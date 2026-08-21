#!/bin/bash

# ============================================================
# Arch Linux Post-Install Setup — Interaktivní verze
# s progress bary a podrobným výpisem
# ============================================================

set -uo pipefail

# Barvy
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
BOLD='\e[1m'
DIM='\e[2m'
RESET='\e[0m'

declare -a ERROR_LOG=()

# --- Retry funkce ---
retry() {
  if "$@"; then
    return 0
  else
    echo -e "${YELLOW}⚠️  Příkaz selhal. Za 2 s zkusím znovu: $*${RESET}"
    sleep 2
    if "$@"; then
      echo -e "${GREEN}✅ Druhý pokus úspěšný.${RESET}"
      return 0
    else
      echo -e "${RED}❌ Selhalo i napodruhé. Zapisuji do logu a pokračuji...${RESET}"
      ERROR_LOG+=("$*")
      return 0
    fi
  fi
}

sudo() { retry command sudo "$@"; }
yay()  { retry command yay "$@"; }
git()  { retry command git "$@"; }

# ============================================================
# Progress bar
# ============================================================
progress_bar() {
  local current=$1
  local total=$2
  local width=40
  local percent=$(( current * 100 / total ))
  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))

  printf "\r  ["
  printf "%${filled}s" | tr ' ' '█'
  printf "%${empty}s" | tr ' ' '░'
  printf "] %3d%%  " "$percent"
}

# Spinner + aktuální akce
show_status() {
  local msg="$1"
  echo -e "  ${CYAN}→${RESET} ${msg}"
}

# ============================================================
# Výběr (multi-select)
# ============================================================
declare -A SELECTED
SELECTED[fonts]=0
SELECTED[cli]=0
SELECTED[wayland]=0
SELECTED[media]=0
SELECTED[office]=0
SELECTED[system]=0
SELECTED[chaotic]=1
SELECTED[omarchy]=0
SELECTED[cron]=1
SELECTED[tlp]=1
SELECTED[disk2]=1

print_menu() {
  clear
  echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${BLUE}║     Arch Linux Post-Install Setup — Interaktivní menu     ║${RESET}"
  echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════╝${RESET}"
  echo
  echo -e "${BOLD}Skupiny balíčků:${RESET}"
  echo -e "  $( [[ ${SELECTED[fonts]}   -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) 1) Fonty"
  echo -e "  $( [[ ${SELECTED[cli]}     -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) 2) CLI nástroje"
  echo -e "  $( [[ ${SELECTED[wayland]} -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) 3) Wayland / Desktop / Mango"
  echo -e "  $( [[ ${SELECTED[media]}   -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) 4) Multimédia"
  echo -e "  $( [[ ${SELECTED[office]}  -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) 5) Kancelář + komunikace"
  echo -e "  $( [[ ${SELECTED[system]}  -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) 6) Systémové nástroje"
  echo
  echo -e "${BOLD}Volitelné součásti:${RESET}"
  echo -e "  $( [[ ${SELECTED[chaotic]} -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) c) Chaotic-AUR"
  echo -e "  $( [[ ${SELECTED[omarchy]} -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) o) omarchy-send (curl|bash)"
  echo -e "  $( [[ ${SELECTED[cron]}    -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) m) Cron pro maily (mbsync + notmuch)"
  echo -e "  $( [[ ${SELECTED[tlp]}     -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) t) TLP + maskování rfkill"
  echo -e "  $( [[ ${SELECTED[disk2]}   -eq 1 ]] && echo -e "${GREEN}[✓]${RESET}" || echo "[ ]" ) d) Vytvořit /mnt/Disk2"
  echo
  echo -e "  ${BOLD}a)${RESET} Vybrat vše     ${BOLD}n)${RESET} Zrušit vše     ${BOLD}s)${RESET} Spustit instalaci     ${BOLD}q)${RESET} Ukončit"
  echo
  echo -ne "${YELLOW}Zadej volbu: ${RESET}"
}

toggle() {
  local key=$1
  if [[ ${SELECTED[$key]} -eq 1 ]]; then
    SELECTED[$key]=0
  else
    SELECTED[$key]=1
  fi
}

