# bootstrap

Stands up Bastion. Run from the **host**, not from Bastion — this is the one
branch that has to run somewhere else, since Bastion doesn't exist yet to
run anything on its own. One-time, rare re-runs only.

## What this creates

- Reads `Bastion-net`, `Bastion-router`, and `public1` as data sources
  (created by hand via the OpenStack CLI, not Terraform-managed here —
  see `data.tf`)
- An SSH keypair for **your** access to Bastion (`keypair.tf`)
- A security group allowing SSH only from the home network (`security_group.tf`)
- The Bastion instance itself, via `modules/bastion_instance` pulled from
  the `modules` branch (`bastion.tf`)
- Bastion's floating IP — the only externally reachable address in the
  whole environment

## Before you `tofu apply`

Set `bastion_flavor` — it has no default on purpose:

```bash
tofu apply -var="bastion_flavor=<flavor-name-from-openstack-flavor-list>"
```

or add it to a local (gitignored) `terraform.tfvars`.

## After Bastion is up

Everything else — `lustre`, `kubernetes`, `slurm` — gets applied **from
Bastion**, not from here. See the `modules` branch README for the full
deployment order.
