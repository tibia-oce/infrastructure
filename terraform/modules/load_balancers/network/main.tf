# ====================================================================
# Resource: Network Load Balancer
# This resource defines a basic Network Load Balancer in OCI.
# ====================================================================

resource "oci_network_load_balancer_network_load_balancer" "nlb" {
  compartment_id = var.compartment_ocid
  display_name   = var.display_name
  subnet_id      = var.subnet_id
  is_private     = var.is_private
}
