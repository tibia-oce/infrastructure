resource "oci_identity_dynamic_group" "vault_access_group" {
  compartment_id = var.root_compartment_id
  name           = var.dynamic_group_name
  description    = "Dynamic group to allow VMs to access Oracle Vault"
  matching_rule = "ANY {instance.compartment.id = '${var.root_compartment_id}', instance.lifecycle.state = 'RUNNING', instance.compartment.id = '${var.compartment_id}'}"
}

resource "oci_identity_user" "vault_user" {
    compartment_id = var.root_compartment_id
    name           = var.vault_user_name
    description    = "User to access the Oracle Vault"
    email          = var.vault_user_email
}

locals {
  policy_statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.vault_access_group.name} to inspect vaults in compartment ${var.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.vault_access_group.name} to use keys in compartment ${var.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.vault_access_group.name} to use secret-family in compartment ${var.compartment_name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.vault_access_group.name} to read secret-bundles in compartment ${var.compartment_name}"
  ]
}

resource "oci_identity_policy" "vault_access_policy" {
    compartment_id = var.compartment_id
    statements     = local.policy_statements
    description    = "Policy for Vault access by VMs"
    name           = "vault-policy"
}

resource "oci_kms_vault" "vault" {
    compartment_id = var.compartment_id
    display_name   = var.vault_display_name
    vault_type     = var.vault_vault_type
}

resource "oci_kms_key" "kms" {
    compartment_id      = var.compartment_id
    display_name        = "kms_key"
    management_endpoint = oci_kms_vault.vault.management_endpoint

    key_shape {
        algorithm = "AES"
        length    = 32
    }
}
