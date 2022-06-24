provider "aws" {
  region   = local.region
  profile  = "${var.aws_profile}"
  insecure = "true"
  version  = "~> 2.8"

  assume_role {
    role_arn = "${var.base_iam_role_arn}"
  }
}
