ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN yum install -y epel-release

ADD *.rpm /

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
