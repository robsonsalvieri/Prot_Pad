#INCLUDE "PROTHEUS.CH"
#include 'TOPCONN.ch'
#INCLUDE "ofia537.ch"

static oStatSB5
static oStatSBZ

/*/{Protheus.doc} OFIA537
Entry point da rotina de importacao de arquivo texto PRI RM
@author		Guilherme Santos
@since		05/09/2025
@version	12.1.2610
/*/
Function OFIA537()
	Local aArea 	:= FwGetArea()
	Local cPerg		:= "OFIA537"
	Local oLogExec	:= DMS_Logger():New("OFIA537_" + dtos(ddatabase) + "_" + StrTran(Time(), ":", "") + ".LOG")
	Local lSchedule	:= FWGetRunSchedule()
	Local oFile     := Nil
	Local aHeader 	:= {}
	Local oSay 		:= NIL 

	Private cIdLog  := ""

	If lSchedule		
		If OA537008M_VldTudoOk( @oFile, @aHeader, lSchedule )
			cIdLog := OA537010M_GrvLog()
			OA537001L_ProcessaTXT( oLogExec, oFile, aHeader, oSay, lSchedule )
		EndIf
	Else				
		If Pergunte(cPerg, .T.)
			If OA537008M_VldTudoOk( @oFile, @aHeader, lSchedule )
				cIdLog := OA537010M_GrvLog()
				FWMsgRun(,{|oSay| OA537001L_ProcessaTXT( oLogExec, oFile, aHeader, oSay, lSchedule )}, STR0007, STR0008 + AllTrim(MV_PAR01))
			EndIf
		EndIf
	EndIF

	FwRestArea(aArea)

Return NIL


/*/{Protheus.doc} SchedDef
Funcao padrao Scheduler
@author		Guilherme Santos
@since		10/09/2025
@version	12.1.2610
/*/
Static Function SchedDef()
	Local aParam := {}
	Aadd(aParam, "P"      ) // 01 - Tipo: "P" para Processo
	Aadd(aParam, "OFIA537") // 02 - Grupo de perguntas (SX1)
	Aadd(aParam, ""        ) // 03 - Alias (apenas para Relatorio)
	Aadd(aParam, {}        ) // 04 - Array de ordens (apenas para Relatorio)
	Aadd(aParam, ""        ) // 05 - Titulo (apenas para Relatorio)
	Aadd(aParam, ""        ) // 06 - Layout de impressao (apenas para Relatorio)
	Aadd(aParam, .F.       ) // 07 - Permite agendamento sempre ativo? (LIB 20260413)
	Aadd(aParam, .F.       ) // 08 - Permite agendamento por filiais? (LIB 20260413)
Return aParam


