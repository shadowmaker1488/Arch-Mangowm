#!/bin/bash

# Cesta k adresáři se styly
THEME_DIR="$HOME/.config/rofi/themes"

# Cílový konfigurační soubor
CONFIG_FILE="$HOME/.config/rofi/config.rasi"

# Seznam dostupných stylů (jen .rasi soubory, bez přípony)
themes=$(ls -1 "$THEME_DIR" 2>/dev/null | sed 's/\.rasi$//')

if [ -z "$themes" ]; then
  echo "Žádné themes nebyly nalezeny ve $THEME_DIR"
  exit 1
fi

# Výběr stylu pomocí rofi
selected_theme=$(echo "$themes" | rofi -dmenu -p "Vyber Rofi styl:" -i)

# Zkontroluj, zda byl vybrán styl
if [ -z "$selected_theme" ]; then
  echo "Žádný styl nebyl vybrán."
  exit 1
fi

# Ověř, že soubor skutečně existuje
if [ ! -f "$THEME_DIR/${selected_theme}.rasi" ] && [ ! -f "$THEME_DIR/$selected_theme" ]; then
  echo "Theme '$selected_theme' neexistuje."
  exit 1
fi

# Změň @theme v config.rasi
# Podporuje jak @theme "themes/xxx", tak @theme "xxx"
if grep -qE '^\s*@theme\s+"' "$CONFIG_FILE"; then
  # Nahradí existující @theme řádek
  sed -i -E "s|^(\s*@theme\s+\")[^\"]*(\")|\1themes/${selected_theme}\2|" "$CONFIG_FILE"
else
  # Pokud @theme chybí, přidá ho na konec souboru
  echo "" >> "$CONFIG_FILE"
  echo "@theme \"themes/${selected_theme}\"" >> "$CONFIG_FILE"
fi

echo "Rofi theme změněn na: themes/${selected_theme}"
