output "fixed_ip_v4" {
  value = openstack_networking_port_v2.this.all_fixed_ips[0]
}
