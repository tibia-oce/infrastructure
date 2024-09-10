# ====================================================================
# Backend Set, Listener, and Backends for HTTPS (port 443)
# This defines the entire configuration for handling HTTPS traffic 
# using port 443.
# ====================================================================

resource "oci_load_balancer_backend_set" "proxy_https_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "https-proxy-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "HTTPS"
    url_path = "/"
    port     = 443
    return_code = 200
    retries      = 3
    timeout_in_millis = 3000
  }
}

resource "oci_load_balancer_listener" "proxy_https_listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = "https-proxy-backend"
  protocol                 = "TCP"
  port                     = 443
  default_backend_set_name = oci_load_balancer_backend_set.proxy_https_backend_set.name
  depends_on               = [oci_load_balancer_backend_set.proxy_https_backend_set]
}

resource "oci_load_balancer_backend" "proxy_https_backend" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.proxy_https_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = 443
}
