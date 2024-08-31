resource "oci_core_instance" "k3s_control_plane" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "k3s-control-plane"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k3s_subnet.id
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.lb_to_instances_kubeapi.id]
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_arm_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = data.hcp_vault_secrets_secret.ssh_public_key.secret_value
    user_data = base64encode(templatefile("${path.module}/control-plane-init.tftpl", {
      load_balancer_public_ip = oci_core_public_ip.reserved_ip.ip_address
    }))
  }
}

resource "oci_core_instance" "k3s_worker_arm" {
  for_each = { for idx in range(var.arm_instance_count) : idx => idx }

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = format("k3s-worker-arm-%d", each.key)
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.k3s_subnet.id
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.lb_to_instances_http.id]
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_arm_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = data.hcp_vault_secrets_secret.ssh_public_key.secret_value
    user_data = base64encode(templatefile("${path.module}/worker-init.tftpl", {
      ssh_private_key  = data.hcp_vault_secrets_secret.ssh_private_key.secret_value,
      control_plane_ip = oci_core_instance.k3s_control_plane.private_ip
    }))
  }

  depends_on = [oci_core_instance.k3s_control_plane]
}

resource "oci_core_instance" "k3s_worker_x86" {
  for_each = { for idx in range(var.x86_instance_count) : idx => idx }

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = format("k3s-worker-x86-%d", each.key)
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.k3s_subnet.id
    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.lb_to_instances_http.id]
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_x86_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = data.hcp_vault_secrets_secret.ssh_public_key.secret_value
    user_data = base64encode(templatefile("${path.module}/worker-init.tftpl", {
      ssh_private_key  = data.hcp_vault_secrets_secret.ssh_private_key.secret_value,
      control_plane_ip = oci_core_instance.k3s_control_plane.private_ip
    }))
  }

  depends_on = [oci_core_instance.k3s_control_plane]
}
