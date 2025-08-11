#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f ".env" ] && { set -a; source .env; set +a; }
# Quita 'version:' obsoleta si existe (solo para evitar warnings)
sed -i.bak '/^[[:space:]]*version:/d' docker-compose.yml 2>/dev/null || true
echo "🧹 docker compose down…"; docker compose down --remove-orphans || true
echo "🏗️ docker compose build…"; docker compose build
echo "🚀 docker compose up -d…"; docker compose up -d
echo "📦 Estado:"; docker compose ps
