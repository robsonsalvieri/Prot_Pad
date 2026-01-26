#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCBVQ
Descricao:  Rotina MVC de Fornecimento Direto referente ao Projeto de 
            Monitoramento TISS.

@author Hermiro Júnior
@since 29/08/2019
@version 1.0

@Param: cFiltro -> Filtro do mBrowse vinda do Fonte CENMVCBVQ
		lAutom  -> Cobertira de Testes Automatizados
/*/
//-------------------------------------------------------------------
Function CENMVCBVQ(cFiltro,lAutom)

    Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Fornecimento Direto" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "BVQ"
	
    Private oDlgBVQ
	Private aRotina	:= {}
	Default lAutom	:= .F.
	Default cFiltro	:= 	" BVQ_FILIAL = xFilial( 'BVQ' ) .AND. " +;
						" BVQ_CODOPE = B3D->B3D_CODOPE .AND. " +;
						" BVQ_CDOBRI = B3D->B3D_CDOBRI .AND. " +;
						" BVQ_ANO = B3D->B3D_ANO .AND. " +;
						" BVQ_CDCOMP = B3D->B3D_CODIGO "

    (cAlias)->(dbSetOrder(1))

	// Desvio para contemplar a Cobertura de testes
	If !lAutom
		Define MsDialog oDlgBVQ Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgBVQ, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' ) 
	EndIf 

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )

	oBrowse:AddLegend( "BVQ_STATUS=='1'", "YELLOW"	, "Pendente Validação" )
	oBrowse:AddLegend( "BVQ_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "BVQ_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "BVQ_STATUS=='4'", "ORANGE"	, "Em processamento ANS" )
	oBrowse:AddLegend( "BVQ_STATUS=='5'", "BLACK" 	, "Criticado pela ANS" )
	oBrowse:AddLegend( "BVQ_STATUS=='6'", "GREEN" 	, "Finalizado" )	
	oBrowse:AddLegend( "BVQ_STATUS=='7'", "WHITE"	, "Pendente Geração do Arquivo" )
	oBrowse:AddLegend( "BVQ_STATUS=='8'", "PINK" 	, "Arquivo Gerado" )

	oBrowse:SetMenuDef( 'CENMVCBVQ' )
	oBrowse:SetProfileID( 'CENMVCBVQ' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	// Desvio para contemplar a Cobertura de testes
	If !lAutom
		oBrowse:Activate()
    	Activate MsDialog oDlgBVQ Center
	EndIf 

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Opções do Menu

@author Hermiro Júnior
@since 29/08/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCBVQ'				, 0 , 2 , 0 , Nil } ) // Visualização  do Fornecimento direto
	aAdd( aRotina, { "Validar Guias"		, 'VldGuiaForn(BVQ->BVQ_NMGPRE)'	, 0 , 2 , 0 , Nil } ) // Validação da Guia
	aAdd( aRotina, { "Críticas Guia"		, 'VisCriForn(.F.,"1")'		, 0 , 2 , 0 , Nil } ) // Visualização das Criticas da Guia
	aAdd( aRotina, { "Criticas XTR"			, 'VisCriForn(.F.,"3")'		, 0 , 2 , 0 , Nil } ) // Visualização das Criticas da Guia
	aAdd( aRotina, { "Beneficiário"	    	, 'CenMosBen(BVQ->BVQ_CODOPE,BVQ->BVQ_MATRIC,.F.)' , 0 , 2 , 0 , Nil } ) // Beneficiário
	aAdd( aRotina, { "Histórico de Guias"	, 'HisGuiBvq(BVQ->BVQ_NMGPRE,.F.)'		, 0 , 2 , 0 , Nil } ) // Visualização das Guias Identificadas como Valor Pre Estabelecido.


Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Descricao: Cria o Modelo da Rotina.
@author Hermiro Júnior
@since 29/08/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Static Function ModelDef() 

	Local oStrBVQ	:= FwFormStruct(1,'BVQ')
	Local oStrBVT	:= FwFormStruct(1,'BVT')
	Local oModel 


	//Instancia do Objeto de Modelo de Dados
	oModel := MPFormModel():New('CENMVCBVQ')
	oModel:AddFields( 'BVQMASTER', NIL, oStrBVQ )

		oModel:AddGrid( 'BVTDETAIL', 'BVQMASTER', oStrBVT )

	oModel:getModel("BVTDETAIL"):SetOptional(.T.)
	oModel:getModel('BVTDETAIL'):SetDescription("Dados Fornecimento Direto")     						
	oModel:setRelation("BVTDETAIL", ;       
											{{"BVT_FILIAL",'xFilial("BVQ")'	},;        
											 {"BVT_CODOPE",	"BVQ->BVQ_CODOPE"	},;  
										     {"BVT_NMGPRE",	"BVQ->BVQ_NMGPRE"	},;  
											 {"BVT_CDOBRI",	"BVQ->BVQ_CDOBRI"	},;        
											 {"BVT_ANO",	"BVQ->BVQ_ANO"		},;  
											 {"BVT_CDCOMP",	"BVQ->BVQ_CDCOMP"	},;
											 {"BVT_LOTE",	"BVQ->BVQ_LOTE"		},;
											 {"BVT_DTPRGU",	"BVQ->BVQ_DTPRGU"	}},;        
											BVT->(IndexKey(1)))


	oModel:GetModel( 'BVQMASTER' ):SetDescription( "Fornecimento Direto")
	oModel:GetModel( 'BVTDETAIL' ):SetDescription( "Eventos Fornecimento Direto")

	oModel:SetDescription( "Fornecimento Direto" )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Descricao: Cria a View da Rotina.
@author Hermiro Júnior
@since 29/08/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( 'CENMVCBVQ' )
	Local oStruBVQ 	:= FWFormStruct( 2, 'BVQ' ) 
	Local oStruBVT 	:= FWFormStruct( 2, 'BVT' ) 
	Local oView    	:= FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BVQ' , oStruBVQ, 'BVQMASTER' )
	oView:AddGrid( 'VIEW_BVT'  , oStruBVT, 'BVTDETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )
	
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_BVQ', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_BVT', 'INFERIOR' )

	//Insiro descrições nas views
	oView:EnableTitleView( 'VIEW_BVQ', "Dados Fornecimento Direto" )
	oView:EnableTitleView( 'VIEW_BVT', "Eventos Fornecimento Direto" )

	//Fechar a janela na confirmação
	oView:SetCloseOnOk({||.T.})
	oView:AddUserButton( 'Criticas Vld'	, 'CLIPS', {|oView| VisCriForn(.F.,"1")} )
	oView:AddUserButton( 'Criticas XTR'	, 'CLIPS', {|oView| VisCriForn(.F.,"3")} )

	//Remove campos da chave primaria
	oStruBVT:RemoveField( 'BVT_FILIAL' )
	oStruBVT:RemoveField( 'BVT_CODOPE' )
	oStruBVT:RemoveField( 'BVT_NMGPRE' )
	oStruBVT:RemoveField( 'BVT_CDOBRI' )
	oStruBVT:RemoveField( 'BVT_ANO' )
	oStruBVT:RemoveField( 'BVT_CDCOMP' )
	oStruBVT:RemoveField( 'BVT_LOTE' )
	oStruBVT:RemoveField( 'BVT_DTPRGU' )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} VldGuiaForn
Descricao: Validação da Guia de Fornecimento Direto 

@author Hermiro Júnior
@since 02/09/2019
@version 1.0

@Param: Numero da Guia = BVQ_NMGPRE

/*/
//-------------------------------------------------------------------
Function VldGuiaForn(cNumGuia,lAutom)
	Default lAutom		:= .F. 

	If lAutom .Or. MsgYesNo("Este processo irá validar todos as guias pendentes em segundo plano. Deseja continuar?")
		Msginfo("Processo iniciado. Para acompanhar o andamento da validação, atualize a tela.")
		StartJob("BVQVldJob",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.T.,BVQ->BVQ_CODOPE)
		DelClassIntf()
	else
		Msginfo("O Job sera processado posteriormente de acordo com a parametrizacao.")
	EndIf

