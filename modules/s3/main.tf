resource "aws_s3_bucket" "logs" {
  bucket = "${var.aws_account_id}-${var.name}-${var.env}-logs"
  acl    = "log-delivery-write"
  region = "${var.aws_region}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Terraform   = "true"
    Name        = "${var.aws_account_id}-${var.name}-${var.env}-logs"
    Environment = "${var.env}"
    CostCentre  = "${var.cost_centre}"
    Owner       = "${var.owner}"
    Account     = "${var.aws_profile}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = "${var.aws_account_id}-${var.name}-${var.env}-logs"
    target_prefix = "log/"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = "${aws_s3_bucket.logs.id}"

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = "${aws_s3_bucket.logs.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "${var.name}-${var.env}-logs-s3-policy",
    "Statement": [
        {
          "Sid": "DenyDeleteBucket",
          "Effect": "Deny",
          "Principal": "*",
         "Action": "s3:DeleteBucket",
         "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.name}-${var.env}-logs"
        },
        {
          "Sid": "AdminFolder",
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${var.aws_account_id}:role/AdminRole"
          },
          "Action": "s3:*",
          "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.name}-${var.env}-logs/admin_folder/*"
        },
        {
          "Sid": "PublicConstraint",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.name}-${var.env}-logs/*",
          "Condition": {
            "StringEquals": {
               "s3:x-amz-acl": [
                 "public-read",
                 "public-read-write"
               ]
            }
          }
        },
        {
          "Sid": "DenyHTTPAccess",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.name}-${var.env}-logs/*",
          "Condition": {
            "Bool": {
              "aws:SecureTransport": "false"
            }
          }
        },
        {
            "Sid": "AWSLogWritePrincipal",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::783225319266:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.name}-${var.env}-logs/*"
        },
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                  "logs.ap-southeast-2.amazonaws.com",
                  "delivery.logs.amazonaws.com"
                ]
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.name}-${var.env}-logs/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                   "logs.ap-southeast-2.amazonaws.com",
                   "delivery.logs.amazonaws.com"
                   ]
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.aws_account_id}-${var.name}-${var.env}-logs"
        }
    ]
}

POLICY
}
