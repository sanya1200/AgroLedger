#!/bin/bash
set -e

echo "Applying database migrations..."
# Убеждаемся, что база готова перед запуском alembic
# В продакшене лучше использовать wait-for-it или встроенные проверки
alembic upgrade head

echo "Starting application..."
# Передаем управление uvicorn
exec "$@"
