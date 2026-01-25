#INCLUDE "GFEA061F.ch"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lPE613		:= ExistBlock("GFEA0613")
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA061F 
Tarifa da tabela de frete.
Uso Generico.

@param  lFiltGV9        Inicia com filtro default

@sample
GFEA061F(lFiltGV9)

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA061F()
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cCdEmitente
	Local cDsEmitente
	Local cCdTabela	
	Local cNrNeg		
	Local cClassFrt	
	Local cTipoOper	
	Local cLotacao	
	Local oPanelCabecalho
	Local aLotacao := STRToKArr(Posicione("SX3", 2, "GV9_TPLOTA", "X3CBOX()"),";")
	Local cFunBkp := FunName()

	// Workaround para executar o MenuDef() correto.
	// Assim considera os privilégios específicos setados no SIGACFG.
	SetFunName("GFEA061F")
	
	Private oBrwTabFrete, oBrwNeg
	
	cCdEmitente := GV9->GV9_CDEMIT
	cDsEmitente := Posicione("GU3", 1, xFilial("GU3") + cCdEmitente, "GU3_NMEMIT")
	cCdTabela	:= GV9->GV9_NRTAB
	cNrNeg		:= GV9->GV9_NRNEG
	cClassFrt	:= POSICIONE("GUB", 1 ,xFilial("GUB") + GV9->GV9_CDCLFR, "GUB_DSCLFR")
	cTipoOper	:= POSICIONE("GV4", 1, xFilial("GV4") + GV9->GV9_CDTPOP, "GV4_DSTPOP")
	cLotacao	:= ""
	cVigDe		:= DToC(GV9->GV9_DTVALI)
	cVigAte		:= DToC(GV9->GV9_DTVALF)
	
	If !Empty(GV9->GV9_TPLOTA)
		cLotacao := SubStr(aLotacao[Val(AllTrim(GV9->GV9_TPLOTA))], 3)
	EndIf


	Define MsDialog oDialog61F Title "Tarifas da Tabela de Frete" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		/* -- Layers -------------------------------------------------- */
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDialog61F, .F., .T.)
		
		// Cabeçalho
		oFWLayer:AddLine('TOP', 30, .T.)
		oFWLayer:AddCollumn('TABFRETE', 100, .T., 'TOP') // Tabela de Frete
		oFWLayer:AddWindow('TABFRETE', 'TABFRETEWIN', "Negociação", 100, .F., .F., /*bAction*/, 'TOP')
		oLayerCabecalho := oFWLayer:GetWinPanel('TABFRETE', 'TABFRETEWIN', 'TOP')
		
		// Tarifas
		oFWLayer:AddLine('BOTTON', 70, .F.) 
		oFWLayer:AddCollumn('NEGOC', 100, .T., 'BOTTON') // Negociação
		oLayerTarifas := oFWLayer:GetColPanel('NEGOC', 'BOTTON')
		
		oPanelCabecalho := TScrollBox():Create(oLayerCabecalho,01,01,10,10,.T.,.T.,.T.)
		oPanelCabecalho:Align := CONTROL_ALIGN_ALLCLIENT
		
		
		@ 005, 005 SAY oSay3 PROMPT "Emitente"  	SIZE 037, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 013, 005 MSGET oCdTransp 	VAR cCdEmitente SIZE 055, 010 OF oPanelCabecalho READONLY PIXEL
		
		@ 005, 070 SAY oSay3 PROMPT "Nome"  		SIZE 037, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 013, 070 MSGET oDsTransp 	VAR cDsEmitente SIZE 135, 010 OF oPanelCabecalho READONLY PIXEL
		
		@ 005, 215 SAY oSay3 PROMPT "Tabela"  		SIZE 037, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 013, 215 MSGET oCdTabela 	VAR cCdTabela 	SIZE 037, 010 OF oPanelCabecalho READONLY PIXEL
		
		@ 035, 005 SAY oSay3 PROMPT "Negociação"  	SIZE 037, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 043, 005 MSGET oNrNeg    	VAR cNrNeg 		SIZE 055, 010 OF oPanelCabecalho READONLY PIXEL
		
		@ 035, 070 SAY oSay3 PROMPT "Class. Frete" 	SIZE 040, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 043, 070 MSGET oClassFrt 	VAR cClassFrt	SIZE 135, 010 OF oPanelCabecalho READONLY PIXEL
		
		@ 035, 215 SAY oSay3 PROMPT "Tipo de Operação"	SIZE 050, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 043, 215 MSGET oTipoOper 	VAR cTipoOper 	SIZE 135, 010 OF oPanelCabecalho READONLY PIXEL
		
		@ 035, 360 SAY oSay3 PROMPT "Lotação"		SIZE 050, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 043, 360 MSGET oLotacao 	VAR cLotacao 	SIZE 100, 010 OF oPanelCabecalho READONLY PIXEL
		
		@ 065, 005 SAY oSay3 PROMPT "Vigência De"  	SIZE 037, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 073, 005 MSGET oVigDe 	VAR cVigDe 		SIZE 050, 010 OF oPanelCabecalho READONLY PIXEL
		oVigDe:SetContentAlign(0)
		
		
		@ 065, 070 SAY oSay3 PROMPT "Vigência Até"  SIZE 037, 007 OF oPanelCabecalho COLORS RGB(0, 74, 119), 16777215 PIXEL
		@ 073, 070 MSGET oVigAte 	VAR cVigAte 	SIZE 050, 010 OF oPanelCabecalho READONLY PIXEL
		oVigAte:SetContentAlign(0)
		
	     
		/* -- Browse -------------------------------------------------- */
		oBrwTarifas := FWMBrowse():New()
		oBrwTarifas:SetOwner(oLayerTarifas)
		oBrwTarifas:SetDescription("Tarifa da Tabela de Frete")
		oBrwTarifas:SetAlias('GV6')
		oBrwTarifas:SetFilterDefault("GV6_FILIAL == '" + GV9->GV9_FILIAL + "' .AND. GV6_CDEMIT == '" + GV9->GV9_CDEMIT + "' .AND. GV6_NRTAB == '" + GV9->GV9_NRTAB + "' .AND. GV6_NRNEG == '" + GV9->GV9_NRNEG + "'")
		oBrwTarifas:SetIgnoreARotina(.T.) 	// Ignora aRotina na construção das opções de menu
		oBrwTarifas:SetMenuDef("GFEA061F")
		oBrwTarifas:SetProfileID("3")
		oBrwTarifas:ForceQuitButton(.T.)
		oBrwTarifas:DisableDetails()
		oBrwTarifas:SetAmbiente(.F.)
		oBrwTarifas:SetWalkthru(.F.)	

		oBrwTarifas:Activate()
	Activate MsDialog oDialog61F Center	
	
	SetFunName(cFunBkp)
	
Return(Nil)


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} MenuDef
Definição de Menu

@author Frete Embarcador
@since 14/10/09
@version 1.0
-------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {}
	Local lGFEA61F1 := ExistBlock("GFEA61F1")

	ADD OPTION aRotina TITLE STR0002 ACTION "GFE61FPESQ()"     OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "GFE61FVIS()"      OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "GFE61FINC()"      OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005 ACTION "GFE61FALT()"      OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006 ACTION "GFE61FEXC()"      OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE "Copiar" ACTION "GFE61FCOPY()"/*"GFEA61COPY()"*/ OPERATION 9 ACCESS 0 //"Copiar"
	
	If IsInCallStack("GFEA061") .Or. IsInCallStack("SIGACFG")		// Executado pelo "SIGACFG -> Usuários -> Senhas -> Privilégios"
		ADD OPTION aRotina TITLE "Gerar Tarifas" ACTION "GFEA61FTAR()" OPERATION 3 ACCESS 0
	EndIf
	
	ADD OPTION aRotina TITLE "Excluir em Lote" ACTION "GFEA061LOT()" OPERATION 3 ACCESS 0	
	
	If lGFEA61F1
		aRotAdic := ExecBlock("GFEA61F1",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf

Return aRotina


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} ModelDef
Definição do Model

@author Frete Embarcador
@since 14/10/09
@version 1.0
-------------------------------------------------------------------*/

Static Function ModelDef()
	Local oModel
	
	oModel := MPFormModel():New("GFEA061F", /*bPre*/, {|oX|GFE61FPOS(oX)},{|oX|GFE61FCOM(oX)}, /*bCancel*/)
	oModel:AddFields("GFEA061F_GV6", Nil, FWFormStruct(1,"GV6"),/*bPre*/,/*bPost*/,/*bLoad*/)
	
	oModel:AddGrid( 'DETAIL_GV1', 'GFEA061F_GV6', FWFormStruct(1,"GV1"), /*bLinePre*/, {|oX| GFE061CTA(oX)},  /*bPreVal*/ , /*bPosVal*/,/*BLoad*/ ) 
	oModel:AddGrid( 'DETAIL_GUC', 'GFEA061F_GV6', FWFormStruct(1,"GUC"), /*bLinePre*/, {|oX| GFE061CEM(oX)}, /*bPreVal*/ , /*bPosVal*/,/*BLoad*/ ) 
	
	oModel:SetRelation('DETAIL_GV1',{{'GV1_FILIAL','xFilial( "GV1" )'},{'GV1_CDEMIT','GV6_CDEMIT'},{'GV1_NRTAB','GV6_NRTAB'},{'GV1_NRNEG','GV6_NRNEG'},{'GV1_CDFXTV','GV6_CDFXTV'},{'GV1_NRROTA','GV6_NRROTA'}},'GV1_CDCOMP') 
	oModel:SetRelation('DETAIL_GUC',{{'GUC_FILIAL','xFilial( "GUC" )'},{'GUC_CDEMIT','GV6_CDEMIT'},{'GUC_NRTAB','GV6_NRTAB'},{'GUC_NRNEG','GV6_NRNEG'},{'GUC_CDFXTV','GV6_CDFXTV'},{'GUC_NRROTA','GV6_NRROTA'}},'GUC_CDCOMP+GUC_EMICOM') 
	
	oModel:GetModel('DETAIL_GV1'):SetDelAllLine(.T.)
	oModel:GetModel('DETAIL_GUC'):SetDelAllLine(.T.)
	
	If !IsBlind()
	 	oModel:GetModel('DETAIL_GV1'):SetMaxLine(9999) 
		oModel:GetModel('DETAIL_GUC'):SetMaxLine(9999) 
	EndIf
	
	oModel:SetOptional('DETAIL_GUC', .T. )
	
	oModel:SetActivate( {|oMod| GFEA61FACT(oMod)} )
	
	oModel:SetVldActivate( {|oMod| GFEA061FA(oMod)} )
	
	oModel:GetModel("DETAIL_GV1"):SetUniqueLine({"GV1_CDCOMP"})
	
	oModel:SetPrimaryKey({"GV6_FILIAL", "GV6_CDEMIT", "GV6_NRTAB", "GV6_NRNEG", "GV6_CDFXTV", "GV6_NRROTA"}) 
