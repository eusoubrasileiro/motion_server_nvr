#!/bin/bash

# 1. nvmpi_install.sh

# 2.clone ffmpeg and ...
if [ ! -d "ffmpeg" ]; then
    git clone git://source.ffmpeg.org/ffmpeg.git -b release/6.0 --depth=1
fi 

# ... patch ffmpeg with nvmpi and my RTSP_lower_transport patch
cd ffmpeg
wget -O ffmpeg_nvmpi.patch https://github.com/Keylost/jetson-ffmpeg/raw/master/ffmpeg_patches/ffmpeg6.0_nvmpi.patch
git apply ffmpeg_nvmpi.patch
# Add my RTSP patch my Yoose trash cameras
patch -p1 < ../RTSP_lower_transport_TCP.patch

# SHINOBI change IF... one day maybe
# Need to change this to enable filters for Shinobi 
# if considering using it really

#  compiling jetson nano 
./configure --enable-nvmpi \
--disable-ffprobe --disable-ffplay \
--disable-outdevs --disable-indevs --disable-devices --disable-filters \
--enable-shared --prefix=/usr/local \
--disable-encoders \
--enable-encoder=mpeg2video --enable-encoder=mpeg4 \
--disable-muxers \
--enable-muxer=mpeg2video --enable-muxer=mp4 --enable-muxer=rtsp \
--enable-muxer=h264 --enable-muxer=hevc --enable-muxer=mp4 \
--disable-decoders \
--enable-decoder=hevc_nvmpi --enable-decoder=h264_nvmpi \
--enable-decoder=hevc --enable-decoder=h264

# missing parsers and bsfs

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
# ffmpeg -v quiet -stats -rtsp_transport tcp -y -c:v  hevc_nvmpi -i rtsp://admin:passwd@ipcam_front_left:554/onvif2 -f null -
# Working perfectly after install. To show only progress use -v quiet -stats
# less image smearing/tearing errors etc..  it seams
 