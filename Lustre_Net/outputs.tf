## The output from Netwroking
#   Module is to split the 

# output "vpc_id" {
#   value = aws_vpc.lustre_vpc.id
# }

# output "subnet_id" {
#   value = aws_subnet.lustre_subnet.id
# }

output "availability_zone" {
  value = var.availability_zone
}

# output "aws_subnet" {
#   value = aws_subnet.lustre_subnet
# }

# output "subnet" {
#   value = aws_subnet.lustre_subnet
# }

# output "security_group_id" {
#   value = aws_security_group.our_security_group.id
# }

# output "security_group" {
#   value = aws_security_group.our_security_group
# }