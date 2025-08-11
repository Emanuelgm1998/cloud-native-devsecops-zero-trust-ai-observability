# 🌐 DevSecOps AI Platform

Plataforma cloud-native con DevSecOps, Zero Trust y observabilidad con AI.

## 🚀 Tecnologías
- Docker & Docker Compose
- Node.js (Express, Helmet)
- Python (Flask, scikit-learn)

## 📦 Estructura
\`\`\`
devsecops-ai-platform/
├── api/
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
├── ai/
│   ├── anomaly_detector.py
│   └── Dockerfile
├── docker-compose.yml
└── README.md
\`\`\`

## 🧪 Endpoints
- API: `GET /status`, `POST /detect`
- AI: `GET /health`, `POST /detect`

## 🛡️ Seguridad
- Helmet + CORS
- Aislamiento de servicios
- Reinicio automático
