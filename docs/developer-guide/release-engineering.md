<!--
    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at http://mozilla.org/MPL/2.0/.
-->

<!--
    Copyright 2019 Joyent, Inc.
-->

# Release Engineering

This document describes some of the details on the release engineering process
for Triton and Manta. Over time, we expect to include more information here
on how to produce a full release.

Developer documentation on
[building Manta and Triton is also available.](https://github.com/joyent/triton/blob/master/docs/developer-guide/building.md)


# Bits directory structure

Joyent engineering builds upload build bits to a controlled directory structure at
`/Joyent_Dev/stor/builds` in Manta. The `sdc-headnode` and `agents-installer`
rely on this structure, as do the Triton
[release engineering scripts.](https://github.com/joyent/triton/blob/master/tools/releng)

    /Joyent_Dev/stor/builds/
        $job/                   # Typically $job === Jenkins job name
            $branch-latest      # File with path to latest ".../$branch-$timestamp"
            ...
            $branch-$timestamp/
                $target/
                    ...the target's built bits...
                ...all dependent bits and build configuration...

For example:

    /Joyent_Dev/stor/builds/
        amon/
            master-latest
            master-20130208T215745Z/
            ...
            master-20130226T191921Z/
                config.mk
                md5sums.txt
                amon/
                    amon-agent-master-20130226T191921Z-g7cd3e28.tgz
                    amon-pkg-master-20130226T191921Z-g7cd3e28.tar.bz2
                    amon-relay-master-20130226T191921Z-g7cd3e28.tgz
                    build.log
        headnode
            master-latest
            ...
            master-20130301T004335Z/
                config.mk
                md5sums.txt
                headnode/
                    boot-master-20130301T004335Z-gad6dfc4.tgz
                    coal-master-20130301T004335Z-gad6dfc4.tgz
                    usb-master-20130301T004335Z-gad6dfc4.tgz
                    build.log
                    build.spec.local

All those "extra" pieces (build log, md5sums.txt, config.mk)
are there to be able to debug and theoretically reproduce builds.
The "md5sums.txt" is used by the headnode build to ensure uncorrupted
downloads.


## Package Versioning

Thou shalt name thy Triton constituent build bits as follows:

    NAME-BRANCH-TIMESTAMP[-GITDESCRIBE].TGZ

where:

- NAME is the package name, e.g. "smartlogin", "ca-pkg".
- BRANCH is the git branch, e.g. "master", "release-20110714". Use:

        BRANCH=$(shell git symbolic-ref HEAD | awk -F / '{print $$3}')  # Makefile
        BRANCH=$(git symbolic-ref HEAD | awk -F / '{print $3}')         # Bash script

- TIMESTAMP is an ISO timestamp like "20110729T063329Z". Use:

        TIMESTAMP=$(shell TZ=UTC date "+%Y%m%dT%H%M%SZ")    # Makefile
        TIMESTAMP=$(TZ=UTC date "+%Y%m%dT%H%M%SZ")          # Bash script

  Good. A timestamp is helpful (and in this position in the package name)
  because: (a) it often helps to know approx. when a package was built when
  debugging; and (b) it ensures that simple lexographical sorting of
  "NAME-BRANCH-*" packages in a directory (as done by agents-installer and
  usb-headnode) will make choosing "the latest" possible.

  Bad. A timestamp *sucks* because successive builds in a dev tree will get a
  new timestamp: defeating Makefile dependency attempts to avoid rebuilding.
  Note that the TIMESTAMP is only necessary for released/published packages,
  so for projects that care (e.g. ca), the TIMESTAMP can just be added for
  release.

- GITDESCRIBE gives the git sha for the repo and whether the repo was dirty
  (had local changes) when it was built, e.g. "gfa1afe1-dirty", "gbadf00d".
  Use:

        # Need GNU awk for multi-char arg to "-F".
        AWK=$((which gawk 2>/dev/null | grep -v "^no ") || which awk)
        # In Bash:
        GITDESCRIBE=g$(git describe --all --long --dirty | ${AWK} -F'-g' '{print $NF}')
        # In a Makefile:
        GITDESCRIBE=g$(shell git describe --all --long --dirty | $(AWK) -F'-g' '{print $$NF}')

  Notes: "--all" allows this to work on a repo with no tags. "--long"
  ensures we always get the "sha" part even if on a tag. We strip off the
  head/tag part because we don't reliably use release tags in all our
  repos, so the results can be misleading in package names. E.g., this
  was the smartlogin package for the Lime release:

        smartlogin-release-20110714-20110714T170222Z-20110414-2-g07e9e4f.tgz

  The "20110414" there is an old old tag because tags aren't being added
  to smart-login.git anymore.

  "GITDESCRIBE" is *optional*. However, the only reason I currently see to
  exclude it is if the downstream user of the package cannot handle it in
  the package name. The "--dirty" flag is *optional* (though strongly
  suggested) to allow repos to deal with possibly intractable issues (e.g. a
  git submodule that has local changes as part of the build that can't be
  resolved, at least not resolved quickly).

- TGZ is a catch-all for whatever the package format is. E.g.: ".tgz",
  ".sh" (shar), ".md5sum", '"tar.gz", ".tar.bz2".


## Exceptions

The agents shar is a subtle exception:

    agents-release-20110714-20110726T230725Z.sh

That "release-20110714" really refers to the branch used to build the
agent packages included in the shar. For typical release builds, however,
the "agents-installer.git" repo is always also on a branch of the same
name so there shouldn't be a mismatch.



## Suggested Versioning Usage

It is suggested that the Triton repos use something like this at the top of
their Makefile to handle package naming (using the Joyent Engineering
Guidelines, eng.git):

    ENGBLD_REQUIRE := $(shell git submodule update --init deps/eng)
    include ./deps/eng/tools/Makefile.defs   # provides "STAMP"
    ...
    RELEASE_TARBALL = $(NAME)-pkg-$(STAMP).tar.gz


Notes:
- This gives the option of the TIMESTAMP being passed in. This is important
  to allow build tools -- e.g., eng.git, CI -- to
  predict the expected output files, and hence be able to raise errors if
  expected files are not generated.
- Consistency here will help avoid confusion, and surprises in things like
  subtle differences in `awk` on Mac vs. SmartOS, various options to
  `git describe`.
