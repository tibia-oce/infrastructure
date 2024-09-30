output "myaac_domain" {
  description = "The web application domain managed by Cloudflare"
  value       = cloudflare_record.myaac.hostname
}

output "game_domain" {
  description = "The game server domain managed by Cloudflare"
  value       = cloudflare_record.game.hostname
}

output "status_domain" {
  description = "The game server domain managed by Cloudflare"
  value       = cloudflare_record.status.hostname
}

output "argo_domain" {
  description = "The argo server domain managed by Cloudflare"
  value       = cloudflare_record.argo.hostname
}
