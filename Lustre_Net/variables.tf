## Only net specific var definitions are placed here. 
## aveialabity zone is one key var needed

variable "external_network_name" {
  description = "Name of the existing external/provider network"
  type        = string
  default = "public"
}
variable "network_name" {
  description = "Name for the new tenant network"
  type        = string
  default = "lustre-test-net"
}

variable "subnet_cidr" {
  description = "CIDR for the new subnet"
  type        = string
  default = "10.0.20.0/24"
}

variable "router_name" {
  description = "Name for the new router"
  type        = string
  default = "lustre-test-router"
}

variable "dns_nameservers" {
  description = "DNS servers assigned to the subnet"
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}

variable "flavor_name" {
  type    = string
  default = "m1.small"
}

variable "keypair_name" {
  type    = string
  default = "id_rasa"
}

variable "ssh_key_location" {
  type = string
  description = "SSH key location"
  default = "/home/reseke/.ssh/id.rsa"
  sensitive = true
}