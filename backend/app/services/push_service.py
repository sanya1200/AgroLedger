import logging
import firebase_admin
from firebase_admin import credentials, messaging
from sqlalchemy.orm import Session
from datetime import datetime, timezone, timedelta
from app.models.calendar import LivestockTask
from app.models.user import User

logger = logging.getLogger(__name__)

# Попытка инициализации Firebase Admin SDK
try:
    # Предполагается, что переменная окружения GOOGLE_APPLICATION_CREDENTIALS указывает на service_account.json
    firebase_admin.initialize_app()
    FIREBASE_ENABLED = True
    logger.info("Firebase Admin initialized successfully.")
except Exception as e:
    logger.warning(f"Firebase Admin could not be initialized: {e}")
    FIREBASE_ENABLED = False

def send_push_notification(token: str, title: str, body: str, data: dict = None):
    if not FIREBASE_ENABLED or not token:
        logger.info(f"Mock Push -> Token: {token} | Title: {title} | Body: {body}")
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
        logger.info(f"Successfully sent message: {response}")
    except Exception as e:
        logger.error(f"Error sending push notification: {e}")

def check_upcoming_tasks(db: Session):
    """
    Проверяет задачи на ближайшие 2 часа и отправляет пуш-уведомления.
    """
    now = datetime.now(timezone.utc)
    target_time = now + timedelta(hours=2)

    # Находим задачи, которые начинаются в ближайшие 2 часа и еще не помечены как 'completed'
    tasks = db.query(LivestockTask).filter(
        LivestockTask.due_date > now,
        LivestockTask.due_date <= target_time,
        LivestockTask.status != 'completed'
    ).all()

    for task in tasks:
        # Для задачи нужно найти пользователя. Задача привязана к BusinessProfile или LivestockAsset.
        # В нашей схеме LivestockTask привязана к User напрямую?
        # Посмотрим схему...
        user = task.user
        if user and user.fcm_token:
            send_push_notification(
                token=user.fcm_token,
                title="Напоминание AgroLedger",
                body=f"Задача '{task.title}' запланирована на {task.due_date.strftime('%H:%M')}.",
                data={"task_id": str(task.id)}
            )
