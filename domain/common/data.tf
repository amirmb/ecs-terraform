data "aws_vpc" "tooling" {
  filter {
    name   = "tag:Name"
    values = ["${var.tooling_subnet_vpc}"]
  }
}

data "aws_vpc" "private" {
  filter {
    name   = "tag:Name"
    values = ["${var.private_vpc}"]
  }
}

data "aws_subnet" "private-a" {
  filter {
    name   = "tag:Name"
    values = ["${var.private_subnet}-a"]
  }
}

data "aws_subnet" "private-b" {
  filter {
    name   = "tag:Name"
    values = ["${var.private_subnet}-b"]
  }
}

data "aws_subnet" "private-c" {
  filter {
    name   = "tag:Name"
    values = ["${var.private_subnet}-c"]
  }
}

data "aws_subnet" "tooling-a" {
  filter {
    name   = "tag:Name"
    values = ["${var.tooling_subnet}-a"]
  }
}

data "aws_subnet" "tooling-b" {
  filter {
    name   = "tag:Name"
    values = ["${var.tooling_subnet}-b"]
  }
}

data "aws_subnet" "tooling-c" {
  filter {
    name   = "tag:Name"
    values = ["${var.tooling_subnet}-c"]
  }
}

data "aws_ssm_parameter" "auth_data" {
  name = "S{docker-registry-auth-data}"
}

data "aws_ami" "ami" {
  owners           = ["self", "${var.aws_account_id}"]
  most_recent      = true

  name_regex = "amazon-ecs-ami-*"

  filter {
    name   = "name"
    values = ["amazon-ecs-ami-*"]
  }

  filter {
    name   = "tag:Branch"
    values = ["${var.branch}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

}

# The attribute `${data.aws_caller_identity.current.account_id}` will be current account number.
data "aws_caller_identity" "current" {}

# The attribue `${data.aws_iam_account_alias.current.account_alias}` will be current account alias
data "aws_iam_account_alias" "current" {}

# The attribute `${data.aws_region.current.name}` will be current region
data "aws_region" "current" {}

# Set as [local values](https://www.terraform.io/docs/configuration/locals.html)
locals {
  account_id    = data.aws_caller_identity.current.account_id
  account_alias = data.aws_iam_account_alias.current.account_alias
  region        = data.aws_region.current.name
}
