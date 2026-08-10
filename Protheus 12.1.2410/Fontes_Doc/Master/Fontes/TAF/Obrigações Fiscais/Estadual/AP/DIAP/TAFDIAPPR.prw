#include 'protheus.ch'

Function TAFDIAPPR(aWizard as array)

	Local oError	as object
	Local cTxtSys  	as char
	Local nHandle   as numeric 
	Local cREG 		as char
	Local lFound    as logical
	Local cStrTxt   as char
	Local dIni      as date
	Local dFim      as date
	
	Private nSldApur as numeric

	Begin Sequence	

		cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
		nHandle   	:= MsFCreate( cTxtSys )
		cREG		:= "DIAPPR"
		lFound      := .T. 
	    dIni        := aWizard[1,6] 
	    dFim        := aWizard[1,7]
	    nSldApur    := 0
	    
		cInscEst:= Posicione('SM0',1,SM0->M0_CODIGO + cFilAnt,"M0_INSC")	 
	
		cStrTxt := cREG									 + ";"		 //01 - DIAPPR
		cStrTxt += Left(Alltrim(cInscEst),11)        	 + ";"		 //02 - IE
		cStrTxt += PADL(Substr(aWizard[1,3],1,1),2,"0")  + ";"  	 //03 - MOTIVO
		cStrTxt += "00001"                           	 + ";"		 //04 - Sequencia Geral do DIAP para o Contribuinte
		cStrTxt += "001"                             	 + ";"		 //05 - Sequencia Parcial para DIAP
		cStrTxt += PADL(Substr(aWizard[1,4],1,1),2,"0")  + ";"     	 //06 - Tipo da DIAP
		cStrTxt += PADL(Substr(aWizard[1,5],1,1),2,"0")  + ";"     	 //07 - Periodicidade da DIAP
		cStrTxt += DTOS(dIni)                            + ";"	 	 //08 - Periodo Inicial 
		cStrTxt += DTOS(dFim)							 + ";"		 //09 - Periodo Final
		cStrTxt += PADL(Substr(aWizard[1,8],1,3),6,"0")	 + ";"		 //10 - Município Origem
		cStrTxt += PADL(Substr(aWizard[1,9],1,3),6,"0") + ";"		 //11 - Município Destino
		
		/* INFORMAÇÕES ECONÔMICAS */
		TAFInfEcon(@cStrTxt, dIni, dFim)
		
		cStrTxt += IIF(aWizard[2][1] == "0 - Não", "N", "S")  + ";"   //16 - Houve Movimentação de Entrada/Saída? 
		cStrTxt += IIF(aWizard[2][2] == "0 - Não", "N", "S")  + ";"   //17 - Houve Redução de Base de Cálculo? 
		cStrTxt += IIF(aWizard[2][3] == "0 - Não", "N", "S")  + ";"   //18 - Houve Operações Interestaduais? 
		
		If !("3" $ aWizard[1, 5]) 
		
			/* INFORMAÇÕES DE ESTOQUE */
			TAFEstoque(@cStrTxt, dIni, dFim, IIF(aWizard[2][4] == "0 - Não", .F., .T.))	
			
			/* INFORMAÇÕES DA APURAÇÃO DE ICMS */
			TAFApurICMS(@cStrTxt, dIni, dFim)
			
			/* INFORMAÇÕES DE RECOLHIMENTO */
			TAFRecolhe(@cStrTxt, dIni, dFim)
			
			/* INFORMAÇÕES DO ICMS ST */
			TAFApurST(@cStrTxt, dIni, dFim, aWizard[2,5])
			
			/* INFORMAÇÕES DA APURAÇÃO SIMPLES NACIONAL */
			TAFApurSimples(@cStrTxt, dIni, dFim)
			
			/* INFORMAÇÕES DA IMPORTAÇÃO */
			TAFImportacao(@cStrTxt, DtoS(dIni), DtoS(dFim), aWizard[2,6])
			
			cStrTxt += Dtos(dDataBase) 							 + ";"	 //127 - Data da geração do arquivo 
			cStrTxt += TIME()    								 + ";"	 //128 - Hora da geração do arquivo
			cStrTxt += "I"		 								 + ";" 	 //129 - Forma de Cadastro - I - IMPORTAÇÃO
			cStrTxt += IIF(aWizard[2][4] == "0 - Não", "N", "S") + ";"   //130 - Houve Movimentação de Estoque?
			
			
			/* JUSTIFICATIVAS DE ESTORNOS E OUTROS DÉBITOS DE ICMS*/
			TAFTxtAjustes(@cStrTxt, dIni, dFim, aWizard[2][4] )
		EndIf
		
		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	
		GerTxtDIAP( nHandle, cTxtSys, "_DIPR")
	
		Recover
		lFound := .F.
	
	End Sequence

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInfEcon

Imprime as informações enconômicas de número de funcionário e valor em caixa
do final do período

@Param 	cStrTxt -> Texto com as colunas da obrigação
		dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFInfEcon(cStrTxt as char, dIni as date, dFim as date)	
	
	Local cAliasQry  as char
	Local cMesAnt    as char
	Local cAnoAnt    as char
	Local cMesAtual  as char
	Local cAnoAtual  as char
	Local dDateAnt   as date	
	Local nFuncIni  := 0
	Local nFuncFim  := 0
	Local nCxIni    := 0
	Local nCxFim    := 0
	
	cAliasQry := GetNextAlias()
	
	dDateAnt  := TAFSubMes(dIni,1)
	cMesAnt   := StrZero(Month(dDateAnt),2)
	cAnoAnt   := StrZero(Year(dDateAnt),4)
	cMesAtual := StrZero(Month(dFim),2)
	cAnoAtual := StrZero(Year(dFim),4)
	
	BeginSql Alias cAliasQry	
		
		SELECT 'INICIAL' PERIODO,
				CWY_NUMEMP,
				CWY_VLCAIX
			FROM %table:CWY%
		   WHERE CWY_FILIAL = %Exp:cFilAnt%
		     AND CWY_MESREF = %Exp:cMesAnt%
		     AND CWY_ANOREF = %Exp:cAnoAnt%
		     AND %NotDel%
		     
		     UNION		     
		 
		SELECT 'FINAL' PERIODO,
				CWY_NUMEMP,
				CWY_VLCAIX
			FROM %table:CWY%
		   WHERE CWY_FILIAL = %Exp:cFilAnt%
		     AND CWY_MESREF = %Exp:cMesAtual%
		     AND CWY_ANOREF = %Exp:cAnoAtual%
		     AND %NotDel%
	EndSql
	
	While !(cAliasQry)->(Eof())
	
		If(cAliasQry)->PERIODO == "INICIAL"
			nFuncIni += (cAliasQry)->CWY_NUMEMP
			nCxIni   += (cAliasQry)->CWY_VLCAIX 
		Else
			nFuncFim += (cAliasQry)->CWY_NUMEMP
			nCxFim   += (cAliasQry)->CWY_VLCAIX
		EndIf
		
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())
	
	cStrTxt += StrTran(StrZero(nFuncIni, 4, 0),".","") + ";" //12 - N° de Funcionários Inicial
	cStrTxt += StrTran(StrZero(nFuncFim, 4, 0),".","") + ";" //13 - N° de Funcionários Final 
	cStrTxt += StrTran(StrZero(nCxIni,  16, 2),".","") + ";" //14 - Valor da Disponibilidade de Caixa Inicial
	cStrTxt += StrTran(StrZero(nCxFim,  16, 2),".","") + ";" //15 - Valor da Disponibilidade de Caixa Final

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFEstoque

Imprime as informações de estoque

