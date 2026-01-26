#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNE.CH"

#DEFINE CLRF  CHR(13)+CHR(10)
#DEFINE WMSXFUNE01 "WMSXFUNE01"
#DEFINE WMSXFUNE02 "WMSXFUNE02"
#DEFINE WMSXFUNE03 "WMSXFUNE03"
#DEFINE WMSXFUNE04 "WMSXFUNE04"
#DEFINE WMSXFUNE05 "WMSXFUNE05"
#DEFINE WMSXFUNE06 "WMSXFUNE06"
#DEFINE WMSXFUNE07 "WMSXFUNE07"
#DEFINE WMSXFUNE08 "WMSXFUNE08"
#DEFINE WMSXFUNE09 "WMSXFUNE09"
#DEFINE WMSXFUNE10 "WMSXFUNE10"
#DEFINE WMSXFUNE11 "WMSXFUNE11"
#DEFINE WMSXFUNE12 "WMSXFUNE12"
#DEFINE WMSXFUNE13 "WMSXFUNE13"
#DEFINE WMSXFUNE14 "WMSXFUNE14"
#DEFINE WMSXFUNE15 "WMSXFUNE15"
#DEFINE WMSXFUNE16 "WMSXFUNE16"
#DEFINE WMSXFUNE17 "WMSXFUNE17"
#DEFINE WMSXFUNE18 "WMSXFUNE18"
#DEFINE WMSXFUNE19 "WMSXFUNE19"
#DEFINE WMSXFUNE20 "WMSXFUNE20"
#DEFINE WMSXFUNE21 "WMSXFUNE21"
#DEFINE WMSXFUNE22 "WMSXFUNE22"
#DEFINE WMSXFUNE23 "WMSXFUNE23"
#DEFINE WMSXFUNE24 "WMSXFUNE24"
#DEFINE WMSXFUNE25 "WMSXFUNE25"
#DEFINE WMSXFUNE26 "WMSXFUNE26"
#DEFINE WMSXFUNE27 "WMSXFUNE27"
#DEFINE WMSXFUNE28 "WMSXFUNE28"
#DEFINE WMSXFUNE29 "WMSXFUNE29"
#DEFINE WMSXFUNE30 "WMSXFUNE30"
#DEFINE WMSXFUNE31 "WMSXFUNE31"
#DEFINE WMSXFUNE32 "WMSXFUNE32"
#DEFINE WMSXFUNE33 "WMSXFUNE33"
#DEFINE WMSXFUNE34 "WMSXFUNE34"
#DEFINE WMSXFUNE35 "WMSXFUNE35"
#DEFINE WMSXFUNE36 "WMSXFUNE36"
#DEFINE WMSXFUNE37 "WMSXFUNE37"
#DEFINE WMSXFUNE38 "WMSXFUNE38"
#DEFINE WMSXFUNE39 "WMSXFUNE39"
#DEFINE WMSXFUNE40 "WMSXFUNE40"
#DEFINE WMSXFUNE41 "WMSXFUNE41"
#DEFINE WMSXFUNE42 "WMSXFUNE42"

Static __aCposCal := {}

/*-----------------------------------------------------------------------------
Valida a integração da entrada de notas fiscais com WMS
Efetua validações com base no cabeçalho das notas fiscais
-----------------------------------------------------------------------------*/
Function WmsAvalSF1(cAcao,cAliasSF1)
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lAuto      := (Val(SuperGetMV("MV_WMSDPCA",.F.,'0')) > 0)
Local oDistrib   := Nil

Default cAcao     := "1"
Default cAliasSF1 := "SF1"
/*
cAcao -> 1 - Classificação de NF
		 2 - Estorno de Classificação
		 3 - Alteração de NF
		 4 - Exclusão de NF
		 5 - Processamento das regras WMS
		 6 - Distribuição automatica prenota com pedido de compra
		 7 - Cancelamento da distribuição automática prenota
*/
	If cAcao $ "1|2|3|4" //-- Validações da nota fiscal
		lRet := WmsChkDCW(cAcao,(cAliasSF1)->F1_DOC,(cAliasSF1)->F1_SERIE,(cAliasSF1)->F1_FORNECE,(cAliasSF1)->F1_LOJA)
		If lRet .And. cAcao != "2" .And. lWmsNew
			lRet := WmsChkD07(cAcao,(cAliasSF1)->F1_DOC,(cAliasSF1)->F1_SERIE,(cAliasSF1)->F1_FORNECE,(cAliasSF1)->F1_LOJA)
		EndIf
	ElseIf cAcao == "5" //-- Processamento das regras WMS referentes as ordens de serviço do documento
		WmsExeServ()
		If lWmsNew
			// Exclusão das tabelas temporárias
			WMSDTPRGCV()
		EndIf
	ElseIf cAcao == "6" //-- Distribuição automatica prenota com pedido de compra
		If lWmsNew .And. lAuto
			oDistrib := WMSDTCDistribuicaoProdutosPedidosItens():New()
			lRet := oDistrib:MntDisAuto(SF1->(Recno()))
		EndIf
	ElseIf cAcao == "7"
		If lWmsNew .And. lAuto
			oDistrib := WMSDTCDistribuicaoProdutosPedidosItens():New()
			lRet := oDistrib:CancelDist(SF1->(Recno()))
		EndIf
	ElseIf cAcao = "8"
		If lWmsNew
			// Cria as tabelas temporárias utilizadas no caso do skip-lote
			WMSCTPRGCV()
		EndIf
	EndIf
Return lRet

/*-----------------------------------------------------------------------------
Valida a integração da entrada de notas fiscais com WMS
Efetua validações com base nos itens das notas fiscais
Pode efetuar a validação pelo Alias posicionado, ou pelo Array passado
-----------------------------------------------------------------------------*/
Function WmsAvalSD1(cAcao,cAliasSD1,aCols,nPos,aHeader,lPreNota)
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lWMSVQFP   := SuperGetMV("MV_WMSVQFP",.F.,.F.)
Local lConfServ  := .F.
Local aAreaAnt   := GetArea()
Local aAreaDC5   := {}
Local aAreaSBE   := {}
Local aAreaDC8   := {}
Local aAreaSB5   := {}
Local aMensagem  := {}
Local aContSX5   := {}
Local oOrdServ   := Nil
Local oDmdUnit   := Nil
Local cProduto   := ""
Local cArmazem   := ""
Local cArmConf   := ""
Local cServico   := ""
Local cEndereco  := ""
Local cCampos    := ""
Local cAliasDC5  := Nil
Local cCodRec    := ""
Local cFunExe    := ""
Local cMensagem  := ""
Local cTes       := ""
Local nPosItem   := 0
Local nPosQuant  := 0
Local nPosProd   := 0
Local nPosArmz   := 0
Local nPosServ   := 0
Local nPosEnd    := 0
Local nPosStSv   := 0
Local nPosRegWMS := 0
Local nPosTes    := 0
Local nQuant     := 0

