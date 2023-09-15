#!/bin/bash

# 1. rkmpp_decoder_install.sh

# 2.clone ffmpeg and ... for mppa media process plataform
if [ ! -d "FFmpeg" ]; then
    git clone https://github.com/hbiyik/FFmpeg -b mpp-rga-ffmpeg-6 --depth=1
fi 

cd FFmpeg
# Add my RTSP patch my Yoose trash cameras
git apply --stat ../RTSP_lower_transport_TCP.patch

# SHINOBI change IF... one day maybe
# Need to change this to enable filters for Shinobi 
# if considering using it really

#  compiling orangepi 5 
./configure --disable-ffprobe --disable-ffplay --disable-outdevs \
--disable-indevs --disable-devices --disable-filters \
--enable-shared --prefix=/usr/local --enable-rkmpp --enable-version3 --enable-libdrm

# debbuging version
#./configure --enable-shared --disable-static --disable-optimizations \
#--disable-mmx --disable-stripping  xxxx..... --prefix=/usr/local

make -j$(nproc)

# add a conf with the path of libraries here instead of setting LD_LIBRARY_PATH
# /etc/ld.so.conf.d
# ldconfig reads conf files and reloads libraries, kind like that
# /home/ubuntu/jetson-ffmpeg/build
# make install
# /home/ubuntu/jetson-ffmpeg/build/ffmpeg
# make install
# ldconfig

# testing  hevc_rkmpp_decoder decoder 
# ffmpeg -v quiet -stats -rtsp_transport tcp -y -c:v  hevc_rkmpp_decoder -i rtsp://admin:passwd@ipcam_front_left:554/onvif2 -f null -
# Working perfectly after install. To show only progress use -v quiet -stats
# less image smearing/tearing errors etc..  it seams
 