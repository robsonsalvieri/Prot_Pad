#Include 'Protheus.ch'
#Include 'STBChangePay.ch'

//------------------------------------------------------------------------------
/*{Protheus.doc} STBValidPay
Função para validar (permitir) as trocas de pagamentos
@param   	     
@author     Fábio Siqueira dos Santos
@version    P12
@since      26/06/2018
@return     .T. ou .F.
/*/
//------------------------------------------------------------------------------
Function STBValidPay()
Local lRet			:= .T.
Local lChgPay		:= .T.
Local nCont			:= 0
Local nCont2		:= 0
Local nParcela		:= 1
Local nPosForma		:= aScan(aHeadPagto,{ |x| AllTrim(x[2]) == "L4_FORMA"} )
Local nPosValor		:= aScan(aHeadPagto,{ |x| AllTrim(x[2]) == "L4_VALOR"} )
Local nPosParcela	:= aScan(aHeadPagto,{ |x| AllTrim(x[2]) == "L4_PARCELA"} )
Local nPosIdCard	:= aScan(aHeadPagto,{ |x| AllTrim(x[2]) == "L4_FORMAID"} )
Local nPosNvForma	:= aScan(aHeadPagto,{ |x| AllTrim(x[2]) == "L4_NVFORM"} )
Local nPosQtdCard	:= aScan(aHeadPagto,{ |x| AllTrim(x[2]) == "L4_QTDCART"} )
Local nPosNvParc	:= aScan(aHeadPagto,{ |x| AllTrim(x[2]) == "L4_NVPARC"} )
Local cMsg			:= ""
Local aCartoes		:= {}
//Valida se pode ou não adicionar na grid do resumo
If !Empty(oGetResumo:aCols[1][1])
	MsgInfo(STR0001,STR0002) //"Não é possível adicionar as formas de pagamento, pois já foram adicionadas, favor clicar no botão 'Limpar' para alterar as formas alteradas!!!"/"Atenção"
	lRet := .F.
