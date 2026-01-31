#INCLUDE "PLSA627.CH"
#include "PROTHEUS.CH"
#include "PLSMGER2.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PL627PROJ
Gera o faturamento em JOB...
@author  PLS TEAM
@version P12
/*/
Function PL627PROJ(nOpc, _nH,oSayJob, lAuto, lPessoaF,aItens,lSchedule)
	Local jConta      := 0
	Local iConta      := 0
	Local lRet	      := .f.
	Default aItens    := If( !lPessoaF, Array(1,15), )
	Default lSchedule := .F.
	Default lAuto     := .F.

	lSchedule:= .F.

	If FindFunction("GetParAuto") .And. lAuto

		aCodLan := PL627LANTB()

		aRetAuto := GetParAuto("PLS627JOBTestCase")
		M->BDC_ANOINI := aRetAuto[1]
		M->BDC_MESINI := aRetAuto[2]
		M->BDC_ANOFIM := aRetAuto[3]
		M->BDC_MESFIM := aRetAuto[4]
		M->BDC_EXPFIF := aRetAuto[5]
		M->BDC_CODOPE := aRetAuto[6]
		M->BDC_TIPO := aRetAuto[7]
		M->BDC_INTERC := aRetAuto[8]
		M->BDC_HORAF	:= Time()
		M->BDC_HORA	:= Time()
		M->BDC_GRPCOB	:= " "
		M->BDC_LOTREN := " "
		M->BDC_CONGER	:= 0
		M->BDC_CONCRI	:= 0
		M->BDC_VALOR	:= 392
		M->BDC_VENINI	:= 1
		M->BDC_VENFIM	:= 31
		M->BDC_VENCTO	:= 1
		M->BDC_MODPAG	:= aRetAuto[26] //"3"
		M->BDC_AGLUTI	:= "1"
		M->BDC_CARIMP	:= "0"
		M->BDC_DTEMIS := dDataBase
		M->BDC_FATGR	:= "0"
		M->BDC_REEMB	:= "2"
		M->BDC_DTPREE	:=	Stod(" ")
		M->BDC_CONSAD	:= " "
		M->BDC_USUOPE := PLSRtCdUsr()

		If BDC->(FieldPos('BDC_RATIMP')) > 0 .and. Len(aRetAuto) > 26
			M->BDC_RATIMP :=aRetAuto[27]
		Endif

		aAdd(aRetAuto, aRetAuto[6] + cValToChar(M->BDC_NUMERO) ) // BM1_PLNUCO

	EndIf

	M->BDC_NUMERO := PLSA625Num()
	M->BDC_DATGER := dDataBase

	PLUPTENC("BDC",nOpc)

	nRegBDC := BDC->( Recno() )
	// Primeiro Verifico se o periodo esta correto
	If M->BDC_ANOINI+M->BDC_MESINI <= M->BDC_ANOFIM+M->BDC_MESFIM

		// Se o periodo estiver no mesmo ano
		If M->BDC_ANOINI == M->BDC_ANOFIM

			// O mes inicial tem que ser menor que o final
			If M->BDC_MESINI <= M->BDC_MESFIM

				For IConta := Val(M->BDC_MESINI) To Val(M->BDC_MESFIM)

					lRet := PLS627JOB(	M->BDC_NUMERO,M->BDC_ANOINI,StrZero(IConta,2),M->BDC_EXPFIF,M->BDC_CODOPE,Iif( lAuto, IIf ( lPessoaF, M->BDC_EXPFIF, aItens ) , If(M->BDC_TIPO == "1" .And. !lSchedule , oBrwBDW:aCols,aItens) ), ;	// Matriz com filtro
					Iif(M->BDC_INTERC=='1',.T.,.F.),M->BDC_TIPO,nOpc,lAuto,oSayJob)
				Next
			EndIf

			// Se forem anos diferentes
		ElseIf M->BDC_ANOINI < M->BDC_ANOFIM

			For JConta := Val(M->BDC_ANOINI) to Val(M->BDC_ANOFIM)

				If (JConta < Val(M->BDC_ANOFIM))

					If (JConta == Val(M->BDC_ANOINI))
						For IConta := Val(M->BDC_MESINI) To 12

							lRet := PLS627JOB(	M->BDC_NUMERO,StrZero(JConta,4),Strzero(IConta,2),M->BDC_EXPFIF,M->BDC_CODOPE,If(M->BDC_TIPO = "1" .And. !lSchedule , oBrwBDW:aCols,aItens),;	// Matriz com filtro
							Iif(M->BDC_INTERC=='1',.T.,.F.),M->BDC_TIPO,,,oSayJob)

						Next

					Else
						For IConta := 1  to 12

							lRet := PLS627JOB(	M->BDC_NUMERO,StrZero(JConta,4),Strzero(IConta,2),M->BDC_EXPFIF,M->BDC_CODOPE,If(M->BDC_TIPO = "1" .And. !lSchedule , oBrwBDW:aCols,),;	// Matriz com filtro
							Iif(M->BDC_INTERC=='1',.T.,.F.),M->BDC_TIPO,,,oSayJob)
						Next
					EndIf

					// Caso o ano que esta sendo processados seja o ultimo percorro do mes 1 ate o mes final
				ElseIf (JConta == vAL(M->BDC_ANOFIM))

					For IConta:= 1 To Val(M->BDC_MESFIM)

						lRet := PLS627JOB(M->BDC_NUMERO,StrZero(JConta,4),Strzero(IConta,2),M->BDC_EXPFIF,M->BDC_CODOPE,If(M->BDC_TIPO = "1" .And. !lSchedule , oBrwBDW:aCols,),;
							Iif(M->BDC_INTERC=='1',.T.,.F.),M->BDC_TIPO,,,oSayJob)

					Next
				EndIf
			Next
		EndIf

		// Ponto de entrada no fim da rotina...
		If ExistBlock("PL627FIM")
			ExecBlock("PL627FIM",.F.,.F.)
			PLSLOGFAT("PL627FIM",1,.F.)
		EndIf
	EndIf

	// Grava hora final do processamento do lote...
	BDC->( dbGoto(nRegBDC) )
	BDC->( Reclock("BDC", .F.) )
	BDC->BDC_HORAF := Time()
	BDC->( MsUnlock() )
	BDC->( dbCommitall() )

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS627JOB
@author  José Paulo de Azevedo
@version P11
@Função que inicia o JOB do lote de cobrança
@since   16/01/2024
/*/
//-------------------------------------------------------------------
Function PLS627JOB(	cNumCob,cAnoIni,cMesIni,cFilBA3,cOperadora, aItens,lInterC, cTipo, nOpc, lAuto,oSayJob)
	Local nX		   := 0
	Local nI		   := 0
	Local nThreads     := 0
	Local nQtdFam      := 0
	Local nTamAux      := 0
	Local cAliBase	   := getNextAlias()
	Local cNomThr      := allTrim(cValToChar(THREADID()))+Time()
	Local lSql         := Alltrim(Upper(TCGetDb())) == "MSSQL"
	Local cSqlName 	   := ""
	Local cSql         := ""
	Local cSqlAux      := ""
	Local aPrmt        := {}
	Local aColumns     := {}
	Local aAux         := {}
	Local aFami        := {}
	Local aItAux       := {}
	Local cOtrBcos     := IIF(!lSql,"TBLOT"+allTrim(cValToChar(THREADID())),"")
	Local lLock        := .T.
	private oTmpTable  := nil
	Default lAuto      := .F.
	Default cOperadora := ""
	Default cCodEmp    := ""
	Default cNumCob    := ""
	Default cAnoIni    := ""
	Default cMesIni    := ""
	Default cFiltro    := ""
	Default aMatFil    := {}
	Default lInterc    := .F.
	Default cTipo      := "1"
	Default oSayJob    := nil

	//trato quando For excluida uma linha da tabela BDK
	If cTipo == "1" .And. Len(aItens)>0 .And. !Empty(aItens[1,2])

		For nX:=1  To Len(aItens)
			If !aItens[nX,Len(aItens[nX])]
				AADD(aItAux,aItens[nx])
			EndIf
		Next nX

		If Len(aItAux) == 0
			Return(.T.) //se For informado dados no grid inferior da cobrança e deletado todos os itens não devo gerar lote.
		Else
			aItens:= aItAux
		EndIf

	EndIf

	//carrego alguns parâmetros para utilizar posteriormente
	aPrmt:={cNumCob,cAnoIni,cMesIni,cFilBA3,cOperadora,aItens,M->BDC_INTERC,cTipo,nOpc,lAuto,M->BDC_MODPAG,M->BDC_DTEMIS,M->BDC_RATIMP, M->BDC_AGLUTI,M->BDC_VENCTO}

	//Função que cria uma tabela temporária com as famílias que serão processadas
	fCriaBase(cAliBase,@oTmpTable,cTipo,@cSql,@cSqlAux,@aColumns,aItens,aPrmt[10])

	//agora insiro as famílias que serão processadas na tabela temporária criada anteriormente
	A627Itjob(oTmpTable,cTipo,cFilBA3,aItens,.f.,cSql,cSqlAux,aPrmt[10])

	//Marco as Threads com os flags na tabela temporária
	PLSDsBen(@nThreads,@nQtdFam)

	If 	nQtdFam == 0
		oTmpTable:Delete()
		freeObj(oTmpTable)
		oTmpTable := nil
		Return(.F.)
	EndIf

	PlsAprMsg("1",nQtdFam,aPrmt[10],,@oSayJob)

	//Para Automação
	PlsAprMsg()

	IIf (!lSql,TcSqlEXEC("DROP TABLE "+cOtrBcos+""),"")
	IIf (!lSql,nRet:=TcSqlEXEC(" CREATE TABLE "+cOtrBcos+" AS SELECT * FROM " + oTmpTable:getrealName()), nRet:= -1)
	IIf (nRet >= 0,TcSqlEXEC("COMMIT"),"")
	IIf (!lSql,cSqlName := cOtrBcos,cSqlName:= oTmpTable:getrealName())

	//Aqui inicio os Jobs. Cada nThread corresponde a um Flag marcado na tabela temporária
	For nX := 1 to nThreads
		startJob("PLPROCLTCOB",GetEnvServer(),.F., cEmpAnt, cFilAnt,strzero(nX,2), cSqlName, nThreads,cTipo,aPrmt,cNomThr)
	Next nX

	aThreads := GetUserInfoArray()

	//Aqui é o controle. Enquanto houver registro na tabela temporária com o OK em branco significa que não posso prosseguir. Aguardo até q todos OK estejam preenchidos.
	While nQtdFam <> 0

		cSql := "SELECT COUNT(OK) QTD FROM " + cSqlName + " WHERE OK = ' ' "
		nQtdFam := MPSysExecScalar(cSql, "QTD")

		If nQtdFam <> 0
			PlsAprMsg("2",nQtdFam,aPrmt[10],,@oSayJob)
			sleep(1000)
		Else
			PlsAprMsg("3",,aPrmt[10],,@oSayJob)
			EXIT
		EndIf

	EndDo

	IIf (!lSql,nRet:=TcSqlEXEC("DROP TABLE "+cOtrBcos+""),nRet:= -1)
	IIf (nRet >= 0,TcSqlEXEC("COMMIT"),"")

	While lLock
		IIf(!( GlbLock() ),Sleep(5),lLock:=.F.)
	End While

	//Pego o aAux (que é uma variável global) contendo os dados de todas as threads processadas.
	GetGlbVars("JB"+cNomThr+"",aAux)

	//Destravo a transação
	GlbUnlock()

	//Limpo a memória
	ClearGlbValue("JB"+cNomThr+"")

	(cAliBase)->(dbclosearea())

	PlsAprMsg("4",,aPrmt[10],,@oSayJob)

	//Fecho e finalizo a tabela temporária.
	oTmpTable:Delete()
	freeObj(oTmpTable)
	oTmpTable := nil

	nTamAux:= Len(aAux)

	//Trato o array com diversas famílias para gerar títulos posteriormente
	For nX:=1 To nTamAux

		For nI:=1 To Len(aAux[nX])
			AADD(aFami,{aAux[nX,nI,1],aAux[nX,nI,2],aAux[nX,nI,3]})
		Next

	Next

	If Len(aFami)>0
		ProcesTit(aFami,aPrmt,oSayJob)
	EndIf

