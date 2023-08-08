USE AB_DDA
GO

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_RESERVAR_MANUTENCAO_TITULO_GERACAO_ARQUIVO_101')
BEGIN
	EXEC ('DROP PROCEDURE dbo.SP_RESERVAR_MANUTENCAO_TITULO_GERACAO_ARQUIVO_101')
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_RESERVAR_MANUTENCAO_TITULO_GERACAO_ARQUIVO_THREADS')
BEGIN
	EXEC ('CREATE PROCEDURE dbo.SP_RESERVAR_MANUTENCAO_TITULO_GERACAO_ARQUIVO_THREADS AS BEGIN RETURN END')
END
GO

ALTER PROCEDURE DBO.SP_RESERVAR_MANUTENCAO_TITULO_GERACAO_ARQUIVO_THREADS( 
	@P_TIPOMANUTENCAO CHAR(1), 
	@P_QTD INT 
) AS 
BEGIN 
	/* 
		01/04/2019 - EDUARDOK - ALTERACAO NA PERFORMANCE - CARREGA APENAS A PK NA #TEMP_MANUT_TITULOS_INICIO E 
								CARREGA A #TEMP_MANUT_TITULOS UTILIZANDO JOIN DIRETO DA MANUT_TITULOS COM FILTRO DA PK 

		16/09/2019 - RFAQUINI - SOL 61154 - ALTERAÇÃO POSSIBILITANDO EXPORTAÇÃO DE ADDA108 VIA THREADS 

		19/11/2021 - RFAQUINI - INCLUSÃO E TRATAMENTO DO CAMPO NOME_PORTADOR (CATÁLOGO 5.03)
								REMOÇÃO DE ALIAS 
	
		07/06/2022 - RFAQUINI - INCLUSÃO E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CATÁLOGO 5.04) 
								REMOÇÃO DE ALIAS 
		
		23/01/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
									DOS CAMPOS 
										TIPOPESAGREGADOR, 
										CNPJ_CPF_AGREGADOR,
										NOMEAGREGADOR,
										ISPBINICIADORPAGTO,
										AGENCIARECEBEDORA
										
		02/02/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
								DO CAMPO 
									CODMOTIVO	

		10/02/2023 - RFAQUINI - ALTERAÇÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
								DOS CODEVENTOS
								
		14/02/2023 - ELIANE, RFAQUINI - VALIDAÇÃO PARA BAIXAS EFETIVAS ENVIADAS PELA 108
		
		TEST 
		DELETE FROM TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO 
		EXEC SP_RESERVAR_MANUTENCAO_TITULO_GERACAO_ARQUIVO_THREADS 'I', 20000 
	*/ 
 
	DECLARE 
		@DATAHORAREM DATETIME, 
		@DATAULTPROCESSAMENTO DATETIME, 
		@FILTRO_QTD INT, 
		@QTD_THREADS INT, 
		@INI_BLOCO INT, 
		@CONT_NOMEARQUIVO INT, 
		@NOMEARQREM VARCHAR(35), 
		@TAM_BLOCO INT 
	
	SELECT @DATAHORAREM = GETDATE() 

	SELECT @FILTRO_QTD = 3 * @P_QTD 

	SELECT @DATAULTPROCESSAMENTO = DATAULTPROCESSAMENTO 
	FROM PARAMETROS 

	-- SELECIONANDO TODAS AS MANUTENCOES PREPARADAS PARA ENVIO NO TIPO DE MANUTENCAO VISADO ("I", OU "A" DESDE QUE NAO ACOMPANHADO DE UMA MANUT_COMPLEMENTOS E NAO SEJA CODEVENTO 8300 - MANUT. ANEXO DE FA 

	/********** PRIMEIRA TEMPORÁRIA DE TRABALHO *****************/ 
	SELECT 
	DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
	NUMPEDIDO, NUMIDENTCDDA, CODEVENTO, CODIFSACADA, 
	TIPOMANUTENCAOTIT, CODIFCEDENTE, TIPOPESCEDENTE, CNPJ_CPF_CEDENTE, 
	NOMEFANTASIACEDENTE, NOMEFANTASIACEDENTEORI, NOMEFANTASIASACADO, NUMIDENTCBAIXAOPERAC, 
	
	NUMREFBAIXAOPERAC, NUMSEQBAIXAOPERAC, NUMIDENTCBAIXAEFET, NUMREFBAIXAEFET, 
	NUMSEQBAIXAEFET, ISPBCEDENTE, ISPBSACADA, CANALPAGTO, 
	MEIOPAGTO, NUMREFBAIXAOPERAC_RET, NUMREFBAIXAEFET_RET, NOMECEDENTE, 
	TIPOPESCEDENTEORI, CNPJ_CPF_CEDENTEORI, NOMECEDENTEORI, ENDCEDENTEORI, 
	
	CIDCEDENTEORI, UFCEDENTEORI, CEPCEDENTEORI, TIPOPESSACADO, 
	CNPJ_CPF_SACADO, NOMESACADO, ENDSACADO, CIDSACADO, 
	UFSACADO, CEPSACADO, TIPOPESSACADOR, CNPJ_CPF_SACADOR, 
	NOMESACADOR, CODCARTEIRA, CODMOEDACNAB, IDENTNOSSONUMERO, 
	
	NUMCODBARRAS, DATAVENCIMENTO, VLRTITULO, SEUNUMERO, 
	CODESPECIEDOC, DATAEMISSAO, QTDEDIASPROTESTO, DATALIMPAGTO, 
	TIPOPAGTO, INDTITULONEGOCIADO, VLRABATIMENTO, CODMORA, 
	DATAMORA, VLRPERCMORA, CODMULTA, DATAMULTA, 
	
	VLRPERCMULTA, CODDESCONTO01, DATADESCONTO01, VLRPERCDESCONTO01, 
	CODDESCONTO02, DATADESCONTO02, VLRPERCDESCONTO02, CODDESCONTO03, 
	DATADESCONTO03, VLRPERCDESCONTO03, VLRMINTITULO, VLRMAXTITULO, 
	TIPOBAIXA, DATAPAGTOBAIXA, VLRPAGTOBAIXA, ACEITE, 
	
	NUMCTRLDDA, DATAHORADDA, TIPOPESTERCEIRO, CNPJ_CPF_TERCEIRO, 
	NUMIDENTCDDA2, DATAVENCTOINI, DATAVENCTOFIM, DATACADASTINI, 
	DATACADASTFIM, TIPOCONSULTA, CNPJBASE, BUSCABASESACADO, 
	CODSITUACAO, TIPORETORNO, SITUACAOPEDIDO, CODRETORNO, 
	
	NOMEARQRET, NOMEARQREM, TIPOCALCULO, INDALTERAVALOR, 
	DATACALCULO, VLRCALCULADODESC, VLRCALCULADOMORA, VLRCALCULADOMULTA, 
	VLRCOBRAR, TIPOENVIO, FORMAENVIO, LINHADIGITAVEL, 
	NUMPARCELA, QTDPARCELA, TIPOAUTRECDIVERGENTE, INDBLOQUEIO, 
	
	INDPARCIAL, QTDPAGTO, INDVALORPERC_MIN, INDVALORPERC_MAX, 
	NUMREFCADTIT, NUMSEQCADTIT, NUMREFACEITE, NUMSEQACEITE, 
	NUMREFTERC, NUMSEQTERC, NUMIDENTCTERC, NUMREFACEITE_RET, 
	NUMREFTERC_RET, TIPOPESAUTORIZADOR, CNPJ_CPF_AUTORIZADOR, TIPOPESPORTADOR, 
	
	CNPJ_CPF_PORTADOR, 
	
	--19/11/2021 - RFAQUINI - INCLUSÃO E TRATAMENTO DO CAMPO NOME_PORTADOR (CATÁLOGO 5.03)
	NOME_PORTADOR, 
	
	--07/06/2022 - RFAQUINI - INCLUSÃO E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CATÁLOGO 5.04) 
	DATAHORARECBTTITULO, 
	
	--23/01/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
	TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO,
	AGENCIARECEBEDORA,
	
	--02/02/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
	CODMOTIVO,
	
	INDCONTINGENCIA, SPID, DATAHORAPROCESSO, 
	NUMPEDIDOPEND, 
	CONVERT (CHAR, NULL) AS ERRO 
		INTO #TEMP_MANUT_TITULOS 
	FROM MANUT_TITULOS 
	WHERE 1 = 2 

	/********** SEGUNDA TEMPORÁRIA DE TRABALHO *****************/ 
	SELECT 
	DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
	CONVERT (CHAR, NULL) AS ERRO 
		INTO #TEMP_MANUT_TITULOS_INICIO 
	FROM #TEMP_MANUT_TITULOS 


	/********** SELECIONANDO MANUTS PREPARADAS PARA ENVIO *****************/ 
	/* 3 VEZES A QUANTIDADE QUE ENTROU COMO PARÂMETRO */ 
	/* FAZEMOS ISSO PARA DEPOIS ORDENAR POR VENCIMENTO E PEGAR O VENCTO MAIS RECENTE...*/ 

	IF (@P_TIPOMANUTENCAO IS NOT NULL AND @P_TIPOMANUTENCAO = 'I') 

	BEGIN /*TRATANDO INCLUSÕES */ 
		INSERT INTO #TEMP_MANUT_TITULOS_INICIO (
			DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
			ERRO
		) 
		SELECT TOP(@FILTRO_QTD) 
			DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
			CONVERT (CHAR, NULL) AS ERRO 
		FROM MANUT_TITULOS 
		WHERE DATAPEDIDO >= @DATAULTPROCESSAMENTO 
		AND SITUACAOPEDIDO = '4' 
		AND TIPOMANUTENCAOTIT = 'I' 
		AND TIPOENVIO = 'X' 

		/* AQUI NÃO VERIFICAMOS NUMPEDIDO IS NOT NULL - PORQUE? -->> A PROC QUE PREPARA, NUMERA - ELIANE */ 

		ORDER BY DATAVENCIMENTO 
	END /*TRATANDO INCLUSÕES */ 

	ELSE 
	IF (@P_TIPOMANUTENCAO IS NOT NULL AND @P_TIPOMANUTENCAO = 'A') 

	BEGIN /* TRATANDO ALTERAÇÕES */ 
		INSERT INTO #TEMP_MANUT_TITULOS_INICIO(
			DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
			ERRO
		) 
		SELECT TOP(@FILTRO_QTD) 
			DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
			CONVERT (CHAR, NULL) AS ERRO 
		FROM MANUT_TITULOS 
		WHERE DATAPEDIDO >= @DATAULTPROCESSAMENTO 
		AND SITUACAOPEDIDO = '4' 
		AND TIPOMANUTENCAOTIT = 'A' 
		AND CODEVENTO NOT IN ('8300', '8121', '8122', '8104') 
		AND TIPOENVIO = 'X' 
		AND NUMPEDIDO IS NOT NULL 

		DELETE #TEMP_MANUT_TITULOS_INICIO
		FROM #TEMP_MANUT_TITULOS_INICIO 
		INNER JOIN MANUT_COMPLEMENTOS 
			ON (#TEMP_MANUT_TITULOS_INICIO.DATAPEDIDO = MANUT_COMPLEMENTOS.DATAPEDIDO 
			AND #TEMP_MANUT_TITULOS_INICIO.DATALEGADO = MANUT_COMPLEMENTOS.DATALEGADO 
			AND #TEMP_MANUT_TITULOS_INICIO.NUMCTRLLEGADO = MANUT_COMPLEMENTOS.NUMCTRLLEGADO 
			AND #TEMP_MANUT_TITULOS_INICIO.CODSISLEGADO = MANUT_COMPLEMENTOS.CODSISLEGADO)
	END /* TRATANDO ALTERAÇÕES */ 

	--16/09/2019 - RFAQUINI - SOL 61154 - ALTERAÇÃO POSSIBILITANDO EXPORTAÇÃO DE ADDA108 VIA THREADS 
	ELSE 
	IF (@P_TIPOMANUTENCAO IS NOT NULL AND @P_TIPOMANUTENCAO = 'B') 

	BEGIN /* TRATANDO BAIXAS */ 
		INSERT INTO #TEMP_MANUT_TITULOS_INICIO(
			DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
			ERRO
		) 
		SELECT TOP(@FILTRO_QTD) 
			DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
			CONVERT (CHAR, NULL) AS ERRO 
		FROM MANUT_TITULOS 
		WHERE DATAPEDIDO >= @DATAULTPROCESSAMENTO 
		AND SITUACAOPEDIDO = '4' 
		AND TIPOMANUTENCAOTIT = 'B'
		--09/02/2023 - RFAQUINI - ALTERAÇÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
		AND CODEVENTO IN (
			'0111', '0112', '0113', '0114', 
			'0115', '0116', '0266', '1101', 
			'8108', '8511'
		) 
		AND TIPOENVIO = 'X' 
		AND NUMPEDIDO IS NOT NULL 

		DELETE #TEMP_MANUT_TITULOS_INICIO
		FROM #TEMP_MANUT_TITULOS_INICIO
		INNER JOIN MANUT_COMPLEMENTOS  
			ON (#TEMP_MANUT_TITULOS_INICIO.DATAPEDIDO = MANUT_COMPLEMENTOS.DATAPEDIDO 
			AND #TEMP_MANUT_TITULOS_INICIO.DATALEGADO = MANUT_COMPLEMENTOS.DATALEGADO 
			AND #TEMP_MANUT_TITULOS_INICIO.NUMCTRLLEGADO = MANUT_COMPLEMENTOS.NUMCTRLLEGADO 
			AND #TEMP_MANUT_TITULOS_INICIO.CODSISLEGADO = MANUT_COMPLEMENTOS.CODSISLEGADO)
	END /* TRATANDO BAIXAS */ 

	/* INCLUINDO A CHAVE DE TODAS AS MANUTENCOES QUE JA NAO ESTIVEREM NA TABELA QUE AUXILIA O WORKFLOW DE ARQUIVOS, 
	JUNTO A MARCACAO DO ARQUIVO QUE ESTA SENDO PROCESSADO E O TIMESTAMP DESSA EXECUCAO */ 

	DELETE #TEMP_MANUT_TITULOS_INICIO
	FROM #TEMP_MANUT_TITULOS_INICIO
	INNER JOIN TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO 
		ON (#TEMP_MANUT_TITULOS_INICIO.DATAPEDIDO = TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.DATAPEDIDO 
		AND #TEMP_MANUT_TITULOS_INICIO.DATALEGADO = TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.DATALEGADO 
		AND #TEMP_MANUT_TITULOS_INICIO.NUMCTRLLEGADO = TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.NUMCTRLLEGADO 
		AND #TEMP_MANUT_TITULOS_INICIO.CODSISLEGADO = TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.CODSISLEGADO)

	INSERT INTO #TEMP_MANUT_TITULOS 
	SELECT TOP(@P_QTD) 
		MANUT_TITULOS.DATAPEDIDO, MANUT_TITULOS.DATALEGADO, MANUT_TITULOS.CODSISLEGADO, MANUT_TITULOS.NUMCTRLLEGADO, 
		MANUT_TITULOS.NUMPEDIDO, MANUT_TITULOS.NUMIDENTCDDA, MANUT_TITULOS.CODEVENTO, MANUT_TITULOS.CODIFSACADA, 
		MANUT_TITULOS.TIPOMANUTENCAOTIT, MANUT_TITULOS.CODIFCEDENTE, MANUT_TITULOS.TIPOPESCEDENTE, MANUT_TITULOS.CNPJ_CPF_CEDENTE, 
		MANUT_TITULOS.NOMEFANTASIACEDENTE, MANUT_TITULOS.NOMEFANTASIACEDENTEORI, MANUT_TITULOS.NOMEFANTASIASACADO, MANUT_TITULOS.NUMIDENTCBAIXAOPERAC, 

		MANUT_TITULOS.NUMREFBAIXAOPERAC, MANUT_TITULOS.NUMSEQBAIXAOPERAC, MANUT_TITULOS.NUMIDENTCBAIXAEFET, MANUT_TITULOS.NUMREFBAIXAEFET, 
		MANUT_TITULOS.NUMSEQBAIXAEFET, MANUT_TITULOS.ISPBCEDENTE, MANUT_TITULOS.ISPBSACADA, MANUT_TITULOS.CANALPAGTO, 
		MANUT_TITULOS.MEIOPAGTO, MANUT_TITULOS.NUMREFBAIXAOPERAC_RET, MANUT_TITULOS.NUMREFBAIXAEFET_RET, MANUT_TITULOS.NOMECEDENTE, 
		MANUT_TITULOS.TIPOPESCEDENTEORI, MANUT_TITULOS.CNPJ_CPF_CEDENTEORI, MANUT_TITULOS.NOMECEDENTEORI, MANUT_TITULOS.ENDCEDENTEORI, 
		
		MANUT_TITULOS.CIDCEDENTEORI, MANUT_TITULOS.UFCEDENTEORI, MANUT_TITULOS.CEPCEDENTEORI, MANUT_TITULOS.TIPOPESSACADO, 
		MANUT_TITULOS.CNPJ_CPF_SACADO, MANUT_TITULOS.NOMESACADO, MANUT_TITULOS.ENDSACADO, MANUT_TITULOS.CIDSACADO, 
		MANUT_TITULOS.UFSACADO, MANUT_TITULOS.CEPSACADO, MANUT_TITULOS.TIPOPESSACADOR, MANUT_TITULOS.CNPJ_CPF_SACADOR, 
		MANUT_TITULOS.NOMESACADOR, MANUT_TITULOS.CODCARTEIRA, MANUT_TITULOS.CODMOEDACNAB, MANUT_TITULOS.IDENTNOSSONUMERO, 
		
		MANUT_TITULOS.NUMCODBARRAS, MANUT_TITULOS.DATAVENCIMENTO, MANUT_TITULOS.VLRTITULO, MANUT_TITULOS.SEUNUMERO, 
		MANUT_TITULOS.CODESPECIEDOC, MANUT_TITULOS.DATAEMISSAO, MANUT_TITULOS.QTDEDIASPROTESTO, MANUT_TITULOS.DATALIMPAGTO, 
		MANUT_TITULOS.TIPOPAGTO, MANUT_TITULOS.INDTITULONEGOCIADO, MANUT_TITULOS.VLRABATIMENTO, MANUT_TITULOS.CODMORA, 
		MANUT_TITULOS.DATAMORA, MANUT_TITULOS.VLRPERCMORA, MANUT_TITULOS.CODMULTA, MANUT_TITULOS.DATAMULTA, 
		
		MANUT_TITULOS.VLRPERCMULTA, MANUT_TITULOS.CODDESCONTO01, MANUT_TITULOS.DATADESCONTO01, MANUT_TITULOS.VLRPERCDESCONTO01, 
		MANUT_TITULOS.CODDESCONTO02, MANUT_TITULOS.DATADESCONTO02, MANUT_TITULOS.VLRPERCDESCONTO02, MANUT_TITULOS.CODDESCONTO03, 
		MANUT_TITULOS.DATADESCONTO03, MANUT_TITULOS.VLRPERCDESCONTO03, MANUT_TITULOS.VLRMINTITULO, MANUT_TITULOS.VLRMAXTITULO, 
		MANUT_TITULOS.TIPOBAIXA, MANUT_TITULOS.DATAPAGTOBAIXA, MANUT_TITULOS.VLRPAGTOBAIXA, MANUT_TITULOS.ACEITE, 
		
		MANUT_TITULOS.NUMCTRLDDA, MANUT_TITULOS.DATAHORADDA, MANUT_TITULOS.TIPOPESTERCEIRO, MANUT_TITULOS.CNPJ_CPF_TERCEIRO, 
		MANUT_TITULOS.NUMIDENTCDDA2, MANUT_TITULOS.DATAVENCTOINI, MANUT_TITULOS.DATAVENCTOFIM, MANUT_TITULOS.DATACADASTINI, 
		MANUT_TITULOS.DATACADASTFIM, MANUT_TITULOS.TIPOCONSULTA, MANUT_TITULOS.CNPJBASE, MANUT_TITULOS.BUSCABASESACADO, 
		MANUT_TITULOS.CODSITUACAO, MANUT_TITULOS.TIPORETORNO, MANUT_TITULOS.SITUACAOPEDIDO, MANUT_TITULOS.CODRETORNO, 
		
		MANUT_TITULOS.NOMEARQRET, MANUT_TITULOS.NOMEARQREM, MANUT_TITULOS.TIPOCALCULO, MANUT_TITULOS.INDALTERAVALOR, 
		MANUT_TITULOS.DATACALCULO, MANUT_TITULOS.VLRCALCULADODESC, MANUT_TITULOS.VLRCALCULADOMORA, MANUT_TITULOS.VLRCALCULADOMULTA, 
		MANUT_TITULOS.VLRCOBRAR, MANUT_TITULOS.TIPOENVIO, MANUT_TITULOS.FORMAENVIO, MANUT_TITULOS.LINHADIGITAVEL, 
		MANUT_TITULOS.NUMPARCELA, MANUT_TITULOS.QTDPARCELA, MANUT_TITULOS.TIPOAUTRECDIVERGENTE, MANUT_TITULOS.INDBLOQUEIO, 
		
		MANUT_TITULOS.INDPARCIAL, MANUT_TITULOS.QTDPAGTO, MANUT_TITULOS.INDVALORPERC_MIN, MANUT_TITULOS.INDVALORPERC_MAX, 
		MANUT_TITULOS.NUMREFCADTIT, MANUT_TITULOS.NUMSEQCADTIT, MANUT_TITULOS.NUMREFACEITE, MANUT_TITULOS.NUMSEQACEITE, 
		MANUT_TITULOS.NUMREFTERC, MANUT_TITULOS.NUMSEQTERC, MANUT_TITULOS.NUMIDENTCTERC, MANUT_TITULOS.NUMREFACEITE_RET, 
		MANUT_TITULOS.NUMREFTERC_RET, MANUT_TITULOS.TIPOPESAUTORIZADOR, MANUT_TITULOS.CNPJ_CPF_AUTORIZADOR, MANUT_TITULOS.TIPOPESPORTADOR, 
		
		MANUT_TITULOS.CNPJ_CPF_PORTADOR, 

		--19/11/2021 - RFAQUINI - INCLUSÃO E TRATAMENTO DO CAMPO NOME_PORTADOR (CATÁLOGO 5.03) 
		MANUT_TITULOS.NOME_PORTADOR, 
		
		--07/06/2022 - RFAQUINI - INCLUSÃO E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CATÁLOGO 5.04) 		
		MANUT_TITULOS.DATAHORARECBTTITULO, 
		
		--23/01/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
		TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO,
		AGENCIARECEBEDORA,
		
		--02/02/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
		CODMOTIVO,
		
		--14/02/2023 - ELIANE, RFAQUINI - VALIDAÇÃO PARA BAIXAS EFETIVAS ENVIADAS PELA 108
		ISNULL(MANUT_TITULOS.INDCONTINGENCIA, 'N'), 
		
		MANUT_TITULOS.SPID, MANUT_TITULOS.DATAHORAPROCESSO, MANUT_TITULOS.NUMPEDIDOPEND, 
		ERRO 
	FROM MANUT_TITULOS, #TEMP_MANUT_TITULOS_INICIO  
	--EDUARDOK 01/04/2019 - ALTERACAO PARA MELHORAR PERFORMANCE 
	WHERE MANUT_TITULOS.DATAPEDIDO = #TEMP_MANUT_TITULOS_INICIO.DATAPEDIDO 
	AND MANUT_TITULOS.CODSISLEGADO = #TEMP_MANUT_TITULOS_INICIO.CODSISLEGADO 
	AND MANUT_TITULOS.DATALEGADO = #TEMP_MANUT_TITULOS_INICIO.DATALEGADO 
	AND MANUT_TITULOS.NUMCTRLLEGADO = #TEMP_MANUT_TITULOS_INICIO.NUMCTRLLEGADO 

	DELETE 
	FROM TEMP_MANUTENCAO_NOTAS_FISCAIS_GERACAO_ARQUIVO 
	
	INSERT INTO TEMP_MANUTENCAO_NOTAS_FISCAIS_GERACAO_ARQUIVO 
	SELECT 
		MANUT_NOTAS_FISCAIS.DATAPEDIDO, MANUT_NOTAS_FISCAIS.DATALEGADO, MANUT_NOTAS_FISCAIS.CODSISLEGADO, MANUT_NOTAS_FISCAIS.NUMCTRLLEGADO, 
		MANUT_NOTAS_FISCAIS.CODEVENTO, MANUT_NOTAS_FISCAIS.NUMNOTAFISCAL, MANUT_NOTAS_FISCAIS.DATAEMISSAO, MANUT_NOTAS_FISCAIS.VLRNOTAFISCAL 
	FROM #TEMP_MANUT_TITULOS 
	INNER JOIN MANUT_NOTAS_FISCAIS  
		ON (#TEMP_MANUT_TITULOS.DATAPEDIDO = MANUT_NOTAS_FISCAIS.DATAPEDIDO 
		AND #TEMP_MANUT_TITULOS.DATALEGADO = MANUT_NOTAS_FISCAIS.DATALEGADO 
		AND #TEMP_MANUT_TITULOS.CODSISLEGADO = MANUT_NOTAS_FISCAIS.CODSISLEGADO 
		AND #TEMP_MANUT_TITULOS.NUMCTRLLEGADO = MANUT_NOTAS_FISCAIS.NUMCTRLLEGADO) 

	DELETE 
	FROM TEMP_MANUTENCAO_MENSAGENS_GERACAO_ARQUIVO 
	
	INSERT INTO TEMP_MANUTENCAO_MENSAGENS_GERACAO_ARQUIVO 
	SELECT 
		MANUT_MENSAGENS.DATAPEDIDO, MANUT_MENSAGENS.DATALEGADO, MANUT_MENSAGENS.CODSISLEGADO, 
		MANUT_MENSAGENS.NUMCTRLLEGADO, MANUT_MENSAGENS.CODEVENTO, MANUT_MENSAGENS.SEQMENSAGEM, MANUT_MENSAGENS.TEXTO 
	FROM #TEMP_MANUT_TITULOS
	INNER JOIN MANUT_MENSAGENS
		ON (#TEMP_MANUT_TITULOS.DATAPEDIDO = MANUT_MENSAGENS.DATAPEDIDO 
		AND #TEMP_MANUT_TITULOS.DATALEGADO = MANUT_MENSAGENS.DATALEGADO 
		AND #TEMP_MANUT_TITULOS.CODSISLEGADO = MANUT_MENSAGENS.CODSISLEGADO 
		AND #TEMP_MANUT_TITULOS.NUMCTRLLEGADO = MANUT_MENSAGENS.NUMCTRLLEGADO) 

	DELETE
	FROM TEMP_MANUTENCAO_CALCULOS_GERACAO_ARQUIVO 

	INSERT INTO TEMP_MANUTENCAO_CALCULOS_GERACAO_ARQUIVO 
	SELECT 
		MANUT_CALCULOS.DATAPEDIDO, MANUT_CALCULOS.DATALEGADO, MANUT_CALCULOS.CODSISLEGADO, MANUT_CALCULOS.NUMCTRLLEGADO, 
		MANUT_CALCULOS.DATACALCULO, MANUT_CALCULOS.VLRMORA, MANUT_CALCULOS.VLRMULTA, MANUT_CALCULOS.VLRDESCONTO, 
		MANUT_CALCULOS.VLRCOBRAR 
	FROM #TEMP_MANUT_TITULOS
	INNER JOIN MANUT_CALCULOS
		ON (#TEMP_MANUT_TITULOS.DATAPEDIDO = MANUT_CALCULOS.DATAPEDIDO 
		AND #TEMP_MANUT_TITULOS.DATALEGADO = MANUT_CALCULOS.DATALEGADO 
		AND #TEMP_MANUT_TITULOS.CODSISLEGADO = MANUT_CALCULOS.CODSISLEGADO 
		AND #TEMP_MANUT_TITULOS.NUMCTRLLEGADO = MANUT_CALCULOS.NUMCTRLLEGADO) 

	--QUANTIDADE DE NOMEARQUIVO EM TEMP_NOME_ARQUIVO_EXPORTACAO = QUANTIDADE DE THREADS 

	SELECT @QTD_THREADS = COUNT(1) 
	FROM TEMP_NOME_ARQUIVO_EXPORTACAO 

	SELECT @CONT_NOMEARQUIVO = 0 
	SELECT @TAM_BLOCO = @P_QTD / @QTD_THREADS --5000 = 20000 / 4 

	--ALOCA ATÉ @P_QTD DE MANUTS POR NOMENOMEARQUIVO DIFERENTE 

	WHILE (@CONT_NOMEARQUIVO < @QTD_THREADS) 
	BEGIN 
		--SQL2008R2- 
		SELECT @NOMEARQREM = NOMEARQUIVO 
		FROM 
		( 
			SELECT NOMEARQUIVO, 
			ROW_NUMBER() OVER (ORDER BY NOMEARQUIVO) AS NOMARQ 
			FROM TEMP_NOME_ARQUIVO_EXPORTACAO 
		) T 
		WHERE NOMARQ BETWEEN (@CONT_NOMEARQUIVO + 1) AND (@CONT_NOMEARQUIVO + 1) 

		/*--------------------------------------------------------------------------*/ 
		/* NESTE PONTO TEMOS UM NOME DE ARQUIVO OBTIDO COMO O N-ESIMO A SER CRIADO. */ 
		/*--------------------------------------------------------------------------*/ 

		/* 
		--09/10/2019 - RFAQUINI - ALTERAÇÃO PARA SER POSSÍVEL EXECUTAR NO CARUANA, SQLSERVER 2008 R2 
		--SQL 2012+ 
		SELECT @NOMEARQREM = NOMEARQUIVO 
		FROM TEMP_NOME_ARQUIVO_EXPORTACAO 
		ORDER BY NOMEARQUIVO 
		OFFSET @CONT_NOMEARQUIVO ROWS 
		FETCH NEXT 1 ROWS ONLY 
		*/ 

		SET @INI_BLOCO = @CONT_NOMEARQUIVO * @TAM_BLOCO 

		/* 
		--28/03/2022 - ELIANE, RFAQUINI - ATUALIZAÇÃO DA TABELA PARAMETROS 
		*/ 
		BEGIN TRANSACTION 

			--09/10/2019 - RFAQUINI - ALTERAÇÃO PARA SER POSSÍVEL EXECUTAR NO CARUANA, SQLSERVER 2008 R2 
			--SQL2008R2- 
			INSERT INTO TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO 
			(DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, NOMEARQREM, DATAHORAREM) 
			SELECT DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, @NOMEARQREM, @DATAHORAREM 
			FROM 
			( 
			SELECT DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
			ROW_NUMBER() OVER (ORDER BY DATAVENCIMENTO) AS ARQSEXP 
			FROM #TEMP_MANUT_TITULOS 
			) T 
			WHERE ARQSEXP BETWEEN (@INI_BLOCO + 1) AND (@INI_BLOCO + @TAM_BLOCO) 

			IF @@ERROR <> 0 
			GOTO TRATAERRO 

			/* 
			--28/03/2022 - ELIANE, RFAQUINI - INÍCIO 
			EXTRAINDO O NÚMERO DO ARQUIVO RESERVADO PARA ATUALIZAR A TABELA DE PARAMETROS 
			LOGGANDO EM LOG_PARAMETROS 
			@@ROWCOUNT - VERIFICANDO SE HOUVE CONTEÚDO PARA GRAVAR EM UM ARQUIVO 
			*/ 

			IF ((SELECT TOP 1 NOMEARQREM 
				FROM TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO WITH (NOLOCK) 
				WHERE NOMEARQREM = @NOMEARQREM) = @NOMEARQREM) 
			BEGIN 

				DECLARE @NOVOULTNUMARQGERADO NUMERIC (10) 

				SELECT @NOVOULTNUMARQGERADO = CONVERT(NUMERIC(10), SUBSTRING(@NOMEARQREM, 27, 5)) --NNNNN 
				--ADDAXXX_XXXXXXXX_XXXXXXXX_NNNNN.XML 
				--ADDA567_90123456_89012345_78901.XML 

				INSERT INTO LOG_PARAMETROS ( 
					CAMPO, VALOR_ANT, VALOR_ATU, DATAATU, 
					TABELA, PK_REGISTRO, USUARIO 
				) 
				SELECT 
					'ULTNUMARQGERADO', CONVERT (VARCHAR(10), PARAMETROS.ULTNUMARQGERADO), CONVERT (VARCHAR(10), @NOVOULTNUMARQGERADO), GETDATE(), 
					'PARAMETROS', 'DDA-AUTK', 'SP_RES_MAN_TIT_GER_ARQ_THREADS' 
				FROM PARAMETROS 
				WHERE CODSISTEMA = 'DDA-AUTK' 
				AND ULTNUMARQGERADO < @NOVOULTNUMARQGERADO 

				UPDATE PARAMETROS SET 
					ULTNUMARQGERADO = @NOVOULTNUMARQGERADO 
				WHERE CODSISTEMA = 'DDA-AUTK' 
				AND ULTNUMARQGERADO < @NOVOULTNUMARQGERADO 
			END 

			/* 
			--28/03/2022 - ELIANE, RFAQUINI - FIM 
			*/ 

			/* 
			--SQL 2012+ 
			INSERT INTO TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO 
			(DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, NOMEARQREM, DATAHORAREM) 
			SELECT DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, @NOMEARQREM, @DATAHORAREM 
			FROM #TEMP_MANUT_TITULOS 
			ORDER BY DATAVENCIMENTO 
			OFFSET @INI_BLOCO ROWS 
			FETCH NEXT @TAM_BLOCO ROWS ONLY 
			*/ 

		COMMIT 

		SET @CONT_NOMEARQUIVO = @CONT_NOMEARQUIVO + 1 
	END 

	/* PROVAVELMENTE ESSA MESMA PROCEDURE SENDO EXECUTADA QUASE SIMULTANEAMENTE, GERANDO PK DUPLICADA... 
	O WORKFLOW DEVE SER SUSPENSO COM O RETORNO DE UM ERRO */ 
	IF @@ERROR != 0 
	BEGIN 
		SELECT 'S' ERRO 
		RETURN 
	END 

	-- ESSA TEMP EH UM ESPELHO DESSAS MANUTENCOES QUE ACABARAM DE SER RESERVADAS. RETORNAR PARA QUE SEJAM UTILIZADAS NA GERACAO DO ARQUIVO 
	--SELECT * FROM #TEMP_MANUT_TITULOS 

	/* 
	--28/03/2022 - ELIANE, RFAQUINI - ALTERAÇÃO DO RETORNO PARA VINCULAR O NOME DO ARQUIVO DE REMESSA 
	*/ 
	SELECT 
	#TEMP_MANUT_TITULOS.DATAPEDIDO, #TEMP_MANUT_TITULOS.DATALEGADO, #TEMP_MANUT_TITULOS.CODSISLEGADO, #TEMP_MANUT_TITULOS.NUMCTRLLEGADO, 
	#TEMP_MANUT_TITULOS.NUMPEDIDO, #TEMP_MANUT_TITULOS.NUMIDENTCDDA, #TEMP_MANUT_TITULOS.CODEVENTO, #TEMP_MANUT_TITULOS.CODIFSACADA, 
	#TEMP_MANUT_TITULOS.TIPOMANUTENCAOTIT, #TEMP_MANUT_TITULOS.CODIFCEDENTE, #TEMP_MANUT_TITULOS.TIPOPESCEDENTE, #TEMP_MANUT_TITULOS.CNPJ_CPF_CEDENTE, 
	#TEMP_MANUT_TITULOS.NOMEFANTASIACEDENTE, #TEMP_MANUT_TITULOS.NOMEFANTASIACEDENTEORI, #TEMP_MANUT_TITULOS.NOMEFANTASIASACADO, #TEMP_MANUT_TITULOS.NUMIDENTCBAIXAOPERAC, 

	#TEMP_MANUT_TITULOS.NUMREFBAIXAOPERAC, #TEMP_MANUT_TITULOS.NUMSEQBAIXAOPERAC, #TEMP_MANUT_TITULOS.NUMIDENTCBAIXAEFET, #TEMP_MANUT_TITULOS.NUMREFBAIXAEFET, 
	#TEMP_MANUT_TITULOS.NUMSEQBAIXAEFET, #TEMP_MANUT_TITULOS.ISPBCEDENTE, #TEMP_MANUT_TITULOS.ISPBSACADA, #TEMP_MANUT_TITULOS.CANALPAGTO, 
	#TEMP_MANUT_TITULOS.MEIOPAGTO, #TEMP_MANUT_TITULOS.NUMREFBAIXAOPERAC_RET, #TEMP_MANUT_TITULOS.NUMREFBAIXAEFET_RET, #TEMP_MANUT_TITULOS.NOMECEDENTE, 
	#TEMP_MANUT_TITULOS.TIPOPESCEDENTEORI, #TEMP_MANUT_TITULOS.CNPJ_CPF_CEDENTEORI, #TEMP_MANUT_TITULOS.NOMECEDENTEORI, #TEMP_MANUT_TITULOS.ENDCEDENTEORI, 

	#TEMP_MANUT_TITULOS.CIDCEDENTEORI, #TEMP_MANUT_TITULOS.UFCEDENTEORI, #TEMP_MANUT_TITULOS.CEPCEDENTEORI, #TEMP_MANUT_TITULOS.TIPOPESSACADO, 
	#TEMP_MANUT_TITULOS.CNPJ_CPF_SACADO, #TEMP_MANUT_TITULOS.NOMESACADO, #TEMP_MANUT_TITULOS.ENDSACADO, #TEMP_MANUT_TITULOS.CIDSACADO, 
	#TEMP_MANUT_TITULOS.UFSACADO, #TEMP_MANUT_TITULOS.CEPSACADO, #TEMP_MANUT_TITULOS.TIPOPESSACADOR, #TEMP_MANUT_TITULOS.CNPJ_CPF_SACADOR, 
	#TEMP_MANUT_TITULOS.NOMESACADOR, #TEMP_MANUT_TITULOS.CODCARTEIRA, #TEMP_MANUT_TITULOS.CODMOEDACNAB, #TEMP_MANUT_TITULOS.IDENTNOSSONUMERO, 
	
	#TEMP_MANUT_TITULOS.NUMCODBARRAS, #TEMP_MANUT_TITULOS.DATAVENCIMENTO, #TEMP_MANUT_TITULOS.VLRTITULO, #TEMP_MANUT_TITULOS.SEUNUMERO, 
	#TEMP_MANUT_TITULOS.CODESPECIEDOC, #TEMP_MANUT_TITULOS.DATAEMISSAO, #TEMP_MANUT_TITULOS.QTDEDIASPROTESTO, #TEMP_MANUT_TITULOS.DATALIMPAGTO, 
	#TEMP_MANUT_TITULOS.TIPOPAGTO, #TEMP_MANUT_TITULOS.INDTITULONEGOCIADO, #TEMP_MANUT_TITULOS.VLRABATIMENTO, #TEMP_MANUT_TITULOS.CODMORA, 
	#TEMP_MANUT_TITULOS.DATAMORA, #TEMP_MANUT_TITULOS.VLRPERCMORA, #TEMP_MANUT_TITULOS.CODMULTA, #TEMP_MANUT_TITULOS.DATAMULTA, 
	
	#TEMP_MANUT_TITULOS.VLRPERCMULTA, #TEMP_MANUT_TITULOS.CODDESCONTO01, #TEMP_MANUT_TITULOS.DATADESCONTO01, #TEMP_MANUT_TITULOS.VLRPERCDESCONTO01, 
	#TEMP_MANUT_TITULOS.CODDESCONTO02, #TEMP_MANUT_TITULOS.DATADESCONTO02, #TEMP_MANUT_TITULOS.VLRPERCDESCONTO02, #TEMP_MANUT_TITULOS.CODDESCONTO03, 
	#TEMP_MANUT_TITULOS.DATADESCONTO03, #TEMP_MANUT_TITULOS.VLRPERCDESCONTO03, #TEMP_MANUT_TITULOS.VLRMINTITULO, #TEMP_MANUT_TITULOS.VLRMAXTITULO, 
	#TEMP_MANUT_TITULOS.TIPOBAIXA, #TEMP_MANUT_TITULOS.DATAPAGTOBAIXA, #TEMP_MANUT_TITULOS.VLRPAGTOBAIXA, #TEMP_MANUT_TITULOS.ACEITE, 
	
	#TEMP_MANUT_TITULOS.NUMCTRLDDA, #TEMP_MANUT_TITULOS.DATAHORADDA, #TEMP_MANUT_TITULOS.TIPOPESTERCEIRO, #TEMP_MANUT_TITULOS.CNPJ_CPF_TERCEIRO, 
	#TEMP_MANUT_TITULOS.NUMIDENTCDDA2, #TEMP_MANUT_TITULOS.DATAVENCTOINI, #TEMP_MANUT_TITULOS.DATAVENCTOFIM, #TEMP_MANUT_TITULOS.DATACADASTINI, 
	#TEMP_MANUT_TITULOS.DATACADASTFIM, #TEMP_MANUT_TITULOS.TIPOCONSULTA, #TEMP_MANUT_TITULOS.CNPJBASE, #TEMP_MANUT_TITULOS.BUSCABASESACADO, 
	#TEMP_MANUT_TITULOS.CODSITUACAO, #TEMP_MANUT_TITULOS.TIPORETORNO, #TEMP_MANUT_TITULOS.SITUACAOPEDIDO, #TEMP_MANUT_TITULOS.CODRETORNO, 
	
	#TEMP_MANUT_TITULOS.NOMEARQRET, TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.NOMEARQREM, #TEMP_MANUT_TITULOS.TIPOCALCULO, #TEMP_MANUT_TITULOS.INDALTERAVALOR, 
	#TEMP_MANUT_TITULOS.DATACALCULO, #TEMP_MANUT_TITULOS.VLRCALCULADODESC, #TEMP_MANUT_TITULOS.VLRCALCULADOMORA, #TEMP_MANUT_TITULOS.VLRCALCULADOMULTA, 
	#TEMP_MANUT_TITULOS.VLRCOBRAR, #TEMP_MANUT_TITULOS.TIPOENVIO, #TEMP_MANUT_TITULOS.FORMAENVIO, #TEMP_MANUT_TITULOS.LINHADIGITAVEL, 
	#TEMP_MANUT_TITULOS.NUMPARCELA, #TEMP_MANUT_TITULOS.QTDPARCELA, #TEMP_MANUT_TITULOS.TIPOAUTRECDIVERGENTE, #TEMP_MANUT_TITULOS.INDBLOQUEIO, 
	
	#TEMP_MANUT_TITULOS.INDPARCIAL, #TEMP_MANUT_TITULOS.QTDPAGTO, #TEMP_MANUT_TITULOS.INDVALORPERC_MIN, #TEMP_MANUT_TITULOS.INDVALORPERC_MAX, 
	#TEMP_MANUT_TITULOS.NUMREFCADTIT, #TEMP_MANUT_TITULOS.NUMSEQCADTIT, #TEMP_MANUT_TITULOS.NUMREFACEITE, #TEMP_MANUT_TITULOS.NUMSEQACEITE, 
	#TEMP_MANUT_TITULOS.NUMREFTERC, #TEMP_MANUT_TITULOS.NUMSEQTERC, #TEMP_MANUT_TITULOS.NUMIDENTCTERC, #TEMP_MANUT_TITULOS.NUMREFACEITE_RET, 
	#TEMP_MANUT_TITULOS.NUMREFTERC_RET, #TEMP_MANUT_TITULOS.TIPOPESAUTORIZADOR, #TEMP_MANUT_TITULOS.CNPJ_CPF_AUTORIZADOR, #TEMP_MANUT_TITULOS.TIPOPESPORTADOR,
	
	#TEMP_MANUT_TITULOS.CNPJ_CPF_PORTADOR, 
	
	--19/11/2021 - RFAQUINI - INCLUSÃO E TRATAMENTO DO CAMPO NOME_PORTADOR (CATÁLOGO 5.03) 
	#TEMP_MANUT_TITULOS.NOME_PORTADOR, 
	
	--07/06/2022 - RFAQUINI - INCLUSÃO E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CATÁLOGO 5.04) 
	#TEMP_MANUT_TITULOS.DATAHORARECBTTITULO, 
	
	--23/01/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
	TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO,
	AGENCIARECEBEDORA,
	
	--02/02/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
	CODMOTIVO,

	#TEMP_MANUT_TITULOS.INDCONTINGENCIA, 
	#TEMP_MANUT_TITULOS.SPID, #TEMP_MANUT_TITULOS.DATAHORAPROCESSO, #TEMP_MANUT_TITULOS.NUMPEDIDOPEND, 
	#TEMP_MANUT_TITULOS.ERRO 
	FROM #TEMP_MANUT_TITULOS 
	INNER JOIN TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO 
		ON (#TEMP_MANUT_TITULOS.DATAPEDIDO = TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.DATAPEDIDO 
		AND #TEMP_MANUT_TITULOS.CODSISLEGADO = TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.CODSISLEGADO 
		AND #TEMP_MANUT_TITULOS.DATALEGADO = TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.DATALEGADO 
		AND #TEMP_MANUT_TITULOS.NUMCTRLLEGADO = TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.NUMCTRLLEGADO) 
	ORDER BY TEMP_MANUTENCAO_TITULO_GERACAO_ARQUIVO.NOMEARQREM 

	RETURN 

	TRATAERRO: 
		ROLLBACK TRANSACTION 
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
	'SP_RESERVAR_MANUTENCAO_TITULO_GERACAO_ARQUIVO_THREADS', 
	SYSTEM_USER, 
	GETDATE() 
GO