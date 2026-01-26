#Include 'Protheus.ch'

Function TAFDPMPDOC(aWizard, nCont, aTotalizFn, aTotaliz)

	/* Variáveis - Arquivo Texto */
	Local cTxtSys := CriaTrab( , .F. ) + ".TXT"
	Local nHandle := MsFCreate( cTxtSys )
	Local cStrTxt := ""

	/* Variáveis - Wizard */
	Local cAgentReg := aWizard[1][5]             // Cod. Regulador ANP
	Local cMesRefer := Substr(aWizard[1][3],1,2) // Mês Referência
	Local cAnoRefer := LTRIM(STR(aWizard[1][4])) // Ano Referência

	Local cDtIniRef := CTOD("01/"+cMesRefer+"/"+cAnoRefer)
	Local cDtFimRef := Lastday(stod(cAnoRefer+cMesRefer+'01'),0)

	
	/* Variáveis - SQL */
	Local cAlias1	   := GetNextAlias()
	Local cAlias3	   := GetNextAlias()
	Local cAlias4	   := GetNextAlias()

	/* Variáveis - Funções */
	Local aDadosItem := {}
	Local aDadosPart := {}
	Local aSerie 	 := {}
	Local cInstalEst := ""
	Local cInstalPar := ""

	/* Variáveis - Campos para geração */
	Local cOperacao  := ""
	Local cInstal1   := ""
	Local cInstal2   := ""
	Local cProdANP   := ""
	Local nQtdPrdANP := 0
	Local cModal     := ""
	Local cVeiculo   := ""
	Local cIdentTerc := ""
	Local cMunicANP  := ""
	Local cAtivEcon  := ""
	Local cPaisANP   := ""
	Local nNumeroLI  := 0
	Local nNumeroDI  := 0
	Local cNotaFisc  := ""
	Local cSerNotFis := ""
	Local cDtOperac  := ""
	Local cServDutos := ""
	Local cCaracFisQ := ""
	Local cCaracNaoM := ""
	Local cMetodoAfe := ""
	Local cUniMedDes := ""
	Local cValorCar  := 0
	Local cCodPrdRes := ""
	Local nMassaEsp  := 0
	Local cRecipGLP  := ""
	Local cChaveAces := ""
	Local cModFrt    := SPACE(02)
	Local cSelect    := ""
	Local cGroupBy   := ""	
	Local cNotIn     := ""
	Local aRemessa   := {}
	Local cNatCtaOrd := ""
	Local nPos       := 0
	
	//Inicializo as variáves para o controle do compartilhamento no JOIN
	Local aInfoEUF	 := {}
	Local cCompC1L   := ""
	Local cCompC1N   := ""
	Local cJC1LxC30	 := ""
	Local cJC1NxC30  := "" 
	Local cFilJC30	 := ""

	cNatCtaOrd := TDPMP456(cDtIniRef)  
	/* Busca o Código da Instalação ANP da Filial */
	cInstalEst := POSICIONE("C1E",3,xFilial("C1E")+FWGETCODFILIAL+"1","C1E_CDINAN")

	cFilJC30   := "C30.C30_FILIAL"

	//Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial
	aInfoEUF := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	
	//Retorna o modo de compartilhamento para a tabela
	cCompC1L := Upper(AllTrim(FWModeAccess("C1L", 1) + FWModeAccess("C1L", 2) + FWModeAccess("C1L", 3)))
	cCompC1N := Upper(AllTrim(FWModeAccess("C1N", 1) + FWModeAccess("C1N", 2) + FWModeAccess("C1N", 3)))

	// Obtém as condições de join usando TAFCompDPMP e informações de aInfoEUF
	cJC1LxC30 := TAFCompDPMP("C1L", cCompC1L, aInfoEUF, cFilJC30)
	cJC1NxC30 := TAFCompDPMP("C1N", cCompC1N, aInfoEUF, cFilJC30)

	/* Busca notas de Remessa das Operações de Conta e Ordem */
	If !Empty(cNatCtaOrd)
		cAlias4 := TDPMPTerc(cNatCtaOrd, cDtIniRef, cDtFimRef)
		
		While (cAlias4)->(!EOF())
			
			Iif (!Empty(cNotIn),cNotIn += ", ","")		 
			cNotIn +=  "'" + Alltrim((cAlias4)->C26_CHVNF) + "'"
			cChvVend := getChvVnd((cAlias4)->C26_CODMOD, (cAlias4)->C26_INDOPE, (cAlias4)->C26_INDEMI, (cAlias4)->C26_CODPAR, (cAlias4)->C26_SERIE, (cAlias4)->C26_SUBSER, (cAlias4)->C26_NUMDOC, (cAlias4)->C26_DTDOC)
			cPart  := POSICIONE("C20",4,xFilial("C20")+(cAlias4)->C26_CHVNF,"C20_CODPAR")
			
			// Armazena chave da venda, chave da remessa e cód. participante da remessa
			aAdd(aRemessa, {cChvVend, (cAlias4)->C26_CHVNF, cPart })
			( cAlias4 )->( DbSkip() )
		
		EndDo
		
		( cAlias4 )->( DbCloseArea() )
		
		If !Empty(cNotIn)
			cNotIn := "% AND C20.C20_CHVNF NOT IN (" + cNotIn + ")%"
		Else
			cNotIn := "%%"
		EndIf
	Else
		cNotIn := "%%"
	EndIf
		
	//Carrega Array com as Séries da Dpmp
	CarregaSer(@aSerie)
	cSelect := "%"
	cSelect += "C20_NUMDOC 		NUM_DOC,"
	cSelect += "C20_SERIE  		SERIE,"
	cSelect += "C20_CHVELE 		CHAVE_ACE,"
	cSelect += "(CASE WHEN C20_INDOPE = '0' THEN C20_DTES WHEN C20_INDOPE = '1' THEN C20_DTDOC END) DTA_ES,"
	cSelect += "C20_TPDOC  		TIP_DOC,"
	cSelect += "C20_CODPAR 		COD_PART,"
	cSelect += "C20_INDOPE 		IND_OPER,"
	cSelect += "C30_CODITE 		COD_ITEM,"
	cSelect += "C30_UM 	   		UNID_MED,"
	cSelect += "SUM(C30_QUANT)  QUANT_ITEM,"
	cSelect += "C30_CHVNF  		CHVNF,"
	cSelect += "T5A_CODOPE 		COD_OPER,"
	cSelect += "C0X_CODIGO      IND_FRETE,"
	
	If TAFColumnPos("C30_LICIMP")			
		cSelect += "C30_LICIMP      LICIMP,"
		cSelect += "C1N_CODNAT      CODNAT"
	Else
		cSelect += "C1N_CODNAT      CODNAT"
	EndIf
	
	cSelect += "%"
	
	cGroupBy := "%"	
	cGroupBy += " C20.C20_NUMDOC," 
    cGroupBy += " C20.C20_SERIE, "
    cGroupBy += " C20.C20_CHVELE," 
    cGroupBy += " C20.C20_DTES,  "
    cGroupBy += " C20.C20_DTDOC, "
    cGroupBy += " C20.C20_TPDOC, "
    cGroupBy += " C20.C20_CODPAR," 
    cGroupBy += " C20.C20_INDOPE," 
    cGroupBy += " C30.C30_CODITE," 
    cGroupBy += " C30.C30_UM,    "
    cGroupBy += " C30.C30_CHVNF, "
    cGroupBy += " T5A.T5A_CODOPE,"
    cGroupBy += " C0X.C0X_CODIGO,"
    
    If TAFColumnPos("C30_LICIMP")    	
    	cGroupBy += " C30.C30_LICIMP, "
    	cGroupBy += "C1N.C1N_CODNAT"
    Else    	
    	cGroupBy += "C1N.C1N_CODNAT"
    EndIf    
	cGroupBy += "%"
	
	BeginSql Alias cAlias1
		SELECT	%Exp:cSelect%
							
		FROM 	%table:C20% C20
		
		INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xFilial:C02%   AND C02.C02_ID 	  = C20.C20_CODSIT	AND C02.%NotDel% //Situação do Documento			
		INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL  AND C30.C30_CHVNF  = C20.C20_CHVNF   AND C30.%NotDel% //Join com o Item do Documento
		INNER JOIN %table:C1L% C1L %Exp:cJC1LxC30%  AND C1L.C1L_ID     = C30.C30_CODITE  AND C1L.%NotDel% //Join com o Cadastro de Itens
		INNER JOIN %table:C1N% C1N %Exp:cJC1NxC30%  AND C1N.C1N_ID     = C30.C30_NATOPE	AND C1N.%NotDel% //Join com o Cadastro de Natureza de Operação
		INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%   AND C0G.C0G_ID 	   = C1L.C1L_CODANP AND C0G.%NotDel%	
		LEFT  JOIN %table:T5A% T5A ON T5A.T5A_FILIAL = %xFilial:T5A%   AND T5A.T5A_ID     = C1N.C1N_IDOPAN  AND T5A.%NotDel% //Join com auto contida de Códigos de operação ANP
		LEFT  JOIN %table:C0X% C0X ON C0X.C0X_FILIAL = %xFilial:C0X%   AND C0X.C0X_ID     = C20.C20_INDFRT  AND C0X.%NotDel% //Join com auto contida de modalidade de fretes
				 
		WHERE C20_FILIAL = %xFilial:C20% 
		  AND (C20_INDOPE = '0' AND C20.C20_DTES BETWEEN %Exp: dtos(cDtIniRef)%  AND %Exp: dtos(cDtFimRef)% OR
		  		C20_INDOPE = '1' AND C20.C20_DTDOC BETWEEN %Exp: dtos(cDtIniRef)%  AND %Exp: dtos(cDtFimRef)%)
		  AND C20.%NotDel%		  	
		  AND C02.C02_CODIGO  NOT IN (%Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
		  AND C1N.C1N_OBJOPE != '01' //DIF. USO E CONSUMO
		  %Exp:cNotIn%  
		
		GROUP BY %Exp:cGroupBy%
		
		ORDER BY T5A.T5A_CODOPE,
				  C20.C20_NUMDOC, 
				  C20.C20_SERIE, 
				  C20.C20_CHVELE,				 
				  C20.C20_DTES, 	
				  C20.C20_DTDOC,			  
				  C20.C20_TPDOC, 
				  C20.C20_CODPAR, 
				  C20.C20_INDOPE, 
				  C30.C30_CODITE, 
				  C30.C30_UM, 
				  C30.C30_CHVNF				  
	EndSql
	
	DbSelectArea(cAlias1)
	(cAlias1)->(DbGoTop())
	
	While (cAlias1)->(!EOF())
	
		cOperacao := (cAlias1)->COD_OPER
	   
		If((cAlias1)->QUANT_ITEM > 0)
					
			/* Busca campos ANP referente ao participante */
			aDadosPart := RetDadosPt((cAlias1)->COD_PART)
			
			cInstalPar := TRIM(aDadosPart[1][1])
			cAtivEcon  := TRIM(aDadosPart[1][2])
			cPaisANP   := TRIM(aDadosPart[1][3])
			cIdentTerc := TRIM(aDadosPart[1][4])
			cMunicANP  := TRIM(aDadosPart[1][5])			
			
			/* Instalação 1 e 2 */
			cInstal1 := TRIM(cInstalEst)
			cInstal2 := TRIM(cInstalPar)
								
			/* Busca campos ANP referente ao item */
			aDadosItem := RetDadosIt((cAlias1)->COD_ITEM)
			
			cProdANP     := TRIM(aDadosItem[1][1])
			cCaracFisQ   := TRIM(aDadosItem[2][1])
			cCaracNaoM   := TRIM(aDadosItem[3][1])
			cRecipGLP    := TRIM(aDadosItem[4][1])
			cMetodoAfe   := TRIM(aDadosItem[5][1])						
			cUniMedDes   := TRIM(aDadosItem[7][1])
			cValorCar    := TRIM(aDadosItem[8][1])
			
			Do Case
				 Case (cAlias1)->IND_FRETE == "0"  //Por conta de terceiros;
				 	cModFrt := "12" 
				 Case (cAlias1)->IND_FRETE == "1"  //Por conta do emitente;
				 	cModFrt := "10"
				 Case (cAlias1)->IND_FRETE == "2"  //Por conta do destinatário;
				 	cModFrt := "11"
				 Case (cAlias1)->IND_FRETE == "9"  //Sem cobrança de frete.
				 	cModFrt := "19"
			EndCase
														
			/* Converte quantidade para unidade de medida ANP */
			nQtdPrdANP := RetQtdANP((cAlias1)->QUANT_ITEM, (cAlias1)->UNID_MED, cUniMedDes)
																					
			/* Dados da Nota Fiscal */
			cNotaFisc  := TRIM((cAlias1)->NUM_DOC)
			cSerNotFis := SerNfToObf(@aSerie, TRIM((cAlias1)->SERIE))
			cChaveAces := TRIM((cAlias1)->CHAVE_ACE)			
			cDtOperac  := SUBSTR((cAlias1)->DTA_ES,7,2) + SUBSTR((cAlias1)->DTA_ES,5,2) + SUBSTR((cAlias1)->DTA_ES,1,4)
						
			/* Documento de imporação e licença de importação */
			 If TAFColumnPos("C30_LICIMP")
			 	nNumeroLI  := TRIM((cAlias1)->LICIMP)
			 Else
			 	nNumeroLI  := POSICIONE("C23",1,xFilial("C23")+(cAlias1)->CHVNF,"C23_LICIMP")
			 EndIf
						
			nNumeroDI  := POSICIONE("C23",1,xFilial("C23")+(cAlias1)->CHVNF,"C23_NUMDOC") 
			
			/* Caso seja preenchido a chave de acesso, não deve ser preenchido a Nota fiscal e Série */
			If(cChaveAces != "")
				cNotaFisc  := ""
				cSerNotFis := ""					
			EndIf
			
			/* Modal de Transporte */
			cModal := RetModal((cAlias1)->CHVNF)
			
			If cModal == ""
				cModal := Substr(aWizard[1][6],1,1)
			EndIf
																					
			cStrTxt += StrZero(nCont,10)           // Contador Sequencial
			cStrTxt += StrZero(cAgentReg,10)       // Agente Regulado Informante
		 	cStrTxt += (cMesRefer+cAnoRefer)       // Mês de Referência (MMAAAA)
		 	cStrTxt += StrZero(VAL(cOperacao),7)   // Código da Operação
		 	cStrTxt += StrZero(VAL(cInstal1),7)    // Código da Instalação 1
		 	cStrTxt += StrZero(VAL(cInstal2),7)    // Código da Instalação 2
		 	cStrTxt += StrZero(VAL(cProdANP),9)    // Código do Produto Operado
		 	cStrTxt += StrTran(StrZero(nQtdPrdANP,15),".","")     // Qtde. do Produto Operado na Unidade de Medida Oficial ANP
		 	cStrTxt += StrTran(StrZero(nQtdPrdANP,15),".","")     // Qtde. do Produto Operado em Quilogramas (KG)
		 	cStrTxt += StrZero(VAL(cModal),1)      // Código do Modal Utilizado na Movimentação
		 	cStrTxt += StrZero(VAL(cVeiculo),7)    // Código do Veículo Utilizado no Modal			 	
		 	
		 	if  !Empty(cInstal2)
		 		cIdentTerc := "0"
			 	cMunicANP  := "0"
			 	cAtivEcon  := "0"
			 	
			 	If Alltrim((cAlias1)->CODNAT) $ cNatCtaOrd
			 		//busca NF de remessa com a chave da venda
			 		nPos := Ascan( aRemessa,{ |x| x[1] == (cAlias1)->CHVNF } )
			 		If nPos > 0			 			
			 			aDadosPart  := RetDadosPt(aRemessa[nPos][3]) //Busca dados do participante da remessa
			 			            
			 			cInstalTerc := TRIM(aDadosPart[1][1])
			 			cAtivEcon   := TRIM(aDadosPart[1][2])			 			
			 			cIdentTerc  := TRIM(aDadosPart[1][4])
			 			cMunicANP   := TRIM(aDadosPart[1][5])
			 			
			 			Iif(!Empty(cInstalTerc), cIdentTerc := cInstalTerc, nil)
			 		EndIf			 				 		
			 	EndIf		 	
		 	EndIf	
		 	
		 	cStrTxt += StrZero(VAL(cIdentTerc),14) // Identificação do Terceiro Envolvido na Operação
			cStrTxt += StrZero(VAL(cMunicANP),7)   // Código do Município (Origem/Destino)
			cStrTxt += StrZero(VAL(cAtivEcon),5)   // Código de Atividade Econômica do Terceiro	 	
		 	
		 	cStrTxt += StrZero(VAL(cPaisANP),4)       // Código do País (Origem/Destino)
		 	cStrTxt += StrZero(VAL(nNumeroLI),10)     // Número da Licença de Importação (LI)
		 	cStrTxt += StrZero(VAL(nNumeroDI),10)     // Número da Declaração de Importação (DI)
		 	cStrTxt += StrZero(VAL(cNotaFisc),7)      // Número da Nota Fiscal da Operação Comercial
		 	cStrTxt += StrZero(VAL(cSerNotFis),2)     // Código da Série da Nota Fiscal da Operação Comercial
		 	cStrTxt += StrZero(VAL(cDtOperac),8)      // Data da Operação Comercial (DDMMAAAA)
		 	cStrTxt += StrZero(VAL(cServDutos),1)     // Código do Serviço Acordado (Dutos)
		 	cStrTxt += StrZero(VAL(cCaracFisQ),3)     // Código da Característica Físico-Química do Produto
		 	cStrTxt += StrZero(VAL(cMetodoAfe),3)     // Código do Método Utilizado para Aferição da Característica
		 	cStrTxt += StrZero(VAL(cModFrt),2)    	  // Modalidade do Frete
		 	cStrTxt += StrZero(VAL(cValorCar),10)     // Valor Encontrado da Característica
		 	cStrTxt += StrZero(VAL(cCodPrdRes),9)     // Código do Produto/Operação Resultante
		 	cStrTxt += StrZero(nMassaEsp,7)           // Massa Específica do Produto
		 	cStrTxt += StrZero(VAL(cRecipGLP),2)      // Recipiente de GLP
		 	cStrTxt += PADR(cChaveAces,44,'0')    	  // Chave de acesso da Nota Fiscal Eletrônica (NF-e)
		 	cStrTxt += CRLF
		 	
		 	/* Realiza a soma das quantidades para os registros de Totalização */
		 	If (substr(cOperacao,4,1) != "0") 			 						
		 		SomaOpTot(nQtdPrdANP, nQtdPrdANP, cOperacao, cInstal1, cProdANP, (cAlias1)->IND_OPER, @aTotalizFn, @aTotaliz)
		 	EndIf
														 				 				
		 	nCont++
		 EndIf						
		
		(cAlias1)->(DbSkip())
	EndDo
	(cAlias1)->(DbCloseArea())
	
	BeginSql Alias cAlias3	
	
	  SELECT C0G.C0G_CODIGO COD_ANP,
	  		 C0G2.C0G_CODIGO COD_ANPT,
	  		 T5A.T5A_CODOPE COD_OPE,
	  		 SUM(T6L.T6L_QTDANP) QTD_ANP
	  
	  	FROM %table:T6L% T6L
		
		INNER JOIN %table:T5A% T5A ON T5A.T5A_FILIAL = %xFilial:T5A% AND T5A.T5A_ID = T6L.T6L_IDOANP  AND T5A.D_E_L_E_T_ != '*'
		INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G% AND C0G.C0G_ID = T6L.T6L_IDANPI  AND C0G.D_E_L_E_T_ != '*'
		LEFT JOIN %table:C0G% C0G2 ON C0G2.C0G_FILIAL = %xFilial:C0G% AND C0G2.C0G_ID = T6L.T6L_IDANPT  AND C0G2.D_E_L_E_T_ != '*'
		
		WHERE T6L.T6L_FILIAL = %xFilial:T6L%
		AND T6L.T6L_DTLANC BETWEEN %Exp: dtos(cDtIniRef)%  AND %Exp: dtos(cDtFimRef)% 
		AND T6L.D_E_L_E_T_ != '*'
		
		GROUP BY C0G.C0G_CODIGO, T5A.T5A_CODOPE, C0G2.C0G_CODIGO
	
	EndSql
	
	DbSelectArea(cAlias3)
	(cAlias3)->(DbGoTop())
	
	While (cAlias3)->(!EOF())
	
		cProdANP   := (cAlias3)->COD_ANP	
		cOperacao  := (cAlias3)->COD_OPE
		nQtdPrdANP := (cAlias3)->QTD_ANP
		cCodPrdRes := (cAlias3)->COD_ANPT
		
		
		cStrTxt += StrZero(nCont,10)           // Contador Sequencial #
		cStrTxt += StrZero(cAgentReg,10)       // Agente Regulado Informante #
	 	cStrTxt += (cMesRefer+cAnoRefer)       // Mês de Referência (MMAAAA) #
	 	cStrTxt += StrZero(Val(cOperacao),7)   // Código da Operação #
	 	cStrTxt += StrZero(Val(cInstalEst),7)  // Código da Instalação 1 #
	 	cStrTxt += Replicate( "0", 7) 	 	   // Código da Instalação 2
	 	cStrTxt += StrZero(Val(cProdANP),9)    // Código do Produto Operado #
	 	cStrTxt += StrTran(StrZero(nQtdPrdANP,15),".","")      // Qtde. do Produto Operado na Unidade de Medida Oficial ANP #
	 	cStrTxt += StrTran(StrZero(nQtdPrdANP,15),".","")      // Qtde. do Produto Operado em Quilogramas (KG) #
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
	 	cStrTxt += StrZero(VAL(cCodPrdRes),9)        // Código do Produto/Operação Resultante
	 	cStrTxt += StrZero(VAL(""),7)        // Massa Específica do Produto
	 	cStrTxt += StrZero(VAL(""),2)        // Recipiente de GLP
	 	cStrTxt += StrZero(VAL(""),44)       // Chave de acesso da Nota Fiscal Eletrônica (NF-e) 	 	
	 	cStrTxt += CRLF
	 	
	 	nCont++	
	 	
	 	/* Realiza a soma das quantidades para os registros de Totalização */
	 	If (substr(cOperacao,4,1) != "0") 			 						
	 		SomaOpTot(nQtdPrdANP, nQtdPrdANP, cOperacao, cInstalEst, cProdANP, substr(cOperacao,4,1), @aTotalizFn, @aTotaliz)
	 	EndIf
	 	
	 	(cAlias3)->(DbSkip())		
	Enddo
	(cAlias3)->(DbCloseArea())
	
	Begin Sequence
 		WrtStrTxt( nHandle, cStrTxt )
 		 				 	
 		GerTxtDPMP( nHandle, cTxtSys, "MOV_DOC" )
 	
 		Recover
		lFound := .F.
	End Sequence
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetDadosPt

RetDadosPt() - Retorna dados da ANP do participante

@Author Francisco Kennedy Nunes Pinheiro
@Since 20/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function RetDadosPt( cCodPart )

	Local aDadosPart  :=	{}
	Local cStrQueryPt := ""
	Local cIdMun 	  := ""
	Local cAliasPart  := GetNextAlias()
	Local cAliasT2d   := GetNextAlias()
	Local cPais       := '' 

	//Carrega dados do participante
	cStrQueryPt := " SELECT C1H.C1H_CODINS COD_INS, C1H.C1H_CNPJ CNPJ, C1H.C1H_CPF CPF, C1H.C1H_CODMUN COD_MUN, T5B.T5B_CODIGO COD_ATV, C08.C08_CODANP COD_PAIS_ANP "
	cStrQueryPt += "   FROM " + RetSqlName('C1H') + ' C1H ' + ','
	cStrQueryPt +=              RetSqlName('T5B') + ' T5B ' + ','
	cStrQueryPt +=              RetSqlName('C08') + ' C08 '
	cStrQueryPt += "  WHERE C1H.C1H_FILIAL  = '" + xFilial("C1H") + "' "
	cStrQueryPt += "    AND C1H.C1H_ID      = '" + cCodPart + "' "
	cStrQueryPt += "    AND C1H.D_E_L_E_T_ != '*' "
	cStrQueryPt += "    AND T5B.T5B_ID      = C1H.C1H_IDATV "
	cStrQueryPt += "    AND T5B.D_E_L_E_T_ != '*' "
	cStrQueryPt += "    AND C08.C08_ID      = C1H.C1H_CODPAI "
	cStrQueryPt += "    AND C08.D_E_L_E_T_ != '*' "

	cStrQueryPt := ChangeQuery(cStrQueryPt)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQueryPt),cAliasPart,.T.,.T.)
	DbSelectArea(cAliasPart)

	If (cAliasPart)->COD_PAIS_ANP != '1554'         // 1554 é o código ANP para Brasil, segundo tabela T016. Esse campos deve ser gerado somente para importação ou exportação
	        cPais := (cAliasPart)->COD_PAIS_ANP
	EndIf

	AADD(aDadosPart,{(cAliasPart)->COD_INS,; 	  // Instalação
					 (cAliasPart)->COD_ATV,; 	  // Atividade Econômica
					 cPais,;                      // País ANP
					 Iif( Empty((cAliasPart)->CNPJ), (cAliasPart)->CPF, (cAliasPart)->CNPJ),; // Identificador do Participante, CNPJ ou CPF
					 ""})

	// Id do Municipio do Participante
	cIdMun := (cAliasPart)->COD_MUN

	(cAliasPart)->(DbCloseArea())
	//======================================================================

	//Busca na tabela T2D o código da Localidade referente ao municipio do participante
	BeginSql Alias cAliasT2d
		SELECT	T2D_CODMUN COD_MUN
		  FROM 	%table:T2D% T2D
		WHERE T2D.T2D_FILIAL = %xFilial:T2D%
	      AND T2D.T2D_IDMUN  = (%Exp: cIdMun%)
	      AND T2D.T2D_TPCLAS = (%Exp:'ANP'%)
		  AND T2D.%NotDel%
	EndSql

	If !(cAliasT2d)->(Eof())
		aDadosPart[1,5] := (cAliasT2d)->COD_MUN // Localidade

	EndIf

	(cAliasT2d)->(DbCloseArea())
	//======================================================================

