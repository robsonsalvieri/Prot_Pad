#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*{Protheus.doc} STDGComission
Busca a comissão do Vendedor

@param 
@author  Varejo
@version P11.8
@since   16/10/2012
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------

Function STDGComission( cSalesman )
Local aArea	:= GetArea()
Local nRet 	:= 0

DbSelectArea("SA3")
SA3->(DbSetOrder())
If DbSeek(xFilial("SA3")+cSalesman)
	nRet := SA3->A3_COMIS
EndIf

RestArea(aArea)

Return nRet

