output "API_DOMAIN_NAME" {
  value       = aws_api_gateway_domain_name.epochregister.regional_domain_name
  description = "Custom domain name"
}
