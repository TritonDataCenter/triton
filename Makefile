#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2018, Joyent, Inc.
#

#
# SDC docs Makefile
#

JSON = json
NPM = npm
RAMSEY = node_modules/.bin/ramsey
MD_FILES = \
	docs/developer-guide/repos.md

CLEAN_FILES += build/repos.json


include ./tools/mk/Makefile.defs


#
# Repo-specific targets
#

.PHONY: all
all: docs

.PHONY: docs
docs: $(MD_FILES)

docs/developer-guide/repos.md: $(RAMSEY) docs/developer-guide/repos.md.in build/repos.json
	$(RAMSEY) -d build -j repos.json "$@.in" "$@"

JSON_SCRIPT = 'var self = this; \
	this.name = /([^:/]+).git$$/.exec(this.git)[1]; \
	this.url = "https://github.com/joyent/" + this.name; \
	(this.tags || ["none"]).forEach(function (t) { self[t] = true; });'

build/repos.json: build etc/repos.json
	$(JSON) -f ./etc/repos.json -e $(JSON_SCRIPT) > "$@"

build:
	mkdir -p "$@"

$(RAMSEY):
	$(NPM) install

# A quick hack for convenience of looking at source for all SDC repos.
# Assumption: you have `json` (npm install -g json).
.PHONY: clone-all-repos
clone-all-repos:
	(mkdir -p build/repos; cd build/repos; json -f ../../etc/repos.json -a git | xargs -n1 git clone)


include ./tools/mk/Makefile.deps
include ./tools/mk/Makefile.targ