Return (.t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} A627Itjob
@author José Paulo
@since  05/01/2024
@Carrego os campos ou rodo a query principal do lote de cobrnça. O sistema pode passar aqui 2 x. Primeira vez para pegar os campos da query para montar
@o temporário. Segunda vez: efetivamente para rodar a query e adicionar os dados em um temporário.
@version P12
/*/
//-------------------------------------------------------------------
function A627Itjob(oTmpTable,cTipo,cFilBA3,aItens,lSoCmps,cSql,cSqlAux,lAuto)
	Local nBDW_CODEMP := Iif( lAuto, Val(aRetAuto[9]),  oBrwBDW:PLRETPOS("BDW_CODEMP"))
	Local nBDW_CONEMP := Iif( lAuto, Val(aRetAuto[10]), oBrwBDW:PLRETPOS("BDW_CONEMP"))
	Local nBDW_VERCON := Iif( lAuto, Val(aRetAuto[11]), oBrwBDW:PLRETPOS("BDW_VERCON"))
	Local nBDW_SUBCON := Iif( lAuto, Val(aRetAuto[12]), oBrwBDW:PLRETPOS("BDW_SUBCON"))
	Local nBDW_VERSUB := Iif( lAuto, Val(aRetAuto[13]), oBrwBDW:PLRETPOS("BDW_VERSUB"))
	Local nBDWCODEMF  := Iif( lAuto, Val(aRetAuto[14]), oBrwBDW:PLRETPOS("BDW_CODEMF"))
	Local nBDWCONEMF  := Iif( lAuto, Val(aRetAuto[15]), oBrwBDW:PLRETPOS("BDW_CONEMF"))
	Local nBDWVERCOF  := Iif( lAuto, Val(aRetAuto[16]), oBrwBDW:PLRETPOS("BDW_VERCOF"))
	Local nBDWSUBCOF  := Iif( lAuto, Val(aRetAuto[17]), oBrwBDW:PLRETPOS("BDW_SUBCOF"))
	Local nBDWVERSUF  := Iif( lAuto, Val(aRetAuto[18]), oBrwBDW:PLRETPOS("BDW_VERSUF"))
	Local lPLS627QR   := ExistBlock("PLS627QR")
	Local nLItens     := 0 
	Local nPosFim     := 0
	Local  nItens     := 1
	Default cTipo     := ""
	Default cFilBA3   := ""
	Default aItens	  := { {} }
	Default lSoCmps   := .F.

	nLItens := Len(aItens)

	cSql := "SELECT BA3_CODINT, BA3_TIPOUS, BA3_CODCLI, BA3_LOJA, "
	cSql += "BA3_COBNIV, BA3_VENCTO, BA3_CODFOR, BA3_LOJFOR, BA3_CODEMP, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, "
	cSql += "BA3_VERSUB, BA3_MATRIC, BA3_CODPLA, BA3_VERSAO, BA3_NATURE, BA3_DATBLO, "
	If BA3->( FieldPos("BA3_CONDPA") ) > 0
		cSql += "BA3_CONDPA, "
	EndIf
	If BA3->(Fieldpos("BA3_TIPPAG")) > 0 .AND. BA3->( Fieldpos("BA3_PORTAD") ) > 0 .and. BA3->(Fieldpos("BA3_AGEDEP")) > 0 .AND. BA3->( Fieldpos("BA3_CTACOR") ) > 0 .and.;
			BA3->(Fieldpos("BA3_BCOCLI")) > 0 .AND. BA3->( Fieldpos("BA3_AGECLI") ) > 0 .and. BA3->(Fieldpos("BA3_CTACLI")) > 0

		cSql += "BA3_TIPPAG, BA3_PORTAD, BA3_AGEDEP, BA3_CTACOR, BA3_BCOCLI, BA3_AGECLI, BA3_CTACLI, "
	EndIf

	cSql += "BG9_LOJA, BG9_VENCTO, BG9_CODFOR, BG9_LOJFOR, BG9_NATURE, BG9_TIPO  ,BG9_CODCLI, "
	If BG9->( FieldPos("BG9_CONDPA") ) > 0
		cSql += "BG9_CONDPA, "
	EndIf
	If BG9->(Fieldpos("BG9_TIPPAG")) > 0 .AND. BG9->( Fieldpos("BG9_PORTAD") ) > 0 .and. BG9->(Fieldpos("BG9_AGEDEP")) > 0 .AND. BG9->( Fieldpos("BG9_CTACOR") ) > 0 .and.;
			BG9->(Fieldpos("BG9_BCOCLI")) > 0 .AND. BG9->( Fieldpos("BG9_AGECLI") ) > 0 .and. BG9->(Fieldpos("BG9_CTACLI")) > 0
		cSql += "BG9_TIPPAG, BG9_PORTAD, BG9_AGEDEP, BG9_CTACOR, BG9_BCOCLI, BG9_AGECLI, BG9_CTACLI, "
	EndIf

	If lSoCmps //quando igual a .t. indica que somente este pegando os campos da query para montar a tabela temporária.
		cSql += " BG9REC,  BA3REC  "
	Else
		cSql += RetSqlName("BG9")+".R_E_C_N_O_ BG9REC,  "+RetSqlName("BA3")+".R_E_C_N_O_ BA3REC  "
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Campo utilizados quando eh pessoa juridica... no bdc 1=juridica no ba3 1=fisica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTipo == '1'
		cSql += ",BT5_INTERC, BT5_TIPOIN, BT5_COBNIV, BT5_CODCLI, BT5_LOJA  , BT5_VENCTO, "
		cSql += "BT5_CODFOR , BT5_LOJFOR, BQC_COBNIV, BQC_CODCLI, BQC_LOJA  , BT5_NATURE, "
		cSql += "BQC_VENCTO , BQC_CODFOR, BQC_LOJFOR, BQC_GRATUI, BT6_CODPRO, BQC_NATURE, BT6_VERSAO, "

		If BT5->( FieldPos("BT5_CONDPA") ) > 0
			cSql += "BT5_CONDPA, "
		EndIf
		If BQC->( FieldPos("BQC_CONDPA") ) > 0
			cSql += " BQC_CONDPA, "
		EndIf
		If BT5->(Fieldpos("BT5_TIPPAG")) > 0 .AND. BT5->( Fieldpos("BT5_PORTAD") ) > 0 .and. BT5->(Fieldpos("BT5_AGEDEP")) > 0 .AND. BT5->( Fieldpos("BT5_CTACOR") ) > 0 .and.;
				BT5->(Fieldpos("BT5_BCOCLI")) > 0 .AND. BT5->( Fieldpos("BT5_AGECLI") ) > 0 .and. BT5->(Fieldpos("BT5_CTACLI")) > 0
			cSql += "BT5_TIPPAG, BT5_PORTAD, BT5_AGEDEP, BT5_CTACOR, BT5_BCOCLI, BT5_AGECLI, BT5_CTACLI, "
		EndIf

		If BQC->(Fieldpos("BQC_TIPPAG")) > 0 .AND.  BQC->( Fieldpos("BQC_PORTAD") ) > 0 .and. BQC->(Fieldpos("BQC_AGEDEP")) > 0 .AND. BQC->( Fieldpos("BQC_CTACOR") ) > 0 .and.;
				BQC->(Fieldpos("BQC_BCOCLI")) > 0 .AND. BQC->( Fieldpos("BQC_AGECLI") ) > 0 .and. BQC->(Fieldpos("BQC_CTACLI")) > 0
			cSql += "BQC_TIPPAG, BQC_PORTAD, BQC_AGEDEP, BQC_CTACOR, BQC_BCOCLI, BQC_AGECLI, BQC_CTACLI, "
		EndIf
		If BQC->( FieldPos("BQC_TPVCPP") ) > 0
			cSql += "BQC_TPVCPP, "
		EndIf
		If BQC->( FieldPos("BQC_VENCCO") ) > 0
			cSql += "BQC_VENCCO, "
		EndIf
		If BQC->( FieldPos("BQC_TPVCCO") ) > 0
			cSql += "BQC_TPVCCO, "
		EndIf
		If lSoCmps
			cSql += " BT5REC , BQCREC , BT6REC "
		Else
			cSql += RetSqlName("BT5")+".R_E_C_N_O_ BT5REC ,"
			cSql += RetSqlName("BQC")+".R_E_C_N_O_ BQCREC ,"
			cSql += RetSqlName("BT6")+".R_E_C_N_O_ BT6REC  "
		EndIf
	EndIf

	If lSoCmps //já insiro os campos de copntrole na criação de temporário
		cSql += " ,FLAG,OK "
	Else
		cSql += " ,'  ' FLAG,' ' OK "
	EndIf

	cSqlAx:= SubStr(Alltrim(cSql),7,Len(Alltrim(cSql)))

	cSql += "FROM "+RetSqlName("BA3")+", "+RetSqlName("BG9")+" "

	If cTipo == '1'
		cSql += ", "+RetSqlName("BT5")+", "+RetSqlName("BQC")+", "+RetSqlName("BT6")+" "
	EndIf

	cSql += "WHERE BA3_FILIAL = '" + xFilial("BA3") + "' "
	cSql += "AND BG9_FILIAL = '" + xFilial("BG9") + "' "

	If cTipo == '1'
		cSql += "AND BT5_FILIAL = '" + xFilial("BT5") + "' "
		cSql += "AND BQC_FILIAL = '" + xFilial("BQC") + "' "
		cSql += "AND BT6_FILIAL = '" + xFilial("BT6") + "' "
	EndIf

	cSql += "AND BA3_CODINT = BG9_CODINT "
	cSql += "AND BA3_CODEMP = BG9_CODIGO "

	// Filtro para pessoa juridica...

	If cTipo = '1'
		cSql += "AND BA3_CODINT = BT5_CODINT "
		cSql += "AND BA3_CODEMP = BT5_CODIGO "
		cSql += "AND BA3_CONEMP = BT5_NUMCON "
		cSql += "AND BA3_VERCON = BT5_VERSAO "

		cSql += "AND BA3_CODINT || BA3_CODEMP = BQC_CODIGO  "
		cSql += "AND BA3_CONEMP = BQC_NUMCON "
		cSql += "AND BA3_VERCON = BQC_VERCON "
		cSql += "AND BA3_SUBCON = BQC_SUBCON "
		cSql += "AND BA3_VERSUB = BQC_VERSUB "

		cSql += "AND BA3_CODINT = BT6_CODINT "
		cSql += "AND BA3_CODEMP = BT6_CODIGO "
		cSql += "AND BA3_CONEMP = BT6_NUMCON "
		cSql += "AND BA3_VERCON = BT6_VERCON "
		cSql += "AND BA3_SUBCON = BT6_SUBCON "
		cSql += "AND BA3_VERSUB = BT6_VERSUB "
		cSql += "AND BA3_CODPLA = BT6_CODPRO "
		cSql += "AND BA3_VERSAO = BT6_VERSAO "
		cSql += "AND "+RetSqlName("BT6")+".D_E_L_E_T_ = ' ' "
		cSql += "AND "+RetSqlName("BT5")+".D_E_L_E_T_ = ' ' "
		cSql += "AND "+RetSqlName("BQC")+".D_E_L_E_T_ = ' ' "
	EndIf

	// Trata lote de renovacao...

	If BDC->( FieldPos("BDC_LOTREN") ) > 0
		If !Empty(M->BDC_LOTREN)
			cSql += "AND EXISTS (SELECT * FROM "+RetSqlName("BED")+" "
			cSql += " WHERE BED_FILIAL = '"+xFilial("BED")+"' "
			cSql += "AND BA3_CODINT = BED_CODINT "
			cSql += "AND BA3_CODEMP = BED_CODEMP "
			cSql += "AND BA3_MATRIC = BED_MATRIC "
			cSql += "AND BED_CDIDEN = '"+M->BDC_LOTREN+"' "
			cSql += "AND "+RetSqlName("BED")+".D_E_L_E_T_ = ' ' )"
		EndIf
	EndIf

	cSql += "AND "+RetSqlName("BA3")+".D_E_L_E_T_ = ' ' "
	cSql += "AND "+RetSqlName("BG9")+".D_E_L_E_T_ = ' ' "

	If cTipo == '1'  .and. Iif(BDC->( FieldPos("BDC_LOTREN") ) > 0,Empty(M->BDC_LOTREN),.T.)
		cSql += " AND ("

		For nItens:= 1 To nLItens 

			cSql +="("

			If ! Empty(aItens[nItens][nBDWCODEMF])
				cSql += " BA3_CODEMP >= '" + aItens[nItens][nBDW_CODEMP] + "' AND BA3_CODEMP <= '" + aItens[nItens][nBDWCODEMF] + "' "

			ElseIf ! Empty(aItens[nItens][nBDW_CODEMP])
				cSql += " BA3_CODEMP = '" + aItens[nItens][nBDW_CODEMP] + "' "
			EndIf

			If ! Empty(aItens[nItens][nBDWCONEMF] + aItens[nItens][nBDWVERCOF])
				cSql += " AND (BA3_CONEMP >= '" + aItens[nItens][nBDW_CONEMP] + "' AND BA3_VERCON >= '" + aItens[nItens][nBDW_VERCON] + "') AND " +;
					"(BA3_CONEMP <= '" + aItens[nItens][nBDWCONEMF] + "' AND BA3_VERCON <= '" + aItens[nItens][nBDWVERCOF] + "') "

			ElseIf ! Empty(aItens[nItens][nBDW_CONEMP] + aItens[nItens][nBDW_VERCON])
				cSql += " AND BA3_CONEMP = '" + aItens[nItens][nBDW_CONEMP] + "' AND BA3_VERCON = '" + aItens[nItens][nBDW_VERCON] + "' "
			EndIf

			If ! Empty(aItens[nItens][nBDWSUBCOF] + aItens[nItens][nBDWVERSUF])
				cSql += " AND (BA3_SUBCON >= '" + aItens[nItens][nBDW_SUBCON] + "' AND BA3_VERSUB >= '" + aItens[nItens][nBDW_VERSUB] + "') AND " +;
					"(BA3_SUBCON <= '" + aItens[nItens][nBDWSUBCOF] + "' AND BA3_VERSUB <= '" + aItens[nItens][nBDWVERSUF] + "') "

			ElseIf ! Empty(aItens[nItens][nBDW_SUBCON] + aItens[nItens][nBDW_VERSUB])
				cSql += " AND BA3_SUBCON = '" + aItens[nItens][nBDW_SUBCON] + "' AND BA3_VERSUB = '" + aItens[nItens][nBDW_VERSUB] + "' "
			EndIf

			cSql +=")"

		Next nItens
		cSql += ")"

		cSql:= STRTRAN( cSql, "AND (())", "")
		cSql:= STRTRAN( cSql, ")(", ") OR (")


		cSql += "AND BA3_TIPOUS = '2' "
		cSql += "AND BA3_CODINT = '"+M->BDC_CODOPE+"' "


		If !Empty(M->BDC_GRPCOB)
			cSql += "AND BA3_GRPCOB = '" + M->BDC_GRPCOB + "' "
		EndIf

		If ! Empty(cFilBA3)
			cSql += " AND (" + PlsParSql(cFilBA3) + ") "
		EndIf

	ElseIf cTipo == '2' .And. Iif(BDC->( FieldPos("BDC_LOTREN") ) > 0, Empty(M->BDC_LOTREN), .T.)

		// Filtra exclusivo para pessoa fisica...

		If ! Empty(cFilBA3)
			cSql += " AND (" + PlsParSql(cFilBA3) + ") "
		EndIf

		cSql += "AND BA3_VENCTO >= " + AllTrim(Str(M->BDC_VENINI)) + " AND "
		cSql += "BA3_VENCTO <= " + AllTrim(Str(M->BDC_VENFIM)) + " AND "
		cSql += "BA3_TIPOUS = '1' "

		If  BDC->(FieldPos("BDC_CARIMP")) > 0
			If  ! Empty(M->BDC_CARIMP)
				cSql += " AND BA3_CARIMP = '" + M->BDC_CARIMP + "' "
			EndIf
		EndIf

		// Filtra por grupo de cobranca...

		If !Empty(M->BDC_GRPCOB)
			cSql += "AND BA3_GRPCOB = '"+M->BDC_GRPCOB+"' "
		EndIf
	EndIf

	If cTipo == '1'
		cSql += "ORDER BY BA3_FILIAL, BA3_CODINT, BA3_CODEMP, BA3_CONEMP, "
		cSql += "BA3_VERCON, BA3_SUBCON, BA3_VERSUB,BT6_CODPRO,BA3_MATRIC"
	Else
		cSql += "ORDER BY BA3_FILIAL,BA3_CODINT,BA3_CODEMP,BA3_MATRIC"
	EndIf

	If lPLS627QR
		cSql := ExecBlock("PLS627QR",.F.,.F.,{cSql})
		PLSLOGFAT("PLS627QR",1,.F.)
	EndIf

	cSql := StrTran(cSql,"DTOS(", "(" )
	cSql := StrTran(cSql,"DTOC(", "(" )
	cSql := StrTran(cSql,"CTOD(", "(" )

	cSql := ChangeQuery(Alltrim(cSql))

	If lSoCmps

		If lPLS627QR
			nPosFim:=(at("FROM",cSql))
			cSql:= SubStr(cSql,7,nPosFim-7)

		Else
			nPosFim:=(at("FROM",cSql))
			cSql:= SubStr(cSql,7,nPosFim-7)

		EndIf

	Else

		cSql := " Insert Into " +  oTmpTable:getrealName() + " ( "+ cSqlAux +") " + cSql
		PLSCOMMIT(cSql)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSDsBen
Distribuo as famílias nos JBS
@author José Paulo
@since  05/01/23
@ Esta função é utilizada para verificar quantos registros tem a query e também para marcar o campo FLAG com a Thead que irá processar o registro
@version P12
/*/
//-------------------------------------------------------------------
static function PLSDsBen(nThreads,nQtdFam)
	Local cSql 		:= ""
	Local nX		:= 0
	Local lPOSTGRES := SubStr(Alltrim(Upper(TCGetDb())),1,8) $ "POSTGRES"
	Local lSql      := Alltrim(Upper(TCGetDb())) $ "MSSQL"
	Default nQtdFam := 0

	cSql += " SELECT COUNT(BA3_CODINT) QTD FROM " +  oTmpTable:getrealName() +""
	cSql += " WHERE FLAG = ' ' "

	//De acordo com quantas famílias foram encontradas no temporário, seto a quantidade de threads disparadas.
	nQtdFam := MPSysExecScalar(cSql, "QTD")

	IIf (nQtdFam < 20,nThreads:= 1,nThreads:= 10)

	IIF(nQtdFam == 0,nThreads:=0,"")

	//definido a quantidade de threads, marcado o flag
	For nX := 1 to nThreads

		If nX = nThreads
			cSql := " UPDATE " + oTmpTable:getrealName() + " SET FLAG = '" + strzero(nX,2) + "'  WHERE FLAG = ' ' "
		Else
			// oracle e DB2 o tratamento é igual. Aqui preparo a query para oracle, DB2, SQL e PostGres
			cSql := IIF(lSql,"UPDATE TOP(" + cvaltochar(Int(nQtdFam/nThreads)) + ")" + oTmpTable:getrealName() + " SET FLAG = '" + strzero(nX,2) + "' WHERE FLAG = ' ' ",;
				" UPDATE " + oTmpTable:getrealName() + " SET FLAG = '" + strzero(nX,2) + "' WHERE FLAG = ' ' "+IIF(lPostGres," LIMIT  "," AND ROWNUM <= ")+cvaltochar(Int(nQtdFam/nThreads))+"")
		EndIf

		PLSCOMMIT(cSql)

	Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLPROCLTCOB
@author  José Paulo de Azevedo
@version P11
@since   16/01/2024
@Esta função cria um temporário com as famílias que vão ser processadas de acordo com a sua respectiva thread (FLAG).
/*/
//-------------------------------------------------------------------
Function PLPROCLTCOB(cEmpAnt, cFilAnt, cFlag ,cAliPri, nThreads, cTipo,aPrmt,cNomThr)
	Local cSql		    := ""
	Local cAlias	    := GetNextAlias()
	Default aPrmt       := {}
	Default aAux        := {}
	Default cTipo       := ""

	rpcSetType(3)
	rpcSetEnv( cEmpAnt, cFilAnt,,,GetEnvServer(),, )

	//monto o temporário que será processado por esta flag
	cSql := " SELECT * FROM " + cAliPri + " WHERE FLAG = '" + cFlag + "' AND OK = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	// coloco para processar os valores, as familias que fazem parte deste flag
	ProcesLot(cAlias,cTipo,aPrmt,cNomThr)

	//marco o OK na flag que já foi processada acima.
	TcSqlEXEC("UPDATE " + cAliPri + " SET OK = 'S' WHERE FLAG = '" + cFlag + "'" )

	rpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fCriaBase
Cria tabela temporaria da base a ser processada.
@author José Paulo de Azevedo
@since  10/01/2023
@version P12
@Função que adiciona campos ao temporário de acordo com a query principal da família
/*/
//-------------------------------------------------------------------
static function fCriaBase(cAlias,oTmpTable,cTipo,cSql,cSqlAux,aColumns,aItens,lAuto)
	Local nI          := 0
	Local nLnCmpos    := 0
	Default cSql      := ""
	Default cSqlAux   := ""
	Default aColumns  := ""
	Default aItens    := {{}}
	Default lAuto := .F.

	A627Itjob(,cTipo,,aItens,.t.,@cSql,cSqlAux,lAuto)
	cSqlAux:= cSql
	aCmps:= strtokarr (Alltrim(cSql), ",") //trato os campos que vieram da query de famílias. preciso disso porque talvez o PE tenha adicionado campos entre o select e o from
	nLnCmpos := LEN(aCmps)

	For nI:=1 To nLnCmpos
		If  "BT5REC" $ Alltrim(aCmps[nI])
			aAdd( aColumns,{"BT5REC","C",20,00 })
		ElseIf "BQCREC" $ Alltrim(aCmps[nI])
			aAdd( aColumns,{"BQCREC","C",20,00 })
		ElseIf "BT6REC" $ Alltrim(aCmps[nI])
			aAdd( aColumns,{"BT6REC","C",20,00 })
		ElseIf "BG9REC" $ Alltrim(aCmps[nI])
			aAdd( aColumns,{"BG9REC","C",20,00 })
		ElseIf "BA3REC" $ Alltrim(aCmps[nI])
			aAdd( aColumns,{"BA3REC","C",20,00 })
		ElseIf "FLAG" $ Alltrim(aCmps[nI])
			aAdd( aColumns,{"FLAG","C",02,00 })
		ElseIf "OK" $ Alltrim(aCmps[nI])
			aAdd( aColumns,{"OK","C",01,00 })
		Else
			aAdd( aColumns,{Alltrim(aCmps[nI]),"C",TamSX3(Alltrim(aCmps[nI]))[1],00 })
		EndIf
	Next

	oTmpTable := FWTemporaryTable():New(cAlias)
	oTmpTable:SetFields( aColumns )
	oTmpTable:Create()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcesLot
