resource "aws_lb" "lb" {
  name               = "${var.name}-${var.env}-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = ["${var.subnets}"]
  security_groups    = ["${aws_security_group.alb.id}"]
  idle_timeout       = "${var.idle_timeout}"

  enable_deletion_protection = "${var.alb_deletion_protection}"

  access_logs {
    bucket  = "${var.log_s3_bucket}"
    prefix  = "${var.name}-${var.env}-alb"
    enabled = true
  }

  tags {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-alb"
    CostCentre    = "${var.cost_centre}"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.https_listener_port}"
  protocol          = "HTTPS"
  ssl_policy        = "${var.ssl_policy}"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.lb_tg.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "lb_tg" {
  deregistration_delay = "${var.deregistration_delay}"
  name                 = "${var.name}-${var.env}-alb-tg"
  port                 = "${var.target_group_port}"
  protocol             = "${var.target_group_protocol}"
  target_type          = "${var.target_type}"
  vpc_id               = "${var.vpc_id}"

  stickiness = {
    type            = "lb_cookie"
    cookie_duration = "${var.cookie_duration}"
    enabled         = "${var.stickiness}"
  }

  health_check = {
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    port                = "traffic-port"
    path                = "${var.target_group_path}"
    protocol            = "${var.target_group_protocol}"
  }

  tags {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-tg"
    CostCentre    = "${var.cost_centre}"
  }
}

resource "aws_lb_listener" "http_lb_listener" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.http_listener_port}"
  protocol          = "${var.target_group_protocol}"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "http_lb_listener2" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.target_group_port}"
  protocol          = "${var.target_group_protocol}"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "cname" {
  provider = "aws.dns"
  zone_id  = "${var.zone_id}"
  name     = "${var.fqdn_short}"
  type     = "CNAME"
  ttl      = "300"
  records  = ["${aws_lb.lb.dns_name}"]
}

resource "aws_security_group" "alb" {
  name   = "${var.name}-alb-${var.env}-sg"
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.allow_cidr_blocks}"
  }

  ingress {
    from_port   = "${var.http_listener_port}"
    to_port     = "${var.http_listener_port}"
    protocol    = "tcp"
    cidr_blocks = "${var.allow_cidr_blocks}"
  }

  ingress {
    from_port   = "${var.target_group_port}"
    to_port     = "${var.target_group_port}"
    protocol    = "tcp"
    cidr_blocks = "${var.allow_cidr_blocks}"
  }

  ingress {
    from_port   = "${var.https_listener_port}"
    to_port     = "${var.https_listener_port}"
    protocol    = "tcp"
    cidr_blocks = "${var.allow_cidr_blocks}"
  }

  tags {
    Terraform   = "true"
    Name        = "${var.name}-alb-${var.env}-sg"
    Environment = "${var.env}"
    CostCentre  = "${var.cost_centre}"
  }
}

# resource "aws_cloudwatch_metric_alarm" "alb_active_connections" {
#   alarm_name          = "${var.name}-${var.env}-alb-ActiveConnectionCount"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2

#   dimensions = {
#     LoadBalancer = "${aws_lb.lb.arn_suffix}"
#   }

#   metric_name        = "ActiveConnectionCount"
#   namespace          = "AWS/ApplicationELB"
#   period             = 120
#   statistic          = "Sum"
#   threshold          = "${var.cw_alb_active_connections_threshold}"
#   alarm_description  = "${var.name}-${var.env}-alb - number of connections greater than threshold"
#   alarm_actions      = ["${var.sns_arn}"]
#   treat_missing_data = "ignore"
# }

# resource "aws_cloudwatch_metric_alarm" "alb_4xx_connections" {
#   alarm_name          = "${var.name}-${var.env}-alb-HTTPCode_ELB_4XX_Count"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2

#   dimensions = {
#     LoadBalancer = "${aws_lb.lb.arn_suffix}"
#   }

#   metric_name        = "HTTPCode_ELB_4XX_Count"
#   namespace          = "AWS/ApplicationELB"
#   period             = 120
#   statistic          = "Sum"
#   threshold          = "${var.cw_alb_4xx_connections_threshold}"
#   alarm_description  = "${var.name}-${var.env}-alb - number of 4XX connections greater than threshold"
#   alarm_actions      = ["${var.sns_arn}"]
#   treat_missing_data = "ignore"
# }

# resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_host_count" {
#   alarm_name          = "${var.name}-${var.env}-alb-UnHealthyHostCount"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2

#   dimensions = {
#     LoadBalancer = "${aws_lb.lb.arn_suffix}"
#     TargetGroup  = "${aws_lb_target_group.lb_tg.arn_suffix}"
#   }

#   metric_name        = "HTTPCode_ELB_5XX_Count"
#   namespace          = "AWS/ApplicationELB"
#   period             = 120
#   statistic          = "Average"
#   threshold          = "${var.cw_alb_unhealthy_host_count_threshold}"
#   alarm_description  = "${var.name}-${var.env}-alb - number of unhealthy hosts greater than threshold"
#   alarm_actions      = ["${var.sns_arn}"]
#   treat_missing_data = "ignore"
# }

# resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
#   alarm_name          = "${var.name}-${var.env}-alb-TargetResponseTime"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2

#   dimensions = {
#     LoadBalancer = "${aws_lb.lb.arn_suffix}"
#     TargetGroup  = "${aws_lb_target_group.lb_tg.arn_suffix}"
#   }

#   metric_name        = "TargetResponseTime"
#   namespace          = "AWS/ApplicationELB"
#   period             = 120
#   statistic          = "Average"
#   threshold          = "${var.cw_alb_target_response_time_threshold}"
#   alarm_description  = "${var.name}-${var.env}-alb - target response time greater than threshold"
#   alarm_actions      = ["${var.sns_arn}"]
#   treat_missing_data = "ignore"
# }