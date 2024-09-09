resource "oci_core_instance" "k3s_control_plane" {
  count = var.control_plane_count

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = format("k3s-control-plane-%d", count.index)
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    nsg_ids          = var.network_groups
    private_ip       = length(var.private_ips) > 0 ? element(var.private_ips, count.index) : null
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_arm_image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }
}
