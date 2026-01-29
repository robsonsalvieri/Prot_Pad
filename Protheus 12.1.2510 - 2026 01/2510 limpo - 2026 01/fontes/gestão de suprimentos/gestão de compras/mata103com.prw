#INCLUDE "MATA103COM.CH"
#include "protheus.ch"

Static lDHQInDic  := (FwAliasInDic("DHQ") .and. SF4->(FieldPos("F4_EFUTUR") > 0))
Static nPrecisao  := TamSX3("D1_VUNIT")[2]
Static lLGPD  	  := FindFunction("SuprLGPD") .And. SuprLGPD()

/*/{Protheus.doc} A103FutSel
Seleciona a nota fiscal de compra com entrega futura para relacionar à nota de remessa.

@author  Felipe Raposo
@version P12
@since   11/06/2018
@return  Nenhum.
/*/
Function A103FutSel(aCompFutur, cFornec, cLoja, cProduto, oGetDb, aComFut)

Local aArea      := {}
Local aDocumento := {}
Local nX, nY
Local nPItemNF   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"} )

Local cQuery     := ""
Local cTopAlias  := GetNextAlias()

Local cTMPAlias  := "COMFUT"
Local cTMPTabela := ""
Local cTMPIndice := ""
Local cTMPCampo  := ""
Local aTMPCampos := {}
Local aTMPHeader := {}
Local aTMPStruct := {}

Local aSize      := {}
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}

Local oDlg, oPanel, oCombo
Local nOpcA      := 0
Local aTexto     := {"", ""}
Local cCombo     := ""
Local cComboFor  := ""
Local cForTer    := cFornec
Local cLojaTer   := cLoja
Local aOrdem     := {}
Local xPesq
Local lEntTerc   := SuperGetMV("MV_FORPCNF",.F.,.F.)
Local lFutTer    := (aComFut != Nil)
Local lRet 		 := .F.

Local cCampo  As Character    
Local nTamIt  As Numeric
Local nOrder  As Numeric
Local oQry    As Object
Local aCmpX3  As Array

cCampo 	:= ""
nTamIt  := Len( Alltrim( Str(nPItemNF) ) )
nOrdem 	:= 1  
oQry 	:= Nil
aCmpX3  := {"X3_TITULO","X3_CAMPO","X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_PICTURE","X3_VALID","X3_USADO","X3_ARQUIVO","X3_CONTEXT"}



Default oGetDb  := Nil
Default aComFut := {}

