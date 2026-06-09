import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException
from fastapi.exceptions import RequestValidationError
from sqlalchemy import text

from app.core.config import settings
from app.core.database import engine, Base

from app.models.user import User, UserSession
from app.models.business_profile import BusinessProfile
from app.models.marketplace import Product
from app.models.calculator import CalculationCycle, Expense, Income

import app.routers.auth as auth_mod
import app.routers.business as business_mod
import app.routers.calculator as calculator_mod
import app.routers.marketplace as marketplace_mod

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

DEVICE_HEADERS = [
    "Authorization",
    "Content-Type",
    "Accept",
    "X-Device-Fingerprint",
    "X-Device-Name",
]

def run_migrations():
    """Manually apply schema changes to existing tables."""
    try:
        with engine.connect() as conn:
            logger.info("Running manual migrations...")

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
                    check_sql = text(
                        f"SELECT data_type FROM information_schema.columns "
                        f"WHERE table_name='users' AND column_name='{column}'"
                    )
                    result = conn.execute(check_sql).fetchone()

                    if not result:
                        logger.info(f"Adding column {column} to users table...")
                        conn.execute(text(f"ALTER TABLE users ADD COLUMN {column} {col_type}"))
                        conn.commit()
                    elif column == "role" and result[0] == "USER-DEFINED":
                        logger.info("Converting 'role' column from ENUM to VARCHAR for compatibility...")
                        conn.execute(text(
                            "ALTER TABLE users ALTER COLUMN role TYPE VARCHAR(50) USING role::text"
                        ))
                        conn.commit()
                except Exception as e:
                    logger.warning(f"Could not migrate column {column}: {e}")

            session_columns = {
                "refresh_jti": "VARCHAR(36)",
                "revoked_at": "TIMESTAMP WITH TIME ZONE",
                "grace_access_token": "TEXT",
                "grace_refresh_token": "TEXT",
                "grace_expires_at": "TIMESTAMP WITH TIME ZONE",
            }

            for column, col_type in session_columns.items():
                try:
                    check_sql = text(
                        f"SELECT column_name FROM information_schema.columns "
                        f"WHERE table_name='user_sessions' AND column_name='{column}'"
                    )
                    result = conn.execute(check_sql).fetchone()
                    if not result:
                        logger.info(f"Adding column {column} to user_sessions table...")
                        conn.execute(text(
                            f"ALTER TABLE user_sessions ADD COLUMN {column} {col_type}"
                        ))
                        conn.commit()
                except Exception as e:
                    logger.warning(f"Could not migrate user_sessions column {column}: {e}")

            logger.info("Migrations completed.")
    except Exception as e:
        logger.error(f"Migration process failed: {e}")

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Initializing system components...")
    try:
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

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=DEVICE_HEADERS,
    expose_headers=[
        "X-Device-Fingerprint",
        "X-Device-Name",
    ],
)

app.include_router(auth_mod.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Security & Auth Core"])
app.include_router(business_mod.router, prefix=f"{settings.API_V1_STR}/business", tags=["Business Profile"])
app.include_router(calculator_mod.router, prefix=f"{settings.API_V1_STR}/calculator", tags=["Calculations"])
app.include_router(marketplace_mod.router, prefix=f"{settings.API_V1_STR}/marketplace", tags=["Marketplace"])

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
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
    logger.error(f"Critical System Error: {exc}", exc_info=True)

    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "data": None,
            "error": f"Server Error: {str(exc)}" if getattr(settings, "DEBUG", True) else "A critical error occurred on the server."
        },
    )

@app.get("/api/v1/healthcheck")
async def health_check():
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        db_status = "connected"
    except Exception as e:
        db_status = f"error: {str(e)}"

    return {
        "success": True,
        "data": {
            "status": "healthy",
            "version": "2.0.0",
            "database": db_status
        },
        "error": None
    }

@app.get("/")
async def root():
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
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
