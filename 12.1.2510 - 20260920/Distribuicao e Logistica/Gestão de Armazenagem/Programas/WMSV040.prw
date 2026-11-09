#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE 'WMSV040.CH'

#DEFINE WMSV04001 "WMSV04001"
#DEFINE WMSV04002 "WMSV04002"
#DEFINE WMSV04003 "WMSV04003"
#DEFINE WMSV04008 "WMSV04008"
#DEFINE WMSV04009 "WMSV04009"
#DEFINE WMSV04010 "WMSV04010"
#DEFINE WMSV04011 "WMSV04011"
#DEFINE WMSV04012 "WMSV04012"
#DEFINE WMSV04013 "WMSV04013"
#DEFINE WMSV04014 "WMSV04014"
#DEFINE WMSV04015 "WMSV04015"
#DEFINE WMSV04016 "WMSV04016"
#DEFINE WMSV04017 "WMSV04017"
#DEFINE WMSV04018 "WMSV04018"
#DEFINE WMSV04019 "WMSV04019"
#DEFINE WMSV04020 "WMSV04020"
#DEFINE WMSV04021 "WMSV04021"
#DEFINE WMSV04022 "WMSV04022"
#DEFINE WMSV04023 "WMSV04023"
#DEFINE WMSV04024 "WMSV04024"
#DEFINE WMSV04025 "WMSV04025"
#DEFINE WMSV04026 "WMSV04026"
#DEFINE WMSV04027 "WMSV04027"
#DEFINE WMSV04028 "WMSV04028"
#DEFINE WMSV04029 "WMSV04029"
#DEFINE WMSV04030 "WMSV04030"
#DEFINE WMSV04031 "WMSV04031"
#DEFINE WMSV04032 "WMSV04032"
#DEFINE WMSV04033 "WMSV04033"
#DEFINE WMSV04034 "WMSV04034"
#DEFINE WMSV04035 "WMSV04035"
#DEFINE WMSV04036 "WMSV04036"
#DEFINE WMSV04037 "WMSV04037"
//-------------------------------------------------------------
/*/{Protheus.doc} WMSV076
Esta rotina é responsável pelo processo de distribuição dos
produtos após a separação, distribuindo cada pedido de venda
em um único endereço de forma exclusiva.
@author Jackson Patrick Werka
@since 15/04/2015
@version 1.0
/*/
//-------------------------------------------------------------
Static oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
Static lWMSV040EN := ExistBlock('WMSV040EN')

Function WMSV040()
Local cKey24    := VtDescKey(24)
Local bkey24    := VTSetKey(24)
Local cArmazem  := Space(TamSx3("D14_LOCAL")[1])
Local cEndereco := Space(TamSx3("D14_ENDER")[1])

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	
	DbSelectArea("D0E")

	If GetEndOrig(@cArmazem,@cEndereco)
		oDisSepItem:oDisEndOri:SetArmazem(cArmazem)
		oDisSepItem:oDisEndOri:SetEnder(cEndereco)
		oDisSepItem:oDisPrdLot:SetArmazem(cArmazem)
		oDisSepItem:oDisEndOri:SetArmazem(cArmazem)
		oDisSepItem:oDisSep:oDisEndDes:SetArmazem(cArmazem)
		// Atribui tecla de atalho para estorno
		VTSetKey(24,{|| EstDisSep()}, STR0001) // Estorno
		DistPrdLot()
	EndIf
	VTSetKey(24,bkey24,cKey24)
Return Nil
/*--------------------------------------------------------------------------------
---GetEndOrig
---Informa os dados de origem da distribuição da separação
---de lote, sub-lote e quantidade a ser conferida
---Jackson Patrick Werka - 01/04/2015
---cArmazem, Caracter, (Armazem origem)
---cEndereco, Caracter, (Endereço origem)
----------------------------------------------------------------------------------*/
Static Function GetEndOrig(cArmazem,cEndereco)
Local lEncerra := .F.

	Do While !lEncerra
		WMSVTCabec(STR0002,.F.,.F.,.T.) // Distribuicao
		@ 01,00 VTSay PadR(STR0003+":",VTMaxCol()) // Armazem
		@ 02,00 VTGet cArmazem Pict "@!" Valid VldArmazem(cArmazem)
		@ 03,00 VTSay PadR(STR0004+":",VTMaxCol()) // End. Separacao
		@ 04,00 VTGet cEndereco Pict "@!" Valid VldEndOrig(cArmazem,cEndereco)
		VtRead()
		// Valida se foi precionado Esc
		If VTLastKey() == 27
			lEncerra := WMSV040Esc(STR0005) // Deseja encerrar a distribuição?
			Loop
		EndIf
		Exit
	EndDo
Return !lEncerra
/*--------------------------------------------------------------------------------
---VldArmazem
---Validação do armazém informado.
---Jackson Patrick Werka - 01/04/2015
---cArmazem, Caracter, (Armazem origem)
----------------------------------------------------------------------------------*/
Static Function VldArmazem(cArmazem)
Local lRet := .T.
	If Empty(cArmazem)
		Return .F.
	EndIf
	If Empty(Posicione("NNR",1,xFilial("NNR")+cArmazem,"NNR_CODIGO"))
		WMSVTAviso(WMSV04002,STR0008) // Armazem invalido!
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---VldEndOrig
---Validação do endereço origem informado.
---de lote, sub-lote e quantidade a ser conferida
---Jackson Patrick Werka - 01/04/2015
---cEndereco, Caracter, (Endereço origem)
----------------------------------------------------------------------------------*/
Static Function VldEndOrig(cArmazem,cEndereco)
Local lRet      := .T.
Local cAliasD0E := Nil
	If Empty(cEndereco)
		Return .F.
	EndIf
	If Empty(Posicione("SBE",1,xFilial("SBE")+cArmazem+cEndereco,"BE_LOCALIZ")) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
		WMSVTAviso(WMSV04003,STR0009) // Endereço invalido!
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	If lRet
		cAliasD0E := GetNextAlias()
		BeginSql Alias cAliasD0E
			SELECT 1
			FROM %Table:D0E% D0E
			WHERE D0E.D0E_FILIAL = %xFilial:D0E%
			AND D0E.D0E_LOCORI = %Exp:cArmazem%
			AND D0E.D0E_ENDORI = %Exp:cEndereco%
			AND D0E.%NotDel%
		EndSql
		If (cAliasD0E)->(Eof())
			WMSVTAviso(WMSV04003,WmsFmtMsg(STR0054,{{"[VAR01]",cArmazem},{"[VAR02]",cEndereco}})) // Armazém [VAR01] e endereço [VAR02] sem distribuição de separação gerada!
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		(cAliasD0E)->(dbCloseArea())
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---DistPrdLot
---Permite ir executando a conferência dos produtos, informando os dados
---de lote, sub-lote e quantidade a ser conferida
---Jackson Patrick Werka - 01/04/2015
---lEstorno, Logico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function DistPrdLot(lEstorno)
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aTelaUMI  := {}
Local lEncerra  := .F.
// Solicita a confirmacao do lote nas operacoes com radio frequencia
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.T.)
Local cCodBar   := ""
Local cProduto  := ""
Local cLoteCtl  := ""
Local cSubLote  := ""
Local nQtde     := 0.00
Default lEstorno := .F.
	Do While !lEncerra
		cCodBar  := Space(128)
		cProduto := Space(TamSx3("D0E_PRODUT")[1])
		cLoteCtl := Space(TamSx3("D0E_LOTECT")[1])
		cSubLote := Space(TamSx3("D0E_NUMLOT")[1])

		// 01234567890123456789
		// 0 ____Distribuicao____
		// 1 Informe o Produto
		// 2 PA1
		// 3 Informe o Lote
		// 4 AUTO000636
		WMSVTCabec(Iif(lEstorno,STR0001+" ","")+STR0002,.F.,.F.,.T.) // Estorno // Distribuicao
		@ 01,00  VTSay STR0010 // Informe o Produto
		@ 02,00  VtGet cCodBar Picture "@!" Valid ValidPrdLot(@cProduto,@cLoteCtl,@cSubLote,@nQtde,lEstorno,@cCodBar)
		VtRead()

		If VTLastKey()==27
			If !lEstorno
				lEncerra := WMSV040Esc(STR0005) // Deseja encerrar a distribuição?
			Else
				lEncerra := .T.
			EndIf
			Loop
		EndIf
		
		If !lEncerra .And. lWmsLote
			If Rastro(cProduto)
				@ 03,00  VtSay STR0011 // Informe o Lote
				@ 03,06  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValLoteCtl(cLoteCtl,lEstorno)
				If Rastro(cProduto,"S")
					@ 04,00 VTSay STR0012 // Informe o Sub-Lote
					@ 04,10 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid ValSubLote(cSubLote,lEstorno)
				EndIf
				VtRead()
				
				If VTLastKey()==27
					If !lEstorno
						lEncerra := WMSV040Esc(STR0005) // Deseja encerrar a distribuição?
					Else
						lEncerra := .T.
					EndIf
					Loop
				EndIf
				// Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
				If !(Iif(Empty(cLoteCtl),.T.,ValLoteCtl(cLoteCtl,lEstorno))) .Or. ;
					!(Iif(Empty(cSubLote),.T.,ValSubLote(cSubLote,lEstorno)))
					Loop // Volta para o inicio do produto
				EndIf
			EndIf
		EndIf
		If !lEncerra
			// Carrega os dados do produto
			oDisSepItem:oDisPrdLot:LoadData()
			oDisSepItem:oDisEndOri:LoadData()
			DistPedDes(lEstorno,nQtde)
		EndIf
		// Estorno faz uma unica vez
		If lEstorno
			Exit
		EndIf
	EndDo

	// Restaura tela anterior
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---DistPrdLot
---Permite informar a quantidade a ser distribuida, caso haja mais de um pedido
---para distribuir do mesmo produto/lote deverá também escolher o pedido
---Jackson Patrick Werka - 01/04/2015
---lEstorno, Logico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function DistPedDes(lEstorno,nQtDist)
Local lRet        := .T.
Local lEncerra    := .F.
Local lCodBar     := .F.
Local lSelDist    := Empty(oDisSepItem:oDisSep:GetCodDis())
Local aTelaAnt    := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aListDist   := {}
Local oMntVolItem := Nil
Local oConExpItem := Nil
Local cPictQt     := ""
Local cUM         := ""
Local cWmsUMI     := ""
Local cDscUM      := ""
Local cWhere      := ""
Local cAliasD0E   := Nil
Local cPrdOri     := ""
Local nQtdTot     := 0
Local nQtdItem    := 0
Local nItem       := 0
Local nPrdOri     := 0
Local nQtdNorma   := DLQtdNorma(oDisSepItem:oDisPrdLot:GetProduto(),oDisSepItem:oDisEndOri:GetArmazem(),oDisSepItem:oDisEndOri:GetEstFis(),,.F.)

