variable "compartment_ocid" {
  description = "The OCID of the compartment where the NSG will be created."
  type        = string
}

variable "vcn_id" {
  description = "The ID of the VCN where the NSG will be created."
  type        = string
}
