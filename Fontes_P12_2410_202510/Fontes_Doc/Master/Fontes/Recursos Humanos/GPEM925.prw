#INCLUDE 'Protheus.ch'
#INCLUDE "TopConn.ch"
#INCLUDE "GPEM925.ch"
/*/{Protheus.doc} GPEM925
Carga Inicial SIGAGPE x NG (AP)
@type  Function
@author rafaelalmeida
@since 08/06/2020
@version 12,1,27
/*/
Function GPEM925()

Local cUserId   := ""
Local cMsg      := ""
Local cLog      := ""
Local cFilIni   := ""
Local cFilFin   := ""
Local cMatIni   := ""
Local cMatFin   := ""
Local cPesIni   := ""
Local cPesFin   := ""
Local cCrgIni   := ""
Local cCrgFin   := ""
Local lProcSRA  := .F.
Local lProcSRE  := .F.
Local lProcSR7  := .F.
Local lProcSRB  := .F.
Local lProcSQG  := .F.
Local lProcSQB  := .F.
Local lProcSQ3  := .F.
Local lLog      := .F.
Local aLogSra   := {}
Local aLogSre   := {}
Local aLogSr7   := {}
Local aLogSrb   := {}
Local aLogSqg   := {}
Local lSched	:= FwIsInCallStack("WFLAUNCHER") .or. FwIsInCallStack("FWBOSCHDEXECUTE")

Private aLogSqb   := {}
Private aLogSq3   := {}
Private lIncDem   := .F.

If !lSched 
	If !SuperGetMv("MV_RHNG",.F. ,.F.)
		MsgStop(STR0001+CRLF+;//##"A integração SIGAGPE x NG não está configurada neste ambiente."
				STR0002,STR0003)//##"Verifique se o seu ambiente está parâmetrizado corretamente!"##"Parâmetro MV_RHNG"
		Return Nil
	EndIf

	//"Este processamento pode levar alguns minutos."
	//"O tempo de processamentop pode variar de acordo com o tamanho da sua base de dados!"
	//"Tem certeza que deseja realizar o processo de carga inicial?"
	cUserId := SubStr(cUsuario,7,15)
	If FPergunte("GPEM925") .And.MsgNoYes(STR0004 + CRLF + STR0005 + CRLF + CRLF + STR0006) .And. !GPESmartViewUtils():ValidBackGExec("GPEM925", 7, {MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09, MV_PAR10, MV_PAR11, MV_PAR12, MV_PAR13, MV_PAR14, MV_PAR15, MV_PAR16, MV_PAR17, cUserId})

		cFilIni     := MV_PAR01
		cFilFin     := MV_PAR02
		lProcSRA    := MV_PAR03
		lProcSRE    := MV_PAR04
		lProcSR7    := MV_PAR05
		lProcSRB    := MV_PAR06
		cMatIni     := MV_PAR07
		cMatFin     := MV_PAR08
		lProcSQG    := MV_PAR09
		cPesIni     := MV_PAR10
		cPesFin     := MV_PAR11
		lProcSQB    := MV_PAR12
		cCrgIni     := MV_PAR13
		cCrgFin     := MV_PAR14
		lProcSQ3    := MV_PAR15
		lLog        := MV_PAR16
		lIncDem     := MV_PAR17

	Else
		Return Nil
	EndIf
EndIf

if !lSched 
	If lProcSRA
		Processa({||LoadSRA(cUserId,@cMsg,@aLogSra,cFilIni,cFilFin,cMatIni,cMatFin,lSched)}, STR0007, STR0008,.F.)//##"Aguarde..."##"Processando Cadastro de Funcionários (SRA)..."
		cLog += cMsg + CRLF
	EndIf

	If lProcSRE
		Processa({||LoadSRE(cUserId, @cMsg, @aLogSre, cFilIni, cFilFin, cMatIni, cMatFin,lSched)}, STR0007, STR0056, .F.) //"Aguarde..."##"Processando o Histórico de transferências (SRE)..."
		cLog += cMsg + CRLF
	EndIf

	If lProcSR7
		Processa({||LoadSR7(cUserId, @cMsg, @aLogSr7, cFilIni, cFilFin, cMatIni, cMatFin,lSched)}, STR0007, STR0057, .F.)//##"Aguarde..."##"Processando o Histórico Salarial (SR7)..."
		cLog += cMsg + CRLF
	EndIf

	If lProcSRB
		Processa({||LoadSRB(cUserId,@cMsg,@aLogSrb,cFilIni,cFilFin,cMatIni,cMatFin,lSched)}, STR0007, STR0009,.F.)//##"Aguarde..."##"Processando Cadastro de Dependentes (SRB)..."
		cLog += cMsg + CRLF
	EndIf

	If lProcSQG
		Processa({||LoadSQG(cUserId,@cMsg,@aLogSQG,cFilIni,cFilFin,cPesIni,cPesFin,lSched)}, STR0007, STR0010,.F.)//##"Aguarde..."##"Processando  Cadastro de Candidatos (SQG)..."
		cLog += cMsg + CRLF
	EndIf

	If lProcSQB
		Processa({||LoadSQB(cUserId,@cMsg,@aLogSqb,cFilIni,cFilFin,lSched)}, STR0007, STR0046,.F.)//##"Aguarde..."##"Processando Cadastro de Departamentos (SQB)..."
		cLog += cMsg + CRLF
	EndIf

	If lProcSQ3
		Processa({||LoadSQ3(cUserId,@cMsg,@aLogSq3,cFilIni,cFilFin, cCrgIni,cCrgFin,lSched)}, STR0007, STR0053,.F.)//##"Aguarde..."##"Processando Cadastro de Cargos (SQ3)..."
		cLog += cMsg + CRLF
	EndIf

	If lProcSRA .Or. lProcSRB .Or. lProcSQG .Or. lProcSQB .Or. lProcSQ3 .or. lLog .Or. lProcSRE .Or. lProcSR7
		If lLog .And. (!Empty(aLogSRA) .Or. !Empty(aLogSRB) .Or. !Empty(aLogSQG) .Or. !Empty(aLogSqb) .Or. !Empty(aLogSq3) .Or. !Empty(aLogSRE) .Or. !Empty(aLogSR7))
			Processa({|| GravaLog(aLogSRA,aLogSRB,aLogSQG,aLogSqb,aLogSq3,aLogSRE,aLogSR7,lSched)}, STR0007, STR0011,.F.) //##"Aguarde..."##"Gerando arquivo de Log..."
		EndIf

		MsgInfo(cLog, STR0012)//##"Fim do Processamento da Carga Inicial"
	Else
		// "Você marcou como não em todos os parâmetros!"
		// "Nenhum dado será processado!"
		MsgStop(STR0013 + CRLF + STR0014)
	EndIf
