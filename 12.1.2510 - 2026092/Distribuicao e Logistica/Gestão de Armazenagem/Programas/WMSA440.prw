#Include "PROTHEUS.CH"
#Include "APWIZARD.CH"
#Include "WMSA440.CH"

#DEFINE INCLUIR 1
#DEFINE ALTERAR 2
#DEFINE CRLF CHR(13)+CHR(10)

#DEFINE WMSA44001 "WMSA44001"

//-----------------------------------
/*/{Protheus.doc} WMSA440
Wizard de Geração do Complemento de Produtos.

@author Tiago Filipe da Silva
@version P12
@Since  06/09/13
/*/
//-----------------------------------
Function WMSA440()
Local lRet        := .F.
Local nInd        := 0
Local nCps        := 0
Local nI          := 1
Local aPaineis    := {}
Local cTitTabela  := ""
Local cDescFiltro := ""
Local nOpc        := INCLUIR
Local cFil        := ""
Local lFim        := .F.
Local oDescFiltro := Nil
Local oFont       := Nil
Local oWizard     := Nil
Local oMemo       := Nil
Local cTexto      := STR0017+CRLF+CRLF  // Relação de produtos processados."
Local oDlgFinal   := Nil
Local lGerou      := .F.
Local aIndKey     := {}
Local cIndKey     := ""
Local cDesc       := ""
Local aTxtApre    := ""
Local cCampos     := ""
Local aSize       := {}
Local aCpsHead    := {}
Local aCpsTam     := {}
Local aCpsResumo  := {}
Local aContResum  := {}
Local aComplemen  := {}
Local aValCpsAux  := {}
Local aCpsAtuali  := {}
Local cMVWMSWCP   := SuperGetMv("MV_WMSWCP",.F.,"")
Local aStrRemove  := {"B5_FILIAL","B5_COD","B5_CEME"}
Local aColsSX3    := {}
Local aCposSB1    := {"B1_COD","B1_DESC"}

