variable "ece_domain" {
  type        = string
  description = "Domain name to access elastic. Please set this to something real and point it to the load balancer floating IP address"
}

variable "lets_encrypt_email" {
  type        = string
  description = "email address used for letsencrypt cert request"
}

variable "run_ansible" {
  type        = bool
  description = "run ansible automatically - set to false if you want to run the installation manually after the deployment - this can be useful for debugging and troubleshooting"
  default     = true
}

variable "internal_network_range" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "aws_region" {
  type    = string
}


variable "private_subnet_1_id" {
  type = string
}

variable "private_subnet_2_id" {
  type = string
}

variable "public_subnet_1_id" {
  type = string
}

variable "public_subnet_2_id" {
  type = string
}

variable "elastic_ami" {
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "management_instance_ami" {
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "ubuntu_ami_owner" {
  default = "099720109477"
}

variable "management_instance_flavor" {
  default = "t3a.medium"
}

variable "public_ssh_key_path" {
  type = string
}

variable "private_ssh_key_path" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "vpn_security_group_id" {
  type = string
}

variable "elastic_flavor" {
  type    = string
  default = "t3a.xlarge"
}

variable "elastic_primary_flavor" {
  type    = string
  default = "t3a.2xlarge"
}

variable "primary_server_count" {
  type    = number
  default = 1
}

variable "primary_server_roles" {
  type    = list(string)
  default = ["director", "coordinator", "proxy", "allocator"]
}

variable "secondary_server_count" {
  type    = number
  default = 2
}

variable "secondary_server_roles" {
  type    = list(string)
  default = ["director", "coordinator", "proxy", "allocator"]
}

variable "ece_version" {
  default = "3.6.2"
}

variable "ece_user" {
  default = "ubuntu"
}

variable "ece_device_name_aws" {
  default = "sdf"
}

variable "ece_device_name_server" {
  default = "nvme1n1"
}

variable "aws_availability_zone_1" {
  type = string
}

variable "aws_availability_zone_2" {
  type = string
}

variable "ece_load_balancer_listener_ports" {
  type = map(object({
    default_target_port = optional(number, null)
    alb_protocol        = optional(string, null)
    nlb_protocol        = string
    redirect_to_https   = optional(bool, false)
    https_port          = optional(number, null)

  }))
  default = {
    80 = {
      alb_protocol      = "HTTP"
      nlb_protocol      = "TCP"
      redirect_to_https = true
      https_port        = 443
    }
    443 = {
      alb_protocol        = "HTTPS"
      default_target_port = 9200
      nlb_protocol        = "TCP"
    }
    12300 = {
      alb_protocol      = "HTTP"
      nlb_protocol      = "TCP"
      redirect_to_https = true
      https_port        = 12343
    }
    12343 = {
      alb_protocol        = "HTTPS"
      default_target_port = 12300
      nlb_protocol        = "TCP"
    }
    12400 = {
      alb_protocol      = "HTTP"
      nlb_protocol      = "TCP"
      redirect_to_https = true
      https_port        = 12443
    }
    12443 = {
      alb_protocol        = "HTTPS"
      default_target_port = 12400
      nlb_protocol        = "TCP"
    }
    9200 = {
      alb_protocol      = "HTTP"
      nlb_protocol      = "TCP"
      redirect_to_https = true
      https_port        = 9243
    }
    9243 = {
      alb_protocol        = "HTTPS"
      default_target_port = 9200
      nlb_protocol        = "TCP"
    }
    9300 = {
      alb_protocol      = "HTTP"
      nlb_protocol      = "TCP"
      redirect_to_https = true
      https_port        = 9343
    }
    9343 = {
      default_target_port = 9343
      nlb_protocol        = "TCP"
    }
    9400 = {
      default_target_port = 9400
      nlb_protocol        = "TCP"
    }
  }
}

variable "ece_load_balancer_target_ports" {
  type = map(object({
    name                          = string
    role                          = string
    protocol                      = string
    proxy_protocol_v2             = optional(bool, false)
    load_balancing_algorithm_type = optional(string, "round_robin")
    description                   = string
    health_monitor_enabled        = optional(bool, false)
    health_monitor_type           = optional(string, null)
    health_monitor_url_path       = optional(string, null)
    health_monitor_http_method    = optional(string, null)
    health_monitor_expected_codes = optional(string, null)
  }))
  default = {
    80 = {
      name                   = "letsencrypt-validation"
      role                   = "letsencrypt"
      protocol               = "HTTP"
      description            = "allow letencrypt access to management instance to verify domain ownership"
      health_monitor_enabled = false
    }
    12300 = {
      name                          = "admin-api"
      role                          = "coordinator"
      protocol                      = "HTTP"
      description                   = "Admin API port"
      health_monitor_enabled        = true
      health_monitor_type           = "HTTP"
      health_monitor_http_method    = "GET"
      health_monitor_url_path       = "/"
      health_monitor_expected_codes = "200,400"
    }
    12400 = {
      name                          = "cloud-ui-console"
      role                          = "coordinator"
      protocol                      = "HTTP"
      description                   = "HTTP port for the cloud UI console"
      health_monitor_enabled        = true
      health_monitor_type           = "HTTP"
      health_monitor_http_method    = "GET"
      health_monitor_url_path       = "/"
      health_monitor_expected_codes = "200"
    }
    9200 = {
      name                          = "elastic-api"
      role                          = "coordinator"
      protocol                      = "HTTP"
      description                   = "main elastic port - used for all API calls"
      health_monitor_enabled        = true
      health_monitor_type           = "HTTP"
      health_monitor_http_method    = "GET"
      health_monitor_url_path       = "/_health"
      health_monitor_expected_codes = "200"

    }
    9343 = {
      name                   = "elastic-transport"
      role                   = "proxy"
      protocol               = "TCP"
      proxy_protocol_v2      = true
      description            = "elastic transport port - used for internal communication between elastic nodes"
      health_monitor_enabled = true
      health_monitor_type    = "TCP"
    }
    9400 = {
      name                   = "remote-cluster"
      role                   = "proxy"
      protocol               = "TCP"
      description            = "elastic remote cluster port - used for cross-cluster replication"
      health_monitor_enabled = true
      health_monitor_type    = "TCP"
    }
  }
}
