resource "hcloud_server" "control_plane" {
  for_each = { for i in range(1, var.control_plane_server_count) : "#${i}" => i }
  name     = "${var.cluster_name}-control-plane-${each.value}"

  image       = data.hcloud_image.ubuntu.name
  server_type = var.control_plane_server_type
  location    = element(var.server_locations, each.value)

  ssh_keys = var.ssh_keys
  labels = merge({
    node_type = "control-plane"
  }, local.common_labels)

  # Join cluster as server after first boot
  user_data = format("%s\n%s", "#cloud-config", yamlencode(
    {
      runcmd = [
        "curl -sfL https://get.k3s.io | K3S_TOKEN='${random_password.k3s_cluster_secret.result}' INSTALL_K3S_VERSION='${var.k3s_version}' sh -s - server --server 'https://${local.first_control_plane_ip}:6443' ${local.k3s_setup_args}"
      ]
      packages = concat(local.server_base_packages, var.server_additional_packages)
    }
  ))

  network {
    network_id = local.network_id
    ip         = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, each.value + 1)
  }

  provisioner "remote-exec" {
    inline = [
      "until systemctl is-active --quiet k3s.service; do sleep 1; done",
      "until kubectl get node ${self.name}; do sleep 1; done",
      # Disable workloads on master node
      "kubectl taint node ${self.name} node-role.kubernetes.io/master=true:NoSchedule",
      "kubectl taint node ${self.name} CriticalAddonsOnly=true:NoExecute",
    ]

    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
    }
  }

  depends_on = [
    hcloud_server.first_control_plane
  ]
}

resource "hcloud_server_network" "control_plane" {
  for_each  = { for i in range(1, var.control_plane_server_count) : "#${i}" => i } // starts at 1 because master was 0
  subnet_id = hcloud_network_subnet.k3s_nodes.id
  server_id = hcloud_server.control_plane[each.key].id
  ip        = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, each.value + 1)
}
