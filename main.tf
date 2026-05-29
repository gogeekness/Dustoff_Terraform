## Main ft file.
## This contains the instance notaction
## 


module "lust_net" {
  source = "./Lustre_Net"

  # external_network_name = var.external_network_name
  network_name          = var.network_name
  subnet_cidr           = var.subnet_cidr
  router_name           = var.router_name

}

variable "keypair_name" {
  type    = string
  default = "Lustre_VM"
}

resource "openstack_compute_keypair_v2" "ssh_key" {
  name       = var.keypair_name
  public_key = file("/home/ubuntu/ssh/lustretest.pub")
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

# EBS volumes main Data drive 500 GB drive for the oss
# This is only a test drive.
# resource "openstack_ebs_volume" "zfs_data_drive" {
#   availability_zone = module.lust_net.availability_zone
#   size             = 500  #GB 
#   type             = "gp3"
#   tags = {
#     Name = "data-drive-oss-server"
#   }
# }


# Attach large drive specifically to OSS server
# resource "openstack_volume_attachment" "oss_large_drive" {
#   device_name = "/dev/sdz"  # Set as -last- drive for the oss
#   volume_id   = openstack_ebs_volume.zfs_data_drive.id
#   instance_id = openstack_instance.Lustre_servers["lustre_oss"].id
# }

resource "openstack_key_pair" "Lustre_Key" {
  # the name for the resource adding the RSA key to servers
  key_name  = "Lustre_Key"
  public_key = var.openstack_key_pub
  # public_key = file("./ssh/lustretest.pub")  #defined in screts
}

resource "openstack_compute_instance" "Lustre_servers" {
  for_each        = { for server in var.server_list : server.host_name => server }
  #for_each        = toset(var.server_list)
  name            = each.value.host_name
  # host_id         = "${each.key}"
  flavor_id       = each.value.flavor_name
  image_id        = data.openstack_images_image_v2.ubuntu_24-04.id
  subnet_id       = module.lust_net.subnet_id
  private_ip      = each.value.ipv4
  key_name        = openstack_key_pair.Lustre_Key.key_name
  associate_public_ip_address = each.key == "lustre_client" ? true : false

    # the one we created as "RESOURCE 1) Also we now use the "openstack_security_group" of RESOURCE 2) above
  vpc_security_group_ids = [module.lust_net.security_group.id]

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

### output public IP address
# output "server_public_ips" {
#   description = "Public IP addresses of the servers"
#   value       = { for server in openstack_compute_instance.Lustre_servers : server.key => server.associate_public_ip_address ? server.public_ip : null }
# }


## ENDE
