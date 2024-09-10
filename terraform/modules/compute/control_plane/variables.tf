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
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  description = "Number of OCPUs for the instance."
  type        = number
  default     = 1
}

variable "control_plane_count" {
  description = "Number of control plane nodes."
  type        = number
  default     = 1
}

variable "memory_in_gbs" {
  description = "Amount of memory in GBs for the instance."
  type        = number
  default     = 6
}

variable "subnet_id" {
  description = "The subnet ID where the instance will be created."
  type        = string
}

variable "network_groups" {
  description = "The list of NSG IDs for traffic."
  type        = list(string)
}

variable "ubuntu_arm_image_ocid" {
  description = "The OCID of the Ubuntu ARM image."
  type        = string
}

variable "ssh_authorized_keys" {
  description = "The SSH authorized keys for the instance."
  type        = string
}

variable "private_ips" {
  type    = list(string)
  default = []
}