If lDHQInDic
	aArea := GetArea()

	// Ajusta o tamanho da variavel de acordo com os itens da nota
	aSize(aCompFutur, Len(aCols))
	For nX := 1 To Len(aCompFutur)
		If aCompFutur[nX] == Nil
			aCompFutur[nX] := {" "," "," ",0," "," "," "}
		EndIf
	Next nX
	
	cQuery := "SELECT DHQ.R_E_C_N_O_ DHQRecNo, SD1.R_E_C_N_O_ SD1RecNo " 
	cQuery += "FROM ? DHQ "
	cQuery += "INNER JOIN ? SD1 on SD1.D1_FILIAL  = ? "
	cQuery += "AND SD1.D1_DOC     = DHQ.DHQ_DOC "
	cQuery += "AND SD1.D1_SERIE   = DHQ.DHQ_SERIE "
	cQuery += "AND SD1.D1_FORNECE = DHQ.DHQ_FORNEC "
	cQuery += "AND SD1.D1_LOJA    = DHQ.DHQ_LOJA "
	cQuery += "AND SD1.D1_ITEM    = DHQ.DHQ_ITEM "
	cQuery += "AND SD1.D1_COD     = DHQ.DHQ_COD "
	cQuery += "AND SD1.D_E_L_E_T_ = ? "
	cQuery += "WHERE DHQ.DHQ_FILIAL = ? " 
	cQuery += "AND DHQ.DHQ_FORNEC = ?  "
	cQuery += "AND DHQ.DHQ_LOJA   = ?  "
	cQuery += "AND DHQ.DHQ_COD    = ?  "
	cQuery += "AND DHQ.D_E_L_E_T_ = ?  "
	
	If cTipo == "C"
		cQuery += "AND DHQ.DHQ_TIPO   IN ( ? ) "
		cQuery += "AND DHQ.DHQ_STATUS IN ( ? ) " 
	Else
		cQuery += "AND DHQ.DHQ_TIPO   = ?  "
		cQuery += "AND DHQ.DHQ_STATUS = ?  "
		cQuery += "AND DHQ.DHQ_QTORI  > DHQ.DHQ_QTREC "  // 1-Aberto. 
	EndIf

	cQuery += "AND DHQ.DHQ_DESFAZ  = ? "
	cQuery += "ORDER BY DHQ.DHQ_DTREC, DHQ.DHQ_DOC, DHQ.DHQ_SERIE, DHQ.DHQ_ITEM "
	
	oQry := FWPreparedStatement():New()
	nOrder := 1
	
	oQry:SetQuery(cQuery)
	
	oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
	oQry:SetNumeric(nOrder++,RetSqlName("SD1"))
	oQry:SetString(nOrder++,xFilial("SD1"))
	oQry:SetString(nOrder++,' ' )
	oQry:SetString(nOrder++,xFilial("DHQ"))
	oQry:SetString(nOrder++,cFornec)
	oQry:SetString(nOrder++,cLoja)
	oQry:SetString(nOrder++,cProduto)
	oQry:SetString(nOrder++,' ' )
	
	If cTipo == "C"
		oQry:SetIn(nOrder++, {"1","2"} )
		oQry:SetIn(nOrder++, {"1","9"} )
	Else
		oQry:SetString(nOrder++,'1')
		oQry:SetString(nOrder++,'1')
	EndIf	
	
	oQry:SetString(nOrder++,' ' )

	cQuery    := oQry:GetFixQuery()
	cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)
	
	Do While (cTopAlias)->(!eof())
		(cTopAlias)->(aAdd(aDocumento, {DHQRecNo, SD1RecNo}))
		(cTopAlias)->(dbSkip())
	EndDo
	(cTopAlias)->(dbCloseArea())
	
	//Se for nota de complemento verifica se o tipo eh diferente de complemento de preço
	If cTipo == "C"
		lRet := cTpCompl != "1"
	EndIf 

	// Exibe a tela para o usuário selecionar a nota de origem.
	If !lRet .And. !Empty(aDocumento) .Or. lEntTerc

		If lFutTer .And. Select(cTMPAlias) > 0
			FWCloseTemp(cTMPAlias, cTMPTabela)
		EndIf

		// Cria tabela de trabalho.
		aTMPCampos := {"DHQ->DHQ_DOC", "DHQ->DHQ_SERIE", "DHQ->DHQ_ITEM", "DHQ->DHQ_DTREC", "DHQ->DHQ_QTORI",;
		"DHQ->DHQ_QTREC", "SD1->D1_VUNIT", "SD1->D1_CF", "SD1->D1_ORIGEM", "SD1->D1_FCICOD"}

		For nX := 1 to Len(aTMPCampos)
		
			cCampo := SubStr(aTMPCampos[nX], 6)
			//Campo | Tipo | Tamanho | Decimal | Contagem do Item 
			aAdd(aTMPStruct, {Alltrim(GetSx3Cache(cCampo,aCmpX3[2])),GetSx3Cache(cCampo,aCmpX3[3]),;
				GetSx3Cache(cCampo,aCmpX3[4]),GetSx3Cache(cCampo,aCmpX3[5]),StrZero(nX, 2) })
			
			//Titulo | Campo | Picture | Tamanho | Decimal | Valid | Usado | Tipo | Arquivo | Context | Contagem do Item   
			aAdd(aTMPHeader,{GetSx3Cache(cCampo,aCmpX3[1]),Alltrim(GetSx3Cache(cCampo,aCmpX3[2])),GetSx3Cache(cCampo,aCmpX3[6]),;
				GetSx3Cache(cCampo,aCmpX3[4]),GetSx3Cache(cCampo,aCmpX3[5]),GetSx3Cache(cCampo,aCmpX3[7]),GetSx3Cache(cCampo,aCmpX3[8]),;
				GetSx3Cache(cCampo,aCmpX3[3],cCampo),GetSx3Cache(cCampo,aCmpX3[9]),GetSx3Cache(cCampo,aCmpX3[10]),StrZero(nX, 2)})

		Next nX

		cTMPTabela := FWOpenTemp(cTMPAlias, aTMPStruct,, .T.)

		// Cria índice e configuração de pesquisa.
		aChave := {"DHQ_DOC+DHQ_SERIE+DHQ_ITEM", "DHQ_DTREC"}
		aPesq  := {{Space(Len(DHQ->DHQ_DOC + DHQ->DHQ_SERIE)), "@!"}, {ctod(""), ""}}
		
		For nX := 1 To Len(aChave)
			cTMPIndice := cTMPAlias + "_" + Str(nPItemNF,nTamIt) + "_" + Str(nX, 1)
			(cTMPAlias)->(IndRegua(cTMPAlias, cTMPIndice, aChave[nX]))
			aChave[nX] := cTMPIndice
		Next nX
		(cTMPAlias)->(dbClearIndex())
		For nX := 1 To Len(aChave)
			(cTMPAlias)->(dbSetIndex(aChave[nX]))
		Next nX

		// Popula a tabela de trabalho.
		For nX := 1 to Len(aDocumento)
			DHQ->(dbGoTo(aDocumento[nX, 1]))
			SD1->(dbGoTo(aDocumento[nX, 2]))
			RecLock(cTMPAlias, .T.)
			For nY := 1 to len(aTMPCampos)
				cTMPCampo := SubStr(aTMPCampos[nY], 6)
				(cTMPAlias)->(&cTMPCampo) := &(aTMPCampos[nY])
			Next nY
			(cTMPAlias)->(msUnLock())
		Next nX

		If !lFutTer	// Chamada via funcao A103FutTer nao deve montar a Dialog novamente, somente atualizar o objeto oGetDb
			// Posiciona tabelas.
			(cTMPAlias)->(dbSetOrder(1))
			(cTMPAlias)->(dbGoTop())
			SA2->(dbSetOrder(1))  // A2_FILIAL, A2_COD, A2_LOJA.
			SA2->(dbSeek(xFilial() + cFornec + cLoja, .F.))
			SB1->(dbSetOrder(1))  // B1_FILIAL, B1_COD.
			SB1->(dbSeek(xFilial() + cProduto, .F.))
	
			// Calcula as coordenadas da tela.
			aSize := MsAdvSize(.F.)
			aSize[1] /= 1.5; aSize[2] /= 1.5; aSize[3] /= 1.5; aSize[4] /= 1.3
			aSize[5] /= 1.5; aSize[6] /= 1.3; aSize[7] /= 1.5
			aAdd(aObjects, {100, 020, .T., .F., .T.})
			aAdd(aObjects, {100, 060, .T., .T.})
			aAdd(aObjects, {100, 022, .T., .F.})
			aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
			aPosObj := MsObjSize(aInfo, aObjects, .T.)
	
			// Monta a tela.
			DEFINE MSDIALOG oDlg TITLE STR0001 FROM aSize[7], 000 TO aSize[6], aSize[5] OF oMainWnd PIXEL  // "Notas fiscais de origem (compra com entrega futura)"
	
			@ aPosObj[1, 1], aPosObj[1, 2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1, 3], aPosObj[1, 4]+IIf(lEntTerc,7,0) OF oDlg CENTERED LOWERED
	
			If !lEntTerc
				aTexto[1] := AllTrim(RetTitle("DHQ_FORNEC")) + "/" + AllTrim(RetTitle("DHQ_LOJA")) + ": " + SA2->A2_COD + "/" + SA2->A2_LOJA + " - " + RetTitle("A2_NOME") + ": " + ;
				If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME)
				@ 002, 005 SAY aTexto[1] SIZE aPosObj[1, 3], 008 OF oPanel PIXEL
	
				aTexto[2] := AllTrim(RetTitle("DHQ_COD")) + ": " + SB1->B1_COD + " - " + rtrim(SB1->B1_DESC)
				@ 012, 005 SAY aTexto[2] SIZE aPosObj[1, 3], 008 OF oPanel PIXEL
			Else
				aTexto[1] := AllTrim(RetTitle("DHQ_FORNEC")) + "/" + AllTrim(RetTitle("DHQ_LOJA")) + ": "
				@ 005, 005 SAY aTexto[1] SIZE aPosObj[1, 3], 008 OF oPanel PIXEL
				@ 007, 055 MSCOMBOBOX oComboBox VAR cComboFor ITEMS MTGetForRl(cA100For,cLoja) SIZE 392,9 OF oDlg PIXEL ON CHANGE A103FutTer(aCompFutur, cProduto, cComboFor, @oGetDb, cTMPAlias, aPosObj, @aDocumento, @cForTer, @cLojaTer)
	
				aTexto[2] := AllTrim(RetTitle("DHQ_COD")) + ": " + SB1->B1_COD + " - " + rtrim(SB1->B1_DESC)
				@ 018, 005 SAY aTexto[2] SIZE aPosObj[1, 3], 008 OF oPanel PIXEL
			EndIf
	
			Private aHeader := aTMPHeader
			oGetDb := MsGetDB():New(aPosObj[2, 1]+IIf(lEntTerc,8,0), aPosObj[2, 2], aPosObj[2, 3], aPosObj[2, 4], 1, "AllwaysTrue", "AllwaysTrue", "", .F.,,, .F.,, cTMPAlias)
	
			aOrdem := {AllTrim(RetTitle("DHQ_DOC")) + "+" + AllTrim(RetTitle("DHQ_SERIE")), AllTrim(RetTitle("DHQ_DTREC"))}
			@ aPosObj[3, 1], aPosObj[3, 2] + 000 SAY STR0002 PIXEL  // "Pesquisar por"
			@ aPosObj[3, 1], aPosObj[3, 2] + 040 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 60, 12 OF oDlg PIXEL;
			VALID ((cTMPAlias)->(dbSetOrder(oCombo:nAt), xPesq := aPesq[oCombo:nAt, 1], .T.))
	
			xPesq := aPesq[1, 1]
			@ aPosObj[3, 1], aPosObj[3, 2] + 120 SAY STR0003 PIXEL  // "Localizar"
			@ aPosObj[3, 1], aPosObj[3, 2] + 150 MSGET xPesq PICTURE aPesq[oCombo:nAt, 2] Of oDlg PIXEL;
			VALID (cTMPAlias)->(MsSeek(If(ValType(xPesq) == "C", AllTrim(xPesq), xPesq), .T.), oGetDb:oBrowse:Refresh(), .T.)
	
			DEFINE SBUTTON FROM aPosObj[3, 1] + 00, aPosObj[3, 4] - 25 TYPE 1 ACTION (nOpcA := 1, oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM aPosObj[3, 1] + 12, aPosObj[3, 4] - 25 TYPE 2 ACTION (nOpcA := 0, oDlg:End()) ENABLE OF oDlg
	
			ACTIVATE MSDIALOG oDlg CENTERED
	
			// Verifica se o usuário confirmou a tela.
			If nOpcA = 1 .And. nBrLin > 0 .And. nBrLin < 5000 .And. nBrLin <= Len(aDocumento)	// A MSGetDB cria a variavel publica nBrLin que indica qual a linha posicionada do aCols.
				(cTMPAlias)->(aCompFutur[N] := {DHQ_DOC, DHQ_SERIE, DHQ_ITEM})
				aAdd(aCompFutur[N],aDocumento[nBrLin][2])	// Guarda o Recno da DHQ
				aAdd(aCompFutur[N],aCols[N][nPItemNF])		// Guarda o item do aCols
				aAdd(aCompFutur[N],cForTer)					// Guarda o fornecedor
				aAdd(aCompFutur[N],cLojaTer)				// Guarda a loja do fornecedor
			EndIf

			// Apaga a tabela de trabalho do banco de dados.
			FWCloseTemp(cTMPAlias, cTMPTabela)
		EndIf
	Else
		If cTipo == "C" .And. lRet 
			Help("  ", 1, "MATA103COM",, STR0022, 1, 0)
		Else
			Help("  ", 1, "MATA103COM",, STR0010, 1, 0)  // "Não há notas fiscais de entrega futura com saldo a receber."
		EndIf 
	EndIf
	If !lFutTer
		RestArea(aArea)
	EndIf
EndIf

If lFutTer
	aComFut := aClone(aDocumento)
EndIf

FwFreeArray(aCmpX3)

Return


/*/{Protheus.doc} A103FutVld
Verifica o recebimento da nota de compra com entrega futura.
Nessa função é verificado o saldo a receber e o valor unitário das notas.

@author  Felipe Raposo
@version P12
@since   12/06/2018
@return  lRet - indicando se pode continuar o processamento.
/*/
Function A103FutVld(lDelete, aCompFutur, nLinha, lTudoOk)

Local lRet       := .F.
Local aArea      := {}
Local cQuery     := ""
Local cTopAlias  := ""
Local nSaldo     := 0
Local nX         := 0
Local nLinVld    := 0

If !lDHQInDic
	lRet := .T.
Else
	aArea := GetArea()

	If !lDelete
		// Verifica se o usuario selecionou a nota de entrega futura
		If Len(aCompFutur) >= N .And. ValType(aCompFutur[N]) = "A" .And. Len(aCompFutur[N]) >= 3

			nLinVld := Iif(lTudoOk,nLinha,N)

			cQuery := "select DHQ.DHQ_QTORI - DHQ.DHQ_QTREC SALDO, DHQ.DHQ_VLUNIT VLUNIT " + CRLF
			cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
			cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
			cQuery += "and DHQ.DHQ_DOC    = '" + aCompFutur[nLinVld, 1] + "' " + CRLF
			cQuery += "and DHQ.DHQ_SERIE  = '" + aCompFutur[nLinVld, 2] + "' " + CRLF
			cQuery += "and DHQ.DHQ_FORNEC = '" + aCompFutur[nLinVld, 6] + "' " + CRLF
			cQuery += "and DHQ.DHQ_LOJA   = '" + aCompFutur[nLinVld, 7] + "' " + CRLF
			cQuery += "and DHQ.DHQ_ITEM   = '" + aCompFutur[nLinVld, 3] + "' " + CRLF
			cQuery += "and DHQ.DHQ_COD    = '" + GdFieldGet("D1_COD", nLinVld) + "' " + CRLF
			cQuery += IIF(cTipo == "C","and DHQ.DHQ_TIPO   IN('1','2') " + CRLF,"and DHQ.DHQ_TIPO   = '1' " + CRLF )
			If !cTipo == "C"
				cQuery += "and DHQ.DHQ_QTORI  > DHQ.DHQ_QTREC " + CRLF  // 1-Aberto
			EndIf 
			cQuery += "and DHQ.DHQ_DESFAZ  = ' ' " + CRLF
			cQuery := ChangeQuery(cQuery)
			cTopAlias := MPSysOpenQuery(cQuery)

			If (cTopAlias)->(Eof())
				Help("  ", 1, "MATA103COM",, STR0004, 1, 0)  // "Selecione uma NF de entrega futura com saldo (F7)."
			ElseIf (cTopAlias)->SALDO < GdFieldGet("D1_QUANT", nLinha) .And. !cTipo == 'C'
				Help("  ", 1, "MATA103COM",, STR0014, 1, 0)  // "A quantidade não pode ser superior ao saldo do item na nota de compra futura vinculada."
			ElseIf lTudoOk .And. !cTipo == 'C'  // Se for no TudoOk, valida se outras linhas não estão consumindo o mesmo item.
				nSaldo := (cTopAlias)->SALDO
				For nX := 1 To (nLinha - 1)
					If !Atail(aCols[nX]) .And. aCompFutur[nX] != Nil .And. Len(aCompFutur[nX]) >= 3 .And. aCompFutur[nX, 1] == aCompFutur[nLinha, 1] .And. aCompFutur[nX, 2] == aCompFutur[nLinha, 2] .And. aCompFutur[nX, 3] == aCompFutur[nLinha, 3]
						nSaldo -= GdFieldGet("D1_QUANT", nX)
					EndIf
				Next nX

				lRet := (Atail(aCols[nX])) .or. (nSaldo >= GdFieldGet("D1_QUANT", nLinha))
				If !lRet
					Help("  ", 1, "MATA103COM",, STR0014, 1, 0)  // "Selecione uma NF de entrega futura com saldo (F7)."
				EndIf
			Else
				lRet := .T.
			EndIf

			(cTopAlias)->(dbCloseArea())
		Else
			Help("  ", 1, "MATA103COM",, STR0004, 1, 0)  // "Selecione uma NF de entrega futura com saldo (F7)."
		EndIf
	Else
		// Verifica se a NF a ser excluída é de entrega futura, e possui saldo consumido.
		cQuery := "select CON.DHQ_IDENT IDENT " + CRLF
		cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
		cQuery += "inner join " + RetSQLName("DHQ") + " CON on CON.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "and CON.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
		cQuery += "and CON.DHQ_IDENT  = DHQ.DHQ_IDENT " + CRLF
		cQuery += "and CON.DHQ_TIPO   = '2' " + CRLF  // 2-Entrega.
		cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
		cQuery += "and DHQ.DHQ_DOC    = '" + SD1->D1_DOC + "' " + CRLF
		cQuery += "and DHQ.DHQ_SERIE  = '" + SD1->D1_SERIE + "' " + CRLF
		cQuery += "and DHQ.DHQ_FORNEC = '" + SD1->D1_FORNECE + "' " + CRLF
		cQuery += "and DHQ.DHQ_LOJA   = '" + SD1->D1_LOJA + "' " + CRLF
		cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
		cQuery := ChangeQuery(cQuery)
		cTopAlias := MPSysOpenQuery(cQuery)
		lRet := (cTopAlias)->(eof())
		(cTopAlias)->(dbCloseArea())

		If !lRet
			Help("  ", 1, "MATA103COM",, STR0006, 1, 0)  // "Existe nota de remessa vinculada a essa nota de compra futura."
		EndIf
	EndIf

	RestArea(aArea)
EndIf

Return lRet


/*/{Protheus.doc} A103FutFat
Efetua a gravação do saldo de nota fiscal de compra com entrega futura (faturamento).

@author  Felipe Raposo
@version P12
@since   11/06/2018
@return  Nenhum.
/*/
Function A103FutFat(lDelete)
Local aArea  	As Array 
Local cQuery 	As Character
Local cTopAlias As Character 
Local cIdent 	As Character 
Local nOrder 	As Numeric
Local oQry 		As Object

cQuery 		:= ""
cTopAlias 	:= GetNextAlias()
cIdent 		:= ""
nOrder 		:= 1
oQry 		:= Nil 

Default lDelete := .F.

If lDHQInDic
	aArea := GetArea()

	If !lDelete
		// Pega o número de identificação do saldo da entrega futura.
		// DHQ índice 2 -> DHQ_FILIAL, DHQ_IDENT, DHQ_TIPO, DHQ_DOC, DHQ_SERIE, DHQ_ITEM.
		cIdent := GetSXENum("DHQ", "DHQ_IDENT")
		Do While DHQ->(dbSetOrder(2), dbSeek(xFilial() + cIdent, .F.))
			ConfirmSX8()
			cIdent := GetSXENum("DHQ", "DHQ_IDENT")
		EndDo

		// Cria o saldo a receber.
		RecLock("DHQ", .T.)
		DHQ->DHQ_FILIAL := xFilial("DHQ")
		DHQ->DHQ_IDENT  := cIdent
		DHQ->DHQ_TIPO   := "1"  // 1-Compra futura.
		DHQ->DHQ_DOC    := SD1->D1_DOC
		DHQ->DHQ_SERIE  := SD1->D1_SERIE
		DHQ->DHQ_FORNEC := SD1->D1_FORNECE
		DHQ->DHQ_LOJA   := SD1->D1_LOJA
		DHQ->DHQ_ITEM   := SD1->D1_ITEM
		DHQ->DHQ_DTREC  := SD1->D1_DTDIGIT
		DHQ->DHQ_STATUS := "1"  // 1-Aberto.
		DHQ->DHQ_COD    := SD1->D1_COD
		DHQ->DHQ_QTORI  := SD1->D1_QUANT
		DHQ->DHQ_VLUNIT := SD1->D1_VUNIT
		DHQ->DHQ_ESTOQ  := SF4->F4_ESTOQUE
		DHQ->(msUnLock())
		ConfirmSX8()

		// Atualiza o saldo a receber no SB2.
		MaAvalCF(1, SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_QUANT)
	Else
		// Exclui registro de eliminação de resíduo, se houver.
		If !cTipo == "C"
			cQuery := "select CON.R_E_C_N_O_ DHQRecNo " 
			cQuery += "from ? DHQ " 
			cQuery += "inner join ? CON on CON.D_E_L_E_T_ = ?  " 
			cQuery += "and CON.DHQ_FILIAL = ?  " 
			cQuery += "and CON.DHQ_IDENT  = DHQ.DHQ_IDENT "
			cQuery += "and CON.DHQ_TIPO   = ? " // 9-Elim. resíduo.
			cQuery += "where DHQ.D_E_L_E_T_ = ?  " 
			cQuery += "and DHQ.DHQ_FILIAL = ? " 
			cQuery += "and DHQ.DHQ_DOC    = ? " 
			cQuery += "and DHQ.DHQ_SERIE  = ? "
			cQuery += "and DHQ.DHQ_FORNEC = ? "
			cQuery += "and DHQ.DHQ_LOJA   = ? "
			cQuery += "and DHQ.DHQ_ITEM   = ? "
			cQuery += "and DHQ.DHQ_COD    = ? "
			cQuery += "and DHQ.DHQ_TIPO   = ? " //1-Compra futura.
			
			oQry := FWPreparedStatement():New()
			nOrder := 1
			oQry:SetQuery(cQuery)
			oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
			oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
			oQry:SetString(nOrder++,' ' )
			oQry:SetString(nOrder++,xFilial("DHQ"))
			oQry:SetString(nOrder++,'9')
			oQry:SetString(nOrder++,' ' )
			oQry:SetString(nOrder++,xFilial("DHQ"))
			oQry:SetString(nOrder++,SD1->D1_DOC)
			oQry:SetString(nOrder++,SD1->D1_SERIE)
			oQry:SetString(nOrder++,SD1->D1_FORNECE)
			oQry:SetString(nOrder++,SD1->D1_LOJA)
			oQry:SetString(nOrder++,SD1->D1_ITEM)
			oQry:SetString(nOrder++,SD1->D1_COD)
			oQry:SetString(nOrder++,'1')

			cQuery    := oQry:GetFixQuery()
			cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)

			If (cTopAlias)->(!eof())
				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))

				// Exclui o saldo a receber.
				RecLock("DHQ", .F.)
				DHQ->(dbDelete())
				DHQ->(msUnLock())
			Endif
			(cTopAlias)->(dbCloseArea())
			
			cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo "
			cQuery += "from ?  DHQ " 
			cQuery += "where DHQ.D_E_L_E_T_ = ? " 
			cQuery += "and DHQ.DHQ_FILIAL = ?  " 
			cQuery += "and DHQ.DHQ_DOC    = ? " 
			cQuery += "and DHQ.DHQ_SERIE  = ? " 
			cQuery += "and DHQ.DHQ_FORNEC = ? " 
			cQuery += "and DHQ.DHQ_LOJA   = ? " 
			cQuery += "and DHQ.DHQ_ITEM   = ? " 
			cQuery += "and DHQ.DHQ_COD    = ? " 
			cQuery += "and DHQ.DHQ_TIPO   = ? " // 1-Compra futura.
			
			oQry := FWPreparedStatement():New()
			nOrder := 1
			oQry:SetQuery(cQuery)
			oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
			oQry:SetString(nOrder++,' ' )
			oQry:SetString(nOrder++,xFilial("DHQ"))
			oQry:SetString(nOrder++,SD1->D1_DOC)
			oQry:SetString(nOrder++,SD1->D1_SERIE)
			oQry:SetString(nOrder++,SD1->D1_FORNECE)
			oQry:SetString(nOrder++,SD1->D1_LOJA)
			oQry:SetString(nOrder++,SD1->D1_ITEM)
			oQry:SetString(nOrder++,SD1->D1_COD)
			oQry:SetString(nOrder++,'1')
			
			cQuery    := oQry:GetFixQuery()
			cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)

			If (cTopAlias)->(!eof())
				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))

				// Exclui o saldo a receber.
				RecLock("DHQ", .F.)
				DHQ->(dbDelete())
				DHQ->(msUnLock())

				// Atualiza o saldo a receber no SB2.
				MaAvalCF(2, SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_QUANT)
			Endif
			(cTopAlias)->(dbCloseArea())
		EndIf 
	Endif
	RestArea(aArea)
