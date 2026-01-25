#INCLUDE "loca080.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/{PROTHEUS.DOC} LOCA080.PRW
Duplica as Linhas de Locações FPA
@TYPE user Function
@AUTHOR Jose Eulalio
@SINCE 12/05/2022
@VERSION P12
@HISTORY 12/05/2022, Jose Eulalio, Criação da Função
/*/

Function LOCA080()
Local nPosSeqGru	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})
Local nPosAS		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AS"    })
Local nPosViagem	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VIAGEM"})
Local nPosEquip		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GRUA"  })
Local nPosDescEq	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DESGRU"})
Local nPosUltFat	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ULTFAT"})
Local nPosNfRem		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NFREM" })
Local nPosdNfRem	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DNFREM"})
Local nPosSerRem	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SERREM"})
Local nPosIteRem	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ITEREM"})
Local nPosNfRet		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NFRET" })
Local nPosdNfRet	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DNFRET"})
Local nPosProdut	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})
Local nPosNfEnt		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DNFENT"})
Local nPosReboq		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_REBOQI"})
Local nPosDtScr		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTSCRT"})
Local nPosMotRe		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_MOTRET"})
Local nPosNMotR		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NMOTRE"})
Local nPosAjust		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AJUSTE"})
Local nPosDAjus		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DAJUST"})
Local nPosNiver		:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NIVER"})
Local nPosSeqEst	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"}) // Frank em 24/05/23
Local nPosAux		:= 0
Local nQtdCopias	:= 0
Local nX			:= 0
Local nLinhaAtu		:= 0
Local nUltimaLn		:= 0
Local nFim01		:= 0
Local nFim02		:= 0
Local nLenPla		:= 0
//Local cListNoBem	:= ""
Local aListNoBem	:= {}
Local cBemDisp		:= Space(TamSx3("T9_CODBEM")[1])
Local cBemNome		:= Space(TamSx3("T9_NOME")[1])
Local cVazioAs		:= Space(TamSx3("FPA_AS")[1])
Local cVazioViag	:= Space(TamSx3("FPA_VIAGEM")[1])
Local cVazioNFRe	:= Space(TamSx3("FPA_NFREM")[1])
Local cVazioSeRe	:= Space(TamSx3("FPA_SERREM")[1])
Local cVazioItRe	:= Space(TamSx3("FPA_ITEREM")[1])
Local cVazioNfRt	:= Space(TamSx3("FPA_NFRET")[1])
Local cVazioRebo	:= Space(TamSx3("FPA_REBOQI")[1])
Local cVazioMotr	:= Space(TamSx3("FPA_MOTRET")[1])
Local cVazioNMot	:= Space(TamSx3("FPA_NMOTRE")[1])
Local cVazioAjus	:= Space(TamSx3("FPA_AJUSTE")[1])
Local cVazioDAju	:= Space(TamSx3("FPA_DAJUST")[1])
Local cVazioEstr	:= Space(TamSx3("FPA_SEQEST")[1]) // Frank em 24/05/23
Local aCoors		:= FwGetDialogSize()
Local aRetBem		:= {}
Local aHead080		:= {}
Local aCols080		:= {}
Local aLoca080C		:= {}
Local aTipCpo		:= {}
Local lContinua 	:= .T.
Local lOk 			:= .F.
Local lLoca080A		:= ExistBlock("LOCA080A") // valida se pode realizar cópias
Local lLoca080B		:= ExistBlock("LOCA080B") // valida se pode realizar cópias após escolher a quantidade
Local lLoca080C		:= ExistBlock("LOCA080C") // informa campos customizados que não devem ser copiados
Local lLoca080D		:= ExistBlock("LOCA080D") // altera conteúdo nos campos copiados
LOCAL ODLGQ
Local nZ
Local cSeq
Local cSeqOld
Local cSeqCopy
Local cSeqNew
Local xValor
Local cCpoNao		:= ""
Local aLimpa     	:= {}
Local cTemp
Local cTipo

	// Se alterar os campos não, precisa alterar a rotina do loca001 - LOCA00141
	//cCpoNao := "FPA_GRUA;FPA_DESGRU;"
	cCpoNao := "FPA_VIAGEM;FPA_AS;"
	cCpoNao += "FPA_DTPREN;"
	cCpoNao += "FPA_FILREM;FPA_NFREM;FPA_DNFREM;FPA_SERREM;FPA_ITEREM;"
	cCpoNao += "FPA_NFRET;FPA_DNFRET;FPA_SERRET;FPA_ITERET;FPA_PARIDA;"
	cCpoNao += "FPA_PARVOL;FPA_ULTFAT;"
	cCpoNao += "FPA_SEQEST;"
	cCpoNao += "FPA_DTPRRT;"
	cCpoNao += "FPA_PEDIDO"

	IF EXISTBLOCK("LC080CPN") 					// --> PONTO DE ENTRADA PARA ALTERAÇÃO DE CAMPOS QUE SÃO OU NÃO COPIADOS PARA A PRÓXIMA LINHA DE LOCAÇÃO.
		cCpoNao := EXECBLOCK("LC080CPN",.T.,.T.,{cCpoNao})
	ENDIF

	cTemp := ""
	cCpoNao := alltrim(cCpoNao)
	For nX := 1 to len(cCpoNao)
		If substr(cCpoNao,nX,1) == ";"
			aadd(aLimpa,{alltrim(cTemp), "", Nil, 0 })
			cTemp := ""
		Else
			cTemp += Substr(cCpoNao,nX,1)
			If len(cCpoNao) == nX
				aadd(aLimpa,{alltrim(cTemp), "", Nil, 0 })
				cTemp := ""
			EndIf
		EndIF
	Next

	For nX := 1 to len(aLimpa)
		cTipo := TamSx3(aLimpa[nX,1])[3]
		aLimpa[nX,2] := cTipo
		If cTipo == "C"
			aLimpa[nX,3] := Space(TamSx3(aLimpa[nX,1])[1])
		ElseIf cTipo == "N"
			aLimpa[nX,3] := 0
		ElseIf cTipo == "M"
			aLimpa[nX,3] := ""
		ElseIf cTipo == "D"
			aLimpa[nX,3] := ctod("")
		EndIF
		aLimpa[nX,4] := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])==aLimpa[nX,1]})
	Next

	IF !OFOLDER:NOPTION == nFolderPla
		Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
						Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
						{STR0003}) //"Selecionar a aba Locação."
		lContinua := .F.
	ENDIF

	If lContinua
		nLinhaAtu		:= oDlgPla:nAt

		// Ponto de Entrada valida se pode realizar cópias
		If lLoca080A
			aHead080	:= oDlgPla:aHeader
			aCols080	:= AClone( oDlgPla:aCols[nLinhaAtu] )
			lContinua 	:= EXECBLOCK("LOCA080A" , .T. , .T. , {aHead080,aCols080})
		EndIf

		If lContinua

			//adequa para a resolução da tela
			//If GetScreenRes()[1] < 1500
				nFim01			:= aCoors[3] / 6
				nFim02			:= aCoors[4] / 5
			//Else
			//	nFim01			:= aCoors[3] / 8
			//	nFim02			:= aCoors[4] / 6
			//EndIf
			DEFINE MSDIALOG ODLGQ TITLE STR0009 + oDlgPla:aCols[nLinhaAtu][nPosSeqGru] FROM aCoors[1], aCoors[2] To nFim01, nFim02 Pixel Style DS_MODALFRAME //OF ODLG3 PIXEL //"Duplica o Item " ### [SEQGRU]
				@ 00,01 TO 03,05
				@ 012,022 SAY STR0004 //"Quantidade de linhas a duplicar:"
				@ 010,102 GET nQtdCopias PICTURE "999"
				@ 025,022 BUTTON "OK"   		SIZE 30,15 PIXEL OF ODLGQ ACTION ( lOk := .T., ODLGQ:End() ) // 240 //"OK"
				@ 025,055 BUTTON STR0010   	SIZE 30,15 PIXEL OF ODLGQ ACTION ODLGQ:End()             // 240 //"Cancelar"
			ACTIVATE MSDIALOG ODLGQ CENTERED
		EndIf
	EndIf

	If lOk .And. nQtdCopias > 0

		// Ponto de Entrada valida se pode realizar cópias após escolher a quantidade
		If lLoca080B
			aHead080	:= oDlgPla:aHeader
			aCols080	:= AClone( oDlgPla:aCols[nLinhaAtu] )
			lContinua 	:= EXECBLOCK("LOCA080B" , .T. , .T. , {aHead080,aCols080,nQtdCopias})
		EndIf

		If lContinua .And. MSGYESNO(STR0005 + oDlgPla:aCols[nLinhaAtu][nPosSeqGru] + STR0006 + cValtoChar(nQtdCopias) + STR0007, STR0008) //"Deseja copiar o Item " + #### + " por " + #### + " vezes ?" ### Rental
			For nX := 1 To nQtdCopias
				//pega SegGru da última linha
				nUltimaLn := oDlgPla:ACOLS[LEN(oDlgPla:ACOLS)][nPosSeqGru]
				//adiciona linha nova
				AADD(oDlgPla:ACOLS,ACLONE(oDlgPla:ACOLS[nLinhaAtu]))
				//pega nova ultima linha
				nLenPla := Len(ODLGPLA:aCols)
				//atualiza campos
				// se o bem estiver preenchido, preenche com próximo disponível

//-----------------------------------------
				If !Empty(oDlgPla:ACOLS[nLenPla][nPosEquip])
					If Len(aListNoBem) > 0
					Else
						aListNoBem := ListNoBem(AClone(oDlgPla:ACOLS),nPosAS,nPosEquip)
					EndIf
					aRetBem := RetBemDisp(oDlgPla:ACOLS[nLenPla][nPosProdut], @aListNoBem)
//-----------------------------------------
					oDlgPla:ACOLS[nLenPla][nPosEquip] 	:= aRetBem[1]
					oDlgPla:ACOLS[nLenPla][nPosDescEq] 	:= aRetBem[2]
				Else
					oDlgPla:ACOLS[nLenPla][nPosEquip] 	:= cBemDisp
					oDlgPla:ACOLS[nLenPla][nPosDescEq] 	:= cBemNome
				EndIf
				//campos que não são copiados
				oDlgPla:ACOLS[nLenPla][nPosSeqGru] 	:= Soma1(nUltimaLn)
				oDlgPla:ACOLS[nLenPla][nPosAS] 		:= cVazioAs
				oDlgPla:ACOLS[nLenPla][nPosViagem] 	:= cVazioViag
				oDlgPla:ACOLS[nLenPla][nPosUltFat] 	:= StoD("")
				oDlgPla:ACOLS[nLenPla][nPosNfRem] 	:= cVazioNFRe
				oDlgPla:ACOLS[nLenPla][nPosDNfRem] 	:= StoD("")
				oDlgPla:ACOLS[nLenPla][nPosSerRem] 	:= cVazioSeRe
				oDlgPla:ACOLS[nLenPla][nPosIteRem] 	:= cVazioItRe
				oDlgPla:ACOLS[nLenPla][nPosNfRet] 	:= cVazioNfRt
				oDlgPla:ACOLS[nLenPla][nPosDNfRet] 	:= StoD("")
				oDlgPla:ACOLS[nLenPla][nPosNfEnt] 	:= StoD("")
				oDlgPla:ACOLS[nLenPla][nPosDtScr] 	:= StoD("")
				oDlgPla:ACOLS[nLenPla][nPosReboq] 	:= cVazioRebo
				oDlgPla:ACOLS[nLenPla][nPosMotRe] 	:= cVazioMotr
				oDlgPla:ACOLS[nLenPla][nPosNMotR] 	:= cVazioNMot
				//SIGALOC94-822 - 21/06/2023 - Jose Eulalio - Solicitado manter esses campos na cópia
				//oDlgPla:ACOLS[nLenPla][nPosAjust] 	:= cVazioAjus
				//oDlgPla:ACOLS[nLenPla][nPosDAjus] 	:= cVazioDAju
				//oDlgPla:ACOLS[nLenPla][nPosNiver] 	:= StoD("")
				// Frank em 24/05/23.
				// Se for estrutura e item filho não preencher na cópia.
				If substr(oDlgPla:ACOLS[nLenPla][nPosSeqEst],5,1) <> " "
					oDlgPla:ACOLS[nLenPla][nPosSeqEst] := cVazioEstr
				EndIF

				For nZ := 1 to len(aLimpa)
					If aLimpa[nZ,4] > 0 .and. aLimpa[nZ,2] <> "L"
						oDlgPla:ACOLS[nLenPla][aLimpa[nZ,4]] := aLimpa[nZ,3]
					EndIf
				Next

				// Ponto de Entrada informa campos customizados que não devem ser copiados
				If lLoca080C
					aLoca080C := EXECBLOCK("LOCA080C" , .T. , .T. , NIL)
					//percorre os campos enviados
					For nZ := 1 to Len(aLoca080C)
						//localiza campo no aCols
						nPosAux	:= ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])== AllTrim(aLoca080C[Nz])})
						//se existir limpa o valor
						If nPosAux > 0
							//verifica tamanho e tipo do campo
							aTipCpo := TamSx3(aLoca080C[Nz])
							If aTipCpo[3] == "N"
								xValor	:= 0
							ElseIf aTipCpo[3] == "D"
								xValor	:= StoD("")
							Else
								xValor	:= Space(aTipCpo[1])
							EndIf

							oDlgPla:ACOLS[nLenPla][nPosAux] := xValor
						EndIf
					Next nZ
				EndIf

		// PE para alterar conteúdo dos campos na linha duplicada
		// Rossana - DSERLOCA 2435 - 12/03/2024

				If lLoca080D
					ODLGPLA:ACOLS[nLenPla] := EXECBLOCK("LOCA080D" , .T. , .T. , {ODlgPla:ACOLS[nLenPla],ODLGPLA:AHEADER})
				EndIf

				//adiciona no array oPla_cols
				AADD(OPLA_COLS, Aclone(ODLGPLA:ACOLS[nLenPla]))
				// Frank em 24/05/23.
				// Se for estrutura e item pai refazer todos os itens filhos com nova estrutura
/*
//	não duplicar itens da estrutura
//

				If substr(oDlgPla:ACOLS[nLenPla][nPosSeqEst],5,1) == " " .and. substr(oDlgPla:ACOLS[nLenPla][nPosSeqEst],1,1) <> " "
					// Passo 1 - identificar qual a numeracao maior para criar um item pai novo
					// Passo 2 - trocar na linha copiada pai a nova numeracao
					// Passo 3 - identificar todos os itens filhos e
					// gerar os novos itens filhos, limpar os campos que não devem ser copiados, já com a nova estrutura pai x filho

					// Passo 1
					cSeq := "000"
					For nZ := 1 to len(oDlgPla:ACOLS)
						If substr(oDlgPla:ACOLS[nZ][nPosSeqEst],1,3) > cSeq
							cSeq := substr(oDlgPla:ACOLS[nZ][nPosSeqEst],1,3)
						EndIF
					Next
					cSeq := Soma1(cSeq)

					// Passo 2
					cSeqOld := substr(oDlgPla:ACOLS[nLenPla][nPosSeqEst],1,3)
					oDlgPla:ACOLS[nLenPla][nPosSeqEst] := cSeq

  					// Passo 3
					For nZ := 1 to len(oDlgPla:ACOLS)
						If substr(oDlgPla:ACOLS[nZ][nPosSeqEst],1,3) == cSeqOld
							If substr(oDlgPla:ACOLS[nZ][nPosSeqEst],5,1) <> " "
								cSeqCopy := substr(oDlgPla:ACOLS[nZ][nPosSeqEst],5,len(oDlgPla:ACOLS[nZ][nPosSeqEst]))
								// Trata-se de um item filho e que deve ser replicado
								//pega SegGru da última linha
								nUltimaLn := oDlgPla:ACOLS[LEN(oDlgPla:ACOLS)][nPosSeqGru]
								//adiciona linha nova
								AADD(oDlgPla:ACOLS,ACLONE(oDlgPla:ACOLS[nZ]))
								//pega nova ultima linha
								nLenPla := Len(ODLGPLA:aCols)
								//atualiza campos
								// se o bem estiver preenchido, preenche com próximo disponível
								If !Empty(oDlgPla:ACOLS[nLenPla][nPosEquip])
//-----------------------------------------
									If Len(aListNoBem) > 0
									Else
										aListNoBem := ListNoBem(AClone(oDlgPla:ACOLS),nPosAS,nPosEquip)
									EndIf
									aRetBem := RetBemDisp(oDlgPla:ACOLS[nLenPla][nPosProdut], @aListNoBem)
//-----------------------------------------
									oDlgPla:ACOLS[nLenPla][nPosEquip] 	:= aRetBem[1]
									oDlgPla:ACOLS[nLenPla][nPosDescEq] 	:= aRetBem[2]
								Else
									oDlgPla:ACOLS[nLenPla][nPosEquip] 	:= cBemDisp
									oDlgPla:ACOLS[nLenPla][nPosDescEq] 	:= cBemNome
								EndIf
								//campos que não são copiados
								oDlgPla:ACOLS[nLenPla][nPosSeqGru] 	:= Soma1(nUltimaLn)
								oDlgPla:ACOLS[nLenPla][nPosAS] 		:= cVazioAs
								oDlgPla:ACOLS[nLenPla][nPosViagem] 	:= cVazioViag
								oDlgPla:ACOLS[nLenPla][nPosUltFat] 	:= StoD("")
								oDlgPla:ACOLS[nLenPla][nPosNfRem] 	:= cVazioNFRe
								oDlgPla:ACOLS[nLenPla][nPosDNfRem] 	:= StoD("")
								oDlgPla:ACOLS[nLenPla][nPosSerRem] 	:= cVazioSeRe
								oDlgPla:ACOLS[nLenPla][nPosIteRem] 	:= cVazioItRe
								oDlgPla:ACOLS[nLenPla][nPosNfRet] 	:= cVazioNfRt
								oDlgPla:ACOLS[nLenPla][nPosDNfRet] 	:= StoD("")
								oDlgPla:ACOLS[nLenPla][nPosNfEnt] 	:= StoD("")
								oDlgPla:ACOLS[nLenPla][nPosDtScr] 	:= StoD("")
								oDlgPla:ACOLS[nLenPla][nPosReboq] 	:= cVazioRebo
								oDlgPla:ACOLS[nLenPla][nPosMotRe] 	:= cVazioMotr
								oDlgPla:ACOLS[nLenPla][nPosNMotR] 	:= cVazioNMot
								oDlgPla:ACOLS[nLenPla][nPosAjust] 	:= cVazioAjus
								oDlgPla:ACOLS[nLenPla][nPosDAjus] 	:= cVazioDAju
								oDlgPla:ACOLS[nLenPla][nPosNiver] 	:= StoD("")
								cSeqNew := cSeq + "." + cSeqCopy
								oDlgPla:ACOLS[nLenPla][nPosSeqEst]  := cSeqNew
							EndIF
						EndIf
					Next


				EndIF
*/			Next nX
			oDlgPla:oBrowse:Refresh()
		EndIf
	EndIf