Default lEstorno  := .F.
Default nQtDist   := 0.00
	// Verifica se quantidade já preenchida via etiqueta
	lQtdBar := (nQtDist >0)
	Do While !lEncerra
		// Se chegou até aqui e não tem definido qual será a Distribuição/Carga/Pedido
		// Deve listar quais os pedidos em que o produto está pendente para o usuário escolher
		If lSelDist
			If !SelCodDist(aListDist,@lSelDist)
				Exit
			EndIf
		EndIf
		//Verifica produto origem
		// Parâmertro Where
		cWhere := "%"
		If !Empty(oDisSepItem:oDisSep:GetCarga())
			cWhere += " AND D0E_CARGA  = '"+oDisSepItem:oDisSep:GetCarga()+"'"
		EndIf
		If !Empty(oDisSepItem:oDisPrdLot:GetLoteCtl())
			cWhere += " AND D0E_LOTECT = '"+oDisSepItem:oDisPrdLot:GetLoteCtl()+"'"
		EndIf
		If !Empty(oDisSepItem:oDisPrdLot:GetNumLote())
			cWhere += " AND D0E_NUMLOT = '"+oDisSepItem:oDisPrdLot:GetNumLote()+"'"
		EndIf
		cWhere += "%"
		cAliasD0E := GetNextAlias()
		BeginSql Alias cAliasD0E
			SELECT DISTINCT D0E.D0E_PRDORI
			FROM %Table:D0E% D0E
			WHERE D0E_FILIAL = %xFilial:D0E%
			AND D0E.D0E_CODDIS = %Exp:oDisSepItem:oDisSep:GetCodDis()%
			AND D0E.D0E_PEDIDO = %Exp:oDisSepItem:oDisSep:GetPedido()%
			AND D0E.D0E_PRODUT = %Exp:oDisSepItem:oDisPrdLot:GetProduto()%
			AND D0E.%NotDel% 
			%Exp:cWhere%
		EndSql
		(cAliasD0E)->(dbEval({|| nPrdOri++}))
		(cAliasD0E)->(dbGoTop())
		If (cAliasD0E)->(!Eof()) 
			If nPrdOri > 1
				If WMSVTAviso(WMSV04035,STR0049,{STR0050,STR0051}) == 2 // Considerar como componente ou produto // Componente // Produto
					cPrdOri := oDisSepItem:oDisPrdLot:GetProduto()
				EndIf
			EndIf
			If Empty(cPrdOri)
				cPrdOri := (cAliasD0E)->D0E_PRDORI
			EndIf
		EndIf
		(cAliasD0E)->(dbCloseArea())
		
		oDisSepItem:oDisPrdLot:SetPrdOri(cPrdOri)
		oDisSepItem:LoadPrdDis()
		
		If lEstorno
			// Define o total deste pedido que pode ser estornado
			nQtdTot := oDisSepItem:GetQtdDis()
			If QtdComp(nQtdTot) == 0
				WMSVTAviso(WMSV04036,STR0022) // Produto não possui quantidade distribuída para estorno.
				lEncerra := .T.
				Loop
			EndIf
		Else
			// Define o total deste pedido que pode ser distribuído
			nQtdTot := oDisSepItem:GetQtdSep()-oDisSepItem:GetQtdDis()
			If QtdComp(nQtdTot) == 0
				WMSVTAviso(WMSV04037,STR0023) // Produto não pertence a nenhuma distibuição pendente.
				lEncerra := .T.
				Loop
			EndIF
		EndIf
		// Carrega unidade de medida, simbolo da unidade e quantidade na unidade  
		WmsValUM(nQtdTot,;                           // Quantidade movimento
				@cWmsUMI,;                            // Unidade parametrizada
				oDisSepItem:oDisPrdLot:GetProduto(),; // Produto
				oDisSepItem:oDisEndOri:GetArmazem(),; // Armazem
				oDisSepItem:oDisEndOri:GetEnder(),;   // Endereço
				Nil,;                                 // Item unidade medida
				.F.,;                                 // Indica se é uma conferência
				lQtdBar)                              // Indica se quantidade já preenchida
					
		// Seleciona unidade de medida
		Do While !lEncerra
			WmsSelUM(cWmsUMI,;                           // Unidade parametrizada 
					@cUM,;                                // Unidade medida reduzida
					@cDscUM,;                             // Descrição unidade medida
					nQtdTot,;                             // Quantidade movimento
					@nItem,;                              // Item seleção unidade
					@cPictQt,;                            // Mascara unidade medida
					@nQtdItem,;                           // Quantidade no item seleção unidade
					.F.,;                                 // Indica se é uma conferência
					STR0002,;                             // Descrição da tarefa
					oDisSepItem:oDisEndOri:GetArmazem(),; // Armazem
					oDisSepItem:oDisEndOri:GetEnder(),;   // Endereço
					oDisSepItem:oDisPrdLot:GetProduto(),; // Produto Origem
					oDisSepItem:oDisPrdLot:GetProduto(),; // Produto
					oDisSepItem:oDisPrdLot:GetLoteCtl(),; // Lote
					oDisSepItem:oDisPrdLot:GetNumLote(),; // sub-lote
					lQtdBar)                              // Indica se quantidade já preenchida
				
			If VTLastKey()==27
				If !lEstorno
					lEncerra := WMSV040Esc(STR0040) // Deseja cancelar a distribuição do pedido? 
				Else
					lEncerra := .T.
				EndIf
				Loop
			EndIf
			Exit
		EndDo	
		//-- Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
		Do While !lEncerra
			// 01234567890123456789
			// 0 ____Distribuicao____
			// 1 Carga/Pedido
			// 2 000001/000001
			// 3 Produto
			// 4 AUTO000636
			// 5 Qtde 999.00 UM
			// 6               240.00
			WMSVTCabec(Iif(lEstorno,STR0001+" ","")+STR0002,.F.,.F.,.T.) // Estorno // Distribuicao
			@ 01,00 VTSay Iif(!Empty(oDisSepItem:oDisSep:GetCarga()),STR0013+"/"+STR0014,STR0014) // Carga/Pedido // Pedido
			@ 02,00 VTSay Iif(!Empty(oDisSepItem:oDisSep:GetCarga()),oDisSepItem:oDisSep:GetCarga()+"/"+oDisSepItem:oDisSep:GetPedido(),oDisSepItem:oDisSep:GetPedido()) // Carga/Pedido // Pedido
			@ 03,00 VTSay STR0015 // Produto
			@ 04,00 VTSay oDisSepItem:oDisPrdLot:GetProdCol()
			@ 05,00 VTSay PadR('Qtd'+' '+AllTrim(Str(nQtdItem))+' '+cUM, VTMaxCol()) // Qtd 240.00 UN
			@ 06,00 VTGet nQtDist Picture cPictQt When Empty(nQtDist) Valid !Empty(nQtDist)
			VTRead()
			If VTLastKey()==27
				If !lEstorno
					lEncerra := WMSV040Esc(STR0040) // Deseja cancelar a distribuição do pedido?
				Else
					lEncerra := .T.
				EndIf
				Loop
			EndIf
			If !ValidQtd(@nQtDist,nItem,nQtdNorma,lEstorno)
				nQtDist := 0
				Loop
			EndIf
			Exit
		EndDo	
		If lEncerra
			lEncerra := .F.
			If lSelDist
				// Zera a quantidade informada pelo usuário
				nQtDist := 0
				// Apaga o pedido do objeto para forçar recarregar outro
				oDisSepItem:oDisSep:SetCodDis("")
				oDisSepItem:oDisSep:SetCarga("")
				oDisSepItem:oDisSep:SetPedido("")
				Loop
			Else
				Exit
			EndIf
		EndIf
		// Solicita o endereço destino para o pedido
		If !lEstorno
			If !GetEndDest(nQtDist)
				lEncerra := .T.
			EndIf
		Else
			GravaDistr(nQtDist,.T.)
		EndIf
		If !lEncerra .And. lSelDist
			// Apaga o pedido do objeto para forçar recarregar outro
			oDisSepItem:oDisSep:SetCodDis("")
			oDisSepItem:oDisSep:SetCarga("")
			oDisSepItem:oDisSep:SetPedido("")
		EndIf
		If !lEncerra .And. !lSelDist .And.;
			QtdComp(oDisSepItem:GetQtdDis()) >= QtdComp(oDisSepItem:GetQtdSep())
		EndIf
		Exit
	EndDo
	// Apaga o pedido do objeto para forçar recarregar outro
	oDisSepItem:oDisSep:SetCodDis("")
	oDisSepItem:oDisSep:SetCarga("")
	oDisSepItem:oDisSep:SetPedido("")
	// Restaura tela anterior
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return !lEncerra
/*--------------------------------------------------------------------------------
---SelCodDist
---Efetua a escolha do pedido de venda a ser distribuído
---Jackson Patrick Werka - 01/04/2015
---aListDist, array, (1-Distribuição, Caracter
                      2-Carga, Caracter
                      3-Pedido, Caracter
                      4-Qtde Origem
                      5-Qtde Separada
                      6-Qtde Distribuida)
---lSelDist, Logico, (Indica se seleciona distribuição)
----------------------------------------------------------------------------------*/
Static Function SelCodDist(aListDist,lSelDist)
Local lEncerra  := .F.
Local aHeader   := {STR0013,STR0014,STR0016}   // Pedido // Carga // Qtd Dist
Local aSize     := {6,6,5}
Local aPedidos  := {}
Local nSelDist  := 0
	// Limpa a listagem anterior
	aListDist := {}
	// Carrega a lista dos pedidos que estão pendentes de distribuição
	QtdPrdDist(.F.,aListDist)
	While !lEncerra .And. nSelDist == 0
		// Se possui mais de um pedido, mostra um browse para o usuário selecionar
		If Len(aListDist) > 1
			aPedidos := {}
			// Copia os dados para montar o browse
			AEval(aListDist,{|x|AAdd(aPedidos,{x[2],x[3],x[5]-x[6]})})
			nSelDist := 1
			WMSVTCabec(STR0002,.F.,.F.,.T.) // Distribuicao
			WMSVTRodPe(STR0017,.F.)   // Escolha um Pedido
			nSelDist := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),aHeader,aPedidos,aSize,,nSelDist)
		Else // Senão já carrega no objeto as informações da primera posição
			nSelDist := 1
			lSelDist := .F.
		EndIf

		If VTLastKey()==27
			lEncerra := .T.
		EndIf
	EndDo

	If !lEncerra
		If Len(aListDist) > 0
			oDisSepItem:oDisSep:SetCodDis(aListDist[nSelDist,1])
			oDisSepItem:oDisSep:SetCarga(aListDist[nSelDist,2])
			oDisSepItem:oDisSep:SetPedido(aListDist[nSelDist,3])
			oDisSepItem:SetQtdOri(aListDist[nSelDist,4])
			oDisSepItem:SetQtdSep(aListDist[nSelDist,5])
			oDisSepItem:SetQtdDis(aListDist[nSelDist,6])
		Else
			lEncerra := .T.
		EndIf
	EndIf
