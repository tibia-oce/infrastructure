# todo: make https and http dynamic 

# modules/load_balancer_backend/backend.tf
resource "oci_load_balancer_backend_set" "https_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "${var.service_name}-https-backend"
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

resource "oci_load_balancer_backend_set" "http_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "${var.service_name}-http-backend"
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

resource "oci_load_balancer_backend" "http_backend" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.http_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = var.http_port
}

resource "oci_load_balancer_backend" "https_backend" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.https_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = var.https_port
}
