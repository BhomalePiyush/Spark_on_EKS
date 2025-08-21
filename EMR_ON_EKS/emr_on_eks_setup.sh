#!/usr/bin/env bash
cd EMR_ON_EKS

export ACCOUNT_NUMBER=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(aws configure get region)
export CLUSTER_NAME=spark-on-eks-demo
export EMR_ON_EKS_NAMESPACE="ns-emr-on-eks"
export EMR_ON_EKS_ROLE_NAME="EMROnEKSRole"

aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

kubectl get svc

kubectl cluster-info

kubectl create namespace ${EMR_ON_EKS_NAMESPACE}

# create EMR on EKS IAM Role

eksctl create iamidentitymapping -f emr_identity_mappings.yaml

aws iam create-role \
    --role-name ${EMR_ON_EKS_ROLE_NAME} \
    --assume-role-policy-document file://pod-identity-trust-policy.json

aws iam put-role-policy --role-name ${EMR_ON_EKS_ROLE_NAME} \
    --policy-name EMR-Containers-Job-Execution \
    --policy-document file://EMRContainers-JobExecutionPolicy.json
# create role association with the namespace
aws emr-containers create-role-associations \
        --cluster-name mycluster \
        --namespace ${EMR_ON_EKS_NAMESPACE} \
        --role-name ${EMR_ON_EKS_ROLE_NAME}

aws emr-containers update-role-trust-policy \
       --cluster-name ${CLUSTER_NAME} \
       --namespace ${EMR_ON_EKS_NAMESPACE} \
       --role-name ${EMR_ON_EKS_ROLE_NAME}

cd ..