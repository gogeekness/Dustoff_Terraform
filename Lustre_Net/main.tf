
### Lustre_Net main.tf
##
##  The networking side of this cluster
##  OpenStack resources for the network, subnet, router, and router interface are defined here.

resource "openstack_networking_network_v2" "Lustre_Net" {
  name           = var.network_name
  admin_state_up = true
  tags = [
    "tier : Private",
    "subnet_name : Lustre_subnet"
  ]
}

# fetch the external network by name to get its ID for router uplink External ==> Maintenence network
data "openstack_networking_network_v2" "External_Net" {
  name = var.external_network_name
}

resource "openstack_networking_subnet_v2" "Lustre_subnet" {
  network_id = openstack_networking_network_v2.Lustre_Net.id
  cidr       = var.subnet_cidr
  ip_version = 4
  dns_nameservers = var.dns_nameservers
}

resource "openstack_networking_floatingip_v2" "lustre_fip" {
  pool = var.external_network_name   # "Maintenence"
}

# resource "openstack_networking_subnet_route_v2" "Lustre_route" {
#   subnet_id       = openstack_networking_subnet_v2.Lustre_subnet.id
#   destination_cidr = "10.0.10.0/24"
#   next_hop        = "10.0.10.1"
# }

# Router with uplink to external network
resource "openstack_networking_router_v2" "Lustre_router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.External_Net.id
}
# Attach the subnet to the router
resource "openstack_networking_router_interface_v2" "Lustre_router_iface" {
  router_id = openstack_networking_router_v2.Lustre_router.id
  subnet_id = openstack_networking_subnet_v2.Lustre_subnet.id
}

# resource "aws_vpc" "lustre_vpc" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true
  
#   tags = {
#     Name = "lustre-vpc"
#   }
# }

# # RESOURCE 2) an "aws_security_group" is like the rules what network connections are 
# #             allowed for the "aws_instance" we use this resource 
# resource "aws_security_group" "our_security_group" {
#   # rules about incoming network connections to the instance
#   name = "Lustre_SG"
#   vpc_id = aws_vpc.lustre_vpc.id
#   ingress {
#     # allowed port(s) starting form this port number to and from port
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     # the allowed ip origins this rule applies to (0.0.0.0/0) is all ipv4 addresses "everyone"
#     cidr_blocks = ["0.0.0.0/0"]
#     }

#   # Allow internal SSH between instances
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.subnet_cidr]
#   }
#     # Give access to squid so dnf can install components in the internal servers
#     ingress {
#     from_port   = 3128
#     to_port     = 3128
#     protocol    = "tcp"
#     cidr_blocks = [var.subnet_cidr]
#   }

#   # Allow Lustre traffic internally
#   ingress {
#     from_port   = 988
#     to_port     = 988
#     protocol    = "tcp"
#     cidr_blocks = [var.subnet_cidr]
#   }
#   egress {
#     # same as above, just for outgoing
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "lustre-security-group"
#   }
# }

# # ── Floating IP ─── Capture ─────────────────────────────────────────────────────
# resource "openstack_networking_floatingip" "fip" {
#   pool = var.external_network_name
# }
