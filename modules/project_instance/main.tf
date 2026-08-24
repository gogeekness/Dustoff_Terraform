### modules/project_instance/main.tf

data "openstack_images_image_v2" "this" {
  name        = var.image_name
  most_recent = true
}

# ── Optional boot volume (Cinder) ───────────────────────────────────────────
resource "openstack_blockstorage_volume_v3" "root" {
  count    = var.boot_from_volume ? 1 : 0
  name     = "${var.instance_name}-root"
  size     = var.root_volume_size_gb
  image_id = data.openstack_images_image_v2.this.id
}

# ── Optional extra data volume (Cinder) — e.g. Lustre MDT/OST ──────────────
resource "openstack_blockstorage_volume_v3" "data" {
  count = var.data_volume_size_gb != null ? 1 : 0
  name  = "${var.instance_name}-data"
  size  = var.data_volume_size_gb
}

# ── Instance ─────────────────────────────────────────────────────────────────
resource "openstack_compute_instance_v2" "this" {
  name            = var.instance_name
  flavor_name     = var.instance_type
  key_pair        = var.keypair_name
  security_groups = var.security_group_names
  user_data       = var.user_data

  # Boots straight from the image via the flavor's local disk unless
  # boot_from_volume is set, in which case it uses the Cinder root volume.
  image_id = var.boot_from_volume ? null : data.openstack_images_image_v2.this.id

  dynamic "block_device" {
    for_each = var.boot_from_volume ? [1] : []
    content {
      uuid                  = openstack_blockstorage_volume_v3.root[0].id
      source_type           = "volume"
      destination_type      = "volume"
      boot_index            = 0
      delete_on_termination = true
    }
  }

  network {
    uuid        = var.network_id
    fixed_ip_v4 = var.fixed_ip
  }
}

resource "openstack_compute_volume_attach_v2" "data" {
  count       = var.data_volume_size_gb != null ? 1 : 0
  instance_id = openstack_compute_instance_v2.this.id
  volume_id   = openstack_blockstorage_volume_v3.data[0].id
}
