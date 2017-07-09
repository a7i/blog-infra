# region for globally unique resources like state bucket
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

resource "aws_s3_bucket" "state" {
  tags     = "${merge(var.tags, map("Name", "ltd-terraform-state"))}"
  provider = "aws.us-east-1"
  bucket   = "ltd-terraform-state"
  acl      = "private"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "PutObjPolicy",
    "Statement": [
        {
            "Sid": "DenyIncorrectEncryptionHeader",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::blog-terraform-state/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": "AES256"
                }
            }
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::blog-terraform-state/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        }
    ]
}
EOF

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
