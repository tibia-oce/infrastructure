variable "compartment_id" {
  description = "The OCID of the compartment where the key and secret will be created."
  type        = string
}

variable "kms_key_id" {
  description = "The KMS id for the vault."
  type        = string
}

variable "secret_name" {
  description = "The name of the secret to be created in the vault."
  type        = string
}

variable "vault_id" {
  description = "The OCID of the vault where the secret will be stored."
  type        = string
}

variable "secret_content" {
  description = "The content of the secret, which will be base64 encoded."
  type        = string
}

