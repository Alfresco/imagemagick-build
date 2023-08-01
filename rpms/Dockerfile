ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN dnf install -y epel-release git make wget 'dnf-command(config-manager)' && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y rpm-build yum-utils && \
    dnf group install -y "Development Tools" && \
    dnf clean all

WORKDIR /build
COPY override-* /build/

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