Else
	For nCont := 1 To Len(oGetPagtos:aCols)
		If Empty(oGetPagtos:aCols[nCont][nPosNvForma])
			lChgPay	:= .F.
		Else
			lChgPay := .T.
			Exit
		EndIf
	Next nCont
	If lChgPay
		For nCont := 1 To Len(oGetPagtos:aCols)
			If SubStr(oGetPagtos:aCols[nCont][nPosForma],1,2) == "R$"
				nParcela := 1
			Else
				nParcela := Val(oGetPagtos:aCols[nCont][nPosParcela])
			EndIf  
			If SubStr(oGetPagtos:aCols[nCont][nPosNvForma],1,2) $ "CC|CD"
				If oGetPagtos:aCols[nCont][nPosQtdCard] > 1//Qtde de Cartoes - STIChangePay
					Aadd(aCartoes,{oGetPagtos:aCols[nCont][nPosIdCard],oGetPagtos:aCols[nCont][nPosNvForma], oGetPagtos:aCols[nCont][nPosValor],;
						 oGetPagtos:aCols[nCont][nPosParcela], oGetPagtos:aCols[nCont][nPosQtdCard], oGetPagtos:aCols[nCont][nPosForma]}) //ID Cartão, Nova Forma de Pagamento, Valor, Parcela, Qtde de Cartões, Forma Original
				ElseIf oGetPagtos:aCols[nCont][nPosQtdCard] == 0
					cMsg += STR0003 + AllTrim(oGetPagtos:aCols[nCont][nPosNvForma]) + STR0004 + AllTrim(Str(nCont)) + STR0005 + CHR(13) + CHR(10) //"Foi informado a forma "/" na linha "/" e não foi informado o campo 'Qtde. Cartões'. "
				ElseIf !Empty(oGetPagtos:aCols[nCont][nPosNvParc]) .And. Val(oGetPagtos:aCols[nCont][nPosNvParc]) > nParcela 
					cMsg += STR0006 + AllTrim(Str(nCont)) + " ." + CHR(13) + CHR(10) //"Foi informado quantidade de parcelas maior que a parcela original na linha "  
				EndIf
			ElseIf SubStr(oGetPagtos:aCols[nCont][nPosNvForma],1,2) <> "R$" .And. !Empty(oGetPagtos:aCols[nCont][nPosNvForma]) .And. (Empty(oGetPagtos:aCols[nCont][nPosNvParc]) .Or. Val(oGetPagtos:aCols[nCont][nPosNvParc]) == 0 )
				cMsg += STR0007 + AllTrim(Str(nCont)) + " ." + CHR(13) + CHR(10) //	 
			ElseIf !Empty(oGetPagtos:aCols[nCont][nPosNvParc]) .And. Val(oGetPagtos:aCols[nCont][nPosNvParc]) > nParcela
				cMsg += STR0008 + AllTrim(Str(nCont)) + " ." + CHR(13) + CHR(10) //"Foi informado quantidade de parcelas maior que a parcela original na linha "
			EndIf
		Next nCont
		If Empty(cMsg)
			If Len(aCartoes) > 0
				lRet := STIChgCard(aCartoes)
			EndIf
			If lRet
				For nCont := 1 To Len(oGetPagtos:aCols) 
					If !Empty(oGetPagtos:aCols[nCont][nPosNvForma])
						If SubStr(oGetPagtos:aCols[nCont][nPosNvForma],1,2) $ "CC|CD" .And. oGetPagtos:aCols[nCont][nPosQtdCard] > 1
							For nCont2 := 1 To Len(oGetCards:aCols)
								//verifica qual é o pagamento atual e verifico com o getdados dos cartões
								If SubStr(oGetCards:aCols[nCont2][6],1,2) == SubStr(oGetPagtos:aCols[nCont][nPosForma],1,2) .And. SubStr(oGetCards:aCols[nCont2][1],1,2) == SubStr(oGetPagtos:aCols[nCont][nPosNvForma],1,2) .And. oGetCards:aCols[nCont2][4] == oGetPagtos:aCols[nCont][nPosIdCard]
									Aadd(aColsResumo,{oGetCards:aCols[nCont2][1],oGetCards:aCols[nCont2][2],StrZero(oGetCards:aCols[nCont2][3],2),oGetCards:aCols[nCont2][5],.F.})
								EndIf 	
							Next nCont2		
						ElseIf SubStr(oGetPagtos:aCols[nCont][nPosNvForma],1,2) $ "CC|CD"
							//Pagamento com a forma CC ou CD e definiu um cartão
							Aadd(aColsResumo,{oGetPagtos:aCols[nCont][nPosNvForma],oGetPagtos:aCols[nCont][nPosValor],PadL(AllTrim(oGetPagtos:aCols[nCont][nPosNvParc]),2,"0"),oGetPagtos:aCols[nCont][nPosIdCard],.F.})
						Else
							//Pagamento diferente da forma CC ou CD
							Aadd(aColsResumo,{oGetPagtos:aCols[nCont][nPosNvForma],oGetPagtos:aCols[nCont][nPosValor],PadL(AllTrim(oGetPagtos:aCols[nCont][nPosNvParc]),2,"0"),"",.F.})	 
						EndIf 	
					Else
						//Pagamento não teve alteração
						Aadd(aColsResumo,{oGetPagtos:aCols[nCont][nPosForma],oGetPagtos:aCols[nCont][nPosValor],IIf(SubStr(oGetPagtos:aCols[nCont][nPosNvForma],1,2) == "R$", "01",oGetPagtos:aCols[nCont][nPosParcela]),oGetPagtos:aCols[nCont][nPosIdCard],.F.}) 
					EndIf
				Next nCont
				aDel(aColsResumo, 1) //exclui a primeira linha
				aSize(aColsResumo, Len(aColsResumo) - 1) //seta novo tamanho do array
				oGetResumo:SetArray(aColsResumo,.T.)
				oGetResumo:Refresh()
			EndIf	
		Else
			MsgInfo(Stuff(cMsg,0,0,STR0009 + Chr(13) + Chr(10)),STR0002) //"Favor Verificar: "/"Atenção"
			lRet := .F.
		EndIf
	Else
		MsgInfo(STR0010,STR0002) //"Não foi alterada nenhuma forma, favor realizar as alterações!!!"/"Atenção"
		lRet := .F.
	EndIf
EndIf
Return lRet

//------------------------------------------------------------------------------
/*{Protheus.doc} STBChangePay
Função para confirmar e armazenar na variável de pagamentos os novos pagamentos
@param   	aPagtos     
@author     Fábio Siqueira dos Santos
@version    P12
@since      26/06/2018
@return     Nil
/*/
//------------------------------------------------------------------------------
Function STBChangePay(aPagtos)
Local lRet		:= .F.
Local nCont		:= 0
Local nCont2	:= 0
Local nCampos	:= 0
Local nSobra	:= 0
Local nValorTot	:= 0
Local nValParc	:= 0
Local nTotSobra	:= 0
Local nUltParc	:= 0
Local nTamaCols	:= 0
Local nQtdDel	:= 0
Local nPosForma	:= aScan(aHeadResumo,{ |x| AllTrim(x[2]) == "L4_FORMA"} )
Local nPosValor	:= aScan(aHeadResumo,{ |x| AllTrim(x[2]) == "L4_VALOR"} )
Local nPosFrmId	:= aScan(aHeadResumo,{ |x| AllTrim(x[2]) == "L4_FORMAID"} )
Local nPosParc	:= aScan(aHeadResumo,{ |x| AllTrim(x[2]) == "L4_NVPARC"} )
Local cIdCardCD	:= "00"
Local cIdCardCC	:= "00"

