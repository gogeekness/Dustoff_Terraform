### modules/project_net/main.tf
## Network, subnet, and a dedicated router with SNAT egress to the external
## network. No floating IPs are allocated here on purpose — Bastion is the
## only thing meant to be reachable from outside; everything else gets to
## Bastion via modules/bastion_link instead.

resource "openstack_networking_network_v2" "this" {
  name           = var.network_name
  admin_state_up = true
}

data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

resource "openstack_networking_subnet_v2" "this" {
  name            = var.subnet_name
  network_id      = openstack_networking_network_v2.this.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

resource "openstack_networking_router_v2" "this" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
  enable_snat         = true
}

resource "openstack_networking_router_interface_v2" "this" {
  router_id = openstack_networking_router_v2.this.id
  subnet_id = openstack_networking_subnet_v2.this.id
}
