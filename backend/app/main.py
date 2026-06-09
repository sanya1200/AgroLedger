import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException
from fastapi.exceptions import RequestValidationError

from app.core.config import settings
from sqlalchemy import text
from app.core.database import engine, Base
import app.routers.auth as auth_mod
import app.routers.business as business_mod
import app.routers.calculator as calculator_mod
import app.routers.marketplace as marketplace_mod

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

def run_migrations():
    """Manually apply schema changes to existing tables."""
    with engine.connect() as conn:
        logger.info("Running manual migrations...")
        
        # 1. Ensure 'users' table has all required columns
        columns_to_add = {
            "full_name": "VARCHAR(255)",
            "hashed_pin": "VARCHAR(255)",
            "is_biometric_enabled": "BOOLEAN DEFAULT FALSE",
            "role": "VARCHAR(50) DEFAULT 'customer_buyer'",
            "is_active": "BOOLEAN DEFAULT TRUE",
            "is_verified": "BOOLEAN DEFAULT FALSE",
            "created_at": "TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP"
        }
        
        for column, col_type in columns_to_add.items():
            try:
                # PostgreSQL specific check
                check_sql = text(f"SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='{column}'")
                if not conn.execute(check_sql).fetchone():
                    logger.info(f"Adding column {column} to users table...")
                    conn.execute(text(f"ALTER TABLE users ADD COLUMN {column} {col_type}"))
                    conn.commit()
            except Exception as e:
                logger.warning(f"Could not add column {column}: {e}")
        
        logger.info("Migrations completed.")

@asynccontextmanager
async def lifespan(app: FastAPI):
    """System lifecycle events initialization."""
    logger.info("Initializing system components...")
    try:
        # Create database tables if they do not exist
        Base.metadata.create_all(bind=engine)
        run_migrations()
        logger.info("Database initialized successfully.")
    except Exception as e:
        logger.error(f"Failed to initialize database: {e}")
    yield
    logger.info("Shutting down system...")

app = FastAPI(
    title="AgroLedger Core API",
    version="2.0.0",
    lifespan=lifespan,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Global CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Application Routers
app.include_router(auth_mod.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Security & Auth Core"])
app.include_router(business_mod.router, prefix=f"{settings.API_V1_STR}/business", tags=["Business Profile"])
app.include_router(calculator_mod.router, prefix=f"{settings.API_V1_STR}/calculator", tags=["Calculations"])
app.include_router(marketplace_mod.router, prefix=f"{settings.API_V1_STR}/marketplace", tags=["Marketplace"])

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    """Custom handler for HTTP exceptions to keep the envelope."""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "data": None,
            "error": str(exc.detail)
        },
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Custom handler for Pydantic validation errors."""
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "data": None,
            "error": f"Validation error: {exc.errors()}"
        },
    )

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Standardized error handler for all unhandled exceptions."""
    logger.error(f"Critical System Error: {exc}", exc_info=True)

    # Standardized JSON response envelope
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "data": None,
            "error": str(exc) if getattr(settings, "DEBUG", False) else "A critical error occurred on the server."
        },
    )

@app.get("/api/v1/healthcheck")
async def health_check():
    """Service health status endpoint."""
    return {"success": True, "data": {"status": "healthy", "version": "2.0.0"}, "error": None}

@app.get("/")
async def root():
    """Root redirect / landing info."""
    return {
        "success": True,
        "data": {
            "message": "AgroLedger Industrial API is running",
            "docs": "/docs"
        },
        "error": None
    }

if __name__ == "__main__":
    import uvicorn
    # In production, uvicorn is usually run from the command line
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