Endif

Return


/*/{Protheus.doc} A103FutRem
Efetua a gravação do consumo de saldo da nota fiscal de compra com entrega futura (remessa).

@author  Felipe Raposo
@version P12
@since   12/06/2018
@return  Nenhum.
/*/
Function A103FutRem(lDelete, aCompFutur,cAlias)
Local aArea 	As Array
Local cQuery 	As Character 
Local cTopAlias As Character
Local aIdent 	As Array 
Local nOrder 	As Numeric
Local oQry 		As Object 

Default cAlias     := "SD1"
Default aCompFutur := {}
Default lDelete    := .F.

cQuery     := ""
cTopAlias  := GetNextAlias()
aIdent     := {}
nOrder 	   := 1 
oQry 	   := Nil 


If lDHQInDic
	aArea := GetArea()

	If cAlias == "SD1"
		If !lDelete
			cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo "
			cQuery += "from ? DHQ " 
			cQuery += "where DHQ.D_E_L_E_T_ = ? 	"
			cQuery += "and DHQ.DHQ_FILIAL   = ? 	"
			cQuery += "and DHQ.DHQ_DOC      = ? 	" 
			cQuery += "and DHQ.DHQ_SERIE    = ? 	"
			cQuery += "and DHQ.DHQ_FORNEC   = ? 	"
			cQuery += "and DHQ.DHQ_LOJA     = ? 	"
			cQuery += "and DHQ.DHQ_ITEM     = ? 	"
			cQuery += "and DHQ.DHQ_COD      = ? 	"	 
			cQuery += "and DHQ.DHQ_TIPO  IN ( ? ) 	"
			
			oQry := FWPreparedStatement():New()
			nOrder := 1
			oQry:SetQuery(cQuery)
			oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
			oQry:SetString(nOrder++,' ' )
			oQry:SetString(nOrder++,xFilial("DHQ"))
			oQry:SetString(nOrder++,aCompFutur[1])
			oQry:SetString(nOrder++,aCompFutur[2])
			oQry:SetString(nOrder++,aCompFutur[6])
			oQry:SetString(nOrder++,aCompFutur[7])
			oQry:SetString(nOrder++,aCompFutur[3])
			oQry:SetString(nOrder++,SD1->D1_COD)
			
			if cTipo == "C"
				oQry:SetIn(nOrder++, {"1","2"} )
			else
				oQry:SetIn(nOrder++, {"1"} )
			endif 

			cQuery    := oQry:GetFixQuery()
			cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)

			If (cTopAlias)->(!eof())

				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
				aIdent := {DHQ->DHQ_IDENT}

				// Consome o saldo a receber da nota de compras.
				RecLock("DHQ", .F.)
				DHQ->DHQ_QTREC += SD1->D1_QUANT
				If DHQ->DHQ_QTREC < DHQ->DHQ_QTORI
					DHQ->DHQ_STATUS := "1"  // 1-Aberto.
				Else
					DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
				Endif
				DHQ->(msUnLock())

				// Grava o registro do consumo.
				RecLock("DHQ", .T.)
				DHQ->DHQ_FILIAL := xFilial("DHQ")
				DHQ->DHQ_IDENT  := aIdent[1]
				If cTipo == "C"
					DHQ->DHQ_TIPO := "3" //DHQ_TIPO = 3 (Compl. de preço)
				else 
					DHQ->DHQ_TIPO := "2" //DHQ_TIPO = 2 (Entrega)
				endif 		
				DHQ->DHQ_DOC    := SD1->D1_DOC
				DHQ->DHQ_SERIE  := SD1->D1_SERIE
				DHQ->DHQ_FORNEC := SD1->D1_FORNECE
				DHQ->DHQ_LOJA   := SD1->D1_LOJA
				DHQ->DHQ_ITEM   := SD1->D1_ITEM
				DHQ->DHQ_DTREC  := SD1->D1_DTDIGIT
				DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
				DHQ->DHQ_COD    := SD1->D1_COD
				DHQ->DHQ_QTREC  := SD1->D1_QUANT
				DHQ->DHQ_VLUNIT := SD1->D1_VUNIT
				DHQ->DHQ_ESTOQ  := SF4->F4_ESTOQUE
				DHQ->(msUnLock())

				// Atualiza o saldo a receber no SB2.
				If !cTipo == "C" //Nota tipo complemento de preço não possui quantidade
					MaAvalCF(3, SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_QUANT)
				EndIf
			Endif
			(cTopAlias)->(dbCloseArea())
		Else 
			cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo "
			cQuery += "from  ?  DHQ " 
			cQuery += "where DHQ.D_E_L_E_T_ = ? " 
			cQuery += "and DHQ.DHQ_FILIAL   = ? " 
			cQuery += "and DHQ.DHQ_DOC      = ? "
			cQuery += "and DHQ.DHQ_SERIE    = ? "
			cQuery += "and DHQ.DHQ_FORNEC   = ? " 
			cQuery += "and DHQ.DHQ_LOJA     = ? "
			cQuery += "and DHQ.DHQ_ITEM     = ? " 
			cQuery += "and DHQ.DHQ_COD      = ? " 
			cQuery += "and DHQ.DHQ_TIPO 	= ? "

			oQry := FWPreparedStatement():New()
			nOrder := 1
			oQry:SetQuery(cQuery)
			oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
			oQry:SetString(nOrder++,' ' )
			oQry:SetString(nOrder++,xFilial("DHQ"))
			oQry:SetString(nOrder++,SD1->D1_DOC)
			oQry:SetString(nOrder++,SD1->D1_SERIE)
			oQry:SetString(nOrder++,SD1->D1_FORNECE)
			oQry:SetString(nOrder++,SD1->D1_LOJA)
			oQry:SetString(nOrder++,SD1->D1_ITEM)
			oQry:SetString(nOrder++,SD1->D1_COD)

			if cTipo == "C"
				oQry:SetString(nOrder++,'3')
			else 
				oQry:SetString(nOrder++,'2')
			endif 

			cQuery    := oQry:GetFixQuery()
			cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)

			If (cTopAlias)->(!eof())
				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
				aIdent := {DHQ->DHQ_IDENT, DHQ->DHQ_QTREC}

				// Exclui o consumo do saldo a receber da nota de compras.
				RecLock("DHQ", .F.)
				DHQ->(dbDelete())
				DHQ->(msUnLock())
			Endif
			(cTopAlias)->(dbCloseArea())

			// Ajusta o saldo do nota de entrega futura.
			If !empty(aIdent) .And. !cTipo == "C"
				cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo " 
				cQuery += "from ? DHQ " 
				cQuery += "where DHQ.D_E_L_E_T_ = ? " 
				cQuery += "and DHQ.DHQ_FILIAL   = ? " 
				cQuery += "and DHQ.DHQ_IDENT    = ? " 
				cQuery += "and DHQ.DHQ_TIPO     = ? "  // 1-Compra futura.
				cQuery += "and DHQ.DHQ_DESFAZ   = ? "
				
				oQry := FWPreparedStatement():New()
				nOrder := 1
				oQry:SetQuery(cQuery)
				oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
				oQry:SetString(nOrder++,' ' )
				oQry:SetString(nOrder++,xFilial("DHQ"))
				oQry:SetString(nOrder++,aIdent[1])
				oQry:SetString(nOrder++,'1')
				oQry:SetString(nOrder++,' ' )

				cQuery    := oQry:GetFixQuery()
				cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)

				If (cTopAlias)->(!eof())
					DHQ->(dbGoTo((cTopAlias)->DHQRecNo))

					// Ajusta o saldo a receber da nota de compras.
					RecLock("DHQ", .F.)
					DHQ->DHQ_QTREC -= aIdent[2]
					If DHQ->DHQ_QTREC < DHQ->DHQ_QTORI
						DHQ->DHQ_STATUS := "1"  // 1-Aberto.
					Else
						DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
					Endif
					DHQ->(msUnLock())

					// Atualiza o saldo a receber no SB2.
					MaAvalCF(4, SD1->D1_COD, SD1->D1_LOCAL, aIdent[2])
				Endif
				(cTopAlias)->(dbCloseArea())
			Endif
		Endif
	ElseIf cAlias == "SD2"
		If !lDelete
			//Nota de Consumo (Remessa)
			cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo "
			cQuery += "from ?  DHQ "
			cQuery += "where DHQ.D_E_L_E_T_ = ? " 
			cQuery += "and DHQ.DHQ_FILIAL   = ? "
			cQuery += "and DHQ.DHQ_DOC      = ? " 
			cQuery += "and DHQ.DHQ_SERIE    = ? " 
			cQuery += "and DHQ.DHQ_ITEM     = ? " 
			cQuery += "and DHQ.DHQ_FORNEC   = ? " 
			cQuery += "and DHQ.DHQ_LOJA     = ? "
			cQuery += "and DHQ.DHQ_COD      = ? " 
			cQuery += "and DHQ.DHQ_TIPO     = ? "
			
			oQry := FWPreparedStatement():New()
			nOrder := 1
			oQry:SetQuery(cQuery)
			oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
			oQry:SetString(nOrder++,' ' )
			oQry:SetString(nOrder++,xFilial("DHQ"))
			oQry:SetString(nOrder++,aCompFutur[1])  
			oQry:SetString(nOrder++,aCompFutur[2]) 
			oQry:SetString(nOrder++,aCompFutur[3])  
			oQry:SetString(nOrder++,aCompFutur[4])
			oQry:SetString(nOrder++,aCompFutur[5]) 
			oQry:SetString(nOrder++,aCompFutur[6])
			oQry:SetString(nOrder++,'2' )

			cQuery    := oQry:GetFixQuery()
			cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)

			If (cTopAlias)->(!eof())
				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
				aIdent := {DHQ->DHQ_IDENT}
				
				// Grava o registro da devolução do consumo.
				RecLock("DHQ", .T.)
					DHQ->DHQ_FILIAL := xFilial("DHQ")
					DHQ->DHQ_IDENT  := aIdent[1]
					DHQ->DHQ_TIPO   := "4"
					DHQ->DHQ_FORNEC := SF2->F2_CLIENTE
					DHQ->DHQ_LOJA   := SF2->F2_LOJA
					DHQ->DHQ_DOC    := SD2->D2_DOC
					DHQ->DHQ_SERIE  := SD2->D2_SERIE
					DHQ->DHQ_ITEM   := SD2->D2_ITEM 
					DHQ->DHQ_DTREC  := IIF(Empty(SD2->D2_DTDIGIT),SD2->D2_EMISSAO,SD2->D2_DTDIGIT)
					DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
					DHQ->DHQ_COD    := SD2->D2_COD
					DHQ->DHQ_QTREC  := SD2->D2_QUANT
					DHQ->DHQ_VLUNIT := SD2->D2_PRCVEN
					DHQ->DHQ_ESTOQ  := SF4->F4_ESTOQUE
				DHQ->(MsUnLock())
			Endif 
			(cTopAlias)->(dbCloseArea())
			
			if Len(aIdent) > 0 
				//Nota de Simples Faturamento 
				cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo "
				cQuery += "from ?  DHQ "
				cQuery += "where DHQ.D_E_L_E_T_ = ? " 
				cQuery += "and DHQ.DHQ_FILIAL   = ? "
				cQuery += "and DHQ.DHQ_IDENT    = ? "
				cQuery += "and DHQ.DHQ_ITEM     = ? "
				cQuery += "and DHQ.DHQ_FORNEC   = ? " 
				cQuery += "and DHQ.DHQ_LOJA     = ? "
				cQuery += "and DHQ.DHQ_COD      = ? " 
				cQuery += "and DHQ.DHQ_TIPO     = ? "
				
				oQry := FWPreparedStatement():New()
				nOrder := 1
				oQry:SetQuery(cQuery)
				oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
				oQry:SetString(nOrder++,' ' )
				oQry:SetString(nOrder++,xFilial("DHQ"))
				oQry:SetString(nOrder++,aIdent[1])  
				oQry:SetString(nOrder++,aCompFutur[3])
				oQry:SetString(nOrder++,aCompFutur[4])
				oQry:SetString(nOrder++,aCompFutur[5])   
				oQry:SetString(nOrder++,aCompFutur[6])
				oQry:SetString(nOrder++,'1') 
				
				cQuery    := oQry:GetFixQuery()
				cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)
				
				If (cTopAlias)->(!eof())
					DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
					
					// Devolve o saldo a receber da nota de compras.
					RecLock("DHQ", .F.)
						DHQ->DHQ_QTREC := DHQ->DHQ_QTREC-SD2->D2_QUANT
						DHQ->DHQ_STATUS := "1"
					DHQ->(msUnLock()) 	

					// Atualiza o saldo a receber no SB2.
					MaAvalCF(3, SD2->D2_COD, SD2->D2_LOCAL, SD2->D2_QUANT)
				
				Endif 
				(cTopAlias)->(dbCloseArea())
			Endif 
		Else
			//Registro de Devolução
			cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo "
			cQuery += "from ?  DHQ "
			cQuery += "where DHQ.D_E_L_E_T_ = ? " 
			cQuery += "and DHQ.DHQ_FILIAL   = ? "
			cQuery += "and DHQ.DHQ_DOC      = ? " 
			cQuery += "and DHQ.DHQ_SERIE    = ? " 
			cQuery += "and DHQ.DHQ_ITEM     = ? " 
			cQuery += "and DHQ.DHQ_FORNEC   = ? " 
			cQuery += "and DHQ.DHQ_LOJA     = ? "
			cQuery += "and DHQ.DHQ_COD      = ? " 
			cQuery += "and DHQ.DHQ_TIPO     = ? "
			
			oQry := FWPreparedStatement():New()
			nOrder := 1
			oQry:SetQuery(cQuery)
			oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
			oQry:SetString(nOrder++,' ' )
			oQry:SetString(nOrder++,xFilial("DHQ"))
			oQry:SetString(nOrder++,aCompFutur[1])  
			oQry:SetString(nOrder++,aCompFutur[2]) 
			oQry:SetString(nOrder++,aCompFutur[3])  
			oQry:SetString(nOrder++,aCompFutur[4])
			oQry:SetString(nOrder++,aCompFutur[5]) 
			oQry:SetString(nOrder++,aCompFutur[6])
			oQry:SetString(nOrder++,'4' )

			cQuery    := oQry:GetFixQuery()
			cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)

			If (cTopAlias)->(!eof())
				DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
				aIdent := {DHQ->DHQ_IDENT}

				//Exclui o registro de devolução.
				RecLock("DHQ", .F.)
					DHQ->(dbDelete())
				DHQ->(msUnLock())

			EndIf
			(cTopAlias)->(dbCloseArea())

			if Len(aIdent) > 0 
				//Nota de Simples Faturamento 
				cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo "
				cQuery += "from ?  DHQ "
				cQuery += "where DHQ.D_E_L_E_T_ = ? " 
				cQuery += "and DHQ.DHQ_FILIAL   = ? "
				cQuery += "and DHQ.DHQ_IDENT    = ? "
				cQuery += "and DHQ.DHQ_ITEM     = ? "
				cQuery += "and DHQ.DHQ_FORNEC   = ? " 
				cQuery += "and DHQ.DHQ_LOJA     = ? "
				cQuery += "and DHQ.DHQ_COD      = ? " 
				cQuery += "and DHQ.DHQ_TIPO     = ? "
				
				oQry := FWPreparedStatement():New()
				nOrder := 1
				oQry:SetQuery(cQuery)
				oQry:SetNumeric(nOrder++,RetSqlName("DHQ"))
				oQry:SetString(nOrder++,' ' )
				oQry:SetString(nOrder++,xFilial("DHQ"))
				oQry:SetString(nOrder++,aIdent[1])  
				oQry:SetString(nOrder++,StrZero(Val(aCompFutur[3]), TamSX3("D1_ITEM")[1]))
				oQry:SetString(nOrder++,aCompFutur[4])
				oQry:SetString(nOrder++,aCompFutur[5])   
				oQry:SetString(nOrder++,aCompFutur[6])
				oQry:SetString(nOrder++,'1') 
				
				cQuery    := oQry:GetFixQuery()
				cTopAlias := MpSysOpenQuery(cQuery,cTopAlias)
				
				If (cTopAlias)->(!eof())
					DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
					
					// Ajusta o saldo a receber da nota de compras.
					RecLock("DHQ", .F.)
					DHQ->DHQ_QTREC += aCompFutur[7]
					If DHQ->DHQ_QTREC < DHQ->DHQ_QTORI
						DHQ->DHQ_STATUS := "1"  // 1-Aberto.
					Else
						DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
					Endif
					DHQ->(msUnLock())

					// Atualiza o saldo a receber no SB2.
					MaAvalCF(4, SD2->D2_COD, SD2->D2_LOCAL, aCompFutur[7])
				
				Endif 
				(cTopAlias)->(dbCloseArea())
			EndIf
				
		Endif 
	Endif 	
	
	RestArea(aArea)
