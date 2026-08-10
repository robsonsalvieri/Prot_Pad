#INCLUDE "TOTVS.CH"
#INCLUDE "TECA765.CH"

Static cTmpAlias := ""
Static oGSTmpTb

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA765
@description Monitor de Marcações de Atendentes
@sample TECA765()
@since  23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Function TECA765()

	Local cPerg := "TECA765"
	Local aArea := GetArea()

	Private cCadastro := STR0001 //"Monitor de Marcações de Atendentes"

	If AliasInDic("T40") .AND. T40->(ColumnPos('T40_CIC')) > 0
		DbSelectArea("T40")
		T40->(DbSetOrder(4)) //T40_FILIAL+T40_VALCON
		If Pergunte(cPerg,.T.)
			AT765Brow(cPerg)
		Endif
		RestArea(aArea)
	Else
		Help( " ", 1, "TECA765", Nil, STR0004, 1 ) //"Tabela T40 não existe no dicionário de Dados"
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765Brow
Definicao do Objeto Browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765Brow(cPerg)

	Local oBrowse  := Nil
	Local aStru    := AT765aStru()
	Local bTimer   := {||AT765AtBrw(@oBrowse)}
	Local aColumns := {}
	Local aSeek    := {}

	oBrowse:= FWmBrowse():New()
	oBrowse:SetDataQuery(.F.)
	oBrowse:SetDataTable(.T.)

	FwMsgRun(Nil,{|oSay|At765Cria(@oBrowse,oSay)}, STR0005, STR0006) //"Aguarde..."##"Processando a requisição solicitada..."

	oBrowse:SetMenuDef("")
	oBrowse:SetDescription(OEmToAnsi(cCadastro))

	oBrowse:AddButton(STR0007,{||Pergunte(cPerg,.T.),AT765AtBrw(@oBrowse)}) // Parametros
	oBrowse:AddButton(STR0008,{||CloseBrowse()}) // Sair

	oBrowse:AddStatusColumns( { || Chkmarc(1) }, { || ConsLeg(1) } ) // Legenda das marcações
	oBrowse:AddStatusColumns( { || Chkmarc(2) }, { || ConsLeg(2) } ) // Legenda da cerca eletrônica

	// Ponto de entrada para personalização do Browse
	If ExistBlock("TC765Bro")
		oBrowse := ExecBlock("TC765Bro", .F., .F., {oBrowse} )
	EndIf

	aColumns := AT765aCols(aStru)
	oBrowse:SetColumns(aColumns)

	aAdd(aSeek, {TxDadosCpo('AA1_NOMTEC')[1],{{'','C',TamSX3('AA1_NOMTEC')[1],TamSX3('AA1_NOMTEC')[2],TxDadosCpo('AA1_NOMTEC')[1],PesqPict('AA1','AA1_NOMTEC'),NIL}},1,.T.})
	aAdd(aSeek, {TxDadosCpo('ABB_CODTEC')[1],{{'','C',TamSX3('ABB_CODTEC')[1],TamSX3('ABB_CODTEC')[2],TxDadosCpo('ABB_CODTEC')[1],PesqPict('ABB','ABB_CODTEC'),NIL}},2, .T.})
	
	oBrowse:SetSeek(.T., aSeek)

	oBrowse:SetTimer(bTimer, MV_PAR01 * 60000) // 60.000 aproximadamente 1 Minuto
	oBrowse:SetParam({||Pergunte(cPerg,.T.),AT765AtBrw(@oBrowse)})

	oBrowse:DisableConfig()

	oBrowse:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765AtBrw
Criacao do Objeto Browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Function AT765AtBrw(oBrowse)

	(At765Alias())->(DbCloseArea())
	FwMsgRun(Nil,{|oSay|At765Cria(@oBrowse,oSay)}, STR0005, STR0006) //"Aguarde..."##"Processando a requisição solicitada..."
	oBrowse:Refresh(.T.)
	
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Alias
Retorna alias uso do browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At765Alias(cSetValue)

	If VALTYPE(cSetValue) == 'C'
		cTmpAlias := cSetValue
	EndIf

Return cTmpAlias

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765QryGen
Retorna objeto query usado no browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At765QryGen(aTmpStruct, oQuery)
Local cQuery      := ""
Local cFields     := ""
Local cxFilTDV    := " ABB.ABB_FILIAL = '" + xFilial("TDV",cFilAnt) + "'"
Local lRegra      := .F.
Local lNoCheckin  := .F.
Local lMV_MultFil := TecMultFil() //Indica se considera multiplas filiais
Local nNumQuery   := 1
Local nX          := 0

