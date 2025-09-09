🛡️ Zero Trust AI Observability Lab — Cloud-Native DevSecOps
Laboratorio integral para desplegar un stack de observabilidad con enfoque Zero Trust, utilizando un único script (star.sh). Este entorno incluye métricas, logs, trazas distribuidas, healthchecks, escaneo de seguridad y proxy seguro con TLS + BasicAuth.

<p align="left"> <img alt="License" src="https://img.shields.io/badge/license-MIT-black"> <img alt="Docker" src="https://img.shields.io/badge/docker-compose-blue"> <img alt="ZeroTrust" src="https://img.shields.io/badge/security-zero%20trust-important"> <img alt="Observability" src="https://img.shields.io/badge/stack-grafana%2Fprometheus%2Floki%2Ftempo-success"> </p>

📦 Componentes Principales
FastAPI App instrumentada con OpenTelemetry (:8000)

Nginx Proxy con TLS, BasicAuth y rate-limit (:8443)

Prometheus para métricas

Loki + Promtail para logs

Tempo para trazas distribuidas

Grafana como panel de visualización unificado

🧭 Arquitectura del Sistema
mermaid
flowchart LR
  user[👤 Cliente/Dev] -->|HTTPS + Auth| nginx[(🔐 Nginx Proxy)]
  nginx --> app[(⚙️ FastAPI App)]
  app -->|OTLP| otel[(📡 OTEL Collector)]
  otel --> prometheus[(📊 Prometheus)]
  otel --> loki[(📜 Loki)]
  otel --> tempo[(🧵 Tempo)]
  prometheus --> grafana[(📈 Grafana)]
  loki --> grafana
  tempo --> grafana
✨ Funcionalidades Clave
🔧 Setup automatizado con ./star.sh up

🔐 TLS + BasicAuth preconfigurados

📊 Dashboards listos vía provisioning

📈 Logs, métricas y trazas conectadas

🛡️ Escaneo de seguridad con Trivy (./star.sh scan)

🧹 Clean-up idempotente (./star.sh clean)

📁 Estructura del Proyecto
Código
.
├── star.sh              # Script maestro
├── docker-compose.yml   # Orquestación de servicios
├── prometheus.yml       # Configuración de Prometheus
├── otel-collector.yaml  # Configuración de OTEL Collector
├── nginx.conf           # Proxy seguro con TLS + Auth
├── certs/               # Certificados TLS self-signed
├── app/                 # FastAPI instrumentada
├── provisioning/        # Dashboards y datasources Grafana
└── README.md
✅ Requisitos Previos
Docker + Docker Compose

OpenSSL

Linux / macOS / WSL2

🚀 Quick Start
bash
git clone https://github.com/Emanuelgm1998/zero-trust-ai-observability-lab.git
cd zero-trust-ai-observability-lab
chmod +x star.sh
./star.sh up
./star.sh status
for i in {1..10}; do curl -k -u admin:admin https://localhost:8443/; done
🌐 Endpoints del Sistema
Servicio	URL	Credenciales
Grafana	localhost:3000	admin / admin
Prometheus	localhost:9090	—
Loki API	localhost:3100	—
Tempo	localhost:3200	—
App (HTTPS)	localhost:8443	admin / admin
🔍 Verificación Post-Deploy
bash
./star.sh logs
curl -k -u admin:admin https://localhost:8443/healthz
# → {"status":"ok"}
🔐 Enfoque Zero Trust & DevSecOps
✅ TLS obligatorio (certificados self-signed)

✅ Autenticación básica (BasicAuth)

✅ Rate-limit configurado en Nginx

✅ Escaneo de seguridad con Trivy

✅ Observabilidad 360°: métricas, logs y trazas

👨‍💻 Autor
Emanuel González Michea Cloud Architect · SysOps · DevSecOps · Observability Specialist 📎 GitHub · 🌐 LinkedIn

---

👉 Este README está **listo para producción** en GitHub: profesional, con badges, mapa conceptual en `mermaid`, secciones ordenadas y enfoque Cloud/DevSecOps.  

¿Quieres que también te arme **un dashboard JSON preconfigurado para Grafana** (lo subes en `provisioning/dashboards`) de modo que al abrir Grafana ya aparezcan métricas, logs y trazas sin configurar nada?
```
