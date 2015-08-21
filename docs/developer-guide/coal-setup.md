<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2015, Joyent, Inc.
-->

# Set Up CoaL

CoaL stands for "Cloud on a Laptop". It is a VMware virtual appliance
for a SmartDataCenter headnode. It's useful for developing and testing
SmartDataCenter (SDC). This document walks through setting up CoaL.

**WARNING: these steps and command options are not appropriate for
production deployments.**

The minimum requirements, practically speaking, for a good CoaL
experience is a **Mac with at least 16 GB RAM and an SSD with at least
45 GB disk available**. Currently, almost all team members using CoaL
are on Macs with VMware Fusion. Vmware Workstation for Linux is used by
a few in the community. VMware Workstation for Windows should work, but
has not recently been tested.

At a high level, setting up CoaL involves:

1. Downloading the latest build.
1. Booting the VMware appliance (virtual machine).
2. Configuring SmartDataCenter.
3. Waiting for the SDC services to automatically install and setup in
   the SDC headnode virtual machine. This can take from 10 to 20 minutes
   on a Mac laptop.
4. Test and develop.


## Run CoaL on VMware

### Download CoaL and Configure VMware

1. Start the download of the latest CoaL build. The tarball is
   approximately 2 GB.

    curl -C - -O https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/coal-latest.tgz

