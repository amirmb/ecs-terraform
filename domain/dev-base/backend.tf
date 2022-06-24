terraform {
  backend "s3" {
    bucket  = "123456789-terraform-states"
    key     = "dev/base/terraform.tfstate"
    region  = "ap-southeast-2"
    encrypt = "true"
    dynamodb_table = "terraform-lock"
  }
}
