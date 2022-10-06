#!/bin/bash -e

if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "GITHUB_WORKSPACE is not set"
    exit 1
fi

apt-get update && apt-get upgrade -y &&  apt-get install build-essential git automake equivs -y

git clone --depth 1 -b $1 https://github.com/ImageMagick/ImageMagick.git

cd ImageMagick && \
    mv /tmp/debian . && \
    sed -i "1s/7.1.0-16/$1/g" "debian/changelog" "debian/README.Debian" && \
    apt-get install -y dpkg-dev devscripts gawk ghostscript gsfonts libzstd-dev libbz2-dev libdjvulibre-dev libfftw3-dev fontconfig libfreetype6-dev libgs-dev libjbig-dev libjpeg8-dev libjpeg-turbo8-dev liblcms2-dev liblqr-1-0-dev libltdl-dev liblzma-dev libopenexr-dev libopenjp2-7-dev libpango1.0-dev libperl-dev libpng-dev libraqm-dev libraw-dev librsvg2-dev libtiff5-dev libwebp-dev libwmf-dev libx11-dev libxext-dev libxml2-dev libxt-dev libzip-dev zlib1g-dev && \
    yes | mk-build-deps -Bi && dpkg-buildpackage -b -uc

echo "::set-output name=built-version::$1"

exit 0
