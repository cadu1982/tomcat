USE AB_DDA
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_PROCESSA_DDA0108R1_ADDA108RET')
BEGIN
	EXEC ('CREATE PROCEDURE dbo.SP_PROCESSA_DDA0108R1_ADDA108RET AS BEGIN RETURN END')
END
GO

ALTER PROCEDURE DBO.SP_PROCESSA_DDA0108R1_ADDA108RET(
	@P_TIMEOUT INT, 
	@P_SQLERRO INT OUT
) AS BEGIN

	SET NOCOUNT ON
	/*
		05/02/2019 - RFAQUINI, EDUARDOK - SELECIONAR APENAS A �LTIMA BAIXA PARA ATUALIZAR EM TITULOS
										- IDENTA��O DO C�DIGO E INSER��O DE COMENT�RIOS
									   
		31/05/2019 - RFAQUINI, EDUARDOK - CORRE��O NA REFER�NCIA DE TABELA TEMPOR�RIA	

		05/11/2021 - RFAQUINI - INCLUS�O E TRATAMENTO DO CAMPO NOME_PORTADOR (CAT�LOGO 5.03)
								REMO��O DE ALIAS
								
		25/05/2022 - RFAQUINI - INCLUS�O E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CAT�LOGO 5.04)
		
		08/11/2022 - ELIANE - SALVANDO EM MANUT_TITULOS A DATAHORADDA  
		
		03/02/2023 - ELIANE, RFAQUINI - REMO��O DA VALIDA��O DE CODREJEICAO '32' 
						POR N�O TER MAIS O CONTE�DO DE NUMSEQATLZBAIXAOPERAC/ULTNUMSEQBAIXAOPERAC
										
		06 A 10/02/2023 - ELIANE, RFAQUINI - TRATAMENTO DO CAMPO NUMSEQBAIXAOPERAC (CAT�LOGO MODERNIZA��O)
		13/03/2023 - Eliane - Ajustando campos em TITULOS para as baixas definiticas, apenas. Baixas Parciais n�o devem baixar o t�tulo.
	*/

	/*
		MARCACOES DIFERENCIADAS (CODPROCESSA)

		'4' - DUPLICIDADE DE RECEBIMENTO (APENAS O MAIS RECENTE GERA ATUALIZACAO NA BASE)

		DOMINIOS DE REJEICOES (CODREJEICAO)

		'06' - PEDIDO CORRESPONDENTE NAO ENCONTRADO
		'01' - MANUTENCAO DE TITULO NAO CADASTRADO
		'32' - SEQUENCIAL DA BAIXA DESATUALIZADO EM RELACAO AO TITULO
		'26' - BAIXA JA CADASTRADA
	*/

	DECLARE 
		@DATAULTPROCESSAMENTO DATETIME, 
		@DATAPROCESSAMENTO DATETIME, 
		@TIMESTAMP DATETIME, 
		@SQLERRO INTEGER,
		@VRSMANUAL VARCHAR (07) /* 06/02/2023 */
		
	SELECT 
		@DATAULTPROCESSAMENTO = DATAULTPROCESSAMENTO, 
		@DATAPROCESSAMENTO = DATAPROCESSAMENTO, 
		@TIMESTAMP = GETDATE()
	FROM PARAMETROS 
	WHERE CODSISTEMA = 'DDA-AUTK'
	
	SELECT @VRSMANUAL = VRSMANUAL FROM VWIB_VRSMANUAL WITH (NOLOCK)  /* 06/02/2023 */

	-- DELETA RESERVAS POR TIMEOUT
	DELETE 
	FROM TEMP_RECEBE_ADDA108_RET_RECUSADOS 
	WHERE DATAHORAPROC < DATEADD(MINUTE, -(@P_TIMEOUT), @TIMESTAMP)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	DELETE 
	FROM TEMP_RECEBE_ADDA108_RET_ACEITOS 
	WHERE DATAHORAPROC < DATEADD(MINUTE, -(@P_TIMEOUT), @TIMESTAMP)

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	---------------------TRATAMENTO DE RECUSAS - INICIO------------------------
	-- BUSCA PELO QUE ESTA PENDENTE - #TEMP_RECUSADOS � AUXILIAR DA RECEBE_ADDA108_RET_RECUSADOS
	SELECT RECEBE_ADDA108_RET_RECUSADOS.* 
		INTO #TEMP_RECUSADOS 
	FROM RECEBE_ADDA108_RET_RECUSADOS 
	WHERE RECEBE_ADDA108_RET_RECUSADOS.CODPROCESSA = '0' 
	AND RECEBE_ADDA108_RET_RECUSADOS.DATAMOVTO >= @DATAULTPROCESSAMENTO 
	AND RECEBE_ADDA108_RET_RECUSADOS.DATAMOVTO <= @DATAPROCESSAMENTO 
	AND RECEBE_ADDA108_RET_RECUSADOS.INDIMPORTACAOVALIDA = 'S'

	-- REMOVE DAS PENDENTES O QUE AINDA ESTA RESERVADO
	DELETE #TEMP_RECUSADOS 
	FROM #TEMP_RECUSADOS 
	INNER JOIN TEMP_RECEBE_ADDA108_RET_RECUSADOS TEMP_RECEBE 
		ON (#TEMP_RECUSADOS.SEQ_RECEBE = TEMP_RECEBE.SEQ_RECEBE 
		AND #TEMP_RECUSADOS.NUMPEDIDO = TEMP_RECEBE.NUMPEDIDO 
		AND #TEMP_RECUSADOS.DATAMOVTO = TEMP_RECEBE.DATAMOVTO)

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	-- RESERVA O QUE ESTIVER LIVRE => CONTEUDO DA (RECEBE_ADDA108_RET_RECUSADOS - TEMP_RECEBE_ADDA108_RET_RECUSADOS)
	INSERT INTO TEMP_RECEBE_ADDA108_RET_RECUSADOS (
		SEQ_RECEBE, NUMPEDIDO, DATAMOVTO, DATAHORAPROC
	)
	SELECT 
		SEQ_RECEBE, NUMPEDIDO, DATAMOVTO, @TIMESTAMP 
	FROM #TEMP_RECUSADOS

	-- PK DUPLICADA, PROCESSOS SIMULTANEOS?
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO


	IF EXISTS(SELECT 1 FROM #TEMP_RECUSADOS) --1) SE EXISTE ALGO NA AUXILIAR
	BEGIN
		--2) COD REJEICAO "06" PARA RECEBES SEM MANUTS CORRESPONDENTES - '06' - PEDIDO CORRESPONDENTE NAO ENCONTRADO
		--31/05/2019 - RFAQUINI/EDUARDOK - CORRE��O NA REFER�NCIA DE TABELA TEMPOR�RIA
		UPDATE #TEMP_RECUSADOS SET 
			CODREJEICAO = '06', 
		    CODPROCESSA = '2' 
		FROM #TEMP_RECUSADOS
		WHERE NOT EXISTS (SELECT 1 
				  FROM MANUT_TITULOS  
				  WHERE MANUT_TITULOS.SITUACAOPEDIDO = '2' 
				  AND MANUT_TITULOS.TIPOMANUTENCAOTIT = 'B'
				  AND MANUT_TITULOS.NUMPEDIDO = #TEMP_RECUSADOS.NUMPEDIDO
				  AND ISNULL(MANUT_TITULOS.NOMEARQRET, '') = ISNULL(#TEMP_RECUSADOS.NOMEARQRET, '')
		)

		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO

		--3) NENHUMA OUTRA REJEICAO, O RESTO PODE SER DADO COMO PROCESSADO E ACEITO
		UPDATE #TEMP_RECUSADOS SET 
			CODPROCESSA = '1'
		WHERE CODPROCESSA = '0'
		AND CODREJEICAO IS NULL

		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO
	
		-- APLICANDO RESULTADOS
		BEGIN TRANSACTION
  
			--4) DESBLOQUEIO PRA PAGAMENTO DO TITULO
			UPDATE TITULOS SET 
				SITPAGAMENTO = NULL, 
			    CODSISLEGADO = NULL
			FROM TITULOS
			INNER JOIN #TEMP_RECUSADOS 
				ON (TITULOS.NUMIDENTCDDA = #TEMP_RECUSADOS.NUMIDENTCDDA)

			SELECT @SQLERRO = @@ERROR		 
				IF @SQLERRO <> 0 GOTO TRATAERROTRANS		
					
			--5) ATUALIZA REJEICOES NA RECEBE RECUSADA
			UPDATE RECEBE_ADDA108_RET_RECUSADOS SET 
				CODPROCESSA = #TEMP_RECUSADOS.CODPROCESSA, 
			    CODREJEICAO = #TEMP_RECUSADOS.CODREJEICAO, 
				DATAMANUTENCAO = @TIMESTAMP
			FROM RECEBE_ADDA108_RET_RECUSADOS 
			INNER JOIN #TEMP_RECUSADOS 
				ON (#TEMP_RECUSADOS.SEQ_RECEBE = RECEBE_ADDA108_RET_RECUSADOS.SEQ_RECEBE 
				AND #TEMP_RECUSADOS.NUMPEDIDO = RECEBE_ADDA108_RET_RECUSADOS.NUMPEDIDO
				AND #TEMP_RECUSADOS.DATAMOVTO = RECEBE_ADDA108_RET_RECUSADOS.DATAMOVTO)

			SELECT @SQLERRO = @@ERROR		 
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS

			--6) PROCESSAR MANUTS 
			UPDATE MANUT_TITULOS SET 
				SITUACAOPEDIDO = '5', --PROCESSADO
			    CODRETORNO = '1'--REJEITADO
			FROM MANUT_TITULOS 
			INNER JOIN #TEMP_RECUSADOS 
				ON (#TEMP_RECUSADOS.CODPROCESSA = '1'
				AND MANUT_TITULOS.SITUACAOPEDIDO = '2'--IMPORTADO MAS NAO PROCESSADO
				AND #TEMP_RECUSADOS.NUMPEDIDO = MANUT_TITULOS.NUMPEDIDO
				AND ISNULL(#TEMP_RECUSADOS.NOMEARQRET, '') = ISNULL(MANUT_TITULOS.NOMEARQRET, ''))

			SELECT @SQLERRO = @@ERROR		 
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS

		COMMIT TRANSACTION
		
	END
	----------------------TRATAMENTO DE RECUSAS - FIM------------------------

	--------------------- TRATAMENTO DE ACEITOS - INICIO---------------------
	-- BUSCA O QUE ESTA PENDENTE
	SELECT RECEBE_ADDA108_RET_ACEITOS.* 
		INTO #TEMP_ACEITOS 
	FROM RECEBE_ADDA108_RET_ACEITOS 
	WHERE RECEBE_ADDA108_RET_ACEITOS.CODPROCESSA = '0' 
	AND RECEBE_ADDA108_RET_ACEITOS.DATAMOVTO >= @DATAULTPROCESSAMENTO 
	AND RECEBE_ADDA108_RET_ACEITOS.DATAMOVTO <= @DATAPROCESSAMENTO 
	AND RECEBE_ADDA108_RET_ACEITOS.INDIMPORTACAOVALIDA = 'S'

	-- REMOVE O QUE AINDA ESTA RESERVADO
	DELETE #TEMP_ACEITOS  
	FROM #TEMP_ACEITOS 
	INNER JOIN TEMP_RECEBE_ADDA108_RET_ACEITOS  
		ON (#TEMP_ACEITOS.SEQ_RECEBE = TEMP_RECEBE_ADDA108_RET_ACEITOS.SEQ_RECEBE 
		AND #TEMP_ACEITOS.NUMPEDIDO = TEMP_RECEBE_ADDA108_RET_ACEITOS.NUMPEDIDO
		AND #TEMP_ACEITOS.DATAMOVTO = TEMP_RECEBE_ADDA108_RET_ACEITOS.DATAMOVTO)

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	-- RESERVA O QUE ESTA LIVRE
	INSERT INTO TEMP_RECEBE_ADDA108_RET_ACEITOS(
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
		WHERE EXISTS (SELECT * 
						FROM #TEMP_ACEITOS  
						WHERE MANUT_TITULOS.SITUACAOPEDIDO = '2' 
						AND #TEMP_ACEITOS.NUMPEDIDO = MANUT_TITULOS.NUMPEDIDO)

		/** REJEICOES **/

		-- COD REJEICAO "06" PARA RECEBES SEM MANUT CORRESPONDENTE
		UPDATE #TEMP_ACEITOS SET 
			CODREJEICAO = '06', 
		    CODPROCESSA = '2' 
		FROM #TEMP_ACEITOS
		WHERE NOT EXISTS (SELECT 1 
							FROM MANUT_TITULOS  
							WHERE MANUT_TITULOS.SITUACAOPEDIDO = '2' 
							AND MANUT_TITULOS.TIPOMANUTENCAOTIT = 'B'
							AND #TEMP_ACEITOS.NUMPEDIDO = MANUT_TITULOS.NUMPEDIDO)

		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO

		-- COD REJEICAO "01" PARA PEDIDOS DE UM TITULO NAO CADASTRADO
		UPDATE #TEMP_ACEITOS SET 
			CODREJEICAO = '01', 
		    CODPROCESSA = '2' 
		FROM #TEMP_ACEITOS 
		WHERE CODPROCESSA = '0' 
		AND CODREJEICAO IS NULL 
		AND NOT EXISTS (SELECT 1 
						FROM TITULOS 
						WHERE TITULOS.NUMIDENTCDDA = #TEMP_ACEITOS.NUMIDENTCDDA)

		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO

                /*----------------------------------------------------------------------------------------*/
                /* 03/02/2023 - ELIANE, RFAQUINI - REMO��O DA VALIDA��O DE CODREJEICAO '32'               */
		/*              POR N�O TER MAIS O CONTE�DO DE NUMSEQATLZBAIXAOPERAC/ULTNUMSEQBAIXAOPERAC */
		/*              A PARTIR DO CAT�LOGO DA MODERNIZA��O.                                     */
		/*                                                                                        */
		/*   CODREJEICAO "32" PARA RECEBES COM NUMERO DE SEQUENCIA INFERIOR AO JA CADASTRADO      */
	        /*----------------------------------------------------------------------------------------*/
              
                IF @VRSMANUAL <= '5.05'  
                
                BEGIN /* Catalogo anterior � MODERNIZA��O */
                
                  UPDATE #TEMP_ACEITOS SET 
		         #TEMP_ACEITOS.CODREJEICAO = CASE WHEN #TEMP_ACEITOS.NUMSEQBAIXAOPERAC > ISNULL(TITULOS.ULTNUMSEQBAIXAOPERAC, -1) 
		  					THEN NULL 
		  					ELSE '32' 
		  				   END, 
		         #TEMP_ACEITOS.CODPROCESSA = CASE WHEN #TEMP_ACEITOS.NUMSEQBAIXAOPERAC > ISNULL(TITULOS.ULTNUMSEQBAIXAOPERAC, -1)
		  					THEN '0' 
		  					ELSE '2' 
		  				   END
		  FROM TITULOS 
		  INNER JOIN #TEMP_ACEITOS  
		  	ON (TITULOS.NUMIDENTCDDA = #TEMP_ACEITOS.NUMIDENTCDDA)
		  WHERE #TEMP_ACEITOS.CODREJEICAO IS NULL
		  
		  SELECT @SQLERRO = @@ERROR		 
		  IF @SQLERRO <> 0 GOTO TRATAERRO
		  
                END   /* Catalogo anterior � MODERNIZA��O */
	        /*----------------------------------------------------------------------------------------*/
	        /* FIM DO TRECHO....                                                                      */
	        /*----------------------------------------------------------------------------------------*/
		
		-- CODREJEICAO "26" PARA BAIXAS JA CADASTRADAS
		UPDATE #TEMP_ACEITOS
		SET CODREJEICAO = '26', 
		    CODPROCESSA = '2' 
		FROM #TEMP_ACEITOS 
		INNER JOIN BAIXAS_OPERACIONAIS BAIXAS
		 ON (
			#TEMP_ACEITOS.CODPROCESSA = '0'
			AND #TEMP_ACEITOS.CODREJEICAO IS NULL 
			AND #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC = BAIXAS.NUMIDENTCBAIXAOPERAC
			AND #TEMP_ACEITOS.NUMIDENTCDDA = BAIXAS.NUMIDENTCDDA
		)

		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO

		/** MARCACOES DIFERENCIADAS **/
		-- MOVIMENTOS SERAO SEPARADOS DOS DEMAIS PARA SOMENTE RECEBEREM A MARCACAO DE PROCESSADOS AO FINAL DA PROCEDURE

		-- CODPROCESSA "4": DUPLICIDADE DE MOVIMENTOS
		-- SE HOUVER DUPLICIDADE NO PEDIDO, MESMA BAIXA, OS RECEBIMENTOS COM DATAHORADDA OU SEQ_RECEBE MENOR SAO SEPARADAS 
		-- PARA SEREM SOMENTE MARCADAS COMO PROCESSADAS AO FINAL
		
		SELECT MAX(#TEMP_ACEITOS.DATAHORADDA) MAX_DATAHORADDA, #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC
			INTO #TEMP_MAX_DATAHORADDA
		FROM #TEMP_ACEITOS 
		WHERE #TEMP_ACEITOS.CODPROCESSA = '0'
		AND #TEMP_ACEITOS.CODREJEICAO IS NULL 
		GROUP BY #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC

		UPDATE #TEMP_ACEITOS SET 
			CODPROCESSA = '4'
		FROM #TEMP_ACEITOS 
		WHERE #TEMP_ACEITOS.CODPROCESSA = '0'
		AND #TEMP_ACEITOS.CODREJEICAO IS NULL 
		AND #TEMP_ACEITOS.DATAHORADDA < (SELECT MAX_DATAHORADDA 
							FROM #TEMP_MAX_DATAHORADDA 
							WHERE #TEMP_MAX_DATAHORADDA.NUMIDENTCBAIXAOPERAC = #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC)
		
		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO

		SELECT MAX(#TEMP_ACEITOS.SEQ_RECEBE) MAX_SEQ_RECEBE, #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC
			INTO #TEMP_MAX_SEQ_RECEBE
		FROM #TEMP_ACEITOS 
		WHERE #TEMP_ACEITOS.CODPROCESSA = '0'
		AND #TEMP_ACEITOS.CODREJEICAO IS NULL
		GROUP BY #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC 
		
		UPDATE #TEMP_ACEITOS SET 
			CODPROCESSA = '4'
		FROM #TEMP_ACEITOS 
		WHERE #TEMP_ACEITOS.CODPROCESSA = '0'
		AND #TEMP_ACEITOS.CODREJEICAO IS NULL 
		AND #TEMP_ACEITOS.SEQ_RECEBE < (SELECT MAX_SEQ_RECEBE
							FROM #TEMP_MAX_SEQ_RECEBE 
							WHERE #TEMP_MAX_SEQ_RECEBE.NUMIDENTCBAIXAOPERAC = #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC)

		SELECT @SQLERRO = @@ERROR		 
			IF @SQLERRO <> 0 GOTO TRATAERRO

		-- SEM MAIS REJEICOES, O RESTO PODE SER DADO COMO ACEITO E PROCESSADO
		UPDATE #TEMP_ACEITOS 
			SET CODPROCESSA = '1' 
		WHERE CODPROCESSA = '0' 
		AND CODREJEICAO IS NULL

		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO

		-- MARCANDO ANTECIPADAMENTE COMO PROCESSADO E COM O COD RETORNO CORRESPONDENTE ("0" SE NAO HOUVER REJEICAO E "1" CASO CONTRARIO)
		UPDATE #TEMP_MANUT SET 
			SITUACAOPEDIDO = '5', 
		    CODRETORNO = '1'
		FROM #TEMP_MANUT 
		INNER JOIN #TEMP_ACEITOS  
			ON (#TEMP_ACEITOS.CODPROCESSA = '2' 
			AND #TEMP_ACEITOS.CODREJEICAO IS NOT NULL 
			AND #TEMP_ACEITOS.NUMPEDIDO = #TEMP_MANUT.NUMPEDIDO)

		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO

		UPDATE #TEMP_MANUT SET 
			SITUACAOPEDIDO = '5', 
			CODRETORNO = '0'
		FROM #TEMP_MANUT 
		INNER JOIN #TEMP_ACEITOS  
			ON (#TEMP_ACEITOS.CODPROCESSA = '1' 
			AND #TEMP_ACEITOS.CODREJEICAO IS NULL 
			AND #TEMP_ACEITOS.NUMPEDIDO = #TEMP_MANUT.NUMPEDIDO)

		SELECT @SQLERRO = @@ERROR		 
		IF @SQLERRO <> 0 GOTO TRATAERRO


                /*----------------------------------------------------------------------------------------------*/
                /* 06/02/2023 - Eliane.                                                                         */
                /* Este �po de atualiza��o de controles baseado na maior sequencia de baixa s� funciona at� o   */
                /* catalogo 5.05, pois na Moderniza��o sumiram NumRefAtlBaixaOperac e NumSeqAtlzBaixaOperac.    */
                /* Num baixa, a CIP n�o altera NUMIDENTCDDA e o NUMREFCATTIT n�o s�o alterados numa BAIXA!      */
                /*----------------------------------------------------------------------------------------------*/
                

		--MAX_SEQ_BAIXAOPERAC POR T�TULO
		--06/02/2023 - ELIANE, RFAQUINI - TRATAMENTO DO CAMPO NUMSEQBAIXAOPERAC (CAT�LOGO MODERNIZA��O)
		SELECT MAX(ISNULL(#TEMP_ACEITOS.NUMSEQBAIXAOPERAC, 0)) NUMSEQBAIXAOPERAC, #TEMP_ACEITOS.NUMIDENTCDDA NUMIDENTCDDA
			INTO #TEMP_MAX_NUMSEQBAIXAOPERAC
		FROM #TEMP_ACEITOS 
		INNER JOIN MANUT_TITULOS 
			ON (#TEMP_ACEITOS.NUMIDENTCDDA = MANUT_TITULOS.NUMIDENTCDDA)
		WHERE #TEMP_ACEITOS.CODPROCESSA = '1'
		AND #TEMP_ACEITOS.CODREJEICAO IS NULL
		GROUP BY #TEMP_ACEITOS.NUMIDENTCDDA
		

		
                /*----------------------------------------------------------------------------------------------*/
                /* 06/02/2023 - Eliane.  Selecionando a mais recente baixa do t�tulo, que pode ser DEVOLU��O... */
                /* INICIO DO TRECHO.                                                                            */
                /*----------------------------------------------------------------------------------------------*/
                
		--MAX_NUMIDENTCBAIXA POR T�TULO - MODERNIZA��O
		--06/02/2023 - ELIANE - TRATAMENTO DO CAMPO NUMIDENTBAIXAOPERAC (CAT�LOGO MODERNIZA��O)
		SELECT MAX(#TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC) NUMIDENTCBAIXAOPERAC, #TEMP_ACEITOS.NUMIDENTCDDA NUMIDENTCDDA
			INTO #TEMP_MAX_NUMIDENTCBAIXAOPERAC
		FROM #TEMP_ACEITOS 
		INNER JOIN MANUT_TITULOS 
			ON (#TEMP_ACEITOS.NUMIDENTCDDA = MANUT_TITULOS.NUMIDENTCDDA)
		WHERE #TEMP_ACEITOS.CODPROCESSA = '1'
		AND #TEMP_ACEITOS.CODREJEICAO IS NULL
		GROUP BY #TEMP_ACEITOS.NUMIDENTCDDA
		
                /*----------------------------------------------------------------------------------------------*/
                /* 06/02/2023 - Eliane.  Selecionando a mais recente baixa do t�tulo, que pode ser DEVOLU��O... */
                /* FIM DO TRECHO.                                                                               */
                /*----------------------------------------------------------------------------------------------*/
		
	
		-- APLICANDO RESULTADOS
		BEGIN TRANSACTION	
			
			/* RETORNOS ACEITOS */	
			
                  IF @VRSMANUAL <= '5.05'  
                
                     BEGIN /* Catalogo anterior � MODERNIZA��O - SOMENTE AVISO DE LIQUIDA��O */

			UPDATE TITULOS SET 
				ULTNUMREFBAIXAOPERAC = #TEMP_ACEITOS.NUMREFBAIXAOPERAC, 
				--06/02/2023 - ELIANE, RFAQUINI - TRATAMENTO DO CAMPO NUMSEQBAIXAOPERAC (CAT�LOGO MODERNIZA��O)
				ULTNUMSEQBAIXAOPERAC = ISNULL(#TEMP_ACEITOS.NUMSEQBAIXAOPERAC, 0),
				INDCONTINGENCIA = #TEMP_MANUT.INDCONTINGENCIA, 
				TIPOPESPORTADOR	= #TEMP_MANUT.TIPOPESPORTADOR, 
				CNPJ_CPF_PORTADOR = #TEMP_MANUT.CNPJ_CPF_PORTADOR, 
				SITPAGAMENTO = '2', /* SITUACAO "BAIXA ENVIADA" */
				DATAHORADDA = #TEMP_ACEITOS.DATAHORADDA
			FROM TITULOS
			INNER JOIN #TEMP_MANUT 
				ON (#TEMP_MANUT.CODRETORNO = '0'
				AND #TEMP_MANUT.NUMIDENTCDDA = TITULOS.NUMIDENTCDDA)
			INNER JOIN #TEMP_ACEITOS 
				ON (#TEMP_ACEITOS.CODPROCESSA = '1' 
				AND #TEMP_ACEITOS.CODREJEICAO IS NULL
				AND #TEMP_MANUT.NUMPEDIDO = #TEMP_ACEITOS.NUMPEDIDO)
			--ATUALIZAR APENAS PARA A �LTIMA MANUTEN��O DE BAIXA RECEBIDA--05/02/2019
			INNER JOIN #TEMP_MAX_NUMSEQBAIXAOPERAC 
				ON(#TEMP_MAX_NUMSEQBAIXAOPERAC.NUMIDENTCDDA = #TEMP_MANUT.NUMIDENTCDDA 
			--06/02/2023 - ELIANE, RFAQUINI - TRATAMENTO DO CAMPO NUMSEQBAIXAOPERAC (CAT�LOGO MODERNIZA��O)
				AND ISNULL(#TEMP_ACEITOS.NUMSEQBAIXAOPERAC, 0) = ISNULL(#TEMP_MAX_NUMSEQBAIXAOPERAC.NUMSEQBAIXAOPERAC, 0))

			SELECT @SQLERRO = @@ERROR		 
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS
			
                     END   /* Catalogo anterior � MODERNIZA��O */
                   
                   ELSE
                     BEGIN /* Moderniza��o em diante LIQUIDA��O OU BAIXA EFETIVAMENTE. */
			
			UPDATE TITULOS SET 
			        ULTNUMREFBAIXAOPERAC = #TEMP_ACEITOS.NUMREFBAIXAOPERAC,
			        ULTNUMSEQBAIXAOPERAC = ISNULL(#TEMP_ACEITOS.NUMSEQBAIXAOPERAC, 0),
				INDCONTINGENCIA = CASE WHEN #TEMP_MANUT.TIPOBAIXA IN ('2','3','10','12') /* Baixas Parciais, n�o baixar o t�tulo */
				                       THEN NULL
				                       ELSE #TEMP_MANUT.INDCONTINGENCIA 
				                  END,
				TIPOPESPORTADOR	= CASE WHEN #TEMP_MANUT.TIPOBAIXA IN ('2','3','10','12') /* Baixas Parciais, n�o baixar o t�tulo */
				                       THEN TITULOS.TIPOPESPORTADOR
				                       ELSE #TEMP_MANUT.TIPOPESPORTADOR
				                  END,
				CNPJ_CPF_PORTADOR = CASE WHEN #TEMP_MANUT.TIPOBAIXA IN ('2','3','10','12') /* Baixas Parciais, n�o baixar o t�tulo */
				                         THEN TITULOS.CNPJ_CPF_PORTADOR
				                         ELSE #TEMP_MANUT.CNPJ_CPF_PORTADOR
				                    END,

				SITPAGAMENTO = '2', /* SITUACAO "BAIXA ENVIADA/RECEBIDA" */
				DATAHORADDA   = #TEMP_ACEITOS.DATAHORADDA,
				DTHRSITTITULO = #TEMP_ACEITOS.DATAHORADDA, /* Eliane - coloquei aqui porque a 115 atualiza esse campo tb */
				
/*---------------------------------------------------------------*/				
/* dados que ser�o atualizados a partir da MODERNIZA��O - inicio */
				
				/* 13/03/2023 - Eliane - Acrescentei MEIO e CANAL para as BAIXAS definitivas... */
				MEIOPAGTO    	  = CASE WHEN #TEMP_MANUT.TIPOBAIXA IN ('2','3','10','12') /* Baixas Parciais, n�o baixar o t�tulo */
				                       THEN TITULOS.MEIOPAGTO
				                       ELSE #TEMP_MANUT.MEIOPAGTO
				                  END,
				CANALPAGTO    	  = CASE WHEN #TEMP_MANUT.TIPOBAIXA IN ('2','3','10','12') /* Baixas Parciais, n�o baixar o t�tulo */
				                       THEN TITULOS.CANALPAGTO
				                       ELSE #TEMP_MANUT.CANALPAGTO
				                  END,
				/* 13/03/2023 - Eliane - Acrescentei MEIO e CANAL para as BAIXAS definitivas... */

		                CODSITUACAO = CASE WHEN #TEMP_MANUT.CODEVENTO = '8108' 				AND
		                                        #TEMP_MANUT.TIPOMANUTENCAOTIT =  'B' /* Baixa */	AND
		                                        #TEMP_MANUT.TIPOBAIXA = '0' /* Baixa Operacional Integral Interbanc�ria */
		                                   THEN '4' /* t�tulo liquidado - LIQ INTERBANC�RIA */
		                                   WHEN #TEMP_MANUT.CODEVENTO = '8108' 				AND
		                                        #TEMP_MANUT.TIPOMANUTENCAOTIT =  'B' /* Baixa */	AND
						        #TEMP_MANUT.TIPOBAIXA = '1' /* Baixa Operacional Integral Intrabanc�ria */
		                                   THEN '3' /* t�tulo liquidado - LIQ INTRABANC�RIA */
		                                   WHEN #TEMP_MANUT.CODEVENTO <> '8108' 			AND
		                                   	#TEMP_MANUT.TIPOMANUTENCAOTIT =  'B' /* Baixa */
		                                   THEN #TEMP_MANUT.CODSITUACAO /* Baixa escolhida pela Cobran�a */
		                                   ELSE TITULOS.CODSITUACAO /* Continua como est� */
		                              END,

                		TIPOBAIXA      = CASE WHEN #TEMP_MANUT.TIPOBAIXA IN ('2','3','10','12') /* Baixas Parciais, n�o baixar o t�tulo */
                		                      THEN TITULOS.TIPOBAIXA     /* Deixa como estava */
                		                      ELSE #TEMP_MANUT.TIPOBAIXA /* J� estar� na codifica��o da moderniza��o */
                		                 END, 
                		DATAPAGTOBAIXA = CASE WHEN #TEMP_MANUT.TIPOBAIXA IN ('2','3','10','12') /* Baixas Parciais, n�o baixar o t�tulo */
                		                      THEN TITULOS.DATAPAGTOBAIXA /* Deixa como estava */
                		                      ELSE #TEMP_MANUT.DATAPAGTOBAIXA
                		                 END,
                		VLRPAGTOBAIXA  = CASE WHEN #TEMP_MANUT.TIPOBAIXA IN ('2','3','10','12') /* Baixas Parciais, n�o baixar o t�tulo */
                		                      THEN TITULOS.VLRPAGTOBAIXA
                		                      ELSE #TEMP_MANUT.VLRPAGTOBAIXA /* Deixa como estava */
                		                 END
/* dados que ser�o atualizados a partir da MODERNIZA��O - fim    */
/*---------------------------------------------------------------*/				
				
			FROM TITULOS
			INNER JOIN #TEMP_MANUT 
				ON (#TEMP_MANUT.CODRETORNO = '0'
				AND #TEMP_MANUT.NUMIDENTCDDA = TITULOS.NUMIDENTCDDA)
			INNER JOIN #TEMP_ACEITOS 
				ON (#TEMP_ACEITOS.CODPROCESSA = '1' 
				AND #TEMP_ACEITOS.CODREJEICAO IS NULL
				AND #TEMP_MANUT.NUMPEDIDO = #TEMP_ACEITOS.NUMPEDIDO)
			
			--ATUALIZAR APENAS PARA A MANUTEN��O DE BAIXA MAIS RECENTE RECEBIDA
			INNER JOIN  #TEMP_MAX_NUMIDENTCBAIXAOPERAC
				ON (#TEMP_MAX_NUMIDENTCBAIXAOPERAC.NUMIDENTCDDA = #TEMP_MANUT.NUMIDENTCDDA 
				AND #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC = #TEMP_MAX_NUMIDENTCBAIXAOPERAC.NUMIDENTCBAIXAOPERAC)

			SELECT @SQLERRO = @@ERROR		 
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS
                     
                     
                     END   /* Moderniza��o em diante LIQUIDACAO OU BAIXA EFETIVAMENTE */
                     

			INSERT INTO BAIXAS_OPERACIONAIS
			(
					NUMIDENTCDDA, NUMIDENTCBAIXAOPERAC, NUMCTRLDDA, NUMREFBAIXAOPERAC, 
					NUMSEQBAIXAOPERAC, NUMREFCADTIT, NUMSEQCADTIT, DATAMOVTO, 
					DATAHORADDA, TIPOBAIXA, DATABAIXA, DATAHORABAIXA, 
					VLRBAIXA, NUMCODBARRAS, SITBAIXA, DATAHORASITUACAO, 
					ISPBSACADA, CODIFSACADA, NUMCTRLDDACANCEL, DATAHORACANCEL, 
					SITPAGTO, SITUACAOTIT, CANALPAGTO, MEIOPAGTO, 
					--05/11/2021 - RFAQUINI - INCLUS�O E TRATAMENTO DO CAMPO NOME_PORTADOR (CAT�LOGO 5.03)
					INDCONTINGENCIA, TIPOPESPORTADOR, CNPJ_CPF_PORTADOR, NOME_PORTADOR,
					--25/05/2022 - RFAQUINI - INCLUS�O E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CAT�LOGO 5.04)
					DATAHORARECBTTITULO, QTDPAGTOREG, VLRSALDOATUAL,
					TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO, AGENCIARECEBEDORA /* CAT MODERNIZA��O */
					
			) 
			SELECT
					#TEMP_ACEITOS.NUMIDENTCDDA, #TEMP_ACEITOS.NUMIDENTCBAIXAOPERAC, #TEMP_ACEITOS.NUMCTRLDDA, #TEMP_ACEITOS.NUMREFBAIXAOPERAC, 
					ISNULL (#TEMP_ACEITOS.NUMSEQBAIXAOPERAC, 0) /* 09/02/2023 */, #TEMP_ACEITOS.NUMREFCADTIT, #TEMP_ACEITOS.NUMSEQCADTIT, #TEMP_ACEITOS.DATAMOVTO, 
					#TEMP_ACEITOS.DATAHORADDA, #TEMP_MANUT.TIPOBAIXA, #TEMP_MANUT.DATAPAGTOBAIXA, #TEMP_MANUT.DATAPAGTOBAIXA, 
					#TEMP_MANUT.VLRPAGTOBAIXA, #TEMP_MANUT.NUMCODBARRAS, 'A', /* BAIXA ATIVA */ NULL, 
					#TEMP_MANUT.ISPBSACADA, #TEMP_MANUT.CODIFSACADA, NULL, NULL, 
					NULL, #TEMP_MANUT.CODSITUACAO, #TEMP_MANUT.CANALPAGTO, #TEMP_MANUT.MEIOPAGTO, 
					--05/11/2021 - RFAQUINI - INCLUS�O E TRATAMENTO DO CAMPO NOME_PORTADOR (CAT�LOGO 5.03)
					#TEMP_MANUT.INDCONTINGENCIA, #TEMP_MANUT.TIPOPESPORTADOR, #TEMP_MANUT.CNPJ_CPF_PORTADOR, #TEMP_MANUT.NOME_PORTADOR,
					--25/05/2022 - RFAQUINI - INCLUS�O E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CAT�LOGO 5.04)					
					#TEMP_MANUT.DATAHORARECBTTITULO, NULL, NULL,
					#TEMP_MANUT.TIPOPESAGREGADOR, #TEMP_MANUT.CNPJ_CPF_AGREGADOR, #TEMP_MANUT.NOMEAGREGADOR, 	/* CAT MODERNIZA��O */
					#TEMP_MANUT.ISPBINICIADORPAGTO, #TEMP_MANUT.AGENCIARECEBEDORA 					/* CAT MODERNIZA��O */
					
			FROM #TEMP_ACEITOS 
			INNER JOIN #TEMP_MANUT 
				ON (#TEMP_ACEITOS.CODPROCESSA = '1'
				AND #TEMP_ACEITOS.CODREJEICAO IS NULL
				AND #TEMP_ACEITOS.NUMPEDIDO = #TEMP_MANUT.NUMPEDIDO)

			SELECT @SQLERRO = @@ERROR		 
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS

			-- MANUTS PROCESSADAS
			UPDATE MANUT_TITULOS SET 
				SITUACAOPEDIDO = '5', 
				CODRETORNO = #TEMP_MANUT.CODRETORNO, 
				NOMEARQRET = #TEMP_ACEITOS.NOMEARQRET, 
				NUMREFBAIXAOPERAC_RET = #TEMP_ACEITOS.NUMREFBAIXAOPERAC,   
				--06/02/2023 - ELIANE, RFAQUINI - TRATAMENTO DO CAMPO NUMSEQBAIXAOPERAC (CAT�LOGO MODERNIZA��O)
				NUMSEQBAIXAOPERAC = ISNULL(#TEMP_ACEITOS.NUMSEQBAIXAOPERAC, 0), 
				DATAHORADDA = #TEMP_ACEITOS.DATAHORADDA  /* 08/11/2022 */  
			FROM MANUT_TITULOS
			INNER JOIN #TEMP_MANUT 
				ON (MANUT_TITULOS.DATAPEDIDO = #TEMP_MANUT.DATAPEDIDO
				AND MANUT_TITULOS.DATALEGADO = #TEMP_MANUT.DATALEGADO
				AND MANUT_TITULOS.CODSISLEGADO = #TEMP_MANUT.CODSISLEGADO
				AND MANUT_TITULOS.NUMCTRLLEGADO = #TEMP_MANUT.NUMCTRLLEGADO)
			INNER JOIN #TEMP_ACEITOS 
				ON (MANUT_TITULOS.NUMPEDIDO = #TEMP_ACEITOS.NUMPEDIDO)

			SELECT @SQLERRO = @@ERROR		 
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS

			-- RESTABELECENDO OS RECEBIMENTOS QUE FORAM MARCADOS PARA PROCESSAMENTO AO FINAL DA PROCEDURE
			UPDATE #TEMP_ACEITOS
			SET CODPROCESSA = '1'
			WHERE CODPROCESSA = '4'

			SELECT @SQLERRO = @@ERROR		 
			IF @SQLERRO <> 0 GOTO TRATAERROTRANS

			-- RECEBES PROCESSADAS
			UPDATE RECEBE_ADDA108_RET_ACEITOS SET 
				CODPROCESSA = #TEMP_ACEITOS.CODPROCESSA, 
			    CODREJEICAO = #TEMP_ACEITOS.CODREJEICAO, 
			    DATAMANUTENCAO = @TIMESTAMP
			FROM RECEBE_ADDA108_RET_ACEITOS 
			INNER JOIN #TEMP_ACEITOS 
				ON (#TEMP_ACEITOS.SEQ_RECEBE = RECEBE_ADDA108_RET_ACEITOS.SEQ_RECEBE
				AND #TEMP_ACEITOS.NUMPEDIDO = RECEBE_ADDA108_RET_ACEITOS.NUMPEDIDO
				AND #TEMP_ACEITOS.DATAMOVTO = RECEBE_ADDA108_RET_ACEITOS.DATAMOVTO)
		
		COMMIT TRANSACTION
		RETURN

		TRATAERROTRANS:
			ROLLBACK TRANSACTION
			GOTO TRATAERRO

		TRATAERRO:
			SELECT @P_SQLERRO = @SQLERRO
			RETURN

	END 
	----------------- TRATAMENTO DE ACEITOS - FIM ---------------------------------

	SET NOCOUNT OFF
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
	'SP_PROCESSA_DDA0108R1_ADDA108RET', 
	SYSTEM_USER, 
	GETDATE() 
GO