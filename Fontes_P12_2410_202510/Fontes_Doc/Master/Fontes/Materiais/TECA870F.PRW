#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA870F.CH"

Static cTmpAlias:= ""
Static aVerbas 	:= {}
Static aBenefi 	:= {}
Static aMAT_MI 	:= {}
Static aMAT_MC 	:= {}
Static aARM		:= {}
Static aUNIF	:= {}
Static oGSTmpTb := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA870F
Monitor de Marcações de Atendentes
@sample TECA870F()
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Function TECA870F()

	Local cPerg := "TECA870F"
    Local aArea := GetArea()

    Private cCadastro := STR0001 //"Reajuste de Planilhas de Contratos"

	If TecHasPerg("MV_PAR01", "TECA870F")
		If Pergunte(cPerg,.T.)
			MakeSQLEXPR(cPerg)
			AT870FBrow(cPerg)
		EndIf
	Else
		Help(" ", 1, "TECA870F", Nil, STR0012, 1) //"Para utilizar a rotina é necessário criar o pergunte TECA870F, indicado no TDN."
	EndIf

    RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FBrow
Definicao do Objeto Browse
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT870FBrow(cPerg)

	Local oBrowse  := Nil
    Local aStruct  := AT870FaStru()
    Local aColumns := {}
	Local aSeek    := {}

	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetDataQuery(.F.)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetFieldMark("OK") 
	oBrowse:SetAllMark({||oBrowse:AllMark()}) 

    FwMsgRun(Nil,{|oSay|At870FCria(@oBrowse,oSay)}, STR0002, STR0003) //"Aguarde..."###"Processando a requisição solicitada..."

    oBrowse:SetMenuDef("")
	oBrowse:SetParam({||AT870FAtBrw(@oBrowse,cPerg)})
	oBrowse:SetDescription(OEmToAnsi(cCadastro))

	oBrowse:AddButton(STR0004, {||At870FExec(@oBrowse,cPerg)}) //"Gerar Revisão"
	oBrowse:AddButton(STR0005, {||AT870FAtBrw(@oBrowse,cPerg)}) //"Parametros"
	oBrowse:AddButton(STR0006, {||CloseBrowse()}) //"Sair"

	oBrowse:AddStatusColumns({||AT870FStatus()},{||AT870FLegend()})
	aColumns := AT870FaCols(aStruct)
	oBrowse:SetColumns(aColumns)

	aAdd(aSeek, {TxDadosCpo("TFJ_CODIGO")[1],{{"","C",TamSX3("TFJ_CODIGO")[1],TamSX3("TFJ_CODIGO")[2],TxDadosCpo("TFJ_CODIGO")[1],PesqPict("TFJ","TFJ_CODIGO"),NIL}},1,.T.})
	aAdd(aSeek, {TxDadosCpo("TFJ_CONTRT")[1],{{"","C",TamSX3("TFJ_CONTRT")[1],TamSX3("TFJ_CONTRT")[2],TxDadosCpo("TFJ_CONTRT")[1],PesqPict("TFJ","TFJ_CONTRT"),NIL}},2, .T.})
	oBrowse:SetSeek(.T., aSeek)

	oBrowse:DisableConfig()
    oBrowse:DisableReport()
    oBrowse:DisableDetails()

	oBrowse:Activate()

	FwFreeArray(aStruct)
	FwFreeArray(aColumns)
	FreeObj(oBrowse)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FStatus
Status do Planilha do contrato
@since	19/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT870FStatus()

	Local cAliasTmp := At870FAlias()
	Local cStatus   := "BR_VERDE"

	If (cAliasTmp)->(REVISA)
		cStatus := "BR_VERMELHO"
	EndIf

Return cStatus

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FLegend
Exibe a Legenda
@since	19/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT870FLegend()

	Local oLegend := FWLegend():New()

	oLegend:Add("","BR_VERDE"	,STR0032) //"Config. Planilha atualizada"
	oLegend:Add("","BR_VERMELHO",STR0033) //"Config. Planilha desatualizada"
	oLegend:Activate()
	oLegend:View()
	oLegend:DeActivate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FAtBrw
Criacao do Objeto Browse
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT870FAtBrw(oBrowse,cPerg,lShow)

	Default lShow := .T.

	If Pergunte(cPerg,lShow)
		MakeSQLEXPR(cPerg)
		(At870FAlias())->(DbCloseArea())
		FwMsgRun(Nil,{|oSay|At870FCria(@oBrowse,oSay)}, STR0002, STR0003) //"Aguarde..."###"Processando a requisição solicitada..."
		oBrowse:Refresh(.T.)
	EndIf
	
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FAlias
Retorna alias uso do browse
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FAlias(cSetValue)

	If VALTYPE(cSetValue) == "C"
		cTmpAlias := cSetValue
	EndIf