Private oDlg     := Nil
Private aColsWiz := {}
Private aBrWiz   := {}
Private oBrowse  := Nil
Private bBlock   := Nil

	aSize := MsAdvSize(.F.)

	// Busca as informações da tabela a ser processada
	cTitTabela := FWX2Nome("SB5")
	cIndKey    := FWX2Unico("SB5")
	aIndKey    := &("{'"+StrTran(AllTrim(cIndKey),"+","','")+"'}")
	aDel(aIndKey,1)
	aSize(aIndKey,Len(aIndKey)-1)

	cCampos := "B5_CODZON/B5_UMIND/B5_CTRWMS/B5_WMSEMB/B5_SERVENT/B5_SERVINT/B5_SERVSAI/B5_SERVREQ/B5_SERVDEV/B5_SERECD/B5_SERSCD/B5_ENDENT/B5_ENDSAI/B5_ENDREQ/B5_ENDDEV/B5_ENDECD/B5_ENDSCD/B5_SERVTDV"

	// Se o parametro estiver vazio é adicinado uma barra no da string dos campos
	If !Empty(cMVWMSWCP)
		// Remove os campos que não devem ser apresentados
		For nI := 1 To Len(aStrRemove)
			cMVWMSWCP := StrTran(cMVWMSWCP,aStrRemove[nI],"")
		Next nI
		cCampos += "/"+cMVWMSWCP
	EndIf

	aColsWiz := StrToKArr(cCampos,"/")

	// Ordenação dos campos
	aColsAux := Aclone(aColsWiz)

	nPos1 := aScan(aColsWiz,"B5_CODZON")
	aColsAux[1] := aColsWiz[nPos1]

	nPos2 := aScan(aColsWiz,"B5_UMIND")
	aColsAux[2] := aColsWiz[nPos2]

	j := 3

	For nCps := 1 To Len(aColsWiz)
		If nCps == nPos1 .Or. nCps == nPos2
			Loop
		EndIf

		aColsAux[j] := aColsWiz[nCps]
		j++
	Next nCps

	aColsWiz := Aclone(aColsAux)

	If Len(aColsWiz) >0 // Somente quando existirem campos válidos.
		lRet        :=  .T.

		// Texto padrao caso não seja passado por parâmetro.
		If aTxtApre == Nil .Or. Len(aTxtApre)<>4
			aTxtApre := {}
			aAdd(aTxtApre, STR0001)                                      // Facilitador...
			aAdd(aTxtApre, STR0002+AllTrim("SB5")+" - "+cTitTabela)  // Facilitador da tabela:
			aAdd(aTxtApre, "")
			aAdd(aTxtApre, STR0003)   // Este facilitador tem como objetivo, possibilitar a criação/alteração simplificada das informações do Complemento do Produto para atender de forma rápida as necessidades da gestão de armazenamento WMS. Partindo de critérios definidos na execução desse assistente."
		EndIf

		// Definição dos paineis de apresentação da rotina, estes paineis são padrões, com textos padrões
		cDesc   :=  STR0004
		aAdd(aPaineis,{STR0005, STR0006, cDesc})    // Informação a ser editada... // 1/6 - Neste passo seleciona-se a informação que se deseja alterar no respectivo cadastro."

		cDesc   :=  STR0007                         // Ao selecionarmos um filtro para o processamento da rotina, estaremos indicando que os registros que satisfizerem a condição definida abaixo serão excluídas do montante e não sofrerão nenhuma atualização."
		aAdd(aPaineis,{STR0008, STR0009, cDesc})    // Filtro... // 2/4 - Neste passo é possível efetuar um filtro no referido cadastro de forma a restringir as alterações em critérios específicos."

		aAdd(aPaineis,{STR0010, STR0011, ""})       // Grupo... // 3/4 - Neste passo podemos condicionar a atualização por um determinado grupo, ou seja, informações comuns para atualização em grupo."

		Define FONT oFont NAME "Arial" SIZE 0, -10
		Define FONT oFontB NAME "Arial" SIZE 0, -10 BOLD

		Define WIZARD oWizard;
			TITLE SubStr (aTxtApre[1], 1, 80);
			HEADER SubStr (aTxtApre[2], 1, 80);
			MESSAGE SubStr (aTxtApre[3], 1, 80);
			TEXT aTxtApre[4];
			NEXT {|| .T.};
			FINISH {|| .T.}
		For nInd := 1 To Len (aPaineis)

			CREATE PANEL oWizard;
				HEADER aPaineis[nInd][1];
				MESSAGE aPaineis[nInd][2];
				BACK {|| BkPainel(oWizard)};
				NEXT {|| ValPainel(oWizard,"SB5",cFil,cTitTabela,cDescFiltro,@aIndKey,aCpsHead,aCpsTam,aCpsResumo,aContResum,aCpsAtuali,aValCpsAux)};
				FINISH {|| lFim := MSGYESNO(STR0019,STR0016)}   // Confirma atualização em massa conforme apresentação no quadro de resumo ? // Atenção

			If nInd == 1
				TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(nInd))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)

				@29,05 TO 132,282 LABEL STR0012 OF oWizard:oMPanel[nInd+1] PIXEL    // Campo a ser editado

				RegToMemory("SB5", .T.,,.F.)

				oEncSB5 := MsmGet():New("SB5",,3,,,,aColsWiz,{40,10,127,275},,,,,,oWizard:oMPanel[nInd+1],.T.,.T.)
				oEncSB5:Refresh()

			ElseIf nInd == 2
				// Filtro
				TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(nInd))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)

				@40,05 TO 132,250 LABEL STR0013 OF oWizard:oMPanel[nInd+1] PIXEL // Filtro"
				@50,10 GET oDescFiltro VAR cDescFiltro MEMO SIZE 235,74 OF oWizard:oMPanel[nInd+1] PIXEL READONLY

				DEFINE SBUTTON FROM 44,255  TYPE 17 ENABLE OF oWizard:oMPanel[nInd+1] ACTION (cFil  := BuildExpr("SB1",oWizard:oMPanel[3],cFil),;
						cDescFiltro := MontDescr("SB5",cFil),;
						oDescFiltro:Refresh()) WHEN (nOpc == INCLUIR .OR. nOpc == ALTERAR) // Monta o filtro

			ElseIf nInd == 3
				TSay ():New (05, 05, &("{||aPaineis["+AllTrim(Str(3))+"][3]}"), oWizard:oMPanel[nInd+1],,oFont,.F.,.F.,.F., .T., CLR_BLUE,, 275, 50, .F., .F., .F., .F., .F.)

				@2,05 TO 132,295 LABEL STR0014 OF oWizard:oMPanel[nInd+1] PIXEL // Resumo

				For nI := 1 To Len(aCposSB1)
					aAdd(aCpsHead, BuscarSX3(aCposSB1[nI],,aColsSX3))
					aAdd(aCpsTam , aColsSX3[3])
				Next nI

				aAdd(aCpsResumo, ("B5_COD"))
				aAdd(aCpsResumo, ("B5_CEME"))

				// For para criação dos arrays com os titulos dos campos que aparecerão no resumo, o tamanho e o nome dos campos no banco
				For nCps := 1 To Len (aColsWiz)
					BuscarSX3(aColsWiz[nCps],,aColsSX3)
					aAdd(aCpsHead  , aColsSX3[1])
					aAdd(aCpsTam   , aColsSX3[2])
					aAdd(aCpsResumo, aColsWiz[nCps])
				Next nCps

				oBrowse := TWBrowse():New(12 , 10, 280, 116,,aCpsHead,aCpsTam,oWizard:oMPanel[4],,,,,,,,,,,,.F.,,.T.,,.F.,,, )

				// Montagem do bloco de código bLine
				bBlock := "{ ||{aBrWiz[oBrowse:nAt,1],aBrWiz[oBrowse:nAt,2],aBrWiz[oBrowse:nAt,3],aBrWiz[oBrowse:nAt,4]"

				If Len(aColsWiz) > 2
					For nCps := 5 To Len(aColsWiz)+2
						bBlock += ",aBrWiz[oBrowse:nAt,"+AllTrim(Str(nCps))+"]"
					Next nCps
				EndIf

				bBlock += "}}"

				aBrWiz := {Array(Len(aColsWiz)+2)}

				oBrowse:SetArray(aBrWiz)
				oBrowse:bLine := &bBlock
			EndIf
		Next (nInd)

		Activate WIZARD oWizard Centered

		If lFim
			// Processamento dos dados informados
			Atualiza(@lGerou,@aValCpsAux,@aCpsAtuali)

			If lGerou
				cTexto  +=  CRLF
				cTexto  +=  STR0020 // Conclusão: Foram criados os complementos dos produtos selecionados conforme o filtro.
			Else
				cTexto  +=  STR0015     // Nenhum
				cTexto  +=  CRLF+CRLF
				cTexto  +=  STR0021     // STATUS: Atualização não efetuada, pois não houve alteração.
			EndIf

			DEFINE MSDIALOG oDlgFinal TITLE STR0025 From 3,0 to 340,417 PIXEL                       // Atualizacao concluida.
			@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlgFinal PIXEL READONLY
			oMemo:bRClicked := {||AllwaysTrue()}
			oMemo:oFont:=oFont
			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgFinal:End() ENABLE OF oDlgFinal PIXEL // Sair
			ACTIVATE MSDIALOG oDlgFinal CENTER
		EndIf
		dbSelectArea("SB5")
		dbGoTop()
	EndIf
