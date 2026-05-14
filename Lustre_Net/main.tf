#  The networking side of this cluster


# Look up the existing external (provider) network
data "openstack_networking_network_v2" "external" {
  name     = var.external_network_name
  external = true
}

# New tenant network
resource "openstack_networking_network_v2" "test_net" {
  name           = var.network_name
  admin_state_up = true
}

# Subnet 10.0.20.0/24
resource "openstack_networking_subnet_v2" "test_subnet" {
  name            = "${var.network_name}-subnet"
  network_id      = openstack_networking_network_v2.test_net.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers 
    tags = {
    Tier = "Private"
    name = "Lustre_subnet"
  }
}

# Router with uplink to external network
resource "openstack_networking_router_v2" "test_router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

# Attach the subnet to the router
resource "openstack_networking_router_interface_v2" "test_router_iface" {
  router_id = openstack_networking_router_v2.test_router.id
  subnet_id = openstack_networking_subnet_v2.test_subnet.id
}



variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
resource "aws_vpc" "lustre_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "lustre-vpc"
  }
}

# RESOURCE 2) an "aws_security_group" is like the rules what network connections are 
#             allowed for the "aws_instance" we use this resource 
resource "aws_security_group" "our_security_group" {
  # rules about incoming network connections to the instance
  name = "Lustre_SG"
  vpc_id = aws_vpc.lustre_vpc.id
  ingress {
    # allowed port(s) starting form this port number to and from port
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # the allowed ip origins this rule applies to (0.0.0.0/0) is all ipv4 addresses "everyone"
    cidr_blocks = ["0.0.0.0/0"]
    }

  # Allow internal SSH between instances
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr]
  }
    # Give access to squid so dnf can install components in the internal servers
    ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr]
  }

  # Allow Lustre traffic internally
  ingress {
    from_port   = 988
    to_port     = 988
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr]
  }
  egress {
    # same as above, just for outgoing
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "lustre-security-group"
  }
}

# Route table for internet access
resource "aws_route_table" "lustre_route_table" {
  vpc_id = aws_vpc.lustre_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lustre-gw.id
  }

  tags = {
    Name = "lustre-route-table"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "lustre_route_assoc" {
  subnet_id      = aws_subnet.lustre_subnet.id
  route_table_id = aws_route_table.lustre_route_table.id
}


resource "aws_internet_gateway" "lustre-gw" {
  vpc_id = aws_vpc.lustre_vpc.id
  tags = {
    Name = "test-env-gw"
  }
}

output "aws_subnet_id" {
  value = aws_subnet.lustre_subnet.id 
}
output "aws_security_gp_id" {
  value = aws_security_group.our_security_group.id
}