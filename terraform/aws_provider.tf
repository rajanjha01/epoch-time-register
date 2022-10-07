## TF and AWS provider version requirements
terraform {
  required_version = ">= 1.0.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0"
    }
  }
}
provider "aws" {
  region  = var.aws_region_a
  profile = var.aws_profile_name


}
## multiple providers with alias
provider "aws" {
  alias   = "prod-dr"
  region  = var.aws_region_b
  profile = var.aws_profile_name

}
