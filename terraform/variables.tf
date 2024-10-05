# ====================================================================
# Discord channel variables
# These variables are used to authenticate with the Discord bot/app
# and to configure the server.
# ====================================================================

variable "discord_token" {
    type = string
    sensitive = true
    default = ""
    description = "Discord API token"
}

variable "server_name" {
    type = string
    default = "Mythbound"
    description = "Name of server to create"
}

variable "server_region" {
    type = string
    default = "sydney"
    description = "Geographical region to create server in"
}

variable "server_icon_file" {
    type = string
    default = "discord/terraformLogoDark.png"
    description = "File name or path of server icon to use"
}

variable "category_name" {
    type = string
    default = "General"
    description = "Name of category to create in server"
}

variable "create_text_channels" {
    type = bool
    description = "Whether or not to create text channels from 'text_channels' list"
    default = false
}

variable "text_channels" {
    type = list
    description = "List of text channels to create under created category, if any"
    default = ["general", "text channel 1"]
}

variable "create_voice_channels" {
    type = bool
    default = false
    description = "Whether or not to create voice channels from 'text_channels' list"
}

variable "voice_channels" {
    type = list
    default = []
    description = "List of voice channels to create under created category, if any"
}

# ====================================================================
# HCP Provider Variables
# These variables are used to authenticate with HashiCorp Cloud Platform
# and retrieve secrets from the HCP Vault app.
# ====================================================================

variable "hcp_client_id" {
  description = "The client ID for HCP authentication. This should be obtained from your HCP service principal credentials."
  type        = string
  sensitive   = true
}

variable "hcp_client_secret" {
  description = "The client secret for HCP authentication. This should be obtained from your HCP service principal credentials."
  type        = string
  sensitive   = true
}

variable "vault_app_name" {
  description = "The name of the Vault Secrets application."
  type        = string
  default     = "tibia-oce" # TODO: Remove in favour of var.sh script to .tfvars
}

variable "oci_private_key_secret_name" {
  description = "The name of the OCI private key secret in Vault."
  type        = string
  default     = "oci_private_key"
}

variable "ssh_private_key_secret_name" {
  description = "The name of the SSH private key secret in Vault."
  type        = string
  default     = "ssh_private_key"
}

variable "ssh_public_key_secret_name" {
  description = "The name of the SSH public key secret in Vault."
  type        = string
  default     = "ssh_public_key"
}

variable "k3s_token" {
  description = "The name of the k3s token secret in Vault."
  type        = string
  default     = "k3s_token"
}

variable "domain" {
  description = "Website domain name."
  default     = "mythbound.dev"
}

# ====================================================================
# OCI (Oracle Cloud Infrastructure) Configuration
# These variables define the essential identifiers and configuration
# parameters needed to interact with your OCI tenancy and resources.
# ====================================================================

variable "tenancy_ocid" {
  description = "The OCID of the tenancy in Oracle Cloud Infrastructure."
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "The OCID of the user in Oracle Cloud Infrastructure."
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "The fingerprint of the public key used for API signing in OCI."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The OCI region where resources will be created (e.g., ap-sydney-1)."
  type        = string
}

variable "compartment_ocid" {
  description = "The OCID of the compartment in which resources will be managed."
  type        = string
}

# ====================================================================
# Networking Configuration
# These variables define CIDR blocks and public IPs for networking.
# ====================================================================

variable "vcn_cidr" {
  description = "CIDR block for the Virtual Cloud Network (VCN) in OCI."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet within the VCN."
  type        = string
}

variable "my_public_ip_cidr" {
  description = "CIDR block for your public IP (e.g., 203.0.113.1/32) to allow traffic."
  type        = string
}

# ====================================================================
# Compute Instance Configuration
# These variables define the images and instance counts for ARM and x86 architectures.
# ====================================================================

variable "ubuntu_arm_image_ocid" {
  description = "Map of OCI ARM image OCIDs keyed by region."
  type        = map(string)
}

variable "ubuntu_x86_image_ocid" {
  description = "Map of OCI x86 image OCIDs keyed by region."
  type        = map(string)
}

variable "arm_instance_count" {
  description = "The number of ARM-based compute instances to provision."
  type        = number
}

variable "x86_instance_count" {
  description = "The number of x86-based compute instances to provision."
  type        = number
}

# ====================================================================
# Kubernetes Configuration
# These variables define ports and settings for Kubernetes and load balancers.
# ====================================================================

variable "kube_api_port" {
  description = "The port on which the Kubernetes API will be exposed."
  type        = number
  default     = 6443
}

variable "http_lb_port" {
  description = "The port for HTTP traffic on the public load balancer."
  type        = number
  default     = 80
}

variable "https_lb_port" {
  description = "The port for HTTPS traffic on the public load balancer."
  type        = number
  default     = 443
}

variable "expose_kubeapi" {
  description = "Boolean to control whether the Kubernetes API should be publicly exposed."
  type        = bool
  default     = true
}

variable "public_lb_shape" {
  description = "The shape of the public load balancer (e.g., flexible)."
  type        = string
  default     = "flexible"
}

variable "lb_display_name" {
  description = "The display name of the load balancer in OCI."
  type        = string
  default     = "lb"
}

variable "additional_trusted_sources" {
  description = "Additional CIDR blocks of trusted sources."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "metal_lb_cidr" {
  description = "The CIDR block of MetalLB network."
  default     = "10.0.1.96/28" # Covers 10.0.1.96 - 10.0.1.111
  type        = string
}
