FROM alpine:3.18

#切到国内镜像
RUN set -eux && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk add --no-cache tinyproxy iptables
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
EXPOSE 8888
ENTRYPOINT ["tinyproxy", "-d", "-c", "/etc/tinyproxy/tinyproxy.conf"]