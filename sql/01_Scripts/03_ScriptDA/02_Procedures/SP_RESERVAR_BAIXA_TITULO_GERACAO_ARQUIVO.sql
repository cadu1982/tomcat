USE AB_DDA
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_RESERVAR_BAIXA_TITULO_GERACAO_ARQUIVO')
BEGIN
	EXEC ('CREATE PROCEDURE dbo.SP_RESERVAR_BAIXA_TITULO_GERACAO_ARQUIVO AS BEGIN RETURN END')
END
GO

ALTER PROCEDURE dbo.SP_RESERVAR_BAIXA_TITULO_GERACAO_ARQUIVO (
	@P_NOMEARQREM VARCHAR(255), 
	@P_QTD INT, 
	@P_CODEVENTO CHAR(4)
) AS 
BEGIN

	/*
		09/02/2023 - RFAQUINI - ALTERAÇÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
								DOS CODEVENTOS
								
		14/02/2023 - ELIANE, RFAQUINI - VALIDAÇÃO PARA BAIXAS EFETIVAS ENVIADAS PELA 108						
	
		@P_CODEVENTO PODE ASSUMIR
			8108 - ADDA0108 - BAIXA OPERACIONAL (CATÁLOGO <= 5.05) -> BAIXA (CATÁLOGO >= 5.06 - Modernização da Cobrança)
				(AB_COBRANCA..EVENTOS )
				0111 - BAIXA SIMPLES
				0112 - BAIXA COMANDADA PELO CLIENTE
				0113 - BAIXA P/INSTRUÇÃO CADAS.NO SISTEMA
				0114 - BAIXA P/INSTRUÇÃO CADAS NA ENTRADA
				0115 - BAIXA PELO PADRÃO DO BANCO
				0116 - BAIXA SIMPLES S/REMESSA CORRESP.
				0266 - TÍTULO PROTESTADO
				1101 - BAIXA TD - ESTORNO DE ENTRADA
				8108 - ?
				8511 - PEDIR BAIXA DE TITULO NA CIP
			
			8114 - ADDA0114 - BAIXA OPERACIONAL EM CONTINGÊNCIA
				8114 - ?
	*/

	DECLARE 
		@DATAHORAREM DATETIME, 
		@DATAULTPROCESSAMENTO DATETIME
	
	SELECT 
		@DATAHORAREM = GETDATE()
	
	SELECT 
		@DATAULTPROCESSAMENTO = DATAULTPROCESSAMENTO 
	FROM PARAMETROS

	-- SELECIONANDO TODAS AS MANUTENCOES PREPARADAS PARA ENVIO NO TIPO DE MANUTENCAO VISADO
	--09/02/2023 - RFAQUINI - ALTERAÇÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
	SELECT 
		DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, 
		NUMPEDIDO, NUMIDENTCDDA, CODEVENTO, CODIFSACADA, 
		TIPOMANUTENCAOTIT, CODIFCEDENTE, TIPOPESCEDENTE, CNPJ_CPF_CEDENTE, 
		NOMEFANTASIACEDENTE, NOMEFANTASIACEDENTEORI, NOMEFANTASIASACADO, NUMIDENTCBAIXAOPERAC, 
		
		NUMREFBAIXAOPERAC,NUMSEQBAIXAOPERAC, NUMIDENTCBAIXAEFET, NUMREFBAIXAEFET, 
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

		--(CATÁLOGO 5.03)
		NOME_PORTADOR, 
		
		--(CATÁLOGO 5.04)
		DATAHORARECBTTITULO, 
		
		--(CATÁLOGO 5.06 - Modernização da Cobrança)
		TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO,
		AGENCIARECEBEDORA, 
		
		--(CATÁLOGO 5.06 - Modernização da Cobrança)
		CODMOTIVO,
		
		INDCONTINGENCIA, SPID, DATAHORAPROCESSO, NUMPEDIDOPEND, 
		DATAHORACANCELAMENTOBAIXAOPERAC,
		CONVERT (CHAR, NULL) AS ERRO

		INTO #TEMP 
	FROM MANUT_TITULOS 
	WHERE 1 = 2
	
	IF (@P_CODEVENTO = '8114')
	BEGIN
		INSERT INTO #TEMP
		(
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

			--19/11/2021 - RFAQUINI, UAFERREIRA - INCLUSÃO E TRATAMENTO DO CAMPO NOME_PORTADOR (CATÁLOGO 5.03)
			NOME_PORTADOR, 
			
			--09/08/2022 - RFAQUINI- INCLUSÃO E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CATÁLOGO 5.04)	
			DATAHORARECBTTITULO, 
			
			--23/01/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
			TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO,
			AGENCIARECEBEDORA,
			--02/02/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
			CODMOTIVO,
			
			INDCONTINGENCIA, SPID, DATAHORAPROCESSO, NUMPEDIDOPEND, 
			DATAHORACANCELAMENTOBAIXAOPERAC,
			ERRO
		) 
		SELECT TOP(@P_QTD) 
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
			
			--19/11/2021 - RFAQUINI, UAFERREIRA - INCLUSÃO E TRATAMENTO DO CAMPO NOME_PORTADOR (CATÁLOGO 5.03)
			NOME_PORTADOR, 
			
			--09/08/2022 - RFAQUINI- INCLUSÃO E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CATÁLOGO 5.04)	
			DATAHORARECBTTITULO, 
			
			--23/01/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
			TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO,
			AGENCIARECEBEDORA,
			
			--02/02/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
			CODMOTIVO,
			
			INDCONTINGENCIA, SPID, DATAHORAPROCESSO, NUMPEDIDOPEND, 
			DATAHORACANCELAMENTOBAIXAOPERAC,
			CONVERT (CHAR, NULL) AS ERRO
		FROM MANUT_TITULOS
		WHERE MANUT_TITULOS.TIPOMANUTENCAOTIT = 'B' 
		AND MANUT_TITULOS.SITUACAOPEDIDO = '4' 
		AND CODEVENTO = @P_CODEVENTO
		AND TIPOENVIO = 'X' 
		AND MANUT_TITULOS.DATAPEDIDO >= @DATAULTPROCESSAMENTO
	END
	ELSE
	BEGIN
		INSERT INTO #TEMP
		(
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

			--19/11/2021 - RFAQUINI, UAFERREIRA - INCLUSÃO E TRATAMENTO DO CAMPO NOME_PORTADOR (CATÁLOGO 5.03)
			NOME_PORTADOR, 
			
			--09/08/2022 - RFAQUINI- INCLUSÃO E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CATÁLOGO 5.04)	
			DATAHORARECBTTITULO, 
			
			--23/01/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
			TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO,
			AGENCIARECEBEDORA,
			--02/02/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
			CODMOTIVO,
			
			INDCONTINGENCIA, SPID, DATAHORAPROCESSO, NUMPEDIDOPEND, 
			DATAHORACANCELAMENTOBAIXAOPERAC,
			ERRO
		) 
		SELECT TOP(@P_QTD) 
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
			
			--19/11/2021 - RFAQUINI, UAFERREIRA - INCLUSÃO E TRATAMENTO DO CAMPO NOME_PORTADOR (CATÁLOGO 5.03)
			NOME_PORTADOR, 
			
			--09/08/2022 - RFAQUINI- INCLUSÃO E TRATAMENTO DO CAMPO DATAHORARECBTTITULO (CATÁLOGO 5.04)	
			DATAHORARECBTTITULO, 
			
			--23/01/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
			TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO,
			AGENCIARECEBEDORA,
			
			--02/02/2023 - RFAQUINI - INCLUSÃO E TRATAMENTO (CATÁLOGO 5.06 - Modernização da Cobrança)
			CODMOTIVO,
			
			--14/02/2023 - ELIANE, RFAQUINI - VALIDAÇÃO PARA BAIXAS EFETIVAS ENVIADAS PELA 108
			ISNULL(INDCONTINGENCIA, 'N'), SPID, DATAHORAPROCESSO, NUMPEDIDOPEND, 
			DATAHORACANCELAMENTOBAIXAOPERAC,
			CONVERT (CHAR, NULL) AS ERRO
		FROM MANUT_TITULOS
		WHERE MANUT_TITULOS.TIPOMANUTENCAOTIT = 'B' 
		AND MANUT_TITULOS.SITUACAOPEDIDO = '4' 
		AND CODEVENTO IN (
			'0111', '0112', '0113', '0114', 
			'0115', '0116', '0266', '1101', 
			'8108', '8511'
		)
		AND TIPOENVIO = 'X' 
		AND MANUT_TITULOS.DATAPEDIDO >= @DATAULTPROCESSAMENTO
	END
	
	/* INCLUINDO A CHAVE DE TODAS AS MANUTENCOES QUE JA NAO ESTIVEREM NA TABELA QUE AUXILIA O WORKFLOW DE ARQUIVOS, 
	 JUNTO A MARCACAO DO ARQUIVO QUE ESTA SENDO PROCESSADO E O TIMESTAMP DESSA EXECUCAO */
	DELETE #TEMP 
	FROM 
		#TEMP, 
		TEMP_BAIXA_TITULO_GERACAO_ARQUIVO 
	WHERE #TEMP.DATAPEDIDO = TEMP_BAIXA_TITULO_GERACAO_ARQUIVO.DATAPEDIDO 
	AND #TEMP.DATALEGADO = TEMP_BAIXA_TITULO_GERACAO_ARQUIVO.DATALEGADO
	AND #TEMP.NUMCTRLLEGADO = TEMP_BAIXA_TITULO_GERACAO_ARQUIVO.NUMCTRLLEGADO 
	AND #TEMP.CODSISLEGADO = TEMP_BAIXA_TITULO_GERACAO_ARQUIVO.CODSISLEGADO

	INSERT INTO TEMP_BAIXA_TITULO_GERACAO_ARQUIVO (
		DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, NOMEARQREM, DATAHORAREM
	)
	SELECT 
		DATAPEDIDO, DATALEGADO, CODSISLEGADO, NUMCTRLLEGADO, @P_NOMEARQREM, @DATAHORAREM 
	FROM #TEMP

	/* PROVAVELMENTE ESSA MESMA PROCEDURE SENDO EXECUTADA QUASE SIMULTANEAMENTE, GERANDO PK DUPLICADA... 
	 O WORKFLOW DEVE SER SUSPENSO COM O RETORNO DE UM ERRO */
	IF @@ERROR != 0
	BEGIN
		SELECT 'S' ERRO
		RETURN
	END

	-- ESSA TEMP EH UM ESPELHO DESSAS MANUTENCOES QUE ACABARAM DE SER RESERVADAS. RETORNAR PARA QUE SEJAM UTILIZADAS NA GERACAO DO ARQUIVO
	SELECT * 
	FROM #TEMP

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
	'SP_RESERVAR_BAIXA_TITULO_GERACAO_ARQUIVO', 
	SYSTEM_USER, 
	GETDATE() 
GO