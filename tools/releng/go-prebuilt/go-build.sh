#!/bin/bash
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright 2020 Joyent, Inc.
# Copyright 2024 MNX Cloud, Inc.
#

#
# This script expects that you have downloaded and extracted a Go bootstrap
# release from $GO_MANTA_URL and are running on a 'min_platform' SmartOS box.
# It then expects to have a *.src.tar.gz release from $GO_SOURCE_URL and
# have extracted it to a versioned directory at the top of your build dir.
#
# Then invoke using something like:
#
# $ ~/projects/triton.git/tools/releng/go-prebuilt/go-build.sh \
#      -N 1.14 -b 1.13rc1 -d /ws/gobuild
#
#

if [[ -n "$TRACE" ]]; then
    export PS4='${BASH_SOURCE}:${LINENO}: '
    set -o xtrace
fi
set -o errexit

#
# This URL is hardcoded in eng.git:tools/download_go. If it changes, be sure
# to modify there too.
#
GO_MANTA_URL=https://us-central.manta.mnx.io/Joyent_Dev/public/releng/go/adhoc/

#
# The Golang source distribution download page
#
GO_SOURCE_URL=https://golang.org/dl/

function usage {
    echo ""
    echo "Usage: go-build.sh [options]"
    echo ""
    echo "OPTIONS"
    echo "  -b <version>        the bootstrap version to use"
    echo "  -d <dir>            the top-level build directory"
    echo "  -f                  force a build, ignoring min_platform and any existing output archive"
    echo "  -N <version>        the new Golang version to build"
    echo "  -C                  skip post-build cleanup and archive steps"
    exit 2
}

function verify_min_platform {
    MIN_PLATFORM=20181206T011455Z
    CURRENT_PLATFORM=$(uname -v | sed -e 's/^joyent_//g')

    if [[ "$CURRENT_PLATFORM" != "$MIN_PLATFORM" ]]; then
        echo "The current platform $CURRENT_PLATFORM is not $MIN_PLATFORM"
        echo "Golang builds for use in Triton/Manta should be done on the"
        echo "oldest supported platform to ensure we're able to build with"
        echo "it on any current build machine."
        exit 1
    fi
}

function build {
    export GOROOT_BOOTSTRAP="$BUILD_DIR/$BOOTSTRAP_VER"
    export GOROOT="$BUILD_DIR/$NEW_VER/proto"
    export GOROOT_FINAL="/opt/go/$NEW_VER"
    export GOOS='illumos'
    export GOARCH='amd64'

    cd "$BUILD_DIR/$NEW_VER/src"
    echo "Building in dir: $(pwd)"
    ./all.bash
}

function cleanup {
    #
    # Attempt to remove superfluous files to reduce the size
    # of the Golang toolchain archive. This is based on code
    # and comments in:
    #     https://github.com/golang/build/blob/master/cmd/release/release.go
    #
    cd $BUILD_DIR/$NEW_VER

    if [[ ! -f VERSION ]] || ! v=$(<VERSION) || [[ "$v" != "go${NEW_VER}" ]]; then
        printf 'Are you in a go release directory?\n' >&2
        exit 1
    fi

    # Remove the bootstrap compiler files.
    rm -rf "pkg/bootstrap"

    # Remove the obj build cache, which is _huge_.
    rm -rf "pkg/obj"

    # Remove the libraries used to build the toolchain commands.
    rm -rf "pkg/illumos_amd64/cmd"
}

function compress {
    cd $BUILD_DIR/$NEW_VER
    gtar --owner=root --group=root -cvjf \
        $BUILD_DIR/go${NEW_VER}.illumos-amd64.tar.bz2 \
        *
}

#
# Main
#
while getopts "Cb:d:fN:" opt; do
    case "${opt}" in
        d)
            BUILD_DIR=$OPTARG
            ;;
        f)
            FORCE=true
            ;;
        b)
            BOOTSTRAP_VER=$OPTARG
            ;;
        C)
            SKIP_CLEANUP=true
            ;;
        N)
            NEW_VER=$OPTARG
            ;;
        *)
            echo "Error: Unknown argument ${opt}"
            usage
    esac
done
shift $((OPTIND - 1))

if [[ -z "${BUILD_DIR}" ]]; then
    echo "Missing -d argument <build directory>"
    usage
fi

if [[ -z "${BOOTSTRAP_VER}" ]]; then
    echo "Missing -b argument <bootstrap version>"
    usage
fi

if [[ -z "${NEW_VER}" ]]; then
    echo "Missing -N argument <new version>"
    usage
fi

if [[ ! -d ${BUILD_DIR}/${BOOTSTRAP_DIR} ]]; then
    echo ""
    echo "Missing bootstrap directory ${BUILD_DIR}/${BOOTSTRAP_DIR}"
    echo "You should download and extract an appropriate bootstrap go build"
    echo "from $GO_MANTA_URL"
    exit 1
fi

mkdir -p $BUILD_DIR/$NEW_VER

if [[ ! -f ${BUILD_DIR}/${NEW_VER}/VERSION ]]; then
    #
    # This message assumes that golang source releases
    # are always packaged with ./go/ at the top level of
    # the archive, which has always been the case so far.
    #
    echo ""
    echo "Missing Golang sources in ${BUILD_DIR}/${NEW_VER}"
    echo "You should download a go${NEW_VER}.src.tar.gz archive from"
    echo "$GO_SOURCE_URL"
    echo "verify its SHA256 checksum, then extract it with:"
    echo ""
    echo "    tar -C $BUILD_DIR/$NEW_VER -x --strip-components=1 -f $BUILD_DIR/go${NEW_VER}.src.tar.gz"
    echo ""
    exit 1
fi

if [[ -f $BUILD_DIR/go${NEW_VER}.illumos-amd64.tar.bz2 ]]; then
    if [[ -z "$FORCE" ]]; then
        echo "Use -f flag to remove existing archive at $BUILD_DIR/go${NEW_VER}.illumos-amd64.tar.bz2"
        echo "Note that this also ignores the min_platform check, so should not be set for production builds."
        exit 1
    fi
fi

verify_min_platform
build
RES=$?
if [[ -n "$SKIP_CLEANUP" ]]; then
    echo "Skipping cleanup and archive stages."
    exit $RES
fi
cleanup
compress

echo ""
echo "All done. You should now test $BUILD_DIR/go${NEW_VER}.illumos-amd64.tar.bz2"
echo "and then post it to $GO_MANTA_URL"
echo ""
