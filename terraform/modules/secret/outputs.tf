output "secret_id" {
  description = "The OCID of the secret stored in the vault."
  value       = oci_vault_secret.secret.id
}

output "secret_name" {
  description = "The name of the secret stored in the vault."
  value       = oci_vault_secret.secret.secret_name
}
