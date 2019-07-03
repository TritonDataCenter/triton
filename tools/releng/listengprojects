#!/bin/bash
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2017, Joyent, Inc.
#

#
# List the Joyent Engineering Jira projects. This is defined as the set of
# Jira projects on which we want the bi-weekly engineering release versions.
# E.g., these ones:
#
#    $ jirash versions HEAD
#    ...
#    17529  2016-07-07 Super Stretch        released  archived
#    17591  2016-07-21 Tangent Man          released         -
#    17646  2016-08-04 Uncle Jumbo                 -         -
#    ...
#
# When adding a new Jira project for eng the process is:
# - add it to jira
# - add it to the whitelist here
# - manually add the upcoming sprint versions (see ./addsprintversion.sh) to it
#

if [[ -n "$TRACE" ]]; then
    export PS4='[\D{%FT%TZ}] ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -o xtrace
fi
set -o errexit
set -o pipefail

ENG_PROJECTS="ADMINUI
MANATEE
MANTA
MORAY
OS
RICHMOND
ROGUE
TOOLS
TRITON"

echo "$ENG_PROJECTS"
