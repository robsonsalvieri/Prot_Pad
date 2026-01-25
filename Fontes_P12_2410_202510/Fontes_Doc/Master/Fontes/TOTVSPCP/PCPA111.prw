#INCLUDE "PROTHEUS.CH"
#Include "PCPA111.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA111
 
Programa de Sincronização de dados com o PCFactory.

@author  Lucas Konrad França
@version P12
@since   09/10/2015
/*/
//-------------------------------------------------------------------------------------------------
Function PCPA111()
	Local lIntgSFC   := Iif(SuperGetMV("MV_INTSFC",.F.,0)==1,.T.,.F.)
	Local lLite      := .F.
	Local lIntPPI    := .F.
	Local nI         := 0
	Local oBtnProc   := Nil
	Local oBtnSair   := Nil
	Local oCheckAll  := Nil
	Local oDlgSinc   := Nil
	Local oPnlBottom := Nil
	Local oPnlTop    := Nil

	Private aTabsFil := {}
	Private aChecks  := {}
	Private aFiltEsp := {}
	Private lChange  := .F.

	Default lAutoMacao := .F.

	lIntPPI := PCPIntgPPI("SC2", @lLite)

	If !lAutoMacao
		DEFINE DIALOG oDlgSinc TITLE STR0001 FROM 0,0 TO 370,400 PIXEL //"Sincronização"

		oPnlTop := TPanel():New( 01, 01, ,oDlgSinc, , , , , , 400, 280, .T.,.T. )
		oPnlTop:Align := CONTROL_ALIGN_TOP

		oPnlBottom := TPanel():New( 280, 01, ,oDlgSinc, , , , , , 400, 20, .T.,.T. )
		oPnlBottom:Align := CONTROL_ALIGN_BOTTOM
	EndIf

	If lLite
		//Para adicionar mais opções, adicionar mais uma posição neste array e tratar a execução
		//na função procLite
		aAdd(aTabsFil, {"SB1", STR0002, ""}) //"Produto"
		aAdd(aTabsFil, {"SC2", STR0005, ""}) //"Ordem de Produção"
	Else

		//Lista de opções que aparecerão... Para adicionar, basta colocar mais uma posição no array.
		//Verificar se é necessário adicionar alguma tratativa da tabela na função PCPA111PPI
		aAdd(aTabsFil, {"SB1",STR0002,"MATA010PPI(, , .F., .F., .T.)"}) //"Produto"
		aAdd(aTabsFil, {"NNR",STR0003,"AGRA045PPI(, , , oModel, .F., .T.)"}) //"Local de Estoque"
		If lIntgSFC
			aAdd(aTabsFil, {"CYH",STR0004,"SFCA006PPI(, ,.F., .F., .T., oModel)"}) //"Recurso"
			aAdd(aTabsFil, {"CYB",STR0041,"mata610PPI(, , .F., .T.)"}) //"Máquina"
		Else
			aAdd(aTabsFil, {"SH1",STR0004,"mata610PPI(, ,.F.,.T.)"}) //"Recurso"
			aAdd(aTabsFil, {"SH4",STR0042,"MATA620PPI(, ,.F.,.F.,.T.)"}) //"Ferramenta"
		EndIf
		aAdd(aTabsFil, {"SC2",STR0005,"mata650PPI(, , .T., .T., .F., .F.)"}) //"Ordem de Produção"
		aAdd(aTabsFil, {"SG2",STR0043,"PCPA124PPI(, , .F., .F., .T.)"}) //"Roteiro"
		aAdd(aTabsFil, {"SG1",STR0044,"PCPA200PPI(, SG1->G1_COD, 3, .F., .T.)"}) //"Estrutura"
		aAdd(aTabsFil, {"SBE",STR0045,"MATA015PPI(, , .F., .F., .T., oModel)"}) //"Endereço"
		/*
		   Saldo estoque não passa a função para execução pois tem a tratativa diferente. Função ProcSaldo.
		*/
		aAdd(aTabsFil, {"SB2",STR0046,""}) //"Saldo Estoque"
	EndIf

	If !lAutoMacao
		@ 15, 05 CHECKBOX oCheckAll VAR lChange PROMPT STR0047 /*"Marca/Desmarca todos"*/ WHEN PIXEL OF oPnlTop SIZE 100,015 MESSAGE ""
		oCheckAll:bChange := {|| ChangCheck(lChange,oCheckAll)}

		For nI := 1 To Len(aTabsFil)
			//Checkbox Filtro
			aAdd(aChecks,PCPA110C():New(oPnlTop,aTabsFil[nI][1],aTabsFil[nI][2],(nI+1) * 15,05,{|| }) )
			aAdd(aFiltEsp,PCPA111F():New(oPnlTop,aTabsFil[nI][1],aTabsFil[nI][2],(nI+1) * 15,82) )
		Next

		@ 05,10 BUTTON oBtnProc PROMPT STR0006 SIZE 50,12 WHEN (.T.) ACTION (Processar(lIntPPI, lLite))    OF oPnlBottom PIXEL //"Processar"
		@ 05,65 BUTTON oBtnSair PROMPT STR0007 SIZE 50,12 WHEN (.T.) ACTION (oDlgSinc:End()) OF oPnlBottom PIXEL //"Sair"

		ACTIVATE MSDIALOG oDlgSinc CENTERED
	EndIf

Return Nil

Static Function ChangCheck(lTipo,oCheckAll)
	//lTipo: .T. = Marcar todos, .F. = Desmarcar todos
	Local nI := 0

	For nI := 1 To Len(aChecks)
		aChecks[nI]:lValue := lTipo
	Next
	SetFocus(aChecks[1]:oCheckBox:HWND)
	SetFocus(oCheckAll:HWND)
Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Processar

Função principal de processamento dos dados.

