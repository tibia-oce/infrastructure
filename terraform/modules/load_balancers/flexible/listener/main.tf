# todo:  Load balancer listeners likely won't need hostnames in this 
# configuration, as the host headers are reserved on the request 

resource "oci_load_balancer_listener" "listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = var.listener_name
  protocol                 = var.listener_protocol
  port                     = var.listener_port

  # Default backend set name derived from the hostname_backend_map
  default_backend_set_name = lookup(var.hostname_backend_map, var.hostname_names[0], null)

  # # Assign hostname_names directly (as an attribute)
  # hostname_names           = var.hostname_names

  # SSL Configuration (optional)
  dynamic "ssl_configuration" {
    for_each = var.ssl_configuration_enabled ? [1] : []
    content {
      certificate_name              = var.certificate_name
      protocols                     = var.ssl_protocols
    }
  }
}
