#!/bin/bash -e

if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "GITHUB_WORKSPACE is not set"
    exit 1
fi

DEST_DIR=$GITHUB_WORKSPACE/packages

echo "Copying prebuilt packages for $IMAGEMAGICK_VERSION to $DEST_DIR"
mkdir -p "$DEST_DIR"

if [ -e /etc/debian_version ]; then
   cp /root/*.deb "$DEST_DIR" 
else
   if [ -e /etc/redhat-release ]; then
      cp /root/rpmbuild/RPMS/x86_64/*.rpm  "$DEST_DIR"
   fi
 fi

echo "::set-output name=built-version::$IMAGEMAGICK_VERSION"

exit 0