##data block to get the route53 hosted zone

data "aws_route53_zone" "epochregister" {
  name         = "epochregister.click."
  private_zone = false
}

####Resource: aws_acm_certificate
### Alternative Domains DNS Validation with Route 53 
// request a DNS validated certificate, deploy the required validation records and wait for validation to complete.
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation

resource "aws_acm_certificate" "epochregister" {
  domain_name       = "api.epochregister.click"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
  Name = "epochregister"
  }
}

resource "aws_route53_record" "epochregister" {
  for_each = {
    for dvo in aws_acm_certificate.epochregister.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.epochregister.zone_id
}

resource "aws_acm_certificate_validation" "epochregister" {
  certificate_arn         = aws_acm_certificate.epochregister.arn
  validation_record_fqdns = [for record in aws_route53_record.epochregister : record.fqdn]
}
######################################

