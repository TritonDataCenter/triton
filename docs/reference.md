# Triton DataCenter Reference

Triton DataCenter is a large and complex beast. Many of the components that make
up Triton (REST APIs, agents, the SmartOS platform, important libraries) have
their own reference documentation. This page links to those, with a brief
description of each. See also the [overview of Triton repositories](./repos.md).


## Services

By "Services" here, we mean SAPI services of type "vm". See [the *service*
section in the glossary](./glossary.md#service) for details.

| Name | Repo | Description |
| ---- | ---- | ----------- |
| [adminui](https://docs.joyent.com/private-cloud/install/operations-setup) | [sdc-adminui](https://github.com/TritonDataCenter/sdc-adminui) | Triton Operations Portal |
| [amon](https://github.com/TritonDataCenter/sdc-amon/blob/master/docs/index.md) | [sdc-amon](https://github.com/TritonDataCenter/sdc-amon) | Triton monitoring and alarming |
| amonredis | [sdc-amonredis](https://github.com/TritonDataCenter/sdc-amonredis) | Internal infrastructure for the Amon service |
| binder | [binder](https://github.com/TritonDataCenter/binder) | Triton/Manta DNS server over Apache ZooKeeper |
| [ca](https://github.com/TritonDataCenter/sdc-cloud-analytics/blob/master/docs/index.md) | [sdc-cloud-analytics](https://github.com/TritonDataCenter/sdc-cloud-analytics) | Triton internal API for gathering real-time metrics across the datacenter |
| [cloudapi](https://github.com/TritonDataCenter/sdc-cloudapi/blob/master/docs/index.md) | [sdc-cloudapi](https://github.com/TritonDataCenter/sdc-cloudapi) | Triton Public HTTP API |
| [cnapi](https://github.com/TritonDataCenter/sdc-cnapi/blob/master/docs/README.md) | [sdc-cnapi](https://github.com/TritonDataCenter/sdc-cnapi) | Triton Compute Node API |
| [cmon](https://github.com/TritonDataCenter/triton-cmon/blob/master/docs) | [triton-cmon](https://github.com/TritonDataCenter/triton-cmon) | Triton Container Monitor |
| [cns](https://github.com/TritonDataCenter/triton-cns/blob/master/docs/index.md) | [triton-cns](https://github.com/TritonDataCenter/triton-cns) | Triton Container Naming Service |
| dhcpd | [sdc-booter](https://github.com/TritonDataCenter/sdc-booter) | Triton Compute Node DHCP and TFTP server |
| [docker](https://github.com/TritonDataCenter/sdc-docker/tree/master/docs/api) | [sdc-docker](https://github.com/TritonDataCenter/sdc-docker) | Triton Remote Docker API |
| [fwapi](https://github.com/TritonDataCenter/sdc-fwapi/blob/master/docs/index.md) | [sdc-fwapi](https://github.com/TritonDataCenter/sdc-fwapi) | Triton Firewall API |
| [imgapi](https://github.com/TritonDataCenter/sdc-imgapi/blob/master/docs/index.md) | [sdc-imgapi](https://github.com/TritonDataCenter/sdc-imgapi) | Triton Image API |
| [mahi](https://github.com/TritonDataCenter/mahi/blob/master/docs/index.md) | [mahi](https://github.com/TritonDataCenter/mahi) | Authentication cache |
| [manatee](https://github.com/TritonDataCenter/manatee/blob/master/docs/user-guide.md) | [sdc-manatee](https://github.com/TritonDataCenter/sdc-manatee) | Highly available Postgres |
| [manta](https://github.com/TritonDataCenter/sdc-manta/blob/master/docs/index.md) | [sdc-manta](https://github.com/TritonDataCenter/sdc-manta) | Triton tools for deploying and managing a Manta |
| [moray](https://github.com/TritonDataCenter/moray/blob/master/docs/index.md) | [moray](https://github.com/TritonDataCenter/moray) | Highly-available key/value store |
| [napi](https://github.com/TritonDataCenter/sdc-napi/blob/master/docs/index.md) | [sdc-napi](https://github.com/TritonDataCenter/sdc-napi) | Triton Network API |
| [papi](https://github.com/TritonDataCenter/sdc-papi/blob/master/docs/index.md) | [sdc-papi](https://github.com/TritonDataCenter/sdc-papi) | Triton Package (aka instance types) API |
| [portolan](https://github.com/TritonDataCenter/sdc-portolan/tree/master/docs) | [sdc-portolan](https://github.com/TritonDataCenter/sdc-portolan) | Triton VXLAN Directory |
| rabbitmq | [sdc-rabbitmq](https://github.com/TritonDataCenter/sdc-rabbitmq) | Triton internal RabbitMQ |
| [sapi](https://github.com/TritonDataCenter/sdc-sapi/blob/master/docs/index.md) | [sdc-sapi](https://github.com/TritonDataCenter/sdc-sapi) | Triton Service API |
| [sdc](https://github.com/TritonDataCenter/sdc-sdc/blob/master/docs/index.md) | [sdc-sdc](https://github.com/TritonDataCenter/sdc-sdc) | Triton internal "sdc" zone with ops tooling |
| [ufds](https://github.com/TritonDataCenter/sdc-ufds/blob/master/docs/index.md) | [sdc-ufds](https://github.com/TritonDataCenter/sdc-ufds) | Triton LDAP directory service. It is used primarily for user management. The deprecated customer API (CAPI) runs in this zone. |
| [vmapi](https://github.com/TritonDataCenter/sdc-vmapi/blob/master/docs/index.md) | [sdc-vmapi](https://github.com/TritonDataCenter/sdc-vmapi) | Triton Virtual Machine API |
| [volapi](https://github.com/TritonDataCenter/sdc-volapi/blob/master/docs/api/README.md) | [sdc-volapi](https://github.com/TritonDataCenter/sdc-volapi) | Triton Volumes API |
| [workflow](https://github.com/TritonDataCenter/sdc-workflow/blob/master/docs/index.md) | [sdc-workflow](https://github.com/TritonDataCenter/sdc-workflow) | Triton Workflow API and job runner service |

## Agents

By "Agents" here, we mean all Triton agents as described by the [*agent* section in
the glossary](./glossary.md#agent). The "Where" column of this table indicates
where an instance of this agent is typically running: "vm" means in Triton core
VMs, "gz" means in the global zone of Triton servers (both the headnode and
compute nodes).


| Name | Repo | Where | Description |
| ---- | ---- | ----- | ----------- |
| [amon-agent](https://github.com/TritonDataCenter/sdc-amon/blob/master/docs/index.md) | [sdc-amon](https://github.com/TritonDataCenter/sdc-amon) | vm, gz | Agent for Amon system, responsible for probe checking |
| [amon-relay](https://github.com/TritonDataCenter/sdc-amon/blob/master/docs/index.md) | [sdc-amon](https://github.com/TritonDataCenter/sdc-amon) | gz | Relay for Amon system, go-between for Amon agents and the central master |
| [cainstsvc](https://github.com/TritonDataCenter/sdc-cloud-analytics/blob/master/docs/index.md) | [sdc-cloud-analytics](https://github.com/TritonDataCenter/sdc-cloud-analytics) | gz | Agent for cloud-analytics system, responsible for gathering CA data on-demand |
| cmon-agent | [sdc-cn-agent](https://github.com/TritonDataCenter/triton-cmon-agent) | gz | Provides statistics to CMON for local containers |
| cn-agent | [sdc-cn-agent](https://github.com/TritonDataCenter/sdc-cn-agent) | gz | Monitors CN usage and executes tasks on CN |
| config-agent | [sdc-config-agent](https://github.com/TritonDataCenter/sdc-config-agent) | vm, gz | Triton configuration file writer |
| [firewaller](https://github.com/TritonDataCenter/sdc-fwapi/blob/master/docs/index.md) | [sdc-firewaller-agent](https://github.com/TritonDataCenter/sdc-firewaller-agent) | gz | Syncs firewall rules and associated VM data from FWAPI and VMAPI. |
| [hagfish-watcher](https://github.com/TritonDataCenter/sdc-hagfish-watcher/blob/master/docs/index.md) | [sdc-hagfish-watcher](https://github.com/TritonDataCenter/sdc-hagfish-watcher) | gz | Records telemetry about customer workloads for usage monitoring and billing purposes. |
| hermes-actor | [sdc-hermes](https://github.com/TritonDataCenter/sdc-hermes) | gz | Uploads Triton logs to Manta |
| net-agent | [sdc-net-agent](https://github.com/TritonDataCenter/sdc-net-agent) | gz | Next generation agent for updating NAPI with CN network data. |
| [registrar](https://github.com/TritonDataCenter/registrar/blob/master/README.md) | [registrar](https://github.com/TritonDataCenter/registrar) | vm | Registers the local host with *binder* for Triton internal DNS. |
| smartlogin | [sdc-smart-login](https://github.com/TritonDataCenter/sdc-smart-login) | gz | The set of components that enable SSHd on VMs to resolve public keys in UFDS. |
| varpd | [varpd](https://github.com/TritonDataCenter/illumos-joyent/tree/master/usr/src/cmd/varpd) | gz | Provides virtual ARP services for overlay networks by querying Portolan |
| vm-agent | [sdc-vm-agent](https://github.com/TritonDataCenter/sdc-vm-agent) | gz | Next generation agent for updating VMAPI with VM data from a CN. |
| ur | [sdc-ur-agent](https://github.com/TritonDataCenter/sdc-ur-agent) | gz | Triton Compute Node bootstrapping agent |


## Important Libraries

| Name | Description |
| ---- | ----------- |
| [sdc-designation](https://github.com/TritonDataCenter/sdc-designation/blob/master/docs/index.md) | A package to select a compute node for VM instance provisioning. The Designation API (DAPI) is used by CNAPI. |

## Important CLI tools

| Name | Description |
| ---- | ----------- |
| [sdcadm](https://github.com/TritonDataCenter/sdcadm) | A tool for managing and updating Triton installations |
