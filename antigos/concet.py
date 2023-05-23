import pyodbc

dados_conexao = (
    "Driver={ODBC Driver 18 for SQL Server};"
    "Server=127.0.0.1;"
    "PORT=1433;"
    "UID=sa;"
    "PWD=Tomcat123;"
    "TrustServerCertificate=yes;"
)
try:
    conn = pyodbc.connect(dados_conexao)
    cursor = conn.cursor()
    print('Conexão estabelecida com sucesso!')

    
# Fecha a conexão
    cursor.close()
    conn.close()

except pyodbc.Error as e:
    print('Erro ao conectar ao banco de dados:', e)

