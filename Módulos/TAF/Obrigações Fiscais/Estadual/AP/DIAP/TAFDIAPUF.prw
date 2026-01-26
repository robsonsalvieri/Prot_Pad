#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDIAPMV

Movimentos de Entradas e Saídas DIAP

@Param 	Wizard

@Author Jean Battista Grahl Espindola
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------

Function TAFDIAPUF(aWizard as array)

	Local cTxtSys as char
	Local nHandle as numeric
	Local cStrTxt as Char
	Local cPerIni as Char
	Local cPerFin as Char
	Local nPos    as Numeric
	Local nVlRes  as Numeric	
	Local aReg 	  as Array
	
	cPerIni := cValToChar(Year(aWizard[1,6])) + "0101"
	cPerFin := cValToChar(Year(aWizard[1,7])) + "1231"
	
	//Se Anual OU (Mensal/Trimestral e Mes 12)
	If !("3" $ aWizard[1, 5]) .Or. (!("3" $ aWizard[1, 5]) .And. Month(aWizard[1,6]) == 12)
		Return
	EndIf	
	
	nVlRes := 0
	
	Begin Sequence
		
		cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
		nHandle  	:= MsFCreate( cTxtSys )
		cStrTxt 	:= ""			
		
		//======== ENTRADAS UF (DIAPUE)
		aReg := {}		
		
		DiapMvtUen(@aReg, cPerIni, cPerFin)
		if Len(aReg) > 0 
			DiapMvtDa(@aReg, "0", cPerIni, cPerFin, 5) //VALORES DIFERENCIAL DE ALÍQUOTA
		EndIf
		
		For nPos := 1 To Len(aReg)		
		
			nVlRes  := GetValRess(aReg[nPos, 1], cPerIni, cPerFin)
			nVlMerc := GetVlMerc(aReg[nPos, 1], "0", cPerIni, cPerFin)
		
			cStrTxt += "DIAPUE;"
			cStrTxt += aReg[nPos, 1] + ";"                    //UF sigla
			cStrTxt += StrZero((aReg[nPos, 2] - nVlRes) * 100, 15) + ";" //Valor Contábil
			cStrTxt += StrZero( aReg[nPos, 3] * 100, 15) + ";" //Valor da Base de Cálculo
			cStrTxt += StrZero( aReg[nPos, 4] * 100, 15) + ";" //Valor de Outras
			cStrTxt += StrZero((aReg[nPos, 5] - nVlMerc) * 100, 15) + ";" //Valor de demais valores
			cStrTxt += StrZero( aReg[nPos, 6] * 100, 15) + ";" //Valor de Petróleo + Energia
			cStrTxt += StrZero( aReg[nPos, 7] * 100, 15) + ";" //Valor de Outros Produtos
			cStrTxt += CRLF
		Next
		//==================================
		
		//======== SAÍDAS UF (DIAPUS)		
		aReg := {}		
		
		DiapMvtUsa(@aReg, cPerIni, cPerFin)
		if Len(aReg) > 0
			DiapMvtDa(@aReg, "1", cPerIni, cPerFin, 7) //VALORES DIFERENCIAL DE ALÍQUOTA
		EndIf
		
		For nPos := 1 To Len(aReg)	
			
			nVlRes  := GetValRess(aReg[nPos, 1], cPerIni, cPerFin)
			nVlMerc := GetVlMerc(aReg[nPos, 1], "1", cPerIni, cPerFin)
			
			cStrTxt += "DIAPUS;"
			cStrTxt += aReg[nPos, 1] + ";"
			cStrTxt += StrZero( aReg[nPos, 2] * 100, 15) + ";" //Valor Contábil Contribuinte
			cStrTxt += StrZero( aReg[nPos, 3] * 100, 15) + ";" //Valor Contábil não Contribuinte
			cStrTxt += StrZero( aReg[nPos, 4] * 100, 15) + ";" //Valor Base de Cálculo Contribuinte
			cStrTxt += StrZero( aReg[nPos, 5] * 100, 15) + ";" //Valor Base de Cálculo não Contribuinte
			cStrTxt += StrZero( aReg[nPos, 6] * 100, 15) + ";" //Valor Outras
			cStrTxt += StrZero((aReg[nPos, 7] - nVlMerc) * 100, 15) + ";" //Valor Demais valores
			cStrTxt += StrZero((aReg[nPos, 8] - nVlRes)  * 100, 15) + ";" //Valor Substituição Tributária
			cStrTxt += CRLF
		Next
		
		//===================================
		WrtStrTxt( nHandle, cStrTxt )
		GerTxtDIAP( nHandle, cTxtSys, "_DIUF")	
	
		Recover
		lFound := .F.
		
	End Sequence
		
