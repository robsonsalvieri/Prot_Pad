#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} OFIA551EVDEF
    @author Bruno Forcato
    @since 11/02/2026
    @version version
    /*/
Class OFIA551EVDEF From FWModelEvent
    public data oConfig
    public data JJsonConfig

    method new() constructor
    method destroy()
	method ModelPosVld(oModel, cModelId)
	method GridPreVld()

    method _setaDiarioOficina(oModel, cModelID)
	method _setaPriorizacaoAtendimento()
EndClass

/*/{Protheus.doc} new
	Metodo de construção da classe

	@author Bruno Forcato
	@since 11/02/2026
/*/
Method new() Class OFIA551EVDEF
    self:JJsonConfig := JsonObject():New()
    self:oConfig := OfScaniaConfig():New("","OFIA551")
return .t.

/*/{Protheus.doc} destroy

	@author Bruno Forcato
	@since 11/02/2026
/*/
Method destroy() Class OFIA551EVDEF
    freeObj(self:oConfig)
    freeObj(self:JJsonConfig)
return .t.

/*/{Protheus.doc} new
	Metodo pos-validação do model

	@author Bruno Forcato
	@since 11/02/2026
/*/
method ModelPosVld(oModel, cModelId) class OFIA551EVDEF
    DbSelectArea("VRN")
    DbSetOrder(1)
    if DbSeek(xFilial("VRN") + "OFIA551")
        if !Empty(VRN->VRN_CONFIG)
            self:JJsonConfig:FromJson(VRN->VRN_CONFIG)
        endif
    endif
    DbCloseArea()
	self:_setaDiarioOficina(oModel, cModelId)
    self:_setaPriorizacaoAtendimento(oModel, cModelId)
    self:oConfig:saveConfig(self:jJsonConfig)
return .T.

/*/{Protheus.doc} _setaDiarioOficina
    Salva o json do Diario da Oficina
    @author Bruno Forcato
    @since 11/02/2026
    /*/
Method _setaDiarioOficina(oModel, cModelID) Class OFIA551EVDEF
    local oSubModAgendamento := oModel:getModel("TABAGE")
    local oSubModOrdemServico := oModel:getModel("TABOS")
    local jTarget := JsonObject():New()
    local aCampos := {}
    local nX := 0
    local cKey := ""

    if !self:jJsonConfig:HasProperty("DIAOFI")
        self:jJsonConfig["DIAOFI"] := JsonObject():New()
    endif

    jTarget["AGE_MULTIAGEN"] := oSubModAgendamento:GetValue("AGE_MULTIAGEN")
    jTarget["AGE_EXISTAGEN"] := oSubModAgendamento:GetValue("AGE_EXISTAGEN")

    jTarget["OS_VALIDINTERAGE"] := oSubModOrdemServico:GetValue("OS_VALIDINTERAGE")
    jTarget["OS_INTERMIN"] := oSubModOrdemServico:GetValue("OS_INTERMIN")
    jTarget["OS_VALIDANTAGEHORA"] := oSubModOrdemServico:GetValue("OS_VALIDANTAGEHORA")
    jTarget["OS_VALIDDEPAGEHORA"] := oSubModOrdemServico:GetValue("OS_VALIDDEPAGEHORA")

    aCampos := jTarget:GetNames()

    for nX := 1 to Len(aCampos)
        cKey := aCampos[nX]
        self:jJsonConfig["DIAOFI"][cKey] := jTarget[cKey]
    next
return .t.

/*/{Protheus.doc} _setaDiarioOficina
    Salva o json do Diario da Oficina
    @author Bruno Forcato
    @since 11/02/2026
    /*/
Method _setaPriorizacaoAtendimento(oModel, cModelID) Class OFIA551EVDEF
	local oSubModGeracaoSenha := oModel:getModel("TABGESE")
	local oSubModAcompanhaCliente := oModel:getModel("TABACCLI")
	local oSubModAgendamento := oModel:getModel("TABCAAGE")
	local oSubModTempoTolerancia := oModel:getModel("TABTOL")
	local oSubModSequencialSenha := oModel:getModel("TABSEQ")
	local aConfigGeracaoSenha := {}
	local aConfigAgendamento := {}
	local jDados := JsonObject():New()
	local jTarget := JsonObject():New()
	local aCampos := {}
	local nX := 0
	local cKey := ""

	if !self:jJsonConfig:HasProperty("PRIOATE")
		self:jJsonConfig["PRIOATE"] := JsonObject():New()
	endif

	for nX := 1 to oSubModGeracaoSenha:Length()
		oSubModGeracaoSenha:GoLine(nX)
		if ! oSubModGeracaoSenha:IsDeleted()
			jDados := JsonObject():New()
			jDados['GESE_ORDEM'] := oSubModGeracaoSenha:GetValue('GESE_ORDEM')
			jDados['GESE_TPCONTRATO'] := oSubModGeracaoSenha:GetValue('GESE_TPCONTRATO')
			jDados['GESE_DESC'] := oSubModGeracaoSenha:GetValue('GESE_DESC')
			AADD(aConfigGeracaoSenha, jDados)
		endif
	next

    jTarget["GESE"] := aConfigGeracaoSenha
    jTarget["ACCLI_TEMPCHAMADAS"] := oSubModAcompanhaCliente:GetValue("ACCLI_TEMPCHAMADAS")
    jTarget["ACCLI_IDENTPAINEL"] := oSubModAcompanhaCliente:GetValue("ACCLI_IDENTPAINEL")
	jTarget["TTO_TEMPOCHEGADA"] := oSubModTempoTolerancia:GetValue("TTO_TEMPOCHEGADA")
    jTarget["SESE_TEMPORESETSENHA"] := oSubModSequencialSenha:GetValue("SESE_TEMPORESETSENHA")

	for nX := 1 to oSubModAgendamento:Length()
		oSubModAgendamento:GoLine(nX)
		if ! oSubModAgendamento:IsDeleted()
			jDados := JsonObject():New()
			jDados['AAGE_FILIAL'] := oSubModAgendamento:GetValue('AAGE_FILIAL')
			jDados['AAGE_CANALAGENDA'] := oSubModAgendamento:GetValue('AAGE_CANALAGENDA')
			AADD(aConfigAgendamento, jDados)
		endif
	next

	jTarget["AGENDAMENTO"] := aConfigAgendamento
	aCampos := jTarget:GetNames()

	for nX := 1 to Len(aCampos)
		cKey := aCampos[nX]
		self:jJsonConfig["PRIOATE"][cKey] := jTarget[cKey]
	next
return .t.

/*/{Protheus.doc} GridPreVld
	Metodo pre-validação da grid

	@author Bruno Forcato
	@since 30/03/2026
/*/
METHOD GridPreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA551EVDEF
	local nx := 0
	local nOrder := 0
	Local aSaveLines
	local oView := FWViewActive()
	Local lConsidera := .T.

	If cModelId == "TABGESE"
		If cAction == "DELETE" .OR. cAction == "UNDELETE"
			aSaveLines := FWSaveRows()
			nOrder := 0

			For nx := 1 To oSubModel:Length()
				oSubModel:GoLine(nx)

				 lConsidera := .T.
				If cAction == "DELETE" .AND. nx == nLine
					lConsidera := .F.
				EndIf

				If cAction == "UNDELETE" .AND. nx == nLine
					lConsidera := .T.
				EndIf

				If nx <> nLine .AND. oSubModel:IsDeleted()
					lConsidera := .F.
				EndIf

				If lConsidera
					nOrder++
					oSubModel:SetValue("GESE_ORDEM", nOrder)
				EndIf 	
			Next

			FWRestRows(aSaveLines)
			oView:Refresh()
		EndIf
	EndIf
return .t.