Return cTmpAlias

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FCria
Criacao tabela temporaria
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FCria(oBrw,oSay)

	Local cAliasTmp  := IIF(EMPTY(At870FAlias()), GetNextAlias(), At870FAlias())
	Local aTmpStruct := AT870FaStru()
	Local aInsert    := {}
	Local aIdx       := {}
	Local aRetSal    := {}
	Local aRetMat    := {}
	Local cAliasAux  := GetNextAlias()
	Local cQry       := ""
	Local cField     := ""
	Local cMV_PAR02  := "1 = 1"
	Local cMV_PAR03  := "1 = 1"
	Local cMV_PAR04  := "1 = 1"
	Local cMV_PAR05  := "1 = 1"
	Local cMV_PAR06  := "1 = 1"
	Local cDescr     := STR0017 //"Existem valores de salário base, Beneficios ou Verbas reajustados."
	Local nX         := 0
	Local nAtual     := 1
	Local lRetVer    := .F.
	Local lRetBen    := .F.
	Local lRetArm    := .F.
	Local lRetUni    := .F.
	Local lRevisa    := .F.
	Local xValue
	Local oQry

	aMAT_MI := {}
	aMAT_MC := {}
	aVerbas := {}
	aBenefi := {}
	aARM    := Array(0)
	aUNIF   := Array(0)

	If VALTYPE(oGSTmpTb) == "O"
		oGSTmpTb:Close()
		TecDestroy(oGSTmpTb)
	EndIf

	//Cria indices para a tabela temporária 
	Aadd(aIdx, {"I1",{ "TFJ_CODIGO" }})
	Aadd(aIdx, {"I2",{ "TFJ_CONTRT" }})

	oGSTmpTb := GSTmpTable():New(cAliasTmp,aTmpStruct,aIdx)
	If oGSTmpTb:CreateTMPTable()

		If !Empty(MV_PAR02)
			cMV_PAR02 := MV_PAR02
		EndIf

		If !Empty(MV_PAR03)
			cMV_PAR03 := MV_PAR03
		EndIf

		If !Empty(MV_PAR04)
			cMV_PAR04 := MV_PAR04
		EndIf

		If !Empty(MV_PAR05)
			cMV_PAR05 := MV_PAR05
		EndIf

		If !Empty(MV_PAR06)
			cMV_PAR06 := MV_PAR06
		EndIf

		If "CN9_NUMERO" $ MV_PAR04
			cMV_PAR04 := Replace(MV_PAR04,"CN9_NUMERO","TFJ_CONTRT")
		EndIf

		cQry := At870FQryGen(aTmpStruct)
		oQry := FwPreparedStatement():New(cQry)
		oQry:SetNumeric( 1, RetSqlName( "TFF" ) )
		oQry:SetNumeric( 2, RetSqlName( "TFL" ) )
		oQry:SetNumeric( 3, FWJoinFilial("TFL", "TFF") )
		oQry:SetNumeric( 4, RetSqlName( "TFJ" ) )
		oQry:SetNumeric( 5, FWJoinFilial("TFJ", "TFL") )
		oQry:SetNumeric( 6, cMV_PAR04 ) //Contrato
		oQry:SetNumeric( 7, RetSqlName( "TFJ" ) )
		oQry:SetNumeric( 8, RetSqlName( "ABS" ) )
		oQry:SetString( 9, FwxFilial( "ABS" ) )
		oQry:SetNumeric( 10, cMV_PAR05 ) //Local
		oQry:SetNumeric( 11, RetSqlName( "SRJ" ) )
		oQry:SetString( 12, FwxFilial( "SRJ" ) )
		oQry:SetNumeric( 13, cMV_PAR06 ) //Função
		oQry:SetNumeric( 14, RetSqlName( "SA1" ) )
		oQry:SetString( 15, FwxFilial( "SA1" ) )
		oQry:SetNumeric( 16, cMV_PAR02 ) //Cliente
		oQry:SetNumeric( 17, cMV_PAR03 ) //Loja
		oQry:SetNumeric( 18, RetSqlName( "ABW" ) )
		oQry:SetString( 19, FwxFilial( "ABW" ) )
		oQry:SetNumeric( 20, RetSqlName( "TCW" ) )
		oQry:SetString( 21, FwxFilial( "TCW" ) )
		oQry:SetString( 22, FwxFilial( "TFF" ) )
		cQry := oQry:GetFixQuery()
		MPSysOpenQuery(cQry, cAliasAux)

		While (cAliasAux)->(!EOF())

			// Existem valores de salário base, Beneficios, Verbas,
			// Materiais de Consumo, Materiais de Implantação ou Armamento reajustados.
			aRetSal := At870FSalVld(cAliasAux)
			aRetMat := At870FMatVld(cAliasAux)
			lRetVer := At870FVerVld(cAliasAux)
			lRetBen := At870FBenVld(cAliasAux)
			lRetArm := At870FArmVld(cAliasAux)
			lRetUni := At870FUniVld(cAliasAux)
			lRevisa := "2" $ (cAliasAux)->(ABW_ULTIMA)

			If aRetSal[1] .Or. aRetMat[1] .Or. aRetMat[2] .Or. lRetVer .Or. lRetBen .Or. lRevisa .Or. lRetArm .Or. lRetUni
				aInsert := {}
				For nX := 1 To LEN(aTmpStruct)
					cField := aTmpStruct[nX][1]
					If cField == "OK"
						Aadd(aInsert, {cField, " " })
					ElseIf cField == "RJ_SALARIO"
						Aadd(aInsert, {cField, aRetSal[2] })
					ElseIf cField == "REVISA"
						Aadd(aInsert, {cField, lRevisa })
					ElseIf cField == "TFF_PRCVEN"
						Aadd(aInsert, {cField, aRetSal[3] })
					ElseIf cField == "SALBAS"
						Aadd(aInsert, {cField, aRetSal[1] })
					ElseIf cField == "MAT_MI"
						Aadd(aInsert, {cField, aRetMat[1] })
					ElseIf cField == "MAT_MC"
						Aadd(aInsert, {cField, aRetMat[2] })
					ElseIf cField == "VERBAS"
						Aadd(aInsert, {cField, lRetVer })
					ElseIf cField == "BENEFI"
						Aadd(aInsert, {cField, lRetBen })
					ElseIf cField == "ARMAMENTO"
						Aadd(aInsert, {cField, lRetArm })
					ElseIf cField == "UNIFORME"
						Aadd(aInsert, {cField, lRetUni })
					ElseIf cField == "DESCRI"
						cDescr := ""
						If aRetSal[1]
							cDescr += STR0018 //"Alteração do Salário Base da Função"
						EndIf
						If lRetVer
							If !Empty(cDescr)
								cDescr += " / "
							EndIf
							cDescr += STR0019 //"Alteração das Verbas"
						EndIf
						If aRetMat[1] .Or. aRetMat[2]
							If !Empty(cDescr)
								cDescr += " / "
							EndIf
							cDescr += STR0021 //"Alteração do Custo de Materiais"
						EndIf
						If lRetBen
							If !Empty(cDescr)
								cDescr += " / "
							EndIf
							cDescr += STR0020 //"Alteração dos Benefícios"
						EndIf
						If lRetArm
							If !Empty(cDescr)
								cDescr += " / "
							EndIf
							cDescr += STR0042 //"Alteração dos Armamentos"
						EndIf
						If lRetUni
							If !Empty(cDescr)
								cDescr += " / "
							EndIf
							cDescr += STR0043 //"Alteração dos Uniformes"
						EndIf
						Aadd(aInsert, {cField, cDescr })
					ElseIf !(cField $ "REVTCW")
						xValue := (&("(cAliasAux)->" + cField))
						If aTmpStruct[nX][2] == "D"
							// Aadd(aInsert, {cField, STOD(xValue) })
						Else
							Aadd(aInsert, {cField, xValue })
						EndIf
					EndIf
					oSay:SetText(STR0007 + cValToChar(nAtual)) //"Processando o registro : "
					ProcessMessages()
				Next nX

				If ( lRet := ( oGSTmpTb:Insert(aInsert) .AND. oGSTmpTb:Commit() ) )
					(cAliasAux)->(DbSkip())
				Else
					oGSTmpTb:ShowErro()
					Exit
				EndIf

				nAtual++
			Else
				(cAliasAux)->(DbSkip())
			EndIf

		EndDo

		(cAliasAux)->(dbCloseArea())
		oQry:Destroy()
		FwFreeObj(oQry)

	Else
		// oGSTmpTb:ShowErro()
	EndIf

	At870FAlias(oGSTmpTb:cAliasTmp)
	(At870FAlias())->(DbGoTop())
	oBrw:SetAlias((At870FAlias()))

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FaStru
Definicao dos campos uso do browse
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT870FaStru()

	Local aRet := {}
	Aadd(aRet, At870FField("OK"))
	Aadd(aRet, At870FField("TFJ_FILIAL"))
	Aadd(aRet, At870FField("TFJ_CONTRT"))
	Aadd(aRet, At870FField("TFJ_CODIGO"))
	Aadd(aRet, At870FField("TFJ_CONREV"))
	Aadd(aRet, At870FField("TFJ_STATUS"))
	Aadd(aRet, At870FField("TFL_LOCAL"))
	Aadd(aRet, At870FField("ABS_DESCRI"))
	Aadd(aRet, At870FField("A1_COD"))
	Aadd(aRet, At870FField("A1_LOJA"))
	Aadd(aRet, At870FField("A1_NOME"))
	Aadd(aRet, At870FField("TFF_COD"))
	Aadd(aRet, At870FField("RJ_FUNCAO"))
	Aadd(aRet, At870FField("RJ_DESC"))
	Aadd(aRet, At870FField("TFF_PRCVEN"))
	Aadd(aRet, At870FField("RJ_SALARIO"))
	Aadd(aRet, At870FField("DESCRI"))
	Aadd(aRet, At870FField("REVISA"))
	Aadd(aRet, At870FField("REVTCW"))
	Aadd(aRet, At870FField("SALBAS"))
	Aadd(aRet, At870FField("MAT_MI"))
	Aadd(aRet, At870FField("MAT_MC"))
	Aadd(aRet, At870FField("VERBAS"))
	Aadd(aRet, At870FField("BENEFI"))
	Aadd(aRet, At870FField("ARMAMENTO"))
	Aadd(aRet, At870FField("UNIFORME"))

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FField
Definicao das colunas uso do browse
@since  12/06/2024
@author flavio.vicco
@return Array Campo, Tipo, Tamanho, Decimais
/*/
//------------------------------------------------------------------------------
Static Function At870FField(cField)

	Local aRet   := {}
	Local aField := {}

	If cField $ "OK"
		aField := {cField, "C", 1, 0}
	ElseIf cField == "DESCRI"
		aField := {cField, "C", 150, 0}
	ElseIf cField $ "SALBAS|MAT_MI|MAT_MC|VERBAS|BENEFI|REVISA|REVTCW|ARMAMENTO|UNIFORME"
		aField := {cField, "L", 1, 0}
	Else
		aRet   := FwTamSx3(cField)
		aField := {cField, aRet[3], aRet[1], aRet[2]}
	EndIf

Return aField

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FQryGen
Retorna query uso do browse para retornar Contratos em com Status 1=Ativo ou 2=Em Revisão (se existir).
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FQryGen(aTmpStruct)

	Local cQuery := ""

    cQuery := "SELECT TFJ.TFJ_FILIAL, TFJ.TFJ_CODIGO, TFJ.TFJ_CONTRT, TFJ.TFJ_CONREV, TFJ.TFJ_STATUS, "
	cQuery += "TFL.TFL_LOCAL, LOC.ABS_DESCRI, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SRJ.RJ_FUNCAO, SRJ.RJ_DESC, SRJ.RJ_SALARIO, "
	cQuery += "TFF.TFF_COD, TFF.TFF_PLACOD, TFF.TFF_PLAREV, TFF.TFF_PRCVEN, ABW.ABW_ULTIMA, TCW.TCW_ULTIMA "
    cQuery += "FROM ? TFF "
    cQuery += "INNER JOIN ? TFL ON ? AND TFL.TFL_CODIGO=TFF.TFF_CODPAI AND TFL.D_E_L_E_T_=' ' "
    cQuery += "INNER JOIN ? TFJ ON ? AND TFJ.TFJ_CODIGO=TFL.TFL_CODPAI AND TFJ.TFJ_CONTRT<>' ' AND (TFJ.TFJ_STATUS='1' OR TFJ.TFJ_STATUS='2') AND TFJ.D_E_L_E_T_=' ' AND ? "
	cQuery += "AND NOT EXISTS (SELECT 1 FROM ? REV WHERE REV.TFJ_FILIAL = TFJ.TFJ_FILIAL AND REV.TFJ_CODIGO<>TFJ.TFJ_CODIGO AND REV.TFJ_CONTRT=TFJ.TFJ_CONTRT AND REV.D_E_L_E_T_=' ' AND (REV.TFJ_STATUS = '2' OR REV.TFJ_STATUS = '4')) "
    cQuery += "INNER JOIN ? LOC ON LOC.ABS_FILIAL= ? AND LOC.ABS_LOCAL=TFL.TFL_LOCAL AND LOC.D_E_L_E_T_=' ' AND ? "
    cQuery += "INNER JOIN ? SRJ ON SRJ.RJ_FILIAL = ? AND SRJ.RJ_FUNCAO=TFF.TFF_FUNCAO AND SRJ.D_E_L_E_T_=' ' AND ? "
    cQuery += "INNER JOIN ? SA1 ON SA1.A1_FILIAL = ? AND SA1.A1_COD=TFJ.TFJ_CODENT AND SA1.A1_LOJA=TFJ.TFJ_LOJA AND SA1.D_E_L_E_T_=' ' AND ? AND ? "
	cQuery += "INNER JOIN ? ABW ON ABW.ABW_FILIAL= ? AND ABW.ABW_CODIGO=TFF.TFF_PLACOD AND ABW.ABW_REVISA=TFF.TFF_PLAREV AND ABW.D_E_L_E_T_= ' ' "
	cQuery += "INNER JOIN ? TCW ON TCW.TCW_FILIAL= ? AND TCW.TCW_CODIGO=ABW.ABW_CODTCW AND TCW.TCW_REVISA=ABW.ABW_RESTCW AND TCW.D_E_L_E_T_=' ' "
    cQuery += "WHERE TFF.TFF_FILIAL= ? AND TFF.D_E_L_E_T_=' ' AND TFF.TFF_PLACOD<>' ' "
	cQuery := ChangeQuery(cQuery)

Return cQuery

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FaCols
Definicao das colunas uso do browse
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT870FaCols(aStru)

	Local nY       := 0
	Local nTam     := 0
	Local aColumns := {}
	Local cAlias   := At870FAlias()
	Local cField   := ""
	Local cMasc    := ""
	Local cTitle   := ""

	For nY := 1 To Len(aStru)
		cField := aStru[nY][1]
		If !(cField $ "OK|TFF_COD|RREVISA|REVTCW")
			cMasc := X3Picture(cField)
			If cField $ "TFJ_CODIGO"
				cTitle := STR0013 //"Orçamento"
			ElseIf cField $ "RJ_SALARIO"
				cTitle := STR0014 //"Sal. Base Função"
			ElseIf cField $ "TFF_PRCVEN"
				cTitle := STR0015 //"Sal. Base Contrato"
			ElseIf cField $ "DESCRI"
				cTitle := STR0016 //"Descrição"
			Else
				cTitle := AllTrim(RetTitle(cField))
			EndIf
			AAdd(aColumns,FWBrwColumn():New())
			nTam := Len(aColumns)
			If aStru[nY][2] == "C"
				aColumns[nTam]:SetData(&("{||Rtrim("+(cAlias)+"->"+(cField)+")}"))
			Else
				aColumns[nTam]:SetData(&("{||"+cAlias+"->"+cField+"}"))
			EndIf
			aColumns[nTam]:SetTitle(cTitle)
			aColumns[nTam]:SetSize(aStru[nY][3])
			aColumns[nTam]:SetDecimal(aStru[nY][4])
			aColumns[nTam]:SetPicture(cMasc)
		EndIf
	Next nY

Return aColumns

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FSalVld
Retorna Pesquisar Salario Base com valores a maior ao informado no Posto/Planilha
@since  16/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FSalVld(cAlias)

	Local aAreaSav := GetArea()
	Local aRet     := {.F.,0,0}
	Local cFuncao  := ""
	Local nSalBase := 0
	Local aExec	   := {}

	// Pesquisar Salario Base da Planilha do Posto XML
	nSalBase := At870FPsqTag((cAlias)->(TFF_COD),"VLR_SB")

	// Pesquisar a Funcao do Modelo da Planilha do Posto
	cFuncao := Posicione("ABW",1,xFilial("ABW")+(cAlias)->(TFF_PLACOD+TFF_PLAREV),"ABW_FUNCAO")
	If Empty(cFuncao)
		// Usa Funcao do Posto caso nao informado
		cFuncao := (cAlias)->RJ_FUNCAO
	EndIf

	// Comparar Salario Base da Funcao x Salario Base Planiha do Posto
	If nSalBase > 0 .And. (cAlias)->RJ_SALARIO > nSalBase
		aRet[1] := .T.
		aRet[2] := SRJ->RJ_SALARIO
		aRet[3] := nSalBase
	EndIf

	If nSalBase > 0
		if ExistBlock("at870FSa")
			aExec := ExecBlock("at870FSa",.F.,.F.,{(cAlias)->(TFF_COD),cFuncao,aRet,nSalBase})               
			If Valtype(aExec) == "A"
				aRet := aClone( aExec )
			EndIf 
			aExec := {}
		endif
	endif

	RestArea(aAreaSav)

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FMatVld
Retorna Pesquisar Materias com valores a maior ao informado no Posto/Planilha
@since  19/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FMatVld(cAlias)

	Local aAreaSav  := GetArea()
	Local aRet      := {.F.,.F.}
	Local cAliasTmp := GetNextAlias()
	Local cCodTFF   := (cAlias)->(TFF_COD)
	Local cQry      := ""
	Local oQry

	cQry := " SELECT TFG.TFG_CODPAI, TFG.TFG_COD, TFG.TFG_PRODUT, TFG.TFG_PRCVEN, SB1.B1_PRV1 "
	cQry += " FROM ? TFG "
	cQry += " INNER JOIN ? SB1 "
	cQry += " ON SB1.B1_FILIAL = ? AND SB1.B1_COD = TFG.TFG_PRODUT AND SB1.D_E_L_E_T_=' ' "
	cQry += " WHERE TFG.TFG_FILIAL = ? AND TFG.TFG_CODPAI = ? AND TFG.D_E_L_E_T_=' ' "

	oQry := FwPreparedStatement():New(cQry)
	oQry:SetNumeric( 1, RetSqlName( "TFG" ) )
	oQry:SetNumeric( 2, RetSqlName( "SB1" ) )
	oQry:SetString(  3, FwxFilial( "SB1" ) )
	oQry:SetString(  4, FwxFilial( "TFG" ) )
	oQry:SetString(  5, cCodTFF )
	cQry := oQry:GetFixQuery()
	MPSysOpenQuery(cQry, cAliasTmp)

	While (cAliasTmp)->(!Eof())
		If (cAliasTmp)->(B1_PRV1) > (cAliasTmp)->(TFG_PRCVEN)
			aAdd(aMAT_MI,{(cAliasTmp)->(TFG_COD), (cAliasTmp)->(B1_PRV1), (cAliasTmp)->(TFG_CODPAI)})
			aRet[1] := .T.
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())
	oQry:Destroy()
	FwFreeObj(oQry)

	cQry := " SELECT TFH.TFH_CODPAI, TFH.TFH_COD, TFH.TFH_PRODUT, TFH.TFH_PRCVEN, SB1.B1_PRV1 "
	cQry += " FROM ? TFH "
	cQry += " INNER JOIN ? SB1 "
	cQry += " ON SB1.B1_FILIAL = ? AND SB1.B1_COD = TFH.TFH_PRODUT AND SB1.D_E_L_E_T_=' ' "
	cQry += " WHERE TFH.TFH_FILIAL = ? AND TFH.TFH_CODPAI = ? AND TFH.D_E_L_E_T_=' ' "

	oQry := FwPreparedStatement():New(cQry)
	oQry:SetNumeric( 1, RetSqlName( "TFH" ) )
	oQry:SetNumeric( 2, RetSqlName( "SB1" ) )
	oQry:SetString(  3, FwxFilial( "SB1" ) )
	oQry:SetString(  4, FwxFilial( "TFH" ) )
	oQry:SetString(  5, cCodTFF )
	cQry := oQry:GetFixQuery()
	MPSysOpenQuery(cQry, cAliasTmp)

	While (cAliasTmp)->(!Eof())
		If (cAliasTmp)->(B1_PRV1) > (cAliasTmp)->(TFH_PRCVEN)
			aAdd(aMAT_MC,{(cAliasTmp)->(TFH_COD), (cAliasTmp)->(B1_PRV1), (cAliasTmp)->(TFH_CODPAI)})
			aRet[2] := .T.
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())
	oQry:Destroy()
	FwFreeObj(oQry)

	RestArea(aAreaSav)

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FVerVld
Retorna Pesquisar Verbas da Cnf Planilhas para comparar com a Planilha do Orçamento
@since  16/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FVerVld(cAlias)

	Local aAreaSav  := GetArea()
	Local cAliasTCX := GetNextAlias()
	Local cCfgCalc  := ""
	Local cCfgRevi  := ""
	Local cCodTFF 	:= ""
	Local lRet      := .F.
	Local cQry      := ""
	Local nVlrBen	:= 0
	Local oQry		:= Nil
	Local aExec		:= {}

	// Pesquisar a Funcao do Modelo da Planilha do Posto
	DbSelectArea("ABW")
	DbSetOrder(1) //ABW_FILIAL+ABW_CODIGO+ABW_REVISA
	If ABW->(DbSeek(xFilial("ABW")+(cAlias)->(TFF_PLACOD+TFF_PLAREV)))
		cCfgCalc := ABW->ABW_CODTCW
		cCfgRevi := ABW->ABW_RESTCW
	EndIf

	cCodTFF := (cAlias)->TFF_COD

	// Pesquisar Config x Verbas
	If !Empty(cCfgCalc)

		cQry := "SELECT TCX.TCX_NICKPO, TCX.TCX_CODIGO, TCX.TCX_PORCEN, TCX.TCX_PORALT, SRV.RV_PERC FROM ? TCX "
		cQry += "INNER JOIN ? SRV ON "
		cQry += "SRV.RV_FILIAL = ? AND SRV.RV_COD = TCX.TCX_CODTBL AND SRV.D_E_L_E_T_=' ' "
		cQry += "WHERE TCX.TCX_FILIAL = ? "
		cQry += "AND TCX.TCX_CODTCW = ? "
		cQry += "AND TCX.TCX_REVISA = ? "
		cQry += "AND TCX.TCX_TIPOPE = '1' "
		cQry += "AND TCX.TCX_NICKPO <> ' ' "
		cQry += "AND TCX.D_E_L_E_T_=' ' "

		oQry := FwPreparedStatement():New(cQry)
		oQry:SetNumeric( 1, RetSqlName( "TCX" ) )
		oQry:SetNumeric( 2, RetSqlName( "SRV" ) )
		oQry:SetString( 3, FwxFilial( "SRV" ) )
		oQry:SetString( 4, FwxFilial( "TCX" ) )
		oQry:SetString( 5, cCfgCalc )
		oQry:SetString( 6, cCfgRevi )
		cQry := oQry:GetFixQuery()
		MPSysOpenQuery(cQry, cAliasTCX)
	
		While (cAliasTCX)->(!Eof())
			nVlrBen := (cAliasTCX)->(RV_PERC)
			nPorAlt := At870FPsqTag((cAlias)->(TFF_COD), (cAliasTCX)->(TCX_NICKPO))
			If nPorAlt > 0 .And. nVlrBen > nPorAlt
				If aScan(aVerbas, {|x| x[1]==(cAliasTCX)->(TCX_NICKPO) .AND. x[2]==nVlrBen .AND. x[3]==cCodTFF}) == 0
					aAdd(aVerbas,{(cAliasTCX)->(TCX_NICKPO), ; //Nick do benefício na Configuração de Cálculo
									nVlrBen, ; //Valor do benefício no RH
									cCodTFF, ; //Código do Posto
									(cAliasTCX)->(TCX_CODIGO), ; //Código da TCX dentro da Configuração de Cálculo
									cCfgRevi, ; //Revisão da Configuração de Cálculo
									(cAliasTCX)->(TCX_PORCEN), ; //Valor diario CCT na Configuração de Cálculo
									(cAliasTCX)->(TCX_PORALT), ; //Valor diario diferenciado na Configuração de Cálculo
									(nVlrBen > (cAliasTCX)->(TCX_PORCEN)) .Or. ((cAliasTCX)->(TCX_PORALT) <> 0 .And. nVlrBen > (cAliasTCX)->(TCX_PORALT))}) //Se é necessário atualizar a configuração de cálculo
				EndIf
				lRet := .T.
			EndIf
			(cAliasTCX)->(DbSkip())
		EndDo

		(cAliasTCX)->(DbCloseArea())
		oQry:Destroy()
		FwFreeObj(oQry)

		If ExistBlock("at870FVb")
			aExec := ExecBlock( "at870FVb",.F.,.F.,{ (cAlias)->TFJ_FILIAL, (cAlias)->(TFF_COD), (cAlias)->(TFF_PLACOD+TFF_PLAREV), aVerbas, lRet } )               
			If Valtype(aExec) == "A"
				aVerbas := aClone( aExec[2] )
				lRet	:= aExec[1]
			EndIf 
			aExec := {}
		EndIf	

	EndIf

	RestArea(aAreaSav)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FBenVld
Retorna Pesquisar Beneficios da Cnf Planilhas para comparar com a Planilha do Orçamento
@since  16/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FBenVld(cAlias)

	Local aAreaSav  := GetArea()
	Local cAliasTDZ := GetNextAlias()
	Local cCfgCalc  := ""
	Local cCfgRevi  := ""
	Local cQry      := ""
	Local cCodTFF 	:= ""
	Local lRet      := .F.
	Local nVlrBen   := 0
	Local nVlrPln   := 0
	Local oQry		:= Nil
	Local aExec		:= {}

	// Pesquisar a Funcao do Modelo da Planilha do Posto
	DbSelectArea("ABW")
	DbSetOrder(1) //ABW_FILIAL+ABW_CODIGO+ABW_REVISA
	If ABW->(DbSeek(xFilial("ABW")+(cAlias)->(TFF_PLACOD+TFF_PLAREV)))
		cCfgCalc := ABW->ABW_CODTCW
		cCfgRevi := ABW->ABW_RESTCW
	EndIf

	cCodTFF := (cAlias)->TFF_COD

	If !Empty(cCfgCalc)

		cQry := "SELECT TDZ.TDZ_CODSLY, TDZ.TDZ_TIPBEN, TDZ.TDZ_NICKVL, TDZ.TDZ_VALOR, TDZ.TDZ_VLRDIF, TDZ.TDZ_CODIGO "
		cQry += "FROM ? TDZ "
		cQry += "INNER JOIN ? TCW ON TCW.TCW_FILIAL = ? AND TCW.TCW_CODIGO=TDZ.TDZ_CODTCW AND TCW.D_E_L_E_T_=' ' "
		cQry += "INNER JOIN ? SLY ON SLY.LY_FILIAL = ? AND SLY.LY_FILENT = ? AND SLY.LY_ALIAS = 'SWY' "
		cQry += "AND SLY.LY_CHVENT = TCW.TCW_CODCCT AND SLY.LY_CODIGO = TDZ.TDZ_CODSLY AND SLY.D_E_L_E_T_=' ' "
		cQry += "WHERE TDZ.TDZ_FILIAL= ? AND TDZ.TDZ_CODTCW = ? AND TDZ.TDZ_REVISA =  ? AND TDZ.TDZ_NICK<>' ' AND TDZ.D_E_L_E_T_=' ' "

		oQry := FwPreparedStatement():New(cQry)
		oQry:SetNumeric( 1, RetSqlName( "TDZ" ) )
		oQry:SetNumeric( 2, RetSqlName( "TCW" ) )
		oQry:SetString( 3, FwxFilial( "TCW" ) )
		oQry:SetNumeric( 4, RetSqlName( "SLY" ) )
		oQry:SetString( 5, FwxFilial( "SLY" ) )
		oQry:SetString( 6, FwxFilial( "SWY" ) )
		oQry:SetString( 7, FwxFilial( "TDZ" ) )
		oQry:SetString( 8, cCfgCalc )
		oQry:SetString( 9, cCfgRevi )
		cQry := oQry:GetFixQuery()
		MPSysOpenQuery(cQry, cAliasTDZ)

		While (cAliasTDZ)->(!Eof())
			nVlrBen := At870FVlrB((cAliasTDZ)->(TDZ_CODSLY), (cAliasTDZ)->(TDZ_TIPBEN))
			nVlrPln := At870FPsqTag((cAlias)->(TFF_COD), (cAliasTDZ)->(TDZ_NICKVL))
			If nVlrPln > 0 .And. nVlrBen > nVlrPln
				If aScan(aBenefi, {|x| x[1]==(cAliasTDZ)->(TDZ_NICKVL) .AND. x[2]==nVlrBen .AND. x[3]==cCodTFF}) == 0
					aAdd(aBenefi,{(cAliasTDZ)->(TDZ_NICKVL), ;   //Nick do benefício na Configuração de Cálculo
									nVlrBen, ; 	//Valor do benefício no RH
									cCodTFF, ; //Código do Posto
									(cAliasTDZ)->(TDZ_CODIGO), ; //Código da TDZ dentro da Configuração de Cálculo
									cCfgRevi, ; //Revisão da Configuração de Cálculo
									(cAliasTDZ)->(TDZ_VALOR), ;	//Valor diario CCT na Configuração de Cálculo
									(cAliasTDZ)->(TDZ_VLRDIF), ; //Valor diario diferenciado na Configuração de Cálculo
									(nVlrBen > (cAliasTDZ)->(TDZ_VALOR)) .Or. ((cAliasTDZ)->(TDZ_VLRDIF) <> 0 .And. nVlrBen > (cAliasTDZ)->(TDZ_VLRDIF))}) //Se é necessário atualizar a configuração de cálculo
				EndIf
				lRet := .T.
			EndIf

			(cAliasTDZ)->(DbSkip())
		EndDo

		(cAliasTDZ)->(DbCloseArea())
		oQry:Destroy()
		FwFreeObj(oQry)

		If ExistBlock("at870FBe")
			aExec := ExecBlock( "at870FBe",.F.,.F.,{ (cAlias)->TFJ_FILIAL, (cAlias)->(TFF_COD), (cAlias)->(TFF_PLACOD+TFF_PLAREV), aBenefi, lRet } )               
			If Valtype(aExec) == "A"
				aBenefi := aClone( aExec[2] )
				lRet	:= aExec[1]
			EndIf 
			aExec := {}
		EndIf

	EndIf

	RestArea(aAreaSav)
	
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FVlrB
Retorna Pesquisar Valor do beneficio
@since  12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Function At870FVlrB(cChave,cTipoBen)

	Local aAreaSav := GetArea()
	Local nRet     := 0

	Default cChave   := ""
	Default cTipoBen := ""

	cChave	:= Alltrim(cChave)
	cTipoBen := Alltrim(cTipoBen)

	If !Empty(cChave)
		// aArea := GetArea()
		If cTipoBen == "VR"
			//1=Vale Refeicao                                                                                              
			nRet := Posicione("RFO",1,xFilial("RFO")+"1"+cChave,"RFO_VALOR")
		ElseIf cTipoBen == "VA"
			//1=Vale Refeicao                   
			nRet := Posicione("RFO",1,xFilial("RFO")+"2"+cChave,"RFO_VALOR")
		ElseIf cTipoBen == "PS"
			nRet := Posicione("SG0",1,xFilial("SG0")+cChave,"G0_DESCR")
		Else
			nRet := Posicione("RIS",1,xFilial("RIS")+cTipoBen+cChave,"RIS_REF")
		EndIf
		RestArea(aAreaSav)
	EndIf

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FPsqTag
Retorna Pesquisar Nick na Planilha (XML) e retornar valor
@since  16/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FPsqTag(cCodPosto,cNick)

	Local cXML     := ""
	Local cValue   := ""
	Local nPosSal  := 0
	Local nPosIni  := 0
	Local nPosFim  := 0
	Local nRet     := 0

	// Pesquisar Salario Base da Planilha do Posto XML
	DbSelectArea("TFF")
	TFF->(DbSetOrder(1)) //TFF_FILIAL+TFF_COD
	If TFF->(DbSeek(xFilial("TFF")+cCodPosto))
		cXML := TFF->TFF_CALCMD
		nPosSal := at("<NICKNAME>"+AllTrim(cNick)+"</NICKNAME>",cXml)
		If nPosSal > 0
			nPosIni := at("<VALUE>",cXml,nPosSal)+7
			nPosFim := at("</VALUE>",cXml,nPosIni)
			cValue  := Substr(cXml,nPosIni,nPosFim-nPosIni)
			If IsNumeric(cValue)
				nRet := Val(cValue)
			EndIf
		EndIf
	EndIf

Return nRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FExec
Retorna Realiza o processamento do Reajuste
@since  25/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FExec(oBrowse,cPerg)

	FwMsgRun(Nil,{|oSay| At870FPrcRea(oSay)}, STR0035, STR0034) //"Revisão de Contratos"###"Geração da Revisão dos Contratos: "
	// AT870FAtBrw(@oBrowse,cPerg,.F.)
	CloseBrowse()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FPrcRea
Retorna Realiza o processamento do Reajuste
@since  12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FPrcRea(oSay)

	Local aAreaSav := GetArea()
	Local cAlias   := At870FAlias()
	Local aErroMVC := {}
	Local aResult  := {}
	Local cFIlTFJ  := ""
	Local cCodTFJ  := ""
	Local cContrt  := ""
	Local cRevis   := ""
	Local cCodTFF  := ""
	Local cCodSub  := ""
	Local cCodSubMI:= ""
	Local cCodSubMC:= ""
	Local cCodPla  := ""
	Local cCodRev  := ""
	Local cXML     := ""
	Local cMsg     := ""
	Local cFolder  := ""
	Local cFileLog := ""
	Local cOldTFF  := ""
	Local lAttBen  := .F.
	Local lAttVer  := .F.
	Local lRet     := .T.
	Local lTemRevis:= .F.
	Local nVlFixo  := 0
	Local nRegs    := 0
	Local nTotReg  := 0
	Local nX       := 0
	Local nZ       := 0
	Local nIni     := 0
	Local oModel   := Nil
	Local oMdlRh   := Nil
	Local oMdlTFG  := Nil
	Local oMdlTFH  := Nil
	Local oMdlTXQ  := Nil
	Local oMdlTXP  := Nil
	Local lCpoCustom	:= ExistBlock('A870CPOU')
	Local cCodSubArm  := ""
	Local cCodSubUni  := ""

	Default nTotReg	:= 0
	Default oSay	:= Nil

	If !Empty(MV_PAR01)
		// Total de Contratos selecionados
		(cAlias)->(dBGoTop())
		While !(cAlias)->(Eof())
			If !Empty((cAlias)->(OK))
				nTotReg++
			EndIf
			(cAlias)->(dBSkip())
		EndDo

		If nTotReg > 0 .And. Aviso(STR0008, STR0009, { STR0010, STR0011}, 2) == 1 //"Atencao!"###"Confirmar geração de Revisão do(s) contrato(s) selecionado(s) ?"###"Sim"###"Não"

			cFolder := AllTrim(MV_PAR07)
			If !Empty(cFolder) .And. ExistDir(cFolder)
				If Subs(cFolder,Len(cFolder),1) <> "\"
					cFolder += "\"
				EndIf
			Else
				cFolder := AllTrim(GetPvProfString(GetEnvServer(),"startpath","",GetADV97()))+"GestaoServicos\"
			EndIf
			cFileLog := AllTrim(cFilAnt)+"-"+STR0035+"-"+cValToChar(ThreadID()) //"Revisão de Contratos"

			(cAlias)->(dBGoTop())
			While !(cAlias)->(Eof())

				If !Empty((cAlias)->OK)

					nRegs++
					oSay:SetText(STR0034+AllTrim(Str(nRegs))+" / "+AllTrim(Str(nTotReg))) //"Geração da Revisão dos Contratos: "
					ProcessMessages()

					cFIlTFJ := (cAlias)->(TFJ_FILIAL)
					cCodTFJ := (cAlias)->(TFJ_CODIGO)
					cContrt := (cAlias)->(TFJ_CONTRT)
					cRevis  := (cAlias)->(TFJ_CONREV)
					cCodTFF := (cAlias)->(TFF_COD)
					cOldTFF := cCodTFF

					DbSelectArea("TFJ")
					TFJ->(DbSetOrder(1)) //TFJ_FILIAL+TFJ_CODIGO
					If TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ))

						DbSelectArea("TFF")
						TFF->(DbSetOrder(1)) //TFF_FILIAL+TFF_COD
						If TFF->(DbSeek(xFilial("TFF")+cCodTFF))
							cXML := TFF->TFF_CALCMD
							cCodPla := TFF->TFF_PLACOD
							cCodRev := TFF->TFF_PLAREV
							nVlFixo := IIF(Empty(TFF->TFF_VLFIXO), TFF->TFF_VLRCOB, TFF->TFF_VLFIXO)

							Begin Transaction

								lRet := .T.

								//Verifica se já tem Revisão Aberta:
								lTemRevis := At870PsqRev(cContrt, cRevis)

								If !lTemRevis
									//Abre uma Revisão de Contrato:
									lRet := At870PRev(cCodTFJ,cContrt,cRevis,.T.,MV_PAR01,.F.,0,0)
								EndIf

								If lRet
									TFJ->(DbSetOrder(5)) //TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV
									If TFJ->(DbSeek(xFilial("TFJ")+cContrt+cRevis))
										While TFJ->(!Eof()) .And. TFJ->(TFJ_FILIAL+TFJ_CONTRT+TFJ_CONREV) == cFIlTFJ+cContrt+cRevis 
											//No Contrato revisado pega o Código novo da TFF:
											If TFJ->TFJ_STATUS == "2"
												DbSelectArea("TFF")
												TFF->(DbSetOrder(1)) //TFF_FILIAL+TFF_COD
												If TFF->(DbSeek(xFilial("TFF")+cCodTFF))
													cCodSub := TFF->TFF_CODSUB
													// Posicionar no NOVO Posto
													If TFF->(DbSeek(xFilial("TFF")+cCodSub))
														cCodTFF := TFF->TFF_COD
														cXML    := TFF->TFF_CALCMD
														cCodPla := TFF->TFF_PLACOD
														cCodRev := TFF->TFF_PLAREV
													EndIf
												EndIf
												Exit
											EndIf
											TFJ->(dbSkip())
										EndDo
									EndIf
								EndIf

								If lRet

									TFF->(DBSeek(xFilial() + cCodTFF))
									// Carregar tela de ajustes diretamente sem abrir a tela principal
									oModel := FWLoadModel("TECA740")
									oModel:SetOperation(MODEL_OPERATION_UPDATE)
									oModel:Activate()
									oMdlRh  := oModel:GetModel("TFF_RH")
									oMdlTFG := oModel:GetModel("TFG_MI")
									oMdlTFH := oModel:GetModel("TFH_MC")
									oMdlTXQ := oModel:GetModel("TXQDETAIL")
									oMdlTXP := oModel:GetModel("TXPDETAIL")

									// Posicionar no Posto do Modelo
									oMdlRh:SeekLine({{"TFF_COD",cCodTFF}})

									// Atualizar Ultima Revisao da Planilha
									If (cAlias)->(REVISA)
										cCodRev := At870FVfRev(cCodPla)
										oMdlRh:SetValue("TFF_PLAREV",cCodRev)
										At998ExPla(ABW->ABW_INSTRU,oModel,.F.,cCodPla+cCodRev)
										cXML := oMdlRh:GetValue("TFF_CALCMD")
									EndIf

									oPlaTFF := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibição
									oPlaTFF:LoadXmlModel(cXML)

									// Atualizar Salario Base
									If (cAlias)->(SALBAS)
										If oPlaTFF:CellExists(AllTrim("VLR_SB"))
											oPlaTFF:SetCellValue("VLR_SB",cvaltochar((cAlias)->(RJ_SALARIO)))
										EndIf
									EndIf

									// Atualizar MI
									If (cAlias)->(MAT_MI)
										nIni := aScan(aMAT_MI,{|x|x[3] == cOldTFF})
										If nIni > 0
											For nX := nIni To Len(aMAT_MI)
												If cOldTFF == aMAT_MI[nX,3]
													cCodSubMI := POSICIONE("TFG",1,xFilial("TFG")+aMAT_MI[nX,1],"TFG_CODSUB")
													If oMdlTFG:SeekLine({{"TFG_COD",cCodSubMI}})
														oMdlTFG:SetValue("TFG_PRCVEN",aMAT_MI[nX,2])
													EndIf
												Else
													Exit
												EndIf
											Next nX
										EndIf
									EndIf

									// Atualizar MC
									If (cAlias)->(MAT_MC)
										nIni := aScan(aMAT_MC,{|x|x[3] == cOldTFF})
										If nIni > 0
											For nX := nIni To Len(aMAT_MC)
												If cOldTFF == aMAT_MC[nX,3]
													cCodSubMC := POSICIONE("TFH",1,xFilial("TFH")+aMAT_MC[nX,1],"TFH_CODSUB")
													If oMdlTFH:SeekLine({{"TFH_COD",cCodSubMC}})
														oMdlTFH:SetValue("TFH_PRCVEN",aMAT_MC[nX,2])
													EndIf
												Else
													Exit
												EndIf
											Next nX
										EndIf
									EndIf

									If (cAlias)->(ARMAMENTO)
										nIni := aScan(aARM, {|x| x[3] == cOldTFF})
										If nIni > 0
											For nX := nIni To Len(aARM)
												If cOldTFF == aARM[nX][3]
													cCodSubArm := POSICIONE("TXQ",1,xFilial("TXQ")+aARM[nX,1],"TXQ_CODSUB")
													If oMdlTXQ:SeekLine({{"TXQ_CODIGO",cCodSubArm}})
														oMdlTXQ:SetValue("TXQ_PRCVEN",aARM[nX,2])
													EndIf
												Else
													Exit
												EndIf
											Next nX
										EndIf
									EndIf

									If (cAlias)->(UNIFORME)
										nIni := aScan(aUNIF, {|x| x[3] == cOldTFF})
										If nIni > 0
											For nX := nIni To Len(aUNIF)
												If cOldTFF == aUNIF[nX][3]
													cCodSubUni := POSICIONE("TXP",1,xFilial("TXP")+aUNIF[nX,1],"TXP_CODSUB")
													If oMdlTXP:SeekLine({{"TXP_CODIGO",cCodSubUni}})
														oMdlTXP:SetValue("TXP_PRCVEN",aUNIF[nX,2])
													EndIf
												Else
													Exit
												EndIf
											Next nX
										EndIf
									EndIf

									// Atualizar Verbas
									If (cAlias)->(VERBAS)
										For nX := 1 To Len(aVerbas)
											If cOldTFF == aVerbas[nX][3]
												lAttVer := .T.
												If oPlaTFF:CellExists(aVerbas[nX,1])
													oPlaTFF:SetCellValue(aVerbas[nX,1], aVerbas[nX,2])
												EndIf
											EndIf
										Next nX
									EndIf

									// Atualizar Beneficios
									If (cAlias)->(BENEFI)
										For nX := 1 To Len(aBenefi)
											If cOldTFF == aBenefi[nX][3]
												lAttBen := .T.
												If oPlaTFF:CellExists(aBenefi[nX,1])
													oPlaTFF:SetCellValue(aBenefi[nX,1], aBenefi[nX,2])
												EndIf
											EndIf
										Next nX
									EndIf

									cXML := oPlaTFF:GetXmlModel(,,,,.F.,.T.,.F.)
									At998ExPla(cXML,oModel,.F.,cCodPla+cCodRev)

									cXML := oPlaTFF:GetXmlModel(,,,,.F.,.T.,.F.)

									oMdlRh:SetValue("TFF_VLFIXO",nVlFixo)

									If lCpoCustom
										ExecBlock('A870CPOU', .F., .F., {oMdlRh,oPlaTFF} )
									EndIf

									If lRet := oModel:VldData()
										oModel:CommitData()
										If aScan(aResult,{|x|x[1]==STR0036+cContrt}) == 0
											aAdd(aResult,{STR0036+cContrt}) //"Gerado Revisão do Contrato: "
										EndIf
									EndIf

									If !lRet
										aErroMVC := oModel:GetErrorMessage()
										DisarmTransacation()
										oModel:deActivate()
										At870FError(cContrt, aResult, aErroMVC)
									EndIf

									oModel:deActivate()
								Else
									aErroMVC := {"TECA870","","","","",STR0038,STR0039,"",""} //"Erro ao realizar a revisão do contrato.""Consulte o log em system\gestaoservicos"
									DisarmTransacation()
									At870FError(cContrt, aResult, aErroMVC)
								EndIf
					
							End Transaction

						EndIf

					EndIf

				EndIf

				(cAlias)->(dBSkip())

			EndDo

			If !Empty(aResult)
				//Atualiza beneficio na Configuração de Cálculo:
				If lAttBen
					atualizaBen()
				EndIf
				//Atualiza beneficio na Configuração de Cálculo:
				If lAttVer
					atualizaVer()
				EndIf

				For nX := 1 To Len(aResult)
					For nZ := 1 To Len(aResult[nX])
						cMsg += If(Empty(aResult[nX][nZ]), aResult[nX][nZ], aResult[nX][nZ] + CRLF )
					Next nZ
					cMsg += CRLF + REPLICATE("-",30) + CRLF
				Next
				AtShowLog(cMsg,STR0035,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) //"Revisão de Contratos"
			EndIf

			TxLogFile(cFileLog,cMsg,,,,cFolder)
			MsgInfo(STR0037+cFileLog) //"Processamento concluido. Log gerado em: "

		EndIf
	Else
		Help(,, "At870FPrcRea",,STR0040,1,0,,,,,,{STR0041})//"Parametro Tipo de Revisão obrigatório.""Selecione um tipo de revisão nos parametros do Pergunte."
	EndIf

	RestArea(aAreaSav)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FVfRev
Retorna a ultima versao da Configuracao da Planilha
@since  22/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870FVfRev(cCodP)

	Local aArea := GetArea()
	Local cRev  := ""

	DbSelectArea("ABW")
	ABW->(DbSetOrder(1)) //ABW_FILIAL+ABW_CODIGO
	If ABW->(DbSeek(xFilial("ABW")+cCodP))
		While !ABW->(EOF()) .AND. xFilial("ABW")+cCodP == ABW->(ABW_FILIAL+ABW_CODIGO)
			cRev := ABW->ABW_REVISA
			ABW->(DbSkip())
		EndDo
	EndIf

	RestArea(aArea)

Return cRev

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FError
Formatar Array com aErroMVC
@since  25/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static function At870FError(cContrt, aReturn, aErroMVC)

	AADD(aReturn, { STR0022 + " [" + cContrt + "]",; //"Contrato:"
					STR0023 + " [" + AllToChar( aErroMVC[1] ) + "]",;	//"Id do formulário de origem:"
					STR0024 + " [" + AllToChar( aErroMVC[2] ) + "]",;	//"Id do campo de origem:"
					STR0025 + " [" + AllToChar( aErroMVC[3] ) + "]",;	//"Id do formulário de erro:"
					STR0026 + " [" + AllToChar( aErroMVC[4] ) + "]",;	//"Id do campo de erro:"
					STR0027 + " [" + AllToChar( aErroMVC[5] ) + "]",;	//"Id do erro:"
					STR0028 + " [" + AllToChar( aErroMVC[6] ) + "]",;	//"Mensagem do erro:"
					STR0029 + " [" + AllToChar( aErroMVC[7] ) + "]",;	//"Mensagem da solução:"
					STR0030 + " [" + AllToChar( aErroMVC[8] ) + "]",;	//"Valor atribuído:"
					STR0031 + " [" + AllToChar( aErroMVC[9] ) + "]"})	//"Valor anterior:"

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870PsqRev
Formatar Verifica se existe revisao do contrato
@since  31/01/2025
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At870PsqRev(cContrt, cRevis)
Local lRet 		:= .F.
Local cQry 		:= ""
Local cAliasTFJ := ""
Local oQry 		:= Nil

cQry := " SELECT 1 FROM ? TFJ "
cQry += " WHERE TFJ.TFJ_FILIAL = ? "
cQry += " AND TFJ.TFJ_CONTRT = ? "
cQry += " AND TFJ.TFJ_CONREV = ? "
cQry += " AND TFJ.TFJ_STATUS = '2' "
cQry += " AND TFJ.D_E_L_E_T_ = ' ' "

oQry := FwPreparedStatement():New(cQry)
oQry:SetNumeric( 1, RetSqlName( "TFJ" ) )
oQry:SetString(  2, FwxFilial( "TFJ" ) )
oQry:SetString(  3, cContrt )
oQry:SetString(  4, cRevis )

cQry := oQry:GetFixQuery()
cAliasTFJ := MPSysOpenQuery(cQry)

If (cAliasTFJ)->(!Eof())
	lRet := .T.
EndIf

(cAliasTFJ)->(DbCloseArea())
oQry:Destroy()
FwFreeObj(oQry)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FArmVld
Formatar Verifica se existe revisao do contrato
@since  05/02/2025
@param cAliasAux (Alias da tabela temporária com os dados do contrato em revisão)
@return logical
/*/
//------------------------------------------------------------------------------
Static Function At870FArmVld(cAliasAux as character) as Logical

	Local lRet      as logical
	Local cQuery    as character
	Local oQuery    as object
	Local cAliasTmp as character
	Local cCodTFF   as character

	lRet    := .F.
	cCodTFF := (cAliasAux)->(TFF_COD)

	cQuery := " SELECT TXQ.TXQ_CODTFF, TXQ.TXQ_CODIGO, TXQ.TXQ_CODPRD, TXQ.TXQ_PRCVEN, SB1.B1_PRV1 "
	cQuery += " FROM ? "
	cQuery += " INNER JOIN ? "
	cQuery += " ON SB1.B1_FILIAL = ? AND SB1.B1_COD = TXQ.TXQ_CODPRD  "
	cQuery += " WHERE TXQ.TXQ_FILIAL = ? AND TXQ.TXQ_CODTFF = ? AND TXQ.D_E_L_E_T_ = ? AND SB1.D_E_L_E_T_ = ?"

	oQuery := FwPreparedStatement():New(cQuery)
	oQuery:SetNumeric( 1, RetSqlTab("TXQ"))
	oQuery:SetNumeric( 2, RetSqlTab("SB1"))
	oQuery:SetString(  3, FWxFilial("SB1"))
	oQuery:SetString(  4, FWxFilial("TXQ"))
	oQuery:SetString(  5, cCodTFF         )
	oQuery:SetString(  6, Space(1)        )
	oQuery:SetString(  7, Space(1)        )

	cQuery    := oQuery:GetFixQuery()
	cAliasTmp := MPSysOpenQuery(cQuery)

	While (cAliasTmp)->(!EoF())
		If (cAliasTmp)->(B1_PRV1) > (cAliasTmp)->(TXQ_PRCVEN)
			aAdd(aARM,{(cAliasTmp)->(TXQ_CODIGO), (cAliasTmp)->(B1_PRV1), (cAliasTmp)->(TXQ_CODTFF)})
			lRet := .T.
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())
	oQuery:Destroy()
	FwFreeObj(oQuery)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FUniVld
