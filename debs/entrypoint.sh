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

IMAGEMAGICK_VERSION=$1

git clone --depth 1 -b "$IMAGEMAGICK_VERSION" https://github.com/ImageMagick/ImageMagick.git

mv debian ImageMagick/

cd ImageMagick

AFTER_CHECKOUT_HOOK_SCRIPT="../after-checkout-${BASE_IMAGE//[:.]/}-$IMAGEMAGICK_VERSION.sh"
if [ -x "$AFTER_CHECKOUT_HOOK_SCRIPT" ]; then
    "$AFTER_CHECKOUT_HOOK_SCRIPT"
fi

sed -i "1s/\${version}/$IMAGEMAGICK_VERSION/g" "debian/changelog" "debian/README.Debian"

mk-build-deps -Bi

dpkg-buildpackage -b -uc

echo "Imagemagick $IMAGEMAGICK_VERSION built successfully."
ls -l ../*.deb

exit 0
