#!/bin/bash

# Start Minikube if not running
minikube status > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Starting Minikube..."
  minikube start --driver=docker
else
  echo "Minikube is already running."
fi
