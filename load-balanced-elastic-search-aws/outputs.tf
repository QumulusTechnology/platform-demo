output "load_balancer_dns" {
  value = <<EOT
Please create the following DNS Records

TYPE: A
DOMAIN_NAME: ${var.ece_domain}
VALUE: ${aws_eip.elastic_nlb_2.public_ip}

TYPE: A
DOMAIN_NAME: *.${var.ece_domain}
VALUE: ${aws_eip.elastic_nlb_2.public_ip}

EOT
}

output "management_instance_files_1_sha256" {
  value = data.archive_file.management_instance_files_1.output_sha256
}

output "management_instance_files_2_sha256" {
  value = data.archive_file.management_instance_files_2.output_sha256
}

output "management_instance_connection" {
  value = <<EOT
You can connect to the ece management instance using the following command:

ssh -i ${var.private_ssh_key_path} ${var.ece_user}@${cidrhost(local.private_network_cidr_1, 11)}

(You will need to be connected to the vpn to connect to the management instance)
EOT
}
