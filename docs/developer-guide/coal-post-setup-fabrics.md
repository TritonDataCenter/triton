<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2015, Joyent, Inc.
    Copyright 2022 MNX Cloud, Inc.
-->

# CoaL post-setup: fabrics

This guide shows you how to setup "fabrics" (Triton's network virtualization
system) in your CoaL after basic [CoaL headnode setup](./coal-setup.md).
See also: <https://docs.joyent.com/private-cloud/networks/sdn>.


## CoaL headnode

To setup fabrics on your CoaL **headnode** the process is as follows.
First an overview is given, then an example run of each command is shown.

1. Create the `sdc_underlay` *nic tag*.
2. Create the `sdc_underlay` NAPI *network*.
3. Create the `sdc_nat` NAPI *network pool*.
4. Setup the *"portolan" and "nat" SAPI services* and *set the fabric config*.
5. Add `sdc_underlay` to the headnode's physical external nic tags.
   (See [Nic Tag
   Concepts](https://github.com/TritonDataCenter/sdc-napi/blob/master/docs/index.md#nic-tag-concepts)
   for background.)) for background.)
6. Create an underlay nic for the headnode.
7. Setup the headnode with a boot-time networking file.
8. Reboot the headnode.
   (Note: In general SmartOS networking card device drivers don't support
   increasing the MTU once you already have interfaces plumbed up and using
   them.)


### 1. Create the `sdc_underlay` *nic tag*


```bash
if [[ "$(sdc-napi /nic_tags | json -H -c 'this.name==="sdc_underlay"')" == "[]" ]]; then
    sdc-napi /nic_tags -X POST -d '{"name": "sdc_underlay"}'
fi
```

Example:

```
[root@headnode (coal) ~]# if [[ "$(sdc-napi /nic_tags | json -H -c 'this.name==="sdc_underlay"')" == "[]" ]]; then
>     sdc-napi /nic_tags -X POST -d '{"name": "sdc_underlay"}'
> fi
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 80
Date: Tue, 13 Oct 2015 22:22:56 GMT
Server: SmartDataCenter Networking API
x-request-id: f4388100-71f8-11e5-a0e5-db294d29a01e
x-response-time: 112
x-server-name: dbd37544-b6b9-4b10-9f8e-1050bdcdd0b2
Connection: keep-alive

{
  "mtu": 1500,
  "name": "sdc_underlay",
  "uuid": "064cf263-7738-4e7e-b183-59f9c2df6c57"
}
```

### 2. Create the `sdc_underlay` NAPI *network*

```bash
if [[ "$(sdc-napi /networks?name=sdc_underlay | json -H)" == "[]" ]]; then
    sdc-napi /networks -X POST -d@- <<EOM
{
    "name": "sdc_underlay",
    "subnet": "10.88.88.0/24",
    "provision_start_ip": "10.88.88.205",
    "provision_end_ip": "10.88.88.250",
    "nic_tag": "sdc_underlay",
    "vlan_id": 0,
    "owner_uuids": ["$(sdc-ufds search login=admin | json uuid)"]
}
EOM
fi
```

Example:

```
[root@headnode (coal) ~]# if [[ "$(sdc-napi /networks?name=sdc_underlay | json -H)" == "[]" ]]; then
>     sdc-napi /networks -X POST -d@- <<EOM
> {
>     "name": "sdc_underlay",
>     "subnet": "10.88.88.0/24",
>     "provision_start_ip": "10.88.88.205",
>     "provision_end_ip": "10.88.88.250",
>     "nic_tag": "sdc_underlay",
>     "vlan_id": 0,
>     "owner_uuids": ["$(sdc-ufds search login=admin | json uuid)"]
> }
> EOM
> fi
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 308
Date: Tue, 13 Oct 2015 22:30:27 GMT
Server: SmartDataCenter Networking API
x-request-id: 00552190-71fa-11e5-a0e5-db294d29a01e
x-response-time: 797
x-server-name: dbd37544-b6b9-4b10-9f8e-1050bdcdd0b2
Connection: keep-alive

{
  "mtu": 1500,
  "nic_tag": "sdc_underlay",
  "name": "sdc_underlay",
  "provision_end_ip": "10.88.88.250",
  "provision_start_ip": "10.88.88.205",
  "vlan_id": 0,
  "subnet": "10.88.88.0/24",
  "uuid": "a72863ae-9d76-4b5c-8895-870ab1179b40",
  "resolvers": [],
  "owner_uuids": [
    "930896af-bf8c-48d4-885c-6573a94b1853"
  ],
  "netmask": "255.255.255.0"
}
```

### 3. Create the `sdc_nat` NAPI *network pool*

