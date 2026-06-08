import logging
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import engine, Base
# Импортируем модули роутеров с уникальными именами
import app.routers.auth as auth_mod
import app.routers.business as business_mod
import app.routers.calculator as calculator_mod
import app.routers.marketplace as marketplace_mod

# Импортируем модели для создания таблиц
import app.models.user
import app.models.business_profile
import app.models.calculator
import app.models.marketplace

# Создаем таблицы в БД
Base.metadata.create_all(bind=engine)

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключаем роутеры через созданные алиасы
app.include_router(auth_mod.router, prefix=f"{settings.API_V1_STR}/auth", tags=["Authentication"])
app.include_router(business_mod.router, prefix=f"{settings.API_V1_STR}/business", tags=["Business Profile"])
app.include_router(calculator_mod.router, prefix=f"{settings.API_V1_STR}/calculator", tags=["Calculator"])
app.include_router(marketplace_mod.router, prefix=f"{settings.API_V1_STR}/marketplace", tags=["Marketplace"])

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal server error", "error_type": type(exc).__name__},
    )

@app.get("/api/v1/healthcheck")
async def health_check():
    return {"status": "healthy", "project": settings.PROJECT_NAME}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
