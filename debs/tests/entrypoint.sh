#!/bin/bash
set -e -o pipefail -x

if [ -z "$BASE_IMAGE" ]; then
    echo "BASE_IMAGE env needs to be set"
    exit 1
fi

if [ -z "$1" ]; then
    echo "first argument must be provided: IMAGEMAGICK_VERSION"
    exit 1
fi

if [ -z "$2" ]; then
    echo "second argument must be provided: PKG_ARCH"
    exit 1
fi

IMAGEMAGICK_VERSION=$1
PKG_ARCH=$2

echo "Installing package"
dpkg -i --force-depends "imagemagick-alfresco_${IMAGEMAGICK_VERSION}_${PKG_ARCH}.deb"
apt-get -f install

echo "Exporting the path of the package"
export PATH="/opt/imagemagick-7/bin:$PATH"

echo "ldd output of convert command"
ldd /opt/imagemagick-7/bin/convert

echo "Testing convert command"
convert -version

echo "Creating test image file"
convert  -size 32x32 xc:transparent test.png

echo "Converting png to jpg"
convert test.png test1.jpg

exit 0
