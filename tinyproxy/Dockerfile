FROM alpine:3.18
RUN apk add --no-cache tinyproxy iptables
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
EXPOSE 8888
ENTRYPOINT ["tinyproxy", "-d", "-c", "/etc/tinyproxy/tinyproxy.conf"]