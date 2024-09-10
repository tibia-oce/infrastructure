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

module "api" {
  source                      = "./api"
  worker_node_private_ip_map  = var.worker_node_private_ip_map
  load_balancer_id            = oci_load_balancer_load_balancer.kubeapi_lb.id
  url_path                    = "/api"
  https_port                  = 433
  http_port                   = 80
}