Return !lEncerra
/*--------------------------------------------------------------------------------
---SelCodDist
---Informa os dados do endereço destino da distribuição da separação
---Jackson Patrick Werka - 01/04/2015
---nQtDist, Numerico, (Qtde distribuida)
----------------------------------------------------------------------------------*/
Static Function GetEndDest(nQtDist)
Local lEncerra  := .F.
Local cEndereco := Space(TamSx3("D0D_ENDDES")[1])
Local cKey24    := VtDescKey(24)
Local bkey24    := VTSetKey(24) // Limpa tecla de estorno
	// Carrega os dados da capa da distribuição
	oDisSepItem:oDisSep:oDisEndDes:SetArmazem(oDisSepItem:oDisEndOri:GetArmazem())
	oDisSepItem:oDisSep:LoadData()
	Do While !lEncerra
		If !Empty(oDisSepItem:oDisSep:oDisEndDes:GetEnder())
			WMSVTCabec(STR0018,.F.,.F.,.T.)   // Leve para o Endereço
			@ 02, 00 VTSay PadR(STR0019, VTMaxCol()) // Endereço
			@ 03, 00 VTSay PadR(oDisSepItem:oDisSep:oDisEndDes:GetEnder(), VTMaxCol())
			@ 05, 00 VTSay PadR(STR0020, VTMaxCol()) // Confirme!
			@ 06, 00 VTGet cEndereco Pict '@!' Valid VldEndDest(@cEndereco,"1")
		Else
			WMSVTCabec(STR0021,.F.,.F.,.T.)   // Informe o Endereço
			@ 02, 00 VTSay PadR(STR0019+":", VTMaxCol()) // End. Distribuicao
			@ 03, 00 VTGet cEndereco Pict '@!' Valid VldEndDest(@cEndereco,"2")
		EndIf
		VTRead()
		// Valida se foi precionado Esc
		If VTLastKey() == 27
			lEncerra := WMSV040Esc(STR0040) // Deseja cancelar a distribuição do pedido?
			Loop
		EndIf

		If !lEncerra
			GravaDistr(nQtDist)
			Exit
		EndIf
	EndDo
	// Restaura tecla de atalho
	VTSetKey(24,bkey24,cKey24)
