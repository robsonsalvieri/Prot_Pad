#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"

//Utilização do E

//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCBRF
Descricao: Rotina de Guias Processadas. 

@author Hermiro Júnior
@since 22/08/2019
@version 1.0

@Param: cFiltro -> Filtro do mBrowse vinda do Fonte CENMVCBRF

/*/
//-------------------------------------------------------------------

Function CENMVCBRF(cFiltro,cDescript,cType,lAutom)

    Local aCoors        := FWGetDialogSize( oMainWnd )
	Local oFWLayer		:= FWLayer():New()
    Local oPnl
	Local oBrowse
	Local cAlias	    := "BRF"
	Private cFilBrw		:= ''
    Private oDlgBRF
	Private aRotina		:=	{}

	Default cFiltro     := ''
    Default cDescript   := "Guias Processadas" 
    Default cType       := ''
	Default lAutom		:= .F.   

    (cAlias)->(dbSetOrder(1))
	// Criação dos Componentes Visuais
	If !lAutom
		Define MsDialog oDlgBRF Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgBRF, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	// Cria a Tela do Browse
	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )
	oBrowse:SetProfileID( '1' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	// Define qual os Menus Corretos quando a Rotina for executada pelo Histórico.
	If Empty(cType) // Não veio das Rotinas de Histórico do Monitoramento.
		oBrowse:SetMenuDef( 'CENMVCBRF' )

	Else
		//Defino o Filtro Padrão
		cFilBrw		:= "BKR_FILIAL==xFilial('BRF') .AND. BKR_NMGOPE== BRF->BRF_NMGOPE"
		// Adiciona a Rotina ao Menu
		aAdd( aRotina, { "Visualizar"	, 'VIEWDEF.CENMVCBRF'	, 0 , 2 , 0 , Nil } ) 
		aAdd( aRotina, { "Histórico"	, 'CENMVCBKR(cFilBrw)'	, 0 , 7 , 0 , Nil } ) 
	EndIf
	// Somente quando não for teste automatizado.
	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgBRF Center
	EndIf
Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Opções do Menu

@author Hermiro Júnior
@since 22/08/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}
	
    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCBRF'			, 0 , 2 , 0 , Nil } ) // Visualização   das Guias

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Descricao: Cria o Modelo da Rotina.
@author Hermiro Júnior
@since 22/08/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Static Function ModelDef() 

	Local oStrBRF	:= FwFormStruct(1,'BRF')
	Local oStrBRG	:= FwFormStruct(1,'BRG')
	Local oStrBRH	:= FwFormStruct(1,'BRH')

	//Instancia do Objeto de Modelo de Dados
	oModel := MPFormModel():New('CENMVCBRF')
	oModel:AddFields( 'BRFMASTER', NIL, oStrBRF )
	oModel:AddGrid( 'BRGDETAIL', 'BRFMASTER', oStrBRG )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'BRGDETAIL',  { 	{ 'BRG_FILIAL'	, 'xFilial( "BRF" )' },;
											{ 'BRG_CODOPE' 	, 'BRF_CODOPE' },;
											{ 'BRG_NMGOPE' 	, 'BRF_NMGOPE' };
										}, BRG->( IndexKey( 1 ) ) )

	oModel:GetModel( 'BRFMASTER' ):SetDescription( "Processamento" ) 
	oModel:GetModel( 'BRGDETAIL' ):SetDescription( "Eventos" ) 
	oModel:SetDescription( "Processamentos" )
	
	oModel:addGrid('BRHDETAIL','BRGDETAIL',oStrBRH) 
	oModel:getModel("BRHDETAIL"):SetOptional(.T.)
	oModel:getModel('BRHDETAIL'):SetDescription('Pacotes')     						
	oModel:setRelation("BRHDETAIL", ;       
											{{"BRH_FILIAL",'xFilial("BRH")'	},;        
											{"BRH_CODOPE","BRG_CODOPE" 		},;        
											{"BRH_NMGOPE","BRG_NMGOPE"		},;
											{"BRH_CODTAB","BRG_CODTAB"		},;
											{"BRH_CODPRO","BRG_CODPRO"		};        
										},	BRH->(IndexKey(1)))

Return oModel

Static Function ViewDef()

	Local oModel   	:= FWLoadModel( 'CENMVCBRF' )
	Local oStruBRF 	:= FWFormStruct( 2, 'BRF' ) 
	Local oStruBRG 	:= FWFormStruct( 2, 'BRG' )
	Local oStruBRH 	:= FWFormStruct( 2, 'BRH' )
	Local oView    	:= FWFormView():New()
	Local cFilB3K   :=""
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BRF' , oStruBRF, 'BRFMASTER' )
	
	oView:AddGrid( 'VIEW_BRG'  , oStruBRG, 'BRGDETAIL' )
	oView:AddGrid( 'VIEW_BRH'  , oStruBRH, 'BRHDETAIL' )
		
	
	oView:CreateHorizontalBox( 'SUPERIOR', 50 )
	
	oView:CreateHorizontalBox( 'BOXFOLDER', 50)
	oView:CreateFolder( 'FOLDER', 'BOXFOLDER')
	oView:addSheet("FOLDER","ABA1","Eventos")
	oView:addSheet("FOLDER","ABA2","Pacotes")	
	
	
	oView:createHorizontalBox("BOX_SUPERIOR",100,,,"FOLDER","ABA1")
	oView:createHorizontalBox("BOX_INFERIOR",100,,,"FOLDER","ABA2")
	
	
	oView:CreateVerticalBox( 'BOX_EVEN', 100, 'BOX_SUPERIOR',,"FOLDER","ABA1") 
 	oView:CreateVerticalBox( 'BOX_PAC' , 100, 'BOX_INFERIOR',,"FOLDER","ABA2") 
	
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_BRF', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_BRG', 'BOX_EVEN' )
	oView:SetOwnerView( 'VIEW_BRH', 'BOX_PAC' )

	//Insiro descrições nas views
	oView:EnableTitleView( 'VIEW_BRF', "Dados Guia Processadas" )
	oView:EnableTitleView( 'VIEW_BRG', "Eventos" )
	oView:EnableTitleView( 'VIEW_BRH', "Pacotes" )

	oView:AddUserButton( 'Declar. Nascidos/Óbitos'	, 'CLIPS', {|oView| PlSBRFDECL()} )

	if FunName()=='CENMVCB5I'
		cFilB3K := " B3K_FILIAL=xFilial( 'BRF' ) .AND. B3K_CODOPE=BRF->BRF_CODOPE .AND. B3K_MATRIC=BRF->BRF_MATRIC "
		oView:AddUserButton( 'Beneficiário'	, 'CLIPS', {|oView| PLSMVCBENE(.f.,cFilB3K,'Beneficiário' )} )
	endIf

	//Remove campos da chave primaria - BRG
	oStruBRG:RemoveField( 'BRG_FILIAL' )
	oStruBRG:RemoveField( 'BRG_CODOPE' )
	oStruBRG:RemoveField( 'BRG_NMGOPE' )

	//Remove campos da chave primaria - BRH
	oStruBRH:RemoveField( 'BRH_FILIAL' )
	oStruBRH:RemoveField( 'BRH_CODOPE' )
	oStruBRH:RemoveField( 'BRH_NMGOPE' )
	oStruBRH:RemoveField( 'BRH_CODTAB' )
	oStruBRH:RemoveField( 'BRH_CODPRO' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PlSBRFDECL
Descricao: Visualiza as declaracoes de nascidos e obitos

@author Sakai
@since 06/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function PlSBRFDECL(lAuto)

	Local oCltBNY   := CenCltBNY():New()
	Local aDadosBNY := {}
	Local cTipo   := ""
	Local cNumero := ""
	Default lAuto := .F.

	oCltBNY:setValue("operatorRecord"    ,BRF->BRF_CODOPE)
	oCltBNY:setValue("operatorFormNumber",BRF->BRF_NMGOPE)
	   	
	if oCltBNY:buscar()
		while oCltBNY:HasNext()
            oDeclar := oCltBNY:GetNext()
            cTipo   := iif(oDeclar:getValue("certificateType")=="1","Nascido","Obito")
			cNumero := oDeclar:getValue("certificateNumber")
			aadd(aDadosBNY,{cTipo,cNumero})
            oDeclar:destroy()
        endDo
	endIf
	oCltBNY:destroy()
	
	if len(aDadosBNY) > 0
		iif(lAuto,nil,PLSCRIGEN(aDadosBNY,{ {"Tipo Declaração","@C",90} , {"Número","@C",80 } },"Declarações Nascidos/Óbitos"))
	else
		iif(lAuto,Conout("Esta guia não tem declarações de nascidos/óbitos."),Aviso("Atenção","Esta guia não tem declarações de nascidos/óbitos.",{ "Ok" }, 2 ))
	endIf

Return