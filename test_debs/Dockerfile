ARG IMAGE_TAG
FROM ubuntu:$IMAGE_TAG

ARG IMAGE_TAG
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical
ENV DEBCONF_NOWARNINGS=yes
ENV IMAGE_TAG=$IMAGE_TAG
ENV LOGNAME=root

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/99yes
RUN apt-get update

ADD *.deb /

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
