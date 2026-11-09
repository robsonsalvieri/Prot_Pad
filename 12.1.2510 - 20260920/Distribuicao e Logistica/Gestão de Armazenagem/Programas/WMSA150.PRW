#Include "Protheus.ch"
#Include "WMSA150.CH"
#INCLUDE "FWMVCDEF.CH"
#include "tbiconn.ch"

#DEFINE WMSA15001 "WMSA15001"
#DEFINE WMSA15002 "WMSA15002"
#DEFINE WMSA15003 "WMSA15003"
#DEFINE WMSA15004 "WMSA15004"
#DEFINE WMSA15005 "WMSA15005"
#DEFINE WMSA15006 "WMSA15006"
#DEFINE WMSA15007 "WMSA15007"
#DEFINE WMSA15008 "WMSA15008"
#DEFINE WMSA15009 "WMSA15009"
#DEFINE WMSA15010 "WMSA15010"
#DEFINE WMSA15011 "WMSA15011"
#DEFINE WMSA15012 "WMSA15012"
#DEFINE WMSA15013 "WMSA15013"
#DEFINE WMSA15014 "WMSA15014"
#DEFINE WMSA15015 "WMSA15015"
#DEFINE WMSA15016 "WMSA15016"

Static lMarkAll := .F. // Indicador de marca/desmarca todos
Static nContDCF := 0   // Contador de Registros Marcados (ProcRegua)
Static lAutomato := .F.
Static cMark150 := ""
//----------------------------------------------------------
/*/{Protheus.doc} WMSA150
Execucao de Servicos

Neste arq. se encontram todas as ordens de servico,
dividas em 4 categorias:

1= Entradas, gerado atraves dos arquivos:
   SD1 - Itens das NF's de Entrada
   SD2 - Itens de venda da NF
   SD3 - Movimentacoes Internas
   SDA - Saldos a Distribuir
   SCM - Remitos de Entrada
2= Saidas, gerado atraves do arquivo:
   SC9 - Pedidos Liberados
   SCN - Remitos de Saida
4= Ordem de Servico, gerado atraves do arquivo:
   DCF - Ordens de servico manual
@author Alex Egydio
@version 2.0
@since 26/12/2000
/*/
//----------------------------------------------------------
Function WMSA150(lAuto,nOpcao,cMark,cServico,cTipUnit)
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local bKeyF5     := SetKey(VK_F5)
Local nRefreTela := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)

Private oBrowse   := Nil
Private cCadastro := OemToAnsi(STR0001) // Execucao de Servicos
Private cCusMed   := SuperGetMv('MV_CUSMED')
Private lEnd      := .T.

Default lAuto := .F.

	If !(lAutomato := lAuto)
		If !SuperGetMv("MV_WMSNEW",.F.,.F.)
			Return DLGA150()
		EndIf

		// Verifica se o custo medio e' calculado On-Line
		If cCusMed == 'O'
			Private nHdlPrv     := 0   // Endereco do arquivo de contra prova dos lanctos cont.
			Private lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
			Private cLoteEst    := ''  // Numero do lote para lancamentos do estoque
			Private nTotal      := 0   // Total dos lancamentos contabeis
			Private cArquivo    := ''  // Nome do arquivo contra prova
			// Posiciona numero do Lote para Lancamentos do Faturamento
			SX5->(dbSetorder(1))
			cLoteEst := If(SX5->(DbSeek(xFilial('SX5')+'09EST',.F.)),Trim(X5Descri()),'EST ')
		EndIf

		If AMiIn(39,42) // Somente autorizado para OMS e WMS
			// Variaveis utilizadas como parametros p/filtrar as ordens de servico
			//-----------------------------------------------------------------------------------
			// MV_PAR01 - Servico           De?
			// MV_PAR02                     Ate?
			// MV_PAR03 - Status do Servico 1- Nao Executados
			//                              2- Interrompidos
			//                              3- Ja Executados
			//                              4- Aptos a Execucao (Nao Executados e Iterrompidos)
			//                              5- Aptos ao Estorno (Ja Executados e Interrompidos)
			//                              6- Todos
			// MV_PAR04 - Documento         De?
			// MV_PAR05                     Ate?
			// MV_PAR06 - Data              De?
			// MV_PAR07                     Ate?
			// MV_PAR08 - Produto           De?
			// MV_PAR09                     Ate?
			// MV_PAR10 - Cliente/Forn      De?
			// MV_PAR11                     Ate?
			// MV_PAR12 - Loja              De?
			// MV_PAR13                     Ate?
			// MV_PAR14 - Tipo de Servico   1- Entradas
			//                              2- Saidas
			//                              3- Cargas
			//                              4- Ordem de Servico
			//                              5- Todos
			// MV_PAR15 - Carga             De?
			// MV_PAR16                     Ate?
			// MV_PAR17 - Refresh Autom.Tela  Refresh 1o Reg
			//                                Refresh Ult.Reg
			//                                Sem Refresh
			// MV_PAR18 - Habilita Estorno    Sim/Nao
			// MV_PAR19 - Estorna Serv.Autom. Sim/Nao
			If !Pergunte('DLA150', .T.)
				Return Nil
			EndIf
			oBrowse:= FWMarkBrowse():New()
			oBrowse:SetDescription(cCadastro)
			oBrowse:SetMenuDef("WMSA150")
			oBrowse:SetAlias("DCF")
			oBrowse:SetFieldMark("DCF_OK")
			oBrowse:SetValid({||ValidMark()})
			oBrowse:SetAfterMark({||AfterMark(.F.,.F.)})
			oBrowse:SetAllMark({||AllMark()})
			oBrowse:SetFilterDefault("@"+MontaQuery())
			oBrowse:SetWalkThru(.F.)
			oBrowse:SetAmbiente(.F.)
			oBrowse:SetFixedBrowse(.T.)
			oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='1'","GREEN" ,STR0002) // O.S. Não Executada
			oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='2'","YELLOW",STR0003) // O.S. Interrompida
			oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='3'","RED"   ,STR0004) // O.S. Executada
			oBrowse:AddLegend("Empty(DCF_SERVIC)"                     ,"BROWN" ,STR0005) // O.S. Sem Serviço
			oBrowse:SetTimer({|| RefreshBrw() }, Iif(nRefreTela <= 0, 3600, nRefreTela) * 1000)
			oBrowse:SetIniWindow({||oBrowse:oBrowse:oTimer:lActive := (mv_par17 < 3)})
			oBrowse:SetParam({|| WMS150Sel()})

			SetKey (VK_F5 , {|| Processa({|lEnd| oBrowse:Refresh()},cCadastro,OemToAnsi(STR0006),.T.)}) // Selecionando Servicos...

			oBrowse:Activate()

			SetKey (VK_F5 , bKeyF5)
			RestArea(aAreaDCF)
			RestArea(aAreaAnt)
		EndIf
	Else
		// Atribui marca passada por parâmetro
		cMark150 := cMark
		Do Case
			Case nOpcao == 1 // Executar
				WMS150Proc(1)
			Case nOpcao == 2 // Estornar
				WMS150Proc(2)
			Case nOpcao == 3 // Alterar Serviço
				WMS150Serv(cServico)
			Case nOpcao == 4 // Informar Tipo Unit.
				WMS150TpUn(cTipUnit)
		EndCase
	EndIf
