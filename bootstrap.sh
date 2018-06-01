#!/bin/bash
set -e

# Clone crosstool-ng
#
git submodule init
git submodule update

# Configure
#
cd crosstool-ng
./bootstrap                 # create configure script
./configure --enable-local  # don't install, use local directory
make
cd ..

# Get new gcc releases
#
# wget -cP downloads https://ftp.gnu.org/gnu/gcc/gcc-7.2.0/gcc-7.2.0.tar.xz
wget -cP downloads https://ftp.gnu.org/gnu/gcc/gcc-8.1.0/gcc-8.1.0.tar.xz