else
	Processa({||ExecSched(lSched)})
Endif

Return Nil


/*/{Protheus.doc} LoadSRA
Realiza a carga dos registros da SRA.
@type  Static Function
@author rafaelalmeida
@since 08/06/2020
@version 12.1.27
@param cUserId, Character, Código do Usuário
@param cMsg , Character, Mensagem de processamento.
@param aLog , Character, Array contendo log de processamento
@param lSched, Logical, Se será processado em segundo plano
/*/
Static Function LoadSRA(cUserId,cMsg,aLog,cFilIni,cFilFin,cMatIni,cMatFin,lSched)

Local aAreOld 	:= GetArea()
Local cAlsQry   := GetNextAlias()
Local cChave    := ""
Local cTime     := ""
Local nTotalReg := 0
Local cBkpFil	:= cFilAnt

Default cUserId   := SubStr(cUsuario,7,15)
Default cMsg    := ""
Default aLog    := {}
Default cFilIni := ""
Default cFilFin := ""
Default cMatIni := ""
Default cMatFin := ""
Default lSched := .F.

	BeginSQL Alias cAlsQry
		SELECT RA_FILIAL, RA_MAT
		FROM %Table:SRA% SRA
		WHERE RA_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFin%
		AND RA_MAT BETWEEN %Exp:cMatIni% AND %Exp:cMatFin%
		AND SRA.%NotDel%
	EndSQL

	(cAlsQry)->(dbEval({||nTotalReg++}))
	(cAlsQry)->(dbGoTop())

	if !lSched
		ProcRegua(nTotalReg)
	Endif

	nTotalReg := 0

	dbSelectArea("RJP")
	dbSetOrder(6)

	While !(cAlsQry)->(Eof())
		if !lSched
			IncProc()
		Endif

		cChave  := cEmpAnt + "|" + (cAlsQry)->RA_FILIAL + "|" + (cAlsQry)->RA_MAT

		If RJP->(dbSeek(xFilial("RJP", (cAlsQry)->RA_FILIAL ) + cChave))
			(cAlsQry)->(dbSkip())
			LOOP
		Else
			cTime   := Time()
			Aadd(aLog, {cChave, dDataBase, cTime, cUserId})
			nTotalReg++

			Begin Transaction
				If !(cFilAnt == (cAlsQry)->RA_FILIAL)// Gero as informações na RJP fazendo xFilial
					cFilAnt := (cAlsQry)->RA_FILIAL
				EndIf
				fSetInforRJP((cAlsQry)->RA_FILIAL, (cAlsQry)->RA_MAT, "SRA", cChave, "I",  dDataBase, cTime, cUserId)
				RJP->(dbSetOrder(6))  //RJP_FILIAL+RJP_KEY
				If RJP->(dbSeek(xFilial("RJP")+cChave))
					RecLock("RJP",.F.)
					RJP->RJP_CGINIC := '1'
					RJP->(MsUnlock())
				Else
					DisarmTransaction()
				EndIf
			End Transaction
		Endif
		(cAlsQry)->(dbSkip())
	EndDo

	If nTotalReg == 0
		cMsg := STR0015// ##"Não foram encontrados registros elegíveis para processamento no cadastro de funcionários. (SRA)"
	else
		cMsg := STR0016+cValToChar(nTotalReg)+STR0017//##"Foram processados "##" registros do cadastro de funcionários (SRA)."
		cFilAnt := cBkpFil
	EndIf

	(cAlsQry)->(dbCloseArea())

	RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} LoadSRE
