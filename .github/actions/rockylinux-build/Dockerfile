FROM rockylinux:8

COPY entrypoint.sh /entrypoint.sh

COPY override-* /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
