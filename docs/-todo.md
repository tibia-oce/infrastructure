
## Todo

- write guide on dedicated terraform user creation to limit scope from root compartment
    - second scripts for this?
- is a private key upload even neccessary??
    - if yes, Vault SSH Secrets Engine?
- update docs with a new set of private keys (named specifically for terraform/oci)
- need fine-grained permissions on oci api/ssh keys
- `oci_core_public_ip` should be idempotent
- SSH private key is needed by Ansible... can we use a collection for vault to handle this better?
    - temp file isn't practical
- Logging to track of all access attempts and successful connections via SSH?
    - restrict the gateway/nsg ssh access to a whitelist
    - cloudflare tunnel? 
- oci_core_public_ip.ignore_changes could be more specific
- Create bastion server for TF and Ansible
- Configure flannel to use node networking? (https://docs.k3s.io/networking/basic-network-options)

-----

## Install

Follow the installation instructions in each of the following:

Install OCI CLI:
- https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__linux_and_unix

Install Kubectl:
- https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

Install Kustomize:
- https://kubectl.docs.kubernetes.io/installation/kustomize/

Install HCP CLI:
- https://developer.hashicorp.com/hcp/docs/vault-secrets/get-started/install-hcp-cli
- hcp auth login

Install Terraform:
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- terraform login

Install Ansible:
-
-

Generate provider and variables files:
- make tfvars
- make providers

Ensure HCP Vault has required keys:

    ```
    hcp profile init --vault-secrets --app <app>
    hcp vault-secrets secrets create ssh_public_key --data-file=$HOME/.ssh/id_rsa.pub --app <app>
    hcp vault-secrets secrets create ssh_private_key --data-file=$HOME/.ssh/id_rsa --app <app>
    hcp vault-secrets secrets create oci_private_key --data-file=$HOME/.oci/oci_api_key.pem --app <app>

    # Cloudflare variables:
    echo -n 'xxxxx' | hcp vault-secrets secrets create cf_zone_id --data-file=- --app <app>
    echo -n 'xxxxx' | hcp vault-secrets secrets create cf_account_id --data-file=- --app <app>
    echo -n 'xxxxx' | hcp vault-secrets secrets create cf_token --data-file=- --app <app>

    # Create a cloduflare certifate & download cf ca cert
    hcp vault-secrets secrets create cf_origin_certificate --data-file=public_cert.pem --app <app>
    hcp vault-secrets secrets create cf_private_key --data-file=private_key.pem --app <app>
    hcp vault-secrets secrets create cf_ca_certificate --data-file=cloudflare_ca_cert.pem --app <app>
    ```

[!](./assets/images/encryption.png)