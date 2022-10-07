##import the traffic policy saved locally
/*
data "local_file" "epoch-traffick" {
  filename = "./route53-policy.json"
}
*/

## import the template file
data "local_file" "policy_template" {
  filename = "./policy.json.tmpl"
} 

## update the template with dynamic values

data "template_file" "policy_updated" {
  template = data.local_file.policy_template.content
  vars = {
    cdn1 = module.frontend_us-east-1.cdn
    cdn2 = module.frontend_us-west-2.cdn
    healthcheck1 = module.frontend_us-east-1.healthcheckid
    healthcheck2 = module.frontend_us-west-2.healthcheckid
  }
}

resource "local_file" "traffic_policy" {
    content     = data.template_file.policy_updated.rendered
    filename = "./traffic-policy.json"
}

##create route53 traffick policy for weighted routing

resource "aws_route53_traffic_policy" "epoch-traffic" {
  name     = "epoch-traffic-policy"
  comment  = "epoch-traffic-policy"
  document = local_file.traffic_policy.content

  lifecycle {
    create_before_destroy = true
  }

}
## get the hosted zone
data "aws_route53_zone" "epochregister" {
  name         = "epochregister.click."
  private_zone = false
}
## create policy record for the policy

resource "aws_route53_traffic_policy_instance" "epochregister" {
  name                   = "api.epochregister.click"
  traffic_policy_id      = aws_route53_traffic_policy.epoch-traffic.id
  traffic_policy_version = 1
  hosted_zone_id         = data.aws_route53_zone.epochregister.zone_id
  ttl                    = 360
  depends_on = [
    aws_route53_traffic_policy.epoch-traffic
  ]
}
######################################