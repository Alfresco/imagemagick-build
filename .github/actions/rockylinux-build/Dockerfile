FROM rockylinux:8

ENV IMAGEMAGICK_VERSION=7.1.0-16

# Build dependencies
RUN dnf install -y epel-release git make wget 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y rpm-build yum-utils && \
    dnf group install -y "Development Tools" && \
    dnf clean all

# Imagemagick sources
RUN git clone --depth 1 -b $IMAGEMAGICK_VERSION https://github.com/ImageMagick/ImageMagick.git

# Generate updated .src.rpm
RUN cd ImageMagick && \
    ./configure && \
    make dist-xz && \
    sed -i '/BuildRequires.*lqr/d' ImageMagick.spec && \
    make srpm

# Finally build rpm
RUN cd ImageMagick && \
    yum-builddep -y ImageMagick-$IMAGEMAGICK_VERSION.src.rpm && \
    rpmbuild --rebuild --nocheck ImageMagick-$IMAGEMAGICK_VERSION.src.rpm

RUN ls /root/rpmbuild/RPMS/x86_64

COPY entrypoint.sh /entrypoint.sh

FROM centos:7 AS centos7

ENV IMAGEMAGICK_VERSION=7.1.0-16

# Build dependencies
RUN yum install -y epel-release git make && \
    yum-config-manager --enable powertools && \
    yum install -y rpm-build yum-utils && \
    yum group install -y "Development Tools" && \
    yum clean all

# Imagemagick sources
RUN git clone --depth 1 -b $IMAGEMAGICK_VERSION https://github.com/ImageMagick/ImageMagick.git

# Generate updated .src.rpm
RUN cd ImageMagick && \
    ./configure && \
    make dist-xz && \
    sed -i '/BuildRequires.*lqr/d' ImageMagick.spec && \
    make srpm

# Finally build rpm
RUN cd ImageMagick && \
    yum-builddep -y ImageMagick-$IMAGEMAGICK_VERSION.src.rpm && \
    rpmbuild --rebuild --nocheck ImageMagick-$IMAGEMAGICK_VERSION.src.rpm

RUN ls /root/rpmbuild/RPMS/x86_64

COPY entrypoint.sh /entrypoint.sh

FROM ubuntu:18.04 AS ubuntu18

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
    apt-get install -y dpkg-dev devscripts gawk libzstd-dev libbz2-dev libdjvulibre-dev libfftw3-dev fontconfig libfreetype6-dev libgs-dev libjbig-dev libjpeg8-dev libjpeg-turbo8-dev liblcms2-dev liblqr-1-0-dev libltdl-dev liblzma-dev libopenexr-dev libopenjp2-7-dev libpango1.0-dev libperl-dev libpng-dev libraqm-dev libraw-dev librsvg2-dev libtiff5-dev libwebp-dev libwmf-dev libx11-dev libxext-dev libxml2-dev libxt-dev libzip-dev zlib1g-dev && \
    yes | mk-build-deps -Bi && dpkg-buildpackage -b -uc

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]