#INCLUDE 'WMSV076.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'

#DEFINE CRLF CHR(13)+CHR(10)
#DEFINE WMSV07601 "WMSV07601"
#DEFINE WMSV07602 "WMSV07602"
#DEFINE WMSV07603 "WMSV07603"
#DEFINE WMSV07604 "WMSV07604"
#DEFINE WMSV07605 "WMSV07605"
#DEFINE WMSV07606 "WMSV07606"
#DEFINE WMSV07607 "WMSV07607"
#DEFINE WMSV07608 "WMSV07608"
#DEFINE WMSV07609 "WMSV07609"
#DEFINE WMSV07610 "WMSV07610"
#DEFINE WMSV07611 "WMSV07611"
#DEFINE WMSV07612 "WMSV07612"
#DEFINE WMSV07613 "WMSV07613"
#DEFINE WMSV07614 "WMSV07614"
#DEFINE WMSV07615 "WMSV07615"
#DEFINE WMSV07616 "WMSV07616"
#DEFINE WMSV07617 "WMSV07617"
#DEFINE WMSV07618 "WMSV07618"
#DEFINE WMSV07619 "WMSV07619"
#DEFINE WMSV07620 "WMSV07620"
#DEFINE WMSV07621 "WMSV07621"
#DEFINE WMSV07622 "WMSV07622"
#DEFINE WMSV07623 "WMSV07623"
#DEFINE WMSV07624 "WMSV07624"
#DEFINE WMSV07625 "WMSV07625"
#DEFINE WMSV07626 "WMSV07626"
#DEFINE WMSV07627 "WMSV07627"
#DEFINE WMSV07628 "WMSV07628"
#DEFINE WMSV07629 "WMSV07629"
#DEFINE WMSV07630 "WMSV07630"
#DEFINE WMSV07631 "WMSV07631"
#DEFINE WMSV07632 "WMSV07632"
#DEFINE WMSV07633 "WMSV07633"
#DEFINE WMSV07634 "WMSV07634"
#DEFINE WMSV07635 "WMSV07635"
#DEFINE WMSV07636 "WMSV07636"

//------------------------------------------------------------
/*/{Protheus.doc} WMSV076
Conferencia de mercadorias
@author Jackson Patrick Werka
@since 01/04/2015
@version 1.0
/*/
//------------------------------------------------------------
Static cServico   := ""
Static cOrdTar    := ""
Static cTarefa    := ""
Static cAtividade := ""
Static cArmazem   := ""
Static cEndereco  := ""
Static cPedido    := ""
Static cCarga     := ""
Static dDataIni   := CTOD("")
Static cHoraIni   := ""
Static lWV076LOT  := ExistBlock("WV076LOT")
Static lWMS076VL  := ExistBlock("WMS076VL")
Static lWV075REG  := ExistBlock("WV075REG")
Static lWmsDaEn   := SuperGetMV("MV_WMSDAEN",.F.,.F.) // Conferência apenas considerando o endereço sem o armazém

Function WMSV076()
Local aAreaAnt := GetArea()
Local lRet        := .T.
// Salva todas as teclas de atalho anteriores
Local aSavKey     := VTKeys()
Local lCarga      := .F.
Local lAbandona   := .F.

	cServico   := oMovimento:oMovServic:GetServico()
	cOrdTar    := oMovimento:oMovServic:GetOrdem()
	cTarefa    := oMovimento:oMovTarefa:GetTarefa()
	cAtividade := oMovimento:oMovTarefa:GetAtivid()
	cArmazem   := oMovimento:oMovEndOri:GetArmazem()
	cEndereco  := Space(TamSx3("D12_ENDORI")[1])
	dDataIni   := oMovimento:GetDataIni()
	cHoraIni   := oMovimento:GetHoraIni()

	Do While lRet .And. !lAbandona
		// Indica ao operador o endereco de origem da conferencia
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
		WMSEnder(0,0,oMovimento:oMovEndOri:GetEnder(),oMovimento:oMovEndOri:GetArmazem(),,,STR0003) // Va para o Endereco
		If (VTLastKey()==27)
			WMSV076ESC(@lAbandona)
			Loop
		EndIf
		Exit
	EndDo

	Do While lRet .And. !lAbandona
		WMSVTCabec(STR0001,.F.,.F.,.T.)
		If oMovimento:lUsuArm .Or. !lWmsDaEn
			@ 01, 00 VTSay Padr(STR0056+cArmazem,VTMaxCol()) //Armazem: 
		EndIf
		@ 02, 00 VTSay PadR(STR0004,VTMaxCol()) // Endereco
		@ 03, 00 VTSay PadR(oMovimento:oMovEndOri:GetEnder(),VTMaxCol())
		@ 05, 00 VTSay PadR(STR0005, VTMaxCol()) // Confirme!
		@ 06, 00 VTGet cEndereco Pict '@!' Valid ValidEnder(@cEndereco)
		VTRead()
		If (VTLastKey()==27)
			WMSV076ESC(@lAbandona)
			Loop
		EndIf
		Exit
	EndDo

	Do While lRet .And. !lAbandona
		// Confirmar Documento / Carga
		lCarga  := WmsCarga(oMovimento:oOrdServ:GetCarga())
		cCarga  := Space(TamSX3("D12_CARGA")[1])
		cPedido := Space(TamSX3("D12_DOC")[1])
		If lCarga
			WMSVTCabec(STR0001,.F.,.F.,.T.)
			@ 01, 00 VTSay PadR(STR0006,VTMaxCol()) // Carga
			@ 02, 00 VTSay PadR(oMovimento:oOrdServ:GetCarga(),VTMaxCol())
			@ 04, 00 VTSay PadR(STR0005, VTMaxCol()) // Confirme!
			@ 05, 00 VTGet cCarga Picture '@!' Valid ValidCarga()
		Else
			WMSVTCabec(STR0001,.F.,.F.,.T.)
			@ 01, 00 VTSay PadR(STR0007,VTMaxCol()) // Pedido
			@ 02, 00 VTSay PadR(oMovimento:oOrdServ:GetDocto(),VTMaxCol())
			@ 04, 00 VTSay PadR(STR0005, VTMaxCol()) // Confirme!
			@ 05, 00 VTGet cPedido Picture '@!' Valid ValidPedido()
		EndIf
		VTRead()
		If (VTLastKey()==27)
			WMSV076ESC(@lAbandona)
			Loop
		EndIf
		// Efetua as validações para a carga/pedido informado
		If !ValidDocto(lCarga)
			Loop
		EndIf
		Exit
	EndDo

	If lRet .And. !lAbandona
		lRet := CofPrdLot()
		WMSAltSts(.F.) // Não altera a situação da atividade no WMSV0001
	EndIf

	VTClear()
	VTKeyBoard(chr(13))
	VTInkey(0)
	// Restaura as teclas de atalho anteriores
	VTKeys(aSavKey)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---CofPrdLot
