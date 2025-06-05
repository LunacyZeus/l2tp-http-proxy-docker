FROM alpine:3.18


#切到国内镜像
RUN set -eux && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN set -x \
    && apk add --no-cache \
        strongswan \
        xl2tpd \
        curl \
        grep \
        tzdata \
    && mkdir -p /var/run/xl2tpd \
    && touch /var/run/xl2tpd/l2tp-control

# Copy config files for l2tp
COPY ipsec.conf /etc/ipsec.conf
COPY ipsec.secrets /etc/ipsec.secrets
COPY xl2tpd.conf /etc/xl2tpd/xl2tpd.conf
COPY options.l2tpd.client /etc/ppp/options.l2tpd.client

# Copy scripts
COPY startup.sh /etc/
COPY vpn-entrypoint.sh /vpn-entrypoint.sh
RUN chmod +x /vpn-entrypoint.sh /etc/startup.sh

WORKDIR /home

ENTRYPOINT ["/vpn-entrypoint.sh"]
