#!/usr/bin/env bash
# setup-devsecops-ai-platform.sh — PRO OVERWRITE
# Crea/rehace la plataforma (API Node + AI Flask) y la levanta en Docker o en modo local (fallback).

set -Eeuo pipefail

# -------- Utils --------
ts(){ date +'%H:%M:%S'; }
log(){ echo "[$(ts)] $*"; }
ok(){ echo "✅ $*"; }
warn(){ echo "⚠️  $*"; }
err(){ echo "❌ $*" >&2; }

trap 'err "Falló en la línea ${BASH_LINENO[0]}: ${BASH_COMMAND}"' ERR

have(){ command -v "$1" >/dev/null 2>&1; }
docker_ok(){ docker info >/dev/null 2>&1; }

compose_cmd(){
  if have docker && docker_ok && docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  elif have docker-compose && docker_ok; then
    echo "docker-compose"
  else
    echo ""
  fi
}

# -------- Estructura base --------
log "📦 Preparando estructura (sobrescritura controlada)..."
mkdir -p devsecops-ai-platform/{api,ai,tests,.github/workflows,api/docs}

# API Node.js
log "🛠️ Escribiendo API Node..."
cat > devsecops-ai-platform/api/package.json <<'JSON'
{
  "name": "devsecops-ai-api",
  "version": "1.0.0",
  "main": "server.js",
  "type": "module",
  "scripts": { "start": "node server.js" },
  "dependencies": {
    "axios": "^1.7.4",
    "cors": "^2.8.5",
    "express": "^4.19.2",
    "helmet": "^7.1.0"
  }
}
JSON

cat > devsecops-ai-platform/api/server.js <<'JS'
import express from "express";
import cors from "cors";
import helmet from "helmet";
import axios from "axios";

const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet({
  crossOriginOpenerPolicy: { policy: "same-origin" },
  crossOriginResourcePolicy: { policy: "same-origin" },
  referrerPolicy: { policy: "no-referrer" }
}));

const PORT = process.env.PORT || 3000;
const AI_URL = process.env.AI_URL || "http://ai:5000";

app.get("/", (_req, res) => res.send("✅ API Node corriendo"));
app.get("/status", (_req, res) => res.json({ status: "ok", service: "api", ts: Date.now() }));

app.post("/detect", async (req, res) => {
  try {
    const { data } = await axios.post(`${AI_URL}/detect`, req.body, { timeout: 8000 });
    res.json({ ok: true, source: "api", result: data });
  } catch (e) {
    res.status(502).json({ ok: false, error: e?.message || "AI upstream error" });
  }
});

app.listen(PORT, () => console.log(`API escuchando en :${PORT}`));
JS

cat > devsecops-ai-platform/api/Dockerfile <<'DOCKER'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --no-audit --no-fund
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
DOCKER

# AI Flask
log "🧠 Escribiendo AI Flask..."
cat > devsecops-ai-platform/ai/anomaly_detector.py <<'PY'
from flask import Flask, request, jsonify
from sklearn.ensemble import IsolationForest
import numpy as np
import time

app = Flask(__name__)
start_time = time.time()

model = IsolationForest(random_state=42, contamination="auto")
X_train = np.array([[0.1],[0.2],[0.15],[0.18],[0.22],[0.19],[0.16]])
model.fit(X_train)

@app.route("/", methods=["GET"])
def index():
    return "✅ Servicio AI corriendo"

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "service": "ai", "uptime": time.time() - start_time})

@app.route("/detect", methods=["POST"])
def detect():
    body = request.get_json(silent=True) or {}
    data = body.get("data")
    if data is None:
        return jsonify({"error": "Falta 'data'"}), 400
    try:
        arr = np.array(data).reshape(-1, 1)
    except Exception:
        return jsonify({"error": "Formato inválido"}), 400
    scores = model.decision_function(arr).tolist()
    preds = model.predict(arr).tolist()
    return jsonify({"predictions": preds, "scores": scores})
PY

cat > devsecops-ai-platform/ai/Dockerfile <<'DOCKER'
FROM python:3.10-slim
WORKDIR /app
ENV PIP_NO_CACHE_DIR=1
COPY . .
RUN python -m pip install --upgrade pip && \
    pip install flask scikit-learn pandas numpy
EXPOSE 5000
CMD ["python", "anomaly_detector.py"]
DOCKER

# docker-compose
log "🧩 Escribiendo docker-compose.yml..."
cat > devsecops-ai-platform/docker-compose.yml <<'YML'
version: "3.8"
services:
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    environment:
      - PORT=3000
      - AI_URL=http://ai:5000
    ports:
      - "3000:3000"
    depends_on:
      - ai
    networks:
      - devnet
  ai:
    build:
      context: ./ai
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    networks:
      - devnet
networks:
  devnet:
    driver: bridge
YML

# Lanzar según entorno
DCMD="$(compose_cmd || true)"
if [ -n "${DCMD}" ]; then
  log "🐳 Docker Compose detectado. Levantando..."
  ( cd devsecops-ai-platform && $DCMD down --remove-orphans && $DCMD up --build -d )
else
  warn "Docker no disponible. Debes iniciar servicios manualmente."
fi

ok "Setup completo 🚀"

