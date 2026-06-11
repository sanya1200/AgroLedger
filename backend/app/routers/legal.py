from fastapi import APIRouter
from fastapi.responses import HTMLResponse

router = APIRouter()

PRIVACY_HTML = """
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Политика конфиденциальности - AgroLedger</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #2c3e50; }
        h2 { color: #34495e; margin-top: 30px; }
    </style>
</head>
<body>
    <h1>Политика конфиденциальности</h1>
    <p>Последнее обновление: 11 июня 2026 г.</p>
    
    <h2>1. Сбор информации</h2>
    <p>Мы собираем информацию, которую вы предоставляете напрямую, включая ваше имя, email, номер телефона и данные о вашем хозяйстве.</p>
    
    <h2>2. Использование информации</h2>
    <p>Мы используем собранную информацию для предоставления, поддержки и улучшения наших услуг, а также для защиты наших пользователей.</p>
    
    <h2>3. Защита данных</h2>
    <p>Мы применяем соответствующие меры безопасности для защиты вашей личной информации от несанкционированного доступа.</p>
    
    <h2>4. Обработка персональных данных</h2>
    <p>Используя наше приложение, вы даете согласие на обработку ваших персональных данных в соответствии с законодательством Республики Казахстан.</p>
</body>
</html>
"""

TERMS_HTML = """
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Пользовательское соглашение - AgroLedger</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #2c3e50; }
        h2 { color: #34495e; margin-top: 30px; }
    </style>
</head>
<body>
    <h1>Пользовательское соглашение</h1>
    <p>Последнее обновление: 11 июня 2026 г.</p>
    
    <h2>1. Принятие условий</h2>
    <p>Используя приложение AgroLedger, вы соглашаетесь с настоящими условиями. Если вы не согласны, пожалуйста, не используйте приложение.</p>
    
    <h2>2. Описание услуг</h2>
    <p>AgroLedger предоставляет инструменты для управления фермерским хозяйством, включая калькулятор прибыльности, маркетплейс и консультации с ИИ-ветеринаром.</p>
    
    <h2>3. Ограничение ответственности</h2>
    <p>Рекомендации ИИ-ветеринара носят исключительно информационный характер и не заменяют профессиональную ветеринарную помощь. Мы не несем ответственности за ущерб, возникший в результате использования этих рекомендаций.</p>
    
    <h2>4. Маркетплейс</h2>
    <p>AgroLedger не выступает стороной сделки между покупателем и продавцом на маркетплейсе и не несет ответственности за качество товаров.</p>
</body>
</html>
"""

TRADE_HTML = """
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Правила торговли - AgroLedger</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 0 auto; padding: 20px; }
        h1 { color: #2c3e50; }
        h2 { color: #34495e; margin-top: 30px; }
    </style>
</head>
<body>
    <h1>Правила торговли на платформе</h1>
    <p>Последнее обновление: 11 июня 2026 г.</p>
    
    <h2>1. Требования к продавцам</h2>
    <p>Только верифицированные хозяйства могут публиковать товары на маркетплейсе.</p>
    
    <h2>2. Описание товаров</h2>
    <p>Товары должны сопровождаться достоверным описанием и реальными фотографиями.</p>
    
    <h2>3. Запрещенные товары</h2>
    <p>Запрещена продажа больных животных, несертифицированных препаратов и других незаконных товаров.</p>
</body>
</html>
"""

@router.get("/privacy", response_class=HTMLResponse)
async def get_privacy():
    return PRIVACY_HTML

@router.get("/terms", response_class=HTMLResponse)
async def get_terms():
    return TERMS_HTML

@router.get("/trade", response_class=HTMLResponse)
async def get_trade():
    return TRADE_HTML
