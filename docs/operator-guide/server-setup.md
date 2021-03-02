<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2021, Joyent, Inc.
-->

# Introduction

This document describes the process of setting up a new Triton Compute Node
(CN). It assumes a healthy Triton installation and ignores the specifics of
actually physically setting up the hardware and booting it, but picks up at
the point where the new empty CN first boots.

## Overview

 * CN boots for the first time
 * booter/dhcpd adds to NAPI/CNAPI and responds to DHCPDISCOVER w/ DHCPOFFER
 * iPXE runs and downloads kernel, boot_archive and networking config
 * SmartOS boots
 * Ur Agent sends sysinfo to rabbitmq
 * CNAPI sees sysinfo and reloads data from the CN until it's setup
 * Operator tells CNAPI to setup CN
 * CNAPI starts server-setup job in workflow
 * server-setup downloads files to the CN
 * server-setup runs joysetup to create zpool and setup files
 * server-setup runs agentsetup to setup more files and install agents
 * agentsetup marks setup as complete on the CN
 * server-setup refreshes sysinfo
 * server-setup reboots the CN (if hostname was set) and waits for it to come
   back up
 * server-setup restarts Ur agent on CN
 * server-setup marks setup complete at CNAPI
 * Operator cheers

## First Boot

When a CN boots (whether by PXE, USB, or from disk) the first
interaction it will have with the Triton control plane will be via
DHCP. It will do a DHCPDISCOVER in order to attempt to learn its own
IP address. This DHCPDISCOVER is a broadcast message and the
booter/dhcpd service (usually dhcpd0 zone on the HN) will see this
message be responsible for handling it.

