#Include "protheus.ch"
#Include "fwmvcdef.ch"
#INCLUDE "AGDP070.CH"

/*/{Protheus.doc} AGDP070
Cadastro de Grupo Familiar
@type function
@version 12
@author carlos.augusto
@see (https://jiraproducao.totvs.com.br/browse/DAGRODIST-1885)
@since 10/10/2025
/*/
Function AGDP070()
	Local oBrowse

    If (.Not. TableInDic('NEV')) .Or. (.Not. TableInDic('NEX'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

	oBrowse	:= FWMBrowse():New()
	oBrowse:SetAlias("NEV")
	oBrowse:SetDescription(STR0001) //"Grupo Familiar"
	oBrowse:DisableDetails()	
	oBrowse:Activate()
	
Return


/*/{Protheus.doc} MenuDef
MenuDef da Rotina
@author carlos.augusto
@since 10/10/2025
/*/
Static Function MenuDef()
    Local aRotina := {}
    Local cAction := "VIEWDEF.AGDP070"

    ADD OPTION aRotina TITLE STR0002 ACTION cAction OPERATION 2 ACCESS 0  //"Visualizar"
    ADD OPTION aRotina TITLE STR0003 ACTION cAction OPERATION 3 ACCESS 0  //"Incluir"
    ADD OPTION aRotina TITLE STR0004 ACTION cAction OPERATION 4 ACCESS 0  //"Alterar"
    ADD OPTION aRotina TITLE STR0005 ACTION cAction OPERATION 5 ACCESS 0  //"Excluir"

Return aRotina


/*/{Protheus.doc} ModelDef
ModelDef da Rotina
@author carlos.augusto
@since 10/10/2025
/*/
Static Function ModelDef()
	Local oModel 	 := Nil
	Local oStruNEV   := FWFormStruct( 1, 'NEV' )
	Local oStruNEX   := FWFormStruct( 1, 'NEX' ) 
	Local oEvent     := AGDP070EVT():New()

    //Cria o modelo 	
	oModel := MPFormModel():New( 'AGDP070')
	oModel:SetDescription( STR0001 ) //"Grupo Familiar"

	// Adiciona a estrutura da Field
	oModel:AddFields( 'MdFieldNEV', /*cOwner*/, oStruNEV )
	
	// Adiciona a estrutura da Grid
	oModel:AddGrid( "MdFieldNEX", "MdFieldNEV", oStruNEX)
	oModel:GetModel("MdFieldNEX"):SetUniqueLine({'NEX_CODCLI', 'NEX_LOJCLI'})

	// Seta relacionamento
	oModel:SetRelation( 'MdFieldNEX', {{'NEX_FILIAL', 'fwxFilial("NEX")'}, {'NEX_CODGRP', 'NEV_CODIGO'}}, NEX->(IndexKey( 1 ) ) )
	
	oModel:SetPrimaryKey({"NEV_FILIAL", "NEV_CODIGO"})


	oModel:InstallEvent("AGDP070EVT", /*cOwner*/, oEvent)

Return oModel
                                                                                                         

/*/{Protheus.doc} ViewDef
ViewDef da Rotina
@author carlos.augusto
@since 10/10/2025
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel 	:= FWLoadModel('AGDP070')
	Local oStruNEV	:= FWFormStruct(2,'NEV')
	Local oStruNEX	:= FWFormStruct(2,'NEX')

	//Instância modelo de visualização
	oView := FwFormView():New()

	//Seta o modelo de dados
	oView:SetModel( oModel )
	oView:SetDescription( STR0001 ) //"Grupo Familiar"

	//Adiciona os campos na estrutura do modelo de dados
	oView:AddField("VIEW_NEV", oStruNEV, "MdFieldNEV")

	//Adiciona ao view um formulário do tipo FWFormGrid
	oView:AddGrid( "VIEW_NEX", oStruNEX, "MdFieldNEX" )

	oView:AddIncrementField("VIEW_NEX", "NEX_ITEM")

	//Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "SUPERIOR", 15)
	oView:CreateHorizontalBox( "INFERIOR", 85)

	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( "VIEW_NEV", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NEX", "INFERIOR" )

Return oView


/*/{Protheus.doc} AGDP070CRM
Abre a tela de Grupo Familiar acionado pelo menu CRMA980 e Dados Agronegocio
@author carlos.augusto
@since 10/10/2025
/*/
Function AGDP070CRM(cCodCli,cCodLoja)
	Local aAreaSA1  := SA1->(GetArea())
	Local aArea     := GetArea()
	Local oModel    := nil
	Local oView     := FwViewActive()

    If (.Not. TableInDic('NEV')) .Or. (.Not. TableInDic('NEX'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif
	//Se acionadas pelo CRMA980, gerar tabelas NEV e NEX
	DbSelectArea("NEV")
	DbSelectArea("NEX")

    oModel := FwLoadModel('AGDP070')

    NEX->(DbSetOrder(2))
    If NEX->(DBSeek(FWxFilial("NEX")+cCodCli+cCodLoja))
		NEV->(DbSetOrder(1))
		If NEV->(DBSeek(FWxFilial("NEV")+NEX->NEX_CODGRP))
        	FWExecView(oModel:GetDescription(), "AGDP070", MODEL_OPERATION_UPDATE)
		EndIf
    Else
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        If oModel:Activate()
            FWExecView(oModel:GetDescription(), "AGDP070", MODEL_OPERATION_INSERT, , , ,0, , , , , oModel)
			oModel:DeActivate()
        Endif

		NEX->(DbSetOrder(2))
		If NEX->(DBSeek(FWxFilial("NEX")+cCodCli+cCodLoja))
			If valType(oView) == 'O' .AND. oView:GetModel():GetId() == "AGDP060"
				oView:GetModel():GetModel("AGDP060_NEP"):LoadValue('NEP_GRPFAM', NEX->NEX_CODGRP)
				oView:Refresh("VIEW_NEP")
			EndIf
		EndIf
    Endif

	FreeObj(oModel)
	RestArea(aArea)
	RestArea(aAreaSA1)

Return .T.