Realiza a carga dos registros da SRE.
@type Static Function
@author Cícero Alves
@since 19/03/2021
@version 12.1.27
@param cUserId, Caracter, Código do Usuário
@param cMsg, Caracter, Mensagem de processamento.
@param aLog, Array, Array contendo log de processamento
@param cFilIni, Caracter, Filial inicial para filtro dos dados
@param cFilFin, Caracter, Filial final para filtro dos dados
@param cMatIni, Caracter, Matrícula inicial para filtro dos dados
@param cMatFin, Caracter, Matrícula final para filtro dos dados
@param lSched, Logical, Se será processado em segundo plano
/*/
Static Function LoadSRE(cUserId, cMsg, aLog, cFilIni, cFilFin, cMatIni, cMatFin,lSched)

    Local aAreOld	:= GetArea()
    Local cAlsQry   := GetNextAlias()
    Local cChave    := ""
    Local cTime     := ""
    Local nTotalReg := 0
    Local aTransf   := {}
    Local nI		:= 1
	Local cBkpFil	:= cFilAnt
    Local cSitFol   := ""

    Default cUserId := SubStr(cUsuario, 7, 15)
    Default cMsg    := ""
    Default aLog    := {}
    Default cFilIni := ""
    Default cFilFin := ""
    Default cMatIni := ""
    Default cMatFin := ""
	Default lSched  := .F.

    If lIncDem
       cSitFol := "(' ','A','D','F','T')"
    Else
       cSitFol := "(' ','A','F','T')"
    EndIf

    cSitFol := "%" + cSitFol + "%"

    BeginSQL Alias cAlsQry
        SELECT RA_FILIAL, RA_MAT
        FROM %Table:SRA% SRA
        WHERE RA_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:cFilFin%
        AND RA_MAT BETWEEN %Exp:cMatIni% AND %Exp:cMatFin%
        AND	RA_SITFOLH IN %exp:cSitFol%
        AND SRA.%NotDel%
    EndSQL

	if !lSched
    	ProcRegua((cAlsQry)->(LastRec()))
	endif

    dbSelectArea("RJP")

    While !(cAlsQry)->(Eof())
        aTransf := {}

		if !lSched
        	IncProc()
		Endif

        If fTransf( @aTransf,,,,,, .F., .T.,,,,, (cAlsQry)->RA_FILIAL, (cAlsQry)->RA_MAT ) // Busca todas as transferências do funcionário
			For nI := 1 To Len(aTransf)
				RJP->(dbSetOrder(2)) // RJP_FIL + RJP_MAT + RJP_KEY + DTOS(RJP_DATA)
				cChave  := cEmpAnt + "|" + aTransf[nI][8] + "|" + aTransf[nI][9] + "|" + dToS(aTransf[nI][7])	//RJP_KEY busca SRE no schedule pela origem
                If ! RJP->(dbSeek( aTransf[nI][10] + aTransf[nI][11] + cChave ))								//RJP_FIL/MAT destino da transferência
                    nTotalReg++
					cTime := Time()
					Aadd(aLog, {cChave, dDataBase, cTime, cUserId})
                    Begin Transaction
						If !(cFilAnt == aTransf[nI][10])// Gero as informações na RJP fazendo xFilial
							cFilAnt := aTransf[nI][10]
						EndIf
                        fSetInforRJP(aTransf[nI][10], aTransf[nI][11], "SRE", cChave, "I",  dDataBase, cTime, cUserId)
                        RJP->(dbSetOrder(6))//RJP_FILIAL+RJP_KEY
                        If RJP->(dbSeek(xFilial("RJP")+cChave))
                            RecLock("RJP", .F.)
                            RJP->RJP_CGINIC := '1'
                            RJP->(MsUnlock())
                        Else
                            DisarmTransaction()
                        EndIf
                    End Transaction
                EndIf

            Next nI
        EndIf
		(cAlsQry)->(dbSkip())
    EndDo

    If nTotalReg == 0
        cMsg := STR0058 // "Não foram encontrados registros elegíveis para processamento no histórico de transferências. (SRE)"
    else
        cMsg := STR0016 + cValToChar(nTotalReg) + STR0059 // "Foram processados "##" registros do histórico de transferências. (SRE)"
		cFilAnt := cBkpFil
    EndIf

	(cAlsQry)->(dbCloseArea())

	RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} LoadSR7
Realiza a carga dos registros da SR7.
@type Static Function
@author Cícero Alves
@since 19/03/2021
@version 12.1.27
@param cUserId, Caracter, Código do Usuário
@param cMsg, Caracter, Mensagem de processamento.
@param aLog, Array, Array contendo log de processamento
@param cFilIni, Caracter, Filial inicial para filtro dos dados
@param cFilFin, Caracter, Filial final para filtro dos dados
@param cMatIni, Caracter, Matrícula inicial para filtro dos dados
@param cMatFin, Caracter, Matrícula final para filtro dos dados
@param lSched, Logical, Se será processado em segundo plano
/*/
Static Function LoadSR7(cUserId, cMsg, aLog, cFilIni, cFilFin, cMatIni, cMatFin, lSched)

	Local aAreOld 	:= GetArea()
	Local cAlsQry   := GetNextAlias()
	Local cChave    := ""
	Local cTime     := ""
	Local nTotalReg := 0
	Local cCargoAnt	:= ""
	Local cFuncaoAnt:= ""
	Local aTransf   :={}
	Local cFilSR7   := ""
	Local cMatSR7   := ""
	Local nx        := 1
    Local cSitFol   := ""

	Default cUserId := SubStr(cUsuario, 7, 15)
	Default cMsg    := ""
	Default aLog    := {}
	Default cFilIni := ""
	Default cFilFin := ""
	Default cMatIni := ""
	Default cMatFin := ""
	Default lSched  := .F.

	If !Empty(cFilIni)
		cFilIni := xFilial("SR7",cFilIni)
	EndIf

    If lIncDem
       cSitFol := "(' ','A','D','F','T')"
    Else
       cSitFol := "(' ','A','F','T')"
    EndIf

    cSitFol := "%" + cSitFol + "%"

	BeginSQL Alias cAlsQry
		SELECT RA_FILIAL, RA_MAT
		FROM %Table:SRA% SRA
		WHERE RA_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SRA", cFilFin)%
		AND RA_MAT BETWEEN %Exp:cMatIni% AND %Exp:cMatFin%
		AND	RA_SITFOLH IN %exp:cSitFol%
		AND SRA.%NotDel%
	EndSQL

	(cAlsQry)->(dbEval({||nTotalReg++}))
	(cAlsQry)->(dbGoTop())

	if !lSched
		ProcRegua(nTotalReg)
	endif

	nTotalReg := 0

	dbSelectArea("RJP")
	dbSetOrder(6)

	dbSelectArea("SR7")
	dbSetOrder(1)

	While !(cAlsQry)->(Eof())

		if !lSched
			IncProc()
		endif

		cCargoAnt := ""
		cFuncaoAnt := ""

		If SR7->(dbSeek((cAlsQry)->(RA_FILIAL + RA_MAT)))
			fTransf( @aTransf, , , , , , , , , , , , (cAlsQry)->RA_FILIAL, (cAlsQry)->RA_MAT)
			While SR7->( !EoF() .And. R7_FILIAL + R7_MAT ==  (cAlsQry)->(RA_FILIAL + RA_MAT))
				If !(SR7->R7_CARGO == cCargoAnt) .Or. !(SR7->R7_FUNCAO == cFuncaoAnt)
					cCargoAnt := SR7->R7_CARGO
					cFuncaoAnt := SR7->R7_FUNCAO
					cFilSR7		:= SR7->R7_FILIAL
					cMatSR7		:= SR7->R7_MAT

					If !Empty(aTransf)
						For nX := 1 to Len(aTransf)
							IF aTransf[nX,8] != aTransf[nX,10] .And. aTransf[nX, 7] > SR7->R7_DATA
								cFilSR7 := aTransf[nX, 8]
								cMatSR7 := aTransf[nX, 9]
								Exit
							Endif
						Next nX
					Endif

					//cChave := SR7->(cEmpAnt + "|" + R7_FILIAL + "|" + R7_MAT + "|" + DtoS(R7_DATA) + "|" + R7_SEQ + "|" + R7_TIPO)
					cChave := (cEmpAnt + "|" + cFilSR7 + "|" +cMatSR7+ "|" +DtoS(SR7->R7_DATA)+ "|" +SR7->R7_SEQ+ "|" +  SR7->R7_TIPO)

					If RJP->(dbSeek(xFilial("RJP") + cChave))
						SR7->(dbSkip())
						LOOP
					Else
						cTime   := Time()
						Aadd(aLog, {cChave, dDataBase, cTime, cUserId})
						nTotalReg++
						Begin Transaction
							fSetInforRJP(SR7->R7_FILIAL, SR7->R7_MAT, "SR7", cChave, "I",  dDataBase, cTime, cUserId)
							RJP->(dbSetOrder(6))
							If RJP->(dbSeek(xFilial("RJP") + cChave))
								RecLock("RJP",.F.)
								RJP->RJP_CGINIC := '1'
								RJP->(MsUnlock())
							Else
								DisarmTransaction()
							EndIf
						End Transaction
					EndIf
				EndIf
				SR7->(dbSkip())
			EndDo
		EndIf
		(cAlsQry)->(dbSkip())
	EndDo

	If nTotalReg == 0
		cMsg := STR0060		// "Não foram encontrados registros elegíveis para processamento no histórico salarial. (SR7)"
	else
		cMsg := STR0016 + cValToChar(nTotalReg) + STR0061 // "Foram processados "## " registros do cadastro de histórico salarial (SR7)."
	EndIf

	(cAlsQry)->(dbCloseArea())

	RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} LoadSRB

	Realiza a carga dos registros da SRB.

	@type  Static Function
	@author rafaelalmeida
	@since 08/06/2020
	@version 12.1.27
	@param cUserId, Character, Código do Usuário
	@param cMsg , Character, Mensagem de processamento.
	@param aLog , Character, Array contendo log de processamento
	@param lSched, Logical, Se será processado em segundo plano
	/*/
Static Function LoadSRB(cUserId,cMsg,aLog,cFilIni,cFilFin,cMatIni,cMatFin,lSched)

Local aAreOld := GetArea()

Local cAlsQry   := GetNextAlias()
Local cChave    := ""
Local cTime     := ""

Local nTotalReg := 0

Default cUserId := SubStr(cUsuario,7,15)
Default cMsg    := ""
Default aLog    := {}
Default cFilIni := ""
Default cFilFin := ""
Default cMatIni := ""
Default cMatFin := ""
Default lSched  := .F.

If !Empty(cFilIni)
	cFilIni := xFilial("SRB",cFilIni)
EndIf

BeginSQL Alias cAlsQry
	SELECT RA_FILIAL, RA_MAT
	FROM %Table:SRA% SRA
	WHERE RA_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SRA", cFilFin)%
	AND RA_MAT BETWEEN %Exp:cMatIni% AND %Exp:cMatFin%
	AND	RA_SITFOLH != 'D'
	AND SRA.%NotDel%
EndSQL

(cAlsQry)->(dbEval({||nTotalReg++}))
(cAlsQry)->(dbGoTop())

if !lSched 
	ProcRegua(nTotalReg)
endif

nTotalReg := 0

dbSelectArea("RJP")
dbSetOrder(6)

dbSelectArea("SRB")
dbSetOrder(1)

While !(cAlsQry)->(Eof())
	if !lSched 
		IncProc()
	endif

	If SRB->(dbSeek((cAlsQry)->(RA_FILIAL + RA_MAT)))
		While SRB->( !EoF() .And. RB_FILIAL + RB_MAT ==  (cAlsQry)->(RA_FILIAL + RA_MAT))
			cChave    := cEmpAnt + "|" + SRB->RB_FILIAL + "|" + SRB->RB_MAT + "|" + SRB->RB_COD

			If RJP->(dbSeek(xFilial("RJP") + cChave))
				SRB->(dbSkip())
				LOOP
			Else
				cTime   := Time()
				Aadd(aLog,{cChave,dDataBase,cTime,cUserId})
				nTotalReg++
				Begin Transaction
					fSetInforRJP(SRB->RB_FILIAL, SRB->RB_MAT, "SRB", cChave, "I",  dDataBase, cTime, cUserId)
					RJP->(dbSetOrder(6))//RJP_FILIAL+RJP_KEY
					If RJP->(dbSeek(xFilial("RJP")+cChave))
						RecLock("RJP",.F.)
						RJP->RJP_CGINIC := '1'
						RJP->(MsUnlock())
					Else
						DisarmTransaction()
					EndIf
				End Transaction
			EndIf
			SRB->(dbSkip())
		EndDo
	EndIf
	(cAlsQry)->(dbSkip())
EndDo

If nTotalReg == 0
	cMsg := STR0018//##"Não foram encontrados registros elegíveis para processamento no cadastro de dependentes. (SRB)"
else
	cMsg := STR0016+cValToChar(nTotalReg)+STR0019//##"Foram processados "##" registros do cadastro de dependentes (SRB)."
EndIf

(cAlsQry)->(dbCloseArea())


RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} LoadSQG

	Realiza a carga dos registros da SQG.

	@type  Static Function
	@author Emerson Grassi Rocha

	@since 21/03/2024
	@version 1.0
	@param cUserId, Character, Código do Usuário.
	@param cMsg , Character, Mensagem de processamento.
	@param aLog , Character, Array contendo log de processamento
	@param cFilIni, Character, Filial inicial.
	@param cFilFin, Character, Filial final.
	@param cPesIni, Character, Curriculo inicial.
	@param cPesFin, Character, Curriculo final.
	@param lSched, Logical, Se será processado em segundo plano

	/*/