Return NIL
/*/-----------------------------------------------------------------------------
 Monta o menu da rotina
-----------------------------------------------------------------------------/*/
Static Function MenuDef()
Local aRotina := {}
	Add OPTION aRotina TITLE STR0029 ACTION "AxPesqui"                         OPERATION 1 ACCESS 0 // Pesquisar
	Add OPTION aRotina TITLE STR0030 ACTION "VIEWDEF.WMSA150"                  OPERATION 2 ACCESS 0 // Visualizar
	Add OPTION aRotina TITLE STR0007 ACTION "WMS150Proc(1)" 				   OPERATION 4 ACCESS 0 // Executar
	Add OPTION aRotina TITLE STR0008 ACTION "WMS150Proc(2)" 				   OPERATION 5 ACCESS 0 // Estornar
	Add OPTION aRotina TITLE STR0009 ACTION "WMS150Sel()"				  	   OPERATION 3 ACCESS 0 // Selecionar
	Add OPTION aRotina TITLE STR0010 ACTION "WMS150Serv()"  				   OPERATION 4 ACCESS 0 // Alterar Serviço
	If WmsX312118('DCF','DCF_UNIDES')
		Add OPTION aRotina TITLE STR0038 ACTION "WMS150TpUn()"   	OPERATION 4 ACCESS 0 // Informar Tipo Unit.
	EndIf
	If ExistBlock("DL150MNU")
		aRotina := ExecBlock("DL150MNU", .F., .F., {aRotina})
	EndIf

Return aRotina

