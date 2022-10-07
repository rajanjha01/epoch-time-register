######################################## CW Alarms FOR epoch apigw ###################################################

###################################

##API Count in APIGW - Disabling it as its flodding in my email
/*
resource "aws_cloudwatch_metric_alarm" "epoch_apigw_api_count" {
  alarm_name                = "API Count SUM in EPOCH APIGW prod  env"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "5"
  alarm_description         = "No of API requests is breaching the threshold of 5 or the APIGW Data is missing"
  datapoints_to_alarm       = 1
  insufficient_data_actions = []
  treat_missing_data        = "breaching"
  metric_name = "Count"
  namespace   = "AWS/ApiGateway"
  period      = "300"
  statistic   = "Sum"
  unit        = "Count"
  dimensions = {
        ApiName = "${var.epoch-apigw}-API"
      }
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.epoch-prod.arn]
  ok_actions          = [aws_sns_topic.epoch-prod.arn]

}

##APIGW Latency

resource "aws_cloudwatch_metric_alarm" "epoch_apigw_latency" {
  alarm_name                = "API Latency SUM in EPOCH APIGW prod  env"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "3"
  threshold                 = "400"
  alarm_description         = "API Latency is breaching the threshold "
  datapoints_to_alarm       = 1
  insufficient_data_actions = []
  treat_missing_data        = "breaching"
  metric_name = "Latency"
  namespace   = "AWS/ApiGateway"
  period      = "300"
  statistic   = "Sum"
  unit        = "Milliseconds"
  dimensions = {
        ApiName = "${var.epoch-apigw}-API"
      }
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.epoch-prod.arn]
  ok_actions          = [aws_sns_topic.epoch-prod.arn]

}

##APIGW 4XX Errors

resource "aws_cloudwatch_metric_alarm" "epoch_apigw_4xx" {
  alarm_name                = "SUM of 4xx Errors in EPOCH APIGW prod  env"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "5"
  alarm_description         = "Sum of 4xx Errors is breaching the threshold "
  datapoints_to_alarm       = 1
  insufficient_data_actions = []
  treat_missing_data        = "breaching"
  metric_name = "4XXError"
  namespace   = "AWS/ApiGateway"
  period      = "300"
  statistic   = "Sum"
  unit        = "Count"
  dimensions = {
        ApiName = "${var.epoch-apigw}-API"
      }
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.epoch-prod.arn]
  ok_actions          = [aws_sns_topic.epoch-prod.arn]

}

##APIGW 5XX Errors

resource "aws_cloudwatch_metric_alarm" "epoch_apigw_5xx" {
  alarm_name                = "SUM of 5xx Errors in EPOCH APIGW prod  env"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  threshold                 = "5"
  alarm_description         = "Sum of 5xx Errors is breaching the threshold "
  datapoints_to_alarm       = 1
  insufficient_data_actions = []
  treat_missing_data        = "breaching"
  metric_name = "5XXError"
  namespace   = "AWS/ApiGateway"
  period      = "300"
  statistic   = "Sum"
  unit        = "Count"
  dimensions = {
        ApiName = "${var.epoch-apigw}-API"
      }
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.epoch-prod.arn]
  ok_actions          = [aws_sns_topic.epoch-prod.arn]

}
############################################################

*/
#############
## CW Alarm for route53 health check- It is available only in us-east-1. The alarm will get created in 
## us-west-2 as well but integration is not possible as route53 metrics are not available in any other region. 
## More on https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/monitoring-health-checks.html

resource "aws_cloudwatch_metric_alarm" "epoch-health-status" {
  alarm_name          = "epoch-health-status"
  namespace           = "AWS/Route53"
  metric_name         = "HealthCheckStatus"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  unit                = "None"
  dimensions = {
    HealthCheckId = "${aws_route53_health_check.epochregister.id}"
  }
  actions_enabled           = "true"
  alarm_description         = "This metric monitors whether the epoch apigw endpoint is down or not."
  alarm_actions             = [aws_sns_topic.epoch-prod.arn]
  insufficient_data_actions = [aws_sns_topic.epoch-prod.arn]
  ok_actions                = [aws_sns_topic.epoch-prod.arn]
  treat_missing_data        = "breaching"
  depends_on                = [aws_route53_health_check.epochregister]
}

############################################################
