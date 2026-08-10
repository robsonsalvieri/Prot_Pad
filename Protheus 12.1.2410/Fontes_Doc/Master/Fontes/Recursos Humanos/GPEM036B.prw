#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM036.CH"

Static cVersEnvio:= "2.4"

Static __oSt05_1	 	//Query para filtrar as verbas de folha que foram pagas de funcionários ativos
Static __oSt05_2	 	//Query para filtrar as verbas de folha que foram pagas de funcionários demitidos
Static __oSt06		 	//Query para filtrar roteiro 132 anterior a dezembro
Static __oSt09		 	//Query para filtrar as verbas calculadas no dissídio
Static __oSt10		 	//Query para verificar os lançamentos de múltiplos vínculos
Static __oSt11		 	//Query para verificar se houve cálculo de férias com pagamento no período
Static __oSt12		 	//Query para filtrar as verbas de férias calculadas com pagamento no período
Static __oSt13		 	//Query para filtrar os registros da C9V do CPF que está em processamento
Static __oSt17_1	 	//Query para verificar quantidade de matriculas no periodo
Static __oSt17_2	 	//Query para verificar quantidade de matriculas no periodo filtrando por data de pagamento
Static __oSt17_3	 	//Query para verificar quantidade de matriculas no periodo 132
Static __oSt18		 	//Query para verificar férias pagas em período anterior, de matrículas transferidas
Static __oSt19		 	//Query para verificar registros destino da SRH/SRR de matrículas transferidas
Static __oSt04		 	//Query para filtrar o cálculo de plano de saúde
Static __oSt20		 	//Query para filtrar o Reembolso/Coparticipação
Static aTabS073		:= {}	//Tabela S073
Static oHash
Static lIntTAF
Static lMiddleware
Static cQuebra
Static aTabS016		:= {}
Static aTabS017		:= {}
Static cFilCrgTab	:= ""

/*/{Protheus.doc} GPEM036B
@Author   Alessandro Santos
@Since    18/03/2019
@Version  1.0
@Obs      Migrado do GPEM036 em 15/04/2019 para gerar o evento S-1211
/*/
Function GPEM036B()
Return()

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ fNew1210()     ³Autor³  Marcia Moura     ³ Data ³02/06/2017³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Gera o registro de Folha / Pagamentos                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM034                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Nil															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³Nil															³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */

Function fNew1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, aLogsErr, aLogsPrc, lRelat, lSched)

Local lRet 		:= .T.
Local aAreaSM0	:= SM0->(GetArea())

Private lRobo	:= IsBlind()

Default lSched := .F.

If lSched
	lRet := NewProc1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, .F., aLogsErr, aLogsPrc, lRelat, lSched)
ElseIf lRobo
	Processa({|lEnd| lRet := NewProc1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, .F., aLogsErr, aLogsPrc, lRelat)})
Else
	Proc2BarGauge({|lEnd| lRet := NewProc1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, .T., aLogsErr, aLogsPrc, lRelat)}, "Evento S-1210", NIL , NIL , .T. , .T. , .F. , .F. )
EndIf

__oSt05_1 	:= Nil
__oSt05_2 	:= Nil
__oSt06 	:= Nil
__oSt09 	:= Nil
__oSt10 	:= Nil
__oSt11 	:= Nil
__oSt12 	:= Nil
__oSt13 	:= Nil
__oSt17_1 	:= Nil
__oSt17_2 	:= Nil
__oSt17_3 	:= Nil
__oSt18 	:= Nil
__oSt19 	:= Nil
aTabS073 	:= Nil
__oSt04     := Nil
__oSt20     := Nil
aTabS016    := Nil
aTabS017    := Nil

If ValType(oHash) == "O"
	HMClean(oHash)
	FreeObj(oHash)
	oHash := Nil
EndIf

RestArea(aAreaSM0)

Return lRet

