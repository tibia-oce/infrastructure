resource "oci_core_instance" "k3s_worker_arm" {
  count = var.arm_instance_count

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = format("k3s-worker-arm-%d", count.index)
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    private_ip = length(var.private_ips) > 0 ? element(var.private_ips, count.index) : null
    nsg_ids          = var.network_groups
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_arm_image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }
}
