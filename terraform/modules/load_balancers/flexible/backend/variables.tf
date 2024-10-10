variable "service_name" {
  type = string
}

variable "load_balancer_id" {
  description = "ID of the OCI load balancer"
  type        = string
}

variable "worker_node_private_ip_map" {
  description = "Private IP map of worker nodes"
  type        = map(string)
}

variable "https_port" {
  type        = number
  default = 433
}

variable "http_port" {
  type        = number
  default = 80
}

variable "tcp_game_port" {
  type        = number
  default = 7172
}

variable "tcp_login_port" {
  type        = number
  default = 7171
}

variable "url_path" {
  type        = string
}