/*/{Protheus.doc} NewProc1210
Processamento das rubricas de IRRF com data de pagamento dentro da competência selecionada
@author Allyson
@since 19/06/2018
@version 2.0
@param cCompete 	- Competência da geração do evento
@param cPerIni 		- Período inicial da geração do evento
@param cPerFim 		- Período final da geração do evento
@param aArrayFil 	- Filiais selecionadas para processamento
@param lRetific 	- Indica se é retificação
@param lIndic13 	- Indica se é referente a 13º salário
@param aLogsOk 		- Log de ocorrências do processamento
@param cOpcTab 		- Indica se o período em aberto será considerado (0=Não|1=Sim)
@param aCheck 		- Checkbox da tela de geração dos períodicos
@param cCPFDe 		- CPF inicial para filtro
@param cCPFAte 		- CPF final para filtro
@param lExcLote		- Indicativo de exclusão em lote
@param cExpFiltro	- Expressão de filtro na tabela SRA
@param lNewProgres	- Indicativo de execução do robô
@param aLogsErr 	- Log de ocorrências de erro do processamento
@param aLogsProc 	- Log de ocorrências do resumo do processamento
@param lRelat 		- Indica se é geração do relatório em Excel

@return NIL

/*/
Static Function NewProc1210(cCompete, cPerIni, cPerFim, aArrayFil, lRetific, lIndic13, aLogsOk, cOpcTab, aCheck, cCPFDe, cCPFAte, lExcLote, cExpFiltro, lNewProgres, aLogsErr, aLogsPrc, lRelat, lSched)

	Local aArea			:= GetArea()
	Local aAreaSM0		:= SM0->(GetArea())
	Local aBkpFer		:= {}
	Local aContdmDev	:= {}
	Local aCpfDesp		:= {}
	Local aFilInTaf		:= {}
	Local aFilInAux 	:= {}
	Local aRotADI		:= fGetRotTipo("2")
	Local aRotFOL		:= fGetRotTipo("1")
	Local aTabIR		:= {}
	Local aTabIRRF		:= {}
	Local aVbFer		:= {}
	Local aStatT3P		:= {}
	Local aFilInativ	:= {}

	Local cFilInativ	:= ""
	Local cAliasQSRA	:= "SRAQRY"
	Local cAliasQC		:= "SRACON"
	Local cAliasQMV		:= "SRAQMV"
	Local cAliasSRA		:= "SRA"
	Local cAliasSRX		:= GetNextAlias()
	Local cAno			:= substr(cCompete,3,4)
	Local cBkpFil		:= cFilAnt
	Local cBkpFilEnv	:= ""
	Local cCatTSV		:= SuperGetMv( "MV_NTSV", .F., "701|711|712|741|" )
	Local cCPF			:= ""
	Local cCpfOld		:= ""
	Local cDtIni		:= ""
	Local cDtFim		:= ""
	Local cDtGerRes		:= ""
	Local cDtPesqI		:= substr(cCompete,3,4)+ substr(cCompete,1,2)+"01"
	Local cDtPesqF		:= substr(cCompete,3,4)+ substr(cCompete,1,2)+"31"
	Local cFilEnv		:= ""
	Local cFilProc		:= ""
	Local cFilPreTrf	:= ""
	Local cFilx			:= ""
	Local cideDmDev		:= ""
	Local cIdeRubr		:= ""
	Local cIdTbRub		:= ''
	Local cJoinRCxRY	:= FWJoinFilial( "SRC", "SRY" )
	Local cJoinRDxRY	:= FWJoinFilial( "SRD", "SRY" )
	Local cLastRot		:= ""
	Local cLstCPF		:= ''
	Local cMes			:= substr(cCompete,1,2)
	Local cMsgErro		:= ""
	Local cNome			:= ""
	Local cNomeTCPF		:= ""
	Local cNomeTEmp		:= ""
	Local cOldFil		:= ""
	Local cOldFilEnv	:= ""
	Local cOldOcorr		:= ""
	Local cPD			:= ""
	Local cPdCod0021	:= ""
	Local cPdCod546		:= ""
	Local cPdCod0151	:= ""
	Local cPDLiq		:= ""
	Local cPer			:= ""
	Local cPer1210		:= SubStr(cCompete, 3, 4) + SubStr(cCompete, 1, 2)
	Local cPer132		:= ""
	Local cPeriodo		:= ""
	Local cPerOld		:= ""
	Local cPerOld1		:= ""
	Local cPerRes		:= ""
	Local cQuery		:= ""
	Local cQueryCont	:= ""
	Local cQueryMV		:= ""
	Local cRecResc		:= ""
	Local cRoteiro		:= ""
	Local cSemRes		:= ""
	Local cSRHFil		:= ""
	Local cSRHMat		:= ""
	Local cSRHCodUni	:= ""
	Local cStat1		:= ''
	Local cStatT3P		:= "-1"
	Local cTpPgto		:= "1"
	Local cTpRes		:= ""
	Local cTpRot		:= ""
	Local cRecibo		:= ""
	Local cTSV			:= fCatTrabEFD("TSV")
	Local cXml			:= ""
	Local cSitFolh		:= ""
	Local cEmp			:= ""
	Local cEmpOld		:= ""
	Local cTafKey		:= ""
	Local cTpFolha		:= IIF(lIndic13, "2", "1")
	Local cUltTpRes		:= ""

	Local dDcgIni		:= SuperGetMV("MV_DTCGINI",nil,CTOD(" / / ") )
	Local dDtPgt		:= DDATABASE
	Local dDtRes		:= cToD("//")
	Local dDtPgtRR		:= cToD("//")

	Local lAchou063		:= .F.
	Local lAfast		:= .F.
	Local lFilAux		:= .F.
	Local lGeraCod		:= .F.
	Local lRes			:= .F.
	Local lRetXml		:= .F.
	Local lTem132		:= .F.
	Local lTSV			:= .F.
	Local lPgtRes		:= .T.
	Local lPrimIdT		:= .T.
	Local lResComPLR	:= .F.
	Local lResOriCom	:= .F.
	Local lDtPgto		:= .F.
	Local lAborta		:= .F.

	Local nVldOpcoes	:= 0
	Local nCntFer		:= 0
	Local nCont			:= 0
	Local nContRot		:= 0
	Local nI			:= 0
	Local nPdetPGtoAt	:= 0
	Local nPdetPGtoFl	:= 0
	Local nPosEmp		:= 0
	Local nQtdeFolMV	:= 0
	Local nValor		:= 0
	Local nVlrDep		:= 0
	Local nX			:= 0
	Local nx1			:= 0
	Local nHrInicio
	Local nHrFim

	Local aEmp_1210		:= {0, 0, 0, 0} //1 - Integrados TCV; 2 - Nao Integrados TCV; 3 - Integrados TSV; 4 - Nao Integrados TSV
	Local aRGE1210 		:= {}
	Local aResCompl		:= {}

	Local nContRes		:= 0
	Local dlastDate		:= cToD("")
	Local lGera546		:= .T.
	Local lVer546		:= .T.
	Local aCodHash		:= {}
	Local cCodFol
	Local cTipoCod
	Local cCodINCIRF
	Local cCodAdiant
	Local cCodFil
	Local cCodNat	    := ""

	Local lAdmPubl	 	:= .F.
	Local aInfoC	 	:= {}
	Local aDados	 	:= {}
	Local aErros	 	:= {}
	Local cTpInsc		:= ""
	Local cNrInsc		:= ""
	Local cChaveMid	 	:= ""
	Local cStatNew		:= ""
	Local cOperNew		:= ""
	Local cRetfNew		:= ""
	Local cRecibAnt		:= ""
	Local cKeyMid		:= ""
	Local cIdXml		:= ""
	Local lNovoRJE		:= .T.
	Local nRecEvt		:= 0
	Local cVersMw		:= ""
	Local nTotRec		:= 0
	Local cTimeIni		:= Time()
	Local aArrayFil2	:= {}
	Local nZ			:= 0
	Local nW			:= 0
	Local cFilTransf	:= ""
	Local dDtPgto		:= cToD("//")
	Local cKeyProc		:= ""
	Local cTrabSemVinc  := "201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903"
	Local lTemMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0
	Local lGeraMat		:= .F.
	Local lResTSV		:= .F.
	Local l3GRescMes	:= .F.
	Local nQtdMesAnt	:= 1
	Local lTercGrp		:= .F.
	Local lPesFisica	:= .F.
	Local cVerbas		:= ""
	Local cStatC91		:= "-1"
	Local aStatC91		:= {}
	Local cNumFer		:= ""
	Local cBkpDtFer		:= ""
	Local nNumFer		:= 0
	Local lOrig1202		:= ( ChkFile("T61") .And. T61->(ColumnPos("T61_ORGSUC")) > 0 ) .And. ( ChkFile("V6V") .And. V6V->(ColumnPos("V6V_TPINSC")) > 0 )
	Local lOrig1207		:= SuperGetMv("MV_OPESOC", Nil, .F.) .And. SRC->(ColumnPos("RC_NRBEN")) > 0 .And. ( ChkFile("T61") .And. T61->(ColumnPos("T61_ORGSUC")) > 0 ) .And. ( ChkFile("V6V") .And. V6V->(ColumnPos("V6V_TPINSC")) > 0 )
	Local lCatEst		:= .F.
	Local aDmDevBop		:= {}
	Local nDm			:= 0
	Local lTemNrBen		:= SRD->(ColumnPos("RD_NRBEN")) > 0 .And. SRC->(ColumnPos("RC_NRBEN")) > 0
	Local nRetFer       := 1
	Local cFilVal       := ""
	Local lAchouSRG		:= .F.
	Local lCodCorr		:= .F.
	Local lGeraRRA		:= .F.
	Local nPosFOL		:= 0
	Local cRotBkp		:= ""
	Local cdtDeslig		:= ""
	Local nPosRes		:= 0
	Local aResS1210		:= {}
	Local cTpPgtoBkp	:= ""
	Local lAmbosEve		:= .F.
	Local lAltdmDev		:= .T.
	Local cRotAnt       := ""
	Local lNewDmDev		:= SuperGetMv("MV_IDEVTE", , .F. ) .And. ChkFile("RU8") .And. FindFunction("fGetPrefixo")
	Local cPrefixo		:= ""
	Local cCodChave		:= ""
	Local cCatS1200     := "501|701|711|712|723|731|734|738|741|751|761|781|903|904|905|906"
	Local aIncIRComp	:= {} //Array com incidência de IR que obrigam as informações complementares:
	Local cMsgPens		:= ""
	Local cMsgPlSau		:= ""
	Local cMsgPrevC		:= ""
	Local cFrmTribut	:= ""
	Local cMsgRGE		:= ""
	Local aRGE1210Bkp	:= {}
	Local aLogErrDep	:= {}
	Local lDtPgtoDif	:= .F.

	Private aCodFol		:= {}
	Private aCodBenef	:= {}
	Private aDetPgtoFl	:= {}
	Private aideBenef	:= {}
	Private aInfoPgto	:= {}
	Private aDetPgtoAt 	:= {}
	Private aPgtoAnt 	:= {}
	Private aRetFer		:= {}
	Private aRetPensao	:= {}
	Private aLogCIC		:= {}
	Private aRetPgtoTot	:= {}
	Private detPgtoFer	:= {}
	Private aRelIncons	:= {}
	Private aEstb		:= fGM23SM0(,.T.) //extrai lista de filiais da SM0
	Private aSM0     	:= FWLoadSM0(.T.)
	Private nQtdeFol	:= 1
	Private lTemEmp		:= !Empty(FWSM0Layout(cEmpAnt, 1))
	Private lTemGC		:= fIsCorpManage( FWGrpCompany() )
	Private cLayoutGC	:= FWSM0Layout(cEmpAnt)
	Private nIniEmp 	:= At("E", cLayoutGC)
	Private nTamEmp		:= Len(FWSM0Layout(cEmpAnt, 1))

	Private cSRACPF 	:= "QRYSRACPF"
	Private cSRAEmp 	:= "QRYSRAEMP"
	Private oTmpCPF		:= Nil
	Private oTmpEmp		:= Nil
	Private aInfoPrev	:= {}
	Private aDepen		:= {}
	Private aDedDep		:= {}
	Private dtLaudo     := cToD("//")
	Private cCodRec     := ""
	Private adadosRHS	:= {}
	Private adadosRHP	:= {}
	Private aRelRHS		:= {}
	Private aRelRHP		:= {}
	Private cCodRece    := ""
	Private aCodRece    := {}
	Private lResidExt	:= .F.
	Private cLogDep		:= ""
	Private aIncRes       := {}
	Private cCdEFD        := ""

	//Statics
	Default lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .And. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
	Default lMiddleware	:= If( cPaisLoc == 'BRA' .And. Findfunction("fVerMW"), fVerMW(), .F. )
	Default cQuebra		:= Chr(13) + Chr(10)

	Default aCheck		:= {.F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .T.}
	Default cOpcTab		:= "0"
	Default cCPFDe		:= ""
	Default cCPFAte		:= ""
	Default cExpFiltro	:= ""
	Default lNewProgres	:= .F.
	Default lSched		:= .F.

	Iif( FindFunction("fVersEsoc"), fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, Nil, @cVersMw ), .T.)

	lGeraRRA := (cVersEnvio >= "9.1")

	lAfast	:= aCheck[13]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Carrega Tabela de IRRF                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTabIR 	 := {}
	aTabIRRF := {}
	fCarrTab( @aTabIRRF, "S002",  )
	For nX := 1 To Len(aTabIRRF)
		If aTabIRRF[nX][1] == "S002"
			If aTabIRRF[nX][5] <= cAno+cMes .And. aTabIRRF[nX][6] >= cAno+cMes
				aAdd(aTabIR, aTabIRRF[nX][20])
			EndIf
		EndIf
	Next nX

	If !lMiddleware
		fGp23Cons(@aFilInTaf, aArrayFil, @cFilEnv, @aFilInativ)

		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf

		If Empty(aFilInTaf)
			MsgAlert( STR0065 + CRLF + STR0066 )//"Não foi encontrada a filial de referência do TAF para a importação das informações."##"É necessário que seja incluído no cadastro de complemento de empresa a filial de destino para a importação das informações."
			Return .F.
		EndIf

		If LEN(aFilInativ) > 0

			FOR nI := 1 TO LEN(aFilInativ)
				cFilInativ += aFilInativ[nI] + ", "
			NEXT nI

			MsgAlert( "A(s) filial(is) " + cFilInativ + STR0072)
			Return .F.
		EndIf
	EndIf

	If !Empty(cFilEnv)
		lPesFisica	:= fGM36PFisica(cFilEnv)
	Endif
	//Hora Inicial
	nHrInicio := Seconds()

	If lAglut
		If !lMiddleware
			For nI := 1 To Len(aFilInTaf)
				For nX := 1 to len(aFilInTaf[nI,3])
					cFilProc += aFilInTaf[nI,3,nX]
				Next
			Next nI  //
		Else
			For nI := 1 To Len(aArrayFil)
				cFilProc += aArrayFil[nI]
			Next nI
		EndIf
		cFilProc := fSQLIn(cFilProc, FwSizeFilial())
	EndIf

	aStru := SRD->(dbStruct())

	If !Fp_CodFol(@aCodFol, xFilial('SRV'))
		Return(.F.)
	EndIf

	cVerbas :="'" + ACODFOL[44,1] + "','" + ACODFOL[106,1] + "','" + ACODFOL[107,1] + "'"

	oHash := HMNew()
	HMSet( oHash,xFilial('SRV'),aClone(aCodFol) )

	//Grava quais são as raízes de CNPJ's selecionadas para processamento
	If lAglut .And. !Empty(aArrayFil)
		For nZ := 1 to Len(aArrayFil)
			If (nW := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + aArrayFil[nZ] } )) > 0
				aAdd(aArrayFil2, {aSM0[nW, 1], aSM0[nW, 2], SubStr(aSM0[nW, 18], 1, 8)})
			EndIf
		Next nZ
	EndIf

	For nI := 1 To Len(aArrayFil)
		//Quando aglutina, somente executa o For uma vez pois processa todas as filiais de uma vez
		If lAglut .And. nI > 1
			Exit
		EndIf
		If !lAglut
			If !lMiddleware
				cFilProc := StrTran(fGM23Fil(aFilInTaf, nI)[1], "%", "")
			Else
				cFilProc := "'" + aArrayFil[nI] + "'"
			EndIf
		EndIf
		If Select( cAliasQSRA ) > 0
			(cAliasQSRA)->( dbCloseArea() )
		EndIf

		//Query para filtrar os CPFs de acordo com o filtro da rotina
		fQryCPF(cFilProc, aFilInTaf, nI, cCPFDe, cCPFAte, cExpFiltro, .F., cPer1210, aArrayFil )
		cNomeTCPF := oTmpCPF:GetRealName()

		If lAglut
			//Query para filtrar os CNPJs de acordo com o filtro da rotina
			fQryEmp()
			cNomeTEmp := oTmpEmp:GetRealName()
		EndIf

		//Query para filtrar as matriculas que possuem cálculo da folha de acordo com os CPFs filtrados
		cQuery := "SELECT SRA.RA_CIC, SRA.RA_FILIAL RC_FILIAL, SRA.RA_MAT RC_MAT, SRA.RA_PIS, SRA.RA_NOMECMP, SRA.RA_OCORREN, SRA.RA_NOME, SRA.RA_CATEFD, "
		cQuery += "SRA.RA_SINDICA, SRA.RA_CODUNIC, SRA.RA_DEPIR, SRA.RA_PROCES, SRA.RA_ADMISSA, SRA.RA_RESEXT, SRA.RA_CODRET, SRA.RA_DEMISSA, SRA.RA_TPPREVI, SRA.RA_CATFUNC, SRA.RA_EAPOSEN, SRA.RA_MOLEST, SRA.R_E_C_N_O_ AS RECNO "
		If lOrig1207
			cQuery += ", RA_DTENTRA "
		EndIf
		If lAglut
			cQuery += ", EMP.CNPJ as CNPJ "
		EndIf
		cQuery += "FROM " + RetSqlName('SRA') + " SRA "
		If lAglut
			cQuery += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
			cQuery += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
		Else
			cQuery += "WHERE SRA.RA_FILIAL IN (" + cFilProc + ") "
			cQuery += "AND EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
		EndIf
		cQuery += "AND SRA.RA_CC <> ' ' "
		If !lExcLote
			cQuery += "AND EXISTS ("
			If cOpcTab == "1"
				cQuery += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT FROM " + RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRC.RC_TIPO2 != 'K' AND SRC.RC_PD NOT IN (" + cVerbas + ") AND SRC.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
				cQuery += "UNION "
			EndIf
			cQuery += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.RD_PD NOT IN (" + cVerbas + ") AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
			cQuery += "UNION "
			cQuery += "SELECT DISTINCT SRH.RH_FILIAL RC_FILIAL, SRH.RH_MAT RC_MAT FROM " + RetSqlName('SRH') + " SRH WHERE SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT AND SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRH.D_E_L_E_T_ = ' ') "
		EndIf
		cQuery += "AND SRA.D_E_L_E_T_ = ' ' "
		If !lAglut
			cQuery += "ORDER BY SRA.RA_CIC, SRA.RA_FILIAL, SRA.RA_MAT"
		Else
			cQuery += "ORDER BY SRA.RA_CIC, CNPJ"
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQSRA,.T.,.T.)

		If !lRobo
			//Query para filtrar as matriculas que possuem cálculo da folha de acordo com os CPFs filtrados
			cQueryCont := "SELECT COUNT(*) AS TOTAL "
			cQueryCont += "FROM " + RetSqlName('SRA') + " SRA "
			If lAglut
				cQueryCont += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
				cQueryCont += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
			Else
				cQueryCont += "WHERE SRA.RA_FILIAL IN (" + cFilProc + ") "
				cQueryCont += "AND EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
			EndIf
			cQueryCont += "AND SRA.RA_CC <> ' ' "
			If !lExcLote
				cQueryCont += "AND EXISTS ("
				If cOpcTab == "1"
					cQueryCont += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT FROM " + RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRC.RC_TIPO2 != 'K' AND SRC.RC_PD NOT IN (" + cVerbas + ") AND SRC.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
					cQueryCont += "UNION "
				EndIf
				cQueryCont += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.RD_PD NOT IN (" + cVerbas + ") AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
				cQueryCont += "UNION "
				cQueryCont += "SELECT DISTINCT SRH.RH_FILIAL RC_FILIAL, SRH.RH_MAT RC_MAT FROM " + RetSqlName('SRH') + " SRH WHERE SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT AND SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRH.D_E_L_E_T_ = ' ') "
			EndIf
			cQueryCont += "AND SRA.D_E_L_E_T_ = ' ' "
			cQueryCont := ChangeQuery(cQueryCont)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCont),cAliasQC,.T.,.T.)

			If (cAliasQC)->( !EoF() )
				nTotRec := (cAliasQC)->TOTAL
				If !lNewProgres
					GPProcRegua(nTotRec)
				Else
					BarGauge1Set(nTotRec)
				EndIf
			EndIf
			(cAliasQC)->( dbCloseArea() )
		EndIf

		If lAglut
			//Query para verificar quantas matriculas de um mesmo CPF possuem cálculo da folha de acordo com os CPFs filtrados
			cQueryMV := "SELECT SRA.RA_CIC, "
			cQueryMV += "EMP.CNPJ as CNPJ, "
			cQueryMV += " COUNT(*) AS CONT FROM " + RetSqlName('SRA') + " SRA "
			cQueryMV += "INNER JOIN " + cNomeTEmp + " EMP ON SRA.RA_FILIAL = EMP.FILIAL "
			cQueryMV += "WHERE EXISTS (SELECT RA_CIC FROM " + cNomeTCPF + " SRA2 WHERE SRA2.RA_CIC = SRA.RA_CIC) "
			cQueryMV += "AND SRA.RA_CC <> ' ' "
			If !lExcLote
				cQueryMV += "AND EXISTS ("
				If cOpcTab == "1"
					cQueryMV += "SELECT DISTINCT SRC.RC_FILIAL RC_FILIAL, SRC.RC_MAT RC_MAT FROM " + RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRC.RC_TIPO2 != 'K' AND SRC.RC_PD NOT IN (" + cVerbas + ") AND SRC.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
					cQueryMV += "UNION "
				EndIf
				cQueryMV += "SELECT DISTINCT SRD.RD_FILIAL RC_FILIAL, SRD.RD_MAT RC_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.RD_PD NOT IN (" + cVerbas + ") AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
				cQueryMV += "UNION "
				cQueryMV += "SELECT DISTINCT SRH.RH_FILIAL RC_FILIAL, SRH.RH_MAT RC_MAT FROM " + RetSqlName('SRH') + " SRH WHERE SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT AND SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRH.D_E_L_E_T_ = ' ') "
			EndIf

			cQueryMV += "AND SRA.D_E_L_E_T_ = ' ' "
			cQueryMV += "GROUP BY SRA.RA_CIC, CNPJ "
			cQueryMV += "ORDER BY SRA.RA_CIC, CNPJ"
			cQueryMV := ChangeQuery(cQueryMV)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryMV),cAliasQMV,.T.,.T.)
			nQtdeFol := (cAliasQMV)->CONT
		EndIf

		While (cAliasQSRA)->(!EOF())
			(cAliasSRA) ->( dbGoTo( (cAliasQSRA)->RECNO ) )
			lTercGrp := .F.
			//Identifica se o funcionário é residente no exterior
			lResidExt	:= If( cVersEnvio >= "9.1", ( cPer1210 >= "202303" .And. (cAliasSRA)->RA_CODRET == "0473" ), .F. )
			aRGE1210	:= {}
			aResS1210	:= {}
			aCodRece	:= {}
			aIncIRComp	:= {}
			lAmbosEve	:= .F.
			lAborta		:= .F.
			cLogDep		:= ""
			aLogErrDep	:= {}
			lDtPgtoDif	:= .F.

			//Codigos de Receita S-1210
			aAdd( aCodRece, {"047301",{},{},{} } )  //CR,Dependente,Pensao, Previdencia
			aAdd( aCodRece, {"056107",{},{},{} } )
			aAdd( aCodRece, {"058806",{},{},{} } )
			aAdd( aCodRece, {"188901",{},{},{} } )
			aAdd( aCodRece, {"356201",{},{},{} } )

								//Grupo  	Se Obriga   			Incidências							Se Gerou		Verbas
			aAdd( aIncIRComp, {"penAlim", 		.F., 	{"51","52","53","54"}, 								.F.,	 	{}	} )
			aAdd( aIncIRComp, {"planSaude", 	.F., 	{"67","9067","9219"}, 								.F.,		{}	} )
			aAdd( aIncIRComp, {"previdCompl", 	.F., 	{"46","47","48","61","62","63","64","65","66"}, 	.F., 		{}	} )

			If cVersEnvio < "9.0.00" .And. Empty((cAliasQSRA)->RA_PIS) .And. !((cAliasQSRA)->RA_CATEFD $ ("901*903*904"))
				aAdd(aLogsErr, Alltrim((cAliasQSRA)->RA_CIC) +"-" + Alltrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0214) ) //" Funcionário sem PIS cadastrado - Campo Obrigatório"
				aAdd(aLogsErr, "" )
				(cAliasQSRA)->(DBSkip())
				Loop
			EndIf
			cTpPgto := "1"
			If cVersEnvio >= "9.0.00"
				If lOrig1207 .And. ((cAliasQSRA)->RA_CATFUNC == "9" .Or. (cAliasQSRA)->RA_EAPOSEN == "1" ) .And. !Empty((cAliasQSRA)->RA_DTENTRA)
					cTpPgto := "5"
				ElseIf lOrig1202
					lCatEst := fTpPgtoEst((cAliasQSRA)->RA_TPPREVI, (cAliasQSRA)->RA_CATEFD, cCompete,cTpFolha)
					If lCatEst
						cTpPgto := "4"
						lAmbosEve := !((cAliasSRA)->RA_VIEMRAI $ "30|31|35")
					Endif
				EndIf
			Endif


			If Empty(cEmp)
				If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL } ) ) > 0
					cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
					cEmpOld := cEmp
				EndIf
			EndIf

			If	lAglut .And. ((cAliasQSRA)->RA_CIC != (cAliasQMV)->RA_CIC .OR.;
				((cAliasQSRA)->RA_CIC == (cAliasQMV)->RA_CIC .AND. cEmp != cEmpOld)) //Se o CPF for o mesmo, porém, a empresa é diferente
				(cAliasQMV)->( dbSkip() )
				nQtdeFol := (cAliasQMV)->CONT
			EndIf

			cSRHFil		:= cFilPreTrf := (cAliasSRA)->RA_FILIAL
			cSRHMat		:= (cAliasSRA)->RA_MAT
			cSRHCodUni	:= Iif((cAliasSRA)->RA_CATEFD $ cTrabSemVinc, "", (cAliasSRA)->RA_CODUNIC)

			If fFerPreTrf(@cSRHFil, @cSRHMat, cDtPesqF )
				(cAliasQSRA)->( dbSkip() )
				Loop
			EndIf

			cFilAnt := (cAliasSRA)->RA_FILIAL
			If lMiddleware
				fPosFil( cEmpAnt, cFilAnt )
			EndIf

			If !lIntTAF .And. (lMiddleware .And. Empty(fXMLInfos()))
				(cAliasQSRA)->( dbSkip() )
				If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL } ) ) > 0
					cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
				EndIf
				Loop
			EndIf

			//Verifica filial centralizadora do envio
			If cOldFilEnv != cFilAnt
				cOldFilEnv := cFilAnt
				If !lExcLote
					RstaCodFol()
					aCodHash := {}
					If HMGet(oHash,xFilial('SRV', (cAliasSRA)->RA_FILIAL),@aCodHash)
						aCodFol := aCodHash
					Else
						If !Fp_CodFol(@aCodFol, xFilial('SRV', (cAliasSRA)->RA_FILIAL))
							Return(.F.)
						EndIf
						HMSet( oHash,xFilial('SRV', (cAliasSRA)->RA_FILIAL),aClone(aCodFol) )
					EndIf
					cPdCod0021 	:= aCodFol[21,1]
					cPdCod546	:= aCodFol[546,1]
					cPdCod0151	:= aCodFol[151,1]
				Endif
				If !lMiddleware
					lFilAux		:= .F.
					For nX := 1 To Len(aFilInTaf)
						If aScan( aFilInTaf[nX, 3], { |x| x == cFilAnt } ) > 0
							cFilEnv := aFilInTaf[nX, 2]
							lFilAux	:= .T.
							Exit
						EndIf
					Next nX
					If !lFilAux
						fGp23Cons(aFilInAux, {cFilAnt})
						For nX := 1 To Len(aFilInAux)
							If aScan( aFilInAux[nX, 3], { |x| x == cFilAnt } ) > 0
								cFilEnv := aFilInAux[nX, 2]
								Exit
							EndIf
						Next nX
					EndIf
				Else
					cFilEnv := cFilAnt
				EndIf
			EndIf

			//Se P_ESOCMV for .T., relacionamento 1 x 1 e (raiz do CNPJ do funcionário com múltiplo vínculo não estiver selecionada ou
			//Funcionário não tem múltiplo vínculo no período e filial não está seleciona) pula para o próximo registro
			If lAglut .And. cFilEnv == (cAliasQSRA)->RC_FILIAL .And. (( nW := aScan(aArrayFil2, {|x| x[3] == cEmp }) ) == 0 .Or.;
			( nW := aScan(aArrayFil2, {|x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL })) == 0) .And. (cAliasQMV)->CONT == 1 .And.;
			(cAliasQMV)->RA_CIC == (cAliasQSRA)->RA_CIC .And. (cAliasQMV)->CNPJ == cEmp
				(cAliasQSRA)->( dbSkip() )
				If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL } ) ) > 0
					cEmpOld := cEmp
					cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
				EndIf
				Loop
			EndIf

			If !lRobo
				If !lNewProgres
					GPIncProc( "CPF: " + Transform((cAliasSRA)->RA_CIC, "@R 999.999.999-99") + " | Funcionário: " + (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT )
				Else
					IncPrcG1Time("CPF: " + Transform((cAliasSRA)->RA_CIC, "@R 999.999.999-99") + " | Funcionário: " + (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT, nTotRec, cTimeIni, .T., 1, 1, .T.)
				EndIf
			EndIf

			aResCompl	:= {}
			lDtPgto		:= .F.
			lResComPLR  := .F.
			cCPF    	:= (cAliasSRA)->RA_CIC
			cFil   		:= (cAliasSRA)->RA_FILIAL
			cMat   		:= (cAliasSRA)->RA_MAT
			cProcAtu    := (cAliasSRA)->RA_PROCES
			cMes   		:= Left(cCompete,2)
			cAno   		:= Right(cCompete,4)
			cCat 		:= (cAliasSRA)->RA_CATEFD
			cSitFolh	:= (cAliasSRA)->RA_SITFOLH
			cPerRes		:= ""
			cSemRes		:= ""
			dDtRes		:= cToD("//")
			cTpRes		:= ""
			cUltTpRes	:= ""
			cDtGerRes	:= ""
			cRecResc	:= ""
			lResTSV		:= .F.
			lRes 		:= fGetRes(cFil, cMat, cCompete, @dDtRes, Nil, @cTpRes, @cPerRes, @aResCompl, @cSemRes, @cRecResc, cTSV, @lResComPLR, cVersEnvio, @lResTSV, @cdtDeslig, @aResS1210 )
			cStat1		:= ""
			lPgtRes		:= .T.
			lTem132	 	:= .F.
			nContRes 	:= 0
			dlastDate	:= cToD("//")
			cLastRot	:= ""
			cPerOld		:= ""
			cPerOld1	:= ""
			nQtdeFolMV	:= 0
			lGera546	:= .T.
			lVer546		:= .T.
			lResOriCom	:= .F.
			cFilTransf	:= fFilTransf(cMat, cPer1210)
			l3GRescMes	:= .F.
			aBkpFer		:= {}
			cPrefixo	:= ""
			cCodChave	:= ""
			cMsgPens	:= ""
			cMsgPlSau	:= ""
			cMsgPrevC	:= ""
			cMsgRGE		:= ""

			If cVersEnvio >= "9.2"
				dtLaudo		:= 	(cAliasSRA)->RA_MOLEST
				cCodRece    := ""
			Endif

			//Define se o recibo será gerado usando a data de pagamento da verba quando há mais de uma rescisão complementar.
			lDtPgto := (lResComPLR .And. Len(aResCompl) > 1 .And. aScan(aResCompl, { |x| x[1] <> "1"}) == 0 .Or. (Len(aResCompl)>= 2 .And. aScan(aResCompl,{ |x|x[1] == "1"}) > 0))

			//Identifica no array aResCompl se as rescisões complementares possuem data de pagamento diferenes
			If Len(aResCompl) > 1
				For nW := 1 to Len(aResCompl)
					aEval(aResCompl, { |x| IIF( x[4] <> aResCompl[nW][4], lDtPgtoDif := .T.,)})
					If lDtPgtoDif
						Exit
					EndIf
				Next nW
			EndIf

			//Identifica se há rescisão complementar no mesmo da original para TSV exceto categoria 721
			If Len(aResCompl) > 1 .And. lDtPgtoDif .And. SRA->RA_CATEFD $ cTSV .And. SRA->RA_CATEFD != "721" .And. Substr(cCompete, 3, 4) + Substr(cCompete, 1, 2) == MesAno(SToD((cAliasQSRA)->RA_DEMISSA))
				lMesResTSV := .T.
			EndIf

			If lMiddleware
				fPosFil( cEmpAnt, SRA->RA_FILIAL )
				aInfoC   := fXMLInfos()
				If Len(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
					cIdXml   := aInfoC[3]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
			EndIf

			If cVersEnvio >= "9.0" .And. lOrig1207 .And. ((cAliasQSRA)->RA_CATFUNC == "9" .Or. (cAliasQSRA)->RA_EAPOSEN == "1" ) .And. !Empty((cAliasQSRA)->RA_DTENTRA)
				cStat1  := TAFGetStat( "S-2400", AllTrim((cAliasSRA)->(RA_CIC)) )
				lTSV 	:= cCat $ cTSV
			ElseIf cCat $ cTSV
				If !( cCat $ cCatTSV )
					If cVersEnvio >= "9.0" .And. lTemMat //controle chave 2300
						lGeraMat := ( SRA->RA_DESCEP == "1" )
					EndIf
					If !lMiddleware
						If cVersEnvio >= "9.0"
							cLstCPF := AllTrim( SRA->RA_CIC ) + ";" + If(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
						Else
							cLstCPF := AllTrim( (cAliasSRA)->(RA_CIC) ) + ";" + AllTrim( (cAliasSRA)->(RA_CATEFD) ) + ";" + AllTrim( dToS((cAliasSRA)->(RA_ADMISSA)) )
						EndIf
						cStat1  := TAFGetStat( "S-2300", cLstCPF, Nil, Nil, Nil, cPer1210, .T.)
					Else
						cLstCPF := If( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cLstCPF, 40, " ")
						cStat1 	:= "-1"
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStat1 )
					EndIf
				EndIf
				lTSV := .T.
			Else
				If !lMiddleware
					cLstCPF := AllTrim((cAliasSRA)->(RA_CIC)) + ";" + Iif(lMiddleware,Alltrim((cAliasSRA)->(RA_CODUNIC)),SRA->RA_CODUNIC)
					cStat1  := TAFGetStat( "S-2200", cLstCPF )
				Else
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStat1 		:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					GetInfRJE( 2, cChaveMid, @cStat1 )
				EndIf
				lTSV := .F.
			Endif
			If cStat1 == "-1"
				If !(cSitFolh == "D" .And. !lRes) .And. aScan(aLogsErr, {|X| "Funcionário("+(cAliasSRA)->RA_CIC+")" $ X}) == 0
					If !lMiddleware
						aAdd(aLogsErr,"[FALHA] Não foi possivel encontrar o registro do Funcionário ("+(cAliasSRA)->RA_CIC+")-"+Alltrim((cAliasSRA)->RA_NOME)+ " no TAF.") //##" ao integrar funcionario "
					Else
						aAdd(aLogsErr,"[FALHA] Não foi possivel encontrar o registro do Funcionário ("+(cAliasSRA)->RA_CIC+")-"+Alltrim((cAliasSRA)->RA_NOME)+ " no Middleware.") //##" ao integrar funcionario "
					EndIf
					aAdd(aLogsErr, "" )
				EndIf

				If lTSV
					aEmp_1210[4]++ //Inclui TSV nao integrado
				Else
					aEmp_1210[2]++ //Inclui TCV nao integrado
				EndIf

				If lRelat
					aAdd( aRelIncons, { SRA->RA_FILIAL, SRA->RA_CIC, OemToAnsi(STR0206) } )//"Não foi possivel encontrar o registro do Funcionário"
				EndIf

				(cAliasQSRA)->(DBSkip())
				Loop
			EndIf

			If !lAglut .Or. nQtdeFol == 1 .Or. SRA->RA_CIC != cCpfOld .Or. cEmp != cEmpOld
				cStatNew := ""
				cOperNew := ""
				cRetfNew := ""
				cRecibAnt:= ""
				cKeyMid	 := ""
				nRecEvt	 := 0
				lNovoRJE := .T.
				aStatT3P := fVerStat( 2, cFilEnv, cPer1210, aClone(aFilInTaf), Nil, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @cRecibAnt, @lNovoRJE, @cKeyMid, lAdmPubl, cTpInsc, cNrInsc, cVersEnvio )
				cStatT3P := aStatT3P[1]
				cRecibo  := If( cVersEnvio >= "9.0", PadR(aStatT3P[2], 23), aStatT3P[2]) //23 digitos
				aStatC91 := fVerStat( 1, cFilEnv, cPer1210, aClone(aFilInTaf), "2", , , , , , , , lAdmPubl, cTpInsc, cNrInsc, cVersEnvio )
				cStatC91 := aStatC91[1] //verifica se existe evento S-1200 anual ref.13
			EndIf

			/*
			±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
			±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
			±±³ Exclusao em lote dos registros            ³±±
			±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
			±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
			If lExcLote
				If cStatT3P $ "4"
					cXml := ""
					cStatNew := ""
					cOperNew := ""
					cRetfNew := ""
					cRecibAnt:= ""
					cKeyMid	 := ""
					nRecEvt	 := 0
					lNovoRJE := .T.
					aDados	 := {}
					InExc3000(@cXml,'S-1210',cRecibo,(cAliasQSRA)->RA_CIC,(cAliasQSRA)->RA_PIS,.T.,"1",cAno+"-"+cMes, (cAliasQSRA)->RA_CATEFD, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cIdXml, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
					GrvTxtArq(alltrim(cXml), "S3000", (cAliasQSRA)->RA_CIC)
					If !lMiddleware
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3000")
					ElseIf Empty(aErros)
						aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecibo, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
						If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
							aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
						EndIf
					EndIf
					If Len( aErros ) > 0
						cMsgErro := ''
						FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
						FormText(@cMsgErro)
						aErros[1] := cMsgErro
						aAdd(aLogsErr, OemToAnsi(STR0046) + OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0029) ) //"[FALHA] "##"Registro de exclusao S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "
						aAdd(aLogsErr, "" )
						aAdd(aLogsErr, aErros[1] )
						If lTSV
							aEmp_1210[4]++ //Inclui TSV nao integrado
						Else
							aEmp_1210[2]++ //Inclui TCV nao integrado
						EndIf
					Else
						If !lMiddleware
							aAdd(aLogsOk, OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0049) ) //##"Registro de exclusao S-1210 do Funcionário: "##" Integrado com TAF."
						Else
							aAdd(aLogsOk, OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0165) ) //##"Registro de exclusao S-1210 do Funcionário: "##" Integrado com TAF."
						EndIf
						aAdd(aLogsOk, "" )
						If lTSV
							aEmp_1210[3]++ //Inclui TSV integrado
						Else
							aEmp_1210[1]++ //Inclui TCV integrado
						EndIf
					Endif
				ElseIf cStatT3P $ "2"
					aAdd(aLogsErr, OemToAnsi(STR0046) + OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0028) ) //"[FALHA] "##"Registro de exclusao S-1210 do Funcionário: "##" desprezado pois está aguardando retorno do governo."
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				ElseIf cStatT3P $ "6|99"
					aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0166) ) //"[AVISO] "##"Registro de exclusao S-1210 do Funcionário: "##" desprezado pois há evento de exclusão pendente para transmissão."
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				ElseIf cStatT3P != "-1"
					aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0048) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0150) ) //"[AVISO] "##"Registro de exclusao S-1210 do Funcionário: "##" desprezado pois não foi transmitido."
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				Else
					aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + (cAliasQSRA)->RA_CIC + " - " + AllTrim((cAliasQSRA)->RA_NOME) + OemToAnsi(STR0151) ) //"[AVISO] "##"Registro S-1210 do funcionario "##" não foi encontrado. A exclusão não poderá ser realizada."
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
				EndIf

				(cAliasQSRA)->(DBSkip())
				Loop
			EndIf

			If !lRelat
				nVldOpcoes := fVldOpcoes(aCheck, cStatT3P)

				If nVldOpcoes == 1
					If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
						aAdd(aCpfDesp, SRA->RA_CIC)
						aAdd(aLogsErr, OemToAnsi(STR0025) + (cAliasSRA)->RA_CIC + " - " + AllTrim((cAliasSRA)->RA_NOME) + OemToAnsi(STR0026) ) //##"Registro S-1210 do Funcionário: "##" não foi sobrescrito."
						aAdd(aLogsErr, "" )
						If lTSV
							aEmp_1210[4]++ //Inclui TSV nao integrado
						Else
							aEmp_1210[2]++ //Inclui TCV nao integrado
						EndIf
					EndIf
					(cAliasQSRA)->(DBSkip())
					Loop
				Elseif nVldOpcoes == 2
					If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
						aAdd(aCpfDesp, SRA->RA_CIC)
						aAdd(aLogsErr, OemToAnsi(STR0025) + (cAliasSRA)->RA_CIC + " - " + AllTrim((cAliasSRA)->RA_NOME) + OemToAnsi(STR0027) ) //##"Registro S-1210 do Funcionário: "##" não foi retificado."
						aAdd(aLogsErr, "" )
						If lTSV
							aEmp_1210[4]++ //Inclui TSV nao integrado
						Else
							aEmp_1210[2]++ //Inclui TCV nao integrado
						EndIf
					EndIf
					(cAliasQSRA)->(DBSkip())
					Loop
				Elseif nVldOpcoes == 3
					If aScan( aCpfDesp, { |x| x == SRA->RA_CIC } ) == 0
						aAdd(aCpfDesp, SRA->RA_CIC)
						aAdd(aLogsErr, OemToAnsi(STR0025) + (cAliasSRA)->RA_CIC + " - " + AllTrim((cAliasSRA)->RA_NOME) + OemToAnsi(STR0028) ) //##"Registro S-1210 do Funcionário: "##" desprezado pois está aguardando retorno do governo."
						aAdd(aLogsErr, "" )
						If lTSV
							aEmp_1210[4]++ //Inclui TSV nao integrado
						Else
							aEmp_1210[2]++ //Inclui TCV nao integrado
						EndIf
					EndIf
					(cAliasQSRA)->(DBSkip())
					Loop
				ElseIf cStatT3P == "99"
					aAdd(aLogsErr, OemToAnsi(STR0025) + (cAliasSRA)->RA_CIC + " - " + AllTrim((cAliasSRA)->RA_NOME) + OemToAnsi(STR0166) ) //##"Registro S-1210 do Funcionário: "##" desprezado pois há evento de exclusão pendente para transmissão."
					aAdd(aLogsErr, "" )
					If lTSV
						aEmp_1210[4]++ //Inclui TSV nao integrado
					Else
						aEmp_1210[2]++ //Inclui TCV nao integrado
					EndIf
					(cAliasQSRA)->(DBSkip())
					Loop
				Endif
			EndIf

			If Select(cAliasSRX) > 0
				(cAliasSRX)->(dbcloseArea())
			EndIf

			If !lAglut .Or. nQtdeFol == 1 .Or. cCPF <> cCpfOld .Or. cEmp != cEmpOld
				aContdmDev	:= {}
				nVlrDep		:= 0
				cCpfOld		:= cCPF
				cNome  		:= Alltrim((cAliasSRA)->RA_NOME)
				cOldFil 	:= (cAliasSRA)->RA_FILIAL
				cOldOcorr	:= (cAliasSRA)->RA_OCORREN
				cEmpOld		:= cEmp
				If cVersEnvio < "9.0" .And. Len( aTabIR ) > 0//testa se existe dados na tabela
					If aTabIR[1] <> 0 .and. VAL((cAliasSRA)->RA_DEPIR) <> 0
						nVlrDep := VAL((cAliasSRA)->RA_DEPIR) * aTabIR[1]
					Endif
				EndIf
				cXml := ""
				If !lMiddleware
					S1210A01(@cXml)
					S1210A02(@cXml, {})
					S1210A03(@cXml, {"1",,Iif(cVersEnvio >= "9.0", Nil, "1"),cAno+"-"+cMes,,,,,}, .T.)
					S1210A05(@cXml, {(cAliasSRA)->RA_CIC}, .F.)
					If( cVersEnvio < "9.0", S1210A06(@cXml, {nVlrDep}, .T.), Nil )
				EndIf
				aAdd(aideBenef, {(cAliasSRA)->RA_CIC, nvlrDep, (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_NOMECMP})
				aDados		:= {}
				aErros		:= {}
				aLogCIC		:= {}
				aDadosRHS	:= {}
				aDadosRHP	:= {}
				lPrimIdT	:= .T.
				cIdeRubr	:= ""
				cCdEFD      := ""
				aIncRes		:= {}
				If !lRelat
					aInfoPgto	:= {}
					aDetPgtoFl	:= {}
					aRetFer		:= {}
					aRetPgtoTot	:= {}
					aRetPensao	:= {}
					aDetPgtoAt 	:= {}
					aPgtoAnt 	:= {}
					aInfoPrev	:= {}
					aDedDep     := {}
					aDepen		:= {}
					aRelRHS   	:= {}
					aRelRHP   	:= {}
				EndIf
			Endif

			If cVersEnvio >= "9.2"
				fGM1210Dep(cFil, cMat, cVersEnvio, @aDepen)

				If Len(aDepen ) > 0 .And. !lMiddleware
					If cCat $ cTSV
						fStatDep(aDepen, (cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_CIC,(cAliasSRA)->RA_CODUNIC, "S2300", SRA->RA_CATEFD, dToS(SRA->RA_ADMISSA) )
					Else
						fStatDep(aDepen, (cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_CIC,(cAliasSRA)->RA_CODUNIC, "S2200")
					Endif
				Endif
			Endif

			If (!lRes .And. __oSt05_1 == Nil) .Or. (lRes .And. __oSt05_2 == Nil)
				If !lRes
					__oSt05_1 := FWPreparedStatement():New()
					cQrySt := "SELECT RD_FILIAL,RD_MAT,RD_DATPGT,RD_SEMANA,RD_PD,RD_SEQ,RD_CC,RD_PERIODO,RD_ROTEIR,RD_VALOR,RD_IDCMPL,'SRD' AS TAB,SRD.R_E_C_N_O_ AS RECNO "
					If lTemNrBen
						cQrySt += ", RD_NRBEN "
					EndIf
				Else
					__oSt05_2 := FWPreparedStatement():New()
					cQrySt := "SELECT DISTINCT RD_FILIAL,RD_MAT,RD_DATPGT,RD_SEMANA,RD_PD,RD_SEQ,RD_CC,RD_PERIODO,RD_ROTEIR,RD_VALOR,RD_IDCMPL,'SRD' AS TAB,SRD.R_E_C_N_O_ AS RECNO  "
					If lTemNrBen
						cQrySt += ", RD_NRBEN "
					Endif
				EndIf
				cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
				cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
				cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
				cQrySt += 		"SRD.RD_MAT = ? AND "
				cQrySt += 		"SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
				cQrySt += 		"SRD.RD_TIPO2 != 'K' AND "
				cQrySt += 		"SRD.RD_EMPRESA = '  ' AND "
				cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
				cQrySt += 		"SRY.RY_TIPO != 'K' AND "
				cQrySt += 		"SRY.RY_FILIAL = ? AND "
				cQrySt += 		"SRY.D_E_L_E_T_ = ' ' AND "
				cQrySt +=		"SRD.RD_PD NOT IN ("
				cQrySt +=			"SELECT SRR.RR_PD "
				cQrySt +=			"FROM " + RetSqlName('SRR') + " SRR "
				cQrySt +=			"WHERE SRR.RR_FILIAL = ? AND "
				cQrySt +=				"SRR.RR_MAT = ? AND "
				cQrySt +=				"SRR.RR_DATAPAG = SRD.RD_DATPGT  AND "
				If !lRes
					cQrySt +=			"SRR.RR_TIPO3 = 'F'  AND "
				EndIf
				cQrySt +=				"SRR.D_E_L_E_T_ = ' ') "
				If cOpcTab == "1" .Or. lRes
					cQrySt += "UNION "
					If !lRes
						cQrySt += "SELECT RC_FILIAL,RC_MAT,RC_DATA,RC_SEMANA,RC_PD,RC_SEQ,RC_CC,RC_PERIODO,RC_ROTEIR,RC_VALOR,RC_IDCMPL,'SRC' AS TAB,SRC.R_E_C_N_O_ AS RECNO "
						If lTemNrBen
							cQrySt += ", RC_NRBEN AS RD_NRBEN "
						EndIf
					Else
						cQrySt += "SELECT DISTINCT RC_FILIAL AS RD_FILIAL,RC_MAT AS RD_MAT,RC_DATA AS RD_DATPGT,RC_SEMANA AS RD_SEMANA,RC_PD AS RD_PD,RC_SEQ AS RD_SEQ,RC_CC AS RD_CC,RC_PERIODO AS RD_PERIODO,RC_ROTEIR AS RD_ROTEIR,RC_VALOR AS RD_VALOR,RC_IDCMPL AS RD_IDCMPL, 'SRC' AS TAB,SRC.R_E_C_N_O_ AS RECNO "
						If lTemNrBen
							cQrySt += ", RC_NRBEN AS RD_NRBEN "
						EndIf
					EndIf
					cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
					cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
					cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
					cQrySt += 		"SRC.RC_MAT = ? AND "
					cQrySt += 		"SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
					cQrySt += 		"SRC.RC_TIPO2 != 'K' AND "
					cQrySt += 		"SRC.D_E_L_E_T_ = ' ' AND "
					cQrySt += 		"SRY.RY_TIPO != 'K' AND "
					cQrySt += 		"SRY.D_E_L_E_T_ = ' ' AND "
					cQrySt +=		"SRC.RC_PD NOT IN ("
					cQrySt +=			"SELECT SRR.RR_PD "
					cQrySt +=			"FROM " + RetSqlName('SRR') + " SRR "
					cQrySt +=			"WHERE SRR.RR_FILIAL = ? AND "
					cQrySt +=				"SRR.RR_MAT = ? AND "
					cQrySt +=				"SRR.RR_DATAPAG = SRC.RC_DATA AND "
					If !lRes
						cQrySt +=			"SRR.RR_TIPO3 = 'F'  AND "
					EndIf
					cQrySt +=				"SRR.D_E_L_E_T_ = ' ') "
				EndIf
				If lRes
					cQrySt += "UNION ALL "
					cQrySt += "SELECT RR_FILIAL,RR_MAT,RR_DATA,RR_SEMANA,RR_PD,RR_SEQ,RR_CC,RR_PERIODO,RR_ROTEIR,RR_VALOR,RR_IDCMPL,'SRR' AS TAB, SRR.R_E_C_N_O_ AS RECNO "
					If lTemNrBen
						cQrySt += ", '' AS RD_NRBEN "
					Endif
					cQrySt += "FROM " + RetSqlName('SRR') + " SRR "
					cQrySt += "WHERE SRR.RR_FILIAL = ? AND "
					cQrySt += 		"SRR.RR_MAT = ? AND "
					cQrySt += 		"SRR.RR_DATAPAG BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
					cQrySt += 		"SRR.RR_TIPO2 != 'K' AND "
					cQrySt += 		"SRR.RR_TIPO3 != 'F' AND "
					cQrySt += 		"SRR.D_E_L_E_T_ = ' ' "
				EndIf
				If lTemNrBen
					cQrySt += "ORDER BY 1, 2, 8, 9, 3, 14, 5"
				Else
					cQrySt += "ORDER BY 1, 2, 8, 9, 3, 5"
				EndIf
				cQrySt := ChangeQuery(cQrySt)
				If !lRes
					__oSt05_1:SetQuery(cQrySt)
				Else
					__oSt05_2:SetQuery(cQrySt)
				EndIf
			EndIf
			If !lRes
				__oSt05_1:SetString(1, cFil)
				__oSt05_1:SetString(2, cMat)
				__oSt05_1:SetString(3, xFilial("SRY", cFil))
				__oSt05_1:SetString(4, cFil)
				__oSt05_1:SetString(5, cMat)
				If cOpcTab == "1"
					__oSt05_1:SetString(6, cFil)
					__oSt05_1:SetString(7, cMat)
					__oSt05_1:SetString(8, cFil)
					__oSt05_1:SetString(9, cMat)
				EndIf
			Else
				__oSt05_2:SetString(1, cFil)
				__oSt05_2:SetString(2, cMat)
				__oSt05_2:SetString(3, xFilial("SRY", cFil))
				__oSt05_2:SetString(4, cFil)
				__oSt05_2:SetString(5, cMat)
				__oSt05_2:SetString(6, cFil)
				__oSt05_2:SetString(7, cMat)
				__oSt05_2:SetString(8, cFil)
				__oSt05_2:SetString(9, cMat)
				__oSt05_2:SetString(10, cFil)
				__oSt05_2:SetString(11, cMat)
			EndIf
			If !lRes
				cQrySt := __oSt05_1:getFixQuery()
			Else
				cQrySt := __oSt05_2:getFixQuery()
			EndIf
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRX,.T.,.T.)

			For nx1 := 1 To len(aStru)
				If aStru[nX1][2] <> "C" .And. FieldPos(aStru[nX1][1])<>0
					TcSetField(cAliasSRX,aStru[nX1][1],aStru[nX1][2],aStru[nX1][3],aStru[nX1][4])
				EndIf
			Next nX1
			dbSelectArea(cAliasSRX)

			//Verifica qual a data de pagamento do roteiro 132 nos casos de funcionários com rescisão calculada em dezembro
			If !Empty(SRA->RA_DEMISSA) .And. SUBSTR(DTOS(SRA->RA_DEMISSA),5,2) == "12" .And. (Empty(dDtPgto) .Or. cKeyProc <> xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES)
				dDtPgto 	:= fGetDtPgto(SRA->RA_FILIAL, SRA->RA_PROCES, AnoMes(SRA->RA_DEMISSA), "01", "132")
				cKeyProc	:= xFilial("RCH", SRA->RA_FILIAL) + SRA->RA_PROCES
			EndIf
			aDmDevBop := {}
			If (cAliasSRX)->(!Eof())
				If aScan( aContdmDev, { |x| x[1] == cFilEnv + ";" + (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT } ) == 0
					aAdd( aContdmDev, { cFilEnv + ";" + (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT } )
				EndIf
				While (cAliasSRX)->(!Eof())
					cTpRot := fGetTipoRot( (cAliasSRX)->RD_ROTEIR )
					cRotBkp:=""
					nPosRes := 0

					// DESCONSIDERA OS ID´S DE DESONERAÇÃO
					If (!lRobo .Or. lSched) .And. RetValSrv((cAliasSRX)->RD_PD, (cAliasSRX)->RD_FILIAL, 'RV_CODFOL') $ "0148|0973"
						(cAliasSRX)->(DBSkip())
						Loop
					EndIf

					If lRes
						If !((cAliasSRX)->RD_PERIODO != cCompete .Or. (cAliasSRX)->RD_DATPGT == dDtRes)
							(cAliasSRX)->(DBSkip())
							Loop
						Endif
					Endif

					//Para competencia anterior a Dezembro, despreza todas as verbas do roteiro 132 que não seja a do líquido (Id 0022)
					If ( SubStr(cCompete, 1, 2) != "12" .And. ( (cAliasSRX)->RD_ROTEIR == "132" .Or. cTpRot == "6" ) ) .And. (cAliasSRX)->RD_PD != cPdCod0021
						(cAliasSRX)->( dbSkip() )
						Loop
					EndIf

					If SubStr(cCompete, 1, 2) == "12" .And. ((cAliasSRX)->RD_ROTEIR == "132" .Or. cTpRot == "6")
						lTem132	:= .T.
					EndIf

					//Terceiro grupo, autonomo regime caixa que não gerou S-1200 na competencia. Não gerar o  S-1210
					//Pessoa Juridica 10/05/2021 e Pessoa Juridica 19/07/2021
					If !Empty(dDcgIni) .And. MesAno(dDcgIni) == "201904" .And. If(!lPesFisica, (cAliasSRX)->RD_PERIODO == "202104",(cAliasSRX)->RD_PERIODO == "202106" ).And. !(StrZero(Month(dDtPgt),2) == Substr((cAliasSRX)->RD_PERIODO,5,2)) ;
						.And. nQtdeFol == 1 .And. (cAliasSRA)->RA_CATEFD $ cTrabSemVinc
						nQtd1200 	:= fQtdS1200(cOpcTab, cPer1210)
						If nQtd1200 == 0    // Não houve movimento no S-1200
							lTercGrp	:= .T.
							(cAliasSRX)->( dbSkip() )
							Exit
						Endif
					Endif

					cFilx   	:= (cAliasSRX)->RD_FILIAL
					cPD     	:= (cAliasSRX)->RD_PD
					cCodFol 	:= RetValSrv( cPD, cFilx, 'RV_CODFOL' )
					cTipoCod 	:= RetValSrv( cPD, cFilx, 'RV_TIPOCOD' )
					cCodINCIRF 	:= RetValSrv( cPD, cFilx, 'RV_INCIRF' )
					cCodAdiant 	:= RetValSrv( cPD, cFilx, 'RV_ADIANTA' )
					cCodFil 	:= RetValSrv( cPD, cFilx, 'RV_FILIAL' )
					lAchou063	:= .F.
					cCodNat 	:= RetValSrv( cPD, cFilx, 'RV_NATUREZ' )

					//Verifica se a verba é gerada por código correspondente e é do tipo base:
					lCodCorr	:= fCodCorr(xFilial("SRV", cFilx), cPD) .And. cTipoCod $ "3*4"

					//Identifica pela incidência IRF se os dados de informações complementares é obrigatório
					If cVersEnvio >= "9.3"
						For nX := 1 to Len(aIncIRComp)
							If aScan( aIncIRComp[nX][3], {|x| x == cCodINCIRF } ) > 0 .And. cTipoCod $ "1*2"
								aIncIRComp[nX][2] := .T. //Indica que o grupo passou a ser obrigatório
								aAdd(aIncIRComp[nX][5], cPD)
							EndIf
						Next nX
					EndIf

					//Desprezar verbas geradas no fechamento dos roteiros ADI/FOL, desconto do arredondamento de férias/folha, dedução para férias/abono no S-1200, férias/abono pagos mês anterior ou período superior ao escolhido
					If cCodFol $ "0012/0106/0107/0105/1562/1722/1723/0044/0164/1449/0029/0300/0025/0082/0088/0090/0092/0096/0094/0095/0097/0098/0099/1893/0007/0008/0838/0839" .Or. (cAliasSRX)->RD_PERIODO > SubStr(cCompete,3,4)+SubStr(cCompete,1,2) .Or. lCodCorr

						If lRes .And. cTpRot == "4"
							dbSelectArea("SRG")
							SRG->( dbSetOrder(1) )
							If SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + dToS((cAliasSRX)->RD_DATPGT) ) )
								If AnoMes(SRG->RG_DATAHOM) > cAno+cMes
									lPgtRes := .F.
								EndIf
							EndIf
						EndIf
						(cAliasSRX)->( dbSkip() )
						Loop
					EndIf

					If lRes .And. !(cTpRot $ "4/6") // Se tiver rescisão no mês a data de pagamento será a data de pagamento do roteito para que os ideDmDev fiquem iguais no S-1200 e S-1210
						//Se for a verba de INSS Patronal e for no mesmo período da rescisão, significa que é a verba de desoneração gerada para rescisão
						If cCodFol == "0148" .And. cPerRes+cSemRes == (cAliasSRX)->RD_PERIODO+(cAliasSRX)->RD_SEMANA
							cTpRot  := "4"
							dDtPgt  := (cAliasSRX)->RD_DATPGT
						Else
							dDtPgt  := StoD(fVerDtPgto( dToS((cAliasSRX)->RD_DATPGT), , , cAliasSRX))
						EndIf
					Elseif (lRes .And. cTpRot == "4" ) .Or.;      									//Rescisao complementar outro periodo
					(lResComPLR .And. cTpRot == "1" .And. !Empty((cAliasSRA)->RA_DEMISSA) .And. AnoMes((cAliasSRA)->RA_DEMISSA ) < (cAliasSRX)->RD_PERIODO )

						dbSelectArea("SRG")
						SRG->( dbSetOrder(1) )
						lAchouSRG := SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + dToS((cAliasSRX)->RD_DATPGT) ) )
						If !lAchouSRG
							SRG->( dbSetOrder(2) ) //RG_FILIAL+RG_MAT+RG_ROTEIR+DTOS(RG_DATAHOM)
							lAchouSRG := SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + "RES" + dToS((cAliasSRX)->RD_DATPGT) ) )
						EndIf
						If lAchouSRG
							dDtPgt 		:= SRG->RG_DATAHOM
							cTpRes 		:= SRG->RG_RESCDIS
							If Empty(cUltTpRes)
								cUltTpRes	:= SRG->RG_RESCDIS
								cDtGerRes	:= AnoMes(SRG->RG_DTGERAR)
							ElseIf SRG->RG_RESCDIS != cUltTpRes .And. cUltTpRes == "0" .And. SRG->RG_RESCDIS $ "1|2" .And. AnoMes(SRG->RG_DTGERAR) > cDtGerRes
								cUltTpRes	:= SRG->RG_RESCDIS
								cDtGerRes	:= AnoMes(SRG->RG_DTGERAR)
								lRes		:= .F.
								lResOriCom	:= .T.
							EndIf
							If AnoMes(dDtPgt) > cAno+cMes
								lPgtRes := .F.
								(cAliasSRX)->( dbSkip() )
								Loop
							EndIf
							If lRes .And. cTpRot == "4" .And.  !Empty((cAliasSRA)->RA_DEMISSA)
								cCdEFD := FM40TpRes(SRG->RG_TIPORES, NIL, NIL, (cAliasSRA)->RA_DEMISSA)
							Endif

							If cCdEFD == "44"  //Caso o roteiro seja RES, tenha demissão e o motivo 44 não deve gerar o grupo <infoPgto> 
								(cAliasSRX)->(dbSkip())
								Loop
							Endif	
						EndIF
					else
						If cTpRot  <> "4"
							dDtPgt  := (cAliasSRX)->RD_DATPGT
						Endif
					EndIf

					cPeriodo	:= (cAliasSRX)->RD_PERIODO
					cRoteiro	:= (cAliasSRX)->RD_ROTEIR
					cPer		:= substr(cPeriodo,1,4)+"-"+substr(cPeriodo,5,2)
					cPer132		:= substr(cPeriodo,1,4)
					dDtPgtRR 	:= dDtPgt
					nValor		:= (cAliasSRX)->RD_VALOR

					//Obtém o prefixo se utilizado o novo ideDmDev
					If lNewDmDev .And. ( Empty(cCodChave) .Or. cCodChave <> cFilx + (cAliasSRX)->RD_MAT + (cAliasSRX)->RD_PERIODO + (cAliasSRX)->RD_SEMANA + (cAliasSRX)->RD_ROTEIR)
						cCodChave	:= cFilx + (cAliasSRX)->RD_MAT + (cAliasSRX)->RD_PERIODO + (cAliasSRX)->RD_SEMANA + (cAliasSRX)->RD_ROTEIR
						cPrefixo	:= fGetPrefixo(SRA->RA_FILIAL, SRA->RA_MAT, cPeriodo, SRA->RA_CIC, .F.)
					EndIf

					If lResOriCom .And. cTpRot == "4"
						If (cAliasSRA)->RA_CATFUNC $ "P*A"
							cTpRot 	:= "9"
							cRoteiro:= fGetCalcRot("9")
						Else
							cTpRot 	:= "1"
							cRoteiro:= fGetRotOrdinar()
						EndIf
					EndIf

					If lVer546 .And. (cRoteiro == "ADI" .Or. cTpRot == "2")
						lGera546	:= lTem546(cFil,cMat,cDtPesqI,cDtPesqF,cPdCod546)
						lVer546 	:= .F.
					EndIf

					If cTipoCod $ "2/4"
						nValor *= (-1)
					EndIf

					cPdLiq := cCodFol

					If cCodFol == "0066"//I.R.
						nValor *= (-1)
						SRD->( dbSetOrder(6) )//RD_FILIAL+RD_MAT+RD_PD+RD_ROTEIR+DTOS(RD_DATPGT)
						SRC->( dbSetOrder(8) )//RC_FILIAL+RC_MAT+RC_PD+RC_ROTEIR+DTOS(RC_DATA)
						For nContRot := 1 To Len(aRotADI)
							If SRD->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotADI[nContRot]+AnoMes(dDtPgt) ) )//Ded. Residuo IR pago
								While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_PD+SRD->RD_ROTEIR+AnoMes(SRD->RD_DATPGT) == SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotADI[nContRot]+AnoMes(dDtPgt)
									nValor -= SRD->RD_VALOR
									If nValor <= 0
										(cAliasSRX)->( dbSkip() )
										lAchou063 := .T.
										Exit
									EndIf
									SRD->( dbSkip() )
								EndDo
							EndIf
							If !lAchou063 .And. SRC->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotADI[nContRot]+AnoMes(dDtPgt) ) )//Ded. Residuo IR pago
								While SRC->( !EoF() ) .And. SRC->RC_FILIAL+SRC->RC_MAT+SRC->RC_PD+SRC->RC_ROTEIR+AnoMes(SRC->RC_DATA) == SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotADI[nContRot]+AnoMes(dDtPgt)
									nValor -= SRC->RC_VALOR
									If nValor <= 0
										(cAliasSRX)->( dbSkip() )
										lAchou063 := .T.
										Exit
									EndIf
									SRC->( dbSkip() )
								EndDo
							EndIf
						Next nCont
						If !lAchou063
							For nContRot := 1 To Len(aRotFOL)
								If SRD->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotFOL[nContRot]+AnoMes(dDtPgt) ) )//Ded. Residuo IR pago
									While SRD->( !EoF() ) .And. SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_PD+SRD->RD_ROTEIR+AnoMes(SRD->RD_DATPGT) == SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotFOL[nContRot]+AnoMes(dDtPgt)
										nValor -= SRD->RD_VALOR
										If nValor <= 0
											(cAliasSRX)->( dbSkip() )
											lAchou063 := .T.
											Exit
										EndIf
										SRD->( dbSkip() )
									EndDo
								EndIf
								If !lAchou063 .And. SRC->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotFOL[nContRot]+AnoMes(dDtPgt) ) )//Ded. Residuo IR pago
									While SRC->( !EoF() ) .And. SRC->RC_FILIAL+SRC->RC_MAT+SRC->RC_PD+SRC->RC_ROTEIR+AnoMes(SRC->RC_DATA) == SRA->RA_FILIAL+SRA->RA_MAT+aCodFol[63, 1]+aRotFOL[nContRot]+AnoMes(dDtPgt)
										nValor -= SRC->RC_VALOR
										If nValor <= 0
											(cAliasSRX)->( dbSkip() )
											lAchou063 := .T.
											Exit
										EndIf
										SRC->( dbSkip() )
									EndDo
								EndIf
							Next nCont
						EndIf
						If lAchou063
							Loop
						EndIf
						nValor *= (-1)
					EndIf

					If lRes .And. (cTpRot $ "1/2/5/9/F" .Or. (cTpRot == "6" .And. !(SUBSTR(DTOS(SRA->RA_DEMISSA),5,2) == "12" .And. SRA->RA_DEMISSA >= dDtPgto .Or. (SRA->RA_DEMISSA < dDtPgto .And. cStatC91 <> "-1")))) .And. cPerRes == cPeriodo .Or. cTpRot == "4"

						// Empresa do 3o grupo possui rescisão no mês que inicia a obrigatoriedade do envio de periódicos
						If !Empty(dDcgIni) .And. MesAno(dDcgIni) == "201904" .And. If(!lPesFisica, (cPeriodo == "202105" .And. MesAno(SRA->RA_DEMISSA) == "202105" .And. SRA->RA_DEMISSA < CtoD("10/05/2021") ), (cPeriodo == "202107" .And. MesAno(SRA->RA_DEMISSA) == "202107" .And. SRA->RA_DEMISSA < CtoD("19/07/2021")))
							l3GRescMes := .T.
						EndIf
						IF ( !Empty(dDcgIni) .And. (MesAno(MonthSum(dDcgIni, IIF(Month(dDcgIni) == 3, 1,2)  )) == cPeriodo) .Or. ( MesAno(dDcgIni) == "201904" .And. If(!lPesFisica, cPeriodo <= "202104",cPeriodo <= "202106" ) ) ) .Or. l3GRescMes
							cTpPgto := "9"

							IF cTpRot == "4"
								dbSelectArea("SRG")
								SRG->( dbSetOrder(1) )
								If SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + dToS(dDtPgt) ) )
									dDtPgt := SRG->RG_DATAHOM
								EndIF
							ENDIF
						ELSE
							If lTSV
								If cVersEnvio < "9.0.00" .Or. SRA->RA_CATEFD == "721"
									cTpPgto := "3"
								Else
									cTpPgto := "1"
									If cVersEnvio >= "9.0.00" .And. lOrig1202 .And. lCatEst
										cTpPgto := "4"
									Endif
								EndIf
							Else
								cTpPgto := "2"
							Endif
						ENDIF

						If cTpRot == "4"
							If dDtPgt != dlastDate .Or. (cTpRot != cLastRot .And. Left(cideDmDev, 1) != "R")
								nPosRes := aScan(aResS1210, { |x| x[2] == dDtPgt })
								If nPosRes > 0
									nContRes := aResS1210[nPosRes, 3]
								EndIf
								cideDmDev := "R" + cEmpAnt + Alltrim(xFilial("SRA", (cAliasSRA)->RA_FILIAL)) + (cAliasSRA)->RA_MAT + If(cTpRes == "3", "C", "") + If(Empty(nContRes), (++nContRes, ""), cValToChar(nContRes++))
							EndIf
						Else
							//O ADI deve ser gerado com o cTpPgto 2 e o ID da DmDev deve ficar igual ao que foi gerado para o ADI no desligamento
							If Empty(cPrefixo)
								cideDmDev := cFilx + dtos(dDtPgt) + cPeriodo + cRoteiro + If(lAmbosEve, "RPPS", "")
							Else
								cideDmDev := cPrefixo + dtos(dDtPgt) + cPeriodo + cRoteiro + If(lAmbosEve, "RPPS", "")
							EndIf
						EndIf
						cLastRot  := cTpRot
						dlastDate := dDtPgt
					Else
						If ( !Empty(dDcgIni) .And. (MesAno(MonthSum(dDcgIni, IIF(Month(dDcgIni) == 3, 1,2)  )) == cPeriodo  .Or. ( MesAno(dDcgIni) == "201904" .And.  If(!lPesFisica, cPeriodo <= "202104", cPeriodo <= "202106") ))  .And. !(StrZero(Month(dDtPgt),2) == Substr(cPeriodo,5,2)) )
							cTpPgto := "9"
						Else
							cTpPgto := "1"
							If cVersEnvio >= "9.0.00"
								If lOrig1207 .And. ((cAliasQSRA)->RA_CATFUNC == "9" .Or. (cAliasQSRA)->RA_EAPOSEN == "1" ) .And. !Empty((cAliasQSRA)->RA_DTENTRA)
									cTpPgto := "5"
								ElseIf lOrig1202 .And. lCatEst
									cTpPgto := "4"
								EndIf
							Endif
						EndIf

						//Verifica se mes anterior ocorreu pagamento como Multv. Funcionario demitido e admitido no mesmo periodo. Regime Caixa
						If lAglut .And. nQtdeFol == 1 .And. If( cTpRot == "1", cPeriodo <= MesAno(dDtPgt), .T.) .And. cPeriodo != cPerOld1 .And. Empty(cPrefixo)
							cPerOld1	:= cPeriodo
							nQtdMesAnt	:= fQtdS1200(cOpcTab, cPeriodo, cRoteiro,.T.)
						Endif

						//Ajusta a veriável cRoteiro para RRA quando executar a verba de líquido RRA
						If cPdLiq == "0977" .And. lGeraRRA
							cRotBkp := cRoteiro
							cRoteiro := "RRA"
						EndIf

						lAltdmDev := .T.
						If lAglut .And. Empty(cPrefixo) .And. ((cAliasSRA)->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFol > 1 .Or. (nQtdeFol >= 1 .And. nQtdeFol < nQtdMesAnt) ) //MultV
							//Funcionario demitido e admitido no mesmo periodo. Regime competencia
							If lAglut .And. nQtdeFol > 1 .And. If( cTpRot $ "1|2|5|9", cPeriodo == MesAno(dDtPgt), .F.)
								If 	cRotAnt <> cRoteiro
									cRotAnt   := cRoteiro
									__oSt17_1 := Nil
								Endif
								nQtdeFolMV	:= fQtdS1200(cOpcTab, cPeriodo, cRoteiro,.T.)
							Endif

							If nQtdeFol > 1 .And. cPeriodo != cPerOld
								cPerOld	 	:= cPeriodo
								nQtdeFolMV 	:= fQtdS1200(cOpcTab, cPeriodo, cRoteiro)
							EndIf
							If (cAliasSRA)->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFolMV > 1 .AND. !lResComPLR
								If cVersEnvio >= "9.0.00" .And. nQtdMesAnt == 1 .And. nQtdeFolMV <= 1
									cideDmDev := cFilx + dtos(dDtPgt) + cPeriodo + cRoteiro
								Else
									cideDmDev := cFilx + (cAliasSRX)->RD_MAT + SubStr( dtos(dDtPgt), 3 ) + SubStr( cPeriodo, 3 ) + cRoteiro
								EndIf
								cideDmDev += If(lAmbosEve, "RPPS", "")
								lAltdmDev := .F.
								If Len(cideDmDev) > 30
									cideDmDev := cFilx + (cAliasSRX)->RD_MAT + SubStr( dtos(dDtPgt), 7 ) + fGetTipoRot( cRoteiro )
								EndIf
							ElseIf lResComPLR .And. !lDtPgto
								cideDmDev := cFilx + (cAliasSRX)->RD_MAT + SubStr( fVerDtPgto( dToS((cAliasSRX)->RD_DATPGT), , , cAliasSRX), 3, 7) + SubStr(cPeriodo, 3) + cRoteiro
							ElseIf nQtdeFol < nQtdMesAnt
								cideDmDev := cFilx + (cAliasSRX)->RD_MAT + SubStr( dtos(dDtPgt), 3 ) + SubStr( cPeriodo, 3 ) + cRoteiro
							Else
								cideDmDev := cFilx + dtos(dDtPgt) + cPeriodo + cRoteiro
							EndIf
						ElseIf lResComPLR .And. !lDtPgto
							cideDmDev := If(Empty(cPrefixo), cFilx, cPrefixo) + fVerDtPgto( dToS((cAliasSRX)->RD_DATPGT), , , cAliasSRX) + cPeriodo + cRoteiro
						ElseIf cVersEnvio >= "9.0.00" .And. lTSV .And. (ANOMES(SRA->RA_DEMISSA) == cPeriodo) .And. (cRoteiro $ "FOL*AUT" .And. (SRA->RA_CATEFD $ cTSV .And. SRA->RA_CATEFD <> "721")  )
							cideDmDev := "R" + cEmpAnt + Alltrim((cAliasSRX)->RD_FILIAL) + (cAliasSRX)->RD_MAT
						Else
							cideDmDev := If(Empty(cPrefixo), cFilx, cPrefixo) + dtos(dDtPgt) + cPeriodo + cRoteiro
						EndIf
						cideDmDev += If(lAltdmDev .And. lAmbosEve, "RPPS", "")

						//Retorno o valor de cRoteiro
						If cPdLiq == "0977" .And. lGeraRRA
							cRoteiro := cRotBkp
						EndIf

					Endif

					// Tratamento cideDmDev para roteiro BOP
					If cVersEnvio >= "9.0.00" .And. lOrig1207 .And. cRoteiro == "BOP" .And. cPdLiq == "0047" .And. cTpRot == "O"
						If (nDm := aScan( aDmDevBop, { |x| x[1] == cideDmDev } )) == 0
							aAdd(aDmDevBop, {cideDmDev, "1"})
						Else
							cideDmDev += aDmDevBop[nDm][2]
							aDmDevBop[nDm][2] := Soma1(aDmDevBop[nDm][2])
						EndIf
					EndIf

					If cPdLiq == "0977" .And. lGeraRRA .And. cRoteiro == "RES"
						If( nPdetPGtoFl := aScan( adetPgtoFl, { |x| x[7] == dToS(dDtPgt) + cTpPgto .And. x[2] == ("DRRA"+cEmpAnt + Alltrim(xFilial("SRA", (cAliasSRA)->RA_FILIAL)) + (cAliasSRA)->RA_MAT) .And. x[8] == (cAliasSRA)->RA_CIC } )) == 0
							aAdd( adetPgtoFl, {cPer, "DRRA"+cEmpAnt + Alltrim(xFilial("SRA", (cAliasSRA)->RA_FILIAL)) + (cAliasSRA)->RA_MAT ,  Nil, (cAliasSRX)->RD_VALOR, Iif(lMiddleware .And. (cTpPgto $ "2/3" .Or. cRoteiro == "RES" .Or. cTpRot == "4"), cRecResc, Nil), "N", dToS(dDtPgt) + cTpPgto, (cAliasSRA)->RA_CIC, (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_CODUNIC, (cAliasSRA)->RA_NOMECMP, (cAliasSRA)->RA_FILIAL, 0 } )
						Endif
					Endif
					If cTpPgto <> "9" 
						nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == dtos(dDtPgt) .And. x[2] == cTpPgto .And. x[5] == (cAliasSRA)->RA_CIC } )
						If nPInfoPgto == 0
							If Left(cideDmDev, 1) == "R"
								dbSelectArea("SRG")
								SRG->( dbSetOrder(1) ) //RG_FILIAL+RG_MAT+DTOS(RG_DTGERAR)
								If SRG->( dbSeek( cFilx + (cAliasSRX)->RD_MAT + dToS((cAliasSRX)->RD_DATPGT) ) )
									dDtPgtRR := SRG->RG_DATAHOM
									//Em caso de retificação utiliza o período da rescisão original
									If SRG->RG_RESCDIS == "3"
										cPer := Year2Str(SRG->RG_DATADEM)+"-"+Month2Str(SRG->RG_DATADEM)
									EndIf
								EndIF
							EndIf
							aAdd( aInfoPgto, { dtos(dDtPgt), cTpPgto ,If(lResidExt, "N", "S"), "1", (cAliasSRA)->RA_CIC } )
						EndIf
						nPdetPGtoFl := aScan( adetPgtoFl, { |x| x[7] == dToS(dDtPgt) + cTpPgto .And. x[2] == cideDmDev .And. x[8] == (cAliasSRA)->RA_CIC } )
						If nPdetPGtoFl == 0
							aAdd( adetPgtoFl, { If(cTpPgto $ "2/3" .Or. (cRoteiro == "RES" .Or. cTpRot == "4"),If(cVersEnvio >= "9.0", cPer, Iif(!lMiddleware, "", Nil)), If(SubStr(cCompete, 1, 2) == "12" .And. (cRoteiro == "132" .Or. cTpRot == "6"), cPer132, cPer)), cideDmDev, Iif(cVersEnvio < "9.0", "S", Nil), 0, Iif(lMiddleware .And. (cTpPgto $ "2/3" .Or. cRoteiro == "RES" .Or. cTpRot == "4"), cRecResc, Nil), "N", dToS(dDtPgt) + cTpPgto, (cAliasSRA)->RA_CIC, (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_CODUNIC, (cAliasSRA)->RA_NOMECMP, (cAliasSRA)->RA_FILIAL, 0} )
						EndIf
					EndIf

					//Cria o array adetPgtoFl para gerar RRA
					If cPdLiq == "0977" .And. lGeraRRA .And. (cRoteiro == "FOL" .Or. cTpRot $ "1")
						nPdetPGtoFl := aScan( adetPgtoFl, { |x| x[7] == dToS(dDtPgt) + cTpPgto .And. x[2] == cideDmDev .And. x[8] == (cAliasSRA)->RA_CIC } )
						If nPdetPGtoFl > 0
							adetPgtoFl[nPdetPGtoFl, 4] += (cAliasSRX)->RD_VALOR
						EndIf
					EndIf

					nPdetPGtoFl := aScan( adetPgtoFl, { |x| x[7] == dtos(dDtPgt) + cTpPgto .And. x[2] == cideDmDev .And. x[8] == (cAliasSRA)->RA_CIC } )
					If nPdetPGtoFl > 0
						If cPdLiq == "0126" .Or. (!(cTpPgto $ "2/3") .And. cPdLiq == "0303" .And. !lMesResTSV) .Or. (cPdLiq == "0021" .And. (cRoteiro == "132" .Or. cTpRot == "6")) .Or. (cPdLiq == "0678" .And. (cRoteiro == "131" .Or. cTpRot == "5"))
							adetPgtoFl[nPdetPGtoFl, 4] += (cAliasSRX)->RD_VALOR
							lPgtRes := .F.
						Elseif ((lGera546 .And. (cRoteiro == "ADI" .Or. cTpRot == "2")) .Or. !(cRoteiro == "ADI" .Or. cTpRot == "2")) .And. ((cPdLiq == "0047" .And. cTpRot != "N" ) .Or. cPdLiq == "0836" .Or. ( cPdLiq == "0546" .And. (cRoteiro == "ADI" .Or. cTpRot == "2") ) ) //proteger, pois pode ter iniciado e varrer dentre os registros SRD´s que nao sejam 0047
							adetPgtoFl[nPdetPGtoFl, 4] += (cAliasSRX)->RD_VALOR
							If cPdLiq == "0836"
								lPgtRes := .F.
							EndIf
						Elseif !lGera546 .And. (cRoteiro == "ADI" .Or. cTpRot == "2") .And. (cCodAdiant == "S" .Or. cCodFol == "0045") .And. cPdLiq != "0151"
							If cTipoCod  == '1'
								adetPgtoFl[nPdetPGtoFl, 4] += (cAliasSRX)->RD_VALOR
							ElseIf cTipoCod  == '2'
								adetPgtoFl[nPdetPGtoFl, 4] -= (cAliasSRX)->RD_VALOR
							EndIf
							lPgtRes := .F.
						ElseIf lRes .And. (cRoteiro == "RES" .Or. cTpRot == "4") .And. AnoMes(dDtRes) > cAno+cMes
							lPgtRes := .F.
						EndIf
						If !Empty((cAliasSRX)->RD_IDCMPL)
							adetPgtoFl[nPdetPGtoFl, 6] := "S"
						EndIf
						//Deduz valor do líquido RRA da folha
						If cPdLiq == "0977" .And. lGeraRRA .And. (cRoteiro $ "FOL|RES" .Or. cTpRot $ "1|4")
							nPosFOL := aScan( adetPgtoFl, { |x| x[7] == dToS(dDtPgt) + cTpPgto .And. If( (cRoteiro == "RES" .Or. cTpRot == "4"), "R" == Left(x[2],1), StrTran(cideDmDev, "RRA", cRoteiro) == x[2]).And. x[8] == (cAliasSRA)->RA_CIC } )
							If nPosFOL > 0
								adetPgtoFl[nPosFOL, 4] -= (cAliasSRX)->RD_VALOR
							Endif
						EndIf
					EndIf

					//Ajusta posição do demonstrativo que guarda o valor de dedução do IRRF
					If cVersEnvio >= "9.3" .And. nPdetPGtoFl > 0 .And. cCodINCIRF $ "31|32|33|34|35"
						adetPgtoFl[nPdetPGtoFl, 12] += Iif(cTipoCod $ '2*4', (cAliasSRX)->RD_VALOR, (cAliasSRX)->RD_VALOR * -1)
					EndIf
	
					If cVersEnvio >= "9.2"
						If (VAL(cCodINCIRF ) >=  51 .And. VAL(cCodINCIRF ) <= 55) .Or. (VAL(cCodINCIRF ) >= 9051 .And. VAL(cCodINCIRF ) <= 9054)
							fBenefic( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, dDtPgt, cPd, nValor, cideDmDev, cPeriodo, cCodINCIRF, lTSV, (cAliasSRA)->RA_CIC )
						EndIf
						If (Val(cCodINCIRF) >= 46 .And. Val(cCodINCIRF) <= 48) .Or. (Val(cCodINCIRF) >= 61 .And. Val(cCodINCIRF) <= 66) .Or. (Val(cCodINCIRF) >= 9046 .And. Val(cCodINCIRF) <= 9048) .Or. (Val(cCodINCIRF) >= 9061 .And. Val(cCodINCIRF) <= 9066)
							fGetPrev( cPd, cPeriodo, cCodINCIRF, nValor, lTSV )
						EndIf
						If  Empty(aDedDep) .Or. (Len(aDedDep) > 0 .And. ascan(aDedDep,{ |x| X[1]==(cAliasSRA)->RA_FILIAL .And. X[2]==(cAliasSRA)->RA_MAT })== 0 )
							aDedDep := fDedDep((cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, Substr(cCompete, 3, 4) + Substr(cCompete, 1, 2), lTSV, (cAliasSRA)->RA_CIC)
						Endif

						If cCodNat == '9219' .And. Empty(aDadosRHS)
							adadosRHS := fGetPLS1210( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT , cOpcTab, cDtPesqI, cDtPesqF, cPeriodo, lRes, MesAno(dDtRes), (cAliasSRA)->RA_CIC, @aLogsErr, @lAborta, @aLogErrDep )
							If lRelat
								For nX := 1 To Len(aDadosRHS)
									aAdd(aRelRHS, aClone(aDadosRHS[nX]))
								Next nX
							EndIf
						EndIf
						If cCodNat ==  '1405' .And. Empty(aDadosRHP)
							adadosRHP := fGetRCop1210( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT , cOpcTab, cDtPesqI, cDtPesqF, cPeriodo, lRes, MesAno(dDtRes), (cAliasSRA)->RA_CIC, lRelat )
							If lRelat
								For nX := 1 To Len(aDadosRHP)
									aAdd(aRelRHP, aClone(aDadosRHP[nX]))
								Next nX
							EndIf
						EndIf
					Endif

					(cAliasSRX)->(dbSkip())
				EndDo//cAliasSRX
			EndIf

			If cVersEnvio < "9.0" .Or. cTpPgto <> "9"
				cTpPgtoBkp := ""
				If SubStr(cCompete, 1, 2) == "12" .And. !lTem132
					cDtIni := SubStr(cCompete,3,4)+"0101"
					cDtFim := SubStr(cCompete,3,4)+"1130"
					If Select( cAliasSRX ) > 0
						(cAliasSRX)->( dbCloseArea() )
					EndIf

					If __oSt06 == Nil
						__oSt06 := FWPreparedStatement():New()
						cQrySt := "SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_DATPGT, SRD.RD_SEMANA, SRD.RD_PD, SRD.RD_SEQ, SRD.RD_CC, SRD.RD_PERIODO, SRD.RD_ROTEIR, SRD.RD_VALOR, 'SRD' AS TAB, SRD.R_E_C_N_O_  AS RECNO "
						cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
						cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRy + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO "
						cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
						cQrySt += 		"SRD.RD_MAT = ? AND "
						cQrySt += 		"SRD.RD_DATPGT BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' AND "
						cQrySt += 		"SRD.RD_EMPRESA = '  ' AND "
						cQrySt += 		"SRY.RY_TIPO = '6' AND "
						cQrySt += 		"SRD.D_E_L_E_T_ = ' ' AND "
						cQrySt += 		"SRY.D_E_L_E_T_ = ' ' "
						If cOpcTab == "1"
							cQrySt += "UNION ALL "
							cQrySt += "SELECT SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_DATA, SRC.RC_SEMANA, SRC.RC_PD, SRC.RC_SEQ, SRC.RC_CC, SRC.RC_PERIODO, SRC.RC_ROTEIR, SRC.RC_VALOR, 'SRC' AS TAB, SRC.R_E_C_N_O_  AS RECNO "
							cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
							cQrySt += "INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
							cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
							cQrySt += 		"SRC.RC_MAT = ? AND "
							cQrySt += 		"SRC.RC_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' AND "
							cQrySt += 		"SRY.RY_TIPO = '6' AND "
							cQrySt += 		"SRC.D_E_L_E_T_ = ' ' AND "
							cQrySt += 		"SRY.D_E_L_E_T_ = ' ' "
						EndIf
						cQrySt += "ORDER BY 1, 2, 8, 9, 3, 5"
						cQrySt := ChangeQuery(cQrySt)
						__oSt06:SetQuery(cQrySt)
					EndIf
					__oSt06:SetString(1, cFil)
					__oSt06:SetString(2, cMat)
					If cOpcTab == "1"
						__oSt06:SetString(3, cFil)
						__oSt06:SetString(4, cMat)
					EndIf
					cQrySt := __oSt06:getFixQuery()
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRX,.T.,.T.)

					TCSetField( cAliasSRX, "RD_DATPGT", "D", 8, 0 )

					If (cAliasSRX)->(!Eof())
						If aScan( aContdmDev, { |x| x[1] == cFilEnv + ";" + (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT } ) == 0
							aAdd( aContdmDev, { cFilEnv + ";" + (cAliasSRA)->RA_FILIAL+(cAliasSRA)->RA_MAT } )
						EndIf
						If !Empty(dDtPgto) .And. !Empty((cAliasSRA)->RA_DEMISSA) .And. SUBSTR(DTOS((cAliasSRA)->RA_DEMISSA),5,2) == "12" .And. ((cAliasSRA)->RA_DEMISSA >= dDtPgto .Or. ((cAliasSRA)->RA_DEMISSA < dDtPgto .And. cStatC91 <> "-1"))
							cTpPgtoBkp := cTpPgto
							cTpPgto := "1"
						EndIf
						While (cAliasSRX)->(!Eof())
							cFilx   	:= (cAliasSRX)->RD_FILIAL
							cPD     	:= (cAliasSRX)->RD_PD
							dDtPgt  	:= sToD(SubStr(cCompete,3,4)+"1201")
							cPeriodo	:= (cAliasSRX)->RD_PERIODO
							cRoteiro	:= (cAliasSRX)->RD_ROTEIR
							//<perRef> - Se tpPgto = [2, 3], informar o mês/ano da data de desligamento (ou de término), no formato AAAA-MM
							If cTpPgto $ "2|3" .And. !Empty((cAliasSRA)->RA_DEMISSA)
								cPer	:= Year2Str((cAliasSRA)->RA_DEMISSA) + "-" + Month2Str((cAliasSRA)->RA_DEMISSA)
							Else
								cPer	:= substr(cPeriodo,1,4)
							EndIf

							cCodFol 	:= RetValSrv( cPD, cFilx, 'RV_CODFOL' )
							cTipoCod 	:= RetValSrv( cPD, cFilx, 'RV_TIPOCOD' )
							cCodINCIRF 	:= RetValSrv( cPD, cFilx, 'RV_INCIRF' )
							cCodAdiant 	:= RetValSrv( cPD, cFilx, 'RV_ADIANTA' )
							cCodFil 	:= RetValSrv( cPD, cFilx, 'RV_FILIAL' )
							cCodNat 	:= RetValSrv( cPD, cFilx, 'RV_NATUREZ' )

							//Identifica pela incidência IRF se os dados de informações complementares é obrigatório
							If cVersEnvio >= "9.3"
								For nX := 1 to Len(aIncIRComp)
									If aScan( aIncIRComp[nX][3], {|x| x == cCodINCIRF } ) > 0 .And. cTipoCod $ "1*2"
										aIncIRComp[nX][2] := .T. //Indica que o grupo passou a ser obrigatório
										aAdd(aIncIRComp[nX][5], cPD)
									EndIf
								Next nX
							EndIf

							nValor	:= (cAliasSRX)->RD_VALOR
							If cTipoCod $ "2/4"
								nValor *= (-1)
							EndIf

							cPdLiq := cCodFol

							//Busca o prefixo para geração do novo IdDmDev
							If lNewDmDev .And. ( Empty(cCodChave) .Or. cCodChave <> cFil + cMat + cPeriodo + cRoteiro )
								cCodChave	:= cFil + cMat + cPeriodo + cRoteiro
								cPrefixo	:= fGetPrefixo(cFil, cMat, cPeriodo, (cAliasSRA)->RA_CIC, .F.)
							EndIF

							cideDmDev := If(Empty(cPrefixo), cFilx, cPrefixo) + dtos((cAliasSRX)->RD_DATPGT) + cPeriodo + cRoteiro

							nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == dtos(dDtPgt) .And. x[2] == cTpPgto .And. x[5] == (cAliasSRA)->RA_CIC } )
							If nPInfoPgto == 0
								aAdd( aInfoPgto, { dtos(dDtPgt), cTpPgto ,If(lResidExt, "N", "S"), "1", (cAliasSRA)->RA_CIC } )
							EndIf

							nPdetPGtoFl := aScan( adetPgtoFl, { |x| x[7] == dToS(dDtPgt) + cTpPgto .And. x[2] == cideDmDev .And. x[8] == (cAliasSRA)->RA_CIC } )
							If nPdetPGtoFl == 0
								aAdd( adetPgtoFl, { cPer, cideDmDev, Iif(cVersEnvio < "9.0", "S", Nil), 0, Nil, "N", dToS(dDtPgt) + cTpPgto, (cAliasSRA)->RA_CIC, (cAliasSRA)->RA_MAT + " - " + (cAliasSRA)->RA_CODUNIC, (cAliasSRA)->RA_NOMECMP, (cAliasSRA)->RA_FILIAL, 0} )
							EndIf

							If cVersEnvio < "9.0" .And. cCodINCIRF $ '31|32|33|34|35|51|52|53|54|55|81|82|83'
								nPos := aScan(aRetPgtoTot, {|x| x[1] == cPd .And. x[7] == cideDmDev .And. x[9] == (cAliasSRA)->RA_CIC })
								If lGeraCod
									cIdTbRub := cCodFil
								Else
									If cVersEnvio >= "2.3"
										cIdTbRub := cEmpAnt
									Else
										cIdTbRub := ""
									EndIf
								EndIf

								If lMiddleware
									If lPrimIdT
										lPrimIdT  := .F.
										cIdeRubr := fGetIdRJF( cCodFil, cIdTbRub )
										If Empty(cIdeRubr) .And. aScan(aErros, { |x| x == OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) }) == 0
											aAdd( aErros, OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) )//"Atenção"##"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
										EndIf
									EndIf
									cIdTbRub := cIdeRubr
								EndIf

								If nPos == 0
									Aadd (aRetPgtoTot, {cPd, cIdTbRub, Nil, Nil, Nil, nValor, cideDmDev, (cCodFil+cPd), (cAliasSRA)->RA_CIC} )
								else
									aRetPgtoTot[nPos,6] += nValor
								Endif

								If (VAL(cCodINCIRF ) >=  51 .AND. VAL(cCodINCIRF ) <= 55)
									fBenefic( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, dDtPgt, cPd, nValor, cideDmDev, cPeriodo )
								EndIf
							EndIf
							If cVersEnvio >= "9.2"
								If (VAL(cCodINCIRF ) >=  51 .And. VAL(cCodINCIRF ) <= 55) .Or. (VAL(cCodINCIRF ) >= 9051 .And. VAL(cCodINCIRF ) <= 9054)
									fBenefic( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, dDtPgt, cPd, nValor, cideDmDev, cPeriodo, cCodINCIRF, lTSV, (cAliasSRA)->RA_CIC )
								EndIf

								If  Empty(aDedDep) .Or. (Len(aDedDep) > 0 .And. ascan(aDedDep,{ |x| X[1]== (cAliasSRA)->RA_FILIAL .And. X[2]==(cAliasSRA)->RA_MAT }) == 0 )
									aDedDep := fDedDep((cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, cPeriodo, lTSV, (cAliasSRA)->RA_CIC )
								Endif
							Endif
							(cAliasSRX)->(dbSkip())

							//Ajusta posição do demonstrativo que guarda o valor de dedução do IRRF
							If cVersEnvio >= "9.3" .And. nPdetPGtoFl > 0 .And. cCodINCIRF $ "31|32|33|34|35"
								adetPgtoFl[nPdetPGtoFl, 12] += Iif(cTipoCod $ '2*4', (cAliasSRX)->RD_VALOR, (cAliasSRX)->RD_VALOR * -1)
							EndIf
						EndDo
					EndIf
				EndIf

				//Atualiza o array aIncIRComp na posição 4 se há dados para a geração de informações complementares obrigatórias
				If cVersEnvio >= "9.3" .And. Len(aIncIRComp) >= 3
					If Len(aRetPensao) > 0 .And. aScan(aRetPensao, {|x| x[7] == (cAliasSRA)->RA_CIC}) > 0
						aIncIRComp[1][4] := .T.
					EndIf
					If 	((Len(adadosRHS) > 0 .And. aScan(adadosRHS, {|x| x[1]+x[2] == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT}) > 0 ) .Or. ;
							(Len(adadosRHP) > 0 .And. aScan(adadosRHP, {|x| x[1]+x[2] == (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT}) > 0))
						aIncIRComp[2][4] := .T.
					EndIf
					If Len(aInfoPrev) > 0 .And. aScan(aInfoPrev, {|x| x[7] == (cAliasSRA)->RA_CIC}) > 0
						aIncIRComp[3][4] := .T.
					EndIf
				EndIf

				If !Empty(cTpPgtoBkp)
					cTpPgto := cTpPgtoBkp
				EndIf

				//Para funcionarios que não possuem a categoria de contrato intermitente
				If (cAliasSRA)->RA_CATEFD <> "111"
					//Tratamento para buscar os valores de ferias
					aBkpFer := fm036GetFer( cSRHFil, cSRHMat, cDtPesqI, cDtPesqF, (cAliasSRA)->RA_CATEFD, @aVbFer, @aErros, cFilPreTrf, (cAliasQSRA)->RA_CIC )
				Endif

				//Zera as variáveis
				cNumFer 	:= ""
				cBkpDtFer	:= ""
				nNumFer 	:= 0

				//Retorna o valor inicial de cSRHFil
				cSRHFil := cFilPreTrf

				For nCntFer := 1 To Len(aBkpFer)
					If cVersEnvio >= "9.0"
						nRetFer := nCntFer

						//Pesquisa pelo prefixo na tabela RU8
						If lNewDmDev
							cPrefixo := fGetPrefixo(cSRHFil, cSRHMat, aBkpFer[nCntFer][12], aBkpFer[nCntFer][8], .F.)
						EndIf

						If !lRes
							aAdd( aRetFer, aClone( aBkpFer[nCntFer] ) )
							//Verifica se a data de pagamento das férias é igual
							If !Empty(cBkpDtFer) .And. cBkpDtFer == aBkpFer[nCntFer, 6]
								nNumFer ++
								If nNumFer >= 1
									cNumFer := cValToChar(nNumFer)
								EndIf
							EndIf

							If Empty(cPrefixo)
								If lAglut .And. (SRA->RA_OCORREN $ "05/06/07/08" .Or. nQtdeFol > 1)//MultV
									If nQtdeFolMV <= 1
										cideDmDev := cSRHFil + aBkpFer[nCntFer, 6] + aBkpFer[nCntFer][12] + "FER" + cNumFer
									Else
										cideDmDev := cSRHFil + cSRHMat + SubStr( aBkpFer[nCntFer, 6], 3 ) + SubStr( aBkpFer[nCntFer, 12], 3 )  + "FER" + cNumFer
									EndIf
									cideDmDev += If(lAmbosEve, "RPPS", "")
									If Len(cideDmDev) > 30
										cideDmDev := cSRHFil + SRA->RA_MAT + SubStr( aBkpFer[nCntFer, 6], 7 ) + "FER" + cNumFer
									EndIf
								Else
									cideDmDev := cSRHFil + aBkpFer[nCntFer, 6] + aBkpFer[nCntFer][12] + "FER" + cNumFer + If(lAmbosEve, "RPPS", "")
								EndIf
							Else
								cideDmDev := cPrefixo + aBkpFer[nCntFer, 6] + aBkpFer[nCntFer][12] + "FER" + cNumFer + If(lAmbosEve, "RPPS", "")
							EndIf

							nRetFer := Len(aRetFer)
							aRetFer[nRetFer][13] := cideDmDev
							aRetFer[nRetFer][12] := substr(aBkpFer[nCntFer, 6],1,4) + "-" + substr(aBkpFer[nCntFer, 6],5,2)
							nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == aBkpFer[nCntFer, 6] .And. x[2] == ctpPgto .And. x[3] == Nil .And. x[4] == Nil .And. x[5] == (cAliasSRA)->RA_CIC } )
							If nPInfoPgto == 0
								aAdd( aInfoPgto, { aBkpFer[nCntFer, 6], ctpPgto, Nil, Nil, (cAliasSRA)->RA_CIC } )
							EndIf
							cBkpDtFer := aBkpFer[nCntFer, 6]
						ElseIf lRes
							aAdd( aRetFer, aClone( aBkpFer[nCntFer] ) )
							//Verifica se a data de pagamento das férias é igual
							If !Empty(cBkpDtFer) .And. cBkpDtFer == aBkpFer[nCntFer, 6]
								nNumFer ++
								If nNumFer >= 1
									cNumFer := cValToChar(nNumFer)
								EndIf
							EndIf

							//cideDmDev = FILIAL + MATRÍCULA + DATA DE PAGAMENTO + ROTEIRO + SEQUENCIAL (Gerado apenas se a data de pagamento for igual)
							If Empty(cPrefixo)
								cideDmDev := cSRHFil + cSRHMat + aBkpFer[nCntFer, 6] + "FER" + cNumFer
								If Len(cideDmDev) > 30
									cideDmDev := cSRHFil + aBkpFer[nCntFer, 6] + cPeriodo + "FER" + cNumFer
								EndIf
							Else
								cideDmDev := cPrefixo + aBkpFer[nCntFer, 6] + aBkpFer[nCntFer][12] + "FER" + cNumFer
							EndIf

							//Somente gerado os dados de férias se o recibo foi gerado no S-2299
							If fFer2299TAF(cFilEnv, aBkpFer[nCntFer, 2], cDtDeslig, cideDmDev)
								nRetFer := Len(aRetFer)
								aRetFer[nRetFer][13] := cideDmDev
								aRetFer[nRetFer][12] := substr(aBkpFer[nCntFer, 6],1,4) + "-" + substr(aBkpFer[nCntFer, 6],5,2)
								nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == aBkpFer[nCntFer, 6] .And. x[2] == "2" .And. x[3] == Nil .And. x[4] == Nil .And. x[5] == (cAliasSRA)->RA_CIC } )
								If nPInfoPgto == 0
									aAdd( aInfoPgto, { aBkpFer[nCntFer, 6], "2", Nil, Nil, (cAliasSRA)->RA_CIC} )
								EndIf
								cBkpDtFer := aBkpFer[nCntFer, 6]
							EndIf
						EndIf
					Else
						aAdd( aRetFer, aClone( aBkpFer[nCntFer] ) )
						nPInfoPgto := aScan( aInfoPgto, { |x| x[1] == aBkpFer[nCntFer, 6] .And. x[2] == "7" .And. x[5] == (cAliasSRA)->RA_CIC } )
						If nPInfoPgto == 0
							aAdd( aInfoPgto, { aBkpFer[nCntFer, 6], "7", If(lResidExt, "N", "S"), "1", (cAliasSRA)->RA_CIC } )
						EndIf
					EndIf
				Next

				//Se for residente no exterior busca alimenta o array aRGE1210 com os dados da tabela RGE
				If lResidExt
					aRGE1210 := fGetRGE( (cAliasSRA)->RA_FILIAL, (cAliasSRA)->RA_MAT, cCompete)
					//A partir do leiaute 1.3 ajusta a posição 10 do array para conter a forma de tributação para cada demonstrativo
					If cVersEnvio >= "9.3" .And. Len(aRGE1210) > 0
						aRGE1210Bkp := aClone(aRGE1210)
						aRGE1210	:= {}

						//Adiciona aRGE1210 conforme a quantidade de demonstrativos do array
						For nX := 1 To Len(adetPgtoFl)
							If Len(adetPgtoFl[nX]) > 11
								cFrmTribut := aRGE1210Bkp[1, 12]

								//Verifique se deve ajustar o valor da tag cFrmTribut ou apresentar mensagem de inconsistência:
								If (Substr(aRGE1210Bkp[1, 12], 1, 1) == "1" .Or. aRGE1210Bkp[1, 12] == "30") .And. adetPgtoFl[nX, 12] < 1
									cFrmTribut := "50"
								ElseIf(Substr(aRGE1210Bkp[1, 12], 1, 1) == "4" .Or. aRGE1210Bkp[1, 12] == "50") .And. adetPgtoFl[nX, 12] > 0
									If Empty(cMsgRGE)
										//"Trabalhador possui forma de tributacao inválida. Para os códigos [4X, 50] não é permitida a informação do imposto retido na fonte. "
										cMsgRGE += OemToAnsi(STR0259) + CRLF
									EndIf
									//"Verifique a rotina Histórico de Contrato (GPEA900) e/ou os cálculos do demonstrativo "
									cMsgRGE += OemToAnsi(STR0260) + adetPgtoFl[nX, 2] + CRLF
								EndIf

								//Cria a aRGE1210 novamente
								aAdd(aRGE1210, { aRGE1210Bkp[1, 1],;	//Código do Pais		- TAG <paisResidExt> 	do S-1210
									aRGE1210Bkp[1, 2],;					//Indicativo do NIF		- TAG <indNIF>			do S-1210
									aRGE1210Bkp[1, 3],;					//Código do NIF			- TAG <nifBenef>		do S-1210
									aRGE1210Bkp[1, 4],;					//Logradouro 			- TAG <endDscLograd>	do S-1210
									aRGE1210Bkp[1, 5],;					//Número do Endereço	- TAG <endNrLograd>		do S-1210
									aRGE1210Bkp[1, 6],;					//Complemento Endereço	- TAG <endComplem>		do S-1210
									aRGE1210Bkp[1, 7],;					//Bairro				- TAG <endBairro>		do S-1210
									aRGE1210Bkp[1, 8],;					//Cidade				- TAG <endCidade>		do S-1210
									aRGE1210Bkp[1, 9],;					//Estado				- TAG <endEstado>		do S-1210
									aRGE1210Bkp[1, 10],;				//Cód Postal (CEP)		- TAG <endCodPostal>	do S-1210
									aRGE1210Bkp[1, 11],;				//Telefone				- TAG <telef>			do S-1210
									cFrmTribut})						//Forma Tributação		- TAG <frmTribut>		do S-1210
							EndIf
						Next nX

						//Adiciona aRGE1210 conforme a quantidade de demonstrativos do array aRetFer
						For nX := 1 To Len(aRetFer)
							If Len(aRetFer[nX]) > 13
								cFrmTribut := aRGE1210Bkp[1, 12]

								//Verifique se deve ajustar o valor da tag cFrmTribut ou apresentar mensagem de inconsistência:
								If (Substr(aRGE1210Bkp[1, 12], 1, 1) == "1" .Or. aRGE1210Bkp[1, 12] == "30") .And. aRetFer[nX, 14] < 1
									cFrmTribut := "50"
								ElseIf(Substr(aRGE1210Bkp[1, 12], 1, 1) == "4" .Or. aRGE1210Bkp[1, 12] == "50") .And. aRetFer[nX, 14] > 0
									If Empty(cMsgRGE)
										//"Trabalhador possui forma de tributacao inválida. Para os códigos [4X, 50] não é permitida a informação do imposto retido na fonte. "
										cMsgRGE += OemToAnsi(STR0259) + CRLF
									EndIf
									//"Verifique a rotina Histórico de Contrato (GPEA900) e/ou os cálculos do demonstrativo "
									cMsgRGE += OemToAnsi(STR0260) + adetPgtoFl[nX, 2] + CRLF
								EndIf

								//Cria a aRGE1210 novamente
								aAdd(aRGE1210, { aRGE1210Bkp[1, 1],;	//Código do Pais		- TAG <paisResidExt> 	do S-1210
									aRGE1210Bkp[1, 2],;					//Indicativo do NIF		- TAG <indNIF>			do S-1210
									aRGE1210Bkp[1, 3],;					//Código do NIF			- TAG <nifBenef>		do S-1210
									aRGE1210Bkp[1, 4],;					//Logradouro 			- TAG <endDscLograd>	do S-1210
									aRGE1210Bkp[1, 5],;					//Número do Endereço	- TAG <endNrLograd>		do S-1210
									aRGE1210Bkp[1, 6],;					//Complemento Endereço	- TAG <endComplem>		do S-1210
									aRGE1210Bkp[1, 7],;					//Bairro				- TAG <endBairro>		do S-1210
									aRGE1210Bkp[1, 8],;					//Cidade				- TAG <endCidade>		do S-1210
									aRGE1210Bkp[1, 9],;					//Estado				- TAG <endEstado>		do S-1210
									aRGE1210Bkp[1, 10],;					//Cód Postal (CEP)		- TAG <endCodPostal>	do S-1210
									aRGE1210Bkp[1, 11],;				//Telefone				- TAG <telef>			do S-1210
									cFrmTribut})						//Forma Tributação		- TAG <frmTribut>		do S-1210
							EndIf
						Next nX

						//Adiciona inconsistência no relatório
						If lRelat
							aAdd( aRelIncons, { cOldFil, cCPF, OemToAnsi(cMsgRGE)} )
						EndIf
					EndIf
				Endif

				//Carrega demais dados do grupo infoIRComplem
				If cVersEnvio >= "9.2"
					fInfIRComp()
				EndIf
			EndIf

			//Verifica se há inconsistência impeditiva de dependente para ser exibida nos logs
			If !Empty(aLogErrDep)
				If lRelat
					aEval( aLogErrDep, { |x| IIf(!Empty(x), aAdd(aRelIncons,	{(cAliasQSRA)->RC_FILIAL, (cAliasQSRA)->RA_CIC, x }), Nil ) }  )
				Else
					aEval( aLogErrDep, { |x| aAdd(aLogsErr, 	 x ) }  )
				EndIf
			EndIf

			(cAliasQSRA)->( dbSkip() )
			(cAliasSRA)->( dbGoTo( (cAliasQSRA)->RECNO ) )

			If ( nPosEmp := aScan( aSM0, { |x| x[1] + x[2] == cEmpAnt + (cAliasQSRA)->RC_FILIAL } ) ) > 0
				cEmp 	:= SubStr(aSM0[nPosEmp, 18], 1, 8)
			EndIf

			//Valida se há alguma informação complementar obrigatória que não foi gerada:
			If cVersEnvio >= "9.3" .And. Len(aIncIRComp) >= 3
				//Pensão Alimentícia
				If aIncIRComp[1][2] .And. !aIncIRComp[1][4]
					cMsgPens := OemToAnsi(STR0246) + CRLF //"Há verbas com a incidência incidência IR relacionada a Pensão Alimentícia, mas não foi gerado o grupo 'penAlim' no XML. "
					cMsgPens += OemToAnsi(STR0247) + CRLF //"Verifique o cadastro de beneficiários. "
					cMsgPens += OemToAnsi(STR0248) + ArrTokStr(aIncIRComp[1][3], ", ") + CRLF //"Incidências IR avaliadas: "
					cMsgPens += OemToAnsi(STR0249) + ArrTokStr(aIncIRComp[1][5], ", ") + CRLF //"Verbas com incidência IR de Pensão Alimentícia: "
					If lRelat
						aAdd( aRelIncons, { cOldFil, cCPF, OemToAnsi(cMsgPens)} )
					EndIf
				EndIf

				//Plano de Saúde
				If aIncIRComp[2][2] .And. !aIncIRComp[2][4]
					cMsgPlSau := OemToAnsi(STR0250) + CRLF //"Há verbas com a incidência IR relacionada a Plano de Saúde, mas não foi gerado o grupo 'planSaude' no XML. "
					cMsgPlSau += OemToAnsi(STR0251) + CRLF //"Verifique o cadastro de plano de saúde. "
					cMsgPlSau += OemToAnsi(STR0248) + ArrTokStr(aIncIRComp[2][3], ", ") + CRLF //"Incidências IR avaliadas: "
					cMsgPlSau += OemToAnsi(STR0252) + ArrTokStr(aIncIRComp[2][5], ", ") + CRLF //"Verbas com incidência IR de Plano de Saúde: "
					If lRelat
						aAdd( aRelIncons, { cOldFil, cCPF, OemToAnsi(cMsgPlSau)} )
					EndIf
				EndIf

				//Previdência Complementar
				If aIncIRComp[3][2] .And. !aIncIRComp[3][4]
					cMsgPrevC := OemToAnsi(STR0253) + CRLF //"Há verbas com a incidência IR relacionada a Previdência Complementar, mas não foi gerado o grupo 'previdCompl' no XML. "
					cMsgPrevC += OemToAnsi(STR0254) + CRLF //"Verifique o cadastro de previdência complementar. "
					cMsgPrevC += OemToAnsi(STR0248) + ArrTokStr(aIncIRComp[3][3], ", ") + CRLF //"Incidências IR avaliadas: "
					cMsgPrevC += OemToAnsi(STR0255) + ArrTokStr(aIncIRComp[3][5], ", ") + CRLF //"Verbas com incidência IR de Previdência Complementar: "
					If lRelat
						aAdd( aRelIncons, { cOldFil, cCPF, OemToAnsi(cMsgPrevC)} )
					EndIf
				EndIf
			EndIf

			If (cAliasQSRA)->(!Eof())
				If !lRelat .And. ( !lAglut .Or. nQtdeFol == 1 .Or. cCPF <> AllTrim((cAliasSRA)->RA_CIC) .Or. (cEmp != cEmpOld) ) .And. !lTercGrp
					If (Empty(aLogCIC) .OR. cVersEnvio <> "2.5.00")
						lRetXml := fXml1210(@cXml, lRes, lPgtRes, aRGE1210, lAfast, cCompete, cRetfNew, cRecibo, cIdXml, cVersMw, @aErros, cPer1210, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cCPF, nVlrDep)
						If lRetXml
							If !lMiddleware .And. cStatT3P $ "4"
								cXml := StrTran(cXml, "<indRetif>1</indRetif>", "<indRetif>2</indRetif>")
							EndIf
							cBkpFilEnv	:= cFilEnv

							If Empty(cMsgPens) .And. Empty(cMsgPlSau) .And. Empty(cMsgPrevC) .And. Empty(cMsgRGE)
								If lAglut
									If Len(aContdmDev) > 1
										cFilVal := Left(aContdmDev[1,1],((At(";",aContdmDev[1,1]))-1))
										For nZ := 1 to Len(aContdmDev)
											If cFilVal <> Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
												cFilEnv := cFilAnt := fVldMatriz(cFilEnv, cPer1210)
												EXIT
											ElseIf nZ == Len(aContdmDev)
												cFilEnv := cFilAnt := SubStr( aContdmDev[nZ,1], 1, FwSizeFilial() )
												EXIT
											EndIf
											cFilVal := Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
										Next nZ
									ElseIf !Empty(aContdmDev)
										cFilEnv := cFilAnt := SubStr( aContdmDev[1,1], 1, FwSizeFilial() )
									EndIf
								EndIf
								If !lMiddleware
									cTafKey := "S1210" + cPeriodo + cTpFolha + cCPF
									SM0->(dbSeek( cEmpAnt + cFilEnv ))
									aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S1210", , "", , , , "GPE", , "", If(nQtdeFol > 1, "MV", ""),,,,,,,cSRHCodUni )
								Else
									aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1210", cPer1210, cKeyMid, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, cRecibo } )
									If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
										aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
									EndIf
								EndIf
								If Len( aErros ) > 0
									If !lMiddleware
										FeSoc2Err( aErros[1], @cMsgErro)
									Else
										For nCont := 1 To Len(aErros)
											cMsgErro += aErros[nCont] + Chr(13) + Chr(10)
										Next nCont
									EndIf
									aAdd(aLogsErr, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029) ) //##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "
									aAdd(aLogsErr, "" )
									aAdd(aLogsErr, cMsgErro)
									If lTSV
										aEmp_1210[4]++ //Inclui TSV nao integrado
									Else
										aEmp_1210[2]++ //Inclui TCV nao integrado
									EndIf
								Else
									If !lMiddleware
										aAdd(aLogsOk, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0049) ) //##"Registro S-1210 do Funcionário: "##" Integrado com TAF."
									Else
										aAdd(aLogsOk, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0165) ) //##"Registro S-1210 do Funcionário: "##" Integrado com Middleware."
									EndIf
									If !Empty(cLogDep)
										aAdd(aLogsOk, cLogDep )
									EndIf
									aAdd(aLogsOk, "" )
									If lTSV
										aEmp_1210[3]++ //Inclui TSV integrado
									Else
										aEmp_1210[1]++ //Inclui TCV integrado
									EndIf
								Endif
							Else
								//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##"Funcionário não possui movimento"
								aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
								If !Empty(cMsgPens)
									aAdd(aLogsErr, OemToAnsi(cMsgPens))
								EndIf
								If !Empty(cMsgPlSau)
									aAdd(aLogsErr, OemToAnsi(cMsgPlSau))
								EndIf
								If !Empty(cMsgPrevC)
									aAdd(aLogsErr, OemToAnsi(cMsgPrevC))
								EndIf
								If !Empty(cMsgRGE)
									aAdd(aLogsErr, OemToAnsi(cMsgRGE))
								EndIf
								aAdd(aLogsErr, "" )
								If lTSV
									aEmp_1210[4]++ //Inclui TSV nao integrado
								Else
									aEmp_1210[2]++ //Inclui TCV nao integrado
								EndIf
							EndIf
							cFilEnv		:= cBkpFilEnv
							aInfoPgto	:= {}
							aRetFer		:= {}
							GrvTxtArq(alltrim(cXml), "S1210", cCPF)
						Else
							//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##"Funcionário não possui movimento"
							aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
							aAdd(aLogsErr, OemToAnsi(STR0180))
							aAdd(aLogsErr, "" )
							If lTSV
								aEmp_1210[4]++ //Inclui TSV nao integrado
							Else
								aEmp_1210[2]++ //Inclui TCV nao integrado
							EndIf
						EndIf
					Else
						If !Empty(aLogCIC) .AND. cVersEnvio == "2.5.00"
							//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##" - Beneficiário(s) de Pensão Alimentícia SEM CPF cadastrado. Beneficiário deve ser um CPF válido e diferente do CPF do trabalhador."
							aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
							aAdd(aLogsErr, OemToAnsi(STR0149))
							aAdd(aLogsErr, "" )
						EndIf
						If lTSV
							aEmp_1210[4]++ //Inclui TSV nao integrado
						Else
							aEmp_1210[2]++ //Inclui TCV nao integrado
						EndIf
					EndIf
				ElseIf lRelat .And. !Empty(aLogCIC)
					aAdd( aRelIncons, { cOldFil, cCPF, OemToAnsi(STR0149)} )//" - Beneficiário(s) de Pensão Alimentícia SEM CPF cadastrado. Beneficiário deve ser um CPF válido e diferente do CPF do trabalhador."
				EndIf
			EndIf
		EndDo //SRA
		If !lAborta
			If !lExcLote .And. ( !Empty(aInfoPgto) .Or. !Empty(aRetFer) )
				If !lRelat
					If (Empty(aLogCIC) .OR. cVersEnvio <> "2.5.00")
						lRetXml := fXml1210(@cXml, lRes, lPgtRes, aRGE1210, lAfast, cCompete, cRetfNew, cRecibo, cIdXml, cVersMw, @aErros, cPer1210, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cCPF, nVlrDep)
						If lRetXml
							If !lMiddleware .And. cStatT3P $ "4"
								cXml := StrTran(cXml, "<indRetif>1</indRetif>", "<indRetif>2</indRetif>")
							EndIf

							If Empty(cMsgPens) .And. Empty(cMsgPlSau) .And. Empty(cMsgPrevC) .And. Empty(cMsgRGE)
								If lAglut
									If Len(aContdmDev) > 1
										cFilVal := Left(aContdmDev[1,1],((At(";",aContdmDev[1,1]))-1))
										For nZ := 1 to Len(aContdmDev)
											If cFilVal <> Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
												cFilEnv := cFilAnt := fVldMatriz(cFilEnv, cPer1210)
												EXIT
											ElseIf nZ == Len(aContdmDev)
												cFilEnv := cFilAnt := SubStr( aContdmDev[nZ,1], 1, FwSizeFilial() )
												EXIT
											EndIf
											cFilVal := Left(aContdmDev[nZ,1],((At(";",aContdmDev[nZ,1]))-1))
										Next nZ
									ElseIf !Empty(aContdmDev)
										cFilEnv := cFilAnt := SubStr( aContdmDev[1,1], 1, FwSizeFilial() )
									EndIf
								EndIf

								If !lMiddleware
									cTafKey := "S1210" + cPeriodo + cTpFolha + cCPF
									SM0->(dbSeek( cEmpAnt + cFilEnv ))
									aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S1210", , "", , , , "GPE", , "", If(nQtdeFol > 1, "MV", "") ,,,,,,,cSRHCodUni )
								Else
									aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1210", cPer1210, cKeyMid, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, Nil, cRecibo } )
									If !(fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
										aAdd( aErros, OemToAnsi(STR0155) )//"Ocorreu um erro na gravação do registro na tabela RJE"
									EndIf
								EndIf
								If Len( aErros ) > 0
									If !lMiddleware
										FeSoc2Err( aErros[1], @cMsgErro)
									Else
										For nCont := 1 To Len(aErros)
											cMsgErro += aErros[nCont] + Chr(13) + Chr(10)
										Next nCont
									EndIf
									aAdd(aLogsErr, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029) ) //##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "
									aAdd(aLogsErr, "" )
									aAdd(aLogsErr, cMsgErro)
									If lTSV
										aEmp_1210[4]++ //Inclui TSV nao integrado
									Else
										aEmp_1210[2]++ //Inclui TCV nao integrado
									EndIf
								Else
									If !lMiddleware
										aAdd(aLogsOk, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0049) ) //##"Registro S-1210 do Funcionário: "##" Integrado com TAF."
									Else
										aAdd(aLogsOk, OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0165) ) //##"Registro S-1210 do Funcionário: "##" Integrado com Middleware."
									EndIf
									If !Empty(cLogDep)
										aAdd(aLogsOk, cLogDep )
									EndIf
									aAdd(aLogsOk, "" )
									If lTSV
										aEmp_1210[3]++ //Inclui TSV integrado
									Else
										aEmp_1210[1]++ //Inclui TCV integrado
									EndIf
								Endif
							Else
								//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##"Funcionário não possui movimento"
								aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
								If !Empty(cMsgPens)
									aAdd(aLogsErr, OemToAnsi(cMsgPens))
								EndIf
								If !Empty(cMsgPlSau)
									aAdd(aLogsErr, OemToAnsi(cMsgPlSau))
								EndIf
								If !Empty(cMsgPrevC)
									aAdd(aLogsErr, OemToAnsi(cMsgPrevC))
								EndIf
								If !Empty(cMsgRGE)
									aAdd(aLogsErr, OemToAnsi(cMsgRGE))
								EndIf
								aAdd(aLogsErr, "" )
								If lTSV
									aEmp_1210[4]++ //Inclui TSV nao integrado
								Else
									aEmp_1210[2]++ //Inclui TCV nao integrado
								EndIf
							EndIf
							GrvTxtArq(alltrim(cXml), "S1210", cCPF)
						Else
							//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##"Funcionário não possui movimento"
							aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
							aAdd(aLogsErr, OemToAnsi(STR0180))
							aAdd(aLogsErr, "" )
							If lTSV
								aEmp_1210[4]++ //Inclui TSV nao integrado
							Else
								aEmp_1210[2]++ //Inclui TCV nao integrado
							EndIf
						EndIf
					Else
						If !Empty(aLogCIC) .AND. cVersEnvio == "2.5.00"
							//"[AVISO]"##"Registro S-1210 do Funcionário: "##" não foi integrado devido ao(s) erro(s) abaixo: "##" - Beneficiário(s) de Pensão Alimentícia SEM CPF cadastrado. Beneficiário deve ser um CPF válido e diferente do CPF do trabalhador."
							aAdd(aLogsErr, OemToAnsi(STR0148) + OemToAnsi(STR0025) + cCPF + " - " + cNome + OemToAnsi(STR0029))
							aAdd(aLogsErr, OemToAnsi(STR0149))
							aAdd(aLogsErr, "" )
						EndIf
						If lTSV
							aEmp_1210[4]++ //Inclui TSV nao integrado
						Else
							aEmp_1210[2]++ //Inclui TCV nao integrado
						EndIf
					EndIf
					aInfoPgto	:= {}
					aRetFer		:= {}
				ElseIf lRelat .And. !Empty(aLogCIC)
					aAdd( aRelIncons, { cOldFil, cCPF, OemToAnsi(STR0149)} )//" - Beneficiário(s) de Pensão Alimentícia SEM CPF cadastrado. Beneficiário deve ser um CPF válido e diferente do CPF do trabalhador."
				EndIf
			EndIf
		EndIf

		(cAliasQSRA)->(dbCloseArea())
		If lAglut
			(cAliasQMV)->(dbCloseArea())
		EndIf
		IF oTmpCPF <> NIL
			oTmpCPF:Delete()
			oTmpCPF := Nil
		ENDIF
		If oTmpEmp <> NIL
			oTmpEmp:Delete()
			oTmpEmp := Nil
		EndIf
	Next nI

	cFilAnt := cBkpFil

	RestArea(aArea)
	RestArea(aAreaSM0)

	If !lRelat
		aAdd(aLogsPrc, OemToAnsi(STR0039) + cValToChar(aEmp_1210[1]) ) 	//"Trabalhadores com vínculo integrados: "
		aAdd(aLogsPrc, OemToAnsi(STR0040) + cValToChar(aEmp_1210[2]) )	//"Trabalhadores com vínculo não Integrados: "
		aAdd(aLogsPrc, OemToAnsi(STR0041) + cValToChar(aEmp_1210[3]) )	//"Trabalhadores sem vínculo integrados: "
		aAdd(aLogsPrc, OemToAnsi(STR0042) + cValToChar(aEmp_1210[4]) )	//"Trabalhadores sem vínculo não Integrados: "
		aAdd(aLogsPrc, OemToAnsi(STR0043) + cValToChar( aEmp_1210[1] + aEmp_1210[3] ) )	//"Total de registros integrados: "
		aAdd(aLogsPrc, OemToAnsi(STR0044) + cValToChar(aEmp_1210[2] + aEmp_1210[4]) )	//"Total de registros não integrados: "

		aAdd(aLogsPrc,"")
		aAdd(aLogsPrc, Replicate("-",132) )
		aAdd(aLogsPrc, OemToAnsi(STR0069)+": " +  SecsToTime(nHrInicio))				//Inicio Processamento:
		nHrFim 	:= SecsToTime(Seconds())
		aAdd(aLogsPrc,+OemToAnsi(STR0070)+":    " + nHrFim)							//Fim Processamento:
		aAdd(aLogsPrc,"")
		aAdd(aLogsPrc,OemToAnsi(STR0071+": " + SecsToTime(Seconds() - nHrInicio)))		//Duracao do Processamento
	Else
		fGeraRelat( cCompete, lAfast )
	EndIf

	aInfoPgto	:= {}
	aDetPgtoFl	:= {}
	aRetFer		:= {}
	aRetPgtoTot	:= {}
	aRetPensao	:= {}
	aLogCIC		:= {}
	aDetPgtoAt 	:= {}
	aPgtoAnt 	:= {}
	aInfoPrev	:= {}
	aDedDep     := {}
	aDepen		:= {}
	adadosRHS   := {}
	adadosRHP   := {}

Return .T.

/*/{Protheus.doc} fXml1210
Função que monta o XML do evento S-1210 através da estrutura abaixo dos arrays de controle:
v2.5
aInfoPgto <InfoPgto> -> Aglutina por <dtPgto> e <tpPgto>
	|
	->	aDetPgtoAt <detPgtoAnt> -> Relaciona com aInfoPgto por <dtPgto> e <tpPgto>
		|
		-> aPgtoAnt <infoPgtoAnt> -> Relaciona com aDetPgtoAt por <dtPgto> e <tpPgto>
			|
			-> aRetPensao <penAlim>	-> Relaciona com aPgtoAnt por <codRubr> + <dtPgto> e <tpPgto>
	|
	->	aDetPgtoFl <detPgtoFl> -> Relaciona com aInfoPgto por <dtPgto> e <tpPgto>
		|
		-> aRetPgtoTot <retPgtoTot>	-> Relaciona com aDetPgtoFl por <ideDmDev>
			|
			-> aRetPensao <penAlim>	-> Relaciona com aRetPgtoTot por <codRubr> + <ideDmDev>
	|
	->	aRetFer <detPgtoFer> -> Relaciona com aInfoPgto por <dtPgto> e <tpPgto>
		|
		-> Gera <detRubrFer> pelos itens de aRetFer[XXX, 7]
			|
			-> aRetPensao <penAlim>	-> Relaciona com detRubrFer por <codRubr> + <ideDmDev>
vS-1.0: aInfoPgto relaciona com detPgtoFl -> um grupo <infoPgto> por idmDev
@author Allyson
@since 19/06/2018
@version 1.0
@param cXML 		- String com o XML do evento S-1210
@param lRes 		-
@param lPgtRes 		-
@param aRGE1210		-
@param lAfast		- Indica se gera o evento para funcionários sem valores
@param cCompete		- Competência informada na geração do evento
@return lGerouXML	- Indica se foi gerado informações de pagamento no XML
/*/
Static Function fXml1210( cXML, lRes, lPgtRes, aRGE1210, lAfast, cCompete, cRetfNew, cRecibXML, cIdXml, cVersMw, aErros, cPeriodo, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cCpfBenef, nVlrDep )

Local cStatus		:= "-1"
Local cPaisExt		:= ""
Local lS1000		:= .T.
Local nCntInfPgFl	:= 0
Local nCntDetPgAt	:= 0
Local nCntDetPgTo	:= 0
Local nCntRetPgAt 	:= 0
Local nCntRetPgTo 	:= 0
Local nCntRetPens 	:= 0
Local nCntRetFer 	:= 0
Local nCntRubFer 	:= 0
Local nCntRGE1210	:= 1
Local lFirstInfo	:= .F.
Local lGerouInfo	:= .F.
Local lGerouDetP	:= .F.
Local lGerouXML		:= .F.
Local lGerarRGE		:= .F.

Local lNGeraInPgt 	:= .F.
Local nPosInfo		:= 1
Local nPosDet		:= 1

Default lRes 		:= .F.
Default lPgtRes		:= .T.
Default aRGE1210	:= {}
Default cCompete	:= ""
Default cRetfNew	:= "1"
Default cRecibXML	:= ""
Default cIdXml		:= ""
Default cVersMw		:= ""
Default aErros		:= {}
Default cFilEnv		:= ""
Default lAdmPubl	:= .F.
Default cTpInsc		:= ""
Default cNrInsc		:= ""
Default cCpfBenef	:= ""
Default nVlrDep		:= 0

If lMiddleware
	cXml += "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtPgtos/v" + cVersMw + "'>"
	fPosFil( cEmpAnt, cFilEnv )
	lS1000 := fVld1000( cPeriodo, @cStatus )
	If !lS1000
		Do Case
			Case cStatus == "-1" // nao encontrado na base de dados
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0161) )//"Registro do evento X-XXXX não localizado na base de dados"
			Case cStatus == "1" // nao enviado para o governo
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0162) )//"Registro do evento X-XXXX não transmitido para o governo"
			Case cStatus == "2" // enviado e aguardando retorno do governo
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0163) )//"Registro do evento X-XXXX aguardando retorno do governo"
			Case cStatus == "3" // enviado e retornado com erro
				aAdd( aErros, OemToAnsi(STR0160) + "S-1000" + OemToAnsi(STR0164) )//"Registro do evento X-XXXX retornado com erro do governo"
		EndCase
		Return .F.
	EndIf
	cXML += "<evtPgtos Id='" + cIdXml + "'>"//<evtPgtos>
	fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Iif(cVersEnvio >= "9.0", Nil, "1"), (SubStr(cPeriodo, 1, 4) + "-" + SubStr(cPeriodo, 5, 2)), 1, 1, "12" } )//<ideEvento>
	fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )//<ideEmpregador>
	S1210A05(@cXml, {cCpfBenef}, .F.)
	If(cVersEnvio < "9.0", S1210A06(@cXml, {nVlrDep}, .T.), Nil)
EndIf

If cVersEnvio >= "9.1" .And. Len(aRGE1210) > 0
	cPaisExt := aRGE1210[1,1]
	lGerarRGE := (cPaisExt != "105")
EndIf

For nCntInfPgFl	:= 1 To Len(aInfoPgto)
	If cVersEnvio >= "9.0"
		If !( aInfoPgto[nCntInfPgFl, 2] $ "7|9" )
			For nCntDetPgto := 1 To Len(adetPgtoFl)
				If (adetPgtoFl[nCntDetPgTo, 7] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2]) .And. (lAfast .Or. adetPgtoFl[nCntDetPgTo, 4] > 0 ) .And. aInfoPgto[nCntInfPgFl, 3] <> Nil .And. aInfoPgto[nCntInfPgFl, 4] <> Nil
					S1210A30(@cXml, { aInfoPgto[nCntInfPgFl][1], aInfoPgto[nCntInfPgFl][2], adetPgtoFl[nCntDetPgto][1], adetPgtoFl[nCntDetPgto][2], adetPgtoFl[nCntDetPgto][4], If(lGerarRGE, cPaisExt, Nil) }, .F.) //infoPgto S-1.0~
					lGerouXML := .T.
					If lGerarRGE
						nCntRGE1210 := 1
						If cVersEnvio >= "9.3" .And. nCntDetPgTo <= Len(aRGE1210)
							nCntRGE1210 := nCntDetPgTo
						EndIf
						S1210A18(@cXml, { aRGE1210[nCntRGE1210,2], aRGE1210[nCntRGE1210,3], aRGE1210[nCntRGE1210,12] }, .F.)//infoPgtoExt
						S1210A19(@cXml, { aRGE1210[nCntRGE1210,4], aRGE1210[nCntRGE1210,5], aRGE1210[nCntRGE1210,6], aRGE1210[nCntRGE1210,7], aRGE1210[nCntRGE1210,8], aRGE1210[nCntRGE1210,9], aRGE1210[nCntRGE1210,10], aRGE1210[nCntRGE1210,11] }, .T.)//endExt
						S1210F18(@cXml)//infoPgtoExt
					EndIf
					S1210F07(@cXml)//infoPgto
				EndIf
			Next nCntDetPgto
			For nCntRetFer := 1 To Len(aRetFer)
				If aInfoPgto[nCntInfPgFl, 1] == aRetFer[nCntRetFer, 6] .And. aInfoPgto[nCntInfPgFl, 3] == Nil .And. aInfoPgto[nCntInfPgFl, 4] == Nil
					S1210A30(@cXml, { aInfoPgto[nCntInfPgFl][1], aInfoPgto[nCntInfPgFl][2], aRetFer[nCntRetFer][12], aRetFer[nCntRetFer][13], aRetFer[nCntRetFer][5], If(lGerarRGE, cPaisExt, Nil) }, .F.)
					lGerouXML := .T.
					If lGerarRGE
						nCntRGE1210 := 1
						If cVersEnvio >= "9.3" .And. (Len(adetPgtoFl) + nCntRetFer) <= Len(aRGE1210)
							nCntRGE1210 := Len(adetPgtoFl) + nCntRetFer
						EndIf
						S1210A18(@cXml, { aRGE1210[nCntRGE1210,2], aRGE1210[nCntRGE1210,3], aRGE1210[nCntRGE1210,12] }, .F.)//infoPgtoExt
						S1210A19(@cXml, { aRGE1210[nCntRGE1210,4], aRGE1210[nCntRGE1210,5], aRGE1210[nCntRGE1210,6], aRGE1210[nCntRGE1210,7], aRGE1210[nCntRGE1210,8], aRGE1210[nCntRGE1210,9], aRGE1210[nCntRGE1210,10], aRGE1210[nCntRGE1210,11] }, .T.)//endExt
						S1210F18(@cXml)//infoPgtoExt
					EndIf
					S1210F07(@cXml)//infoPgto
				EndIf
			Next
		EndIf
	Else
		lFirstInfo	:= .T.
		lGerouInfo	:= .F.
		If aInfoPgto[nCntInfPgFl, 2] == "9"//Pagamento Anterior
			For nCntDetPgAt	:= 1 To Len(aDetPgtoAt)
				If aDetPgtoAt[nCntDetPgAt, 3] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2] //infoPgto -> aDetPgtoAt | dtPgto + tpPgto
					If lFirstInfo
						lFirstInfo	:= .F.
						lGerouInfo	:= .T.
						lGerouDetP	:= .T.
						S1210A07(@cXml, aInfoPgto[nCntInfPgFl], .F., cVersEnvio)//infoPgto
						S1210A15(@cXml, aDetPgtoAt[nCntDetPgAt], .F., cVersEnvio)//detPgtoAnt
					EndIf
					For nCntRetPgAt	:= 1 To Len(aPgtoAnt)
						If aDetPgtoAt[nCntDetPgAt, 3] == aPgtoAnt[nCntRetPgAt, 7] .And. Iif( ValType(aPgtoAnt[nCntRetPgAt, 3]) == "N", Abs(aPgtoAnt[nCntRetPgAt, 3]) > 0, Abs(aPgtoAnt[nCntRetPgAt, 6]) > 0 )//aDetPgtoAt -> aPgtoAnt | dtPgto + tpPgto
							S1210A24(@cXml, aPgtoAnt[nCntRetPgAt], .F.)//infoPgtoAnt
							For nCntRetPens	:= 1 To Len(aRetPensao)
								If aPgtoAnt[nCntRetPgAt, 1] == aRetPensao[nCntRetPens, 1] .And. aPgtoAnt[nCntRetPgAt, 7] == aRetPensao[nCntRetPens, 6]//aPgtoAnt -> aRetPensao | codRubr + dtPgto + tpPgto
									S1210A10(@cXml, {aRetPensao[nCntRetPens, 4], aRetPensao[nCntRetPens, 2],aRetPensao[nCntRetPens, 3],aRetPensao[nCntRetPens, 5]}, .T.)//penAlim
								EndIf
							Next nCntRetPens
							S1210F24(@cXml)//infoPgtoAnt
						EndIf
					Next nCntRetPgAt
				EndIf
			Next nCntDetPgAt
			If lGerouDetP
				S1210F15(@cXml)//detPgtoAnt
			EndIf
		ElseIf aInfoPgto[nCntInfPgFl, 2] == "7"//Ferias
			lGerouInfo	:= .T.
			S1210A07(@cXml, aInfoPgto[nCntInfPgFl], .F., cVersEnvio)//infoPgto
			If Len(aRGE1210) > 0
				S1210A17(@cXml, .F.)//idePgtoExt
				S1210A18(@cXml, { aRGE1210[1,1], aRGE1210[1,2], aRGE1210[1,3] }, .T.)//idePais
				S1210A19(@cXml, { aRGE1210[1,4], aRGE1210[1,5], aRGE1210[1,6], aRGE1210[1,7], aRGE1210[1,8], aRGE1210[1,9] }, .T.)//endExt
			Endif
			For nCntRetFer := 1 To Len(aRetFer)
				If aInfoPgto[nCntInfPgFl, 1] == aRetFer[nCntRetFer, 6]//infoPgto -> aRetFer | dtPgto
					S1210A21(@cXml, { aRetFer[nCntRetFer, 1], aRetFer[nCntRetFer, 2], aRetFer[nCntRetFer, 3], aRetFer[nCntRetFer, 4], aRetFer[nCntRetFer, 5] }, .F.)//detPgtoFer
					For nCntRubFer := 1 To Len(aRetFer[nCntRetFer, 7])
						S1210A22(@cXml, aRetFer[nCntRetFer, 7, nCntRubFer], .F.)//detRubrFer
						If lMiddleware
							fValPred(aRetFer[nCntRetFer, 7, nCntRubFer, 7], "S1010", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
						EndIf
						For nCntRetPens	:= 1 To Len(aRetPensao)
							If aRetFer[nCntRetFer, 7, nCntRubFer, 1] == aRetPensao[nCntRetPens, 1] .And. aRetFer[nCntRetFer, 2]+aRetFer[nCntRetFer, 6]+"7" == aRetPensao[nCntRetPens, 6]//aRetFer -> aRetPensao | codRubr + matricula + dtPgto + tpPgto
								S1210A23(@cXml, { aRetPensao[nCntRetPens, 4], aRetPensao[nCntRetPens, 2], aRetPensao[nCntRetPens, 3], aRetFer[nCntRetFer, 7, nCntRubFer, 6] }, .T.)//penAlim
							EndIf
						Next nCntRetPens
						S1210F22(@cXml)//detRubrFer
					Next nCntRubFer
					S1210F21(@cXml)//detPgtoFer
				EndIf
			Next nCntRetFer
		Else
			For nCntDetPgTo	:= 1 To Len(adetPgtoFl)
				If (adetPgtoFl[nCntDetPgTo, 7] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2]) .And. (lAfast .Or. adetPgtoFl[nCntDetPgTo, 4] > 0 .Or. aScan( aRetPgtoTot, { |x| x[7] == adetPgtoFl[nCntDetPgTo, 2] } ) > 0 ) //infoPgto -> detPgtoFl | dtPgto + tpPgto
					If !lGerouInfo
						lGerouInfo	:= .T.
						lGerarRGE	:= .T.
						S1210A07(@cXml, aInfoPgto[nCntInfPgFl], .F., cVersEnvio)//infoPgto
					Endif
					S1210A08(@cXml, adetPgtoFl[nCntDetPgTo], .F., cVersEnvio)//detPgtoFl

					For nCntRetPgTo	:= 1 To Len(aRetPgtoTot)
						If adetPgtoFl[nCntDetPgTo, 2] == aRetPgtoTot[nCntRetPgTo, 7]//detPgtoFl -> retPgtoTot | ideDmDev
							S1210A09(@cXml, aRetPgtoTot[nCntRetPgTo], .F.)//retPgtoTot
							If lMiddleware
								fValPred(aRetPgtoTot[nCntRetPgTo, 8], "S1010", cPeriodo, @aErros, lAdmPubl, cTpInsc, cNrInsc )
							EndIf
							For nCntRetPens	:= 1 To Len(aRetPensao)
								If aRetPgtoTot[nCntRetPgTo, 1] == aRetPensao[nCntRetPens, 1] .And. aRetPgtoTot[nCntRetPgTo, 7] == aRetPensao[nCntRetPens, 6]//retPgtoTot -> aRetPensao | codRubr + ideDmDev
									S1210A10(@cXml, {aRetPensao[nCntRetPens, 4], aRetPensao[nCntRetPens, 2],aRetPensao[nCntRetPens, 3],aRetPensao[nCntRetPens, 5]}, .T.)//penAlim
								EndIf
							Next nCntRetPens
							S1210F09(@cXml)//retPgtoTot
						EndIf
					Next nCntRetPgTo

					S1210F08(@cXml)//detPgtoFl
					If Len(aRGE1210) > 0 .And. lGerarRGE
						S1210A17(@cXml, .F.)//idePgtoExt
						S1210A18(@cXml, { aRGE1210[1,1], aRGE1210[1,2], aRGE1210[1,3] }, .T.)//idePais
						S1210A19(@cXml, { aRGE1210[1,4], aRGE1210[1,5], aRGE1210[1,6], aRGE1210[1,7], aRGE1210[1,8], aRGE1210[1,9] }, .T.)//endExt
						lGerarRGE := .F.
					EndIf
				EndIf
			Next nCntDetPgTo
		EndIf
		If lGerouInfo
			lGerouXML := .T.
			If Len(aRGE1210) > 0
				S1210F17(@cXml)//idePgtoExt
			Endif
			S1210F07(@cXml)//infoPgto
		EndIf
	EndIf //2.5
Next nCntInfPgFl

IF lRes
	For nCntInfPgFl	:= 1 To Len(aInfoPgto)
		For nCntDetPgTo	:= 1 To Len(adetPgtoFl)
			IF (adetPgtoFl[nCntDetPgTo, 7] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2]) .AND. (LEN(adetPgtoFl[nCntDetPgTo][2]) > 0 .AND. Left(adetPgtoFl[nCntDetPgTo][2],1) == "R")

				IF adetPgtoFl[nCntDetPgTo, 4] == 0
					nPosInfo := nCntInfPgFl
					nPosDet := nCntDetPgTo
				ELSE
					lNGeraInPgt := .T.
				ENDIF

			ENDIF
		NEXT nCntDetPgTo
	NEXT nCntInfPgFl
ENDIF

IF (!lGerouXML .Or. (lRes .And. !lNGeraInPgt )) .And. lAfast .And. LEN(aInfoPgto) > 0 .And. LEN(adetPgtoFl) > 0 .And. lPgtRes

	adetPgtoFl[nPosDet,4] := 0
	If cVersEnvio >= "9.0"
		If !lGerouXML
			S1210A30(@cXml, { aInfoPgto[nPosInfo][1], aInfoPgto[nPosInfo][2], adetPgtoFl[nPosDet][1], adetPgtoFl[nPosDet][2],adetPgtoFl[nPosDet][4] }, .T.) //infoPgto S-1.0
		EndIf
	EndIf

	lGerouXML := .T.
ENDIF

//<infoIRComplem>
If cVersEnvio >= "9.2"
	If Len(aDedDep) > 0 .Or. Len(aRetPensao) > 0 .Or. Len(aInfoPrev) > 0 .Or. Len(adadosRHS) > 0 .Or. Len(adadosRHP) > 0
		S1210A31(@cXml, aDepen, aDedDep, aRetPensao, aInfoPrev, adadosRHS, adadosRHP,cVersEnvio)
	Endif
Endif

S1210F05(@cXml)//ideBenef
S1210F02(@cXml)//evtPgtos
S1210F01(@cXml)//eSocial

If lMiddleware .And. lGerouXML .And. !Empty(aErros)
	lGerouXML := .F.
EndIf

Return lGerouXML

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fBenefici   ³ autor ³ Marcia Moura        ³ Data ³ 02/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carrega array com informacoes do cadastro de beneficiarios ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function fBenefic(cFilFun, cMatFun, dDataCalc, cCodVerba, nRdValor, cId, cPeriodo, cCodIR, lTSV, cCPFFun )

Local cAlias		:= ALIAS()
Local cMesAnoCalc	:= ""
Local nPos			:= 0
Local cCodIRF		:= ""
Local cCodRece		:= ""

Default cFilFun		:= ""
Default cMatFun		:= ""
Default dDataCalc	:= CTOD("//")
Default cCodVerba	:= ""
Default cId	 		:= ""
Default cPeriodo	:= ""
Default cCodIR		:= ""
Default lTSV 		:= .F.
Default cCPFFun		:= SRA->RA_CIC

//Para regime caixa, é necessário verificar o período do cálculo pois o pagamento ocorre no mês seguinte
If !Empty(cPeriodo)
	cMesAnoCalc := cPeriodo
Else
	cMesAnoCalc := AnoMes(dDataCalc)
EndIf

cCodIR := Alltrim(cCodIR)

If cCodIR $ "51|9051"		// Pensao Remuneração Mensal
	cCodIRF:= "11"
ElseIf cCodIR $ "52|9052"		// Pensao 13 Salario
	cCodIRF:= "12"
ElseIf cCodIR $ "53|9053"		// Pensao Ferias
	cCodIRF:= "13"
ElseIf cCodIR $ "54|9054"		// Pensao PLR
	cCodIRF:= "14"
ElseIf cCodIR $ "55"		// Pensao RRA
	cCodIRF:= "18"
Endif

cCodRece := fCodRece( lTSV , cCodIR  )

If nRdValor < 0
   nRdValor := ABS(nRdValor)
Endif

dbSelectArea( "SRQ" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com dados do cadastro de beneficiarios	     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If dbSeek( cFilFun + cMatFun )

	While SRQ->RQ_FILIAL + SRQ->RQ_MAT == cFilFun + cMatFun

		If SRQ->(FieldPos('RQ_DTINI')) > 0 .and. SRQ->(FieldPos('RQ_DTFIM')) > 0 .and.;
			(!Empty(SRQ->RQ_DTINI) .or. !Empty(SRQ->RQ_DTFIM))

			If (!Empty(SRQ->RQ_DTINI) .and. cMesAnoCalc < AnoMes(SRQ->RQ_DTINI)) .or.;
	 		   (!Empty(SRQ->RQ_DTFIM) .and. cMesAnoCalc > AnoMes(SRQ->RQ_DTFIM))
				dbSkip()
				Loop
			EndIf
		EndIf

		If cCodVerba $ (SRQ->RQ_VERBADT+"/"+SRQ->RQ_VERBFOL+"/"+SRQ->RQ_VERBFER+"/"+SRQ->RQ_VERB131+"/"+SRQ->RQ_VERB132+"/"+SRQ->RQ_VERBPLR+"/"+SRQ->RQ_VERBDFE+"/"+SRQ->RQ_VERBRRA) .Or. cCodIR == "55"
			nPos := ascan(aRetPensao,{|X| X[2] == dToS( SRQ->RQ_NASC ) .And. X[3] == SRQ->RQ_NOME .And. X[4] == SRQ->RQ_CIC .And. x[7] == cCPFFun .And. x[9] == cCodIRF .And. x[10]==cCodRece })
			If nPos == 0
				Aadd (aRetPensao, { cCodVerba, Iif( !lMiddleware .Or. !Empty(SRQ->RQ_NASC), dToS(SRQ->RQ_NASC), Nil), SRQ->RQ_NOME, SRQ->RQ_CIC, nRdValor, cId, cCPFFun, SRQ->RQ_ORDEM, cCodIRF, cCodRece, cFilFun, cMatFun})
				If Empty(SRQ->RQ_CIC)
					aAdd(aLogCIC, SRQ->RQ_NOME)
				EndIf
			else
				aRetPensao[nPos,5] += nRdValor
			Endif

		EndIf

		dbSkip()
	EndDo
EndIf
dbSelectArea( cAlias )

Return .T.

/*/{Protheus.doc} fm036GetFer
Função responsável por pesquisar e gerar os dados de ferias nas tabelas SRH e SRR para geracao do evento S-1210
@Author.....: Marcelo Silveira
@Since......: 08/05/2018
@Version....: 1.0
@Param......: (char) - cFilFun - Filial do funcionario para a pesquisa nas tabelas SRH e SRR
@Param......: (char) - cMatFun - Matricula do funcionario para a pesquisa
@Param......: (char) - cDtPesqI - Data inicial do período para a pesquisa
@Param......: (char) - cDtPesqF - Data final do período para a pesquisa
@Param......: (char) - cCateg - Categoria do funcionario
@Param......: (array) - aVbFer - Array de referencia para armazenamento das verbas de ferias avaliadas
@Param......: (array) - aErros - Retorno de possíveis erros na geração do evento
@Param......: (char) - cFilPreTrf - Filial de origem do funcionario para posicionamento da SRV
@Param......: (char) - cCPFFun - CPF do Funcionário
@Return.....: (array) - aFer - Array de retorno com os dados de ferias do funcionario
/*/
Static Function fm036GetFer( cFilFun, cMatFun, cDtPesqI, cDtPesqF, cCateg, aVbFer, aErros, cFilPreTrf, cCPFFun )

Local cAliasSRH	:= "QSRH"
Local cIdPdv	:= ""
Local nNumReg	:= 0
Local nPercRub	:= 0
Local nVbFer	:= 0
Local nPosFerPd	:= 0
Local aFer		:= {}
Local aFerPd	:= {}
Local lGeraCod	:= .F.
Local cIdTbRub	:= ""
Local lPrimIdT	:= .T.
Local cIdeRubr	:= ""
Local cTSV		:= fCatTrabEFD("TSV")
Local lTSV      := .F.

Default cFilFun		:= ""
Default cMatFun		:= ""
Default cDtPesqI	:= ""
Default cDtPesqF	:= ""
Default cCateg		:= ""
Default aVbFer		:= {}
Default aErros		:= {}
Default cFilPreTrf	:= ""
Default cCPFFun		:= ""

lTSV 	:= cCateg $ cTSV

DEFAULT aErros	:= {}

If ( Select( cAliasSRH ) > 0 )
	( cAliasSRH )->( dbCloseArea() )
EndIf

If __oSt11 == Nil
	__oSt11 := FWPreparedStatement():New()
	cQrySt := "SELECT Count(*) AS NUMREG "
	cQrySt += "FROM " + RetSqlName('SRH') + " SRH "
	cQrySt += "WHERE SRH.RH_FILIAL = ? AND "
	cQrySt += 		"SRH.RH_MAT = ? AND "
	cQrySt += 		"SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
	cQrySt += 		"SRH.D_E_L_E_T_ = ' ' "
	cQrySt := ChangeQuery(cQrySt)
	__oSt11:SetQuery(cQrySt)
EndIf
__oSt11:SetString(1, cFilFun)
__oSt11:SetString(2, cMatFun)
cQrySt := __oSt11:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRH,.T.,.T.)

nNumReg := (cAliasSRH)->NUMREG
( cAliasSRH )->( dbCloseArea() )

If nNumReg > 0
	If __oSt12 == Nil
		__oSt12 := FWPreparedStatement():New()
		cQrySt := "SELECT RH_FILIAL,RH_MAT,RH_PROCES,RH_PERIODO,RH_ROTEIR,RH_DTRECIB,RH_DFERIAS,RH_DATAINI,RH_DTRECIB "
		cQrySt += "FROM " + RetSqlName('SRH') + " SRH "
		cQrySt += "WHERE SRH.RH_FILIAL = ? AND "
		cQrySt += 		"SRH.RH_MAT = ? AND "
		cQrySt += 		"SRH.RH_DTRECIB BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND "
		cQrySt += 		"SRH.D_E_L_E_T_ = ' ' "
		cQrySt := ChangeQuery(cQrySt)
		__oSt12:SetQuery(cQrySt)
	EndIf
	__oSt12:SetString(1, cFilFun)
	__oSt12:SetString(2, cMatFun)
	cQrySt := __oSt12:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRH,.T.,.T.)

	DbSelectArea("SRR")
	DbSetOrder(RetOrder("SRR","RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC"))

	While (cAliasSRH)->(!Eof())

		//			  codCateg,	matricula,	dtIniGoz,					qtDias,						vrLiq,	Data pagamento (recibo)
		aAdd( aFer, { cCateg, SRA->RA_CODUNIC, (cAliasSRH)->(RH_DATAINI), (cAliasSRH)->(RH_DFERIAS),	0,	(cAliasSRH)->(RH_DTRECIB), {}, SRA->RA_CIC, SRA->RA_FILIAL, SRA->RA_MAT + " - " + SRA->RA_CODUNIC, SRA->RA_NOMECMP, (cAliasSRH)->RH_PERIODO, "", 0 } )

		If SRR->( DbSeek( (cAliasSRH)->RH_FILIAL + (cAliasSRH)->RH_MAT + "F" + (cAliasSRH)->(RH_DATAINI) ) )

			While SRR->(!Eof() .and. RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA) == (cAliasSRH)->RH_FILIAL+(cAliasSRH)->RH_MAT+"F"+(cAliasSRH)->RH_DATAINI )

				nVbFer := aScan( aVbFer, { |x| x[1] == SRR->RR_PD })

				//Tratamento para evitar o uso da PosSrv devido desempenho
				PosSrv( SRR->RR_PD, cFilPreTrf )
				If nVbFer > 0
					nPercRub 	:= aVbFer[nVbFer,2]
					cIncIRF 	:= aVbFer[nVbFer,3]
					cIdPdv 		:= aVbFer[nVbFer,4]
				Else
					aAdd( aVbFer, { SRR->RR_PD, SRV->RV_PERC, SRV->RV_INCIRF, SRV->RV_CODFOL } )
					nPercRub 	:= SRV->RV_PERC - 100
					cIncIRF  	:= SRV->RV_INCIRF
					cIdPdv 		:= SRV->RV_CODFOL
				EndIf

				If cVersEnvio >= "9.0"
					If cIdPdv $ "102|0102" //Liquido de Ferias para gerar a Tag <vrLiq>
						aFer[Len(aFer),5] += SRR->RR_VALOR
					EndIf
					If cVersEnvio >= "9.2"
						If Val(cIncIRF) == 53 .Or. Val(cIncIRF) == 9053
							fBenefic( (cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, stod((cAliasSRH)->RH_DTRECIB), SRR->RR_PD, SRR->RR_VALOR, SRA->RA_CODUNIC + (cAliasSRH)->RH_DTRECIB + "7" , cPeriodo, cIncIRF, lTSV, cCPFFun)
						EndIf
						If (Val(cIncIRF) >= 46 .And. Val(cIncIRF) <= 48) .Or. (Val(cIncIRF) >= 61 .And. Val(cIncIRF) <= 66) .Or. (Val(cIncIRF) >= 9046 .And. Val(cIncIRF) <= 9048) .Or. (Val(cIncIRF) >= 9061 .And. Val(cIncIRF) <= 9066)
							fGetPrev( SRR->RR_PD, (cAliasSRH)->RH_PERIODO, cIncIRF, IIf(SRV->RV_TIPOCOD $ '2*4', SRR->RR_VALOR * -1, SRR->RR_VALOR), lTSV )
						EndIf
					Endif
					//Ajusta posição que guarda o valor de dedução do IRRF
					If cVersEnvio >= "9.3" .And. Alltrim(cIncIRF) $ "31|32|33|34|35"
						aFer[Len(aFer), 14] += Iif(SRV->RV_TIPOCOD $ '2*4', SRR->RR_VALOR, SRR->RR_VALOR * -1)
					EndIf
				Else
					cIncIRF 	:= SubStr(cIncIRF, 1, 2)
					If !Empty(xFilial("SRV"))
						lGeraCod := .T.
					EndIf
					If lGeraCod
						cIdTbRub := SRV->RV_FILIAL
					Else
						If cVersEnvio >= "2.3"
							cIdTbRub := cEmpAnt
						Else
							cIdTbRub := ""
						EndIf
					EndIf

					If lMiddleware
						If lPrimIdT
							lPrimIdT  := .F.
							cIdeRubr := fGetIdRJF( SRV->RV_FILIAL, cIdTbRub )
							If Empty(cIdeRubr) .And. aScan(aErros, { |x| x == OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) }) == 0
								aAdd( aErros, OemToAnsi(STR0156) + cIdTbRub + OemToAnsi(STR0157) )//"Atenção"##"Não será possível efetuar a integração. O identificador de tabela de rubrica do código: "##" não está cadastrado."
							EndIf
						EndIf
						cIdTbRub := cIdeRubr
					EndIf

					nPosFerPd := aScan( aFerPd, { |x| x[1] == SRR->RR_PD} )
					If nPosFerPd > 0
						If cIncIRF $ "00|01|09|13|33|43|46|53|63|75|93" .And. !(cIdPdv $ "102|0102")
							aFerPd[nPosFerPd][3] += SRR->RR_HORAS
							aFerPd[nPosFerPd][6] += SRR->RR_VALOR

							If cIncIRF == "53"
								fBenefic( (cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, stod((cAliasSRH)->RH_DTRECIB), SRR->RR_PD, SRR->RR_VALOR, SRA->RA_CODUNIC + (cAliasSRH)->RH_DTRECIB + "7" , cPeriodo)
							EndIf
						Endif

						If cIdPdv $ "102|0102"
							aFerPd[nPosFerPd][5] += SRR->RR_VALOR
						Endif
					Else
						If cIncIRF $ "00|01|09|13|33|43|46|53|63|75|93" .And. !(cIdPdv $ "102|0102")
							//				codRubr, 	ideTabRubr, 	qtdRubr, 			fatorRubr, 												vrUnit, 	  vrRubr
							aAdd( aFerPd, { SRR->RR_PD, cIdTbRub, SRR->RR_HORAS, If( nPercRub < 0, 0, Transform(nPercRub,"@E 999.99")), /*nao enviar*/,SRR->RR_VALOR, (SRV->RV_FILIAL+SRR->RR_PD) } )
							If cIncIRF == "53"
								fBenefic( (cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, stod((cAliasSRH)->RH_DTRECIB), SRR->RR_PD, SRR->RR_VALOR, SRA->RA_CODUNIC + (cAliasSRH)->RH_DTRECIB + "7", cPeriodo )
							EndIf
						EndIf

						If cIdPdv $ "102|0102" //Liquido de Ferias para gerar a Tag <vrLiq>
							aFer[Len(aFer),5] += SRR->RR_VALOR
						EndIf
					Endif
				EndIf

				SRR->(DbSkip())
			EndDo

		EndIf

		If Len( aFerPd ) > 0
			aFer[Len(aFer)][7] := aClone(aFerPd)
			aFerPd := Array(0)
		EndIf

		(cAliasSRH)->(DbSkip())
	EndDo

EndIf

Return( aFer )

/*/{Protheus.doc} fGetRGE()
Função responsável por verificar histórico do contrato de trabalho
de residentes no exterior, gravação do array axxx com os dados da tabela RGE para o evento S-1210
@type function
@author Claudinei Soares
@since 22/11/2018
@version 1.1
@param cFilRGE		= Filial a ser pesquisada na tabela RGE
@param cMatRGE 		= Matrícula a ser pesquisada na tabela RGE
@param cCompete 	= Período informado na geração do evento servirá como base para buscar a vigência do contrato
@return aRGE, Array, Retorno da função, campos da RGE que serão enviados no XML
/*/

Function fGetRGE(cFilRGE, cMatRGE, cCompete)

Local cUltimoD		:= STRZERO(f_UltDia(CTOD( "01/"+SUBSTR(cCompete,1,2)+"/"+SUBSTR(cCompete,3,4) )),2)
Local cIndNif		:= ""

Local dIniContr		:= CTOD("//")
Local dFimContr		:= CTOD("//")
Local dCompIni 		:= CTOD( "01/"+SUBSTR(cCompete,1,2)+"/"+SUBSTR(cCompete,3,4) )
Local dCompFim 		:= CTOD( cUltimoD +"/"+ SUBSTR(cCompete,1,2) +"/"+ SUBSTR(cCompete,3,4) )

Local aArea			:= GetArea()
Local aItensRGE		:= {}

dbSelectArea("RGE")
RGE->( dbSetOrder(2) )
RGE->(dbGoTop())

If RGE->( dbSeek( cFilRGE + cMatRGE ) )
	While RGE->( !Eof() .And. RGE->RGE_FILIAL == cFilRGE .And. RGE->RGE_MAT == cMatRGE )
		dIniContr := RGE->RGE_DATAIN
		dFimContr := RGE->RGE_DATAFI

		If dIniContr <= dCompIni .And. (dFimContr >= dCompFim .Or. Empty(dFimContr))

			cIndNif := ( If(RGE->RGE_PAEXNI == "2", "3", IIF (RGE->RGE_BEDINI=="2","1",IF(RGE->RGE_BEDINI=="1","2",""))))

			aAdd(aItensRGE, {	Alltrim(RGE->RGE_CODPAI)	,;	//Código do Pais		- TAG <paisResidExt> do S-1210
								Alltrim(cIndNif)			,;	//Indicativo do NIF		- TAG <indNIF>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_CODNIF), Alltrim(RGE->RGE_CODNIF), Nil),;	//Código do NIF			- TAG <nifBenef>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_LOGRAD), Alltrim(RGE->RGE_LOGRAD), Nil),;	//Logradouro 			- TAG <endDscLograd>	do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_NUMERO), Alltrim(RGE->RGE_NUMERO), Nil),;	//Número do Endereço	- TAG <endNrLograd>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_COMPL),  Alltrim(RGE->RGE_COMPL),  Nil),;	//Complemento Endereço	- TAG <endComplem>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_BAIRRO), Alltrim(RGE->RGE_BAIRRO), Nil),;	//Bairro				- TAG <endBairro>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_CIDADE), Alltrim(RGE->RGE_CIDADE), Nil),;	//Cidade				- TAG <endCidade>		do S-1210
								If(!lMiddleware .Or. !Empty(RGE->RGE_ESTPRO), Alltrim(RGE->RGE_ESTPRO), Nil),;	//Estado			- TAG <endEstado>
								If(!lMiddleware .Or. !Empty(RGE->RGE_CODPOS), Alltrim(RGE->RGE_CODPOS), Nil),;	//Cód Postal (CEP)	- TAG <endCodPostal>
								If(!lMiddleware .Or. !Empty(RGE->RGE_TELEFO), Alltrim(RGE->RGE_TELEFO), Nil),;	//Telefone			- TAG <telef>
								AllTrim(RGE->RGE_FRMTRB) })														//Forma Tributação	- TAG <frmTribut>

			Exit
		Endif

		RGE->(dbSkip())
	EndDo
EndIf

RestArea(aArea)

Return( aItensRGE )

/*/{Protheus.doc} fQtdeFolMV()
Função que verifica a quantidade matriculas no Periodo de acordo com o filtro por data de pagamento
@type function
@author allyson.mesashi
@since 27/02/2019
@version 1.0
@param cOpcTab		= Indica se considerada a tabela SRC
@param cFilProc		= Filiais para busca
@param cPeriodo		= Periodo de busca
@param cDtPesqI		= Data de pagamento inicial
@param cDtPesqF		= Data de pagamento final
@return nQtde		= Quantidade de matriculas no periodo
/*/
Static Function fQtdeFolMV(cOpcTab, cPeriodo, cDtPesqI, cDtPesqF)

Local aArea		:= GetArea()
Local cAliasMV	:= GetNextAlias()
Local cJoinRCxRY:= FWJoinFilial( "SRC", "SRY" )
Local cJoinRDxRY:= FWJoinFilial( "SRD", "SRY" )
Local cQrySt	:= ""
Local nParam	:= 0
Local nQtde		:= 1

If __oSt17_2 == Nil
	__oSt17_2 := FWPreparedStatement():New()
	cQrySt := "SELECT SRA.RA_CIC, COUNT(*) AS CONT FROM " + RetSqlName('SRA') + " SRA "
	IF lTemGC .And. lTemEmp
		cQrySt += "WHERE SUBSTRING(SRA.RA_FILIAL, " + cValToChar(nIniEmp) + ", " + cValToChar(nTamEmp) + ") = ? AND "
	Else
		cQrySt += "WHERE "
	EndIf
	cQrySt += "SRA.RA_CIC >= ? AND SRA.RA_CIC <= ? "
	cQrySt += "AND SRA.RA_CC <> ' ' "
	If cOpcTab == "1"
		cQrySt += "AND EXISTS (SELECT DISTINCT SRC.RC_FILIAL, SRC.RC_MAT FROM " + RetSqlName('SRC') + " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY + " AND SRC.RC_ROTEIR = SRY.RY_CALCULO WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_PERIODO = ? AND SRC.RC_DATA BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRC.RC_TIPO2 != 'K' AND SRC.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
		cQrySt += "UNION "
		cQrySt += "SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
	Else
		cQrySt += "AND EXISTS (SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND SRD.RD_DATPGT BETWEEN '" + cDtPesqI + "' AND '" + cDtPesqF + "' AND SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
	EndIf
	cQrySt += "AND SRA.D_E_L_E_T_ = ' ' "
	cQrySt += "GROUP BY SRA.RA_CIC "
	cQrySt := ChangeQuery(cQrySt)
	__oSt17_2:SetQuery(cQrySt)
EndIf
IF lTemGC .And. lTemEmp
	__oSt17_2:SetString(++nParam, SubString(SRA->RA_FILIAL, nIniEmp, nTamEmp) )
EndIf
__oSt17_2:SetString(++nParam, SRA->RA_CIC)
__oSt17_2:SetString(++nParam, SRA->RA_CIC)
__oSt17_2:SetString(++nParam, cPeriodo)
If cOpcTab == "1"
	__oSt17_2:SetString(++nParam, cPeriodo)
EndIf
cQrySt := __oSt17_2:getFixQuery()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasMV,.T.,.T.)
nQtde := (cAliasMV)->CONT

(cAliasMV)->( dbCloseArea() )

RestArea(aArea)
Return nQtde

/*/{Protheus.doc} lTem546
//Checa se tem a verba de ID 0546
@author flavio.scorrea
@since 06/05/2019
/*/
Static Function lTem546(cFilFun,cMatFun,dData1,dData2,cPd)
Local lRet		:= .F.
Local cAliasTmp	:= GetNextAlias()

BeginSQL Alias cAliasTmp
	SELECT RC_PD
	FROM %Table:SRC% SRC
	WHERE RC_FILIAL = %Exp:cFilFun%
	AND RC_MAT = %Exp:cMatFun%
	AND RC_DATA BETWEEN %Exp:dData1% AND %Exp:dData2%
	AND SRC.%NotDel%
	AND RC_PD = %Exp:cPd%
	UNION
	SELECT RD_PD AS RC_PD
	FROM %Table:SRD% SRD
	WHERE RD_FILIAL = %Exp:cFilFun%
	AND RD_MAT = %Exp:cMatFun%
	AND RD_DATPGT BETWEEN %Exp:dData1% AND %Exp:dData2%
	AND SRD.%NotDel%
	AND RD_PD = %Exp:cPd%
EndSQL
lRet := !(cAliasTmp)->(Eof())
(cAliasTmp)->(DbCloseArea())
Return lRet

/*/{Protheus.doc} fFerPreTrf
Verifica SRE para transferência posterior às férias no período da consulta à SRH, SRR
	@type	Function
	@author	isabel.noguti
	@since	13/01/2020
	@version 1.0
	@param	cSRHFil, char, Filial a ser consultada na SRH
	@param	cSRHMat, char, Matricula a ser consultada na SRH
	@param	cDtPesq, char, Data final do período
	@return	lRet, logic, Matrícula destino possui SRH no período, transferida da matrícula de origem
/*/
Static Function fFerPreTrf( cSRHFil, cSRHMat, cDtPesq )
	Local cAliasSRE	:= GetNextAlias()
	Local cQrySt	:= ""
	Local lRet		:= .F.

	If __oSt18 == Nil
		__oSt18 := FWPreparedStatement():New()
		cQrySt := "SELECT COUNT(*) QTD FROM "
		cQrySt += RetSqlName('SRH') + " SRH INNER JOIN " + RetSqlName('SRE') + " SRE ON SRH.RH_FILIAL = SRE.RE_FILIALP AND SRH.RH_MAT = SRE.RE_MATP "
		cQrySt += "WHERE SRE.RE_FILIALP = ? AND SRE.RE_MATP = ? "
		cQrySt += "AND SRH.RH_DTRECIB <= ? AND SRE.RE_DATA > ? "
		cQrySt += "AND SRE.RE_EMPP = ? "
		cQrySt += "AND (SRE.RE_FILIALD <> SRE.RE_FILIALP OR SRE.RE_MATD <> SRE.RE_MATP) "
		cQrySt += "AND SRH.D_E_L_E_T_ = ' ' AND SRE.D_E_L_E_T_ = ' ' "
		cQrySt := ChangeQuery(cQrySt)
		__oSt18:SetQuery(cQrySt)
	EndIf
	__oSt18:SetString(1, cSRHFil)
	__oSt18:SetString(2, cSRHMat)
	__oSt18:SetString(3, cDtPesq)
	__oSt18:SetString(4, cDtPesq)
	__oSt18:SetString(5, cEmpAnt)
	cQrySt := __oSt18:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRE,.T.,.T.)

	If (cAliasSRE)->QTD > 0
		lRet := .T.
	EndIf
	(cAliasSRE)->(DbCloseArea())

	If !lRet .And. SRA->RA_SITFOLH == "D" .And. SRA->RA_RESCRAI $ "30|31"
		If __oSt19 == Nil
			__oSt19 := FWPreparedStatement():New()
			cQrySt := "SELECT SRE.RE_FILIALP, SRE.RE_MATP FROM "
			cQrySt += RetSqlName('SRH') + " SRH INNER JOIN " + RetSqlName('SRE') + " SRE ON SRH.RH_FILIAL = SRE.RE_FILIALP AND SRH.RH_MAT = SRE.RE_MATP "
			cQrySt += "WHERE SRE.RE_FILIALD = ? AND SRE.RE_MATD = ? "
			cQrySt += "AND SRH.RH_DTRECIB <= ? AND SRE.RE_DATA > ? "
			cQrySt += "AND SRE.RE_EMPP = ? "
			cQrySt += "AND SRH.D_E_L_E_T_ = ' ' AND SRE.D_E_L_E_T_ = ' ' "
			cQrySt += "ORDER BY SRE.RE_DATA DESC "
			cQrySt := ChangeQuery(cQrySt)
			__oSt19:SetQuery(cQrySt)
		EndIf
		__oSt19:SetString(1, cSRHFil)
		__oSt19:SetString(2, cSRHMat)
		__oSt19:SetString(3, cDtPesq)
		__oSt19:SetString(4, cDtPesq)
		__oSt19:SetString(5, cEmpAnt)
		cQrySt := __oSt19:getFixQuery()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasSRE,.T.,.T.)

		If !(cAliasSRE)->(Eof())
			cSRHFil := (cAliasSRE)->RE_FILIALP
			cSRHMat := (cAliasSRE)->RE_MATP
			Iif( nQtdeFol > 1, nQtdeFol --, nQtdeFol )
		EndIf
		(cAliasSRE)->(DbCloseArea())
	EndIf