---Permite ir executando a conferência dos produtos, informando os dados
---de lote, sub-lote e quantidade a ser conferida
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function CofPrdLot()
Local aTelaAnt  := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local oEndereco := WMSDTCEndereco():New()
// Solicita a confirmacao do lote nas operacoes com radio frequencia
Local lWmsLote  := SuperGetMV('MV_WMSLOTE',.F.,.T.)
Local lWMSConf  := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local lAbandona := .F.
Local lQtdBar   := .F.
Local lCarga    := WmsCarga(cCarga)
Local cLoteCtl  := Space(TamSx3("D12_LOTECT")[1])
Local cNumLote  := Space(TamSx3("D12_NUMLOT")[1])
Local cWmsUMI   := ""
Local cCodBar   := ""
Local cProduto  := ""
Local cPrdAnt   := ""
Local nQtConf   := 0
Local cPictQt   := ""
Local cUM       := ""
Local cDscUM    := ""
Local nItem     := 0
Local lEncerra  := .F.
Local nAviso    := 0
Local nQtdNorma := 0
Local nQtde1UM  := 0
Local nQtde2UM  := 0
Local nLin      := 0

	// Permite indicar se a deve solicitar o lote dos produtos no processo de conferência
	If lWV076LOT
		xRetPE   := ExecBlock("WV076LOT",.F.,.F.)
		lWmsLote := Iif(ValType(xRetPE)=="L",xRetPE,lWmsLote)
	EndIf

	// Atribui a funcao de JA CONFERIDOS a combinacao de teclas <CTRL> + <Q>
	VTSetKey(17,{||ShowPrdCof(lWmsLote)},STR0041) // Ja Conferidos

	Do While !lEncerra .And. !lAbandona

		cProduto := Space(TamSx3("D12_PRODUT")[1])
		cCodBar  := Space(128)
		nQtdConf := 0
		// 01234567890123456789
		// 0 ____Conferência_____
		// 1 Pedido: 000000       // Carga: 000000
		// 2 Informe o Produto
		// 3 PA1
		// 4 Informe o Lote
		// 5 AUTO000636
		// 6 Qtde 999.00 UM
		// 7               240.00
		WMSVTCabec(STR0001,.F.,.F.,.T.) // Conferência
		If lCarga
			@ 01,00  VtSay STR0006 + ': ' + cCarga // Carga
		Else
			@ 01,00  VtSay STR0007 + ': ' + cPedido  // Pedido
		EndIf
		@ 02,00  VTSay STR0008 // Informe o Produto
		@ 03,00  VtGet cCodBar Picture "@!" Valid ValidPrdLot(@cProduto,@cLoteCtl,@cNumLote,@nQtConf,@cCodBar,lCarga)
		// Descricao do Produto com tamanho especifico.
		VtRead()
		If VTLastKey()==27
			nAviso := WMSVTAviso(STR0001,STR0014,{STR0015,STR0016}) // Deseja encerrar a conferencia? // Encerrar // Interromper
			If nAviso == 1
				lEncerra := .T.
			ElseIf nAviso == 2
				lAbandona  := .T.
			Else
				Loop
			EndIf
		EndIf
		// Indica que quantidade já atribuída
		lQtdBar := (nQtConf > 0)
		If lQtdBar
			cPrdAnt := Space(TamSx3("D12_PRODUT")[1]) 
		EndIf
		If !lEncerra .And. !lAbandona
			// Forca selecionar unidade de medida se informou produto diferente ou a cada leitura do codigo do produto
			If ((cProduto <> cPrdAnt) .Or. lWMSConf)
				// Carrega unidade de medida, simbolo da unidade e quantidade na unidade
				WmsValUM(Nil,;      // Quantidade movimento
						@cWmsUMI,;  // Unidade parametrizada
						cProduto,;  // Produto
						cArmazem,;  // Armazem
						cEndereco,; // Endereço
						@nItem,;    // Item unidade medida
						.T.,;       // Indica se é uma conferência
						lQtdBar)    // Indica se quantidade já preenchida
				// Monta tela produto
				WmsMontPrd(cWmsUMI,;                // Unidade parametrizada
						.T.,;                       // Indica se é uma conferência
						Tabela("L2",cTarefa,.F.),;  // Descrição da tarefa
						cArmazem,;                  // Armazem
						cEndereco,;                 // Endereço
						cProduto,;                  // Produto Origem
						cProduto,;                  // Produto
						cLoteCtl,;                  // Lote
						cNumLote,;                  // sub-lote
						Nil,;                       // Id Unitizador
						nQtConf)                    // Quantidade preenchida
				If (VTLastKey()==27)
					Loop
				EndIf
				If (QtdComp(nQtConf) <= QtdComp(0))
					// Seleciona unidade de medida
					WmsSelUM(cWmsUMI,;                 // Unidade parametrizada
							@cUM,;                     // Unidade medida reduzida
							@cDscUM,;                  // Descrição unidade medida
							Nil,;                      // Quantidade movimento
							@nItem,;                   // Item seleção unidade
							@cPictQt,;                 // Mascara unidade medida
							Nil,;                      // Quantidade no item seleção unidade
							.T.,;                      // Indica se é uma conferência
							Tabela("L2",cTarefa,.F.),; // Descrição da tarefa
							cArmazem,;                 // Armazem
							cEndereco,;                // Endereço
							cProduto,;                 // Produto Origem
							cProduto,;                 // Produto
							cLoteCtl,;                 // Lote
							cNumLote,;                 // sub-lote
							lQtdBar)                   // Indica se quantidade já preenchida
					If (VTLastKey()==27)
						Loop
					EndIf
				EndIf
			EndIf
			cPrdAnt := cProduto
		EndIf
		nLin := 4
		If !lEncerra .And. !lAbandona .And. lWmsLote
			If Empty(cLoteCtl)
				// Se tiver espaço na tela suficiente ele mostra o sub-lote na mesma tela
				If Rastro(cProduto)
					@ nLin,00  VtSay STR0054 // Lote:
					@ nLin++,06  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValLoteCtl(cProduto,cLoteCtl)
				EndIf
				If Rastro(cProduto,"S")
					@ nLin,00 VTSay STR0055 // Sub-Lote:
					@ nLin++,10 VTGet cNumLote Picture "@!" When VTLastKey()==05 .Or. Empty(cNumLote) Valid ValSubLote(cProduto,cLoteCtl,cNumLote)
				EndIf
				VtRead()

				If VTLastKey()==27
					Loop // Volta para o inicio do produto
				EndIf
			EndIf
			// Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
			If !(Iif(Empty(cLoteCtl),.T.,ValLoteCtl(cProduto,cLoteCtl))) .Or. ;
				!(Iif(Empty(cNumLote),.T.,ValSubLote(cProduto,cLoteCtl,cNumLote)))
				Loop // Volta para o inicio do produto
			EndIf
			//Altera status da movimentação
			UpdStatus(lCarga,cProduto,cLoteCtl,cNumLote)
		EndIf

		If !lEncerra .And. !lAbandona
			//Carrega informações do endereço da conferência
			oEndereco:SetArmazem(cArmazem)
			oEndereco:SetEnder(cEndereco)
			oEndereco:LoadData()
			nQtdNorma := DLQtdNorma(cProduto,cArmazem,oEndereco:GetEstFis(),,.F.)
			// Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
			Do While .T.
				@ nLin++,00 VTSay PadR(STR0013+' '+cDscUM,VTMaxCol())
				@ nLin++,00 VTGet nQtConf Picture cPictQt When Empty(nQtConf) Valid !Empty(nQtConf)
				VTRead()
				If VTLastKey()==27
					Exit // Volta para o inicio do produto
				EndIf
				If !ValidQtd(cProduto,cLoteCtl,cNumLote,nQtConf,nItem,nQtdNorma,@nQtde1UM,@nQtde2UM)
					nQtConf := 0
					If !lQtdBar
						nLin -= 2
						Loop
					EndIf
				EndIf
				Exit
			EndDo
			If VTLastKey()==27
				Loop
			EndIf
		EndIf

		// Somente grava a quantidade se o usuário não cancelar
		If !lEncerra .And. !lAbandona .And. QtdComp(nQtConf) > 0
			VTMsg(STR0053) // Processando...
			GravCofOpe(cProduto,cLoteCtl,cNumLote,nQtde1UM)
			// Permite executar tratamentos adicionais a partir do registro de produtos conferidos
			If lWV075REG
				ExecBlock("WV075REG",.F.,.F.,{cCarga,cPedido,cProduto,cLoteCtl,cNumLote,cArmazem,cEndereco,cServico,cOrdTar,cTarefa,cAtividade})
			EndIf
		EndIf
		// Se o usuário optou por encerrar, deve verificar se pode ser finalizado a conferência
		If lEncerra .Or. lAbandona
			// Se o usuário optou por interromper, deve verificar se pode sair da conferência
			// Caso não haja mais nada para ser executado, não será possível efetuar
			// a liberação da expedição para o faturamento
			If lAbandona
				lAbandona := SaiCofExp()
				lEncerra := !lAbandona
			EndIf
			If lEncerra
				lEncerra:= FinCofExp()
			EndIf
		EndIf
	EndDo
	// Restaura tela anterior
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return
/*--------------------------------------------------------------------------------
---ShowPrdCof
---Exibe os produtos e quantidade conferida para cada um deles
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ShowPrdCof(lWmsLote)
Local aAreaAnt   := GetArea()
Local aProduto   := {}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local aHeaders   := {}
Local aSizes     := {}
Local cWhere     := ""
Local cAliasQry  := GetNextAlias()

	cWhere := "%"
	If WmsCarga(cCarga)
		cWhere += " AND D12.D12_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND D12.D12_DOC   = '"+cPedido+"'"
		EndIf
	If oMovimento:lUsuArm .Or. !lWmsDaEn 
		cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT D12.D12_PRODUT,
			   D12.D12_LOTECT, 
			   D12.D12_NUMLOT, 
			   SUM(D12.D12_QTDMOV) D12_QTDMOV, 
			   SUM(D12.D12_QTDLID) D12_QTDLID
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar%
		AND D12.D12_STATUS IN ('3','4','1')
		AND D12.D12_RECHUM = %Exp:__cUserID%
		AND D12.D12_ENDDES = %Exp:cEndereco%
		AND D12.%NotDel%
		%Exp:cWhere%
		GROUP BY D12.D12_PRODUT,
					D12.D12_LOTECT,
					D12.D12_NUMLOT
		ORDER BY D12.D12_PRODUT,
					D12.D12_LOTECT,
					D12.D12_NUMLOT
	EndSql
	TCSetField(cAliasQry,'D12_QTDMOV' ,'N',TamSx3('D12_QTDMOV')[1], TamSx3('D12_QTDMOV')[2])
	TCSetField(cAliasQry,'D12_QTDLID','N',TamSx3('D12_QTDLID')[1],TamSx3('D12_QTDLID')[2])
	Do While (cAliasQry)->(!Eof())
		If lWmsLote
			AAdd(aProduto,{Iif((cAliasQry)->D12_QTDMOV <> (cAliasQry)->D12_QTDLID,'*',' '),(cAliasQry)->D12_PRODUT,Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->D12_PRODUT,'SB1->B1_DESC'),(cAliasQry)->D12_LOTECTL,(cAliasQry)->D12_NUMLOT,(cAliasQry)->D12_QTDLID})
		Else
			AAdd(aProduto,{Iif((cAliasQry)->D12_QTDMOV <> (cAliasQry)->D12_QTDLID,'*',' '),(cAliasQry)->D12_PRODUT,Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->D12_PRODUT,'SB1->B1_DESC'),(cAliasQry)->D12_QTDLID})
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)

	If lWmsLote
		aHeaders := {' ',RetTitle("D12_PRODUT"),RetTitle("B1_DESC"),RetTitle("D12_LOTECT"),RetTitle("D12_NUMLOT"),STR0040} //Produto|Descrição|Lote|Sub-Lote|Qtde Conferida
		aSizes   := {1,TamSx3("D12_PRODUT")[1],30,TamSx3("D12_LOTECT")[1],TamSx3("D12_NUMLOT")[1],11}
	Else
		aHeaders := {' ',RetTitle("D12_PRODUT"),RetTitle("B1_DESC"),STR0040} // Produto|Descrição|Qtde Conferida
		aSizes   := {1,TamSx3("D12_PRODUT")[1],30,11}
	EndIf
	VtClearBuffer()
	WMSVTCabec(STR0001,.F.,.F.,.T.) // Produto
	VTaBrowse(1,,,,aHeaders,aProduto,aSizes)
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil
/*--------------------------------------------------------------------------------
---ValidCarga
---Valida a informação do campo Pedido
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ValidCarga()
Local aAreaAnt := GetArea()
Local lRet
	// Se não informou a carga retorna
	If Empty(cCarga)
		Return .F.
	EndIf
	// Se a carga informada é a mesma convocada
	If cCarga == oMovimento:oOrdServ:GetCarga()
		Return .T.
	EndIf
	// Se a carga é diferente, deve validar se existe esta carga
	cCarga := PadR(cCarga,TamSX3("DAK_COD")[1])
	DAK->(DbSetOrder(1)) // DAK_FILIAL+DAK_COD
	If DAK->(!DbSeek(xFilial("DAK")+cCarga))
		WMSVTAviso(WMSV07604,STR0019) // Carga inválida!
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidPedido
---Valida a informação do campo Pedido
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function ValidPedido()
Local aAreaAnt := GetArea()
Local lRet
	// Se não informou a Pedido retorna
	If Empty(cPedido)
		Return .F.
	EndIf
	// Se a Pedido informada é a mesma convocada
	If cPedido == oMovimento:oOrdServ:GetDocto()
		Return .T.
	EndIf
	// Se o pedido é diferente, deve validar se existe este pedido
	cPedido := PadR(cPedido,TamSX3("C5_NUM")[1])
	SC5->(DbSetOrder(1)) // C5_FILIAL+C5_NUM
	If SC5->(!DbSeek(xFilial("SC5")+cPedido))
		WMSVTAviso(WMSV07605,STR0020) // Pedido inválido!
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidDocto
---Valida a informação da carga/pedido informado, trocando operador se for o caso
---Jackson Patrick Werka - 01/04/2015
---lCarga, Logico, (Indica se controla carga)
----------------------------------------------------------------------------------*/
Static Function ValidDocto(lCarga)
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local lTrocouDoc := .F.
Local lRet       := .T.
Local nRecnoD12  := 0
	// Se o operador informou outro documento tira a reserva feita pelo WMSV001
	If ( lCarga .And. !Empty(cCarga) .And. cCarga <> oMovimento:oOrdServ:GetCarga()) .Or. ;
		(!lCarga .And. !Empty(cPedido) .And. cPedido <> oMovimento:oOrdServ:GetDocto())
		If !WmsQuestion(STR0021,WMSV07606) // Deseja alterar pedido/carga?
			lRet := .F.
		Else
			lTrocouDoc := .T.
		EndIf
	EndIf
	// Se trocou a carga ou o pedido, deve validar a nova informação
	If lRet
		If lTrocouDoc
			If !HasTarDoc(lCarga,@nRecnoD12)
				If lCarga
					WMSVTAviso(WMSV07607,WmsFmtMsg(STR0022,{{"[VAR01]",cArmazem}})) //Não existem atividades de conferência para a carga informada no armazém [VAR01].
				Else
					WMSVTAviso(WMSV07608,WmsFmtMsg(STR0023,{{"[VAR01]",cArmazem}})) //Não existem atividades de conferência para o pedido informa no armazém [VAR01].
				EndIf
				Return .F.
			EndIf
			If !TrdocUsuCF(nRecnoD12)
				WMSVTAviso(WMSV07636,STR0058) // Usuário não possui permissão para convocação da atividade.
				Return .F.
			EndIf 
		EndIf
		////  algum item do mesmo documento foi convocado p/ outro operador.
		If TarExeOper(cCarga,cPedido,lCarga)
			WMSVTAviso(WMSV07609,STR0024) // Atividades da tarefa em andamento por outro operador.
			Return .F.
		EndIf

		If lTrocouDoc
			oMovimento:SetRecHum(Iif(lLiberaRH,cRecHVazio,oMovimento:GetRecHum()))
			If QtdComp(oMovimento:GetQtdLid()) > QtdComp(0)
				oMovimento:SetStatus("3") // Atividade Em Andamento
			Else
				oMovimento:SetStatus("4") // Atividade A Executar
				oMovimento:SetDataIni(CtoD(""))
				oMovimento:SetHoraIni("")
			EndIf
			oMovimento:SetDataFim(CtoD(""))
			oMovimento:SetHoraFim("")
			oMovimento:UpdateD12()

			If lLiberaRH
				// Retira recurso humano atribuido as atividades de outros itens do mesmo pedido / carga.
				CancRHServ()
			EndIf
			oMovimento:GotoD12(nRecnoD12)
			// Seta D12_STATUS para Servico em Execucao
			If WMSAltSts()
				If oMovimento:GetStatus() != "3"
					oMovimento:SetRecHum(__cUserID)
					oMovimento:SetStatus("3")
					oMovimento:SetDataIni(dDataBase)
					oMovimento:SetHoraIni(Time())
					oMovimento:SetDataFim(CTOD(""))
					oMovimento:SetHoraFim("")
					oMovimento:UpdateD12()
				EndIf
			EndIf
			//Atribui variáveis novamente
			cServico   := oMovimento:oMovServic:GetServico()
			cOrdTar    := oMovimento:oMovServic:GetOrdem()
			cTarefa    := oMovimento:oMovTarefa:GetTarefa()
			cAtividade := oMovimento:oMovTarefa:GetAtivid()
			cArmazem   := oMovimento:oMovEndOri:GetArmazem()
			dDataIni   := oMovimento:GetDataIni()
			cHoraIni   := oMovimento:GetHoraIni()
			If !lCarga .And. WmsCarga(oMovimento:oOrdServ:GetCarga())
				Return .F.
			EndIf
			If lCarga
				WMSVTAviso(STR0001,PadC(STR0025,VTMaxCol())+STR0026) // Atenção - Carga alterada. Executar a conferencia da carga informada.
			Else
				WMSVTAviso(STR0001,PadC(STR0025,VTMaxCol())+STR0027) // Atenção - Pedido alterado. Executar a conferencia do pedido informado.
			EndIf
		EndIf
		// Atribui o documento todo para o usuário
		AddRHServ()
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---HasTarDoc
---Verifica se tem atividades para o novo documento informado
---Jackson Patrick Werka - 01/04/2015
---lCarga,    logico,   (Indica se controla carga)
---nRecnoD12, numerico, (Número do recno da movimentação)
---cProduto,  caracter, (Produto)
---cLoteCtl,  caracter, (Lote)
---cNumLote,  caracter, (Sub-Lote)
----------------------------------------------------------------------------------*/
Static Function HasTarDoc(lCarga,nRecnoD12,cProduto,cLoteCtl,cNumLote)
Local lRet       := .F.
Local aAreaAnt   := GetArea()
Local cWhere     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])

