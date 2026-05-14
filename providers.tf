provider "aws" {
  alias  = "management"
  region = var.region

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "log_archive"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.log_archive_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  alias  = "audit"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.audit_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = var.tags
  }
}
