## Main Terraform file.
## This file is the main entry point for Terraform. It defines the resources to be created and how they are connected.
## It calls the other resorces and modules, and defines the variables and outputs.  


module "lust_net" {
  source = "./Lustre_Net"

  # external_network_name = var.external_network_name
  network_name          = var.network_name
  subnet_cidr           = var.subnet_cidr
  router_name           = var.router_name

  # subnet_id             = var.subnet_id
  # vpc_security_group_ids = [module.lust_net.security_group.id]
}


resource "openstack_compute_keypair_v2" "public-key" {
  name = "lustre_public-key"
  public_key = file(var.ssh-public-key-path)
}


data "openstack_images_image_v2" "ubuntu_24-04"{
  # source          = "/v2/images/2cf93f7d-8a8f-4153-b7c7-aaaa54ae1e98/file"
  name              = "Ubuntu 24.04 LTS"
  most_recent       = true
}


# for each node of this small cluster
# Terraform will assign the public IP dynamically
variable "Lserver_list" {
  type = list(object({
    host_name     = string
    instance_type = string
    ipv4          = string
    public_ip     = string
    ssh-key       = string
    OS-size       = string
    tags          = map(string)
  }))
  default = [
    {
      host_name     = "lustre_mgt"
      instance_type = "m1.small"
      ipv4          = "10.0.20.10"
      public_ip     = ""
      ssh-key       = "~/.ssh/id_rsa.pub"
      OS-size       = "20"
      tags = {
        Name    = "lustre_mgt"
        Role    = "manager"
        Project = "lustre"
      }
    }
    # {
    #   host_name     = "lustre_oss"
    #   instance_type = "t3.xlarge"
    #   ipv4          = "10.0.20.11"
    #   public_ip     = ""
    #   tags = {
    #     Name    = "lustre_oss"
    #     Role    = "storage"
    #     Project = "lustre"
    #   }
    # },
    # {
    #   host_name     = "lustre_client"
    #   instance_type = "t3a.large"
    #   ipv4          = "10.0.20.12"
    #   public_ip     = "fill"
    #   tags = {
    #     Name    = "bastion"
    #     Role    = "client"
    #     Project = "lustre"
    #   }
    # }
  ]
}

locals {
  server_names = toset([for Lserver in var.Lserver_list : Lserver.host_name])
  inventory = ""
}

module "lustre_instance" {
  for_each          = { for Lserver in var.Lserver_list : Lserver.host_name => Lserver }
  source            = "./Lustre_Instance"

  instance_name     = each.value.host_name
  instance_type     = each.value.instance_type
  network_id        = module.lust_net.network_id
  openstack_key_pub = each.value.ssh-key
  OS-size           = each.value.OS-size

  depends_on = [module.lust_net]
}

# module "Lustre_Instance" {
#   for_each        = { for Lserver in var.Lserver_list : Lserver.host_name => Lserver }
#   source          = "./Lustre_Instance"

#   # instance_name       = each.value.host_name
#   instance_type       = each.value.instance_type
#   openstack_key_pub   = public_key.name
# }


## ENDE
