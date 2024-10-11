#!/bin/bash

# Input DATA payload dari user
read -p "Enter the DATA payload (as JSON format): " DATA

# Ekstrak nilai owner dari JSON menggunakan regex
X_OWNER=$(echo "$DATA" | grep -oP '(?<="owner":")[^"]*')

# Periksa apakah X_OWNER berhasil diekstrak
if [ -z "$X_OWNER" ]; then
    echo "Error: Unable to extract owner value from the input."
    exit 1
else
    echo "Extracted X_OWNER: $X_OWNER"
fi

# URL dan Headers
URL="https://arcade.hub.soniclabs.com/rpc"
ACCEPT="*/*"
ACCEPT_LANGUAGE="en-US,en;q=0.9"
CONTENT_TYPE="application/json"
NETWORK="SONIC"
ORIGIN="https://arcade.soniclabs.com"
PRIORITY="u=1, i"
REFERER="https://arcade.soniclabs.com/"
SEC_CH_UA='"Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"'
SEC_CH_UA_MOBILE="?0"
SEC_CH_UA_PLATFORM='"Windows"'
SEC_FETCH_DEST="empty"
SEC_FETCH_MODE="cors"
SEC_FETCH_SITE="same-site"
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"

# Inisialisasi counter untuk perulangan
i=1

# Loop selamanya
while true; do
    echo "Request $i"

    # Eksekusi curl dan simpan respon dalam variabel
    RESPONSE=$(curl -s -X POST "$URL" \
      -H "accept: $ACCEPT" \
      -H "accept-language: $ACCEPT_LANGUAGE" \
      -H "content-type: $CONTENT_TYPE" \
      -H "network: $NETWORK" \
      -H "origin: $ORIGIN" \
      -H "priority: $PRIORITY" \
      -H "referer: $REFERER" \
      -H "sec-ch-ua: $SEC_CH_UA" \
      -H "sec-ch-ua-mobile: $SEC_CH_UA_MOBILE" \
      -H "sec-ch-ua-platform: $SEC_CH_UA_PLATFORM" \
      -H "sec-fetch-dest: $SEC_FETCH_DEST" \
      -H "sec-fetch-mode: $SEC_FETCH_MODE" \
      -H "sec-fetch-site: $SEC_FETCH_SITE" \
      -H "user-agent: $USER_AGENT" \
      -H "x-owner: $X_OWNER" \
      --data-raw "$DATA")

    # Validasi respon JSON untuk status success
    if echo "$RESPONSE" | grep -q '"hash":"'; then
        # Tampilkan pesan sukses dalam warna hijau
        echo -e "\e[32mSuccess request $i: $RESPONSE\e[0m"
    elif echo "$RESPONSE" | grep -q 'Daily play count limit exceeded'; then
        # Tampilkan pesan bahwa batas harian tercapai dan berhenti
        echo -e "\e[31mDaily play count limit exceeded. Stopping further requests.\e[0m"
        break
    else
        # Tampilkan pesan kesalahan dalam warna merah
        echo -e "\e[31mError request $i: $RESPONSE\e[0m"
    fi

    # Delay selama 8 detik sebelum request berikutnya
    sleep 8
    ((i++))
done
