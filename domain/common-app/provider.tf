provider "aws" {
  region   = "${var.aws_region}"
  profile  = "${var.aws_profile}"
  insecure = "true"
  version  = "~> 2.8"

  assume_role {
    role_arn = "${var.provision_iam_role_arn}"
  }
}
