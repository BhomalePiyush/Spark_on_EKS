#!/usr/bin/env bash
cd Test_Spark
export AWS_REGION=$(aws configure get region)
export ACCOUNT_NUMBER=$(aws sts get-caller-identity --query Account --output text)
export BUCKET_NAME=""

aws s3 cp pi.py s3://${BUCKET_NAME}/Test/pi.py
aws s3 cp depstest.py s3://${BUCKET_NAME}/Test/depstest.py

if [[ $1 == "EMR_ON_EKS" ]]; then
  echo "run spark on eks"
  export EMR_ON_EKS_ROLE_NAME="EMROnEKSRole"
  export VIRTUAL_CLUSTER_ID=''
  export EMR_DOCKER_IMAGE=''
  python3 run_job_emr_on_eks_job.py
elif [[ $1 == "Spark_ON_EKS" ]]; then
  echo "run spark on eks"
else
  echo "please select one of the test mode (EMR_ON_EKS Spark_ON_EKS)"
fi

cd ..
