#!/bin/bash

# $1 nyní přijímá přímo fyzický název podsložky v mailovém archivu (osobni, mup, prace...)
FOLDER="$1"
# $2 je hledaný výraz z aercu
SEARCH="$2"

# Jeden příkaz vládne všem. Filtr na "noreply" můžeme nechat plošně,
# protože ani z osobního mailu většinou na noreply roboty nepíšeme.
notmuch address --deduplicate=address "path:${FOLDER}/** and ${SEARCH}*" | grep -i "$SEARCH" | grep -vi "noreply"
