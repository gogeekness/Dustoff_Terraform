# Known-good values already true of this OpenStack. bastion_flavor is
# deliberately not set here — tofu will prompt for it at plan/apply time
# until you fill it in from `openstack flavor list`.

bastion_network_name  = "Bastion-net"
bastion_router_name   = "Bastion-router"
external_network_name = "public1"
