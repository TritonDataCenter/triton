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

This repository is the starting point for SDC - all of the code lives in
other repos.  See the [repo list](docs/developer-guide/repos.md).


## Getting Started

### Cloud on a Laptop (CoaL)

An easy way to try SmartDataCenter is by downloading the Cloud on a Laptop
(CoaL) image.  This is a VMware image that you can import and setup for testing
or development.

TODO: Instructions on how to download and install coal.


### Installing

TODO: How to obtain an image

Once you have downloaded an image, you will need to
[write it to a USB key](https://docs.joyent.com/sdc7/installing-sdc7/creating-a-usb-key-from-a-release-tarball),
boot the machine with it, and follow the install prompts.  See the
[installing SDC 7](https://docs.joyent.com/sdc7/installing-sdc7) and
[install checklist](https://docs.joyent.com/sdc7/installing-sdc7/install-checklist)
documents for information.

After installation, you will probably want to perform some
[additional configuration](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration).
The most common of these include:

* [Adding external nics to the imgapi and adminui zones](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration#AddingExternalNICstoHeadNodeVMs)
  to give them internet access.  This enables simple import of VM images.
* [Provision a cloudapi zone](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration#CreatingCloudAPI)
  to allow users to create and administer their VMs without an operator.

See the
[post-installation configuration documentation](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration)
for the complete list.


### Building

SDC is composed of several pre-built components:

* A [SmartOS platform image](https://github.com/joyent/smartos-live)
* [Images](https://docs.joyent.com/sdc7/working-with-images) for SDC
  services, which are provisioned as VMs at install time.
* Agents, which are bundled into a [shar file](https://github.com/joyent/sdc-agents-core)
  that can then be installed into the global zone of Compute Nodes.

All of these components other than SmartOS are built using
[Mountain Gorilla](https://github.com/joyent/mountain-gorilla). See its
[README](https://github.com/joyent/mountain-gorilla/blob/master/README.md) for
instructions on building these images.

The images from Mountain Gorilla are stored in
[Manta](https://www.joyent.com/products/manta).  They are then combined into
a boot image that can be written to a USB key and used to boot a headnode.  The
[sdc-headnode](https://github.com/joyent/sdc-headnode) repo automates this
process. See the
[sdc-headnode README](https://github.com/joyent/sdc-headnode/blob/master/README.md)
for instructions.


### Contributing

* Reporting bugs / feature requests: [sdc project issues](https://github.com/joyent/sdc/issues)
* Contributing code: make a pull request to the appropriate repo.

If you're contributing something substantial, you should contact developers on
the mailing list or IRC first.

For issues with Joyent's public cloud or production Manta service, contact
Joyent support instead.

To report bugs or request features, submit issues to the Manta project on
Github.  If you're asking for help with Joyent's production Manta service,
you should contact Joyent support instead.  If you're contributing code, start
with a pull request.

SDC repositories follow the
[Joyent Engineering Guidelines](https://github.com/joyent/eng).  Notably:

* The #master branch should be first-customer-ship (FCS) quality at all times.
  Don't push anything until it's tested.
* All repositories should be "make check" clean at all times.
* All repositories should have tests that run cleanly at all times.

"make check" checks both JavaScript style and lint.  Style is checked with
[jsstyle](https://github.com/davepacheco/jsstyle).  The specific style rules are
somewhat repo-specific.  Style is somewhat repo-specific.  See the jsstyle
configuration file or JSSTYLE\_FLAGS in Makefiles in each repo for exceptions
to the default jsstyle rules.

Lint is checked with
[javascriptlint](https://github.com/davepacheco/javascriptlint).  ([Don't
conflate lint with
style!](http://dtrace.org/blogs/dap/2011/08/23/javascriptlint/)  There are gray
areas, but generally speaking, style rules are arbitrary, while lint warnings
identify potentially broken code.)  Repos sometimes have repo-specific lint
rules - look for tools/jsl.web.conf and tools/jsl.node.conf for per-repo
execeptions to the default rules.


## Design principles

SmartDataCenter is very opinionated about how to architect a cloud.  These
opinions are the result of many years of deploying and debugging the Joyent
Public Cloud (JPC).  Design principles include the following:

* A VM's primary storage should be a local disk, not over the network - this
  avoids difficult to debug performance pathologies.
* Communication between internal APIs should occur in its own control plane
  (network) that is separate from the customer networks. Avoid communicating
  over the open Internet if possible.
* A provisioned VM should rely as little as possible on SDC services outside of
  the operating system for its normal operation.

The goals behind the design of SDC services include:

* All parts of the stack should be observable.
* The state of the running service should be simple to obtain.
* The internals of the system should make it straightfoward to debug from a
  core file (from a crash or taken from a running process using
  [gcore (1)](http://smartos.org/man/1/gcore))
* Services should be RESTful unless there is a compelling reason otherwise.
* Services should avoid keeping state and should not assume that there is
  only one instance of that service running. This allows multiple instances
  of a service to be provisioned for High Availability.
* C and node.js should be used for new services.


## Dependencies

SmartDataCenter uses [SmartOS](https://smartos.org) as its hypervisor.


## License

SmartDataCenter is licensed under the
[Mozilla Public License, v. 2.0](http://mozilla.org/MPL/2.0/). It uses
[SmartOS](http://smartos.org), which is its own project and
[licensed separately](http://smartos.org/cddl/).
