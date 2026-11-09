#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP01.CH"

STATIC oObjQry     := NIL
STATIC oObjDelay   := NIL
STATIC cEmpVac     := ""

/*/{Protheus.doc} fGetCountAbsenses
- Checa e elimina registros em duplicidade que podem ser gerados quando o periodo está compreendido numa interseccao de transferencias

@author:	Marcelo Silveira
@since:		06/01/2022
@param:		cBranchVld - Filial do gestor que está pesquisando dos dados
			cMatSRA - Matricula do gestor que está pesquisando dos dados
			aCoordTeam - Array com os dados do time
			aDataFunc - Array para adicionar os dados de ferias dos funcionarios
/*/
Function fGetCountAbsenses(cBranchVld, cMatSRA, aCoordTeam, aDataFunc)

Local nX			:= 0
Local cEmpTeam 		:= ""
Local cFilTeam 		:= ""
Local cMatTeam 		:= ""
Local cEmpStruct 	:= ""
Local cFilStruct 	:= ""
Local cMatStruct 	:= ""

DEFAULT cBranchVld 	:= ""
DEFAULT cMatSRA 	:= ""
DEFAULT aCoordTeam 	:= ""
DEFAULT aDataFunc	:= {0,0,0,0,0}

For nX := 1 To Len(aCoordTeam[1]:ListOfEmployee)

	cEmpStruct := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp
	cFilStruct := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial
	cMatStruct := aCoordTeam[1]:ListOfEmployee[nX]:Registration

	// - Despreza caso o coordinatorId esteja incluso na estrutura.
	If !(cEmpStruct+cFilStruct+cMatStruct == cEmpAnt+cBranchVld+cMatSRA)

		cEmpTeam := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp
		cFilTeam := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial
		cMatTeam := aCoordTeam[1]:ListOfEmployee[nX]:Registration

		fProcDataSRF(cMatTeam, cFilTeam, cEmpTeam, aDataFunc)
	EndIf

Next nX

Return()


/*/{Protheus.doc} fProcDataSRF
- Realiza a classificacao de ferias da equipe definindo o status: em férias, vencidas, a vencer, em dobro e risco de dobro

@author:	Marcelo Silveira
@since:		06/01/2022
@param:		cMatTeam - Filial do funcionario para pesquisa dos dados
			cFilTeam - Matricula do funcionario para pesquisa dos dados
			cEmpTeam - Empresa do funcionario para pesquisa dos dados
			aData - Array para adicionar os dados de ferias dos funcionarios
/*/
Function fProcDataSRF(cMatTeam, cFilTeam, cEmpTeam, aData)

Local oObjQry		:= Nil

Local cQryObj       := ""
Local cQuery 		:= ""
Local cCondition	:= ""

Local nX			:= 0
Local nDiasDIR 		:= 0
Local nDiasSRF 		:= 0
Local nDiasSRH		:= 0
Local nSubDays		:= 60

Local nExpired		:= 0
Local nToExpire		:= 0
Local nDoubleExpire := 0
Local nDoubleRisk	:= 0
Local nOnVacation	:= 0

Local lExistCalc	:= .F.

Local aPeriod		:= {}

Local dDate   		:= Date()
Local dDtIni		:= cTod("//")
Local dDtFim		:= cTod("//")
Local dDouble		:= cToD("//")
Local dIniVacDate   := cToD("//")
Local dEndVacDate   := cToD("//")
Local dRiskDouble	:= cToD("//")

Default cMatTeam	:= ""
Default cFilTeam	:= FwCodFil()
Default cEmpTeam	:= cEmpAnt
Default aData		:= {0,0,0,0,0}

