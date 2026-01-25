#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCBVZ
Descricao:  Rotina MVC de Outra Remuneração referente ao Projeto de 
            Monitoramento TISS.

@author Hermiro Júnior
@since 29/08/2019
@version 1.0

@Param: cFiltro -> Filtro do mBrowse vinda do Fonte CENMVCBVZ

/*/
//-------------------------------------------------------------------
Function CENMVCBVZ(cFiltro,lAutom)

    Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Outra Remuneração" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "BVZ"
	
    Private oDlgBVZ
	Default lAutom	:= .F.
	Default cFiltro	:= 	" BVZ_FILIAL = xFilial( 'BVZ' ) .AND. " +;
						" BVZ_CODOPE = B3D->B3D_CODOPE .AND. " +;
						" BVZ_CDOBRI = B3D->B3D_CDOBRI .AND. " +;
						" BVZ_ANO = B3D->B3D_ANO .AND. " +;
						" BVZ_CDCOMP = B3D->B3D_CODIGO "

    (cAlias)->(dbSetOrder(1))

	// Desvio para Contemplar a Cobertura de Testes
	If !lAutom
		Define MsDialog oDlgBVZ Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgBVZ, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf 

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )

	oBrowse:AddLegend( "BVZ_STATUS=='1'", "YELLOW"	, "Pendente Validação" )
	oBrowse:AddLegend( "BVZ_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "BVZ_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "BVZ_STATUS=='4'", "ORANGE"	, "Em processamento ANS" )
	oBrowse:AddLegend( "BVZ_STATUS=='5'", "BLACK" 	, "Criticado pela ANS" )
	oBrowse:AddLegend( "BVZ_STATUS=='6'", "GREEN" 	, "Finalizado" )	
	oBrowse:AddLegend( "BVZ_STATUS=='7'", "WHITE"	, "Pendente Geração do Arquivo" )
	oBrowse:AddLegend( "BVZ_STATUS=='8'", "PINK" 	, "Arquivo Gerado" )

	oBrowse:SetMenuDef( 'CENMVCBVZ' )
	oBrowse:SetProfileID( 'CENMVCBVZ' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	
	// Desvio para Contemplar a Cobertura de Testes
	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgBVZ Center
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

    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCBVZ'		, 0 , 2 , 0 , Nil } ) // Visualização   das Guias
	aAdd( aRotina, { "Validar Guias"		, 'VldOutRem()'				, 0 , 2 , 0 , Nil } ) // Validacao da Outras Remunerações
	aAdd( aRotina, { "Críticas Guia"		, 'VisOutRem(.F.,"1")'		, 0 , 2 , 0 , Nil } ) // Visualiza Criticas da Outras Remunerações
	aAdd( aRotina, { "Criticas XTR"			, 'VisOutRem(.F.,"3")'		, 0 , 2 , 0 , Nil } ) // Visualiza Criticas da Outras Remunerações
	aAdd( aRotina, { "Histórico de Guias"	, 'HisGuiBvz(BVZ->BVZ_CPFCNP,.F.)'		, 0 , 2 , 0 , Nil } ) // Visualização das Guias Identificadas como Valor Pre Estabelecido.

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

	Local oStrBVZ	:= FwFormStruct(1,'BVZ')

	//Instancia do Objeto de Modelo de Dados
	oModel := MPFormModel():New('CENMVCBVZ')
	oModel:AddFields( 'BVZMASTER', NIL, oStrBVZ )

	oModel:GetModel( 'BVZMASTER' ):SetDescription( "Outra Remuneração")
	oModel:SetDescription( "Outra Remuneração" )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Descricao: View da Rotina de Outra Remuneração. 

@author Hermiro Júnior
@since 29/08/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   	:= FWLoadModel( 'CENMVCBVZ' )
	Local oStruBVQ 	:= FWFormStruct( 2, 'BVZ' ) 
	Local oView    	:= FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BVZ' , oStruBVQ, 'BVZMASTER' )
	
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_BVZ', 'SUPERIOR' )

	//Insiro descrições nas views
	oView:EnableTitleView( 'VIEW_BVZ', "Dados Outra Remuneração" )

	oView:AddUserButton( 'Criticas Vld'	, 	'CLIPS', {|oView| VisOutRem(.F.,"1")} )
	oView:AddUserButton( 'Criticas XTR'	, 	'CLIPS', {|oView| VisOutRem(.F.,"3")} )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} VldOutRem
Descricao: Validação de Outras Remunerações

@author Hermiro Júnior
@since 02/09/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function VldOutRem(lAutom)
	Default lAutom		:= .F. 

	If lAutom .Or. MsgYesNo("Este processo irá validar todos as guias pendentes em segundo plano. Deseja continuar?")
		Msginfo("Processo iniciado. Para acompanhar o andamento da validação, atualize a tela.")
		StartJob("BVZVldJob",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.T.,BVZ->BVZ_CODOPE)
		DelClassIntf()
	else
		Msginfo("O Job sera processado posteriormente de acordo com a parametrizacao.")
	EndIf

Return

Function BVZVldJob(cEmp, cFil, lJob, cCodOpe)
	Local aSvcVldr      := {}
	Local aSvcVlInd     := {}
	Default lJob := .T.
	
	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf
                    
	aSvcVldr  := {SvcVlGrORe():New()}
	aSvcVlInd := {SVCVLINORE():New()}
	ExecVldMon(cCodOpe,aSvcVldr,aSvcVlInd,cEmp, cFil)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HisGuiBvz
Descricao: Visualização Guias com o mesmo CPF/CNPJ

@author Vinícius Nicolau
@since 08/09/2020
@version 1.0

@Param: cIdCpf 	-> Campo CPF/CNPJ da tabela BVZ
		lAutom		-> .T. - Automação de Testes | .F. = Chamada da Função padrão.
/*/
//-------------------------------------------------------------------
Function HisGuiBvz(cIdCpf,lAutom)

	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Histórico de Guias" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "BVZ"
    Private oDlgIdVlr
	Private aRotina	:=	{}
	Default cIdCpf	:= ''
	Default lAutom		:= .F.

	aAdd( aRotina, { "Críticas Guia", 'VisOutRem(.F.,"1")'	 , 0 , 7 , 0 , Nil } ) // Visualização das Criticas
	aAdd( aRotina, { "Críticas XTR", 'VisOutRem(.F.,"3")'	 , 0 , 7 , 0 , Nil } ) // Visualização das Criticas
    aAdd( aRotina, { "Visualizar"  , 'VIEWDEF.CENMVCBVZ', 0 , 2 , 0 , Nil } ) // Visualização   das Guias

    (cAlias)->(dbSetOrder(1))

	If !Empty(cIdCpf)
		cFiltro		:= "BVZ_FILIAL==xFilial('BVZ') .AND. BVZ_CPFCNP =='"+cIdCpf+"' "
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
	oBrowse:SetProfileID( 'HistGuiaBVZ' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	oBrowse:AddLegend( "BVZ_STATUS=='1'", "YELLOW"	, "Pendente Validação" )
	oBrowse:AddLegend( "BVZ_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "BVZ_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "BVZ_STATUS=='4'", "ORANGE"	, "Em processamento ANS" )
	oBrowse:AddLegend( "BVZ_STATUS=='5'", "BLACK" 	, "Criticado pela ANS" )
	oBrowse:AddLegend( "BVZ_STATUS=='6'", "GREEN" 	, "Finalizado" )	
	oBrowse:AddLegend( "BVZ_STATUS=='7'", "WHITE"	, "Pendente Geração do Arquivo" )
	oBrowse:AddLegend( "BVZ_STATUS=='8'", "PINK" 	, "Arquivo Gerado" )

	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgIdVlr Center
	EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}
Descricao:  Visualização das Criticas das Guias de Outras Remunerações

@author Everton Mateus
@since 02/09/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function VisOutRem(lAuto,cTipo)

	Local cFiltro := " B3F_FILIAL = '" + xFilial( 'B3F' ) + "' .AND. " +;
			   		" B3F_TIPO = '" + cTipo + "' .AND. " +;
			   		" B3F_ORICRI $ 'BVZ' .AND. SubStr(B3F_IDEORI,1,50) = '" + BVZ->(BVZ_CODOPE+BVZ_CPFCNP+BVZ_CDOBRI+BVZ_ANO+BVZ_CDCOMP+BVZ_LOTE)+DTOS(BVZ->BVZ_DTPROC) + "'" 
	
	Default cTipo := "1"
	Default lAuto := .F.

	If(!lAuto)
		PLBRWCrit(cFiltro, lAuto)
	EndIf		
Return 