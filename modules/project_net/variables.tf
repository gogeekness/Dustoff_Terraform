### modules/project_net/variables.tf
## Shared module: one tenant network + subnet + own router with SNAT egress.
## Used by every project branch (lustre, kubernetes, slurm) so each project
## keeps its own isolated network instead of routing through a shared router.

variable "network_name" {
  description = "Name for the tenant network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR for the subnet"
  type        = string
}

variable "subnet_name" {
  description = "Name for the subnet"
  type        = string
}

variable "router_name" {
  description = "Name for this project's own router"
  type        = string
}

variable "external_network_name" {
  description = "Name of the external network for the router's gateway (SNAT egress only — no floating IPs are allocated here)"
  type        = string
  default     = "public1"
}

variable "dns_nameservers" {
  description = "DNS servers assigned to the subnet"
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}
