pipeline {
  agent any
  options { timestamps() }
  environment {
    DOCKER_IMAGE  = 'vitalybelos112/spfa'
    RELEASE_NAME  = 'spfa'
    NAMESPACE     = 'default'
    IMAGE_TAG     = "${env.GIT_COMMIT ? env.GIT_COMMIT.take(7) : env.BUILD_NUMBER}"
    KCFG          = 'C:\\Users\\axio\\.kube\\config'
    // OCI Helm chart location + version (must match what you pushed)
    CHART_REF     = 'oci://registry-1.docker.io/vitalybelos112/spfa'
    CHART_VERSION = '0.1.1'
  }

  stages {
    stage('Checkout'){ steps { checkout scm } }

    stage('K8s Preflight'){
      steps {
        bat '''
          set KUBECONFIG=%KCFG%
          kubectl cluster-info || (echo ERROR: Minikube is not running & exit /b 1)
        '''
      }
    }

    // Optional sanity when repo also has a local helm/ (won’t block OCI deploy)
    stage('Lint & Dry-Run (local chart)'){
      when { expression { return fileExists('helm/Chart.yaml') } }
      steps {
        bat '''
          set KUBECONFIG=%KCFG%
          helm lint helm
          helm template %RELEASE_NAME% helm | kubectl apply --dry-run=client -f -
        '''
      }
    }

    stage('Build Image'){
      steps { bat 'docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% -t %DOCKER_IMAGE%:latest .' }
    }

    stage('Push Image'){
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat '''
            echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
            docker push %DOCKER_IMAGE%:%IMAGE_TAG%
            docker push %DOCKER_IMAGE%:latest
          '''
        }
      }
    }

    stage('Deploy (OCI Helm, atomic)'){
      steps {
        bat '''
          set KUBECONFIG=%KCFG%
          kubectl get ns %NAMESPACE% || kubectl create ns %NAMESPACE%
          helm upgrade --install %RELEASE_NAME% %CHART_REF% ^
            --namespace %NAMESPACE% --create-namespace ^
            --version %CHART_VERSION% ^
            --set image.repository=%DOCKER_IMAGE% ^
            --set image.tag=%IMAGE_TAG% ^
            --set fullnameOverride=%RELEASE_NAME% ^
            --wait --atomic --timeout 180s
          kubectl rollout status deployment/%RELEASE_NAME% -n %NAMESPACE% --timeout=180s
        '''
      }
    }

    stage('Smoke Test (in-cluster)'){
      steps {
        bat '''
          set KUBECONFIG=%KCFG%
          kubectl run curl --rm -i --restart=Never -n %NAMESPACE% --image=curlimages/curl:8.9.1 -- ^
            sh -c "curl -sS http://spfa-service:5000 | head -n1"
        '''
      }
    }
  }

  post { always { bat 'docker logout || ver >NUL' } }
}
