# Configuration decisions

The source spec left several fields marked "your suggestion" or otherwise
ambiguous. Here's exactly what was chosen and why, so you can revisit any of
them before a real `apply`.

| Field | Spec said | Decision made | Where |
|---|---|---|---|
| Dynamic routing mode | "regional - what you suggest" | `REGIONAL` | `vpc/prod.tfvars` |
| Flow logs | enable/disable | Enabled on the **private** subnet only (where the workload runs); disabled on the public subnet to save cost | `vpc/prod.tfvars` |
| Enable private nodes | yes, "might add NAT" | `true`, **and** Cloud Router + Cloud NAT added so private nodes get outbound internet access | `modules/network`, `vpc/prod.tfvars` |
| Pod CIDR range | `10.60.8.0/28` ("will discuss over a call") | Used as given, but **flagged**: a /28 is only 16 IPs total for pods across the whole cluster - almost certainly too small for real workloads. Widen to at least a /20 before applying to anything real. | `vpc/prod.tfvars` |
| Backup for GKE | "based on your current backup policy" | Enabled (per your answer), daily backups at 03:00, 7-day delete lock, 30-day retention | `gke/prod.tfvars` |
| Binary Authorization | "your suggestion" / no preference given | Enabled at the cluster level, but the project policy defaults to `ALWAYS_ALLOW` + `DRYRUN_AUDIT_LOG_ONLY` enforcement - i.e. wired up but **not actually restricting anything yet**, since no attestors exist in this scaffold. See the TODO comment in `gke/main.tf` for how to turn on real dry-run/enforce behavior once you have attestors. | `gke/main.tf`, `gke/prod.tfvars` |
| Fleet Feature (Mesh) | servicemesh / multiclusteringress / configmanagement - "your suggestion" | `servicemesh` + `configmanagement` (per your answer); `multiclusteringress` left out since there's only one cluster right now - add it later if you register a second cluster into the fleet | `fleet/prod.tfvars` |
| Mesh Management Mode | "ASM" | `MANAGEMENT_AUTOMATIC` (Google manages the mesh control plane - the standard modern ASM setup) | `fleet/prod.tfvars` |
| Deletion protection | true/false, unspecified | `true` - standard for a prod cluster. Flip to `false` in `gke/prod.tfvars` if you expect to tear this down often. | `gke/prod.tfvars` |
| Fleet name | "kepler-prod-502406 fleet (created)" | Not modeled as a separate resource - a GCP project has exactly one Fleet, auto-created the moment anything registers into it. The cluster's fleet **membership** ID (effectively the cluster name) is what's referenced elsewhere. | `modules/fleet` |
| Master authorized networks (bastion CIDR) | "config not outside the bastion" | **Placeholder only** - set to the private subnet's CIDR (`10.60.0.0/22`) as a stand-in. Replace with your actual bastion host/subnet CIDR before applying, or the control plane's public endpoint will be reachable from anywhere in that placeholder range. | `gke/prod.tfvars` |
| Control plane peering range | not specified | `172.16.0.0/28`, chosen to not overlap any of the 10.60.x.x / 10.62.x.x ranges already in use. Double-check it doesn't collide with anything else in the project. | `gke/prod.tfvars` |
| Backend state bucket | "keep bucket name specific to what it does" | `uma-enhub-state-file-holder` | `bootstrap/prod.tfvars`, all `backend-prod.hcl` files |
| Environment name | only "prod" mentioned in the spec | Used `prod.tfvars` / `backend-prod.hcl` everywhere (rather than `dev`) since the source spec was explicitly for `kepler-prod`. Add `qa.tfvars` / `backend-qa.hcl` per root module the same way if you need another environment later. | all root modules |

None of these are hard-coded assumptions you're stuck with - every one of
them is a plain variable in a `.tfvars` file, meant to be edited before you
run `terraform apply` for real.
