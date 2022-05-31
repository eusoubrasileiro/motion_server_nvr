#!/bin/bash

# Custom ffmpeg for jetson nano 
# 1.build and install nvmpi library

if [ ! -d "jetson-ffmpeg" ]; then
    git clone https://github.com/jocover/jetson-ffmpeg.git
fi

cd jetson-ffmpeg
mkdir -p build
cd build
cmake ..
make

# 2.clone ffmpeg and ...
if [ ! -d "ffmpeg" ]; then
    git clone git://source.ffmpeg.org/ffmpeg.git -b release/4.2 --depth=1
fi 

# ... patch ffmpeg nvmpi and my RTSP_lower_transport patch
cd ffmpeg
if [ ! -f "ffmpeg_nvmpi.patch" ]; then
    wget https://github.com/jocover/jetson-ffmpeg/raw/master/ffmpeg_nvmpi.patch
    git apply ffmpeg_nvmpi.patch
    # Add my custom patch 
    patch -p1 < ../../../RTSP_lower_transport_TCP.patch
fi 

make  
#  compiling jetson nano 
./configure --disable-outdevs  --disable-indevs --enable-nvmpi \
--enable-shared --prefix=/usr/local #is the default for real linux let it be
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