# SPFA

Minimal Python Flask “Hello, World!” app, containerized with Docker and orchestrated on Kubernetes.

---

## Prerequisites

- Docker Desktop (Linux containers)
- Docker Hub account (`vitalybelos112`)
- Minikube & kubectl
- **Phase 3:** Helm v3, Jenkins LTS (Java 17/21)

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

## Phase 3: Helm & Jenkins CI/CD

### A) Helm

```
helm/
├─ Chart.yaml
├─ values.yaml
└─ templates/ (deployment, service, hpa, secret, configmap, cronjob)
```

Deploy with Helm:
```bash
helm lint ./helm
helm template spfa ./helm | kubectl apply --dry-run=client -f -
helm upgrade --install spfa ./helm \
  --set image.repository=vitalybelos112/spfa \
  --set image.tag=latest
kubectl rollout status deployment/spfa-spfa --timeout=180s
kubectl port-forward deploy/spfa-spfa 5000:5000
curl http://localhost:5000    # → Hello, World!
```

### B) Git (branch + PR)

```bash
git checkout -b feature/phase3
# ...edit files...
git add .
git commit -m "Phase 3: Helm + Jenkins pipeline"
git push -u origin feature/phase3
# open PR → review → merge to main
```

### C) Jenkins Pipeline

- The repo contains a `Jenkinsfile` that:
  1) lints and dry-runs the Helm chart,  
  2) builds & tags the image (`<repo>:<shortSHA>` and `latest`),  
  3) pushes to Docker Hub,  
  4) deploys with `helm upgrade --install` (atomic/wait),  
  5) runs an in-cluster smoke test (`curlimages/curl` → `spfa-service:5000`).

**Minimal setup in Jenkins**
- Add Docker Hub credentials:
  - **Kind:** Username with password
  - **ID:** `dockerhub-creds`
- Create a **Pipeline** job → **Pipeline script from SCM** → point at this repo.
- Trigger: **manual** (“Build Now”).

---

## File Overview

```
spfa/
├─ app.py
├─ requirements.txt
├─ Dockerfile
├─ docker-compose.yml
├─ README.md
├─ k8s/
│  ├─ configmap.yaml
│  ├─ secret.yaml
│  ├─ deployment.yaml
│  ├─ service.yaml
│  ├─ hpa.yaml
│  └─ cronjob.yaml
├─ helm/
│  ├─ Chart.yaml
│  ├─ values.yaml
│  └─ templates/
└─ Jenkinsfile
```
