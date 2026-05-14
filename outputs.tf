output "log_archive_bucket_name" {
  description = "Name of the log-archive S3 bucket."
  value       = aws_s3_bucket.log_archive.id
}

output "log_archive_bucket_arn" {
  description = "ARN of the log-archive S3 bucket."
  value       = aws_s3_bucket.log_archive.arn
}

output "log_archive_bucket_region" {
  description = "AWS region where the log-archive S3 bucket is managed."
  value       = var.region
}
