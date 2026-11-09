#INCLUDE "PROTHEUS.CH"
#include 'TOPCONN.ch'
#include "OFIA539.CH"

/*/{Protheus.doc} OFIA539
Rotina de importacao de arquivo PRI 9600
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Function OFIA539()
	Local lAbort     As Logical
	Local lTudoOk    As Logical
	Local oControle  As Object
	Local aMsg       As Array
	Local aArea      := FwGetArea()
	Local lSchedule  := FWGetRunSchedule()
	Local oSay       := Nil

	aMsg        := {}
	oControle   := JSonObject():New()
	oControle["schedule"] := lSchedule

	lTudoOk := .F.
	lAbort  := .F.

	If lSchedule
		lTudoOk := OA539001M_VldTOk( @oControle )
		If !lTudoOk
			OA539009M_GrvLog( { STR0010 } )
			lAbort := .T.
		EndIf
	Else
		While !lAbort .And. !lTudoOk
			lAbort := Pergunte("OFIA539", .T., STR0032)
			If !lAbort .Or. !OA539001M_VldTOk( @oControle )
				lAbort := If( !lAbort, .T., .F. ) ; Loop
			Else
				lTudoOk := .T.
			EndIf
		End
	EndIf

	If lAbort .And. !lTudoOk
		Return
	Else
		If MV_PAR07 == 3
			aAdd(aMsg, {STR0019})
		EndIf
		aAdd(aMsg, {STR0036})
		oControle["id_log"] := OA539009M_GrvLog( aMsg )

		If lSchedule
			OA539002M_ExecutaLeitura( oControle, Nil, lSchedule )
		Else
			FWMsgRun(,{|oSay| OA539002M_ExecutaLeitura( oControle, oSay, lSchedule )},, STR0020 )
		EndIf
	EndIf

	FwRestArea(aArea)

Return


/*/{Protheus.doc} SchedDef
Funcao padrao Scheduler
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Static Function SchedDef()
	Local aParam := {}
	aAdd(aParam, "P"      ) // 01 - Tipo: "P" para Processo
	aAdd(aParam, "OFIA539") // 02 - Grupo de perguntas (SX1)
	aAdd(aParam, ""        ) // 03 - Alias (apenas para Relatorio)
	aAdd(aParam, {}        ) // 04 - Array de ordens (apenas para Relatorio)
	aAdd(aParam, ""        ) // 05 - Titulo (apenas para Relatorio)
	aAdd(aParam, ""        ) // 06 - Layout de impressao (apenas para Relatorio)
	aAdd(aParam, .F.       ) // 07 - Permite agendamento sempre ativo? (LIB 20260413)
	aAdd(aParam, .F.       ) // 08 - Permite agendamento por filiais? (LIB 20260413)
Return aParam