Return( aDadosPart )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetDadosIt

RetDadosIt() - Retorna dados da ANP do item

@Author Francisco Kennedy Nunes Pinheiro
@Since 20/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function RetDadosIt( cCodItem )

	Local aDadosItem :=	{}
	Local cAliasItem := GetNextAlias()

	BeginSql Alias cAliasItem
		SELECT	C0G.C0G_CODIGO COD_ANP,
				T5C.T5C_CODIGO COD_CFQ,
				T5D.T5D_CODIGO COD_CNM,
				T5E.T5E_CODIGO COD_GLP,
				T5F.T5F_CODIGO COD_AFE,
				T59.T59_CODIGO COD_UMANP,
				T59.T59_UNMEDI UNMED,
				C1L.C1L_CERTIF CERT_ANP
		  FROM 	%table:C1L% C1L
		   INNER JOIN %table:C0G% C0G ON C0G.C0G_FILIAL = %xFilial:C0G%   AND C0G.C0G_ID 	= C1L.C1L_CODANP AND C0G.%NotDel%
		  	LEFT JOIN %table:T5C% T5C ON T5C.T5C_FILIAL = %xFilial:T5C%   AND T5C.T5C_ID 	= C1L.C1L_IDCFQ  AND T5C.%NotDel%
			LEFT JOIN %table:T5D% T5D ON T5D.T5D_FILIAL = %xFilial:T5D%   AND T5D.T5D_ID 	= C1L.C1L_IDCNM  AND T5D.%NotDel%
			LEFT JOIN %table:T5E% T5E ON T5E.T5E_FILIAL = %xFilial:T5E%   AND T5E.T5E_ID 	= C1L.C1L_IDGLP  AND T5E.%NotDel%
			LEFT JOIN %table:T5F% T5F ON T5F.T5F_FILIAL = %xFilial:T5F%   AND T5F.T5F_ID 	= C1L.C1L_IDAFE  AND T5F.%NotDel%
			LEFT JOIN %table:T59% T59 ON T59.T59_FILIAL = %xFilial:T59%   AND T59.T59_ID 	= C1L.C1L_IDUM   AND T59.%NotDel%
		WHERE C1L.C1L_FILIAL = %xFilial:C1L%
		  AND C1L.C1L_ID     = %Exp: cCodItem%
		  AND C1L.%NotDel%
	EndSql

	If !(cAliasItem)->(Eof())
		AADD(aDadosItem,{(cAliasItem)->COD_ANP})   // Produto Operado ANP
		AADD(aDadosItem,{(cAliasItem)->COD_CFQ})   // Característica Físico-Química do Produto
		AADD(aDadosItem,{(cAliasItem)->COD_CNM})   // Característica Físico-Química não mensurável
		AADD(aDadosItem,{(cAliasItem)->COD_GLP})   // Recipiente de GLP
		AADD(aDadosItem,{(cAliasItem)->COD_AFE})   // Método Utilizado para Aferição da Característica
		AADD(aDadosItem,{(cAliasItem)->COD_UMANP}) // Unidade de Medida da Característica (Código ANP)
		AADD(aDadosItem,{(cAliasItem)->UNMED})     // Unidade de Medida da Característica
		AADD(aDadosItem,{(cAliasItem)->CERT_ANP})  // Valor Encontrado da Característica (Certificado de qualidade / Boletim de qualidade)
	EndIf

	(cAliasItem)->(DbCloseArea())

