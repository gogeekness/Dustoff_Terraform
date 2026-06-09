# This file is for configration varables gernerally used by Tofu
# AMI, IPs, Groupings, are stored here
#


router_name           = "lust_net_router"
instance_name         = "lust_net_vm"
flavor_name           = "m1.small"
keypair_name          = "lustretest.pub"
external_network_name = "Internal_line"
network_name          = "lust_net"
subnet_cidr           = "10.0.20.0/24"
ssh-public-key-path  = "~/.ssh/id_rsa.pub"


Lserver_list = [
  {
    host_name     = "lustre_mgt"
    instance_type = "m1.small"
    ipv4          = "10.0.20.10"
    public_ip     = ""
    ssh-key       = local.ssh-public-key-path
    OS-size       = "20"
    tags = {
      Name    = "lustre_mgt"
      Role    = "manager"
      Project = "lustre"
    }
  }
]



// region            = "eu-central-1"
// availability_zone = "eu-central-1a"

# (openstack) reseke@dustoff:~$ openstack flavor list
# +-------------------------+--------------------+-------+------+-----------+-------+-----------+
# | ID                      | Name               |   RAM | Disk | Ephemeral | VCPUs | Is Public |
# +-------------------------+--------------------+-------+------+-----------+-------+-----------+
# | 1                       | m1.tiny            |   512 |    1 |         0 |     1 | True      |
# | 2                       | m1.small           |  2048 |   20 |         0 |     1 | True      |
# | 29f8ea07-6e6c-4fda-     | m1.small+          |  2048 |   30 |         0 |     2 | True      |
# | 8b4d-8180c9873b74       |                    |       |      |           |       |           |
# | 3                       | m1.medium          |  4096 |   40 |         0 |     2 | True      |
# | 4                       | m1.large           |  8192 |   80 |         0 |     4 | True      |
# | 5                       | m1.xlarge          | 16384 |  160 |         0 |     8 | True      |
# | 6                       | m2.tiny            |   512 |    1 |         0 |     2 | True      |
# | 9ecfb673-70c6-4aa5-     | xigmanas.noef_disk |  4048 |    0 |         0 |     2 | True      |
# | 8941-b0293edb8ae5       |                    |       |      |           |       |           |
# +-------------------------+--------------------+-------+------+-----------+-------+-----------+
