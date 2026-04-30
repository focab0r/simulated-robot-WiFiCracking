#!/bin/bash
set -e

echo "[CLIENT] Waiting for wlan1 to appear (AP must start first)..."
for i in $(seq 1 20); do
    if iw dev | grep -q wlan1; then
        echo "[CLIENT] wlan1 found."
        break
    fi
    echo "[CLIENT] Waiting... ($i/20)"
    sleep 2
done

if ! iw dev | grep -q wlan1; then
    echo "[CLIENT] ERROR: wlan1 not found. Is the AP container running and mac80211_hwsim loaded?"
    exit 1
fi

echo "[CLIENT] Bringing up wlan1..."
ip link set wlan1 up

echo "[CLIENT] Connecting to wifi-old (WEP)..."
exec wpa_supplicant -Dnl80211 -iwlan1 -c /etc/wpa_supplicant/wpa_supplicant.conf
