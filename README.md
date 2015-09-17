<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2015, Joyent, Inc.
-->


# SmartDataCenter

SmartDataCenter (SDC) is an open-source cloud management platform, optimized
to deliver next generation, container-based, service-oriented infrastructure
across one or more data centers. With an emphasis on ease of installation
and operation, SDC is proven at scale: it is the software that runs
the [Joyent public cloud](https://www.joyent.com/public-cloud)
and powers
[private clouds](https://www.joyent.com/products/private-cloud)
at organizations of all size and industry.

This repository provides documentation for the overall SDC project and
pointers to the other repositories that make up a complete SDC deployment.
See the [repository list](./docs/developer-guide/repos.md).

Report bugs and request features using [GitHub Issues](https://github.com/joyent/sdc/issues).
For additional resources, you can visit the
[Joyent Developer Center](https://www.joyent.com/developers).


## Overview

A SmartDataCenter installation consists of two or more servers. All servers run
[SmartOS](http://smartos.org). One server acts as the management server, the
headnode, which houses the initial set of core services that drive SDC. The
remainder are compute nodes (CNs) which run instances (virtual machines).

SDC features:

- SmartOS zones provides high performance container virtualization. KVM support
  on top of zones means secure full Linux and Windows guest OS support.
- RESTful API and CLI tooling for customer self-service
- Complete operator portal (web app)
- Robust and observable service oriented architecture (implemented primarily in
  Node.js)
- Automated USB key installation

SDC consists of the following components:

- A public API for provisioning and managing instances (virtual machines),
  networks, users, images, etc.
- An operator portal
- A set of private APIs
- Agents running in the global zone of CNs for management and monitoring

For more details, see:

- The [Overview of SmartDataCenter 7](https://docs.joyent.com/sdc7/overview-of-smartdatacenter-7)
  in the Joyent customer documentation.
- [SmartDataCenter Architecture](./docs/developer-guide/architecture.md) for
  overall architecture.
- [SmartDataCenter Reference](./docs/reference.md) for an
  overview of each component.


## Community

Community discussion about SmartDataCenter happens in two main places:

* The *sdc-discuss* mailing list. Once you [subscribe to the list](https://www.listbox.com/subscribe/?list_id=247449),
  you can send mail to the list address: sdc-discuss@lists.smartdatacenter.org.
  The mailing list archives are also [available on the web](https://www.listbox.com/member/archive/247449/=now).

* In the *#smartos* IRC channel on the [Freenode IRC network](https://freenode.net/).

You can also follow [@SmartDataCenter](https://twitter.com/SmartDataCenter) on
Twitter for updates.


## Getting Started

### Cloud on a Laptop (CoaL)

An easy way to try SmartDataCenter is by downloading a Cloud on a Laptop
(CoaL) build. This is a VMware virtual appliance providing a
full SDC headnode for development and testing.

The minimum requirements, practically speaking, for a good CoaL experience
is a **Mac with at least 16 GB RAM and an SSD**. Currently, almost all team
members using CoaL are on Macs with VMware Fusion. Vmware Workstation for 
Linux is used by a few in the community. VMware Workstation for Windows
should work, but has not recently been tested.

See [CoaL Setup](./docs/developer-guide/coal-setup.md) for a thorough
walkthrough including updating CoaL and enabling provisioning on the
headnode.

1. Start the download of the latest CoaL build. The tarball is
   approximately 2 GB.

    ```bash
    curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/coal-latest.tgz
    ```

2. Install VMware, if you haven't already.
    - Mac: [VMware Fusion](http://www.vmware.com/products/fusion) 5, 7, or 8.
    - Windows or Linux: [VMware Workstation](http://www.vmware.com/products/workstation).

3. Configure VMware virtual networks for CoaL's "external" and "admin"
   networks. This is a one time configuration for a VMware installation.

    1. Launch VMware at least once after installing VMware.

    2. Run SDC set up script for VMware:

         - Mac:

            ```bash
            curl -s https://raw.githubusercontent.com/joyent/sdc/master/tools/coal-mac-vmware-setup | sudo bash
            ```

         - Linux:

            ```bash
            curl -s https://raw.githubusercontent.com/joyent/sdc/master/tools/coal-linux-vmware-setup | sudo bash
            ```

         - Windows:

            ```
            Download https://raw.githubusercontent.com/joyent/sdc/master/tools/coal-windows-vmware-setup.bat
            Run coal-windows-vmware-setup.bat
            ```

4. Unpack the CoaL build that you downloaded in step 1.

    - Mac:

        ```bash
        $ tar -zxvf coal-latest.tgz
        x root.password.20140911t161518z
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/USB-headnode.vmx
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/zpool.vmdk
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/USB-headnode.vmdk
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/4gb.img
        ...
        ```

5. Start VMware and load the appliance.

    - Mac: 'open'ing the folder will start VMware and "open and run" the vm:

            open coal-<branch>-<build_date_time>-<git_sha1_hash>-4gb.vmwarevm

6. Boot the headnode.

  When you are prompted with the GRUB menu press the "down" arrow.

  1. Press the down arrow key to highlight "Live 64-bit".

  1. Press 'c' to go to the command line for GRUB.

     By default, the OS will redirect the console to ttyb which is fine
     for production but needs to be changed for CoaL. While in the command line:

            grub> variable os_console vga

  1. Press enter.

  1. Press esc to get back to the GRUB menu.

  1. Boot "Live 64-bit" by pressing enter.

7. Configure the headnode.

Use the following table to configure your CoaL with settings that
are fine for development.

If you make a mistake while entering the configuration you can restart
the VMware virtual machine. Also, as the onscreen instructions describe,
the last step in configuration allows editing the resulting configuration file.

|Setting|Value|Notes|
|---|---|---|
|*Instructions*|↵||
|Company Name|Clavius|*Can substitute with your choice.*|
|Region of Datacenter|orbit|*Can substitute with your choice.*|
|Name of Datacenter|coal-1|(Availability zone.) *Can substitute with your choice.* |
|Location of DataCenter|Moon, Earth|*Can substitute with your choice.*|
|*Instructions*|↵||
|'admin' interface|2|The second NIC is set up as the admin network by the CoaL networking script|
|(admin) headnode IP address|10.99.99.7|Must use this value.|
|(admin) headnode netmask:|↵|Use the default.|
|(admin) Zone's starting IP address:|↵|Use the default.|
|Add external network now? (Y/n)|Y|Must use this value.|
|'external' interface|1|The first NIC is set up as the external network by the CoaL networking script|
|(external) headnode IP address|10.88.88.200|Must use this value.|
|(external) headnode netmask:|↵|Use the default.|
|(external) gateway IP address:|10.88.88.2|Must use this value.|
|(external) network VLAN ID|↵|Use default. The external network is not on a VLAN in CoaL|
|Starting Provisionable IP address for external Network|↵|Use the default.|
|Ending Provisionable IP address for external Network|↵|Use the default.|
|Default gateway IP address:|↵|Use the default.|
|Primary DNS Server|↵|Use the default.|
|Secondary DNS Server|↵|Use the default.|
|Head node domain name|example.com|*Can substitute with your choice.*|
|DNS Search Domain|example.com|*Can substitute with your choice.*|
|NTP Server IP Address|↵|Use the default.|
|"root" password|rootpass|*Can substitute with your choice.*|
|Confirm "root" password|||
|"admin" password|adminpass1|*Can substitute with your choice.*|
|Confirm "admin" password|||
|Administrator's email|↵|Use the default.|
|Support email|↵|Use the default.|
|Confirm password|||
|Enable telemetry|"true" or "false"|*Can use your choice*|
|Verify Configuration|||
|Verify Configuration Again|||

- CoaL will now install based on the configuration parameters entered
  above. Installation has been observed to take up to 20 minutes,
  particularly if slow laptop HDD.

After setup is complete you should be able to SSH into your CoaL on the
"admin" network. Example:

```bash
ssh root@10.99.99.7  # password 'rootpass'
```

For just a taste run `svcs` to see running [SMF
services](http://wiki.smartos.org/display/DOC/Using+the+Service+Management+Facility).
Run `vmadm list` to see a list of current VMs (SmartOS
[zones](http://wiki.smartos.org/display/DOC/Zones)). Each SDC service runs in
its own zone. See [the Joyent customer documentation](https://docs.joyent.com/sdc7).

As mentioned previously, see [CoaL Setup](./docs/developer-guide/coal-setup.md)
for a thorough walkthrough.


### Installing SDC on a Physical Server

A SmartDataCenter server runs SmartOS which is a live image. This means that
it boots from a USB flash drive (key).
a physical USB key, inserting the key and booting the server from that key.
To install SDC, first obtain the latest release USB build.


#### Hardware

For SDC development only, the minimum server hardware is:

- 8 GB USB flash drive
- Intel Processors with VT-x and EPT support (all Xeon since Nehalem)
- 16 GB RAM
- 6 GB available storage

Hardware RAID is not recommended. SDC will lay down a ZFS ZPOOL across all
available disks on install. You'll want much more storage if you're working with
images and instances.

If setting up a SmartDataCenter pilot then you'll want to review
the [Minimum Requirements](https://docs.joyent.com/sdc7/sdc7-minimium-requirements)
and [Installation Prerequisites](https://docs.joyent.com/sdc7/sdc7-installation-prerequisites)
which include IPMI and at least 10 gigabit Ethernet. The supported hardware
components for SmartOS are described in the [SmartOS Hardware Requirements](http://wiki.smartos.org/display/DOC/Hardware+Requirements).
Joyent certified hardware for SmartDataCenter are all in
the [Joyent Manufacturing Database](http://eng.joyent.com/manufacturing/).


#### Install

To install SDC, first download the latest release image:

```bash
curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/usb-latest.tgz
```

Once you have downloaded the latest release image, you will need to
[write it to a USB key](https://docs.joyent.com/sdc7/installing-sdc7/creating-a-usb-key-from-a-release-tarball),
boot the headnode server using the USB key, and follow the install prompts. See
the the Joyent customer documentation "[installing SDC 7](https://docs.joyent.com/sdc7/installing-sdc7)"
and "[install checklist](https://docs.joyent.com/sdc7/installing-sdc7/install-checklist)"
for information.

After installation, you will probably want to perform some
[additional configuration](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration).
The most common of these include:

- [Adding external nics to the imgapi and adminui zones](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration#AddingExternalNICstoHeadNodeVMs)
  to give them internet access. This enables simple import of VM images.
- [Provision a CloudAPI zone](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration#CreatingCloudAPI)
  to allow users to create and administer their VMs without an operator.

See the
[post-installation configuration documentation](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration)
for the complete list.


## Building

SDC is composed of several pre-built components:

- A [SmartOS *platform* image](https://github.com/joyent/smartos-live). This is
  a slightly customized build of vanilla SmartOS for SDC.
- *Virtual machine images* for SDC services (e.g. imgapi, vmapi, adminui), which
  are provisioned as VMs at install time.
- Agents bundled into a [single
  package](https://github.com/joyent/sdc-agents-installer)
  installed into the global zone of each compute node.

Each component is built separately and then all are combined into CoaL and USB
builds (see the preceding sections) via the [sdc-headnode
repository](https://github.com/joyent/sdc-headnode). The built components are
typically stored in a [Manta object store](https://github.com/joyent/manta),
e.g. [Joyent's public Manta](https://www.joyent.com/products/manta),
and pulled from there. For example, Joyent's builds push to
`/Joyent_Dev/public/builds` in Joyent's public Manta in us-east-1
(<https://us-east.manta.joyent.com/>).

You can build your own CoaL and USB images on Mac or SmartOS (see the
[sdc-headnode README](https://github.com/joyent/sdc-headnode#readme)). However,
all other SDC components must be built using a running SDC
(e.g. on the [Joyent Cloud](https://www.joyent.com/products/compute-service)
or in a local CoaL). See [the building document](./docs/developer-guide/building.md)
for details on building each of the SDC components.


## Contributing

To report bugs or request features, submit issues here on
GitHub, [joyent/sdc/issues](https://github.com/joyent/sdc/issues).
If you're contributing code, make pull requests to the appropriate
repositories (see [the repo overview](./docs/developer-guide/repos.md)).
If you're contributing something substantial, you should first contact
developers on the [sdc-discuss mailing list](mailto:sdc-discuss@lists.smartdatacenter.org)
([subscribe](https://www.listbox.com/subscribe/?list_id=247449),
[archives](http://www.listbox.com/member/archive/247449/=now)).

For support of Joyent products and services, please contact [Joyent customer
support](https://help.joyent.com/home) instead.

SDC repositories follow the [Joyent Engineering Guidelines](https://github.com/joyent/eng/blob/master/docs/index.md).
Notably:

- The #master branch should be first-customer-ship (FCS) quality at all times.
  Don't push anything until it's tested.
- All repositories should be `make check` clean at all times.
- All repositories should have tests that run cleanly at all times.

`make check` checks both JavaScript style and lint. Style is checked with
[jsstyle](https://github.com/davepacheco/jsstyle). The specific style rules are
somewhat repo-specific. Style is somewhat repo-specific. See the jsstyle
configuration file or `JSSTYLE_FLAGS` in Makefiles in each repo for exceptions
to the default jsstyle rules.

Lint is checked with
[javascriptlint](https://github.com/davepacheco/javascriptlint).
([Don't conflate lint with style!](http://dtrace.org/blogs/dap/2011/08/23/javascriptlint/)
There are gray areas, but generally speaking, style rules are arbitrary, while
lint warnings identify potentially broken code. Repos sometimes have
repo-specific lint rules -- look for "tools/jsl.web.conf" and
"tools/jsl.node.conf" for per-repo exceptions to the default rules.


## Design Principles

SmartDataCenter is very opinionated about how to architect a cloud. These
opinions are the result of many years of deploying and debugging
the [Joyent public cloud](https://www.joyent.com/public-cloud).
Design principles include the following:

- A VM's primary storage should be local disk, not over the network -- this
  avoids difficult to debug performance pathologies.
- Communication between internal APIs should occur in its own control plane
  (network) that is separate from the customer networks. Avoid communicating
  over the open Internet if possible.
- A provisioned VM should rely as little as possible on SDC services outside of
  the operating system for its normal operation.
- Installation and operation should require as little human intervention as
  possible.

The goals behind the design of SDC services include:

- All parts of the stack should be observable.
- The state of the running service should be simple to obtain.
- The internals of the system should make it straightfoward to debug from a
  core file (from a crash or taken from a running process using
  [gcore(1)](http://smartos.org/man/1/gcore)).
- Services should be RESTful and accept JSON unless there is a compelling
  reason otherwise.
- Services should avoid keeping state and should not assume that there is
  only one instance of that service running. This allows multiple instances
  of a service to be provisioned for high availability.
- Node.js and C should be used for new services.


## Dependencies and Related Projects

SmartDataCenter uses [SmartOS](http://smartos.org) as the host operating
system. The SmartOS hypervisor provides both SmartOS zone (container) and

Joyent's open-source [Manta project](https://github.com/joyent/manta)
is an HTTP-based object store with built-in support to run arbitrary
programs on data at rest (i.e., without copying data out of the object store).
Manta runs on and integrates with SmartDataCenter.


## License

SmartDataCenter is licensed under the
[Mozilla Public License version 2.0](http://mozilla.org/MPL/2.0/).
See the file LICENSE. SmartOS is [licensed separately](http://smartos.org/cddl/).
