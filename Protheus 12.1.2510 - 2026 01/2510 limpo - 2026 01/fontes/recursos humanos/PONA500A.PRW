#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONA500A.CH"

/*/{Protheus.doc} PONA500A
Rotina para buscar os dados do Dashboard Banco de Horas e enviar e-mail.
@author Marco Nakazawa
@since 17/06/2025
@Type Function
/*/
Function PONA500A(lDashBoard, oJparams)
Local oBuscaAvnd	:= JsonObject():New()
Local aFiliais		:= {}
Local aGestores		:= {}
Local aDeptos		:= {}
Local aCc			:= {}
Local aDados		:= {}
Local aErros		:= {}
Local aSemEmail		:= {}
Local aSaldo		:= {}
Local aHrsPosit		:= {}
Local aHrsNegat		:= {}
Local aHrsVencer	:= {}
Local aHrsVencds	:= {}
Local aResp			:= {}
Local aAbasExcel	:= Array(5)
Local aExcelBck		:= {}
Local aColsInd		:= {}
Local cJoiFilSPI	:= "%" + FWJoinFilial("SPI", "SRA") + "%"
Local cJoiFilSQB	:= "%" + FWJoinFilial("SQB", "SRA") + "%"
Local cJoiFilCTT	:= "%" + FWJoinFilial("CTT", "SRA") + "%"
Local cJoiFilSRJ	:= "%" + FWJoinFilial("SRJ", "SRA") + "%"
Local cJoiFilSP9	:= "%" + FWJoinFilial("SP9", "SPI") + "%"
Local cNomeSGDB 	:= Upper(TCGetDB())
Local cAlias		:= GetNextAlias()
Local cDataDe		:= ""
Local cDataAte		:= ""
Local cWhere		:= ""
Local cWhereFil		:= ""
Local cWhereDpto	:= ""
Local cWhereCc		:= ""
Local cWhereVnc		:= ""
Local cQryGestor	:= ""
Local cLastFil		:= ""
Local cLastMat		:= ""
Local cLastEmail	:= ""
Local cEmpNome		:= ""
Local cHora			:= ""
Local cBuscEmp		:= ""
Local cDtVenc		:= ""
Local cDestinat		:= ""
Local cAcessoSRA	:= fSFiltrSQL(ChkRH("PONA500", "SRA", "1"))
Local cAcessoSQB	:= fSFiltrSQL(ChkRH("PONA500", "SQB", "1"))
Local cAcessoCTT	:= fSFiltrSQL(ChkRH("PONA500", "CTT", "1"))
Local cPerg			:= "PNA500A"
Local cDiaIni		:= ""
Local cDiaFim		:= ""
Local dDataAtual	:= Date()
Local dDtFimVld		:= sToD(" / / ")
Local lExistPerg 	:= fExistPerg(cPerg)
Local lTemDtVnc		:= .F.
Local lEof			:= .T.
Local lBuscEmp		:= .F.
Local lSchedule		:= IsBlind()
Local nI			:= 0
Local nMeses		:= 0
Local nDiaIni		:= 0
Local nDiaFim		:= 0
Local oFilTemp		:= Nil

Default lDashBoard	:= .F.
Default oJparams	:= Nil

// Verifica se o campo PI_DTVENC existe
lTemDtVnc := totvs.protheus.rh.sigapon.dashbh.fChkDtVenc()

// Se tiver o campo PI_DTVENC adiciona o campo PI_MESESBH na Query
If lTemDtVnc		
	cDtVenc := "%SPI.PI_DTVENC,%"

	If Alltrim(cNomeSGDB) == "ORACLE" .Or. Alltrim(cNomeSGDB) == "POSTGRES"
		cWhereVnc := "% AND (SPI.PI_MESESBH = 0 OR SPI.PI_MESESBH IS NULL) %"
	Else
		cWhereVnc := "% AND (SPI.PI_MESESBH = 0 OR SPI.PI_MESESBH = ' ') %"
	EndIf
EndIf