Default cAcao     := "1"
Default cAliasSD1 := "SD1"
Default aCols     := {}
Default nPos      := 1
Default aHeader   := {}
Default lPreNota  := .F.

	If Type("l103Class")=="U"
		Private l103Class := .F.
	EndIf

	If cAcao == "1" //-- Validações da LinhaOK na digitação de documentos de entrada

		nPosProd := aScan(aHeader,{|x|Alltrim(x[2])=='D1_COD'})
		cProduto := Iif(nPosProd>0,aCols[nPos,nPosProd],CriaVar('D1_COD', .F.))

		If IntWMS(cProduto)

			nPosArmz   := aScan(aHeader,{|x|Alltrim(x[2])=='D1_LOCAL'})
			nPosServ   := aScan(aHeader,{|x|Alltrim(x[2])=='D1_SERVIC'})
			nPosEnd    := aScan(aHeader,{|x|Alltrim(x[2])=='D1_ENDER'})

			aAreaDC5 := DC5->(GetArea())
			aAreaSBE := SBE->(GetArea())
			aAreaDC8 := DC8->(GetArea())

			cServico  := Iif(nPosServ>0,aCols[nPos,nPosServ],CriaVar('D1_SERVIC', .F.))
			cArmazem  := Iif(nPosArmz>0,aCols[nPos,nPosArmz],CriaVar('D1_LOCAL' , .F.))
			cEndereco := Iif(nPosEnd >0,aCols[nPos,nPosEnd] ,CriaVar('D1_ENDER' , .F.))

			If lWmsNew .And. !lPreNota
				If IntWMS(cProduto)
					If Empty(cServico)
						WmsMessage(STR0001,WMSXFUNE01,,,,STR0002) //'Campo "Serviço WMS" não informado.'###"Produtos que possuem controle de WMS devem ter o campo serviço informado."
						lRet := .F.
					EndIf
				EndIf
			EndIf
			//quando o produto tem integração com a qualidade como Q-Siga Quality , valida se possui o cadastro do fornecedor relacionado ao produto MATA061. 
			nPosTes   := aScan(aHeader,{|x|Alltrim(x[2])=='D1_TES'})
			cTes  := Iif(nPosTes>0,aCols[nPos,nPosTes],CriaVar('D1_TES' , .F.))
			
			If lRet .AND. lWMSVQFP .AND. lWmsNew .And. IsInCallStack("MATA103") .AND. (RetFldProd(SB1->B1_COD,"B1_TIPOCQ") == "Q") .AND. !QieTipoNF(cTipo,cTes)
				DbSelectArea("SA5")
				SA5->(DbSetOrder(1))
				If !DBSeek(xFilial("SA5")+CA100FOR+cLoja+cProduto)
					WmsMessage(STR0057,WMSXFUNE41,,,,) // "Produto com controle de qualidade e não possui amarração com o Fornecedor (MATA061)."
				    lRet := .F. 
				EndIf
			EndIF
			//-- Valida se os campos obrigatório para o WMS forma informados
			If lRet .And. !Empty(cServico)
				If Empty(cArmazem) .Or. Empty(cEndereco)
					cCampos := Iif(Empty(cArmazem),AllTrim(RetTitle('D1_LOCAL')),'')
					cCampos += Iif(Empty(cEndereco),Iif(!Empty(cCampos),', ','')+AllTrim(RetTitle('D1_ENDER')),'')
					WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",cCampos}}),WMSXFUNE02,,,,STR0004) //"Os campos [VAR01] devem ser preenchidos quando se utiliza a integração com o módulo de WMS."###"Informe os campos para integração com o módulo WMS."
					lRet := .F.
				EndIf
				If lRet
					//-- Valida o serviço digitado, que deve ser do tipo "Entrada"
					DbSelectArea('DC5')
					DC5->(DbSetOrder(1))
					If !(DC5->(DbSeek(xFilial('DC5')+cServico, .F.)) .And. DC5->DC5_TIPO=='1')
						WmsMessage(STR0005,WMSXFUNE03,,,,STR0006) //"Tipo de serviço WMS inválido."###'Somente serviços WMS do tipo "Entrada" podem ser utilizados.'
						lRet := .F.
					EndIf
					//- Valida o Servico digitado na pre-nota, que deve ser de Conferencia.
					If lRet
						//-- Verifica se o servico eh de conferencia
						If lWmsNew
							cAliasDC5 := GetNextAlias()
							If lPrenota
								BeginSql Alias cAliasDC5
									SELECT DC5.DC5_OPERAC
									FROM %Table:DC5% DC5
									WHERE DC5.DC5_FILIAL = %xFilial:DC5%
									AND DC5.DC5_SERVIC = %Exp:cServico%
									AND NOT EXISTS (SELECT DC5A.DC5_OPERAC
													FROM %Table:DC5% DC5A
													WHERE DC5A.DC5_FILIAL = %xFilial:DC5%
													AND DC5A.DC5_SERVIC = DC5.DC5_SERVIC
													AND DC5A.DC5_OPERAC NOT IN ('0','6')
													AND DC5A.%NotDel% )
									AND EXISTS (SELECT DC5B.DC5_OPERAC
												FROM %Table:DC5% DC5B
												WHERE DC5B.DC5_FILIAL = %xFilial:DC5%
												AND DC5B.DC5_SERVIC = DC5.DC5_SERVIC
												AND DC5B.DC5_OPERAC = '6'
												AND DC5B.%NotDel% )
									AND DC5.%NotDel%
								EndSql
							Else
								BeginSql Alias cAliasDC5
									SELECT DC5.DC5_OPERAC
									FROM %Table:DC5% DC5
									WHERE DC5.DC5_FILIAL = %xFilial:DC5%
									AND DC5.DC5_SERVIC = %Exp:cServico%
									AND NOT EXISTS (SELECT DC5A.DC5_OPERAC
													FROM %Table:DC5% DC5A
													WHERE DC5A.DC5_FILIAL = %xFilial:DC5%
													AND DC5A.DC5_SERVIC = DC5.DC5_SERVIC
													AND DC5A.DC5_OPERAC NOT IN ('0','1','2','6')
													AND DC5A.%NotDel% )
									AND EXISTS (SELECT DC5B.DC5_OPERAC
												FROM %Table:DC5% DC5B
												WHERE DC5B.DC5_FILIAL = %xFilial:DC5%
												AND DC5B.DC5_SERVIC = DC5.DC5_SERVIC
												AND DC5B.DC5_OPERAC IN ('1','2')
												AND DC5B.%NotDel% )
									AND DC5.%NotDel%
								EndSql
							EndIf
							If (cAliasDC5)->(Eof())
								If lPreNota
									WmsMessage(STR0005,WMSXFUNE04,,,,STR0038) // Tipo de serviço WMS com operação inválida. // Informe um serviço WMS que possua a operação de 6-Conferência de Entrada, permitindo a operação 0-Customizada!
								Else
									WmsMessage(STR0005,WMSXFUNE38,,,,STR0053) // Tipo de serviço WMS com operação inválida. // Informe um serviço WMS que possua as operações 1-Endereçamento ou 2-Endereçamento Crossdocking, permitindo as operações 0-Customizada e/ou 6-Conferência de entrada!
								EndIf
								lRet := .F.
							EndIf
							(cAliasDC5)->(dbCloseArea())
						ElseIf lPreNota
							// Busca o registro relacionado à função a ser executada pela tarefa
							aContSX5 := FWGetSX5("L6",DC5->DC5_FUNEXE)
							// Se encontrar
							If Len(aContSX5) > 0
								cFunExe := Upper(aContSX5[1,4])
								//-- Valida o Servico digitado na pre-nota, que deve ser de Conferencia.
								If !("DLCONFEREN" $ cFunExe .Or. "DLCONFENT" $ cFunExe .Or. (SubStr(cFunExe, 1, 2) == 'U_'))
									WmsMessage(STR0005,WMSXFUNE17,,,,STR0007) //"Tipo de serviço WMS inválido."###'Somente serviços WMS de "Conferência" podem ser utilizados.'
									lRet := .F.
								EndIf
							EndIf
						EndIf
					EndIf
					If lRet .And. lWmsNew
						//Avalia produto componente
						lRet := WmsAvalCmp(cProduto)
					EndIf
				EndIf
			EndIf

			//-- Valida se o Endereco digitado possui Estrutura "BOX/DOCA"
			If lRet .And. !Empty(cArmazem) .And. !Empty(cEndereco)
				DbSelectArea('SBE')
				SBE->(DbSetOrder(1))
				If !SBE->(DbSeek(xFilial('SBE')+cArmazem+cEndereco, .F.))
					WmsMessage(WmsFmtMsg(STR0008,{{"[VAR01]",cEndereco},{"[VAR02]",cArmazem}}),WMSXFUNE05,,,,STR0009) //"Endereço [VAR01] não cadastrado para o armazém [VAR02]."###"Verifique o cadastro de endereços (SBE)."
					cEndereco := CriaVar('D1_ENDER' , .F.)
					lRet := .F.
				Else
					DbSelectArea('DC8')
					DC8->(DbSetOrder(1))
					If !DC8->(DbSeek(xFilial('DC8')+SBE->BE_ESTFIS, .F.))
						WmsMessage(WmsFmtMsg(STR0010,{{"[VAR01]",SBE->BE_ESTFIS},{"[VAR02]",cEndereco}}),WMSXFUNE06,,,,STR0009) //"Estrutura física [VAR01] cadastrada para o endereço [VAR02] não cadastrada."###"Verifique o cadastro de endereços (SBE)."
						lRet := .F.
					Else
						If DC8->DC8_TPESTR != '5'
							WmsMessage(WmsFmtMsg(STR0011,{{"[VAR01]",SBE->BE_ESTFIS},{"[VAR02]",cEndereco}}),WMSXFUNE07,,,,STR0012) //"Tipo da estrutura física [VAR01] cadastrada para o endereço [VAR02] inválido."###"Somente endereços pertencentes a estruturas físicas do tipo BOX/DOCA podem ser utilizados."
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If lRet
					If SBE->BE_STATUS == '3'
						 WmsMessage(WmsFmtMsg(STR0028,{{"[VAR01]",cEndereco}})) // O endereço origem [VAR01] está bloqueado.
						 lRet := .F.
					ElseIf SBE->BE_STATUS == '4'
						 WmsMessage(WmsFmtMsg(STR0029,{{"[VAR01]",cEndereco}})) // Endereço destino [VAR01] está com bloqueio de entrada.
						 lRet := .F.
					ElseIf SBE->BE_STATUS == '6'
						 WmsMessage(WmsFmtMsg(STR0030,{{"[VAR01]",cEndereco}})) // Endereço destino [VAR01] está com bloqueio de inventário.
						 lRet := .F.
					EndIf
				EndIf
			EndIf

			// Para os itens que foram distribuidos pelo WMS, força ser informado um serviço de cross-docking
			If lRet .And. lWmsNew .And. IsInCallStack("MATA103") .AND. l103Class .AND. nPos <= Len(aColsOrig) .And. !Empty(aCols)
				lRet := WMSVldD07(1,aCols,nPos,aHeader)
			EndIf

			// Não deve permitir alteração da quantidade quando for classificação de pré-nota com conferência de recebimento finalizada
			If lRet .And. !lPreNota .And. !INCLUI
				// Descobre a posição das colunas a partir do cabeçalho do grid
				nPosItem   := aScan(aHeader,{|x|Alltrim(x[2])=='D1_ITEM'   })
				nPosQuant  := aScan(aHeader,{|x|Alltrim(x[2])=='D1_QUANT'  })
				// Verifica se existe conferência de recebimento para o documento
				If WmsChkDCW("5",SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,@cCodRec) .And. !Empty(cCodRec)
					// Busca a quantidade original do item, pois neste momento a SD1 não está posicionada
					nQuant := Posicione("SD1",1,xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[nPos,nPosProd]+aCols[nPos,nPosItem],"D1_QUANT")
					// Verifica se a quantidade foi alterada
					If QtdComp(nQuant) != aCols[nPos,nPosQuant]
						WmsMessage(WmsFmtMsg(STR0043,{{"[VAR01]",cCodRec}}),WMSXFUNE29,,,,STR0021) // A quantidade não pode ser alterada porque o documento está vinculado ao processo de conferência [VAR01] no WMS que encontra-se finalizado. ### Retire o documento da conferência ou exclua o processo de conferência no WMS.
						lRet := .F.
					EndIf
					//Verifica se o armazem foi alterado quando existe conferencia de recebimento e está classificando a pre-nota
					cArmConf := Posicione("SD1",1,xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[nPos,nPosProd]+aCols[nPos,nPosItem],"D1_LOCAL")
					If WmsArmUnit(cArmConf)
						If cArmazem <> cArmConf
							WmsMessage(WmsFmtMsg(STR0054,{{"[VAR01]",cArmConf}}),WMSXFUNE39,,,,WmsFmtMsg(STR0055,{{"[VAR01]",cArmConf},{"[VAR02]",cArmazem}})) //"Existe conferência de recebimento para o armazém [VAR01]." "Classifique no armazém [VAR01] ou refaça a conferência de recebimento no armazém [VAR02]."
							lRet := .F.
						Endif
					Endif 
				EndIf
			EndIf

			RestArea(aAreaDC8)
			RestArea(aAreaSBE)
			RestArea(aAreaDC5)

		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando se tratar de Pre-Nota, e apenas quando o serviço for de conferencia, apaga os         ³
	//³ campos referentes ao servico de WMS apos a execucao, permitindo que o servico (enderecamento)³
	//³ seja informado apos classificacao                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf cAcao $ "2|8" //-- Preenchimento dos dados do aCols quando classificação da nota fiscal

		nPosProd := aScan(aHeader,{|x|AllTrim(x[2])=='D1_COD'})
		cProduto := Iif(nPosProd>0,aCols[nPos,nPosProd],CriaVar('D1_COD', .F.))

		If IntWMS(cProduto)

			aAreaSB5 := SB5->(GetArea())
			nPosArmz   := aScan(aHeader,{|x|AllTrim(x[2])=='D1_LOCAL'})
			nPosServ   := aScan(aHeader,{|x|AllTrim(x[2])=='D1_SERVIC'})
			nPosStSv   := aScan(aHeader,{|x|AllTrim(x[2])=='D1_STSERV'})
			nPosEnd    := aScan(aHeader,{|x|AllTrim(x[2])=='D1_ENDER' })
			nPosRegWMS := aScan(aHeader,{|x|AllTrim(x[2])=='D1_REGWMS'})

			dbSelectArea("SB5")
			SB5->(dbSetOrder(1))
			SB5->(dbSeek(xFilial("SB5")+cProduto))

			//-- Busca o tipo da função do serviço que está cadastrado
			If nPosServ > 0
				cServico  := aCols[nPos,nPosServ]
				If nPosEnd > 0 
					cEndereco := aCols[nPos][nPosEnd]
				EndIF
				//-- Verifica se o servico eh de conferencia
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT DC5.DC5_OPERAC,
							DC5.DC5_FUNEXE
					FROM %Table:DC5% DC5
					WHERE DC5.DC5_FILIAL = %xFilial:DC5%
					AND DC5.DC5_SERVIC = %Exp:cServico%
					AND DC5.%NotDel%
				EndSql
				If (cAliasQry)->(!Eof())
					If !lWmsNew
						DbSelectArea('SX5')
						SX5->(DbSetOrder(1))
						SX5->(DbSeek(xFilial('SX5')+'L6'+(cAliasQry)->DC5_FUNEXE))
						If 'DLCONFEREN' $ AllTrim(Upper(SX5->(X5Descri()))) .Or.;
						   'DLCONFENT'  $ AllTrim(Upper(SX5->(X5Descri())))
							lConfServ := .T.
						EndIf
					Else
						If (cAliasQry)->DC5_OPERAC $ "6|7|"
							lConfServ := .T.
						EndIf
					EndIf
				EndIf
				(cAliasQry)->(dbCloseArea())
				// Verifica serviço preenchido e conferência convocada
				IF !IsInCallStack("MATA140") .And. (Empty(aCols[nPos,nPosServ]) .Or. (!Empty(aCols[nPos,nPosServ]) .And. lConfServ))
					aCols[nPos,nPosServ  ] := SB5->B5_SERVENT
					If Empty(cEndereco)
						IF nPosEnd > 0 
							aCols[nPos,nPosEnd] := SB5->B5_ENDENT
						EndIf 
					EndIf
					IF nPosStSv > 0 
						aCols[nPos,nPosStSv  ] := CriaVar('D1_STSERV', .T.) //-- Neste caso SEMPRE deixa o servico com status de NAO EXECUTADO
					EndIf 
					IF nPosRegWMS > 0 
						aCols[nPos,nPosRegWMS] := CriaVar('D1_REGWMS', .T.)
					EndIf	
				EndIf
				//-- Valida se o Endereco digitado possui Estrutura "BOX/DOCA"
				If lRet .And. !Empty(aCols[nPos,nPosArmz]) .And. !Empty(aCols[nPos][nPosEnd] )
					DbSelectArea('SBE')
					SBE->(DbSetOrder(1))
					If !SBE->(DbSeek(xFilial('SBE')+aCols[nPos,nPosArmz]+aCols[nPos][nPosEnd], .F.))
						WmsMessage(WmsFmtMsg(STR0008,{{"[VAR01]",aCols[nPos][nPosEnd]},{"[VAR02]",aCols[nPos,nPosArmz]}}),WMSXFUNE18,,,,STR0009) //"Endereço [VAR01] não cadastrado para o armazém [VAR02]."###"Verifique o cadastro de endereços (SBE)."
						aCols[nPos][nPosEnd] := CriaVar('D1_ENDER' , .F.)
						lRet := .F.
					Else
						DbSelectArea('DC8')
						DC8->(DbSetOrder(1))
						If !DC8->(DbSeek(xFilial('DC8')+SBE->BE_ESTFIS, .F.))
							WmsMessage(WmsFmtMsg(STR0010,{{"[VAR01]",SBE->BE_ESTFIS},{"[VAR02]",aCols[nPos][nPosEnd]}}),WMSXFUNE19,,,,STR0009) //"Estrutura física [VAR01] cadastrada para o endereço [VAR02] não cadastrada."###"Verifique o cadastro de endereços (SBE)."
							lRet := .F.
						Else
							If DC8->DC8_TPESTR != '5'
								WmsMessage(WmsFmtMsg(STR0011,{{"[VAR01]",SBE->BE_ESTFIS},{"[VAR02]",aCols[nPos][nPosEnd]}}),WMSXFUNE20,,,,STR0012) //"Tipo da estrutura física [VAR01] cadastrada para o endereço [VAR02] inválido."###"Somente endereços pertencentes a estruturas físicas do tipo BOX/DOCA podem ser utilizados."
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
				If ExistBlock("WMS103PN")
					If !Execblock("WMS103PN",.F.,.F.,)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cAcao == "3" //-- Validação para efetuar a classificação da nota fiscal
		//-- Impede a classif. da PreNota com Servico de WMS conferencia pendente
		If IntWMS((cAliasSD1)->D1_COD) .And. !Empty((cAliasSD1)->D1_SERVIC)
			If lWmsNew
				If !Empty((cAliasSD1)->D1_IDDCF)
					oOrdServ := WMSDTCOrdemServico():New()
					oOrdServ:SetIdDCF((cAliasSD1)->D1_IDDCF)
					If oOrdServ:LoadData()
						If oOrdServ:GetStServ() $ "12"
							lRet := .F.
						ElseIf oOrdServ:HaveMovD12('3')
							lRet := .F.
						EndIf
						If !lRet
							WmsMessage(STR0013,WMSXFUNE14,,,,STR0014) //"Documento não pode ser classificado porque possui serviços de conferência WMS pendentes."###"Finalize o processo de conferência do WMS ou estorne e exclua estes serviços."
						EndIf
					EndIf
				EndIf
			Else
				If WmsChkDCF("SD1",,,(cAliasSD1)->D1_SERVIC,,,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,;
					(cAliasSD1)->D1_LOCAL,(cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_NUMLOTE,(cAliasSD1)->D1_NUMSEQ,(cAliasSD1)->D1_IDDCF)
					If DCF->DCF_STSERV $ "12"
						lRet := .F.
					ElseIf WmsChkSDB('3')
						lRet := .F.
					EndIf
					If !lRet
						WmsMessage(STR0013,WMSXFUNE24,,,,STR0014) //"Documento não pode ser classificado porque possui serviços de conferência WMS pendentes."###"Finalize o processo de conferência do WMS ou estorne e exclua estes serviços."
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cAcao == "4" //-- Estorno do serviço relacionado no WMS
		If IntWMS((cAliasSD1)->D1_COD) .And. !Empty((cAliasSD1)->D1_SERVIC)
			lRet := WmsEstNfe()
		EndIf
	ElseIf cAcao == "5" //-- Geração da ordem de serviço WMS
		If IntWMS(SD1->D1_COD) .And. SD1->D1_QUANT > 0
			lRet := WmsIntNfe(Nil,lPreNota)
			//valida se todas as DCF foram criadas corretamente
			If lRet
				If !WmsArmUnit(SD1->D1_LOCAL).And. !WmsValDCF() 
					WmsMessage(STR0058,WMSXFUNE42,5)	
					lRet := .F.
				EndIf
			EndIf
		EndIf
		WmsSkipCQ(.F.)
	ElseIf cAcao $ "6|7" //-- Validação da exclusão de uma pre-nota
		If IntWMS((cAliasSD1)->D1_COD)
			If lWmsNew
				If WmsArmUnit((cAliasSD1)->D1_LOCAL) //Verifica se o armazém é unitizado
					WmsChkDCW("5",(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,@cCodRec)
					If !lPreNota
						oDmdUnit := WMSDTCDemandaUnitizacaoDelete():New()
 						oDmdUnit:SetIdD0Q((cAliasSD1)->D1_IDDCF)
 						If oDmdUnit:LoadData() .And. Empty(cCodRec)
	 						If !oDmdUnit:CanDelete()
	 							WmsMessage(WmsFmtMsg(STR0047,{{"[VAR01]",Iif(oDmdUnit:GetStatus() == "2",STR0048,STR0049)}}),WMSXFUNE30,1) //Documento não pode ser excluído ou estornado porque possui demanda de unitização [VAR01]. // em andamento // finalizada
	 							lRet := .F.
	 						EndIf
	 					EndIf
 					EndIf
				Else
					oOrdServ := WMSDTCOrdemServicoDelete():New()
					oOrdServ:SetIdDCF((cAliasSD1)->D1_IDDCF)
					If oOrdServ:LoadData()
						//-- Se for pré-nota, só checa se a conferência não está em andamento
						If lPreNota
							If oOrdServ:GetStServ() == "3" .And. oOrdServ:HaveMovD12('3')
								WmsMessage(WmsFmtMsg(STR0016,{{"[VAR01]",Iif(cAcao=="6",STR0031,STR0032)}}),WMSXFUNE08,,,,STR0017) //"Documento não pode ser [VAR01] porque possui serviços de conferência WMS pendentes."##"alterado"##"excluído"##"Finalize o processo de conferência do WMS ou estorne e exclua estes serviços."
								lRet := .F.
							EndIf
						Else
							If !oOrdServ:CanDelete()
								cMensagem := WmsFmtMsg(STR0018,{{"[VAR01]",Iif(cAcao=="6",STR0031,STR0032)}}) //"Documento não pode ser [VAR01]. Possui serviços de WMS. "##"alterado"##"excluído"
								aMensagem := StrTokArr (oOrdServ:GetErro(), CRLF )
								AEval(aMensagem, {|x| cMensagem += x + " " },2,Len(aMensagem)-2)
								WmsMessage(cMensagem,WMSXFUNE09,,,,STR0019) //"Estorne os serviços WMS manualmente antes deste processo."
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				If WmsChkDCF("SD1",,,SD1->D1_SERVIC,'3',,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,SD1->D1_COD,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_NUMSEQ,SD1->D1_IDDCF)
					//-- Se for pré-nota, só checa se a conferência não está em andamento
					If lPreNota
						If WmsChkSDB('3')
							WmsMessage(WmsFmtMsg(STR0016,{{"[VAR01]",Iif(cAcao=="6",STR0031,STR0032)}}),WMSXFUNE21,,,,STR0017) //"Documento não pode ser [VAR01] porque possui serviços de conferência WMS pendentes."##"alterado"##"excluído"##"Finalize o processo de conferência do WMS ou estorne e exclua estes serviços."
							lRet := .F.
						EndIf
					Else
						If !WmsAvalDCF("2",,.F.)
							cMensagem := WmsFmtMsg(STR0018,{{"[VAR01]",Iif(cAcao=="6",STR0031,STR0032)}}) //"Documento não pode ser [VAR01]. Possui serviços de WMS. "##"alterado"##"excluído"
							aMensagem := StrTokArr (WmsLastMsg(), CLRF )
							AEval(aMensagem, {|x| cMensagem += x + " " },2,Len(aMensagem)-2)
							WmsMessage(cMensagem,WMSXFUNE22,,,,STR0019) //"Estorne os serviços WMS manualmente antes deste processo."
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*-----------------------------------------------------------------------------
Efetua a integração da nota de entrada com o WMS gerando:
 - Apenas movimentação de falta quando o armazém for o parametrizado no WMS e possuir conferência
 - Uma demanda de unitização quando armazém controlar unitizador, desde que não seja armazém CQ
 - Uma ordem de serviço de endereçamento para a quantidade recebida na sequencia da nota
-----------------------------------------------------------------------------*/
Function WmsIntNfe(nRecSD1,lPreNota)
Local lRet     := .T.
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local nPosDCF  := 0
Local nRecnoSD7:= 0
Local oOrdServ := WmsOrdSer() // Busca referencia do objeto WMS
Local aLibDCF  := WmsLibDCF() // Busca referencia do array WMS
Local oDmdUnit := Nil
Local cCodRec  := ""
Local cWmsLcFt := PadR(SuperGetMV("MV_WMSLCFT",.F.,""),TamSx3("D1_LOCAL")[1]) // Local de falta
Local cWmsEndFt:= SuperGetMV("MV_WMSENFT",.F.,"") // Endereço de falta
Local cLocalCQ := PadR(SuperGetMV("MV_CQ",.F.,""),TamSx3("D1_LOCAL")[1])

Default nRecSD1 := 0

	If nRecSD1 > 0
		SD1->(MsGoTo(nRecSD1))
	EndIf
	If lWmsNew
		// Quando a OP está preenchida, cai no processo de beneficiamento
		// O qual será baixado automaticamente a requisição do produto da OP, não chegando a passar pelo armazém
		// A baixa da requisição é efetuada pelo documento de entrada com o objetivo de utilizar o custo completo do produto ao invés do custo médio
		// Casos em que a peça sofreu adaptações por terceiros
		If !Empty(SD1->D1_OP)
			// Será realizado a baixa da requisição automaticamente na função MaAvalSD1, efetuando somente D13 neste ponto
			lRet := WmsIKdxBen("SD1")
		ElseIf (SD1->D1_LOCAL == cLocalCQ) .And.  WmsSkipCQ()
			//Cria ordem de serviço
			If oOrdServ == Nil
				oOrdServ := WMSDTCOrdemServicoCreate():New()
				WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
			EndIf
			oOrdServ:SetNumSeq(SD1->D1_NUMSEQ)
			oOrdServ:oOrdEndDes:SetEnder(SD1->D1_ENDER)
			oOrdServ:SetOrigem('SD1')
			If !oOrdServ:CreateDCF()
				WmsMessage(oOrdServ:GetErro()+" "+STR0039,WMSXFUNE31,,,,STR0040)  //"A OS WMS não foi gerada." //"Depois de regularizar a situação, o documento deverá ser incluído novamente para a correta geração da OS WMS."
				lRet := .F.
			EndIf
			//Executa ordem de serviço
			If lRet
				AAdd(oOrdServ:aLibDCF,oOrdServ:GetIdDCF())
				WmsExeServ(.F.)  
			EndIf
			//Finaliza movimentação
			If lRet
				If !(lRet := ExeMovWMS())
					WmsMessage(oOrdServ:GetErro()+" "+STR0050,WMSXFUNE32,,,,STR0040)  //Movimentação WMS não executada. //"Depois de regularizar a situação, o documento deverá ser incluído novamente para a correta geração da OS WMS."
				EndIF
			EndIf
			//No caso de skip de lote é necessário integrar a liberação automática de CQ
			If lRet 
				nRecnoSD7 := WmsRecSD7(SD1->D1_COD,SD1->D1_NUMSEQ)
				WmsSkipCQ(.F.)
				If !(lRet := WmsIntCQ(nRecnoSD7))
					WmsMessage(oOrdServ:GetErro()+" "+STR0051,WMSXFUNE33,,,,STR0040)  //Integração do registro de liberação de CQ não realizada. //"Depois de regularizar a situação, o documento deverá ser incluído novamente para a correta geração da OS WMS."
				EndIf
			EndIf
		ElseIf SD1->D1_LOCAL == cWmsLcFt .And. Alltrim(SD1->D1_ENDER) == Alltrim(cWmsEndFt)
			// Busca o código da conferência
			WmsChkDCW("5",SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,@cCodRec)
			If !Empty(cCodRec)
				lRet := WmsArmFalt("SD1")
			EndIf
		// No armazém de qualidade nunca irá gerar demanda de unitização
		ElseIf !(SD1->D1_LOCAL == cLocalCQ) .And. WmsArmUnit(SD1->D1_LOCAL) //Verifica se deve unitizar o produto
			oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
			oDmdUnit:SetNumSeq(SD1->D1_NUMSEQ)
			oDmdUnit:SetOrigem('SD1')
			lRet := oDmdUnit:CreateD0Q()
			If !lRet 
				WmsMessage(oDmdUnit:GetErro()+" "+STR0056,WMSXFUNE40,,,,) //"Erro na geração da demanda de unitização."
			EndIF
		Else
			//-- Somente cria a ordem de serviço na primeira vez
			If oOrdServ == Nil
				oOrdServ := WMSDTCOrdemServicoCreate():New()
				WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
			EndIf
			oOrdServ:SetNumSeq(SD1->D1_NUMSEQ)
			oOrdServ:SetOrigem('SD1')
			If !oOrdServ:CreateDCF()
				WmsMessage(oOrdServ:GetErro()+" "+STR0039,WMSXFUNE25,,,,STR0040)  //"A OS WMS não foi gerada." //"Depois de regularizar a situação, o documento deverá ser incluído novamente para a correta geração da OS WMS."
				lRet := .F.
			EndIf
			//Executa ordem de serviço se for automático
			If lRet .And. WmsVldSrv('4', SD1->D1_SERVIC)
				AAdd(oOrdServ:aLibDCF,oOrdServ:GetIdDCF())
				WmsExeServ(.F.)  
			EndIf
		EndIf
	Else
		//-- Somente na pré-nota que gera a OS neste momento
		If lPreNota
			WmsCriaDCF('SD1',,,,@nPosDCF )
			If !Empty(nPosDCF) .And. WmsVldSrv('4',SD1->D1_SERVIC)
				AAdd(aLibDCF,nPosDCF)
			EndIf
		EndIf
	EndIf
Return lRet
/*-----------------------------------------------------------------------------
Efetua o estorna da integração da nota de entrada com o WMS
-----------------------------------------------------------------------------*/
Function WmsEstNfe(nRecSD1)
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oOrdSerDel := Nil
Local oDmdUniDel := Nil
Local cCodRec    := ""
Local cAliasQry  := Nil
Local cWmsLcFt   := PadR(SuperGetMV("MV_WMSLCFT",.F.,""),TamSx3("D1_LOCAL")[1]) // Local de falta
Local cWmsEndFt  := SuperGetMV("MV_WMSENFT",.F.,"") // Endereço de falta
Local cLocalCQ   := PadR(SuperGetMV("MV_CQ",.F.,""),TamSx3("D1_LOCAL")[1])

Default nRecSD1 := 0

	If nRecSD1 > 0
		SD1->(MsGoTo(nRecSD1))
	EndIf

	If !lWmsNew
		WmsDelDCF('1','SD1')
	Else
		WmsChkDCW("5",SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,@cCodRec)
		If !Empty(SD1->D1_OP)
			// Gera os movimentos de kardex reverso do processo de beneficiamento com OP
			lRet := WmsEKdxBen("SD1")
		ElseIf SD1->D1_LOCAL == cWmsLcFt .And. Alltrim(SD1->D1_ENDER) == Alltrim(cWmsEndFt)
			If !Empty(cCodRec)
				lRet := WmsEstFalt("SD1")
			EndIf
		// No armazém de qualidade nunca irá gerar demanda de unitização
		ElseIf !(SD1->D1_LOCAL == cLocalCQ) .And. WmsArmUnit(SD1->D1_LOCAL) //Verifica se deve unitizar o produto
			If Empty(cCodRec)
				oDmdUniDel := WMSDTCDemandaUnitizacaoDelete():New()
				oDmdUniDel:SetIdD0Q(SD1->D1_IDDCF)
				If oDmdUniDel:LoadData()
					oDmdUniDel:DeleteD0Q()
				EndIf
				FreeObj(oDmdUniDel)
			Else		
				//Realiza ajustes de saldo apenas no primeiro estorno de classificação associado ao código da conferência
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT 1
					FROM %Table:DCX% DCX
					WHERE DCX.DCX_FILIAL = %xFilial:DCX%
					AND DCX.DCX_EMBARQ = %Exp:cCodRec%
					AND DCX.%NotDel%
					AND EXISTS (SELECT 1
								FROM %Table:SD1% SD1
								WHERE SD1.D1_FILIAL = %xFilial:SD1%
								AND SD1.D1_DOC = DCX.DCX_DOC
								AND SD1.D1_SERIE = DCX.DCX_SERIE
								AND SD1.D1_FORNECE = DCX.DCX_FORNEC
								AND SD1.D1_LOJA = DCX.DCX_LOJA
								AND SD1.D1_TES = ' '
								AND SD1.%NotDel% )
				EndSql
				If (cAliasQry)->(Eof())
					//Ajusta D14
					WMSA320D14(cCodRec,.T.)
				EndIf
				(cAliasQry)->(DbCloseArea())
				
				oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetDocto(SD1->D1_DOC)
				oOrdSerDel:SetSerie(SD1->D1_SERIE)
				oOrdSerDel:SetCliFor(SD1->D1_FORNECE)
				oOrdSerDel:SetLoja(SD1->D1_LOJA)
				oOrdSerDel:SetNumSeq(SD1->D1_NUMSEQ)
				oOrdSerDel:SetQuant (SD1->D1_QUANT)
				oOrdSerDel:SetIdDCF(SD1->D1_IDDCF)
				oOrdSerDel:SetOrigem("SD1")
				oOrdSerDel:oServico:SetServico(SD1->D1_SERVIC)
				oOrdSerDel:oOrdEndOri:SetArmazem(SD1->D1_LOCAL)
				oOrdSerDel:oOrdEndOri:SetEnder(SD1->D1_ENDER)
				oOrdSerDel:oProdLote:SetPrdOri(SD1->D1_COD)
				oOrdSerDel:oProdLote:SetProduto(SD1->D1_COD)
				oOrdSerDel:oProdLote:SetArmazem(SD1->D1_LOCAL)
				oOrdSerDel:oProdLote:SetLotectl(SD1->D1_LOTECTL)
				oOrdSerDel:oProdLote:SetNumLote(SD1->D1_NUMLOTE)
				oOrdSerDel:oProdLote:LoadData()
				oOrdSerDel:UndoIntegr()
				oOrdSerDel:DelDCFUni(cCodRec)
			EndIf
		Else
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			oOrdSerDel:SetIdDCF(SD1->D1_IDDCF)
			If oOrdSerDel:LoadData()
				oOrdSerDel:DeleteDCF()
			EndIf
			FreeObj(oOrdSerDel)
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------
/*{Protheus.doc} WmsChkDCW
Verifica se existe conferência de recebimento não iniciada ou em andamento para a nota

@author  Guilherme Alexandre Metzger
@version P11
@Since   23/06/2014
*/
//--------------------------------------------------------------
Function WmsChkDCW(cAcao,cDocumento,cSerie,cFornecedor,cLoja,cCodRec)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasDCW := Nil
Local cAcaoNota := ""
// Variável que recebe os possíveis status da conferência
Local aStatus := StrTokArr(Posicione('SX3',2,'DCW_SITEMB','X3CBox()'),';')

	If cAcao $ "1|2|3|4|5"
		cAliasDCW := GetNextAlias()
		BeginSql Alias cAliasDCW
			SELECT DCW_EMBARQ,
			       DCW_SITEMB,
			       DCW_TPCONF
			FROM %Table:DCX% DCX
			INNER JOIN %Table:DCW% DCW
			ON DCW.DCW_FILIAL = %xFilial:DCW%
			AND DCW.DCW_EMBARQ = DCX.DCX_EMBARQ
			AND DCW.%NotDel%
			WHERE DCX.DCX_FILIAL = %xFilial:DCX%
			AND DCX.DCX_DOC = %Exp:cDocumento%
			AND DCX.DCX_SERIE = %Exp:cSerie%
			AND DCX.DCX_FORNEC = %Exp:cFornecedor%
			AND DCX.DCX_LOJA = %Exp:cLoja%
			AND DCX.%NotDel%
		EndSql
		If !(cAliasDCW)->(Eof())
			// Classificação ou Estorno de Classificação
			If cAcao $ "1|2"
				// Se for estorno de classificação e a conferência tiver sido feita a partir do documento de entrada
				If cAcao == "2" .And. (cAliasDCW)->DCW_TPCONF == '2'
					WmsMessage(WmsFmtMsg(STR0046,{{"[VAR01]",(cAliasDCW)->DCW_EMBARQ}}),WMSXFUNE26,,,,STR0021) // Documento não pode ter sua classificação estornada porque está vinculado ao processo de conferência [VAR01] no WMS que foi originado a partir do documento classificado. ### Retire o documento da conferência ou exclua o processo de conferência no WMS.
					lRet := .F.
				// Se for classificação ou estorno de classificação e o status da conferência for igual a finalizado ou finalizado com divergência
				ElseIf !((cAliasDCW)->DCW_SITEMB $ '6|7|8')
					cAcaoNota := Iif(cAcao=="1",STR0033,STR0034) // classificado // estornado a classificação
					WmsMessage(WmsFmtMsg(STR0022,{{"[VAR01]",(cAliasDCW)->DCW_EMBARQ},{"[VAR02]",cAcaoNota},{"[VAR03]",aStatus[Val((cAliasDCW)->DCW_SITEMB)]}}),WMSXFUNE11,,,,STR0023) // Documento não pode ser [VAR02] porque está vinculado ao processo de conferência [VAR01] no WMS que está [VAR03]. ### Finalize o processo de conferência ou retire o documento da conferência no WMS.
					lRet := .F.
				EndIf
			// Alteração
			ElseIf cAcao == "3"
				WmsMessage(WmsFmtMsg(STR0045,{{"[VAR01]",(cAliasDCW)->DCW_EMBARQ}}),WMSXFUNE34,,,,STR0021) // Documento não pode ser alterado porque está vinculado ao processo de conferência [VAR01] no WMS. ### Retire o documento da conferência ou exclua o processo de conferência no WMS.
				lRet := .F.
			// Exclusão
			ElseIf cAcao == "4"
				WmsMessage(WmsFmtMsg(STR0020,{{"[VAR01]",(cAliasDCW)->DCW_EMBARQ}}),WMSXFUNE10,,,,STR0021) // Documento não pode ser excluído porque está vinculado ao processo de conferência [VAR01] no WMS. ### Retire o documento da conferência ou exclua o processo de conferência no WMS.
				lRet := .F.
			// Busca do registro de conferência
			ElseIf cAcao == "5"
				cCodRec := (cAliasDCW)->DCW_EMBARQ
			EndIf
		EndIf
		(cAliasDCW)->(DbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*-----------------------------------------------------------------------------
Valida a a distribuição de uma nota fiscal de entrada
Efetua validações com base no cabeçalho das notas fiscais
-----------------------------------------------------------------------------*/
Function WmsChkD07(cAcao,cDocumento,cSerie,cFornecedor,cLoja)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasD06 := Nil

	If cAcao $ "1|2|3|4"
		cAliasD06 := GetNextAlias()
		BeginSql Alias cAliasD06
			SELECT D06_CODDIS,
					D06_SITDIS
			FROM %Table:D07% D07
			INNER JOIN %Table:D06% D06
			ON D06_FILIAL = %xFilial:D06%
			AND D06_CODDIS = D07_CODDIS
			AND D06_SITDIS <> '3'
			AND D06.%NotDel%
			WHERE D07_FILIAL = %xFilial:D07%
			AND D07_DOC = %Exp:cDocumento%
			AND D07_SERIE = %Exp:cSerie%
			AND D07_FORNEC = %Exp:cFornecedor%
			AND D07_LOJA = %Exp:cLoja%
			AND D07.%NotDel%
		EndSql
		If (cAliasD06)->(!Eof())
			If cAcao == "4" //-- Exclusão da NF
				WmsMessage(WmsFmtMsg(STR0024,{{"[VAR01]",(cAliasD06)->D06_CODDIS},{"[VAR02]",STR0032}}),WMSXFUNE13,,,,STR0025) // Documento não pode ser [VAR02] porque está vinculado ao processo de distribuição [VAR01] no WMS."##"excluído"##"É necessário primeiro desvincular o documento da distribuição no WMS.
				lRet := .F.
			Else
				If cAcao == "1" //-- Classificação da NF
					If (cAliasD06)->D06_SITDIS == "1"
						WmsMessage(WmsFmtMsg(STR0026,{{"[VAR01]",(cAliasD06)->D06_CODDIS}}),WMSXFUNE12,,,,STR0027) //"Documento não pode ser classificado porque está vinculado ao processo de distribuição [VAR01] no WMS que está em 'Aberto'."###"Para classificar este documento é preciso que a montagem da distribuição esteja 'Distribuída' acionando a opção 'Manutenção' da rotina (WMSA325)."
						lRet := .F.
					EndIf
				Else //-- Alteração da NF
					If (cAliasD06)->D06_SITDIS != "3"
						WmsMessage(WmsFmtMsg(STR0024,{{"[VAR01]",(cAliasD06)->D06_CODDIS},{"[VAR02]",STR0031}}),WMSXFUNE23,,,,STR0025) // Documento não pode ser [VAR02] porque está vinculado ao processo de distribuição [VAR01] no WMS."##"alterado"##"É necessário primeiro desvincular o documento da distribuição no WMS.
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		(cAliasD06)->(DbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*-----------------------------------------------------------------------------
Valida produtos componentes, verifica rastro, controle de endereço e controle WMS.
-----------------------------------------------------------------------------*/
Function WmsAvalCmp(cPai)
Local lRet        := .T.
Local lRastroPai  := Rastro(cPai)
Local cComponente := " "

	dbSelectArea('D11')
	D11->(dbSetOrder(1)) //D11_FILIAL+D11_PRODUT+D11_PRDORI+D11_PRDCMP

	If dbSeek(xFilial('D11')+cPai)
		While D11->(!EoF()) .And. D11->D11_FILIAL == xFilial('D11') .And. D11->D11_PRODUT == cPai
			cComponente := D11->D11_PRDCMP
			If IntWms(cComponente)
				If lRastroPai != Rastro(cComponente)
					WmsMessage(STR0035,WMSXFUNE15,,,,WmsFmtMsg(STR0036,{{"[VAR01]",cComponente},{"[VAR02]",cPai}})) //Produto componente inválido /O componente [VAR01]  não possuí o mesmo controle de rastro do produto pai [VAR02].
					lRet := .F.
					Exit
				EndIf
			Else
				WmsMessage(STR0035,WMSXFUNE16,,,,WmsFmtMsg(STR0037,{{"[VAR01]",cComponente},{"[VAR02]",cPai}})) //Produto componente inválido //O componente [VAR01] do produto [VAR02] não possuí controle WMS.
				lRet := .F.
				Exit
			EndIf
			D11->(dbSkip())
		EndDo
	EndIf

Return lRet
/*-----------------------------------------------------------------------------
Realiza armazenagem de produtos no armazém de falta.
Nesses casos não precisa gerar ordem de serviço.
-----------------------------------------------------------------------------*/
Function WmsArmFalt(cAliasSD1)
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local oProdComp  := WMSDTCProdutoComponente():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	oProdComp:SetPrdOri((cAliasSD1)->D1_COD)
	If oProdComp:LoadData(3) .And. oProdComp:GetNivel() == 1
		oProdComp:EstProduto()
		aProduto := oProdComp:GetArrProd()
	Else
		aAdd(aProduto,{(cAliasSD1)->D1_COD,1,(cAliasSD1)->D1_COD})
	EndIf
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem((cAliasSD1)->D1_LOCAL)
			oEstEnder:oEndereco:SetEnder((cAliasSD1)->D1_ENDER)
			oEstEnder:oProdLote:SetArmazem((cAliasSD1)->D1_LOCAL) // Armazem
			oEstEnder:oProdLote:SetPrdOri((cAliasSD1)->D1_COD)   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl((cAliasSD1)->D1_LOTECTL) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote((cAliasSD1)->D1_NUMLOTE) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:LoadData()
			oEstEnder:SetQuant(QtdComp((cAliasSD1)->D1_QUANT * aProduto[nProduto][2]) )
			// Seta o bloco de código para informações do documento
			oEstEnder:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem("SD1"),;
				oMovEstEnd:SetDocto((cAliasSD1)->D1_DOC),;
				oMovEstEnd:SetSerie((cAliasSD1)->D1_SERIE),;
				oMovEstEnd:SetCliFor((cAliasSD1)->D1_FORNECE),;
				oMovEstEnd:SetLoja((cAliasSD1)->D1_LOJA),;
				oMovEstEnd:SetNumSeq((cAliasSD1)->D1_NUMSEQ);
			})
			// Seta o bloco de código para informações do movimento
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto(""),;
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetIdUnit("");
			})
			// Realiza Entrada Armazem Estoque por Endereço
			oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
		Next nProduto
	EndIf
