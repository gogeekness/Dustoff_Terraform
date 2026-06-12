# terraform is now "commercial/proprietary" hence we go with drop replacement opentofu (free software)
# Opentofu/Terraform work by writing "resources" that one wants to be created
# those resources can then
# a) be easily planned + applyed (i.e. created) 
#    # tofu plan -out ourplan
#    # tofu apply outplan
# b) be as easily removed/deletet/destroyed 
#    # tofu destroy
#
# in this file we setup the "modules" and "terraform" stuff 
# so that aws resources can be managed via terraform 

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.1.0"
    }
  
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.3.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = file(pathexpand("~/.ssh/terraf_passcode"))
  auth_url    = "http://192.168.178.210:5000/v3"
  region      = "RegionOne"
}