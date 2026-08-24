output "instance_id" {
  value = openstack_compute_instance_v2.this.id
}

output "port_id" {
  value = openstack_compute_instance_v2.this.network[0].port
}

output "fixed_ip_v4" {
  value = openstack_compute_instance_v2.this.network[0].fixed_ip_v4
}