Return( aDadosItem )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetQtdANP

RetQtdANP() - Retorna quantidade convertida para unidade de medida ANP

@Author Francisco Kennedy Nunes Pinheiro
@Since 20/12/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
static function RetQtdANP( dQuantItem, cUnidNota, cUnidANP )

	Local cStrQuerUn := ""
	Local cAliasUnid := GetNextAlias()

	Local cStrQuerFt := ""
	Local cAliasFat  := GetNextAlias()

	Local cIdUnidANP := ""
	Local dFatorConv := 1

	/* Busca o ID da Unidade de Medida ANP */
	cStrQuerUn := " SELECT C1J.C1J_ID ID_UNID_MED "
	cStrQuerUn += "   FROM " +  RetSqlName('C1J') + ' C1J '
	cStrQuerUn += "  WHERE C1J.C1J_FILIAL  = '" + xFilial("C1J") + "' "
	cStrQuerUn += "    AND C1J.C1J_CODIGO  = '" + cUnidANP + "' "
	cStrQuerUn += "    AND C1J.D_E_L_E_T_ != '*' "

	cStrQuerUn := ChangeQuery(cStrQuerUn)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuerUn),cAliasUnid,.T.,.T.)
	DbSelectArea(cAliasUnid)

	If (!EOF())
		cIdUnidANP := (cAliasUnid)->ID_UNID_MED

		/* Busca Fator de Conversão da Unidade de Medida da NF para a Unidade de medida ANP */
		cStrQuerFt := " SELECT C6X.C6X_FATCON FAT_CONV "
		cStrQuerFt += "   FROM " +  RetSqlName('C1K') + ' C1K ' + ','
		cStrQuerFt +=               RetSqlName('C6X') + ' C6X '
		cStrQuerFt += "  WHERE C1K.C1K_FILIAL  = '" + xFilial("C1K") + "' "
		cStrQuerFt += "    AND C1K.C1K_CODIGO  = '" + cUnidNota + "' "
		cStrQuerFt += "    AND C1K.D_E_L_E_T_ != '*' "
		cStrQuerFt += "    AND C6X.C6X_ID      = C1K.C1K_ID "
		cStrQuerFt += "    AND C6X.C6X_UNCONV  = '" + cIdUnidANP + "' "
		cStrQuerFt += "    AND C6X.D_E_L_E_T_ != '*' "

		cStrQuerFt := ChangeQuery(cStrQuerFt)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuerFt),cAliasFat,.T.,.T.)
		DbSelectArea(cAliasFat)

		If (!EOF())
			dFatorConv := (cAliasFat)->FAT_CONV
		EndIf

		(cAliasFat)->(DbCloseArea())
	EndIf

	(cAliasUnid)->(DbCloseArea())

	nQtdANP := dQuantItem * dFatorConv
	nQtdANP := ROUND(nQtdANP,3)

