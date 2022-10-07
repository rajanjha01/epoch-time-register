## Setup dynamodb using the official aws module 
## credit : https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table/
##############################################################################

## Define tagging 
locals {
  tags = {
    Terraform   = "true"
    Environment = "Prod"
  }
}

################################################################################
# Supporting Resources
################################################################################

resource "random_pet" "this" {
  length = 2
}

resource "aws_kms_key" "primary" {
  description = "CMK for primary region"
  tags        = local.tags
}

resource "aws_kms_key" "secondary" {
  provider = aws.prod-dr

  description = "CMK for secondary region"
  tags        = local.tags
}

################################################################################
# DynamoDB Global Table
################################################################################

module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name                               = var.dynamodb-table-name
  hash_key                           = "id"
  billing_mode                       = "PROVISIONED"
  read_capacity                      = 5
  write_capacity                     = 5
  autoscaling_enabled                = true
  stream_enabled                     = true
  stream_view_type                   = "NEW_AND_OLD_IMAGES"
  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_key.primary.arn
  point_in_time_recovery_enabled     = true


  autoscaling_read = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
    max_capacity       = 10
  }

  autoscaling_write = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 45
    max_capacity       = 10
  }

  attributes = [

    {
      name = "id"
      type = "S"
    },

  ]
  ## There is a bug while creating replica with autoscaling. https://github.com/hashicorp/terraform-provider-aws/issues/13097
  ## Added replica block after the table creation in first apply and it works fine. 
  replica_regions = [{
    region_name            = "us-west-2"
    kms_key_arn            = aws_kms_key.secondary.arn
    propagate_tags         = true
    point_in_time_recovery = true
  }]

  tags = local.tags
}

##########################################################