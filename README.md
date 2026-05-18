# aws-security-infra

Terraform for the AWS security accounts used by the Loadberry POC.

This repo manages two accounts in the Security OU:

- `log-archive` — immutable audit log storage (S3 Object Lock, CloudTrail destination)
- `audit` — security monitoring hub (GuardDuty + Security Hub delegated admin)

---

## Prerequisites

Both accounts must exist in AWS Organizations before applying anything here.
Account creation is managed by `aws-org-infra/2-organisation/accounts.tf`.

The GitHub Actions OIDC gateway role (`github-actions-aws-security-infra`) must also exist.
It is defined in `aws-org-infra/2-organisation/github_oidc.tf` — one role with access to
both log-archive and audit accounts.

### One-time manual CLI setup — org trusted service access

Before the first apply, enable trusted service access for all three security services.
This cannot be done via Terraform because the org is a `data` source (pre-existing),
not a managed resource. Run once from the management account:

```bash
aws organizations enable-aws-service-access \
  --service-principal cloudtrail.amazonaws.com \
  --profile setnay-admin

aws organizations enable-aws-service-access \
  --service-principal guardduty.amazonaws.com \
  --profile setnay-admin

aws organizations enable-aws-service-access \
  --service-principal securityhub.amazonaws.com \
  --profile setnay-admin
```

Verify in the AWS console: **Organizations → Services** — all three should show **Enabled**.

Without this, CloudTrail fails with `CloudTrailAccessNotEnabledException` and GuardDuty/Security Hub
delegation fails with `BadRequestException`.

---

## Build order — two rounds

The build is intentionally split. The log-archive S3 bucket must exist before CloudTrail,
GuardDuty, and Security Hub are wired up. The sandbox Config delivery channel also depends
on this bucket existing.

### Round 1 — log-archive foundation (apply first)

```
log_archive.tf    S3 bucket + Object Lock GOVERNANCE + versioning + SSE + bucket policy
```

Stop after Round 1. Confirm the bucket exists before proceeding.

### Round 2 — security services (after bucket confirmed)

```
cloudtrail.tf     Org-level CloudTrail → log-archive S3 (management events only — free)
guardduty.tf      GuardDuty delegated admin → audit account + auto-enrol all org accounts
securityhub.tf    Security Hub delegated admin → audit account + CIS + AWS Foundational standards
```

---

## File structure

```
aws-security-infra/
├── versions.tf              Terraform + provider version constraints
├── providers.tf             Three provider aliases: management, log_archive, audit
├── backend.tf               S3 backend in management account
├── variables.tf             Account IDs, region, tags (no sensitive defaults)
├── outputs.tf               Bucket ARN, CloudTrail ARN, detector IDs
├── terraform.tfvars.example Placeholder values — copy to terraform.tfvars locally
│
├── log_archive.tf           Round 1 — S3 bucket + Object Lock + bucket policy
├── cloudtrail.tf            Round 2 — org-level CloudTrail
├── guardduty.tf             Round 2 — GuardDuty delegated admin
└── securityhub.tf           Round 2 — Security Hub delegated admin
```

---

## S3 Object Lock

Object Lock must be enabled at bucket creation time — it cannot be added later.

```hcl
object_lock_enabled = true
```

This POC uses `GOVERNANCE` mode with 7-day retention:

```hcl
mode = "GOVERNANCE"
days = 7
```

`GOVERNANCE` mode prevents normal deletes during the retention period but can be bypassed
by a principal with `s3:BypassGovernanceRetention`. This allows cleanup after the POC.

`COMPLIANCE` mode is stronger — no principal including root can delete objects before
retention expires. **Never switch this POC repo to COMPLIANCE mode** — cleanup becomes
impossible until the retention period expires on every object.

---

## GuardDuty delegated admin

The audit account needs its own GuardDuty detector because it becomes the GuardDuty
delegated administrator for the organization. That detector is the control point used
to manage organization configuration and aggregate findings.

Sandbox is different: its GuardDuty detector is a member-account detector. It generates
findings for sandbox workloads; the audit account is the central admin account that
receives and manages those findings.

## Security Hub delegated admin

Security Hub follows the same admin/member pattern. The audit account is enabled as
the delegated administrator so it can act as the central findings and compliance hub.

Sandbox Security Hub is a member-account setup. Its standards subscriptions, such as
CIS AWS Foundations Benchmark, evaluate sandbox resources and produce findings that
can be viewed centrally from the audit account.

`CIS AWS Foundations Benchmark` is a compliance-style account baseline: root MFA,
CloudTrail coverage, password policy, public S3 access, and open security groups.
`AWS Foundational Security Best Practices` is AWS's broader service-level standard:
S3 public access, encrypted EBS volumes, public RDS, secure load balancers, ECR image
scanning, Lambda settings, and similar resource posture checks.

---

## Organization service access

Round 2 uses three permission layers:

- GitHub OIDC lets GitHub Actions assume the management gateway role.
- IAM policies on that role allow Terraform to call AWS APIs.
- AWS Organizations trusted service access allows CloudTrail, GuardDuty, and Security Hub
  themselves to operate across the organization.

Trusted service access belongs to AWS Organizations, not to the GitHub role. The role only
needs permission to enable/use those organization-level service integrations.

If an org-level apply fails partway through, Terraform may mark the partially created
resource as tainted. After the missing IAM or trusted-access prerequisite is fixed,
Terraform can replace that new resource and continue. This happened with the initial
CloudTrail org trail create during the POC.

---

## POC vs Production

| Setting | This repo (POC) | Loadberry production |
|---|---|---|
| Object Lock mode | `GOVERNANCE` — cleanable | `COMPLIANCE` — truly immutable |
| Retention | 7 days | 365 days minimum |
| Account creation | Manual via aws-org-infra | Control Tower automatic |
| Wiring | Manual Terraform | CT handles automatically |

---

## Cost

| Service | Cost |
|---|---|
| GuardDuty | $0 — 30-day free trial per account |
| Security Hub | $0 — 30-day free trial per account |
| CloudTrail org trail | $0 — management events free |
| S3 log storage | ~$0.01/month at POC scale |
| **Total** | **~$0.50** — run within 30-day trial window |

---

## Teardown warning

An SCP (`deny_security_monitoring_disable`) in the org blocks GuardDuty and Config
destroy operations. Before running `terraform destroy` on any security baseline resources:

1. Temporarily relax the SCP in AWS console → Organizations → Policies
2. Run the destroy
3. Restore the SCP immediately

Keep the relaxation window short — the SCP applies to the whole org.

---

## Safety

- Do not commit real `terraform.tfvars` — use `terraform.tfvars.example` only
- Do not push directly to `main` unless you intend to trigger the apply workflow
- Never switch Object Lock to `COMPLIANCE` mode in this repo