Return( nQtdANP )

Static Function CarregaSer(aSerie as Array)

	Aadd(aSerie, { "1"  , "A"  , "200409", "200705" })
	Aadd(aSerie, { "1"  , "A"  , "200706", "200707" })
	Aadd(aSerie, { "1"  , "A"  , "200708", "" })
	Aadd(aSerie, { "2"  , "B"  , "200409", "" })
	Aadd(aSerie, { "3"  , "C"  , "200409", "" })
	Aadd(aSerie, { "4"	, "U"  , "200409", "" })
	Aadd(aSerie, { "7"	, "1"  , "200501", "" })
	Aadd(aSerie, { "16"	, "10" , "200501", "" })
	Aadd(aSerie, { "27"	, "11" , "200501", "" })
	Aadd(aSerie, { "28"	, "12" , "200501", "" })
	Aadd(aSerie, { "17"	, "13" , "200501", "" })
	Aadd(aSerie, { "29"	, "14" , "200501", "" })
	Aadd(aSerie, { "18"	, "15" , "200501", "" })
	Aadd(aSerie, { "30"	, "16" , "200501", "" })
	Aadd(aSerie, { "31"	, "17" , "200501", "" })
	Aadd(aSerie, { "32"	, "18" , "200501", "" })
	Aadd(aSerie, { "33"	, "19" , "200501", "" })
	Aadd(aSerie, { "8"	, "2"  , "200501", "" })
	Aadd(aSerie, { "34"	, "20" , "200501", "" })
	Aadd(aSerie, { "35"	, "21" , "200501", "" })
	Aadd(aSerie, { "19"	, "22" , "200501", "" })
	Aadd(aSerie, { "36"	, "23" , "200501", "" })
	Aadd(aSerie, { "37"	, "24" , "200501", "" })
	Aadd(aSerie, { "38"	, "25" , "200501", "" })
	Aadd(aSerie, { "20"	, "26" , "200501", "" })
	Aadd(aSerie, { "39"	, "27" , "200501", "" })
	Aadd(aSerie, { "26"	, "28" , "200501", "" })
	Aadd(aSerie, { "40"	, "29" , "200501", "" })
	Aadd(aSerie, { "9"	, "3"  , "200501", "" })
	Aadd(aSerie, { "41"	, "30" , "200501", "" })
	Aadd(aSerie, { "42"	, "31" , "200501", "" })
	Aadd(aSerie, { "43"	, "32" , "200501", "" })
	Aadd(aSerie, { "44"	, "33" , "200501", "" })
	Aadd(aSerie, { "45"	, "34" , "200501", "" })
	Aadd(aSerie, { "46"	, "35" , "200501", "" })
	Aadd(aSerie, { "47"	, "36" , "200501", "" })
	Aadd(aSerie, { "48"	, "37" , "200501", "" })
	Aadd(aSerie, { "49"	, "38" , "200501", "" })
	Aadd(aSerie, { "21"	, "39" , "200501", "" })
	Aadd(aSerie, { "10"	, "4"  , "200501", "" })
	Aadd(aSerie, { "50"	, "40" , "200501", "" })
	Aadd(aSerie, { "22"	, "41" , "200501", "" })
	Aadd(aSerie, { "23"	, "42" , "200501", "" })
	Aadd(aSerie, { "25"	, "43" , "200501", "" })
	Aadd(aSerie, { "51"	, "44" , "200501", "" })
	Aadd(aSerie, { "24"	, "45" , "200501", "" })
	Aadd(aSerie, { "52"	, "46" , "200501", "" })
	Aadd(aSerie, { "53"	, "47" , "200501", "" })
	Aadd(aSerie, { "54"	, "48" , "200501", "" })
	Aadd(aSerie, { "55"	, "49" , "200501", "" })
	Aadd(aSerie, { "11"	, "5"  , "200501", "" })
	Aadd(aSerie, { "56"	, "50" , "200501", "" })
	Aadd(aSerie, { "57"	, "51" , "200501", "" })
	Aadd(aSerie, { "58"	, "52" , "200501", "" })
	Aadd(aSerie, { "59"	, "53" , "200501", "" })
	Aadd(aSerie, { "60"	, "54" , "200501", "" })
	Aadd(aSerie, { "61"	, "55" , "200501", "" })
	Aadd(aSerie, { "62"	, "56" , "200501", "" })
	Aadd(aSerie, { "63"	, "57" , "200501", "" })
	Aadd(aSerie, { "64"	, "58" , "200501", "" })
	Aadd(aSerie, { "65"	, "59" , "200501", "" })
	Aadd(aSerie, { "12"	, "6"  , "200501", "" })
	Aadd(aSerie, { "66"	, "60" , "200501", "" })
	Aadd(aSerie, { "67"	, "61" , "200501", "" })
	Aadd(aSerie, { "13"	, "7"  , "200501", "" })
	Aadd(aSerie, { "14"	, "8"  , "200501", "" })
	Aadd(aSerie, { "15"	, "9"  , "200501", "" })

