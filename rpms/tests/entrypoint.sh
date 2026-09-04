#!/bin/bash
set -e -o pipefail -x

if [ -z "$BASE_IMAGE" ]; then
    echo "BASE_IMAGE env needs to be set"
    exit 1
fi

if [ -z "$1" ]; then
    echo "first argument needs to be set - IMAGEMAGICK_VERSION"
    exit 1
fi

if [ -z "$2" ]; then
    echo "second argument needs to be set - TARGET_ARCH"
    exit 1
fi

IMAGEMAGICK_VERSION=$1
TARGET_ARCH=$2

echo "Test install imagemagick packages"
yum install -y ImageMagick-libs-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm
yum install -y ImageMagick-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm

echo "ldd output of convert command"
ldd /usr/bin/convert

echo "Testing convert command"
convert -version

echo "Creating test image file"
convert  -size 32x32 xc:transparent test.png

echo "Converting png to jpg"
convert test.png test1.jpg

source /etc/os-release
if [[ "$VERSION_ID" == 8* || "$VERSION_ID" == 9* ]]; then
    echo "=== HEIC decode test ==="
    HEIC_RPM=ImageMagick-heic-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm

    # The build container already has the libheif package (needed to compile),
    # whose files conflict with the ones bundled into ImageMagick-heic, so the
    # decoder can only be installed and exercised in a clean environment (the
    # dedicated test job / a real consumer such as ATS).
    if rpm -q libheif >/dev/null 2>&1 || rpm -q libheif-freeworld >/dev/null 2>&1; then
        echo "libheif already present (build container) - skipping HEIC test"
    else
        echo "Installing ImageMagick-heic and decoding a sample HEIC file"
        yum install -y "$HEIC_RPM"
        convert /sample.heic /tmp/heic-out.jpg
        echo "HEIC tested successfully: $(ls -l /tmp/heic-out.jpg)"
    fi
fi

exit 0