@Param 	cStrTxt -> Texto com as colunas da obrigação
		dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento		

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFEstoque(cStrTxt as char, dIni as date, dFim as date, lMovEst as logical)	
	Local cAliasEst  as char
	Local cDataEst   as char
	Local dDataPer   as date	
	Local nIniMatNor := 0
    Local nIniMatIse := 0
    Local nIniMatOut := 0
    Local nIniRevNor := 0
    Local nIniRevIse := 0
    Local nIniRevOut := 0
    Local nIniAcaNor := 0
    Local nIniAcaIse := 0
    Local nIniAcaOut := 0
    Local nIniElbNor := 0
    Local nIniElbIse := 0
    Local nIniElbOut := 0
    Local nIniUsuOut := 0
    Local nIniAtvOut := 0
    Local nIniTerOut := 0
    Local nFinMatNor := 0
    Local nFinMatIse := 0
    Local nFinMatOut := 0         
    Local nFinRevNor := 0
    Local nFinRevIse := 0
    Local nFinRevOut := 0         
    Local nFinAcaNor := 0
    Local nFinAcaIse := 0
    Local nFinAcaOut := 0         
    Local nFinElbNor := 0
    Local nFinElbIse := 0
    Local nFinElbOut := 0
    Local nFinUsuOut := 0
    Local nFinAtvOut := 0
    Local nFinTerOut := 0    
    
    If (lMovEst)
    	cAliasEst := GetNextAlias()
    	dDataPer := dIni
	    dIni     := dIni - 1    
	    
	    If Month(dDataPer) == 1
		    BeginSql Alias cAliasEst
				SELECT 'INICIAL' PERIODO,
					   C2M.C2M_CODIGO TIPO_ITEM,
					   C5B.C5B_INCICM INCIDENCIA,
					   SUM(C5B_VITEM) VL_ITEM
			      FROM %table:C5A% C5A
				      INNER JOIN %table:C5B% C5B ON C5B.C5B_FILIAL = C5A.C5A_FILIAL AND C5B.C5B_ID  = C5A.C5A_ID
				      INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C5A.C5A_FILIAL AND C1L.C1L_ID  = C5B.C5B_CODITE
				      INNER JOIN %table:C2M% C2M ON C2M.C2M_FILIAL = %xfilial:C2M%  AND C2M.C2M_ID  = C1L.C1L_TIPITE
				 WHERE C5A.C5A_FILIAL = %xfilial:C5A%
				   AND C5A.C5A_DTINV  = %Exp:DTOS(dIni)%
				   AND C5B.C5B_INDPRO IN (%Exp:'0'%, %Exp:'1'%) //próprio e em terceiros
				   AND C5A.%NotDel%  
				   AND C5B.%NotDel%			   
				   AND C1L.%NotDel%
				   AND C2M.%NotDel%			   
				  GROUP BY C2M.C2M_CODIGO, C5B.C5B_INCICM		  
			EndSql	
		ElseIf  Month(dIni) == 12
			BeginSql Alias cAliasEst	
				SELECT 'FINAL' PERIODO,
						C2M.C2M_CODIGO TIPO_ITEM,				    
					    C5B.C5B_INCICM INCIDENCIA,
					    SUM(C5B_VITEM) VL_ITEM
			      FROM %table:C5A% C5A
				      INNER JOIN %table:C5B% C5B ON C5B.C5B_FILIAL = C5A.C5A_FILIAL AND C5B.C5B_ID  = C5A.C5A_ID
				      INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C5A.C5A_FILIAL AND C1L.C1L_ID  = C5B.C5B_CODITE
				      INNER JOIN %table:C2M% C2M ON C2M.C2M_FILIAL = %xfilial:C2M%  AND C2M.C2M_ID  = C1L.C1L_TIPITE
				 WHERE C5A.C5A_FILIAL = %xfilial:C5A%
				   AND C5A.C5A_DTINV  = %Exp:DTOS(dIni)%
				   AND C5B.C5B_INDPRO IN (%Exp:'0'%, %Exp:'1'%) //próprio e em terceiros		   
				   AND C5A.%NotDel%  
				   AND C5B.%NotDel%			   
				   AND C1L.%NotDel%
				   AND C2M.%NotDel%			    
				   GROUP BY C2M.C2M_CODIGO, C5B.C5B_INCICM
			EndSql
		EndIf
		
		While !(cAliasEst)->(Eof())
			
			If (cAliasEst)->PERIODO == "INICIAL"
				Do Case
					Case (cAliasEst)->TIPO_ITEM $ "01/10" //Materia Prima e Outros Insumos
						If  Alltrim((cAliasEst)->INCIDENCIA) 	== "1"
							nIniMatNor += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "2"
							nIniMatIse += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "3"
							nIniMatOut += (cAliasEst)->VL_ITEM
						EndIf
					
					Case (cAliasEst)->TIPO_ITEM $ "00" //Revenda
						If  Alltrim((cAliasEst)->INCIDENCIA) 	== "1"
							nIniRevNor += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "2"
							nIniRevIse += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "3"
							nIniRevOut += (cAliasEst)->VL_ITEM
						EndIf
					
					Case (cAliasEst)->TIPO_ITEM $ "04" //Acabados
						If  Alltrim((cAliasEst)->INCIDENCIA) 	== "1"
							nIniAcaNor += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "2"
							nIniAcaIse += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "3"
							nIniAcaOut += (cAliasEst)->VL_ITEM
						EndIf
					
					Case (cAliasEst)->TIPO_ITEM $ "03" //Em processo
						If  Alltrim((cAliasEst)->INCIDENCIA) 	== "1"
							nIniElbNor += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "2"
							nIniElbIse += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "3"
							nIniElbOut += (cAliasEst)->VL_ITEM
						EndIf
						
					Case (cAliasEst)->TIPO_ITEM $ "07" //Uso e consumo
						nIniUsuOut += (cAliasEst)->VL_ITEM					
						
					Case (cAliasEst)->TIPO_ITEM $ "08" //Ativo Imobilizado
						nIniAtvOut += (cAliasEst)->VL_ITEM				
				EndCase 
			Else
				Do Case
					Case (cAliasEst)->TIPO_ITEM $ "01/10" //Materia Prima e Outros Insumos
						If  Alltrim((cAliasEst)->INCIDENCIA) 	== "1"
							nFinMatNor += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "2"
							nFinMatIse += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "3"
							nFinMatOut += (cAliasEst)->VL_ITEM
						EndIf
					
					Case (cAliasEst)->TIPO_ITEM $ "00" //Revenda
						If  Alltrim((cAliasEst)->INCIDENCIA) 	== "1"
							nFinRevNor += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "2"
							nFinRevIse += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "3"
							nFinRevOut += (cAliasEst)->VL_ITEM
						EndIf
					
					Case (cAliasEst)->TIPO_ITEM $ "04" //Acabados
						If  Alltrim((cAliasEst)->INCIDENCIA) 	== "1"
							nFinAcaNor += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "2"
							nFinAcaIse += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "3"
							nFinAcaOut += (cAliasEst)->VL_ITEM
						EndIf
					
					Case (cAliasEst)->TIPO_ITEM $ "03" //Em processo
						If  Alltrim((cAliasEst)->INCIDENCIA) 	== "1"
							nFinElbNor += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "2"
							nFinElbIse += (cAliasEst)->VL_ITEM
						ElseIf Alltrim((cAliasEst)->INCIDENCIA) == "3"
							nFinElbOut += (cAliasEst)->VL_ITEM
						EndIf
						
					Case (cAliasEst)->TIPO_ITEM $ "07" //Uso e consumo
						nFinUsuOut += (cAliasEst)->VL_ITEM					
						
					Case (cAliasEst)->TIPO_ITEM $ "08" //Ativo Imobilizado
						nFinAtvOut += (cAliasEst)->VL_ITEM				
				EndCase 
			EndIf		 
			
			(cAliasEst)->(DbSkip())
		EndDo
		
		(cAliasEst)->(DbCloseArea())
		
		
		//BUSCA ESTOQUE DE TERCEIROS
		If Month(dDataPer) == 1
			BeginSql Alias cAliasEst
				SELECT 'INICIAL' PERIODO,				   
					   SUM(C5B_VITEM) VL_ITEM
			      FROM %table:C5A% C5A
				      INNER JOIN %table:C5B% C5B ON C5B.C5B_FILIAL = C5A.C5A_FILIAL AND C5B.C5B_ID  = C5A.C5A_ID
				      INNER JOIN %table:C5C% C5C ON C5C.C5C_FILIAL = C5B.C5B_FILIAL AND C5C.C5C_ID  = C5B.C5B_ID  		AND C5C.C5C_CODITE = C5B.C5B_CODITE			      
				 WHERE C5A.C5A_FILIAL = %xfilial:C5A%
				   AND C5A.C5A_DTINV  = %Exp:DTOS(dIni)%
				   AND C5B.C5B_INDPRO = %Exp:"2"% //de terceiros
				   AND C5A.%NotDel%  
				   AND C5B.%NotDel%
				   AND C5C.%NotDel%		   
			 EndSql
		ElseIf Month(dIni) == 12
			 BeginSql Alias cAliasEst
				SELECT 'FINAL' PERIODO,				   
					   SUM(C5B_VITEM) VL_ITEM
			      FROM %table:C5A% C5A
				      INNER JOIN %table:C5B% C5B ON C5B.C5B_FILIAL = C5A.C5A_FILIAL AND C5B.C5B_ID  = C5A.C5A_ID
				      INNER JOIN %table:C5C% C5C ON C5C.C5C_FILIAL = C5B.C5B_FILIAL AND C5C.C5C_ID  = C5B.C5B_ID  		AND C5C.C5C_CODITE = C5B.C5B_CODITE			      
				 WHERE C5A.C5A_FILIAL = %xfilial:C5A%
				   AND C5A.C5A_DTINV  = %Exp:DTOS(dFim)%
				   AND C5B.C5B_INDPRO = %Exp:"2"% //de terceiros
				   AND C5A.%NotDel%  
				   AND C5B.%NotDel%
				   AND C5C.%NotDel%
			EndSql
		EndIf
		
		While !(cAliasEst)->(Eof())
			
			If (cAliasEst)->PERIODO == "INICIAL"
				If !Empty((cAliasEst)->VL_ITEM)
					nIniTerOut += (cAliasEst)->VL_ITEM
				EndIf
			Else
				If !Empty((cAliasEst)->VL_ITEM)
					nFinTerOut += (cAliasEst)->VL_ITEM
				EndIf
			EndIf			
			
			(cAliasEst)->(DbSkip())
		EndDo
		
		(cAliasEst)->(DbCloseArea())
	EndIf
    
	cStrTxt += StrTran(StrZero(nIniMatNor, 16, 2),".","") + ";" //19 - Valor do Estoque Inicial de Matéria Prima e Outros Insumos para a coluna Tributação Normal
	cStrTxt += StrTran(StrZero(nIniMatIse, 16, 2),".","") + ";" //20 - Valor do Estoque Inicial de Matéria Prima e Outros Insumos para a coluna Isentas
	cStrTxt += StrTran(StrZero(nIniMatOut, 16, 2),".","") + ";" //21 - Valor do Estoque Inicial de Matéria Prima e Outros Insumos para a coluna Outros
	                                                      
	cStrTxt += StrTran(StrZero(nIniRevNor, 16, 2),".","") + ";" //22 - Valor do Estoque Inicial de Mercadoria para Revenda para a coluna de Tributação Normal
	cStrTxt += StrTran(StrZero(nIniRevIse, 16, 2),".","") + ";" //23 - Valor do Estoque Inicial de Mercadoria para Revenda para a coluna de Isentas
	cStrTxt += StrTran(StrZero(nIniRevOut, 16, 2),".","") + ";" //24 - Valor do Estoque Inicial de Mercadoria para Revenda para a coluna de Outras
	                                                      
	cStrTxt += StrTran(StrZero(nIniAcaNor, 16, 2),".","") + ";" //25 - Valor do Estoque Inicial de Produtos de Fabricação Própria (Acabados) para a coluna Tributação Normal
	cStrTxt += StrTran(StrZero(nIniAcaIse, 16, 2),".","") + ";" //26 - Valor do Estoque Inicial de Produtos de Fabricação Própria (Acabados) para a coluna Isentas
	cStrTxt += StrTran(StrZero(nIniAcaOut, 16, 2),".","") + ";" //27 - Valor do Estoque Inicial de Produtos de Fabricação Própria (Acabados) para a coluna de Outras
	                                                      
	cStrTxt += StrTran(StrZero(nIniElbNor, 16, 2),".","") + ";" //28 - Valor do Estoque Inicial de Produtos de Fabricação Própria (em elaboração) para a coluna Tributação Normal
	cStrTxt += StrTran(StrZero(nIniElbIse, 16, 2),".","") + ";" //29 - Valor do Estoque Inicial de Produtos de Fabricação Própria (em elaboração) para a coluna Isentas
	cStrTxt += StrTran(StrZero(nIniElbOut, 16, 2),".","") + ";" //30 - Valor do Estoque Inicial de Produtos de Fabricação Própria (em elaboração) para a coluna de Outras
	                                                      
	cStrTxt += StrTran(StrZero(nIniUsuOut, 16, 2),".","") + ";" //31 - Valor do Estoque Inicial de Materiais de Uso e Consumo para a coluna Outras
	cStrTxt += StrTran(StrZero(nIniAtvOut, 16, 2),".","") + ";" //32 - Valor do Estoque Inicial de Bens do ativo imobilizado para a coluna Outras
	cStrTxt += StrTran(StrZero(nIniTerOut, 16, 2),".","") + ";" //33 - Valor do Estoque Inicial de Estoque de Terceiros para a coluna Outras
	                                                      
	cStrTxt += StrTran(StrZero(nFinMatNor, 16, 2),".","") + ";" //34 - Valor do Estoque Final de Matéria Prima e Outros Insumos para a coluna Tributação Normal
	cStrTxt += StrTran(StrZero(nFinMatIse, 16, 2),".","") + ";" //35 - Valor do Estoque Final de Matéria Prima e Outros Insumos para a coluna Isentas
	cStrTxt += StrTran(StrZero(nFinMatOut, 16, 2),".","") + ";" //36 - Valor do Estoque Final de Matéria Prima e Outros Insumos para a coluna Outros
	                                                                              
	cStrTxt += StrTran(StrZero(nFinRevNor, 16, 2),".","") + ";" //37 - Valor do Estoque Final de Mercadoria para Revenda para a coluna de Tributação Normal
	cStrTxt += StrTran(StrZero(nFinRevIse, 16, 2),".","") + ";" //38 - Valor do Estoque Final de Mercadoria para Revenda para a coluna de Isentas
	cStrTxt += StrTran(StrZero(nFinRevOut, 16, 2),".","") + ";" //39 - Valor do Estoque Final de Mercadoria para Revenda para a coluna de Outras
	                                                                              
	cStrTxt += StrTran(StrZero(nFinAcaNor, 16, 2),".","") + ";" //40 - Valor do Estoque Final de Produtos de Fabricação Própria (Acabados) para a coluna Tributação Normal
	cStrTxt += StrTran(StrZero(nFinAcaIse, 16, 2),".","") + ";" //41 - Valor do Estoque Final de Produtos de Fabricação Própria (Acabados) para a coluna Isentas
	cStrTxt += StrTran(StrZero(nFinAcaOut, 16, 2),".","") + ";" //42 - Valor do Estoque Final de Produtos de Fabricação Própria (Acabados) para a coluna de Outras
	                                                                              
	cStrTxt += StrTran(StrZero(nFinElbNor, 16, 2),".","") + ";" //43 - Valor do Estoque Final de Produtos de Fabricação Própria (em elaboração) para a coluna Tributação Normal
	cStrTxt += StrTran(StrZero(nFinElbIse, 16, 2),".","") + ";" //44 - Valor do Estoque Final de Produtos de Fabricação Própria (em elaboração) para a coluna Isentas
	cStrTxt += StrTran(StrZero(nFinElbOut, 16, 2),".","") + ";" //45 - Valor do Estoque Final de Produtos de Fabricação Própria (em elaboração) para a coluna de Outras
	                                                                              
	cStrTxt += StrTran(StrZero(nFinUsuOut, 16, 2),".","") + ";" //46 - Valor do Estoque Final de Materiais de Uso e Consumo para a coluna Outras
	cStrTxt += StrTran(StrZero(nFinAtvOut, 16, 2),".","") + ";" //47 - Valor do Estoque Final de Bens do ativo imobilizado para a coluna Outras
	cStrTxt += StrTran(StrZero(nFinTerOut, 16, 2),".","") + ";" //48 - Valor do Estoque Final de Estoque de Terceiros para a coluna Outras
	

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFApurICMS

