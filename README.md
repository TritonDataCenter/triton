<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2014, Joyent, Inc.
-->

# Joyent SmartDataCenter

SmartDataCenter (SDC) is an open-source cloud computing software platform. It is
a complete system for creating and operating a secure, scalable, and robust
cloud. Features:

- SmartOS zones provides high performance container virtualization. KVM support
  on top of zones means secure full Linux and Windows guest OS support.
- RESTful API and CLI tooling for customer self-service
- Complete operations portal (web GUI)
- Robust and observable service oriented architecture (implemented primarily in
  Node.js)
- Automated USB key installation

SDC is the software that runs Joyent's public cloud and numerous on-premise
private clouds.

This repo provides documentation for the overall SDC project and pointers to the
other repositories that make up a complete SDC deployment. See the [repository
list](./docs/developer-guide/repos.md).


## Overview

A SmartDataCenter installation consists of two or more servers. All servers run
[SmartOS](https://smartos.org). One server acts as the management server, the
headnode (HN), which houses the initial set of core services that drive SDC. The
remainder are compute nodes (CNs) which run instances (virtual machines).

SDC is the cloud orchestration software that consists of the following
components:

- A public API for provisioning and managing instances (virtual machines),
  networks, users, images, etc.
- An operator portal.
- A set of private APIs.
- Agents running in the global zone of CNs for management and monitoring.

See the [overview of SDC](https://docs.joyent.com/sdc7/overview-of-smartdatacenter-7)
in the SDC operator documentation for more details. See
the [SmartDataCenter Reference](./docs/developer-guide/reference.md)
for an overview of each component.


## Getting Started

### Cloud on a Laptop (CoaL)

An easy way to try SmartDataCenter is by downloading a Cloud on a Laptop
(CoaL) build. This is a VMware virtual appliance providing a
full SDC headnode development and testing.

Minimum requirements: practically speaking, a good CoaL experience
requires a **Mac** with at least **16GB** RAM and **SSD** drives. Currently, all
core team members using CoaL are on Macs with VMware Fusion. For Linux and Windows
**VMware Workstation should work**, but has not recently been tested.

See [CoaL Setup](./docs/developer-guide/coal-setup.md) for a thorough walkthrough.

1. Start the download of the latest CoaL build. The tarball is over 2GB.

   During the private beta, download as follows:

    ```bash
    # Get the Manta CLI tools (https://github.com/joyent/node-manta).
    npm install -g manta

    # Setup to use the Manta CLI tools as the 'joyager' user.
    export MANTA_URL=https://us-east.manta.joyent.com
    export MANTA_USER=joyager
    export MANTA_KEY_ID=`ssh-keygen -l -f ~/.ssh/id_rsa.pub | awk '{print $2}' | tr -d '\n'`

    # Find the latest build on the master branch and download it.
    latest=$(mget -q /joyager/stor/builds/headnode/master-latest)
    pkg=$(mls $latest/headnode | grep coal-)
    echo "Downloading $latest/headnode/$pkg"
    mget -O $latest/headnode/$pkg
    ```

   When finally public the intention is to have the latest build here:

    ```bash
    curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/coal-latest.tgz
    ```

2. Install VMware, if you haven't already.
    - Mac: [VMware Fusion](http://www.vmware.com/products/fusion) 5 or later.
    - Windows or Linux: [VMware Workstation](http://www.vmware.com/products/workstation).

3. Configure VMware virtual networks for CoaL's "external" and "admin"
   networks. This is a one time configuration for a VMware installation.

    1. Launch VMware at least once after installing VMware.

    2. Download and run the following setup script from this repository.

         - Mac: download
           [./tools/coal-mac-vmware-setup](https://github.com/joyent/sdc/raw/master/tools/coal-mac-vmware-setup).
           Make this shell script executable and run as root:

             ```bash
             chmod 744 coal-mac-vmware-setup; sudo ./coal-mac-vmware-setup
             ```

         - Linux: not yet written.

         - Windows: download and run
           [./tools/coal-windows-vmware-setup.bat](https://github.com/joyent/sdc/raw/master/tools/coal-windows-vmware-setup.bat).

4. Unpack the CoaL build that you downloaded in step 1.

    - Mac:

        ```bash
        $ tar xzf coal-latest.tgz
        root.password.20140911t161518z
        coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/
        coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/USB-headnode.vmx
        coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/zpool.vmdk
        coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/USB-headnode.vmdk
        coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/4gb.img
        ...
        ```

5. Run CoaL on VMware:
    - Mac: 'open'ing the folder will start VMware and load the appliance:

        ```bash
        open coal-master-<build_id>-<git_sha1_hash>-4gb.vmwarevm
        ```

6. Boot the headnode:

    1. When you are prompted with the GRUB menu press the "down" arrow.

    2. Select the "Live 64-bit" option and press 'c' to enter the command
       line for GRUB. By default, the OS will be redirect the console to
       be ttyb which is fine for production but needs to be changed for
       COAL. While in the command line:

            grub> variable os_console vga

    3. Press 'ESC' to get back to the GRUB menu.

    4. Boot "Live 64-bit" by pressing 'enter'.

7. Configure the headnode. The setup process, in short, is as follows:

    - On first boot, you are interactively prompted for minimal configuration
      (e.g. datacenter name, company name, networking information). The
      configuration is saved and the server reboots.
    - On reboot, all SDC services are installed. Expect this to take around
      15-20 minutes.

   See [CoaL Setup](./docs/developer-guide/coal-setup.md) for the recommended
   prompt responses for new SDC developers or testers.

8. After setup is complete you should be able to SSH into your CoaL on the
   "admin" network. Example:

    ```bash
    ssh root@10.99.99.7  # password 'root'
    ```

For just a taste run `svcs` to see running [SMF
services](http://wiki.smartos.org/display/DOC/Using+the+Service+Management+Facility).
Run `vmadm list` to see a list of current VMs (SmartOS
[zones](http://wiki.smartos.org/display/DOC/Zones)). Each SDC service runs in
its own zone. See [the SDC operator guide](https://docs.joyent.com/sdc7).


### Installing SDC on a Physical Server

A SmartDataCenter server runs SmartOS, which is a "live image". That means that
it boots from a USB key. Installing SDC involves writing a "USB" build to
a physical USB key, inserting the key and booting the server from that key.
To install SDC, first obtain the latest release USB build.

#### Hardware

For SDC development only, the minimum server hardware is:
* 8 GB USB flash drive
* Intel Processors with VT-x and EPT support (all Xeon since Nehalem).
* 16 GB RAM
* 6 GB available storage. Hardware RAID is not recommended.
  SDC will lay down a ZFS ZPOOL across all available disks on install.
  You'll want much more storage if you're working with images and instances.

If setting up a SmartDataCenter pilot then you'll want to review
the [SDC7 Installation Prerequisites](https://docs.joyent.com/sdc7/sdc7-installation-prerequisites)
which include IPMI and at least 10 gigabit Ethernet. The supported hardware
components for SmartOS are described in the [SmartOS Hardware Requirements](http://wiki.smartos.org/display/DOC/Hardware+Requirements).
Joyent certified hardware for SmartDataCenter are all in
the [Joyent Manufacturing Database](http://eng.joyent.com/manufacturing/).


#### USB Key

During the private beta, download as follows:

```bash
# Get the Manta CLI tools (https://github.com/joyent/node-manta).
npm install -g manta

# Setup to use the Manta CLI tools as the 'joyager' user.
export MANTA_URL=https://us-east.manta.joyent.com
export MANTA_USER=joyager
export MANTA_KEY_ID=`ssh-keygen -l -f ~/.ssh/id_rsa.pub | awk '{print $2}' | tr -d '\n'`

# Find the latest build on the master branch and download it.
latest=$(mget -q /joyager/stor/builds/headnode/master-latest)
pkg=$(mls $latest/headnode | grep usb-)
echo "Downloading $latest/headnode/$pkg"
mget -O $latest/headnode/$pkg
```

When finally public the intention is to have the latest build here:

    curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/usb-latest.tgz

#### Install

Once you have downloaded an image, you will need to
[write it to a USB key](https://docs.joyent.com/sdc7/installing-sdc7/creating-a-usb-key-from-a-release-tarball),
boot the machine with it, and follow the install prompts. See the
[installing SDC 7](https://docs.joyent.com/sdc7/installing-sdc7) and
[install checklist](https://docs.joyent.com/sdc7/installing-sdc7/install-checklist)
documents for information.

After installation, you will probably want to perform some
[additional configuration](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration).
The most common of these include:

* [Adding external nics to the imgapi and adminui zones](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration#AddingExternalNICstoHeadNodeVMs)
  to give them internet access. This enables simple import of VM images.
* [Provision a cloudapi zone](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration#CreatingCloudAPI)
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
- Agents, which are bundled into a [single
  package](https://github.com/joyent/sdc-agents-installer)
  that can then be installed into the global zone of Compute Nodes.

Each component is built separately and then all are combined into CoaL and USB
builds (see the preceding sections) via the [sdc-headnode
repository](https://github.com/joyent/sdc-headnode). Built components are typically
stored in a [Manta object store](https://github.com/joyent/manta), e.g.
[Joyent's public Manta](https://www.joyent.com/products/manta), and pulled from
there. For example, Joyent's core builds push to
`/Joyent_Dev/public/builds` in Joyent's public Manta in us-east-1
(<https://us-east.manta.joyent.com/>).

You can build your own CoaL and USB on Mac or SmartOS (see the [sdc-headnode
README](https://github.com/joyent/sdc-headnode#readme)). However, all other
SDC components must be built using a running SDC (e.g. on the [Joyent Cloud](https://www.joyent.com/products/compute-service)
or in a local CoaL). See [the building
document](./docs/developer-guide/building.md) for details on building each of
the SDC components.


## Contributing

To report bugs or request features, submit issues to the [joyent/sdc
project](https://github.com/joyent/sdc/issues). If you're contributing code,
make a pull request to the appropriate repo (see [the repo
overview](./docs/developer-guide/repos.md)). If you're contributing something
substantial, you should contact developers on the [mailing list](TODO) or
[IRC](TODO) first.

For help or issues with the [Joyent
Cloud](https://www.joyent.com/products/compute-service) or production [Manta
service](https://www.joyent.com/products/manta), contact [Joyent Cloud customer
support](https://help.joyent.com/home) instead.

SDC repositories follow the
[Joyent Engineering
Guidelines](https://github.com/joyent/eng/blob/master/docs/index.restdown).
Notably:

* The #master branch should be first-customer-ship (FCS) quality at all times.
  Don't push anything until it's tested.
* All repositories should be `make check` clean at all times.
* All repositories should have tests that run cleanly at all times.

`make check` checks both JavaScript style and lint. Style is checked with
[jsstyle](https://github.com/davepacheco/jsstyle). The specific style rules are
somewhat repo-specific. Style is somewhat repo-specific. See the jsstyle
configuration file or `JSSTYLE_FLAGS` in Makefiles in each repo for exceptions
to the default jsstyle rules.

Lint is checked with
[javascriptlint](https://github.com/davepacheco/javascriptlint). ([Don't
conflate lint with
style!](http://dtrace.org/blogs/dap/2011/08/23/javascriptlint/)  There are gray
areas, but generally speaking, style rules are arbitrary, while lint warnings
identify potentially broken code. Repos sometimes have repo-specific lint
rules -- look for "tools/jsl.web.conf" and "tools/jsl.node.conf" for per-repo
exceptions to the default rules.


## Design principles

SmartDataCenter is very opinionated about how to architect a cloud. These
opinions are the result of many years of deploying and debugging the [Joyent
Cloud](https://www.joyent.com/products/compute-service). Design principles
include the following:

* A VM's primary storage should be a local disk, not over the network -- this
  avoids difficult to debug performance pathologies.
* Communication between internal APIs should occur in its own control plane
  (network) that is separate from the customer networks. Avoid communicating
  over the open Internet if possible.
* A provisioned VM should rely as little as possible on SDC services outside of
  the operating system for its normal operation.

The goals behind the design of SDC services include:

* All parts of the stack should be observable.
* The state of the running service should be simple to obtain.
* The internals of the system should make it straightfoward to debug from a
  core file (from a crash or taken from a running process using
  [gcore(1)](http://smartos.org/man/1/gcore))
* Services should be RESTful unless there is a compelling reason otherwise.
* Services should avoid keeping state and should not assume that there is
  only one instance of that service running. This allows multiple instances
  of a service to be provisioned for High Availability.
* Node.js and C should be used for new services.


## Dependencies and Related Projects

SmartDataCenter uses [SmartOS](https://smartos.org) as the host OS. The SmartOS
hypervisor provides both SmartOS zone (container) and KVM virtualization.

Joyent's open-source [Manta project](https://github.com/joyent/manta]
is an HTTP-based object store with built-in support to run arbitrary
programs on data at rest (i.e., without copying data out of the object store).
Manta runs on and integrates with SmartDataCenter.


## License

SmartDataCenter is licensed under the
[Mozilla Public License version 2.0](http://mozilla.org/MPL/2.0/).
SmartOS is [licensed separately](http://smartos.org/cddl/).