Return !lEncerra
/*--------------------------------------------------------------------------------
---EstDisSep
---Informa os dados do endereço para estorno da distribuição da separação
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function EstDisSep()
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cKey24    := VtDescKey(24) // Recupera descrição - Deve ser antes de limpar
Local bkey24    := VTSetKey(24) // Limpa tecla de estorno
// Salva os dados do pedido atual
Local cCodDisAnt := oDisSepItem:oDisSep:GetCodDis()
Local cCargaAnt  := oDisSepItem:oDisSep:GetCarga()
Local cPedidoAnt := oDisSepItem:oDisSep:GetPedido()
Local cArmazAnt  := oDisSepItem:oDisEndOri:GetArmazem()
Local cEnderAnt  := oDisSepItem:oDisEndOri:GetEnder()
Local cPrdOriAnt := oDisSepItem:oDisPrdLot:GetPrdOri()
Local cProdutAnt := oDisSepItem:oDisPrdLot:GetProduto()
Local cLoteCtAnt := oDisSepItem:oDisPrdLot:GetLoteCtl()
Local cNumLotAnt := oDisSepItem:oDisPrdLot:GetNumLote()
Local nQtdOriAnt := oDisSepItem:GetQtdOri()
Local nQtdSepAnt := oDisSepItem:GetQtdSep()
Local nQtdDisAnt := oDisSepItem:GetQtdDis()
	 
	If GetEndEst()
		DistPrdLot(.T.)
	EndIf
	// Restaura tecla de estorno
	VTSetKey(24,bkey24,cKey24)
	// Restaura os dados anteriores
	oDisSepItem:oDisSep:SetCodDis(cCodDisAnt)
	oDisSepItem:oDisSep:SetCarga(cCargaAnt)
	oDisSepItem:oDisSep:SetPedido(cPedidoAnt)
	oDisSepItem:oDisSep:oDisEndDes:SetArmazem(cArmazAnt)
	oDisSepItem:oDisEndOri:SetArmazem(cArmazAnt)
	oDisSepItem:oDisEndOri:SetEnder(cEnderAnt)
	oDisSepItem:oDisPrdLot:SetPrdOri(cPrdOriAnt)
	oDisSepItem:oDisPrdLot:SetProduto(cProdutAnt)
	oDisSepItem:oDisPrdLot:SetLoteCtl(cLoteCtAnt)
	oDisSepItem:oDisPrdLot:SetNumLote(cNumLotAnt)
	oDisSepItem:SetQtdOri(nQtdOriAnt)
	oDisSepItem:SetQtdSep(nQtdSepAnt)
	oDisSepItem:SetQtdDis(nQtdDisAnt)
	
	// Restaura tela anterior
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---GetEndEst
---Informa os dados do endereço para estorno da distribuição da separação
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function GetEndEst()
Local lEncerra  := .F.
Local cArmazem  := Space(TamSx3("D0D_LOCDES")[1])
Local cCarga    := Space(TamSx3("D0D_CARGA")[1])
Local cPedido   := Space(TamSx3("D0D_PEDIDO")[1])
Local cEndereco := Space(TamSx3("D0D_ENDDES")[1])
Local nCol := Len(STR0003) + 1
	cArmazem := oDisSepItem:oDisSep:oDisEndDes:GetArmazem()
	Do While !lEncerra
		WMSVTCabec(STR0019+" "+STR0001,.F.,.F.,.T.)   // Endereço Estorno
		@ 01,00 VTSay PadR(STR0003+":",VTMaxCol()) // Armazem
		@ 01,nCol VTGet cArmazem Pict "@!" Valid VldArmazem(cArmazem)
		@ 02,00 VTSay PadR(STR0013+":",VTMaxCol()) // Carga      
		@ 03,00 VTGet cCarga Pict "@!" Valid Empty(cCarga) .Or. VldCarga(cCarga)
		@ 04,00 VTSay PadR(STR0014+":",VTMaxCol()) // Pedido      
		@ 05,00 VTGet cPedido Pict "@!" Valid !Empty(cPedido) .And. VldPedido(cPedido)
		@ 06,00 VTSay PadR(STR0019, VTMaxCol()) // Endereco
		@ 07,00 VTGet cEndereco Pict '@!' Valid VldEndEst(cArmazem,cCarga,cPedido,cEndereco)
		VTKeyBoard(Chr(13))
		VTRead()
		// Valida se foi precionado Esc
		If VTLastKey() == 27
			lEncerra := .T.
			Loop
		EndIf
		Exit
	EndDo
Return !lEncerra
/*--------------------------------------------------------------------------------
---ValidPrdLot
---Valida o produto informado, verificando se o mesmo pertence a alguma
---distribuição de separação que está pendente ou em andamento
---Jackson Patrick Werka - 01/04/2015
---cProduto, character, (Produto informado)
---cLoteCtl, character, (Lote etiqueta)
---cSubLote, character, (Sub-lote etiqueta)
---nQtde, numerico, (Quantidade etiqueta)
---lEstorno, Logico, (Indica se é um estorno)
---cCodBar, character, (Codigo de barras)
----------------------------------------------------------------------------------*/
Static Function ValidPrdLot(cProduto,cLoteCtl,cSubLote,nQtde,lEstorno,cCodBar)
Local aAreaAnt := GetArea()
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lRet     := .T.

	VTClearBuffer()
	lRet := !Empty(cCodBar)
	If lRet
		lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cSubLote,@nQtde,@cCodBar)
	EndIf
	// Deve validar se o produto possui quantidade para ser distribuida
	If lRet	
		oDisSepItem:oDisPrdLot:SetProduto(cProduto)
		oDisSepItem:oDisPrdLot:SetLoteCtl(cLoteCtl)
		oDisSepItem:oDisPrdLot:SetNumLote(cSubLote)
		QtdPrdDist(lEstorno)
		If lEstorno
			If QtdComp(oDisSepItem:GetQtdDis()) == 0
				WMSVTAviso(WMSV04008,STR0022) // Produto não possui quantidade distribuída para estorno.
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
		Else
			If QtdComp(oDisSepItem:GetQtdOri()) == 0
				WMSVTAviso(WMSV04009,STR0023) // Produto não pertence a nenhuma distibuição pendente.
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
			If lRet .And. QtdComp(oDisSepItem:GetQtdSep()) == 0
				WMSVTAviso(WMSV04010,STR0024) // Produto não possui quantidade separada para distribuição.
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
			If lRet .And. QtdComp(oDisSepItem:GetQtdSep()) == QtdComp(oDisSepItem:GetQtdDis()) .And. QtdComp(oDisSepItem:GetQtdSep()) < QtdComp(oDisSepItem:GetQtdOri())
				WMSVTAviso(WMSV04030,STR0044) // Produto possui quantidade pendente de separação.
				VTKeyBoard(Chr(20))
				lRet := .F.
			EndIf
		EndIf
		If lRet
			WmsMontPrd( Nil,;                                  // Unidade parametrizada 
						.T.,;                                  // Indica se é uma conferência
						STR0002,;                              // Descrição da tarefa
						oDisSepItem:oDisEndOri:GetArmazem(),;  // Armazem
						oDisSepItem:oDisEndOri:GetEnder(),;    // Endereço
						oDisSepItem:oDisPrdLot:GetProduto(),;  // Produto Origem
						oDisSepItem:oDisPrdLot:GetProduto(),;  // Produto
						oDisSepItem:oDisPrdLot:GetLoteCtl(),;  // Lote
						oDisSepItem:oDisPrdLot:GetNumLote(),;  // sub-lote
						Nil,;                                  // Id Unitizador
						nQtde)                                 // Quantidade preenchida
			VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValLoteCtl
---Valida o produto/lote informado, verificando se o mesmo pertence a algum
---pedido/carga que estaja pendnete de distribuição da separação
---Jackson Patrick Werka - 01/04/2015
---cLoteCtl, character, (Lote etiqueta)
---cSubLote, character, (Sub-lote etiqueta)
---lEstorno, Logico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function ValLoteCtl(cLoteCtl,lEstorno)
Local lRet     := .T.
	If Empty(cLoteCtl)
		Return .F.
	EndIf
	oDisSepItem:oDisPrdLot:SetLoteCtl(cLoteCtl)
	QtdPrdDist(lEstorno)
	If lEstorno
		If QtdComp(oDisSepItem:GetQtdDis()) == 0
			WMSVTAviso(WMSV04011,STR0025) // Produto/Lote não pertence a nenhuma distibuição pendente.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	Else
		If QtdComp(oDisSepItem:GetQtdOri()) == 0
			WMSVTAviso(WMSV04012,STR0026) // Produto/Lote não pertence a nenhuma distibuição pendente.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		If lRet .And. QtdComp(oDisSepItem:GetQtdSep()) == 0
			WMSVTAviso(WMSV04013,STR0027) // Produto/Lote não possui quantidade separada para distibuição.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValSubLote
---Valida o produto/rastro informado, verificando se o mesmo pertence a algum
---pedido/carga que estaja pendnete de distribuição da separação
---Jackson Patrick Werka - 01/04/2015
---cSubLote, character, (Sub-lote etiqueta)
---lEstorno, Logico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function ValSubLote(cSubLote,lEstorno)
Local lRet    := .T.
	If Empty(cSubLote)
		Return .F.
	EndIf
	oDisSepItem:oDisPrdLot:SetNumLote(cSubLote)
	QtdPrdDist(lEstorno)
	If lEstorno
		If QtdComp(oDisSepItem:GetQtdDis()) == 0
			WMSVTAviso(WMSV04014,STR0028) // Produto/Lote não pertence a nenhuma distibuição pendente.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	Else
		If QtdComp(oDisSepItem:GetQtdOri()) == 0
			WMSVTAviso(WMSV04015,STR0029) // Produto/Rastro não pertence a nenhuma distibuição pendente.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		If lRet .And. QtdComp(oDisSepItem:GetQtdSep()) == 0
			WMSVTAviso(WMSV04016,STR0030) // Produto/Rastro não possui quantidade separada para distibuição.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---QtdPrdDist
---Permite carregar a quantidade do produto que está pendente de distribuição
---Jackson Patrick Werka - 01/04/2015
---lEstorno, Logico, (Indica se é um estorno)
---cSubLote, character, (Sub-lote etiqueta)
---aListDist, array, (1-Distribuição, Caracter
                      2-Carga, Caracter
                      3-Pedido, Caracter
                      4-Qtde Origem
                      5-Qtde Separada
                      6-Qtde Distribuida)
----------------------------------------------------------------------------------*/
Static Function QtdPrdDist(lEstorno,aListDist)
Local aAreaAnt   := GetArea()
Local aTamSX3    := TamSx3('D0E_QTDORI')
Local cWhere     := ""
Local cAliasQry  := GetNextAlias()
Local cCodDist   := Space(TamSX3("D0E_CODDIS")[1])
Local cCarga     := Space(TamSX3("D0E_CARGA" )[1])
Local cPedido    := Space(TamSX3("D0E_PEDIDO")[1])
Local cCodDisAnt := cCodDist
Local cCargaAnt  := cCarga
Local cPedidoAnt := cPedido
Local nNumDist   := 0
Local nQtdOri    := 0
Local nQtdSep    := 0
Local nQtdDis    := 0