Return lRet

/*/{Protheus.doc} fGeraRelat
Função que gera o relatório em Excel
@author Allyson
@since 08/05/2020
@version 1.0
/*/
Static Function fGeraRelat(cCompete, lAfast)

Local cArquivo  	:= "RELATORIO_PERIODICOS_1210_"+cCompete+".xls"
Local cDefPath		:= GetSrvProfString( "StartPath", "\system\" )
Local cPath     	:= ""
Local cTpRend		:= ""
Local cTpPrev		:= ""
Local nCntIdeBen	:= 0
Local nCntInfPgFl	:= 0
Local nCntDetPgTo	:= 0
Local nCntRetFer 	:= 0
Local nCntIncons	:= 0
Local nCntCodRece	:= 0
Local nCtDep		:= 0
Local nCtPens		:= 0
Local nCtPrevComp	:= 0
Local nCntPla		:= 0
Local nPlaD			:= 0
Local nCntCop		:= 0
Local nCntCopTit	:= 0
Local nCntCopDep	:= 0
Local oTpRend		:= Nil
Local oTpPrev		:= Nil
Local oExcelApp 	:= Nil
Local oExcel

//Cria objeto com tipo de rendimento
oTpRend			:= JSONObject():New()
oTpRend["11"]	:= OemToAnsi(STR0263) //"11 - Remuneração mensal"
oTpRend["12"]	:= OemToAnsi(STR0264) //"12 - 13º salário"
oTpRend["13"]	:= OemToAnsi(STR0265) //"13 - Férias"
oTpRend["14"]	:= OemToAnsi(STR0266) //"14 - PLR"
oTpRend["15"]	:= OemToAnsi(STR0267) //"15 - RRA"
oTpRend["79"]	:= OemToAnsi(STR0268) //"79 - Rendimento isento ou não tributável"

//Cria objeto com tipo de previdência complementar
oTpPrev			:= JSONObject():New()
oTpPrev["1"]	:= OemToAnsi(STR0270) //"1 - Privada"
oTpPrev["2"]	:= OemToAnsi(STR0271) //"2 - FAPI"
oTpPrev["3"]	:= OemToAnsi(STR0272) //"3 - Funpresp"

If !IsBlind()
	cPath	:= cGetFile( OemToAnsi(STR0083) + "|*.*", OemToAnsi(STR0084), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )//"Diretório"##"Selecione um diretório para a geração do relatório"
Else
	cPath	:= cDefPath
EndIf

oExcel  := FWMSExcel():New()

cAbaPag		:= OemToAnsi(STR0181)//"Pagamentos"
cAbaDedDep	:= OemToAnsi(STR0274)//"Ded. Dependente"
cAbaPens	:= OemToAnsi(STR0183)//"Pensão Aliment."
cAbaPlSau	:= OemToAnsi(STR0275)//"Plano de Saúde"
cAbaReemb	:= OemToAnsi(STR0277)//"Reembolso Pl. Saúde"
cAbaPrev	:= OemToAnsi(STR0276)//"Prev. Complementar"
cAbaInc		:= OemToAnsi(STR0090)//"Inconsistências"
cAbaLeg		:= OemToAnsi(STR0091)//"Legenda"

cTabPag		:= OemToAnsi(STR0181)//"Pagamentos"
cTabDedDep	:= OemToAnsi(STR0278)//"Dedução Dependente"
cTabPens	:= OemToAnsi(STR0184)//"Pensão Alimentícia"
cTabPlSau	:= OemToAnsi(STR0279)//"Plano de Saúde"
cTabReemb	:= OemToAnsi(STR0280)//"Reembolso Plano de Saúde"
cTabPrev	:= OemToAnsi(STR0281)//"Previdência Complementar"
cTabInc		:= OemToAnsi(STR0090)//"Inconsistências"
cTabLeg		:= OemToAnsi(STR0091)//"Legenda"

// Criação abas conforme ordem abaixo
oExcel:AddworkSheet(cAbaPag)
oExcel:AddworkSheet(cAbaDedDep)
oExcel:AddworkSheet(cAbaPens)
oExcel:AddworkSheet(cAbaPlSau)
oExcel:AddworkSheet(cAbaReemb)
oExcel:AddworkSheet(cAbaPrev)
oExcel:AddworkSheet(cAbaInc)
oExcel:AddworkSheet(cAbaLeg)

// Criação de tabela
oExcel:AddTable(cAbaPag, cTabPag)
oExcel:AddTable(cAbaDedDep, cTabDedDep)
oExcel:AddTable(cAbaPens, cTabPens)
oExcel:AddTable(cAbaPlSau, cTabPlSau)
oExcel:AddTable(cAbaReemb, cTabReemb)
oExcel:AddTable(cAbaPrev, cTabPrev)
oExcel:AddTable(cAbaInc, cTabInc)
oExcel:AddTable(cAbaLeg, cTabLeg)

// Criação de colunas Aba 1 - Pagamentos
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcionário"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0102) ,1,1,.F.)//"Matricula - Matrícula eSocial"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0187) ,1,1,.F.)//"Data de Pagamento"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0099) ,1,1,.F.)//"ideDmDev"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0188) ,1,1,.F.)//"Tipo do Pagamento"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0189) ,1,1,.F.)//"Mês de referência"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0190) ,1,3,.F.)//"Valor líquido"
oExcel:AddColumn(cAbaPag, cTabPag, OemToAnsi(STR0194) ,1,3,.F.)//"Valor dependentes"

// Criação de colunas Aba 2 - Ded. Dependente
oExcel:AddColumn(cAbaDedDep, cTabDedDep, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAbaDedDep, cTabDedDep, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAbaDedDep, cTabDedDep, OemToAnsi(STR0282) ,1,1,.F.)//"Código de Receita"
oExcel:AddColumn(cAbaDedDep, cTabDedDep, OemToAnsi(STR0283) ,1,1,.F.)//"CPF do Dependente"
oExcel:AddColumn(cAbaDedDep, cTabDedDep, OemToAnsi(STR0284) ,1,1,.F.)//"Nome do Dependente"
oExcel:AddColumn(cAbaDedDep, cTabDedDep, OemToAnsi(STR0285) ,1,1,.F.)//"Tipo de Rendimento"
oExcel:AddColumn(cAbaDedDep, cTabDedDep, OemToAnsi(STR0286) ,1,1,.F.)//"Valor de Dedução Dependente"

//Criação de colunas Aba 3 - Pensão Aliment.
oExcel:AddColumn(cAbaPens, cTabPens, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAbaPens, cTabPens, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAbaPens, cTabPens, OemToAnsi(STR0287) ,1,1,.F.)//"CPF do Pensionista"
oExcel:AddColumn(cAbaPens, cTabPens, OemToAnsi(STR0288) ,1,1,.F.)//"Nome do Pensionista"
oExcel:AddColumn(cAbaPens, cTabPens, OemToAnsi(STR0285) ,1,1,.F.)//"Tipo de Rendimento"
oExcel:AddColumn(cAbaPens, cTabPens, OemToAnsi(STR0290) ,1,1,.F.)//"Valor de Dedução Pensão Alimentícia"

//Criação de colunas Aba 4 - Plano de Saúde
oExcel:AddColumn(cAbaPlSau, cTabPlSau, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAbaPlSau, cTabPlSau, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAbaPlSau, cTabPlSau, OemToAnsi(STR0291) ,1,1,.F.)//"Origem Lançamento"
oExcel:AddColumn(cAbaPlSau, cTabPlSau, OemToAnsi(STR0283) ,1,1,.F.)//"CPF do Dependente"
oExcel:AddColumn(cAbaPlSau, cTabPlSau, OemToAnsi(STR0284) ,1,1,.F.)//"Nome do Dependente"
oExcel:AddColumn(cAbaPlSau, cTabPlSau, OemToAnsi(STR0292) ,1,1,.F.)//"CNPJ do Operador"
oExcel:AddColumn(cAbaPlSau, cTabPlSau, OemToAnsi(STR0293) ,1,1,.F.)//"Registro ANS"
oExcel:AddColumn(cAbaPlSau, cTabPlSau, OemToAnsi(STR0294) ,1,3,.F.)//"Valor do Plano de Saúde"

//Criação de colunas Aba 5 - Reembolso Pl. Saúde
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0291) ,1,1,.F.)//"Origem Lançamento"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0283) ,1,1,.F.)//"CPF do Dependente"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0284) ,1,1,.F.)//"Nome do Dependente"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0292) ,1,1,.F.)//"CNPJ do Operador"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0293) ,1,1,.F.)//"Registro ANS"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0295) ,1,1,.F.)//"Ind. de Origem"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0296) ,1,1,.F.)//"Tp. Insc. Prestador"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0297) ,1,1,.F.)//"Nr. Insc. Prestador"
oExcel:AddColumn(cAbaReemb, cTabReemb, OemToAnsi(STR0298) ,1,3,.F.)//"Valor do Reembolso"

