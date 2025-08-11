#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(pwd)"; AI_DIR="$ROOT/ai"

# matar AI previo si existe
[ -f "$ROOT/ai.pid" ] && { PID=$(cat "$ROOT/ai.pid"); kill -9 "$PID" 2>/dev/null || true; rm -f "$ROOT/ai.pid"; }

# venv y deps mínimas
python3 -m venv "$AI_DIR/.venv"
source "$AI_DIR/.venv/bin/activate"
python -m pip install --upgrade pip >/dev/null
pip install flask numpy >/dev/null
# arrancar AI
nohup python "$AI_DIR/anomaly_detector.py" > "$ROOT/ai.out" 2>&1 & echo $! > "$ROOT/ai.pid"
deactivate
sleep 2

echo "AI /health:"
curl -s http://localhost:5000/health || true
echo