Default cProduto := Space(TamSX3('D12_PRODUT')[1])
Default cLoteCtl := Space(TamSX3('D12_LOTECT')[1])
Default cNumLote := Space(TamSX3('D12_NUMLOT')[1])

	cWhere := "%"
	If lCarga
		cWhere += " AND D12.D12_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND D12.D12_DOC   = '"+cPedido+"'"
	EndIf
	If !Empty(cProduto)
		cWhere += " AND D12.D12_PRODUT  = '"+cProduto+"'"
	EndIf
	If !Empty(cLoteCtl)
		cWhere += " AND D12.D12_LOTECT  = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D12.D12_NUMLOT  = '"+cNumLote+"'"
	EndIf
	If oMovimento:lUsuArm
		cWhere += " AND D12.D12_LOCORI  = '"+cArmazem+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT D12.R_E_C_N_O_ RECNOD12
		FROM %Table:D12% D12
		INNER JOIN %Table:DC5% DC5
  		ON DC5.DC5_FILIAL = %xFilial:DC5%
  		AND DC5.DC5_SERVIC = D12.D12_SERVIC 
  		AND DC5.DC5_tarefa = D12.D12_TAREFA
		AND DC5.DC5_OPERAC = '7'
  		AND DC5.%NotDel%
  	    
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_STATUS IN ('3','4')
		AND (D12.D12_RECHUM = %Exp:cRecHVazio%
			OR D12.D12_RECHUM = %Exp:__cUserID% )
		AND D12.D12_ENDORI  = %Exp:cEndereco%
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasQry)->(!Eof())
		nRecnoD12 := (cAliasQry)->RECNOD12
		lRet := .T.
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---TarExeOper
---Analisa se a tarefa está em andamento por outro operador.
---Jackson Patrick Werka - 01/04/2015
---cCarga, character, (Carga)
---cPedido, character, (Pedido)
---lCarga, Logico, (Indica se controla carga)
----------------------------------------------------------------------------------*/
Static Function TarExeOper(cCarga,cPedido,lCarga)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
Local cWhere     := ""

	cWhere := "%"
	If lCarga
		cWhere += " AND D12.D12_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND D12.D12_DOC   = '"+cPedido+"'"
	EndIf
	If oMovimento:lUsuArm .Or. !lWmsDaEn 
		cWhere += " AND D12.D12_LOCORI  = '"+cArmazem+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:D12% D12
		INNER JOIN %Table:DC5% DC5
  		ON DC5.DC5_FILIAL = %xFilial:DC5%
  		AND DC5.DC5_SERVIC = D12.D12_SERVIC 
  		AND DC5.DC5_tarefa = D12.D12_TAREFA
		AND DC5.DC5_OPERAC = '7'
  		AND DC5.%NotDel%
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_RECHUM <> %Exp:cRecHVazio%
		AND D12.D12_RECHUM <> %Exp:__cUserID%
		AND D12.D12_QTDLID <> D12.D12_QTDMOV
		AND D12.D12_ENDORI  = %Exp:cEndereco%
		AND D12.D12_STATUS <> '0'
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---CancRHServ
---Retira recurso humano atribuido as atividades de conferencia
---de outros itens do mesmo pedido / carga.
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function CancRHServ()
Local aAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
Local cWhere     := ""

	cWhere := "%"
	If WmsCarga(oMovimento:oOrdServ:GetCarga())
		cWhere += " AND D12.D12_CARGA = '"+oMovimento:oOrdServ:GetCarga()+"'"
	Else
		cWhere += " AND D12.D12_DOC = '"+oMovimento:oOrdServ:GetDocto()+"'"
	EndIf
	cWhere += "%"

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D12.R_E_C_N_O_ RECNOD12
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:oMovimento:oMovServic:GetServico()%
		AND D12.D12_STATUS = '4' // Atividade A Executar
		AND D12.D12_RECHUM = %Exp:__cUserID%
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	Do While (cAliasQry)->(!Eof())
		D12->(MsGoto((cAliasQry)->RECNOD12))
		RecLock('D12', .F.)  // Trava para gravacao
		D12->D12_DATINI := CTOD("")
		D12->D12_HORINI := ""
		D12->D12_DATFIM := CTOD("")
		D12->D12_HORFIM := ""
		D12->D12_RECHUM := cRecHVazio
		D12->(MsUnlock())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return
