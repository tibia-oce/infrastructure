# ====================================================================
# Backend Set, Listener, and Backends for HTTP (port 80)
# This defines the entire configuration for handling HTTP traffic 
# using NodePort 30080.
# ====================================================================

resource "oci_load_balancer_backend_set" "nodeport_http_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "nodeport-http-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = 30080
  }
}

resource "oci_load_balancer_listener" "nodeport_http_listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = "nodeport-listener-http"
  protocol                 = "TCP"
  port                     = 80
  default_backend_set_name = oci_load_balancer_backend_set.nodeport_http_backend_set.name
  depends_on               = [oci_load_balancer_backend_set.nodeport_http_backend_set]
}

resource "oci_load_balancer_backend" "nodeport_http_backend" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.nodeport_http_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = 30080
}
