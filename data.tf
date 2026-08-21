### data.tf
## Bastion-net, Bastion-router, and public1 were created by hand (CLI), not
## Terraform — read as data sources rather than `terraform import`, so an
## apply here never tries to "fix" some manually-set attribute.

data "openstack_networking_network_v2" "bastion_net" {
  name = var.bastion_network_name
}

data "openstack_networking_subnet_v2" "bastion_net" {
  network_id = data.openstack_networking_network_v2.bastion_net.id
}

data "openstack_networking_router_v2" "bastion_router" {
  name = var.bastion_router_name
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}
