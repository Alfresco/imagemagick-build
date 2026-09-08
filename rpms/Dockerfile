ARG BASE_IMAGE=rockylinux/rockylinux:9

FROM ${BASE_IMAGE}

RUN <<EOF
dnf update -y
dnf install -y epel-release git make yum-utils rpm-build
dnf group install -y "Development Tools"
dnf clean packages
EOF

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

RUN <<EOF
source /etc/os-release
case "$VERSION_ID" in
    9*)
        dnf install -y dnf-plugins-core
        dnf config-manager --set-enabled crb
        # Build-time libheif/libde265 for the HEIC decoder (from EPEL + RPM Fusion). entrypoint.sh bundles them into the RPM
        dnf install -y --nogpgcheck "https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm"
        dnf install -y libheif-devel libheif-freeworld libde265
        dnf clean packages
        ;;
    8*)
        yum-config-manager --enable powertools
        # Build-time libde265 for the HEIC decoder (from RPM Fusion free). entrypoint.sh bundles it into the RPM
        dnf install -y --nogpgcheck "https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm"
        dnf install -y libde265-devel cmake
        # RPM Fusion's own el8 libheif package links the GPL x265 encoder directly
        # into libheif.so, which would leak a "Requires: libx265" onto the
        # decode-only ImageMagick-heic RPM. Build libheif from source instead with
        # the x265 encoder disabled, so the bundled library only needs libde265.
        git clone --branch v1.17.6 --depth 1 https://github.com/strukturag/libheif.git /tmp/libheif
        cmake -S /tmp/libheif -B /tmp/libheif/build \
            -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib64 -DCMAKE_BUILD_TYPE=Release \
            -DWITH_X265=OFF -DWITH_X265_PLUGIN=OFF -DWITH_LIBDE265_PLUGIN=OFF \
            -DWITH_AOM_DECODER=OFF -DWITH_AOM_ENCODER=OFF -DWITH_X264=OFF -DWITH_DAV1D=OFF \
            -DWITH_OpenH264_DECODER=OFF -DWITH_EXAMPLES=OFF -DBUILD_TESTING=OFF -DENABLE_PLUGIN_LOADING=OFF
        cmake --build /tmp/libheif/build -j"$(nproc)"
        cmake --install /tmp/libheif/build
        rm -rf /tmp/libheif
        dnf clean packages
        ;;
    *)
        echo "Unsupported OS version: $VERSION_ID" && exit 1 ;;
esac
EOF

WORKDIR /build
COPY after-checkout-* /build/
COPY tests/entrypoint.sh /tests.sh
COPY tests/sample.heic /sample.heic
COPY bundle-heic-decoder.sh /bundle-heic-decoder.sh

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
