#!/bin/sh
if echo "$VPN_SERVER_IPV4" | grep -q '[A-Za-z]'; then
  echo "Resolving VPN server hostname: $VPN_SERVER_IPV4..."
  resolved_ip=$(getent hosts "$VPN_SERVER_IPV4" | awk '{print $1}' | head -n 1)
  if [ -z "$resolved_ip" ]; then
    echo "Error: Unable to resolve hostname $VPN_SERVER_IPV4" >&2
    exit 1
  fi
  echo "Resolved IP: $resolved_ip"
  export VPN_SERVER_IPV4="$resolved_ip"
fi

exec /etc/startup.sh "$@"