2. Install VMware, if you haven't already.
    - Mac: [VMware Fusion](http://www.vmware.com/products/fusion) 5 or 7.
    - Windows or Linux: [VMware Workstation](http://www.vmware.com/products/workstation).

3. Configure VMware virtual networks for CoaL's "external" and "admin"
   networks. This is a one time configuration for a VMware installation.

    1. Launch VMware at least once after installing VMware.

    2. Run the OS specific CoaL set up script for VMware:

         - Mac:

            ```bash
            curl -s https://raw.githubusercontent.com/joyent/sdc/master/tools/coal-mac-vmware-setup | sudo bash
            ```

         - Linux:

            ```bash
            curl -s https://raw.githubusercontent.com/joyent/sdc/master/tools/coal-linux-vmware-setup | sudo bash
            ```

         - Windows:

            ```
            Download https://raw.githubusercontent.com/joyent/sdc/master/tools/coal-windows-vmware-setup.bat
            Run coal-windows-vmware-setup.bat
            ```

1. Extract the CoaL virtual machine:

    - Mac example:

        ```bash
        $ tar -zxvf coal-latest.tgz -C ~/Documents/Virtual\ Machines.localized
        x root.password.20140911t161518z
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/USB-headnode.vmx
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/zpool.vmdk
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/USB-headnode.vmdk
        x coal-master-20140911T194415Z-g1a445f5-4gb.vmwarevm/4gb.img
        ...
        ```

1. Set memory and run.

    - Mac example:

        1. Launch VMware Fusion
        2. File > Open... `coal-<branch>-<build_date_time>-<git_sha1_hash>-4gb.vmwarevm`
        3. Virtual Machine > Settings
        4. Processes & Memory > set memory to 8192 MB or greater. Be sure to
           leave Mac OS X with at least 8 GB.


1. When you are prompted with the GRUB menu press the down arrow.

  1. Press the down arrow key to highlight "Live 64-bit".

  2. Press 'c' to go to the command line for GRUB.

     ![CoaL Grub Boot Menu](../img/coal-grub-menu.png)

     By default, the OS will redirect the console to ttyb which is fine
     for production but needs to be changed for CoaL. At the command line enter
     "variable os_console vga":

        ```
        grub> variable os_console vga
        ```

  1. Press enter.

  1. Press esc to get back to the GRUB menu.

  1. Boot "Live 64-bit" by pressing enter.

     If while booting it stays just showing a cursor then you might have
     forgotten to redirect the console, see instructions above.

     ![kvm warning on boot](../img/coal-only-cursor.png)

     On boot, being in a virtual environment without Intel VT-x support
     enabled, you'll receive cpu and kvm warnings:

     ![kvm warning on boot](../img/coal-boot-warnings.png)


### Configure the Headnode

Use the following table to configure your CoaL with settings that are
fine for development. The table is followed by screenshots.

If you make a mistake while entering the configuration you can restart
the VMware virtual machine. Also, as the onscreen instructions describe,
the last step in configuration allows editing the resulting
configuration file.

|Setting|Value|Notes|
|---|---|---|
|*Instructions*|↵||
|Company Name|Clavius||
|Region of Datacenter|orbit||
|Name of Datacenter|coal-1|(Availability zone.) |
|Location of DataCenter|Moon, Earth||
|*Instructions*|↵||
|'admin' interface|2|The second NIC is set up as the admin network by the CoaL networking script|
|(admin) headnode IP address|10.99.99.7|Must use this value.|
|(admin) headnode netmask:|↵|Use the default.|
|(admin) Zone's starting IP address:|↵|Use the default.|
|Add external network now? (Y/n)|↵|Must use this value.|
|'external' interface|1|The first NIC is set up as the external network by the CoaL networking script|
|(external) headnode IP address|10.88.88.200|Must use this value.|
|(external) headnode netmask:|↵|Use the default.|
|(external) gateway IP address:|10.88.88.2|Must use this value.|
|(external) network VLAN ID|↵|Use default. The external network is not on a VLAN in CoaL|
|Starting Provisionable IP address for external Network|↵|Use the default.|
|Ending Provisionable IP address for external Network|↵|Use the default.|
|Default gateway IP address:|↵|Use the default.|
|Primary DNS Server|↵|Use the default.|
|Secondary DNS Server|↵|Use the default.|
|Head node domain name|example.com||
|DNS Search Domain|example.com||
|NTP Server IP Address|↵|Use the default.|
|"root" password|rootpass||
|Confirm "root" password|||
|"admin" password|adminpass1||
|Confirm "admin" password|||
|Administrator's email|↵|Use the default.|
|Support email|↵|Use the default.|
|Enable telemetry|↵|Defaults to false.|
|Verify Configuration||Review the configuration before proceeding.|
|Verify Configuration Again|||

Verify configuration:

![Configuration displayed on console for verification.](../img/coal-verify-configuration.png)


## Installation

CoaL will now install based on the configuration parameters entered
above. Installation has been observed to take up to 20 minutes,
particularly if installing on a laptop hard disk drive. It is not
complete **until you see "Setup complete"**.

On a Mac, you will be prompted to enter your admin password, so that the
VM can monitor all network traffic. You may receive this popup a few
times:

![Mac system dialog confirming VM can monitor all network traffic.](../img/coal-mac-vm-monitor-all-network-traffic.png)

The next phase of installation completes with notification of a reboot:

![Reboot message shown on console.](../img/coal-will-reboot.png)

The final phase of installation, setup, is the longest and does not show
the progress at the beginning of it. You may see either just a cursor on
the login page or a login prompt:

!["Welcome to SDC7!" message on console.](../img/coal-welcome-sdc7.png)

or

![Login prompt on console.](../img/coal-headnode-login-prompt.png)

After sometime you will see "preparing for setup":

!["preparing for setup..." on console.](../img/coal-preparing-for-setup.png)

Finally, you'll see "Setup complete":

!["Setup complete on console."](../img/coal-setup-complete.png)


## Post Installation

### Root Access

After setup is complete you should be able to ssh into your CoaL using
the admin network headnode IP address you configured.

```bash
ssh root@10.88.88.200  # password 'rootpass'
```

### Health

Let's confirm the health of SDC services:

```bash
root@headnode (coal-1) ~]# sdc-healthcheck
ZONE                                 STATE           AGENT               STATUS
global                               running         -                   online
assets                               running         -                   online
amon                                 running         -                   online
binder                               running         -                   online
rabbitmq                             running         -                   online
napi                                 running         -                   online
fwapi                                running         -                   online
imgapi                               running         -                   online
adminui                              running         -                   online
moray                                running         -                   online
amonredis                            running         -                   online
sapi                                 running         -                   online
workflow                             running         -                   online
mahi                                 running         -                   online
sdc                                  running         -                   online
papi                                 running         -                   online
dhcpd                                running         -                   online
redis                                running         -                   online
ufds                                 running         -                   online
manatee                              running         -                   online
vmapi                                running         -                   online
cnapi                                running         -                   online
ca                                   running         -                   online
global                               running         provisioner         online
global                               running         heartbeat           online
global                               running         ur                  online
global                               running         smartlogin          online
```


### Additional Plumbing

1. Add external nics to imgapi and adminui

   These are required in order to be able to access remote update sources, and
   in order to be able to access AdminUI using a browser:

    ```bash
    [root@headnode (coal-1) ~]# sdcadm post-setup common-external-nics
    Added external nic to adminui
    Added external nic to imgapi
    ```

   Please note that this command didn't wait for the "add nics" jobs to be
   completed, just submitted, so you might need to give it some extra time
   after the command exits until these jobs really finish.

   Let's use "sdc-vmapi" to confirm which services have an external IP:

    ```bash
    root@headnode (coal-1) ~]# sdc-vmapi /vms?state=running | json -H -ga alias nics.0.ip nics.1.ip
    dhcpd0 10.99.99.9
    imgapi0 10.99.99.21 10.88.88.4
    sdc0 10.99.99.28
    workflow0 10.99.99.19
    napi0 10.99.99.10
    fwapi0 10.99.99.26
    assets0 10.99.99.8
    moray0 10.99.99.17
    ufds0 10.99.99.18
    redis0 10.99.99.24
    sapi0 10.99.99.32
    vmapi0 10.99.99.27
    cnapi0 10.99.99.22
    binder0 10.99.99.11
    amonredis0 10.99.99.23
    rabbitmq0 10.99.99.20
    manatee0 10.99.99.16
    papi0 10.99.99.29
    amon0 10.99.99.25
    ca0 10.99.99.30
    mahi0 10.99.99.33
    adminui0 10.99.99.31 10.88.88.3
    ```

   We can now access access the operations portal, "SDC ADMINUI", in a web
   browser on the host computer at https://10.88.88.3/ .

2. Set up CloudAPI

   CloudAPI provides the self-serve API access to SDC. If you are developing or
   testing verses CloudAPI then create the CloudAPI zone:

    ```bash
    root@headnode (coal-1) ~]# sdcadm post-setup cloudapi
    cloudapi0 zone created
    ```

### Configure for Development

If you are setting up CloudAPI in your CoaL and attempting to provision
VMs using that, you'll probably hit an error that there are no
provisionable servers. That's because the headnode is excluded from the
set of servers used for provisioning customer instances.

However, for development and testing, allowing the headnode to act as a
compute node for instances is handy. To enable:

```bash
[root@headnode (coal-1) ~]# sdcadm post-setup dev-headnode-prov
Configuring CNAPI to allow headnode provisioning and over-provisioning (allow a minute to propagate)
```

# Update CoaL

## Set Channel

If this is your first time updating CoaL, then you'll want to set the [update
channel](../operator-guide/update.md):

```bash
[root@headnode (coal-1) ~]# sdcadm channel set dev
Update channel has been successfully set to: 'dev'
```

## Check Health

It's a good idea to check the health of CoaL using `sdcadm check-health`
before each step. Until [TOOLS-1001](https://smartos.org/bugview/TOOLS-1001)
is resolved, you should also run `sdc-healthcheck`.

## Self Update

1. Update sdcadm:

    ```bash
    [root@headnode (coal-1) ~]# sdcadm --version
    sdcadm 1.6.0 (release-20150723-20150723T144058Z-g66f719b)
    [root@headnode (coal-1) ~]# sdcadm self-update
    Update to sdcadm 1.6.1 (master-20150805T230606Z-g752a217)
    Download update from https://updates.joyent.com
    Run sdcadm installer (log at /var/sdcadm/self-updates/20150814T202432Z/install.log)
    Updated to sdcadm 1.6.1 (master-20150805T230606Z-g752a217, elapsed 17s)
    ```

1. Confirm the updated sdcadm reports SDC as healthy using
   `sdcadm check-health`.

## Back Up SDC's Brain

Take a ZFS snapsnot of the manatee zone and temporarily store on
headnode's drive:

```bash
MANATEE0_UUID=$(vmadm lookup -1 alias=~manatee)
zfs snapshot zones/$MANATEE0_UUID/data/manatee@backup
zfs send zones/$MANATEE0_UUID/data/manatee@backup > /var/tmp/manatee-backup.zfs
zfs destroy zones/$MANATEE0_UUID/data/manatee@backup
```

## Update SDC

You've backed up the Manatee zone, now download and install the updated images
for SDC services. This process can take up to 60 minutes depending on how many
services have new images.

1. Update global zone tools:

    ```bash
    [root@headnode (coal-1) ~]# sdcadm experimental update-gz-tools --latest
    Downloading gz-tools image e9ea98b6-201b-4079-b4cb-e6f9c925d16d (3.0.0) to /var/tmp/gz-tools-e9ea98b6-201b-4079-b4cb-e6f9c925d16d.tgz
    Decompressing gz-tools tarball
    Updating "sdc" zone tools
    Updating global zone scripts
    Mounting USB key
    Unmounting USB key
    Updating cn_tools on all compute nodes
    Cleaning up gz-tools tarball
    Updated gz-tools successfully (elapsed 14s).
    ```

1. Update domain name services:

    ```bash
    [root@headnode (coal-1) ~]# sdcadm experimental update-other
    Update "sdc" SAPI app metadata_schema
    ```

1. Update the agents:

    ```bash
    [root@headnode (coal-1) ~]# sdcadm experimental update-agents --latest -y --all
    UUID of latest installed agents image is: release-20150723-20150723t113741z-gd067c0e

    Ensuring contact with all servers

    This update will make the following changes:
        Download and install
         agentsshar image 31ad16e7-ded0-42c0-8f12-a23e4d2f0b82
        (1.0.0-master-20150813T192358Z-gd067c0e) on 1 servers

    Downloading agentsshar image to /var/tmp/agents-31ad16e7-ded0-42c0-8f12-a23e4d2f0b82.sh
    Running agents installer into 1 servers
    ...16e7-ded0-42c0-8f12-a23e4d2f0b82.sh [===============================================================================>] 100%        1
    Ur command run complete
    Reloading servers sysinfo
    sysinfo reloaded for all the running servers
    Refresh config-agent into all the setup and running servers
    config-agent refresh for all the running servers
    Done.
    ```

1. Update all the services. This step can take up to 45 minutes
   depending on how many services have new images.

    ```bash
    [root@headnode (coal-1) ~]# sdcadm update --all -y
    Finding candidate update images for 23 services (cnapi, mahi, redis, papi, adminui, amonredis, amon, binder, manatee, ca, sapi, vmapi, napi, manta, imgapi, ufds, fwapi, workflow, dhcpd, sdc, cloudapi, moray, assets).
    Note: There are no "manta" instances. Only the service configuration will be updated.

    This update will make the following changes:
        download 7 images (352 MiB):
            image 72e02784-4205-11e5-8716-bf4775f2d122 (cnapi@master-20150813T214711Z-gec7854c)
            image 37f1ced4-411f-11e5-98c2-7771ebd8c6a8 (adminui@master-20150812T181718Z-g4caebce)
            image 7098ceb8-3260-11e5-abaa-cfc71813e2f6 (manta-deployment@master-20150724T235719Z-gc13ee4d)
            image 7460992a-37da-11e5-9a9d-77d0d6309219 (napi@master-20150731T231325Z-g2ac49c8)
            image b68e6d62-360a-11e5-8927-f39b9ca92d9a (imgapi@master-20150729T155341Z-geeb1af4)
            image 4677867a-3b8d-11e5-b0b0-bb8491425542 (cloudapi@master-20150805T160959Z-g23d22d6)
            image 3a5db69e-407d-11e5-a22e-4ff96e942d5d (vmapi@master-20150811T225942Z-g6df1922)
        update "cnapi" service to image 72e02784-4205-11e5-8716-bf4775f2d122 (cnapi@master-20150813T214711Z-gec7854c)
        update "adminui" service to image 37f1ced4-411f-11e5-98c2-7771ebd8c6a8 (adminui@master-20150812T181718Z-g4caebce)
        update "vmapi" service to image 3a5db69e-407d-11e5-a22e-4ff96e942d5d (vmapi@master-20150811T225942Z-g6df1922)
        update "napi" service to image 7460992a-37da-11e5-9a9d-77d0d6309219 (napi@master-20150731T231325Z-g2ac49c8)
        update "manta" service to image 7098ceb8-3260-11e5-abaa-cfc71813e2f6 (manta-deployment@master-20150724T235719Z-gc13ee4d)
        update "cloudapi" service to image 4677867a-3b8d-11e5-b0b0-bb8491425542 (cloudapi@master-20150805T160959Z-g23d22d6)
        update "imgapi" service to image b68e6d62-360a-11e5-8927-f39b9ca92d9a (imgapi@master-20150729T155341Z-geeb1af4)

    Create work dir: /var/sdcadm/updates/20150814T204832Z
    Downloading image 72e02784-4205-11e5-8716-bf4775f2d122 (cnapi@master-20150813T214711Z-gec7854c)
    Downloading image 37f1ced4-411f-11e5-98c2-7771ebd8c6a8 (adminui@master-20150812T181718Z-g4caebce)
    Downloading image 7098ceb8-3260-11e5-abaa-cfc71813e2f6 (manta-deployment@master-20150724T235719Z-gc13ee4d)
    Downloading image 7460992a-37da-11e5-9a9d-77d0d6309219 (napi@master-20150731T231325Z-g2ac49c8)
    Imported image 72e02784-4205-11e5-8716-bf4775f2d122 (cnapi@master-20150813T214711Z-gec7854c)
    Downloading image b68e6d62-360a-11e5-8927-f39b9ca92d9a (imgapi@master-20150729T155341Z-geeb1af4)
    Imported image 7460992a-37da-11e5-9a9d-77d0d6309219 (napi@master-20150731T231325Z-g2ac49c8)
    Downloading image 4677867a-3b8d-11e5-b0b0-bb8491425542 (cloudapi@master-20150805T160959Z-g23d22d6)
    Imported image 37f1ced4-411f-11e5-98c2-7771ebd8c6a8 (adminui@master-20150812T181718Z-g4caebce)
    Downloading image 3a5db69e-407d-11e5-a22e-4ff96e942d5d (vmapi@master-20150811T225942Z-g6df1922)
    Imported image 7098ceb8-3260-11e5-abaa-cfc71813e2f6 (manta-deployment@master-20150724T235719Z-gc13ee4d)
    Imported image b68e6d62-360a-11e5-8927-f39b9ca92d9a (imgapi@master-20150729T155341Z-geeb1af4)
    Imported image 4677867a-3b8d-11e5-b0b0-bb8491425542 (cloudapi@master-20150805T160959Z-g23d22d6)
    Imported image 3a5db69e-407d-11e5-a22e-4ff96e942d5d (vmapi@master-20150811T225942Z-g6df1922)
    Installing image 72e02784-4205-11e5-8716-bf4775f2d122 (cnapi@master-20150813T214711Z-gec7854c)
    Reprovisioning cnapi VM 1ede0997-1a1f-405a-bf57-b794c69feb10
    Waiting for cnapi instance 1ede0997-1a1f-405a-bf57-b794c69feb10 to come up
    Installing image 37f1ced4-411f-11e5-98c2-7771ebd8c6a8 (adminui@master-20150812T181718Z-g4caebce)
    Reprovisioning adminui VM 733a6141-5167-42e6-9d8a-ece47974b82d
    Waiting for adminui instance 733a6141-5167-42e6-9d8a-ece47974b82d to come up
    Installing image 3a5db69e-407d-11e5-a22e-4ff96e942d5d (vmapi@master-20150811T225942Z-g6df1922)
    Reprovisioning vmapi VM 09882999-4f41-4519-9d1c-ea1843f8fb36
    Waiting for vmapi instance 09882999-4f41-4519-9d1c-ea1843f8fb36 to come up
    Installing image 7460992a-37da-11e5-9a9d-77d0d6309219 (napi@master-20150731T231325Z-g2ac49c8)
    Reprovisioning napi VM a9ff40ea-5662-4c04-b38c-941757e61a0f
    Waiting for napi instance a9ff40ea-5662-4c04-b38c-941757e61a0f to come up
    Installing image 4677867a-3b8d-11e5-b0b0-bb8491425542 (cloudapi@master-20150805T160959Z-g23d22d6)
    Reprovisioning cloudapi VM fb327364-2308-4f11-a6b1-af39ad3d05fb
    Waiting for cloudapi instance fb327364-2308-4f11-a6b1-af39ad3d05fb to come up
    Installing image b68e6d62-360a-11e5-8927-f39b9ca92d9a (imgapi@master-20150729T155341Z-geeb1af4)
    Reprovisioning imgapi VM 141f8416-5496-4cef-9a0d-b7ab3ffda801
    Waiting for imgapi instance 141f8416-5496-4cef-9a0d-b7ab3ffda801 to come up
    Disabling imgapi service
    Running IMGAPI migration-008-new-storage-layout.js
    Running IMGAPI migration-009-backfill-archive.js
    Running IMGAPI migration-010-backfill-billing_tags.js
    Running IMGAPI migration-011-backfill-published_at.js
    Running IMGAPI migration-012-update-docker-image-uuids.js (if exists)
    Enabling imgapi service
    Updated successfully (elapsed 615s).
    ```

1. Confirm SDC's health with `sdcadm check-health`.

## Update Platform

[SmartOS](https://smartos.org/) is the operating system, the platform, of
SmartDataCenter. You'll often update the platform image (PI) at the same
time you install SDC updates. You might not reboot the headnode or
compute nodes (CN) right away. You will likely "install" new PI more
freqently than the rest of SDC, so that on reboot you benefit from
the most reliable and secure OS.

1. Download and "install" the latest platform image:

    ```bash
    [root@headnode (coal-1) ~]# sdcadm platform install --latest
    Downloading platform 20150312T155347Z (image 6564370e-da8f-4c40-b66e-9c4ba21e9f50) to /var/tmp/platform-master-20150312T155347Z.tgz
    Installing platform image onto USB key
    ==> Mounting USB key
    ==> Staging 20150312T155347Z
    ######################################################################## 100.0%
    ==> Unpacking 20150312T155347Z to /mnt/usbkey/os
    ==> This may take a while...
    ==> Copying 20150312T155347Z to /usbkey/os
    ==> Unmounting USB Key
    ==> Adding to list of available platforms
    ==> Done!
    Platform installer finished successfully
    Proceeding to complete the update
    Updating 'latest' link
    Installation complete
    ```

1. Update the headnode to use the latest platform image.

   Get the version of the latest platform image:
    ```bash
    [root@headnode (coal-1) ~]# LATEST_PLATFORM=$(sdcadm platform list -j | json -a -c 'latest==true' version)
    [root@headnode (coal-1) ~]# echo $LATEST_PLATFORM
    20150219T182356Z
    ```

   Assign the latest platform image to the headnode which is included with
   the "--all" servers option on the "sdc platform assign" command:

    ```bash
    [root@headnode (coal-1) ~]# sdcadm platform assign $LATEST_PLATFORM --all
    updating headnode 564dc5bc-f596-6234-8041-bab9c76c2509 to 20150205T055835Z
    Setting boot params for 564dc5bc-f596-6234-8041-bab9c76c2509
    Updating booter cache for servers
    Done updating booter caches
    ```

   Confirm:

    ```bash
    [root@headnode (coal-1) ~]# sdcadm platform list
    VERSION           CURRENT_PLATFORM  BOOT_PLATFORM  LATEST
    20150219T182356Z  0                 1              true
    20150205T055835Z  1                 0              false
    ```

1. Reboot the headnode:

    ```bash
    [root@headnode (coal-1) ~]# reboot
    reboot: Halting 22 zones.
    Connection to 10.88.88.200 closed by remote host.
    ```

1. Log back in and confirm the platform version:

    ```bash
    % ssh root@10.88.88.200
    Password:
    Last login: Thu Feb 19 21:04:24 2015 from 10.88.88.1
     - SmartOS Live Image v0.147+ build: 20150219T182356Z
    ```

1. Run `sdc-healthcheck` until all services go from "error" or "svc-err" to "online".

   You have successfully updated CoaL.

## Additional Operations

See [the Joyent customer documentation](https://docs.joyent.com/sdc7).
