resource "aws_sns_topic" "autoscaling" {
  display_name = "${var.name}-${var.env}-autoscaling-sns"
  name         = "${var.name}-${var.env}-autoscaling-sns"

  tags {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-autoscaling-sns"
    CostCentre    = "${var.cost_centre}"
  }
}

resource "aws_sns_topic" "alerting" {
  display_name = "${var.name}-${var.env}-alerting-sns"
  name         = "${var.name}-${var.env}-alerting-sns"

  tags {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-alerting-sns"
    CostCentre    = "${var.cost_centre}"
  }
}

resource "aws_sns_topic" "lifecycle" {
  display_name = "${var.name}-${var.env}-lifecycle-sns"
  name         = "${var.name}-${var.env}-lifecycle-sns"

  tags {
    Environment   = "${var.env}"
    Owner         = "${var.owner}"
    ApplicationID = "${var.application_id}"
    Name          = "${var.name}-${var.env}-lifecycle-sns"
    CostCentre    = "${var.cost_centre}"
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.name}-${var.env}-SNS-Publish-Policy"
  path        = "/"
  description = "Policy for ${var.name} instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.lifecycle.arn}",
      "Action": [
        "sns:Publish"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "logs:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "sns-publish-role" {
  name = "${var.name}-${var.env}-SNS-Publish-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "autoscaling.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam-restriction-policy-attachment" {
  role       = "${aws_iam_role.sns-publish-role.name}"
  policy_arn = "arn:aws:iam::${var.aws_account_id}:policy/IAMRestrictionPolicy"
}

resource "aws_iam_role_policy_attachment" "base-policy-attachment" {
  role       = "${aws_iam_role.sns-publish-role.name}"
  policy_arn = "arn:aws:iam::${var.aws_account_id}:policy/BasePolicy"
}

resource "aws_iam_role_policy_attachment" "restriction-policy-attachment" {
  role       = "${aws_iam_role.sns-publish-role.name}"
  policy_arn = "arn:aws:iam::${var.aws_account_id}:policy/RestrictionPolicy"
}

resource "aws_iam_role_policy_attachment" "sns-policy-attachment" {
  role       = "${aws_iam_role.sns-publish-role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}
