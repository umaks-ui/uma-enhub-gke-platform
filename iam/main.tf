module "iam" {
  source = "../modules/iam"

  project_id                    = var.project_id
  service_account_id            = var.service_account_id
  service_account_display_name  = var.service_account_display_name
  project_roles                 = var.project_roles
  bindings                      = var.sa_bindings
}
