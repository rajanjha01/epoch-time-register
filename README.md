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
   •	Prerequisite
   •	TF setup
6.	Monitoring and Alerting
7.	HA Failover

# 1.Solution Summary

EPOCHRegister is a serverless api based application which is used to register the current epoch time in the backend database.
EPOCHRegister is hosted on AWS and consumes below AWS resources – 

•	Route 53
•	API Gateway
•	ACM
•	Lambda Function
•	DynamoDB
•	CloudWatch
•	SNS
•	KMS

This solution deploys this serverless application in a multi-region active-active setup. We have deployed the application in two regions us-east-1 and us-west2. Route53 healthcheck alerting has been setup only in us-east-1 due to limitation of aws publishing the metrics on other regions.

# 2. Requirements

|API application as frontend                                | Uses two api’s - /getEpoch and /EpochRegisterTime                 | 
------------------------------------------------------------|-------------------------------------------------------------------|
|Database as backend                                        | Using a nosql database in the backend                             |
|-----------------------------------------------------------|-------------------------------------------------------------------|
|Each API call has to register current epoch to the database| /EpochRegisterTime api call will create a new entry in backend db |