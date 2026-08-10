#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"  
//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCB5I
Descricao: Cabeçalho do Arquivos de retorno XTQ
@author jose paulo
@since 23/01/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function CENMVCB5I(cFiltro,lAutom)

   Local aCoors		:= FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Arquivos da Qualidade" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "B5I"
	
    Private oDlgB5I
	Default lAutom	:= .F.
	Default cFiltro	:= 	""

    (cAlias)->(dbSetOrder(1))

	If !lAutom
		Define MsDialog oDlgB5I Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgB5I, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )
	oBrowse:SetMenuDef( 'CENMVCB5I' )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetProfileID( 'CENMVCB5I' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgB5I Center
	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Descrição: Opções do Menu

@author José PAulo
@since 23/01/20
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}
	Private lAutom	:= .F.

    aAdd( aRotina, { "Visualizar"			                       , 'VIEWDEF.CENMVCB5I'				                                   , 0 , 2 , 0 , Nil } ) //Visualizar
    aAdd( aRotina, { "Ocorrências Gerais"	                       , 'CENMVCB5P(.F.,"Ocorrências Gerais")'                                 , 0 , 2 , 0 , Nil } ) //Ocorrências Gerais
    aAdd( aRotina, { "Importar XTQ"                                , 'EnvArqSer("*.xtq|*.xtq","Importar arquivos de Retorno .XTQ","2",.F.)', 0 , 3 , 0 , Nil } ) //Importar XTQ
    aAdd( aRotina, { "Ocorrências por Guia"                        , 'TempB5P(B5I->B5I_CODOPE,B5I->B5I_CMPLOT,B5I->B5I_NUMLOT,.f.)'        , 0 , 2 , 0 , Nil } ) //Ocorrências por guia
	aAdd( aRotina, { "Ocorrências Agrupadas"                       , 'CenOcoAgr(.F.,"B5P")'                                                , 0 , 2 , 0 , Nil } ) //Visualiza Criticas agrupadas
	
Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Descricao: Cria o Modelo da Rotina.
@author José Paulo de Azevedo
@since 27/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef() 

	Local oStrB5I	:= FwFormStruct(1,'B5I')
	Local oModel 	
	
	//Instancia do Objeto de Modelo de Dados
	oModel := MPFormModel():New('CENMVCB5I',,)
	
	// Adiciona os campos no Model - Tipo Enchoice
	oModel:AddFields( 'B5IMASTER', NIL, oStrB5I )
	
	// Definição das Descrições 
	oModel:SetDescription( "Arquivos da Qualidade" )
	oModel:GetModel( 'B5IMASTER' ):SetDescription( "Arquivos da Qualidade" ) 
	oModel:SetPrimaryKey( {"B5I_FILIAL","B5I_CODOPE","B5I_CMPLOT","B5I_NUMLOT"} )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCB5I
Descricao: Cria as VIEW

@author Jose Paulo
@since 23/01/20
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( 'CENMVCB5I' )
	Local oStruB5I 	:= FWFormStruct( 2, 'B5I' ) 
	Local oView    	:= FWFormView():New()

	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_B5I'	,oStruB5I,'B5IMASTER')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',100)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_B5I','CABEC')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_B5I','Arquivos da Qualidade')

	oView:SetCloseOnOk({|| .T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DetArqQu
Descricao: Mostra Ocorrências Gerais

@author José Paulo
@since 28/01/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Function DetArqQu(lAutom)

	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Ocorrências Gerais" 
    Local oPnl
	Local oBrowse   := NIL
	Default lAutom	:= .F.
    Private oDlgB5P

  
    B5P->(dbSetOrder(1))

	// Cria a Tela do Browse
	If !lAutom
		Define MsDialog oDlgB5P Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgB5P, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault()
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( "B5P" )
	oBrowse:SetProfileID( '1' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgB5P Center
	EndIf
	
Return
