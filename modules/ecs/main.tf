resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}-${var.env}-ecs-cluster"

  tags = {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-ecs-cluster"
    CostCentre    = "${var.cost_centre}"
    LoadBalancer  = "${var.alb_dns_name}"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.name}-${var.env}-ecs-task-def"
  container_definitions = "${data.template_file.container_definitions.rendered}"

  volume {
    name = "${var.name}-home"
    host_path = "/ecs/${var.name}-home"
  }

  tags = {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-ecs-task-def"
    CostCentre    = "${var.cost_centre}"
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.name}-${var.env}-ecs-service"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"
  desired_count   = "${var.service_desired_count}"
  iam_role        = "${aws_iam_role.ecs_service_role.arn}"

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }

  depends_on = ["aws_iam_role_policy.ecs_service_role_policy"]
}

resource "aws_iam_role" "ecs_service_role" {
    name = "${var.name}-${var.env}-ecs-service-role"
    assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

force_detach_policies = true
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name = "${var.name}-${var.env}-ecs-service-policy"
    role = "${aws_iam_role.ecs_service_role.name}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

data "template_file" "container_definitions" {
  template = "${file("container_definitions.json.tpl")}"

  vars {
    name              = "${var.name}"
    container_image    = "${var.container_image}"
    container_port    = "${var.container_port}"
  }
}