Return

Static Function SerNfToObf(aSerie as Array, cSerie as Char)

	Local cSerieDpmp as Char
	Local nPos 		 as Numeric

	cSerieDpmp := "5"

	nPos := 0
	If ((nPos := aScan(aSerie, {|x| x[2] == cSerie .And. Empty(x[4])})) != 0)

		cSerieDpmp := aSerie[nPos, 1]

	EndIf

Return( cSerieDpmp )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetModal

RetModal() - Retorna modal de transporte

@Author Francisco Kennedy Nunes Pinheiro
@Since 23/02/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
static function RetModal( cChaveNF )
	
	Local cAliasMod as char
	Local cModal 	  as Char
	
	cModal := ""

	cAliasMod := GetNextAlias()

 	BeginSql Alias cAliasMod 	
 		SELECT C20_MODAL MODAL_TRANSP
 		  FROM %table:T60% T60
 		 	INNER JOIN %table:C20% C20 ON C20.C20_FILIAL = T60.T60_FILIAL AND C20.C20_NUMDOC = T60.T60_NUMDOC AND C20.C20_SERIE = T60.T60_SERIE AND C20.C20_SUBSER = T60.T60_SUBSER AND C20.C20_CODPAR = T60.T60_CODPAR AND C20.%NotDel% 	
 		WHERE T60_FILIAL		= %xFilial:T60%
		  AND T60.T60_CHVNF 	= %Exp: cChaveNF%
		  AND T60.%NotDel%
 	EndSql
 	
 	If !(cAliasMod)->(Eof())
 		
 		cModal := (cAliasMod)->MODAL_TRANSP
 		
 	EndIf

	(cAliasMod)->(DbCloseArea())	

