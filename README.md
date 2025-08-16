# SPFA

Minimal Python Flask “Hello, World!” app, containerized with Docker and orchestrated on Kubernetes.

---

## Prerequisites

- Docker Desktop (Linux containers)
- Docker Hub account (`vitalybelos112`)
- Minikube & kubectl

---

## Phase 1: Docker

1. **Build & tag**
   ```bash
   cd spfa
   docker login                            # enter Docker Hub credentials
   docker build -t vitalybelos112/spfa:latest .
   ```
2. **Push to Docker Hub**
   ```bash
   docker push vitalybelos112/spfa:latest
   ```
3. **Run locally via Compose**
   ```bash
   docker-compose up --build
   ```
4. **Or without Compose**
   ```bash
   docker run -p 5000:5000 vitalybelos112/spfa:latest
   ```
5. **Verify**  
   Visit http://localhost:5000 → returns **Hello, World!**

---

## Phase 2: Kubernetes

1. **Start Minikube & enable metrics**
   ```bash
   minikube start
   minikube addons enable metrics-server
   ```
2. **Deploy manifests**
   ```bash
   kubectl apply -f k8s/configmap.yaml
   kubectl apply -f k8s/secret.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/hpa.yaml
   kubectl apply -f k8s/cronjob.yaml
   ```
3. **Access service**
   ```bash
   minikube service spfa-service
   ```
4. **Test health & autoscale**
   ```bash
   kubectl get pods         # check readiness/liveness
   kubectl get hpa          # view CPU-based scaling
   kubectl delete pod -l app=spfa   # simulate crash, pods restart
   ```
5. **Check CronJob**
   ```bash
   kubectl get jobs
   kubectl logs job/$(kubectl get jobs -o jsonpath='{.items[-1].metadata.name}')
   # Expect “Hello from Kubernetes”
   ```
6. **Tear down**
   ```bash
   kubectl delete -f k8s
   kubectl delete jobs --all
   minikube stop
   ```

---

## File Overview

```
spfa/
├─ app.py
├─ requirements.txt
├─ Dockerfile
├─ docker-compose.yml
├─ README.md
└─ k8s/
   ├─ configmap.yaml
   ├─ secret.yaml
   ├─ deployment.yaml
   ├─ service.yaml
   ├─ hpa.yaml
   └─ cronjob.yaml
```