/*--------------------------------------------------------------------------------
---AddRHServ
---Atribui o recurso humano para as atividades de conferencia
---Jackson Patrick Werka - 01/04/2015
---lCarga, Logico, (Indica se controla carga)
----------------------------------------------------------------------------------*/
Static Function AddRHServ(lCarga)
Local lRet       := .F.
Local aAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
Local cWhere     := ""

	cWhere := "%"
	If lCarga
		cWhere += " AND D12.D12_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND D12.D12_DOC   = '"+cPedido+"'"
	EndIf
	If oMovimento:lUsuArm .Or. !lWmsDaEn 
		cWhere += " AND D12.D12_LOCDES    = '"+cArmazem+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT D12.R_E_C_N_O_ RECNOD12
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar%
		AND D12.D12_STATUS IN ('2','3','4')
		AND D12.D12_QTDLID = 0
		AND (D12.D12_RECHUM = %Exp:cRecHVazio%
			OR D12.D12_RECHUM = %Exp:__cUserID% )
		AND D12.D12_ENDDES = %Exp:cEndereco%
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	Do While (cAliasQry)->(!Eof())
		D12->(MsGoto((cAliasQry)->RECNOD12))
		RecLock('D12', .F.)  // Trava para gravacao
		D12->D12_RECHUM := __cUserID
		D12->D12_DATINI := dDataIni
		D12->D12_HORINI := cHoraIni
		D12->D12_DATFIM := CTOD("")
		D12->D12_HORFIM := ""
		D12->(MsUnlock())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidPrdLot
