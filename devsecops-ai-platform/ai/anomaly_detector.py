#!/usr/bin/env python3
from flask import Flask, request, jsonify
import time, logging, math
import numpy as np

# sklearn opcional
USE_SKLEARN = True
try:
    from sklearn.ensemble import IsolationForest
except Exception:
    USE_SKLEARN = False
    IsolationForest = None

app = Flask(__name__)
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
start_time = time.time()

# -------- Helpers --------
def parse_payload(payload):
    data = payload.get("data") if isinstance(payload, dict) else payload
    if data is None:
        raise ValueError("Entrada inválida: usa {'data':[...]} o una lista directamente.")
    if not isinstance(data, list) or len(data) == 0:
        raise ValueError("Se espera una lista no vacía.")
    # lista de números
    if all(isinstance(x, (int, float)) for x in data):
        X = np.array(data, dtype=float).reshape(-1, 1)
        return X, ["value"]
    # lista de objetos con solo columnas numéricas
    if all(isinstance(x, dict) for x in data):
        # detecta llaves numéricas sin pandas
        keys = set().union(*(d.keys() for d in data))
        num_keys = []
        for k in keys:
            ok = True
            for row in data:
                v = row.get(k, 0.0)
                if isinstance(v, (int, float)) and not (isinstance(v, float) and math.isnan(v)):
                    continue
                ok = False; break
            if ok: num_keys.append(k)
        if not num_keys:
            raise ValueError("No se encontraron columnas numéricas en los objetos.")
        X = np.array([[float(r.get(k, 0.0)) for k in num_keys] for r in data], dtype=float)
        X[np.isnan(X)] = 0.0; X[np.isinf(X)] = 0.0
        return X, num_keys
    raise ValueError("Formato no soportado: lista de números o lista de objetos.")

def detect_iforest(X):
    # modelo ad-hoc por request para evitar persistencia
    model = IsolationForest(random_state=42, contamination=0.1)
    model.fit(X)
    preds  = model.predict(X).tolist()            # 1 normal, -1 anómalo
    scores = model.decision_function(X).tolist()  # mayor = más normal
    return preds, scores

def detect_zscore(X):
    mu = np.mean(X, axis=0)
    sigma = np.std(X, axis=0)
    sigma[sigma == 0] = 1.0
    z = (X - mu) / sigma
    scores = np.mean(np.abs(z), axis=1).tolist()
    preds = [ -1 if any(abs(v) > 2.0 for v in row) else 1 for row in z.tolist() ]
    return preds, scores

# -------- Error handlers JSON --------
@app.errorhandler(400)
def bad_request(e): return jsonify({"error":"Bad Request","detail":str(e)}), 400
@app.errorhandler(422)
def unproc(e): return jsonify({"error":"Unprocessable Entity","detail":str(e)}), 422

# -------- Endpoints --------
@app.route("/", methods=["GET"])
def index():
    return f"✅ Servicio AI corriendo (sklearn={'sí' if USE_SKLEARN else 'no'})"

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status":"ok","service":"ai","sklearn":USE_SKLEARN,"uptime": time.time()-start_time})

@app.route("/detect", methods=["POST"])
def detect():
    try:
        payload = request.get_json(force=True, silent=False)
    except Exception:
        return jsonify({"error":"JSON inválido"}), 400
    try:
        X, features = parse_payload(payload)
    except ValueError as ve:
        return jsonify({"error": str(ve)}), 400
    try:
        if USE_SKLEARN:
            preds, scores = detect_iforest(X)
        else:
            preds, scores = detect_zscore(X)
    except Exception as e:
        # si sklearn falla en runtime, caemos al fallback
        app.logger.warning(f"Fallo en sklearn: {e}. Usando fallback.")
        preds, scores = detect_zscore(X)
    app.logger.info("Anomalías calculadas: filas=%d, features=%d", X.shape[0], X.shape[1])
    return jsonify({
        "ok": True,
        "n_rows": int(X.shape[0]),
        "n_features": int(X.shape[1]),
        "features": features,
        "predictions": preds,
        "scores": scores
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
