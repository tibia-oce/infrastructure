<p align="center">
  <img src="https://garutilorenzo.github.io/images/k3s-logo-large.png?" alt="k3s Logo"/>
</p>

<br>

# 🏠 Oracle K3S Cluster

> [!NOTE]
>
> This repository is for demonstration only and not recommended for production. It uses [OCI always-free](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm), re-claimable compute instances, which after the 30-day trial, OCI may stop, hibernate, or terminate.

This mono-repository demonstrates how to deploy a Kubernetes (K3s) cluster for free on Oracle [always free resources](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm).  Infrastructure provisioning, configuration and deployments are managed with Infrastructure as Code (IaC) and GitOps; using toolings from [Ansible](https://www.ansible.com/), [HashiCorp](https://www.hashicorp.com/), [Kubernetes](https://kubernetes.io/), [Helm](https://github.com/helm/helm), [Kustomize](https://kustomize.io/), [ArgoCD](https://github.com/argoproj/argo-cd), [Renovate](https://github.com/renovatebot/renovate), and [GitHub Actions](https://github.com/features/actions).

<br>

## ⛵ Features

### State Management
[Terraform Cloud](https://www.hashicorp.com/products/terraform) handles the locking and consistency of state files, which helps prevent issues that might arise from multiple users or processes trying to modify the state simultaneously.

### GitOps
[Argo](https://argo-cd.readthedocs.io/en/stable/) watches the definitions in the kubernetes folder and makes the changes to the clusters based on the state of the Git repository. [Renovate](https://github.com/renovatebot/renovate) watches the entire repository looking for dependency updates, when they are found a PR is automatically created. When some PRs are merged Flux applies the changes to the cluster.

<br>

## 🔧 Requirements

To use this repo you will need:

* an Oracle Cloud account. You can register [here](https://cloud.oracle.com)

Once you get the account, follow the *Before you begin* and *Prepare* steps in [this](https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm) document.

<br> 

### 📁 Directories

This Git repository contains the following directories:

```zsh
📁 oci
├── 📁 scripts                      # Utility bash scripts used to assist in preparing credentials
├── 📁 ansible                      
│   ├── 📁 collections              # Required Ansible collections used across playbooks
│   ├── 📁 inventory                # Inventory files for managing host groups and variables
│   └── 📁 roles                    # Roles for reusable automation tasks
├── 📁 kubernetes                   
│   ├── 📁 apps                     # Application-specific manifests and configurations for Kubernetes
│   └── 📁 argo                     # ArgoCD configuration files for managing Kubernetes applications
└── 📁 terraform                    
    └── 📁 modules                  
        ├── 📁 compute              # Terraform modules for managing compute instances
        ├── 📁 load_balancers       # Terraform modules for configuring load balancers
        ├── 📁 networking           # Terraform modules for setting up network components
        ├── 📁 reserved_ip          # Terraform modules for managing reserved IP addresses
        ├── 📁 security_groups      # Terraform modules for defining network security groups
        └── 📁 security_lists       # Terraform modules for configuring network security lists 
```

<br>

## 🤙 Related projects & many thanks 

This project was heavily influenced by the following work and communities, shout out to all the amazing people and resources for design, code and ideas:

- [r/Homelab](https://www.reddit.com/r/homelab/)
- [techno-tim/k3s-ansible](https://github.com/techno-tim/k3s-ansible)
- [solamarpreet/kubernetes-on-oci](https://github.com/solamarpreet/kubernetes-on-oci)
- [garutilorenzo/k3s-oci-cluster](https://github.com/garutilorenzo/k3s-oci-cluster)
- [kaplunb/oracle-cloud-k3s-article01](https://github.com/kaplunb/oracle-cloud-k3s-article01)

<br>

## 🌐 Network topology

Here's a macroscopic overview of the state of the network, connecting all the devices together, including this lab.

![network](https://raw.githubusercontent.com/tibia-oce/oci/main/docs/assets/drawings/topology.excalidraw.svg)

<br>

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