// Tratamento de range de filiais
MakeSqlExp("TECA765")

iF !Empty(MV_PAR07)
	IF MV_PAR07 == 1
		lNoCheckin := .T.
	Else
		lNoCheckin := .F.
	EndIf
EndIf

// Formatar parametro do tipo Range
If lMV_MultFil .And. Empty(MV_PAR02)
	cxFilTDV := "1 = 1 "
Else
	If !Empty(MV_PAR02)
		cxFilTDV := MV_PAR02
	Endif
EndIf

For nX := 1 To Len(aTmpStruct)
	If aTmpStruct[nX,1] $ "TFF_REGRA"
		lRegra := .T.
	EndIf
	If !aTmpStruct[nX,1] $ "T40_TIPOMA|T40_HPREVI|T40_DISTMT"
		cFields += aTmpStruct[nX,1] + ", "
	EndIf
Next nX

cQuery += " SELECT DISTINCT ? "
// Campos Virtuais
cQuery += "' ' T40_TIPOMA, ' ' T40_HPREVI, 0 T40_DISTMT "
// Integração de marcações
cQuery += " FROM ? T40 "
// Funcionários
cQuery += " INNER JOIN ? SRA ON SRA.RA_CIC = T40.T40_CIC AND (RA_DEMISSA=' ' OR RA_DEMISSA > T40.T40_DATMAR) AND SRA.D_E_L_E_T_ = ' ' "

IF lNoCheckin
	// Atendentes
	cQuery += " LEFT JOIN ? AA1 ON AA1.AA1_FUNFIL = SRA.RA_FILIAL AND AA1.AA1_CDFUNC = SRA.RA_MAT AND AA1.D_E_L_E_T_ = ' ' "
	// Agendas
	cQuery += " LEFT JOIN ? ABB ON  ? AND ABB.ABB_CODTEC = AA1.AA1_CODTEC AND ABB.D_E_L_E_T_ = ' ' "
Else
	// Atendentes
	cQuery += " INNER JOIN ? AA1 ON AA1.AA1_FUNFIL = SRA.RA_FILIAL AND AA1.AA1_CDFUNC = SRA.RA_MAT AND AA1.D_E_L_E_T_ = ' ' "
	// Agendas
	cQuery += " INNER JOIN ? ABB ON  ? AND ABB.ABB_CODTEC = AA1.AA1_CODTEC AND ABB.D_E_L_E_T_ = ' ' "
EndIf
If (!Empty(MV_PAR03) .AND. !Empty(MV_PAR04)) .OR. (Empty(MV_PAR03) .AND. !EMPTY(MV_PAR04))
	cQuery += " AND ABB.ABB_LOCAL BETWEEN ? AND ? "
Else
	If !Empty(MV_PAR03) .AND. EMPTY(MV_PAR04)
		cQuery += " AND ABB.ABB_LOCAL = ? "
	EndIf
EndIf
cQuery += " AND ((ABB.ABB_MARENT=T40_VALCON AND ABB.ABB_DTINI=T40.T40_DATMAR) OR (ABB.ABB_MARSAI=T40_VALCON AND ABB.ABB_DTFIM=T40.T40_DATMAR)) "
// Local Atendimento
IF lNoCheckin
	cQuery += " LEFT JOIN ? ABS ON ABS.ABS_FILIAL= ? AND ABS.ABS_LOCAL=ABB.ABB_LOCAL AND ABS.D_E_L_E_T_ = ' ' "
Else
	cQuery += " INNER JOIN ? ABS ON ABS.ABS_FILIAL= ? AND ABS.ABS_LOCAL=ABB.ABB_LOCAL AND ABS.D_E_L_E_T_ = ' ' "
EndIf
// Cfg Agenda
IF lNoCheckin
	cQuery += "LEFT JOIN ? TDV ON TDV.TDV_FILIAL= ABB.ABB_FILIAL AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.D_E_L_E_T_ = ' ' "
Else
	cQuery += "INNER JOIN ? TDV ON TDV.TDV_FILIAL= ABB.ABB_FILIAL AND TDV.TDV_CODABB = ABB.ABB_CODIGO AND TDV.D_E_L_E_T_ = ' ' "
