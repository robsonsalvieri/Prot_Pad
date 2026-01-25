#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA451.CH"

#define MYCSS "QTableView { selection-background-color: #1C9DBD; }"

/*/{Protheus.doc} OFIA451
Visualiza Movimentações de Entrada e Saida dos Serviços Especializados

@author Andre Luis Almeida
@since 24/08/2022
@version 1.0
@return NIL
/*/
Function OFIA451( cFilVPY , cCodVPY , lMovVPZ )
Local lExistMov := .f.
Default cFilVPY := ""
Default cCodVPY := ""
Default lMovVPZ := .t.
//
Private lVerMov := lMovVPZ // Ver as Movimentações VPZ
//
If !Empty(cFilVPY+cCodVPY) // Visualizar Movimentações de um determinado Estoque de Serviço Especializado
	DbSelectArea("VPY")
	DbSetOrder(1)
	If DbSeek( cFilVPY + cCodVPY )
		lExistMov := .t.
		DbSelectArea("VPX")
		DbSetOrder(1) //VPX_FILIAL + VPX_SERINT
		DbSeek( VPY->VPY_FILIAL + VPY->VPY_SERINT )
		oExecView := FWViewExec():New()
		If lVerMov // Ver as Movimentações VPZ
			SetKey(VK_F5,{|| OA4510011_VisualizarMovimento(1) })
			SetKey(VK_F6,{|| OA4510031_TodosMovimentos() })
			oExecView:SetTitle(STR0001) // Visualiza Movimentações da Filial posicionada
		Else // Visualiza apenas o Estoque Atual das Filiais
			oExecView:SetTitle(STR0002) // Estoque Atual das Filiais
		EndIf
		oExecView:SetSource("OFIA451")
		oExecView:SetOperation(MODEL_OPERATION_VIEW)
		oExecView:OpenView(.T.)
		If lVerMov // Ver as Movimentações VPZ
			SetKey(VK_F5, Nil )
			SetKey(VK_F6, Nil )
		EndIf
	EndIf
	DbSelectArea("VPY")
	DbSetOrder(2)
EndIf
If !lExistMov
	Help("",1,"OFIA451",,STR0003,1,0) // Não existem movimentações de Estoque para o Serviço Especializado. Impossível continuar.
EndIf
Return

/*/{Protheus.doc} MenuDef
Função para criação do menu 

@author Andre Luis Almeida
@since 24/08/2022
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 24/08/2022
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oModel
Local oStrVPX := FWFormStruct(1, "VPX")
Local oStrVPY := FWFormStruct(1, "VPY")
Local oStrVPZ := FWFormStruct(1, "VPZ")
Local cIniMes := "" // String contendo o Inicio do MES CORRENTE. Exemplo: 20220101
Local cFinMes := "" // String contendo o Final do MES CORRENTE. Exemplo: 20220199

oModel := MPFormModel():New('OFIA451',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VPXMASTER',/*cOwner*/ 	, oStrVPX)
If  Type("lVerMov") <> "U" .and. lVerMov // Ver as Movimentações VPZ
	oModel:AddFields('VPYMASTER','VPXMASTER'	, oStrVPY)
	oModel:AddGrid('VPZDETAIL'	,'VPXMASTER'	, oStrVPZ, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )
	oModel:GetModel("VPZDETAIL"):SetNoDeleteLine( .T. )
	oModel:SetRelation( 'VPZDETAIL', { { 'VPZ_FILIAL', 'VPY_FILIAL' }, { 'VPZ_CODEST', 'VPY_CODEST' } }, VPZ->( IndexKey( 2 ) ) )
	oModel:SetDescription(STR0004) // Estoque do Serviço Especializado
	oModel:GetModel('VPXMASTER'):SetDescription(STR0005) // Serviço Especializado
	oModel:GetModel('VPYMASTER'):SetDescription(STR0006) // Estoque Atual
	oModel:GetModel('VPZDETAIL'):SetDescription(STR0007) // Movimentações
	cIniMes := dtos((dDataBase-day(dDataBase)+1)) // Exemplo: 20220101
	cFinMes := left(cIniMes,6)+"99" // Exemplo: 20220199
	oModel:GetModel("VPZDETAIL"):SetLoadFilter(," VPZ_DATMOV >= '"+cIniMes+"' AND VPZ_DATMOV <= '"+cFinMes+"' ") // Filtrar MES CORRENTE
