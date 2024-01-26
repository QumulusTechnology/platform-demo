resource "aws_network_interface" "management_instance_port" {
  subnet_id       = var.private_subnet_1_id
  private_ips     = [cidrhost(local.private_network_cidr_1, 11)]
  security_groups = [aws_security_group.management_instance.id]

  tags = {
    Name       = "management-instance-port"
    managed-by = "terraform"
  }
}

resource "aws_iam_role" "management_instance" {
  name               = "management_instance"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name       = "management-instance"
    managed-by = "terraform"
  }
}

resource "aws_iam_instance_profile" "management_instance" {
  name = "management_instance"
  role = aws_iam_role.management_instance.name
}

resource "aws_iam_role_policy" "management_instance_policy" {
  name = "management_instance_policy"
  role = aws_iam_role.management_instance.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": "${aws_s3_bucket.ece_install.arn}/*"
        },
       	{
          "Action": [
            "elasticloadbalancing:*",
            "acm:*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_instance" "management_instance" {
  ami                  = data.aws_ami.management_instance.id
  instance_type        = var.management_instance_flavor
  iam_instance_profile = aws_iam_instance_profile.management_instance.name
  key_name             = var.keypair_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.management_instance_port.id
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = 3000
    volume_type           = "gp3"
    volume_size           = 80
  }

  user_data_replace_on_change = true
  user_data                   = <<-EOT
#cloud-config
write_files:
  - content: |
      ${indent(6, local.install_ece_script)}
    path: /home/${var.ece_user}/install-ece.sh
    permissions: '0700'
runcmd:
  - chown -R ${var.ece_user}:${var.ece_user} /home/${var.ece_user}
  - su ${var.ece_user} /home/${var.ece_user}/install-ece.sh
EOT

  tags = {
    Name       = "management-instance"
    managed-by = "terraform"
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }

  depends_on = [aws_instance.ece_servers]
}
