/*----------------------------------------------------------------------*/
/* Script criado para as altera��es de banco de dados referentes ao	*/
/* PROJETO DE MODERNIZA��O DA CLIQUIDACAO DE COBRAN�A DA CIP.		*/
/* 13/01/2023 - Eliane - Cria��o do script.				*/
/*----------------------------------------------------------------------*/
USE AB_DDA
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*------------------------------------
MOTIVOS_DEVOLUCAO
------------------------------------*/
IF (SELECT NAME FROM SYS.OBJECTS WHERE NAME = 'MOTIVOS_DEVOLUCAO') IS NULL 
BEGIN
	CREATE TABLE MOTIVOS_DEVOLUCAO
	( 
		CODMOTIVO VARCHAR (03) NOT NULL, 
		DESCRICAO VARCHAR (150) NOT NULL, 
		CODUSUARIOMANUTENCAO VARCHAR (35) NULL, 
		DATAMANUTENCAO DATETIME NULL, 
		CONSTRAINT PK_MOTIVOS_DEVOLUCAO PRIMARY KEY (CODMOTIVO)
	)
END
GO

/*----------------------------------------------------------------------
ALIMENTANDO A TABELA DE EVENTOS COM O EVENTO QUE VAI SERVIR � DEVOLU��O. 
-----------------------------------------------------------------------*/

IF (SELECT COUNT (CODEVENTO) FROM EVENTOS WHERE CODEVENTO = '8116') = 0 
	INSERT INTO EVENTOS (CODEVENTO, NOMEEVENTO)
		VALUES ('8116', 'DEVOLU��O DE LIQUIDA��O')
go

/*----------------------------------------------------------------------------------
ALIMENTANDO A TABELA DE MOTIVOS DE DEVOLU��O DE LIQUIDA��O COM A CARGA INCIAL DA CIP 
-----------------------------------------------------------------------------------*/

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '40') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO)
		VALUES ('40', 'C�DIGO DE MOEDA INV�LIDO', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '51') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('51', 'BOLETO DE PAGAMENTO LIQUIDADO POR VALOR A MAIOR OU MENOR', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '52') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('52', 'BOLETO DE PAGAMENTO RECEBIDO AP�S O VENCIMENTO SEM JUROS E DEMAIS ENCARGOS', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '53') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('53', 'APRESENTA��O INDEVIDA', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '63') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('63', 'C�DIGO DE BARRAS EM DESACORDO COM AS ESPECIFICA��ES', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '68') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('68', 'REPASSE EM DUPLICIDADE PELA IF RECEBEDORA DE BOLETO DE PAGAMENTOS LIQUIDADOS', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '69') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('69', 'BOLETO DE PAGAMENTO LIQUIDADO EM DUPLICIDADE NO MESMO DIA', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '71') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('71', 'BOLETO DE PAGAMENTO RECEBIDO COM DESCONTO OU ABATIMENTO N�O PREVISTO NO BOLETO DE PAGAMENTO', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '72') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('72', 'DEVOLU��O DE PAGAMENTO FRAUDADO', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '73') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('73', 'BENEFICI�RIO SEM CONTRATO DE COBRAN�A COM A INSTITUI��O FINANCEIRA DESTINAT�RIA', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '74') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('74', 'CNPJ/CPF DO BENEFICI�RIO INV�LIDO OU N�O CONFERE COM O REGISTRO DO BOLETO NA BASE DA IF DESTINAT�RIA', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '75') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('75', 'CNPJ/CPF DO PAGADOR INV�LIDO OU N�O CONFERE COM O REGISTRO DO BOLETO NA BASE DA IF DESTINAT�RIA', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '77') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('77', 'BOLETO EM CART�RIO OU PROTESTADO', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '82') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('82', 'BOLETO DIVERGENTE DA BASE', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '83') = 0 
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO) 
		VALUES ('83', 'BOLETO INEXISTENTE NA BASE', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '84') = 0
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO)
		VALUES ('84', 'RECURSO FINANCEIRO N�O ENVIADO PELA IF RECEBEDORA VIA COMPE BBPROCESSADOR', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '85') = 0
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO)
		VALUES ('85', 'RECURSO FINANCEIRO N�O ENVIADO PELA IF RECEBEDORA VIA COMPE BBPROCESSADOR', 'AUTBANK', GETDATE ())
go

IF (SELECT COUNT (CODMOTIVO) FROM MOTIVOS_DEVOLUCAO WHERE CODMOTIVO = '86') = 0
	INSERT INTO MOTIVOS_DEVOLUCAO (CODMOTIVO, DESCRICAO, CODUSUARIOMANUTENCAO, DATAMANUTENCAO)
		VALUES ('86', 'CORRE��O DE SALDO PARCIAL DE PAGAMENTO', 'AUTBANK', GETDATE ())
