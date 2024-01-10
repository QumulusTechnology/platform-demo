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

variable "internal_network_id" {
  type = string
}

variable "internal_subnet_id" {
  type = string
}

variable "public_network_name" {
  type = string
}

variable "path_to_openstack_rc" {
  type        = string
  description = "path for your OpenStack credentials"
}

variable "management_instance_image" {
  default = "Ubuntu-22.04-Jammy"
}

variable "management_instance_flavor" {
  default = "c1.medium"
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

#######################################################
#### ECE installation-specific variables #####
#######################################################

variable "elastic_image" {
  type    = string
  default = "Ubuntu-20.04-Focal"
}

variable "elastic_flavor" {
  type    = string
  default = "c1.large"
}

variable "elastic_primary_flavor" {
  type    = string
  default = "c1.xxlarge"
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

# # The device name of the non-root volume that will be used by ECE
variable "ece_device_name" {
  default = "vdb"
}


### This variable drives the configuration of the load balancer listeners
### A listener is a port that the load balancer will listen on and forward traffic to the configured pool
### The listener is configured with a protocol (eg HTTP, HTTPS, TERMINATED_HTTPS and others)
### Optionally, layer 7 policies and rules can be added to a listener to allow for more advanced traffic routing
### when redirect_to_https is enabled, a layer 7 policy is added to redirect HTTP traffic to HTTPS
### TERMINATED_HTTPS means that the load balancer will terminate the TLS connection and typically forward the traffic to the pool as unencrypted HTTP traffic
### This reduces the load on the ECE servers as they do not need to handle the TLS overhead which can slow them down.
### When using TERMINATED_HTTPS, the load balancer needs to be configured with a TLS certificate
### Initially a self-signed certificate is used, but then use certbot & letsencrypt to generate a valid certificate for the domain name
### It's important that a valid domain name is used and this domain name is pointed to the load-balancer public VIP address, as letsencrypt will verify that the domain name is valid
### If certbot fails to run due to domain name validation issues, it can be run manually after the deployment by logging onto the management-instance and running `ansible-playbook certbot.yml`
### A cronjob is configured to refresh the certificate periodically
### The load balancer is configured with a security group that allows traffic from the Internet to the load balancer on these ports

variable "ece_load_balancer_listener_ports" {
  type = map(object({
    default_pool_port = number
    protocol          = string
    redirect_to_https = optional(bool, false)
    https_port        = optional(number, null)
    layer_7_policies = optional(map(object({
      name               = string
      action             = string
      redirect_pool_name = optional(string, null)
      rule = optional(object({
        compare_type = string
        type         = string
        value        = string
      }), null)
    })), null)
  }))
  default = {
    80 = {
      default_pool_port = 12300
      protocol          = "HTTP"
      redirect_to_https = true
      https_port        = 443
      layer_7_policies = {
        1 = {
          name               = "letsencrypt_validation"
          action             = "REDIRECT_TO_POOL"
          redirect_pool_name = "letsencrypt-validation-http-letsencrypt-port-80"
          rule = {
            compare_type = "STARTS_WITH"
            type         = "PATH"
            value        = "/.well-known/acme-challenge"
          }
        }
      }
    }
    443 = {
      default_pool_port = 12400
      protocol          = "TERMINATED_HTTPS"
    }
    12300 = {
      default_pool_port = 12300
      protocol          = "HTTP"
      redirect_to_https = true
      https_port        = 12343
    }
    12343 = {
      default_pool_port = 12300
      protocol          = "TERMINATED_HTTPS"
    }
    12400 = {
      default_pool_port = 12400
      protocol          = "HTTP"
      redirect_to_https = true
      https_port        = 12443
    }
    12443 = {
      default_pool_port = 12400
      protocol          = "TERMINATED_HTTPS"
    }
    9200 = {
      default_pool_port = 9200
      protocol          = "HTTP"
      redirect_to_https = true
      https_port        = 9243
    }
    9243 = {
      default_pool_port = 9200
      protocol          = "TERMINATED_HTTPS"
    }
    9300 = {
      default_pool_port = 9300
      protocol          = "HTTP"
      redirect_to_https = true
      https_port        = 9343
    }
    9343 = {
      default_pool_port = 9300
      protocol          = "TERMINATED_HTTPS"
    }
    9400 = {
      default_pool_port = 9400
      protocol          = "HTTPS"
    }
  }
}

### This variable drives the configuration of the load balancer server pools
### A pool is a group of ports that the load balancer will send traffic to and load balance between - The ports do not need be internal to OpenStack
### They are configured with a protocol (eg HTTP, HTTPS, PROXYV2 and others), optional health monitor and port
### The pool is linked to a server role (eg coordinator, proxy, allocator, director) so that the load balancer knows which servers to send traffic to
### A security group is attached to the servers, that allows the load balancer to communicate with the servers on these ports
variable "ece_load_balancer_pool_ports" {
  type = map(object({
    name                          = string
    role                          = string
    protocol                      = string
    lb_method                     = optional(string, "ROUND_ROBIN")
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
      name                   = "admin-api"
      role                   = "coordinator"
      protocol               = "HTTP"
      description            = "Admin API port"
      health_monitor_enabled = true
      health_monitor_type    = "HTTP"
      health_monitor_http_method = "GET"
      health_monitor_url_path = "/"
      health_monitor_expected_codes = "200,400"
    }
    12400 = {
      name                   = "cloud-ui-console"
      role                   = "coordinator"
      protocol               = "HTTP"
      description            = "HTTP port for the cloud UI console"
      health_monitor_enabled = true
      health_monitor_type    = "HTTP"
      health_monitor_http_method = "GET"
      health_monitor_url_path = "/"
      health_monitor_expected_codes = "200"
    }
    9200 = {
      name                   = "elastic-api"
      role                   = "coordinator"
      protocol               = "HTTP"
      description            = "main elastic port - used for all API calls"
      health_monitor_enabled = true
      health_monitor_type    = "HTTP"
      health_monitor_http_method = "GET"
      health_monitor_url_path = "/_health"
      health_monitor_expected_codes = "200"

    }
    9300 = {
      name                   = "elastic-transport"
      role                   = "proxy"
      protocol               = "PROXYV2"
      description            = "elastic transport port - used for internal communication between elastic nodes"
      health_monitor_enabled = true
      health_monitor_type    = "TCP"
    }
    9400 = {
      name                   = "remote-cluster"
      role                   = "proxy"
      protocol               = "HTTPS"
      description            = "elastic remote cluster port - used for cross-cluster replication"
      health_monitor_enabled = true
      health_monitor_type    = "TCP"
    }
  }
}

variable "load_balancer_floating_ip" {
  type = string
  description = "hard coded floating IP address for the load balancer - useful if you want to tear down the platform and recreate it with the same IP address"
  default = null
}
