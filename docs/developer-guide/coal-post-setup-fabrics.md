<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2015, Joyent, Inc.
-->

# Set up fabrics in CoaL

In order to simplify the process, all the commands are intended to run from
the Headnode Global Zone. Sample output is provided alongside the commands
as a quick guide of which are the expected results of the execution of such
commands.

## Step 1: Get/create `sdc_underlay` Nic Tag

    [root@headnode (coal) ~]# sdc-napi /nic_tags/sdc_underlay
    HTTP/1.1 404 Not Found
    Content-Type: application/json
    Content-Length: 57
    Date: Thu, 08 Oct 2015 14:35:24 GMT
    Server: SmartDataCenter Networking API
    x-request-id: cf9ff950-6dc9-11e5-8849-218c24b1263a
    x-response-time: 7
    x-server-name: ba04abb4-05bd-4f8d-9552-622a359445cb
    Connection: keep-alive

    {
      "code": "ResourceNotFound",
      "message": "nic tag not found"
    }

    [root@headnode (coal) ~]# sdc-napi /nic_tags -X POST -d '{"name": "sdc_underlay"}'
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 80
    Date: Thu, 08 Oct 2015 14:41:01 GMT
    Server: SmartDataCenter Networking API
    x-request-id: 98a91f70-6dca-11e5-8849-218c24b1263a
    x-response-time: 14
    x-server-name: ba04abb4-05bd-4f8d-9552-622a359445cb
    Connection: keep-alive

    {
      "mtu": 1500,
      "name": "sdc_underlay",
      "uuid": "95152cf9-8e9b-48a7-aa39-c29c5328a941"
    }

## Step 2: Get or create `sdc_underlay` Network

    [root@headnode (coal) ~]# sdc-napi /networks?name=sdc_underlay
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 2
    Date: Thu, 08 Oct 2015 14:46:36 GMT
    Server: SmartDataCenter Networking API
    x-request-id: 605af2f0-6dcb-11e5-8849-218c24b1263a
    x-response-time: 8
    x-server-name: ba04abb4-05bd-4f8d-9552-622a359445cb
    Connection: keep-alive

    []

    [root@headnode (coal) ~]# sdc-napi /networks -X POST -d "{
    \"name\": \"sdc_underlay\",
    \"subnet\": \"10.88.88.0/24\",
    \"provision_start_ip\": \"10.88.88.205\",
    \"provision_end_ip\": \"10.88.88.250\",
    \"nic_tag\": \"sdc_underlay\",
    \"vlan_id\": 0,
    \"owner_uuids\": [\"$(sdc-ufds s 'login=admin'|json uuid)\"]
    }"

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 308
    Date: Thu, 08 Oct 2015 15:07:56 GMT
    Server: SmartDataCenter Networking API
    x-request-id: 5b57f610-6dce-11e5-8849-218c24b1263a
    x-response-time: 114
    x-server-name: ba04abb4-05bd-4f8d-9552-622a359445cb
    Connection: keep-alive

    {
      "mtu": 1500,
      "nic_tag": "sdc_underlay",
      "name": "sdc_underlay",
      "provision_end_ip": "10.88.88.250",
      "provision_start_ip": "10.88.88.205",
      "vlan_id": 0,
      "subnet": "10.88.88.0/24",
      "uuid": "bd0675e7-5f0e-4ad8-8418-92939914f583",
      "resolvers": [],
      "owner_uuids": [
        "930896af-bf8c-48d4-885c-6573a94b1853"
      ],
      "netmask": "255.255.255.0"
    }


