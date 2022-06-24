output "alb_fqdn" {
  value = "${module.alb.fqdn}"
}
output "alb_dns_name" {
  value = "${module.alb.dns_name}"
}
output "alb_arn_suffix" {
  value = "${module.alb.arn_suffix}"
}
output "ecs_cluster_arn" {
  value = "${module.ecs.cluster_arn}"
}