Static Function LoadSQG(cUserId,cMsg,aLog,cFilIni,cFilFin,cPesIni,cPesFin,lSched)

Local aAreOld := GetArea()

Local cAlsQry   := GetNextAlias()
Local cTime     := ""
Local cChave    := ""

Local nTotalReg := 0

Default cUserId   := SubStr(cUsuario,7,15)
Default cMsg    := ""
Default aLog    := {}
Default cFilIni := ""
Default cFilFin := ""
Default cPesIni := ""
Default cPesFin := ""
Default lSched  := .F.

If !Empty(cFilIni)
	cFilIni := xFilial("SQG",cFilIni)
EndIf

BeginSQL Alias cAlsQry
	SELECT QG_FILIAL,QG_CURRIC,QG_DTNASC,QG_SEXO,QG_CIC
	FROM %Table:SQG% SQG
	WHERE QG_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SQG", cFilFin)%
	AND QG_CURRIC BETWEEN %Exp:cPesIni% AND %Exp:cPesFin%
	AND SQG.%NotDel%
EndSQL

(cAlsQry)->(dbEval({||nTotalReg++}))
(cAlsQry)->(dbGoTop())

if !lSched
	ProcRegua(nTotalReg)
endif

nTotalReg := 0

dbSelectArea("RJP")
dbSetOrder(6)

