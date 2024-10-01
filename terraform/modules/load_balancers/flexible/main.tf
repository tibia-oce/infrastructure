# ====================================================================
# Load Balancer Configuration
# This resource defines an OCI Flexible Load Balancer used to manage 
# external traffic for the Kubernetes API server and Traefik services. 
# The load balancer is configured with a public IP, associated network 
# security groups, and bandwidth limits.
# ====================================================================

resource "oci_load_balancer_load_balancer" "kubeapi_lb" {
  compartment_id             = var.compartment_ocid
  shape                      = var.public_lb_shape
  subnet_ids                 = [var.subnet_id]
  network_security_group_ids = var.network_groups
  is_private                 = false
  display_name               = "kubeapi-lb"

  reserved_ips {
    id = var.reserved_ip_id
  }

  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }
}

resource "oci_load_balancer_certificate" "cloudflare_cert" {
  load_balancer_id = oci_load_balancer_load_balancer.kubeapi_lb.id
  certificate_name = "cloudflare-cert"
  private_key      = var.private_key
  public_certificate = var.public_certificate
  ca_certificate = var.ca_certificate
}

# ====================================================================
# Module Configurations
# The following modules define the path based routing to the cluster
# services, which integrate with the Flexible Load Balancer. Each module 
# handles a specific route of traffic.
# ====================================================================

module "kubeapi" {
  source                      = "./kubeapi"
  worker_node_private_ip_map   = var.worker_node_private_ip_map
  load_balancer_id             = oci_load_balancer_load_balancer.kubeapi_lb.id
  control_plane_private_ips = var.control_plane_private_ips
  kube_api_port = var.kube_api_port
}

module "nginx_backend" {
  source                     = "./backend"
  load_balancer_id            = oci_load_balancer_load_balancer.kubeapi_lb.id
  worker_node_private_ip_map  = var.worker_node_private_ip_map
  service_name                = "nginx"
  url_path                    = "/health"
  https_port                  = 443
  http_port                   = 80
}

module "http_listener" {
  source                  = "./listener"
  load_balancer_id        = oci_load_balancer_load_balancer.kubeapi_lb.id
  default_backend_set_name = module.nginx_backend.http_backend_set_name
  listener_name           = "http-listener"
  listener_protocol       = "HTTP"
  listener_port           = 80

}

module "https_listener" {
  source                  = "./listener"
  load_balancer_id        = oci_load_balancer_load_balancer.kubeapi_lb.id
  default_backend_set_name = module.nginx_backend.http_backend_set_name
  listener_name           = "https-listener"
  listener_protocol       = "HTTP"
  listener_port           = 443
  ssl_configuration_enabled    = true  # SSL termination enabled
  certificate_name             = oci_load_balancer_certificate.cloudflare_cert.certificate_name
  ssl_protocols                = ["TLSv1.2", "TLSv1.3"]  # SSL protocols to support
}

# module "status_backend" {
#   source                     = "./backend"
#   load_balancer_id            = oci_load_balancer_load_balancer.kubeapi_lb.id
#   worker_node_private_ip_map  = var.worker_node_private_ip_map
#   hostname                    = "status.mythbound.dev"
#   service_name                = "status"
#   url_path                    = "/"
#   https_port                  = 443
#   http_port                   = 80
# }

# # todo: move to tcp (7171, 7172)
# module "game_backend" {
#   source                     = "./backend"
#   load_balancer_id            = oci_load_balancer_load_balancer.kubeapi_lb.id
#   worker_node_private_ip_map  = var.worker_node_private_ip_map
#   hostname                    = "game.mythbound.dev"
#   service_name                = "game"
#   url_path                    = "/"
#   https_port                  = 443
#   http_port                   = 80
# }

# module "myaac_backend" {
#   source                     = "./backend"
#   load_balancer_id            = oci_load_balancer_load_balancer.kubeapi_lb.id
#   worker_node_private_ip_map  = var.worker_node_private_ip_map
#   hostname                    = "myaac.mythbound.dev"
#   service_name                = "myaac"
#   url_path                    = "/"
#   https_port                  = 443
#   http_port                   = 80
# }

# module "http_listener" {
#   source                  = "./listener"

#   # Load balancer and listener information
#   load_balancer_id        = oci_load_balancer_load_balancer.kubeapi_lb.id
#   listener_name           = "http-listener"
#   listener_protocol       = "HTTP"
#   listener_port           = 80

#   # Hostnames and backend map
#   hostname_names          = ["status.mythbound.dev"]
#   hostname_backend_map    = {
#     "status.mythbound.dev" = module.status_backend.http_backend_set_name
#   }
# }

# module "https_listener" {
#   source                  = "./listener"

#   # Load balancer and listener information
#   load_balancer_id        = oci_load_balancer_load_balancer.kubeapi_lb.id
#   listener_name           = "https-listener"
#   listener_protocol       = "HTTP"
#   listener_port           = 443

#   # Hostnames and backend map
#   hostname_names          = ["status.mythbound.dev"]
#   hostname_backend_map    = {
#     "status.mythbound.dev" = module.status_backend.http_backend_set_name
#   }

#   ssl_configuration_enabled    = true  # SSL termination enabled
#   certificate_name             = oci_load_balancer_certificate.cloudflare_cert.certificate_name
#   ssl_protocols                = ["TLSv1.2", "TLSv1.3"]  # SSL protocols to support
# }


