#!/bin/bash -e

if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "GITHUB_WORKSPACE is not set"
    exit 1
fi

# Build dependencies
dnf install -y epel-release git make wget 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y rpm-build yum-utils && \
    dnf group install -y "Development Tools" && \
    dnf clean all

# Imagemagick sources
git clone --depth 1 -b $1 https://github.com/ImageMagick/ImageMagick.git

# Generate updated .src.rpm
cd ImageMagick && \
    ./configure && \
    make dist-xz && \
    sed -i '/BuildRequires.*lqr/d' ImageMagick.spec && \
    make srpm

# Finally build rpm
 cd $GITHUB_WORKSPACE/ImageMagick && \
    yum-builddep -y ImageMagick-$1.src.rpm && \
    rpmbuild --rebuild --nocheck ImageMagick-$1.src.rpm

ls  /github/home/rpmbuild/RPMS/x86_64

DEST_DIR=$GITHUB_WORKSPACE/rpms

echo "Copying prebuilt packages for $1 to $DEST_DIR"
mkdir -p "$DEST_DIR"
cp /github/home/rpmbuild/RPMS/x86_64/*.rpm "$DEST_DIR"

echo "::set-output name=built-version::$1"

exit 0