While !(cAlsQry)->(Eof())
	if !lSched
		IncProc()
	endif

	cChave    := cEmpAnt + "|" + (cAlsQry)->QG_FILIAL + "|" + (cAlsQry)->QG_CURRIC

	If RJP->(dbSeek(xFilial("RJP") + cChave)) .Or. !fBuscaMat((cAlsQry)->QG_CIC)
		(cAlsQry)->(dbSkip())
		LOOP
	Else
		cTime   := Time()
		Aadd(aLog,{cChave,dDataBase,cTime,cUserId})
		nTotalReg++
		Begin Transaction
			fSetInforRJP((cAlsQry)->QG_FILIAL, (cAlsQry)->QG_CURRIC, "SQG", cChave, "I",  dDataBase, cTime, cUserId)

			RJP->(dbSetOrder(6))//RJP_FILIAL+RJP_KEY
			If RJP->(dbSeek(xFilial("RJP")+cChave)) // Primeiro registro que encontrar do candidado
				RecLock("RJP",.F.)
				RJP->RJP_CGINIC := '1'
				RJP->(MsUnlock())

				//Valida campos da SQG gerando mensagem para que não seja enviado registros inconsistentes
				RJP->(DBSetOrder(7))
				If (RJP->(DBSeek(xFilial("RJP")+"SQG"+cChave)))

					While RJP->RJP_FILIAL== xFilial("RJP") .And. RJP->RJP_TAB == "SQG" .And. RJP->RJP_FIL == (cAlsQry)->QG_FILIAL;
						.And. AllTrim(RJP->RJP_KEY) == AllTrim(cChave)

						If RJP->RJP_OPER == "I" .And. RJP->RJP_DATA == dDataBase .And. RJP->RJP_HORA == cTime;
							.And. (Empty((cAlsQry)->QG_DTNASC) .Or. Empty((cAlsQry)->QG_SEXO))

							RecLock("RJP",.F.)
							RJP->RJP_RTN 	:= STR0065+": "+STR0064 		//'Inconsistencia'###'Os campos "Sexo" e "Data de Nascimento" devem estar preenchidos para que o registro seja enviado.'
							RJP->RJP_DTIN 	:= dDataBase 	//Grava data para nao tentar integrar com Quirons
							RJP->(MsUnlock())
							exit
						EndIf
						RJP->(dbSkip())
					EndDo
				EndIf
			Else
				DisarmTransaction()
			EndIf

		End Transaction
	EndIf
	(cAlsQry)->(dbSkip())
EndDo

If nTotalReg == 0
	cMsg := STR0020//##"Não foram encontrados registros elegíveis para processamento no cadastro de candidatos(SQG)."
else
	cMsg := STR0016+cValToChar(nTotalReg)+STR0021//##"Foram processados "##" registros do cadastro de candidatos(SQG)."
EndIf

(cAlsQry)->(dbCloseArea())

RestArea(aAreOld)

Return Nil


/*/{Protheus.doc} LoadSQ3

	Realiza a carga dos registros da SQ3.

	@type  Static Function
	@author brdwc0032

	@since 13/08/2020
	@version 12.1.27
	@param cUserId, Character, Código do Usuário.
	@param cMsg , Character, Mensagem de processamento.
	@param aLog , Character, Array contendo log de processamento
	@param cFilIni , Character, Filial inicial.
	@param cFilFin , Character, Filial final.
	@param lSched, Logical, Se será processado em segundo plano	
	/*/
Static Function LoadSQ3(cUserId, cMsg, aLog, cFilIni, cFilFin, cCrgIni, cCrgFin, lSched)

	Local aAreOld 	:= GetArea()
	Local cAlsQry   := GetNextAlias()
	Local nTotalReg := 0

	Default cUserId   := SubStr(cUsuario,7,15)
	Default cMsg    := ""
	Default aLog    := {}
	Default cFilIni := ""
	Default cFilFin := ""
	Default cCrgIni := ""
	Default cCrgFin := "ZZZZZ"
	Default lSched  := .F.

	If !Empty(cFilIni)
		cFilIni := xFilial("SQ3",cFilIni)
	EndIf

	dbSelectArea("SQ3")

	BeginSQL Alias cAlsQry
		SELECT Q3_FILIAL,Q3_CARGO, Q3_CC, SQ3.R_E_C_N_O_ AS RECNO
		FROM %Table:SQ3% SQ3
		WHERE Q3_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SQ3", cFilFin)%
		AND Q3_CARGO BETWEEN %Exp:cCrgIni% AND %Exp:cCrgFin%
		AND SQ3.%NotDel%
	EndSQL

	(cAlsQry)->(dbEval({||nTotalReg++}))
	(cAlsQry)->(dbGoTop())

	if !lSched
		ProcRegua(nTotalReg)
	endif

	nTotalReg := 0

	While !(cAlsQry)->(Eof())
		if !lSched
			IncProc()
		endif

		// Verifica se o registro está bloqueado para uso
		SQ3->(dbGoTo( (cAlsQry)->RECNO ))
		If !RegistroOk("SQ3", .F.)
			//nTotalReg--
			(cAlsQry)->(dbSkip())
			LOOP
		EndIf

		If FindFunction("fSQ3ToRJP")
			If fSQ3ToRJP("I")
				nTotalReg++
			EndIf
		EndIf

		(cAlsQry)->(dbSkip())
	EndDo

	If nTotalReg <= 0
		cMsg := STR0054//##"Não foram encontrados registros elegíveis para processamento no cadastro de cargos. (SQ3)"
	else
		cMsg := STR0016+cValToChar(nTotalReg)+STR0055//##"Foram processados "##" registros do cadastro de cargos (SQ3)."
	EndIf

	(cAlsQry)->(dbCloseArea())

	RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} LoadSQB
