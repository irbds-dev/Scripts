#!/bin/bash
#2025/04/04 Criado por irbds-dev 


## Edite conforme necessidade 
caminho="/home/${USER}/.config"
pasta=("/i3/" 
	"/i3status/" 
	"/rofi/"
)
dest="${caminho}/BACKUP-CONF/"
arg=$1


echo "#### Verificando existencia das pasta"
for((cont=0; cont<${#pasta[@]}; cont++)) ; do
	diretorio=${caminho}${pasta[$cont]}
	if [[ ! -d ${diretorio} ]]; then
		echo "ERRO: Não foi possivel localizar ${diretorio} favor verifique"
		exit 1
	fi
done
echo "#### Verificação completa"


echo
echo "#### Criando copia dos diretorios indicados em 'pasta'"
for((cont=0; cont<${#pasta[@]}; cont++)) ; do
		diretorio=${caminho}${pasta[$cont]}
		cp -r ${diretorio} ${dest} 2>/dev/null || {
		echo "Erro ao copiar ${diretorio} favor verificar"
		exit 1
		}
done
echo "#### Copias criadas"


if [ ${arg} = "git" 2>/dev/null ]; then
	cd ${dest}
	echo
	echo "#### Adicionando mudanças ao git"
	git add ${dest}

	echo "#### Criando mensagem para commit AAAAmmdd-HH:MM"
	date +%Y%m%d-%H:%M > /tmp/data
	git commit -F /tmp/data > /dev/null  ||  { 
		echo "nada foi alterado desde o ultimo backup"
		exit 1
	}
	echo -n "Mensagem de commit:   " && cat /tmp/data
	echo "#### Commit criado"

	echo
	echo "#### Enviando arquivo para o GitHub"
	git push > /dev/null
	echo "#### Arquivo enviado"
fi


echo
echo "#### Programa finalizado"