go

/*----------------------------------------------------------------------------------
ALIMENTANDO A TABELA DE PARAMETRO_ENVIO COM A CARGA do ADDA116/DDA0116
-----------------------------------------------------------------------------------*/
IF NOT EXISTS(SELECT 1 FROM PARAMETRO_ENVIO WHERE MENSAGEM = 'ADDA116' AND EVENTO = '') 
BEGIN
	INSERT INTO PARAMETRO_ENVIO (MENSAGEM, EVENTO, HORAINICIO, HORAFIM, TIPOCALCULO, DESCRICAO) 
		VALUES ('ADDA116', '', '0548', '0551', '0', 'Cancelamento da Baixa')
END
GO

IF NOT EXISTS(SELECT 1 FROM PARAMETRO_ENVIO WHERE MENSAGEM = 'ADDA116' AND EVENTO = '') 
BEGIN
	INSERT INTO PARAMETRO_ENVIO (MENSAGEM, EVENTO, HORAINICIO, HORAFIM, TIPOCALCULO, DESCRICAO) 
		VALUES ('DDA0116', '', '0548', '0551', '0', 'Envio de Cancelamento da Baixa')
END
GO

/*------------------------------------
RECEBE_ADDA116_RET_ACEITOS
------------------------------------*/
IF (SELECT NAME FROM SYS.OBJECTS WHERE NAME = 'RECEBE_ADDA116_RET_ACEITOS') IS NULL
BEGIN
	CREATE TABLE [DBO].[RECEBE_ADDA116_RET_ACEITOS]
	(
		[DATAMOVTO] [DATETIME] NOT NULL, 
		[NUMPEDIDO] [NUMERIC](10, 0) NOT NULL, 
		[NUMIDENTCBAIXA] [NUMERIC](19, 0) NOT NULL, 
		[NUMCTRLDDA] [VARCHAR](20) NULL, 
		[CODPROCESSA] [CHAR](1) NOT NULL, 
		[CODREJEICAO] [CHAR](2) NULL, 
		[DATAMANUTENCAO] [DATETIME] NULL, 
		[TIPORETORNO] [CHAR](1) NULL, 
		[NOMEARQRET] [VARCHAR](255) NULL, 
		[INDIMPORTACAOVALIDA] [CHAR](1) NULL, 
		[SEQ_RECEBE] [NUMERIC](15, 0) IDENTITY(1, 1) NOT NULL, 
		[DATAHORASITUACAO] [DATETIME] NULL, 
		[DATAHORADDA] [DATETIME] NULL, 
		
		CONSTRAINT [PK_RECEBE_ADDA116_RET_ACEITOS] PRIMARY KEY CLUSTERED 
		(
			[SEQ_RECEBE] ASC, 
			[NUMPEDIDO] ASC, 
			[DATAMOVTO] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

/*------------------------------------
RECEBE_ADDA116_RET_RECUSADOS
------------------------------------*/
IF (SELECT NAME FROM SYS.OBJECTS WHERE NAME = 'RECEBE_ADDA116_RET_RECUSADOS') IS NULL
BEGIN
	CREATE TABLE [DBO].[RECEBE_ADDA116_RET_RECUSADOS]
	(
		[SEQ_RECEBE] [NUMERIC](15, 0) IDENTITY(1, 1) NOT NULL, 
		[DATAMOVTO] [DATETIME] NOT NULL, 
		[NUMPEDIDO] [NUMERIC](10, 0) NOT NULL, 
		[NUMIDENTCBAIXA] [NUMERIC](19, 0) NOT NULL, 
		[NUMCTRLDDA] [VARCHAR](20) NULL, 
		[CODPROCESSA] [CHAR](1) NOT NULL, 
		[CODREJEICAO] [CHAR](2) NULL, 
		[DATAMANUTENCAO] [DATETIME] NULL, 
		[TIPORETORNO] [CHAR](1) NULL, 
		[NOMEARQRET] [VARCHAR](255) NULL, 
		[INDIMPORTACAOVALIDA] [CHAR](1) NULL, 
		[DATAHORACANCELAMENTOBAIXA] [DATETIME] NULL, 
		[DATAHORADDA] [DATETIME] NULL, 
		[CODMOTIVO] [VARCHAR](03) NULL, 
		
		CONSTRAINT [PK_RECEBE_ADDA116_RET_RECUSADOS] PRIMARY KEY CLUSTERED 
		(
			[SEQ_RECEBE] ASC, 
			[NUMPEDIDO] ASC, 
			[DATAMOVTO] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

/*------------------------------------
RECEBE_ADDA116_RR2
------------------------------------*/
IF (SELECT NAME FROM SYS.OBJECTS WHERE NAME = 'RECEBE_ADDA116_RR2') IS NULL
BEGIN
	CREATE TABLE [DBO].[RECEBE_ADDA116_RR2]
	(
		[SEQ_RECEBE] [NUMERIC](15, 0) IDENTITY(1, 1) NOT NULL, 
		[NUMIDENTCDDA] [NUMERIC](19, 0) NOT NULL, 
		[DATAMOVTO] [DATETIME] NOT NULL, 
		[NUMREFALTCADTIT] [NUMERIC](19, 0) NULL, 
		[NUMCTRLDDA] [VARCHAR](20) NULL, 
		[DATAHORASITUACAO] [DATETIME] NULL, 
		[NUMIDENTCBAIXA] [NUMERIC](19, 0) NULL, 
		[DATAHORACANCELAMENTOBAIXA] [DATETIME] NULL, 
		[QTDPAGTOREGTD] [INT] NULL, 
		[VLRSALDOATUAL] [NUMERIC](19, 5) NULL, --> CHECAR O NOME COM O RAFAEL PARA A TAG VLRTOTPGTO
		[NUMULTIDENTCBAIXA] [NUMERIC](19, 0) NULL, 
		[SITPAGTO] [VARCHAR](2) NULL, 
		[DATAHORADDA] [DATETIME] NULL, 
		[CODMOTIVO] [VARCHAR](3) NULL, 
		[INDCONTINGENCIA] [VARCHAR](1) NULL, 
		[CODPROCESSA] [CHAR](1) NOT NULL, 
		[DATAMANUTENCAO] [DATETIME] NULL, 
		[TIPORETORNO] [CHAR](1) NULL, 
		[NOMEARQRET] [VARCHAR](255) NULL, 
		[INDIMPORTACAOVALIDA] [CHAR](1) NULL, 
		[CODREJEICAO] [VARCHAR](2) NULL, 
		
		CONSTRAINT [PK_RECEBE_ADDA116_RR2] PRIMARY KEY CLUSTERED
		(
			[SEQ_RECEBE] ASC, 
			[NUMIDENTCDDA] ASC, 
			[DATAMOVTO] ASC
		) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

/*------------------------------------
TEMP_RECEBE_ADDA116_RR2
------------------------------------*/
IF (SELECT NAME FROM SYS.OBJECTS WHERE NAME = 'TEMP_RECEBE_ADDA116_RR2') IS NULL
BEGIN
	CREATE TABLE [DBO].[TEMP_RECEBE_ADDA116_RR2](
		[SEQ_RECEBE] [NUMERIC](15, 0) NOT NULL,
		[NUMIDENTCDDA] [NUMERIC](19, 0) NOT NULL,
		[DATAMOVTO] [DATETIME] NOT NULL,
		[DATAHORAPROC] [DATETIME] NULL,
	 CONSTRAINT [PK_TEMP_RECEBE_ADDA116_RR2] PRIMARY KEY CLUSTERED 
	(
		[SEQ_RECEBE] ASC,
		[NUMIDENTCDDA] ASC,
		[DATAMOVTO] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

/*------------------------------------
MANUT_TITULOS
------------------------------------*/
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS 
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'MANUT_TITULOS'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE MANUT_TITULOS
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'MANUT_TITULOS'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE MANUT_TITULOS
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'MANUT_TITULOS'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE MANUT_TITULOS
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'MANUT_TITULOS'
				AND SYS.COLUMNS.NAME = 'ISPBINICIADORPAGTO')
BEGIN
	ALTER TABLE MANUT_TITULOS
		ADD ISPBINICIADORPAGTO VARCHAR (08) NULL 
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'MANUT_TITULOS'
				AND SYS.COLUMNS.NAME = 'AGENCIARECEBEDORA')
BEGIN
	ALTER TABLE MANUT_TITULOS
		ADD AGENCIARECEBEDORA VARCHAR (04) NULL 
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'MANUT_TITULOS'
				AND SYS.COLUMNS.NAME = 'CODMOTIVO')
BEGIN
	ALTER TABLE MANUT_TITULOS
		ADD CODMOTIVO VARCHAR (03) NULL /* MOTIVO DE CANCELAMENTO - DDA0116 */
END
GO

/*------------------------------------
BAIXAS_OPERACIONAIS
------------------------------------*/
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'BAIXAS_OPERACIONAIS'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'BAIXAS_OPERACIONAIS'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'BAIXAS_OPERACIONAIS'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'BAIXAS_OPERACIONAIS'
				AND SYS.COLUMNS.NAME = 'ISPBINICIADORPAGTO')
BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS
		ADD ISPBINICIADORPAGTO VARCHAR (08) NULL 
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'BAIXAS_OPERACIONAIS'
				AND SYS.COLUMNS.NAME = 'AGENCIARECEBEDORA')
BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS
		ADD AGENCIARECEBEDORA VARCHAR (04) NULL 
END
GO

--INCLUS�O DE DEFAULT PARA CAMPO QUE DEIXOU DE EXISTIR NO XML
IF EXISTS (SELECT * 
				FROM INFORMATION_SCHEMA.COLUMNS 
				WHERE TABLE_NAME = 'BAIXAS_OPERACIONAIS'
				AND COLUMN_NAME = 'NUMSEQBAIXAOPERAC'
				AND TABLE_SCHEMA = 'DBO'
				AND COLUMN_DEFAULT IS NULL)
BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS 
		ADD DEFAULT 0 
		FOR NUMSEQBAIXAOPERAC
END
GO

/*------------------------------------
RECEBE_ADDA108_RET_RECUSADOS
------------------------------------*/
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RET_RECUSADOS
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RET_RECUSADOS
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RET_RECUSADOS
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'ISPBINICIADORPAGTO')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RET_RECUSADOS
		ADD ISPBINICIADORPAGTO VARCHAR (08) NULL 
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'AGENCIARECEBEDORA')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RET_RECUSADOS
		ADD AGENCIARECEBEDORA VARCHAR (04) NULL 
