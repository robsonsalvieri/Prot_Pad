#Include 'Protheus.CH'
#INCLUDE "APVT100.CH"
#INCLUDE 'FIVEWIN.CH'
#INCLUDE "WMSV102.ch"

#DEFINE WMSV10201 "WMSV10201"
#DEFINE WMSV10202 "WMSV10202"
#DEFINE WMSV10203 "WMSV10203"
#DEFINE WMSV10204 "WMSV10204"
#DEFINE WMSV10205 "WMSV10205"
#DEFINE WMSV10206 "WMSV10206"
#DEFINE WMSV10207 "WMSV10207"
#DEFINE WMSV10208 "WMSV10208"
#DEFINE WMSV10209 "WMSV10209"
#DEFINE WMSV10210 "WMSV10210"
#DEFINE WMSV10211 "WMSV10211"
#DEFINE WMSV10212 "WMSV10212"
#DEFINE WMSV10213 "WMSV10213"
#DEFINE WMSV10214 "WMSV10214"
#DEFINE WMSV10215 "WMSV10215"
#DEFINE WMSV10217 "WMSV10217"
#DEFINE WMSV10218 "WMSV10218"
#DEFINE WMSV10219 "WMSV10219"
#DEFINE WMSV10220 "WMSV10220"
#DEFINE WMSV10221 "WMSV10221"
#DEFINE WMSV10222 "WMSV10222"
#DEFINE WMSV10223 "WMSV10223"
#DEFINE WMSV10224 "WMSV10224"
#DEFINE WMSV10225 "WMSV10225"
#DEFINE WMSV10226 "WMSV10226"
#DEFINE WMSV10227 "WMSV10227"
#DEFINE WMSV10228 "WMSV10228"
#DEFINE WMSV10229 "WMSV10229"
#DEFINE WMSV10230 "WMSV10230"
#DEFINE WMSV10231 "WMSV10231"
#DEFINE WMSV10232 "WMSV10232"
#DEFINE WMSV10233 "WMSV10233"
//----------------------------------------------------------
/*/{Protheus.doc} WMSV102 - Conferência de Expedição
Permite que os produtos de um pedido de venda ou carga sejam conferidos.
Similar ao DLGV102 adaptado para o novo WMS

@version P11
@since   08/05/15
/*/
//----------------------------------------------------------
Function WMSV102()
Local bkey09  := VTSetKey(09)
Local bkey22  := VTSetKey(22)
Local cKey09  := VtDescKey(09)
Local cKey22  := VtDescKey(22)
Local aTela   := {}
Local lRet    := .T.
Local nOpc    := 0
Local cCodOpe := __cUserID

Private lFuncVol := FindFunction('WMSV100VOL')
Private cPCarga  := ""
Private cPPedido := ""

	Do While lRet
		If Empty(cCodOpe)
			WmsMessage(STR0001,WMSV10201) // Operador nao cadastrado
			lRet := .F.
		EndIf
		If lRet
			aTela := VtSave()
			VTClear() 

			If IsInCallStack("WMSV102")
				@ 0,0 VTSay STR0003 // Selecione:
				nOpc:=VTaChoice(2,0,4,VTMaxCol(),{STR0004,STR0005}) // Confere Carga // Confere Pedido
			ElseIf IsInCallStack("WMSV102A")
				nOpc := 1  // Confere Carga
			ElseIf IsInCallStack("WMSV102B")
				nOpc := 2 // Confere Pedido
			EndIf
			VtClearBuffer()

			// Tela de conferência
			If nOpc <> 0
				WMSV1021(nOpc)
			EndIf

			If VtLastKey() == 27
				VtRestore(,,,,aTela)
				lRet := .F.
			EndIf

			// Restaura teclas
			VTSetKey(09,bkey09,cKey09)
			VTSetKey(22,bkey22,cKey22)
			VtRestore(,,,,aTela)
		Else
			VtKeyboard(Chr(20))
		EndIf
	EndDo
Return lRet
//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Conferência de Carga
//----------------------------------------------------------
Function WMSV102A()
	WMSV102()
Return Nil
//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Conferência de Pedido
//----------------------------------------------------------
Function WMSV102B()
	WMSV102()
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} WMSV1021
Tela de Conferência de Expedição

@param   nTipo    Tipo de endereçamento:
						1 - Carga
						2 - Pedido
						3 - NF

@author  Evaldo Cevinscki Jr.
@version P11
@since   24/07/12 - revisão 02/10/14
/*/
//----------------------------------------------------------
Function WMSV1021(nTipo)
Local aTela     := VTSave()
Local aVolume   := {}
Local lRet 	    := .T.
Local lEsc      := .F.
Local lVolume   := .F.
Local lWMSConf  := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local bkey15    := VTSetKey(15)
Local bkey24    := VTSetKey(24)   // trocar por 24 ctrl+x
Local cKey15    := VtDescKey(15)
Local cKey24    := VtDescKey(24)
Local cCarga    := Space(Len(D02->D02_CARGA))
Local cPedido   := Space(Len(D02->D02_PEDIDO))
Local cProduto  := Space(Len(D02->D02_CODPRO))
Local cPrdOri   := Space(Len(D02->D02_PRDORI))
Local cLoteCtl  := Space(Len(D02->D02_LOTE))
Local cNumLote  := Space(Len(D02->D02_SUBLOT))
Local cCodExp   := Space(Len(D02->D02_CODEXP))
Local cStatusD01:= ""
Local cWmsUMI   := ""
Local cPrdAnt   := ""
Local cDscUM    := ""
Local cUM       := ""
Local cPictQt   := ""
Local cPedAux   := ""
Local cHrIni    := ""
Local nLin      := 0
Local i         := 0
Local nItem     := 0
Local nQtd      := 0
Local nQtdConfer:= 0
Local nQtdConf  := 0
Local dDtIni    := CtoD('  /  /  ')
Local cArmazem := ""
Local cEndereco  := ""

Private lWmsLote := SuperGetMV("MV_WMSLOTE",.F.,.F.)

	VTSetKey(15,{|| MontaCons(nTipo,cCarga,cPedido)}, STR0050) // Ctrl+O // Conferencias
	If nTipo < 3
		VTSetKey(24,{|| WMSEST102(nTipo)}, STR0051) // Ctrl+X // Estorno
	EndIf

	Do While !lEsc
		lEsc     := .F.
		cPCarga  := ""
		cPPedido := ""
		cCarga   := Space(Len(D02->D02_CARGA))
		cPedido  := Space(Len(D02->D02_PEDIDO))

		VTClear()
		VTClearBuffer()
		WMSVTCabec(STR0007, .F., .F., .T.) // Conferencia
		If nTipo == 1
			@ 02, 00 VTSay PadR(STR0008, VTMaxCol())   // Carga
			@ 03, 00 VTGet cCarga Valid ValidCarga(.F.,cCarga) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.)
			VTRead()
			If VTLastKey() == 27
				Exit
			EndIf
			cPCarga := cCarga
			// Quando for identificado que a carga toda esta em volumes não solicita o pedido, caso contrário tem que informar o pedido se tiver itens soltos
			If !lVolume
				@ 05, 00 VTSay PadR(STR0009, VTMaxCol())   // Pedido
				@ 06, 00 VTGet cPedido Valid ValPedido(nTipo,.F.,cCarga,cPedido)
				VTRead()
				cPPedido := cPedido
			EndIf
		ElseIf nTipo == 2
			@ 02, 00 VTSay PadR(STR0009, VTMaxCol())   // Pedido
			@ 03, 00 VTGet cPedido Valid ValPedido(nTipo,.F.,@cCarga,cPedido)
			VTRead()
			cPPedido := cPedido
		EndIf

		If VTLastKey() == 27
			Exit
		EndIf

		Do While .T.
			cCodBar    := Space(128)
			cPrdOri    := Space(Len(D02->D02_PRDORI))
			cProduto   := Space(Len(D02->D02_CODPRO))
			cLoteCtl   := Space(Len(D02->D02_LOTE))
			cNumLote   := Space(Len(D02->D02_SUBLOT))
			aVolume    := {}
			// Quantiadade conferida
			nQtdConfer := nQtd
			nQtd       := 0
			nLin       := 1

			VTClear()
			WMSVTCabec(STR0007, .F., .F., .T.) // Conferencia
			If nTipo == 1
				@ nLin++,0 VtSay STR0012+cCarga+STR0013+cPedido // C.: // P.:
			ElseIf nTipo == 2
				@ nLin++,0 VtSay STR0014+cPedido // Pedido:
			EndIf
			@ nLin++, 00 VTSay PadR(STR0016, VTMaxCol()) // Produto:
			@ nLin++, 00 VTGet cCodBar Picture "@!" Valid !Empty(cCodBar) .And. WMSV102PRD(nTipo,.F.,cCarga,@cPedido,@cPrdOri,@cProduto,@nQtd,@cLoteCtl,@cNumLote,@aVolume,@cCodBar,,@cCodExp)
			VTRead()

			dDtIni := dDataBase
			cHrIni := 	Time()

			If VTLastKey() == 27
				// Caso a quantidade conferida anteriormente seja maior que zero
				// mostra dela de conferencia em andamento e volta para pedir a Carga/Pedido
				If nQtdConfer > 0
					VTClear()
					WMSVTCabec(STR0007, .F., .F., .T.)         // Conferencia
					@ 01, 00 VTSay PadR(STR0020, VTMaxCol())  // Em andamento!
					@ 02, 00 VTSay "------------------- "
					If nTipo == 1
						@ 03, 00 VTSay PadR(STR0021+cCarga, VTMaxCol())  // Carga.:
						@ 04, 00 VTSay "------------------- "
						@ 05, 00 VTSay PadR(STR0014+cPedido, VTMaxCol()) // Pedido:
					ElseIf nTipo == 2
						@ 03, 00 VTSay PadR(STR0014+cPedido, VTMaxCol()) // Pedido:
					EndIf
					WMSVTRodPe()
				EndIf
				Exit
			EndIf

			lVolume := !Empty(aVolume)
			lQtdBar := (nQtd > 0)
			If lQtdBar
				cPrdAnt := Space(TamSx3("D02_CODPRO")[1])
			EndIf
			// Quando o produto informando for um volume nao solicita essas informacoes abaixo, pegando a nQtd do retorno da funcao WMSV102PRD()
			If !lVolume
				If ((cProduto <> cPrdAnt) .Or. lWMSConf)
					//Valida a quantidade a ser conferida na segunda unidade de medida
					nQtdConf:=VldCalcof(cCodExp,cProduto,cCarga,cPedido)
					//Retorna o valor do armazem e endereço para passagem da função de validação da unidade de medida.
					VldArD12(cProduto,cCodExp,@cArmazem,@cEndereco)
					// Carrega unidade de medida, simbolo da unidade e quantidade na unidade
					WmsValUM(@nQtdConf,;        // Quantidade movimento
							@cWmsUMI,;      // Unidade parametrizada
							cProduto,;  // Produto
							cArmazem,;       // Armazem
							cEndereco,;       // Endereço
							@nItem,;       // Item unidade medida
							.F.,;       // Indica se é uma conferência
							lQtdBar)    // Indica se quantidade já preenchida
					// Monta tela produto
					WmsMontPrd(cWmsUMI,;    // Unidade parametrizada
								.T.,;        // Indica se é uma conferência
								STR0007,;    // Descrição da tarefa
								Nil,;        // Armazem
								Nil,;        // Endereço
								cPrdOri,;    // Produto Origem
								cProduto,;   // Produto
								cLoteCtl,;   // Lote
								cNumLote,;  // sub-lote
								Nil,;       // Id Unitizador
								nQtd)       // Quantidade preenchida

					If (VTLastKey()==27)
						Loop
					EndIf

					// Seleciona unidade de medida
					WmsSelUM(cWmsUMI,;      // Unidade parametrizada
							@cUM,;           // Unidade medida reduzida
							@cDscUM,;        // Descrição unidade medida
							Nil,;            // Quantidade movimento
							@nItem,;         // Item seleção unidade
							@cPictQt,;       // Mascara unidade medida
							Nil,;            // Quantidade no item seleção unidade
							.T.,;            // Indica se é uma conferência
							STR0007,;        // Descrição da tarefa
							cArmazem,;            // Armazem
							cEndereco,;            // Endereço
							cPrdOri,;        // Produto Origem
							cProduto,;       // Produto
							cLoteCtl,;       // Lote
							cNumLote,;  // sub-lote
							lQtdBar)    // Indica se quantidade já preenchida
					If (VTLastKey()==27)
						Loop
					EndIf
					cPrdAnt := cProduto
				EndIf

				If lWmsLote .And. Rastro(cProduto)
					@ nLin,   00 VTSay PadR("Lote:"/*STR0017*/, VTMaxCol()) // Lote:
					@ nLin++, 06 VTGet cLoteCtl Picture "@!" Valid !Empty(cLoteCtl) .And. ValidaLote(nTipo,.F.,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cCodExp)
					If Rastro(cProduto,"S")
						@ nLin,   00 VTSay PadR("Sub-Lote:"/*STR0018*/, VTMaxCol()) // Sub-Lote:
						@ nLin++, 10 VTGet cNumLote Picture "@!" Valid !Empty(cNumLote) .And. ValSubLote(nTipo,.F.,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,cCodExp)
					EndIf
					VTRead()
				EndIf

				If VTLastKey() == 27
					Exit
				EndIf

				@ nLin, 00 VTSay PadR(STR0019 + cDscUM + ':', VTMaxCol())
				@ nLin+1, 00 VTGet nQtd Picture cPictQt When VTLastKey()==05 .Or. Empty(nQtd) Valid ValidaQtde(.F.,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,,nQtd,cWmsUMI,nItem,cCodExp)
				VTRead()
			ElseIf Len(aVolume) > 0
				lRet := .T.
				For i := 1 To Len(aVolume)
					If !(ValidaQtde(.F.,aVolume[i][4],aVolume[i][5],aVolume[i][10],aVolume[i][1],aVolume[i][6],'','',aVolume[i][3],'',nItem,aVolume[i][12]))//cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,aSeq[nOpc,3],nQtd,cWmsUMI,nItem,cCodExp
						lRet := .F.
						Exit
					EndIf
				Next i
			EndIf

			// Volta para pedir o produto
			If VTLastKey() == 27 .Or. !lRet
				Loop
			EndIf

			//Define o pedido que deverá aparecer como finalizado, quando concluída a conferência.
			If Len(aVolume) == 1
				cPedAux := aVolume[1][5]
			ElseIf Len(aVolume) > 1  .And. (aScan(aVolume,{|x| Alltrim(x[5]) != Alltrim(cPedido)}) > 0)
				cPedAux := "VARIOS"
			Else
				cPedAux := cPedido
			EndIf

			If GravaDados(cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtd,cWmsUMI,nItem,aVolume,nTipo,dDtIni,cHrIni,cCodExp,@cStatusD01)
				VTClear()
				WMSVTCabec(STR0007, .F., .F., .T.)         // Conferencia
				If cStatusD01 == "3"
					@ 01, 00 VTSay PadR(STR0022, VTMaxCol())  // Finalizado
				Else
					@ 01, 00 VTSay PadR(STR0020, VTMaxCol())  // Em andamento!
				EndIf
				@ 02, 00 VTSay "------------------- "
				If nTipo == 1
					@ 03, 00 VTSay PadR(STR0021+cCarga, VTMaxCol())  // Carga.:
					@ 04, 00 VTSay "------------------- "
					@ 05, 00 VTSay PadR(STR0014+cPedAux, VTMaxCol()) // Pedido:
				ElseIf nTipo == 2
					@ 03, 00 VTSay PadR(STR0014+cPedAux, VTMaxCol()) // Pedido:
				EndIf
				WMSVTRodPe()
				Exit
			EndIf
		EndDo

	EndDo

	// Restaura teclas
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(24,bkey24,cKey24)
	VtRestore(,,,,aTela)