Endif

Return


/*/{Protheus.doc} A103CFRes
Elimina resíduo de saldo a receber de compra futura (Desfazimento).

@author  Felipe Raposo
@version P12
@since   12/06/2018
@return  Nenhum.
/*/
Function A103Desfaz()

Local lDHQInDic  := AliasInDic("DHQ") .And. SF4->(ColumnPos("F4_EFUTUR") > 0)
Local lRet       := .F.
Local aArea      := {}
Local cQuery     := ""
Local cTopAlias  := ""
Local aIdent     := {}
Local nOpcDesfaz := 0

If !lDHQInDic
	Help(Nil, 1, "A103CFDESF", Nil, STR0012, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0013})	// "Tabela DHQ ou campo F4_EFUTUR não encontrados no dicionário de dados." / "Para executar a rotina de Desfazimento atualize seu dicionário de acordo com a funcionalidade de Compra com Entrega Futura."
	lRet := .F.
Else
	aArea := GetArea()
	
	cQuery := "select DHQ.R_E_C_N_O_ DHQRecNo, SD1.R_E_C_N_O_ SD1RecNo " + CRLF
	cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
	cQuery += "inner join " + RetSQLName("SD1") + " SD1 on SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and SD1.D1_FILIAL  = '" + xFilial("SD1") + "' " + CRLF
	cQuery += "and SD1.D1_DOC     = DHQ.DHQ_DOC " + CRLF
	cQuery += "and SD1.D1_SERIE   = DHQ.DHQ_SERIE " + CRLF
	cQuery += "and SD1.D1_FORNECE = DHQ.DHQ_FORNEC " + CRLF
	cQuery += "and SD1.D1_LOJA    = DHQ.DHQ_LOJA " + CRLF
	cQuery += "and SD1.D1_ITEM    = DHQ.DHQ_ITEM " + CRLF
	cQuery += "and SD1.D1_COD     = DHQ.DHQ_COD " + CRLF
	cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
	cQuery += "and DHQ.DHQ_DOC    = '" + SF1->F1_DOC + "' " + CRLF
	cQuery += "and DHQ.DHQ_SERIE  = '" + SF1->F1_SERIE + "' " + CRLF
	cQuery += "and DHQ.DHQ_FORNEC = '" + SF1->F1_FORNECE + "' " + CRLF
	cQuery += "and DHQ.DHQ_LOJA   = '" + SF1->F1_LOJA + "' " + CRLF
	cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
	cQuery += "and DHQ.DHQ_STATUS = '1' " + CRLF  // 1-Aberto.
	cQuery += "and DHQ.DHQ_QTORI  > DHQ.DHQ_QTREC " + CRLF  // 1-Aberto.
	cQuery += "order by DHQ.DHQ_DTREC, DHQ.DHQ_DOC, DHQ.DHQ_SERIE, DHQ.DHQ_ITEM " + CRLF
	cQuery := ChangeQuery(cQuery)
	cTopAlias := MPSysOpenQuery(cQuery)

	If (cTopAlias)->(!Eof())
		nOpcDesfaz := Aviso(STR0011,STR0007,{STR0015,STR0016},2)	// "Desfazimento" , "Essa rotina irá eliminar o saldo a receber (desfazimento) do processo abaixo. Deseja continuar?" , "Sim" , "Não"
		If nOpcDesfaz == 1	// Sim
			Begin Transaction
				Do While (cTopAlias)->(!eof())
					DHQ->(dbGoTo((cTopAlias)->DHQRecNo))
					SD1->(dbGoTo((cTopAlias)->SD1RecNo))
					aIdent := {DHQ->DHQ_IDENT, DHQ->DHQ_QTORI - DHQ->DHQ_QTREC}
	
					// Consome o saldo a receber da nota de compras.
					RecLock("DHQ", .F.)
					DHQ->DHQ_QTREC += aIdent[2]
					DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
					DHQ->DHQ_DESFAZ  := "S"
					DHQ->(msUnLock())
	
					// Grava o registro do consumo.
					RecLock("DHQ", .T.)
					DHQ->DHQ_FILIAL := xFilial("DHQ")
					DHQ->DHQ_IDENT  := aIdent[1]
					DHQ->DHQ_TIPO   := "9"  // 9-Elim. resíduo.
					DHQ->DHQ_DTREC  := dDataBase
					DHQ->DHQ_STATUS := "9"  // 9-Encerrado.
					DHQ->DHQ_COD    := SD1->D1_COD
					DHQ->DHQ_QTREC  := aIdent[2]
					DHQ->(msUnLock())
	
					// Atualiza o saldo a receber no SB2.
					MaAvalCF(9, SD1->D1_COD, SD1->D1_LOCAL, aIdent[2])
	
					(cTopAlias)->(dbSkip())
				EndDo
			End Transaction

			MsgInfo(STR0008, STR0001)   // "Desfazimento realizado com sucesso." / "Notas fiscais de origem (compra com entrega futura)"
		EndIf
	Else
		Help(" ", 1, "A103CFSLD", , STR0009, 1, 0)	// "Esta nota fiscal não possui saldo de compra com entrega futura a receber."
		lRet := .F.
	EndIf
	(cTopAlias)->(dbCloseArea())

	RestArea(aArea)
