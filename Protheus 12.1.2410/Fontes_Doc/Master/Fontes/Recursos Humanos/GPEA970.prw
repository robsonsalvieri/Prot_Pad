#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA970.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} GPEA970
@type			function
@description	Cadastro MVC da rotina Prefixo IdeDmDEV.
@author			lidio.oliveira
@since			08/04/2024
/*/
//---------------------------------------------------------------------
Function GPEA970()

    Local lNewDmDev	:= SuperGetMv("MV_IDEVTE", , .F. ) .And. ChkFile("RU8") .And. FindFunction("fTemRU8")
    Local cFiltraRh := ""
    Local oBrowse

    //Verifica se o ambiente está atualizado e o parâmetro MV_IDEVTE ativo
    //Ambiente desatualizado ou parâmetro MV_IDEVTE desabilitado.
    //Acesse o configurador e confira se o parâmetro MV_IDEVTE está habilitado, o parâmetro deve estar ativo e o ambiente atualizado.
    If !lNewDmDev
		lRet := .F.
        Help( " ", 1, OemToAnsi(STR0002), Nil, OemToAnsi(STR0003), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0004) } )
        Return
	EndIf

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription( STR0001 )
    oBrowse:SetAlias( "SRA" )

    //Inicializa o filtro
	cFiltraRh := CHKRH("GPEA970","SRA","1")
	oBrowse:SetFilterDefault( cFiltraRh )
    GpLegMVC(@oBrowse)

    //Filtro registros com dados na RU8
    oBrowse:SetFilterDefault("fTemRU8(RA_FILIAL, RA_MAT)")
	oBrowse:ExecuteFilter(.T.)    

    oBrowse:Activate()

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@type			function
@description	Função genérica MVC do menu.
@author			lidio.oliveira
@since			08/04/2024
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function MenuDef()
    
    Local aRotina :=  {}

    ADD OPTION aRotina TITLE "Pesquisar"    ACTION 'PesqBrw'          	OPERATION 1 ACCESS 0 //"Pesquisar"
    ADD OPTION aRotina TITLE "Visualizar"   ACTION 'VIEWDEF.GPEA970'	OPERATION 2 ACCESS 0 //"Visualizar"

Return( aRotina )


//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@type			function
@description	Função genérica MVC do modelo.
@author			lidio.oliveira
@since			08/04/2024
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel    := MPFormModel():New( "GPEA970" )
    Local oStruRU8  := FWFormStruct( 1, 'RU8')
    Local oStruSRA  

    oStruSRA := FWFormStruct(1,"SRA",{|cCampo| AllTrim(cCampo) $ "RA_MAT|RA_NOME|RA_CIC|RA_ADMISSA|"})
    oStruRU8 := FWFormStruct(1,"RU8",{|cCampo| AllTrim(cCampo) $ "RU8_MAT|RU8_CPF|RU8_ID|RU8_PERINI|"})
   
    oModel:AddFields("GPEA970_SRA", /*cOwner*/, oStruSRA )
	oModel:GetModel("GPEA970_SRA"):SetOnlyView( .T. )
	oModel:GetModel("GPEA970_SRA"):SetOnlyQuery( .T. )
    oModel:GetModel("GPEA970_SRA"):SetDescription(OemToAnsi(STR0005)) //"Funcionário"

    oModel:AddFields( "GPEA970_RU8", "GPEA970_SRA", oStruRU8 )
    oModel:SetRelation("GPEA970_RU8",{{"RU8_FILIAL",'xFilial("RU8",SRA->RA_FILIAL)'},{"RU8_MAT","RA_MAT"}},RU8->(IndexKey()))
	oModel:GetModel("GPEA970_SRA"):SetDescription(OemToAnsi(STR0006)) //"Código do Prefixo e Período Inicial de Uitlização"
    oModel:SetVldActivate( { |oModel| .T. } )

Return( oModel )


//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type			function
@description	Função genérica MVC da view.
@author			lidio.oliveira
@since			08/04/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local oModel	:=	FWLoadModel( "GPEA970" )
    Local oView		:=	FWFormView():New()
    Local oStruRU8	:=	FWFormStruct( 2, "RU8" )
    Local oStruSRA

	oView:SetModel(oModel)
   	
    oStruSRA := FWFormStruct(2,"SRA",{|cCampo| AllTrim(cCampo) $ "RA_NOME|RA_CIC|RA_ADMISSA"})
	oStruSRA:SetNoFolder()
    
    oStruRU8:RemoveField( "RU8_FILIAL" )
    oStruRU8:RemoveField( "RU8_MAT" )
    oStruRU8:RemoveField( "RU8_CPF" )
    oStruRU8:RemoveField( "RU8_DTADM" )
  
    oView:AddField( "VIEW_SRA", oStruSRA, "GPEA970_SRA" )
    oView:AddField( "VIEW_RU8", oStruRU8, "GPEA970_RU8" )

    oView:EnableTitleView( "VIEW_SRA", OemToAnsi(STR0005) ) //"Funcionário"
    oView:EnableTitleView( "VIEW_RU8", OemToAnsi(STR0006)) //"Código do Prefixo e Período Inicial de Uitlização"
    
    oView:SetOnlyView('VIEW_SRA')
    
    oView:createHorizontalBox("FORMSRA",15)
	oView:createHorizontalBox("FIELDSRU8",85)
    
    oView:SetOwnerView( "VIEW_SRA", "FORMSRA" )
    oView:SetOwnerView( "VIEW_RU8", "FIELDSRU8" )

Return( oView )
