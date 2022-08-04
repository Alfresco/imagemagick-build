FROM rockylinux:8

ENV IMAGEMAGICK_VERSION=7.1.0-45

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

ENTRYPOINT ["/entrypoint.sh"]
