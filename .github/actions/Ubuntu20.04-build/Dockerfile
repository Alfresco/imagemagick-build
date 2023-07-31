FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical
ENV DEBCONF_NOWARNINGS=yes
ENV LOGNAME root

RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/99yes

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
