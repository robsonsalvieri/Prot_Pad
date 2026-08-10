#include 'protheus.ch'

Function TAFGSTA1 (aWizard as array, aFilial as array, cJobAux as char)

Local nHandle      as Numeric
Local oError	   as Object
Local cTxtSys  	   as Char
Local cStrTxt 	   as Char
Local cREG 		   as Char      
Local lFound       as logical   
Local dDatIni      as date
Local dDatFim      as date  

Local nTotLin      as numeric

//*****************************
// *** INICIALIZA VARIAVEIS ***
//*****************************
oError	    := ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )
cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
nHandle   	:= MsFCreate( cTxtSys )
cREG 		:= "A1"
lFound      := .T.
cStrTxt 	:= ""
nTotLin     := 0
cAliasR     := GetNextAlias()
dDatIni 	:=  CToD("01/" + SubStr(aWizard[1,3],1,2) + "/"+ cValToChar(aWizard[1,4]))   
dDatFim 	:=  Lastday(dDatIni)

Begin Sequence	
	
	BeginSql Alias cAliasR
	   SELECT C20.C20_NUMDOC C20_NUMDOC, 
	          C20.C20_SERIE C20_SERIE, 
	          C20.C20_DTES C20_DTES, 
	          C1H.C1H_IE C1H_IE, 
	          SUM(C35.C35_VALOR) C35_VALOR
	   	 FROM %table:C20% C20
		   	 INNER JOIN %table:C1H% C1H ON C20.C20_FILIAL = C1H.C1H_FILIAL AND C20.C20_CODPAR = C1H.C1H_ID
		   	 INNER JOIN %table:C0U% C0U ON C0U.C0U_FILIAL = %xfilial:C0U% AND C20.C20_TPDOC   = C0U.C0U_ID
		   	 INNER JOIN %table:C02% C02 ON C02.C02_FILIAL = %xfilial:C02% AND C20.C20_CODSIT  = C02.C02_ID		   	 		   	 
		   	 INNER JOIN %table:C35% C35 ON C20.C20_FILIAL = C35.C35_FILIAL AND C20.C20_CHVNF  = C35.C35_CHVNF       
		   	 INNER JOIN %table:C3S% C3S ON C3S.C3S_FILIAL = %xfilial:C3S% AND C35.C35_CODTRI  = C3S.C3S_ID    
		   	 INNER JOIN %table:C09% C09 ON C09.C09_FILIAL = %xfilial:C09% AND C1H.C1H_UF 	  = C09.C09_ID
        WHERE C20.C20_FILIAL = %Exp:aFilial[1]%
		  AND C20_DTES BETWEEN %Exp:DTOS(dDatIni)% AND %Exp:DTOS(dDatFim)%
		  AND C20.C20_INDOPE = %Exp:'0'%    											//Entrada
		  AND C02.C02_CODIGO NOT IN ( %Exp:'02'%, %Exp:'03'%, %Exp:'04'%, %Exp:'05'%)  	//canceladas e inutilizadas
		  AND C3S.C3S_CODIGO =  %Exp:'04'%												//ICMS-ST	  
		  AND C09.C09_UF 	 = %Exp:Substr(aWizard[1][7],1,2)%
		  AND C0U.C0U_CODIGO = %Exp:'01'%   											//Doc. Devolução
		  AND C20.%NotDel%  
		  AND C1H.%NotDel%
		  AND C0U.%NotDel%
		  AND C02.%NotDel%		  
		  AND C35.%NotDel%
		  AND C3S.%NotDel%
		  AND C09.%NotDel%	
		GROUP BY C20.C20_NUMDOC, 
				 C20.C20_SERIE, 
				 C20.C20_DTES, 
				 C1H.C1H_IE 	  
	EndSql
	
	While !(cAliasR)->(Eof())
		nTotLin++
		
		cStrTxt := cReg
		cStrTxt += PADL(Alltrim((cAliasR)->C20_NUMDOC),13,"0")
		cStrTxt += PADR((cAliasR)->C20_SERIE,03)
		cStrTxt += PADR(TAFRemCharEsp((cAliasR)->C1H_IE),14)
		cStrTxt += PADR((cAliasR)->C20_DTES,08)
		cStrTxt += StrTran(StrZero((cAliasR)->C35_VALOR, 16, 2),".","") 
		cStrTxt += CRLF
		
		WrtStrTxt( nHandle, cStrTxt )
		(cAliasR)->(DbSkip())
	EndDo
	
	(cAliasR)->(DbCloseArea())
	
	GerTxtGST( nHandle, cTxtSys, aFilial[01] + "_" + cReg )
	
	PutGlbValue( "nQtdAnxI_"+aFilial[1] , Str(nTotLin) )
	GlbUnlock()

Recover	
	lFound := .F.

End Sequence

//Tratamento para ocorrência de erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

Else
	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()

EndIf

Return