Return


//---------------------------------------------------------------------
/*/{Protheus.doc} GetVlMerc

Carrega Movimentos de Saídas DIAP, agrupando-os por CFOP e UF

@Param 	cUf -> Uf do participante 
		cPeriodIni -> Período Inicial de Busca
		cPeriodFin -> Período Final de Busca
		
@Author Jean Battista Grahl Espindola
@Since 07/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GetVlMerc (cUf as Char, cOper as Char, cPeriodIni as Char, cPeriodFin as Char)

	Local cAliasReg	:= GetNextAlias()
	Local nPos 		as Numeric
	Local nValor 	as Numeric
	
	Local cCfopInd := Iif(cOper == "0", "2", "6")
	
	nValor := 0

	BeginSql Alias cAliasReg
		SELECT SUM(C30_VLRITE) VLMERC
		  FROM %table:C20%  C20
          INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02%  AND C20.C20_CODSIT = C02.C02_ID 
          INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C1H.C1H_ID     = C20.C20_CODPAR
          INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF
          INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID     = C1H.C1H_UF
          INNER JOIN %table:C0Y% C0Y ON C0Y.C0Y_FILIAL = %xfilial:C0Y%  AND C0Y.C0Y_ID     = C30.C30_CFOP
          WHERE C20.C20_FILIAL = %xfilial:C20%
	        AND C20.C20_DTDOC  BETWEEN (%Exp:cPeriodIni%) AND (%Exp:cPeriodFin%)
	        AND C20.C20_INDOPE = (%Exp:cOper%)
	        AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
	        AND C09.C09_UF	   = (%Exp:cUf%)
	        AND SUBSTRING(C0Y.C0Y_CODIGO,1,1) = ( %Exp:cCfopInd%)		       
            AND C20.%NotDel% 
	  	    AND C1H.%NotDel%
	   	    AND C09.%NotDel% 		
	EndSql		
	
	DbSelectArea(cAliasReg)
	(cAliasReg)->(DbGoTop())
	
	While (cAliasReg)->(!EOF())
		
		nValor := (cAliasReg)->VLMERC
		
		(cAliasReg)->(dbSkip())
	EndDo	
	
	(cAliasReg)->(DbCloseArea())
	
Return nValor

//---------------------------------------------------------------------
/*/{Protheus.doc} DiapMvtSa

Carrega Movimentos de Saídas DIAP, agrupando-os por CFOP e UF

@Param 	aReg -> Array dos dados passado como referência
		cPeriodIni -> Período Inicial de Busca
		cPeriodFin -> Período Final de Busca
		
@Author Jean Battista Grahl Espindola
@Since 30/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function DiapMvtUen (aReg as Array, cPeriodIni as Char, cPeriodFin as Char)

