
@app.route('/')
def index():
    return "✅ Servicio AI corriendo"


@app.route('/health')
def health():
    return jsonify({"status": "ok", "uptime": time.time() - start_time})

