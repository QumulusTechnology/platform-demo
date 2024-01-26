# # This is the firewall group that allows SSH and WireGuard traffic to the VPN server
resource "aws_security_group" "vpn_server" {
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.trusted_networks
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = var.trusted_networks
  }
  tags = {
    Name = "vpn-server"
  }
}

# These are the WireGuard keys and preshared key that will be used to configure the VPN server
resource "wireguard_asymmetric_key" "default" {
}

resource "wireguard_asymmetric_key" "remote" {
}

resource "wireguard_preshared_key" "this" {
}


resource "aws_network_interface" "vpn_server_port" {
  subnet_id       = aws_subnet.public_1.id
  private_ips     = [local.internal_network_vpn_server_ip]
  security_groups = [aws_security_group.vpn_server.id]
}

resource "aws_eip" "vpn_server_public_ip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.vpn_server_port.id
  associate_with_private_ip = local.internal_network_vpn_server_ip
  tags = {
    Name       = "vpn-server"
    managed-by = "terraform"
  }
}

# This is the VPN server instance
resource "aws_instance" "vpn_server" {
  ami           = data.aws_ami.vyos.id
  instance_type = var.vpn_flavor
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.vpn_server_port.id
  }

  user_data = templatefile("${path.module}/templates/vpn_server_cloud_init.tftpl", {
    wireguard_interface_ip        = local.wireguard_network_vpn_server_ip,
    wireguard_network_cidr_prefix = local.wireguard_network_cidr_prefix,
    remote_peer_ip                = local.wireguard_network_remote_peer_ip,
    remote_peer_public_key        = wireguard_asymmetric_key.remote.public_key,
    default_private_key           = wireguard_asymmetric_key.default.private_key,
    default_public_key            = wireguard_asymmetric_key.default.public_key,
    wireguard_preshared_key       = wireguard_preshared_key.this.key,
  })

  key_name = aws_key_pair.this.key_name

  tags = {
    Name       = "vpn-server"
    managed-by = "terraform"
  }
    lifecycle {
    ignore_changes = [
      ami
     ]
  }
}

# This is the public IP address that will be used to connect to the VPN server
output "vpn_server_public_ip" {
  value = aws_eip.vpn_server_public_ip.public_ip
}

# # This is the WireGuard configuration file that will be used to configure the remote peer
resource "local_sensitive_file" "wireguard_config" {
  file_permission = "0600"
  content = templatefile("${path.module}/templates/wireguard_conf.tftpl", {
    vpn_server_public_ip          = aws_eip.vpn_server_public_ip.public_ip,
    remote_peer_ip                = local.wireguard_network_remote_peer_ip,
    internal_network_range        = var.internal_network_range,
    wireguard_network_cidr_prefix = local.wireguard_network_cidr_prefix,
    default_public_key            = wireguard_asymmetric_key.default.public_key,
    remote_peer_private_key       = wireguard_asymmetric_key.remote.private_key,
    wireguard_preshared_key       = wireguard_preshared_key.this.key,
  })

  filename = "${path.module}/../wireguard.conf"
}
