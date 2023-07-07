#!/usr/bin/env python3

import pyodbc

dados_conexao = (
    "Driver={ODBC Driver 18 for SQL Server};"
    "Server=127.0.0.1;"
    "PORT=1433;"
    "Database=TestDB;"
    "UID=sa;"
    "PWD=Camila@1982;"
    "TrustServerCertificate=yes;"
)


connection = pyodbc.connect(dados_conexao)
print("Conexão Bem Sucedida!")




