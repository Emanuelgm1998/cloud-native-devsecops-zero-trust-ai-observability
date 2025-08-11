from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def root():
    return jsonify({"service": "ai", "status": "ok", "message": "Flask AI up", "health": "/health"})

@app.get("/health")
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(5000))