Else // Visualiza apenas o Estoque Atual das Filiais
	oStrVPY:AddField(;
		'Legenda',; // cTitulo
		'',; // cTooltip
		'LEGENDA',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "OA4510041_LegendaEstoqueFiliais(1)"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid
	oModel:AddGrid('VPYDETAIL'	,'VPXMASTER'	, oStrVPY, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )
	oModel:GetModel("VPYDETAIL"):SetNoDeleteLine( .T. )
	oModel:SetRelation( 'VPYDETAIL', { { 'VPY_FILIAL', 'VPX_FILIAL' }, { 'VPY_SERINT', 'VPX_SERINT' } }, VPY->( IndexKey( 2 ) ) )
	oModel:SetDescription(STR0005) // Serviço Especializado
	oModel:GetModel('VPXMASTER'):SetDescription(STR0005) // Serviço Especializado
	oModel:GetModel('VPYDETAIL'):SetDescription(STR0002) // Estoque Atual das Filiais
EndIf

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel  := ModelDef()
	Local oStrVPX := FWFormStruct(2, "VPX", { |cCampo| !ALLTRIM(cCampo) $ "VPX_CUSQTD/" } )
	Local oStrVPY := FWFormStruct(2, "VPY")
	Local oStrVPZ := FWFormStruct(2, "VPZ")
	Local cAux    := ""
	Local cMesAno := ""

	oStrVPX:RemoveField('VPX_SERINT')

	oStrVPY:RemoveField('VPY_CODEST')
	oStrVPY:RemoveField('VPY_SERINT')
	
	oStrVPZ:RemoveField('VPZ_CODMOV')
	oStrVPZ:RemoveField('VPZ_CODEST')
	oStrVPZ:RemoveField('VPZ_SERINT')
	oStrVPZ:RemoveField('VPZ_FILREL')
	oStrVPZ:RemoveField('VPZ_CODREL')

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVPX', 40)
	oView:AddField('VIEW_VPX', oStrVPX, 'VPXMASTER')
	oView:EnableTitleView('VIEW_VPX', STR0005 ) // Serviço Especializado
	oView:SetOwnerView('VIEW_VPX','BOXVPX')

	If lVerMov // Ver as Movimentações VPZ

		oView:CreateHorizontalBox( 'BOXVPY', 15)
		oView:AddField('VIEW_VPY', oStrVPY, 'VPYMASTER')
		oView:EnableTitleView('VIEW_VPY', STR0006 ) // Estoque Atual
		oView:SetOwnerView('VIEW_VPY','BOXVPY')

		cAux    := dtos(dDataBase)
		cMesAno := substr(cAux,5,2)+"/"+left(cAux,4)

		oView:CreateHorizontalBox( 'BOXVPZ', 45)
		oView:AddGrid('VIEW_VPZ', oStrVPZ, 'VPZDETAIL')
		oView:EnableTitleView('VIEW_VPZ', STR0008+" ( "+cMesAno+" )"+"               <F5> "+STR0009+"               <F6> "+STR0010 ) // Movimentações de Estoque do mês corrente / Visualizar o Movimento posicionado / Lista Todas as Movimentações do Serviço Especializado
		oView:SetOwnerView('VIEW_VPZ','BOXVPZ')
		oView:SetViewProperty("VIEW_VPZ", "GRIDDOUBLECLICK", {{|| OA4510011_VisualizarMovimento(1) }})
		oView:SetViewProperty("VIEW_VPZ", "GRIDFILTER", {.T.} )
		oView:SetViewProperty("VIEW_VPZ", "GRIDSEEK"  , {.T.} )
	  	oView:SetViewProperty("VIEW_VPZ", "SETCSS", { MYCSS } )

		oView:AddUserButton("<F5> "+STR0009,'PRODUTO', {|| OA4510011_VisualizarMovimento(1) }) // Visualizar o Movimento posicionado
		oView:AddUserButton("<F6> "+STR0010,'FILTRO', {|| OA4510031_TodosMovimentos() }) // Lista Todas as Movimentações do Serviço Especializado

	Else // Visualiza apenas o Estoque Atual das Filiais

		oStrVPY:AddField( 'LEGENDA','01',' ',STR0011,, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, ) // Legenda

		oView:CreateHorizontalBox( 'BOXVPY', 60)
		oView:AddGrid('VIEW_VPY', oStrVPY, 'VPYDETAIL')
		oView:EnableTitleView('VIEW_VPY', STR0002 ) // Estoque Atual das Filiais
		oView:SetOwnerView('VIEW_VPY','BOXVPY')
		oView:SetViewProperty("VIEW_VPY", "GRIDFILTER", {.T.} )
		oView:SetViewProperty("VIEW_VPY", "GRIDSEEK"  , {.T.} )
		oView:SetViewProperty("VIEW_VPY", "SETCSS", { MYCSS } )
		oView:AddUserButton(STR0011,'CLIPS' ,{ |oView| OA4510041_LegendaEstoqueFiliais(2) }) // Legenda

	EndIf

	oView:AddUserButton(STR0012+" ( "+VPX->VPX_GRUSER+" )",'PRODUTO', {|| OA3900021_EstoqueTotal(VPX->VPX_GRUSER,) }) // Estoque do Grupo de Serviço Especializado
	oView:AddUserButton(STR0013+" ( "+VPX->VPX_TIPSER+" )",'PRODUTO', {|| OA3800031_EstoqueTotal(VPX->VPX_TIPSER,) }) // Estoque do Tipo de Serviço Especializado

Return oView

/*/{Protheus.doc} OA4510011_VisualizarMovimento
Visualizar o Movimento

@author Andre Luis Almeida
@since 13/09/2022
/*/
Static Function OA4510011_VisualizarMovimento(nTp)
Local oModel
Local oModVPZ
Local cOpeMov := ""
Local cFilRel := ""
Local cCodRel := ""
Local nRecVPX := VPX->(RecNo())
Local nRecVPY := VPY->(RecNo())
//
SetKey(VK_F5, Nil )
If nTp == 1 // Objeto MVC
	SetKey(VK_F6, Nil )
	oModel  := FWModelActive()
	oModVPZ := oModel:GetModel("VPZDETAIL")
	cOpeMov := oModVPZ:GetValue("VPZ_OPEMOV")
	cFilRel := oModVPZ:GetValue("VPZ_FILREL")
	cCodRel := oModVPZ:GetValue("VPZ_CODREL")
Else // Posicionamento na tabela VPZ
	cOpeMov := VPZ->VPZ_OPEMOV
	cFilRel := VPZ->VPZ_FILREL
	cCodRel := VPZ->VPZ_CODREL
EndIf
Do Case
	Case cOpeMov == "0" // Compra - VRP/VRQ
		DbSelectArea("VRP")
		DbSetOrder(1)
		If DbSeek( cFilRel + cCodRel )
			OA4600041_VisualizarEntrada()
		EndIf
	Case cOpeMov == "1" // Venda - VRR/VRS
		DbSelectArea("VRR")
		DbSetOrder(1)
		If DbSeek( cFilRel + cCodRel )
			OA4700051_VisualizarSaida()
		EndIf
	Case cOpeMov == "2" // Transferência - VRT
		DbSelectArea("VRT")
		DbSetOrder(1)
		If DbSeek( cFilRel + cCodRel )
			OA4650041_VisualizarTransferencia()
		EndIf
EndCase
SetKey(VK_F5,{|| OA4510011_VisualizarMovimento(nTp) })
If nTp == 1 // Objeto MVC
	SetKey(VK_F6,{|| OA4510031_TodosMovimentos() })
EndIf
//
VPX->(DbGoto(nRecVPX))
VPY->(DbGoTo(nRecVPY))
//
Return

/*/{Protheus.doc} OA4510021_Detalhes()
Monta Detalhes do Movimento (SX3)

@author Andre Luis Almeida
@since 16/09/2022
/*/
Function OA4510021_Detalhes()
Local cDetalhes := ""
Local cQuery    := ""
Local cQAlias   := "SQLAUX"
Do Case
	Case VPZ->VPZ_OPEMOV == "0" // Compra - VRP/VRQ
		cQuery := "SELECT VRP.VRP_FILIAL , "
		cQuery += "       VRP.VRP_NUMNFI , VRP.VRP_SERNFI , "
		cQuery += "       VRP.VRP_CODFOR , VRP.VRP_LOJFOR , "
		cQuery += "       SA2.A2_NOME "
		cQuery += "  FROM " + RetSqlName("VRP")+" VRP "
		cQuery += "  JOIN " + RetSqlName("SA2")+" SA2 "
		cQuery += "    ON SA2.A2_FILIAL  = '" + xFilial("SA2") + "'"
		cQuery += "   AND SA2.A2_COD     = VRP.VRP_CODFOR "
		cQuery += "   AND SA2.A2_LOJA    = VRP.VRP_LOJFOR "
		cQuery += "   AND SA2.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VRP.VRP_FILIAL = '" + VPZ->VPZ_FILREL + "'"
		cQuery += "   AND VRP.VRP_CODIGO = '" + VPZ->VPZ_CODREL + "'"
		cQuery += "   AND VRP.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		If ( cQAlias )->(!Eof())
			cDetalhes := STR0014+": "+( cQAlias )->( VRP_FILIAL )+"    " // Filial
			cDetalhes += STR0015+": "+Alltrim(( cQAlias )->( VRP_NUMNFI ))+"-"+Alltrim(( cQAlias )->( VRP_SERNFI ))+"    " // NF
			cDetalhes += STR0016+": "+( cQAlias )->( VRP_CODFOR )+"-"+( cQAlias )->( VRP_LOJFOR )+" "+( cQAlias )->( A2_NOME ) // Fornecedor
		EndIf
		( cQAlias )->( dbCloseArea() )
	Case VPZ->VPZ_OPEMOV == "1" // Venda - VRR/VRS
		cQuery := "SELECT VRR.VRR_FILIAL , "
		cQuery += "       VRR.VRR_NUMNFI , VRR.VRR_SERNFI , "
		cQuery += "       VRR.VRR_CODCLI , VRR.VRR_LOJCLI , "
		cQuery += "       SA1.A1_NOME "
		cQuery += "  FROM " + RetSqlName("VRR")+" VRR "
		cQuery += "  JOIN " + RetSqlName("SA1")+" SA1 "
		cQuery += "    ON SA1.A1_FILIAL  = '" + xFilial("SA1") + "'"
		cQuery += "   AND SA1.A1_COD     = VRR.VRR_CODCLI "
		cQuery += "   AND SA1.A1_LOJA    = VRR.VRR_LOJCLI "
		cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VRR.VRR_FILIAL = '" + VPZ->VPZ_FILREL + "'"
		cQuery += "   AND VRR.VRR_CODIGO = '" + VPZ->VPZ_CODREL + "'"
		cQuery += "   AND VRR.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		If ( cQAlias )->(!Eof())
			cDetalhes := STR0014+": "+( cQAlias )->( VRR_FILIAL )+"    " // Filial
			cDetalhes += STR0015+": "+Alltrim(( cQAlias )->( VRR_NUMNFI ))+"-"+Alltrim(( cQAlias )->( VRR_SERNFI ))+"    " // NF
			cDetalhes += STR0017+": "+( cQAlias )->( VRR_CODCLI )+"-"+( cQAlias )->( VRR_LOJCLI )+" "+( cQAlias )->( A1_NOME ) // Fornecedor
		EndIf
		( cQAlias )->( dbCloseArea() )
	Case VPZ->VPZ_OPEMOV == "2" // Transferência - VRT
		cQuery := "SELECT VRT.VRT_TIPTRA , "
		cQuery += "       VRT.VRT_FILORI , "
		cQuery += "       VRT.VRT_FILDES   "
		cQuery += "  FROM " + RetSqlName("VRT")+" VRT "
		cQuery += " WHERE VRT.VRT_FILIAL = '" + VPZ->VPZ_FILREL + "'"
		cQuery += "   AND VRT.VRT_CODIGO = '" + VPZ->VPZ_CODREL + "'"
		cQuery += "   AND VRT.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
		If ( cQAlias )->(!Eof())
			cDetalhes := IIf(( cQAlias )->( VRT_TIPTRA )=="0",STR0018,STR0019)+"        " // Manual / Automática
			cDetalhes += STR0020+": "+Alltrim(( cQAlias )->( VRT_FILORI ))+" - "+Alltrim(FWFilialName( , ( cQAlias )->( VRT_FILORI ) ))+"        " // Filial Origem
			cDetalhes += STR0021+": "+Alltrim(( cQAlias )->( VRT_FILDES ))+" - "+Alltrim(FWFilialName( , ( cQAlias )->( VRT_FILDES ) )) // Filial Destino
		EndIf
		( cQAlias )->( dbCloseArea() )
EndCase
DbSelectArea("VPZ")
Return padr(cDetalhes,GeTSX3Cache("VPZ_DETALH","X3_TAMANHO"))

/*/{Protheus.doc} OA4510031_TodosMovimentos()
Lista Todos os Movimentos

@author Andre Luis Almeida
@since 20/09/2022
/*/
Static Function OA4510031_TodosMovimentos()
Local aSize       := FWGetDialogSize( oMainWnd )
Local cFiltVPZ    := "@ VPZ_FILIAL='"+VPY->VPY_FILIAL+"' AND VPZ_CODEST='"+VPY->VPY_CODEST+"'"
Local nRecVPX     := VPX->(RecNo())
Local nRecVPY     := VPY->(RecNo())
Private cCadastro := STR0022 // Movimentações do Serviço Especializado
Private aRotina   := {}
//
SetKey(VK_F5,{|| OA4510011_VisualizarMovimento(2) })
SetKey(VK_F6, Nil )
//
oDlgOA451 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
//
oWorkArea := FWUIWorkArea():New( oDlgOA451 )
oWorkArea:CreateHorizontalBox( "LINE01", 100 , .t. )
oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
oWorkArea:CreateHorizontalBox( "LINE02",  90 , .f. )
oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )
oWorkArea:Activate()
//
oTPanObj1 := TPanelCss():New(0,0,"",oWorkarea:GetPanel("OBJ1"),,.F.,.F.,,,00,15,.T.,.F.)
oTPanObj1:Align := CONTROL_ALIGN_ALLCLIENT
oSayGrp := tSay():New( 006,005, {|| RetTitle("VPX_GRUSER") } , oTPanObj1,,,,,, .T., CLR_BLUE, CLR_WHITE, 040, 010)
oGetGrp := TGet():New( 016,005, {|| VPX->VPX_GRUSER },oTPanObj1, 035, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"",,,,)
oSayCod := tSay():New( 006,045, {|| RetTitle("VPX_CODSER") } , oTPanObj1,,,,,, .T., CLR_BLUE, CLR_WHITE, 060, 010)
oGetCod := TGet():New( 016,045, {|| VPX->VPX_CODSER },oTPanObj1, 080, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"",,,,)
oSayDes := tSay():New( 006,130, {|| RetTitle("VPX_DESSER") } , oTPanObj1,,,,,, .T., CLR_BLUE, CLR_WHITE, 060, 010)
oGetDes := TGet():New( 016,130, {|| VPX->VPX_DESSER },oTPanObj1, 155, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"",,,,)
oSayTip := tSay():New( 006,290, {|| RetTitle("VPX_TIPSER") } , oTPanObj1,,,,,, .T., CLR_BLUE, CLR_WHITE, 040, 010)
oGetTip := TGet():New( 016,290, {|| VPX->VPX_TIPSER },oTPanObj1, 035, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"",,,,)
oSayFil := tSay():New( 006,330, {|| RetTitle("VPY_FILEST") } , oTPanObj1,,,,,, .T., CLR_BLUE, CLR_WHITE, 060, 010)
oGetFil := TGet():New( 016,330, {|| VPY->VPY_FILEST },oTPanObj1, 060, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"",,,,)
oSayNom := tSay():New( 006,395, {|| RetTitle("VPY_NOMFIL") } , oTPanObj1,,,,,, .T., CLR_BLUE, CLR_WHITE, 060, 010)
oGetNom := TGet():New( 016,395, {|| FWFilialName( , VPY->VPY_FILEST ) },oTPanObj1, 140, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"",,,,)
oSayQtd := tSay():New( 006,540, {|| STR0023 } , oTPanObj1,,,,,, .T., CLR_BLUE, CLR_WHITE, 060, 010) // Qtd.Estoque Atual
oGetQtd := TGet():New( 016,540, {|| VPY->VPY_QTDEST },oTPanObj1, 060, 010, "@E 999,999,999",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"",,,,)
//
oBrwVPZ := FWMBrowse():New()
oBrwVPZ:SetAlias("VPZ")
oBrwVPZ:SetOwner(oWorkarea:GetPanel("OBJ2"))
oBrwVPZ:SetDescription(STR0024) // Movimentações de Estoque da Filial posicionada
oBrwVPZ:AddLegend( "VPZ_TIPMOV == '0'" , "BR_BRANCO"  , STR0025+": "+STR0026 ) // Tipo / Entrada
oBrwVPZ:AddLegend( "VPZ_TIPMOV == '1'" , "BR_LARANJA" , STR0025+": "+STR0027 ) // Tipo / Saida
oBrwVPZ:AddFilter( STR0028+": "+STR0029 , " VPZ_PORMOV == '0' ") // Movimento / Normal
oBrwVPZ:AddFilter( STR0028+": "+STR0030 , " VPZ_PORMOV == '1' ") // Movimento / por Cancelamento
oBrwVPZ:AddFilter( STR0031+": "+STR0032 , " VPZ_OPEMOV == '0' ") // Operação / Compra
oBrwVPZ:AddFilter( STR0031+": "+STR0033 , " VPZ_OPEMOV == '1' ") // Operação / Venda
oBrwVPZ:AddFilter( STR0031+": "+STR0034 , " VPZ_OPEMOV == '2' ") // Operação / Transferência
oBrwVPZ:SetMenuDef( '' )
oBrwVPZ:AddButton("<F5> "+STR0009,{ || OA4510011_VisualizarMovimento(2) } ) // Visualizar o Movimento posicionado
oBrwVPZ:SetDoubleClick( {|| OA4510011_VisualizarMovimento(2) })
oBrwVPZ:SetFilterDefault( cFiltVPZ )
oBrwVPZ:DisableDetails()
oBrwVPZ:Activate()
//
oDlgOA451:Activate( , , , .t. , , , EnchoiceBar( oDlgOA451, {|| oDlgOA451:End() }, { || oDlgOA451:End() }, ,, , , , , .F., .T. ) )
//
SetKey(VK_F5,{|| OA4510011_VisualizarMovimento(1) })
SetKey(VK_F6,{|| OA4510031_TodosMovimentos() })
//
VPX->(DbGoto(nRecVPX))
VPY->(DbGoTo(nRecVPY))
//
Return

/*/{Protheus.doc} OA4510041_LegendaEstoqueFiliais
Legenda Grid ( 1o.Campo )

@author Andre Luis Almeida
@since 07/10/2022
/*/
Function OA4510041_LegendaEstoqueFiliais(nTp)
Local cFilSD2  := xFilial("SD2")
Local aLegenda := {}
If nTp == 1 // 1 - retorna o BitMap (azul) somente para a Filial atual (logada)
	If !INCLUI
		If VPY->VPY_FILEST == cFilSD2
			Return "br_azul.png" // Filial posicionada
		Else
			Return "br_branco.png" // Demais Filiais
		EndIf
	EndIf
Else // 2 - Mostrar Legenda
	aadd(aLegenda, {'BR_AZUL', STR0035+": "+cFilSD2+" - "+FWFilialName( , cFilSD2 ) }) // Filial posicionada
	aadd(aLegenda, {'BR_BRANCO', STR0036 }) // Demais Filiais
	BrwLegenda(STR0037,STR0011,aLegenda) // Estoque nas Filiais / Legenda
EndIf
Return ""