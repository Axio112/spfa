pipeline {
  agent any
  options { timestamps() }

  environment {
    // Local project folder (Dockerfile, app.py, helm/)
    PROJECT_DIR  = 'D:\\AXIOMA\\spfa-complete'

    // Container registry
    DOCKER_IMAGE = 'vitalybelos112/spfa'   // change if needed

    // Helm release/chart
    CHART_DIR    = 'helm'
    RELEASE_NAME = 'spfa'
    NAMESPACE    = 'default'               // set 'spfa' if you want a dedicated namespace

    // Tag: prefer Git SHA if available, otherwise BUILD_NUMBER
    IMAGE_TAG    = "${env.GIT_COMMIT ? env.GIT_COMMIT.take(7) : env.BUILD_NUMBER}"

    // Live kubeconfig (Option A)
    KCFG         = 'C:\\Users\\axio\\.kube\\config'
  }

  stages {

    stage('Path check') {
      steps {
        bat '''
          if not exist "%PROJECT_DIR%\\Dockerfile" (
            echo ERROR: Missing Dockerfile at %PROJECT_DIR% & exit /b 1
          )
          if not exist "%PROJECT_DIR%\\%CHART_DIR%\\Chart.yaml" (
            echo ERROR: Missing helm\\Chart.yaml under %PROJECT_DIR% & exit /b 1
          )
        '''
      }
    }

    stage('Chart Lint & Dry-Run') {
      steps {
        dir(env.PROJECT_DIR) {
          bat """
            set KUBECONFIG=%KCFG%
            helm lint %CHART_DIR%
            helm template %RELEASE_NAME% %CHART_DIR% | kubectl apply --dry-run=client -f -
          """
        }
      }
    }

    stage('Build Image') {
      steps {
        dir(env.PROJECT_DIR) {
          bat "docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% -t %DOCKER_IMAGE%:latest ."
        }
      }
    }

    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat """
            echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
            docker push %DOCKER_IMAGE%:%IMAGE_TAG%
            docker push %DOCKER_IMAGE%:latest
          """
        }
      }
    }

    stage('Deploy (Helm, atomic)') {
      steps {
        dir(env.PROJECT_DIR) {
          bat """
            set KUBECONFIG=%KCFG%
            kubectl get ns %NAMESPACE% || kubectl create ns %NAMESPACE%
            helm upgrade --install %RELEASE_NAME% %CHART_DIR% ^
              --namespace %NAMESPACE% --create-namespace ^
              --set image.repository=%DOCKER_IMAGE% ^
              --set image.tag=%IMAGE_TAG% ^
              --wait --atomic --timeout 180s
            kubectl rollout status deployment/%RELEASE_NAME%-spfa -n %NAMESPACE% --timeout=180s
          """
        }
      }
    }

    stage('Smoke Test (in cluster)') {
      steps {
        bat """
          set KUBECONFIG=%KCFG%
          kubectl run curl --rm -i --restart=Never -n %NAMESPACE% --image=curlimages/curl:8.9.1 -- ^
            sh -c "curl -sS http://spfa-service:5000 | head -n1"
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
