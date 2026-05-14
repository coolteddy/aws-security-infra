resource "aws_cloudtrail" "org" {
  provider = aws.management

  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.log_archive.id
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
}
