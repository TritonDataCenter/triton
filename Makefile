#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2014, Joyent, Inc.
#

#
# SDC docs Makefile
#

JSON = json
NPM = npm
RAMSEY = node_modules/.bin/ramsey
DOC_FILES = \
	docs/developer-guide/repos.md

docs: $(DOC_FILES)

docs/developer-guide/repos.md: $(RAMSEY) docs/developer-guide/repos.md.in build/repos.json
	$(RAMSEY) -d build -j repos.json "$@.in" "$@"

build/repos.json: build etc/repos.json
	$(JSON) -f ./etc/repos.json -e 'this.name = /([^:/]+).git$$/.exec(this.git)[1]; this.url = "https://github.com/joyent/" + this.name; var self = this; (this.tags || ["none"]).forEach(function (t) { self[t] = true; });' > "$@"

build:
	mkdir -p "$@"

$(RAMSEY):
	$(NPM) install
