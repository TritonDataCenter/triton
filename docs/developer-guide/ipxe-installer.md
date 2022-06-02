<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2021, Joyent, Inc.
    Copyright 2022 MNX Cloud, Inc.
-->

# Triton iPXE Installation

Some deployments, for example on to a Bare-Metal as a Service (BMaaS)
provider, may use single-shot iPXE boots to install an operating system.

The Triton iPXE installer behaves much like the [ISO installer][triton-iso-doc]
in that it should boot once, and during the reboot mid-installation the on-disk
portion should take over.  It is important that the iPXE Triton boot happen
only once for a head node installation.

Unlike the ISO installer, the iPXE installation requires that network
reachability be enabled DURING the installation process.  The installer
script will post a reminder of this.  Most of the time, the iPXE installer
needed network reachability to start in the first place, so configuring the
head node to reach the iPXE downloads should not be difficult.  The network
is required to be able to download images that are normally on the ISO DVD
image for the ISO installer, but cannot fit into an iPXE ramdisk root.  This
network must be at least `/30`. If your provider allocates a `/31`, you should
configure Triton with a shorter prefix length so that neither the headnode IP
nor the gateway IP are the network or broadcast numbers. In general this should
not cause a problem as long as the host and gatway IPs used are those specified
by the provider's allocation. The minimum *recommended* external network size
is `/28`.

## Configuring an iPXE Server for a Triton Installation

An iPXE installation needs to pull necessary files via HTTP/HTTPS for
installation.  We provide a [tar archive][triton-ipxe] that can be installed on
a web server that an iPXE client can reach.

The tar archive also includes a full tar archive of the
[ISO installer][triton-iso-doc] contents because an iPXE ramdisk image is not
large enough to hold all of the Triton images required for an installation, and
the iPXE installer must download the images after it has booted.

The included ipxe script defaults to ttyb (COM2) for the installer.  This can
be changed in the ipxe file if necessary.

Using the example server above, once it has been setup, an iPXE client should
access `https://ipxe.example.com/triton/triton-installer.ipxe` to install the
Triton head node.

## Using Joyent's Netboot server

Joyent also provides a netboot server that you can use with iPXE to chain load
the Triton installer and is kept up to date with the latest release.  To install
Triton using the iPXE installer, chain load the installer URL.

    chain https://netboot.smartos.org/triton-installer/triton-installer.ipxe

After provisioning your headnode, connect to the serial console to configure
the installation.  Currently the installer is hard coded to use ttyb (COM2) for
the installer.

### Automating Triton setup on third-party bare metal hosting providers

Triton has support for fully-automated installation with third-party bare metal
hosting providers.  This works by loading the hosting provider's metadata object
onto the filesystem as a boot module.  Currently, only [Equinix Metal][eqm] is
supported.

#### Equinix Metal

To install Triton on Equinix Metal use the [`triton-eqm-create.sh`][eqm-script]
script in this repository.  The Triton installer will use the Equinix Metal
metadata object to derive most values (e.g., IP addresses and interface
configuration) needed by the installer.  Not all values needed by Triton are
present in Equinix's metadata object so additional elements can be included by
providing JSON file.  The file format and keys are the same as
[`answers.json`][hn] file used by Triton.

The following keys are supported.  For any keys that are not present, a suitable
default will be used.

| Key                       | Default      |
| ------------------------- | ------------ |
| `company_name`            | Empty string |
| `datacenter_location`     | Empty string |
| `region_name`             | Leading alpha characters of `datacenter_name`, which will be the Equnix Metal `facility`  (e.g., `iad`) |
| `dns_resolver1`           | `8.8.8.8` |
| `dns_resolver2`           | `8.8.4.4` |
| `dns_domain`              | `triton.local` |
| `mail_to`                 | `root@localhost` |
| `mail_from`               | `support@`<dns_domain> |
| `ntp_host`                | `0.smartos.pool.ntp.org` |
| `root_password`           | Randomly generated (you will need to use your Equinix Metal SSH keys to log in) |
| `admin_password`          | Randomly generated.  You can find this password in `/usbkey/config` |
| `update_channel`          | `release` |

SSH keys present in your Equinix Metal account will be added to `root`'s
`~/.ssh/authorized_keys` file.

To use the `triton-eqm-create.sh` script you need the [`packet-cli`][p-cli]
installed and configured on your workstation.  Once this is done, use the
following steps to create a new Triton cloud.

1. Create a project to contain the assets for your Triton Cloud.  This will also
   create the necessary VLANs in the specified facility.

        triton-eqm-create.sh project -n My-Triton-Project

2. After the project has been created, you can create the headnode.  Passing an
   answers file is optional, other values are required.  The hardware plan
   defaults to `c3.small.x86` but can be changed with `-P`.

        triton-eqm-create.sh headnode -p <project_id> -f sv15 -a my-answers.json

3. Connect to the Equinix Metal "`sos`" console to watch the progress (the
   correct `ssh` command will be printed for you).  There are some issues that
   will occasionally prevent properly chain loading the iPXE URL.  If this
   happens, delete the server and try again.

4. After the installer finishes (which takes about 10 minutes) you will be able
   to `ssh` as `root` to the headnode's external IP.

5. Refer to the [Triton Operator Documentation][ops-docs] for post-install
   operation and configuration of your new Triton Cloud.

6. After post-install tasks are complete, create additional Compute Nodes.

        triton-eqm-create.sh computenode -p <project_id> -f iad1

<!-- Footnote style links -->

[triton-ipxe]: https://us-east.manta.joyent.com/Joyent_Dev/public/SmartDataCenter/ipxe-latest.tgz
[triton-iso-doc]: ./iso-installer.md
[eqm]: https://metal.equinix.com/
[tink]: https://tinkerbell.org
[eqm-script]: ../../tools/triton-eqm-create.sh
[hn]: https://github.com/TritonDataCenter/sdc-headnode/
[p-cli]: https://github.com/packethost/packet-cli
[ops-docs]: https://docs.joyent.com/private-cloud/