/*/{Protheus.doc} OA537001L_ProcessaTXT
Orquestra a importacao do arquivo texto.
Delega gravacao, contagem e movimentacao para funcoes especificas.
@author		Guilherme Santos
@since		11/09/2025
@version	12.1.2610
/*/
Static Function OA537001L_ProcessaTXT( oLogExec, oFile, aHeader, oSay, lSchedule )

	Local cNomeArq	:= OA537006L_SeparaNomeArq(AllTrim(MV_PAR01))
	Local cLinha 	:= ""
	Local cItem 	:= ""
	Local cDescri	:= ""
	Local nQtdEmb	:= 0
	Local aItNoEx 	:= {}
	Local aListGrupo:= OA537004L_ListaGruposSB1()
	Local cAliasQry	:= ""

	Local aFilSB5	:= OA537005L_RetornaFiliais("SB5")
	Local aFilSBZ	:= OA537005L_RetornaFiliais("SBZ")
	Local aFilSB1	:= OA537005L_RetornaFiliais("SB1")

	Local cFilBkp	:= cFilAnt
	Local nTotal	:= 0
	Local nAtual	:= 0

	Local lA537GRV	:= ExistBlock("OFA537GR")
	Local lA537FIM	:= ExistBlock("OFA537FI")

	// Cache de parametros (calculados uma vez)
	Local cArqProd	:= GetNewPar("MV_ARQPROD","")
	Local lSB1Prod	:= cArqProd == "SB1"
	Local lSBZProd	:= cArqProd == "SBZ"
	Local lGrvQtd	:= MV_PAR07 == 1

	// Cache de posicoes dos campos de preco na SB5
	Local aCpoPreco	:= OA537011M_PosicaoCampos()

	// Posicoes das colunas no header do arquivo
	Local aPosCol	:= OA537012M_PosicaoHeader(aHeader)
	Local nPosItem	:= aPosCol[1]
	Local nPosDesc	:= aPosCol[2]
	Local nPosQtd	:= aPosCol[3]
	Local nPosPAR03	:= aPosCol[4]
	Local nPosPAR04	:= aPosCol[5]
	Local nPosPAR05	:= aPosCol[6]
	Local nPosPAR06	:= aPosCol[7]

	Local oStatement := Nil
	Local aVlrPrecos := {}

	// Alterações para mostrar a quantidade de itens processados
	Local cMsg := ""
	Local nErros := 0
	Local nOk := 0
	Local nX := 0
		
	If !lSchedule
		nTotal := OA537013M_ContaLinhas( oFile )			
		oFile:Close()
		oFile := FWFileReader():New(AllTrim(MV_PAR01))
		oFile:Open()
	EndIf
		
	DbSelectArea("SB1")
	DbSetOrder(7)		// B1_FILIAL + B1_GRUPO + B1_CODITE
	DbSelectArea("SB5")
	DbSetOrder(1)		// B5_FILIAL + B5_COD
	DbSelectArea("SBZ")
	DbSetOrder(1)		// BZ_FILIAL + BZ_COD
	
	oStatement := OA537014M_MontaQuery( aFilSB1, aListGrupo )
	oStatSB5 := OA5370195_MontaQuerySB5()
	oStatSBZ := OA5370205_MontaQuerySBZ()
	
	While ( oFile:hasLine())

		cLinha := oFile:GetLine()

		If Substr(cLinha, 1, 10) == "----------" .OR. Empty(cLinha) .Or. At("Cod.Item", cLinha) > 0
			Loop
		EndIf

		nAtual++

		// Exibe progresso de mil em mil
		If !lSchedule .And. (nAtual == 1 .Or. nAtual % 1000 == 0 .Or. nAtual == nTotal)
			oSay:SetText(STR0034 + cValToChar(nAtual) + " - " + cValToChar(nTotal))
			ProcessMessages()
		EndIf

		// Extrai dados da linha
		cItem 	:= Substr(cLinha, aHeader[nPosItem][03], aHeader[nPosItem][04])
		cDescri	:= Substr(cLinha, aHeader[nPosDesc][03], aHeader[nPosDesc][04])
		nQtdEmb	:= Val(Substr(cLinha, aHeader[nPosQtd][03], aHeader[nPosQtd][04]))

		aVlrPrecos := {;
			Val(Substr(cLinha, aHeader[nPosPAR03][03], aHeader[nPosPAR03][04])),;
			Val(Substr(cLinha, aHeader[nPosPAR04][03], aHeader[nPosPAR04][04])),;
			Val(Substr(cLinha, aHeader[nPosPAR05][03], aHeader[nPosPAR05][04])),;
			Val(Substr(cLinha, aHeader[nPosPAR06][03], aHeader[nPosPAR06][04]));
		}

		// Executa query apenas com o item variavel
		oStatement:SetString(4, cItem)
		cAliasQry := oStatement:OpenAlias()

		If ((cAliasQry)->NREGSB1) <= 0
			aAdd(aItNoEx, {cItem, cDescri})
			(cAliasQry)->(DbCloseArea())
			Loop
		EndIf

		While !(cAliasQry)->(Eof())
			SB1->(DbGoTo((cAliasQry)->NREGSB1))
			// Grava precos na SB5
			OA537015M_GravaSB5( aFilSB5, cDescri, aVlrPrecos, aCpoPreco, cFilBkp )
			// Grava quantidade por embalagem (SB1 ou SBZ)
			If lGrvQtd
				OA537016M_GravaQtdEmb( lSB1Prod, lSBZProd, nQtdEmb, aFilSB1, aFilSBZ, cFilBkp )
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo

		(cAliasQry)->(DbCloseArea())

		If lA537GRV
			ExecBlock("OFA537GR", .F., .F., {cLinha})
		EndIf
	EndDo

	// Libera recursos
	oStatement:Destroy()
	fwFreeObj(oStatement)
	oFile:Close()

	// Log itens nao encontrados
	If Len(aItNoEx) > 0
		OA537010M_GrvLog( {OA537010J_MontaJsonDeItensNaoImportados(aItNoEx)}, cIdLog, 'IMPORT_ERRORS' )
	EndIf

	nErros := Len(aItNoEx)
	nOk := nTotal - nErros
	
	cMsg := STR0035 + " " + CRLF //"Resumo do processamento:"
	cMsg += STR0036 + " " + AllTrim(cValToChar(nTotal)) + CRLF //"Total de registros:"
	cMsg += STR0037 + " " + AllTrim(cValToChar(nOk)) + CRLF //"Registros atualizados:"
	cMsg += STR0038 + " " + AllTrim(cValToChar(nErros)) //"Registros não atualizados:"

	If !lSchedule
		FWAlertInfo(cMsg, "OFIA537")

		If nErros == 0
			FWAlertSuccess(STR0039, "OFIA537") //"Processamento concluído com sucesso"
		Else
			cMsg := ""
			For nX := 1 to Len(aItNoEx)
				cMsg += STR0040 + " " + AllTrim(aItNoEx[nX][1]) + ' - ' + AllTrim(aItNoEx[nX][2]) + CRLF //"Produto não encontrado:"
			Next
			//"Processamento não foi concluído corretamente."
			//"Os seguintes produtos não foram encontrados:"
			FMX_HELP("OFIA537", STR0041 + CRLF + STR0042 + CRLF + cMsg)
		EndIf
	EndIf

	// Pos-processamento do arquivo (mover/apagar)
	OA537017M_PosProcessaArquivo( cNomeArq )
	OA537010M_GrvLog( {STR0026}, cIdLog )

	If lA537FIM
		ExecBlock("OFA537FI", .F., .F.)
	EndIf

