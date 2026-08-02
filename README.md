# uma-enhub-gke-platform

Terraform for a production GKE Autopilot platform on GCP, project **uma-enhub**.
Four independent **root modules** — `vpc/`, `iam/`, `gke/`, `fleet/` — each
with its own GCS backend/state, wired together via `terraform_remote_state`.
Shared logic lives in `modules/`, which has no state of its own; it wraps the
official `terraform-google-modules` submodules plus a few plain resources
for pieces those modules don't cover (Cloud NAT, Backup for GKE, Binary
Authorization policy, Fleet features).

See `requirements-input.txt` for the original spec this was built from, and
`CONFIG-DECISIONS.md` for exactly what was decided for every field that was
left as "your suggestion" or otherwise ambiguous — **read that file before
your first apply**, it flags a couple of placeholders (bastion CIDR, pod
range size) that need real values.

## Folder structure

```
uma-enhub-gke-platform/
├── README.md
├── requirements-input.txt        # original spec, saved as-is
├── CONFIG-DECISIONS.md           # every "your suggestion" field, resolved + explained
│
├── bootstrap/                     # run ONCE, first - creates the state bucket
│   ├── providers.tf               # (local state - can't store its own bucket's state in itself)
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── prod.tfvars
│
├── modules/                       # shared child modules (no backend, no state)
│   ├── network/                   # VPC + subnets + firewall + Cloud Router/NAT
│   ├── iam/                       # GKE service account + IAM bindings
│   ├── gke/                       # Autopilot cluster + Backup for GKE
│   └── fleet/                     # Fleet features: Service Mesh (ASM) + Config Management
│
├── vpc/                            # ROOT MODULE 1 — own state
├── iam/                             # ROOT MODULE 2 — own state, independent of vpc
├── gke/                             # ROOT MODULE 3 — own state, depends on vpc + iam
├── fleet/                           # ROOT MODULE 4 — own state, depends on gke
│
├── acm/config-root/                # starter Config Sync repo layout (see acm/config-root/README.md)
│
└── .github/workflows/terraform.yml # CI/CD - plan on PR, apply on push to main
```

Every root module follows the same file pattern:

```
<root>/
├── backend.tf         # partial: terraform { backend "gcs" {} }
├── backend-prod.hcl    # real bucket/prefix, supplied at init time
├── providers.tf
├── variables.tf
├── main.tf              # calls ../modules/<name>
├── outputs.tf            # <- read by downstream roots via remote state
└── prod.tfvars
```

## What this deploys

- A `REGIONAL` VPC (`uma-enhub-vpc`) with a public subnet (`10.60.0.0/22`)
  and a private subnet (`10.60.4.0/22`), the private one carrying secondary
  ranges for GKE pods (`10.60.8.0/28` — **see the warning in
  CONFIG-DECISIONS.md**) and services (`10.62.0.0/20`).
- Cloud Router + Cloud NAT on the private subnet, since private GKE nodes
  have no external IPs of their own.
- Firewall rules allowing IAP-based SSH to the bastion range and internal
  VPC traffic.
- A dedicated GKE node/workload service account with logging, monitoring,
  artifact registry, and Secret Manager IAM roles.
- A **private, regional GKE Autopilot cluster** (`uma-enhub-prod-gke`):
  private nodes, public control-plane endpoint locked down to
  `master_authorized_networks` (the bastion), no override of GKE's default
  private-endpoint subnet, `STABLE` release channel, a daily maintenance
  window, Workload Identity, the Secret Manager add-on, Binary Authorization
  wired up (inert until attestors are added — see `gke/main.tf`), and a
  Backup for GKE plan (daily, 30-day retention).
- Fleet registration for the cluster, with the **Service Mesh** (Anthos
  Service Mesh, `MANAGEMENT_AUTOMATIC`) and **Config Management** fleet
  features enabled and bound to it.

## Remote state (GCS)

Each root module gets its own bucket prefix (same bucket, different
`prefix`):

```
gs://uma-enhub-state-file-holder/gke-platform/prod/vpc/default.tfstate
gs://uma-enhub-state-file-holder/gke-platform/prod/iam/default.tfstate
gs://uma-enhub-state-file-holder/gke-platform/prod/gke/default.tfstate
gs://uma-enhub-state-file-holder/gke-platform/prod/fleet/default.tfstate
```

The bucket itself is created by `bootstrap/` (see below) rather than by
hand, but the effect is the same as:

```bash
gsutil mb -p uma-enhub -l US gs://uma-enhub-state-file-holder
gsutil versioning set on gs://uma-enhub-state-file-holder
```

Backend blocks can't read variables, so each root's `backend.tf` is left
partial (`backend "gcs" {}`) and the real bucket/prefix live in that root's
`backend-prod.hcl`, supplied at init time.

## Apply order