Return lRet

//-----------------------------------
/*/{Protheus.doc} ValPainel
Validacao das trocas de paineis do wizard.

@author Tiago Filipe da Silva
@version P12
@Since  06/09/13
@obs
/*/
//-----------------------------------

Static Function ValPainel(oWizard,cAliasSB5,cFil,cTitTabela,cDecFiltro,aIndKey,aCpsHead,aCpsTam,aCpsResumo,aContResum,aCpsAtuali,aValCpsAux)
Local lRet  :=  .T.
Local nCps :=  0
	If oWizard:NPANEL==2
		If Empty(M->B5_CODZON) .OR. Empty(M->B5_UMIND)
			Help(,,'HELP',,STR0022,1,0,) // Conteúdo do campo obrigatório deve ser diferente de branco. Verificar campos Zona Armaz. ou UM.Industria."
			lRet := .F.
		EndIf

	ElseIf oWizard:NPANEL == 3
		// Zera arrays
		aContResum := {}
		aValCpsAux := {}
		aCpsAtuali := {}

		// Adiciona os campos obrigatórios nos arrays que conterão os valores E os campos que serão atualizados
		aAdd(aContResum, {"SB1->B1_COD"})
		aAdd(aContResum, {"SB1->B1_DESC"})
		aAdd(aCpsAtuali, ("B5_COD"))
		aAdd(aCpsAtuali, ("B5_CEME"))

		// Resgata os valores dos campos digitados em tela e os campos que serão atualizados
		For nCps := 3 to Len(aCpsResumo)
			aAdd(aContResum, {&("M->"+AllTrim(aCpsResumo[nCps]))})
			aAdd(aCpsAtuali, (AllTrim(aCpsResumo[nCps])))
		Next nCps

		If Empty(cFil)
			Help(,,'HELP',,STR0023,1,0,)    // Filtro é obrigatório.
			lRet := .F.
		Else
			MontaBrw(cFil,aContResum,aCpsResumo,aValCpsAux) // Função para montagem do Browse, é passado o filtro, os conteudos, os campos que serão atualizados e um array auxiliar

			If Empty(aBrWiz)
				Help(,,'HELP',,STR0026,1,0,) // Nenhum registro encontrado com o filtro especificado.
				aBrWiz := {Array(Len(aColsWiz)+2)}
				oBrowse:SetArray(aBrWiz)
				oBrowse:bLine := &bBlock
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

