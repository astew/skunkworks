FROM debian:latest

WORKDIR /etc/wireguard

# 'inner' - For when devices are connecting from within the same LAN
# 'outer' - For when device is out in the wild
#
# Having both of these:
#   - avoids problems when both ends behind NAT (typical for home users)
#   - keep traffic local when possible

## Names to be given to the wireguard tunnel interfaces
ENV WG_INNER  wg0
ENV WG_OUTER  wg1

## Port numbers used for WG
ENV WG_INNER_PORT 51821
ENV WG_OUTER_PORT 51822

## IP addresses for the inner and outer tunnels.
## These will also end up being the pihole DNS addresses
ENV WG_INNER_DNS  10.128.0.1
ENV WG_OUTER_DNS  10.128.0.2

## Client IP addresses
ENV WG_CLIENT1_IP 10.128.0.10
ENV WG_CLIENT2_IP 10.128.0.12

## Optional variables. If not defined, the container will attempt to discover 
## them automatically
# ENV LAN_IP XX.XX.XX.XX
# ENV WAN_IP XX.XX.XX.XX

RUN apt-get -y update 
RUN apt-get -y install wget wireguard-tools dnsutils qrencode miniupnpc iproute2

COPY run.sh /run.sh
COPY create_client.sh /create_client.sh

RUN chmod u+x /run.sh /create_client.sh

CMD [ "/run.sh" ]
