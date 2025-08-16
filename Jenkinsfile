pipeline {
  agent any

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
    DOCKER_IMAGE = "vitalybelos112/spfa"
    DOCKER_TAG = "latest"
    KUBE_NAMESPACE = "spfa"
    HELM_RELEASE = "spfa"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build Image') {
      steps { sh 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .' }
    }

    stage('Push Image') {
      steps {
        sh '''
          echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin
          docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
        '''
      }
    }

    stage('Helm Lint') {
      steps { dir('helm/spfa-chart') { sh 'helm lint .' } }
    }

    stage('Deploy') {
      steps {
        sh '''
          kubectl create namespace ${KUBE_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
          helm upgrade --install ${HELM_RELEASE} helm/spfa-chart \
            --namespace ${KUBE_NAMESPACE} \
            --set image.repository=${DOCKER_IMAGE} \
            --set image.tag=${DOCKER_TAG}
        '''
      }
    }
  }

  post {
    always { sh 'docker logout || true' }
  }
}
