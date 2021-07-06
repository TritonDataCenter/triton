# SmartDataCenter FAQ

Frequently asked questions about SmartDataCenter (SDC).

If you have a question, please ask on any of
[sdc-discuss mailing list](mailto:sdc-discuss@lists.smartdatacenter.org)
([subscribe](https://www.listbox.com/subscribe/?list_id=247449),
[archives](http://www.listbox.com/member/archive/247449/=now)),
**#smartos** on the [Libera.chat IRC network](https://libera.chat),
or in a [joyent/sdc issue](https://github.com/joyent/sdc/issues).


## Q: I already have SmartOS on my system; how do I upgrade to SDC?

A: SmartOS is designed as a standalone, single-node environment. There is no way
to upgrade a SmartOS node to an SDC headnode or compute node. Instead, create a
new SDC environment and provision new instances there. Once an SDC headnode is
setup, you may convert a SmartOS node to an SDC compute node by booting into
"noinstall" mode, destroying the storage pool, and attaching the system to the
SDC networks [as
documented](https://docs.joyent.com/private-cloud/install/compute-node-setup).  This
will destroy all existing instances and result in a new, empty SDC compute node
ready for provisioning.  Migration of instances from SmartOS to SDC compute
nodes and between SDC compute nodes may be possible using
[vmadm(1m)](http://smartos.org/man/1m/vmadm) and ZFS commands but is not a
supported product feature and is not recommended.

## Q: My compute node failed to setup; how can I find out what went wrong?

A: Find the IP of the compute node from the [Admin
UI](./glossary.md#adminui). Obtain the compute node root password by
running `/usbkey/scripts/mount-usb.sh && cat
/mnt/usbkey/private/root.password.*` on your headnode. Run `bunyan $(svcs
-L ur)` on the compute node and check
the output for errors. The relevant output will likely be at the tail.

