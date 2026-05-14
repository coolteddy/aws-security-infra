resource "aws_guardduty_detector" "audit" {
  provider = aws.audit
  enable   = true
}

resource "aws_guardduty_organization_admin_account" "audit" {
  provider         = aws.management
  admin_account_id = var.audit_account_id

  depends_on = [aws_guardduty_detector.audit]
}

resource "aws_guardduty_organization_configuration" "audit" {
  provider                         = aws.audit
  detector_id                      = aws_guardduty_detector.audit.id
  auto_enable_organization_members = "ALL"

  depends_on = [aws_guardduty_organization_admin_account.audit]
}
