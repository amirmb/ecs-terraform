provider "aws" {
  alias    = "dns"
  region   = "${var.aws_region}"
  profile  = "${var.aws_profile}"
  insecure = "true"

  assume_role {
    role_arn = "${var.dns_role_arn}"
  }
}
