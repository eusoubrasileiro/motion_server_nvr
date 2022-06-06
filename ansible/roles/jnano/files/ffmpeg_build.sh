#!/bin/bash

# 1. nvmpi_install.sh

# 2.clone ffmpeg and ...
if [ ! -d "ffmpeg" ]; then
    git clone git://source.ffmpeg.org/ffmpeg.git -b release/4.2 --depth=1
fi 

# ... patch ffmpeg with nvmpi and my RTSP_lower_transport patch
cd ffmpeg
git apply ../jetson-ffmpeg/ffmpeg_nvmpi.patch
# Add my RTSP patch my Yoose trash cameras
patch -p1 < ../RTSP_lower_transport_TCP.patch

#  compiling jetson nano 
./configure --disable-outdevs  --disable-indevs --enable-nvmpi \
--enable-shared --prefix=/usr/local 
#is the default for real linux let it be
# debbuging version
#./configure --enable-shared --disable-static --disable-optimizations \
#--disable-mmx --disable-stripping --enable-nvmpi --prefix=/usr/local

make -j$(nproc)

# add a conf with the path of libraries here instead of setting LD_LIBRARY_PATH
# /etc/ld.so.conf.d
# ldconfig reads conf files and reloads libraries, kind like that
# /home/andre/jetson-ffmpeg/build
# make install
# /home/andre/jetson-ffmpeg/build/ffmpeg
# make install
# ldconfig

# testing  hevc_nvmpi decoder 
# ffmpeg -v quiet -stats -rtsp_transport tcp -y -c:v  hevc_nvmpi -i rtsp://user:pass@ipcam.kitchen:554/onvif2 -f null -
# Working perfectly after install. To show only progress use -v quiet -stats
# less image smearing/tearing errors etc..  it seams
