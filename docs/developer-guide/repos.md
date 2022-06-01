# Triton DataCenter repos

This page holds an overview of the source repositories that make up
Triton DataCenter. See also [the reference](../reference.md).


The customer-facing self-service API:

* [sdc-cloudapi](https://github.com/TritonDataCenter/sdc-cloudapi): SDC Public HTTP API


The user interface and CLI tools for administering the system:

* [sdc-adminui](https://github.com/TritonDataCenter/sdc-adminui): Operations UI for SDC
* [sdc-sdc](https://github.com/TritonDataCenter/sdc-sdc): Contains all the tools that go into the &#39;sdc&#39; zone.
* [sdcadm](https://github.com/TritonDataCenter/sdcadm): A tool for SDC upgrades, health and sanity checks, and possibly other SDC setup duties
* [sdc-imgapi-cli](https://github.com/TritonDataCenter/sdc-imgapi-cli): SDC CLI client for working with an IMGAPI repository
* [sdc-amonadm](https://github.com/TritonDataCenter/sdc-amonadm): SDC monitoring configuration tool


Cloudapi and the administrative tools call out to the internal REST APIs
to manage the system:

* [sdc-amon](https://github.com/TritonDataCenter/sdc-amon): SDC internal API and agents for monitoring and alarming
* [sdc-cloud-analytics](https://github.com/TritonDataCenter/sdc-cloud-analytics): SDC internal API for gathering real-time metrics across the datacenter
* [sdc-cnapi](https://github.com/TritonDataCenter/sdc-cnapi): SDC Compute Node API -- deals with communication to and management of compute nodes
* [sdc-fwapi](https://github.com/TritonDataCenter/sdc-fwapi): SmartDataCenter Firewall API
* [sdc-imgapi](https://github.com/TritonDataCenter/sdc-imgapi): SDC internal API for managing Images
* [sdc-napi](https://github.com/TritonDataCenter/sdc-napi): SmartDataCenter Network API: manages networking-related data
* [sdc-papi](https://github.com/TritonDataCenter/sdc-papi): SDC Packages API, an HTTP interface topackages used for creating new VMs
* [sdc-sapi](https://github.com/TritonDataCenter/sdc-sapi): SDC Services API. It coordinates the configuration and deployment of SDC services.
* [sdc-vmapi](https://github.com/TritonDataCenter/sdc-vmapi): SDC internal API for managing VMs
* [sdc-workflow](https://github.com/TritonDataCenter/sdc-workflow): SDC installer for Workflow API and Runners


The data storage layer is used to provide HA storage to the APIs and other
services:

* [moray](https://github.com/TritonDataCenter/moray): Moray, the highly-available key/value store (Joyent SDC, Manta)
* [sdc-ufds](https://github.com/TritonDataCenter/sdc-ufds): SDC LDAP Server
* [manatee](https://github.com/TritonDataCenter/manatee): Automated fault monitoring and leader-election system for strongly-consistent, highly-available writes to PostgreSQL


Infrastructure zones (VM instances) provide other essential services:

* [sdc-amonredis](https://github.com/TritonDataCenter/sdc-amonredis): SDC &quot;amonredis&quot; core zone.
* [sdc-assets](https://github.com/TritonDataCenter/sdc-assets): Static file service for SDC CNs.
* [binder](https://github.com/TritonDataCenter/binder): SDC/Manta DNS server over Apache Zookeeper
* [sdc-booter](https://github.com/TritonDataCenter/sdc-booter): SmartDataCenter Compute Node DHCP and TFTP server
* [sdc-manatee](https://github.com/TritonDataCenter/sdc-manatee): SDC HA Postgres
* [sdc-manta](https://github.com/TritonDataCenter/sdc-manta): SDC tools for deploying and managing a Manta
* [mahi](https://github.com/TritonDataCenter/mahi): Authentication cache
* [sdc-rabbitmq](https://github.com/TritonDataCenter/sdc-rabbitmq): RabbitMQ zone for SDC.
* [sdc-redis](https://github.com/TritonDataCenter/sdc-redis): SDC &quot;redis&quot; core zone.
* [muppet](https://github.com/TritonDataCenter/muppet): Loadbalancer for Manta and SmartDataCenter
* [zookeeper-common](https://github.com/TritonDataCenter/zookeeper-common): Common submodule of the sdc-zookeeper (deprecated) and binder zones, to reduce drift in ZK
* [keyapi](https://github.com/TritonDataCenter/keyapi): SmartDataCenter token API


Agents are services that run in the Global Zone of a Compute Node for
management or monitoring purposes:

* [sdc-amon](https://github.com/TritonDataCenter/sdc-amon): SDC internal API and agents for monitoring and alarming
* [sdc-agents-installer](https://github.com/TritonDataCenter/sdc-agents-installer): Scripts to create self-extracting agents executables
* [sdc-agents-core](https://github.com/TritonDataCenter/sdc-agents-core): Core package to boostrap agents installation
* [sdc-provisioner-agent](https://github.com/TritonDataCenter/sdc-provisioner-agent): SDC provisioner agent; executes tasks on compute nodes
* [sdc-hagfish-watcher](https://github.com/TritonDataCenter/sdc-hagfish-watcher): SDC instance usage telemetry agent
* [sdc-heartbeater-agent](https://github.com/TritonDataCenter/sdc-heartbeater-agent): Emits periodic compute node status to AMQP
* [sdc-cn-agent](https://github.com/TritonDataCenter/sdc-cn-agent): SDC Compute Node agent; monitors and reports cn-usage, executes tasks
* [sdc-net-agent](https://github.com/TritonDataCenter/sdc-net-agent): SDC agent for the internal Networking API
* [sdc-vm-agent](https://github.com/TritonDataCenter/sdc-vm-agent): SDC agent for the internal VMs API
* [sdc-smart-login](https://github.com/TritonDataCenter/sdc-smart-login): SDC component that enable SSHd on VMs to resolve public keys
* [sdc-firewaller-agent](https://github.com/TritonDataCenter/sdc-firewaller-agent): SmartDataCenter Firewall Agent: syncs firewall rules and related VM data to Compute Nodes
* [sdc-cloud-analytics](https://github.com/TritonDataCenter/sdc-cloud-analytics): SDC internal API for gathering real-time metrics across the datacenter
* [sdc-ur-agent](https://github.com/TritonDataCenter/sdc-ur-agent): SDC compute node bootstrapping agent


There are also agents that run in each SDC service zone:

* [sdc-config-agent](https://github.com/TritonDataCenter/sdc-config-agent): SDC configuration agent
* [registrar](https://github.com/TritonDataCenter/registrar): On-zone DNS registration agent (see also: binder)


Service clients are node client APIs for communicating with services:

* [node-sdc-clients](https://github.com/TritonDataCenter/node-sdc-clients): Node.js Clients for SmartDataCenter Services
* [node-manatee](https://github.com/TritonDataCenter/node-manatee): Manatee client
* [node-urclient](https://github.com/TritonDataCenter/node-urclient): client library for speaking with ur-agent
* [node-moray](https://github.com/TritonDataCenter/node-moray): NodeJS Client for Moray
* [node-ufds](https://github.com/TritonDataCenter/node-ufds): Node.js API for UFDS
* [sdc-wf-client](https://github.com/TritonDataCenter/sdc-wf-client): Client for the SDC Workflow API


SmartOS repos are used by the [SmartOS project](http://smartos.org) to build
the OS image, and form the foundation for SDC:

* [smartos-live](https://github.com/TritonDataCenter/smartos-live): For more information, please see http://smartos.org/ For any questions that aren&#39;t answered there, please join the SmartOS discussion list: http://smartos.org/smartos-mailing-list/
* [illumos-kvm](https://github.com/TritonDataCenter/illumos-kvm): KVM driver for illumos
* [illumos-kvm-cmd](https://github.com/TritonDataCenter/illumos-kvm-cmd): qemu-kvm for illumos-kvm
* [mdata-client](https://github.com/TritonDataCenter/mdata-client): Cross-platform metadata client tools for use in SDC guests (both Zones and KVM)
* [sdc-platform](https://github.com/TritonDataCenter/sdc-platform): SDC-specific platform components
* [smartos-overlay](https://github.com/TritonDataCenter/smartos-overlay): Overlay directory specific to open-source SmartOS
* [illumos-joyent](https://github.com/TritonDataCenter/illumos-joyent): Community developed and maintained version of the OS/Net consolidation
* [illumos-extra](https://github.com/TritonDataCenter/illumos-extra): Extra non-ON software required for Illumos


Build tools are used for creating the zone images:

* [sdcnode](https://github.com/TritonDataCenter/sdcnode): Tools for creation of prebuilt node tarballs for SDC components.
* [sdc-headnode](https://github.com/TritonDataCenter/sdc-headnode): Repository for building headnode images for SDC, and the intial setup and configuration of the headnode itself
* [sdc-scripts](https://github.com/TritonDataCenter/sdc-scripts): Common scripts for configuring and setting up SDC zones.
* [ipxe](https://github.com/TritonDataCenter/ipxe): SDC iPXE implementation


There are also services responsible for syncing data between datacenters or
to manta:

* [sdc-hermes](https://github.com/TritonDataCenter/sdc-hermes): Centralised tool to upload SDC logs to Manta


Documentation repos:

* [sdc](https://github.com/TritonDataCenter/sdc): starting point for SmartDataCenter
* [eng](https://github.com/TritonDataCenter/eng): Joyent Engineering Guide
* [restdown-brand-remora](https://github.com/TritonDataCenter/restdown-brand-remora): &quot;remora&quot; restdown brand/style for coherent API documentation
* [oid-docs](https://github.com/TritonDataCenter/oid-docs): Document the Joyent OID tree (1.3.6.1.4.1.38678)
* [schemas](https://github.com/TritonDataCenter/schemas): Schemas used by Joyent APIs, tools, and databases


The other repos are used by one of the other repos above:

* [convertvm](https://github.com/TritonDataCenter/convertvm): convert OVF vm packages to smartos compatible images
* [sdc-system-tests](https://github.com/TritonDataCenter/sdc-system-tests): SDC system tests
* [node-timeseries-heatmap](https://github.com/TritonDataCenter/node-timeseries-heatmap): Time series heatmaps for node.js
* [node-png-joyent](https://github.com/TritonDataCenter/node-png-joyent): An ancient branch of node-png
* [node-amqp-joyent](https://github.com/TritonDataCenter/node-amqp-joyent): An ancient branch of node-amqp
* [node-imgmanifest](https://github.com/TritonDataCenter/node-imgmanifest): Node.js library for working with SmartOS image manifests
* [sdc-fast-stream](https://github.com/TritonDataCenter/sdc-fast-stream): Stream event messages via node-fast.
* [sdc-fwrule](https://github.com/TritonDataCenter/sdc-fwrule): SmartDataCenter firewall rule parser and object.
* [aperture-config](https://github.com/TritonDataCenter/aperture-config): Common aperture config for SDC/Manta
* [node-workflow-moray-backend](https://github.com/TritonDataCenter/node-workflow-moray-backend): A backend for node-workflow built over Moray
* [sdc-securetoken](https://github.com/TritonDataCenter/sdc-securetoken): Library to securely pass data publicly between services.
* [node-tracker](https://github.com/TritonDataCenter/node-tracker): Node.js library list vm details, watch for status changes
* [node-zfs](https://github.com/TritonDataCenter/node-zfs): Node.js library to interface with ZFS utilities
* [sdc-designation](https://github.com/TritonDataCenter/sdc-designation): Compute node designation library
* [sdc-wf-shared](https://github.com/TritonDataCenter/sdc-wf-shared): SmartDataCenter workflow shared code.
* [cloud-tycoon](https://github.com/TritonDataCenter/cloud-tycoon): DC simulation package
* [node-triton-netconfig](https://github.com/TritonDataCenter/node-triton-netconfig): A module to help manage the network configuration of a trition datacenter
