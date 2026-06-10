### Lustre_Instance / main.tf
##  This file defines the OpenStack resources for the Lustre cluster instances. 
##  It uses a module to create multiple instances based on a list of server configurations defined in variables.tf.

# ── Ubuntu image reference ────────────────────────────────────────────────────
data "openstack_images_image_v2" "ubuntu_2404" {
  name        = "Ubuntu 24.04 LTS" 
  most_recent = true
  # id = "2cf93f7d-8a8f-4153-b7c7-aaaa54ae1e98"
}

# ── Boot volume ───────────────────────────────────────────────────────────────
resource "openstack_blockstorage_volume_v3" "root" {
  name     = "${var.instance_name}"
  size     = var.OS-size
  image_id = openstack_blockstorage_volume_v3.root.id  
  #image_id = data.openstack_images_image_v2.ubuntu_2404.id
}

### build build build
# ── Instance ──────────────────────────────────────────────────────────────────
resource "openstack_compute_instance_v2" "vm" {
  name            = var.instance_name
  flavor_name     = var.instance_type
  key_pair        = var.openstack_key_pub
  security_groups = [module.lust_net.security_group.name]

  block_device {
    uuid                  = var.instance_name
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid = module.lust_net.network_id   # <-- from module output
  }
  depends_on = [module.lust_net.router_interface_id]
}

# ── Floating IP ─── Capture ─────────────────────────────────────────────────────
# resource "openstack_networking_floatingip_v2" "fip" {
#   pool = module.lust_net.external_network_name
# }

# resource "openstack_compute_floatingip_associate_v2" "fip_assoc" {
#   floating_ip = openstack_networking_floatingip_v2.fip.address
#   instance_id = openstack_compute_instance_v2.vm.id
# }