## Step 3: Get/create `sdc_nat` network pool

    [root@headnode (coal) ~]# sdc-napi /network_pools?name=sdc_nat
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 2
    Date: Thu, 08 Oct 2015 15:11:06 GMT
    Server: SmartDataCenter Networking API
    x-request-id: cc978200-6dce-11e5-8849-218c24b1263a
    x-response-time: 7
    x-server-name: ba04abb4-05bd-4f8d-9552-622a359445cb
    Connection: keep-alive

    []

    [root@headnode (coal) ~]# sdc-napi /network_pools -X POST -d "{
    \"name\": \"sdc_nat\",
    \"networks\": [\"$(sdc-napi /networks?name=external | json -H 0.uuid)\"]
    }"

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 137
    Date: Thu, 08 Oct 2015 15:13:52 GMT
    Server: SmartDataCenter Networking API
    x-request-id: 2f7b3650-6dcf-11e5-8849-218c24b1263a
    x-response-time: 17
    x-server-name: ba04abb4-05bd-4f8d-9552-622a359445cb
    Connection: keep-alive

    {
      "uuid": "ee58eb30-3c65-4504-babf-c556da1ea868",
      "name": "sdc_nat",
      "networks": [
        "919b0eba-3223-4dcd-8f5f-1e1a0181839a"
      ],
      "nic_tag": "external"
    }


## Step 4: Save the configuration file to run `sdcadm post-setup fabrics`

The network pool UUID for the `sdc_nat` pool is required in order to configure
fabrics. The configuration file contents can be saved as follows:

    echo "{
        \"default_underlay_mtu\": 1500,
        \"default_overlay_mtu\": 1400,
        \"sdc_nat_pool\": \"$(sdc-napi /network_pools?name=sdc_nat|json -H 0.uuid)\",
        \"sdc_underlay_assignment\": \"manual\",
        \"sdc_underlay_tag\": \"sdc_underlay\"
    }" > /tmp/fabrics.cfg

## Step 5: Initialize fabrics using sdcadm

    [root@headnode (coal) ~]# sdcadm post-setup fabrics -c /tmp/fabrics.cfg
    Service "portolan" already exists
    Instance "portolan0" already exists
    Adding fabric configuration to SAPI
    Restarting config of services using "fabric_cfg": napi, vmapi, dhcpd
    Done!

## Step 6: Configure Headnode

### Step 6.1: Update Headnode External Nic

    [root@headnode (coal) ~]# sdc-napi /nics/0050563da795 -d '{"nic_tags_provided": ["external","sdc_underlay"]}' -X PUT
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 245
    Date: Fri, 09 Oct 2015 17:39:04 GMT
    Server: SmartDataCenter Networking API
    x-request-id: a2bf3b60-6eac-11e5-9c45-edaf7bd2771c
    x-response-time: 31
    x-server-name: ba04abb4-05bd-4f8d-9552-622a359445cb
    Connection: keep-alive

    {
      "belongs_to_type": "server",
      "belongs_to_uuid": "564dc9e5-fcb0-fed8-570d-ca17753dd0cc",
      "mac": "00:50:56:3d:a7:95",
      "owner_uuid": "930896af-bf8c-48d4-885c-6573a94b1853",
      "primary": false,
      "state": "running",
      "nic_tags_provided": [
        "external",
        "sdc_underlay"
      ]
    }

### Step 6.2: Create underlay nic for Headnode using sdcadm:

    [root@headnode (coal) ~]# sdcadm post-setup underlay-nics \
        $(sdc-napi /networks?name=sdc_underlay | json -H 0.uuid) \
        $(sysinfo|json UUID)
    Checking for minimum NAPI version
    Verifying the provided network exists
    Verifying the provided Server(s) UUID(s)
    Underlay NIC created for CN 564dc9e5-fcb0-fed8-570d-ca17753dd0cc

### Step 6.3: Setup the headnode with a boot-time networking file and reboot

    [root@headnode (coal) ~]# /usbkey/scripts/mount-usb.sh
    [root@headnode (coal) ~]# sdc-login dhcpd /opt/smartdc/booter/bin/hn-netfile > /mnt/usbkey/boot/networking.json
    [root@headnode (coal) ~]# umount /mnt/usbkey
    [root@headnode (coal) ~]# reboot

## Step 7: Configure the desired Compute Nodes

Just use `sdcadm post-setup underlay-nics`:

        [root@headnode (coal) ~]# sdcadm post-setup underlay-nics \
        $(sdc-napi /networks?name=sdc_underlay | json -H 0.uuid) \
        $CN1_UUID [$CN2_UUID [$CN3_UUID ...]]

