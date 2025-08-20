# Use Image Discriptio

Build your Docker Imange base from Base_Spark_versionImage 
make sure you set `.env` from `.envexample` in repo 

```shell
cd Image_Spec_Kubernetes/Base_Spark_versionImage
docker compose -f build-spark-base-image.yaml build
docker compose -f build-spark-base-image.yml push
cd ..
```

after this run below command:

```shell
cd build_image_for_Kubernetes
docker compose -f build-image-kubernetes.yaml build 
docker compose -f build-image-kubernetes.yaml push  
cd ..
```

### Note:

This is just a step where we can build our own Image from 
our existing spark local env. I have observed this image build can go upto 4 GB's 
depending what you install.

Better way is to use a **prebuild Pyspark or Spark Docker Image**
* like Bitnami Spark Image
* apache spark

Check Next section where I am Setting Up Spark On EKS