@author  Lucas Konrad França
@version P12
@since   09/10/2015
@param 01 lIntPPI, Logic, Indica se integração MES está habilitada.
@param 02 lLite  , Logic, Indica se usa MES LITE.
/*/
//-------------------------------------------------------------------------------------------------
Static Function Processar(lIntPPI, lLite)
	Local aFiltro   := {}
	Local aProcess  := {}
	Local aResults  := {}
	Local cAliasCnt := "COUNTREG"
	Local cFiltro   := ""
	Local cNameFil  := ""
	Local cQuery    := ""
	Local nI        := 0
	Local nPos      := 0
	Local nTotal    := 0

	Default lAutoMacao := .F.

	//Validação da integração ativa ou não. Só deixa processar se a integração estiver ativa.
	If !lIntPPI
		MSGALERT( STR0008, STR0009 ) //"Integração com o PCFactory desativada. Processamento não permitido.", "Atenção"
		Return .F.
	EndIf

	//Verifica se foi selecionado algum registro para processar.
	If aScan(aChecks,{|x| x:lValue==.T.}) < 1
		MSGALERT( STR0010, STR0009 ) //"Atenção"
		Return .F.
	EndIf

	//Aplica os filtros e verifica a quantidade total de registros que serão sincronizados.
	dbSelectArea("SOE")
	SOE->(dbSetOrder(1))
	cQuery := ""
	For nI := 1 To Len(aChecks)
		aFiltro := {}
		If aChecks[nI]:lValue
			If AT("S",aChecks[nI]:cId) == 1
				//Se o nome da tabela começa com S
				cNameFil := SubStr(AllTrim(aChecks[nI]:cId),2,2)+"_FILIAL"
			Else
				cNameFil := AllTrim(aChecks[nI]:cId)+"_FILIAL"
			EndIf

			If !Empty(cQuery) .And. AllTrim(aChecks[nI]:cId) != "SB2"
				cQuery += " UNION ALL "
			EndIf

			cFiltro := AllTrim(aChecks[nI]:cId) + ".D_E_L_E_T_ = ' ' "
			cFiltro += " AND " + AllTrim(aChecks[nI]:cId) + "." + cNameFil + " = '" + xFilial(aChecks[nI]:cId) + "' "
			//Aplica filtros da tabela SOE
			If SOE->(dbSeek(xFilial("SOE")+AllTrim(aChecks[nI]:cId))) .And. !Empty(SOE->OE_FILTRO)
				cFiltro += " AND (" + StrTran(SOE->OE_FILTRO,'"',"'") + ") "
			EndIf
			//Aplica filtros da tela
			If !Empty(aFiltEsp[nI]:cFiltro)
				cFiltro += " AND (" + StrTran(aFiltEsp[nI]:cFiltro,'"',"'") + ") "
			EndIf

			If AllTrim(aChecks[nI]:cId) == "SG2" //Tratamento especial para as Operações
				cQuery += " SELECT COUNT(*) TOTAL "
				cQuery +=   " FROM ( SELECT DISTINCT SG2.G2_PRODUTO, SG2.G2_CODIGO "
				cQuery +=            " FROM " + RetSqlName("SG2") + " SG2 "
				cQuery +=           " WHERE " + AlLTrim(cFiltro) + " ) t"
			ElseIf AllTrim(aChecks[nI]:cId) == "SG1" //Tratamento especial para as Estruturas
				cQuery += " SELECT COUNT(*) TOTAL "
				cQuery +=   " FROM ( SELECT DISTINCT SG1.G1_COD "
				cQuery +=            " FROM " + RetSqlName("SG1") + " SG1 "
				cQuery +=           " WHERE " + AlLTrim(cFiltro) + " ) t"
			ElseIf AllTrim(aChecks[nI]:cId) == "SB2" //Tratamento especial para os saldos
				//Aplica filtros da tabela SOE
				If (ValType(aFiltEsp[nI]:oFilt)=="O" .And. aFiltEsp[nI]:oFilt:lExec) .Or. ValType(aFiltEsp[nI]:oFilt)!="O"
					If !Empty(cQuery)
						cQuery += " UNION ALL "
					EndIf

					cFiltro +=    " AND SB2.B2_COD <> ' ' "
					cFiltro +=    " AND SB2.B2_COD NOT IN ( SELECT DISTINCT SBF.BF_PRODUTO "
					cFiltro +=                              " FROM " + RetSqlName("SBF") + " SBF "
					cFiltro +=                             " WHERE SBF.D_E_L_E_T_ = ' ' "
					cFiltro +=                               " AND SBF.BF_FILIAL  = '" + xFilial("SBF") + "' "
					cFiltro +=                             " UNION "
					cFiltro +=                             " SELECT DISTINCT SB8.B8_PRODUTO "
					cFiltro +=                               " FROM " + RetSqlName("SB8") + " SB8 "
					cFiltro +=                              " WHERE SB8.B8_FILIAL  = '" + xFilial("SB8") + "' "
					cFiltro +=                                " AND SB8.D_E_L_E_T_ = ' ' )"

					cQuery += " SELECT COUNT(*) TOTAL "
					cQuery +=   " FROM (SELECT DISTINCT SB2.B2_LOCAL, SB2.B2_COD "
					cQuery +=           " FROM " + RetSqlName(aChecks[nI]:cId) + " " + aChecks[nI]:cId
					cQuery +=          " WHERE " + cFiltro + " ) t "

					aAdd(aFiltro, {"SB2", cFiltro })
				EndIf
				nPos := 0
				If ValType(aFiltEsp[nI]:oFilt)=="O"
					nPos := aScan(aFiltEsp[nI]:oFilt:aSubFolder,{|x| x:cTabela == "SB8"})
				EndIf
				If (ValType(aFiltEsp[nI]:oFilt)=="O" .And. nPos > 0 .And. aFiltEsp[nI]:oFilt:aSubFolder[nPos]:lExec) .Or. ValType(aFiltEsp[nI]:oFilt)!="O"
					//Conta os registros da tabela SB8.
					If !Empty(cQuery)
						cQuery += " UNION ALL "
					EndIf
					cFiltro := "SB8.D_E_L_E_T_ = ' ' "
					cFiltro += " AND SB8.B8_FILIAL  = '" + xFilial("SB8") + "' "
					//Aplica filtros da tabela SOE
					If SOE->(dbSeek(xFilial("SOE")+"SB8")) .And. !Empty(SOE->OE_FILTRO)
						cFiltro += " AND (" + StrTran(SOE->OE_FILTRO,'"',"'") + ") "
					EndIf
					If ValType(aFiltEsp[nI]:oFilt)=="O"
						nPos := aScan(aFiltEsp[nI]:oFilt:aSubFolder,{|x| x:cTabela == "SB8"})
					EndIf
					//Aplica filtros da tela
					If ValType(aFiltEsp[nI]:oFilt)=="O" .And. !Empty(aFiltEsp[nI]:oFilt:aSubFolder[nPos]:cFiltro)
						cFiltro += " AND (" + StrTran(aFiltEsp[nI]:oFilt:aSubFolder[nPos]:cFiltro,'"',"'") + ") "
					EndIf

					cFiltro += " AND SB8.B8_PRODUTO NOT IN ( SELECT DISTINCT SBF.BF_PRODUTO "
					cFiltro +=                              " FROM " + RetSqlName("SBF") + " SBF "
					cFiltro +=                             " WHERE SBF.D_E_L_E_T_ = ' ' "
					cFiltro +=                               " AND SBF.BF_FILIAL  = '" + xFilial("SBF") + "' )"

					cQuery += " SELECT COUNT(*) TOTAL "
					cQuery +=   " FROM ( SELECT DISTINCT SB8.B8_LOCAL   , "
					cQuery +=                          " SB8.B8_PRODUTO , "
					cQuery +=                          " SB8.B8_LOTECTL , "
					cQuery +=                          " SB8.B8_NUMLOTE , "
					cQuery +=                          " SB8.B8_DTVALID  "
					cQuery +=            " FROM " + RetSqlName("SB8") + " SB8 "
					cQuery +=           " WHERE " + cFiltro + " ) t "

					aAdd(aFiltro, {"SB8", cFiltro})
				EndIf

				nPos := 0
				If ValType(aFiltEsp[nI]:oFilt)=="O"
					nPos := aScan(aFiltEsp[nI]:oFilt:aSubFolder,{|x| x:cTabela == "SBF"})
				EndIf
				If (ValType(aFiltEsp[nI]:oFilt)=="O" .And. nPos > 0 .And. aFiltEsp[nI]:oFilt:aSubFolder[nPos]:lExec) .Or. ValType(aFiltEsp[nI]:oFilt)!="O"
					//Conta os registros da tabela SBF.
					If !Empty(cQuery)
						cQuery += " UNION ALL "
					EndIf

					cFiltro := "SBF.D_E_L_E_T_ = ' ' "
					cFiltro += " AND SBF.BF_FILIAL  = '" + xFilial("SBF") + "' "
					//Aplica filtros da tabela SOE
					If SOE->(dbSeek(xFilial("SOE")+"SBF")) .And. !Empty(SOE->OE_FILTRO)
						cFiltro += " AND (" + StrTran(SOE->OE_FILTRO,'"',"'") + ") "
					EndIf
					If ValType(aFiltEsp[nI]:oFilt)=="O"
						nPos := aScan(aFiltEsp[nI]:oFilt:aSubFolder,{|x| x:cTabela == "SBF"})
					EndIf
					//Aplica filtros da tela
					If ValType(aFiltEsp[nI]:oFilt)=="O" .And. !Empty(aFiltEsp[nI]:oFilt:aSubFolder[nPos]:cFiltro)
						cFiltro += " AND (" + StrTran(aFiltEsp[nI]:oFilt:aSubFolder[nPos]:cFiltro,'"',"'") + ") "
					EndIf
					cQuery += " SELECT COUNT(*) TOTAL "
					cQuery +=   " FROM ( SELECT DISTINCT SBF.BF_LOCAL  , "
					cQuery +=                          " SBF.BF_LOCALIZ, "
					cQuery +=                          " SBF.BF_PRODUTO, "
					cQuery +=                          " SBF.BF_NUMSERI, "
					cQuery +=                          " SBF.BF_LOTECTL, "
					cQuery +=                          " SBF.BF_NUMLOTE "
					cQuery +=            " FROM " + RetSqlName("SBF") + " SBF "
					cQuery +=           " WHERE " + cFiltro + " ) t "
					aAdd(aFiltro, {"SBF", cFiltro})
				EndIf
			ElseIf lLite .And. AllTrim(aChecks[nI]:cId) == "SC2"
				cQuery += queryOP(cFiltro, .T.)
			Else
				cQuery += " SELECT COUNT(*) TOTAL "
				cQuery +=   " FROM " + RetSqlName(aChecks[nI]:cId) + " " + aChecks[nI]:cId
				cQuery +=  " WHERE " + cFiltro
			EndIf

			aAdd(aProcess,{AllTrim(aChecks[nI]:cId),cFiltro,aTabsFil[nI,3],aTabsFil[nI,2], aFiltro})
		EndIf
	Next nI

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCnt,.T.,.T.)
	While !(cAliasCnt)->(Eof())
		nTotal += (cAliasCnt)->(TOTAL)
		(cAliasCnt)->(dbSkip())
	End
	(cAliasCnt)->(dbCloseArea())

	//Não encontrou nenhum registro para processar.
	If nTotal == 0
		MSGALERT( STR0011, STR0009 ) //"Não existem registros a serem processados. Verifique os filtros utilizados.", "Atenção"
		Return .F.
	EndIf

	If !lAutoMacao
		If MsgYesNo(STR0012 + cValToChar(nTotal) + STR0013, STR0009) //"Serão processados " XXX " registros, deseja continuar?", "Atenção"
			//Monta a barra de progresso e executa o processamento.
			processBar(aProcess, nTotal, lLite, @aResults)

			//Mostra a tela com o resultado do processamento.
			ResultProc(aResults)

			If lLite
				aSize(aResults, 0)
			Else
				//Limpa as variáveis globais.
				ClearGlbValue("A111COUNT")
				ClearGlbValue("A111PROCINF")
			EndIf
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} queryOP
Monta a query para buscar as ordens de produção

@type  Static Function
@author lucas.franca
@since 13/11/2024
@version P12
@param 01 cFiltro, Character, Filtro SQL padrão da OP
@param 02 lCount , Logic    , indica se retorna o COUNT ou o RECNO.
@return cQuery, Character, Condição SQL para retornar as ordens
/*/
Static Function queryOP(cFiltro, lCount)
	Local cQuery   := ""
	Local cFiltPrd := ""
	Local cFiltRot := ""

	If lCount
		cQuery := " SELECT COUNT(*) TOTAL"
	Else
		cQuery := " SELECT SC2.R_E_C_N_O_ RECTAB"
	EndIf
	cQuery +=   " FROM " + RetSqlName("SC2") + " SC2"
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO"
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' '"

	If totvs.protheus.manufacturing.meslite.productionorder.aplicaFiltroProdutoNaOP(@cFiltPrd, .T.) .And. !Empty(cFiltPrd)
		cFiltPrd := StrTran(cFiltPrd, "B1_", "SB1.B1_")
		cQuery   += " AND (" + cFiltPrd + ") "
	EndIf

	cQuery +=  " WHERE SC2.C2_DATRF   = ' '"
	cQuery +=    " AND SC2.C2_TPOP    = 'F'"
	cQuery +=    " AND " + cFiltro
	cQuery +=    " AND EXISTS (SELECT 1"
	cQuery +=                  " FROM " + RetSqlName("SG2") + " SG2"
	cQuery +=                 " WHERE SG2.G2_FILIAL  = '" + xFilial("SG2") + "'"
	cQuery +=                   " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO"
	cQuery +=                   " AND SG2.G2_CODIGO  = CASE WHEN SC2.C2_ROTEIRO <> ' ' THEN SC2.C2_ROTEIRO"
	cQuery +=                                             " WHEN SB1.B1_OPERPAD <> ' ' THEN SB1.B1_OPERPAD"
	cQuery +=                                             " ELSE '01'"
	cQuery +=                                        " END"
	cQuery +=                   " AND (SG2.G2_DTINI  = ' ' OR SG2.G2_DTINI < SC2.C2_DATPRI )
	cQuery +=                   " AND (SG2.G2_DTFIM  = ' ' OR SG2.G2_DTFIM > SC2.C2_DATPRI )

	If totvs.protheus.manufacturing.meslite.productionorder.aplicaFiltroRoteiroNaOP(@cFiltRot) .And. !Empty(cFiltRot)
		cFiltRot := StrTran(cFiltRot, "G2_", "SG2.G2_")
		cQuery   += " AND (" + cFiltRot + ") "
	EndIf

	cQuery +=                   " AND SG2.D_E_L_E_T_ = ' ') "