Default lEstorno := .F.

	// Parâmetro Where
	cWhere := "%"
	If !Empty(oDisSepItem:oDisSep:GetCodDis())
		cWhere += " AND D0E_CODDIS  = '"+oDisSepItem:oDisSep:GetCodDis()+"'"
	EndIf
	If !Empty(oDisSepItem:oDisSep:GetCarga())
		cWhere += " AND D0E_CARGA  = '"+oDisSepItem:oDisSep:GetCarga()+"'"
	EndIf
	If !Empty(oDisSepItem:oDisSep:GetPedido())
		cWhere += " AND D0E_PEDIDO = '"+oDisSepItem:oDisSep:GetPedido()+"'"
	EndIf
	If !Empty(oDisSepItem:oDisPrdLot:GetLoteCtl())
		cWhere += " AND D0E_LOTECT  = '"+oDisSepItem:oDisPrdLot:GetLoteCtl()+"'"
	EndIf
	If !Empty(oDisSepItem:oDisPrdLot:GetNumLote())
		cWhere += " AND D0E_NUMLOT  = '"+oDisSepItem:oDisPrdLot:GetNumLote()+"'"
	EndIf
	cWhere += "%"
	If lEstorno
		BeginSql Alias cAliasQry
			SELECT D0E.D0E_CODDIS,
					D0E.D0E_CARGA,
					D0E.D0E_PEDIDO,
					SUM(D0E.D0E_QTDORI) D0E_QTDORI,
					SUM(D0E.D0E_QTDSEP) D0E_QTDSEP,
					SUM(D0E.D0E_QTDDIS) D0E_QTDDIS
			FROM %Table:D0E% D0E
			WHERE D0E.D0E_FILIAL = %xFilial:D0E%
			AND D0E.D0E_LOCORI = %Exp:oDisSepItem:oDisEndOri:GetArmazem()%
			AND D0E.D0E_PRODUT = %Exp:oDisSepItem:oDisPrdLot:GetProduto()%
			AND %NotDel%
			%Exp:cWhere%
			GROUP BY D0E.D0E_CODDIS,
						D0E.D0E_CARGA,
						D0E.D0E_PEDIDO
			ORDER BY D0E.D0E_CODDIS,
						D0E.D0E_CARGA,
						D0E.D0E_PEDIDO
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT D0E.D0E_CODDIS,
					D0E.D0E_CARGA,
					D0E.D0E_PEDIDO,
					SUM(D0E.D0E_QTDORI) D0E_QTDORI,
					SUM(D0E.D0E_QTDSEP) D0E_QTDSEP,
					SUM(D0E.D0E_QTDDIS) D0E_QTDDIS
			FROM %Table:D0E% D0E
			WHERE D0E.D0E_FILIAL = %xFilial:D0E%
			AND D0E.D0E_LOCORI = %Exp:oDisSepItem:oDisEndOri:GetArmazem()%
			AND D0E.D0E_PRODUT = %Exp:oDisSepItem:oDisPrdLot:GetProduto()%
			AND (D0E.D0E_QTDSEP - D0E.D0E_QTDDIS) > 0 // Pendente
			AND D0E.%NotDel%
			%Exp:cWhere%
			GROUP BY D0E_CODDIS, D0E_CARGA, D0E_PEDIDO"
			ORDER BY D0E_CODDIS, D0E_CARGA, D0E_PEDIDO"
		EndSql
	EndIf
	TcSetField(cAliasQry,'D0E_QTDORI','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasQry,'D0E_QTDSEP','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasQry,'D0E_QTDDIS','N',aTamSX3[1],aTamSX3[2])
	Do While (cAliasQry)->(!Eof())
		cCodDist := (cAliasQry)->D0E_CODDIS
		cCarga   := (cAliasQry)->D0E_CARGA
		cPedido  := (cAliasQry)->D0E_PEDIDO
		nQtdOri  += (cAliasQry)->D0E_QTDORI
		nQtdSep  += (cAliasQry)->D0E_QTDSEP
		nQtdDis  += (cAliasQry)->D0E_QTDDIS
		// Se é uma distribuição diferente da anterior, soma uma na contagem
		If (cCodDisAnt+cCargaAnt+cPedidoAnt != cCodDist+cCarga+cPedido)
			nNumDist++
			cCodDisAnt := cCodDist
			cCargaAnt  := cCarga
			cPedidoAnt := cPedido
			If aListDist != Nil
				If QtdComp(nQtdSep) > QtdComp(nQtdDis)
					AAdd(aListDist,{cCodDist,cCarga,cPedido,nQtdOri,nQtdSep,nQtdDis})
				EndIf
				nQtdOri := 0
				nQtdSep := 0
				nQtdDis := 0
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	If !lEstorno
		// Se tem mais de uma distribuição diferente, zera os valores da carga/pedido
		// Deve exibir uma tela para o usuário escolher qual pedido quer distribuir
		If nNumDist > 1
			cCodDist := Space(TamSX3("D0E_CODDIS")[1])
			cCarga   := Space(TamSX3("D0E_CARGA" )[1])
			cPedido  := Space(TamSX3("D0E_PEDIDO")[1])
		EndIf
	EndIf
	// Se não está carregando na lista, carrega no objeto
	If aListDist == Nil
		If !lEstorno
			oDisSepItem:oDisSep:SetCodDis(cCodDist)
			oDisSepItem:oDisSep:SetCarga(cCarga)
			oDisSepItem:oDisSep:SetPedido(cPedido)
		EndIf
		oDisSepItem:SetQtdOri(nQtdOri)
		oDisSepItem:SetQtdSep(nQtdSep)
		oDisSepItem:SetQtdDis(nQtdDis)
	EndIf

	RestArea(aAreaAnt)
