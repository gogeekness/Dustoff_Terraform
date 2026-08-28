### modules/bastion_instance/main.tf
## To create the bastion instance and the supporting network.
## The The plan is only to be run on the host. 
## Everything else will be seaperate and will be ran on the bastion. 



data "openstack_images_image_v2" "this" {
  name        = var.image_name
  most_recent = true
}

resource "openstack_compute_instance_v2" "this" {
  name            = var.instance_name
  flavor_name     = var.instance_type
  key_pair        = var.keypair_name
  security_groups = var.security_group_names
  image_id        = data.openstack_images_image_v2.this.id

  user_data = templatefile("${path.module}/templates/user-data.yaml.tpl", {
    ssh_public_key = var.ssh_public_key
  })

  network {
    uuid = var.network_id
  }
}

resource "openstack_networking_floatingip_v2" "this" {
  pool = var.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "this" {
  floating_ip = openstack_networking_floatingip_v2.this.address
  port_id     = openstack_compute_instance_v2.this.network[0].port
}
