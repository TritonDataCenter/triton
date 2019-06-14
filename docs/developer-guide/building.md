---
Building Triton and Manta
---

## Introduction

[Triton](https://github.com/joyent/triton/#triton-datacenter) and
[Manta](https://github.com/joyent/manta#manta-tritons-object-storage-and-converged-analytics-solution)
is composed of an operating system, a series of components which run the
services that make up the system, and a set of administrative tools.
Many of the components are deployed inside dedicated SmartOS zones.
You may find the [architecture diagram](https://github.com/joyent/triton/blob/master/docs/developer-guide/architecture.md) useful to refer to.

All of that software can be built directly from
[the sources on github](https://github.com/joyent/triton/blob/master/docs/developer-guide/repos.md)
and the resulting components can be assembled into an image that you can install
on your own hardware.

This guide tells you how to get started.

If you're working on Manta, or are interested about other aspects of the build
system, see the [Manta dev notes](https://github.com/joyent/manta/blob/master/docs/dev-notes.md).

## Prerequisites

 * we assume you have npm/node installed on your workstation
 * we assume you have git installed on your workstation
 * we assume you have json (npm install -g json) installed on your workstation
 * we assume you understand the basics of Triton, if not please start with [the
   Triton README](https://github.com/joyent/triton#readme)
 * we assume you have your SSH keys loaded in your ssh-agent when connecting
   to build zones via SSH.

## Decisions to Make

To build Triton and Manta components you first need to make some choices:

 * [which components are you going to build?](#components)
 * [where are you going to build those components?](#buildzone)

<a name="components"></a>

## Components

Many components that make up part of Triton or Manta are formed from a
`base image` (or `origin image`) installed with a specific set of packages
from a given pkgsrc release, along with the software that implements the
services delivered by that component. Some components are services or
software that run directly on the system, either on the "global zone"
itself, or installed within other zones.

The different components have different build zone requirements, since
different components deploy with different origin images. We require the
build zone to be running the same pkgsrc release that the component will
ultimately be deployed with. A build zone is composed of a base image at
a given pkgsrc release and a set of developer tools.

The top-level `Makefile` in each component repository includes metadata to
declare what build zone it needs. The `make validate-buildenv` target in each
component `Makefile` will determine whether the build zone and environment is
correctly configured. The `make show-buildenv` will give a short summary of the
expected build zone.

A few components have quite tailored build systems, such as
[`smartos-live`](https://github.com/joyent/smartos-live#smartos-live-smartos-platform),
which builds the operating system and associated services (collectively known
as the `platform`) or
[`sdc-headnode`](https://github.com/joyent/sdc-headnode/#sdc-headnode),
which assembles components into a bootable USB, iso or vmware image.

For the most part though, components share the same `Makefile` rules to make
it easier for developers to build any component.

<a name="buildzone"></a>

## Where to build

Triton/Manta components are built inside build zones that run on
either of two platforms, Triton or SmartOS.

The tooling to create build zones differs across these platforms, so please
read **[Build Zone Setup For Manta and Triton](./build-zone-setup.md)** to
get started.

If you're not developing the operating system itself (the `platform` component)
it is possible to partially develop and test on other platforms (e.g OS X or
Linux) However, doing complete builds of components requires ZFS tooling that
is only supported on Triton/SmartOS at the time of writing.

One exception to the above is the `sdc-headnode` build which can be built on
OS X and Linux in addition to Triton or SmartOS.

It is also possible to build on virtual machines (vmware, kvm, bhyve, etc.)
hosting SmartOS, or a
[Triton "CoaL" ("Cloud on a Laptop")](https://github.com/joyent/triton/blob/master/docs/developer-guide/coal-setup.md) instance, though your virtualization platform will need to allow nested
virtualization in order to host the 'retro' build zones that we talk about later
in this document.

<a name="makefile-targets"></a>

## Building a component

Having [setup and logged into the correct build zone for your component](./build-zone-setup.md),
you should now be able to clone any of the
[Manta or Triton repositories](./repos.md).

The following Makefile targets are conventions used in most Manta/Triton
components:

  | target               | description
  |----------------------|----------------------------------------------------------------------------------
  | show-buildenv        |  show the build environment and build zone image uuid for building this component
  | validate-buildenv    |  check that the build machine is capable of building this component
  | all                  |  build all sources for this component
  | release              |  build a tarball containing the bits for this component
  | publish              |  publish a tarball containing the bits for this component
  | buildimage           |  assemble a Triton/Manta image for this component
  | bits-upload          |  post bits to Manta, and optionally updates.joyent.com for this component
  | bits-upload-latest   |  just post the most recently built bits, useful in case an upload was interrupted
  | check                |  run build tests (e.g. xml validation, linting)
  | prepush              |  additional testing that should occur before pushing to github


For more details on the specifics of these targets, we do have commentary in
[eng.git:/Makefile](https://github.com/joyent/eng/blob/master/Makefile#L11) and
[eng.git:/tools/mk/Makefile.defs](https://github.com/joyent/eng/blob/master/tools/mk/Makefile.defs#L29).

Typically, the following can be used to build any component, and will leave
a component image (a compressed zfs send stream and image manifest) in `./bits`
along with some additional metadata about the build:

```
$ export ENGBLD_SKIP_VALIDATE_BUILD_PLATFORM=true
$ make all release publish buildimage
```

The build will happily run as a non-root user (recommended!), however some
parts of the build do need additional privileges. To add those to your non-root
user inside your build zone, do:

```
# usermod -P 'Primary Administrator' youruser
```

For building some components, your user should have an ssh key that allows you
to access private Joyent repos. You should also have Manta environment
variables set to allow the build to publish artifacts to Manta if that's
required (see ["Configuring the build zone"](./build-zone-setup.md#build-zone-configuration) in
the "Build Zone Setup For Manta and Triton" document)

### Additional notes on build artifacts

The `bits-upload` or `bits-upload-latest` Makefile targets will upload built
components from `./bits` using the `./deps/eng/tools/bits-upload.sh` script.

   * `bits-upload` will publish bits to `$MANTA_USER/publics/builds/<component>`
     by default, and will use `$MANTA_USER`, `$MANTA_KEY_ID` and `$MANTA_URL`
     to determine the Manta address to post to.

   * `bits-upload-latest` will attempt to retry the last upload, in case of
      network interruption, but will otherwise not re-create any of the build
      artifacts.

   * publishing bits to the imgapi service on https://updates.joyent.com from
     `bits-upload` requires you to have credentials configured there to allow
     you to upload.

   * By default, publishing to https://updates.joyent.com is disabled and will
     only happen if `$ENGBLD_BITS_UPLOAD_IMAPI=true` in your shell environment.
     You can also publish bits to a local (or NFS) path instead of Manta and
     imgapi.
     To do that, set `$ENGBLD_DEST_OUT_PATH` and `$ENGBLD_BITS_UPLOAD_LOCAL`

     For example:
     ```
     export ENGBLD_DEST_OUT_PATH=/home/timf/projects/bits
     export ENGBLD_BITS_UPLOAD_LOCAL=true
     ```
     This can be useful if doing a local `sdc-headnode` build.

   * You can change which imgapi instance your build posts to by setting
     `$UPDATES_IMGADM_USER`, `$UPDATES_IMG_URL` and `$UPDATES_IMGADM_IDENTITY`
     in your environment. If not set, `$UPDATES_IMGADM_CHANNEL` is computed
     automatically. See `./deps/eng/tools/bits-upload.sh`

### Building from Gerrit

When reviewing proposed changes from Gerrit, it can be useful to build and
deploy those directly.

Here we build patch set 2 of the `sdc-sapi.git` component, which has the
gerrit id `5538`:

```
-bash-4.1$ cd /tmp
-bash-4.1$ git clone https://cr.joyent.us/joyent/sdc-sapi.git
Cloning into 'sdc-sapi'...
remote: Counting objects: 2180, done
remote: Finding sources: 100% (2180/2180)
remote: Total 2180 (delta 1464), reused 2175 (delta 1464)
Receiving objects: 100% (2180/2180), 540.64 KiB | 251.00 KiB/s, done.
Resolving deltas: 100% (1464/1464), done.
Checking connectivity... done.
-bash-4.1$ cd sdc-sapi
-bash-4.1$ git ls-remote | grep 5538
From https://cr.joyent.us/joyent/sdc-sapi.git
d2daf78578e3854069cbe194f5f9cf4c96571d22        refs/changes/38/5538/1
53f51b8e1b4e6088b22757ee230edc9b6974e46e        refs/changes/38/5538/2
-bash-4.1$ git fetch origin refs/changes/38/5538/2
remote: Counting objects: 13, done
remote: Finding sources: 100% (7/7)
remote: Total 7 (delta 6), reused 7 (delta 6)
Unpacking objects: 100% (7/7), done.
From https://cr.joyent.us/joyent/sdc-sapi
 * branch            refs/changes/38/5538/2 -> FETCH_HEAD
 -bash-4.1$ git checkout FETCH_HEAD
Note: checking out 'FETCH_HEAD'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

  HEAD is now at 53f51b8... TRITON-1131 convert sdc-sapi to engbld framework
  -bash-4.1$ git describe --all --long
  heads/master-1-g53f51b8
-bash-4.1$ make all release publish buildimage
fatal: ref HEAD is not a symbolic ref
/tmp/space/sdc-sapi/deps/eng/tools/validate-buildenv.sh
.
.
[ 29.00080643] Saving manifest to "/tmp/sapi-zfs--20190215T144650Z-g53f51b8.imgmanifest"
[ 30.24198958] Destroyed zones/3923c435-8688-47bb-a5f1-b213b010f826/data/b9f703a4-52e1-4c3d-b862-29b8dd047669
[ 30.29018650] Deleted /zoneproto-49345
[ 30.29080095] Build complete
cp /tmp/sapi-zfs--20190215T144650Z-g53f51b8.zfs.gz /tmp/space/sdc-sapi/bits/sapi
cp /tmp/sapi-zfs--20190215T144650Z-g53f51b8.imgmanifest /tmp/space/sdc-sapi/bits/sapi
pfexec rm /tmp/sapi-zfs--20190215T144650Z-g53f51b8.zfs.gz
pfexec rm /tmp/sapi-zfs--20190215T144650Z-g53f51b8.imgmanifest
pfexec rm -rf /tmp/buildimage-sapi--20190215T144650Z-g53f51b8
-bash-4.1$
```

Note that the first build of components on a new dev zone will likely take
a little longer than usual as the `agent-cache` framework has to build each
agent to be included in the image, and the `buildimage` tool has to download
and cache the base images for the component. See TOOLS-2063 and TOOLS-2066.

Also note in the above, that the `$(BRANCH)` used for the build artifacts looks
a little unusual due to the fact we checked out a gerrit branch that doesn't
follow the same naming format as most git branches.
