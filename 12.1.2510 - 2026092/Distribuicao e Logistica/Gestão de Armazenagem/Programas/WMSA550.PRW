#INCLUDE "WMSA550.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------
/*/{Protheus.doc} WMSA550
Monitor de Montagem de Unitizadores
@author  Guilherme A. Metzger
@since   03/04/2017
@version 1.0
/*/
//--------------------------------------------------
Static oBrowse := Nil
Function WMSA550()
Local nTime := SuperGetMV('MV_WMSREFS',.F.,10) // Tempo em segundos para refresh da tela (Default = 10 segundos)

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	
	If Pergunte('WMSA550',.T.)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("D0Q")
		oBrowse:SetMenuDef("WMSA550")
		oBrowse:SetDescription(STR0001) // "Montagem de Unitizadores"
		oBrowse:DisableDetails()
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:SetParam({|| SelFiltro() })
		oBrowse:SetTimer({|| RefreshBrw() }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR15 < 4)})
		oBrowse:AddLegend("D0Q->D0Q_STATUS=='1'","RED"   ,STR0002) // "Pendente"
		oBrowse:AddLegend("D0Q->D0Q_STATUS=='2'","YELLOW",STR0003) // "Em Andamento"
		oBrowse:AddLegend("D0Q->D0Q_STATUS=='3'","GREEN" ,STR0004) // "Finalizado"
		oBrowse:SetProfileID('D0Q')
		oBrowse:Activate()
	EndIf

