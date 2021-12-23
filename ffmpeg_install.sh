#!/bin/bash

# Custom ffmpeg for jetson nano 
# 1.build and install library
git clone https://github.com/jocover/jetson-ffmpeg.git
cd jetson-ffmpeg
mkdir build
cd build
cmake ..
make
sudo make install
sudo ldconfig

# 2.patch ffmpeg 
git clone git://source.ffmpeg.org/ffmpeg.git -b release/4.2 --depth=1
cd ffmpeg
wget https://github.com/jocover/jetson-ffmpeg/raw/master/ffmpeg_nvmpi.patch
git apply ffmpeg_nvmpi.patch

# Add my cystom patch 
patch -p1 < ../RTSP_LOWER_TRANSPORT_TCP-Yoose-Ip-Camera-Fix.patch

make clean 
#  compiling jetson nano 
./configure --disable-outdevs  --disable-indevs --enable-nvmpi \
--enable-shared --prefix=/usr/local #is the default for real linux let it be

make -j$(nproc)
sudo make install 

# testing  hevc_nvmpi decoder 
#./ffmpeg -v quiet -stats -rtsp_transport tcp -y -c:v  hevc_nvmpi -i rtsp://user:pass@ipcam.kitchen:554/onvif2 -f null -
# working perfectly after install  only progress with -v quiet -stats
# less image smearing/tearing errors etc.. 

echo "LD_LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH" >> ~/.bashrc

source ~/.bashrc
