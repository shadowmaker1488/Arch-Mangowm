#!/bin/bash

# Dynamické odvození cesty k souboru podle názvu účtu v aerc.
# $AERC_ACCOUNT automaticky obsahuje přesný název tvé schránky (např. "MUP" nebo "Osobní").
ABOOK_FILE="$HOME/.abook/$AERC_ACCOUNT"

# Pokud složka nebo samotný soubor pro danou schránku ještě neexistuje,
# skript je automaticky vytvoří, přesně pod jménem té schránky.
if [ ! -f "$ABOOK_FILE" ]; then
  mkdir -p "$HOME/.abook"
  touch "$ABOOK_FILE"
fi

IFS=',' read -ra ADDR_ARRAY <<<"$AERC_TO"

for ADDR in "${ADDR_ARRAY[@]}"; do
  RAW_EMAIL=$(echo "$ADDR" | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+' | head -n 1)

  if [ -z "$RAW_EMAIL" ]; then continue; fi

  if ! grep -qi "$RAW_EMAIL" "$ABOOK_FILE"; then

    TMP_SCRIPT=$(mktemp)
    cat <<'EOF' >"$TMP_SCRIPT"
#!/bin/bash
EMAIL="$1"
ABOOK_FILE="$2"
FULL_ADDR="$3"

echo -e "\nE-mail $EMAIL nemáš v kontaktech."
read -n 1 -p "Chceš kontakt rovnou uložit s vlastním jménem? (a/n): " ans
echo ""

if [[ "${ans,,}" == "a" ]]; then
    read -p "Zadej jméno kontaktu (nebo stiskni jen Enter pro uložení bez jména): " contact_name
    
    if [ -z "$contact_name" ]; then
        echo "From: $FULL_ADDR" | abook --datafile "$ABOOK_FILE" --add-email-quiet
        echo -e "\nUloženo beze změny."
    else
        echo "From: $contact_name <$EMAIL>" | abook --datafile "$ABOOK_FILE" --add-email-quiet
        echo -e "\nÚspěšně uloženo jako: $contact_name"
    fi
    sleep 1
else
    echo "From: $FULL_ADDR" | abook --datafile "$ABOOK_FILE" --add-email-quiet
fi

rm "$0"
EOF
    chmod +x "$TMP_SCRIPT"

    kitty --class abook-editor -T "Nový kontakt" -e "$TMP_SCRIPT" "$RAW_EMAIL" "$ABOOK_FILE" "$ADDR" &
  fi
done