END
GO

/*------------------------------------
RECEBE_ADDA108_RR2
------------------------------------*/
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RR2'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RR2'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RR2'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO
----
/*IF NOT EXISTS 
(SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RR2'
				AND SYS.COLUMNS.NAME = 'ISPBINICIADORPAGTO')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2
		ADD ISPBINICIADORPAGTO VARCHAR (08) NULL 
END
GO*/
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RR2'
				AND SYS.COLUMNS.NAME = 'AGENCIARECEBEDORA')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2
		ADD AGENCIARECEBEDORA VARCHAR (04) NULL 
END
GO

/*------------------------------------
RECEBE_ADDA114_RET_ACEITOS
------------------------------------*/
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RET_ACEITOS'
				AND SYS.COLUMNS.NAME = 'DATAHORASITUACAOBAIXA')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RET_ACEITOS
		ADD DATAHORASITUACAOBAIXA DATETIME NULL
END
GO

/*------------------------------------
RECEBE_ADDA114_RET_RECUSADOS
------------------------------------*/
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RET_RECUSADOS
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RET_RECUSADOS
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RET_RECUSADOS
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'ISPBINICIADORPAGTO')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RET_RECUSADOS
		ADD ISPBINICIADORPAGTO VARCHAR (08) NULL 
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RET_RECUSADOS'
				AND SYS.COLUMNS.NAME = 'AGENCIARECEBEDORA')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RET_RECUSADOS
		ADD AGENCIARECEBEDORA VARCHAR (04) NULL 
