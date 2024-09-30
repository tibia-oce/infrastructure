# Constants for formatting/prints
LINE := "----------------------------------------"
YELLOW=\033[33m
GREEN=\033[32m
BLUE=\033[34m
RED=\033[31m
NC=\033[0m

# Define environment variables for directories
export TF_DIR="terraform"
export SCRIPTS_DIR="scripts"
export ANSIBLE_DIR="ansible"
export VENV_DIR=".venv"
export TF_OUTPUT_FILE="$(TF_DIR)/terraform_output.json"
export ANSIBLE_INVENTORY_DIR="ansible/inventory"
export ANSIBLE_INVENTORY_FILE="$(ANSIBLE_INVENTORY_DIR)/hosts.ini"
export ANSIBLE_PRIVATE_KEY_PATH="~/.ssh/id_rsa"

# Generate a hidden tfvars file with OCI credentials from the Terraform agent
tfvars:
	@printf "$(GREEN)Generating tfvars file with OCI credentials...$(NC)\n"
	cd $(SCRIPTS_DIR) && ./vars.sh

# Generate provider configuration with OCI credentials from the Terraform agent
provider:
	@printf "$(GREEN)Generating provider configuration...$(NC)\n"
	cd $(SCRIPTS_DIR) && ./provider.sh

check_tf_requirements:
	@if [ ! -f "$(TF_DIR)/provider.tf" ]; then \
		printf "$(RED)Error: provider.tf not found. Please run 'make provider'.$(NC)\n"; \
		exit 1; \
	fi
	@if [ ! -f "$(TF_DIR)/terraform.tfvars" ]; then \
		printf "$(RED)Error: terraform.tfvars not found. Please run 'make tfvars'.$(NC)\n"; \
		exit 1; \
	fi
	@printf "$(GREEN)Both provider.tf and terraform.tfvars exist. Proceeding...$(NC)\n"
	
# Initialize Terraform for the K3S environment
oci-init: check_tf_requirements
	@printf "$(GREEN)Initializing Terraform in $(TF_DIR)...$(NC)\n"
	cd $(TF_DIR) && terraform init

# Generate and display a Terraform execution plan for the K3S environment
oci-plan: check_tf_requirements
	@printf "$(YELLOW)Generating Terraform plan in $(TF_DIR)...$(NC)\n"
	cd $(TF_DIR) && terraform plan

# Sync state with HCP remote backend
oci-refresh: check_tf_requirements
	@printf "$(GREEN)Refreshing Terraform state from remote HCP Terraform Cloud...$(NC)\n"
	cd $(TF_DIR) && terraform refresh

# Apply the Terraform plan to the K3S environment with auto-approval
oci-apply: check_tf_requirements
	@printf "$(GREEN)Applying Terraform plan in $(TF_DIR) with auto-approval...$(NC)\n"
	cd $(TF_DIR) && terraform apply -auto-approve

# Format the Terraform configuration files in the K3S environment
oci-fmt:
	@printf "$(BLUE)Formatting Terraform files in $(TF_DIR)...$(NC)\n"
	cd $(TF_DIR) && terraform fmt

# Destroy the Terraform-managed infrastructure in the K3S environment with auto-approval
oci-destroy: check_tf_requirements
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
	@echo "apiserver_endpoint=$$(jq -r '.control_plane_public_ips.value[]' $(TF_OUTPUT_FILE))" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "k3s_token=$$(jq -r '.k3s_token.value' $(TF_OUTPUT_FILE))" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "ansible_ssh_private_key_file=${ANSIBLE_PRIVATE_KEY_PATH}" >> $(ANSIBLE_INVENTORY_FILE)

	@echo "myaac_domain=$$(jq -r '.myaac_domain.value' $(TF_OUTPUT_FILE))" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "status_domain=$$(jq -r '.status_domain.value' $(TF_OUTPUT_FILE))" >> $(ANSIBLE_INVENTORY_FILE)
	@echo "game_domain=$$(jq -r '.game_domain.value' $(TF_OUTPUT_FILE))" >> $(ANSIBLE_INVENTORY_FILE)

# Set up Python virtual environment and install Ansible
setup-env:
	@printf "$(GREEN)Setting up Python virtual environment and installing Ansible...$(NC)\n"
	cd ansible/ && python3 -m venv $(VENV_DIR)
	. ansible/$(VENV_DIR)/bin/activate && pip install --upgrade pip && pip install -q -r ansible/requirements.txt
	. ansible/$(VENV_DIR)/bin/activate && ansible-galaxy install -r ansible/collections/requirements.yml

# Sequentially run all necessary steps to bootstrap the K3s cluster
# todo: configure vault injector or similar to pass the keys for ssl termination
bootstrap-cluster: terraform-output generate-inventory setup-env
	@printf "$(GREEN)Bootstrapping the K3s cluster...$(NC)\n"
	cd ansible && . $(VENV_DIR)/bin/activate && ansible-playbook ./site.yml -i ./inventory/hosts.ini --private-key ~/.ssh/id_rsa -e 'ansible_remote_tmp=/tmp/.ansible/tmp'
	@mkdir -p ~/.kube
	cp ./ansible/kubeconfig ~/.kube/config
	@printf "$(GREEN)Deploying base services and configs..$(NC)\n"
	@sleep 10

status:
	@printf "\n$(LINE)\n$(GREEN)Nodes...$(NC)\n$(LINE)\n"
	@kubectl get nodes
	@printf "\n$(LINE)\n$(GREEN)Pods...$(NC)\n$(LINE)\n"
	@kubectl get pods --all-namespaces
	@printf "\n$(LINE)\n$(GREEN)Services...$(NC)\n$(LINE)\n"
	kubectl get svc --all-namespaces
	@printf "\n"

base:
	@printf "$(GREEN)Deploying base services and configs..$(NC)\n"
	@kubectl apply -k kubernetes/apps/gatus

# @kubectl create deployment nginx --image=nginx            
# @kubectl expose deployment nginx --port=80 --type=ClusterIP
# @kubectl apply -k kubernetes/base/

# @printf "$(GREEN)Waiting for containers to come online...$(NC)\n"
# @kubectl wait --for=condition=Ready pod -l app=traefik -n kube-system --timeout=30s || \
# (printf "$(RED)Timeout: Traefik pods not ready in time!$(NC)\n" && exit 1)
# @printf "\n"
# @printf "\n$(LINE)\n$(GREEN)Traefik services$(NC)\n$(LINE)\n"
# @kubectl get svc -n kube-system | awk '{if(NR==1) print "\033[1;32m" $$0 "\033[0m"; else print $$0}'
# @printf "\n$(LINE)\n$(GREEN)Namespace pods$(NC)\n$(LINE)\n"
# @kubectl get pods --all-namespaces | awk '{if(NR==1) print "\033[1;32m" $$0 "\033[0m"; else print $$0}'
# @printf "\n$(LINE)\n"

traefik:
	@printf "$(GREEN)Deploying Traefik Services...$(NC)\n"
	@kubectl apply -k kubernetes/base/
	make traefik-logs
	
apps:
	@printf "$(GREEN)Deploying app manifests and checking pod status...$(NC)\n"
	@kubectl apply -k kubernetes/apps/
	@printf "\n$(LINE)\n$(GREEN)Node status...$(NC)\n$(LINE)\n"
	@kubectl get nodes
	@printf "\n$(LINE)\n$(GREEN)Pod status...$(NC)\n$(LINE)\n"
	@kubectl get pods --all-namespaces
	@printf "\n"

traefik-logs:
	@printf "\n$(LINE)\n$(GREEN)Secrets...$(NC)\n$(LINE)\n"
	$(call kubectl_get,secret)

	$(call kubectl_logs,traefik)
	@printf "\n"

	@printf "\n$(LINE)\n$(GREEN)Services...$(NC)\n$(LINE)\n"
	$(call kubectl_get,svc traefik)
	@printf "\n"
	@printf "\n$(LINE)\n$(GREEN)Service definition...$(NC)\n$(LINE)\n"
	kubectl get svc -n kube-system traefik -o yaml
	@printf "\n"

	@printf "\n$(LINE)\n$(GREEN)IngressRoutes...$(NC)\n$(LINE)\n"
	kubectl get ingressroute -A
	@printf "\n"

# @printf "\n$(LINE)\n$(GREEN)Service Account...$(NC)\n$(LINE)\n"
# $(call kubectl_get,serviceaccount traefik-ingress-controller)

# @printf "\n$(LINE)\n$(GREEN)ClusterRoleBinding...$(NC)\n$(LINE)\n"
# kubectl describe clusterrolebinding traefik-ingress-controller
# @printf "\n"


# @printf "\n$(LINE)\n$(GREEN)Cluster role...$(NC)\n$(LINE)\n"
# kubectl describe clusterrole traefik-ingress-controller
# @printf "\n"

	@make pod-traefik
	@printf "\n"


define kubectl_get
	@printf "> kubectl get $1 -n kube-system\n"
	@kubectl get $1 -n kube-system
	@printf "\n"
endef

define kubectl_logs
	@printf "\n$(LINE)\n$(GREEN)$1 logs...$(NC)\n> kubectl logs -n kube-system deployment/$1\n$(LINE)\n"
	@kubectl logs -n kube-system deployment/$1 | grep -v 'reflector.go'
endef

restart-traefik:
	kubectl delete deployment traefik -n kube-system --ignore-not-found
	kubectl delete svc traefik -n kube-system --ignore-not-found
	kubectl delete ingressroute traefik-dashboard-http -n kube-system --ignore-not-found
	kubectl delete ingressroute traefik-dashboard-https -n kube-system --ignore-not-found
	kubectl delete secret cloudflare-tls -n kube-system --ignore-not-found
	kubectl delete crd ingressroutes.traefik.io --ignore-not-found
	kubectl delete crd middleware.traefik.io --ignore-not-found
	kubectl delete crd tlsoptions.traefik.io --ignore-not-found
	kubectl delete crd tlsstores.traefik.io --ignore-not-found
	kubectl delete crd traefikservices.traefik.io --ignore-not-found
	make base
	kubectl logs -n kube-system deployment/traefik | grep -v 'reflector.go'

port-gatus:
	@GATUS_POD=$$(kubectl get pods -n kube-system -l app=gatus -o jsonpath='{.items[0].metadata.name}'); \
	echo "Port-forwarding pod: $$GATUS_POD"; \
	kubectl port-forward -n kube-system $$GATUS_POD 9090:8080 & \
	sleep 2; \
	printf "\n$(LINE)\n$(GREEN)http://localhost:9090$(NC)\n$(LINE)\n\n"

port-traefik:
	@TRAFFIC_POD=$$(kubectl get pods -n kube-system -o jsonpath='{.items[0].metadata.name}'); \
	echo "Port-forwarding pod: $$TRAFFIC_POD"; \
	kubectl port-forward -n kube-system $$TRAFFIC_POD 8080:80 & \
	sleep 2; \
	printf "\n$(LINE)\n$(GREEN)http://localhost:8080/dashboard/$(NC)\n$(LINE)\n\n"

reset: terraform-output generate-inventory setup-env
	@printf "$(GREEN)Resetting cluster...$(NC)\n"
	cd ansible && . $(VENV_DIR)/bin/activate && ansible-playbook ./reset.yml -i ./inventory/hosts.ini --private-key ~/.ssh/id_rsa -e 'ansible_remote_tmp=/tmp/.ansible/tmp'
	cd ansible && rm -f kubeconfig

# Retrieve the Kubeconfig from the control plane node and set up kubectl
config-kube:
	@printf "$(GREEN)Copying kubeconfig from ansible to ~/.kube/config...$(NC)\n"
	@cp ./ansible/kubeconfig ~/.kube/config
	@printf "$(GREEN)Kubeconfig copied successfully!$(NC)\n"

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
	# cilium connectivity test

clean-pods:
	@kubectl delete pods --all -n default

pod-cilium:
	@kubectl exec -it -n kube-system $(kubectl get pods -n kube-system -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}') -- bash
	# kubectl exec -n kube-system $$POD_NAME -- sh -c 'cat /etc/ssl/certs/kube-root-ca.crt'

pod-traefik:
	@printf "\n$(LINE)\n$(GREEN)Traefik pod mounts and kubeapi connection test...$(NC)\n$(LINE)\n"
	@POD_NAME=$$(kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}') && \
	printf "$(YELLOW)> kubectl exec -n kube-system $$POD_NAME -- sh -c 'cat /etc/ssl/certs/kube-root-ca.crt'$(NC)\n" && \
	kubectl exec -n kube-system $$POD_NAME -- sh -c 'cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt' && \
	printf "\n$(YELLOW)> kubectl exec -n kube-system $$POD_NAME -- sh -c 'cat /var/run/secrets/kubernetes.io/serviceaccount/token'$(NC)\n" && \
	kubectl exec -n kube-system $$POD_NAME -- sh -c 'cat /var/run/secrets/kubernetes.io/serviceaccount/token' && \
	printf "\n\n$(YELLOW)> $$POD_NAME | wget --header=\"Authorization: Bearer \$${TOKEN}\" --no-check-certificate https://10.43.0.1:443/version -O -\n$(NC)" && \
	kubectl exec -n kube-system $$POD_NAME -- sh -c "TOKEN=\$$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) && \
	( command -v wget > /dev/null || apk add --no-cache wget > /dev/null 2>&1 ) && \
	wget --header=\"Authorization: Bearer \$${TOKEN}\" --no-check-certificate https://10.43.0.1:443/version -O -" && \
	printf "\n$(YELLOW)> $$POD_NAME | nslookup kubernetes.default.svc.cluster.local\n$(NC)" && \
	kubectl exec -n kube-system $$POD_NAME -- nslookup kubernetes.default.svc.cluster.local

curl-pod:
	@kubectl delete pod alpine --ignore-not-found
	@kubectl run -it --rm --restart=Never alpine --image=alpine -- /bin/sh -c "\
		apk add --no-cache curl bind-tools && /bin/sh"

coredns-logs:
	@printf "$(YELLOW)List of Kubernetes endpoints...$(NC)\n"
	@kubectl get endpoints kubernetes -o yaml

	@printf "\n$(YELLOW)Checking CoreDNS logs for network connectivity issues...$(NC)\n"
	@POD_NAME=$$(kubectl get pods -n kube-system -l k8s-app=kube-dns -o jsonpath='{.items[0].metadata.name}') && \
	kubectl logs -n kube-system $$POD_NAME

	@printf "\n$(YELLOW)Checking network connectivity to the API server from a busybox pod...$(NC)\n"
	# @kubectl run -it --rm debug --image=busybox --restart=Never -- sh -c '\
	# 	ping -c 3 10.43.0.1 && \
	# 	nc -vz 10.43.0.1 443'
	@printf "\n"

metrics-server-logs:
	@kubectl logs -n kube-system $$(kubectl get pods -n kube-system -l k8s-app=metrics-server -o jsonpath='{.items[0].metadata.name}')

# kubectl port-forward -n kube-system pod/$(kubectl get pods -n kube-system -l app=traefik -o jsonpath="{.items[0].metadata.name}") 9000:8080


# kubectl logs -n kube-system deployment/traefik --since=2m

# curl -H "Host: status.mythbound.dev" http://140.238.193.212