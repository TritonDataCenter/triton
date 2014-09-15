# The SmartDataCenter Glossary

This glossary vocabulary and terminology used to talk about features and
aspects of SmartDataCenter.

### adminui

The repository and internal SDC service name for the operator portal is
"adminui". See [Operator Portal](#operator-portal).

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


### CN

See [compute node](#compute-node).

### CoaL

TODO

### Compute Node

TODO

### Global Zone

TODO

### GZ

See [Global Zone](#global-zone).

### HN

See [headnode](#headnode).

### headnode

TODO

### Operator Portal

TODO

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

