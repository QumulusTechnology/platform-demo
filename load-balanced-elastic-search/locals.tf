locals {
  internal_network_cidr    = cidrsubnet(var.internal_network_range, 2, 0)
  public_ssh_key_filename  = basename(var.public_ssh_key_path)
  private_ssh_key_filename = basename(var.private_ssh_key_path)
  run_ansible              = var.run_ansible ? "su ${var.ece_user} /home/${var.ece_user}/install-ece.sh" : "echo 'Skipping ECE installation'"
  install_ece_script = templatefile("${path.module}/templates/install-ece.sh.tftpl", {
    run_ansible              = var.run_ansible,
    private_ssh_key_filename = local.private_ssh_key_filename,
  })

  openstack_rc = templatefile("${path.module}/templates/openstack-rc.sh.tftpl", {
    secret_id    = openstack_identity_application_credential_v3.manage_load_balancer_certificates.id
    secret       = openstack_identity_application_credential_v3.manage_load_balancer_certificates.secret
    project_name = data.external.env.result["os_project_name"]
    auth_url     = data.external.env.result["os_auth_url"]
  })

  hosts_file = templatefile("${path.module}/templates/hosts.tftpl", {
    load_balancer_ip           = openstack_lb_loadbalancer_v2.elastic.vip_address
    ece_domain                 = var.ece_domain
    device                     = var.ece_device_name
    ece_version                = var.ece_version
    ece_servers                = local.ece_servers
    elastic_server_count       = var.ece_servers_count
    ece_servers                = [for k, v in local.ece_servers : v]
    ssh_key_filename           = basename(var.private_ssh_key_path)
    user                       = var.ece_user
    letsencrypt_email          = var.letsencrypt_email
    load_balancer_listener_ids = join(",", [for k, v in openstack_lb_listener_v2.ece_listeners : v.id if v.protocol == "TERMINATED_HTTPS"])
    private_ssh_key_filename   = local.private_ssh_key_filename
  })

  ece_servers = { for i in range(var.ece_servers_count) :
    i => {
      name       = "ece-server-${i + 1}"
      type       = i == 0 ? "primary" : "secondary"
      roles      = i == 0 ? var.primary_server_roles : var.secondary_server_roles
      ip_address = cidrhost(local.internal_network_cidr, 5 + i)
      index      = i
    }
  }
  management_server = {
    length(local.ece_servers) = {
      name       = "management-instance"
      type       = "management-instance"
      roles      = ["letsencrypt"]
      ip_address = openstack_networking_port_v2.management_instance_port.all_fixed_ips[0]
    }
  }

  all_servers = merge(local.ece_servers, local.management_server)

  ece_load_balancer_listener_ports = { for k, v in var.ece_load_balancer_listener_ports :
    k => {
      "default_pool_port" = v.default_pool_port
      "protocol"          = v.protocol
      "redirect_to_https" = v.redirect_to_https
      "https_port"        = v.https_port
      "layer_7_policies"  = v.layer_7_policies
      "description"       = "${v.default_pool_port == null ? "" : var.ece_load_balancer_pool_ports[v.default_pool_port].description}: ${v.protocol}"
    }
  }

  ece_load_balancer_pool_members = flatten([for pool_index, pool in var.ece_load_balancer_pool_ports : [
    for server_index, server in local.all_servers : {
      id         = "${server_index}-${pool_index}"
      pool_id    = openstack_lb_pool_v2.ece_pools[pool_index].id
      name       = server.name
      ip_address = server.ip_address
      port       = pool_index
    }
    if contains(server.roles, pool.role)]
  ])
  ece_load_balancer_pool_ids = { for pool in openstack_lb_pool_v2.ece_pools :
    pool.name => pool.id
  }
  ece_load_balancer_listener_layer7_policies = flatten([for k1, v1 in var.ece_load_balancer_listener_ports : [
    for k2, v2 in v1.layer_7_policies :
    {
      "name"             = v2.name
      "listener_id"      = openstack_lb_listener_v2.ece_listeners[k1].id
      "position"         = k2
      "action"           = v2.action
      "redirect_url"     = null
      "redirect_pool_id" = v2.redirect_pool_name != null ? local.ece_load_balancer_pool_ids[v2.redirect_pool_name] : null
      "rule"             = v2.rule
    }
  ] if v1.layer_7_policies != null])
  ece_load_balancer_listener_redirect_to_https_policies = [for k, v in var.ece_load_balancer_listener_ports :
    {
      "name"             = "Redirect to HTTPS"
      "listener_id"      = openstack_lb_listener_v2.ece_listeners[k].id
      "position"         = v.layer_7_policies == null ? 1 : length(v.layer_7_policies) + 1
      "action"           = "REDIRECT_TO_URL"
      "redirect_url"     = "https://${var.ece_domain}:${v.https_port}"
      "redirect_pool_id" = null
      "rule"             = null
    }
  if v.redirect_to_https]
  ece_load_balancer_listener_policies = { for i, p in concat(local.ece_load_balancer_listener_layer7_policies, local.ece_load_balancer_listener_redirect_to_https_policies) :
    i => p
  }
}