END
GO

/*------------------------------------
RECEBE_ADDA114_RR2
------------------------------------*/
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RR2'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RR2
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RR2'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RR2
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RR2'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RR2
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO
----
/*IF NOT EXISTS 
(SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RR2'
				AND SYS.COLUMNS.NAME = 'ISPBINICIADORPAGTO')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RR2
		ADD ISPBINICIADORPAGTO VARCHAR (08) NULL 
END
GO*/
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA114_RR2'
				AND SYS.COLUMNS.NAME = 'AGENCIARECEBEDORA')
BEGIN
	ALTER TABLE RECEBE_ADDA114_RR2
		ADD AGENCIARECEBEDORA VARCHAR (04) NULL 
END
GO

/*------------------------------------
RECEBE_BAIXAS_OPERACIONAIS_ADDA121_RR3
------------------------------------*/
/* RECEBE_BAIXAS_OPERACIONAIS_ADDA121_RR3 --> N�O RECEBEU INICIADOR DE PAGTO NEM AGERECEB */
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_ADDA121_RR3'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_ADDA121_RR3
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_ADDA121_RR3'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_ADDA121_RR3
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_ADDA121_RR3'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_ADDA121_RR3
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO

/*------------------------------------
RECEBE_BAIXAS_OPERACIONAIS_ADDA127
------------------------------------*/
/* RECEBE_BAIXAS_OPERACIONAIS_ADDA127 --> N�O RECEBEU INICIADOR DE PAGTO NEM AGERECEB */
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_ADDA127'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_ADDA127
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_ADDA127'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_ADDA127
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_ADDA127'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_ADDA127
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO

/*------------------------------------
RECEBE_ADDA108_RET_ACEITOS
------------------------------------*/
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_ADDA108_RET_ACEITOS'
				AND SYS.COLUMNS.NAME = 'DATAHORASITUACAOBAIXA')
BEGIN
	ALTER TABLE RECEBE_ADDA108_RET_ACEITOS
		ADD DATAHORASITUACAOBAIXA DATETIME NULL
END
GO

/*------------------------------------------
RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106
-------------------------------------------*/
/* RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106 --> N�O RECEBEU INICIADOR DE PAGTO NEM AGERECEB */
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106'
				AND SYS.COLUMNS.NAME = 'TIPOPESAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106
		ADD TIPOPESAGREGADOR CHAR (01) NULL /* F - F�SICA J = JURIDICA */
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106'
				AND SYS.COLUMNS.NAME = 'CNPJ_CPF_AGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106
		ADD CNPJ_CPF_AGREGADOR VARCHAR (14) NULL
END
GO
----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106'
				AND SYS.COLUMNS.NAME = 'NOMEAGREGADOR')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106
		ADD NOMEAGREGADOR VARCHAR (50) NULL
END
GO


----
IF NOT EXISTS (SELECT * FROM SYS.OBJECTS, SYS.COLUMNS
				WHERE SYS.OBJECTS.OBJECT_ID = SYS.COLUMNS.OBJECT_ID
				AND SYS.OBJECTS.NAME = 'RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106'
				AND SYS.COLUMNS.NAME = 'AGENCIARECEBEDORA')
BEGIN
	ALTER TABLE RECEBE_BAIXAS_OPERACIONAIS_DDA0106R1_ADDA106
		ADD AGENCIARECEBEDORA VARCHAR (04) NULL 
END
GO
---------------------------------------------------------------------------------
/*------------------------------------
TEMP_RECEBE_ADDA116_RET_ACEITOS
------------------------------------*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE NAME = N'TEMP_RECEBE_ADDA116_RET_ACEITOS')
BEGIN
	DROP TABLE TEMP_RECEBE_ADDA116_RET_ACEITOS
END 
GO
IF NOT EXISTS(SELECT * FROM SYS.OBJECTS WHERE NAME = N'TEMP_RECEBE_ADDA116_RET_ACEITOS')
BEGIN
	CREATE TABLE [dbo].[TEMP_RECEBE_ADDA116_RET_ACEITOS](
		[SEQ_RECEBE] [numeric](15, 0) NOT NULL,
		[NUMPEDIDO] [numeric](10, 0) NOT NULL,
		[DATAMOVTO] [datetime] NOT NULL,
		[DATAHORAPROC] [datetime] NULL,
	 CONSTRAINT [PK_TEMP_RECEBE_ADDA116_RET_ACEITOS] PRIMARY KEY CLUSTERED 
	(
		[SEQ_RECEBE] ASC,
		[NUMPEDIDO] ASC,
		[DATAMOVTO] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END 
GO
---------------------------------------------------------------------------------
/*------------------------------------
TEMP_RECEBE_ADDA116_RET_RECUSADOS
------------------------------------*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE NAME = N'TEMP_RECEBE_ADDA116_RET_RECUSADOS')
BEGIN
	DROP TABLE TEMP_RECEBE_ADDA116_RET_RECUSADOS
END 
GO
IF NOT EXISTS(SELECT * FROM SYS.OBJECTS WHERE NAME = N'TEMP_RECEBE_ADDA116_RET_RECUSADOS')
BEGIN
	CREATE TABLE [dbo].[TEMP_RECEBE_ADDA116_RET_RECUSADOS](
		[SEQ_RECEBE] [numeric](15, 0) NOT NULL,
		[NUMPEDIDO] [numeric](10, 0) NOT NULL,
		[DATAMOVTO] [datetime] NOT NULL,
		[DATAHORAPROC] [datetime] NULL,
	 CONSTRAINT [PK_TEMP_RECEBE_ADDA116_RET_RECUSADOS] PRIMARY KEY CLUSTERED 
	(
		[SEQ_RECEBE] ASC,
		[NUMPEDIDO] ASC,
		[DATAMOVTO] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO
---------------------------------------------------------------------------------
/*------------------------------------
TEMP_RECEBE_ADDA116_RR2
------------------------------------*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM SYS.OBJECTS WHERE NAME = N'TEMP_RECEBE_ADDA116_RR2')
BEGIN
	DROP TABLE TEMP_RECEBE_ADDA116_RR2
END 
GO
IF NOT EXISTS(SELECT * FROM SYS.OBJECTS WHERE NAME = N'TEMP_RECEBE_ADDA116_RR2')
BEGIN
	CREATE TABLE [dbo].[TEMP_RECEBE_ADDA116_RR2](
		[SEQ_RECEBE] [numeric](15, 0) NOT NULL,
		[NUMIDENTCDDA] [numeric](19, 0) NOT NULL,
		[DATAMOVTO] [datetime] NOT NULL,
		[DATAHORAPROC] [datetime] NULL,
	 CONSTRAINT [PK_TEMP_RECEBE_ADDA116_RR2] PRIMARY KEY CLUSTERED 
	(
		[SEQ_RECEBE] ASC,
		[NUMIDENTCDDA] ASC,
		[DATAMOVTO] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO
---------------------------------------------------------------------------------
/*------------------------------------
VWIB_VRSMANUAL
------------------------------------*/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE  NAME = N'VWIB_VRSMANUAL' AND TYPE = 'V')
	DROP VIEW VWIB_VRSMANUAL
