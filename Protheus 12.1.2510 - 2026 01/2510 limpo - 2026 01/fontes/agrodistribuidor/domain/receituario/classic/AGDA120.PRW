#Include "TOTVS.ch"
#Include "fwmvcdef.ch"
#Include "agda120.ch"

/*/{Protheus.doc} AGDA120
Rotina para Cadastro da Receita/Itens de Receita
@type function
@version P12
@author Gilson.Venturi
@since 18/11/2025
/*/
Function AGDA120()
    Local oMBrowse := Nil

    If .Not. TableInDic('NE6')
		MsgNextRel()
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NE6" )
	oMBrowse:SetDescription( STR0001 ) //#"Receita"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Definição do menu
@type function
@version P12
@author Gilson.Venturi
@since 18/11/2025
@return Array, array com o menu da rotina
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA120' OPERATION 2 ACCESS 0 //#"Visualizar"
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGDA120' OPERATION 4 ACCESS 0 //"Alterar"
	
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@type function
@version P12
@author Gilson.Venturi
@since 18/11/2025
@return Object, modelo de dados
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNE6  := FwFormStruct( 1, "NE6" )
	Local oStruNE7	:= FwFormStruct( 1, "NE7" )

	oModel := MpFormModel():New( "AGDA120")
	oModel:SetDescription( STR0001 ) //##"Receita"

	oStruNE7:SetProperty( "NE7_CODREC" 	, MODEL_FIELD_INIT 	, {| | M->NE6_CODREC } )

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA120_NE6", , oStruNE6)
	oModel:GetModel( "AGDA120_NE6" ):SetDescription( STR0003 ) //#"Dados da Receita"
	oModel:SetPrimaryKey( { "NE6_FILIAL", "NE6_CODREC" } )

	oModel:AddGrid( "AGDA120_NE7", "AGDA120_NE6", oStruNE7)
	oModel:GetModel( "AGDA120_NE7" ):SetDescription( STR0004 ) //#"Itens da Receita"

	//Atribui um relacionamento de Pai X Filho
	oModel:SetRelation( 'AGDA120_NE7', {{'NE7_FILIAL', 'FWxFilial("NE7")'},{ 'NE7_CODREC', 'NE6_CODREC' }}, NE7->(IndexKey( 1 ) ) )

	oModel:GetModel( "AGDA120_NE7" ):SetUniqueLine( { 'NE7_SEQREC' } )
	oModel:GetModel( "AGDA120_NE7" ):SetOptional( .F. )
	oModel:GetModel( "AGDA120_NE7" ):SetUseOldGrid(.T.)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da visualização dos dados
@type function
@version P12.1.2610
@author Gilson.Venturi
@since 18/11/2025
@return Object, Objeto de dados da View
/*/
Static Function ViewDef()

	Local oModel	:= FwLoadModel( "AGDA120" )
	Local oStruNE6  := FwFormStruct( 2, "NE6" )
	Local oStruNE7  := FwFormStruct( 2, "NE7" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oStruNE7:RemoveField( "NE7_CODREC" )

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NE6', oStruNE6, 'AGDA120_NE6' )

	oView:AddGrid( 'VIEW_NE7', oStruNE7, 'AGDA120_NE7' )
	oView:AddIncrementField( 'VIEW_NE7', 'NE7_SEQREC' )

	oView:CreateHorizontalBox( 'CABEC', 50 )
	oView:CreateHorizontalBox( 'GRID', 50 )

	oView:SetOwnerView( 'VIEW_NE6', 'CABEC' )
	oView:SetOwnerView( 'VIEW_NE7', 'GRID' )

	oView:EnableTitleView("VIEW_NE6")
	oView:EnableTitleView("VIEW_NE7")

	oView:SetCloseOnOk({||.T.})
Return oView

/*/{Protheus.doc} IntegDef
IntegDef - Integração EAI do cadastro de Receita (AGDA120) para AgroReceita
@type  function
@version 12
@author rodrigo.nsoledade
@since  03/12/2025
@param  xEnt         , variant   , xml/obj para envio/recebimento
@param  cTypeTrans   , character , "0"=TRANS_SEND, "1"=TRANS_RECEIVE
@param  cTypeMessage , character , Tipo Mensagem '20'=DEFINE EAI_MESSAGE_BUSINESS,
                                  '21'=DEFINE EAI_MESSAGE_RESPONSE,
                                  '22'=DEFINE EAI_MESSAGE_RECEIPT,
                                  '23'=DEFINE EAI_MESSAGE_WHOIS
@param  cVersion     , character , Versão
@param  cTransaction , character , Nome mensagem única
@param  lEAIObj      , logical   , EAI Object (JSON = .T.)
@return array, { lResult , xValue(oFWEAIobj ou cMsgErr) , cTransaction }
/*/
Static Function IntegDef(xEnt, cTypeTrans, cTypeMessage, cVersion, cTransaction, lEAIObj)
    Default lEAIObj := .F.
    
Return AGDIP120(xEnt, cTypeTrans, cTypeMessage, cVersion, cTransaction, lEAIObj)
