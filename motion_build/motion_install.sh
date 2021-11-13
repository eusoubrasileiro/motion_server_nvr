#!/bin/bash

sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
    autoconf automake autopoint \
    build-essential pkgconf libtool \
    libzip-dev libjpeg-dev git  \
    libwebp-dev gettext libmicrohttpd-dev \
    python3 unzip 

if [ ! -f "motion-4.3.zip" ]; then # only if not downloaded yet
    wget -O motion-4.3.zip https://github.com/Motion-Project/motion/archive/refs/heads/4.4.zip
fi
if [ ! -d "motion-4.3" ]; then # only if not unziped yet
    unzip motion-4.3.zip
fi

cd motion-4.3/ && autoreconf -fiv 

# compiling on a chroot linux android
if [ "`uname -m`" = "aarch64" ] ; then
    ./configure --without-mysql --without-mariadb -without-pgsql \
    --without-sqlite3 CFLAGS='-g -O3 -ftree-vectorize -mcpu=cortex-a53 -march=armv8-a+crypto+crc+simd'
fi
#  compiling on real linux not android
if [ "`uname -m`" = "x86_64" ] ; then
    ./configure --without-mysql --without-mariadb -without-pgsql \
    --without-sqlite3 CFLAGS='-I/usr/local/include' \
    LDFLAGS='-L/usr/local/lib'
fi

make -j$(nproc)

# copy to /usr/local/bin the compiled binary
sudo cp src/motion  /usr/local/bin/motiond
sudo chmod a+x /usr/local/bin/motiond