Imprime informações da apuração de ICMS

@Param 	cStrTxt -> Texto com as colunas da obrigação
		dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFApurICMS(cStrTxt as char, dIni as date, dFim as date)	
		
	Local nValDebSai := 0
    Local nValOutDeb := 0
    Local nValEstCre := 0
    Local nValCreEnt := 0
    Local nValOutCre := 0
    Local nValEstDeb := 0
    Local nValSldCre := 0
    
	DbSelectArea("C2S")
		
	C2S->(DbSetOrder(2))
	If C2S->(DbSeek(xFilial("C2S")))
	 	While C2S->(!EOF()) .AND. xFilial("C2S") == C2S->C2S_FILIAL
	 			 		
	 		If (!(C2S->C2S_DTINI >= dIni .AND. C2S->C2S_DTFIN <= dFim))
 				C2S->(dbSkip())
	 			Loop
	 		Endif

            nValDebSai := C2S->C2S_TOTDEB
            nValOutDeb := C2S->C2S_TAJUDB
            nValEstCre := C2S->C2S_ESTCRE
            nValCreEnt := C2S->C2S_TOTCRE
            nValOutCre := C2S->C2S_TAJUCR
            nValEstDeb := C2S->C2S_ESTDEB
            nValSldCre := C2S->C2S_CREANT
			nSldApur   := C2S->C2S_SDOAPU
			C2S->(dbSkip())
		EndDo
	EndIf
	
	cStrTxt += StrTran(StrZero(nValDebSai, 16, 2),".","") + ";" //49 - Valor dos Débitos pelas Saídas
	cStrTxt += StrTran(StrZero(nValOutDeb, 16, 2),".","") + ";" //50 - Valor de Outros Débitos
	cStrTxt += StrTran(StrZero(nValEstCre, 16, 2),".","") + ";" //51 - Valor de Estorno de Créditos
	cStrTxt += StrTran(StrZero(nValCreEnt, 16, 2),".","") + ";" //52 - Valor de Crédito pelas Entradas
	cStrTxt += StrTran(StrZero(nValOutCre, 16, 2),".","") + ";" //53 - Valor de Outros Créditos
	cStrTxt += StrTran(StrZero(nValEstDeb, 16, 2),".","") + ";" //54 - Valor de Estorno de Débitos
	cStrTxt += StrTran(StrZero(nValSldCre, 16, 2),".","") + ";" //55 - Valor do Saldo Credor do Período Anterior
	
Return 


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFRecolhe

Imprime informações de recolhimento do ICMS

