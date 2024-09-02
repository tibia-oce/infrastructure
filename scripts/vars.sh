#!/bin/bash

# TODO: Remove in favour of var.sh script to .tfvars

print_red() {
  echo -e "\033[31m$1\033[0m"
}

# Check if OCI config file exists
if [ ! -f ~/.oci/config ]; then
  print_red "Error: OCI config file '~/.oci/config' not found. Please configure Oracle Cloud per the docs, then try again."
  exit 1
fi

# Check if Terraform credentials file exists
if [ ! -f /root/.terraform.d/credentials.tfrc.json ]; then
  print_red "Error: Terraform credentials file '/root/.terraform.d/credentials.tfrc.json' not found. Please login to Terraform Cloud and try again."
  exit 1
fi

# Check if HCP credentials file exists
if [ ! -f ~/.config/hcp/credentials/cred_file.json ]; then
  print_red "Error: HCP credentials file '~/.config/hcp/credentials/cred_file.json' not found. Please authenticate with the HCP CLI and try again."
  exit 1
fi

# Extracting OCI values
compartment_ocid=$(grep '^tenancy=' ~/.oci/config | cut -d'=' -f2 | tr -d '\n')
tenancy_ocid=$(grep '^tenancy=' ~/.oci/config | cut -d'=' -f2 | tr -d '\n')
user_ocid=$(grep '^user=' ~/.oci/config | cut -d'=' -f2 | tr -d '\n')
fingerprint=$(openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c | awk '{print $2}' | tr -d '\n')
region=$(grep '^region=' ~/.oci/config | cut -d'=' -f2 | tr -d '\n')
my_public_ip_cidr=$(echo "$(curl -s ifconfig.me)/32" | tr -d '\n')
private_key_path=~/.oci/oci_api_key.pem

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

# Extracting HCP credentials
hcp_client_id=$(jq -r '.oauth.client_id' ~/.config/hcp/credentials/cred_file.json)
hcp_client_secret=$(jq -r '.oauth.client_secret' ~/.config/hcp/credentials/cred_file.json)

if [ -z "$hcp_client_id" ] || [ "$hcp_client_id" == "null" ]; then
  print_red "Error: HCP client_id not found in credentials file."
  exit 1
fi

if [ -z "$hcp_client_secret" ] || [ "$hcp_client_secret" == "null" ]; then
  print_red "Error: HCP client_secret not found in credentials file."
  exit 1
fi

# Export the SSH private key for use in Ansible
export SSH_PRIVATE_KEY=$(hcp vault-secrets secrets open ssh_private_key --format=json | jq -r '.static_version.value')
echo "SSH private key has been set for the session."

# Creating terraform.tfvars file
cat <<EOL > ../terraform/terraform.tfvars
hcp_client_id           = "$hcp_client_id"
hcp_client_secret       = "$hcp_client_secret"

compartment_ocid        = "$compartment_ocid"
tenancy_ocid            = "$tenancy_ocid"
user_ocid               = "$user_ocid"
fingerprint             = "$fingerprint"
region                  = "$region"
my_public_ip_cidr       = "$my_public_ip_cidr"
vcn_cidr                = "10.0.0.0/16"
subnet_cidr             = "10.0.1.0/24"

ubuntu_arm_image_ocid   = {"$region" = "ocid1.image.oc1.$region.aaaaaaaavr5qhtpawoy2ppcmuvd3eq2yz2tfxtukbuwdgisld26qjr7iioaa"}
ubuntu_x86_image_ocid   = {"$region" = "ocid1.image.oc1.$region.aaaaaaaavkso6eo5ghy2m3a7p422ihpi5ctoemz6mituscwx46y6qb44pzca"}
arm_instance_count      = 2
x86_instance_count      = 0

# If not using HCP Vault Secrets
# private_key_path        = "$private_key_path"
# ssh_public_key_path     = "~/.ssh/id_rsa.pub"
# ssh_private_key_path    = "~/.ssh/id_rsa"

EOL
echo "terraform/terraform.tfvars has been generated."

echo "$SSH_PRIVATE_KEY"