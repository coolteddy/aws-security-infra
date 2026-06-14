resource "aws_guardduty_detector" "audit" {
  provider = aws.audit
  enable   = false
}

# POC teardown: the audit account was the GuardDuty delegated administrator,
# and organization members were initially auto-enrolled with "ALL". Member
# monitoring was stopped and members were disassociated before removing these
# organization-level resources. Restore both blocks to re-enable delegation.
# resource "aws_guardduty_organization_admin_account" "audit" {
#   provider         = aws.management
#   admin_account_id = var.audit_account_id
#
#   depends_on = [aws_guardduty_detector.audit]
# }
#
# resource "aws_guardduty_organization_configuration" "audit" {
#   provider    = aws.audit
#   detector_id = aws_guardduty_detector.audit.id
#
#   auto_enable_organization_members = "ALL"
#
#   depends_on = [aws_guardduty_organization_admin_account.audit]
# }
