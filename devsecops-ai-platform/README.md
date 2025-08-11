# 🌐 DevSecOps AI Platform

A **Cloud-Native** platform built with **DevSecOps**, **Zero Trust**, and **AI-powered observability**, designed to detect anomalies in real time with modular architecture and full automation.

![Docker](https://img.shields.io/badge/docker-ready-blue)
![CI/CD](https://img.shields.io/badge/CI%2FCD-enabled-green)
![Zero Trust](https://img.shields.io/badge/security-zero--trust-critical)
![AI Observability](https://img.shields.io/badge/AI-observability-purple)

---

## ⚙️ Key Features

- **Secure API in Node.js** (Express + Helmet)
- **AI microservice in Flask (Python)** using Isolation Forest or fallback with NumPy
- **Modular containerized architecture** ready for **Docker Compose** and **GitHub Codespaces**
- Automation scripts for setup, lifecycle management, and endpoint verification
- CI/CD-ready configuration for seamless integration

---

## 🚀 Technologies

- **Docker & Docker Compose** – Service orchestration
- **Node.js** (Express, Helmet, CORS) – API gateway and business logic
- **Python** (Flask, scikit-learn, NumPy) – AI anomaly detection engine
- **Bash Scripts** – Deployment and verification automation

---

## 📁 Project Structure

devsecops-ai-platform/ ├── api/ # REST API (Node.js) │ ├── server.js │ ├── package.json │ └── Dockerfile │ ├── ai/ # AI Service (Flask + Python) │ ├── anomaly_detector.py │ └── Dockerfile │ ├── docs/ # Technical documentation │ ├── bootstrap_local.sh # Full local setup ├── start-local.sh # Start API and AI services ├── stop-local.sh # Stop services ├── ai_restart.sh # Restart AI service ├── verify.sh # Endpoint verification ├── docker-compose.yml # Service orchestration └── README.md


---

## 🧪 API Endpoints

**Node.js API**
- `GET /status` → API health check
- `POST /detect` → Proxy request to AI service for anomaly detection

**Flask AI Service**
- `GET /health` → AI service health check
- `POST /detect` → Direct anomaly detection

Example usage:

```bash
curl -X POST http://localhost:5000/detect \
  -H "Content-Type: application/json" \
  -d '{"data":[1,2,3,100]}'


Security
Helmet for secure HTTP headers

CORS configured for origin control

Zero Trust enforced via service isolation

Automatic service restarts for resilience

Structured logs with anomaly analysis metadata

Quick Deployment

chmod +x bootstrap_local.sh
./bootstrap_local.sh
Launches the full platform locally in seconds—ideal for testing, demos, or CI/CD pipelines.

Project Status
✅ Functional ✅ Documented ✅ Modular ✅ Scalable ✅ Recruiter-ready

This project showcases senior-level execution in cloud-native architecture, DevSecOps automation, and AI-driven observability. Perfect for technical portfolios targeting international roles.

This project showcases senior-level execution in cloud-native architecture, DevSecOps automation, and AI-driven observability. Perfect for technical portfolios targeting international roles.