Return lRet
/*-----------------------------------------------------------------------------
Realiza estorno da armazenagem de produtos no armazém de falta.
Nesses casos não existe ordem de serviço.
-----------------------------------------------------------------------------*/
Function WmsEstFalt(cAliasSD1)
Local lRet       := .T.
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
Local oProdComp  := WMSDTCProdutoComponente():New()
	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	oProdComp:SetPrdOri((cAliasSD1)->D1_COD)
	If oProdComp:LoadData(3) .And. oProdComp:GetNivel() == 1
		oProdComp:EstProduto()
		aProduto := oProdComp:GetArrProd()
	Else
		aAdd(aProduto,{(cAliasSD1)->D1_COD,1,(cAliasSD1)->D1_COD})
	EndIf
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Carrega dados para Estoque por Endereço
			oEstEnder:oEndereco:SetArmazem((cAliasSD1)->D1_LOCAL)
			oEstEnder:oEndereco:SetEnder((cAliasSD1)->D1_ENDER)
			oEstEnder:oProdLote:SetArmazem((cAliasSD1)->D1_LOCAL) // Armazem
			oEstEnder:oProdLote:SetPrdOri((cAliasSD1)->D1_COD)   // Produto Origem
			oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
			oEstEnder:oProdLote:SetLoteCtl((cAliasSD1)->D1_LOTECTL) // Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:oProdLote:SetNumLote((cAliasSD1)->D1_NUMLOTE) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			oEstEnder:LoadData()
			oEstEnder:SetQuant(QtdComp((cAliasSD1)->D1_QUANT * aProduto[nProduto][2]) )
			// Seta o bloco de código para informações do documento
			oEstEnder:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem("SD1"),;
				oMovEstEnd:SetDocto((cAliasSD1)->D1_DOC),;
				oMovEstEnd:SetSerie((cAliasSD1)->D1_SERIE),;
				oMovEstEnd:SetCliFor((cAliasSD1)->D1_FORNECE),;
				oMovEstEnd:SetLoja((cAliasSD1)->D1_LOJA),;
				oMovEstEnd:SetNumSeq((cAliasSD1)->D1_NUMSEQ);
			})
			// Seta o bloco de código para informações do movimento
			oEstEnder:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdMovto(""),;
				oMovEstEnd:SetIdOpera(""),;
				oMovEstEnd:SetIdUnit("");
			})
			// Realiza Entrada Armazem Estoque por Endereço
			oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
		Next nProduto
	EndIf
