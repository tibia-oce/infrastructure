# ====================================================================
# Backend Set, Listener, and Backends for HTTPS (port 443)
# This defines the entire configuration for handling HTTPS traffic 
# using NodePort 443.
# ====================================================================

resource "oci_load_balancer_backend_set" "traefik_https_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "traefik-https-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = 443  # Health check for HTTPS on NodePort 443
  }
}

resource "oci_load_balancer_listener" "traefik_https_listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = "traefik-listener-https"
  protocol                 = "TCP"
  port                     = 443  # External port for HTTPS
  default_backend_set_name = oci_load_balancer_backend_set.traefik_https_backend_set.name
  depends_on               = [oci_load_balancer_backend_set.traefik_https_backend_set]
}

resource "oci_load_balancer_backend" "traefik_https_backend" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.traefik_https_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = 443  # NodePort for HTTPS on worker nodes
}
