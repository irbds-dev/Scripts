#!/bin/bash

# Script que lista os aplicativos de acordo com as pastas indicadas (pastas padroes para linux)
# São listados apenas aplicativos que estão na pasta do sistema e não estão na pasta local (dentro do home)
# Adiciona a configuração "NoDisplay=true" para os aplicativos selecionado
#
# Caso o aplicativo continue mesmo após ter certeza que selecionou o certo:
# 	É possivel que a configuração não esteja sendo criada dentro da seção "[Desktop Entry]"
# 	Abra o arquivo manualmente e adicione dentro da seção


# Pasta de onde pegar os .desktop (padrão)
SYSTEM_DIR="/usr/share/applications"
USER_DIR="$HOME/.local/share/applications"


# Filtra os arquivos que estão no $SYSTEM_DIR e não estão no $USER_DIR, depois abre uma lista para selecionar os apps.
apps="$SYSTEM_DIR/"$(comm -23 \
  <(find "$SYSTEM_DIR" -maxdepth 1 -type f -name "*.desktop" -printf "%f\n" | sort) \
  <(find "$USER_DIR" -maxdepth 1 -type f -name "*.desktop" -printf "%f\n" | sort) | fzf -m --prompt="[TAB]Selecione os apps a remover; [ENTER]Confirma;  [ESC]Sair do programa")

# Caso nenhum seja selecionado, não ha o que fazer, sai do programa
if [ "$apps" == "$SYSTEM_DIR/"  ]; then
  echo "Nenhum app selecionado."
  exit 1
fi

echo "$apps" | while read -r app; do
  filename=$(basename "$app")
  user_app="$USER_DIR/$filename"

  # Se o arquivo não estiver no diretório local, copia ele
  if [ "$app" != "$user_app" ]; then
    cp "$app" "$user_app"
    app="$user_app"
    echo "Copiado para local: $filename"
  fi

  # Adiciona ou atualiza a linha NoDisplay
  if grep -q "^NoDisplay=" "$app"; then
    sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$app"
  else
    echo "NoDisplay=true" >> "$app"
  fi

  echo "App ocultado: $filename"
done

echo "Feito! Os apps selecionados não aparecerão mais no Rofi."