Return Nil
//----------------------------------------------------------
// ValidCarga
// Verifica se a carga informada é valida

// lEstorno Indica se a função foi chamada pelo processo de estorno
// cCarga   Código da carga
//----------------------------------------------------------
Static Function ValidCarga(lEstorno,cCarga)
Local lRet      := .T.
Local cAliasQry := Nil

	If Empty(cCarga)
		lRet := .F.
	EndIf

	DAK->(DbSetOrder(1))
	If lRet .And. DAK->(!DbSeek(xFilial("DAK")+cCarga))
		WmsMessage(STR0024,WMSV10202) // Carga inválida!
		lRet := .F.
	Else
		If !lEstorno
			D01->(DbSetOrder(2))
			If !D01->(dbSeek(xFilial("D01")+cCarga))
				WmsMessage(WmsFmtMsg(STR0079,{{"[VAR01]",cCarga}}),WMSV10203) // Nao existe conferencia de expedicao para a carga [VAR01].
				lRet := .F.
			Else
				// Verifica se todos os movimentos de separação já foram finalizados para a carga informada.
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT 1
					FROM %Table:DCF% DCF
					WHERE DCF.DCF_FILIAL = %xFilial:DCF%
					AND DCF.DCF_CARGA = %Exp:cCarga%
					AND DCF.DCF_STSERV = '3'
					AND DCF.%NotDel%
					AND NOT EXISTS (SELECT 1
									FROM %Table:D12% D12
									WHERE D12.D12_FILIAL = %xFilial:D12%
									AND D12.D12_IDDCF = DCF.DCF_ID
									AND D12.D12_STATUS NOT IN ('1','0')
									AND D12.%NotDel% )
				EndSql
				// Se não achar os movimentos, não deixa fazer a conferência
				If (cAliasQry)->(Eof())
					WmsMessage(STR0081,WMSV10205) // Separacao nao concluida para realizar a conferencia.
					lRet := .F.
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
	EndIf

	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------
// ValPedido
// Verifica se o pedido informado é válido
//
// nTipo       Tipo de endereçamento:
// 				1 - Carga
// 				2 - Pedido
// 				3 - NF
// lEstorno    Indica se a função foi chamada pelo processo de estorno
// cCarga      Código da carga
// cPedido     Código do pedido
//----------------------------------------------------------
Static Function ValPedido(nTipo,lEstorno,cCarga,cPedido)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local oConfExp  := Nil
Local cAliasQry := Nil
Local cAliasD04 := Nil

Local cCodOpe   := __cUserID

	If Empty(cPedido) .And. nTipo <> 1
		lRet := .F.
	EndIf

	If lRet .And. !Empty(cPedido)
		SC6->(DbSetOrder(1))
		If !(SC6->(DbSeek(xFilial('SC6')+cPedido)))
			WmsMessage(STR0028,WMSV10207) // Pedido inválido!
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If !lEstorno
			D01->(DbSetOrder(2))
			// Verifica se existe conferencia para o pedido, e força que o pedido nao tenha carga,
			// pelo contrario é preciso utilizar o menu por carga.
			If !D01->(dbSeek( xFilial("D01")+Padr(cCarga, TamSx3("D01_CARGA")[1])+cPedido ))
				WmsMessage(WmsFmtMsg(STR0082,{{"[VAR01]",cPedido}}),WMSV10208) // Nao existe conferencia de expedicao para o pedido [VAR01].
				lRet := .F.
			Else
				If lRet
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT D01_STATUS,
								D01_CODEXP
						FROM %Table:D01% D01A
						WHERE D01A.D01_FILIAL = %xFilial:D01%
						AND D01A.D01_CARGA =  %Exp:cCarga%
						AND D01A.D01_PEDIDO = %Exp:cPedido%
						AND D01A.%NotDel%
						AND D01A.D01_CODEXP = ( SELECT MAX(D01B.D01_CODEXP)
												FROM %Table:D01% D01B
												WHERE D01B.D01_FILIAL = D01A.D01_FILIAL
												AND D01B.D01_CARGA = D01A.D01_CARGA
												AND D01B.D01_PEDIDO = D01A.D01_PEDIDO
												AND D01B.%NotDel% )
					EndSql
					If (cAliasQry)->(!Eof())
						If (cAliasQry)->D01_STATUS == "3"
							WmsMessage(STR0027,WMSV10209) // Pedido já foi conferido!
							lRet := .F.
						EndIf
					Else
						(cAliasQry)->(dbCloseArea())

						// Verifica se todos os movimentos de separação já foram finalizados para a carga/pedido informado.
						cAliasQry := GetNextAlias()
						If !Empty(cCarga)
							BeginSql Alias cAliasQry
								SELECT 1
								FROM %Table:DCF% DCF
								WHERE DCF.DCF_FILIAL = %xFilial:DCF%
								AND DCF.DCF_CARGA = %Exp:cCarga%
								AND DCF.DCF_DOCTO = %Exp:cPedido%
								AND DCF.DCF_STSERV = '3'
								AND DCF.%NotDel%
								AND NOT EXISTS (SELECT 1
												FROM %Table:D12% D12
												WHERE D12_FILIAL = %xFilial:D12%
												AND D12.D12_IDDCF = DCF_ID
												AND D12.D12_STATUS NOT IN ('1','0')
												AND D12.%NotDel% )
							EndSql
						Else
							BeginSql Alias cAliasQry
								SELECT 1
								FROM %Table:DCF% DCF
								WHERE DCF.DCF_FILIAL = %xFilial:DCF%
								AND DCF.DCF_DOCTO = %Exp:cPedido%
								AND DCF.DCF_STSERV = '3'
								AND DCF.%NotDel%
								AND NOT EXISTS (SELECT 1
												FROM %Table:D12% D12
												WHERE D12_FILIAL = %xFilial:D12%
												AND D12.D12_IDDCF = DCF_ID
												AND D12.D12_STATUS NOT IN ('1','0')
												AND D12.%NotDel% )
							EndSql
						EndIf
						// Se não achar os movimentos, não deixa fazer a conferência
						If (cAliasQry)->(Eof())
							WmsMessage(STR0067,WMSV10210) // Pedido ainda não foi separado!
							lRet := .F.
						EndIf
						(cAliasQry)->(dbCloseArea())
					EndIf
				EndIf
			EndIf
		Else
			//Verifica código da expedição
			oConfExp := WMSDTCConferenciaExpedicao():New()
			oConfExp:SetCarga(cCarga)
			oConfExp:SetPedido(cPedido)
			oConfExp:SetCodExp(oConfExp:FindCodExp())
			// Verifica se existe conferência realizada para ser estornada
			cAliasD04 := GetNextAlias()
			BeginSql Alias cAliasD04
				SELECT D04.D04_PEDIDO
				FROM %Table:D04% D04
				WHERE D04.D04_FILIAL = %xFilial:D04%
				AND D04.D04_CODEXP = %Exp:oConfExp:GetCodExp()%
				AND D04.D04_CARGA = %Exp:cCarga%
				AND D04.D04_PEDIDO = %Exp:cPedido%
				AND D04.D04_QTCONF > 0
				AND D04.%NotDel%
			EndSql
			If (cAliasD04)->(Eof())
				WmsMessage(STR0066,WMSV10211) // Pedido ainda não foi conferido!
				lRet := .F.
			EndIf
			(cAliasD04)->(DbCloseArea())
			//Verifica se o operador que está estornando é o mesmo que realizou a conferência
			If lRet
				cAliasD04 := GetNextAlias()
				BeginSql Alias cAliasD04
					SELECT D04_PEDIDO
					FROM %Table:D04% D04
					WHERE D04_FILIAL = %xFilial:D04%
					AND D04.D04_CODEXP = %Exp:oConfExp:GetCodExp()%
					AND D04.D04_CARGA  = %Exp:cCarga%
					AND D04.D04_PEDIDO = %Exp:cPedido%
					AND D04.D04_CODOPE = %Exp:cCodOpe%
					AND D04.%NotDel%
				EndSql
				If (cAliasD04)->(Eof())
					WmsMessage(STR0096,WMSV10206) //Conferência realizada por outro operador. Estorne por meio do monitor.
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMSV102PRD
Verifica se o código de produto informado é válido

@param   nTipo       Tipo de endereçamento:
							1 - Carga
							2 - Pedido
							3 - NF
@param   lEstorno    Indica se a função foi chamada pelo processo de estorno
@param   cCarga      Código da carga
@param   cPedido     Código do pedido
@param   cProduto    Código do produto
@param   nQtd        Quantidade, será retornada por referência no caso
							de montagem de volumes
@param   cLoteCtl       Número de lote do produto
@param   cNumLote    Número de sublote do produto

