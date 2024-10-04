#!/bin/bash

# Start LocalStack if it's not already running
docker ps | grep localstack > /dev/null
if [ $? -ne 0 ]; then
  echo "Starting LocalStack..."
  docker run -d -p 4566:4566 -p 4571:4571 localstack/localstack
else
  echo "LocalStack is already running."
fi
