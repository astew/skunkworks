#!/bin/bash
grep -qxF "100 ${WG_INNER}_table" /etc/iproute2/rt_tables || echo "100 ${WG_INNER}_table" >> /etc/iproute2/rt_tables
grep -qxF "200 ${WG_OUTER}_table" /etc/iproute2/rt_tables || echo "200 ${WG_OUTER}_table" >> /etc/iproute2/rt_tables

export LC_ALL=C

# if [ -z $ROUTER_IP ]; then
#   ROUTER_IP=$(ip r | grep default | cut -d " " -f 3)
# fi
# if [ -z $GATEWAY_IP ]; then
#   GATEWAY_IP=$(upnpc -l | grep "desc: http://$ROUTER_IP:[0-9]*/rootDesc.xml" | cut -d " " -f 3)
# fi
if [ -z $LAN_IP ]; then
  LAN_IP=$(upnpc -l | grep "Local LAN ip address" | cut -d: -f2)
fi
if [ -z $WAN_IP ]; then
  WAN_IP=$(dig +short txt ch whoami.cloudflare @1.0.0.1 | tr -d '"')
fi

WG_INNER_PRIV=$(wg genkey)
WG_OUTER_PRIV=$(wg genkey)

WG_INNER_PUB=$(echo $WG_INNER_PRIV | wg pubkey)
WG_OUTER_PUB=$(echo $WG_OUTER_PRIV | wg pubkey)

upnpc -a $LAN_IP $WG_OUTER_PORT $WG_OUTER_PORT UDP


# If there is no configuration file for the inner interface yet, create them
if [ ! -f /etc/wireguard/$WG_INNER.conf ]
then

  ## Note: The client configurations are for your PC or mobile device 
  ##       to connect to the VPN network

  # Generate client 1 configuration file
  CLIENT1_PUB=$(/create_client.sh client1.conf $WG_CLIENT1_IP  \
                  $WG_INNER_PUB $WG_OUTER_PUB $LAN_IP $WAN_IP)
                  
  # Generate client 2 configuration file
  CLIENT2_PUB=$(/create_client.sh client2.conf $WG_CLIENT2_IP  \
                  $WG_INNER_PUB $WG_OUTER_PUB $LAN_IP $WAN_IP)



  ## Generate the local device's wireguard configuration files
  echo "
  [Interface]
  Address = $WG_INNER_DNS/32
  ListenPort = $WG_INNER_PORT
  PrivateKey = $WG_INNER_PRIV
  Table = ${WG_INNER}_table
  PostUp = ip rule add from $WG_INNER_DNS table ${WG_INNER}_table prio 1 
  PostUp = ip rule add to $WG_INNER_DNS/24 table ${WG_INNER}_table prio 1
  PostDown = ip rule del from $WG_INNER_DNS
  PostDown = ip rule del to $WG_INNER_DNS/24

  [Peer]
  PublicKey = $CLIENT1_PUB
  AllowedIPs = $WG_CLIENT1_IP/32

  [Peer]
  PublicKey = $CLIENT2_PUB
  AllowedIPs = $WG_CLIENT2_IP/32
  " > /etc/wireguard/$WG_INNER.conf

  echo "WHAT THE MOTHER FUCK"

  echo "
  [Interface]
  Address = $WG_OUTER_DNS/32
  ListenPort = $WG_OUTER_PORT
  PrivateKey = $WG_OUTER_PRIV
  Table = ${WG_OUTER}_table
  PostUp = ip rule add from $WG_OUTER_DNS table ${WG_OUTER}_table prio 2
  PostUp = ip rule add to $WG_OUTER_DNS/24 table ${WG_OUTER}_table prio 2
  PostDown = ip rule del from $WG_OUTER_DNS
  PostDown = ip rule del to $WG_OUTER_DNS/24

  [Peer]
  PublicKey = $CLIENT1_PUB
  AllowedIPs = $WG_CLIENT1_IP/32

  [Peer]
  PublicKey = $CLIENT2_PUB
  AllowedIPs = $WG_CLIENT2_IP/32
  " > /etc/wireguard/$WG_OUTER.conf
fi


chmod 600 /etc/wireguard/$WG_INNER.conf
chmod 600 /etc/wireguard/$WG_OUTER.conf

ip rule del from $WG_OUTER_DNS 2>/dev/null
ip rule del from $WG_INNER_DNS 2>/dev/null
wg-quick down $WG_INNER 2>/dev/null
wg-quick down $WG_OUTER 2>/dev/null
ip rule del table ${WG_INNER}_table 2>/dev/null
ip rule del table ${WG_OUTER}_table 2>/dev/null
wg-quick up $WG_INNER
wg-quick up $WG_OUTER

# Keep container active
tail -f /dev/null