@return  lRet  Indica se o código de produto informado é válido
@author  Evaldo Cevinscki Jr.
@version P11
@since   25/07/12 - revisão 02/10/14
/*/
//----------------------------------------------------------
Function WMSV102PRD(nTipo,lEstorno,cCarga,cPedido,cPrdOri,cProduto,nQtd,cLoteCtl,cNumLote,aVolume,cCodBar,lVolume,cCodExp)
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local oConExpItem := Nil
Local cCodOpe     := __cUserID
Local cCargaAnt   := Space(TamSX3('D01_CARGA')[1])
Local cPedAnt     := Space(TamSX3('D01_PEDIDO')[1])
Local cPrdOriAnt  := ""
Local cWhere      := ""
Local cAliasQry   := GetNextAlias()
Local cCodInfo    := cProduto
Local i           := 0
Local nPrdOri     := 0
Local nOpcao      := 1

Default lVolume   := .F.
Default aVolume   := {}
Default cCodExp   := Space(TamSX3('D01_CODEXP')[1])

	//Verifica código da expedição
	//Valida se possui distribuição de separação, apenas se já não foi validado o volume
	oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
	oConExpItem:SetCodExp(cCodExp)
	oConExpItem:SetCarga(cCarga)
	oConExpItem:SetPedido(cPedido)
	oConExpItem:SetCodExp(oConExpItem:oConfExp:FindCodExp())
	cCodExp := oConExpItem:oConfExp:GetCodExp()

	lRet := WMSValProd(Nil,@cProduto,@cLoteCtl,@cNumLote,@nQtd,@cCodBar,.T.,@aVolume)
	
	If lRet .And. Len(aVolume) == 0 .And.VldConfVol(cCarga,cPedido,lEstorno)
		WmsMessage(STR0102,WMSV10204) // Pedido com montagem de volume. Informe o volume para a conferência.
		lRet := .F.
	EndIf
	
	If lRet
		If Len(aVolume) > 0
			For i:= 1 to Len(aVolume)
				If aVolume[i][5] == cPedido  .Or. nTipo != 2
					If aVolume[i][2] < aVolume[i][3]
						WmsMessage(WmsFmtMsg(STR0029,{{"[VAR01]",AllTrim(aVolume[i][1])}}),WMSV10212) // Quantidade maior que separada! Produto: [VAR01]
	 	 				lRet := .F.
						Exit
					EndIf
					If nTipo == 1 .And. (aScan(aVolume,{|x| Alltrim(x[4]) == Alltrim(cCarga)}) == 0)
						WmsMessage(STR0083,WMSV10213) // Volume nao pertence a essa carga!
						lRet := .F.
						Exit
					EndIf

					nQtd 	 := aVolume[i][3]
					cCodInfo := aVolume[i][11]
				ElseIf (aScan(aVolume,{|x| Alltrim(x[5]) == Alltrim(cPedido)}) == 0) //Verifica 	se o volume não encontra-se no array
					WmsMessage(STR0088,WMSV10230) // Volume nao pertence a esse pedido!
					lRet := .F.
					Exit
				EndIf
				//Grava Código de Expedição da Carga/Pedido
				If lRet
					If cCargaAnt+cPedAnt <> aVolume[i][4]+aVolume[i][5]
						cCargaAnt := aVolume[i][4]
						cPedAnt   := aVolume[i][5]
						//Verifica código da expedição
						oConExpItem:oConfExp:SetCarga(aVolume[i][4])
						oConExpItem:oConfExp:SetPedido(aVolume[i][5])
						oConExpItem:oConfExp:SetCodExp(oConExpItem:oConfExp:FindCodExp())
					EndIf
					aAdd(aVolume[i],oConExpItem:oConfExp:GetCodExp())
				EndIf
			Next i

			// Verifica se o volume informado já não foi conferido
			DCU->(DbSetOrder(1)) //DCU_FILIAL+DCU_CODVOL+DCU_CODMNT
			If(DCU->(DbSeek(xFilial('DCU')+ Alltrim(cCodBar))))
				If DCU->DCU_STCONF == "2"
					If !lEstorno
						WmsMessage(STR0084,WMSV10214) // Volume ja conferido!
						lRet := .F.
						aVolume := {}
					EndIf
				ElseIf lEstorno
					WmsMessage(STR0085,WMSV10215) // Volume ainda nao conferido!
					lRet := .F.
					aVolume := {}
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet .And. Len(aVolume) == 0
		lAchou := .F.
		i := 0
		// Quando o nTipo for 1, filtrar somente pela carga e produto
		If nTipo == 1
			cWhere := "%"
			If !Empty(cPedido)
				cWhere +=   " AND D02.D02_PEDIDO = '"+cPedido+"'"
			EndIf
			cWhere += "%"
			BeginSql Alias cAliasQry
				SELECT D02.D02_PEDIDO,
						D02.D02_CODPRO,
						D02.D02_LOTE,
						D02.D02_SUBLOT,
						D02.D02_QTCONF,
						D02.D02_QTSEPA,
						D02.D02_STATUS,
						D02.D02_CODEXP,
						D02.D02_PRDORI
				FROM %Table:D02% D02
				WHERE D02.D02_FILIAL = %xFilial:D02%
				AND D02.D02_CARGA  = %Exp:cCarga%
				AND D02.D02_CODPRO = %Exp:cProduto%
				AND D02.%NotDel%
				%Exp:cWhere%
			EndSql
		Else
			cWhere := "%"
			If !Empty(cCarga)
				cWhere +=   " AND D02.D02_CARGA = '"+cCarga+"'"
			EndIf
			cWhere += "%"
			BeginSql Alias cAliasQry
				SELECT D02.D02_PEDIDO,
						D02.D02_CODPRO,
						D02.D02_LOTE,
						D02.D02_SUBLOT,
						D02.D02_QTCONF,
						D02.D02_QTSEPA,
						D02.D02_STATUS,
						D02.D02_CODEXP,
						D02.D02_PRDORI
				FROM %Table:D02% D02
				WHERE D02.D02_FILIAL = %xFilial:D02%
				AND D02.D02_PEDIDO = %Exp:cPedido%
				AND D02.D02_CODPRO = %Exp:cProduto%
				AND D02.%NotDel%
				%Exp:cWhere%
			EndSql
		EndIf
		// Percorre o resultado para verificar se existe produtos origem diferentes
		(cAliasQry)->(dbEval( {|| Iif(cPrdOriAnt!=D02_PRDORI,nPrdOri++,), cPrdOriAnt := D02_PRDORI }))
		// Pergunta o que deve considerar
		If nPrdOri > 1
			nOpcao := WMSVTAviso(STR0090,STR0091, {STR0092,STR0035}) // Conf. Expedicao // Considerar produto como: // Componente // Produto
		EndIf

		(cAliasQry)->(dbGoTop())
		While (cAliasQry)->(!Eof())
			If nPrdOri > 1
				// Quando "Componente", pula aquele que é produto
				If nOpcao == 1 .And. (cAliasQry)->D02_PRDORI == cProduto
					(cAliasQry)->(DbSkip())
					Loop
				EndIf
				// Quando "Produto", pula aquele que é componente
				If nOpcao == 2 .And. (cAliasQry)->D02_PRDORI != cProduto
					(cAliasQry)->(DbSkip())
					Loop
				EndIf
			EndIf
			cPrdOri := (cAliasQry)->D02_PRDORI
			If nTipo == 1
				cPedido := (cAliasQry)->D02_PEDIDO
				If ( QtdComp((cAliasQry)->D02_QTCONF) < QtdComp((cAliasQry)->D02_QTSEPA) ) .Or. lEstorno
					lAchou := .T.
					Exit
				EndIf
			Else
				lAchou := .T.
				Exit
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())

		If !lAchou
			WmsMessage(STR0069,WMSV10217) // Produto não pertence ao documento!
			lRet := .F.
		ElseIf lEstorno
			D04->(DbSetOrder(1))
			If !(D04->(DbSeek(xFilial('D04')+cCodExp+cCarga+cPedido+cCodOpe+cPrdOri)))
				WmsMessage(WmsFmtMsg(STR0099,{{"[VAR01]",AllTrim(cPrdOri)},{"[VAR02]",AllTrim(cCodOpe)}}),WMSV10218) // Conferência do [VAR01] não realizada por este operador [VAR02]
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If !lRet
		aVolume  := {}
		cProduto := Space(Len(D02->D02_CODPRO))
		VTKeyBoard(Chr(20))
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
// ValidaLote
// Verifica se o lote informado é válido
//
// nTipo       Tipo de endereçamento:
// 					1 - Carga
// 					2 - Pedido
// 					3 - NF
// lEstorno    Indica se a função foi chamada pelo processo de estorno
// cCarga      Código da carga
// cPedido     Código do pedido
// cProduto    Código do produto
// cLoteCtl    Código do lote
//----------------------------------------------------------
Static Function ValidaLote(nTipo,lEstorno,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cCodExp)
Local lRet    := .T.
Local cCodOpe := __cUserID

	SB8->(DbSetOrder(5))
	If !(SB8->(DbSeek(xFilial('SB8')+cPrdOri+cLoteCtl)))
		WmsMessage(STR0071,WMSV10219) // Lote inválido!
		lRet := .F.
	Else
		D02->(DbSetOrder(1))//D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE
		If !(D02->(DbSeek(xFilial('D02')+cCodExp+cCarga+cPedido+cPrdOri+cProduto+cLoteCtl)))
			WmsMessage(STR0072,WMSV10220) // Lote não pertence ao documento!
			lRet := .F.
		ElseIf lEstorno
			D04->(DbSetOrder(1)) //D04_FILIAL+D04_CODEXP+D04_CARGA+D04_PEDIDO+D04_CODOPE+D04_PRDORI+D04_CODPRO+D04_LOTE
			If !(D04->(DbSeek(xFilial('D04')+cCodExp+cCarga+cPedido+cCodOpe+cPrdOri+cProduto+cLoteCtl)))
				WmsMessage(WmsFmtMsg(STR0100,{{"[VAR01]",AllTrim(cLoteCtl)},{"[VAR02]",AllTrim(cCodOpe)}}),WMSV10221) // Conferência do lote [VAR01] não realizada por este operador [VAR02]! STR0073
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
// ValSubLote
// Verifica se o sublote informado é válido
//
// nTipo       Tipo de endereçamento:
// 					1 - Carga
// 					2 - Pedido
// 					3 - NF
// lEstorno    Indica se a função foi chamada pelo processo de estorno
// cCarga      Código da carga
// cPedido     Código do pedido
// cProduto    Código do produto
// cLoteCtl       Código do lote
// cNumLote    Código do sublote
//----------------------------------------------------------
Static Function ValSubLote(nTipo,lEstorno,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,cCodExp)
Local lRet    := .T.
Local cCodOpe := __cUserID

	SB8->(DbSetOrder(5))
	If !(SB8->(DbSeek(xFilial('SB8')+cPrdOri+cLoteCtl)))
		WmsMessage(STR0074,WMSV10222) // Sublote inválido!
		lRet := .F.
	Else
		D02->(DbSetOrder(1)) //D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE+D02_SUBLOT
		If !(D02->(DbSeek(xFilial('D02')+cCodExp+cCarga+cPedido+cPrdOri+cProduto+cLoteCtl+cNumLote)))
			WmsMessage(STR0075,WMSV10223) // Sublote não pertence ao documento!
			lRet := .F.
		ElseIf lEstorno
			D04->(DbSetOrder(1)) //D04_FILIAL+D04_CODEXP+D04_CARGA+D04_PEDIDO+D04_CODOPE+D04_PRDORI+D04_CODPRO+D04_LOTE+D04_SUBLOT
			If !(D04->(DbSeek(xFilial('D04')+cCodExp+cCarga+cPedido+cCodOpe+cPrdOri+cProduto+cLoteCtl+cNumLote)))
				WmsMessage(WmsFmtMsg(STR0101,{{"[VAR01]",AllTrim(cPrdOri)},{"[VAR02]",AllTrim(cCodOpe)}}),WMSV10224) // Conferência do sublote [VAR01] não realizada por este operador [VAR02].
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
// MontaCons
// Monta consulta de produtos na conferência de expedição
//
// nTipo    Tipo de endereçamento:
// 			1 - Carga
// 			2 - Pedido
// 			3 - NF
// cCarga   Código da carga
// cPedido  Código do pedido
//----------------------------------------------------------
Static Function MontaCons(nTipo,cCarga,cPedido)
Local lVolume   := .F.
Local aTela     := VTSave()
Local aProds    := {}
Local aArea     := GetArea()
Local bkey15    := VTSetKey(15)
Local bkey24    := VTSetKey(24)
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Local nPos      := 1

	WMSVTCabec(STR0086+STR0007, .F., .F., .T.) // Consulta // Conferencia
	If nTipo == 1 .And. Empty(cCarga) // Verifica se cCarga já foi preenchido para nao solicitar novamente
		@ 02, 00 VTSay PadR(STR0008, VTMaxCol())   // Carga
		@ 03, 00 VTGet cCarga Valid ValidCarga(.F.,cCarga) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.) .And. If(lVolume,ValPedido(nTipo,.T.,cCarga,cPedido),.T.)
		VTRead()
		If VTLastKey() == 27
			VtRestore(,,,,aTela)
			// Restaura Tecla
			VTSetKey(15,bKey15, STR0050)
			VTSetKey(24,bKey24, STR0051)
			Return
		EndIf
		// Quando for identificado que a carga toda esta em volumes não solicita o pedido, caso contrário tem que informar o pedido se tiver itens soltos
		If !lVolume
			@ 05, 00 VTSay PadR(STR0009, VTMaxCol())// Pedido
			@ 06, 00 VTGet cPedido Valid ValPedido(nTipo,.T.,cCarga,cPedido)
			VTRead()
		EndIf
	ElseIf nTipo == 2 .And. Empty(cPedido) // Verifica se cPedido já foi preenchido para nao solicitar novamente
		@ 02, 00 VTSay PadR(STR0009, VTMaxCol())   // Pedido
		@ 03, 00 VTGet cPedido Valid ValPedido(nTipo,.F.,cCarga,cPedido)
		VTRead()
	EndIf
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0050)
		VTSetKey(24,bKey24, STR0051)
		Return
	EndIf

	If nTipo == 1 .And. Empty(cCarga)
		WmsMessage(STR0023,WMSV10225) // Informe uma carga para consultar!
		VtKeyboard(Chr(20))
		Return Nil
	ElseIf nTipo == 2 .And. Empty(cPedido)
		WmsMessage(STR0031,WMSV10226) // Informe um pedido para consultar!
		VtKeyboard(Chr(20))
		Return Nil
	EndIf

	If nTipo == 1
		cWhere := "%"
		If !Empty(cPedido)
			cWhere += " AND D02_PEDIDO = '"+cPedido+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT D02.D02_CODPRO,
					D02.D02_LOTE,
					D02.D02_SUBLOT,
					D02.D02_QTCONF,
					D02.D02_STATUS
			FROM %Table:D02% D02
			WHERE D02.D02_FILIAL = %xFilial:D02%
			AND D02.D02_CARGA  = %Exp:cCarga%
			AND D02.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		cWhere := "%"
		If !Empty(cCarga)
			cWhere += " AND D02_CARGA = '"+cCarga+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT D02.D02_CODPRO,
					D02.D02_LOTE,
					D02.D02_SUBLOT,
					D02.D02_QTCONF,
					D02.D02_STATUS
			FROM %Table:D02% D02
			WHERE D02.D02_FILIAL = %xFilial:D02%
			AND D02.D02_PEDIDO  = %Exp:cPedido%
			AND D02.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	Do While (cAliasQry)->(!Eof())
		aAdd(aProds,{If((cAliasQry)->D02_STATUS <> "3","*",""),(cAliasQry)->D02_CODPRO,(cAliasQry)->D02_LOTE,(cAliasQry)->D02_SUBLOT,(cAliasQry)->D02_QTCONF})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If Len(aProds) > 0
		VTClear()
		If nTipo == 1
			@ 0,0 VtSay STR0033   // Conferencia Pedido
			@ 1,0 VtSay STR0012+cCarga+STR0013+cPedido // C.: // P.:
		ElseIf nTipo == 2
			@ 0,0 VtSay STR0033   // Conferencia Pedido
			@ 1,0 VtSay STR0014+cPedido // Pedido:
		EndIf
		nPos:=VTaBrowse(2,,,,{" ",STR0035,STR0017,STR0036,STR0037},aProds,{1,15,10,6,12})  // Produto // Lote // SubLote /-- Qtd.Conf.
		VtRestore(,,,,aTela)
	Else
		If nTipo == 1
			WmsMessage(WmsFmtMsg(STR0052,{{"[VAR01]",AllTrim(cCarga)},{"[VAR02]",AllTrim(cPedido)}}),WMSV10228) // Conferencia para a Carga: [VAR01] Pedido: [VAR02] não encontrado!
		ElseIf nTipo == 2
			WmsMessage(WmsFmtMsg(STR0054,{{"[VAR01]",AllTrim(cPedido)}}),WMSV10229) // Conferência para o Pedido: [VAR01] não encontrada!
		EndIf
		VtKeyboard(Chr(20))
	EndIf

	RestArea(aArea)

	// Restaura Tecla
	VTSetKey(15,bKey15, STR0050)
	VTSetKey(24,bKey24, STR0051)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSEST102
Tela de estorno da conferência de expedição

@param   nTipo    Tipo de endereçamento:
						1 - Carga
						2 - Pedido
						3 - NF

@author  Evaldo Cevinscki Jr.
@version P11
@since   27/07/12 - revisão 19/05/14
/*/
//----------------------------------------------------------
Function WMSEST102(nTipo)
Local lRet := .T.
Local lEsc      := .F.
Local lInicio   := .F.
Local lVolume   := .F.
Local lWMSConf  := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local aVolume   := {}
Local aTela     := VTSave()
Local aSeq      := {}
Local aAreaAnt  := GetArea()
Local bkey15    := VTSetKey(15)
Local bkey24    := VTSetKey(24)
Local cWhere    := ""
Local cAliasQry := Nil
Local cWmsUMI   := ""
Local cPrdAnt   := ""
Local cDscUM    := ""
Local cUM       := ""
Local cPictQt   := ""
Local cCarga    := Space(Len(D02->D02_CARGA))
Local cPedido   := Space(Len(D02->D02_PEDIDO))
Local cPrdOri   := Space(Len(D02->D02_PRDORI))
Local cProduto  := Space(Len(D02->D02_CODPRO))
Local cLoteCtl  := Space(Len(D02->D02_LOTE))
Local cNumLote  := Space(Len(D02->D02_SUBLOT))
Local cCodExp   := Space(Len(D02->D02_CODEXP))
Local nItem     := 0
Local nQtd      := 0
Local nOpc      := 1
Local nSeq      := 0
Local i

	While !lEsc
		cCarga    := Space(Len(D02->D02_CARGA))
		cPedido   := Space(Len(D02->D02_PEDIDO))
		VTClear()
		WMSVTCabec(STR0038, .F., .F., .T.)   // Estorna Conferencia
		If nTipo == 1
			If !Empty(cPCarga)
				cCarga := cPCarga
			EndIf
			@ 02, 00 VTSay PadR(STR0008, VTMaxCol())   // Carga
			@ 03, 00 VTGet cCarga Valid ValidCarga(.T.,cCarga) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.) .And. If(lVolume,ValPedido(nTipo,.T.,cCarga,cPedido),.T.)
			VTRead()
			If VTLastKey() == 27
				Exit
			EndIf
			If Empty(cPPedido)
				@ 04, 00 VTSay PadR(STR0009, VTMaxCol())   // Pedido
				@ 05, 00 VTGet cPedido Valid ValPedido(nTipo,.T.,cCarga,cPedido)
				VTRead()
			EndIf
		ElseIf nTipo == 2 .And. Empty(cPPedido) // Verifica se cPedido ja foi preenchido para nao solicitar novamente
			@ 02, 00 VTSay PadR(STR0009, VTMaxCol())   // Pedido
			@ 03, 00 VTGet cPedido Valid ValPedido(nTipo,.T.,@cCarga,cPedido)
			VTRead()
		EndIf

		If VTLastKey() == 27
			Exit
		EndIf

		While .T.
			cCodBar   := Space(128)
			cPrdOri   := Space(Len(D02->D02_PRDORI))
			cProduto  := Space(Len(D02->D02_CODPRO))
			cLoteCtl  := Space(Len(D02->D02_LOTE))
			cNumLote  := Space(Len(D02->D02_SUBLOT))
			nQtd      := 0
			nLin      := 1
			aSeq      := {}
			aVolume   := {}
			VTClear()
			WMSVTCabec(STR0038, .F., .F., .T.) // Estorna Conferencia
			If nTipo == 1
				If !Empty(cPCarga)
					cCarga := cPCarga
				EndIf
				If !Empty(cPPedido)
					cPedido := cPPedido
				EndIf
				@ nLin++,0 VtSay STR0012+cCarga+STR0013+cPedido    // C.: //--P.:
			ElseIf nTipo == 2
				If !Empty(cPPedido)
					cPedido := cPPedido
				EndIf
				@ nLin++, 00 VTSay PadR(STR0014+cPedido, VTMaxCol())  // Pedido:
			EndIf
			@ nLin++, 00 VTSay PadR(STR0016, VTMaxCol()) // Produto:
			@ nLin++, 00 VTGet cCodBar Picture "@!" Valid !Empty(cCodBar) .And. WMSV102PRD(nTipo,.T.,cCarga,@cPedido,@cPrdOri,@cProduto,@nQtd,@cLoteCtl,@cNumLote,@aVolume,@cCodBar,,@cCodExp)
			VTRead()
			If VTLastKey() == 27
				Exit
			EndIf

			// Solicita quantidade se não retorna valor referente a consulta de etiquetas EAN (WMSV102PRD())
			If nQtd == 0 .And. Len(aVolume) == 0
				If cProduto <> cPrdAnt .Or. lWMSConf
					// Carrega unidade de medida, simbolo da unidade e quantidade na unidade
					WmsValUM(@Nil,;         // Quantidade movimento
							@cWmsUMI,;       // Unidade parametrizada
							cProduto)        // Produto
					// Monta tela produto
					WmsMontPrd(cWmsUMI,;    // Unidade parametrizada
								.T.,;        // Indica se é uma conferência
								STR0007,;    // Descrição da tarefa
								Nil,;        // Armazem
								Nil,;        // Endereço
								cPrdOri,;    // Produto Origem
								cProduto,;   // Produto
								cLoteCtl,;   // Lote
								cNumLote)    // sub-lote

					If (VTLastKey()==27)
						Loop
					EndIf

					// Seleciona unidade de medida
					WmsSelUM(cWmsUMI,;      // Unidade parametrizada
							@cUM,;           // Unidade medida reduzida
							@cDscUM,;        // Descrição unidade medida
							Nil,;            // Quantidade movimento
							@nItem,;         // Item seleção unidade
							@cPictQt,;       // Mascara unidade medida
							Nil,;            // Quantidade no item seleção unidade
							.T.,;            // Indica se é uma conferência
							STR0007,;        // Descrição da tarefa
							Nil,;            // Armazem
							Nil,;            // Endereço
							cPrdOri,;        // Produto Origem
							cProduto,;       // Produto
							cLoteCtl,;       // Lote
							cNumLote)        // sub-lote

					If (VTLastKey()==27)
						Loop
					EndIf
					cPrdAnt := cProduto
				EndIf
				If lWmsLote .And. Rastro(cProduto)
					@ nLin, 00 VTSay PadR("Lote:"/*STR0017*/, VTMaxCol()) // Lote // Sub-Lote:
					@ nLin++, 06 VTGet cLoteCtl Picture "@!" Valid !Empty(cLoteCtl) .And. ValidaLote(nTipo,.T.,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cCodExp)
					If Rastro(cProduto,"S")
						@ nLin,   00 VTSay PadR("Sub-Lote:"/*STR0018*/, VTMaxCol()) // Sub-Lote:
						@ nLin++, 10 VTGet cNumLote Picture "@!" Valid !Empty(cNumLote) .And. ValSubLote(nTipo,.T.,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,cCodExp)
					EndIf
					VTRead()
				EndIf

				If VTLastKey() == 27
					Exit
				Else
					// Query para verificar se existe mais de uma sequência de conferência
					// para a mesma carga/pedido/produto/lote/sublote
					cWhere := "%"
					If !Empty(cLoteCtl)
						cWhere += " AND D02.D02_LOTE   = '"+cLoteCtl+"'"
					EndIf
					If !Empty(cNumLote)
						cWhere += " AND D02.D02_SUBLOT = '"+cNumLote+"'"
					EndIf
					cWhere += "%"
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SUM(D02.D02_QTCONF) AS D02_QTCONF, 
								D02.D02_CODEXP, 
								D01.D01_DATA
						FROM %Table:D02% D02
						INNER JOIN %Table:D01% D01
						ON  D01.D01_FILIAL = %xFilial:D01%
						AND D01.D01_CODEXP = D02.D02_CODEXP
						AND D01.%NotDel%
						WHERE D02.D02_FILIAL = %xFilial:D02%
						AND D02.D02_CARGA  = %Exp:cCarga%
						AND D02.D02_PEDIDO = %Exp:cPedido%
						AND D02.D02_CODEXP = %Exp:cCodExp%
						AND D02.D02_PRDORI = %Exp:cPrdOri%
						AND D02.D02_CODPRO = %Exp:cProduto%
						AND D02.D02_STATUS <> '1'
						AND D02.%NotDel%
						%Exp:cWhere%
						GROUP BY D02.D02_CODEXP,
									D01.D01_DATA
					EndSql
					If (cAliasQry)->(Eof())
						WmsMessage(STR0048,WMSV10231) // Status da conferencia nao permite estorno!
						VtKeyboard(Chr(20))
						Loop
					EndIf

					While (cAliasQry)->(!Eof())
						nSeq++
						AAdd(aSeq,{nSeq,(cAliasQry)->D02_QTCONF,(cAliasQry)->D02_CODEXP,FormatDate((cAliasQry)->D01_DATA)})
						(cAliasQry)->(DbSkip())
					EndDo
					(cAliasQry)->(DbCloseArea())
					RestArea(aAreaAnt)
				EndIf
				//Valida se o pedido já encontra-se faturado
				If A412VldFat(cCodExp,cCarga,cPedido,.T.)
					@ nLin, 00 VTSay PadR(STR0019 + cDscUM + ':', VTMaxCol())
					@ nLin+1, 00 VTGet nQtd Picture cPictQt Valid ValidaQtde(.T.,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,aSeq[nOpc,3],nQtd,cWmsUMI,nItem,cCodExp)
					VTRead()
				Else
					lRet := .F.
				EndIf

				If VTLastKey() == 27
					Exit
				EndIf
			ElseIf Len(aVolume) > 0
				lRet := .T.
				If A412VldFat(,,,.T.,aVolume[1][11])
					For i := 1 To Len(aVolume)
						If !(ValidaQtde(.T.,aVolume[i][4],aVolume[i][5],aVolume[i][10],aVolume[i][1],aVolume[i][6],'','',aVolume[i][3],'',nItem,aVolume[i][12]))//cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,aSeq[nOpc,3],nQtd,cWmsUMI,nItem,cCodExp
							lRet = .F.
							Exit
						EndIf
					Next i
				Else
					lRet := .F.
				EndIf
			EndIf

			If !lRet
				Loop
			EndIf

			If nTipo == 1
				cMsg  := STR0039+AllTrim(cCarga)+"?"   // Confirma o estorno da conferencia da Carga: "###"?
			ElseIf nTipo == 2
				If Len(aVolume) > 0
					cMsg := WmsFmtMsg(STR0097,{{"[VAR01]",AllTrim(cPedido)},{"[VAR02]",AllTrim(aVolume[1][11])}}) //Confirma o estorno da conferencia do Pedido: [VAR01] p/ Volume: [VAR02]?
				Else
					cMsg  := STR0042+AllTrim(cPedido)+STR0041+AllTrim(cProduto)+"?" // Confirma o estorno da conferencia do Pedido: "###" p/ produto:
				EndIf
			EndIf
			VTClear()
			WMSVTCabec(STR0044, .F., .F., .T.) // Atenção
			If VtYesNo(AllTrim(cMsg),STR0044)
				WMS102GrvE(cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtd,cWmsUMI,nItem,cCodExp,lInicio,aVolume)
				If lInicio
					Exit
				EndIf
			EndIf
		EndDo
	EndDo
	RestArea(aAreaAnt)
	VtRestore(,,,,aTela)
	// Restaura Tecla
	VTSetKey(15,bKey15, STR0050)
	VTSetKey(24,bKey24, STR0051)
