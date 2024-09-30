variable "cf_zone_id" {
  type        = string
  description = "The Cloudflare Zone ID that uniquely identifies the DNS zone (domain) being managed."
}

variable "domain" {
  type        = string
  description = "The domain name being managed in Cloudflare, such as example.com."
}

variable "lb_public_ip_address" {
  description = "The public IP address of the load balancer."
  type        = string
}