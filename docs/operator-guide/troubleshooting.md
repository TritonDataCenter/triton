# SmartDataCenter Troubleshooting

This document tries to capture some of the less known SmartDataCenter
troubleshooting steps and fixes. A more comprehensive troubleshooting guide
can be found here: [Troubleshooting SDC7](https://docs.joyent.com/sdc7/troubleshooting-sdc7)

## Upgrade

### Offending SAPI record in SAPI database

This condition can arise in situations where SAPI fails to upgrade
cleanly during a SmartDataCenter upgrade.

**Symptoms include:**
  * SAPI zone fails to upgrade/re-provision cleanly
  * a new SAPI zone with the alias "sapi0tmp" is visible
  * the overall SDC upgrade process can't continue

Example error:

```
This update will make the following changes:
    update "sapi" service to image 3fc4b974-1b08-11e5-a9ba-672a0f7e12c7
    (sapi@release-20150625-20150625T065520Z-g983d6be)

    Would you like to continue? [y/N] y

    Create work dir: /var/sdcadm/updates/20150629T133211Z
    Get SAPI current mode
    Installing image 3fc4b974-1b08-11e5-a9ba-672a0f7e12c7
    (sapi@release-20150625-20150625T065520Z-g983d6be)
    Updating 'sapi-url' in SAPI
    Updating 'sapi-url' in VM 76851b15-46e6-4325-878f-38cfd7558304
    Verifying if we are on an HA setup
    Update error: {"message":"The following SAPI instances are not present
    into VMAPI and should be removed before continue with the upgrade
    process: [object Object]","code":"InternalError","exitStatus":1}
```

**Requirements:**
  * headnode root access

**How to diagnose:**

  1. Log into SDC headnode
  2. Verify sapi instances registered in SAPI:

  `sdc-sapi /instances?service_uuid=$(sdc-sapi /services?name=sapi|json -Ha uuid)|json -Ha`

  ```
  {
    "uuid": "c9742298-6861-42f3-8ebd-56aca525a471",
    "service_uuid": "0e6983da-9a5b-4e7b-84cb-98991bd92334",
    "params": {
      "alias": "sapi0",
      "server_uuid": "fb6e5c86-4247-11e1-a93a-5cf3fcba325c"
    },
    "metadata": {
      "ADMIN_IP": "10.65.65.26",
      "PRIMARY_IP": "10.65.65.26"
    },
    "type": "vm"
  }
  {
    "uuid": "2eeea6fc-e109-473c-b7c3-7374dbb122df",
    "service_uuid": "6283f56a-212d-11e5-88d6-3c970e80eb61",
    "params": {
      "alias": "sapi0tmp",
      "server_uuid": "fb6e5c86-4247-11e1-a93a-5cf3fcba325c"
    },
    "metadata": {
      "ADMIN_IP": "10.65.65.27",
      "PRIMARY_IP": "10.65.65.27"
    },
    "type": "vm"
  }
  ```

  3. Verify sapi instances registered in VMAPI:

  `sdc-vmapi /vms?query=\(alias=sapi*\)|json -Ha uuid state`

```
c9742298-6861-42f3-8ebd-56aca525a471 running sapi0
2eeea6fc-e109-473c-b7c3-7374dbb122df destroyed sapi0tmp
```

  Here we see the UUID identifier of the offending "sapi0tmp" instance
  and its inactive state - in this case destroyed.

  4. Determine which sapi instance is inactive "not running" in VMAPI

  The inactive sapi instance was "sapi0tmp" as shown above.

**The fix:**

  1. Delete the inactive sapi instance from SAPI (previously obtained from VMAPI):

  `sdc-sapi /instances/<INSTANCE_UUID> -X DELETE`

Once the offending record is removed the SDC upgrade process can continue.