```bash
if [[ "$(sdc-napi /network_pools | json -H -c 'this.name==="sdc_nat"')" == "[]" ]]; then
    sdc-napi /network_pools -X POST -d@- <<EOM
{
    "name": "sdc_nat",
    "networks": ["$(sdc-napi /networks?name=external | json -H 0.uuid)"]
}
EOM
fi
```

Example:

```
[root@headnode (coal) ~]# if [[ "$(sdc-napi /network_pools | json -H -c 'this.name==="sdc_nat"')" == "[]" ]]; then
>     sdc-napi /network_pools -X POST -d@- <<EOM
> {
>     "name": "sdc_nat",
>     "networks": ["$(sdc-napi /networks?name=external | json -H 0.uuid)"]
> }
> EOM
> fi
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 137
Date: Tue, 13 Oct 2015 22:32:41 GMT
Server: SmartDataCenter Networking API
x-request-id: 5087ade0-71fa-11e5-a0e5-db294d29a01e
x-response-time: 225
x-server-name: dbd37544-b6b9-4b10-9f8e-1050bdcdd0b2
Connection: keep-alive

{
  "uuid": "d8b7fe2e-4461-4964-a484-e585168c3c28",
  "name": "sdc_nat",
  "networks": [
    "079f8d7a-aa72-4c69-8965-be1be0f5247c"
  ],
  "nic_tag": "external"
}
```


### 4. Setup the *"portolan" and "nat" SAPI services* and *set the fabric config*

```bash
cat <<EOM >/tmp/fabrics.cfg
{
    "default_underlay_mtu": 1500,
    "default_overlay_mtu": 1400,
    "sdc_nat_pool": "$(sdc-napi /network_pools | json -H -c 'this.name==="sdc_nat"' 0.uuid)",
    "sdc_underlay_assignment": "manual",
    "sdc_underlay_tag": "sdc_underlay"
}
EOM

sdcadm post-setup fabrics -c /tmp/fabrics.cfg
```

Example:

```
[root@headnode (coal) ~]# cat <<EOM >/tmp/fabrics.cfg
> {
>     "default_underlay_mtu": 1500,
>     "default_overlay_mtu": 1400,
>     "sdc_nat_pool": "$(sdc-napi /network_pools | json -H -c 'this.name==="sdc_nat"' 0.uuid)",
>     "sdc_underlay_assignment": "manual",
>     "sdc_underlay_tag": "sdc_underlay"
> }
> EOM

[root@headnode (coal) ~]# sdcadm post-setup fabrics -c /tmp/fabrics.cfg
Downloading image c4da1b22-6969-11e5-8926-435b6dfb7da8
    (portolan@master-20151003T005420Z-g91be53a)
Imported image c4da1b22-6969-11e5-8926-435b6dfb7da8
    (portolan@master-20151003T005420Z-g91be53a)
Creating "portolan" service
Creating "portolan" instance
Finished portolan setup
Adding fabric configuration
Restarting config of services using "fabric_cfg": napi, vmapi, dhcpd
Done!
```


### 5. Add `sdc_underlay` to the headnode's physical external nic tags

```bash
external_nic=$(sdc-sapi /applications?name=sdc | json -H 0.metadata.external_nic)
sdc-napi /nics/$(echo $external_nic | sed -e 's/://g') \
    -d '{"nic_tags_provided": ["external","sdc_underlay"]}' -X PUT
```

Example:

```
[root@headnode (coal) ~]# external_nic=$(sdc-sapi /applications?name=sdc | json -H 0.metadata.external_nic)
[root@headnode (coal) ~]# sdc-napi /nics/$(echo $external_nic | sed -e 's/://g') \
>     -d '{"nic_tags_provided": ["external","sdc_underlay"]}' -X PUT
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 250
Date: Tue, 13 Oct 2015 22:42:12 GMT
Server: SmartDataCenter Networking API
x-request-id: a4d39d90-71fb-11e5-8616-4ba690e7d4ac
x-response-time: 96
x-server-name: dbd37544-b6b9-4b10-9f8e-1050bdcdd0b2
Connection: keep-alive

{
  "belongs_to_type": "server",
  "belongs_to_uuid": "564d5814-017e-1bb2-9fcc-859d1ce51ee3",
  "mac": "00:50:56:3d:a7:95",
  "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
  "primary": false,
  "state": "provisioning",
  "nic_tags_provided": [
    "external",
    "sdc_underlay"
  ]
}
```


### 6. Create an underlay nic for the headnode

```bash
sdcadm post-setup underlay-nics \
    $(sdc-napi /networks?name=sdc_underlay | json -H 0.uuid) \
    $(sysinfo | json UUID)
```

