FROM alpine:latest
MAINTAINER aligator

RUN apk add --no-cache --update-cache openssh && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key* && \
    mkdir /etc/ssh/authorized_keys && \
    mkdir /ssh-home
    
COPY sshd_config /etc/ssh/sshd_config
COPY ./run.sh /usr/local/bin/run.sh

RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]