Realiza a carga dos registros da SQB.
@type  Static Function
@author brdwc0032
@since 13/08/2020
@version 12.1.27
@param cUserId, Character, Código do Usuário.
@param cMsg , Character, Mensagem de processamento.
@param aLog , Character, Array contendo log de processamento
@param cFilIni , Character, Filial inicial.
@param cFilFin , Character, Filial final.
@param lSched, Logical, Se será processado em segundo plano
/*/
Static Function LoadSQB(cUserId,cMsg,aLog,cFilIni,cFilFin,lSched)
	Local aAreOld := GetArea()
	Local cAlsQry   := GetNextAlias()
	Local nTotalReg := 0
	Default cUserId   := SubStr(cUsuario,7,15)
	Default cMsg    := ""
	Default aLog    := {}
	Default cFilIni := ""
	Default cFilFin := ""
	Default lSched  := .F.

	If !Empty(cFilIni)
		cFilIni := xFilial("SQB",cFilIni)
	EndIf

	dbSelectArea("SQB")

	BeginSQL Alias cAlsQry
		SELECT QB_FILIAL, QB_DEPTO, QB_CC, SQB.R_E_C_N_O_ AS RECNO
		FROM %Table:SQB% SQB
		WHERE QB_FILIAL BETWEEN %Exp:cFilIni% AND %Exp:xFilial("SQB", cFilFin)%
		AND SQB.%NotDel%
	EndSQL

	(cAlsQry)->(dbEval({||nTotalReg++}))
	(cAlsQry)->(dbGoTop())

	if !lSched
		ProcRegua(nTotalReg)
	endif

	nTotalReg := 0

	While !(cAlsQry)->(Eof())
		if !lSched
			IncProc()
		endif

		// Verifica se o registro está bloqueado para uso
		SQB->(dbGoTo( (cAlsQry)->RECNO ))
		If !RegistroOk("SQB", .F.)
			//nTotalReg--
			(cAlsQry)->(dbSkip())
			LOOP
		EndIf

		If FindFunction("fSQBToRJP")
			If fSQBToRJP("I")
				nTotalReg++
			EndIf
		EndIf

		(cAlsQry)->(dbSkip())
	EndDo

	If nTotalReg <= 0
		cMsg := STR0047//##"Não foram encontrados registros elegíveis para processamento no cadastro de departamentos. (SQB)"
	else
		cMsg := STR0016+cValToChar(nTotalReg)+STR0048//##"Foram processados "##" registros do cadastro de departamentos (SQB)."
	EndIf

	(cAlsQry)->(dbCloseArea())

	RestArea(aAreOld)

Return Nil

/*/{Protheus.doc} FPergunte
Perguntas da rotina
@type  Static Function
@author rafaelalmeida
@since 08/06/2020
@version 12.1.27
@param lView, logical, Determina se será exibida a janela de perguntas.
@param lEdit, logical, Determina o modo de edição de alguns parâmetros.
@return lRet, logical, Determina se o usuário confirmou ou cancelou a janela de perguntas.
/*/
Static Function FPergunte(cNomRot, lView, lEdit)

	Local aParambox	:= {}
	Local aRet 		:= {}
	Local lRet		:= .T.
	Local nX		:= 0

	Default cNomRot	:= "GPEM925"
	Default lView	:= .T.
	Default lEdit	:= .T.

	Private lWhen	:= lEdit

	aAdd( aParambox, {1, STR0035, CriaVar("RA_FILIAL", .F.), "@!", ".T.", "SM0",, 100, .F.})        //"Filial De: "
	aAdd( aParambox, {1, STR0036, CriaVar("RA_FILIAL", .F.), "@!", ".T.", "SM0",, 100, .F.})        //"Filial Até: "
	aAdd( aParamBox, {4, STR0022, .F., "", 90, "", .F.})                                            //"Cadastro de Funcionários"
	aAdd( aParamBox, {4, STR0062, .F., "", 90, "", .F.})			                                //"Transferências"
	aAdd( aParamBox, {4, STR0063, .F., "", 90, "", .F.})				                            //"Alterações Salariais"
	aAdd( aParamBox, {4, STR0025, .F., "", 90, "", .F.})                                            //"Cadastro de Dependentes"
	aAdd( aParambox, {1, STR0037, CriaVar("RA_MAT", .F.), "@!", ".T.", "SRA02A", ".T.", 100, .F.})  //"Matrícula De: "
	aAdd( aParambox, {1, STR0038, CriaVar("RA_MAT", .F.), "@!", ".T.", "SRA02A", ".T.", 100, .F.})  //"Matrícula Até: "
	aAdd( aParamBox, {4, STR0026, .F., "", 90, "", .F.})                                            //"Cadastro de Dependentes"
	aAdd( aParambox, {1, STR0039, CriaVar("QG_CURRIC", .F.), "@!", ".T.", "SQG", ".T.", 100, .F.}) //"Candidato De: "
	aAdd( aParambox, {1, STR0040, CriaVar("QG_CURRIC", .F.), "@!", ".T.", "SQG", ".T.", 100, .F.}) //"Candidato Até: "
	aAdd( aParamBox, {4, STR0049, .F., "", 90, "", .F.})                                            //"Cadastro de Departamentos"
	aAdd( aParambox, {1, STR0051, CriaVar("Q3_CARGO", .F.), "@!", ".T.", "SQ3", ".T.", 100, .F.})   //"Cargo De: "
	aAdd( aParambox, {1, STR0052, CriaVar("Q3_CARGO", .F.), "@!", ".T.", "SQ3", ".T.", 100, .F.})   //"Cargo Até: "
	aAdd( aParamBox, {4, STR0050, .F., "", 90, "", .F.})                                            //"Cadastro de Cargos"
	aAdd( aParamBox, {4, STR0041, .F., "", 90, "", .F.})                                            //"Log de Processamento
    aAdd( aParamBox, {4, STR0066, .F., "", 90, "", .F.})                                            //"Considera Demitidos

	//Carrega o array com os valores utilizados na última tela ou valores Default de cada campo.
	For nX := 1 To Len(aParamBox)
		aParamBox[nX][3] := ParamLoad(cNomRot, aParamBox, nX, aParamBox[nX][3])
	Next nX

	//Define se ira apresentar tela de perguntas
	If lView
		lRet := ParamBox(aParamBox, STR0027, aRet, {|| VldPerg()}, {}, .T., Nil, Nil, Nil, cNomRot, .F., .F.) //"Parâmetros"
	Else
		For nX := 1 To Len(aParamBox)
			Aadd(aRet, aParamBox[nX][3])
		Next nX
	EndIf

	If lRet
		//Carrega perguntas em variaveis usadas no programa
		If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
			For nX := 1 to Len(aParamBox)
				If aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "C"
					&("Mv_Par" + StrZero(nX, 2)) := aScan(aParamBox[nX][4], {|x| Alltrim(x) == aRet[nX]})
				ElseIf aParamBox[nX][1] == 2 .And. ValType(aRet[nX]) == "N"
					&("Mv_Par" + StrZero(nX, 2)) := aRet[nX]
				Else
					&("Mv_Par" + StrZero(nX, 2)) := aRet[nX]
				Endif
			Next nX
		EndIf

		If lEdit
			//Salva parametros
			ParamSave(cNomRot, aParamBox, "1")
		EndIf
	EndIf

Return(lRet)


/*/{Protheus.doc} nomeStaticFunction
Função de validação do preenchimento dos perguntes.
@type  Static Function
@author rafaelalmeida
@since 18/06/2020
@version 12.1.27
@return lRet, logic, Retorno lógico da validação
/*/
Static Function VldPerg()

	Local lRet := .T.

	//Integraçao SRA  ou SRB selecionada e (Matricula até) vazio.
	If (MV_PAR03 .Or. MV_PAR04 .Or. MV_PAR05 .Or. MV_PAR06) .And. Empty(MV_PAR08)
		lRet := .F.
		// "Você selecionou a integração de Funcionários, Dependentes, Transferências ou Histórico Salarial."
		// "Por favor preencha o campo de [Matricula até:] !"
		MsgStop(STR0042 + CRLF + STR0043)
	EndIf

	//Integraçao SQG selecionada e (Candidato até) vazio.
	If MV_PAR09 .And. Empty(MV_PAR11)
		lRet := .F.
		// "Você selecionou a integração de candidatos."
		// "Por favor preencha o campo de [Candidato até:] !"
		MsgStop(STR0044 + CRLF + STR0045)
	EndIf

Return lRet

/*/{Protheus.doc} GravaLog
Grava log de processamento
@type  Static Function
@author user
@since 09/06/2020
@version version
@param cLog, Character, Mensagem geral de processamento
@param aLogSra, Array, Log de Registros Gravados na SRA.
@param aLogSrb, Array, Log de Registros Gravados na SRB.
@param aLogSQG, Array, Log de Registros Gravados na SQG
@param aLogSqb, Array, Log de Registros Gravados na SQB
@param aLogSq3, Array, Log de Registros Gravados na SQ3
@param aLogSre, Array, Log de Registros Gravados na SRE
@param aLogSr7, Array, Log de Registros Gravados na SR7
@param lSched, Logical, Indica se é ou não por Schedule em segundo plano
/*/
Static Function GravaLog(aLogSra, aLogSrb, aLogSqg, aLogSqb, aLogSq3, aLogSre, aLogSr7, lSched)

Local aDados  := {}
Local aTitle  := {}

Local nTotalReg := 0
Local nXi       := 1

Default aLogSra := {}
Default aLogSrb := {}
Default aLogSqg := {}
Default aLogSqb := {}
Default lSched  := .F.

Aadd(aTitle, STR0029)//##Log de Processamento da Carga Inicial

Aadd(aDados, Padr(STR0030,30) +;//##Tabela
			 Padr(STR0031,40) +;//##Chave
			 Padr(STR0032,12) +;//##Data
			 Padr(STR0033,10) +;//##Hora
			 Padr(STR0034,20))//##Usuário*/