Função que roda as validações, cálculos e valores referente ao lote de cobrança
@author José Paulo de Azevedo
@since  10/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function ProcesLot(cAlias,cTipo,aPrmt,cNomThr)
	Local cCodInt	  := ""
	Local cCodEmp 	  := ""
	Local cConEmp 	  := ""
	Local cVerCon 	  := ""
	Local cSubCon 	  := ""
	Local cVerSub 	  := ""
	Local cMatric 	  := ""
	Local cTipReg	  := ""
	Local cInterc	  := "0"
	Local cCodPro 	  := ""
	Local cVerPro 	  := ""
	Local cDirFile	  := ""
	Local lFisica	  := (aPrmt[8] == '2' .or. empty(aPrmt[8]))
	Local lRegs		  := .F.
	Local aCliente    := {}
	Local aVet1		  := {}
	Local aRetAux	  := {}
	Local cAno        := aPrmt[2]
	Local cMes        := aPrmt[3]
	Local cNumCob     := aPrmt[1]
	Local aAux        := {}
	Local aAux1       := {}
	Local lLock       := .T.
	Default lInterC   := .F.
	Default aItens	  := { {} }
	Default lSchedule := .F.

	If lFisica
		aItens := { {} }
	EndIf

	BA1->( DbSetOrder(1) )
	BA3->( DbSetOrder(1) )

	While !(cAlias)->( Eof() )
		lRegs 	:= .T.
		cCodInt := (cAlias)->BA3_CODINT
		cCodEmp := (cAlias)->BA3_CODEMP
		nCont 	:= 0

		// While Empresa Processa familias...
		While !(cAlias)->( Eof() ) .And. (cAlias)->BA3_CODINT == cCodInt .And. (cAlias)->BA3_CODEMP == cCodemp
			BG9->(MsSeek(xFilial("BG9")+(cAlias)->BA3_CODINT+(cAlias)->BA3_CODEMP))

			// Pessoa Juridica
			If cTipo == '1'
				BQC->(MsSeek(xFilial("BQC")+(cAlias)->BA3_CODINT+(cAlias)->BA3_CODEMP+(cAlias)->BA3_CONEMP+(cAlias)->BA3_VERCON+(cAlias)->BA3_SUBCON+(cAlias)->BA3_VERSUB))
				BT5->(MsSeek(xFilial("BT5")+(cAlias)->BA3_CODINT+(cAlias)->BA3_CODEMP+(cAlias)->BA3_CONEMP+(cAlias)->BA3_VERCON))

				// Posiciona o BT5...
				cInterc := Iif(Empty((cAlias)->BT5_INTERC),'0',(cAlias)->BT5_INTERC)

				// Ou e intercambio ou nao... de acordo com a opcao definida no lote
				If cInterc <> aPrmt[7]
					(cAlias)->( dbSkip() )
					Loop
				EndIf

				// Liga variavel para indicar se eh intercambio ou nao...
				lInterc := ((cAlias)->BT5_INTERC=='1')

				// Atualiza variaveis...
				cConEmp := (cAlias)->BA3_CONEMP
				cVerCon := (cAlias)->BA3_VERCON
				cSubCon := (cAlias)->BA3_SUBCON
				cVerSub := (cAlias)->BA3_VERSUB
				cCodPro := (cAlias)->BT6_CODPRO
				cVerPro := (cAlias)->BT6_VERSAO
				cMatric := (cAlias)->BA3_MATRIC


				// While no mesmo produto para evitar pocisionamentos redundantes      |
				While !(cAlias)->( Eof() ) .And. cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPro+cVerPro ==;
						(cAlias)->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO )
					cDirFile := ""
					aVet1 := {}
					aVet1 := {	0,;						//01
					(cAlias)->BA3_CODINT,;	//02
					(cAlias)->BA3_CODEMP,;	//03
					(cAlias)->BA3_MATRIC,;	//04
					cAno,;					//05
					cMes,;					//06
					cConEmp,;				//07
					cVerCon,;				//08
					cSubCon,;				//09
					cVerSub,;				//10
					cCodPro,;				//11
					cVerPro,;				//12
					(cAlias)->BA3_TIPOUS,;  //13
					Val((cAlias)->BA3REC),;		//14
					Val((cAlias)->BG9REC),;		//15
					Val((cAlias)->BT5REC),;		//16
					Val((cAlias)->BQCREC),;		//17
					Val((cAlias)->BT6REC),;		//18
					cNumCob,;				//19
					lInterC,;				//20
					cTipReg,;				//21
					cDirFile}               //22

					BA3->(MsSeek(xFilial("BA3")+(cAlias)->BA3_CODINT+(cAlias)->BA3_CODEMP+(cAlias)->BA3_MATRIC+(cAlias)->BA3_CONEMP+(cAlias)->BA3_VERCON+(cAlias)->BA3_SUBCON+(cAlias)->BA3_VERSUB))

					aCliente := PLS770NIV((cAlias)->BA3_CODINT,(cAlias)->BA3_CODEMP,(cAlias)->BA3_MATRIC,If((cAlias)->BA3_TIPOUS=="1","F","J"),(cAlias)->BA3_CONEMP,(cAlias)->BA3_VERCON,(cAlias)->BA3_SUBCON,(cAlias)->BA3_VERSUB,1)

					aUsuarios := PLSLOADUSR(cCodInt,cCodEmp,(cAlias)->BA3_MATRIC,cAno,cMes,,)

					//Calcula valor de cobrança
					aRetAux := CalcFatGri(aVet1,.F.,aUsuarios,aCliente, aPrmt[11])

					// Monta o aAux1
					If Len(aRetAux) > 0
						AADD(aAux1,{(cAlias)->(BA3_CODINT+BA3_CODEMP),aRetAux,aCliente})
					EndIf

					(cAlias)->( dbSkip() )

				EndDo

			Else
				cDirFile := ""
				aVet1 := {}
				aVet1 := {	0,;						//01
				(cAlias)->BA3_CODINT,;	//02
				(cAlias)->BA3_CODEMP,;	//03
				(cAlias)->BA3_MATRIC,;	//04
				cAno,;					//05
				cMes,;					//06
				cConEmp,;				//07
				cVerCon,;				//08
				cSubCon,;				//09
				cVerSub,;				//10
				cCodPro,;				//11
				cVerPro,;				//12
				(cAlias)->BA3_TIPOUS,;	//13
				val((cAlias)->BA3REC),;		//14
				val((cAlias)->BG9REC),;		//15
				0,;						//16
				0,;						//17
				0,;						//18
				cNumCob,;				//19
				lInterC,;				//20
				cTipReg,;				//21
				cDirFile}               //22

				BA3->(MsSeek(xFilial("BA3")+(cAlias)->BA3_CODINT+(cAlias)->BA3_CODEMP+(cAlias)->BA3_MATRIC+(cAlias)->BA3_CONEMP+(cAlias)->BA3_VERCON+(cAlias)->BA3_SUBCON+(cAlias)->BA3_VERSUB))

				aCliente := PLS770NIV((cAlias)->BA3_CODINT,(cAlias)->BA3_CODEMP,(cAlias)->BA3_MATRIC,If((cAlias)->BA3_TIPOUS=="1","F","J"),(cAlias)->BA3_CONEMP,(cAlias)->BA3_VERCON,(cAlias)->BA3_SUBCON,(cAlias)->BA3_VERSUB,1)

				aUsuarios := PLSLOADUSR(cCodInt,cCodEmp,(cAlias)->BA3_MATRIC,cAno,cMes,,)

				//Calcula valor de cobrança
				aRetAux := CalcFatGri(aVet1,.F.,aUsuarios,aCliente, aPrmt[11])

				// Monta a aCobAbr
				If Len(aRetAux) > 0
					AADD(aAux1,{(cAlias)->(BA3_CODINT+BA3_CODEMP),aRetAux,aCliente})
				EndIf

				(cAlias)->( dbSkip() )

			EndIf

		EndDo

	EndDo

	(cAlias)->( DbCloseArea() )

	DbSelectArea("BA1")

	If Len(aAux1) > 0

		//Bloqueio esta transação que estou fazendo. Isso evita que diversas threads passem por aqui ao mesmo tempo, sobrepondo umas as outras.
		While lLock
			IIf(!( GlbLock() ),Sleep(5),lLock:=.F.)
		End While

		//puxo aAux que já está em minha memória global
		GetGlbVars("JB"+cNomThr+"",aAux)
		//Adiciono o aAux1 ao aAux que está em memória
		AADD(aAux,aAux1)
		//envio o novo aAux para memória novamente
		PutGlbVars("JB"+cNomThr+"",aAux)
		//Destravo
		GlbUnlock()

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcesLot
Função para montar o aCobAbr e organizar o aAux
@author José Paulo de Azevedo
@since  10/01/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function ProcesTit(aAux,aPrmt,oSayJob)
	Local nH          := 0
	Local nAux        :=  Len(aAux)
	Local aCobAbr	  := {}

	//o aAux chegou e está fora de ordem. Ordeno por empresa.Por isso usei essa chave (cAlias)->(BA3_CODINT+BA3_CODEMP) ao calcular família.
	aSort(aAux,,,{|x,y| x[1] < y[1]})

	PlsAprMsg("5",,aPrmt[10],,@oSayJob)

	//Monto o aCobAbr.Nessa função ele separa as empresas
	For nH:=1 To nAux
		PLSACOBRG( aAux[nH,2] ,@aCobAbr,@aAux[nH,3],.T.)
	Next nH

	//Começo a gerar os títulos
	GerTitAbr(aCobAbr, aPrmt,oSayJob)

	lInterc := (aPrmt[7]=='1')
	
	If !aPrmt[10]
		PLCABRES(aPrmt[5],aPrmt[1],lInterC,.T.,oSayJob,.T.)
	EndIf
