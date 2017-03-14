#!/bin/bash
set -e

BASE_DIR=$PWD
DOWNLOADS_DIR=$BASE_DIR/downloads
RELEASES_DIR=$BASE_DIR/releases
CT_NG=$BASE_DIR/crosstool-ng/ct-ng


function build {
    CONFIG_DIR=$BASE_DIR/$1

    mkdir -p $DOWNLOADS_DIR
    mkdir -p $RELEASES_DIR

    echo
    echo "***** Building $1 *****"
    echo

    cd $CONFIG_DIR
    if [[ ! -f defconfig ]]; then
        echo "ERROR: $CONFIG_DIR/defconfig not found" 1>&2
        exit 1
    fi

    $CT_NG defconfig
    $CT_NG clean
    $CT_NG build

    echo
    echo "***** Packaging $1 *****"
    echo

    cd $CONFIG_DIR/output

    # The output directory name is defined by the defconfig and
    # includes the GCC version number (which we don't know yet).
    #
    # So we have to search the output directory.
    #
    for REL_NAME in *; do
        if [[ -d $REL_NAME ]]; then
            REL_HOST=${1/*-/}   # win64 or linux
            REL_DATE=$(date +%Y%m%d -r$REL_NAME)

            # h - do not create symlinks (windows can't extract them)
            #
            tar chvJf $RELEASES_DIR/$REL_NAME-$REL_HOST-$REL_DATE.tar.xz $REL_NAME
        fi
    done
}


if [[ $# -lt 1 ]]; then
    echo "usage: $0 CONFIG_DIR..." 1>&2
    exit 1
fi


for ARG in "$@"; do
    build "$ARG"
done