Return cModal

//-------------------------------------------------------------------
/*/{Protheus.doc} getChvVnd

getChvVnd() - Retorna o ID (C20_CHVNF) da nota fiscal de venda das operações
de conta e ordem.

@Author Rafael Völtz
@Since 23/08/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function getChvVnd(cModelo as char, cIndOpe as char, cIndEmi as char, cCodPar as char, cSerie as char, cSubSer as char, cNumDoc as char, dDtDoc as char)
 
 Local cAlias	   := GetNextAlias()
 Local cChvNf      := ""
 
	BeginSql Alias cAlias		
		SELECT C20.C20_CHVNF  C20_CHVNF
		  FROM %table:C20% C20
		 WHERE C20.C20_FILIAL = %xFilial:C20%					 
	       AND C20.C20_CODMOD = %Exp:cModelo%
	       AND C20.C20_INDOPE = %Exp:cIndOpe%
	       AND C20.C20_INDEMI = %Exp:cIndEmi%
	       AND C20.C20_CODPAR = %Exp:cCodPar%
	       AND C20.C20_SERIE  = %Exp:cSerie%
	       AND C20.C20_SUBSER = %Exp:cSubSer%
	       AND C20.C20_NUMDOC = %Exp:cNumDoc%
	       AND C20.C20_DTDOC  = %Exp: dDtDoc%
	EndSql
	
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	
	While (cAlias)->(!EOF())
		
		cChvNf := (cAlias)->C20_CHVNF
		(cAlias)->(DbSkip())
	
	EndDo
	
	( cAlias )->(DbCloseArea())
	
Return cChvNf

//-------------------------------------------------------------------
/*/{Protheus.doc} TDPMPTerc

