#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "AGDA142.ch"

/*/{Protheus.doc} AGDA142
Rotina para registrar encerramento de conta de cooperado
@type function
@version 12
@author gilson.venturi
@since 07/07/2026
@return variant, nil
/*/
Function AGDA142()
	Local aArea      := GetArea()
	Local aAreaNF4   := NF4->(GetArea())
	Local oView      := FWLoadView("AGDA140")
	Local oModel	 := oView:GetModel()
	Local oModelNF4  := oModel:GetModel("AGDA140_NF4")
	Local oMDStruNF4 := oModelNF4:GetStruct()
	Local oVWStruNF4 := nil
	Local aCoors     := FWGetDialogSize(oMainWnd) //array com tamanho da window
	Local nX         := 0
	Local oFWMVCWin  := Nil
	Local aFieldsNF4 := {}
	Local aNoFldRemo := { "NF4_CODCOO","NF4_LOJCOO","NF4_MATCOO","NF4_TIPMOV","NF4_QTDCOT","NF4_VLRCAP","NF4_DTMOV","NF4_HRMOV","NF4_DATVCT","NF4_OBS"}

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:SetDescription( STR0001 )  //"Encerramento Cota Cooperado"

	//adiciona validação campos
	oMDStruNF4:SetProperty('NF4_QTDCOT', MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "POSITIVO()"))
	oMDStruNF4:SetProperty('NF4_VLRCAP', MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "POSITIVO()"))
	oMDStruNF4:SetProperty('NF4_TIPMOV', MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "POSICIONE('NF5', 1, FWxFilial('NF5') + FWFldGet('NF4_TIPMOV'), 'NF5->NF5_TIPO') == '6'")) //6=Encerramento

	//adiciona obrigatoriedade dos campos
	oMDStruNF4:SetProperty('NF4_OPTMOV', MODEL_FIELD_OBRIGAT, .T.)
	oMDStruNF4:SetProperty('NF4_CODCOO', MODEL_FIELD_OBRIGAT, .T.)
	oMDStruNF4:SetProperty('NF4_LOJCOO', MODEL_FIELD_OBRIGAT, .T.)
	oMDStruNF4:SetProperty('NF4_TIPMOV', MODEL_FIELD_OBRIGAT, .T.)
	oMDStruNF4:SetProperty('NF4_QTDCOT', MODEL_FIELD_OBRIGAT, .T.)
	oMDStruNF4:SetProperty('NF4_VLRCAP', MODEL_FIELD_OBRIGAT, .T.)
	oMDStruNF4:SetProperty('NF4_DTMOV' , MODEL_FIELD_OBRIGAT, .T.)
	oMDStruNF4:SetProperty('NF4_HRMOV' , MODEL_FIELD_OBRIGAT, .T.)

	If oModel:Activate()
		oModelNF4:SetValue("NF4_OPTMOV", "6") //#6=Encerramento Conta Cooperado
		oModelNF4:SetValue("NF4_CODCOO", NF3->NF3_CODCOO)
		oModelNF4:SetValue("NF4_LOJCOO", NF3->NF3_LOJCOO)
		oModelNF4:SetValue('NF4_QTDCOT', NF3->NF3_QTDCOT)
		oModelNF4:SetValue("NF4_VLRCAP", NF3->NF3_VALCOT)
		oModelNF4:SetValue("NF4_DTMOV" , dDatabase)
		oModelNF4:SetValue("NF4_HRMOV" , Time())
	EndIf

	if oModel:HasErrorMessage()
		FWAlertError(oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE])
		oModel:DeActivate()
		FreeObj(oModel)
		Return
	endIf

	oView:SetOperation(MODEL_OPERATION_INSERT)
	oView:SetCloseOnOk({|| .T.})

	oVWStruNF4 := oView:GetViewStruct("AGDA140_NF4") //carrega a estrutura da NF4

	//não permite alterar na View
	oVWStruNF4:SetProperty( "NF4_VLRCOT" , MVC_VIEW_CANCHANGE, .F. )
	oVWStruNF4:SetProperty( "NF4_CODCOO" , MVC_VIEW_CANCHANGE, .F. )
	oVWStruNF4:SetProperty( "NF4_LOJCOO" , MVC_VIEW_CANCHANGE, .F. )
	oVWStruNF4:SetProperty( "NF4_QTDCOT" , MVC_VIEW_CANCHANGE, .F. )
	oVWStruNF4:SetProperty( "NF4_VLRCAP" , MVC_VIEW_CANCHANGE, .F. )

	//remove campo - Não mostra na View
	aFieldsNF4 := aClone(oVWStruNF4:Getfields())
	For nX := 1 to Len( aFieldsNF4 )
		IF aScan(aNoFldRemo, aFieldsNF4[nX][1]) = 0 //Não encontra
			oVWStruNF4:RemoveField( aFieldsNF4[nX][1] ) //remove campo da view
		ENDIF
	Next nX
	FWFreeArray(aFieldsNF4)

	oFWMVCWin := FWMVCWindow():New()
	oFWMVCWin:SetUseControlBar(.T.)
	oFWMVCWin:SetView(oView)
	oFWMVCWin:SetCentered(.T.)
	oFWMVCWin:SetPos(aCoors[1],aCoors[2])
	oFWMVCWin:SetSize(aCoors[3],aCoors[4])
	oFWMVCWin:SetTitle(STR0002)  //"Incluir"
	oFWMVCWin:Activate()

	oView:DeActivate()
	FreeObj(oView)
	oFWMVCWin:DeActivate()
	FreeObj(oFWMVCWin)

	RestArea(aArea)
	RestArea(aAreaNF4)
Return Nil
