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
6.  HA Failover
7.	Monitoring and Alerting


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
      * Clone the repo on your local system and ```cd epoch-time-register/terraform```
      * setup backend.tf with earlier created backend resources.
      * setup aws providers.
      * Create variables in ```variables.tf``` and put all the values in ```terraform.tfvars```
      * Run ```terraform init``` ```terraform plan``` and ```terraform apply```. If dynamodb creation fails due to a bug, follow the instructions in tf file.
      * Wait for few minutes and check the route53 heathcheck if they are healthy.
      * Open ```https://httpie.io/app``` and make a post call to ```https://api.epochregister.click/EpochRegisterTime```
      This should create an entry in the backend database.

<img width="1567" alt="image" src="https://user-images.githubusercontent.com/82893856/194481235-9c286f16-237f-4afc-a31e-cf64680142be.png">

      We can see the newly created entry in the dynamodb. 
<img width="1482" alt="image" src="https://user-images.githubusercontent.com/82893856/194481392-5c8b3a4e-774c-4c18-9f73-be75ec64b74f.png">
      DynamoDB should be updated in both the regions with the latest epoch entry.


# 6. HA and DNS failover

* We are using Route53 healthchecks to monitor the healthcheck of apigw. 
* Route 53 is configured with weighted routed policy in this active-active setup.
* If status of both healthchecks are healthy, route53 will redirect the traffic 50-50 to both the regions.
<img width="1329" alt="image" src="https://user-images.githubusercontent.com/82893856/194482347-a55444fa-b07a-4149-826e-d761e05ff866.png">

When both the healthchecks are healthy, the request will be routed to both the regions as per the below snippet, 

<img width="1537" alt="image" src="https://user-images.githubusercontent.com/82893856/194482430-2499f2fc-2e92-4817-982a-896ba40a1590.png">

<img width="1552" alt="image" src="https://user-images.githubusercontent.com/82893856/194482568-441e82a2-419c-4fd6-ba93-f8cbe61a7146.png">

* In case of one region going down, the healthcheck for that region will be unhealthy and requests will be routed to the healthy region.
  Change the status of healtch lambda function to 400 in us-west-2, now we can see the healthcheck is unhealthy in this region.
  
  <img width="1290" alt="image" src="https://user-images.githubusercontent.com/82893856/194483262-85661ddb-acd8-436a-ba6b-b887454cbed7.png">

All the traffic will be routed to us-east-1 only.

<img width="1569" alt="image" src="https://user-images.githubusercontent.com/82893856/194483380-89126b1c-c437-437c-8ff9-d73aeb2bbcf0.png">

# 7. Monitoring and alerting

  

















