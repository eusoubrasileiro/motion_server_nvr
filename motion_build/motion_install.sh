#!/bin/bash

sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
    autoconf automake autopoint \
    build-essential pkgconf libtool \
    libzip-dev libjpeg-dev git  \
    libwebp-dev gettext libmicrohttpd-dev \
    python3 unzip 

if [ ! -f "motion-4.4.zip" ]; then # only if not downloaded yet
    wget -O motion-4.4.zip https://github.com/Motion-Project/motion/archive/refs/tags/release-4.4.0.zip
fi
if [ ! -d "motion-release-4.4.0" ]; then # only if not unziped yet
    unzip motion-4.4.zip
fi

cd motion-release-4.4.0/ && autoreconf -fiv 

./configure --without-mysql --without-mariadb -without-pgsql \
--without-sqlite3 CFLAGS='-g' --with-ffmpeg=/usr/local  # CFLAGS,LDFLAGS replaced by --with-ffmpeg
# CFLAGS with -g option is debbuging


make -j$(nproc)

# copy to /usr/local/bin the compiled binary
sudo cp src/motion  /usr/local/bin/motiond
sudo chmod a+x /usr/local/bin/motiond