#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class BO_Sadt from BO_Guia
		
	method New() Constructor
	method getTipProc(cChave)
		
endClass

method new() class BO_Sadt
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipProc
Retorna tipo do procedimento
@author Pablo Alipio
@since 30/07/2018
@version P12
/*/
//-------------------------------------------------------------------
method getTipProc(cChave) Class BO_Sadt
Local cTipoProc	:= ""
Local aArea	:= BR8->(GetArea())


BR8->(DbSetOrder(1))//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
If ( BR8->(MsSeek(xFilial("BR8")+cChave)) )
	cTipoProc := BR8->BR8_TPPROC + "*" + X3COMBO("BR8_TPPROC",BR8->BR8_TPPROC)
EndIf
	
RestArea(aArea)	

Return cTipoProc

//-------------------------------------------------------------------
/*/{Protheus.doc} BO_Sadt
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function BO_Sadt
Return