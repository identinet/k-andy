output "control_planes_public_ips" {
  value       = concat([hcloud_server.first_control_plane.ipv4_address], [for server in hcloud_server.control_plane : server.ipv4_address])
  description = "The public IP addresses of the control plane servers"
}

output "agents_public_ips" {
  value       = flatten([for agents in module.agent_group : agents.public_ips])
  description = "The public IP addresses of the agent servers"
}

output "k3s_token" {
  description = "Secret k3s authentication token"
  value       = random_password.k3s_cluster_secret.result
  sensitive   = true
}

output "network_id" {
  value = local.network_id
}

output "subnet_id" {
  value = hcloud_network_subnet.k3s_nodes.id
}

output "cidr_block" {
  value = hcloud_network_subnet.k3s_nodes.ip_range
}

output "server_locations" {
  description = "Array of hetzner server locations we deploy to"
  value       = var.server_locations
}