Return Nil


/*/{Protheus.doc} OA537011M_PosicaoCampos
Retorna array com posicao e flag dos campos de preco na SB5.
@author		Diogo Barros
@since		20/05/2026
@return		Array {nPosCp03, nPosCp04, nPosCp05, nPosCp06, lField03, lField04, lField05, lField06}
/*/
Static Function OA537011M_PosicaoCampos()
	Local nPosCp03	:= SB5->(FieldPos(AllTrim(MV_PAR03)))
	Local nPosCp04	:= SB5->(FieldPos(AllTrim(MV_PAR04)))
	Local nPosCp05	:= SB5->(FieldPos(AllTrim(MV_PAR05)))
	Local nPosCp06	:= SB5->(FieldPos(AllTrim(MV_PAR06)))
Return {nPosCp03, nPosCp04, nPosCp05, nPosCp06, nPosCp03 > 0, nPosCp04 > 0, nPosCp05 > 0, nPosCp06 > 0}



/*/{Protheus.doc} OA537012M_PosicaoHeader
Retorna array com as posicoes das colunas do header do arquivo.
@author		Diogo Barros
@since		20/05/2026
@return		Array {nPosItem, nPosDesc, nPosQtd, nPosPAR03, nPosPAR04, nPosPAR05, nPosPAR06}
/*/
Static Function OA537012M_PosicaoHeader(aHeader)
Return {;
	aScan(aHeader, {|x| x[01] == "B5_COD"          .AND. x[02] == "Cod.Item"         }),;
	aScan(aHeader, {|x| x[01] == "B5_CEME"         .AND. x[02] == "Descricao_Item"   }),;
	aScan(aHeader, {|x| x[01] == "B1_QE"           .AND. x[02] == "Qt.Peca_Emb."     }),;
	aScan(aHeader, {|x| AllTrim(x[01]) == AllTrim(MV_PAR03) .AND. x[02] == "P.Dealer_Contrato"}),;
	aScan(aHeader, {|x| AllTrim(x[01]) == AllTrim(MV_PAR04) .AND. x[02] == "P.Dealer_Normal"  }),;
	aScan(aHeader, {|x| AllTrim(x[01]) == AllTrim(MV_PAR05) .AND. x[02] == "P.Balcao_Contrato"}),;
	aScan(aHeader, {|x| AllTrim(x[01]) == AllTrim(MV_PAR06) .AND. x[02] == "P.Balcao_Normal"  });
}


/*/{Protheus.doc} OA537015M_GravaSB5
Grava precos na SB5
@author		Diogo Barros
@since		20/05/2026
@param		aFilSB5		Array de filiais da SB5
@param		cDescri		Descricao do item
@param		aVlrPrecos	Array {Dealer_Contrato, Dealer_Normal, Balcao_Contrato, Balcao_Normal}
@param		aCpoPreco	Array com posicoes e flags dos campos (OA537011M_PosicaoCampos)
@param		cFilBkp		Filial original para restauracao
/*/
Static Function OA537015M_GravaSB5( aFilSB5, cDescri, aVlrPrecos, aCpoPreco, cFilBkp )
	
	Local nFilSB5 := 0
	Local cAliasQry := ""

	For nFilSB5 := 1 To Len(aFilSB5)

		If SB1->B1_FILIAL != aFilSB5[nFilSB5][02]
			Loop
		EndIf

		//cFilAnt := aFilSB5[nFilSB5][01]

		oStatSB5:SetString(1, aFilSB5[nFilSB5][03])
		oStatSB5:SetString(2, SB1->B1_COD)

		cAliasQry := oStatSB5:OpenAlias()
		if !(cAliasQry)->(Eof()) .and. (cAliasQry)->NREGSB5 > 0
			SB5->(DbGoTo((cAliasQry)->NREGSB5))
			RecLock("SB5", .F.)
		Else
			RecLock("SB5", .T.)
			SB5->B5_FILIAL := aFilSB5[nFilSB5][03]
			SB5->B5_COD    := SB1->B1_COD
			SB5->B5_CEME   := cDescri
		Endif
		(cAliasQry)->(DbCloseArea())

		// aCpoPreco: [1-4]=FieldPos, [5-8]=lField
		If aCpoPreco[5]
			SB5->(FieldPut(aCpoPreco[1], aVlrPrecos[1]))
		EndIf
		If aCpoPreco[6]
			SB5->(FieldPut(aCpoPreco[2], aVlrPrecos[2]))
		EndIf
		If aCpoPreco[7]
			SB5->(FieldPut(aCpoPreco[3], aVlrPrecos[3]))
		EndIf
		If aCpoPreco[8]
			SB5->(FieldPut(aCpoPreco[4], aVlrPrecos[4]))
		EndIf

		SB5->(MsUnlock())
		//cFilAnt := cFilBkp

	Next nFilSB5

