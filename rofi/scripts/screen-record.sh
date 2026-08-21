#!/bin/bash

DIR="$HOME/Videa"
STATE="/tmp/recording.pid"

# Optimalizované nastavení: dobrá kvalita + plynulost + menší soubory
# CRF 23 + veryfast + 30 fps = výrazně menší soubory při stále výborné kvalitě
VIDEO=(
  -c libx264
  -p crf=21
  -p preset=veryfast
  -p profile=high
  -x yuv420p
  -r 60
  -D
)

AUDIO=(
  -C aac
  -P b=192k
  -R 48000
)

# Waybar status
if [ "$1" = "--status" ]; then
  if [ -f "$STATE" ]; then
    PID=$(cat "$STATE")

    if kill -0 "$PID" 2>/dev/null; then
      echo '{"text":" ","tooltip":"Nahrávání probíhá. Super+Alt+R nahrávání zastaví."}'
      exit 0
    fi

    rm -f "$STATE"
  fi

  exit 0
fi

# Zastavení nahrávání
if [ -f "$STATE" ]; then
  PID=$(cat "$STATE")

  if kill -0 "$PID" 2>/dev/null; then
    kill -INT "$PID"
    killall mpv 2>/dev/null

    notify-send "Ukládám záznam..." "Probíhá zápis na disk."
    sleep 1.5

    rm -f "$STATE"

    notify-send "Hotovo" "Záznam je uložen."
    pkill -RTMIN+8 waybar
    exit 0
  fi

  rm -f "$STATE"
fi

# Výběr režimu
MODE=$(printf '%s\n' \
  "  Pouze mikrofon" \
  "  Pouze obrazovka" \
  "  Mikrofon + Obrazovka" \
  "  Mikrofon + Obrazovka + Kamera" |
  rofi -dmenu -i -p "Nahrávání:" -lines 5)

[ -z "$MODE" ] && exit 0

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

case "$MODE" in
"  Pouze mikrofon")
  FILE="$DIR/zaznam_mikrofon_$TIMESTAMP.mp3"

  # Záznam přímo do MP3 ve vysoké kvalitě pomocí ffmpeg
  ffmpeg \
    -f pulse -i default \
    -c:a libmp3lame -b:a 192k \
    "$FILE" 2>/dev/null &

  PID=$!
  ;;

"  Pouze obrazovka")
  FILE="$DIR/zaznam_obraz_$TIMESTAMP.mkv"

  wf-recorder \
    "${VIDEO[@]}" \
    -f "$FILE" &

  PID=$!
  ;;

"  Mikrofon + Obrazovka")
  FILE="$DIR/zaznam_obraz_zvuk_$TIMESTAMP.mkv"

  wf-recorder \
    "${VIDEO[@]}" \
    "${AUDIO[@]}" \
    -a \
    -f "$FILE" &

  PID=$!
  ;;

"  Mikrofon + Obrazovka + Kamera")
  FILE="$DIR/zaznam_komplet_$TIMESTAMP.mkv"

  mpv \
    --no-config \
    --no-osc \
    --no-input-default-bindings \
    --profile=low-latency \
    --untimed \
    --title=webcam \
    /dev/video0 &

  sleep 1.5
  mmsg dispatch toggleglobal

  wf-recorder \
    "${VIDEO[@]}" \
    "${AUDIO[@]}" \
    -a \
    -f "$FILE" &

  PID=$!
  ;;
esac

sleep 0.3

if ! kill -0 "$PID" 2>/dev/null; then
  killall mpv 2>/dev/null

  notify-send -u critical \
    "Nahrávání se nepodařilo spustit" \
    "Proces se ukončil."

  exit 1
fi

printf '%s\n' "$PID" >"$STATE"

pkill -RTMIN+8 waybar