/*/{Protheus.doc} OA539002M_ExecutaLeitura
Orquestra a leitura do arquivo e processamento dos itens.
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Static Function OA539002M_ExecutaLeitura( oControle, oSay, lSchedule )

	Local cLin      As Character
	Local cId       As Character
	Local cLog      As Character
	Local nQuant    As Numeric
	Local lOA539Lin As Logical
	Local lOA539Fim As Logical
	Local aGrupos   As Array
	Local aItNoEx   As Array
	Local cGroup    As Character
	Local lFound    := .F.
	Local oFile     := Nil

	Local nTotal    := 0
	Local nAtual    := 0
	Local nTam      := 0
	Local nFilSB1   := 0

	Local oCache    := OA539013M_CacheFiliais()

	Local nTamGrupo := TamSx3("B1_GRUPO")[1]
	Local nTamCodIt := TamSx3("B1_CODITE")[1]
	Local aFilSB1Map := oCache["aSB1Map"]

	// Alterações para mostrar a quantidade de itens processados
	Local cMsg := ""
	Local nErros := 0
	Local nOk := 0
	Local nX := 0

	aGrupos   := OA539011M_SeparaGrupo()
	oDados    := oControle["modelo"]
	oFile     := oControle["ofile"]

	nPos      := aScan( oDados["indices"], {|x| x["campo"] == "B1_COD" })
	nPosIni   := If( nPos > 0, oDados["indices"][nPos]["inicio"], 0 )
	nPosFim   := If( nPos > 0, oDados["indices"][nPos]["fim"]   , 0 )
	nQuant    := 0

	lOA539Lin := ExistBlock("OA539LIN")
	lOA539Fim := ExistBlock("OA539FIM")

	cLog      := oControle["id_log"]
	cFilBck   := cFilAnt
	aItNoEx   := {}
	
	SB1->(dbSetOrder(7))
	SB5->(dbSetOrder(1))
	SBZ->(dbSetOrder(1))
	
	If !lSchedule
		nTotal := OA539014M_ContaLinhas( oFile )
		oFile:Close()
		oFile := FWFileReader():New( AllTrim( MV_PAR01 ) )
		oFile:Open()
	EndIf
	
	While ( oFile:hasLine() )
		cFilAnt := cFilBck
		cLin    := oFile:GetLine()

		If Empty(cLin) .Or. At("Item", cLin) > 0
			Loop
		EndIf

		nAtual++
		cId := SubStr( cLin, nPosIni, nPosFim )

		// Progresso de mil em mil
		If !lSchedule .And. (nAtual == 1 .Or. nAtual % 1000 == 0 .Or. nAtual == nTotal)
			oSay:SetText(STR0037 + cValToChar(nAtual) + " - " + cValToChar(nTotal))
			ProcessMessages()
		EndIf

		nTam := 1

		While nTam <= Len( aGrupos )
			cGroup := aGrupos[nTam]
			lFound := .F.

			For nFilSB1 := 1 To Len(aFilSB1Map)
				cChave := aFilSB1Map[nFilSB1][2] + PadR(cGroup, nTamGrupo) + PadR( cId, nTamCodIt )

				If SB1->(DbSeek( cChave ))
					OA539004M_GravaRegistros( oDados, cLin, cLog, oCache )
					lFound := .T.
				EndIf
			Next nFilSB1

			If !lFound
				aAdd(aItNoEx, {AllTrim(cGroup), AllTrim(cId)})
			EndIf

			nTam++
		EndDo

		If lOA539Lin
			ExecBlock("OA539LIN", .F., .F., { cLin })
		EndIf

		nQuant++
	EndDo

	If lOA539Fim
		ExecBlock("OA539FIM", .F., .F., {} )
	EndIf

	cFilAnt := cFilBck
	oFile:Close()

	// Loga itens nao encontrados
	If Len(aItNoEx) > 0
		OA539009M_GrvLog({OA539012J_MontaJsonDeItensNaoImportados(aItNoEx)}, cLog)
	EndIf

	nErros := Len(aItNoEx)
	nOk := nTotal - nErros
	
	cMsg := STR0038 + " " + CRLF //"Resumo do processamento:"
	cMsg += STR0039 + " " + AllTrim(cValToChar(nTotal)) + CRLF //"Total de registros:"
	cMsg += STR0040 + " " + AllTrim(cValToChar(nOk)) + CRLF //"Registros atualizados:"
	cMsg += STR0041 + " " + AllTrim(cValToChar(nErros)) //"Registros não atualizados:"

	If !lSchedule
		FWAlertInfo(cMsg, "OFIA539")

		If nErros == 0
			FWAlertSuccess(STR0042, "OFIA539") //"Processamento concluído com sucesso"
		Else
			cMsg := ""
			For nX := 1 to Len(aItNoEx)
				cMsg += AllTrim(aItNoEx[nX][2]) + CRLF
			Next
			//"Processamento não foi concluído corretamente."
			//"Os seguintes produtos não foram encontrados:"
			FMX_HELP("OFIA539", STR0044 + CRLF + STR0045 + CRLF + cMsg)
		EndIf
	EndIf

	FWFreeArray(aItNoEx)

	// Pos-processamento do arquivo
	If MV_PAR07 != 1 .And. nQuant > 0
		OA539006M_MoveArquivo( oFile:cFileName, cLog )
	ElseIf MV_PAR07 == 1
		OA539009M_GrvLog( { STR0009 }, cLog )
	EndIf

	OA539009M_GrvLog( { STR0010 }, cLog )

Return

/*/{Protheus.doc} OA539004M_GravaRegistros
Gravacao nas tabelas SB1, SB5 e SBZ.
Delega a escrita de campos para OA539015M_GravaCampos.
@type function
@author		Diogo Barros
@since		20/05/2026
@param oMoldura	Object com arrays sb1[], sb5[], sbz[]
@param cLin		Character linha do arquivo
@param cLog		Character id do log
@param oCache	Object cache de filiais
/*/
Static Function OA539004M_GravaRegistros( oMoldura, cLin, cLog, oCache )

	Local aSB5Fil    As Array
	Local aSBZFil    As Array
	Local aFilSB1Map As Array
	Local lSB5       As Logical
	Local lSBZ       As Logical
	Local nX         As Number
	Local nPosFil    As Number

	aFilSB1Map := oCache["aSB1Map"]
	aSB5Fil    := oCache["aSB5Fil"]
	aSBZFil    := oCache["aSBZFil"]

	cFilBkp := cFilAnt

	// SB1
	If !Empty( oMoldura["sb1"] )

		nPosFil := aScan(aFilSB1Map, {|x| x[2] == SB1->B1_FILIAL})
		If nPosFil > 0
			cFilAnt := aFilSB1Map[nPosFil][1]
		EndIf

		SB1->(RecLock("SB1", .F.))
		OA539015M_GravaCampos( "SB1", oMoldura["sb1"], cLin, cLog )
		SB1->(MsUnlock())
		cFilAnt := cFilBkp

	EndIf

	// SB5
	If !Empty( aSB5Fil ) .And. !Empty( oMoldura["sb5"] )

		For nX := 1 To Len( aSB5Fil )
			cFilAnt := aSB5Fil[nX]

			If xFilial("SB1") != SB1->B1_FILIAL
				Loop
			EndIf

			lSB5    := SB5->(DbSeek( xFilial("SB5") + SB1->B1_COD ))

			SB5->(RecLock("SB5", !lSB5))
			OA539015M_GravaCampos( "SB5", oMoldura["sb5"], cLin, cLog )
			SB5->(MsUnlock())
		Next nX

	EndIf

	// SBZ
	If !Empty( aSBZFil ) .And. !Empty( oMoldura["sbz"] )

		For nX := 1 To Len( aSBZFil )
			cFilAnt := aSBZFil[nX]

			If xFilial("SB1") != SB1->B1_FILIAL
				Loop
			EndIf

			lSBZ    := SBZ->(DbSeek( xFilial("SBZ") + SB1->B1_COD ))

			SBZ->(RecLock("SBZ", !lSBZ))
			OA539015M_GravaCampos( "SBZ", oMoldura["sbz"], cLin, cLog )
			SBZ->(MsUnlock())
		Next nX

	EndIf

	cFilAnt := cFilBkp

Return


/*/{Protheus.doc} OA539015M_GravaCampos
Grava informações de campos
@type function
@author		Diogo Barros
@since		20/05/2026
@param cAlias	Character alias da tabela
@param aMoldura	Array de campos [{campo, nome, inicio, fim, valor}, ...]
@param cLin		Character linha do arquivo
@param cLog		Character id do log
/*/
Static Function OA539015M_GravaCampos( cAlias, aMoldura, cLin, cLog )
	Local nW     := 0
	Local cCampo := ""
	Local cColuna:= ""
	Local nIni   := 0
	Local nFim   := 0
	Local xParte := Nil
	Local xValor := Nil
	Local lTipoN := .F.
	Local cPula  := Chr(13) + Chr(10)

	For nW := 1 To Len( aMoldura )

		cCampo  := AllTrim(aMoldura[nW]["campo"])
		cColuna := aMoldura[nW]["nome"]
		nIni    := aMoldura[nW]["inicio"]
		nFim    := aMoldura[nW]["fim"]
		xParte  := SubStr( cLin, nIni, nFim )
		lTipoN  := GetSX3Cache( cCampo, "X3_TIPO") == "N"

		If lTipoN .And. !IsNumeric( xParte )
			OA539009M_GrvLog( { STR0033 + cPula + STR0034 + cLin + cPula + STR0035 + cColuna }, cLog )
			Loop
		EndIf

		xValor := &(aMoldura[nW]["valor"])
		(cAlias)->&(cCampo) := xValor

	Next nW

Return


/*/{Protheus.doc} OA539006M_MoveArquivo
Move ou exclui o arquivo conforme MV_PAR07
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Static Function OA539006M_MoveArquivo( cFile, cLog )
	Local cDesc    As Character
	Local cDestino As Character
	Local lMove    As Logical
	Local lDel     As Logical

	cDesc    := SubStr( cFile, Rat("\", cFile) + 1, Len(cFile) )
	cDestino := AllTrim(MV_PAR08) + "\"
	lDel     := MV_PAR07 == 3
	lMove    := MV_PAR07 == 2
	lOk      := .F.

	lOk := If( ( lMove .And. __CopyFile( cFile, cDestino + cDesc ) ) .Or. lDel, Ferase( cFile ) == 0, .F. )

	If lOk .And. ( lDel .Or. lMove )
		cDesc := If( lDel, STR0011, STR0012 ) + " " + cDestino
		OA539009M_GrvLog( { cDesc }, cLog )
	EndIf

Return lOk


/*/{Protheus.doc} OA539003M_DefineLayout
Definicao do modelo de leitura do arquivo.
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Static Function OA539003M_DefineLayout( cLin )

	Local lPub       As Logical
	Local l30d       As Logical
	Local lBalcao    As Logical
	Local lAtuSB1    As Logical
	Local lAtuSBZ    As Logical
	Local lAtuQtd    As Logical
	Local oDados     As Object
	Local aSB1       As Array
	Local cArqProd   As Character

	aSB1 := SB1->(FWGetArea())

	lPub       := !Empty( AllTrim( MV_PAR03 ) )
	l30d       := !Empty( AllTrim( MV_PAR04 ) )
	lBalcao    := !Empty( AllTrim( MV_PAR05 ) )
	cArqProd   := GetNewPar("MV_ARQPROD","")
	lAtuSB1    := cArqProd == "SB1"
	lAtuSBZ    := cArqProd == "SBZ"
	lAtuQtd    := MV_PAR06 == 1

	oDados             := JSonObject():New()
	oDados["itens"]    := {}
	oDados["indices"]  := {}
	oDados["sb1"]      := {}
	oDados["sb5"]      := {}
	oDados["sbz"]      := {}

	// Colunas do arquivo
	aAdd( oDados["itens"], OA539016M_CriaItem( "Item",         "B1_COD",     .F., 7, 'Val( SubStr( cLin, aItens[nX]["inicio"], aItens[nX]["fim"] ) )' ))
	aAdd( oDados["indices"], oDados["itens"][Len(oDados["itens"])] )

	aAdd( oDados["itens"], OA539016M_CriaItem( "Publico",      MV_PAR03,     lPub,    0, 'Val( SubStr( cLin, nIni, nFim ) ) / 100' ))
	aAdd( oDados["itens"], OA539016M_CriaItem( "Publico 30d",  MV_PAR04,     l30d,    0, 'Val( SubStr( cLin, nIni, nFim ) ) / 100' ))
	aAdd( oDados["itens"], OA539016M_CriaItem( "Balcao",       MV_PAR05,     lBalcao, 0, 'Val( SubStr( cLin, nIni, nFim ) ) / 100' ))

	// Campos fixos da SB5
	aAdd( oDados["itens"], OA539016M_CriaItem( "B5_FILIAL",    "B5_FILIAL",  .T., 0, 'xFilial("SB5")' ))
	aAdd( oDados["itens"], OA539016M_CriaItem( "B5_COD",       "B5_COD",     .T., 0, 'SB1->B1_COD'    ))
	aAdd( oDados["itens"], OA539016M_CriaItem( "B5_CEME",      "B5_CEME",    .T., 0, 'SB1->B1_DESC'   ))

	// Quantidade por embalagem (condicional)
	If lAtuQtd .And. lAtuSB1
		aAdd( oDados["itens"], OA539016M_CriaItem( "Qt.Peca_Emb", "B1_QE", .T., 0, 'Val( SubStr( cLin, nIni, nFim ) )' ))

	ElseIf lAtuQtd .And. lAtuSBZ
		aAdd( oDados["itens"], OA539016M_CriaItem( "BZ_FILIAL",   "BZ_FILIAL", .T., 0, 'xFilial("SBZ")'   ))
		aAdd( oDados["itens"], OA539016M_CriaItem( "BZ_COD",      "BZ_COD",    .T., 0, 'SB1->B1_COD'      ))
		aAdd( oDados["itens"], OA539016M_CriaItem( "BZ_LOCPAD",   "BZ_LOCPAD", .T., 0, 'SB1->B1_LOCPAD'   ))
		aAdd( oDados["itens"], OA539016M_CriaItem( "Qt.Peca_Emb", "BZ_QE",     .T., 0, 'Val( SubStr( cLin, nIni, nFim ) )' ))

	ElseIf !lAtuQtd
		aAdd( oDados["itens"], OA539016M_CriaItem( "Qt.Peca_Emb", "", .F., 0, '' ))
	EndIf

	oDados := OA539007M_Mapeia_Colunas( cLin, oDados )

	SB1->(FWRestArea(aSB1))

Return oDados


/*/{Protheus.doc} OA539016M_CriaItem
Cria um item de layout padrao.
@type 	function
@author	Diogo Barros
@since	20/05/2026
@param 	cNome    Nome da coluna no arquivo
@param 	cCampo   Nome do campo no Protheus
@param 	lAtivo   Campo ativo?
@param 	nTamanho Tamanho fixo (0 = usar tamanho do nome)
@param 	cValor   Expressao de valor (macrosubstituicao)
@return Object JSonObject com a estrutura do item
/*/
Static Function OA539016M_CriaItem( cNome, cCampo, lAtivo, nTamanho, cValor )
	Local oItem := JSonObject():New()
	oItem["nome"]    := cNome
	oItem["campo"]   := cCampo
	oItem["ativo"]   := lAtivo
	oItem["inicio"]  := 0
	oItem["fim"]     := 0
	oItem["tamanho"] := nTamanho
	oItem["valor"]   := cValor
Return oItem


/*/{Protheus.doc} OA539007M_Mapeia_Colunas
Mapeia as posicoes das colunas no arquivo texto
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Static Function OA539007M_Mapeia_Colunas( cLin, oDados )
	Local nX      := 0
	Local nAux    := 0
	Local aAux    := {}
	Local aCampos := {"Item", "Publico", "Publico 30d", "Balcao", "Qt.Peca_Emb" }

	For nX := 1 To Len( aCampos )
		nPos := At( aCampos[nX], cLin )

		If nPos > 0
			nIndex := aScan( oDados["itens"], {|x| Upper( x["nome"] ) == Upper( aCampos[nX] ) } )

			If nIndex > 0
				nTam := oDados["itens"][nIndex]["tamanho"]
				nTam := If( nTam > 0, nTam, Len( oDados["itens"][nIndex]["nome"] ) )

				oDados["itens"][nIndex]["inicio"] := nPos
				oDados["itens"][nIndex]["fim"]    := nTam
				nAux++
			EndIf
		EndIf
	Next nX

	oDados["tudook"] := Len( aCampos ) == nAux

	For nX := 1 To Len( oDados["itens"] )
		xItem := oDados["itens"][nX]

		If xItem["ativo"]
			If( Left( xItem["campo"], 2 ) == "B1", aAdd( oDados["sb1"], xItem), )
			If( Left( xItem["campo"], 2 ) == "B5", aAdd( oDados["sb5"], xItem), )
			If( Left( xItem["campo"], 2 ) == "BZ", aAdd( oDados["sbz"], xItem), )
			aAdd( aAux, xItem )
		EndIf
	Next nX

	oDados["itens"] := If( !Empty( aAux ), aAux, oDados["itens"] )

Return oDados

/*/{Protheus.doc} OA539001M_VldTOk
Validacao geral (arquivo, estrutura, grupos, MV_ARQPROD)
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Static Function OA539001M_VldTOk( oControle )
	Local lSX6      := !Empty( GetNewPar( "MV_ARQPROD", "") )
	Local lSchedule := oControle["schedule"]
	Local lOpen     := .F.
	Local oFile     := Nil

	oFile := FWFileReader():New( AllTrim( MV_PAR01 ) )
	lOpen := oFile:Open()
	oControle["ofile"] := oFile

	If !lOpen
		OA539010M_ExibeMensagem( lSchedule, "OA539001F", STR0007, STR0025 )
		Return .F.
	EndIf

	If !OA539008M_VldEstruturaArquivo( oControle )
		OA539010M_ExibeMensagem( lSchedule, "OA539001G", STR0008, STR0026 )
		oFile:Close()
		Return .F.
	EndIf

	If Empty( AllTrim( StrTran( MV_PAR02, "/", "" ) ) )
		OA539010M_ExibeMensagem( lSchedule, "OA539001B", STR0003, STR0022 )
		Return .F.
	EndIf

	If MV_PAR07 == 2 .And. Empty(MV_PAR08)
		OA539010M_ExibeMensagem( lSchedule, "OA539001C", STR0004, STR0023 )
		Return .F.
	EndIf

	If !lSx6
		OA539010M_ExibeMensagem( lSchedule, "OA539001E", STR0006, STR0024 )
		Return .F.
	EndIf

Return .T.


/*/{Protheus.doc} OA539008M_VldEstruturaArquivo
Validacao da estrutura do arquivo (primeiras 10 linhas)
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Static Function OA539008M_VldEstruturaArquivo( oControle )
	Local cLinha  := ""
	Local nVezes  := 0
	Local lTudoOk := .F.
	Local oFile   := oControle["ofile"]

	While ( oFile:hasLine() .And. nVezes <= 10 )
		cLinha := oFile:GetLine()
		oControle["modelo"] := OA539003M_DefineLayout( cLinha )
		lTudoOk := oControle["modelo"]["tudook"]
		nVezes += If( lTudoOk, 11, 1 )
	EndDo

Return lTudoOk


/*/{Protheus.doc} OA539005M_PreValid
Pre-validacao em tempo de digitacao (SX1)
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
@param nCampo	1=Arquivo, 2=Grupos, 3=Campos preco, 4=Diretorio destino
/*/
Function OA539005M_PreValid( nCampo )
	Local cMascara As Character
	Local cPrefixo As Character
	Local nX       As Number
	Local nErro    As Number
	Local aGrupos  As Array
	Local aAux     As Array
	Local xValue   As Variant
	Local lRet     As Logical
	Local lMove    As Logical
	Local lFileOk  As Logical
	Local lDirOk   As Logical

	xValue := Upper(AllTrim(&(ReadVar())))
	lRet   := .T.
	lMove  := nCampo == 2

	If nCampo == 1 .Or. nCampo == 4

		cMascara := If( !lMove, "*.txt|*.txt", "" )

		If nCampo == 1
			lFileOk := File( MV_PAR01 )
			If !lFileOk
				xValue := MV_PAR01 := cGetFile( cMascara, STR0015,, STR0016, .T., 0, .T., .T. )
			EndIf
			Return !Empty(xValue) .And. File( MV_PAR01 )
		Else
			lDirOk := ExistDir( MV_PAR08 )
			If !lDirOk
				xValue := MV_PAR08 := cGetFile( cMascara, STR0015,, STR0016, .T., 128, .T., .T. )
			EndIf
			Return !Empty(xValue) .And. ExistDir( MV_PAR08 )
		EndIf
	EndIf

	If nCampo == 2

		aGrupos := {}
		nErro   := 0
		aAux    := StrTokArr( AllTrim(xValue), "/" )

		For nX := 1 To Len( aAux )
			If SBM->(dbSeek( xFilial("SBM") + PadR( AllTrim(aAux[nX]), TamSx3("BM_GRUPO")[1] ) ))
				aAdd( aGrupos, SBM->BM_GRUPO )
			ElseIf !Empty( aAux[nX] )
				nErro++
			EndIf
		Next nX

		If nErro > 0
			OA539010M_ExibeMensagem( .F., "OA539005A", STR0013, STR0027 )
			Return .F.
		ElseIf Len(aGrupos) > 1
			aAux := {} ; nX := 1

			While nX <= Len(aGrupos)
				nPos := aScan( aAux, {|x| x == aGrupos[nX] } )
				If nPos <= 0
					aAdd( aAux, aGrupos[nX] )
				Else
					OA539010M_ExibeMensagem( .F., "OA539005B", STR0017 + " " + aAux[nPos], STR0028 )
					nX := Len(aGrupos) + 1
					lRet := .F.
				EndIf
				nX++
			End
			Return lRet
		EndIf
	EndIf

	If nCampo == 3

		cPrefixo := "B1_PRV1|B5_PRV2|B5_PRV3|B5_PRV4|B5_PRV5|B5_PRV6|B5_PRV7"
		lRet := lExist := ExistCPO("SX3", xValue, 2) .And. GetSX3Cache( xValue, "X3_TIPO") != Nil .And. xValue $ cPrefixo

		If lExist
			aCampos := { MV_PAR03, MV_PAR04, MV_PAR05 } ; nErro := 0

			For nX := 1 To Len( aCampos )
				nErro += If( xValue == Upper(AllTrim( aCampos[nX] )), 1, 0 )
			Next nX

			If nErro > 1
				OA539010M_ExibeMensagem( .F., "OA539005C", STR0018, STR0029 )
				Return .F.
			EndIf
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} OA539013M_CacheFiliais
Armazena informacao de filiais para SB1, SB5 e SBZ.
Respeitando modo de compartilhamento de cada tabela.
@type 	function
@author	Diogo Barros
@since	20/05/2026
@return Object JSonObject com aSB1Map, aSB5Fil, aSBZFil
/*/
Static Function OA539013M_CacheFiliais()
	Local oCache     := JSonObject():New()
	Local aFilSB1Map := {}
	Local aAllFilSB1 := If( FWModeAccess("SB1", 3) == "E", FWAllFilial(), { cFilAnt } )
	Local cFilBkp    := cFilAnt
	Local cTmpFil    := ""
	Local nX         := 0

	For nX := 1 To Len(aAllFilSB1)
		cFilAnt := aAllFilSB1[nX]
		cTmpFil := xFilial("SB1")
		If aScan(aFilSB1Map, {|y| y[2] == cTmpFil}) == 0
			aAdd(aFilSB1Map, {aAllFilSB1[nX], cTmpFil})
		EndIf
	Next nX
	cFilAnt := cFilBkp

	oCache["aSB1Map"] := aFilSB1Map
	oCache["aSB5Fil"] := If( FWModeAccess("SB5", 3) == "E", FWAllFilial(), { xFilial("SB5") })
	oCache["aSBZFil"] := If( FWModeAccess("SBZ", 3) == "E", FWAllFilial(), { xFilial("SBZ") })

Return oCache


/*/{Protheus.doc} OA539014M_ContaLinhas
Conta linhas validas do arquivo para barra de progresso.
@type 	function
@author	Diogo Barros
@since	20/05/2026
@param 	oFile Objeto FWFileReader
@return Numeric total de linhas validas
/*/
Static Function OA539014M_ContaLinhas( oFile )
	Local nTotal := 0
	Local cLin   := ""

	While ( oFile:hasLine() )
		cLin := oFile:GetLine()
		If !Empty(cLin)
			nTotal++
		EndIf
	EndDo
Return nTotal


/*/{Protheus.doc} OA539011M_SeparaGrupo
Separa os grupos informados no MV_PAR02
@type function
@author Jesse Augusto
@since 16/10/2025
@version 12.1.2610
/*/
Static Function OA539011M_SeparaGrupo()
	Local nX      As Numeric
	Local aGrupos As Array

	aGrupos := {}
	aAux    := StrTokArr( AllTrim(MV_PAR02), "/" )

	For nX := 1 To Len( aAux )
		If !Empty( AllTrim( aAux[nX] ) )
			aAdd( aGrupos, AllTrim( aAux[nX] ) )
		EndIf
	Next nX

Return aGrupos


/*/{Protheus.doc} OA539009M_GrvLog
Grava log na tabela VQL
@type function
@author Jesse Augusto
@since 15/10/2025
@version 12.1.2610
/*/
Static Function OA539009M_GrvLog( aMsg, cId )
	Local oLogger   As Object
	Local jLog      As JSon
	Local jItem     As JSon
	Local aValor    As Array
	Local lSchedule As Logical
	Local nX        As Numeric

	Default cId  := ""
	Default aMsg := {}

	lSchedule := FWGetRunSchedule()

	jLog               := JSonObject():New()
	jLog["geral"]      := {}
	jLog["parametros"] := {}
	jLog["mensagem"]   := {}

	jItem              := JSonObject():New()
	jItem["MV_PAR01"]  := AllTrim( MV_PAR01 )
	jItem["MV_PAR02"]  := AllTrim( MV_PAR02 )
	jItem["MV_PAR03"]  := AllTrim( MV_PAR03 )
	jItem["MV_PAR04"]  := AllTrim( MV_PAR04 )
	jItem["MV_PAR05"]  := AllTrim( MV_PAR05 )
	jItem["MV_PAR06"]  := AllTrim( MV_PAR06 )
	jItem["MV_PAR07"]  := MV_PAR07
	jItem["MV_PAR08"]  := AllTrim( MV_PAR08 )
	aAdd( jLog["parametros"], jItem )

	jItem                  := JSonObject():New()
	jItem["EMPRESA"]       := cEmpAnt
	jItem["FILIAL"]        := cFilAnt
	jItem["USUARIO"]       := cUserName
	jItem["MODE_EXECUCAO"] := If( lSchedule, "SCHEDULE", "MANUAL" )
	aAdd( jLog["geral"], jItem )

	For nX := 1 To Len( aMsg )
		aAdd( jLog["mensagem"], aMsg[nX] )
	Next nX

	aValor := {}
	aAdd( aValor, {"VQL_AGROUP", "OFIA539"                                   })
	aAdd( aValor, {"VQL_FILORI", xFilial("VQL")                              })
	aAdd( aValor, {"VQL_DATAI" , dDatabase                                   })
	aAdd( aValor, {"VQL_DATAF" , dDatabase                                   })
	aAdd( aValor, {"VQL_HORAI" , Val( StrTran( Left( Time(), 5), ":", "" ) ) })
	aAdd( aValor, {"VQL_HORAF" , Val( StrTran( Left( Time(), 5), ":", "" ) ) })
	aAdd( aValor, {"VQL_MSGLOG", jLog:ToJSon()                               })

	If !Empty(cId)
		aAdd( aValor, {"VQL_CODVQL", cId })
	EndIf

	oLogger := DMS_Logger():New()

Return oLogger:LogToTable( aValor )


/*/{Protheus.doc} OA539010M_ExibeMensagem
Log + FMX_HELP
@type function
@author Jesse Augusto
@since 16/10/2025
@version 12.1.2610
/*/
Static Function OA539010M_ExibeMensagem( lSchedule, cLabel, cMsg, cSolucao )

	OA539009M_GrvLog( { cMsg, cSolucao } )

	If !lSchedule
		FMX_HELP( cLabel, cMsg, cSolucao )
	EndIf

Return


/*/{Protheus.doc} OA539012J_MontaJsonDeItensNaoImportados
Monta JSON com itens nao encontrados para log na VQL
@type function
@author Renan Migliaris
@since 25/11/2025
/*/
Static Function OA539012J_MontaJsonDeItensNaoImportados(aItens)
	Local jJson    := JSonObject():New()
	Local jAuxJson := Nil
	Local nX       := 0

	jJson['notFoundItems'] := {}

	For nX := 1 To Len(aItens)
		jAuxJson := JSonObject():New()
		jAuxJson["groupCode"] := AllTrim(aItens[nX][1])
		jAuxJson["itemId"]    := AllTrim(aItens[nX][2])
		aAdd(jJson['notFoundItems'], jAuxJson)
		freeObj(jAuxJson)
	Next nX

Return jJson:ToJSon()
