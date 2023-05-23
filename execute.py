#!/usr/bin/python3

import json
import pyodbc

conn_str = (
    "Driver={ODBC Driver 18 for SQL Server};"
    "Server=127.0.0.1;"
    "PORT=1433;"
    "UID=sa;"
    "PWD=Tomcat123;"
    "TrustServerCertificate=yes;"
)

# Tenta estabelecer a conexão
try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    print('Conexão estabelecida com sucesso!')

    with open('./json/install.json') as file:
        data = json.load(file)

    scripts = data['sqlfiles']

    for script_name in scripts:
        # Executa um script SQL de um arquivo
        script_file = 'sql/' + script_name

        with open(script_file, 'r') as file:
            script = file.read()
            cursor.execute(script)

        print(f'O script {script_name} foi executado com sucesso!')

        # Verifica o valor retornado
        if cursor.rowcount > 0:
            print('O script retornou resultados. Executando próximo script...')
        else:
            print('O script não retornou resultados. Parando execução dos scripts...')
            break

    # Fecha a conexão
    cursor.close()
    conn.close()

except pyodbc.Error as e:
    print('Erro ao conectar ao banco de dados:', e)