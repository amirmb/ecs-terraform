terraform {
  backend "s3" {
    bucket  = "${var.config_bucket}"
    key     = "dev/rds/terraform.tfstate"
    region  = "${var.region}"
    encrypt = "true"
  }
}
