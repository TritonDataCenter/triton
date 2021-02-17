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
