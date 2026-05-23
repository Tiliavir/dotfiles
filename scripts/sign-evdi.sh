#!/usr/bin/env bash

set -euo pipefail

MODDIR="/lib/modules/$(uname -r)/updates/dkms"
KEY_PRIV="/root/mok/MOK.priv"
KEY_DER="/root/mok/MOK.der"

if [[ $EUID -ne 0 ]]; then
    echo "Bitte mit sudo ausführen."
    exit 1
fi

# --- Find module (compressed or not) ---
MOD_ZST="${MODDIR}/evdi.ko.zst"
MOD_KO="${MODDIR}/evdi.ko"

if [[ ! -f "$MOD_ZST" && ! -f "$MOD_KO" ]]; then
    echo ">>> Modul fehlt – starte DKMS-Build …"
    EVDI_VER=$(dkms status evdi | awk -F'[,/]' '{print $2}' | tr -d ' ' | head -1)
    if [[ -z "$EVDI_VER" ]]; then
        echo "Fehler: evdi nicht in DKMS registriert. Bitte 'apt install evdi-dkms' ausführen."
        exit 1
    fi
    dkms build evdi/"$EVDI_VER" -k "$(uname -r)" --force
    dkms install evdi/"$EVDI_VER" -k "$(uname -r)" --force
fi

# Detect which format is present
if [[ -f "$MOD_ZST" ]]; then
    echo ">>> Komprimiertes Modul gefunden (.zst)"
    COMPRESSED=1
    echo ">>> Entpacke evdi.ko.zst …"
    zstd -d "$MOD_ZST" -o "$MOD_KO"
else
    echo ">>> Unkomprimiertes Modul gefunden (.ko)"
    COMPRESSED=0
fi

if [[ ! -f "$KEY_PRIV" || ! -f "$KEY_DER" ]]; then
    echo "Fehler: Schlüssel fehlen in /root/mok"
    exit 1
fi

echo ">>> Signiere Modul …"
/usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 \
    "$KEY_PRIV" \
    "$KEY_DER" \
    "$MOD_KO"

if [[ $COMPRESSED -eq 1 ]]; then
    echo ">>> Komprimiere Modul wieder …"
    zstd -f "$MOD_KO" -o "$MOD_ZST"
    echo ">>> Entferne unkomprimierte Version …"
    rm -f "$MOD_KO"
fi

echo ">>> Erzeuge Modul-Cache neu …"
depmod -a

echo ">>> Teste Laden …"
if modprobe evdi 2>/tmp/evdi_err; then
    echo ">>> evdi erfolgreich geladen."
else
    echo ">>> Fehler beim Laden von evdi:"
    cat /tmp/evdi_err
fi

echo ">>> Signaturprüfung:"
modinfo evdi | grep -E "signer|sig_key" || echo "Keine Signatur gefunden!"

echo ">>> Fertig."

