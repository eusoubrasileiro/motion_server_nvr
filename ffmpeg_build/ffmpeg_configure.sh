# debian linux deploy 

sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  pkg-config \
  yasm  \
  wget \
  unzip
sudo wget https://github.com/eusoubrasileiro/FFmpeg/archive/refs/heads/release/4.3.zip
unzip 4.3.zip
cd FFmpeg-release-4.3
#export CFLAGS='-g -O3 -ftree-vectorize -mcpu=cortex-a53 -march=armv8-a+crypto+crc+simd' 

# based on ffmpeg-kit android.sh
./configure --arch=arm64  --target-os=linux --enable-pic  --enable-optimizations  --enable-swscale \
--disable-outdevs    --disable-indevs  --disable-openssl  --disable-xmm-clobber-test  --disable-neon-clobber-test \
--disable-ffplay  --disable-postproc  --disable-doc  --disable-htmlpages  --disable-manpages  --disable-podpages \
--disable-txtpages   --disable-sndio  --disable-schannel --disable-securetransport  --disable-xlib  --disable-cuda  \
--disable-cuvid  --disable-nvenc   --disable-vaapi  --disable-vdpau  --disable-videotoolbox  --disable-audiotoolbox  \
--disable-appkit  --disable-alsa  --disable-cuda --disable-cuvid  --disable-nvenc  \
--disable-vaapi --disable-vdpau --enable-shared --enable-v4l2-m2m 
# --prefix=/usr/local is the default and binaries on /usr/local/bin
# v4l2-m2m provides some hardware accelerated decoders/enconder

make -j8
sudo make install 

