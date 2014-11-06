# The SmartDataCenter Glossary

This glossary vocabulary and terminology used to talk about features and
aspects of SmartDataCenter (SDC).

### adminui

The [repository](https://github.com/joyent/sdc-adminui) and SDC
core service name for the operator portal is "adminui". See [Operator
Portal](#operator-portal).

### Agent

Generally-speaking an agent is piece of software that runs "locally", e.g.
in a VM or on a server, as *part* of a larger system. For example, many
monitoring systems have an agent that will run in your VMs or on your servers to
report issues back to a central service.

In SDC, there are agents running both on [compute nodes](#compute-node)
[global zones](#global-zones) and in core SDC VMs to assist in providing
SDC functionality. An example of the former is the "vm-agent" that runs
in every SDC server's global zone and reports VM state to VMAPI. An example
of the latter is the "registrar" agent running in each SDC core VM to report
back its IP for internal DNS.

At the time of this writing, SDC is moving to having all GZ agents (the former
type) be managed as "SAPI services" of type "agent" -- see the
[Service](#service) section below.

See the [reference](reference.md#agents) for an overview of agents in SDC.

### CN

See [compute node](#compute-node).

### CoaL

"Cloud on a Laptop" is a VMware virtual appliance providing a full SDC headnode
for development and testing. See [the
README](https://github.com/joyent/sdc#cloud-on-a-laptop-coal) for getting start
with SDC using a recent CoaL build.

### Compute Node

A node (or physical server) in a SmartDataCenter installation that is not the
[headnode](#headnode). Compute nodes are where customer VMs are run.

### Global Zone

"Zones" is the term used in SmartOS/Illumos/Solaris and other derivatives to
refer to operating system-level virtualized containers. See [Wikipedia's
Solaris Containers article](http://en.wikipedia.org/wiki/Solaris_Containers)
for a general introduction to zones. The special "global" zone is
non-virtualized host for all "non-global" zones.

Borrowing from [Jonathan Perkin's post on the SmartOS global
zone](http://www.perkin.org.uk/posts/smartos-and-the-global-zone.html), two
key principles in SmartOS' design govern usage of the global zone:

- SmartOS is specifically designed as an OS for running Virtual Machines, not
  as a general purpose OS.
- The global zone is effectively a read-only hypervisor, and should only be
  used for creating and managing Virtual Machines.  Everything else should be
  performed inside Virtual Machines.

In SmartDataCenter, which runs SmartOS as its OS on every node, the global zone
is only ever used to run operator-owned infrastructure (agents, SMF services)
for managing the data center. All customer activity is run in non-global zones.


### GZ

See [Global Zone](#global-zone).

### HN

See [headnode](#headnode).

### headnode

The first node (or physical server) setup for a SmartDataCenter installation,
and the one that houses the initial instances of all SDC services, is the
"headnode" (or HN for short). Typically the headnode is reserved for SDC and
operator services, i.e. no customer VMs are run on the headnode. All other
nodes are referred to as [compute nodes](#compute-node).

### Operator Portal

The Operator Portal (a.k.a. adminui) is the Web UI for administering SmartDataCenter.
Its repository is [sdc-admin.git](https://github.com/joyent/sdc-adminui).

### Service

There are two common usages of "service" in SDC:

1. SAPI services. "SAPI" is a the SDC Service API, the HTTP REST API of
   record for the core SmartDataCenter components (each called a "service")
   and instances of those services (called "instances"). For example, the
   "VMAPI" service is a component of SDC defined in SAPI.

   Furthermore, SAPI defines multiple types of services: "vm" services (e.g.
   VMAPI, IMGAPI, CloudAPI, etc.) for which an instance is a VM, and "agent"
   services (e.g. "net-agent" and "vm-agent") for which an instance is an
   installation in the [global zone](#global-zone) of a [compute
   node](#compute-node). Sometimes, for historical reasons, usage of "SAPI
   service" will be referring to *only* the SAPI services of type "vm".

2. SMF services.
   [SMF](http://wiki.smartos.org/display/DOC/Using+the+Service+Management+Facility)
   is the SmartOS/illumos/SunOS "Service Management Facility". It is an OS-level
   facility for process management. All long-running processes that are part of
   SDC use SMF. An SMF service is identified by its Fault Management Resource
   Identifier (FMRI), e.g.:

        svc:/smartdc/site/imgapi:default
        svc:/smartdc/site/vmapi:default
        svc:/smartdc/agent/amon-relay:default
        svc:/smartdc/agent/ca/cainstsvc:default
        svc:/smartdc/agent/firewaller:default

   However commonly abbreviated names are used and supported by all the
   tooling, e.g.

        svcs -x imgapi
        svcadm restart vmapi
        svcadm disable amon-relay
