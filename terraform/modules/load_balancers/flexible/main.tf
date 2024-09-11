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

module "api_backends" {
  source                     = "./backend"
  load_balancer_id            = oci_load_balancer_load_balancer.kubeapi_lb.id
  worker_node_private_ip_map  = var.worker_node_private_ip_map
  service_name                = "api"
  url_path                    = "/api"
  https_port                  = 443
  http_port                   = 80
}

module "dashboard_backends" {
  source                     = "./backend"
  load_balancer_id            = oci_load_balancer_load_balancer.kubeapi_lb.id
  worker_node_private_ip_map  = var.worker_node_private_ip_map
  service_name                = "dashboard"
  url_path                    = "/dashboard/"
  https_port                  = 443
  http_port                   = 80
}

module "path_routing" {
  source               = "./routing"
  load_balancer_id     = oci_load_balancer_load_balancer.kubeapi_lb.id
  path_route_set_name  = "api-dashboard-path-route-set"

  path_routes = [
    {
      path            = "/api"
      backend_set_name = module.api_backends.http_backend_set_name
      match_type      = "PREFIX_MATCH"
    },
    {
      path            = "/dashboard/"
      backend_set_name = module.dashboard_backends.http_backend_set_name
      match_type      = "PREFIX_MATCH"
    }
  ]
}

module "http_listener" {
  source                  = "./listener"
  load_balancer_id         = oci_load_balancer_load_balancer.kubeapi_lb.id
  listener_name            = "http-listener"
  listener_protocol        = "HTTP"
  listener_port            = 80
  default_backend_set_name = module.api_backends.http_backend_set_name
  path_route_set_name      = module.path_routing.path_route_set_name
}

module "https_listener" {
  source                  = "./listener"
  load_balancer_id         = oci_load_balancer_load_balancer.kubeapi_lb.id
  listener_name            = "https-listener"
  listener_protocol        = "HTTP"
  listener_port            = 443
  default_backend_set_name = module.api_backends.https_backend_set_name
  path_route_set_name      = module.path_routing.path_route_set_name

  # TODO: Enable TLS between Domain and LB comms?
  # # Enable SSL
  # ssl_configuration_enabled        = true
  # certificate_name                 = "my-cert"
  # ssl_has_session_resumption       = true
  # ssl_certificate_ids              = ["ocid1.certificate.oc1..example"]
  # ssl_cipher_suite_name            = "oci-cipher-suite-v1"
  # ssl_protocols                    = ["TLSv1.2", "TLSv1.3"]
  # ssl_server_order_preference      = "ENFORCED"
  # ssl_trusted_certificate_authority_ids = ["ocid1.certificateauthority.oc1..example"]
  # ssl_verify_depth                 = 3
  # ssl_verify_peer_certificate      = true
}
