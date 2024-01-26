

resource "aws_network_interface" "elastic" {
  count           = length(var.private_subnet_ids)
  subnet_id       = var.private_subnet_ids[count.index]
  private_ips     = [cidrhost(var.private_network_cidrs[count.index], 11)]
  security_groups = [aws_security_group.ece_servers.id]
  tags = {
    Name       = "ece-server-${count.index + 1}"
    managed-by = "terraform"
  }
}

resource "aws_instance" "ece_servers" {
  count         = length(var.private_subnet_ids)
  ami           = data.aws_ami.elastic.id
  instance_type = count.index == 0 ? var.elastic_primary_flavor : var.elastic_flavor
  key_name      = var.keypair_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.elastic[count.index].id
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp3"
  }

  ebs_block_device {
    device_name           = "/dev/${var.ece_device_name_aws}"
    delete_on_termination = true
    volume_size           = 300
    volume_type           = "gp3"
  }

  tags = {
    Name       = "ece-server-${count.index + 1}"
    managed-by = "terraform"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}
