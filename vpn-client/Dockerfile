FROM r0hm1/l2tp-vpn-client:latest
COPY vpn-entrypoint.sh /vpn-entrypoint.sh
RUN chmod +x /vpn-entrypoint.sh
ENTRYPOINT ["/vpn-entrypoint.sh"]
