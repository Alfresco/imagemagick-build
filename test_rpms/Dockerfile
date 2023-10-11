ARG BASE_IMAGE

FROM ${BASE_IMAGE}

RUN yum install -y epel-release

ADD *.rpm /

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
