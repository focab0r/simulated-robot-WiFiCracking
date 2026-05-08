FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    hostapd \
    dnsmasq \
    iproute2 \
    iw \
    kmod \
    && rm -rf /var/lib/apt/lists/*

COPY hostapd.conf /etc/hostapd/hostapd.conf
COPY dnsmasq.conf /etc/dnsmasq.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]