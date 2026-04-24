# Terraform_Lustre and OpenStack
This is a repo to create a Lustre FS cluster with Terraform and OpenStack

To run Tofu (Open source version Terraform), I use a Bastion MV for ToFu and to hold OpenStack's credenticals
You will that access to use the Tofu setup here. 

Requirements 
* Linux envrionment, bash is used as a wraper script.
* docker (docker engine) 27.3.0 or later (optional)
* docker-compose 1.29.2 or later (optional) 
* Python 3.10 or later  (My servers have 3.11)
* ToFu will be installed online
* Ansible 2.16 or above


There is a secrets file that is used by `variables.tf`.
### secrets.auto.tfvar 
This file contains keys to access OpenStack API and use SSH
The Vendor is to be OpenStack

Fill these variable with your specific credentails, by secrets file, password keeper, or vault.

### Ansible
Using Ansible to configure the servers and mounts.
The playbook will add the private ssh key to the client server, allowing it to reach the others.
When up, the scrip will copy you profile from `$(USER) ./.ssh` 
Then, log into the client system to then ssh into the 2 servers (MGT & OSS)

#### Anisble updates 
Ansible on some Linux is too old for the special plugins.
Linux Mint/Ubuntu at the time of writing only has version 2.10
Remove the old ansible
 1. `sudo apt remove ansible`
 2. `sudo apt --purge ansible`
Then update Linux
 1. `sudo apt update`
 2. `sudo apt upgrade`
Then update the apt source lists
 1. `sudo apt -y install software-properties-common`
 2. `sudo apt-add-repository ppa:ansible/ansible`
Then install the lastest Ansible. If this install is still the old verion, then restart and try installing again
 1. `sudo apt install ansible`

### The base diskimage and snapshot
If you entend to use this image and snapshot, be aware that the build in user is `ec-user`.
Once you are in the VMs update the active users, the Ansibel code will do that.
I included my ZFS install commands so you can create your ZFS installation on Alma8 
The snapshot should have python3 set to verion 3.11 
*  Do it here with the snap shot as updating through the client (Bastion) is more involved.
*  Do it here one and then use the snapshot as a template for the other servers.


### Bash adn command line
The scrip will create the container with Tofu, AWS CLI, and Ansible.
Run Tofo on AWS then pass the public IP to Ansible to configure.
Then the script will run the contrainer creating the Lustre cluster by Tofu.
* The `Lustre.sh` is more of draft in I have not tested it.
  *  I have used parts of it when I started to create my inital vm, then created a snapshot of the OS disk.
  *  However, the commands as a sequence works.  This is who I solved the installation of ZFS on Alma 8 (manualy).    

### Cluster layout, lustre file system name is: Lust 
* lustre_mgt    (IB: 10.0.0.?) for the MGT, MDS and MDT.
* lustre_oss    (IB: 10.0.0.?) for the OSS and OST.
* lustre_client (IB: 10.0.0.?) for the client.

All of the servers have 30 GB data drives (scratch pad) for extra working data.
The OSS drive has a extra drive 2 TB drive for ZFS.

The Client also is a jumpbox or bastion to the other two servers.  I only public IP is to the Client.
From it, Ansible can tunnel to the other two machines.  That IP is created by AWS, then the Ansible Invtory plugin reads it.
 
## The goal
To have a working Lustre test Cluster with a couple of commands.
Then direct access to create and use a simple Lustre FS and use the commands. 
This is not ment to be a usable cluster as the OSS and the MD servers are only link by 1G network.  It is very slow compared to a proper cluster.

## The Path
While so far I have not reached my goal the path has been rewarding.
* Learn Terraform.  I can depoy various infrasture layout by TF
* More time with Ansible.  Learn better ways of implementing Ansible in AWS and understand some of Anislble's limitations.
  

# Runing commands on Tofu and Ansible
### To run commands in Tofu

### Runing Ansible
- Use a variation of `ansible-playbook -vv -i ../Terraform_Lustre/inventory/Lustre_aws_ec2.yml --ask-vault-password ../Terraform_Lustre/playbook.yml`
- - Ansible and Playbook
- - vv for verbosity (v - vvvv)
- - The inventory, for me using "...aws_ec2.yml" 
- - - This is a special Invnetory plugin for Ansible that pulls AWS data of your infrastructure. 
- - - https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_ec2_inventory.html
- - A password for a local ansible vault (optional)
