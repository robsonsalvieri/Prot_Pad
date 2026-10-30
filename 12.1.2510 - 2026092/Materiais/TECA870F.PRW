#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA870F.CH"

Static _lPercDesc := .F.
Static aARM       := {}
Static aBenefi    := {}
Static aMAT_MC    := {}
Static aMAT_MI    := {}
Static aUNIF      := {}
Static aVerbAdc   := {}
Static aVerbas    := {}
Static cTmpAlias  := ""
Static oGSTmpTb   := Nil

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

	_lPercDesc := TDZ->(ColumnPos("TDZ_PERC") > 0) .AND. TDZ->(ColumnPos("TDZ_NICKPE") > 0)

	If TecHasPerg("MV_PAR01", "TECA870F")
		If Pergunte(cPerg,.T.)
			MakeSQLEXPR(cPerg)
			lRet := AT870FBrow(cPerg)
		EndIf
	Else
		Help(" ", 1, "TECA870F", Nil, STR0012, 1) //"Para utilizar a rotina é necessário criar o pergunte TECA870F, indicado no TDN."
	EndIf

    RestArea(aArea)

Return lRet

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
	Local lRet	   := .F.

	oBrowse:= FWMarkBrowse():New()
	oBrowse:SetDataQuery(.F.)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetFieldMark("OK")
	oBrowse:SetAllMark({||oBrowse:AllMark()}) 

	FwMsgRun(Nil,{|oSay|lRet := At870FCria(@oBrowse,oSay)}, STR0002, STR0003) //"Aguarde..."###"Processando a requisição solicitada..."

	If lRet
		oBrowse:SetMenuDef("")
		oBrowse:SetParam({||lRet := AT870FAtBrw(@oBrowse,cPerg)})

		If lRet
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
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT870FAtBrw
Criacao do Objeto Browse
@since	12/06/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT870FAtBrw(oBrowse,cPerg,lShow)
	Local lRet := .F.

	Default lShow := .T.

	If Pergunte(cPerg,lShow)
		MakeSQLEXPR(cPerg)
		(At870FAlias())->(DbCloseArea())
		FwMsgRun(Nil,{|oSay| lRet := At870FCria(@oBrowse,oSay)}, STR0002, STR0003) //"Aguarde..."###"Processando a requisição solicitada..."
		oBrowse:Refresh(.T.)
	EndIf

Return lRet

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
	Local lRet       := .T.
	Local lRetArm    := .F.
	Local lRetBen    := .F.
	Local lRetUni    := .F.
	Local lRetVer    := .F.
	Local lRetVerAdc := .F.
	Local nAtual     := 1
	Local nX         := 0
	Local oPlanTFF   := Nil
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
	aVerbAdc:= {}
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
			aRetMat    := {.F., .F.}
			aRetSal    := {.F., 0  , 0}
			lRetArm    := .F.
			lRetBen    := .F.
			lRetUni    := .F.
			lRetVer    := .F.
			lRetVerAdc := .F.

			DbSelectArea("TFF")
			TFF->(DbSetOrder(1)) //TFF_FILIAL+TFF_COD
			If TFF->(DbSeek(xFilial("TFF")+(cAliasAux)->TFF_COD))

				// Busca dados da planilha e da configuração de cálculo mais recentes
				AT870FVers((cAliasAux)->(TFF_PLACOD), @cPlaVer, @cConfCal, @cConfVer, @cFuncao, @cCodCCT)

				// Instancia a Planilha que será usada nas verificações:
				oPlanTFF := GsPlan():New()
				oPlanTFF:LoadXmlModel(TFF->TFF_CALCMD)
			
				// Salário Base:
				aRetSal := At870FSalVld(cAliasAux, cConfCal, cFuncao, cCodCCT, oPlanTFF)
				// Verbas TCX:
				lRetVer := At870FVerVld(cAliasAux, cConfCal, cConfVer, oPlanTFF)
				// Benefícios TDZ:
				lRetBen := At870FBenVld(cAliasAux, cConfCal, cConfVer, oPlanTFF)
				// Verbas adicionais:
				lRetVerAdc := At870FVAdVld(cAliasAux, cConfCal, cConfVer, oPlanTFF)
				// Materiais MI e MC:
				aRetMat := At870FMatVld(cAliasAux)
				// Armamento:
				lRetArm := At870FArmVld(cAliasAux)
				// Uniformes:
				lRetUni := At870FUniVld(cAliasAux)
			EndIf

			If aRetSal[1] .Or. aRetMat[1] .Or. aRetMat[2] .Or. lRetVer .Or. lRetBen .Or. lRetArm .Or. lRetUni .Or. lRetVerAdc
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
					ElseIf cField == "VERBAS_ADC"
						Aadd(aInsert, {cField, lRetVerAdc })
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
						If lRetVerAdc
							If !Empty(cDescr)
								cDescr += " / "
							EndIf
							cDescr += "Alteração Verbas Adicionais" //"Alteração Verbas Adicionais"
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

			oPlanTFF := Nil	
		EndDo
		At870FAlias(oGSTmpTb:cAliasTmp)
		(At870FAlias())->(DbGoTop())
		oBrw:SetAlias((At870FAlias()))

		(cAliasAux)->(dbCloseArea())
	Else
		oGSTmpTb:ShowErro()
		If VALTYPE(oGSTmpTb) == "O"
			oGSTmpTb:Close()
			TecDestroy(oGSTmpTb)
		EndIf
		lRet := .F.
	EndIf

