#!/bin/bash
set -e

git submodule init
git submodule update

cd crosstool-ng
./bootstrap
./configure --enable-local
make