Return Nil

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Função MenuDef
@author  Guilherme A. Metzger
@since   03/04/2017
@version 1.0
/*/
//--------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0005 ACTION "WMS550Mtor()" OPERATION 2 ACCESS 0 // "Monitor"

Return aRotina

//--------------------------------------------------
/*/{Protheus.doc} Filtro
Montagem do filtro para o browse principal da rotina
@author  Guilherme A. Metzger
@since   03/04/2017
@version 1.0
/*/
//--------------------------------------------------
Static Function Filtro()
Local cFiltro := ""

	cFiltro += " D0Q_FILIAL = '"+xFilial('D0Q')+"'"
	If MV_PAR01 < 4
		cFiltro += " AND D0Q_STATUS = '"+LTrim(Str(MV_PAR01))+"'"
	EndIf
	cFiltro += " AND D0Q_DOCTO  >= '"+MV_PAR02+"'"
	cFiltro += " AND D0Q_DOCTO  <= '"+MV_PAR03+"'"
	cFiltro += " AND D0Q_DATA   >= '"+DtoS(MV_PAR04)+"'"
	cFiltro += " AND D0Q_DATA   <= '"+DtoS(MV_PAR05)+"'"
	cFiltro += " AND D0Q_CODPRO >= '"+MV_PAR06+"'"
	cFiltro += " AND D0Q_CODPRO <= '"+MV_PAR07+"'"
	cFiltro += " AND D0Q_CLIFOR >= '"+MV_PAR08+"'"
	cFiltro += " AND D0Q_CLIFOR <= '"+MV_PAR09+"'"
	cFiltro += " AND D0Q_LOJA   >= '"+MV_PAR10+"'"
	cFiltro += " AND D0Q_LOJA   <= '"+MV_PAR11+"'"
	cFiltro += " AND D0Q_LOCAL  >= '"+MV_PAR12+"'"
	cFiltro += " AND D0Q_LOCAL  <= '"+MV_PAR13+"'"
	// O novo WMS ainda não contempla o apontamento do produção
	If !Empty(MV_PAR14) .And. MV_PAR14 != "ALL"
		cFiltro += " AND D0Q_ORIGEM = '"+MV_PAR14+"'"
	EndIf
	cFiltro += " AND D_E_L_E_T_ = ' '"

Return cFiltro

//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro()
Local nPos := oBrowse:At()
Local lRet := .T.

	If (lRet := Pergunte('WMSA550',.T.))
		oBrowse:oTimer:lActive := (MV_PAR15 < 4)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:Refresh(.T.)
	EndIf
Return lRet
//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw()
Local nPos := oBrowse:At()

	Pergunte('WMSA550',.F.) // Força recarregar as perguntas
	oBrowse:SetFilterDefault("@"+Filtro())
	If MV_PAR15 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR15 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf
Return .T.

//--------------------------------------------------
/*/{Protheus.doc} Monitor
Tela do Monitor da Montagem de Unitizadores
@author  Guilherme A. Metzger
@since   17/04/2017
@version 1.0
/*/
//--------------------------------------------------
Function WMS550Mtor()
Local oDlg        := Nil
Local oMaster     := Nil
Local oSize       := Nil
Local oLayer      := Nil
Local oPanelLeft  := Nil
Local oPanelRight := Nil
Local oRel        := Nil
Local oPanel2     := Nil
Local aPosSize    := {}
Local aColsSX3    := {}
Local nOpcA       := 0
Local nTime       := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oBrwD0R     := Nil
Local oBrwD0S     := Nil

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar

	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 40, .T., .T. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()

	// Desenha a dialog
	Define MsDialog oDlg TITLE STR0001 ; // "Montagem de Unitizadores"
	  FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
	    TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	// Cria as variáveis de memória usadas pela Enchoice
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
	             oSize:GetDimension("MASTER","COLINI"),;
	             oSize:GetDimension("MASTER","LINEND"),;
	             oSize:GetDimension("MASTER","COLEND")}

	oMaster := MsMGet():New("D0Q",D0Q->(Recno()),2,,,,,aPosSize,,3,,,,oDlg,,,,,.T./*lNoFolder*/)

	aPosSize := {oSize:GetDimension("DETAIL","LININI"),;
	             oSize:GetDimension("DETAIL","COLINI"),;
	             oSize:GetDimension("DETAIL","XSIZE" ),;
	             oSize:GetDimension("DETAIL","YSIZE" )}

	oPanel2       := TPanel():New(aPosSize[1],aPosSize[2],'',oDlg,,.T.,.T.,,,aPosSize[3],aPosSize[4],.T.,.T.)
	oPanel2:Align := CONTROL_ALIGN_BOTTOM

	oLayer := FWLayer():New()
	oLayer:Init(oPanel2,.F.,.T.)

	oLayer:AddCollumn("LEFT" ,50,.F.)
	oLayer:AddCollumn("RIGHT",50,.F.)

	oPanelLeft  := oLayer:GetColPanel('LEFT')
	oPanelRight := oLayer:GetColPanel('RIGHT')

	// Define Browse Volume (D0R)
	oBrwD0R := FWMBrowse():New()
	oBrwD0R:SetOwner(oPanelLeft)
	oBrwD0R:SetDescription(STR0006) // "Unitizadores"
	oBrwD0R:SetAlias('D0R')
	oBrwD0R:SetAmbiente(.F.)
	oBrwD0R:SetWalkThru(.F.)
	oBrwD0R:SetMenuDef('')
	oBrwD0R:DisableDetails()
	oBrwD0R:SetFixedBrowse(.T.)
	oBrwD0R:SetProfileID('D0R')
	oBrwD0R:AddLegend("D0R->D0R_STATUS=='1'", "RED"   , STR0008) // "Em Montagem"
	oBrwD0R:AddLegend("D0R->D0R_STATUS=='2'", "YELLOW", STR0009) // "Aguardando Geração OS"
	oBrwD0R:AddLegend("D0R->D0R_STATUS=='3'", "BLUE"  , STR0010) // "OS Gerada"
	oBrwD0R:AddLegend("D0R->D0R_STATUS=='4'", "GREEN" , STR0014) // "Endereçado"
	oBrwD0R:AddLegend("D0R->D0R_STATUS=='5'", "ORANGE" ,STR0016) // "Em Conferência"
	oBrwD0R:AddLegend("D0R->D0R_STATUS=='6'", "BLACK" , STR0017) // "Aguardando Classificação NF"
	oBrwD0R:AddButton(STR0015, {|| oTimer:DeActivate(), Iif(ExcluirOS(),(oBrwD0R:Refresh(),oBrwD0S:Refresh()),.F.), oTimer:Activate()},, 4, 0) // "Excluir OS End."
	oBrwD0R:SetFilterDefault(FiltroUnit())
	oBrwD0R:Activate()

	// Define Browse Produtos (D0S)
	oBrwD0S := FWMBrowse():New()
	oBrwD0S:SetOwner(oPanelRight)
	oBrwD0S:SetDescription(STR0007) // "Itens do Unitizador"
	oBrwD0S:SetAlias('D0S')
	oBrwD0S:SetFields({{BuscarSx3("D0Q_DOCTO",,aColsSX3),{|| GetDocto()},"C",	aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,"1"}})
	oBrwD0S:SetAmbiente(.F.)
	oBrwD0S:SetWalkThru(.F.)
	oBrwD0S:SetMenuDef('')
	oBrwD0S:DisableDetails()
	oBrwD0S:SetFixedBrowse(.T.)
	oBrwD0S:SetProfileID('D0S')
	oBrwD0S:Activate()

	// Relacionamento browse Itens com Pedidos
	oRel := FWBrwRelation():New()
	oRel:AddRelation(oBrwD0R,oBrwD0S,{ {"D0S_FILIAL","xFilial('D0S')"},{"D0S_IDUNIT","D0R_IDUNIT"} })
	oRel:Activate()

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| oBrwD0R:Refresh(), oBrwD0S:Refresh() },oDlg)
	oTimer:Activate()

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()})
	RefreshBrw()

