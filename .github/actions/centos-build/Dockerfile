FROM centos:7


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

COPY entrypoint.sh  /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]