# Define the Path Route Set using dynamic blocks
resource "oci_load_balancer_path_route_set" "path_route_set" {
  load_balancer_id = var.load_balancer_id
  name             = var.path_route_set_name

  dynamic "path_routes" {
    for_each = var.path_routes
    content {
      backend_set_name = path_routes.value.backend_set_name
      path             = path_routes.value.path

      path_match_type {
        match_type = path_routes.value.match_type
      }
    }
  }
}
