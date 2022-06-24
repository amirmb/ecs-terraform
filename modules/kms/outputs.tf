output "kms_key_id" {
  value = "${aws_kms_key.kms.key_id}"
}

output "kms_key_arn" {
  value = "${aws_kms_key.kms.arn}"
}

output "kms_alias_arn" {
  value = "${aws_kms_alias.kms.arn}"
}

output "kms_alias_target_key_arn" {
  value = "${aws_kms_alias.kms.target_key_arn}"
}
