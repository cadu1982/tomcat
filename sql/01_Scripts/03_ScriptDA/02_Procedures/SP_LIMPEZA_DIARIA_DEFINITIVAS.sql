﻿USE AB_DDA
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_LIMPEZA_DIARIA_DEFINITIVAS')
BEGIN
	EXEC ('CREATE PROCEDURE dbo.SP_LIMPEZA_DIARIA_DEFINITIVAS AS BEGIN RETURN END')
END
GO
ALTER PROCEDURE dbo.SP_LIMPEZA_DIARIA_DEFINITIVAS
AS
BEGIN

	/*
		13/12/2021 - RFAQUINI - ALTERAÇÃO PARA AB_DDAARQUIVADA

		15/07/2022 - RFAQUINI - INCLUSÃO E TRATAMENTO DOS CAMPOS NOME_PORTADOR E DATAHORARECBTTITULO (CATÁLOGOS 5.03 E 5.04)
	
		25/08/2022 - MSRODRIGUES, RFAQUINI - REMOÇÃO DE ORDERBY
											POIS TODO O RESULT TRAZIDO PODE SER MOVIDO PARA _PASS

											
		22/03/2023 - JLSANTOS - INCLUSÃO NA TABELA BAIXAS_OPERACIONAIS_PASS, TRATAMENTO DOS CAMPOS TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO E AGENCIARECEBEDORA (CATÁLOGO 5.06)
	*/
	
	DECLARE 
		@MSGERRO VARCHAR(255), 
		@DATALIMPEZA DATETIME, 
		@DATAPROCESSAMENTO DATETIME, 
		@DATAHORA DATETIME, 
		@SQLERRO INTEGER, 
		@INDLIMPEZA CHAR

	SELECT 
		@DATALIMPEZA = DATEADD (DD, -60, DATAPROCESSAMENTO), 
		@DATAPROCESSAMENTO = DATAPROCESSAMENTO, 
		@DATAHORA = GETDATE(), 
		@INDLIMPEZA = ISNULL(INDLIMPEZA, 'N')
	FROM PARAMETROS
	SELECT @SQLERRO = @@ERROR		 
	
	IF @SQLERRO <> 0 GOTO TRATAERRO

	IF (@INDLIMPEZA = 'N' 
		OR DATEDIFF (DD, @DATAPROCESSAMENTO, @DATAHORA) < -7 ) /* NÃO EXECUTA LIMPEZA SE A DATAPROCESSAMENTO FOR MAIOR QUE 7 DAIS DO RELÓGIO */
		RETURN 
		
	-------------------------------------------------------------------------------------------------------
	SELECT TOP 50000 TITULOS.NUMIDENTCDDA 
		INTO #TMP_TITULOS_SEL 
	FROM TITULOS 	
	INNER JOIN BAIXAS_EFETIVAS 
		ON (TITULOS.NUMIDENTCDDA = BAIXAS_EFETIVAS.NUMIDENTCDDA)
	WHERE TITULOS.CODSITUACAO NOT IN ('01', '1')
	AND TITULOS.DATAPAGTOBAIXA IS NOT NULL 
	AND TITULOS.DATAPAGTOBAIXA < @DATALIMPEZA
	AND BAIXAS_EFETIVAS.TIPOBAIXA < '5'
	GROUP BY TITULOS.NUMIDENTCDDA, TITULOS.DATAPAGTOBAIXA
	--25/08/2022 - MSRODRIGUES, RFAQUINI - REMOÇÃO DE ORDERBY

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	CREATE CLUSTERED INDEX IDX_TMP_TITULOS_SEL 
	ON #TMP_TITULOS_SEL (NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	INSERT INTO TITULOS_PASS (
		DATALIMPEZA, NUMIDENTCDDA, CODIFSACADA, CODIFCEDENTE, TIPOPESCEDENTE, CNPJ_CPF_CEDENTE, NOMECEDENTE, TIPOPESCEDENTEORI, 
		CNPJ_CPF_CEDENTEORI, NOMECEDENTEORI, ENDCEDENTEORI, CIDCEDENTEORI, UFCEDENTEORI, CEPCEDENTEORI, TIPOPESSACADO, CNPJ_CPF_SACADO, NOMESACADO, 
		ENDSACADO, CIDSACADO, UFSACADO, CEPSACADO, TIPOPESSACADOR, CNPJ_CPF_SACADOR, NOMESACADOR, CODCARTEIRA, CODMOEDACNAB, IDENTNOSSONUMERO, 
		NUMCODBARRAS, DATAVENCIMENTO, VLRTITULO, SEUNUMERO, CODESPECIEDOC, DATAEMISSAO, QTDEDIASPROTESTO, DATALIMPAGTO, TIPOPAGTO, 
		INDTITULONEGOCIADO, VLRABATIMENTO, CODMORA, DATAMORA, VLRPERCMORA, CODMULTA, DATAMULTA, VLRPERCMULTA, CODDESCONTO01, DATADESCONTO01, 
		VLRPERCDESCONTO01, CODDESCONTO02, DATADESCONTO02, VLRPERCDESCONTO02, CODDESCONTO03, DATADESCONTO03, VLRPERCDESCONTO03, ACEITE, 
		DATAACEITE, CODSITUACAO, TIPOBAIXA, VLRMINTITULO, VLRMAXTITULO, TIPOPESTERCEIRO, CNPJ_CPF_TERCEIRO, SITPAGAMENTO, CODSISLEGADO, 
		DTHRSITTITULO, TIPOCALCULO, INDALTERAVALOR, DATACALCULO, VLRCALCULADODESC, VLRCALCULADOMORA, VLRCALCULADOMULTA, VLRCOBRAR, 
		DATAPAGTOBAIXA, VLRPAGTOBAIXA, LINHADIGITAVEL, ISPBCEDENTE, ISPBSACADA, NUMPARCELA, QTDPARCELA, TIPOAUTRECDIVERGENTE, INDBLOQUEIO, 
		INDPARCIAL, QTDPAGTO, QTDPAGTOREG, INDVALORPERC_MIN, INDVALORPERC_MAX, NOMEFANTASIACEDENTE, NOMEFANTASIACEDENTEORI, NOMEFANTASIASACADO, 
		DATAINCLUSAO, DATAHORADDA, ULTNUMREFCADTIT, ULTNUMSEQCADTIT, ULTNUMREFBAIXAOPERAC, ULTNUMSEQBAIXAOPERAC, ULTNUMREFBAIXAEFET, 
		ULTNUMSEQBAIXAEFET, ULTNUMREFACEITE, ULTNUMSEQACEITE, ULTNUMREFTERC, ULTNUMSEQTERC, VLRSALDOATUAL, SITPAGAMENTOCIP, TIPOPESAUTORIZADOR, 
		CNPJ_CPF_AUTORIZADOR, INDCONTINGENCIA, TIPOPESPORTADOR, CNPJ_CPF_PORTADOR, MEIOPAGTO, CANALPAGTO
	)
	SELECT 
		@DATAPROCESSAMENTO, TITULOS.NUMIDENTCDDA, CODIFSACADA, CODIFCEDENTE, TIPOPESCEDENTE, CNPJ_CPF_CEDENTE, NOMECEDENTE, TIPOPESCEDENTEORI, 
		CNPJ_CPF_CEDENTEORI, NOMECEDENTEORI, ENDCEDENTEORI, CIDCEDENTEORI, UFCEDENTEORI, CEPCEDENTEORI, TIPOPESSACADO, CNPJ_CPF_SACADO, NOMESACADO, 
		ENDSACADO, CIDSACADO, UFSACADO, CEPSACADO, TIPOPESSACADOR, CNPJ_CPF_SACADOR, NOMESACADOR, CODCARTEIRA, CODMOEDACNAB, IDENTNOSSONUMERO, 
		NUMCODBARRAS, DATAVENCIMENTO, VLRTITULO, SEUNUMERO, CODESPECIEDOC, DATAEMISSAO, QTDEDIASPROTESTO, DATALIMPAGTO, TIPOPAGTO, 
		INDTITULONEGOCIADO, VLRABATIMENTO, CODMORA, DATAMORA, VLRPERCMORA, CODMULTA, DATAMULTA, VLRPERCMULTA, CODDESCONTO01, DATADESCONTO01, 
		VLRPERCDESCONTO01, CODDESCONTO02, DATADESCONTO02, VLRPERCDESCONTO02, CODDESCONTO03, DATADESCONTO03, VLRPERCDESCONTO03, ACEITE, 
		DATAACEITE, CODSITUACAO, TIPOBAIXA, VLRMINTITULO, VLRMAXTITULO, TIPOPESTERCEIRO, CNPJ_CPF_TERCEIRO, SITPAGAMENTO, CODSISLEGADO, 
		DTHRSITTITULO, TIPOCALCULO, INDALTERAVALOR, DATACALCULO, VLRCALCULADODESC, VLRCALCULADOMORA, VLRCALCULADOMULTA, VLRCOBRAR, 
		DATAPAGTOBAIXA, VLRPAGTOBAIXA, LINHADIGITAVEL, ISPBCEDENTE, ISPBSACADA, NUMPARCELA, QTDPARCELA, TIPOAUTRECDIVERGENTE, INDBLOQUEIO, 
		INDPARCIAL, QTDPAGTO, QTDPAGTOREG, INDVALORPERC_MIN, INDVALORPERC_MAX, NOMEFANTASIACEDENTE, NOMEFANTASIACEDENTEORI, NOMEFANTASIASACADO, 
		DATAINCLUSAO, DATAHORADDA, ULTNUMREFCADTIT, ULTNUMSEQCADTIT, ULTNUMREFBAIXAOPERAC, ULTNUMSEQBAIXAOPERAC, ULTNUMREFBAIXAEFET, 
		ULTNUMSEQBAIXAEFET, ULTNUMREFACEITE, ULTNUMSEQACEITE, ULTNUMREFTERC, ULTNUMSEQTERC, VLRSALDOATUAL, SITPAGAMENTOCIP, TIPOPESAUTORIZADOR, 
		CNPJ_CPF_AUTORIZADOR, INDCONTINGENCIA, TIPOPESPORTADOR, CNPJ_CPF_PORTADOR, MEIOPAGTO, CANALPAGTO
	FROM TITULOS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (TITULOS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO MODELO_PASS (
		DATALIMPEZA, NUMIDENTCDDA, SEQFATURA, SEQMODELO, CABECALHO, TPDADOS
	)
	SELECT 
		@DATAPROCESSAMENTO, MODELO.NUMIDENTCDDA, SEQFATURA, SEQMODELO, CABECALHO, TPDADOS
	FROM MODELO 
	INNER JOIN #TMP_TITULOS_SEL ON MODELO.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO ANEXO_FATURA_PASS (
		DATALIMPEZA, NUMIDENTCDDA, SEQFATURA, CODMODELO 
	)
	SELECT 
		@DATAPROCESSAMENTO, ANEXO_FATURA.NUMIDENTCDDA, SEQFATURA, CODMODELO 
	FROM ANEXO_FATURA 
	INNER JOIN #TMP_TITULOS_SEL ON ANEXO_FATURA.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO BAIXAS_EFETIVAS_PASS (
		DATALIMPEZA, NUMIDENTCDDA, NUMIDENTCBAIXAEFET, NUMCTRLDDA, NUMREFBAIXAEFET, NUMSEQBAIXAEFET, NUMREFCADTIT, NUMSEQCADTIT, 
		DATAMOVTO, DATAHORADDA, TIPOBAIXA, DATAHORABAIXA, DATABAIXA, VLRBAIXA, NUMCODBARRAS, DATAHORASITUACAO, ISPBCEDENTE, CODIFCEDENTE, 
		SITPAGTO, SITUACAOTIT, CANALPAGTO, MEIOPAGTO, NUMIDENTCBAIXAOPERAC, QTDPAGTOREG, VLRSALDOATUAL
	)
	SELECT 
		@DATAPROCESSAMENTO, BAIXAS_EFETIVAS.NUMIDENTCDDA, NUMIDENTCBAIXAEFET, NUMCTRLDDA, NUMREFBAIXAEFET, NUMSEQBAIXAEFET, NUMREFCADTIT, NUMSEQCADTIT, 
		DATAMOVTO, DATAHORADDA, TIPOBAIXA, DATAHORABAIXA, DATABAIXA, VLRBAIXA, NUMCODBARRAS, DATAHORASITUACAO, ISPBCEDENTE, CODIFCEDENTE, 
		SITPAGTO, SITUACAOTIT, CANALPAGTO, MEIOPAGTO, NUMIDENTCBAIXAOPERAC, QTDPAGTOREG, VLRSALDOATUAL
	FROM BAIXAS_EFETIVAS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (BAIXAS_EFETIVAS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO BAIXAS_OPERACIONAIS_PASS (
		DATALIMPEZA, NUMIDENTCDDA, NUMIDENTCBAIXAOPERAC, NUMCTRLDDA, NUMREFBAIXAOPERAC, NUMSEQBAIXAOPERAC, NUMREFCADTIT, NUMSEQCADTIT, DATAMOVTO, DATAHORADDA, 
		TIPOBAIXA, DATABAIXA, DATAHORABAIXA, VLRBAIXA, NUMCODBARRAS, SITBAIXA, DATAHORASITUACAO, ISPBSACADA, CODIFSACADA, NUMCTRLDDACANCEL, DATAHORACANCEL, 
		SITPAGTO, SITUACAOTIT, CANALPAGTO, MEIOPAGTO, INDCONTINGENCIA, TIPOPESPORTADOR, CNPJ_CPF_PORTADOR, QTDPAGTOREG, VLRSALDOATUAL, ORIGEMCANCELAMENTO,
		--15/07/2022 - RFAQUINI - INCLUSÃO E TRATAMENTO DOS CAMPOS NOME_PORTADOR E DATAHORARECBTTITULO (CATÁLOGOS 5.03 E 5.04)
		NOME_PORTADOR, DATAHORARECBTTITULO,
		--22/03/2023 - JLSANTOS - INCLUSÃO E TRATAMENTO DOS CAMPOS TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO E AGENCIARECEBEDORA (CATÁLOGO 5.06)
		TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO, AGENCIARECEBEDORA
	)
	SELECT 
		@DATAPROCESSAMENTO, BAIXAS_OPERACIONAIS.NUMIDENTCDDA, NUMIDENTCBAIXAOPERAC, NUMCTRLDDA, NUMREFBAIXAOPERAC, NUMSEQBAIXAOPERAC, NUMREFCADTIT, NUMSEQCADTIT, DATAMOVTO, DATAHORADDA, 
		TIPOBAIXA, DATABAIXA, DATAHORABAIXA, VLRBAIXA, NUMCODBARRAS, SITBAIXA, DATAHORASITUACAO, ISPBSACADA, CODIFSACADA, NUMCTRLDDACANCEL, DATAHORACANCEL, 
		SITPAGTO, SITUACAOTIT, CANALPAGTO, MEIOPAGTO, INDCONTINGENCIA, TIPOPESPORTADOR, CNPJ_CPF_PORTADOR, QTDPAGTOREG, VLRSALDOATUAL, ORIGEMCANCELAMENTO,
		--15/07/2022 - RFAQUINI - INCLUSÃO E TRATAMENTO DOS CAMPOS NOME_PORTADOR E DATAHORARECBTTITULO (CATÁLOGOS 5.03 E 5.04)
		NOME_PORTADOR, DATAHORARECBTTITULO,
		--22/03/2023 - JLSANTOS - INCLUSÃO E TRATAMENTO DOS CAMPOS TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO E AGENCIARECEBEDORA (CATÁLOGO 5.06)
		TIPOPESAGREGADOR, CNPJ_CPF_AGREGADOR, NOMEAGREGADOR, ISPBINICIADORPAGTO, AGENCIARECEBEDORA
	FROM BAIXAS_OPERACIONAIS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (BAIXAS_OPERACIONAIS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO CALCULOS_PASS (
		DATALIMPEZA, NUMIDENTCDDA, DATACALCULO, VLRMORA, VLRMULTA, VLRDESCONTO, VLRCOBRAR
	)
	SELECT 
		@DATAPROCESSAMENTO, CALCULOS.NUMIDENTCDDA, DATACALCULO, VLRMORA, VLRMULTA, VLRDESCONTO, VLRCOBRAR
	FROM CALCULOS
	INNER JOIN #TMP_TITULOS_SEL 
		ON (CALCULOS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO MENSAGENS_PASS (
		DATALIMPEZA, NUMIDENTCDDA, SEQMENSAGEM, TEXTO
	)
	SELECT 
		@DATAPROCESSAMENTO, MENSAGENS.NUMIDENTCDDA, SEQMENSAGEM, TEXTO
	FROM MENSAGENS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (MENSAGENS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO NOTAS_FISCAIS_PASS (
		DATALIMPEZA, NUMIDENTCDDA, NUMNOTAFISCAL, DATAEMISSAO, VLRNOTAFISCAL
	)
	SELECT 
		@DATAPROCESSAMENTO, NOTAS_FISCAIS.NUMIDENTCDDA, NUMNOTAFISCAL, DATAEMISSAO, VLRNOTAFISCAL
	FROM NOTAS_FISCAIS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (NOTAS_FISCAIS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO TERCEIROS_PASS (
		DATALIMPEZA, NUMIDENTCDDA, NUMIDENTCTERC, NUMCTRLDDA, NUMREFTERC, NUMSEQTERC, DATAMOVTO, 
		DATAHORADDA, TIPOPESTERC, CNPJ_CPF_TERC, TIPOPESAUTORIZADOR, CNPJ_CPF_AUTORIZADOR
	)
	SELECT 
		@DATAPROCESSAMENTO, TERCEIROS.NUMIDENTCDDA, NUMIDENTCTERC, NUMCTRLDDA, NUMREFTERC, NUMSEQTERC, DATAMOVTO, 
		DATAHORADDA, TIPOPESTERC, CNPJ_CPF_TERC, TIPOPESAUTORIZADOR, CNPJ_CPF_AUTORIZADOR
	FROM TERCEIROS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (TERCEIROS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS
	
	--DELETES
	DELETE MODELO 
	FROM MODELO 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (MODELO.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
		
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE ANEXO_FATURA 
	FROM ANEXO_FATURA 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (ANEXO_FATURA.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE BAIXAS_EFETIVAS 
	FROM BAIXAS_EFETIVAS
	INNER JOIN #TMP_TITULOS_SEL 
		ON (BAIXAS_EFETIVAS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE BAIXAS_OPERACIONAIS
	FROM BAIXAS_OPERACIONAIS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (BAIXAS_OPERACIONAIS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE CALCULOS 
	FROM CALCULOS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (CALCULOS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE MENSAGENS
	FROM MENSAGENS
	INNER JOIN #TMP_TITULOS_SEL 
		ON (MENSAGENS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE NOTAS_FISCAIS
	FROM NOTAS_FISCAIS
	INNER JOIN #TMP_TITULOS_SEL 
		ON (NOTAS_FISCAIS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE TERCEIROS 
	FROM TERCEIROS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (TERCEIROS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE TITULOS 
	FROM TITULOS 
	INNER JOIN #TMP_TITULOS_SEL 
		ON (TITULOS.NUMIDENTCDDA = #TMP_TITULOS_SEL.NUMIDENTCDDA)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	--DROPS
	DROP INDEX IDX_TMP_TITULOS_SEL ON dbo.#TMP_TITULOS_SEL
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	DROP TABLE #TMP_TITULOS_SEL
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO
	
	-------------------------------------------------------------------------------------------------------
	/*LIMPEZA DE TITULOS_SAC_EXC*/ 

	SELECT TOP 50000 SEQ_RECEBE, DATAMOVTO
		INTO #TMP_TITULOS_SACEXC_SEL 
	FROM TITULOS_SACEXC	
	WHERE DATAMOVTO < @DATALIMPEZA
	ORDER BY DATAMOVTO
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	CREATE CLUSTERED INDEX IDX_TMP_TITULOS_SACEXC_SEL
		ON dbo.#TMP_TITULOS_SACEXC_SEL
	(
		SEQ_RECEBE, DATAMOVTO
	)

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	INSERT INTO TITULOS_SACEXC_PASS ( 
		DATALIMPEZA, SEQ_RECEBE, DATAMOVTO, 
		NUMCTRLDDA, NUMIDENTCDDA, CODIFCEDENTE, 
		TIPOPESCEDENTE, CNPJ_CPF_CEDENTE, NOMECEDENTE, TIPOPESCEDENTEORI, CNPJ_CPF_CEDENTEORI, 
		NOMECEDENTEORI, ENDCEDENTEORI, CIDCEDENTEORI, UFCEDENTEORI, CEPCEDENTEORI, TIPOPESSACADO, 
		CNPJ_CPF_SACADO, NOMESACADO, ENDSACADO, CIDSACADO, UFSACADO, CEPSACADO, TIPOPESSACADOR, 
		CNPJ_CPF_SACADOR, NOMESACADOR, CODCARTEIRA, CODMOEDACNAB, IDENTNOSSONUMERO, LINHADIGITAVEL, 
		DATAVENCIMENTO, VLRTITULO, SEUNUMERO, CODESPECIEDOC, DATAEMISSAO, QTDEDIASPROTESTO, DATALIMPAGTO, 
		TIPOPAGTO, INDTITULONEGOCIADO, VLRABATIMENTO, DATAMORA, CODMORA, VLRPERCMORA, CODMULTA, DATAMULTA, 
		VLRPERCMULTA, DATADESCONTO01, CODDESCONTO01, VLRPERCDESCONTO01, DATADESCONTO02, CODDESCONTO02, 
		VLRPERCDESCONTO02, DATADESCONTO03, CODDESCONTO03, VLRPERCDESCONTO03, VLRMINTITULO, VLRMAXTITULO, 
		TIPOPESTERCEIRO, CNPJ_CPF_TERCEIRO, ACEITE, CODSITUACAO, BUSCABASESACADO, DATAMANUTENCAO, 
		NOMEARQRET, DTHRSITTITULO
	)
	SELECT 
		@DATAPROCESSAMENTO, TITULOS_SACEXC.SEQ_RECEBE, TITULOS_SACEXC.DATAMOVTO, 
		NUMCTRLDDA, NUMIDENTCDDA, CODIFCEDENTE, 
		TIPOPESCEDENTE, CNPJ_CPF_CEDENTE, NOMECEDENTE, TIPOPESCEDENTEORI, CNPJ_CPF_CEDENTEORI, 
		NOMECEDENTEORI, ENDCEDENTEORI, CIDCEDENTEORI, UFCEDENTEORI, CEPCEDENTEORI, TIPOPESSACADO, 
		CNPJ_CPF_SACADO, NOMESACADO, ENDSACADO, CIDSACADO, UFSACADO, CEPSACADO, TIPOPESSACADOR, 
		CNPJ_CPF_SACADOR, NOMESACADOR, CODCARTEIRA, CODMOEDACNAB, IDENTNOSSONUMERO, LINHADIGITAVEL, 
		DATAVENCIMENTO, VLRTITULO, SEUNUMERO, CODESPECIEDOC, DATAEMISSAO, QTDEDIASPROTESTO, DATALIMPAGTO, 
		TIPOPAGTO, INDTITULONEGOCIADO, VLRABATIMENTO, DATAMORA, CODMORA, VLRPERCMORA, CODMULTA, DATAMULTA, 
		VLRPERCMULTA, DATADESCONTO01, CODDESCONTO01, VLRPERCDESCONTO01, DATADESCONTO02, CODDESCONTO02, 
		VLRPERCDESCONTO02, DATADESCONTO03, CODDESCONTO03, VLRPERCDESCONTO03, VLRMINTITULO, VLRMAXTITULO, 
		TIPOPESTERCEIRO, CNPJ_CPF_TERCEIRO, ACEITE, CODSITUACAO, BUSCABASESACADO, DATAMANUTENCAO, 
		NOMEARQRET, DTHRSITTITULO
	FROM TITULOS_SACEXC 
	INNER JOIN #TMP_TITULOS_SACEXC_SEL 
		ON (TITULOS_SACEXC.SEQ_RECEBE = #TMP_TITULOS_SACEXC_SEL.SEQ_RECEBE
		AND TITULOS_SACEXC.DATAMOVTO = #TMP_TITULOS_SACEXC_SEL.DATAMOVTO)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO MENSAGENS_SACEXC_PASS ( 
		DATALIMPEZA, SEQ_RECEBE, DATAMOVTO, 
		NUMCTRLDDA, NUMIDENTCDDA, SEQMENSAGEM, TEXTO, NOMEARQRET
	)
	SELECT 
		@DATAPROCESSAMENTO, MENSAGENS_SACEXC.SEQ_RECEBE, MENSAGENS_SACEXC.DATAMOVTO, 
		NUMCTRLDDA, NUMIDENTCDDA, SEQMENSAGEM, TEXTO, NOMEARQRET
	FROM MENSAGENS_SACEXC 
	INNER JOIN #TMP_TITULOS_SACEXC_SEL 
		ON (MENSAGENS_SACEXC.SEQ_RECEBE = #TMP_TITULOS_SACEXC_SEL.SEQ_RECEBE
		AND MENSAGENS_SACEXC.DATAMOVTO = #TMP_TITULOS_SACEXC_SEL.DATAMOVTO)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	INSERT INTO NOTAS_FISCAIS_SACEXC_PASS ( 
		DATALIMPEZA, SEQ_RECEBE, DATAMOVTO, 
		NUMCTRLDDA, NUMIDENTCDDA, NUMNOTAFISCAL, DATAEMISSAO, 
		VLRNOTAFISCAL, NOMEARQRET
	)
	SELECT 
		@DATAPROCESSAMENTO, NOTAS_FISCAIS_SACEXC.SEQ_RECEBE, NOTAS_FISCAIS_SACEXC.DATAMOVTO, 
		NUMCTRLDDA, NUMIDENTCDDA, NUMNOTAFISCAL, DATAEMISSAO, 
		VLRNOTAFISCAL, NOMEARQRET
	FROM NOTAS_FISCAIS_SACEXC 
	INNER JOIN #TMP_TITULOS_SACEXC_SEL 
		ON (NOTAS_FISCAIS_SACEXC.SEQ_RECEBE = #TMP_TITULOS_SACEXC_SEL.SEQ_RECEBE
		AND NOTAS_FISCAIS_SACEXC.DATAMOVTO = #TMP_TITULOS_SACEXC_SEL.DATAMOVTO)

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	--DELETES
	DELETE MENSAGENS_SACEXC
	FROM MENSAGENS_SACEXC 
	INNER JOIN #TMP_TITULOS_SACEXC_SEL 
		ON (MENSAGENS_SACEXC.SEQ_RECEBE = #TMP_TITULOS_SACEXC_SEL.SEQ_RECEBE
		AND MENSAGENS_SACEXC.DATAMOVTO = #TMP_TITULOS_SACEXC_SEL.DATAMOVTO)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE NOTAS_FISCAIS_SACEXC
	FROM NOTAS_FISCAIS_SACEXC 
	INNER JOIN #TMP_TITULOS_SACEXC_SEL 
		ON (NOTAS_FISCAIS_SACEXC.SEQ_RECEBE = #TMP_TITULOS_SACEXC_SEL.SEQ_RECEBE
		AND NOTAS_FISCAIS_SACEXC.DATAMOVTO = #TMP_TITULOS_SACEXC_SEL.DATAMOVTO)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	DELETE TITULOS_SACEXC
	FROM TITULOS_SACEXC 
	INNER JOIN #TMP_TITULOS_SACEXC_SEL 
		ON (TITULOS_SACEXC.SEQ_RECEBE = #TMP_TITULOS_SACEXC_SEL.SEQ_RECEBE
		AND TITULOS_SACEXC.DATAMOVTO = #TMP_TITULOS_SACEXC_SEL.DATAMOVTO)
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO_TRANS

	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO
	-------------------------------------------------------------------------------------------------------
	--DROPS
	DROP INDEX IDX_TMP_TITULOS_SACEXC_SEL 
		ON dbo.#TMP_TITULOS_SACEXC_SEL
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO   

	DROP TABLE #TMP_TITULOS_SACEXC_SEL
	
	SELECT @SQLERRO = @@ERROR		 
	IF @SQLERRO <> 0 GOTO TRATAERRO

	RETURN
	-------------------------------------------------------------------------------------------------------
	TRATAERRO:
		SELECT @MSGERRO = CONVERT(VARCHAR(10), @SQLERRO)
		RAISERROR(@MSGERRO, 15, 1)
		RETURN
	TRATAERRO_TRANS:
		SELECT @MSGERRO = CONVERT(VARCHAR(10), @SQLERRO)
		RAISERROR(@MSGERRO, 15, 1)
		RETURN

END
GO

INSERT INTO VERSAO_SISTEMA (
	[VERSAO], 
	[NOMESCRIPT], 
	[CODUSUARIO], 
	[DATAATU])
SELECT 
	'V15_01_1_01B', 
	'SP_LIMPEZA_DIARIA_DEFINITIVAS', 
	SYSTEM_USER, 
	GETDATE() 
GO