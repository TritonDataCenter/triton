#!/usr/bin/python
"""
strip-restdown-html -- Strip Restdown HTML header/footer content for processing
with `simplehtml2rst`.
"""

from __future__ import print_function

__version_info__ = (1, 0, 0)
__version__ = '.'.join(map(str, __version_info__))

import codecs
import logging
import math
import optparse
from pprint import pprint
import re
import sys
import textwrap
import UserList
import warnings
import xml.dom.minidom


#---- globals

# A crutch: short to type print funcs for debugging. This script shouldn't
# ever ship with these being used.
p = print
def e(*args, **kwargs):
    kwargs['file'] = sys.stderr
    print(*args, **kwargs)

log = logging.getLogger('strip-restdown-html')



#---- public API

def strip_restdown_html(html):
    stripped = html

    stripped = stripped[
        stripped.index('<div id="content">') + len('<div id="content">')
        :
        stripped.rindex('</div> <!-- #content -->')]

    #XXX START HERE close tags
    assert '<h6>' not in stripped, "Can't demote headers with <h6>."
    stripped = stripped \
        .replace('<h5', '<h6') \
        .replace('</h5>', '</h6>') \
        .replace('<h4', '<h5') \
        .replace('</h4>', '</h5>') \
        .replace('<h3', '<h4') \
        .replace('</h3>', '</h4>') \
        .replace('<h2', '<h3') \
        .replace('</h2>', '</h3>') \
        .replace('<h1', '<h2') \
        .replace('</h1>', '</h2>') \
        .replace('<h2', '<h1', 1) \
        .replace('</h2>', '</h1>', 1)  # just the first one, for full docset TOC

    return stripped



#---- mainline

def main(argv=None):
    if argv is None:
        argv = sys.argv
    if not logging.root.handlers:
        logging.basicConfig()

    usage = "usage: %prog [PATHS...]"
    version = "%prog "+__version__
    desc = "Strip Restdown HTML header/footer content for processing with `simplehtml2rst`."
    parser = optparse.OptionParser(prog="strip-restdown-html", usage=usage,
        version=version, description=desc)
    parser.add_option("-v", "--verbose", dest="log_level",
                      action="store_const", const=logging.DEBUG,
                      help="more verbose output")
    parser.add_option("--encoding", help="specify encoding of HTML content")
    parser.set_defaults(log_level=logging.INFO, encoding="utf-8")
    opts, paths = parser.parse_args()
    log.setLevel(opts.log_level)

    if not paths:
        paths = ['-']
    for path in paths:
        if path == '-':
            html = sys.stdin.read()
        else:
            fp = codecs.open(path, 'r', opts.encoding)
            html = fp.read()
            fp.close()
        stripped = strip_restdown_html(html)
        sys.stdout.write(stripped.encode(sys.stdout.encoding or "utf-8"))

if __name__ == "__main__":
    sys.exit( main(sys.argv) )
