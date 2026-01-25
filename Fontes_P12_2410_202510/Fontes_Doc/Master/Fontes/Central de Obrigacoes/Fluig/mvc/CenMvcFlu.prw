#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCFLU
Descricao: Críticas por Compromisso

@author José Paulo
@since 29/12/2020
@version 1.0

/*/
//-------------------------------------------------------------------

Function CENMVCFLU(cFiltro,lAutom,cDescript)

    Local aCoors    := FWGetDialogSize( oMainWnd )
    Local oFWLayer	:= FWLayer():New()
    Local oPnl
    Local oBrowse
    Local cAlias	:= "B3D"

    Private oDlgB3D
    Private aRotina	:= {}

    Default cDescript := "Críticas do SIB"
    Default cFiltro	:= 	""

    (cAlias)->(dbSetOrder(1))

    If !lAutom
        Define MsDialog oDlgB3D Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
        oFWLayer:Init( oDlgB3D, .F., .T. )
        oFWLayer:AddLine( 'LINE', 100, .F. )
        oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
        oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
    EndIf

    oBrowse:= FWmBrowse():New()
    oBrowse:SetOwner( oPnl )
    oBrowse:SetFilterDefault( cFiltro )
    oBrowse:SetDescription( cDescript )
    oBrowse:SetAlias( cAlias )

    oBrowse:SetMenuDef( 'CENMVCFLU' )
    oBrowse:SetProfileID( 'CENMVCFLU' )
    oBrowse:ForceQuitButton()
    oBrowse:DisableDetails()
    oBrowse:SetWalkthru(.F.)
    oBrowse:SetAmbiente(.F.)

    If !lAutom
        oBrowse:Activate()
        Activate MsDialog oDlgB3D Center
    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Opções do Menu

@author José Paulo
@since 29/12/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

    Private aRotina	:= {}


    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCFLU'					, 0 , 2 , 0 , Nil } )

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Descricao: Cria o Modelo da Rotina.
@author José PAulo
@since 29/12/2020
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStruB3D	:= FwFormStruct(1,'B3D')
    Local oStruB3F	:= FwFormStruct(1,'B3F')
    Local oModel

    oStruB3D:AddField("Operadora","Operadora" , "B3D_DESOPE", 'C', 50, 0, /*bValid*/	,{||.T. } , {}	, .F.	, , .F., .F., .F., , )
    //   oStruB3D:AddField("Vencimento do Compromisso","Vencimento do Compromisso" , "B3D_VENCIM", 'D', 8, 0, /*bValid*/	,{||.T. } , {}	, .F.	, , .F., .F., .F., , )
    oStruB3F:AddField("Solução","Solução" , "B3F_RESOLV", 'M', 10, 0, /*bValid*/	,{||.T. } , {}	, .F.	, , .F., .F., .F., , )

    //Instancia do Objeto de Modelo de Dados
    oModel := MPFormModel():New('CENMVCFLU')
    oModel:AddFields( 'B3DMASTER', NIL, oStruB3D )

    oModel:AddGrid( 'B3FDETAIL', 'B3DMASTER', oStruB3F )

    oModel:getModel("B3FDETAIL"):SetOptional(.T.)
    oModel:getModel('B3FDETAIL'):SetDescription("Críticas")
    oModel:SetRelation( 'B3FDETAIL',  {{ 'B3F_FILIAL', 'xFilial( "B3F" )' },{ 'B3F_CODOPE' , 'B3D_CODOPE' },{ 'B3F_CDOBRI' , 'B3D_CDOBRI' },{ 'B3F_CDCOMP' , 'B3D_CODIGO' }}, B3F->( IndexKey( 1 ) ) )

    oModel:SetPrimaryKey({'xFilial("B3D")','B3D_CODOPE','B3D_CDOBRI','B3D_ANO','B3D_CODIGO','B3D_TIPOBR'})

    oModel:GetModel( 'B3DMASTER' ):SetDescription( "Compromissoo")
    oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Críticas")
    oModel:SetDescription( "Críticas do SIB" )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Descricao: Cria a View da Rotina.
