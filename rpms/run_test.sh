#!/bin/bash

IMAGEMAGICK_VERSION=$1
TARGET_ARCH=$2

# Install the RPMs
IMAGEMAGICK_VERSION=$1
yum install -y /root/rpmbuild/RPMS/${TARGET_ARCH}/ImageMagick-libs-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm
yum install -y /root/rpmbuild/RPMS/${TARGET_ARCH}/ImageMagick-$IMAGEMAGICK_VERSION.$TARGET_ARCH.rpm

#Check ImageMagick commands
convert -version
