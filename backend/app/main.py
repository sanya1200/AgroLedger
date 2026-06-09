import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
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

@asynccontextmanager
async def lifespan(app: FastAPI):
    """System lifecycle events initialization."""
    logger.info("Initializing system components...")
    try:
        # Create database tables if they do not exist
        Base.metadata.create_all(bind=engine)
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
            "error": str(exc) if settings.DEBUG else "A critical error occurred on the server."
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
