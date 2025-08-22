import boto3
import os
import uuid

aws_region = os.getenv("AWS_REGION","us-east-1")
virtual_cluster_id = os.getenv("VIRTUAL_CLUSTER_ID")
execution_role_name = os.getenv("EMR_ON_EKS_ROLE_NAME")
aws_account_number = os.getenv("ACCOUNT_NUMBER")

# get bucket name by running Test_Spark/copy_code.sh

spark_code_bucket_name = os.getenv("BUCKET_NAME","")
# get bucket name by running EMR_Docker_Image/build_image.sh
dockar_image_name = os.getenv("EMR_DOCKER_IMAGE","")

emr_release_lable = os.getenv("EMR_RELEASE_LABLE",'emr-7.8.0-latest')

def trigger_job():
    session = boto3.Session(region_name=aws_region)
    client = session.client('emr-containers')
    response = client.start_job_run(
        name="EMR_ON_EKS_First_job",
        virtualClusterId = virtual_cluster_id,
        clientToken = uuid.uuid4().hex,
        executionRoleArn = f"arn:aws:iam::{aws_account_number}:role/{execution_role_name}",
        releaseLabel = emr_release_lable,
        obDriver={
            'sparkSubmitJobDriver': {
                'entryPoint': f's3://{spark_code_bucket_name}/Test/pi.py',
                'entryPointArguments': [],
                'sparkSubmitParameters': f'--py-files s3://{spark_code_bucket_name}/Test/depstest.py'
            }
        },
        configurationOverrides={
            'applicationConfiguration': [
                {
                    'classification': 'spark-defaults',
                    'properties': {
                        'spark.hadoop.fs.s3a.aws.credentials.provider': 'com.amazonaws.auth.WebIdentityTokenCredentialsProvider',
                        'spark.kubernetes.container.image': f'{aws_account_number}.dkr.ecr.{aws_region}.amamzonaws.com/{dockar_image_name}',
                        'spark.driver.core': '4',
                        'spark.driver.memory': '15G',
                        'spark.executor.core': '2',
                        'spark.executor.memort': '8G'
                    },
                    'configurations': {'... recursive ...'}
                },
            ],
            'monitoringConfiguration': {
                # 'managedLogs': {
                #     'allowAWSToRetainLogs': 'ENABLED' | 'DISABLED',
                #     'encryptionKeyArn': 'string'
                # },
                'persistentAppUI': 'ENABLED' ,
                # 'cloudWatchMonitoringConfiguration': {
                #     'logGroupName': 'string',
                #     'logStreamNamePrefix': 'string'
                # },
                's3MonitoringConfiguration': {
                    'logUri': f's3://{spark_code_bucket_name}/logs/'
                },
                'containerLogRotationConfiguration': {
                    'rotationSize': 'string',
                    'maxFilesToKeep': 123
                }
            }
        },
    )
    return response

if __name__=="__main__":
    if not spark_code_bucket_name:
        raise Exception("please set your bucket name or get bucket name by running Test_Spark/copy_code.sh")
    elif not dockar_image_name:
        raise Exception("please set your docket image name or get name by executing EMR_Docker_Image/build_image.sh")
    else:
        trigger_job()