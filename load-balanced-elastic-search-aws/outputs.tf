output "load_balancer_dns" {
  value = <<EOT
Please create the following DNS Records

TYPE: A
DOMAIN_NAME: ${var.ece_domain}
VALUE: ${aws_eip.elastic_nlb[0].public_ip}

TYPE: A
DOMAIN_NAME: *.${var.ece_domain}
VALUE: ${aws_eip.elastic_nlb[0].public_ip}

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

ssh -i ${var.private_ssh_key_path} ${var.ece_user}@${aws_instance.management_instance.private_ip}

From you can see what is happening by looking at the following files:

'~/ansible.log'
'~/script_errors.log'
'~/script_timings.log'
'~/.rally/logs/rally.log'

you can find elastic urls and credentials in '~/config.json'

Note:

The ssl certificate is initially self signed and you will need to accept the certificate in your browser before you can access the management interface.
The services will take a few minutes to set up and you can check the progress by looking at the '~/script_timings.log' file.
The above files will take time to appear, so if you don't see them right away, wait a few minutes and try again.
After everything is setup, the install script will attempt to upload a letsencrypt certificate to the load balancer, however for this to work, the domain name must be pointing to the load balancer public IP address or it will fail.
You can re-run the certificate installation script by running the following command: `ansible-playbook -i hosts certbot.yml` but it should only be attempted after you see 'Starting certbot installation' in the '~/script_timings.log' file as it depends on outputs from the elastic deployment process.

(You will need to be connected to the vpn to connect to the management instance)
EOT
}
