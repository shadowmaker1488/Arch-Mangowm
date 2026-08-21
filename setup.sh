#!/bin/bash

# ============================================================
# Arch Linux post-install setup (přepsaná a rozdělená verze)
# ============================================================

set -euo pipefail # lepší bezpečnost (můžeš vypnout, pokud chceš maximální toleranci)

declare -a ERROR_LOG=()

# --- Retry funkce ---
retry() {
  if "$@"; then
    return 0
  else
    echo -e "\e[33m⚠️  Příkaz selhal. Za 2 s zkusím znovu: $*\e[0m"
    sleep 2
    if "$@"; then
      echo -e "\e[32m✅ Druhý pokus úspěšný.\e[0m"
      return 0
    else
      echo -e "\e[31m❌ Selhalo i napodruhé. Zapisuji do logu a pokračuji...\e[0m"
      ERROR_LOG+=("$*")
      return 0
    fi
  fi
}

# Automatické obalení
sudo() { retry command sudo "$@"; }
yay() { retry command yay "$@"; }
git() { retry command git "$@"; }

# ============================================================
# 1. Základní příprava
# ============================================================
echo -e "\n>>> 1. Instalace base-devel a yay"

sudo pacman -S --needed base-devel --noconfirm

if [[ ! -d ~/.config/yay ]]; then
  git clone https://aur.archlinux.org/yay.git ~/.config/yay
fi
cd ~/.config/yay
makepkg -si --noconfirm
cd ~

# ============================================================
# 2. Systémový update + Chaotic-AUR
# ============================================================
echo -e "\n>>> 2. Systémový update a Chaotic-AUR"

sudo pacman -Syu --noconfirm

if [[ "$(uname -m)" == "x86_64" ]] && [[ -z "${DISABLE_CHAOTIC:-}" ]]; then
  if ! pacman-key --list-keys 3056513887B78AEB &>/dev/null; then
    sudo pacman-key --recv-key 3056513887B78AEB
    sudo pacman-key --lsign-key 3056513887B78AEB
    sudo pacman -U --noconfirm \
      'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
      'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  fi

  if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
    echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf >/dev/null
  fi
fi

# ============================================================
# 3. Úpravy konfigurace
# ============================================================
echo -e "\n>>> 3. Úpravy pacman.conf a bluetooth"

sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf

if [[ -f /etc/bluetooth/main.conf ]]; then
  sudo sed -i 's/#AutoEnable=true/AutoEnable=false/' /etc/bluetooth/main.conf
fi

sudo pacman -Syu --noconfirm

# ============================================================
# 4. Přesun konfiguračních souborů (s kontrolou existence)
# ============================================================
echo -e "\n>>> 4. Přesun dotfiles"

mkdir -p ~/.local/bin ~/.themes ~/.icons

[[ -d ~/.config/Obrázky ]] && mv ~/.config/Obrázky ~
[[ -f ~/.config/bashrc ]] && mv ~/.config/bashrc ~/.bashrc
[[ -f ~/.config/bash_profile ]] && mv ~/.config/bash_profile ~/.bash_profile
[[ -f ~/.config/rofi-power-menu ]] && mv ~/.config/rofi-power-menu ~/.local/bin/
[[ -f ~/.config/text-extract.sh ]] && mv ~/.config/text-extract.sh ~/.local/bin/
[[ -d ~/.config/themes ]] && mv ~/.config/themes ~/.themes
[[ -d ~/.config/icons ]] && mv ~/.config/icons ~/.icons

# ============================================================
# 5. Instalace balíčků – logické skupiny
# ============================================================

echo -e "\n>>> 5.1 Fonty"
yay -S --needed --noconfirm \
  adobe-source-han-sans-cn-fonts \
  adobe-source-han-sans-jp-fonts \
  adobe-source-han-sans-kr-fonts \
  adwaita-fonts \
  cantarell-fonts \
  noto-fonts-emoji \
  ttf-jetbrains-mono-nerd \
  ttf-meslo-nerd \
  ttf-roboto \
  woff2-font-awesome

echo -e "\n>>> 5.2 CLI nástroje a utility"
yay -S --needed --noconfirm \
  aerc \
  atool \
  bash-completion \
  bat \
  bluetui \
  brightnessctl \
  calcurse \
  caligula \
  clipse \
  clipse-gui \
  cronie \
  dysk \
  eza \
  fastfetch \
  fzf \
  gdu \
  htop \
  lynx \
  man-db \
  mediainfo \
  newsboat \
  ouch \
  perl-image-exiftool \
  pulsemixer \
  starship \
  topgrade \
  trash-cli \
  tree \
  yazi \
  zoxide

