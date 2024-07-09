ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN yum install -y epel-release git make yum-utils rpm-build && \
    yum group install -y "Development Tools" && \
    yum clean all

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

RUN if [ "$BASE_IMAGE" = "rockylinux:9" ]; then \
        dnf install -y dnf-plugins-core && \
        dnf config-manager --set-enabled crb && \
        yum clean all; \
    else \
        yum-config-manager --enable powertools && \
        yum clean all; \
    fi

WORKDIR /build
COPY after-checkout-* /build/
COPY tests/entrypoint.sh /tests.sh

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
