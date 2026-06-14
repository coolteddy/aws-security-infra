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

output "cloudtrail_name" {
  description = "Name of the organization CloudTrail."
  value       = aws_cloudtrail.org.name
}

output "cloudtrail_arn" {
  description = "ARN of the organization CloudTrail."
  value       = aws_cloudtrail.org.arn
}

output "guardduty_audit_detector_id" {
  description = "GuardDuty detector ID in the audit account."
  value       = aws_guardduty_detector.audit.id
}

# POC teardown: restore this output with aws_securityhub_account.audit.
# output "securityhub_audit_account_enabled" {
#   description = "Security Hub account resource ID in the audit account."
#   value       = aws_securityhub_account.audit.id
# }