Return oModel


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} ViewDef
Definição de View

@author Frete Embarcador
@since 14/10/09
@version 1.0
-------------------------------------------------------------------*/
Static Function ViewDef()
	Local oModel := FWLoadModel("GFEA061F")
	Local oView  := Nil
	Local oStructGV1 := FWFormStruct(2, "GV1")
	Local oStructGUC := FWFormStruct(2, "GUC")
	Local oStructGV6 := FWFormStruct(2,"GV6")
	
	oStructGV6:SetNoFolders()
	oStructGV6:SetNoGroups()
	oStructGV6:AddGroup("TABNE","Tabela e Negociação","",2)
	oStructGV6:AddGroup("COMPO","Composição","",2)
	oStructGV6:AddGroup("FRETE","Frete Mínimo","",2)
	oStructGV6:AddGroup("PRAZO","Prazo de Entrega","",2)
	oStructGV6:AddGroup("CONTR","Controle","",2)
	
	oStructGV6:SetProperty("*",MVC_VIEW_GROUP_NUMBER,"TABNE")
	
	oStructGV6:SetProperty("GV6_CDFXTV",MVC_VIEW_GROUP_NUMBER,"COMPO")
	oStructGV6:SetProperty("GV6_INFFXA",MVC_VIEW_GROUP_NUMBER,"COMPO")
	oStructGV6:SetProperty("GV6_NRROTA",MVC_VIEW_GROUP_NUMBER,"COMPO")
	oStructGV6:SetProperty("GV6_INFROT",MVC_VIEW_GROUP_NUMBER,"COMPO")
	
	oStructGV6:SetProperty("GV6_QTMIN",MVC_VIEW_GROUP_NUMBER,"FRETE")
	oStructGV6:SetProperty("GV6_FRMIN",MVC_VIEW_GROUP_NUMBER,"FRETE")
	oStructGV6:SetProperty("GV6_COMFRG",MVC_VIEW_GROUP_NUMBER,"FRETE")
	
	oStructGV6:SetProperty("GV6_CONSPZ",MVC_VIEW_GROUP_NUMBER,"PRAZO")
	oStructGV6:SetProperty("GV6_TPPRAZ",MVC_VIEW_GROUP_NUMBER,"PRAZO")
	oStructGV6:SetProperty("GV6_QTPRAZ",MVC_VIEW_GROUP_NUMBER,"PRAZO")
	oStructGV6:SetProperty("GV6_CONTPZ",MVC_VIEW_GROUP_NUMBER,"PRAZO")
	
	oStructGV6:SetProperty("GV6_DTATU",MVC_VIEW_GROUP_NUMBER,"CONTR")
	oStructGV6:SetProperty("GV6_HRATU",MVC_VIEW_GROUP_NUMBER,"CONTR")

	//Ponto de entrada
	If ExistBlock("GFEA61F2")
		ExecBlock("GFEA61F2",.f.,.f.,{oStructGV6})
	EndIf	
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA061F_GV6" , oStructGV6, /*cLinkID*/ )	
	oView:AddGrid('VIEW_GV1',oStructGV1,'DETAIL_GV1')
	oView:AddGrid('VIEW_GUC',oStructGUC,'DETAIL_GUC')
	
	
	oStructGV1:RemoveField("GV1_CDEMIT")
	oStructGV1:RemoveField("GV1_NMEMIT")                               	
	oStructGV1:RemoveField("GV1_NRTAB") 
	oStructGV1:RemoveField("GV1_DSTAB") 
	oStructGV1:RemoveField("GV1_NRNEG")   
	oStructGV1:RemoveField("GV1_CDFXTV")   
	oStructGV1:RemoveField("GV1_NRROTA")    
	
	oStructGUC:RemoveField("GUC_CDEMIT")
	oStructGUC:RemoveField("GUC_NMEMIT")                               	
	oStructGUC:RemoveField("GUC_NRTAB") 
	oStructGUC:RemoveField("GUC_DSTAB") 
	oStructGUC:RemoveField("GUC_NRNEG")   
	oStructGUC:RemoveField("GUC_CDFXTV")   
	oStructGUC:RemoveField("GUC_NRROTA") 
	
	oView:CreateHorizontalBox( "MASTER" , 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "DETAIL" , 40,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ ) 
	oView:CreateHorizontalBox( "DETAILTAR" , 100,,,"IDFOLDER","IDSHEET01" ) 
	oView:CreateHorizontalBox( "DETAILEMI" , 100,,,"IDFOLDER","IDSHEET02" )
	
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01",STR0012) //'Componente da Tarifa'
	oView:AddSheet("IDFOLDER","IDSHEET02",STR0013) //'Componentes Adic. Emitente'
	
	oView:SetOwnerView("VIEW_GV1","DETAILTAR")
	oView:SetOwnerView("VIEW_GUC","DETAILEMI")
	
	// Associa um View a um box
	oView:SetOwnerView( "GFEA061F_GV6" , "MASTER" )

Return oView


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61FPOS
Validação de saidA de foco do campo Rota e Sequencia de Frete.
Uso GFEA061F.

@param  oModel  Model principal

@sample
GFE61FPOS(oModel)

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFE61FPOS(oModel)
	Local lRet := .T., lCompGarantia := .F.
	Local nOp  := (oModel:getOperation())
	Local oModelPai := FWMODELACTIVE()
	Local oModelGV1 := oModelPai:GetModel('DETAIL_GV1')
	Local nI  
	Local cCalcs := ""
	Local cCont  := 0
	Local cQuery := ""
		
	// Se for inclusao ou alteração
	If nOp == MODEL_OPERATION_INSERT .OR. nOp == MODEL_OPERATION_UPDATE
		//o campo "GV6_COMFRG", quando informado, verificando se o mesmo consta entre os componentes da tarifa.
		If !Empty(oModel:GetValue( 'GFEA061F_GV6', 'GV6_COMFRG' ))
			For nI := 1 To oModelGV1:GetQtdLine() 
				oModelGV1:GoLine( nI ) 
				If FwFldGet("GV1_CDCOMP",nI) == oModel:GetValue( 'GFEA061F_GV6', 'GV6_COMFRG' )  		
					lCompGarantia := .T.
				EndIf
			End	   
		EndIf
		
		If !lCompGarantia .And. !Empty(oModel:GetValue( 'GFEA061F_GV6', 'GV6_COMFRG' ))
	   		Help( ,, 'Help',, STR0033+ALLTRIM(oModel:GetValue( 'GFEA061F_GV6', 'GV6_COMFRG'))+STR0034 , 1, 0 ) //"Componente Frete Garantia " ### " deve estar informado entre os componentes da tarifa da tabela de frete."
			lRet := .F.  
		EndIf           
		   
		If nOp == MODEL_OPERATION_UPDATE
			GFEALPMTV(oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDEMIT'),oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRTAB'))
		Endif
		
	//Validação de exclusão
	ElseIf nOp == MODEL_OPERATION_DELETE          
	
		If FWModeAccess("GVA",1) == "E" 
			//tarifa da tabela de frete não pode estar em uso em pre-calculo.
			cAliasQry := GetNextAlias()
			cQuery := " SELECT COUNT(*) AS QTD FROM "+RetSQLName("GWG")	
			cQuery += " WHERE GWG_CDEMIT = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDEMIT' )+"'"
			cQuery += " AND GWG_FILIAL = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_FILIAL' )+"'"	
			cQuery += " AND GWG_NRTAB = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRTAB' )+"'"
			cQuery += " AND GWG_NRNEG = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRNEG' )+"'"
			cQuery += " AND GWG_CDFXTV = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDFXTV' )+"'"
			cQuery += " AND GWG_NRROTA = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRROTA' )+"'"
			cQuery += " AND D_E_L_E_T_ = ' '"
		
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		
			If (cAliasQry)->QTD > 0
				
				cAliasClc := GetNextAlias()
				cQuery := " SELECT * FROM "+RetSQLName("GWG")
				cQuery += " WHERE GWG_CDEMIT = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDEMIT' )+"'"
				cQuery += " AND GWG_FILIAL = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_FILIAL' )+"'"	
				cQuery += " AND GWG_NRTAB = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRTAB' )+"'"
				cQuery += " AND GWG_NRNEG = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRNEG' )+"'"
				cQuery += " AND GWG_CDFXTV = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDFXTV' )+"'"
				cQuery += " AND GWG_NRROTA = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRROTA' )+"'"
				cQuery += " AND D_E_L_E_T_ = ' '"
			
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasClc, .F., .T.)
			
				While !(cAliasClc)->(EoF()) .And. cCont < 50
					cCalcs += (cAliasClc)->GWG_NRCALC + ", "
					cCont++
					(cAliasClc)->( dbSkip() )
				EndDo
				(cAliasClc)->( dbCloseArea() )
			
				cCalcs := SubStr(cCalcs, 1, Len(cCalcs) - 2)
			
				Help(,,'HELP',,"A Tarifa selecionada está em uso nos seguintes Pré-cálculos: " + cCalcs + Iif( ((cAliasQry)->QTD > 50) ,". Mais " + cValToChar(((cAliasQry)->QTD - cCont)) + " pré-cálculos que não puderam ser mostrados.", "."),1,0) 
				lRet := .F.
			EndIF
			(cAliasQry)->( dbCloseArea() )
		Else
			//tarifa da tabela de frete não pode estar em uso em pre-calculo.
			cAliasQry := GetNextAlias()
			cQuery := " SELECT COUNT(*) AS QTD FROM "+RetSQLName("GWG")	
			cQuery += " WHERE GWG_CDEMIT = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDEMIT' )+"'"
			cQuery += " AND GWG_NRTAB = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRTAB' )+"'"
			cQuery += " AND GWG_NRNEG = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRNEG' )+"'"
			cQuery += " AND GWG_CDFXTV = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDFXTV' )+"'"
			cQuery += " AND GWG_NRROTA = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRROTA' )+"'"
			cQuery += " AND D_E_L_E_T_ = ' '"
		
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			
			If (cAliasQry)->QTD > 0
				
				cAliasClc := GetNextAlias()
				cQuery := " SELECT * FROM "+RetSQLName("GWG")
				cQuery += " WHERE GWG_CDEMIT = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDEMIT' )+"'"
				cQuery += " AND GWG_NRTAB = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRTAB' )+"'"
				cQuery += " AND GWG_NRNEG = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRNEG' )+"'"
				cQuery += " AND GWG_CDFXTV = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDFXTV' )+"'"
				cQuery += " AND GWG_NRROTA = '"+oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRROTA' )+"'"
				cQuery += " AND D_E_L_E_T_ = ' '"
			
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasClc, .F., .T.)
			
				While !(cAliasClc)->(EoF()) .And. cCont < 50
					cCalcs += (cAliasClc)->GWG_NRCALC + ", "
					cCont++
					(cAliasClc)->( dbSkip() )
				EndDo
				(cAliasClc)->( dbCloseArea() )
			
				cCalcs := SubStr(cCalcs, 1, Len(cCalcs) - 2)
			
				Help(,,'HELP',,"A Tarifa selecionada está em uso nos seguintes Pré-cálculos: " + cCalcs + Iif( ((cAliasQry)->QTD > 50) ,". Mais " + cValToChar(((cAliasQry)->QTD - cCont)) + " pré-cálculos que não puderam ser mostrados.", "."),1,0) 
				lRet := .F.
			EndIf
			(cAliasQry)->( dbCloseArea() )
		EndIf
	EndIf

