#!/usr/bin/env bash
cd EMR_ON_EKS

export ACCOUNT_NUMBER=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(aws configure get region)
export CLUSTER_NAME=spark-on-eks-demo
export EMR_ON_EKS_NAMESPACE="ns-emr-on-eks"
export EMR_ON_EKS_ROLE_NAME="EMROnEKSRole"
export VIRTUAL_CLUSTER_NAME=${CLUSTER_NAME}_VC1

aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

kubectl get svc

kubectl cluster-info

kubectl create namespace ${EMR_ON_EKS_NAMESPACE}

# create EMR on EKS IAM Role
envsubset emr_identity_mappings.yaml > emr_identity_mappings_env.yaml
eksctl create iamidentitymapping -f emr_identity_mappings_env.yaml
rm emr_identity_mappings_env.yaml
# disable if below and enable second command if do not want to use
# pod identity agent
aws iam create-role \
    --role-name ${EMR_ON_EKS_ROLE_NAME} \
    --assume-role-policy-document file://pod-identity-trust-policy.json \
    --discription "emr on eks role for demo"

#aws iam create-role \
#    --role-name ${EMR_ON_EKS_ROLE_NAME} \
#    --assume-role-policy-document file://emr-on-eks-default-trust-policy.json


aws iam put-role-policy --role-name ${EMR_ON_EKS_ROLE_NAME} \
    --policy-name EMR-Containers-Job-Execution \
    --policy-document file://EMRContainers-JobExecutionPolicy.json

# create role association with the namespace
# if not want to use pod identity comment this part
aws emr-containers create-role-associations \
        --cluster-name mycluster \
        --namespace ${EMR_ON_EKS_NAMESPACE} \
        --role-name ${EMR_ON_EKS_ROLE_NAME}

aws emr-containers update-role-trust-policy \
       --cluster-name ${CLUSTER_NAME} \
       --namespace ${EMR_ON_EKS_NAMESPACE} \
       --role-name ${EMR_ON_EKS_ROLE_NAME}

virtual_cluster_id=(aws emr-containers create-virtual-cluster \
      --name ${VIRTUAL_CLUSTER_NAME} \
      --container-provider '{
          "id": "spark-on-eks-demo",
          "type": "EKS",
          "info": {
              "eksInfo": {
                  "namespace": "ns-emr-on-eks"
              }
          }
      }' \
      --query 'id' --output text)

export VIRTUAL_CLUSTER_ID=virtual_cluster_id

echo "Virtual cluster ID is ->> ${VIRTUAL_CLUSTER_ID}"

# python3 run_job_emr_on_eks_job.py
cd ..