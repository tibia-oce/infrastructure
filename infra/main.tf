data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "hcp_vault_secrets_secret" "oci_private_key" {
  app_name    = var.vault_app_name
  secret_name = var.oci_private_key_secret_name
}

data "hcp_vault_secrets_secret" "ssh_private_key" {
  app_name    = var.vault_app_name
  secret_name = var.ssh_private_key_secret_name
}

data "hcp_vault_secrets_secret" "ssh_public_key" {
  app_name    = var.vault_app_name
  secret_name = var.ssh_public_key_secret_name
}

data "oci_core_public_ips" "existing_ip" {
  compartment_id = var.compartment_ocid
  scope          = "REGION"
}

locals {
  existing_ip = [
    for ip in data.oci_core_public_ips.existing_ip.public_ips :
    ip if ip.display_name == "${var.lb_display_name}-public-ip"
  ]

  reserved_ip_id      = length(local.existing_ip) > 0 ? local.existing_ip[0].id : null
  reserved_ip_address = length(local.existing_ip) > 0 ? local.existing_ip[0].ip_address : null
}