Return lRet


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA061FVL
Validação de saidA de foco do campo Rota e Sequencia de Frete.
Uso GFEA061F.

@sample
GFEA61FVL()

@author Felipe M., Felipe W.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA61FVL()
	Local lRet := .T.
	Local cChave := ""
	Local aArea := GetArea()
	
	cChave := FwFldGet( 'GV6_CDEMIT' )
	cChave += FwFldGet( 'GV6_NRTAB' )
	cChave += FwFldGet( 'GV6_NRNEG' )
	cChave += FwFldGet( 'GV6_CDFXTV' )
	cChave += FwFldGet( 'GV6_NRROTA' )
	
	dbSelectArea("GV6")  // seleciona a tabela
	dbSetOrder(01)       // seta o indice
	If dbSeek(xFilial("GV6") + cChave)
		Help( ,, 'Help',, STR0011, 1, 0 ) //"Já existe registro cadastrado com as chaves informadas"
		lRet := .F.
	EndIf
	
	RestArea(aArea)
	
Return lRet


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE61COMP
Validação do campo GV1_CDCOMP do dicionario

@sample
GFE61COMP()

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFE61COMP() 
	Local oModel    := FWModelActive() 
	Local oModelGV1 := oModel:GetModel("DETAIL_GV1")
	Local aArea     := GetArea()
	Local cGV1_CDCOMP
	Local cAtribCalc
	Local lExiste := .F.
	Local lVinculo := .F.
	Local cCampo := ReadVar()
		
	If "GV1_CDCOMP" $ cCampo
		
		cGV1_CDCOMP := FwFldGet("GV1_CDCOMP")
		
		DbSelectArea("GV2")
		DbSetOrder(1)
		If (DbSeek(xFilial("GV2")+cGV1_CDCOMP))
			lExiste := .T.
		EndIF
		
		DbSelectArea("GUY")
		If (DbSeek(xFilial("GUY")+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG+cGV1_CDCOMP))
			lVinculo := .T.	       
		EndIf
				
		If lExiste .and. !lVinculo
			Help( ,, 'Help',, 'O Componente informado existe mas não está vinculado na negociação', 1, 0 )
			RestArea(aArea)
			Return .F.
		Elseif !lExiste 
			Help( ,, 'Help',, 'O Componente informado não existe', 1, 0 )
			RestArea(aArea)
			Return .F.
		EndIf
				
		cAtribCalc := AllTrim(Posicione("GV2",1,xFilial("GV2")+cGV1_CDCOMP,"GV2_ATRCAL"))
		
		If cAtribCalc $ "29" .OR. cAtribCalc == "12"
			oModelGV1:SetValue("GV1_VLFIXN",0)
			oModelGV1:SetValue("GV1_VLUNIN",0)
			oModelGV1:SetValue("GV1_VLFRAC",0)
			oModelGV1:SetValue("GV1_VLMINN",0)
			oModelGV1:SetValue("GV1_VLFIXE",0)
			oModelGV1:SetValue("GV1_VLUNIE",0)
			oModelGV1:SetValue("GV1_CALCEX",'2')  
		ElseIf cAtribCalc $ "8"
			oModelGV1:SetValue("GV1_PCNORM",0)
			oModelGV1:SetValue("GV1_VLUNIN",0)
			oModelGV1:SetValue("GV1_VLFRAC",0)
			oModelGV1:SetValue("GV1_VLMINN",0)
			oModelGV1:SetValue("GV1_VLLIM" ,0)
			oModelGV1:SetValue("GV1_VLFIXE",0)
			oModelGV1:SetValue("GV1_PCEXTR",0)
			oModelGV1:SetValue("GV1_VLUNIE",0)
		Else
			oModelGV1:SetValue("GV1_PCNORM",0)
			oModelGV1:SetValue("GV1_PCEXTR",0)
		EndIf
		
		
		If Posicione("GV2",1,xFilial("GV2")+cGV1_CDCOMP,"GV2_TABSUF") == "3"
			MsgInfo(STR0031, STR0032)// "O componente selecionado utiliza tabela suframa. As tarifas informadas serão ignoradas, pois, serão utilizadas as tarifas da tabela suframa relacionada ao componente." ### "Aviso"
		EndIf
		
		//Não permite informar nas tarifas de frete o componente já informado na faixa de entrega da negociação
     	If cGV1_CDCOMP == GV9->GV9_COMFXE
			Help( ,, 'Help',, "Componente "+ALLTRIM(GV9->GV9_COMFXE)+" já informado como Componente Faixa Entrega da negociação.", 1, 0 )
			RestArea(aArea)
			Return .F.
		EndIf		
		
		RestArea(aArea)
	EndIf

Return .T.

Function GFE61FCOM(oModel)
	Local nOp := oModel:GetOperation()
	Local lRet := .T.
	If nOp == MODEL_OPERATION_DELETE
		lRet := FwFormCommit(oModel)
	Else
		lRet := FWFormCommit(oModel, /*[ bBefore ]*/,/* [ bAfter ]*/, /*[ bAfterSTTS ]*/,{|oModel| GFE61ATDP(oModel:GetValue( 'GFEA061F_GV6', 'GV6_CDEMIT' ) + oModel:GetValue( 'GFEA061F_GV6', 'GV6_NRTAB' ))}, /*[ bABeforeTTS ]*/, /*<bIntegEAI >*/)
	EndIf
Return lRet

Function GFE61FPESQ()
	
	AxPesqui()
Return        

Function GFE61FVIS()
	
	//VIEWDEF.GFEA061F
	FWExecView(STR0003,'GFEA061F', MODEL_OPERATION_VIEW, , {|| .T. },{|| .T.},,,{|| .T.})
Return        

Function GFE61FINC()
	
	//VIEWDEF.GFEA061F
	FWExecView(STR0004,'GFEA061F', MODEL_OPERATION_INSERT, , {|| .T. },{|| .T.},,,{|| .T.})
Return        

Function GFE61FALT()
	
	//VIEWDEF.GFEA061F
	FWExecView(STR0005,'GFEA061F', MODEL_OPERATION_UPDATE, , {|| .T. },{|| .T.},,,{|| .T.})
Return        

Function GFE61FEXC()
	
	//VIEWDEF.GFEA061F
	FWExecView(STR0006,'GFEA061F', MODEL_OPERATION_DELETE, , {|| .T. },{|| .T.},,,{|| .T.})
Return        

Function GFE61FCOPY()
	
	//VIEWDEF.GFEA061F
	FWExecView('Copiar',"GFEA061F",9,,{|| .T.}) //"Cópia"
Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE061CTA
Validação de saidA de foco do registro do Componente da Tarifa 
Uso GFEA061F.

@param  oModel        objeto modelo

@sample
GFE061CTA(oModel)

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFE061CTA(oModel)
	Local nLine := oModel:GetLine()
	Local nI 
	Local cAtribCalc
	Local cDsAtrib             
	
	For nI := 1 To oModel:Length() 
		oModel:GoLine(nI) 
		If FwFldGet("GV1_CDCOMP",nLine) == FwFldGet("GV1_CDCOMP",nI) .AND. nLine != nI .AND. !oModel:IsDeleted()
			Help( ,, 'Help',, StrTran(STR0014, "[ln]", AllTrim(Str(nI))), 1, 0 )  //"Componente já foi informado."                  
			oModel:GoLine( nLine )
			Return .F.
		EndIf
	Next nI
	
	oModel:GoLine( nLine )   
	
	//Atribui o valor do atributo de cálculo para posteriores validações.
	cAtribCalc := AllTrim(Posicione("GV2",1,xFilial("GV2")+FwFldGet("GV1_CDCOMP"),"GV2_ATRCAL"))
	                                                      
	If cAtribCalc == "2"
		cDsAtrib := STR0036 //"Valor da Mercadoria"
	ElseIf cAtribCalc == "8"
		cDsAtrib := STR0037 //"Valor Informado"
	ElseIf cAtribCalc == "9"
		cDsAtrib := STR0038 //"Valor do Frete"
	ElseIf cAtribCalc == '12'
		cDsAtrib := 'Valor Líquido'
	EndIf
	
	//Verifica se o componente é de valor da mercadoria ou valor do frete, pois, com essas especificações a fração normal deve ser 0
	If (cAtribCalc $ "29" .OR. cAtribCalc == '12' ) .And. FwFldGet("GV1_VLFRAC") != 0
		Help( ,, 'Help',, StrTran(StrTran(STR0023, "[atribcalc]", cDsAtrib), "[ln]", AllTrim(Str(nLine))), 1, 0 ) //"O Componente de Frete em 'Componente da Tarifa' na linha [ln], possui atributo de cálculo '[atribcalc]', portanto, o valor da Fração Normal deve ser 0."
		Return .F.
	ElseIf cAtribCalc $ "8" .And. (FwFldGet("GV1_PCNORM") != 0 .Or. FwFldGet("GV1_VLUNIN") != 0 .Or. FwFldGet("GV1_VLFRAC") != 0 .Or. ;
		   FwFldGet("GV1_VLMINN") != 0 .Or. FwFldGet("GV1_VLLIM") != 0 .Or. FwFldGet("GV1_VLFIXE") != 0 .Or. FwFldGet("GV1_PCEXTR") != 0 .Or. ;
		   FwFldGet("GV1_VLUNIE") != 0)
		Help( ,, 'Help',, StrTran(StrTran(STR0025, "[atribcalc]", cDsAtrib), "[ln]", AllTrim(Str(nLine))), 1, 0 ) //"O Componente de Frete em 'Componente da Tarifa' na linha [ln], possui atributo de cálculo '[atribcalc]', portanto, só o campo 'Valor Fixo Normal' pode ser informado."
		Return .F.
	ElseIf !(cAtribCalc $ "29" .OR. cAtribCalc == '12') 
		If FwFldGet("GV1_PCNORM") != 0    
			Help( ,, 'Help',, StrTran(STR0027, "[ln]", AllTrim(Str(nLine))), 1, 0 ) //"O Componente de Frete em 'Componente da Tarifa' na linha [ln], possui atributo de cálculo diferente de 'Valor da Mercadoria' e 'Valor do Frete', portanto, o campo de 'Precentual Normal' deve ser 0."
			Return .F.
		ElseIf FwFldGet("GV1_PCEXTR") != 0
			Help( ,, 'Help',, StrTran(STR0028, "[ln]", AllTrim(Str(nLine))), 1, 0 ) //"O Componente de Frete em 'Componente da Tarifa' na linha [ln], possui atributo de cálculo diferente de 'Valor da Mercadoria' e 'Valor do Frete', portanto, o campo de 'Precentual Extra' deve ser 0."
			Return .F.
		EndIf
	EndIf
	
