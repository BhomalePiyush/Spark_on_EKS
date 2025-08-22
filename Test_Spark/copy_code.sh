#!/usr/bin/env bash


cd Test_Spark

export AWS_REGION=$(aws configure get region)

export BUCKET_NAME="spark_test_bucket_$(uuidgen | tr -d - | tr '[:upper:]' '[:lower:]' )"
aws s3api create-bucket \
    --bucket ${BUCKET_NAME} \
    --region ${AWS_REGION}
echo "bucket created ${BUCKET_NAME}"
aws s3 cp pi.py s3://${BUCKET_NAME}/Test/pi.py
aws s3 cp depstest.py s3://${BUCKET_NAME}/Test/depstest.py




cd ..