# ====================================================================
# Backend Set, Listener, and Backends for KubeAPI (port 6443)
# This defines the entire configuration for handling KubeAPI traffic 
# using over TCP.
# ====================================================================

resource "oci_load_balancer_backend_set" "kubeapi_backend_set" {
  load_balancer_id         = var.load_balancer_id
  name             = "kubeapi-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = var.kube_api_port
  }
}

resource "oci_load_balancer_listener" "kubeapi_listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = "kubeapi-listener"
  protocol                 = "TCP"
  port                     = var.kube_api_port
  default_backend_set_name = oci_load_balancer_backend_set.kubeapi_backend_set.name
  depends_on               = [oci_load_balancer_backend_set.kubeapi_backend_set]
}

resource "oci_load_balancer_backend" "kubeapi_backend" {
  count            = length(var.control_plane_private_ips)
  ip_address       = element(var.control_plane_private_ips, count.index)
  backendset_name  = oci_load_balancer_backend_set.kubeapi_backend_set.name
  load_balancer_id         = var.load_balancer_id
  port             = var.kube_api_port
}
