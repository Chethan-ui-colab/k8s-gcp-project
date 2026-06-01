pipeline {
    agent any

    environment {
        PROJECT_ID       = "k8s-gcp-project-498008"
        REGION           = "us-central1"
        ZONE             = "us-central1-a"
        REGISTRY         = "us-central1-docker.pkg.dev/k8s-gcp-project-498008/k8s-gcp-registry"
        IMAGE_NAME       = "k8s-gcp-app"
        IMAGE_TAG        = "${BUILD_NUMBER}"
        CLUSTER_NAME     = "k8s-gcp-cluster"
    }

    stages {

        stage('Checkout') {
            steps {
                echo '=== Checking out code ==='
                checkout scm
            }
        }

        stage('Run Tests') {
            steps {
                echo '=== Running tests ==='
                dir('app') {
                    sh 'npm install'
                    sh 'npm test'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "=== Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG} ==="
                dir('app') {
                    sh """
                        docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
                                   ${REGISTRY}/${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Push to Artifact Registry') {
            steps {
                echo '=== Pushing image to GCP Artifact Registry ==='
                sh """
                    gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
                    docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${REGISTRY}/${IMAGE_NAME}:latest
                """
            }
        }

        stage('Configure kubectl') {
            steps {
                echo '=== Connecting to GKE cluster ==='
                sh """
                    gcloud container clusters get-credentials ${CLUSTER_NAME} \
                      --zone ${ZONE} \
                      --project ${PROJECT_ID}
                """
            }
        }

        stage('Deploy to GKE') {
            steps {
                echo '=== Deploying to GKE ==='
                sh """
                    # Replace IMAGE_TAG placeholder with actual build number
                    sed -i 's|IMAGE_TAG|${IMAGE_TAG}|g' k8s/deployment.yaml

                    # Apply all manifests
                    kubectl apply -f k8s/namespace.yaml
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl apply -f k8s/ingress.yaml

                    # Wait for rollout
                    kubectl rollout status deployment/k8s-gcp-app \
                      -n production --timeout=180s
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '=== Verifying deployment ==='
                sh """
                    echo "--- Pods ---"
                    kubectl get pods -n production
                    echo "--- Services ---"
                    kubectl get svc -n production
                    echo "--- Ingress ---"
                    kubectl get ingress -n production
                """
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Build #${BUILD_NUMBER} deployed to GKE!"
        }
        failure {
            echo "FAILED: Build #${BUILD_NUMBER} failed. Check logs above."
        }
        always {
            sh 'docker image prune -f || true'
        }
    }
}
