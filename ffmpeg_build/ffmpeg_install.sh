#!/bin/bash

sudo apt-get update -qq && DEBIAN_FRONTEND=noninteractive sudo apt-get install -yfq --no-install-recommends \
  autoconf \
  automake \
  build-essential \
  pkg-config \
  yasm  \
  wget \
  unzip \
  libv4l-dev \
  libv4l-0 \
  i965-va-driver \
  libvdpau-dev \
  ninja-build  \
  libva-dev \
  libva2 \
  libmfx-dev \
  libvdpau-dev \
  libvorbis-dev \
  v4l2loopback-dkms # support hevc_qs intel hardware decoding h265
# libv4l-dev libv4l-0  for video4linux decoders/encoders

if [ ! -d "FFmpeg" ]; then # only if not cloned
  git clone --depth 1 --branch release/4.4 https://github.com/FFmpeg/FFmpeg.git
fi

cd FFmpeg
git reset --hard 
# Applying the patch: git apply --stat file.patch # show stats. 
# git apply --check file.patch # check for error before applying. 
# git am < file.patch # apply the patch finally.
git config --global user.email aflopes7@gmail.com
git config --global user.name eusoubrasileiro
# apply the patch finally.
git am <  ../RTSP_LOWER_TRANSPORT_TCP-Yoose-Ip-Camera-Fix.patch

make clean 

#  compiling on linux not android
if [ "`uname -m`" = "x86_64" ] ; then 
  ./configure --disable-outdevs  --disable-indevs   \
  --enable-shared --prefix=/usr/local --extra-libs="-lpthread -lm" \
  --ld="g++" --extra-cflags="-pthread"
  # --prefix=/usr/local is the default for real linux let it be
fi

sudo make -j$(nproc)
sudo make install 

echo "LD_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH" >> ~/.bashrc

source ~/.bashrc
