#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RU99D204.CH'

/*/{Protheus.doc} RU99D204
    "EAI Queue" routine main function
    @type function
    @author Andrews Egas
    @since 22/12/2016
    @version P10
    @return Nil
/*/
Function RU99D204()

    Local oBrowse as Object
    Local aColors := {} as Array
    Local nX as numeric
    Local oDSChart := FWDSChart():New()

    oDSChart:SetID("RU99D204001")
    oDSChart:SetName(STR0005) // Status
    oDSChart:SetTitle(STR0005) // Status
    oDSChart:SetPublic(.T.)
    oDSChart:SetSeries({ {"F6Y","F6Y_MSUID","COUNT"} })
    oDSChart:SetCategory({ {"F6Y", "F6Y_STATUS"} })
    oDSChart:SetType("PIECHART")
    oDSChart:SetLegend(CONTROL_ALIGN_LEFT)
    oDSChart:SetTitleAlign(CONTROL_ALIGN_CENTER)
    oDSChart:SetPicture("99999")

    // Initalization of tables, if they do not exist.
    DBSelectArea("F6Y")
    F6Y->(DbSetOrder(1))

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('F6Y')
    oBrowse:SetDescription(STR0001) // EAI Queue
    aColors := np.framework.eai.RU99X20016_GetLegendColors()
    For nX:=1 To Len(aColors)
        oBrowse:AddLegend( "F6Y_STATUS == '"+aColors[nX,1]+"'", aColors[nX,2], aColors[nX,3])
    Next
    oBrowse:SetChartsDefault( {oDSChart} )
    oBrowse:SetOpenChart( .T. ) 
    //Set filter to not show purged
    //oBrowse:SetFilter()
    oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
    "EAI Queue" routine menu
    @type function
    @author Andrews Egas
    @since 22/12/2016
    @version P10
    @return Array, Items of menu
/*/
Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002	 		ACTION 'VIEWDEF.RU99D204' OPERATION 2 ACCESS 0 // View
    //ADD OPTION aRotina TITLE STR0003    		ACTION 'VIEWDEF.RU99D204' OPERATION 4 ACCESS 0 // Edit
    ADD OPTION aRotina TITLE STR0004    		ACTION 'VIEWDEF.RU99D204' OPERATION 5 ACCESS 0 // Delete

Return aRotina

/*/{Protheus.doc} ModelDef()
    "EAI Queue" routine MVC Model
    @type function
    @author Andrews Egas
    @since 22/12/2016
    @version P10
    @return Object, MVC Model
/*/
Static Function ModelDef()
    // Creates the structure to be used in the Data Model
    Local oStruF6Y 	:= FWFormStruct( 1, 'F6Y', /*bAvalCampo*/,/*lViewUsado*/ )
    Local oStruF6Z 	:= FWFormStruct( 1, 'F6Z')
    Local oModel

    // Creates the Data Model object
    oModel := MPFormModel():New('RU99D204', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields( 'F6YMASTER', /*cOwner*/, oStruF6Y, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
    oModel:AddGrid('F6ZDETAIL', 'F6YMASTER', oStruF6Z, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

    oModel:SetPrimaryKey( { "F6Y_FILIAL", "F6Y_MSUID"} )

    // Relate the components of the model
    oModel:SetRelation( 'F6ZDETAIL', {{ 'F6Z_FILIAL', 'F6Y_FILIAL' },  { 'F6Z_QUUID', 'F6Y_MSUID' }}, "F6Z_FILIAL+F6Z_QUUID+F6Z_DTINS" )
    oModel:GetModel('F6ZDETAIL'):SetOptional(.T.)
    //oModel:GetModel( 'F6ZDETAIL' ):SetUniqueLine( { 'F42_REPORT','F42_ITEM' } )

    // Adiciona a descricao do Modelo de Dados
    //OModel:SetDescription( STR0012 )

    // Adiciona a descricao do Componente do Modelo de Dados
    //oModel:GetModel( 'F6YMASTER' ):SetDescription( STR0012 )
    //oModel:GetModel( 'F42DETAIL' ):SetDescription( STR0011 )
    // Liga a validasso da ativacao do Modelo de Dados

Return oModel

/*/{Protheus.doc} ViewDef()
    "EAI Queue" routine MVC View
    @type function
    @author Andrews Egas
    @since 22/12/2016
    @version P10
    @return Object, MVC View
/*/
Static Function ViewDef()
    // Creates a Data Model object based on the ModelDef of the given source
    Local oModel   := FWLoadModel( 'RU99D204' )
    // Creates the structure to be used in the View
    Local oStruF6Y 	:= FWFormStruct( 2, 'F6Y' ) 
    Local oStruF6Z 	:= FWFormStruct( 2, 'F6Z' ) 
    Local oView

    // Creates the View object
    oView := FWFormView():New()

    // Defines which data model will be used
    oView:SetModel( oModel )

    // Adds a FormFields control (formerly enchoice) to our View
    oView:AddField( 'F6Y', oStruF6Y, 'F6YMASTER' )
    oView:AddGrid( 	'F6Z', oStruF6Z, 'F6ZDETAIL' )
    oView:CreateHorizontalBox( 'TOP' 	, 40 )
    oView:CreateHorizontalBox( 'BOTTOM' , 60 )

    oView:SetOwnerView( 'F6Y', 'TOP')
    oView:SetOwnerView( 'F6Z', 'BOTTOM')

Return oView
                   
//Merge Russia R14 
                   
