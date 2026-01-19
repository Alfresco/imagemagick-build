ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical
ENV DEBCONF_NOWARNINGS=yes
ENV LOGNAME=root

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/99yes
RUN <<EOF
apt-get update
apt-get install build-essential git dpkg-dev devscripts equivs
EOF

WORKDIR /build

ADD debian/ /build/debian
ADD after-checkout-*.sh /build/

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