Return

Static Function GerTitAbr(aCobAbr,aPrmt,oSayJob)
	Local nY		  := 0
	Local nI 		  := 0
	Local nTotLNF	  := 0
	Local nTotTit	  := 0
	Local nParFin	  := 0
	Local nL		  := 0
	Local nM		  := 0
	Local nN		  := 0
	Local bEmissao	  := {|| Iif(GetNewPar("MV_PLSNFBR","0")=="0", aPrmt[12], dDataBase ) }
	Local aRet 		  := {}
	Local aVet2		  := {}
	Local aVlrCob	  := {}
	Local aVlrAcu	  := {}
	Local aDataVenc   := {} // Callback var.
	Local cCliente	  := ""
	Local cLoja		  := ""
	Local cNivel	  := ""
	Local cDirFile	  := ""
	Local cFormPagto  := ""
	Local cMsgPrt     := ""
	Local dVenc 	  := ctod("")	// vencimento
	Local dVencCO 	  := ctod("")   // vencimento do custo operacional.
	Local lRatImpost  := aPrmt[13] == "1"
	Local cAno        := aPrmt[2]
	Local cMes        := aPrmt[3]
	Local cNumCob     := aPrmt[1]
	Local lPLS627OG   := ExistBlock("PLS627OG")
	Local cTotCob     := ""
	Local cCharNI     := ""
	Local cCharTit    := ""
	
	Default aCobAbr	  := {}

	If lPLS627OG
		aRetPto := ExecBlock("PLS627OG",.F.,.F.,{aCobAbr})
		aCobAbr := aRetPto[1]
		aRetPto := {}
		PLSLOGFAT("PLS627OG",1,.F.)
	EndIf

	nTotAbr := Len(aCobAbr)

	cTotCob := cValtoChar(nTotAbr)

	For nI := 1 to nTotAbr
		cMsgPrt:= Strzero(nI,6) + STR0269 + Alltrim(StrZero(nTotAbr,6)) + " => " + STR0280+ AllTrim(aCobAbr[nI,4,1])+" - "+AllTrim(aCobAbr[nI,4,3])
		PlsAprMsg("6",,aPrmt[10],cMsgPrt,@oSayJob)

		// Vai tratar a aCobAbr[6] e retornar a matriz pronta  quantidade de titulos
		aRet := PLSPRETIT(aCobAbr[nI],.F.,aPrmt[14],aPrmt[11],cAno,cMes)

		If ValType(aRet[4]) == "L"

			//Patronal diferenciado (Acordo ANS CApesesp)
			If aRet[4]

				For nL:= 1 to Len(aRet[1])
					nPos101:=1
					nPos188:=2
					If aRet[1,nL,1,3]="101"
						nPos101:=nL
					ElseIf aRet[1,nL,1,3]="186"
						nPos188:=nL
					EndIf
				Next

				For nL:= 1 to Len(aRet[1])
					If nPos101 = nL
						For nM:= 1 to Len(aRet[1,nL])
							If aRet[1,nL,nM,1]="1"
								For nN:=1 to Len(aRet[1,nPos188])
									If aRet[1,nPos188,nN,1]="1"  .and. 	aRet[1,nPos188,nN,7]= aRet[1,nL,nM,7]  .and. aRet[1,nL,nM,3] $ ("101,108")
										aRet[1,nL,nM,2]:= IIf (aRet[1,nPos101,nN,2] - aRet[1,nPos188,nN,23] <= 0 ,0,aRet[1,nPos101,nN,2] - aRet[1,nPos188,nN,23])
										aRet[1,nL,nM,23]:= aRet[1,nPos188,nN,2]
									Else
										If aRet[1,nPos188,nN,1]<>"1"
											aRet[1,nL,nM,23]:=0
											aRet[1,nL,nM,2] :=0
										EndIf
									EndIf
								Next nN
							Else
								If aRet[1,nL,nM,3] $ "186,187,188"
									aRet[1,nL,nM,23]:=0
									aRet[1,nL,nM,2] :=0
								EndIf
							EndIf
						Next
					EndIf
				Next

				For nL:= 1 to Len(aRet[1])
					If nPos188 = nL
						For nM:= 1 to Len(aRet[1,nL])
							If aRet[1,nL,nM,1]<>"1"
								aRet[1,nL,nM,2]:=0
								aRet[1,nL,nM,23]:= 0
							Else
								aRet[1,nL,nM,2]:=aRet[1,nL,nM,23]
							EndIf
						Next
					EndIf
				Next

			EndIf
		EndIf

		aVlrCob  := aClone(aRet[1])
		aVlrAcu  := aClone(aRet[2])
		nParFin	 := aRet[3]
		nTotTit	 := Len(aVlrCob)
		aRet 	 := {}
		cCharNI  := cValtoChar(nI)
		cCharTit := cValToChar(nTotTit)

		//Processo de geracao de titulo
		For nY:=1 To nTotTit
			cMsgPrt := STR0299 /*Cobrança*/ + cCharNI + STR0269 /*de*/ + cTotCob + STR0300 /*=> Gerando Título*/ + cValToChar(nY) + STR0269 /*de*/ + cCharTit //Cobrança ## de ## => Gerando Título ## de

			PlsAprMsg("6",,aPrmt[10],cMsgPrt,@oSayJob)

			//Total de linhas da nota
			nTotLNF  := Len(aVlrCob[nY])
			cDirFile := ""

			//Matriz de parametros para processamento
			cCliente := ""
			cLoja := ""
			cChaveNiv := ""
			cFormPagto := ""
			dVenc := ""
			dVencCO := ""
			cNivel := ""

			// Se tiver um subNivel de cobranca vou utilizar ele para gerar o titulo.
			If Len(aCobAbr[nI,4]) > 33 .and. Len(aCobAbr[nI,4,34]) > 0 .and. Len(aCobAbr[nI,4,34,1]) > 0

				// Cliente do sub nivel. Cobranca patrocinada
				If Len(aVlrCob[nY][1]) >= 66 .and. aVlrCob[nY][1][66] == "3"

					cCliente := aCobAbr[nI,4,34,1,1]
					cLoja := aCobAbr[nI,4,34,1,2]
					cChaveNiv := aCobAbr[nI,7,3] // Chave do nivel de cobranca do subcontrato.
					cFormPagto := aCobAbr[nI,4,34,1,21]

					// Calcula o vencimento baseado no sub nivel de cobranca.
					aDataVenc := PLS627VENC(aCobAbr[nI,4,34],cAno,cMes)

					dVenc := aDataVenc[1] // Vencimento pre-pagamento.
					dVencCO := aDataVenc[2] // Vencimento custo Operacional.
					cNivel := aCobAbr[nI,4,34,1,18]	// Nivel de cobranca.

				EndIf
			EndIf

			// Se não For cobranca patrocinada, realiza a cobranca convencional ou auto patrocinada.
			If Empty(cCliente) .and. Empty(cLoja) .And. Val(aCobAbr[nI,9]) != 0
				cCliente 	:= aCobAbr[nI,1]
				cLoja 		:= aCobAbr[nI,2]					// Cliente do sub nivel. Cobranca convencional ou auto patrocinada
				cChaveNiv	:= aCobAbr[nI,7,Val(aCobAbr[nI,9])]	// Chave do nivel de cobranca.

				dVencCO 	:= aCobAbr[nI,20]					// Vencimento custo Operacional.
				dVenc 		:= aCobAbr[nI,5]                	// Vencimento pre-pagamento.
				cNivel 		:= aCobAbr[nI,9]					// Nivel de cobranca.

			ElseIf Empty(dVenc) .and. Empty(dVencCO)
				dVencCO 	:= aCobAbr[nI,20]					// Vencimento custo Operacional.
				dVenc  		:= aCobAbr[nI,5]                	// Vencimento pre-pagamento.

			ElseIf Empty(dVenc)
				dVenc 		:= aCobAbr[nI,20]					// Vencimento custo Operacional.

			ElseIf Empty(dVencCO)
				dVencCO 	:= aCobAbr[nI,5]                	// Vencimento pre-pagamento.
			EndIf

			If Empty(cFormPagto)
				cFormPagto := aCobAbr[nI,13]
			EndIf

			// Detalhes dos itens.
			aVet2 := {}
			aVet2 := {1,;
				cChaveNiv,;
				aVlrCob[nY],;
				aVlrAcu,;
				dVencCO,;
				dVenc,;
				cMes,;
				cAno,;
				aPrmt[15],;
				cNumCob,;
				Eval(bEmissao),;
				aPrmt[14],;
				aPrmt[5],;
				cCliente,;
				cLoja,;
				aCobAbr[nI,4,15],;
				cNivel,;
				aClone(aCobAbr[nI,7]),;
				aCobAbr[nI,10],;
				aCobAbr[nI,11],;
				aCobAbr[nI,12],;
				cFormPagto,;
				aCobAbr[nI,14],;
				aCobAbr[nI,15],;
				aCobAbr[nI,16],;
				aCobAbr[nI,17],;
				aCobAbr[nI,18],;
				aCobAbr[nI,19],;
				aCobAbr[nI,22],;
				BDC->(Recno()),;
				aPrmt[7]=="1",;
				cDirFile,;
				nTotLNF,;
				IIf(nY<=nParFin,1,2),lRatImpost}

			If nTotLNF > 0
				PLSGERTIT(aVet2,.T.)
			EndIf
			aVlrAcu := {}
		Next nY
	Next nI
	aCobAbr := {}

