#INCLUDE "MATA103COM.CH"
#include "protheus.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CNFENGELE "NF3E"
#DEFINE CNOTACRED "5" //Nota de Crédito
#DEFINE CNOTADEBI "6" //Nota de Débito

Static lDHQInDic  := (FwAliasInDic("DHQ") .and. SF4->(FieldPos("F4_EFUTUR") > 0))
Static nPrecisao  := TamSX3("D1_VUNIT")[2]
Static lLGPD  	  := FindFunction("SuprLGPD") .And. SuprLGPD()
Static __lEspFoco := Nil	// Cache de MV_ESPFOCO - ver A103EspFoc()



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

	If isItNCND(cTipo, cTpCompl) .Or. cTipo == "D" // Por item (a devolucao e sempre por item)
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
	Local nPosVDesc := 0  as numeric //Posicao de D1_VALDESC no aCols
	Local nPos 	   := 0  as numeric
	Local nQtd     := 0  as numeric //Quantidade da NF de Cred/Debito
	Local nTot     := 0  as numeric //Valor total da NF de Cred/Debito
	Local nQtdRef  := 0  as numeric //Quantidade total dos documentos referenciados
	Local nTotRef  := 0  as numeric //Valor total somado dos documentos referenciados
	Local nVlrLiqRef := 0 as numeric //Valor liquido da NF (NF_VALMERC - NF_DESCONTO) para comparacao com nTotRef
	Local aRetFun	:= {} 	as array
	//-- Recusa Parcial (NC+6): controle da validacao de recusa total disfarcada de parcial
	Local nTotNC   := 0  as numeric //Soma do valor total dos itens da Nota de Credito
	Local nTotDisp := 0  as numeric //Total ainda passivel de recusa na nota de saida referenciada
	Local cDocRP   := "" as character //Documento da nota de saida referenciada
	Local cSerRP   := "" as character //Serie da nota de saida referenciada
	Local cCliRP   := "" as character //Cliente da nota de saida referenciada
	Local cLojRP   := "" as character //Loja da nota de saida referenciada
	//-- Recusa Parcial (NC+6): apoio a deteccao de item alterado em relacao a origem.
	Local lRcParIt := .F. as logical //.T. quando a nota e Nota de Credito + 6-Recusa Parcial
	Local lItAlt   := .F. as logical //.T. quando ao menos um item teve quantidade ou valor alterado
	Local lVldTot  := .F. as logical //Habilita a validacao de teto do valor do item
	Local lVldQtd  := .F. as logical //Habilita a validacao de teto da quantidade do item
	Local nDecQtd  := TamSX3("D1_QUANT")[2] as numeric //Decimais de D1_QUANT usadas na comparacao
	Local nDecTot  := TamSX3("D1_TOTAL")[2] as numeric //Decimais de D1_TOTAL usadas na comparacao
	Local lCRPARFN := .F.

	Default l103Auto := .F.
	Default cTipoNF  := ""
	Default cCompl   := ""
	Default cForm	 := ""
	Default oJDocRef := nil

	if !empty(cTipoNF) .and. !empty(cCompl) .and. !empty(cForm) .and. valtype(oJDocRef) == "J"

		//-- Devolucao (F1_TIPO="D"): o vinculo e SEMPRE por item (uma nota de origem por
		//-- item), entao entra no mesmo ramo "lRefItem" sem precisar de A103DevRef
		//-- por TES aqui - a elegibilidade por item ja foi decidida em A103DevVld.
		lRefItem := isItNCND(cTipoNF, cCompl, cForm) .Or. cTipoNF == "D"

		//-- Recusa Parcial (NC + complemento 6): avaliado uma unica vez, fora dos lacos,
		//-- para nao repetir a chamada a cada item processado.
		lRcParIt := A103RcPar(cTipoNF, cCompl)
		if ( lRcParIt .and. cFormul == "N" )
			lCRPARFN := .T.
		endif

		if !lRefItem .and. oJDocRef:hasproperty('documentos')
			nTotRef := 0
			aDocVinc := aClone(oJDocRef['documentos'])
			if (l103Auto)
				nTotRef := A103VlNFRef("1", aDocVinc)[1]
			else
				if len(aDocVinc) > 0
					for nK := 1 to len(aDocVinc)
						nTotRef := nTotRef + if(aDocVinc[nK]:hasproperty('valor'),aDocVinc[nK]['valor'],0)
					next nK
				endif
			endif
			// Utiliza o valor liquido da NF (descontando NF_DESCONTO)
			if MaFisFound("NF")
				nVlrLiqRef := Max(0, MaFisRet(,"NF_VALMERC") - MaFisRet(,"NF_DESCONTO"))

				if nTotRef > 0 .and. nVlrLiqRef > nTotRef
					lRet := .F.
					Help(NIL, NIL, "A103TOTREF", NIL, STR0037 + Alltrim(TransForm(nTotRef,PesqPict("SF1","F1_VALBRUT"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {}) //"O valor da Nota de Credito/Debito não deve exceder o total somado dos documentos referenciados: "
				elseif (cTipoNF == "5" .and. cCompl == "4" .and. nVlrLiqRef > 0 .and. nVlrLiqRef == nTotRef )
					lRet := .F.
					Help(NIL, NIL, "A103TOTREF", NIL, STR0052 + Alltrim(TransForm(nTotRef,PesqPict("SF1","F1_VALBRUT"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {})//O valor total dos itens deve ser inferior ao valor correspondente nos documentos referenciados."
				endif
			endif
		elseif lRefItem .and. oJDocRef:hasproperty('itens')

			if type("aCols") == "A" .and. len(aCols) > 0
				nPosIt 	    := GdFieldPos("D1_ITEM")
				nPosProd    := GdFieldPos("D1_COD")
				nPosQtd     := GdFieldPos("D1_QUANT")
				nPosTot     := GdFieldPos("D1_TOTAL")
				nPosVDesc   := GdFieldPos("D1_VALDESC")
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
						//-- D1_TOTAL vem bruto na carga automatica (M103FilDv); abate D1_VALDESC
						//-- para comparar liquido com liquido contra nTotRef. Frete/Seguro/Despesa
						//-- nao entram: nao compoem D1_TOTAL e podem acrescer sem equivalente na origem.
						nTot := aCols[nPos][nPosTot] - if(nPosVDesc > 0, aCols[nPos][nPosVDesc], 0)
						//-- nTotNC (usado no bloco de Recusa Parcial abaixo) precisa da mesma base
						//-- liquida de nTotDisp/A103TotRP, senao o empate nunca seria detectado.
						nTotNC := nTotNC + nTot
						if !l103Auto
							for nK := 1 to len(aDocVinc)
								nTotRef := nTotRef + if(aDocVinc[nK]:hasproperty('valortotal'),aDocVinc[nK]['valortotal'],0)
								nQtdRef	:= nQtdRef + if(aDocVinc[nK]:hasproperty('quantidade'),aDocVinc[nK]['quantidade'],0)
							next nK
						else
							aRetFun := A103VlNFRef("2", aDocVinc, cTipoNF, cCompl, cForm, cProd)
							nTotRef := aRetFun[1]
							nQtdRef := aRetFun[2]
						endif
					endif

					//-- Item do JSON sem linha correspondente no aCols: o produto foi trocado ou o
					//-- item foi renumerado depois do vinculo, e a linha do grid ficou apontando para
					//-- um documento referenciado do qual ela nao faz parte.
					If nPos == 0
						lRet := .F.
						Help(NIL, NIL, "A103ITVINC", NIL, STR0060, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0061}) //"O produto do item nao corresponde a nenhum documento referenciado vinculado a esta Nota de Credito/Debito." - "Utilize novamente a opcao 'Vinc. Doc. Referenciado' para revincular os itens ao documento de origem."
						lItAlt := .T.
						Exit
					//-- Recusa Parcial (NC+6): marca se ESTE item difere do documento de origem.
					//-- Serve para a validacao de falsa recusa total aplicada depois do laco: se o usuario
					//-- alterou quantidade OU valor de qualquer item, a recusa é parcial de fato.
					ElseIf Round(nQtd, nDecQtd) <> Round(nQtdRef, nDecQtd) .Or. Round(nTot, nDecTot) <> Round(nTotRef, nDecTot)
						lItAlt := .T.
					EndIf

				// nTot ja foi ajustado acima (D1_TOTAL - D1_VALDESC) para comparar liquido com liquido.
				//-- Teto por item: valor e quantidade da NC nao podem exceder o documento de origem.
				// Na Recusa Parcial (NC+6) valor e quantidade passam a ser avaliados de forma independente. 
				//--Nos demais tipos/complementos o guard combinado é mantido.
				If lRcParIt
					lVldTot := ( nTotRef > 0 .And. nTot > 0 )
					lVldQtd := ( nQtdRef > 0 .And. nQtd > 0 )
				Else
					lVldTot := ( nTotRef > 0 .And. nQtdRef > 0 .And. nQtd > 0 .And. nTot > 0 )
					lVldQtd := lVldTot
				EndIf

				if lVldTot .or. lVldQtd
						if lVldTot .and. nTot > nTotRef 
							lRet := .F.
							Help(NIL, NIL, "A103TOTREF", NIL, STR0032 + cItem +"/"+Alltrim(cProd) + STR0033 + Alltrim(TransForm(nTotRef,PesqPict("SF1","F1_VALBRUT"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"O valor total do item: "##" excede a soma do valor total dos documentos referenciados: "
							exit
						elseif lVldQtd .and. nQtd > nQtdRef 
							lRet := .F.
							Help(NIL, NIL, "A103QTDREF", NIL, STR0034 + cItem +"/"+Alltrim(cProd) + STR0035 + Alltrim(TransForm(nQtdRef,PesqPict("SD1","D1_QUANT"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"A quantidade do item: "##" excede a soma das quantidades dos documentos referenciados: "
							exit
						endif 
					endif
				next nX
			endif
		endif

		//-------------------------------------------------------------------------
		//-- Recusa Parcial (NC + complemento 6): impede recusa TOTAL disfarcada.
		//-- Se a soma do valor total dos itens da Nota de Credito empatar com o
		//-- total ainda passivel de recusa da nota de saida referenciada, o usuario
		//-- marcou todos os itens disponiveis e nao reduziu valor nem quantidade - ou seja, recusou tudo.
		//-------------------------------------------------------------------------
		//-- Condicao !lItAlt: o bloqueio vale APENAS quando nenhum item foi alterado. Trazer
		//-- todos os itens da nota sem mexer em quantidade nem valor significa recusar tudo,
		//-- e para isso existe o complemento 3-Recusa Total. Se o usuario alterou quantidade
		//-- ou valor de qualquer item, a recusa e parcial de fato e deve passar. Selecionar
		//-- apenas parte dos itens tambem passa, pois a soma nao empata com o total disponivel.
		if lRet .and. lRcParIt .and. !lItAlt .and. nTotNC > 0 .and. len(aItens) > 0

			//-- Na Recusa Parcial todos os itens apontam para a MESMA nota de saida,
			//-- por isso basta ler os dados da nota no primeiro item vinculado.
			if aItens[1]:hasproperty('documentos') .and. len(aItens[1]['documentos']) > 0
				cDocRP := aItens[1]['documentos'][1]['documento']
				cSerRP := aItens[1]['documentos'][1]['serie']
				cCliRP := aItens[1]['documentos'][1]['forclirf']
				cLojRP := aItens[1]['documentos'][1]['lojarf']
			endif

			nTotDisp := A103TotRP(cDocRP, cSerRP, cCliRP, cLojRP, lCRPARFN)

			if nTotDisp > 0 .and. nTotNC == nTotDisp
				lRet := .F.
				Help(NIL, NIL, "A103TOTREF", NIL, STR0052 + Alltrim(TransForm(nTotDisp,PesqPict("SF1","F1_VALBRUT"))), 1, 0, NIL, NIL, NIL, NIL, NIL, {})//"O valor total dos itens deve ser inferior ao valor correspondente nos documentos referenciados."
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


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A103VlNFRef
	Realiza validação do valor total da nota x valor total somado das referenciadas, onde valor total da nota 
	não pode exceder a soma das referenciadas.
	Validações exclusiva para o EXECAUTO, pois em tela, a função A103VldRef já faz as etapas necessárias.
	@author renan.martins
	@since 01/2026
	@param cTipo		, string, Verifica se o vínculo é por NF ou Item da NF: "1" - NF / "2" - Item
	@param aDados		, array , Array com os dados das notas vinculadas
	@param cTpNota		, string, Tipo da NF (F1_TIPO)
	@param cComplNota	, string, Complemento da Nota (F1_TPCOMPL)
	@param cNotaProp	, string, Formulário P´roprio? (F1_FORMUL)
	@param cProd		, string, Código do produto (D1_COD)
	@return array, array, 
		1ª posição -> Valor total das notas vinculadas
		2ª posição -> Quantidade total dos itens nas notas vinculadas
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
function A103VlNFRef(cTipo, aDados, cTpNota, cComplNota, cNotaProp, cProd)
	Local aAliasTmp		:= {}	
	Local aAreas		:= { SF1->(GetArea()), SD1->(GetArea()), SD2->(GetArea()) }	
	Local aRetDad		:= {}	
	Local cAjsForn		:= PadR(cA100For, TamSx3("F1_FORNECE")[1]) + PadR(cLoja, TamSx3("F1_LOJA")[1])	
	Local cFilSF1		:= FwxFilial("SF1")	
	Local cItem			:= 0
	Local cNumNota		:= ""	
	Local cNumSerie 	:= ""		
	Local lBusSD2		:= .F.	
	Local nFor			:= 1
	Local nQuant		:= 0	
	Local nSizeAda		:= 0	
	Local nValor		:= 0	
	Default cTipo		:= "1"
	Default aDados		:= {}
	Default cTpNota		:= ""
	Default cComplNota	:= ""
	Default cNotaProp	:= ""
	Default cProd		:= ""

	nSizeAda := len(aDados)

	if cTipo == "1"
		for nFor := 1 to nSizeAda
			if ( aDados[nFor]:hasproperty('documento') )
				cNumNota := aDados[nFor]['documento']
			endif
			if ( aDados[nFor]:hasproperty('serie') )
				cNumSerie := aDados[nFor]['serie']
			endif
		
			nValor += GetAdvFVal("SF1", "F1_VALMERC", cFilSF1 + cNumNota + cNumSerie + cAjsForn, 1)
		next

	else
		lBusSD2 := A103RtCliRT(cTpNota, cComplNota, cNotaProp)
		if (!lBusSD2)
			//Alias - Campos de retorno - Filial tabela - Índice da pesquisa (1-D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM)
			aAliasTmp := {"SD1", {"D1_TOTAL", "D1_QUANT"}, FwxFilial("SD1"), 1}
		else
			//Alias - Campos de retorno - Filial tabela - indice da pesquisa (3-D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM)
			//D2_QTDEDEV considerado: quantidade disponivel = D2_QUANT - D2_QTDEDEV
			//D2_VALDEV  considerado: valor disponivel     = D2_TOTAL - D2_VALDEV
			aAliasTmp := {"SD2", {"D2_TOTAL", "D2_QUANT", "D2_QTDEDEV", "D2_VALDEV"}, FwxFilial("SD2"), 3}
		endif
		
		for nFor := 1 to nSizeAda
			if ( aDados[nFor]:hasproperty('documento') )
				cNumNota := aDados[nFor]['documento']
			endif
			if ( aDados[nFor]:hasproperty('serie') )
				cNumSerie := aDados[nFor]['serie']
			endif
			if ( aDados[nFor]:hasproperty('item') )
				cItem := aDados[nFor]['item']
			endif

			aRetDad := GetAdvFVal(aAliasTmp[1], aAliasTmp[2], aAliasTmp[3] + cNumNota + cNumSerie + cAjsForn + cProd + cItem, aAliasTmp[4])
			if lBusSD2
				// Desconta D2_VALDEV  para obter o valor total disponivel real
				nValor += max(0, aRetDad[1] - aRetDad[4])
				// Desconta D2_QTDEDEV para obter a quantidade disponivel real
				nQuant += max(0, aRetDad[2] - aRetDad[3])
			else
				nValor += aRetDad[1]
				nQuant += aRetDad[2]
			endif
		next
	endif

	for nFor := 1 to len(aAreas)
		FwRestArea(aAreas[nFor])
	next

	FwFreeArray(aAreas)
	FwFreeArray(aRetDad)
	FwFreeArray(aAliasTmp)
return {nValor, nQuant}



//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A103VlDtPr
	Valida se Data Prevista de Entrega é menor que a data de emissão
	@author Tsilva
	@since 03/2026
	@param dDataPrev    , data,  Data Prevista de Entrega
	@param dEmissao		, data , Data de emissão
	@return lDataValida , Logico,  .T. caso a data seja valida ou .F. caso invalida
/*/
//-----------------------------------------------------------------------------------------------------------------------------------

Function A103VlDtPr(dDataPrev, dEmissao)
	Local lDataValida  As logical

	Default dDataPrev := Stod("")
	Default dEmissao  := Stod("")

	lDataValida := .T.
	
	If !Empty(dDataPrev) .And. !Empty(dEmissao) .And. dDataPrev < dEmissao
		Help(NIL, NIL, "A103DTPREV", NIL, STR0038, 1, 0, NIL, NIL, NIL, NIL, NIL, {}) //"A data de previsão de entrega não pode ser anterior a data de emissão."
		lDataValida := .F.
	endif

Return lDataValida


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CNF3DIALOG
	Abre a tela para lançamentos de dados adicionais da Nota Fiscal de Energia - NF3E.
	@author renan.martins
	@since 05/2026
	@param lIncNF3	, lógico, Inclusão ou outra operação.
	@return Nil		, Nil	, Nil
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
Function CNF3DIALOG(lIncNF3 as logical)
	Local lIncBkp  	:= INCLUI
	Local lExsDKO	:= FWAliasInDic("DKO") .and. ChkFile("DKO")
	Local aButtons 	:= {}	as array

	Default lIncNF3 := .T.

	aButtons :=   { {.F., Nil},;            //- Copiar
                    {.F., Nil},;            //- Recortar
                    {.F., Nil},;            //- Colar
                    {.F., Nil},;            //- Calculadora
                    {.F., Nil},;            //- Spool
                    {.F., Nil},;            //- Imprimir
                    {lIncNF3, STR0039},;    //- "Confirmar"
                    {.T., STR0040},;        //- "Cancelar"
                    {.F., Nil},;            //- WalkThrough
                    {.F., Nil},;            //- Ambiente
                    {.F., Nil},;            //- Mashup
                    {.F., Nil},;            //- Help
                    {.F., Nil},;            //- Formulário HTML
                    {.F., Nil},;            // - ECM
                    {.F., nil} }            // - Desabilitar o botão Salvar e Criar Novo

	if ( lExsDKO )
 		lExsDKO := DKO->(FieldPos("DKO_QUANT")) > 0 .and. DKO->(FieldPos("DKO_VUNIT")) > 0 .and. ;
                   DKO->(FieldPos("DKO_TOTAL")) > 0 .and. DKO->(FieldPos("DKO_UM")) > 0 .and. FindFunction("COMNF3ADIC")
	endif

	if ( lExsDKO .and. cPaisLoc == "BRA" .and. !empty(cA100For) .and. !empty(cLoja) .and. !empty(cEspecie) .and. (!empty(cEspecie) .and. alltrim(cEspecie) == CNFENGELE))
		NF3IniLoad(lIncNF3)
		FWExecView(STR0042, "COMNF3ADIC", MODEL_OPERATION_INSERT, , {||.T.}, , 10, aButtons, , , , ) //"Dados adicionais da Nota Fiscal de Energia Elétrica - NF3E"
	else
		Help(" ", 1, 'A103NF3E', , STR0041, 1, 0) //"A opção está disponível apenas para Notas de Energia Elétrica, do tipo NF3E."
	endif

	if !lIncBkp //-- Restauro o valor da variável global INCLUI alterada pelo execview.
		INCLUI := .F.
	endif
	
	if ( lIncNF3 .and. oJsDKOInf != Nil)
		//Dispara refresh do folder atual e do folder de totais para exibir o valor DKO corretamente
		if (Type("bRefresh") == "B")
			Eval(bRefresh)    // folder atual 
			Eval(bRefresh, 1) // folder de totais (TOTPED)
		endif
		if (Type("bGDRefresh") == "B")
			Eval(bGDRefresh)
		endif
	endif

	FwFreeArray(aButtons)
Return

/*/{Protheus.doc} M103FilD1
Monta os itens do aCols a partir da tabela SD1 (itens de documentos de entrada),
com comportamento equivalente a M103FilDv, porem baseado na SD1 em vez da SD2.

Utilizada para reprocessar ou recarregar os itens de um documento de entrada
ja existente, respeitando as regras de TES, poder de terceiros e estrutura
de campos da tabela SD1.

Apos executar a query na SD1, exibe uma tela de selecao via FWMarkBrowse
para que o usuario escolha quais itens deseja importar. Apenas os itens
marcados pelo usuario sao carregados no aCols via MPutD1Acol.

@type  Function
@author vinicius.snascimento
@since 13/07/2026

@param aLinha,    Array,     Array que sera populado com os campos do item (passado por referencia)
@param aItens,    Array,     Array que acumula todos os itens montados (passado por referencia)
@param cDocSD1,   Character, Numero do documento de entrada a filtrar
@param cSerieSD1, Character, Serie do documento de entrada a filtrar
@param cFornece,  Character, Codigo do fornecedor
@param cLoja,     Character, Loja do fornecedor
@param lHelp,     Logical,   Indica se deve exibir help quando nenhum item for encontrado (padrao .T.)

@return lReducao, Logical, .T. se ao menos um item valido foi montado, .F. caso contrario
/*/
Function M103FilD1(aLinha, aItens, cDocSD1, cSerieSD1, cFornece, cLoja, lHelp)

    Local aAreaAnt   	:= GetArea()
    Local aAreaSD1   	:= SD1->(GetArea())
    Local aAreaSF4   	:= SF4->(GetArea())
    Local cAliasSD1  	:= ""
    Local cAliasMrk  	:= ""
    Local cItemAtual 	:= ""
    Local cQuery     	:= ""
    Local cTESAtual  	:= ""
    Local lReducao	 	:= .T.
    Local lRedCode   	:= .F.
    Local lFirstLine 	:= .T.
    Local lTrbGen    	:= IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD1", "D1_IDTRIB"), .F.) // Verificacao tributos genericos
    Local nX         	:= 0
    Local oQrySD1    	:= Nil
    Local oTmpSel    	:= Nil
    Local oDlgMrk    	:= Nil
    Local oMrkBrowse 	:= Nil
    Local aItensVal  	:= {}
    Local aLinhaVal  	:= {}
    Local aStruTmp   	:= {}
    Local aColsMrk   	:= {}
    Local aSizeMrk   	:= {}
    Local lNCReForCl 	:= .F.
	Local lESTFilD1  	:= .F.
	Local oEstDocRef 	:= Nil
	Local aEntContb		:= {{"D1_EC05DB", .F.}, {"D1_EC05CR", .F.}, {"D1_EC06DB", .F.}, {"D1_EC06CR", .F.}, {"D1_EC07DB", .F.},;
							{"D1_EC07CR", .F.}, {"D1_EC08DB", .F.}, {"D1_EC08CR", .F.}, {"D1_EC09DB", .F.}, {"D1_EC09CR", .F.}}	as array
    Local cComplSQL		:= ""					as character
	Local nSizeEntCtb	:= Len(aEntContb)		as numeric
	Local nFor			:= 0					as numeric
	Local cValEntCtb	:= ""					as character
	Local cFilSD1		:= FwxFilial("SD1")		as character
	Local jExsSF4		:= JsonObject():New()	as json
	Local cFilSF4		:= FwxFilial("SF4")		as character
	Local lRetFun		:= .F.					as logical
	Local nTamQuant		:= TamSX3("D1_QUANT")[2]
    Local nTamVunit		:= TamSX3("D1_VUNIT")[2]
    Local nTamD1Tot		:= TamSX3("D1_TOTAL")[2]
	Private nRetMrk   	:= 0
    // cMarcaVal declarado como Private para que o FWMarkBrowse possa referencia-lo
    // internamente caso necessario (padrao documentado em mnta877.prw / MsSelect)
    Private cMarcaVal 	:= ""
    // aMarca: array de controle interno do FWMarkBrowse (recnos marcados).
    // DEVE ser Private (nao Local) para ser visivel ao FWMarkBrowse e permitir
    // que M103MarkAll sincronize o estado de marcacao via oMrkBrowse:Mark().
    Private aMarca    	:= {}

    Default aLinha    	:= {}
    Default aItens    	:= {}
    Default cDocSD1   	:= ""
    Default cSerieSD1 	:= ""
    Default cFornece  	:= ""
    Default cLoja     	:= ""
    Default lHelp     	:= .T.

	If FindClass("ESTDOCREF")
		lESTFilD1  := .T.
		oEstDocRef := ESTDOCREF():New()
	EndIf

	lNCReForCl := (cTipo == "5" .and. cTpCompl == "4" .and. cFormul == "S") // Nota de Credito Tipo de Complemento 4-Reducao de Valores - Vinculo com cliente (Quando verdadeiro)

    // Inicializa o engine fiscal antes de processar os itens,
    // equivalente ao que M103FilDv faz quando lNCCliNF = .T.
    // Sem isso, MaFisIniLoad() falharia ao tentar acessar aNfCab que seria Nil.
    If !MaFisFound("NF")
        MaFisIni(cFornece, cLoja, IIf(lNCReForCl, "C", "F"), ;
                 cTipo, Nil, MaFisRelImp("MT100", {"SF1", "SD1"}),, , NIL, NIL, NIL,, ;
                 ,,,,,,,,,,,,,dDEmissao,,,,,,,,lTrbGen)
    EndIf

    // Identifica posicoes das entidades contabeis adicionais na SD1, caso existam
	for nFor := 1 to nSizeEntCtb
		if ( SD1->(FieldPos(aEntContb[nFor, 1])) > 0 )
			aEntContb[nFor, 2] := .T.
			cComplSQL += "SD1." + aEntContb[nFor, 1] + ", "
		endif
	next nFor

    // Monta query com Bind Parameters para buscar os itens do documento de entrada
    cAliasSD1 := GetNextAlias()

    cQuery := " SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA,"
    cQuery += "        SD1.D1_COD, SD1.D1_ITEM, SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL,"
    cQuery += "        SD1.D1_VALDESC, SD1.D1_IPI, SD1.D1_LOCAL, SD1.D1_TES, SD1.D1_CF,"
    cQuery += "        SD1.D1_UM, SD1.D1_NFORI, SD1.D1_SERIORI, SD1.D1_ITEMORI,"
    cQuery += "        SD1.D1_VALFRE, SD1.D1_SEGURO,"
    cQuery += "        SD1.D1_DESPESA, SD1.D1_ICMSRET, SD1.D1_CC, SD1.D1_CONTA,"
    cQuery += "        SD1.D1_ITEMCTA, SD1.D1_CLVL, "
	cQuery += cComplSQL
    cQuery += "        SD1.D1_EMISSAO, SD1.D1_DTDIGIT, "
    cQuery += "        SD1.R_E_C_N_O_ SD1RECNO"
    cQuery += " FROM ? SD1 "
    cQuery += " WHERE SD1.D1_FILIAL   = ?"
    cQuery += "   AND SD1.D1_DOC      = ?"
    cQuery += "   AND SD1.D1_SERIE    = ?"
    cQuery += "   AND SD1.D1_FORNECE  = ?"
    cQuery += "   AND SD1.D1_LOJA     = ?"
    cQuery += "   AND SD1.D_E_L_E_T_  = ?"
    cQuery += " ORDER BY " + SqlOrder(SD1->(IndexKey()))

    cQuery := ChangeQuery(cQuery)

    oQrySD1 := FWExecStatement():New(cQuery)
    oQrySD1:SetUnsafe(1, RetSqlName("SD1"))
    oQrySD1:SetString(2, cFilSD1)
    oQrySD1:SetString(3, cDocSD1)
    oQrySD1:SetString(4, cSerieSD1)
    oQrySD1:SetString(5, cFornece)
    oQrySD1:SetString(6, cLoja)
    oQrySD1:SetString(7, " ")

    cAliasSD1 := oQrySD1:OpenAlias(cAliasSD1)

    TcSetField(cAliasSD1, "D1_QUANT"  , "N", TamSX3("D1_QUANT"  )[1], TamSX3("D1_QUANT"  )[2])
    TcSetField(cAliasSD1, "D1_VUNIT"  , "N", TamSX3("D1_VUNIT"  )[1], TamSX3("D1_VUNIT"  )[2])
    TcSetField(cAliasSD1, "D1_TOTAL"  , "N", TamSX3("D1_TOTAL"  )[1], TamSX3("D1_TOTAL"  )[2])
    TcSetField(cAliasSD1, "D1_VALDESC", "N", TamSX3("D1_VALDESC")[1], TamSX3("D1_VALDESC")[2])
    TcSetField(cAliasSD1, "D1_IPI"    , "N", TamSX3("D1_IPI"    )[1], TamSX3("D1_IPI"    )[2])
    TcSetField(cAliasSD1, "D1_VALFRE" , "N", TamSX3("D1_VALFRE" )[1], TamSX3("D1_VALFRE" )[2])
    TcSetField(cAliasSD1, "D1_SEGURO" , "N", TamSX3("D1_SEGURO" )[1], TamSX3("D1_SEGURO" )[2])
    TcSetField(cAliasSD1, "D1_DESPESA", "N", TamSX3("D1_DESPESA")[1], TamSX3("D1_DESPESA")[2])
    TcSetField(cAliasSD1, "D1_ICMSRET", "N", TamSX3("D1_ICMSRET")[1], TamSX3("D1_ICMSRET")[2])

    // Verifica se a query retornou registros
    If (cAliasSD1)->(Eof())
        If lHelp
            Help(" ", 1, "NCRDCNOREGS")
        EndIf
        lReducao := .F.
    EndIf

    // -------------------------------------------------------------------
    // ETAPA 1: Percorre todos os registros validos da query e acumula
    //          o aLinha de cada um em aItensVal (nao carrega aCols ainda)
    // -------------------------------------------------------------------
    DbSelectArea("SF4")
    SF4->(DbSetOrder(1))
	While (cAliasSD1)->(!Eof()) .And.;
          (cAliasSD1)->D1_FILIAL   == cFilSD1 		.And.;
          (cAliasSD1)->D1_DOC      == cDocSD1		.And.;
          (cAliasSD1)->D1_SERIE    == cSerieSD1		.And.;
          (cAliasSD1)->D1_FORNECE  == cFornece		.And.;
          (cAliasSD1)->D1_LOJA     == cLoja

        // Verifica se a TES do item e valida para inclusao (somente TES de entrada)
		if ( jExsSF4[(cAliasSD1)->D1_TES] != Nil )
			lRetFun := jExsSF4[(cAliasSD1)->D1_TES]
		else
			lRetFun := SF4->(MsSeek(cFilSF4 + (cAliasSD1)->D1_TES)) .And. (cAliasSD1)->D1_TES <= "500"
			jExsSF4[(cAliasSD1)->D1_TES] := lRetFun
		endif

        If ( lRetFun )

            lRedCode := .T.

            aLinha := {}

            // Campos principais do item de entrada
            AAdd(aLinha, {"D1_COD"    , (cAliasSD1)->D1_COD    , Nil})
            AAdd(aLinha, {"D1_QUANT"  , (cAliasSD1)->D1_QUANT  , Nil})
            AAdd(aLinha, {"D1_VUNIT"  , (cAliasSD1)->D1_VUNIT  , Nil})
            AAdd(aLinha, {"D1_TOTAL"  , (cAliasSD1)->D1_TOTAL  , Nil})
            AAdd(aLinha, {"D1_VALDESC", (cAliasSD1)->D1_VALDESC, Nil})
            AAdd(aLinha, {"D1_IPI"    , (cAliasSD1)->D1_IPI    , Nil})
            AAdd(aLinha, {"D1_LOCAL"  , (cAliasSD1)->D1_LOCAL  , Nil})
            AAdd(aLinha, {"D1_TES"    , (cAliasSD1)->D1_TES    , Nil})
            AAdd(aLinha, {"D1_CF"     , (cAliasSD1)->D1_CF     , Nil})
            AAdd(aLinha, {"D1_UM"     , (cAliasSD1)->D1_UM     , Nil})
            AAdd(aLinha, {"D1_ITEM"   , (cAliasSD1)->D1_ITEM   , Nil})
            AAdd(aLinha, {"D1_NFORI"  , cDocSD1                , Nil})
            AAdd(aLinha, {"D1_SERIORI", cSerieSD1              , Nil})
            AAdd(aLinha, {"D1_ITEMORI", (cAliasSD1)->D1_ITEM   , Nil})
            AAdd(aLinha, {"D1_VALFRE" , (cAliasSD1)->D1_VALFRE , Nil})
            AAdd(aLinha, {"D1_SEGURO" , (cAliasSD1)->D1_SEGURO , Nil})
            AAdd(aLinha, {"D1_DESPESA", (cAliasSD1)->D1_DESPESA, Nil})
            AAdd(aLinha, {"D1_ICMSRET", (cAliasSD1)->D1_ICMSRET, Nil})

            // Entidades contabeis
            If !(Empty((cAliasSD1)->D1_CC))
                AAdd(aLinha, {"D1_CC"     , (cAliasSD1)->D1_CC    , Nil})
            EndIf
            If !(Empty((cAliasSD1)->D1_CONTA))
                AAdd(aLinha, {"D1_CONTA"  , (cAliasSD1)->D1_CONTA  , Nil})
            EndIf
            If !(Empty((cAliasSD1)->D1_ITEMCTA))
                AAdd(aLinha, {"D1_ITEMCTA", (cAliasSD1)->D1_ITEMCTA, Nil})
            EndIf
            If !(Empty((cAliasSD1)->D1_CLVL))
                AAdd(aLinha, {"D1_CLVL"   , (cAliasSD1)->D1_CLVL   , Nil})
            EndIf

			// Entidades contabeis adicionais (EC05 a EC09)
			for nFor := 1 to nSizeEntCtb
				if ( aEntContb[nFor, 2] )
					cValEntCtb := (cAliasSD1)->&(aEntContb[nFor, 1])
					if ( !empty(cValEntCtb) )
						AAdd(aLinha, {aEntContb[nFor, 1], cValEntCtb, Nil})
					endif
				endif
			next nFor

			If lESTFilD1
				oEstDocRef:ESTFilD1(@aLinha,cDocSD1,cSerieSD1,cFornece,cLoja,cAliasSD1)
			EndIf

            // Recno para controle interno
            AAdd(aLinha, {"D1RECNO"   , (cAliasSD1)->SD1RECNO  , Nil})
            AAdd(aLinha, {"D1_TES_AUX", (cAliasSD1)->D1_TES    , Nil}) // TES preservada para MPutD1Acol

            AAdd(aItensVal, aLinha)

        EndIf // TES valida

        //DbSelectArea(cAliasSD1)
        (cAliasSD1)->(dbSkip())

    EndDo // While

    // Fecha area de trabalho da query e destroi o objeto
    (cAliasSD1)->(DbCloseArea())
	oEstDocRef := Nil
    oQrySD1:Destroy()
    oQrySD1 := Nil
	FwFreeArray(aEntContb)
	FwFreeObj(jExsSF4)
    DbSelectArea("SD1")

    // -------------------------------------------------------------------
    // ETAPA 2: Se ha itens validos, exibe FWMarkBrowse para selecao
    //          O usuario marca os itens que deseja importar
    // -------------------------------------------------------------------
    If lRedCode .And. Len(aItensVal) > 0

        // ---------------------------------------------------------------
        // Estrutura da tabela temporaria de selecao
        // Cada campo recebe os dados copiados do aLinha correspondente.
        // M103_IDX guarda o indice em aItensVal para recuperar o aLinha
        // original na Etapa 3, sem depender da area de trabalho do alias.
        // ---------------------------------------------------------------
        // M103_OK tamanho 2 — campo de controle de marcacao do FWMarkBrowse.
        // Tamanho 2 porque GetMark() pode retornar strings com 2 caracteres
        // (ex.: "0W"). Com C(1) o valor seria truncado e a comparacao quebraria.
        // O valor inicial e "  " (2 espacos) = desmarcado.
        AAdd(aStruTmp, {"M103_OK"   , "C", 2                         , 0})
        AAdd(aStruTmp, {"M103_ITEM" , "C", TamSX3("D1_ITEM"  )[1]   , 0})
        AAdd(aStruTmp, {"M103_COD"  , "C", TamSX3("D1_COD"   )[1]   , 0})
        AAdd(aStruTmp, {"M103_TES"  , "C", TamSX3("D1_TES"   )[1]   , 0})
        AAdd(aStruTmp, {"M103_CF"   , "C", TamSX3("D1_CF"    )[1]   , 0})
        AAdd(aStruTmp, {"M103_QTD"  , "N", TamSX3("D1_QUANT" )[1]   , TamSX3("D1_QUANT" )[2]})
        AAdd(aStruTmp, {"M103_VUNIT", "N", TamSX3("D1_VUNIT" )[1]   , TamSX3("D1_VUNIT" )[2]})
        AAdd(aStruTmp, {"M103_TOTAL", "N", TamSX3("D1_TOTAL" )[1]   , TamSX3("D1_TOTAL" )[2]})
        AAdd(aStruTmp, {"M103_UM"   , "C", TamSX3("D1_UM"    )[1]   , 0})
        AAdd(aStruTmp, {"M103_LOCAL", "C", TamSX3("D1_LOCAL" )[1]   , 0})
        AAdd(aStruTmp, {"M103_IDX"  , "N", 6                         , 0})

        cAliasMrk := GetNextAlias()
        oTmpSel   := FWTemporaryTable():New(cAliasMrk)
        oTmpSel:SetFields(aStruTmp)
        oTmpSel:AddIndex("1", {"M103_ITEM"})
        oTmpSel:Create()

        // Popula a tabela temporaria com os dados de cada item valido
        For nX := 1 To Len(aItensVal)
            aLinhaVal := aItensVal[nX]
            RecLock(cAliasMrk, .T.)
            (cAliasMrk)->M103_OK    := "  " // 2 espacos = desmarcado (campo C(2))
            (cAliasMrk)->M103_IDX   := nX
            (cAliasMrk)->M103_ITEM  := PadR(AllTrim(cValToChar(M103VlArray(aLinhaVal, "D1_ITEM"  ))), TamSX3("D1_ITEM"  )[1])
            (cAliasMrk)->M103_COD   := PadR(AllTrim(cValToChar(M103VlArray(aLinhaVal, "D1_COD"   ))), TamSX3("D1_COD"   )[1])
            (cAliasMrk)->M103_TES   := PadR(AllTrim(cValToChar(M103VlArray(aLinhaVal, "D1_TES"   ))), TamSX3("D1_TES"   )[1])
            (cAliasMrk)->M103_CF    := PadR(AllTrim(cValToChar(M103VlArray(aLinhaVal, "D1_CF"    ))), TamSX3("D1_CF"    )[1])
            // Arredonda pelas casas do dicionario da SD1 para a tela exibir exatamente o
            // valor do documento de origem. Vale apenas para a exibicao: o aLinha original,
            // consumido pelo MPutD1Acol, permanece inalterado.
            (cAliasMrk)->M103_QTD   := Round(M103VlArray(aLinhaVal, "D1_QUANT" ), nTamQuant)
            (cAliasMrk)->M103_VUNIT := Round(M103VlArray(aLinhaVal, "D1_VUNIT" ), nTamVunit)
            (cAliasMrk)->M103_TOTAL := Round(M103VlArray(aLinhaVal, "D1_TOTAL" ), nTamD1Tot)
            (cAliasMrk)->M103_UM    := PadR(AllTrim(cValToChar(M103VlArray(aLinhaVal, "D1_UM"    ))), TamSX3("D1_UM"    )[1])
            (cAliasMrk)->M103_LOCAL := PadR(AllTrim(cValToChar(M103VlArray(aLinhaVal, "D1_LOCAL" ))), TamSX3("D1_LOCAL" )[1])
            (cAliasMrk)->(MsUnLock())
        Next nX

        // cMarcaVal sera atualizado apos a ativacao do browse, pois GetMark()
        // pode retornar valor incorreto antes do contexto de browse estar ativo.

        // ---------------------------------------------------------------
        // Monta as colunas no formato NATIVO do FWMarkBrowse (array de arrays).
        // Formato: {cTitulo, bData, cTipo, cPicture, nAlign, nSize, nDecimal,
        //            lEdit, bValid, lImage, bDblClick, cEditVar, bHeaderClick,
        //            lDel, lDetail}
        // FWBrwColumn NAO deve ser usado aqui: pertence a FWBrowse (superclasse)
        // e nao ativa o mecanismo de marcacao da subclasse FWMarkBrowse.
        // Evidencia canonica: TAFR121.prw (TAF), GPEM944.PRW, gpem400.prx.
        // ---------------------------------------------------------------
        AAdd(aColsMrk, {"Item"     , {|| (cAliasMrk)->M103_ITEM } , "C", "@!", 1, TamSX3("D1_ITEM"  )[1], 0                        , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})
        AAdd(aColsMrk, {"Produto"  , {|| (cAliasMrk)->M103_COD  } , "C", "@!", 1, TamSX3("D1_COD"   )[1], 0                        , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})
        AAdd(aColsMrk, {"TES"      , {|| (cAliasMrk)->M103_TES  } , "C", "@!", 1, TamSX3("D1_TES"   )[1], 0                        , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})
        AAdd(aColsMrk, {"Cod.Fisc" , {|| (cAliasMrk)->M103_CF   } , "C", "@!", 1, TamSX3("D1_CF"    )[1], 0                        , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})
        // Colunas numericas usam a picture do proprio campo da SD1 (PesqPict). Sem ela o
        // FWMarkBrowse exibe o float cru, com varias decimais, enquanto a SD1 guarda o
        // valor com as casas definidas no dicionario (X3_DECIMAL).
        AAdd(aColsMrk, {"Qtde"     , {|| (cAliasMrk)->M103_QTD  } , "N", PesqPict("SD1","D1_QUANT"), 2, TamSX3("D1_QUANT" )[1], TamSX3("D1_QUANT" )[2]  , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})
        AAdd(aColsMrk, {"Vl.Unit." , {|| (cAliasMrk)->M103_VUNIT} , "N", PesqPict("SD1","D1_VUNIT"), 2, TamSX3("D1_VUNIT" )[1], TamSX3("D1_VUNIT" )[2]  , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})
        AAdd(aColsMrk, {"Total"    , {|| (cAliasMrk)->M103_TOTAL} , "N", PesqPict("SD1","D1_TOTAL"), 2, TamSX3("D1_TOTAL" )[1], TamSX3("D1_TOTAL" )[2]  , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})
        AAdd(aColsMrk, {"UM"       , {|| (cAliasMrk)->M103_UM   } , "C", "@!", 1, TamSX3("D1_UM"    )[1], 0                        , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})
        AAdd(aColsMrk, {"Armazem"  , {|| (cAliasMrk)->M103_LOCAL} , "C", "@!", 1, TamSX3("D1_LOCAL" )[1], 0                        , .F., {||.T.}, .F., {||.T.}, NIL, {||.T.}, .F., .F.})

        // ---------------------------------------------------------------
        // Private aRotina vazia: impede que o FWMarkBrowse herde o aRotina
        // da MATA103 e reconstrua a toolbar com opcoes de CRUD.
        // Padrao confirmado em PLSA586.PRW e FINA761.PRW do codebase.
        // ---------------------------------------------------------------
        Private aRotina := {}

        // Posiciona a tabela temporaria no primeiro registro antes de abrir o browse
        (cAliasMrk)->(DbSetOrder(1))
        (cAliasMrk)->(DbGoTop())

        // Monta e exibe o dialogo de selecao
        aSizeMrk := MsAdvSize()

        DEFINE MSDIALOG oDlgMrk TITLE STR0053 ; //"Selecao de Itens do Documento de Entrada"
            From aSizeMrk[7], 0 To aSizeMrk[6], aSizeMrk[5] ;
            OF oMainWnd PIXEL

        oDlgMrk:lMaximized := .T.

        // ---------------------------------------------------------------
        // Owner direto no MSDIALOG padrao canonico do FWMarkBrowse com
        // AddButton. O TPanel intermediario com ALLCLIENT e o padrao do
        // MsSelect/MarkBrow legado, nao do FWMarkBrowse moderno.
        // Evidencia: TAFR121.prw (TAF), GPEM944.PRW, GPEA005.PRW todos
        // passam o MSDIALOG ou o panel-pai diretamente como owner, sem
        // TPanel com ALLCLIENT intermediario.
        // ---------------------------------------------------------------
        oMrkBrowse := FWMarkBrowse():New()
        oMrkBrowse:SetOwner(oDlgMrk)
        oMrkBrowse:SetAlias(cAliasMrk)
        oMrkBrowse:SetDescription(STR0054) //"Selecione os itens que deseja importar para o documento de entrada"
        oMrkBrowse:SetFieldMark("M103_OK")
        oMrkBrowse:SetAllMark({|| M103MarkAll(oMrkBrowse, cAliasMrk, "M103_OK"), oMrkBrowse:Refresh(.T.)})
        oMrkBrowse:SetColumns(aColsMrk)
        oMrkBrowse:SetMenuDef("")
        oMrkBrowse:SetIgnoreARotina(.T.)
        oMrkBrowse:SetTemporary(.T.)
        oMrkBrowse:DisableReport()
        oMrkBrowse:DisableFilter()
        oMrkBrowse:AddButton(STR0055, {|| nRetMrk := 1, oDlgMrk:End()},, 1) //"Confirmar"
        oMrkBrowse:AddButton(STR0056, {|| M103MarkAll(oMrkBrowse, cAliasMrk, "M103_OK"), oMrkBrowse:Refresh(.T.)},, 1) //"Marcar/Desm. Todos" 
        oMrkBrowse:AddButton(STR0057, {|| nRetMrk := 0, oDlgMrk:End()},, 1) //"Cancelar" 

        oMrkBrowse:Activate()

        ACTIVATE MSDIALOG oDlgMrk CENTERED

        // Nao depende de GetMark() — o FWMarkBrowse pode gravar qualquer caractere
        // diferente de espaco no campo de marca. A comparacao e feita diretamente
        // verificando se o campo nao esta vazio/espaco (ver Etapa 3 e M103MarkAll).

        If ValType(oMrkBrowse) == "O"
            oMrkBrowse:DeActivate(.T.)
        EndIf

        // -------------------------------------------------------------------
        // ETAPA 3: Processa apenas os itens marcados
        // -------------------------------------------------------------------
        If nRetMrk == 1

            (cAliasMrk)->(DbSetOrder(1))
            (cAliasMrk)->(DbGoTop())

            While !(cAliasMrk)->(Eof())

                If !Empty(AllTrim((cAliasMrk)->M103_OK))
                    nX        := (cAliasMrk)->M103_IDX
                    aLinha    := aItensVal[nX]
                    cTESAtual := M103VlArray(aLinha, "D1_TES_AUX")
                    cItemAtual:= M103VlArray(aLinha, "D1_ITEM"   )

                    // Inicializa o aCols e MaFis apenas antes do primeiro item carregado
                    If lFirstLine
                        aCols      := {}
                        MaFisClear()
                        lFirstLine := .F.
                    EndIf

                    // Carrega o item no aCols via MPutD1Acol
                    FWMsgRun(, {|| MPutD1Acol(aLinha, cTESAtual)}, STR0058 , STR0059 + cItemAtual) //"Aguarde... Processando Item:" 

                    AAdd(aItens, aLinha)

                EndIf

                (cAliasMrk)->(dbSkip())

            EndDo

        Else
            // Cancelado: nao carrega nada no aCols
            lRedCode   := .F.
            lReducao   := .F.
        EndIf

        // Destroi tabela temporaria
        oTmpSel:Delete()
        oTmpSel := Nil

    EndIf // lRedCode

    // Se nenhum item foi processado, retorna falso
    If !lRedCode
        lReducao := .F.
    EndIf

    RestArea(aAreaSF4)
    RestArea(aAreaSD1)
    RestArea(aAreaAnt)

Return lReducao

/*/{Protheus.doc} M103VlArray
Retorna o valor de um campo pelo nome dentro de um array de linha no formato
{{cCampo, xValor, Nil}, ...}, equivalente ao aLinha usado em M103FilD1.

@type  Static Function
@author vinicius.snascimento
@since 13/07/2026

@param aLinha  , Array    , Array de linha no formato {{cCampo, xValor, Nil}}
@param cCampo  , Character, Nome do campo a localizar

@return xRet, Variant, Valor encontrado ou Nil quando o campo nao existe
/*/
Static Function M103VlArray(aLinha, cCampo)
    Local nPos := aScan(aLinha, {|x| AllTrim(x[1]) == AllTrim(cCampo)})
Return If(nPos > 0, aLinha[nPos][2], Nil)

/*/{Protheus.doc} M103MarkAll
Toggle de marcacao em lote para FWMarkBrowse.
Segue o padrao canonico de sincronizacao do array interno aMarca:
 - Se aMarca vazio (nenhum marcado) -> marca todos com oMrkBrw:Mark()
 - Se aMarca nao-vazio (algum marcado) -> desmarca todos

O array aMarca e a fonte de verdade interna do FWMarkBrowse para renderizar
o estado de marcacao. Gravar apenas no campo via RecLock nao e suficiente —
o browse nao monitora alteracoes diretas no campo. Por isso, este metodo
sincroniza aMarca junto com o campo fisico.

@type  Static Function
@author vinicius.snascimento
@since 16/07/2026

@param oMrkBrw  , Object   , Objeto FWMarkBrowse ativo — usado para obter Mark()
@param cAlias   , Character, Alias da tabela temporaria de selecao
@param cCampoMrk, Character, Campo de marcacao da tabela (ex.: "M103_OK")

@return Nil
/*/
Static Function M103MarkAll(oMrkBrw, cAlias, cCampoMrk)
    Local cMarcaBrw   := oMrkBrw:Mark()   // caractere de marcacao do FWMarkBrowse
    Local lInverte    := !Empty(aMarca)    // .T. = ha marcados -> desmarcar; .F. = nenhum marcado -> marcar
    Local nPos        := 0

    (cAlias)->(DbGoTop())

    While !(cAlias)->(Eof())

        If lInverte
            // Desmarcar todos: limpa o campo e remove o recno de aMarca
            RecLock(cAlias, .F.)
            (cAlias)->&cCampoMrk := Space(Len((cAlias)->&cCampoMrk))
            (cAlias)->(MsUnLock())
            nPos := aScan(aMarca, (cAlias)->(Recno()))
            If nPos > 0
                aDel(aMarca, nPos)
                aSize(aMarca, Len(aMarca) - 1)
            EndIf
        Else
            // Marcar todos: grava cMarcaBrw no campo e adiciona recno em aMarca
            RecLock(cAlias, .F.)
            (cAlias)->&cCampoMrk := Left(cMarcaBrw, Len((cAlias)->&cCampoMrk))
            (cAlias)->(MsUnLock())
            If aScan(aMarca, (cAlias)->(Recno())) == 0
                aAdd(aMarca, (cAlias)->(Recno()))
            EndIf
        EndIf

        (cAlias)->(DbSkip())
    EndDo

Return

/*/{Protheus.doc} MPutD1Acol
Realiza o tratamento dos dados do array de linha para o array de itens do
documento de entrada (aCols), baseado na tabela SD1.
Funcao analoga a MPutD2Acol (mata103x.prx), adaptada para o contexto da SD1:
enquanto MPutD2Acol e usada na devolucao (SD2->SD1) e mapeia D1_ITEM a partir
de D1_ITEMORI, esta funcao preserva D1_ITEM do proprio registro SD1, pois
trata reprocessamento de documentos de entrada ja existentes.

@type  Function
@author vinicius.snascimento
@since 13/07/2026

@param aLinha, Array,     Array com os dados da linha SD1 a ser inserida no aCols.
@param cTES,   Character, TES do item para identificar o tipo do documento e carregar referencias fiscais.

@return lRet, Logical, .T. se o item foi inserido com sucesso no aCols.
/*/
Function MPutD1Acol(aLinha, cTES)

    Local aArea       := GetArea()
    Local cCampo      := ""
    Local cValor      := ""
    Local nY          := 0
    Local nX          := 0
    Local nTamSD1     := TamSx3("D1_ITEM")[1]
    Local lMaFisFound := MaFisFound()
    Local nItem       := 0

    Default aLinha := {}
    Default cTES   := ""

    If ValType(aLinha) == "A" .And. Len(aLinha) > 0

        AAdd(aCols, Array(Len(aHeader)+1))

        nItem := Len(aCols)
        If lMaFisFound
            MaFisIniLoad(nItem)
        EndIf

        For nX := 1 To Len(aHeader)

            cCampo := AllTrim(aHeader[nX][2])
            cValor := ""

            If cCampo == "D1_ITEM"
                // D1_ITEM e mapeado do proprio campo D1_ITEM (reprocessamento SD1->SD1,
                // diferente da devolucao SD2->SD1 onde se usa D1_ITEMORI)
                For nY := 1 To Len(aLinha)
                    If AllTrim(aLinha[nY][1]) == "D1_ITEM"
                        cValor := StrZero(Val(aLinha[nY][2]), nTamSD1)
                        Exit
                    EndIf
                Next nY
            Else
                // Para os demais campos, busca diretamente no aLinha
                For nY := 1 To Len(aLinha)
                    If AllTrim(aLinha[nY][1]) == cCampo
                        cValor := aLinha[nY][2]
                        Exit
                    EndIf
                Next nY
            EndIf

            If IsHeadRec(cCampo)
                aCols[Len(aCols)][nX] := 0
            ElseIf IsHeadAlias(cCampo)
                aCols[Len(aCols)][nX] := "SD1"
            ElseIf !Empty(cValor)
                aCols[Len(aCols)][nX] := cValor
            Else
                aCols[Len(aCols)][nX] := CriaVar(cCampo, (aHeader[nX][10] <> "V"))
            EndIf

        Next nX

        // Flag da linha (nao deletado)
        aCols[Len(aCols)][Len(aHeader)+1] := .F.

        If lMaFisFound
            MaFisEndLoad(nItem)
        EndIf

    EndIf

    // Carrega referencias fiscais se MaFis esta ativo e aColsD1 disponivel
    If lMaFisFound .And. Type("aColsD1") == "A"
        MaColsToFis(aHeader, aCols, nItem, "MT100")
        If !Empty(cTES)
            MaFisLoad("IT_TES", "", nItem)
            MaFisAlt("IT_TES", cTES, nItem)
        EndIf
        aColsD1 := aCols
    EndIf

    RestArea(aArea)

Return .T.

/*/{Protheus.doc} A103DKNPC
Quando Nota Credito - Redução Valores, deve atualizar PC quando documento
referenciado possuir PC vinculado.

@type  Function
@author rodrigo.mpontes
@since 13/07/2026

@param nOpc, 	Numeric,	3-Estorno PC,5-Retorna Reducao ao PC
@param cNCFor,	Character,	Fornecedor
@param cNCLoj,	Character,	Loja

@return
/*/

Function A103DKNPC(nOpc,cNCFor,cNCLoj)

Local aArea	 	:= GetArea()
Local nX       	:= 0
Local nRecC7	:= 0
Local nQtdNC	:= 0
Local nPItem	:= GetPosSD1("D1_ITEM")
Local nPCod	 	:= GetPosSD1("D1_COD")
Local nPQtd	 	:= GetPosSD1("D1_QUANT")
Local nPNFOri	:= GetPosSD1("D1_NFORI")
Local nPSeOri	:= GetPosSD1("D1_SERIORI")
Local nPItOri	:= GetPosSD1("D1_ITEMORI")
Local nTamDoc	:= TamSX3("F1_DOC")[1]
Local nTamSer	:= TamSX3("F1_SERIE")[1]
Local nTamFor	:= TamSX3("F1_FORNECE")[1]
Local nTamLoj	:= TamSX3("F1_LOJA")[1]
Local nTamIt	:= TamSX3("D1_ITEM")[1]
Local nTamCod	:= TamSX3("D1_COD")[1]
Local cFilSD1	:= FwxFilial("SD1")
Local cFilSC7	:= FwxFilial("SC7")

Default nOpc		:= 0
Default cNCFor		:= ""
Default cNCLoj		:= ""

If nPItem > 0 .And. nPCod > 0 .And. nPNFOri > 0 .And. nPSeOri > 0 .And. nPItOri > 0 .And. nPQtd > 0
	SD1->(DbSetOrder(1))
	For nX := 1 To Len(aCols)
		If !aCols[nX,Len(aCols[nX])] //Item habilitado
			//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
			If !Empty(aCols[nX,nPNFOri]) .And. SD1->(DbSeek(cFilSD1 + PadR(aCols[nX,nPNFOri],nTamDoc) + PadR(aCols[nX,nPSeOri],nTamSer) + PadR(cNCFor,nTamFor) + PadR(cNCLoj,nTamLoj) + PadR(aCols[nX,nPCod],nTamCod) + PadR(aCols[nX,nPItOri],nTamIt)))
				If !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
					nQtdNC := aCols[nX,nPQtd] //Quantidade Redução

					//Posicionando na SC7
					nRecC7 := A103RECC7(cFilSC7,SD1->D1_PEDIDO,cNCFor,cNCLoj,aCols[nX,nPCod],SD1->D1_ITEMPC)
					If nRecC7 > 0
						SC7->(DbGoTo(nRecC7))

						If nOpc == 3 //Inclusão NC - Redução Valores - Estorna Valores do PC
							MaAvalPC("SC7",9,,,,,,,,,,,nQtdNC) 
						Elseif nOpc == 5 //Exclusão NC - Redução Valores - Inclui Valores do PC
							MaAvalPC("SC7",8,,,,,,,,,,,nQtdNC)
						Endif
					Endif
				Endif
			Endif
		Endif
	Next nX
Endif

RestArea(aArea)
FwFreeArray(aArea)

Return


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} COMOPGOVCOMBO
  	Função que retorna as strings para o combo do campo F1_OPGOV, para ficarem descritivas.
	@type function
	@author renan.martins
	@since 07/2026
	@return cRet, string, retorno das opções do combo
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
function COMOPGOVCBX()
	Local cRet := "" as character
	cRet := "1=" + STR0043 + ";2=" + STR0044 + ";3=" + STR0045 + ";4=" + STR0046 //1-Fornecimento pagamento posterior;2=Recebimento pagamento fornecimento já realizado;3=Fornecimento pagamento já realizado;4=Recebimento pagamento fornecimento posterior"
return cRet


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A103CPGVTP
  	Função que valida os tipos de compra governamental e os tipos de TES, para validação conforme suas necessidades.
	@type function
	@author renan.martins
	@since 07/2026
	@param cTipoOpe	, string	, tipo de operação governamental.
	@param cCodItem	, string	, código do item analisado.
	@param cCodTes	, string	, código da TES do item analisado.
	@return array	, array		, retorna o array, contendo o status da validação das regras e a mensagem de erro.
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
function A103CPGVTP(cTipoOpe as character, cCodItem as character, cCodTes as character)
	Local lRet			:= .T.				as logical
	Local cRetMsg		:= ""				as character
	Local cDescErro		:= ""				as character
	Local aAreaSF4		:= SF4->(GetArea()) as array
	Default cTipoOpe	:= ""
	Default cCodItem	:= ""
	Default cCodTes		:= ""

	if ( alltrim(SF4->F4_CODIGO) <> alltrim(cCodTes) )
		SF4->(DbSetOrder(1))
		SF4->(MsSeek(FwxFilial("SF4") + cCodTes))
	Endif

	//Se 2-Recebimento do pagamento com fornecimento já realizado, TES NÃO DEVE gerar duplicata e NÃO DEVE atualizar estoque, o processo é interrompido, pois a TES é inválida para Nota de recebimento.
	if ( cTipoOpe == "2" )
		if ( SF4->F4_DUPLIC != "N" .OR. SF4->F4_ESTOQUE!= "N" )
			cRetMsg		:= STR0047 + cCodItem + " - " + STR0048 + cCodTes + CRLF //Item: / Código TES:
			lRet 		:= .F.
			cDescErro	:= STR0049 //"Para o tipo 2=Recebimento do pagamento com fornecimento já realizado, utilize TES onde as opções 'Gera Duplicata' e 'Atualiza estoque' contenham o valor 'N' - Não."
		endif

	//Se 4-Recebimento do pagamento com fornecimento posterior, TES DEVE gerar duplicata e NÃO DEVE gerar estoque.
	elseif ( cTipoOpe == "4")
		if !( SF4->F4_DUPLIC == "S" .AND. SF4->F4_ESTOQUE == "N" )
			cRetMsg 	:= STR0047 + cCodItem + " - " + STR0048 + cCodTes + CRLF //Item: / Código TES:
			lRet 		:= .F.
			cDescErro	:= STR0050 //"Para o tipo 4-Recebimento do pagamento com fornecimento posterior, utilize TES que a opção 'Gera Duplicata' esteja igual a S-SIM e 'Atualiza Estoque' igual a N-Não."
		endif

	//Se 3-Fornecimento com pagamento já realizado, TES NÃO DEVE gerar duplicata e DEVE gerar estoque.
	elseif ( cTipoOpe == "3")
		if !( SF4->F4_DUPLIC == "N" .AND. SF4->F4_ESTOQUE == "S" )
			cRetMsg 	:= STR0047 + cCodItem + " - " + STR0048 + cCodTes + CRLF //Item: / Código TES: 
			lRet 		:= .F.
			cDescErro	:= STR0051 //"Para o tipo 3-Fornecimento com pagamento já realizado, utilize TES que a opção 'Gera Duplicata' esteja igual a N-Não e 'Atualiza Estoque' igual a S-Sim."
		endif
	endif
	RestArea(aAreaSF4)
	FwFreeArray(aAreaSF4)
return {lRet, cRetMsg, cDescErro}


//-----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A103VdSX2DKO
  	Função que valida o SX2 único da tabela, para verificar se pode ou não exibir o menu.
	@author renan.martins
	@type function
	@since 07/2026
	@return lRet, logical, Se o X2_UNICO da DKO é o que esperamos (DKO_FILIAL+DKO_DOC+DKO_SERIE+DKO_FORNEC+DKO_LOJA+DKO_ESPECI+DTOS(DKO_EMISSA)+DKO_ITEM+DKO_COD+DKO_ITXML)
/*/
//-----------------------------------------------------------------------------------------------------------------------------------
function A103VdSX2DKO()
	Local lRet		:= .F.								as logical
	Local cX2Corrt	:= "DKO_FILIAL+DKO_DOC+DKO_SERIE+DKO_FORNEC+DKO_LOJA+DKO_ESPECI+DTOS(DKO_EMISSA)+DKO_ITEM+DKO_COD+DKO_ITXML"	as character //Alterar se o X2_UNico for alterado
	Local cRetFun	:= alltrim(FWX2Unico("DKO"))		as character
	Local aRetCrt	:= ASort( StrTokArr(cX2Corrt, "+"))	as array
	Local aRetX2U	:= {}								as array
	Local nFor		:= 0								as numeric
	Local nTamX2	:= Len(aRetCrt)						as numeric

	if ( !empty(cRetFun) )
		cRetFun := StrTran(cRetFun, " ", "")
		aRetX2U := ASort( StrTokArr(cRetFun, "+"))

		if (cRetFun == cX2Corrt)
			lRet := .T.
		endif
		
		if ( !lRet .And. (Len(aRetCrt) == Len(aRetX2U)) )
			lRet := .T.
			for nFor := 1 to nTamX2
				if ( aRetCrt[nFor] != aRetX2U[nFor] )
					lRet := .F.
					exit
				endif
			next nFor
		endif
	endif
return lRet


/*/{Protheus.doc} A103OrSaiRT
Indica se o documento de origem a ser vinculado (documento referenciado) é uma nota de
SAÍDA (SF2/SD2) ou de ENTRADA (SF1/SD1), conforme regras da Reforma Tributária.

Regra geral: a origem acompanha o roteamento de entidade de A103RtCliRT - quando o documento
é tratado como cliente, a origem é nota de saída.

Exceção (Poder de Terceiros): Nota de Crédito (5) + Redução de Valores (4) + Formulário
Próprio ("S") + Poder de Terceiros ("1"). Nessa combinação, o parceiro do cabecalho é o
FORNECEDOR (ver A103P3VSCF/A103ExbCli), mas o documento de origem é nota de SAÍDA.

ATENÇÃO: a função responde apenas "a origem do vinculo é nota de saída?". Não responde
"o parceiro do cabeçalho é cliente ou fornecedor?" - essa pergunta continua sendo respondida
por A103RtCliRT, que NÃO deve ser alterada.

@param cTpTipNF - Tipo da Nota (F1_TIPO)
@param cTpCmpNF - Tipo de complemento da Nota (F1_TPCOMPL)
@param cTpForm  - Tipo do Formulario (F1_FORMUL - Proprio?)
@return lOrigSai - Origem e nota de saida (.T. - SF2/SD2 / .F. - SF1/SD1)
@author renan.martins
@since 07/26
/*/
Function A103OrSaiRT(cTpTipNF, cTpCmpNF, cTpForm)
Local lOrigSai		:= .F.
Local cCBXP3F1		:= Iif(Type("cCBXP3NAF1") != "C", "0", cCBXP3NAF1)
Default cTpTipNF	:= ""
Default cTpCmpNF	:= ""
Default cTpForm		:= ""

//Regra geral: a origem acompanha o roteamento de entidade.
lOrigSai := A103RtCliRT(cTpTipNF, cTpCmpNF, cTpForm)

//Exceção do Poder de Terceiros: cabeçalho em fornecedor, mas origem em nota de saída.
if ( !lOrigSai .And. cTpTipNF == CNOTACRED .And. cTpCmpNF == "4" .And. cTpForm == "S" .And. cCBXP3F1 == "1" )
	lOrigSai := .T.
endif

return lOrigSai

/*/{Protheus.doc} A103EspFoc
Indica se o tratamento diferenciado da especie de servico (NFS / NFSE) em
Nota de Credito (5) e Nota de Debito (6) esta ativo.

O mecanismo e governado pelo parametro MV_ESPFOCO e abrange:
 - foco inicial e ordem de digitacao do campo F1_ESPECIE no cabecalho;
 - filtro das opcoes do combo F1_TPCOMPL conforme a especie informada;
 - liberacao de TES geradora de duplicata / atualizacao de estoque;
 - geracao e estorno de titulo NDF (SE2) / NCC (SE1).

Com o parametro desligado - .F., valor padrao - o MATA103 mantem o
comportamento padrão, sem qualquer tratamento diferenciado por especie.

O valor é lido uma unica vez e mantido em Static.

@type  Function
@author vinicius.snascimento
@since 19/08/2026
@return lRet, Logical, .T. quando o mecanismo esta ativo
/*/

Function A103EspFoc() As Logical

If __lEspFoco == Nil
	__lEspFoco := SuperGetMV("MV_ESPFOCO", .F., .F.)
EndIf

Return __lEspFoco


/*/{Protheus.doc} A103EspSrv
Indica se a especie informada pertence a familia de documentos de servico
(NFS e NFSE).

Regra de negocio: o que caracteriza uma especie de servico e a presenca
do caractere "S" na terceira posicao (ex.: "NFS", "NFSE").
Especies com apenas dois caracteres (ex.: "NF") NAO sao consideradas servico,
ainda que sejam prefixo de especies de servico.

O tratamento só é aplicado quando o parametro MV_ESPFOCO esta ativo - ver
A103EspFoc(). Com o parametro desligado esta funcao sempre retorna .F., de
modo que o MATA103 opera exatamente como antes do mecanismo.
@type  Function
@author vinicius.snascimento
@since 12/08/2026
@version version
@param cEspDoc, Character, Especie do documento (F1_ESPECIE)
@return lRet, Logical, .T. quando a especie e de servico
/*/

Function A103EspSrv(cEspDoc As Character) As Logical

Local lRet      As Logical
Local cEspServ  As Character
Local cEspNorm  As Character

lRet     := .F.
cEspServ := "|NFS|NFSE|"

Default cEspDoc := ""

// Mecanismo desligado (MV_ESPFOCO = .F.): nenhuma especie é classificada como
// de servico, o que devolve todos os consumidores desta funcao - filtro do combo
// F1_TPCOMPL, validacao de TES em VLdDupDC, geracao e estorno de NDF / NCC - ao
// comportamento anterior, sem necessidade de guarda em cada ponto de chamada.
If !A103EspFoc()
	Return lRet
EndIf

cEspNorm := Upper(AllTrim(cEspDoc))

// Minimo 3 caracteres e terceiro digito deve ser "S" para caracterizar servico.
// Isso impede que "NF" (apenas dois digitos) seja tratado como servico por ser
// prefixo de especies validas como "NFS", "NFSE", etc.
If !Empty(cEspNorm) .And. Len(cEspNorm) >= 3 .And. SubStr(cEspNorm, 3, 1) == "S"
	lRet := "|" + cEspNorm + "|" $ cEspServ
EndIf

Return lRet


/*/{Protheus.doc} A103EspObg
Indica se o preenchimento da especie do documento (F1_ESPECIE) é obrigatorio.

Regra: alem da obrigatoriedade governada pelo parametro MV_ESPOBG, a especie
passa a ser SEMPRE obrigatoria quando o documento de entrada e Nota de Credito
(5) ou Nota de Debito (6) - independentemente do valor do parametro - porque a
especie determina as regras fiscais aplicaveis a esses documentos.

@type  Function
@author vinicius.snascimento
@since 17/08/2026
@param cTpTipNF, Character, Tipo da nota (F1_TIPO)
@return lRet, Logical, .T. quando o preenchimento da especie e obrigatorio
/*/

Function A103EspObg(cTpTipNF As Character) As Logical

Local lRet As Logical

Default cTpTipNF := ""

lRet := SuperGetMV("MV_ESPOBG", .F., .F.)

// Nota de Credito / Debito: especie sempre obrigatoria, mesmo com MV_ESPOBG = .F.
If !lRet .And. ( cTpTipNF == CNOTACRED .Or. cTpTipNF == CNOTADEBI )
	lRet := .T.
EndIf

Return lRet


/*/{Protheus.doc} A103RcPar
Indica se o documento é uma Nota de Credito (5) com Tipo de Complemento
6 - Recusa Parcial.

POR QUE ESTA FUNCAO EXISTE
A Recusa Parcial é o unico cenario em que o vinculo do documento referenciado e
APRESENTADO na tela no modo "por NF" - só para o usuario escolher a nota de saida
e receber a tela intermediaria de selecao de itens, exatamente como acontece no
4-Reducao de Valores. Toda a persistencia, porem, continua "por item", porque o
layout exigido pela legislacao para a Recusa Parcial e por item: isItNCND NAO
muda (segue .T.), e DKN, oJDocOrig['itens'], A103GRVREF, NCPutAcOri, CntValAcol
e as validacoes de a103TudoOk permanecem inalterados.

Consequencia: os poucos trechos que decidem o LAYOUT DA TELA a partir do
isItNCND precisam de uma condicao extra para a Recusa Parcial. Essa condicao
fica centralizada aqui, para nao espalhar o literal "6" pelos fontes.

@type  Function
@author vinicius.snascimento
@since 17/08/2026
@param cTpTipNF, Character, Tipo da nota (F1_TIPO)
@param cTpCmpNF, Character, Tipo de complemento da nota (F1_TPCOMPL)
@return lRet, Logical, .T. quando e Nota de Credito + 6-Recusa Parcial
/*/

Function A103RcPar(cTpTipNF As Character, cTpCmpNF As Character) As Logical

Local lRet As Logical

Default cTpTipNF := ""
Default cTpCmpNF := ""

lRet := ( cTpTipNF == CNOTACRED .And. cTpCmpNF == "6" )

Return lRet


/*/{Protheus.doc} A103JsItRP
Monta o oJDocOrig['itens'] da Recusa Parcial (NC + complemento 6) a partir do
aCols que a tela intermediaria de selecao acabou de carregar.

POR QUE E NECESSARIA
No ato do vinculo a Recusa Parcial usa o modelo "por NF" do COMDOCREF, e o
DOCREFCommit, nesse ramo, monta apenas oJDocOrig['documentos'] - bloco que
NENHUM caminho por item consome. Esta funcao converte "nota escolhida + itens
carregados" para o formato por item que A103GRVREF (gravacao da DKN),
NCPutAcOri, CntValAcol e A103VldRef esperam encontrar.

Cada linha viva do aCols vira um item do JSON com exatamente UM documento
referenciado: o item da tabela de origem de onde ela foi carregada, identificado
por D1_NFORI + D1_SERIORI + D1_ITEMORI (gravados pelo MPutD2Acol/MPutD1Acol
durante a carga).

GENERICA PARA SD1/SD2 - o parametro lOriEntr seleciona a tabela de origem:
 - lOriEntr = .F. (default): nota de SAIDA referenciada (SD2/SF2, parceiro SA1
   cliente) - uso atual pela Recusa Parcial.
 - lOriEntr = .T.: nota de ENTRADA referenciada (SD1/SF1, parceiro SA2
   fornecedor). So os pontos que realmente diferem entre as duas tabelas
   (alias do item/cabecalho, campo do parceiro, campo de valor unitario e
   tabela/campo do nome reduzido) sao resolvidos em variaveis antes do laco;
   o restante da montagem do JSON e comum as duas origens.

ATENCAO - os valores do documento referenciado sao lidos da tabela de origem e
NAO copiados do aCols. Depois da carga o usuario pode reduzir quantidade/valor
no grid para caracterizar a recusa parcial, e ? justamente a diferenca entre o
aCols e a tabela de origem que o A103VldRef compara. Copiar do aCols anularia
a validacao.

REMOCAO DO VINCULO (lSemVinc = .T.)
Quem limpa D1_NFORI / D1_SERIORI / D1_ITEMORI do aCols e reseta os fiscais do
vinculo anterior é o proprio NCPutAcOri, no ramo em que o item do JSON esta com
['documentos'] vazio. Como no modelo por NF o DOCREFCommit nao monta ['itens'],
sem essa montagem o NCPutAcOri nem seria chamado e os campos de origem ficariam
preenchidos apos o usuario desfazer o vinculo. Com lSemVinc os itens sao
montados a partir do aCols com ['documentos'] vazio, exatamente o formato que
dispara a limpeza - nao ha leitura da tabela de origem, pois nenhum valor
referenciado e necessario.

@type  Function
@author vinicius.snascimento
@since 17/08/2026
@param oJDoc   , Json     , Objeto oJDocOrig a ser populado (por referencia)
@param cCliRef , Character, Cliente/Fornecedor da nota de origem referenciada
@param cLojRef , Character, Loja da nota de origem referenciada
@param lSemVinc, Logical  , .T. monta os itens sem documento referenciado (vinculo desfeito)
@param lOriEntr, Logical  , .T. origem e nota de ENTRADA (SD1/SF1) - default .F. (nota de SAIDA, SD2/SF2)
@return nRet, Numeric, Quantidade de itens montados no JSON
/*/

Function A103JsItRP(oJDoc As Json, cCliRef As Character, cLojRef As Character, lSemVinc As Logical, lOriEntr As Logical) As Numeric

Local nRet       As Numeric
Local aItemVinc  As Array
Local aDocVinc   As Array
Local aAreaOri   As Array
Local aAreaCab   As Array
Local nPosItem   As Numeric
Local nPosCod    As Numeric
Local nPosNFOri  As Numeric
Local nPosSerOri As Numeric
Local nPosItmOri As Numeric
Local nX         As Numeric
Local cChvRef    As Character
Local cAliasOri  As Character // Alias da tabela de origem: SD2 (nota de saida) ou SD1 (nota de entrada)
Local cAliasCab  As Character // Alias do cabecalho: SF2 ou SF1
Local cAliasPrc  As Character // Alias do parceiro: SA1 (cliente) ou SA2 (fornecedor)
Local cPrefOri   As Character // Prefixo de campo da tabela de origem: D2 (SD2) ou D1 (SD1) - alias != prefixo
Local cCpParc    As Character // D2_CLIENTE ou D1_FORNECE
Local cCpVUnit   As Character // D2_PRUNIT ou D1_VUNIT
Local cCpNRedPrc As Character // A1_NREDUZ ou A2_NREDUZ
Local cCpChvNFe  As Character // F2_CHVNFE ou F1_CHVNFE
Local nOrdOri    As Numeric   // Ordem de SD2 (3) ou SD1 (1) pela chave doc+serie+parceiro+loja+cod+item
Local nTamOriDoc As Numeric
Local nTamOriSer As Numeric
Local nTamOriPrc As Numeric
Local nTamOriLoj As Numeric
Local nTamOriCod As Numeric
Local nTamOriItm As Numeric
Local nTamITXML	 As Numeric
Local cTamCmp	 As character

Default oJDoc    := Nil
Default cCliRef  := ""
Default cLojRef  := ""
Default lSemVinc := .F.
Default lOriEntr := .F.

nRet       := 0
aItemVinc  := {}
nPosItem   := GdFieldPos("D1_ITEM")
nPosCod    := GdFieldPos("D1_COD")
nPosNFOri  := GdFieldPos("D1_NFORI")
nPosSerOri := GdFieldPos("D1_SERIORI")
nPosItmOri := GdFieldPos("D1_ITEMORI")

If lOriEntr
	cAliasOri	:= "SD1"
	cAliasCab  	:= "SF1"
	cAliasPrc 	:= "SA2"
	cPrefOri  	:= "D1"
	cCpParc   	:= "D1_FORNECE"
	cCpVUnit  	:= "D1_VUNIT"
	cCpNRedPrc	:= "A2_NREDUZ"
	cCpChvNFe 	:= "F1_CHVNFE"
	nOrdOri   	:= 1 // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	cTamCmp		:= "DKN_ITXML"
Else
	cAliasOri 	:= "SD2"
	cAliasCab 	:= "SF2"
	cAliasPrc 	:= "SA1"
	cPrefOri  	:= "D2"
	cCpParc   	:= "D2_CLIENTE"
	cCpVUnit  	:= "D2_PRUNIT"
	cCpNRedPrc	:= "A1_NREDUZ"
	cCpChvNFe 	:= "F2_CHVNFE"
	nOrdOri   	:= 3 // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	cTamCmp		:= "D2_ITEM"
EndIf

nTamOriDoc := TamSx3(cPrefOri + "_DOC" )[1]
nTamOriSer := TamSx3(cPrefOri + "_SERIE")[1]
nTamOriPrc := TamSx3(cCpParc)[1]
nTamOriLoj := TamSx3(cPrefOri + "_LOJA")[1]
nTamOriCod := TamSx3(cPrefOri + "_COD" )[1]
nTamOriItm := TamSx3(cPrefOri + "_ITEM")[1]
nTamITXML  := FWSX3Util():GetFieldStruct(cTamCmp)[3]

// Sem os campos de origem no aCols nao ha como amarrar item de entrada x item de saida
If ValType(oJDoc) == "J" .and. nPosItem > 0 .and. nPosCod > 0 .and. nPosNFOri > 0 .and. nPosSerOri > 0 .and. nPosItmOri > 0

	If !lSemVinc
		aAreaOri := (cAliasOri)->(GetArea())
		aAreaCab := (cAliasCab)->(GetArea())

		DbSelectArea(cAliasOri)
		(cAliasOri)->(DbSetOrder(nOrdOri))
		DbSelectArea(cAliasCab)
		(cAliasCab)->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA (ou equivalente F1_*)
	EndIf

	For nX := 1 To Len(aCols)

		// Ignora linha deletada e linha sem origem (nao veio da carga da nota de origem)
		If !(aCols[nX][Len(aCols[nX])] .Or. Empty(aCols[nX][nPosNFOri]))
		
			If lSemVinc
				AAdd(aItemVinc, JsonObject():New())
				aItemVinc[Len(aItemVinc)]["item"]       := aCols[nX][nPosItem]
				aItemVinc[Len(aItemVinc)]["produto"]    := aCols[nX][nPosCod]
				aItemVinc[Len(aItemVinc)]["nfori"]      := aCols[nX][nPosNFOri]
				aItemVinc[Len(aItemVinc)]["seriori"]    := aCols[nX][nPosSerOri]
				aItemVinc[Len(aItemVinc)]["itemori"]    := AllTrim(aCols[nX][nPosItmOri])
				aItemVinc[Len(aItemVinc)]["documentos"] := {}
				Loop
			EndIf

			// Posiciona o item da tabela de origem que originou esta linha do grid
			If (cAliasOri)->(MsSeek(FwxFilial(cAliasOri) + ;
					PadR(aCols[nX][nPosNFOri]          , nTamOriDoc) + ;
					PadR(aCols[nX][nPosSerOri]         , nTamOriSer) + ;
					PadR(cCliRef                       , nTamOriPrc) + ;
					PadR(cLojRef                       , nTamOriLoj) + ;
					PadR(aCols[nX][nPosCod]            , nTamOriCod) + ;
					PadR(AllTrim(aCols[nX][nPosItmOri]), nTamOriItm) ))

				cChvRef := ""
				If (cAliasCab)->(MsSeek(FwxFilial(cAliasCab) + ;
						(cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_DOC")))  + ;
						(cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_SERIE"))) + ;
						(cAliasOri)->(FieldGet(FieldPos(cCpParc)))             + ;
						(cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_LOJA")))))
					cChvRef := (cAliasCab)->(FieldGet(FieldPos(cCpChvNFe)))
				EndIf

				aDocVinc := {}
				AAdd(aDocVinc, JsonObject():New())
				aDocVinc[1]["item"]       := (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_ITEM")))
				aDocVinc[1]["itemxml"]    := StrZero( Val( (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_ITEM"))) ), nTamITXML)
				aDocVinc[1]["documento"]  := (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_DOC")))
				aDocVinc[1]["serie"]      := (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_SERIE")))
				aDocVinc[1]["fornecedor"] := (cAliasOri)->(FieldGet(FieldPos(cCpParc)))
				aDocVinc[1]["loja"]       := (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_LOJA")))
				aDocVinc[1]["nomefor"]    := GetAdvFVal(cAliasPrc, cCpNRedPrc, FwxFilial(cAliasPrc) + (cAliasOri)->(FieldGet(FieldPos(cCpParc))) + (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_LOJA"))), 1)
				aDocVinc[1]["valorunit"]  := (cAliasOri)->(FieldGet(FieldPos(cCpVUnit)))
				// Saldo ainda passivel de recusa - mesma regra usada pela tela intermediaria
				aDocVinc[1]["quantidade"] := Max(0, (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_QUANT"))) - (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_QTDEDEV"))))
				aDocVinc[1]["valortotal"] := Max(0, (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_TOTAL"))) - (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_VALDEV"))))
				aDocVinc[1]["emissao"]    := (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_EMISSAO")))
				aDocVinc[1]["chave"]      := cChvRef
				aDocVinc[1]["forclirf"]   := (cAliasOri)->(FieldGet(FieldPos(cCpParc)))
				aDocVinc[1]["lojarf"]     := (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_LOJA")))
				aDocVinc[1]["identb6"]    := (cAliasOri)->(FieldGet(FieldPos(cPrefOri + "_IDENTB6")))

				AAdd(aItemVinc, JsonObject():New())
				aItemVinc[Len(aItemVinc)]["item"]       := aCols[nX][nPosItem]
				aItemVinc[Len(aItemVinc)]["produto"]    := aCols[nX][nPosCod]
				aItemVinc[Len(aItemVinc)]["nfori"]      := aCols[nX][nPosNFOri]
				aItemVinc[Len(aItemVinc)]["seriori"]    := aCols[nX][nPosSerOri]
				aItemVinc[Len(aItemVinc)]["itemori"]    := AllTrim(aCols[nX][nPosItmOri])
				aItemVinc[Len(aItemVinc)]["documentos"] := aClone(aDocVinc)
			EndIf
		EndIf
	Next nX

	oJDoc['itens'] := aClone(aItemVinc)
	nRet := Len(aItemVinc)

	If !lSemVinc
		(cAliasOri)->(RestArea(aAreaOri))
		(cAliasCab)->(RestArea(aAreaCab))
	EndIf

EndIf

Return nRet


/*/{Protheus.doc} A103TotRP
Retorna o valor total ainda passivel de recusa da nota de saida referenciada,
somando (D2_TOTAL - D2_VALDEV) de todos os itens que ainda tem saldo.

E a base de comparacao da validacao da Recusa Parcial: se o total dos itens da
Nota de Credito empatar com este valor, o usuario selecionou tudo o que havia
disponivel e nao reduziu nada - o que caracteriza uma recusa TOTAL disfarcada de
parcial. Selecionar apenas parte dos itens, ou reduzir valor/quantidade de algum
deles, mantem o total abaixo e e uma recusa parcial legitima.

Os filtros reproduzem os da tela de escolha da nota (DOCREFORIG): somente notas
de saida do tipo Normal/Beneficiamento e itens com quantidade ainda nao
devolvida, que sao exatamente os itens que a tela intermediaria lista.

A consulta e feita aqui, e nao reaproveitada da tela, porque a validacao tambem
roda na reabertura do documento e no ExecAuto - cenarios em que a tela
intermediaria nao existe.

@type  Function
@author vinicius.snascimento
@since 17/08/2026
@param cDocRef, Character	, Documento da nota de saida referenciada
@param cSerRef, Character	, Serie da nota de saida referenciada
@param cCliRef, Character	, Cliente da nota de saida referenciada
@param cLojRef, Character	, Loja da nota de saida referenciada
@param lNFCRRP, logical		, Se é Nota de crédito e redução parcial, com formulário próprio igual a Não
@return nRet, Numeric, Valor total disponivel para recusa na nota referenciada
/*/

Function A103TotRP(cDocRef As Character, cSerRef As Character, cCliRef As Character, cLojRef As Character, lNFCRRP as logical) As Numeric

Local nRet   As Numeric
Local cQry   As Character
Local cAlias As Character
Local oQry   As Object
Local cAliSr As Character
Local lRet   As logical

Default cDocRef	:= ""
Default cSerRef := ""
Default cCliRef := ""
Default cLojRef := ""
Default lNFCRRP := .F.

lRet   := .T.
nRet   := 0
cAlias := GetNextAlias()
cAliSr := "D2"

If Empty(cDocRef)
	lRet := .F.
EndIf
if ( lNFCRRP )
	cAliSr := "D1"
endif

if ( lRet )
	cQry := " SELECT SUM(S" + cAliSr + "." + cAliSr + "_TOTAL - S" + cAliSr + "." + cAliSr + "_VALDEV) TOTDISP "
	cQry += "   FROM " + RetSqlName("S" + cAliSr) + " S" + cAliSr
	cQry += "  WHERE S" + cAliSr + "." + cAliSr + "_FILIAL  = ? "
	cQry += "    AND S" + cAliSr + "." + cAliSr + "_DOC     = ? "
	cQry += "    AND S" + cAliSr + "." + cAliSr + "_SERIE   = ? "
	if ( !lNFCRRP )
		cQry += "    AND S" + cAliSr + "." + cAliSr + "_CLIENTE = ? "
	else
		cQry += "    AND S" + cAliSr + "." + cAliSr + "_FORNECE = ? "
	endif
	cQry += "    AND S" + cAliSr + "." + cAliSr + "_LOJA    = ? "
	cQry += "    AND S" + cAliSr + "." + cAliSr + "_TIPO   IN ('N', 'B') "
	cQry += "    AND S" + cAliSr + "." + cAliSr + "_QTDEDEV < S" + cAliSr + "." + cAliSr + "_QUANT "
	cQry += "    AND S" + cAliSr + ".D_E_L_E_T_ = ? "

	cQry := ChangeQuery(cQry)

	oQry := FWExecStatement():New(cQry)
	oQry:SetString(1, FwxFilial("S" + cAliSr))
	oQry:SetString(2, cDocRef)
	oQry:SetString(3, cSerRef)
	oQry:SetString(4, cCliRef)
	oQry:SetString(5, cLojRef)
	oQry:SetString(6, Space(1))

	cAlias := oQry:OpenAlias(cAlias)

	// SUM sem GROUP BY sempre devolve uma linha, mas pode vir nula quando nao ha item com saldo
	If !(cAlias)->(Eof()) .And. ValType((cAlias)->TOTDISP) == "N"
		nRet := (cAlias)->TOTDISP
	EndIf

	(cAlias)->(DbCloseArea())
	oQry:Destroy()
endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A103EnvEvt
Aciona a integracao tecnica com o TAF para solicitar o evento 211128
(aceite de debito na apuracao por emissao de nota de credito) para a
NF de credito posicionada
@param  cTabOri   - Tabela de origem NFE
@param  cRotina   - Rotina solicitante do Evento
@param  cIdEvent  - Evento de Aceite de débito na apuração por emissão de nota de crédito
@param  cChaveNfe - Chave NFE
@author Thiago Rodrigues
@since 17/08/2026
@version P12
@return Nil
/*/
//-------------------------------------------------------------------
Function A103EnvEvt(cTabOri as Character,cRotina as Character,cIdEvent as Character,cChaveNfe as Character)

	Local oEventsCompras as object
	Local jResponse      as json
	Local jDadosEven     as Json
	Local cAuthor 	     as Character 
	Local aSM0           as Array

	Default cTabOri   := "SF1"
	Default cRotina   := "MATA103"
	Default cChaveNfe := ""
	Default cIdEvent   := ""
	
	If FindClass("totvs.protheus.fiscal.taf.event.WSEventsRepository") .And.;
	   FindClass("totvs.protheus.backoffice.com.event.EventsCompras") .And. !Empty(cChaveNfe) .And. !Empty(cIdEvent)

		aSM0 := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_ESTENT" } )
		if Len(aSM0) > 0 
			cAuthor := aSM0[1,2]
		Endif

		jDadosEven := JsonObject():New()
		jDadosEven["chvnfe"]              := cChaveNfe  //Chave NFE
		jDadosEven["authorType"]          := "2"        //Tipo de Autor (1-Emitente, 2-Destinatário, 3-Sucessora)
		jDadosEven["stateAuthor"]         := cAuthor    //UF do Autor (SP, MG, RS)
		jDadosEven["acceptanceIndicator"] := "1"        //Indicador de Aceitação (0-Não, 1-Sim)
		jDadosEven["event"]               := cIdEvent   //Evento de Aceite de débito na apuração por emissão de nota de crédito	
		jDadosEven["originTable"]         := cTabOri    //Tabela de origem NFE
		jDadosEven["originRoutine"]       := cRotina    //Rotina solicitante do Evento

		oEventsCompras := totvs.protheus.backoffice.com.event.EventsCompras():New()
		jResponse := oEventsCompras:SendEvent(jDadosEven)

		If ValType(jResponse) == "J" 
			If (jResponse["code"] == 200 .Or. jResponse["code"] == 201)
				FwLogMsg('INFO',, STR0066, "MATA103", "", cIdEvent, STR0067 + cIdEvent + STR0068) //Aceite Débito - Evento xxxx adicionado à fila de processamento do TAF.
			Else 
				FwLogMsg('INFO',, STR0066, "MATA103", "", cIdEvent, STR0069 + cIdEvent + STR0070) //Aceite Débito - Falha ao enviar o envento xxxx. Consulte o monitor de Eventos
			EndIf
		EndIf
		FwFreeArray(aSM0)
		FwFreeObj(oEventsCompras)
		jResponse := NIL
	Endif


Return 

//-------------------------------------------------------------------
/*/{Protheus.doc}A103CanEvt
Aciona a integracao tecnica com o TAF para solicitar o cancelamento do evento 211128
(aceite de debito na apuracao por emissao de nota de credito) para a
NF de credito posicionada. Opcao de menu "Outras Acoes" - apenas dispara
a integracao ja parametrizada pela chave da NF corrente

@param  cIdEvent  - Evento de Aceite de débito na apuração por emissão de nota de crédito
@param  cChaveNfe - Chave NFE

@author Thiago Rodrigues
@since 17/08/2026
@version P12
@return Nil
/*/
//-------------------------------------------------------------------
Function A103CanEvt(cIdEvent as Character, cChaveNf as Character)

	Local oEventsCompras as object
	Local jResponse      as json
	local jDadosEven     as Json

	Default cIdEvent :=  ""
	Default cChaveNf :=  ""

	If FindClass("totvs.protheus.fiscal.taf.event.WSEventsRepository") .And.;
	   FindClass("totvs.protheus.backoffice.com.event.EventsCompras") .And. !Empty(cIdEvent) .And. !Empty(cChaveNf)

		jDadosEven := JsonObject():New()
		jDadosEven["event"]   := cIdEvent  //Evento de Aceite de débito na apuração por emissão de nota de crédito
		jDadosEven["chvnfe"]  := cChaveNf  //Chave NFE	

		oEventsCompras := totvs.protheus.backoffice.com.event.EventsCompras():New()
		jResponse := oEventsCompras:CancelEvent(jDadosEven)

		if ValType(jResponse) == "J" .And. jResponse:Hasproperty("lOk")
			If jResponse["lOk"]
				FwLogMsg('INFO',, STR0066, "MATA103", "", cIdEvent, STR0071 + cIdEvent + STR0072) //Aceite Débito - Solicitação de cancelamento do evento xxxxx enviada ao TAF. 
			EndIf
		Endif
		FwFreeObj(oEventsCompras)
		jDadosEven := Nil
	Endif

Return 


/*/{Protheus.doc} A103ChTsDV
A função valida se realmente deve preencher o campo D1_IDENTB6, quando associar uma nota de crédito (5)
e complemento Devolução Total (3), quando a TES de saída original estiver com o campo F4_TESDV em branco, pois não é
obrigatório seu preenchimento e da forma atual, obriga que preencha, para considerar devolução e preencher o campo.
@type  Function
@author renan.martins
@since 08/2026
@param lCredDEv	, lógico	, se é uma nota de crédito (5) e complemento (3) Devolução / Não encontrado
@param cTesAnl	, caractere	, código da TES original do Pedido de venda, para analise do campo F4_PODER3
@return lRet	, lógico	, se deve gravar ou não o campo IDENTB6, pois se F4_PODER3 for diferente de 'R', não deve, mesmo sendo crédito (5) e devolução (3)
/*/
function A103ChTsDV(lCredDEv as logical, cTesAnl as character) as logical
	Local aAreaSF4		:= {}				as array
	Local cFilSF4		:= FwxFilial("SF4")	as character
	Local lRet			:= .F.				as logical
	Default lCredDEv	:= .F.
	Default cTesAnl		:= ""

	if ( lCredDEv .and. !empty(cTesAnl) )
		aAreaSF4 := SF4->(GetArea())
		SF4->(DbSetorder(1)) // F4_FILIAL+F4_CODIGO
		if ( SF4->(DbSeek(cFilSF4 + cTesAnl )) )
			if ( SF4->F4_PODER3 == "R" ) //remessa, logo, tem poder de terceiros
				lRet := .T.
			endif
		endif
		RestArea(aAreaSF4)
		FwFreeArray(aAreaSF4)
	endif

return lRet


/*/{Protheus.doc} A103V5Cl6F
Função que valida a quantidade e valor unitário, quando for nota de crédito e complemento de recusa parcial.
Se o valor unitário for alterado, é retornado falso, pois deve ser igual da nota original, ou seja, não pode ser alterado.
Se a quantidade for alterada, deve ser para igual ou menor que a quantidade na nota original, nunca maior.
Fluxo via tela: comportamento original mantido (bloqueio incondicional em D1_VUNIT e comparação
direta em D1_QUANT), pois o oJsDados sempre chega com 'valorunit'/'quantidade' populados.
Fluxo via ExecAuto (l103Auto): a comparação NUNCA usa 'valorunit'/'quantidade' do próprio JSON
informado pelo ExecAuto - esses valores são apenas o que o script decidiu informar, não o dado
real gravado no documento de origem. A função busca o valor unitário/quantidade REAIS direto no
documento referenciado (SD1 quando origem é nota de entrada, SD2 quando é nota de saída - mesmo
critério de A103RtCliRT usado por A103VlNFRef), usando de 'documento'/'serie'/'item' do vínculo
apenas para localizar o registro. Sem o vínculo (documento/serie/item) informado, não há
comparação possível e o campo não é bloqueado.
@type  Function
@author renan.martins
@since 08/2026
@param cCampo	, caractere	, campo que está sendo validado (D1_UNIT ou D1_QUANT)
@param oJsDados	, json		, objeto json com os dados vinculados, que contêm todos os dados da nota original.
@param cItem	, caractere	, sequencial do item no grid
@param cProduct	, caractere , código do item
@return lRet	, lógico	, se o item foi validado ou não, conforme as regras.
/*/
function A103V5Cl6F(cCampo as character, oJsDados as json, cItem as character, cProduct as character) as logical
	Local aDados		:= {}		as array
	Local aRetOri		:= {}		as array
	Local aAreaSD1		:= {}		as array
	Local aAreaSD2		:= {}		as array
	Local lRet			:= .T.		as logical
	Local lBusSD2		:= .F.		as logical
	Local lAchouOri		:= .F.		as logical
	Local nPos			:= 0		as numeric
	Local nQuant		:= 0		as numeric
	Local nVUnit		:= 0		as numeric
	Local cDocOri		:= ""		as character
	Local cSerOri		:= ""		as character
	Local cItemOri		:= ""		as character
	Local cAjsForn		:= ""		as character
	Local nTamForne		:= 0		as numeric
	Local nTamLoja		:= 0		as numeric
	Local nTamD2Doc		:= 0		as numeric
	Local nTamD2Ser		:= 0		as numeric
	Local nTamD2Cod		:= 0		as numeric
	Local nTamD2Item	:= 0		as numeric
	Local nTamD1Doc		:= 0		as numeric
	Local nTamD1Ser		:= 0		as numeric
	Local nTamD1Cod		:= 0		as numeric
	Local nTamD1Item	:= 0		as numeric
	Local lBloqVUnit	:= .F.		as logical //-- Variavel de controle: setada em qualquer um dos dois fluxos (tela ou ExecAuto), o Help e disparado uma unica vez ao final.
	Local lBloqQtd		:= .F.		as logical //-- Idem, para a validacao de quantidade.
	Local lIsAuto		:= (Type("l103Auto") == "L" .And. l103Auto)	as logical //-- Identifica se a validacao esta ocorrendo via ExecAuto (variavel Private herdada da MATA103)
	Default cCampo		:= ""
	Default oJsDados	:= Nil
	Default cItem		:= ""
	Default cProduct	:= ""

	nTamForne   := TamSx3("F1_FORNECE")[1]
	nTamLoja    := TamSx3("F1_LOJA")[1]
	nTamD2Doc   := TamSx3("D2_DOC")[1]
	nTamD2Ser   := TamSx3("D2_SERIE")[1]
	nTamD2Cod   := TamSx3("D2_COD")[1]
	nTamD2Item  := TamSx3("D2_ITEM")[1]
	nTamD1Doc   := TamSx3("D1_DOC")[1]
	nTamD1Ser   := TamSx3("D1_SERIE")[1]
	nTamD1Cod   := TamSx3("D1_COD")[1]
	nTamD1Item  := TamSx3("D1_ITEM")[1]

	//-- Fluxo especifico ExecAuto: busca o valor unitario/quantidade REAIS do documento de
	//-- origem (SD1/SD2) - nunca o que o proprio ExecAuto informou no vinculo, senao a
	//-- validacao compararia o dado com ele mesmo e nunca detectaria divergencia real.
	if lIsAuto .and. ( cCampo == "M->D1_VUNIT" .or. cCampo == "M->D1_QUANT" ) .and. ;
		( oJsDados != Nil .and. oJsDados:hasproperty('itens') .and. len(oJsDados['itens']) > 0 )

		aDados 	:= aClone(oJsDados["itens"])
		nPos 	:= aScan(aDados, {|x| x['item'] + alltrim(x['produto']) == cItem + Alltrim(cProduct) })

		if nPos > 0 .and. len(oJsDados["itens"][nPos]['documentos']) > 0 .and. ;
			oJsDados["itens"][nPos]['documentos'][1]:hasproperty('documento') .and. ;
			oJsDados["itens"][nPos]['documentos'][1]:hasproperty('serie') .and. ;
			oJsDados["itens"][nPos]['documentos'][1]:hasproperty('item')

			cDocOri  := oJsDados["itens"][nPos]['documentos'][1]['documento']
			cSerOri  := oJsDados["itens"][nPos]['documentos'][1]['serie']
			cItemOri := oJsDados["itens"][nPos]['documentos'][1]['item']
			lBusSD2  := A103RtCliRT(cTipo, cTpCompl, cFormul) //-- .T. = origem em nota de saida (SD2) / .F. = nota de entrada (SD1)
			cAjsForn := PadR(cA100For, nTamForne) + PadR(cLoja, nTamLoja)

			aAreaSD1 := SD1->(GetArea())
			aAreaSD2 := SD2->(GetArea())

			if lBusSD2
				//-- Saldo real (quantidade - devolvida) e valor unitario do documento de saida original.
				//--aRetOri[1] - D2_PRCVEN (valor unitário)
				//--aRetOri[2] - D2_QUANT (quantidade total do item na nota de saída)
				//--aRetOri[3] - D2_QTDEDEV (quantidade já devolvida/recusada anteriormente desse item)
				aRetOri := GetAdvFVal("SD2", {"D2_PRCVEN", "D2_QUANT", "D2_QTDEDEV"}, ;
					FwxFilial("SD2") + PadR(cDocOri, nTamD2Doc) + PadR(cSerOri, nTamD2Ser) + ;
					cAjsForn + PadR(cProduct, nTamD2Cod) + PadR(cItemOri, nTamD2Item), 3)
				nVUnit := aRetOri[1]
				nQuant := max(0, aRetOri[2] - aRetOri[3])
			else
				//-- Valor unitario e quantidade do documento de entrada original.
				aRetOri := GetAdvFVal("SD1", {"D1_VUNIT", "D1_QUANT"}, ;
					FwxFilial("SD1") + PadR(cDocOri, nTamD1Doc) + PadR(cSerOri, nTamD1Ser) + ;
					cAjsForn + PadR(cProduct, nTamD1Cod) + PadR(cItemOri, nTamD1Item), 1)
				nVUnit := aRetOri[1]
				nQuant := aRetOri[2]
			endif

			RestArea(aAreaSD1)
			RestArea(aAreaSD2)
			lAchouOri := .T.
		endif
		FwFreeArray(aDados)
		FwFreeArray(aRetOri)
	endif

	if ( cCampo == "M->D1_VUNIT" )

		if !lIsAuto
			//-- Fluxo via tela: comportamento original, inalterado (ja funcional e validado).
			lBloqVUnit := .T.
		elseif lAchouOri .and. ( (&cCampo) <> nVUnit )
			lBloqVUnit := .T.
		endif

		if lBloqVUnit
			Help(Nil, nil, "A103BLOQVUN", Nil, STR0062, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0064}) // "Campo Vlr. Unitário não pode ser alterado para Notas de Crédito e complemento de Recusa Parcial." / "Não realize alteração no valor unitário, pois deve ser idêntico ao da Nota original." 
			lRet := .F.
		endif

	endif

	if ( cCampo == "M->D1_QUANT" )

		if !lIsAuto
			//-- Fluxo via tela: comportamento original, inalterado (ja funcional e validado).
			if ( oJsDados != Nil .and. oJsDados:hasproperty('itens') .and. len(oJsDados['itens']) > 0 )
				aDados 	:= aClone(oJsDados["itens"])
				nPos 	:= aScan(aDados, {|x| x['item'] + alltrim(x['produto']) == cItem + Alltrim(cProduct) })

				if nPos > 0 .and. len(oJsDados["itens"][nPos]['documentos']) > 0
					nQuant	:= oJsDados["itens"][nPos]['documentos'][1]['quantidade']
					if ( (&cCampo) > nQuant )
						lBloqQtd := .T.
					endif
				endif
				FwFreeArray(aDados)
			endif
		elseif lAchouOri .and. ( (&cCampo) > nQuant )
			lBloqQtd := .T.
		endif

		if lBloqQtd
			Help(Nil, 1, "A103BLOQTDMAIOR", Nil, STR0063 + cValtoChar(nQuant), 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0065} ) //"A quantidade informada deve ser igual ou menor que da Nota original. Quantidade na Nota Original:" /"A quantidade deve ser igual ou menor que a Nota original, já que se trata de recusa parcial."
			lRet := .F.
		endif
	endif
return lRet

/*/{Protheus.doc} A103NFXCON
	Tratamento para atualizar banco de conhecimento x documento entrada
		
	@author leandro nishihata
	@since 14/11/2023
/*/
Function A103NFXCON(cAliNF,nRecNF,nOpcNF,nOperNF)

Local lTabDKP		:= ChkFile("DKP")
Local lComTabDados	:= FindFunction("ComTabDados")
Local aDadosDKP		:= {}
Local lRetDoc	:= .F.
Local lSeekDkp	:= .F.
Local cNFiscal 	:= PADR(SF1->F1_DOC,TAMSX3("F1_DOC")[1]," ")
Local cSerie	:= PADR(SF1->F1_SERIE,TAMSX3("F1_SERIE")[1]," ")
Local cA100For 	:= PADR(SF1->F1_FORNECE,TAMSX3("F1_FORNECE")[1]," ")
Local cLoja 	:= PADR(SF1->F1_LOJA,TAMSX3("F1_LOJA")[1]," ")

Default cAliNF	:= "SF1"
Default nRecNF	:= 0
Default nOpcNF	:= 2
Default nOperNF := 0

Begin Transaction
	If cAliNF == "SF1" .And. lTabDKP .And. lComTabDados
		DKP->(DbSetOrder(1))
		lSeekDkp := DKP->(DbSeek(fwxFilial("DKP") + cNFiscal + cSerie + cA100For + cLoja + SF1->F1_ESPECIE + DtoS(SF1->F1_EMISSAO)))
		If !lSeekDkp
			aAdd(aDadosDKP,{{"DKP_FILIAL"	,fwxFilial("DKP")},;	// Filial do Sistema
							{"DKP_UIDSF1"	,SF1->F1_MSUIDT},;		// Chave UUID SF1
							{"DKP_DOC"		,SF1->F1_DOC},;			// Numero Documento             
							{"DKP_SERIE"	,SF1->F1_SERIE},;		// Serie                    
							{"DKP_FORNEC"	,SF1->F1_FORNECE},;		// Fornecedor / Cliente     
							{"DKP_LOJA"		,SF1->F1_LOJA},;		// Loja                     
							{"DKP_ESPECI"	,SF1->F1_ESPECIE},;		// Especie 
							{"DKP_EMISSA"	,SF1->F1_EMISSAO}})		// Emissao

			COMTabDados("DKP",aDadosDKP)
			lSeekDkp := DKP->(DbSeek(fwxFilial("DKP") + cNFiscal + cSerie + cA100For + cLoja + SF1->F1_ESPECIE + DtoS(SF1->F1_EMISSAO)))
		Endif
		
		If lSeekDkp
			ComAjusC9(cAliNF,cNFiscal + cSerie + cA100For + cLoja + SF1->F1_FORMUL,"DKP",DKP->DKP_MSUID)
		Endif
	Endif

	If lTabDKP .And. lSeekDkp
		If nOperNF > 0
			lRetDoc:= MsDocument("DKP",DKP->(Recno()),2,,3)
		Else
			lRetDoc:= MsDocument("DKP",DKP->(Recno()),4) 
		Endif
	Else
		If nOperNF > 0
			lRetDoc:= MsDocument(cAliNF,nRecNF,2,,3)
		Else
			lRetDoc:= MsDocument(cAliNF,nRecNF,4) 
		Endif
	Endif

	If !lRetDoc
		DisarmTransaction()
	Endif

End Transaction

Return

/*/{Protheus.doc} ComAjusC9
Ajusta a amarração da base de conhecimento com a nova tabela DKP

@version 12.1.2410
@author rodrigo.mpontes
@since 02/05/2026
/*/
Function ComAjusC9(cOldEnt,cOldKey,cNewEnt,cNewKey)

	Local cQuery As Character
	Local oQryAC9 As Object
    Local nParam As Numeric
    Local cAliasAC9 As Character
	Local lRet As Logical

	Default cOldEnt := ""
	Default cOldKey := ""
	Default cNewEnt := ""
	Default cNewKey := ""

	cQuery    := ""
	oQryAC9   := Nil
	nParam    := 1
    cAliasAC9 := GetNextAlias()
	lRet      := .F.

	cQuery := "SELECT AC9.R_E_C_N_O_ RECAC9 "
	cQuery += "FROM " + RetSQLName("AC9") + " AC9 "
	cQuery += "WHERE AC9.AC9_FILIAL = ? " // WHERE seguindo a ordem do indice 2 da tabela AC9 = AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	cQuery += "AND AC9.AC9_ENTIDA = ? "
	cQuery += "AND AC9.AC9_FILENT = ? "
	cQuery += "AND AC9.AC9_CODENT = ? "
	cQuery += "AND AC9.D_E_L_E_T_ = ? "
	cQuery := ChangeQuery(cQuery)

	oQryAC9 := FwExecStatement():New(cQuery)
	
	oQryAC9:SetString(nParam++, FWxFilial("AC9"))
	oQryAC9:SetString(nParam++, cOldEnt)
	oQryAC9:SetString(nParam++, FWxFilial(cOldEnt))
	oQryAC9:SetString(nParam++, cOldKey)
	oQryAC9:SetString(nParam++, " ")

	oQryAC9:OpenAlias(cAliasAC9)

	If (cAliasAC9)->(!EOF())
		While (cAliasAC9)->(!EOF())
			AC9->(DBGoTo((cAliasAC9)->RECAC9))

			RecLock("AC9", .F.)
			AC9->AC9_FILENT := FWxFilial("DKP")
			AC9->AC9_ENTIDA := cNewEnt
			AC9->AC9_CODENT := cNewKey
			AC9->(MSUnlock())
			
			(cAliasAC9)->(DBSkip())
		EndDo

		lRet := .T.
	EndIf

	(cAliasAC9)->(DBCloseArea())
	oQryAC9:Destroy()
	FWFreeObj(oQryAC9)
	
Return lRet

/*/{Protheus.doc} A103DevRef
Retorna se a nota de devolucao esta elegivel ao referenciamento por item
(Reforma Tributaria - RV VC02-14), no mesmo layout da Nota de Debito
complemento 4 - Multa e Juros.

A nota de devolucao nao e novidade da legislacao: existe ha anos com vinculo
em D1_NFORI/D1_SERIORI/D1_ITEMORI. O que muda e a exigencia do vinculo formal
gravado na DKN. Por isso esta funcao e especifica da devolucao e nao reaproveita
os predicados de Nota de Credito/Debito (isItNCND, A103RtCliRT, A103OrSaiRT),
que permanecem com sua semantica original.

Sem condicao de especie: a mudanca e apenas a possibilidade e a obrigatoriedade
do vinculo, e a devolucao mantem o comportamento atual quanto a especie.

@type  Function
@author vinicius.snascimento
@since 08/09/2026
@param cTipoNF , character, tipo da nota (F1_TIPO)
@param cTesItem, character, codigo da TES do item avaliado
@return lRet, logical, .T. quando devolucao elegivel ao vinculo por item
/*/
Function A103DevRef(cTipoNF As Character, cTesItem As Character) As Logical

Local lRet As Logical

lRet := .F.

Default cTipoNF  := ""
Default cTesItem := ""

If cPaisLoc == "BRA" .And. cTipoNF == "D" .And. !Empty(cTesItem)
	If GetAdvFVal("SF4", "F4_PODER3", xFilial("SF4") + cTesItem, 1) == "N"
		lRet := A103ChkDKNAmb()
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} A103DevJs
Deriva o vinculo por item da nota de devolucao a partir dos campos de origem
ja preenchidos no aCols (D1_NFORI / D1_SERIORI / D1_ITEMORI), delegando a
montagem do JSON ao A103JsItRP com origem em nota de SAIDA (SD2/SF2).

Existe para ISOLAR a devolucao do fluxo da Recusa Parcial, que compartilha o
A103JsItRP. Toda condicao especifica da devolucao mora aqui; o A103JsItRP
permanece sem conhecimento do cenario que o chama - nao recebe flag nova,
nem tem o ramo de saida (lOriEntr = .F.) alterado.

Acionada apenas no fluxo do botao "Retornar" (IsInCallStack("A103Devol")),
que e um modo automatico onde o sistema ja busca e preenche a origem. Na
digitacao direta ou via F4NFORI o vinculo continua sendo ato deliberado do
usuario, verificado por A103DevVld.

@type  Function
@author vinicius.snascimento
@since 08/09/2026
@param oJDoc  , json    , por referencia, documento de vinculo (oJDocOrig) a ser populado
@param cCliRef, character, cliente da nota de saida de origem
@param cLojRef, character, loja do cliente da nota de saida de origem
@return nRet, numeric, quantidade de itens vinculados no JSON
/*/
Function A103DevJs(oJDoc As Json, cCliRef As Character, cLojRef As Character) As Numeric

Local nRet As Numeric

Default oJDoc   := Nil
Default cCliRef := ""
Default cLojRef := ""

If ValType(oJDoc) != "J"
	oJDoc := JsonObject():New()
EndIf

nRet := A103JsItRP(@oJDoc, cCliRef, cLojRef, .F., .F.)

Return nRet

/*/{Protheus.doc} A103DevVld
Verifica, na confirmacao da devolucao, se cada item elegivel
(A103DevRef verdadeiro) tem o vinculo de documento referenciado exigido
por A103NtVlDC.

Regra "stateless", por linha viva do aCols:
1. a linha tem vinculo em oJDocOrig["itens"] para (item + produto)  -> aceita
2. senao, !INCLUI e a DKN ja tem registro para o item (DKNJaGrv)    -> aceita
   (alteracao/visualizacao de devolucao ja gravada)
3. senao, A103NtVlDC("D", cTpCompl, cEspDoc) exige o vinculo        -> bloqueia com Help

SUSPENSO: A103NtVlDC retorna .F. para devolucao (legislacao RV VC02-14 ainda nao
vigente), logo o item 3 nunca bloqueia hoje - o bloco do Help abaixo permanece
comentado de proposito. Reativacao futura: ver comentario em A103NtVlDC
(mata103.prw) e descomentar as duas linhas no corpo do laco desta funcao.

@type  Function
@author vinicius.snascimento
@since 08/09/2026
@param cTipoNF, character, tipo da nota (F1_TIPO)
@param cTpCompl, character, tipo de complemento da nota
@param cEspDoc, character, especie do documento
@param oJDoc, json, documento de vinculo (oJDocOrig)
@param aColsDev, array, aCols do documento (linhas D1_*)
@param lIncDev, logical, .T. quando o documento esta em inclusao/classificacao (INCLUI .Or. l103Class)
@param cDocDev, character, numero do documento da devolucao
@param cSerDev, character, serie do documento da devolucao
@param cForDev, character, codigo do parceiro (SF1->F1_FORNECE) da devolucao
@param cLojDev, character, loja do parceiro da devolucao
@return lRet, logical, .T. quando todos os itens elegiveis tem o vinculo exigido
/*/
Function A103DevVld(cTipoNF As Character, cTpCompl As Character, cEspDoc As Character, oJDoc As Json, ;
	aColsDev As Array, lIncDev As Logical, cDocDev As Character, cSerDev As Character, cForDev As Character, cLojDev As Character) As Logical

Local lRet      As Logical
Local nX        As Numeric
Local nPosItem  As Numeric
Local nPosCod   As Numeric
Local nPosTes   As Numeric
Local nPos      As Numeric
Local lTemVinc  As Logical
Local lDKNGrv   As Logical

Default cTipoNF  := ""
Default cTpCompl := ""
Default cEspDoc  := ""
Default aColsDev := {}
Default lIncDev  := .F.
Default cDocDev  := ""
Default cSerDev  := ""
Default cForDev  := ""
Default cLojDev  := ""

lRet     := .T.
nPosItem := GdFieldPos("D1_ITEM")
nPosCod  := GdFieldPos("D1_COD")
nPosTes  := GdFieldPos("D1_TES")

For nX := 1 To Len(aColsDev)

	If lRet .And. !aColsDev[nX][Len(aColsDev[nX])] .And. A103DevRef(cTipoNF, aColsDev[nX][nPosTes])

		lTemVinc := .F.
		If ValType(oJDoc) == "J" .And. oJDoc:hasproperty('itens')
			nPos := aScan(oJDoc['itens'], {|x| x['item'] + Alltrim(x['produto']) == aColsDev[nX][nPosItem] + Alltrim(aColsDev[nX][nPosCod]) })
			lTemVinc := (nPos > 0) .And. Len(oJDoc['itens'][nPos]['documentos']) > 0
		EndIf

		If !lTemVinc .And. !lIncDev
			lDKNGrv := .F.
			If FindFunction("DKNJaGrv")
				lDKNGrv := DKNJaGrv(cTipoNF, cTpCompl, cDocDev, cSerDev, cForDev, cLojDev, aColsDev)
			EndIf
			lTemVinc := lDKNGrv
		EndIf

		If !lTemVinc .And. A103NtVlDC(cTipoNF, cTpCompl, cEspDoc)
			//-- SUSPENSO: obrigatoriedade do vinculo para devolucao revertida - a
			//-- legislacao (RV VC02-14) ainda nao entrou em vigor. A103NtVlDC ja
			//-- retorna .F. para cTpTipNF == "D", entao este bloco nunca e alcancado
			//-- hoje. REATIVACAO FUTURA: alterar o retorno em A103NtVlDC (mata103.prw)
			//-- de .F. para .T. e descomentar as duas linhas abaixo - sao os DOIS
			//-- UNICOS pontos a tocar.
			// lRet := .F.
			// Help(NIL, NIL, "A103DOCREF", NIL, "O vinculo do documento referenciado nao foi informado ou nao foi localizado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilize a opcao 'Vinc. Doc. Referenciado' para vincular a nota de origem."}) //"O vinculo do documento referenciado nao foi informado ou nao foi localizado." / "Utilize a opcao 'Vinc. Doc. Referenciado' para vincular a nota de origem."
		EndIf

	EndIf

Next nX

Return lRet
