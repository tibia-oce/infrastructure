export $(grep -v '^#' .env | tr -d '\r' | xargs) && terraform plan

TF_LOG=DEBUG OCI_GO_SDK_DEBUG=v terraform apply

ssh -i "~/.ssh/id_rsa" ubuntu@<control-plane-ip>

scp -i "~/.ssh/id_rsa" ubuntu@<control-plane-ip>:/home/ubuntu/kubeconfig ~/.kube/config

curl -k https://<load-balancer-ip>:6443