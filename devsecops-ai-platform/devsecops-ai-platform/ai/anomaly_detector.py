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
