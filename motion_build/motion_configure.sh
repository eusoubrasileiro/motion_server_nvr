#!/bin/bash
sudo apt-get install -yq autoconf automake autopoint \
    build-essential pkgconf libtool \
    libzip-dev libjpeg-dev git  \
    libwebp-dev gettext libmicrohttpd-dev

sudo wget https://github.com/Motion-Project/motion/archive/refs/heads/4.3.zip

unzip 4.3.zip

cd motion-4.3/ && autoreconf -fiv 

./configure --without-mysql --without-mariadb -without-pgsql \
    --without-sqlite3 CFLAGS='-g -O3 -ftree-vectorize -mcpu=cortex-a53 -march=armv8-a+crypto+crc+simd'

make -j8 

# copy to /usr/local/bin the compiled binary
sudo cp src/motion  /usr/local/bin/motiond
sudo chmod a+x /usr/local/bin/motiond

# -O3 to forcee use Neon optimization 
# according to https://stackoverflow.com/questions/29851128/gcc-arm64-aarch64-unrecognized-command-line-option-mfpu-neon
# since `gcc -march=native -Q --help=target' gives bellow Do I need to put  `-mcpu=cortex-a53 -march=armv8-a+crypto+crc+simd` ?
# parece que -mcpu=cortex-a53 equivalente -march=armv8-a+crypto+crc+simd? usando tudo pra ter certeza
#The following options are target specific:
#  -mabi=ABI                             lp64
#  -march=ARCH                           armv8-a+crypto+crc
#  -mbig-endian                          [disabled]
#  -mbionic                              [disabled]
#  -mcmodel=                             small
#  -mcpu=CPU
#  -mfix-cortex-a53-835769               [enabled]
#  -mfix-cortex-a53-843419               [enabled]
#  -mgeneral-regs-only                   [disabled]
# -mglibc                               [enabled]
#  -mlittle-endian                       [enabled]
#  -mmusl                                [disabled]
#  -momit-leaf-frame-pointer             [enabled]
#  -moverride=STRING
#  -mpc-relative-literal-loads           [enabled]
#  -msign-return-address=                none
#  -mstrict-align                        [disabled]
#  -msve-vector-bits=N                   scalable
#  -mtls-dialect=                        desc
#  -mtls-size=                           24
#  -mtune=CPU
#  -muclibc                              [disabled]

#  Known AArch64 ABIs (for use with the -mabi= option):
#    ilp32 lp64

#  Supported AArch64 return address signing scope (for use with -msign-return-address= option):
#    all non-leaf none

#  The code model option names for -mcmodel:
#    large small tiny

#  The possible SVE vector lengths:
#    1024 128 2048 256 512 scalable

#  The possible TLS dialects:
#    desc trad

