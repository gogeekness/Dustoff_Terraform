# variable "openstack_ssh_key_pair" {
#   type      = string
#   # the name for the resource
#   description = "our_public_ssh_key"
#   #public_key = "ssh-rsa AAAAB.............(fill in here the result of `ssh-add -L`"
#   sensitive = true
# }

variable "router_name" {
  type    = string
  default = "tf-test-router"
}

variable "instance_name" {
  type    = string
  default = "tf-test-vm"
}

variable "flavor_name" {
  type    = string
  default = "m1.small"
}

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

