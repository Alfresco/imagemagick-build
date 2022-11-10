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
    sed -i '/BuildRequires.*lqr/d; /--with-lqr/d' ImageMagick.spec.in && \
    sed -i '/%package lib/a AutoReq: no' ImageMagick.spec.in && \
    sed -i '/AutoReq: no/a Requires: libHalf.so.12()(64bit) libICE.so.6()(64bit) libIex-2_2.so.12()(64bit) libIexMath-2_2.so.12()(64bit) libIlmImf-2_2.so.22()(64bit) libIlmThread-2_2.so.12()(64bit) libImath-2_2.so.12()(64bit) libSM.so.6()(64bit) libX11.so.6()(64bit) libXext.so.6()(64bit) libXt.so.6()(64bit) libbz2.so.1()(64bit) libc.so.6()(64bit) libc.so.6(GLIBC_2.11)(64bit) libc.so.6(GLIBC_2.14)(64bit) libc.so.6(GLIBC_2.17)(64bit) libc.so.6(GLIBC_2.2.5)(64bit) libc.so.6(GLIBC_2.3)(64bit) libc.so.6(GLIBC_2.3.4)(64bit) libc.so.6(GLIBC_2.4)(64bit) libc.so.6(GLIBC_2.6)(64bit) libcairo.so.2()(64bit) xlibfontconfig.so.1()(64bit) libfreetype.so.6()(64bit) libgcc_s.so.1()(64bit) libgcc_s.so.1(GCC_3.3.1)(64bit) libgdk_pixbuf-2.0.so.0()(64bit) libgio-2.0.so.0()(64bit) libglib-2.0.so.0()(64bit) libgobject-2.0.so.0()(64bit) libgomp.so.1()(64bit) libgomp.so.1(GOMP_1.0)(64bit) libgomp.so.1(GOMP_4.0)(64bit) libgomp.so.1(OMP_1.0)(64bit) libgomp.so.1(OMP_3.0)(64bit) libjbig.so.2.1()(64bit) libjpeg.so.62()(64bit) libjpeg.so.62(LIBJPEG_6.2)(64bit) liblcms2.so.2()(64bit) libltdl.so.7()(64bit) liblzma.so.5()(64bit) liblzma.so.5(XZ_5.0)(64bit) libm.so.6()(64bit) libm.so.6(GLIBC_2.2.5)(64bit) libopenjp2.so.7()(64bit) libpango-1.0.so.0()(64bit) libpangocairo-1.0.so.0()(64bit) libpng16.so.16()(64bit) libpng16.so.16(PNG16_0)(64bit) libpthread.so.0()(64bit) libpthread.so.0(GLIBC_2.2.5)(64bit) libraqm.so.0()(64bit) libraw_r.so.19()(64bit) librsvg-2.so.2()(64bit) libtiff.so.5()(64bit) libtiff.so.5(LIBTIFF_4.0)(64bit) libwebp.so.7()(64bit) libwebpdemux.so.2()(64bit) libwebpmux.so.3()(64bit) libwmflite-0.2.so.7()(64bit) libxml2.so.2()(64bit) libxml2.so.2(LIBXML2_2.4.30)(64bit) libxml2.so.2(LIBXML2_2.6.0)(64bit) libz.so.1()(64bit) rtld(GNU_HASH)' ImageMagick.spec.in && \
    ./configure && \
    make dist-xz && \
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

echo "built-version=$1" >> "$GITHUB_OUTPUT"

exit 0
