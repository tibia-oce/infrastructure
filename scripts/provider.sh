#!/bin/bash

print_red() {
  echo -e "\033[31m$1\033[0m"
}

# Check if Terraform credentials file exists
if [ ! -f /root/.terraform.d/credentials.tfrc.json ]; then
  print_red "Error: Terraform credentials file '/root/.terraform.d/credentials.tfrc.json' not found. Please login to Terraform Cloud and try again."
  exit 1
fi

# Check if HCP credentials file exists
if [ ! -f ~/.config/hcp/credentials/cred_file.json ]; then
  # hcp auth login --client-id=<sp_id> --client-secret=<sp_secret>
  print_red "Error: HCP credentials file '~/.config/hcp/credentials/cred_file.json' not found. Please authenticate with the HCP CLI and try again."
  exit 1
fi

# Extracting HashiCorp Cloud values
hashicorp_api_token=$(jq -r '.credentials."app.terraform.io".token' /root/.terraform.d/credentials.tfrc.json)
hashicorp_org_name=$(curl -s \
  --header "Authorization: Bearer $hashicorp_api_token" \
  https://app.terraform.io/api/v2/organizations | jq -r '.data[-1].attributes.name')
hashicorp_workspace=$(curl -s \
  --header "Authorization: Bearer $hashicorp_api_token" \
  https://app.terraform.io/api/v2/organizations/$hashicorp_org_name/workspaces | jq -r '.data[0].attributes.name')

if [ -z "$hashicorp_workspace" ] || [ "$hashicorp_workspace" == "null" ]; then
  print_red "No workspace found in organization $hashicorp_org_name. Please create a workspace, then try again."
  exit 1
fi

# Creating provider.tf file
cat <<EOL > ../terraform/provider.tf
terraform {
  cloud {
    organization = "$hashicorp_org_name"
    workspaces {
      name = "$hashicorp_workspace"
    }
  }
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.64.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.34.0"
    }
  }
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

provider "oci" {
  private_key      = data.hcp_vault_secrets_secret.oci_private_key.secret_value
  
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  region           = var.region
}
EOL
echo "terraform/provider.tf has been generated."