Local cAliasReg	:= GetNextAlias()
Local nPos 		as Numeric
Local cCfop 	as Char
	
	//Entradas de combustiveis, derivados ou não de petroleo e lubrificantes
	cCfop := ""
	
	for nPos := 1651 To 1664	
		cCfop += cValToChar(nPos) + "|"	
	Next
	
	for nPos := 2651 To 2664	
		cCfop += cValToChar(nPos) + "|"	
	Next
	
	for nPos := 3651 To 3664	
		cCfop += cValToChar(nPos) + "|"	
	Next
	
	//======================================================================= 
	
	//Compras de Energia Elétrica
	for nPos := 1251 To 1257	
		cCfop += cValToChar(nPos) + "|"	
	Next
	
	for nPos := 2251 To 2257	
		cCfop += cValToChar(nPos) + "|"	
	Next
	
	cCfop += "3251"
	
	//=======================================================================
	
	BeginSql Alias cAliasReg
		SELECT C09.C09_UF 	   CDUF,
			   C0Y.C0Y_CODIGO  CFOP,
			   C3S.C3S_CODIGO  IMPTO,
		 	   SUM(C2F_VLOPE)  VLCONT,
			   SUM(C2F_VALOR)  VLIMPT,
			   SUM(C2F_BASE)   VLBASE,
			   SUM(C2F_VLOUTR) VLOUTR	
	
		  FROM %table:C20%  C20
          INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02%  AND C20.C20_CODSIT = C02.C02_ID 
          INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C1H.C1H_ID     = C20.C20_CODPAR
          INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID     = C1H.C1H_UF
          INNER JOIN %table:C2F% C2F ON C2F.C2F_FILIAL = C20.C20_FILIAL AND C2F.C2F_CHVNF  = C20.C20_CHVNF
          INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S%  AND C3S.C3S_ID     = C2F.C2F_CODTRI
          INNER JOIN %table:C0Y% C0Y ON C0Y.C0Y_FILIAL = %xfilial:C0Y%  AND C0Y.C0Y_ID     = C2F.C2F_CFOP
          
          WHERE C20.C20_FILIAL = %xfilial:C20%
	        AND C20.C20_DTDOC  BETWEEN (%Exp:cPeriodIni%) AND (%Exp:cPeriodFin%)
	        AND C20.C20_INDOPE = (%Exp:'0'%)
	        AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
	        AND SUBSTRING(C0Y.C0Y_CODIGO,1,1) = ( %Exp:'2'%)
            AND C20.%NotDel% 
	  	    AND C1H.%NotDel%
	   	    AND C09.%NotDel%
		    AND C2F.%NotDel%
		    AND C3S.%NotDel%
		    AND C0Y.%NotDel%
		    
       GROUP BY C09.C09_UF, C0Y.C0Y_CODIGO, C3S.C3S_CODIGO
       ORDER BY C09.C09_UF, C0Y.C0Y_CODIGO, C3S.C3S_CODIGO  
		
	EndSql	
	
	DbSelectArea(cAliasReg)
	(cAliasReg)->(DbGoTop())
	
	While (cAliasReg)->(!EOF())
		
		If ((nPos := aScan(aReg, {|aX| aX[1] == (cAliasReg)->CDUF })) == 0)		
			Aadd(aReg, {(cAliasReg)->CDUF,;		   //UF sigla
			 			(cAliasReg)->VLCONT,; 	   //Valor Contábil
			 			(cAliasReg)->VLBASE,; 	   //Valor da Base de Cálculo
			 			(cAliasReg)->VLOUTR,;      //Valor de Outras 
			 			(cAliasReg)->VLCONT,;      //Valor de demais valores
			 			Iif((cAliasReg)->IMPTO == '04' .And.  (cAliasReg)->CFOP $ (cCfop), (cAliasReg)->VLIMPT, 0 ),;                        //Valor de Petróleo + Energia
			 			Iif((cAliasReg)->IMPTO == '04' .And. !(cAliasReg)->CFOP $ (cCfop), (cAliasReg)->VLIMPT, 0 )})                        //Valor de Outros Produtos			 			   	
		Else						
			aReg[nPos][2] += (cAliasReg)->VLCONT
			aReg[nPos][3] += (cAliasReg)->VLBASE
			aReg[nPos][4] += (cAliasReg)->VLOUTR			
			aReg[nPos][5] += (cAliasReg)->VLCONT
			aReg[nPos][6] += Iif((cAliasReg)->IMPTO == '04' .And.  (cAliasReg)->CFOP $ (cCfop), (cAliasReg)->VLIMPT, 0 ) 
			aReg[nPos][7] += Iif((cAliasReg)->IMPTO == '04' .And. !(cAliasReg)->CFOP $ (cCfop), (cAliasReg)->VLIMPT, 0 )
		EndIf
		
		(cAliasReg)->(dbSkip())
	EndDo	
	
	(cAliasReg)->(DbCloseArea())
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DiapMvtSa

Carrega Movimentos de Saídas DIAP, agrupando-os por CFOP e UF

@Param 	aReg -> Array dos dados passado como referência
		cPeriodIni -> Período Inicial de Busca
		cPeriodFin -> Período Final de Busca
		
@Author Jean Battista Grahl Espindola
@Since 30/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function DiapMvtUsa (aReg as Array, cPeriodIni as Char, cPeriodFin as Char)

