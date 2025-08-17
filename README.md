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

## # SPFA — Phase 3

Deploy the Flask app to Kubernetes using the published **Helm chart on Docker Hub (OCI)**.  
This guide is device‑agnostic: no local paths are required.

---

## Prerequisites

You need any Kubernetes cluster. For local testing we recommend **Minikube**.

- Kubernetes cluster (e.g., Minikube, kind, k3s, or a managed cluster)
- `kubectl` v1.20+
- `Helm` v3.8+ (OCI support is enabled by default in modern Helm)
- Optional (recommended for autoscaling): **metrics-server** addon

> The app image is **docker.io/vitalybelos112/spfa:latest**.  
> The Helm chart is **oci://registry-1.docker.io/vitalybelos112/spfa** (version **0.1.1**).

---

## 1) Start a local cluster (optional — if you already have one, skip)

### Windows PowerShell
```powershell
minikube start
minikube addons enable metrics-server 2>$null  # optional, for HPA metrics
```

### macOS/Linux (bash)
```bash
minikube start
minikube addons enable metrics-server 2>/dev/null || true  # optional
```

---

## 2) Install (or upgrade) the app with Helm (OCI)

### Windows PowerShell
```powershell
helm upgrade --install spfa oci://registry-1.docker.io/vitalybelos112/spfa `
  --version 0.1.1 `
  --set image.repository=vitalybelos112/spfa `
  --set image.tag=latest `
  --wait --atomic --timeout 180s
```

### macOS/Linux (bash)
```bash
helm upgrade --install spfa oci://registry-1.docker.io/vitalybelos112/spfa   --version 0.1.1   --set image.repository=vitalybelos112/spfa   --set image.tag=latest   --wait --atomic --timeout 180s
```

**What gets created**
- Deployment: `spfa`
- Service: `spfa-service` (ClusterIP on port 5000)
- HPA: `spfa` (targets CPU 50%, min 1, max 3)
- CronJob: `spfa` (every 2 minutes, prints a message)
- ConfigMap: `spfa-config`
- Secret: `spfa-secret`

---

## 3) Verify the deployment

### a) Rollout
```bash
kubectl rollout status deployment/spfa --timeout=180s
```

### b) In‑cluster smoke test (works on any cluster)
```bash
kubectl run curl --rm -i --restart=Never --image=curlimages/curl:8.9.1 --   sh -c "curl -sS http://spfa-service:5000 | head -n1"
# Expect: Hello, World!
```

### c) From your machine (Minikube only)
**Windows PowerShell**
```powershell
$URL = (minikube service spfa-service --url | Select-Object -First 1)
Invoke-WebRequest $URL -UseBasicParsing | Select-Object -Expand Content
```

**macOS/Linux (bash)**
```bash
URL=$(minikube service spfa-service --url | head -n1)
curl -sS "$URL"
```

---

## 4) Upgrade

To deploy a **new app image** (e.g., a new tag):
```bash
helm upgrade spfa oci://registry-1.docker.io/vitalybelos112/spfa   --version 0.1.1   --set image.repository=vitalybelos112/spfa   --set image.tag=<newTag>   --wait --atomic --timeout 180s
```

To upgrade to a **new chart version**, bump `--version` accordingly.

---

## 5) Rollback

```bash
helm history spfa
helm rollback spfa <REV>   # e.g., helm rollback spfa 1
```

---

## 6) Uninstall

```bash
helm uninstall spfa
```

---

## References

- Chart (OCI): `oci://registry-1.docker.io/vitalybelos112/spfa` (version `0.1.1`)
- App Image: `docker.io/vitalybelos112/spfa:latest`
- Source: https://github.com/Axio112/spfa


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