If !Empty(cMatTeam)

	dDate 	:= If( Empty(dDtRobot), dDate, dDtRobot )
	dDtIni  := DaySub( dDate, 40 )
	dDtFim  := DaySum( dDate, 365 )
	cQuery 	:= GetNextAlias()

	If oObjQry == NIL .Or. cEmpVac <> cEmpTeam
		oObjQry := FWPreparedStatement():New()
		cQryObj := " SELECT RA_FILIAL, RA_MAT, RA_SITFOLH, RF_FILIAL, RF_MAT, RF_DATABAS, RF_DATAFIM, "
		cQryObj += " RF_DFERVAT, RF_DFERAAT, RF_DATAINI, RF_DFEPRO1, RF_DABPRO1, RF_DATINI2, RF_DFEPRO2, "
		cQryObj += " RF_DABPRO2, RF_DATINI3, RF_DFEPRO3, RF_DABPRO3, RF_DIASDIR"
		cQryObj += " FROM " + RetFullName('SRA', cEmpTeam) + " SRA "
		cQryObj += " INNER JOIN " + RetFullName('SRF', cEmpTeam) + " SRF "
		cQryObj += " ON SRA.RA_FILIAL = SRF.RF_FILIAL AND SRA.RA_MAT = SRF.RF_MAT"
		cQryObj += " WHERE SRA.RA_SITFOLH NOT IN ('D','T')"
		cQryObj += " AND SRA.RA_FILIAL = ?"
		cQryObj += " AND SRA.RA_MAT = ?"
		cQryObj += " AND SRF.RF_STATUS = '1'"
		cQryObj += " AND SRA.D_E_L_E_T_ = ' '"
		cQryObj += " AND SRF.D_E_L_E_T_ = ' '"

		cEmpVac := cEmpTeam

		cQryObj := ChangeQuery(cQryObj)
		oObjQry:SetQuery(cQryObj)
	EndIf

	//Define os parametros
	oObjQry:SetString(1,cFilTeam)
	oObjQry:SetString(2,cMatTeam)

	cQryObj := oObjQry:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryObj),cQuery,.T.,.T.)
	oObjQry:doTcSetField(cQuery)

	While (cQuery)->(!Eof())

		//Calcula o periodo concessivo
		aPeriod := PeriodConcessive((cQuery)->RF_DATABAS, (cQuery)->RF_DATAFIM)

		//Obtem dados e valida os dados de ferias do período aquisitivo se houver calculo
		aDataSRH := fGetSRH( (cQuery)->RF_FILIAL, (cQuery)->RF_MAT, STOD((cQuery)->RF_DATABAS), STOD((cQuery)->RF_DATAFIM) )

		If Len(aDataSRH) > 0			
			For nX := 1 to Len(aDataSRH)
				nDiasSRH 	+= ( aDataSRH[nX][2] + aDataSRH[nX][6] )
				dIniVacDate := STOD(aDataSRH[nX][1])
				dEndVacDate	:= STOD(aDataSRH[nX][3])
				
				//Verifica se o funcionario está gozando férias, ou se existe cálculo futuro
				If dIniVacDate <= dDate .And. dEndVacDate >= dDate
					nOnVacation ++
				ElseIf dIniVacDate >= dDtIni .And. dEndVacDate <= dDtFim
					lExistCalc := .T.
				EndIf
			Next nX
		EndIf

		//Verifica as programações existentes quando o funcionario não está gozando férias e nem existe cálculo futuro
		If nOnVacation == 0 .And. !lExistCalc

			If !Empty((cQuery)->RF_DATAINI)
				If Ascan( aDataSRH, {|x| ( x[1] == (cQuery)->RF_DATAINI ) } ) == 0
					If STOD((cQuery)->RF_DATAINI) >= dDate 
						nDiasSRF += (cQuery)->RF_DFEPRO1 + (cQuery)->RF_DABPRO1
					EndIf
				EndIf
			EndIf

			If !Empty((cQuery)->RF_DATINI2)
				If Ascan( aDataSRH, {|x| ( x[1] == (cQuery)->RF_DATINI2 ) } ) == 0
					If STOD((cQuery)->RF_DATINI2) >= dDate
						nDiasSRF += (cQuery)->RF_DFEPRO2 + (cQuery)->RF_DABPRO2
					EndIf
				EndIf
			EndIf

			If !Empty((cQuery)->RF_DATINI3)
				If Ascan( aDataSRH, {|x| ( x[1] == (cQuery)->RF_DATINI3 ) } ) == 0
					If STOD((cQuery)->RF_DATINI3) >= dDate
						nDiasSRF += (cQuery)->RF_DFEPRO3 + (cQuery)->RF_DABPRO3
					EndIf
				EndIf
			EndIf

			nDiasDIR := If( (cQuery)->RF_DFERVAT > 0, (cQuery)->RF_DFERVAT, (cQuery)->RF_DFERAAT )
			nDiasDIR := If( nDiasDIR > 0, nDiasDIR, (cQuery)->RF_DIASDIR ) - (nDiasSRF + nDiasSRH)

			If nDiasDIR > 0 .And. nDiasSRF == 0

				dDouble 	:= aPeriod[2] - nDiasDIR + 1
				dRiskDouble := aPeriod[2] - (nDiasDIR + nSubDays) + 1
				cCondition	:= GetCondition(dDouble, dRiskDouble, (cQuery)->RF_DFERVAT, (cQuery)->RF_DFERAAT, , , , dDate)
				
				//Atribui o valor as variaveis conforme a condição
				If !Empty(cCondition)
					fSetValue(cCondition, @nExpired, @nToExpire, @nDoubleExpire, @nDoubleRisk)
				EndIf
			EndIf

		EndIf

		Exit
	End

	(cQuery)->( DBCloseArea() )

