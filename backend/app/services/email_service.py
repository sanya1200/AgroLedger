import logging
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import Optional
from app.core.config import settings

logger = logging.getLogger(__name__)

def send_verification_email(email: str, code: str) -> bool:
    """
    Sends a verification email with a 6-digit code.
    Falls back to logging if SMTP is not configured.
    """
    # Print code to logger first (useful for local testing)
    logger.info(f"\n========================================\nVERIFICATION CODE for {email}: {code}\n========================================\n")
    print(f"\n========================================\nVERIFICATION CODE for {email}: {code}\n========================================\n")

    if not settings.SMTP_HOST or not settings.SMTP_USER or not settings.SMTP_PASSWORD:
        logger.warning("SMTP settings not fully configured. Email was not sent via SMTP (printed to log instead).")
        return False

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = "AgroLedger - Код подтверждения регистрации"
        msg["From"] = settings.SMTP_FROM or settings.SMTP_USER
        msg["To"] = email

        html = f"""
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f7f9f6; padding: 20px; color: #2d3748;">
            <div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 12px; padding: 30px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
              <h2 style="color: #4a5d4e; margin-bottom: 20px; text-align: center;">Добро пожаловать в AgroLedger!</h2>
              <p style="font-size: 16px; line-height: 1.6;">Здравствуйте!</p>
              <p style="font-size: 16px; line-height: 1.6;">Для завершения регистрации и входа в приложение, пожалуйста, введите следующий 6-значный код подтверждения:</p>
              <div style="text-align: center; margin: 30px 0;">
                <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #4a5d4e; background: #eef2ed; padding: 12px 24px; border-radius: 8px;">{code}</span>
              </div>
              <p style="font-size: 14px; color: #718096; line-height: 1.6;">Код действителен в течение 10 минут. Если вы не запрашивали этот код, просто проигнорируйте это письмо.</p>
              <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 30px 0;">
              <p style="font-size: 12px; color: #a0aec0; text-align: center;">С уважением,<br>Команда AgroLedger</p>
            </div>
          </body>
        </html>
        """

        msg.attach(MIMEText(html, "html"))

        # Connect to SMTP server
        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
            if settings.SMTP_PORT == 587:
                server.starttls()
            server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
            server.sendmail(settings.SMTP_USER, email, msg.as_string())
            
        logger.info(f"Verification email successfully sent to {email}")
        return True
    except Exception as e:
        logger.error(f"Failed to send verification email to {email}: {e}")
        return False
