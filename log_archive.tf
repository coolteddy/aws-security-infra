resource "aws_s3_bucket" "log_archive" {
  provider = aws.log_archive
  bucket   = var.log_archive_bucket_name

  object_lock_enabled = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "log_archive" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.log_archive.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "log_archive" {
  provider   = aws.log_archive
  bucket     = aws_s3_bucket.log_archive.id
  depends_on = [aws_s3_bucket_versioning.log_archive]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_archive" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.log_archive.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_archive" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.log_archive.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "log_archive" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.log_archive.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.log_archive.arn}/AWSLogs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AllowCloudTrailBucketCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.log_archive.arn
      },
      # POC teardown: these six Config statements were active while sandbox
      # Config delivery existed. They are kept commented as documentation so
      # the original cross-account policy can be restored if Config returns.
      # {
      #   Sid       = "AllowConfigServiceBucketCheck"
      #   Effect    = "Allow"
      #   Principal = { Service = "config.amazonaws.com" }
      #   Action    = "s3:GetBucketAcl"
      #   Resource  = aws_s3_bucket.log_archive.arn
      #   Condition = { StringEquals = { "AWS:SourceAccount" = var.sandbox_account_id } }
      # },
      # {
      #   Sid       = "AllowConfigServiceListBucket"
      #   Effect    = "Allow"
      #   Principal = { Service = "config.amazonaws.com" }
      #   Action    = "s3:ListBucket"
      #   Resource  = aws_s3_bucket.log_archive.arn
      #   Condition = { StringEquals = { "AWS:SourceAccount" = var.sandbox_account_id } }
      # },
      # {
      #   Sid       = "AllowConfigServiceWrite"
      #   Effect    = "Allow"
      #   Principal = { Service = "config.amazonaws.com" }
      #   Action    = "s3:PutObject"
      #   Resource  = "${aws_s3_bucket.log_archive.arn}/AWSLogs/${var.sandbox_account_id}/Config/*"
      #   Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control", "AWS:SourceAccount" = var.sandbox_account_id } }
      # },
      # {
      #   Sid       = "AllowConfigRoleBucketCheck"
      #   Effect    = "Allow"
      #   Principal = { AWS = "arn:aws:iam::${var.sandbox_account_id}:role/sandbox-config-recorder-role" }
      #   Action    = "s3:GetBucketAcl"
      #   Resource  = aws_s3_bucket.log_archive.arn
      # },
      # {
      #   Sid       = "AllowConfigRoleListBucket"
      #   Effect    = "Allow"
      #   Principal = { AWS = "arn:aws:iam::${var.sandbox_account_id}:role/sandbox-config-recorder-role" }
      #   Action    = "s3:ListBucket"
      #   Resource  = aws_s3_bucket.log_archive.arn
      # },
      # {
      #   Sid       = "AllowConfigRoleWrite"
      #   Effect    = "Allow"
      #   Principal = { AWS = "arn:aws:iam::${var.sandbox_account_id}:role/sandbox-config-recorder-role" }
      #   Action    = "s3:PutObject"
      #   Resource  = "${aws_s3_bucket.log_archive.arn}/AWSLogs/${var.sandbox_account_id}/Config/*"
      # },
      {
        Sid       = "DenyDelete"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:DeleteBucket"
        ]
        Resource = [
          aws_s3_bucket.log_archive.arn,
          "${aws_s3_bucket.log_archive.arn}/*"
        ]
      }
    ]
  })
}
