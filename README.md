# Genomics Data Pipeline

**A serverless, event-driven AWS pipeline for processing genomics VCF files, transforming them into Parquet, and enabling analytics with Athena, built using Terraform.**

## 📖 Project Overview

The Genomics Data Pipeline is a scalable, secure, and automated AWS-based solution designed to process Variant Call Format (VCF) files, transform them into Parquet format, and make them queryable via AWS Athena. It leverages a serverless architecture with AWS Lambda, Glue, and S3, orchestrated by Terraform for infrastructure-as-code (IaC) deployments. The pipeline validates VCF files, processes them into a structured format, and updates a Glue Data Catalog for analytics.

Key features:
- **VCF Processing**: Validate and transform VCF files into Parquet using AWS Glue.
- **Event-Driven Trigger**: Automatically process files uploaded to S3 via Lambda.
- **Analytics**: Query processed data using Athena with results stored in S3.
- **Secure Storage**: Use KMS-encrypted S3 buckets for raw and processed data.
- **IaC Automation**: Deploy and manage infrastructure with Terraform.

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **AWS Lambda** | Validates VCF files and triggers Glue jobs |
| **AWS Glue** | Transforms VCF files to Parquet and updates Data Catalog |
| **AWS Athena** | Queries processed genomics data |
| **AWS S3** | Stores raw VCF files, processed Parquet files, and Athena query results |
| **AWS KMS** | Encrypts S3 buckets for secure storage |
| **AWS IAM** | Manages permissions for Lambda, Glue, and Athena |
| **Terraform** | Infrastructure as Code for provisioning AWS resources |
| **GitHub** | Version control for Terraform configurations |

## 🏗️ Architecture

The pipeline follows a modular, serverless, and event-driven architecture:

- **Input**: S3 bucket (`genomics-raw-data-bucket`) stores uploaded VCF files and triggers Lambda via S3 notifications.
- **Processing**:
  - **Lambda Function (`validate-vcf`)**: Validates VCF file format and triggers Glue jobs, handling concurrency limits.
  - **Glue Job (`genomics-vcf-etl-job`)**: Reads VCF files, transforms them to Parquet, and partitions by `CHROM`.
- **Storage**: Processed Parquet files are stored in `s3://genomics-processed-data-bucket/processed/`.
- **Cataloging**: Glue Crawler (`genomics-raw-data-bucket-crawler`) updates the Data Catalog (`genomics_vcf_database.vcf_data`).
- **Analytics**: Athena queries the cataloged data, storing results in `s3://genomics-processed-data-bucket/athena-queries/`.
- **Security**: KMS encryption secures S3 buckets, and IAM roles restrict access.