EndIf

//Atualiza o array de referencia com dados do funcionario processado
aData[1] += nExpired		//Ferias vencidas
aData[2] += nToExpire		//Ferias a vencer
aData[3] += nDoubleExpire	//Ferias em dobro
aData[4] += nDoubleRisk		//Ferias com risco de dobro
aData[5] += nOnVacation		//Em Ferias

Return()

/*/{Protheus.doc} fSetValue
- Realiza a atribuição de valores conforme a condição: em férias, vencidas, a vencer, em dobro e risco de dobro

@author:	Marcelo Silveira
@since:		06/01/2022
@param:		cCondition - Condição do item que está sendo validado
			n1Val - Ferias vencidas
			n2Val - Ferias a vencer
			n3Val - Ferias em dobro
			n4Val - Ferias com risco de dobro
/*/
STATIC Function fSetValue( cCondition, n1Val, n2Val, n3Val, n4Val )

DEFAULT cCondition	:= ""
DEFAULT n1Val		:=  0
DEFAULT n2Val		:=  0
DEFAULT n3Val		:=  0
DEFAULT n4Val		:=  0

DO CASE
	CASE cCondition == "expiredVacation"
		n1Val ++
	CASE cCondition == "vacationsToExpire"
		n2Val ++
	CASE cCondition == "doubleExpiredVacation"
		n3Val ++
	CASE cCondition == "doubleRisk"
		n4Val ++
END CASE

Return()

/*/{Protheus.doc} fAbsenseTypes
- Retorna os motivos de afastamento

@author:	Marcelo Silveira
@since:		03/03/2022
@param:		cFilFunc - Filial do funcionario logado
			cEmpFunc - Empresa do funcionario logado
@return:	aData - array com os tipos de afastamentos
/*/
Function fAbsenseTypes( cFilFunc, cEmpFunc )

	Local aData 		:= {}
	Local cQuery		:= ""
	Local cBrchRCM		:= ""
	Local cTableRCM		:= ""
	Local cDelRCM		:= "% RCM.D_E_L_E_T_ = ' ' %"

	DEFAULT cEmpFunc	:= cEmpAnt

	If !Empty( cFilFunc )

		cQuery 		:= GetNextAlias()
		cBrchRCM	:= xFilial("RCM", cFilFunc)
		cTableRCM	:= "%" + RetFullName('RCM', cEmpFunc) + "%"

		//Apresenta os motivos considerando: dias corridos, tipo informado, e diferente de Ferias/Recesso
		BEGINSQL ALIAS cQuery
			SELECT RCM_FILIAL, RCM_TIPO, RCM_DESCRI
			FROM
				%exp:cTableRCM% RCM
			WHERE
				RCM.RCM_FILIAL = %Exp:cBrchRCM% AND
				RCM.RCM_TIPOAF NOT IN ('', '4') AND
				RCM.RCM_TIPODI = '2' AND
				%Exp:cDelRCM%
			ORDER BY 1, 2
		ENDSQL

		While !(cQuery)->(Eof())
			aAdd( aData, { ;
				(cQuery)->RCM_FILIAL, ;
				(cQuery)->RCM_TIPO, ;
				AllTrim((cQuery)->RCM_DESCRI) ;
			})

			(cQuery)->(dbSkip())
		EndDo

		(cQuery)->( DBCloseArea() )
	EndIf