If !Empty(oGetResumo:aCols[1][1]) 
	lRet := .T.
	//Refaz os Id's dos cartões
	For nCont := 1 To Len(aColsResumo)
		If SubStr(aColsResumo[nCont][nPosForma],1,2) $ "CC|CD"
			If SubStr(aColsResumo[nCont][nPosForma],1,2) == "CD"
				cIdCardCD := Soma1(cIdCardCD) 
				aColsResumo[nCont][nPosFrmId] := cIdCardCD  
			Else
				cIdCardCC := Soma1(cIdCardCC) 
				aColsResumo[nCont][nPosFrmId] := cIdCardCC
			EndIf		
		EndIf
	Next nCont
	
	//Refaz os pagamentos com parcelas maior que 1
	For nCont := 1 To Len(aColsResumo)
		If Val(aColsResumo[nCont][nPosParc]) > 1
			nValorTot := aColsResumo[nCont][nPosValor]
			nValParc	:= nValorTot / Val(aColsResumo[nCont][nPosParc])
			For nSobra := 1 To Val(aColsResumo[nCont][nPosParc])
				nTotSobra		+= nValParc - NoRound(nValParc,2)
				If nSobra == Val(aColsResumo[nCont][nPosParc])
					nUltParc := Round(NoRound(nValParc,2) + nTotSobra,2)
				EndIf
			Next 
			nTamaCols := Len(aColsResumo) 
			aSize(aColsResumo,nTamaCols+Val(aColsResumo[nCont][nPosParc]))
			For nCont2 := nTamaCols + 1 To Len(aColsResumo)
				aColsResumo[nCont2] := Array(Len(aColsResumo[nCont]))
				aColsResumo[nCont2][nPosForma]	:= aColsResumo[nCont][nPosForma]
				If nCont2 == Len(aColsResumo)
					aColsResumo[nCont2][nPosValor]	:= nUltParc
				Else
					aColsResumo[nCont2][nPosValor]	:= NoRound(nValParc,2)
				EndIf
				aColsResumo[nCont2][nPosParc]	:= aColsResumo[nCont][nPosParc]
				aColsResumo[nCont2][nPosFrmId]	:= aColsResumo[nCont][nPosFrmId]
				aColsResumo[nCont2][5]			:= .F. //CONTROLE DA LINHA DELETADA
					
			Next nCont2
			aColsResumo[nCont][5] := .T.			 
		EndIf
	Next
	
	//Atualiza aColsResumo removendo itens excluídos
	For nCont:=1 To Len(aColsResumo)
		If aColsResumo[nCont] <> Nil .And. aColsResumo[nCont][5]
			ADel(aColsResumo,nCont)
			nQtdDel += 1
			nCont := 0
			Loop
		EndIf		
	Next nCont
	
	If nQtdDel > 0
		ASize(aColsResumo,Len(aColsResumo)-nQtdDel)
	EndIf
	
	aPagtos := Array(Len(aColsResumo),Len(aPagtos[1]),2) //Quantidade de pagamentos do resumo,quantidade de campos SL4,quantidade de colunas = estrutura do aSL4
	
	SX3->(DbSetOrder(1))
	For nCont := 1 To Len(aPagtos)
		nCampos := 0
		SX3->(DbSeek("SL4")) 
		While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SL4"
			nCampos++		
			aPagtos[nCont][nCampos][1] := AllTrim(SX3->X3_CAMPO)//nome do campo
			aPagtos[nCont][nCampos][2] := CriaVar(aPagtos[nCont][nCampos][1],.T.)//conteúdo (valor)	
				
			SX3->(DbSkip())
		End
	Next nCont
	
	For nCont := 1 To Len(aColsResumo)
		For nCampos := 1 To Len(aPagtos[nCont])
			If aPagtos[nCont][nCampos][1] == "L4_FILIAL"
				aPagtos[nCont][nCampos][2] := xFilial("SL4")	
			ElseIf aPagtos[nCont][nCampos][1] == "L4_NUM"
				aPagtos[nCont][nCampos][2] := cNumOrc	
			ElseIf aPagtos[nCont][nCampos][1] == "L4_DATA"
				aPagtos[nCont][nCampos][2] := DtoS(dDataBase)
			ElseIf aPagtos[nCont][nCampos][1] == "L4_VALOR"
				aPagtos[nCont][nCampos][2] := aColsResumo[nCont][nPosValor]
			ElseIf aPagtos[nCont][nCampos][1] == "L4_FORMA"
				aPagtos[nCont][nCampos][2] := SubStr(aColsResumo[nCont][nPosForma],1,2)
			ElseIf aPagtos[nCont][nCampos][1] == "L4_FORMAID"
				aPagtos[nCont][nCampos][2] := aColsResumo[nCont][nPosFrmId]
			EndIf
		Next nCampos
	Next nCont
		
