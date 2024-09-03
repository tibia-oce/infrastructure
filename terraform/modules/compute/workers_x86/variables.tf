variable "availability_domain" {
  description = "The availability domain where the instance will be created."
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where the instance will be created."
  type        = string
}

variable "shape" {
  description = "The shape of the instance."
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "ocpus" {
  description = "Number of OCPUs for the instance."
  type        = number
  default     = 1
}

variable "memory_in_gbs" {
  description = "Amount of memory in GBs for the instance."
  type        = number
  default     = 1
}

variable "subnet_id" {
  description = "The subnet ID where the instance will be created."
  type        = string
}

variable "lb_to_instances_http_nsg_id" {
  description = "The NSG ID for HTTP traffic."
  type        = string
}

variable "ubuntu_x86_image_ocid" {
  description = "The OCID of the Ubuntu x86 image."
  type        = string
}

variable "ssh_authorized_keys" {
  description = "The SSH authorized keys for the instance."
  type        = string
}

variable "x86_instance_count" {
  description = "The number of x86 worker instances to create."
  type        = number
  default     = 1
}
