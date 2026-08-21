### modules/bastion_link/main.tf

data "openstack_compute_instance_v2" "bastion" {
  name = var.bastion_instance_name
}

resource "openstack_networking_port_v2" "this" {
  name       = "bastion-link-${var.network_id}"
  network_id = var.network_id

  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = var.fixed_ip
  }
}

resource "openstack_compute_interface_attach_v2" "this" {
  instance_id = data.openstack_compute_instance_v2.bastion.id
  port_id     = openstack_networking_port_v2.this.id
}
