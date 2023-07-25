#!/bin/bash

# Custom ffmpeg for jetson nano 
# 1.build nvmpi library local folder

if [ ! -d "jetson-ffmpeg" ]; then
    git clone https://github.com/Keylost/jetson-ffmpeg.git
fi


cd jetson-ffmpeg
mkdir build
cd build
cmake ..
make
make install
ldconfig