Return cQuery

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} processBar

Abre a barra de progresso para o processamento.

@author  Lucas Konrad França
@version P12
@since   13/10/2015
@param 01 aProcess, Array  , Array com as informações das tabelas que devem ser sincronizadas
@param 02 nTotal  , Numeric, Quantidade total de registros a processar
@param 03 lLite   , Logic  , Indica se é integração MES Lite.
@param 04 aResults, Array  , Retorna por referência o resultado da execução
/*/
//-------------------------------------------------------------------------------------------------
Static Function processBar(aProcess, nTotal, lLite, aResults)
	Local cFunc   := "initProc"
	Local oDlgMet := Nil

	Private nMeter := 0
	Private oMeter, oSayMtr

	If lLite
		cFunc := "procLite"
	EndIf

	DEFINE MSDIALOG oDlgMet FROM 0,0 TO 5,60 TITLE STR0014 //"Processando"

	oSayMtr := tSay():New(10,10,{||STR0015},oDlgMet,,,,,,.T.,,,220,20) //"Processando, aguarde..."
	oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},100,oDlgMet,220,10,,.T.) // cria a régua

	ACTIVATE MSDIALOG oDlgMet CENTERED ON INIT (&cFunc.(aProcess, nTotal, @aResults), oDlgMet:End())
Return .T.

/*/{Protheus.doc} procLite
Executa o processamento da integração quando configurado MES LITE.

