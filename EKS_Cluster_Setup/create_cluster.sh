#!/usr/bin/env bash
cd EKS_Cluster_Setup

export CLUSTER_ROLENAME=AmazonEKSAutoClusterRoleSparkPOC
export NODE_ROLENAME=AmazonEKSAutoNodeRoleSparkPOC

# Cluster IAM Role Setup
aws iam create-role \
    --role-name ${CLUSTER_ROLENAME} \
    --assume-role-policy-document file://cluster-trust-policy.json

export CLUSTER_ROLE_ARN=$(aws iam get-role --role-name ${CLUSTER_ROLENAME} --query "Role.Arn" --output text)

aws iam attach-role-policy \
    --role-name ${CLUSTER_ROLENAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

aws iam attach-role-policy \
    --role-name ${CLUSTER_ROLENAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSComputePolicy

aws iam attach-role-policy \
    --role-name ${CLUSTER_ROLENAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy

aws iam attach-role-policy \
    --role-name ${CLUSTER_ROLENAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy

aws iam attach-role-policy \
    --role-name ${CLUSTER_ROLENAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy

# Node Group IAM Role Setup

aws iam create-role \
    --role-name ${NODE_ROLENAME} \
    --assume-role-policy-document file://node-trust-policy.json

export NODE_ROLE_ARN=$(aws iam get-role --role-name ${NODE_ROLENAME} --query "Role.Arn" --output text)

aws iam attach-role-policy \
    --role-name ${NODE_ROLENAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy

aws iam attach-role-policy \
    --role-name ${NODE_ROLENAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly

aws iam attach-role-policy \
    --role-name ${NODE_ROLENAME} \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

eksctl create cluster --name=${EKS_CLUSTER_NAME} --enable-auto-mode

export AWS_REGION=$(aws configure get region)

aws eks create-cluster \
  --enable-auto-mode \
  --region ${AWS_REGION} \
  --name ${EKS_CLUSTER_NAME} \
  --kubernetes-version 1.33 \
  --role-arn ${CLUSTER_ROLE_ARN} \
  --resources-vpc-config '{"subnetIds": ["subnet-ExampleID1","subnet-ExampleID2"], "securityGroupIds": ["sg-ExampleID1"], "endpointPublicAccess": true, "endpointPrivateAccess": true}' \
  --compute-config '{"enabled": true, "nodeRoleArn": "arn:aws:iam::111122223333:role/AmazonEKSAutoNodeRole", "nodePools": ["general-purpose", "system"]}' \
  --kubernetes-network-config '{"elasticLoadBalancing": {"enabled": true}}' \
  --storage-config '{"blockStorage": {"enabled": true}}' \
  --access-config '{"authenticationMode": "API_AND_CONFIG_MAP"}'