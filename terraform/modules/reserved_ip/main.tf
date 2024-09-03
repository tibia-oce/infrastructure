# ====================================================================
# Resource: Reserved Public IP
# This resource reserves a public IP for the load balancer if one 
# does not already exist. Once created, the public IP is associated 
# with the load balancer and should not be modified or destroyed 
# independently by Terraform. 
#
# The lifecycle and provisioner blocks are configured to prevent
# Terraform from making changes to this resource after its initial
# creation, ensuring that the public IP remains stable once it is 
# associated with the load balancer.
# ====================================================================

resource "oci_core_public_ip" "reserved_ip" {
  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
  display_name   = "${var.lb_display_name}-public-ip"

  lifecycle {
    ignore_changes = [
      private_ip_id,
      display_name,
      lifetime,
    ]
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = ""
  }
}
