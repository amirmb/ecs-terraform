data "template_file" "user_data" {
  template = "${file("user_data.sh.tpl")}"

  vars {
    name       = "${var.name}"
    env        = "${var.env}"
    auth_data  = "${var.auth_data}"
    auth_type  = "${var.auth_type}"
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name              = "${var.name}-${var.env}"
  retention_in_days = "${var.log_retention_in_days}"
  kms_key_id        = "${var.kms_key_arn}"

  tags = {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-logs"
    CostCentre    = "${var.cost_centre}"
  }
}

resource "aws_launch_configuration" "launch-configuration" {
  name_prefix          = "${var.name}-${var.env}-launch-config-"
  image_id             = "${var.ami}"
  instance_type        = "${var.instance_type}"
  spot_price           = "${var.spot_price}"
  key_name             = "${var.key_name}"
  security_groups      = ["${aws_security_group.ec2-security-group.id}"]
  iam_instance_profile = "${var.iam_instance_profile}"
  user_data            = "${data.template_file.user_data.*.rendered[count.index]}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
    encrypted   = true
  }
}

resource "aws_autoscaling_group" "autoscaling-group" {
  desired_capacity          = "${var.asg_desired_capacity}"
  launch_configuration      = "${aws_launch_configuration.launch-configuration.id}"
  health_check_grace_period = "${var.grace_period}"
  health_check_type         = "${var.health_check_type}"
  target_group_arns         = ["${var.target_group_arns}"]
  max_size                  = "${var.asg_max_size}"
  min_size                  = "${var.asg_min_size}"
  name                      = "${var.name}-${var.env}-asg"

  vpc_zone_identifier = ["${var.subnets}"]

  lifecycle {
    create_before_destroy = true
  }

  protect_from_scale_in = "${var.protect_from_scale_in}"

  metrics_granularity = "1Minute"

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    value               = "${var.name}-${var.env}-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "${var.owner}"
    propagate_at_launch = true
  }

  tag {
    key                 = "CostCentre"
    value               = "${var.cost_centre}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ApplicationID"
    value               = "${var.application_id}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.env}"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "BackupOptOut"
    value               = "Yes"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_schedule" "asg-schedule-up" {
  count                  = "${var.env != "prod" ? 1 : 0}"
  scheduled_action_name  = "${var.name}-${var.env}-asg-schedule-up"
  min_size               = "${var.asg_min_size}"
  max_size               = "${var.asg_max_size}"
  desired_capacity       = "${var.asg_desired_capacity}"
  recurrence             = "${var.schedule_up}"
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling-group.name}"
}

resource "aws_autoscaling_schedule" "asg-schedule-down" {
  count                  = "${var.env != "prod" ? 1 : 0}"
  scheduled_action_name  = "${var.name}-${var.env}-asg-schedule-down"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "${var.schedule_down}"
  autoscaling_group_name = "${aws_autoscaling_group.autoscaling-group.name}"
}

resource "aws_security_group" "ec2-security-group" {
  name   = "${var.name}-${var.env}-ec2-sg"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.cidr_blocks}"]
  }

  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    security_groups = ["${var.alb_sg_id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_blocks}"]
  }

  ingress {
    from_port   = "${var.target_group_port}"
    to_port     = "${var.target_group_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-ec2-sg"
    CostCentre    = "${var.cost_centre}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
