variable "compartment_ocid" {
  description = "The OCID of the compartment where NSG resources will be created."
  type        = string
}

variable "vcn_id" {
  description = "The ID of the VCN where the NSG resources will be created."
  type        = string
}

variable "http_lb_port" {
  description = "Port number for HTTP traffic."
  type        = number
}

variable "https_lb_port" {
  description = "Port number for HTTPS traffic."
  type        = number
}

variable "kube_api_port" {
  description = "Port number for the Kubernetes API."
  type        = number
  default     = 6443
}

variable "expose_kubeapi" {
  description = "Flag to determine if KubeAPI should be exposed."
  type        = bool
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
