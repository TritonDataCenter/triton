<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2021 Joyent, Inc.
    Copyright 2022 MNX Cloud, Inc.
-->

# Triton DataCenter

Triton DataCenter (just "Triton" for short, formerly "SmartDataCenter" and
"SDC") is an open-source cloud management platform that delivers next
generation, container-based, service-oriented infrastructure across one or more
data centers. With an emphasis on ease of installation and operation, Triton is
proven at scale: Triton powers the [Triton
Cloud](https://www.tritondatacenter.com/triton/managed-hardware-cloud) and private data centers
([Triton Enterprise](https://www.tritondatacenter.com/triton/on-premises))
worldwide.

This repository provides documentation for the overall Triton project and
pointers to the other repositories that make up a complete Triton deployment.
See the [repository list](./docs/developer-guide/repos.md).

Report bugs and request features using [GitHub Issues](https://github.com/TritonDataCenter/triton/issues).
For additional resources, you can visit the
[Triton Developer Center](https://www.tritondatacenter.com/getting-started).

## Overview

A Triton DataCenter installation consists of two or more servers. All servers run
[SmartOS](http://smartos.org). One server acts as the management server, the
head node, which houses the initial set of core services that drive Triton. The
remainder are compute nodes (CNs) which run instances (containers and
virtual machines).

Triton features:

* SmartOS zones provides high performance container virtualization. KVM support
  on top of zones means secure full Linux and Windows guest OS support.
* RESTful API and CLI tooling for customer self-service
* Complete operator portal (web app)
* Robust and observable service oriented architecture (implemented primarily in
  Node.js)
* Automated USB key, ISO, or iPXE installation

Triton consists of the following components:

* A public API for provisioning and managing instances (virtual machines),
  networks, users, images, etc.
* An operator portal
* A set of private APIs
* Agents running in the global zone of CNs for management and monitoring

For more details, see:

* The [Triton Enterprise](https://docs.tritondatacenter.com/private-cloud) documentation.
* [Triton DataCenter Architecture](./docs/developer-guide/architecture.md) for
  overall architecture.
* [Triton DataCenter Reference](./docs/reference.md) for an
  overview of each component.

## Community

Community discussion about Triton DataCenter happens in two main places:

* The *sdc-discuss*
  [mailing list](https://smartdatacenter.topicbox.com/groups/sdc-discuss).
  If you wish to send mail to the list you'll need to join, but you can view
  and search the archives online without being a member.

* In the *#smartos* IRC channel on the
  [Libera Chat IRC network](https://libera.chat/).

## Getting Started

### Cloud on a Laptop (CoaL)

An easy way to try Triton DataCenter is by downloading and installing a Cloud
on a Laptop (CoaL) build. CoaL is a VMware virtual appliance that provides a
full Triton head node for development and testing.

The [CoaL Setup document](./docs/developer-guide/coal-setup.md) contains
detailed instructions for downloading and installing the virtual appliance.
If you use the ISO installer (see below) on a Virtual Machine, the CoaL setup
instructions post-booting should be followed as well.

If you already have a CoaL and would like to update the installation, follow
the instructions for [updating a Triton standup using
[`sdcadm`](https://github.com/TritonDataCenter/sdcadm/blob/master/docs/update.md).

### ISO Installer

The [ISO installer page](./docs/developer-guide/iso-installer.md) contains
information on the ISO installer. With SmartOS now able to boot off a ZFS
pool, the Triton Head Node can do the same.

### iPXE installer

Some deployment environments install new hardware using an iPXE boot. An
[iPXE boot](./docs/developer-guide/ipxe-installer.md) directory for a Triton
Head Node can install Triton using an iPXE installation.

### Installing Triton on a Physical Server

A Triton DataCenter server runs SmartOS which is a live image. That live
image, which generates a ramdisk root with many portions set to read-only,
can boot from a USB flash drive (a physical USB key), or a ZFS pool.  To
install a USB-key Triton, first obtain the latest release USB build.
Otherwise, given the cautions in the [ISO installer
page](./docs/developer-guide/iso-installer.md), a physical server can boot
off of its `zones` pool.

Both USB-key-boot and ZFS-pool-boot use the same interfaces within Triton,
with a ZFS bootable filesystem substituting for the USB-key.

#### Hardware

For Triton development only, the minimum server hardware is:

* 8 GB USB flash drive
* Intel Processors with VT-x and EPT support (all Xeon since Nehalem), or AMD
  Processors no earlier than EPYC or Zen.
* 16 GB RAM
* 20 GB available storage

Hardware RAID is not recommended. Triton will lay down a ZFS ZPOOL across all
available disks on install. You'll want much more storage if you're working
with images and instances.  If you are using an ISO or iPXE installation,
configure a simple layout of disks (e.g. mirrored pair, or single raidz
group).

If setting up a Triton DataCenter pilot then you'll want to review
the [Hardware Selection Requirements](https://docs.tritondatacenter.com/private-cloud/install/hardware-selection),
[Networking Layout Requirements](https://docs.tritondatacenter.com/private-cloud/install/network-layout),
and [Installation Prerequisites](https://docs.tritondatacenter.com/private-cloud/install/deployment-planning)
which include IPMI and at least 10 gigabit Ethernet. The supported hardware
components for SmartOS are described in the
[SmartOS Hardware Requirements](http://wiki.smartos.org/display/DOC/Hardware+Requirements).
certified hardware for Triton DataCenter are all in
the [Triton Manufacturing Database](https://docs.tritondatacenter.com/private-cloud/hardware).

#### Install

To install a USB-key Triton, first download the latest release image:

```bash
curl -C - -O https://us-central.manta.mnx.io/Joyent_Dev/public/SmartDataCenter/usb-latest.tgz
```

Once you have downloaded the latest release image, you will need to
[write it to a USB key](https://docs.tritondatacenter.com/private-cloud/install/installation-media)
boot the head node server using the USB key, and follow the install prompts. All steps necessary
to plan, install, and configure Triton DataCenter (Triton) are available in the
customer documentation [Installing Triton Data Center](https://docs.tritondatacenter.com/private-cloud/install).

To install using the [ISO
installer](./docs/developer-guide/iso-installer.md), download the [ISO
image](https://us-central.manta.mnx.io/Joyent_Dev/public/SmartDataCenter/iso-latest.iso),
make sure you be aware of the available disks, and then follow the
installation instructions above.

To install using the [iPXE
installer](https://us-central.manta.mnx.io/Joyent_Dev/public/SmartDataCenter/ipxe-latest.tgz),
follow the advice on the [iPXE installer
documentation](./docs/developer-guide/ipxe-installer.md).

## Building

Triton is composed of several pre-built components:

* A [SmartOS *platform* image](https://github.com/TritonDataCenter/smartos-live). This is
  a slightly customized build of vanilla SmartOS for Triton.
* *Virtual machine images* for Triton services (e.g. imgapi, vmapi, adminui), which
  are provisioned as VMs at install time.
* Agents bundled into a [single
  package](https://github.com/TritonDataCenter/sdc-agents-installer)
  installed into the global zone of each compute node.

Each component is built separately and then all are combined into
CoaL, USB, ISO, and iPXE builds (see the preceding sections) via the
[sdc-headnode repository](https://github.com/TritonDataCenter/sdc-headnode). The
built components are typically stored in a [Manta object
store](https://github.com/TritonDataCenter/manta), and pulled from
there. For example, Triton builds push to
`/Joyent_Dev/public/builds` in our public Manta in us-central-1
(<https://us-central.manta.mnx.io/>).

You can build your own CoaL and USB images on Mac or SmartOS (see the
[sdc-headnode
README](https://github.com/TritonDataCenter/sdc-headnode#readme)). However, ISO
and iPXE images, as well as all other Triton components must be built
using a running Triton or in a local CoaL). See
[the building document](./docs/developer-guide/building.md) for details on
building each of the Triton components.

## Contributing

To report bugs or request features, submit issues here on
GitHub, [TritonDataCenter/triton/issues](https://github.com/TritonDataCenter/triton/issues)
(or on the GitHub issue tracker for the relevant project).
For support of Triton products and services, please contact [MNX Solutions customer
support](https://www.tritondatacenter.com/contact) instead.

See the [Contribution Guidelines](CONTRIBUTING.md) for information about
contributing changes to the project.

## Design Principles

Triton DataCenter is very opinionated about how to architect a cloud. These
opinions are the result of many years of deploying and debugging
[Triton as a public cloud service](https://www.tritondatacenter.com/triton/compute)
in production. Design principles include the following:

* A VM's primary storage should be local disk, not over the network -- this
  avoids difficult to debug performance pathologies.
* Communication between internal APIs should occur in its own control plane
  (network) that is separate from the customer networks. Avoid communicating
  over the open Internet if possible.
* A provisioned VM should rely as little as possible on Triton services outside of
  the operating system for its normal operation.
* Installation and operation should require as little human intervention as
  possible.

The goals behind the design of Triton services include:

* All parts of the stack should be observable.
* The state of the running service should be simple to obtain.
* The internals of the system should make it straightforward to debug from a
  core file (from a crash or taken from a running process using
  [gcore(1)](http://smartos.org/man/1/gcore)).
* Services should be RESTful and accept JSON unless there is a compelling
  reason otherwise.
* Services should avoid keeping state and should not assume that there is
  only one instance of that service running. This allows multiple instances
  of a service to be provisioned for high availability.
* Node.js and C should be used for new services.

## Dependencies and Related Projects

Triton DataCenter uses [SmartOS](http://smartos.org) as the host operating
system. The SmartOS hypervisor provides both SmartOS zone (container) and
KVM virtualization.

Triton's open-source [Manta project](https://github.com/TritonDataCenter/manta)
is an HTTP-based object store with built-in support to run arbitrary
programs on data at rest (i.e., without copying data out of the object store).
Manta runs on and integrates with Triton DataCenter.

## License

Triton DataCenter is licensed under the
[Mozilla Public License version 2.0](http://mozilla.org/MPL/2.0/).
See the file LICENSE. SmartOS is [licensed separately](http://smartos.org/cddl/).
