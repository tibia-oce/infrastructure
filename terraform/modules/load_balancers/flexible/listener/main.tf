resource "oci_load_balancer_listener" "listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = var.listener_name
  protocol                 = var.listener_protocol
  port                     = var.listener_port
  default_backend_set_name = var.default_backend_set_name

  # Only attach the path route set if it is provided
  path_route_set_name      = var.path_route_set_name != "" ? var.path_route_set_name : null

  # # SSL configuration (optional)
  # dynamic "ssl_configuration" {
  #   for_each = var.ssl_configuration_enabled ? [1] : []
  #   content {
  #     certificate_name              = var.certificate_name
  #     has_session_resumption        = var.ssl_has_session_resumption
  #     certificate_ids               = var.ssl_certificate_ids
  #     cipher_suite_name             = var.ssl_cipher_suite_name
  #     protocols                     = var.ssl_protocols
  #     server_order_preference       = var.ssl_server_order_preference
  #     trusted_certificate_authority_ids = var.ssl_trusted_certificate_authority_ids
  #     verify_depth                  = var.ssl_verify_depth
  #     verify_peer_certificate       = var.ssl_verify_peer_certificate
  #   }
  # }
}
