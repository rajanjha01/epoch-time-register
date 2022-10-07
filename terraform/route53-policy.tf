##import the traffic policy saved locally

data "local_file" "epoch-traffick" {
    filename = "./route53-policy.json"
}

##create route53 traffick policy for weighted routing

resource "aws_route53_traffic_policy" "epoch-traffic" {
  name     = "epoch-traffic-policy"
  comment  = "epoch-traffic-policy"
  document = data.local_file.epoch-traffick.content
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