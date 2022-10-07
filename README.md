# EPOCHRegister
# Solution Architecture & High-Level Design

--------------------------------------------------------------------------------------------
|Solution Name:     | EPOCHRegister – Register the current epoch time to a backend database | 
|-------------------|-----------------------------------------------------------------------|
|Author             | Rajan Jha                                                             |
---------------------------------------------------------------------------------------------

# Table of Contents 

1.	Solution Summary
2.	Requirements
3.	Application architecture
4.	Folder structure
5.	Deployment
   *	Prerequisite
   *	TF setup
6.	Monitoring and Alerting
7.	HA Failover

# 1.Solution Summary

EPOCHRegister is a serverless api based application which is used to register the current epoch time in the backend database.
EPOCHRegister is hosted on AWS and consumes below AWS resources – 

*	Route 53
*	API Gateway
*	ACM
*	Lambda Function
*	DynamoDB
*	CloudWatch
*	SNS
*	KMS

This solution deploys this serverless application in a multi-region active-active setup. We have deployed the application in two regions us-east-1 and us-west2. Route53 healthcheck alerting has been setup only in us-east-1 due to limitation of aws publishing the metrics on other regions.

# 2. Requirements

|             Requirements	                                |                          Solution                                 |
------------------------------------------------------------|--------------------------------------------------------------------
|API application as frontend                                | Uses two api’s - /getEpoch and /EpochRegisterTime                 | 
|Database as backend                                        | Using a nosql database in the backend                             |
|Each API call has to register current epoch to the database| /EpochRegisterTime api call will create a new entry in backend db |

# 3. Non-Functional

Resiliency & HA 

*	A multi-region active-active deployment in us-east-1 and us-west-2.
*	Use Route53 active-active DNS failover with weighted route policy.
*	Point in time recovery for backend DynamoDB database.
*	Global table Multi region replication for DynamoDB for high availability.

Scalability 

*	DynamoDB with auto scaling capacity in the backend to automatically adapt to the application’s traffic volume.
*	Provisioned concurrency for AWS Lambda to reduce the latency.

Deployments

*	One click deployment using terraform with s3 as the backend.
*	Can be deployed locally .

Hosting

*	Application is hosted on AWS

Security

*	Data encryption at rest in DynamoDB using AWS KMS.
*	Use HTTPS endpoints for accessing the api’s. ACM for certificates.
*   Use KMS for encryption at rest.

Monitoring and logging

*   Cloudwatch to monitor and log aws resources.
*   Route 53 healthchecks to monitor the apigw.
*   Lambda function for apigw health check.

Alerting

* Alarms in cloudwatch sends notification using SNS.

# 3. Application archetecture

<img width="903" alt="image" src="https://user-images.githubusercontent.com/82893856/194475429-3eef53a5-ae8e-48e8-bbde-e6047f3d31fb.png">


# 4. Folder structure

```
.
|
terraform
├── modules                   # terraform local modules
|   ├── frontend              # Module for application frontend
|   └── remote-state          # setup s3 as remote backed with dynamodb for tfstate locking
|   ├── src/lambda_handlers   # Lambda functions source files
...
(terraform files)             # Terraform config to deploy backend db and global resources like iam and route53.
...             
└── README.md

```
# 5. Deployment

 * # Prerequisite 

    1. Configure AWS on your local system with credetials in ~/.aws/credentials.
    2. Terraform (> v1.0.11 or higher). 

 * # Terraform Setup

    # S3 as backend 

    This project used S3 as remote backend with dynamoDB for tfstate locking.
    This is a one time activity to setup the s3 bucket and dynamodb required for the backend.

    1. ``` cd modules/remote-state ``` 
    2. Run ``` terraform init ``` ```terraform plan``` ```terraform deploy``` 
    3. Fetch the s3 bucket and dynamo table name from ```output```

    # Application deployment

    * We are deploying the frontend application with a modular approach in two different regions defind in main.tf. Root directory 
      has the aws provider with an alias (prod-dr) to deploy the same set up of resources in two different regions.
    * As a part of frontend module, we are deploying apigw with custom domain names, three lambda functions for get/post and health, certificates, cloudwatch alarms, sns topic and dns healthchecks in us-east-1 and us-west-2.
    * DynamoDB, IAM role and route 53 traffic policy are getting created along with frondend applications.

    Steps to deploy - 
      * Clone the repo on your local system and ```cd cpoch/time/register/terraform```
      * setup backend.tf with earlier created backend resources.
      * setup aws providers.
      * Create variables in ```variables.tf``` and put all the values in ```terraform.tfvars```
      * Run ```terraform init``` ```terraform plan``` and ```terraform apply```. If dynamodb creation fails due to a bug, follow the instructions in tf file.
      * Wait for few minutes and check the route53 heathcheck if they are healthy.
      * Open ```https://httpie.io/app``` and make a post call to ```https://api.epochregister.click/EpochRegisterTime```
      This should create an entry in the backend database.













