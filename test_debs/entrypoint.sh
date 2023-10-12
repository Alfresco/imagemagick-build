#!/bin/bash
set -e -o pipefail -x

if [ -z "$IMAGE_TAG" ]; then
    echo "IMAGE_TAG env needs to be set"
    exit 1
fi

if [ -z "$1" ]; then
    echo "first argument needs to be set - IMAGEMAGICK_VERSION"
    exit 1
fi

IMAGEMAGICK_VERSION=$1

echo "Install dependencies"
apt-get install liblcms2-utils libfribidi0 libilmbase12 libdjvulibre21 librsvg2-2 libwmf0.2-7 libgomp1 liblqr-1-0 libltdl7 libopenexr22 libopenjp2-7 libraqm0 libraw16 libwebp6 libwebpdemux2 libwebpmux3 libzip4

echo "Testing package expected dependencies"
dpkg-deb -f imagemagick-alfresco_${IMAGEMAGICK_VERSION}_amd64.deb  Depends | grep -qEv 'libcdt|libcgraph|libgvc|libgs9'

echo "Installing package"
dpkg -i imagemagick-alfresco_${IMAGEMAGICK_VERSION}_amd64.deb

echo "Exporting the path of the package"
export PATH="/opt/imagemagick-7/bin:$PATH"

echo "Testing convert command"
convert -version

echo "Creating test image file"
convert  -size 32x32 xc:transparent test.png

echo "Converting png to jpg"
convert test.png test1.jpg

exit 0
