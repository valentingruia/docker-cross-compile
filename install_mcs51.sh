#!/bin/bash -x

rev_SDCC="4.5.0"

wget -O sdcc-${rev_SDCC}-amd64-unknown-linux2.5.tar.bz2 https://sourceforge.net/projects/sdcc/files/sdcc-linux-amd64/${rev_SDCC}/sdcc-${rev_SDCC}-amd64-unknown-linux2.5.tar.bz2/download
tar -xvjf sdcc-${rev_SDCC}-amd64-unknown-linux2.5.tar.bz2

# cd sdcc-${rev_SDCC}
# cd ..
# cp -r sdcc-${rev_SDCC} ~/dev_rpi
cd sdcc-${rev_SDCC}
cp -r * /usr/local

# from ./sdcc-${rev_SDCC}/INSTALL.txt file
# Install sdcc binaries into:      /usr/local/bin/
# header files into:               /usr/local/share/sdcc/include/
# non-free header files into:      /usr/local/share/sdcc/non-free/include/
# library files into:              /usr/local/share/sdcc/lib/
# non-free library files into:     /usr/local/share/sdcc/non-free/lib/
# and documentation into:          /usr/local/share/sdcc/doc/


