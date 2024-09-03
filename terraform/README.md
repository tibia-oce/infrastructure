# Terraform

## Service architecture
[always-free Oracle services](../docs/8-always-free.md)

## Directory structure

```
terraform/
├── modules/
│   ├── compute/
│   │   ├── main.tf
│   │   ├── data.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── network/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── nsg/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── reserved_ip/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── load_balancers/
│   │   ├── flexible/
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── network/
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
├── main.tf
├── data.tf
├── outputs.tf
├── provider.tf
└── variables.tf
```