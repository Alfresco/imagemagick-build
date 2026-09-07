#!/bin/bash -e
sed -i "s/libwebp7/libwebp6/g" debian/control

# 18.04 (EOL) has a libheif older than ImageMagick requires, so disable HEIC here.
sed -i "s/--with-heic/--without-heic/" debian/rules
sed -i "s/, libheif-dev//" debian/control
sed -i "s/, libheif-plugin-libde265 | libde265-0//" debian/control
