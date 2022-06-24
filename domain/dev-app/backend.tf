terraform {
  backend "s3" {
    bucket  = "${var.config_bucket}"
    key     = "dev/app/terraform.tfstate"
    region  = "${var.region}"
    encrypt = "true"
  }
}
