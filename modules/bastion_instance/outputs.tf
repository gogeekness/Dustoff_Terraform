output "instance_id" {
  value = openstack_compute_instance_v2.this.id
}

output "floating_ip_address" {
  value = openstack_networking_floatingip_v2.this.address
}
