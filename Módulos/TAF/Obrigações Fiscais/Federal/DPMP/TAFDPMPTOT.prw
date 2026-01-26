#Include 'Protheus.ch'

Function TAFDPMPTOT(aWizard as array, nCont as numeric, aTotalizFn as array, aTotaliz as array)

	/* Variáveis - Arquivo Texto */
	Local cTxtSys as char
	Local nHandle as numeric
	Local cStrTxt as char	 
	
	/* Variáveis - Wizard */
	Local nAgentReg2 as numeric
	Local cMesRefer as char
	Local cAnoRefer as char
	
	Local dIni 	   as date
	Local dFin	   as date
	Local nX       as numeric	
	
	cTxtSys   := CriaTrab( , .F. ) + ".TXT"
	nHandle   := MsFCreate( cTxtSys )
	cStrTxt   := ""
	nAgentReg2 := aWizard[1][5]             // Cod. Regulador ANP
	cMesRefer := Substr(aWizard[1][3],1,2) // Mês Referência
	cAnoRefer := LTRIM(STR(aWizard[1][4])) // Ano Referência	
	dIni 	  := CTOD("01/"+Substr(aWizard[1][3],1,2)+"/"+LTRIM(STR(aWizard[1][4])))
	dFin	  := LastDay(dInicial)
	nX  	  := 0
	
	/* Gera os totalizadores por tipo, classe e finalidade */
	FOR nX := 1 TO Len(aTotalizFn)
	
		RetRegTot(@nCont,nAgentReg2,cMesRefer,cAnoRefer,aTotalizFn,@cStrTxt,nX)
		
	NEXT
	
	/* Gera os totalizadores ESTOQUE */
	RetRegEst(dIni, dFin, @nCont, nAgentReg2, (cMesRefer + cAnoRefer), @cStrTxt )
	
	/* Gera os totalizadores gerais (Entrada e Saída) */
	FOR nX := 1 TO Len(aTotaliz)
	
		RetRegTot(@nCont,nAgentReg2,cMesRefer,cAnoRefer,aTotaliz,@cStrTxt,nX)
		
	NEXT

	Begin Sequence
 		WrtStrTxt( nHandle, cStrTxt )
 		 				 	
 		GerTxtDPMP( nHandle, cTxtSys, "MOV_TOT" )
 	
 		Recover
		lFound := .F.
	End Sequence
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetRegTot

RetRegTot() - Retorna String com Registro Totalizador

@Author Francisco Kennedy Nunes Pinheiro
@Since 20/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function RetRegTot( nCont as numeric, nAgentReg2 as numeric, cMesRefer as char, cAnoRefer as char, aTotaliz as array, cStrTxt as char,  nX as numeric )

	/* Variáveis - Campos para geração */
	Local cOperacao  as char	
	Local cInstal1   as char
	Local cProdANP   as char
	Local nQtdPrdANP as numeric
	Local nQtdPrdKG  as numeric
	Local aDados     as array	
	
	cOperacao  := TRIM(aTotaliz[nX][1])
	cInstal1   := TRIM(aTotaliz[nX][2])
	cProdANP   := TRIM(aTotaliz[nX][3])
	nQtdPrdANP := aTotaliz[nX][4]  
	nQtdPrdKG  := aTotaliz[nX][5]
	aDados     := {}	
	
	aAdd(aDados, nCont)   		  		// 1 -  Contador Sequencial
	aAdd(aDados, nAgentReg2)     		// 2 -  Agente Regulado Informante
 	aAdd(aDados, (cMesRefer+cAnoRefer)) // 3 -  Mês de Referência (MMAAAA)
 	aAdd(aDados, VAL(cOperacao))  		// 4 -  Código da Operação
 	aAdd(aDados, VAL(cInstal1))  		// 5 -  Código da Instalação 1
 	aAdd(aDados, 0)     				// 6 -  Código da Instalação 2
 	aAdd(aDados, VAL(cProdANP))  		// 7 -  Código do Produto Operado
 	aAdd(aDados, nQtdPrdANP)     		// 8 -  Qtde. do Produto Operado na Unidade de Medida Oficial ANP
 	aAdd(aDados, nQtdPrdKG)     		// 9 -  Qtde. do Produto Operado em Quilogramas (KG)
 	
 	cStrTxt += TCriaLinha(aDados)
	
 	nCont++
