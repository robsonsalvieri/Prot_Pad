#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"

//Utilização do E

//-------------------------------------------------------------------
/*/{Protheus.doc} CENMVCBKR
Descricao: Rotina de Movimentação das Guias Processadas. 

@author Hermiro Júnior
@since 22/08/2019
@version 1.0

@Param: cFiltro -> Filtro do mBrowse vinda do Fonte CENMVCBKR

/*/
//-------------------------------------------------------------------

Function CENMVCBKR(cFiltro,lAutom)

    Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Movimentação de Guias" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "BKR"
	
    Private oDlgBKR
	Private aRotina	:= {}

	Default cFiltro	:= 	" BKR_FILIAL = xFilial( 'BKR' ) .AND. " +;
						" BKR_CODOPE = B3D->B3D_CODOPE .AND. " +;
						" BKR_CDOBRI = B3D->B3D_CDOBRI .AND. " +;
						" BKR_ANO = B3D->B3D_ANO .AND. " +;
						" BKR_CDCOMP = B3D->B3D_CODIGO "

    (cAlias)->(dbSetOrder(1))

	If !lAutom
		Define MsDialog oDlgBKR Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgBKR, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )

	oBrowse:AddLegend( "BKR_STATUS=='1'", "YELLOW"	, "Pendente Validação" )
	oBrowse:AddLegend( "BKR_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "BKR_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "BKR_STATUS=='4'", "ORANGE"	, "Em processamento ANS" )
	oBrowse:AddLegend( "BKR_STATUS=='5'", "BLACK" 	, "Criticado pela ANS" )
	oBrowse:AddLegend( "BKR_STATUS=='6'", "GREEN" 	, "Finalizado" )	
	oBrowse:AddLegend( "BKR_STATUS=='7'", "WHITE"	, "Pendente Geração do Arquivo" )
	oBrowse:AddLegend( "BKR_STATUS=='8'", "PINK" 	, "Arquivo Gerado" )

	oBrowse:SetMenuDef( 'CENMVCBKR' )
	oBrowse:SetProfileID( 'CENMVCBKR' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgBKR Center
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

	
    aAdd( aRotina, { "Validar Guias"	    , 'CenVldGuia(.F.)'			, 0 , 7 , 0 , Nil } ) // Validação      das Guias 
    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCBKR'					, 0 , 2 , 0 , Nil } ) // Visualização   das Guias
    aAdd( aRotina, { "Historico Guia"	    , 'HistGuias(BKR->BKR_NMGOPE,.F.)'	, 0 , 7 , 0 , Nil } ) // Histórico das Guias 
    aAdd( aRotina, { "Críticas Guia"	    , 'CenCritBKR(.F.,"1")'					, 0 , 7 , 0 , Nil } ) // Críticas    
    aAdd( aRotina, { "Criticas XTR"	    	, 'CenCritBKR(.F.,"3")'					, 0 , 7 , 0 , Nil } ) // Críticas
	aAdd( aRotina, { "Beneficiário"	    	, 'CenMosBen(BKR->BKR_CODOPE,BKR->BKR_MATRIC,.F.)' , 0 , 2 , 0 , Nil } ) // Beneficiário  

Return aRotina

Function CenCritBKR(lAuto,cTipo)
	Local cFiltro := " B3F_FILIAL = '" + xFilial( 'B3F' ) + "' .AND. " +;
			   		" B3F_TIPO = '" + cTipo + "' .AND. " +;
			   		"  B3F_ORICRI $ 'BKR,BKS,BKT' .AND. SubStr(B3F_IDEORI,1,56) = '" + BKR->(BKR_CODOPE+BKR_NMGOPE+BKR_CDOBRI+BKR_ANO+BKR_CDCOMP+BKR_LOTE+DtoS(BKR_DTPRGU)) + "'" 
	
	Default cTipo := "1"
	Default lAuto := .F.

	If(!lAuto)
		PLBRWCrit(cFiltro, lAuto)
	EndIf		
Return 

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

	Local oStrBKR	:= FwFormStruct(1,'BKR')
	Local oStrBKS	:= FwFormStruct(1,'BKS')
	Local oStrBKT	:= FwFormStruct(1,'BKT')

	//Instancia do Objeto de Modelo de Dados
	oModel := MPFormModel():New('CENMVCBKR')
	oModel:AddFields( 'BKRMASTER', NIL, oStrBKR )
	oModel:AddGrid( 'BKSDETAIL', 'BKRMASTER', oStrBKS )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'BKSDETAIL',  { 	{ 'BKS_FILIAL'	, 'xFilial( "BKR" )' },;
											{ 'BKS_CODOPE' 	, 'BKR_CODOPE' },;
											{ 'BKS_NMGOPE' 	, 'BKR_NMGOPE' },;
											{ 'BKS_CDOBRI' 	, 'BKR_CDOBRI' },;
											{ 'BKS_ANO' 	, 'BKR_ANO'    },;
											{ 'BKS_CDCOMP' 	, 'BKR_CDCOMP' },;
											{ 'BKS_LOTE' 	, 'BKR_LOTE'   },;
											{ 'BKS_DTPRGU' 	, 'BKR_DTPRGU' };
										}, BKS->( IndexKey( 1 ) ) )

	oModel:GetModel( 'BKRMASTER' ):SetDescription( "Movimentações" ) 
	oModel:GetModel( 'BKSDETAIL' ):SetDescription( "Eventos" ) 
	oModel:SetDescription( "Movimentações" )
	
	oModel:addGrid('BKTDETAIL','BKSDETAIL',oStrBKT) 
	oModel:getModel("BKTDETAIL"):SetOptional(.T.)
	oModel:getModel('BKTDETAIL'):SetDescription('Pacotes')     						
	oModel:setRelation("BKTDETAIL", ;     
											{	{"BKT_FILIAL"	,'xFilial("BKS")'	},;
												{"BKT_CODOPE"	,'BKS_CODOPE' },;
												{"BKT_NMGOPE" 	,'BKS_NMGOPE' },;
												{"BKT_CDOBRI"	,'BKS_CDOBRI' },;
												{"BKT_ANO"		,'BKS_ANO'	  },;
												{"BKT_CDCOMP"	,'BKS_CDCOMP' },;
												{"BKT_LOTE"		,'BKS_LOTE'	  },;
												{"BKT_DTPRGU"	,'BKS_DTPRGU' },;
												{"BKT_CODTAB"   ,'BKS_CODTAB' },;
												{"BKT_CODPRO"   ,'BKS_CODPRO' };
											}, BKT->(IndexKey(1)))

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Descricao: Cria a View da Rotina.
@author Hermiro Júnior
@since 22/08/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel   	:= FWLoadModel( 'CENMVCBKR' )
	Local oStruBKR 	:= FWFormStruct( 2, 'BKR' ) 
	Local oStruBKS 	:= FWFormStruct( 2, 'BKS' )
	Local oStruBKT 	:= FWFormStruct( 2, 'BKT' )
	Local oView    	:= FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BKR' , oStruBKR, 'BKRMASTER' )
	
	oView:AddGrid( 'VIEW_BKS'  , oStruBKS, 'BKSDETAIL' )
	oView:AddGrid( 'VIEW_BKT'  , oStruBKT, 'BKTDETAIL' )
			
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
	oView:SetOwnerView( 'VIEW_BKR', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_BKS', 'BOX_EVEN' )
	oView:SetOwnerView( 'VIEW_BKT', 'BOX_PAC' )

	//Insiro descrições nas views
	oView:EnableTitleView( 'VIEW_BKR', "Dados Guia de Movimentação" )
	oView:EnableTitleView( 'VIEW_BKS', "Eventos" )
	oView:EnableTitleView( 'VIEW_BKT', "Pacotes" )

	oView:AddUserButton( 'Declar. Nascidos/Óbitos'	, 'CLIPS', {|oView| PlSBKRDECL()} )
	oView:AddUserButton( 'Histórico Guia'	, 'CLIPS', {|oView| HISTGUIAS(BKR->BKR_NMGOPE)} )
	oView:AddUserButton( 'Criticas Guia'	, 'CLIPS', {|oView| alert("Criticas Guia")} )

	//Remove campos da chave primaria - BKS
	oStruBKS:RemoveField( 'BKS_FILIAL' )
	oStruBKS:RemoveField( 'BKS_CODOPE' )
	oStruBKS:RemoveField( 'BKS_NMGOPE' )
	oStruBKS:RemoveField( 'BKS_CDOBRI' )
	oStruBKS:RemoveField( 'BKS_ANO' )
	oStruBKS:RemoveField( 'BKS_CDCOMP' )
	oStruBKS:RemoveField( 'BKS_LOTE' )
	oStruBKS:RemoveField( 'BKS_DTPRGU' )
	
	//Remove campos da chave primaria - BKT
	oStruBKT:RemoveField( 'BKT_FILIAL' )
	oStruBKT:RemoveField( 'BKT_CODOPE' )
	oStruBKT:RemoveField( 'BKT_NMGOPE' )
	oStruBKT:RemoveField( 'BKT_CDOBRI' )
	oStruBKT:RemoveField( 'BKT_ANO' )
	oStruBKT:RemoveField( 'BKT_CDCOMP' )
	oStruBKT:RemoveField( 'BKT_LOTE' )
	oStruBKT:RemoveField( 'BKT_DTPRGU' )
	oStruBKT:RemoveField( 'BKT_CODTAB' )
	oStruBKT:RemoveField( 'BKT_CODPRO' )
	

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldGuia
Descricao:  Rotina de validação da Guia.

@author Hermiro Júnior
@since 26/08/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function CenVldGuia(lAutom)
	Default lAutom		:= .F. 

	If lAutom .Or. MsgYesNo("Este processo irá validar todos as guias pendentes em segundo plano. Deseja continuar?")
		Msginfo("Processo iniciado. Para acompanhar o andamento da validação, atualize a tela.")
		StartJob("BKRVldJob",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.T.,BKR->BKR_CODOPE)
		DelClassIntf()
	else
		Msginfo("O Job sera processado posteriormente de acordo com a parametrizacao.")
	EndIf

Return

Function BKRVldJob(cEmp, cFil, lJob, cCodOpe)
	Local aSvcVldr      := {}
	Local aSvcVlInd     := {}
	Default lJob := .T.
	
	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf
                    
	aSvcVldr  := {SvcVlMGGrp():New(),SvcVlGrItG():New(),SvcVlGrPcG():New()}
	aSvcVlInd := {SVCVLINGMO():New(),SvcVlInItG():New(),SvcVlInPcG():New()}
	ExecVldMon(cCodOpe,aSvcVldr,aSvcVlInd,cEmp, cFil)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} HISTGUIAS
