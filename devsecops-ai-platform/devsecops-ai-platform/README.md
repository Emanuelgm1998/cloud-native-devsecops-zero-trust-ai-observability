# 🌐 DevSecOps AI Platform

Plataforma cloud-native con DevSecOps, Zero Trust y observabilidad con AI.

## 🚀 Tecnologías
- AWS, Docker, Kubernetes
- Node.js, Flask, Python
- CI/CD con GitHub Actions
- AI: Isolation Forest para anomalías

## 📦 Estructura
```
devsecops-ai-platform/
├── api/              # Microservicio Node.js
├── ai/               # Servicio AI Flask
├── tests/            # Scripts de prueba
├── docker-compose.yml
└── .github/workflows/
```

## 🧪 Endpoints
- API: [http://localhost:3000/status](http://localhost:3000/status)
- AI: [http://localhost:5000/health](http://localhost:5000/health)
- AI Detect: POST /detect

## 🛡️ Seguridad
- Zero Trust
- Validación de tokens
- Escaneo de vulnerabilidades

## 📈 Observabilidad
- Logs estructurados
- AI para detección de anomalías