Return lRet
// ---------------------------------------------------------
/*/{Protheus.doc} WmsSkipCQ
Atualiza o campo logico __lSkipCQ definir se houve skip de lote
do produto por conta da integração com o módulo de inspeção de entrada 

@author  Amanda Rosa Vieira
@version P12
@Since   01/01/2012
/*/
// ---------------------------------------------------------
Static __lSkipCQ := .F. // Determina se o skip lote por meio da integração com o módulo de inspeção de entrada
Function WmsSkipCQ(lSkipCQ)
	If ValType(lSkipCQ) == "L"
		__lSkipCQ := lSkipCQ
	EndIf
Return __lSkipCQ
/*-----------------------------------------------------------------------------
Executa movimentação WMS
-----------------------------------------------------------------------------*/
Static Function ExeMovWMS()
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local oMovimento := WMSBCCMovimentoServico():New()
Local cAliasQry:= GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT D12.R_E_C_N_O_ RECNOD12
		FROM %Table:D12% D12
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_DOC = %Exp:SD1->D1_DOC%
		AND D12.D12_SERIE = %Exp:SD1->D1_SERIE%
		AND D12.D12_CLIFOR = %Exp:SD1->D1_FORNECE%
		AND D12.D12_LOJA = %Exp:SD1->D1_LOJA%
		AND D12.D12_SERVIC = %Exp:SD1->D1_SERVIC%
		AND D12.D12_IDDCF = %Exp:SD1->D1_IDDCF%
		AND D12.%NotDel%
		ORDER BY D12_ORDTAR,
					D12_IDMOV,
					D12_ORDATI
	EndSql
	Do While lRet .And. (cAliasQry)->(!Eof())
		oMovimento:GoToD12((cAliasQry)->RECNOD12)
		oMovimento:SetLog("2")
		oMovimento:SetStatus("1")
		oMovimento:SetPrAuto("2")
		oMovimento:SetDataIni(dDataBase)
		oMovimento:SetHoraIni(Time())
		oMovimento:SetDataFim(dDataBase)
		oMovimento:SetHoraFim(Time())
		oMovimento:SetRecHum(__cUserID)
		oMovimento:SetQtdLid(oMovimento:GetQtdMov())
		oMovimento:SetRadioF("2")
		oMovimento:UpdateD12()
		// Finalizar ou Apontar a movimentação
		If lRet .And. oMovimento:IsUltAtiv()
			If oMovimento:IsUpdEst()
				lRet := oMovimento:RecEnter()
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------
/*/{Protheus.doc} WmsIKdxBen
Efetua uma movimentação de entrada e saída de um endereço, caracterizando 
um deslocamento que não foi armazenado
@author felipe.m
@since 29/01/2018
@version 1.0
@param cAliasSD1, characters, (Alias do arquivo SD1, sendo possível passar o alias do select)
@param lEstorno, logical, (Indica se é uma movimentação de estorno)
@return return, retorno lógico de sucesso ou falha do processo
/*/
//-----------------------------------------------------------------------
Static Function WmsIKdxBen(cAliasSD1,lEstorno)
Local aAreaAnt := GetArea()
Local lRet := .T.
Local aProduto := {}
Local nProduto := 0
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()
Local oProdComp := WMSDTCProdutoComponente():New()
Default lEstorno := .F.

	oProdComp:SetPrdOri((cAliasSD1)->D1_COD)
	If oProdComp:LoadData(3) .And. oProdComp:GetNivel() == 1
		oProdComp:EstProduto()
		aProduto := oProdComp:GetArrProd()
	Else
		aAdd(aProduto,{(cAliasSD1)->D1_COD,1,(cAliasSD1)->D1_COD})
	EndIf
	
	If Len(aProduto) > 0
		For nProduto := 1 To Len(aProduto)
			// Dados do documento origem
			oMovEstEnd:SetDocto((cAliasSD1)->D1_DOC)
			oMovEstEnd:SetSerie((cAliasSD1)->D1_SERIE)
			oMovEstEnd:SetCliFor((cAliasSD1)->D1_FORNECE)
			oMovEstEnd:SetLoja((cAliasSD1)->D1_LOJA)
			oMovEstEnd:SetOrigem("SD1")
			oMovEstEnd:SetNumSeq((cAliasSD1)->D1_NUMSEQ)
			// Dados do produto
			oMovEstEnd:SetPrdOri((cAliasSD1)->D1_COD)
			oMovEstEnd:SetProduto(aProduto[nProduto][1])
			oMovEstEnd:SetLoteCtl((cAliasSD1)->D1_LOTECTL)
			oMovEstEnd:SetNumLote((cAliasSD1)->D1_NUMLOTE)
			// Dados do endereço
			oMovEstEnd:SetArmazem((cAliasSD1)->D1_LOCAL)
			oMovEstEnd:SetEnder((cAliasSD1)->D1_ENDER)
			// Dados do movimento
			oMovEstEnd:SetQtdEst((cAliasSD1)->D1_QUANT * aProduto[nProduto][2])
			oMovEstEnd:SetDtEsto(dDataBase)
			oMovEstEnd:SetHrEsto(Time())
			If lEstorno
				oMovEstEnd:SetUsaCalc("2")
			EndIf			
			oMovEstEnd:SetTipMov("499")
			If !(lRet := oMovEstEnd:RecordD13())
				WmsMessage(oMovEstEnd:GetErro(),WMSXFUNE35)
			EndIf
			
			If lRet
				oMovEstEnd:SetTipMov("999")
				If !(lRet := oMovEstEnd:RecordD13())
					WmsMessage(oMovEstEnd:GetErro(),WMSXFUNE36)
				EndIf
			EndIf
		Next nProduto
	EndIf
	RestArea(aAreaAnt)
