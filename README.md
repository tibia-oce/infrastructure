# Oracle K3S Cluster

Deploy a Kubernetes cluster for free, using K3s and Oracle [always free](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) resources.  Deployments of resources are automated with ArgoCD, and HCP cloud is used to sync states remotely to allow multiple members to contribute to infrastructure improvements.

<br>

<p align="center">
  <img src="https://garutilorenzo.github.io/images/k3s-logo-large.png?" alt="k3s Logo"/>
</p>

## Important notes

* This is repo only demonstrates how to use terraform with Oracle Cloud Infrastructure and aims to use the **always free** resources (but in some cases, charges may be incurred depending on region/storage etc..). 
* This examples are **not** for a production environment.
* At the end of your trial period (30 days). unless you have configured pay-as-you-go for your OCI Subscription, all resources deployed will be stopped, hibernated or terminated

<br>

## Requirements

To use this repo you will need:

* an Oracle Cloud account. You can register [here](https://cloud.oracle.com)

Once you get the account, follow the *Before you begin* and *Prepare* steps in [this](https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm) document.

<br>

## Features

### State Management
Terraform Cloud handles the locking and consistency of state files, which helps prevent issues that might arise from multiple users or processes trying to modify the state simultaneously.

<br>

## References

- https://medium.com/@Phoenixforge/a-weekend-project-with-k3s-and-oracle-cloud-free-tier-99eda1aa49a0
- https://github.com/solamarpreet/kubernetes-on-oci
- https://github.com/garutilorenzo/k3s-oci-cluster

<br>

## Todo

- write guide on dedicated terraform user creation to limit scope from root compartment
    - second scripts for this?
- is a private key upload even neccessary??
    - if yes, Vault SSH Secrets Engine?
- update docs with a new set of private keys (named specifically for terraform/oci)
- need fine-grained permissions on oci api/ssh keys
- `oci_core_public_ip` should be idempotent