//-----------------------------------
/*/{Protheus.doc} BkPainel
Funcao validacao ao voltar o assistente da rotina.

@author Tiago Filipe da Silva
@version P12
@Since  06/09/13
@obs
/*/
//-----------------------------------

Static Function BkPainel(oWizard)
Local   lRet    :=  .T.
Local nCps := 0
Local bBlock := ""
	If oWizard:NPANEL==4
		aBrWiz := {}

		// Bloco de código bLine
		bBlock := "{ ||{aBrWiz[oBrowse:nAt,1],aBrWiz[oBrowse:nAt,2],aBrWiz[oBrowse:nAt,3],aBrWiz[oBrowse:nAt,4]"

		If Len (aColsWiz) > 2
			For nCps := 5 To Len(aColsWiz)+2
				bBlock += ",aBrWiz[oBrowse:nAt,"+AllTrim(Str(nCps))+"]"
			Next nCps
		EndIf

		bBlock += "}}"

		aBrWiz := {Array(Len(aColsWiz)+2)}
		oBrowse:SetArray(aBrWiz)
		oBrowse:bLine := &bBlock
		oBrowse:Refresh()
	EndIf
Return lRet

//-----------------------------------
/*/{Protheus.doc} MontaBrw
Funcao para montar o array com os valores do painel 2 conforme o filtro especificado

@author Tiago Filipe da Silva
@version P12
@Since  06/09/13
@obs
/*/
//-----------------------------------