# ============================================================
# Instalace jednotlivých skupin
# ============================================================
install_fonts() {
  echo -e "\n${BOLD}${CYAN}>>> 5.1 Fonty${RESET}"
  show_status "Instaluji fonty (CJK, Nerd Fonts, emoji...)"
  progress_bar 1 6
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
  progress_bar 1 6
  echo -e "\n  ${GREEN}✓ Fonty hotovo${RESET}"
}

install_cli() {
  echo -e "\n${BOLD}${CYAN}>>> 5.2 CLI nástroje${RESET}"
  show_status "Instaluji CLI utility (bat, eza, fzf, yazi...)"
  progress_bar 2 6
  yay -S --needed --noconfirm \
    aerc atool bash-completion bat bluetui brightnessctl \
    calcurse caligula clipse clipse-gui cronie dysk eza \
    fastfetch fzf gdu htop lynx man-db mediainfo newsboat \
    ouch perl-image-exiftool pulsemixer starship topgrade \
    trash-cli tree yazi zoxide
  progress_bar 2 6
  echo -e "\n  ${GREEN}✓ CLI nástroje hotovo${RESET}"
}

install_wayland() {
  echo -e "\n${BOLD}${CYAN}>>> 5.3 Wayland / Desktop / Mango${RESET}"
  show_status "Instaluji Wayland ekosystém (waybar, rofi, kitty...)"
  progress_bar 3 6
  yay -S --needed --noconfirm \
    awww grim hyprpicker kitty mako mangowm nwg-look \
    rofi rofi-calc rofi-emoji slurp swayidle swaylock-effects \
    waybar waypaper-git wev wf-recorder wl-clipboard wlopm \
    wlr-randr wlsunset xdg-desktop-portal-gtk \
    xdg-desktop-portal-wlr ydotool
  progress_bar 3 6
  echo -e "\n  ${GREEN}✓ Wayland / Desktop hotovo${RESET}"
}

install_media() {
  echo -e "\n${BOLD}${CYAN}>>> 5.4 Multimédia${RESET}"
  show_status "Instaluji multimédia (mpv, zathura, yt-dlp...)"
  progress_bar 4 6
  yay -S --needed --noconfirm \
    gst-plugins-good imagemagick mpv mpv-mpris \
    python-ffsubsync qimgv-git songrec subliminal-git \
    yt-dlp zathura zathura-cb zathura-pdf-mupdf
  progress_bar 4 6
  echo -e "\n  ${GREEN}✓ Multimédia hotovo${RESET}"
}

install_office() {
  echo -e "\n${BOLD}${CYAN}>>> 5.5 Kancelář a komunikace${RESET}"
  show_status "Instaluji Firefox, LibreOffice, Telegram..."
  progress_bar 5 6
  yay -S --needed --noconfirm \
    firefox libreoffice-still libreoffice-still-cs \
    telegram-desktop spotify-player
  progress_bar 5 6
  echo -e "\n  ${GREEN}✓ Kancelář hotovo${RESET}"
}

install_system() {
  echo -e "\n${BOLD}${CYAN}>>> 5.6 Systémové nástroje${RESET}"
  show_status "Instaluji systémové nástroje (tlp, timeshift, neovim...)"
  progress_bar 6 6
  yay -S --needed --noconfirm \
    clamav cups cyrus-sasl-xoauth2-git downgrade edk2-shell \
    gparted gvfs limine-mkinitcpio-hook lxqt-policykit ntfs-3g \
    paccache-hook python-pipx qt5-wayland qt5ct qt6-wayland qt6ct \
    reflector simple-mtpfs smartmontools system-config-printer \
    timeshift tlp tlpui udiskie unrar unzip uwsm veracrypt \
    xdg-user-dirs xorg-xhost zip neovim tesseract-data-ces
  progress_bar 6 6
  echo -e "\n  ${GREEN}✓ Systémové nástroje hotovo${RESET}"
}

