<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2021, Joyent, Inc.
-->

# Triton iPXE Installation

Some deployments, for example on to a Bare-Metal as a Service (BMaaS)
provider, may use single-shot iPXE boots to install an operating system.

The Triton iPXE installer behaves much like the [ISO
installer](./docs/developer-guide/iso-installer.md) in that it should boot
once, and during the reboot mid-installation the on-disk portion should take
over.  It is important that the iPXE Triton boot happen only once for a head
node installation.

Unlike the ISO installer, the iPXE installation requires that network
reachability be enabled DURING the installation process.  The installer
script will post a reminder of this.  Most of the time, the iPXE installer
needed network reachability to start in the first place, so configuring the
head node to reach the iPXE downloads should not be difficult.  The network
is required to be able to download images that are normally on the ISO DVD
image for the ISO installer, but cannot fit into an iPXE ramdisk root.

## Configuring an iPXE Server for a Triton Installation

A Triton iPXE server needs to be populated so iPXE can pull via HTTP what it
needs to boot the Triton installer and actually perform the installation.  We
provide a [tar
archive](https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/ipxe-latest.tgz)
that can be installed on a web server that an iPXE client can reach.

The `triton-installer.ipxe` file will need modifications in its `testdomain`
and `base-url` variables to match your deployment.  If your iPXE webserver is
ipxe.example.com, and its directory URL is https://ipxe.example.com/triton,
you would have these lines in triton-installer.ipxe:

```
	set testdomain ipxe.example.com
	set base-url https://ipxe.example.com/triton
```

**NOTE** - The `testdomain` must allow ICMP echo requests and respond to them
(aka. pings) so the installer can confirm reachability.

The tar archive also includes a full tar archive of the [ISO
installer](./docs/developer-guide/iso-installer.md) contents because an iPXE
ramdisk image is not large enough to hold all of the Triton images required
for an installation, and the iPXE installer must download the images after it
has booted.

Using the example server above, once it has been setup, an iPXE client should
access `https://ipxe.example.com/triton/triton-installer.ipxe` to install the
Triton head node.