EndIf

Return lRet


/*/{Protheus.doc} MaAvalCF
Efetua o ajuste do saldo a receber do produto ao ajustar tabela de compra com entrega futura.

nEvento - código do evento.
	[1] - Inclusão de compra com entrega futura (simples faturamento).
	[2] - Exclusão de compra com entrega futura (simples faturamento).
	[3] - Consumo de compra com entrega futura (remessa).
	[4] - Estorno no consumo de compra com entrega futura (remessa).
	[9] - Elimina resíduo do saldo a receber de compra com entrega futura.

@author  Felipe Raposo
@version P12
@since   25/07/2018
@return  Nenhum.
/*/
Function MaAvalCF(nEvento, cProduto, cLocal, nQtdeUM1)

Local nQtdeUM2 := ConvUm(cProduto, nQtdeUM1, 0, 2)

// [1] - Inclusão de compra com entrega futura (simples faturamento).
// [4] - Estorno no consumo de compra com entrega futura (remessa).
If nEvento = 1 .or. nEvento = 4

	// Atualiza o saldo a receber no SB2.
	SB2->(dbSetOrder(1))  // B2_FILIAL, B2_COD, B2_LOCAL.
	If SB2->(!MsSeek(xFilial() + cProduto + cLocal, .F.))
		CriaSB2(cProduto, cLocal)
	Endif
	RecLock("SB2", .F.)
	SB2->B2_SALPEDI += nQtdeUM1
	SB2->B2_SALPED2 += nQtdeUM2
	SB2->(msUnLock())

	// [2] - Exclusão de compra com entrega futura (simples faturamento).
	// [3] - Consumo de compra com entrega futura (remessa).
	// [9] - Elimina resíduo do saldo a receber de compra com entrega futura.
ElseIf nEvento = 2 .or. nEvento = 3 .or. nEvento = 9

	// Atualiza o saldo a receber no SB2.
	SB2->(dbSetOrder(1))  // B2_FILIAL, B2_COD, B2_LOCAL.
	If SB2->(MsSeek(xFilial() + cProduto + cLocal, .F.))
		RecLock("SB2", .F.)
		SB2->B2_SALPEDI := max(0, SB2->B2_SALPEDI - nQtdeUM1)
		SB2->B2_SALPED2 := max(0, SB2->B2_SALPED2 - nQtdeUM2)
		SB2->(msUnLock())
	Endif
Endif

Return

/*/{Protheus.doc} A103Refaz
Funcao destinada a reprocessar os saldos acumulados de compra com entrega futura (chamada via rotina MATA215)

cFilAnt - código da filial
cFirst  - código da primeira filial
lBat    - indica se o processamento e via batch
oObj    - objeto para exibir as mensagens informativas do processamento

@author  Felipe Raposo
@version P12
@since   25/07/2018
@return  Nenhum.
/*/
Function A103Refaz(cFilAnt, cFirst, lBat, oObj, l215Regua, cFilProc)

Local cMensagem := STR0017
Local cAliasDHQ := "DHQMA215PROC"
Local cQuery    := ""
Local aStru     := TamSX3("DHQ_QTORI")

Default l215Regua  := .F.
Default cFilProc   := ""
// Atualiza os dados acumulados do compras com entrega futura.
If (!Empty(xFilial("DHQ")) .Or. cFilAnt == cFirst )

	dbSelectArea("DHQ")
	dbSetOrder(1)

	cQuery := "select DHQ.DHQ_FILIAL FILIAL, DHQ.DHQ_COD PRODUTO, SD1.D1_LOCAL ALMOX, DHQ.DHQ_QTORI - DHQ.DHQ_QTREC QUANT_UM1 " + CRLF
	cQuery += "from " + RetSQLName("DHQ") + " DHQ " + CRLF
	cQuery += "inner join " + RetSQLName("SD1") + " SD1 on SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and SD1.D1_FILIAL  = '" + xFilial("SD1") + "' " + CRLF
	cQuery += "and SD1.D1_DOC     = DHQ.DHQ_DOC " + CRLF
	cQuery += "and SD1.D1_SERIE   = DHQ.DHQ_SERIE " + CRLF
	cQuery += "and SD1.D1_FORNECE = DHQ.DHQ_FORNEC " + CRLF
	cQuery += "and SD1.D1_LOJA    = DHQ.DHQ_LOJA " + CRLF
	cQuery += "and SD1.D1_ITEM    = DHQ.DHQ_ITEM " + CRLF
	cQuery += "and SD1.D1_COD     = DHQ.DHQ_COD " + CRLF
	cQuery += "where DHQ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "and DHQ.DHQ_FILIAL = '" + xFilial("DHQ") + "' " + CRLF
	cQuery += "and DHQ.DHQ_TIPO   = '1' " + CRLF  // 1-Compra futura.
	cQuery += "and DHQ.DHQ_STATUS = '1' " + CRLF  // 1-Aberto.
	cQuery += "and DHQ.DHQ_QTORI  <> DHQ.DHQ_QTREC " + CRLF
	cQuery += "and DHQ.DHQ_DESFAZ  = ' ' " + CRLF
	cQuery += "order by 1, 2, 3 "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDHQ,.T.,.T.)

	TcSetField(cAliasDHQ, "QUANT_UM1", "N", aStru[1], aStru[2])

	If !lBat
		If l215Regua
			oObj:SetRegua1(DHQ->(LastRec()))
			oObj:IncRegua1(cMensagem)
		Else
			oObj:cCaption := cFilProc + cMensagem;ProcessMessages()
		EndIf
	EndIf

	Do While (cAliasDHQ)->(!eof())
		MaAvalCF(1, (cAliasDHQ)->PRODUTO, (cAliasDHQ)->ALMOX, (cAliasDHQ)->QUANT_UM1)
		If l215Regua
			oObj:IncRegua1(cMensagem)
		EndIf
		(cAliasDHQ)->(dbSkip())
	EndDo
	(cAliasDHQ)->(dbCloseArea())
	dbSelectArea("DHQ")
EndIf

Return

/*/{Protheus.doc} A103VldTES
Funcao destinada a validar a configuracao da TES quando utilizada para compra com entrega futura (chamada via rotina MATA080)

@author  Felipe Raposo
@version P12
@since   25/07/2018
@return  lRet
/*/
Function A103VldTES()

Local lRet := .T.

If M->F4_EFUTUR == "1" .And. M->F4_ESTOQUE == "S"
	Help(Nil, 1, "F4_EFUTUR", Nil, STR0018, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0019})
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} A103FutTer
Funcionalidade para utilizar o recurso de Entrega por Terceiros na compra com entrega futura