Return( aData )

/*/{Protheus.doc} fGetAbsenses
Carrega os afastamentos de um funcionário a partir de uma filial e matricula
@author:	Marcelo Silveira
@since:		03/03/2022
@param:		cCondition - Condição do item que está sendo validado
			cFilTeam - Filial do funcionario que está sendo pesquisado
			cMatTeam - Matricula do funcionario que está sendo pesquisado
			cEmpTeam - Empresa do funcionario que está sendo pesquisado
			aQryParam - Array com a data inicial e final para filtro dos dados
@return:	aData - array com os dados de afastamentos
/*/
Function fGetAbsenses(cFilTeam, cMatTeam, cEmpTeam, aQryParam)

	Local oStAbsence	:= Nil
	Local cQuery 		:= ""
	Local cQryObj		:= ""
	Local cTipo			:= ""
	Local nSetPar		:= 2
	Local aDtsQry		:= {}
	Local aData			:= {}
	Local dDate			:= cTod("//")
	Local dDtIni 		:= cTod("//")
	Local dDtFim 		:= cTod("//")
	Local lDtIni		:= .F.
	Local lDtFim		:= .F.

	Default cMatTeam	:= ""
	Default cFilTeam	:= FwCodFil()
	Default cEmpTeam	:= cEmpAnt
	Default aQryParam	:= {cTod("//"), cTod("//"), ""}

	If !Empty(cMatTeam)

		//Obtem os dados vindos do queryparam
		If !Empty(aQryParam[1])
			dDtIni := aQryParam[1]
		EndIf
		If !Empty(aQryParam[2])
			dDtFim := aQryParam[2]
		EndIf
		If !Empty(aQryParam[3])
			cTipo := aQryParam[3]
		EndIf		

		//Quando não passa nenhuma data considera o ultimo ano
		If Empty(dDtIni) .And. Empty(dDtFim)
			dDate  := If( !Type("dDtRobot") == "U" .And. !Empty(dDtRobot), dDtRobot, dDatabase )
			dDtIni := YearSub( dDate, 1 )
			dDtFim := dDate
		EndIf

		lDtIni := !Empty(dDtIni)
		lDtFim := !Empty(dDtFim)

		cQuery		:= GetNextAlias()
		oStAbsence	:= FWPreparedStatement():New()

		cQryObj := "SELECT"
		cQryObj += " RA_FILIAL, RA_MAT, RA_SITFOLH, R8_NUMID, R8_FILIAL, R8_MAT, R8_TIPOAFA, R8_DATAINI, R8_DATAFIM, R8_DURACAO, R8_STATUS, RCM_FILIAL, RCM_DESCRI"
		cQryObj += " FROM " + RetFullName('SRA', cEmpTeam) + " SRA "
		cQryObj += " INNER JOIN " + RetFullName('SR8', cEmpTeam) + " SR8 "
		cQryObj += " ON SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT "
		cQryObj += " LEFT JOIN " + RetFullName('RCM', cEmpTeam) + " RCM "
		cQryObj += " ON SR8.R8_TIPOAFA = RCM.RCM_TIPO AND " + fMHRTableJoin("SR8", "RCM")
		cQryObj += " WHERE SRA.RA_FILIAL = ? "
		cQryObj += " AND SRA.RA_MAT = ? "
		cQryObj += " AND SRA.D_E_L_E_T_ = ' '"
		cQryObj += " AND SR8.D_E_L_E_T_ = ' '"
		cQryObj += " AND RCM.D_E_L_E_T_ = ' '"
		cQryObj += " AND RCM_TIPOAF NOT IN ('', '4') "

		//Define os campos data na query
		aAdd(aDtsQry, { "R8_DATAINI", "D", 8, 0 } )
		aAdd(aDtsQry, { "R8_DATAFIM", "D", 8, 0 } )

		If !Empty(cTipo)
			cQryObj += " AND SR8.R8_TIPOAFA = '" + cTipo + "'"
		EndIf
		If lDtIni
			cQryObj += " AND SR8.R8_DATAINI >= ? "
		EndIf
		If lDtFim
			cQryObj += " AND SR8.R8_DATAFIM <= ? "
		EndIf

		cQryObj += " ORDER BY 4 DESC "

		oStAbsence:SetFields( aDtsQry )

		cQryObj := ChangeQuery(cQryObj)
		oStAbsence:SetQuery(cQryObj)

		//Seta na query os parâmetros
		oStAbsence:SetString(1,cFilTeam)
		oStAbsence:SetString(2,cMatTeam)
		
		If lDtIni
			nSetPar ++
			oStAbsence:SetDate(nSetPar,dDtIni)
		EndIf
		If lDtFim
			nSetPar ++
			oStAbsence:SetDate(nSetPar,dDtFim)
		EndIf

		cQryObj := oStAbsence:GetFixQuery()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryObj),cQuery,.T.,.T.)
		oStAbsence:doTcSetField(cQuery)

		While (cQuery)->(!Eof())
			aAdd(aData, { 				;
				AllTrim((cQuery)->R8_NUMID),;	//Numero de identificacao
				(cQuery)->R8_DATAINI,	;		//Inicio do afastamento
				(cQuery)->R8_DATAFIM,	;		//Fim do afastamento
				(cQuery)->R8_DURACAO,	;		//Duracao do afastamento
				(cQuery)->R8_TIPOAFA,	;		//Tipo do afastamento
				(cQuery)->RCM_FILIAL,	;		//Filial da tabela Tipo de Afastamento
				AllTrim((cQuery)->RCM_DESCRI) ;	//Descrição do Tipo de Afastamento
			})
			(cQuery)->( DbSkip() )
		EndDo
		(cQuery)->( DBCloseArea() )
	EndIf

