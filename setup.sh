#!/bin/bash

# Vytvoření prázdného pole pro logování chyb[cite: 1]
declare -a ERROR_LOG

# Chytrá funkce pro opakování a logování[cite: 1]
retry() {
  if "$@"; then
    return 0
  else
    echo -e "\e[33m⚠️ Příkaz selhal. Za 2 sekundy zkusím znovu: $*\e[0m"
    sleep 2
    if "$@"; then
      echo -e "\e[32m✅ Druhý pokus byl úspěšný.\e[0m"
      return 0
    else
      echo -e "\e[31m❌ Příkaz selhal i napodruhé. Přeskakuji a zapisuji do logu...\e[0m"
      ERROR_LOG+=("$*")
      return 0
    fi
  fi
}

# --- AUTOMATICKÉ OBALENÍ PŘÍKAZŮ ---[cite: 1]
sudo() { retry command sudo "$@"; }
yay() { retry command yay "$@"; }
git() { retry command git "$@"; }
ya() { retry command ya "$@"; }
sh() { retry command sh "$@"; }
# -----------------------------------

sudo pacman -S base-devel --noconfirm

# yay install[cite: 1]
git clone https://aur.archlinux.org/yay.git ~/.config/yay
# Pokud se cd nepovede, rovnou zapíše chybu do logu
cd ~/.config/yay || ERROR_LOG+=("Nepodařilo se přejít do složky ~/.config/yay")
retry command makepkg -si --noconfirm
cd || true

# update system[cite: 1]
sudo pacman -Syu --noconfirm

# chaotic AUR[cite: 1]
if [[ "$(uname -m)" == "x86_64" ]] && [ -z "$DISABLE_CHAOTIC" ]; then
  if ! pacman-key --list-keys 3056513887B78AEB >/dev/null 2>&1 &&
    sudo pacman-key --recv-key 3056513887B78AEB &&
    sudo pacman-key --lsign-key 3056513887B78AEB &&
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' &&
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then

    if ! grep -q "chaotic-aur" /etc/pacman.conf; then
      echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf >/dev/null
    fi
  else
    # V případě selhání bloku přidáme jasnou hlášku do logu
    echo -e "Failed to install Chaotic-AUR, so won't include it in pacman config!"
    ERROR_LOG+=("Instalace Chaotic-AUR selhala.")
  fi
fi

# sed stuff[cite: 1]
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sudo sed -i 's/#AutoEnable=true/AutoEnable=false/' /etc/bluetooth/main.conf
sudo pacman -Syu --noconfirm

# basic files - Explicitní hlídání přes retry
retry command mkdir -p ~/.local/bin/
retry command mv ~/.config/Obrázky .
retry command mv ~/.config/bashrc ~/.bashrc
retry command mv ~/.config/rofi-power-menu ~/.local/bin
retry command mv ~/.config/themes ~/.themes
retry command mv ~/.config/icons ~/.icons

# --- INSTALACE PROGRAMŮ PO JEDNOM PRO PŘESNÉ LOGOVÁNÍ ---
PACKAGES=(
  adobe-source-han-sans-cn-fonts
  adobe-source-han-sans-jp-fonts
  adobe-source-han-sans-kr-fonts
  adwaita-fonts
  atool
  awww
  aerc
  bat
  cyrus-sasl-xoauth2-git
  bash-completion
  bluetui
  breeze
  brightnessctl
  calcurse
  caligula
  cantarell-fonts
  clamav
  clipse
  clipse-gui
  cronie
  cups
  downgrade
  dysk
  edk2-shell
  fastfetch
  firefox
  fzf
  gdu
  gparted
  grim
  gst-plugins-good
  gvfs
  htop
  imagemagick
  kitty
  libreoffice-still
  libreoffice-still-cs
  limine-mkinitcpio-hook
  lxqt-policykit
  lynx
  mako
  man-db
  mangowm
  mediainfo
  mpv
  mpv-mpris
  ncspot
  neovim
  newsboat
  noto-fonts-emoji
  ntfs-3g
  nwg-look
  ouch
  paccache-hook
  perl-image-exiftool
  pulsemixer
  python-ffsubsync
  python-pipx
  qimgv-git
  qt5-wayland
  qt5ct
  qt6-wayland
  qt6ct
  reflector
  rofi
  rofi-calc-git
  simple-mtpfs
  slurp
  smartmontools
  subliminal-git
  swaylock-effects
  swayidle
  system-config-printer
  timeshift
  telegram-desktop
  tlp
  starship
  tlpui
  topgrade
  trash-cli
  tree
  ttf-jetbrains-mono-nerd
  ttf-meslo-nerd
  ttf-ms-win11-auto
  ttf-roboto
  udiskie
  ufw
  unrar
  unzip
  uwsm
  veracrypt
  waybar
  waypaper-git
  wev
  wf-recorder
  wl-clipboard
  wlsunset
  wlopm
  woff2-font-awesome
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  xdg-user-dirs
  xorg-xhost
  wlr-randr
  yazi
  ydotool
  yt-dlp
  zathura
  zathura-cb
  zathura-pdf-mupdf
  zip
  zoxide
)

for pkg in "${PACKAGES[@]}"; do
  # Funkce 'yay' z úvodu zajistí opakování i zalogování konkrétního selhavšího balíčku
  yay -S "$pkg" --noconfirm
done

# omarchy-send[cite: 1]
sh -c "curl -fsSL https://raw.githubusercontent.com/28allday/omarchy-send/main/install.sh | bash"

# services[cite: 1]
sudo systemctl enable tlp
sudo systemctl enable ufw
sudo ufw enable
sudo systemctl enable cronie
sudo systemctl enable reflector.timer
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
sudo cp /usr/share/edk2-shell/x64/Shell.efi /boot/shellx64.efi

# Mail automatizace[cite: 1]
echo "Instaluji a aktivuji cronie..."
sudo pacman -S --noconfirm cronie
sudo systemctl enable --now cronie.service

CRON_JOB="*/5 * * * * /usr/bin/mbsync -a && /usr/bin/notmuch new"

echo "Nastavuji automatickou synchronizaci e-mailů..."
if ! crontab -l 2>/dev/null | grep -qF "$CRON_JOB"; then
  (
    crontab -l 2>/dev/null
    echo "$CRON_JOB"
  ) | crontab -
  echo "Úloha pro mbsync a notmuch úspěšně přidána."
else
  echo "Úloha už v crontabu existuje, přeskakuji."
fi

# složky[cite: 1]
sudo mkdir -p /mnt/Disk2
sudo chown "$USER:$USER" /mnt/Disk2

# --- ZÁVĚREČNÉ SHRNUTÍ CHYB ---[cite: 1]
echo -e "\n=================================================="
if [ ${#ERROR_LOG[@]} -eq 0 ]; then
  echo -e "\e[32m🎉 Skript byl kompletně dokončen bez jediného erroru!\e[0m"
else
  echo -e "\e[31m⚠️ Skript byl dokončen, ale následující akce (či instalace) selhaly:\e[0m"
  for err in "${ERROR_LOG[@]}"; do
    echo -e " - \e[33m$err\e[0m"
  done
fi
echo "=================================================="
