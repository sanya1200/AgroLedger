import os
import uuid
import logging
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Request
import cloudinary
import cloudinary.uploader
from app.core.config import settings
from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()
logger = logging.getLogger(__name__)

if settings.CLOUDINARY_URL:
    cloudinary.config(url=settings.CLOUDINARY_URL)

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/image")
async def upload_image(
    request: Request,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user)
):
    if file.content_type not in ["image/jpeg", "image/png", "image/webp"]:
        raise HTTPException(status_code=400, detail="Только JPEG, PNG и WEBP форматы поддерживаются.")

    try:
        if settings.CLOUDINARY_URL:
            result = cloudinary.uploader.upload(
                file.file,
                folder="agroledger_products",
                resource_type="image",
                quality="auto",
                fetch_format="auto"
            )
            return {"url": result.get("secure_url")}
        else:
            ext = file.filename.split(".")[-1] if "." in file.filename else "jpg"
            filename = f"{uuid.uuid4().hex}.{ext}"
            file_path = os.path.join(UPLOAD_DIR, filename)
            
            with open(file_path, "wb") as buffer:
                content = await file.read()
                buffer.write(content)
            
            base_url = str(request.base_url).rstrip("/")
            url = f"{base_url}/uploads/{filename}"
            return {"url": url}
            
    except Exception as e:
        logger.error(f"Error uploading image: {e}")
        raise HTTPException(status_code=500, detail="Ошибка загрузки изображения")
