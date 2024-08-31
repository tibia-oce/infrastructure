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
