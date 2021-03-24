pkg install git
mkdir ~/motion_sources
cd ~/motion_sources
git clone https://github.com/Motion-Project/motion.git
pkg install git automake libzip gettext libmicrohttpd libwebp
cd motion
autoreconf -fiv
# copy src\* modified files to motion/src replacing originals
./configure
make
# copy to usr/bin the compiled binary
cp ~/motion_sources/motion/src/motion  ~/../usr/bin/
