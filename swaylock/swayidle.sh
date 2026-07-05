#!/bin/bash

swayidle -w \
  timeout 150 'brightnessctl -sd rgb:kbd_backlight set 0' \
  resume 'brightnessctl -rd rgb:kbd_backlight' \
  timeout 300 'brightnessctl -s set 10' \
  resume 'brightnessctl -r' \
  timeout 900 'swaylock -f -c 000000' \
  before-sleep 'swaylock -f -c 000000'