Return



/*/{PROTHEUS.DOC} RetBemDisp.PRW
Função que retorna o Bem Disponível, baseada na consulta FPAST9
@TYPE Static Function
@AUTHOR Jose Eulalio
@SINCE 08/06/2022
@VERSION P12
@HISTORY 08/06/2022, Jose Eulalio, Criação da Função
/*/
Static Function RetBemDisp(cProdut, aListNoBem)
Local cBemDisp	:= Space(TamSx3("T9_CODBEM")[1])
Local cBemNome	:= Space(TamSx3("T9_NOME")[1])

Local cAlias 	:= GetNextAlias()
Local aBemDisp	:= {cBemDisp,cBemNome}
Local cQuery := ""
Local cFinalQuery
local oExec as object

// DSERLOCA-2435 - Rossana em 01/03/2024
// Bens já utilizados no acols controlados em array - alteração na montagem e execução das queries

	//Verifica a disponibilidade por data FIFO na FQ4

	oExec := FwExecStatement():New()

	cQuery	:= " SELECT DISTINCT FQ4_STATUS, FQ4_DESTAT, FQ4_DTFIM, T9_CODBEM, T9_NOME,T9_CODESTO FROM " + RetSqlName("ST9") + " ST9 "
	cQuery	+= " INNER JOIN  " + RetSqlName("FQ4") + " FQ4 "
	cQuery	+= " ON T9_CODBEM = FQ4_CODBEM "
	cQuery	+= " AND FQ4_STATUS = '00' "
	cQuery	+= " AND FQ4.D_E_L_E_T_ = ' '   "
	cQuery	+= " WHERE T9_FILIAL = '?' "
	cQuery	+= " AND ST9.D_E_L_E_T_ = ' '   "
	cQuery	+= " AND T9_SITMAN = 'A'  "
	cQuery	+= " AND T9_SITBEM = 'A'  "
