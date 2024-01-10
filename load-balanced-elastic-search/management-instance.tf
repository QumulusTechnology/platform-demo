resource "openstack_networking_port_v2" "management_instance_port" {
  name       = "management-instance-port"
  network_id = var.internal_network_id
  fixed_ip {
    subnet_id  = var.internal_subnet_id
    ip_address = cidrhost(local.internal_network_cidr, 4)
  }
  security_group_ids = [openstack_networking_secgroup_v2.management_instance.id]
}

resource "openstack_compute_instance_v2" "management_instance" {
  name      = "management-instance"
  image_id  = data.openstack_images_image_v2.management_instance.id
  flavor_id = data.openstack_compute_flavor_v2.management_instance.id
  key_pair  = var.keypair_name
  user_data = <<-EOT
#cloud-config
write_files:
  - content: |
      ${indent(6, local.install_ece_script)}
    path: /home/${var.ece_user}/install-ece.sh
    permissions: '0700'
  - content: |
      ${indent(6, file(var.path_to_openstack_rc))}
    path: /home/${var.ece_user}/openstack-rc.sh
    permissions: '0700'
  - content: |
      ${indent(6, file("${path.module}/files/certbot_post_deploy.yml"))}
    path: /home/${var.ece_user}/certbot_post_deploy.yml
    permissions: '0600'
  - content: |
      ${indent(6, file("${path.module}/files/esrally.yml"))}
    path: /home/${var.ece_user}/esrally.yml
    permissions: '0600'
  - content: |
      ${indent(6, file("${path.module}/files/create-elastic-deployment.yml"))}
    path: /home/${var.ece_user}/create-elastic-deployment.yml
    permissions: '0600'
  - content: |
      ${indent(6, file("${path.module}/files/deployment.json"))}
    path: /home/${var.ece_user}/deployment.json
    permissions: '0600'
  - content: |
      ${indent(6, file("${path.module}/files/certbot.yml"))}
    path: /home/${var.ece_user}/certbot.yml
    permissions: '0600'
  - content: |
      ${indent(6, local.hosts_file)}
    path: /home/${var.ece_user}/hosts
    permissions: '0600'
  - content: |
      ${indent(6, file(var.private_ssh_key_path))}
    path: /home/${var.ece_user}/.ssh/${basename(var.private_ssh_key_path)}
    permissions: '0600'
  - content: |
      #!/bin/bash
      ansible-playbook -i /home/${var.ece_user}/hosts /home/${var.ece_user}/certbot_post_deploy.yml
    path: /etc/letsencrypt/renewal-hooks/deploy/certbot_post_deploy.sh
    permissions: '0700'
  - content: |
      [defaults]
      host_key_checking = False
      log_path = /home/${var.ece_user}/ansible.log
    path: /etc/ansible/ansible.cfg
    permissions: '0644'
  - content: |
      ${indent(6, file("${path.module}/files/deploy-ece.yml"))}
    path: /home/${var.ece_user}/deploy-ece.yml
    permissions: '0600'
runcmd:
  - chown -R ${var.ece_user}:${var.ece_user} /home/${var.ece_user}
  - su ${var.ece_user} /home/${var.ece_user}/install-ece.sh
EOT

  network {
    port = openstack_networking_port_v2.management_instance_port.id
  }
  depends_on = [
    openstack_compute_instance_v2.elastic,
    openstack_networking_secgroup_rule_v2.ece_servers_from_management_instance,
    openstack_lb_member_v2.ece_pool_members,
    #openstack_lb_listener_v2.ece_listeners,
    ]
}
