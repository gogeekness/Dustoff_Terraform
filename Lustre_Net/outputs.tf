## The output from Netwroking
#   Module is to split the 

output "network_id" {
  description = "ID of the created tenant network"
  value       = openstack_networking_network.net.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = openstack_networking_subnet.subnet.id
}

output "router_id" {
  description = "ID of the created router"
  value       = openstack_networking_router.router.id
}

output "external_network_id" {
  description = "ID of the external network (for floating IP pool)"
  value       = data.openstack_networking_network.external.id
}

# Convenience: expose the router interface so instance.tf can depend_on it
output "router_interface_id" {
  description = "Router interface resource ID — use in depends_on"
  value       = openstack_networking_router_interface.router_iface.id
}

output "external_network_name" {
  description = "Name of the external network (for floating IP pool)"
  value       = openstack_networking_network.external.name
}

output "lust_net_cidr" {
  description = "CIDR of the created subnet"
  value       = var.subnet_cidr
}