Return lRet 
//-----------------------------------------------------------------------
/*/{Protheus.doc} WmsEKdxBen
Registra as movimentações do kardex reverso da movimentação original e marca 
para não serem utilizadas no fechamento
@author felipe.m
@since 29/01/2018
@version 1.0
@param cAliasSD1, characters, (Alias do arquivo SD1, sendo possível passar o alias do select)
@return return, retorno lógico de sucesso ou falha do processo
/*/
//-----------------------------------------------------------------------
Static Function WmsEKdxBen(cAliasSD1)
Local lRet := .T.
Local aAreaAnt := GetArea()
Local cQuery := ""

	If WmsX312118("D13","D13_USACAL")
		cQuery := "UPDATE "+RetSqlName("D13")
		cQuery +=   " SET D13_USACAL = '2'"
		cQuery += " WHERE D13_FILIAL = '"+xFilial("D13")+"'"
		cQuery +=   " AND D13_DOC = '"+(cAliasSD1)->D1_DOC+"'"
		cQuery +=   " AND D13_SERIE = '"+(cAliasSD1)->D1_SERIE+"'"
		cQuery +=   " AND D13_CLIFOR = '"+(cAliasSD1)->D1_FORNECE+"'"
		cQuery +=   " AND D13_LOJA = '"+(cAliasSD1)->D1_LOJA+"'"
		cQuery +=   " AND D13_LOCAL = '"+(cAliasSD1)->D1_LOCAL+"'"
		cQuery +=   " AND D13_ENDER = '"+(cAliasSD1)->D1_ENDER+"'"
		cQuery +=   " AND D13_NUMSEQ = '"+(cAliasSD1)->D1_NUMSEQ+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		If !(lRet := !(TcSQLExec(cQuery) < 0))
			WmsMessage(STR0052,WMSXFUNE37) // "Erro na atualização de estorno dos movimentos do WMS"
		EndIf
	EndIf
	If lRet
		// Gera as movimentações de entrada e saída do endereço para o estorno
		lRet := WmsIKdxBen(cAliasSD1,.T./*lEstorno*/)
	EndIf	
	RestArea(aAreaAnt)
