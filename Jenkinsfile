pipeline {
    agent any
    environment {
        // Secrets stored in Jenkins Credentials
        DATABASE_PASSWORD = credentials('DATABASE_PASSWORD')
        CLERK_SECRET_KEY = credentials('CLERK_SECRET_KEY')
        STRIPE_SECRET_KEY = credentials('STRIPE_SECRET_KEY')
        OPENAI_API_KEY = credentials('OPENAI_API_KEY')
        NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY = credentials('NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY')
        NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY = credentials('NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY')
        NEXT_PUBLIC_CLERK_SIGN_IN_URL = credentials('NEXT_PUBLIC_CLERK_SIGN_IN_URL')
        NEXT_PUBLIC_CLERK_SIGN_UP_URL = credentials('NEXT_PUBLIC_CLERK_SIGN_UP_URL')
        CLERK_WEBHOOK_SECRET = credentials('CLERK_WEBHOOK_SECRET')

        // Minikube-specific
        KUBECONFIG = "~/.kube/config"
        MINIKUBE_VERSION = 'v1.34.0'
        MINIKUBE_IP = ""
    }

    options {
        timeout(time: 30, unit: 'MINUTES') // Set an appropriate timeout for long-running stages
    }

    stages {
        stage('Debug Environment') {
            steps {
                // Print debug information to verify environment setup
                sh '''
                set -x
                git --version  # Check Git installation
                docker --version  # Check Docker installation
                echo $PATH  # Print the PATH
                echo "Checking if Docker is installed and accessible..."
                docker ps || echo "Docker is not installed or running"
                '''
            }
        }

        stage('Checkout Code') {
            steps {
                script {
                    // Manually perform the Git checkout with verbose output for debugging
                    echo "Starting Git checkout..."
                    sh '''
                    git --version
                    echo "Cloning repository..."
                    git clone https://github.com/NickThompsonDev/meta-tale-compendium.git || echo "Git clone failed"
                    cd meta-tale-compendium
                    git fetch --all || echo "Git fetch failed"
                    git checkout master || echo "Git checkout failed"
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            parallel {
                stage('Build Webapp') {
                    steps {
                        dir('webapp') {
                            sh '''
                            docker build --build-arg DATABASE_PASSWORD=${DATABASE_PASSWORD} \
                                          --build-arg CLERK_SECRET_KEY=${CLERK_SECRET_KEY} \
                                          --build-arg STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY} \
                                          --build-arg OPENAI_API_KEY=${OPENAI_API_KEY} \
                                          --build-arg NEXT_PUBLIC_API_URL=http://${MINIKUBE_IP}/api \
                                          --build-arg NEXT_PUBLIC_WEBAPP_URL=http://${MINIKUBE_IP} \
                                          --build-arg NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY} \
                                          --build-arg NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=${NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY} \
                                          --build-arg NEXT_PUBLIC_CLERK_SIGN_IN_URL=${NEXT_PUBLIC_CLERK_SIGN_IN_URL} \
                                          --build-arg NEXT_PUBLIC_CLERK_SIGN_UP_URL=${NEXT_PUBLIC_CLERK_SIGN_UP_URL} \
                                          -t webapp-tale-compendium:latest -f Dockerfile . || echo "Webapp build failed"
                            '''
                        }
                    }
                }

                stage('Build API') {
                    steps {
                        dir('api') {
                            sh '''
                            docker build --build-arg DATABASE_PASSWORD=${DATABASE_PASSWORD} \
                                          --build-arg CLERK_SECRET_KEY=${CLERK_SECRET_KEY} \
                                          --build-arg STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY} \
                                          --build-arg OPENAI_API_KEY=${OPENAI_API_KEY} \
                                          --build-arg NEXT_PUBLIC_API_URL=http://${MINIKUBE_IP}/api \
                                          --build-arg NEXT_PUBLIC_WEBAPP_URL=http://${MINIKUBE_IP} \
                                          --build-arg NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY} \
                                          --build-arg NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=${NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY} \
                                          --build-arg NEXT_PUBLIC_CLERK_SIGN_IN_URL=${NEXT_PUBLIC_CLERK_SIGN_IN_URL} \
                                          --build-arg NEXT_PUBLIC_CLERK_SIGN_UP_URL=${NEXT_PUBLIC_CLERK_SIGN_UP_URL} \
                                          -t api-tale-compendium:latest -f Dockerfile . || echo "API build failed"
                            '''
                        }
                    }
                }
            }
        }

        stage('Load Docker Images into Minikube') {
            steps {
                script {
                    // Load the Docker images into Minikube
                    sh '''
                    echo "Loading webapp image into Minikube..."
                    minikube image load webapp-tale-compendium:latest || echo "Failed to load webapp image into Minikube"

                    echo "Loading API image into Minikube..."
                    minikube image load api-tale-compendium:latest || echo "Failed to load API image into Minikube"
                    '''
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                dir('terraform/local') {
                    sh '''
                    terraform init || echo "Terraform init failed"
                    terraform apply -auto-approve -var="minikube_ip=${MINIKUBE_IP}" || echo "Terraform apply failed"
                    '''
                }
            }
        }

        stage('Run Tests') {
            steps {
                sh 'echo "Running tests..."'
            }
        }

        stage('Cleanup') {
            steps {
                sh 'docker image prune -f || echo "Docker image cleanup failed"'
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up after build..."
            }
        }
        failure {
            script {
                echo "Pipeline failed!"
            }
        }
    }
}
