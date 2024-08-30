cd example

terraform init

export $(grep -v '^#' .env | tr -d '\r' | xargs) && terraform plan

TF_LOG=DEBUG OCI_GO_SDK_DEBUG=v terraform apply