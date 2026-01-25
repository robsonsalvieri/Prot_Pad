#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH "
#INCLUDE "LOCA229H.CH"

/*/{Protheus.doc} LOCA229H
Implementa o Fechamento de Embarque
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
Function LOCA229H(lFechar)
Local oExecView
Local aButtons
Local oView as Object
LOcal aArea := GetArea()
 
// Embarque já fechado não proseguir
if FQU->FQU_FCHEMB = "1" .and. lFechar
	MsgAlert(STR0002, STR0001) //"Embarque Fechado" //"Romaneio já teve o embarque fechado não é necessario fechar novamente!"
	REturn .t.
endif

if FQU->FQU_STATUS = "6"
	MsgAlert( STR0021,STR0013)  //"Pedido Emitido" //"O pedido já foi emitido não será possivel alterar o status do embarque!"
	Return .t.
endif

// Romaneio vazio não pode ter embarque fechado
FQV->(dbSetOrder(1))
if !FQV->(dbSeek(xFilial("FQV")+FQU->FQU_NUM)) // tem itens no romaneio embarque poderá ser fechado
	MsgAlert(STR0004, STR0003) //"Romaneio Vazio" //"Romaneio não possui itens o embarque não pode ser fechado!"
	RestArea(aArea)
	REturn .T.
endif

RestArea(aArea)

oView := FWLoadView("LOCA229B")
if lFechar
	oView:AddUserButton(STR0006,"OK",{|oView| Loca229HFC(oView, lFechar) },STR0005,,,.T.) //"Marca o Romaneio como Embarque Fechado" //"Fechar Embarque"
else
	oView:AddUserButton(STR0015,"OK",{|oView| Loca229HFC(oView, lFechar) },STR0014,,,.T.) //"Marca o Romaneio como Embarque Fechado" //"Fechar Embarque" //"Reabre o embarque do Romaneio." //"Reabre Embarque"
endif
oView:EnableControlBar(.T.)

aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
			  {.F.,Nil},{.T.,NIL},{.T.,STR0007},{.F.,Nil},{.F.,Nil},; //"Cancelar"
			  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
oExecView := FWViewExec():New()
oExecView:setView(oView)
if lFechar
	oExecView:setTitle(STR0006) //"A.S." //"Fechar Embarque"
else
	oExecView:setTitle(STR0015) //"A.S." //"Fechar Embarque" //"Reabre Embarque"
endif
//oExecView:setSource("LOCA229B")
oExecView:setModal(.F.)
oExecView:SetButtons(aButtons)
oExecView:setOperation(MODEL_OPERATION_VIEW)
oExecView:openView(.T.)

return .T.
/*/{Protheus.doc} Loca229HFC
Realiza o fechamento de embarque
@type function
@version 25.10
@author Alexandre Circenis
@since 28/08/2025
@param oView, object, param_description
@param lFechar, logical, param_description
@return variant, return_description
/*/
Function Loca229HFC(oView, lFechar)
Local oModel := FwModelActive()
Local oFQVGrid := oModel:GetModel("GRID")
Local nX
Local aArea := GetArea()
Local aAreaFQ5 := FQ5->(GetArea())

if lFechar

	if MsgNoYes(STR0010+CRLF+STR0008, STR0009) //"Após fechado o romaneio não poderá sofrer alteração nos itens!" //"Fechamento de Embarque" //"Confirma a Fechamento do Embarque ?"

		Begin Transaction
		RecLock("FQU", .F.)
		FQU->FQU_USREMB := __cUserID
		FQU->FQU_DFEEMB := dDataBase
		FQU->FQU_HFEEMB := Left(Time(), 5)
		FQU->FQU_FCHEMB := '1'
		msUnlock()

		// Setar as AS como embarcadas
		dbSelectArea("FQ5")
		dbSetOrder(9) // Por A.S.
		for nX := 1 to oFQVGrid:Length()

			OfQVGrid:GoLine(nX)

			if FQ5->(dbSeek(xFilial("FQ5")+oFQVGrid:GetValue("FQV_AS", nX)))
				RecLock("FQ5", .F.)
				FQ5->FQ5_STDEMA := "4"
				msUnlock()

				dbSelectArea("FQV")
				if !Empty(oFQVGrid:GetDataID())
					FQV->(dbGoTo(oFQVGrid:GetDataID()))
					RecLock("FQV", .F.)
					FQV->FQV_STATUS := '4'
					msUnlock()
				endif

			endif	

		next nX

		End Transaction
		
		MsgInfo(STR0012+FQU->FQU_NUM+STR0011,STR0009) //"Fechamento de Embarque" //" foi fechado !" //"O Embarque do Romaneio "
		
	endif
else
	if MsgNoYes(STR0018+CRLF+STR0016, STR0017)  //"Após a reabertura do embarque os itens do romaneio poderão ser alterados" //"Confirma a reabertura do embarque?" //"Reabertura de Embarque"

		Begin Transaction
		RecLock("FQU", .F.)
		FQU->FQU_USREMB := ""
		FQU->FQU_DFEEMB := Ctod("")
		FQU->FQU_HFEEMB := ""
		FQU->FQU_FCHEMB := '2'
		msUnlock()

				// Setar as AS como embarcadas
		dbSelectArea("FQ5")
		dbSetOrder(9) // Por A.S.
		for nX := 1 to oFQVGrid:Length()

			OfQVGrid:GoLine(nX)
		
			if FQ5->(dbSeek(xFilial("FQ5")+oFQVGrid:GetValue("FQV_AS", nX)))
				
				RecLock("FQ5", .F.)
				FQ5->FQ5_STDEMA := If(FQ5->FQ5_STATUS = "1", "1", "2")
				msUnlock()

				dbSelectArea("FQV")
				if !Empty(oFQVGrid:GetDataID())
					FQV->(dbGoTo(oFQVGrid:GetDataID()))
					RecLock("FQV", .F.)
					FQV->FQV_STATUS := If(FQ5->FQ5_STATUS = "1", "1", "6")
					msUnlock()
				endif
				
			endif	

		next nX


	End Transaction

	MsgInfo(STR0012+FQU->FQU_NUM+STR0020,STR0019) //"O Embarque do Romaneio " //"Reabertura do Romaneio" //" foi reaberto."
			
	endif
endif

oView:ButtonCancelAction()

RestArea(aAreaFQ5)
RestArea(aArea)

REturn .F.
