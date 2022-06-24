output "tg_arn" {
  value = "${aws_lb_target_group.lb_tg.arn}"
}

output "sg_id" {
  value = "${aws_security_group.alb.id}"
}

output "tg_name" {
  value = "${aws_lb_target_group.lb_tg.name}"
}

output "dns_name" {
  value = "${aws_lb.lb.dns_name}"
}

output "fqdn" {
  value = "${aws_route53_record.cname.fqdn}"
}

output "arn_suffix" {
  value = "${aws_lb.lb.arn_suffix}"
}

