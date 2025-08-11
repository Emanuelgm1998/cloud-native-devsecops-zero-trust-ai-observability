# Cloud-Native DevSecOps Platform — Zero Trust & AI Observability

A production-ready, minimal platform composed of two independent, health-checked services:

- **API** → Node.js + Express + Helmet (internal port `3000`, exposed to host via `API_PORT_HOST`, default `5858`)
- **AI** → Flask + Gunicorn (internal port `5000`, exposed to host via `AI_PORT_HOST`, default `5859`)

**Features:**
- Docker Compose orchestration
- Automatic healthchecks
- Service start and verification scripts
- Configurable ports via `.env`
- Optimized `.dockerignore` and `.gitignore`
- Quick local tests with `curl` + `jq`

---

## 📦 Prerequisites

- **Docker** and **Docker Compose**
- `jq` and `lsof` (auto-installed by start script if missing)
- Linux, macOS, or WSL2 (Windows)

---

## 📂 Project Structure

.
├── api/
│ ├── Dockerfile
│ ├── package.json
│ ├── server.js
│ └── .dockerignore
├── ai/
│ ├── Dockerfile
│ ├── requirements.txt
│ ├── app.py
│ └── .dockerignore
├── scripts/
│ ├── ai_restart.sh # Stops, builds, and starts services
│ ├── verify.sh # Verifies API and AI endpoints
│ ├── verify_all.sh # Alias to verify.sh
│ └── run_tests.sh # Full automated tests
├── docker-compose.yml
├── .env.example
├── .env
├── .gitignore
└── README.md

yaml
Copiar
Editar

---

## 🚀 Quick Start

### 1) Clone and configure
```bash
git clone <REPO_URL>
cd <REPO_NAME>
cp -n .env.example .env
2) Start the platform
bash
Copiar
Editar
./scripts/ai_restart.sh
This script will:

Stop previous containers

Check for free ports

Rebuild images (--no-cache)

Start api and ai in detached mode

Display status and URLs

3) Verify services
bash
Copiar
Editar
./scripts/verify.sh
Expected output:

bash
Copiar
Editar
✅ API / OK
✅ API /health OK
✅ AI / OK
✅ AI /health OK
🎉 All OK
🌐 Available Endpoints
API (Node.js)
GET / → { service: "api", status: "ok", ... }

GET /health → { status: "healthy" }

GET /<non_existing_route> → 404 JSON

AI (Flask)
GET / → { service: "ai", status: "ok", ... }

GET /health → { status: "healthy" }

GET /<non_existing_route> → 404 JSON

⚙️ Port Configuration
Edit .env:

env
Copiar
Editar
API_PORT_HOST=5858   # API:  host:API_PORT_HOST → container:3000
AI_PORT_HOST=5859    # AI:   host:AI_PORT_HOST  → container:5000
If a port is in use, the start script will prompt you to change it.

✅ Verification After Deployment
Once the platform is running, validate that all services and healthchecks work:

bash
Copiar
Editar
./scripts/run_tests.sh
What this does:

Checks API (/ and /health)

Checks AI (/ and /health)

Verifies 404 on invalid routes

Ensures Docker healthchecks are healthy

Expected output:

scss
Copiar
Editar
✅ API OK (/, /health, 404)
✅ AI OK (/, /health, 404)
✅ Healthchecks Docker OK
🎉 All tests passed.
If any test fails:

bash
Copiar
Editar
docker compose logs -f api
docker compose logs -f ai
📋 Logs & Monitoring
Check service status:

bash
Copiar
Editar
docker compose ps
View logs:

bash
Copiar
Editar
docker compose logs -f api
docker compose logs -f ai
🛠 Troubleshooting
Port in use → change .env values and rerun:

bash
Copiar
Editar
./scripts/ai_restart.sh
Healthcheck failing → inspect logs:

bash
Copiar
Editar
docker compose logs -f <service_name>
Missing jq/lsof → install manually:

bash
Copiar
Editar
sudo apt-get update -y && sudo apt-get install -y jq lsof
🧹 Cleanup
bash
Copiar
Editar
docker compose down --remove-orphans
docker system prune -f
📜 License
MIT — Free to use and modify