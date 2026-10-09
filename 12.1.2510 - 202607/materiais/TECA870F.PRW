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
Reajuste de Planilhas de Contratos
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

	oBrowse:AddLegend("!(SALBAS .OR. VERBAS .OR. BENEFI)","BR_VERDE",   STR0032,"PLANILHA",.T.) //"Config. Planilha atualizada"
	oBrowse:AddLegend(" (SALBAS .OR. VERBAS .OR. BENEFI)","BR_VERMELHO",STR0033,"PLANILHA",.T.) //"Config. Planilha desatualizada"

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
	Local aIdx       := {}
	Local aInsert    := {}
	Local aRetMat    := {}
	Local aRetSal    := {}
	Local aTmpStruct := AT870FaStru()
	Local cAliasAux  := ""
	Local cAliasTmp  := ""
	Local cCodCCT    := ""
	Local cConfCal   := ""
	Local cConfVer   := ""
	Local cDescr     := STR0017 //"Existem valores de salário base, Beneficios ou Verbas reajustados."
	Local cField     := ""
	Local cFuncao    := ""
	Local cPlaVer    := ""
	Local lRetArm    := .F.
	Local lRetBen    := .F.
	Local lRetUni    := .F.
	Local lRetVer    := .F.
	Local nAtual     := 1
	Local nX         := 0
	Local xValue

	If Empty(At870FAlias())
		cAliasTmp := GetNextAlias()
	Else
		cAliasTmp := At870FAlias()
	EndIf

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

		cAliasAux := At870FQryGen(aTmpStruct)

		While (cAliasAux)->(!EOF())
			// Busca dados da planilha e da configuração de cálculo mais recentes
			AT870FVers((cAliasAux)->(TFF_PLACOD), @cPlaVer, @cConfCal, @cConfVer, @cFuncao, @cCodCCT)

			// Existem valores de salário base, Beneficios, Verbas,
			// Materiais de Consumo, Materiais de Implantação ou Armamento reajustados.
			aRetSal := At870FSalVld(cAliasAux, cConfCal, cFuncao, cCodCCT)
			aRetMat := At870FMatVld(cAliasAux)
			lRetVer := At870FVerVld(cAliasAux, cConfCal ,cConfVer)
			lRetBen := At870FBenVld(cAliasAux, cConfCal ,cConfVer)
			lRetArm := At870FArmVld(cAliasAux)
			lRetUni := At870FUniVld(cAliasAux)

			If aRetSal[1] .Or. aRetMat[1] .Or. aRetMat[2] .Or. lRetVer .Or. lRetBen .Or. lRetArm .Or. lRetUni
				aInsert := {}
				For nX := 1 To LEN(aTmpStruct)
					cField := aTmpStruct[nX][1]
					If cField == "OK"
						Aadd(aInsert, {cField, " " })
					ElseIf cField == "RJ_SALARIO"
						Aadd(aInsert, {cField, aRetSal[2] })
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
					ElseIf cField == "REAJUSTE"
						Aadd(aInsert, {cField, aRetSal[4] })
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
	Aadd(aRet, At870FField("REAJUSTE"))
	Aadd(aRet, At870FField("DESCRI"))
	Aadd(aRet, At870FField("REVTCW"))
	Aadd(aRet, At870FField("CCTSUB"))
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
	ElseIf cField == "REAJUSTE"
		aField := {cField, "N", 14, 2}
	ElseIf cField $ "SALBAS|MAT_MI|MAT_MC|VERBAS|BENEFI|REVTCW|ARMAMENTO|UNIFORME"
		aField := {cField, "L", 1, 0}
	ElseIf cField == "CCTSUB"
		aRet := FwTamSx3("TCW_CODCCT")
		aField := {cField, aRet[3], aRet[1], aRet[2]}
	Else
		aRet := FwTamSx3(cField)
		aField := {cField, aRet[3], aRet[1], aRet[2]}
	EndIf

Return aField

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FQryGen
Retorna query uso do browse para retornar Contratos em com Status 1=Ativo ou 2=Em Revisão (se existir).

