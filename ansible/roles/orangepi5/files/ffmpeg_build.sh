#!/bin/bash

# 1. rkmpp_decoder_install.sh

# 2.clone ffmpeg and ... for mppa media process plataform
if [ ! -d "FFmpeg" ]; then
    git clone https://github.com/hbiyik/FFmpeg -b mpp-rga-ffmpeg-6 --depth=1
fi 

cd FFmpeg
# Add my RTSP patch my Yoose trash cameras
patch -p1 < ../RTSP_lower_transport_TCP.patch

# SHINOBI change IF... one day maybe
# Need to change this to enable filters for Shinobi 
# if considering using it really

#  compiling orangepi 5 
./configure --disable-ffprobe --disable-ffplay --enable-shared --prefix=/usr/local \
--enable-rkmpp --enable-version3 --enable-libdrm --enable-libv4l2


# debbuging version
#./configure --enable-shared --disable-static --disable-optimizations \
#--disable-mmx --disable-stripping  xxxx..... --prefix=/usr/local

make -j$(nproc)

# add a conf with the path of libraries here instead of setting LD_LIBRARY_PATH
# /etc/ld.so.conf.d
# ldconfig reads conf files and reloads libraries, kind like that
# /home/andre/jetson-ffmpeg/build
# make install
# /home/andre/jetson-ffmpeg/build/ffmpeg
# make install
# ldconfig

# testing  hevc_rkmpp_decoder decoder 
# ffmpeg -v quiet -stats -rtsp_transport tcp -y -c:v  hevc_rkmpp_decoder -i rtsp://admin:passwd@ipcam_front_left:554/onvif2 -f null -
# Working perfectly after install. To show only progress use -v quiet -stats
# less image smearing/tearing errors etc..  it seams
 

# Trying video4linux loopback device 

#  camera_name front-up
# videodevice /dev/video0
# video_params palette=17


# From these ffprobe lines how to decode a rtsp stream without using cpu using ffmpeg. For that only using a decoder called `h264_rkmpp_decoder` and writing the output  decoded video only on video4linux virtual loopback device at /dev/video0
#   Stream #0:0: Video: h264 (Main), yuv420p(progressive), 1920x1080, 12 fps, 6 tbr, 90k tbn, 24 tbc
#   Stream #0:1: Audio: pcm_alaw, 8000 Hz, 1 channels, s16, 64 kb/s



# sudo modprobe v4l2loopback video_nr=0 card_label="CamFrontUp" exclusive_caps=1\
# sudo modprobe v4l2loopback video_nr=1 card_label="CamRightAisle" exclusive_caps=1
# sudo modprobe v4l2loopback video_nr=2 card_label="CamRightAisle" exclusive_caps=1
# sudo modprobe v4l2loopback video_nr=3 card_label="CamRightAisle" exclusive_caps=1
# ffmpeg -rtsp_transport tcp -y -c:v  h264_rkmpp_decoder -i rtsp://admin:gig1684A@ipcam-front-up:554/stream=0 -f v4l2 /dev/video0 
# ffmpeg -rtsp_transport tcp -y -c:v  h264_rkmpp_decoder -i rtsp://admin:gig1684A@ipcam-front-up:554/stream=1 -f v4l2 /dev/video1 
# ffmpeg -rtsp_transport tcp -y -c:v  hevc_rkmpp_decoder -i rtsp://admin:gig1684A@ipcam-right-aisle:554/ch0_0.264 -f v4l2 /dev/video2
# ffmpeg -rtsp_transport tcp -y -c:v  h264_rkmpp_decoder -i rtsp://admin:gig1684A@ipcam-right-aisle:554/ch0_1.264 -f v4l2 /dev/video3