//Criação de colunas Aba 6 - PPrev. Complementar
oExcel:AddColumn(cAbaPrev, cTabPrev, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAbaPrev, cTabPrev, OemToAnsi(STR0097) ,1,1,.F.)//"Nome do Funcionário"
oExcel:AddColumn(cAbaPrev, cTabPrev, OemToAnsi(STR0299) ,1,1,.F.)//"Tipo de Previdência Complementar"
oExcel:AddColumn(cAbaPrev, cTabPrev, OemToAnsi(STR0300) ,1,1,.F.)//"CNPJ da Entidade"
oExcel:AddColumn(cAbaPrev, cTabPrev, OemToAnsi(STR0301) ,1,3,.F.)//"Valor de Dedução Previdência Complementar"
oExcel:AddColumn(cAbaPrev, cTabPrev, OemToAnsi(STR0302) ,1,3,.F.)//"Valor de Dedução Previdência Complementar"

//Criação de colunas Aba 7 - Inconsistências
oExcel:AddColumn(cAbaInc, cTabInc, OemToAnsi(STR0095) ,1,1,.F.)//"Filial do Funcionário"
oExcel:AddColumn(cAbaInc, cTabInc, OemToAnsi(STR0096) ,1,1,.F.)//"CPF do Funcionário"
oExcel:AddColumn(cAbaInc, cTabInc, OemToAnsi(STR0132) ,1,1,.F.)//"Inconsistências"