@type  Static Function
@author lucas.franca
@since 12/11/2024
@version P12
@param 01 aProcess, Array  , Array com as informações das tabelas que devem ser sincronizadas
@param 02 nTotal  , Numeric, Quantidade total de registros a processar
@param 03 aResults, Array  , Retorna por referência o resultado da execução
@return Nil
/*/
Static Function procLite(aProcess, nTotal, aResults)
	Local nIndex   := 0
	Local nRegs    := 0
	Local nQtdProc := Len(aProcess)

	ProcTot(nTotal)

	For nIndex := 1 To nQtdProc
		
		If aProcess[nIndex][1] == "SB1"
			aAdd(aResults, sincProd(aProcess[nIndex], @nRegs))
		ElseIf aProcess[nIndex][1] == "SC2"
			aAdd(aResults, sincOP(aProcess[nIndex], @nRegs))
		EndIf

	Next nIndex
Return Nil

/*/{Protheus.doc} sincProd
Executa a sincronização de produtos para o MES LITE.

@type  Static Function
@author lucas.franca
@since 12/11/2024
@version P12
@param 01 aProcess, Array  , Array com os dados do processamento.
@param 02 nRegs   , Numeric, Retorna por referência quantidade de itens processados
@return aResult, Array, Array com o resultado da execução
/*/
Static Function sincProd(aProcess, nRegs)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local nQtdOk  := 0
	Local nQtdErr := 0
	Local o010Int := Nil

	cQuery := " SELECT SB1.R_E_C_N_O_ RECTAB "
	cQuery +=   " FROM " + RetSqlName("SB1") + " SB1"
	cQuery +=  " WHERE " + aProcess[2]

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)
	While (cAlias)->(!Eof())
		SB1->(dbGoTo( (cAlias)->RECTAB ))

		o010Int := MATA010PPI():New(Nil, Nil, .F., .F., .T., .F.)
		If o010Int:Execute()
			nQtdOk++
		Else
			nQtdErr++
		EndIf
		FreeObj(o010Int)

		nRegs++
		ProcInc(nRegs)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())
Return {"SB1", STR0002, nQtdOk, nQtdErr} //STR0002 - Produto

/*/{Protheus.doc} sincOP
Executa a sincronização de ordens de produção com o MES LITE.

@type  Static Function
@author lucas.franca
@since 13/11/2024
@version P12
@param 01 aProcess, Array  , Array com os dados do processamento.
@param 02 nRegs   , Numeric, Retorna por referência quantidade de itens processados
@return aResult, Array, Array com o resultado da execução
/*/
Static Function sincOP(aProcess, nRegs)
	Local cAlias  := GetNextAlias()
	Local cQuery  := queryOP(aProcess[2], .F.)
	Local nQtdOk  := 0
	Local nQtdErr := 0

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)
	While (cAlias)->(!Eof())
		SC2->(dbGoTo( (cAlias)->RECTAB ))

		If mata650PPI(, , .T., .T., .F., .F.)
			nQtdOk++
		Else
			nQtdErr++
		EndIf
		
		nRegs++
		ProcInc(nRegs)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return {"SC2", STR0005, nQtdOk, nQtdErr} //STR0005 - Ordem de produção

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} initProc

Inicia o processamento.

@author  Lucas Konrad França
@version P12
@since   13/10/2015
@param 01 aProcess, Array  , Array com as informações das tabelas que devem ser sincronizadas
@param 02 nTotal  , Numeric, Quantidade total de registros a processar
@param 03 aResults, Array  , Compatibilidade com a função procLite.
/*/
//-------------------------------------------------------------------------------------------------
Static Function initProc(aProcess, nTotal, aResults)
   Local nI       := 0
   Local aJobs    := {}
   Local cNameJob := ""
   Local cToken   := ""
   Local nRetry_0 := 0
   Local lError   := .F.

   ProcTot(nTotal)
   PutGlbValue("A111COUNT","0")
   PutGlbVars("A111PROCINF",{})
   GlbUnLock()
   
   cToken := totvs.framework.users.rpc.getAuthToken()

   //Processa os registros
   For nI := 1 To Len(aProcess)
      cNameJob := "A111PPI"+cValToChar(nI)
      PutGlbValue(cNameJob, "0")
      GlbUnLock()
      StartJob("PCPA111PPI", GetEnvServer(), .F., cEmpAnt, cFilAnt, aProcess[nI,1], aProcess[nI,2], aProcess[nI,3], cNameJob, aProcess[nI,4], cToken, aProcess[nI,5])

      aAdd(aJobs, {aProcess[nI,1], aProcess[nI,2], aProcess[nI,3], cNameJob, , aProcess[nI,4], cToken, aProcess[nI,5]} )
   Next nI

   For nI := 1 To Len(aJobs)
      While .T.
         If lError
            Exit
         EndIf
         ProcInc()
         Do Case
            //Tratamento para subida de Thread
            Case GetGlbValue(aJobs[nI,4]) == "0"
               If nRetry_0 > 50
                  //Conout(Replicate("-",65))
                  //Conout(STR0016 + aJobs[nI,4]) //"PCPA111: Não foi possivel realizar a subida da thread "
                  //Conout(Replicate("-",65))
                  Final(STR0016 + aJobs[nI,4]) //"PCPA111: Não foi possivel realizar a subida da thread "
               Else
                  nRetry_0 ++
               EndIf
            //TRATAMENTO PARA ERRO DE CONEXAO
            Case GetGlbValue(aJobs[nI,4]) == '10'
               If nRetry_1 > 5
                  //Conout(Replicate("-",65))
                  //Conout(STR0017 + aJobs[nI,4]) //"PCPA111: Erro de conexao na thread "
                  //Conout(STR0018 + aJobs[nI,4]) //"Thread numero : "
                  //Conout(STR0019) //"Numero de tentativas excedidas"
                  //Conout(Replicate("-",65))

                  Final(STR0017 + aJobs[nI,4]) //"PCPA111: Erro de conexao na thread "
               Else
                  //Inicializa variavel global de controle de Job
                  PutGlbValue(aJobs[nI,4],"0")
                  GlbUnLock()

                  //Reiniciar thread
                  //Conout(Replicate("-",65))
                  //Conout(STR0017 + aJobs[nI,4]) //"PCPA111: Erro de conexao na thread "
                  //Conout(STR0018 + aJobs[nI,4]) //"Thread numero : "
                  //Conout(STR0020 + aJobs[nI,4]) //"Reiniciando a thread: "
                  //Conout(Replicate("-",65))

                  //Dispara thread para Stored Procedure
                  StartJob("PCPA111PPI", GetEnvServer(), .F., cEmpAnt, cFilAnt, aJobs[nI,1], aJobs[nI,2], aJobs[nI,3], aJobs[nI,4], aJobs[nI,5], aJobs[nI,8])
               EndIf
               nRetry_1 ++

            //TRATAMENTO PARA ERRO DE APLICACAO
            Case GetGlbValue(aJobs[nI,4]) == '20'
               //Conout(Replicate("-",65))
               //Conout(STR0021 + aJobs[nI,4]) //"PCPA111: Erro ao efetuar a conexão da thread "
               //Conout(STR0018 + aJobs[nI,4]) //"Thread numero: "
               //Conout(Replicate("-",65))

               Final(STR0021 + aJobs[nI,4]) //"PCPA111: Erro ao efetuar a conexão da thread "

            //Tratamento de erro de execução
            Case GetGlbValue(aJobs[nI,4]) == '30'
               //Conout(Replicate("-",65))
               //Conout(STR0022 + aJobs[nI,4]) //"PCPA111: Erro de execução na thread "
               //Conout(STR0018 + aJobs[nI,4]) //"Thread numero: "
               //Conout(GetGlbValue(aJobs[nI,4]+"ERR"))
               //Conout(Replicate("-",65))

               /*
               Erro ao integrar as mensagens de XXXX.
               PCPA111: Erro de execução na thread XXXX
               MENSAGEM DE ERRO
               STACK DO ERRO
               */
               Aviso("ERRO",STR0048 + aJobs[nI,6] + CHR(10) + ; //"Erro ao integrar as mensagens de "
                            STR0022 + aJobs[nI,4] + CHR(10) + ; //"PCPA111: Erro de execução na thread "
                            GetGlbValue(aJobs[nI,4]+"ERR"), {"OK"},3)
               lError := .T.
               Exit

               //Final(STR0022 + aJobs[nI,4] + CHR(10) + GetGlbValue(aJobs[nI,4]+"ERR")) //"PCPA111: Erro de execução na thread "

            //THREAD PROCESSADA CORRETAMENTE
            Case GetGlbValue(aJobs[nI,4]) == '3'
               //Atualiza o log de processamento
               //Conout("Thread " + aJobs[nI,4] + STR0023) //" processada com sucesso."
               Exit
         EndCase
         Sleep(1000)
      End
   Next nI