Return lRet

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
	Aadd(aRet, At870FField("VERBAS_ADC"))
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
	ElseIf cField $ "SALBAS|MAT_MI|MAT_MC|VERBAS|BENEFI|VERBAS_ADC|REVTCW|ARMAMENTO|UNIFORME"
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
	cQuery +=        "TFF.TFF_CALCMD, " 
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

	cFields := "OK|TFF_COD|REVTCW|CCTSUB|SALBAS|MAT_MI|MAT_MC|VERBAS|BENEFI|VERBAS_ADC|REVTCW|ARMAMENTO|UNIFORME" //Campos que não devem ser exibidos no Browse

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
Static Function At870FSalVld(cAlias, cConfCal, cFuncao, cCodCCT, oPlanTFF)
	Local aAreaSav  := GetArea()
	Local aExec     := {}
	Local aRet      := {.F., 0, 0, 0}
	Local nPercReaj := 0
	Local nSalBase  := 0
	Local nSalFunc  := 0

	// Pesquisar Salario Base da Planilha do Posto XML
	nSalBase := oPlanTFF:GetCellValue("VLR_SB")

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
	oQry:SetString( 3, FwxFilial( "SB1" ) )
	oQry:SetString( 4, FwxFilial( "TFG" ) )
	oQry:SetString( 5, cCodTFF )
	cAliasTmp := oQry:OpenAlias()

	While (cAliasTmp)->(!Eof())
		If ((cAliasTmp)->(B1_PRV1) <> (cAliasTmp)->(TFG_PRCVEN)) .And. (cAliasTmp)->(B1_PRV1) > 0
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
		If ((cAliasTmp)->(B1_PRV1) <> (cAliasTmp)->(TFH_PRCVEN)) .And. (cAliasTmp)->(B1_PRV1) > 0
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
Static Function At870FVerVld(cAlias, cCfgCalc, cCfgRevi, oPlanTFF)
	Local aAreaSav   := GetArea()
	Local aExec      := {}
	Local cAliasTCX  := ""
	Local cCodTFF    := ""
	Local cNickName  := ""
	Local cQry       := ""
	Local lAttConf   := .F. // Se atualiza a Configuração de Cálculo
	Local lInsere    := .F. // Se insere no array para atualizar a Planilha
	Local lRet       := .F. // Se o Posto precisa atualizar a planilha
	Local nMaior     := 0
	Local nValorRH   := 0
	Local nValorTFF  := 0
	Local nValPORALT := 0
	Local nValPORCEN := 0
	Local oQry       := Nil

	// Pesquisar Config x Verbas
	If !Empty(cCfgCalc)

		cCodTFF  := (cAlias)->TFF_COD

		cQry := " SELECT TCX.TCX_NICK, TCX.TCX_NICKPO, TCX.TCX_FORMUL, TCX.TCX_CODIGO, TCX.TCX_PORCEN, TCX.TCX_PORALT, TCX.TCX_DESCRI, TCX.TCX_OBRGT, COALESCE( SRV.RV_PERC, 0 ) RV_PERC "
		cQry += " FROM ? TCX "
		cQry += " LEFT JOIN ? SRV ON "
		cQry += " SRV.RV_FILIAL = ? AND SRV.RV_COD = TCX.TCX_CODTBL AND SRV.D_E_L_E_T_=' ' "
		cQry += " WHERE TCX.TCX_FILIAL = ? "
		cQry += " AND TCX.TCX_CODTCW = ? "
		cQry += " AND TCX.TCX_REVISA = ? "
		cQry += " AND TCX.TCX_TIPOPE = '1' "
		cQry += " AND TCX.TCX_NICKPO <> ' ' "
		cQry += " AND TCX.D_E_L_E_T_=' ' "

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
			lAttConf  := .F. // Se atualiza a Configuração de Cálculo
			lInsere   := .F. // Se insere no array para atualizar a Planilha

			// Nickname da Verba:
			cNickName := AllTrim((cAliasTCX)->(TCX_NICKPO))
			// Valor "alterável" da verba na configuração:
			nValPORALT := (cAliasTCX)->(TCX_PORALT)
			// Valor na configuração que veio do RH quando criada:
			nValPORCEN := (cAliasTCX)->(TCX_PORCEN)
			// Valor que está no RH HOJE:
			nValorRH := (cAliasTCX)->(RV_PERC)
			// Valor que está na planilha HOJE:
			nValorTFF := oPlanTFF:GetCellValue(cNickName)

			// O maior Valor é sempre o que vai para a planilha:
			nMaior := nValorRH
			If nValPORALT > nMaior
				nMaior := nValPORALT
			EndIf
			If nValorTFF > nMaior
				nMaior := nValorTFF
			EndIf

			// Verbas que existem na planilha do Posto:
			If oPlanTFF:CellExists(cNickName)
				// Verba no RH acima da planilha / Valor configuração acima da planilha:
				If nValorRH > nValorTFF .Or. nValPORCEN > nValorTFF .Or. nValPORALT > nValorTFF
					lInsere := .T.
					lRet    := .T.
				EndIf				

				// Verba na planilha não obrigatória (precisa manter):
				If (cAliasTCX)->(TCX_OBRGT) <> "1"
					lInsere := .T.
				EndIf

				// Verba maior na planilha - manter valor:
				If nValorTFF > nValPORALT .And. nValorTFF > nValPORCEN
					lInsere := .T.
				EndIf

			Else
				// Obrigatória mas não está na planilha antiga:
				If (cAliasTCX)->(TCX_OBRGT) == "1"
					lInsere := .T.
					lRet    := .T.
				EndIf
			EndIf

			// Valor no RH maior que na configuração:
			If nValorRH > nValPORCEN .Or. (nValorRH > nValPORALT .And. nValPORALT <> 0)
				lInsere  := .T.
				lRet     := .T.
				lAttConf := .T. // Atualiza a Configuração de Cálculo caso o Valor no RH seja maior que o da configuração ou caso o alterável seja diferente de zero e menor que no RH:
			EndIf

			If lInsere
				If aScan(aVerbas, {|x| x[1]==cNickName .AND. x[3]==cCodTFF}) == 0
					aAdd(aVerbas, { cNickName, ; //........................ [1] Nick do benefício na Configuração de Cálculo
									nMaior, ; //........................... [2] Valor do benefício a ser atualizado
									cCodTFF, ; //.......................... [3] Código do Posto
									(cAliasTCX)->(TCX_CODIGO), ;//......... [4] Código da TCX dentro da Configuração de Cálculo
									cCfgRevi, ; //......................... [5] Revisão da Configuração de Cálculo
									nValPORCEN, ; //....................... [6] Valor diario CCT na Configuração de Cálculo
									nValPORALT, ; //....................... [7] Valor diario diferenciado na Configuração de Cálculo
									lAttConf,; //.......................... [8] Se é necessário atualizar a configuração de cálculo
									AllTrim((cAliasTCX)->(TCX_DESCRI)),; // [9] Descrição na configuração de cálculo
									AllTrim((cAliasTCX)->(TCX_NICK)),;	//. [10] Nick da célula
									(cAliasTCX)->(TCX_FORMUL),;	//......... [11] Formula da célula
									nValorRH}) //.......................... [12] Valor no RH
				EndIf
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
Static Function At870FBenVld(cAlias, cCfgCalc ,cCfgRevi, oPlanTFF)
	Local aAreaSav   := GetArea()
	Local aExec      := {}
	Local cAliasTDZ  := ""
	Local cCodTFF    := ""
	Local cNickDesc  := ""
	Local cQry       := ""
	Local lAttConf   := .F. // Se atualiza a Configuração de Cálculo
	Local lInsere    := .F. // Se insere no array para atualizar a Planilha
	Local lRet       := .F. // Se o Posto precisa atualizar a planilha
	Local nMaior     := 0
	Local nValDesc   := 0
	Local nValorRH   := 0
	Local nValorTFF  := 0
	Local nValPORALT := 0
	Local nValPORCEN := 0
	Local oQry       := Nil

	cCodTFF  := (cAlias)->TFF_COD

	If !Empty(cCfgCalc)

		cQry := "SELECT TDZ.TDZ_CODSLY, TDZ.TDZ_TIPBEN, TDZ.TDZ_NICKVL, TDZ.TDZ_VALOR, TDZ.TDZ_VLRDIF, TDZ.TDZ_CODIGO, TDZ.TDZ_NICK, TDZ.TDZ_FORMUL, TDZ.TDZ_OBRGT "
		If _lPercDesc
			cQry += ", TDZ.TDZ_PERC, TDZ.TDZ_NICKPE " 
		EndIf
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
			lAttConf  := .F. // Se atualiza a Configuração de Cálculo
			lInsere   := .F. // Se insere no array para atualizar a Planilha

			// Nickname da Verba:
			cNickName := AllTrim((cAliasTDZ)->(TDZ_NICKVL))
			// Valor "alterável" da verba na configuração:
			nValPORALT := (cAliasTDZ)->(TDZ_VLRDIF)
			// Valor na configuração que veio do RH quando criada:
			nValPORCEN := (cAliasTDZ)->(TDZ_VALOR)
			// Valor que está no RH HOJE:
			nValorRH := At996aVlrB((cAliasTDZ)->TDZ_CODSLY,(cAliasTDZ)->TDZ_TIPBEN,.T.,"VALOR")
			// Valor que está na planilha HOJE:
			nValorTFF := oPlanTFF:GetCellValue(cNickName)

			// O maior Valor é sempre o que vai para a planilha:
			nMaior := nValorRH
			If nValPORALT > nMaior
				nMaior := nValPORALT
			EndIf
			If nValorTFF > nMaior
				nMaior := nValorTFF
			EndIf

			// Valores do Desconto da verba:
			If _lPercDesc
				cNickDesc := (cAliasTDZ)->(TDZ_NICKPE)
				nValDesc := (cAliasTDZ)->(TDZ_PERC)
			EndIf

			// Verbas que existem na planilha do Posto:
			If oPlanTFF:CellExists(cNickName)
				// Verba no RH acima da planilha / Valor configuração acima da planilha:
				If nValorRH > nValorTFF .Or. nValPORCEN > nValorTFF .Or. nValPORALT > nValorTFF
					lInsere := .T.
					lRet    := .T.
				EndIf				

				// Verba na planilha não obrigatória (precisa manter):
				If (cAliasTDZ)->(TDZ_OBRGT) <> "1"
					lInsere := .T.
				EndIf

				If _lPercDesc
					// Considera sempre o menor Valor do Desconto da verba:
					If oPlanTFF:CellExists(cNickName)
						If oPlanTFF:GetCellValue(cNickName) < nValDesc
							nValDesc := oPlanTFF:GetCellValue(cNickName)
						EndIf
					EndIf
				EndIf
			Else
				// Obrigatória na Config. mas não está na planilha antiga:
				If (cAliasTDZ)->(TDZ_OBRGT) == "1"
					lInsere := .T.
					lRet    := .T.
				EndIf
			EndIf

			// Valor no RH maior que na configuração:
			If nValorRH > nValPORCEN .Or. (nValorRH > nValPORALT .And. nValPORALT <> 0)
				lInsere  := .T.
				lRet     := .T.
				lAttConf := .T. // Atualiza a Configuração de Cálculo caso o Valor no RH seja maior que o da configuração ou caso o alterável seja diferente de zero e menor que no RH:
			EndIf

			If lInsere
				If aScan(aBenefi, {|x| x[1]==cNickName .AND. x[3]==cCodTFF}) == 0
					aAdd(aBenefi, { cNickName, ; //...................... [1] Nick do benefício na Configuração de Cálculo
									nMaior, ; //......................... [2] Valor do benefício no RH
									cCodTFF, ; //........................ [3] Código do Posto
									(cAliasTDZ)->(TDZ_CODIGO), ; //...... [4] Código da TDZ dentro da Configuração de Cálculo
									cCfgRevi, ; //....................... [5] Revisão da Configuração de Cálculo
									nValPORCEN, ; //..................... [6] Valor diario CCT na Configuração de Cálculo
									nValPORALT, ; //..................... [7] Valor diario diferenciado na Configuração de Cálculo
									lAttConf,; //........................ [8] Se é necessário atualizar a configuração de cálculo
									AllTrim(At996aDsc((cAliasTDZ)->TDZ_CODSLY,(cAliasTDZ)->TDZ_TIPBEN)),;// [9] Descrição na configuração de cálculo
									AllTrim((cAliasTDZ)->(TDZ_NICK)),; // [10] Nick da célula
									(cAliasTDZ)->(TDZ_FORMUL),; //....... [11] Formula da célula
									cNickDesc,; //....................... [12] Nickname do Desconto
									nValDesc,; //........................ [13] Valor do Desconto
									nValorRH}) //........................ [14] Valor no RH
				EndIf					
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
/*/{Protheus.doc} At870FVAdVld
Retorna Pesquisar Verbas Adicionais da Cnf cálculo para comparar com a Planilha do Orçamento
@since  17/06/2026
@author jack.junior
@return lRet
/*/
//------------------------------------------------------------------------------
Static Function At870FVAdVld(cAlias, cCfgCalc, cCfgRevi, oPlanTFF)
	Local aAreaSav   := GetArea()
	Local cAliasTXO  := ""
	Local cCodTFF    := ""
	Local cQry       := ""
	Local lInsere    := .F. // Se insere no array para atualizar a Planilha
	Local lRet       := .F. // Se o Posto precisa atualizar a planilha
	Local nValorTFF  := 0
	Local nValPORALT := 0
	Local nMaior	 := 0
	Local oQry       := Nil

	cCodTFF  := (cAlias)->TFF_COD

	If !Empty(cCfgCalc)

		cQry := "SELECT TXO.TXO_NICKPO, TXO.TXO_PORALT, TXO.TXO_NICK, TXO.TXO_FORMUL, TXO.TXO_DESCRI "
		cQry += "FROM ? TXO "
		cQry += "INNER JOIN ? TCW ON TCW.TCW_FILIAL = ? AND TCW.TCW_CODIGO = TXO.TXO_CODTCW AND TCW.TCW_REVISA = TXO.TXO_REVISA AND TCW.D_E_L_E_T_ = ' ' "
		cQry += "WHERE TXO.TXO_FILIAL= ? AND TXO.TXO_CODTCW = ? AND TXO.TXO_REVISA =  ? AND TXO.TXO_NICK <> ' ' AND TXO.TXO_NICKPO <> ' ' AND TXO.D_E_L_E_T_= ' ' AND TXO.TXO_ITEM <> '01' "

		cQry := ChangeQuery(cQry)
		oQry := FwExecStatement():New(cQry)

		oQry:SetUnsafe( 1, RetSqlName( "TXO" ) )
		oQry:SetUnsafe( 2, RetSqlName( "TCW" ) )
		oQry:SetString( 3, FwxFilial( "TCW" ) )
		oQry:SetString( 4, FwxFilial( "TXO" ) )
		oQry:SetString( 5, cCfgCalc )
		oQry:SetString( 6, cCfgRevi )

		cAliasTXO := oQry:OpenAlias()

		While (cAliasTXO)->(!Eof())
			lInsere   := .F. // Se insere no array para atualizar a Planilha

			// Nickname da Verba:
			cNickName := AllTrim((cAliasTXO)->(TXO_NICKPO))
			// Valor "alterável" da verba na configuração:
			nValPORALT := (cAliasTXO)->(TXO_PORALT)
			// Valor que está na planilha HOJE:
			nValorTFF := oPlanTFF:GetCellValue(cNickName)

			// O maior Valor é sempre o que vai para a planilha:
			nMaior := nValPORALT
			If nValorTFF > nMaior
				nMaior := nValorTFF
			EndIf

			// Verbas que existem na planilha do Posto:
			If oPlanTFF:CellExists(cNickName)
				// Verba no RH acima da planilha / Valor configuração acima da planilha:
				lInsere := .T.
				If nValPORALT > nValorTFF
					lRet := .T.
				EndIf				
			EndIf

			If lInsere
				If aScan(aVerbAdc, {|x| x[1]==cNickName .AND. x[3]==cCodTFF}) == 0
					aAdd(aVerbAdc, { cNickName, ; //....................... [1] Nick do benefício na Configuração de Cálculo
									nMaior, ; //........................... [2] Valor do benefício na Configuração de Cálculo
									cCodTFF, ; //.......................... [3] Código do Posto
									.F.,; //............................... [4] Se deleta a ABP nova
									AllTrim((cAliasTXO)->(TXO_DESCRI)),; // [5] Descrição da verba adicional
									AllTrim((cAliasTXO)->(TXO_NICK)),;   // [6] Nickname do valor total
									AllTrim((cAliasTXO)->(TXO_FORMUL))}) // [7] Formula do total
				EndIf					
			EndIf
			(cAliasTXO)->(DbSkip())
		EndDo

		(cAliasTXO)->(DbCloseArea())
		oQry:Destroy()
		FwFreeObj(oQry)

        // Verifica se alguma verba foi deletada da configuração mas está no contrato na ABP:
        DbSelectArea("ABP")
        ABP->(DbSetOrder(2)) // ABP_FILIAL+ABP_ITRH
        If ABP->(DbSeek(xFilial("ABP")+cCodTFF))
            While ABP->(!Eof())
                If ABP->ABP_CONFCA == "1" .AND. !Empty(ABP->ABP_NICKPO)
                    // Se o nick ta na ABP mas não está na configuração nova, adiciona no array para excluir da revisão:
                    If !(hasNick(cCfgCalc, cCfgRevi, ABP->ABP_NICKPO))
                        If aScan(aVerbAdc, {|x| x[1]==ABP->ABP_NICKPO .AND. x[3]==cCodTFF}) == 0
                            aAdd(aVerbAdc, { ABP->ABP_NICKPO, ;	// [1] Nick do benefício na Configuração de Cálculo
                                            0, ; //............... [2] Valor do benefício na Configuração de Cálculo
                                            cCodTFF, ; //......... [3] Código do Posto
                                            .T.,; //.............. [4] Se deleta a ABP nova
											"",; //............... [5] Compatibilidade
											"",; //............... [6] Compatibilidade
											""}) //............... [7] Compatibilidade         
                            lRet := .T.
                        EndIf	
                    EndIf
                EndIf
                ABP->(DbSkip())
            End 
        EndIf

	EndIf

	RestArea(aAreaSav)

