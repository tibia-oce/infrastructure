module "kubeapi_nsg" {
  source            = "./kubeapi"
  compartment_ocid  = var.compartment_ocid
  vcn_id            = var.vcn_id
  additional_trusted_sources   = var.additional_trusted_sources
  all_private_instance_ips_map = var.all_private_instance_ips_map
  all_instance_ips_map = var.all_instance_ips_map
  my_public_ip_cidr            = var.my_public_ip_cidr
  kube_api_port                = var.kube_api_port
}

module "ssh_nsg" {
  source            = "./ssh"
  compartment_ocid  = var.compartment_ocid
  vcn_id            = var.vcn_id
  additional_trusted_sources   = var.additional_trusted_sources
  my_public_ip_cidr            = var.my_public_ip_cidr
}

module "admin_nsg" {
  source            = "./admin"
  compartment_ocid  = var.compartment_ocid
  vcn_id            = var.vcn_id
  additional_trusted_sources   = var.additional_trusted_sources
  my_public_ip_cidr            = var.my_public_ip_cidr
}

module "public_web_nsg" {
  source            = "./web"
  compartment_ocid  = var.compartment_ocid
  vcn_id            = var.vcn_id
  http_lb_port                 = var.http_lb_port
  https_lb_port                = var.https_lb_port
}

module "game_service_nsg" {
  source            = "./game"
  compartment_ocid  = var.compartment_ocid
  vcn_id            = var.vcn_id
}