Return .T.

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcTot

Incrementa a barra de progresso.

@author  Lucas Konrad França
@version P12
@since   13/10/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function ProcInc(nValue)

	Default nValue := -1

	If Type("oMeter") != "U"
		If nValue > -1
			nMeter := nValue
		Else
			nMeter := Val(GetGlbValue("A111COUNT"))
		EndIf

		oMeter:Set(nMeter)
		oSayMtr:SetText(STR0024 + cValToChar(nMeter) + STR0025 + cValToChar(oMeter:nTotal) + STR0026) //"Processando... 1 de 100 registros "
		oMeter:Refresh()
		oSayMtr:CtrlRefresh()
	EndIf
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcTot

Define o valor total da barra de progresso

@param nTotal - Quantidade total da barra de progresso.

@author  Lucas Konrad França
@version P12
@since   13/10/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function ProcTot(nTotal)
   If Type("oMeter") != "U"
      oMeter:SetTotal(nTotal)
   EndIf
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PCPA111PPI

Executa a integração dos registros com o PPI.

@param cEmp     - Empresa que será utilizada para realizar o processamento. Ex: 99
@param cFil     - Filial que será utilizada para realizar o processamento. Ex: 01
@param cTable   - Nome da tabela que será integrada. Ex: SB1
@param cFiltro  - Filtro que será utilizado para buscar os registros. Ex: B1_COD <> 'TESTE'
@param cRotina  - Rotina que será executada para realizar a integração. Ex: MATA010PPI(, , .F., .F., .T.)
@param cNameJob - Identificador do Job. Ex: A111PPI1
@param cNameTab - Nome da tabela que está processando. Ex: "Produto"
@param cUser     - Usuário que está realizando o processamento.
@param aFiltro   - Array com os filtros (utilizado para o processamento dos saldos, tabelas SB2, SB8 e SBF)

