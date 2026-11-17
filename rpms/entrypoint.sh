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

# Drop LibRaw support which is not compatible with the current version of ImageMagick
sed -i '/BuildRequires.*LibRaw/d; /--with-raw/d' ImageMagick.spec.in

# A git checkout has no release tarball signature, and %prep never verifies it.
sed -i '/^Source[0-9]*:.*\.asc$/d' ImageMagick.spec.in

OS_ID="${BASE_IMAGE##*/}"
OS_ID="${OS_ID//[:.]/}"
# OS-wide hook, then an optional one for this ImageMagick version only.
for hook in "../after-checkout-$OS_ID.sh" "../after-checkout-$OS_ID-$IMAGEMAGICK_VERSION.sh"; do
    if [ -f "$hook" ]; then
        bash -e "$hook"
    fi
done

# Generate updated src.rpm
./configure
make dist-xz
make srpm

# Build it
yum-builddep -y "ImageMagick-$IMAGEMAGICK_VERSION.src.rpm"
rpmbuild --rebuild --nocheck --target "$TARGET_ARCH" "ImageMagick-$IMAGEMAGICK_VERSION.src.rpm"

echo "Imagemagick $IMAGEMAGICK_VERSION for $TARGET_ARCH built successfully."
ls  -lR /root/rpmbuild/RPMS/

cd "/root/rpmbuild/RPMS/$TARGET_ARCH"

echo "Testing package for unexpected dependencies"
rpm -qp --requires ImageMagick-libs-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm | grep -qEv 'libgs'

exec /tests.sh $IMAGEMAGICK_VERSION $TARGET_ARCH
