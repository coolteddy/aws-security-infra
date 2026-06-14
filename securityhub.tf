# POC teardown: Security Hub was enabled in the audit account as the
# organization delegated administrator with CIS and AWS Foundational standards.
# Restore these blocks when centralized Security Hub monitoring is required.
# resource "aws_securityhub_account" "audit" {
#   provider = aws.audit
# }
#
# resource "aws_securityhub_organization_admin_account" "audit" {
#   provider         = aws.management
#   admin_account_id = var.audit_account_id
#
#   depends_on = [aws_securityhub_account.audit]
# }
#
# resource "aws_securityhub_standards_subscription" "cis" {
#   provider      = aws.audit
#   standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
#
#   depends_on = [aws_securityhub_account.audit]
# }
#
# resource "aws_securityhub_standards_subscription" "aws_foundational" {
#   provider      = aws.audit
#   standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
#
#   depends_on = [aws_securityhub_account.audit]
# }

# POC teardown: sandbox was explicitly associated with the audit delegated
# administrator so cross-account findings could be validated. Keeping the
# resource commented documents the tested relationship while Terraform removes it.
# resource "aws_securityhub_member" "sandbox" {
#   provider   = aws.audit
#   account_id = var.sandbox_account_id
#   invite     = false
#
#   depends_on = [
#     aws_securityhub_organization_admin_account.audit
#   ]
# }
