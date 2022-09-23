FROM ubuntu:18.04

ENV IMAGEMAGICK_VERSION=7.1.0-16
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical
ENV DEBCONF_NOWARNINGS=yes
ENV LOGNAME root

# Build dependencies
RUN apt-get update && apt-get upgrade -y &&  apt-get install build-essential git automake equivs -y

WORKDIR /root
ADD debian /tmp/debian

# Imagemagick sources
RUN git clone --depth 1 -b $IMAGEMAGICK_VERSION https://github.com/ImageMagick/ImageMagick.git

RUN cd ImageMagick && \
    mv /tmp/debian . && \
    apt-get install -y dpkg-dev devscripts gawk ghostscript gsfonts libzstd-dev libbz2-dev libdjvulibre-dev libfftw3-dev fontconfig libfreetype6-dev libgs-dev libjbig-dev libjpeg8-dev libjpeg-turbo8-dev liblcms2-dev liblqr-1-0-dev libltdl-dev liblzma-dev libopenexr-dev libopenjp2-7-dev libpango1.0-dev libperl-dev libpng-dev libraqm-dev libraw-dev librsvg2-dev libtiff5-dev libwebp-dev libwmf-dev libx11-dev libxext-dev libxml2-dev libxt-dev libzip-dev zlib1g-dev && \
    yes | mk-build-deps -Bi && dpkg-buildpackage -b -uc

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]