Example:

```
[root@headnode (coal) ~]# sdcadm post-setup underlay-nics \
>     $(sdc-napi /networks?name=sdc_underlay | json -H 0.uuid) \
>     $(sysinfo | json UUID)
Checking for minimum NAPI version
Verifying the provided network exists
Verifying the provided Server(s) UUID(s)
Underlay NIC created for CN 564d5814-017e-1bb2-9fcc-859d1ce51ee3
```


### 7. Setup the headnode with a boot-time networking file

```bash
sdc-usbkey mount
sdc-login -l dhcpd /opt/smartdc/booter/bin/hn-netfile \
    > /mnt/usbkey/boot/networking.json
sdc-usbkey unmount
```

(TODO: An explanation of this step would be helpful.)


Example:

```
[root@headnode (coal) ~]# sdc-usbkey mount
/mnt/usbkey
[root@headnode (coal) ~]# sdc-login -l dhcpd /opt/smartdc/booter/bin/hn-netfile \
>     > /mnt/usbkey/boot/networking.json
[root@headnode (coal) ~]# sdc-usbkey unmount
```


### 8. Reboot the headnode

```bash
reboot
```


### Summary

In summary, all the commands to run are repeated here (with some updates to
allow re-running this block):

```bash
if [[ "$(sdc-napi /nic_tags | json -H -c 'this.name==="sdc_underlay"')" == "[]" ]]; then
    sdc-napi /nic_tags -X POST -d '{"name": "sdc_underlay"}'
fi

if [[ "$(sdc-napi /networks?name=sdc_underlay | json -H)" == "[]" ]]; then
    sdc-napi /networks -X POST -d@- <<EOM
{
    "name": "sdc_underlay",
    "subnet": "10.88.88.0/24",
    "provision_start_ip": "10.88.88.205",
    "provision_end_ip": "10.88.88.250",
    "nic_tag": "sdc_underlay",
    "vlan_id": 0,
    "owner_uuids": ["$(sdc-ufds search login=admin | json uuid)"]
}
EOM
fi

if [[ "$(sdc-napi /network_pools | json -H -c 'this.name==="sdc_nat"')" == "[]" ]]; then
    sdc-napi /network_pools -X POST -d@- <<EOM
{
    "name": "sdc_nat",
    "networks": ["$(sdc-napi /networks?name=external | json -H 0.uuid)"]
}
EOM
fi

sdc_nat_pool_uuid=$(sdc-napi /network_pools | json -H -c 'this.name==="sdc_nat"' 0.uuid)
fabric_cfg=$(/opt/smartdc/bin/sdc-sapi /applications?name=sdc | json -H 0.metadata.fabric_cfg)
if [[ -z "$fabric_cfg" ]]; then
    cat <<EOM >/tmp/fabrics.cfg
{
    "default_underlay_mtu": 1500,
    "default_overlay_mtu": 1400,
    "sdc_nat_pool": "$sdc_nat_pool_uuid",
    "sdc_underlay_assignment": "manual",
    "sdc_underlay_tag": "sdc_underlay"
}
EOM
    sdcadm post-setup fabrics -c /tmp/fabrics.cfg
fi

if ! $(nictagadm exists sdc_underlay 2>/dev/null); then
    external_nic=$(sdc-sapi /applications?name=sdc | json -H 0.metadata.external_nic)
    sdc-napi /nics/$(echo $external_nic | sed -e 's/://g') \
        -d '{"nic_tags_provided": ["external","sdc_underlay"]}' -X PUT

    sdcadm post-setup underlay-nics \
        $(sdc-napi /networks?name=sdc_underlay | json -H 0.uuid) \
        $(sysinfo | json UUID)

    sdc-usbkey mount
    sdc-login -l dhcpd /opt/smartdc/booter/bin/hn-netfile \
        > /mnt/usbkey/boot/networking.json
    sdc-usbkey unmount

    reboot
fi
```


## CoaL CNs

To configure one or more CoaL CNs, it is assumed that you have run the
[Coal headnode fabrics setup](#coal-headnode). Then do the following
for each CN:

```bash
cn_uuid=<UUID of the CN>
# See NIC info with: sysinfo | json "Network Interfaces"
cn_mac=<MAC of the CN NIC to use for fabric traffic>

sdc-server update-nictags -s $cn_uuid sdc_underlay_nic=$cn_mac

underlay_network_uuid=$(sdc-napi /networks?name=sdc_underlay | json -H 0.uuid)
sdcadm post-setup underlay-nics $underlay_network_uuid $cn_uuid

# Reboot the CN
sdc-oneachnode -n $cn_uuid reboot
```