If lDashBoard .And. oJparams <> Nil
	cDataDe		:= StrTran(oJparams["startDate"],"-","")
	cDataAte	:= StrTran(oJparams["endDate"],"-","")
	aFiliais	:= oJparams["branch"]
	aDeptos		:= oJparams["departament"]
	aCc			:= oJparams["costCenter"]
	aGestores	:= oJparams["manager"]
	oBuscaAvnd	:= oJparams["advancededSearch"]

	// Montagem do Where das filais	e controle de acesso da SRA
	cWhere := cWhereFil := totvs.protheus.rh.sigapon.dashbh.fFilQuery(aFiliais, @oFilTemp)

	If (!Empty(cWhere), cWhere := " AND " + cWhere, Nil)
		
	// Montagem do Where dos departamentos
	cWhereDpto := totvs.protheus.rh.sigapon.dashbh.fDptoQuery(aDeptos)
	If (!Empty(cWhereDpto), cWhere += " AND " + cWhereDpto, Nil)

	// Montagem do Where dos Centros de Custos
	cWhereCc := totvs.protheus.rh.sigapon.dashbh.fCcQuery(aCc)
	If (!Empty(cWhereCc), cWhere += " AND " + cWhereCc, Nil)

	// Montagem da query da busca avançada
	If oBuscaAvnd:HasProperty("company")
		cQryBuscAd := totvs.protheus.rh.sigapon.dashbh.fQryBuscAd(oBuscaAvnd)

		If !Empty(cQryBuscAd)
			cWhere += cQryBuscAd
		EndIf

		If oBuscaAvnd:HasProperty("company") .And. !Empty(oBuscaAvnd["company"])
			lBuscEmp := .T.
			cBuscEmp := Upper(AllTrim(oBuscaAvnd["company"]))
		EndIf
	EndIf

	If (Empty(cWhere), cWhere := "%" + cWhere + "%", "%%")

	// Montagem da query dos gestores
	cQryGestor := totvs.protheus.rh.sigapon.dashbh.fGstQuery(aGestores, cWhereFil)
	cQryGestor := StrTran(cQryGestor, "LEFT", "INNER")
Else
	If lExistPerg .And. lSchedule
		MakeSqlExpr(cPerg)
		
		// Montagem do filtro das filiais
		If (!Empty(MV_PAR01), cWhere := " AND " + StrTran(MV_PAR01, "RA_", "SRA.RA_"), Nil)
		If (!Empty(cAcessoSRA), cWhere += " AND (" + cAcessoSRA + ")", Nil)
		
		// Montagem do filtro de Departamentos
		If (!Empty(MV_PAR02), cWhere += " AND " + StrTran(MV_PAR02, "RA_", "SRA.RA_"), Nil)
		If (!Empty(cAcessoSQB), cWhere += " AND (" + cAcessoSQB + ")", NIl)

		// Montagem do filtro de centros de custo
		If (!Empty(MV_PAR03), cWhere += " AND " + StrTran(MV_PAR03, "RA_", "SRA.RA_"), Nil)
		If (!Empty(cAcessoCTT), cWhere += " AND (" + cAcessoCTT + ")", Nil)

		// Montagem da query de Gestores
		If !Empty(MV_PAR04)
			cQryGestor := totvs.protheus.rh.sigapon.dashbh.fGstQuery({MV_PAR04},"")
		Else
			cQryGestor := totvs.protheus.rh.sigapon.dashbh.fGstQuery({""},"")
		EndIf
		cQryGestor := StrTran(cQryGestor, "LEFT", "INNER")

		// Montagem do período
		If !Empty(MV_PAR05) .And. Len(AllTrim(MV_PAR05)) == 4
			cDiaIni := SubStr(MV_PAR05, 1, 2)
			cDiaFim := SubStr(MV_PAR05, 3, 2)

			nDiaIni := Val(cDiaIni)
			nDiaFim := Val(cDiaFim)

			lValidDia := If (nDiaIni > 0 .And. nDiaIni <= 31 .And. nDiaFim > 0 .And. nDiaFim <= 31, .T., .F.)

			If (MV_PAR06 > 1, nMeses := MV_PAR06, nMeses := 1)

			If lValidDia
				If nMeses > 1
					cDataDe := AnoMes(MonthSub(dDataAtual , nMeses)) + cDiaIni
					If (Empty(sToD(AnoMes(dDataAtual) + cDiaFim)), dDtFimVld := LastDate(dDataAtual), dDtFimVld := sToD(AnoMes(dDataAtual) + cDiaFim))
				Else
					cDataDe := AnoMes(dDataAtual) + cDiaIni
					If cDiaIni > cDiaFim
						If (Empty(sToD(AnoMes(MonthSum(dDataAtual , 1)) + cDiaFim)), dDtFimVld := LastDate(dDataAtual), dDtFimVld := sToD(AnoMes(MonthSum(dDataAtual , 1)) + cDiaFim))
					Else
						If (Empty(sToD(AnoMes(dDataAtual) + cDiaFim)), dDtFimVld := LastDate(dDataAtual), dDtFimVld := sToD(AnoMes(dDataAtual) + cDiaFim))
					EndIf
				EndIf

				cDataAte := dToS(Min(dDtFimVld, dDataAtual))
			Else
				cDataDe		:= ""
				cDataAte	:= dToS(dDataAtual)
			EndIf
		Else
			cDataDe		:= ""
			cDataAte	:= dToS(dDataAtual)
		EndIf
	ElseIf !lSchedule
		Help(,,STR0019,,STR0020,1,0) // "Erro na execução da rotina." "A rotina PONA500A só deve ser executada pelo Scheduler."
		Return .F.
	ElseIf !lExistPerg
		Conout(AnsiToOEM(STR0021)) // "Erro de dicionario. O grupo de perguntas PNA500A nao esta criado. Execute o UPPDISTR com o pacote de dicionario da expedicao continua para a criacao."
		Return .F.
	EndIf

