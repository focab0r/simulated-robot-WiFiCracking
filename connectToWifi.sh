#!/bin/bash

echo "[*] Trying connection to $1..."

sleep 3
if [ $2 == "cookie123" ]; then
    echo "[+] Connected!"
    echo "[*] Network is 10.133.7.0/24"
else
    echo "[-] Unable to connect. Password incorrect"
fi