echo -e "\n>>> 5.3 Wayland / Desktop / Mango ekosystém"
yay -S --needed --noconfirm \
  awww \
  grim \
  hyprpicker \
  kitty \
  mako \
  mangowm \
  nwg-look \
  rofi \
  rofi-calc \
  rofi-emoji \
  slurp \
  swayidle \
  swaylock-effects \
  waybar \
  waypaper-git \
  wev \
  wf-recorder \
  wl-clipboard \
  wlopm \
  wlr-randr \
  wlsunset \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-wlr \
  ydotool

echo -e "\n>>> 5.4 Multimédia"
yay -S --needed --noconfirm \
  gst-plugins-good \
  imagemagick \
  mpv \
  mpv-mpris \
  python-ffsubsync \
  qimgv-git \
  songrec \
  subliminal-git \
  yt-dlp \
  zathura \
  zathura-cb \
  zathura-pdf-mupdf

echo -e "\n>>> 5.5 Kancelář a komunikace"
yay -S --needed --noconfirm \
  firefox \
  libreoffice-still \
  libreoffice-still-cs \
  telegram-desktop \
  spotify-player

echo -e "\n>>> 5.6 Systémové nástroje a hardware"
yay -S --needed --noconfirm \
  clamav \
  cups \
  cyrus-sasl-xoauth2-git \
  downgrade \
  edk2-shell \
  gparted \
  gvfs \
  limine-mkinitcpio-hook \
  lxqt-policykit \
  ntfs-3g \
  paccache-hook \
  python-pipx \
  qt5-wayland \
  qt5ct \
  qt6-wayland \
  qt6ct \
  reflector \
  simple-mtpfs \
  smartmontools \
  system-config-printer \
  timeshift \
  tlp \
  tlpui \
  udiskie \
  unrar \
  unzip \
  uwsm \
  veracrypt \
  xdg-user-dirs \
  xorg-xhost \
  zip \
  neovim \
  tesseract-data-ces

# ============================================================
# 6. Služby a systémové nastavení
# ============================================================
echo -e "\n>>> 6. Povolení služeb"

sudo systemctl enable tlp
sudo systemctl enable cronie
sudo systemctl enable reflector.timer
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

if [[ -f /usr/share/edk2-shell/x64/Shell.efi ]]; then
  sudo cp /usr/share/edk2-shell/x64/Shell.efi /boot/shellx64.efi
fi

# ============================================================
# 7. Omarchy-send (bezpečnější varianta)
# ============================================================
echo -e "\n>>> 7. Instalace omarchy-send"

# Doporučuji si skript nejdřív stáhnout a prohlédnout:
# curl -fsSL https://raw.githubusercontent.com/28allday/omarchy-send/main/install.sh -o /tmp/omarchy-install.sh
# less /tmp/omarchy-install.sh
# bash /tmp/omarchy-install.sh

# Pokud chceš automaticky (na vlastní nebezpečí):
sh -c "curl -fsSL https://raw.githubusercontent.com/28allday/omarchy-send/main/install.sh | bash"

# ============================================================
# 8. Cron pro maily
# ============================================================
echo -e "\n>>> 8. Nastavení cron úlohy pro mbsync + notmuch"

CRON_JOB="*/5 * * * * /usr/bin/mbsync -a && /usr/bin/notmuch new"

if ! crontab -l 2>/dev/null | grep -qF "$CRON_JOB"; then
  (
    crontab -l 2>/dev/null
    echo "$CRON_JOB"
  ) | crontab -
  echo "Úloha přidána."
else
  echo "Úloha už existuje, přeskakuji."
fi

# ============================================================
# 9. Další složky
# ============================================================
echo -e "\n>>> 9. Vytvoření /mnt/Disk2"
sudo mkdir -p /mnt/Disk2
sudo chown "$USER:$USER" /mnt/Disk2

# ============================================================
# Závěrečné shrnutí
# ============================================================
echo -e "\n=================================================="
if [[ ${#ERROR_LOG[@]} -eq 0 ]]; then
  echo -e "\e[32m🎉 Skript dokončen bez chyb!\e[0m"
else
  echo -e "\e[31m⚠️  Skript dokončen, ale tyto příkazy selhaly:\e[0m"
  for err in "${ERROR_LOG[@]}"; do
    echo -e "  - \e[33m$err\e[0m"
  done
fi
echo "=================================================="
