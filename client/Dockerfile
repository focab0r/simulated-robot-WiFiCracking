FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wpasupplicant \
    isc-dhcp-client \
    iproute2 \
    net-tools \
    iputils-ping \
    iw \
    kmod \
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

COPY wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
COPY start.sh /start.sh

COPY bstreamer /bstreamer

RUN chmod +x /start.sh

CMD ["/start.sh"]
