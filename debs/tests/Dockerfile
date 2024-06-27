ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/99yes
RUN apt-get update

ADD *.deb /

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
