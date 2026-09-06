#!/bin/bash

ACTION=$1
FILE=~/Obrázky/Screenshot_$(date +"%Y%m%d_%H%M%S").png

case $ACTION in
full)
  # 1. Zkratka: Celá obrazovka
  grim "$FILE"
  wl-copy <"$FILE"
  notify-send -i "$FILE" "Screenshot" "Uloženo do Obrázků a schránky"
  ;;

area)
  # 2. Zkratka: Výřez + QR detekce
  GEOMETRY=$(slurp)
  [ -z "$GEOMETRY" ] && exit 1

  grim -g "$GEOMETRY" "$FILE"

  # Pokus o vytažení QR kódu
  QR_TEXT=$(zbarimg --quiet --raw "$FILE" 2>/dev/null)

  if [ -n "$QR_TEXT" ]; then
    # QR kód byl nalezen
    printf "%s" "$QR_TEXT" | wl-copy
    notify-send "QR kód rozpoznán" "Text zkopírován do schránky:\n$QR_TEXT"

    # Smaže obrázek s QR kódem
    rm "$FILE"
  else
    # Běžný výřez (QR nenalezen)
    wl-copy <"$FILE"
    notify-send -i "$FILE" "Výřez" "Uloženo do Obrázků a schránky"
  fi
  ;;

text)
  # 3. Zkratka: OCR výběr textu + QR (bez otevírání)
  GEOMETRY=$(slurp)
  [ -z "$GEOMETRY" ] && exit 1

  # Dočasný soubor (nemusí se ukládat do Obrázků)
  TMP=$(mktemp /tmp/ocr-XXXXXX.png)
  grim -g "$GEOMETRY" "$TMP"

  # 1. Nejdřív zkus QR
  QR_TEXT=$(zbarimg --quiet --raw "$TMP" 2>/dev/null)

  if [ -n "$QR_TEXT" ]; then
    printf "%s" "$QR_TEXT" | wl-copy
    notify-send "QR kód rozpoznán" "Text zkopírován do schránky:\n$QR_TEXT"
  else
    # 2. OCR (čeština + angličtina)
    # Pokud nemáš tesseract-data-ces, změň na -l eng
    TEXT=$(tesseract "$TMP" stdout -l ces+eng --psm 6 2>/dev/null | sed '/^\s*$/d')

    if [ -n "$TEXT" ]; then
      printf "%s" "$TEXT" | wl-copy
      # Zkrácená notifikace (max ~80 znaků)
      PREVIEW=$(echo "$TEXT" | head -c 80)
      [ ${#TEXT} -gt 80 ] && PREVIEW="${PREVIEW}…"
      notify-send "OCR hotovo" "Text zkopírován:\n$PREVIEW"
    else
      notify-send "OCR" "Žádný text nebyl rozpoznán"
    fi
  fi

  rm -f "$TMP"
  ;;

*)
  echo "Chyba: Použij parametr {full|area|text}"
  exit 1
  ;;
esac
