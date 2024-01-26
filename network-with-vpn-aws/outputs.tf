output "vpc_id" {
    value = aws_vpc.this.id
}

output "public_subnet_1_id" {
    value = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
    value = aws_subnet.public_2.id
}

output "private_subnet_1_id" {
    value = aws_subnet.private_1.id
}

output "private_subnet_2_id" {
    value = aws_subnet.private_2.id
}

output "vpn_security_group_id" {
    value = aws_security_group.vpn_server.id
}

output "keypair_name" {
    value = aws_key_pair.this.key_name
}
