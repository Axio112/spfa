pipeline {
  agent any
  options { timestamps() }

  environment {
    KCFG            = 'C:\\Users\\axio\\.kube\\config'
    DOCKER_IMAGE    = 'vitalybelos112/spfa'
    COMMIT_SHORT    = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"
    RELEASE_NAME    = 'spfa'          // Helm release
    CHART_DIR       = 'helm'          // Local chart dir in repo
    DEPLOYMENT_NAME = 'spfa'          // <<< FIX: actual k8s Deployment name
    SERVICE_NAME    = 'spfa-service'  // in-cluster service for smoke test
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('K8s Preflight') {
      steps {
        bat """
          set KUBECONFIG=%KCFG%
          kubectl cluster-info || (echo ERROR: Minikube is not running & exit /b 1)
        """
      }
    }

    stage('Path check') {
      steps {
        bat """
          if not exist "Dockerfile" (echo Missing Dockerfile & exit /b 1)
          if not exist "%CHART_DIR%\\Chart.yaml" (echo Missing Chart.yaml & exit /b 1)
        """
      }
    }

    stage('Lint & Dry-Run') {
      steps {
        bat """
          set KUBECONFIG=%KCFG%
          helm lint %CHART_DIR%
          helm template %RELEASE_NAME% %CHART_DIR% | kubectl apply --dry-run=client -f -
        """
      }
    }

    stage('Build Image') {
      steps {
        bat 'docker build -t %DOCKER_IMAGE%:%COMMIT_SHORT% -t %DOCKER_IMAGE%:latest .'
      }
    }

    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat """
            echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
            docker push %DOCKER_IMAGE%:%COMMIT_SHORT%
            docker push %DOCKER_IMAGE%:latest
          """
        }
      }
    }

    stage('Deploy (Helm, atomic)') {
      steps {
        bat """
          set KUBECONFIG=%KCFG%
          kubectl get ns default || kubectl create ns default
          helm upgrade --install %RELEASE_NAME% %CHART_DIR% ^
            --namespace default --create-namespace ^
            --set image.repository=%DOCKER_IMAGE% ^
            --set image.tag=%COMMIT_SHORT% ^
            --wait --atomic --timeout 180s
          rem FIX: wait on the right deployment name
          kubectl rollout status deployment/%DEPLOYMENT_NAME% -n default --timeout=180s
        """
      }
    }

    stage('Smoke Test (in-cluster)') {
      steps {
        bat """
          set KUBECONFIG=%KCFG%
          kubectl run curl --rm -i --restart=Never -n default --image=curlimages/curl:8.9.1 -- ^
            sh -c "curl -sS http://%SERVICE_NAME%:5000 | head -n1"
        """
      }
    }
  }

  post {
    always {
      bat 'docker logout || ver >NUL'
    }
  }
}
