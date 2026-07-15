#!/bin/bash
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

# Textové soubory
xdg-mime default nvim.desktop text/plain

# Browser
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop text/html
xdg-mime default firefox.desktop application/xhtml+xml

notify-send "Asociace přiřazeny."
