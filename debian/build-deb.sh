#!/bin/bash

cd projman_2

VERSION=$(grep Version projman.tcl | grep -oE '\b[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}\b')
RELEASE=$(grep Release projman.tcl | grep -oE '\b[0-9A-Za-z]{1,3}\b')

mv projman.tcl projman

sed -i "s+^set\ dir(lib)+set\ dir(lib)\ /usr/share/projman/lib ;#+g" projman
   
sed -i "s+\[pwd\]+/usr/share/projman+g" projman
   
tar czf ../projman_${VERSION}.orig.tar.gz .

dpkg-buildpackage

#cp ../projman_${VERSION}-${RELEASE}_amd64.deb /files/

mv projman projman.tcl
