#!/bin/bash

# Ensure permissions are correct
chmod +x scripts/start-localstack.sh
chmod +x scripts/start-minikube.sh

# Start LocalStack and Minikube
echo "Setting up LocalStack and Minikube..."
./scripts/start-localstack.sh
./scripts/start-minikube.sh

# Jenkins will use Minikube's Docker daemon to build and push images
echo "Configuring Docker to use Minikube..."
eval $(minikube -p minikube docker-env)

# Confirm everything is running
echo "LocalStack and Minikube setup complete."