Return .T.
/*--------------------------------------------------------------------------------
---ValidQtd
---Valida o produto/rastro informado, verificando se o mesmo pertence a algum
---pedido/carga que estaja pendnete de distribuição da separação
---Jackson Patrick Werka - 01/04/2015
---nQtDist, Numerico, (Qtde distribuida)
---nItem, Numerico, (Qtde item)
---nQtdNorma, Numerico, (Qtde norma)
---lEstorno, Logico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function ValidQtd(nQtDist,nItem,nQtdNorma,lEstorno)
Local lRet        := .T.
Local oConExpItem := Nil
Local oMntVolItem := Nil
Local oProdComp   := Nil
Local aIdDisSep   := {}
Local aMntVol     := {}
Local aConfExp    := {}
Local nQtdPrdDis  := 0
Local nQtdPrdSep  := 0
Local nQtdEmbMnt  := 0
Local nQtdCofExp  := 0
Local nQtdMult    := 0
Local nQtDisAux   := 0
Local nI          := 0
//---- Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM   := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
Local cProdutAux  := ""
Local cPrdOriAux  := ""

Default lEstorno := .F.

	If Empty(nQtDist)
		Return .F.
	EndIf
	// O sistema trabalha sempre na 1a.UM
	If nItem == 1
		// Converter de U.M.I. p/ 1a.UM
		nQtDist := (nQtDist*nQtdNorma)
	ElseIf nItem == 2
		// Converter de 2a.UM p/ 1a.UM
		nQtDist := ConvUm(oDisSepItem:oDisPrdLot:GetProduto(),0,nQtDist,1)
	EndIf
	// Validando as quantidades informadas
	If lEstorno
		nQtdPrdDis := oDisSepItem:GetQtdDis()
		If QtdComp(nQtDist) > QtdComp(nQtdPrdDis) .And.;
			QtdComp(Abs(nQtdPrdDis-nQtDist)) > QtdComp(nToler1UM)
			WMSVTAviso(WMSV04017,STR0031) // Quantidade informada maior que a quantidade distribuida.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		If lRet
			oProdComp := WMSDTCProdutoComponente():New()
			oProdComp:SetPrdOri(oDisSepItem:oDisPrdLot:GetPrdOri())
			oProdComp:SetProduto(oDisSepItem:oDisPrdLot:GetProduto())
			oProdComp:EstProduto()
			aProduto := oProdComp:GetArrProd()
			For nI := 1 To Len(aProduto)
				cProdutAux := aProduto[nI][1]
				cPrdOriAux := aProduto[nI][3]
				nQtdMult   := aProduto[nI][2]
				nQtDisAux := nQtDist * nQtdMult 
		
				aIdDisSep := oDisSepItem:GerAIdDCF()
				//Valida se possui montagem de volume
				oMntVolItem := WMSDTCMontagemVolumeItens():New()
				oMntVolItem:SetCarga(oDisSepItem:oDisSep:GetCarga())
				oMntVolItem:SetPedido(oDisSepItem:oDisSep:GetPedido())
				oMntVolItem:SetPrdOri(cPrdOriAux)
				oMntVolItem:SetProduto(cProdutAux)
				oMntVolItem:SetLoteCtl(oDisSepItem:oDisPrdLot:GetLoteCtl())
				oMntVolItem:SetNumLote(oDisSepItem:oDisPrdLot:GetNumLote())
				oMntVolItem:SetCodMnt(oMntVolItem:oMntVol:FindCodMnt())
				// Busca quantidade sumarizada das quantidade montadas que possuem distribuição
				aMntVol := oMntVolItem:ChkQtdMnt(aIdDisSep)
				nQtdEmbMnt := aMntVol[2]
				//Valida se possui distribuição de separação, apenas se já não foi validado o volume
				oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
				oConExpItem:SetCarga(oDisSepItem:oDisSep:GetCarga())
				oConExpItem:SetPedido(oDisSepItem:oDisSep:GetPedido())
				oConExpItem:SetPrdOri(cPrdOriAux)
				oConExpItem:SetProduto(cProdutAux)
				oConExpItem:SetLoteCtl(oDisSepItem:oDisPrdLot:GetLoteCtl())
				oConExpItem:SetNumLote(oDisSepItem:oDisPrdLot:GetNumLote())
				oConExpItem:SetCodExp(oConExpItem:oConfExp:FindCodExp())
				// Busca quantidade sumarizada da distribuição de separação
				aConfExp := oConExpItem:ChkQtdCof(aIdDisSep)
				nQtdCofExp := aConfExp[2]
				// Valida se é possivel estorno da distrição desconsiderando a conferentecia de expedição
				If QtdComp(nQtdCofExp) > QtdComp(0) .And. QtdComp(nQtdPrdDis - nQtdEmbMnt - nQtdCofExp) < QtdComp(nQtDisAux)
					WMSVTAviso(WMSV04034,STR0053) //Quantidade do item da distribuição possui conferência de expedição, primeiro estorne a conferência!
					lRet := .F.
				EndIf
				// Valida se é possivel estorno da distrição desconsiderando a montagem de volume
				If lRet .And. QtdComp(nQtdEmbMnt) > QtdComp(0) .And. QtdComp(nQtdPrdDis - nQtdEmbMnt - nQtdCofExp) < QtdComp(nQtDist)
					WMSVTAviso(WMSV04033,STR0052) //Quantidade do item da distribuição possui montagem de volume, primeiro estorne a montagem!
					lRet := .F.
				EndIf
				If !lRet 
					Exit
				EndIf
			Next nI	
		EndIf
		// Deve validar se a quantidade a ser estornada não está faturada
	Else
		nQtdPrdDis := oDisSepItem:GetQtdSep()-oDisSepItem:GetQtdDis()
		If QtdComp(nQtDist) > QtdComp(nQtdPrdDis) .And.;
			QtdComp(Abs(nQtdPrdDis-nQtDist)) > QtdComp(nToler1UM)
			WMSVTAviso(WMSV04018,STR0032) // Quantidade informada maior que a quantidade a ser distribuida.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		// Valida se a quantidade separada é maior ou igual a quantidade conferida mais o está sendo conferido
		nQtdPrdSep := oDisSepItem:GetQtdSep()
		nQtdPrdDis := oDisSepItem:GetQtdDis()
		If lRet .And. QtdComp(nQtdPrdDis+nQtDist) > QtdComp(nQtdPrdSep) .And.;
			QtdComp(Abs(nQtdPrdSep-(nQtdPrdDis+nQtDist))) > QtdComp(nToler1UM)
			WMSVTAviso(WMSV04019,STR0033) // Quantidade distribuida mais a informada maior que quantidade total separada.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---VldEndDest
---Validação do endereço destino informado.
---Jackson Patrick Werka - 01/04/2015
---cEndereco, Caracter, (Endereço informado)
----------------------------------------------------------------------------------*/
Static Function VldEndDest(cEndereco,cOpc)
Local lRet      := .T.
Local aParamPE  := {}
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
Local cMensagem := ""

	If Empty(cEndereco)
		Return .F.
	EndIf
	If !Empty(oDisSepItem:oDisSep:oDisEndDes:GetEnder()) .And. oDisSepItem:oDisSep:oDisEndDes:GetEnder() != cEndereco
		WMSVTAviso(WMSV04020,STR0034) // Endereço diferente do solicitado.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	If lRet .And. Empty(Posicione("SBE",1,xFilial("SBE")+oDisSepItem:oDisSep:oDisEndDes:GetArmazem()+cEndereco,"BE_LOCALIZ")) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
		WMSVTAviso(WMSV04021,STR0009) // Endereço invalido!
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Deve validar se o endereço não está em uso por outra distribuição
	If lRet .And. Empty(oDisSepItem:oDisSep:oDisEndDes:GetEnder())
		BeginSql Alias cAliasQry
			SELECT D0D.D0D_CARGA,
					D0D.D0D_PEDIDO
			FROM %Table:D0D% D0D
			WHERE D0D.D0D_FILIAL = %xFilial:D0D%
			AND D0D.D0D_LOCDES = %Exp:oDisSepItem:oDisSep:oDisEndDes:GetArmazem()%
			AND D0D.D0D_ENDDES = %Exp:cEndereco%
			AND D0D.D0D_STATUS = '1' // Pendente
			AND D0D.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			cMensagem := STR0035+" "+;
							 Iif(Empty((cAliasQry)->D0D_CARGA),STR0014+": ",STR0013+"/"+STR0014+": ")+;
							 Iif(Empty((cAliasQry)->D0D_CARGA),(cAliasQry)->D0D_PEDIDO,(cAliasQry)->D0D_CARGA+"/"+(cAliasQry)->D0D_PEDIDO)
			WMSVTAviso(WMSV04022,cMensagem) // O endereço está em uso
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If lRet .And. !Empty(cEndereco) .And. oDisSepItem:oDisEndOri:GetEnder() == cEndereco	
		WMSVTAviso(WMSV04029,STR0043) // "Endereço destino igual ao origem!"
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	
	If lRet
		oDisSepItem:oDisSep:oDisEndDes:SetEnder(cEndereco)
	EndIf
	
	If lRet .And. lWMSV040EN
		aParamPE := {oDisSepItem:oDisSep:GetCarga(),;
						oDisSepItem:oDisSep:GetPedido(),;
						oDisSepItem:oDisEndOri:GetArmazem(),;
						cEndereco,;
						cOpc}
		ExecBlock('WMSV040EN', .F., .F., aParamPE)
	EndIf

	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---VldEndEst
---Validação do endereço destino informado.
---Jackson Patrick Werka - 01/04/2015
---cArmazem, Caracter, (Armazem informado)
---cEndereco, Caracter, (Endereço informado)
----------------------------------------------------------------------------------*/
Static Function VldEndEst(cArmazem,cCarga,cPedido,cEndereco)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()

	If Empty(cEndereco)
		Return .F.
	EndIf
	If lRet .And. Empty(Posicione("SBE",1,xFilial("SBE")+cArmazem+cEndereco,"BE_LOCALIZ")) // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
		WMSVTAviso(WMSV04023,STR0009) // Endereço invalido!
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Deve validar se o endereço possui um pedido de uma distribuição que não está todo faturado
	If lRet
		BeginSql Alias cAliasQry
		SELECT  D0D.D0D_CODDIS,
				D0D.D0D_CARGA,
				D0D.D0D_PEDIDO
		FROM %Table:D0D% D0D
		WHERE D0D.D0D_FILIAL = %xFilial:D0D%
		AND D0D.D0D_LOCDES = %Exp:cArmazem%
		AND D0D.D0D_CARGA = %Exp:cCarga%
		AND D0D.D0D_PEDIDO = %Exp:cPedido%
		AND D0D.D0D_ENDDES = %Exp:cEndereco%
		AND D0D.%NotDel%
		AND D0D.D0D_CODDIS = ( SELECT MAX(D0DA.D0D_CODDIS)
								FROM %Table:D0D% D0DA
								WHERE D0DA.D0D_FILIAL = %xFilial:D0D%
								AND D0DA.D0D_LOCDES = %Exp:cArmazem%
								AND D0DA.D0D_CARGA = %Exp:cCarga%
								AND D0DA.D0D_PEDIDO = %Exp:cPedido%
								AND D0DA.D0D_ENDDES = %Exp:cEndereco%
								AND D0DA.%NotDel% )
		EndSql
		If (cAliasQry)->(Eof())
			WMSVTAviso(WMSV04024,STR0036) // Não existe nenhum pedido para este endereço.
			VTKeyBoard(Chr(20))
			lRet := .F.
		Else
			oDisSepItem:oDisSep:SetCodDis((cAliasQry)->D0D_CODDIS)
			oDisSepItem:oDisSep:SetCarga((cAliasQry)->D0D_CARGA)
			oDisSepItem:oDisSep:SetPedido((cAliasQry)->D0D_PEDIDO)
			If oDisSepItem:oDisSep:LoadData()
				If oDisSepItem:oDisSep:GetLibEst() == "2" .And. oDisSepItem:oDisSep:ChkPedFat()
					WMSVTAviso(WMSV04025,STR0037) // O pedido alocado no endereço já está faturado, não é possível estornar.
					VTKeyBoard(Chr(20))
					lRet := .F.
				EndIf
			Else
				WMSVTAviso(WMSV04026,oDisSepItem:oDisSep:GetErro())
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
		// Se não é um pedido válido, apaga os dados do objeto
		If !lRet
			oDisSepItem:oDisSep:SetCodDis("")
			oDisSepItem:oDisSep:SetCarga("")
			oDisSepItem:oDisSep:SetPedido("")
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---GravaDistr
---Efetua a gravação da quantidade distribuída para o produto
---Jackson Patrick Werka - 01/04/2015
---nQtDist, Numerico, (Qtde distribuida)
---lEstorno, Logico, (Indica se é um estorno)
----------------------------------------------------------------------------------*/
Static Function GravaDistr(nQtDist,lEstorno)
Local lRet      := .T.
Local lFinaliz  := .F.
Local aAreaAnt  := GetArea()
Local aTamD0E   := TamSx3("D0E_QTDDIS")
Local aTamD11   := TamSx3("D11_QTMULT")
Local cWhere    := ""
Local cAliasD0E := GetNextAlias()
Local cAliasQry := Nil
Local cMensagem := ""
Local cPrdOri   := ""
Local cEndereco := oDisSepItem:oDisSep:oDisEndDes:GetEnder()
Local cArmazem  := oDisSepItem:oDisSep:oDisEndDes:GetArmazem()
Local nQtDisPrd := 0
Local nQtMult   := 0
Local nProdut   := 0
Local nQtDist1  := 0

