#!/usr/bin/env bash

cd Test_Spark

export AWS_REGION=$(aws configure get region)
export ACCOUNT_NUMBER=$(aws sts get-caller-identity --query Account --output text)
export BUCKET_NAME=""
export EMR_DOCKER_IMAGE='spark/emr-7.8.0-custom:latest'

if [ -z "$S3_BUCKET_NAME" ]; then
  echo "Bucket name not found to for logging...."
  exit 1
fi

aws s3 cp pi.py s3://${BUCKET_NAME}/Test/pi.py
aws s3 cp depstest.py s3://${BUCKET_NAME}/Test/depstest.py

if [[ $1 == "EMR_ON_EKS" ]]; then
  echo "run spark on eks"
  export EMR_ON_EKS_ROLE_NAME="EMROnEKSRole"
  export VIRTUAL_CLUSTER_ID=''
  python3 run_job_emr_on_eks_job.py
elif [[ $1 == "Spark_ON_EKS" ]]; then
  echo "run spark with spark operator...."
  export SPARK_ON_EKS_ROLE_NAME="SparkOnEKSRole"
  envsubset run_spark_job_spark_operator.yaml > run_spark_job_spark_operator_env.yaml
  kubectl apply -f run_spark_job_spark_operator_env.yaml
  rm run_spark_job_spark_operator_env.yaml
  kubectl get sparkapplication pyspark-pi -o=yaml
  kubectl describe sparkapplication pyspark-pi -n ns-spark-on-eks
  kubectl get verticalpodautoscalers --all-namespaces \
  -l=emr-containers.amazonaws.com/dynamic.sizing.signature=my-signature
else
  echo "please select one of the test mode (EMR_ON_EKS Spark_ON_EKS)"
fi

cd ..
