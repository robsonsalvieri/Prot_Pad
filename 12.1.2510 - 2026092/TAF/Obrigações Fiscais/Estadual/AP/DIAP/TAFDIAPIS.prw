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

Function TAFDIAPIS(aWizard as array)

	Local cTxtSys as char
	Local nHandle as numeric
	Local cStrTxt as Char
	Local cPerIni as Char
	Local cPerFin as Char
	Local cAliasReg	:= GetNextAlias()
	
	cPerIni := DtoS(aWizard[1,6])
	cPerFin := DtoS(aWizard[1,7])
	
	If !("1" $ aWizard[2,2]) 
		Return
	Endif
	
	Begin Sequence
		
		cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
		nHandle  	:= MsFCreate( cTxtSys )
		cStrTxt 	:= ""		
		
		BeginSql Alias cAliasReg	
	       SELECT CWZ.CWZ_CODMOT  CODMOT,
			   	  SUM(C35_VLISEN) VLISEN,
			   	  SUM(C35_VLOUTR) VLOUTR,
			   	  SUM(C35_VLNT)	  VLNT	   	  			  
	         
	         FROM %table:C20%  C20
	         INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02%  AND C20.C20_CODSIT = C02.C02_ID 
	         INNER JOIN %table:C30% C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF  = C20.C20_CHVNF
	         INNER JOIN %table:C35% C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF  = C30.C30_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE
	         INNER JOIN %table:CWZ% CWZ ON CWZ.CWZ_FILIAL = %xfilial:CWZ%  AND CWZ.CWZ_ID     = C35.C35_IDMINC
	         INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09%  AND C09.C09_ID     = CWZ.CWZ_IDUF AND C09.C09_CODIGO = (%Exp:'16'%)
	         INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S%  AND C3S.C3S_ID     = C35.C35_CODTRI
	                  
	         WHERE C20.C20_FILIAL = %xFilial:C20%
		       AND C20.C20_DTDOC  BETWEEN (%Exp:cPerIni%) AND (%Exp:cPerFin%)
		       AND C20.C20_INDOPE = (%Exp:'1'%)
		       AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
		       AND C35.C35_IDMINC IS NOT NULL
		       AND C3S.C3S_CODIGO = %Exp:'02'%		      
		       AND C20.%NotDel%
		       AND C30.%NotDel%
		       AND C35.%NotDel% 
		  	   AND CWZ.%NotDel%
		  	   AND C09.%NotDel%
		  	   AND C3S.%NotDel%          
			   
	       GROUP BY CWZ.CWZ_CODMOT
		EndSql
	
		DbSelectArea(cAliasReg)
		(cAliasReg)->(DbGoTop())
		
		While (cAliasReg)->(!EOF())
			
			cStrTxt += "DIAPIS;"
			cStrTxt += Substr((cAliasReg)->CODMOT,3,3) + ";"
			cStrTxt += StrZero(((cAliasReg)->VLISEN + (cAliasReg)->VLOUTR + (cAliasReg)->VLNT) * 100, 15) + ";"
			cStrTxt += CRLF
		
			(cAliasReg)->(dbSkip())
		EndDo	
		
		(cAliasReg)->(DbCloseArea())			
	
		WrtStrTxt( nHandle, cStrTxt )
		GerTxtDIAP( nHandle, cTxtSys, "_DIIS")
				
	Recover
	lFound := .F.
		
	End Sequence
		
Return