cat > README.md <<'EOF'
# Cloud-Native DevSecOps Platform · Zero Trust + AI Observability

> Plataforma demo desplegada en **GitHub Codespaces** sobre **Kubernetes (k3d)**, con **Istio**, **Prometheus**, **Grafana** y logs con **Loki**.  
> Incluye microservicios **API** y **Frontend** con Zero Trust “básico” y endpoints de salud listos para monitoreo.

![Badges](https://img.shields.io/badge/Kubernetes-k3d-326CE5?logo=kubernetes&logoColor=white)
![Badges](https://img.shields.io/badge/ServiceMesh-Istio-466BB0?logo=istio&logoColor=white)
![Badges](https://img.shields.io/badge/Observability-Prometheus%20%7C%20Grafana%20%7C%20Loki-orange)
![Badges](https://img.shields.io/badge/DevSecOps-Zero%20Trust-success)

---

## ✨ Qué incluye
- **Cluster local (k3d)** en Codespaces.
- **Istio** instalado (gateway/ingress).
- **API Service (Node/Express)** con `GET /` y `GET /health`.
- **Frontend Service (Node/Express)** mínimo.
- **Observabilidad**: `kube-prometheus-stack` (**Prometheus + Grafana**) y **Loki** para logs.
- Scripts de **verificación** rápida (curl y kubectl).

---

## 🏗️ Arquitectura (Mermaid)
> GitHub renderiza diagramas Mermaid directamente en el README.

```mermaid
flowchart LR
  subgraph Client
    Browser[Usuario / Navegador]
  end

  subgraph Codespaces["GitHub Codespaces (Dev)"]
    subgraph K8s["k3d Kubernetes Cluster"]
      istio[Istio Ingress/Gateway]
      api[API Service (Node/Express)]
      fe[Frontend Service (Node/Express)]
      subgraph Observability["Observabilidad"]
        prom[Prometheus]
        graf[Grafana]
        loki[Loki (logs)]
      end
    end
  end

  Browser -->|HTTPS (túnel)| istio
  istio --> fe
  istio --> api
  api --> prom
  fe  --> prom
  api --> loki
  fe  --> loki
  graf --> Browser
