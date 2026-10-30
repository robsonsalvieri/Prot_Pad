#Include "agda130t.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"


#DEFINE NAMESPACEAGRO totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDA130T
Função para chamada da tela de Transferência de Cotas e Valores Cooperado
@type function
@version 12
@author ronery.filho
@since 19/08/2026
/*/
Function AGDA130T(cCodCoop, cLojCoop)
	Local oModel 	:= FwLoadModel('AGDA130T')
	Local oModelNF3 := oModel:GetModel("AGDA130T_NF3")
	
	oModel:SetOperation(MODEL_OPERATION_INSERT)

	If oModel:Activate()
		If !Empty(cCodCoop) .and. vldCoopOri(cCodCoop, cLojCoop)
			oModelNF3:SetValue('X_CODCOO', cCodCoop)
			oModelNF3:SetValue('X_LOJCOO', cLojCoop)
			oModelNF3:SetValue('X_BLOQUEADO', '1')
		EndIf

		FWExecView(oModel:GetDescription(), "AGDA130T", MODEL_OPERATION_INSERT, , {|| .T.}, {|| execTransfer(oModel) }, , , , , , oModel)

	Endif
	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)

Return

/*/{Protheus.doc} ModelDef
Model do AGDA130
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel      := Nil

	oModel := MpFormModel():New( "AGDA130T",,, {|oModel| .T. } )
	oModel:SetDescription(  STR0001 )  //"Conta de Cotas e Valores Cooperado" //"Transferência de Cotas e Valores Cooperado"

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA130T_NF3", , getFieldModel())
	oModel:GetModel( "AGDA130T_NF3" ):SetDescription(  STR0001 )  //"Conta de Cotas e Valores Cooperado" //"Transferência de Cotas e Valores Cooperado"
	oModel:SetPrimaryKey( { "NF3_FILIAL", "NF3_CODIGO" } )

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	 := FwLoadModel( "AGDA130T" )
	Local oView		 := FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NF3', getFieldView(), 'AGDA130T_NF3' )
	oView:CreateHorizontalBox( 'CABEC', 100 )
	oView:SetOwnerView( 'VIEW_NF3', 'CABEC' )
	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} execTransfer
Efetivação da Transferência
@type function
@version 12
@author jean.schulze
@since 7/8/2026
@param oModel, object, modelo de dados
@return variant, true/false
/*/
Static Function execTransfer(oModel)
	Local lRet := .T.
	Local oNF3 := oModel:GetModel("AGDA130T_NF3")
	Local oQuotaMovementService := NAMESPACEAGRO.QuotaMovementService():New()
	Local jComandTransferir := JsonObject():New()

	jComandTransferir["cooperadoOrigem"]  := oNF3:GetValue("X_CODCOO")
	jComandTransferir["lojaOrigem"]       := oNF3:GetValue("X_LOJCOO")
	jComandTransferir["qtdCotas"]         := oNF3:GetValue("X_QTDCOT")
	jComandTransferir["cooperadoDestino"] := oNF3:GetValue("X_DCODCO")
	jComandTransferir["lojaDestino"]      := oNF3:GetValue("X_DLOJCO")
	jComandTransferir["observacao"]       := oNF3:GetValue("X_OBS")
	jComandTransferir["tipoMovimento"]    := Posicione("NF5",1,xFilial("NF5") + oNF3:GetValue("X_TPOPER"),"NF5_TIPO")
	jComandTransferir["codigoMovimento"]  := oNF3:GetValue("X_TPOPER")

	oQuotaMovementService:transferirCotas(jComandTransferir)

	If !oQuotaMovementService:isSuccess()
		lRet := .F.
		FWAlertHelp(STR0002, oQuotaMovementService:getMessageError())
	EndIf
	
	FwFreeObj(oQuotaMovementService)
	FwFreeObj(jComandTransferir)

Return lRet

/*/{Protheus.doc} vldCoopOri
Validação de Cooperado
@type function
	@version 12
