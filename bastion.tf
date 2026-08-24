### bastion.tf

module "bastion" {
  source = "./modules/bastion_instance"

  instance_type          = var.bastion_flavor
  network_id             = data.openstack_networking_network_v2.bastion_net.id
  keypair_name           = openstack_compute_keypair_v2.operator.name
  security_group_names   = [openstack_networking_secgroup_v2.bastion.name]
  external_network_name  = var.external_network_name
  ssh_public_key         = trimspace(file(pathexpand(var.operator_ssh_public_key_path)))
}