EndIf

If (!Empty(cWhere), cWhere := "%" + cWhere + "%", "%%")	

BeginSql alias cAlias
	SELECT 
		SRA.RA_FILIAL,
		SRA.RA_MAT,
		SRA.RA_NOME,
		SRJ.RJ_DESC,
		SQB.QB_FILIAL,
		SQB.QB_DEPTO,
		SQB.QB_DESCRIC,
		CTT.CTT_FILIAL,
		CTT.CTT_CUSTO,
		CTT.CTT_DESC01,
		SRAGEST.GESTOR,
		SRAGEST.FILGESTOR,
		SRAGEST.MATGESTOR,
		SRAGEST.EMAILGESTOR,
		%exp:cDtVenc%
		SPI.PI_DATA,
		SPI.PI_QUANT,
		SP9.P9_TIPOCOD
	FROM %table:SRA% SRA
	%exp:cQryGestor%
	INNER JOIN %table:SPI% SPI ON %exp:cJoiFilSPI% AND SPI.PI_MAT = SRA.RA_MAT AND SPI.%notDel%
	INNER JOIN %table:SQB% SQB ON %exp:cJoiFilSQB% AND SQB.QB_DEPTO = SRA.RA_DEPTO AND SQB.%notDel%
	INNER JOIN %table:CTT% CTT ON %exp:cJoiFilCTT% AND CTT.CTT_CUSTO = SRA.RA_CC AND CTT.%notDel%
	INNER JOIN %table:SRJ% SRJ ON %exp:cJoiFilSRJ% AND SRJ.RJ_FUNCAO = SRA.RA_CODFUNC AND SRJ.%notDel%
	INNER JOIN %table:SP9% SP9 ON %exp:cJoiFilSP9% AND SP9.P9_CODIGO = SPI.PI_PD AND SP9.%notDel%
	WHERE SRA.%notDel%
		AND SPI.PI_STATUS = ' '
		%exp:cWhere%
	ORDER BY SRAGEST.FILGESTOR, SRAGEST.MATGESTOR, SRA.RA_FILIAL, SRA.RA_MAT
EndSql

