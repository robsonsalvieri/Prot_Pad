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

Function TAFDIAPDI(aWizard as array)

	Local cAliasReg	:= GetNextAlias()
	
	Local cTxtSys as Char
	Local nHandle as Numeric
	Local cStrTxt as Char
	Local cPerIni as Char
	Local cPerFin as Char	
	Local cMoeda  as Char
	Local cNroDi  as Char
	
	cPerIni := DtoS(aWizard[1,6])
	cPerFin := DtoS(aWizard[1,7])
	
	Begin Sequence
		
		cTxtSys := CriaTrab( , .F. ) + ".TXT"
		nHandle := MsFCreate( cTxtSys )
		cStrTxt := ""
		cMoeda 	:= "DOLAR%"		
		
		BeginSql Alias cAliasReg	
	       SELECT C23.C23_NUMDOC 	  NUMDOC,
	       		  C20.C20_DTDOC  	  DTDOC,
	       		  CZU.CZU_CODIGO 	  CODIGO,
	       		  SUM(C23.C23_VLMOOR) VLMOOR,
	       		  SUM(C23.C23_VLCVMO) VLCVMO		  
	         
	         FROM %table:C20%  C20
	         INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02%  AND C20.C20_CODSIT = C02.C02_ID 
	         INNER JOIN %table:C23% C23 ON C23.C23_FILIAL = C20.C20_FILIAL AND C23.C23_CHVNF  = C20.C20_CHVNF
	         INNER JOIN %table:CZU% CZU ON CZU.CZU_FILIAL = %xfilial:CZU%  AND C23.C23_IDMOED = CZU.CZU_ID
	                  
	         WHERE C20.C20_FILIAL 	= %xfilial:C20%
		       AND C20.C20_DTDOC  BETWEEN (%Exp:cPerIni%) AND (%Exp:cPerFin%)
		       AND C20.C20_INDOPE 	= (%Exp:'0'%)
		       AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)
		       AND C23.C23_TIPO 	= (%Exp:'0'%)
		       AND CZU.CZU_DESCRI LIKE (%Exp:cMoeda%) OR  CZU.CZU_DESCRI = (%Exp:'EURO'%)
		       AND C20.%NotDel%
		       AND C02.%NotDel%
		       AND C23.%NotDel%
		       AND CZU.%NotDel%
			   
		    GROUP BY C23.C23_NUMDOC, C20.C20_DTDOC, CZU.CZU_CODIGO
		EndSql
	
		DbSelectArea(cAliasReg)
		(cAliasReg)->(DbGoTop())
		
		While (cAliasReg)->(!EOF())
			
			cNroDi := StrTran(StrTran(StrTran((cAliasReg)->NUMDOC, "/", ""),"-", ""), ".", "")
			
			cNroDi := TRANSFORM(Strzero(Val(cNroDi),10), "@R 99/9999999-9") 
			
			
			cStrTxt += "DIAPDI;"
			cStrTxt += cNroDi + ";"
			cStrTxt += (cAliasReg)->DTDOC  + ";"
			cStrTxt += Iif((cAliasReg)->CODIGO == "978","002","001") + ";" //2 - Euro / 1 - Dolar
			cStrTxt += StrZero((cAliasReg)->VLMOOR * 100, 15) + ";"
			cStrTxt += StrZero((cAliasReg)->VLCVMO * 100, 15) + ";"
			cStrTxt += CRLF
		
			(cAliasReg)->(dbSkip())
		EndDo	
		
		(cAliasReg)->(DbCloseArea())			
	
		WrtStrTxt ( nHandle, cStrTxt )
		GerTxtDIAP( nHandle, cTxtSys, "_DIDI")
				
		Recover
		lFound := .F.
		
	End Sequence
		
Return