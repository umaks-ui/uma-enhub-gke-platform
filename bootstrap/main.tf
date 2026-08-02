# -----------------------------------------------------------------------------
# Bootstrap: creates the GCS bucket that every other root module (vpc/, iam/,
# gke/, fleet/) uses as its remote state backend.
#
# This intentionally uses a LOCAL state file (no backend.tf here) - it's the
# classic chicken-and-egg problem: you can't store the bucket's own state in
# the bucket it's about to create. Run this once, keep bootstrap.tfstate
# somewhere safe (or migrate it into the bucket afterwards if you want), and
# never re-run destroy on it casually since every other root module depends
# on this bucket existing.
# -----------------------------------------------------------------------------
resource "google_storage_bucket" "tfstate" {
  name     = var.state_bucket_name
  project  = var.project_id
  location = var.state_bucket_location

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    purpose = "terraform-state"
    project = "uma-enhub"
  }
}