@author  Lucas Konrad França
@version P12
@since   09/10/2015
/*/
//-------------------------------------------------------------------------------------------------
Function PCPA111PPI(cEmp, cFil, cTable, cFiltro, cRotina, cNameJob, cNameTab, cToken, aFiltro)
   Local cAlias  := "" //GetNextAlias()
   Local cQuery  := ""
   Local nCntOk  := 0
   Local nCntErr := 0
   Local aProces := {}

   Local bError  := ErrorBlock({|e| wspcpexecp(e)})

   Private INCLUI  := .T.
   Private ALTERA  := .F.
   Private nOpcRot := 3
   Private oModelCYB
   Private oWsInteg

   Private lErro   := .F.
   Private aMsg    := {}
   Private aStack  := {}

   BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue(cNameJob,"1")
   GlbUnLock()
   END SEQUENCE
   If lErro
      //ConOut(Replicate("-",65))
      //ConOut(STR0027 + cNameJob)  //"Erro ao iniciar a execucao do Job "
      //ConOut(aMsg[1])
      //ConOut(Replicate("-",65))
      PutGlbValue(cNameJob, "10" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'PCP')

   SetFunName("PCPA111")
   If !Empty(cToken)
      totvs.framework.users.rpc.authByToken(cToken)
   EndIf   

   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue(cNameJob, "2" )
   END SEQUENCE
   If lErro
      //ConOut(Replicate("-",65))
      //ConOut(STR0028 + cNameJob) //"Erro ao efetuar a conexão do Job "
      //ConOut(aMsg[1])
      //ConOut(Replicate("-",65))
      PutGlbValue(cNameJob, "20" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
   If AllTrim(cTable) == "SB2" // Os saldos possuem tratativas diferentes, processamento realizado na função ProcSaldo
      ProcSaldo(cTable, cFiltro, cRotina, cNameJob, cNameTab, aFiltro)
   Else
      cAlias  := GetNextAlias()

      //Instancia o objeto, para não instanciar um objeto para cada registro.
      oWsInteg := WSPCFactory():New()

      //Carrega os parâmetros do WS
      oWsInteg:getLinks()

      //Busca o registro da tabela.
      If AllTrim(cTable) == "SG2" //Tratamento especial para as Operações
         cQuery := " SELECT DISTINCT SG2.G2_PRODUTO, SG2.G2_CODIGO "
         cQuery +=   " FROM " + RetSqlName(cTable) + " " + cTable
         cQuery +=  " WHERE " + cFiltro
         SG2->(dbSetOrder(1))
      ElseIf AllTrim(cTable) == "SG1" //Tratamento especial para as Estruturas
         cQuery := " SELECT DISTINCT SG1.G1_COD "
         cQuery +=   " FROM " + RetSqlName(cTable) + " " + cTable
         cQuery +=  " WHERE " + cFiltro
         SG1->(dbSetOrder(1))
      Else
         cQuery := " SELECT " + cTable + ".R_E_C_N_O_ RECTAB "
         cQuery +=   " FROM " + RetSqlName(cTable) + " " + cTable
         cQuery +=  " WHERE " + cFiltro
      EndIf

      cQuery := ChangeQuery(cQuery)

      dbSelectArea(cTable)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
      While (cAlias)->(!Eof())
         while !GlbLock()
            sleep(50)
         enddo
         nTotal := Val(GetGlbValue("A111COUNT"))
         nTotal++
         PutGlbValue("A111COUNT",cValToChar(nTotal))
         GlbUnLock()

         //Posiciona na tabela
         If AllTrim(cTable)=="SG2" //Tratamento especial para as Operações
            SG2->(dbSeek(xFilial("SG2")+(cAlias)->(G2_PRODUTO+G2_CODIGO)))
         ElseIf AllTrim(cTable)=="SG1" //Tratamento especial para as Estruturas
            SG1->(dbSeek(xFilial("SG1")+(cAlias)->(G1_COD)))
         Else
            (cTable)->(dbGoTo((cAlias)->(RECTAB)))
         EndIf

         //Tratamento para o adapter de produto e de recurso. Os valores devem estar na variável de memória M->...
         If cTable $ "SB1|SH1|SH4"
            RegToMemory(cTable,.F.,.T.,.F.)
         EndIf
         //Tratamento para o adapter de local de estoque. Os valores devem estar carregados no Model.
         If cTable $ "NNR|CYH|SBE|CYB"
            oModel := cargaMVC(cTable)
         EndIf

         If cTable == "CYB"
            oModelCYB := oModel:GetModel("CYBMASTER")
            MATI610MOD(oModel)
         EndIf

         //Executa a rotina de integração para o registro.
         If &(cRotina) == .F.
            nCntErr++
         Else
            nCntOk++
         EndIf

         If cTable == "CYB"
            oModelCYB := Nil
            MATI610MOD(Nil)
         EndIf

         //Tratamento para o adapter de local de estoque. Desativa o Model
         If cTable $ "NNR|CYH"
            oModel:DeActivate()
         EndIf
         (cAlias)->(dbSkip())
      End

      while !GlbLock()
         sleep(50)
      enddo
      GetGlbVars("A111PROCINF",@aProces)
      aAdd(aProces,{cTable, cNameTab, nCntOk, nCntErr})
      PutGlbVars("A111PROCINF",aProces)
      GlbUnLock()
   EndIf

   RECOVER
   If lErro
      nCntErr++
      //ConOut(Replicate("-",65))
      //ConOut(STR0029 + cNameJob) //"Erro ao efetuar o processamento do Job "
      //ConOut(aMsg[1])
      //ConOut(Replicate("-",65))
      PutGlbValue(cNameJob, "30" )
      PutGlbValue(cNameJob+"ERR", aMsg[1]+CHR(10)+aStack[1] )
      GetGlbVars("A111PROCINF",@aProces)
      aAdd(aProces,{cTable, cNameTab, nCntOk, nCntErr})
      PutGlbVars("A111PROCINF",aProces)
      GlbUnLock()
      Return
   EndIf

   END SEQUENCE
   If lErro
      nCntErr++
      //ConOut(Replicate("-",65))
      //ConOut(STR0029 + cNameJob) //"Erro ao efetuar o processamento do Job "
      //ConOut(aMsg[1])
      //ConOut(Replicate("-",65))
      PutGlbValue(cNameJob, "30" )
      PutGlbValue(cNameJob+"ERR", aMsg[1]+CHR(10)+aStack[1] )
      GetGlbVars("A111PROCINF",@aProces)
      aAdd(aProces,{cTable, cNameTab, nCntOk, nCntErr})
      PutGlbVars("A111PROCINF",aProces)
      GlbUnLock()
      Return
   EndIf

   //STATUS 3 - Processamento efetuado com sucesso
   PutGlbValue(cNameJob,"3")
   GlbUnLock()

Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} cargaMVC

Carrega o modelo de dados MVC

@param cTable  - Nome da tabela que será integrada.

@author  Lucas Konrad França
@version P12
@since   09/10/2015
/*/
//-------------------------------------------------------------------------------------------------
Static Function cargaMVC(cTable)
   Local oModel

   If cTable == "NNR"
      oModel := FwLoadModel("AGRA045")

      oModel:SetOperation(4)
      oModel:Activate()
   ElseIf cTable == "CYH"
      oModel := FwLoadModel("SFCA006")

      oModel:SetOperation(4)
      oModel:Activate()
   ElseIf cTable == "SBE"
      oModel := FwLoadModel("MATA015")

      oModel:SetOperation(4)
      oModel:Activate()
   ElseIf cTable == "CYB"
      oModel := FwLoadModel("SFCA002")

      oModel:SetOperation(4)
      oModel:Activate()
   EndIf

Return oModel

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcSaldo

Função para processar os saldos.

@param cTable   - Nome da tabela que será integrada. Ex: SB1
@param cFiltro  - Filtro que será utilizado para buscar os registros. Ex: B1_COD <> 'TESTE'
@param cRotina  - Rotina que será executada para realizar a integração. Ex: MATA010PPI(, , .F., .F., .T.)
@param cNameJob - Identificador do Job. Ex: A111PPI1
@param cNameTab - Nome da tabela que está processando. Ex: "Produto"
@param aFiltro   - Array com os filtros (utilizado para o processamento dos saldos, tabelas SB2, SB8 e SBF)

