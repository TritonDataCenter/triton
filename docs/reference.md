# SmartDataCenter Reference

SmartDataCenter is a large and complex beast. Many of the components that make
up SDC (REST APIs, agents, the SmartOS platform, important libraries) have their
own reference documentation. This page links to those, with a brief description
of each. See also the [overview of SDC repositories](./repos.md).


## Services

By "Services" here, we mean SAPI services of type "vm". See [the *service*
section in the glossary](./glossary.md#service) for details.

| Name | Repo | Description |
| ---- | ---- | ----------- |
| [adminui](https://docs.joyent.com/sdc7/operations-portal-walkthrough) | [sdc-adminui](https://github.com/joyent/sdc-adminui) | SDC Operations Portal |
| [amon](https://github.com/joyent/sdc-amon/blob/master/docs/index.md) | [sdc-amon](https://github.com/joyent/sdc-amon) | SDC monitoring and alarming |
| amonredis | [sdc-amonredis](https://github.com/joyent/sdc-amonredis) | Internal infrastructure for the Amon service |
| [binder](https://github.com/joyent/binder/blob/master/docs/index.md) | [binder](https://github.com/joyent/binder) | SDC/Manta DNS server over Apache Zookeeper |
| [ca](https://github.com/joyent/sdc-cloud-analytics/blob/master/docs/index.md) | [sdc-cloud-analytics](https://github.com/joyent/sdc-cloud-analytics) | SDC internal API for gathering real-time metrics across the datacenter |
| [cloudapi](https://github.com/joyent/sdc-cloudapi/blob/master/docs/index.restdown) | [sdc-cloudapi](https://github.com/joyent/sdc-cloudapi) | SDC Public HTTP API |
| [cnapi](https://github.com/joyent/sdc-cnapi/blob/master/docs/index.md) | [sdc-cnapi](https://github.com/joyent/sdc-cnapi) | SDC compute node API |
| dhcpd | [sdc-booter](https://github.com/joyent/sdc-booter) | SDC Compute Node DHCP and TFTP server |
| [fwapi](https://github.com/joyent/sdc-fwapi/blob/master/docs/index.md) | [sdc-fwapi](https://github.com/joyent/sdc-fwapi) | SDC Firewall API |
| [imgapi](https://github.com/joyent/sdc-imgapi/blob/master/docs/index.md) | [sdc-imgapi](https://github.com/joyent/sdc-imgapi) | SDC Image API |
| [mahi](https://github.com/joyent/mahi/blob/master/docs/index.md) | [mahi](https://github.com/joyent/mahi) | Authentication cache |
| [manatee](https://github.com/joyent/manatee/blob/master/docs/user-guide.md) | [sdc-manatee](https://github.com/joyent/sdc-manatee) | Highly available postgres |
| [manta](https://github.com/joyent/sdc-manta/blob/master/docs/index.md) | [sdc-manta](https://github.com/joyent/sdc-manta) | SDC tools for deploying and managing a Manta |
| [moray](https://github.com/joyent/moray/blob/master/docs/index.md) | [moray](https://github.com/joyent/moray) | Highly-available key/value store |
| [napi](https://github.com/joyent/sdc-napi/blob/master/docs/index.md) | [sdc-napi](https://github.com/joyent/sdc-napi) | SDC Network API |
| [papi](https://github.com/joyent/sdc-papi/blob/master/docs/index.md) | [sdc-papi](https://github.com/joyent/sdc-papi) | SDC Package (aka instance types) API |
| rabbitmq | [sdc-rabbitmq](https://github.com/joyent/sdc-rabbitmq) | SDC internal RabbitMQ |
| redis | [sdc-redis](https://github.com/joyent/sdc-redis) | SDC internal redis |
| [sapi](https://github.com/joyent/sdc-sapi/blob/master/docs/index.md) | [sdc-sapi](https://github.com/joyent/sdc-sapi) | SDC Service API |
| [sdc](https://github.com/joyent/sdc-sdc/blob/master/docs/index.md) | [sdc-sdc](https://github.com/joyent/sdc-sdc) | SDC internal "sdc" zone with ops tooling |
| [ufds](https://github.com/joyent/sdc-ufds/blob/master/docs/index.md) | [sdc-ufds](https://github.com/joyent/sdc-ufds) | SDC LDAP directory service. It is used primarily for user management. The deprecated customer API (CAPI) runs in this zone. |
| [vmapi](https://github.com/joyent/sdc-vmapi/blob/master/docs/index.md) | [sdc-vmapi](https://github.com/joyent/sdc-vmapi) | SDC Virtual Machine API |
| [workflow](https://github.com/joyent/sdc-workflow/blob/master/docs/index.md) | [sdc-workflow](https://github.com/joyent/sdc-workflow) | SDC Workflow API and job runner service |

## Agents

By "Agents" here, we mean all SDC agents as described by the [*agent* section in
the glossary](./glossary.md#agent). The "Where" column of this table indicates
where an instance of this agent is typically running: "vm" means in SDC core
VMs, "gz" means in the global zone of SDC servers (both the headnode and
compute nodes).


| Name | Repo | Where | Description |
| ---- | ---- | ----- | ----------- |
| [amon-agent](https://github.com/joyent/sdc-amon/blob/master/docs/index.md) | [sdc-amon](https://github.com/joyent/sdc-amon) | vm, gz | Agent for Amon system, responsible for probe checking |
| [amon-relay](https://github.com/joyent/sdc-amon/blob/master/docs/index.md) | [sdc-amon](https://github.com/joyent/sdc-amon) | gz | Relay for Amon system, go-between for Amon agents and the central master |
| [cainstsvc](https://github.com/joyent/sdc-cloud-analytics/blob/master/docs/index.md) | [sdc-cloud-analytics](https://github.com/joyent/sdc-cloud-analytics) | gz | Agent for cloud-analytics system, responsible for gathering CA data on-demand |
| config-agent | [sdc-config-agent](https://github.com/joyent/sdc-config-agent) | vm, gz | SDC config file writer |
| [firewaller](https://github.com/joyent/sdc-fwapi/blob/master/docs/index.md) | [sdc-firewaller-agent](https://github.com/joyent/sdc-firewaller-agent) | gz | Syncs firewall rules and associated VM data from FWAPI and VMAPI. |
| [hagfish-watcher](https://github.com/joyent/sdc-hagfish-watcher/blob/master/docs/index.md) | [sdc-hagfish-watcher](https://github.com/joyent/sdc-hagfish-watcher) | gz | Records telemetry about customer workloads for usage monitoring and billing purposes. |
| heartbeater | [sdc-heartbeater-agent](https://github.com/joyent/sdc-heartbeater-agent) | gz | Heartbeats CN and VM status to CNAPI and VMAPI. |
| net-agent | [sdc-net-agent](https://github.com/joyent/sdc-net-agent) | gz | Next generation agent for updating NAPI with CN network data. |
| [provisioner](https://github.com/joyent/sdc-provisioner-agent/blob/master/docs/index.md) | [sdc-provisioner-agent](https://github.com/joyent/sdc-provisioner-agent) | gz | CNAPI agent for managing VMs on a CN (provisioning, rebooting, etc.). |
| [registrar](https://github.com/joyent/registrar/blob/master/docs/index.md) | [registrar](https://github.com/joyent/registrar) | vm | Registers the local host with *binder* for SDC internal DNS. |
| smartlogin | [sdc-smart-login](https://github.com/joyent/sdc-smart-login) | gz | The set of components that enable SSHd on VMs to resolve public keys in UFDS. |
| vm-agent | [sdc-vm-agent](https://github.com/joyent/sdc-vm-agent) | gz | Next generation agent for updating VMAPI with VM data from a CN. |
| ur | [sdc-ur-agent](https://github.com/joyent/sdc-ur-agent) | gz | SDC compute node bootstrapping agent |


## Important Libraries

| Name | Description |
| ---- | ----------- |
| [sdc-designation](https://github.com/joyent/sdc-designation/blob/master/docs/index.restdown) | A package to select a compute node for VM instance provisioning. The Designation API (DAPI) is used by CNAPI. |
