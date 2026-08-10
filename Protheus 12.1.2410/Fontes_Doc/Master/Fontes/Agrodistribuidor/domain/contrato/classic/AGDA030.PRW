#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA030.CH"
#DEFINE CONTRATO_ACL_SERVICE agd.contratoAclService.agdContratoAclService
#DEFINE CONTRATO_ACL_VINCULAR_SERVICE agd.ContratoAclVincularService.agdContratoAclVincularService
/*/{Protheus.doc} AGDA030
Browser da ACL de Contratos Barter
@type function
@version 12
@author jean.schulze
@since 07/01/2025
@return variant, nil
/*/
Function AGDA030(pcFiltro)
	Local oMBrowse := Nil

	If .Not. TableInDic('NEF')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NEF" )
	oMBrowse:SetDescription( STR0001  )  //'Contratos de Compra da Negociacao'
	oMBrowse:DisableDetails()
	oMBrowse:lBrwFilOn := .F.

	if !Empty(pcFiltro)
		oMBrowse:SetFilterDefault(pcFiltro)
	Endif

	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu
@type function
@version 12
@author jean.schulze
@since 07/01/2025
@return variant, nil
/*/
Static Function MenuDef()
	Local aRotina := {}

	/**************************************************************************************
    Nao Mudar a Ordem do Menu -	Impacto no Cockpit Barter - Permissão de acesso das rotinas
	***************************************************************************************/	
	
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA030' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0003 Action 'AGD030MVCT(NEF->NEF_IDCTR)' OPERATION 2 ACCESS 0 //#"Visualizar Movto Contratos"
	ADD OPTION aRotina Title STR0006 Action 'AGDA010MCT' OPERATION 3 ACCESS 0 //"Gerar Contrato"
	ADD OPTION aRotina Title STR0007 Action 'AGDA030VCC' OPERATION 3 ACCESS 0 //"Vincular Contrato"
	ADD OPTION aRotina Title STR0008 Action 'AGDA030DVC(NEF->NEF_IDCTR, NEF->NEF_CODBRT, NEF->NEF_ITECTR)' OPERATION 5 ACCESS 0 //"Desvincular Contrato"

Return aRotina

/*/{Protheus.doc} ModelDef
Model da ACL de Contratos de Negócios Barter
@type function
@version 12
@author jean.schulze
@since 07/01/2025
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNEF  := FwFormStruct( 1, "NEF" )

	oModel := MpFormModel():New( "AGDA030" )
	oModel:SetDescription(  STR0001 )

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA030_NEF", , oStruNEF)
	oModel:GetModel( "AGDA030_NEF" ):SetDescription(  STR0001 )
	oModel:SetPrimaryKey( { "NEF_FILIAL", "NEF_CODBRT", "NEF_ITECTR", "NEF_ITEM" } )

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author jean.schulze
@since 07/01/2025
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA030" )
	Local oStruNEE  := FwFormStruct( 2, "NEF" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NEF', oStruNEE, 'AGDA030_NEF' )

	oView:CreateHorizontalBox( 'CABEC', 100 )

	oView:SetOwnerView( 'VIEW_NEF', 'CABEC' )

	oView:EnableTitleView("VIEW_NEF")

	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} AGDA030SUM
Funcao de Dicionário para retornar a quantidade total de Contratos Gerados
@type function
@version 12
@author jean.schulze
@since 27/01/2025
@param cCodNegoc, character, Codigo Negocio Barter
@param cItem, character, Item Local Contrato Barter
@return variant, Quantidade Total
/*/
function AGDA030SUM(cCodNegoc, cItem)
	Local nTotal := 0

	oService:= CONTRATO_ACL_SERVICE():New(cCodNegoc)
	nTotal := oService:sumQuantidadeByItemContrato(cItem)

	FreeObj(oService)
return nTotal

/*/{Protheus.doc} AGD030MVCT
Chamada de Menu para Abrir Listagem dos Movimentos do Contratos do Negócio
@type function
@version 12
@author Gilson.Venturi
@since 28/01/2025
@return variant, nil
/*/
Function AGD030MVCT(cIDCtr)
	SetFunName("AGDA031")
	AGDA031("NEI->NEI_IDCTR == '"+ cIDCtr +"'" )
	SetFunName("AGDA030")
return nil

/*/{Protheus.doc} AGDA030VCC
Função de Menu para chamar o tela de vincular contrato
@type function
@version P12 
@author claudineia.reinert
@since 06/05/2025
/*/
Function AGDA030VCC()

	if SUPERGETMV("MV_AGDCTOG", .f., .f.) .and. SUPERGETMV("MV_SIGAAGR", .f., .f.) .and. SUPERGETMV("MV_AGRORI", .f., .f.)
		SetFunName("AGDA032")
		AGDA032()
		SetFunName("AGDA030")
	else
		AGDHELP(STR0004, STR0005) //"Ajuda" //"Não há parametrização de integração para vincular contrato."
	EndIf
return nil

/*/{Protheus.doc} AGDA030DVC
Função de Menu para desvincular contrato vinculados
@type function
@version P12 
@author claudineia.reinert
@since 19/05/2025
/*/
Function AGDA030DVC(cIDCtr, cCodBrt, cItemCtr)
	Local oService:= CONTRATO_ACL_VINCULAR_SERVICE():New(FWxFilial("NEF")+cIDCtr+cCodBrt+cItemCtr)

	oService:desvincularContrato()
	If !oService:isSuccess()
		AGDHELP(STR0004, oService:getMessageError())
	EndIf

	FreeObj(oService)
return nil
