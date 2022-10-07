output "cdn" {
  value       = aws_api_gateway_domain_name.epochregister.regional_domain_name
  description = "APIGW Custom domain name"
}

output "healthcheckid" {
  value = aws_route53_health_check.epochregister.id
  description = "prints the route53 healthcheckid"
}