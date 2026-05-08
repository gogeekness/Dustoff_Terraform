# AWS backend to keep the state of the Lusre cluster
# Opentofu/Terraform work by writing "resources" that one wants to be created

terraform {
  backend "s3" {
    bucket = "terraform-lustre-store"
    key = "./terraform.tfstate"
    region     = "eu-central-1"
    # access_key = var.Access_Key_ID
    # secret_key = var.Sercret_Access_Key
  }
}