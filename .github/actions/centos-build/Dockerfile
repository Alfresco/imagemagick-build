FROM centos:7

COPY entrypoint.sh  /entrypoint.sh
COPY override-7.0.10-59.sh /override-7.0.10-59.sh
COPY override-7.1.0-16.sh /override-7.1.0-16.sh
RUN chmod +x /override-7.0.10-59.sh 
RUN chmod +x /override-7.1.0-16.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
