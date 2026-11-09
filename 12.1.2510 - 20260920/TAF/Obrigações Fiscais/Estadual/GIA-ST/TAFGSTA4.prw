#include 'protheus.ch'

Function TAFGSTA4 (aWizard as array, aFilial as array, cJobAux as char)

Local nHandle      as Numeric
Local oError	   as Object
Local cTxtSys  	   as Char
Local cStrTxt 	   as Char
Local cREG 		   as Char      
Local lFound       as logical   
Local dDatIni      as date
Local dDatFim      as date  
Local nX           as numeric
Local nY           as numeric
Local aGuiaDifal   as array
Local aDifal       as array
Local aFCP         as array
Local nTotLin      as numeric

oError	    := ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )
nTotLin     := 0
lFound      := .T.

Begin Sequence	
	
	If ("1" $ aWizard[2][2])		
		cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
		nHandle   	:= MsFCreate( cTxtSys )		
		cREG 		:= "A4"		
		cStrTxt 	:= ""		
		cAliasR     := GetNextAlias()
		dDatIni 	:= CToD("01/" + SubStr(aWizard[1,3],1,2) + "/"+ cValToChar(aWizard[1,4]))   
		dDatFim 	:= Lastday(dDatIni)
		aDifal      := {}
		aFCP        := {}
		
		aGuiaDifal := TAFGuiaDif(aWizard, aFilial, dDatIni, dDatFim)
		
		For nX := 1 To Len(aGuiaDifal)
			For nY := 1 To Len(aGuiaDifal[nX])
				IIF(nX == 1, aAdd(aDifal, aGuiaDifal[nX,nY]), nil)
				IIF(nX == 3, aAdd(aFCP,   aGuiaDifal[nX,nY]), nil)
			Next nY
		Next nX
		
		For nX := 1 To Len(aDifal)
			cStrTxt := cReg
			cStrTxt += aDifal[nX,1]
			cStrTxt += StrTran(StrZero(aDifal[nX,2], 16, 2),".","")
			
			If(Len(aFCP) >= nX)
				cStrTxt += aFCP[nX,1]
				cStrTxt += StrTran(StrZero(aFCP[nX,2], 16, 2),".","")
			Else
				cStrTxt += Replicate("0",8)
				cStrTxt += Replicate("0",15)
			EndIf
			
			cStrTxt += CRLF
		
			WrtStrTxt( nHandle, cStrTxt )
			nTotLin++
		Next nX
		
		GerTxtGST( nHandle, cTxtSys, aFilial[01] + "_" + cReg )
	EndIf
	
	
	PutGlbValue( "nQtdAnxIV_"+aFilial[1] , Str(nTotLin) )
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



