#INCLUDE 'protheus.ch'
#INCLUDE "JURXCOM.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JurEnvAprv
Envia a nota fiscal para aprovação no LD no fluxo do controle orcamentario.

@author Victor Hayashi
@since 08/01/2025
/*/
//-------------------------------------------------------------------
Function JurEnvAprv(ChaveSF1)
Local lRet := .T.

Default ChaveSF1 := SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)

	If SF1->(ColumnPos("F1_JSITLD")) > 0 .And. SF1->(ColumnPos("F1_JHSTLD")) > 0
		If SF1->F1_JSITLD $ "2|5|6" // Pendente de Envio ou Reprovada

			OHV->(DBSetOrder(1)) // OHV_FILIAL + OHV_DOC + OHV_SERIE + OHV_FORNEC + OHV_LOJA + OHV_COD + OHV_ITEM
			If !(OHV->(DBSeek(xFilial("OHV") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA)))
				lRet := JurMsgErro(STR0001, "JurEnvAprv", STR0002) // "Não existem desdobramentos cadastrados para o documento." # "Os desdobramentos devem ser cadastrados para seguir para a aprovação no LegalDesk."
			EndIf

			If lRet
				lRet := MsgYesNo(STR0003, STR0004) // "Deseja enviar a nota fiscal para aprovação?" # "Aviso"
			EndIf

			If lRet
				J170GRAVA("MATA103", SF1->(F1_FILIAL + "|" + F1_DOC + "|" + F1_SERIE + "|" + F1_FORNECE + "|" + F1_LOJA), "3") // Grava na fila de sincronização

				// Atualiza a situação da NF para Pendente de aprovação
				lRet := JurUpdSitNF(ChaveSF1, "3")
				ApMsgInfo(STR0005) // "Nota fiscal enviada para aprovação com sucesso."
			EndIf
		Else
			If SF1->F1_JSITLD == "1"
				JurMsgErro(STR0006) // "Pré notas não passam pelo processo de aprovação. Por favor, realize a pré - classificação da nota fiscal."
			ElseIf SF1->F1_JSITLD == "3"
				JurMsgErro(STR0007) // "A nota fiscal já se encontra em processo de aprovação."
			ElseIf SF1->F1_JSITLD == "4"
				JurMsgErro(STR0008) // "A nota fiscal já foi aprovada."
			EndIf
			lRet := .F.
		EndIf
	Else
		JurMsgErro(STR0009, "MATA103", STR0010) // "Não foi possível enviar para aprovação." # "Verifique se os campos de situação (F1_JSITLD) e histórico (F1_JHSTLD) existem no sistema."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurConsAprv
Janela com o Historico de aprovações da nota fiscal no fluxo do 
controle orcamentario.

@author Victor Hayashi
@since 08/01/2025
/*/
//-------------------------------------------------------------------
Function JurConsAprv()
Local oDlg     := Nil
Local oLayer   := Nil
Local oSitacao := Nil
Local oHist    := Nil
Local nPos     := 0
Local cSituac  := ""
Local cMemo    := ""
Local lConOrc  := SuperGetMV("MV_JCONORC", .F., .F., )

	If lConOrc
		If SF1->(ColumnPos("F1_JHSTLD")) > 0 .And. SF1->(ColumnPos("F1_JSITLD")) > 0
			cMemo   := SF1->F1_JHSTLD
			nPos    := Iif(Empty(SF1->F1_JSITLD), 0, Val(SF1->F1_JSITLD))
			cSituac := Iif(nPos > 0, Substr(RetSX3Box(GetSX3Cache("F1_JSITLD", "X3_CBOX"),,,1)[nPos][1],3), "")

			If nPos == 0
				JurMsgErro(STR0011, "MATA103") // "Não existe histórico do fluxo do Controle Orçamentario para esse documento."
			Else
				DEFINE MSDIALOG oDlg TITLE STR0012 FROM 010,0 TO 250,500 PIXEL // "Histórico de aprovação"

					oLayer := FWLayer():New()
					oLayer:init(oDlg, .F.)
					oLayer:addCollumn("MainColl", 100, .F.)

					oSitacao := TGet():New( 05,20,{||cSituac}, oLayer:GetColPanel("MainColl"), 60, 10,,,0,,,,,.T.,,,,,,,.T.,,, cSituac,,,,,,, STR0013, 1,,,,) // "Situação:"
					oHist    := TMultiGet():New(30,20,{|u| If(pCount()>0, cMemo := u, cMemo)}, oLayer:GetColPanel("MainColl"), 200, 50, /*oFont*/,,,,,.T.,,,,,,.T.,,,,.F.,.T.,RetTitle('F1_JHSTLD'), 1,,)

				ACTIVATE MSDIALOG oDlg CENTER
			EndIf
		Else
			JurMsgErro(STR0014, "MATA103", STR0010) // "Não foi possível exibir o histórico de aprovação."
		EndIf
	Else
		JurMsgErro(STR0015, "MATA103", STR0016) // "Essa opção está disponivel somente com Controle Orçamentário" # "Esta funcionalidade está desabilitada pelo parâmetro MV_JCONORC."
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurUpdSitNF
Realiza a gravação do log de histórico de aprovações da nota fiscal no
fluxo do controle orcamentario.

@param cChaveSF1, Chave do documento de entrada
@param cSituac  , Situação para gravação do historico.

@author Victor Hayashi
@since 08/01/2025
/*/
//-------------------------------------------------------------------
Function JurUpdSitNF(cChaveSF1,cSituac, cJustif)
Local cData    := Transform(Date(),"DD/MM/YYYY")
Local cHora    := Time()
Local cSigla   := JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__cUserId), "RD0_SIGLA", .F.)
Local cMemoNew := "- "
Local cMemoOld := ""

Default cJustif := ""

	SF1->(DbSetOrder(1)) //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
	If SF1->(dbSeek(cChaveSF1)) .And. SF1->F1_JSITLD != cSituac
		 cMemoOld := SF1->F1_JHSTLD
		 
		If cSituac == "1"
			cMemoNew += cData + " " + cHora + STR0017 + cSigla // " - Entrada da pré-nota pelo usuário "
		ElseIf cSituac == "2"
			If SF1->F1_JSITLD == "1"
				cMemoNew += cData + " " + cHora + STR0018 + cSigla // " - Pré Classificação realizada pelo usuário "
			ElseIf SF1->F1_JSITLD == "5"
				cMemoNew += cData + " " + cHora + STR0019 + cSigla // " - Ajustes no documento pelo usuário "
			Else
				cMemoNew += cData + " " + cHora + STR0020 + cSigla // " - Entrada do documento pelo usuário "
			EndIf
		ElseIf cSituac == "3"
			cMemoNew += cData + " " + cHora + STR0021 + cSigla // " - Enviado para aprovação pelo usuário "
		ElseIf cSituac == "4"
			cMemoNew += cData + " " + cHora + STR0022 // " - Aprovada."
		ElseIf cSituac == "5"
			cMemoNew += cData + " " + cHora + STR0023 + "'" + cJustif + "'" // " - Reprovada, com a seguinte justificativa: "

			// Limpa TES dos itens da nota fiscal, para que o usuário possa realizar as correções necessárias e enviar novamente para aprovação
			JLimpaTES()

		ElseIf cSituac == "6"
			If IsInCallStack("PUT_AprvDoc")
				cMemoNew += cData + " " + cHora + STR0026 + "'" + cJustif + "'" // " - Estornado no LegalDesk, com a seguinte justificativa: "
			Else
				cMemoNew += cData + " " + cHora + STR0024 + cSigla // " - Alterado para Pendente de envio devido estorno da classificação pelo usuário "
			EndIf
			J170GRAVA("MATA103", SF1->(F1_FILIAL + "|" + F1_DOC + "|" + F1_SERIE + "|" + F1_FORNECE + "|" + F1_LOJA), "5") // Grava na fila de sincronização
		EndIf

		Reclock("SF1",.F.)
		SF1->F1_JSITLD := cSituac
		SF1->F1_JHSTLD := cMemoNew + CRLF + cMemoOld
		SF1->(MsUnlock())
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JurNatTit()
Busca a natureza principal do documento fiscal quando há integração
com o Controle Orçamentário no Legal Desk.

@obs chamada na função A103NFiscal

@author Abner Fogaça de Oliveira
@since 21/03/2026
/*/
//-------------------------------------------------------------------
Function JurNatTit()
Local cNatTitulo := ""

	If FWAliasInDic("OID")
		OID->(DBSetOrder(1)) // OID_FILIAL + OID_DOC + OID_SERIE + OID_FORNEC + OID_LOJA
		If OID->(DBSeek(xFilial("OID") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
			cNatTitulo := OID->OID_CNATUR
		EndIf 
	EndIf

Return cNatTitulo

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldTes()
Valida que a TES nos itens do documento são iguais.

@param aCols    Array com os itens da Nota.
@param cFilSF4  Filial da TES (Tipo de Entrada e Saida)

@obs chamada na função A103Tudok
@obs A nota só poderá ter itens que geram duplicata ou que não geram.

@author Victor Hayashi
@since 24/03/2026
/*/
//-------------------------------------------------------------------
Function JurVldTes(aCols, cFilSF4)
Local aArea    := GetArea()
Local aAreaSF4 := SF4->(GetArea())
Local lRet     := .T.
Local nX       := 0
Local cDupl1   := ""
Local cDupl2   := ""

	For nX := 1 To Len(aCols)
		If lRet
			If nX == 1
				cDupl1 := Posicione("SF4", 1, cFilSF4 + Padr(aCols[nX, GetPosSD1("D1_TES")], TamSx3("F4_CODIGO")[1]), "F4_DUPLIC")
				lRet   := .T.
			Else
				cDupl2 := Posicione("SF4", 1, cFilSF4 + Padr(aCols[nX, GetPosSD1("D1_TES")], TamSx3("F4_CODIGO")[1]), "F4_DUPLIC")
				lRet   := cDupl1 == cDupl2
			EndIf
		Else
			Exit
		EndIf
	Next nX

	If !lRet
		JurMsgErro(STR0025) // "A integração com o Controle Orçamentário não permite documentos fiscais quando os valores do campo Gera Duplicata são divergentes entre si."
	EndIf
	
	RestArea(aAreaSF4)
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JLimpaTES()
Limpa a TES dos itens do documento quando o mesmo for reprovado 
no fluxo do controle orçamentario.

@author Victor Hayashi
@since 24/03/2026
/*/
//-------------------------------------------------------------------
Static Function JLimpaTES()
Local aArea    := GetArea()
Local aAreaSD1 := SD1->(GetArea())

	SD1->(DBSetOrder(1)) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
	If SD1->(DBSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
		While SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
			RecLock("SD1",.F.)
			SD1->D1_TES     := CriaVar('D1_TES',.F.)
			SD1->D1_CODCIAP := CriaVar('D1_CODCIAP',.F.)
			SD1->D1_RATEIO  := "2"
			SD1->(MsUnlock())

			SD1->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JConOrcTit
Ajusta o array de titulos para integração com o Controle Orçamentário 
no Legal Desk, buscando as informações salvas na tabela OID.

@param aHeadSE2, Array com os cabeçalhos da SE2
@param aColsSE2, Array com os itens da SE2

@obs chamada na função A103NFiscal

@author Victor Hayashi
@since 22/04/2026
/*/
//-------------------------------------------------------------------
Function JConOrcTit(aHeadSE2, aColsSE2, nTaxa, nMoedaCor)
Local aArea    := GetArea()
Local nX       := 0
Local nPVencto := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VENCTO"})
Local nPValor  := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VALOR" })

	OID->(DbSetOrder(1)) // OID_FILIAL, OID_DOC, OID_SERIE, OID_FORNEC, OID_LOJA, OID_PARCEL
	For nX := 1 To Len(aColsSE2)
		If OID->(DbSeek(SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + cValToChar(nX)))
			aColsSE2[nX][nPVencto] := OID->OID_VENCTO
			aColsSE2[nX][nPValor]  := OID->OID_VALOR

			If nX == 1
				nMoedaCor := OID->OID_MOEDA
				nTaxa     := OID->OID_COTAC
			EndIf
		EndIf
	Next nX

	RestArea(aArea)

Return .T.
