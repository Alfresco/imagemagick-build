#!/bin/bash -e
echo "! $1"
if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "GITHUB_WORKSPACE is not set"
    exit 1
fi

DEST_DIR=$GITHUB_WORKSPACE/rpms

echo "Copying prebuilt packages for $IMAGEMAGICK_VERSION to $DEST_DIR"
mkdir -p "$DEST_DIR"
cp /root/rpmbuild/RPMS/x86_64/*.rpm  "$DEST_DIR"

echo "::set-output name=built-version::$IMAGEMAGICK_VERSION"

exit 0