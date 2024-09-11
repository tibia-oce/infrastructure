output "http_backend_set_name" {
  value = oci_load_balancer_backend_set.http_backend_set.name
}

output "https_backend_set_name" {
  value = oci_load_balancer_backend_set.https_backend_set.name
}
