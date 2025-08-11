from flask import Flask, request, jsonify
import time, numpy as np

# Intentar sklearn; si falla, usamos z-score simple como fallback
USE_SKLEARN = True
try:
    from sklearn.ensemble import IsolationForest
except Exception:
    USE_SKLEARN = False

app = Flask(__name__)
start_time = time.time()

if USE_SKLEARN:
    try:
        model = IsolationForest(random_state=42, contamination="auto")
        X_train = np.array([[0.1],[0.2],[0.15],[0.18],[0.22],[0.19],[0.16]])
        model.fit(X_train)
    except Exception:
        USE_SKLEARN = False  # si falla el fit, pasamos a fallback

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
        try:
            scores = IsolationForest().fit(arr).decision_function(arr).tolist()
            # Nota: entreno rápido sobre la misma muestra para robustez en entornos sin modelo persistente
            preds = IsolationForest().fit(arr).predict(arr).tolist()
        except Exception:
            # Si algo falla en runtime, caemos al fallback
            USE_SKLEARN = False

    if not USE_SKLEARN:
        x = arr.flatten()
        mu = float(np.mean(x))
        sigma = float(np.std(x)) if float(np.std(x)) != 0 else 1.0
        z = ((x - mu) / sigma).tolist()
        preds = [ -1 if abs(v) > 2 else 1 for v in z ]
        scores = z

    return jsonify({"predictions": preds, "scores": scores})