@author  Carlos Capeli
@version P12
@since   12/07/2019
@return  Nenhum.
/*/
Function A103FutTer(aCompFutur, cProduto, cComboFor, oGetDb, cTMPAlias, aPosObj, aDocumento, cForTer, cLojaTer)

Local aComFut     := {}
Local cForLojTer  := ""
Local cFornTer    := ""
Local cLojTer    := ""

Default oGetDb     := Nil
Default aCompFutur := {}
Default aDocumento := {}
Default cProduto   := ""
Default cComboFor  := ""
Default cTMPAlias  := ""
Default cForTer    := ""
Default cLojaTer   := ""

cForLojTer := SubStr(cComboFor, At(' | ',cComboFor)+3, Len(cComboFor))
cForLojTer := SubStr(cForLojTer,1, At(' - ',cForLojTer)-1)

cFornTer := SubStr(cForLojTer, 1, At('/',cForLojTer)-1)
cLojTer  := SubStr(cForLojTer, At('/',cForLojTer)+1, Len(cForLojTer))
cForTer  := cFornTer
cLojaTer := cLojTer

A103FutSel(aCompFutur, cFornTer, cLojTer, cProduto, oGetDb, @aComFut)

aDocumento := aClone(aComFut)

oGetDb := MsGetDB():New(aPosObj[2, 1]+8, aPosObj[2, 2], aPosObj[2, 3], aPosObj[2, 4], 1, "AllwaysTrue", "AllwaysTrue", "", .F.,,, .F.,, cTMPAlias)

oGetDb:ForceRefresh()

Return

/*/{Protheus.doc} A103DKDDIC
Avaliar dicionario DKD

@author  rodrigo.mpontes
@version P12
@since   11/06/2022
/*/
Function A103DKD(lClas103,lVis103,lAlt140,lVis140,lShowDKD)

Local aDKDStruct	:= {}
Local nI			:= 0
Local nZ			:= 0
Local nPos			:= 0
Local nPosNot		:= 0
Local aChvDKD		:= {"DKD_FILIAL","DKD_DOC","DKD_SERIE","DKD_FORNEC","DKD_LOJA","DKD_TIPO","DKD_ESPECI","DKD_EMISSA"}
Local aNotUpdDKD	:= {"DKD_ITEM","DKD_VALBRU"}
Local aNotVisDKD	:= {}
Local lRet			:= .F.
Local nTamDKDIt		:= TamSX3("DKD_ITEM")[1]
Local nPosD1It		:= GdFieldPos("D1_ITEM",aHeader)
Local lDKDValBru	:= DKD->(FieldPos("DKD_VALBRU")) > 0
Local lUserCpo 		:= .F.

Default lClas103 	:= .F.
Default lVis103		:= .F.
Default lAlt140		:= .F.
Default lVis140		:= .F.
Default lShowDKD    := .F.

aDKDStruct := FWSX3Util():GetListFieldsStruct("DKD",.T.)  

For nI := 1 To Len(aDKDStruct)
	nPos 	:= aScan(aChvDKD	,{|x| Alltrim(x) == AllTrim(aDKDStruct[nI,1])}) //Campo Diferente da Chave do documento
	nPosNot := aScan(aNotUpdDKD	,{|x| Alltrim(x) == AllTrim(aDKDStruct[nI,1])}) //Campo existente, porem, não devem ser alterados
	If nPos == 0 .And. nPosNot == 0 //Possui campo customizado
		aAdd(aAltDKD,AllTrim(aDKDStruct[nI,1]))
	Endif
	If X3Usado(aDKDStruct[nI,1]) .and. AllTrim(GetSX3Cache(aDKDStruct[nI,1], 'X3_PROPRI')) == "U"
		lUserCpo := .T.
	endif
Next nI

aNotVisDKD := aClone(aChvDKD)

If lDKDValBru
	aAdd(aNotVisDKD,"DKD_VALBRU")
Endif

lRet := (Len(aAltDKD) > 0)

if !lShowDKD .and. !lUserCpo //--se tiver campo customizado, não poderá ser desativado.
	lRet := .F.
endif

If lRet 
	aColsDKD := {}
	aHeadDKD := COMXHDCO("DKD",,aNotVisDKD) //Header

	//Execauto ou Classificação ou Visualização 103 ou Alteração ou Visualização 140
	If (Type("aAutoDKD") == "A" .And. Len(aAutoDKD) > 0) .Or. lClas103 .Or. lVis103 .Or. lAlt140 .Or. lVis140
		For nI := 1 To Len(aCols)
			aadd(aColsDKD,Array(Len(aHeadDKD)+1)) //aCols
			For nZ := 1 to Len(aHeadDKD)
				If AllTrim(aHeadDKD[nZ,2]) == "DKD_ITEM"
					aColsDKD[Len(aColsDKD)][nZ] := aCols[nI,nPosD1It]
				Else
					aColsDKD[Len(aColsDKD)][nZ] := A103DKDDADOS(aCols[nI,nPosD1It],lClas103,aHeadDKD[nZ,2],lVis103,lAlt140,lVis140)
				Endif
			Next nZ
			aColsDKD[Len(aColsDKD)][Len(aHeadDKD)+1] := .F. 	
		Next nI
	Else
		aadd(aColsDKD,Array(Len(aHeadDKD)+1)) //aCols
		For nI := 1 to Len(aHeadDKD)
			If AllTrim(aHeadDKD[nI,2]) == "DKD_ITEM"
				aColsDKD[1,nI] 	:= StrZero(1,nTamDKDIt)
			Else
				aColsDKD[1,nI] := CriaVar(aHeadDKD[nI,2])
			EndIf
			aColsDKD[1][Len(aHeadDKD)+1] := .F.
		Next nI
	Endif
Endif
Return lRet

/*/{Protheus.doc} A103DKDDADOS
Atualiza aColsDKD

@author  rodrigo.mpontes
@version P12
@since   11/06/2022
/*/
Function A103DKDDADOS(cItem,lClas103,cCampo,lVis103,lAlt140,lVis140)

Local nPos1	:= 0
Local nPos2	:= 0
Local nI	:= 0
Local xRet	:= Nil

If (Type("aAutoDKD") == "A" .And. Len(aAutoDKD) > 0)
	For nI := 1 To Len(aAutoDKD)
		nPos1 := aScan(aAutoDKD[nI],{|x| AllTrim(x[1]) == "DKD_ITEM"})
		If nPos1 > 0
			If aAutoDKD[nI,nPos1,2] == cItem
				nPos2  := aScan(aAutoDKD[nI],{|x| AllTrim(x[1]) == AllTrim(cCampo)})
				If nPos2 > 0
					xRet := aAutoDKD[nI,nPos2,2]
					Exit
				Endif
			Endif
		Endif
	Next nI
Elseif lClas103 .Or. lVis103 .Or. lAlt140 .Or. lVis140
	xRet := GetAdvFVal("DKD",cCampo,xFilial("DKD") + cNFiscal + cSerie + cA100For + cLoja + cItem + DtoS(dDEmissao) + cEspecie,1)
Endif

If ValType(xRet) == "U"
	xRet := CriaVar(cCampo)
Endif

Return xRet

/*/{Protheus.doc} A103DKDATU
Atualiza aColsDKD e visualização em tela

@author  rodrigo.mpontes
@version P12
@since   11/06/2022
/*/
Function A103DKDATU(nOpc,lVincPc)

Local nItDKD	:= GdFieldPos("DKD_ITEM",aHeadDKD)
Local nItSD1	:= GdFieldPos("D1_ITEM",aHeader)
Local nI		:= 0
Local nZ		:= 0
Local lInclui	:= .F.
Default nOpc    := 0
Default lVincPc := .F.

lInclui := iif(Type("Inclui") == "L",Inclui,.f.)
If Type("l103Auto") <> "L"
	l103Auto := .F.
Endif

If Len(aColsDKD) <> Len(aCols)  //Cria nova posição aColsDKD
	For nI := 1 To Len(aCols)
		If nI > Len(aColsDKD)
			aadd(aColsDKD,Array(Len(aHeadDKD)+1)) //aCols
			For nZ := 1 to Len(aHeadDKD)
				If AllTrim(aHeadDKD[nZ,2]) == "DKD_ITEM"
					aColsDKD[Len(aColsDKD),nZ] 	:= aCols[nI,nItSD1]
				Else
					if l103Auto .and. lInclui
						aColsDKD[Len(aColsDKD),nZ] := A103DKDDADOS(aCols[nI,nItSD1],.f.,aHeadDKD[nZ,2],.F.,.F.,.F.)
					Else
						aColsDKD[Len(aColsDKD),nZ] := CriaVar(aHeadDKD[nZ,2]) 
					Endif	
				EndIf
				aColsDKD[Len(aColsDKD)][Len(aHeadDKD)+1] := .F.
			Next nZ			
		Endif
	Next nI
Endif

If Type( "oGetDKD" ) <> "U"
	//Atualizar dados do oGetDKD:aCols (visualiza) para aColsDKD (todos os itens)
	For nI := 1 To Len(aColsDKD)
		If aColsDKD[nI,nItDKD] == oGetDKD:aCols[oGetDKD:nAt,nItDKD]  .and. !lVincPc
			For nZ := 1 to Len(aHeadDKD)
				aColsDKD[nI,nZ] := oGetDKD:aCols[oGetDKD:nAt,nZ]
			Next nZ
		Endif
	Next nI

	/*Controle para não utilizar a private:n quando a chamada vier da ativação do browse (bChange) 
	na nota de devolução ou execauto com abertura de tela, pois como o MsGetDAuto executa o A103LinOk, 
	a private:n já vai estar no último item, dessa forma a dkd tbm abrirá no ultimo item.
	*/
	if Type("lLinOK") =="L" .And. !lLinOK .And. !l103visual 
		nOpc := 1
	endif

	//Atualiza informaçao a ser apresentada - Posicionado na SD1
	For nI := 1 To Len(aColsDKD)
		If aColsDKD[nI,nItDKD] == aCols[Iif(nOpc==1,1, Iif(n > Len(aCols),Len(aCols),n)),nItSD1]
			For nZ := 1 to Len(aHeadDKD)
				oGetDKD:aCols[oGetDKD:nAt,nZ] := aColsDKD[nI,nZ]
			Next nZ
		Endif
	Next nI

	If nOpc == 1 //Ajuste oGetDKD:aCols (l103Class ou Execauto)
		If Len(oGetDKD:aCols) > 1
			For nI := 2 To Len(oGetDKD:aCols)
				If nI <= Len(oGetDKD:aCols) 
					aDel( oGetDKD:aCols, nI )
					aSize( oGetDKD:aCols, Len(oGetDKD:aCols)-1)
					nI := 1
				Endif
			Next nI
		Endif
	Endif

	oGetDKD:Refresh()
	oGetDKD:oBrowse:Refresh()
Endif 

Return

/*/{Protheus.doc} A103DKDGRV
Gravação do complemento de itens da NF

@author  rodrigo.mpontes
@version P12
@since   11/06/2022
/*/
Function A103DKDGRV(aHeadDKD,aColsDKD,nPosIt,cDel,lShowDKD)

Local nI 			:= 1
Local lGrv			:= .F.
Local nItDKD		:= 0
Local lSeekDkd  	:= .F.
Local lDKDValBru	:= DKD->(FieldPos("DKD_VALBRU")) > 0
Local nPos			:= 0
Local nItD1			:= GetPosSD1("D1_ITEM")
Local nValBrut		:= 0
Local cItem 		:= ""

Default cDel	 := ""
Default lShowDKD := .F. //-- .T. -> DKD está ativa na tela, .F. está desativado.

if len(aHeadDKD) > 0
	nItDKD := GdFieldPos("DKD_ITEM",aHeadDKD)
endif

