# Updating SmartDataCenter

This document describes how to update a SmartDataCenter.

The primary tool for SDC updates is `sdcadm`. At the time of writing the
`sdcadm` tool is still under heavy development and is not yet ready for updating
in production. See [the sdcadm repo](https://github.com/joyent/sdcadm#readme)
for status and the current documentation on doing a full upgrade of SDC.


## Channels

As of `sdcadm` version 1.5.5 and the release-20150319, SmartDataCenter has
*preliminary* support for update "channels". A "channel" is separate stream of
built SDC components with different stability characteristics. Current channels
are:

    NAME          DESCRIPTION
    experimental  feature-branch builds (warning: 'latest' isn't meaningful)
    dev           main development branch builds
    staging       staging for release branch builds before a full release
    release       release bits
    support       Joyent-supported release bits

Use the `sdcadm channel ...` command to list and set your channel:


    [root@headnode (coal) ~]# sdcadm channel set release
    Update channel has been successfully set to: 'release

    [root@headnode (coal) ~]# sdcadm channel list
    NAME          DEFAULT  DESCRIPTION
    experimental  -        feature-branch builds (warning: 'latest' isn't meaningful)
    dev           -        main development branch builds
    staging       -        staging for release branch builds before a full release
    release       true     release bits
    support       -        Joyent-supported release bits

It is recommended that production installations of SDC use the "release"
channel. SDC developers will want the "dev" channel (to get access to
"#master" branch builds). Joyent SmartDataCenter supported customers should
eventually use the "support" channel.

Every second Thursday we roll a "release-YYYYMMDD" release branch and
builds for all SmartDataCenter (and Manta) repositories. These go to the
"staging" branch. After a complete set of builds and basic sanity checking,
those are added to the "release" channel.
