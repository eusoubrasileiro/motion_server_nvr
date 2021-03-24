cd motion
autoreconf -fiv
# copy src\* modified files to motion/src replacing originals
./configure
make -j4
# copy to usr/bin the compiled binary
cp ~/motion_sources/motion/src/motion  ~/../usr/bin/