if lShowDKD .and. len(aColsDKD) > 0 .and. nItDKD > 0
	cItem := aColsDKD[nPosIt][nItDKD]
else 
	cItem := SD1->D1_ITEM
endif

DbSelectArea("DKD")
DKD->(DbSetOrder(1)) //DKD_FILIAL, DKD_DOC, DKD_SERIE, DKD_FORNEC, DKD_LOJA, DKD_ITEM, DKD_EMISSA, DKD_ESPECI
lSeekDkd := DKD->(MsSeek(xFilial("DKD") + cNFiscal + cSerie + cA100For + cLoja + cItem + DtoS(dDEmissaoA) + cEspecieA))
If !lSeekDkd
	lGrv := .T. 
Endif

If lShowDKD .and. lDKDValBru .And. nItD1 > 0 .And. nItDKD > 0
	nPos := aScan(aCols,{|x| AllTrim(x[nItD1]) == AllTrim(aColsDKD[nPosIt][nItDKD])})
	If nPos > 0 .And. MaFisFound("IT",nPos)
		nValBrut := MaFisRet(nPos,"IT_TOTAL") //Valor Bruto Item
	Endif
elseif !lShowDKD .and. lDKDValBru 
	nPos := aScan(aCols,{|x| AllTrim(x[nItD1]) == AllTrim(SD1->D1_ITEM)})
	If nPos > 0 .And. MaFisFound("IT",nPos)
		nValBrut := MaFisRet(nPos,"IT_TOTAL") //Valor Bruto Item
	Endif
Endif

lGrv := Iif(Empty(cDel),lGrv,.F.)

If Empty(cDel) .and. RecLock("DKD",lGrv)
	DKD->DKD_FILIAL	:= xFilial("DKD")  
	DKD->DKD_DOC	:= cNFiscal
	DKD->DKD_SERIE	:= cSerie
	DKD->DKD_FORNEC	:= cA100For
	DKD->DKD_LOJA	:= cLoja
	DKD->DKD_EMISSA	:= dDEmissao
	DKD->DKD_ESPECI	:= cEspecie

	if lShowDKD
		For nI := 1 to Len(aHeadDKD)
			DKD->(FieldPut(FieldPos(aHeadDKD[nI,2]),aColsDKD[nPosIt][nI]))
		Next nI
	else 
		DKD->DKD_ITEM := cItem
	endif

	If lDKDValBru
		DKD->DKD_VALBRU := nValBrut
	Endif
	
	DKD->(MsUnlock())
ElseIf lSeekDkd .and. RecLock("DKD",.F.)
	DKD->(Dbdelete())
	DKD->(MsUnlock())
Endif
	
Return

/*/{Protheus.doc} A103DKDGAT
Função generica para utilização de gatilhos

@author  rodrigo.mpontes
@version P12
@since   11/06/2022 
/*/

Function A103DKDGAT(cAliasFind,nIndFind,cChvFind,cCpoRet,cCpoDKD)

Local xRet		:= Nil
Local nPosDKD	:= GdFieldPos(cCpoDKD,aHeadDKD)
Local cCpoX7 	:= SX7->X7_CAMPO
Local nPosVal 	:= 0

If Empty(cChvFind) .Or. FwIsInCallStack("MATA116") .Or. FWIsInCallStack("MATA119")
	nPosVal 	:= GDFieldPos(cCpoX7,aHeader)
	If nPosVal > 0
		cChvFind	:= aCols[n][nPosVal]
	EndIf
EndIf

xRet := GetAdvFVal(cAliasFind,cCpoRet,xFilial(cAliasFind) + cChvFind,nIndFind)

If ValType(xRet) == "U"
	xRet := CriaVar(cCpoDKD) 
Endif

If Type( "oGetDKD" ) <> "U"
	If nPosDKD > 0
		oGetDKD:aCols[oGetDKD:nAt,nPosDKD] := xRet
		oGetDKD:Refresh()
		oGetDKD:oBrowse:Refresh()
	Endif
Elseif Len(aColsDKD) >= n .AND. nPosDKD > 0
	aColsDKD[n][nPosDKD] := xRet
Endif

Return xRet

/*/{Protheus.doc} gatilhadkd
Aciona os gatilhos da dkd

@author  Leandro Nishihata
@version P12
@since   11/06/2022 
/*/

Function gatilhadkd()
Local cCpo		:= ""
Local nI		:= 0
Local lX7CondS	:= .F.
Local lX7CondE	:= .F.
Local nPosAhead := 0
Local lPcToNf := IsInCallStack("A103ForF4") .or. IsInCallStack("A103ItemPC")

DbSelectArea("SX7")
SX7->(dbSetOrder(1))

If SX7->( dbSeek( 'D1_' ) )
	While !SX7->( Eof() ) .And. LEFT(SX7->X7_CAMPO,3) == "D1_"		
		IF AllTrim(SX7->X7_CAMPO) == "D1_COD" .And. AllTrim(SX7->X7_CDOMIN) == "D1_SERVIC"
			lX7CondS := AllTrim(Upper(SX7->X7_CONDIC)) == '!EMPTY(M->D1_COD)'
		Elseif AllTrim(SX7->X7_CAMPO) == "D1_COD" .And. AllTrim(SX7->X7_CDOMIN) == "D1_ENDER"
			lX7CondE := AllTrim(Upper(SX7->X7_CONDIC)) == '!EMPTY(M->D1_COD)'
		Endif
		SX7->( DbSkip() )
		If LEFT(SX7->X7_CAMPO,3) <> "D1_"
			Exit
		Endif
	Enddo
EndIf

SX7->(DbGotop())
If SX7->( dbSeek( 'D1_' ) ) .And. lX7CondS .And. lX7CondE
	While !SX7->( Eof() ) .And. LEFT(SX7->X7_CAMPO,3) == "D1_"		
		nPosAhead := GDFieldPos(SX7->X7_CAMPO,aHeader)	
		IF LEFT(SX7->X7_CDOMIN,4) == "DKD_" .AND. cCpo <> SX7->X7_CAMPO .AND. nPosAHead <> 0 
			cCpo := SX7->X7_CAMPO
			If lPcToNf
				FOR nI := 1 to len(aCols)
						oGetDKD:aCols[oGetDKD:nAt,1] := STRZERO(nI,TamSX3("DKD_ITEM")[1])
						RunTrigger(2,nI,,,alltrim(SX7->X7_CAMPO))
						A103DKDATU()
				Next nI
            Else
				RunTrigger(2,n,,,alltrim(SX7->X7_CAMPO))
				A103DKDATU()
		    EndIf

		Endif
		
		SX7->( DbSkip() )
		If LEFT(SX7->X7_CAMPO,3) <> "D1_"
			Exit
		Endif
	Enddo
EndIf

Return

/*/{Protheus.doc} gatilhadkd
Efetua validações na dkd.

@author  Leandro Nishihata
@version P12
@since   11/06/2022 
/*/

Function A103DKVld(aHeadDKD,aColsDKD)
Local nZ := 0
Local nX := 0
Local lRet := .T.

For nZ := 1 to len(aHeadDKD)
	If  lRet .AND. X3OBRIGAT(AllTrim(aHeadDKD[nZ,2])) .AND. aHeadDKD[nZ,2] <> "DKD_ITEM"
		For nX := 1 To len(aColsDKD) // verifica preenchimento dos campos obrigatorios.
			If EMPTY(aColsDKD[nx,nz]) .and. !aCols[nx,len(aCols[nx])]
				lRet := .F.
				Help(Nil, 1, "A103DKDATU", Nil, STR0023, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0024 +AllTrim(FWSX3Util():GetDescription(AllTrim(aHeadDKD[nZ,2])))+STR0025+ alltrim(str(nX))}) // "Foi encontrado campo complementar definido como obrigatório não preenchido" //"Verificar o campo " //" do Item "
				Exit
			Endif	
		Next
	Endif	
Next

Return lRet


/*/{Protheus.doc} A103ChkDKNAmb
	Verifica se as tabelas de vinculação de documentos estão presentes no ambiente do sistema.
	@author renan.martins
	@since 10/2025
	@return lRet, logical, Se existe a tabela DKN no ambiente
	@version 1.0
/*/
function A103ChkDKNAmb()
	Local lRet	:= .F.
	
	if ( cPaisLoc == "BRA" )
		lRet := FWAliasInDic("DKN") .and. ChkFile("DKN") .and. findFunction("COMDOCREF")
	endif
return lRet

/*/{Protheus.doc} A103CmpGovernamental
	Função que valida se os campos de compra governamental existem na base.
	@author renan.martins
	@since 10/2025
	@return lRet, lógico, se existem os campos na base.
	@version 1.0
/*/
Function A103CmpGovernamental()
	Local lRet := .F.

	lRet := ( SF1->(FieldPos("F1_PCTRED")) > 0 .AND. SF1->(FieldPos("F1_OPGOV")) > 0 .AND. SF1->(FieldPos("F1_CPGOVE")) > 0 )

return lRet

/*/{Protheus.doc} hasRefDKN
	Função que valida o documento passado por parâmetro 
	foi referenciado por outras notas.
	@author Leandro Fini
	@since 11/2025
	@return lRet, lógico, .T. -> Existe referenciação.
	@version 1.0
/*/
Function hasRefDKN(cDocRef, cSerieRef, cFornRef, cLojaRef, cTpMov, cOrigem, lHelp)

	Local lRet     As Logical
	Local oObjQry  As Object
	Local cQry     As Character 
	Local cAlias   As Character
	Local cFilDKN  As Character
	Local aDocRef  As Array

	Default cDocRef    := ""
	Default cSerieRef  := ""
	Default cFornRef   := ""
	Default cLojaRef   := ""
	Default cTpMov     := ""
	Default cOrigem    := ""
	Default lHelp 	   := .F. // Exibe o help

	lRet     := .F.
	cQry     := ""
	aDocRef  := {}
	cAlias   := GetNextAlias()
	cFilDKN  := FwxFilial("DKN")	

	cQry = "SELECT DKN_DOC, DKN_SERIE "
	cQry += "   FROM " + RetSqlName("DKN") + " DKN "
	cQry += " WHERE DKN_FILIAL = ? "
	cQry += " AND DKN_DOCREF = ? "
	cQry += " AND DKN_SERREF = ? "
	cQry += " AND DKN_PARREF = ? "
	cQry += " AND DKN_LOJREF = ? "
	cQry += " AND DKN_TPMOV =  ? "
	cQry += " AND DKN_ORIGEM = ? "
	cQry += " AND D_E_L_E_T_ = ? "

	cQry := ChangeQuery(cQry)
	oObjQry := FWExecStatement():New(cQry)

	oObjQry:SetString(1,cFilDKN)
	oObjQry:SetString(2,cDocRef)
	oObjQry:SetString(3,cSerieRef)
	oObjQry:SetString(4,cFornRef) 
	oObjQry:SetString(5,cLojaRef) 
	oObjQry:SetString(6,cTpMov) 
	oObjQry:SetString(7,cOrigem) 
	oObjQry:SetString(8,Space(1)) 

	cAlias := oObjQry:OpenAlias()

	While !(cAlias)->(Eof())
		lRet := .T.	

		aAdd(aDocRef, Alltrim((cAlias)->DKN_DOC) + "/" + (cAlias)->DKN_SERIE)

		(cAlias)->(DbSkip())
	Enddo
	(cAlias)->(DbCloseArea())

	if lRet .and. lHelp .and. len(aDocRef) > 0
		Help(" ",1,'HASREFDKN',,"Este documento está referenciado a Nota(s) de Credito/Debito: " + ArrTokStr(aDocRef),1,0)
	endif

	freeObj(oObjQry)

