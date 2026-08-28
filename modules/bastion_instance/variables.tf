### modules/bastion_instance/variables.tf
## the only varibles for the bastion instance

variable "instance_name" {
  type    = string
  default = "bastion"
}

variable "instance_type" {
  description = "Flavor name"
  type        = string
}

variable "network_id" {
  description = "Bastion-net network ID"
  type        = string
}

variable "keypair_name" {
  type = string
}

variable "security_group_names" {
  type    = list(string)
  default = ["default"]
}

variable "image_name" {
  type    = string
  default = "Ubuntu 24.04 LTS"
}

variable "external_network_name" {
  description = "Floating IP pool name"
  type        = string
  default     = "public1"
}

variable "ssh_public_key" {
  description = "Public key written into cloud-init for the reseke user"
  type        = string
}