Descricao: Mostra as Guias Filtradas escolhidas pelo usuário. 

@author Hermiro Júnior
@since 26/08/2019
@version 1.0

@Param:
	xGuia -> Numero da Guia que será inserida no Filtro do Browse

/*/
//-------------------------------------------------------------------
Function HistGuias(xGuia,lAutom)

	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Histórico de Guias" 
    Local oPnl
	Local oBrowse
	Local cAlias	:= "BKR"
	Local cFiltro	:= ''
	
    Private oDlgHist

	Default xGuia	:= ''
	Default lAutom	:= .F.

	Private aRotina	:=	{}

	// Adiciona a Rotina ao Menu
	aAdd( aRotina, { "Visualizar"	, 'VIEWDEF.CENMVCBKR', 0 , 2 , 0 , Nil } ) // Visualização   das Guias
	aAdd( aRotina, { "Críticas Guia", 'PlCenFilCri("BKR", BKR->(Recno()), .F.)'	 , 0 , 7 , 0 , Nil } ) // Visualização das Criticas
   
    (cAlias)->(dbSetOrder(1))

	//Defino o Filtro Padrão
	If !Empty(xGuia) 
		cFiltro		:= "BKR_FILIAL==xFilial('BKR') .AND. BKR_NMGOPE=='"+xGuia+"' "
	EndIf

	// Cria a Tela do Browse
	If !lAutom
		Define MsDialog oDlgHist Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgHist, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	oBrowse:= FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )
	oBrowse:SetProfileID( 'HistGuias' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)

	oBrowse:AddLegend( "BKR_STATUS=='1'", "YELLOW"	, "Pendente Validação" )
	oBrowse:AddLegend( "BKR_STATUS=='2'", "BLUE"  	, "Pronto para o Envio" )
	oBrowse:AddLegend( "BKR_STATUS=='3'", "RED"   	, "Criticado" )
	oBrowse:AddLegend( "BKR_STATUS=='4'", "ORANGE"	, "Em processamento ANS" )
	oBrowse:AddLegend( "BKR_STATUS=='5'", "BLACK" 	, "Criticado pela ANS" )
	oBrowse:AddLegend( "BKR_STATUS=='6'", "GREEN" 	, "Finalizado" )	
	oBrowse:AddLegend( "BKR_STATUS=='7'", "WHITE"	, "Pendente Geração do Arquivo" )
	oBrowse:AddLegend( "BKR_STATUS=='8'", "PINK" 	, "Arquivo Gerado" )

	If !lAutom
		oBrowse:Activate()
		Activate MsDialog oDlgHist Center
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlSBKRDECL
Descricao: Visualiza as declaracoes de nascidos e obitos

@author Sakai
@since 06/01/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function PlSBKRDECL(lAuto)

	Local oCltBN0   := CenCltBN0():New()
	Local aDadosBN0 := {}
	Local cTipo   := ""
	Local cNumero := ""
	Default lAuto := .F.

    oCltBN0:setValue("referenceYear"     ,BKR->BKR_ANO)
    oCltBN0:setValue("commitmentCode"    ,BKR->BKR_CDCOMP)
    oCltBN0:setValue("requirementCode"   ,BKR->BKR_CDOBRI)
    oCltBN0:setValue("operatorRecord"    ,BKR->BKR_CODOPE)
    oCltBN0:setValue("formProcDt"        ,BKR->BKR_DTPRGU)
    oCltBN0:setValue("batchCode"         ,BKR->BKR_LOTE)
    oCltBN0:setValue("operatorFormNumber",BKR->BKR_NMGOPE)
   	
	if oCltBN0:buscar()
		while oCltBN0:HasNext()
            oDeclar := oCltBN0:GetNext()
            cTipo   := iif(oDeclar:getValue("certificateType")=="1","Nascido","Obito")
			cNumero := oDeclar:getValue("certificateNumber")
			aadd(aDadosBN0,{cTipo,cNumero})
            oDeclar:destroy()
        endDo
	endIf
	oCltBN0:destroy()

	if len(aDadosBN0) > 0
		iif(lAuto,nil,PLSCRIGEN(aDadosBN0,{ {"Tipo Declaração","@C",90} , {"Número","@C",80 } },"Declarações Nascidos/Óbitos"))
	else 
		iif(lAuto,Conout("Esta guia não tem declarações de nascidos/óbitos."),Aviso("Atenção","Esta guia não tem declarações de nascidos/óbitos.",{ "Ok" }, 2 )) 
	endIf

Return



//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenExiCad

Funcao criada para exibir as telas de cadastros de beneficiario.

@author José Paulo
@since 10/06/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CenMosBen(cCodope,cMatric,lAuto)
	Local lOk       := .F.
	Default cCodope := ""
	Default lAuto 	:= .F.
	Default lAuto 	:= .F.
	Default cBene 	:= ""

	B3K->(DBSetOrder(1))

	If !Empty(cMatric)
		lOk:=B3K->(MsSeek(xFilial("B3K")+cCodope+PADR(cMatric,tamSX3("B3K_MATRIC")[1])))
	endIf

	If !lAuto
		If !lOk 
			MSGINFO("Beneficiário não encontrado!")
		else				
			FWExecView('Visualização',"PLSMVCBENE",MODEL_OPERATION_VIEW)		
		EndIf
	EndIf

Return lOk

