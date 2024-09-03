output "kubeapi_nsg_id" {
  value       = module.kubeapi_nsg.nsg_kubeapi_id
  description = "The ID of the KubeAPI NSG."
}

output "ssh_nsg_id" {
  value       = module.ssh_nsg.nsg_ssh_id
  description = "The ID of the SSH NSG."
}

output "public_web_nsg_id" {
  value       = module.public_web_nsg.nsg_public_web_id
  description = "The ID of the Public Web NSG."
}

output "game_service_nsg_id" {
  value       = module.game_service_nsg.nsg_game_service_id
  description = "The ID of the Game Service NSG."
}

output "admin_nsg_id" {
  value       = module.admin_nsg.nsg_admin_id
  description = "The ID of the Admin NSG."
}
