<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2021, Joyent, Inc.
-->

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
system, see the [Manta developer guide](https://github.com/joyent/manta/tree/master/docs/developer-guide).

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
     `$UPDATES_IMGADM_USER`, `$UPDATES_IMGADM_URL` and `$UPDATES_IMGADM_IDENTITY`
     in your environment. If not set, `$UPDATES_IMGADM_CHANNEL` is computed
     automatically. See `./deps/eng/tools/bits-upload.sh`

### Useful development tools and dealing with GitHub Pull Requests

Setting up the following tools is likely to make your work on Manta and Triton
a little easier:

* [hub](https://hub.github.com/) is a command line extension to git, with
  particularly useful commands to list, checkout and create pull requests.
* [jr](https://github.com/joyent/joyent-repos) is a tool that makes it
  easier to interact with the many Joyent repositories you'll be working with
  when developing Manta and Triton. It allows you to list and clone
  repositories, as well as allowing you to run commands that affect multiple
  repositories.
* [prr](https://github.com/joyent/prr/) is a command line tool for merging an
  approved pull request, allowing you to modify the commit message.

Developers on Manta/Triton use GitHub pull requests to seek code review from
other developers before committing changes to the repository.

The `hub` command makes it simple to create a new pull request:

```
-bash-4.3$ cd /tmp/sdc-manta
-bash-4.3$ echo "Make a change to this file." >> README.md
-bash-4.3$ git commit -m "MANTA-1234 an example jira synopsis" README.md
[pr-MANTA-1234 8f47ea2] MANTA-1234 an example jira synopsis
 1 file changed, 1 insertion(+)
-bash-4.3$ hub pull-request -p
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 339 bytes | 0 bytes/s, done.
Total 3 (delta 2), reused 0 (delta 0)
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
remote:
remote: Create a pull request for 'pr-MANTA-1234' on GitHub by visiting:
remote:      https://github.com/joyent/sdc-manta/pull/new/pr-MANTA-1234
remote:
remote:
To git@github.com:joyent/sdc-manta
 * [new branch]      HEAD -> pr-MANTA-1234
Branch pr-MANTA-1234 set up to track remote branch pr-MANTA-1234 from origin.
https://github.com/joyent/sdc-manta/pull/23
-bash-4.3$
```

When reviewing proposed changes from GitHub, it can be useful to build and
deploy those directly allowing reviewers to exercise the changes before they're
integrated.


In this example, we'll use `hub` to list all open pull requests, and then to
get the changes from the
[joyent/sdc-manta#21](https://github.com/joyent/sdc-manta/pull/21) pull
request.


```
-bash-4.3$ hub pr list
     #21  MANTA-4744 'manta-adm update' should guard image usage by image.name
     #16  Bump js-yaml from 3.8.2 to 3.13.1   dependencies
      #8  MANTA-4408 Reorder nics for manta prometheus service
      #7  MANTA-3518 fix params.networks formatting of manta services
      #5  MANTA-3974 manta deployment zone adminIp functions need to be factored out MANTA-3971 manta-oneach needs to be rack aware
      #4  MANTA-3274 show how to run sdc-manta 'make test' when developing on non-smartos
-bash-4.3$ hub pr checkout 21
Switched to a new branch 'prr-MANTA-4744'
-bash-4.3$
```

We can build the pull request changes as normal:

```
-bash-4.3$ make all release publish buildimage
Cloning into 'deps/eng'...
remote: Enumerating objects: 177, done.
remote: Counting objects: 100% (177/177), done.
.
.
/usr/bin/pfexec /tmp/sdc-manta.git/deps/eng/tools/buildimage/bin/buildimage \
        -i 04a48d7d-6bb5-4e83-8c3b-e60a99e0f48f \
        -d /tmp/buildimage-manta-deployment-prr-MANTA-4744-20191126T165949Z-gb4cc60e/root \
        -m '{"name": "manta-deployment", "description": "Manta deployment tools", "version": "prr-MANTA-4744-20191126T165949Z-gb4cc60e", "tags": {"smartdc_service": true} }' \
         \
        -p $(echo openldap-client-2.4.44nb2 | sed -e 's/ /,/g') \
        -M -S "$(git -C /tmp/sdc-manta.git remote get-url origin)" \
        -a \
        -P manta-deployment-zfs
[  0.04019809] Starting build for manta-deployment (prr-MANTA-4744-20191126T165949Z-gb4cc60e)
.
.
.
cp /tmp/manta-deployment-zfs-prr-MANTA-4744-20191126T165949Z-gb4cc60e.pkgaudit /tmp/sdc-manta.git/bits/manta-deployment
/usr/bin/pfexec rm /tmp/manta-deployment-zfs-prr-MANTA-4744-20191126T165949Z-gb4cc60e.zfs.gz
/usr/bin/pfexec rm /tmp/manta-deployment-zfs-prr-MANTA-4744-20191126T165949Z-gb4cc60e.imgmanifest
/usr/bin/pfexec rm /tmp/manta-deployment-zfs-prr-MANTA-4744-20191126T165949Z-gb4cc60e.pkgaudit
/usr/bin/pfexec rm -rf /tmp/buildimage-manta-deployment-prr-MANTA-4744-20191126T165949Z-gb4cc60e
-bash-4.3$
```

We can now deploy the image in `/tmp/sdc-manta.git/bits/manta-deployment`.

Note that the first build of components on a new dev zone will likely take
a little longer than usual as the `agent-cache` framework has to build each
agent to be included in the image, and the `buildimage` tool has to download
and cache the base images for the component. See TOOLS-2063 and TOOLS-2066.