nTotalReg := Len(aLogSRA)
If nTotalReg > 0
	if !lSched
		ProcRegua(nTotalReg)
	endif

	For nXi := 1 To nTotalReg
		if !lSched
			IncProc()
		endif

		Aadd(aDados,Padr("SRA " + FWSX2UTIL():GETX2NAME("SRA"), 30) +;
			Padr(aLogSra[nXi][1], 40) +;
			Padr(DtoC(aLogSra[nXi][2]), 12) +;
			Padr(aLogSra[nXi][3],10) +;
			Padr(aLogSra[nXi][4],20))
	Next
EndIf

nTotalReg := Len(aLogSRB)
If nTotalReg > 0
	if !lSched
		ProcRegua(nTotalReg)
	endif

	For nXi := 1 To nTotalReg
		if !lSched
			IncProc()
		endif

		Aadd(aDados,Padr("SRB "+FWSX2UTIL():GETX2NAME("SRB"),30) +;
			Padr(aLogSRB[nXi][1],40) +;
			Padr(DtoC(aLogSRB[nXi][2]),12) +;
			Padr(aLogSRB[nXi][3],10) +;
			Padr(aLogSRB[nXi][4],20))
	Next
EndIf

nTotalReg := Len(aLogSQG)
If nTotalReg > 0
	if !lSched
		ProcRegua(nTotalReg)
	endif

	For nXi := 1 To nTotalReg
		if !lSched
			IncProc()
		endif

		Aadd(aDados,Padr("SQG "+FWSX2UTIL():GETX2NAME("SQG"),30) +;
			Padr(aLogSQG[nXi][1],40) +;
			Padr(DtoC(aLogSQG[nXi][2]),12) +;
			Padr(aLogSQG[nXi][3],10) +;
			Padr(aLogSQG[nXi][4],20))
	Next
EndIf

nTotalReg := Len(aLogSqb)
If nTotalReg > 0
	if !lSched
		ProcRegua(nTotalReg)
	endif

	For nXi := 1 To nTotalReg
		if !lSched
			IncProc()
		endif

		Aadd(aDados, Padr("SQB " + FWSX2UTIL():GETX2NAME("SQB"), 30) +;
			Padr(aLogSqb[nXi][1],40) +;
			Padr(DtoC(aLogSqb[nXi][2]),12) +;
			Padr(aLogSqb[nXi][3],10) +;
			Padr(aLogSqb[nXi][4],20))
	Next
EndIf

nTotalReg := Len(aLogSq3)
If nTotalReg > 0
	if !lSched
		ProcRegua(nTotalReg)
	endif

	For nXi := 1 To nTotalReg
		if !lSched
			IncProc()
		endif

		Aadd(aDados,Padr("SQ3 "+FWSX2UTIL():GETX2NAME("SQ3"),30) +;
			Padr(aLogSq3[nXi][1],40) +;
			Padr(DtoC(aLogSq3[nXi][2]),12) +;
			Padr(aLogSq3[nXi][3],10) +;
			Padr(aLogSq3[nXi][4],20))
	Next
EndIf

nTotalReg := Len(aLogSre)
If nTotalReg > 0
	if !lSched
		ProcRegua(nTotalReg)
	endif

	For nXi := 1 To nTotalReg
		if !lSched
			IncProc()
		endif

		Aadd(aDados, Padr("SRE " + FWSX2UTIL():GETX2NAME("SRE"), 30) +;
			Padr(aLogSre[nXi][1], 40) +;
			Padr(DtoC(aLogSre[nXi][2]), 12) +;
			Padr(aLogSre[nXi][3], 10) +;
			Padr(aLogSre[nXi][4], 20))
	Next
EndIf

nTotalReg := Len(aLogSr7)
If nTotalReg > 0
	if !lSched
		ProcRegua(nTotalReg)
	endif

	For nXi := 1 To nTotalReg
		if !lSched
			IncProc()
		endif

		Aadd(aDados, Padr("SR7 " + FWSX2UTIL():GETX2NAME("SR7"), 30) +;
			Padr(aLogSr7[nXi][1], 40) +;
			Padr(DtoC(aLogSr7[nXi][2]), 12) +;
			Padr(aLogSr7[nXi][3], 10) +;
			Padr(aLogSr7[nXi][4], 20))
	Next
EndIf

If (lSched)
	GPESmartViewUtils():CreateLog({aDados}, aTitle, "GPEM925")
Else
	fMakeLog( {aDados}, aTitle, "GPEM925", NIL, FunName())
EndIf

Return Nil

