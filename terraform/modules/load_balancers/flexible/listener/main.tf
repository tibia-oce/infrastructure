resource "oci_load_balancer_listener" "listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = var.listener_name
  protocol                 = var.listener_protocol
  port                     = var.listener_port

  # Map the hostnames to backend sets
  default_backend_set_name = var.default_backend_set_name

  # SSL Configuration (for HTTPS listener)
  dynamic "ssl_configuration" {
    for_each = var.ssl_configuration_enabled ? [1] : []
    content {
      certificate_name              = var.certificate_name
      protocols                     = var.ssl_protocols
    }
  }
}
