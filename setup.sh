#!/bin/bash

# Vytvoření prázdného pole pro logování chyb
declare -a ERROR_LOG

# Chytrá funkce pro opakování a logování
retry() {
  # Spustí se původní příkaz
  if "$@"; then
    return 0
  else
    echo -e "\e[33m⚠️ Příkaz selhal. Za 2 sekundy zkusím znovu: $*\e[0m"
    sleep 2
    # Druhý pokus
    if "$@"; then
      echo -e "\e[32m✅ Druhý pokus byl úspěšný.\e[0m"
      return 0
    else
      echo -e "\e[31m❌ Příkaz selhal i napodruhé. Přeskakuji a zapisuji do logu...\e[0m"
      ERROR_LOG+=("$*")
      # Vrátíme 0, čímž Bash oklameme, že je vše OK, aby skript nepadl a jel dál
      return 0
    fi
  fi
}

# --- AUTOMATICKÉ OBALENÍ PŘÍKAZŮ ---
# Tyto příkazy se nyní budou automaticky a neviditelně chránit přes 'retry'
sudo() { retry command sudo "$@"; }
yay() { retry command yay "$@"; }
git() { retry command git "$@"; }
ya() { retry command ya "$@"; }
sh() { retry command sh "$@"; }
# -----------------------------------

sudo pacman -S base-devel --noconfirm

# yay install
git clone https://aur.archlinux.org/yay.git ~/.config/yay
cd ~/.config/yay
makepkg -si --noconfirm
cd

# update system
sudo pacman -Syu --noconfirm

# chaotic AUR

if [[ "$(uname -m)" == "x86_64" ]] && [ -z "$DISABLE_CHAOTIC" ]; then
  # Try installing Chaotic-AUR keyring and mirrorlist
  if ! pacman-key --list-keys 3056513887B78AEB >/dev/null 2>&1 &&
    sudo pacman-key --recv-key 3056513887B78AEB &&
    sudo pacman-key --lsign-key 3056513887B78AEB &&
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' &&
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then

    # Add Chaotic-AUR repo to pacman config
    if ! grep -q "chaotic-aur" /etc/pacman.conf; then
      echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf >/dev/null
    fi
  else
    echo -e "Failed to install Chaotic-AUR, so won't include it in pacman config!"
  fi
fi

# sed stuff
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sudo sed -i 's/#AutoEnable=true/AutoEnable=false/' /etc/bluetooth/main.conf
sudo pacman -Syu --noconfirm

# basic files
mkdir -p ~/.local && mkdir ~/.local/bin/

mv ~/.config/Obrázky .
mv ~/.config/zshrc ~/.zshrc
mv ~/.config/zshenv ~/.zshenv
mv ~/.config/rofi-power-menu ~/.local/bin
mv ~/.config/themes ~/.themes
mv ~/.config/icons ~/.icons

# EFI shell to systemd-boot
# install programs
# update file saving location

xdg-user-dirs-update

yay -S adobe-source-han-sans-cn-fonts \
  adobe-source-han-sans-jp-fonts \
  adobe-source-han-sans-kr-fonts \
  adwaita-fonts \
  atool \
  awww \
  aerc \
  bat \
  cyrus-sasl-xoauth2-git \
  bluetui \
  breeze \
  brightnessctl \
  calcurse \
  caligula \
  cantarell-fonts \
  clamav \
  clipse \
  clipse-gui \
  cronie \
  cups \
  downgrade \
  dysk \
  edk2-shell \
  fastfetch \
  firefox \
  fzf \
  gdu \
  gparted \
  grim \
  gst-plugins-good \
  gvfs \
  htop \
  imagemagick \
  kitty \
  libreoffice-still \
  libreoffice-still-cs \
  limine-mkinitcpio-hook \
  lxqt-policykit \
  lynx \
  mako \
  man-db \
  mangowm-wlonly-git \
  wlroots-git \
  mediainfo \
  mpv \
  mpv-mpris \
  ncspot \
  neovim \
  newsboat \
  noto-fonts-emoji \
  ntfs-3g \
  nwg-look \
  ouch \
  paccache-hook \
  perl-image-exiftool \
  pulsemixer \
  python-ffsubsync \
  python-pipx \
  qimgv-git \
  qt5-wayland \
  qt5ct \
  qt6-wayland \
  qt6ct \
  reflector \
  rofi \
  rofi-calc-git \
  simple-mtpfs \
  slurp \
  subliminal-git \
  swaylock-effects \
  swayidle \
  system-config-printer \
  timeshift \
  telegram-desktop \
  tlp \
  tlpui \
  topgrade \
  trashy \
  tree \
  ttf-jetbrains-mono-nerd \
  ttf-meslo-nerd \
  ttf-ms-win11-auto \
  ttf-roboto \
  udiskie \
  ufw \
  unrar \
  unzip \
  uwsm \
  veracrypt \
  waybar \
  waypaper-git \
  wev \
  wf-recorder \
  wl-clipboard \
  wlsunset \
  wlopm \
  woff2-font-awesome \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-wlr \
  xdg-user-dirs \
  xorg-xhost \
  wl-randr \
  yazi \
  ydotool \
  yt-dlp \
  zathura \
  zathura-cb \
  zathura-pdf-mupdf \
  zip \
  zoxide \
  zsh --noconfirm

