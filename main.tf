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
  # source            = "/v2/images/2cf93f7d-8a8f-4153-b7c7-aaaa54ae1e98/file"
  name              = "Ubuntu 24.04 LTS"
  most_recent       = true
}

resource "openstack_compute_keypair_v2" "lustre_ssh_key" {
  name       = "lustre_ssh_key"
  public_key = file(var.ssh-public-key-path)
}


# for each node of this small cluster
# Terraform will assign the public IP dynamically
variable "server_list" {
  type = list(object({
    host_name     = string
    instance_type = string
    ipv4          = string
    public_ip     = string
    tags          = map(string)
  }))
  default = [
    {
      host_name     = "lustre_mgt"
      instance_type = "m1.small"
      ipv4          = "10.0.20.10"
      public_ip     = ""
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
  server_names = toset([for server in var.server_list : server.host_name])
  inventory = ""
}


module "Lustre_Instance" {
  source = "./Lustre_Instance"

  instance_name       = var.instance_name
  instance_type       = var.flavor_name
  openstack_key_pub   = public_key.public_key 
}

resource "openstack_compute_instance_v2" "Lustre_servers" {
  for_each        = { for server in var.server_list : server.host_name => server }
  #for_each        = toset(var.server_list)
  name            = each.value.host_name
  # host_id         = "${each.key}"
  flavor_id       = each.value.flavor_name
  image_id        = data.openstack_images_image_v2.ubuntu_24-04.id


  block_device {
    uuid                  = data.openstack_images_image.ubuntu_2404.id
    source_type           = "image"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 20 
  }

  tags = merge(
    {
      Name = each.value.host_name
    },
    each.value.tags
  )

  network {
    uuid = module.lust_net.network_id   # <-- from module output
  }
}


  # subnet_id       = module.lust_net.subnet_id
  # private_ip      = each.value.ipv4
  # key_name        = openstack_key_pair.Lustre_Key.key_name
  # associate_public_ip_address = each.key == "lustre_client" ? true : false
  # vpc_security_group_ids = [module.lust_net.security_group.id]

  
### output public IP address
# output "server_public_ips" {
#   description = "Public IP addresses of the servers"
#   value       = { for server in openstack_compute_instance.Lustre_servers : server.key => server.associate_public_ip_address ? server.public_ip : null }
# }


## ENDE
