ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN yum install -y epel-release git make yum-utils rpm-build && \
    yum group install -y "Development Tools" && \
    yum clean all

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

WORKDIR /build
COPY after-checkout-* /build/

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