TDPMPTerc() - Retorna query com as notas de Remessa e Revenda das Operações
de conta e ordem.

@Author Rafael Völtz
@Since 23/08/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TDPMPTerc(cNatCtaOrd as char, cDtIniRef as date, cDtFimRef as date )
	Local cAlias 	 := GetNextAlias()
	Local aNatur 	 := {} 
	Local nPos   	 := 0
	Local aInfoEUF   := {}
	Local cCompC1N	 := ""
	Local cFilJC30   := ""
	Local cJC1NxC30  := ""

	//Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial
	aInfoEUF := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	
	//Retorna o modo de compartilhamento para a tabela
	cCompC1N := Upper(AllTrim(FWModeAccess("C1N", 1) + FWModeAccess("C1N", 2) + FWModeAccess("C1N", 3)))

	cFilJC30   := "C30.C30_FILIAL"

	// Obtém as condições de join usando TAFCompDPMP e informações de aInfoEUF
	cJC1NxC30 := TAFCompDPMP("C1N", cCompC1N, aInfoEUF, cFilJC30)
	
	aNatur     := StrToKArr( cNatCtaOrd, ";" )
	cNatCtaOrd := ""
	For nPos := 1 To Len(aNatur)	    	
		If (!Empty(AllTrim(aNatur[nPos])))	    	
			Iif (!Empty(cNatCtaOrd),cNatCtaOrd += ",", "")		 
			cNatCtaOrd +=  "'" + Alltrim(aNatur[nPos]) + "'"		 
		End	    
	Next
	
	cNatCtaOrd := "%" + Alltrim(cNatCtaOrd) + "%"
	
	BeginSql Alias cAlias
		SELECT C26_CHVNF,   //CHAVE DA REMESSA
		       C26_CODMOD , //DADOS DA VENDA
	           C26_INDOPE , //DADOS DA VENDA
	           C26_INDEMI , //DADOS DA VENDA
	           C26_CODPAR , //DADOS DA VENDA
	           C26_SERIE  , //DADOS DA VENDA
	           C26_SUBSER , //DADOS DA VENDA
	           C26_NUMDOC , //DADOS DA VENDA
	           C26_DTDOC    //DADOS DA VENDA              
		  FROM %table:C26% C26
		 WHERE C26_FILIAL = %xFilial:C26%
		   AND C26.C26_DTDOC BETWEEN %Exp: dtos(cDtIniRef)%  AND %Exp: dtos(cDtFimRef)%
		   AND C26.%NotDel%
		   AND EXISTS 
		   		(
					SELECT C20.C20_CHVNF 
					  FROM %table:C20% C20
					 INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF  AND C30.%NotDel%
					 INNER JOIN %table:C1N% C1N %Exp:cJC1NxC30% AND C1N.C1N_ID    = C30.C30_NATOPE AND C1N.%NotDel%
					 WHERE C20.C20_FILIAL = %xFilial:C20%					 
	                   AND C20.C20_CODMOD = C26_CODMOD
	                   AND C20.C20_INDOPE = C26_INDOPE
	                   AND C20.C20_INDEMI = C26_INDEMI
	                   AND C20.C20_CODPAR = C26_CODPAR
	                   AND C20.C20_SERIE  = C26_SERIE
	                   AND C20.C20_SUBSER = C26_SUBSER
	                   AND C20.C20_NUMDOC = C26_NUMDOC
	                   AND C20.C20_DTDOC  = C26_DTDOC
	                   AND C1N.C1N_CODNAT IN (%Exp:cNatCtaOrd%)
	             )
	EndSql
	
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} TDPMP456

