#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA570.CH"

Static oMarkBrw := Nil
Static lMarkAll := .F. // Indicador de marca/desmarca todos
Static aErro := {}
//--------------------------------------------------------------
/*/{Protheus.doc} WMSA570
Unitizadores Montados.
@author felipe.m
@since 25/10/2017
@version 1.0

@return return, Nil
@see DLOGWMSMSP-2153
/*/
//--------------------------------------------------------------
Function WMSA570()
Local aAreaAnt := GetArea()
Local aAreaD0R := D0R->(GetArea())

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	
	If !Pergunte("WMSA570",.T.)
		RestArea(aAreaD0R)
		RestArea(aAreaAnt)
		Return Nil
	EndIf

	oMarkBrw:= FWMarkBrowse():New()
	oMarkBrw:SetDescription(STR0001) // "Unitizadores Montados"
	oMarkBrw:SetMenuDef("WMSA570")
	oMarkBrw:SetAlias("D0R")
	oMarkBrw:SetFieldMark("D0R_OK")
	oMarkBrw:SetAllMark({||AllMark()})
	oMarkBrw:AddLegend("D0R_STATUS=='1'", "RED"   , STR0002) // "Em Montagem"
	oMarkBrw:AddLegend("D0R_STATUS=='2'", "YELLOW", STR0003) // "Aguardando Geração OS"
	oMarkBrw:AddLegend("D0R_STATUS=='3'", "BLUE"  , STR0004) // "OS Gerada"
	oMarkBrw:AddLegend("D0R_STATUS=='4'", "GREEN" , STR0005) // "Endereçado"
	oMarkBrw:AddLegend("D0R_STATUS=='5'", "ORANGE", STR0006) // "Em Conferência"
	oMarkBrw:AddLegend("D0R_STATUS=='6'", "BLACK" , STR0007) // "Aguardando Classificação NF"
	oMarkBrw:SetFilterDefault( Filtro() )
	oMarkBrw:SetParam({|| UpdSelecao()})
	oMarkBrw:Activate()

RestArea(aAreaD0R)
RestArea(aAreaAnt)
Return Nil
//--------------------------------------------------------------
Static Function MenuDef()
//--------------------------------------------------------------
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0008 ACTION "AxPesqui"      OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0009 ACTION "WMS570Mtor()"  OPERATION 2 ACCESS 0 // "Monitor"
	ADD OPTION aRotina TITLE STR0010 ACTION "WMS570GOs()"   OPERATION 2 ACCESS 0 // "Gerar OS"
	ADD OPTION aRotina TITLE STR0011 ACTION "WMS570EOS()"   OPERATION 5 ACCESS 0 // "Excluir OS"

