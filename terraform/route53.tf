//resource "aws_route53_zone" "primary" {
//  name = var.zone_name
//  tags = {
//    Name = var.zone_name
//  }
//  force_destroy = false
//}
//
//## Add data source ##
//data "aws_elb_hosted_zone_id" "this" {}
//### This will use your aws provider-level region config otherwise mention explicitly.
//
//resource "aws_route53_record" "backend_record" {
//  zone_id = aws_route53_zone.primary.zone_id
//  name    = var.host_name
//  type    = "A"
//  alias {
//    name                   = kubernetes_service.helios-fhir-server.status.0.load_balancer.0.ingress.0.hostname
//    zone_id                = data.aws_elb_hosted_zone_id.this.id ## Updated ##
//    evaluate_target_health = true
//  }
//}
