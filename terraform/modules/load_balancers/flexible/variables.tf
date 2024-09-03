variable "compartment_ocid" {
  description = "The OCID of the compartment where the load balancer will be created."
  type        = string
}

variable "public_lb_shape" {
  description = "Shape of the public load balancer."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the load balancer will be created."
  type        = string
}

variable "public_lb_nsg_id" {
  description = "The ID of the NSG to associate with the public load balancer."
  type        = string
}

variable "reserved_ip_id" {
  description = "The ID of the reserved public IP."
  type        = string
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