@Param 	cStrTxt -> Texto com as colunas da obrigação
		dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFRecolhe(cStrTxt as char, dIni as date, dFim as date)
	
	Local cAliasQry  as char
	Local cPeriodo   as char	
	Local cRegime    as char
	Local nRecNormal := 0
    Local nRecImport := 0
    Local nRecAtivoI := 0
    Local nRecForaPr := 0
    Local nRecFPrzIm := 0
    Local nRecFPrzAt := 0
    Local nVencNorml := 0
    Local nVencImpor := 0
    Local nVencAtivo := 0
    Local nBenfNorml := 0
    Local nBenfImpor := 0
    Local nBenfAtivo := 0
    Local nEstiNorml := 0
    Local nEstiTotal := 0
    Local nRecTotalN := 0
    Local nRecTotalS := 0
    Local nRecUsoCon := 0
    Local nRecICMSST := 0
    Local nRecForUso := 0
    Local nRecForaST := 0
    Local nVencUsoCo := 0
    Local nVencICMST := 0    
    
    cPeriodo := ""
    cRegime  := ""
    cPeriodo := StrZero(Month(dIni),2)+StrZero(Year(dIni),4)
    
    cAliasQry 	:= GetNextAlias()
	
	BeginSql Alias cAliasQry
	
	  SELECT T54_CHAVE,
	         T57_VLCHAV        
	    FROM %table:T56% T56 
	      INNER JOIN %table:T57% T57 ON T57.T57_FILIAL = T56.T56_FILIAL AND T57.T57_ID = T56.T56_ID
	      INNER JOIN %table:T54% T54 ON T54.T54_FILIAL = %xfilial:T54%  AND T54.T54_ID = T57.T57_IDCHAV
	      INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID = T56.T56_IDUF
	    WHERE T56.T56_FILIAL = %xfilial:T56%
	      AND T56.T56_DTINI >= %Exp:DTOS(dIni)%
	      AND T56.T56_DTFIN <= %Exp:DTOS(dFim)%
	      AND C09.C09_UF 	  = %Exp:'AP'%
	      AND T54.T54_CHAVE IN ( %Exp:"VLR_IMP_FORA_PRAZO"%,   
	      						 %Exp:"VLR_IMP_VENCIDO"% , 
	      						 %Exp:"VLR_DIF_ALQ_ATV_FORA_PRAZO"% ,
	      						 %Exp:"VLR_DIF_ALQ_ATV_VENCIDO"% ,
	      						 %Exp:"VLR_BENEFICIO_IMPORTACAO"% ,
	      						 %Exp:"VLR_BENEFICIO_DIF_ALIQ_ATIVO"% ,
	      						 %Exp:"VLR_USO_FORA_PRAZO"% ,
	      						 %Exp:"VLR_USO_VENCIDO"% 
	      						 )
	      AND T56.%NotDel%
	      AND T57.%NotDel%
	      AND C09.%NotDel%  
	
	EndSql
	
	While !(cAliasQry)->(Eof())
	    
	    Do Case
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "VLR_IMP_FORA_PRAZO"  
	    		nRecFPrzIm += Val((cAliasQry)->T57_VLCHAV)
	    		
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "VLR_IMP_VENCIDO"
	    		nVencImpor += Val((cAliasQry)->T57_VLCHAV)
	    		
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "VLR_DIF_ALQ_ATV_FORA_PRAZO"
	    		nRecFPrzAt += Val((cAliasQry)->T57_VLCHAV)
	    		
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "VLR_DIF_ALQ_ATV_VENCIDO"
	    		nVencAtivo += Val((cAliasQry)->T57_VLCHAV)
	    		
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "VLR_BENEFICIO_IMPORTACAO"
	    		nBenfImpor += Val((cAliasQry)->T57_VLCHAV)
	    		
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "VLR_BENEFICIO_DIF_ALIQ_ATIVO"
	    		nBenfAtivo += Val((cAliasQry)->T57_VLCHAV)
	    		
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "VLR_USO_FORA_PRAZO"
	    		nRecForUso += Val((cAliasQry)->T57_VLCHAV)
	    		
	    	Case Alltrim((cAliasQry)->T54_CHAVE) == "VLR_USO_VENCIDO"
	    		nVencUsoCo += Val((cAliasQry)->T57_VLCHAV)
	    		
	    EndCase
	    	    
	    (cAliasQry)->(DbSkip())     
	EndDo	
	
	(cAliasQry)->(DbCloseArea())
	
	
	/* ------ RECOLHIMENTO ICMS ------ */ 
	BeginSql Alias cAliasQry

	   SELECT SUM(C0R_VLDA) VALOR_REC,	      
	          "NO_PRAZO" TIPO_REC
	     FROM %table:C2S% C2S 
	       INNER JOIN %table:C2Z% C2Z ON C2Z.C2Z_FILIAL = C2S.C2S_FILIAL AND C2Z.C2Z_ID = C2S.C2S_ID
	       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C2Z.C2Z_FILIAL AND C0R.C0R_ID = C2Z.C2Z_DOCARR	       
	     WHERE C2S.C2S_FILIAL = %xFilial:C2S%
	       AND C2S.C2S_DTINI >= %Exp:DTOS(dIni)%
	       AND C2S.C2S_DTFIN <= %Exp:DTOS(dFim)%
	       AND C0R.C0R_PERIOD = %Exp:cPeriodo%
	       AND (C0R.C0R_DTPGT <= C0R.C0R_DTVCT AND 
	            C0R.C0R_DTPGT IS NOT NULL AND C0R.C0R_DTPGT != ' ') 	       
	       AND C2S.%NotDel%
	       AND C2Z.%NotDel%
	       AND C0R.%NotDel%
	       
	  UNION 
	       	       
	     SELECT SUM(C0R_VLDA) VALOR_REC,      
	          "FORA_PRAZO" TIPO_REC	          
	      FROM %table:C2S% C2S 
	       INNER JOIN %table:C2Z% C2Z ON C2Z.C2Z_FILIAL = C2S.C2S_FILIAL AND C2Z.C2Z_ID = C2S.C2S_ID
	       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C2Z.C2Z_FILIAL AND C0R.C0R_ID = C2Z.C2Z_DOCARR
	     WHERE C2S.C2S_FILIAL = %xFilial:C2S%
	       AND C2S.C2S_DTINI >= %Exp:DTOS(dIni)%
	       AND C2S.C2S_DTFIN <= %Exp:DTOS(dFim)%
	       AND C0R.C0R_PERIOD = %Exp:cPeriodo%
	       AND (C0R.C0R_DTPGT > C0R.C0R_DTVCT AND
	            C0R.C0R_DTPGT IS NOT NULL AND C0R.C0R_DTPGT != ' ')
	       AND C2S.%NotDel%
	       AND C2Z.%NotDel%
	       AND C0R.%NotDel%
	  
	   UNION 
	       	       
	     SELECT SUM(C0R_VLDA) VALOR_REC,      
	          "NAO_PAGO" TIPO_REC	          
	      FROM %table:C2S% C2S 
	       INNER JOIN %table:C2Z% C2Z ON C2Z.C2Z_FILIAL = C2S.C2S_FILIAL AND C2Z.C2Z_ID = C2S.C2S_ID
	       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C2Z.C2Z_FILIAL AND C0R.C0R_ID = C2Z.C2Z_DOCARR
	     WHERE C2S.C2S_FILIAL = %xFilial:C2S%
	       AND C2S.C2S_DTINI >= %Exp:DTOS(dIni)%
	       AND C2S.C2S_DTFIN <= %Exp:DTOS(dFim)%
	       AND C0R.C0R_PERIOD = %Exp:cPeriodo%
	       AND (C0R.C0R_DTPGT IS NULL OR C0R.C0R_DTPGT = ' ') 
	       AND C2S.%NotDel%
	       AND C2Z.%NotDel%
	       AND C0R.%NotDel%
	EndSql
	
	
    While !(cAliasQry)->(Eof())
    	
        If (cAliasQry)->TIPO_REC = "NO_PRAZO"
        	nRecNormal += (cAliasQry)->VALOR_REC
    	ElseIf (cAliasQry)->TIPO_REC = "FORA_PRAZO"
    		nRecForaPr += (cAliasQry)->VALOR_REC
    	Else
    		nVencNorml += (cAliasQry)->VALOR_REC
    	EndIF
    	
    	(cAliasQry)->(DbSkip())     
    EndDo
    
    (cAliasQry)->(DbCloseArea())    
    
    
    /* ------  RECOLHIMENTO ICMS REGIME ESTIMATIVA ------ */
    BeginSql Alias cAliasQry
    
    	SELECT T39_TIPREG
    	  FROM %table:T39% T39
    	 WHERE T39_FILIAL = %xFilial:T39%
    	   AND T39_PERINI = %Exp: StrZero(Month(dIni),2) + "/" +StrZero(Year(dIni),4) %
    	   AND T39.%NotDel%
    	   
    EndSql
    
    While !(cAliasQry)->(Eof())
    	cRegime := (cAliasQry)->T39_TIPREG
    	
    	(cAliasQry)->(DbSkip())     
    EndDo
    
    (cAliasQry)->(DbCloseArea())
    
    If cRegime == "13" //REGIME POR ESTIMATIVA
      	nEstiNorml := nRecNormal + nRecForaPr + nVencNorml      	
    EndIf   
        
    
    /* ------ RECOLHIMENTO ICMS-ST ------ */
    BeginSql Alias cAliasQry

	   SELECT SUM(C0R_VLDA) VALOR_REC,
	          "NO_PRAZO"    TIPO_REC
	     FROM %table:C3J% C3J 
	       INNER JOIN %table:C3N% C3N ON C3N.C3N_FILIAL = C3J.C3J_FILIAL AND C3N.C3N_ID = C3J.C3J_ID
	       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C3N.C3N_FILIAL AND C0R.C0R_ID = C3N.C3N_DOCARR
	       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID = C3J.C3J_UF AND C09.C09_ID = C0R.C0R_UF	       
	     WHERE C3J.C3J_FILIAL = %xFilial:C3J%
	       AND C3J.C3J_DTINI >= %Exp:DTOS(dIni)%
	       AND C3J.C3J_DTFIN <= %Exp:DTOS(dFim)%
	       AND C09.C09_UF 	  = %Exp:'AP'%	       
	       AND C0R.C0R_PERIOD = %Exp:cPeriodo%
	       AND (C0R.C0R_DTPGT <= C0R.C0R_DTVCT AND	       
	            C0R.C0R_DTPGT IS NOT NULL AND C0R.C0R_DTPGT != ' ')	       
	       AND C3J.%NotDel%
	       AND C3N.%NotDel%
	       AND C0R.%NotDel%
	       AND C09.%NotDel%
	       
	  UNION 
	       	       
	     SELECT SUM(C0R_VLDA) VALOR_REC,
	            "FORA_PRAZO"  TIPO_REC
	     FROM %table:C3J% C3J 
	       INNER JOIN %table:C3N% C3N ON C3N.C3N_FILIAL = C3J.C3J_FILIAL AND C3N.C3N_ID = C3J.C3J_ID
	       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C3N.C3N_FILIAL AND C0R.C0R_ID = C3N.C3N_DOCARR
	       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID = C3J.C3J_UF AND C09.C09_ID = C0R.C0R_UF
	     WHERE C3J.C3J_FILIAL = %xFilial:C3J%
	       AND C3J.C3J_DTINI >= %Exp:DTOS(dIni)%
	       AND C3J.C3J_DTFIN <= %Exp:DTOS(dFim)%
	       AND C09.C09_UF 	  = %Exp:'AP'%	       
	       AND C0R.C0R_PERIOD = %Exp:cPeriodo%
	       AND (C0R.C0R_DTPGT  > C0R.C0R_DTVCT AND
	       		C0R.C0R_DTPGT IS NOT NULL AND C0R.C0R_DTPGT != ' ')
	       AND C3J.%NotDel%
	       AND C3N.%NotDel%
	       AND C0R.%NotDel%
	       AND C09.%NotDel%
	  
	   UNION 
	       	       
	     SELECT SUM(C0R_VLDA) VALOR_REC,
	            "NAO_PAGO"    TIPO_REC
	     FROM %table:C3J% C3J 
	       INNER JOIN %table:C3N% C3N ON C3N.C3N_FILIAL = C3J.C3J_FILIAL AND C3N.C3N_ID = C3J.C3J_ID
	       INNER JOIN %table:C0R% C0R ON C0R.C0R_FILIAL = C3N.C3N_FILIAL AND C0R.C0R_ID = C3N.C3N_DOCARR
	       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID = C3J.C3J_UF AND C09.C09_ID = C0R.C0R_UF
	     WHERE C3J.C3J_FILIAL = %xFilial:C3J%
	       AND C3J.C3J_DTINI >= %Exp:DTOS(dIni)%
	       AND C3J.C3J_DTFIN <= %Exp:DTOS(dFim)%
	       AND C09.C09_UF 	  = %Exp:'AP'%	       
	       AND C0R.C0R_PERIOD = %Exp:cPeriodo%
	       AND (C0R.C0R_DTPGT IS NULL OR C0R.C0R_DTPGT = ' ')
	       AND C3J.%NotDel%
	       AND C3N.%NotDel%
	       AND C0R.%NotDel%
	       AND C09.%NotDel%
	EndSql	
		
    While !(cAliasQry)->(Eof())
    	
        If (cAliasQry)->TIPO_REC = "NO_PRAZO"
        	nRecICMSST += (cAliasQry)->VALOR_REC
    	ElseIf (cAliasQry)->TIPO_REC = "FORA_PRAZO"
    		nRecForaST += (cAliasQry)->VALOR_REC
    	Else
    		nVencICMST += (cAliasQry)->VALOR_REC
    	EndIF
    	
    	(cAliasQry)->(DbSkip())     
    EndDo
    
    (cAliasQry)->(DbCloseArea())
    
    /* ------ RECOLHIMENTO ICMS IMPORTACAO ------ */
    nRecImport := TAFGetValNF(dIni, dFim, "%BETWEEN '3000' AND '3999'%", "02") //ICMS
    /* ------ RECOLHIMENTO DIF. ALÍQUOTA ATIVO IMOBILIZADO ------ */
    nRecAtivoI := TAFGetValNF(dIni, dFim, "%IN ('1406','1551','1552','1553','1554','1555','1604')%", "03") //ICMS COMPLEMENTAR (DIF. ALIQ)
    /* ------ RECOLHIMENTO DIF. ALÍQUOTA USO E CONSUMO ------ */
    nRecUsoCon := TAFGetValNF(dIni, dFim, "%IN ('1407', '1556', '1557')%", "03") //ICMS COMPLEMENTAR (DIF. ALIQ)
    /* ------ TOTAL BENEFÍCIOS FISCAIS ------ */
    nBenfNorml := TAFGetBenef(dIni, dFim)    
    
    If cRegime == "08"
    	nRecTotalS := nRecNormal + nRecForaPr + nVencNorml
    ElseIf cRegime == "13"
    	nEstiTotal := nRecNormal + nRecForaPr + nVencNorml
    Else
    	nRecTotalN := nRecNormal + nRecForaPr + nVencNorml
    EndIf             
    	
	cStrTxt += StrTran(StrZero(nRecNormal, 16, 2),".","")  + ";" //56 - Valor do Detalhamento Recolhido ou a recolher no prazo legal para a coluna Normal/Estimativa/Simples
	cStrTxt += StrTran(StrZero(nRecImport, 16, 2),".","")  + ";" //57 - Valor do Detalhamento Recolhido ou a recolher no prazo legal para a coluna Importação
	cStrTxt += StrTran(StrZero(nRecAtivoI, 16, 2),".","")  + ";" //58 - Valor do Detalhamento Recolhido ou a recolher no prazo legal para a coluna Diferencial de Aliquota Imobilizado
	cStrTxt += StrTran(StrZero(nRecForaPr, 16, 2),".","")  + ";" //59 - Valor do Detalhamento Recolhido fora do prazo para a coluna Normal/Estimativa/Simples
	cStrTxt += StrTran(StrZero(nRecFPrzIm, 16, 2),".","")  + ";" //60 - Valor do Detalhamento Recolhido fora do prazo para a coluna Importação
	cStrTxt += StrTran(StrZero(nRecFPrzAt, 16, 2),".","")  + ";" //61 - Valor do Detalhamento Recolhido fora do prazo para a coluna Diferencial de Aliquota Imobilizado
	cStrTxt += StrTran(StrZero(nVencNorml, 16, 2),".","")  + ";" //62 - Valor do Detalhamento Vencido e não recolhido para a coluna Normal/Estimativa/Simples
	cStrTxt += StrTran(StrZero(nVencImpor, 16, 2),".","")  + ";" //63 - Valor do Detalhamento Vencido e não recolhido para a coluna Importação
	cStrTxt += StrTran(StrZero(nVencAtivo, 16, 2),".","")  + ";" //64 - Valor do Detalhamento Vencido e não recolhido para a coluna Diferencial de Aliquota Imobilizado
	cStrTxt += StrTran(StrZero(nBenfNorml, 16, 2),".","")  + ";" //65 - Valor do Detalhamento Benefício Fiscal para a coluna Normal/Estimativa/Simples
	cStrTxt += StrTran(StrZero(nBenfImpor, 16, 2),".","")  + ";" //66 - Valor do Detalhamento Benefício Fiscal para a coluna Importação
	cStrTxt += StrTran(StrZero(nBenfAtivo, 16, 2),".","")  + ";" //67 - Valor do Detalhamento Benefício Fiscal para a coluna Diferencial de Aliquota Imobilizado
	cStrTxt += StrTran(StrZero(nEstiNorml, 16, 2),".","")  + ";" //68 - Valor do Detalhamento Estimativas pagas no Período para a coluna Normal/Estimativa/Simples
	cStrTxt += StrTran(StrZero(nEstiTotal, 16, 2),".","")  + ";" //69 - Valor do Detalhamento Imposto total a recolher/Estimativa para a coluna Normal/Estimativa/Simples
	cStrTxt += StrTran(StrZero(0, 16, 2),".","")  		   + ";" //70 - Campo vago
	cStrTxt += StrTran(StrZero(nRecTotalN, 16, 2),".","")  + ";" //71 - Valor do Detalhamento Imposto total a recolher/Normal para a coluna Normal/Estimativa/Simples
	cStrTxt += StrTran(StrZero(nRecTotalS, 16, 2),".","")  + ";" //72 - Valor do Detalhamento Imposto total a recolher/Simples para a coluna Normal/Estimativa/Simples
	cStrTxt += StrTran(StrZero(nRecUsoCon, 16, 2),".","")  + ";" //73 - Valor do Detalhamento Recolhido ou a recolher no prazo legal para a coluna ICMS Diferencial de Aliquota Material de Consumo
	cStrTxt += StrTran(StrZero(nRecICMSST, 16, 2),".","")  + ";" //74 - Valor do Detalhamento Recolhido ou a recolher no prazo legal para a coluna ICMS Substituição Tributária
	cStrTxt += StrTran(StrZero(nRecForUso, 16, 2),".","")  + ";" //75 - Valor do Detalhamento Recolhido fora do prazo para a coluna ICMS Diferencial de Aliquota Material de Consumo
	cStrTxt += StrTran(StrZero(nRecForaST, 16, 2),".","")  + ";" //76 - Valor do Detalhamento Recolhido fora do prazo para a coluna ICMS Substituição Tributária
	cStrTxt += StrTran(StrZero(nVencUsoCo, 16, 2),".","")  + ";" //77 - Valor do Detalhamento Vencido e não recolhido para a coluna de ICMS Diferencial de Aliquota Material de Consumo
	cStrTxt += StrTran(StrZero(nVencICMST, 16, 2),".","")  + ";" //78 - Valor do Detalhamento Vencido e não recolhido para a coluna de ICMS Substituição Tributária		                                                    