---Valida o produto informado, verificando se o mesmo pertence ao pedido/carga
---Valida se o mesmo já foi separado e pode ser conferido
---Jackson Patrick Werka - 01/04/2015
---cProduto, character, (Produto informado)
---cDescPro, character, (Descrição do produto)
---cDescPr2, character, (Descrição do produto)
---cDescPr3, character, (Descrição do produto)
---cLoteCtl, character, (Lote etiqueta)
---cNumLote, character, (Sub-lote etiqueta)
---nQtde, numerico, (Quantidade etiqueta)
---cCodBar, character, (Codigo de barras)
---lCarga, lógico, (Se produto controla carga)
---cCarga, caracter, (quando produto controla carga, numero da carga)
---cPedido, caracter, (quando produto nao controla carga, numero do pedido)
----------------------------------------------------------------------------------*/
Static Function ValidPrdLot(cProduto,cLoteCtl,cNumLote,nQtde,cCodBar,lCarga)
Local lRet     := .T.

	If Empty(cCodBar)
		Return .F.
	EndIf

	//Deve zerar estas informações, pois pode haver informação de outra etiqueta
	cLoteCtl := Space(TamSX3('D12_LOTECT')[1])
	cNumLote := Space(TamSX3('D12_NUMLOT')[1])

	lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cNumLote,@nQtde,@cCodBar)

	// Executado para efetuar a validação do produto digitado
	If lWMS076VL
		lRetPE := ExecBlock('WMS076VL',.F.,.F.,{cProduto,cLoteCtl,cNumLote,nQtde,cCodBar,cCarga,cPedido,lCarga})
		lRet   := If(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf

	// Deve validar se o produto possui quantidade para ser conferida
	If lRet
		If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote,.F.)) == 0
			WMSVTAviso(WMSV07611,IIF(lWmsDaEn .And. !oMovimento:lUsuArm,STR0028,WmsFmtMsg(STR0057,{{"[VAR01]",cArmazem}}))) // Não existe conferência para o produto. // Não existe conferência para o produto no armazém [VAR01].
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		// Verifica se possui alguma quantidade para conferir liberada
		If lRet .And. QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote)) == 0
			// Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
			If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote,.F.,.T.)) > 0
				WMSVTAviso(WMSV07612,STR0042) // Conferência do produto bloqueada.
			Else
				WMSVTAviso(WMSV07613,STR0043) // Conferência do produto finalizada.
			EndIf
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
		If lRet .And. QtdComp(QtdPrdSep(cProduto,cLoteCtl,cNumLote)) == 0
			WMSVTAviso(WMSV07614,STR0029) // Produto não possui quantidade separada para conferência.
			VTKeyBoard(Chr(20))
			lRet := .F.
		EndIf
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValLoteCtl
---Valida o produto/lote informado, verificando se o mesmo pertence ao pedido/carga
---Valida se o mesmo já foi separado e pode ser conferido
---Jackson Patrick Werka - 01/04/2015
---cLoteCtl, character, (Lote etiqueta)
----------------------------------------------------------------------------------*/
Static Function ValLoteCtl(cProduto,cLoteCtl)
Local lRet  := .T.
	If Empty(cLoteCtl)
		Return .F.
	EndIf
	If QtdComp(QtdPrdCof(cProduto,cLoteCtl,,.F.)) == 0
		WMSVTAviso(WMSV07615,STR0030) // Produto/Lote não pertence a conferência.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Verifica se possui alguma quantidade para conferir liberada
	If lRet .And. QtdComp(QtdPrdCof(cProduto,cLoteCtl)) == 0
		// Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
		If QtdComp(QtdPrdCof(cProduto,cLoteCtl,,.F.,.T.)) > 0
			WMSVTAviso(WMSV07616,STR0044) // Conferência do Produto/Lote bloqueada.
		Else
			WMSVTAviso(WMSV07617,STR0045) // Conferência do Produto/Lote finalizada.
		EndIf
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	If lRet .And. QtdComp(QtdPrdSep(cProduto,cLoteCtl)) == 0
		WMSVTAviso(WMSV07618,STR0031) // Produto/Lote não possui quantidade separada para conferência.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValSubLote
---Valida o produto/rastro informado, verificando se o mesmo pertence ao pedido/carga
---Valida se o mesmo já foi separado e pode ser conferido
---Jackson Patrick Werka - 01/04/2015
---cLoteCtl, character, (Lote)
---cNumLote, Caracter, (Sub-lote)
----------------------------------------------------------------------------------*/
Static Function ValSubLote(cProduto,cLoteCtl,cNumLote)
Local lRet  := .T.
	If Empty(cNumLote)
		Return .F.
	EndIf
	If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote,.F.)) == 0
		WMSVTAviso(WMSV07619,STR0032) // Produto/Rastro não pertence a conferência.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Verifica se possui alguma quantidade para conferir liberada
	If lRet .And. QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote)) == 0
		// Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
		If QtdComp(QtdPrdCof(cProduto,cLoteCtl,cNumLote,.F.,.T.)) > 0
			WMSVTAviso(WMSV07620,STR0046) // Conferência do Produto/Rastro bloqueada.
		Else
			WMSVTAviso(WMSV07621,STR0047) // Conferência do Produto/Rastro finalizada.
		EndIf
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	If lRet .And. QtdComp(QtdPrdSep(cProduto,cLoteCtl,cNumLote)) == 0
		WMSVTAviso(WMSV07622,STR0033) // Produto/Rastro não possui quantidade separada para conferência.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---ValidQtd
---Valida a quantidade informada efetuando a conversão das unidades de medida
---Jackson Patrick Werka - 01/04/2015
---nQtConf, Numerico, (Quantidade conferida)
---nItem, Numerico, (Quantidade Item)
---nQtdNorma, Numerico, (Quantidade da norma)
---nQtde1UM, Numerico, (Quantidade 1UM)
---nQtde2UM, Numerico, (Quantidade 2UM)
----------------------------------------------------------------------------------*/
Static Function ValidQtd(cProduto,cLoteCtl,cNumLote,nQtConf,nItem,nQtdNorma,nQtde1UM,nQtde2UM)
Local lRet := .T.
Local nQtdPrdCof := 0
Local nQtdPrdSep := 0
// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
	If Empty(nQtConf)
		Return .F.
	EndIf
	// O sistema trabalha sempre na 1a.UM
	If nItem == 1
		// Converter de U.M.I. p/ 1a.UM
		nQtde1UM := (nQtConf * nQtdNorma)
		nQtde2UM := ConvUm(cProduto,nQtde1UM,0,2)
	ElseIf nItem == 2
		// Converter de 2a.UM p/ 1a.UM
		nQtde2UM := nQtConf
		nQtde1UM := ConvUm(cProduto,0,nQtde2UM,1)
	ElseIf nItem == 3
		// Converter de 1a.UM p/ 2a.UM
		nQtde1UM := nQtConf
		nQtde2UM := ConvUm(cProduto,nQtde1UM,0,2)
	EndIf
	// Validando as quantidades informadas
	nQtdPrdCof := QtdPrdCof(cProduto,cLoteCtl,cNumLote)
	If QtdComp(nQtde1UM) > QtdComp(nQtdPrdCof)
		WMSVTAviso(WMSV07623,STR0034) // Quantidade informada maior que a quantidade liberada para conferência.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	// Valida se a quantidade separada é maior ou igual a quantidade conferida mais o está sendo conferido
	nQtdPrdSep := QtdPrdSep(cProduto,cLoteCtl,cNumLote)
	nQtdPrdCof := QtdPrdCof(cProduto,cLoteCtl,cNumLote,,,.T.)
	If lRet .And. QtdComp(nQtdPrdCof+nQtde1UM) > QtdComp(nQtdPrdSep)
		WMSVTAviso(WMSV07624,STR0035) // Quantidade conferida mais a informada maior que quantidade total separada.
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
Return lRet
/*--------------------------------------------------------------------------------
---QtdPrdCof
---Permite carregar a quantidade do produto que está pendente de conferência
---Jackson Patrick Werka - 01/04/2015
---lSitLib, Logico, (Indica se está liberado)
---lSitBlq, Logico, (Indica se está bloqueado)
---lQtdLid, Logico, (Indica se está lida)
----------------------------------------------------------------------------------*/
Static Function QtdPrdCof(cProduto,cLoteCtl,cNumLote,lSitLib,lSitBlq,lQtdLid)
Local aAreaAnt   := GetArea()
Local aTamSX3    := TamSx3('D12_QTDMOV')
Local cwhere     := ""
Local cCampos    := ""
Local cStatus    := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
Local nQuant     := 0