Local cAliasReg	:= GetNextAlias()
Local nPos 		as Numeric
Local lContrib  as Logical
	
	BeginSql Alias cAliasReg
		SELECT C09.C09_UF 	   CDUF,
	    	   C1H.C1H_IE      CDIE,
	    	   C0Y.C0Y_CODIGO  CFOP,
		   	   C3S.C3S_CODIGO  IMPTO,
		 	   SUM(C2F_VLOPE)  VLCONT,
			   SUM(C2F_VALOR)  VLIMPT,
			   SUM(C2F_BASE)   VLBASE,
			   SUM(C2F_VLOUTR) VLOUTR	
	
		  FROM %table:C20%  C20
          INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02%  AND C20.C20_CODSIT = C02.C02_ID 
          INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C1H.C1H_ID     = C20.C20_CODPAR
          INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID     = C1H.C1H_UF
          INNER JOIN %table:C2F% C2F ON C2F.C2F_FILIAL = C20.C20_FILIAL AND C2F.C2F_CHVNF  = C20.C20_CHVNF
          INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S%  AND C3S.C3S_ID     = C2F.C2F_CODTRI
          INNER JOIN %table:C0Y% C0Y ON C0Y.C0Y_FILIAL = %xfilial:C0Y%  AND C0Y.C0Y_ID     = C2F.C2F_CFOP
          
          WHERE C20.C20_FILIAL = %xfilial:C20%
	        AND C20.C20_DTDOC  BETWEEN (%Exp:cPeriodIni%) AND (%Exp:cPeriodFin%)
	        AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)	  
	        AND SUBSTRING(C0Y.C0Y_CODIGO,1,1) = ( %Exp:'6'%)        	       
            AND C20.%NotDel% 
	  	    AND C1H.%NotDel%
	   	    AND C09.%NotDel%
		    AND C2F.%NotDel%
		    AND C3S.%NotDel%
		    AND C0Y.%NotDel%
		    
       GROUP BY C09.C09_UF, C1H.C1H_IE, C0Y.C0Y_CODIGO, C3S.C3S_CODIGO
       ORDER BY C09.C09_UF, C1H.C1H_IE, C0Y.C0Y_CODIGO, C3S.C3S_CODIGO  
		
	EndSql		

	DbSelectArea(cAliasReg)
	(cAliasReg)->(DbGoTop())
	
	While (cAliasReg)->(!EOF())
		
		lContrib := .F.
		
		if (cAliasReg)->CDIE != '' .And. (cAliasReg)->CDIE != 'ISENTO' 
			lContrib := .T.
		EndIf		
		
		If ((nPos := aScan(aReg, {|aX| aX[1] == (cAliasReg)->CDUF })) == 0)		
			Aadd(aReg, {(cAliasReg)->CDUF,;								   		       //Código UF							   				       //Contribuinte/Não Contribuinte
			 			 Iif( lContrib .And. (cAliasReg)->CFOP $ ("6107|6108|6258|6307|6357|6401|6403")  ,(cAliasReg)->VLCONT, 0 ),; 				       //Valor Contábil Contribuinte
			 			 Iif(!lContrib .And. (cAliasReg)->CFOP $ ("6107|6108|6258|6307|6357|6401|6403")  ,(cAliasReg)->VLCONT, 0 ),; 				       //Valor Contábil não Contribuinte
			 			 Iif( lContrib .And. (cAliasReg)->CFOP $ ("6107|6108|6258|6307|6357") 			 ,(cAliasReg)->VLBASE, 0 ),; 				       //Valor Base de Cálculo Contribuinte
			 			 Iif(!lContrib .And. (cAliasReg)->CFOP $ ("6107|6108|6258|6307|6357") 			 ,(cAliasReg)->VLBASE, 0 ),; 				       //Valor Base de Cálculo não Contribuinte
			 			 (cAliasReg)->VLOUTR,;                     				       //Valor Outras
			 			 (cAliasReg)->VLCONT,;                     								       //Valor Demais valores (Diferencial de Alíquota)
			 			 Iif((cAliasReg)->IMPTO == '04', (cAliasReg)->VLIMPT, 0)})  //Valor Substituição Tributária	
		Else						
			aReg[nPos][2] += Iif( lContrib .And. (cAliasReg)->CFOP $ ("6107|6108|6258|6307|6357|6401|6403") ,(cAliasReg)->VLCONT, 0 )
			aReg[nPos][3] += Iif(!lContrib .And. (cAliasReg)->CFOP $ ("6107|6108|6258|6307|6357|6401|6403") ,(cAliasReg)->VLCONT, 0 )
			aReg[nPos][4] += Iif( lContrib .And. (cAliasReg)->CFOP $ ("6107|6108|6258|6307|6357") 		 	,(cAliasReg)->VLBASE, 0 )			
			aReg[nPos][5] += Iif(!lContrib .And. (cAliasReg)->CFOP $ ("6107|6108|6258|6307|6357") 		 	,(cAliasReg)->VLBASE, 0 )
			aReg[nPos][6] += (cAliasReg)->VLOUTR
			aReg[nPos][7] += (cAliasReg)->VLCONT
			aReg[nPos][8] += Iif((cAliasReg)->IMPTO == '04', (cAliasReg)->VLIMPT, 0 )
		EndIf
		
		(cAliasReg)->(dbSkip())
	EndDo	
	
	(cAliasReg)->(DbCloseArea())
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DiapMvtDa