Return

Function PLJBMDFAI(cEmpAnt, cFilAnt,cAno,cMes,aVlrCob,nIdade,nIdadePla,dDatTrb,lMudaFaixa,nRecBa3)
	Local J            := 0
	Local nLnVlrCb     := 0
	Default nIdade	   := 0
	Default nIdadePla  := 0
	Default dDatTrb    := CtoD("01/"+cMes+"/"+cAno)
	Default lMudaFaixa := .T.
	Default aVlrCob    := {}
	Default cAno       := ""
	Default cMes       := ""
	Default nRecBa3    := ""

	rpcSetType(3)
	rpcSetEnv(cEmpAnt, cFilAnt,,,'PLS')

	BA3->(DBGOTO(nRecBa3))

	nLnVlrCb := len(aVlrCob)

	For J:=1 to nLnVlrCb

		BA1->(DbSetOrder(2))
		If BA1->(MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
			While ! BA1->(Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)

				// Calcula a sua idade em meses...
				nIdade    := Calc_Idade(dDatTrb,BA1->BA1_DATNAS)
				nIdade	  := Iif(nIdade < 0,0,nIdade)
				nIdadePla := PLSDIFANOS(PLSSTRANO(BA1->BA1_DATINC,.T.),PLSSTRMES(BA1->BA1_DATINC),cAno,cMes,"A")

				//Verifica se deve congelar a faixa
				AnaReajId(nIdade,nIdadePla,@lMudaFaixa)

				// Atualiza os campos de mudanca de faixa no  usuario de  acordo com as regras acima...
				If !lMudaFaixa

					AnaUsrFaixa(aVlrCob,.T.,nIdadePla >= 10)
				Else

					nPos := Ascan(aVlrCob,{ |x| x[7] == BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) .And. x[3] == "101"	})

					If nPos > 0

						BA1->(RecLock("BA1",.F.))
						BA1->BA1_FAICOB := aVlrCob[nPos,13] //A faixa que devera ser cobrada...
						BA1->(MsUnLock())
					EndIf
				EndIf

				lMudaFaixa := .T.

				// Se o usuario tiver mais de 10 anos de plano nao muda mais a faixa...
				BA1->(DbSkip())
			EndDo
		EndIf
	Next

	rpcClearEnv()

