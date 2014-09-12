# CoaL headnode setup

"CoaL" stands for "Cloud on a Laptop". It is a VMware virtual appliance for
a SmartDataCenter headnode -- useful for testing or development of SDC. This
document walks through booting and setup of a CoaL. See [this section of the
README](https://github.com/joyent/sdc#cloud-on-a-laptop-coal) for the requisite
VMware setup and where to download a recent CoaL build.

At a high level the CoaL setup procedure is:

1. Boot the appliance in VMware.
2. Work through interactive prompts for basic config information for the
   CoaL datacenter. The config is saved and the appliance reboots.
3. On reboot with a config the SDC services (zones and agents) are
   installed and setup. This can take from 10 to 20 minutes depending on
   how RAM, CPU and disk limits of your host computer running VMware.
4. Login to your SDC headnode and play/test/develop with it.


## Coal setup walkthrough

TODO



## Post-setup

The base setup of a SmartDataCenter headnode is minimal. In short it is
"everything up to the [Operator Portal](../glossary.md#operator-portal)."
For example, there is no customer public API instance (CloudAPI), no services
have been given access to the "external" network (locked down by default).
See the [post-installation configuration
documentation](https://docs.joyent.com/sdc7/installing-sdc7/post-installation-configuration)
for others and instructions.

