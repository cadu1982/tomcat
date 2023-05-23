-- Use o banco de dados desejado
USE BancoDeDadosTomCat;

-- Criação da tabela
CREATE TABLE TB_teste1 (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(50),
    Sobrenome VARCHAR(50),
    Idade INT,
    Email VARCHAR(100)
);