Default lEstorno:= .F.

	Begin Transaction
		// Deve verificar se o produto informado foi um produto pai e buscar os filhos
		cWhere := "%"
		If oDisSepItem:oDisPrdLot:HasRastSub() .And. !Empty(oDisSepItem:oDisPrdLot:GetNumLote())
			// Valida se controla lote
			If oDisSepItem:oDisPrdLot:HasRastro() .And. !Empty(oDisSepItem:oDisPrdLot:GetLoteCtl())
				cWhere += " AND D0E.D0E_LOTECT = '"+oDisSepItem:oDisPrdLot:GetLoteCtl()+"'"
				// Valida se controla sublote
				If oDisSepItem:oDisPrdLot:HasRastSub() .And. !Empty(oDisSepItem:oDisPrdLot:GetNumLote()) 
					cWhere += " AND D0E.D0E_NUMLOT = '"+oDisSepItem:oDisPrdLot:GetNumLote()+"'"
				EndIf
			EndIf
		EndIf
		cWhere += "%"
		If lEstorno
			BeginSql Alias cAliasD0E
				SELECT D0E.R_E_C_N_O_ RECNOD0E,
						D0E.D0E_PRODUT,
						D0E_PRDORI,
						D0E.D0E_QTDDIS,
						D11.D11_QTMULT
				FROM %Table:D0E% D0E
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = D0E.D0E_PRDORI
				AND D11.D11_PRDCMP = D0E.D0E_PRODUT
				AND D11.%NotDel%
				WHERE D0E.D0E_FILIAL = %xFilial:D0E%
				AND D0E.D0E_PRDORI = %Exp:oDisSepItem:oDisPrdLot:GetProduto()% // Produto Origem
				AND D0E.D0E_CODDIS = %Exp:oDisSepItem:oDisSep:GetCodDis()%
				AND D0E.D0E_CARGA  = %Exp:oDisSepItem:oDisSep:GetCarga()%
				AND D0E.D0E_PEDIDO = %Exp:oDisSepItem:oDisSep:GetPedido()%
				AND D0E.D0E_LOCORI = %Exp:oDisSepItem:oDisEndOri:GetArmazem()%
				AND D0E.D0E_PRODUT <> D0E.D0E_PRDORI // Pai é diferente do filho
				AND D0E.%NotDel%
				%Exp:cWhere%
			EndSql
		Else
			BeginSql Alias cAliasD0E
				SELECT D0E.R_E_C_N_O_ RECNOD0E,
						D0E.D0E_PRODUT,
						D0E_PRDORI,
						(D0E.D0E_QTDSEP - D0E.D0E_QTDDIS) D0E_QTDDIS,
						D11.D11_QTMULT
				FROM %Table:D0E% D0E
				INNER JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = D0E.D0E_PRDORI
				AND D11.D11_PRDCMP = D0E.D0E_PRODUT
				AND D11.%NotDel%
				WHERE D0E.D0E_FILIAL = %xFilial:D0E%
				AND D0E.D0E_PRDORI = %Exp:oDisSepItem:oDisPrdLot:GetProduto()% // Produto Origem
				AND D0E.D0E_CODDIS = %Exp:oDisSepItem:oDisSep:GetCodDis()%
				AND D0E.D0E_CARGA  = %Exp:oDisSepItem:oDisSep:GetCarga()%
				AND D0E.D0E_PEDIDO = %Exp:oDisSepItem:oDisSep:GetPedido()%
				AND D0E.D0E_LOCORI = %Exp:oDisSepItem:oDisEndOri:GetArmazem()%
				AND D0E.D0E_ENDORI = %Exp:oDisSepItem:oDisEndOri:GetEnder()%
				AND D0E.D0E_STATUS = '1' // Pendente
				AND D0E.D0E_PRODUT <> D0E.D0E_PRDORI // Pai é diferente do filho
				AND D0E.%NotDel%
				%Exp:cWhere%
			EndSql
		EndIf
		TcSetField(cAliasD0E,'D0E_QTDDIS','N',aTamD0E[1],aTamD0E[2])
		TcSetField(cAliasD0E,'D11_QTMULT','N',aTamD11[1],aTamD11[2])
		If (cAliasD0E)->(!Eof())
			cPrdOri := (cAliasD0E)->D0E_PRDORI //oDisSepItem:oDisPrdLot:GetPrdOri()
			// Deve calcular com base no primeiro filho, quanto deve distribuir para este processo
			nQtMult := IIf((cPrdOri == oDisSepItem:oDisPrdLot:GetProduto()),1,(cAliasD0E)->D11_QTMULT)
			nQtDist := nQtDist/nQtMult
			nQtDisPrd := Min(nQtDist,(cAliasD0E)->D0E_QTDDIS/(cAliasD0E)->D11_QTMULT)
			//BUSCA TODOS OS FILHOS PARA A PROXIMA QUANTIDADE
			nQtDist1 := nQtDist
			nProdut := (cAliasD0E)->D0E_PRODUT
			Do While lRet .And. ((cAliasD0E)->(!Eof()))
				If nProdut != (cAliasD0E)->D0E_PRODUT 
					nQtDist := nQtDist1
				EndIf
				nProdut := (cAliasD0E)->D0E_PRODUT
				nQtDisPrd := Min(nQtDist,(cAliasD0E)->D0E_QTDDIS/(cAliasD0E)->D11_QTMULT)
				// Se para algum filho não pode distribuir a mesma quantidade, gera erro
				// Pode ser que o filho tenha sido distribuído de forma separada
				// Nesta situação deverá bipar cada filho de forma separada
				If QtdComp(nQtDisPrd) > QtdComp((cAliasD0E)->D0E_QTDDIS/(cAliasD0E)->D11_QTMULT)
					If lEstorno
						cMensagem := WmsFmtMsg(STR0038,{{"[VAR01]",(cAliasD0E)->D0E_PRODUT}}) // Quantidade distribuida do componente [VAR01] menor que a quantidade informada. Estorne cada componente separadamente.
					Else
						cMensagem := WmsFmtMsg(STR0039,{{"[VAR01]",(cAliasD0E)->D0E_PRODUT}}) // Quantidade a distribuir do componente [VAR01] menor que a quantidade informada. Distribua cada componente separadamente.
					EndIf
					lRet := .F.
				Else
					If (lRet := oDisSepItem:GoToD0E((cAliasD0E)->RECNOD0E))
						If lEstorno
							oDisSepItem:SetQtdDis(oDisSepItem:GetQtdDis()-(nQtDisPrd*(cAliasD0E)->D11_QTMULT))
						Else
							oDisSepItem:SetQtdDis(oDisSepItem:GetQtdDis()+(nQtDisPrd*(cAliasD0E)->D11_QTMULT))
						EndIf
						If (lRet := oDisSepItem:UpdateD0E())
							// Atualizando a capa da distribuição
							oDisSepItem:CalcDisSep(2)
							oDisSepItem:oDisSep:SetQtdDis(oDisSepItem:GetTotDis())
							// Se zerar a quantidade distribuída, limpa o endereço
							If lEstorno .And. !oDisSepItem:HasQtdDis()
								oDisSepItem:oDisSep:oDisEndDes:SetEnder("")
							Else  //Seta armazém e endereço 
								oDisSepItem:oDisSep:oDisEndDes:SetArmazem(cArmazem)
								oDisSepItem:oDisSep:oDisEndDes:SetEnder(cEndereco)
							EndIf
							lRet := oDisSepItem:oDisSep:UpdateD0D()
							If !lRet
								oDisSepItem:cErro := oDisSepItem:oDisSep:GetErro()
							EndIf
						EndIf
					EndIf
				EndIf
				nQtDist -= nQtDisPrd
				(cAliasD0E)->(DbSkip())
			EndDo
			oDisSepItem:oDisPrdLot:SetProduto(cPrdOri)
			oDisSepItem:oDisPrdLot:LoadData()
		Else
			// Deve verificar se o produto informado é um produto filho
			// Parâmetro Where
			cWhere := "%"
			// Valida se controla lote
			If oDisSepItem:oDisPrdLot:HasRastro() .And. !Empty(oDisSepItem:oDisPrdLot:GetLoteCtl())
				cWhere += " AND D0E.D0E_LOTECT = '"+oDisSepItem:oDisPrdLot:GetLoteCtl()+"'"
				// Valida se controla sublote
				If oDisSepItem:oDisPrdLot:HasRastSub() .And. !Empty(oDisSepItem:oDisPrdLot:GetNumLote())
					cWhere += " AND D0E.D0E_NUMLOT = '"+oDisSepItem:oDisPrdLot:GetNumLote()+"'"
				EndIf
			EndIf
			cWhere += "%"
			cAliasQry := GetNextAlias()
			If lEstorno
				BeginSql Alias cAliasQry
					SELECT D0E.R_E_C_N_O_ RECNOD0E,
							D0E.D0E_QTDDIS
					FROM %Table:D0E% D0E
					WHERE D0E.D0E_FILIAL = %xFilial:D0E%
					AND D0E.D0E_PRDORI = %Exp:oDisSepItem:oDisPrdLot:GetPrdOri()%
					AND D0E.D0E_PRODUT = %Exp:oDisSepItem:oDisPrdLot:GetProduto()% // Produto Componente
					AND D0E.D0E_CODDIS = %Exp:oDisSepItem:oDisSep:GetCodDis()%
					AND D0E.D0E_CARGA = %Exp:oDisSepItem:oDisSep:GetCarga()%
					AND D0E.D0E_PEDIDO = %Exp:oDisSepItem:oDisSep:GetPedido()%
					AND D0E.D0E_LOCORI = %Exp:oDisSepItem:oDisEndOri:GetArmazem()%
					AND D0E.%NotDel%
					%Exp:cWhere%
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT D0E.R_E_C_N_O_ RECNOD0E,
							(D0E.D0E_QTDSEP-D0E.D0E_QTDDIS) D0E_QTDDIS
					FROM %Table:D0E% D0E
					WHERE D0E.D0E_FILIAL = %xFilial:D0E%
					AND D0E.D0E_PRDORI = %Exp:oDisSepItem:oDisPrdLot:GetPrdOri()%
					AND D0E.D0E_PRODUT = %Exp:oDisSepItem:oDisPrdLot:GetProduto()% // Produto Componente
					AND D0E.D0E_CODDIS = %Exp:oDisSepItem:oDisSep:GetCodDis()%
					AND D0E.D0E_CARGA = %Exp:oDisSepItem:oDisSep:GetCarga()%
					AND D0E.D0E_PEDIDO = %Exp:oDisSepItem:oDisSep:GetPedido()%
					AND D0E.D0E_LOCORI = %Exp:oDisSepItem:oDisEndOri:GetArmazem()%
					AND D0E.D0E_ENDORI = %Exp:oDisSepItem:oDisEndOri:GetEnder()%
					AND D0E.D0E_STATUS = '1' // Pendente
					AND D0E.%NotDel%
					%Exp:cWhere%
				EndSql
			EndIf
			TcSetField(cAliasQry,'D0E_QTDDIS','N',aTamD0E[1],aTamD0E[2])
			Do While lRet .And. ((cAliasQry)->(!Eof()) .And. QtdComp(nQtDist) > 0)
				nQtDisPrd := Min(nQtDist,(cAliasQry)->D0E_QTDDIS)
				If (lRet := oDisSepItem:GoToD0E((cAliasQry)->RECNOD0E))
					If lEstorno
						oDisSepItem:SetQtdDis(oDisSepItem:GetQtdDis()-nQtDisPrd)
					Else
						oDisSepItem:SetQtdDis(oDisSepItem:GetQtdDis()+nQtDisPrd)
					EndIf
					If (lRet := oDisSepItem:UpdateD0E())
						// Atualizando a capa da distribuição
						oDisSepItem:CalcDisSep(2)
						oDisSepItem:oDisSep:SetQtdDis(oDisSepItem:GetTotDis())
						// Se zerar a quantidade distribuída, limpa o endereço
						If lEstorno .And. !oDisSepItem:HasQtdDis()
							oDisSepItem:oDisSep:oDisEndDes:SetArmazem(cArmazem)
							oDisSepItem:oDisSep:oDisEndDes:SetEnder("")
						Else  //Seta armazém e endereço 
							oDisSepItem:oDisSep:oDisEndDes:SetArmazem(cArmazem)
							oDisSepItem:oDisSep:oDisEndDes:SetEnder(cEndereco)
						EndIf
						lRet := oDisSepItem:oDisSep:UpdateD0D()
						If !lRet
							oDisSepItem:cErro := oDisSepItem:oDisSep:GetErro()
						EndIf
					EndIf
				EndIf
				nQtDist -= nQtDisPrd
				(cAliasQry)->(DbSkip())
			Enddo
			(cAliasQry)->(DbCloseArea())
		EndIf
		(cAliasD0E)->(DbCloseArea())
		If !lRet
			DisarmTransaction()
			If Empty(cMensagem)
				cMensagem := oDisSepItem:GetErro()
			EndIf
			WMSVTAviso(WMSV04027,cMensagem)
		Else
			If !lEstorno
				//Verifica se a distribuição está finalizada
				BeginSql Alias cAliasD0E
					SELECT 1
					FROM %Table:D0E% D0E
					WHERE D0E.D0E_FILIAL = %xFilial:D0E%
					AND D0E.D0E_CODDIS = %Exp:oDisSepItem:oDisSep:GetCodDis()%
					AND D0E.D0E_CARGA = %Exp:oDisSepItem:oDisSep:GetCarga()%
					AND D0E.D0E_PEDIDO = %Exp:oDisSepItem:oDisSep:GetPedido()%
					AND D0E.D0E_LOCORI = %Exp:oDisSepItem:oDisEndOri:GetArmazem()%
					AND D0E.D0E_STATUS = '1'
					AND D0E.%NotDel%
				EndSql
				If (cAliasD0E)->(Eof())
					lFinaliz := .T.
				EndIf
				(cAliasD0E)->(DbCloseArea())
			EndIf
		EndIf
	End Transaction
	If lFinaliz
		WMSVTAviso(WMSV04028,WmsFmtMsg(STR0042,{{"[VAR01]",oDisSepItem:oDisSep:GetPedido()},{"[VAR02]",oDisSepItem:oDisEndOri:GetArmazem()}})) // Distribuição do pedido [VAR01] do armazém [VAR02] finalizada!
	EndIf	
	RestArea(aAreaAnt)
