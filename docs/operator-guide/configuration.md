# SmartDataCenter Configuration

This document describes the various knobs with which an operator can configure
a SmartDataCenter. There are two main different groups of configuration:
headnode configuration (stored in "[/mnt]/usbkey/config") and service
configuration (stored as "metadata" on applications, services and instance in
[SAPI](https://github.com/joyent/sdc-sapi)).


## Headnode configuration

TODO


## Service configuration

One of the core services in SDC is SAPI (the Services API). This holds the definitions
of all SDC services. SAPI is organized in a hierarchy:

    Application                 e.g. the 'sdc' application, the 'manta' application
        Service                 e.g. 'vmapi', 'cnapi', 'manatee', 'moray', ...
            Instance            e.g. each of the 'manatee' VMs is an instance
                                The UUID of an instance is the UUID of the VM.

Each level of that hierarchy a "metadata" object (key/value pairs). For example, the
'napi' service metadata:

    [root@headnode (coal) ~]# sdc-sapi /services?name=napi | json -H 0.metadata
    {
      "SERVICE_NAME": "napi",
      "NAPI_LOG_LEVEL": "info",
       ...
    }

and the top-level 'sdc' application metadata:

    [root@headnode (coal) ~]# sdc-sapi /applications?name=sdc | json -H 0.metadata
    {
      ...
      "region_name": "coalregion",
      "datacenter_name": "coal",
      ...
    }

Instance configuration is typically created by rendering a template file
provided by the instance image (these are called "sapi_manifests") with the
combined metadata of the application, service and instance. E.g., for the
'napi0' zone:

    [root@headnode (coal) ~]# sdc-sapi /configs/$(vmadm lookup -1 alias=napi0) | json -H metadata
    {
      "region_name": "coalregion",
      "datacenter_name": "coal",
      ...
      "SERVICE_NAME": "napi",
      "NAPI_LOG_LEVEL": "info",
      ...
    }

This config retrieval, rendering and config file update is handled by the
"config-agent" service.


### Modifying service configuration

TODO: sapiadm, sdc-sapi usage, eventuallly 'sdcadm config'


### SDC Application Configuration

This section documents the SDC config vars that live on the 'sdc' SAPI
application.

Note: This is currently an incomplete list. Also note that currently there is a
large overlap with 'sdc' application metadata (documented here) and headnode
configuration variables (from /usbkey/config, see section above). Then
intention is to eventually reduce that overlap.

| Name | Type | Description |
| ---- | ---- | ----------- |
| account_allowed_dcs | Boolean | Whether to consider 'allowed_dcs' field on UFDS account entries for cloudapi and sdc-docker in this datacenter. See [DOCKER-166](https://smartos.org/bugview/DOCKER-166). |


Example setting a SDC application config var:

    $ sdc-sapi /applications/$(sdc-sapi /applications?name=sdc | json -H 0.uuid) \
        -X PUT -d '{"metadata": {"account_allowed_dcs": true}}'
    ...

    # Check that it was set.
    $ sdc-sapi /applications/$(sdc-sapi /applications?name=sdc | json -H 0.uuid) \
        | json -Ha metadata.account_allowed_dcs
    true

    # Show how to delete it
    $ sdc-sapi /applications/$(sdc-sapi /applications?name=sdc | json -H 0.uuid) \
        -X PUT -d '{"action": "delete", "metadata": {"account_allowed_dcs": null}}'
    ...
    $ sdc-sapi /applications/$(sdc-sapi /applications?name=sdc | json -H 0.uuid) \
        | json -Ha metadata.account_allowed_dcs



### SDC Service Configuration

Many of the SDC services support some configuration variables. This table
provides links to the relevant documentation for each.

| Service |
| ------- |
| [cloudapi](https://github.com/joyent/sdc-cloudapi/blob/master/docs/admin.restdown#L40) |
| [cnapi](https://github.com/joyent/sdc-cnapi/blob/master/docs/index.md#sapi-configuration) |
