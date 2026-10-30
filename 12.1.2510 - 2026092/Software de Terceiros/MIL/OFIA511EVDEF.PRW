#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOPCONN.CH'

/*/ { Protheus.doc } OFIA511EVDEF
	Eventos Exportacao Do Arquivo PMMANAGE (JDPrism)

	@author Bruno Hebeler Forcato
	@since 15/10/2025
/*/
Class OFIA511EVDEF FROM FWModelEvent
	Data cLog

	Method New()
	Method InTTS()
	Method AfterTTS()
End Class

Method New(cLog) Class OFIA511EVDEF
	::cLog := cLog
Return

/*/{Protheus.doc} InTTS
	Método que é chamado pelo MVC quando ocorrer as ações do commit após 
	as gravações porém antes do final da transação.

	@param oModel   - Modelo de dados de Contrato.
	@author Bruno Hebeler Forcato
	@since 15/10/2025
/*/
Method InTTS(oModel) Class OFIA511EVDEF
	Local oBase := oModel:GetModel("CONTAS")
	local cConta := "OLD"
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)

	if empty(oBase)
		return
	endif

	if lNovoCombo
		cConta := oBase:GetValue('OFA_CONTA')
	endif

	OA5110012_ProcessaPMM(cConta, oModel)
Return

/*/{Protheus.doc} AfterTTS
	Método que é chamado pelo MVC quando ocorrer as ações do commit após 
	as gravações depois do final da transação.

	@param oModel   - Modelo de dados de Contrato.
	@author Bruno Hebeler Forcato
	@since 15/10/2025
/*/
Method AfterTTS(oModel) Class OFIA511EVDEF
	local oBase := oModel:GetModel("LOGS")
	Local oView := FWViewActive()

	::cLog := oBase:getValue("OFA_LOG")
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})
	oView:ButtonCancelAction()
	OFIA511(,,,::cLog)
Return 