Return .T.


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE061CEMI
Validação de saidA de foco do campo do Componente da Tarifa X Emitente.
Uso GFEA061F.

@param  cCampo        Campo para validacao, não obrigatório

@sample
GFE061CEMI(oModel)

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFE061CEMI(cCampo)
	Local oModel    := FWModelActive()
	Local oModelGUC := oModel:GetModel("DETAIL_GUC")
	Local cGUC_CDCOMP
	Local cAtribCalc
	Local oView := FwViewActive()
	
	Default cCampo := ReadVar()
	
	If "GUC_CDCOMP" $ cCampo
	
	    //Componente deve estar cadastrado na tabela de componentes da tabela de frete
		If !ExistCpo("GUY",GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG+M->GUC_CDCOMP) 
			Help( ,, 'Help',, STR0015, 1, 0 )  //"Componente não está cadastrado na rotina de Componentes da Tabela de Frete."
			Return .F.  
		//Componente deve estar cadastrado na tabela de componente de frete
		ElseIf !ExistCpo("GV2",M->GUC_CDCOMP)
			Help( ,, 'Help',, STR0016, 1, 0 )  //"Componente não está cadastrado na rotina de Componentes de Frete."
			Return .F.
		EndIf
		
		cGUC_CDCOMP := FwFldGet("GUC_CDCOMP")  
	
		cAtribCalc := AllTrim(Posicione("GV2",1,xFilial("GV2")+cGUC_CDCOMP,"GV2_ATRCAL"))
	
		If cAtribCalc $ "29" .OR. cAtribCalc == "12" 
			oModelGUC:SetValue("GUC_VLFIXN",0)
			oModelGUC:SetValue("GUC_VLUNIN",0)
			oModelGUC:SetValue("GUC_VLFRAC",0)
			oModelGUC:SetValue("GUC_VLMINN",0)
			oModelGUC:SetValue("GUC_PCLIM" ,0)
			oModelGUC:SetValue("GUC_VLFIXE",0)
			oModelGUC:SetValue("GUC_VLUNIE",0)
			oModelGUC:SetValue("GUC_CALCEX",'2')
		ElseIf cAtribCalc $ "8"
			oModelGUC:SetValue("GUC_PCNORM",0)
			oModelGUC:SetValue("GUC_VLUNIN",0)
			oModelGUC:SetValue("GUC_VLFRAC",0)
			oModelGUC:SetValue("GUC_VLMINN",0)
			oModelGUC:SetValue("GUC_VLLIM" ,0)
			oModelGUC:SetValue("GUC_PCLIM" ,0)
			oModelGUC:SetValue("GUC_VLFIXE",0)
			oModelGUC:SetValue("GUC_PCEXTR",0)
			oModelGUC:SetValue("GUC_VLUNIE",0)
		Else
			oModelGUC:SetValue("GUC_PCNORM",0)
			oModelGUC:SetValue("GUC_PCEXTR",0)
		EndIf
		
		If Posicione("GV2",1,xFilial("GV2")+cGUC_CDCOMP,"GV2_TABSUF") == "3"
			If oView != Nil .And. oView:lActivate .And. oView:oModel:cId == oModel:cId // Tem uma view ativa e é referente a esse modelo.
				MsgInfo(STR0031, STR0032)// "O componente selecionado utiliza tabela suframa. As tarifas informadas serão ignoradas, pois, serão utilizadas as tarifas da tabela suframa relacionada ao componente." ### "Aviso"
			EndIf
		EndIf
		
		//Não permite informar nas tarifas de frete o componente já informado na faixa de entrega da negociação
     	If cGUC_CDCOMP == GV9->GV9_COMFXE
			Help( ,, 'Help',, "Componente "+ALLTRIM(GV9->GV9_COMFXE)+" já informado como Componente Faixa Entrega da negociação.", 1, 0 )
			Return .F.
		EndIf	
		
	ElseIf "GUC_EMICOM" $ cCampo

		If Alltrim(M->GUC_EMICOM) != "*"	// Para adequação a MOR onde deverá permitir incluir todos emitentes atraves do caracter * possam receber a regra de exceção.
			//Emitente deve estar cadastrado na tabela de emitentes 
			If !ExistCpo("GU3",M->GUC_EMICOM)   
				Help( ,, 'Help',, STR0017, 1, 0 ) //"Emitente não está cadastrado no sistema"
				Return .F.
			//O emitente deve estar ativo.
			ElseIf !GFEExistC("GU3", 1, M->GUC_EMICOM, "GU3->GU3_SIT=='1'")
				Help( ,, 'Help',, STR0021, 1, 0 ) //"O emitente deve estar ativo."
				Return .F.
			//Emitente deve ter o campo "Cliente" igual a SIM
			ElseIf POSICIONE("GU3",1,XFILIAL("GU3")+M->GUC_EMICOM,"GU3_CLIEN") != '1'
				Help( ,, 'Help',, STR0018, 1, 0 ) //"Emitente deve ser um cliente"
				Return .F.
			EndIf
		EndIf
	    
	ElseIf "GUC_NRCID" $ cCampo
		If !Empty(Alltrim(M->GUC_NRCID))
			If !ExistCpo("GU7",M->GUC_NRCID)   
				Help( ,, 'Help',, STR0057, 1, 0 ) //"Cidade não está cadastrado no sistema"
				Return .F.
			EndIf
		EndIf
	EndIf 

Return .T.


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFE061CEM
Validação de saidA de foco do registro do Componente da Tarifa X Emitente.
Uso GFEA061F.

@param  cCampo        Campo para validacao, não obrigatório
@param  oModel        objeto modelo

@sample
GFE061CEM(oModel)

@author Felipe M.
@since 14/10/09
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFE061CEM(oModel)
	Local nLine := oModel:GetLine()
	Local nI
	Local cGUC_CDCOMP := FwFldGet("GUC_CDCOMP",nLine)
	Local cGUC_EMICOM := FwFldGet("GUC_EMICOM",nLine)   
	Local lRet := .T.
	Local cAtribCalc
	Local cDsAtrib 
	
	For nI := 1 To oModel:GetQtdLine() 
		oModel:GoLine( nI )            
		//Validação de chave duplicada
		If FwFldGet("GUC_CDCOMP",nI)+ FwFldGet("GUC_EMICOM",nI) == cGUC_CDCOMP + cGUC_EMICOM .AND. nLine != nI
			Help( ,, 'Help',, StrTran(STR0019, "[ln]", AllTrim(Str(nI))), 1, 0 )  
			lRet := .F.
		EndIf
	Next nI
		
	//Verifica se o componente é de valor da mercadoria ou valor do frete, pois, com essas especificações a fração normal deve ser 0
	cAtribCalc := AllTrim(Posicione("GV2",1,xFilial("GV2")+FwFldGet("GUC_CDCOMP"),"GV2_ATRCAL"))
	
	If cAtribCalc == "2"
		cDsAtrib := STR0036 //"Valor da Mercadoria"
	ElseIf cAtribCalc == "8"
		cDsAtrib := STR0037 //"Valor Informado"
	ElseIf cAtribCalc == "9"
		cDsAtrib := STR0038 //"Valor do Frete"
	ElseIf cAtribCalc == "12"
		cDsAtrib := "Valor Líquido" 
	EndIf
	
	If (cAtribCalc $ "29" .OR. cAtribCalc == "12") .And. FwFldGet('GUC_VLFRAC') != 0
		Help(,, 'Help',, StrTran(StrTran(STR0024, "[atribcalc]", cDsAtrib), "[ln]", AllTrim(Str(nLine))), 1, 0) //"O Componente de Frete em 'Componente da Tarifa X Emitente' na linha [ln] na  possui atributo de cálculo '[atribcalc]', portanto, o valor da Fração Normal deve ser 0."
		lRet := .F.
	ElseIf cAtribCalc $ "8" .And. (FwFldGet("GUC_PCNORM") != 0 .Or. FwFldGet("GUC_VLUNIN") != 0 .Or. FwFldGet("GUC_VLFRAC") != 0 .Or. ;
		   FwFldGet("GUC_VLMINN") != 0 .Or. FwFldGet("GUC_PCLIM") != 0 .Or. FwFldGet("GUC_VLLIM") != 0 .Or. FwFldGet("GUC_VLFIXE") != 0 .Or. ;
		   FwFldGet("GUC_PCEXTR") != 0 .Or. FwFldGet("GUC_VLUNIE") != 0)
		Help( ,, 'Help',, StrTran(StrTran(STR0026, "[atribcalc]", cDsAtrib), "[ln]", AllTrim(Str(nLine))), 1, 0 ) //"O Componente de Frete em 'Componente da Tarifa X Emitente' na linha [ln], possui atributo de cálculo '[atribcalc]', portanto, só o campo 'Valor Fixo Normal' pode ser informado."
		Return .F.   
	ElseIf !(cAtribCalc $ "29" .OR. cAtribCalc == "12") 
		If FwFldGet("GUC_PCNORM") != 0    
			Help( ,, 'Help',, StrTran(STR0029, "[ln]", AllTrim(Str(nLine))), 1, 0 ) //"O Componente de Frete em 'Componente da Tarifa X Emitente' na linha [ln], possui atributo de cálculo diferente de 'Valor da Mercadoria' e 'Valor do Frete', portanto, o campo de 'Precentual Normal' deve ser 0."
			Return .F.
		ElseIf FwFldGet("GUC_PCEXTR") != 0
			Help( ,, 'Help',, StrTran(STR0030, "[ln]", AllTrim(Str(nLine))), 1, 0 ) //"O Componente de Frete em 'Componente da Tarifa X Emitente' na linha [ln], possui atributo de cálculo diferente de 'Valor da Mercadoria' e 'Valor do Frete', portanto, o campo de 'Precentual Extra' deve ser 0."
			Return .F.
		EndIf
	EndIf
 