return lRet



/*/{Protheus.doc} DKNJaGrv
	Valida os documentos referenciados foram gravados corretamente na DKN
	Caso seja uma nota de Credito/Debito por item, verifica se todos os itens foram gravados
	@author Thiago Rodrigues
	@since 10/2025
	@return lRet, lógico, se existir DKN
	@version 1.0
/*/
Function DKNJaGrv(cTipo,cTpCompl,cDoc, cSerieNF, cFornece,cLojaFor,aItensNF) 

	Local lRet     As Logical
	Local oObjQry  As Object
	Local cQry     As Character 
	Local cAlias   As Character
	Local Nx       As Numeric
	Local nPosItem As Character
	Local cFilDKN  As Character

	Default cTipo    := ""
	Default cTpCompl := ""
	Default cDoc     := ""
	Default cSerieNF := ""
	Default cFornece := ""
	Default cLojaFor := ""
	Default aItensNF := {}

	lRet     := .F.
	cQry     := ""
	cAlias   := GetNextAlias()
	Nx       := 0
	nPosItem := GdFieldPos("D1_ITEM")
	cFilDKN  := FwxFilial("DKN")

	If isItNCND(cTipo, cTpCompl) // Por item
		For Nx := 1 To Len(aItensNF)
	
			//Busca documentos de referencia
			cQry = " SELECT DKN.DKN_DOC "
			cQry += "   FROM " + RetSqlName("DKN") + " DKN "
			cQry += "  WHERE DKN.DKN_FILIAL = ? "
			cQry += "    AND DKN.DKN_DOC    = ? "
			cQry += "    AND DKN.DKN_SERIE  = ? "
			cQry += "    AND DKN.DKN_CLIFOR = ? "
			cQry += "    AND DKN.DKN_LOJA   = ? "
			cQry += "    AND DKN.DKN_ITEMNF  = ? "
			cQry += "    AND DKN.DKN_ORIGEM = ? "
			cQry += "    AND DKN.D_E_L_E_T_ = ? "

			cQry := ChangeQuery(cQry)
			oObjQry := FWExecStatement():New(cQry)

			oObjQry:SetString(1,cFilDKN)
			oObjQry:SetString(2,cDoc)
			oObjQry:SetString(3,cSerieNF)
			oObjQry:SetString(4,cFornece) 
			oObjQry:SetString(5,cLojaFor) 
			oObjQry:SetString(6,aItensNF[Nx][nPosItem]) 
			oObjQry:SetString(7,"MATA103") 
			oObjQry:SetString(8,Space(1)) 

			cAlias := oObjQry:OpenAlias()
			
			If !(cAlias)->(Eof())
				lRet := .T.	
			Else 
				lRet := .F.
				Exit
			Endif
		Next Nx
		(cAlias)->(DbCloseArea())
		

	Else // Por nota

		//Busca documentos de referencia
		cQry = " SELECT DKN.DKN_DOC "
		cQry += "   FROM " + RetSqlName("DKN") + " DKN "
		cQry += "  WHERE DKN.DKN_FILIAL = ? "
		cQry += "    AND DKN.DKN_DOC    = ? "
		cQry += "    AND DKN.DKN_SERIE  = ? "
		cQry += "    AND DKN.DKN_CLIFOR = ? "
		cQry += "    AND DKN.DKN_LOJA   = ? "
		cQry += "    AND DKN.DKN_ORIGEM = ? "
		cQry += "    AND DKN.D_E_L_E_T_ = ? "

		cQry := ChangeQuery(cQry)
		oObjQry := FWExecStatement():New(cQry)

		oObjQry:SetString(1,cFilDKN)
		oObjQry:SetString(2,cDoc)
		oObjQry:SetString(3,cSerieNF)
		oObjQry:SetString(4,cFornece) 
		oObjQry:SetString(5,cLojaFor) 
		oObjQry:SetString(6,"MATA103") 
		oObjQry:SetString(7,Space(1)) 

		cAlias := oObjQry:OpenAlias()

		If !(cAlias)->(Eof())
			lRet := .T.	
		Endif
		(cAlias)->(DbCloseArea())

	EndIf

	freeObj(oObjQry)

Return lRet

/*/{Protheus.doc} A103VldRef
	Realiza validação do valor total da nota x valor total somado das referenciadas.
	O valor total da nota não pode exceder a soma das referenciadas.
	@author Leandro Fini
	@since 12/2025
	@return lRet, lógico
		.T. -> Valor está abaixo da soma das referenciadas
		.F. -> Valor excede total da soma das referenciadas
/*/
Function A103VldRef(l103Auto, cTipoNF, cCompl, cForm, oJDocRef)

	Local lRet 	   := .T. as boolean
	Local lRefItem := .F. as boolean //Referencia por item ou NF
	Local nX 	   := 1 as numeric
	Local nK 	   := 1 as numeric
	Local aItens   := {} as array
	Local aDocVinc := {} as array
	Local cItem    := "" as character
	Local cProd    := "" as character
	Local nPosIt   := 0  as numeric 
	Local nPosProd := 0  as numeric
	Local nPosQtd  := 0  as numeric
	Local nPosTot  := 0  as numeric
	Local nPos 	   := 0  as numeric
	Local nQtd     := 0  as numeric //Quantidade da NF de Cred/Debito
	Local nTot     := 0  as numeric //Valor total da NF de Cred/Debito
	Local nQtdRef  := 0  as numeric //Quantidade total dos documentos referenciados
	Local nTotRef  := 0  as numeric //Valor total somado dos documentos referenciados

	Default l103Auto := .F.
	Default cTipoNF  := ""
	Default cCompl   := ""
	Default cForm	 := ""
	Default oJDocRef := nil

	if !l103Auto .and. !empty(cTipoNF) .and. !empty(cCompl) .and. !empty(cForm) .and. valtype(oJDocRef) == "J"

		lRefItem := isItNCND(cTipoNF, cCompl, cForm)

		if !lRefItem .and. oJDocRef:hasproperty('documentos')
			nTotRef := 0
			aDocVinc := aClone(oJDocRef['documentos'])
			if len(aDocVinc) > 0
				for nK := 1 to len(aDocVinc)
					nTotRef := nTotRef + if(aDocVinc[nK]:hasproperty('valor'),aDocVinc[nK]['valor'],0)
				next nK
			endif

			if nTotRef > 0 .and. MaFisFound("NF") .and.  MaFisRet(,"NF_VALMERC") > nTotRef
				lRet := .F.
				Help(NIL, NIL, "A103TOTREF", NIL, STR0037 + Alltrim(TransForm(nTotRef,PesqPict("SF1","F1_VALBRUT"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {}) //"O valor da Nota de Credito/Debito não deve exceder o total somado dos documentos referenciados: "
			endif
		elseif lRefItem .and. oJDocRef:hasproperty('itens')

			if type("aCols") == "A" .and. len(aCols) > 0
				nPosIt 	 := GdFieldPos("D1_ITEM")
				nPosProd := GdFieldPos("D1_COD")
				nPosQtd  := GdFieldPos("D1_QUANT")
				nPosTot  := GdFieldPos("D1_TOTAL")
			endif

			aItens := aClone(oJDocRef['itens'])
			if len(aItens) > 0 .and. nPosIt > 0 .and. nPosProd > 0 .and. nPosQtd > 0 .and. nPosTot > 0
				for nX := 1 to len(aItens)
					nTotRef := 0
					nTot 	:= 0
					nQtd 	:= 0
					nQtdRef := 0
					cItem := aItens[nX]['item']
					cProd := aItens[nX]['produto']
					nPos := aScan(aCols,{|x| x[nPosIt] == cItem .and. x[nPosProd] == cProd })
					if aItens[nX]:hasproperty('documentos')
						aDocVinc := aClone(aItens[nX]['documentos'])
					endif
					if nPos > 0 .and. len(aDocVinc) > 0
						nQtd := aCols[nPos][nPosQtd]
						nTot := aCols[nPos][nPosTot]
						for nK := 1 to len(aDocVinc)
							nTotRef := nTotRef + if(aDocVinc[nK]:hasproperty('valortotal'),aDocVinc[nK]['valortotal'],0)
							nQtdRef	:= nQtdRef + if(aDocVinc[nK]:hasproperty('quantidade'),aDocVinc[nK]['quantidade'],0)
						next nK
					endif

					if nTotRef > 0 .and. nQtdRef > 0 .and. nQtd > 0 .and. nTot > 0
						if nTot > nTotRef 
							lRet := .F.
							Help(NIL, NIL, "A103TOTREF", NIL, STR0032 + cItem +"/"+Alltrim(cProd) + STR0033 + Alltrim(TransForm(nTotRef,PesqPict("SF1","F1_VALBRUT"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"O valor total do item: "##" excede a soma do valor total dos documentos referenciados: "
							exit
						elseif nQtd > nQtdRef 
							lRet := .F.
							Help(NIL, NIL, "A103QTDREF", NIL, STR0034 + cItem +"/"+Alltrim(cProd) + STR0035 + Alltrim(TransForm(nQtdRef,PesqPict("SD1","D1_QUANT"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"A quantidade do item: "##" excede a soma das quantidades dos documentos referenciados: "
							exit
						endif 
					endif
				next nX
			endif
		endif

		FwFreeArray(aItens)
		FwFreeArray(aDocVinc)
	endif


Return lRet

/*/{Protheus.doc} A103VldPaRef
	Realiza validação do valor total da nota x valor total dos PAs referenciados
	O valor total da nota não pode exceder a soma dos PAs referenciados
	Somente para Notas de Débito - Pagamento atencipado.
	@author Leandro Fini
	@since 12/2025
	@return lRet, lógico
		.T. -> Valor está abaixo da soma dos PAs referenciados
		.F. -> Valor excede total da soma dos PAs referenciados
/*/
Function A103VldPaRef(l103Auto, cTipo, cTpCompl, oPAVinc)

	Local lRet 	      := .T. as boolean 
	Local nX 	      := 1 as numeric
	Local jDados   	  := JsonObject():New() as Json
	Local aAreaSE2    := SE2->(GetArea())
	Local nTotPa	  := 0 as numeric
	Local cChvSE2	  := "" as character

	Default l103Auto := .F.
	Default cTipo    := ""
	Default cTpCompl := ""
	Default oPAVinc  := nil

	if type("oPAVinc") == "O"
		jDados	:= oPAVinc:getResult()
	endif

	if !l103Auto .and. valtype(jDados) == "J" .and. jDados:hasProperty("F7Q_IDDOC") .and. len(jDados["F7Q_IDDOC"]) > 0

		DbSelectArea("SE2")
		SE2->(DbSetOrder(1)) //-- E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
		for nX := 1 to len(jDados["F7Q_IDDOC"])

			if !empty(jDados["F7Q_IDDOC"][nX])

				cChvSE2 := FinFK7Key( '', jDados["F7Q_IDDOC"][nX])

				if SE2->(DbSeek(cChvSE2))
					nTotPa := nTotPa + SE2->E2_VALOR
				endif
			endif
		next nX

		if nTotPa > 0 .and. MaFisFound("NF") .and.  MaFisRet(,"NF_VALMERC") > nTotPa
			lRet := .F.
			Help(NIL, NIL, "A103PAREF", NIL, STR0036 + Alltrim(TransForm(nTotPa,PesqPict("SE2","E2_VALOR"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {}) //"O valor da Nota de Debito não deve exceder o total somado dos pagamentos antecipados referenciados: "
		endif

		freeobj(jDados)
		RestArea(aAreaSE2)
	endif

Return lRet