Return lRet

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
	Local aContrt    := {}
	Local aErroMVC   := {}
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
	Local cFormTot   := ""
	Local cFormula   := ""
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
	Local lTemArm    := .F.
	Local lTemBenef  := .F.
	Local lTemMC     := .F.
	Local lTemMI     := .F.
	Local lTemRevis  := .F.
	Local lTemSal    := .F.
	Local lTemUni    := .F.
	Local lTemVerAdc := .F.
	Local lTemVerba  := .F.
	Local nIni       := 0
	Local nLine      := 0
	Local nPercReaj  := 0
	Local nRegs      := 0
	Local nSalario   := 0
	Local nSalBase   := 0
	Local nTotReg    := 0
	Local nVlFixo    := 0
	Local nX         := 0
	Local nY         := 0
	Local nZ         := 0
	Local oMdlABP    := Nil
	Local oMdlRh     := Nil
	Local oMdlTFG    := Nil
	Local oMdlTFH    := Nil
	Local oMdlTXP    := Nil
	Local oMdlTXQ    := Nil
	Local oModel     := Nil
	Local oPlaTFF    := Nil

	Default nTotReg := 0
	Default oSay    := Nil

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
														DbSelectArea("ABW")
														ABW->(DbSetOrder(1)) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
														// XML da Planilha ABW atualizada
														If ABW->(DbSeek(xFilial("ABW")+TFF->(TFF_PLACOD)+cCodRev)) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
															cXML := ABW->ABW_INSTRU
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
									oMdlABP := oModel:GetModel("ABP_BENEF")

									// Posicionar no Posto do Modelo
									oMdlRh:SeekLine({{"TFF_COD",cCodTFF}})

									lTemArm    := (cAlias)->(ARMAMENTO)
									lTemMC     := (cAlias)->(MAT_MC)
									lTemMI     := (cAlias)->(MAT_MI)
									lTemSal    := (cAlias)->(SALBAS)
									lTemUni    := (cAlias)->(UNIFORME)
									lTemVerba  := aScan(aVerbas,  {|x| x[3] == cOldTFF}) > 0
									lTemBenef  := aScan(aBenefi,  {|x| x[3] == cOldTFF}) > 0
									lTemVerAdc := aScan(aVerbAdc, {|x| x[3] == cOldTFF}) > 0

									// ORÇAMENTO: Atualizar MI:
									If lTemMI
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
									If lTemMC
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
									If lTemArm
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
									If lTemUni
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

									// Sempre aplica a planilha Atualizada da ABW:
									At998ExPla(cXML,@oModel,.F.,cCodPla+cCodRev,.F.)
									cXML := oMdlRh:GetValue("TFF_CALCMD")

									If lTemSal .Or. lTemVerba .Or. lTemBenef .Or. lTemVerAdc
		
										//instancia a planilha sem exibição para atualização de verbas:
										oPlaTFF := GsPlan():New()
										
										oPlaTFF:LoadXmlModel(cXML)

										// PLANILHA: Atualizar Salario Base
										If lTemSal
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
															nSalario := at998SalCCT(TCW->TCW_CODCCT, (cAlias)->(RJ_FUNCAO)) 
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
										If lTemVerba
											For nX := 1 To Len(aVerbas)
												If cOldTFF == aVerbas[nX][3] .And. AllTrim(aVerbas[nX][1]) <> "VLR_SB"
													lAttVer := .T.
													cFormula := ""
													If oPlaTFF:CellExists(aVerbas[nX,1])
														oPlaTFF:SetCellValue(aVerbas[nX,1], aVerbas[nX,2])
													Else
														nLine 	:= 3
														While !Empty(oPlaTFF:getCellValue("I"+cValToChar(nLine))) //Valida se existe registro na linha
															nLine++
														End
														If !Empty( aVerbas[nX,11] )
															cFormula := "=" + aVerbas[nX,11]
														EndIf
														
														//DESCRIÇÃO - COLUNA I -- TCX_DESCRI -> Descrição
														oPlaTFF:addCell("I", nLine, "", "", aVerbas[nX,9], "!@")
														//VALOR - COLUNA J -- TCX_NICKPO -> TCX_PORALT
														oPlaTFF:addCell("J", nLine, aVerbas[nX,1], "", aVerbas[nX,2], "@E 999,999,999.99")
														//FORMULA - COLUNA K -- TCX_NICK -> Maior valor entre RH, Conf. e Plan antiga
														oPlaTFF:addCell("K", nLine, aVerbas[nX,10], cFormula, 0, "@E 999,999,999.99")
													EndIf
												EndIf
											Next nX
										EndIf

										// PLANILHA: Atualizar Beneficios
										If lTemBenef
											For nX := 1 To Len(aBenefi)
												If cOldTFF == aBenefi[nX][3]
													lAttBen := .T.
													cFormula := ""
													If oPlaTFF:CellExists(aBenefi[nX,1])
														oPlaTFF:SetCellValue(aBenefi[nX,1], aBenefi[nX,2])
													Else
														nLine 	:= 3
														While !Empty(oPlaTFF:getCellValue("I"+cValToChar(nLine))) //Valida se existe registro na linha
															nLine++
														End
														If !Empty( aBenefi[nX,11] )
															cFormula := "=" + aBenefi[nX,11]
														EndIf
														
														//DESCRIÇÃO - COLUNA I -> Descrição
														oPlaTFF:addCell("I", nLine, "", "", aBenefi[nX,9], "!@")
														//VALOR - COLUNA J
														oPlaTFF:addCell("J", nLine, aBenefi[nX,1], "", aBenefi[nX,2], "@E 999,999,999.99")
														//FORMULA - COLUNA K -- TDZ_NICK -> Maior valor entre RH, Conf. e Plan antiga
														oPlaTFF:addCell("K", nLine, aBenefi[nX,10], cFormula, 0, "@E 999,999,999.99")
														If _lPercDesc
															//FORMULA - COLUNA L
															oPlaTFF:addCell("L", nLine, aBenefi[nX,12], "", aBenefi[nX,13], "@E 999,999,999.99")
														EndIf
													EndIf
												EndIf
											Next nX
										EndIf

										// PLANILHA: Atualizar Verbas Adicionais
										If lTemVerAdc
											For nX := 1 To Len(aVerbAdc)
												If cOldTFF == aVerbAdc[nX][3]
													cFormula := ""
													cFormTot := ""
													// Verifica se é para Deletar a ABP ou atualizar a planilha:
													If aVerbAdc[nX,4]
														// Deleção das ABP que não estão na configuração de cálculo:
														For nY := 1 To oMdlABP:Length()
															oMdlABP:GoLine(nY)
															If AllTrim(oMdlABP:GetValue("ABP_NICKPO")) == AllTrim(aVerbAdc[nX,1])
																oMdlABP:DeleteLine()
															EndIf
														Next nY
													Else
														If oPlaTFF:CellExists(aVerbAdc[nX,1])
															oPlaTFF:SetCellValue(aVerbAdc[nX,1], aVerbAdc[nX,2])
														Else
															// Cria a linha de título e total das verbas adicionais se não houver:
															If Empty(oPlaTFF:getCellValue("P2"))
																oPlaTFF:addCell("N", 1, "", "", "%PORCENTAGEM", "!@")
																oPlaTFF:addCell("O", 1, "", "", "VALOR", "!@")
																oPlaTFF:addCell("P", 1, "", "", "TOTAL", "!@")

																cFormTot := At870FForm(cConfCal, cConfVer)
																oPlaTFF:addCell("M", 2, "", "", "VERBAS ADICIONAIS", "!@")
																oPlaTFF:addCell("P", 2, "TOT_VERAD", cFormTot, "TOTAL", "@E 999,999,999.99")
															EndIf

															nLine := 3 //Registros à partir da terceira linha da planilha
															While !Empty(oPlaTFF:getCellValue("M"+cValToChar(nLine))) //Valida se existe registro na linha
																nLine ++
															EndDo

															If !Empty(aVerbAdc[nX,7])
																cFormula := "="+aVerbAdc[nX,7]
															EndIf

															//DESCRIÇÃO - COLUNA M
															oPlaTFF:addCell("M", nLine, "", "", aVerbAdc[nX,5], "!@")
															//VALOR - COLUNA N
															oPlaTFF:addCell("N", nLine, aVerbAdc[nX,1], "", aVerbAdc[nX,2], "@E 999,999,999.99")
															//FORMULA - COLUNA O
															oPlaTFF:addCell("O", nLine, aVerbAdc[nX,6], cFormula, 0, "@E 999,999,999.99")
														EndIf
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
									oMdlRh:SetValue("TFF_CALCMD", cXML)
									oMdlRh:SetValue("TFF_VLFIXO", nVlFixo)

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
		If ((cAliasTmp)->(B1_PRV1) <> (cAliasTmp)->(TXQ_PRCVEN)) .And. (cAliasTmp)->(B1_PRV1) > 0
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
		If ((cAliasTmp)->(B1_PRV1) <> (cAliasTmp)->(TXP_PRCVEN)) .And. (cAliasTmp)->(B1_PRV1) > 0
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
				If aBenefi[nX][14] > aBenefi[nX][6]
					//TDZ_FILIAL+TDZ_CODIGO+TDZ_REVISA
					If TDZ->(dbSeek(xFilial("TDZ")+aBenefi[nX][4]+aBenefi[nX][5]))
						If TDZ->(RecLock("TDZ", .F.))

							//Atualiza Valor dia da CCT na configuração:
							TDZ->TDZ_VALOR := aBenefi[nX][14]

							//Caso o valor diario diferenciado da configuração for diferente de zero e valor menor que o benefício do RH
							If aBenefi[nX][7] <> 0 .AND. aBenefi[nX][14] > aBenefi[nX][7]
								TDZ->TDZ_VLRDIF := aBenefi[nX][14]
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
				If aVerbas[nX][12] > aVerbas[nX][6]
					//TCX_FILIAL+TCX_CODIGO+TCX_REVISA
					If TCX->(dbSeek(xFilial("TCX")+aVerbas[nX][4]+aVerbas[nX][5]))
						If TCX->(RecLock("TCX", .F.))

							//Atualiza Valor dia da CCT na configuração:
							TCX->TCX_PORCEN := aVerbas[nX][12]

							//Caso o valor diario diferenciado da configuração for diferente de zero e valor menor que o benefício do RH
							If aVerbas[nX][7] <> 0 .AND. aVerbas[nX][12] > aVerbas[nX][7]
								TCX->TCX_PORALT := aVerbas[nX][12]
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

