# Bare-Metal ARM Toolchains

This repository contains Crosstool-NG configurations and helper scripts to
build Windows and Linux toolchains for my personal use.

### Installation

  * Tested on Ubuntu 16.04 LTS and Debian 8.7

```bash
sudo apt-get update
sudo apt-get install -y build-essential automake gperf bison flex gawk libncurses5-dev python-dev texinfo help2man mingw-w64

./bootstrap.sh
```

### How to build

Build a single toolchain:

```bash
./build-toolchain.sh gcc-arm-socfpga_hf-eabi-linux
```

.. or build all of them:

```bash
./build-toolchain.sh gcc-*
```

Building all toolchains requires 45 GB of disk space and will take about
2 hours on a recent Core i7 machine.

Afterwards, you will (hopefully) find nicely packaged toolchains in the
"releases" folder.


## Altera SoCFPGA (Cortex-A9)

Altera's [SoC EDS][1] includes a variant of Sourcery CodeBench _Lite_.
While the full version supports the "hard" floating point ABI, the lite
edition only supports "softfp" -- i.e. floating point arguments are
passed in integer registers on function calls.

The alternatives are no better: [GNU ARM Embedded][2] only supports
Thumb mode (which is 10% slower), and [Linaro's arm-eabi][3] toolchain
only does software floating point (on purpose, for bootloaders).
All other prebuilt toolchains are either proprietary or outdated.

[1]: https://dl.altera.com/soceds/
[2]: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm
[3]: https://www.linaro.org/downloads/

### Configuration Settings

* Use fastest floating point ABI

    ```-mfloat-abi=hard```

* newlib options

  * Reeantrancy with multi-thread and multi-_core_ support (see [10], [11]) 

    ```-DREENTRANT_SYSCALLS_PROVIDED -D__DYNAMIC_REENT__```

  * Disable NEON optimized memcpy to prevent floating point
    instructions in otherwise integer-only code.

    As there is no better flag (see [12]), newlib is configured with

    ```-mno-unaligned-access```

[10]: http://code-time.com/newlib.html
[11]: http://code-time.com/pdf/mAbassi%20Port%20-%20SMP%20ARM%20Cortex%20A9%20-%20DS5%20(GCC).pdf
[12]: https://github.com/mirror/newlib-cygwin/blob/master/newlib/libc/machine/arm/aeabi_memcpy-armv7a.S#L32 


## NXP LPC32xx (ARM926EJ-S)

Mentor Graphics stopped to release Sourcery CodeBench _Lite_ in 2013
(and only supported softfp anyways).

### Configuration Settings

* Use fastest floating point ABI

    ```-mfloat-abi=hard```

* newlib

  * Reentrancy with multi-thread support

    ```-DREENTRANT_SYSCALLS_PROVIDED```
