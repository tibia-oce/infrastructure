# Variables
variable "compartment_ocid" {
  description = "The OCID of the compartment where the resources will be created."
  type        = string
}

variable "vcn_display_name" {
  description = "The display name of the VCN."
  type        = string
  default     = "my-vcn"
}

variable "vcn_cidr_block" {
  description = "The CIDR block for the VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_display_name" {
  description = "The display name of the subnet."
  type        = string
  default     = "my-subnet"
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_domain" {
  description = "The availability domain for the subnet."
  type        = string
}

variable "display_name" {
  description = "The display name of the network load balancer."
  type        = string
  default     = "my-network-lb"
}


variable "subnet_id" {
  description = "The ID of the subnet where the network load balancer will be created."
  type        = string
}

variable "is_private" {
  description = "Whether the network load balancer is private or public."
  type        = bool
  default     = false
}

variable "my_public_ip_cidr" {
  description = "The CIDR block of your public IP address for SSH access."
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block of the subnet."
  type        = string
}

variable "control_plane_private_ips" {
  description = "List of private IP addresses for control plane nodes."
  type        = list(string)
}