Return Nil
//----------------------------------------------------------
// GravaDados
// Gravação da conferência de expedição
//
// cCarga      Código da carga
// cPedido     Código do pedido
// cProduto    Código do produto
// cLoteCtl       Número de lote do produto
// cNumLote    Número de sublote do produto
// nQtd        Quantidade conferida
// cWmsUMI     Conteúdo do parâmetro MV_WMSUMI
// nItem       Item escolhido no browse de unidades de medida
// nQtdNorma   Quantidade do produto na 1a.UM equivalente a uma norma
//----------------------------------------------------------
Static Function GravaDados(cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtd,cWmsUMI,nItem,aDados,nTipo,dDtIni,cHrIni,cCodExp,cStatusD01)
Local lRet       := .F.
Local lFinal     := .F.
Local lVolume    := .F.
Local aAreaAnt   := GetArea()
Local aTela      := VTSave()
Local cAliasDCU  := GetNextAlias()
Local cVolume    := ''
Local nQtdRes    := 0

	VTClear()

	D01->(DbSetOrder(1)) // D01_FILIAL+D01_CODEXP+D01_CARGA+D01_PEDIDO
	D02->(DbSetOrder(1)) // D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE+D02_SUBLOT
	D03->(DbSetOrder(1)) // D03_FILIAL+D03_CODEXP+D03_CARGA+D03_PEDIDO+D03_CODOPE
	D04->(DbSetOrder(1)) // D04_FILIAL+D04_CODEXP+D04_CARGA+D04_PEDIDO+D04_CODOPE+D04_PRDORI+D04_CODPRO+D04_LOTE+D04_SUBLOT+D04_ITEM+D04_SEQUEN
	SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	nQtdRes := nQtd
	// Converter de 2a.UM p/ 1a.UM
	If nItem == 2
		nQtdRes := ConvUm(cProduto,0,nQtd,1)
		nQtd := nQtdRes
	EndIf

	If Len(aDados) == 0
		LoadPrdConf(@aDados,nQtd,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,cCodExp)
	Else
		lVolume := .T.
		cVolume := aDados[1][11] //O código do volume é sempre o mesmo dentro do array
	EndIf

	Begin Transaction

		lRet := MntPrdConf(aDados,cCarga,cPedido,dDtIni,cHrIni,cCodExp,@cStatusD01,nTipo)
		If cStatusD01 == "3"
			lFinal := .T.
		EndIf
		//Grava status do volume como conferido
		If lRet .And. !Empty(cVolume)
			cAliasDCU := GetNextAlias()
			BeginSql Alias cAliasDCu
				SELECT DISTINCT DCU.R_E_C_N_O_ RECNODCU
				FROM %Table:DCV% DCV
				INNER JOIN %Table:D04% D04
				ON D04.D04_FILIAL = %xFilial:D04%
				AND D04.D04_PEDIDO = DCV.DCV_PEDIDO
				AND D04.D04_ITEM = DCV.DCV_ITEM
				AND D04.D04_SEQUEN = DCV.DCV_SEQUEN
				AND D04.%NotDel%
				INNER JOIN %Table:DCU% DCU
				ON DCU.DCU_FILIAL = %xFilial:DCU%
				AND DCU.DCU_CODVOL = DCV.DCV_CODVOL
				AND DCU.DCU_CODMNT = DCV.DCV_CODMNT
				AND DCU.%NotDel%
				WHERE DCV.DCV_FILIAL = %xFilial:DCV%
				AND DCV.DCV_CODVOL = %Exp:cVolume%
				AND DCV.%NotDel%
			EndSql
			Do While (cAliasDCU)->(!EoF())
				DCU->(dbGoTo((cAliasDCU)->RECNODCU))
					RecLock('DCU',.F.)
					DCU->DCU_STCONF := "2"
					DCU->(MsUnlock())
				(cAliasDCU)->(dbSkip())
			EndDo
			(cAliasDCU)->(dbCloseArea())
		EndIf
	End Transaction
	//nTipo == 1 e lFinal, precisa analisar se toda a carga já esta conferida
	If nTipo == 1 .And. lFinal
		lFinal := ValConfCar(cCarga)
	EndIf

	VtRestore(,,,,aTela)

	RestArea(aAreaAnt)
	aDados := {}
	If VTLastKey() == 27
		Return lRet
	EndIf
