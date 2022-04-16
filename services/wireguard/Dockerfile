FROM debian:buster

WORKDIR /wireguard

RUN install_packages wget wireguard-tools dnsutils qrencode miniupnpc

COPY run.sh /run.sh
COPY install.sh /install.sh

RUN chmod u+x /install.sh /run.sh
ENTRYPOINT [ "/install.sh" ]
CMD [ "/run.sh" ]