While lEof
	lEof := !(cAlias)->(Eof())

	If cLastFil <> (cAlias)->RA_FILIAL
		cEmpNome := AllTrim(FWCompanyName(cEmpAnt,(cAlias)->RA_FILIAL))
	EndIf

	If lBuscEmp
		If !(cBuscEmp $ Upper(cEmpNome))
			(cAlias)->(dbSkip())
			Loop
		EndIf
	EndIf

	If !lEof
		If !Empty(cLastEmail)
			aAdd(aDados, {cLastFil, cLastMat, cLastEmail, aSaldo, aHrsPosit, aHrsNegat, aHrsVencer, aHrsVencds})
		EndIf

		Loop
	EndIf

	If Empty((cAlias)->EMAILGESTOR)
		If aScan(aSemEmail, {|x| x[1] == (cAlias)->FILGESTOR .And. x[2] == (cAlias)->MATGESTOR}) == 0
			aAdd(aSemEmail, {(cAlias)->FILGESTOR, (cAlias)->MATGESTOR})
		EndIf
		
		(cAlias)->(dbSkip())
		Loop
	EndIf

	If Empty(cLastFil) .And. Empty(cLastMat)
		cLastFil	:= (cAlias)->FILGESTOR
		cLastMat	:= (cAlias)->MATGESTOR
		cLastEmail	:= (cAlias)->EMAILGESTOR
		cEmpNome	:= AllTrim(FWCompanyName(cEmpAnt,(cAlias)->RA_FILIAL))
	EndIf

	If (cLastFil <> (cAlias)->FILGESTOR .Or. cLastMat <> (cAlias)->MATGESTOR)
		cEmpNome := AllTrim(FWCompanyName(cEmpAnt,(cAlias)->RA_FILIAL))

		aAdd(aDados, {cLastFil, cLastMat, cLastEmail, aSaldo, aHrsPosit, aHrsNegat, aHrsVencer, aHrsVencds})

		cLastFil	:= (cAlias)->FILGESTOR
		cLastMat	:= (cAlias)->MATGESTOR
		cLastEmail	:= (cAlias)->EMAILGESTOR

		aSaldo		:= {}
		aHrsPosit	:= {}
		aHrsNegat	:= {}
		aHrsVencds	:= {}
		aHrsVencer	:= {}
	EndIf

	If Empty(cDataDe) .Or. ((cAlias)->PI_DATA >= cDataDe .And. (cAlias)->PI_DATA <= cDataAte)
		aAdd(aSaldo, {cEmpNome,(cAlias)->RA_FILIAL, (cAlias)->RA_NOME, (cAlias)->RA_MAT, (cAlias)->RJ_DESC, AllTrim((cAlias)->CTT_DESC01) + " (" + AllTrim((cAlias)->CTT_FILIAL) + " - " + AllTrim((cAlias)->CTT_CUSTO) + ")", (cAlias)->GESTOR, AllTrim((cAlias)->QB_DESCRIC) + " (" + AllTrim((cAlias)->QB_FILIAL) + " - " + AllTrim((cAlias)->QB_DEPTO) + ")", totvs.protheus.rh.sigapon.dashbh.fNumToHr(If((cAlias)->P9_TIPOCOD $ "1*3", (cAlias)->PI_QUANT, (cAlias)->PI_QUANT * -1)), If(lTemDtVnc, dToC(sToD((cAlias)->PI_DTVENC)), "")})

		If (cAlias)->P9_TIPOCOD $ "1*3"
			aAdd(aHrsPosit, {cEmpNome,(cAlias)->RA_FILIAL, (cAlias)->RA_NOME, (cAlias)->RA_MAT, (cAlias)->RJ_DESC, AllTrim((cAlias)->CTT_DESC01) + " (" + AllTrim((cAlias)->CTT_FILIAL) + " - " + AllTrim((cAlias)->CTT_CUSTO) + ")", (cAlias)->GESTOR, AllTrim((cAlias)->QB_DESCRIC) + " (" + AllTrim((cAlias)->QB_FILIAL) + " - " + AllTrim((cAlias)->QB_DEPTO) + ")", totvs.protheus.rh.sigapon.dashbh.fNumToHr(If((cAlias)->P9_TIPOCOD $ "1*3", (cAlias)->PI_QUANT, (cAlias)->PI_QUANT * -1)), If(lTemDtVnc, dToC(sToD((cAlias)->PI_DTVENC)), "")})
		EndIf

		If (cAlias)->P9_TIPOCOD $ "2*4"
			aAdd(aHrsNegat, {cEmpNome,(cAlias)->RA_FILIAL, (cAlias)->RA_NOME, (cAlias)->RA_MAT, (cAlias)->RJ_DESC, AllTrim((cAlias)->CTT_DESC01) + " (" + AllTrim((cAlias)->CTT_FILIAL) + " - " + AllTrim((cAlias)->CTT_CUSTO) + ")", (cAlias)->GESTOR, AllTrim((cAlias)->QB_DESCRIC) + " (" + AllTrim((cAlias)->QB_FILIAL) + " - " + AllTrim((cAlias)->QB_DEPTO) + ")", totvs.protheus.rh.sigapon.dashbh.fNumToHr(If((cAlias)->P9_TIPOCOD $ "1*3", (cAlias)->PI_QUANT, (cAlias)->PI_QUANT * -1)), If(lTemDtVnc, dToC(sToD((cAlias)->PI_DTVENC)), "")})
		EndIf
	EndIf
	
	If lTemDtVnc
		If (cAlias)->PI_DTVENC <= cDataAte
			aAdd(aHrsVencds, {cEmpNome,(cAlias)->RA_FILIAL, (cAlias)->RA_NOME, (cAlias)->RA_MAT, (cAlias)->RJ_DESC, AllTrim((cAlias)->CTT_DESC01) + " (" + AllTrim((cAlias)->CTT_FILIAL) + " - " + AllTrim((cAlias)->CTT_CUSTO) + ")", (cAlias)->GESTOR, AllTrim((cAlias)->QB_DESCRIC) + " (" + AllTrim((cAlias)->QB_FILIAL) + " - " + AllTrim((cAlias)->QB_DEPTO) + ")", totvs.protheus.rh.sigapon.dashbh.fNumToHr(If((cAlias)->P9_TIPOCOD $ "1*3", (cAlias)->PI_QUANT, (cAlias)->PI_QUANT * -1)), If(lTemDtVnc, dToC(sToD((cAlias)->PI_DTVENC)), "")})
		Else
			aAdd(aHrsVencer, {cEmpNome,(cAlias)->RA_FILIAL, (cAlias)->RA_NOME, (cAlias)->RA_MAT, (cAlias)->RJ_DESC, AllTrim((cAlias)->CTT_DESC01) + " (" + AllTrim((cAlias)->CTT_FILIAL) + " - " + AllTrim((cAlias)->CTT_CUSTO) + ")", (cAlias)->GESTOR, AllTrim((cAlias)->QB_DESCRIC) + " (" + AllTrim((cAlias)->QB_FILIAL) + " - " + AllTrim((cAlias)->QB_DEPTO) + ")", totvs.protheus.rh.sigapon.dashbh.fNumToHr(If((cAlias)->P9_TIPOCOD $ "1*3", (cAlias)->PI_QUANT, (cAlias)->PI_QUANT * -1)), If(lTemDtVnc, dToC(sToD((cAlias)->PI_DTVENC)), "")})
		EndIf
	EndIf

	(cAlias)->(dbSkip())
