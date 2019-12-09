---
Setting up Triton-based build zones for Manta and Triton development
---

# Triton-based build zones

This document assumes that you have a local [Triton/CoaL setup](./coal-setup.md)
and have access to the global zone.

## Setting up Triton for development

CloudAPI allows us to run remote commands against a Triton instance in order
to manage and create VMs, in our case, build zones.

If you're using CoaL, a cloudapi zone is not created by default,
so run the following to create one:

```
[root@headnode (coal-1) ~]# sdcadm post-setup cloudapi
cloudapi0 zone created
```

We also want to add external access to the adminui and imgapi services
so that we can access the adminui remotely and so that the imgapi service
can download the build zone images from updates.joyent.com:

```
[root@headnode (coal-1) ~]# sdcadm post-setup common-external-nics
Added external nic to adminui
Added external nic to imgapi
```

If we don't have a dedicated compute node (CN) on this Triton installation,
which is the default for coal installs, we need to configure it to allow
the creation of zones on the headnode itself. That's not recommended on
production Triton instances.

```
[root@headnode (coal-1) ~]# sdcadm post-setup dev-headnode-prov
Configuring CNAPI to allow headnode provisioning and over-provisioning
Refreshing instance cnapi0 config-agent
[root@headnode (coal-1) ~]#
```

Next we should find the external address for adminui and cloudapi
so that we can interact with those services remotely:

```
[root@headnode (coal-1) ~]# sdc-vmadm ips -p $(sdc-vmname adminui)
10.88.88.5
```

```
[root@headnode (coal-1) ~]# sdc-vmadm ips -p $(sdc-vmname cloudapi)
10.88.88.3
```

Finally, we'll create a user account on the Triton instance ensuring the user
is allowed to provision virtual machines:

```
[root@headnode (coal-1) ~]#  echo '{
    "approved_for_provisioning": "true",
    "company": "Clavius",
    "email": "email@domain.net",
    "givenname": "Build",
    "cn": "Build User",
    "sn": "User",
    "login": "builder",
    "phone": "555 1212",
    "userpassword": "1password"
}' | sdc-useradm create
User 92372c7f-d5a2-4223-888f-8e7982891b8e (login "builder") created
[root@headnode (coal-1) ~]#
```

We'll add our SSH public key to that user:

```
[root@headnode (coal-1) ~]# sdc-useradm add-key builder /tmp/id_rsa.pub
Key "c3:eb:d4:e3:33:ca:9a:a1:54:b5:d6:40:f0:b2:93:68" added to user "builder"
```

and allow that user to create images using one of the default packages by
adding our user to the `owner_uuids` array for that package.
(the package is owned by the `admin` user by default)

```
[root@headnode (coal-1) ~]# sdc-papi /packages | json -ac 'this.name === "sdc_8192"' uuid owner_uuids
.
.
16425b42-b818-11e2-90d4-87477f18a688 [
  "930896af-bf8c-48d4-885c-6573a94b1853"
]
[root@headnode (coal-1) ~]# sdc-papi /packages/16425b42-b818-11e2-90d4-87477f18a688 -X PUT -d '{"owner_uuids": ["930896af-bf8c-48d4-885c-6573a94b1853", "92372c7f-d5a2-4223-888f-8e7982891b8e"]}'
    [output omitted for brevity]
```

We should now be able to use `triton` commands to interact with our Triton
instance using the cloudapi IP address we determined earlier:

```
$ npm install triton
.
.
$ export SDC_URL=https://10.88.88.3
$ export SDC_ACCOUNT=builder
$ export SDC_TESTING=true
$ export SDC_KEY_ID=c3:eb:d4:e3:33:ca:9a:a1:54:b5:d6:40:f0:b2:93:68
$ triton info
login: builder
name: Build User
email: email@domain.net
url: https://10.88.88.3
totalDisk: 0 B
totalMemory: 0 B
instances: 0
$
```

## Retrieving an image on Triton

To retrieve an image on Triton, connect to the headnode and use
`sdc-imgadm import`. For example:

```
[root@headnode (coal-1) ~]# sdc-imgadm import -S 'https://updates.joyent.com?channel=experimental' 1356e735-456e-4886-aebd-d6677921694c
```

You should then modify the image to mark it `public` so that it available for
anyone on the system, or if you prefer, use sdc-imgadm to set set `owner`
 to your `builder` uuid:

```
[root@headnode (coal-1) ~]# sdc-imgadm update $uuid 1356e735-456e-4886-aebd-d6677921694c public=true
```

You should then see that image appearing in the `triton image list` command:

```
$ triton image list
SHORTID   NAME                            VERSION  FLAGS  OS       TYPE          PUBDATE
1356e735  jenkins-agent-multiarch-15.4.1  2.1.0    -      smartos  zone-dataset  2018-12-19
$
```

Repeat these steps for any other images that are needed to build your
component.

## Creating a build zone on Triton

Normally, build zones can be created using the `triton` command line tool,
however cloudapi doesn't currently have support for creating zones with a
`delegated dataset` - where we assign the zone a separate zfs dataset which
can be manipulated within the zone. Delegated datasets are needed by the
`buildimage` tool to assemble component images.

So, the two ways of creating build zones are:

 * remotely, using the admin web interface
 * directly on the headnode itself


