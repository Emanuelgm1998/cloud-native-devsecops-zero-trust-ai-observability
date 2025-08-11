#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f ".env" ]; then set -a; source .env; set +a; fi

API_PORT="${API_PORT_HOST:-5858}"
AI_PORT="${AI_PORT_HOST:-5859}"

echo "🧹 Apagando contenedores previos..."
docker compose down --remove-orphans || true

if command -v lsof >/dev/null 2>&1; then
  if lsof -iTCP -sTCP:LISTEN -P | grep -q ":${API_PORT}\b"; then
    echo "⚠️  El puerto ${API_PORT} ya está en uso en el host."
    echo "   Edita .env y cambia API_PORT_HOST (p. ej. 5860) y vuelve a ejecutar."
    exit 2
  fi
fi

echo "🏗️  Build..."
docker compose build --no-cache
echo "🚀 Up..."
docker compose up -d
docker compose ps
echo "✅ API:  http://localhost:${API_PORT}"
echo "✅ AI:   http://localhost:${AI_PORT}"