Return(aData)

Function fQryOccurs( cCodEmp, cCodFil, cCodMat, cDtIni, cDtFim, aClass, lTotalize, cEmpJob, lJob, cUID )

	Local cQryObj  := ""
	Local aArea    := {}
	Local aHEs     := {}
	Local cQuery   := ""
	Local dIniPon  := ctod("//")
	Local dFimPon  := ctod("//")
	Local nNumPars := NIL

	DEFAULT lTotalize   := .F.
	DEFAULT cDtIni := ""
	DEFAULT cDtFim := ""
	DEFAULT lJob   := .F.
	DEFAULT cUID   := ""
	DEFAULT aClass := {}
	DEFAULT cEmpJob := cEmpAnt

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType( 3 )
		RPCSetEnv( cCodEmp, cCodFil )
	EndIf

	aArea    := GetArea()
	cQuery   := GetNextAlias()

	If oObjDelay == NIL .Or. !( cEmpJob == cCodEmp )
		oObjDelay := FWPreparedStatement():New()

		cQryObj := " SELECT "
		cQryObj += " SPC.PC_FILIAL FILIAL, 
		cQryObj += " SPC.PC_MAT MAT, 
		cQryObj += " SPC.PC_DATA DATAMOV, 
		cQryObj += " SPC.PC_PD PD, 
		cQryObj += " SPC.PC_PDI PDI,
		cQryObj += " SPC.PC_QUANTC QUANTC, 
		cQryObj += " SPC.PC_QUANTI QUANTI,
		cQryObj += " SPC.PC_ABONO ABONO, 
		cQryObj += " SPC.PC_QTABONO QTABONO, 
		cQryObj += " SP9.P9_CODIGO,
		cQryObj += " SP9.P9_IDPON, 
		cQryObj += " SP9.P9_DESC,
		cQryObj += " SP9.P9_CLASEV,
		cQryObj += " SRA.RA_NOME
		cQryObj += " FROM " + RetFullName('SPC', cCodEmp) + " SPC "
		cQryObj += " INNER JOIN " + RetFullName('SP9', cCodEmp) + " SP9 "
		cQryObj += " ON " + FWJoinFilial("SPC", "SP9")
		cQryObj += " AND SPC.PC_PD = SP9.P9_CODIGO "
		cQryObj += " INNER JOIN " + RetFullName('SRA', cCodEmp) + " SRA "
		cQryObj += " ON SPC.PC_FILIAL = SRA.RA_FILIAL AND SPC.PC_MAT = SRA.RA_MAT"
		cQryObj += " WHERE "
		cQryObj += " SRA.RA_FILIAL = ?"
		cQryObj += " AND SRA.RA_MAT = ?"
		cQryObj += " AND P9_CLASEV IN (?)"
		cQryObj += " AND SPC.PC_DATA >= ?"
		cQryObj += " AND SPC.PC_DATA <= ?"
		cQryObj += " AND SRA.D_E_L_E_T_ = ' '"
		cQryObj += " AND SPC.D_E_L_E_T_ = ' '"
		cQryObj += " AND SP9.D_E_L_E_T_ = ' '"

		cQryObj += " UNION "

		cQryObj += " SELECT "
		cQryObj += " SPH.PH_FILIAL FILIAL, 
		cQryObj += " SPH.PH_MAT MAT, 
		cQryObj += " SPH.PH_DATA DATAMOV, 
		cQryObj += " SPH.PH_PD PD, 
		cQryObj += " SPH.PH_PDI PDI,
		cQryObj += " SPH.PH_QUANTC QUANTC, 
		cQryObj += " SPH.PH_QUANTI QUANTI,
		cQryObj += " SPH.PH_ABONO ABONO, 
		cQryObj += " SPH.PH_QTABONO QTABONO, 
		cQryObj += " SP9.P9_CODIGO,
		cQryObj += " SP9.P9_IDPON, 
		cQryObj += " SP9.P9_DESC,
		cQryObj += " SP9.P9_CLASEV,
		cQryObj += " SRA.RA_NOME
		cQryObj += " FROM " + RetFullName('SPH', cCodEmp) + " SPH "
		cQryObj += " INNER JOIN " + RetFullName('SP9', cCodEmp) + " SP9 "
		cQryObj += " ON " + FWJoinFilial("SPH", "SP9")
		cQryObj += " AND SPH.PH_PD = SP9.P9_CODIGO "
		cQryObj += " INNER JOIN " + RetFullName('SRA', cCodEmp) + " SRA "
		cQryObj += " ON SPH.PH_FILIAL = SRA.RA_FILIAL AND SPH.PH_MAT = SRA.RA_MAT"
		cQryObj += " WHERE "
		cQryObj += " SRA.RA_FILIAL = ?"
		cQryObj += " AND SRA.RA_MAT = ?"
		cQryObj += " AND P9_CLASEV IN (?)"
		cQryObj += " AND SPH.PH_DATA >= ?"
		cQryObj += " AND SPH.PH_DATA <= ?"
		cQryObj += " AND SRA.D_E_L_E_T_ = ' '"
		cQryObj += " AND SPH.D_E_L_E_T_ = ' '"
		cQryObj += " AND SP9.D_E_L_E_T_ = ' '"
		cQryObj += " ORDER BY DATAMOV, PD "
		cQryObj := ChangeQuery(cQryObj)
		oObjDelay:SetQuery(cQryObj)
	EndIf

	//Carrega codigos de HE Autorizadas/Não autorizadas
	DBSelectArea("SRA")
	SRA->(DbSetOrder(1))
	SRA->(DbSeek(cCodFil+cCodMat))
	//Função do PONXFUN para carregar as HEs conforme o funcionário posicionado no loop.
	GetTabExtra( @aHEs, SRA->RA_FILIAL, SRA->RA_TNOTRAB, .F., .F. )
	//Busca periodo de apontamento de acordo com o funcionário que está sendo processado.
	If Empty(cDtIni) .And. Empty(cDtFim)
		GetPonMesDat( @dIniPon, @dFimPon, SRA->RA_FILIAL )
		cDtIni := If( Empty(cDtIni), dToS(dIniPon), cDtIni ) 
		cDtFim := If( Empty(cDtFim), dToS(dFimPon), cDtFim )
	EndIf

	//Seta na query os parâmetros da SPC
	nNumPars := 1
	oObjDelay:SetString(nNumPars,SRA->RA_FILIAL)
	nNumPars ++
	oObjDelay:SetString(nNumPars,SRA->RA_MAT)
	nNumPars ++
	oObjDelay:SetIn(nNumPars,aClass)
	nNumPars ++
	oObjDelay:SetString(nNumPars,cDtIni)
	nNumPars ++
	oObjDelay:SetString(nNumPars,cDtFim)
	nNumPars ++

	//Seta na query os parâmetros da SPH após UNION
	oObjDelay:SetString(nNumPars,SRA->RA_FILIAL)
	nNumPars ++
	oObjDelay:SetString(nNumPars,SRA->RA_MAT)
	nNumPars ++
	oObjDelay:SetIn(nNumPars,aClass)
	nNumPars ++
	oObjDelay:SetString(nNumPars,cDtIni)
	nNumPars ++
	oObjDelay:SetString(nNumPars,cDtFim)

	cQryObj := oObjDelay:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryObj),cQuery,.T.,.T.)
	oObjDelay:doTcSetField(cQuery)

	aEventos := fSetEvents( cQuery, lTotalize, aHEs, cCodEmp )

	RestArea(aArea)
	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf
