# Create this bucket once (via ../bootstrap) before first init anywhere:
#   cd ../bootstrap && terraform init && terraform apply -var-file=prod.tfvars
bucket = "uma-enhub-state-file-holder"
prefix = "gke-platform/prod/vpc"
