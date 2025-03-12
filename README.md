# L2TP VPN to HTTP Proxy in Docker

This project sets up a **Docker-based L2TP/IPSec VPN client** and exposes an **HTTP proxy** (via TinyProxy) for users to access the internet through the VPN.


---

### Build and Run
```sh
docker compose build
docker compose up -d
```

### Credits

Based on [r0hm1's l2tp-vpn-client](https://github.com/r0hm1/l2tp-vpn-client).
