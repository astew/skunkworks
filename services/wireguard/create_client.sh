#!/bin/bash

# Args:
#   - Output file
CLIENT_FILE=$1
#   - Client IP address
CLIENT_IP=$2
#   - DNS inner IP
DNS_INNER_PUB=$3
#   - DNS outer pub key
DNS_OUTER_PUB=$4
#   - LAN IP
LAN_IP=$5
#   - WAN IP
WAN_IP=$6

CLIENT_PRIV=$(wg genkey)
CLIENT_PUB=$(echo $CLIENT_PRIV | wg pubkey)


# Generate client configuration file
echo "
[Interface]
Address = $CLIENT_IP/31
PrivateKey = $CLIENT_PRIV
DNS = $WG_INNER_DNS,$WG_OUTER_DNS

[Peer]
PublicKey = $DNS_INNER_PUB
AllowedIPs = $WG_INNER_DNS/32
Endpoint= $LAN_IP:$WG_INNER_PORT

[Peer]
PublicKey = $DNS_OUTER_PUB
AllowedIPs = $WG_OUTER_DNS/32
Endpoint= $WAN_IP:$WG_OUTER_PORT
" > /etc/wireguard/$CLIENT_FILE


# Create QR code
qrencode -r /etc/wireguard/$CLIENT_FILE -o /etc/wireguard/$CLIENT_FILE.png


# Output: Client pub key
echo $CLIENT_PUB