Static Function MontaBrw(cFil,aContResum,aCpsResumo,aValCpsAux)
Local lRet := .T.
Local nI := 0
Local bBlockAux := ""
Local aValCpo := {}
Local aBrwAux := {}
Local cTipo := ""
	dbSelectArea("SB1")
	SB1->(dbSeek(xFilial("SB1")))

	aValCpsAux := {}
	// Montagem do bloco de código que conterá os campos do browse
	Do While SB1->(!Eof()) .And. SB1->B1_FILIAL == xFilial("SB1")
		If &cFil        // Se a execução do filtro for .T.
			For nI = 1 To Len(aContResum)
				If nI == 1
					bBlockAux := "{ || aValCpo := {'" + &(AllTrim(aContResum[nI][1]))+"'"
				Else
					If nI == 2
						bBlockAux += ",'" + StrTran(&(AllTrim(aContResum[nI][1])),"'")+"'"
					Else
						cTipo := Posicione("SX3",2,aCpsResumo[nI],"X3_TIPO")

						If cTipo == "N"
							If !ValType(aContResum[nI][1]) == "C"
								aContResum[nI][1] := str(aContResum[nI][1])
							EndIf
							bBlockAux += "," + AllTrim(aContResum[nI][1])

						ElseIf cTipo == "D"
							If !ValType(aContResum[nI][1]) == "D"
								aContResum[nI][1] := ""
							EndIf
							bBlockAux += ",'" + AllTrim(DtoS(aContResum[nI][1]))+"'"
						ElseIf cTipo == "C"
							bBlockAux += ",'" + StrTran(AllTrim(aContResum[nI][1]),"'")+"'"
						EndIf
					EndIf
				EndIf
			Next nI
			bBlockAux += "}}"

			Eval(&bBlockAux)

			aAdd(aBrWiz, aValCpo)
			aValCpo := {}
		EndIf
		SB1->(dbSkip())
	EndDo
	// Eliminação da primeira linha nula do array
	aBrwAux := aClone(aBrWiz)
	For nI = 1 To Len(aBrWiz)
		If (nI + 1) <= Len(aBrWiz)
			aBrWiz[nI] := aBrWiz[nI + 1]
			aBrWiz[nI + 1] := aBrwAux[1]
		EndIf
	Next nI
	ASize(aBrWiz,Len(aBrWiz)-1)
	aValCpsAux := aClone(aBrWiz)
Return lRet

//-----------------------------------
/*/{Protheus.doc} Atualiza
Funcao de atualizacao da tabela envolvida.

@author Tiago Filipe da Silva
@version P12
@Since  06/09/13
@obs
/*/
//-----------------------------------

Static Function Atualiza(lGerou,aValCpsAux,aCpsAtuali)
Local nI           := 0
Local nX           := 0
Local aComplemen   := {}
Local nTamCEME     := TamSX3("B5_CEME")[1]

Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.
Private lMsErroAuto    := .F.
	If Len(aBrWiz) > 0
		lGerou := .T.
		Begin Transaction
			For nI := 1 to Len(aValCpsAux)
				aComplemen := {}
				aAdd(aComplemen, {"B5_FILIAL", xFilial("SB5"), nil})
				For nX := 1 to Len(aCpsAtuali)
					If ValType(SB5->&(aCpsAtuali[nX])) == "N" .And. ValType(aValCpsAux[nI][nX]) != "N"
						aValCpsAux[nI][nX] := CtoN(aValCpsAux[nI][nX],10)
					Elseif ValType(SB5->&(aCpsAtuali[nX])) == "D" .And. ValType(aValCpsAux[nI][nX]) != "D"
						aValCpsAux[nI][nX] := StoD(aValCpsAux[nI][nX])
					EndIf
					If aCpsAtuali[nX] == "B5_CEME"
						aValCpsAux[nI][nX] := PadR(aValCpsAux[nI][nX],nTamCEME)
					EndIf
					If !Empty(aValCpsAux[nI][nX])
						// Para cada linha do browse é adicionada uma linha no array para execução
						aAdd(aComplemen, {aCpsAtuali[nX], aValCpsAux[nI][nX], nil})
					EndIf
				Next nX
				dbSelectArea("SB5")
				SB5->(dbSetOrder(1))
				SB5->(dbSeek(xFilial("SB5")+aValCpsAux[nI][1]))

				If SB5->(!EOF()) .And. AllTrim(SB5->(B5_FILIAL+B5_COD)) == AllTrim(xFilial("SB5")+aValCpsAux[nI][1])
					MSExecAuto({|x,y| Mata180(x,y)},aComplemen, 4) // Já existe complemento para o produto (update)
				Else
					MSExecAuto({|x,y| Mata180(x,y)},aComplemen, 3) // Não existe existe complemento para o produto (insert)
				EndIf

				If lMsErroAuto
					MostraErro() // Mensagem em tela
					Exit
				EndIf
			Next nI

			If lMsErroAuto
				DisarmTransaction()
			EndIf
		End Transaction
	Else
		MsgAlert(STR0024)
		lGerou := .F.
	EndIf
Return
