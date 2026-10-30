#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "AGDA143.ch"

/*/{Protheus.doc} AGDA143
Rotina para reativar conta de cooperado
@type function
@version 12
@author carlos.augusto
@since 16/07/2026
@return variant, nil
/*/
Function AGDA143()
	Local aArea      := GetArea()
	Local aAreaNF4   := NF4->(GetArea())
	Local oModel	 := FwLoadModel( "AGDA140" )
	Local oMDStruNF4 := nil
	Local oVWStruNF4 := nil
	Local oView      := nil
	Local aCoors     := FWGetDialogSize(oMainWnd) 
	Local nX 		 := 0
	Local nY 		 := 0
	Local aFieldsNF4 := {}
	Local aCpoTela   := { "NF4_CODCOO","NF4_LOJCOO","NF4_MATCOO","NF4_TIPMOV","NF4_QTDCOT","NF4_VLRCOT","NF4_VLRCAP","NF4_DTMOV","NF4_HRMOV","NF4_OBS"}

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:SetDescription( STR0001 )  //"Reativar Conta"

	//adiciona validação campos
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty('NF4_TIPMOV', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "AGD143VTPM()"))
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty('NF4_QTDCOT', MODEL_FIELD_VALID,{| oField | fGatValCPO( oField, "NF4_QTDCOT" ) })
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty('NF4_VLRCAP', MODEL_FIELD_VALID,{| oField | fGatValCPO( oField, "NF4_VLRCAP" ) })
	
	//adiciona obrigatoriedade dos campos
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty( 'NF4_CODCOO', MODEL_FIELD_OBRIGAT, .T. )
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty( 'NF4_LOJCOO', MODEL_FIELD_OBRIGAT, .T. )
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty( 'NF4_OPTMOV', MODEL_FIELD_OBRIGAT, .T. )
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty( 'NF4_TIPMOV', MODEL_FIELD_OBRIGAT, .T. )
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty( 'NF4_VLRCAP', MODEL_FIELD_OBRIGAT, .T. )
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty( 'NF4_DTMOV' , MODEL_FIELD_OBRIGAT, .T. )
	oModel:GetModel("AGDA140_NF4"):GetStruct():SetProperty( 'NF4_HRMOV' , MODEL_FIELD_OBRIGAT, .T. )

	oModel:Activate()
	oMDStruNF4 := oModel:GetModel("AGDA140_NF4")
	//seta valores default para o reativar conta
	oMDStruNF4:SetValue("NF4_FILIAL", NF3->NF3_FILIAL)
	oMDStruNF4:SetValue("NF4_CODCOO", NF3->NF3_CODCOO)
	oMDStruNF4:SetValue("NF4_LOJCOO", NF3->NF3_LOJCOO)
	oMDStruNF4:SetValue("NF4_VLRCOT", SuperGetMV( "MV_AGD0011",.F., 0 ))
	oMDStruNF4:SetValue('NF4_QTDCOT', 0)
	oMDStruNF4:SetValue('NF4_VLRCAP', 0)
	oMDStruNF4:SetValue("NF4_DTMOV" , dDatabase)
	oMDStruNF4:SetValue("NF4_HRMOV" , Time())
	oMDStruNF4:SetValue("NF4_OPTMOV", "3") 

	oView := FWLoadView("AGDA140")
	oView:SetModel(oModel)
	oView:SetOperation(MODEL_OPERATION_INSERT)
	oVWStruNF4 := oView:GetViewStruct("AGDA140_NF4") //carrega a estrutura da NF4
	
	oVWStruNF4:SetProperty( "NF4_CODCOO" , MVC_VIEW_CANCHANGE, .F. )
	oVWStruNF4:SetProperty( "NF4_LOJCOO" , MVC_VIEW_CANCHANGE, .F. )
	oVWStruNF4:SetProperty( "NF4_VLRCOT" , MVC_VIEW_CANCHANGE, .F. )
	oVWStruNF4:SetProperty( "NF4_TIPMOV" , MVC_VIEW_LOOKUP, "NF5NF3")

	//remove campo - Não mostra na View
	aFieldsNF4 := aClone(oVWStruNF4:Getfields())
	For nX := 1 to Len( aFieldsNF4 )
		IF (nY := aScan(aCpoTela,{|x| x == aFieldsNF4[nX][1]})) == 0 //Não encontra
			oVWStruNF4:RemoveField( aFieldsNF4[nX][1] ) //remove campo da view
		ENDIF
	Next nX

	oFWMVCWin := FWMVCWindow():New()
	oFWMVCWin:SetUseControlBar(.T.)
	oFWMVCWin:SetView(oView)
	oFWMVCWin:SetCentered(.T.)
	oFWMVCWin:SetPos(aCoors[1],aCoors[2])
	oFWMVCWin:SetSize(aCoors[3],aCoors[4])
	oFWMVCWin:Activate()

	oView:DeActivate()
	FreeObj(oView)
	oFWMVCWin:DeActivate()
	FreeObj(oFWMVCWin)

	RestArea(aArea)
	RestArea(aAreaNF4)
Return Nil


/*/{Protheus.doc} fGatValCPO
Calcula de/para cotas e valor do capital social
@type function
@version 12
@author claudineia.reinert
@since 15/07/2026
@return Logical, .T. se o campo for válido, .F. caso contrário
/*/
Static Function fGatValCPO( oField, cFieldName )

	If cFieldName == "NF4_QTDCOT"
		If oField:GetValue("NF4_QTDCOT") <= 0
			return .F.
		EndIf
		oField:LoadValue("NF4_VLRCAP", (oField:GetValue("NF4_QTDCOT") * oField:GetValue("NF4_VLRCOT")) )
		oField:LoadValue("NF4_VALBRT", (oField:GetValue("NF4_QTDCOT") * oField:GetValue("NF4_VLRCOT")) )
	EndIf
	If cFieldName == "NF4_VLRCAP"
		If oField:GetValue("NF4_VLRCAP") <= 0
			return .F.
		EndIf
		oField:LoadValue("NF4_QTDCOT", Int(oField:GetValue("NF4_VLRCAP") / oField:GetValue("NF4_VLRCOT")) )
		oField:LoadValue("NF4_VALBRT", (oField:GetValue("NF4_QTDCOT") * oField:GetValue("NF4_VLRCOT")) )
	EndIf

Return .T.


/*/{Protheus.doc} AGD130VTPM
Validação para o campo NF3_TPOPER via dicionario(SX3) 
@type function
@version 12
@author claudineia.reinert
@since 15/07/2026
@return Logical, .T. se o campo for válido, .F. caso contrário
/*/
Function AGD143VTPM()
	If !Empty(M->NF4_TIPMOV)
		dbSelectArea("NF5")
		NF5->(dbSetOrder(1)) //NF5_FILIAL+NF5_CODIGO
		If NF5->(dbSeek(xFilial("NF5")+M->NF4_TIPMOV))
				//return .T.
			If !(NF5->NF5_TIPO $ "23")
				AGDHELP( STR0002 , STR0002, STR0003 + AllTrim(X3CboxDesc( "NF5_TIPO", "2" )) + '/' + AllTrim(X3CboxDesc( "NF5_TIPO", "3" ))) //"Tipo de movimentação inválido para reativar conta de cooperado.""Informe uma movimentação do tipo "
				Return .F.
			Endif
		Else
			Return .F. //código informado não existe na NF5
		EndIf
	EndIf
Return .T.
