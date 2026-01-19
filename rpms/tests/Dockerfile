ARG BASE_IMAGE=rockylinux/rockylinux:9

FROM ${BASE_IMAGE}

RUN <<EOF
yum update -y
yum install -y epel-release
source /etc/os-release
case "$VERSION_ID" in
    8*)
        # Enable RPM Fusion repos to get libheif
        dnf install -y --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
        ;;
    *)
        echo "No overrides for OS version: $VERSION_ID" && exit 0 ;;
esac
EOF

ADD *.rpm /

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
