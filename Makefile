export TF_BACKEND_DIR="infra"
export K3S_ENV_DIR="infra"
export SCRIPTS_DIR="scripts"
export CONTROL_PLANE_IP=

# Retrieves the kube config via ssh from the control node
kube-config:
	mkdir -p ~/.kube
	scp -i "~/.ssh/id_rsa" ubuntu@$(CONTROL_PLANE_IP):/home/ubuntu/kubeconfig ~/.kube/config
	export KUBECONFIG=~/.kube/config
	kubectl get nodes

get-nodes:
	kubectl get nodes

# Retrieves the OCI credentials from your terraform agent and generates a hidden tf.vars
tfvars:
	cd $(SCRIPTS_DIR) && ./vars.sh

init-backend:
	cd $(TF_BACKEND_DIR) && terraform init

plan-backend:
	cd $(TF_BACKEND_DIR) && terraform plan

apply-backend:
	cd $(TF_BACKEND_DIR) && terraform apply -auto-approve

oci-init:
	cd $(K3S_ENV_DIR) &&  terraform init

oci-plan:
	cd $(K3S_ENV_DIR) &&  terraform plan

oci-apply:
	cd $(K3S_ENV_DIR) &&  terraform apply -auto-approve

oci-fmt:
	cd $(K3S_ENV_DIR) &&  terraform fmt

oci-destroy:
	cd $(K3S_ENV_DIR) &&  terraform destroy

