output "sns_arn" {
  value = "${aws_sns_topic.alerting.arn}"
}

output "lifecycle_sns_arn" {
  value = "${aws_sns_topic.lifecycle.arn}"
}