# ============================================================
# Hlavní logika
# ============================================================
main_menu() {
  while true; do
    print_menu
    read -r choice
    case $choice in
      1) toggle fonts ;;
      2) toggle cli ;;
      3) toggle wayland ;;
      4) toggle media ;;
      5) toggle office ;;
      6) toggle system ;;
      c|C) toggle chaotic ;;
      o|O) toggle omarchy ;;
      m|M) toggle cron ;;
      t|T) toggle tlp ;;
      d|D) toggle disk2 ;;
      a|A)
        for k in fonts cli wayland media office system chaotic cron tlp disk2; do
          SELECTED[$k]=1
        done
        SELECTED[omarchy]=0
        ;;
      n|N)
        for k in "${!SELECTED[@]}"; do SELECTED[$k]=0; done
        ;;
      s|S) break ;;
      q|Q)
        echo -e "\n${YELLOW}Ukončeno uživatelem.${RESET}"
        exit 0
        ;;
      *)
        echo -e "${RED}Neplatná volba${RESET}"
        sleep 0.8
        ;;
    esac
  done
}

run_installation() {
  clear
  echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${BLUE}           Spouštím instalaci...${RESET}"
  echo -e "${BOLD}${BLUE}════════════════════════════════════════════════════════${RESET}"
  echo

  # 1. Základ
  echo -e "${BOLD}${CYAN}>>> 1. Základní příprava (base-devel + yay)${RESET}"
  show_status "Instaluji base-devel..."
  sudo pacman -S --needed base-devel --noconfirm

  if [[ ! -d ~/.config/yay ]]; then
    show_status "Klonuji yay z AUR..."
    git clone https://aur.archlinux.org/yay.git ~/.config/yay
  fi
  show_status "Kompiluji a instaluji yay..."
  cd ~/.config/yay
  makepkg -si --noconfirm
  cd ~
  echo -e "  ${GREEN}✓ Základ hotovo${RESET}\n"

  # 2. Update + Chaotic
  echo -e "${BOLD}${CYAN}>>> 2. Systémový update${RESET}"
  show_status "Provádím plný systémový update..."
  sudo pacman -Syu --noconfirm
  echo -e "  ${GREEN}✓ Update hotovo${RESET}\n"

  if [[ ${SELECTED[chaotic]} -eq 1 ]]; then
    echo -e "${BOLD}${CYAN}>>> 2b. Chaotic-AUR${RESET}"
    show_status "Přidávám Chaotic-AUR..."
    if [[ "$(uname -m)" == "x86_64" ]]; then
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
    echo -e "  ${GREEN}✓ Chaotic-AUR hotovo${RESET}\n"
  fi

  # 3. Konfigurace
  echo -e "${BOLD}${CYAN}>>> 3. Úpravy konfigurace${RESET}"
  show_status "Upravuji pacman.conf a bluetooth..."
  sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
  sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
  sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
  if [[ -f /etc/bluetooth/main.conf ]]; then
    sudo sed -i 's/#AutoEnable=true/AutoEnable=false/' /etc/bluetooth/main.conf
  fi
  sudo pacman -Syu --noconfirm
  echo -e "  ${GREEN}✓ Konfigurace hotovo${RESET}\n"

  # 4. Dotfiles
  echo -e "${BOLD}${CYAN}>>> 4. Přesun dotfiles${RESET}"
  show_status "Přesouvám konfigurační soubory..."
  mkdir -p ~/.local/bin ~/.themes ~/.icons
  [[ -d ~/.config/Obrázky ]] && mv ~/.config/Obrázky ~
  [[ -f ~/.config/bashrc ]] && mv ~/.config/bashrc ~/.bashrc
  [[ -f ~/.config/bash_profile ]] && mv ~/.config/bash_profile ~/.bash_profile
  [[ -f ~/.config/rofi-power-menu ]] && mv ~/.config/rofi-power-menu ~/.local/bin/
  [[ -f ~/.config/text-extract.sh ]] && mv ~/.config/text-extract.sh ~/.local/bin/
  [[ -d ~/.config/themes ]] && mv ~/.config/themes ~/.themes
  [[ -d ~/.config/icons ]] && mv ~/.config/icons ~/.icons
  echo -e "  ${GREEN}✓ Dotfiles hotovo${RESET}\n"

  # 5. Skupiny balíčků
  local total_groups=0
  local current=0
  [[ ${SELECTED[fonts]}   -eq 1 ]] && ((total_groups++))
  [[ ${SELECTED[cli]}     -eq 1 ]] && ((total_groups++))
  [[ ${SELECTED[wayland]} -eq 1 ]] && ((total_groups++))
  [[ ${SELECTED[media]}   -eq 1 ]] && ((total_groups++))
  [[ ${SELECTED[office]}  -eq 1 ]] && ((total_groups++))
  [[ ${SELECTED[system]}  -eq 1 ]] && ((total_groups++))

  if [[ $total_groups -gt 0 ]]; then
    echo -e "${BOLD}${CYAN}>>> 5. Instalace vybraných skupin balíčků (${total_groups})${RESET}\n"
  fi

  [[ ${SELECTED[fonts]}   -eq 1 ]] && install_fonts
  [[ ${SELECTED[cli]}     -eq 1 ]] && install_cli
  [[ ${SELECTED[wayland]} -eq 1 ]] && install_wayland
  [[ ${SELECTED[media]}   -eq 1 ]] && install_media
  [[ ${SELECTED[office]}  -eq 1 ]] && install_office
  [[ ${SELECTED[system]}  -eq 1 ]] && install_system

  # 6. Služby
  if [[ ${SELECTED[tlp]} -eq 1 ]]; then
    echo -e "\n${BOLD}${CYAN}>>> 6. Povolení služeb${RESET}"
    show_status "Povoluji tlp, cronie, reflector.timer..."
    sudo systemctl enable tlp
    sudo systemctl enable cronie
    sudo systemctl enable reflector.timer
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
    if [[ -f /usr/share/edk2-shell/x64/Shell.efi ]]; then
      sudo cp /usr/share/edk2-shell/x64/Shell.efi /boot/shellx64.efi
    fi
    echo -e "  ${GREEN}✓ Služby hotovo${RESET}\n"
  fi

  # 7. Omarchy
  if [[ ${SELECTED[omarchy]} -eq 1 ]]; then
    echo -e "${BOLD}${CYAN}>>> 7. omarchy-send${RESET}"
    show_status "Instaluji omarchy-send (curl | bash)..."
    sh -c "curl -fsSL https://raw.githubusercontent.com/28allday/omarchy-send/main/install.sh | bash"
    echo -e "  ${GREEN}✓ omarchy-send hotovo${RESET}\n"
  fi

  # 8. Cron
  if [[ ${SELECTED[cron]} -eq 1 ]]; then
    echo -e "${BOLD}${CYAN}>>> 8. Cron pro maily${RESET}"
    show_status "Nastavuji cron úlohu pro mbsync + notmuch..."
    CRON_JOB="*/5 * * * * /usr/bin/mbsync -a && /usr/bin/notmuch new"
    if ! crontab -l 2>/dev/null | grep -qF "$CRON_JOB"; then
      (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
      echo -e "  ${GREEN}✓ Cron úloha přidána${RESET}\n"
    else
      echo -e "  ${YELLOW}ℹ Úloha už existuje${RESET}\n"
    fi
  fi

  # 9. Disk2
  if [[ ${SELECTED[disk2]} -eq 1 ]]; then
    echo -e "${BOLD}${CYAN}>>> 9. /mnt/Disk2${RESET}"
    show_status "Vytvářím /mnt/Disk2..."
    sudo mkdir -p /mnt/Disk2
    sudo chown "$USER:$USER" /mnt/Disk2
    echo -e "  ${GREEN}✓ /mnt/Disk2 hotovo${RESET}\n"
  fi

  # Závěr
  echo -e "\n${BOLD}════════════════════════════════════════════════════════${RESET}"
  if [[ ${#ERROR_LOG[@]} -eq 0 ]]; then
    echo -e "${GREEN}${BOLD}🎉  Skript byl úspěšně dokončen bez chyb!${RESET}"
  else
    echo -e "${RED}${BOLD}⚠️  Skript dokončen, ale tyto příkazy selhaly:${RESET}"
    for err in "${ERROR_LOG[@]}"; do
      echo -e "  - ${YELLOW}$err${RESET}"
    done
  fi
  echo -e "${BOLD}════════════════════════════════════════════════════════${RESET}\n"
}

# ============================================================
# Start
# ============================================================
clear
echo -e "${BOLD}${BLUE}"
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║                                                      ║"
echo "  ║     Arch Linux Post-Install Setup                    ║"
echo "  ║     Interaktivní verze s progress bary               ║"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  Tento skript ti umožní vybrat, které části nainstalovat."
echo -e "  ${DIM}Doporučeno spouštět po čisté instalaci Archu.${RESET}"
echo
echo -ne "  Stiskni Enter pro vstup do menu..."
read -r

main_menu
run_installation
