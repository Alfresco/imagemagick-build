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

git clone --depth 1 -b $IMAGEMAGICK_VERSION https://github.com/ImageMagick/ImageMagick.git

mv debian ImageMagick/

cd ImageMagick

AFTER_CHECKOUT_HOOK_SCRIPT="../after-checkout-$IMAGE_TAG-$IMAGEMAGICK_VERSION.sh"
if [ -x "$AFTER_CHECKOUT_HOOK_SCRIPT" ]; then
    "$AFTER_CHECKOUT_HOOK_SCRIPT"
fi

sed -i "1s/\${version}/$IMAGEMAGICK_VERSION/g" "debian/changelog" "debian/README.Debian"

mk-build-deps -Bi

dpkg-buildpackage -b -uc

echo "Imagemagick $IMAGEMAGICK_VERSION built successfully."
ls -l ../*.deb

echo "Testing package expected dependencies"
dpkg-deb -f ../imagemagick-alfresco_${IMAGEMAGICK_VERSION}_amd64.deb  Depends | grep -qEv 'libcdt|libcgraph|libgvc|libgs9'

echo "Installing package"
dpkg -i ../imagemagick-alfresco_${IMAGEMAGICK_VERSION}_amd64.deb

echo "Exporting the path of the package"
export PATH="/opt/imagemagick-7/bin:$PATH"

echo "Testing convert command"
convert -version

echo "Creating test image file"
convert  -size 32x32 xc:transparent test.png

echo "Converting png to jpg"
convert test.png test1.jpg

exit 0
