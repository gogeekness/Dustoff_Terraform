## The output from Netwroking
#   Module is to split the 

output "network_id" {
  description = "ID of the created tenant network"
  value       = openstack_networking_network_v2.Lustre_Network.id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = openstack_networking_subnet_v2.subnet.id
}

output "router_interfaceid" {
  description = "ID of the created router"
  value       = openstack_networking_router.interface_v2.Lustre_Router.id 
}

