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

Function TAFDIAPMV(aWizard as array)

	Local cTxtSys as char
	Local nHandle as numeric
	Local cStrTxt as Char
	Local cPerIni as Char
	Local cPerFin as Char
	Local nPos    as Numeric	
	Local aReg 	  as Array	
	
	cPerIni := DtoS(aWizard[1,6])
	cPerFin := DtoS(aWizard[1,7])
	
	Begin Sequence
		If !("1" $ aWizard[2,1]) 
			Return
		Endif
		
		cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
		nHandle  	:= MsFCreate( cTxtSys )
		cStrTxt 	:= ""
		
		//MOVIMENTOS DE ENTRADA ================================
		aReg := {}		
		DiapMvtES(@aReg, cPerIni, cPerFin, "0", "02") //ICMS
		DiapMvtES(@aReg, cPerIni, cPerFin, "0", "05") //IPI
		DiapMvtES(@aReg, cPerIni, cPerFin, "0", "04") //ICMSST
		
		For nPos := 1 To Len(aReg)		
			cStrTxt += "DIAPEN;"
			cStrTxt += aReg[nPos, 1] + ";"
			cStrTxt += aReg[nPos, 2] + ";"
			cStrTxt += StrZero(aReg[nPos, 3] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 4] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 5] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 6] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 7] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 8] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 9] * 100, 15) + ";"
			cStrTxt += CRLF
		Next
		//=======================================================
		
		//MOVIMENTOS DE SAÍDA ===================================
		
		aReg := {}
		DiapMvtES(@aReg, cPerIni, cPerFin, "1", "02") //ICMS
		DiapMvtES(@aReg, cPerIni, cPerFin, "1", "05") //IPI
		DiapMvtES(@aReg, cPerIni, cPerFin, "1", "04") //ICMSST
		
		For nPos := 1 To Len(aReg)		
			cStrTxt += "DIAPSA;"
			cStrTxt += aReg[nPos, 1] + ";"
			cStrTxt += aReg[nPos, 2] + ";"
			cStrTxt += StrZero(aReg[nPos, 3] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 4] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 5] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 6] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 7] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 8] * 100, 15) + ";"
			cStrTxt += StrZero(aReg[nPos, 9] * 100, 15) + ";"
			cStrTxt += CRLF
		Next
		
		//=======================================================
	
		WrtStrTxt( nHandle, cStrTxt )
		GerTxtDIAP( nHandle, cTxtSys, "_MVES")		
		
		Recover
		lFound := .F.
		
	End Sequence
		
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DiapMvtES

Carrega Movimentos de Entradas e Saídas DIAP, agrupando-os por CFOP e UF

@Param 	aReg -> Array dos dados passado como referência
		cPeriodIni -> Período Inicial de Busca
		cPeriodFin -> Período Final de Busca
		cCfop 	   -> Digito 1 das CFOPs envolvidas, 1, 2 e 3 para entradas e 5, 6 e 7 para Saídas
		cImposto   -> Código do imposto conforme tabela C3S
		
@Author Jean Battista Grahl Espindola
@Since 16/11/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function DiapMvtES (aReg as Array, cPeriodIni as Char, cPeriodFin as Char, cIndOper as Char, cImposto as Char)

Local cAliasReg	:= GetNextAlias()
Local cCfop		as Char
Local nPos 		as Numeric
	
	BeginSql Alias cAliasReg	
       SELECT C09.C09_UF 	  CDUF,  
		   	  C0Y.C0Y_CODIGO  CDCFOP,
		 	  SUM(C2F_VLOPE)  VLCONT,
			  SUM(C2F_VALOR)  VLIMPT,
			  SUM(C2F_BASE)   VLBASE,
			  SUM(C2F_VLISEN) VLISEN,
			  SUM(C2F_VLOUTR) VLOUTR
         
         FROM %table:C20%  C20
         INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02%  AND C20.C20_CODSIT = C02.C02_ID 
         INNER JOIN %table:C1H% C1H ON C1H.C1H_FILIAL = C20.C20_FILIAL AND C1H.C1H_ID     = C20.C20_CODPAR
         INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xFilial:C09%  AND C09.C09_ID     = C1H.C1H_UF
         INNER JOIN %table:C2F% C2F ON C2F.C2F_FILIAL = C20.C20_FILIAL AND C2F.C2F_CHVNF  = C20.C20_CHVNF
         INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S%  AND C3S.C3S_ID     = C2F.C2F_CODTRI
         INNER JOIN %table:C0Y% C0Y ON C0Y.C0Y_FILIAL = %xfilial:C0Y%  AND C0Y.C0Y_ID     = C2F.C2F_CFOP
         
         WHERE C20.C20_FILIAL = %xFilial:C20%
	       AND C20.C20_DTDOC  BETWEEN (%Exp:cPeriodIni%) AND (%Exp:cPeriodFin%)
	       AND C20.C20_INDOPE = (%Exp:cIndOper%)
	       AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)	      
	       AND C3S.C3S_CODIGO = %Exp:cImposto%
	       AND C20.%NotDel% 
	  	   AND C1H.%NotDel%
	   	   AND C2F.%NotDel%
		   AND C0Y.%NotDel%
		   AND C3S.%NotDel% 	             
		   AND C09.%NotDel%
       GROUP BY C09.C09_UF, C0Y.C0Y_CODIGO
       ORDER BY C0Y.C0Y_CODIGO, C09.C09_UF
	EndSql

	DbSelectArea(cAliasReg)
	(cAliasReg)->(DbGoTop())
	
	While (cAliasReg)->(!EOF())
		
		cCfop  := Substr((cAliasReg)->CDCFOP, 1, 1) + "." + Substr((cAliasReg)->CDCFOP, 2, 3)		
				
		If ((nPos := aScan(aReg, {|aX| aX[1] == cCfop .And. aX[2] == (cAliasReg)->CDUF})) == 0)
			Aadd(aReg, { cCfop,;
			 			(cAliasReg)->CDUF,;
			 			 Iif(cImposto == "02" ,(cAliasReg)->VLCONT, 0 ),; //ICMS
			 			 Iif(cImposto == "02" ,(cAliasReg)->VLBASE, 0 ),; //ICMS
			 			 Iif(cImposto == "02" ,(cAliasReg)->VLIMPT, 0 ),; //ICMS
			 			 Iif(cImposto == "02" ,(cAliasReg)->VLISEN, 0 ),; //ICMS
			 			 Iif(cImposto == "02" ,(cAliasReg)->VLOUTR, 0 ),; //ICMS
			 			 Iif(cImposto == "05" ,(cAliasReg)->VLIMPT, 0 ),; //IPI
			 			 Iif(cImposto == "04" ,(cAliasReg)->VLIMPT, 0 )}) //ICMS-ST			
		Else
			If (cImposto == "02")			
				aReg[nPos][3] += (cAliasReg)->VLCONT
				aReg[nPos][4] += (cAliasReg)->VLBASE
				aReg[nPos][5] += (cAliasReg)->VLIMPT			
				aReg[nPos][6] += (cAliasReg)->VLISEN
				aReg[nPos][7] += (cAliasReg)->VLOUTR
			
			ElseIf (cImposto == "04")
				aReg[nPos][9] += (cAliasReg)->VLIMPT
			
			Else
				aReg[nPos][8] += (cAliasReg)->VLIMPT
			EndIf
			
		EndIf
		(cAliasReg)->(dbSkip())
	EndDo	
	
	(cAliasReg)->(DbCloseArea())
Return