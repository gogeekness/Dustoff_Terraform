# modules

Shared OpenTofu modules used across the component branches of this repo
(`bootstrap`, `lustre`, `kubernetes`, `slurm`). This branch has no root
config of its own and is never applied directly — other branches pull from
it via a git-ref module source, e.g.:

```hcl
module "lustre_net" {
  source = "git::ssh://git@github.com-terraform/gogeekness/Dustoff_Terraform.git//modules/project_net?ref=modules"
  ...
}
```

## Modules

- **`project_net`** — one tenant network + subnet + dedicated router with
  SNAT egress to the external network (`public1`). No floating IPs are
  allocated here; Bastion is the only thing meant to be reachable from
  outside.
- **`project_instance`** — one compute instance. Boots from the Glance image
  using the flavor's local ephemeral disk by default (no Cinder volume);
  set `boot_from_volume` and/or `data_volume_size_gb` to opt into Cinder
  where a project actually needs durable block storage (e.g. Lustre's
  MDT/OST).
- **`bastion_link`** — attaches an extra NIC on the Bastion instance into a
  project's network, found by a name lookup rather than a hard dependency on
  Bastion's own Terraform state. This is what lets `lustre`/`kubernetes`/
  `slurm` be applied and destroyed independently of each other and of
  Bastion, while Bastion still reaches into all of them as the admin jump
  host.
- **`bastion_instance`** — the Bastion VM itself. Used only by the
  `bootstrap` branch, since that's the one thing that has to be created
  before Bastion exists to run anything on its own.

## Deployment order

1. **Host, one-time**: `bootstrap` branch stands up Bastion (uses
   `bastion_instance`).
2. **From Bastion, ongoing**: `lustre` / `kubernetes` / `slurm` branches are
   applied/destroyed independently, in any order, any time. Each one's
   `bastion_link.tf` looks up the already-running Bastion instance by name,
   which only succeeds because step 1 already happened.
