#Include "Protheus.ch"

Static lIsPOS := Nil			// Verifica se é TOTVS PDV 


//--------------------------------------------------------
/*/{Protheus.doc} STFIsPOS
Verifica se é TOTVS PDV
@type function
@author  	Varejo
@since   	01/03/2012
@version 	P12
@param 		STFIsPOS  , identifica se o módulo é FrontLoja 23
@return	    lIsPOS - Retorna se é TOTVS PDV
/*/
//--------------------------------------------------------
Function STFIsPOS(lFront)
Local nMod := 0

Default lFront := .F.

If lIsPOS = Nil 

	If lFront
		nMod := 23
	Else
		nMod := 12
	EndIf 
	
	If Type("nModulo") == "N"
		nMod := nModulo
	EndIf
	
	If nMod == 23
		
		lIsPOS := ExistFunc("FWPosLight") .AND. FWPosLight()
		
		If !lIsPOS
			lIsPOS := STFPdvOn()
		EndIf		
	Else
		lIsPOS := .F.
	EndIf

EndIf	

Return lIsPOS 


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSetPOS
Atribui a flag se for TOTVS PDV.
Esse método pode ser usado para forcar a marca que é TOTVS PDV
@type function
@param   lValue
@author  rafael.pessoa
@version P12
@since   02/03/2018
@return  lIsPOS - Retorna se é PDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFSetPOS(lValue)

Default lValue := .F.

lIsPOS := lValue

Return lIsPOS


//-------------------------------------------------------------------
/*/{Protheus.doc} STFPdvOn
Retorna se esta trabalhando com o PDV Online

@type 		function
@author  	Bruno Almeida
@version 	P12
@since   	29/04/2022
@return  	lRet - Retorna se o PDV esta trabalhando Online
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFPdvOn(cEstacao)

Local lRet 	:= .F.
Local aArea := GetArea()

Default cEstacao := ""

If SLG->(ColumnPos("LG_PDVON")) > 0
	If Empty(cEstacao)
		lRet := AllTrim(STFGetStat("PDVON")) == "1"
	Else
		SLG->(dbSetOrder(1)) //LG_FILIAL+LG_CODIGO
		If SLG->(dbSeek(xFilial("SLG") + PadR(cEstacao,TamSX3("LG_CODIGO")[1])))
			lRet := AllTrim(SLG->LG_PDVON) == "1"
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet
