output "web_domain" {
  description = "The web application domain managed by Cloudflare"
  value       = cloudflare_record.web.hostname
}

output "game_domain" {
  description = "The game server domain managed by Cloudflare"
  value       = cloudflare_record.game.hostname
}
