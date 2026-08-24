### modules/project_instance/variables.tf
## Shared module: one compute instance. Defaults to booting straight from the
## Glance image using the flavor's local ephemeral disk (no Cinder volume),
## since only Lustre actually needs durable block storage. Set
## boot_from_volume = true and/or data_volume_size_gb to opt into Cinder.

variable "instance_name" {
  type = string
}

variable "instance_type" {
  description = "Flavor name"
  type        = string
}

variable "network_id" {
  type = string
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

variable "fixed_ip" {
  description = "Optional static IP on the given network; leave null for DHCP"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Optional cloud-init content"
  type        = string
  default     = null
}

variable "boot_from_volume" {
  description = "Boot from a Cinder volume instead of the flavor's local ephemeral disk"
  type        = bool
  default     = false
}

variable "root_volume_size_gb" {
  description = "Size of the boot volume, only used when boot_from_volume = true"
  type        = number
  default     = 20
}

variable "data_volume_size_gb" {
  description = "Size of an extra Cinder data volume (e.g. Lustre MDT/OST). Leave null to skip."
  type        = number
  default     = null
}