//  cQuery	+= " AND T9_STATUS = '00'  "
	cQuery	+= " AND ( T9_STATUS = '00' OR T9_STATUS = '  ' )"
	cQuery	+= " AND T9_CODESTO = ? "
	cQuery	+= " AND T9_CODBEM NOT IN (?) "
	cQuery	+= " ORDER BY FQ4_DTFIM "

	cQuery := ChangeQuery(cQuery)

		oExec  :SetQuery(cQuery)
		oExec  :SetUnsafe(1, xFilial("ST9"))
		oExec  :SetString(2,cProdut)
		oExec  :SetIn(3, aListNoBem)
		cFinalQuery := oExec:GetFixQuery()
 		MPSysOpenQuery(cFinalQuery,cAlias)

		If (cAlias)->(!EOF())
			cBemDisp 	:= (cAlias)->T9_CODBEM
			cBemNome	:= (cAlias)->T9_NOME
			AADD( aListNoBem, cBemDisp)
			aBemDisp[1] := cBemDisp
			aBemDisp[2] := cBemNome
		EndIf

		(cAlias)->(DbCloseArea())
		oExec:Destroy()
		oExec := nil

	//Caso não ache, procura pela ST9
*/
	cAlias 	:= GetNextAlias()

	If Empty(cBemDisp)

		oExec := FwExecStatement():New()

		cQuery	:= " SELECT DISTINCT T9_CODBEM, T9_NOME,T9_CODESTO FROM " + RetSqlName("ST9") + " ST9 "
		cQuery	+= " WHERE T9_FILIAL = '" + xFilial("ST9") + "' "
		cQuery	+= " AND ST9.D_E_L_E_T_ = ' '   "
		cQuery	+= " AND T9_SITMAN = 'A'  "
		cQuery	+= " AND T9_SITBEM = 'A'  "
		cQuery	+= " AND T9_STATUS = '00'  "
		cQuery	+= " AND T9_CODESTO = ? "
		cQuery	+= " AND T9_CODBEM NOT IN (?) "

		cQuery := ChangeQuery(cQuery)
		oExec  :SetQuery(cQuery)
		oExec  :SetString(1,cProdut)
		oExec  :SetIn(2, aListNoBem)
		cFinalQuery := oExec:GetFixQuery()
		MPSysOpenQuery(cFinalQuery,cAlias)

		If (cAlias)->(!EOF())
			cBemDisp 	:= (cAlias)->T9_CODBEM
			cBemNome	:= (cAlias)->T9_NOME
			AADD( aListNoBem, cBemDisp)
			aBemDisp[1] := cBemDisp
			aBemDisp[2] := cBemNome
		EndIf

		(cAlias)->(DbCloseArea())
		oExec:Destroy()
		oExec := nil

	EndIf

Return aBemDisp

/*/{PROTHEUS.DOC} RetBemDisp.PRW
Retorna lista de bens que não deverão ser copiados
@TYPE Static Function
@AUTHOR Jose Eulalio
@SINCE 09/06/2022
@VERSION P12
@HISTORY 09/06/2022, Jose Eulalio, Criação da Função
/*/
Static Function ListNoBem(aColsFpa,nPosAS,nPosEquip)
Local aListNoBem 	:= {}
//Local cListNoBem	:= ""
Local nX			:= 0

	For nX := 1 To Len(aColsFpa)
		If !Empty(aColsFpa[nX][nPosEquip]) .And. Empty(aColsFpa[nX][nPosAS])
			AADD( aListNoBem, aColsFpa[nX][nPosEquip])
		EndIf
	Next nX

Return aListNoBem