Default cLoteCtl:= Space(TamSX3('D12_LOTECT')[1])
Default cNumLote:= Space(TamSX3('D12_NUMLOT')[1])
Default lSitLib := .T.
Default lSitBlq := .F.
Default lQtdLid := .F.

	cWhere := "%"
	If !Empty(cLoteCtl)
		cWhere += " AND D12.D12_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D12.D12_NUMLOT = '"+cNumLote+"'"
	EndIf
	If oMovimento:lUsuArm .Or. !lWmsDaEn
		cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
	EndIf
	If lQtdLid
		cWhere += " AND D12.D12_STATUS IN ('3','1')"
	ElseIf lSitLib
		cWhere += " AND D12.D12_STATUS IN ('3','4')"
	ElseIf lSitBlq
		cWhere += " AND D12.D12_STATUS = '2'"
	Else
		cWhere += " AND D12.D12_STATUS <> '0'"
	EndIf
	If WmsCarga(cCarga)
		cWhere += " AND D12.D12_CARGA  = '"+cCarga+"'"
	Else
		cWhere += " AND D12.D12_DOC    = '"+cPedido+"'"
	EndIf
	cWhere += "%"
	cCampos := "%"
	If lQtdLid
		cCampos += "SUM(D12.D12_QTDLID) QTD_SALDO"
	ElseIf lSitLib
		cCampos += "SUM(D12.D12_QTDMOV - D12.D12_QTDLID) QTD_SALDO"
	Else
		cCampos += "SUM(D12.D12_QTDMOV) QTD_SALDO"
	EndIf	
	cCampos += "%"
	BeginSql Alias cAliasQry
		SELECT %Exp:cCampos%
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar%
		AND D12.D12_PRODUT = %Exp:cProduto%
		AND (D12.D12_RECHUM = %Exp:__cUserID%
			OR D12.D12_RECHUM = %Exp:cRecHVazio% )
		AND D12.D12_ENDDES = %Exp:cEndereco%
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	TcSetField(cAliasQry,'QTD_SALDO','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		nQuant := (cAliasQry)->QTD_SALDO
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return nQuant
/*--------------------------------------------------------------------------------
---QtdPrdSep
---Permite carregar a quantidade do produto que está empenhada (já separada)
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function QtdPrdSep(cProduto,cLoteCtl,cNumLote)
Local aAreaAnt   := GetArea()
Local oServico   := WMSDTCServicoTarefa():New()
Local cWhere     := ""
Local cWhereDCF  := ""
Local cAliasQry  := GetNextAlias()
Local aTamSX3    := TamSx3('D12_QTDMOV')
Local nQuant     := 0

Default cLoteCtl := Space(TamSX3('D12_LOTECT')[1])
Default cNumLote := Space(TamSX3('D12_NUMLOT')[1])

	oServico:SetServico(cServico)
	oServico:SetOrdem(cOrdTar)
	oServico:LoadData()
	// Parâmetro Where
	cWhere := "%"
	If !Empty(cLoteCtl)
		cWhere += " AND D12.D12_LOTECT = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D12.D12_NUMLOT = '"+cNumLote+"'"
	EndIf
	cWhere += "%"
	cWhereDCF := "%"
	If WmsCarga(cCarga)
		cWhereDCF += " AND DCF.DCF_CARGA = '"+cCarga+"'"
	Else
		cWhereDCF += " AND DCF.DCF_DOCTO = '"+cPedido+"'"
	EndIf
	cWhereDCF += "%"
	BeginSql Alias cAliasQry
		SELECT SUM(DCR.DCR_QUANT) QTD_SEPARA
		FROM %Table:DCF% DCF
		INNER JOIN %Table:DCR% DCR
		ON DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF = DCF.DCF_ID
		AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN
		AND DCR.%NotDel%
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = DCF.DCF_SERVIC
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.D12_ORDTAR = %Exp:oServico:FindOrdAnt()% // Assume a tarefa exatamante anterior
		AND D12.D12_PRODUT  = %Exp:cProduto%
		AND D12.D12_ORDMOV IN ('3','4')
		AND D12.D12_STATUS = '1'
		AND D12.%NotDel%
		%Exp:cWhere%
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_SERVIC = %Exp:cServico%
		AND DCF.%NotDel%
		%Exp:cWhereDCF%
	EndSql
	TcSetField(cAliasQry,'QTD_SEPARA','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		nQuant := (cAliasQry)->QTD_SEPARA
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return nQuant
/*--------------------------------------------------------------------------------
---GravCofOpe
---Grava a quantidade conferida, finalizando a atividade
---relativa ao produto conferido, se for o caso.
---Jackson Patrick Werka - 01/04/2015
---nQtConf, Numerico, (Quantidade conferida)
----------------------------------------------------------------------------------*/
Static Function GravCofOpe(cProduto,cLoteCtl,cNumLote,nQtConf)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cWhere     := ""
Local cAliasQry  := GetNextAlias()
Local nQtdLid    := 0
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])

	// Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
	// Parâmetro Where
	cWhere := "%"
	If WmsCarga(cCarga)
		cWhere += " AND D12.D12_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND D12.D12_DOC   = '"+cPedido+"'"
	EndIf
	If !Empty(cLoteCtl)
		cWhere += " AND D12.D12_LOTECT  = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D12.D12_NUMLOT  = '"+cNumLote+"'"
	EndIf
	If oMovimento:lUsuArm .Or. !lWmsDaEn
		cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
	EndIf
	cWhere += "%"
	Begin Transaction
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:cServico%
			AND D12.D12_TAREFA = %Exp:cTarefa%
			AND D12.D12_ATIVID = %Exp:cAtividade%
			AND D12.D12_ORDTAR = %Exp:cOrdTar%
			AND D12.D12_PRODUT = %Exp:cProduto%
			AND D12.D12_STATUS IN ('3','4')
			AND (D12.D12_RECHUM = %Exp:__cUserID%
				OR D12.D12_RECHUM  = %Exp:cRecHVazio% )
			AND D12.D12_LOCDES = %Exp:cArmazem%
			AND D12.D12_ENDDES = %Exp:cEndereco%
			AND (D12.D12_QTDMOV-D12.D12_QTDLID) > 0
			AND D12.%NotDel%
			%Exp:cWhere%
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof()) .And. QtdComp(nQtConf) > 0
			D12->(dbGoTo((cAliasQry)->RECNOD12))
			// Verifica somente o saldo que falta conferir daquele item
			// Se o saldo é diferente do informado para conferir
			// E a diferença absoluta do saldo mais o conferido é maior que a tolerancia
			If QtdComp(D12->D12_QTDMOV - D12->D12_QTDLID) < QtdComp(nQtConf)
				nQtdLid := D12->D12_QTDMOV - D12->D12_QTDLID
			Else
				nQtdLid := nQtConf
			EndIf
			RecLock("D12",.F.)
			D12->D12_DATINI := dDataIni
			D12->D12_HORINI := cHoraIni
			D12->D12_DATFIM := dDataBase
			D12->D12_HORFIM := Time()
			D12->D12_RECHUM := __cUserID
			D12->D12_STATUS := '3' // Atividade Em Andamento
			D12->D12_QTDLID := D12->D12_QTDLID + nQtdLid
			D12->D12_QTDLI2 := ConvUm(cProduto,D12->D12_QTDLID,0,2)
			D12->(MsUnLock())
			// Diminuindo a quantida utilizada da quantidade conferida
			nQtConf -= nQtdLid

			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		If !lRet
			DisarmTransaction()
			WMSVTAviso(WMSV07625,STR0036) // Não foi possível registrar a quantidade.
		EndIf
	End Transaction
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---FinCofExp
---Grava a quantidade conferida, finalizando a atividade
---relativa ao produto conferido, se for o caso.
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function FinCofExp()
Local lRet       := .T.
Local lDiverge   := .F.
Local lDocPend   := .F.
Local cWhere     := ""
Local aAreaAnt   := GetArea()
Local cAliasQry  := Nil
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
	If AtivAntPen()
		WMSVTAviso(WMSV07631,STR0037) // Existem atividades anteriores não finalizadas.
		Return .F.
	EndIf
	If DocAntPen()
		WMSVTAviso(WMSV07632,STR0048) // Existem ordens de serviço pendentes de execução.
		lDocPend := .T.
	EndIf
	// Parâmetro Where
	cWhere := "%"
	If WmsCarga(cCarga)
		cWhere += " AND D12.D12_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND D12.D12_DOC   = '"+cPedido+"'"
	EndIf
	If oMovimento:lUsuArm .Or. !lWmsDaEn
		cWhere += " AND D12.D12_LOCDES  = '"+cArmazem+"'"
	EndIf
	cWhere += "%"
	Begin Transaction
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:cServico%
			AND D12.D12_TAREFA = %Exp:cTarefa%
			AND D12.D12_ATIVID = %Exp:cAtividade%
			AND D12.D12_ORDTAR = %Exp:cOrdTar%
			AND D12.D12_STATUS IN ('2','3','4')
			AND (D12.D12_RECHUM = %Exp:__cUserID%
				OR D12.D12_RECHUM = %Exp:cRecHVazio% )
			AND D12.D12_ENDDES = %Exp:cEndereco%
			AND (D12.D12_QTDMOV - D12.D12_QTDLID) > 0
			AND D12.%NotDel%
			%Exp:cWhere%
		EndSql
		If (cAliasQry)->(!Eof())
			If WmsQuestion(STR0038,WMSV07628) // Existem itens não conferidos. Confirma a finalização da conferência?
				Do While (cAliasQry)->(!Eof())
					lDiverge := .T.
					D12->(dbGoTo((cAliasQry)->RECNOD12))
					RecLock("D12",.F.)
					D12->D12_DATFIM := dDataBase
					D12->D12_HORFIM := Time()
					D12->D12_STATUS := '2' // Atividade Com Problemas
					D12->D12_PRAUTO := '1' // Permite reinicio automático
					D12->D12_ANOMAL := 'S'
					D12->(MsUnLock())
					(cAliasQry)->(DbSkip())
				EndDo
			Else
				lRet   := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
		// Aqui deve liberar os itens do pedido de venda, caso esteja parametrizado para tal
		If lRet .And. !lDiverge
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT D12.R_E_C_N_O_ RECNOD12
				FROM %Table:D12% D12
				WHERE D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_SERVIC = %Exp:cServico%
				AND D12.D12_TAREFA = %Exp:cTarefa%
				AND D12.D12_ATIVID = %Exp:cAtividade%
				AND D12.D12_ORDTAR = %Exp:cOrdTar%
				AND D12.D12_ENDDES = %Exp:cEndereco%
				AND D12.D12_STATUS IN ('2','3','4')
				AND (D12.D12_QTDMOV - D12.D12_QTDLID) <= 0
				AND D12.%NotDel%
				%Exp:cWhere%
			EndSql
			Do While (cAliasQry)->(!Eof())
				D12->(dbGoTo((cAliasQry)->RECNOD12))
				RecLock("D12",.F.)
				D12->D12_STATUS := IIf(lDocPend,'2','1') // Com Problema // Finalizado
				D12->D12_PRAUTO := IIf(lDocPend,'1','2') // Permite reinicio automático
				D12->(MsUnLock())
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
			If !lDocPend .And. oMovimento:GetLibPed() == "2"
				oMovimento:LibPedConf()
			EndIf
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	If lRet .And. !lDiverge .And. !lDocPend
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:cServico%	
			AND D12.D12_TAREFA = %Exp:cTarefa%
			AND D12.D12_ATIVID = %Exp:cAtividade%
			AND D12.D12_ORDTAR = %Exp:cOrdTar%
			AND D12.D12_STATUS IN ('2','3','4')
			AND D12.D12_RECHUM <> %Exp:__cUserID%
			AND D12.D12_ENDDES = %Exp:cEndereco%
			AND (D12.D12_QTDMOV - D12.D12_QTDLID) > 0
			AND D12.%NotDel%
			%Exp:cWhere%
		EndSql
		If (cAliasQry)->(!Eof())
			WMSVTAviso(WMSV07630,STR0002) // Conferência em andamento, há pendências atribuidas para outros usuários!
		Else
			WMSVTAviso(WMSV07630,STR0050) // Conferência encerrada com sucesso!
			If Existblock("WV076FIN")
				Execblock("WV076FIN",.F.,.F.,{cCarga, cPedido})
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	Else
		WMSVTAviso(WMSV07629,STR0039) // Não foi possível finalizar a conferência.
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---SaiCofExp
---Efetua a validação para verificar se não exitem mais itens pendentes
---Caso não exista mais nenhuma pendencia, somente deverá ser finalizado a conferência
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function SaiCofExp()
Local aAreaAnt   := GetArea()
Local lRet       := .T.

	If !AtivAtuPen()
		If !DocAntPen()
			WMSVTAviso(WMSV07633,STR0052) // Não existem mais itens para serem conferidos. Conferência deve ser finalizada.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---ValidEnder
