<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2021, Joyent, Inc.
    Copyright 2022 MNX Cloud, Inc.
-->

# Booting the Head Node from a ZFS Pool

A Triton Head Node can boot off of a ZFS pool, using its bootable filesystem
as an on-disk equivalent to the traditional USB-key.  The `sdc-usbkey`
command works on a disk-booting Triton Head Node nearly-identically to an
actual USB-key-booting head node.  The only difference is that the ZFS
bootable filesystem is case-sensitive, unlike the USB key.

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

NOTE:  After installation a bootable pool can have log devices, log device
mirrors, or cache devices added.

## Installing a ZFS bootable Head Node

In addition to [regular network attachment and
configuration](https://docs.tritondatacenter.com/private-cloud/install/network-layout),
if you wish to start booting a Head Node from a ZFS pool you should attach a
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

Make sure the Triton installation ISO is in the optical drive (virtual or
otherwise), and boot it.  Proceed to follow the installation prompts per
[Installing Triton DataCenter](https://docs.tritondatacenter.com/private-cloud/install).

### For iPXE Installations

As with ISO installations, it is important that the disks are first in the
boot order, but the disks themselves should not be bootable at the time for
the initial iPXE installation.  It may be necessary to clear the disks of a
usable Master Boot Record or EFI partition prior to installation.

An iPXE installation requires that iPXE web directory that allows a boot into
the Triton installer also be reachable by the configured-at-installation time
"external" network.  The iPXE web directory contains a copy of the larger ISO
contents, which cannot fit into an iPXE boot-archive/initrd.


## Converting from a USB-key (or from one bootable pool to another)

The
[piadm](https://github.com/TritonDataCenter/smartos-live/blob/master/man/usr/share/man/man8/piadm.8.md)(8)
command can be employed to transfer the current USB-key to a bootable ZFS
pool.  It can also be used to transfer boot contents from one pool to
another.  If a pool is not bootable, piadm(1M) will fail.

Select a POOL, and then issue `piadm bootable -e POOL` to copy the USB key
contents on to a bootable pool and enable the pool to be bootable. If the
pool is not bootable per the requirements above, the piadm(1M) command will
fail.

## How Do I Know I'm Booting from a ZFS Pool?

For Triton Head Nodes, we set the boot parameter "triton_bootpool".  The
piadm(1M) command and other Triton components use that boot parameter to
determine the booted pool.

```
[root@headnode (testcloud) ~]# zpool list
NAME       SIZE  ALOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
bootpool    74G  3.60G  70.4G        -         -     0%     4%  1.00x  ONLINE  -
zones      928G   264G   664G        -         -    36%    28%  1.00x  ONLINE  -
[root@headnode (testcloud) ~]# piadm bootable
bootpool                       ==> BIOS and UEFI
zones                          ==> non-bootable
[root@headnode (testcloud) ~]# bootparams | grep triton_bootpool
triton_bootpool=botpool
[root@headnode (testcloud) ~]#
```