Return aRotina
//--------------------------------------------------------------
Function WMS570Mtor()
//--------------------------------------------------------------
Local oDlg        := Nil
Local oSize       := Nil
Local oPanel      := Nil
Local oLayer      := Nil
Local oPanelLeft  := Nil
Local oPanelRight := Nil
Local oRel        := Nil
Local oBrwD0Q     := Nil
Local oBrwD0S     := Nil
Local aPosSize    := {}

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar
	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 30, .T., .T. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 70, .T., .T. ) // Adiciona enchoice
	oSize:lProp := .T. // Proporciona as dimenções de Y (30 e 70)
	// Dispara o calculo
	oSize:Process()

	// Desenha a dialog
	Define MsDialog oDlg TITLE STR0001 ; // "Unitizadores Montados"
	  FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
	    TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	// Cria as dimensões da MASTER
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
	             oSize:GetDimension("MASTER","COLINI"),;
	             oSize:GetDimension("MASTER","LINEND"),;
	             oSize:GetDimension("MASTER","COLEND")}

	// Monta a Enchoice
	MsMGet():New("D0R",D0R->(Recno()),2,,,,,aPosSize,,3,,,,oDlg,,,,,.T./*lNoFolder*/)

	// Cria as dimensões do DETAIL
	aPosSize := {oSize:GetDimension("DETAIL","LININI"),;
	             oSize:GetDimension("DETAIL","COLINI"),;
	             oSize:GetDimension("DETAIL","XSIZE" ),;
	             oSize:GetDimension("DETAIL","YSIZE" )}

	oPanel       := TPanel():New(aPosSize[1],aPosSize[2],'',oDlg,,.T.,.T.,,,aPosSize[3],aPosSize[4],.T.,.T.)
	oPanel:Align := CONTROL_ALIGN_BOTTOM

	oLayer := FWLayer():New()
	oLayer:Init(oPanel,.F.,.T.)

	oLayer:AddCollumn("LEFT" ,50,.T.)
	oLayer:AddCollumn("RIGHT",50,.T.)

	oPanelLeft  := oLayer:GetColPanel("LEFT")
	oPanelRight := oLayer:GetColPanel("RIGHT")

	// Define Browse Produtos (D0S)
	oBrwD0S := FWMBrowse():New()
	oBrwD0S:SetOwner(oPanelLeft)
	oBrwD0S:SetDescription(STR0012) // "Itens do Unitizador"
	oBrwD0S:SetAlias("D0S")
	oBrwD0S:SetAmbiente(.F.)
	oBrwD0S:SetWalkThru(.F.)
	oBrwD0S:SetMenuDef('')
	oBrwD0S:DisableDetails()
	oBrwD0S:SetFixedBrowse(.T.)
	oBrwD0S:SetProfileID("D0S")
	oBrwD0S:SetFilterDefault( "@D0S_IDUNIT = '"+D0R->D0R_IDUNIT+"'" )
	oBrwD0S:Activate()

	// Define Browse Volume (D0Q)
	oBrwD0Q := FWMBrowse():New()
	oBrwD0Q:SetOwner(oPanelRight)
	oBrwD0Q:SetDescription(STR0013) // "Demanda de Unitização"
	oBrwD0Q:SetAlias("D0Q")
	oBrwD0Q:SetAmbiente(.F.)
	oBrwD0Q:SetWalkThru(.F.)
	oBrwD0Q:SetMenuDef('')
	oBrwD0Q:DisableDetails()
	oBrwD0Q:SetFixedBrowse(.T.)
	oBrwD0Q:SetProfileID("D0Q")
	oBrwD0Q:AddLegend("D0Q->D0Q_STATUS=='1'", "RED"   , STR0014) // "Pendente"
	oBrwD0Q:AddLegend("D0Q->D0Q_STATUS=='2'", "YELLOW", STR0015) // "Em Andamento"
	oBrwD0Q:AddLegend("D0Q->D0Q_STATUS=='3'", "GREEN" , STR0016) // "Finalizado"
	oBrwD0Q:Activate()

	// Relacionamento browse Itens com Pedidos
	oRel := FWBrwRelation():New()
	oRel:AddRelation(oBrwD0S,oBrwD0Q,{ {"D0Q_FILIAL","xFilial('D0Q')"},{"D0Q_ID","D0S_IDD0Q"} })
	oRel:Activate()

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()})

Return Nil
//--------------------------------------------------------------
Static Function Filtro()
//--------------------------------------------------------------
Local cFiltro := ""

	cFiltro +=     "@D0R_LOCAL  >= '"+MV_PAR01+"' AND D0R_LOCAL  <= '"+MV_PAR02+"'"
	cFiltro += " AND D0R_ENDER  >= '"+MV_PAR03+"' AND D0R_ENDER  <= '"+MV_PAR04+"'"
	cFiltro += " AND D0R_IDUNIT >= '"+MV_PAR05+"' AND D0R_IDUNIT <= '"+MV_PAR06+"'"
	cFiltro += " AND D0R_DATINI >= '"+DTOS(MV_PAR07)+"' AND D0R_DATINI <= '"+DTOS(MV_PAR08)+"'"

Return cFiltro
//--------------------------------------------------------------
Static Function UpdSelecao()
//--------------------------------------------------------------
	Pergunte("WMSA570",.T.)
	oMarkBrw:SetFilterDefault( Filtro() )
	oMarkBrw:Refresh()
