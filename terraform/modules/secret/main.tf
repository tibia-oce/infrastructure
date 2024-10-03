resource "oci_vault_secret" "secret" {
    compartment_id = var.compartment_id
    secret_name    = var.secret_name
    vault_id       = var.vault_id
    key_id         = var.kms_key_id

    secret_content {
        content_type = "BASE64"
        content      = base64encode(var.secret_content)
    }

    lifecycle {
        # Allow Terraform to destroy the secret straight away
        prevent_destroy = false
    }
}
