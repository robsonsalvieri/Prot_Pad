#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSA535.CH"

#DEFINE WMSA53501 "WMSA53501"

Static aCposSB8 := {}
//--------------------------------------------------
/*/{Protheus.doc} WMSA535
Rotina para troca de validade dos lotes

@author  Guilherme A. Metzger
@since   26/03/2015
@version 1.0
/*/
//--------------------------------------------------
Function WMSA535()
Local oBrowse  := Nil
Local aColsSB8 := {}
Local aColsSX3 := {}

	Pergunte("WMSA535",.F.)

	// Define os campos que deverão aparecer no browse
	aAdd(aColsSB8,{buscarSX3("B8_PRODUTO",,aColsSX3),{|| SB8->B8_PRODUTO},"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})
	aAdd(aColsSB8,{buscarSX3("B8_LOCAL"  ,,aColsSX3),{|| SB8->B8_LOCAL  },"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})
	aAdd(aColsSB8,{buscarSX3("B8_DTVALID",,aColsSX3),{|| SB8->B8_DTVALID},"D",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})
	aAdd(aColsSB8,{buscarSX3("B8_DFABRIC",,aColsSX3),{|| SB8->B8_DFABRIC},"D",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})
	aAdd(aColsSB8,{buscarSX3("B8_LOTECTL",,aColsSX3),{|| SB8->B8_LOTECTL},"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})
	aAdd(aColsSB8,{buscarSX3("B8_NUMLOTE",,aColsSX3),{|| SB8->B8_NUMLOTE},"C",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})
	aAdd(aColsSB8,{buscarSX3("B8_QTDORI" ,,aColsSX3),{|| SB8->B8_QTDORI },"N",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})
	aAdd(aColsSB8,{buscarSX3("B8_SALDO"  ,,aColsSX3),{|| SB8->B8_SALDO  },"N",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})
	aAdd(aColsSB8,{buscarSX3("B8_EMPENHO",,aColsSX3),{|| SB8->B8_EMPENHO},"N",aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1})

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SB8")
	oBrowse:SetFields(aColsSB8)
	oBrowse:SetOnlyFields({""})
	oBrowse:SetFilterDefault("@ "+RetFiltSB8())
	oBrowse:SetMenuDef("WMSA535")
	oBrowse:SetDescription(STR0001) // "Troca Data de Validade"
	oBrowse:SetParam({|| Pergunte("WMSA535",.T.)}) // Tecla F12
	oBrowse:SetAmbiente(.F.) // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.) // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()

Return Nil

Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.WMSA535" OPERATION 4 ACCESS 0 // Alterar

Return aRotina

Static Function ModelDef()
Local oModel    := MPFormModel():New("WMSA535")
Local oStruSB8  := Nil
Local bValid    := FWBuildFeature( STRUCT_FEATURE_VALID, "WMS535VFld(A,B,C)")
Local oWmsEvent := WMSModelEventWMSA535():New() // Evento de validação e commit customizados

	// Define os campos que deverão ser apresentados em tela
	aCposSB8 := {}
	aAdd(aCposSB8,"B8_PRODUTO")
	aAdd(aCposSB8,"B8_LOTECTL")
	aAdd(aCposSB8,"B8_NUMLOTE")
	aAdd(aCposSB8,"B8_DTVALID")
	aAdd(aCposSB8,"B8_DFABRIC")
	aAdd(aCposSB8,"B8_LOCAL"  )
	aAdd(aCposSB8,"B8_QTDORI" )
	aAdd(aCposSB8,"B8_SALDO"  )
	aAdd(aCposSB8,"B8_EMPENHO")

	oStruSB8 := FWFormStruct(1,"SB8",{ |cCampo| AllTrim(cCampo) == "B8_FILIAL" .Or. aScan(aCposSB8 , AllTrim( cCampo ) ) > 0 })

	// Atribui a função de validação específica para o campo Data de Validade
	oStruSB8:SetProperty("B8_DTVALID",MODEL_FIELD_VALID,bValid)

	// Retira a obrigatoriedade de todos os campos, menos o Data de Validade já que é o único que deverá ser preenchido pelo usuário
	oStruSB8:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oStruSB8:SetProperty("B8_DTVALID",MODEL_FIELD_OBRIGAT,.T.)
	oStruSB8:SetProperty("B8_DFABRIC",MODEL_FIELD_OBRIGAT,.T.)

	oModel:AddFields("MdFieldSB8", /*cOwner*/, oStruSB8)

	oModel:InstallEvent("WMSW535", /*cOwner*/, oWmsEvent)

Return oModel

Static Function ViewDef()
Local oModel   := FWLoadModel("WMSA535")
Local oView    := FWFormView():New()
Local oStruSB8 := FWFormStruct(2,"SB8",{ |cCampo| AllTrim(cCampo) == "B8_FILIAL" .Or. aScan(aCposSB8 , AllTrim( cCampo ) ) > 0  })

	// Desabilita a edição de todos os campos, menos o Data de Validade já que é o único que deverá ser preenchido pelo usuário
	oStruSB8:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
	oStruSB8:SetProperty("B8_DTVALID",MVC_VIEW_CANCHANGE,.T.)
	oStruSB8:SetProperty("B8_DFABRIC",MVC_VIEW_CANCHANGE,.T.)

	oView:SetModel(oModel)
	oView:AddField("VwGridSB8",oStruSB8,"MdFieldSB8")

Return oView

Function WMS535VFld(oModel,cField,xValue)
	If cField == "B8_DTVALID"
		If dDataBase > oModel:GetValue("B8_DTVALID")
			oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,,,WMSA53501,STR0002,STR0003) // "A Data de Validade informada é inválida." // "Informe uma Data de Validade posterior à Data Base."
		EndIf
	EndIf
Return .T.

Static Function RetFiltSB8()
Local cFiltro     := ""
Local cDadosProd:= SuperGetMV("MV_ARQPROD",.F.,"SB1")

	dbSelectArea("SBZ")
	cFiltro +=     " B8_SALDO > 0"
	If cDadosProd == 'SBZ'
		cFiltro += " AND (EXISTS (SELECT 1"
		cFiltro +=                " FROM "+RetSqlName("SBZ")+" SBZ"
		cFiltro +=               " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'"
		cFiltro +=                 " AND SBZ.BZ_COD     = B8_PRODUTO"
		cFiltro +=                 " AND SBZ.BZ_LOCALIZ IN (' ','S')"
		cFiltro +=                 " AND SBZ.BZ_CTRWMS  IN (' ','1')"
		cFiltro +=                 " AND SBZ.D_E_L_E_T_ = ' ')"
		cFiltro +=      " OR ( NOT EXISTS (SELECT 1"
		cFiltro +=                         " FROM "+RetSqlName("SBZ")+" SBZ"
		cFiltro +=                        " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'"
		cFiltro +=                          " AND SBZ.BZ_COD     = B8_PRODUTO"
		cFiltro +=                          " AND SBZ.BZ_LOCALIZ IN (' ','S')"
		cFiltro +=                          " AND SBZ.BZ_CTRWMS  IN (' ','1')"
		cFiltro +=                          " AND SBZ.D_E_L_E_T_ = ' ')"
	EndIf
	cFiltro +=           " AND EXISTS (SELECT 1"
	cFiltro +=                         " FROM "+RetSqlName("SB5")+" SB5"
	cFiltro +=                        " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cFiltro +=                           " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cFiltro +=                          " AND SB1.B1_COD = SB5.B5_COD"
	cFiltro +=                          " AND SB1.B1_LOCALIZ = 'S'"
	cFiltro +=                          " AND SB1.D_E_L_E_T_ = ' '"
	cFiltro +=                        " WHERE SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
	cFiltro +=                          " AND SB5.B5_COD = B8_PRODUTO"
	cFiltro +=                          " AND SB5.B5_CTRWMS = '1'"
	cFiltro +=                          " AND SB5.D_E_L_E_T_ = ' ')"
	If cDadosProd == 'SBZ'
		cFiltro +="))"
	EndIf
Return cFiltro
