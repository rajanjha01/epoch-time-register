########################################################################
# API GATEWAY - Sets up & configure api gw
########################################################################

###### Creating apigw

resource "aws_api_gateway_rest_api" "epochregister" {
  name = "EpochRegisterTime"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
##### Creating getEpoch api with the necessary apigw config ##############

resource "aws_api_gateway_resource" "getepoch" {
  rest_api_id = aws_api_gateway_rest_api.epochregister.id
  parent_id   = aws_api_gateway_rest_api.epochregister.root_resource_id
  path_part   = "getEpoch"
}

resource "aws_api_gateway_method" "getepoch" {
  resource_id   = aws_api_gateway_resource.getepoch.id
  rest_api_id   = aws_api_gateway_rest_api.epochregister.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "getepoch" {
  rest_api_id             = aws_api_gateway_rest_api.epochregister.id
  resource_id             = aws_api_gateway_resource.getepoch.id
  http_method             = aws_api_gateway_method.getepoch.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.getepoch.invoke_arn
}

##### Creating EpochRegisterTime api ##################################

resource "aws_api_gateway_resource" "epochregistertime" {
  rest_api_id = aws_api_gateway_rest_api.epochregister.id
  parent_id   = aws_api_gateway_rest_api.epochregister.root_resource_id
  path_part   = "EpochRegisterTime"
}

resource "aws_api_gateway_method" "epochregistertime" {
  rest_api_id   = aws_api_gateway_rest_api.epochregister.id
  resource_id   = aws_api_gateway_resource.epochregistertime.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "epochregistertime" {
  rest_api_id             = aws_api_gateway_rest_api.epochregister.id
  http_method             = aws_api_gateway_method.epochregistertime.http_method
  resource_id             = aws_api_gateway_resource.epochregistertime.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.epochregister.invoke_arn
}
##### Creating health api ##################################
resource "aws_api_gateway_resource" "epochhealth" {
  rest_api_id = aws_api_gateway_rest_api.epochregister.id
  parent_id   = aws_api_gateway_rest_api.epochregister.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "epochhealth" {
  rest_api_id   = aws_api_gateway_rest_api.epochregister.id
  resource_id   = aws_api_gateway_resource.epochhealth.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "epochhealth" {
  rest_api_id             = aws_api_gateway_rest_api.epochregister.id
  http_method             = aws_api_gateway_method.epochhealth.http_method
  resource_id             = aws_api_gateway_resource.epochhealth.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.health.invoke_arn
}
## apigw deployment

resource "aws_api_gateway_deployment" "epochregister" {

  rest_api_id = aws_api_gateway_rest_api.epochregister.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.getepoch.id,
      aws_api_gateway_method.getepoch.id,
      aws_api_gateway_integration.getepoch.id,
      aws_api_gateway_resource.epochregistertime.id,
      aws_api_gateway_method.epochregistertime.id,
      aws_api_gateway_integration.epochregistertime.id,
      aws_api_gateway_resource.epochhealth.id,
      aws_api_gateway_method.epochhealth.id,
      aws_api_gateway_integration.epochhealth.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
## Create apigw stage

resource "aws_api_gateway_stage" "epochregister" {
  rest_api_id   = aws_api_gateway_rest_api.epochregister.id
  deployment_id = aws_api_gateway_deployment.epochregister.id
  stage_name    = "prod"
}

## Allow API Gateway to invoke lambda function

resource "aws_lambda_permission" "getepoch_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getepoch.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.epochregister.id}/*/${aws_api_gateway_method.getepoch.http_method}${aws_api_gateway_resource.getepoch.path}"
}

resource "aws_lambda_permission" "epochregister_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.epochregister.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.epochregister.id}/*/${aws_api_gateway_method.epochregistertime.http_method}${aws_api_gateway_resource.epochregistertime.path}"
}

resource "aws_lambda_permission" "health_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.epochregister.id}/*/${aws_api_gateway_method.epochhealth.http_method}${aws_api_gateway_resource.epochhealth.path}"
}
########### Custom Domain public for APIGW - Registers a custom domain name for use with AWS API Gateway

resource "aws_api_gateway_domain_name" "epochregister" {
  domain_name              = "api.epochregister.click"
  regional_certificate_arn = aws_acm_certificate_validation.epochregister.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [
    aws_acm_certificate_validation.epochregister
  ]
}

### apigw cdn mapping - API can be attached to a particular path under the registered domain name

resource "aws_api_gateway_base_path_mapping" "epochregister" {
  api_id      = aws_api_gateway_rest_api.epochregister.id
  stage_name  = aws_api_gateway_stage.epochregister.stage_name
  domain_name = aws_api_gateway_domain_name.epochregister.domain_name
}
######################################################################