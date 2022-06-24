output "kms_key_id" {
  value = "${module.kms.kms_key_id}"
}
output "kms_key_arn" {
  value = "${module.kms.kms_key_arn}"
}
output "sns_arn" {
  value = "${module.sns.sns_arn}"
}
