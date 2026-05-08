#!/bin/bash
set -e

_cleaned=0
cleanup() {
    [ "$_cleaned" = "1" ] && return
    _cleaned=1
    echo "[AP] Shutting down..."
    [ -n "$HOSTAPD_PID" ] && kill "$HOSTAPD_PID" 2>/dev/null; wait "$HOSTAPD_PID" 2>/dev/null || true
    modprobe -r mac80211_hwsim 2>/dev/null \
        && echo "[AP] mac80211_hwsim unloaded — virtual interfaces removed." \
        || echo "[AP] Warning: could not unload mac80211_hwsim (may still be in use)."
}

trap cleanup EXIT SIGTERM SIGINT

echo "[AP] Loading mac80211_hwsim kernel module (3 radios: wlan0=AP, wlan1=client, wlan2=attacker)..."
modprobe mac80211_hwsim radios=3
sleep 1

echo "[AP] Available interfaces:"
iw dev

echo "[AP] Bringing up wlan0..."
ip link set wlan0 up
ip addr add 10.133.7.1/24 dev wlan0

echo "[AP] Starting hostapd (WPA2 AP on wlan0, SSID: wifi-lab)..."
hostapd /etc/hostapd/hostapd.conf &
HOSTAPD_PID=$!

wait "$HOSTAPD_PID"
