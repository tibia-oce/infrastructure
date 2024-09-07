# HashiCorp


## Terraform Cloud

terraform login

https://app.terraform.io/app/settings/tokens?source=terraform-login

sudo apt-get update
sudo apt-get install jq

## Vault

https://developer.hashicorp.com/hcp/docs/vault-secrets/get-started/install-hcp-cli

https://portal.cloud.hashicorp.com/services/secrets/apps

Create app under '<org>' organisation

create sync integration by registering an organisation token from https://app.terraform.io/app/<org>/settings/authentication-tokens

### Create secret principal

### Create key for service principal

### Login using service principal credentials:
Auth wsl environment with service principal
```
hcp auth login --client-id=<id> --client-secret=<secret>
```

### Set the Vault Application Name in Your Profile
```
hcp profile set vault-secrets/app <app_name>

```

### Upload keys

**TODO: Don't use default 'id_rsa'**

```
hcp profile init --vault-secrets --app <app_name>
hcp vault-secrets secrets create ssh_public_key --data-file=$HOME/.ssh/id_rsa.pub --app <app_name>
hcp vault-secrets secrets create ssh_private_key --data-file=$HOME/.ssh/id_rsa --app <app_name>
hcp vault-secrets secrets create oci_private_key --data-file=$HOME/.oci/oci_api_key.pem --app <app_name>
```

# References
- https://developer.hashicorp.com/hcp/tutorials/get-started-hcp-vault-secrets/hcp-vault-secrets-terraform
