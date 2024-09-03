variable "compartment_ocid" {
  description = "The OCID of the compartment where the NSG will be created."
  type        = string
}

variable "vcn_id" {
  description = "The ID of the VCN where the NSG will be created."
  type        = string
}

variable "kube_api_port" {
  description = "Port number for the Kubernetes API."
  type        = number
  default     = 6443
}

variable "expose_kubeapi" {
  description = "Boolean to control whether the Kubernetes API should be publicly exposed."
  type        = bool
  default     = true
}

variable "my_public_ip_cidr" {
  description = "CIDR block for your public IP (e.g., 203.0.113.1/32) to allow traffic."
  type        = string
}

variable "additional_trusted_sources" {
  description = "Additional CIDR blocks of trusted sources for KubeAPI access."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "all_private_instance_ips_map" {
  description = "Map of all private instance IPs."
  type        = map(string)
}

variable "all_instance_ips_map" {
  description = "Map of all instance IPs."
  type        = map(string)
}