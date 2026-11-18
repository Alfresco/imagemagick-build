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

OS_ID="${BASE_IMAGE##*/}"
OS_ID="${OS_ID//[:.]/}"
# OS-wide hook, then an optional one for this ImageMagick version only.
# Run with bash: hooks committed through the GitHub API lose their exec bit.
for hook in "../after-checkout-$OS_ID.sh" "../after-checkout-$OS_ID-$IMAGEMAGICK_VERSION.sh"; do
    if [ -f "$hook" ]; then
        bash -e "$hook"
    fi
done

sed -i "1s/\${version}/$IMAGEMAGICK_VERSION/g" "debian/changelog" "debian/README.Debian"

mk-build-deps -Bi

dpkg-buildpackage -b -uc

echo "Imagemagick $IMAGEMAGICK_VERSION built successfully."
ls -l ../*.deb

exit 0
