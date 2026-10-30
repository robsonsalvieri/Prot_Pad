#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFsmPlan
Métodos Rest do FSM para Planejamento de O.S.
@author fernanda.rigolin
@since 31/07/2026
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMPLAN DESCRIPTION "WS de Integração Field Services Manager - Planejamento de O.S."

	WSDATA dataInicio AS STRING
	WSDATA dataFinal AS STRING

	WSMETHOD POST consAgenda    DESCRIPTION 'Retorna Agendas dos Atendimentos' PATH "agenda"     PRODUCES APPLICATION_JSON
	WSMETHOD GET  consTecnicos  DESCRIPTION 'Retorna Agendas dos Técnicos'     PATH "tecnicos"   PRODUCES APPLICATION_JSON
	WSMETHOD POST cnsAtendentes DESCRIPTION 'Retorna Atendentes por Grupos'    PATH "atendentes" PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author fernanda.rigolin
@since 28/07/2026
@version 1.0
*/
//-------------------------------------------------------------------

WSMETHOD POST consAgenda WSREST FSMPLAN

    Local lRet      := .F.
    Local oRequest  := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cBody     := Self:GetContent()
    Local cMsgRet   := ''

    oRequest:FromJson(cBody)

    lRet := fsmxageatd(oRequest, @oResponse, @cMsgRet)

    If lRet
        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
    Else
        SetRestFault(400, EncodeUtf8(cMsgRet))
    EndIf

    oResponse := Nil
    oRequest  := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author fernanda.rigolin
@since 05/08/2026
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD GET consTecnicos WSRECEIVE dataInicio, dataFinal WSREST FSMPLAN
    Local lRet      := .F.
    Local oResponse := JsonObject():New()
    Local cMsgRet   := ''
    Local cDataInicio := ""
    Local cDataFinal  := ""

    cDataInicio := Self:dataInicio
    cDataFinal  := Self:dataFinal


    If Empty(cDataInicio)
    	SetRestFault(404, EncodeUtf8("Data Início não informada"))
    	Return .F.
    Endif	

    If Empty(cDataFinal)
    	SetRestFault(404, EncodeUtf8("Data Final não informada"))
    	Return .F.
    Endif

    lRet := fsmxagetec(cDataInicio, cDataFinal, @oResponse, @cMsgRet)

    If lRet
        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
    Else
        SetRestFault(400, EncodeUtf8(cMsgRet))
    EndIf

    oResponse := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} 

@author fernanda.rigolin
@since 14/09/2026
@version 1.0
*/
//-------------------------------------------------------------------
WSMETHOD POST cnsAtendentes WSREST FSMPLAN

    Local oRequest  := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cBody     := Self:GetContent()

    oRequest:FromJson(cBody)

    fsmxatends(oRequest, @oResponse)
    
    Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

    oResponse := Nil
    oRequest  := Nil

Return
