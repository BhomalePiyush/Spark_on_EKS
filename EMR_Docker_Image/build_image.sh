#!/usr/bin/env bash

# considerations https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/docker-custom-images-considerations.html
# go through below document before using any EMR image as base
# https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/docker-custom-images-steps.html
# i am using emr version later than EMR 6.9.0 steps will change if using EMR 6.9.0 or older
cd EMR_Docker_Image
export EMR_VERSION=emr-7.8.0
export BASE_IMAGE=public.ecr.aws/emr-on-eks/spark/${EMR_VERSION}:latest
export PUSH_IMAGE=spark/${EMR_VERSION}-custom
export PUSH_TAG=latest
export ACCOUNT_NUMBER=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(aws configure get region)

# Attempt to describe the repository
if ! aws ecr describe-repositories --repository-names "${PUSH_IMAGE}" > /dev/null 2>&1; then
    # If describe-repositories fails (e.g., RepositoryNotFoundException), create the repository
    echo "Repository '${PUSH_IMAGE}' not found. Creating it..."
    aws ecr create-repository --repository-name "${PUSH_IMAGE}"
    echo "Repository '${PUSH_IMAGE}' created successfully."
else
    echo "Repository '${PUSH_IMAGE}' already exists. No action taken."
fi


aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com
echo "Logged in into ECR using Docker"

# Docker compose does not support multi arch Build so skipping that
# As i am on mac so adding build arch
docker buildx build --platform linux/amd64 --build-args BASE_IMAGE=${BASE_IMAGE} \
        -t ${PUSH_IMAGE}:${PUSH_TAG}

echo "Image Build Success...."
echo "Tagging Image...."
docker tag ${PUSH_IMAGE}:${PUSH_TAG} ${ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PUSH_IMAGE}:${PUSH_TAG}

docker push ${ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PUSH_IMAGE}:${PUSH_TAG}

cd ..