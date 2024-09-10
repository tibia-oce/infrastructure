# ====================================================================
# Backend Sets for HTTP & HTTPS traffic to /api
# ====================================================================
resource "oci_load_balancer_backend_set" "api_https_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "api-https-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol           = "HTTP"
    url_path           = var.url_path
    port               = var.https_port
    return_code        = 200
    retries            = 3
    timeout_in_millis  = 3000
  }
}

resource "oci_load_balancer_backend_set" "api_http_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "api-http-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol           = "HTTP"
    url_path           = var.url_path
    port               = var.http_port
    return_code        = 200
    retries            = 3
    timeout_in_millis  = 3000
  }
}

# ====================================================================
# Backends for the /api service
# ====================================================================
resource "oci_load_balancer_backend" "api_http_backends" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.api_http_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = var.http_port
}

resource "oci_load_balancer_backend" "api_https_backends" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.api_https_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = var.https_port
}

# ====================================================================
# Listeners for HTTPS (433) & HTTP (80) traffic for /api
# ====================================================================
resource "oci_load_balancer_listener" "https_listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = "api-https-listener"
  protocol                 = "HTTP"
  port                     = var.https_port
  default_backend_set_name = oci_load_balancer_backend_set.api_https_backend_set.name
}

resource "oci_load_balancer_listener" "http_listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = "api-http-listener"
  protocol                 = "HTTP"
  port                     = var.http_port
  default_backend_set_name = oci_load_balancer_backend_set.api_http_backend_set.name
}