Return lFinal
//----------------------------------------------------------
// WMS102GrvE
// Gravação do estorno da conferência
//
// cCarga      Código da carga
// cPedido     Código do pedido
// cProduto    Código do produto
// cLoteCtl       Número de lote do produto
// cNumLote    Número de sublote do produto
// nQtde       Quantidade conferida
// cWmsUMI     Conteúdo do parâmetro MV_WMSUMI
// nItem       Item escolhido no browse de unidades de medida
// nQtdNorma   Quantidade do produto na 1a.UM equivalente a uma norma
// cIDDCF      Sequência identificadora da ordem de serviço
// lInicio     Indica que estornou a conferência de todo o documento,
// 					retornando ao início do processo
//----------------------------------------------------------
Function WMS102GrvE(cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtde,cWmsUMI,nItem,cCodExp,lInicio,aDados)
Local aAreaAnt  := GetArea()
Local cWhere    := ''
Local cAliasQry := Nil
Local cAliasD02 := Nil
Local cAliasD03 := Nil
Local cAliasDCU := Nil
Local cAliasSC9 := Nil
Local cVolume   := IIF(Len(aDados) == 0, '', aDados[1][11])
Local cLibEst   := ""
Local i         := 1
Local nQtd      := 0
Local nQtdEst   := 0

	lInicio   := .F.

	nQtd := nQtde
	If nItem == 2
		nQtd := ConvUm(cProduto,0,nQtde,1)
	EndIf

	If Len(aDados) == 0
		LoadPrdEst(@aDados,nQtd,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,cCodExp,cLibEst)
	EndIf

	cLibEst := Posicione("D01",1,xFilial("D01")+aDados[1,12]+aDados[1,4]+aDados[1,5],"D01_LIBEST")

	Begin Transaction

		For i:= 1 to Len(aDados)
			aSize(aDados[i],12)
			cCarga  := aDados[i][4]
			cPedido := aDados[i][5]
			cPrdOri := aDados[i][10]
			cProduto:= aDados[i][1]
			cLoteCtl:= aDados[i][6]
			cNumLote:= aDados[i][7]
			nQtd    := aDados[i][3]
			cCodExp := aDados[i][12]
			
			cWhere := "%"
			If cPrdOri == cProduto
				cWhere += " AND D04.D04_PRDORI = '"+cPrdOri+"'"
			Else
				cWhere += " AND D04.D04_CODPRO = '"+cProduto+"'"
			EndIf
			If !Empty(cLoteCtl)
				cWhere += " AND D04.D04_LOTE = '"+cLoteCtl+"'"
			EndIf
			If !Empty(cNumLote)
				cWhere += " AND D04.D04_SUBLOT = '"+cNumLote+"'"
			EndIf
			cWhere += "%"
			cAliasQry := GetNextAlias()
			If cLibEst == "2"
				// Se não permite estorno de itens faturados
				// Desconsidera as sequencias que existem pedidos faturados
				BeginSql Alias cAliasQry
					SELECT D04.D04_LOTE,
							D04.D04_SUBLOT,
							D04.D04_CODOPE,
							D04.R_E_C_N_O_ AS RECNOD04
					FROM %Table:D04% D04
					WHERE D04.D04_FILIAL = %xFilial:D04%
					AND D04.D04_CODEXP = %Exp:cCodExp%
					AND D04.D04_CARGA = %Exp:cCarga%
					AND D04.D04_PEDIDO = %Exp:cPedido%
					AND D04.%NotDel%
					%Exp:cWhere%
					AND NOT EXISTS (SELECT 1
									FROM %Table:SC9% SC9
									WHERE SC9.C9_FILIAL = %xFilial:SC9%
									AND SC9.C9_PEDIDO = D04.D04_PEDIDO
									AND SC9.C9_ITEM = D04.D04_ITEM
									AND SC9.C9_SEQUEN = D04.D04_SEQUEN
									AND SC9.C9_PRODUTO = D04.D04_PRDORI
									AND SC9.C9_NFISCAL <> '  '
									AND SC9.%NotDel% )
					ORDER BY D04.D04_SEQUEN,
								D04.D04_CODPRO
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT D04.D04_LOTE,
							D04.D04_SUBLOT,
							D04.D04_CODOPE,
							D04.R_E_C_N_O_ AS RECNOD04
					FROM %Table:D04% D04
					WHERE D04.D04_FILIAL = %xFilial:D04%
					AND D04.D04_CODEXP = %Exp:cCodExp%
					AND D04.D04_CARGA = %Exp:cCarga%
					AND D04.D04_PEDIDO = %Exp:cPedido%
					AND D04.%NotDel%
					%Exp:cWhere%
				EndSql
			EndIf
			// É preciso trabalhar desta forma para quando os produtos possuem rastro,
			// porém o sistema está parametrizado para não solicitar confirmação de lote
			// nas operações via coletor (parâmetro MV_WMSLOTE = .F.)
			Do While (cAliasQry)->(!Eof()) .And. QtdComp(nQtd) > 0
				D04->(DbGoTo((cAliasQry)->RECNOD04))
				cProduto := D04->D04_CODPRO

				If nQtd > D04->D04_QTCONF
					nQtdEst := D04->D04_QTCONF
				Else
					nQtdEst := nQtd
				EndIf
				nQtd -= nQtdEst

				// Trata o bloqueio WMS na liberação do pedido
				cAliasSC9 := GetNextAlias()
				BeginSql Alias cAliasSC9
					SELECT SC9.R_E_C_N_O_ RECNOSC9
					FROM %Table:D04% D04
					INNER JOIN %Table:D01% D01
					ON D01.D01_FILIAL = %xFilial:D01%
					AND D01.D01_CODEXP = D04.D04_CODEXP
					AND D01.D01_CARGA = D04.D04_CARGA
					AND D01.D01_PEDIDO = D04.D04_PEDIDO
					AND D01.D01_LIBPED IN ('3','4')
					AND D01.%NotDel%
					INNER JOIN %Table:SC9% SC9
					ON SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_PEDIDO = D04.D04_PEDIDO
					AND SC9.C9_ITEM = D04.D04_ITEM
					AND SC9.C9_SEQUEN  = D04.D04_SEQUEN
					AND SC9.C9_PRODUTO = D04.D04_PRDORI
					AND SC9.C9_BLWMS = '05'
					AND SC9.C9_NFISCAL = '  '
					AND SC9.%NotDel%
					WHERE D04.D04_FILIAL = %xFilial:D04%
					AND D04.D04_CODEXP = %Exp:cCodExp%
					AND D04.D04_CARGA = %Exp:cCarga%
					AND D04.D04_PEDIDO = %Exp:cPedido%
					AND D04.D04_CODPRO = %Exp:cProduto%
					AND D04.D04_PRDORI = %Exp:cPrdOri%
					AND D04.%NotDel%
				EndSql
				Do While (cAliasSC9)->(!Eof())
					SC9->(DbGoTo((cAliasSC9)->RECNOSC9))
					RecLock("SC9",.F.)
					SC9->C9_BLWMS := "01"
					SC9->(MsUnlock())
					(cAliasSC9)->(dbSkip())
				EndDo
				(cAliasSC9)->(dbCloseArea())

				If D04->D04_QTCONF == nQtdEst
					RecLock("D04",.F.)
					D04->(DbDelete())
					D04->(MsUnlock())
				Else
					RecLock("D04",.F.)
					D04->D04_QTCONF -= nQtdEst
					D04->(MsUnlock())
				EndIf

				// Se não existir mais nenhum registro referente ao operador na de conferência, apaga registro da D03
				cAliasD03 := GetNextAlias()
				BeginSql Alias cAliasD03
					SELECT D03.R_E_C_N_O_ RECNOD03
					FROM %Table:D03% D03
					WHERE D03.D03_FILIAL = %xFilial:D03%
					AND D03.D03_CODEXP = %Exp:cCodExp%
					AND D03.D03_CARGA  = %Exp:cCarga%
					AND D03.D03_PEDIDO = %Exp:cPedido%
					AND D03.D03_CODOPE = %Exp:(cAliasQry)->D04_CODOPE%
					AND NOT EXISTS (SELECT 1
									FROM %Table:D04% D04
									WHERE D04.D04_FILIAL = %xFilial:D04%
									AND D04.D04_CODEXP = D03.D03_CODEXP
									AND D04.D04_CARGA = D03.D03_CARGA
									AND D04.D04_PEDIDO = D03.D03_PEDIDO
									AND D04.D04_CODOPE = D03.D03_CODOPE
									AND D04.%NotDel% )
					AND D03.%NotDel%
				EndSql
				If (cAliasD03)->(!EoF())
					D03->(dbGoTo((cAliasD03)->RECNOD03))
					RecLock("D03",.F.)
					D03->(DbDelete())
					D03->(MsUnlock())
				EndIf
				(cAliasD03)->(dbCloseArea())

				// Atualiza produtos na conferência de carga/pedido
				cAliasD02 := GetNextAlias()
				BeginSql Alias cAliasD02
					SELECT R_E_C_N_O_ RECNOD02,
							D02_QTCONF
					FROM %Table:D02% D02
					WHERE D02.D02_FILIAL = %xFilial:D02%
					AND D02.D02_CODEXP = %Exp:cCodExp%
					AND D02.D02_CARGA = %Exp:cCarga%
					AND D02.D02_PEDIDO = %Exp:cPedido%
					AND D02.D02_PRDORI = %Exp:cPrdOri%
					AND D02.D02_CODPRO = %Exp:cProduto%
					AND D02.D02_LOTE = %Exp:(cAliasQry)->D04_LOTE%
					AND D02.D02_SUBLOT = %Exp:(cAliasQry)->D04_SUBLOT%
					AND D02.%NotDel%
				EndSql
				If (cAliasD02)->(!EoF())
					D02->(dbGoto((cAliasD02)->RECNOD02))
					RecLock("D02",.F.)
					D02->D02_QTCONF -= nQtdEst
					D02->D02_STATUS := IIF(D02->D02_QTCONF == 0,"1","2")
					D02->(MsUnlock())
				EndIf
				(cAliasD02)->(dbCloseArea())

				// Calcula qtd estornada do produto pai
				If cPrdOri <> cProduto
					CalcConfExp(1,cCodExp,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote)
					CalcConfExp(2,cCodExp,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote)
				Else
					CalcConfExp(2,cCodExp,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote)
					// Realiza o estorno das partes quando foi conferido o pai
					//CalcQtdPart(.T.,cCodExp,cCarga,cPedido,cPrdOri,cLoteCtl,cNumLote,nQtdEst)
				EndIf

				// Carrega o status da conferência dos produtos para verificar se
				// existe algum registro que esteja conferido total ou parcialmente,
				// para com base nesta informação atualizar a tabela de documentos
				// na conferência de carga/pedido
				cAliasD02 := GetNextAlias()
				BeginSql Alias cAliasD02
					SELECT D02.R_E_C_N_O_ RECNOD02
					FROM %Table:D02% D02
					WHERE D02.D02_FILIAL = %xFilial:D02%
					AND D02.D02_CODEXP = %Exp:cCodExp%
					AND D02.D02_CARGA = %Exp:cCarga%
					AND D02.D02_PEDIDO = %Exp:cPedido%
					AND D02.D02_STATUS IN ('2','3')
					AND D02.%NotDel%
				EndSql
				If (cAliasD02)->(!EoF())
					lInicio := .F.
				EndIf
				(cAliasD02)->(dbCloseArea())
				// Atualiza Quantidade conferida da D01 e status
				CalcQtdD01(cCodExp,cCarga,cPedido,/*cStatusD01*/,/*cLibPed*/)
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		Next i
		// Busca código do volume para voltar o status para "1" caso tudo tenha sido estornado
		If Empty(cVolume)
			// Verifica se existe volume conferido para carga/pedido
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT DCU.R_E_C_N_O_ RECNODCU
				FROM %Table:DCU% DCU
				WHERE DCU.DCU_FILIAL = %xFilial:DCU%
				AND DCU.DCU_CARGA  = %Exp:cCarga%
				AND DCU.DCU_PEDIDO = %Exp:cPedido%
				AND DCU.DCU_STCONF = '2'
				AND DCU.%NotDel%
				AND EXISTS (SELECT 1"
							FROM %Table:DCS% DCS
							WHERE DCS.DCS_FILIAL = %xFilial:DCS%
							AND DCS.DCS_CODMNT = DCU.DCU_CODMNT
							AND DCS.DCS_CARGA = DCU.DCU_CARGA
							AND DCS.DCS_PEDIDO = DCU.DCU_PEDIDO
							AND DCS.DCS_STATUS <> '1'
							AND DCS.%NotDel% )
				// Verifica se ainda existe algum DCV que está conferido
				AND NOT EXISTS (SELECT 1
								FROM %Table:DCV% DCV
								WHERE DCV.DCV_FILIAL = %xFilial:DCV%
								AND DCV.DCV_CODVOL = DCU.DCU_CODVOL
								AND DCV.%NotDel%
								AND EXISTS (SELECT 1
											FROM %Table:D04% D04
											WHERE D04.D04_FILIAL = %xFilial:D04%
											AND D04.D04_CARGA = DCV.DCV_CARGA
											AND D04.D04_PEDIDO = DCV.DCV_PEDIDO
											AND D04.D04_PRDORI = DCV.DCV_PRDORI
											AND D04.D04_CODPRO = DCV.DCV_CODPRO
											AND D04.D04_LOTE = DCV.DCV_LOTE
											AND D04.D04_SUBLOT = DCV.DCV_SUBLOT
											AND D04.D04_ITEM = DCV.DCV_ITEM
											AND D04.D04_SEQUEN = DCV.DCV_SEQUEN
											AND D04.%NotDel% ))
			EndSql
			Do While (cAliasQry)->(!Eof())

				DCU->(dbGoTo((cAliasQry)->RECNODCU))
				RecLock("DCU",.F.)
				DCU->DCU_STCONF := '1' //Não Conferido
				DCU->(MsUnlock())

				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

		Else //Atualiza Status da conferência, em caso de estorno por volume
			cAliasDCU := GetNextAlias()
			BeginSql Alias cAliasDCU
				SELECT DCU.R_E_C_N_O_ RECNODCU
				FROM %Table:DCU% DCU
				WHERE DCU.DCU_FILIAL = %xFilial:DCU%
				AND DCU.DCU_CODVOL = %Exp:cVolume%
				AND DCU.DCU_STCONF = '2'
				AND DCU.%NotDel%
			EndSql
			Do While (cAliasDCU)->(!EoF())
				DCU->(dbGoTo((cAliasDCU)->RECNODCU))
				RecLock("DCU",.F.)
				DCU->DCU_STCONF := '1' //Não Conferido
				DCU->(MsUnlock())
				(cAliasDCU)->(dbSkip())
			EndDo
			(cAliasDCU)->(dbCloseArea())
		EndIf
	End Transaction
	aDados := {}
	RestArea(aAreaAnt)
Return
//----------------------------------------------------------
// ValidaQtde
// Validação de quantidade informada na conferência
//
// lEstorno    Indica se a função foi chamada pelo processo de estorno
// cCarga      Código da carga
// cPedido     Código do pedido
// cProduto    Código do produto
// cLoteCtl       Número de lote do produto
// cNumLote    Número de sublote do produto
// cIdDCF      Sequência identificadora da ordem de serviço
// nQtde       Quantidade informada na conferência
// cWmsUMI     Conteúdo do parâmetro MV_WMSUMI
// nItem       Item escolhido no browse de unidades de medida
// nQtdNorma   Quantidade do produto na 1a.UM equivalente a uma norma
//----------------------------------------------------------
Static Function ValidaQtde(lEstorno,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,cIdDCF,nQtde,cWmsUMI,nItem,cCodExp)
Local lRet      := .T.
Local lValDisSep:= .T.
Local aAreaAnt  := GetArea()
Local cCodOpe   := __cUserID
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Local nQuant    := 0
Local nToler1UM := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0)) // Quantidade de tolerância para cálculos com a 1UM. Usado quando o fator de conversão gera um dízima periódica
Local nQtdAux   := 0
Default cIdDCF := ""

	If Empty(nQtde)
		Return .F.
	EndIf
	nQuant := nQtde
	If nItem == 2
		nQuant := ConvUm(cProduto,0,nQtde,1)
	EndIf
	If lEstorno
		// É preciso utilizar o SUM para quando os produtos possuem rastro, porém
		// o sistema está parametrizado para não solicitar confirmação de lote
		// nas operações via coletor (parâmetro MV_WMSLOTE = .F.)
		cWhere := "%"
		If cProduto == cPrdOri
			cWhere += " AND D04.D04_PRDORI = '"+cPrdOri+"'"
		Else
			cWhere += " AND D04.D04_CODPRO = '"+cProduto+"'"
		EndIf
		If !Empty(cLoteCtl)
			cWhere += " AND D04.D04_LOTE = '"+cLoteCtl+"'"
		EndIf
		If !Empty(cNumLote)
			cWhere += " AND D04.D04_SUBLOT = '"+cNumLote+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT D04.D04_CODPRO,
					SUM(D04.D04_QTCONF) AS D04_QTCONF,
					CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END D11_QTMULT
			FROM %Table:D04% D04
			LEFT JOIN %Table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D04.D04_FILIAL = %xFilial:D04%
			AND D11.D11_PRDORI = D04.D04_PRDORI
			AND D11.D11_PRDCMP = D04.D04_CODPRO
			AND D11.%NotDel%
			WHERE D04.D04_FILIAL = %xFilial:D04%
			AND D04.D04_CODEXP = %Exp:cCodExp%
			AND D04.D04_CARGA  = %Exp:cCarga%
			AND D04.D04_PEDIDO = %Exp:cPedido%
			AND D04.D04_CODOPE = %Exp:cCodOpe%
			AND D04.%NotDel%
			%Exp:cWhere%
			GROUP BY D04.D04_CODPRO,
						D11.D11_QTMULT
			ORDER BY D04.D04_CODPRO
		EndSql
		Do While (cAliasQry)->(!Eof())
			If cProduto == cPrdOri
				nQtdAux := (nQuant * (cAliasQry)->D11_QTMULT)
			EndIf

			If QtdComp(nQtdAux) > QtdComp((cAliasQry)->D04_QTCONF) .And.;
				QtdComp(Abs((cAliasQry)->D04_QTCONF - nQtdAux)) > QtdComp(nToler1UM)
				WmsMessage(STR0049,WMSV10233) // Quantidade maior que conferida!
				lRet := .F.
				Exit
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	Else
		// É preciso utilizar o SUM para quando os produtos possuem rastro, porém
		// o sistema está parametrizado para não solicitar confirmação de lote
		// nas operações via coletor (parâmetro MV_WMSLOTE = .F.)
		cWhere := "%"
		If !Empty(cLoteCtl)
			cWhere += " AND D02.D02_LOTE = '"+cLoteCtl+"'"
		EndIf
		If !Empty(cNumLote)
			cWhere += " AND D02.D02_SUBLOT = '"+cNumLote+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT SUM(D02.D02_QTSEPA) D02_QTSEPA,
					SUM(D02.D02_QTCONF) D02_QTCONF
			FROM %Table:D02% D02
			WHERE D02.D02_FILIAL = %xFilial:D02%
			AND D02.D02_CODEXP = %Exp:cCodExp%
			AND D02.D02_CARGA = %Exp:cCarga%
			AND D02.D02_PEDIDO = %Exp:cPedido%
			AND D02.D02_PRDORI = %Exp:cPrdOri%
			AND D02.D02_CODPRO = %Exp:cProduto%
			AND D02.%NotDel%
			%Exp:cWhere%
		EndSql
		If (cAliasQry)->(!Eof())
			If QtdComp((cAliasQry)->D02_QTCONF + nQuant) > QtdComp((cAliasQry)->D02_QTSEPA) .And.;
				QtdComp(Abs((cAliasQry)->D02_QTSEPA - ((cAliasQry)->D02_QTCONF + nQuant))) > QtdComp(nToler1UM)
				WmsMessage(WmsFmtMsg(STR0029,{{"[VAR01]",AllTrim(cProduto)}}),WMSV10232) // Quantidade maior que separada! // Aviso
				lRet := .F.
			EndIf
			If lRet .And. Rastro(cProduto) .And. !lWmsLote
				lValDisSep := .F.
			EndIf
			// Valida se a distribuição foi efetuada para o produto
			If lRet .And. lValDisSep .And. !VldVolDis(cCodExp,cCarga,cPedido,cPrdori,cProduto,cLoteCtl,cNumLote,nQtde)
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
// FormatDate
// Formata string contendo data no formato aaaammdd em dd/mm/aaaa