EndIf
// Regra de Apontamento TFF - join ABQ e TFF
If lRegra
	IF lNoCheckin
		cQuery += " LEFT JOIN ? ABQ ON "
		If lMV_MultFil
			cQuery += " ? "
		Else
			cQuery += " ABQ.ABQ_FILIAL = ? "
		EndIf
		cQuery += " AND ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL "
		cQuery += " AND ABQ.D_E_L_E_T_= ' ' "

		cQuery += " LEFT JOIN ? TFF ON "
		cQuery += " TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
		cQuery += " AND TFF.TFF_COD = ABQ.ABQ_CODTFF "
		cQuery += " AND TFF.D_E_L_E_T_= ' ' "
	Else
		cQuery += " INNER JOIN ? ABQ ON "
		If lMV_MultFil
			cQuery += " ? "
		Else
			cQuery += " ABQ.ABQ_FILIAL = ? "
		EndIf
		cQuery += " AND ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL "
		cQuery += " AND ABQ.D_E_L_E_T_= ' ' "

		cQuery += " INNER JOIN ? TFF ON "
		cQuery += " TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
		cQuery += " AND TFF.TFF_COD = ABQ.ABQ_CODTFF "
		cQuery += " AND TFF.D_E_L_E_T_= ' ' "
	EndIf
EndIf
cQuery += " WHERE "
cQuery += " T40_FILIAL = ? AND "
cQuery += " T40_DATMAR BETWEEN ? AND ? AND "
cQuery += " T40_AGEINT <> 'S' AND "
cQuery += " T40.D_E_L_E_T_ = ' ' AND "
cQuery += " AA1.AA1_NOMTEC <> ' ' "
If lNoCheckin
	// Se nao encontrou agenda, verificar se existe agenda em outra filial ou local
	cQuery += " AND NOT EXISTS ( "
	cQuery += " SELECT 1 FROM ? AGE WHERE "
	cQuery += " AGE.ABB_CODTEC = AA1.AA1_CODTEC AND AGE.D_E_L_E_T_ = ' ' AND "
	cQuery += " ((AGE.ABB_MARENT=T40_VALCON AND AGE.ABB_DTINI=T40.T40_DATMAR) OR (AGE.ABB_MARSAI=T40_VALCON AND AGE.ABB_DTFIM=T40.T40_DATMAR)) "
	cQuery += " AND (ABB.R_E_C_N_O_ IS NULL OR AGE.R_E_C_N_O_ <> ABB.R_E_C_N_O_) ) "
EndIf
// Ordenacao
cQuery += " ORDER BY T40.T40_CIC, T40.T40_DATMAR, T40.T40_NUMMAR "
cQuery := ChangeQuery( cQuery )

// Prepara a query:
oQuery := FwExecStatement():New(cQuery)
// Campos
oQuery:SetUnsafe( nNumQuery++, cFields )
// Integração de marcações
oQuery:SetUnsafe( nNumQuery++, RetSqlName('T40') )
// Funcionários
oQuery:SetUnsafe( nNumQuery++, RetSqlName('SRA') )
// Atendentes
oQuery:SetUnsafe( nNumQuery++, RetSqlName('AA1') )
// Agendas
oQuery:SetUnsafe( nNumQuery++, RetSqlName('ABB') )
oQuery:SetUnsafe( nNumQuery++, cxFilTDV )
If (!Empty(MV_PAR03) .AND. !Empty(MV_PAR04)) .OR. (Empty(MV_PAR03) .AND. !EMPTY(MV_PAR04))
	oQuery:SetString( nNumQuery++, MV_PAR03 )
	oQuery:SetString( nNumQuery++, MV_PAR04 )
Else
	If !Empty(MV_PAR03) .AND. EMPTY(MV_PAR04)
		oQuery:SetString( nNumQuery++, MV_PAR03 )
	EndIf
EndIf
// Local Atendimento
oQuery:SetUnsafe( nNumQuery++, RetSqlName('ABS') )
oQuery:SetString( nNumQuery++, xFilial("ABS") )
// Cfg Agenda
oQuery:SetUnsafe( nNumQuery++, RetSqlName('TDV') )
// Regra de Apontamento TFF - join ABQ e TFF
If lRegra
	oQuery:SetUnsafe( nNumQuery++, RetSqlName('ABQ') )
	If lMV_MultFil
		oQuery:SetUnsafe( nNumQuery++, FWJoinFilial("ABQ" , "ABB" , "ABQ", "ABB", .T.) )
	Else
		oQuery:SetString( nNumQuery++, xFilial("ABQ") )
	EndIf
	oQuery:SetUnsafe( nNumQuery++, RetSqlName('TFF') )
EndIf
// Integração de marcações
oQuery:SetString( nNumQuery++, xFilial("T40"))
oQuery:SetString( nNumQuery++, DtOS(MV_PAR05) )
oQuery:SetString( nNumQuery++, DTOS(MV_PAR06) )
If lNoCheckin
	oQuery:SetUnsafe( nNumQuery++, RetSqlName('ABB') )
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Cria
Criacao tabela temporaria
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At765Cria(oBrw,oSay)

