FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    wget \
    iproute2 \
    net-tools \
    iputils-ping \
    iw \
    kmod \
    && rm -rf /var/lib/apt/lists/*

# Build hostapd from source with WEP enabled
# Stock packages since 2.10 ship WITHOUT CONFIG_WEP
WORKDIR /build
RUN wget -q https://w1.fi/releases/hostapd-2.10.tar.gz && \
    tar xzf hostapd-2.10.tar.gz && \
    cd hostapd-2.10/hostapd && \
    cp defconfig .config && \
    echo "CONFIG_WEP=y" >> .config && \
    echo "CONFIG_DRIVER_NL80211=y" >> .config && \
    make -j$(nproc) && \
    make install && \
    which hostapd

COPY hostapd.conf /etc/hostapd/hostapd.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