Return lRet 

//-----------------------------------------------------------------------
/*/{Protheus.doc} WmsSplitD1
Separa um item da Prenota de Entrada (SD1) de acordo com parâmetros recebidos

@author  Guilherme A. Metzger
@since   14/02/2019
@version 1.0
@obs     Utilizado nos processos de Conf. Recebimento e Distr. Produtos
/*/
//-----------------------------------------------------------------------
Function WmsSplitD1(cRotina,nQtdOri,nQtdSpl,lSubtrai,lExcTotal,cLocal,cProduto,cLote,cSubLote,cCodDis)
Local aAreaAnt  := SB2->(GetArea())
Local aCopiaSD1 := {}
Local cAliasSD1 := Nil
Local nItem     := 1
Local nI        := 1
Local cLocAnt   := ""

Default lExcTotal := .F.
Default cCodDis   := ""
Default cLote     := SD1->D1_LOTECTL
Default cSubLote  := SD1->D1_NUMLOTE

	cLocAnt := SD1->D1_LOCAL

	If Len(__aCposCal) <= 0
		__aCposCal := CposCalc()
	EndIf

	cAliasSD1 := GetNextAlias()
	BeginSql Alias cAliasSD1
		SELECT MAX(SD1.D1_ITEM) D1_ITEM
		FROM %Table:SD1% SD1
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
		AND SD1.D1_DOC = %Exp:SD1->D1_DOC%
		AND SD1.D1_SERIE = %Exp:SD1->D1_SERIE%
		AND SD1.D1_FORNECE = %Exp:SD1->D1_FORNECE%
		AND SD1.D1_LOJA = %Exp:SD1->D1_LOJA%
		AND SD1.D1_QUANT > 0
		AND SD1.D1_OP = ' '
		AND SD1.%NotDel%
	EndSql
	If (cAliasSD1)->(!Eof())
		nItem := Soma1((cAliasSD1)->D1_ITEM)
	EndIf
	(cAliasSD1)->(DbCloseArea())
	// Guarda a quantidade original do item
	nQtdOri := SD1->D1_QUANT
	// Copia para o array o registro a ser duplicado
	For nI := 1 To SD1->(FCount())
		If SD1->(FieldName(nI)) == "D1_ITEM"
			AAdd(aCopiaSD1, nItem)
		ElseIf SD1->(FieldName(nI)) == "D1_QUANT"
			AAdd(aCopiaSD1, nQtdSpl)
		ElseIf SD1->(FieldName(nI)) == "D1_TOTAL"
			AAdd(aCopiaSD1, Iif(lExcTotal,0,nQtdSpl * SD1->D1_VUNIT)) 			
		ElseIf SD1->(FieldName(nI)) == "D1_NUMSEQ"
			AAdd(aCopiaSD1, ProxNum())
		ElseIf !lExcTotal .And. !(SD1->(FieldName(nI)) == "D1_DESC") .And. AScan(__aCposCal,SD1->(FieldName(nI))) > 0 
			// Calcula valores proporcionais para campos predefinidos
			AAdd(aCopiaSD1, CalcProp(SD1->(FieldName(nI)),nQtdSpl,nQtdOri))
		Else
			AAdd(aCopiaSD1,SD1->(FieldGet(nI)))
		EndIf
		// A partir daqui trata os campos de acordo com a rotina, por isso atribui direto o valor no array em vez de criar um novo item
		If cRotina == "WMSA320"
			If SD1->(FieldName(nI)) == "D1_LOCAL"
				aCopiaSD1[nI] := PadR(cLocal,Len(SD1->D1_LOCAL))
			ElseIf SD1->(FieldName(nI)) == "D1_SERVIC"
				If cLocAnt <> cLocal
					aCopiaSD1[nI] := Iif(lSubtrai,Wm320SvcFt(),Wm320SvcEx())
				EndIf
			ElseIf SD1->(FieldName(nI)) == "D1_ENDER"
				If cLocAnt <> cLocal
					aCopiaSD1[nI] := Iif(lSubtrai,Wm320EndFt(),Wm320EndEx())
				EndIf
			ElseIf SD1->(FieldName(nI)) == "D1_QTDCONF"
				aCopiaSD1[nI] := Iif(lSubtrai,0,nQtdSpl)
			ElseIf lExcTotal .And. SD1->(FieldName(nI)) == "D1_COD"
				aCopiaSD1[nI] := cProduto

			//Somente para excesso copia o lote da SD1 do lote original
			ElseIf !lSubtrai .And. SD1->(FieldName(nI)) == "D1_LOTECTL"
				aCopiaSD1[nI] := cLote
			ElseIf !lSubtrai .And. SD1->(FieldName(nI)) == "D1_NUMLOTE"
				aCopiaSD1[nI] := cSubLote
								
			ElseIf lExcTotal .And. SD1->(FieldName(nI)) == "D1_VUNIT"
				aCopiaSD1[nI] := 0
			ElseIf lExcTotal .And. SD1->(FieldName(nI)) == "D1_DTDIGIT"
				aCopiaSD1[nI] := dDataBase
			ElseIf lExcTotal .And. SD1->(FieldName(nI)) == "D1_DTVALID"
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial('SB1')+cProduto))
				aCopiaSD1[nI] := dDataBase + SB1->B1_PRVALID
			EndIf
		ElseIf cRotina == "WMSA325"
			If SD1->(FieldName(nI)) == "D1_SERVIC"
				aCopiaSD1[nI] := Posicione("SB5",1,xFilial("SB5")+SD1->D1_COD,"B5_SERVENT")
			ElseIf SD1->(FieldName(nI)) == "D1_ENDER"
				aCopiaSD1[nI] := Posicione("SB5",1,xFilial("SB5")+SD1->D1_COD,"B5_ENDENT")
			ElseIf SD1->(FieldName(nI)) == "D1_CODDIS"
				aCopiaSD1[nI] := cCodDis
			EndIf
		EndIf
	Next nI
	// Diminui a quantidade faltante do item atual
	If lSubtrai
		WmsSubSD1(cRotina,nQtdSpl,cCodDis)
	EndIf
	//Cria o novo item na SD1
	RecLock('SD1',.T.)
	For nI := 1 To SD1->(FCount())
		SD1->(FieldPut(nI,aCopiaSD1[nI]))
	Next nI
	SD1->D1_VALIPI  := (SD1->D1_BASEIPI * (SD1->D1_IPI     / 100))
	SD1->D1_VALICM  := (SD1->D1_BASEICM * (SD1->D1_PICM    / 100))
	SD1->D1_VALIRR  := (SD1->D1_BASEIRR * (SD1->D1_ALIQIRR / 100))
	SD1->D1_VALINS  := (SD1->D1_BASEINS * (SD1->D1_ALIQINS / 100))
	SD1->D1_VALDESC := (SD1->D1_TOTAL   * (SD1->D1_DESC    / 100))
	SD1->D1_VALIMA  := (SD1->D1_BASIMA  * (SD1->D1_ALIIMA  / 100))
	SD1->D1_VALISS  := (SD1->D1_BASEISS * (SD1->D1_ALIQISS / 100))
	SD1->D1_VALFASE := (SD1->D1_BASFASE * (SD1->D1_ALIFASE / 100))
	SD1->D1_VALFUND := (SD1->D1_BASFUND * (SD1->D1_ALIFUND / 100))
	SD1->D1_VALFEEF := (SD1->D1_BASFEEF * (SD1->D1_ALQFEEF / 100))
	SD1->D1_VALCPB  := (SD1->D1_BASECPB * (SD1->D1_ALIQCPB / 100))
	SD1->D1_VLSENAR := (SD1->D1_BSSENAR * (SD1->D1_ALSENAR / 100))
	SD1->D1_VALFAB  := (SD1->D1_BASEFAB * (SD1->D1_ALIQFAB / 100))
	SD1->D1_VALFAC  := (SD1->D1_BASEFAC * (SD1->D1_ALIQFAC / 100))
	SD1->D1_VALFET  := (SD1->D1_BASEFET * (SD1->D1_ALIQFET / 100))
	SD1->D1_VALCOF  := (SD1->D1_BASECOF * (SD1->D1_ALQCOF  / 100))
	SD1->D1_VLCIDE  := (SD1->D1_BASECID * (SD1->D1_ALQCIDE / 100))
	SD1->D1_VALPIS  := (SD1->D1_BASEPIS * (SD1->D1_ALQPIS  / 100))
	SD1->D1_VALCPM  := (SD1->D1_BASECPM * (SD1->D1_ALQCPM  / 100))
	SD1->D1_VALPRO  := (SD1->D1_BASEPRO * (SD1->D1_ALIQPRO / 100))
	SD1->D1_VALFMD  := (SD1->D1_BASEFMD * (SD1->D1_ALQFMD  / 100))
	SD1->D1_VFCPANT := (SD1->D1_BFCPANT * (SD1->D1_AFCPANT / 100))
	SD1->D1_VALFMP  := (SD1->D1_BASEFMP * (SD1->D1_ALQFMP  / 100))
	SD1->D1_VALSES  := (SD1->D1_BASESES * (SD1->D1_ALIQSES / 100))
	SD1->D1_QTSEGUM := ConvUm(SD1->D1_COD, SD1->D1_QUANT, 0, 2)
	SD1->(MsUnlock())
	// Valida se SB2 existe
	WmsAvalSB2(SD1->D1_LOCAL,SD1->D1_COD)
	// Ajusta SB2->B2_NAOCLAS
	If cRotina == "WMSA320" .And. SB2->(dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL))
		// Grava
		RecLock('SB2',.F.)
		SB2->B2_NAOCLAS += nQtdSpl
		SB2->(MsUnlock())
	EndIf
	RestArea(aAreaAnt)
