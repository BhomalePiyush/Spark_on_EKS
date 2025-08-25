#!/usr/bin/env bash
cd Spark_On_EKS

export ACCOUNT_NUMBER=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(aws configure get region)
export CLUSTER_NAME=spark-on-eks-demo
export EKS_NAMESPACE="ns-spark-on-eks"
export EKS_ROLE_NAME="SparkOnEKSRole"
export SERVICE_ACCOUNT=aws-resource-access
export oidc_id=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
export S3_BUCKET_NAME=""
if [ -z "$S3_BUCKET_NAME" ]; then
  echo "Bucket name not found to for logging...."
  exit 1
fi


envsubset eks_iam_service_account.yaml > eks_iam_service_account_env.yaml
kubectl apply -f eks_iam_service_account_env.yaml -n ${EKS_NAMESPACE}
rm eks_iam_service_account_env.yaml

#envsubset spark_on_eks_trust_relationship.json > spark_on_eks_trust_relationship_env.json
#
#aws iam create-role \
#    --role-name ${EKS_ROLE_NAME} \
#    --assume-role-policy-document file://spark_on_eks_trust_relationship_env.json \
#    --discription "spark on eks role for demo"
#rm spark_on_eks_trust_relationship_env.json

envsubset spark_on_eks_trust_relationship_pod_Identity.json > spark_on_eks_trust_relationship_pod_Identity_env.json
aws iam create-role \
    --role-name ${EKS_ROLE_NAME} \
    --assume-role-policy-document file://spark_on_eks_trust_relationship_pod_Identity_env.json \
    --discription "spark on eks role for demo"
rm spark_on_eks_trust_relationship_pod_Identity_env.json

aws iam put-role-policy --role-name ${EKS_ROLE_NAME} \
    --policy-name EMR-Containers-Job-Execution \
    --policy-document file://SparkOperator-JobExecutionPolicy.json

kubectl annotate serviceaccount -n ${EKS_NAMESPACE} ${SERVICE_ACCOUNT} eks.amazon.com/role-arn=arn:aws:iam::${ACCOUNT_NUMBER}:role/${EKS_ROLE_NAME}

kubectl describe serviceaccount ${SERVICE_ACCOUNT} -n ${EKS_NAMESPACE}

kubectl get serviceaccount -n ${EKS_NAMESPACE} -o yaml

aws ecr get-login-password \
  --region ${AWS_REGION} | helm registry login \
  --username AWS \
  --password-stdin ${ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com

helm install spark-operator-demo \
  oci://895885662937.dkr.ecr.${AWS_REGION}.amazonaws.com/spark-operator \
  --set emrContainers.awsRegion=${AWS_REGION} \
  --version 7.8.0 \
  --namespace ${EKS_NAMESPACE} \
  --set "spark.jobNamespace={${EKS_NAMESPACE}}" \
  --set sparkJobNamespace=${EKS_NAMESPACE} \
  --set serviceAccounts.sparkoperator.name ${SERVICE_ACCOUNT} \
  --set webhook.enable=true \
  --set webhook-srvc-namespace=${EKS_NAMESPACE} \
  --set webhook-port=433 \
  --set sparkJobNamespace=${EKS_NAMESPACE} \
  --set enableBatchScheduler=true \
  --set ingressUrlFormat="\{\{\$appName\}\}.ingress.cluster.com" \
  --set emrContainers.monitoringConfiguration.s3MonitoringConfiguration.logUri=s3://${S3_BUCKET_NAME}/logs/ \
  --set emrContainers.monitoringConfiguration.containerLogRotationConfiguration.maxFilesToKeep=10 \
  --set emrContainers.operatorExecutionRoleArn=arn:aws:iam::${ACCOUNT_NUMBER}:role/${EKS_ROLE_NAME}

# get spark application

cd ..