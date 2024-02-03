output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "vpn_security_group_id" {
  value = aws_security_group.vpn_server.id
}

output "keypair_name" {
  value = aws_key_pair.this.key_name
}

output "public_network_cidrs" {
  value = local.public_network_cidrs
}

output "private_network_cidrs" {
  value = local.private_network_cidrs
}

output "availability_zones" {
  value = local.availability_zones
}