Return
//----------------------------------------------------------
/*/{Protheus.doc} CalcProp
Calcula os valores proporcionais para o novo item da SD1

@author  Guilherme A. Metzger
@version P12
@since   13/02/2019
/*/
//----------------------------------------------------------
Static Function CalcProp(cCampo,nQuant,nQtdOri)
Local nValor := SD1->&(cCampo)
Local nRet   := 0
	nRet := (nValor * nQuant) / nQtdOri
Return nRet
//----------------------------------------------------------
/*/{Protheus.doc} WmsSubSD1
Subtrai uma quantidade do item da Prenota e atualiza os
valores dos impostos de acordo com a nova quantidade

@author  Guilherme A. Metzger
@version P11
@since   21/11/14
/*/
//----------------------------------------------------------
Function WmsSubSD1(cRotina,nQtdSub,cCodDis)
Local nQtdOrig := 0
Local nI       := 1
Local nPos     := 0

	If Len(__aCposCal) <= 0
		__aCposCal := CposCalc()
	EndIf

	RecLock('SD1',.F.)
	nQtdOrig        :=  SD1->D1_QUANT
	SD1->D1_QUANT   -=  nQtdSub
	SD1->D1_TOTAL   :=  SD1->D1_QUANT * SD1->D1_VUNIT
	// Regra para calcular o valor proporcional da base de impostos e descontos, após a quebra
	For nI := 1 To Len(__aCposCal)
		nPos := SD1->(ColumnPos(__aCposCal[nI]))
		If nPos > 0
			SD1->(FieldPut(nPos, (FieldGet(nPos) * SD1->D1_QUANT) / nQtdOrig))
		EndIf
	Next nI
	// Recalcula o valor dos impostos
	SD1->D1_VALIPI  := (SD1->D1_BASEIPI * (SD1->D1_IPI     / 100))
	SD1->D1_VALICM  := (SD1->D1_BASEICM * (SD1->D1_PICM    / 100))
	SD1->D1_VALIRR  := (SD1->D1_BASEIRR * (SD1->D1_ALIQIRR / 100))
	SD1->D1_VALINS  := (SD1->D1_BASEINS * (SD1->D1_ALIQINS / 100))
	SD1->D1_VALDESC := (SD1->D1_TOTAL   * (SD1->D1_DESC    / 100))
	SD1->D1_VALIMA  := (SD1->D1_BASIMA  * (SD1->D1_ALIIMA  / 100))
	SD1->D1_VALISS  := (SD1->D1_BASEISS * (SD1->D1_ALIQISS / 100))
	SD1->D1_VALFASE := (SD1->D1_BASFASE * (SD1->D1_ALIFASE / 100))
	SD1->D1_VALFUND := (SD1->D1_BASFUND * (SD1->D1_ALIFUND / 100))
	SD1->D1_VALFEEF := (SD1->D1_BASFEEF * (SD1->D1_ALQFEEF / 100))
	SD1->D1_VALCPB  := (SD1->D1_BASECPB * (SD1->D1_ALIQCPB / 100))
	SD1->D1_VLSENAR := (SD1->D1_BSSENAR * (SD1->D1_ALSENAR / 100))
	SD1->D1_VALFAB  := (SD1->D1_BASEFAB * (SD1->D1_ALIQFAB / 100))
	SD1->D1_VALFAC  := (SD1->D1_BASEFAC * (SD1->D1_ALIQFAC / 100))
	SD1->D1_VALFET  := (SD1->D1_BASEFET * (SD1->D1_ALIQFET / 100))
	SD1->D1_VALCOF  := (SD1->D1_BASECOF * (SD1->D1_ALQCOF  / 100))
	SD1->D1_VLCIDE  := (SD1->D1_BASECID * (SD1->D1_ALQCIDE / 100))
	SD1->D1_VALPIS  := (SD1->D1_BASEPIS * (SD1->D1_ALQPIS  / 100))
	SD1->D1_VALCPM  := (SD1->D1_BASECPM * (SD1->D1_ALQCPM  / 100))
	SD1->D1_VALPRO  := (SD1->D1_BASEPRO * (SD1->D1_ALIQPRO / 100))
	SD1->D1_VALFMD  := (SD1->D1_BASEFMD * (SD1->D1_ALQFMD  / 100))
	SD1->D1_VFCPANT := (SD1->D1_BFCPANT * (SD1->D1_AFCPANT / 100))
	SD1->D1_VALFMP  := (SD1->D1_BASEFMP * (SD1->D1_ALQFMP  / 100))
	SD1->D1_VALSES  := (SD1->D1_BASESES * (SD1->D1_ALIQSES / 100))
	SD1->D1_QTSEGUM := ConvUm(SD1->D1_COD, SD1->D1_QUANT, 0, 2)
	// Apenas para distribuição de produtos
	If cRotina == "WMSA325"
		SB5->(DbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+SD1->D1_COD))
			SD1->D1_SERVIC  := SB5->B5_SERECD
			SD1->D1_ENDER   := SB5->B5_ENDECD
		EndIf
		SD1->D1_CODDIS  := cCodDis
	EndIf
	SD1->(MsUnlock())

	// Ajusta SB2->B2_NAOCLAS
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))
	If cRotina == "WMSA320" .And. SB2->(dbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL))
		RecLock('SB2',.F.)
		SB2->B2_NAOCLAS -= nQtdSub
		SB2->(MsUnlock())
	EndIf