GO

CREATE VIEW VWIB_VRSMANUAL AS
	SELECT VRSMANUAL 
	FROM 
		AB_INFOBANC..VERSAO_MANUAL, 
		PARAMETROS
	WHERE AB_INFOBANC..VERSAO_MANUAL.DATAATIVA <= PARAMETROS.DATAPROCESSAMENTO
	AND AB_INFOBANC..VERSAO_MANUAL.DATADESATIVA > PARAMETROS.DATAPROCESSAMENTO  
GO 
---------------------------------------------------------------------------------
/*------------------------------------
VWIB_DE_PARA_SGR
------------------------------------*/
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE  NAME = N'VWIB_DE_PARA_SGR' AND TYPE = 'V')
	DROP VIEW VWIB_DE_PARA_SGR
GO

CREATE VIEW VWIB_DE_PARA_SGR
AS 
	SELECT  
		AB_INFOBANC..DE_PARA_SGR.CODSISTEMA,
		AB_INFOBANC..DE_PARA_SGR.CODMSG,
		AB_INFOBANC..DE_PARA_SGR.TIPO_M,
		AB_INFOBANC..DE_PARA_SGR.SEQUENCIA,
		AB_INFOBANC..DE_PARA_SGR.TAG,
		AB_INFOBANC..DE_PARA_SGR.NOMETABELA,
		AB_INFOBANC..DE_PARA_SGR.NOMECAMPO,
		AB_INFOBANC..DE_PARA_SGR.NOMECAMPO2,
		AB_INFOBANC..DE_PARA_SGR.VRSMANUAL,
		ISNULL(AB_INFOBANC..DE_PARA_SGR.OBRIGATORIO, 'N') 'OBRIGATORIO'
	FROM 
		AB_INFOBANC..DE_PARA_SGR, 
		AB_INFOBANC..VERSAO_MANUAL, 
		PARAMETROS
	WHERE AB_INFOBANC..DE_PARA_SGR.CODSISTEMA = 'DA' 	
	AND AB_INFOBANC..DE_PARA_SGR.VRSMANUAL = AB_INFOBANC..VERSAO_MANUAL.VRSMANUAL 
	AND AB_INFOBANC..VERSAO_MANUAL.DATAATIVA <= PARAMETROS.DATAPROCESSAMENTO 
	AND AB_INFOBANC..VERSAO_MANUAL.DATADESATIVA > PARAMETROS.DATAPROCESSAMENTO
GO

DECLARE @dbname nvarchar(128)
SET @dbname = N'AB_DDAARQUIVADA'

