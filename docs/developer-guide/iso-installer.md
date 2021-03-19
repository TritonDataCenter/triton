<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2021, Joyent, Inc.
-->

# Triton ISO Installation

If one wishes to boot off a ZFS pool, one can use the Triton ISO installer to
boot once off of DVD-ROM, and on subsequent boots, boot off of a bootable
`zones` ZFS pool.

The ISO installer can be used in a virtual machine environment, in lieu of
[CoaL](./docs/developer-guide/coal-setup.md), as well.  Be sure to download
the [ISO
image](https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/iso-latest.iso)
and follow the main README. 

## Minimum Requirements

The ISO installer requires more disk space than a USB-key Triton deployment,
but is otherwise the same.

- Intel Processors with VT-x and EPT support (all Xeon since Nehalem), or AMD Processors no earlier than EPYC or Zen. 
- 16 GB RAM
- 60 GB available storage

See the [main README's Physical Server
section](https://github.com/joyent/triton/tree/TRITON-2202#installing-triton-on-a-physical-server)
for more details

## Disk/Pool Requirements

See [Booting the Head Node from a ZFS
Pool](https://github.com/joyent/triton/blob/TRITON-2202/docs/developer-guide/zpool.md)
for details about how to properly set up a ZFS pool that is bootable.

## Boot-device Requirements

It is important that the Triton ISO installer is only booted once.  Part of
the Triton installation process is to reboot a second time, which in the case
of the ISO installer must be to the boot disks.  The best way to configure
this is to have hard drives first in the boot order, followed by the DVD
drive later in the boot order.  On a fresh installation, it will boot the
installer ISO, but subsequent reboots will boot from the disk.