Local cAliasTmp    := ""
Local aTmpStruct   := AT765aStru()
Local aAgendas     := {} //Array com batidas da ABB
Local aInsert      := {}
Local aIdx         := {}
Local cAliasAux    := ""
Local cOperado     := ""
Local cCodTecABB   := ""
Local cFilialABB   := ""
Local cDatMarT40   := ""
Local cTipoMar     := ""
Local cLimiteMar   := ""
Local cTipo        := "" // Tipo de marcação
Local cGeofence    := "" // Dentro ou Fora da cerca eletrônica
Local lOK          := .F.
Local lRet         := .F.
Local lRegra 	   := TFF->(ColumnPos('TFF_REGRA')) > 0
Local nAtual       := 1
Local nX           := 0
Local nHoraIniABB  := 0
Local nAgenda      := 0
Local nBatidas     := 0
Local nEntrAtraso1 := 0 // Entrada com atraso 1
Local nSaidAtraso1 := 0 // Saida   com atraso 1
Local nEntrAtraso2 := 0 // Entrada com atraso 2
Local nSaidAtraso2 := 0 // Saida   com atraso 2
Local nEntrHExtra1 := 0 // Entrada com hora extra 1
Local nSaidHExtra1 := 0 // Saida   com hora extra 1
Local nEntrHExtra2 := 0 // Entrada com hora extra 2
Local nSaidHExtra2 := 0 // Saida   com hora extra 2
Local nDistMts     := 0 // Distancia em metros
Local nHoraLEExtra := 0
Local nHoraLIMEnt  := 0
Local nHoraBatida  := 0
Local xValue       := Nil
Local oQry         := Nil

	If VALTYPE(oGSTmpTb) == 'O'
		oGSTmpTb:Close()
		TecDestroy(oGSTmpTb)
	EndIf

	//Cria indices para a tabela temporária
	Aadd(aIdx, {"I1",{ 'AA1_NOMTEC' }})
	Aadd(aIdx, {"I2",{ 'ABB_CODTEC' }})

	cAliasTmp := At765Alias()
	If Empty(cAliasTmp)
		cAliasTmp := GetNextAlias()
	EndIf

	oGSTmpTb  := GSTmpTable():New(cAliasTmp,aTmpStruct,aIdx)
	If !oGSTmpTb:CreateTMPTable()
		oGSTmpTb:ShowErro()
	Else

		At765QryGen(aTmpStruct, @oQry)
		cAliasAux := oQry:OpenAlias()

			While (cAliasAux)->(!EOF())

				aInsert := {}

				//Reseta o registro quando trocar o atendente:
				If cCodTecABB != (cAliasAux)->ABB_CODTEC
					cDatMarT40   := ""
					nEntrAtraso1 := 0
					nSaidAtraso1 := 0
					nEntrAtraso2 := 0
					nSaidAtraso2 := 0
					nEntrHExtra1 := 0
					nSaidHExtra1 := 0
					nEntrHExtra2 := 0
					nSaidHExtra2 := 0
				EndIf

				If cDatMarT40 <> (cAliasAux)->TDV_DTREF
					lOk := .F.
					cCodTecABB := (cAliasAux)->ABB_CODTEC // Codigo do atendente
					cFilialABB := (cAliasAux)->ABB_FILIAL // Filial da Agenda
					cDatMarT40 := (cAliasAux)->TDV_DTREF // Data da batida
					aAgendas   := ChkQtdAtd(cCodTecABB,cDatMarT40,cFilialABB) // Array com as batidas da ABB
					nBatidas   := Len(aAgendas) //Quantidade de batidas
					If lRegra
						cLimiteMar := (cAliasAux)->TFF_REGRA
					EndIf
					If Empty(cLimiteMar)
						cLimiteMar := (cAliasAux)->ABS_REGRA // Codigo da pesquisa de marcações
					EndIf
					If !Empty(cLimiteMar) .And. SPA->(DbSeek(Xfilial("SPA")+cLimiteMar))
						nEntrAtraso1 := At765LimTol(SPA->PA_TOLASAI,1) // Entrada com atraso 1
						nSaidAtraso1 := At765LimTol(SPA->PA_TOLASAI,2) // Saida   com atraso 1
						nEntrAtraso2 := At765LimTol(SPA->PA_TOLASAI,3) // Entrada com atraso 2
						nSaidAtraso2 := At765LimTol(SPA->PA_TOLASAI,4) // Saida   com atraso 2
						nEntrHExtra1 := At765LimTol(SPA->PA_TOLHEX,1)  // Entrada com hora extra 1
						nSaidHExtra1 := At765LimTol(SPA->PA_TOLHEX,2)  // Saida   com hora extra 1
						nEntrHExtra2 := At765LimTol(SPA->PA_TOLHEX,3)  // Entrada com hora extra 2
						nSaidHExtra2 := At765LimTol(SPA->PA_TOLHEX,4)  // Saida   com hora extra 2
					Endif
				Endif
				cTipo := "O" // Tipo de marcação
				nHoraBatida := (cAliasAux)->T40_NUMMAR  // Hora da batida
				nAgenda := aScan(aAgendas,{|x|x[2]==(cAliasAux)->T40_VALCON})
				If nAgenda > 0
					If nAgenda == 1
						nHoraIniABB  := TECXMinHor(aAgendas[nAgenda,1])
						nHoraLIMEnt  := nHoraIniABB+nEntrAtraso1 // Hora Prevista de entrada + Tolerancia de Atraso
						nHoraLEExtra := nHoraIniABB-nEntrHExtra1 // Hora Prevista de entrada + Tolerancia de extra entrada
						If nHoraLIMEnt < nHoraBatida
							lOk := .T. // Batida após o horario permitido - Atraso
							cTipo := "A" //ATRASO
						Elseif nHoraBatida < nHoraLEExtra
							lOk := .T. // Batida antes da entrada - hora extra
							cTipo := "C" //ENTRADA ANTECIPADA
						Endif
						cTipoMar := STR0023 //"Entrada"
					Elseif nAgenda == 2
						nHoraIniABB  := TECXMinHor(aAgendas[nAgenda,1])
						nHoraLIMEnt  := nHoraIniABB-nSaidAtraso1 // Hora Prevista de entrada + Tolerancia de Atraso
						nHoraLEExtra := nHoraIniABB+nSaidHExtra1 // Hora Prevista de entrada + Tolerancia de extra entrada
						If nHoraBatida < nHoraLIMEnt
							lOk := .T. // Batida após o horario permitido - Atraso
							cTipo := "D" //SAIDA ANTECIPADA
						Elseif nHoraBatida > nHoraLEExtra
							lOk := .T. // Batida antes da entrada - hora extra
							cTipo := "B" //HORA EXTRA
						Endif
						cTipoMar := STR0024 //"Saida "
					Elseif nAgenda == 3
						nHoraIniABB  := TECXMinHor(aAgendas[nAgenda,1])
						nHoraLIMEnt  := nHoraIniABB+nEntrAtraso2 // Hora Prevista de entrada + Tolerancia de Atraso
						nHoraLEExtra := nHoraIniABB-nEntrHExtra2 // Hora Prevista de entrada + Tolerancia de extra entrada
						If nHoraLIMEnt < nHoraBatida
							lOk := .T. // Batida após o horario permitido - Atraso
							cTipo := "A" //ATRASO
						Elseif nHoraBatida < nHoraLEExtra
							lOk := .T. // Batida antes da entrada - hora extra
							cTipo := "C" //ENTRADA ANTECIPADA
						Endif
						cTipoMar := STR0023 //"Entrada "
					Elseif nAgenda == 4
						nHoraIniABB  := TECXMinHor(aAgendas[nAgenda,1])
						nHoraLIMEnt  := nHoraIniABB-nSaidAtraso2 // Hora Prevista de entrada + Tolerancia de Atraso
						nHoraLEExtra := nHoraIniABB+nSaidHExtra2 // Hora Prevista de entrada + Tolerancia de extra entrada
						If nHoraBatida < nHoraLIMEnt
							lOk := .T. // Batida após o horario permitido - Atraso
							cTipo := "D" //SAIDA ANTECIPADA
						Elseif nHoraBatida > nHoraLEExtra
							lOk := .T. // Batida antes da entrada - hora extra
							cTipo := "B" //HORA EXTRA
						Endif
						cTipoMar := STR0024 //"Saída"
					EndIf
				Else
					// Marcacao do atendente sem agenda na data
					lOk := .T.
					nHoraIniABB := 0
					cTipoMar := STR0032 //"Sem Agenda"
				Endif

				// Verifica se a batida está dentro da cerca eletronica (virtual)
				cGeofence := "X" // Sem cerca eletrônica
				nDistMts  := 0
				If (cAliasAux)->ABS_METROS > 0
					cGeofence := "I" // Dentro da cerca eletrônica
					// Calcula a distância entre duas coordenadas (latitude/longitude) em metros
					nDistMts := distanciaGPS(Val((cAliasAux)->T40_LATITU), Val((cAliasAux)->T40_LONGIT), Val((cAliasAux)->ABS_LATITU), Val((cAliasAux)->ABS_LONGIT))
					If (cAliasAux)->ABS_METROS < nDistMts
						lOk := .T.
						cGeofence := "O" // Fora da cerca eletrônica
					EndIf
				EndIf

				If lOK
					For nX := 1 To LEN(aTmpStruct)
						If aTmpStruct[nX][1] == 'T40_NUMMAR'
							Aadd(aInsert, {aTmpStruct[nX][1],TECXHorMin(nHoraBatida)+cTipo+cGeofence})
						ElseIf aTmpStruct[nX][1] == 'T40_TIPOMA'
							Aadd(aInsert, {aTmpStruct[nX][1], cTipoMar })
						ElseIf aTmpStruct[nX][1] == 'T40_DISTMT'
							Aadd(aInsert, {aTmpStruct[nX][1], nDistMts })
						ElseIf aTmpStruct[nX][1] == "T40_HPREVI
							If !Empty(aInsert[2][2])
								Aadd(aInsert, {aTmpStruct[nX][1], TECXHorMin(nHoraIniABB) })
							Else
								Aadd(aInsert, {aTmpStruct[nX][1], "" })
							EndIf
						Else
							xValue := (&("(cAliasAux)->" + aTmpStruct[nX][1]))
							If aTmpStruct[nX][1] == 'AA1_NOMTEC'
								cOperado := xValue
								Aadd(aInsert, {aTmpStruct[nX][1], xValue })
							ElseIf aTmpStruct[nX][2] == 'D'
								Aadd(aInsert, {aTmpStruct[nX][1], STOD(xValue) })
							Else
								Aadd(aInsert, {aTmpStruct[nX][1], xValue })
							EndIf
						EndIf
						oSay:SetText(STR0013 + cValToChar(nAtual) + STR0014 + cOperado) //"Processando o registro : "###" do operador(a) : "
						ProcessMessages()
					Next nX
				Else
					(cAliasAux)->(DbSkip())
					lOK := .F.
				Endif

				If lOK
					If ( lRet := ( oGSTmpTb:Insert(aInsert) .AND. oGSTmpTb:Commit() ) )
						(cAliasAux)->(DbSkip())
						lOK := .F.
					Else
						oGSTmpTb:ShowErro()
						Exit
					EndIf
				Endif	
				nAtual++
				cLimiteMar := ""
			End	
		oQry:Destroy()
		FwFreeObj( oQry )
		(cAliasAux)->(DbCloseArea())
	EndIf
	At765Alias(oGSTmpTb:cAliasTmp)
	( At765Alias() )->(DbGoTop())
	oBrw:SetAlias((At765Alias()))

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765aStru
Definicao dos campos uso do browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765aStru()
	Local nX       := 0
    Local aRet     := {}
	Local aUSRCpos := {}
	Local aFields  := { "ABB_FILIAL", "ABB_CODTEC", "AA1_CODTEC", "AA1_NOMTEC", "T40_DATMAR", ;
						"T40_TIPOMA", "T40_HPREVI", "T40_NUMMAR", "ABB_DTINI",  "ABB_DTFIM",  ;
						"TDV_DTREF",  "ABB_LOCAL",  "ABS_DESCRI", "T40_CODREL", "AA1_CDFUNC", ;
						"T40_CODREP", "T40_LONGIT", "T40_LATITU", "T40_GEOFEN", "T40_AGEINT", ;
						"T40_CIC",    "T40_VALCON", "ABS_REGRA",  "TFF_REGRA",  "ABS_LATITU", ;
						"ABS_LONGIT", "ABS_METROS", "T40_DISTMT" }

	For nX := 1 To Len(aFields)
		aSpec := At765Field(aFields[nX])
		If Len(aSpec) > 0
			Aadd(aRet, aSpec)
		EndIf
	Next nX

	// Ponto de entrada para retornar array (Campo, Tipo, Tamanho, Decimais) dos campos a serem usados no Browse.
	If ExistBlock("TC765STR")
		aUSRCpos := aClone(ExecBlock("TC765STR", .F., .F., {aRet}))
		If Valtype(aUSRCpos) == "A" .And. Len(aUSRCpos) > 0
			For nX := 1 to Len(aUSRCpos)
				aAdd(aRet, {aUSRCpos[nX][1], aUSRCpos[nX][2], aUSRCpos[nX][3], aUSRCpos[nX][4]})
			Next nX
		EndIf
	EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765Field
