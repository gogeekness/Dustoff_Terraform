### modules/bastion_link/variables.tf
## Attaches an extra NIC on the Bastion instance into a project's network,
## via a lookup by name — not a hard Terraform dependency on Bastion's own
## state. Used by lustre/kubernetes/slurm so Bastion can reach each project's
## private subnet as the admin jump host, without those branches ever
## touching Bastion's state, and without Bastion needing to know which
## project networks currently exist.

variable "network_id" {
  description = "The project network to attach Bastion into"
  type        = string
}

variable "subnet_id" {
  description = "The project subnet to allocate Bastion's port IP from"
  type        = string
}

variable "bastion_instance_name" {
  type    = string
  default = "bastion"
}

variable "fixed_ip" {
  description = "Optional static IP for Bastion on this network; leave null to auto-assign from the subnet"
  type        = string
  default     = null
}
