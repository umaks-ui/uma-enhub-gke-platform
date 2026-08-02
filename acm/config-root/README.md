# config-root

This is a starter [Config Sync](https://cloud.google.com/anthos-config-management/docs/config-sync-overview)
`config-root` for the Anthos Config Management fleet feature enabled by
`fleet/`. Config Sync (running inside the cluster once the fleet feature is
bound) polls a git repo and applies whatever's under here.

## Layout

```
config-root/
├── cluster/        # cluster-scoped objects (ClusterRole, ClusterRoleBinding, etc.)
└── namespaces/      # namespace-scoped objects, one subfolder per namespace
    └── app/
        └── namespace.yaml
```

## To actually use this

1. Push this `acm/config-root/` folder (rename/move as needed) to its own
   git repo - e.g. `https://github.com/umaks-ui/uma-enhub-config-root`,
   matching `config_sync_repo` in `fleet/prod.tfvars`.
2. If the repo is private, change `config_sync_secret_type` in
   `fleet/prod.tfvars` away from `"none"` (e.g. `"token"` or
   `"gcpserviceaccount"`) and follow the
   [Config Sync auth docs](https://cloud.google.com/anthos-config-management/docs/how-to/installing-config-sync#git-creds)
   to set up the corresponding secret/credentials.
3. Add real manifests under `cluster/` and `namespaces/<name>/` - the two
   files included here are just a working placeholder so `terraform apply`
   on `fleet/` has something valid to sync on day one.