@author  Lucas Konrad França
@version P118
@since   20/06/2016
/*/
//-------------------------------------------------------------------------------------------------
Static Function ProcSaldo(cTable, cFiltro, cRotina, cNameJob, cNameTab, aFiltro)
   Local nPos    := 0
   Local nCntOk  := 0
   Local nCntErr := 0
   Local cQuery  := ""
   Local cAlias  := ""
   Local aProces := {}

   Local cProd     := ""
   Local cArmaz    := ""
   Local cLocaliz  := ""
   Local cNumserie := ""
   Local cLotectl  := ""
   Local cNumlote  := ""
   Local dValid    := StoD("")
   Local nQuant    := 0
   Local cAcao     := ""
   Local cNumSeq   := ""
   Local cDoc      := ""

   cAlias  := GetNextAlias()

   //Instancia o objeto, para não instanciar um objeto para cada registro.
   oWsInteg := WSPCFactory():New()

   //Carrega os parâmetros do WS
   oWsInteg:getLinks()

   cFiltro := " 1 = 1 "
   nPos := aScan(aFiltro, {|x| x[1] == "SBF"})
   If nPos > 0
      cFiltro := aFiltro[nPos,2]
      cQuery += " SELECT DISTINCT SBF.BF_LOCAL   ARMAZEM, "
      cQuery +=                 " SBF.BF_LOCALIZ LOCALIZ, "
      cQuery +=                 " SBF.BF_PRODUTO PRODUTO, "
      cQuery +=                 " SBF.BF_NUMSERI NUMSERI, "
      cQuery +=                 " SBF.BF_LOTECTL LOTE, "
      cQuery +=                 " SBF.BF_NUMLOTE SUBLOTE, "
      cQuery +=                 " ' '            DTVALID "
      cQuery +=   " FROM " + RetSqlName("SBF") + " SBF "
      cQuery +=  " WHERE " + cFiltro
   EndIf

   cFiltro := " 1 = 1 "
   nPos := aScan(aFiltro, {|x| x[1] == "SB8"})
   If nPos > 0
      cFiltro := aFiltro[nPos,2]
      If !Empty(cQuery)
         cQuery += " UNION ALL "
      EndIf
      cQuery += " SELECT DISTINCT SB8.B8_LOCAL   ARMAZEM, "
      cQuery +=                 " ' '            LOCALIZ, "
      cQuery +=                 " SB8.B8_PRODUTO PRODUTO, "
      cQuery +=                 " ' '            NUMSERI, "
      cQuery +=                 " SB8.B8_LOTECTL LOTE, "
      cQuery +=                 " SB8.B8_NUMLOTE SUBLOTE, "
      cQuery +=                 " SB8.B8_DTVALID DTVALID "
      cQuery +=   " FROM " + RetSqlName("SB8") + " SB8 "
      cQuery +=  " WHERE " + cFiltro
   EndIf

   cFiltro := " 1 = 1 "
   nPos := aScan(aFiltro, {|x| x[1] == "SB2"})
   If nPos > 0
      cFiltro := aFiltro[nPos,2]
      If !Empty(cQuery)
         cQuery += " UNION ALL "
      EndIf
      cQuery += " SELECT DISTINCT SB2.B2_LOCAL   ARMAZEM, "
      cQuery +=                 " ' '            LOCALIZ, "
      cQuery +=                 " SB2.B2_COD     PRODUTO, "
      cQuery +=                 " ' '            NUMSERI, "
      cQuery +=                 " ' '            LOTE, "
      cQuery +=                 " ' '            SUBLOTE, "
      cQuery +=                 " ' '            DTVALID "
      cQuery +=   " FROM " + RetSqlName("SB2") + " SB2 "
      cQuery +=  " WHERE " + cFiltro
   EndIf

   //cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
   While (cAlias)->(!Eof())
      while !GlbLock()
         sleep(50)
      enddo
      nTotal := Val(GetGlbValue("A111COUNT"))
      nTotal++
      PutGlbValue("A111COUNT",cValToChar(nTotal))
      GlbUnLock()

      cProd     := (cAlias)->(PRODUTO)
      cArmaz    := (cAlias)->(ARMAZEM)
      cLocaliz  := (cAlias)->(LOCALIZ)
      cNumserie := (cAlias)->(NUMSERI)
      cLotectl  := (cAlias)->(LOTE)
      cNumlote  := (cAlias)->(SUBLOTE)
      dValid    := (cAlias)->(DTVALID)
      nQuant    := 0
      cAcao     := "1"
      cNumSeq   := ""
      cDoc      := ""
      If Empty(dValid)
         dValid := StoD(" ")
      Else
         If ValType(dValid) != "D"
            dValid := StoD(dValid)
         EndIf
      EndIf
      If ValType(dValid) != "D"
         dValid := StoD(" ")
      EndIf

      If MATA225PPI(cProd, cArmaz, cLocaliz, cNumserie, cLotectl, cNumlote, dValid, nQuant, cAcao, cNumSeq, cDoc, {})
         nCntOk++
      Else
         nCntErr++
      EndIf
      (cAlias)->(dbSkip())
   End

   while !GlbLock()
      sleep(50)
   enddo
   GetGlbVars("A111PROCINF",@aProces)
   aAdd(aProces,{cTable, cNameTab, nCntOk, nCntErr})
   PutGlbVars("A111PROCINF",aProces)
   GlbUnLock()
Return

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultProc

Exibe uma tela com o resultado da sincronização.

@author  Lucas Konrad França
@version P12
@since   13/10/2015
@param 01 aResults, Array, Array com os resultados. Utilizado no lugar da global A111PROCINF
/*/
//-------------------------------------------------------------------------------------------------
Static Function ResultProc(aResults)
   Local oDlgPrc, oLbx
   Local nI       := 0
   Local aCpos    := {}
   Local cDesc    := ""
   Local aTabProc := {}
   Default lAutoMacao := .F.

   If Empty(aResults)
      GetGlbVars("A111PROCINF",@aTabProc)
   Else
      aTabProc := aResults
   EndIf

   For nI := 1 To Len(aTabProc)
      If aTabProc[nI,4] > 0
         If aTabProc[nI,4] > 1
            cDesc := cValToChar(aTabProc[nI,4]) + STR0030 //" registros processados com erro."
         Else
            cDesc := cValToChar(aTabProc[nI,4]) + STR0031 //" registro processado com erro."
         EndIf
         aAdd(aCpos, {AllTrim(aTabProc[nI,1]) + " - " + AllTrim(aTabProc[nI,2]),;
                      cDesc})
         If aTabProc[nI,3] > 0
            If aTabProc[nI,3] > 1
               cDesc := cValToChar(aTabProc[nI,3]) + STR0032 //" registros processados com sucesso."
            Else
               cDesc := cValToChar(aTabProc[nI,3]) + STR0033 //" registro processado com sucesso."
            EndIf
            aAdd(aCpos, {AllTrim(aTabProc[nI,1]) + " - " + AllTrim(aTabProc[nI,2]),;
                         cDesc})
         EndIf
      Else
         If aTabProc[nI,3] > 1
            cDesc := cValToChar(aTabProc[nI,3]) + STR0032 //" registros processados com sucesso."
         Else
            If aTabProc[nI,3] == 0
               cDesc := STR0039 //"Nenhum registro processado."
            Else
               cDesc := cValToChar(aTabProc[nI,3]) + STR0033 //" registro processado com sucesso."
            EndIf
         EndIf
         aAdd(aCpos, {AllTrim(aTabProc[nI,1]) + " - " + AllTrim(aTabProc[nI,2]),;
                      cDesc})
      EndIf
   Next nI

   If Len(aCpos) < 1
   	aAdd(aCpos, {"",""})
   EndIf

   IF !lAutoMacao
      DEFINE DIALOG oDlgPrc TITLE STR0034 FROM 0,0 TO 220,457 PIXEL //"Resultado"

      @ 01,01 LISTBOX oLbx FIELDS HEADER STR0035, STR0036 SIZE 230,95 OF oDlgPrc PIXEL //"Tabela", "Status"

      oLbx:SetArray( aCpos )

      oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}

      DEFINE SBUTTON FROM 98,205 TYPE 1 ACTION (oDlgPrc:End())  ENABLE OF oDlgPrc

      ACTIVATE MSDIALOG oDlgPrc CENTERED
   ENDIF

