locals {
  availability_zones = [for z in var.zones : "${var.aws_region}${z}"]
  run_ansible        = var.run_ansible ? "su ${var.ece_user} /home/${var.ece_user}/install-ece.sh" : "echo 'Skipping ECE installation'"
  install_ece_script = templatefile("${path.module}/templates/install-ece.sh.tftpl", {
    run_ansible  = var.run_ansible,
    s3_bucket_id = aws_s3_bucket.ece_install.id
    s3_object_1  = aws_s3_object.management_instance_files_1.id
    s3_object_2  = aws_s3_object.management_instance_files_2.id
  })

  hosts_file = templatefile("${path.module}/templates/hosts.tftpl", {
    load_balancer_ip  = aws_eip.elastic_nlb[0].public_ip
    ece_domain        = var.ece_domain
    device            = var.ece_device_name_server
    ece_version       = var.ece_version
    ece_servers       = [for k, v in local.ece_servers : v]
    ece_servers_count = length(local.ece_servers)
    ssh_key_filename  = basename(var.private_ssh_key_path)
    user              = var.ece_user
    letsencrypt_email = var.letsencrypt_email
    aws_region        = var.aws_region
    load_balancer_arn = aws_lb.elastic_alb.arn
  })

  ece_servers = { for i, s in aws_instance.ece_servers :
    i => {
      name       = "ece-server-${i + 1}"
      type       = i == 0 ? "primary" : "secondary"
      roles      = i == 0 ? var.primary_server_roles : var.secondary_server_roles
      ip_address = s.private_ip
      index      = i
    }
  }

  ece_servers_with_instance_ids = { for k, v in local.ece_servers :
    k => {
      name        = v.name
      type        = v.type
      roles       = v.roles
      ip_address  = v.ip_address
      index       = v.index
      instance_id = aws_instance.ece_servers[k].id
    }
  }

  management_server = {
    length(local.ece_servers) = {
      name        = "management-instance"
      type        = "management-instance"
      roles       = ["letsencrypt"]
      ip_address  = aws_network_interface.management_instance_port.private_ip
      instance_id = aws_instance.management_instance.id
    }
  }

  all_servers = merge(local.ece_servers_with_instance_ids, local.management_server)

  ece_load_balancer_target_ports_alb = { for k, v in var.ece_load_balancer_target_ports :
    k => {
      name                          = v.name
      role                          = v.role
      protocol                      = v.protocol
      load_balancing_algorithm_type = v.load_balancing_algorithm_type
      description                   = v.description
      health_monitor_enabled        = true
      health_monitor_type           = v.health_monitor_type
      health_monitor_url_path       = v.health_monitor_url_path
      health_monitor_http_method    = v.health_monitor_http_method
      health_monitor_expected_codes = v.health_monitor_expected_codes

    }
    if v.protocol == "HTTP"
  }

  ece_load_balancer_target_ports_nlb = { for k, v in var.ece_load_balancer_listener_ports :
    k => {
      role                                  = v.alb_protocol != null ? "nlb" : var.ece_load_balancer_target_ports[v.default_target_port].role
      protocol                              = "TCP"
      load_balancing_algorithm_type         = v.alb_protocol != null ? "round_robin" : var.ece_load_balancer_target_ports[v.default_target_port].load_balancing_algorithm_type
      health_monitor_enabled                = v.alb_protocol != null ? true : var.ece_load_balancer_target_ports[v.default_target_port].health_monitor_enabled
      health_monitor_type                   = v.alb_protocol != null ? "HTTP" : var.ece_load_balancer_target_ports[v.default_target_port].health_monitor_type
      health_monitor_url_path               = v.alb_protocol != null ? "/" : var.ece_load_balancer_target_ports[v.default_target_port].health_monitor_url_path
      health_monitor_http_method            = v.alb_protocol != null ? null : var.ece_load_balancer_target_ports[v.default_target_port].health_monitor_http_method
      health_monitor_expected_codes         = v.alb_protocol != null ? 301 : var.ece_load_balancer_target_ports[v.default_target_port].health_monitor_expected_codes
      health_monitor_port                   = v.alb_protocol != null ? 80 : k
      redirect_to_application_load_balancer = v.alb_protocol != null ? true : false
      target_type                           = v.alb_protocol != null ? "alb" : "instance"
      proxy_protocol_v2                     = v.alb_protocol != null ? null : var.ece_load_balancer_target_ports[v.default_target_port].proxy_protocol_v2
    }
  }

  ece_load_balancer_listener_ports = { for k, v in var.ece_load_balancer_listener_ports :
    k => {
      "default_target_port" = v.default_target_port
      "protocol"            = v.alb_protocol != null ? v.alb_protocol : v.nlb_protocol
      "redirect_to_https"   = v.redirect_to_https
      "https_port"          = v.https_port
      "description"         = "${v.default_target_port == null ? "" : var.ece_load_balancer_target_ports[v.default_target_port].description}: ${v.alb_protocol != null ? v.alb_protocol : v.nlb_protocol}"
    }
  }

  ece_load_balancer_target_members_nlb_servers = flatten([for target_index, target in local.ece_load_balancer_target_ports_nlb : [
    for server_index, server in local.all_servers : {
      id               = "${server_index}-${target_index}"
      target_group_arn = aws_lb_target_group.ece_targets_nlb[target_index].arn
      name             = server.name
      target_id        = server.instance_id
      port             = target_index
    }
    if target.redirect_to_application_load_balancer == false && contains(server.roles, target.role)]
  ])

  ece_load_balancer_target_members_nlb_alb = [for target_index, target in local.ece_load_balancer_target_ports_nlb : {
    id               = "${target_index}"
    target_group_arn = aws_lb_target_group.ece_targets_nlb[target_index].arn
    target_id        = aws_lb.elastic_alb.arn
    port             = target_index
    }
    if target.redirect_to_application_load_balancer == true
  ]

  ece_load_balancer_target_members_nlb = concat(local.ece_load_balancer_target_members_nlb_servers, local.ece_load_balancer_target_members_nlb_alb)

  ece_load_balancer_target_members_alb = flatten([for target_index, target in local.ece_load_balancer_target_ports_alb : [
    for server_index, server in local.all_servers : {
      id               = "${server_index}-${target_index}"
      target_group_arn = aws_lb_target_group.ece_targets_alb[target_index].arn
      name             = server.name
      target_id        = server.instance_id
      port             = target_index
    }
    if contains(server.roles, target.role)]
  ])

  ece_load_balancer_target_ids = { for target in aws_lb_target_group.ece_targets_alb :
    target.name => target.id
  }
}