---Valida o endereço informado
---Jackson Patrick Werka - 01/04/2015
---cEndereco, Caracter, (Endereço informado)
----------------------------------------------------------------------------------*/
Static Function ValidEnder(cEndereco)
Local aAreaAnt := GetArea()
Local lRet     := .T.
	// Se não informou a carga retorna
	If Empty(cEndereco)
		Return .F.
	EndIf
	If cEndereco != oMovimento:oMovEndOri:GetEnder()
		WMSVTAviso(WMSV07602,STR0017) // Endereco incorreto!
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
	If lRet
		If !oMovimento:oMovEndOri:LoadData()
			WMSVTAviso(WMSV07603,WmsFmtMsg(STR0018,{{"[VAR01]",oMovimento:oMovEndOri:GetEnder()}})) // O endereco [VAR01] não está cadastrado!
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return(lRet)
/*--------------------------------------------------------------------------------
---AtivAntPen
---Verifica se existem atividades anteriores não finalizadas
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function AtivAntPen()
Local lRet      := .F.
Local oServico  := WMSDTCServicoTarefa():New()
Local cAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
Local cWhere    := ""

	oServico:SetServico(cServico)
	oServico:SetOrdem(cOrdTar)
	oServico:LoadData()
	
	cWhere := "%"
	If WmsCarga(cCarga)
		cWhere += " AND DCF.DCF_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND DCF.DCF_DOCTO = '"+cPedido+"'"
	EndIf
	cWhere += "%"

	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:DCF% DCF
		INNER JOIN %Table:DCR% DCR
		ON DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF = DCF.DCF_ID
		AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN"
		AND DCR.%NotDel%
		INNER JOIN %Table:D12% D12
		ON D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_SERVIC = DCF.DCF_SERVIC
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.D12_ORDTAR = %Exp:oServico:FindOrdAnt()% // Assume a tarefa exatamante anterior
		AND D12.D12_STATUS IN ('2','3','4')
		AND D12.%NotDel%
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_SERVIC = %Exp:cServico%
		AND DCF.%NotDel%
		%Exp:cWhere%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(cAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---DocAntPen
---Verifica se existem ordens de serviço não executadas para o mesmo documento
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function DocAntPen()
Local lRet        := .F.
Local cAreaAnt    := GetArea()
Local cAliasQry   := GetNextAlias()
Local cWhere      := ""

	cWhere := "%"
	If WmsCarga(cCarga)
		cWhere += " AND DCF.DCF_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND DCF.DCF_DOCTO = '"+cPedido+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_SERVIC = %Exp:cServico%
		AND DCF.DCF_STSERV IN ('1','2')
		AND DCF.%NotDel%
		%Exp:cWhere%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(cAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---AtivAtuPen
---Verifica se existem atividades do documento atual ainda pendentes
---Jackson Patrick Werka - 01/04/2015
----------------------------------------------------------------------------------*/
Static Function AtivAtuPen()
Local lRet       := .F.
Local cAreaAnt   := GetArea()
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])
Local cWhere     := ""

	cWhere := "%"
	If WmsCarga(cCarga)
		cWhere += " AND D12.D12_CARGA = '"+cCarga+"'"
	Else
		cWhere += " AND D12.D12_DOC   = '"+cPedido+"'"
	EndIf	
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:SDB%
		AND D12.D12_SERVIC = %Exp:cServico%
		AND D12.D12_TAREFA = %Exp:cTarefa%
		AND D12.D12_ATIVID = %Exp:cAtividade%
		AND D12.D12_ORDTAR = %Exp:cOrdTar%
		AND D12.D12_STATUS IN ('2','3','4')
		AND (D12.D12_RECHUM = %Exp:__cUserID%
			OR D12.D12_RECHUM = %Exp:cRecHVazio% )
		AND D12.D12_LOCORI = %Exp:cArmazem%
		AND D12.D12_ENDORI = %Exp:cEndereco%
		AND D12.%NotDel%
		%Exp:cWhere%
	EndSql
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(cAreaAnt)
Return lRet
/*--------------------------------------------------------------------------------
---WMSV076ESC
---Questiona ao usuário se o mesmo deseja sair da conferência, abandonando a mesma
---Jackson Patrick Werka - 01/04/2015
---lAbandona, Logico, (Indica se abandona conferencia)
----------------------------------------------------------------------------------*/
Static Function WMSV076ESC(lAbandona)
// Disponibiliza novamente o documento para convocação quando o operador
// altera o documento ou abandona conferência pelo Coletor RF.
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local cRecHVazio := Space(TamSX3('D12_RECHUM')[1])

	If WmsQuestion(STR0051) // Deseja sair da conferencia?
		// Variavel private definida no programa WMSV001
		lAbandona := .T.
		// Variavel definida no programa WMSV001
		WMSAltSts(.F.)

		Begin Transaction
			oMovimento:SetRecHum(IIf(lLiberaRH,cRecHVazio,oMovimento:GetRecHum()))
			If oMovimento:GetQtdLid() > 0
				oMovimento:SetStatus("3") // Atividade Em Andamento
				oMovimento:SetDataIni(dDataIni)
				oMovimento:SetHoraIni(cHoraIni)
				oMovimento:SetDataFim(CTOD(""))
				oMovimento:SetHoraFim("")
			Else
				oMovimento:SetStatus("4") // Atividade A Executar
				oMovimento:SetDataIni(CTOD(""))
				oMovimento:SetHoraIni("")
				oMovimento:SetDataFim(CTOD(""))
				oMovimento:SetHoraFim("")
			EndIf
			oMovimento:UpdateD12()
		End Transaction

		If lLiberaRH
			// Retira recurso humano atribuido as atividades de outros itens do mesmo pedido / carga.
			CancRHServ()
		EndIf
	EndIf
