
### Create lambda function for the frontend application
##################################################################

##get function

resource "aws_lambda_function" "getepoch" {
  function_name = "get-epoch"
  description   = "Get epoch register time from dynamodb"
  role          = "arn:aws:iam::${var.aws_account_id}:role/${var.lambdainvokerole}"
  runtime       = var.nodejsver
  handler       = "get-epoch.handler"
  architectures = ["x86_64"]
  filename      = "./src/lambda_handler/get-epoch.zip"

  environment {
    variables = {
      DBTable    = var.db_table_name
      Serverless = "Terraform"
      Region     = var.aws_region
    }
  }
}
################################################################
##post function

resource "aws_lambda_function" "epochregister" {
  function_name = "epoch-register"
  description   = "Register current epoch time in DynamoDB"
  role          = "arn:aws:iam::${var.aws_account_id}:role/${var.lambdainvokerole}"
  handler       = "epoch-register.handler"
  runtime       = var.nodejsver
  architectures = ["x86_64"]

  filename = "./src/lambda_handler/epoch-register.zip"

  environment {
    variables = {
      DBTable    = var.db_table_name
      Serverless = "Terraform"
      Region     = var.aws_region
    }
  }
}
#################################################################
##health function

resource "aws_lambda_function" "health" {
  function_name = "health"
  description   = "APIGW Health check"
  role          = "arn:aws:iam::${var.aws_account_id}:role/${var.lambdainvokerole}"
  handler       = "health.handler"
  runtime       = "python3.9"
  architectures = ["x86_64"]

  filename = "./src/lambda_handler/health.py.zip"

  environment {
    variables = {
      STATUS     = "200"
      Serverless = "Terraform"
      Region     = var.aws_region
    }
  }
}
#################################################################