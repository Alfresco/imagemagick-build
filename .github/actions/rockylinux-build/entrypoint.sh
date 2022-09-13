#!/bin/bash -e

if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "GITHUB_WORKSPACE is not set"
    exit 1
fi

OS=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}')

DEST_DIR=$GITHUB_WORKSPACE/packages

echo "Copying prebuilt RPMs for $IMAGEMAGICK_VERSION to $DEST_DIR"
mkdir -p "$DEST_DIR"

if [ "$OS" = "Ubuntu" ]; then \
   cp /root/*.deb "$DEST_DIR" 
else 
   cp /root/rpmbuild/RPMS/x86_64/*.rpm  "$DEST_DIR"
fi

echo "::set-output name=built-version::$IMAGEMAGICK_VERSION"

exit 0