@author jean.schulze
@since 7/7/2026
@param cCoooperado, character, cooperado
@param cLoja, character, loja
@return variant, true/false
/*/
Static Function vldCoopOri(cCoooperado, cLoja)
	Local lRet    := .T.

	If !Empty(cCoooperado) .and. !Empty(cLoja) .and. POSICIONE("NF3",1,FWxFilial('NF3')+ cCoooperado + cLoja,"NF3_STATUS") <> "1"
		AGDHELP(STR0004, STR0003) //"Informe um cooperado ativo." //"Cooperado Inválido"
		lRet := .F.
	EndIf

Return lRet


/*/{Protheus.doc} vldCoopDes
Validação de Cooperado
@type function
@version 12
@author carlos.augusto
@since 17/07/2026
@param cCoooperado, character, cooperado
@param cLoja, character, loja
@return variant, true/false
/*/
Static Function vldCoopDes(cCoooperado, cLoja)
	Local lRet          := .T.
	Local lCooperadoOk  := .F.
	Local aArea         := GetArea()

	If !Empty(cCoooperado) .and. !Empty(cLoja)
		dbSelectArea("NEP")
		NEP->(dbSetOrder(1))

		lCooperadoOk := NEP->(DBSeek(FWxFilial("NEP") + cCoooperado + cLoja))
		If lCooperadoOk
			lCooperadoOk := NEP->NEP_COOPER == "1" .and. !Empty(NEP->NEP_MATRIC)
		EndIf

		If !lCooperadoOk
			lRet := .F.
			AGDHELP(STR0009, STR0003)//"Cooperado não cadastrado."
		EndIf
	EndIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} getFieldModel
Retorna a lista de campos do modelo
@type function
@version 12
@author jean.schulze
@since 7/8/2026
@return variant, lista de campos do modelo
/*/
Static Function getFieldModel()
	Local oStruct     := FWFormModelStruct():New()
	Local aFldCliente := FWSX3Util():GetFieldStruct("NF3_CODCOO")
	Local aFldLoja    := FWSX3Util():GetFieldStruct("NF3_LOJCOO")
	Local aFldNome    := FWSX3Util():GetFieldStruct("NF3_NOMCOO")
	Local aFldTipo    := FWSX3Util():GetFieldStruct("NF3_TPOPER")
	Local aFldCota    := FWSX3Util():GetFieldStruct("NF3_QTDCOT")
	Local aFldValor   := FWSX3Util():GetFieldStruct("NF3_VALCOT")

	/*Campos customizados da tela*/
	oStruct:AddField(RetTitle("NF3_CODCOO") , RetTitle("NF3_CODCOO") , "X_CODCOO", "C", aFldCliente[3],, {|oModel| vldCoopOri(oModel:GetValue("X_CODCOO"), oModel:GetValue("X_LOJCOO"))}, {|oModel| empty(oModel:GetValue("X_BLOQUEADO"))} , , .t.)
	oStruct:AddField(RetTitle("NF3_LOJCOO") , RetTitle("NF3_LOJCOO") , "X_LOJCOO", "C", aFldLoja[3]   ,, {|oModel| vldCoopOri(oModel:GetValue("X_CODCOO"), oModel:GetValue("X_LOJCOO"))}, {|oModel| empty(oModel:GetValue("X_BLOQUEADO"))} , , .t.)
	oStruct:AddField(RetTitle("NF3_NOMCOO") , RetTitle("NF3_NOMCOO") , "X_NOME"  , "C", aFldNome[3])
	oStruct:AddField(RetTitle("NF3_TPOPER") , RetTitle("NF3_TPOPER") , "X_TPOPER", "C", aFldTipo[3],, FWBuildFeature(STRUCT_FEATURE_VALID, "POSICIONE('NF5', 1, FWxFilial('NF5') + FWFldGet('X_TPOPER'), 'NF5->NF5_TIPO') $ '4|5'"), , , .t.)
	oStruct:AddField(RetTitle("NF3_QTDCOT") , RetTitle("NF3_QTDCOT") , "X_QTDCOT", "N", aFldCota[3],, , , , .t.)
	oStruct:AddField(RetTitle("NF3_VALCOT") , RetTitle("NF3_VALCOT") , "X_VALCOT", "N", aFldValor[3])
	oStruct:AddField(RetTitle("NF3_OBS")    , RetTitle("NF3_OBS")    , "X_OBS"  , "M", 200)

	oStruct:AddField(RetTitle("NF3_CODCOO") + STR0005, RetTitle("NF3_CODCOO") + STR0005, "X_DCODCO", "C", aFldCliente[3],, {|oModel| vldCoopDes(oModel:GetValue("X_DCODCO"), oModel:GetValue("X_DLOJCO"))}, , , .t.) //STR0005 //" Destino"
	oStruct:AddField(RetTitle("NF3_LOJCOO") + STR0005, RetTitle("NF3_LOJCOO") + STR0005, "X_DLOJCO", "C", aFldLoja[3]   ,, {|oModel| vldCoopDes(oModel:GetValue("X_DCODCO"), oModel:GetValue("X_DLOJCO"))}, , , .t.) //STR0005 //" Destino"
	oStruct:AddField(RetTitle("NF3_NOMCOO") + STR0005, RetTitle("NF3_NOMCOO") + STR0005, "X_DNOME"  , "C", aFldNome[3]) //STR0005 //" Destino"
	
	oStruct:AddTrigger("X_LOJCOO", "X_NOME"  , , { |oModel|POSICIONE("SA1",1,FWxFilial('SA1')+oModel:GetValue("X_CODCOO")+oModel:GetValue("X_LOJCOO"),"A1_NOME")})
	oStruct:AddTrigger("X_LOJCOO", "X_QTDCOT", , { |oModel|POSICIONE("NF3",1,FWxFilial('NF3')+oModel:GetValue("X_CODCOO")+oModel:GetValue("X_LOJCOO"),"NF3_QTDCOT")})
	oStruct:AddTrigger("X_DLOJCO", "X_DNOME" , , { |oModel|POSICIONE("SA1",1,FWxFilial('SA1')+oModel:GetValue("X_DCODCO")+oModel:GetValue("X_DLOJCO"),"A1_NOME")})
	oStruct:AddTrigger("X_QTDCOT", "X_VALCOT", , { |oModel| oModel:GetValue("X_QTDCOT") * SUPERGETMV("MV_AGD0011", .F., 1) })

	oStruct:AddField("X_BLOQUEADO", "X_BLOQUEADO", "X_BLOQUEADO"  , "C", 1)