// cData    String contendo a data no formato aaaammdd
//----------------------------------------------------------
Static Function FormatDate(cData)
Local cDia  := ''
Local cMes  := ''
Local cAno  := ''
	cDia := SubStr(cData, 7, 2)
	cMes := SubStr(cData, 5, 2)
	cAno := SubStr(cData, 1, 4)
	cData := cDia + '/' + cMes  + '/' + cAno
Return cData
//----------------------------------------------------------
// ValConfCar
// Verifica se a carga toda ja foi conferida
//----------------------------------------------------------
Static Function ValConfCar(cCarga)
Local cAliasSC9  := GetNextAlias()
	//verifica se tudo que foi conferido bate com o total liberado do pedido
	BeginSql Alias cAliasSC9
		SELECT DISTINCT SUM(SC9.C9_QTDLIB) SUM_QTDLIB,
				D01.D01_QTCONF
		FROM %Table:SC9% SC9
		INNER JOIN %Table:D01% D01
		ON D01.D01_FILIAL = %xFilial:D01%
		AND D01.D01_CARGA = SC9.C9_CARGA
		AND D01.D01_PEDIDO = SC9.C9_PEDIDO
		AND D01.D01_QTSEPA > 0
		AND D01.%NotDel%
		WHERE SC9.C9_FILIAL = %xFilial:SC9%
		AND SC9.C9_CARGA  = %Exp:cCarga%
		AND SC9.C9_QTDLIB > 0
		AND SC9.%NotDel%
		GROUP BY D01.D01_QTCONF
	EndSql
	lFinal := (QtdComp((cAliasSC9)->SUM_QTDLIB) == QtdComp((cAliasSC9)->D01_QTCONF))
Return lFinal

// Calcula qtd conf. do produto pai
Static Function CalcConfExp(nAcao,cCodExp,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote)
Local lRet      := .T.
Local aTamSx3   := TamSx3("D02_QTSEPA")
Local aAreaAnt  := GetArea()
Local cAliasD02 := Nil
Local cAliasQry := Nil

