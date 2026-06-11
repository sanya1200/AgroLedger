import logging
import firebase_admin
from firebase_admin import credentials, messaging
from sqlalchemy.orm import Session
from datetime import datetime, timezone, timedelta
from app.models.calendar import LivestockTask
from app.models.calculator import LivestockAsset
from app.models.user import User

logger = logging.getLogger(__name__)

try:
    if not firebase_admin._apps:
        firebase_admin.initialize_app()
    FIREBASE_ENABLED = True
    logger.info("Firebase Admin initialized successfully.")
except Exception as e:
    logger.warning(f"Firebase Admin could not be initialized: {e}")
    FIREBASE_ENABLED = False

def send_push_notification(token: str, title: str, body: str, data: dict = None):
    if not token:
        logger.warning(f"Cannot send push notification, missing token. Title: {title}")
        return

    if not FIREBASE_ENABLED:
        logger.warning(f"Firebase is not enabled. Skipped push to {token}. Title: {title}")
        return

    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=token,
        )
        response = messaging.send(message)
        logger.info(f"Successfully sent FCM message: {response}")
    except Exception as e:
        logger.error(f"Error sending FCM push notification: {e}")

def check_upcoming_tasks(db: Session):
    now = datetime.now(timezone.utc)
    target_time = now + timedelta(hours=2)

    tasks = db.query(LivestockTask).join(LivestockAsset).filter(
        LivestockTask.planned_date > now,
        LivestockTask.planned_date <= target_time,
        LivestockTask.is_completed == False
    ).all()

    for task in tasks:
        asset = task.asset
        if asset and asset.user:
            user = asset.user
            if user.fcm_token:
                send_push_notification(
                    token=user.fcm_token,
                    title="Напоминание AgroLedger",
                    body=f"Задача '{task.title}' для группы '{asset.breed}' запланирована на {task.planned_date.strftime('%H:%M')}.",
                    data={"task_id": str(task.id), "asset_id": str(asset.id)}
                )