Return 


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetValNF

Busca informações dos tributos por documento fiscal

@Param 	dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento
		cQryCFOP -> Expressão SQL para pesquisa por CFOP
		cTributo -> Código do tributo a ser pesquisado

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFGetValNF(dIni as date, dFim as date, cQryCFOP as char, cTributo as char)
  
  Local cAliasQry  as char
  Local cValImpost as numeric  
  
  cAliasQry  := GetNextAlias()
  cValImpost := 0
   
  BeginSql Alias cAliasQry
  	
  	SELECT SUM(C35_VALOR) VALOR
  	  FROM %table:C20% C20
  	   INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF
  	   INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE
  	   INNER JOIN %table:C0Y% C0Y ON C0Y.C0Y_FILIAL = %xFilial:C0Y%  AND C30.C30_CFOP   = C0Y.C0Y_ID
  	   INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xFilial:C3S%  AND C35.C35_CODTRI = C3S.C3S_ID
  	WHERE C20.C20_FILIAL = %xFilial:C20%
  	  AND C20.C20_INDOPE = %Exp: "0"% //Entrada
  	  AND C20.C20_DTDOC  BETWEEN %Exp: DTOS(dIni)% AND %Exp: DTOS(dFim)%
  	  AND C0Y.C0Y_CODIGO %Exp: cQryCFOP %
  	  AND C3S.C3S_CODIGO = %Exp: cTributo %
  	  AND C20.%NotDel%
	  AND C30.%NotDel%
	  AND C35.%NotDel%
	  AND C0Y.%NotDel%
	  AND C3S.%NotDel%  
  EndSql
  
   While !(cAliasQry)->(Eof())    	
       
        cValImpost += (cAliasQry)->VALOR
    	    	
    	(cAliasQry)->(DbSkip())     
    EndDo
    
    (cAliasQry)->(DbCloseArea())
  
   If Empty(cValImpost)
   		cValImpost := 0
   EndIf
   
Return cValImpost


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetBenef

Busca dos beneficios fiscais diretamente da apuração

@Param 	dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento		

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFGetBenef(dIni as date, dFim as date, cQryCFOP as char, cTributo as char)
  
  Local cAliasQry  as char
  Local cValBenef as numeric  
  
  cAliasQry  := GetNextAlias()
  cValBenef := 0
  
  BeginSql Alias cAliasQry
  	
  	SELECT SUM(C2T_VLRAJU) VALOR_AJUSTE
  	  FROM %table:C2S% C2S
  	   INNER JOIN %table:C2T% C2T ON C2T.C2T_FILIAL = C2S.C2S_FILIAL AND C2T.C2T_ID  = C2S.C2S_ID  	   
  	   INNER JOIN %table:CHY% CHY ON CHY.CHY_FILIAL = %xFilial:CHY%  AND CHY.CHY_ID  = C2T.C2T_IDSUBI  	   
  	WHERE C2S.C2S_FILIAL = %xFilial:C2S%  	  
  	  AND C2S.C2S_DTINI  >= %Exp: DTOS(dIni) % 
  	  AND C2S.C2S_DTFIN  <= %Exp: DTOS(dFim) %
  	  AND CHY.CHY_CODIGO = %Exp: "00300" % //INCENTIVO A CULTURA
  	  AND C2S.%NotDel%
	  AND C2T.%NotDel%
	  AND CHY.%NotDel%	    
  EndSql
  
   While !(cAliasQry)->(Eof())    	
       
        cValBenef += (cAliasQry)->VALOR_AJUSTE
    	    	
    	(cAliasQry)->(DbSkip())     
    EndDo
    
    (cAliasQry)->(DbCloseArea())
  
   If Empty(cValBenef)
   		cValBenef := 0
   EndIf
   
Return cValBenef

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFApurST

Imprime informações da apuração  do ICMS ST

