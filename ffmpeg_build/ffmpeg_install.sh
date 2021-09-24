#!/bin/bash
# debian linux deploy 

sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  pkg-config \
  yasm  \
  wget \
  unzip \
  libv4l-dev \
  libv4l-0
# libv4l-dev libv4l-0  for video4linux decoders/encoders

if [ ! -f "ffmpeg-4.3.zip" ]; then # only if not downloaded yet
    wget -O ffmpeg-4.3.zip https://github.com/eusoubrasileiro/FFmpeg/archive/refs/heads/release/4.3.zip
fi
if [ ! -d "FFmpeg-release-4.3" ]; then # only if not unziped yet
   unzip ffmpeg-4.3.zip
fi
    

cd FFmpeg-release-4.3
#export CFLAGS='-g -O3 -ftree-vectorize -mcpu=cortex-a53 -march=armv8-a+crypto+crc+simd' 
make clean 

# based on ffmpeg-kit android.sh
# compiling on a chroot linux android
if [ "`uname -m`" = "aarch64" ] ; then  
  ./configure --arch=arm64  --target-os=linux --enable-pic  --enable-optimizations  --enable-swscale \
  --disable-outdevs    --disable-indevs  --disable-openssl  --disable-xmm-clobber-test  --disable-neon-clobber-test \
  --disable-ffplay  --disable-postproc  --disable-doc  --disable-htmlpages  --disable-manpages  --disable-podpages \
  --disable-txtpages   --disable-sndio  --disable-schannel --disable-securetransport  --disable-xlib  --disable-cuda  \
  --disable-cuvid  --disable-nvenc   --disable-vaapi  --disable-vdpau  --disable-videotoolbox  --disable-audiotoolbox  \
  --disable-appkit  --disable-alsa  --disable-cuda --disable-cuvid  --disable-nvenc  \
  --disable-vaapi --disable-vdpau --enable-shared --enable-v4l2-m2m --prefix=/usr
# --prefix=/usr/local is the default and binaries on /usr/local/bin
# but better user /usr to avoid LD_LIBRARY_PATH set 
# v4l2-m2m provides some hardware accelerated decoders/enconder
fi
#  compiling on real linux not android
if [ "`uname -m`" = "x86_64" ] ; then 
  ./configure --enable-optimizations  --enable-swscale \
  --disable-outdevs    --disable-indevs   \
  --enable-shared --prefix=/usr/local
  # --prefix=/usr/local is the default for real linux let it be
fi

sudo make -j8
sudo make install 
