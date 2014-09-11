<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright (c) 2014, Joyent, Inc.
-->

# Joyent SmartDataCenter

TODO(trentm): bit more overview here

SmartDataCenter (SDC) is open source cloud computing software. It is
the same software that runs Joyent's Public Cloud and numerous
on-premise private clouds.
* Distributed system written in Node.js on SmartOS.
* High-performance SmartOS Zones (containers) with KVM support.

This repository is the starting point for SDC. All of the code lives in
other repos. See the [repo list](docs/developer-guide/repos.md).


## Getting Started

### Cloud on a Laptop (CoaL)

An easy way to try SmartDataCenter is by downloading the Cloud on a Laptop
(CoaL) image. This is a VMware virtual appliance that you can use for testing
or development.

TODO: Instructions on how to download and install CoaL.


### Installing

TODO: Supported hardware: Joyent-branded, certified hardware, known to work,
min features & capacities

TODO: How to obtain an image

Once you have downloaded an image, you will need to
[write it to a USB key](https://docs.joyent.com/sdc7/installing-sdc7/creating-a-usb-key-from-a-release-tarball),
boot the machine from the key, and follow the install prompts. See
[Installing SDC 7](https://docs.joyent.com/sdc7/installing-sdc7) and
[Installation Checklist](https://docs.joyent.com/sdc7/installing-sdc7/install-checklist).

After installation, you will probably want to perform some
[additional configuration](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration).
The most common of these include:
* [Adding external nics to the imgapi and adminui zones](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration#AddingExternalNICstoHeadNodeVMs)
  to give them Internet access. This enables simple import of VM images.
* [Provision a cloudapi zone](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration#CreatingCloudAPI)
  to allow users to create and administer their VMs without an operator.

See
[Post-Installation Configuration](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration).


### Building

SmartDataCenter components are built using [Mountain Gorilla](https://github.com/joyent/mountain-gorilla).
The exception to this is the [SmartOS platform image](https://github.com/joyent/smartos-live).

There are two types of SDC components built by Mountain Gorilla:
* Agents which are bundled into a [shar file](https://github.com/joyent/sdc-agents-core)
  and installed into the global zone of SDC compute nodes.
* Images for SDC services which are provisioned as zones.

The builds from Mountain Gorilla are stored in the
[Joyent Manta public cloud](https://www.joyent.com/products/manta).
Joyent Manta is also its own [open source
software project](https://github.com/joyent/manta). The built components are then combined into
a bootable disk image that can be written to a USB key and used to boot
an SDC head node.  The
[sdc-headnode](https://github.com/joyent/sdc-headnode) repo automates this
process. See the
[sdc-headnode README](https://github.com/joyent/sdc-headnode/blob/master/README.md).

See the [Mountain Gorilla README](https://github.com/joyent/mountain-gorilla/blob/master/README.md).


## Contributing

TODO: add mailing list & IRC info

* Reporting a bug or feature request: [sdc project issues](https://github.com/joyent/sdc/issues).
* Contributing code: make a pull request to the specific component's repo.

If you're contributing something substantial, please contact developers on
the mailing list or IRC first.

For issues with Joyent's public cloud or Manta service, [contact
Joyent support](https://www.joyent.com/developers) instead.

SDC repositories follow the
[Joyent Engineering Guidelines](https://github.com/joyent/eng). Notably:
* Use the master branch for development and releases.
* The master branch should be [FCS quality all the time](https://github.com/joyent/eng/blob/master/docs/index.restdown#L43).
* `make check` runs clean at all times.
* Tests run cleanly at all times.

`make check` checks both JavaScript style and lint.

Style is checked with [jsstyle](https://github.com/davepacheco/jsstyle). The
Style is somewhat repo-specific. See the jsstyle configuration file or
JSSTYLE\_FLAGS in makefiles in each repo for exceptions to the
default jsstyle rules.

Lint is checked with [javascriptlint](https://github.com/davepacheco/javascriptlint).
([Don't conflate lint with style!](http://dtrace.org/blogs/dap/2011/08/23/javascriptlint/)
There are gray areas, but generally speaking, style rules are arbitrary, while
lint warnings identify potentially broken code.) Repos sometimes have
repo-specific lint rules - look for tools/jsl.web.conf and tools/jsl.node.conf
for per-repo exceptions to the default rules.


## Design Principles

SmartDataCenter's architect is the result of many years of deploying and
debugging Joyent's public cloud. Design principles include:

* A VM's normal operation should rely as little as possible on SDC services.
* A VM's primary storage should be a local disk, not over the network - this
  avoids difficult to debug performance pathologies.
* Communication between internal APIs should occur in its own control plane
  (network).

The goals behind the design of SDC services include:

* All parts of the stack should be observable.
* The state of the running service should be simple to obtain.
* The internals of the system should make it straightfoward to debug from a
  core file (from a crash or taken from a running process using
  [gcore (1)](http://smartos.org/man/1/gcore))
* Services should be RESTful unless there is a compelling reason otherwise.
* Services should avoid keeping state and should not assume that there is
  only one instance of that service running. This allows multiple instances
  of a service to be provisioned for high availability.
* Node.js and C should be used for new services.


## Dependencies

SmartDataCenter uses [SmartOS](http://smartos.org) as its hypervisor.


## License

SmartDataCenter is licensed under the
[Mozilla Public License version 2.0](http://mozilla.org/MPL/2.0/). It uses
[SmartOS](http://smartos.org), which is its own project and
[licensed separately](http://smartos.org/cddl/).
