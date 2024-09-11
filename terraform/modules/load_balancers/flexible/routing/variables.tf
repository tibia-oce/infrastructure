variable "load_balancer_id" {
  type = string
}

variable "path_route_set_name" {
  type = string
}

variable "path_routes" {
  type = list(object({
    path            = string
    backend_set_name = string
    match_type      = string
  }))
}
