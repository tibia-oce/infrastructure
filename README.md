<div align="center">

<img src="https://miro.medium.com/v2/resize:fit:1024/0*tTUoVKGzxtZYA5xp.png" align="center" width="144px" height="144px"/>

### Mythbound Tibia Infrastructure :octocat:

_... managed with ArgoCD, Renovate, Ansible and Terraform_ 🤖

</div>

<div align="center">

[![Kubernetes](https://img.shields.io/static/v1?label=K3s&message=v1.30.2&color=blue&style=for-the-badge&logo=kubernetes&logoColor=white)](https://k3s.io/)&nbsp;&nbsp;
[![Discord](https://img.shields.io/discord/1283279739775352896?style=for-the-badge&label&logo=discord&logoColor=white&color=blue)]([https://discord.gg/1283279739775352896](https://discord.gg/Erhz4GmDMd))&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/tibia-oce/oci/renovate.yml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/tibia-oce/oci/actions/workflows/renovate.yml)

</div>

<div align="center">

[![Cluster](https://img.shields.io/static/v1?label=Cluster&message=Online&color=brightgreen&style=for-the-badge&logo=v&logoColor=white)](#)&nbsp;&nbsp;
[![Server](https://img.shields.io/static/v1?label=Server&message=Offline&color=red&style=for-the-badge&logo=v&logoColor=white)](#)&nbsp;&nbsp;
[![Website](https://img.shields.io/static/v1?label=Website&message=Offline&color=red&style=for-the-badge&logo=statuspage&logoColor=white)](#)&nbsp;&nbsp;

</div>

<br>

---

<br>

# 🏠 Oracle K3S Cluster

This mono-repository demonstrates how to deploy a K3s Kubernetes cluster for free on Oracle [always free resources](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm).  Infrastructure provisioning, configuration and deployments are managed with Infrastructure as Code (IaC) and GitOps; using toolings from [Ansible](https://www.ansible.com/), [HashiCorp](https://www.hashicorp.com/), [Kubernetes](https://kubernetes.io/), [Helm](https://github.com/helm/helm), [Kustomize](https://kustomize.io/), [ArgoCD](https://github.com/argoproj/argo-cd), [Renovate](https://github.com/renovatebot/renovate), and [GitHub Actions](https://github.com/features/actions).

<br>

## ⛵ Features

### GitOps

[Argo CD](https://argo-cd.readthedocs.io/en/stable/) monitors the repository's Kubernetes manifests and ensures the cluster matches the desired state in Git. When changes are merged, Argo CD automatically applies them to the cluster.

[Renovate](https://github.com/renovatebot/renovate) watches for dependency updates, creating pull requests when updates are found. Once merged, Argo CD detects and applies the changes, deploying the updated dependencies.

### State Management
[Terraform Cloud](https://www.hashicorp.com/products/terraform) handles the locking and consistency of state files, which helps prevent issues that might arise from multiple users or processes trying to modify the state simultaneously.

### Secret Management

[HashiCorp Vault](https://www.vaultproject.io/) stores and manages secrets, passwords, and API keys. It controls access, provides dynamic secrets, and supports automatic rotation to enhance security and limit exposure.

### Core Components

- [cloudflare](https://www.cloudflare.com/en-au/application-services/products/dns/): dns resolution for layer 4 and layer 7 cluster applications.
- [metal-lb](https://metallb.universe.tf/): layer 2 & 3 network load balancing to integrate with Oracle cloud without a CCM.
- [nginx](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/): an os-level pass through proxy to support cloud integration.
- [flannel](https://github.com/flannel-io/flannel): internal Kubernetes container networking interface.
- [traefik](https://doc.traefik.io/traefik/): as a reverse proxy and service load balancing ingress controller.
- [cert-manager](https://github.com/cert-manager/cert-manager): manages SSL certificates for services in the cluster.
- [gatus](https://gatus.io/): monitors the health and performance of services, with alerts.
- [cloudflared](https://github.com/cloudflare/cloudflared): enables zero-trust tunnelling to certain ingress routes.

<br>

## 🌐 Network topology

Here's a macroscopic overview of the state of the network, integrated with Oracle ingress points.

![network](/docs/assets/drawings/topology.excalidraw.svg)

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

## 🔧 Requirements

> [!NOTE]
>
> This repository is for demonstration only and not recommended for production. It uses [OCI always-free](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm), re-claimable compute instances, which after the 30-day trial, OCI may stop, hibernate, or terminate.

To use this repo you will need:

* an Oracle Cloud account.
* a HCP Vault account.
* a HCP Terraform account.
* a HCP Service Principal.

Read more [here](/docs/0-setup.md).

<br> 

## 🤙 Related projects & many thanks 

This project was heavily influenced by the following work and communities, shout out to all the amazing people and resources for design, code and ideas:

- [r/Homelab](https://www.reddit.com/r/homelab/)
- [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible)
- [techno-tim/k3s-ansible](https://github.com/techno-tim/k3s-ansible)
- [solamarpreet/kubernetes-on-oci](https://github.com/solamarpreet/kubernetes-on-oci)
- [garutilorenzo/k3s-oci-cluster](https://github.com/garutilorenzo/k3s-oci-cluster)
- [kaplunb/oracle-cloud-k3s-article01](https://github.com/kaplunb/oracle-cloud-k3s-article01)
