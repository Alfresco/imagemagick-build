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

HEIC_RPM=ImageMagick-heic-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm
HEIC_REQUIRES=$(rpm -qp --requires "$HEIC_RPM")
HEIC_FILES=$(rpm -qlp "$HEIC_RPM")
if grep -Ei 'x265' <<< "$HEIC_REQUIRES" || grep -Ei 'x265' <<< "$HEIC_FILES"; then
    echo 'Decode-only HEIC RPM must not require or bundle x265' >&2
    exit 1
fi

echo "Test install imagemagick packages"
yum --disablerepo='rpmfusion*' install -y ImageMagick-libs-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm
yum --disablerepo='rpmfusion*' install -y ImageMagick-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm

echo "ldd output of convert command"
ldd /usr/bin/convert

echo "Testing convert command"
convert -version

echo "Creating test image file"
convert  -size 32x32 xc:transparent test.png

echo "Converting png to jpg"
convert test.png test1.jpg

echo "=== HEIC decode test ==="
if [[ "${HEIC_BUILD_CONTAINER:-false}" == true ]]; then
    # RPM-owned build dependencies conflict with the bundled library paths.
    # The dedicated clean test image must install and exercise the HEIC RPM.
    echo 'HEIC metadata checked; bundled-library installation is tested in the clean test image'
    exit 0
fi

echo "Installing ImageMagick-heic and decoding a sample HEIC file"
yum --disablerepo='rpmfusion*' install -y "$HEIC_RPM"
INSTALLED_PACKAGES=$(rpm -qa --qf '%{NAME}\n')
if grep -Ei 'x265|^rpmfusion-' <<< "$INSTALLED_PACKAGES"; then
    echo 'Clean HEIC test must not have x265 or RPM Fusion release packages installed' >&2
    exit 1
fi
convert /sample.heic /tmp/heic-out.jpg
test -s /tmp/heic-out.jpg
echo "HEIC tested successfully: $(ls -l /tmp/heic-out.jpg)"

exit 0
