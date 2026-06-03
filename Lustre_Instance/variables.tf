
### Tofu instance module variables.tf
###

variable "openstack_key_pub" {
  type        = string
  description = "Main SSH Key"
  # default = "Non-usable-keypair"
  sensitive = true
}

variable "instance_type" {
  type        = string
  description = "Instance Size"
  sensitive   = false
}

variable "openstack_user" {
  type        = string
  description = "Key user for teh cluster"
  default = "reseke"
}

variable "network_id" {
  type        = string
  description = "Network ID for the cluster"
  default = "fill"
}

variable "instance_name" {
  type        = string
  description = "Name for the instance"
  default = "lustre_test_vm"
}