Return
//--------------------------------------------------------------
Static Function AllMark()
//--------------------------------------------------------------
Local aAreaD0R  := D0R->(GetArea())
Local cAliasD0R := ""

	lMarkAll := !lMarkAll
	// Busca alias do próprio browse, que neste caso é a D0R
	cAliasD0R := oMarkBrw:Alias()
	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	(cAliasD0R)->(DbGoTop())
	Do While (cAliasD0R)->(!Eof())
		Reclock(cAliasD0R,.F.)
		(cAliasD0R)->D0R_OK := Iif(lMarkAll,oMarkBrw:cMark,Space(TamSx3("D0R_OK")[1]))
		(cAliasD0R)->(MsUnlock())

		(cAliasD0R)->(DbSkip())
	EndDo

RestArea(aAreaD0R)
oMarkBrw:Refresh()
Return Nil
//--------------------------------------------------------------
Function WMSA570ERR()
//--------------------------------------------------------------
Return aErro
//--------------------------------------------------------------
Function WMS570EOS()
//--------------------------------------------------------------
	Processa({|| ProcRegua(0), WMSA570EOS() },STR0011,STR0022,.T.) // "Excluir OS" ## "Excluindo OS selecionada..."
Return .T.
//--------------------------------------------------------------
Function WMSA570EOS(cMarca,lAuto)
//--------------------------------------------------------------
Local aAreaAnt := GetArea()
Local cQuery := ""
Local cAliasQry := ""
Local cCodRec := ""
Local oMntUnitiz := Nil
Local oOrdServ := Nil

Default cMarca := Iif(oMarkBrw==Nil,"",oMarkBrw:cMark)
Default lAuto := .F.

	aErro := {}
	oMntUnitiz := WMSDTCMontagemUnitizador():New()
	// Busca os unitizadores marcados para exclusão da OS
	cQuery := " SELECT D0R_IDUNIT,"
	cQuery +=        " D0R_IDDCF,"
	cQuery +=        " D0R_STATUS"
	cQuery +=   " FROM "+RetSqlName("D0R")
	cQuery +=  " WHERE D0R_FILIAL = '"+xFilial("D0R")+"'"
	cQuery +=    " AND D0R_OK = '"+cMarca+"'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())

		If !((cAliasQry)->D0R_STATUS == "3")
			aAdd(aErro,WmsFmtMsg(STR0017,{{"[VAR01]",(cAliasQry)->D0R_IDUNIT}}) + STR0018) // "Unitizador [VAR01]: "##"Ordem de serviço não pôde ser excluída, somente unitizador com situação '3=OS Gerada'."
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		If UnitInConf((cAliasQry)->D0R_IDUNIT,@cCodRec)
			aAdd(aErro,WmsFmtMsg(STR0017,{{"[VAR01]",(cAliasQry)->D0R_IDUNIT}}) + WmsFmtMsg(STR0024,{{"[VAR01]",cCodRec}})) // "Unitizador [VAR01]: "##"Exclusão da ordem de serviço não permitida, unitizador originado pela conferência de recebimento [VAR01]."
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		// Seta a ordem de serviço e exclui a mesma
		oMntUnitiz:SetIdDCF((cAliasQry)->D0R_IDDCF)
		If !oMntUnitiz:ExcludeOS()
			aAdd(aErro,WmsFmtMsg(STR0017,{{"[VAR01]",(cAliasQry)->D0R_IDUNIT}}) + oMntUnitiz:GetErro()) // "Unitizador [VAR01]: "
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	FreeObj(oMntUnitiz)

	// Exibe aviso dos erros
	If !lAuto .And. !Empty(aErro)
		oOrdServ := WMSDTCOrdemServico():New()
		oOrdServ:aWmsAviso := aErro
		oOrdServ:ShowWarnig()
		oOrdServ:Destroy()
	EndIf

RestArea(aAreaAnt)
Return .T.
//--------------------------------------------------------------
Function WMS570GOs()
//--------------------------------------------------------------
	Processa({|| WMSA570GOS() },STR0010,"...",.T.) // "Gerar OS"