Return( cStrTxt )


//-------------------------------------------------------------------
/*/{Protheus.doc} RetRegTot

RetRegTot() - Retorna String com Registro Totalizador

@Author Rafael Völtz
@Since 11/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
static function RetRegEst(dIni as date, dFin as date, nCont as numeric, nAgentReg2 as numeric, cPeriodo as char, cStrTxt as char )

	Local cAliasQry     as char
	Local aDados        as array
	Local cInstalEst    as char
	Local dIniAnt       as date
	Local dFinAnt       as date
	Local aInfoEUF		as array
	Local cCompC1L		as character
	Local cFilJT19		as character
	Local cJC1LxT19		as character

	dIniAnt := TAFSubMes( dIni , 1 )
	dFinAnt := LastDay(dIniAnt)

	cInstalEst  := POSICIONE("C1E",3,xFilial("C1E")+FWGETCODFILIAL+"1","C1E_CDINAN")
	cAliasQry 	:= GetNextAlias()
	
	//Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial
	aInfoEUF := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

	//Retorna o modo de compartilhamento para a tabela
	cCompC1L := Upper(AllTrim(FWModeAccess("C1L", 1) + FWModeAccess("C1L", 2) + FWModeAccess("C1L", 3)))

	cFilJT19 := "T19.T19_FILIAL"

	// Obtém as condições do join usando TAFCompDPMP e informações de aInfoEUF
	cJC1LxT19 := TAFCompDPMP("C1L", cCompC1L, aInfoEUF, cFilJT19)
 
	/* --------------------- ESTOQUE INICIAL --------------------- */
	/*IMPORTANTE: O estoque em terceiro está contido no estoque próprio, ou seja, se a empresa produziu 
	1.000 litros de um determinado produto e resolve armazenar em instalação de terceiro 300 litros, 
	deve-se declarar um estoque inicial sem movimentação próprio de 1.000 e um estoque inicial sem 
	movimentação em terceiros de 300. Não é possível indicar um estoque inicial sem movimentação em 
	terceiros maior que o estoque inicial próprio.
	*/ 

	BeginSql Alias cAliasQry
		SELECT C0G.C0G_CODIGO  C0G_CODIGO, 
				SUM (CASE WHEN T19_INDEST = '0' OR T19_INDEST = '1' THEN T19_QTDEST ELSE 0 END) QTD_PROPRIO,
				SUM (CASE WHEN T19_INDEST = '1' THEN T19_QTDEST ELSE 0 END) QTD_EMTERC,
				SUM (CASE WHEN T19_INDEST = '2' THEN T19_QTDEST ELSE 0 END) QTD_DETERC	 		   
			FROM %table:T18% T18
			INNER JOIN %table:T19% T19 ON T19.T19_FILIAL = T18.T18_FILIAL AND T19.T19_ID = T18.T18_ID 	AND T19.%NotDel%
			INNER JOIN %table:C1L% C1L %Exp:cJC1LxT19% AND C1L.C1L_ID = T19.T19_CODITE AND C1L.%NotDel%   
			INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%
			WHERE T18.T18_FILIAL = %xFilial:T18%
			AND T18.T18_DTINI >= %Exp: DTOS(dIniAnt)% 
			AND T18.T18_DTFIN <= %Exp: DTOS(dFinAnt)%
			AND C1L.C1L_CODANP IS NOT NULL
			AND C1L.C1L_CODANP != ' '
			AND T18.%NotDel%   
		GROUP BY C0G.C0G_CODIGO	   
		
	EndSql


	While !(cAliasQry)->(Eof())
		
	If (cAliasQry)->QTD_EMTERC > 0
		aDados := {}
		
		aAdd(aDados, nCont)   		  				// 1 -  Contador Sequencial
		aAdd(aDados, nAgentReg2)     				// 2 -  Agente Regulado Informante
		aAdd(aDados, cPeriodo)						// 3 -  Mês de Referência (MMAAAA)
		aAdd(aDados, 3010001)  						// 4 -  Código da Operação
		aAdd(aDados, VAL(cInstalEst))  				// 5 -  Código da Instalação 1
		aAdd(aDados, 0)     						// 6 -  Código da Instalação 2
		aAdd(aDados, VAL((cAliasQry)->C0G_CODIGO))  // 7 -  Código do Produto Operado
		aAdd(aDados, (cAliasQry)->QTD_EMTERC)     	// 8 -  Qtde. do Produto Operado na Unidade de Medida Oficial ANP
		aAdd(aDados, (cAliasQry)->QTD_EMTERC)     	// 9 -  Qtde. do Produto Operado em Quilogramas (KG)
		
		cStrTxt += TCriaLinha(aDados)
		nCont++
	EndIf

	If (cAliasQry)->QTD_DETERC > 0
		aDados := {}
		
		aAdd(aDados, nCont)   		  				// 1 -  Contador Sequencial
		aAdd(aDados, nAgentReg2)     				// 2 -  Agente Regulado Informante
		aAdd(aDados, cPeriodo)						// 3 -  Mês de Referência (MMAAAA)
		aAdd(aDados, 3010002)  						// 4 -  Código da Operação
		aAdd(aDados, VAL(cInstalEst))  				// 5 -  Código da Instalação 1
		aAdd(aDados, 0)     						// 6 -  Código da Instalação 2
		aAdd(aDados, VAL((cAliasQry)->C0G_CODIGO))  // 7 -  Código do Produto Operado
		aAdd(aDados, (cAliasQry)->QTD_DETERC)    	// 8 -  Qtde. do Produto Operado na Unidade de Medida Oficial ANP
		aAdd(aDados, (cAliasQry)->QTD_DETERC)    	// 9 -  Qtde. do Produto Operado em Quilogramas (KG)
		
		cStrTxt += TCriaLinha(aDados)
		nCont++
	EndIf 

	If (cAliasQry)->QTD_PROPRIO > 0
		aDados := {}
		
		aAdd(aDados, nCont)   		  				// 1 -  Contador Sequencial
		aAdd(aDados, nAgentReg2)     				// 2 -  Agente Regulado Informante
		aAdd(aDados, cPeriodo)						// 3 -  Mês de Referência (MMAAAA)
		aAdd(aDados, 3010003)  						// 4 -  Código da Operação
		aAdd(aDados, VAL(cInstalEst))  				// 5 -  Código da Instalação 1
		aAdd(aDados, 0)     						// 6 -  Código da Instalação 2
		aAdd(aDados, VAL((cAliasQry)->C0G_CODIGO))  // 7 -  Código do Produto Operado
		aAdd(aDados, (cAliasQry)->QTD_PROPRIO)     	// 8 -  Qtde. do Produto Operado na Unidade de Medida Oficial ANP
		aAdd(aDados, (cAliasQry)->QTD_PROPRIO)     	// 9 -  Qtde. do Produto Operado em Quilogramas (KG)
		
		cStrTxt += TCriaLinha(aDados)
		nCont++
	EndIf		
		
	(cAliasQry)->(DbSkip()) 	
	EndDo

	(cAliasQry)->(DbCloseArea())


	/* --------------------- ESTOQUE FINAL --------------------- */

	BeginSql Alias cAliasQry
		SELECT C0G.C0G_CODIGO  C0G_CODIGO, 
				SUM (CASE WHEN T19_INDEST = '0' OR T19_INDEST = '1' THEN T19_QTDEST ELSE 0 END) QTD_PROPRIO,
				SUM (CASE WHEN T19_INDEST = '1' THEN T19_QTDEST ELSE 0 END) QTD_EMTERC,
				SUM (CASE WHEN T19_INDEST = '2' THEN T19_QTDEST ELSE 0 END) QTD_DETERC
			FROM %table:T18% T18
			INNER JOIN %table:T19% T19 ON T19.T19_FILIAL = T18.T18_FILIAL AND T19.T19_ID = T18.T18_ID 	AND T19.%NotDel%
			INNER JOIN %table:C1L% C1L %Exp:cJC1LxT19% AND C1L.C1L_ID = T19.T19_CODITE AND C1L.%NotDel%   
			INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%  AND C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%
			WHERE T18.T18_FILIAL = %xFilial:T18%
			AND T18.T18_DTINI >= %Exp: DTOS(dIni)% 
			AND T18.T18_DTFIN <= %Exp: DTOS(dFin)%
			AND C1L.C1L_CODANP IS NOT NULL
			AND C1L.C1L_CODANP != ' '
			AND T18.%NotDel%
		GROUP BY C0G.C0G_CODIGO	  
	EndSql


	While !(cAliasQry)->(Eof())


	If (cAliasQry)->QTD_EMTERC > 0
		aDados := {}
		
		aAdd(aDados, nCont)   		  				// 1 -  Contador Sequencial
		aAdd(aDados, nAgentReg2)     				// 2 -  Agente Regulado Informante
		aAdd(aDados, cPeriodo)						// 3 -  Mês de Referência (MMAAAA)
		aAdd(aDados, 3020001)  						// 4 -  Código da Operação
		aAdd(aDados, VAL(cInstalEst))  				// 5 -  Código da Instalação 1
		aAdd(aDados, 0)     						// 6 -  Código da Instalação 2
		aAdd(aDados, VAL((cAliasQry)->C0G_CODIGO))  // 7 -  Código do Produto Operado
		aAdd(aDados, (cAliasQry)->QTD_EMTERC)     	// 8 -  Qtde. do Produto Operado na Unidade de Medida Oficial ANP
		aAdd(aDados, (cAliasQry)->QTD_EMTERC)     	// 9 -  Qtde. do Produto Operado em Quilogramas (KG)
		
		cStrTxt += TCriaLinha(aDados)
		nCont++
	EndIf

	If (cAliasQry)->QTD_DETERC > 0
		aDados := {}
		
		aAdd(aDados, nCont)   		  				// 1 -  Contador Sequencial
		aAdd(aDados, nAgentReg2)     				// 2 -  Agente Regulado Informante
		aAdd(aDados, cPeriodo)						// 3 -  Mês de Referência (MMAAAA)
		aAdd(aDados, 3020002)  						// 4 -  Código da Operação
		aAdd(aDados, VAL(cInstalEst))  				// 5 -  Código da Instalação 1
		aAdd(aDados, 0)     						// 6 -  Código da Instalação 2
		aAdd(aDados, VAL((cAliasQry)->C0G_CODIGO))  // 7 -  Código do Produto Operado
		aAdd(aDados, (cAliasQry)->QTD_DETERC)     	// 8 -  Qtde. do Produto Operado na Unidade de Medida Oficial ANP
		aAdd(aDados, (cAliasQry)->QTD_DETERC)     	// 9 -  Qtde. do Produto Operado em Quilogramas (KG)
		
		cStrTxt += TCriaLinha(aDados)
		nCont++
		EndIf	

	If (cAliasQry)->QTD_PROPRIO > 0
		aDados := {}
		
		aAdd(aDados, nCont)   		  				// 1 -  Contador Sequencial
		aAdd(aDados, nAgentReg2)     				// 2 -  Agente Regulado Informante
		aAdd(aDados, cPeriodo)						// 3 -  Mês de Referência (MMAAAA)
		aAdd(aDados, 3020003)  						// 4 -  Código da Operação
		aAdd(aDados, VAL(cInstalEst))  				// 5 -  Código da Instalação 1
		aAdd(aDados, 0)     						// 6 -  Código da Instalação 2
		aAdd(aDados, VAL((cAliasQry)->C0G_CODIGO))  // 7 -  Código do Produto Operado
		aAdd(aDados, (cAliasQry)->QTD_PROPRIO)     	// 8 -  Qtde. do Produto Operado na Unidade de Medida Oficial ANP
		aAdd(aDados, (cAliasQry)->QTD_PROPRIO)     	// 9 -  Qtde. do Produto Operado em Quilogramas (KG)
		
		cStrTxt += TCriaLinha(aDados)
		nCont++ 		
	EndIf
		
	(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

Return cStrTxt


//-------------------------------------------------------------------
/*/{Protheus.doc} TCriaLinha

TCriaLinha() - Retorna String com Registro Totalizador

@Author Rafael Völtz
@Since 11/01/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
static function TCriaLinha( aDados as array )
 Local cLinha  as char
	
	cLinha := StrZero(IIF(Len(aDados) < 1,  0, aDados[1]),10)	  // 1 -  Contador Sequencial
	cLinha += StrZero(IIF(Len(aDados) < 2,  0, aDados[2]),10)     // 2 -  Agente Regulado Informante
 	cLinha += (aDados[3])      		  							  // 3 -  Mês de Referência (MMAAAA)
 	cLinha += StrZero(IIF(Len(aDados) < 4,  0, aDados[4]),7)  	  // 4 -  Código da Operação
 	cLinha += StrZero(IIF(Len(aDados) < 5,  0, aDados[5]),7)  	  // 5 -  Código da Instalação 1
 	cLinha += StrZero(IIF(Len(aDados) < 6,  0, aDados[6]),7)      // 6 -  Código da Instalação 2
 	cLinha += StrZero(IIF(Len(aDados) < 7,  0, aDados[7]),9)  	  // 7 -  Código do Produto Operado
 	cLinha += StrTran(StrZero(IIF(Len(aDados) < 8,  0, aDados[8]),16,3),".","")     // 8 -  Qtde. do Produto Operado na Unidade de Medida Oficial ANP
 	cLinha += StrTran(StrZero(IIF(Len(aDados) < 9,  0, aDados[9]),16,3),".","")    // 9 -  Qtde. do Produto Operado em Quilogramas (KG)
 	cLinha += StrZero(IIF(Len(aDados) < 10, 0, aDados[10]),1)     // 10 - Código do Modal Utilizado na Movimentação
 	cLinha += StrZero(IIF(Len(aDados) < 11, 0, aDados[11]),7)     // 11 - Código do Veículo Utilizado no Modal
 	cLinha += StrZero(IIF(Len(aDados) < 12, 0, aDados[12]),14)    // 12 - Identificação do Terceiro Envolvido na Operação
 	cLinha += StrZero(IIF(Len(aDados) < 13, 0, aDados[13]),7)     // 13 - Código do Município (Origem/Destino)
 	cLinha += StrZero(IIF(Len(aDados) < 14, 0, aDados[14]),5)     // 14 - Código de Atividade Econômica do Terceiro
 	cLinha += StrZero(IIF(Len(aDados) < 15, 0, aDados[15]),4)     // 15 - Código do País (Origem/Destino)
 	cLinha += StrZero(IIF(Len(aDados) < 16, 0, aDados[16]),10)    // 16 - Número da Licença de Importação (LI)
 	cLinha += StrZero(IIF(Len(aDados) < 17, 0, aDados[17]),10)    // 17 - Número da Declaração de Importação (DI)
 	cLinha += StrZero(IIF(Len(aDados) < 18, 0, aDados[18]),7)     // 18 - Número da Nota Fiscal da Operação Comercial
 	cLinha += StrZero(IIF(Len(aDados) < 19, 0, aDados[19]),2)     // 19 - Código da Série da Nota Fiscal da Operação Comercial
 	cLinha += StrZero(IIF(Len(aDados) < 20, 0, aDados[20]),8)     // 20 - Data da Operação Comercial (DDMMAAAA)
 	cLinha += StrZero(IIF(Len(aDados) < 21, 0, aDados[21]),1)     // 21 - Código do Serviço Acordado (Dutos)
 	cLinha += StrZero(IIF(Len(aDados) < 22, 0, aDados[22]),3)     // 22 - Código da Característica Físico-Química do Produto
 	cLinha += StrZero(IIF(Len(aDados) < 23, 0, aDados[23]),3)     // 23 - Código do Método Utilizado para Aferição da Característica
 	cLinha += StrZero(IIF(Len(aDados) < 24, 0, aDados[24]),2)     // 24 - Código da Unidade de Medida da Característica
 	cLinha += StrZero(IIF(Len(aDados) < 25, 0, aDados[25]),10)    // 25 - Valor Encontrado da Característica
 	cLinha += StrZero(IIF(Len(aDados) < 26, 0, aDados[26]),9)     // 26 - Código do Produto/Operação Resultante
 	cLinha += StrZero(IIF(Len(aDados) < 27, 0, aDados[27]),7)     // 27 - Massa Específica do Produto
 	cLinha += StrZero(IIF(Len(aDados) < 28, 0, aDados[28]),2)     // 28 - Recipiente de GLP
 	cLinha += StrZero(IIF(Len(aDados) < 29, 0, aDados[29]),44)    // 29 - Chave de acesso da Nota Fiscal Eletrônica (NF-e)
 	cLinha += CRLF
 	
Return cLinha 
