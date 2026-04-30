#!/bin/bash
set -e

echo "[AP] Loading mac80211_hwsim kernel module (3 radios: wlan0=AP, wlan1=client, wlan2=attacker)..."
# Load with 3 radios so the host/attacker also gets wlan2
modprobe mac80211_hwsim radios=3

# Give the kernel a moment to create the interfaces
sleep 1

echo "[AP] Available interfaces:"
iw dev

echo "[AP] Bringing up wlan0..."
ip link set wlan0 up

echo "[AP] Starting hostapd (WPA2 AP on wlan0, SSID: wifi-old)..."
exec hostapd /etc/hostapd/hostapd.conf
