### Output values for the Lustre instance
###

output "instance_id" {
  description = "ID of the created instance"
  value       = openstack_compute_instance_v2.Lustre_Instance.id
}

output "instance_name" {
  description = "Name of the created instance"
  value       = openstack_compute_instance_v2.Lustre_Instance.name
}

