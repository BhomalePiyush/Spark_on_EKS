#!/usr/bin/env bash
cd Image_Spec_Kubernetes

echo "building base image for spark"
sleep 10
docker compose -f Base_Spark_versionImage/build-spark-base-image.yml build
docker compose -f Base_Spark_versionImage/build-spark-base-image.yml push

echo "building kubernetes image for spark single arch......"
sleep 10
docker compose -f build_image_for_Kubernetes/build-image-kubernetes.yml build
docker compose -f build_image_for_Kubernetes/build-image-kubernetes.yml push

cd ..