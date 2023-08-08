USE AB_DDA
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_INCLUI_RECEBE_ADDA116_RET_RECUSADOS')
BEGIN
	EXEC ('CREATE PROCEDURE dbo.SP_INCLUI_RECEBE_ADDA116_RET_RECUSADOS AS BEGIN RETURN END')
END
GO

ALTER PROCEDURE dbo.SP_INCLUI_RECEBE_ADDA116_RET_RECUSADOS  
(  
	@DATAMOVTO DATETIME, 
	@NUMPEDIDO NUMERIC(10, 0), 
	@CODPROCESSA CHAR(1), 
	@TIPORETORNO CHAR(2), 
	@NOMEARQRET VARCHAR(255), 
	@DATAHORADDA DATETIME,
	@NUMIDENTCBAIXA NUMERIC(19, 0), 
	@DATAHORABAIXA DATETIME, 
	@MOTIVOCANCELAMENTO VARCHAR(3), --CODMOTIVO
	@SEQ_RECEBE NUMERIC(15, 0) OUTPUT  
) AS BEGIN  

	/*
		02/03/2023 - RFAQUINI - CRIAÇÃO (CATÁLOGO 5.06 - Modernização da Cobrança)
	*/

	INSERT INTO RECEBE_ADDA116_RET_RECUSADOS(
		DATAMANUTENCAO, CODREJEICAO, DATAMOVTO, NUMPEDIDO, 
		CODPROCESSA, TIPORETORNO, NOMEARQRET, DATAHORADDA,
		NUMIDENTCBAIXA, DATAHORACANCELAMENTOBAIXA, CODMOTIVO, 
		INDIMPORTACAOVALIDA
	) VALUES (
		GETDATE(), NULL, @DATAMOVTO, @NUMPEDIDO, 
		@CODPROCESSA, @TIPORETORNO, @NOMEARQRET, @DATAHORADDA,
		@NUMIDENTCBAIXA, @DATAHORABAIXA, @MOTIVOCANCELAMENTO, 
		CASE  
			WHEN @TIPORETORNO = 'M' 
				THEN 'S'  
			ELSE 
				NULL  
		END  
	)  

	SELECT @SEQ_RECEBE = @@IDENTITY  
END 
GO

INSERT INTO VERSAO_SISTEMA (
	[VERSAO], 
	[NOMESCRIPT], 
	[CODUSUARIO], 
	[DATAATU]
)
SELECT 
	'V15_01_1_01B', 
	'SP_INCLUI_RECEBE_ADDA116_RET_RECUSADOS', 
	SYSTEM_USER, 
	GETDATE() 
GO