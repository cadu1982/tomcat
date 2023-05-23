import pyodbc

# Define as informações de conexão
server = 'NomeDoServidor'
database = 'NomeDoBancoDeDados'
username = 'NomeDoUsuario'
password = 'SenhaDoUsuario'

# Define a string de conexão
conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}'

# Tenta estabelecer a conexão
try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()
    print('Conexão estabelecida com sucesso!')

    # Executa operações no banco de dados

    # Exemplo: Executa uma consulta SQL
    cursor.execute('SELECT * FROM NomeDaTabela')
    rows = cursor.fetchall()
    for row in rows:
        print(row)

    # Fecha a conexão
    conn.close()

except pyodbc.Error as e:
    print('Erro ao conectar ao banco de dados:', e)