return oStruct

/*/{Protheus.doc} getFieldView
Retorna a lista de campos da View
@type function
@version 12
@author jean.schulze
@since 7/8/2026
@return variant, lista de campos da View
/*/
Static Function getFieldView()
	Local oStruct     := FWFormViewStruct():New()
	Local aFldCliente := FWSX3Util():GetFieldStruct("NF3_CODCOO")
	Local aFldLoja    := FWSX3Util():GetFieldStruct("NF3_LOJCOO")
	Local aFldNome    := FWSX3Util():GetFieldStruct("NF3_NOMCOO")
	Local aFldTipo    := FWSX3Util():GetFieldStruct("NF3_TPOPER")
	Local aFldCota    := FWSX3Util():GetFieldStruct("NF3_QTDCOT")
	Local aFldValor   := FWSX3Util():GetFieldStruct("NF3_VALCOT")

	oStruct:AddGroup("ORIG" , STR0006, "", 1) //"Cooperado de Origem"
	oStruct:AddGroup("COTA" , STR0007, "", 1) //"Cotas a Transferir"
	oStruct:AddGroup("DEST" , STR0008, "", 1) //"Cooperado Beneficiário"

	oStruct:AddField("X_CODCOO","01",RetTitle("NF3_CODCOO") , RetTitle("NF3_CODCOO") ,, "C", aFldCliente[5],, "NEPNF3",,,"ORIG")
	oStruct:AddField("X_LOJCOO","02",RetTitle("NF3_LOJCOO") , RetTitle("NF3_LOJCOO") ,, "C", aFldLoja[5],,"",,,"ORIG")
	oStruct:AddField("X_NOME"  ,"03",RetTitle("NF3_NOMCOO") , RetTitle("NF3_NOMCOO") ,, "C", aFldNome[5],,"",.f.,,"ORIG")
	
	oStruct:AddField("X_TPOPER","04",RetTitle("NF3_TPOPER") , RetTitle("NF3_TPOPER") ,, "C", aFldTipo[5],,"NF5TRA",,,"COTA")
	oStruct:AddField("X_QTDCOT","05",RetTitle("NF3_QTDCOT") , RetTitle("NF3_QTDCOT") ,, "N", aFldCota[5],,"",,,"COTA")
	oStruct:AddField("X_VALCOT","06",RetTitle("NF3_VALCOT") , RetTitle("NF3_VALCOT") ,, "N", aFldValor[5],,"",.f.,,"COTA")

	oStruct:AddField("X_DCODCO", "07", RetTitle("NF3_CODCOO") + STR0005, RetTitle("NF3_CODCOO") + STR0005, ,"C", aFldCliente[5],, "NEPNF3",,,"DEST") //STR0005 //" Destino"
	oStruct:AddField("X_DLOJCO", "08", RetTitle("NF3_LOJCOO") + STR0005, RetTitle("NF3_LOJCOO") + STR0005, ,"C", aFldLoja[5],,"",,,"DEST") //STR0005 //" Destino"
	oStruct:AddField("X_DNOME" , "09", RetTitle("NF3_NOMCOO") + STR0005, RetTitle("NF3_NOMCOO") + STR0005, ,"C", aFldNome[5],,"",.f.,,"DEST") //STR0005 //" Destino"

	oStruct:AddField("X_OBS"  , "10", RetTitle("NF3_OBS")    , RetTitle("NF3_OBS") ,, "M",,,"",,,"DEST")

return oStruct
