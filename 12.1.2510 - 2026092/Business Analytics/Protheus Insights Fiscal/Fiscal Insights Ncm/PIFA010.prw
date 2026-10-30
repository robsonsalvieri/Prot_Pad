#Include "Totvs.ch"
#Include "PIFA010.ch"

Static __oTempTable

//------------------------------------------------------------------------------
/* {Protheus.doc} PIFA010
    Chamada da rotina de Fiscal Insight NCM

    @type Function
    @author Squad PIF
    @return Nil
*/
//------------------------------------------------------------------------------
Function PIFA010(lVldPif As Logical)

	Default lVldPif := .T.

	If totvs.protheus.backoffice.ba.insights.util.pinsCheckEnv() .And. lVldPif // Valida ambiente Produção ou Engenharia Protheus Insights

		If AliasInDic("I14")
			DbSelectArea("I14")
		EndIf
		If AliasInDic("I19")
			DbSelectArea("I19")
		EndIf
		If AliasInDic("I20")
			DbSelectArea("I20")
		EndIf
		If AliasInDic("I21")
			DbSelectArea("I21")
		EndIf
		If AliasInDic("I1A")
			DbSelectArea("I1A")
		EndIf

		IIF(IsBlind(), .T., FwCallApp("pifa010"))

		// Deleta Temporária
		IIF(__oTempTable <> NIL, __oTempTable:Delete(), .F.)

	Else

		Help(Nil, Nil, "PIFA010", "Protheus Insights", STR0001, 1	;			    // "Identificamos que você está usando o Protheus Insights em ambiente de homologação e isto afeta a qualidade e atualização de novas recomendações."
		,Nil ,Nil, Nil, Nil, Nil, Nil, {STR0002 + CRLF + CRLF +	;					// "Sugerimos que leia a documentação e siga o passo a passo descrito para ter acesso a insights mais assertivos."
		I18N( STR0003, {"https://tdn.totvs.com/display/PROT/Protheus+Insights"} )})	// "Para informações acesse: #1"

	EndIf
Return

//------------------------------------------------------------------------------
/* {Protheus.doc} JsToAdvpl
    Função que recebera as chamadas JavaScript

    @type Function
    @author Squad PIF
	@params oWebChannel, object, Instância da classe TWebChannel
    @params cType, character, Tipo
    @params cContent, character, Conteúdo
    @return Nil
*/
//------------------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel As Object, cType As Character, cContent As Character )
	Local JContent  := JsonObject():New() As Json
	Local JResponse := JsonObject():New() As Json
	Local oTempTable                      As Object
	Local lRet                            As Logical
	Local cTempTable                      As Character

	Do Case
	Case cType == "playload"
	Case cType == "createTempTable"
		JContent:fromJson(cContent)
		lRet        := .F.
		cTempTable  := ""

		oTempTable  := PIFC010()
   		lRet        := oTempTable:lCREATED

		If lRet 
			__oTempTable := oTempTable
			cTempTable   := oTempTable:getRealName()
		EndIf

		JResponse["success"]   := lRet
		JResponse["tempTable"] := cTempTable

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	Case cType == "taxConfiguration"
		If !Empty(cContent)
			JContent:fromJson(cContent)
			lRet := AliasInDic("CJ2")

			IIF(!IsBlind() .And. lRet, FISA170(), lRet := .F.)

			JResponse["success"] := lRet

			oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
		EndIf
	EndCase

	FWFreeObj(JContent)
	FWFreeObj(JResponse)
Return
