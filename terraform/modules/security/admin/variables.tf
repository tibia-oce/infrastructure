variable "compartment_id" {
  description = "The OCID of the compartment where the security lists will be created."
  type        = string
}

variable "vcn_id" {
  description = "The ID of the VCN where the security lists will be created."
  type        = string
}

variable "my_public_ip_cidr" {
  description = "The CIDR block of your public IP address for SSH access."
  type        = string
}

variable "kube_api_port" {
  description = "Port number for the Kubernetes API."
  type        = number
  default     = 6443
}

variable "subnet_cidr" {
  description = "The CIDR block of the subnet within the VCN."
  type        = string
}

variable "vcn_cidr" {
  description = "The CIDR block of the VCN."
  type        = string
}