//Criação de colunas Aba 8 - Legendas
oExcel:AddColumn(cAbaLeg, cTabLeg, OemToAnsi(STR0133) ,1,1,.F.)//"Tipo"
oExcel:AddColumn(cAbaLeg, cTabLeg, OemToAnsi(STR0106) ,1,1,.F.)//"Valor"

//Copia array com dados de plano de saúde de todos
aDadosRHS := aClone(aRelRHS)
aDadosRHP := aClone(aRelRHP)

//Geração das informações
For nCntIdeBen := 1 To Len(aIdeBenef)
	lGerouInfo := .F.
	For nCntInfPgFl	:= 1 To Len(aInfoPgto)
		If aInfoPgto[nCntInfPgFl, 5] == aIdeBenef[nCntIdeBen, 1]//aIdeBenef -> aInfoPgto | CPF
			For nCntRetFer := 1 To Len(aRetFer)
				If aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 5] == aRetFer[nCntRetFer, 6] + aRetFer[nCntRetFer, 8] .And. aInfoPgto[nCntInfPgFl, 3] == Nil .And. aInfoPgto[nCntInfPgFl, 4] == Nil//infoPgto -> aRetFer | dtPgto + CPF
					lGerouInfo := .T.
					oExcel:AddRow(cAbaPag, cTabPag, { aRetFer[nCntRetFer, 9], aRetFer[nCntRetFer, 10], aRetFer[nCntRetFer, 8], aRetFer[nCntRetFer, 11], dToC(sToD(aInfoPgto[nCntInfPgFl, 1])), aRetFer[nCntRetFer, 13], aInfoPgto[nCntInfPgFl, 2], aRetFer[nCntRetFer, 12], aRetFer[nCntRetFer, 5], 0 } )
				EndIf
			Next nCntRetFer
			For nCntDetPgTo	:= 1 To Len(adetPgtoFl)
				If (adetPgtoFl[nCntDetPgTo, 7] + adetPgtoFl[nCntDetPgTo, 8] == aInfoPgto[nCntInfPgFl, 1] + aInfoPgto[nCntInfPgFl, 2] + aInfoPgto[nCntInfPgFl, 5]) .And. (lAfast .Or. adetPgtoFl[nCntDetPgTo, 4] > 0 .Or. aScan( aRetPgtoTot, { |x| x[7] == adetPgtoFl[nCntDetPgTo, 2] .And. x[9] == adetPgtoFl[nCntDetPgTo, 8] } ) > 0 )  .And. aInfoPgto[nCntInfPgFl, 3] <> Nil .And. aInfoPgto[nCntInfPgFl, 4] <> Nil //infoPgto -> detPgtoFl | dtPgto + tpPgto + CPF
					lGerouInfo := .T.
					oExcel:AddRow(cAbaPag, cTabPag, { adetPgtoFl[nCntDetPgTo, 11], adetPgtoFl[nCntDetPgTo, 9], adetPgtoFl[nCntDetPgTo, 8], adetPgtoFl[nCntDetPgTo, 10], dToC(sToD(aInfoPgto[nCntInfPgFl, 1])), adetPgtoFl[nCntDetPgTo, 2], aInfoPgto[nCntInfPgFl, 2], adetPgtoFl[nCntDetPgTo, 1], adetPgtoFl[nCntDetPgTo, 4], aIdeBenef[nCntIdeBen, 2] } )
				EndIf
			Next nCntDetPgTo
		EndIf
	Next nCntInfPgFl

	//Varre o array com informações complementares (Dedução Dependente, Pensão Alimentícia e Previdência Complementar)
	For nCntCodRece := 1 To (Len(aCodRece))
		//Dedução de dependente
		If Len(aCodRece[nCntCodRece, 2]) > 0
			For nCtDep := 1 To Len(aCodRece[nCntCodRece,2])
				cTpRend := aCodRece[nCntCodRece, 2, nCtDep, 5]
				If cTpRend $ "11|12|13|14|18|79"
					cTpRend := oTpRend[aCodRece[nCntCodRece, 2, nCtDep, 5]]
				EndIf
				If aIdeBenef[nCntIdeBen, 1] == aCodRece[nCntCodRece, 2, nCtDep, 9]
					oExcel:AddRow(cAbaDedDep, cTabDedDep, { aCodRece[nCntCodRece, 2, nCtDep, 9], aIdeBenef[nCntIdeBen, 4], aCodRece[nCntCodRece, 1], aCodRece[nCntCodRece, 2, nCtDep, 4], aCodRece[nCntCodRece, 2, nCtDep, 8], cTpRend, aCodRece[nCntCodRece, 2, nCtDep, 6]} )
				EndIf
			Next nCtDep
		EndIf

		//Pensão Alimentícia
		If Len(aCodRece[nCntCodRece, 3]) > 0
			For nCtPens := 1 To Len(aCodRece[nCntCodRece, 3])
				cTpRend := aCodRece[nCntCodRece, 3, nCtPens, 9]
				If cTpRend $ "11|12|13|14|18|79"
					cTpRend := oTpRend[aCodRece[nCntCodRece, 3, nCtPens, 9]]
				EndIf
				If aIdeBenef[nCntIdeBen, 1] == aCodRece[nCntCodRece, 3, nCtPens, 7]
					oExcel:AddRow(cAbaPens, cTabPens, { aCodRece[nCntCodRece, 3, nCtPens, 7], aIdeBenef[nCntIdeBen, 4], aCodRece[nCntCodRece, 3, nCtPens, 4], aCodRece[nCntCodRece, 3, nCtPens, 3], cTpRend, aCodRece[nCntCodRece, 3, nCtPens, 5]} )
				EndIf
			Next nCtPens
		EndIf

		//Previdência Complementar
		If Len(aCodRece[nCntCodRece, 4]) > 0
			For nCtPrevComp := 1 To Len(aCodRece[nCntCodRece, 4])
				cTpPrev := aCodRece[nCntCodRece, 4, nCtPrevComp, 3]
				If AllTrim(cTpPrev) $ "1|2|3"
					cTpPrev := oTpPrev[aCodRece[nCntCodRece, 4, nCtPrevComp, 3]]
				EndIf
				If aIdeBenef[nCntIdeBen, 1] == aCodRece[nCntCodRece, 4, nCtPrevComp, 7]
					oExcel:AddRow(cAbaPrev, cTabPrev, { aCodRece[nCntCodRece, 4, nCtPrevComp, 7], aIdeBenef[nCntIdeBen, 4], cTpPrev, aCodRece[nCntCodRece, 4, nCtPrevComp, 2], Abs(aCodRece[nCntCodRece, 4, nCtPrevComp, 4]), Abs(aCodRece[nCntCodRece, 4, nCtPrevComp, 6])} )
				EndIf
			Next nCtPrevComp
		EndIf
	Next nCntCodRece

	//Varre array com os dados de desconto de Plano de Saúde
	For nCntPla := 1 to Len(aDadosRHS)
		If aIdeBenef[nCntIdeBen, 1] == aDadosRHS[nCntPla, 11]
			oExcel:AddRow(cAbaPlSau, cTabPlSau, { aDadosRHS[nCntPla, 11], aIdeBenef[nCntIdeBen, 4], OemToAnsi(STR0306), "", "", Alltrim(aDadosRHS[nCntPla,6]), Alltrim(aDadosRHS[nCntPla,7]), Abs(aDadosRHS[nCntPla,8])} )
			If Len(aDadosRHS[nCntPla,9]) > 0
				For nPlaD := 1 to Len(aDadosRHS[nCntPla,9])
					oExcel:AddRow(cAbaPlSau, cTabPlSau, { aDadosRHS[nCntPla, 11], aIdeBenef[nCntIdeBen, 4], OemToAnsi(STR0307), Alltrim(aDadosRHS[nCntPla,9,nPlaD,1]), Alltrim(aDadosRHS[nCntPla,9,nPlaD,5]), Alltrim(aDadosRHS[nCntPla,6]), Alltrim(aDadosRHS[nCntPla,7]), Abs(aDadosRHS[nCntPla,9,nPlaD,2])} )
				Next nPlaD
			Endif
		EndIf
	Next nCntPla

	//Varre array com os dados de reembolso médico
	For nCntCop := 1 to Len(adadosRHP)
		If aIdeBenef[nCntIdeBen, 1] == adadosRHP[nCntCop, 11]
			If Len(adadosRHP[nCntCop, 8]) > 0
				For nCntCopTit := 1 to Len(adadosRHP[nCntCop, 8])
					oExcel:AddRow(cAbaReemb, cTabReemb, { adadosRHP[nCntCop, 11], aIdeBenef[nCntIdeBen, 4], OemToAnsi(STR0306), "", "", Alltrim(adadosRHP[nCntCop, 6]), Alltrim(adadosRHP[nCntCop, 7]), OemToAnsi(STR0305), AllTrim(adadosRHP[nCntCop, 8, nCntCopTit, 3]), AllTrim(adadosRHP[nCntCop, 8, nCntCopTit, 4]), Abs(adadosRHP[nCntCop, 8, nCntCopTit, 5])} )
				Next nCntCopTit
			EndIf
			If Len(adadosRHP[nCntCop, 9]) > 0
				For nCntCopDep := 1 to Len(adadosRHP[nCntCop , 9])
					oExcel:AddRow(cAbaReemb, cTabReemb, { adadosRHP[nCntCop, 11], aIdeBenef[nCntIdeBen, 4], OemToAnsi(STR0307), adadosRHP[nCntCop, 9, nCntCopDep, 1], adadosRHP[nCntCop, 9, nCntCopDep, 9], Alltrim(adadosRHP[nCntCop, 6]), Alltrim(adadosRHP[nCntCop, 7]), OemToAnsi(STR0305), AllTrim(adadosRHP[ nCntCop, 9, nCntCopDep, 5]), AllTrim(adadosRHP[ nCntCop, 9, nCntCopDep, 6]), Abs(adadosRHP[nCntCop, 9, nCntCopDep, 2])} )
				Next nCntCopDep
			EndIf
		EndIf
	Next nCntPla

	If !lGerouInfo
		aAdd( aRelIncons, { aIdeBenef[nCntIdeBen, 3], aIdeBenef[nCntIdeBen, 1], OemToAnsi(STR0207) } )//"Funcionário foi desprezado pois está sem movimento"
	EndIf
