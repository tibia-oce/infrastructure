resource "oci_identity_compartment" "k3s" {
  compartment_id = var.compartment_ocid
  name           = "k3s"
  description    = "Compartment for k3s cluster resources"
}

module "vault" {
  source              = "./modules/vault"
  root_compartment_id = var.compartment_ocid
  compartment_id      = oci_identity_compartment.k3s.id
  compartment_name    = oci_identity_compartment.k3s.name
  tenancy_ocid        = var.tenancy_ocid
  vault_vault_type    = "DEFAULT"
  vault_user_email    = "user@example.com" # todo: get from root compartment
  dynamic_group_name  = "k3s-dynamic-group"
  vault_user_name     = "k3s-user"
  vault_display_name  = "k3s-vault"
}

module "mysql_password" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.mysql_password.secret_name
  secret_content = data.hcp_vault_secrets_secret.mysql_password.secret_value
}

module "mysql_port" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.mysql_port.secret_name
  secret_content = data.hcp_vault_secrets_secret.mysql_port.secret_value
}

module "mysql_root_password" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.mysql_root_password.secret_name
  secret_content = data.hcp_vault_secrets_secret.mysql_root_password.secret_value
}

module "mysql_database" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.mysql_database.secret_name
  secret_content = data.hcp_vault_secrets_secret.mysql_database.secret_value
}

module "mysql_user" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.mysql_user.secret_name
  secret_content = data.hcp_vault_secrets_secret.mysql_user.secret_value
}

module "reserved_ip" {
  source          = "./modules/reserved_ip"
  compartment_id  = var.compartment_ocid
  lb_display_name = var.lb_display_name
}

module "domain" {
  source               = "./modules/domain"
  lb_public_ip_address = module.reserved_ip.reserved_ip_address
  cf_zone_id           = data.hcp_vault_secrets_secret.cf_zone_id.secret_value
  domain               = var.domain
  depends_on           = [module.reserved_ip]
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

  # SSL Certificate
  private_key        = data.hcp_vault_secrets_secret.cf_private_key.secret_value
  public_certificate = data.hcp_vault_secrets_secret.cf_origin_certificate.secret_value
  ca_certificate     = data.hcp_vault_secrets_secret.ca_certificate.secret_value

  # Security lists and groups
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

  depends_on = [module.domain]
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

# # todo: integrate with existing discord server
# module "discord_server" {
#   source              = "./discord"
#   discord_token       = var.discord_token
#   server_name         = var.server_name
#   server_region       = var.server_region
#   server_icon_file    = var.server_icon_file
#   category_name       = var.category_name
#   create_text_channels = var.create_text_channels
#   text_channels       = var.text_channels
#   create_voice_channels = var.create_voice_channels
#   voice_channels      = var.voice_channels
# }

module "authentik_bootstrap_token" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.authentik_bootstrap_token.secret_name
  secret_content = data.hcp_vault_secrets_secret.authentik_bootstrap_token.secret_value
}

module "authentik_redis_password" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.authentik_redis_password.secret_name
  secret_content = data.hcp_vault_secrets_secret.authentik_redis_password.secret_value
}

module "authentik_secret_key" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.authentik_secret_key.secret_name
  secret_content = data.hcp_vault_secrets_secret.authentik_secret_key.secret_value
}


module "authentik_bootstrap_password" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.authentik_bootstrap_password.secret_name
  secret_content = data.hcp_vault_secrets_secret.authentik_bootstrap_password.secret_value
}


module "authentik_postgresql_password" {
  source         = "./modules/secret"
  vault_id       = module.vault.vault_id
  kms_key_id     = module.vault.kms_id
  compartment_id = oci_identity_compartment.k3s.id

  secret_name    = data.hcp_vault_secrets_secret.authentik_postgresql_password.secret_name
  secret_content = data.hcp_vault_secrets_secret.authentik_postgresql_password.secret_value
}
