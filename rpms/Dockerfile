ARG BASE_IMAGE
ARG TARGET

FROM ${BASE_IMAGE} as dnf

RUN dnf install -y epel-release git make wget 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y rpm-build yum-utils && \
    dnf group install -y "Development Tools" && \
    dnf clean all

FROM ${BASE_IMAGE} as yum

RUN yum install -y epel-release git make && \
    yum-config-manager --enable powertools && \
    yum install -y rpm-build yum-utils && \
    yum group install -y "Development Tools" && \
    yum clean all

FROM ${TARGET}

WORKDIR /build
COPY override-* /build/

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
