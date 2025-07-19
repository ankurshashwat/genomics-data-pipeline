import json
import boto3
import urllib.parse
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

glue_client = boto3.client('glue')
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
        
        # Validate bucket name matches INPUT_BUCKET_NAME
        expected_bucket = os.environ['INPUT_BUCKET_NAME']
        if bucket != expected_bucket:
            logger.error(f"Unexpected bucket: {bucket}, expected: {expected_bucket}")
            return {
                'statusCode': 400,
                'body': json.dumps(f"Unexpected bucket: {bucket}")
            }
        
        # Validate VCF file (basic check for header)
        response = s3_client.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read().decode('utf-8').splitlines()
        if not content[0].startswith('##fileformat=VCF'):
            logger.error("Invalid VCF file format")
            return {
                'statusCode': 400,
                'body': json.dumps('Invalid VCF file format')
            }
        
        # Trigger Glue job
        glue_job_name = os.environ['GLUE_JOB_NAME']
        output_bucket = os.environ['OUTPUT_BUCKET_NAME']
        response = glue_client.start_job_run(
            JobName=glue_job_name,
            Arguments={
                '--input_path': f"s3://{bucket}/{key}",
                '--output_path': f"s3://{output_bucket}/processed/"
            }
        )
        
        logger.info(f"Started Glue job: {response['JobRunId']}")
        return {
            'statusCode': 200,
            'body': json.dumps('Glue job triggered successfully')
        }
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error: {str(e)}")
        }