Carrega Movimentos de Entradas/
Saídas DIAP, agrupando-os por CFOP e UF

@Param 	aReg -> Array dos dados passado como referência
		cOper -> Tipo de Operação 0 - Entrada / 1 - Saída
		cPeriodIni -> Período Inicial de Busca
		cPeriodFin -> Período Final de Busca
		iField -> Posição da coluna que contem o valor de diferencial de Alíquota
		
@Author Jean Battista Grahl Espindola
@Since 30/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function DiapMvtDa (aReg as Array, cOper as Char, cPeriodIni as Char, cPeriodFin as Char, iField as Numeric)

Local cAliasReg	:= GetNextAlias()
Local nPos 		as Numeric
	
	BeginSql Alias cAliasReg		
		
		SELECT C09.C09_UF 	   CDUF,  
			   SUM(C20_VLRDA)  VLRDA
	      FROM %table:C20%  C20
	           INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02%  AND C20.C20_CODSIT = C02.C02_ID 
	           INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C1H.C1H_ID     = C20.C20_CODPAR 
	           INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID     = C1H.C1H_UF
	     WHERE C20.C20_FILIAL = %xFilial:C20% 
		   AND C20.C20_DTDOC  BETWEEN (%Exp:cPeriodIni%) AND (%Exp:cPeriodFin%) 
		   AND C20.C20_INDOPE = (%Exp:cOper%) 
		   AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%) 	      
		   AND C20.%NotDel% 
		   AND C02.%NotDel% 
		   AND C1H.%NotDel% 
		   AND C09.%NotDel% 
	  GROUP BY C09.C09_UF 
	  ORDER BY C09.C09_UF 
	  	
	EndSql
	
	DbSelectArea(cAliasReg)
	(cAliasReg)->(DbGoTop())
	
	While (cAliasReg)->(!EOF())
				
		If (!(nPos := aScan(aReg, {|aX| aX[1] == (cAliasReg)->CDUF })) == 0)
			aReg[nPos][iField] += (cAliasReg)->VLRDA //DIFERENCIAL DE ALÍQUOTA
		EndIf
		
		(cAliasReg)->(dbSkip())
	EndDo	
	
	(cAliasReg)->(DbCloseArea())
Return


//---------------------------------------------------------------------
/*/{Protheus.doc} GetValRess

Retorna o Valor de Ressarcimento da apuração de ICMS ST

@Param 	cUf -> Uf da apuração
		cPeriodIni -> Período Inicial de Busca
		cPeriodFin -> Período Final de Busca		
		
@Author Jean Battista Grahl Espindola
@Since 08/12/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GetValRess (cUf as Char, cPerIni as Char, cPerFin as Char)

Local cAliasReg	:= GetNextAlias()
Local nValor 	as Numeric

	nValor := 0
	
	BeginSql Alias cAliasReg	
		SELECT C3J.C3J_VLRRES VLRRES		  
		  FROM %table:C3J% C3J		 
		 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09% AND C3J.C3J_UF = C09.C09_ID		 
		 WHERE C3J.C3J_FILIAL 	= %xfilial:C3J%
		   AND C3J.C3J_DTINI   >= (%Exp:cPerIni%)
		   AND C3J.C3J_DTFIN   <= (%Exp:cPerFin%)
		   AND C09.C09_UF       = (%Exp:cUf%)
		   AND C3J.%NotDel%
		   AND C09.%NotDel%		   
	EndSql	

	DbSelectArea(cAliasReg)
	(cAliasReg)->(DbGoTop())
	
	While (cAliasReg)->(!EOF())
		
		nValor := (cAliasReg)->VLRRES
		
		(cAliasReg)->(dbSkip())
	EndDo	
	
	(cAliasReg)->(DbCloseArea())

Return nValor
