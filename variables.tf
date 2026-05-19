variable "region" {
  description = "AWS region for security infrastructure."
  type        = string
  default     = "eu-west-2"
}

variable "management_account_id" {
  description = "Management AWS account ID. Used by workflows and future management-account resources."
  type        = string
  sensitive   = true
}

variable "log_archive_account_id" {
  description = "Log-archive AWS account ID. Used only to build the provider assume-role ARN."
  type        = string
  sensitive   = true
}

variable "audit_account_id" {
  description = "Audit AWS account ID. Used to build the provider assume-role ARN and future delegated admin configuration."
  type        = string
  sensitive   = true
}

variable "sandbox_account_id" {
  description = "Sandbox AWS account ID. Used to scope Config cross-account delivery bucket policy."
  type        = string
  sensitive   = true
}

variable "log_archive_bucket_name" {
  description = "S3 bucket name for organization security logs."
  type        = string
  default     = "loadberry-log-archive-eu-west-2"
}

variable "cloudtrail_name" {
  description = "Organization CloudTrail name."
  type        = string
  default     = "loadberry-org-trail"
}

variable "tags" {
  description = "Default tags applied to security infrastructure resources."
  type        = map(string)
  default = {
    Project     = "aws-security-infra"
    ManagedBy   = "terraform"
    Environment = "security"
  }
}
