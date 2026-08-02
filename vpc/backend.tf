# Partial backend config - real bucket/prefix supplied at init time via
# `terraform init -backend-config=backend-prod.hcl`
terraform {
  backend "gcs" {}
}
