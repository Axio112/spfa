# SPFA – Phase 2: Kubernetes Orchestration

This phase extends the simple Python Flask app (SPFA) by deploying it in a Kubernetes environment using Minikube.  
The application is now scalable, resilient, and includes health checks, secure configuration, and scheduled automation.

---

## Architecture

- App: Python Flask (port 5000)
- Image: ghcr.io/axio112/spfa:v1 (multi-arch)
- Cluster: Minikube (local)
- Kubernetes Resources: Deployment, Service, HPA, ConfigMap, Secret, CronJob

---

## How to Deploy

```bash
minikube start
minikube addons enable metrics-server

kubectl apply -f spfa-configmap.yaml
kubectl apply -f spfa-secret.yaml
kubectl apply -f spfa-deployment.yaml
kubectl apply -f spfa-service.yaml
kubectl apply -f spfa-hpa.yaml
kubectl apply -f spfa-cronjob.yaml

minikube service spfa-service
```

---

## File Overview

| File                   | Description                                              |
|------------------------|----------------------------------------------------------|
| spfa-deployment.yaml   | Deploys the app (3 replicas) with env vars and probes    |
| spfa-service.yaml      | Exposes the app externally on NodePort (port 30080)      |
| spfa-hpa.yaml          | Horizontal Pod Autoscaler based on CPU                   |
| spfa-configmap.yaml    | Injects FLASK_ENV=production                             |
| spfa-secret.yaml       | Injects API_TOKEN=dummy_api_token securely               |
| spfa-cronjob.yaml      | Scheduled job running every 5 minutes                    |
| README.md              | This documentation                                       |

---

## Task Implementation Mapping

| Task                        | Implementation Detail                                                    |
|-----------------------------|---------------------------------------------------------------------------|
| Kubernetes Cluster Setup    | Minikube                                                                  |
| Dockerized App Deployment   | Image ghcr.io/axio112/spfa:v1 in spfa-deployment.yaml                     |
| Deployment & ReplicaSet     | 3 replicas managed by Kubernetes                                          |
| Expose App via Service      | spfa-service.yaml using NodePort                                          |
| Horizontal Pod Autoscaler   | spfa-hpa.yaml (CPU-based autoscaling)                                    |
| ConfigMap                   | Injects FLASK_ENV                                                         |
| Secret                      | Injects API_TOKEN                                                         |
| Liveness & Readiness Probes| Restart on crash, route only when app is ready                            |
| CronJob                     | Prints "Hello from Kubernetes" every 5 minutes                            |

---

## Environment Check

```bash
kubectl exec <pod> -- printenv | grep -E 'FLASK_ENV|API_TOKEN'
```

Expected output:

```
FLASK_ENV=production
API_TOKEN=dummy_api_token
```

---

## Health Check Probes

Liveness Probe: Auto-restarts crashed containers  
Readiness Probe: Delays routing until app is ready

Simulate a crash:

```bash
kubectl exec <pod> -- kill 1
```

The pod should restart automatically.

---

## CronJob Output

```bash
kubectl get jobs
kubectl logs <cronjob-pod>
```

Expected output:

```
Hello from Kubernetes
```

---

## Teardown Commands

```bash
kubectl delete -f spfa-deployment.yaml
kubectl delete -f spfa-service.yaml
kubectl delete -f spfa-hpa.yaml
kubectl delete -f spfa-configmap.yaml
kubectl delete -f spfa-secret.yaml
kubectl delete -f spfa-cronjob.yaml
kubectl delete jobs --all
```

---

## Notes

- Compatible with Intel and Apple Silicon (multi-arch image)
- Minimal setup required: kubectl and minikube
- Fully reproducible using included YAML files
