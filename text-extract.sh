#!/bin/bash

# Získá souřadnice z myši
GEOMETRY=$(slurp)

# 1. Kontrola zrušení: Pokud stiskneš Esc, skript se tiše ukončí a nic se neděje
if [ -z "$GEOMETRY" ]; then
  exit 0
fi

# 2. Extrémní efektivita: Zpracování probíhá čistě v paměti RAM (žádné ukládání do /tmp).
# grim pošle raw data do roury (-) a tesseract si je přečte ze stdin (-) a vypíše na stdout (-).
TEXT=$(grim -g "$GEOMETRY" - | tesseract - - -l ces)

# Odstranění přebytečných bílých znaků a kontrola
CLEAN_TEXT=$(echo "$TEXT" | xargs)

# 3. Spolehlivost: Pokud Tesseract nic nepřečte, nepřemaže ti to aktuální schránku prázdnem
if [ -n "$CLEAN_TEXT" ]; then
  # Vloží původní (neformátovaný) text do schránky
  echo "$TEXT" | wl-copy
  notify-send "OCR Dokončeno" "Text byl zkopírován do schránky."
else
  notify-send -u critical "OCR Selhalo" "Nepodařilo se rozpoznat žádný text."
fi