@param aTmpStruct - Estrutura da tabela temporária para construção da query
@Return cAliasAux - Alias com os dados da query
@since	12/06/2024
@author flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function At870FQryGen(aTmpStruct)

	Local cAliasAux := ""
	Local cQuery    := ""
	Local oQry      := Nil
	Local cMV_PAR02 := "1 = 1"
	Local cMV_PAR03 := "1 = 1"
	Local cMV_PAR04 := "1 = 1"
	Local cMV_PAR05 := "1 = 1"
	Local cMV_PAR06 := "1 = 1"
	Local nOrder	:= 1

	Static lCCTANT := SWY->(ColumnPos("WY_CCTANT") > 0) .And. FindFunction("At996aAtuCCT")

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
	Else
		cMV_PAR04 := "TFJ.TFJ_CONTRT <> ' ' "	
	EndIf

	cQuery := "SELECT TFJ.TFJ_FILIAL, "
	cQuery +=        "TFJ.TFJ_CODIGO, " 
	cQuery +=        "TFJ.TFJ_CONTRT, " 
	cQuery +=        "TFJ.TFJ_CONREV, " 
	cQuery +=        "TFJ.TFJ_STATUS, " 
	cQuery +=        "TFL.TFL_LOCAL, "
	cQuery +=        "LOC.ABS_DESCRI, " 
	cQuery +=        "SA1.A1_COD, "
	cQuery +=        "SA1.A1_LOJA, "
	cQuery +=        "SA1.A1_NOME, "
	cQuery +=        "COALESCE(SRJ.RJ_FUNCAO,' ') RJ_FUNCAO, "
	cQuery +=        "COALESCE(SRJ.RJ_DESC,' ') RJ_DESC, "
	cQuery +=        "COALESCE(SRJ.RJ_SALARIO,0) RJ_SALARIO, " 
	cQuery +=        "TFF.TFF_COD, "
	cQuery +=        "TFF.TFF_PLACOD, " 
	cQuery +=        "TFF.TFF_PLAREV, " 
	cQuery +=        "TFF.TFF_PRCVEN, " 
	cQuery +=        "ABW.ABW_CODTCW, " 
	cQuery +=        "ABW.ABW_RESTCW, " 
	cQuery +=        "ABW.ABW_ULTIMA, " 
	cQuery +=        "TCW.TCW_CODIGO, " 
	cQuery +=        "TCW.TCW_REVISA, " 
	cQuery +=        "TCW.TCW_ULTIMA, " 
	cQuery +=        "TCW.TCW_CODCCT "
	// Verificar se existe CCT Substituta
	If lCCTANT
		cQuery +=    ", COALESCE(SWY.WY_CODIGO, ' ') AS CCTSUB "
	Else
		cQuery +=    ", ' ' CCTSUB "
	EndIf
	cQuery += "FROM   ? TFF "
	cQuery +=        "INNER JOIN ? TFL "
	cQuery +=                "ON ? "
	cQuery +=                   "AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQuery +=                   "AND TFL.D_E_L_E_T_ = ' ' "
	cQuery +=        "INNER JOIN ? TFJ "
	cQuery +=                "ON ? "
	cQuery +=                   "AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQuery +=                   "AND (TFJ.TFJ_STATUS = '1' "
	cQuery +=                         "OR TFJ.TFJ_STATUS = '2') "
	cQuery +=                   "AND ? "	
	cQuery +=                   "AND TFJ.D_E_L_E_T_= ' ' "
	cQuery +=                   "AND NOT EXISTS (SELECT 1 "
	cQuery +=                                   "FROM ? REV "
	cQuery +=                                   "WHERE REV.TFJ_FILIAL = TFJ.TFJ_FILIAL "
	cQuery +=                                         "AND REV.TFJ_CODIGO <> TFJ.TFJ_CODIGO "
	cQuery +=                                         "AND REV.TFJ_CONTRT = TFJ.TFJ_CONTRT "
	cQuery +=                                         "AND ( REV.TFJ_STATUS = '2' "
	cQuery +=                                                "OR REV.TFJ_STATUS = '4' ) "
	cQuery +=                                         "AND REV.D_E_L_E_T_ = ' ' ) "
	cQuery +=        "INNER JOIN ? LOC "
	cQuery +=                "ON LOC.ABS_FILIAL = ? "
	cQuery +=                   "AND LOC.ABS_LOCAL = TFL.TFL_LOCAL "
	cQuery +=                   "AND ? "
	cQuery +=                   "AND LOC.D_E_L_E_T_ = ' ' "
	cQuery +=        "LEFT JOIN ? SRJ "
	cQuery +=               "ON SRJ.RJ_FILIAL = ? "
	cQuery +=                  "AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO "
	cQuery +=                  "AND ? "
	cQuery +=                  "AND SRJ.D_E_L_E_T_ = ' ' "
	cQuery +=        "INNER JOIN ? SA1 "
	cQuery +=                "ON SA1.A1_FILIAL = ? "
	cQuery +=                   "AND SA1.A1_COD = TFJ.TFJ_CODENT "
	cQuery +=                   "AND SA1.A1_LOJA = TFJ.TFJ_LOJA "
	cQuery +=                   "AND ? "
	cQuery +=                   "AND ? "
	cQuery +=                   "AND SA1.D_E_L_E_T_ = ' ' "	
	cQuery +=        "INNER JOIN ? ABW "
	cQuery +=                "ON ABW.ABW_FILIAL = ? "
	cQuery +=                   "AND ABW.ABW_CODIGO = TFF.TFF_PLACOD "
	cQuery +=                   "AND ABW.ABW_REVISA = TFF.TFF_PLAREV "
	cQuery +=                   "AND ABW.D_E_L_E_T_= ' ' "
	cQuery +=        "INNER JOIN ? TCW "
	cQuery +=                "ON TCW.TCW_FILIAL = ? "
	cQuery +=                   "AND TCW.TCW_CODIGO = ABW.ABW_CODTCW "
	cQuery +=                   "AND TCW.TCW_REVISA = ABW.ABW_RESTCW "
	cQuery +=                   "AND TCW.D_E_L_E_T_ = ' ' "
	If lCCTANT
		cQuery +=    "LEFT JOIN ? SWY "
		cQuery +=           "ON SWY.WY_FILIAL = ? "
		cQuery +=              "AND SWY.WY_CODIGO = TCW.TCW_CODCCT "
		cQuery +=              "AND SWY.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "WHERE  TFF.TFF_FILIAL = ? "
	cQuery +=        "AND TFF.TFF_PLACOD <> ' ' "
	cQuery +=        "AND TFF.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	oQry := FwExecStatement():New(cQuery)

	oQry:SetUnsafe( nOrder++, RetSqlName( "TFF" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "TFL" ) )
	oQry:SetUnsafe( nOrder++, FWJoinFilial("TFL", "TFF") )
	oQry:SetUnsafe( nOrder++, RetSqlName( "TFJ" ) )
	oQry:SetUnsafe( nOrder++, FWJoinFilial("TFJ", "TFL") )
	oQry:SetUnsafe( nOrder++, cMV_PAR04 ) //Contrato
	oQry:SetUnsafe( nOrder++, RetSqlName( "TFJ" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "ABS" ) )
	oQry:SetString( nOrder++, FwxFilial( "ABS" ) )
	oQry:SetUnsafe( nOrder++, cMV_PAR05 ) //Local
	oQry:SetUnsafe( nOrder++, RetSqlName( "SRJ" ) )
	oQry:SetString( nOrder++, FwxFilial( "SRJ" ) )
	oQry:SetUnsafe( nOrder++, cMV_PAR06 ) //Função
	oQry:SetUnsafe( nOrder++, RetSqlName( "SA1" ) )
	oQry:SetString( nOrder++, FwxFilial( "SA1" ) )
	oQry:SetUnsafe( nOrder++, cMV_PAR02 ) //Cliente
	oQry:SetUnsafe( nOrder++, cMV_PAR03 ) //Loja
	oQry:SetUnsafe( nOrder++, RetSqlName( "ABW" ) )
	oQry:SetString( nOrder++, FwxFilial( "ABW" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "TCW" ) )
	oQry:SetString( nOrder++, FwxFilial( "TCW" ) )
	If lCCTANT
		oQry:SetUnsafe( nOrder++, RetSqlName( "SWY" ) )
		oQry:SetString( nOrder++, FwxFilial( "SWY" ) )
	EndIf	
	oQry:SetString( nOrder++, FwxFilial( "TFF" ) )

	cAliasAux := oQry:OpenAlias()
	oQry:Destroy()
	FwFreeObj(oQry)

Return cAliasAux

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
	Local cFields  := ""
	Local cField   := ""
	Local cMasc    := ""
	Local cTitle   := ""

	cFields := "OK|TFF_COD|REVTCW|CCTSUB|SALBAS|MAT_MI|MAT_MC|VERBAS|BENEFI|REVTCW|ARMAMENTO|UNIFORME" //Campos que não devem ser exibidos no Browse

	For nY := 1 To Len(aStru)
		cField := aStru[nY][1]
		If !(cField $ cFields)
			cMasc := X3Picture(cField)
			If cField $ "TFJ_CODIGO"
				cTitle := STR0013 //"Orçamento"
			ElseIf cField $ "RJ_SALARIO"
				cTitle := STR0014 //"Sal. Base Função"
			ElseIf cField $ "TFF_PRCVEN"
				cTitle := STR0015 //"Sal. Base Contrato"
			ElseIf cField $ "REAJUSTE"
				cTitle := STR0045 //"% de Reajuste do Salário"
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
Static Function At870FSalVld(cAlias, cConfCal, cFuncao, cCodCCT)
	Local aAreaSav  := GetArea()
	Local aExec     := {}
	Local aRet      := {.F., 0, 0, 0}
	Local nPercReaj := 0
	Local nSalBase  := 0
	Local nSalFunc  := 0

	// Pesquisar Salario Base da Planilha do Posto XML
	nSalBase := At870FPsqTag((cAlias)->(TFF_COD),"VLR_SB")

	If Empty(cFuncao)
		// Usa Funcao do Posto caso nao informado
		cFuncao := (cAlias)->RJ_FUNCAO
	EndIf

	// Prioriza CCT
	If !Empty(cConfCal)
		If !Empty(cCodCCT) .And. !Empty(cFuncao)
			nSalFunc := at998SalCCT(cCodCCT, cFuncao)
		EndIf
	EndIf

	// Fallback SRJ
	If nSalFunc <= 0
		nSalFunc := (cAlias)->RJ_SALARIO
	EndIf

	// Comparar Salario Base da Funcao x Salario Base Planiha do Posto
	If nSalBase > 0 .And. nSalFunc > nSalBase
		aRet[1] := .T.
		aRet[2] := nSalFunc
		aRet[3] := nSalBase
		// % de reajuste do salario
		nPercReaj := ((nSalFunc - nSalBase) / nSalBase) * 100
		aRet[4]   := nPercReaj

	EndIf

	If nSalBase > 0
		// Manipulação de Salario Base no Reajuste de Planilhas
		If ExistBlock("at870FSa")
			aExec := ExecBlock("at870FSa",.F.,.F.,{(cAlias)->(TFF_COD),cFuncao,aRet,nSalBase})
			If Valtype(aExec) == "A"
				aRet := aClone( aExec )
			EndIf
			aExec := {}
		EndIf
	EndIf

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
	Local cAliasTmp := ""
	Local cCodTFF   := (cAlias)->(TFF_COD)
	Local cQry      := ""
	Local oQry

	cQry := " SELECT TFG.TFG_CODPAI, TFG.TFG_COD, TFG.TFG_PRODUT, TFG.TFG_PRCVEN, SB1.B1_PRV1 "
	cQry += " FROM ? TFG "
	cQry += " INNER JOIN ? SB1 "
	cQry += " ON SB1.B1_FILIAL = ? AND SB1.B1_COD = TFG.TFG_PRODUT AND SB1.D_E_L_E_T_=' ' "
	cQry += " WHERE TFG.TFG_FILIAL = ? AND TFG.TFG_CODPAI = ? AND TFG.D_E_L_E_T_=' ' "

	oQry := FwExecStatement():New(cQry)
	oQry:SetUnsafe( 1, RetSqlName( "TFG" ) )
	oQry:SetUnsafe( 2, RetSqlName( "SB1" ) )
	oQry:SetString(  3, FwxFilial( "SB1" ) )
	oQry:SetString(  4, FwxFilial( "TFG" ) )
	oQry:SetString(  5, cCodTFF )
	cAliasTmp := oQry:OpenAlias()

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

	oQry := FwExecStatement():New(cQry)
	oQry:SetUnsafe( 1, RetSqlName( "TFH" ) )
	oQry:SetUnsafe( 2, RetSqlName( "SB1" ) )
	oQry:SetString( 3, FwxFilial( "SB1" ) )
	oQry:SetString( 4, FwxFilial( "TFH" ) )
	oQry:SetString( 5, cCodTFF )
	cAliasTmp := oQry:OpenAlias()

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
Static Function At870FVerVld(cAlias, cCfgCalc ,cCfgRevi)
	Local aAreaSav  := GetArea()
	Local aExec     := {}
	Local cAliasTCX := ""
	Local cCodTFF   := ""
	Local cQry      := ""
	Local lRet      := .F.
	Local nPorAlt   := 0
	Local nVlrBen   := 0
	Local oQry      := Nil

	cCodTFF  := (cAlias)->TFF_COD

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

		cQry := ChangeQuery(cQry)
		oQry := FwExecStatement():New(cQry)

		oQry:SetUnsafe( 1, RetSqlName( "TCX" ) )
		oQry:SetUnsafe( 2, RetSqlName( "SRV" ) )
		oQry:SetString( 3, FwxFilial( "SRV" ) )
		oQry:SetString( 4, FwxFilial( "TCX" ) )
		oQry:SetString( 5, cCfgCalc )
		oQry:SetString( 6, cCfgRevi )

		cAliasTCX := oQry:OpenAlias()
	
		While (cAliasTCX)->(!Eof())
			nVlrBen := (cAliasTCX)->(RV_PERC)
			nPorAlt := At870FPsqTag((cAlias)->(TFF_COD), (cAliasTCX)->(TCX_NICKPO))
			If nPorAlt > 0 .And. nVlrBen > nPorAlt
				If aScan(aVerbas, {|x| x[1]==(cAliasTCX)->(TCX_NICKPO) .AND. x[2]==nVlrBen .AND. x[3]==cCodTFF}) == 0
					aAdd(aVerbas, { (cAliasTCX)->(TCX_NICKPO), ; //Nick do benefício na Configuração de Cálculo
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

		// Manipulação de Verbas no Reajuste de Planilhas
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
Static Function At870FBenVld(cAlias, cCfgCalc ,cCfgRevi)
	Local aAreaSav  := GetArea()
	Local aExec     := {}
	Local cAliasTDZ := ""
	Local cCodTFF   := ""
	Local cQry      := ""
	Local lRet      := .F.
	Local nVlrBen   := 0
	Local nVlrPln   := 0
	Local oQry      := Nil

	cCodTFF  := (cAlias)->TFF_COD

	If !Empty(cCfgCalc)

		cQry := "SELECT TDZ.TDZ_CODSLY, TDZ.TDZ_TIPBEN, TDZ.TDZ_NICKVL, TDZ.TDZ_VALOR, TDZ.TDZ_VLRDIF, TDZ.TDZ_CODIGO "
		cQry += "FROM ? TDZ "
		cQry += "INNER JOIN ? TCW ON TCW.TCW_FILIAL = ? AND TCW.TCW_CODIGO = TDZ.TDZ_CODTCW AND TCW.TCW_REVISA = TDZ.TDZ_REVISA AND TCW.D_E_L_E_T_=' ' "
		cQry += "WHERE TDZ.TDZ_FILIAL= ? AND TDZ.TDZ_CODTCW = ? AND TDZ.TDZ_REVISA =  ? AND TDZ.TDZ_NICK <> ' ' AND TDZ.D_E_L_E_T_= ' ' AND TDZ.TDZ_ITEM <> '001' "

		cQry := ChangeQuery(cQry)
		oQry := FwExecStatement():New(cQry)

		oQry:SetUnsafe( 1, RetSqlName( "TDZ" ) )
		oQry:SetUnsafe( 2, RetSqlName( "TCW" ) )
		oQry:SetString( 3, FwxFilial( "TCW" ) )
		oQry:SetString( 4, FwxFilial( "TDZ" ) )
		oQry:SetString( 5, cCfgCalc )
		oQry:SetString( 6, cCfgRevi )

		cAliasTDZ := oQry:OpenAlias()

		While (cAliasTDZ)->(!Eof())
			nVlrBen := At870FVlrB((cAliasTDZ)->(TDZ_CODSLY), (cAliasTDZ)->(TDZ_TIPBEN))
			nVlrPln := At870FPsqTag((cAlias)->(TFF_COD), (cAliasTDZ)->(TDZ_NICKVL))
			If nVlrPln > 0 .And. nVlrBen > nVlrPln
				If aScan(aBenefi, {|x| x[1]==(cAliasTDZ)->(TDZ_NICKVL) .AND. x[2]==nVlrBen .AND. x[3]==cCodTFF}) == 0
					aAdd(aBenefi, { (cAliasTDZ)->(TDZ_NICKVL), ; //Nick do benefício na Configuração de Cálculo
									nVlrBen, ; //Valor do benefício no RH
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

		// Manipulação de Benefícios no Reajuste de Planilhas
		If ExistBlock("at870FBe") // atualmente estamos usando a última revisão da planilha de preço invés da TFF_PLAREV
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

	Local aAreaSav 	:= GetArea()
	Local nRet     	:= 0

	Default cChave   := ""
	Default cTipoBen := ""

	cChave   := Alltrim(cChave)
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
			nRet := 0
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
	Local xValue   := 0

	cNick := AllTrim(cNick)

	DbSelectArea("TFF")
	TFF->(DbSetOrder(1)) //TFF_FILIAL+TFF_COD
	If TFF->(DbSeek(xFilial("TFF")+cCodPosto)) .And. !Empty(cNick)

		oPlaTFF := GsPlan():New()
		oPlaTFF:LoadXmlModel(TFF->TFF_CALCMD)

		// Pesquisar cNick da Planilha do Posto XML
		If oPlaTFF:CellExists(cNick)
			xValue := oPlaTFF:GetCellValue(cNick)
			nRet := xValue
		EndIf
	EndIf

Return xValue

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
	Local aAreaSav   := GetArea()
	Local aErroMVC   := {}
	Local aContrt    := {}
	Local aResult    := {}
	Local cAlias     := At870FAlias()
	Local cCodCCT    := ""
	Local cCodPla    := ""
	Local cCodRev    := ""
	Local cCodSub    := ""
	Local cCodSubArm := ""
	Local cCodSubMC  := ""
	Local cCodSubMI  := ""
	Local cCodSubUni := ""
	Local cCodTFF    := ""
	Local cCodTFJ    := ""
	Local cConfCal   := ""
	Local cConfVer   := ""
	Local cContrt    := ""
	Local cFileLog   := ""
	Local cFIlTFJ    := ""
	Local cFolder    := ""
	Local cFuncao    := ""
	Local cMsg       := ""
	Local cMsgCCT    := ""
	Local cOldTFF    := ""
	Local cRevis     := ""
	Local cXML       := ""
	Local lAttBen    := .F.
	Local lAttVer    := .F.
	Local lCpoCustom := ExistBlock( 'A870CPOU' )
	Local lRet       := .T.
	Local lTemRevis  := .F.
	Local nIni       := 0
	Local nRegs      := 0
	Local nSalario   := 0
	Local nTotReg    := 0
	Local nVlFixo    := 0
	Local nSalBase   := 0
	Local nPercReaj  := 0
	Local nX         := 0
	Local nZ         := 0
	Local oMdlRh     := Nil
	Local oMdlTFG    := Nil
	Local oMdlTFH    := Nil
	Local oMdlTXP    := Nil
	Local oMdlTXQ    := Nil
	Local oModel     := Nil
	Local oPlaTFF    := Nil

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
							If Empty(TFF->TFF_VLFIXO)
								nVlFixo := TFF->TFF_VLRCOB
							Else
								nVlFixo := TFF->TFF_VLFIXO
							EndIf

							Begin Transaction

								lRet := .T.

								//Verifica se já tem Revisão Aberta:
								lTemRevis := At870PsqRev(cContrt, cRevis)

								If !lTemRevis
									//Abre uma Revisão de Contrato:
									lRet := At870PRev(cCodTFJ,cContrt,cRevis,.T.,MV_PAR01,.F.,0,0)
								EndIf

								If lRet
									// Geração de Cgf. Planilha se existe campo de CCT Substituta
									cMsgCCT := ""
									If !Empty((cAlias)->(CCTSUB))
										cCodAtu := At870FGetCCT((cAlias)->(CCTSUB)) //Recursivo: Pesquisa CCT Substituta
										// Pesquisa Cgf. Planilha
										DbSelectArea("ABW")
										ABW->(DbSetOrder(1)) //ABW_FILIAL+ABW_CODIGO
										If ABW->(DbSeek(xFilial("ABW")+cCodPla+cCodRev))
											DbSelectArea("TCW")
											TCW->(DbSetOrder(1)) //TCW_FILIAL+TCW_CODIGO+TCW_REVISA
											If TCW->(DbSeek(xFilial("TCW")+ABW->(ABW_CODTCW+ABW_RESTCW)))
												If AT870FCCTVld(TCW->TCW_CODIGO, TCW->TCW_REVISA, TCW->TCW_CODCCT, cCodAtu)
													cMsgCCT := STR0044 + TCW->TCW_REVISA //"Gerado Revisão da Config. Planilha com CCT atualizado."
												EndIf
											EndIf
										EndIf
									EndIf

									// Considerada a última versão de Planilha e Configuração de cáclulo para reajustes
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
														// Busca dados da planilha e da configuração de cálculo mais recentes
														cCodTFF := TFF->TFF_COD
														cXML    := TFF->TFF_CALCMD
														cCodPla := TFF->TFF_PLACOD
														AT870FVers(TFF->(TFF_PLACOD), @cCodRev, @cConfCal, @cConfVer, @cFuncao, @cCodCCT)
														If TFF->(RecLock("TFF", .F.))
															TFF->TFF_PLAREV := cCodRev
															TFF->(MsUnlock("TFF"))
														EndIf
													EndIf
												EndIf
												Exit
											EndIf
											TFJ->(dbSkip())
										EndDo
									EndIf
								EndIf

								If lRet
									TFF->(DBSeek(xFilial("TFF") + cCodTFF))
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

									// ORÇAMENTO: Atualizar MI:
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

									// ORÇAMENTO: Atualizar MC:
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

									// ORÇAMENTO: Atualizar Armamento:
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

									// ORÇAMENTO: Atualizar Uniforme:
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

									If (cAlias)->(MAT_MI) .Or. (cAlias)->(MAT_MC) .Or. (cAlias)->(ARMAMENTO) .Or. (cAlias)->(UNIFORME)
										//Roda a planilha para aplicar as alterações de Materiais:
										At998ExPla(cXML,@oModel,.F.,cCodPla+cCodRev,.F.)
										cXML := oMdlRh:GetValue("TFF_CALCMD")
									EndIf

									If (cAlias)->(SALBAS) .Or. (cAlias)->(VERBAS) .Or. (cAlias)->(BENEFI)
										//instancia a planilha sem exibição para atualização de verbas:
										oPlaTFF := GsPlan():New()
										
										oPlaTFF:LoadXmlModel(cXML)

										// PLANILHA: Atualizar Salario Base
										If (cAlias)->(SALBAS)
											If oPlaTFF:CellExists(AllTrim("VLR_SB"))
												// Prioriza salario da CCT (RI4_SALARI), senao usa SRJ (RJ_SALARIO)
												nSalBase := oPlaTFF:GetCellValue("VLR_SB")
												nSalario := 0
												DbSelectArea("ABW")
												ABW->(DbSetOrder(1)) //ABW_FILIAL+ABW_CODIGO
												If ABW->(DbSeek(xFilial("ABW")+cCodPla+cCodRev))
													DbSelectArea("TCW")
													TCW->(DbSetOrder(1)) //TCW_FILIAL+TCW_CODIGO+TCW_REVISA
													If TCW->(DbSeek(xFilial("TCW")+ABW->(ABW_CODTCW+ABW_RESTCW)))
														If !Empty(TCW->TCW_CODIGO) .And. !Empty((cAlias)->(RJ_FUNCAO))
															nSalario := at998SalCCT(TCW->TCW_CODIGO, (cAlias)->(RJ_FUNCAO))
														EndIf
													EndIf
												EndIf
												
												If nSalario <= 0
													nSalario := (cAlias)->(RJ_SALARIO)
												EndIf
												oPlaTFF:SetCellValue("VLR_SB", cvaltochar(nSalario))
												nPercReaj := ((nSalario - nSalBase) / nSalBase) * 100
												If oPlaTFF:CellExists("INDIC_REAJ")
													oPlaTFF:SetCellValue("INDIC_REAJ", nPercReaj)
												EndIf
											EndIf
										EndIf

										// PLANILHA:  Atualizar Verbas
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

										// PLANILHA: Atualizar Beneficios
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

										// PLANILHA: Atualiza Formula do Total Bruto
										If !Empty(TCW->TCW_FORBRT)
											If oPlaTFF:CellExists("TOTAL_BRUTO")
												oPlaTFF:SetCellForm("TOTAL_BRUTO", TCW->TCW_FORBRT)
											EndIf
										EndIf

										cXML := oPlaTFF:GetXmlModel()
										
										If lCpoCustom
											ExecBlock('A870CPOU', .F., .F., {oMdlRh,oPlaTFF} )
										EndIf
									EndIf

									// Atualiza campos do modelo:
									oMdlRh:SetValue("TFF_CALCMD",cXML)
									oMdlRh:SetValue("TFF_VLFIXO",nVlFixo)

									If lRet := oModel:VldData()
										oModel:CommitData()
										If aScan(aContrt,{|x|x==cContrt}) == 0
											aAdd(aContrt,cContrt)
											aAdd(aResult,{STR0036+cContrt+CRLF+cMsgCCT}) //"Gerado Revisão do Contrato: "
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

				// Ponto de Entrada at870Fim - Final da gravacao da revisao do contrato
				If ExistBlock("at870Fim")
					ExecBlock("at870Fim",.F.,.F.,{aContrt})
				EndIf
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

	oQry := FwExecStatement():New(cQry)
	oQry:SetUnsafe( 1, RetSqlName( "TFJ" ) )
	oQry:SetString(  2, FwxFilial( "TFJ" ) )
	oQry:SetString(  3, cContrt )
	oQry:SetString(  4, cRevis )
	cAliasTFJ := oQry:OpenAlias()

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
Static Function At870FArmVld(cAliasAux)
	Local cAliasTmp := ""
	Local cCodTFF   := ""
	Local cQuery    := ""
	Local lRet      := .F.
	Local oQuery    := Nil

	cCodTFF := (cAliasAux)->(TFF_COD)

	cQuery := " SELECT TXQ.TXQ_CODTFF, TXQ.TXQ_CODIGO, TXQ.TXQ_CODPRD, TXQ.TXQ_PRCVEN, SB1.B1_PRV1 "
	cQuery += " FROM ? TXQ "
	cQuery +=     " INNER JOIN ? SB1 "
	cQuery +=         " ON SB1.B1_FILIAL = ? "
	cQuery +=         " AND SB1.B1_COD = TXQ.TXQ_CODPRD  "
	cQuery += " WHERE TXQ.TXQ_FILIAL = ? "
	cQuery +=     " AND TXQ.TXQ_CODTFF = ? "
	cQuery +=     " AND TXQ.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	oQuery := FwExecStatement():New(cQuery)
	oQuery:SetUnsafe( 1, RetSqlName("TXQ"))
	oQuery:SetUnsafe( 2, RetSqlName("SB1"))
	oQuery:SetString( 3, FWxFilial("SB1"))
	oQuery:SetString( 4, FWxFilial("TXQ"))
	oQuery:SetString( 5, cCodTFF )
	cAliasTmp := oQuery:OpenAlias()

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
Static Function At870FUniVld(cAliasAux)
	Local cAliasTmp := ""
	Local cCodTFF   := ""
	Local cQuery    := ""
	Local lRet      := .F.
	Local oQuery    := Nil
	
	cCodTFF   := (cAliasAux)->(TFF_COD)

	cQuery := " SELECT TXP.TXP_CODTFF, TXP.TXP_CODIGO, TXP.TXP_CODUNI, TXP.TXP_PRCVEN, SB1.B1_PRV1 "
	cQuery += " FROM ? TXP "
	cQuery +=     " INNER JOIN ? SB1 "
	cQuery +=         " ON SB1.B1_FILIAL = ? "
	cQuery +=         " AND SB1.B1_COD = TXP.TXP_CODUNI "
	cQuery += " WHERE TXP.TXP_FILIAL = ? "
	cQuery +=     " AND TXP.TXP_CODTFF = ? "
	cQuery +=     " AND TXP.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	oQuery := FwExecStatement():New(cQuery)
	oQuery:SetUnsafe( 1, RetSqlName("TXP"))
	oQuery:SetUnsafe( 2, RetSqlName("SB1"))
	oQuery:SetString( 3, FWxFilial("SB1"))
	oQuery:SetString( 4, FWxFilial("TXP"))
	oQuery:SetString( 5, cCodTFF )
	cAliasTmp := oQuery:OpenAlias()

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

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FCCTVld
Gerar uma nova revisão da Cfg. Planilha com a CCT Substituta
@param cAliasAux, Character, Alias da tabela temporária com os dados do contrato em revisão
@return Logical
@since	20/11/2025
@author flavio.vicco
/*/
//------------------------------------------------------------------------------
Static Function AT870FCCTVld(cCfgCalc, cCfgRevi, cCodCCT, cCCTSub)
	Local aArea    := GetArea()
	Local lGerar   := .F.
	Local lRet     := .F.

	Default cCfgCalc := ""
	Default cCfgRevi := ""
	Default cCodCCT  := ""
	Default cCCTSub  := ""

	// Verifcar se existe CCT Substituta para a CCT da Cfg. Planilha
	If !Empty(cCCTSub) .And. cCodCCT <> cCCTSub
		// Verifcar se existe Cfg. Planilha com a CCT Substituta
		DbSelectArea("TCW")
		TCW->(DbSetOrder(1)) //TCW_FILIAL+TCW_CODIGO+TCW_REVISA
		If TCW->(DbSeek(xFilial("TCW")+cCfgCalc+cCfgRevi))
			While !TCW->(EOF()) .AND. xFilial("TCW")+cCfgCalc == TCW->(TCW_FILIAL+TCW_CODIGO)
				If TCW->TCW_ULTIMA == "1" .And. TCW->TCW_CODCCT <> cCCTSub
					lGerar := .T. // Encontrou ultima revisão com CCT diferente do CCT Substituta
					Exit
				EndIf
				TCW->(DbSkip())
			EndDo
		EndIf
		If lGerar
			// Gerar uma nova revisão da Cfg. Planilha com a CCT Substituta
			lRet := At996aAtuCCT(cCCTSub)
		EndIf
	EndIf
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FVers
Busca a planilha de preço mais atualizada na ABW independente da informada na TFF
ou seja com a maior versão
@param cTFFPla, Planilha de preço na TFF
@since	13/02/2026
@author felipe.mcamargo
/*/
//------------------------------------------------------------------------------
Function AT870FVers(cTFFPla, cABWVer, cTCWCod, cTCWVer, cFuncao, cCodCCT)
	Local cAlias := ""
	Local cQuery := ""
	Local oExec  := Nil

	cQuery := " SELECT ABW.ABW_CODIGO, ABW.ABW_REVISA, TCW.TCW_CODIGO, TCW.TCW_REVISA, ABW.ABW_FUNCAO, TCW.TCW_CODCCT "
	cQuery += " FROM ? ABW "
	cQuery +=     " JOIN ? TCW ON ? "
	cQuery +=         " AND TCW.TCW_CODIGO = ABW.ABW_CODTCW "
	cQuery +=         " AND TCW.TCW_ULTIMA = '1' "// última revisão
	cQuery +=         " AND TCW.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE ABW.ABW_FILIAL = ? "
	cQuery +=     " AND ABW.ABW_CODIGO = ? "
	cQuery +=     " AND ABW.ABW_ULTIMA = '1' " // última revisão
	cQuery +=     " AND ABW.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	oExec := FwExecStatement():New(cQuery)
	oExec:SetUnsafe( 1, RetSqlName("ABW"))
	oExec:SetUnsafe( 2, RetSqlName("TCW"))
	oExec:SetUnsafe( 3, FWJoinFilial("ABW", "TCW") )
	oExec:SetString( 4, FwxFilial("ABW"))
	oExec:SetString( 5, cTFFPla)
	
	cAlias := oExec:OpenAlias()
	oExec:Destroy()
	FwFreeObj(oExec)

	If (cAlias)->(!Eof())
		cABWVer := (cAlias)->(ABW_REVISA)
		cTCWCod := (cAlias)->(TCW_CODIGO)
		cTCWVer := (cAlias)->(TCW_REVISA)
		cFuncao := (cAlias)->(ABW_FUNCAO)
		cCodCCT := (cAlias)->(TCW_CODCCT)
	EndIf

	(cAlias)->(DbCloseArea())

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FGetCCT
Recursivo: Retorna o código CCT substituta
@param cCodCCT, código CCT substituida
@since	24/04/2026
@author flavio.vicco
/*/
//------------------------------------------------------------------------------
Function At870FGetCCT(cCodCCT)
    Local cCodRet := cCodCCT
	Local cAlias  := ""
	Local cQuery  := ""
	Local oExec   := Nil

	cQuery += "SELECT SWY.WY_CODIGO FROM ? SWY WHERE SWY.WY_FILIAL = ? AND SWY.WY_CCTANT = ? AND SWY.D_E_L_E_T_=' '"
	cQuery := ChangeQuery(cQuery)

	oExec := FwExecStatement():New(cQuery)
	oExec:SetUnsafe( 1, RetSqlName( "SWY" ) )
	oExec:SetString( 2, FwxFilial( "SWY" ) )
	oExec:SetString( 3, cCodCCT)

	cAlias := oExec:OpenAlias()
	oExec:Destroy()
	FwFreeObj(oExec)

	If (cAlias)->(!Eof())
		// Recursivo: Se existe codigo CCT substituta -> Pesquisa se foi substituida
		cCodRet := At870FGetCCT((cAlias)->WY_CODIGO)
	EndIf

	(cAlias)->(DbCloseArea())

Return cCodRet
