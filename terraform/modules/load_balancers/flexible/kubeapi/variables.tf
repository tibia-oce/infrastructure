variable "load_balancer_id" {
  description = "ID of the OCI load balancer"
  type        = string
}

variable "worker_node_private_ip_map" {
  description = "Private IP map of worker nodes"
  type        = map(string)
}

variable "kube_api_port" {
  description = "The port number for the Kubernetes API."
  type        = number
  default     = 6443
}

variable "control_plane_private_ips" {
  description = "List of private IP addresses for control plane nodes."
  type        = list(string)
}