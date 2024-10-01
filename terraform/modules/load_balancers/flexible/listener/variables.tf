variable "load_balancer_id" {
  type = string
}

variable "listener_name" {
  type = string
}

variable "listener_protocol" {
  type = string
}

variable "listener_port" {
  type = number
}

variable "ssl_configuration_enabled" {
  type    = bool
  default = false
}

variable "certificate_name" {
  type    = string
  default = ""
}

variable "default_backend_set_name" {
  type    = string
}

variable "ssl_has_session_resumption" {
  type    = bool
  default = false
}

variable "ssl_certificate_ids" {
  type    = list(string)
  default = []
}

variable "ssl_cipher_suite_name" {
  type    = string
  default = ""
}

variable "ssl_protocols" {
  type    = list(string)
  default = []
}

variable "hostname_names" {
  type    = list(string)
  default = []
}

variable "ssl_server_order_preference" {
  type    = string
  default = ""
}

variable "ssl_trusted_certificate_authority_ids" {
  type    = list(string)
  default = []
}

variable "ssl_verify_depth" {
  type    = number
  default = 0
}

variable "ssl_verify_peer_certificate" {
  type    = bool
  default = false
}

# variable "hostname_backend_map" {
#   type = map(string)
# }