@Param 	cStrTxt -> Texto com as colunas da obrigação
		dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFApurST(cStrTxt as char, dIni as date, dFim as date, cGerar as char)
	
	Local cAliasQry  as char
	Local nValProd   as numeric
    Local nValIPI    as numeric
    Local nValDA     as numeric
    Local nBaseICMS  as numeric
    Local nValICMS   as numeric
    Local nBaseST    as numeric
    Local nICMSST    as numeric
    Local nDevolST   as numeric
    Local nRessarST  as numeric
    Local nCredAntST as numeric
    Local nCredSegST as numeric
    Local nRecolheST as numeric
    Local nRetEntST  as numeric
    Local nRetEntIPI as numeric
    Local nRetEntDA  as numeric
    Local nRetEntBIC as numeric
    Local nRetEntICM as numeric
    Local nRetEntBST as numeric    
    Local nRecEntST  as numeric
    Local nRetFntPro as numeric
    Local nRetFntIPI as numeric
    Local nRetFntDA  as numeric
    Local nRetFntBIC as numeric
    Local nRetFntICM as numeric
    Local nRetFntBST as numeric
    Local nRetFntST  as numeric
    Local nSldCreST  as numeric
    Local nSldDevST  as numeric    
      
    nValProd    := 0   
    nValIPI     := 0
    nValDA      := 0
    nBaseICMS   := 0
    nValICMS    := 0
    nBaseST     := 0
    nICMSST     := 0
    nDevolST    := 0
    nRessarST   := 0
    nCredAntST  := 0
    nCredSegST  := 0
    nRecolheST  := 0
    nRetEntST   := 0
    nRetEntIPI  := 0
    nRetEntDA   := 0
    nRetEntBIC  := 0
    nRetEntICM  := 0
    nRetEntBST  := 0
    nRecEntST   := 0
    nRetFntPro  := 0
    nRetFntIPI  := 0
    nRetFntDA   := 0
    nRetFntBIC  := 0
    nRetFntICM  := 0
    nRetFntBST  := 0
    nRetFntST   := 0
    nSldCreST   := 0
    nSldDevST   := 0
    
    If ("1" $ cGerar)
	    aApurST     := TAFVlAprST(dIni, dFim)
	    nDevolST    := aApurST[1]
		nRessarST   := aApurST[2]
		nCredAntST  := aApurST[3]	
		nSldDevST   := aApurST[4]
		nCredSegST  := aApurST[5]
		nSldCreST   := aApurST[5]
		nRecolheST  := aApurST[6]
	    
	    aTributos   := TAFTotTrib(dIni, dFim, "04", "1") //ICMS-ST SUBSTITUTO (SAÍDAS)
	    nValProd 	:= aTributos[1]
		nValIpi     := aTributos[2]
		nValDA      := aTributos[3]
		nBaseICMS   := aTributos[4]
		nValICMS    := aTributos[5]
		nBaseST     := aTributos[6]
		nICMSST     := aTributos[7]
	    
	    aTributos  := TAFTotTrib(dIni, dFim, "17", "0") //ICMS-ST ANTECIPADO (RETIDO NA ENTRADA)
	    nRecEntST  := aTributos[1]
		nRetEntIPI := aTributos[2]
		nRetEntDA  := aTributos[3]
		nRetEntBIC := aTributos[4]
		nRetEntICM := aTributos[5]
		nRetEntBST := aTributos[6]
		nRetEntST  := aTributos[7]
	   
	    aTributos   := TAFTotTrib(dIni, dFim, "04", "0") //ICMS-ST SUBSTITUÍDO (RETIDO NA FONTE)
	    nRetFntPro 	:= aTributos[1]
		nRetFntIPI  := aTributos[2]
		nRetFntDA   := aTributos[3]
		nRetFntBIC  := aTributos[4]
		nRetFntICM  := aTributos[5]
		nRetFntBST  := aTributos[6]
		nRetFntST   := aTributos[7]
	EndIf 
	
	cStrTxt += StrTran(StrZero(nValProd,   16, 2),".","") + ";" 	//79 - GIA-ST Valor do Produto da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nValIPI,    16, 2),".","") + ";" 	//80 - GIA-ST Valor IPI da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nValDA,     16, 2),".","") + ";" 	//81 - GIA-ST Valor Despesas Acessórias da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nBaseICMS,  16, 2),".","") + ";" 	//82 - GIA-ST Valor da Base de Cálculo do ICMS próprio da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nValICMS,   16, 2),".","") + ";" 	//83 - GIA-ST Valor do ICMS próprio da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nBaseST,    16, 2),".","") + ";" 	//84 - GIA-ST Valor da Base de Cálculo do ICMS - Substituição Tributária da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nICMSST,    16, 2),".","") + ";" 	//85 - GIA-ST Valor do ICMS retido por Substituição Tributária da coluna Substituiçao do Estado
	cStrTxt += StrTran(StrZero(nDevolST,   16, 2),".","") + ";" 	//86 - GIA-ST Valor ICMS Devoluções de Mercadorias da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nRessarST,  16, 2),".","") + ";" 	//87 - GIA-ST Valor ICMS Ressarcimentos apropriados da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nCredAntST, 16, 2),".","") + ";" 	//88 - GIA-ST Valor Crédito do período anterior da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nCredSegST, 16, 2),".","") + ";" 	//89 - GIA-ST Valor Crédito para o período seguinte da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nRecolheST, 16, 2),".","") + ";" 	//90 - GIA-ST Valor Total ICMS - Substituição Tributária a recolher da coluna Substituição do Estado
	cStrTxt += StrTran(StrZero(nRecEntST,  16, 2),".","") + ";" 	//91 - GIA-ST Valor dos Produtos da coluna Retido na Entrada
	cStrTxt += StrTran(StrZero(nRetEntIPI, 16, 2),".","") + ";" 	//92 - GIA-ST Valor IPI da coluna Retido na Entrada
	cStrTxt += StrTran(StrZero(nRetEntDA,  16, 2),".","") + ";" 	//93 - GIA-ST Valor Despesas Acessórias da coluna Retido na Entrada
	cStrTxt += StrTran(StrZero(nRetEntBIC, 16, 2),".","") + ";" 	//94 - GIA-ST Valor da Base de Cálculo do ICMS próprio da coluna Retido na Entrada
	cStrTxt += StrTran(StrZero(nRetEntICM, 16, 2),".","") + ";" 	//95 - GIA-ST Valor do ICMS próprio da coluna Retido na Entrada
	cStrTxt += StrTran(StrZero(nRetEntBST, 16, 2),".","") + ";" 	//96 - GIA-ST Valor da Base de Cálculo do ICMS - Substituição Tributária da coluna Retido na Entrada
	cStrTxt += StrTran(StrZero(nRetEntST,  16, 2),".","") + ";"  	//97 - GIA-ST Valor do ICMS retido por Substituição Tributária da coluna Retido na Entrada
	cStrTxt += StrTran(StrZero(nRetFntPro, 16, 2),".","") + ";"  	//98 - GIA-ST Valor do Produto da coluna Retido na Fonte
	cStrTxt += StrTran(StrZero(nRetFntIPI, 16, 2),".","") + ";" 	//99 - GIA-ST Valor IPI da coluna Retido na Fonte
	cStrTxt += StrTran(StrZero(nRetFntDA,  16, 2),".","") + ";"  	//100 - GIA-ST Valor Despesas Acessórias da coluna Retido na Fonte
	cStrTxt += StrTran(StrZero(nRetFntBIC, 16, 2),".","") + ";" 	//101 - GIA-ST Valor da Base de Cálculo do ICMS próprio da coluna Retido na Fonte
	cStrTxt += StrTran(StrZero(nRetFntICM, 16, 2),".","") + ";" 	//102 - GIA-ST Valor do ICMS próprio da coluna Retido na Fonte
	cStrTxt += StrTran(StrZero(nRetFntBST, 16, 2),".","") + ";" 	//103 - GIA-ST Valor da Base de Cálculo do ICMS - Substituição Tributária da coluna Retido na Fonte
	cStrTxt += StrTran(StrZero(nRetFntST,  16, 2),".","") + ";" 	//104 - GIA-ST Valor do ICMS retido por Substituição Tributária da coluna Retido na Fonte
	cStrTxt += StrTran(StrZero(nSldCreST,  16, 2),".","") + ";"  	//105 - Valor do Saldo Credor Apurado no final do Período
	cStrTxt += StrTran(StrZero(nSldApur,  16, 2),".","") + ";"  	//106 - Valor do Saldo Devedor Apurado no final do Período	
		

Return 

//------------------------------------------------------------
/*/{Protheus.doc} TAFTotTrib
 Buscar informações de ICMS, ICMS ST e dos itens dos documentos
 que tiveram a incidência do ICMS ST

@Param 	dIni     > 	Data inicial do período de processamento
		dFim     > 	Data inicial do período de processamento
		cTributo >  Código do Tributo
		cOper    >  Código da operação (0 - Entrada; 1 - Saída)
@Return aRet     > 	Array com as informações totais de ICMS, ICMS ST
					valor do produto e despesa acessória do período
@author Rafael Völtz
@since  08/09/2016
@version 1.0
/*/
//------------------------------------------------------------
Static Function TAFTotTrib(dIni as date, dFim as date, cTributo as char, cOper as char)

Local cAliasST   as char
Local cAliasTrib as char
Local cSelect	 as Char
Local cFrom		 as Char
Local cWhere	 as Char
Local cAliasC	 as Char
Local nTotProd   as numeric
Local nDespAcess as numeric
Local nBaseICMS  as numeric
Local nVlICMS    as numeric
Local nBaseST    as numeric
Local nVlST      as numeric
Local nVlIPI     as numeric
Local aRet       as array
Local nAliqZFM   as numeric