/*/{Protheus.doc} fBuscaMat
Verifica se existe funcionario ativo
@author Emerson Grassi Rocha
@since 14/08/2024
@version P12
@param cChave
/*/
Static Function fBuscaMat(cChave)
Local aAreaSra := SRA ->(GetArea())
Local lRet := .T.

DbSelectArea ("SRA")
DbSetorder (20)

If SRA->(dbSeek( cChave ) )
	While SRA->(!Eof()) .And. cChave == SRA->RA_CIC
		If SRA->RA_SITFOLH != "D"
			lRet := .F.
            exit
		EndIf
		SRA->(Dbskip())
	EndDo
EndIf

RestArea(aAreaSra)
Return lRet

Static Function ExecSched(lSched as Logical)

	Local nTotal    := 0
	Local cFilIni   := ""
	Local cFilFin   := ""
	Local cMatIni   := ""
	Local cMatFin   := ""
	Local cPesIni   := ""
	Local cPesFin   := ""
	Local cCrgIni   := ""
	Local cCrgFin   := ""
	Local lProcSRA  := .F.
	Local lProcSRE  := .F.
	Local lProcSR7  := .F.
	Local lProcSRB  := .F.
	Local lProcSQG  := .F.
	Local lProcSQB  := .F.
	Local lProcSQ3  := .F.
	Local lLog      := .F.
	Local aLogSra   := {}
	Local aLogSre   := {}
	Local aLogSr7   := {}
	Local aLogSrb   := {}
	Local aLogSqg   := {}
	Local aLogSqb   := {}
	Local aLogSq3   := {}
	Local cMsg      := ""
	Local aLog      := {}

	cFilIni     := MV_PAR01
	cFilFin     := MV_PAR02
	lProcSRA    := MV_PAR03 
	lProcSRE    := MV_PAR04 
	lProcSR7    := MV_PAR05 
	lProcSRB    := MV_PAR06 
	cMatIni     := MV_PAR07
	cMatFin     := MV_PAR08
	lProcSQG    := MV_PAR09 
	cPesIni     := MV_PAR10
	cPesFin     := MV_PAR11
	lProcSQB    := MV_PAR12 
	cCrgIni     := MV_PAR13
	cCrgFin     := MV_PAR14
	lProcSQ3    := MV_PAR15 
	lLog        := MV_PAR16 
    lIncDem     := MV_PAR17 
	cUserId     := MV_PAR18

	If lProcSRA
		nTotal ++
	Endif

	If lProcSRE
		nTotal ++
	Endif

	If lProcSR7
		nTotal ++
	Endif

	If lProcSRB
		nTotal ++
	Endif

	If lProcSQG
		nTotal ++
	Endif

	If lProcSQB
		nTotal ++
	Endif

	If lProcSQ3
		nTotal ++
	Endif

	// Define o tamanho da régua de processamento
	ProcRegua(nTotal)

	If lProcSRA	
		LoadSRA(cUserId,@cMsg,@aLogSra,cFilIni,cFilFin,cMatIni,cMatFin,lSched)
		IncProc()
		AAdd(aLog, cMsg + CRLF) 
	EndIf

	If lProcSRE
		LoadSRE(cUserId, @cMsg, @aLogSre, cFilIni, cFilFin, cMatIni, cMatFin,lSched)
		IncProc()
		AAdd(aLog, cMsg + CRLF) 
	EndIf

	If lProcSR7
		LoadSR7(cUserId, @cMsg, @aLogSr7, cFilIni, cFilFin, cMatIni, cMatFin,lSched)
		IncProc()
		AAdd(aLog, cMsg + CRLF) 
	EndIf

	If lProcSRB
		LoadSRB(cUserId,@cMsg,@aLogSrb,cFilIni,cFilFin,cMatIni,cMatFin,lSched)
		IncProc()
		AAdd(aLog, cMsg + CRLF) 
	EndIf

	If lProcSQG
		LoadSQG(cUserId,@cMsg,@aLogSQG,cFilIni,cFilFin,cPesIni,cPesFin,lSched)
		IncProc()
		AAdd(aLog, cMsg + CRLF) 
	EndIf

	If lProcSQB
		LoadSQB(cUserId,@cMsg,@aLogSqb,cFilIni,cFilFin,lSched)
		IncProc()
		AAdd(aLog, cMsg + CRLF) 
	EndIf

	If lProcSQ3
		LoadSQ3(cUserId,@cMsg,@aLogSq3,cFilIni,cFilFin, cCrgIni,cCrgFin,lSched)
		IncProc()
		AAdd(aLog, cMsg + CRLF) 
	EndIf

	If lProcSRA .Or. lProcSRB .Or. lProcSQG .Or. lProcSQB .Or. lProcSQ3 .or. lLog .Or. lProcSRE .Or. lProcSR7
		If lLog .And. (!Empty(aLogSRA) .Or. !Empty(aLogSRB) .Or. !Empty(aLogSQG) .Or. !Empty(aLogSqb) .Or. !Empty(aLogSq3) .Or. !Empty(aLogSRE) .Or. !Empty(aLogSR7))
			GravaLog(aLogSRA,aLogSRB,aLogSQG,aLogSqb,aLogSq3,aLogSRE,aLogSR7,lSched)
		EndIf

		GPESmartViewUtils():CreateLog({aLog}, {{STR0012}}, "GPEM925_Fim") //##"Fim do Processamento da Carga Inicial"
	Else
		// "Você marcou como não em todos os parâmetros!"
		// "Nenhum dado será processado!"
		AAdd(aLog, STR0013 + CRLF + STR0014) 
		GPESmartViewUtils():CreateLog({aLog}, {{STR0012}}, "GPEM925_Fim") //##"Fim do Processamento da Carga Inicial"
	EndIf

Return Nil

/*/{Protheus.doc} SchedDef
    Definições de agendamento do Schedule.
    @type Function
    @version 12.1.2410
    @author karina.alves
    @since 02/04/2025
    @return Array, Definições do agendamento
/*/
Static Function SchedDef() As Array
    // Declaração das variáveis locais
    Local aParam As Array

    // Inicialização das variáveis
    aParam := {}

    // Montagem da estrutura do vetor de retorno
    AAdd(aParam, "P")      // Tipo do agendamento: "P" = Processo | "R" = Relatório
    AAdd(aParam, "GPEM925A") // Pergunte (SX1) (usar "PARAMDEF" caso não tenha conjunto de perguntas)
    AAdd(aParam, "")       // Alias principal (exclusivo para relatórios)
    AAdd(aParam, {})       // Vetor de ordenação (exclusivo para relatórios)
    AAdd(aParam, "")       // Título (exclusivo para relatórios)
Return aParam

