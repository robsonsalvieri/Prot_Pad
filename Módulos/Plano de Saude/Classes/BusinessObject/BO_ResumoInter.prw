#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class BO_ResumoInter from BO_Guia
		
	method New() Constructor
	method getNumInt(cChave, cTipo)
		
endClass

method new() class BO_ResumoInter
return self


//-------------------------------------------------------------------
/*/{Protheus.doc} getNumInt
Recupera/transforma o número da Guia de Internação, pois o campo BE4_GUIINT converte para outro padrão
@Obs: cTipo : 1- Pesquisa pelo índice 1 (BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO) / 2 - Pelo número da Internação (BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
Se cTipo Vazio, procura nos dois índíces. 
@author Renan Martins
@since 03/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNumInt(cChave,cTipo) Class BO_ResumoInter
Local lValTd	:= Iif (Empty(cTipo), .T., .F.)
Local lAchou	:= .F.
Local aArea	:= BE4->(GetArea())
Local cRet		:= ""

If (cTipo == '1' .Or. lValTd)
	BE4->(DbSetOrder(1)) //BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO
	If ( BE4->(DbSeek(xFilial("BE4")+cChave)) )
		cRet := (BE4->BE4_CODOPE + BE4->BE4_ANOINT + BE4->BE4_MESINT + BE4->BE4_NUMINT) + "|" + dtoc(BE4->BE4_DTDIGI) + "|" + BE4->BE4_SENHA
		lAchou := .T.
	Else
		cRet := cChave
	EndIf
EndIf

If (cTipo == '2' .Or. lValTd .And. !lAchou)
	BE4->(DbSetOrder(2)) //BE4_FILIAL, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT
	If ( BE4->(DbSeek(xFilial("BE4")+cChave)) )
		cRet := (BE4->BE4_CODOPE + BE4->BE4_CODLDP + BE4->BE4_CODPEG + BE4->BE4_NUMERO) + "|" + dtoc(BE4->BE4_DTDIGI) + "|" + BE4->BE4_SENHA 
	Else
		cRet := cChave
	EndIf
EndIf	

RestArea(aArea)	

Return cRet	


//-------------------------------------------------------------------
/*/{Protheus.doc} BO_ResumoInter
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function BO_ResumoInter
Return