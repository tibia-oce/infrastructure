variable "compartment_id" {
  description = "The OCID of the compartment where the security lists will be created."
  type        = string
}

variable "vcn_id" {
  description = "The ID of the VCN where the security lists will be created."
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block of the subnet within the VCN."
  type        = string
}

variable "vcn_cidr" {
  description = "The CIDR block of the VCN."
  type        = string
}
