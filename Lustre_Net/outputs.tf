## The output from Netwroking
#   Module is to split the 

output "network_id" {
  description = "ID of the created tenant network"
  value       = openstack_networking_network_v2.Lustre_Net.id
  }

output "subnet_id" {
  description = "ID of the created subnet"
  value       = openstack_networking_subnet_v2.Lustre_subnet.id
}

output "router_interface_id" {
  description = "ID of the created router"
  value       = openstack_networking_router_v2.Lustre_router.id
  
}