Return (Nil)
/*--------------------------------------------------------------------------------
---UpdStatus
---Verifica se o produto informado é o mesmo que o posicionado no objeto,
-- caso contrário posiciona no recno correto e atualiza o status das movimentações
---Amanda Rosa Vieira - 14/12/2016
---cProduto,  caracter, (Produto)
---cLoteCtl,  caracter, (Lote)
---cNumLote,  caracter, (Sub-Lote)
----------------------------------------------------------------------------------*/
Static Function UpdStatus(lCarga,cProduto,cLoteCtl,cNumLote)
Local nRecnoD12 := 0
	//Se o produto da movimentação corrente não teve quantidade lida, então seu status passa para "A Excutar"
	//Já a movimentação do 'novo' produto ou lote informado deve passar para "Em Execução"
	If cProduto <> oMovimento:oMovPrdLot:GetProduto() .Or. cLoteCtl <> oMovimento:oMovPrdLot:GetLoteCtl() .Or. cNumLote <> oMovimento:oMovPrdLot:GetNumLote()
		If QtdPrdCof(oMovimento:oMovPrdLot:GetProduto(),oMovimento:oMovPrdLot:GetLoteCtl(),oMovimento:oMovPrdLot:GetNumLote(),.F.,.F.,.T.) == 0
			oMovimento:SetStatus("4") // Atividade A Executar
			oMovimento:UpdateD12()
		EndIf
		HasTarDoc(lCarga,@nRecnoD12,cProduto,cLoteCtl,cNumlote)
		oMovimento:GotoD12(nRecnoD12)
		If oMovimento:GetStatus() != "3"
			oMovimento:SetStatus("3") // Atividade Executando
			oMovimento:UpdateD12()
		EndIf
	EndIf
Return

//----------------------------------------------------------
/*/{Protheus.doc} TrdocUsuCF
Efetuar validações de permissão do usuário na troca de documento/serviço.
@author  Roselaine Adriano.
@version P12
@Since   13/10/2020
@version 1.0
/*/
//----------------------------------------------------------
Static Function TrdocUsuCF(nRecnoD12)
Local lRet := .T.
Local cUsuZona   := aParConv[5]
Local lNaoConv   := SuperGetMV("MV_WMSNREG", .F., .F.)
Local oRegraConv := WMSBCCRegraConvocacao():New()

	oRegraConv:aRetRegra := {}
	oRegraConv:SetArmazem(cArmazem)
	oRegraConv:SetRecHum(__cUserID)
	oRegraConv:oMovimento:GoToD12(nRecnoD12)
	// Verifica se ha regras para convocacao
	If oRegraConv:LawRecHum()
		// Analisa se convocao ou nao
		If !oRegraConv:LawLimit()
			lRet := .F.
		EndIf
	Else
	    If lNaoConv
			lRet := .F.
		EndIf
		// Apesar de o operador(A) nao ter regra definida, preciso analisar se outro operador(B) reservou a rua,
		// se o operador(B) ja reservou a rua o operador(A) nao sera convocado ate que a rua seja liberada.
		If lRet .And. !oRegraConv:LawChkRua()
			lRet := .F.
		EndIf
		// Ignora a Zona de Armazenagem diferente da escolhida na convocacao
		If lRet .And. !Empty(cUsuZona)
			lRet := (oMovimento:oMovEndOri:GetCodZona() == cUsuZona)
		EndIf
	EndIf

Return lRet
