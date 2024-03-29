﻿USE AB_DDA
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_PROCESSA_DDA0116R1_ADDA116RET')
BEGIN
	EXEC ('CREATE PROCEDURE dbo.SP_PROCESSA_DDA0116R1_ADDA116RET AS BEGIN RETURN END')
END
GO

ALTER PROCEDURE dbo.SP_PROCESSA_DDA0116R1_ADDA116RET(  
	@P_TIMEOUT INT, 
	@P_SQLERRO INT OUT  
) AS BEGIN  

	/*  
		06/03/2023 - RFAQUINI - CRIAÇÃO (CATÁLOGO 5.06 - Modernização da Cobrança)
		
		08/03/2023 - RFAQUINI - ALTERAÇÃO PARA MARCAR COMO REJEITADOS
			
		MARCACOES DIFERENCIADAS (CODPROCESSA)  

		"4" - DUPLICIDADE DE RECEBIMENTO (APENAS O MAIS RECENTE GERA ATUALIZACAO NA BASE)  

		DOMINIOS DE REJEICOES (CODREJEICAO)  

		'06' - PEDIDO CORRESPONDENTE NAO ENCONTRADO  
		'01' - MANUTENCAO DE TITULO NAO CADASTRADO  
		'23' - BAIXA OPERACIONAL NAO ENCONTRADA  
		'24' - BAIXA OPERACIONAL JA CONSTA COMO CANCELADA  
		
		---------------------------------------------------------------------------------------------------------------------------------------------
		 09/03/2023 - Eliane - A partir da Modernização, a devolução da baixa será feita pela IF DESTINATÁRIA pela DDA0116/ADDA116.Não mais pelo SGC.   
		                       Esta primeira versão da procedure vai procurar o título no DDA Gerenciador e estornar a baixa integral de for um 
		                       título do Sistema de Cobrança da própria IF, pois agora ele é baiaxado pela DDA0108.                     
		---------------------------------------------------------------------------------------------------------------------------------------------  
	*/
	DECLARE 
		@DATAULTPROCESSAMENTO DATETIME, 
		@DATAPROCESSAMENTO DATETIME, 
		@TIMESTAMP DATETIME, 
		@SQLERRO INTEGER, 
		@VRSMANUAL VARCHAR (07) 

	SELECT 
		@DATAULTPROCESSAMENTO = DATAULTPROCESSAMENTO, 
		@DATAPROCESSAMENTO = DATAPROCESSAMENTO, 
		@TIMESTAMP = GETDATE()  
	FROM PARAMETROS 
	WHERE CODSISTEMA = 'DDA-AUTK'  

	SELECT 
		@VRSMANUAL = VRSMANUAL 
	FROM VWIB_VRSMANUAL WITH (NOLOCK)  

	-- DELETA RESERVAS POR TIMEOUT  
	DELETE FROM TEMP_RECEBE_ADDA116_RET_RECUSADOS 
	WHERE DATAHORAPROC < DATEADD(MINUTE, -(@P_TIMEOUT), @TIMESTAMP)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	DELETE FROM TEMP_RECEBE_ADDA116_RET_ACEITOS 
	WHERE DATAHORAPROC < DATEADD(MINUTE, -(@P_TIMEOUT), @TIMESTAMP)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	-- TRATAMENTO DE RECUSAS   
	-- BUSCA PELO QUE ESTA PENDENTE  
	SELECT RECEBE_ADDA116_RET_RECUSADOS.* 
		INTO #TEMP_RECUSADOS 
	FROM RECEBE_ADDA116_RET_RECUSADOS
	WHERE RECEBE_ADDA116_RET_RECUSADOS.CODPROCESSA = '0' 
	AND RECEBE_ADDA116_RET_RECUSADOS.DATAMOVTO >= @DATAULTPROCESSAMENTO 
	AND RECEBE_ADDA116_RET_RECUSADOS.DATAMOVTO <= @DATAPROCESSAMENTO   
	AND RECEBE_ADDA116_RET_RECUSADOS.INDIMPORTACAOVALIDA = 'S'  

	-- REMOVE O QUE AINDA ESTA RESERVADO  
	DELETE #TEMP_RECUSADOS 
	FROM #TEMP_RECUSADOS 
		INNER JOIN TEMP_RECEBE_ADDA116_RET_RECUSADOS
	ON (#TEMP_RECUSADOS.SEQ_RECEBE = TEMP_RECEBE_ADDA116_RET_RECUSADOS.SEQ_RECEBE   
	AND #TEMP_RECUSADOS.NUMPEDIDO = TEMP_RECEBE_ADDA116_RET_RECUSADOS.NUMPEDIDO   
	AND #TEMP_RECUSADOS.DATAMOVTO = TEMP_RECEBE_ADDA116_RET_RECUSADOS.DATAMOVTO)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	-- RESERVA O QUE ESTIVER LIVRE  
	INSERT INTO TEMP_RECEBE_ADDA116_RET_RECUSADOS (
		SEQ_RECEBE, NUMPEDIDO, DATAMOVTO, DATAHORAPROC
	)  
	SELECT 
		SEQ_RECEBE, NUMPEDIDO, DATAMOVTO, @TIMESTAMP 
	FROM #TEMP_RECUSADOS  

	-- PK DUPLICADA, PROCESSOS SIMULTANEOS?  
	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	IF EXISTS(SELECT 1 FROM #TEMP_RECUSADOS)  
	BEGIN  
	-- COD REJEICAO "06" PARA RECEBES SEM MANUTS CORRESPONDENTES  
		UPDATE #TEMP_RECUSADOS SET 
			CODREJEICAO = '06', 
			CODPROCESSA = '2' 
		FROM #TEMP_RECUSADOS   
		WHERE NOT EXISTS (SELECT 1 
					FROM MANUT_TITULOS 
					WHERE MANUT_TITULOS.SITUACAOPEDIDO = '2' 
					AND MANUT_TITULOS.TIPOMANUTENCAOTIT = 'D'  
					AND MANUT_TITULOS.NUMPEDIDO = #TEMP_RECUSADOS.NUMPEDIDO  
					AND ISNULL(MANUT_TITULOS.NOMEARQRET, '') = ISNULL(#TEMP_RECUSADOS.NOMEARQRET, '')  
		)  

		SELECT @SQLERRO = @@ERROR     
		IF @SQLERRO <> 0 GOTO TRATAERRO  

		-- NENHUMA OUTRA REJEICAO, O RESTO PODE SER DADO COMO PROCESSADO E ACEITO  
		UPDATE #TEMP_RECUSADOS SET 
			CODPROCESSA = '1' 
		WHERE CODPROCESSA = '0' 
		AND CODREJEICAO IS NULL  

		SELECT @SQLERRO = @@ERROR     
		IF @SQLERRO <> 0 GOTO TRATAERRO  

		-- APLICANDO RESULTADOS  
		BEGIN TRANSACTION     
			-- RECEBES PROCESSADAS  
			UPDATE RECEBE_ADDA116_RET_RECUSADOS SET 
				CODPROCESSA = #TEMP_RECUSADOS.CODPROCESSA, 
				CODREJEICAO = #TEMP_RECUSADOS.CODREJEICAO, 
				DATAMANUTENCAO = @TIMESTAMP  
			FROM RECEBE_ADDA116_RET_RECUSADOS  
				INNER JOIN #TEMP_RECUSADOS 
			ON (#TEMP_RECUSADOS.SEQ_RECEBE = RECEBE_ADDA116_RET_RECUSADOS.SEQ_RECEBE   
			AND #TEMP_RECUSADOS.NUMPEDIDO = RECEBE_ADDA116_RET_RECUSADOS.NUMPEDIDO  
			AND #TEMP_RECUSADOS.DATAMOVTO = RECEBE_ADDA116_RET_RECUSADOS.DATAMOVTO)  

			SELECT @SQLERRO = @@ERROR     
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS  

			-- MANUTS PROCESSADAS  
			UPDATE MANUT_TITULOS SET 
				SITUACAOPEDIDO = '5', 
				CODRETORNO = '1'  
			FROM MANUT_TITULOS 
				INNER JOIN #TEMP_RECUSADOS
			ON (#TEMP_RECUSADOS.CODPROCESSA = '1' 
			AND MANUT_TITULOS.SITUACAOPEDIDO = '2'  
			AND #TEMP_RECUSADOS.NUMPEDIDO = MANUT_TITULOS.NUMPEDIDO  
			AND ISNULL(#TEMP_RECUSADOS.NOMEARQRET, '') = ISNULL(MANUT_TITULOS.NOMEARQRET, ''))  

			SELECT @SQLERRO = @@ERROR     
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS  

		COMMIT TRANSACTION  

	END  

	-- TRATAMENTO DE ACEITOS  
	-- BUSCA O QUE ESTA PENDENTE  
	SELECT RECEBE_ADDA116_RET_ACEITOS.* 
		INTO #TEMP_ACEITOS 
	FROM RECEBE_ADDA116_RET_ACEITOS 
	WHERE RECEBE_ADDA116_RET_ACEITOS.CODPROCESSA = '0' 
	AND RECEBE_ADDA116_RET_ACEITOS.DATAMOVTO >= @DATAULTPROCESSAMENTO 
	AND RECEBE_ADDA116_RET_ACEITOS.DATAMOVTO <= @DATAPROCESSAMENTO   
	AND RECEBE_ADDA116_RET_ACEITOS.INDIMPORTACAOVALIDA = 'S'  

	-- REMOVE O QUE AINDA ESTA RESERVADO  
	DELETE #TEMP_ACEITOS
	FROM #TEMP_ACEITOS 
		INNER JOIN TEMP_RECEBE_ADDA116_RET_ACEITOS
	ON (#TEMP_ACEITOS.SEQ_RECEBE = TEMP_RECEBE_ADDA116_RET_ACEITOS.SEQ_RECEBE   
	AND #TEMP_ACEITOS.NUMPEDIDO = TEMP_RECEBE_ADDA116_RET_ACEITOS.NUMPEDIDO  
	AND #TEMP_ACEITOS.DATAMOVTO = TEMP_RECEBE_ADDA116_RET_ACEITOS.DATAMOVTO)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	-- RESERVA O QUE ESTA LIVRE  
	INSERT INTO TEMP_RECEBE_ADDA116_RET_ACEITOS (
		SEQ_RECEBE, NUMPEDIDO, DATAMOVTO, DATAHORAPROC
	)  
	SELECT 
		#TEMP_ACEITOS.SEQ_RECEBE, #TEMP_ACEITOS.NUMPEDIDO, #TEMP_ACEITOS.DATAMOVTO, @TIMESTAMP 
	FROM #TEMP_ACEITOS 

	-- PK DUPLICADA, PROCESSOS SIMULTANEOS?  
	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	IF EXISTS(SELECT 1 FROM #TEMP_ACEITOS)  
	BEGIN  
	-- CRIANDO UMA TABELA DE TRABALHO DE MANUTS  
	SELECT MANUT_TITULOS.* 
		INTO #TEMP_MANUT 
	FROM MANUT_TITULOS  
	WHERE EXISTS (SELECT 1 
			FROM #TEMP_ACEITOS 
			WHERE MANUT_TITULOS.SITUACAOPEDIDO = '2' 
			AND #TEMP_ACEITOS.NUMPEDIDO = MANUT_TITULOS.NUMPEDIDO)  

	/** REJEICOES */  

	-- COD REJEICAO "06" PARA RECEBES SEM MANUT CORRESPONDENTE  
	UPDATE #TEMP_ACEITOS SET 
		CODREJEICAO = '06', 
		CODPROCESSA = '2' 
	FROM #TEMP_ACEITOS 
	WHERE NOT EXISTS (SELECT 1 
				FROM MANUT_TITULOS 
				WHERE MANUT_TITULOS.SITUACAOPEDIDO = '2' 
				AND MANUT_TITULOS.TIPOMANUTENCAOTIT = 'D'  
				AND #TEMP_ACEITOS.NUMPEDIDO = MANUT_TITULOS.NUMPEDIDO  
				AND ISNULL(MANUT_TITULOS.NOMEARQRET, '') = ISNULL(#TEMP_ACEITOS.NOMEARQRET, ''))  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

        /*-------------------------------------------------------------------------------------------------*/
        /* Vamos retirar esta validação porque a R1 de uma 116 pode chegar, independente de termos a BAIXA */
        /* como nos ambientes onde o DDAMensageria não é AUTK e não temos acesso a elas!      INICIO       */
        /*-------------------------------------------------------------------------------------------------*/
        
	-- COD REJEICAO "23" PARA PEDIDOS DE UMA BAIXA NAO ENCONTRADA  
	--UPDATE #TEMP_ACEITOS SET 
	--	CODREJEICAO = '23', 
	--	CODPROCESSA = '2' 
	--FROM #TEMP_ACEITOS 
	--WHERE CODPROCESSA = '0' 
	--AND CODREJEICAO IS NULL 
	--AND NOT EXISTS (SELECT 1 
	--				FROM BAIXAS_OPERACIONAIS 
	--				WHERE #TEMP_ACEITOS.NUMIDENTCBAIXA = NUMIDENTCBAIXAOPERAC 
	--				AND #TEMP_ACEITOS.NUMIDENTCDDA = NUMIDENTCDDA)  

	--SELECT @SQLERRO = @@ERROR     
	--IF @SQLERRO <> 0 GOTO TRATAERRO  

        /*-------------------------------------------------------------------------------------------------*/
        /* Vamos retirar esta validação porque a R1 de uma 116 pode chegar, independente de termos a BAIXA */
        /* como nos ambientes onde o DDAMensageria não é AUTK e não temos acesso a elas!     FIM           */
        /*-------------------------------------------------------------------------------------------------*/


	-- COD REJEICAO "24" PARA PEDIDOS DE UM TITULO COM SITUACAO DE BAIXA CANCELADA  
	UPDATE #TEMP_ACEITOS SET 
		CODREJEICAO = '24', 
		CODPROCESSA = '2' 
	FROM #TEMP_ACEITOS 
	WHERE CODPROCESSA = '0' 
	AND CODREJEICAO IS NULL 
	AND EXISTS (SELECT 1 
				FROM BAIXAS_OPERACIONAIS 
				WHERE #TEMP_ACEITOS.NUMIDENTCBAIXA = NUMIDENTCBAIXAOPERAC 
				AND DATAHORACANCEL IS NOT NULL)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	/** MARCACOES DIFERENCIADAS **/  
	-- MOVIMENTOS SERAO SEPARADOS DOS DEMAIS PARA SOMENTE RECEBEREM A MARCACAO DE PROCESSADOS AO FINAL DA PROCEDURE  

	-- CODPROCESSA "4": DUPLICIDADE DE MOVIMENTOS  
	-- SE HOUVER DUPLICIDADE NO PEDIDO, MESMA BAIXA, OS RECEBIMENTOS COM DATAHORADDA OU SEQ_RECEBE MENOR SAO SEPARADAS PARA SEREM SOMENTE MARCADAS COMO PROCESSADAS AO FINAL  
	
	SELECT MAX(#TEMP_ACEITOS.DATAHORADDA) MAX_DATAHORADDA, #TEMP_ACEITOS.NUMIDENTCBAIXA
		INTO #TEMP_MAX_DATAHORADDA 
	FROM #TEMP_ACEITOS   
	WHERE #TEMP_ACEITOS.CODPROCESSA = '0' 
	AND #TEMP_ACEITOS.CODREJEICAO IS NULL   
	GROUP BY #TEMP_ACEITOS.NUMIDENTCBAIXA 

	UPDATE #TEMP_ACEITOS SET 
		CODPROCESSA = '4' 
	FROM #TEMP_ACEITOS 
	WHERE #TEMP_ACEITOS.CODPROCESSA = '0' 
	AND #TEMP_ACEITOS.CODREJEICAO IS NULL   
	AND #TEMP_ACEITOS.DATAHORADDA < (SELECT MAX_DATAHORADDA 
						FROM #TEMP_MAX_DATAHORADDA 
						WHERE #TEMP_MAX_DATAHORADDA.NUMIDENTCBAIXA = #TEMP_ACEITOS.NUMIDENTCBAIXA)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	SELECT MAX(#TEMP_ACEITOS.SEQ_RECEBE) MAX_SEQ_RECEBE, #TEMP_ACEITOS.NUMIDENTCBAIXA
		INTO #TEMP_MAX_SEQ_RECEBE 
	FROM #TEMP_ACEITOS 
	WHERE #TEMP_ACEITOS.CODPROCESSA = '0' 
	AND #TEMP_ACEITOS.CODREJEICAO IS NULL  
	GROUP BY #TEMP_ACEITOS.NUMIDENTCBAIXA

	UPDATE #TEMP_ACEITOS SET 
		CODPROCESSA = '4' 
	FROM #TEMP_ACEITOS  
	WHERE #TEMP_ACEITOS.CODPROCESSA = '0' 
	AND #TEMP_ACEITOS.CODREJEICAO IS NULL   
	AND #TEMP_ACEITOS.SEQ_RECEBE < (SELECT MAX_SEQ_RECEBE 
						FROM #TEMP_MAX_SEQ_RECEBE  
						WHERE #TEMP_MAX_SEQ_RECEBE.NUMIDENTCBAIXAOPE = #TEMP_ACEITOS.NUMIDENTCBAIXA)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	-- SEM MAIS REJEICOES, O RESTO PODE SER DADO COMO ACEITO E PROCESSADO  
	UPDATE #TEMP_ACEITOS SET 
		CODPROCESSA = '1' 
	WHERE CODPROCESSA = '0'
	AND CODREJEICAO IS NULL  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	-- MARCANDO ANTECIPADAMENTE COMO PROCESSADO E COM O COD RETORNO CORRESPONDENTE ("0" SE NAO HOUVER REJEICAO E "1" CASO CONTRARIO)  
	UPDATE #TEMP_MANUT SET 
		SITUACAOPEDIDO 	= '5', 
		CODRETORNO 	= '1', 
		DATAHORADDA	= #TEMP_ACEITOS.DATAHORADDA 
	FROM #TEMP_MANUT  
		INNER JOIN #TEMP_ACEITOS
	ON (#TEMP_ACEITOS.CODPROCESSA = '2' 
	AND #TEMP_ACEITOS.CODREJEICAO IS NOT NULL 
	AND #TEMP_ACEITOS.NUMPEDIDO = #TEMP_MANUT.NUMPEDIDO)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	UPDATE #TEMP_MANUT SET 
		SITUACAOPEDIDO 	= '5', 
		CODRETORNO 	= '0', 
		DATAHORADDA 	= #TEMP_ACEITOS.DATAHORADDA, 
		NUMCTRLDDA 	= #TEMP_ACEITOS.NUMCTRLDDA  
	FROM #TEMP_MANUT  
		INNER JOIN #TEMP_ACEITOS
	ON (#TEMP_ACEITOS.CODPROCESSA = '1' 
	AND #TEMP_ACEITOS.CODREJEICAO IS NULL 
	AND #TEMP_ACEITOS.NUMPEDIDO = #TEMP_MANUT.NUMPEDIDO)  

	SELECT @SQLERRO = @@ERROR     
	IF @SQLERRO <> 0 GOTO TRATAERRO  

	-- APLICANDO RESULTADOS  
	BEGIN TRANSACTION    

		/*------------------------------------------------------------------------------------------------------------------------*/  
		/* 13/03/2023 - Vamos cancelar a baixa e reabrir o título no nosso DDA, se a mesma não foi aceita pela IF DESCTINATÁRIA...*/      
		/*------------------------------------------------------------------------------------------------------------------------*/  

		UPDATE BAIXAS_OPERACIONAIS  
		SET  
			NUMCTRLDDACANCEL 	= #TEMP_MANUT.NUMCTRLDDA, 
			DATAHORADDA 		= #TEMP_MANUT.DATAHORADDA, 
			DATAHORACANCEL 		= #TEMP_MANUT.DATAHORACANCELAMENTOBAIXAOPERAC, 
			ORIGEMCANCELAMENTO 	= '1', -- A PROPRIA IF ESTA CANCELANDO A BAIXA  
			SITBAIXA 		= 'C' /* CANCELADA PELO PARTICIPANTE */  
		FROM BAIXAS_OPERACIONAIS  
			INNER JOIN #TEMP_MANUT
		ON (#TEMP_MANUT.SITUACAOPEDIDO 	= '5' 
		AND #TEMP_MANUT.CODRETORNO 	= '0' 
		AND #TEMP_MANUT.NUMIDENTCBAIXAOPERAC = BAIXAS_OPERACIONAIS.NUMIDENTCBAIXAOPERAC)  

		SELECT @SQLERRO = @@ERROR     
		IF @SQLERRO <> 0 GOTO TRATAERROTRANS  

                /*-------------------------------------------------------------------------------------*/
                /* Reabrindo o título no DDAGerenciador se o mesmo chegou a ser baixado por esta BAIXA */
                /* Conferir os dados da baixa cancelada com os dados que estão no título...            */
                /*-------------------------------------------------------------------------------------*/
                
 		UPDATE TITULOS  
		SET 
		SITPAGAMENTO 		= '3',
		CODSISLEGADO 		= NULL,
		DTHRSITTITULO 		= #TEMP_MANUT.DATAHORADDA,
		
		INDCONTINGENCIA 	= NULL, 
		TIPOPESPORTADOR		= NULL, 
		CNPJ_CPF_PORTADOR 	= NULL, 
		DATAHORADDA 		= #TEMP_MANUT.DATAHORADDA,
		CODSITUACAO 		= '1', /* EM ABERTO */
		TIPOBAIXA      		= NULL,
		DATAPAGTOBAIXA 		= NULL,
		VLRPAGTOBAIXA  		= NULL
		FROM BAIXAS_OPERACIONAIS, #TEMP_MANUT
		WHERE 
		    #TEMP_MANUT.SITUACAOPEDIDO 	= '5' 
		AND #TEMP_MANUT.CODRETORNO 	= '0' 
		AND #TEMP_MANUT.NUMIDENTCBAIXAOPERAC = BAIXAS_OPERACIONAIS.NUMIDENTCBAIXAOPERAC 
		AND BAIXAS_OPERACIONAIS.NUMIDENTCDDA = TITULOS.NUMIDENTCDDA
		AND BAIXAS_OPERACIONAIS.DATABAIXA    = TITULOS.DATAPAGTOBAIXA
		AND BAIXAS_OPERACIONAIS.VLRBAIXA     = TITULOS.VLRPAGTOBAIXA 
		AND BAIXAS_OPERACIONAIS.TIPOBAIXA    = TITULOS.TIPOBAIXA

		SELECT @SQLERRO = @@ERROR     
		IF @SQLERRO <> 0 GOTO TRATAERROTRANS  
                
                /*-------------------------------------------------------------------------------------*/
                /* Reabrindo o título no DDAGerenciador se o mesmo chegou a ser baixado por esta BAIXA */
                /* Conferir os dados da baixa cancelada com os dados que estão no título...            */
                /*-------------------------------------------------------------------------------------*/


		-- RESTABELECENDO OS RECEBIMENTOS QUE FORAM MARCADOS PARA PROCESSAMENTO AO FINAL DA PROCEDURE  
		
		UPDATE #TEMP_ACEITOS SET 
			CODPROCESSA = '2',
			CODREJEICAO = '36'
		WHERE CODPROCESSA = '4'

		SELECT @SQLERRO = @@ERROR     
		IF @SQLERRO <> 0 GOTO TRATAERROTRANS  

		UPDATE #TEMP_MANUT SET 
			SITUACAOPEDIDO 	= '5', 
			CODRETORNO 	= '0', 
			DATAHORADDA 	= #TEMP_ACEITOS.DATAHORADDA, 
			NUMCTRLDDA 	= #TEMP_ACEITOS.NUMCTRLDDA  
		FROM #TEMP_MANUT   
		INNER JOIN #TEMP_ACEITOS 
		ON (#TEMP_ACEITOS.CODPROCESSA = '1' 
		AND #TEMP_ACEITOS.CODREJEICAO IS NULL 
		AND #TEMP_ACEITOS.NUMPEDIDO = #TEMP_MANUT.NUMPEDIDO)  

		SELECT @SQLERRO = @@ERROR     
		IF @SQLERRO <> 0 GOTO TRATAERRO  

		-- RECEBES PROCESSADAS  
		UPDATE RECEBE_ADDA116_RET_ACEITOS SET 
			CODPROCESSA = #TEMP_ACEITOS.CODPROCESSA, 
			CODREJEICAO = #TEMP_ACEITOS.CODREJEICAO, 
			DATAMANUTENCAO = @TIMESTAMP  
		FROM RECEBE_ADDA116_RET_ACEITOS 
		INNER JOIN #TEMP_ACEITOS  
		ON (#TEMP_ACEITOS.SEQ_RECEBE = RECEBE_ADDA116_RET_ACEITOS.SEQ_RECEBE)  

		SELECT @SQLERRO = @@ERROR     
		IF @SQLERRO <> 0 GOTO TRATAERROTRANS  

		-- MANUTS PROCESSADAS  
		UPDATE MANUT_TITULOS SET 
			SITUACAOPEDIDO 	= '5', 
			CODRETORNO 	= #TEMP_MANUT.CODRETORNO, 
			DATAHORADDA 	= #TEMP_MANUT.DATAHORADDA  
		FROM MANUT_TITULOS 
		INNER JOIN #TEMP_MANUT 
		ON (MANUT_TITULOS.DATAPEDIDO 		= #TEMP_MANUT.DATAPEDIDO 
		AND MANUT_TITULOS.DATALEGADO 		= #TEMP_MANUT.DATALEGADO  
		AND MANUT_TITULOS.CODSISLEGADO 		= #TEMP_MANUT.CODSISLEGADO 
		AND MANUT_TITULOS.NUMCTRLLEGADO 	= #TEMP_MANUT.NUMCTRLLEGADO)  

		SELECT @SQLERRO = @@ERROR     
		IF @SQLERRO <> 0 GOTO TRATAERROTRANS  

	COMMIT TRANSACTION  
	END  

	RETURN
	
	TRATAERROTRANS:  
		ROLLBACK TRANSACTION  
		GOTO TRATAERRO  

	TRATAERRO:  
		SELECT @P_SQLERRO = @SQLERRO  
	RETURN  

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
	'SP_PROCESSA_DDA0116R1_ADDA116RET', 
	SYSTEM_USER, 
	GETDATE() 
GO