Else
	MsgInfo(STR0011,STR0002) //"Não foi possível confirmar, pois não há pagamentos informados, favor realizar as alterações!!!"/	
EndIf
Return lRet

//------------------------------------------------------------------------------
/*{Protheus.doc} STBVldCard
Função para validar se todas as informações dos cartões foram preenchidas
@param   	aHeadCard, aColsCard     
@author     Fábio Siqueira dos Santos
@version    P12
@since      26/06/2018
@return     .T. ou .F.
/*/
//------------------------------------------------------------------------------
Function STBVldCard(aHeadCard, aColsCard)
Local lRet		:= .T. 
Local nCont		:= 0
Local nVlrTot	:= 0
Local nPosValor	:= aScan(aHeadCard,{ |x| AllTrim(x[2]) == "L4_VALOR"} )
Local nPosNvParc:= aScan(aHeadCard,{ |x| AllTrim(x[2]) == "L4_NVPARC"} )
Local cMsg		:= ""
Local nPosForOld:= aScan(aHeadCard,{ |x| AllTrim(x[2]) == "L4_OLDFRM"} )
Local nPosForma	:= aScan(aHeadCard,{ |x| AllTrim(x[2]) == "L4_FORMA"} )
Local nPosOldID	:= aScan(aHeadCard,{ |x| AllTrim(x[2]) == "L4_OLDID"} )
Local nPosVlrPgt:= aScan(oGetCards:aHeader,{ |x| AllTrim(x[2]) == "L4_OLDVLR"} )
Local cFormaOri := ""
Local cFormaNew := ""
Local cIdCardOld:= " " //deixar com um espaço, pois caso a primeira linha seja pagamento original diferente de cartão, não existe ID Cartão 

For nCont := 1 To Len(aColsCard)
	If Empty(aColsCard[nCont][nPosValor]) .Or. aColsCard[nCont][nPosValor] == 0
		cMsg += STR0012 + Str(nCont) + ". "  + CHR(13) + CHR(10) //"Não foi informado valor ou o valor está ZERO na linha "
	EndIf 
	If Empty(aColsCard[nCont][nPosNvParc]) .Or. aColsCard[nCont][nPosNvParc] == 0
		cMsg += STR0013 + Str(nCont) + ". " + CHR(13) + CHR(10) //"Não foi informado parcela ou a parcela está ZERO na linha "
	EndIf 
	If aColsCard[nCont][nPosForOld] <> cFormaOri .And. aColsCard[nCont][nPosForma] <> cFormaNew .And. aColsCard[nCont][nPosOldID] <> cIdCardOld
		If nCont > 1 .And. nVlrTot < aColsCard[nCont-1][nPosVlrPgt]
			cMsg += STR0014 + CHR(13) + CHR(10) //"Valor dos pagamentos menor que o valor original. "
		EndIf 
		cFormaOri := aColsCard[nCont][nPosForOld]
		cFormaNew := aColsCard[nCont][nPosForma]
		cIdCardOld:= aColsCard[nCont][nPosOldID]
		nVlrTot	:= 0
		nVlrTot+= oGetCards:aCols[nCont][nPosValor]
	Else
		nVlrTot+= oGetCards:aCols[nCont][nPosValor]	
		If nCont == Len(aColsCard) .And. nVlrTot < aColsCard[nCont][nPosVlrPgt]
			cMsg += STR0014 + CHR(13) + CHR(10) //"Valor dos pagamentos menor que o valor original. "
		EndIf
	EndIf	
Next nCont
If !Empty(cMsg)
	MsgInfo(Stuff(cMsg,0,0,STR0009 + Chr(13) + Chr(10)),STR0002) //"Favor Verificar: "/"Atenção"
	lRet := .F.
EndIf
Return lRet