IF (
EXISTS (SELECT name
FROM sys.databases
WHERE ('[' + name + ']' = @dbname
OR name = @dbname))
)
BEGIN
	IF EXISTS (SELECT * FROM sys.views WHERE name = 'RECEBE_ADDA108_RR2_PASS')
	BEGIN
		DROP VIEW [DBO].[RECEBE_ADDA108_RR2_PASS] 
	END
	IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'MANUT_SACELETRONICO_PASS')
	BEGIN
		EXECUTE('CREATE VIEW [DBO].[RECEBE_ADDA108_RR2_PASS] AS     
		SELECT VW.* 
		FROM AB_DDAARQUIVADA..RECEBE_ADDA108_RR2_PASS VW')
	END

	IF EXISTS (SELECT * FROM sys.views WHERE name = 'BAIXAS_OPERACIONAIS_PASS')
	BEGIN
		DROP VIEW [DBO].[BAIXAS_OPERACIONAIS_PASS] 
	END
	IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'MANUT_SACELETRONICO_PASS')
	BEGIN
		EXECUTE('CREATE VIEW [DBO].[BAIXAS_OPERACIONAIS_PASS] AS       
		SELECT VW.*      
		FROM AB_DDAARQUIVADA..BAIXAS_OPERACIONAIS_PASS VW')
	END

	IF EXISTS (SELECT * FROM sys.views WHERE name = 'MANUT_TITULOS_PASS')
	BEGIN
		DROP VIEW [DBO].[MANUT_TITULOS_PASS] 
	END
	IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'MANUT_TITULOS_PASS')
	BEGIN
		EXECUTE('CREATE VIEW [DBO].[MANUT_TITULOS_PASS] AS     
		SELECT VW.*    
		FROM AB_DDAARQUIVADA..MANUT_TITULOS_PASS VW')
	END

	IF EXISTS (SELECT * FROM sys.views WHERE name = 'MANUT_SACELETRONICO_PASS')
	BEGIN
		DROP VIEW [DBO].[MANUT_SACELETRONICO_PASS] 
	END
	IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'MANUT_SACELETRONICO_PASS')
	BEGIN
		EXECUTE('CREATE VIEW [DBO].[MANUT_SACELETRONICO_PASS] AS   
		SELECT VW.*  
		FROM AB_DDAARQUIVADA..MANUT_SACELETRONICO_PASS VW')
	END
END
ELSE
BEGIN
	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'MANUT_TITULOS_PASS'
	 and sys.columns.name = 'TIPOPESAGREGADOR')
	BEGIN
	ALTER TABLE MANUT_TITULOS_PASS
	ADD   TIPOPESAGREGADOR   		CHAR (01) NULL /* F - F�SICA J = JURIDICA */
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'MANUT_TITULOS_PASS'
	 and sys.columns.name = 'CNPJ_CPF_AGREGADOR')
	BEGIN
	ALTER TABLE MANUT_TITULOS_PASS
	ADD   CNPJ_CPF_AGREGADOR   		VARCHAR (14) NULL
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'MANUT_TITULOS_PASS'
	 and sys.columns.name = 'NOMEAGREGADOR')
	BEGIN
	ALTER TABLE MANUT_TITULOS_PASS
	ADD   NOMEAGREGADOR   		VARCHAR (50) NULL
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'MANUT_TITULOS_PASS'
	 and sys.columns.name = 'ISPBINICIADORPAGTO')
	BEGIN
	ALTER TABLE MANUT_TITULOS_PASS
	ADD   ISPBINICIADORPAGTO   		VARCHAR (08) NULL 
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'MANUT_TITULOS_PASS'
	 and sys.columns.name = 'AGENCIARECEBEDORA')
	BEGIN
	ALTER TABLE MANUT_TITULOS_PASS
	ADD   AGENCIARECEBEDORA   		VARCHAR (04) NULL 
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'MANUT_TITULOS_PASS'
	 and sys.columns.name = 'CODMOTIVO')
	BEGIN
	ALTER TABLE MANUT_TITULOS_PASS
	ADD   CODMOTIVO   		VARCHAR (03) NULL /* MOTIVO DE CANCELAMENTO - DDA0116 */
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'RECEBE_ADDA108_RR2_PASS'
	 and sys.columns.name = 'TIPOPESAGREGADOR')
	BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2_PASS
	ADD   TIPOPESAGREGADOR   		CHAR (01) NULL /* F - F�SICA J = JURIDICA */
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'RECEBE_ADDA108_RR2_PASS'
	 and sys.columns.name = 'CNPJ_CPF_AGREGADOR')
	BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2_PASS
	ADD   CNPJ_CPF_AGREGADOR   		VARCHAR (14) NULL
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'RECEBE_ADDA108_RR2_PASS'
	 and sys.columns.name = 'NOMEAGREGADOR')
	BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2_PASS
	ADD   NOMEAGREGADOR   		VARCHAR (50) NULL
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'RECEBE_ADDA108_RR2_PASS'
	 and sys.columns.name = 'AGENCIARECEBEDORA')
	BEGIN
	ALTER TABLE RECEBE_ADDA108_RR2_PASS
	ADD   AGENCIARECEBEDORA   		VARCHAR (04) NULL 
	END

	-- ######################################################### BAIXA_OPERACIONAL_PASS #########################################################   
 
	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'BAIXAS_OPERACIONAIS_PASS'
	 and sys.columns.name = 'TIPOPESAGREGADOR')
	BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS_PASS
	ADD   TIPOPESAGREGADOR   		CHAR (01) NULL /* F - F�SICA J = JURIDICA */
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'BAIXAS_OPERACIONAIS_PASS'
	 and sys.columns.name = 'CNPJ_CPF_AGREGADOR')
	BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS_PASS
	ADD   CNPJ_CPF_AGREGADOR   		VARCHAR (14) NULL
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'BAIXAS_OPERACIONAIS_PASS'
	 and sys.columns.name = 'NOMEAGREGADOR')
	BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS_PASS
	ADD   NOMEAGREGADOR   		VARCHAR (50) NULL
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'BAIXAS_OPERACIONAIS_PASS'
	 and sys.columns.name = 'ISPBINICIADORPAGTO')
	BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS_PASS
	ADD   ISPBINICIADORPAGTO   		VARCHAR (08) NULL 
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'BAIXAS_OPERACIONAIS_PASS'
	 and sys.columns.name = 'AGENCIARECEBEDORA')
	BEGIN
	ALTER TABLE BAIXAS_OPERACIONAIS_PASS
	ADD   AGENCIARECEBEDORA   		VARCHAR (04) NULL 
	END

	IF NOT EXISTS 
	(SELECT * FROM sys.objects, sys.columns
	 where sys.objects.object_id = sys.columns.object_id
	 and sys.objects.name = 'MANUT_SACELETRONICO_PASS'
	 and sys.columns.name = 'DATAHORADDA')
	BEGIN
	ALTER TABLE MANUT_SACELETRONICO_PASS
	ADD DATAHORADDA DATETIME NULL
	END