Definicao das colunas uso do browse
@since  23/08/2022
@author flavio.vicco
@return Array Campo, Tipo, Tamanho, Decimais
/*/
//------------------------------------------------------------------------------
Function At765Field(cField)

	Local aRet   := {}
	Local aField := {}

	aRet := FwTamSx3(cField) // Retorna tamanho e tipo do campo (se o campo existir)
	If Len(aRet) > 0
		aField := {cField, aRet[3], aRet[1], aRet[2]}
		// Altera tipo/tamanho do campo de Hora Marcada
		If cField == "T40_NUMMAR"
			aField[2] := "C"
			aField[3] :=  8
		Endif
	ElseIf cField == "T40_DISTMT"
		aField := {cField, "N", 12, 2}
	Endif

Return aField

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT765aCols
Definicao das colunas uso do browse
@since	23/08/2022
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function AT765aCols(aStru)

	Local nY       := 0
	Local nTam     := 0
	Local aColumns := {}
	Local cAlias   := At765Alias()
	Local cFields  := ""
	Local cField   := ""
	Local cMasc    := ""
	Local cTitle   := ""

	cFields := "T40_AGEINT|ABB_CODTEC|ABS_LATITU|ABS_LONGIT|TFF_REGRA|T40_LONGIT|T40_LATITU|T40_GEOFEN" //Campos que não devem ser exibidos no Browse

	For nY := 1 To Len(aStru)
		cField := aStru[nY][1]
		If !cField $ cFields
			cMasc  := X3Picture(cField)
			cTitle := RetTitle(cField)
			If cField $ "T40_NUMMAR|T40_HPREVI"
				cMasc := "99:99"
			ElseIf cField $ "T40_DISTMT"
				cTitle := STR0028 //"Distância (m)"
				cMasc := "@E 999,999,999.99"
			ElseIf cField $ "ABS_METROS"
				cMasc := "@E 999,999,999.99"
			EndIf
			AAdd(aColumns,FWBrwColumn():New())
			nTam := Len(aColumns)
			If aStru[nY][2] == 'C'
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
/*/{Protheus.doc} ChkQtdAtd
Quantidades de batida no dia
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function ChkQtdAtd(cAtend,dDtini,cFilialABB)

