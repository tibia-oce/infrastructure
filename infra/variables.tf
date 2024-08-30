variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key_path" {}
variable "ssh_private_key_path" {}
variable "vcn_cidr" {}
variable "subnet_cidr"{}
variable "ubuntu_arm_image_ocid" {}
variable "arm_instance_count" {}
variable "ubuntu_x86_image_ocid" {}
variable "x86_instance_count" {}
variable "my_public_ip_cidr" {}

variable "kube_api_port" {
  type    = number
  default = 6443
}

variable "http_lb_port" {
  type    = number
  default = 80
}

variable "https_lb_port" {
  type    = number
  default = 443
}

variable "expose_kubeapi" {
  type    = bool
  default = false
}

variable "public_lb_shape" {
  type    = string
  default = "flexible"
}
