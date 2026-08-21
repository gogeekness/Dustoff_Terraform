### security_group.tf
## Bastion is the only VM in this environment with a floating IP, so this is
## the entire external attack surface: SSH from the home network only.

resource "openstack_networking_secgroup_v2" "bastion" {
  name        = "bastion-sg"
  description = "SSH from home network only"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_from_home" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.home_network_cidr
  security_group_id = openstack_networking_secgroup_v2.bastion.id
}

resource "openstack_networking_secgroup_rule_v2" "egress_all" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion.id
}