![Architecture Diagram](https://github.com/ankurshashwat/genomics-data-pipeline/blob/81bb5b700a0a8585d3fb9dd917e27faca87d5183/genomics-data-pipeline-architecture.PNG)

## 📂 Repository Structure

```plaintext
genomics-data-pipeline/
├── terraform/
│    ├── main.tf                   # Root Terraform configuration
│    ├── variables.tf              # Root input variables
│    ├── outputs.tf                # Root output values
│    ├── terraform.tfvars          # Terraform variable definitions
│    ├── s3_notification.tf        # S3 bucket notification configuration
│    ├── modules/                  # Terraform modules
│    │    ├── s3/                  # S3 buckets for input, output, and Glue scripts
│    │    ├── lambda/              # Lambda function for VCF validation
│    │    ├── iam/                 # IAM roles for Lambda and Glue
│    │    ├── glue/                # Glue job and crawler for processing and cataloging
│    │    └── athena/              # Athena database and workgroup
├── README.md                      # Project documentation
├── .gitignore                     # Git ignore rules
├── test.vcf                       # Test VCF file for testing
└── LICENSE                        # MIT License
```

## 🚀 Setup Instructions

Follow these steps to set up the project locally:

### Prerequisites

- **AWS Account** with programmatic access (Access Key and Secret Key).
- **Terraform** v1.5.7 or later installed (`terraform -version`).
- **Git** installed (`git --version`).
- **AWS CLI** v2 installed and configured (`aws configure`).
- **Python** 3.9 for Lambda and Glue scripts.

### Steps

1. **Clone the Repository**
   - Clone the repo locally:
     ```bash
     git clone https://github.com/ankurshashwat/genomics-data-pipeline.git
     cd genomics-data-pipeline
     ```

2. **Configure AWS Credentials**
   - Set up AWS CLI with your credentials:
     ```bash
     aws configure
     ```
     - Provide Access Key, Secret Key, region (`us-east-1`), and output format (`json`).

3. **Initialize Terraform**
   - Initialize the Terraform working directory:
     ```bash
     terraform init
     ```

4. **Set Up Terraform Variables**
   - Create a `terraform.tfvars` file in the `terraform/` directory:
     ```hcl
     aws_region          = "us-east-1"
     input_bucket_name   = "genomics-raw-data-bucket"
     output_bucket_name  = "genomics-processed-data-bucket"
     lambda_function_name = "validate-vcf"
     glue_job_name       = "genomics-vcf-etl-job"
     glue_crawler_name   = "genomics-raw-data-bucket-crawler"
     ```
     - The bucket names will append a random suffix (e.g., `klc6`).

5. **Deploy Infrastructure**
   - Run Terraform plan to preview changes:
     ```bash
     terraform plan
     ```
   - Apply the configuration:
     ```bash
     terraform apply --auto-approve
     ```
   - Outputs (e.g., `input_bucket_name`, `output_bucket_name`) will be displayed.

6. **Prepare Test Data**
   - Create a `test.vcf` file in the project root:
     ```bash
     echo #CHROM	POS	REF	ALT	QUAL	sample1	sample2 > test.vcf
     echo chr1	1002345	A	G	45.7	0/1	1/1 >> test.vcf
     echo chr2	2003456	C	T	50.2	0/0	0/1 >> test.vcf
     ```

7. **Test the Pipeline**
   - Upload `test.vcf` to the input bucket:
     ```bash
     aws s3 cp test.vcf s3://<input_bucket_name>/test.vcf --region us-east-1
     ```
   - Verify Lambda trigger:
     ```bash
     aws logs tail /aws/lambda/validate-vcf --since 10m --region us-east-1
     ```
     - Look for `Started Glue job: <JobRunId>`.
   - Check Glue job status:
     ```bash
     aws glue get-job-runs --job-name genomics-vcf-etl-job --region us-east-1
     ```
   - Verify Parquet output:
     ```bash
     aws s3 ls s3://<output_bucket_name>/processed/ --recursive --region us-east-1
     ```
   - Run Glue crawler:
     ```bash
     aws glue start-crawler --name genomics-raw-data-bucket-crawler --region us-east-1
     ```
   - Query data in Athena:
     ```bash
     aws athena start-query-execution \
       --query-string "SELECT * FROM genomics_vcf_database.vcf_data LIMIT 10;" \
       --work-group genomics_workgroup \
       --region us-east-1
     ```
     - Check results:
       ```bash
       aws athena get-query-results --query-execution-id <QueryExecutionId> --region us-east-1
       ```

8. **Clean Up**
   - Destroy resources to avoid costs:
     ```bash
     terraform destroy --auto-approve
     ```

## 🧪 Testing and Validation

- **Infrastructure**: Verified S3 buckets, Lambda, Glue job, crawler, and Athena workgroup in AWS Console.
- **Lambda Trigger**: Confirmed S3 notifications trigger `validate-vcf` Lambda function.
- **Glue Processing**: Validated Parquet output for `test.vcf` in `s3://<output_bucket_name>/processed/`.
- **Athena Queries**: Executed queries in `genomics_workgroup` and verified results in `s3://<output_bucket_name>/athena-queries/`.
- **Security**: Ensured KMS encryption and IAM roles restrict access appropriately.

## 📚 Lessons Learned

- **Serverless Pipelines**: Mastered event-driven workflows with S3, Lambda, and Glue.
- **Terraform Modules**: Structured reusable modules for S3, Lambda, Glue, and Athena.
- **Concurrency Management**: Implemented Lambda logic to handle Glue job concurrency limits.
- **Athena Integration**: Learned to configure query result locations and bucket policies for analytics.

## 🚧 Future Improvements

- Add SNS notifications for pipeline status updates.
- Implement CloudWatch monitoring for Lambda and Glue job metrics.
- Support larger VCF files with Glue job optimization.
- Integrate QuickSight for data visualization.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes with descriptive messages.
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

## 📬 Contact

- **Author**: ankurshashwat
- **Email**: ankurshwt@gmail.com
- **LinkedIn**: [ankurshashwat](https://linkedin.com/in/ankurshashwat)

## 📄 License

This project is licensed under the MIT License.
