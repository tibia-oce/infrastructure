variable "compartment_id" {
  description = "The OCID of the compartment where the reserved IP will be created."
  type        = string
}

variable "lb_display_name" {
  description = "Display name for the load balancer."
  type        = string
}
