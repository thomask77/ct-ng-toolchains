#!/bin/bash
set -e

BASE_DIR=$PWD
DOWNLOADS_DIR=$BASE_DIR/downloads
RELEASES_DIR=$BASE_DIR/releases
CT_NG=$BASE_DIR/crosstool-ng/ct-ng


function build {
    CONFIG_DIR=$BASE_DIR/$1
    echo
    echo "***** Building $1 *****"
    echo

    mkdir -p "$DOWNLOADS_DIR"

    cd "$CONFIG_DIR"
    if [[ ! -f defconfig ]]; then
        echo "ERROR: $CONFIG_DIR/defconfig not found" 1>&2
        exit 1
    fi

    $CT_NG defconfig
    $CT_NG clean
    $CT_NG build
}


function package {
    CONFIG_DIR=$BASE_DIR/$1
    echo
    echo "***** Packaging $1 *****"
    echo

    mkdir -p "$RELEASES_DIR"

    # The output directory name is defined by the defconfig and
    # includes the GCC version number (which we don't know yet).
    #
    # So we have to search the output directory.
    #
    cd "$CONFIG_DIR/output"

    for REL_NAME in gcc-*; do
        if [[ ! -d $REL_NAME ]]; then continue; fi

        REL_HOST="${1/*-/}"   # win64 or linux
        REL_DATE=$(date -r"$REL_NAME" +%Y%m%d)

        # Keep PDF documentation only and move to one directory
        #
        chmod -R +w "$REL_NAME/share"
        find "$REL_NAME/share/doc" -type f -not -name "*.pdf" -delete
        find "$REL_NAME/share/doc" -type f -exec mv "{}" "$REL_NAME/share/doc" ";"
        find "$REL_NAME/share/doc" -type d -empty -delete
        rm -rf "$REL_NAME/share/info"
        rm -rf "$REL_NAME/share/man"
        chmod -R -w "$REL_NAME/share"

        # --dereference because windows can't handle symlinks
        #
        tar --create --verbose --dereference --xz \
            --file "$RELEASES_DIR/$REL_NAME-$REL_HOST-$REL_DATE.tar.xz" \
            "$REL_NAME"
    done
}


if [[ $# -lt 1 ]]; then
    echo "usage: $0 CONFIG_DIR..." 1>&2
    exit 1
fi


for ARG in "$@"; do
    build "$ARG"
    package "$ARG"
done

