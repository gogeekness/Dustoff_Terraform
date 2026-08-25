### operator_ssh.tf
## The key YOU use to SSH into Bastion from the home network. Separate from
## whatever key Bastion later uses to reach the Lustre/K8s/Slurm VMs it
## creates — that one lives on the modules/lustre/kubernetes/slurm side,
## not here.

resource "openstack_compute_keypair_v2" "operator" {
  name       = "bastion-operator"
  public_key = file(pathexpand(var.operator_ssh_public_key_path))
}
