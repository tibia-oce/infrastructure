module "admin_security_list" {
  source           = "./admin"
  compartment_id = var.compartment_id
  vcn_id           = var.vcn_id
  subnet_cidr      = var.subnet_cidr
  vcn_cidr         = var.vcn_cidr
  my_public_ip_cidr = var.my_public_ip_cidr
  kube_api_port    = var.kube_api_port
}

module "internal_security_list" {
  source           = "./internal"
  compartment_id = var.compartment_id
  vcn_id           = var.vcn_id
  subnet_cidr      = var.subnet_cidr
  vcn_cidr         = var.vcn_cidr
}

module "public_security_list" {
  source           = "./public"
  compartment_id = var.compartment_id
  vcn_id           = var.vcn_id
  subnet_cidr      = var.subnet_cidr
  vcn_cidr         = var.vcn_cidr
  https_lb_port  = var.https_lb_port
}