Return

Function PlsAprMsg(cTipo,nQtd,lAuto,cMsgpnt,oSayJob)
	Local cTexto   := ""
	Default cTipo  := ""
	Default nQtd   := 0
	Default lAuto  := .F.
	Default cMsgpnt:= ""
	Default oSayJob:= nil

	If cTipo == "1" .And. !lAuto
		cTexto:= STR0293+cvaltochar(nQtd)+""                                          //Total de famílias a calcular:

	ElseIf cTipo == "2" .And. !lAuto
		cTexto:= STR0294+cvaltochar(nQtd)+STR0295                                     //"Faltam x famílias para calcular..."

	ElseIf cTipo == "3" .And. !lAuto
		cTexto:= STR0296                                                              //"Fim do cálculo de famílias..."

	ElseIf cTipo == "4" .And. !lAuto
		cTexto:= STR0297                                                              //"Finalizando tabela temporária do cálculo de Famílias..."

	ElseIf cTipo == "5" .And. !lAuto
		cTexto:= STR0298                                                              //"Consolidando Valores das Famílias..."

	ElseIf cTipo == "6" .And. !lAuto
		cTexto:= cMsgpnt

	Else
		Return()    //utilizado para automação
	EndIf

	oSayJob:SetText(cTexto)
	ProcessMessages()

Return