//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************

	cSelect		:= ""
	cFrom		:= ""
	cWhere		:= ""
	cAliasST    := GetNextAlias()
	cAliasTrib  := GetNextAlias()
	nTotProd    := 0
	nBaseICMS   := 0
	nVlICMS     := 0
	nBaseST     := 0
	nVlST       := 0
	nVlIPI      := 0
	nDespAcess  := 0
	nAliqZFM    := 0.07
	aRet        := {}
	
	cSelect      := " C35.C35_CHVNF  C35_CHVNF,  "
	cSelect      += " C35.C35_NUMITE C35_NUMITE, "
	cSelect      += " C35.C35_CODITE C35_CODITE, "
	cSelect      += " C30.C30_TOTAL  C30_TOTAL,  "
	cSelect      += " C30.C30_VLRDA  C30_VLRDA, "
	cSelect      += " C1H.C1H_SUFRAM C1H_SUFRAM  "	
	cFrom        := RetSqlName("C20") + " C20 "
	cFrom        += " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_FILIAL =  '" + xFilial("C1H") + "' AND C20.C20_CODPAR = C1H.C1H_ID  "
	cFrom        += " INNER JOIN " + RetSqlName("C30") + " C30 ON C20.C20_FILIAL = C30.C30_FILIAL AND C20.C20_CHVNF = C30.C30_CHVNF  "
	cFrom        += " INNER JOIN " + RetSqlName("C35") + " C35 ON C20.C20_FILIAL = C35.C35_FILIAL AND C20.C20_CHVNF = C35.C35_CHVNF AND C30.C30_NUMITE = C35.C35_NUMITE "
	cFrom        += " INNER JOIN " + RetSqlName("C02") + " C02 ON C02.C02_FILIAL =  '" + xFilial("C02") + "' AND C20.C20_CODSIT = C02.C02_ID  "
	cFrom        += " INNER JOIN " + RetSqlName("C3S") + " C3S ON C3S.C3S_FILIAL =  '" + xFilial("C3S") + "' AND C35.C35_CODTRI = C3S.C3S_ID   "
	If(cOper == "1")
		cFrom        += " INNER JOIN " + RetSqlName("C09") + " C09 ON C09.C09_FILIAL =  '" + xFilial("C09") + "' AND C1H.C1H_UF =  C09.C09_ID  "
	EndIf
	cWhere       := " 	  C20.C20_FILIAL = '" + xFilial("C20") + "' "
	cWhere       += " AND C20.C20_DTDOC  BETWEEN '" + DToS(dIni) + "' AND '" + DToS(dFim) + "'"
	cWhere       += " AND C20.C20_INDOPE = '" + cOper + "'"
	cWhere       += " AND C02.C02_CODIGO NOT IN ('02', '03', '04','05') "
	cWhere       += " AND C3S.C3S_CODIGO =  '" + cTributo + "'"
	
	If(cOper == "1")
		cWhere       += " AND C09.C09_UF = 'AP'"
	EndIf
	cWhere       += " AND C20.D_E_L_E_T_ = '' "
	cWhere       += " AND C1H.D_E_L_E_T_ = '' "
	cWhere       += " AND C30.D_E_L_E_T_ = '' "
	cWhere       += " AND C35.D_E_L_E_T_ = '' "
	cWhere       += " AND C02.D_E_L_E_T_ = '' "
	cWhere       += " AND C3S.D_E_L_E_T_ = '' "
	If(cOper == "1")
		cWhere       += " AND C09.D_E_L_E_T_ = '' "
	EndIf

	cSelect      := "%" + cSelect    + "%"
	cFrom        := "%" + cFrom      + "%"
	cWhere       := "%" + cWhere     + "%"

	BeginSql Alias cAliasST

	       SELECT
	             %Exp:cSelect%
	       FROM
	             %Exp:cFrom%
	       WHERE
	             %Exp:cWhere%
	EndSql

	DbSelectArea(cAliasST)
	(cAliasST)->(DbGoTop())

	While (cAliasST)->(!EOF())	   	   		
	   		
	   BeginSql Alias cAliasTrib
	       SELECT SUM(CASE WHEN C3S.C3S_CODIGO = '02' THEN C35.C35_BASE END) BASE_ICMS ,
	              SUM(CASE WHEN C3S.C3S_CODIGO = '02' THEN C35.C35_VALOR END) VALOR_ICMS,
	              SUM(CASE WHEN C3S.C3S_CODIGO = '04' OR C3S.C3S_CODIGO = '17' THEN C35.C35_BASE END) BASE_ST ,
	              SUM(CASE WHEN C3S.C3S_CODIGO = '04' OR C3S.C3S_CODIGO = '17' THEN C35.C35_VALOR END) VALOR_ST,
	              SUM(CASE WHEN C3S.C3S_CODIGO = '05' THEN C35.C35_VALOR END) VALOR_IPI
	       FROM %table:C35% C35
	            INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S% AND C35.C35_CODTRI = C3S.C3S_ID
	       WHERE C35.C35_FILIAL = %xFilial:C35%
	         AND C35.C35_CHVNF  = %Exp:(cAliasST)->C35_CHVNF%
	         AND C35.C35_NUMITE = %Exp:(cAliasST)->C35_NUMITE%
	         AND C35.C35_CODITE = %Exp:(cAliasST)->C35_CODITE%
	         AND C35.C35_VALOR  > 0
	         AND C3S.C3S_CODIGO IN (%Exp:'02'%,%Exp:'04'%,%Exp:'05'%, %Exp:'17'%)
	         AND C35.%notDel%
	         AND C3S.%notDel% 
	   EndSql	       

	   //Quando destinados à Zona Franca de Manaus e áreas de livre comércio, informar o valor da base de cálculo do crédito presumido; 
	   If !Empty(Alltrim((cAliasST)->C1H_SUFRAM))
	   	   nTotProd   += (cAliasST)->C30_TOTAL 
		   nDespAcess += (cAliasST)->C30_VLRDA
		   nBaseICMS  += nTotProd
		   nVlICMS    += nTotProd * nAliqZFM    			 
		   nBaseST    += (cAliasTrib)->BASE_ST
		   nVlST      += (cAliasTrib)->VALOR_ST
		   nVlIPI     += (cAliasTrib)->VALOR_IPI
	   Else
		   nTotProd   += (cAliasST)->C30_TOTAL
		   nDespAcess += (cAliasST)->C30_VLRDA
		   nBaseICMS  += (cAliasTrib)->BASE_ICMS
		   nVlICMS    += (cAliasTrib)->VALOR_ICMS
		   nBaseST    += (cAliasTrib)->BASE_ST
		   nVlST      += (cAliasTrib)->VALOR_ST
		   nVlIPI     += (cAliasTrib)->VALOR_IPI
	   EndIf

	   (cAliasTrib)->(DbCloseArea())
	   (cAliasST)->(DbSkip())

	EndDo
	(cAliasST)->(DbCloseArea())
	
	aAdd(aRet,nTotProd)
	aAdd(aRet,nVlIPI)
	aAdd(aRet,nDespAcess)
	aAdd(aRet,nBaseICMS)
	aAdd(aRet,nVlICMS)
	aAdd(aRet,nBaseST)
	aAdd(aRet,nVlST)		

Return aRet

//------------------------------------------------------------
/*/{Protheus.doc} TAFVlAprST
 Buscar informações da apuração de ICMS ST

@Param  dIni    > 	Data inicial do período de processamento
		dFim    > 	Data inicial do período de processamento
@Return aRet    > 	Array com as informações da apuração do ICMS ST
@author Rafael Völtz
@since  12/09/2016
@version 1.0
/*/
//------------------------------------------------------------
Static Function TAFVlAprST(dIni as date, dFim as date)

 Local cAliasA    as char
 Local aRet       as array
 Local nCreAnt    as numeric
 Local nVlrDev    as numeric
 Local nVlrRes    as numeric
 Local nSldDev    as numeric
 Local nVlrRec    as numeric
 Local nCrdTra    as numeric 

 cAliasA := GetNextAlias()  
 aRet    := {}
 nCreAnt := 0
 nVlrDev := 0
 nVlrRes := 0
 nSldDev := 0
 nVlrRec := 0
 nCrdTra := 0

 BeginSql Alias cAliasA

   SELECT C3J.C3J_CREANT C3J_CREANT,
          C3J.C3J_VLRDEV C3J_VLRDEV,
          C3J.C3J_VLRRES C3J_VLRRES,
          C3J.C3J_SDODEV C3J_SDODEV,
          C3J.C3J_VLRREC C3J_VLRREC,
          C3J.C3J_CRDTRA C3J_CRDTRA
     FROM %table:C3J% C3J
       INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09% AND C3J.C3J_UF = C09.C09_ID
     WHERE C3J.C3J_FILIAL = %xFilial:C3J%
       AND C3J.C3J_DTINI  >= %Exp:DTOS(dIni)%
       AND C3J.C3J_DTFIN  <= %Exp:DTOS(dFim)%
       AND C09.C09_UF 	  = %Exp:'AP'%
       AND C3J.%NotDel%
       AND C09.%NotDel%

 EndSql

 While !(cAliasA)->(Eof())
 	 nVlrDev += (cAliasA)->C3J_VLRDEV
     nVlrRes += (cAliasA)->C3J_VLRRES
     nCreAnt += (cAliasA)->C3J_CREANT
 	 nSldDev += (cAliasA)->C3J_SDODEV
     nCrdTra += (cAliasA)->C3J_CRDTRA
     nVlrRec += (cAliasA)->C3J_VLRREC

     (cAliasA)->(DbSkip())
 EndDo

 (cAliasA)->(DbCloseArea())

 aAdd(aRet,nVlrDev)
 aAdd(aRet,nVlrRes)
 aAdd(aRet,nCreAnt)
 aAdd(aRet,nSldDev)
 aAdd(aRet,nCrdTra)
 aAdd(aRet,nVlrRec)

Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFApurSimples

Imprime informações da apuração do Simples Nacional

@Param 	cStrTxt -> Texto com as colunas da obrigação
		dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFApurSimples(cStrTxt as char, dIni as date, dFim as date)
	
	Local cAliasQry  as char	
	Local nBaseICMS := 0
	Local nValICMS  := 0  
	
	cStrTxt += StrTran(StrZero(nBaseICMS,   16, 2),".","") + ";"	//107 - Valor da Base de Cálculo do ICMS Simples
	cStrTxt += StrTran(StrZero(nValICMS,   16, 2),".","")  + ";"	//108 - Valor do ICMS Simples a Recolher

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTxtAjustes

Imprime justificativas dos ajustes de Outros débitos, Estorno de Crédito
e Estorno de Débito

@Param 	cStrTxt -> Texto com as colunas da obrigação
		dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFTxtAjustes(cStrTxt as char, dIni as date, dFim as date)
	
	Local cAliasQry  as char	
	Local cTxtOutDeb := "" 
	Local cTxtEstCre := ""
	Local cTxtEstDeb := ""	  
/*	
0	Outros débitos
1	Estorno de créditos
2	Outros créditos
*/
	
		DbSelectArea("C2S")
		DbSelectArea("C2T")
		DbSelectArea("C1A")
		
		C2S->(DbSetOrder(2))
		If C2S->(DbSeek(xFilial("C2S")))
		 	While C2S->(!EOF()) .And. xFilial("C2S") == C2S->C2S_FILIAL
		 			 		
		 		If (!(C2S->C2S_DTINI >= dIni .And. C2S->C2S_DTFIN <= dFim))
	 				C2S->(dbSkip())
		 			Loop
		 		Endif
	
				C2T->(DbSetOrder(1))
				If C2T->(DbSeek(xFilial("C2T") + C2S->C2S_ID))
					While C2T->(!EOF()) .And. xFilial("C2T") == C2T->C2T_FILIAL .And. C2T->C2T_ID == C2S->C2S_ID			
						
						C1A->(DbSetOrder(3))
						If C1A->(DbSeek(xFilial("C1A") + C2T->C2T_CODAJU + ""))
							
							Do Case
							
								Case Substr(C1A->C1A_CODIGO,4,1) == "0"
									cTxtOutDeb += AllTrim(C2T->C2T_AJUCOM) + " "
								Case Substr(C1A->C1A_CODIGO,4,1) == "1"
									cTxtEstCre += AllTrim(C2T->C2T_AJUCOM) + " "
								Case Substr(C1A->C1A_CODIGO,4,1) == "2"
									cTxtEstDeb += AllTrim(C2T->C2T_AJUCOM) + " "						
							
							EndCase
							
						EndIf
						C2T->(dbSkip())
					EndDo
				Endif
				C2S->(dbSkip())
			EndDo
		EndIf

	
	
	cStrTxt += Alltrim(cTxtOutDeb)  + ";" //131 - Justificativa de Outros débitos
	cStrTxt += Alltrim(cTxtEstCre)  + ";" //132 - Justificativa de Estorno de Créditos
	cStrTxt += Alltrim(cTxtEstDeb)  + ";" //133 - Justificativa de Estorno de Débitos	

Return  

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFImportacao

Imprime informações de Importação

@Param 	cStrTxt -> Texto com as colunas da obrigação
		dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento

