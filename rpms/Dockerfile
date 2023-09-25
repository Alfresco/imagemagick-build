ARG BASE_IMAGE

FROM ${BASE_IMAGE} AS common

RUN yum install -y epel-release git make yum-utils rpm-build && \
    yum group install -y "Development Tools" && \
    yum clean all

FROM common AS final
ARG BASE_IMAGE

RUN if [ "$BASE_IMAGE" = "rockylinux:9" ]; then \
        dnf install -y dnf-plugins-core && \
        dnf config-manager --set-enabled crb; \
    else \
        yum-config-manager --enable powertools; \
    fi

WORKDIR /build
COPY after-checkout-* /build/

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