# omarchy-send
sh -c "curl -fsSL https://raw.githubusercontent.com/28allday/omarchy-send/main/install.sh | bash"

# services
sudo systemctl enable tlp
sudo systemctl enable ufw
sudo ufw enable
sudo systemctl enable cronie
sudo systemctl enable reflector.timer
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
sudo cp /usr/share/edk2-shell/x64/Shell.efi /boot/shellx64.efi

# Mail automatizace
#

# 1. Instalace a spuštění samotného démona cronie
echo "Instaluji a aktivuji cronie..."
sudo pacman -S --noconfirm cronie
sudo systemctl enable --now cronie.service

# 2. Definice příkazu (každých 5 minut se stáhne pošta a updatuje index)
# DŮLEŽITÉ: V cronu je vždy lepší používat absolutní cesty k programům!
CRON_JOB="*/5 * * * * /usr/bin/mbsync -a && /usr/bin/notmuch new"

# 3. Bezpečný zápis do crontabu
echo "Nastavuji automatickou synchronizaci e-mailů..."

# Zkontrolujeme, jestli už tato přesná úloha v crontabu náhodou není
if ! crontab -l 2>/dev/null | grep -qF "$CRON_JOB"; then
  # Pokud není, vezmeme aktuální crontab, přidáme na konec náš příkaz a uložíme zpět
  (
    crontab -l 2>/dev/null
    echo "$CRON_JOB"
  ) | crontab -
  echo "Úloha pro mbsync a notmuch úspěšně přidána."
else
  echo "Úloha už v crontabu existuje, přeskakuji."
fi

# set default xdg
# Browser xdg
# Writer (text)
xdg-mime default libreoffice-writer.desktop application/vnd.oasis.opendocument.text
xdg-mime default libreoffice-writer.desktop application/vnd.oasis.opendocument.text-template
xdg-mime default libreoffice-writer.desktop application/msword
xdg-mime default libreoffice-writer.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document
xdg-mime default libreoffice-writer.desktop application/rtf
xdg-mime default libreoffice-writer.desktop text/rtf

# Calc (spreadsheets)
xdg-mime default libreoffice-calc.desktop application/vnd.oasis.opendocument.spreadsheet
xdg-mime default libreoffice-calc.desktop application/vnd.oasis.opendocument.spreadsheet-template
xdg-mime default libreoffice-calc.desktop application/vnd.ms-excel
xdg-mime default libreoffice-calc.desktop application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

# Impress (presentations)
xdg-mime default libreoffice-impress.desktop application/vnd.oasis.opendocument.presentation
xdg-mime default libreoffice-impress.desktop application/vnd.oasis.opendocument.presentation-template
xdg-mime default libreoffice-impress.desktop application/vnd.ms-powerpoint
xdg-mime default libreoffice-impress.desktop application/vnd.openxmlformats-officedocument.presentationml.presentation

# Draw (graphics)
xdg-mime default libreoffice-draw.desktop application/vnd.oasis.opendocument.graphics

# Math (formula)
xdg-mime default libreoffice-math.desktop application/vnd.oasis.opendocument.formula

# Browser
xdg-mime default firefox.desktop x-scheme-handler/http

# složky
sudo mkdir /mnt/Disk2 && sudo chown $USER:$USER /mnt/Disk2

# Yazi chmod plugin
ya pack -a yazi-rs/plugins#chmod

# Yazi archive plugin
ya pack -a KKV9/compress

# Yazi mount plugin
ya pack -a yazi-rs/plugins#mount

# yazi ouch archives
ya pack -a ndtoan96/ouch

# Oh my zsh (tichá instalace se zachováním stávajícího zshrc a bez vyžádání hesla)
export KEEP_ZSHRC=yes
export RUNZSH=no
export CHSH=yes
export UNATTENDED=yes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# --- ZÁVĚREČNÉ SHRNUTÍ CHYB ---
echo -e "\n=================================================="
if [ ${#ERROR_LOG[@]} -eq 0 ]; then
  echo -e "\e[32m🎉 Skript byl kompletně dokončen bez jediného erroru!\e[0m"
else
  echo -e "\e[31m⚠️ Skript byl dokončen, ale následující příkazy selhaly:\e[0m"
  for err in "${ERROR_LOG[@]}"; do
    echo -e " - \e[33m$err\e[0m"
  done
fi
echo "=================================================="
