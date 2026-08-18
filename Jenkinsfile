pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gantabujji/myapp'
        IMAGE_TAG  = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'python3 -m pip install --break-system-packages flask pytest'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'python3 -m pytest'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f k8s/configmap.yaml
                    kubectl apply -f k8s/secret.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl apply -f k8s/deployment.yaml

                    kubectl set image deployment/myapp-deployment \
                      myapp=${IMAGE_NAME}:${IMAGE_TAG} \
                      -n production
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    kubectl rollout status deployment/myapp-deployment -n production --timeout=180s
                    kubectl get pods -n production
                    kubectl get svc -n production
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD pipeline completed successfully.'
        }

        failure {
            echo 'CI/CD pipeline failed. Check the stage logs.'
        }
    }
}