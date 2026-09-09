#!/bin/bash -e
sed -i "s/libtiff5/libtiff6/g" debian/control
sed -i "s/mime-support/mailcap,media-types/g" debian/control
sed -i "s/libraw-dev,//g" debian/control
