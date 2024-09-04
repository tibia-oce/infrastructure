# ====================================================================
# Backend Set, Listener, and Backends for Dashboard (port 8080)
# This defines the entire configuration for handling the Traefik 
# Dashboard using NodePort 32080.
# ====================================================================

resource "oci_load_balancer_backend_set" "traefik_dashboard_backend_set" {
  load_balancer_id = var.load_balancer_id
  name             = "traefik-dashboard-backend"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol = "TCP"
    port     = 32080
  }
}

resource "oci_load_balancer_listener" "traefik_dashboard_listener" {
  load_balancer_id         = var.load_balancer_id
  name                     = "traefik-dashboard-listener"
  protocol                 = "TCP"
  port                     = 8081
  default_backend_set_name = oci_load_balancer_backend_set.traefik_dashboard_backend_set.name
  depends_on               = [oci_load_balancer_backend_set.traefik_dashboard_backend_set]
}

resource "oci_load_balancer_backend" "traefik_dashboard_backend" {
  for_each         = var.worker_node_private_ip_map
  backendset_name  = oci_load_balancer_backend_set.traefik_dashboard_backend_set.name
  ip_address       = each.value
  load_balancer_id = var.load_balancer_id
  port             = 32080
}
