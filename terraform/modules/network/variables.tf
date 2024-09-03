variable "compartment_id" {
  description = "The OCID of the compartment where network resources will be created."
  type        = string
}

variable "vcn_cidr" {
  description = "The CIDR block for the VCN."
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet."
  type        = string
}

variable "my_public_ip_cidr" {
  description = "The CIDR block of your public IP address for SSH access."
  type        = string
}

variable "kube_api_port" {
  description = "The port number for the Kubernetes API."
  type        = number
  default     = 6443
}