@Author Rafael Völtz
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TAFImportacao(cStrTxt as char, cPerIni as Char, cPerFin as Char, cGerar as char)
	
	Local lCif 		  := .F.
	Local cChaveNf	  := ""
	
	Local cAliasC20   := GetNextAlias()
	Local cAliasC23   := GetNextAlias()
	Local cAliasC35   := GetNextAlias()	
	Local nImpFOB     := 0
    Local nDespFrtFOB := 0
    Local nDespSgrFOB := 0
    Local nDespIFFOB  := 0
    Local nDespAduFOB := 0
    Local nDespOutFOB := 0
    Local nBasICMSFOB := 0
    Local nICMSImport := 0
    Local nImpCIF     := 0
    Local nDespFrtCIF := 0
    Local nDespSgrCIF := 0
    Local nDespIFCIF  := 0
    Local nDespAduCIF := 0
    Local nDespOutCIF := 0
    Local nMargAgrCIF := 0
    Local nBaseICMCIF := 0
    Local nICMSAntCIF := 0    
    Local nICMSAReCIF := 0
    
    If ("1" $ cGerar)
	    //VALORES DO DOCUMENTO
		BeginSql Alias cAliasC20	
	       SELECT C20.C20_CHVNF   CHVNF,
	       	  SUM(C20.C20_VLDOC)  VLDOC,
	       	  SUM(C20.C20_VLRFRT) VLRFRT,
	       	  SUM(C20.C20_VLRSEG) VLRSEG,
	          SUM(C20.C20_VLOUDE) VLOUDE
	         FROM %table:C20%  C20
	         INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02%  AND C20.C20_CODSIT = C02.C02_ID 
	         INNER JOIN %table:C23% C23 ON C23.C23_FILIAL = C20.C20_FILIAL AND C23.C23_CHVNF  = C20.C20_CHVNF
	         WHERE C20.C20_FILIAL 	= %xfilial:C20%
		       AND C20.C20_DTDOC  BETWEEN (%Exp:cPerIni%) AND (%Exp:cPerFin%)
		       AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
		       AND C20.C20_INDOPE 	= (%Exp:'0'%)		       
		       AND C23.C23_TIPO 	= (%Exp:'0'%)	       
		       AND C20.%NotDel%
		       AND C02.%NotDel%
		       AND C23.%NotDel%
			   
		    GROUP BY C20.C20_CHVNF
		EndSql
	    
	    DbSelectArea(cAliasC20)
		(cAliasC20)->(DbGoTop())
		
		While (cAliasC20)->(!EOF())
		
			cChaveNf := (cAliasC20)->CHVNF
			
			//VALOR DO IPI NOS ITENS DO DOCUMENTO
			BeginSql Alias cAliasC35	
				SELECT C35.C35_CODTRI 	   IMPTO
		          FROM %table:C35%  C35	          
		          INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S%  AND C3S.C3S_ID = C35.C35_CODTRI
		         WHERE C35.C35_FILIAL = %xfilial:C23%
			       AND C35.C35_CHVNF  = (%Exp:cChaveNf%)
			       AND C3S.C3S_CODIGO = (%Exp:'17'%) //ICMS ANTECIPADO
			       AND C35.%NotDel%
			       AND C3S.%NotDel%
			EndSql
			
			DbSelectArea(cAliasC35)
			(cAliasC35)->(DbGoTop())
		
			lCif := .F.
			While (cAliasC35)->(!EOF())	
				lCif := .T.
				(cAliasC35)->(dbSkip())
			EndDo				
			(cAliasC35)->(DbCloseArea())
		
			If(lCif) //CIF		
				nImpCIF  	+= (cAliasC20)->VLDOC   //117 - Valor da Importação CIF
				nDespFrtCIF += (cAliasC20)->VLRFRT  //118 - Valor da Despesa com Frete CIF
				nDespSgrCIF += (cAliasC20)->VLRSEG	//119 - Valor da Despesa com Seguro CIF		
				nDespOutCIF += (cAliasC20)->VLOUDE  //121 - Valor da Despesa Aduaneira CIF		
			Else //FOB		
				nImpFOB  	+= (cAliasC20)->VLDOC    //109 - Valor da Importação FOB
				nDespFrtFOB += (cAliasC20)->VLRFRT   //110 - Valor da Despesa com Frete FOB
				nDespSgrFOB += (cAliasC20)->VLRSEG	 //111 - Valor da Despesa com Seguro FOB		
				nDespOutFOB += (cAliasC20)->VLOUDE   //113 - Valor da Despesa Aduaneira FOB		
			EndIf
		
			//VALOR II, VALOR DESPESAS ADUANEIRAS, COFINS E PIS
			BeginSql Alias cAliasC23	
				SELECT SUM(C23.C23_II) 	   VLRII,
		       	   	   SUM(C23.C23_VLRADU) VLRADU,
		       	   	   SUM(C23.C23_VLRCOF) VLRCOF,
		       	   	   SUM(C23.C23_VLRPIS) VLRPIS	         
		          FROM %table:C23%  C23
		         WHERE C23.C23_FILIAL = %xfilial:C23%
			       AND C23.C23_CHVNF  = (%Exp:cChaveNf%)
			       AND C23.%NotDel%
			EndSql
			
			DbSelectArea(cAliasC23)
			(cAliasC23)->(DbGoTop())
		
			While (cAliasC23)->(!EOF())
			
				If(lCif) //CIF			
					nDespIFCIF  += (cAliasC23)->VLRII + (cAliasC23)->VLRPIS + (cAliasC23)->VLRCOF //120 - Valor da Despesa com Impostos Federais CIF		
					nDespAduCIF += (cAliasC23)->VLRADU //121 - Valor da Despesa Aduaneira CIF				
				Else			
					nDespIFFOB  += (cAliasC23)->VLRII + (cAliasC23)->VLRPIS + (cAliasC23)->VLRCOF //112 - Valor da Despesa com Impostos Federais FOB
					nDespAduFOB += (cAliasC23)->VLRADU //113 - Valor da Despesa Aduaneira FOB				
				EndIf
				
				(cAliasC23)->(dbSkip())
			EndDo				
			(cAliasC23)->(DbCloseArea())
	    
			//VALOR DO IPI NOS ITENS DO DOCUMENTO
			BeginSql Alias cAliasC35	
				SELECT C3S.C3S_CODIGO 	   IMPTO,
					   SUM(C35.C35_BASE)   VLRBASE,
		       	   	   SUM(C35.C35_VALOR)  VALOR,
		       	   	   SUM(C35.C35_MVA)    MVA	       	   	   	         
		          FROM %table:C35%  C35	          
		          INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S%  AND C3S.C3S_ID     = C35.C35_CODTRI
		         WHERE C35.C35_FILIAL = %xfilial:C23%
			       AND C35.C35_CHVNF  = (%Exp:cChaveNf%)
			       AND C3S.C3S_CODIGO IN (%Exp:'02'%, %Exp:'05'%, %Exp:'17'%) //ICMS / IPI
			       AND C35.%NotDel%
			       AND C3S.%NotDel%
			       GROUP BY C3S.C3S_CODIGO
			EndSql
			
			DbSelectArea(cAliasC35)
			(cAliasC35)->(DbGoTop())
		
			While (cAliasC35)->(!EOF())		
				
				If ((cAliasC35)->IMPTO == "05") //IPI
				
					If(lCif) //CIF			
						nDespIFCIF += (cAliasC35)->VALOR  
					Else				
						nDespIFFOB += (cAliasC35)->VALOR //112 - Valor da Despesa com Impostos Federais FOB
					EndIf
					
				Else //ICMS
				
					If(lCif) //CIF
						If ((cAliasC35)->IMPTO == "17") //ICMS ANTECIPADO					
							nICMSAntCIF += (cAliasC35)->VALOR
							nMargAgrCIF += (cAliasC35)->VLRBASE * (cAliasC35)->MVA
						Else					
							nBaseICMCIF	+= (cAliasC35)->VLRBASE
						EndIf	
					Else					
						If ((cAliasC35)->IMPTO == "02") //ICMS ANTECIPADO
							nBasICMSFOB	+= (cAliasC35)->VLRBASE		
							nICMSImport += (cAliasC35)->VALOR
						EndIf			
					EndIf
								
				EndIf
			
				(cAliasC35)->(dbSkip())
			EndDo				
			(cAliasC35)->(DbCloseArea())		
			(cAliasC20)->(dbSkip())
		EndDo	
			
		(cAliasC20)->(DbCloseArea())
		
		nICMSAReCIF := nICMSAntCIF - nICMSImport
	EndIF
	
	cStrTxt += StrTran(StrZero(nImpFOB,       16, 2),".","") + ";"	//109 - Valor da Importação FOB
	cStrTxt += StrTran(StrZero(nDespFrtFOB,   16, 2),".","") + ";"	//110 - Valor da Despesa com Frete FOB
	cStrTxt += StrTran(StrZero(nDespSgrFOB,   16, 2),".","") + ";"	//111 - Valor da Despesa com Seguro FOB
	cStrTxt += StrTran(StrZero(nDespIFFOB,    16, 2),".","") + ";"	//112 - Valor da Despesa com Impostos Federais FOB
	cStrTxt += StrTran(StrZero(nDespAduFOB,   16, 2),".","") + ";"	//113 - Valor da Despesa Aduaneira FOB
	cStrTxt += StrTran(StrZero(nDespOutFOB,   16, 2),".","") + ";"	//114 - Valor da Outras Despesas FOB
	cStrTxt += StrTran(StrZero(nBasICMSFOB,   16, 2),".","") + ";"	//115 - Valor da Base de Cálculo do ICMS Importação FOB
	cStrTxt += StrTran(StrZero(nICMSImport,   16, 2),".","") + ";"	//116 - Valor do ICMS Importação	
	
	cStrTxt += StrTran(StrZero(nImpCIF,       16, 2),".","") + ";"	//117 - Valor da Importação CIF
	cStrTxt += StrTran(StrZero(nDespFrtCIF,   16, 2),".","") + ";"	//118 - Valor da Despesa com Frete CIF
	cStrTxt += StrTran(StrZero(nDespSgrCIF,   16, 2),".","") + ";"	//119 - Valor da Despesa com Seguro CIF
	cStrTxt += StrTran(StrZero(nDespIFCIF,    16, 2),".","") + ";"	//120 - Valor da Despesa com Impostos Federais CIF
	cStrTxt += StrTran(StrZero(nDespAduCIF,   16, 2),".","") + ";"	//121 - Valor da Despesa Aduaneira CIF
	cStrTxt += StrTran(StrZero(nDespOutCIF,   16, 2),".","") + ";"	//122 - Valor da Outras Despesas CIF
	cStrTxt += StrTran(StrZero(nMargAgrCIF,   16, 2),".","") + ";"	//123 - Margem do Valor Agregado CIF
	cStrTxt += StrTran(StrZero(nBaseICMCIF,   16, 2),".","") + ";"	//124 - Valor da Base de Cálculo do ICMS Importação CIF
	cStrTxt += StrTran(StrZero(nICMSAntCIF,   16, 2),".","") + ";"	//125 - Valor ICMS Antecipação de Importação CIF		
	cStrTxt += StrTran(StrZero(nICMSAReCIF,   16, 2),".","") + ";"	//126 - Valor do ICMS Antecipação de Importação a Recolher CIF

Return

