# Triton Coding Guidelines for Node.js Code

Many Triton services and tools are written in Node.js. This document provides
some guidelines on Node.js code and specific node modules usage to help
avoid common pitfalls.

See also the following more general guideline docs:

- [Joyent Engineering Guidelines](https://github.com/joyent/eng/blob/master/docs/index.md)
- [RFD 105 Engineering Guide - Node.js Best Practices](https://github.com/joyent/rfd/blob/master/rfd/0105/README.md)
- [RFD 139 Node.js test frameworks and Triton guidelines](https://github.com/joyent/rfd/blob/master/rfd/0139/README.md)
- [specific node module notes for upgrading to Node.js v4](https://github.com/joyent/rfd/blob/master/rfd/0059/README.md#node-modules)


## restify-clients `contentMd5` option

**Guidance: If it is possible that a deployment of client and server span node
v4 and v6, the client must use restify-clients `>=2.5.0` or `>=1.6.0`, and
this client option `contentMd5: {encodings: ['utf8', 'binary']}`.**

Node v6 changed crypto hash.update() to default to 'utf8' encoding. Prior to
that (Node.js v4 and older) it used 'binary' encoding. The result is that
the default hash digest for *non-ASCII* string content differs for different
node.js versions.

This has affected Triton (TOOLS-1592, TRITON-453, MANTA-3679, TRITON-364,
TRITON-630) when dealing with `Content-MD5` HTTP response header verification --
done by default by [restify-clients](https://github.com/restify/clients) -- when
the client and server use different node.js versions before and after the
hash.update() change. If a response includes non-ASCII content (e.g. in a VM's
`alias` or `customer_metadata`), then the client will error with `BadDigest`.

To cope with this a [`contentMd5` client
options](https://github.com/restify/clients#contentmd5) was
[added](https://github.com/restify/clients/pull/174) to restify-clients.
You should do this in your restify-client usage:

    # package.json
    "dependencies": {
        "restify-clients": "1.6.0", // or 2.5.0 or greater
        // ...
    }

    # .js code
    var restifyClients = require('restify-clients');
    var client = restifyClients.createJsonClient({
        contentMd5: {
            encodings: ['utf8', 'binary']
        },
        // ...
    });