Return lRet                               
   

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA061FA

@author Frete Embarcador
@since 14/10/09
@version 1.0
-------------------------------------------------------------------*/
Function GFEA061FA(oModel)
	Local nOpc     	:= oModel:GetOperation()
	Local aArea 	:= GetArea()
	Local _MVAPRTAB	:= SuperGetMv("MV_APRTAB",.F.,"2")	
	Local lExecValid := .T.
	
	If nOpc == MODEL_OPERATION_INSERT .AND. Empty(GV9->GV9_NRNEG)
		Help( ,, 'Help',,"Deve ser selecionada uma negociação", 1, 0 )
		Return .F.	  
	EndIf
	
	If lPE613
		lExecValid := ExecBlock("GFEA0613",.f.,.f.,{nOpc})
	EndIf	
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_DELETE

		If GV9->GV9_SIT == "2" .And. _MVAPRTAB $ "1S" .AND. lExecValid
			Help( ,, 'Help',,STR0020, 1, 0 )  //"Não pode ser Alterados dados de tarifas pois a tabela de frete já foi aprovada ."
			Return .F.	  
		EndIf			
			   
	EndIf
	
	RestArea(aArea)
	
Return .T.


/*--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61FWHN
Função chamada pelo WHEN dos campos em questão

@sample
GFEA61FWHN()

@author Octávio Augusto Felippe de Macedo
@since 24/01/2011
@version 1.0
--------------------------------------------------------------------------------------------------*/
Function GFEA61FWHN(cCampo,cAtrib)   
	Local aBloq  := {}
	Default cCampo := SubStr(ReadVar(),4)
	Default cAtrib = ""
	If !IsInCallStack("GFE61COMP") .And. !IsInCallStack("GFE061CEMI") .And. !IsInCallStack("X061Load")
		If "GV1" $ cCampo
			
			If Empty(cAtrib)
				cAtrib := AllTrim(Posicione("GV2",1,xFilial("GV2")+FwFldGet('GV1_CDCOMP'),"GV2_ATRCAL"))
			EndIf
			
			AAdd(aBloq, "GV1_VLFIXN;GV1_VLUNIN;GV1_VLFRAC;GV1_VLFIXE;GV1_VLUNIE")
			AAdd(aBloq, "GV1_VLFIXN;GV1_VLUNIN;GV1_VLFRAC;GV1_VLFIXE;GV1_VLUNIE")
			AAdd(aBloq, "GV1_PCNORM;GV1_VLUNIN;GV1_VLFRAC;GV1_VLMINN;GV1_PCLIM;GV1_VLLIM;GV1_PCLIM;GV1_VLFIXE;GV1_PCEXTR;GV1_VLUNIE")
			AAdd(aBloq, "GV1_PCNORM;GV1_PCEXTR")		
		Else
			
			If Empty(cAtrib)
				cAtrib := AllTrim(Posicione("GV2",1,xFilial("GV2")+FwFldGet('GUC_CDCOMP'),"GV2_ATRCAL"))
			EndIf
			
			AAdd(aBloq, "GUC_VLFIXN;GUC_VLUNIN;GUC_VLFRAC;GUC_PCLIM;GUC_VLFIXE;GUC_VLUNIE")
			AAdd(aBloq, "GUC_VLFIXN;GUC_VLUNIN;GUC_VLFRAC;GUC_PCLIM;GUC_VLFIXE;GUC_VLUNIE")
			AAdd(aBloq, "GUC_PCNORM;GUC_VLUNIN;GUC_VLFRAC;GUC_VLMINN;GUC_VLLIM;GUC_PCLIM;GUC_VLFIXE;GUC_PCEXTR;GUC_VLUNIE")
			AAdd(aBloq, "GUC_PCNORM;GUC_PCEXTR")
		EndIf     
		
		If !Empty(cAtrib)
			If cAtrib == "9"
				If cCampo $ aBloq[1]
					Return .F.
				EndIf
			ElseIf cAtrib == "2" .OR. cAtrib == "12"
				If cCampo $ aBloq[2]
					Return .F.
				EndIf
			ElseIf cAtrib == "8" 
				If cCampo $ aBloq[3]
					Return .F.
				EndIf
			Else 
				If cCampo $ aBloq[4]
					Return .F.
				EndIf
			EndIf
		EndIf	
	EndIf

Return .T.         

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEASEQFX

Função do gatilho do campo GV6_CDFXTV 

@Param -> cCdEmit - Codigo do Emitente
@Param -> cNrTab  - Numero da Tabela de Frete
@Param -> cNrNeg  - Numero da Negociacao  
@Param -> cCdFxTv - Codigo da Faixa 
@Param -> lNeg    - Indica se posiciona ou não na tabela de negociacao, Default .F.

@author Jorge Matos Valcanaia
@since 03/02/11
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEASEQFX(cCdEmit,cNrTab,cNrNeg,cCdFxTv,lNeg) 
	Local cRetorno := ""
	Local aAreaGV7 := GV7->(GetArea())
	Local aAreaGV9 := GV9->(GetArea())
	Local aAreaGV3 := GV3->(GetArea())
	Local aAreaGV6 := GV6->(GetArea())	
	Local cTpLota  := ""
	
	Default cCdEmit := GV9->GV9_CDEMIT
	Default cNrTab  := GV9->GV9_NRTAB
	Default cNrNeg  := GV9->GV9_NRNEG
	Default cCdFxTv := FwFldGet("GV6_CDFXTV")
	Default lNeg    := .F.
	
	If lNeg 
		dbSelectArea("GV9")
		dbSetOrder(1)
		If dbSeek(xFilial("GV9")+ cCdEmit + cNrTab + cNrNeg )
			cTpLota := GV9->GV9_TPLOTA
		Endif
	Else 
		cTpLota := GV9->GV9_TPLOTA
	Endif
	
		dbSelectArea("GV7")
		dbSetOrder(1)
		If dbSeek(xFilial("GV7") + cCdEmit + cNrTab + cNrNeg + cCdFxTv )
			If cTpLota == "1"
				If GV7->GV7_QTFXFI == 0
					cRetorno := "Todas as faixas"
				Else
					cRetorno := AllTrim(Transform(GV7->GV7_QTFXFI,X3PICTURE("GV7_QTFXFI")))
				EndIf
			Else 
				cRetorno := If (!Empty(GV7->GV7_CDTPVC),Alltrim(GV7->GV7_CDTPVC) + " - ","") + GFEA061DS(GV7->GV7_CDTPVC,.T.,cTpLota)
			Endif	
		Else     
			dbSelectArea("GVA")
			dbSetOrder(1)
			If dbSeek(xFilial("GVA") + cCdEmit + cNrTab )
				If GVA->GVA_TPTAB == "2"
					dbSelectArea("GV9")
					dbSetOrder(1) 
					If dbSeek(xFilial("GV9") + GVA->GVA_EMIVIN + GVA->GVA_TABVIN)  					
						dbSelectArea("GV7")
						dbSetOrder(1)
						If dbSeek(xFilial("GV7") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + cNrNeg + cCdFxTv )
							If GV9->GV9_TPLOTA == "1"
								If GV7->GV7_QTFXFI == 0
									cRetorno := "Todas as faixas"
								Else
									cRetorno := AllTrim(Transform(GV7->GV7_QTFXFI,X3PICTURE("GV7_QTFXFI")))
								EndIf
							Else 
								cRetorno := Alltrim(GV7->GV7_CDTPVC) + " - " + GFEA061DS(GV7->GV7_CDTPVC,.T.,GV9->GV9_TPLOTA)								
							Endif	
						Endif						
					Endif					
				Endif
			Endif		
		Endif            
		
	RestArea(aAreaGV3)
	RestArea(aAreaGV9)
	RestArea(aAreaGV7)
	RestArea(aAreaGV6)		
		
Return cRetorno


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEAGV7FX

Função da Consulta especifica do campo GV6_CDFXTV

@author Jorge Matos Valcanaia
@since 03/02/11
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEAGV7FX() 
	Local aRet     := {}
	Local cTitulo  := STR0039 //"Faixa/ Tipo Veículo"
	Local lRet     := .F.
	Local nItem    := 0
	Local cSeqFx   := ""
	Local cTpLota  := GV9->GV9_TPLOTA 
	
	dbSelectArea("GV7")
	dbSetOrder(1)
	If dbSeek(xFilial("GV7") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG )
		While !Eof() .And. xFilial("GV7") == GV7->GV7_FILIAL .And. GV7->GV7_CDEMIT == GV9->GV9_CDEMIT .And. GV7->GV7_NRTAB == GV9->GV9_NRTAB .And. GV7->GV7_NRNEG == GV9->GV9_NRNEG 
		
			If cTpLota == "1"
				aAdd( aRet, {GV7->GV7_CDEMIT, GV7->GV7_NRTAB, GV7->GV7_NRNEG , GV7->GV7_CDFXTV, Alltrim(STR(GV7->GV7_QTFXFI))} )                        			
			Else 
				aAdd( aRet, {GV7->GV7_CDEMIT, GV7->GV7_NRTAB, GV7->GV7_NRNEG , GV7->GV7_CDFXTV,Alltrim(GV7->GV7_CDTPVC),POSICIONE("GV3",1,XFILIAL("GV3")+GV7->GV7_CDTPVC,"GV3_DSTPVC") } )                        			
			Endif	
			lRet:= .T.							
			dbSelectArea("GV7")
			dbSkip()
		Enddo
	Endif    
			
	
	//-- Apresenta a tela para selecao do item.
	If lRet 
		lRet := .F.
		If cTpLota == "1"
			nItem := TmsF3Array( {STR0040,STR0041,STR0042,STR0043,STR0044}, aRet, cTitulo ) //"Emitente" ### "Número Tab." ### "Número Neg." ### "Seq. Faixa" ### "Qtde. Final Faixa"
		Else            
			nItem := TmsF3Array( {STR0040,STR0041,STR0042,STR0043,STR0045,STR0046}, aRet, cTitulo ) //"Emitente" ### "Número Tab." ### "Número Neg." ### "Seq. Faixa" ### "Tipo Veículo" ### "Descrição Veículo"
		Endif
		If nItem > 0
			cSeqFx  := aRet[ nItem, 4 ]
					
			dbSelectArea("GV7")
			dbSetOrder(1)
			If dbSeek(xFilial("GV7") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG + cSeqFx )
				lRet := .T.
			Endif	
		Endif		
	EndIf    

Return lRet   


/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEAGV7ROT

Função da Consulta especifica do campo GV6_NRROTA

