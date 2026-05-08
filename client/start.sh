#!/bin/bash
set -e

echo "[CLIENT] Launching webcam..."
/bstreamer/bin/bserver -c /bstreamer/bin/server.yaml &

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
ip addr add 10.133.7.86/24 dev wlan1

echo "[CLIENT] Connecting to wifi-lab (WPA2)..."
wpa_supplicant -B -Dnl80211 -iwlan1 -c /etc/wpa_supplicant/wpa_supplicant.conf

echo "[CLIENT] Waiting for WPA2 association..."
for i in $(seq 1 30); do
    if wpa_cli -iwlan1 status 2>/dev/null | grep -q "wpa_state=COMPLETED"; then
        echo "[CLIENT] Associated with wifi-lab."
        break
    fi
    echo "[CLIENT] Waiting for association... ($i/30)"
    sleep 1
done

if ! wpa_cli -iwlan1 status 2>/dev/null | grep -q "wpa_state=COMPLETED"; then
    echo "[CLIENT] ERROR: Failed to associate with wifi-lab."
    exit 1
fi

echo "[CLIENT] Network ready:"
ip addr show wlan1

echo "[CLIENT] [+] Ready."

exec tail -f /dev/null
