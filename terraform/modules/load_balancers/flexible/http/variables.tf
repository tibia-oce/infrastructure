variable "load_balancer_id" {
  description = "ID of the OCI load balancer"
  type        = string
}

variable "worker_node_private_ip_map" {
  description = "Private IP map of worker nodes"
  type        = map(string)
}