//------------------------------------------------------------------------------
/*/{Protheus.doc} hasNick
Verifica se um nick está na configuração de cálculo
@param cCfgCalc, código da configuração
		cCfgRevi, código da revisão da conf.
		cNickPO, Nick que será procurado

@return lRet, .T. se achar o nick

@since	17/06/2026
@author jack.junior
/*/
//------------------------------------------------------------------------------
Static Function hasNick(cCfgCalc, cCfgRevi, cNickPO) 
	Local cAliasTXO := ""
	Local cQry      := ""
	Local lRet      := .F.

	cQry := " SELECT 1 "
	cQry += " FROM ? TXO "
	cQry += " INNER JOIN ? TCW ON TCW.TCW_FILIAL = ? AND TCW.TCW_CODIGO = TXO.TXO_CODTCW AND TCW.TCW_REVISA = TXO.TXO_REVISA AND TCW.D_E_L_E_T_ = ' ' "
	cQry += " WHERE TXO.TXO_FILIAL= ? AND TXO.TXO_CODTCW = ? AND TXO.TXO_REVISA =  ?  AND TXO.TXO_NICKPO =  ? AND TXO.D_E_L_E_T_= ' ' "

	cQry := ChangeQuery(cQry)
	oQry := FwExecStatement():New(cQry)

	oQry:SetUnsafe( 1, RetSqlName( "TXO" ) )
	oQry:SetUnsafe( 2, RetSqlName( "TCW" ) )
	oQry:SetString( 3, FwxFilial( "TCW" ) )
	oQry:SetString( 4, FwxFilial( "TXO" ) )
	oQry:SetString( 5, cCfgCalc )
	oQry:SetString( 6, cCfgRevi )
	oQry:SetString( 7, cNickPO )

	cAliasTXO := oQry:OpenAlias()

	If (cAliasTXO)->(!Eof())
		lRet := .T.
	EndIf

	(cAliasTXO)->(DbCloseArea())
	oQry:Destroy()
	FwFreeObj(oQry)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At870FForm
