# Define environment variables for directories and IP addresses
export TF_BACKEND_DIR="infra"       # Directory containing Terraform backend files
export K3S_ENV_DIR="infra"          # Directory containing K3S environment configuration
export SCRIPTS_DIR="scripts"        # Directory containing utility scripts
export CONTROL_PLANE_IP=152.67.97.100            # Control plane node IP address (to be set)
export LOAD_BALANCER_IP=168.138.109.226            # Load balancer IP address (to be set)

# ANSI color codes
RED=\033[31m
GREEN=\033[32m
YELLOW=\033[33m
BLUE=\033[34m
NC=\033[0m # No Color

# Generate a hidden tfvars file with OCI credentials from the Terraform agent
tfvars:
	@printf "$(GREEN)Generating tfvars file with OCI credentials...$(NC)\n"
	cd $(SCRIPTS_DIR) && ./vars.sh

# Generate provider configuration with OCI credentials from the Terraform agent
provider:
	@printf "$(GREEN)Generating provider configuration...$(NC)\n"
	cd $(SCRIPTS_DIR) && ./provider.sh

# SSH into the control plane node
control-node:
	@printf "$(YELLOW)Connecting to the control plane node at $(CONTROL_PLANE_IP)...$(NC)\n"
	ssh -i "~/.ssh/id_rsa" ubuntu@$(CONTROL_PLANE_IP)

# Retrieve the Kubeconfig from the control plane node and set up kubectl
kube-config:
	@printf "$(BLUE)Retrieving Kubeconfig from control plane node...$(NC)\n"
	mkdir -p ~/.kube
	scp -i "~/.ssh/id_rsa" ubuntu@$(CONTROL_PLANE_IP):/home/ubuntu/kubeconfig ~/.kube/config
	@printf "$(GREEN)Setting up KUBECONFIG and verifying cluster nodes...$(NC)\n"
	export KUBECONFIG=~/.kube/config
	kubectl get nodes

# Test connectivity to the Kubernetes API via the load balancer
curl-lb:
	@printf "$(YELLOW)Curling the Kubernetes API at https://$(LOAD_BALANCER_IP):6443...$(NC)\n"
	curl -k https://$(LOAD_BALANCER_IP):6443

# Get the list of nodes in the Kubernetes cluster
get-nodes:
	@printf "$(BLUE)Getting the list of nodes in the Kubernetes cluster...$(NC)\n"
	kubectl get nodes

# Initialize Terraform for the K3S environment
oci-init:
	@printf "$(GREEN)Initializing Terraform in $(K3S_ENV_DIR)...$(NC)\n"
	cd $(K3S_ENV_DIR) && terraform init

# Generate and display a Terraform execution plan for the K3S environment
oci-plan:
	@printf "$(YELLOW)Generating Terraform plan in $(K3S_ENV_DIR)...$(NC)\n"
	cd $(K3S_ENV_DIR) && terraform plan

# Apply the Terraform plan to the K3S environment with auto-approval
oci-apply:
	@printf "$(GREEN)Applying Terraform plan in $(K3S_ENV_DIR) with auto-approval...$(NC)\n"
	cd $(K3S_ENV_DIR) && terraform apply -auto-approve

# Format the Terraform configuration files in the K3S environment
oci-fmt:
	@printf "$(BLUE)Formatting Terraform files in $(K3S_ENV_DIR)...$(NC)\n"
	cd $(K3S_ENV_DIR) && terraform fmt

# Destroy the Terraform-managed infrastructure in the K3S environment with auto-approval
oci-destroy:
	@printf "$(RED)Destroying Terraform-managed infrastructure in $(K3S_ENV_DIR) with auto-approval...$(NC)\n"
	cd $(K3S_ENV_DIR) && terraform destroy -auto-approve
