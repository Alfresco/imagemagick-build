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
RUN apt-get install liblcms2-utils libfribidi0 libilmbase12 libdjvulibre21 librsvg2-2 libwmf0.2-7 libgomp1 liblqr-1-0 libltdl7 libopenexr22 libopenjp2-7 libraqm0 libraw16 libwebp6 libwebpdemux2 libwebpmux3 libzip4

ADD *.deb /

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
