#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Cargar variables
if [ -f ".env" ]; then set -a; source .env; set +a; fi
API_PORT="${API_PORT_HOST:-5858}"
AI_PORT="${AI_PORT_HOST:-5859}"

echo "🧹 Apagando contenedores previos…"
docker compose down --remove-orphans || true

# Chequeo de puertos ocupados (host)
if command -v lsof >/dev/null 2>&1; then
  if lsof -iTCP -sTCP:LISTEN -P | grep -q ":${API_PORT}\b"; then
    echo "⚠️  Puerto API ${API_PORT} ocupado. Edita .env -> API_PORT_HOST (ej: 5860) y reintenta."
    exit 2
  fi
  if lsof -iTCP -sTCP:LISTEN -P | grep -q ":${AI_PORT}\b"; then
    echo "⚠️  Puerto AI ${AI_PORT} ocupado. Edita .env -> AI_PORT_HOST (ej: 5861) y reintenta."
    exit 2
  fi
fi

echo "🏗️  Build imágenes…"
docker compose build --no-cache

echo "🚀 Levantando servicios…"
docker compose up -d

echo "📋 Estado:"
docker compose ps

echo "✅ API:  http://localhost:${API_PORT}"
echo "✅ AI:   http://localhost:${AI_PORT}"