END
GO

INSERT INTO VERSAO_SISTEMA (
	[VERSAO],
	[NOMESCRIPT],
	[CODUSUARIO],
	[DATAATU])
SELECT 
	'V15_01_1_01Bz', 
	'da_atu_V15_01_1_01Bz_tables', 
	SYSTEM_USER, 
	GETDATE() 
GO

/*
COMPARANDO AS TABELAS DE BAIXAS PARA ELEGER AQUELA QUE SER� ALIMENTADA DAQUI PRA FRENTE:


Name 		Name 
----------------------------		------------------------
BAIXAS_OPERACIONAIS 		BAIXAS_EFETIVAS 

 					 
 					 
Column_name 		Column_name 
----------------------------		------------------------	NAO TEM 
NUMIDENTCDDA 		NUMIDENTCDDA 	NUMIDENTCBAIXAEFET
NUMIDENTCBAIXAOPERAC 		NUMIDENTCBAIXAOPERAC 
NUMCTRLDDA 		NUMCTRLDDA 	NUMREFBAIXAEFET
NUMREFBAIXAOPERAC 		 			NUMSEQBAIXAEFET
NUMSEQBAIXAOPERAC 		 
NUMREFCADTIT 		NUMREFCADTIT 
NUMSEQCADTIT 		NUMSEQCADTIT 
DATAMOVTO 		DATAMOVTO 
DATAHORADDA 		DATAHORADDA 
TIPOBAIXA 		TIPOBAIXA 
DATABAIXA 		DATABAIXA 
DATAHORABAIXA 		DATAHORABAIXA 
VLRBAIXA 		VLRBAIXA 
NUMCODBARRAS 		NUMCODBARRAS 
SITBAIXA 		 
DATAHORASITUACAO 		DATAHORASITUACAO 
ISPBSACADA 		ISPBCEDENTE 
CODIFSACADA 		CODIFCEDENTE 
NUMCTRLDDACANCEL 		 
DATAHORACANCEL 		 
SITPAGTO 		SITPAGTO 
SITUACAOTIT 		SITUACAOTIT 
CANALPAGTO 		CANALPAGTO 
MEIOPAGTO 		MEIOPAGTO 
INDCONTINGENCIA 		 
TIPOPESPORTADOR 		 
CNPJ_CPF_PORTADOR 		 
QTDPAGTOREG 		QTDPAGTOREG 
VLRSALDOATUAL 		VLRSALDOATUAL 
ORIGEMCANCELAMENTO 
NOME_PORTADOR 
DATAHORARECBTTITULO 

INCLUINDO EM BAIXAS OPERACIONAIS

117<TpPessoaAgrgdr> Tipo Pessoa Agregador [0..1]
118<CNPJ_CPFAgrgdr> CNPJ ou CPF Agregador [0..1]
119<Nom_RzSocAgrgdr> Nome do Agregador [0..1]
120<AgRecbdr> Ag�ncia do Recebedor [0..1]
24 <ISPBInidrPgto> ISPB Iniciador Pagamento [0..1]
*/