### To create a zone using the web interface

 * Visit the admin web UI using the `adminui` IP address we obtained earlier
 * Login as `admin` and navigate to the "Provision a virtual machine" page,
   e.g https://10.88.88.4/provision
 * Select `builder` as the user, choose a descriptive build zone alias.
   If you're the only user of the Triton instance, naming the build zone
   after the image name can be convenient, e.g. "jenkins-agent-multiarch-15.4.1"
 * Select a fairly large package, e.g. "sdc\_8192 1.0.0", one of the default
   packages that ships with Triton.
 * Select one of the images we imported earlier, for example,
   "1356e735-456e-4886-aebd-d6677921694c"
 * Select the "Delegate Dataset" option
 * Use the default brand, "joyent"
 * Choose a CN to provision to (selecting "headnode" will ensure the build zone
   is provisioned on that headnode)
 * Choose the "external" network
 * Add the following Customer metadata, `{"user-script": "/usr/sbin/mdata-get root_authorized_keys > ~root/.ssh/authorized_keys ; /usr/sbin/mdata-get root_authorized_keys > ~admin/.ssh/authorized_keys; svcadm enable manifest-import"}` along with supplying your public ssh key.
 * Click "Provision machine"
 * If you encounter any problems while sshing to your build zone, zlogin into it and verify that the `manifest-import` service is online by doing this:
```
svcs -p manifest-import
STATE          STIME    FMRI
online         20:42:28 svc:/system/manifest-import:default
```


### To create a zone directly from the headnode

First we need to create a json file to pass to `sdc-vmadm`.
There are several ways to do this, but we'll describe some simple approaches
below.

When hosting dev zones on Triton, first we need to get some details to construct
our json image manifest. Here, we're on a newly installed coal instance, so
we're just looking for the builder user uuid, the external network uuid and the
uuid of the headnode to provision to:

```
[root@headnode (coal-1) ~]# sdc-useradm search login=builder
UUID                                  LOGIN    EMAIL             CREATED
92372c7f-d5a2-4223-888f-8e7982891b8e  builder  email@domain.net  2019-05-22
[root@headnode (coal-1) ~]# sdc-network list
NAME         UUID                                  VLAN           SUBNET          GATEWAY
admin        c5bb76da-4b19-434f-9c8c-63ef1a45ce41     0    10.99.99.0/24                -
external     1bc9e7a0-3607-42a3-ba44-373924b6c9a6     0    10.88.88.0/24       10.88.88.2
[root@headnode (coal-1) ~]# sdc-server list
HOSTNAME             UUID                                 VERSION    SETUP    STATUS      RAM  ADMIN_IP
headnode             564d8bfa-7076-6ccc-5072-7112ddf32acc     7.0     true   running     8191  10.99.99.7
```

Now use this json to create the VM, or use the adminui. The key parts are
to specify `delegate_dataset`, required to use the new image construction
tooling, and to use a `billing_id` to specify the uuid of a package that gives
you enough compute resources to have a useful development environment.

We'll look for a likely package first:

```
[root@headnode (coal-1) ~]# sdc-papi --no-headers /packages | json -a -i name uuid cpu_cap max_physical_memory quota | grep 8192
'sdc_8192' '16425b42-b818-11e2-90d4-87477f18a688' 400 8192 25600
```

Now we'll use that package uuid to create our VM:

```
{
  "brand": "joyent",
  "image_uuid": "1356e735-456e-4886-aebd-d6677921694c",
  "alias": "jenkins-agent-multiarch-15.4.1",
  "owner_uuid": "92372c7f-d5a2-4223-888f-8e7982891b8e",
  "server_uuid": "564d8bfa-7076-6ccc-5072-7112ddf32acc",
  "hostname": "jenkins-agent-multiarch-15.4.1",
  "billing_id": "16425b42-b818-11e2-90d4-87477f18a688",
  "delegate_dataset": true,
  "resolvers": [
    "10.0.0.29",
    "208.67.220.220"
  ],
  "networks": [{"uuid": "1bc9e7a0-3607-42a3-ba44-373924b6c9a6"}],
  "customer_metadata": {
    "root_authorized_keys": "ssh-rsa AAAAB3NzaC1y... me@myselfandi",
  "user-script": "/usr/sbin/mdata-get root_authorized_keys > ~root/.ssh/authorized_keys ; /usr/sbin/mdata-get root_authorized_keys > ~admin/.ssh/authorized_keys; svcadm enable manifest-import" }
}
```

Then create the VM:

```
[root@headnode (uk-1) ~]# sdc-vmadm create -f json
Creating VM 60802c6d-e458-612b-bcc5-b472fffad1a2 (job "db55fe3e-a631-4df5-a5e7-18ab9ed11afa")
[root@headnode (uk-1) ~]#
```

If your Triton installation consists of multiple compute nodes and you don't
mind where the VM should be deployed, you can omit the `server_uuid` key.

## Verify you can connect to the VM

Having done this, you should be able to see that vm from `triton` and should
be able to connect to it:

```
$ triton instance list
SHORTID   NAME                            IMG                                   STATE    FLAGS  AGE
64512d5b  jenkins-agent-multiarch-15.4.1  jenkins-agent-multiarch-15.4.1@2.1.0  running  -      1m
$ triton instance ssh jenkins-agent-multiarch-15.4.1
   __        .                   .
 _|  |_      | .-. .  . .-. :--. |-
|_    _|     ;|   ||  |(.-' |  | |
  |__|   `--'  `-' `;-| `-' '  ' `-'
                   /  ; Instance (minimal-multiarch-lts 15.4.1)
                   `-'  https://docs.joyent.com/images/smartos/minimal

[root@64512d5b-f4f0-e070-9e1a-b076df72be6b ~]#
```

Now, follow the section
["Configuring the build zone"](./build-zone-setup.md#build-zone-configuration) in
the "Build Zone Setup For Manta and Triton" document.
