# EKS GitHub Actions

A GitOps pipeline on Amazon EKS — **Terraform · GitHub Actions · Argo CD · External Secrets
Operator** — built in three levels: prove the loop, harden it, then scale it on triggers.

The underlying project has eight phases and three levels of depth. Most of the *design* work
is senior-owned: the IAM model, threat modelling, the data-layer choice, backup policy. This
page is scoped to the engineering that sits underneath that — the implementation, the
verification, and the reasoning that holds it together.

---

## The three levels

| Level | What it is | Cost/mo | Time |
| --- | --- | --- | --- |
| **MVP** | Minimum that proves the CI/CD loop end to end | ~$208 | 1–2 days |
| **Production** | Everything the design calls for, hardened | ~$450 | 3–5 days |
| **Scale** | Deliberately deferred — each item has a measured trigger | TBD | as triggered |

The EKS control plane alone is $73/mo and is the largest single line. NAT gateways are not
free-tier eligible, which is why the MVP uses one and production uses one per AZ.

---

## Architecture

```
Developer ──PR──▶ GitHub ──▶ Actions (no AWS creds) ──▶ validated + scanned image
                        │
                        └──merge to main──▶ Actions ──OIDC──▶ AWS STS ──▶ ECR
                                                                      │
ECR ◀──image discovery── Argo Image Updater ◀── writes values.yaml ───┘
                    │                                    │
                    └── Git commit ──▶ Argo CD ──sync──▶ EKS

Secrets Manager ──Pod Identity──▶ External Secrets Operator ──▶ K8s Secret ──▶ App
App ──▶ RDS MySQL / ElastiCache Redis  (private subnets, SG-scoped)
User ──▶ DNS ──▶ NLB + ACM TLS ──▶ NGINX Ingress ──▶ App
```

### The three rules that hold it together

1. **CI ends at the registry.** No workflow runs `kubectl apply`. Actions pushes an image and
   stops. Argo CD deploys. The moment a workflow deploys, you have a push deployment wearing
   a GitOps hat — and Argo CD will fight it, because it reconciles the cluster back to Git and
   reverts the `kubectl` change as drift.

2. **One writer per file.** Argo CD Image Updater is the *only* thing that writes
   `values.yaml`. Actions pushes to ECR and writes nothing to Git manifests. Two writers is
   how you get a commit on every single build.

3. **Terraform owns the platform, Argo CD owns the workloads.** Never let them overlap on the
   same resource. That boundary is the whole design — and it's also the bootstrap answer,
   since Argo CD cannot install itself.

---

## Security decisions worth reading

This is where most of the substance is.

**OIDC instead of stored access keys.** An access key is a bearer token that never expires
until someone rotates it. If it leaks from a workflow, a log, or a fork, it works from
anywhere. GitHub instead mints a short-lived signed JWT per run, AWS verifies the signature
and checks the claims, and the credential expires in minutes. Nothing long-lived to store,
leak, or rotate.

**The `sub` claim is the authorization boundary.** That JWT states *what* is asking for
credentials — `ref:refs/heads/main`, `environment:production`, `pull_request` — and the trust
policy matches it exactly. The value most tutorials show, `repo:ORG/REPO:*`, means any branch
*and any workflow you add later*, which is effectively open. GitHub also now appends
immutable numeric IDs to the claim (`repo:ORG@ID/REPO@ID`), so a policy written against the
old name-only form looks perfectly correct and never matches.

**Four identities, four roles, zero overlap.** `ci-ecr-push` (ECR push only) and
`infra-plan` / `infra-apply` (read-only vs. write) are deliberately separate, because one
combined role means any merged PR can write infrastructure. `break-glass` is AdministratorAccess
with MFA, kept off every workflow.

**Absence as a control.** The PR workflow has no `configure-aws-credentials` step at all.
There is nothing to escalate to — including from a fork.

**Pod Identity, not node roles.** A pod with no association must fail
`sts:GetCallerIdentity`. If it succeeds, it is silently using the node's IAM role, which may
have far more permissions than intended. That check catches more real misconfiguration than
anything else in the project.

**Verify, don't assume.** Every control here has a test that passes by *failing*: a workflow
on a feature branch must be unable to assume the CI role; a fork PR must reach no AWS at all.
A control that has never failed closed is unproven.

---

## Supply chain

- Every action pinned to a **commit SHA**, not a tag — a tagged action can be re-pointed at
  new content, a SHA cannot. A workflow with `id-token: write` is code that can run against
  your cloud account.
- Trivy scanning in the build with `exit-code: '1'`. A scanner that warns is a scanner nobody
  reads.
- `gitleaks` over full Git history, not just the diff.
- ECR tags immutable, scan-on-push, with a lifecycle policy — which is also what makes Image
  Updater trustworthy, since it can't silently re-point a tag.
- Branch protection on `main`: required checks, required review, no force-push.

---

## Two things that bite everyone

**`terraform plan` needs to attach to a state bucket that doesn't exist yet.** It takes two
applies: `terraform init -backend=false`, `terraform apply`, then `terraform init
-migrate-state`. And the bucket name must end in the account ID — S3 names are global, so a
fixed name is already owned by another account and fails with `409 BucketAlreadyExists`.

**Both EKS endpoint flags must be true.** GitHub-hosted runners execute outside your VPC.
With `endpoint_private_access = false`, every `kubectl` step in CI hangs until timeout.

---

## A note on Jenkins

The original brief specified Jenkins. This implementation uses GitHub Actions, which is a
deliberate substitution: the repo is already on GitHub, so OIDC federation removes stored
credentials entirely, and hosted runners are free at this scale (2,000 min/month on a private
repo, against three workflows on one repo).

The tradeoff is real. Jenkins-in-cluster was the mandated path and it does showcase the
Helm-on-EKS route better, but it puts a CI controller inside the trust boundary it manages,
and it introduces a bootstrap problem — the thing that deploys Argo CD cannot itself be
deployed by Argo CD. Hosted runners keep CI outside the cluster.

---

## Documentation

A 14-document runbook set covers this build in depth — the phase-by-phase build order,
verification commands and exit criteria per phase, failure tables, cost breakdowns per level,
the IAM and network policies, and a full architecture review with 26 numbered decisions
recorded with their rejected alternatives.

> The working copy is kept locally and is not published here. Ask and I'll share it.

Included in this repo:

- [`scripts/setup-aws-profile.sh`](scripts/setup-aws-profile.sh) — writes a named AWS profile
  from a downloaded key CSV without printing the secret or putting it in shell history
