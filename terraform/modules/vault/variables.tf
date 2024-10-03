variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment where resources will be created."
  type        = string
}

variable "root_compartment_id" {
  description = "The OCID of the compartment where resources will be created."
  type        = string
}

variable "compartment_name" {
  description = "The name of the compartment where resources will be created."
  type        = string
}

variable "vault_display_name" {
  description = "The display name for the Vault."
  type        = string
  default     = "my-vault"
}

variable "vault_vault_type" {
  description = "The type of the Vault (DEFAULT or VIRTUAL_PRIVATE)."
  type        = string
  default     = "DEFAULT"
}

variable "vault_user_name" {
  description = "The name of the user who will access the Vault secret."
  type        = string
}

variable "vault_user_email" {
  description = "The email of the user who will access the Vault secret."
  type        = string
  default     = "user@example.com"
}

variable "dynamic_group_name" {
  description = "The name of the dynamic group for instance access control."
  type        = string
}