@author Jorge Matos Valcanaia
@since 03/02/11
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEAGV7ROT() 
	Local aRet      := {}
	Local cTitulo   := STR0047 //"Rota de Frete c/ Fil"
	Local lRet      := .F.
	Local nItem     := 0
	Local cRetOri   := ""       
	Local cCodOri   := ""
	Local cDesCodOr := "" 
	Local cRetDes   := ""  
	Local cCodDes   := ""
	Local cDesCodDs := "" 
	Local cNrRota   := "" 
	
	dbSelectArea("GV8")
	dbSetOrder(1)
	If dbSeek(xFilial("GV8") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG )
		While !Eof() .And. xFilial("GV8") == GV8->GV8_FILIAL .And. GV8->GV8_CDEMIT == GV9->GV9_CDEMIT .And. GV8->GV8_NRTAB == GV9->GV9_NRTAB .And. GV8->GV8_NRNEG == GV9->GV9_NRNEG 
		  	If GV8_TPORIG == "1"
		   		cRetOri   := STR0048 //"Cidade"
				cCodOri   := GV8->GV8_NRCIOR
				cDesCodOr := POSICIONE("GU7",1,XFILIAL("GU7")+GV8->GV8_NRCIOR,"GU7_NMCID") 
		  	ElseIf GV8_TPORIG == "2"
				cRetOri   := STR0049 //"Distância"
				cCodOri   := Alltrim(STR(GV8->GV8_DSTORI))
				cDesCodOr := Alltrim(STR(GV8->GV8_DSTORF))
			ElseIf GV8_TPORIG == "3"
				cRetOri   := STR0050 //"Região"
				cCodOri   := GV8->GV8_NRREOR
				cDesCodOr := POSICIONE("GU9",1,XFILIAL("GU9")+GV8->GV8_NRREOR,"GU9_NMREG") 
			ElseIf GV8_TPORIG == "4"
				cRetOri   := STR0051 + "/UF" //"País"
				cCodOri   := GV8->GV8_CDPAOR
				cDesCodOr := AllTrim(POSICIONE("SYA",1,XFILIAL("SYA")+GV8->GV8_CDPAOR,"YA_DESCR")) + "/" + AllTrim(GV8->GV8_CDUFOR)
			ElseIf GV8_TPORIG == "5"
				cRetOri   := STR0052 //"Remetente"
				cCodOri   := GV8->GV8_CDREM
				cDesCodOr := POSICIONE("GU3",1,XFILIAL("GU3")+GV8->GV8_CDREM,"GU3_NMEMIT")   
			Endif            
				
		   	If GV8_TPDEST == "1"
				cRetDes   := STR0048 //"Cidade"
				cCodDes   := GV8->GV8_NRCIDS
				cDesCodDs := POSICIONE("GU7",1,XFILIAL("GU7")+GV8->GV8_NRCIDS,"GU7_NMCID") 
			ElseIf GV8_TPDEST == "2"
				cRetDes   := STR0049 //"Distância"
				cCodDes   := Alltrim(STR(GV8->GV8_DSTDEI))
				cDesCodDs := Alltrim(STR(GV8->GV8_DSTDEF))
			ElseIf GV8_TPDEST == "3"
				cRetDes   := STR0050 //"Região"
				cCodDes   := GV8->GV8_NRREDS
				cDesCodDs := POSICIONE("GU9",1,XFILIAL("GU9")+GV8->GV8_NRREDS,"GU9_NMREG") 
			ElseIf GV8_TPDEST == "4"
				cRetDes   := STR0051 + "/UF" //"País"
				cCodDes   := GV8->GV8_CDPADS
				cDesCodDs := AllTrim(POSICIONE("SYA",1,XFILIAL("SYA")+GV8->GV8_CDPADS,"YA_DESCR")) + "/" + AllTrim(GV8->GV8_CDUFDS)
			ElseIf GV8_TPDEST == "5"
				cRetDes   := "Destinatário" //"Destinatário"
				cCodDes   := GV8->GV8_CDDEST
				cDesCodDs := POSICIONE("GU3",1,XFILIAL("GU3")+GV8->GV8_CDDEST,"GU3_NMEMIT") 
			Endif	  
			
		 	aAdd( aRet, {GV8->GV8_CDEMIT , GV8->GV8_NRTAB , GV8->GV8_NRNEG , GV8->GV8_NRROTA , cRetOri , cCodOri , cDesCodOr , cRetDes , cCodDes , cDesCodDs } )              	
			
		 	ccRetOri := cCodOri := cDesCodOr := cRetDes := cCodDes := cDesCodDs := ""
			lRet:= .T.
			dbSelectArea("GV8")
			dbSkip()
		EndDo
	Endif                 
	
	//-- Apresenta a tela para selecao do item.
	If lRet 
		lRet  := .F.
		nItem := TmsF3Array( {STR0040 , STR0041 , STR0042 , STR0053 , STR0054 , Space(10) , Space(30) , STR0055 , Space(10) , Space(30)}, aRet, cTitulo ) //"Emitente" ### "Número Tab." ### "Número Neg." ### "Rota" ### "Tipo de Origem" ### "Tipo de Destino"
		
		If nItem > 0
			cNrRota  := aRet[ nItem, 4 ]
			
			dbSelectArea("GV8")
			dbSetOrder(1)
			If dbSeek(xFilial("GV8") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + GV9->GV9_NRNEG + cNrRota )
				lRet := .T.
			Endif	
		Endif		
	EndIf                  
               
Return lRet      

        
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEAINFROT

Função do gatilho do campo GV6_NRROTA

@Param -> cCdEmit - Codigo do Emitente
@Param -> cNrTab  - Numero da Tabela de Frete
@Param -> cNrNeg  - Numero da Negociacao  
@Param -> cCdFxTv - Codigo da Faixa 

@author Jorge Matos Valcanaia
@since 03/02/11
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEAINFROT(cCdEmit,cNrTab,cNrNeg,cCdFxTv)
	Local cRetorno  := ""              
	Local cRetOri   := ""     
	Local cRetDes   := ""  
	Local aAreaGV7  := GV7->(GetArea())
	Local aAreaGV9  := GV9->(GetArea())
	Local aAreaGV3  := GV3->(GetArea()) 
	Local aAreaGV6  := GV6->(GetArea()) 
	
	Default cCdEmit := GV9->GV9_CDEMIT
	Default cNrTab  := GV9->GV9_NRTAB
	Default cNrNeg  := GV9->GV9_NRNEG
	Default cCdFxTv := FwFldGet("GV6_NRROTA")  
	
		dbSelectArea("GVA")
		dbSetOrder(1)
		If dbSeek(xFilial("GVA") + cCdEmit + cNrTab )
			If GVA->GVA_TPTAB == "2"
				dbSelectArea("GV9")
				dbSetOrder(1) 
				If dbSeek(xFilial("GV9") + GVA->GVA_EMIVIN + GVA->GVA_TABVIN)  					
					dbSelectArea("GV8")
					dbSetOrder(1)
					If dbSeek(xFilial("GV8") + GV9->GV9_CDEMIT + GV9->GV9_NRTAB + cNrNeg )
						cCdEmit	:= GV8->GV8_CDEMIT
						cNrTab  := GV8->GV8_NRTAB
					Endif						
				Endif					
			Endif
		Endif
	
		dbSelectArea("GV8")
		dbSetOrder(1)
		If dbSeek(xFilial("GV8") + cCdEmit + cNrTab + cNrNeg + cCdFxTv )
			If GV8_TPORIG == "0"
				cRetOri := "Todas as rotas"
			ElseIf GV8_TPORIG == "1"
		   		cRetOri := STR0048 + " - " + AllTrim(GV8->GV8_NRCIOR)      + " - " + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+GV8->GV8_NRCIOR,"GU7_NMCID")) //"Cidade"
		  	ElseIf GV8_TPORIG == "2"
				cRetOri := STR0049 + " - " + Alltrim(STR(GV8->GV8_DSTORI)) + " - " + Alltrim(STR(GV8->GV8_DSTORF)) //"Distância"
			ElseIf GV8_TPORIG == "3"
				cRetOri := STR0050 + " - " + AllTrim(GV8->GV8_NRREOR)      + " - " + AllTrim(POSICIONE("GU9",1,XFILIAL("GU9")+GV8->GV8_NRREOR,"GU9_NMREG")) //"Região"
			ElseIf GV8_TPORIG == "4"
				cRetOri := STR0051 + " - " + AllTrim(GV8->GV8_CDPAOR)      + " - " + AllTrim(POSICIONE("SYA",1,XFILIAL("SYA")+GV8->GV8_CDPAOR,"YA_DESCR")) + ;
						   " , " + STR0056 + " - " + GV8->GV8_CDUFOR // "País" ### "UF"
			ElseIf GV8_TPORIG == "5"
				cRetOri := STR0052 + " - " + AllTrim(GV8->GV8_CDREM)       + " - " + AllTrim(POSICIONE("GU3",1,XFILIAL("GU3")+GV8->GV8_CDREM,"GU3_NMEMIT")) //"Remetente"
			Endif            
			
			If GV8_TPORIG != "2"
				If GV8_TPDEST == "0"
					cRetDes := " | Todas as rotas"
			   	ElseIf GV8_TPDEST == "1"
					cRetDes := " | "+STR0048 + " - " + AllTrim(GV8->GV8_NRCIDS)      + " - " + AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+GV8->GV8_NRCIDS,"GU7_NMCID")) //"Cidade"
				ElseIf GV8_TPDEST == "2"
					cRetDes := " | "+STR0049 + " - " + Alltrim(STR(GV8->GV8_DSTDEI)) + " - " + Alltrim(STR(GV8->GV8_DSTDEF)) //"Distância"
				ElseIf GV8_TPDEST == "3"
					cRetDes := " | "+STR0050 + " - " + AllTrim(GV8->GV8_NRREDS)      + " - " + AllTrim(POSICIONE("GU9",1,XFILIAL("GU9")+GV8->GV8_NRREDS,"GU9_NMREG"))//"Região"
				ElseIf GV8_TPDEST == "4"                                      
					cRetDes := " | "+STR0051 + " - " + AllTrim(GV8->GV8_CDPADS)      + " - " + AllTrim(POSICIONE("SYA",1,XFILIAL("SYA")+GV8->GV8_CDPADS,"YA_DESCR")) + ;
							   " , " + STR0056 + " - " + GV8->GV8_CDUFDS // "País" ### "UF"
				ElseIf GV8_TPDEST == "5"
					cRetDes := " | Destinatário - " + AllTrim(GV8->GV8_CDDEST)      + " - " + Alltrim(POSICIONE("GU3",1,XFILIAL("GU3")+GV8->GV8_CDDEST,"GU3_NMEMIT")) //"Destinatário"
				Endif
			EndIf
			
			cRetorno := cRetOri + cRetDes
			
		Endif
		
	RestArea(aAreaGV3)
	RestArea(aAreaGV9)
	RestArea(aAreaGV7)   
	RestArea(aAreaGV6)  	
		
