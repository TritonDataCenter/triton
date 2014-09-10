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

.PHONY: docs
docs: $(DOC_FILES)

docs/developer-guide/repos.md: $(RAMSEY) docs/developer-guide/repos.md.in build/repos.json
	$(RAMSEY) -d build -j repos.json "$@.in" "$@"

build/repos.json: build etc/repos.json
	$(JSON) -f ./etc/repos.json -e 'this.name = /([^:/]+).git$$/.exec(this.git)[1]; this.url = "https://github.com/joyent/" + this.name; var self = this; (this.tags || ["none"]).forEach(function (t) { self[t] = true; });' > "$@"

build:
	mkdir -p "$@"

$(RAMSEY):
	$(NPM) install



# TODO:
# - basic sphinx structure and build
# - add reference handling after that

# build/
#	sphinx/
#		conf.py
# 		

.PHONY: sphinx
sphinx:

#REFERENCE_DOCS = \
#    amon \
#    cnapi
#
## amon
## -> git clone sdc-amon.git
## -> cp sdc-amon.git/docs/index.restdown build/sphinx/source/reference/amon.md
## -> markdown2 amon.md > amon.html
## -> simplehtml2rst amon.html > amon.rst
## -> build/sphinx/source/reference/amon.rst
#
#
## amon
## -> ./tools/build-reference-doc amon build/sphinx/source/reference
#
#
#.PHONY: reference
#reference: $(REFERENCE_DOCS)
#	echo TODO build reference
