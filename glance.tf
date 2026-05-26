### Terraform Glance Image access
##
# 

data "openstack_images_image_v2" "ubuntu_24-04"{
  # source            = "/v2/images/2cf93f7d-8a8f-4153-b7c7-aaaa54ae1e98/file"
  name              = "Ubuntu 24.04 LTS"
  most_recent       = true
}


#  disk_format      = "qcow2"
#  container_format = "bare"
#  visibility       = "public"
#  local_file_path  = "/v2/images/2cf93f7d-8a8f-4153-b7c7-aaaa54ae1e98/file"