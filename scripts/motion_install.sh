#!/bin/bash

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

# copy to /usr/local/bin the compiled binary better use motiond to avoid confusion if default apt-get package is installed
cp src/motion  /usr/local/bin/motiond
chmod a+x /usr/local/bin/motiond