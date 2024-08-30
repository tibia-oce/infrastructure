#!/bin/bash

# Extracting values
compartment_ocid=$(grep '^tenancy=' ~/.oci/config | cut -d'=' -f2 | tr -d '\n')
tenancy_ocid=$(grep '^tenancy=' ~/.oci/config | cut -d'=' -f2 | tr -d '\n')
user_ocid=$(grep '^user=' ~/.oci/config | cut -d'=' -f2 | tr -d '\n')
fingerprint=$(openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c | awk '{print $2}' | tr -d '\n')
region=$(grep '^region=' ~/.oci/config | cut -d'=' -f2 | tr -d '\n')
my_public_ip_cidr=$(echo "$(curl -s ifconfig.me)/32" | tr -d '\n')
private_key_path=~/.oci/oci_api_key.pem

# Creating terraform.tfvars file
cat <<EOL > ../infra/terraform.tfvars
compartment_ocid        = "$compartment_ocid"
tenancy_ocid            = "$tenancy_ocid"
user_ocid               = "$user_ocid"
fingerprint             = "$fingerprint"
region                  = "$region"
my_public_ip_cidr       = "$my_public_ip_cidr"
private_key_path        = "$private_key_path"
ssh_public_key_path     = "~/.ssh/id_rsa.pub"
ssh_private_key_path    = "~/.ssh/id_rsa"
vcn_cidr                = "10.0.0.0/16"
subnet_cidr             = "10.0.1.0/24"

ubuntu_arm_image_ocid   = {"$region" = "ocid1.image.oc1.$region.aaaaaaaavr5qhtpawoy2ppcmuvd3eq2yz2tfxtukbuwdgisld26qjr7iioaa"}
ubuntu_x86_image_ocid   = {"$region" = "ocid1.image.oc1.$region.aaaaaaaavkso6eo5ghy2m3a7p422ihpi5ctoemz6mituscwx46y6qb44pzca"}
arm_instance_count      = 2
x86_instance_count      = 0
EOL

echo "terraform.tfvars has been generated."