Local aABB          := {}
Local cAliasABB     := GetnextAlias()
Local cQry          := ""
Local nNumQuery     := 1
Local oQuery        := Nil

cQry := " SELECT ABB_HRINI, ABB_HRFIM, ABB_MARENT, ABB_MARSAI "
cQry += " FROM ? ABB "
cQry += " INNER JOIN ? TDV ON TDV.TDV_FILIAL= ABB.ABB_FILIAL "
cQry += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
cQry += " AND TDV.TDV_DTREF = ? "
cQry += " AND TDV.D_E_L_E_T_ = ' ' "
cQry += " WHERE ABB.ABB_FILIAL = ? "
cQry += " AND ABB_CODTEC = ? "
cQry += " AND ABB.D_E_L_E_T_ = ' ' "

//Prepara a query:
oQuery := FwPreparedStatement():New(cQry)
oQuery:SetNumeric( nNumQuery++, RetSQLName("ABB") )
oQuery:SetNumeric( nNumQuery++, RetSQLName("TDV") )
oQuery:SetString( nNumQuery++, dDtini )
oQuery:SetString( nNumQuery++, cFilialABB )
oQuery:SetString( nNumQuery++, cAtend )
cQry := oQuery:GetFixQuery()
MPSysOpenQuery(cQry, cAliasABB)
dbSelectArea(cAliasABB)

