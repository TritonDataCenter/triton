---
Build Zone Setup For Manta and Triton
---

## Introduction

Most Triton/Manta components can build in build zones running on either of two
platforms:

 * Triton - [a full Triton install](https://github.com/joyent/triton#getting-started)
   contains everything you need to install the build zones for building
   components.
   Triton is a little more resource-intensive than SmartOS, but can be scaled
   out beyond a single system. If you're developing for Triton, you may find it
   educational to also run your development environments on it.

 * SmartOS - since Triton itself is based on SmartOS, it's also possible
   to build on [a SmartOS install](https://wiki.smartos.org/display/DOC/Download+SmartOS)
   that hosts those build zones. SmartOS is less resource-intensive than
   Triton and can be easier to set up.

As build zones themselves must be compatible with the origin image that the
component gets deployed with, if you're working on several components, you
may need different build zones for each. We try to keep the set of different
build zones as small as possible.

The tooling to create build zones differs across these platforms, so in this
guide, we'll explain both.

## More about build zones

A build zone contains a set of base pkgsrc packages, some additional
development pkgsrc packages, and a set of build tools. In Triton and SmartOS,
zones are created from `images`, which are templates that contain filesystem
data, and some metadata.

Joyent's production builds impose a further restriction that the Platform Image
(that is, the kernel and userland bits running on the bare metal, either
SmartOS or Triton) needs to be at a specific minimum version, defined via
`min_platform` in `deps/eng/tools/mk/Makefile.defs`.

At the time of writing, most components will build on more modern platform
images, so for now, we'll leave aside the platform image restriction, other than
to say that you should set `$ENGBLD_SKIP_VALIDATE_BUILD_PLATFORM` to `true`
in your environment. We'll talk more about this in the
["Going retro"](#retro) section of this document.

For convenience, we maintain a set of build zone images that already include
the required pkgsrc packages and build tools. The table below lists those image
names and their corresponding uuids:

  |pkgsrc version | base image name                                               | build zone image uuid
  ----------------|---------------------------------------------------------------|-----------------------------
  |2011Q4         | sdc-smartos@1.6.3                                             | 956f365d-2444-4163-ad48-af2f377726e0
  |2014Q2         | sdc-base@14.2.0                                               | 83708aad-20a8-45ff-bfc0-e53de610e418
  |2015Q4         | sdc-minimal-multiarch-lts@15.4.1, triton-origin-multiarch-15.4.1@1.0.1 | 1356e735-456e-4886-aebd-d6677921694c
  |2018Q1         | minimal-multiarch@18.1.0                                      | 8b297456-1619-4583-8a5a-727082323f77
  |2018Q4         | triton-origin-x86\_64-18.4.0@master-20190410T193647Z-g982b0cea | 29b70133-1e97-47d9-a4c1-e4b2ee1a1451
  |2019Q1         | triton-origin-x86\_64-19.1.0@master-20190417T143547Z-g119675b  | fb751f94-3202-461d-b98d-4465560945ec

These build zone image uuids are exactly what we build components on in Joyent's
Jenkins infrastructure (when you examine the images, you'll find that they're
named with `jenkins-agent-...` prefixes)

For any component, you can find the suggested image\_uuid that the component
should build on by running the `make show-buildenv` command from the top-level
of the component git repository. For example:

```
$ cd /home/timf/projects/sdc-manatee.git
$ make show-buildenv
2015Q4 triton-origin-multiarch-15.4.1@1.0.1 1356e735-456e-4886-aebd-d6677921694c
$
```

## Creating a new build zone

Taking one of the image uuids above, you need to download or import the
image, then create a build zone from it. The mechanism to do that will depend on
whether you're using a Triton instance or a SmartOS instance to run your build
zone on.

* [setting up a build zone on Triton](./build-zone-setup-triton.md)
* [setting up a build zone on SmartOS](./build-zone-setup-smartos.md)

<a name="build-zone-configuration"></a>

## Configuring the build zone

There are a few additional pieces of configuration you may need to perform
before attempting to build any component:

 * Ensure your build user has an ssh key available that can access github
   repositories, necessary if you're building private git repositories

 * Ensure `/root/bin` appears in your path, or otherwise install the tools
   mentioned by `make validate-buildenv` (manta-client tools, updates-imgadm)

   ```
   $ /opt/tools/bin/npm install manta git+https://github.com/joyent/sdc-imgapi-cli.git
   ```

   These are needed by the `bits-upload` target mentioned in the
   ["Building a component" section of "Building Triton and Manta"](./building.md#makefile-targets).


 * Ensure your build user has `$MANTA_USER`, `$MANTA_KEY_ID` and `$MANTA_URL`
   set in the environment, again needed if you use the `bits-upload` target.

<a name="retro"></a>

## Going retro

We mentioned before that most components will build on modern platform images.

However, Joyent production builds always build on the earliest possible platform
we support, defined by `min_platform`. We do this because of the binary
compatibility guarantee that comes with Illumos (the kernel and userland
software used by SmartOS): binaries compiled on older platforms are
guaranteed to run on newer platforms, but it is not guaranteed that binaries
compiled on newer platforms will run on older ones.

In addition, when compiling binaries, constant values from the platform headers
may be included in those binaries at build-time. If those constants change
across platform images (which several have), then the binary will have different
behaviour depending on which platform the source was built on.

For these reasons, when assembling the Manta/Triton images via the 'buildimage'
target, we set the `min_platform` of the resulting image to be the version
of the platform running on the build machine. Code in `vmadm` checks at
provisioning-time that the platform hosting the VM is greater than, or equal to
the `min_platform` value baked into the Manta/Triton image.

As mentioned previously, the build system itself will report an error if
your build platform is not equal to the `min_platform` image, via the
`validate-buildenv` make target.

In order to exactly replicate the build environment used for our production
builds, and produce images that can be installed on any supported platform,
we install build zones on `joyent-retro` VMs, which are bhyve (or KVM) SmartOS
instances that boot that old platform image.
(See [https://github.com/joyent/joyent-retro/blob/master/README.md](https://github.com/joyent/joyent-retro/blob/master/README.md))

At the time of writing, our `min_platform` is set to `20151126T062538Z`

That image is available as `joyent-retro-20151126T062538Z`,
uuid `bd83a9b3-65cd-4160-be2e-f7c4c56e0606`

See: [https://updates.joyent.com/images/bd83a9b3-65cd-4160-be2e-f7c4c56e0606?channel=experimental](https://updates.joyent.com/images/bd83a9b3-65cd-4160-be2e-f7c4c56e0606?channel=experimental)

The retro image does not itself contain any devzone images, so those will have
to be imported by hand.

The following example json would then be used to deploy it on a SmartOS
instance. Note here we're adding a 64gb data disk which will then host our
dev zones.

```
{
  "brand": "bhyve",
  "alias": "retro-20151126T062538Z",
  "hostname": "retro-20151126T062538Z",
  "ram": 4096,
  "vcpus": 6,
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
      "ip": "dhcp",
      "netmask": "255.255.255.0",
      "gateway": "10.0.0.1",
      "model": "virtio",
      "primary": "true"
    }
  ],
  "disks": [
            {
                 "boot": true,
                 "model": "virtio",
                 "image_uuid": "bd83a9b3-65cd-4160-be2e-f7c4c56e0606",
                 "image_name": "joyent-retro-20151126T062747Z"
            },
            {
                "boot": false,
                 "model": "virtio",
                 "size": 65536,
                 "media": "disk"
            }
],
  "customer_metadata": {
    "root_authorized_keys": "ssh-rsa AAAAB3Nz... me@myselfandi"
  }
}
```

Having deployed a VM using this image on your Triton or SmartOS host, you can
then ssh into the retro VM and proceed with creating build zones as mentioned in
the earlier section and do **not** need to set
`$ENGBLD_SKIP_VALIDATE_BUILD_PLATFORM` in your environment.

Note that this retro image is itself a SmartOS instance rather than a Triton
host, so you'll need to use SmartOS-formatted json to create build zones.

To allow you to ssh directly into the build zones running in a retro VM,
you can either use the `ProxyJump` ssh option, or configure ipnat. We'll
describe both approaches below.

#### Using ProxyJump for ssh access

To use `ProxyJump`, write `~/.ssh/config` entries similar to:

```
    Host retro-gz
        Hostname 10.0.0.180
        User root

    Host retro-kabuild2
        ProxyJump retro-gz
        Hostname 172.16.9.2
        User root
```

where `retro-gz` is the entry for the global zone of our VM, `10.0.0.180` is
the VM's IP address, and `172.16.9.2` is one of our build zones inside that VM
that we wish to access over ssh. You can then ssh to it using
`ssh retro-kabuild2`.

The `ProxyJump` option can also be used by passing the `-J` option on the ssh
command line.

#### Configuring NAT

If you need to expose services in your build zones other than ssh, setting up
NAT port forwarding is one way to do that. In this example, this retro VM has
the external IP address `10.0.0.180` and our build zones are all on the
`172.16.9.0` network. We'll just forward the ssh port (22), for simplicity.

We create a file `/etc/ipf/ipnat.conf`:

```
[root@27882aaa /etc/ipf]# cat ipnat.conf
map vioif0 172.16.9.0/24 -> 0/32 portmap tcp/udp auto
map vioif0 172.16.9.0/24 -> 0/32

rdr vioif0 10.0.0.180 port 2222 -> 172.16.9.2 port 22 tcp
rdr vioif0 10.0.0.180 port 2223 -> 172.16.9.3 port 22 tcp
rdr vioif0 10.0.0.180 port 2224 -> 172.16.9.4 port 22 tcp
rdr vioif0 10.0.0.180 port 2225 -> 172.16.9.5 port 22 tcp
rdr vioif0 10.0.0.180 port 2226 -> 172.16.9.6 port 22 tcp
```

and enable ip forwarding and the ipfilter service in the retro VM:

```
[root@27882aaa ~]# routeadm -e ipv4-forwarding
[root@27882aaa ~]# svcadm enable ipfilter
```

We can then ssh into our individual build zones with the following changes added
to `~/.ssh/config`. Note that we manually added 'jenkins' non-root users to our
zones here, and chose a simple alphabetic pattern to name build zones, each
corresponding to a different build zone image.

```
Host retro-kabuild2
        User jenkins
        Hostname 10.0.0.180
        Port    2222

Host retro-kbbuild2
        User jenkins
        Hostname 10.0.0.180
        Port    2223

Host retro-kcbuild2
        User jenkins
        Hostname 10.0.0.180
        Port    2224

Host retro-kdbuild2
        User jenkins
        Hostname 10.0.0.180
        Port    2225

Host retro-kebuild2
        User jenkins
        Hostname 10.0.0.180
        Port 2226
```

Here's us logging in:

```
timf@iorangi-eth0 (master) ssh retro-kabuild2
-bash-4.1$ ifconfig
lo0: flags=2001000849<UP,LOOPBACK,RUNNING,MULTICAST,IPv4,VIRTUAL> mtu 8232 index 1
        inet 127.0.0.1 netmask ff000000
net0: flags=40001000843<UP,BROADCAST,RUNNING,MULTICAST,IPv4,L3PROTECT> mtu 1500 index 2
        inet 172.16.9.2 netmask ffffff00 broadcast 172.16.9.255
lo0: flags=2002000849<UP,LOOPBACK,RUNNING,MULTICAST,IPv6,VIRTUAL> mtu 8252 index 1
        inet6 ::1/128
-bash-4.1$ id
uid=103(jenkins) gid=1(other) groups=1(other)
-bash-4.1$
```

As you can see, we connected to port 2222 of 10.0.0.180, which brought us to
the build zone that has the local IP address 172.16.9.2.
