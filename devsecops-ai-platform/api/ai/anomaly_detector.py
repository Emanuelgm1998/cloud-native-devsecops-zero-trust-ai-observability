from flask import Flask, request, jsonify
import pandas as pd
from sklearn.ensemble import IsolationForest
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

@app.route('/')
def index():
    return "✅ Microservicio AI activo. Usa POST en /detect para enviar métricas."

@app.route('/detect', methods=['POST'])
def detect():
    data = request.get_json()
    if not data or not isinstance(data, list):
        return jsonify({'error': 'Entrada inválida. Se espera una lista de objetos.'}), 400
    try:
        df = pd.DataFrame(data)
        model = IsolationForest(contamination=0.1)
        df['anomaly'] = model.fit_predict(df)
        return jsonify(df.to_dict(orient='records'))
    except Exception as e:
        logging.error(f"❌ Error en el procesamiento: {e}")
        return jsonify({'error': 'Error interno en el modelo AI.'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