Return
//----------------------------------------------------------
/*/{Protheus.doc} CposCalc
Retorna os campos que necessitam de recálculo na quebra de
itens das Prenotas de Entrada (SD1)

@author  Guilherme A. Metzger
@version P12
@since   13/02/2019
/*/
//----------------------------------------------------------
Static Function CposCalc()
Local aCampos := {}

	AAdd(aCampos,"D1_BASEIPI")
	AAdd(aCampos,"D1_BASEICM")
	AAdd(aCampos,"D1_ICMSRET")
	AAdd(aCampos,"D1_BRICMS" )
	AAdd(aCampos,"D1_BASEIRR")
	AAdd(aCampos,"D1_BASEINS")
	AAdd(aCampos,"D1_PESO"   )
	AAdd(aCampos,"D1_VALCMAJ")
	AAdd(aCampos,"D1_BASIMP5")
	AAdd(aCampos,"D1_BASIMP6")
	AAdd(aCampos,"D1_VALIMP5")
	AAdd(aCampos,"D1_VALIMP6")
	AAdd(aCampos,"D1_DESPESA")
	AAdd(aCampos,"D1_II"     )
	AAdd(aCampos,"D1_BASIMP3")
	AAdd(aCampos,"D1_BASIMP4")
	AAdd(aCampos,"D1_VALIMP2")
	AAdd(aCampos,"D1_VALIMP3")
	AAdd(aCampos,"D1_VALIMP4")
	AAdd(aCampos,"D1_BASIMP2")
	AAdd(aCampos,"D1_VALFRE" )
	AAdd(aCampos,"D1_BASIMA" )
	AAdd(aCampos,"D1_BASEISS")
	AAdd(aCampos,"D1_BASFASE")
	AAdd(aCampos,"D1_BASFUND")
	AAdd(aCampos,"D1_VFCPDIF")
	AAdd(aCampos,"D1_VALINP" )
	AAdd(aCampos,"D1_VRDICMS")
	AAdd(aCampos,"D1_QTPCCEN")
	AAdd(aCampos,"D1_POTENCI")
	AAdd(aCampos,"D1_DESCICM")
	AAdd(aCampos,"D1_BASECOF")
	AAdd(aCampos,"D1_BASECSL")
	AAdd(aCampos,"D1_BASEPIS")
	AAdd(aCampos,"D1_ESTCRED")
	AAdd(aCampos,"D1_BASFEEF")
	AAdd(aCampos,"D1_BASECPB")
	AAdd(aCampos,"D1_AVLINSS")
	AAdd(aCampos,"D1_ABATISS")
	AAdd(aCampos,"D1_BASEINP")
	AAdd(aCampos,"D1_DIFAL"  )
	AAdd(aCampos,"D1_VALANTI")
	AAdd(aCampos,"D1_SLDDEP" )
	AAdd(aCampos,"D1_BSSENAR")
	AAdd(aCampos,"D1_BASEFAB")
	AAdd(aCampos,"D1_BASEFAC")
	AAdd(aCampos,"D1_BASEFET")
	AAdd(aCampos,"D1_ABATMAT")
	AAdd(aCampos,"D1_CRPRSIM")
	AAdd(aCampos,"D1_CONIMP" )
	AAdd(aCampos,"D1_ABATINS")
	AAdd(aCampos,"D1_VALPMAJ")
	AAdd(aCampos,"D1_VALCMAJ")
	AAdd(aCampos,"D1_MARGEM" )
	AAdd(aCampos,"D1_BASEFMP")
	AAdd(aCampos,"D1_BASECPM")
	AAdd(aCampos,"D1_CUSRP1" )
	AAdd(aCampos,"D1_CUSRP2" )
	AAdd(aCampos,"D1_VALCSL" )
	AAdd(aCampos,"D1_CUSRP3" )
	AAdd(aCampos,"D1_CUSRP4" )
	AAdd(aCampos,"D1_CUSRP5" )
	AAdd(aCampos,"D1_CRPRESC")
	AAdd(aCampos,"D1_BASEPRO")
	AAdd(aCampos,"D1_BASEFMD")
	AAdd(aCampos,"D1_VOPDIF" )
	AAdd(aCampos,"D1_BASFECP")
	AAdd(aCampos,"D1_BFCPANT")
	AAdd(aCampos,"D1_BSFCCMP")
	AAdd(aCampos,"D1_BSFCPST")
	AAdd(aCampos,"D1_FCPAUX" )
	AAdd(aCampos,"D1_CRPREPR")
	AAdd(aCampos,"D1_VALFDS" )
	AAdd(aCampos,"D1_PRFDSUL")
	AAdd(aCampos,"D1_UFERMS" )
	AAdd(aCampos,"D1_BASESES")
	AAdd(aCampos,"D1_BASNDES")
	AAdd(aCampos,"D1_ICMNDES")
	AAdd(aCampos,"D1_CUSTO")
Return aCampos

/*/{Protheus.doc} WmsIntMI
//Função destinada ao Mercado Internacional - Integração WMS para geração da ordem de serviço
@author amanda.vieira
@since 09/10/2019
@version 1.0

@type function
/*/
Function WmsIntMI()
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cAliasSD1 := "" 
Local cRemito 	:= IIF(cPaisloc $ "ARG|BOL", " AND SD1.D1_REMITO = ' ' AND SD1.D1_SERIREM = ' ' " ," ") // Evita que gere duplicidade de serviços, pois o remito já gera essa informação.
cRemito := "%"+cRemito+"%"

	If lWmsNew
		cAliasSD1 := GetNextAlias()
		BeginSQL Alias cAliasSD1
			SELECT SD1.R_E_C_N_O_ RECNOSD1
			  FROM %Table:SD1% SD1
			 INNER JOIN %Table:SF4% SF4
				ON SF4.F4_FILIAL =  %xFilial:SF4%
			   AND SF4.F4_CODIGO = SD1.D1_TES
			   AND SF4.F4_ESTOQUE = 'S'
			   AND SF4.%NotDel%
			 WHERE SD1.D1_FILIAL = %xFilial:SD1%
			   AND SD1.D1_DOC = %Exp:SF1->F1_DOC%
			   AND SD1.D1_SERIE = %Exp:SF1->F1_SERIE%
			   AND SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE%
			   AND SD1.D1_LOJA = %Exp:SF1->F1_LOJA%
			   AND SD1.%NotDel%
			   %Exp:cRemito% 
		EndSql
		While (cAliasSD1)->(!EoF())
			SD1->(DbGoTo((cAliasSD1)->RECNOSD1))
			lRet := WmsAvalSD1("5","SD1")
			(cAliasSD1)->(DbSkip())
		EndDo
		(cAliasSD1)->(DbCloseArea())
	EndIf
Return lRet

/*/{Protheus.doc} WmsValEsMI
//Função destinada ao Mercado Internacional - Validação de linha da fatura
@author amanda.vieira
@since 09/10/2019
@version 1.0

@type function
/*/
Function WmsValLiMI(aCols,n,aHeader)
Local lRet    := .T.
Local lWmsNew := SuperGetMV("MV_WMSNEW",.F.,.F.)
	If lWmsNew
		lRet := WmsAvalSD1("1","SD1",aCols,n,aHeader)
	EndIf
Return lRet

/*/{Protheus.doc} WmsValEsMI
//Função destinada ao Mercado Internacional - Valida estorno da ordem de serviço
@author amanda.vieira
@since 09/10/2019
@version 1.0

@type function
/*/
Function WmsValEsMI()
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cAliasSD1 := ""
	If lWmsNew
		cAliasSD1 := GetNextAlias()
		BeginSQL Alias cAliasSD1
			SELECT SD1.R_E_C_N_O_ RECNOSD1
			  FROM %Table:SD1% SD1
			 WHERE SD1.D1_FILIAL = %xFilial:SD1%
			   AND SD1.D1_DOC = %Exp:SF1->F1_DOC%
			   AND SD1.D1_SERIE = %Exp:SF1->F1_SERIE%
			   AND SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE%
			   AND SD1.D1_LOJA = %Exp:SF1->F1_LOJA%
			   AND SD1.%NotDel%
		EndSql
		While (cAliasSD1)->(!EoF()) .And. lRet
			SD1->(DbGoTo((cAliasSD1)->RECNOSD1))
			lRet := WmsAvalSD1("7","SD1")
			(cAliasSD1)->(DbSkip())
		EndDo
		(cAliasSD1)->(DbCloseArea())
	EndIf
Return lRet

/*/{Protheus.doc} WmsEsIntMI
//Função destinada ao Mercado Internacional - Estorna ordem de serviço WMS
@author amanda.vieira
@since 09/10/2019
@version 1.0

@type function
/*/
Function WmsEsIntMI()
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cAliasSD1 := ""	
	If lWmsNew
		cAliasSD1 := GetNextAlias()
		BeginSQL Alias cAliasSD1
			SELECT SD1.R_E_C_N_O_ RECNOSD1
			  FROM %Table:SD1% SD1
			 WHERE SD1.D1_FILIAL = %xFilial:SD1%
			   AND SD1.D1_DOC = %Exp:SF1->F1_DOC%
			   AND SD1.D1_SERIE = %Exp:SF1->F1_SERIE%
			   AND SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE%
			   AND SD1.D1_LOJA = %Exp:SF1->F1_LOJA%
			   AND SD1.%NotDel%
		EndSql
		While (cAliasSD1)->(!EoF())
			SD1->(DbGoTo((cAliasSD1)->RECNOSD1))
			lRet := WmsAvalSD1("4","SD1")
			(cAliasSD1)->(DbSkip())
		EndDo
		(cAliasSD1)->(DbCloseArea())
	EndIf

Return lRet

/*/{Protheus.doc} WmsValDCF
//Função destinada aSe foi feito a geração da Ordem de Serviço corretamente - Inclusão  ordem de serviço WMS
@author murilo.brandao
@since 26/11/2022
@version 1.00

@type function
/*/

Function WmsValDCF()
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cAliasSD1 := ""
Local cQuery 	:= ""
Local lValGDCF   := SuperGetMV("MV_WMSVDCF",.F.,.F.) //MV_WMSVDCF

	IF lValGDCF
		If lWmsNew
			cQuery := " SELECT D1_DOC,D1_ITEM,D1_IDDCF,SD1.R_E_C_N_O_ RECNOSD1"
			cQuery += " FROM " + RetSqlName('SD1')+" SD1"
			cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"'"
			cQuery += " AND D1_DOC      = '"+SD1->D1_DOC+"'"
			cQuery += " AND D1_SERIE    = '"+SD1->D1_SERIE+"'"
			cQuery += " AND D1_FORNECE  = '"+SD1->D1_FORNECE+"'"
			cQuery += " AND D1_LOJA     = '"+SD1->D1_LOJA+"'"
			cQuery += " AND D1_COD      = '"+SD1->D1_COD+"'"
			cQuery += " AND D1_ITEM     = '"+SD1->D1_ITEM+"'"
			cQuery += " AND D1_IDDCF    = ' '"
			cQuery += " AND D_E_L_E_T_  = ' ' "
			cQuery:= ChangeQuery(cQuery)
			cAliasSD1 := GetNextAlias()
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSD1,.F.,.T.)
			If (cAliasSD1)->RECNOSD1 > 0
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet
     
