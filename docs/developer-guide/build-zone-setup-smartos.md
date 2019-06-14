---
Setting up SmartOS-based build zones for Manta and Triton development
---

# SmartOS-based build zones

This document assumes you have access to a [SmartOS](https://www.joyent.com/smartos)
installation. You can download the latest ISO, USB or vmware images at
https://us-east.manta.joyent.com/Joyent_Dev/public/SmartOS/latest.html


## Obtaining the build zone image

In this example, we're going to use an example build zone image
`1356e735-456e-4886-aebd-d6677921694c`

On a SmartOS system, use the following to download the image:

```
imgadm import -S 'https://updates.joyent.com?channel=experimental' 1356e735-456e-4886-aebd-d6677921694c
```

or if that doesn't work (some versions of SmartOS don't have support for channels
without the fix for OS-7601) download the image manifest and image file and
import by hand, with:

```
curl -o img.manifest 'https://updates.joyent.com/images/1356e735-456e-4886-aebd-d6677921694c?channel=experimental'
curl -o img.gz 'https://updates.joyent.com/images/1356e735-456e-4886-aebd-d6677921694c/file?channel=experimental'
```

then do the following to add the image to your SmartOS instance:

```
imgadm install -m img.manifest -f img.gz
```

To create the VM, use a json manifest similar to the one listed below.
Note that there are syntax differences between Triton `sdc-vmadm` manifests
and SmartOS `vmadm` manifests!

```
{
  "brand": "joyent",
  "image_uuid": "1356e735-456e-4886-aebd-d6677921694c",
  "alias": "jenkins-agent-multiarch-15.4.1",
  "hostname": "jenkins-agent-multiarch-15.4.1",
  "max_physical_memory": 8192,
  "quota": 100,
  "delegate_dataset": true,
  "fs_allowed": ["ufs", "pcfs"],
  "resolvers": [
    "10.0.0.29",
    "208.67.220.220"
  ],
  "nics": [
    {
      "nic_tag": "admin",
      "ip": "dhcp"
    }
  ],
  "customer_metadata": {
    "root_authorized_keys": "ssh-rsa AAAAB3NzaC1y... me@myselfandi",
  "user-script": "/usr/sbin/mdata-get root_authorized_keys > ~root/.ssh/authorized_keys ; /usr/sbin/mdata-get root_authorized_keys > ~admin/.ssh/authorized_keys; svcadm enable manifest-import " }
}
```

Then create the VM using `vmadm`:

```
[root@kura ~]# vmadm create -f json
Successfully created VM c1f04dfb-63c6-ca69-b04b-d68e5b4ffadc
[root@kura ~]#
```

Now, follow the section
["Configuring the build zone"](./build-zone-setup.md#build-zone-configuration) in
the "Build Zone Setup For Manta and Triton" document.
