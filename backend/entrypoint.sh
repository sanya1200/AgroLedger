#!/bin/bash
set -e

echo "Database initialization is handled automatically by the application lifespan context (create_all & run_migrations)."

echo "Starting application..."
# Передаем управление uvicorn
exec "$@"