Enddo

(cAlias)->(dbCloseArea())

// Configuração das abas do Excel
aAbasExcel[1] := {{STR0001, STR0002}} // "Saldo" / "Saldo Banco de Horas"
aAbasExcel[2] := {{STR0003, STR0003}} // "Horas Positivas" / "Horas Positivas"
aAbasExcel[3] := {{STR0004, STR0004}} // "Horas Negativas" / "Horas Negativas"
aAbasExcel[4] := {{STR0005, STR0005}} // "Horas à Vencer" / "Horas à Vencer"
aAbasExcel[5] := {{STR0006, STR0006}} // "Horas Vencidas" / "Horas Vencidas"

// Configuração das colunas do Excel
aAdd(aColsInd, {STR0007, 14}) // "Empresa"
aAdd(aColsInd, {STR0008, 12}) // "Filial"
aAdd(aColsInd, {STR0009, 35}) // "Nome"
aAdd(aColsInd, {STR0010, 15}) // "Matrícula"
aAdd(aColsInd, {STR0011, 25}) // "Cargo"
aAdd(aColsInd, {STR0012, 45}) // "Centro de Custo"
aAdd(aColsInd, {STR0013, 35}) // "Gestor"
aAdd(aColsInd, {STR0014, 45}) // "Departamento"
aAdd(aColsInd, {STR0015, 11}) // "Horas"
aAdd(aColsInd, {STR0016, 17}) // "Vencimento"

aAdd(aAbasExcel[1], aColsInd)
aAdd(aAbasExcel[2], aColsInd)
aAdd(aAbasExcel[3], aColsInd)
aAdd(aAbasExcel[4], aColsInd)
aAdd(aAbasExcel[5], aColsInd)

aExcelBck := aClone(aAbasExcel)

cHora := Time()
cHora := SubStr(cHora, 1, 2) + ":" + SubStr(cHora, 4, 2)