Return cRetorno

/*-------------------------------------------------------------------                                                                           
{Protheus.doc} GFEA61FACT

@author Frete Embarcador
@since 14/10/09
@version 1.0
-------------------------------------------------------------------*/
Function GFEA61FACT(oModel)
	Local nOp := oModel:GetOperation()
	
	If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE //Cópia também é reconhecida como inserção
		
		oModel:SetValue("GFEA061F_GV6", "GV6_DTATU" , DDATABASE)
		oModel:SetValue("GFEA061F_GV6", "GV6_HRATU" , SubStr(TIME(), 0, 5))
		oModel:SetValue("GFEA061F_GV6", "GV6_USUATU", cUserName)
		
	EndIf
	
Return

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA61FTAR
Geração automática de tarifas para uma negociação.

@sample
GFEA61FTAR(lAuto)

@author Alan Victor Lamb
@since 24/07/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEA61FTAR(lAuto,aDadosGV6,aDadosGV1)
	Local lRet := .T.
	Local nTar := 0
	Local aAreaGV8 // Rotas
	Local aAreaGV7 // Faixas
	Local aAreaGV6 // Tarifa
	Local aAreaGV1 // Componente Tarifa
	Local aAreaGUY // Componente Tabela de Frete
	Local cAtribCalc := ""
	Local nFPos
	Local nX
	Local nY
	Local lMod
	Default lAuto := .F.
	Default aDadosGV6 := {} // Exemplo de formato encontrado na função GFEX061->NovaTab
	Default aDadosGV1 := {} // Exemplo de formato encontrado na função GFEX061->NovaTab
	
	If Empty(GV9->GV9_FILIAL+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG)
		lRet := .F.
	EndIf
	
	If !lAuto .And. !ApMsgYesNo("Atenção!"+;
	CRLF+;
	"Esse processo gera a combinação de todas as rotas e faixas/tipos de veículo  da negociação que ainda não estejam cadastradas nas tarifas."+;
	CRLF+;
	"Deseja continuar?", "Gerar Tarifas")
		lRet := .F.
	EndIf
	
	If lRet
		If Select("GV8") == 0
			dbSelectArea("GV8")
		EndIf
		
		If Select("GV7") == 0
			dbSelectArea("GV7")
		EndIf
		
		If Select("GV6") == 0
			dbSelectArea("GV6")
		EndIf
		
		If Select("GV1") == 0
			dbSelectArea("GV1")
		EndIf
		
		If Select("GUY") == 0
			dbSelectArea("GUY")
		EndIf
		
		aAreaGV8 := GV8->(GetArea())
		aAreaGV7 := GV7->(GetArea())
		aAreaGV6 := GV6->(GetArea())
		aAreaGV1 := GV1->(GetArea())
		aAreaGUY := GUY->(GetArea())
		
		GV6->(dbSetOrder(1)) //GV6_FILIAL+GV6_CDEMIT+GV6_NRTAB+GV6_NRNEG+GV6_CDFXTV+GV6_NRROTA
		GV8->(dbSetOrder(1)) //GV8_FILIAL+GV8_CDEMIT+GV8_NRTAB+GV8_NRNEG+GV8_NRROTA
		GV1->(dbSetOrder(1)) //GV1_FILIAL+GV1_CDEMIT+GV1_NRTAB+GV1_NRNEG+GV1_CDFXTV+GV1_NRROTA+GV1_CDCOMP
		GUY->(dbSetOrder(1)) //GUY_FILIAL+GUY_CDEMIT+GUY_NRTAB+GUY_NRNEG+GUY_CDCOMP
		
		If GV9->GV9_TPLOTA == "1" // Carga Fracionada
			GV7->(dbSetOrder(1)) // GV7_FILIAL+GV7_CDEMIT+GV7_NRTAB+GV7_NRNEG+GV7_CDFXTV
		ElseIf GV9->GV9_TPLOTA == "2" // Carga Fechada
			GV7->(dbSetOrder(2)) // GV7_FILIAL+GV7_CDEMIT+GV7_NRTAB+GV7_NRNEG+GV7_CDTPVC
		EndIf
		
		If GV8->(dbSeek(GV9->GV9_FILIAL+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG))
			While GV8->(!Eof()) .AND. ;
					GV8->GV8_FILIAL == GV9->GV9_FILIAL .AND. ;	 
					 GV8->GV8_CDEMIT == GV9->GV9_CDEMIT .AND. ;
					 GV8->GV8_NRTAB  == GV9->GV9_NRTAB .AND. ;
					 GV8->GV8_NRNEG  == GV9->GV9_NRNEG
				 
				 If GV7->(dbSeek(GV9->GV9_FILIAL+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG))
					While GV7->(!Eof()) .AND. ;
							GV7->GV7_FILIAL == GV9->GV9_FILIAL .AND. ;
							GV7->GV7_CDEMIT == GV9->GV9_CDEMIT .AND. ;
							 GV7->GV7_NRTAB  == GV9->GV9_NRTAB .AND. ;
							 GV7->GV7_NRNEG  == GV9->GV9_NRNEG
						 
						 // Geração da tarifa = combinação das faixas x rotas
						 If !GV6->(dbSeek(GV9->GV9_FILIAL+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG+GV7->GV7_CDFXTV+GV8->GV8_NRROTA))
							RecLock("GV6",.T.)
							GV6->GV6_FILIAL := GV9->GV9_FILIAL
							GV6->GV6_CDEMIT := GV9->GV9_CDEMIT
							GV6->GV6_NRTAB  := GV9->GV9_NRTAB
							GV6->GV6_NRNEG  := GV9->GV9_NRNEG
							GV6->GV6_CDFXTV := GV7->GV7_CDFXTV
							GV6->GV6_NRROTA := GV8->GV8_NRROTA
							GV6->GV6_TPPRAZ := '1'
							GV6->GV6_CONSPZ := InitPad(AllTrim(Posicione("SX3",2,"GV6_CONSPZ","X3_RELACAO")))
							GV6->GV6_DTATU  := DDATABASE
							GV6->GV6_HRATU  := TIME()
							GV6->GV6_USUATU := CUSERNAME
							
							If lAuto
								For nX := 1 To Len(aDadosGV6)
									nFPos := GV6->(FieldPos(aDadosGV6[nX][1]))
									If nFPos <> 0
										GV6->(FieldPut(nFPos,aDadosGV6[nX][2]))
									EndIf
								Next nX
							EndIf
							
							MsUnlock()
							
							If GUY->(dbSeek(GV9->GV9_FILIAL+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+GV9->GV9_NRNEG))
								While GUY->(!Eof()) .AND. ;
										GUY->GUY_FILIAL == GV9->GV9_FILIAL .AND. ;
										GUY->GUY_CDEMIT == GV9->GV9_CDEMIT .AND. ;
										GUY->GUY_NRTAB == GV9->GV9_NRTAB .AND. ;
										GUY->GUY_NRNEG == GV9->GV9_NRNEG

									//O componente adicional de entrega não pode ser adicionado à tarifa de frete
									If !(GUY->GUY_CDCOMP == GV9->GV9_COMFXE)
										cAtribCalc := AllTrim(Posicione("GV2",1,xFilial("GV2")+GUY->GUY_CDCOMP,"GV2_ATRCAL"))
									
										If !Empty(cAtribCalc)
											RecLock("GV1",.T.)
										
											GV1->GV1_FILIAL   := GV9->GV9_FILIAL
											GV1->GV1_CDEMIT   := GV9->GV9_CDEMIT
											GV1->GV1_NRTAB    := GV9->GV9_NRTAB
											GV1->GV1_NRNEG    := GV9->GV9_NRNEG
											GV1->GV1_CDFXTV   := GV7->GV7_CDFXTV
											GV1->GV1_NRROTA 	:= GV8->GV8_NRROTA
											GV1->GV1_CDCOMP   := GUY->GUY_CDCOMP
											GV1->GV1_CALCEX   := '1'
											GV1->GV1_VLFIXN 	:= 0
											GV1->GV1_VLUNIN 	:= 0
											GV1->GV1_VLFRAC 	:= 0
											GV1->GV1_VLMINN 	:= 0
											GV1->GV1_VLFIXE	:= 0
											GV1->GV1_VLUNIE 	:= 0
											GV1->GV1_PCNORM 	:= 0
											GV1->GV1_VLLIM  	:= 0
											GV1->GV1_PCEXTR 	:= 0
											GV1->GV1_PCNORM 	:= 0
											
											If cAtribCalc $ "29" .OR. cAtribCalc == "12"
												GV1->GV1_CALCEX := '2'  
											EndIf
											
											If lAuto
												For nX := 1 To Len(aDadosGV1)
													lMod := .F.
													For nY := 1 To Len(aDadosGV1[nx])
														If aDadosGV1[nX][nY][1] == "GV1_CDCOMP" .And. aDadosGV1[nX][nY][2] == GV1->GV1_CDCOMP
															lMod := .T.
															Exit
														EndIf
													Next nY
													
													If lMod
														For nY := 1 To Len(aDadosGV1[nx])
															nFPos := GV1->(FieldPos(aDadosGV1[nX][nY][1]))
															If nFPos <> 0
																GV1->(FieldPut(nFPos,aDadosGV1[nX][nY][2]))
															EndIf
														Next nY
													EndIf
												Next nX
											EndIf
										
											MsUnlock()
										EndIf
									EndIf
									GUY->(dbSkip())
								EndDo	
							EndIf
							
							nTar += 1
						 EndIf
						 
						GV7->(dbSkip())
					EndDo
				 EndIf
				 
				GV8->(dbSkip())
			EndDo		
		EndIf 
		
		RestArea(aAreaGV8)
		RestArea(aAreaGV7)
		RestArea(aAreaGV6)
		
		If !lAuto
			MsgInfo("Total de tarifas geradas para a negociação: " + AllTrim(STR(nTar)))
		EndIf
		
	EndIf
