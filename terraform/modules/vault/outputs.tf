output "vault_id" {
  description = "The OCID of the created Vault"
  value       = oci_kms_vault.vault.id
}

output "kms_id" {
  description = "The OCID of the created Vault"
  value       = oci_kms_key.kms.id
}

output "vault_management_endpoint" {
  description = "The management endpoint of the created vault"
  value       = oci_kms_vault.vault.management_endpoint
}