TDPMP456() - Retorna natureza de operações parametrizadas como 
Conta e Ordem no TAFA456 - Complementos Fiscais

@Author Rafael Völtz
@Since 23/08/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TDPMP456(cDtIniRef as date)
 Local cAliasQry	   := GetNextAlias()
 Local cNat            := ""
 
 BeginSql Alias cAliasQry

  SELECT T57_VLCHAV        
    FROM %table:T56% T56 
      INNER JOIN %table:T57% T57 ON T57.T57_FILIAL = T56.T56_FILIAL AND T57.T57_ID = T56.T56_ID
      INNER JOIN %table:T54% T54 ON T54.T54_FILIAL = %xfilial:T54%  AND T54.T54_ID = T57.T57_IDCHAV      
    WHERE T56.T56_FILIAL = %xfilial:T56%
      AND %Exp:dtos(cDtIniRef)% BETWEEN T56.T56_DTINI AND T56.T56_DTFIN      
      AND T56.T56_IDUF 	= ' '
      AND T54.T54_CHAVE =  %Exp:"NAT_OPER_CONTA_ORDEM"%
      AND T57.T57_VLCHAV != ' '
      AND T56.%NotDel%
      AND T57.%NotDel%  
 EndSql		
 
 DbSelectArea(cAliasQry)
 	
 While (cAliasQry)->(!Eof())	
	cNat := Alltrim((cAliasQry)->T57_VLCHAV)
	exit	
 EndDo		
  
 ( cAliasQry )-> ( DbCloseArea() )

Return cNat