Retorna a fórmula do TOT_VERAD que está na configuração de cálculo
@param cConfCal, código da configuração
		cConfVer, código da revisão da conf.

@return cFormula, fórmula do TOT_VERAD da TXO

@since	30/06/2026
@author jack.junior
/*/
//------------------------------------------------------------------------------
Static Function At870FForm(cConfCal, cConfVer)
	Local cAliasTXO := ""
	Local cFormula  := ""
	Local cQry      := ""

	If !Empty(cConfCal)
		cQry := " SELECT TXO_FORMUL "
		cQry += " FROM ? TXO "
		cQry += " WHERE TXO.TXO_FILIAL= ? AND "
		cQry += 	  " TXO.TXO_CODTCW = ? AND "
		cQry += 	  " TXO.TXO_REVISA = ? AND "
		cQry += 	  " TXO.TXO_NICK = ? AND "
		cQry += 	  " TXO.D_E_L_E_T_= ' ' "

		cQry := ChangeQuery(cQry)
		oQry := FwExecStatement():New(cQry)

		oQry:SetUnsafe( 1, RetSqlName( "TXO" ) )
		oQry:SetString( 2, FwxFilial( "TXO" ) )
		oQry:SetString( 3, cConfCal )
		oQry:SetString( 4, cConfVer )
		oQry:SetString( 5, "TOT_VERAD" )

		cAliasTXO := oQry:OpenAlias()

		If (cAliasTXO)->(!Eof())
			cFormula := AllTrim((cAliasTXO)->TXO_FORMUL) 
		EndIf

		(cAliasTXO)->(DbCloseArea())
		oQry:Destroy()
		FwFreeObj(oQry)
	EndIf

Return cFormula
