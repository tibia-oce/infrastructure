variable "compartment_ocid" {
  description = "The OCID of the compartment where NSG resources will be created."
  type        = string
}

variable "vcn_id" {
  description = "The ID of the VCN where the NSG resources will be created."
  type        = string
}

variable "my_public_ip_cidr" {
  description = "The CIDR block of your public IP address for SSH access."
  type        = string
}

variable "lb_public_ip_address" {
  description = "The public IP address of the load balancer."
  type        = string
}

variable "all_instance_ips_map" {
  description = "Map of all instance IPs."
  type        = map(string)
}

variable "all_private_instance_ips_map" {
  description = "Map of all private instance IPs."
  type        = map(string)
}

variable "additional_trusted_sources" {
  description = "Additional CIDR blocks of trusted sources for KubeAPI access."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "http_lb_port" {
  description = "The port for HTTP traffic on the public load balancer."
  type        = number
  default     = 80
}

variable "https_lb_port" {
  description = "The port for HTTPS traffic on the public load balancer."
  type        = number
  default     = 443
}

variable "expose_kubeapi" {
  description = "Boolean to control whether the Kubernetes API should be publicly exposed."
  type        = bool
  default     = true
}

variable "kube_api_port" {
  description = "The port on which the Kubernetes API will be exposed."
  type        = number
  default     = 6443
}
