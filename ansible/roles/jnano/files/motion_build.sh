#!/bin/bash

if [ ! -f "motion-src.zip" ]; then # only if not downloaded yet
    wget -O motion-src.zip https://github.com/Motion-Project/motion/archive/2829dc766e404bdb24d0435111b4b00c343ab5ee.zip
fi
if [ ! -d "motion-src" ]; then # only if not unziped yet
    unzip motion-src.zip
    # rename weird folder name to motion-src 
    find . -type d -name 'motion-*' -exec bash -c 'mv "$1" motion-src' - {} \;
fi

cd motion-src/ && autoreconf -fiv

# apply my event_id patch - otherwise sql_query still doesn't work alone is not capable
# github issue https://github.com/Motion-Project/motion/issues/1537
patch -p1 < ../time_t.patch

# in case running again
make clean 
./configure --without-mysql --without-mariadb -without-pgsql --with-ffmpeg=/usr/local  # CFLAGS,LDFLAGS replaced by --with-ffmpeg
# CFLAGS with -g option is debbuging
make -j$(nproc)

# copy to /usr/local/bin the compiled binary better use motiond to avoid confusion if default apt-get package is installed
# cp src/motion  /usr/local/bin/motiond
# chmod a+x /usr/local/bin/motiond