#INCLUDE 'Protheus.ch'

//------------------------------------------------------------------------------
/*{Protheus.doc} STDChangePay
Retorna uma string com as formas de pagamento cadastradas no DE/PARA
@param   	cTpForm,cChgPay     
@author     Fábio Siqueira dos Santos
@version    P12
@since      02/04/2018
@return     cChgPay
/*/
//------------------------------------------------------------------------------
Function STDChgPay(cTpForm, cChgPay)
Local aArea		:= GetArea()
Local aRet		:= {}
Local cFilMHI	:= ""
Local cRet		:= ""
Local cSep		:= ";"
Local nCount	:= 0

MHI->(DbSetOrder(1))
If MHI->(DbSeek(xFilial("MHI")+AllTrim(cTpForm)))
	cFilMHI := MHI->MHI_FILIAL
	While !MHI->(EOF()) .AND. cFilMHI == MHI->MHI_FILIAL .And. AllTrim(cTpForm) == AllTrim(MHI->MHI_FRMPRI)		
		Aadd(aRet,AllTrim(MHI->MHI_FRMTRO) + " - " + POSICIONE( "SX5", 1, xFilial( "SX5" ) + "24"+ MHI->MHI_FRMTRO, "X5_DESCRI" ))		
		MHI->(DbSkip())
	End	
	If Len(aRet) > 0
		cChgPay := AllTrim(aRet[1])
	 	For nCount := 2 To Len(aRet)
			cChgPay +=  cSep + AllTrim(aRet[nCount])
	 	Next nCount	 		 	
	EndIf      
EndIf

RestArea(aArea)

Return cChgPay