module "reserved_ip" {
  source          = "./modules/reserved_ip"
  compartment_id  = var.compartment_ocid
  lb_display_name = var.lb_display_name
}

module "network" {
  source            = "./modules/network"
  vcn_cidr          = var.vcn_cidr
  subnet_cidr       = var.subnet_cidr
  compartment_id    = var.compartment_ocid
  my_public_ip_cidr = var.my_public_ip_cidr
  kube_api_port     = var.kube_api_port
  metal_lb_cidr     = var.metal_lb_cidr
  security_lists = [
    module.security.admin_security_list_id,
    module.security.internal_security_list_id,
    module.security.public_security_list_id,
  ]
}

module "security" {
  source            = "./modules/security"
  vcn_id            = module.network.vcn_id
  vcn_cidr          = var.vcn_cidr
  subnet_cidr       = var.subnet_cidr
  compartment_id    = var.compartment_ocid
  my_public_ip_cidr = var.my_public_ip_cidr
  kube_api_port     = var.kube_api_port
}

module "nsg" {
  source                       = "./modules/nsg"
  compartment_ocid             = var.compartment_ocid
  vcn_id                       = module.network.vcn_id
  http_lb_port                 = var.http_lb_port
  https_lb_port                = var.https_lb_port
  kube_api_port                = var.kube_api_port
  expose_kubeapi               = var.expose_kubeapi
  my_public_ip_cidr            = var.my_public_ip_cidr
  lb_public_ip_address         = module.reserved_ip.reserved_ip_address
  all_instance_ips_map         = local.all_instance_ips_map
  all_private_instance_ips_map = local.all_private_instance_ips_map
}

module "flexible_lb" {
  source                     = "./modules/load_balancers/flexible"
  compartment_ocid           = var.compartment_ocid
  public_lb_shape            = var.public_lb_shape
  subnet_id                  = module.network.subnet_id
  reserved_ip_id             = module.reserved_ip.reserved_ip_id
  kube_api_port              = var.kube_api_port
  control_plane_private_ips  = local.k3s_control_plane_private_ips
  worker_node_private_ip_map = local.worker_node_private_ip_map
  security_lists = [
    module.security.admin_security_list_id,
    module.security.internal_security_list_id,
    module.security.public_security_list_id,
  ]
  network_groups = [
    module.nsg.kubeapi_nsg_id,
    module.nsg.game_service_nsg_id,
    module.nsg.public_web_nsg_id,
    module.nsg.ssh_nsg_id,
    module.nsg.admin_nsg_id,
  ]
}

module "control_plane" {
  # TODO: Add count to control plane module
  private_ips           = ["10.0.1.5"]
  source                = "./modules/compute/control_plane"
  ubuntu_arm_image_ocid = "ocid1.image.oc1.ap-sydney-1.aaaaaaaavr5qhtpawoy2ppcmuvd3eq2yz2tfxtukbuwdgisld26qjr7iioaa"
  shape                 = "VM.Standard.A1.Flex"
  ocpus                 = 1
  memory_in_gbs         = 6
  availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_ocid      = var.compartment_ocid
  subnet_id             = module.network.subnet_id
  ssh_authorized_keys   = data.hcp_vault_secrets_secret.ssh_public_key.secret_value
  network_groups = [
    module.nsg.kubeapi_nsg_id,
    module.nsg.game_service_nsg_id,
    module.nsg.public_web_nsg_id,
    module.nsg.ssh_nsg_id,
    module.nsg.admin_nsg_id,
  ]
}

module "workers_arm" {
  arm_instance_count    = 2
  private_ips           = ["10.0.1.10", "10.0.1.11"]
  source                = "./modules/compute/workers_arm"
  ubuntu_arm_image_ocid = "ocid1.image.oc1.ap-sydney-1.aaaaaaaavr5qhtpawoy2ppcmuvd3eq2yz2tfxtukbuwdgisld26qjr7iioaa"
  shape                 = "VM.Standard.A1.Flex"
  memory_in_gbs         = 6
  ocpus                 = 1
  availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_ocid      = var.compartment_ocid
  subnet_id             = module.network.subnet_id
  ssh_authorized_keys   = data.hcp_vault_secrets_secret.ssh_public_key.secret_value
  network_groups = [
    module.nsg.kubeapi_nsg_id,
    module.nsg.game_service_nsg_id,
    module.nsg.public_web_nsg_id,
    module.nsg.ssh_nsg_id,
    module.nsg.admin_nsg_id,
  ]
}

module "workers_x86" {
  x86_instance_count    = 0
  private_ips           = ["10.0.1.20", "10.0.1.21"]
  source                = "./modules/compute/workers_x86"
  ubuntu_x86_image_ocid = "ocid1.image.oc1.ap-sydney-1.aaaaaaaam3pvui5qih7wruqjnfjcjgnq2iiyirpg47rqjeyfarvse53t76ma"
  shape                 = "VM.Standard.E2.1.Micro"
  memory_in_gbs         = 1
  ocpus                 = 1
  availability_domain   = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_ocid      = var.compartment_ocid
  subnet_id             = module.network.subnet_id
  ssh_authorized_keys   = data.hcp_vault_secrets_secret.ssh_public_key.secret_value
  network_groups = [
    module.nsg.kubeapi_nsg_id,
    module.nsg.game_service_nsg_id,
    module.nsg.public_web_nsg_id,
    module.nsg.ssh_nsg_id,
    module.nsg.admin_nsg_id,
  ]
}

module "domain" {
  source               = "./modules/domain"
  lb_public_ip_address = module.reserved_ip.reserved_ip_address
  cf_zone_id           = data.hcp_vault_secrets_secret.cf_zone_id.secret_value
  domain               = var.domain
}

# module "network_lb" {
#   source                    = "./modules/load_balancers/network"
#   display_name              = "my-network-lb"
#   availability_domain       = data.oci_identity_availability_domains.ads.availability_domains[0].name
#   subnet_cidr               = var.subnet_cidr
#   compartment_ocid          = var.compartment_ocid
#   subnet_id                 = module.network.subnet_id
#   my_public_ip_cidr         = var.my_public_ip_cidr
#   control_plane_private_ips = local.k3s_control_plane_private_ips
# }