Return lRet

Static Function WMSV040Esc(cMensagem)
Local lRet := .T.
	lRet := (WMSVTAviso(WMSV04001,cMensagem,{STR0006,STR0007})==1) // Sim // Não
Return lRet

Static Function VldCarga(cCarga)
Local aAreaAnt := GetArea()
Local lRet := .T.
	dbSelectArea("DAK")
	DAK->(dbSetOrder(1))
	If !DAK->(dbSeek(xFilial("DAK")+cCarga))
		WMSVTAviso(WMSV04031,WmsFmtMsg(STR0045,{{"[VAR01]",cCarga}})) // "Codigo da carga [VAR01] não existe!"
		lRet := .F.
	EndIf
	
	RestArea(aAreaAnt)
Return lRet

Static Function VldPedido(cPedido)
Local aAreaAnt := GetArea()
Local lRet := .T.
	
	dbSelectArea("SC9")
	SC9->(dbSetOrder(1))
	If !SC9->(dbSeek(xFilial("SC9")+cPedido))
		WMSVTAviso(WMSV04032,WmsFmtMsg(STR0046,{{"[VAR01]",cPedido}})) // "Codigo do pedido [VAR01] não existe!"
		lRet := .F.
	EndIf	
	
	RestArea(aAreaAnt)
Return lRet