While (cAliasABB)->(!Eof())
	AADD(aABB,{(cAliasABB)->ABB_HRINI,(cAliasABB)->ABB_MARENT})
	AADD(aABB,{(cAliasABB)->ABB_HRFIM,(cAliasABB)->ABB_MARSAI})
	(cAliasABB)->(DbSkip())
Enddo

(cAliasABB)->(DbCloseArea())
oQuery:Destroy()
FwFreeObj(oQuery)

//Verifica se é Intrajornada (DSERSGS-19423):
If Len(aABB) == 4
	//Se data final do primeiro periodo for igual a inicial do segundo (Não tem intervalo):
	If aABB[2,1] == aABB[3,1]
		ADel( aABB, 2 )
		ADel( aABB, 2 )
		ASize( aABB, 2 )
	EndIf
EndIf

Return aABB

//------------------------------------------------------------------------------
/*/{Protheus.doc} Chkmarc
@description Define cor da Legenda no grid
@param  nOption, integer, 1 - Tipo de marcação, 2 - Cerca eletrônica
@since  28/09/2022
@author Vitor kwon
@return Nil
/*/
//------------------------------------------------------------------------------

Static Function Chkmarc(nOption)

Local cCor := ""

If nOption == 1
	IF EMPTY(ABB_DTINI)
		cCor := "BR_PRETO"    //SEM AGENDA
	ElseIf Substring(T40_NUMMAR,6,1) == "A"
		cCor := "BR_AMARELO"  //ATRASO
	ElseIf Substring(T40_NUMMAR,6,1) == "B"
		cCor := "BR_AZUL"     //HORA EXRA
	ElseIf Substring(T40_NUMMAR,6,1) == "C"
		cCor := "BR_VERDE"    //ENTRADA ANTECIPADA
	ElseIf Substring(T40_NUMMAR,6,1) == "D"
		cCor := "BR_VERMELHO" //SAIDA ANTECIPADA
	ElseIf Substring(T40_NUMMAR,6,1) == "O"
		cCor := "BR_BRANCO" //OK
	Endif
