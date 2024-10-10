output "http_backend_set_name" {
  value = oci_load_balancer_backend_set.http_backend_set.name
}

output "https_backend_set_name" {
  value = oci_load_balancer_backend_set.https_backend_set.name
}

output "tcp_login_backend_set_name" {
  value = oci_load_balancer_backend_set.tcp_login_backend_set.name
}

output "tcp_game_backend_set_name" {
  value = oci_load_balancer_backend_set.tcp_game_backend_set.name
}