Return

//---------------------------------------------------------
// Classe construtura dos filtros especificos dinamicos
Class PCPA111F
   //Método construtor da classe
   Method New(oDlg,cId,cDesc,nPosAlt,nPosLar) Constructor

   //Propriedades
   Data cId
   Data cDesc
   Data oFilt
   Data oDlgFil
   Data cFiltro
   Data nParAberto
   Data cLastEvent
   Data lExec
   Data aDadosSub

   //Métodos
   Method Dialog()
   Method getValues()
   Method setValues()
EndClass
//---------------------------------------------------------
Method New(oDlg,cId,cDesc,nPosAlt,nPosLar) Class PCPA111F
   Local oBtn
   Default lAutoMacao := .F.

   Self:cId        := cId
   Self:cDesc      := cDesc
   Self:cFiltro    := ""
   Self:cLastEvent := "operador"
   Self:nParAberto := 0
   Self:lExec      := .T.
   Self:aDadosSub  := {}
   aAdd(Self:aDadosSub,{0,"operador","",.T.})
   aAdd(Self:aDadosSub,{0,"operador","",.T.})

   IF !lAutoMacao
      @ nPosAlt-2,nPosLar BUTTON oBtn PROMPT "..."  SIZE 12,10 WHEN (.T.) ACTION (Self:Dialog()) OF oDlg PIXEL
   ENDIF
Return Self
//---------------------------------------------------------
Method Dialog() Class PCPA111F
   Local nTamanho := 0

   If Self:cId == "SB2"
      nTamanho := 415
   Else
      nTamanho := 347
   EndIf

   DEFINE DIALOG Self:oDlgFil TITLE Self:cDesc FROM 0,0 TO nTamanho,500 PIXEL

   Self:oFilt := PCPA109F():New(Self:cId,Self:oDlgFil,.T.)
   Self:setValues()

   If Self:cId == "SB2"
      nTamanho := 193
   Else
      nTamanho := 156
   EndIf

   @ nTamanho, 05 BUTTON oBtn PROMPT STR0037 SIZE 60,12 WHEN (.T.) ACTION {||btnConfirm(Self)} OF Self:oDlgFil PIXEL //"Confirmar"
   @ nTamanho, 70 BUTTON oBtn PROMPT STR0038 SIZE 60,12 WHEN (.T.) ACTION {||Self:oDlgFil:End()} OF Self:oDlgFil PIXEL //"Cancelar"

   ACTIVATE MSDIALOG Self:oDlgFil CENTERED

Return Nil

Static Function btnConfirm(oTela)
	Local nI         := 0
	Local lRoda      := .F.
	Local cFiltro    := ""
	Local nParAberto := 0
	Local cLastEvent := "operador"
	Local lExec      := .T.
	Local aDados     := {}


	cFiltro    := oTela:cFiltro
	nParAberto := oTela:nParAberto
	cLastEvent := oTela:cLastEvent
	lExec      := oTela:lExec
	For nI := 1 To Len(oTela:aDadosSub)
		aAdd(aDados,{oTela:aDadosSub[nI,1],;
							oTela:aDadosSub[nI,2],;
							oTela:aDadosSub[nI,3],;
							oTela:aDadosSub[nI,4]})
	Next nI

	oTela:getValues()

	If oTela:cId == "SB2"
		If oTela:lExec
			lRoda := .T.
		EndIf
		For nI := 1 To Len(oTela:aDadosSub)
			If oTela:aDadosSub[nI,4]
				lRoda := .T.
			EndIf
		Next nI
		If lRoda
			oTela:oDlgFil:End()
		Else
			oTela:cFiltro    := cFiltro
			oTela:nParAberto := nParAberto
			oTela:cLastEvent := cLastEvent
			oTela:lExec      := lExec
			For nI := 1 To Len(oTela:aDadosSub)
				oTela:aDadosSub[nI,1] := aDados[nI,1]
				oTela:aDadosSub[nI,2] := aDados[nI,2]
				oTela:aDadosSub[nI,3] := aDados[nI,3]
				oTela:aDadosSub[nI,4] := aDados[nI,4]
			Next nI
			MSGALERT( STR0049, STR0009 ) //"Necessário selecionar ao menos uma tabela para processamento." | "Atenção"
			Return
		EndIf
	Else
		oTela:oDlgFil:End()
	EndIf
Return

//---------------------------------------------------------
Method getValues() Class PCPA111F
   Local nI := 0

   Self:cFiltro    := Self:oFilt:cFiltro
   Self:nParAberto := Self:oFilt:nParAberto
   Self:cLastEvent := Self:oFilt:cLastEvent
   Self:lExec      := Self:oFilt:lExec
   For nI := 1 To Len(Self:oFilt:aSubFolder)
   	Self:aDadosSub[nI,2] := Self:oFilt:aSubFolder[nI]:cLastEvent
   	Self:aDadosSub[nI,1] := Self:oFilt:aSubFolder[nI]:nParAberto
   	Self:aDadosSub[nI,3] := Self:oFilt:aSubFolder[nI]:cFiltro
   	Self:aDadosSub[nI,4] := Self:oFilt:aSubFolder[nI]:lExec
   Next nI
Return .T.
//---------------------------------------------------------
Method setValues() Class PCPA111F
   Local nI := 0

   Self:oFilt:cFiltro    := Self:cFiltro
   Self:oFilt:nParAberto := Self:nParAberto
   Self:oFilt:cLastEvent := Self:cLastEvent
   Self:oFilt:lExec := Self:lExec
   For nI := 1 To Len(Self:oFilt:aSubFolder)
   	Self:oFilt:aSubFolder[nI]:cLastEvent := Self:aDadosSub[nI,2]
   	Self:oFilt:aSubFolder[nI]:nParAberto := Self:aDadosSub[nI,1]
   	Self:oFilt:aSubFolder[nI]:cFiltro    := Self:aDadosSub[nI,3]
   	Self:oFilt:aSubFolder[nI]:lExec      := Self:aDadosSub[nI,4]
   Next nI
Return .T.
