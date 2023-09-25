ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN yum install -y epel-release git make yum-utils && \
    if [ "$BASE_IMAGE" = "rockylinux:9" ]; then \
        dnf config-manager --enable crb; \
    else \
        yum-config-manager --enable powertools; \
    fi && \
    yum install -y rpm-build && \
    yum group install -y "Development Tools" && \
    yum clean all

WORKDIR /build
COPY after-checkout-* /build/

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
