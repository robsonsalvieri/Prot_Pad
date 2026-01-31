#Include 'Protheus.ch'

Function TAFDPMPPRD(aWizard, nCont, aTotalizFn, aTotaliz)
	
	/* Variáveis - Arquivo Texto */
	Local cTxtSys := CriaTrab( , .F. ) + ".TXT"
	Local nHandle := MsFCreate( cTxtSys )
	Local cStrTxt := ""
	
	/* Variáveis - SQL */
	Local cAliasProd := GetNextAlias() 
	Local cAliasIns  := GetNextAlias()
		
	/* Variáveis - Wizard */
	Local cAgentReg := aWizard[1][5]             // Cod. Regulador ANP
	Local cMesRefer := Substr(aWizard[1][3],1,2) // Mês Referência
	Local cAnoRefer := LTRIM(STR(aWizard[1][4])) // Ano Referência
				
	Local cDtIniRef := CTOD("01/"+cMesRefer+"/"+cAnoRefer)
	Local cDtFimRef := Lastday(stod(cAnoRefer+cMesRefer+'01'),0)
		
	/* Variáveis - Campos para geração */
	Local cOperacao  := ""
	Local cInstal1   := ""
	Local cProdANP   := ""
	Local cProdutoR  := ""
	Local nQtdPrdANP := 0

	//Inicializo as variáves para o controle do compartilhamento no JOIN
	Local aInfoEUF	 := {}
	Local cCompC1L	 := ""
	Local cFilJT21	 := ""
	Local cFilJT22	 := ""
	Local cJC1LxT21  := ""
	Local cJC1L_I    := ""
	Local cJC1L_P	 := ""
			
	/* Busca o Código da Instalação ANP da Filial */	
	cInstal1 := POSICIONE("C1E",3,xFilial("C1E")+FWGETCODFILIAL+"1","C1E_CDINAN")

	//Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial
	aInfoEUF := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	
	//Retorna o modo de compartilhamento para a tabela
	cCompC1L := Upper(AllTrim(FWModeAccess("C1L", 1) + FWModeAccess("C1L", 2) + FWModeAccess("C1L", 3)))

	cFilJT21 := "T21.T21_FILIAL"
	cFilJT22 := "T22.T22_FILIAL"

	// Obtém as condições de join usando TAFCompDPMP e informações de aInfoEUF
	cJC1LxT21 := TAFCompDPMP("C1L",   cCompC1L, aInfoEUF, cFilJT21)
	cJC1L_I   := TAFCompDPMP("C1L_I", cCompC1L, aInfoEUF, cFilJT22)
	cJC1L_P   := TAFCompDPMP("C1L_P", cCompC1L, aInfoEUF, cFilJT21)
				
	BeginSql Alias cAliasProd
		SELECT	C0G.C0G_CODIGO COD_ANP,
		       SUM(T21.T21_QTDPRO) QTD_PROD,
		       C1L.C1L_TPPRD TP_PRD
		  FROM %table:T18% T18
		   INNER JOIN %table:T21% T21 ON T21.T21_FILIAL = T18.T18_FILIAL AND T21.T21_ID = T18.T18_ID AND T21.%NotDel%
		   INNER JOIN %table:C1L% C1L %Exp:cJC1LxT21% AND C1L.C1L_ID = T21.T21_CODITE AND C1L.%NotDel%
		   INNER JOIN %table:C0G% C0G ON C0G.C0G_ID = C1L.C1L_CODANP AND C0G.%NotDel%			  	
		WHERE T18.T18_FILIAL = %xFilial:T18%
		  AND T18.T18_DTINI >= %Exp:DTOS(cDtIniRef)%
		  AND T18.T18_DTFIN <= %Exp:DTOS(cDtFimRef)%
		  AND T18.%NotDel%	
		GROUP BY C0G.C0G_CODIGO,
				  C1L.C1L_TPPRD	
	EndSql
	
	While !(cAliasProd)->(Eof())
	
		cOperacao := "1021004" // Cod. Operação ANP de Produção por Mistura
	
		If (cAliasProd)->TP_PRD = "2"
			cOperacao := "1021002" // Cod. Operação ANP de Produção Própria
		ElseIf (cAliasProd)->TP_PRD = "3"
			cOperacao := "1021005" // Cod. Operação ANP de Produção por Reprocessamento
		EndIf	
		
		cProdANP   := (cAliasProd)->COD_ANP  // Produto Operado ANP
		nQtdPrdANP := (cAliasProd)->QTD_PROD // Quantidade Produzida do Item
							
		cStrTxt := StrZero(nCont,10)         // Contador Sequencial
		cStrTxt += StrZero(cAgentReg,10)     // Agente Regulado Informante
	 	cStrTxt += (cMesRefer+cAnoRefer)     // Mês de Referência (MMAAAA)
	 	cStrTxt += StrZero(VAL(cOperacao),7) // Código da Operação
	 	cStrTxt += StrZero(VAL(cInstal1),7)  // Código da Instalação 1
	 	cStrTxt += StrZero(VAL(""),7)        // Código da Instalação 2
	 	cStrTxt += StrZero(VAL(cProdANP),9)  // Código do Produto Operado
	 	cStrTxt += StrZero(nQtdPrdANP,15)    // Qtde. do Produto Operado na Unidade de Medida Oficial ANP
	 	cStrTxt += StrZero(nQtdPrdANP,15)    // Qtde. do Produto Operado em Quilogramas (KG)
	 	cStrTxt += StrZero(VAL(""),1)        // Código do Modal Utilizado na Movimentação
	 	cStrTxt += StrZero(VAL(""),7)        // Código do Veículo Utilizado no Modal
	 	cStrTxt += StrZero(VAL(""),14)       // Identificação do Terceiro Envolvido na Operação
	 	cStrTxt += StrZero(VAL(""),7)        // Código do Município (Origem/Destino)
	 	cStrTxt += StrZero(VAL(""),5)        // Código de Atividade Econômica do Terceiro
	 	cStrTxt += StrZero(VAL(""),4)        // Código do País (Origem/Destino)
	 	cStrTxt += StrZero(VAL(""),10)       // Número da Licença de Importação (LI)
	 	cStrTxt += StrZero(VAL(""),10)       // Número da Declaração de Importação (DI)
	 	cStrTxt += StrZero(VAL(""),7)        // Número da Nota Fiscal da Operação Comercial
	 	cStrTxt += StrZero(VAL(""),2)        // Código da Série da Nota Fiscal da Operação Comercial
	 	cStrTxt += StrZero(VAL(""),8)        // Data da Operação Comercial (DDMMAAAA)
	 	cStrTxt += StrZero(VAL(""),1)        // Código do Serviço Acordado (Dutos)
	 	cStrTxt += StrZero(VAL(""),3)        // Código da Característica Físico-Química do Produto
	 	cStrTxt += StrZero(VAL(""),3)        // Código do Método Utilizado para Aferição da Característica
	 	cStrTxt += StrZero(VAL(""),2)        // Código da Unidade de Medida da Característica
	 	cStrTxt += StrZero(VAL(""),10)       // Valor Encontrado da Característica
	 	cStrTxt += StrZero(VAL(""),9)        // Código do Produto/Operação Resultante
	 	cStrTxt += StrZero(VAL(""),7)        // Massa Específica do Produto
	 	cStrTxt += StrZero(VAL(""),2)        // Recipiente de GLP
	 	cStrTxt += StrZero(VAL(""),44)       // Chave de acesso da Nota Fiscal Eletrônica (NF-e)
	 	cStrTxt += CRLF
	 		 	
	 	/* Realiza a soma das quantidades para os registros de Totalização */
	 	SomaOpTot(nQtdPrdANP, nQtdPrdANP, cOperacao, cInstal1, cProdANP, "0", @aTotalizFn, @aTotaliz)
	 	
	 	WrtStrTxt( nHandle, cStrTxt )
	 														 				 				
	 	nCont++
	 	
	 	(cAliasProd)->(DbSkip())		
	EndDo
	(cAliasProd)->(DbCloseArea())
	
	BeginSql Alias cAliasIns
		SELECT	C0G_I.C0G_CODIGO COD_ANP_I,
				C0G_P.C0G_CODIGO COD_ANP_P,
		       SUM(T22.T22_QTDCON) QTD_CON,
		       C1L_I.C1L_TPPRD TP_PRD		       
		  FROM %table:T18% T18
		   INNER JOIN %table:T21% T21 ON T21.T21_FILIAL = T18.T18_FILIAL AND T21.T21_ID = T18.T18_ID AND T21.%NotDel%
		   INNER JOIN %table:T22% T22 ON T22.T22_FILIAL = T21.T21_FILIAL AND T22.T22_CODOP = T21.T21_CODOP AND T22.T22_CODITE = T21.T21_CODITE AND T22.%NotDel%
		   INNER JOIN %table:C1L% C1L_I %Exp:cJC1L_I% AND C1L_I.C1L_ID = T22.T22_CODINS AND C1L_I.%NotDel%
		   INNER JOIN %table:C1L% C1L_P %Exp:cJC1L_P% AND C1L_P.C1L_ID = T21.T21_CODITE AND C1L_P.%NotDel%
		   INNER JOIN %table:C0G% C0G_I ON C0G_I.C0G_ID = C1L_I.C1L_CODANP AND C0G_I.%NotDel%			  	
		   LEFT JOIN %table:C0G% C0G_P ON C0G_P.C0G_ID = C1L_P.C1L_CODANP AND C0G_P.%NotDel%
		   //Trazer todos os insumos(T22) com ANP mesmo que o produto final(T21) não possua código ANP
		   //
		WHERE T18.T18_FILIAL = %xFilial:T18%
		  AND T18.T18_DTINI >= %Exp:DTOS(cDtIniRef)%
		  AND T18.T18_DTFIN <= %Exp:DTOS(cDtFimRef)%
		  AND T18.%NotDel%	
		GROUP BY C0G_I.C0G_CODIGO,
				  C0G_P.C0G_CODIGO,
				  C1L_I.C1L_TPPRD	
	EndSql
	
	While !(cAliasIns)->(Eof())
	
		cOperacao := "1022015" // Cod. Operação ANP de Saída para Produção por Mistura
	
		If (cAliasIns)->TP_PRD = "3"
			cOperacao := "1022018" // Cod. Operação ANP de Saída para Reprocessamento
		Elseif Empty((cAliasIns)->COD_ANP_P)
			cOperacao := "1022002"
		EndIf
		
		cProdANP   := (cAliasIns)->COD_ANP_I // Produto Operado ANP
		cProdutoR  := (cAliasIns)->COD_ANP_P // Produto/Operação Resultante
		nQtdPrdANP := (cAliasIns)->QTD_CON   // Quantidade Consumida do Item		
		
		cStrTxt := StrZero(nCont,10)         // Contador Sequencial
		cStrTxt += StrZero(cAgentReg,10)     // Agente Regulado Informante
	 	cStrTxt += (cMesRefer+cAnoRefer)     // Mês de Referência (MMAAAA)
	 	cStrTxt += StrZero(VAL(cOperacao),7) // Código da Operação
	 	cStrTxt += StrZero(VAL(cInstal1),7)  // Código da Instalação 1
	 	cStrTxt += StrZero(VAL(""),7)        // Código da Instalação 2
	 	cStrTxt += StrZero(VAL(cProdANP),9)  // Código do Produto Operado
	 	cStrTxt += StrZero(nQtdPrdANP,15)    // Qtde. do Produto Operado na Unidade de Medida Oficial ANP
	 	cStrTxt += StrZero(nQtdPrdANP,15)    // Qtde. do Produto Operado em Quilogramas (KG)
	 	cStrTxt += StrZero(VAL(""),1)        // Código do Modal Utilizado na Movimentação
	 	cStrTxt += StrZero(VAL(""),7)        // Código do Veículo Utilizado no Modal
	 	cStrTxt += StrZero(VAL(""),14)       // Identificação do Terceiro Envolvido na Operação
	 	cStrTxt += StrZero(VAL(""),7)        // Código do Município (Origem/Destino)
	 	cStrTxt += StrZero(VAL(""),5)        // Código de Atividade Econômica do Terceiro
	 	cStrTxt += StrZero(VAL(""),4)        // Código do País (Origem/Destino)
	 	cStrTxt += StrZero(VAL(""),10)       // Número da Licença de Importação (LI)
	 	cStrTxt += StrZero(VAL(""),10)       // Número da Declaração de Importação (DI)
	 	cStrTxt += StrZero(VAL(""),7)        // Número da Nota Fiscal da Operação Comercial
	 	cStrTxt += StrZero(VAL(""),2)        // Código da Série da Nota Fiscal da Operação Comercial
	 	cStrTxt += StrZero(VAL(""),8)        // Data da Operação Comercial (DDMMAAAA)
	 	cStrTxt += StrZero(VAL(""),1)        // Código do Serviço Acordado (Dutos)
	 	cStrTxt += StrZero(VAL(""),3)        // Código da Característica Físico-Química do Produto
	 	cStrTxt += StrZero(VAL(""),3)        // Código do Método Utilizado para Aferição da Característica
	 	cStrTxt += StrZero(VAL(""),2)        // Código da Unidade de Medida da Característica
	 	cStrTxt += StrZero(VAL(""),10)       // Valor Encontrado da Característica
	 	cStrTxt += StrZero(VAL(cProdutoR),9) // Código do Produto/Operação Resultante
	 	cStrTxt += StrZero(VAL(""),7)        // Massa Específica do Produto
	 	cStrTxt += StrZero(VAL(""),2)        // Recipiente de GLP
	 	cStrTxt += StrZero(VAL(""),44)       // Chave de acesso da Nota Fiscal Eletrônica (NF-e)
	 	cStrTxt += CRLF
		
		/* Realiza a soma das quantidades para os registros de Totalização */
	 	SomaOpTot(nQtdPrdANP, nQtdPrdANP, cOperacao, cInstal1, cProdANP, "1", @aTotalizFn, @aTotaliz)
	 	
	 	WrtStrTxt( nHandle, cStrTxt )
	 	
	 	nCont++
	
		(cAliasIns)->(DbSkip())
	EndDo
	(cAliasIns)->(DbCloseArea())
	
	Begin Sequence 		 		 				 
 		GerTxtDPMP( nHandle, cTxtSys, "MOV_PRD" )
 	
 		Recover
		lFound := .F.
	End Sequence
	
Return