Next nCntIdeBen

For nCntIncons := 1 To Len(aRelIncons)
	oExcel:AddRow(cAbaInc, cTabInc, { aRelIncons[nCntIncons, 1], aRelIncons[nCntIncons, 2], aRelIncons[nCntIncons, 3] } )
Next nCntIncons

oExcel:AddRow(cAbaLeg, cTabLeg, { OemToAnsi(STR0203), OemToAnsi(STR0204)+OemToAnsi(STR0205) } )//"Tipos de Pagamento"##'1-Pagamento de remuneração, conforme apurado em {dmDev} do S-1200 | 2-Pagamento de verbas rescisórias conforme apurado em {dmDev} do S-2299 | 3-Pagamento de verbas rescisórias conforme apurado em {dmDev} do S-2399 | 5-Pagamento de remuneração conforme apurado em {dmDev} do S-1202'##'6-Pagamento de Benefícios Previdenciários, conforme apurado em {dmDev} do S-1207 | 7-Recibo de férias | 9-Pagamento relativo a competências anteriores ao início de obrigatoriedade dos eventos periódicos para o contribuinte'
oExcel:AddRow(cAbaLeg, cTabLeg, { OemToAnsi(STR0303), OemToAnsi(STR0269)} )//"Tipos de Pagamento"##"11 - Remuneração mensal | 12 - 13º salário | 13 - Férias | 14 - PLR | 15 - RRA | 79 - Rendimento isento ou não tributável"
oExcel:AddRow(cAbaLeg, cTabLeg, { OemToAnsi(STR0304), OemToAnsi(STR0273) } )//"Tipos de Previdência"##"1 - Privada | 2 - FAPI | 3 - Funpresp"


If !Empty(oExcel:aWorkSheet)
    oExcel:Activate() //ATIVA O EXCEL
    oExcel:GetXMLFile(cArquivo)

    If !IsBlind()
		CpyS2T(cDefPath+cArquivo, cPath)
		If ApOleClient( "MSExcel" )
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre a planilha
			oExcelApp:SetVisible(.T.)
		EndIf
	EndIf
EndIf

Return

/*/
{Protheus.doc} fFilTransf
Função que busca por transferencias no periodo do 1210

@author		Silvio C. Stecca
@since		21/08/2020
@version	1.0

/*/
Static Function fFilTransf(cMatFun, cPer1210)

	Local cFilTransf	:= ""
	Local cArqSRE		:= GetNextAlias()

	BeginSQL Alias cArqSRE
		SELECT DISTINCT RE_FILIALD
		FROM %Table:SRE% SRE
		WHERE RE_MATP = %Exp:cMatFun%
		AND SUBSTRING(RE_DATA, 1, 6) = %Exp:cPer1210%
		AND SRE.%NotDel%
	EndSQL

	dbSelectArea(cArqSRE)

	If (cArqSRE)->(!EOF())
		While (cArqSRE)->(!EOF())

			cFilTransf := (cArqSRE)->RE_FILIALD

			dbSelectArea(cArqSRE)
			dbSkip()
		EndDo
	EndIf

	If Select(cArqSRE) > 0
		(cArqSRE)->(dbCloseArea())
	EndIf

Return cFilTransf

/*/{Protheus.doc} fGetDtPgto
Retorna a data de pagamento do cadastro de períodos
@type      	Static Function
@author lidio.oliveira
@since 05/01/2021
@version	1.0
@param cFilPesq		= Filial de Pesquisa
@param cProc		= Código do processo
@param cPeriodo		= Peíodo de pequisa no formato (AAAAMM)
@param cSemana		= Semana
@param cRot			= Roteiro para ser pesquisado
@return dDtPgto		= Data de pagamento no cadastro de períodos
/*/

Static Function fGetDtPgto(cFilPesq, cProc, cPeriodo, cSemana, cRot)

	Local aAreaRCH  := RCH->(GetArea())
	Local nRchIndex	:= RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )
	Local dDtPgto	:= cToD("//")

	Default cFilPesq	:= ""
	Default cProc		:= ""
	Default cPeriodo	:= ""
	Default cSemana		:= ""
	Default cRot		:= ""

	RCH->( dbSetOrder(nRchIndex) )

	If RCH->( dbSeek( xFilial("RCH", cFilPesq) + cProc + cPeriodo  + cSemana + cRot ) )
		dDtPgto := RCH->RCH_DTPAGO
	EndIf

	RestArea(aAreaRCH)

Return dDtPgto
/*/{Protheus.doc} fQtdS1200()
Função que verifica se houve movimento no Periodo
@type function
@author staguti
@since 24/06/2021
@version 1.0
@param cOpcTab		= Indica se considerada a tabela SRC
@param cFilProc		= Filiais para busca
@param cPeriodo		= Periodo de busca
@return nQtde		= Quantidade de matriculas no periodo
/*/
Static Function fQtdS1200(cOpcTab, cPeriodo, cRoteiro, lEst)

Local aArea		:= GetArea()
Local cAliasPer	:= GetNextAlias()
Local cJoinRCxRY:= FWJoinFilial( "SRC", "SRY" )
Local cJoinRDxRY:= FWJoinFilial( "SRD", "SRY" )
Local cQrySt	:= ""
Local nParam	:= 0
Local nQtde		:= 1
Local cCatEFDTSV:= "'201','202','401','410','701','711','712','712','721','722','723','731','734','738','741','751','761','771','781','901','902','903','904','905','906','304','305','308','501'"

Default cRoteiro := ""
Default lEst  := .F.

If cRoteiro == "132"
	If __oSt17_3 == Nil
		__oSt17_3 := FWPreparedStatement():New()
		cQrySt := "SELECT SRA.RA_CIC, COUNT(*) AS CONT FROM " + RetSqlName('SRA') + " SRA "
		IF lTemGC .And. lTemEmp
			cQrySt += "WHERE SUBSTRING(SRA.RA_FILIAL, " + cValToChar(nIniEmp) + ", " + cValToChar(nTamEmp) + ") = ? AND "
		Else
			cQrySt += "WHERE "
		EndIf
		cQrySt += "SRA.RA_CIC >= ? AND SRA.RA_CIC <= ? "
		cQrySt += "AND SRA.RA_CC <> ' ' "
		If lEst
			cQrySt += "	AND NOT(SUBSTRING(SRA.RA_DEMISSA,1,6) = '" + cPeriodo + "' AND SRA.RA_CATEFD IN ("+cCatEFDTSV+") AND SRA.RA_CATEFD <> '721' ) "
		Endif

		If cOpcTab == "1"
			cQrySt += "AND EXISTS (SELECT DISTINCT SRC.RC_FILIAL, SRC.RC_MAT FROM " + RetSqlName('SRC')
			cQrySt += " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY
			cQrySt += " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
			cQrySt += "WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_PERIODO = ? AND  SRC.RC_TIPO2 != 'K' AND SRC.D_E_L_E_T_ = ' ' "
			cQrySt += "AND SRC.RC_ROTEIR = '132' "
			cQrySt += "AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
			cQrySt += "UNION "
			cQrySt += "SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY
			cQrySt += " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND "
			cQrySt += "SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' "
			cQrySt += "AND SRD.RD_ROTEIR = '132' "
			cQrySt += "AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
		Else
			cQrySt += "AND EXISTS (SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD')
			cQrySt += " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND "
			cQrySt += "SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND "
			cQrySt += "SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' "
			cQrySt += "AND SRD.RD_ROTEIR = '132' "
			cQrySt += "AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
		EndIf
		cQrySt += "AND SRA.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY SRA.RA_CIC "
		cQrySt := ChangeQuery(cQrySt)
		__oSt17_3:SetQuery(cQrySt)
	EndIf

	IF lTemGC .And. lTemEmp
		__oSt17_3:SetString(++nParam, SubString(SRA->RA_FILIAL, nIniEmp, nTamEmp) )
	EndIf
	__oSt17_3:SetString(++nParam, SRA->RA_CIC)
	__oSt17_3:SetString(++nParam, SRA->RA_CIC)
	__oSt17_3:SetString(++nParam, cPeriodo)
	If cOpcTab == "1"
		__oSt17_3:SetString(++nParam, cPeriodo)
	EndIf
	cQrySt := __oSt17_3:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasPer,.T.,.T.)
	nQtde := (cAliasPer)->CONT

	(cAliasPer)->( dbCloseArea() )
