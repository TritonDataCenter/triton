<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2021, Joyent, Inc.
-->

# Booting the Head Node from a ZFS Pool

A Triton Head Node can boot off of a ZFS pool, using its bootable filesystem
as an on-disk equivalent to the traditional USB-key.  The `sdc-usbkey`
command works on a disk-booting Triton Head Node nearly-identically to an
actual USB-key-booting head node.  (The ZFS bootable filesystem is
case-sensitive, unlike the USB key.)

A ZFS pool that is bootable SHOULD be created with `zpool create -B`.  You
can determine if a pool was created this way by querying the `bootsize`
parameter on the pool:

```
[root@headnode ~]# zpool get bootsize zones
NAME   PROPERTY  VALUE     SOURCE
zones  bootsize  256M      local
[root@headnode ~]# 
```

If a pool was not created with -B, it can still be bootable IF AND ONLY IF
the server is bootable with BIOS. One created with -B can be bootable by
both BIOS and EFI servers.

Not all pools can be bootable.  We suggest a simple disk set for a
ZFS-bootable Head Node.  Such sets include:

- Single disk.
- Two (mirrored) or more (raidz) same-sized disk.
- Two or more same-sized disk with a single SSD for a log device.

NOTE:  After installation a bootable pool can have log devices or log device
mirrors added.

## Installing a ZFS bootable Head Node

In addition to [regular network attachment and
configuration](https://docs.joyent.com/private-cloud/install/network-layout),
if you wish to start booting a Head Node from a ZFS pool you should attach
set of server disks per the introduction.  You should then use either an ISO
installation, or if the server is iPXE installable (e.g. a bare-metal cloud
provider), you should point at the HTTP/HTTPS-served contents of the iPXE
install tarball.

Future enhancements to the installer will allow for more flexibility in
installing for ZFS bootable Head Nodes.  For now, the set of disks on the
Head Node should be a simple set.

### For ISO Installations

The disks should be clean or otherwise unbootable.  The optical drive should
NOT be the first tried boot device (this is ESPECIALLY true for virtual
machines).  Also, the server (or virtual machine) should have at least two
VLANs or actual LANs associated with its ethernet port(s).  If you are
installing a disk-bootable CoaL, you can either follow the CoaL directions to
setup external and admin network, OR you may configure your own prior to
booting the ISO installer.

Make sure the Triton installation ISO is in the optical drive
(virtual or otherwise), and boot it.  Proceed to 

### For iPXE Installations

As with ISO installations, it is important that the boot order for the server
be the disks first, but the disks should not be bootable for the initial iPXE
installation.

An iPXE installation requires that iPXE web directory that allows a boot into
the Triton installer also be reachable by the configured-at-installation time
"external" network.  The iPXE web directory contains a copy of the larger ISO
contents, which cannot fit into an iPXE boot-archive/initrd.


## Converting from a USB-key (or from one bootable pool to another)

The [piadm(1M)
command](https://github.com/joyent/smartos-live/blob/master/man/usr/share/man/man1m/piadm.1m.md)
can be employed to transfer the current USB-key to a bootable ZFS pool.  It
can also be used to transfer boot contents from one pool to another.  If a
pool is not bootable, piadm(1M) will fail.

Select a POOL, and then issuing `piadm bootable -e POOL` will copy the USB
key contents on to a bootable pool and enable the pool to be bootable (if it
is bootable per the requirements above).