Return


/*/{Protheus.doc} OA537016M_GravaQtdEmb
Grava quantidade por embalagem na SB1 ou SBZ conforme MV_ARQPROD.
@author		Diogo Barros
@since		20/05/2026
@param		lSB1Prod	.T. se MV_ARQPROD = "SB1"
@param		lSBZProd	.T. se MV_ARQPROD = "SBZ"
@param		nQtdEmb		Quantidade por embalagem
@param		aFilSB1		Array de filiais da SB1
@param		aFilSBZ		Array de filiais da SBZ
@param		cFilBkp		Filial original para restauracao
/*/
Static Function OA537016M_GravaQtdEmb( lSB1Prod, lSBZProd, nQtdEmb, aFilSB1, aFilSBZ, cFilBkp )
	
	Local nFil 		:= 0
	//Local nPosFil	:= 0
	Local cAliasQry := ""

	If lSB1Prod

		//// Ajusta cFilAnt para a filial do registro SB1 posicionado
		//nPosFil := aScan(aFilSB1, {|x| x[02] == SB1->B1_FILIAL})
		//If nPosFil > 0
		//	cFilAnt := aFilSB1[nPosFil][01]
		//EndIf

		RecLock("SB1", .F.)
		SB1->B1_QE := nQtdEmb
		SB1->(MsUnlock())
		//cFilAnt := cFilBkp

	ElseIf lSBZProd
		
		For nFil := 1 To Len(aFilSBZ)
			If SB1->B1_FILIAL != aFilSBZ[nFil][02]
				Loop
			EndIf

			//cFilAnt := aFilSBZ[nFil][01]

			oStatSBZ:SetString(1, aFilSBZ[nFil][03])
			oStatSBZ:SetString(2, SB1->B1_COD)

			cAliasQry := oStatSBZ:OpenAlias()
			if !(cAliasQry)->(Eof()) .and. (cAliasQry)->NREGSBZ > 0
				SBZ->(DbGoTo((cAliasQry)->NREGSBZ))
				RecLock("SBZ", .F.)
			Else
				RecLock("SBZ", .T.)
				SBZ->BZ_FILIAL := aFilSBZ[nFil][03]
				SBZ->BZ_COD    := SB1->B1_COD
				SBZ->BZ_LOCPAD := SB1->B1_LOCPAD
			Endif
			(cAliasQry)->(DbCloseArea())

			SBZ->BZ_QE := nQtdEmb
			SBZ->(MsUnlock())
			//cFilAnt := cFilBkp
		Next nFil
	EndIf

Return


