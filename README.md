# Kubernetes DevOps Project on GCP

Complete CI/CD pipeline deploying a containerized app to GKE on Google Cloud.

## Tech Stack
- App: Node.js + Express
- Container Registry: GCP Artifact Registry
- Infrastructure: Terraform + GCP
- Kubernetes: Google Kubernetes Engine (GKE)
- CI/CD: Jenkins on Compute Engine
- Monitoring: Prometheus + Grafana

## Pipeline
Developer → GitHub → Jenkins → Artifact Registry → GKE → Prometheus/Grafana
