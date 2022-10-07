## Creating active-active multi region setup including dynamodb, apigw, lambda, route 53 using local modules.

module "frontend_us-east-1" {
  source           = "./modules/frontend"
  db_table_name    = var.dynamodb-table-name
  aws_region       = var.aws_region_a
  aws_account_id   = var.aws_account_id
  nodejsver        = var.nodejsver
  lambdainvokerole = var.lambdainvokerole
  epoch-apigw      = var.epoch-apigw
}

module "frontend_us-west-2" {
  providers = {
    aws = aws.prod-dr
  }
  source           = "./modules/frontend"
  db_table_name    = var.dynamodb-table-name
  aws_region       = var.aws_region_b
  aws_account_id   = var.aws_account_id
  nodejsver        = var.nodejsver
  lambdainvokerole = var.lambdainvokerole
  epoch-apigw      = var.epoch-apigw
}
############################################
