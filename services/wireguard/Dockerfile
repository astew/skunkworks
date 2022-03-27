
FROM balenalib/aarch64-debian

WORKDIR /wireguard

RUN install_packages kmod wget wireguard-tools dnsutils qrencode miniupnpc

COPY run.sh /run.sh
COPY install.sh /install.sh

RUN chmod u+x /install.sh /run.sh
ENTRYPOINT [ "/install.sh" ]
CMD [ "/run.sh" ]