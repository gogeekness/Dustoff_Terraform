## Main ft file.
## This contains the instance notaction
## 

# module "lust_net" {
#   source = "./Lustre_Net"
#   region             = var.region
#   availability_zone  = var.availability_zone
#   ssh_key_location   = var.openstack_key_pub
# }

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
      ipv4          = "10.0.10.10"
      public_ip     = ""
      tags = {
        Name    = "lustre_mgt"
        Role    = "manager"
        Project = "lustre"
      }
    },
    # {
    #   host_name     = "lustre_oss"
    #   instance_type = "t3.xlarge"
    #   ipv4          = "10.0.10.11"
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
    #   ipv4          = "10.0.10.12"
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

## Adding for access to the internet, I don't need it for testing.
## I add it here for future upgrades if needed. 
# ##
# resource "openstack_internet_gateway" "cluster_igw" {
#   vpc_id = openstack_vpc.cluster_vpc.id
#   tags = {
#     Name = "cluster-igw"
#   }
# }

### Maybe in a future expancion.  I need to keep it simple.
# EBS volumes for data drives all VM will have a extra 30 GB drive
# resource "openstack_ebs_volume" "data_drives" {
#   for_each = toset(local.server_names)
#   availability_zone = module.lust_net.availability_zone
#   size             = 30  #GB
#   type             = "gp3"
#   tags = {
#     Name = "data-drive-${each.key}"
#   }
# }
# # Need to attach the buffer data drives 
# resource "openstack_volume_attachment" "data_drive_attachments" {
#   for_each = { for server in var.server_list : server.host_name => server }

#   device_name = "/dev/sdd"  # Set as second drive 
#   volume_id   = openstack_ebs_volume.data_drives[each.key].id
#   instance_id = openstack_instance.Lustre_servers[each.key].id
### }

# EBS volumes main Data drive 500 GB drive for the oss
# This is only a test drive.
resource "openstack_ebs_volume" "zfs_data_drive" {
  availability_zone = module.lust_net.availability_zone
  size             = 500  #GB 
  type             = "gp3"
  tags = {
    Name = "data-drive-oss-server"
  }
}
# Attach large drive specifically to OSS server
resource "openstack_volume_attachment" "oss_large_drive" {
  device_name = "/dev/sdz"  # Set as -last- drive for the oss
  volume_id   = openstack_ebs_volume.zfs_data_drive.id
  instance_id = openstack_instance.Lustre_servers["lustre_oss"].id
}


resource "openstack_key_pair" "Lustre_Key" {
  # the name for the resource adding the RSA key to servers
  key_name  = "Lustre_Key"
  public_key = var.openstack_key_pub
  # public_key = file("./ssh/lustretest.pub")  #defined in screts
}

resource "openstack_instance" "Lustre_servers" {
  for_each        = { for server in var.server_list : server.host_name => server }
  #for_each        = toset(var.server_list)

  # host_id         = "${each.key}"
  instance_type   = each.value.instance_type
  ami             = var.ami_my_image
  subnet_id       = module.lust_net.subnet_id
  private_ip      = each.value.ipv4
  key_name        = openstack_key_pair.Lustre_Key.key_name
  availability_zone = module.lust_net.availability_zone
  associate_public_ip_address = each.key == "lustre_client" ? true : false

    # the one we created as "RESOURCE 1) Also we now use the "openstack_security_group" of RESOURCE 2) above
  vpc_security_group_ids = [module.lust_net.security_group.id]

  tags = merge(
    {
      Name = each.value.host_name
    },
    each.value.tags
  )
    ### Ansible needs a more modern version of Python then the on installed on the IAM
    #   Install python by yum command and link it as python3.  
    user_data = <<EOF
              #cloud-config
              
              packages:
                - python3.11
                - lnav
              
              late-commands:
                - [ sh, -c, "ln -sf /bin/python3.11 /bin/python3" ]

              EOF

              # echo "set to early fail"
              # set -e

              # echo "installing pythhon 38"
              # # Install Python 3.8
              # sudo yum install -y python38

              # echo "Set softlink to python3"
              # # Ensure it's available for Ansible
              # sudo ln -sf /usr/bin/python3.8 /usr/bin/python3
              # EOF
}

### output public IP address
output "ec2_global_ips" {
  value = [for instance in openstack_instance.Lustre_servers : instance.public_ip]
}
output "ec2_private_ips" {
  value = [for instance in openstack_instance.Lustre_servers : instance.private_ip]
}

output "client_public_ip" {
  value = openstack_instance.Lustre_servers["lustre_client"].public_ip
}

## ENDE
