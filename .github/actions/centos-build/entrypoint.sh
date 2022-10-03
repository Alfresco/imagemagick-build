#!/bin/bash -e
##Build dependencies
yum install -y epel-release git make && \
    yum-config-manager --enable powertools && \
    yum install -y rpm-build yum-utils && \
    yum group install -y "Development Tools" && \
    yum clean all

## Imagemagick sources
git clone --depth 1 -b $1 https://github.com/ImageMagick/ImageMagick.git

## Generate updated .src.rpm
cd ImageMagick && \
    ./configure && \
    make dist-xz && \
    sed -i '/BuildRequires.*lqr/d' ImageMagick.spec && \
    make srpm

## Finally build rpm
cd /github/workspace/ImageMagick && \
    yum-builddep -y ImageMagick-$1.src.rpm && \
    rpmbuild --rebuild --nocheck ImageMagick-$1.src.rpm

ls /root/rpmbuild/RPMS/x86_64

if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "GITHUB_WORKSPACE is not set"
    exit 1
fi

DEST_DIR=$GITHUB_WORKSPACE/rpms

echo "Copying prebuilt packages for $1 to $DEST_DIR"
mkdir -p "$DEST_DIR"
cp /root/rpmbuild/RPMS/x86_64/*.rpm  "$DEST_DIR"

echo "::set-output name=built-version::$1"

exit 0