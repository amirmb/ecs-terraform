module "alb" {
  source = "../../modules/alb"

  allow_cidr_blocks                     = "${var.alb_allow_cidr_blocks}"
  application_id                        = "${var.application_id}"
  aws_profile                           = "${var.aws_profile}"
  certificate_arn                       = "${var.certificate_arn}"
  ssl_policy                            = "${var.ssl_policy}"
  cookie_duration                       = "${var.alb_cookie_duration}"
  stickiness                            = "${var.alb_stickiness}"
  cost_centre                           = "${var.cost_centre}"
  cw_alb_active_connections_threshold   = "${var.cw_alb_active_connections_threshold}"
  cw_alb_4xx_connections_threshold      = "${var.cw_alb_4xx_connections_threshold}"
  cw_alb_rejected_connections_threshold = "${var.cw_alb_rejected_connections_threshold}"
  cw_alb_unhealthy_host_count_threshold = "${var.cw_alb_unhealthy_host_count_threshold}"
  cw_alb_target_response_time_threshold = "${var.cw_alb_target_response_time_threshold}"
  deregistration_delay                  = "${var.alb_deregistration_delay}"
  dns_role_arn                          = "${var.dns_role_arn}"
  env                                   = "${var.env}"
  alb_deletion_protection               = "${var.alb_deletion_protection}"
  target_type                           = "${var.alb_target_type}"
  target_group_port                     = "${var.alb_target_group_port}"
  target_group_path                     = "${var.alb_target_group_path}"
  target_group_protocol                 = "${var.alb_target_group_protocol}"
  fqdn_short                            = "${var.fqdn_short}.${var.account_prefix}"
  idle_timeout                          = "${var.alb_idle_timeout}"
  http_listener_port                    = "${var.http_listener_port}"
  https_listener_port                   = "${var.https_listener_port}"
  https_listener_protocol               = "${var.https_listener_protocol}"
  name                                  = "${var.application_name}"
  owner                                 = "${var.owner}"
  aws_region                            = "${var.aws_region}"
  sns_arn                               = "${data.aws_sns_topic.alerting.arn}"
  log_s3_bucket                         = "${data.aws_s3_bucket.logs.bucket}"

  subnets = [
    "${data.aws_subnet.tooling-a.id}",
    "${data.aws_subnet.tooling-b.id}",
    "${data.aws_subnet.tooling-c.id}",
  ]

  vpc_id  = "${data.aws_vpc.tooling.id}"
  zone_id = "${var.dns_zone_id}"
}

module "asg" {
  source = "../../modules/asg"

  env            = "${var.env}"
  name           = "${var.application_name}"
  owner          = "${var.owner}"
  cost_centre    = "${var.cost_centre}"
  application_id = "${var.application_id}"


  ami                   = "${data.aws_ami.ami.id}"
  key_name              = "${var.key_name}"
  spot_price            = "${var.spot_price}"
  kms_key_arn           = "${data.terraform_remote_state.base.kms_key_arn}"
  schedule_up           = "${var.schedule_up}"
  schedule_down         = "${var.schedule_down}"
  asg_max_size          = "${var.asg_max_size}"
  asg_min_size          = "${var.asg_min_size}"
  grace_period          = "${var.grace_period}"
  instance_type         = "${var.instance_type}"
  auth_data             = "${data.aws_ssm_parameter.auth_data.value}"
  auth_type             = "${var.auth_type}"
  root_volume_type      = "${var.root_volume_type}"
  root_volume_size      = "${var.root_volume_size}"
  health_check_type     = "${var.health_check_type}"
  target_group_port     = "${var.alb_target_group_port}"
  iam_instance_profile  = "${var.iam_instance_profile}"
  asg_desired_capacity  = "${var.asg_desired_capacity}"
  protect_from_scale_in = "${var.protect_from_scale_in}"
  log_retention_in_days = "${var.log_retention_in_days}"

  domain_name = "${var.domain_name}"
  fqdn_short  = "${var.fqdn_short}"
  vpc_id      = "${data.aws_vpc.tooling.id}"

  cidr_blocks = [
    "${data.aws_subnet.private-a.cidr_block}",
    "${data.aws_subnet.private-b.cidr_block}",
    "${data.aws_subnet.private-c.cidr_block}",
    "${data.aws_subnet.tooling-a.cidr_block}",
    "${data.aws_subnet.tooling-b.cidr_block}",
    "${data.aws_subnet.tooling-c.cidr_block}"
  ]

  target_group_arns = []
  alb_sg_id         = "${module.alb.sg_id}"

  subnets = [
    "${data.aws_subnet.tooling-a.id}",
    "${data.aws_subnet.tooling-b.id}",
    "${data.aws_subnet.tooling-c.id}",
  ]

}

module "ecs" {
  source = "../../modules/ecs"

  owner                 = "${var.owner}"
  aws_region            = "${var.aws_region}"
  target_group_arn      = "${module.alb.tg_arn}"
  container_name        = "${var.container_name}"
  container_image       = "${var.container_image}"
  container_port        = "${var.container_port}"
  asg_arn               = "${module.asg.asg_arn}"
  name                  = "${var.application_name}"
  env                   = "${var.env}"
  application_id        = "${var.application_id}"
  service_desired_count = "${var.service_desired_count}"
  cost_centre           = "${var.cost_centre}"
  alb_dns_name          = "${module.alb.dns_name}"
  host_port             = "${var.host_port}"
}
