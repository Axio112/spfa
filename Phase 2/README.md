# spfa — Phase 2

Simple Python Flask App with Kubernetes

This phase takes the Flask app from Phase 1 and runs it on Kubernetes.  
It adds scaling, health checks, config, and a scheduled job.

## Files in Phase 2

- spfa-deployment.yaml — runs the app in pods
- spfa-service.yaml — makes the app available in browser
- spfa-hpa.yaml — auto-scales the app
- spfa-configmap.yaml — app settings
- spfa-cronjob.yaml — runs a task every 5 minutes
- README.md — this file

## What This Does

- Runs the app on Kubernetes using Minikube
- Uses a Docker image pushed to GitHub:
  ghcr.io/axio112/spfa:v1
- Works on Intel and Apple Silicon (multi-arch image)
- App runs on port 5000, shown in browser on port 30080

## How to Run

1. Start Kubernetes with Minikube:
   minikube start

2. Add the config:
   kubectl apply -f spfa-configmap.yaml

3. Start the app:
   kubectl apply -f spfa-deployment.yaml

4. Open the app in browser:
   kubectl apply -f spfa-service.yaml  
   minikube service spfa-service

5. Turn on auto-scaling:
   minikube addons enable metrics-server  
   kubectl apply -f spfa-hpa.yaml

6. Start the scheduled task:
   kubectl apply -f spfa-cronjob.yaml

## Example Logs

From the app:

- Running on http://0.0.0.0:5000/
- GET / HTTP/1.1" 200 -

From the CronJob:
Hello from Kubernetes

---

## Notes

- The app can scale up/down if CPU is high
- Health checks are included to restart it if it crashes
- All setup is done using these YAML files