Return aEventos

/*/{Protheus.doc} fMrhTypeHe
Seta o tipo de HE
@author:	Henrique
@since:		07/04/2021
@param:		cFilSRA - Filial;
			cTnoSRA - Turno;
@return:	aCodigos - Array com codigos de HE
/*/	
Function fMrhTypeHe(cTipo)

Local cReturn := "regularExtraHour"

DEFAULT cTipo := ""

If !Empty(cTipo)
	Do Case
		Case cTipo $ "1*5*A*B"
			cReturn := "regularExtraHour"
		Case cTipo $ "2*6*C*D"
			cReturn := "restExtraHour"
		Case cTipo $ "3*7*E*F"
			cReturn := "compensatedExtraHour"
		Otherwise
			cReturn := "holidayExtraHour"
	End Case
EndIf

Return cReturn

/*/{Protheus.doc} fSetEvents
Preenche o array de eventos que serão retorandos.
@author:	Henrique
@since:		07/04/2021
@param:		cAliasQry - Query;
			lTotalize - .T. para totalizar, .F. para não totalizar;
			cEmpAtu - Código da empresa
@return:	aEventos - Array com os eventos
/*/	
Function fSetEvents( cAliasQry, lTotalize, aHEs, cEmpAtu )

LocaL aEventos 	:= {}

