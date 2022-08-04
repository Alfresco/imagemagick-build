#!/bin/bash -e

if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "GITHUB_WORKSPACE is not set"
    exit 1
fi

cp /root/rpmbuild/RPMS/x86_64/*.rpm "$GITHUB_WORKSPACE/"

ls "$GITHUB_WORKSPACE"