cMsg := STR0017 + DtoC(Date()) + STR0018 + cHora // "Informações do Dashboard Banco de Horas gerado em "/ " às "

// Gera os erros no console.
If Empty(aDados) .And. Empty(aSemEmail) .And. lDashBoard
	Return {.F., {STR0027}, .T.} // "Nao existem dados para notificar o gestor. Verifique os campos utilizados na busca avancada."
ElseIf Empty(aDados) .And. Empty(aSemEmail) .And. !lDashBoard
	Conout(STR0023) // "Dashboard Banco de Horas"
	Conout(STR0028) // "Nao existem dados para notificar o gestor."
	Return .T.
EndIf

If !Empty(aSemEmail)
	If (!lDashBoard, Conout(STR0023), Nil) // "Dashboard Banco de Horas"

	For nI := 1 To Len(aSemEmail)
		If !lDashBoard
			Conout(STR0022 + AllTrim(aSemEmail[nI, 1]) + STR0025 + aSemEmail[nI, 2] + STR0026) // "E-mail do gestor da filial X e matricula X nao foi encontrado."
		Else
			If (nI == 1, aAdd(aErros, STR0023), Nil)
			aAdd(aErros, STR0022 + AllTrim(aSemEmail[nI, 1]) + STR0025 + aSemEmail[nI, 2] + STR0026) // "E-mail do gestor da filial X e matricula X nao foi encontrado."
		EndIf
	Next
EndIf

For nI := 1 To Len(aDados)
	aAdd(aAbasExcel[1], aDados[nI, 4])
	aAdd(aAbasExcel[2], aDados[nI, 5])
	aAdd(aAbasExcel[3], aDados[nI, 6])
	aAdd(aAbasExcel[4], aDados[nI, 7])
	aAdd(aAbasExcel[5], aDados[nI, 8])

	aResp := totvs.protheus.rh.sigapon.dashbh.fExcelBh(aAbasExcel, .F.)

	aAbasExcel := aClone(aExcelBck)

	If (!lDashBoard .And. !Empty(AllTrim(MV_PAR07)), cDestinat := AllTrim(MV_PAR07) + ";" + aDados[nI, 3], cDestinat := aDados[nI, 3])

	If !gpeMail(STR0023, cMsg, cDestinat, {aResp[1,3]}, .T.) // "Dashboard Banco de Horas"
		If lDashBoard 
			fErase(aResp[1,3])
			fErase(StrTran(aResp[1,3],"xlsx","rel"))

			Return {.F., {STR0029}, .T.} // "Falha no envio do e-mail. Verifique as configuracoes do sistema para o envio de e-mails."
		Else
			Conout(STR0023) // "Dashboard Banco de Horas"
			Conout(STR0029) // "Falha no envio do e-mail. Verifique as configuracoes do sistema para o envio de e-mails."
			
			fErase(aResp[1,3])
			fErase(StrTran(aResp[1,3],"xlsx","rel"))

			Return .T.
		EndIf
	EndIf
Next

If lDashBoard
	If (!Empty(aErros), aResp := {.F., aErros, .F.}, aResp := {.T., {}, .F.})
EndIf

Return If (lDashBoard, aResp, .T.)

/*/{Protheus.doc} fExistPerg
//Função para verificar se existe o grupo de perguntas
@author marco.nakazawa
@since 17/06/2025
@version 1.0
@return NIL
@type static function
/*/
Static Function fExistPerg(cPergunte)
Local lRet	:= .F.
Local oSX1	:= FWSX1Util():New()

oSX1:AddGroup(cPergunte)
oSX1:SearchGroup()

If !Empty(oSX1:aGrupo[1,2])
	lRet:= .T.
EndIf

FreeObj(oSX1)
Return lRet

/*/{Protheus.doc} SchedDef
//Função para execução da rotina pelo Scheduler
@author marco.nakazawa
@since 17/06/2025
@version 1.0
@return NIL
@type function
/*/
Static Function SchedDef()
Local aParam		:= {}

aParam := {	"P"			,;	// Tipo: "P" - para Processo, "R" -  para Relatórios
			"PNA500A"	,;	// Nome do Pergunte
			""			,;	// Alias (para Relatório)
			{}			,;	// Array de ordem (para Relatório)
			""			,;	// Título (para Relatório)
			""			}	// Nome do relatório (parâmetro 1 do método new da classe TReport)
Return aParam
