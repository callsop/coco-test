#!/bin/bash
#
# Doesn't appear like there is a published package available
# at this time, so this will build it from source by downloading
# it, building and installing.
#
mkdir -p lwtools
cd lwtools
wget http://www.lwtools.ca/releases//lwtools/lwtools-4.24.tar.gz
tar xvf lwtools-4.24.tar.gz
cd lwtools-4.24/
sudo patch -p1 < ../../setup/lwtools.patch
sudo make install