Else
	If __oSt17_1 == Nil
		__oSt17_1 := FWPreparedStatement():New()
		cQrySt := "SELECT SRA.RA_CIC, COUNT(*) AS CONT FROM " + RetSqlName('SRA') + " SRA "
		IF lTemGC .And. lTemEmp
			cQrySt += "WHERE SUBSTRING(SRA.RA_FILIAL, " + cValToChar(nIniEmp) + ", " + cValToChar(nTamEmp) + ") = ? AND "
		Else
			cQrySt += "WHERE "
		EndIf
		cQrySt += "SRA.RA_CIC >= ? AND SRA.RA_CIC <= ? "
		cQrySt += "AND SRA.RA_CC <> ' ' "
		If lEst
			cQrySt += "	AND NOT(SUBSTRING(SRA.RA_DEMISSA,1,6) = '" + cPeriodo + "' AND SRA.RA_CATEFD IN ("+cCatEFDTSV+") AND SRA.RA_CATEFD <> '721' ) "
		Endif

		If cOpcTab == "1"
			cQrySt += "AND EXISTS (SELECT DISTINCT SRC.RC_FILIAL, SRC.RC_MAT FROM " + RetSqlName('SRC')
			cQrySt += " SRC INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRCxRY
			cQrySt += " AND SRC.RC_ROTEIR = SRY.RY_CALCULO "
			cQrySt += "WHERE SRC.RC_FILIAL = SRA.RA_FILIAL AND SRC.RC_MAT = SRA.RA_MAT AND SRC.RC_PERIODO = ? AND  SRC.RC_TIPO2 != 'K' AND SRC.D_E_L_E_T_ = ' ' "
			cQrySt += "AND SRC.RC_ROTEIR != '132' "
			cQrySt += "AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ' "
			cQrySt += "UNION "
			cQrySt += "SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD') + " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY
			cQrySt += " AND SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND "
			cQrySt += "SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' "
			cQrySt += "AND SRD.RD_ROTEIR != '132' "
			cQrySt += "AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
		Else
			cQrySt += "AND EXISTS (SELECT DISTINCT SRD.RD_FILIAL, SRD.RD_MAT FROM " + RetSqlName('SRD')
			cQrySt += " SRD INNER JOIN " + RetSqlName('SRY') + " SRY ON " + cJoinRDxRY + " AND "
			cQrySt += "SRD.RD_ROTEIR = SRY.RY_CALCULO WHERE SRD.RD_FILIAL = SRA.RA_FILIAL AND SRD.RD_MAT = SRA.RA_MAT AND SRD.RD_PERIODO = ? AND "
			cQrySt += "SRD.RD_TIPO2 != 'K' AND SRD.RD_EMPRESA = '  ' AND SRD.D_E_L_E_T_ = ' ' "
			cQrySt += "AND SRD.RD_ROTEIR != '132' "
			cQrySt += "AND SRY.RY_TIPO != 'K' AND SRY.D_E_L_E_T_ = ' ') "
		EndIf
		cQrySt += "AND SRA.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY SRA.RA_CIC "
		cQrySt := ChangeQuery(cQrySt)
		__oSt17_1:SetQuery(cQrySt)
	EndIf

	IF lTemGC .And. lTemEmp
		__oSt17_1:SetString(++nParam, SubString(SRA->RA_FILIAL, nIniEmp, nTamEmp) )
	EndIf
	__oSt17_1:SetString(++nParam, SRA->RA_CIC)
	__oSt17_1:SetString(++nParam, SRA->RA_CIC)
	__oSt17_1:SetString(++nParam, cPeriodo)
	If cOpcTab == "1"
		__oSt17_1:SetString(++nParam, cPeriodo)
	EndIf
	cQrySt := __oSt17_1:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasPer,.T.,.T.)
	nQtde := (cAliasPer)->CONT

	(cAliasPer)->( dbCloseArea() )
EndIf

RestArea(aArea)
Return nQtde

/*/{Protheus.doc} fGM36PFisica()
Função que verifica se a filial esta cadastrada como pessoa fisica
@type function
@author staguti
@since 10/08/2021
@version 1.0
@param cFilEnv= Filial Centralizadora
/*/
Function fGM36PFisica(cFilEnv)
	Local aArea			:= GetArea()
	Local lPFisica		:= .F.
	Local aInfo	 	 	:= {}

	Default cFilEnv	    := cFilAnt

	fInfo(@aInfo,cFilEnv)

	If Len(aInfo) > 0
		If aInfo[28] == 3 .Or. Alltrim(aInfo[12]) == "1"  //M0_TPINSC //M0_PRODRUR
			lPFisica := .T.
		Endif
	Endif

	RestArea(aArea)

Return lPFisica

/*/{Protheus.doc} fCatEstat
Verifica se a categoria e o Regime de Previdencia são de estatutarios
@author Silvia Taguti
@since 14/03/2022
/*/
Function fTpPgtoEst(cTpPrevi, cCatefd, cCompEst,cTpFolha)

Local lRet 		 := .F.
Local cPer1202		:= SubStr(cCompEst, 3, 4) + SubStr(cCompEst, 1, 2)
Local cCatS1200     := "101|102|103|104|105|106|107|108|111|"
Local cContrib      := '701|711|712|721|722|723|731|734|738|741|751|761|771|781'

Default cTpPrevi := ""
Default cCatefd  := ""
Default cCompEst := ""
Default cTpFolha := "1"


	If ((cTpPrevi= "2" .And. cCatefd $ "301|302|303|304|306|307|309|310|312|401|410") .Or. cCatefd $ "308|311|313" .OR.;
		(cCatefd == "305" .AND. If(cTpFolha=="1", cPer1202 >= "202204", SubStr(cPer1202, 1, 4) >= "2022")))
		lRet := .T.
	Endif

Return lRet

/*/{Protheus.doc} fCodCorr
Verifica se a verba é gerada a partir do código correspodente
@author lidio.oliveira
@since 12/09/2022
/*/
Static Function fCodCorr(cFilSRV, cPD)

	Local aArea		:= GetArea()
	Local aAreaSRV	:= GetArea("SRV")
	Local cAlias	:= GetNextAlias()
	Local lRet		:= .F.

	BeginSql alias cAlias
		SELECT SRV.RV_COD,SRV.RV_CODCORR
		FROM %table:SRV% SRV
		WHERE SRV.RV_FILIAL = %exp:cFilSRV%
			AND SRV.RV_CODCORR =  %exp:cPD%
			AND SRV.%NotDel%
	EndSql

	While (cAlias)->( !Eof() )
		lRet		:=.T.
		Exit
	EndDo

	(cAlias)->(DbCloseArea())

	RestArea( aAreaSRV )
	RestArea( aArea )

Return lRet


/*/{Protheus.doc} fFer2299TAF
Verifica se a o recibo de férias existe na T06
@author lidio.oliveira
@since 14/07/2023
/*/
Static Function fFer2299TAF(cFilEnv, cCodUnic, cDtDeslig, cDmDevFer)

	Local aArea		:= GetArea()
	Local aAreaC9V	:= GetArea("C9V")
	Local aAreaCMD	:= GetArea("CMD")
	Local aAreaT06	:= GetArea("T06")
	Local lRet		:= .F.
	Local cIdC9V	:= ""
	Local cVersCMD	:= ""
	Local cIdT06	:= ""

	Default cFilEnv		:= ""
	Default cCodUnic	:= ""
	Default cDtDeslig	:= CTOD("//")
	Default cDmDevFer	:= ""

	//Localiza um registro de DmDev de férias na T06
	cIdC9V := Posicione("C9V", 11, cFilEnv + cCodUnic + "1", "C9V_ID")
	If !Empty(cIdC9V)
		cVersCMD := Posicione("CMD", 2, cFilEnv + cIdC9V + cdtDeslig + "1", "CMD_VERSAO")
		If !Empty(cVersCMD)
			cIdT06 := Posicione("T06", 2, cFilEnv + cDmDevFer, "T06_ID")
		EndIf
	EndIf

	If !Empty(cIdT06)
		lRet := .T.
	EndIf

	RestArea( aAreaC9V )
	RestArea( aAreaCMD )
	RestArea( aAreaT06 )
	RestArea( aArea )

Return lRet


/*/{Protheus.doc} fDedDep
Retorna com historico de deduçao de dependentes
@author Silvia Taguti
@since 12/09/2023
/*/
Static Function fDedDep(cFilRU6, cMatRU6, cCompete, lTSV, cCPFFunc)

	Local aAreaRU6 	:= GetArea()
	Local nPos		:= 0
	Local aAreaSRB  := SRB->(GetArea())
	Local cUltimoD	:= STRZERO(f_UltDia(CTOD( "01/"+SUBSTR(cCompete,5,2)+"/"+SUBSTR(cCompete,1,4) )),2)
	Local cPerIni	:= cCompete + "01"
	Local cPerFim	:= cCompete + cUltimoD
	Local cTpRend   := ""
	Local cCodRece	:= ""
	Local cCpfDep	:= ""
	Local cNomeDep	:= ""

	Default cFilRU6		:= ""
	Default cMatRU6		:= ""
	Default cCompete	:= ""
	Default lTSV		:= .F.
	Default cCPFFunc	:= ""

	cCodRece := fCodRece( lTSV, )

	DbSelectArea( "RU6" )
	DbSetOrder( 1 )
	If RU6->(dbSeek(cFilRU6+cMatRU6))
		While RU6->( !EOF() ) .And. RU6->RU6_FILIAL + RU6->RU6_MAT == cFilRU6+cMatRU6
			cCpfDep := ""
			If RU6->RU6_FILIAL + RU6->RU6_MAT == cFilRU6+cMatRU6 .And. (DTOS(RU6->RU6_DTPGTO) >= cPerIni .And. DTOS(RU6->RU6_DTPGTO) <= cPerFim) .And.;
				!(Substr(DTOS(RU6->RU6_DTPGTO), 5, 2) == "01" .And. Substr(RU6->RU6_COMPET, 5, 2) == "12" .And. RU6->RU6_TPREND == "2")//Despreza registro de 13º gerado com data de pagamento em janeiro
				If !Empty(RU6->RU6_CODSRB)
					DbSelectArea("SRB")
					DbSetOrder( 1 )
					If DbSeek(cFilRU6 + cMatRU6+ RU6->RU6_CODSRB)
						cCpfDep		:= SRB->RB_CIC
						cNomeDep	:= SRB->RB_NOME
					Else
						//Garante que está posicionado no funcionário na SRB
						SRB->(DbGoTop())
						DbSeek(cFilRU6 + cMatRU6)
					Endif
				Endif
				If !Empty(cCpfDep)
					cTpRend :=  If(RU6->RU6_TPREND $ "1|4|5","11", If(RU6->RU6_TPREND == "3","13","12") )

					nPos := ascan(aDedDep,{|X| X[1]==cFilRU6 .And. X[2]==cMatRU6.And. X[3]==RU6->RU6_CODSRB .And. X[4]==cCpfDep .And. X[5]== cTpRend .And. X[7]== cCodRece })

					If nPos == 0
						Aadd (aDedDep, { RU6->RU6_FILIAL, RU6->RU6_MAT, RU6->RU6_CODSRB, cCpfDep, cTpRend, RU6->RU6_VLRDED, cCodRece, cNomeDep, cCPFFunc})
					Endif
				EndIf
			Endif
			RU6->( DbSkip() )
		EndDo
	EndIf

	RestArea(aAreaSRB)
	RestArea(aAreaRU6)

Return aDedDep


/*/{Protheus.doc} fGetPrev()
Função que retorna as informações de previdência privada
@type      	Function
@author   	Silvia Taguti
@version	1.0
@param cVerba		= Alias da tabela temporária principal
@param cPeriodo		= Data de Geração da Rescisão
@param cDmDev		= Data de Geração da Rescisão
@return aInfoPrev    	= Informações do fornecedor da previdência privada
/*/
Function fGetPrev( cVerba, cPeriodo,  cCodIR, nVlPrev, lTSV )
Local aArea			:= GetArea()
Local dDataRef  	:= cToD( "01/" + SubStr( cPeriodo, 5, 2 ) + "/" + SubStr( cPeriodo, 1, 4 ) )
Local nPosTab		:= 0
Local cCodPrev      := ""
Local nPos 			:= 0
Local cCodRece      := ""
Local aTabPrev 	    := {}
Local lIncid13		:= .F.
Local lPrevFer      := .F.

Default cVerba      := ""
Default cPeriodo 	:= ""
Default cCodIR	 	:= ""
Default nVlPrev     := 0
Default lTSV		:= .F.

If (Val(cCodIR) >= 46 .And. Val(cCodIR) <= 48) .Or. (Val(cCodIR) >= 9046 .And. Val(cCodIR) <= 9048)
	cCodPrev:= "1"
ElseIf (Val(cCodIR) == 61 .Or. Val(cCodIR) == 62 .Or. Val(cCodIR) == 66 .And. Val(cCodIR) == 9061 .Or. Val(cCodIR) == 9062 .Or. Val(cCodIR) == 9066)
	cCodPrev:= "2"
ElseIf (Val(cCodIR) == 63 .Or. Val(cCodIR) == 64 .Or. Val(cCodIR) == 65 .And. Val(cCodIR) == 9063 .Or. Val(cCodIR) == 9064 .Or. Val(cCodIR) == 9065)
	cCodPrev:= "3"
Endif

cCodRece := fCodRece( lTSV , cCodIR )
lIncid13	:= cVersEnvio >= "9.3" .And. cCodIR $ "47*62*64"
If Empty(aTabPrev)
	fCarrTab( @aTabPrev, "S073", dDataRef, .T. )
EndIf
If !Empty(aTabPrev) .And. Len(aTabPrev[1]) > 24 
	lPrevFer := .T.
Endif	

dbSelectArea( "SMU" )
SMU->( dbSetOrder(1) )
If SMU->( dbSeek(SRA->RA_FILIAL+SRA->RA_MAT) )
	While SMU->( !EoF() ) .And. SMU->MU_FILIAL + SMU->MU_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		If cPeriodo >= SubStr( SMU->MU_PERINI, 3, 4 )+SubStr( SMU->MU_PERINI, 1, 2 ) .And. If(!Empty(SMU->MU_PERFIM), cPeriodo <= SubStr( SMU->MU_PERFIM, 3, 4 )+SubStr( SMU->MU_PERFIM, 1, 2 ), .T.)
			nPosTab := aScan( aTabPrev, { |x| x[5] == SMU->MU_CODFOR .And. (x[8] == cVerba .Or. x[9] == cVerba .Or. x[10] == cVerba .Or. x[11] == cVerba .Or. x[16] == cVerba .Or. x[17] == cVerba  ) }) 
		   	If nPosTab == 0 .And. lPrevFer
				nPosTab := aScan( aTabPrev, { |x| x[5] == SMU->MU_CODFOR .And. (x[24] == cVerba .Or. x[25]==cVerba  ) }) 
			Endif  
			If nPosTab > 0
				nPos := ascan(aInfoPrev,{|X| X[2] == aTabPrev[nPosTab, 6] .And. X[3]==cCodPrev .And. X[5] == cCodRece .And. x[7] == SRA->RA_CIC})
				If nPos == 0
					aAdd( aInfoPrev, { cVerba, aTabPrev[nPosTab, 6], cCodPrev, If(lIncid13, 0, nVlPrev), cCodRece, If(lIncid13, nVlPrev, 0), SRA->RA_CIC } )
				else
					aInfoPrev[nPos, If(lIncid13, 6, 4)] += nVlPrev
				Endif
			Endif
		EndIf
		SMU->(dbSkip())
	EndDo
EndIf

RestArea(aArea)

Return .T.

/*/{Protheus.doc} fCodRece
Retorna com historico de deduçao de dependentes
@author Silvia Taguti
@since 12/09/2023
*/
Static Function fCodRece( lTSV1210, cCodFolRec )

Default cCodFolRec  := ""
Default lTSV1210    := .F.

	If 	cCodFolRec $ "54|9054"  			//PLR
		cCodRece := "356201"
	ElseIf cCodFolRec == "55"  				//RRA
		cCodRece := "188901"
	ElseIf (!lTSV1210 .Or. cCat $ "721|722|723|761|901|902|903|904|906") .And. 	!lResidExt		//TCV - Folha/Ferias/13 Salario
		cCodRece := "056107"
	ElseIf !lTSV1210 .And. 	lResidExt  		//Residente Exterior
		cCodRece := "047301"
	ElseIf 	lTSV1210   						//TSV - Folha/Ferias/13 Salario
		cCodRece := "058806"
	Endif

Return cCodRece

/*/{Protheus.doc} fGetPLS1210()
Função que retorna as informações de plano de saude
@type      	Function
@author   	Silvia Taguti
@version	1.0
@return adadosRHS  	= Informações do plano de saude, titular e dependentes
*/
Function fGetPLS1210(cFil, cMat, cOpcTab, cDtIni, cDtFim, cPer, lRes, cMesPgtoRes, cCPFMat, aLogsErr, lAborta, aLogErrDep)
	Local cGetAlias  	:= ""
	Local aDados     	:= {}
	Local aLstDeps   	:= {}
	Local aDadosbKP		:= {}
	Local nPos		 	:= 0
	Local nX		 	:= 0
	Local nZ			:= 0
	Local nPos3			:= 0
	Local cFilRCC		:= xFilial('RCC', cFil)
	Local cPerPag       := "" //Período de pagamento
	Local lPerAb        := .F.
	Local lTemVlrDep	:= .F.
	Local aDepAgreg		:= {}
	Local cdmDev		:= ""
	Local lIncTit		:= .F.
	Local cLogAux		:= ""
	Local cChvForn		:= ""
	Local cSeekForn		:= ""
	Local aPerQry		:= {}

	Default cFil		:= ""
	Default cMat	 	:= ""
	Default cOpcTab	 	:= "0"
	Default cDtIni	    := ""
	Default cDtFim      := ""
	Default cPer        := "" //Período de referência
	Default lRes		:= .F. //Se é sobre mês de rescisão
	Default cMesPgtoRes	:= "" //Mês de Pagamento da rescisão
	Default cCPFMat		:= ""
	Default aLogsErr	:= {}
	Default lAborta		:= .F.
	Default aLogErrDep	:= {}

	aAdd(aPerQry, cPer)
    If !Empty(cDtIni)
		cPerPag := Substr(cDtIni,1,6)
		If cPerPag >= cPer
			lPerAb := .T.
			//Se for sobre um mês de rescisão com pagamento no período selecionado inclui período em aPerQry
			If lRes .And. cPerPag == cMesPgtoRes
				aAdd(aPerQry, cMesPgtoRes)
			EndIf
		Endif
	Endif

	cGetAlias  := GetNextAlias()

	If __oSt04 == Nil
		__oSt04 := FWPreparedStatement():New()
		cQrySt := "SELECT RHS_FILIAL,RHS_MAT,RHS_CODFOR,RHS_PD,RHS_CODIGO,RHS_COMPPG,RHS_TPFORN,RHS_ORIGEM,SUM(RHS_VLRFUN) TOTAL,RCC_CONTEU,RCC_FILIAL,RCC_FIL,RCC_CHAVE "
		cQrySt += "FROM " + RetSqlName('RHS') + " RHS "
		cQrySt += "JOIN " + RetSqlName('RCC') + " RCC ON RHS_CODFOR = SUBSTRING(RCC_CONTEU,1,3) "
		cQrySt += "WHERE RHS_FILIAL = ? AND "
		cQrySt += 		"RHS_MAT = ? AND "
		cQrySt += 		"RCC_FILIAL = ? AND "
		cQrySt += 		"(RCC.RCC_FIL = ' ' OR RCC.RCC_FIL = RHS_FILIAL) AND "
		cQrySt += 		"RCC.RCC_CODIGO = ( CASE WHEN RHS.RHS_TPFORN = '1' THEN 'S016' WHEN RHS.RHS_TPFORN = '2' THEN 'S017' END ) AND "
		cQrySt += 		"RHS_COMPPG IN (?) AND "
		cQrySt += 		"RCC.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"RHS.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY RHS_FILIAL, RHS_MAT, RHS_CODFOR, RHS_PD, RHS_CODIGO, RHS_COMPPG, RHS_TPFORN, RHS_ORIGEM, RCC_CONTEU, RCC_FILIAL, RCC_FIL, RCC_CHAVE  "
		cQrySt += "UNION ALL "
		cQrySt += "SELECT RHP_FILIAL,RHP_MAT,RHP_CODFOR,RHP_PD,RHP_CODIGO,RHP_COMPPG,RHP_TPFORN,RHP_ORIGEM,SUM(RHP_VLRFUN) TOTAL,RCC_CONTEU,RCC_FILIAL,RCC_FIL,RCC_CHAVE "
		cQrySt += "FROM " + RetSqlName('RHP') + " RHP "
		cQrySt += "JOIN " + RetSqlName('RCC') + " RCC ON RHP_CODFOR = SUBSTRING(RCC_CONTEU,1,3) "
		cQrySt += "WHERE RHP_FILIAL = ? AND "
		cQrySt += 		"RHP_MAT = ? AND "
		cQrySt += 		"RCC_FILIAL = ? AND "
		cQrySt += 		"(RCC.RCC_FIL = ' ' OR RCC.RCC_FIL = RHP_FILIAL) AND "
		cQrySt += 		"RCC.RCC_CODIGO = ( CASE WHEN RHP.RHP_TPFORN = '1' THEN 'S016' WHEN RHP.RHP_TPFORN = '2' THEN 'S017' END ) AND "
		cQrySt += 		"RHP_COMPPG IN (?) AND "
		cQrySt += 		"RHP_TPLAN != '2' AND "
		cQrySt += 		"RCC.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"RHP.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY RHP_FILIAL, RHP_MAT, RHP_CODFOR, RHP_PD, RHP_CODIGO, RHP_COMPPG, RHP_TPFORN, RHP_ORIGEM, RCC_CONTEU, RCC_FILIAL, RCC_FIL, RCC_CHAVE "

		If cOpcTab == "1" .And. lPerAb
			cQrySt += "UNION ALL "
			cQrySt += "SELECT RHR_FILIAL,RHR_MAT,RHR_CODFOR,RHR_PD,RHR_CODIGO,RHR_COMPPG,RHR_TPFORN,RHR_ORIGEM,SUM(RHR_VLRFUN) TOTAL,RCC_CONTEU,RCC_FILIAL,RCC_FIL,RCC_CHAVE "
			cQrySt += "FROM " + RetSqlName('RHR') + " RHR "
			cQrySt += "JOIN " + RetSqlName('RCC') + " RCC ON RHR_CODFOR = SUBSTRING(RCC_CONTEU,1,3) "
			cQrySt += "WHERE RHR_FILIAL = ? AND "
			cQrySt += 		"RHR_MAT = ? AND "
			cQrySt += 		"RCC_FILIAL = ? AND "
			cQrySt += 		"(RCC.RCC_FIL = ' ' OR RCC.RCC_FIL = RHR_FILIAL) AND "
			cQrySt += 		"RCC.RCC_CODIGO = ( CASE WHEN RHR.RHR_TPFORN = '1' THEN 'S016' WHEN RHR.RHR_TPFORN = '2' THEN 'S017' END ) AND "
			cQrySt += 		"RHR_COMPPG IN (?) AND "
			cQrySt += 		"RHR_TPLAN != '3' AND "
			cQrySt += 		"RCC.D_E_L_E_T_ = ' ' AND "
			cQrySt += 		"RHR.D_E_L_E_T_ = ' ' "
			cQrySt += "GROUP BY RHR_FILIAL, RHR_MAT, RHR_CODFOR, RHR_PD, RHR_CODIGO, RHR_COMPPG, RHR_TPFORN, RHR_ORIGEM, RCC_CONTEU, RCC_FILIAL, RCC_FIL, RCC_CHAVE "
		EndIf

		cQrySt := ChangeQuery(cQrySt)
		__oSt04:SetQuery(cQrySt)
	EndIf
	__oSt04:SetString(1, cFil)
	__oSt04:SetString(2, cMat)
	__oSt04:SetString(3, cFilRCC)
	__oSt04:SetIn(4, aPerQry)
	__oSt04:SetString(5, cFil)
	__oSt04:SetString(6, cMat)
	__oSt04:SetString(7, cFilRCC)
	__oSt04:SetIn(8, aPerQry)
	If cOpcTab == "1" .And. lPerAb
		__oSt04:SetString(9, cFil)
		__oSt04:SetString(10, cMat)
		__oSt04:SetString(11, cFilRCC)
		__oSt04:SetIn(12, aPerQry)
	EndIf

	cQrySt := __oSt04:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cGetAlias,.T.,.T.)

	While ( (cGetAlias)->( !Eof() ) )

		//Verifica se está posicionado corretamente no fornecedor
		If Empty(cChvForn) .Or. cChvForn <> (cGetAlias)->RHS_TPFORN + (cGetAlias)->RHS_CODFOR
			cChvForn	:= (cGetAlias)->RHS_TPFORN + (cGetAlias)->RHS_CODFOR
			cSeekForn	:= fRetChvFor(IIF((cGetAlias)->RHS_TPFORN == "1", "S016", "S017"), (cGetAlias)->RHS_FILIAL, cPerPag, (cGetAlias)->RHS_CODFOR, cFilCrgTab <> (cGetAlias)->RCC_FILIAL, (cGetAlias)->RHS_FILIAL)
			cFilCrgTab	:= (cGetAlias)->RCC_FILIAL
		EndIf
		
		//Desconsidera registros diferentes da seek correto na tabela de fornecedores
		If cSeekForn <> (cGetAlias)->RCC_FIL + (cGetAlias)->RCC_CHAVE
			(cGetAlias)->(DbSkip())
			Loop
		EndIf

		aLstDeps := {}
		If (cGetAlias)->RHS_ORIGEM == "2"
			If SRB->( dbSeek( (cGetAlias)->RHS_FILIAL + (cGetAlias)->RHS_MAT + (cGetAlias)->RHS_CODIGO ) )
				aAdd( aLstDeps, { SRB->RB_CIC, (cGetAlias)->TOTAL, SRB->RB_COD, (cGetAlias)->RHS_ORIGEM, SRB->RB_NOME, SRB->RB_DTNASC} )
				If Empty(SRB->RB_CIC)
					If aScan(aDepAgreg, { |x| x == fSubst(SRB->RB_NOME) }) == 0
						aAdd( aDepAgreg, fSubst(SRB->RB_NOME) )
					EndIf
				EndIf
			EndIf
		ElseIf (cGetAlias)->RHS_ORIGEM == "3"
			RHM->( dbSetOrder(1) )
			If RHM->( dbSeek( (cGetAlias)->RHS_FILIAL + (cGetAlias)->RHS_MAT + (cGetAlias)->RHS_TPFORN + (cGetAlias)->RHS_CODFOR + (cGetAlias)->RHS_CODIGO ) )
				aAdd( aLstDeps, { RHM->RHM_CPF,(cGetAlias)->TOTAL, RHM->RHM_CODIGO, (cGetAlias)->RHS_ORIGEM,RHM->RHM_NOME, Dtos(RHM->RHM_DTNASC)} )
				If Empty(RHM->RHM_CPF)
					If aScan(aDepAgreg, { |x| x == fSubst(RHM->RHM_NOME) }) == 0
						aAdd( aDepAgreg, fSubst(RHM->RHM_NOME) )
					EndIf
				EndIf
			EndIf
		EndIf

		If cVersEnvio < "9.3"
			nPos := ascan(aDados,{|X| X[6] == Substr( (cGetAlias)->RCC_CONTEU, 154, 14 )  }) //busca apenas pelo CNPJ
		Else
			nPos := ascan(aDados,{|X| X[6]==Substr((cGetAlias)->RCC_CONTEU, 154,14) .And. X[7]==Substr((cGetAlias)->RCC_CONTEU, 168,6)}) //busca pelo CNPJ+ANS
		Endif

		If nPos == 0
			aAdd(aDados, { 	(cGetAlias)->RHS_FILIAL ,;					//Filial da RHS - Plano de Saude
										(cGetAlias)->RHS_MAT		,; 	//Matric da RHS - Plano de Saude
										(cGetAlias)->RHS_CODFOR	,; 		//CodFor da RHS - Plano de Saude
										(cGetAlias)->RHS_PD		,; 		//Verba  da RHS - Plano de Saude
										(cGetAlias)->RHS_CODIGO	,; 		//Depend da RHS - Plano de Saude
										Substr( (cGetAlias)->RCC_CONTEU, 154, 14 ),;  //CNPJ Fornecedor
										Substr( (cGetAlias)->RCC_CONTEU, 168, 6 )  ,; //ANS Fornecedor
										Iif( (cGetAlias)->RHS_ORIGEM == "1", (cGetAlias)->TOTAL, 0)	 ,;//Valor Titular
										aLstDeps ,;						//Soma GastaRHS - Plano de Saude
										cdmDev ,;						//Identificador do dmDev (utilizado no S-1210)
										cCPFMat }) 						//CPF do Funcionário
		Else
			If cVersEnvio < "9.3"
				If aDados[nPos,7] == Substr( (cGetAlias)->RCC_CONTEU, 168, 6 ) .OR. aDados[nPos,6] == Substr( (cGetAlias)->RCC_CONTEU, 154, 14 )
					If Empty((cGetAlias)->RHS_CODIGO) .Or. (cGetAlias)->RHS_ORIGEM == "1"
						aDados[nPos,8] += (cGetAlias)->TOTAL
					EndIf
					For nX := 1 to Len(aLstDeps)
						nPos2 := ascan(aDados[nPos,9], {|X| X[3]+X[4] == aLstDeps[nX,3] + aLstDeps[nX,4] })
						If nPos2 == 0
							AAdd ( aDados[nPos,9], aLstDeps[nX] )
						Else
							aDados[nPos,9,nPos2,2] += aLstDeps[nX,2]
						EndIf
					Next
				EndIf
			Else
				If aDados[nPos,7] == Substr( (cGetAlias)->RCC_CONTEU, 168, 6 ) .And. aDados[nPos,6] == Substr( (cGetAlias)->RCC_CONTEU, 154, 14 )
					If Empty((cGetAlias)->RHS_CODIGO) .Or. (cGetAlias)->RHS_ORIGEM == "1"
						aDados[nPos,8] += (cGetAlias)->TOTAL
					EndIf
					For nX := 1 to Len(aLstDeps)
						nPos2 := ascan(aDados[nPos,9], {|X| X[3]+X[4] == aLstDeps[nX,3] + aLstDeps[nX,4] })
						If nPos2 == 0
							AAdd ( aDados[nPos,9], aLstDeps[nX] )
						Else
							aDados[nPos,9,nPos2,2] += aLstDeps[nX,2]
						EndIf
					Next
				EndIf
			EndIf
		Endif
		( cGetAlias )->(DbSkip())
	EndDo
	( cGetAlias )->( dbCloseArea() )

	//Copia o array de adados
	aDadosbKP := aClone(aDados)
	aDados	  := {}

	//Varre o array aDadosbKP
	For nX := 1 To Len(aDadosbKP)
		lTemVlrDep := .F.
		lIncTit := .F.

		//Adiciona o titular se houver desconto
		If aDadosbKP[nX, 8] > 0
			aAdd(aDados, aClone(aDadosbKP[nX]))
			lIncTit := .T.
		EndIf

		//Para Leiautes anterior ao S-1.3 SEM desconto para o titular
		//varre o array com os valores de dependentes e agregados e inclui somente quem possui desconto.
		If cVersEnvio < "9.3" .And. !lIncTit
			For nZ := 1 To Len(aDadosbKP[nX, 9])
				If aDadosbKP[nX, 9, nz, 2] > 0 .And. !lTemVlrDep
					lTemVlrDep := .T.

					//Inclui os dados do titular
					aAdd(aDados, aClone(aDadosbKP[nX]))

					//Zera a posição dos dependentes e inclui somente a posição que possui valor
					nPos3				:= Len(aDados)
					aDados[nPos3, 9]	:= {}
					aAdd(aDados[nPos3, 9], aDadosbKP[nX, 9, nz])
				ElseIf aDadosbKP[nX, 9, nz, 2] > 0 .And. lTemVlrDep
					aAdd(aDados[nPos3, 9], aDadosbKP[nX, 9, nz])
				EndIf
			Next nZ
		ElseIf cVersEnvio >= "9.3"
			//Se ja inclui o titular, zera a posição dos dependentes
			If lIncTit
				nPos3				:= Len(aDados)
				aDados[nPos3, 9]	:= {}
			EndIf

			//Percorre todos os dependentes relacionados ao titular para validar se possui valor
			For nZ := 1 To Len(aDadosBkp[nX, 9])
				//Se o dependente possui desconto prossegue com a inclusão
				If aDadosBkp[nX, 9, nz, 2] > 0
					If Empty(aDadosBkp[nX, 9, nz, 1])
						If !lAborta
							//"O Funcionário ## possui dependente de plano de saúde sem CPF, por esse motivo o S-1210 não será gerado."
							aAdd(aLogErrDep, OemToAnsi(STR0308) + cCPFMat + OemToAnsi(STR0309) )
							aAdd(aLogErrDep, "" )
							lAborta := .T.
						EndIf
						//" - O dependente [##] não possui CPF preenchido e não foi enviado para o eSocial."
						cLogAux := OemToAnsi(STR0233) + aDadosBkp[nX][9][nZ][3] + " - " + AllTrim(aDadosBkp[nX][9][nZ][5]) + OemToAnsi(STR0234)
						If aScan(aLogErrDep, {|X| AllTrim(X) == AllTrim(cLogAux) }) == 0
							aAdd(aLogErrDep, cLogAux )
							If !(cLogAux $ cLogDep)
								cLogDep += cLogAux + cQuebra
							EndIf
						EndIf
					Else
						//Inclui os dados do titular se não possuir desconto, se possui a inclusão já ocorreu
						If !lIncTit
							aAdd(aDados, aClone(aDadosbKP[nX]))
							//Zera a posição dos dependentes
							nPos3				:= Len(aDados)
							aDados[nPos3, 9]	:= {}
							lIncTit 			:= .T.
						EndIf
						aAdd(aDados[nPos3, 9], aDadosbKP[nX, 9, nz])
					EndIf
				EndIf
			Next nZ
		EndIf
	Next nX

