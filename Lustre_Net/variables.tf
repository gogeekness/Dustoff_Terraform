## Only net specific var definitions are placed here. 
## aveialabity zone is one key var needed


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

variable "subnet_name" {
  description = "Name for the new subnet"
  type        = string
  default     = "lustre-test-subnet"
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