Return Nil
//--------------------------------------------------
// Documento da demanda utilizado no item do unitizador
//--------------------------------------------------
Static Function GetDocto()
Local aAreaD0Q := D0Q->(GetArea())
Local cDocto := Posicione("D0Q",3,xFilial("D0Q")+D0S->D0S_IDD0Q,"D0Q_DOCTO")
RestArea(aAreaD0Q)
Return cDocto

//--------------------------------------------------
/*/{Protheus.doc} ExcluirOS
Realiza a exlusão da OS de Endereçamento Unitizado
@author  Guilherme A. Metzger
@since   08/05/2017
@version 1.0
/*/
//--------------------------------------------------
Static Function ExcluirOS()
Local lRet       := .T.
Local oMntUnitiz := WMSDTCMontagemUnitizador():New()
	If D0R->D0R_STATUS == "3"
		If WmsQuestion(WmsFmtMsg(STR0011,{{"[VAR01]",D0R->D0R_IDUNIT}})) // "Confirma a exclusão da ordem de serviço de endereçamento do unitizador [VAR01]?"
			// Seta o IDDCF
			oMntUnitiz:SetIdDCF(D0R->D0R_IDDCF)
			// Efetua a carga de dados
			If oMntUnitiz:ExcludeOS()
				WmsMessage(STR0012) // "A ordem de serviço foi excluída com sucesso."
			Else
				WmsMessage(oMntUnitiz:GetErro(),,1)
				lRet := .F.
			EndIf
		EndIf
	Else
		WmsMessage(WmsFmtMsg(STR0013,{{"[VAR01]",D0R->D0R_IDUNIT}}),,1) // "A ordem de serviço do unitizador [VAR01] ainda não foi gerada!"
		lRet := .F.
	EndIf
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} FiltroUnit
Monta o filtro do browse de Unitizadores
@author  Guilherme A. Metzger
@since   17/04/2017
@version 1.0
/*/
//--------------------------------------------------
Static Function FiltroUnit()
Local cFiltro := ""

	cFiltro +=     "@D0R_FILIAL = '"+xFilial('D0R')+"'"
	cFiltro += " AND D0R_IDUNIT IN (SELECT D0S_IDUNIT"
	cFiltro +=                      " FROM " + RetSqlName('D0S')
	cFiltro +=                     " WHERE D0S_FILIAL = '"+xFilial('D0S')+"'"
	cFiltro +=                       " AND D0S_IDD0Q  = '"+D0Q->D0Q_ID+"'"
	cFiltro +=                       " AND D_E_L_E_T_ = ' ')"

Return cFiltro
