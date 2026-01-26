#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM944A.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} GPEM944A
@type			function
@description	Cadastro MVC para apresentar os registros da tabela RUO
@author			martins.marcio
@since			11/07/2025
/*/
//---------------------------------------------------------------------
Function GPEM944A()

    Local cFiltraRh := ""
    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription( OemToAnsi(STR0001) ) //"Histórico de Importações do Crédito do Trabalhador"
    oBrowse:SetAlias( "RUO" )

    //Inicializa o filtro
	oBrowse:SetFilterDefault( cFiltraRh )
    fRUOLeg(@oBrowse)

	oBrowse:ExecuteFilter(.T.)

    oBrowse:Activate()

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author			martins.marcio
@since			11/07/2025
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina :=  {}

    ADD OPTION aRotina TITLE OemToAnsi(STR0002) ACTION 'PesqBrw'          	OPERATION 1 ACCESS 0        //"Pesquisar"
    ADD OPTION aRotina TITLE OemToAnsi(STR0003) ACTION 'VIEWDEF.GPEM944A' 	OPERATION 2 ACCESS 0       //"Visualizar"

Return( aRotina )


//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author			martins.marcio
@since			11/07/2025
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel    := MPFormModel():New( "GPEM944A" )
    Local oStruRUO  := FWFormStruct( 1, 'RUO')

    oModel:AddFields( "GPEM944A_RUO", /*cOwner*/, oStruRUO )
    oModel:SetVldActivate( { |oModel| .T. } )

    //Definição de chave primária do modelo
	oModel:SetPrimaryKey({'RUO_FILIAL', 'RUO_MAT', 'RUO_NRCONT', 'RUO_COMPET', 'RUO_PD', 'RUO_BCOCON'})

Return( oModel )


//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author			martins.marcio
@since			11/07/2025
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel	:=	FWLoadModel( "GPEM944A" )
    Local oView		:=	FWFormView():New()
    Local oStruRUO	:=	FWFormStruct( 2, "RUO" )

	oView:SetModel(oModel)
    oView:AddField( "VIEW_RUO", oStruRUO, "GPEM944A_RUO" )
	oView:CreateHorizontalBox( 'FIELDSRUO' , 100 )
    oView:SetOwnerView( "VIEW_RUO", "FIELDSRUO" )

Return( oView )


//---------------------------------------------------------------------
/*/{Protheus.doc} fRUOLeg
Legenda do browse
@author  martins.marcio
@type    function
@since   11/07/2025
/*/
//---------------------------------------------------------------------
Function fRUOLeg(oBrowse)

    oBrowse:AddLegend( "RUO->RUO_INTEGR=='1' "		, 'GREEN'	, OemToAnsi(STR0004), , .T. )	//"Integrado"
    oBrowse:AddLegend( "RUO->RUO_INTEGR=='2' "		, 'BLUE'	, OemToAnsi(STR0005), , .T. )	//"Não Integrado"

Return( .T. )
