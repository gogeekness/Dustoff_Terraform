output "network_id" {
  value = openstack_networking_network_v2.this.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.this.id
}

output "router_id" {
  value = openstack_networking_router_v2.this.id
}
