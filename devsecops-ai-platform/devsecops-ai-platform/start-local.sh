#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$ROOT/api"
AI_DIR="$ROOT/ai"

echo "📦 Instalando deps API..."
if ! command -v npm >/dev/null 2>&1; then echo "❌ npm no encontrado"; exit 1; fi
( cd "$API_DIR" && npm install --no-audit --no-fund )

echo "🐍 Preparando venv AI..."
PYBIN="python3"
command -v $PYBIN >/dev/null 2>&1 || PYBIN="python"
command -v $PYBIN >/dev/null 2>&1 || { echo "❌ python no encontrado"; exit 1; }
$PYBIN -m venv "$AI_DIR/.venv"
source "$AI_DIR/.venv/bin/activate"
pip install --upgrade pip >/dev/null
# Intentamos sklearn; si falla, seguimos (usará fallback)
pip install flask numpy >/dev/null || true
pip install scikit-learn pandas >/dev/null || echo "⚠️ sklearn/pandas no instalados: se usará fallback"
deactivate

echo "🚀 Iniciando AI Flask..."
nohup "$AI_DIR/.venv/bin/python" "$AI_DIR/anomaly_detector.py" > "$ROOT/ai.out" 2>&1 &
echo $! > "$ROOT/ai.pid"

echo "🚀 Iniciando API Node..."
( cd "$API_DIR" && nohup npm run start > "$ROOT/api.out" 2>&1 & echo $! > "$ROOT/api.pid" )

echo "✅ Arrancado. Logs: $ROOT/api.out / $ROOT/ai.out"
