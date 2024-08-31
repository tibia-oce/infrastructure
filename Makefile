# Constants for formatting/prints
RED=\033[31m
GREEN=\033[32m
YELLOW=\033[33m
BLUE=\033[34m
NC=\033[0m

# Load environment variables from .env file, if it exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Define environment variables for directories
export TF_BACKEND_DIR="infra"
export K3S_ENV_DIR="infra"
export SCRIPTS_DIR="scripts"
export ANSIBLE_DIR="ansible"
export VENV_DIR=".venv"
export ANSIBLE_INVENTORY_DIR="ansible/inventory"
export TF_OUTPUT_FILE="$(K3S_ENV_DIR)/terraform_output.json"
export ANSIBLE_INVENTORY_FILE="$(ANSIBLE_INVENTORY_DIR)/hosts.ini"

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
	cd $(K3S_ENV_DIR) && terraform refresh
	cd $(K3S_ENV_DIR) && terraform apply -auto-approve

# Format the Terraform configuration files in the K3S environment
oci-fmt:
	@printf "$(BLUE)Formatting Terraform files in $(K3S_ENV_DIR)...$(NC)\n"
	cd $(K3S_ENV_DIR) && terraform fmt

# Destroy the Terraform-managed infrastructure in the K3S environment with auto-approval
oci-destroy:
	@printf "$(RED)Destroying Terraform-managed infrastructure in $(K3S_ENV_DIR) with auto-approval...$(NC)\n"
	cd $(K3S_ENV_DIR) && terraform destroy -auto-approve

# Generate Terraform outputs and store them in a JSON file
terraform-output:
	@printf "$(GREEN)Extracting Terraform outputs to $(TF_OUTPUT_FILE)...$(NC)\n"
	terraform -chdir=$(K3S_ENV_DIR) output -json > $(TF_OUTPUT_FILE)

# Set up Python virtual environment and install Ansible
setup-env:
	@printf "$(GREEN)Setting up Python virtual environment and installing Ansible...$(NC)\n"
	/bin/bash -c "python3 -m venv $(VENV_DIR) && \
	source $(VENV_DIR)/bin/activate && \
	pip install ansible ansible-core passlib && \
	ansible-galaxy install -r $(ANSIBLE_DIR)/requirements.yml"

# Generate Ansible inventory from Terraform outputs
# TODO: @echo "ansible_ssh_private_key_file=$$(jq -r '.ssh_private_key_file.value' $(TF_OUTPUT_FILE))" >> $(ANSIBLE_INVENTORY_FILE)
generate-inventory: terraform-output
	@printf "$(GREEN)Generating Ansible inventory in $(ANSIBLE_INVENTORY_FILE)...$(NC)\n"
	@echo "[control_plane]" > $(ANSIBLE_INVENTORY_FILE)
	@jq -r '.control_plane_ips.value[]' $(TF_OUTPUT_FILE) >> $(ANSIBLE_INVENTORY_FILE)
	@echo "" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "[workers]" >> $(ANSIBLE_INVENTORY_FILE)
	@jq -r '.worker_ips.value[]' $(TF_OUTPUT_FILE) >> $(ANSIBLE_INVENTORY_FILE)
	@echo "" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "[all:vars]" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "load_balancer_ip=$$(jq -r '.load_balancer_public_ip.value' $(TF_OUTPUT_FILE))" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "ansible_user=ubuntu" >> $(ANSIBLE_INVENTORY_FILE)

ansible-control-plane: generate-inventory
	@printf "$(BLUE)Running Ansible playbook for the control plane...$(NC)\n"
	@temp_key_file=$$(mktemp) && \
	echo "$$SSH_PRIVATE_KEY" > $$temp_key_file && \
	chmod 600 $$temp_key_file && \
	echo "ansible_ssh_private_key_file=$$temp_key_file" >> $(ANSIBLE_INVENTORY_FILE) && \
	trap 'rm -f $$temp_key_file' EXIT && \
	ansible-playbook -i $(ANSIBLE_INVENTORY_FILE) ansible/playbooks/control_plane.yml

# Run Ansible playbook for the worker nodes
ansible-workers: generate-inventory
	@printf "$(BLUE)Running Ansible playbook for the worker nodes...$(NC)\n"
	@temp_key_file=$$(mktemp) && \
	echo "$$SSH_PRIVATE_KEY" > $$temp_key_file && \
	chmod 600 $$temp_key_file && \
	echo "ansible_ssh_private_key_file=$$temp_key_file" >> $(ANSIBLE_INVENTORY_FILE) && \
	trap 'rm -f $$temp_key_file' EXIT && \
	ansible-playbook -i $(ANSIBLE_INVENTORY_FILE) ansible/playbooks/workers.yml

# Sequentially run all necessary steps to bootstrap the K3s cluster
bootstrap-cluster: terraform-output generate-inventory ansible-control-plane ansible-workers
	@printf "$(GREEN)Cluster bootstrapped successfully!$(NC)\n"

