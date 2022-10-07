## Provides a Route53 health check.

resource "aws_route53_health_check" "epochregister" {
  fqdn              = "${aws_api_gateway_rest_api.epochregister.id}.execute-api.${var.aws_region}.amazonaws.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/prod/health"
  failure_threshold = "2"
  request_interval  = "10"
  tags = {
    Name = "epoch-health-check"
  }

  depends_on = [
    aws_api_gateway_base_path_mapping.epochregister
  ]
}
#####################################