Return aDados

/*/{Protheus.doc} fGetRCop1210()
Função que retorna as informações de reembolso/coparticipação
@type      	Function
@author   	Silvia Taguti
@version	1.0
@return adadosRHP  	= Informações de reembolso/coparticipação
*/
Static Function fGetRCop1210(cFil, cMat, cOpcTab, cDtIni, cDtFim, cPer, lRes, cMesPgtoRes, cCPFMat, lRelat)
	Local cGetAlias  	:= ""
	Local aDados     	:= {}
	Local aLstDeps   	:= {}
	Local nPos		 	:= 0
	Local nX		 	:= 0
	Local cFilRCC		:= xFilial('RCC', cFil)
	Local cCpfCNPJ      := "1"
	Local aRemTit		:= {}
	Local nPosR         := 0
	Local cPerPag       := ""
	Local lPerAb        := .F.
	Local cCNPJForn     := ""
	Local cANSForn      := ""
	Local cLogAviso		:= ""
	Local cChvForn		:= ""
	Local cSeekForn		:= ""
	Local aPerQry		:= {}

	Default cFil		:= ""
	Default cMat	 	:= ""
	Default cOpcTab	 	:= "0"
	Default cDtIni	    := ""
	Default cDtFim      := ""
	Default cPer        := "" //Período de referência
	Default lRes		:= .F. //Se é sobre mês de rescisão
	Default cMesPgtoRes	:= "" //Mês de Pagamento da rescisão
	Default cCPFMat		:= ""
	Default lRelat		:= .F.

	aAdd(aPerQry, cPer)
    If !Empty(cDtIni)
		cPerPag := Substr(cDtIni,1,6)
		If cPerPag >= cPer
			lPerAb := .T.
			//Se for sobre um mês de rescisão com pagamento no período selecionado inclui período em aPerQry
			If lRes .And. cPerPag == cMesPgtoRes
				aAdd(aPerQry, cMesPgtoRes)
			EndIf
		Endif
	Endif

	cGetAlias  := GetNextAlias()

	If __oSt20 == Nil
		__oSt20 := FWPreparedStatement():New()
		cQrySt := "SELECT RHP_FILIAL,RHP_MAT,RHP_CODFOR,RHP_PD,RHP_CODIGO,RHP_COMPPG,RHP_TPFORN,RHP_ORIGEM, RHP_VLRFUN ,RCC_CONTEU, "
		cQrySt += "RHP_INMED, RCC_FILIAL, RCC_FIL, RCC_CHAVE  "
		cQrySt += "FROM " + RetSqlName('RHP') + " RHP "
		cQrySt += "JOIN " + RetSqlName('RCC') + " RCC ON RHP_CODFOR = SUBSTRING(RCC_CONTEU,1,3) "
		cQrySt += "WHERE RHP_FILIAL = ? AND "
		cQrySt += 		"RHP_MAT = ? AND "
		cQrySt += 		"RCC_FILIAL = ? AND "
		cQrySt += 		"(RCC.RCC_FIL = ' ' OR RCC.RCC_FIL = RHP_FILIAL) AND "
		cQrySt += 		"RCC.RCC_CODIGO = ( CASE WHEN RHP.RHP_TPFORN = '1' THEN 'S016' WHEN RHP.RHP_TPFORN = '2' THEN 'S017' END ) AND "
		cQrySt += 		"RHP_DATPGT BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' AND "
		cQrySt += 		"RHP_TPLAN = '2' AND "
		cQrySt += 		"RCC.D_E_L_E_T_ = ' ' AND "
		cQrySt += 		"RHP.D_E_L_E_T_ = ' ' "
		cQrySt += "GROUP BY RHP_FILIAL, RHP_MAT, RHP_CODFOR, RHP_PD, RHP_CODIGO, RHP_COMPPG, RHP_TPFORN, RHP_ORIGEM, RHP_VLRFUN, RCC_CONTEU, RHP_INMED, RCC_FILIAL, RCC_FIL, RCC_CHAVE  "

		If cOpcTab == "1" .And. lPerAb
			cQrySt += "UNION ALL "
			cQrySt += "SELECT RHO_FILIAL,RHO_MAT,RHO_CODFOR,RHO_PD,RHO_CODIGO,RHO_COMPPG,RHO_TPFORN,RHO_ORIGEM, RHO_VLRFUN,RCC_CONTEU, "
			cQrySt += "RHO_INMED, RCC_FILIAL, RCC_FIL, RCC_CHAVE  "
			cQrySt += "FROM " + RetSqlName('RHO') + " RHO "
			cQrySt += "JOIN " + RetSqlName('RCC') + " RCC ON RHO_CODFOR = SUBSTRING(RCC_CONTEU,1,3) "
			cQrySt += "WHERE RHO_FILIAL = ? AND "
			cQrySt += 		"RHO_MAT = ? AND "
			cQrySt += 		"RCC_FILIAL = ? AND "
			cQrySt += 		"(RCC.RCC_FIL = ' ' OR RCC.RCC_FIL = RHO_FILIAL) AND "
			cQrySt += 		"RCC.RCC_CODIGO = ( CASE WHEN RHO.RHO_TPFORN = '1' THEN 'S016' WHEN RHO.RHO_TPFORN = '2' THEN 'S017' END ) AND "
			cQrySt += 		"RHO_COMPPG IN (?) AND "
			cQrySt += 		"RHO_TPLAN = '2' AND "
			cQrySt += 		"RCC.D_E_L_E_T_ = ' ' AND "
			cQrySt += 		"RHO.D_E_L_E_T_ = ' ' "
			cQrySt += "GROUP BY RHO_FILIAL, RHO_MAT, RHO_CODFOR, RHO_PD, RHO_CODIGO, RHO_COMPPG, RHO_TPFORN, RHO_ORIGEM, RHO_VLRFUN,RCC_CONTEU, RHO_INMED, RCC_FILIAL, RCC_FIL, RCC_CHAVE  "
		Endif

		cQrySt := ChangeQuery(cQrySt)
		__oSt20:SetQuery(cQrySt)
	EndIf
	__oSt20:SetString(1, cFil)
	__oSt20:SetString(2, cMat)
	__oSt20:SetString(3, cFilRCC)

	If cOpcTab == "1" .And. lPerAb
		__oSt20:SetString(4, cFil)
		__oSt20:SetString(5, cMat)
		__oSt20:SetString(6, cFilRCC)
		__oSt20:SetIn(7, aPerQry)
	EndIf

	cQrySt := __oSt20:getFixQuery()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cGetAlias,.T.,.T.)

	While ( (cGetAlias)->( !Eof() ) )
		cCPFCNPJ	:= If(Len(alltrim((cGetAlias)->RHP_INMED)) == 11, "2", "1")
 		cCNPJForn	:= Substr( (cGetAlias)->RCC_CONTEU, 154, 14 )
	 	cANSForn	:= Substr( (cGetAlias)->RCC_CONTEU, 168, 6 )
		aLstDeps	:= {}

		//Verifica se está posicionado corretamente no fornecedor
		If Empty(cChvForn) .Or. cChvForn <> (cGetAlias)->RHP_TPFORN + (cGetAlias)->RHP_CODFOR
			cChvForn	:= (cGetAlias)->RHP_TPFORN + (cGetAlias)->RHP_CODFOR
			cSeekForn	:= fRetChvFor(IIF((cGetAlias)->RHP_TPFORN == "1", "S016", "S017"), (cGetAlias)->RHP_FILIAL, cPerPag, (cGetAlias)->RHP_CODFOR, cFilCrgTab <> (cGetAlias)->RCC_FILIAL, (cGetAlias)->RHP_FILIAL)
			cFilCrgTab	:= (cGetAlias)->RCC_FILIAL
		EndIf
		
		//Desconsidera registros diferentes da seek correto na tabela de fornecedores
		If cSeekForn <> (cGetAlias)->RCC_FIL + (cGetAlias)->RCC_CHAVE
			(cGetAlias)->(DbSkip())
			Loop
		EndIf

		If (cGetAlias)->RHP_ORIGEM == "2"
			If SRB->( dbSeek( (cGetAlias)->RHP_FILIAL + (cGetAlias)->RHP_MAT + (cGetAlias)->RHP_CODIGO ) )
				aAdd( aLstDeps, { SRB->RB_CIC, (cGetAlias)->RHP_VLRFUN, SRB->RB_COD, (cGetAlias)->RHP_ORIGEM, cCPFCNPJ,(cGetAlias)->RHP_INMED, cCNPJForn, cANSForn, SRB->RB_NOME, Dtos(SRB->RB_DTNASC) } )
			EndIf
		ElseIf (cGetAlias)->RHP_ORIGEM == "3"
			RHM->( dbSetOrder(1) )
			If RHM->( dbSeek( (cGetAlias)->RHP_FILIAL + (cGetAlias)->RHP_MAT + (cGetAlias)->RHP_TPFORN + (cGetAlias)->RHP_CODFOR + (cGetAlias)->RHP_CODIGO ) )
				aAdd( aLstDeps, { RHM->RHM_CPF,(cGetAlias)->RHP_VLRFUN, RHM->RHM_CODIGO, (cGetAlias)->RHP_ORIGEM, cCPFCNPJ,(cGetAlias)->RHP_INMED, cCNPJForn, cANSForn, RHM->RHM_NOME, Dtos(RHM->RHM_DTNASC) } )
			EndIf
		EndIf
		If (cGetAlias)->RHP_ORIGEM == "1"
			nPosR := ascan(aRemTit,{|X| X[1]+X[2]+X[3]+X[4]+X[6]+X[7]== (cGetAlias)->RHP_CODIGO+(cGetAlias)->RHP_ORIGEM+cCpfCnpj+(cGetAlias)->RHP_INMED+cCNPJForn+cANSForn })
			If nPosR == 0
				AaDD(aRemTit, {(cGetAlias)->RHP_CODIGO, (cGetAlias)->RHP_ORIGEM , cCpfCnpj,(cGetAlias)->RHP_INMED,(cGetAlias)->RHP_VLRFUN, cCNPJForn, cANSForn })
			else
				aRemTit[nPosR,5] += (cGetAlias)->RHP_VLRFUN
			Endif
		Endif

		nPos := ascan(aDados,{|X| X[6]==Substr((cGetAlias)->RCC_CONTEU, 154,14) .And. X[7]==Substr((cGetAlias)->RCC_CONTEU, 168,6)}) //busca pelo CNPJ+ANS

		If nPos == 0
			aAdd(aDados, { 	(cGetAlias)->RHP_FILIAL ,;					//Filial da RHP
										(cGetAlias)->RHP_MAT		,; 	//Matric da RHP
										(cGetAlias)->RHP_CODFOR	,; 		//CodFor da RHP
										(cGetAlias)->RHP_PD		,; 		//Verba  da RHP
										(cGetAlias)->RHP_CODIGO	,; 		//Depend da RHP
										cCNPJForn,;  //CNPJ Fornecedor
										cANSForn,; //ANS Fornecedor
										aRemTit,;
										aLstDeps,;
										Iif( (cGetAlias)->RHP_ORIGEM == "1", (cGetAlias)->RHP_VLRFUN, 0),; //Valor Titular
										cCPFMat})
		Else
			If aDados[nPos,7] == cANSForn .And. aDados[nPos,6] == cCNPJForn
				For nX := 1 to Len(aLstDeps)
					nPos2 := ascan(aDados[nPos,9], {|X| X[3]+X[4]+X[5]+X[6] == aLstDeps[nX,3] + aLstDeps[nX,4]+aLstDeps[nX,5]+aLstDeps[nX,6] })
					If nPos2 == 0
						AAdd ( aDados[nPos,9], aLstDeps[nX] )
					Else
						aDados[nPos,9,nPos2,2] += aLstDeps[nX,2]
					EndIf
				Next
			EndIf
		EndIf

		//Adiciona no log caso a informação do número de inscrição do reembolso não for preenchido
		If Empty(cLogAviso) .And. Empty((cGetAlias)->RHP_INMED)
			cLogAviso += OemToAnsi(STR0310) + cQuebra //"Trabalhador possui reembolso sem a informação do número de inscrição do prestador de serviço. "
			cLogAviso += OemToAnsi(STR0311) //"Ajuste o lançamento do reembolso e reenvie o evento S-1210 ou altere no TAF/MID antes de transmitir o evento. "
			//Inclui mensagem nos log`s da rotina
			If lRelat
				aAdd( aRelIncons, { cFil, cCPFMat, cLogAviso } )
			Else
				cLogDep += cLogAviso
			EndIf
		EndIf

		( cGetAlias )->(DbSkip())
	EndDo

	( cGetAlias )->( dbCloseArea() )

Return aDados

/*/{Protheus.doc} fAgreg1210()
Função que verifica Agregados e Pensionistas que não foram cadastrados nos dependentes
@type      	Function
@author   	Silvia Taguti
@version	1.0
@return aDAgreg
*/
Static Function fAgreg1210()

Local nB := 0
Local nS := 0
Local nA := 0
Local lTemDep := .F.
Local aDAgreg := {}

dbSelectArea("SRB")
SRB->(dbSetOrder(1))
SRB->(dbGotop())

For nb := 1 to Len(aRetPensao)
	lTemDep := .F.
	If SRB->( dbSeek( aRetPensao[nb,11] + aRetPensao[nb,12] ))
		While SRB->RB_FILIAL + SRB->RB_MAT == aRetPensao[nb,11] + aRetPensao[nb,12]
			If aRetPensao[nb,4] == SRB->RB_CIC
				lTemDep := .T.
				Exit
			EndIf
			SRB->(dbSkip())
		Enddo
		If !lTemDep
			If Len(aDAgreg) > 0
				If ascan(aDAgreg, {|X| X[3]+X[4] == aRetPensao[nb,2]+AllTrim(aRetPensao[nb,4])}) == 0
					aadd(aDAgreg,{	"99", AllTrim(aRetPensao[nb,3]), aRetPensao[nb,2], AllTrim(aRetPensao[nb,4]),"N","N","N","","","",	""})
				Endif
			else
				aadd(aDAgreg,{	"99", AllTrim(aRetPensao[nb,3]), aRetPensao[nb,2], AllTrim(aRetPensao[nb,4]),"N","N","N","","","",	""})
			Endif
		Endif
	Else
		If Len(aDAgreg) > 0
			If ascan(aDAgreg, {|X| X[3]+X[4] == aRetPensao[nb,2]+AllTrim(aRetPensao[nb,4])}) == 0
				aadd(aDAgreg,{	"99", AllTrim(aRetPensao[nb,3]), aRetPensao[nb,2], AllTrim(aRetPensao[nb,4]),"N","N","N","","",	"",	""})
			Endif
		else
			aadd(aDAgreg,{	"99", AllTrim(aRetPensao[nb,3]), aRetPensao[nb,2], AllTrim(aRetPensao[nb,4]),"N","N","N","","","",	""})
		Endif
	Endif
Next nB

lTemDep := .F.
For nS := 1 to Len(adadosRHS)
	If Len(aDadosRHS[nS,9]) > 0
		For nA := 1 to Len(aDadosRHS[nS,9])
			If adadosRHS[nS,9,nA,4] == "3" //Origem Agregado
				lTemDep := .F.
				If SRB->( dbSeek( adadosRHS[nS,1] + adadosRHS[nS,2] ))
					While SRB->RB_FILIAL + SRB->RB_MAT == adadosRHS[nS,1] + adadosRHS[nS,2]
						If SRB->RB_FILIAL + SRB->RB_MAT == adadosRHS[nS,1] + adadosRHS[nS,2] .And. adadosRHS[nS,9,nA,1] == SRB->RB_CIC
							lTemDep := .T.
							Exit
						EndIf
						SRB->(dbSkip())
					Enddo
					If !lTemDep .And. ( Len(aDAgreg) == 0 .Or. (Len(aDAgreg) > 0 .And. ascan(aDAgreg, {|X| X[3]+X[4] == adadosRHS[nS,9,nA,6] + (adadosRHS[nS,9,nA,1])}) == 0))
						aadd(aDAgreg,{	"99", adadosRHS[nS,9,nA,5], adadosRHS[nS,9,nA,6], adadosRHS[nS,9,nA,1],"N","N","N","","","",""})
					Endif
				elseIf Len(aDAgreg) == 0 .Or. (Len(aDAgreg) > 0 .And. ascan(aDAgreg, {|X| X[3]+X[4] == adadosRHS[nS,9,nA,6] + (adadosRHS[nS,9,nA,1])}) == 0)
					aadd(aDAgreg,{	"99", adadosRHS[nS,9,nA,5], adadosRHS[nS,9,nA,6], adadosRHS[nS,9,nA,1],"N","N","N","","","",""})
				Endif
			Endif
		Next nA
	Endif
Next nS

//Valida as informações de reembolso
If cVersEnvio >= "9.3"
	For nS := 1 to Len(adadosRHP)
		If Len(adadosRHP[nS,9]) > 0
			For nA := 1 to Len(adadosRHP[nS,9])
				If adadosRHP[nS,9,nA,4] == "3" //Origem Agregado
					lTemDep := .F.
					SRB->(dbGotop())
					If SRB->( dbSeek( adadosRHP[nS,1] + adadosRHP[nS,2] ))
						While SRB->RB_FILIAL + SRB->RB_MAT == adadosRHP[nS,1] + adadosRHP[nS,2]
							If SRB->RB_FILIAL + SRB->RB_MAT == adadosRHP[nS,1] + adadosRHP[nS,2] .And. adadosRHP[nS,9,nA,1] == SRB->RB_CIC
								lTemDep := .T.
								Exit
							EndIf
							SRB->(dbSkip())
						Enddo
					EndIf
					If !lTemDep .And. Len(aDAgreg) == 0 .Or. (Len(aDAgreg) > 0 .And. ascan(aDAgreg, {|X| X[3]+X[4] == adadosRHP[nS,9,nA,10]+adadosRHP[nS,9,nA,1]}) == 0)
						aadd(aDAgreg, {	"99", adadosRHP[nS,9,nA,9], adadosRHP[nS,9,nA,10], adadosRHP[nS,9,nA,1],"N","N","N","","","",""})
					Endif
				Endif
			Next nA
		Endif
	Next nS
EndIf

Return aDAgreg

/*/{Protheus.doc} fGM1210Dep()
Função que carrega os dependentes do funcionario
@type      	Function
@author   	Silvia Taguti
@version	1.0
@return aDep
*/
Static Function fGM1210Dep(cFilTrab, cMatTrab, cVersEnvio, aDep )
	Local aArea := GetArea()
	Local nPosDpInc := SRB->(ColumnPos("RB_INCT"))
	Local lDescDep  := cVersEnvio >= "9.2" .And. SRB->(ColumnPos("RB_DESCDEP")) > 0
	Local cIncTrab 	:= "N"
	Local cDescDep	:= ""

	Default cVersEnvio	:= "9.2"
	Default aDep        := {}

	dbSelectArea("SRB")
	SRB->(DbSetOrder(1))
	SRB->(MsSeek(cFilTrab + cMatTrab))

	While !SRB->(Eof()) .And. (cFilTrab + cMatTrab == SRB->RB_FILIAL + SRB->RB_MAT)
		If (cFilTrab + cMatTrab == SRB->RB_FILIAL + SRB->RB_MAT)
			If(nPosDpInc > 0)
				cIncTrab := Iif( SRB->RB_INCT $ " |1","N","S" )
			EndIf

			If lDescDep
				cDescDep := SRB->RB_DESCDEP
			EndIf

			Aadd(aDep,{	SRB->RB_TPDEP,;
						AllTrim(SRB->RB_NOME),;
						DtoS(SRB->RB_DTNASC),;
						AllTrim(SRB->RB_CIC),;
						Iif(SRB->RB_TIPIR   == "4","N","S"),;
						Iif(SRB->RB_TIPSF   == "3","N","S"),;
						Iif(SRB->RB_PLSAUDE == "1","S","N"),;
						AllTrim(SRB->RB_COD),;
						cIncTrab,;
						"",;					//Se preenchido, gerar no infodep
						AllTrim(cDescDep)})
		EndIf
		SRB->(dbSkip())
	Enddo

	RestArea(aArea)
Return

/*/{Protheus.doc} fStatDep()
Função que verifica se os dependentes do funcionario foram integrados no TAF
@type      	Function
@author   	Silvia Taguti
@version	1.0
@return aDep
*/
Static Function fStatDep(aDepen, cFilDep, cCPF,cCodUnic,cTPEven, cCatef, cAdmis )

Local aArea 	:= GetArea()
Local lRet		:= .T.
Local cIdFunc	:= ""
Local aDedT3T   := {}
Local aDedC9Y   := {}
Local aDedT2F   := {}
Local nD        := 0
Local cVerFun   := ""
Local cStat1    := ""
Local lGeraMat	:= .F.
Local cLstCPF   := ""
Local cFilBsC9Y	:= ""
Local cFilBsT2F	:= ""
Local cFilBsT1U	:= ""
Local cFilBsT3T	:= ""

Default cCPF		:= ""
Default cCodUnic	:= ""
Default cFilDep     := ""
Default aDepen      := {}
Default cTPEven     := "S2200"
Default cCatef 	    := ""
Default cAdmis      := ""

lGeraMat := ( SRA->RA_DESCEP == "1" )

	//A pesquisa será realizada apenas se os parâmetros foram informados
	If !Empty(cCPF) .And. !Empty(cCodUnic)
		//Encontra o Id do funcionário na tabela C9V
		DBSelectArea("C9V")
		If cTPEven == "S2200"
			cLstCPF := AllTrim(cCPF) + ";" + cCodUnic
			cStat1  := TAFGetStat( "S-2200", cLstCPF )
			If cStat1 == "4"
				cIdFunc := C9V->C9V_ID
				cVerFun := C9V->C9V_VERSAO
			Endif
		Else
			cLstCPF := AllTrim( cCPF ) + ";" + If(lGeraMat, cCodUnic, "") + ";" + AllTrim( cCatef ) + ";" + cAdmis
			cStat1  := TAFGetStat( "S-2300", cLstCPF )
			If cStat1 == "4"
				cIdFunc := C9V->C9V_ID
				cVerFun := C9V->C9V_VERSAO
			Endif
		Endif
    Endif
	//Busca dependentes gerados pelo S-2200
	If !Empty(cIdFunc)
		cFilBsC9Y	:= fwXFilial("C9Y",cFilDep)
		DBSelectArea("C9Y")
		C9Y->(DBSetOrder(1))
		If C9Y->(DBSEEK(cFilBsC9Y + cIdFunc+cVerFun ))
			While C9Y->( !EOF() ) .And. C9Y->C9Y_FILIAL + C9Y->C9Y_ID+C9Y->C9Y_VERSAO == cFilBsC9Y+cIdFunc+cVerFun
				If C9Y->C9Y_FILIAL + C9Y->C9Y_ID +C9Y->C9Y_VERSAO == cFilBsC9Y+cIdFunc+cVerFun
					AAdd(aDedC9Y,{C9Y->C9Y_FILIAL, C9Y->C9Y_IDDEP, C9Y->C9Y_CPFDEP, Dtos(C9Y->C9Y_DTNASC), C9Y->C9Y_NOMDEP})
				Endif
				C9Y->( DbSkip() )
			EndDo
		Endif
		//Busca dependentes gerados pelo S-2300
		cFilBsT2F	:= fwXFilial("T2F",cFilDep)
		DBSelectArea("T2F")
		T2F->(DBSetOrder(1))
		If T2F->(DBSEEK(cFilBsT2F + cIdFunc + cVerFun))
			While T2F->( !EOF() ) .And. T2F->T2F_FILIAL+T2F->T2F_ID+T2F->T2F_VERSAO == cFilBsT2F+cIdFunc+cVerFun
				If T2F->T2F_FILIAL+T2F->T2F_ID+T2F->T2F_VERSAO == cFilBsT2F+cIdFunc+cVerFun
					AAdd(aDedT2F,{T2F->T2F_FILIAL, T2F->T2F_IDDEP, T2F->T2F_CPFDEP, Dtos(T2F->T2F_DTNASC), T2F->T2F_NOMDEP})
				Endif
				T2F->( DbSkip() )
			EndDo
		Endif

		// Busca dependentes integrados pelo evento S-2205
 		DBSelectArea("T3T")
		T3T->(DBSetOrder(1))

		cFilBsT1U	:= fwXFilial("T1U",cFilDep)
		cFilBsT3T	:= fwXFilial("T3T",cFilDep)
		DBSelectArea("T1U")
		T1U->(DBSetOrder(2))

		If T1U->(DBSEEK(cFilBsT1U + cIdFunc  ))
			While T1U->( !EOF() ) .And. T1U->T1U_FILIAL+T1U->T1U_ID == cFilBsT1U+cIdFunc
				If T1U->T1U_FILIAL+T1U->T1U_ID == cFilBsT1U+cIdFunc .And. T1U->T1U_Ativo == '1' .And.  T1U->T1U_STATUS = "4"
					If T3T->(DBSEEK(cFilBsT3T + cIdFunc + T1U->T1U_VERSAO ))
						While T3T->(!EOF()) .And. T3T->T3T_FILIAL + T3T->T3T_ID +T3T->T3T_VERSAO == cFilBsT3T+cIdFunc+T1U->T1U_VERSAO
							If T3T->T3T_FILIAL + T3T->T3T_ID +T3T->T3T_VERSAO == cFilBsT1U+cIdFunc+T1U->T1U_VERSAO
								AAdd(aDedT3T,{T3T->T3T_FILIAL, T3T->T3T_ID, T3T->T3T_CPFDEP, Dtos(T3T->T3T_DTNASC), T3T->T3T_NOMDEP})
							Endif
							T3T->( DbSkip() )
						EndDo
					Endif
				Endif
				T1U->( DbSkip() )
			Enddo
		Endif
	Endif
    //Quando o dependente é encontrado na C9Y ou na T3T com status 4, não deve ser gerado na S-1210, grava N na posição 10
	If Len(aDedT3T) > 0 .or. Len(aDedC9Y) > 0 .Or. Len(aDedT2F) > 0
		For nD:= 1 to Len(aDepen)
			If Ascan(aDedC9Y, {|X| X[1]+X[3]+X[4] == cFilBsC9Y + aDepen[nD,4]+aDepen[nD,3] }) > 0 .Or.;
			   Ascan(aDedT3T, {|X| X[1]+X[3]+X[4] == cFilBsT3T + aDepen[nD,4]+aDepen[nD,3] }) > 0 .Or.;
			   Ascan(aDedT2F, {|X| X[1]+X[3]+X[4] == cFilBsT2F + aDepen[nD,4]+aDepen[nD,3] }) > 0
				aDepen[nD,10] := "N"
			Endif
		Next Nx
	Endif
RestArea(aArea)

Return lRet


/*/{Protheus.doc} fInfIRComp
Carrega os dados do grupo informações complementares <infoIRComplem> do evento S-1210 na variável aCodRece
@author lidio.oliveira
@since 19/03/2025
/*/
Static Function fInfIRComp()

	Local nX 		:= 0
	Local nG		:= 0
	Local nT		:= 0
	Local nPos		:= 0
	Local aAgreg	:= {}
	Local aInfoDep	:= {}

	//Inclusão de Agregados do PLA e Pensão não cadastrados no SRB
	aAgreg := fAgreg1210()
	If Len(aAgreg) > 0
		For nX := 1 to Len(aAgreg)
			aAdd( aDepen, aClone( aAgreg[nX] ) )
		Next nX
    Endif

	//Dedução de dependente <dedDepen>
	For nX := 1 to Len(aDedDep)
		If Len(aDedDep) > 0
			nPos := ASCAN(aCodRece,{|X| X[1]== aDedDep[nX,7]})
			If nPos > 0
				If Empty(aDedDep[nX][4])
					cLogDep += aDedDep[nX][1] + " - " + aDedDep[nX][2]
					cLogDep += OemToAnsi(STR0233) + aDedDep[nX][3] + OemToAnsi(STR0234) + cQuebra //" - O dependente [##] não possui CPF preenchido e não foi enviado para o eSocial."
				Else
					AAdd( aCodRece[nPos,2], aDedDep[nX] )
				EndIf
			Endif
		Endif
	Next nX

	//Dedução de dependente <penAlim>
	For nX := 1 to Len(aRetPensao)
		If Len(aRetPensao) > 0
			nPos := ASCAN(aCodRece,{|X| X[1]== aRetPensao[nX,10]})
			If nPos > 0
				AAdd ( aCodRece[nPos,3], aRetPensao[nX] )
			Endif
		Endif
	Next nX

	//Previdência Complementar <previdCompl>
	For nX := 1 to Len(aInfoPrev)
		If Len(aInfoPrev) > 0
			nPos := ASCAN(aCodRece,{|X| X[1]== aInfoPrev[nX,5]})
			AAdd ( aCodRece[nPos,4], aInfoPrev[nX] )
		Endif
	Next nX

	//Ajusta array de dependente para gerar os dados somente de dependentes com movimento
	For nX := 1 To Len(aDepen)
		If !(aDepen[nX][10] == "N")
			//Verifica se o dependente possui valores e dedução
			If aScan(aDedDep, {|x| x[4] ==  aDepen[nX][4] }) > 0 .And. aScan(aInfoDep, {|x| x[4] ==  aDepen[nX][4] }) == 0
				AAdd( aInfoDep, aDepen[nX] )
				Loop
			EndIf
			//Verifica se o dependente possui valores de pensão alimentícia
			If aScan(aRetPensao, {|x| x[4] ==  aDepen[nX][4] }) > 0 .And. aScan(aInfoDep, {|x| x[4] ==  aDepen[nX][4] }) == 0
				AAdd( aInfoDep, aDepen[nX] )
				Loop
			EndIf
			//Verifica se o dependente possui valores de assistência médica
			For nG := 1 To Len(adadosRHS)
				For nT := 1 To Len(aDadosRHS[nG,9])
					If AllTrim(aDadosRHS[nG][9][nT][1]) == AllTrim(aDepen[nX][4]) .And. aScan(aInfoDep, {|x| x[4] ==  aDepen[nX][4] }) == 0
						AAdd( aInfoDep, aDepen[nX] )
						Loop
					EndIf
				Next nT
			Next NG
			//Verifica se o dependente possui valores de coparticipação/reembolso
			For nG := 1 To Len(adadosRHP)
				For nT := 1 To Len(adadosRHP[nG,9])
					If AllTrim(adadosRHP[nG][9][nT][1]) == AllTrim(aDepen[nX][4]) .And. aScan(aInfoDep, {|x| x[4] ==  aDepen[nX][4] }) == 0
						AAdd( aInfoDep, aDepen[nX] )
						Loop
					EndIf
				Next nT
			Next nG
		EndIf
	Next nX

	//Recria o array aDepen e
	//Verifica no array aInfoDep se há algum registro com CPF vazio e informa no Log
	aDepen := {}
	For nX := 1 To Len(aInfoDep)
		If Empty(aInfoDep[nX][4])
			cLogDep += OemToAnsi(STR0233) + aInfoDep[nX][1] + " - " + aInfoDep[nX][2] + OemToAnsi(STR0234) + cQuebra //" - O dependente [##] não possui CPF preenchido e não foi enviado para o eSocial."
		Else
			AAdd( aDepen, aInfoDep[nX] )
		EndIf
	Next Nx

Return


/*/{Protheus.doc} fRetChvFor
Retorna a chave RCC_FILIAL + RCC_CHAVE do fornecedor posicionado
@author lidio.oliveira
@since 11/07/2025
/*/
Static Function fRetChvFor(cTabRCC, cRCC_FIL, cRCC_CHAVE, cCodigo, lCargaTab, cFilFunc)

	Local cRet		:= ""
	Local nPosTab	:= 0
	Local aTabForn	:= {}

	DefaulT cTabRCC		:= ""
	DefaulT cRCC_FIL	:= ""
	DefaulT cRCC_CHAVE	:= "" //Competência na RCC
	DefaulT cCodigo		:= "" //Competência do Fornecedor
	Default lCargaTab	:= .F. //Força o carregamento da tabela
	Default cFilFunc	:= cFilAnt

	//Carrega os fornecedores de plano de saúde
	If Empty(aTabS016) .Or. lCargaTab
		aTabS016 := {}
		RstGpexIni()
		fRetTab(@aTabS016,"S016",,,,,.T.,cFilFunc)
	EndIf

	//Carrega os fornecedores de plano odontológico
	If Empty(aTabS017) .Or. lCargaTab
		aTabS017 := {}
		RstGpexIni()
		fRetTab(@aTabS017,"S017",,,,,.T.,cFilFunc)
	EndIf

	If cTabRCC == "S016"
		aTabForn := aClone(aTabS016)
	Else
		aTabForn := aClone(aTabS017)
	EndIf

	//Identifica a chave da do fornecedor
	If Len(aTabForn) > 0
		//Procura o resgistro com filial e com o mês de referência
		If (nPosTab:= Ascan(aTabForn,{ |x| x[1] == cTabRCC .And. x[2] == cRCC_FIL .And. x[3] == cRCC_CHAVE .And. x[5] == cCodigo })) > 0
			cRet := aTabForn[nPosTab][2] + aTabForn[nPosTab][3]
		//Procura o registro sem filial mas com o mesmo mês de referência
		ElseIf (nPosTab := Ascan(aTabForn,{ |x| x[1] == cTabRCC .And.x[2] == Space(Len(cRCC_FIL)) .And. x[3] == cRCC_CHAVE .And. x[5] == cCodigo })) > 0
			cRet := aTabForn[nPosTab][2] + aTabForn[nPosTab][3]
		//Procura o resgistro com filial e sem mês referência
		ElseIf (nPosTab := Ascan(aTabForn,{ |x| x[1] == cTabRCC .And. x[2] == cRCC_FIL .And. x[5] == cCodigo})) > 0
			cRet := aTabForn[nPosTab][2] + aTabForn[nPosTab][3]
		//Procura o resgistro sem filial e sem mês referência
		ElseIf (nPosTab := Ascan(aTabForn,{ |x| x[1] == cTabRCC .And. x[2] == Space(Len(cRCC_FIL)) .And. x[5] == cCodigo})) > 0
			cRet := aTabForn[nPosTab][2] + aTabForn[nPosTab][3]
		EndIf
	EndIf

Return cRet
