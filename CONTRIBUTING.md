<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2016 Joyent, Inc.
-->

# Triton Contribution Guidelines

Thanks for using Triton and for considering contributing to it!

tl;dr:
- Triton repos do *not* use GitHub pull requests (PRs)! You'll be asked to
  re-submit PRs to Gerrit. See below.
- Triton repos use both GitHub issues and internal-to-Joyent Jira projects for
  issue tracking.


## Code

The Triton project uses Gerrit at [cr.joyent.us](https://cr.joyent.us) for code
review of all changes. Any registered GitHub user can submit changes through
this system. If you want to contribute a change, please see the [Joyent Gerrit
user
guide](https://github.com/joyent/joyent-gerrit/blob/master/docs/user/README.md).
If you're making a substantial change, you probably want to contact developers
[on the mailing list or IRC](README.md#community) first. If you have any trouble
with the contribution process, please feel free to contact developers [on the
mailing list or IRC](README.md#community). Note that larger Triton project
changes are typically designed and discussed via ["Requests for Discussion
(RFDs)"](https://github.com/joyent/rfd).

Triton repositories use the [Joyent Engineering
Guidelines](https://github.com/joyent/eng/blob/master/docs/index.md). Notably:

* The #master branch should be first-customer-ship (FCS) quality at all times.
  Don't push anything until it's tested.
* All repositories should be "make check" clean at all times.
* All repositories should have tests that run cleanly at all times.

"make check" checks both JavaScript style and lint.  Style is checked with
[jsstyle](https://github.com/davepacheco/jsstyle).  The specific style rules are
somewhat repo-specific.  See the jsstyle configuration file or `JSSTYLE_FLAGS`
in Makefiles in each repo for exceptions to the default jsstyle rules.

Lint is checked with
[javascriptlint](https://github.com/davepacheco/javascriptlint). Repos sometimes
have repo-specific lint rules, but this is less common -- look for
"tools/jsl.node.conf" for per-repo exceptions to the default rules.


## Issues

There are two separate issue trackers that are relevant for Triton code:

- An internal-to-Joyent JIRA instance.

  A JIRA ticket has an ID like `IMGAPI-536`, where "IMGAPI" is the JIRA project
  name -- in this case used by the
  [sdc-imgapi](https://github.com/joyent/sdc-imgapi) and related repos. A
  read-only view of most JIRA tickets is made available at
  <https://smartos.org/bugview/> (e.g.
  <https://smartos.org/bugview/IMGAPI-536>).

- GitHub issues for the relevant repo, e.g.
  <https://github.com/joyent/triton/issues>.

Before Triton was open sourced, Joyent engineering used a private JIRA instance.
While Joyent continues to use JIRA internally, we also use GitHub issues for
tracking -- primarily to allow interaction with those without access to JIRA.
