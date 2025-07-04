# SPFA – Phase 2: Kubernetes Orchestration

This phase extends the simple Python Flask app (SPFA) from Phase 1 by deploying it into a fully functional Kubernetes environment.

The app is now scalable, resilient, and includes health monitoring, secure config management, and scheduled automation.

---

## 🧩 Architecture Overview

- **App**: Python Flask, runs on port 5000
- **Image**: `ghcr.io/axio112/spfa:v1`
- **Cluster**: Minikube
- **Kubernetes resources**: Deployment, Service, HPA, ConfigMap, Secret, CronJob

---

## 🚀 How to Deploy

```bash
# Start Minikube
minikube start
minikube addons enable metrics-server

# Apply Kubernetes resources
kubectl apply -f spfa-configmap.yaml
kubectl apply -f spfa-secret.yaml
kubectl apply -f spfa-deployment.yaml
kubectl apply -f spfa-service.yaml
kubectl apply -f spfa-hpa.yaml
kubectl apply -f spfa-cronjob.yaml

# Access the app in browser
minikube service spfa-service


| File                   | Purpose                                               |
| ---------------------- | ----------------------------------------------------- |
| `spfa-deployment.yaml` | Deploys the app with 3 replicas, probes, and env vars |
| `spfa-service.yaml`    | Exposes the app on port 30080 (via NodePort)          |
| `spfa-hpa.yaml`        | Enables Horizontal Pod Autoscaler based on CPU        |
| `spfa-configmap.yaml`  | Sets `FLASK_ENV=production` for the app               |
| `spfa-secret.yaml`     | Securely injects `API_TOKEN=dummy_api_token`          |
| `spfa-cronjob.yaml`    | Runs a Kubernetes job every 5 minutes                 |
| `README.md`            | This file                                             |


| Phase 2 Task                    | How It’s Implemented                                                                                |
| ------------------------------- | --------------------------------------------------------------------------------------------------- |
| **Kubernetes Cluster Setup**    | Minikube is used to create the cluster locally                                                      |
| **Deploy Dockerized App**       | Deployment uses image `ghcr.io/axio112/spfa:v1`                                                     |
| **Deployment & ReplicaSet**     | `spfa-deployment.yaml` defines 3 replicas                                                           |
| **Expose App via Service**      | `spfa-service.yaml` uses `NodePort` on port `30080`                                                 |
| **Horizontal Pod Autoscaler**   | `spfa-hpa.yaml` scales between 3–5 replicas based on CPU                                            |
| **ConfigMap**                   | `spfa-configmap.yaml` sets `FLASK_ENV=production`                                                   |
| **Secret**                      | `spfa-secret.yaml` injects `API_TOKEN` securely                                                     |
| **Liveness & Readiness Probes** | Defined in `spfa-deployment.yaml` to auto-restart crashed pods and delay routing until app is ready |
| **CronJob**                     | `spfa-cronjob.yaml` runs a pod every 5 minutes that prints `Hello from Kubernetes`                  |

🔍 Example Environment Variables in Pod
Run this to verify env injection:

bash
Copy
Edit
kubectl exec <pod> -- printenv | grep -E 'FLASK_ENV|API_TOKEN'
Expected output:

ini
Copy
Edit
FLASK_ENV=production
API_TOKEN=dummy_api_token
🧪 Health Check Probes
Liveness probe:

Ensures the container is restarted if it crashes

Readiness probe:

Ensures the app is only exposed when ready to serve traffic

Simulate a crash:

bash
Copy
Edit
kubectl exec <pod> -- kill 1
The pod should auto-restart.

🗓️ CronJob Example Output
Check logs of the latest job:

bash
Copy
Edit
kubectl get jobs
kubectl logs <cronjob-pod-name>
Expected:

csharp
Copy
Edit
Hello from Kubernetes
🧼 To Tear Down Everything
bash
Copy
Edit
kubectl delete -f spfa-deployment.yaml
kubectl delete -f spfa-service.yaml
kubectl delete -f spfa-hpa.yaml
kubectl delete -f spfa-configmap.yaml
kubectl delete -f spfa-secret.yaml
kubectl delete -f spfa-cronjob.yaml
kubectl delete jobs --all
🧠 Notes
Designed to run on both Intel and Apple Silicon (multi-arch Docker image)

No external dependencies beyond kubectl and minikube

Fully reproducible from scratch using included YAML files
```
