## S3 as remote backend with dynamo for tfstate locking
terraform {
  backend "s3" {
    key            = "epoch/infra/terraform.tfstate"
    bucket         = "epoch-infra-tfstate"
    dynamodb_table = "epoch-infra-tfstate-lock"
    region         = "us-east-1"
  }
}