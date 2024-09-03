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