The [booter daemon](https://github.com/joyent/sdc-booter) takes the MAC address
from the DHCPDISCOVER request and checks NAPI to determine whether the NIC exists
yet or not. In this case on first boot of a new CN there will be no entry, so the
next step for booter is to create a record in NAPI. It creates a new "nic" object
with the "state" field set to "provisioning". This record will look something like:

```
[root@headnode (coal) ~]# sdc-napi /nics?belongs_to_uuid=930896af-bf8c-48d4-885c-6573a94b1853 | json -H
[
  {
    "belongs_to_type": "other",
    "belongs_to_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
    "mac": "00:0c:29:e9:7b:8f",
    "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
    "primary": false,
    "state": "provisioning",
    "ip": "10.192.0.43",
    "mtu": 1500,
    "netmask": "255.192.0.0",
    "nic_tag": "admin",
    "resolvers": [
      "10.192.0.11"
    ],
    "vlan_id": 0,
    "network_uuid": "764ed3b2-4d47-4cf1-977a-b57f9c02d92e",
    "nic_tags_provided": [
      "admin"
    ]
  }
]
[root@headnode (coal) ~]#
```

You can see here that this NIC was provisioned with an IP on the admin network.
Importantly, we assume that the NIC that is doing DHCP is the admin network.
This generally must be true because no other NICs should be able to broadcast
the DHCPDISCOVER onto the admin network.

Whether this is a new CN or not, at this point (after a DHCPDISCOVER) we'll
query CNAPI to get the bootparams for this server. In this case the query is
equivalent to:

```
[root@headnode (coal) ~]# sdc-cnapi /boot/930896af-bf8c-48d4-885c-6573a94b1853 | json -H
{
  "code": "ResourceNotFound",
  "message": "Server 930896af-bf8c-48d4-885c-6573a94b1853 not found"
}
[root@headnode (coal) ~]#
```

This is the case because we don't have any special boot parameters for this
server. As such, it does a second query to grab the default boot parameters
and uses those instead:

```
[root@headnode (coal) ~]# sdc-cnapi /boot/default | json -H
{
  "platform": "20160517T105654Z",
  "kernel_args": {
    "rabbitmq": "guest:guest:10.192.0.20:5672",
    "rabbitmq_dns": "guest:guest:rabbitmq.coal.joyent.us:5672"
  },
  "kernel_flags": {},
  "boot_modules": [],
  "default_console": "serial",
  "serial": "ttyb"
}
[root@headnode (coal) ~]#
```

These boot parameters and the network information that came from the request
and was added to NAPI are then used to generate a few files in the DHCP zone:

```
[root@223e92e3-233b-499d-8093-2715c686a398 (coal:dhcpd0) ~]# cat /tftpboot/bootfs/000c29e97b8f/networking.json
{
  "nictags": [
    {
      "mtu": 1500,
      "name": "admin",
      "uuid": "eae42557-f7df-4efc-a1a1-62dfdfe46382",
      "mac": "00:0c:29:e9:7b:8f"
    }
  ],
  "resolvers": [
    "10.192.0.11"
  ],
  "routes": {},
  "vnics": [
    {
      "belongs_to_type": "other",
      "belongs_to_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
      "mac": "00:0c:29:e9:7b:8f",
      "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
      "primary": false,
      "state": "provisioning",
      "ip": "10.192.0.43",
      "mtu": 1500,
      "netmask": "255.192.0.0",
      "nic_tag": "admin",
      "resolvers": [
        "10.192.0.11"
      ],
      "vlan_id": 0,
      "network_uuid": "764ed3b2-4d47-4cf1-977a-b57f9c02d92e",
      "nic_tags_provided": [
        "admin"
      ]
    }
  ],
  "dns_domain": "joyent.us",
  "aggregations": []
}
[root@223e92e3-233b-499d-8093-2715c686a398 (coal:dhcpd0) ~]# cat /tftpboot/cache/00:0c:29:e9:7b:8f.json
{
  "platform": "20160517T105654Z",
  "kernel_args": {
    "rabbitmq": "guest:guest:10.192.0.20:5672",
    "rabbitmq_dns": "guest:guest:rabbitmq.coal.joyent.us:5672",
    "admin_nic": "00:0c:29:e9:7b:8f"
  },
  "kernel_flags": {},
  "boot_modules": [],
  "default_console": "serial",
  "serial": "ttyb",
  "ip": "10.192.0.43",
  "netmask": "255.192.0.0",
  "resolvers": [
    "10.192.0.11"
  ]
}
[root@223e92e3-233b-499d-8093-2715c686a398 (coal:dhcpd0) ~]# cat /tftpboot/boot.ipxe.01000C29E97B8F
#!ipxe
kernel tftp://${next-server}/os/20160517T105654Z/platform/i86pc/kernel/amd64/unix -B rabbitmq=guest:guest:10.192.0.20:5672,rabbitmq_dns=guest:guest:rabbitmq.coal.joyent.us:5672,admin_nic=00:0c:29:e9:7b:8f,console=ttyb,ttyb-mode="115200,8,n,1,-"
module tftp://${next-server}/os/20160517T105654Z/platform/i86pc/amd64/boot_archive type=rootfs name=ramdisk
module tftp://${next-server}/os/20160517T105654Z/platform/i86pc/amd64/boot_archive.hash type=hash name=ramdisk
module tftp://${next-server}/bootfs/000c29e97b8f/networking.json type=file name=networking.json
module tftp://${next-server}/bootfs/000c29e97b8f/networking.json.hash type=file name=networking.json.hash
boot
[root@223e92e3-233b-499d-8093-2715c686a398 (coal:dhcpd0) ~]# cat /tftpboot/menu.lst.01000C29E97B8F
default 0
timeout 5
min_mem64 1024
variable os_console ttyb
serial --unit=1 --speed=115200 --word=8 --parity=no --stop=1
terminal composite
color cyan/blue white/blue

title Live 64-bit
  kernel$ /os/20160517T105654Z/platform/i86pc/kernel/amd64/unix -B rabbitmq=guest:guest:10.192.0.20:5672,rabbitmq_dns=guest:guest:rabbitmq.coal.joyent.us:5672,admin_nic=00:0c:29:e9:7b:8f,console=${os_console},${os_console}-mode="115200,8,n,1,-"
  module$ /os/20160517T105654Z/platform/i86pc/amd64/boot_archive type=rootfs name=ramdisk
  module$ /os/20160517T105654Z/platform/i86pc/amd64/boot_archive.hash type=hash name=ramdisk
  module$ /bootfs/000c29e97b8f/networking.json type=file name=networking.json
  module$ /bootfs/000c29e97b8f/networking.json.hash type=file name=networking.json.hash

title Live 64-bit +kmdb
  kernel$ /os/20160517T105654Z/platform/i86pc/kernel/amd64/unix -d -k -B rabbitmq=guest:guest:10.192.0.20:5672,rabbitmq_dns=guest:guest:rabbitmq.coal.joyent.us:5672,admin_nic=00:0c:29:e9:7b:8f,console=${os_console},${os_console}-mode="115200,8,n,1,-"
  module$ /os/20160517T105654Z/platform/i86pc/amd64/boot_archive type=rootfs name=ramdisk
  module$ /os/20160517T105654Z/platform/i86pc/amd64/boot_archive.hash type=hash name=ramdisk
  module$ /bootfs/000c29e97b8f/networking.json type=file name=networking.json
  module$ /bootfs/000c29e97b8f/networking.json.hash type=file name=networking.json.hash

title Live 64-bit Rescue (no importing zpool)
  kernel$ /os/20160517T105654Z/platform/i86pc/kernel/amd64/unix -B rabbitmq=guest:guest:10.192.0.20:5672,rabbitmq_dns=guest:guest:rabbitmq.coal.joyent.us:5672,admin_nic=00:0c:29:e9:7b:8f,noimport=true,console=${os_console},${os_console}-mode="115200,8,n,1,-"
  module$ /os/20160517T105654Z/platform/i86pc/amd64/boot_archive type=rootfs name=ramdisk
[root@223e92e3-233b-499d-8093-2715c686a398 (coal:dhcpd0) ~]#
```

The:

 * networking.json file is downloaded and mounted using the [bootfs modules](http://dtrace.org/blogs/wesolows/2013/12/28/anonymous-tracing-on-smartos/)
 * cache/00:0c:29:e9:7b:8f.json file is saved for the case where the APIs (NAPI
   and/or CNAPI) are down later when we're trying to boot.
 * boot.ipxe.01000C29E97B8F file is used by iPXE
 * menu.lst.01000C29E97B8F file is used by pxegrub

If the CN is configured to boot with iPXE, the next step will be to download
iPXE itself via tftpd (also running in the dhcpd0 zone on the HN). The
instructions telling the system to do this will be included in the
DHCPOFFER message that booter returns as a result of the DHCPDISCOVER.

In this case the DHCPDOFFER message looks like (from the booter log):

```
[2016-05-28T06:17:39.833Z]  INFO: dhcpd/13726 on 223e92e3-233b-499d-8093-2715c686a398: built packet opts: message type="DHCPDISCOVER", response type="DHCPOFFER" (req_id=d9e7e85a-c59a-49bb-a105-928331c062b3, mac=00:0c:29:e9:7b:8f)
    packetOpts: {
      "siaddr": "10.192.0.9",
      "yiaddr": "10.192.0.43",
      "file": "undionly.kpxe",
      "options": {
        "1": "255.192.0.0",
        "6": [
          "10.192.0.11"
        ],
        "51": 2592000,
        "53": "DHCPOFFER",
        "54": "10.192.0.9"
      }
    }
```

which tells this CN that its IP is 10.192.0.43 and that it should download the
undionly.kpxe file from 10.192.0.9 (which is dhcpd0 in this case). It also
contains information on the DNS server to use (in this case 10.192.0.11). This
DHCPOFFER is broadcast back to the MAC address that sent the DHCPDISCOVER which
in this case is our new CN.

After the CN downloads and runs the iPXE, iPXE will make a DHCPREQUEST in order
to get the data it needs to boot the system. At this point booter will make
another set of requests to NAPI and CNAPI. The results at CNAPI will be the same
but this time it will find the NIC info already in NAPI and not need to create
a new NIC object. Booter will then send a DHCPACK response to this DHCPREQUEST
with the same info that was in the DHCPOFFER it sent as a response to the
DHCPDISCOVER.

The instructions we'll send iPXE (detailed in boot.ipxe.01000C29E97B8F in the
output above) will tell the iPXE to download the kernel, the boot_archive and
the networking.json file that was generated for this CN. iPXE will download
all of these files over tftp from the dhcp0 zone and then boot the server
using the cmdline option specified in this boot.ipxe.01<MAC> file.

At that point the CN will boot up SmartOS and configure its network to match
the settings that it has been passed.

When SmartOS boots, the [Ur Agent](https://github.com/joyent/sdc-ur-agent) is
started. This agent [sends a message](https://github.com/joyent/sdc-ur-agent/blob/release-20160526/ur-agent#L211-L238)
that includes its sysinfo to a rabbitmq queue. The CNAPI service listens for
these rabbitmq messages and when it sees a new CN it adds a record to its
moray bucket and starts a new ['server-sysinfo' workflow
job](https://github.com/joyent/sdc-cnapi/blob/release-20160526/lib/workflows/server-sysinfo.js)
targeted at that server. This workflow ensures that NAPI's NIC information is up-to-date.
As of 2016-05-31 a job server-sysinfo workflow will be run every minute until
that CN is setup.

To this point, the only thing the operator has done is booted the new CN. There
is no intervention required otherwise to get to this point and the CN is now
running SmartOS and has a record in CNAPI (/servers/<uuid>) and its NICs are
registered in NAPI. The next step is to perform the actual server setup, which
*does* require the Operator to press the button.

## Server Setup

A CN that has been booted but not yet setup, will still exist in CNAPI (see
the previous section for details on how that works) but cannot be used for
provisioning until it has be setup. You can tell on a server whether it has
been setup either looking at the SETUP column of `sdc-server list`:

```
[root@headnode (coal) ~]# sdc-server list
HOSTNAME             UUID                                 VERSION    SETUP    STATUS      RAM  ADMIN_IP
00-0c-29-e9-7b-8f    564dd681-2326-3f07-82ba-e010ebe97b8f     7.0    false   running     1047  10.192.0.43
headnode             564dfd57-1dd4-6fc0-d973-4f137ee12afe     7.0     true   running     6143  10.192.0.7
[root@headnode (coal) ~]#
```

or by looking at the "setup" field on the server object in CNAPI:

```
[root@headnode (coal) ~]# sdc-cnapi /servers/564dd681-2326-3f07-82ba-e010ebe97b8f | json -H setup
false
[root@headnode (coal) ~]#
```

In order to setup a server, the operator must execute the
[ServerSetup](https://github.com/joyent/sdc-cnapi/blob/release-20160526/docs/index.md#serversetup-put-serversserver_uuidsetup)
endpoint in CNAPI. Mechanisms that calling this include:

 * adminui
 * sdc-cnapi
 * `sdc-server setup <uuid>`

In this example I'll use `sdc-server -s setup` which just calls that endpoint
and waits for the job to complete. To do this I ran:

```
[root@headnode (coal) ~]# sdc-server setup -s 564dd681-2326-3f07-82ba-e010ebe97b8f
Job(14896857-1cd1-404f-8fd0-ba34d3da30a6) - 322.1s - completed successfully
[root@headnode (coal) ~]#
```

What happens behind the scenes here is that the CNAPI endpoint is called which
then creates a [server-setup job](https://github.com/joyent/sdc-cnapi/blob/release-20160526/lib/workflows/server-setup.js).
This job then:

 * grabs the NICs from NAPI
 * sets up nic tags
 * marks the server as setting_up: true
 * downloads: node.config, [joysetup.sh](https://github.com/joyent/sdc-headnode/blob/release-20160526/scripts/joysetup.sh), [agentsetup.sh](https://github.com/joyent/sdc-headnode/blob/release-20160526/scripts/agentsetup.sh) on the CN from <ASSETS>

where <ASSETS> is the admin IP of the assets zone. The files at this point are
downloaded using a small shell script:

 https://github.com/joyent/sdc-cnapi/blob/release-20160526/lib/workflows/server-setup.js#L86-L98

that is executed via the CNAPI [CommandExecute endpoint](https://github.com/joyent/sdc-cnapi/blob/release-20160526/docs/index.md#commandexecute-post-serversserver_uuidexecute)
which talks to the Ur Agent on this CN. The downloaded scripts are also executed
through this CommandExecute endpoint in CNAPI (from /var/tmp). First joysetup.sh
then the agentsetup.sh.

On a CN the [joysetup.sh script](https://github.com/joyent/sdc-headnode/blob/release-20160526/scripts/joysetup.sh) is responsible for:

 * setting up ntp
 * using /usr/bin/disklayout to generate a layout for the zpool
 * checking that the system has at least 2x disk:DRAM ratio
 * creating the zones zpool and default filesystems
 * creating the /var/lib/setup.json file and updating info about setup progress
 * creating the swap dataset
 * reloading the networking and fixing resolv.conf
 * setting up imgadm to use the DC's imgapi

Once that's complete, the server-setup job will run the [agents setup
script](https://github.com/joyent/sdc-headnode/blob/release-20160526/scripts/agentsetup.sh)
which:

 * downloads and installs /extra/joysetup/cn_tools.tar.gz from assets
 * updates the USB key's iPXE (if it has a USB key)
 * installs the agents in /opt/smartdc/agents
 * marks the CN as setup in /var/lib/setup.json

once this is complete, the server-setup job does any additional NIC tag changes
that are required, then marks the CN as:

```
setup: true
setting_up: false
```

and the setup is complete. The CN should at this point be ready to be part of
the fleet.

There are a few more things that server-setup does worth noting that happen
after the 'setup: true' step. One of these is that it restarts the Ur agent on
the CN. It does this because up to this point Ur will have been logging to
/etc/svc/volatile since there was no zpool. Restarting the agent causes it to
reopen the log in /var/svc/log on restart.

Another thing that's done post-setup while still in the server-setup job, is
to reload the sysinfo. This is done from the cnapi.refresh_server_sysinfo task
which calls /servers/<uuid>/sysinfo-refresh which loads the latest sysinfo from
the CN (including the 'setup: true' value set earlier).

It's also possible that server-setup will reboot the CN after setup is complete.
This is necessary if the operator has specified a hostname for this CN as part
of their setup payload. In this case we need to reboot the CN in order that
everything can come up correctly with the new hostname. The next task after the
reboot (if reboot was required) will be to wait for the reboot to complete.


## Debugging

If the CN is having trouble booting, the svc:/smartdc/application/dhcpd:default
log file in the dhcpd zone is usually the best place to start. It can tell you
what DHCP requests have been seen for the CN and many other details about the
boot process.

If things fail after that, you'll probably need to look at some combination of:

 * The cnapi service log in the CNAPI zone
 * The ur-agent log on the CN
 * The boot parameters for the CN (from CNAPI)
 * The server-setup job (from workflow)
 * The /opt/smartdc/config/node.config file on the CN
 * The /var/log/joysetup.log file on the CN
 * The /var/log/agent-setup.log file on the CN
 * The /var/lib/setup.json file on the CN
 * The /tmp/joysetup.<PID> log file on the CN (if it failed before going to /var/log/joysetup.log)
 * /etc/svc/volatile/system-filesystem-smartdc\:default.log on the CN
 * /etc/svc/volatile/system-smartdc-config\:default.log on the CN
 * The /var/tmp/joysetup.sh script
 * The /var/tmp/agentsetup.sh script
 * `zpool status`
 * `diskinfo`

depending where the problem occurred.

## Common Problems

One common failure mode in test setups is invalid NTP configuration. The
joysetup script attempts to setup NTP and if you haven't specified NTP servers
that work, the ntpdate command it runs will timeout.

Another common failure mode is to have the joysetup.sh script fail due to a
pre-existing zpool on the disks. When this happens often the server-setup
plows forward and the agentsetup fails. If you see a failure, it's always a
good idea to check the status of the zpool early in the debugging process.

## iPXE booting Compute Nodes

In some situations, such as a Bare-Metal-as-a-Service (BMaaS) provider, they
may have instances that by default only network boot on one network
interface, and it may not be the one a Triton installation has configured as
the `admin` network.  Often times, these single-network-interfaces default to
an iPXE boot if it can network boot at all.

A suggested course of action in these situations is to, if possible, ALWAYS
boot using iPXE, but chainloading into a Triton Compute Node boot.

As mentioned in the [iPXE installer](../developer-guide/iso-installer.md),
one will need to setup an iPXE server in these situations.  Unlike the triton
installer, there is no tar archive readily available.  The directory,
however, needs only three files.


### An initial .ipxe instruction file.

This file should be inserted into `triton-cn.ipxe`:

```
#!ipxe
set base-url https://example.com/triton-cn-ipxe
kernel ${base-url}/ipxe.lkrn
module ${base-url}/default-no0.ipxe
boot
```

And the URL for the BMaaS iPXE should be, in this example,
`https://example.com/triton-cn-ipxe/triton-cn.ipxe`.  There are two other
files mentioned in this, and those are what we need as well.

### An iPXE binary

In a head node, the file `/opt/smartdc/share/usbkey/contents/boot/ipxe.lkrn`
exists, and is the Triton-special iPXE binary that a Triton Compute Node
normally boots into either off of a USB key or off of a BIOS PXE chainload.
For a BMaaS compute node that can only network-boot from the BMaaS iPXE, it
will have to chain load into this one.

### The Triton-specific iPXE instruction file

In this example, we name it `default-no0.ipxe`, and it is designed to bypass
at least the primary NIC on the compute node when trying to reach the Triton
Head Node DHCP server.

Some BMaaS providers set `net2` as the primary, because of possible
dissatisfaction with the on-board NICs, and the desire to use a well-tested
PCIe NIC instead.  It is important to know which NICs to skip.  In the
following example `default-no0.ipxe` file we skip both `net0` and `net2`.

```
# Skip BMaaS configuration NICs and instead locate the Triton ADMIN network.

ifstat

# Skip net0 and net2
dhcp net1 && autoboot net1 ||
dhcp net3 && autoboot net3 ||
dhcp net4 && autoboot net4 ||
dhcp net5 && autoboot net5 ||
dhcp net6 && autoboot net6 ||
dhcp net7 && autoboot net7
```

All three files should be in the iPXE web server directory.