/*/{Protheus.doc} OA537017M_PosProcessaArquivo
Executa pos-processamento do arquivo (mover ou apagar) conforme MV_PAR08.
@author		Diogo Barros
@since		20/05/2026
/*/
Static Function OA537017M_PosProcessaArquivo( cNomeArq )
	Local nRetorno := 0

	Do Case
	Case MV_PAR08 == 2	// Mover Arquivo
		OA537010M_GrvLog( { STR0012 + AllTrim(MV_PAR09) + "\" + cNomeArq }, cIdLog )

		If File(MV_PAR01)
			If __CopyFile(AllTrim(MV_PAR01), AllTrim(MV_PAR09) + "\" + cNomeArq)
				FT_FUSE()
				nRetorno := FERASE(AllTrim(MV_PAR01))
				If nRetorno == -1
					OA537010M_GrvLog( { STR0014 }, cIdLog )
				EndIf
			Else
				OA537010M_GrvLog( { STR0015 }, cIdLog )
			EndIf
		EndIf

	Case MV_PAR08 == 3	// Apagar Arquivo
		OA537010M_GrvLog( { STR0013 + AllTrim(MV_PAR01) }, cIdLog )
		nRetorno := FERASE(AllTrim(MV_PAR01))
		If nRetorno == -1
			OA537010M_GrvLog( { STR0014 + MV_PAR01 }, cIdLog )
		EndIf

	EndCase
Return


/*/{Protheus.doc} OA537013M_ContaLinhas
Conta linhas validas do arquivo (para ProcRegua).
@author		Diogo Barros
@since		20/05/2026
@param		oFile, Objeto, FWFileReader
@return		nTotal, Numeric, Total de linhas validas
/*/
Static Function OA537013M_ContaLinhas( oFile )
	Local nTotal := 0
	Local cLinha := ""

	While ( oFile:hasLine())
		cLinha := oFile:GetLine()
		If !(Substr(cLinha, 1, 10) == "----------" .OR. Empty(cLinha))
			nTotal++
		EndIf
	EndDo

Return nTotal


/*/{Protheus.doc} OA537014M_MontaQuery
Monta Query
@author		Diogo Barros
@since		20/05/2026
@param		aFilSB1, Array de filiais da SB1
@param		aListGrupo, Array de grupos
@return		oStatement, Object, FWExecStatement pronto para uso
/*/
Static Function OA537014M_MontaQuery( aFilSB1, aListGrupo )
	Local cQuery 	 := ""
	Local oStatement := Nil
	Local aFilSB1In	 := {}
	Local nX		 := 0

	// Extrai xFilial unicas para o SetIn
	For nX := 1 To Len(aFilSB1)
		If aScan(aFilSB1In, {|y| y == aFilSB1[nX][02]}) == 0
			aAdd(aFilSB1In, aFilSB1[nX][02])
		EndIf
	Next nX

	cQuery := " SELECT SB1.R_E_C_N_O_ NREGSB1"           + CRLF
	cQuery += " FROM "	+ RetSqlName("SB1") + " SB1"       + CRLF
	cQuery += " WHERE  SB1.B1_FILIAL IN ( ? )"             + CRLF
	cQuery += " AND    SB1.B1_GRUPO  IN ( ? )"             + CRLF
	cQuery += " AND    SB1.D_E_L_E_T_ = ?"                 + CRLF
	cQuery += " AND    SB1.B1_CODITE = ?"

	oStatement := FWExecStatement():New(cQuery)
	oStatement:SetIn(1, aFilSB1In)
	oStatement:SetIn(2, aListGrupo)
	oStatement:SetString(3, ' ')

Return oStatement


/*/{Protheus.doc} OA5370195_MontaQuerySB5
Monta Query
@author		Rubens Takahashi
@since		20/05/2026
@return		oStatement, Object, FWExecStatement pronto para uso
/*/
Static Function OA5370195_MontaQuerySB5()
	Local cQuery 	 := ""
	Local oStatement := Nil

	cQuery := " SELECT SB5.R_E_C_N_O_ NREGSB5"
	cQuery += " FROM "	+ RetSqlName("SB5") + " SB5"
	cQuery += " WHERE  SB5.B5_FILIAL = ( ? )"
	cQuery += " AND    SB5.B5_COD = ?"
	cQuery += " AND    SB5.D_E_L_E_T_ = ?"

	oStatement := FWExecStatement():New(cQuery)
	oStatement:SetString(3, ' ')

Return oStatement

/*/{Protheus.doc} OA5370205_MontaQuerySBZ
Monta Query
@author		Rubens Takahashi
@since		20/05/2026
@return		oStatement, Object, FWExecStatement pronto para uso
/*/
Static Function OA5370205_MontaQuerySBZ()
	Local cQuery 	 := ""
	Local oStatement := Nil

	cQuery := " SELECT SBZ.R_E_C_N_O_ NREGSBZ"
	cQuery += " FROM "	+ RetSqlName("SBZ") + " SBZ"
	cQuery += " WHERE  SBZ.BZ_FILIAL = ( ? )"
	cQuery += " AND    SBZ.BZ_COD = ?"
	cQuery += " AND    SBZ.D_E_L_E_T_ = ?"

	oStatement := FWExecStatement():New(cQuery)
	oStatement:SetString(3, ' ')

Return oStatement

/*/{Protheus.doc} OA537002L_GetPosCab
Retorna array com os campos e as posicoes no Arquivo texto
@author		Guilherme Santos
@since		11/09/2025
@version	12.1.2610
/*/
Static Function OA537002L_GetPosCab(cLinha)
	Local aHeader	:= {}
	Local nHeader	:= 0
	Local nPosTxt	:= 0
	Local cField	:= ""
	Local nLenFld	:= 0
	local cLinhaBkp := ''

	cLinhaBkp := cLinha

	if ValType(cLinha) == "C"
		cLinha := noAcento(cLinha)
	endif

	if cLinha == nil .or. empty(cLinha)
		cLinha := cLinhaBkp
		cLinha := noAcento(cLinha)
	endif

	Aadd(aHeader, {"B5_COD",  "Cod.Item",           0, 0})
	Aadd(aHeader, {"B5_CEME", "Descricao_Item",     0, 0})
	Aadd(aHeader, {"B1_QE",   "Qt.Peca_Emb.",       0, 0})
	Aadd(aHeader, {"BZ_QE",   "Qt.Peca_Emb.",       0, 0})
	Aadd(aHeader, {MV_PAR03,  "P.Dealer_Contrato",  0, 0})
	Aadd(aHeader, {MV_PAR04,  "P.Dealer_Normal",    0, 0})
	Aadd(aHeader, {MV_PAR05,  "P.Balcao_Contrato",  0, 0})
	Aadd(aHeader, {MV_PAR06,  "P.Balcao_Normal",    0, 0})

	For nHeader := 1 to Len(aHeader)

		cField  := aHeader[nHeader][2]
		nPosTxt := At(cField, cLinha)

		If nPosTxt <= 0
			If ValType( cLinha ) != "U" .And. ValType( cLinha ) != NIL
				cAux := cLinha
				If ValType( cAux ) == "C"
					nPosTxt := At( cField, cAux )
				EndIf
			EndIf
		EndIf

		if nPosTxt > 0
			For nLenFld := nPosTxt + Len(cField) to Len(cLinha)
				If !Empty(Substr(cLinha, nLenFld, 1))
					Exit
				EndIf
			Next nLenFld

			aHeader[nHeader][3] := nPosTxt
			aHeader[nHeader][4] := nLenFld - 1 - nPosTxt
		endif

	Next nHeader

Return aHeader


/*/{Protheus.doc} OA537003L_ValidaCab
Valida o Header do Arquivo Texto
@author		Guilherme Santos
@since		11/09/2025
@version	12.1.2610
/*/
Static Function OA537003L_ValidaCab(aHeader, cFields)
	Local lRetorno	:= .T.
	Local nHeader	:= 0

	For nHeader := 1 to Len(aHeader)
		If aHeader[nHeader][03] == 0 .OR. aHeader[nHeader][04] == 0
			lRetorno := .F.
			cFields += aHeader[nHeader][02] + "|"
		EndIf
	Next nHeader

Return lRetorno


/*/{Protheus.doc} OA537007M_CheckFileOk
Validacao preliminar da estrutura do arquivo
@author		Jesse Augusto
@since		02/10/2025
@version	12.1.2610
/*/
Static Function OA537007M_CheckFileOk( oFile, aHeader )
	Local cLinha    := ""
	Local cFields   := ""
	Local cColuna   := "Cod.Item"
	Local nLimite   := 0
	Local lContinue := .F.

	While ( oFile:hasLine() .And. nLimite <= 10 )
		cLinha := oFile:GetLine()
		nPosIt := At( cColuna, cLinha )
		nLimite++

		If nPosIt <= 0
			Loop
		EndIf

		aHeader   := OA537002L_GetPosCab( cLinha )
		lContinue := OA537003L_ValidaCab( aHeader, @cFields )

		If !lContinue
			OA537010M_GrvLog( { STR0005 + cFields }, cIdLog )
		EndIf

		nLimite := 11
	EndDo

Return lContinue

/*/{Protheus.doc} OA537018M_ExibeMensagem
Controla emissao de mensagem: sempre grava log, exibe FMX_HELP se nao for Schedule.
@author		Diogo Barros
@since		20/05/2026
@param		lSchedule	.T. se execucao via Schedule
@param		cLabel		Identificador do help
@param		cMsg		Mensagem principal
@param		cSolucao	Mensagem de solucao
/*/
Static Function OA537018M_ExibeMensagem( lSchedule, cLabel, cMsg, cSolucao )
	OA537010M_GrvLog( { cMsg, cSolucao },, STR0033 )
	If !lSchedule
		FMX_HELP( cLabel, chr(13) + chr(10) + cMsg, cSolucao )
	EndIf
Return


/*/{Protheus.doc} OA537008M_VldTudoOk
Validacao geral (arquivo, grupos, parametro MV_ARQPROD)
@author		Jesse Augusto
@since		02/10/2025
@version	12.1.2610
/*/
Static Function OA537008M_VldTudoOk( oFile, aHeader, lSchedule )
	Local lSX6 := .F.

	If Empty( Alltrim(StrTran( MV_PAR02, "/", "" )) )
		OA537018M_ExibeMensagem( lSchedule, "OA537008A", STR0018, STR0028 )
		Return .F.
	EndIf

	lSx6 := FWSX6Util():ExistsParam( "MV_ARQPROD" ) .And. !Empty( GetNewPar( "MV_ARQPROD", "") )

	If !lSx6
		OA537018M_ExibeMensagem( lSchedule, "OA537008C", STR0019, STR0029 )
		Return .F.
	EndIf

	oFile := FWFileReader():New(AllTrim(MV_PAR01))
	lOpen := oFile:Open()

	If !lOpen .Or. !OA537007M_CheckFileOk( oFile, @aHeader )
		If !lOpen
			OA537018M_ExibeMensagem( lSchedule, "OA537008D", STR0017, STR0030 )
		Else
			OA537018M_ExibeMensagem( lSchedule, "OA537008E", STR0005, STR0031 )
			oFile:Close()
		EndIf
		Return .F.
	EndIf
Return .T.


/*/{Protheus.doc} OA537VlGrp
Validacao dos Grupos de Produtos informados
@author		Guilherme Santos
@since		17/09/2025
@version	12.1.2610
/*/
Function OA537VlGrp()
	Local aGrupos	:= {}
	Local aArea		:= GetArea()
	Local aAreaSBM	:= SBM->(GetArea())
	Local cGrpInv	:= ""
	Local nGrupo	:= 0
	Local lRetorno 	:= .T.

	If !Empty(MV_PAR02)
		aGrupos := StrTokArr(MV_PAR02, "/")

		DbSelectArea("SBM")
		DbSetOrder(1)

		For nGrupo := 1 to Len(aGrupos)
			If !Empty(aGrupos[nGrupo]) .And. !SBM->(DBSeek(xFilial("SBM") + aGrupos[nGrupo]))
				cGrpInv += aGrupos[nGrupo] + If(nGrupo < Len(aGrupos), " / ", "")
				lRetorno := .F.
			EndIf
		Next nGrupo

		If !lRetorno
			FMX_HELP( "OA537VlGrp", chr(13) + chr(10) + STR0006 + cGrpInv, STR0027 )
		EndIf
	EndIf

	RestArea(aAreaSBM)
	RestArea(aArea)
Return lRetorno


/*/{Protheus.doc} OA537009M_VldFldOk
Validacao do conteudo do campo digitado na SX1
@author		Jesse Augusto
@since		02/10/2025
@version	12.1.2610
/*/
Function OA537009M_VldFldOk(nOpc)
	Local cMascara := ""
	Local xValue   := Upper(Alltrim(&(ReadVar())))
	Local aAux     := {}
	Local nX       := 0
	Local nErro    := 0
	Local lTudoOk  := .T.
	Local lMove    := nOpc == 2

	If ( nOpc == 1 .Or. nOpc == 3 )

		cMascara := If( !lMove, "*.txt|*.txt", "" )

		If nOpc == 1
			If !File( MV_PAR01 )
				xValue := MV_PAR01 := cGetFile( cMascara, STR0024,, STR0025, .T., 0, .T., .T. )
			EndIf
			lTudoOk := File( MV_PAR01 )
		Else
			If !ExistDir( MV_PAR09 )
				xValue := MV_PAR09 := cGetFile("", STR0024,, STR0025, .T., 128, .T., .T. )
			EndIf
			lTudoOk := ExistDir( MV_PAR09 )
		EndIf

		Return !Empty(xValue) .And. lTudoOk
	EndIf

	If nOpc == 2
		lTudoOk := ExistCPO('SX3', xValue, 2) .And. GetSX3Cache( xValue, "X3_TIPO") != Nil .And. Left( xValue, 3) == "B5_"

		If !lTudoOk
			Return .F.
		EndIf

		aAux := { MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06 }

		For nX := 1 To Len( aAux )
			nErro += If( Upper(Alltrim( xValue )) == Upper(Alltrim( aAux[nX] )), 1, 0 )
		Next nX

		If nErro > 1
			FMX_HELP( "OA537009A", chr(13) + chr(10) + STR0021, STR0032 )
			Return .F.
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} OA537004L_ListaGruposSB1
Retorna array simples com os grupos informados no MV_PAR02
@author		Jesse Augusto
@since		02/10/2025
@version	12.1.2610
/*/
Static Function OA537004L_ListaGruposSB1()
	Local nX       := 0
	Local aAux     := {}
	Local aValores := StrTokArr( AllTrim(MV_PAR02), "/" )

	For nX := 1 To Len( aValores )
		If !Empty( aValores[nX] )
			aAdd( aAux, aValores[nX] )
		EndIf
	Next nX
Return aAux

/*/{Protheus.doc} OA537005L_RetornaFiliais
Retorna as Filiais para gravacao da tabela informada.
Respeita o modo de compartilhamento de cada tabela.
@author		Guilherme Santos
@since		12/09/2025
@version	12.1.2610
@param		cTabela	Nome da tabela (ex: "SB1", "SB5", "SBZ")
@return		Array { {cFilAnt, xFilial("SB1"), xFilial(cTabela)}, ... }
/*/

Static Function OA537005L_RetornaFiliais(cTabela)
	Local aRetorno 	:= {}
	Local cFilBkp	:= cFilAnt
	Local nFil		:= 0
	Local oAuxFil	:= DMS_FilialHelper():New()
	Local aFiliais  := oAuxFil:GetAllFilEmpresa(.t.)

	For nFil := 1 to Len(aFiliais)
		cFilAnt := aFiliais[nFil]
		If AScan(aRetorno, {|x| x[02] == xFilial("SB1") .AND. x[03] == xFilial(cTabela)}) == 0
			Aadd(aRetorno, {cFilAnt, xFilial("SB1"), xFilial(cTabela)})
		EndIf
	Next nFil

	cFilAnt := cFilBkp
Return aRetorno

/*/{Protheus.doc} OA537006L_SeparaNomeArq
Separa o nome do arquivo do caminho completo
@author		Guilherme Santos
@since		17/09/2025
@version	12.1.2610
/*/
Static Function OA537006L_SeparaNomeArq(cArquivo)
	Local nI       := 0
	Local cNomeArq := ""

	For nI := Len(cArquivo) to 1 Step -1
		If Substr(cArquivo, nI, 1) == "\" .OR. Substr(cArquivo, nI, 1) == "/"
			Exit
		EndIf
		cNomeArq := Substr(cArquivo, nI, 1) + cNomeArq
	Next nI
Return cNomeArq

/*/{Protheus.doc} OA537010M_GrvLog
Grava o log na tabela VQL
@author		Jesse Augusto
@since		02/10/2025
@version	12.1.2610
/*/
Static Function OA537010M_GrvLog( aMsg, cId, cTipo )
	Local oLogger   := DMS_Logger():New()
	Local jPars     := JSonObject():New()
	Local lSchedule := FWGetRunSchedule()
	Local aValor    := {}
	Local nX        := 0

	Default cId   := ""
	Default aMsg  := {}
	Default cTipo := ''

	jPars["mensagem"]      := {}
	jPars["EMPRESA"]       := cEmpAnt
	jPars["FILIAL"]        := cFilAnt
	jPars["USUARIO"]       := cUserName
	jPars["MODE_EXECUCAO"] := If( lSchedule, "SCHEDULE", "MANUAL" )
	jPars["MV_PAR01"]      := Alltrim(MV_PAR01)
	jPars["MV_PAR02"]      := Alltrim(MV_PAR02)
	jPars["MV_PAR03"]      := Alltrim(MV_PAR03)
	jPars["MV_PAR04"]      := Alltrim(MV_PAR04)
	jPars["MV_PAR05"]      := Alltrim(MV_PAR05)
	jPars["MV_PAR06"]      := Alltrim(MV_PAR06)
	jPars["MV_PAR07"]      := MV_PAR07
	jPars["MV_PAR08"]      := MV_PAR08
	jPars["MV_PAR09"]      := Alltrim(MV_PAR09)

	For nX := 1 To Len( aMsg )
		aAdd( jPars["mensagem"], aMsg[nX] )
	Next nX

	aAdd( aValor, {"VQL_AGROUP", "OFIA537"                                   })
	aAdd( aValor, {"VQL_FILORI", xFilial("VQL")                              })
	aAdd( aValor, {"VQL_DATAI" , dDatabase                                   })
	aAdd( aValor, {"VQL_DATAF" , dDatabase                                   })
	aAdd( aValor, {"VQL_HORAI" , Val( StrTran( Left( Time(), 5), ":", "" ) ) })
	aAdd( aValor, {"VQL_HORAF" , Val( StrTran( Left( Time(), 5), ":", "" ) ) })
	aAdd( aValor, {"VQL_MSGLOG", jPars:ToJSon()                              })

	If !Empty(cId)
		aAdd( aValor, {"VQL_CODVQL", cId })
	EndIf

	If !Empty(cTipo)
		aAdd( aValor, {"VQL_TIPO", cTipo })
	EndIf
Return oLogger:LogToTable( aValor )

/*/{Protheus.doc} OA537010J_MontaJsonDeItensNaoImportados
Monta JSON com os itens nao encontrados para log na VQL
@author		Renan Migliaris
@since		25/11/2025
/*/
Static Function OA537010J_MontaJsonDeItensNaoImportados(aItens)
	Local jJson    := JSonObject():New()
	Local jAuxJson := nil
	Local nX       := 0

	jJson['notFoundItems'] := {}

	For nX := 1 To Len(aItens)
		jAuxJson := JSonObject():New()
		jAuxJson["itemCode"]        := AllTrim(aItens[nX][1])
		jAuxJson["itemDescription"] := AllTrim(aItens[nX][2])
		aAdd(jJson['notFoundItems'], jAuxJson)
		freeObj(jAuxJson)
	Next nX
Return jJson:ToJSon()
