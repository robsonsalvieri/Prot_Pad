#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "agda050.ch"

#DEFINE VENDA_PERDIDA_REPOSITORY agd.vendaPerdidaRepository.agdVendaPerdidaRepository
#DEFINE NEGOCIO_INSUMO_SERVICE  agd.negocioInsumoService.agdNegocioInsumoService
#DEFINE NEGOCIO_SERVICE  agd.negocioService.agdNegocioService
/*/{Protheus.doc} AGDA050
Browser da ACL de Contratos Barter
@type function
@version 12
@author jean.schulze
@since 07/01/2025
@return variant, nil
/*/
Function AGDA050(pcFiltro)
	Local oMBrowse := Nil

	If .Not. TableInDic('NEL')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NEL" )
	oMBrowse:SetDescription( STR0001  )  //'Contratos de Compra da Negociacao' //"Vendas Perdidas da Negociação"

	if !Empty(pcFiltro)
		oMBrowse:SetFilterDefault(pcFiltro)
	Endif

	oMBrowse:DisableDetails()

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

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA050' OPERATION 2 ACCESS 0  //"Visualizar"

Return aRotina

/*/{Protheus.doc} ModelDef
Model da Venda Perdida
@type function
@version 12
@author jean.schulze
@since 07/01/2025
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNEL  := FwFormStruct( 1, "NEL" )

	oModel := MpFormModel():New( "AGDA050" )
	oModel:SetDescription(  STR0003 )  //"Venda Perdida"

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA050_NEL", , oStruNEL)
	oModel:GetModel( "AGDA050_NEL" ):SetDescription(  STR0003 )  //"Venda Perdida"
	oModel:SetPrimaryKey( { "NEL_FILIAL", "NEL_CODBRT", "NEL_ITEBRT", "NEL_ITEM" } )

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
	Local oModel	:= FwLoadModel( "AGDA050" )
	Local oStruNEL  := FwFormStruct( 2, "NEL" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NEL', oStruNEL, 'AGDA050_NEL' )

	oView:CreateHorizontalBox( 'CABEC', 100 )

	oView:SetOwnerView( 'VIEW_NEL', 'CABEC' )

	oView:EnableTitleView("VIEW_NEL")

	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} AGDA050SEQ
Retorna Ultima Sequencia
@type function
@version 12
@author jean.schulze
@since 03/02/2025
@return character, sequencia
/*/
function AGDA050SEQ(pcFilial, pcCodBrt, pcInsumo)
	Local cSeq := STRZERO(0,TAMSX3("NEL_ITEM")[1])
	Local oRepository := nil
	Local oJsonQuery  := JsonObject():new()

	oJsonQuery['filial']        := pcFilial
	oJsonQuery['codigoNegocio'] := pcCodBrt
	oJsonQuery['itemInsumo']    := pcInsumo
	oJsonQuery['order']         := "-item" //ordernado pelo item

	oRepository := VENDA_PERDIDA_REPOSITORY():New()

	oRepository:find(1, 1, oJsonQuery)
	if oRepository:isSuccess()
		if Len(oRepository:getResponse()['items']) > 0
			cSeq = oRepository:getResponse()['items'][1]['item']
		endif
	endif

	FreeObj(oRepository)
return SOMA1(cSeq)

/*/{Protheus.doc} AGDA050SLD
Retorna o Saldo oara
@type function
@version 12
@author jean.schulze
@since 04/02/2025
@param pcCodBrt, variant, param_description
@param pcInsumo, variant, param_description
@return variant, return_description
/*/
function AGDA050SLD(pcCodBrt, pcInsumo)
	Local nSaldo := 0
	Local oService := nil
	Local oNegocioService := nil
	Local cVersaoNegocio := ""

	If !Empty(pcCodBrt) .and. !Empty(pcInsumo)
		oNegocioService := NEGOCIO_SERVICE():New()
		cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(pcCodBrt)

		oService := NEGOCIO_INSUMO_SERVICE():New(pcCodBrt, cVersaoNegocio, pcInsumo)

		nSaldo := oService:getSaldo()

		FreeObj(oService)
	EndIf

return nSaldo

/*/{Protheus.doc} AGDA050VLD
Validações de SX3
@type function
@version 12
@author jean.schulze
@since 06/02/2025
@return variant, informação válida
/*/
function AGDA050VLD()
	Local lRet   := .t.
	Local cReadVar  := ReadVar()

	If "NEL_QUANT" $ cReadVar
		nSaldo := AGDA050SLD(M->NEL_CODBRT, M->NEL_ITEBRT)
		If M->NEL_QUANT > nSaldo
			AGDHELP(STR0006,STR0005,STR0004 )  //"Informe uma quantidade dentro do saldo disponível" //"Quantidade maior que o Saldo Disponível" //"Ajuda"
			lRet := .F.
		EndIf
	endif

return lRet