Formatar Verifica se existe revisao do contrato
@since  05/02/2025
@param cAliasAux (Alias da tabela temporária com os dados do contrato em revisão)
@return logical
/*/
//------------------------------------------------------------------------------
Static Function At870FUniVld(cAliasAux as character) as Logical

	Local lRet      as logical
	Local cQuery    as character
	Local oQuery    as object
	Local cAliasTmp as character
	Local cCodTFF   as character

	lRet      := .F.
	cAliasTmp := GetNextAlias()
	cCodTFF   := (cAliasAux)->(TFF_COD)

	cQuery := " SELECT TXP.TXP_CODTFF, TXP.TXP_CODIGO, TXP.TXP_CODUNI, TXP.TXP_PRCVEN, SB1.B1_PRV1 "
	cQuery += " FROM ? "
	cQuery += " INNER JOIN ? "
	cQuery += " ON SB1.B1_FILIAL = ? AND SB1.B1_COD = TXP.TXP_CODUNI  "
	cQuery += " WHERE TXP.TXP_FILIAL = ? AND TXP.TXP_CODTFF = ? AND TXP.D_E_L_E_T_ = ? AND SB1.D_E_L_E_T_ = ?"

	oQuery := FwPreparedStatement():New(cQuery)
	oQuery:SetNumeric( 1, RetSqlTab("TXP"))
	oQuery:SetNumeric( 2, RetSqlTab("SB1"))
	oQuery:SetString(  3, FWxFilial("SB1"))
	oQuery:SetString(  4, FWxFilial("TXP"))
	oQuery:SetString(  5, cCodTFF         )
	oQuery:SetString(  6, Space(1)        )
	oQuery:SetString(  7, Space(1)        )

	cQuery    := oQuery:GetFixQuery()
	cAliasTmp := MPSysOpenQuery(cQuery)

	While (cAliasTmp)->(!EoF())
		If (cAliasTmp)->(B1_PRV1) > (cAliasTmp)->(TXP_PRCVEN)
			aAdd(aUNIF,{(cAliasTmp)->(TXP_CODIGO), (cAliasTmp)->(B1_PRV1), (cAliasTmp)->(TXP_CODTFF)})
			lRet := .T.
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())
	oQuery:Destroy()
	FwFreeObj(oQuery)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} atualizaBen
Atualiza Configurações de cálculo de acordo com aumento dos Benefícios de RH
@since  25/02/2025
@author jack.junior
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function atualizaBen()
Local aArea := GetArea()
Local nPos 	:= 0
Local nX 	:= 0
Local nY 	:= 0

//Verifica se existe algum item do array a ser atualizado na Configuração:
nPos := aScan(aBenefi,{|x| x[8] == .T.})

If nPos > 0
	//Posicina TDZ
	dbSelectArea("TDZ")
	TDZ->(dbSetOrder(1)) //TDZ_FILIAL+TDZ_CODIGO+TDZ_REVISA

	For nX := 1 to Len(aBenefi)
		//Caso seja necessário atualizar a Configuração de cálculo:
		If aBenefi[nX][8]
			//Caso o Benefício no RH esteja Maior que na Configuração:
			If aBenefi[nX][2] > aBenefi[nX][6]
				//TDZ_FILIAL+TDZ_CODIGO+TDZ_REVISA
				If TDZ->(dbSeek(xFilial("TDZ")+aBenefi[nX][4]+aBenefi[nX][5]))
					If TDZ->(RecLock("TDZ", .F.))

						//Atualiza Valor dia da CCT na configuração:		
						TDZ->TDZ_VALOR := aBenefi[nX][2]

						//Caso o valor diario diferenciado da configuração for diferente de zero e valor menor que o benefício do RH		
						If aBenefi[nX][7] <> 0 .AND. aBenefi[nX][2] > aBenefi[nX][7]
							TDZ->TDZ_VLRDIF := aBenefi[nX][2]	
						EndIf

						TDZ->( MsUnlock() )	
						
						//Atualiza no array pra não fazer para as mesmas Configurações:	
						For nY := 1 To Len(aBenefi)
							If aBenefi[nY][1] == aBenefi[nX][1] .And. aBenefi[nY][4] == aBenefi[nX][4] .And. aBenefi[nY][5] == aBenefi[nX][5]
								aBenefi[nY][8] := .F.
							EndIf
						Next nY	
					EndIf		
				Endif
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} atualizaVer
Atualiza Configurações de cálculo de acordo com aumento das Verbas de RH
@since  25/02/2025
@author jack.junior
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function atualizaVer()
Local aArea := GetArea()
Local nPos 	:= 0
Local nX 	:= 0
Local nY 	:= 0

//Verifica se existe algum item do array a ser atualizado na Configuração:
nPos := aScan(aVerbas,{|x| x[8] == .T.})

If nPos > 0
	//Posicina TCX
	dbSelectArea("TCX")
	TCX->(dbSetOrder(1)) //TCX_FILIAL+TCX_CODIGO+TCX_REVISA

	For nX := 1 to Len(aVerbas)
		//Caso seja necessário atualizar a Configuração de cálculo:
		If aVerbas[nX][8]
			//Caso o Benefício no RH esteja Maior que na Configuração:
			If aVerbas[nX][2] > aVerbas[nX][6]
				//TCX_FILIAL+TCX_CODIGO+TCX_REVISA
				If TCX->(dbSeek(xFilial("TCX")+aVerbas[nX][4]+aVerbas[nX][5]))
					If TCX->(RecLock("TCX", .F.))

						//Atualiza Valor dia da CCT na configuração:		
						TCX->TCX_PORCEN := aVerbas[nX][2]

						//Caso o valor diario diferenciado da configuração for diferente de zero e valor menor que o benefício do RH		
						If aVerbas[nX][7] <> 0 .AND. aVerbas[nX][2] > aVerbas[nX][7]
							TCX->TCX_PORALT := aVerbas[nX][2]	
						EndIf

						TCX->( MsUnlock() )	
						
						//Atualiza no array pra não fazer para as mesmas Configurações:	
						For nY := 1 To Len(aVerbas)
							If aVerbas[nY][1] == aVerbas[nX][1] .And. aVerbas[nY][4] == aVerbas[nX][4] .And. aVerbas[nY][5] == aVerbas[nX][5]
								aVerbas[nY][8] := .F.
							EndIf
						Next nY	
					EndIf		
				Endif
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aArea)

Return
