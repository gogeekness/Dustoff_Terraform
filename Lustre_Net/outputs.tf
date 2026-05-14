## The output from Netwroking
#   Module is to split the 

output "network_id" {
  description = "ID of the created tenant network"
  value       = openstack_networking_network_v2.net.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = openstack_networking_subnet_v2.subnet.id
}

output "router_id" {
  description = "ID of the created router"
  value       = openstack_networking_router_v2.router.id
}

output "external_network_id" {
  description = "ID of the external network (for floating IP pool)"
  value       = data.openstack_networking_network_v2.external.id
}

# Convenience: expose the router interface so instance.tf can depend_on it
output "router_interface_id" {
  description = "Router interface resource ID — use in depends_on"
  value       = openstack_networking_router_interface_v2.router_iface.id
}

output "external_network_name" {
  description = "Name of the external network (for floating IP pool)"
  value       = openstack_networking_network_v2.external.name
}
