module "common" {
  source = "../../common"
}

module "kms" {
  source = "../../modules/kms"

  aws_account_id = "${var.aws_account_id}"
  aws_region     = "${var.aws_region}"
  env            = "${var.env}"
  name           = "${var.application_name}"
}

module "sns" {
  source = "../../modules/sns"

  aws_account_id = "${var.aws_account_id}"
  application_id = "${var.application_id}"
  cost_centre    = "${var.cost_centre}"
  env            = "${var.env}"
  name           = "${var.application_name}"
  owner          = "${var.owner}"
}

module "s3" {
  source = "../../modules/s3"

  aws_region     = "${var.aws_region}"
  aws_profile    = "${var.aws_profile}"
  aws_account_id = "${var.aws_account_id}"
  cost_centre    = "${var.cost_centre}"
  env            = "${var.env}"
  name           = "${var.application_name}"
  owner          = "${var.owner}"
}