//--------------------------------------------------------------
Return .T.
//--------------------------------------------------------------
Function WMSA570GOS(cMarca,lAuto)
//--------------------------------------------------------------
Local aAreaAnt := GetArea()
Local cQuery := ""
Local cAliasQry := ""
Local cCodRec := ""
Local aUnitiz := {}
Local oMntUnitiz := Nil
Local oOrdServ := Nil
Local lExibeAnt := .T.
Local lRet := .T.

Default cMarca := Iif(oMarkBrw==Nil,"",oMarkBrw:cMark)
Default lAuto := .F.

	aErro := {}
	oMntUnitiz := WMSDTCMontagemUnitizador():New()
	// Busca os unitizadores marcados para geração da OS
	cQuery := " SELECT D0R_IDUNIT,"
	cQuery +=        " D0R_STATUS"
	cQuery +=   " FROM "+RetSqlName("D0R")
	cQuery +=  " WHERE D0R_FILIAL = '"+xFilial("D0R")+"'"
	cQuery +=    " AND D0R_OK = '"+cMarca+"'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())

		If !((cAliasQry)->D0R_STATUS == "2")
			aAdd(aErro,WmsFmtMsg(STR0017,{{"[VAR01]",(cAliasQry)->D0R_IDUNIT}}) + STR0020) // "Unitizador [VAR01]: "##"Ordem de serviço não pôde ser gerada, somente unitizador com situação '2=Aguardando Geração OS'."
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		If UnitInConf((cAliasQry)->D0R_IDUNIT,@cCodRec)
			aAdd(aErro,WmsFmtMsg(STR0017,{{"[VAR01]",(cAliasQry)->D0R_IDUNIT}}) + WmsFmtMsg(STR0023,{{"[VAR01]",cCodRec}})) // "Unitizador [VAR01]: "##"Geração da ordem de serviço não permitida, unitizador originado pela conferência de recebimento [VAR01]."
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		// Deve validar se o unitizador possui itens
		oMntUnitiz:SetIdUnit((cAliasQry)->D0R_IDUNIT)
		If !oMntUnitiz:UniHasItem()
			aAdd(aErro,WmsFmtMsg(STR0017,{{"[VAR01]",(cAliasQry)->D0R_IDUNIT}}) + STR0019) // "Unitizador [VAR01]: "##"O unitizador não possui itens para o endereçamento."
			(cAliasQry)->(dbSkip())
			Loop
		EndIf

		aAdd(aUnitiz,(cAliasQry)->D0R_IDUNIT)

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	FreeObj(oMntUnitiz)

	If Len(aUnitiz) > 0
		lExibeAnt := WmsMsgExibe(.F.) // Atribui para não mostrar mensagens da função WMSV086END

		// Realiza a geração da OS dos unitizadores marcados
		If !(lRet := WMSV086END(aUnitiz))
			aAdd(aErro,STR0021 + WmsLastMsg()) // "Geração da OS: " ## Erro da geração da OS
		EndIf

		WmsMsgExibe(lExibeAnt)
	EndIf

	// Exibe aviso dos erros
	If !lAuto .And. !Empty(aErro)
		oOrdServ := WMSDTCOrdemServico():New()
		oOrdServ:aWmsAviso := aErro
		oOrdServ:ShowWarnig()
		oOrdServ:Destroy()
	EndIf

RestArea(aAreaAnt)
Return .T.
//--------------------------------------------------------------
Static Function UnitInConf(cIdUnit,cCodRec)
//--------------------------------------------------------------
Local aAreaAnt := GetArea()
Local lRet := .F.
Local cQuery := ""
Local cAliasQry := ""

	cQuery := "SELECT DCZ_EMBARQ"
	cQuery +=  " FROM "+RetSqlName("DCZ")
	cQuery += " WHERE DCZ_FILIAL = '"+xFilial("DCZ")+"'"
	cQuery +=   " AND DCZ_IDUNIT = '"+cIdUnit+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		lRet := .T.
		cCodRec := (cAliasQry)->DCZ_EMBARQ
	EndIf
	(cAliasQry)->(dbCloseArea())

RestArea(aAreaAnt)
Return lRet
