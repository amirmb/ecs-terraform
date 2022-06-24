variable "aws_region" {}
variable "aws_profile" {}
variable "dns_role_arn" {}
variable "name" {}
variable "env" {}
variable "owner" {}
variable "application_id" {}
variable "cost_centre" {}
variable "target_group_port" {}
variable "target_group_protocol" {}
variable "target_group_path" {}
variable "certificate_arn" {}
variable "ssl_policy" {}
variable "fqdn_short" {}
variable "target_type" {}
variable "vpc_id" {}
variable "zone_id" {}
variable "stickiness" {}
variable "cookie_duration" {}
variable "alb_deletion_protection" {}
variable "subnets" {
  type = "list"
}
variable "sns_arn" {}

variable "allow_cidr_blocks" {
  type = "list"
}
variable "cw_alb_active_connections_threshold" {
  default = "40"
}

variable "cw_alb_4xx_connections_threshold" {
  default = "10"
}

variable "cw_alb_rejected_connections_threshold" {
  default = "10"
}

variable "cw_alb_unhealthy_host_count_threshold" {
  default = "1"
}

variable "cw_alb_target_response_time_threshold" {
  default = "10"
}

variable "deregistration_delay" {
  default = "300"
}

variable "https_listener_port" {}
variable "https_listener_protocol" {}
variable "http_listener_port" {}
variable "idle_timeout" {}
variable "log_s3_bucket" {}
