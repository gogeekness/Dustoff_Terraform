### variables.tf

variable "bastion_network_name" {
  type    = string
  default = "Bastion-net"
}

variable "bastion_router_name" {
  type    = string
  default = "Bastion-router"
}

variable "external_network_name" {
  type    = string
  default = "public1"
}

variable "bastion_flavor" {
  description = "Flavor name for the Bastion instance. Fill in from `openstack flavor list` — no default on purpose, since guessing wrong here is worse than a plan-time error."
  type        = string
}

variable "operator_ssh_public_key_path" {
  description = "Path to the public key used for YOUR access to Bastion (not the key Bastion later uses to reach other VMs)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "home_network_cidr" {
  description = "The only CIDR allowed to SSH into Bastion's floating IP"
  type        = string
  default     = "192.168.178.0/24"
}
