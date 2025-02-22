# Hetzner Cloud

variable "hcloud_token" {
  description = "Token to authenticate against Hetzner Cloud"
}

# Cluster Configuration

variable "cluster_name" {
  description = "Cluster name (used in various places, don't use special chars)"
}

variable "create_kubeconfig" {
  description = "Create a local kubeconfig file to connect to the cluster"
  default     = true
}

variable "kubeconfig_filename" {
  description = "Specify the filename of the created kubeconfig file (defaults to kubeconfig-$${var.cluster_name}.yaml"
  default     = null
}

## Network

variable "network_cidr" {
  description = "Network in which the cluster will be placed. Ignored if network_id is defined"
  default     = "10.0.0.0/16"
}

variable "cluster_cidr" {
  description = "Network CIDR to use for pod IPs"
  default     = "10.42.0.0/16"
}

variable "service_cidr" {
  description = "Network CIDR to use for services IPs"
  default     = "10.43.0.0/16"
}

variable "network_id" {
  description = "If specified, no new network will be created. Make sure cluster_cidr and service_cidr don't collide with anything in the existing network."
  default     = null
}

variable "subnet_cidr" {
  description = "Subnet in which all nodes are placed"
  default     = "10.0.1.0/24"
}

## Servers

variable "control_plane_server_count" {
  description = "Number of control plane nodes"
  default     = 3
}

variable "control_plane_server_type" {
  description = "Server type of control plane servers"
  default     = "cx11"
}

variable "server_locations" {
  description = "Server locations in which servers will be distributed"
  default     = ["nbg1", "fsn1", "hel1"]
  type        = list(string)
}

variable "agent_groups" {
  description = "Configuration of agent groups"
  default = {
    "default" = {
      type      = "cx21"
      count     = 2
      ip_offset = 33
      taints    = []
    }
  }
  type = map(object({
    type      = string
    count     = number
    ip_offset = number
    taints    = list(string)
  }))
}

## Server Configuration

variable "server_additional_packages" {
  description = "Additional packages which will be installed on node creation"
  default     = []
  type        = list(string)
}

## Server Access

variable "ssh_keys" {
  description = "List of public ssh_key ids"
  type        = list(string)
}

## Versions

variable "k3s_version" {
  description = "K3s version (See https://update.k3s.io/v1-release/channels)"
  default     = "v1.21.3+k3s1"
}

variable "hcloud_csi_driver_version" {
  default = "v1.6.0"
}

## Upgrade Controller

variable "enable_upgrade_controller" {
  description = "Install the rancher system-upgrade-controller"
  default     = false
}

variable "upgrade_controller_image_tag" {
  description = "The image tag of the upgrade controller (See https://github.com/rancher/system-upgrade-controller/releases)"
  default     = "v0.8.0"
}

variable "upgrade_k3s_target_version" {
  description = "Target version of k3s (See https://update.k3s.io/v1-release/channels)"
  type        = string
  default     = null
}

variable "upgrade_node_additional_tolerations" {
  description = "List of tolerations which upgrade jobs must have to run on every node (for control-plane and agents)"
  default     = []
  type        = list(map(any))
}

# Labels

locals {
  common_labels = {
    cluster     = var.cluster_name
    provisioner = "terraform",
    module      = "k-andy"
    engine      = "k3s",
  }
}
