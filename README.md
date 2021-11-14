# k-andy

<img align="left" height="250" src="logo.svg"/>

### Zero friction Kubernetes stack on Hetzner Cloud

This [terraform](https://www.terraform.io/) module will install a High
Availability [K3s](https://k3s.io/) Cluster with Embedded DB in a private
network on [Hetzner Cloud](https://www.hetzner.com/de/cloud). The following
resources are provisionised by default (**20€/mo**):

- 3x Control-plane: _CX11_, 2GB RAM, 1VCPU, 20GB NVMe, 20TB Traffic.
- 2x Worker: _CX21_, 4GB RAM, 2VCPU, 40GB NVMe, 20TB Traffic.
- Network: Private network with one subnet.
- Server and agent nodes are distributed across 3 Datacenters (nbg1, fsn1, hel1)
  for high availability.

</br>
</br>

**Hetzner Cloud integration**:

- Preinstalled [CSI-driver](https://github.com/hetznercloud/csi-driver) for
  volume support.
- Preinstalled
  [Cloud Controller Manager for Hetzner Cloud](https://github.com/hetznercloud/hcloud-cloud-controller-manager)
  for Load Balancer support.

**Auto-K3s-Upgrades**

Enable the upgrade-controller (`enable_upgrade_controller = true`) and specify
your target k3s version (`upgrade_k3s_target_version`). See
[here](https://github.com/k3s-io/k3s/releases) for possible versions.

Label the nodes you want to upgrade, e.g.
`kubectl label nodes core-control-plane-1 k3s-upgrade=true`. The concurrency of
the upgrade plan is set to 1, so you can also label them all at once. Agent
nodes will be drained one by one during the upgrade.

You can label all control-plane nodes by using
`kubectl label nodes -l node-role.kubernetes.io/control-plane=true k3s-upgrade=true`.
All agent nodes can be labelled using
`kubectl label nodes -l node-role.kubernetes.io/control-plane=true k3s-upgrade!=true`.

To remove the label from all nodes you can run
`kubectl label nodes --all k3s-upgrade-`.

After a successful update you can also remove the upgrade controller and the
plans again, setting `enable_upgrade_controller` to `false`.

**What is K3s?**

K3s is a lightweight certified kubernetes distribution. It's packaged as single
binary and comes with solid defaults for storage and networking but we replaced
[local-path-provisioner](https://github.com/rancher/local-path-provisioner) with
hetzner [CSI-driver](https://github.com/hetznercloud/csi-driver) and
[klipper load-balancer](https://github.com/k3s-io/klipper-lb) with hetzner
[Cloud Controller Manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager).
The default ingress controller (traefik) has been disabled.

## Usage

See a more detailed example with walk-through in the
[example folder](./example).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

### Inputs

| Name                                                                                                                                          | Description                                                                                                                                  | Type                                                                                                                  | Default                                                                                                            | Required |
| --------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ | :------: |
| <a name="input_agent_groups"></a> [agent\_groups](#input_agent_groups)                                                                        | Configuration of agent groups                                                                                                                | <pre>map(object({<br> type = string<br> count = number<br> ip_offset = number<br> taints = list(string)<br> }))</pre> | <pre>{<br> "default": {<br> "count": 2,<br> "ip_offset": 33,<br> "taints": [],<br> "type": "cx21"<br> }<br>}</pre> |    no    |
| <a name="input_cluster_cidr"></a> [cluster\_cidr](#input_cluster_cidr)                                                                        | Network CIDR to use for pod IPs                                                                                                              | `string`                                                                                                              | `"10.42.0.0/16"`                                                                                                   |    no    |
| <a name="input_control_plane_server_count"></a> [control\_plane\_server\_count](#input_control_plane_server_count)                            | Number of control plane nodes                                                                                                                | `number`                                                                                                              | `3`                                                                                                                |    no    |
| <a name="input_control_plane_server_type"></a> [control\_plane\_server\_type](#input_control_plane_server_type)                               | Server type of control plane servers                                                                                                         | `string`                                                                                                              | `"cx11"`                                                                                                           |    no    |
| <a name="input_create_kubeconfig"></a> [create\_kubeconfig](#input_create_kubeconfig)                                                         | Create a local kubeconfig file to connect to the cluster                                                                                     | `bool`                                                                                                                | `true`                                                                                                             |    no    |
| <a name="input_enable_upgrade_controller"></a> [enable\_upgrade\_controller](#input_enable_upgrade_controller)                                | Install the rancher system-upgrade-controller                                                                                                | `bool`                                                                                                                | `false`                                                                                                            |    no    |
| <a name="input_hcloud_csi_driver_version"></a> [hcloud\_csi\_driver\_version](#input_hcloud_csi_driver_version)                               | n/a                                                                                                                                          | `string`                                                                                                              | `"v1.6.0"`                                                                                                         |    no    |
| <a name="input_hcloud_token"></a> [hcloud\_token](#input_hcloud_token)                                                                        | Token to authenticate against Hetzner Cloud                                                                                                  | `any`                                                                                                                 | n/a                                                                                                                |   yes    |
| <a name="input_k3s_version"></a> [k3s\_version](#input_k3s_version)                                                                           | K3s version                                                                                                                                  | `string`                                                                                                              | `"v1.21.3+k3s1"`                                                                                                   |    no    |
| <a name="input_kubeconfig_filename"></a> [kubeconfig\_filename](#input_kubeconfig_filename)                                                   | Specify the filename of the created kubeconfig file (defaults to kubeconfig-${var.name}.yaml                                                 | `any`                                                                                                                 | `null`                                                                                                             |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                                                 | Cluster name (used in various places, don't use special chars)                                                                               | `any`                                                                                                                 | n/a                                                                                                                |   yes    |
| <a name="input_network_cidr"></a> [network\_cidr](#input_network_cidr)                                                                        | Network in which the cluster will be placed. Ignored if network\_id is defined                                                               | `string`                                                                                                              | `"10.0.0.0/16"`                                                                                                    |    no    |
| <a name="input_network_id"></a> [network\_id](#input_network_id)                                                                              | If specified, no new network will be created. Make sure cluster\_cidr and service\_cidr don't collide with anything in the existing network. | `any`                                                                                                                 | `null`                                                                                                             |    no    |
| <a name="input_server_additional_packages"></a> [server\_additional\_packages](#input_server_additional_packages)                             | Additional packages which will be installed on node creation                                                                                 | `list(string)`                                                                                                        | `[]`                                                                                                               |    no    |
| <a name="input_server_locations"></a> [server\_locations](#input_server_locations)                                                            | Server locations in which servers will be distributed                                                                                        | `list(string)`                                                                                                        | <pre>[<br> "nbg1",<br> "fsn1",<br> "hel1"<br>]</pre>                                                               |    no    |
| <a name="input_service_cidr"></a> [service\_cidr](#input_service_cidr)                                                                        | Network CIDR to use for services IPs                                                                                                         | `string`                                                                                                              | `"10.43.0.0/16"`                                                                                                   |    no    |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input_ssh_keys)                                                                                    | List of ssh key resource IDs that will be installed on the servers                                                                           | `list(string)`                                                                                                        | n/a                                                                                                                |   yes    |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input_subnet_cidr)                                                                           | Subnet in which all nodes are placed                                                                                                         | `string`                                                                                                              | `"10.0.1.0/24"`                                                                                                    |    no    |
| <a name="input_upgrade_controller_image_tag"></a> [upgrade\_controller\_image\_tag](#input_upgrade_controller_image_tag)                      | The image tag of the upgrade controller (See https://github.com/rancher/system-upgrade-controller/releases)                                  | `string`                                                                                                              | `"v0.8.0"`                                                                                                         |    no    |
| <a name="input_upgrade_k3s_target_version"></a> [upgrade\_k3s\_target\_version](#input_upgrade_k3s_target_version)                            | Target version of k3s (See https://github.com/k3s-io/k3s/releases)                                                                           | `string`                                                                                                              | `null`                                                                                                             |    no    |
| <a name="input_upgrade_node_additional_tolerations"></a> [upgrade\_node\_additional\_tolerations](#input_upgrade_node_additional_tolerations) | List of tolerations which upgrade jobs must have to run on every node (for control-plane and agents)                                         | `list(map(any))`                                                                                                      | `[]`                                                                                                               |    no    |

### Outputs

| Name                                                                                                              | Description                                             |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| <a name="output_agents_public_ips"></a> [agents\_public\_ips](#output_agents_public_ips)                          | The public IP addresses of the agent servers            |
| <a name="output_cidr_block"></a> [cidr\_block](#output_cidr_block)                                                | n/a                                                     |
| <a name="output_control_planes_public_ips"></a> [control\_planes\_public\_ips](#output_control_planes_public_ips) | The public IP addresses of the control plane servers    |
| <a name="output_k3s_token"></a> [k3s\_token](#output_k3s_token)                                                   | Secret k3s authentication token                         |
| <a name="output_kubeconfig"></a> [kubeconfig](#output_kubeconfig)                                                 | Structured kubeconfig data to supply to other providers |
| <a name="output_kubeconfig_file"></a> [kubeconfig\_file](#output_kubeconfig_file)                                 | Kubeconfig file content with external IP address        |
| <a name="output_network_id"></a> [network\_id](#output_network_id)                                                | n/a                                                     |
| <a name="output_server_locations"></a> [server\_locations](#output_server_locations)                              | Array of hetzner server locations we deploy to          |
| <a name="output_subnet_id"></a> [subnet\_id](#output_subnet_id)                                                   | n/a                                                     |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Common Operations

### Agent server replacement

If you need to cycle an agent, you can do that with a single node following this
procedure. Replace the group name and number with the server you want to
recreate!

Make sure you drain the nodes first.

```shell
terraform taint 'module.my_cluster.module.agent_group["GROUP_NAME"].random_pet.agent_suffix[1]'
terraform apply
```

This will recreate the agent in that group on next apply.

### Control Plane server replacement

Currently you should only replace the servers which didn't initialize the
cluster.

```shell
terraform taint 'module.my_cluster.hcloud_server.control_plane["#1"]'
terraform apply
```

## Auto-Upgrade

### Prerequisite

Install the system-upgrade-controller in your cluster.

```
KUBECONFIG=kubeconfig.yaml kubectl apply -f ./upgrade/controller.yaml
```

## Upgrade procedure

1. Mark the nodes you want to upgrade (The script will mark all nodes).

```
KUBECONFIG=kubeconfig.yaml kubectl label --all node k3s-upgrade=true
```

2. Run the plan for the **servers**.

```
KUBECONFIG=kubeconfig.yaml kubectl apply -f ./upgrade/server-plan.yaml
```

**Warning:** Wait for completion
[before you start upgrading your agents](https://github.com/k3s-io/k3s/issues/2996#issuecomment-788352375).

3. Run the plan for the **agents**.

```
KUBECONFIG=kubeconfig.yaml kubectl apply -f ./upgrade/agent-plan.yaml
```

## Backups

K3s will automatically backup your embedded etcd datastore every 12 hours to
`/var/lib/rancher/k3s/server/db/snapshots/`. You can reset the cluster by
pointing to a specific snapshot.

1. Stop the master server.

```sh
sudo systemctl stop k3s
```

2. Restore the master server with a snapshot

```sh
./k3s server \
  --cluster-reset \
  --cluster-reset-restore-path=<PATH-TO-SNAPSHOT>
```

**Warning:** This forget all peers and the server becomes the sole member of a
new cluster. You have to manually rejoin all servers.

3. Connect you with the different servers backup and delete
   `/var/lib/rancher/k3s/server/db` on each peer etcd server and rejoin the
   nodes.

```sh
sudo systemctl stop k3s
rm -rf /var/lib/rancher/k3s/server/db
sudo systemctl start k3s
```

This will rejoin the server with the master server and seed the etcd store.

**Info:** It exists no official tool to automate the procedure. In future,
rancher might provide an operator to handle this
([issue](https://github.com/k3s-io/k3s/issues/3174)).

## Debugging

Cloud init logs can be found on the remote machines in:

- `/var/log/cloud-init-output.log`
- `/var/log/cloud-init.log`
- `journalctl -u k3s.service -e` last logs of the server
- `journalctl -u k3s-agent.service -e` last logs of the agent

## Known issues

- Sometimes at cluster bootstrapping the Cloud-Controllers reports that some
  routes couldn't be created. This issue was fixed in master but wasn't released
  yet. Restart the cloud-controller pod and it will recreate them.

## Credits

- [terraform-hcloud-k3s](https://github.com/cicdteam/terraform-hcloud-k3s)
  Terraform module which creates a single node cluster.
- [terraform-module-k3](https://github.com/xunleii/terraform-module-k3s)
  Terraform module which creates a k3s cluster, with multi-server and management
  features.
- Icon created by [Freepik](https://www.freepik.com) from
  [www.flaticon.com](https://www.flaticon.com/de/)
