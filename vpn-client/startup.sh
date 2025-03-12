#!/bin/sh

logMessage() {
    echo "[l2tp-vpn-client @$(date +'%F %T')] $1"
}

getLocationInfo() {
    local geoResponse=$(curl -s ipconfig.io/json)
    local currentIp=$(echo "$geoResponse" | awk -F'"' '/"ip":/{print $4}')
    local currentCountry=$(echo "$geoResponse" | awk -F'"' '/"country":/{print $4}')
    local currentCity=$(echo "$geoResponse" | awk -F'"' '/"city":/{print $4}')
    logMessage "Current IP address is $currentIp. Location is $currentCountry, $currentCity."
}

updateRoutingTable() {
    logMessage "Updating routing table"
    logMessage "Current routing table:"
    ip route
    echo ""
    ip addr
    echo ""
    
    # Network configuration variables
    local defaultDevice=$(ip route show to default | awk '/default/ {print $5}')
    local defaultGateway=$(ip route show to default | awk '{print $3}')
    local interfaceIp=$(ip addr show dev eth0 | awk '/inet / {print $2}')
    local networkCidr=$(ipcalc -n "$interfaceIp" | awk -F'=' '/NETWORK/ {print $2}')/${interfaceIp#*/}

    # Configure VPN routes
    ip route add "$VPN_SERVER_IPV4" via "$defaultGateway" dev "$defaultDevice" proto static metric 100
    ip route add "$networkCidr" via "$defaultGateway" dev "$defaultDevice" proto static metric 70
    
    # Add LAN route if specified
    [ -n "$LAN" ] && ip route add "$LAN" via "$defaultGateway" dev "$defaultDevice" proto static metric 70
    
    # Update default routing
    ip route add default dev ppp0 proto static scope link metric 50
    ip route del default via "$defaultGateway"
    ip route del "$networkCidr" dev "$defaultDevice"
    
    logMessage "Routing table updated"
    logMessage "New routing table:"
    ip route
    echo ""
    
    getLocationInfo
    logMessage "Routing configuration complete"
}

initializeVpnConnection() {
    logMessage "Configuring VPN settings"
    
    # Update VPN configuration files
    sed -i \
        -e "s/right=.*/right=$VPN_SERVER_IPV4/" /etc/ipsec.conf \
        -e "s/lns = .*/lns = $VPN_SERVER_IPV4/" /etc/xl2tpd/xl2tpd.conf \
        -e "s/name .*/name $VPN_USERNAME/" /etc/ppp/options.l2tpd.client \
        -e "s/password .*/password $VPN_PASSWORD/" /etc/ppp/options.l2tpd.client
    
    # Set IPSec pre-shared key
    echo ": PSK \"$VPN_PSK\"" > /etc/ipsec.secrets
    
    getLocationInfo
    
    # Initialize IPSec connection
    logMessage "Initializing IPSec connection"
    ipsec up L2TP-PSK
    sleep 3
    ipsec status L2TP-PSK
    
    logMessage "Starting VPN services"
    # Handle connection setup in background
    (
        sleep 5
        logMessage "Establishing PPP connection"
        echo "c myVPN" > /var/run/xl2tpd/l2tp-control
        sleep 5
        updateRoutingTable
    ) &
    
    logMessage "Starting L2TP daemon"
    exec /usr/sbin/xl2tpd \
        -p /var/run/xl2tpd.pid \
        -c /etc/xl2tpd/xl2tpd.conf \
        -C /var/run/xl2tpd/l2tp-control \
        -D
}

echo "------------------------------------- ------------------------------------- -------------------------------------"

# Main execution
initializeVpnConnection

# Keep container running for debugging
exec tail -f /dev/null