# SmartDataCenter Troubleshooting

This document tries to capture some of the less known SmartDataCenter
troubleshooting steps and fixes. A more comprehensive troubleshooting guide
can be found here: [Troubleshooting SDC7](https://docs.joyent.com/sdc7/troubleshooting-sdc7)

## Upgrade related issues

### Offending SAPI record in SAPI database

This condition can arise in situations where SAPI fails to upgrade
cleanly during a SmartDataCenter upgrade.

Symptoms include:
  * SAPI zone fails to upgrade/re-provision cleanly
  * a new SAPI zone with the alias "sapi0tmp" is visible
  * the overall SDC upgrade process can't continue

Requirements:
  * headnode root access

How to diagnose:

  1. Log into SDC headnode
  2. Verify sapi instances registered in SAPI:

  `sdc-sapi /instances?service_uuid=$(sdc-sapi /services?name=sapi|json -Ha uuid)|json -Ha`

  3. Verify sapi instances registered in VMAPI:

  `sdc-vmapi /vms?query=\(alias=sapi*\)|json -Ha uuid state`

  4. Determine which sapi instance is inactive "not running" in VMAPI

The fix:

  1. Delete the inactive sapi instance from SAPI (previously obtained from VMAPI):

  `sdc-sapi /instances/<INSTANCE_UUID> -X DELETE`


Once the offending record is removed the SDC upgrade process can continue.
