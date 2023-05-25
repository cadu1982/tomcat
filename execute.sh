#!/bin/bash

# Defina as variáveis de conexão ao banco de dados
servidor="localhost,1433"
nome_usuario="SA"
senha="Tomcat123"

# Defina o local do arquivo
arquivo="./json/install.json"

# Extrair todos os itens da lista usando jq 
scripst=$(jq -r '.sqlfiles[]' "$arquivo")

# Gravando um arquivo com a lista de scripts a serem executados.
echo "$scripst" > scripts.txt

# Loop pelos scripts e execução do sqlcmd
for script in $(cat scripts.txt)
do
  echo "Executando script: $script"
  sqlcmd -S $servidor -U $nome_usuario -P $senha -C -i ./sql/$script -b

  # Verificar o código de saída do sqlcmd
  codigo_saida=$?
  if [ $codigo_saida -ne 0 ]; then
    echo "Erro na execução do script: $script"
    exit 1
  fi
done

rm -r scripts.txt





