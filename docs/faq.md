# SmartDataCenter FAQ

Frequently asked questions about SmartDataCenter (SDC).


## Q: I already have SmartOS on my system; how do I upgrade to SDC?

A: SmartOS is designed as a standalone, single-node environment. There is no way
to upgrade a SmartOS node to an SDC headnode or compute node. Instead, create a
new SDC environment and provision new instances there. Once an SDC headnode is
setup, you may convert a SmartOS node to an SDC compute node by booting into
"noinstall" mode, destroying the storage pool, and attaching the system to the
SDC networks [as
documented](https://docs.joyent.com/sdc7/overview-of-smartdatacenter-7).
Migration of instances from SmartOS to SDC compute nodes and between SDC compute
nodes may be possible using
[vmadm(1m)](http://smartos.org/man/1m/vmadm) and ZFS commands but is not a
supported product feature and is not recommended.
