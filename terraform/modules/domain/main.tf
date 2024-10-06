# ====================================================================
# Cloudflare DNS Records for Application and Game Services
# This section defines DNS records for two services: a myaac application
# and a game server. The myaac application will use Cloudflare's proxy 
# (Layer 7), while the game server will resolve DNS directly (Layer 4).
# Both records are configured as 'A' records pointing to the Oracle
# Load Balancer's public IP address. 
# ====================================================================

resource "cloudflare_record" "root" {
  zone_id = var.cf_zone_id
  name    = var.domain
  content = var.lb_public_ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "myaac" {
  zone_id = var.cf_zone_id
  name    = "myaac.${var.domain}"
  content = var.lb_public_ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "status" {
  zone_id = var.cf_zone_id
  name    = "status.${var.domain}"
  content = var.lb_public_ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "phpmyadmin" {
  zone_id = var.cf_zone_id
  name    = "phpmyadmin.${var.domain}"
  content = var.lb_public_ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "game" {
  zone_id  = var.cf_zone_id
  name     = "game.${var.domain}"
  content  = var.lb_public_ip_address
  type     = "A"
  ttl      = 3600
  proxied  = false
}

# TODO: Instead of landing page, just re-direct to Github for now
resource "cloudflare_page_rule" "redirect_root_to_github" {
  zone_id  = var.cf_zone_id
  target   = "https://${var.domain}/*"
  priority = 1

  actions {
    forwarding_url {
      url         = "https://github.com/tibia-oce"
      status_code = 301
    }
  }
}
