# 🌐 Cloud-Native DevSecOps Platform with Zero Trust & AI Observability

A **production-grade microservices platform** built with **Node.js** (API) and **Python Flask** (AI service), orchestrated via **Docker Compose**.  
Designed with **Zero Trust principles**, featuring **health checks**, and ready for **GitHub Codespaces**, local development, or cloud deployment.

---

## 🚀 Features
- **API** → Node.js + Express + Helmet
- **AI** → Python + Flask
- **Health checks** on `/health` endpoints
- **Docker Compose orchestration**
- **Configurable ports** via `.env`
- **Automation scripts** for restart and verification

---

## ⚙️ Setup & Activation

Run the following commands from the project root to start the entire platform:

```bash
# 1. Navigate to the platform directory
cd devsecops-ai-platform

# 2. Copy the environment variables file (only if .env doesn't exist)
cp .env.example .env

# 3. Start the platform
./scripts/ai_restart.sh

# 4. Verify that both services are healthy
./scripts/verify.sh

✅ API / OK
✅ API /health OK
✅ AI / OK
✅ AI /health OK
🎉 Todo OK
 