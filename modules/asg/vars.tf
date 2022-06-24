variable "name" {}
variable "env" {}
variable "owner" {}
variable "cost_centre" {}
variable "application_id" {}
variable "domain_name" {}
variable "fqdn_short" {}
variable "instance_type" {}
variable "ami" {}
variable "key_name" {}
variable "spot_price" {}
variable "kms_key_arn" {}
variable "iam_instance_profile" {}
variable "root_volume_type" {}
variable "root_volume_size" {}
variable "protect_from_scale_in" {}
variable "asg_desired_capacity" {}
variable "asg_max_size" {}
variable "asg_min_size" {}
variable "schedule_up" {}
variable "schedule_down" {}
variable "health_check_type" {}
variable "grace_period" {}

variable "target_group_port" {}
variable "log_retention_in_days" {}
variable "vpc_id" {}
variable "auth_data" {}
variable "auth_type" {}

variable "subnets" {
    type = "list"
}
variable "cidr_blocks" {
    type = "list"
}
variable "target_group_arns" {
    type = "list"
}
variable "alb_sg_id" {}

