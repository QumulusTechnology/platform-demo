

data "aws_ami" "management_instance" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.management_instance_ami]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = [var.ubuntu_ami_owner]
}

data "aws_ami" "elastic" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.elastic_ami]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = [var.ubuntu_ami_owner]
}

data "archive_file" "management_instance_files_1" {
  type        = "zip"
  output_path = "${path.module}/.management_instance_1.zip"
  source_dir  = "${path.module}/../load-balanced-elastic-search/files"
}

data "archive_file" "management_instance_files_2" {
  type        = "zip"
  output_path = "${path.module}/.management_instance_2.zip"
  source {
    content  = local.hosts_file
    filename = "hosts"
  }
  source {
    content  = <<EOT
[defaults]
host_key_checking = False
log_path = /home/${var.ece_user}/ansible.log
EOT
    filename = ".ansible.cfg"
  }
  source {
    content  = file(var.private_ssh_key_path)
    filename = ".ssh/${basename(var.private_ssh_key_path)}"
  }
  source {
    content  = <<EOT
#!/bin/bash
sudo -u ubuntu ansible-playbook -i /home/${var.ece_user}/hosts /home/${var.ece_user}/certbot_post_deploy.yml
EOT
    filename = "certbot_post_deploy.sh"
  }
}
