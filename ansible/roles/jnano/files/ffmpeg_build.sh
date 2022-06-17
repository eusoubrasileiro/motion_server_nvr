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
./configure --enable-nvmpi \
--disable-outdevs  --disable-indevs --disable-devices \
--disable-ffprobe --disable-ffplay \
--enable-shared --prefix=/usr/local 

# ffmpeg build time reduced 10 fold (trying to)
# - disabling almost everything possible 
# - trying enable only what is needed 
# - tested working
# compiling using nvmpi (nvidia multimedia api) jetson nano hardware decoders
# mpg2video, mpg4 is for mpg/mp4 timelapse videos encoded from 1 second jpegs
# ./configure --enable-nvmpi --disable-outdevs  --disable-indevs  \
# --disable-ffprobe --disable-ffplay --disable-encoders --disable-filters \
# --disable-devices --disable-protocols --disable-decoders \
# --disable-muxers --disable-demuxers \
# --enable-protocol=rtmp \
# --enable-encoder=mpeg2video --enable-encoder=mpeg4 \
# --enable-muxer=mpeg2video --enable-muxer=mp4 \
# --enable-decoder=hevc_nvmpi --enable-decoder=h264_nvmpi \
# --enable-muxer=rtsp --enable-muxer=h264 --enable-muxer=hevc --enable-muxer=mp4 \
# --enable-demuxer=rtsp --enable-demuxer=h264 --enable-demuxer=hevc  \
# --enable-shared --prefix=/usr/local
# more to add to try
#--enable-demuxers=image_jpeg_pipe image2pipe image2
#--enable-muxers=image2pipe



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
# ffmpeg -v quiet -stats -rtsp_transport tcp -y -c:v  hevc_nvmpi -i rtsp://user:pass@ipcam-kitchen:554/onvif2 -f null -
# Working perfectly after install. To show only progress use -v quiet -stats
# less image smearing/tearing errors etc..  it seams
 