

resource "aws_network_interface" "elastic" {
  for_each        = local.ece_servers
  subnet_id       = var.private_subnet_1_id
  private_ips     = [each.value.ip_address]
  security_groups = [aws_security_group.ece_servers.id]
  tags = {
    Name       = each.value.name
    managed-by = "terraform"
  }
}

resource "aws_instance" "ece_servers" {
  for_each      = local.ece_servers
  ami           = data.aws_ami.elastic.id
  instance_type = each.key == "0" ? var.elastic_primary_flavor : var.elastic_flavor
  key_name      = var.keypair_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.elastic[each.key].id
  }

  root_block_device {
    delete_on_termination = true
    iops                  = 3000
    volume_type           = "gp3"
    volume_size           = 30
  }

  ebs_block_device {
    device_name = "/dev/${var.ece_device_name_aws}"
    iops        = 3000
    volume_size = 400
    volume_type = "gp3"
  }

  tags = {
    Name       = each.value.name
    managed-by = "terraform"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}
