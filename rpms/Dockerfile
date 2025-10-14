ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN yum install -y epel-release git make yum-utils rpm-build && \
    yum group install -y "Development Tools" && \
    yum clean all

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

RUN source /etc/os-release && \
    case "$VERSION_ID" in \
        9*) \
            dnf install -y dnf-plugins-core && \
            dnf config-manager --set-enabled crb && \
            yum clean all; \
            ;; \
        8*) \
            yum-config-manager --enable powertools && \
            # Enable RPM Fusion repos to get libheif
            dnf install -y --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm && \
            yum clean all; \
            ;; \
        *) \
            echo "Unsupported OS version: $VERSION_ID" && exit 1 ;; \
    esac

WORKDIR /build
COPY after-checkout-* /build/
COPY tests/entrypoint.sh /tests.sh

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
