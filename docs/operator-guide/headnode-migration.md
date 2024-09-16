# Headnode hardware migration

The purpose of this document is to aid hardware migration scenarios for the SDC
headnode server. By following the steps outlined below it should be possible to
migrate all headnode services and the full headnode installation to new hardware.

This document assumes a fully working SDC HA setup.

**Terminology**
  * "old headnode" - original HW asset from which we intend to migrate away
  * "new headnode" - new HW asset to which we intend to move all headnode services
  * SDC HA setup - [highly available SDC deployment](https://docs.joyent.com/private-cloud/resilience)

**Assumptions**
  * SDC setup is 100% healthy
  * SDC was deployed in a highly available fashion (HA setup)
  * new headnode has sufficient disk space, DRAM, CPU's, network interfaces
  * new headnode has direct SSH connectivity to old headnode
  * physical access to new headnode
  * sufficient maintenance window

**Desired end result**
  * minimal headnode downtime
  * all SDC services migrated to new headnode
  * fully operational SDC setup after migration

**Impact**

For the duration of the migration process:

  * VM provisioning and configuration changes will be unavailable
  * no operator access via "adminui"
  * smartlogin root login will be unavailable to SmartOS zones

**Rollback option**
  * reconnect old headnode to the SDC cluster

## Preparing the new headnode

**Requirements:**
  * IPMI serial over lan (optional)
  * headnode to headnode connectivity
  * SmartOS USB image
  * USB key/thumb drive

Before we can start the migration process the new hardware asset needs to be booted up
into a SmartOS rescue mode.

### Download latest SmartOS USB image

Download latest USB media image:

```
curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/usb-latest.tgz
```

Untar tarball and create a USB bootable image:
(SmartOS specific `dd` command)

```
dd if=usb-release-20150625-20150625T153756Z-gcc5a03f-4gb.img of=/dev/rdsk/c3t0d0p0 bs=4096b
```

More details on how to write a [bootable usb media image](https://docs.joyent.com/private-cloud/install/usb-key)

Don't forget to note down the root password for the USB image (will be required later).

*Hint: the root password is included with each USB image in the downloaded tarball in a text file*
*called root.password.RELEASE, example:* `root.password.20150625t055518z`

### Boot up new headnode

Boot up USB media and from the GRUB menu select:

**Live 64-bit Rescue (no importing zpool)**

GRUB menu:

```
    GNU GRUB  version 0.97  (619K lower / 1983696K upper memory)

 ***************************************************************************
 * Compute Node (PXE)                                                      *
 * Live 64-bit                                                             *
 * Live 64-bit (rollback to 20150617T074149Z)                              *
 * Live 64-bit Rescue (no importing zpool)                                 *
 * Live 64-bit +kmdb                                                       *
 * Legacy Firmware Upgrade Mode                                            *
 *                                                                         *
 *                                                                         *
 *                                                                         *
 *                                                                         *
 *                                                                         *
 *                                                                         *
 ***************************************************************************
      Use the * and * keys to select which entry is highlighted.
      Press enter to boot the selected OS, 'e' to edit the
      commands before booting, or 'c' for a command-line.

      Selected OS console device is 'ttyb'.

      and use 'variable os_console <dev>', then Esc to return.
      Valid <dev> values are: ttya, ttyb, ttyc, ttyd, vga
```

Once the boot process finished the following login screen should be visible:

```
             _____
          ____   ____
         _____   _____        .                   .
         __         __        | .-. .  . .-. :--. |-
         _____   _____        ;|   ||  |(.-' |  | |
          ____   ____     `--'  `-' `;-| `-' '  ' `-'
             _____                  /  ; Joyent Live Image v0.147+
                                    `-'   build: 20150625T055518Z

headnode ttyb login:
```

Login as user root with the root password specified in `root.password.RELEASE`
text file (mentioned earlier).

### Create zpool

Once logged in as user root proceed with setting up the ZFS storage pool.

*(For additional details please consult `zpool(1M)`)*

Create a new ZFS storage pool called `zones` with *raidz* redundancy.

example:

`zpool create zones raidz c0t13d1 c0t14d1 c0t15d1 c0t16d1`

Verify new storage pool with: `zpool list` and `zpool status`

### Prepare network connectivity between headnode servers

This can be a dedicated cable on spare interfaces or connect the new headnode to
the "SDC admin" network and configure a unique IP address.

The following examples assume a dedicated cable connected to spare interfaces.

#### On the new headnode

Check whether the link is up:

```
dladm show-link
LINK        CLASS     MTU    STATE    BRIDGE     OVER
bnx0        phys      1500   down     --         --
bnx1        phys      1500   up       --         --
```

Configure the interface:
(bnx1 in this example)

```
ifconfig bnx1 plumb up
ifconfig bnx1 192.168.10.1/24 up
```

Start SSH server on new headnode: `/lib/svc/method/sshd start`
(svcadm will not start it in recovery mode)

#### On the old headnode

Connect cable and check link status:

```
dladm show-link
LINK        CLASS     MTU    STATE    BRIDGE     OVER
igb0        phys      1500   up       --         --
igb1        phys      1500   up       --         --
igb2        phys      1500   up       --         --
igb3        phys      1500   down     --         --
```

Configure the interface:
(igb2 in this example)

```
ifconfig igb2 plumb up
ifconfig igb2 192.168.10.2/24 up
```

Ping the new headnode IP address:

```
ping 192.168.10.1
192.168.10.1 is alive
```

## Check SDC health

Verify whether SDC is healthy:

```
sdcadm check-health
sdc-healthcheck
```

In case of any issues, please resolve those first, then proceed with the migration.

## Migrate all zones to new headnode

Create a screen session first with `screen(1)`.

Stop all zones on old headnode:

```
for zone in `vmadm list -H -o uuid`; do vmadm stop $zone; done
```

Create ZFS snapshot:

`zfs snapshot -r zones@$(date +%Y-%m-%d)`

Send ZFS stream to new box:
(this is where the saved root password will be required again)

`zfs send -vR zones@2015-07-22 | ssh 192.168.10.1 "zfs recv -F zones"`

## Take a backup of old headnode's configuration

Copy `/usbkey/config` file from old to new headnode into `/var/tmp/`.

## Take a backup of the old headnode's USB media (optional step)

Look up removable USB media with: `rmformat`

```
Looking for devices...
     1. Logical Node: /dev/rdsk/c1t0d0p0
        Physical Node: /pci@0,0/pci15d9,844@1a/hub@1/storage@6/disk@0,0
        Connected Device: SRT      POLLEX 4G        1100
        Device Type: Removable
        Bus: USB
        Size: 3.8 GB
        Label: <Unknown>
        Access permissions: <Unknown>
```

Unmount media first: `umount /mnt/usbkey`

Change directory: `cd /var/tmp`

Take an image of the USB media:

```
dd if=/dev/rdsk/c1t0d0p0 of=headnode-usb.img bs=1M
3840+0 records in
3840+0 records out
4026531840 bytes transferred in 232.360918 secs (17328783 bytes/sec)
```

Copy the USB image onto the new headnode into /zones

`scp headnode-usb.img 192.168.10.1:/zones`

## Restore USB image onto new headnode (optional step)

```
rmformat
Looking for devices...
     1. Logical Node: /dev/rdsk/c1t0d0p0
        Physical Node: /pci@0,0/pci1014,3a3a@1d,7/storage@4/disk@0,0
        Connected Device: SRT      POLLEX 4G        1100
        Device Type: Removable
	Bus: USB
	Size: 3.8 GB
	Label: <Unknown>
	Access permissions: <Unknown>
```

Unmount media first: `umount /mnt/usbkey`

inside `screen(1)` session run:

```
dd if=headnode-usb.img of=/dev/rdsk/c1t0d0p0 bs=1M
3840+0 records in
3840+0 records out
4026531840 bytes transferred in 896.871548 secs (4489530 bytes/sec)
```

## Correcting new headnode configuration

Mount first partition onto /mnt/usbkey

`mount -F pcfs -o foldcase,noatime /dev/dsk/c1t0d0p1 /mnt/usbkey`

Change directory to /mnt/usbkey: `cd /mnt/usbkey`

Restore the old headnode configuration with: `cp /var/tmp/config /mnt/usbkey/config`

Edit the configuration file with: `vi config`

Correct the admin_nic mac address to reflect the new node's mac address

Check the correct mac address with `ifconfig`

```
ifconfig

lo0: flags=2001000849<UP,LOOPBACK,RUNNING,MULTICAST,IPv4,VIRTUAL> mtu 8232 index 1
        inet 127.0.0.1 netmask ff000000
bnx0: flags=1000802<BROADCAST,MULTICAST,IPv4> mtu 1500 index 2
        inet 192.168.10.1 netmask ffffff00 broadcast 192.168.10.255
        ether 5c:f3:fc:e3:e7:b0
bnx1: flags=1000943<UP,BROADCAST,RUNNING,PROMISC,MULTICAST,IPv4> mtu 1500 index 4
        inet 192.168.10.1 netmask ffffff00 broadcast 192.168.10.255
        ether 5c:f3:fc:e3:e7:b2
lo0: flags=2002000849<UP,LOOPBACK,RUNNING,MULTICAST,IPv6,VIRTUAL> mtu 8252 index 1
        inet6 ::1/128
```

In this instance the admin network is physically connected to bnx0.

Corrected admin_nic entry below:

```
# admin_nic is the nic admin_ip will be connected to for headnode zones.
admin_nic=5c:f3:fc:e3:e7:b0
admin_ip=10.11.11.1
admin_netmask=255.255.255.0
admin_network=10.11.11.0
```

Correct the external_nic mac address (in this example interface bnx1).

Corrected external_nic entry below:

```
# external_nic is the nic external_ip will be connected to for headnode zones.
external_nic=5c:f3:fc:e3:e7:b2
external_ip=192.168.1.50
external_gateway=192.168.1.1
external_netmask=255.255.255.0
```

Repeat the same steps to correct any other network interfaces in the config file and save.

## Shut down old headnode and reboot new headnode

At this point shut down the old headnode.

Reboot the new headnode and after the reboot verify its network configuration with `ifconfig` and
the status of services with: `svcs -xv`

In case of any issues please resolve those first before starting the zones.

This is a good time to verify whether the default gateway and admin network CN (compute) nodes are responding to pings.

## Start all zones on new headnode

Start all zones with:

```
for zone in `vmadm list -H -o uuid` ; do vmadm start $zone ; done
```

## Verify SDC health

At this point check SDC health with `sdc-healthcheck` and `sdcadm check-health`.

These will report various errors. This is expected as NAPI needs corrections.

Run `sdc-server list` to check for servers - note down the UUID of the old headnode and new headnode.

## Fixing NAPI entries

Verify the old headnode admin IP address:

```
curl -X GET http://napi.lab.local/networks/62a95100-8021-4210-8d1d-19f43b0d5d22/ips/10.11.11.1|json
{
  "ip": "10.11.11.1",
  "reserved": false,
  "free": false,
  "belongs_to_type": "server",
  "belongs_to_uuid": "ff4cac1a-fe98-11e0-acf9-5cf3fce3e7b0",
  "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
  "network_uuid": "62a95100-8021-4210-8d1d-19f43b0d5d22"
}
```

The IP address is still owned by the old headnode's UUID.

Unassign IP address for later assignment:

```
curl -X PUT http://napi.lab.local/networks/62a95100-8021-4210-8d1d-19f43b0d5d22/ips/10.11.11.1 -d unassign=true`
```

Fix external IP address ownership:

```
curl -X GET http://napi.lab.local/networks/62a95100-8021-4210-8d1d-19f43b0d5d22/ips/192.168.1.50|json
{
  "ip": "192.168.1.50",
  "reserved": false,
  "free": false,
  "belongs_to_type": "server",
  "belongs_to_uuid": "00000000-0000-0000-0000-002590fde488",
  "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
  "network_uuid": "e7753a91-b53a-48fc-990a-fdd86ed06c6c"
}
```

Assign ownership to new headnode UUID:

```
curl -X PUT http://napi.lab.local/networks/e7753a91-b53a-48fc-990a-fdd86ed06c6c/ips/192.168.1.50 -d belongs_to_uuid=ff4cac1a-fe98-11e0-acf9-5cf3fce3e7b0
```

Verify changes:

```
curl -X GET http://napi.lab.local/networks/e7753a91-b53a-48fc-990a-fdd86ed06c6c/ips/192.168.1.50|json
{
  "ip": "192.168.1.50",
  "reserved": false,
  "free": false,
  "belongs_to_type": "server",
  "belongs_to_uuid": "ff4cac1a-fe98-11e0-acf9-5cf3fce3e7b0",
  "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
  "network_uuid": "e7753a91-b53a-48fc-990a-fdd86ed06c6c"
}
```

Check any interfaces still assigned to the old headnode UUID:

```
curl -X GET http://napi.lab.local/nics?belongs_to_uuid=00000000-0000-0000-0000-002590fde488|json -a

{
  "belongs_to_type": "server",
  "belongs_to_uuid": "00000000-0000-0000-0000-002590fde488",
  "mac": "00:25:90:fd:e4:8a",
  "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
  "primary": false,
  "state": "provisioning"
}
{
  "belongs_to_type": "server",
  "belongs_to_uuid": "00000000-0000-0000-0000-002590fde488",
  "mac": "00:25:90:fd:e4:8b",
  "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
  "primary": false,
  "state": "provisioning"
}
{
  "belongs_to_type": "server",
  "belongs_to_uuid": "00000000-0000-0000-0000-002590fde488",
  "mac": "00:25:90:fd:e4:88",
  "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
  "primary": false,
  "state": "provisioning",
  "ip": "10.11.11.1",
  "mtu": 1500,
  "netmask": "255.255.255.0",
  "nic_tag": "admin",
  "resolvers": [
    "10.11.11.5"
  ],
  "vlan_id": 0,
  "network_uuid": "62a95100-8021-4210-8d1d-19f43b0d5d22",
  "nic_tags_provided": [
    "admin"
  ]
}
```

Delete nics belonging to old headnode:

```
curl -X DELETE http://napi.lab.local/nics/002590fde488
curl -X DELETE http://napi.lab.local/nics/002590fde48b
curl -X DELETE http://napi.lab.local/nics/002590fde48a
```

Create an entry for the new headnode admin nic:

```
curl -X POST http://napi.lab.local/nics -d mac=5c:f3:fc:e3:e7:b0 -d belongs_to_uuid=ff4cac1a-fe98-11e0-acf9-5cf3fce3e7b0 -d owner_uuid=930896af-bf8c-48d4-885c-6573a94b1853 -d belongs_to_type=server
```

Assign the old admin IP address to new nic:

```
curl -X PUT http://napi.lab.local/nics/5cf3fce3e7b0 -d belongs_to_uuid=ff4cac1a-fe98-11e0-acf9-5cf3fce3e7b0 -d belongs_to_type=server -d ip=10.11.11.1 -d network_uuid=62a95100-8021-4210-8d1d-19f43b0d5d22
```

## Final steps

Log in to adminui and delete the old headnode highlighted in red.

Re-sync VMAPI (this is required to re-sync the state of the zones)

```
for zone in `vmadm list -H -o uuid` ; do  sdc sdc-vmapi /vms/$zone?sync=true; done
```

At this point SDC should be fully online and healthy.

Verify health:

```
sdcadm check-health

INSTANCE                              SERVICE          HOSTNAME           ALIAS       HEALTHY
c3948095-89b4-4841-892f-4edb9a510c35  adminui          headnode           adminui0    true
a0c2b889-cacd-463c-af73-dea561dfa999  amon             headnode           amon0       true
02b4753e-2d72-4214-ad8c-b7486a39a3d8  amonredis        headnode           amonredis0  true
707adb08-bf9c-49a7-9b0e-ec1f468399e3  assets           headnode           assets0     true
7c9f4d5f-55fd-478f-9e6e-341d90d1f10a  binder           40-f2-e9-20-74-92  binder2     true
eeaf98f5-3f7d-4f7b-b32c-b1b55b8b2d17  binder           e4-1f-13-64-eb-68  binder1     true
4428a629-931c-4dd8-b29c-72516c5d70bd  binder           headnode           binder0     true
d412a4f2-8d7e-474c-b117-8118718c466b  cloudapi         headnode           cloudapi0   true
88836131-510f-497d-aa23-3e3c98b99ad4  cnapi            headnode           cnapi0      true
e12d49ca-4d45-49aa-aaac-2c81a0c99fc0  dhcpd            headnode           dhcpd0      true
86353c9d-cdc9-464c-952d-12f045d43621  fwapi            headnode           fwapi0      true
62c6da1d-f262-43bf-af0a-44abe80f9d85  imgapi           headnode           imgapi0     true
928dbbce-1cd1-4e47-be96-e3cc2669bc1b  mahi             headnode           mahi0       true
951edb11-c18f-4e33-a5a9-df39d4bb4877  manatee          40-f2-e9-20-74-92  manatee1    true
f01c36d1-3cf4-42f4-84a9-e521e4ab3521  manatee          e4-1f-13-64-eb-68  manatee2    true
5fccb103-b00c-47bd-bdf0-035adb01b3be  manatee          headnode           manatee0    true
b00be727-cff8-4aac-805a-0b43c96277ce  moray            40-f2-e9-20-74-92  moray1      true
e27d016c-d726-419a-b448-53c712a25d91  moray            e4-1f-13-64-eb-68  moray2      true
2c888e31-af64-40e1-ab7e-d8620a0d34a6  moray            headnode           moray0      true
a07b4c13-db83-4418-92e8-2352bd2ce78d  papi             headnode           papi0       true
b4c22acb-0399-42ec-8126-b1f809c750e0  portolan         headnode           portolan0   true
2e21c811-7d42-474e-b9e5-8511646c65e0  rabbitmq         headnode           rabbitmq0   true
3a33c1c5-1fa6-45d8-b075-f86b156254c6  redis            headnode           redis0      true
689f00c5-b9f9-4050-82a7-eacff5a3f414  sapi             headnode           sapi0       true
03f6ad3a-69eb-4ab3-8416-0b1810517e57  sdc              headnode           sdc0        true
6955a2d4-1923-4185-99a0-c31734fa1f44  ufds             headnode           ufds0       true
5deda066-e2da-4c32-8b03-85aa70172688  vmapi            headnode           vmapi0      true
55cc77c5-37d6-4039-aa6a-588b8ad8cc3f  workflow         headnode           workflow0   true
ff4cac1a-fe98-11e0-acf9-5cf3fce3e7b0  global           headnode           global      true
-                                     amon-agent       40-f2-e9-20-74-92  -           true
-                                     amon-agent       e4-1f-13-64-eb-68  -           true
-                                     amon-relay       40-f2-e9-20-74-92  -           true
-                                     amon-relay       e4-1f-13-64-eb-68  -           true
-                                     cainstsvc        40-f2-e9-20-74-92  -           true
-                                     cainstsvc        e4-1f-13-64-eb-68  -           true
-                                     cn-agent         40-f2-e9-20-74-92  -           true
-                                     cn-agent         e4-1f-13-64-eb-68  -           true
-                                     firewaller       40-f2-e9-20-74-92  -           true
-                                     firewaller       e4-1f-13-64-eb-68  -           true
-                                     hagfish-watcher  40-f2-e9-20-74-92  -           true
-                                     hagfish-watcher  e4-1f-13-64-eb-68  -           true
-                                     heartbeater      40-f2-e9-20-74-92  -           true
-                                     heartbeater      e4-1f-13-64-eb-68  -           true
-                                     net-agent        40-f2-e9-20-74-92  -           true
-                                     net-agent        e4-1f-13-64-eb-68  -           true
-                                     provisioner      40-f2-e9-20-74-92  -           true
-                                     provisioner      e4-1f-13-64-eb-68  -           true
-                                     smartlogin       40-f2-e9-20-74-92  -           true
-                                     smartlogin       e4-1f-13-64-eb-68  -           true
-                                     vm-agent         40-f2-e9-20-74-92  -           true
-                                     vm-agent         e4-1f-13-64-eb-68  -           true
```