Return

Function BVQVldJob(cEmp, cFil, lJob, cCodOpe)
	Local aSvcVldr      := {}
	Local aSvcVlInd     := {}
	Default lJob := .T.
	
	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf
                    
	aSvcVldr  := {SvcVlGrFDi():New(),SvcVlGrItF():New()}
	aSvcVlInd := {SVCVLINFDI():New(),SvcVlItFDi():New()}
	ExecVldMon(cCodOpe,aSvcVldr,aSvcVlInd,cEmp, cFil)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HisGuiBvq
Descricao: Visualização Guias com o mesmo número de guia

@author Vinícius Nicolau
@since 08/09/2020
@version 1.0

@Param: cGuia 	-> Numero da Guia que será inserida no Filtro do Browse
		lAutom		-> .T. - Automação de Testes | .F. = Chamada da Função padrão.
/*/
//-------------------------------------------------------------------
Function HisGuiBvq(cGuia,lAutom)

	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Histórico de Guias" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "BVQ"
    Private oDlgIdVlr
	Private aRotina	:=	{}
	Default cGuia	:= ''
	Default lAutom		:= .F.

	aAdd( aRotina, { "Críticas Guia", 'VisCriForn(.F.,"1")'	 , 0 , 7 , 0 , Nil } ) // Visualização das Criticas
	aAdd( aRotina, { "Críticas XTR"	, 'VisCriForn(.F.,"3")'	 , 0 , 7 , 0 , Nil } ) // Visualização das Criticas
    aAdd( aRotina, { "Visualizar"  	, 'VIEWDEF.CENMVCBVQ', 0 , 2 , 0 , Nil } ) // Visualização   das Guias

    (cAlias)->(dbSetOrder(1))

	If !Empty(cGuia)
		cFiltro		:= "BVQ_FILIAL==xFilial('BVQ') .AND. BVQ_NMGPRE =='"+cGuia+"' "
	EndIf

	If !lAutom

		Define MsDialog oDlgIdVlr Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgIdVlr, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf 

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )
	oBrowse:SetProfileID( 'HistGuiaBVQ' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	oBrowse:AddLegend( "BVQ_STATUS=='1'", "YELLOW"	, "Pendente Validação" )
	oBrowse:AddLegend( "BVQ_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "BVQ_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "BVQ_STATUS=='4'", "ORANGE"	, "Em processamento ANS" )
	oBrowse:AddLegend( "BVQ_STATUS=='5'", "BLACK" 	, "Criticado pela ANS" )
	oBrowse:AddLegend( "BVQ_STATUS=='6'", "GREEN" 	, "Finalizado" )	
	oBrowse:AddLegend( "BVQ_STATUS=='7'", "WHITE"	, "Pendente Geração do Arquivo" )
	oBrowse:AddLegend( "BVQ_STATUS=='8'", "PINK" 	, "Arquivo Gerado" )

	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgIdVlr Center
	EndIf 

Return



//-------------------------------------------------------------------
/*/{Protheus.doc}
Descricao:  Visualização das Criticas das Guias de Fornecimento Direto. 

@author Hermiro Júnior
@since 02/09/2019
@version 1.0

@Param: Numero da Guia = BVQ_NMGPRE

/*/
//-------------------------------------------------------------------
Function VisCriForn(lAuto,cTipo)

	Local cFiltro := " B3F_FILIAL = '" + xFilial( 'B3F' ) + "' .AND. " +;
			   		" B3F_TIPO = '" + cTipo + "' .AND. " +;
			   		" B3F_ORICRI $ 'BVQ,BVT' .AND. SubStr(B3F_IDEORI,1,56) = '" + BVQ->(BVQ_CODOPE+BVQ_NMGPRE+BVQ_CDOBRI+BVQ_ANO+BVQ_CDCOMP+BVQ_LOTE)+DTOS(BVQ->(BVQ_DTPRGU)) + "'" 
	
	Default cTipo := "1"
	Default lAuto := .F.

	If(!lAuto)
		PLBRWCrit(cFiltro, lAuto)
	EndIf		
Return 