```bash
# 0. Bootstrap - creates the state bucket everything else needs. Uses a
#    LOCAL state file on purpose (chicken-and-egg problem). Run once.
cd bootstrap
terraform init
terraform apply -var-file=prod.tfvars
cd ..

# 1. VPC - no dependencies
cd vpc
terraform init  -backend-config=backend-prod.hcl
terraform apply -var-file=prod.tfvars
cd ..

# 2. IAM - no dependencies, can run in parallel with vpc
cd iam
terraform init  -backend-config=backend-prod.hcl
terraform apply -var-file=prod.tfvars
cd ..

# 3. GKE - reads vpc/ and iam/ state via terraform_remote_state
cd gke
terraform init  -backend-config=backend-prod.hcl
terraform apply -var-file=prod.tfvars
cd ..

# 4. Fleet - reads gke/ state via terraform_remote_state for the cluster's
#    fleet membership; enables Service Mesh + Config Management
cd fleet
terraform init  -backend-config=backend-prod.hcl
terraform apply -var-file=prod.tfvars
cd ..
```

**Before step 3**, double-check `gke/prod.tfvars`:
- `master_authorized_networks` is a placeholder — replace with your real
  bastion CIDR.
- `master_ipv4_cidr_block` (`172.16.0.0/28`) doesn't overlap anything else
  in your project — verify.
- The pod CIDR range (`10.60.8.0/28`, set in `vpc/prod.tfvars`) is very
  small — widen it if this is going to run real workloads.

**Before step 4**, push the `acm/config-root/` folder to the git repo named
in `fleet/prod.tfvars` (`config_sync_repo`), or Config Sync will have
nothing valid to sync.

## APIs to enable once, up front

```bash
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  iam.googleapis.com \
  secretmanager.googleapis.com \
  binaryauthorization.googleapis.com \
  gkebackup.googleapis.com \
  gkehub.googleapis.com \
  mesh.googleapis.com \
  anthosconfigmanagement.googleapis.com \
  --project=uma-enhub
```

## Adding another environment (qa/staging)

Per root module, add a `qa.tfvars` and a `backend-qa.hcl` (different
`prefix`, e.g. `gke-platform/qa/vpc`) — no folder duplication needed:

```bash
cd vpc
terraform init  -backend-config=backend-qa.hcl
terraform apply -var-file=qa.tfvars
```

## CI/CD — GitHub Actions

`.github/workflows/terraform.yml` runs on PRs and pushes to `main`:

1. **`detect_changes`** — diffs the PR/push and figures out which root
   modules (`vpc`, `iam`, `gke`, `fleet`) need to run. A change under
   `modules/` forces all four.
2. **`terraform-plan`** — matrix job, one run per changed component, in
   parallel. On PRs it comments the plan output back onto the PR.
3. **`terraform-apply-vpc`** / **`terraform-apply-iam`** — push-to-`main`
   only, run in parallel, no dependency between them.
4. **`terraform-apply-gke`** — only after `vpc` and `iam` have each
   succeeded or been skipped.
5. **`terraform-apply-fleet`** — only after `gke` has succeeded or been
   skipped, since it reads the cluster's fleet membership from `gke/`'s
   state.

### Required repo secrets

| Secret | Used for |
|---|---|
| `WIF_PROVIDER` | `projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/<pool>/providers/<provider>` |
| `WIF_SERVICE_ACCOUNT` | `github-actions-sa@uma-enhub.iam.gserviceaccount.com`, impersonated via Workload Identity Federation — no key files |

Set these up under the `umaks-ui` GitHub org/user for this repo, tied to a
Workload Identity Federation pool in `uma-enhub`.

## Module versions

- `terraform-google-modules/network/google` ~> 9.0 (verified against the current submodule docs: `vpc`, `subnets`, `firewall-rules`)
- `terraform-google-modules/iam/google//modules/service_accounts_iam` ~> 8.0 (verified against current submodule docs)
- `hashicorp/google` provider ~> 6.0

**GKE no longer depends on a community module.** `modules/gke/main.tf` was originally built on
`terraform-google-modules/kubernetes-engine//modules/gke-autopilot-cluster`, but that submodule's
variable names shift across major versions in ways that are hard to pin down reliably from
outside a live `terraform init`. It's been rewritten to call the native `google_container_cluster`
resource (`enable_autopilot = true`) directly — every field it uses (`private_cluster_config`,
`master_authorized_networks_config`, `binary_authorization`, `secret_manager_config`,
`workload_identity_config`, `fleet`, `cluster_autoscaling.auto_provisioning_defaults`) is a
stable, documented field on that resource in `hashicorp/google` ~> 6.0, with no version-drift risk
from a third-party module.

## Known first-run gotcha

`gke/` and `fleet/` each read another root module's **already-applied** state via
`terraform_remote_state` — not that module's plan output. On a brand-new environment, running
`terraform plan` on `gke/` or `fleet/` before `vpc`/`iam`/`gke` have actually been **applied** will
fail with something like `data.terraform_remote_state.X.outputs is object with no attributes`.
This isn't a bug to fix in code — it's expected: do the very first deploy manually, in order
(`bootstrap` → `vpc` + `iam` → `gke` → `fleet`), before relying on the CI pipeline's plan/apply
flow for subsequent changes.
