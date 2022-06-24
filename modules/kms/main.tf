resource "aws_kms_key" "kms" {
  description         = "KMS Key for the ${var.name}-${var.env} environment"
  enable_key_rotation = "true"
  policy              =  <<POLICY
  {
    "Version": "2012-10-17",
    "Id": "${var.name}-${var.env}-kms-policy",
    "Statement": [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Effect": "Allow",
        "Principal": { "Service": "logs.${var.aws_region}.amazonaws.com" },
        "Action": [ 
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource": "*"
      }
    ]
  }

POLICY

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_kms_alias" "kms" {
  name          = "alias/${var.name}-${var.env}-kms"
  target_key_id = "${aws_kms_key.kms.key_id}"
}