Static Function ModelDef()
Local oStruDCF := FWFormStruct(1,"DCF",/*bAvalCampo*/,/*lViewUsado*/)
Local oStruD12 := FWFormStruct(1,"D12",/*bAvalCampo*/,/*lViewUsado*/)
Local oStruDCR := FWFormStruct(1,"DCR",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   := MPFormModel():New("WMSA150",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)
Local aColsSx3 := {}

	oModel:AddFields("DCFMASTER",/*cOwner*/,oStruDCF )
	oModel:GetModel("DCFMASTER"):SetDescription( STR0031 ) // "Ordem de Serviço"

	oModel:AddGrid("DCRREL","DCFMASTER",oStruDCR)
	oModel:GetModel("DCRREL"):SetDescription( STR0032 ) // "Movimentos WMS"
	oModel:SetRelation("DCRREL", {{"DCR_FILIAL","xFilial('DCR')"},{"DCR_IDDCF","DCF_ID"}})

	oModel:AddGrid("D12GRID","DCRREL",oStruD12)
	oModel:GetModel("D12GRID"):SetDescription( STR0032 ) // "Movimentos WMS"
	oModel:SetRelation("D12GRID", {{"D12_FILIAL","xFilial('D12')"},{"D12_IDDCF","DCR_IDORI"}})

	BuscarSX3("DCF_CARGA",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VCARGA","C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_CARGA") } ,Nil,.F.,.T. )
	BuscarSX3("DCF_DOCTO",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VDOCTO","C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_DOCTO") } ,Nil,.F.,.T. )
	BuscarSX3("DCF_SERIE",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VSERIE","C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_SERIE") } ,Nil,.F.,.T. )
	BuscarSX3("DCF_CLIFOR",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VCLIFO","C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_CLIFOR") },Nil,.F.,.T. )
	BuscarSX3("DCF_LOJA",,aColsSX3)
	oStruDCR:AddField( aColsSX3[1],aColsSX3[1],"DCR_VLOJA" ,"C",aColsSX3[3],aColsSX3[4],Nil,Nil,Nil,Nil,{|| Posicione("DCF",9,xFilial("DCF")+DCR->DCR_IDDCF,"DCF_LOJA") }  ,Nil,.F.,.T. )

	oModel:AddGrid("DCRGRID","D12GRID",oStruDCR)
	oModel:GetModel("DCRGRID"):SetDescription( STR0032 ) // "Movimentos WMS"
	oModel:SetRelation("DCRGRID", {{"DCR_FILIAL","xFilial('DCR')"},{"DCR_IDMOV","D12_IDMOV"},{"DCR_IDOPER","D12_IDOPER"},{"DCR_IDORI","D12_IDDCF"}})
Return oModel

Static Function ViewDef()
Local oStruDCF := FWFormStruct( 2, "DCF" )
Local oStruDCR := FwFormStruct( 2, "DCR" )
Local oStruD12 := FWFormStruct( 2, "D12" )
Local oModel   := FWLoadModel( "WMSA150" )
Local oView    := FWFormView():New()
Local aColsSx3 := {}
	BuscarSX3("DCF_CARGA",,aColsSX3)
	oStruDCR:AddField("DCR_VCARGA","01",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	BuscarSX3("DCF_DOCTO",,aColsSX3)
	oStruDCR:AddField("DCR_VDOCTO","02",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	BuscarSX3("DCF_SERIE",,aColsSX3)
	oStruDCR:AddField("DCR_VSERIE","03",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	BuscarSX3("DCF_CLIFOR",,aColsSX3)
	oStruDCR:AddField("DCR_VCLIFO","04",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)
	BuscarSX3("DCF_LOJA",,aColsSX3)
	oStruDCR:AddField("DCR_VLOJA" ,"05",aColsSX3[1],aColsSX3[1],Nil,"C",aColsSX3[2],Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.T.,Nil)

	oStruDCR:SetProperty("DCR_IDORI"  ,MVC_VIEW_ORDEM,"06")
	oStruDCR:SetProperty("DCR_IDDCF"  ,MVC_VIEW_ORDEM,"07")
	oStruDCR:SetProperty("DCR_IDMOV"  ,MVC_VIEW_ORDEM,"08")
	oStruDCR:SetProperty("DCR_IDOPER" ,MVC_VIEW_ORDEM,"09")
	oStruDCR:SetProperty("DCR_QUANT"  ,MVC_VIEW_ORDEM,"10")
	oStruDCR:SetProperty("DCR_QTSEUM" ,MVC_VIEW_ORDEM,"11")
	oStruDCR:SetProperty("DCR_SEQUEN" ,MVC_VIEW_ORDEM,"12")

	oView:SetModel( oModel )

	oView:CreateHorizontalBox("UP"  , 60,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox("DOWN", 40,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	oView:CreateVerticalBox("LEFT",49.75,"DOWN")
	oView:CreateVerticalBox("MID",0.5,"DOWN")
	oView:CreateVerticalBox("RIGHT",49.75,"DOWN")

	oView:AddField("DCFVIEW", oStruDCF, "DCFMASTER")
	oView:SetOwnerView("DCFVIEW", "UP")

	oView:AddGrid("D12VIEW", oStruD12, "D12GRID")
	oView:EnableTitleView("D12VIEW", "Movimentos WMS")
	oView:SetOwnerView("D12VIEW", "LEFT")

	oView:AddGrid("DCRVIEW", oStruDCR, "DCRGRID")
	oView:EnableTitleView("DCRVIEW", STR0033) //"Detalhes do Movimento"
	oView:SetOwnerView("DCRVIEW", "RIGHT")
Return oView
// Pega a marca setada
Function GetMark150()
	If !lAutomato
		cMark150 := oBrowse:cMark
	EndIf
Return cMark150
/*/-----------------------------------------------------------------------------
 Valida a marcação do registro
-----------------------------------------------------------------------------/*/
Static Function ValidMark()
Local lRet := .F.
	If mv_par03 == 1 .Or. mv_par03 == 2 .Or. mv_par03 == 4 // Verde - Apto a Executar
		// Status do Servico
		//--------------------------------
		// 1 = Nao Executado  - Verde
		// 2 = Interrompido   - Verde
		// 3 = Executado      - Vermelho
		// 4 = Em Conferencia - Azul
		If !(DCF->DCF_STSERV=='3').And.!(DCF->DCF_STSERV=='4')  // Se for Interrompido ou Nao Executado
			lRet := .T.
		EndIf
	ElseIf mv_par03 == 2 .Or. mv_par03 == 3 .Or. mv_par03 == 5 // Verde - Apto a Estornar
		// Status do Servico
		//--------------------------------
		// 1 = Nao Executado  - Vermelho
		// 2 = Interrompido   - Verde
		// 3 = Executado      - Verde
		// 4 = Em Conferencia - Azul
		If (DCF->DCF_STSERV == '2' .Or. DCF->DCF_STSERV == '3') // Se for Interrompido ou Executado
			lRet := .T.
		EndIf
	EndIf
Return lRet
/*/-----------------------------------------------------------------------------
 Rotina após a marcação do registro
-----------------------------------------------------------------------------/*/
Static Function AfterMark(lMarkAll,lMarkRec)
Static lDLA150Pe  := ExistBlock('DLGA150M')
Static lDla150Mk  := ExistBlock('DLA150MK')
Local aAreaAnt    := GetArea()
Local lRet        := .T.
	If lDla150Mk
		lRet := ExecBlock('DLA150MK',.F.,.F.,GetMark150())
	EndIf
	If lRet
		If lMarkAll
			Reclock('DCF',.F.)
			DCF->DCF_OK := Iif(lMarkRec,GetMark150(),Space(TamSx3("DCF_OK")[1]))
			DCF->DCF_STRADI := ' '
			DCF->(MsUnlock())
			Iif(!Empty(DCF->DCF_OK), nContDCF++, nContDCF--)
		Else
			Iif(oBrowse:IsMark(), nContDCF++, nContDCF--)
			Reclock('DCF',.F.)
			DCF->DCF_STRADI := ' '
			DCF->(MsUnlock())
			GetMark150()
			MarcaSimil(oBrowse:IsMark(), lMarkAll) // Marca ou Desmarca todos os servicos de uma mesma Carga/Documento ou documento
		EndIf

	EndIf
	If lDLA150Pe
		ExecBlock("DLGA150M",.F.,.F.,GetMark150())
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*/-----------------------------------------------------------------------------
 Marca ou desmarca todos os servicos da mesma Carga/Documento
 Impede que estes servicos sejam executados separadamente
-----------------------------------------------------------------------------/*/
Static Function MarcaSimil(cMarca, lMarkAll)
Local aAreaDCF  := DCF->(GetArea())
Local cAliasDCF := Nil
Local cChave    := ""
Local cCompar   := ""
Local cQuery    := ""
Local nRecnoDCF := 0


	If ExistBlock('DLGA150M') .OR. ExistBlock('DLA150MK')
		// Define a chave de pesquisa para encontrar as ordens de serviço similares
		If DCF->DCF_ORIGEM == "DCF" .And. DCF->DCF_STSERV $ "1|2" .And. !Empty(DCF->DCF_DOCPEN)
			cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_DOCPEN"
		ElseIf WmsCarga(DCF->DCF_CARGA)
			cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_CARGA"
		Else
			If DCF->DCF_ORIGEM != "SC9"
				cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_DOCTO+DCF->DCF_SERIE+DCF->DCF_CLIFOR+DCF->DCF_LOJA"
			Else
				cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_DOCTO+DCF->DCF_CLIFOR+DCF->DCF_LOJA"
			EndIf
		EndIf
		// Define a string de comparação com base na DCF posicionada
		cCompar := &cChave
		// Busca alias do próprio browse, que neste caso é a DCF
		cAliasDCF := oBrowse:Alias()
		nRecnoDCF := (cAliasDCF)->(Recno())
		// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
		// a regra de marcação será executada apenas para os registros que o usuário vê em tela
		(cAliasDCF)->(DbGoTop())
		Do While (cAliasDCF)->(!Eof())
			// Marca apenas se for um registro similar
			If &cChave == cCompar .And. nRecnoDCF != (cAliasDCF)->(Recno())
				AfterMark(.T.,!Empty(cMarca))
			EndIf
			(cAliasDCF)->(DbSkip())
		EndDo

	Else
		cQuery := "UPDATE " + RetSqlName("DCF")
		cQuery += " SET DCF_OK = '" + Iif(!Empty(cMarca), oBrowse:Mark(), " ") + "' "
		cQuery += " ,DCF_STRADI = ' '"
		cQuery += "	WHERE R_E_C_N_O_ IN (SELECT R_E_C_N_O_ FROM " + RetSqlName("DCF") + " WHERE "
		cQuery += MontaQuery() + " AND D_E_L_E_T_ = ' '"
		If WmsCarga(DCF->DCF_CARGA)
			cQuery += " AND DCF_SERVIC = '" + DCF->DCF_SERVIC +"'"
			cQuery += " AND DCF_CARGA = '"+ DCF->DCF_CARGA + "')"
		Else
		   cQuery += " AND DCF_SERVIC = '" + DCF->DCF_SERVIC +"'"
		   cQuery += " AND DCF_DOCTO = '" + DCF->DCF_DOCTO +"'"

			If DCF->DCF_ORIGEM == "SD1"
				cQuery += " AND DCF_SERIE = '" + DCF->DCF_SERIE +"'"
			EndIf

		   cQuery += " AND DCF_CLIFOR = '" + DCF->DCF_CLIFOR +"'"
		   cQuery += " AND DCF_LOJA = '" + DCF->DCF_LOJA +"')"
		EndIf
		If TcSQLExec(cQuery) < 0
			WmsMessage(STR0040 + CRLF + TcSQLError()) //'Erro na marcação dos registros exibidos.'
		EndIf
		nContDCF := CountDCF()

	EndIf
	RestArea(aAreaDCF)
	If !lMarkAll
		oBrowse:Refresh()
	EndIf
Return Nil
/*/-----------------------------------------------------------------------------
 Marca todos os registros da seleção
-----------------------------------------------------------------------------/*/
Static Function AllMark()
Local aAreaDCF  := DCF->(GetArea())
Local cAliasDCF := ""
Local lRet := .T.

	lMarkAll := !lMarkAll
	If lMarkAll
		nContDCF := 0
	EndIf
	If ExistBlock('DLGA150M') .OR. ExistBlock('DLA150MK')
		// Busca alias do próprio browse, que neste caso é a DCF
		cAliasDCF := oBrowse:Alias()
		// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
		// a regra de marcação será executada apenas para os registros que o usuário vê em tela
		(cAliasDCF)->(DbGoTop())
		While (cAliasDCF)->(!Eof())
			AfterMark(.T.,lMarkAll)
			(cAliasDCF)->(DbSkip())
		EndDo
	Else
		lMarkAll := IIF(GetMark150() = DCF->DCF_OK,.F.,.T.)
		cAliasDCF := oBrowse:Alias()
		(cAliasDCF)->(DbGoTop())
		While (cAliasDCF)->(!Eof())
			lRet := .T.
			If lMarkAll .And. GetMark150() = DCF->DCF_OK //Funcao marcar e ja esta marcado, nao faz nada
				lRet := .F.
			ElseIf !lMarkAll .And. Empty(DCF->DCF_OK) //Funcao desmarcar e nao esta marcado, nao faz nada
				lRet := .F.
			EndIf

			If lRet
				AfterMark(.T.,lMarkAll)
				MarcaSimil(oBrowse:IsMark(), .T.) // Marca ou Desmarca todos os servicos de uma mesma Carga/Documento ou documento
			EndIf
			(cAliasDCF)->(DbSkip())
		EndDo
	EndIf
	If !lMarkAll
		nContDCF := 0
	EndIf
	RestArea(aAreaDCF)
	oBrowse:Refresh()

Return Nil
/*/-----------------------------------------------------------------------------
 Desmarca todos os registros da seleção
-----------------------------------------------------------------------------/*/
Static Function UncheckAll(cWhere)
Local aArea  := GetArea()
Local cQuery := ""
	cQuery := "UPDATE " + RetSqlName("DCF")
	cQuery +=   " SET DCF_OK = ' '"
	cQuery += " WHERE "+cWhere+" AND DCF_OK = '"+GetMark150()+"' AND D_E_L_E_T_ = ' '"
	If TcSQLExec(cQuery) < 0
		WmsMessage(STR0039 + CRLF + TcSQLError()) // "Problema ao tentar demarcar os registros DCF: "
	EndIf
	nContDCF := 0

	RestArea(aArea)
	oBrowse:Refresh()
Return Nil
/*---------------------------------------------------------------------------
---MontaQuery
---Retorna expressao do filtro
---Alex Egydio 13/06/2006
---------------------------------------------------------------------------*/
Static Function MontaQuery()
Local cQuery := ''
Local nStServ:= mv_par03

	cQuery  := " DCF_FILIAL = '"+xFilial('DCF')+"' And "
	If mv_par06 == mv_par07
		cQuery  += "DCF_DATA   = '"+DtoS(mv_par06)+"' And "
	Else
		cQuery  += "DCF_DATA   >= '"+DtoS(mv_par06)+"' And "
		cQuery  += "DCF_DATA   <= '"+DtoS(mv_par07)+"' And "
	EndIf

	If (!Empty(mv_par01) .Or. Upper(SubStr(mv_par02,1,1)) != 'Z') .And. !mv_par01 == mv_par02
		cQuery  += "DCF_SERVIC >= '"+mv_par01+"' And "
		cQuery  += "DCF_SERVIC <= '"+mv_par02+"' And "
	ElseIf mv_par01 == mv_par02
		cQuery  += "DCF_SERVIC = '"+mv_par01+"' And "
	EndIf

	If (!Empty(mv_par04) .Or. Upper(SubStr(mv_par05,1,1)) != 'Z') .And. !mv_par04 == mv_par05
		cQuery  += "DCF_DOCTO  >= '"+mv_par04+"' And "
		cQuery  += "DCF_DOCTO  <= '"+mv_par05+"' And "
	ElseIf mv_par04 == mv_par05
		cQuery  += "DCF_DOCTO  = '"+mv_par04+"' And "
	EndIf

	If (!Empty(mv_par08) .Or. Upper(SubStr(mv_par09,1,1)) != 'Z') .And. !mv_par08 == mv_par09
		cQuery  += "DCF_CODPRO >= '"+mv_par08+"' And "
		cQuery  += "DCF_CODPRO <= '"+mv_par09+"' And "
	ElseIf mv_par08 == mv_par09
		cQuery  += "DCF_CODPRO = '"+mv_par08+"' And "
	EndIf

	If (!Empty(mv_par10) .Or. Upper(SubStr(mv_par11,1,1)) != 'Z') .And. !mv_par10 == mv_par11
		cQuery  += "DCF_CLIFOR >= '"+mv_par10+"' And "
		cQuery  += "DCF_CLIFOR <= '"+mv_par11+"' And "
	ElseIf mv_par10 == mv_par11
		cQuery  += "DCF_CLIFOR = '"+mv_par10+"' And "
	EndIf

	If (!Empty(mv_par12) .Or. Upper(SubStr(mv_par13,1,1)) != 'Z') .And. !mv_par12 == mv_par13
		cQuery  += "DCF_LOJA   >= '"+mv_par12+"' And "
		cQuery  += "DCF_LOJA   <= '"+mv_par13+"' And "
	ElseIf mv_par12 == mv_par13
		cQuery  += "DCF_LOJA   = '"+mv_par12+"' And "
	EndIf

	If (!Empty(mv_par15) .Or. Upper(SubStr(mv_par16,1,1)) != 'Z') .And. !mv_par15 == mv_par16
		cQuery  += "DCF_CARGA  >= '"+mv_par15+"' And "
		cQuery  += "DCF_CARGA  <= '"+mv_par16+"' And "
	ElseIf mv_par15 == mv_par16
		cQuery  += "DCF_CARGA  = '"+mv_par15+"' And "
	EndIf

	If (!Empty(mv_par20) .Or. Upper(SubStr(mv_par21,1,1)) != 'Z') .And. !mv_par20 == mv_par21
		cQuery  += "DCF_CODREC >= '"+mv_par20+"' And "
		cQuery  += "DCF_CODREC <= '"+mv_par21+"' And "
	ElseIf mv_par20 == mv_par21
		cQuery  += "DCF_CODREC = '"+mv_par20+"' And "
	EndIf

	If WmsX112118("DLA150","22")
		If (!Empty(mv_par22) .Or. Upper(SubStr(mv_par23,1,1)) != 'Z') .And. !mv_par22 == mv_par23
			cQuery  += "DCF_UNITIZ >= '"+mv_par22+"' And "
			cQuery  += "DCF_UNITIZ <= '"+mv_par23+"' And "
		ElseIf mv_par22 == mv_par23
			cQuery  += "DCF_UNITIZ = '"+mv_par22+"' And "
		EndIF

	EndIf
	// Tipo de Servico 1- Entradas
	//                 2- Saidas
	//                 3- Cargas Unitizadas
	//                 4- Internos
	//                 5- Todos
	If mv_par14 == 1     // Entradas
		cQuery  += "DCF_ORIGEM IN ('SD1','SD2','SD3','SDA','SCM','D0R') And "
	ElseIf mv_par14 == 2 // Saidas
		cQuery  += "DCF_ORIGEM IN ('SC9','SCN','SD4') And "
	ElseIf mv_par14 == 3 // -> Não usado -< (Removido)
		cQuery  += "DCF_ORIGEM = '   ' And "
	ElseIf mv_par14 == 4 // Internos
		cQuery  += "DCF_ORIGEM IN ('DCF','DH1') And "
	EndIf
	// Status do Servico 1- Nao Executados
	//                   2- Interrompidos
	//                   3- Ja Executados
	//                   4- Aptos a Execucao (Nao Executados e Iterrompidos)
	//                   5- Aptos ao Estorno (Ja Executados e Interrompidos)
	If nStServ == 1      // Mostra Somente Servicos ainda Nao Executados
		cQuery += "DCF_STSERV IN ('1','4')"
	ElseIf  nStServ == 2 // Mostra Somente Servicos Interrompidos
		cQuery += "DCF_STSERV = '2'"
	ElseIf  nStServ == 3 // Mostra somente Servicos Ja Executados
		cQuery += "DCF_STSERV = '3'"
	ElseIf  nStServ == 4 // Mostra somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
		cQuery += "DCF_STSERV IN ('1','2')"
	Else // Mostra somente Servicos Aptos ao Estorno (Ja Executados e Interrompidos)
		cQuery += "DCF_STSERV IN ('3','2')"

		cQuery += " AND (DCF_ORIGEM <> 'SC9' OR (DCF_ORIGEM = 'SC9'"
		cQuery += " AND EXISTS "
		cQuery += 	" (SELECT 1 "
		cQuery += 		" FROM "+RetSqlName('SC9')+" SC9"
		cQuery += 			" WHERE SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
		cQuery += 				" AND SC9.C9_IDDCF = DCF_ID"
		cQuery += 				" AND SC9.C9_NFISCAL = '"+Space(TamSx3('C9_NFISCAL')[1])+"'"
		cQuery += 				" AND SC9.D_E_L_E_T_ = ' ')))"

	EndIf
	// Ponto de Entrada DL150FIL para a alteracao do Filtro executado pelo programa
	If ExistBlock('DL150FIL')
		If ValType(cQueryPE:=ExecBlock('DL150FIL',.F.,.F.,{cQuery,.T.})) == 'C'
			cQuery := cQueryPE
		EndIf
	EndIf
Return(cQuery)
/*---------------------------------------------------------------------------
---WMS150Sel
---Permite Selecionar Novamente o Intervalo
---Fernando Joly Siquini 24/04/2002
---------------------------------------------------------------------------*/
Function WMS150Sel()
Local lRet       := .T.
Local cWhere     := ""
	// Variaveis utilizadas como parametros p/filtrar as ordens de servico
	//--------------------------------------------------------------------------------------
	// MV_PAR01 - Servico           De?
	// MV_PAR02                     Ate?
	// MV_PAR03 - Status do Servico 1- Nao Executados
	//                              2- Interrompidos
	//                              3- Ja Executados
	//                              4- Aptos a Execucao (Nao Executados e Iterrompidos)
	//                              5- Aptos ao Estorno (Ja Executados e Interrompidos)
	//                              6- Todos
	// MV_PAR04 - Documento         De?
	// MV_PAR05                     Ate?
	// MV_PAR06 - Data              De?
	// MV_PAR07                     Ate?
	// MV_PAR08 - Produto           De?
	// MV_PAR09                     Ate?
	// MV_PAR10 - Cliente/Forn      De?
	// MV_PAR11                     Ate?
	// MV_PAR12 - Loja              De?
	// MV_PAR13                     Ate?
	// MV_PAR14 - Tipo de Servico   1- Entradas
	//                              2- Saidas
	//                              3- Cargas
	//                              4- Ordem de Servico
	//                              5- Todos
	// MV_PAR15 - Carga             De?
	// MV_PAR16                     Ate?
	// MV_PAR17 - Refresh Autom.Tela  Refresh 1o Reg
	//                                Refresh Ult.Reg
	//                                Sem Refresh
	// MV_PAR18 - Habilita Estorno    Sim/Nao
	// MV_PAR19 - Estorna Serv.Autom. Sim/Nao
	// MV_PAR20 - Docto.Conferencia Recebto.De?
	// MV_PAR21 - Docto.Conferencia Recebto.Ate?
	If nContDCF > 0
		cWhere := MontaQuery()
	EndIf
	lRet := Pergunte('DLA150', .T.)
	If lRet
		// Antes de selecionar novos registros, eh obrigatoria a chamada da funcao AllMark para desmarcar todos os
		// registros selecionados anteriormente. Isto evita que fiquem marcas repetidas gravadas no campo DCF_OK
		If nContDCF > 0
			UncheckAll(cWhere)
		EndIf
		oBrowse:oBrowse:oTimer:lActive := (mv_par17 < 3)
		// Selecionar servicos conforme a parametrizacao do usuario.
		oBrowse:SetFilterDefault("@"+MontaQuery())
		oBrowse:Refresh()
	EndIf
Return lRet
/*---------------------------------------------------------------------------
---WMS150Proc
---Execucao de Servicos
---Alex Egydio 26/12/2000
---nOpcx, Numerico, (Operação)
---------------------------------------------------------------------------*/
Function WMS150Proc(nOpcx)
Local lRetPE := .T.
	// Ponto de Entrada DL150BEX - Antes Execucao/Estorno O.S.WMS.
	If ExistBlock( "DL150BEX" )
		lRetPE := ExecBlock( "DL150BEX", .F., .F., {nOpcx} )
		If ValType(lRetPE) == 'L' .And. !lRetPE
			Return Nil
		EndIf
	EndIf
	If nOpcx == 1 // Executa
		// Selecionou o.s.wms aptas a estornar e tentou executar
		If mv_par03 == 5 .OR. mv_par03 == 3
			WmsMessage(STR0011,WMSA15001,1) // Para executar o serviço você deve habilitar esta opção através das perguntas desta rotina. // Ok
		Else
			If !lAutomato
				Processa({|lEnd| ExecuteSrv(@lEnd)},cCadastro,OemToAnsi(STR0013),.T.)   //'Executando Servicos...'
			Else
				ExecuteSrv(.T.)
			EndIf
		EndIf
	Else // Estorna
		If mv_par18 == 2 .OR. mv_par03 == 1 .OR. mv_par03 == 4
			WmsMessage(STR0014,WMSA15002,1) // Para executar o estorno você deve habilitar esta opção através das perguntas desta rotina. // Ok
		Else
			If !lAutomato
				Processa({|lEnd| ReverseSrv(@lEnd)},cCadastro,OemToAnsi(STR0015),.T.) // Estornando Servicos...
			Else
				ReverseSrv(.F.)
			EndIf
		EndIf
	EndIf
	// Ponto de Entrada DL150AEX - Apos Execucao/Estorno O.S.WMS.
	If ExistBlock( "DL150AEX" )
		ExecBlock( "DL150AEX", .F., .F., {nOpcx} )
	EndIf

	If !lAutomato
		//Executa novamente o pergunte pois o MATA240 pode alterar os valores
		Pergunte('DLA150', .F.)
		RefreshBrw()
	EndIf
Return Nil

Static Function RefreshBrw()
Local nPos := oBrowse:At()
	If MV_PAR17 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR17 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos,.F.)
	EndIf
Return .T.

Static Function ExecuteSrv(lEnd)
Local aAreaDCF   := DCF->(GetArea())
Local cAliasDCF  := GetNextAlias()
Local cStatus    := ""
Local cSrvVazio  := PadR("", TamSx3("DCF_SERVIC")[1])
Local cMensagem  := ''
Local oOrdSerExe := WMSDTCOrdemServicoExecute():New()
Local oRegraConv := WMSBCCRegraConvocacao():New()
Local aOrdSerExe := {}
Local nI         := 0
	// Verificar data do ultimo fechamento em SX6.
	If MVUlmes() >= dDataBase
		WmsMessage(STR0020,WMSA15005,,,,STR0021) // Não pode ser digitado movimento com data anterior a última data de fechamento (virada de saldos). // Utilizar data posterior ao último fechamento de estoque (MV_ULMES) / posterior à data do bloqueio de movimentos (MV_DBLQMOV).
		Return Nil
	EndIf
	If !oOrdSerExe:ChecaPrior()
		WmsMessage(oOrdSerExe:GetErro(),WMSA15013,1)
		Return Nil
	EndIf
	// Status do Servico 1- Nao Executados
	//                   2- Interrompidos
	//                   3- Ja Executados
	//                   4- Aptos a Execucao (Nao Executados e Iterrompidos)
	//                   5- Aptos ao Estorno (Ja Executados e Interrompidos)
	If MV_PAR03 == 1
		cStatus := "'1'" //
	ElseIf MV_PAR03 == 2
		cStatus := "'2'"
	ElseIf MV_PAR03 == 4
		cStatus := "'1','2'"
	EndIf
	cStatus := "%"+cStatus+"%"
	If (MV_PAR01 == MV_PAR02)
		BeginSql Alias cAliasDCF
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SERVIC = %Exp:MV_PAR01%
			AND DCF.DCF_SERVIC <> %Exp:cSrvVazio%
			AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
			AND DCF.DCF_OK = %Exp:GetMark150()%
			AND DCF.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasDCF
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SERVIC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND DCF.DCF_SERVIC <> %Exp:cSrvVazio%
			AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
			AND DCF.DCF_OK = %Exp:GetMark150()%
			AND DCF.%NotDel%
		EndSql
	EndIf
	// Devido processo de execução efetuar o disarmtransaction ha situações que o cache é limpo
	// e perde-se o cAliasDCF por isso é gerado um vetor de dados para controle
	(cAliasDCF)->(dbEval({|| aAdd( aOrdSerExe,(cAliasDCF)->RECNODCF)}))
	(cAliasDCF)->(dbCloseArea())
	If Empty(aOrdSerExe)
		RestArea(aAreaDCF)
		Return Nil
	EndIf
	WMSCTPENDU() // Cria as temporárias - FORA DA TRANSAÇÃO
	ProcRegua(Len(aOrdSerExe))
	oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
	For nI := 1 To Len(aOrdSerExe)
		If OSPend(aOrdSerExe[nI])
			oOrdSerExe:GoToDCF(aOrdSerExe[nI])
			IncProc(oOrdSerExe:GetServico()+" - "+If(Empty(oOrdSerExe:GetCarga()),Trim(oOrdSerExe:GetDocto())+"/"+Trim(oOrdSerExe:GetSerie()),Trim(oOrdSerExe:GetCarga()))+"/"+Trim(oOrdSerExe:oProdLote:GetProduto()))
			oOrdSerExe:ExecuteDCF()
		Else
			IncProc('Ordem de serviço ID ' + AllTrim(aOrdSerExe[nI]) + ' já executada.')
		EndIf
	Next
	// Verifica as movimentações liberadas para verificar se há reabastecimentos gerados
	oOrdSerExe:ChkOrdReab()
	// O wms devera avaliar as regras para convocacao do servico e disponibilizar os
	// registros do D12 para convocacao
	oRegraConv:LawExecute()
	// Exibe as mensages de erro na ordem de serviço
	// Aviso
	If !lAutomato
		oOrdSerExe:ShowWarnig()
		//-- Exibe as mensagens de reabastecimento
		If SuperGetMV('MV_WMSEMRE',.F.,.T.) .And. !Empty(oOrdSerExe:aWmsReab)
			TmsMsgErr(oOrdSerExe:aWmsReab, STR0028) // Reabastecimentos pendentes:
		EndIf
		If Len(oOrdSerExe:GetLogSld()) > 0 .And. (oOrdSerExe:HasLogSld() .Or. SuperGetMV('MV_WMSRLSA',.F.,.F.))
			cMensagem := ""
			// Se a impressão é forçada, não mostra a mensagem de OS não atendida
			If !SuperGetMV('MV_WMSRLSA',.F.,.F.)
				cMensagem := STR0016+CRLF // Existem ordens de serviço de apanhe que não foram totalmente atendidas.
			EndIf
			cMensagem += STR0017 // Deseja imprimir o relatório de busca de saldo para o apanhe?
			If WmsQuestion(cMensagem,WMSA15003)
				WMSR111(oOrdSerExe:GetLogSld())
			EndIf
		EndIf
		If Len(oOrdSerExe:GetLogEnd()) > 0 .And. (oOrdSerExe:HasLogEnd() .Or. SuperGetMV('MV_WMSRLEN',.F.,.F.))
			cMensagem := ""
			// Se a impressão é forçada, não mostra a mensagem de OS não atendida
			If !SuperGetMV('MV_WMSRLEN',.F.,.F.)
				cMensagem := STR0018+CRLF // Existem ordens de serviço de endereçamento que não foram totalmente atendidas.
			EndIf
			cMensagem += STR0019 // Deseja imprimir o relatório de busca de endereços para a armazenagem?
			If WmsQuestion(cMensagem,WMSA15004)
				WMSR121(oOrdSerExe:GetLogEnd())
			EndIf
		EndIf
		If Len(oOrdSerExe:GetLogUni()) > 0 .And. (oOrdSerExe:HasLogUni() .Or. SuperGetMV('MV_WMSRLEN',.F.,.F.))
			cMensagem := ""
			// Se a impressão é forçada, não mostra a mensagem de OS não atendida
			If !SuperGetMV('MV_WMSRLEN',.F.,.F.)
				cMensagem := STR0035+CRLF // Existem ordens de serviço de endereçamento unitizado que não foram totalmente atendidas.
			EndIf
			cMensagem += STR0036 // Deseja imprimir o relatório de busca de endereços para a armazenagem unitizada?
			If WmsQuestion(cMensagem,WMSA15004)
				WMSR125(oOrdSerExe:GetLogUni())
			EndIf
		EndIf
	EndIf
	WMSDTPENDU() // Destroy as temporárias - FORA DA TRANSAÇÃO
	RestArea(aAreaDCF)
Return lEnd

Static Function ReverseSrv(lEnd)
Local aAreaDCF   := DCF->(GetArea())
Local cAliasDCF  := GetNextAlias()
Local cStatus    := ""
Local cSrvVazio  := PadR("", TamSx3("DCF_SERVIC")[1])
Local oOrdSerRev := WMSDTCOrdemServicoReverse():New()
Local oOrdserDel := Nil
Local oOrdSerExe := Nil
Local oRegraConv := Nil
Local aOrdSerEst := {}
Local nI         := 0
	// Verifica se opção do filtro permite operação
	// Verificar data do ultimo fechamento em SX6
	If MVUlmes() >= dDataBase
		WmsMessage(STR0020,WMSA15006,,,,STR0021) // Não pode ser digitado movimento com data anterior a última data de fechamento (virada de saldos). // Utilizar data posterior ao último fechamento de estoque (MV_ULMES) / posterior à data do bloqueio de movimentos (MV_DBLQMOV).
		Return Nil
	EndIf
	// Status do Servico 1- Nao Executados
	//                   2- Interrompidos
	//                   3- Ja Executados
	//                   4- Aptos a Execucao (Nao Executados e Iterrompidos)
	//                   5- Aptos ao Estorno (Ja Executados e Interrompidos)
	If MV_PAR03 == 2
		cStatus := "'2'"
	ElseIf MV_PAR03 == 3
		cStatus := "'3'"
	ElseIf MV_PAR03 == 5
		cStatus := "'2','3'"
	EndIf
	cStatus := "%"+cStatus+"%"
	If (MV_PAR01 == MV_PAR02)
		BeginSql Alias cAliasDCF
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SERVIC = %Exp:MV_PAR01%
			AND DCF.DCF_SERVIC <> %Exp:cSrvVazio%
			AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
			AND DCF.DCF_OK = %Exp:GetMark150()%
			AND DCF.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasDCF
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SERVIC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND DCF.DCF_SERVIC <> %Exp:cSrvVazio%
			AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
			AND DCF.DCF_OK = %Exp:GetMark150()%
			AND DCF.%NotDel%
		EndSql
	EndIf
	// Devido processo de execução efetuar o disarmtransaction ha situações que o cache é limpo
	// e perde-se o cAliasDCF por isso é gerado um vetor de dados para controle
	(cAliasDCF)->(dbEval({|| AAdd(aOrdSerEst,(cAliasDCF)->RECNODCF)}))
	(cAliasDCF)->(dbCloseArea())
	If Empty(aOrdSerEst)
		RestArea(aAreaDCF)
		Return Nil
	EndIf
	WMSCTPENDU() // Cria as temporárias - FORA DA TRANSAÇÃO
	ProcRegua(Len(aOrdSerEst))
	For nI := 1 To Len(aOrdSerEst)
		If lEnd
			Exit
		EndIf
		Begin Transaction
			oOrdSerRev:GoToDCF(aOrdSerEst[nI])
			IncProc(oOrdSerRev:GetServico()+" - "+If(Empty(oOrdSerRev:GetCarga()),oOrdSerRev:GetDocto()+"/"+oOrdSerRev:GetSerie(),oOrdSerRev:GetCarga())+"/"+oOrdSerRev:oProdLote:GetProduto())
			// Verifica se ordem de serviço pode ser estornada
			oOrdSerRev:SetEstSerA(mv_par19 == 1) // Indica se as O.S originadas da O.S estorna devem ser estornadas automaticamente
			If oOrdSerRev:CanReverse()
				If !oOrdSerRev:ReverseDCF()
					DisarmTransaction()
				EndIf
			EndIf
		End Transaction
	Next
	If !lEnd
		// Verifica se há ordens de serviço  de reabastecimento originados
		// das ordem de serviço estornadas para efetuar o estorno.
		If Len(oOrdSerRev:aOrdReab) > 0
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			For nI := 1 To Len(oOrdSerRev:aOrdReab)
				Begin Transaction
					oOrdSerDel:SetIdDCF(oOrdSerRev:aOrdReab[nI])
					If oOrdSerDel:LoadData()
						// Somente os serviços que não forem transferencia de devolução
						// Se for reabastecimento com origem preenchida, é executado
						// automático independente da configuração do serviço utilizado.
						oOrdSerDel:oServico:SetTpExec("2")
						If oOrdSerDel:CanDelete()
							oOrdSerDel:DeleteDCF()
						Else
							oOrdSerDel:SetIdOrig("")
							oOrdSerDel:UpdateDCF()
						EndIf
					EndIf
				End Transaction
			Next nI
		EndIf
		// Verifica as Ordens de servico geradas para execução automatica
		If Len(oOrdSerRev:aLibDCF) > 0
			oOrdSerExe := WMSDTCOrdemServicoExecute():New()
			oRegraConv := WMSBCCRegraConvocacao():New()
			For nI := 1 To Len(oOrdSerRev:aLibDCF)
				oOrdSerExe:SetIdDCF(oOrdSerRev:aLibDCF[nI])
				If oOrdSerExe:LoadData()
					oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
					oOrdSerExe:ExecuteDCF()
				EndIf
			Next nI
			If !Empty(oRegraConv:GetArrLib())
				oRegraConv:LawExecute()
			EndIf
			// Copiando as mensagens de aviso da execução para o array do objeto atual
			If !Empty(oOrdSerExe:aWmsAviso)
				AEval(oOrdSerExe:aWmsAviso, {|x| AAdd(oOrdSerRev:aWmsAviso,x)})
			EndIf
		EndIf
		// Aviso
		If !lAutomato
			oOrdSerRev:ShowWarnig()
		EndIf
	EndIf
	WMSDTPENDU() // Destroy as temporárias - FORA DA TRANSAÇÃO
	RestArea(aAreaDCF)
Return lEnd
//-----------------------------------
/*{Protheus.doc}
Altera o Serviço das Ordens de Serviço selecionadas

@author Tiago Filipe da Silva
@version P11
@Since   05/02/14
@obs
*/
//-----------------------------------
Function WMS150Serv(cServico)
Local lRet       := .T.
Local aAreaDCF   := DCF->(GetArea())
Local cAliasDCF  := GetNextAlias()
Local cStatus    := ""
Local cSrvVazio  := PadR("", TamSx3("DCF_SERVIC")[1])
Local cTipoServ  := ""
Local cTipoServ2 := ""
Local cCodServ   := ""
Local cCodServ2  := ""
Local lOk        := .T.
Local lAchou     := .F.
Local oOrdServ   := WMSDTCOrdemServico():New()
Local oServico   := WMSDTCServicoTarefa():New()
Default cServico   := PadR("", TamSx3("DCF_SERVIC")[1])
	If MV_PAR03 == 1 .Or. MV_PAR03 == 2 .Or. MV_PAR03 == 4
		// Status do Servico 1- Nao Executados
		//                   2- Interrompidos
		//                   3- Ja Executados
		//                   4- Aptos a Execucao (Nao Executados e Iterrompidos)
		//                   5- Aptos ao Estorno (Ja Executados e Interrompidos)
		If MV_PAR03 == 1
			cStatus := "' ','1'"
		ElseIf MV_PAR03 == 2
			cStatus := "'2'"
		ElseIf MV_PAR03 == 4
			cStatus := "'1','2'"
		EndIf
		cStatus := "%"+cStatus+"%"
		cAliasDCF := GetNextAlias()
		If (MV_PAR01 == MV_PAR02)
			BeginSql Alias cAliasDCF
				SELECT DCF.DCF_ID,
						DCF.DCF_SERVIC,
						DCF.R_E_C_N_O_ RECNODCF
				FROM %Table:DCF% DCF
				WHERE DCF.DCF_FILIAL = %xFilial:DCF%
				AND DCF.DCF_SERVIC = %Exp:MV_PAR01%
				AND DCF.DCF_SERVIC <> %Exp:cSrvVazio%
				AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
				AND DCF.DCF_OK = %Exp:GetMark150()%
				AND DCF.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasDCF
				SELECT DCF.DCF_ID,
						DCF.DCF_SERVIC,
						DCF.R_E_C_N_O_ RECNODCF
				FROM %Table:DCF% DCF
				WHERE DCF.DCF_FILIAL = %xFilial:DCF%
				AND DCF.DCF_SERVIC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND DCF.DCF_SERVIC <> %Exp:cSrvVazio%
				AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
				AND DCF.DCF_OK = %Exp:GetMark150()%
				AND DCF.%NotDel%
			EndSql
		EndIf
		If (cAliasDCF)->(!Eof())
			oServico:SetServico((cAliasDCF)->DCF_SERVIC)
			oServico:LoadData()
			cCodServ  := oServico:GetServico()
			cTipoServ := oServico:GetTipo()
			// Obtem o primeiro servico para comparacao
			Do While (cAliasDCF)->(!Eof())
				// Verifica se o tipo de servico das ordens de servico selecionadas são
				oServico:SetServico((cAliasDCF)->DCF_SERVIC)
				oServico:LoadData()
				cCodServ2  := oServico:GetServico()
				cTipoServ2 := oServico:GetTipo()
				If cTipoServ <> cTipoServ2
					lOk := .F.
					Exit
				EndIf
				(cAliasDCF)->(DbSkip())
			EndDo

			If lOk
				lAchou := .F.
				Do While !lAchou
					If lAutomato .Or. ConPad1(,,, 'DC5',,, .F.)
						If !lAutomato
							cServico := DC5->DC5_SERVIC
						EndIf
						If !Empty(cServico) .AND. ChkTipServ(cServico, cTipoServ)
							lAchou := .T.
						EndIf
					Else
						lAchou := .T.
						lOk    := .F.
					EndIf
				EndDo
				If lOk
					If WMSQuestion(STR0023,WMSA15008) // Todos os itens marcados serao alterados, deseja confimar?
						(cAliasDCF)->(dbGoTop())
						Do While (cAliasDCF)->(!Eof())
							DCF->( dbGoto((cAliasDCF)->RECNODCF) )
							oOrdServ:SetIdDCF(DCF->DCF_ID)
							oOrdServ:LoadData()
							If (oOrdServ:GetStServ() $ "1|2")
								If oOrdServ:GetServico() <> cServico
									oOrdServ:SetServico(cServico)
									oOrdServ:UpdateDCF()
									oOrdServ:UpdServic()
								EndIf
							EndIf
							(cAliasDCF)->( dbSkip())
						EndDo
					EndIf
				EndIf
			Else
				WmsMessage(STR0024,WMSA15009,1)// Há ordens de serviço marcadas com tipo de serviço diferente.
				lRet := .F.
			EndIf
		Else
			WmsMessage(STR0025,WMSA15010,1)// Nenhuma ordem de serviço foi selecionada.
		EndIf
		(cAliasDCF)->(dbCloseArea())
	Else
		WmsMessage(STR0026,WMSA15011,1)// Parâmetro 'Status do Serviço' não permite alteração.
		lRet := .F.
	EndIf
	RestArea(aAreaDCF)
	RefreshBrw()
Return lRet

Static Function ChkTipServ(cServico,cTipoServ)
Local lRet     := .T.
Local oServico := WMSDTCServicoTarefa():New()
	// Verifica se o tipo de serviço do servico informado é igual ao tipo de serviço das ordens de servico selecionadas
	oServico:SetServico(cServico)
	oServico:LoadData()
	If oServico:GetTipo() <> cTipoServ
		WmsMessage(STR0027,WMSA15012,1) // O tipo do serviço informado difere do tipo de serviço dos itens marcados.
		lRet := .F.
	EndIf
Return lRet
//-----------------------------------
/*{Protheus.doc}
Altera o tipo do unitizador na etiqueta do unitizador

@author Amanda Rosa Vieira
@version P12
@Since   26/06/2017
*/
//-----------------------------------
Function WMS150TpUn(cTpUnit)
Local lRet      := .T.
Local aAreaD0Y  := D0Y->(GetArea())
Local cAliasD0Y := GetNextAlias()
Local cStatus   := ""

Default cTpUnit   := ""
	If MV_PAR03 == 1 .Or. MV_PAR03 == 2 .Or. MV_PAR03 == 4
		// Status do Servico 1- Nao Executados
		//                   2- Interrompidos
		//                   3- Ja Executados
		//                   4- Aptos a Execucao (Nao Executados e Iterrompidos)
		//                   5- Aptos ao Estorno (Ja Executados e Interrompidos)
		If MV_PAR03 == 1
			cStatus += "' ','1'"
		ElseIf MV_PAR03 == 2
			cStatus := "'2'"
		ElseIf MV_PAR03 == 4
			cStatus := "'1','2'"
		EndIf
		cStatus := "%"+cStatus+"%"
		If (MV_PAR01 == MV_PAR02)
			BeginSql Alias cAliasD0Y
				SELECT DISTINCT D0Y.R_E_C_N_O_ RECNOD0Y
				FROM %Table:DCF% DCF
				INNER JOIN %Table:D0Y% D0Y
				ON D0Y.D0Y_FILIAL = %xFilial:D0Y%
				AND D0Y.D0Y_IDUNIT = DCF.DCF_UNIDES
				AND D0Y.D0Y_TIPUNI = %Exp:Space(TamSX3('D0Y_TIPUNI')[1])%
				AND D0Y.%NotDel%
				WHERE DCF.DCF_FILIAL = %xFilial:DCF%
				AND DCF.DCF_SERVIC = %Exp:MV_PAR01%
				AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
				AND DCF.DCF_OK = %Exp:GetMark150()%
				AND DCF.DCF_UNIDES <> %Exp:Space(TamSX3("DCF_UNIDES")[1])%
				AND DCF.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasD0Y
				SELECT DISTINCT D0Y.R_E_C_N_O_ RECNOD0Y
				FROM %Table:DCF% DCF
				INNER JOIN %Table:D0Y% D0Y
				ON D0Y.D0Y_FILIAL = %xFilial:D0Y%
				AND D0Y.D0Y_IDUNIT = DCF.DCF_UNIDES
				AND D0Y.D0Y_TIPUNI = %Exp:Space(TamSX3('D0Y_TIPUNI')[1])%
				AND D0Y.%NotDel%
				WHERE DCF.DCF_FILIAL = %xFilial:DCF%
				AND DCF.DCF_SERVIC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND DCF.DCF_STSERV IN ( %Exp:cStatus% )
				AND DCF.DCF_OK = %Exp:GetMark150()%
				AND DCF.DCF_UNIDES <> %Exp:Space(TamSX3("DCF_UNIDES")[1])%
				AND DCF.%NotDel%
			EndSql
		EndIf
		If (cAliasD0Y)->(!Eof())
			If lAutomato .Or. ConPad1(,,, 'D0T',,, .F.)
				If !lAutomato
					cTpUnit := D0T->D0T_CODUNI
				EndIf
				If lAutomato .Or. WMSQuestion(STR0023,WMSA15014) // Todos os itens marcados serao alterados, deseja confimar?
					Do While (cAliasD0Y)->(!Eof())
						D0Y->( dbGoto((cAliasD0Y)->RECNOD0Y) )
						RecLock('D0Y', .F.)
						D0Y->D0Y_TIPUNI := cTpUnit
						D0Y->(MsUnLock())
						(cAliasD0Y)->( dbSkip())
					EndDo
				EndIf
			EndIf
		Else
			WmsMessage(STR0037,WMSA15015,1) //Não há ordens de serviço selecionadas com o tipo de unitizador indefinido.
		EndIf
		(cAliasD0Y)->(dbCloseArea())
	Else
		WmsMessage(STR0026,WMSA15015,1)// Parâmetro 'Status do Serviço' não permite alteração.
		lRet := .F.
	EndIf
	RestArea(aAreaD0Y)
	RefreshBrw()
Return lRet

/*/{Protheus.doc} CountDCF
//Função para fazer o count dos registros marcados na DCF
@author roselaine.adriano
@since 21/02/2020
@version 1.0

@type function
/*/
Static Function CountDCF()
Local cWhere   := ""
Local nResultDCF := 0
Local cAliasDCF := ""

	cWhere := "%"
	cWhere += " AND " + MontaQuery()
	cWhere += "%"

	cAliasDCF := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT COUNT(*) AS CounTDCF
		FROM %Table:DCF% DCF
		WHERE DCF_OK = %EXP:oBrowse:Mark()%
		AND %NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasDCF)->(!Eof())
		nResultDCF :=(cAliasDCF)->CounTDCF
	EndIf
	(cAliasDCF)->(DbCloseArea())

Return nResultDCF

/*/{Protheus.doc} OSPend
//Função que verifica se a OS ainda está pendente.
Na tela principal a OS está pendente e é adicionada ao array. Entretanto, durante a execução de outra OS
esta pode ter sido aglutinada, fazendo com que o status mude e não haja mais necessidade de executá-la.
O objetivo é evitar de fazer o LoadData da classe WMSDTCOrdemServico para essas OS's, e otimizar o
processamento.
@author wander.horongoso
@since 01/08/2021
@version 1.0

@type function
/*/

Static Function OSPend(nRecno)
Local cAliasQry := GetNextAlias()
Local lRet := .F.

	BeginSQL Alias cAliasQry
		SELECT Count(1)
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.R_E_C_N_O_ = %Exp:nRecno%
		AND DCF.DCF_STSERV IN ('1','2')
		AND DCF.DCF_STRADI = ' '
		AND DCF.%NotDel%
	EndSql

	lRet := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

Return lRet