Return lRet 
//------------------------------------------------------------------------
/*/{Protheus.doc} GFEA061LOT

Função para excluir tarifas em lote conforme filtro informado

@author Matheus de Souza
@since 10/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA061LOT()
    Local oDlg		  := NIL
	Local oPnlA		  := NIL
	Local oPnlB		  := NIL
	Local aGV6 		  := Nil
	Local aCpGV6      := Nil
	Local cAliasQuery := Nil
	Local aPergs	  := {}
	Local cCadastro   := "Exclusão de Tarifas em Lote"
	Local nAlt        := GetScreenRes()[2]
	Local nLrg        := GetScreenRes()[1]
	Local cSeqRotDe   := Space(TamSX3("GV6_NRROTA")[01])
	Local cSeqRotAt   := Space(TamSX3("GV6_NRROTA")[01])
	Local CSeqFxDe    := Space(TamSX3("GV6_CDFXTV")[01]) 
	Local CSeqFxAt    := Space(TamSX3("GV6_CDFXTV")[01])

	Private cWhere 	  := oBrwTarifas:CFILTERDEFAULT
	Private oMark	  := NIL
	Private cAliGV6	  := Nil
	Private cMarca    := GetMark()

	//Trata a altura da janela de acordo com a resolução
	nAlt -= (nAlt - 1100) * 80 / 100
	
	cWhere := sTrTran(cWhere,"==","=",1)
	cWhere := sTrTran(cWhere,".","",1)
	cWhere := "%" + cWhere + "%"
	
	cAliasQuery := GetNextAlias()
	BeginSql Alias cAliasQuery
		SELECT MIN(GV6_NRROTA) AS RTMIN,
			MAX(GV6_NRROTA) AS RTMAX,
			MIN(GV6_CDFXTV) AS FXMIN,
			MAX(GV6_CDFXTV) AS FXMAX
		FROM %Table:GV6% GV6
		WHERE %Exp:cWhere% 
		AND GV6.%NotDel%
	EndSql
	If (cAliasQuery)->(!Eof())
		cSeqRotDe := (cAliasQuery)->RTMIN
		cSeqRotAt := (cAliasQuery)->RTMAX
		CSeqFxDe  := (cAliasQuery)->FXMIN
		CSeqFxAt  := (cAliasQuery)->FXMAX
	EndIf
	(cAliasQuery)->(DbCloseArea())
	
	aAdd(aPergs, {1, "Rota de"      , cSeqRotDe,  "@!", ".T.", "",".T.", 50,  .T.})
	aAdd(aPergs, {1, "Rota até"     , cSeqRotAt,  "@!", ".T.", "",".T.", 50,  .T.})
	aAdd(aPergs, {1, "Seq Faixa de" , CSeqFxDe,   "@!", ".T.", "",".T.", 50,  .T.})
	aAdd(aPergs, {1, "Seq Faixa até", CSeqFxAt,   "@!", ".T.", "",".T.", 50,  .T.})
	
	If !ParamBox(aPergs, "Informe os parâmetros")
		Return
	EndIf
	
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	aGV6 := {{"OK"      ,"C", 02                     , 0},;
			{"FILIAL"   ,"C", TamSX3("GV6_FILIAL")[1], 0},;
			{"EMITENTE" ,"C", TamSX3("GV6_CDEMIT")[1], 0},;
			{"NMEMIT"   ,"C", TamSX3("GU3_NMEMIT")[1], 0},;
			{"NRTABELA" ,"C", TamSX3("GV6_NRTAB")[1] , 0},;
			{"NRNEG"    ,"C", TamSX3("GV6_NRNEG")[1] , 0},;
			{"FAIXA"    ,"C", TamSX3("GV6_CDFXTV")[1], 0},;
			{"NRROTA"   ,"C", TamSX3("GV6_NRROTA")[1], 0},;
			{"RECNUM"   ,"N", 10, 0}}

	aCpGV6 := {{"OK"       ,NIL, "",""				 },;
			   {"FILIAL"   ,Nil, "Filial","@!"       },;
			   {"EMITENTE" ,NIL, "Emitente","@!"	 },;
			   {"NMEMIT"   ,Nil, "Nome","@!"         },;
			   {"NRTABELA" ,NIL, "Nr Tabela","@!"	 },;
			   {"NRNEG"    ,NIL, "Nr Neg","@!"	     },;
			   {"FAIXA"    ,NIL, "Faixa Veículo","@!"},;
			   {"NRROTA"   ,NIL, "Nr Rota","@!"		 }}

	cAliGV6 := GFECriaTab({aGV6, {"EMITENTE"}})

	CursorWait()

	Processa({|lEnd| GFEA61Load(cAliGV6)}, "Filtrando tarifas...", "Aguarde")
	
	(cAliGV6)->(dbSetOrder(1))
	(cAliGV6)->(dbGoTop())

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.

	oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,35,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT
	
	@ 07,10  Say "Faixas de Rotas de: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 05,75  MsGet MV_PAR01 Picture "@!" When .F. Pixel Of oPnlA
	@ 07,170 Say "Faixas de Rotas até: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 05,240 MsGet MV_PAR02 Picture "@!" When .F. Pixel Of oPnlA

	@ 23,10  Say "Faixas da Negociação de: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 21,75  MsGet MV_PAR03 Picture"@!" When .F. Pixel Of oPnlA
	@ 23,170 Say "Faixas da Negociação até: " COLOR CLR_BLACK Pixel Of oPnlA
	@ 21,240 MsGet MV_PAR04 Picture "@!" When .F. Pixel Of oPnlA
	
	oMark := MsSelect():New(cAliGV6,"OK",,aCpGV6,,@cMarca,{0,0,0,0},,,oPnlB)
	oMark:oBrowse:bLDblClick := {|| GFE061CHK() }
	oMark:oBrowse:cToolTip := "Excluir"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	CursorArrow()

	Activate MsDialog oDlg ON Init EnchoiceBar(ODlg, {|| If(GFE061PROC(), ODlg:End(), NIL)}, {|| If(APMSGYESNO("Deseja cancelar esse processo?"), ODlg:End(),)},,{}) CENTERED

	GFEDelTab(cAliGV6)
Return

//------------------------------------------------------------------------
/*/{Protheus.doc} GFEA61Load

Carrega os registros de acordo com o filtro informado

@author Matheus de Souza
@since 10/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEA61Load(cAliGV6)
	Local cAliasQry := GetNextAlias()
	
	DbSelectArea(cAliGV6)
	ZAP
	BeginSql Alias cAliasQry
		SELECT GV6_FILIAL
			 , GV6_CDEMIT
			 , GV6_NRTAB
			 , GV6_NRNEG
			 , GV6_CDFXTV
			 , GV6_NRROTA
			 , R_E_C_N_O_ AS RECNUM
		FROM %Table:GV6% GV6
		WHERE %Exp:cWhere% 
		AND GV6.GV6_NRROTA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
		AND GV6.GV6_CDFXTV BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND GV6.%NotDel%
		ORDER BY GV6_NRROTA
	EndSql
	While (cAliasQry)->(!Eof())
		RecLock((cAliGV6),.T.)
			(cAliGV6)->OK       := cMarca
			(cAliGV6)->FILIAL   := (cAliasQry)->GV6_FILIAL
			(cAliGV6)->EMITENTE := (cAliasQry)->GV6_CDEMIT
			(cAliGV6)->NMEMIT	:= Posicione("GU3",1,xFilial("GU3")+(cAliasQry)->GV6_CDEMIT,"GU3_NMEMIT")
			(cAliGV6)->NRTABELA := (cAliasQry)->GV6_NRTAB
			(cAliGV6)->NRNEG	:= (cAliasQry)->GV6_NRNEG
			(cAliGV6)->FAIXA    := (cAliasQry)->GV6_CDFXTV
			(cAliGV6)->NRROTA   := (cAliasQry)->GV6_NRROTA
			(cAliGV6)->RECNUM	:= (cAliasQry)->RECNUM
		(cAliGV6)->(MsUnlock())

		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return .T.

//------------------------------------------------------------------------
/*/{Protheus.doc} GFE061CHK

Marca/desmarca os registros em tela

@author Matheus de Souza
@since 10/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFE061CHK()
	RecLock(cAliGV6,.F.)
		(cAliGV6)->OK := If(IsMark('OK', cMarca), "  ", cMarca)
	(cAliGV6)->(MsUnLock())

	oMark:oBrowse:Refresh()
Return

//------------------------------------------------------------------------
/*/{Protheus.doc} GFE061PROC

Processa os registros selecionados

@author Matheus de Souza
@since 26/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFE061PROC()
	Local lRet := .T.
	FwMsgRun( , { || lRet := GFE061DEL() },"Processando","Excluindo registros selecionados..." )
Return lRet

//------------------------------------------------------------------------
/*/{Protheus.doc} GFE061DEL

Exclui os registros selecionados

@author Matheus de Souza
@since 12/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFE061DEL()
	Local nX       := 0
	Local nY       := 0
	Local nCount   := 0
	Local lRet     := .T.
	Local lMark    := .F.
 	Local aErro	   := {}
	Local aMsgProc := {}
	Local oModel   := Nil
	Local oVwProc  := GFEViewProc():New()
	
	CursorWait()
	(cAliGV6)->(DbGoTop())
	If !(cAliGV6)->(Eof())
		While (cAliGV6)->(!Eof())
			If (cAliGV6)->OK == cMarca
				nCount++
				GV6->(DbGoto((cAliGV6)->RECNUM))
				
				oModel := FwLoadModel("GFEA061F")
				oModel:SetOperation(MODEL_OPERATION_DELETE)
				If !oModel:Activate() .Or. !oModel:VldData()
					aErro := oModel:GetErrorMessage()
					aAdd(aMsgProc, { nCount,;
									(cAliGV6)->FAIXA,;
									(cAliGV6)->NRROTA,;
									AllToChar(aErro[6]) + AllToChar(aErro[7])})	
				Else 
					oModel:CommitData()
				EndIf
				oModel:DeActivate()
				FreeObj(oModel)

				aSize(aErro,0)
				lMark := .T.
			EndIf 
			(cAliGV6)->(dbskip())
		EndDo

		// Processamento das mensagens da rotina
		If lMark
			CursorArrow()
			For nX := 1 To Len(aMsgProc)
				If nY != aMsgProc[nX,1]
					nY := aMsgProc[nX,1]
					oVwProc:AddErro( "Erro(s) no registro " + cValToChar(nY) + ": "+ "Faixa: "+cValToChar(aMsgProc[nX,2]) + " Rota: "+ cValToChar(aMsgProc[nX,3]) + CRLF +;
					"Mensagem: " + aMsgProc[nX,4])
				EndIf
			Next nX

			If Len(aMsgProc) == 0
				oVwProc:Add("")
				oVwProc:Add("As Tarifas selecionadas foram excluidas com sucesso!")
			EndIf
			oVwProc:Show("Excluir em Lote", "Tarifas", "Erros", "Um ou mais registros não foram excluídos com sucesso. Clique em 'Erros' para mais detalhes.")
		Else
			MsgAlert("Nenhum registro selecionado para exclusão!","Atenção")
		EndIf
	EndIf
	FreeObj(oVwProc)
Return lRet
