resource "openstack_lb_loadbalancer_v2" "elastic" {
  name               = "ece-load-balancer"
  vip_subnet_id      = var.internal_subnet_id
  security_group_ids = [openstack_networking_secgroup_v2.load_balancer.id]
}

### Internet facing floating IP for the load balancer
resource "openstack_networking_floatingip_v2" "elastic_floating_ip" {
  description = "ece-load-balancer"
  pool        = data.openstack_networking_network_v2.public.name
}

resource "openstack_networking_floatingip_associate_v2" "elastic_floatingip" {
  floating_ip = openstack_networking_floatingip_v2.elastic_floating_ip.address
  port_id     = openstack_lb_loadbalancer_v2.elastic.vip_port_id
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

resource "local_sensitive_file" "load_balancer_cert" {
  filename = "${path.module}/load-balancer-cert.pem"
  content  = tls_self_signed_cert.load_balancer_tls_cert.cert_pem
}

resource "local_sensitive_file" "load_balancer_key" {
  filename = "${path.module}/load-balancer-key.pem"
  content  = tls_private_key.load_balancer_tls_key.private_key_pem
}

### Create a PKCS12 file from the self-signed certificate for the load balancer to use
resource "null_resource" "load_balancer_pkcs12" {
  provisioner "local-exec" {
    command     = "./scripts/create-p12.sh"
    working_dir = path.module
  }
  depends_on = [
    local_sensitive_file.load_balancer_cert,
    local_sensitive_file.load_balancer_key
  ]
}

### Upload the PKCS12 file to the OpenStack Key Manager service
resource "openstack_keymanager_secret_v1" "load_balancer_tls_cert" {
  name                     = "ece-self-signed-cert"
  algorithm                = "ECDSA"
  bit_length               = 384
  mode                     = "cbc"
  payload                  = data.local_file.load_balancer_tls_cert.content_base64
  secret_type              = "opaque"
  payload_content_type     = "application/octet-stream"
  payload_content_encoding = "base64"
  depends_on = [
    null_resource.load_balancer_pkcs12
  ]
}

## Create a load balancer pool for each port that the load balancer will use to communicate with ECE
resource "openstack_lb_pool_v2" "ece_pools" {
  for_each        = var.ece_load_balancer_pool_ports
  name            = "${each.value.name}-${lower(replace(each.value.protocol,"_","-"))}-${each.value.role}-port-${each.key}"
  protocol        = each.value.protocol
  lb_method       = each.value.lb_method
  loadbalancer_id = openstack_lb_loadbalancer_v2.elastic.id
}

### Add each ECE server as a member of each ECE pools
resource "openstack_lb_member_v2" "ece_pool_members" {
  count         = length(local.ece_load_balancer_pool_members)
  name          = local.ece_load_balancer_pool_members[count.index].name
  address       = local.ece_load_balancer_pool_members[count.index].ip_address
  protocol_port = local.ece_load_balancer_pool_members[count.index].port
  pool_id       = local.ece_load_balancer_pool_members[count.index].pool_id
  subnet_id     = var.internal_subnet_id
  weight        = 1
  depends_on = [ openstack_lb_pool_v2.ece_pools ]
}

# ### Create a health monitor for each ECE pool
resource "openstack_lb_monitor_v2" "ece_pool_monitors" {
  for_each       = { for key, val in var.ece_load_balancer_pool_ports : key => val if val.health_monitor_enabled }
  pool_id        = openstack_lb_pool_v2.ece_pools[each.key].id
  type           = each.value.health_monitor_type
  url_path       = each.value.health_monitor_url_path
  http_method    = each.value.health_monitor_http_method
  expected_codes = each.value.health_monitor_expected_codes
  delay          = 20
  timeout        = 10
  max_retries    = 5
  depends_on = [ openstack_lb_member_v2.ece_pool_members ]
}

### Create a listener for each Internet facing port that ECE requires
resource "openstack_lb_listener_v2" "ece_listeners" {
  for_each                  = var.ece_load_balancer_listener_ports
  name                      = "${var.ece_load_balancer_pool_ports[each.value.default_pool_port].name}-${lower(replace(each.value.protocol,"_","-"))}-port-${each.key}"
  protocol                  = each.value.protocol
  protocol_port             = each.key
  loadbalancer_id           = openstack_lb_loadbalancer_v2.elastic.id
  default_pool_id           = openstack_lb_pool_v2.ece_pools[each.value.default_pool_port].id
  default_tls_container_ref = each.value.protocol == "TERMINATED_HTTPS" ? openstack_keymanager_secret_v1.load_balancer_tls_cert.secret_ref : null
  insert_headers = each.value.protocol == "HTTPS" ? null : {
    X-Forwarded-For   = "true"
    X-Forwarded-Proto = "true"
  }
  lifecycle {
    ignore_changes = [
      default_tls_container_ref
    ]
  }
  depends_on = [
    openstack_lb_monitor_v2.ece_pool_monitors,
    openstack_keymanager_secret_v1.load_balancer_tls_cert
    ]
}

### Create any layer 7 policies that are required
resource "openstack_lb_l7policy_v2" "ece_listener_policies" {
  for_each         = local.ece_load_balancer_listener_policies
  name             = each.value.name
  action           = each.value.action
  position         = each.value.position
  listener_id      = each.value.listener_id
  redirect_pool_id = each.value.redirect_pool_id
  redirect_url     = each.value.redirect_url

  depends_on = [ openstack_lb_listener_v2.ece_listeners ]
}

# ### Create any layer 7 rules that are required
resource "openstack_lb_l7rule_v2" "ece_listener_policy_rules" {
  for_each     = { for key, val in local.ece_load_balancer_listener_policies : key => val if val.rule != null }
  l7policy_id  = openstack_lb_l7policy_v2.ece_listener_policies[each.key].id
  type         = each.value.rule.type
  compare_type = each.value.rule.compare_type
  value        = each.value.rule.value

  depends_on = [ openstack_lb_l7policy_v2.ece_listener_policies ]
}

output "load_balancer_dns" {
  value = <<EOT
Please create the following DNS Records

TYPE: A
DOMAIN_NAME: ${var.ece_domain}
VALUE: ${openstack_networking_floatingip_v2.elastic_floating_ip.address}

TYPE: A
DOMAIN_NAME: *.${var.ece_domain}
VALUE: ${openstack_networking_floatingip_v2.elastic_floating_ip.address}

EOT
}
