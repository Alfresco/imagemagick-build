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

echo "Preparing to build Imagemagick $IMAGEMAGICK_VERSION for $TARGET_ARCH..."

git clone --depth 1 -b "$IMAGEMAGICK_VERSION" https://github.com/ImageMagick/ImageMagick.git
cd ImageMagick

# Drop LQR support
sed -i '/BuildRequires.*lqr/d; /--with-lqr/d' ImageMagick.spec.in

# Drop Raqm support
sed -i '/BuildRequires.*raqm/d; s/--with-raqm/--without-raqm/' ImageMagick.spec.in

# Drop ghostscript support
sed -i '/BuildRequires.*ghostscript-devel/d; s/--with-gslib/--without-gslib/' ImageMagick.spec.in

AFTER_CHECKOUT_HOOK_SCRIPT="../after-checkout-${BASE_IMAGE//:/}-$IMAGEMAGICK_VERSION.sh"
if [ -x "$AFTER_CHECKOUT_HOOK_SCRIPT" ]; then
    "$AFTER_CHECKOUT_HOOK_SCRIPT"
fi

# Generate updated src.rpm
./configure
make dist-xz
make srpm

# Build it
yum-builddep -y "ImageMagick-$IMAGEMAGICK_VERSION.src.rpm"
rpmbuild --rebuild --nocheck --target "$TARGET_ARCH" "ImageMagick-$IMAGEMAGICK_VERSION.src.rpm"

echo "Imagemagick $IMAGEMAGICK_VERSION for $TARGET_ARCH built successfully."
ls  -lR /root/rpmbuild/RPMS

echo "Testing package expected dependencies"
rpm -qp --requires /root/rpmbuild/RPMS/${TARGET_ARCH}/ImageMagick-libs-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm | grep -qEv 'libgs'

echo "Installing packages"
yum install -y /root/rpmbuild/RPMS/${TARGET_ARCH}/ImageMagick-libs-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm
yum install -y /root/rpmbuild/RPMS/${TARGET_ARCH}/ImageMagick-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm

echo "Testing convert command"
convert -version

echo "Creating test image file"
convert  -size 32x32 xc:transparent test.png

echo "Converting png to jpg"
convert test.png test1.jpg

exit 0