Else
	IF EMPTY(ABS_METROS)
		cCor := "BR_PRETO"
	ElseIf Substring(T40_NUMMAR,7,1) == "I"
		cCor := "BR_VERDE"    // Dentro da cerca eletrônica
	ElseIf Substring(T40_NUMMAR,7,1) == "O"
		cCor := "BR_VERMELHO" // Fora da cerca eletrônica
	Endif
EndIf

Return cCor

//------------------------------------------------------------------------------
/*/{Protheus.doc} ConsLeg
@description Define cor da Legenda que sera apresentada ao usuario
@param  nOption, integer, 1 - Tipo de marcação, 2 - Cerca eletrônica
@since  8/09/2022
@author Vitor kwon
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function ConsLeg(nOption)
Local oLegend := FWLegend():New()

If nOption == 1
	oLegend:Add("","BR_AZUL"    ,STR0015) //"Hora Extra"
	oLegend:Add("","BR_AMARELO" ,STR0016) //"Atraso"
	oLegend:Add("","BR_VERDE"   ,STR0020) //"Entrada Antecipada"
	oLegend:Add("","BR_VERMELHO",STR0021) //"Saida Antecipada"
	oLegend:Add("","BR_PRETO"   ,STR0022) //"Sem Agenda"
	oLegend:Add("","BR_BRANCO"  ,STR0033) //"Marcação OK"
Else
	oLegend:Add("","BR_VERDE"   ,STR0029) //"Dentro da cerca eletrônica"
	oLegend:Add("","BR_VERMELHO",STR0030) //"Fora da cerca eletrônica"	
	oLegend:Add("","BR_PRETO"   ,STR0031) //"Sem Cerca eletrônica"
EndIf
oLegend:Activate()
oLegend:View()
oLegend:DeActivate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECXHorMin
Recebe o numero de segundos e transforma em hora
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function TECXHorMin(xValue)

local nHoraDec  := 0
Local nMinuDec  := 0
Local cTimeEnt := ""

nHoraDec := StrZero(Int(xValue/3600),2)
nMinuDec := cValtoChar( ( (xValue/3600) - Int(xValue/3600) ) * 60)
cTimeEnt := nHoraDec + ":" + StrZero(Val(Substring(nMinuDec,1,2)),2)

Return cTimeEnt

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECXMinHor
Recebe a hora e transforma em segundos
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function TECXMinHor(xValue)

local nHoraMarc := 0

nHoraMarc := (( Val(SubStr(xValue,4,2))/60) + (Val(SubStr(xValue,1,2)))) * 3600	

Return nHoraMarc

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECMinSeg
Recebe minutos e transforma em segundos
@since		28/09/2022
@author Vitor kwon
@return 	Nil
/*/
//------------------------------------------------------------------------------

Function TECMinSeg(xValue)

local nSegundos := 0

nSegundos := (xValue * 60)	

Return nSegundos

//------------------------------------------------------------------------------
/*/{Protheus.doc} At765LimTol
Retorna Calculo do tempo de tolerancia atrasos/hora extra (em minutos)
@since  02/09/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At765LimTol(cLimTol, nTipo)
Local nRet := 0

// Excuta funcao do SIGAPON PONA060/PONXFUN
nRet := fTolerancia(cLimTol,nTipo) * 100
nRet := TECXMinHor(Transform(nRet,"99:99"))

Return nRet