Default nAcao := 1
	// ----------nAcao-----------
	// Totalizador dos itens da conferencia
	nTotSepa := 0
	nTotConf := 0

	cAliasD02 := GetNextAlias()
	If nAcao == 1
		BeginSql Alias cAliasD02
			SELECT MIN(D02.D02_QTSEPA / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D02_QTSEPA,
					MIN(D02.D02_QTCONF / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D02_QTCONF
			FROM %Table:D02% D02
			LEFT JOIN %Table:D11% D11
			ON D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDORI = D02.D02_PRDORI
			AND D11.D11_PRDCMP = D02.D02_CODPRO
			AND D11.%NotDel%
			WHERE D02.D02_FILIAL = %xFilial:D02%
			AND D02.D02_CARGA = %Exp:cCarga%
			AND D02.D02_PEDIDO = %Exp:cPedido%
			AND D02.D02_CODEXP = %Exp:cCodExp%
			AND D02.D02_PRDORI = %Exp:cPrdOri%
			AND D02.D02_LOTE = %Exp:cLoteCtl%
			AND D02.D02_SUBLOT = %Exp:cNumLote%
			AND D02.D02_PRDORI <> D02.D02_CODPRO
			AND D02.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasD02
			SELECT SUM(D02.D02_QTSEPA) D02_QTSEPA,
					SUM(D02.D02_QTCONF) D02_QTCONF
			FROM %Table:D02% D02
			WHERE D02.D02_FILIAL = %xFilial:D02%
			AND D02.D02_CARGA = %Exp:cCarga%
			AND D02.D02_PEDIDO = %Exp:cPedido%
			AND D02.D02_CODEXP = %Exp:cCodExp%
			AND D02.D02_PRDORI = %Exp:cPrdOri%
			AND D02.D02_LOTE = %Exp:cLoteCtl%
			AND D02.D02_SUBLOT = %Exp:cNumLote%
			AND D02.D02_PRDORI = D02.D02_CODPRO
			AND D02.%NotDel%
		EndSql
	EndIf	
	TcSetField(cAliasD02,'D02_QTSEPA','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD02,'D02_QTCONF','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD02)->(!Eof())
		//Posiciona no produto pai e grava a quantidade conferida
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D02.R_E_C_N_O_ RECNOD02,
					D02.D02_QTCONF
			FROM %Table:D02% D02
			WHERE D02_FILIAL = %xFilial:D02%
			AND D02.D02_CODEXP = %Exp:cCodExp%
			AND D02.D02_CARGA = %Exp:cCarga%
			AND D02.D02_PEDIDO = %Exp:cPedido%
			AND D02.D02_PRDORI = %Exp:cPrdOri%
			AND D02.D02_CODPRO = %Exp:cPrdOri%
			AND D02.D02_LOTE = %Exp:cLoteCtl%
			AND D02.D02_SUBLOT = %Exp:cNumLote%
			AND D02.%NotDel%
		EndSql
		If (cAliasQry)->(!EoF())
			D02->(dbGoTo((cAliasQry)->RECNOD02))
			RecLock('D02',.F.)
			D02->D02_QTCONF := Int((cAliasD02)->D02_QTCONF)
			If nAcao == 1
				D02->D02_STATUS := Iif((cAliasD02)->D02_QTSEPA == (cAliasD02)->D02_QTCONF,'3',Iif((cAliasD02)->D02_QTCONF == 0,'1','2'))
			Else
				D02->D02_STATUS := Iif((cAliasD02)->D02_QTCONF == 0,'1','2')
			EndIf
			D02->(MsUnlock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	Else
		lRet := .F.
	EndIf
	(cAliasD02)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------
// Verifica se o produto possui volume ou distribuição realizada
//------------------------------------------------------------------
Static Function VldVolDis(cCodExp,cCarga,cPedido,cPrdori,cProduto,cLoteCtl,cNumLote,nQtConf)
Local lRet        := .T.
Local oConExpItem := Nil
Local oDisSepItem := Nil
Local oProdComp   := Nil
Local aCofExp     := {}
Local aDisSep     := {}
Local nQtdOriCof  := 0
Local nQtdDis     := 0
Local nQtdOri     := 0
Local nQtdSDi     := 0
Local nQtdMult    := 0
Local nQtConfAux  := 0
Local nI          := 0
Local cProdutAux  := ""
Local cPrdOriAux  := ""

Default cCodExp := Space(TamSX3("D01_CODEXP")[1])
Default cCarga  := Space(TamSX3("DCT_CARGA")[1])
Default cPedido := Space(TamSX3("DCT_PEDIDO")[1])
Default cPrdOri := Space(TamSX3("DCT_PRDORI")[1])
Default cProduto:= Space(TamSX3("DCT_CODPRO")[1])
Default cLoteCtl:= Space(TamSX3("DCT_LOTE")[1])
Default cNumLote:= Space(TamSX3("DCT_SUBLOT")[1])
Default nQtConf    := 0

	oProdComp := WMSDTCProdutoComponente():New()
	oProdComp:SetPrdOri(cPrdori)
	oProdComp:SetProduto(cProduto)
	oProdComp:EstProduto()
	aProduto := oProdComp:GetArrProd()
	For nI := 1 To Len(aProduto)
		cProdutAux := aProduto[nI][1]
		cPrdOriAux := aProduto[nI][3]
		nQtdMult   := aProduto[nI][2]
		nQtConfAux := nQtConf * nQtdMult

		If QtdComp(nQtConf) > QtdComp(0)
			//Valida se possui distribuição de separação, apenas se já não foi validado o volume
			oConExpItem := WMSDTCConferenciaExpedicaoItens():New()
			oConExpItem:SetCodExp(cCodExp)
			oConExpItem:SetCarga(cCarga)
			oConExpItem:SetPedido(cPedido)
			oConExpItem:SetPrdOri(cPrdOriAux)
			oConExpItem:SetProduto(cProdutAux)
			oConExpItem:SetLoteCtl(cLoteCtl)
			oConExpItem:SetNumLote(cNumLote)
			// Busca quantidade origem
			aCofExp   := oConExpItem:CalcQtdCof()
			nQtdOriCof := aCofExp[1] // Quantidade total original
			nQtdConfer := aCofExp[2] // Quantidade total conferida
			If QtdComp(nQtdOriCof) > QtdComp(0)
				oDisSepItem := WMSDTCDistribuicaoSeparacaoItens():New()
				//Valida se possui distribuição de separação, apenas se já não foi validado o volume
				oDisSepItem:SetCarga(cCarga)
				oDisSepItem:SetPedido(cPedido)
				oDisSepItem:SetPrdOri(cPrdOriAux)
				oDisSepItem:SetProduto(cProdutAux)
				oDisSepItem:SetLoteCtl(cLoteCtl)
				oDisSepItem:SetNumLote(cNumLote)
				// Busca quantidade sumarizada da distribuição de separação
				aDisSep := oDisSepItem:ChkQtdDis(oConExpItem:GerAIdDCF())
				nQtdOri := aDisSep[1] // Quantidade original de montagens de volume com distribuição de separação
				nQtdDis := aDisSep[2] - nQtdConfer // Quantidade distribuida
				nQtdSDi := nQtdOriCof - nQtdOri // Calcula a diferença entre a quantidade a conferir e a distribuir.
				If QtdComp(nQtdOri) > QtdComp(0) .And. QtdComp(nQtConfAux) > QtdComp(nQtdDis+nQtdSDi)
					WmsMessage(WmsFmtMsg(STR0093,{{"[VAR01]",cProdutAux}}),WMSV10227) // Quantidade do produto [VAR01] da conferência não possui distribuição de separação, primeiro realize a distribuição!
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Next nI
Return lRet
/*------------------------------------------------------------
---CalcQtdPart
---Calcula a quantidade das partes com base no pai conferido
---felipe.m 29/01/2015
------------------------------------------------------------*/
/*Static Function CalcQtdPart(lEstorno,cCodExp,cCarga,cPedido,cPrdOri,cLoteCtl,cNumLote,nQtde)
Local oProdComp := WMSDTCProdutoComponente():New()
Local nPosComp  := 0
Local cAliasD02 := Nil

	oProdComp:SetPrdOri(cPrdOri)
	If oProdComp:LoadData(3)
		oProdComp:EstProduto()

		cAliasD02 := GetNextAlias()
		BeginSql Alias cAliasD02
			SELECT D02.R_E_C_N_O_ RECNOD02,
					D02.D02_CODPRO
			FROM %Table:D02% D02
			WHERE D02.D02_FILIAL = %xFilial:D02%
			AND D02.D02_CODEXP = %Exp:cCodExp%
			AND D02.D02_CARGA = %Exp:cCarga%
			AND D02.D02_PEDIDO = %Exp:cPedido%
			AND D02.D02_PRDORI = %Exp:cPrdOri%
			AND D02.D02_CODPRO <> D02_PRDORI
			AND D02.D02_LOTE = %Exp:cLoteCtl%
			AND D02.D02_SUBLOT = %Exp:cNumLote%
			AND D02.%NotDel%
		EndSql
		Do While (cAliasD02)->(!EoF())
			nPosComp := aScan(oProdComp:GetArrProd(),{|x| x[1] == (cAliasD02)->D02_CODPRO })

			D02->(dbGoTo((cAliasD02)->RECNOD02))
			RecLock("D02",.F.)
			If lEstorno
				D02->D02_QTCONF -= nQtde * oProdComp:GetArrProd()[nPosComp][2] // Multiplica a quantidade conferia pelo multiplo do produto
				D02->D02_STATUS := Iif(D02->D02_QTCONF == 0,'1','2')
			Else
				D02->D02_QTCONF += nQtde * oProdComp:GetArrProd()[nPosComp][2]
				D02->D02_STATUS := Iif(D02->(D02_QTORIG == D02_QTCONF),'3','2') // Atualiza o status com base na quantidade conferida
			EndIf
			D02->(MsUnlock())
			(cAliasD02)->(dbSkip())
		EndDo
		(cAliasD02)->(dbCloseArea())
	EndIf
Return Nil*/

Static Function CalcQtdD01(cCodExp,cCarga,cPedido,cStatusD01,cLibPed)
Local aAreaAnt  := GetArea()
Local aTamSx3   := TamSx3("D02_QTCONF")
Local cAliasD02 := Nil
Local cAliasD01 := Nil
Local cAliasQry := Nil
Local cStatus   := ""
	//Soma quantidade conferida do documento
	cAliasD02 := GetNextAlias()
	BeginSql Alias cAliasD02
		SELECT SUM(D02.D02_QTCONF) D02_QTCONF
		FROM %Table:D02% D02
		WHERE D02.D02_FILIAL = %xFilial:D02%
		AND D02.D02_CODEXP = %Exp:cCodExp%
		AND D02.D02_CARGA = %Exp:cCarga%
		AND D02.D02_PEDIDO = %Exp:cPedido%
		AND D02.D02_CODPRO = D02.D02_PRDORI
		AND D02.%NotDel%
	EndSql
	TcSetField(cAliasD02,'D02_QTCONF','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD02)->(!Eof())
		//Altera status do documento
		cAliasD01 := GetNextAlias()
		BeginSql Alias cAliasD01
			SELECT D01.R_E_C_N_O_ RECNOD01
			FROM %Table:D01% D01
			WHERE D01.D01_FILIAL = %xFilial:D01%
			AND D01.D01_CODEXP = %Exp:cCodExp%
			AND D01.D01_CARGA = %Exp:cCarga%
			AND D01.D01_PEDIDO = %Exp:cPedido%
			AND D01.%NotDel%
		EndSql
		If (cAliasD01)->(!Eof())
			D01->(dbGoto((cAliasD01)->RECNOD01))
			RecLock('D01',.F.)
			D01->D01_QTCONF := (cAliasD02)->D02_QTCONF
			If D01->D01_QTCONF == 0
				// Verica se há algum produto da carga/pedido que esteja em andamento
				// situação ocorrerá quando produto/componente
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT 1
					FROM %Table:D02% D02
					WHERE D02.D02_FILIAL = %xFilial:D02%
					AND D02.D02_CODEXP = %Exp:D01->D01_CODEXP%
					AND D02.D02_CARGA = %Exp:D01->D01_CARGA%
					AND D02.D02_PEDIDO = %Exp:D01->D01_PEDIDO%
					AND D02.D02_CODPRO <> D02.D02_PRDORI
					AND D02.D02_STATUS <> '1'
					AND D02.%NotDel%
				EndSql
				If (cAliasQry)->(!Eof())
					cStatus := "2" // Em Andamento
				Else
					cStatus := "1" // Não Iniciado
				EndIf
				(cAliasQry)->(dbCloseArea())
			ElseIf D01->D01_QTORIG == D01->D01_QTCONF
				cStatus := "3" // Finalizado
			Else
				cStatus := "2" // Em Andamento
			EndIf
			D01->D01_STATUS := cStatus //1=Aguardando Conferencia; 2=Conferencia em Andamento; 3=Conferido
			D01->(MsUnlock())
			cLibPed    := D01->D01_LIBPED
			cStatusD01 := D01->D01_STATUS
		EndIf
		(cAliasD01)->(dbCloseArea())
	EndIf
	(cAliasD02)->(dbCloseArea())
	RestArea(aAreaAnt)
Return

Function WMSV102LIB(nTipo,cCodExp,cCarga,cPedido)
Local aAreaAnt  := GetArea()
Local cAliasSC9 := Nil
	cAliasSC9 := GetNextAlias()
	If nTipo <> 1
		BeginSql Alias cAliasSC9
			SELECT SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:D04% D04
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = D04.D04_PEDIDO
			AND SC9.C9_ITEM = D04.D04_ITEM
			AND SC9.C9_SEQUEN = D04.D04_SEQUEN
			AND SC9.C9_PRODUTO = D04.D04_PRDORI
			AND SC9.C9_NFISCAL = '  '
			AND SC9.C9_BLWMS = '01'
			AND SC9.%NotDel%
			WHERE D04.D04_FILIAL = %xFilial:D04%
			AND D04.D04_CODEXP = %Exp:cCodExp%
			AND D04.D04_CARGA = %Exp:cCarga%
			AND D04.D04_PEDIDO = %Exp:cPedido%
			AND D04.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasSC9
			SELECT SC9.R_E_C_N_O_ RECNOSC9
			FROM %Table:D04% D04
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = D04.D04_PEDIDO
			AND SC9.C9_ITEM = D04.D04_ITEM
			AND SC9.C9_SEQUEN = D04.D04_SEQUEN
			AND SC9.C9_PRODUTO = D04.D04_PRDORI
			AND SC9.C9_NFISCAL = '  '
			AND SC9.C9_BLWMS = '01'
			AND SC9.%NotDel%
			WHERE D04.D04_FILIAL = %xFilial:D04%
			AND D04.D04_CODEXP = %Exp:cCodExp%
			AND D04.D04_CARGA = %Exp:cCarga%
			AND D04.%NotDel%
		EndSql
	EndIf
	Do While (cAliasSC9)->(!Eof())
		SC9->(dbGoTo((cAliasSC9)->RECNOSC9))
		RecLock("SC9",.F.)
		SC9->C9_BLWMS := "05"
		SC9->(MsUnlock())
		(cAliasSC9)->(dbSkip())
	EndDo
	(cAliasSC9)->(dbCloseArea())
RestArea(aAreaAnt)
Return Nil
//-----------------------------------------------------------------------------
// Carrega as quantidades a serem conferidas de acordo com os dados informados
// Pode ser que um produto informado gere mais de um registro em função de ser
// produto componente, ou controlar lote e não pedir lote no coletor
//-----------------------------------------------------------------------------
Static Function LoadPrdConf(aProdutos,nQtde,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,cCodExp)
Local aAreaAnt  := GetArea()
Local aTamD02   := TamSx3('D02_QTORIG')
Local aTamD11   := TamSx3('D11_QTMULT')
Local cWhere    := ""
Local cLastChild:= ""
Local cProdAnt  := ""
Local cAliasQry := GetNextAlias()
Local lVerChild := .T.
Local lHasChild := .F.
Local nQtdPrd   := 0
Local nQtdOri   := 0
Default nQtde   := 0

	// Guarda a quantidade total para rateio entre produtos filhos
	nQtdOri := nQtde
	// Esta query deve ordenar primeiro os produtos filhos quando possuir
	// pois neste caso o produto pai não poderá ser considerado e deverá ser descartado ficando por ultimo
	cWhere := "%"
	If cProduto != cPrdOri
		cWhere += " AND D02.D02_CODPRO = '"+cProduto+"'"
		lVerChild := .F. // Ja é produto filho, não precisa verificar
	EndIf
	If !Empty(cLoteCtl)
		cWhere += " AND D02.D02_LOTE   = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D02.D02_SUBLOT = '"+cNumLote+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT CASE WHEN D11.D11_QTMULT IS NULL THEN 2 ELSE 1 END ORD_PRDCMP,
				D02.D02_PRDORI,
				D02.D02_CODPRO,
				D02.D02_LOTE,
				D02.D02_SUBLOT,
				(D02.D02_QTSEPA - D02.D02_QTCONF) D02_SALDO,
				(CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D11_QTMULT
		FROM %Table:D02% D02
		LEFT JOIN %Table:D11% D11
		ON D11.D11_FILIAL =  %xFilial:D11%
		AND D02.D02_FILIAL = %xFilial:D02%
		AND D11.D11_PRODUT = D02.D02_PRDORI
		AND D11.D11_PRDORI = D02.D02_PRDORI
		AND D11.D11_PRDCMP = D02.D02_CODPRO
		AND D11.%NotDel%
		WHERE D02.D02_FILIAL = %xFilial:D02%
		AND D02.D02_CODEXP = %Exp:cCodExp%
		AND D02.D02_CARGA = %Exp:cCarga%
		AND D02.D02_PEDIDO = %Exp:cPedido%
		AND D02.D02_PRDORI = %Exp:cPrdOri%
		AND D02.%NotDel%
		%Exp:cWhere%
		ORDER BY ORD_PRDCMP,
					D02.D02_CODPRO,
					D02.D02_LOTE,
					D02.D02_SUBLOT
	EndSql
	TcSetField(cAliasQry,'ORD_PRDCMP','N',5,0)
	TcSetField(cAliasQry,'D02_SALDO','N',aTamD02[1],aTamD02[2])
	TcSetField(cAliasQry,'D11_QTMULT','N',aTamD11[1],aTamD11[2])
	Do While (cAliasQry)->(!Eof())
		If (cAliasQry)->D02_PRDORI != (cAliasQry)->D02_CODPRO
			lHasChild := .T.
		EndIf
		If lVerChild .And. lHasChild .And.; //Se deve verificar os filhos e já encontrou um filho
			(cAliasQry)->D02_PRDORI == (cAliasQry)->D02_CODPRO // e o produto atual é o pai, sai fora
			Exit
		EndIf
		// Se mudou o filho ou é o primeiro restaura a quantidade original
		If Empty(cLastChild) .Or. cLastChild != (cAliasQry)->D02_CODPRO
			nQtde := nQtdOri
			cLastChild := (cAliasQry)->D02_CODPRO
		EndIf
		// Calcula a quantidade que pode ser "rateada" para este produto
		If QtdComp(nQtde) > Iif(!lVerChild,QtdComp((cAliasQry)->D02_SALDO),QtdComp((cAliasQry)->D02_SALDO / (cAliasQry)->D11_QTMULT))
			nQtdPrd := (cAliasQry)->D02_SALDO
			nQtde   -= Iif(!lVerChild,(cAliasQry)->D02_SALDO,((cAliasQry)->D02_SALDO / (cAliasQry)->D11_QTMULT))
		Else
			nQtdPrd := Iif(!lVerChild,nQtde,(nQtde * (cAliasQry)->D11_QTMULT))
			nQtde   := 0
		EndIf
		// Adiciona o produto no array de produtos a serem colocados no volume
		If QtdComp(nQtdPrd) > 0
			AAdd(aProdutos, {(cAliasQry)->D02_CODPRO,0,nQtdPrd,cCarga,cPedido,(cAliasQry)->D02_LOTE,(cAliasQry)->D02_SUBLOT,,,(cAliasQry)->D02_PRDORI,,cCodExp})
		EndIf
		cProdAnt := (cAliasQry)->D02_CODPRO
		// Se não é produto componente e zerou a quantidade, deve sair
		If lVerChild .And. !lHasChild .And. QtdComp(nQtde) == 0
			Exit
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return .T.
//-----------------------------------------------------------------------------
// Carrega as quantidades conferidas que devem ser estornadas de acordo com os dados informados
// Pode ser que um produto informado gere mais de um registro em função de ser
// produto componente, ou controlar lote e não pedir lote no coletor
//-----------------------------------------------------------------------------
Static Function LoadPrdEst(aProdutos,nQtde,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote,cCodExp,cLibEst)
Local lVerChild  := .T.
Local lHasChild  := .F.
Local aAreaAnt   := GetArea()
Local aTamD04    := TamSx3('D04_QTCONF')
Local aTamD11    := TamSx3('D11_QTMULT')
Local cWhere     := ""
Local cLastChild := ""
Local cProdAnt   := ""
Local cAliasQry  := GetNextAlias()
Local cCodOpe    := __cUserID
Local nQtdPrd    := 0
Default nQtde    := 0

	nQtdOri := nQtde
	// Esta query deve ordenar primeiro os produtos filhos quando possuir
	// pois neste caso o produto pai não poderá ser considerado e deverá ser descartado ficando por ultimo
	// Se não permite estorno de itens faturados
	cWhere := "%"
	If cProduto != cPrdOri
		cWhere += " AND D04.D04_CODPRO = '"+cProduto+"'"
		lVerChild := .F. // Ja é produto filho, não precisa verificar
	EndIf
	If !Empty(cLoteCtl)
		cWhere += " AND D04.D04_LOTE   = '"+cLoteCtl+"'"
	EndIf
	If !Empty(cNumLote)
		cWhere += " AND D04.D04_SUBLOT = '"+cNumLote+"'"
	EndIf
	cWhere += "%"
	If cLibEst == "2"
		BeginSql Alias cAliasQry
			SELECT CASE WHEN D11.D11_QTMULT IS NULL THEN 2 ELSE 1 END ORD_PRDCMP,
					CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END D11_QTMULT,
					D04.D04_PRDORI,
					D04.D04_CODPRO,
					D04.D04_LOTE,
					D04.D04_SUBLOT,
					D04.D04_QTCONF
			FROM %Table:D04% D04
			LEFT JOIN %Table:D11% D11
			ON D11.D11_FILIAL =  %xFilial:D11%
			AND D04.D04_FILIAL = %xFilial:D04%
			AND D11.D11_PRODUT = D04.D04_PRDORI
			AND D11.D11_PRDORI = D04.D04_PRDORI
			AND D11.D11_PRDCMP = D04.D04_CODPRO
			AND D11.%NotDel%
			WHERE D04.D04_FILIAL = %xFilial:D04%
			AND D04.D04_CODEXP = %Exp:cCodExp%
			AND D04.D04_CARGA = %Exp:cCarga%
			AND D04.D04_PEDIDO = %Exp:cPedido%
			AND D04.D04_CODOPE = %Exp:cCodOpe%
			AND D04.D04_PRDORI = %Exp:cPrdOri%
			AND D04.%NotDel%
			%Exp:cWhere%
			// Se não permite estorno de itens faturados
			AND NOT EXISTS (SELECT 1
							FROM %Table:SC9% SC9
							WHERE SC9.C9_FILIAL = %xFilial:SC9%
							AND SC9.C9_PEDIDO = D04.D04_PEDIDO
							AND SC9.C9_ITEM = D04.D04_ITEM
							AND SC9.C9_SEQUEN = D04.D04_SEQUEN
							AND SC9.C9_PRODUTO= D04.D04_PRDORI
							AND SC9.C9_NFISCAL<> ' '
							AND SC9.%NotDel% )
			ORDER BY ORD_PRDCMP,
						D04.D04_CODPRO,
						D04.D04_LOTE,
						D04.D04_SUBLOT
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT CASE WHEN D11.D11_QTMULT IS NULL THEN 2 ELSE 1 END ORD_PRDCMP,
					CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END D11_QTMULT,
					D04.D04_PRDORI,
					D04.D04_CODPRO,
					D04.D04_LOTE,
					D04.D04_SUBLOT,
					D04.D04_QTCONF
			FROM %Table:D04% D04
			LEFT JOIN %Table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D04.D04_FILIAL = %xFilial:D04%
			AND D11.D11_PRODUT = D04.D04_PRDORI
			AND D11.D11_PRDORI = D04.D04_PRDORI
			AND D11.D11_PRDCMP = D04.D04_CODPRO
			AND D11.%NotDel%
			WHERE D04.D04_FILIAL = %xFilial:D04%
			AND D04.D04_CODEXP = %Exp:cCodExp%
			AND D04.D04_CARGA = %Exp:cCarga%
			AND D04.D04_PEDIDO = %Exp:cPedido%
			AND D04.D04_CODOPE = %Exp:cCodOpe%
			AND D04.D04_PRDORI = %Exp:cPrdOri%
			AND D04.%NotDel%
			%Exp:cWhere%
			ORDER BY ORD_PRDCMP,
					D04.D04_CODPRO,
					D04.D04_LOTE,
					D04.D04_SUBLOT
		EndSql
	EndIf
	TcSetField(cAliasQry,'ORD_PRDCMP','N',5,0)
	TcSetField(cAliasQry,'D04_QTCONF','N',aTamD04[1],aTamD04[2])
	TcSetField(cAliasQry,'D11_QTMULT','N',aTamD11[1],aTamD11[2])
	Do While (cAliasQry)->(!Eof())
		If (cAliasQry)->D04_PRDORI != (cAliasQry)->D04_CODPRO
			lHasChild := .T.
		EndIf
		If lVerChild .And. lHasChild .And.; //Se deve verificar os filhos e já encontrou um filho
			(cAliasQry)->D04_PRDORI == (cAliasQry)->D04_CODPRO // e o produto atual é o pai, sai fora
			Exit
		EndIf
		// Se mudou o filho ou é o primeiro restaura a quantidade original
		If Empty(cLastChild) .Or. cLastChild != (cAliasQry)->D04_CODPRO
			// Se pro filho anterior não conseguiu atender tudo, sai fora
			If !Empty(cLastChild) .And. QtdComp(nQtde) > 0
				Exit
			EndIf
			nQtde := nQtdOri
			cLastChild := (cAliasQry)->D04_CODPRO
		EndIf
		// Calcula a quantidade que pode ser "rateada" para este produto
		If QtdComp(nQtde) > Iif(!lVerChild,QtdComp((cAliasQry)->D04_QTCONF),QtdComp((cAliasQry)->D04_QTCONF/ (cAliasQry)->D11_QTMULT))
			nQtdPrd := (cAliasQry)->D04_QTCONF
			nQtde   -= Iif(!lVerChild,(cAliasQry)->D04_QTCONF,((cAliasQry)->D04_QTCONF/ (cAliasQry)->D11_QTMULT))
		Else
			nQtdPrd := Iif(!lVerChild,nQtde,(nQtde * (cAliasQry)->D11_QTMULT))
			nQtde   := 0
		EndIf
		// Adiciona o produto no array de produtos a serem colocados no volume
		If QtdComp(nQtdPrd) > 0
			AAdd(aProdutos, {(cAliasQry)->D04_CODPRO,0,nQtdPrd,cCarga,cPedido,(cAliasQry)->D04_LOTE,(cAliasQry)->D04_SUBLOT,/*cItem*/,/*cSequen*/,(cAliasQry)->D04_PRDORI,,cCodExp})
		EndIf
		cProdAnt := (cAliasQry)->D04_CODPRO
		// Se não é produto componente e zerou a quantidade, deve sair
		If lVerChild .And. !lHasChild .And. QtdComp(nQtde) == 0
			Exit
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return .T.
//-----------------------------------------------------------------------------
// Efetua o rateio das quantidades conferidas conforme a quantidade do pedido de
// venda e os itens conferidos na conferencia de expedição
//-----------------------------------------------------------------------------
Static Function MntPrdConf(aProdutos,cCarga,cPedido,dDtIni,cHrIni,cCodExp,cStatusD01,nTipo)
Local lRet        := .T.
Local lCarga      := WmsCarga(cCarga)
Local aTamSC9     := TamSx3('C9_QTDLIB')
Local aTamD02     := TamSx3('D02_QTCONF')
Local oProdComp   := WMSDTCProdutoComponente():New()
Local cAliasSC9   := Nil
Local cAliasD04   := Nil
Local cAliasD01   := Nil
Local cProduto    := ""
Local cLoteCtl    := ""
Local cNumLote    := ""
Local cPrdOri     := ""
Local cLibPed     := "3"
Local cBloqWms    := "05"
Local cCodOpe     := __cUserID
Local nY          := 0
Local nQtdConf    := 0
Local nQtdMult    := 1
Local nQtdTot     := 0
Local nQtdSld     := 0
	
	cBloqWms := "05"
	cAliasD01 := GetNextAlias()
	If lCarga
		BeginSql Alias cAliasD01
			SELECT D01.D01_LIBPED
			FROM %Table:D01% D01
			WHERE D01.D01_FILIAL = %xFilial:D01%
			AND D01.D01_CODEXP = %Exp:cCodExp%
			AND D01.D01_CARGA = %Exp:cCarga%
			AND D01.D01_PEDIDO = %Exp:cPedido%
			AND D01.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasD01
			SELECT D01.D01_LIBPED
			FROM %Table:D01% D01
			WHERE D01.D01_FILIAL = %xFilial:D01%
			AND D01.D01_CODEXP = %Exp:cCodExp%
			AND D01.D01_PEDIDO = %Exp:cPedido%
			AND D01.%NotDel%
		EndSql
	EndIf
	If (cAliasD01)->(!Eof()) .And. (cAliasD01)->D01_LIBPED $ "3|4|5"
		cBloqWms := "01"
	EndIf
	(cAliasD01)->(dbCloseArea())
	For nY := 1  To Len(aProdutos)
		cProduto := aProdutos[nY,1]
		cLoteCtl := aProdutos[nY,6]
		cNumLote := aProdutos[nY,7]
		cPrdOri  := aProdutos[nY,10]
		nQtdTot  := aProdutos[nY,3]
		nQtdMult := 1
		// Verifica se o produto é um filho
		If cProduto != cPrdOri
			oProdComp:SetPrdCmp(cProduto)
			If oProdComp:LoadData(2)
				nQtdMult := oProdComp:GetQtMult()
			EndIf
		EndIf
		nQtdTot := nQtdTot / nQtdMult
		// Buscar o item e sequen da SC9 correspondente
		cAliasSC9 := GetNextAlias()
		If lCarga
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_QTDLIB
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_CARGA = %Exp:cCarga%
				AND SC9.C9_PEDIDO = %Exp:cPedido%
				AND SC9.C9_PRODUTO = %Exp:cPrdOri%
				AND SC9.C9_LOTECTL = %Exp:cLoteCtl%
				AND SC9.C9_NUMLOTE = %Exp:cNumLote%
				AND SC9.C9_BLWMS = %Exp:cBloqWms%
				AND SC9.C9_BLEST = '  '"
				AND SC9.%NotDel%
				ORDER BY C9_ITEM,
							C9_SEQUEN
			EndSql
		Else
			BeginSql Alias cAliasSC9
				SELECT SC9.C9_ITEM,
						SC9.C9_SEQUEN,
						SC9.C9_QTDLIB
				FROM %Table:SC9% SC9
				WHERE SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_PEDIDO = %Exp:cPedido%
				AND SC9.C9_PRODUTO = %Exp:cPrdOri%
				AND SC9.C9_LOTECTL = %Exp:cLoteCtl%
				AND SC9.C9_NUMLOTE = %Exp:cNumLote%
				AND SC9.C9_BLWMS = %Exp:cBloqWms%
				AND SC9.C9_BLEST = '  '"
				AND SC9.%NotDel%
				ORDER BY C9_ITEM,
							C9_SEQUEN
			EndSql
		EndIf
		TcSetField(cAliasSC9,'C9_QTDLIB','N',aTamSC9[1],aTamSC9[2])
		If (cAliasSC9)->(Eof())
			lRet := .F.
		EndIf
		Do While lRet .And. (cAliasSC9)->(!Eof()) .And. nQtdTot > 0
			//É preciso descontar a quantidade conferida
			cAliasD04 := GetNextAlias()
			BeginSql Alias cAliasD04
				SELECT CASE WHEN (SUM(D04_QTCONF)) IS NULL THEN 0 ELSE SUM(D04_QTCONF) END AS SOMAD04
				FROM %Table:D04% D04
				WHERE D04.D04_FILIAL = %xFilial:D04%
				AND D04.D04_CODEXP = %Exp:cCodExp%
				AND D04.D04_CARGA = %Exp:cCarga%
				AND D04.D04_PEDIDO = %Exp:cPedido%
				AND D04.D04_CODOPE = %Exp:cCodOpe%
				AND D04.D04_PRDORI = %Exp:cPrdOri%
				AND D04.D04_CODPRO = %Exp:cProduto%
				AND D04.D04_LOTE = %Exp:cLoteCtl%
				AND D04.D04_SUBLOT = %Exp:cNumLote%
				AND D04.D04_ITEM = %Exp:(cAliasSC9)->C9_ITEM%
				AND D04.D04_SEQUEN = %Exp:(cAliasSC9)->C9_SEQUEN%
				AND D04.%NotDel%
			EndSql
			TcSetField(cAliasD04,'SOMAD04','N',aTamD02[1],aTamD02[2])
			If (cAliasD04)->(!Eof())
				nQtdSld := ((cAliasSC9)->C9_QTDLIB - ((cAliasD04)->SOMAD04 / nQtdMult))
			EndIf
			(cAliasD04)->(dbCloseArea())

			If QtdComp(nQtdSld) > QtdComp(nQtdTot)
				nQtdConf := nQtdTot * nQtdMult
			Else
				nQtdConf := nQtdSld * nQtdMult
			EndIf
			If QtdComp(nQtdConf) <= 0
				(cAliasSC9)->(dbSkip())
				Loop
			EndIf
			nQtdTot -= (nQtdConf / nQtdMult)

			D02->(DbSetOrder(1)) //D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE+D02_SUBLOT
			If D02->(DbSeek(xFilial('D02')+cCodExp+cCarga+cPedido+cPrdOri+cProduto+cLoteCtl+cNumLote))
				RecLock('D02',.F.)
				D02->D02_QTCONF += nQtdConf
				If D02->D02_QTCONF == D02->D02_QTORIG
					D02->D02_STATUS := "3"
				Else
					D02->D02_STATUS := "2"
				EndIf
				D02->(MsUnlock())
			EndIf

			// Calcula qtd conf. do produto pai
			If cPrdOri <> cProduto
				CalcConfExp(1,cCodExp,cCarga,cPedido,cPrdOri,cProduto,cLoteCtl,cNumLote)
			/*Else
				// Verifica se é um produto pai e joga a quantidade para os filhos
				CalcQtdPart(.F.,cCodExp,cCarga,cPedido,cPrdOri,cLoteCtl,cNumLote,nQtdConf)
			*/EndIf

			D04->(dbSetOrder(1)) //D04_FILIAL+D04_CODEXP+D04_CARGA+D04_PEDIDO+D04_CODOPE+D04_PRDORI+D04_CODPRO+D04_LOTE+D04_SUBLOT+D04_ITEM+D04_SEQUEN
			If D04->(dbSeek(xFilial('D04')+cCodExp+cCarga+cPedido+cCodOpe+cPrdOri+cProduto+cLoteCtl+cNumLote+(cAliasSC9)->C9_ITEM+(cAliasSC9)->C9_SEQUEN))
				RecLock('D04',.F.)
				D04->D04_QTCONF += nQtdConf
				D04->D04_DTFIM  := dDataBase
				D04->D04_HRFIM  := Time()
				D04->(MsUnlock())
			Else
				RecLock('D04',.T.)
				D04->D04_FILIAL := xFilial('D04')
				D04->D04_CODEXP := cCodExp
				D04->D04_CARGA  := cCarga
				D04->D04_PEDIDO := cPedido
				D04->D04_CODOPE := cCodOpe
				D04->D04_PRDORI := cPrdOri
				D04->D04_CODPRO := cProduto
				D04->D04_LOTE   := cLoteCtl
				D04->D04_SUBLOT := cNumLote
				D04->D04_ITEM   := (cAliasSC9)->C9_ITEM
				D04->D04_SEQUEN := (cAliasSC9)->C9_SEQUEN
				D04->D04_QTCONF := nQtdConf
				D04->D04_DTINI  := dDtIni
			  	D04->D04_HRINI  := cHrIni
				D04->D04_DTFIM  := dDataBase
				D04->D04_HRFIM  := Time()
				D04->(MsUnlock())
			EndIf
		EndDo
		(cAliasSC9)->(dbCloseArea())
		If lRet
			If D03->(!DbSeek(xFilial('D03')+cCodExp+cCarga+cPedido+cCodOpe))
				RecLock('D03',.T.)
				D03->D03_FILIAL := xFilial('D03')
				D03->D03_CODEXP := cCodExp
				D03->D03_CARGA  := cCarga
				D03->D03_PEDIDO := cPedido
				D03->D03_CODOPE := cCodOpe
				D03->D03_DTINI  := dDtIni
			   	D03->D03_HRINI  := cHrIni
				D03->D03_DTFIM  := dDataBase
				D03->D03_HRFIM  := Time()
				D03->(MsUnlock())
			Else
				RecLock('D03',.F.)
				D03->D03_DTFIM  := dDataBase
				D03->D03_HRFIM  := Time()
				D03->(MsUnlock())
			EndIf
		EndIf
		If lRet
			// Atualiza Quantidade conferida da D01 e status
			CalcQtdD01(cCodExp,cCarga,cPedido,@cStatusD01,@cLibPed)
			// Se o pedido estiver conferido e a liberação p/ fat. for pela conferencia, realiza a liberação
			If cStatusD01 == "3"
				If cLibPed == "3"
					// Liberação
					WMSV102LIB(nTipo,cCodExp,cCarga,cPedido)
				EndIf
				lFinal := .T.
			EndIf
		EndIf
		If !lRet
			Exit
		EndIf
	Next nY
Return lRet
/*--------------------------------------------------------------------
---VldConfVol
---Valida se existem volumes pendentes de conferência para o pedido 
---amanda.vieira (13/03/2018)
--------------------------------------------------------------------*/
Static Function VldConfVol(cCarga,cPedido,lEstorno)
Local lRet      := .F.
Local cAliasQry := Nil
Local oMntVol   := Nil

Default lEstorno := .F.

	cStConf := IIf(lEstorno,"2","1")

	oMntVol := WMSDTCMontagemVolume():New()
	oMntVol:SetCarga(cCarga)
	oMntVol:SetPedido(cPedido)
	oMntVol:SetCodMnt(oMntVol:FindCodMnt())
	If oMntVol:LoadData()
		lRet := .T.
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCU.DCU_CODVOL
			FROM %Table:DCU% DCU
			WHERE DCU.DCU_FILIAL = %xFilial:DCU%
			AND DCU.DCU_CARGA  = %Exp:cCarga%
			AND DCU.DCU_PEDIDO = %Exp:cPedido%
			AND DCU.DCU_CODMNT = %Exp:oMntVol:GetCodMnt()%
			AND DCU.DCU_STCONF = %Exp:cStConf%
			AND DCU.%NotDel%
		EndSql
		//Caso não exista volume pendente de conferência e o status da montagem encontra-se finalizada,
		//conclui-se que a montagem de volume pertence à outra sequência de liberação do pedido
		//então não obriga a informação do código do volume para a realizar a conferência
		If (cAliasQry)->(EoF()) .And. oMntVol:GetStatus() == '3'
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	oMntVol:Destroy()
Return lRet

//-----------------------------------------
/*/{Protheus.doc} VldCalcof
Busca quantidade do embarque para o item 
@author Squad WMS/OMS Protheus
@since 04/08/2022
@version 1.0
/*/
//-----------------------------------------
Static Function VldCalcof(cCodExp,cProduto,cCarga,cPedido)
Local nConf := 0
Local cAliasD02 := GetNextAlias()
Local cWhere := ""

	cWhere := '%'
	cWhere += " AND D02.D02_CODEXP = '"+cCodExp+"'"
	If !Empty(cCarga)
		cWhere += " AND D02.D02_CARGA = '"+cCarga+"'"
	EndIf
	cWhere += " AND D02.D02_PEDIDO = '"+cPedido+"'"
	cWhere += " AND D02.D02_CODPRO = '"+cProduto+"'"
	cWhere += " AND D02.D02_STATUS <> '3'"
	cWhere += '%'

	BeginSql Alias cAliasD02
		SELECT SUM(D02.D02_QTORIG / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D02_QTDORI,
				SUM(D02.D02_QTORIG / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D02_QTORIG
		FROM %Table:D02% D02
		LEFT JOIN %Table:D11% D11
		ON D11_FILIAL = %xFilial:D11%
		AND D11.D11_PRDORI = D02.D02_PRDORI
		AND D11.D11_PRDCMP = D02.D02_CODPRO
		AND D11.%NotDel%
		WHERE D02.D02_FILIAL = %xFilial:D02%
		%Exp:cWhere%
		AND D02.%NotDel%
	EndSql
	If (cAliasD02)->(!Eof())
		nConf := ((cAliasD02)->D02_QTORIG)
	EndIf
	(cAliasD02)->(dbCloseArea())

Return nConf
//------------------------------------------------------
/*/{Protheus.doc} VldArD12
	(Procurar o armazem e endereço na tabela D12 para que seja considerado 
	a sequencia de abastecimento no processo de validação da unidade de medida do produto.)
	@type  Function
	@author Equipe Wms
	@since 08/08/2022
	@version 1.0
/*/
//----------------------------------------------------------
Static Function VldArD12(cProduto,cCodExp,cArmazem,cEndereco)
Local cAliasD12 := GetNextAlias()
Local cWhere := ""
	
	cWhere := '%'
	cWhere += " AND D02.D02_CODEXP = '"+cCodExp+"'"
	cWhere += " AND D02.D02_CODPRO = '"+cProduto+"'"
	cWhere += '%'

	BeginSql Alias cAliasD12
		SELECT MAX(D12_DTGERA),
        D12.D12_ENDDES,
        D12.D12_LOCDES
   	    FROM %Table:D02% D02
		INNER JOIN %Table:D12% D12 
		 ON D12_FILIAL = %xFilial:D12% 
		AND D12.D12_DOC  = D02.D02_PEDIDO
		AND D12.D12_CARGA = D02.D02_CARGA
		AND D12.D12_PRODUT = D02.D02_CODPRO
		AND D12.D12_PRDORI = D02.D02_PRDORI
		AND D12.D12_LOTECT = D02.D02_LOTE
		AND D12.D12_NUMLOT  = D02.D02_SUBLOT
		AND D12.D12_STATUS IN ('1','0')
		AND D12.D_E_L_E_T_ = ''
		AND D12.D12_QTDLID > 0 
        WHERE D02.D02_FILIAL = %xFilial:D02% 
	 	%Exp:cWhere%
		AND D12.%NotDel%
		GROUP BY  D12.D12_ENDDES,
		D12.D12_LOCDES
	EndSql   
	
	If (cAliasD12)->(!Eof())
		cEndereco := (cAliasD12)->D12_ENDDES
		cArmazem := (cAliasD12)->D12_LOCDES
	EndIf
	(cAliasD12)->(dbCloseArea())

Return 
