<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2019 Joyent, Inc.
    Copyright 2024 MNX Cloud, Inc.
-->

# Triton Contribution Guidelines

Thanks for using Triton and for considering contributing to it!

## Code

All changes to Triton project repositories go through code review via a GitHub
pull request.

If you're making a substantial change, you probably want to contact developers
[on the mailing list or IRC](README.md#community) first. If you have any trouble
with the contribution process, please feel free to contact developers [on the
mailing list or IRC](README.md#community). Note that larger Triton project
changes are typically designed and discussed via ["Requests for Discussion
(RFDs)"](https://github.com/TritonDataCenter/rfd).

Triton repositories use the [Triton Engineering
Guidelines](https://github.com/TritonDataCenter/eng/blob/master/docs/index.md).
Notably:

* The #master branch should be first-customer-ship (FCS) quality at all times.
  Don't push anything until it's tested.
* All repositories should be "make check" clean at all times.
* All repositories should have tests that run cleanly at all times.

## Issues

There are two separate issue trackers that are relevant for Triton code:

* An internal JIRA instance.

  A JIRA ticket has an ID like `IMGAPI-536`, where "IMGAPI" is the JIRA project
  name -- in this case used by the
  [sdc-imgapi](https://github.com/TritonDataCenter/sdc-imgapi) and related
  repos. A read-only view of most JIRA tickets is made available at
  <https://smartos.org/bugview/> (e.g.
  <https://smartos.org/bugview/IMGAPI-536>).
* GitHub issues for the relevant repo, e.g.
  <https://github.com/TritonDataCenter/triton/issues>.

Before Triton was open sourced, Joyent engineering used a private JIRA instance.
While we continue to use JIRA internally, we also use GitHub issues for
tracking -- primarily to allow interaction with those without access to JIRA.

## Code of Conduct

All persons and/or organizations contributing to, or intercting with our
repositories or communities are required to abide by the
[illumos Code of Conduct][coc].

[coc]: https://github.com/TritonDataCenter/illumos-joyent/blob/master/CODE_OF_CONDUCT.md
