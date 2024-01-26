resource "aws_lb" "elastic_nlb" {
  name               = "ece-load-balancer-network"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.load_balancer.id]

  subnet_mapping {
    subnet_id     = var.public_subnet_1_id
    allocation_id = aws_eip.elastic_nlb_1.id

  }

  subnet_mapping {
    subnet_id     = var.public_subnet_2_id
    allocation_id = aws_eip.elastic_nlb_2.id

  }
}

resource "aws_lb" "elastic_alb" {
  name               = "ece-load-balancer-application"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [var.private_subnet_1_id, var.private_subnet_2_id]
}

resource "aws_eip" "elastic_nlb_1" {
  tags = {
    Name = "ece-load-balancer"
  }
}

resource "aws_eip" "elastic_nlb_2" {
  tags = {
    Name = "ece-load-balancer"
  }
}

### Create a temporary self-signed certificate for the load balancer to use until the Let's Encrypt certificate is created
resource "tls_private_key" "load_balancer_tls_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "load_balancer_tls_cert" {
  private_key_pem = tls_private_key.load_balancer_tls_key.private_key_pem
  subject {
    common_name = var.ece_domain
  }
  dns_names = [
    var.ece_domain,
    "*.${var.ece_domain}",
    "*.fleet.${var.ece_domain}",
    "*.apm.${var.ece_domain}",
  ]
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "load_balancer_tls_cert" {
  private_key      = tls_private_key.load_balancer_tls_key.private_key_pem
  certificate_body = tls_self_signed_cert.load_balancer_tls_cert.cert_pem
}

resource "aws_lb_target_group" "ece_targets_nlb" {
  for_each                      = local.ece_load_balancer_target_ports_nlb
  name                          = "ece-server-nlb-${each.key}-${lower(each.value.protocol)}"
  target_type                   = each.value.target_type
  port                          = each.key
  protocol                      = each.value.protocol
  proxy_protocol_v2             = each.value.proxy_protocol_v2
  load_balancing_algorithm_type = each.value.protocol == "TCP" ? null : each.value.load_balancing_algorithm_type
  vpc_id                        = var.vpc_id

  health_check {
    enabled             = each.value.health_monitor_enabled
    protocol            = each.value.health_monitor_type
    path                = each.value.health_monitor_url_path
    port                = each.value.health_monitor_port
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = each.value.health_monitor_expected_codes
  }

}

resource "aws_lb_target_group" "ece_targets_alb" {
  for_each                      = local.ece_load_balancer_target_ports_alb
  name                          = "${each.value.name}-${lower(replace(each.value.protocol, "_", "-"))}"
  port                          = each.key
  protocol                      = each.value.protocol
  load_balancing_algorithm_type = each.value.load_balancing_algorithm_type
  vpc_id                        = var.vpc_id

  health_check {
    enabled             = each.value.health_monitor_enabled
    protocol            = each.value.health_monitor_type
    path                = each.value.health_monitor_url_path
    port                = each.key
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = each.value.health_monitor_expected_codes
  }
}

resource "aws_lb_target_group_attachment" "ece_targets_nlb" {
  count            = length(local.ece_load_balancer_target_members_nlb)
  target_group_arn = local.ece_load_balancer_target_members_nlb[count.index].target_group_arn
  target_id        = local.ece_load_balancer_target_members_nlb[count.index].target_id
  port             = local.ece_load_balancer_target_members_nlb[count.index].port
  depends_on = [ aws_lb_listener.alb_listeners ]
}

resource "aws_lb_target_group_attachment" "ece_targets_alb" {
  count            = length(local.ece_load_balancer_target_members_alb)
  target_group_arn = local.ece_load_balancer_target_members_alb[count.index].target_group_arn
  target_id        = local.ece_load_balancer_target_members_alb[count.index].target_id
  port             = local.ece_load_balancer_target_members_alb[count.index].port
}


resource "aws_lb_listener" "alb_listeners" {
  for_each          = { for key, val in var.ece_load_balancer_listener_ports : key => val if val.alb_protocol != null }
  load_balancer_arn = aws_lb.elastic_alb.arn
  port              = each.key
  protocol          = each.value.alb_protocol
  ssl_policy        = each.value.alb_protocol == "HTTPS" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   = each.value.alb_protocol == "HTTPS" ? aws_acm_certificate.load_balancer_tls_cert.arn : null

  default_action {
    type             = each.value.redirect_to_https ? "redirect" : "forward"
    target_group_arn = each.value.default_target_port != null ? aws_lb_target_group.ece_targets_alb[each.value.default_target_port].id : null

    dynamic "redirect" {
      for_each = each.value.redirect_to_https ? [each.value.https_port] : []
      content {
        host        = "#{host}"
        path        = "/#{path}"
        port        = redirect.value
        protocol    = "HTTPS"
        query       = "#{query}"
        status_code = "HTTP_301"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      certificate_arn
    ]
  }
  depends_on = [ aws_lb_target_group_attachment.ece_targets_alb ]
}

resource "aws_lb_listener" "nlb_listeners" {
  for_each          = var.ece_load_balancer_listener_ports
  load_balancer_arn = aws_lb.elastic_nlb.arn
  port              = each.key
  protocol          = each.value.nlb_protocol
  ssl_policy        = each.value.nlb_protocol == "TLS" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   = each.value.nlb_protocol == "TLS" ? aws_acm_certificate.load_balancer_tls_cert.arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ece_targets_nlb[each.key].id
  }

  depends_on = [ aws_lb_target_group_attachment.ece_targets_nlb ]
}

resource "aws_lb_listener_rule" "letencrypt_rule" {
  listener_arn = aws_lb_listener.alb_listeners[80].arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = local.ece_load_balancer_target_ids["letsencrypt-validation-http"]
  }
  condition {
    path_pattern {
      values = ["/.well-known/acme-challenge", "/.well-known/acme-challenge/*"]
    }
  }

}

