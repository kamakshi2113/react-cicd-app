
pipeline {
  agent any

  environment {
    DOCKER_USER  = 'zenparker'
    IMAGE_NAME   = 'react-cicd-app'
    IMAGE_TAG    = "${BUILD_NUMBER}"
    AWS_REGION   = 'ap-south-1'
    CLUSTER_NAME = 'react-cicd-eks'
    SCANNER_HOME = tool 'sonar-scanner'
  }

  stages {
    stage('Clean Workspace') {
      steps { deleteDir() }
    }
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Install Dependencies') {
      steps { sh 'npm ci' }
    }
    stage('Unit Test') {
      steps { sh 'npm test' }
    }
    stage('Build') {
      steps { sh 'npm run build' }
    }
    stage('SonarQube Scan') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh "${SCANNER_HOME}/bin/sonar-scanner"
        }
      }
    }
    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
    stage('Docker Build') {
      steps {
        sh "docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} -t ${DOCKER_USER}/${IMAGE_NAME}:latest ."
      }
    }
    stage('Trivy Scan') {
      steps {
        sh "trivy image --no-progress --severity HIGH,CRITICAL --exit-code 0 ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
      }
    }
    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh 'echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin'
          sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
          sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:latest"
        }
      }
    }
    stage('Connect to EKS') {
      steps {
        sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        sh "sed -i 's|image: .*|image: ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}|' k8s/deployment.yaml"
        sh 'kubectl apply -f k8s/'
      }
    }
    stage('Verify Rollout') {
      steps {
        sh 'kubectl rollout status deployment/react-app --timeout=180s'
        sh 'kubectl get pods,svc -o wide'
      }
    }
    stage('Health Check') {
      steps {
        sh '''
          for i in $(seq 1 30); do
            HOST=$(kubectl get svc react-app-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
            if [ -n "$HOST" ] && curl -sf -o /dev/null "http://$HOST"; then
              echo "App is live at http://$HOST"
              exit 0
            fi
            echo "Waiting for load balancer... ($i/30)"
            sleep 10
          done
          echo "Health check failed"
          exit 1
        '''
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
    }
  }
}
