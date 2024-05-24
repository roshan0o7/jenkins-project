#!/bin/bash

# AWS region
AWS_REGION="us-east-1"

# AWS ECR repository URL
ECR_REPO_URL="006432355300.dkr.ecr.us-east-1.amazonaws.com/webserverimage"

# Docker image tag
IMAGE_TAG="webserver"

# AWS ECR login
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL

# Pull the Docker image
docker pull $ECR_REPO_URL:$IMAGE_TAG

# Run the Docker container
docker run -d -p 8080:8080 $ECR_REPO_URL:$IMAGE_TAG
