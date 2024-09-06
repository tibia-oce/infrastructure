# Constants for formatting/prints
RED=\033[31m
GREEN=\033[32m
YELLOW=\033[33m
BLUE=\033[34m
NC=\033[0m

# Define environment variables for directories
export TF_DIR="terraform"
export SCRIPTS_DIR="scripts"
export ANSIBLE_DIR="ansible"
export VENV_DIR=".venv"
export TF_OUTPUT_FILE="$(TF_DIR)/terraform_output.json"
export ANSIBLE_INVENTORY_DIR="ansible/inventory"
export ANSIBLE_INVENTORY_FILE="$(ANSIBLE_INVENTORY_DIR)/hosts.ini"

# Generate a hidden tfvars file with OCI credentials from the Terraform agent
tfvars:
	@printf "$(GREEN)Generating tfvars file with OCI credentials...$(NC)\n"
	cd $(SCRIPTS_DIR) && ./vars.sh

# Generate provider configuration with OCI credentials from the Terraform agent
provider:
	@printf "$(GREEN)Generating provider configuration...$(NC)\n"
	cd $(SCRIPTS_DIR) && ./provider.sh

# Initialize Terraform for the K3S environment
oci-init:
	@printf "$(GREEN)Initializing Terraform in $(TF_DIR)...$(NC)\n"
	cd $(TF_DIR) && terraform init

# Generate and display a Terraform execution plan for the K3S environment
oci-plan:
	@printf "$(YELLOW)Generating Terraform plan in $(TF_DIR)...$(NC)\n"
	cd $(TF_DIR) && terraform plan

# Sync state with HCP remote backend
oci-refresh:
	@printf "$(GREEN)Refreshing Terraform state from remote HCP Terraform Cloud...$(NC)\n"
	cd $(TF_DIR) && terraform refresh

# Apply the Terraform plan to the K3S environment with auto-approval
oci-apply:
	@printf "$(GREEN)Applying Terraform plan in $(TF_DIR) with auto-approval...$(NC)\n"
	cd $(TF_DIR) && terraform apply -auto-approve

# Format the Terraform configuration files in the K3S environment
oci-fmt:
	@printf "$(BLUE)Formatting Terraform files in $(TF_DIR)...$(NC)\n"
	cd $(TF_DIR) && terraform fmt

# Destroy the Terraform-managed infrastructure in the K3S environment with auto-approval
oci-destroy:
	@printf "$(RED)Destroying Terraform-managed infrastructure in $(TF_DIR) with auto-approval...$(NC)\n"
	cd $(TF_DIR) && terraform destroy -auto-approve

# Generate Terraform outputs and store them in a JSON file
terraform-output:
	@printf "$(GREEN)Extracting Terraform outputs to $(TF_OUTPUT_FILE)...$(NC)\n"
	terraform -chdir=$(TF_DIR) output -json > $(TF_OUTPUT_FILE)

# Generate Ansible inventory from Terraform outputs
generate-inventory: terraform-output
	@printf "$(GREEN)Generating Ansible inventory in $(ANSIBLE_INVENTORY_FILE)...$(NC)\n"
	@mkdir -p $(ANSIBLE_INVENTORY_DIR)  # Ensure the directory exists
	
	@echo "[master]" > $(ANSIBLE_INVENTORY_FILE)
	@jq -r '.control_plane_public_ips.value[]' $(TF_OUTPUT_FILE) >> $(ANSIBLE_INVENTORY_FILE)
	@echo "" >> $(ANSIBLE_INVENTORY_FILE)
	
	@echo "[node]" >> $(ANSIBLE_INVENTORY_FILE)
	@jq -r '.worker_public_ips.value[]' $(TF_OUTPUT_FILE) >> $(ANSIBLE_INVENTORY_FILE)
	@echo "" >> $(ANSIBLE_INVENTORY_FILE)
	
	@echo "[k3s_cluster:children]" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "master" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "node" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "" >> $(ANSIBLE_INVENTORY_FILE)
	
	@echo "[all:vars]" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "load_balancer_ip=$$(jq -r '.load_balancer_public_ip.value' $(TF_OUTPUT_FILE))" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "ansible_user=ubuntu" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "ansible_ssh_private_key_file=~/.ssh/id_rsa" >> $(ANSIBLE_INVENTORY_FILE)
	
	@load_balancer_ip=$$(jq -r '.load_balancer_public_ip.value' $(TF_OUTPUT_FILE)); \
	sed -i "s|apiserver_endpoint:.*|apiserver_endpoint: $$load_balancer_ip|" ./ansible/inventory/group_vars/all.yml
	@printf "$(GREEN)Updated apiserver_endpoint in all.yml with the load_balancer_public_ip...$(NC)\n"

# Set up Python virtual environment and install Ansible
setup-env:
	@printf "$(GREEN)Setting up Python virtual environment and installing Ansible...$(NC)\n"
	cd ansible/ && python3 -m venv $(VENV_DIR)
	. ansible/$(VENV_DIR)/bin/activate && pip install -q -r ansible/requirements.txt
	ansible-galaxy install -r ansible/collections/requirements.yml

# Sequentially run all necessary steps to bootstrap the K3s cluster
bootstrap-cluster: terraform-output generate-inventory setup-env
	@printf "$(GREEN)Bootstrapping the K3s nodes...$(NC)\n"
	cd ansible && . $(VENV_DIR)/bin/activate && ansible-playbook ./site.yml -i ./inventory/hosts.ini --private-key ~/.ssh/id_rsa -e 'ansible_remote_tmp=/tmp/.ansible/tmp'
	@cp ./ansible/kubeconfig ~/.kube/config
	@printf "$(GREEN)Cluster bootstrapped successfully!$(NC)\n"
	@kubectl cluster-info
	@printf "$(GREEN)Restarting Metrics Server...$(NC)\n"
	@kubectl rollout restart deployment metrics-server -n kube-system
	@printf "$(GREEN)Starting Traefik pods...$(NC)\n"
	@kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
	@kubectl apply -k ./kubernetes/traefik/
	@printf "$(GREEN)Waiting for Traefik pods to be ready...$(NC)\n"
	@timeout 20 bash -c 'while ! kubectl get pods -n traefik | grep -q "1/1 *Running"; do sleep 2; done'
	@if [ $$? -eq 0 ]; then \
		printf "$(GREEN)All Traefik pods are ready!$(NC)\n"; \
	else \
		printf "$(RED)Timed out waiting for Traefik pods to be ready$(NC)\n"; \
		exit 1; \
	fi
	@kubectl get pods --all-namespaces

# Retrieve the Kubeconfig from the control plane node and set up kubectl
config-kube:
	@printf "$(GREEN)Copying kubeconfig from ansible to ~/.kube/config...$(NC)\n"
	@cp ./ansible/kubeconfig ~/.kube/config
	@printf "$(GREEN)Kubeconfig copied successfully!$(NC)\n"

# Command to verify connection by getting Kubernetes nodes
apply-charts: config-kube
	@printf "$(GREEN)Deploying ingress controller and checking pod status...$(NC)\n"
	# @kubectl apply -k ./kubernetes/apps/
	@kubectl get nodes
	@kubectl cluster-info
	@kubectl get pods --all-namespaces

# SSH into the first control plane node
ssh-control-plane: terraform-output
	@printf "$(GREEN)SSH into the first control plane node...$(NC)\n"
	@control_plane_ip=$$(jq -r '.control_plane_public_ips.value[0]' $(TF_OUTPUT_FILE)); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$control_plane_ip

# SSH into the first worker node
ssh-worker-node: terraform-output
	@printf "$(GREEN)SSH into the first worker node...$(NC)\n"
	@worker_ip=$$(jq -r '.worker_public_ips.value[0]' $(TF_OUTPUT_FILE)); \
	ssh -i ~/.ssh/id_rsa ubuntu@$$worker_ip

clean-pods:
	@kubectl delete pods --all -n default

pod-cilium:
	@kubectl exec -it -n kube-system $(kubectl get pods -n kube-system -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}') -- bash

pod-traefik:
	kubectl exec -it -n traefik $(kubectl get pods -n traefik -l app=traefik -o jsonpath='{.items[0].metadata.name}') -- bash

curl-pod:
	@printf "$(GREEN)Deleting any existing curl-pod....$(NC)\n"
	-kubectl delete pod curl-pod --ignore-not-found=true
	@printf "$(GREEN)Creating new curl-pod...$(NC)\n"
	kubectl run curl-pod --image=debian --restart=Never --command -- sleep infinity
	kubectl wait --for=condition=Ready pod/curl-pod --timeout=60s
	sudo kubectl exec -it curl-pod -- bash -c "apt update && apt install -y curl dnsutils"
	kubectl exec -it curl-pod -- bash
	kubectl run -it --rm --image=busybox:1.28 dns-test --restart=Never -- bash
