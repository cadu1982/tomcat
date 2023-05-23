# Define a imagem base a ser utilizada
FROM mcr.microsoft.com/mssql/server:2022-latest

# Variáveis de ambiente para configuração do SQL Server
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=Tomcat123

# Copia o arquivo .sql para ser executado na criação do contêiner (opcional)
COPY script.sql /docker-entrypoint-initdb.d/

# Porta para acesso ao SQL Server
EXPOSE 1433

# Comando para executar o SQL Server no contêiner
CMD ["/opt/mssql/bin/sqlservr"]
