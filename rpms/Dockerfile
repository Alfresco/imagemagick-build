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
        dnf clean packages
        ;;
    8*)
        yum-config-manager --enable powertools
        # Enable RPM Fusion repos to get libheif
        dnf install -y --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
        dnf clean packages
        ;;
    *)
        echo "Unsupported OS version: $VERSION_ID" && exit 1 ;;
esac
EOF

WORKDIR /build
COPY after-checkout-* /build/
COPY tests/entrypoint.sh /tests.sh

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
