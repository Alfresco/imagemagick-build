ARG IMAGE_TAG
FROM ubuntu:$IMAGE_TAG

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/99yes
RUN apt-get update

ADD *.deb /

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
