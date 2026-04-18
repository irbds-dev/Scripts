#!/bin/bash

SYSTEM_DIR="/usr/share/applications"
USER_DIR="$HOME/.local/share/applications"

# Garante que a pasta do usuário existe
mkdir -p "$USER_DIR"

# 1. Filtra os nomes dos arquivos
# 2. Abre o fzf para seleção múltipla
# 3. Armazena apenas os NOMES dos arquivos selecionados
selected_filenames=$(comm -23 \
  <(find "$SYSTEM_DIR" -maxdepth 1 -type f -name "*.desktop" -printf "%f\n" | sort) \
  <(find "$USER_DIR" -maxdepth 1 -type f -name "*.desktop" -printf "%f\n" | sort) | \
  fzf -m --prompt="[TAB] Selecionar | [ENTER] Confirmar | [ESC] Sair")

# Sai se nada for selecionado
if [ -z "$selected_filenames" ]; then
  echo "Nenhum app selecionado."
  exit 1
fi

# Processa cada nome selecionado
echo "$selected_filenames" | while read -r filename; do
  system_app="$SYSTEM_DIR/$filename"
  user_app="$USER_DIR/$filename"

  # Copia para o local se ainda não existir (garante a sobrescrita para ocultar)
  if [ ! -f "$user_app" ]; then
    cp "$system_app" "$user_app"
    echo "Copiado para local: $filename"
  fi

  # Aplica a modificação no arquivo LOCAL
  if grep -q "^NoDisplay=" "$user_app"; then
    sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$user_app"
  else
    sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$user_app"
  fi

  echo "App ocultado com sucesso: $filename"
done

echo "Feito! O Rofi não deve mais listar esses apps."
