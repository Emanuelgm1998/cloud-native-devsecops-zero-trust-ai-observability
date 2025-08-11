#!/usr/bin/env bash
# bootstrap_local.sh — levanta API Node + AI Flask en local con fallback sin Docker

set -Eeuo pipefail
ts(){ date +'%H:%M:%S'; }; log(){ echo "[$(ts)] $*"; }; ok(){ echo "✅ $*"; }; warn(){ echo "⚠️  $*"; }; err(){ echo "❌ $*" >&2; }
trap 'err "Falló en la línea ${BASH_LINENO[0]}: ${BASH_COMMAND}"' ERR

ROOT="devsecops-ai-platform"
API_DIR="$ROOT/api"
AI_DIR="$ROOT/ai"
mkdir -p "$API_DIR" "$AI_DIR" "$ROOT/tests" "$ROOT/.github/workflows" "$ROOT/api/docs"

# --- API Node ---
log "Escribiendo API Node..."
cat > "$API_DIR/package.json" <<'JSON'
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

cat > "$API_DIR/server.js" <<'JS'
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
const AI_URL = process.env.AI_URL || "http://localhost:5000";

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

# --- AI Flask con fallback si sklearn falla ---
log "Escribiendo AI Flask (con fallback sin sklearn)..."
cat > "$AI_DIR/anomaly_detector.py" <<'PY'
from flask import Flask, request, jsonify
import time, numpy as np

# Intentar sklearn; si falla, usamos z-score simple
USE_SKLEARN = True
try:
    from sklearn.ensemble import IsolationForest
except Exception:
    USE_SKLEARN = False

app = Flask(__name__)
start_time = time.time()

if USE_SKLEARN:
    model = IsolationForest(random_state=42, contamination="auto")
    X_train = np.array([[0.1],[0.2],[0.15],[0.18],[0.22],[0.19],[0.16]])
    model.fit(X_train)

@app.route("/", methods=["GET"])
def index():
    return "✅ Servicio AI corriendo (sklearn=%s)" % ("sí" if USE_SKLEARN else "no")

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status":"ok","service":"ai","sklearn": USE_SKLEARN, "uptime": time.time() - start_time})

@app.route("/detect", methods=["POST"])
def detect():
    body = request.get_json(silent=True) or {}
    data = body.get("data")
    if data is None:
        return jsonify({"error": "Falta 'data'"}), 400
    try:
        arr = np.array(data, dtype=float).reshape(-1,1)
    except Exception:
        return jsonify({"error": "Formato inválido, se espera lista de números"}), 400

    if USE_SKLEARN:
        scores = model.decision_function(arr).tolist()
        preds = model.predict(arr).tolist()  # 1 normal, -1 anómalo
    else:
        # Fallback: z-score por columna y umbral |z|>2 como anomalía
        x = arr.flatten()
        mu, sigma = float(np.mean(x)), float(np.std(x) if np.std(x) != 0 else 1.0)
        z = ((x - mu) / sigma).tolist()
        preds = [ -1 if abs(v) > 2 else 1 for v in z ]
        scores = z
    return jsonify({"predictions": preds, "scores": scores})
PY

# --- Scripts start/stop local ---
log "Escribiendo scripts start/stop..."
cat > "$ROOT/start-local.sh" <<'BASH'
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
BASH
chmod +x "$ROOT/start-local.sh"

cat > "$ROOT/stop-local.sh" <<'BASH'
#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
stop_pid(){
  local f="$1"
  [ -f "$f" ] || return 0
  local pid; pid="$(cat "$f" || true)"
  [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null && kill "$pid" || true
  sleep 1; kill -9 "${pid:-999999}" 2>/dev/null || true
  rm -f "$f"
}
stop_pid "$ROOT/api.pid"
stop_pid "$ROOT/ai.pid"
echo "🛑 Servicios detenidos."
BASH
chmod +x "$ROOT/stop-local.sh"

# --- Lanzar y probar ---
log "Levantando servicios locales..."
( cd "$ROOT" && ./start-local.sh )

log "Probando endpoints (espera 4s)..."; sleep 4
set +e
echo "API /status =>";  curl -sS http://localhost:3000/status || true
echo
echo "AI /health   =>"; curl -sS http://localhost:5000/health || true
echo
echo "AI /detect   =>"; curl -sS -X POST http://localhost:5000/detect -H "Content-Type: application/json" -d '{"data":[1,2,3,100]}' || true
echo
set -e

ok "Todo listo. Para detener: (cd $ROOT && ./stop-local.sh)"
