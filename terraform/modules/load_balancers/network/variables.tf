variable "compartment_ocid" {
  description = "The OCID of the compartment where the network load balancer will be created."
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
