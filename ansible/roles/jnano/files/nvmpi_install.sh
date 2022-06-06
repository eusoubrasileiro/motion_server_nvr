#!/bin/bash

# Custom ffmpeg for jetson nano 
# 1.build nvmpi library local folder

if [ ! -d "jetson-ffmpeg" ]; then
    git clone https://github.com/jocover/jetson-ffmpeg.git
fi

# needs usr/src/jetson_multimedia_api/samples

cd jetson-ffmpeg
cmake .
make 
# without this ffmpeg cant find nvmpi library even for execution
make install 