# ── Call the network module ───────────────────────────────────────────────────
module "lust_net" {
  source = "./Lustre_Net"
  network_name          = lust_net.network_name
  subnet_cidr           = lust_net.subnet_cidr
  router_name           = lust_net.router_name

}

# ── Render cloud-init ─────────────────────────────────────────────────────────

# data "template_file" "user_data" {
#   template = file("${path.module}/templates/user-data.yaml.tpl")
#   vars = {
#     ssh_public_key = var.ssh_public_key
#   }
# }

# ── Ubuntu image reference ────────────────────────────────────────────────────
data "openstack_images_image_v2" "ubuntu_2404" {
  id = "2cf93f7d-8a8f-4153-b7c7-aaaa54ae1e98"
}

# ── Boot volume ───────────────────────────────────────────────────────────────
resource "openstack_blockstorage_volume_v3" "root" {
  name     = "${var.instance_name}-root"
  size     = 20
  image_id = data.openstack_images_image_v2.ubuntu_2404.id
}

# ── Instance ──────────────────────────────────────────────────────────────────
resource "openstack_compute_instance_v2" "vm" {
  name            = var.instance_name
  flavor_name     = var.flavor_name
  key_pair        = var.keypair_name
  security_groups = [openstack_networking_secgroup.ssh.name]
  # user_data       = data.template_file.user_data.rendered

  block_device {
    uuid                  = openstack_blockstorage_volume.root.id
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