output "bastion_floating_ip" {
  description = "SSH here: ssh reseke@<this>"
  value       = module.bastion.floating_ip_address
}

output "bastion_instance_id" {
  value = module.bastion.instance_id
}
