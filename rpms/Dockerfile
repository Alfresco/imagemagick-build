ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN yum install -y epel-release git make yum-utils && \
    yum-config-manager --enable powertools && \
    yum install -y rpm-build && \
    yum group install -y "Development Tools" && \
    yum clean all

WORKDIR /build
COPY override-* /build/

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