@author José PAulo
@since 29/12/2020
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oModel   	:= FWLoadModel( 'CENMVCFLU' )
    Local oStruB3D 	:= FWFormStruct( 2, 'B3D' )
    Local oStruB3F 	:= FWFormStruct( 2, 'B3F' )
    Local oView    	:= FWFormView():New()
    oStruB3D:AddField('B3D_DESOPE','01','Operadora', 'Operadora',{'Operadora'},'C',NIL,NIL,NIL,.T.,'1','1',NIL,NIL,"",.F.,NIL )

    oStruB3D:SetProperty('B3D_CODOPE',MVC_VIEW_LOOKUP,"")

    oStruB3D:SetProperty('B3D_CODOPE',MVC_VIEW_TITULO,"Registro Operadora")
    oStruB3D:SetProperty('B3D_CDOBRI',MVC_VIEW_TITULO,"Código Obrigação")
    oStruB3D:SetProperty('B3D_CODIGO',MVC_VIEW_TITULO,"Código do Compromisso")
    oStruB3D:SetProperty('B3D_OBRDES',MVC_VIEW_TITULO,"Descrição da Obrigação")
    oStruB3D:SetProperty('B3D_TIPOBR',MVC_VIEW_TITULO,"Tipo da Obrigação")
    oStruB3D:SetProperty('B3D_ANO'   ,MVC_VIEW_TITULO,"Ano Referência")
    oStruB3D:SetProperty('B3D_REFERE',MVC_VIEW_TITULO,"Referência do Compromisso")
    oStruB3D:SetProperty('B3D_VCTO'  ,MVC_VIEW_TITULO,"Vencimento do Compromisso")
    oStruB3D:SetProperty('B3D_AVVCTO',MVC_VIEW_TITULO,"Aviso de Vencimento")

    oStruB3D:SetProperty('B3D_CODOPE',MVC_VIEW_CANCHANGE,.F.)
    oStruB3D:SetProperty('B3D_VCTO'  ,MVC_VIEW_CANCHANGE,.F.)
    oStruB3D:SetProperty('B3D_ANO'   ,MVC_VIEW_CANCHANGE,.F.)
    oStruB3D:SetProperty('B3D_AVVCTO',MVC_VIEW_CANCHANGE,.F.)
    oStruB3D:SetProperty('B3D_DESOPE',MVC_VIEW_CANCHANGE,.F.)
    oStruB3D:SetProperty('B3D_STATUS',MVC_VIEW_CANCHANGE,.F.)

    oStruB3D:RemoveField("B3D_SNTBEN")
    oStruB3D:RemoveField("B3D_QTDCRI")
    oStruB3D:RemoveField("B3D_OBRDES")
    oStruB3D:RemoveField("B3D_FILIAL")

    oStruB3D:SetProperty('B3D_CODOPE',MVC_VIEW_ORDEM,'01')
    oStruB3D:SetProperty('B3D_DESOPE',MVC_VIEW_ORDEM,'02')
    oStruB3D:SetProperty('B3D_VCTO'  ,MVC_VIEW_ORDEM,'03')
    oStruB3D:SetProperty('B3D_REFERE',MVC_VIEW_ORDEM,'04')
    oStruB3D:SetProperty('B3D_STATUS',MVC_VIEW_ORDEM,'05')
    oStruB3D:SetProperty('B3D_AVVCTO',MVC_VIEW_ORDEM,'06')
    oStruB3D:SetProperty('B3D_CDOBRI',MVC_VIEW_ORDEM,'07')
    oStruB3D:SetProperty('B3D_TIPOBR',MVC_VIEW_ORDEM,'08')
    oStruB3D:SetProperty('B3D_CODIGO',MVC_VIEW_ORDEM,'09')
    oStruB3D:SetProperty('B3D_ANO'   ,MVC_VIEW_ORDEM,'10')

    oStruB3F:RemoveField("B3F_OK")
    oStruB3F:RemoveField("B3F_CHVORI")
    oStruB3F:RemoveField("B3F_NFLUIG")
    oStruB3F:RemoveField("B3F_SOLUCA")

    oStruB3F:AddField('B3F_RESOLV','04','Solução', 'Solução',{'Solução'},'M',NIL,NIL,NIL,.T.,'1','1',NIL,NIL,"",.F.,NIL )

    oStruB3F:SetProperty('B3F_DESCRI',MVC_VIEW_ORDEM,'01')
    oStruB3F:SetProperty('B3F_CODCRI',MVC_VIEW_ORDEM,'02')
    oStruB3F:SetProperty('B3F_RESOLV',MVC_VIEW_ORDEM,'03')
    oStruB3F:SetProperty('B3F_IDEORI',MVC_VIEW_ORDEM,'04')
    oStruB3F:SetProperty('B3F_DESORI',MVC_VIEW_ORDEM,'05')
    oStruB3F:SetProperty('B3F_CAMPOS',MVC_VIEW_ORDEM,'06')
    oStruB3F:SetProperty('B3F_LEGEN' ,MVC_VIEW_ORDEM,'07')
    oStruB3F:SetProperty('B3F_CRIANS',MVC_VIEW_ORDEM,'08')
    oStruB3F:SetProperty('B3F_TIPO'  ,MVC_VIEW_ORDEM,'09')
    If !IsBlind()
        oStruB3F:SetProperty('B3F_ANO'   ,MVC_VIEW_ORDEM,'10')
    endif
    oStruB3F:SetProperty('B3F_IDEORI',MVC_VIEW_TITULO,'Matrícula')
    oStruB3F:SetProperty('B3F_DESORI',MVC_VIEW_TITULO,'Beneficiário')
    oStruB3F:SetProperty('B3F_DESCRI',MVC_VIEW_TITULO,'Descrição da Crítica')
    oStruB3F:SetProperty('B3F_CODCRI',MVC_VIEW_TITULO,'Código da Crítica')
    oStruB3F:SetProperty('B3F_RESOLV',MVC_VIEW_CANCHANGE,.F.)

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_B3D' , oStruB3D, 'B3DMASTER' )
    oView:AddGrid( 'VIEW_B3F'  , oStruB3F, 'B3FDETAIL' )

    oView:CreateHorizontalBox( 'SUPERIOR', 40 )
    oView:CreateHorizontalBox( 'INFERIOR', 60 )

    oView:SetOwnerView( 'VIEW_B3D', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_B3F', 'INFERIOR' )

    //Insiro descrições nas views
    oView:EnableTitleView( 'VIEW_B3D', "Compromisso" )
    oView:EnableTitleView( 'VIEW_B3F', "Críticas" )

Return oView
