# ====================================================================
# Backend Set, Listener, and Backends for HTTP (port 80)
# This defines the entire configuration for handling HTTP traffic 
# using port 80.
# ====================================================================

resource "oci_load_balancer_backend_set" "proxy_http_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "http-proxy-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTP"
    url_path = "/"
    port     = 80
    return_code = 200
    retries      = 3
    timeout_in_millis = 3000
  }
}

resource "oci_load_balancer_listener" "proxy_http_listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = "http-proxy-listener"
  protocol                 = "TCP"
  port                     = 80
  default_backend_set_name = oci_load_balancer_backend_set.proxy_http_backend_set.name
  depends_on               = [oci_load_balancer_backend_set.proxy_http_backend_set]
}

resource "oci_load_balancer_backend" "proxy_http_backend" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.proxy_http_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = 80
}
