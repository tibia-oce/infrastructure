resource "oci_core_instance" "k3s_worker_x86" {
  for_each = { for idx in range(var.x86_instance_count) : idx => idx }

  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = format("k3s-worker-x86-%d", each.key)
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    nsg_ids          = var.network_groups
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_x86_image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }
}
