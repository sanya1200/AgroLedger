import logging
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
import cloudinary
import cloudinary.uploader
from app.core.config import settings
from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()
logger = logging.getLogger(__name__)

if settings.CLOUDINARY_URL:
    cloudinary.config(url=settings.CLOUDINARY_URL)

@router.post("/image")
async def upload_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user)
):
    if not settings.CLOUDINARY_URL:
        # Режим заглушки: возвращаем случайную картинку, если Cloudinary не настроен
        logger.warning("CLOUDINARY_URL is not set. Returning a mock image URL.")
        return {"url": "https://via.placeholder.com/600x400?text=AgroLedger+Mock+Image"}

    if file.content_type not in ["image/jpeg", "image/png", "image/webp"]:
        raise HTTPException(status_code=400, detail="Только JPEG, PNG и WEBP форматы поддерживаются.")

    try:
        # Загрузка файла в Cloudinary
        result = cloudinary.uploader.upload(
            file.file,
            folder="agroledger_products",
            resource_type="image",
            quality="auto",
            fetch_format="auto"
        )
        return {"url": result.get("secure_url")}
    except Exception as e:
        logger.error(f"Error uploading image to Cloudinary: {e}")
        raise HTTPException(status_code=500, detail="Ошибка загрузки изображения")
