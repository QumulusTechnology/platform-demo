resource "aws_security_group" "load_balancer" {
  vpc_id = var.vpc_id
  tags = {
    Name = "load-balancer"
  }
}

resource "aws_security_group_rule" "load_balancer_ingress_rules" {
  for_each          = local.ece_load_balancer_listener_ports
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.key
  to_port           = each.key
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
  description       = "${each.key}: from-internet"
}

resource "aws_security_group_rule" "load_balancer_internal_traffic_ingress" {
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.load_balancer.id
  security_group_id        = aws_security_group.load_balancer.id
  description              = "load-balancer-internal-traffic - egress"
}

resource "aws_security_group_rule" "load_balancer_internal_traffic_egress" {
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.load_balancer.id
  security_group_id        = aws_security_group.load_balancer.id
  description              = "load-balancer-internal-traffic - ingress"
}

resource "aws_security_group" "management_instance" {
  vpc_id = var.vpc_id
  tags = {
    Name = "management-instance"
  }
}

resource "aws_security_group_rule" "management_instance_internet_access" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.management_instance.id
  description       = "management instance internal access"
}

resource "aws_security_group_rule" "management_instance_vpn_access_ingress" {
  description              = "allow vpn users access to management instance"
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = var.vpn_security_group_id
  security_group_id        = aws_security_group.management_instance.id
}

resource "aws_security_group_rule" "management_instance_vpn_access_egress" {
  description              = "allow vpn users access to management instance"
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.management_instance.id
  security_group_id        = var.vpn_security_group_id
}

resource "aws_security_group_rule" "management_instance_letencrypt_rules" {
  for_each                 = { for key, val in var.ece_load_balancer_target_ports : key => val if val.role == "letsencrypt" }
  description              = "${each.key}: from-load-balancer"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = each.key
  to_port                  = each.key
  source_security_group_id = aws_security_group.load_balancer.id
  security_group_id        = aws_security_group.management_instance.id

}

resource "aws_security_group_rule" "load_balancer_letencrypt_rules" {
  for_each                 = { for key, val in var.ece_load_balancer_target_ports : key => val if val.role == "letsencrypt" }
  description              = "${each.key}: to-management-instance"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = each.key
  to_port                  = each.key
  source_security_group_id = aws_security_group.management_instance.id
  security_group_id        = aws_security_group.load_balancer.id
}

resource "aws_security_group" "ece_servers" {
  vpc_id = var.vpc_id
  tags = {
    Name = "ece-servers"
  }
}

resource "aws_security_group_rule" "ece_servers_internet_access" {
  description       = "ece-servers internet access"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ece_servers.id
}

resource "aws_security_group_rule" "ece_servers_from_vpn" {
  description              = "allow vpn users access to ece servers"
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = var.vpn_security_group_id
  security_group_id        = aws_security_group.ece_servers.id
}

resource "aws_security_group_rule" "ece_servers_from_management_instance" {
  description              = "allow management instance access to ece servers"
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.management_instance.id
  security_group_id        = aws_security_group.ece_servers.id
}

resource "aws_security_group_rule" "ece_servers_internal_traffic" {
  description              = "allow ece servers to communicate with each other"
  type                     = "ingress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.ece_servers.id
  security_group_id        = aws_security_group.ece_servers.id
}

resource "aws_security_group_rule" "ece_servers_from_load_balancer" {
  for_each                 = { for key, val in var.ece_load_balancer_target_ports : key => val if contains(["director", "coordinator", "proxy", "allocator"], val.role) }
  description              = "${each.key}: from-load-balancer"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = each.key
  to_port                  = each.key
  security_group_id        = aws_security_group.ece_servers.id
  source_security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "load_balancer_to_ece_servers" {
  for_each                 = { for key, val in var.ece_load_balancer_target_ports : key => val if contains(["director", "coordinator", "proxy", "allocator"], val.role) }
  description              =  "${each.key}: to-ece-servers"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = each.key
  to_port                  = each.key
  security_group_id        = aws_security_group.load_balancer.id
  source_security_group_id = aws_security_group.ece_servers.id
}