Local cTpEv 	 := "XX"
Local cLastMat	 := ""
Local cDelays	 := "03,04,05" // classe dos eventos de atrasos / saidas
Local cAbsences  := "02" // classe do evento de faltas

Local nReg		:= 0
Local nSaldo 	:= 0
Local nPos   	:= 0
//Posicoes usadas no array de eventos
LocaL nPosVal 		:= 0
LocaL nPosDelay 	:= 6
LocaL nPosAbsence 	:= 7
Local nPosOverT     := 8

DEFAULT cAliasQry := ""
DEFAULT lTotalize := .F.
DEFAULT aHEs	  := {}
DEFAULT cEmpAtu   := cEmpAnt

If (cAliasQry)->(!Eof())

	If lTotalize
		nReg := 1
		// Empresa, Filial, Matricula, Nome, Atrasos, Faltas, HEs, TipoHE
		aAdd( aEventos,	{ "", "", "", "", "", 0, 0, 0, "" } ) 
	EndIf

	While !(cAliasQry)->(Eof())

		//Se houver abono verifica se o evento foi abonado integral ou parcialmente
		If !Empty((cAliasQry)->ABONO ) 
			If ((cAliasQry)->QUANTC > (cAliasQry)->QTABONO )
				nSaldo := __TimeSub( (cAliasQry)->QUANTC, (cAliasQry)->QTABONO )
			Else
				(cAliasQry)->(DbSkip())
				Loop
			EndIf
		Else
			//Prioriza a qtde informada e depois a qtde calculada
			If (cAliasQry)->QUANTI > 0
				nSaldo := (cAliasQry)->QUANTI
			Else
				nSaldo := (cAliasQry)->QUANTC
			EndIf
		EndIf
		//Converte de Horas para Milissegundos.
		nSaldo := HourToMs(cValToChar(nSaldo))

		//Verifica se existe alguma HE autorizada e busca o tipo, iniciando pelo código informado.
		If ( nPos := aScan( aHEs,{|x| x[4] == (cAliasQry)->PDI } ) ) > 0
			cTpEv := aHEs[nPos,1]
		ElseIf ( nPos := aScan( aHEs,{|x| x[5] == (cAliasQry)->PDI } ) ) > 0
			cTpEv := aHEs[nPos,1]
		ElseIf ( nPos := aScan( aHEs,{|x| x[4] == (cAliasQry)->PD } ) ) > 0
			cTpEv := aHEs[nPos,1]
		//Verifica se existe alguma HE NÃO autorizada ou não autorizada e busca o tipo
		ElseIf ( nPos := aScan( aHEs,{|x| x[5] == (cAliasQry)->PD } ) ) > 0
			cTpEv := aHEs[nPos,1]
		// evento diferente de HE ( Atrasos e Faltas)
		else
			cTpEv := "XX" 
		EndIf

		//Atribui o valor na posicao correta conforme o tipo (Falta ou atraso ou HE)
		If (cAliasQry)->P9_CLASEV $ cDelays
			nPosVal := nPosDelay
		ElseIf (cAliasQry)->P9_CLASEV $ cAbsences
			nPosVal := nPosAbsence
		Else
			nPosVal := nPosOverT
		EndIf

		If lTotalize
			If nPosVal == nPosAbsence
				aEventos[nReg, nPosVal] += 1
			Else
				aEventos[nReg, nPosVal] := __TimeSum( aEventos[nReg, nPosVal], nSaldo )
			EndIf
		Else
			If !cLastMat == cEmpAtu + (cAliasQry)->FILIAL + (cAliasQry)->MAT + (cAliasQry)->DATAMOV + cTpEv
				nReg ++
				aAdd( aEventos,	{ cEmpAtu, ;
									(cAliasQry)->FILIAL, ;
									(cAliasQry)->MAT, ;
									AllTrim((cAliasQry)->RA_NOME), ;
									(cAliasQry)->DATAMOV, ;
									0, ;
									0, ;
									0, ;
									cTpEv } ) 
			EndIf
			aEventos[nReg, nPosVal] := __TimeSum( aEventos[nReg, nPosVal], nSaldo )
			cLastMat := cEmpAtu + (cAliasQry)->FILIAL + (cAliasQry)->MAT + (cAliasQry)->DATAMOV + cTpEv
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->( DBCloseArea() )
EndIf

Return aEventos


