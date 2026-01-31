#INCLUDE "PROTHEUS.CH"
#INCLUDE "TECA910.CH"
#INCLUDE "FILEIO.CH"

Static aCCT 	:= {}
Static aDados 	:= {}
Static aAbbHE	:= {}
Static dMVPAR03 := CTOD("")
Static dMVPAR04 := CTOD("")
Static lBaseOp  := .F.

#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA910()

Gera as marcações atraves do atendimento da O.S

@return ExpL: Retorna .T. quando teve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA910(lSemTela, aParams, aAtendentes)
Local cQuery		:= ""
Local cAlias		:= ""	// Alias
Local cTitle		:= ""
Local cComAA1 		:= FwModeAccess("AA1",1) +  FwModeAccess("AA1",2) + FwModeAccess("AA1",3)
Local cComSRA 		:= FwModeAccess("SRA",1) +  FwModeAccess("SRA",2) + FwModeAccess("SRA",3)
Local nTotal
Local oDlg
Local oPanTop
Local oPanBot
Local oFont
Local nMeter
Local oMeter
Local oSay
Local oSayMsg
Local dDataIni
Local dDataFim
Local lContinua		:= .T.
Local cMvGsxInt 	:= SuperGetMv("MV_GSXINT",,"2")
Local lMV_GSXINT	:= cMvGsxInt  <> "2"
Local cTpExp 		:= SuperGetMV("MV_GSOUT", .F., "1") //1 - Integração RH protheus(Default) - 2 Ponto de Entrada - 3 Arquivo CSV
Local cDirArq 		:= At910RHD()
Local nHandle 		:= 0
Local aRet 			:= {.T.,{}}
Local cMsg 			:= ""
Local nHandle2 		:= 0 //Handle para exportação do RM
Local lInclui 		:= .F.
Local aEmpFil 		:= {}
Local lMultFil		:= TecHasPerg("MV_PAR07","TEC910B")
Local lMultThread	:= TecHasPerg("MV_PAR11","TEC910B") .AND. TecHasPerg("MV_PAR12","TEC910B")
Local lAglutBtd		:= TecHasPerg("MV_PAR13","TEC910B")
Local lFolder		:= TecHasPerg("MV_PAR14","TEC910B")
Local lParMultFil	:= SuperGetMV("MV_GSMSFIL",,.F.) .AND. (LEN(STRTRAN( cComAA1  , "E" )) > LEN(STRTRAN(  cComSRA  , "E" )))
Local cFilBkp		:= cFilAnt
Local aMtFil		:= {}
Local aAglut		:= {}
Local nX			:= 0
Local lLastFil		:= .F.
Local cFolder		:= ""
Local cSql			:= ""
Local cAliasQry := GetNextAlias()
Local AtdTDVN := {}
Local lFuncBaseOP	:= FindFunction("TecBaseOp") .And. FindFunction("TecConfCCT")

Default lSemTela 	:= .F.
Default aParams 	:= {}
Default aAtendentes := {}

aDados 	:= {}
aCCT	:= {}

If FindFunction('TECBLimp')
	TECBLimp()
EndIf

DbSelectArea("ABB")
If SuperGetMV("MV_GSGEROS",.F.,"1") == "2" .And. ABB->( ColumnPos("ABB_MPONTO") ) == 0
	aRet[1] 	:= .F.
	lContinua 	:= .F.
	cMsg 		:= STR0040+" "+STR0041
	Help(,, "TECA910",,STR0040,1,0,,,,,,{STR0041}) //"O parâmetro MV_GSGEROS está preenchido com '2', mas o campo ABB_MPONTO não foi encontrado."##"Realize a inclusão do campo."
	aAdd(aRet[2], cMsg)
Endif

//Verifica se a Base está com o "novo" Pergunte - TEC910B
If !TecHasPerg("MV_PAR01","TEC910B")
	aRet[1] 	:= .F.
	lContinua 	:= .F.
	cMsg 		:= "Pergunte TEC910B não localizado."+"Favor atualizar dicionário de dados com último pacote de Expedição Contínua disponível para utilização da rotina."
	Help(,, "TECA910",,"Pergunte TEC910B não localizado.",1,0,,,,,,{"Favor atualizar dicionário de dados com último pacote de Expedição Contínua disponível para utilização da rotina."}) //"Pergunte TEC910B não localizado."##"Favor atualizar dicionário de dados com último pacote de Expedição Contínua disponível para utilização da rotina."
	aAdd(aRet[2], cMsg)
Endif

//Verifica se tem as configurações de base operacional e CCT e o não gera O.S
If lFuncBaseOP .And. TecBaseOp() .And. TecConfCCT() .And. SuperGetMV("MV_GSGEROS",.F.,"1") == "2"
	lBaseOp := .T.
EndIf

//----------------------------------------------------------------------------
// Parametros Utilizados no Pergunte
//
// MV_PAR01: Atendente De ?
// MV_PAR02: Atendente Ate ?
// MV_PAR03: Data Inicio De ?
// MV_PAR04: Data Inicio Ate ?
// MV_PAR05: Processamento ? 1=Inclusao;2=Exclusao
// MV_PAR06: Mantem Int Turnos? 1=Sim;2=Não
// MV_PAR07: Filial para geração dos atendimentos. Vazio = Filial atual
// MV_PAR08: Local De?
// MV_PAR09: Local Até?
// MV_PAR10: Processa Todas as Filiais?
// MV_PAR11: Processa em multthread?
// MV_PAR12: Quantidade de threads?
// MV_PAR13: Aglutina marcações?
// MV_PAR14: Local do Arquivo de Log
//------------------------------------------------------------------------------
If lContinua

	If  "2" $ cTpExp .and. !ExistBlock("At910CMa")
		cMsg := STR0034
		Help(,, "At910CMa",cMsg ,, 1, 0)//"Ponto de Entrada At910CMa nao compilado."
		cTpExp := StrTran(cTpExp, "2", )
		aAdd(aRet[2], cMsg)
	EndIf

	If !lSemTela
		lContinua := Pergunte("TEC910B",.T.)
	Else
		Pergunte("TEC910B",.F.)
	EndIf

	If lContinua
		If lMultFil
			IF (EMPTY(MV_PAR07))
				aAdd(aMtfil,cFilant)
			Else
				At900PMtFl(MV_PAR07,@aMtFil,"TEC910B","MV_PAR07")
			EndIF
		Else
			aAdd(aMtfil,cFilant)
		EndIf

		If !Empty(aParams)
			MV_PAR01 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR01"})][2]
			MV_PAR02 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR02"})][2]
			MV_PAR03 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR03"})][2]
			MV_PAR04 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR04"})][2]
			MV_PAR05 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR05"})][2]
			MV_PAR06 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR06"})][2]
			If ASCAN(aParams, {|d| d[1] == "MV_PAR07"}) > 0
				MV_PAR07 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR07"})][2]
			EndIf
			If ASCAN(aParams, {|d| d[1] == "MV_PAR08"}) > 0
				MV_PAR08 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR08"})][2]
			EndIf
			If ASCAN(aParams, {|d| d[1] == "MV_PAR09"}) > 0
				MV_PAR09 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR09"})][2]
			EndIf
			If ASCAN(aParams, {|d| d[1] == "MV_PAR10"}) > 0
				MV_PAR10 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR10"})][2]
			EndIf
			If ASCAN(aParams, {|d| d[1] == "MV_PAR11"}) > 0
				MV_PAR11 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR11"})][2]
			EndIf
			If ASCAN(aParams, {|d| d[1] == "MV_PAR12"}) > 0
				MV_PAR12 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR12"})][2]
			EndIf
			If ASCAN(aParams, {|d| d[1] == "MV_PAR13"}) > 0
				MV_PAR13 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR13"})][2]
			EndIf
		EndIf

		// Define pasta do arquivo de log
		If lFolder
			cFolder := AllTrim(MV_PAR14)
		EndIf
		If !Empty(cFolder) .And. ExistDir(cFolder)
			If Subs(cFolder,Len(cFolder),1) <> "\"
				cFolder += "\"
			EndIf
		Else
			cFolder := AllTrim(GetPvProfString(GetEnvServer(),"startpath","",GetADV97()))+"GestaoServicos"
		EndIf

		For nX := 1 to Len(aMtFil)
			cFilant := aMtFil[nX]
			//Verifica Periodo de Apontamente(MV_PAPONTA)
			If "1" $ cTpExp .AND. !lMV_GSXINT
				PerAponta(@dDataIni,@dDataFim )
			Else
				dDataIni :=  MV_PAR03
				dDataFim :=  MV_PAR04
			EndIf
			If MV_PAR03 < dDataIni .OR. MV_PAR04 > dDataFim
				nRetorno := Aviso(STR0058,STR0059,{STR0060,STR0061},,"",,"BMPPERG") //"O período selecionado diverge do período de apontamento. Deseja continuar?"
				If nRetorno == 2
					cMsg := STR0062
					Aviso(STR0001,cMsg,{STR0004},2) // OK
					lContinua := .F.
					Exit
				Else
					Exit
				EndIf
			EndIf
		Next nX
	EndIf
EndIf

If lContinua

	cSql += " SELECT DISTINCT AA1.AA1_FUNFIL, AA1.AA1_CDFUNC FROM " + RetSqlName("ABB") + " ABB "
	cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV ON "
	cSql += " ABB.ABB_FILIAL = TDV.TDV_FILIAL AND "
	cSql += " ABB.ABB_CODIGO = TDV.TDV_CODABB AND "
	cSql += TECStrExpBlq("TDV",,,2)
	cSql += " TDV.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("AA1") + " AA1 ON "
	cSql += " AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
	cSql += " AA1.AA1_FILIAL = '"+xFilial("AA1")+"' AND "
	cSql += " AA1.D_E_L_E_T_ = ' ' "
	cSql += " WHERE "
	cSql += " ABB.D_E_L_E_T_ = ' ' AND "
	cSql += " TDV.TDV_TPDIA = 'N' AND "
	cSql += " TDV.TDV_DTREF >='" + DToS( MV_PAR03 ) + "' AND "
	cSql += " TDV.TDV_DTREF <='" + DToS( MV_PAR04 ) + "' AND "
	cSql += " ABB.ABB_CODTEC >='" +  MV_PAR01 + "' AND "
	cSql += " ABB.ABB_CODTEC <='" +  MV_PAR02 + "' AND "
	cSql += " ABB.ABB_CHEGOU ='S' AND "
	cSql += " ABB.ABB_ATENDE ='1' AND "
	cSql += " ABB.ABB_ATIVO = '1' "
	cSql += TECStrExpBlq("ABB")

	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
	While !(cAliasQry)->(EOF())
		AADD(AtdTDVN, ((cAliasQry)->AA1_FUNFIL + (cAliasQry)->AA1_CDFUNC))
		(cAliasQry)->(DBSkip())
	End
	(cAliasQry)->(DbCloseArea())

	For nX := 1 to Len(aMtFil)
		lLastFil := IIF(lParMultFil, .T., nX == Len(aMtFil))
		nTotal 	:= 0
		cAlias 	:= GetNextAlias()
		cFilant := aMtFil[nX]

		If lMultThread .AND. lContinua .AND. nX == 1
			If MV_PAR11 == 1
				If MV_PAR05 == 1
					If !( "1" $ cTpExp .AND. cMvGsxInt == "2" )
						cMsg := STR0082 // "Não é possivel gerar o Mult-Thread com integração com outras marcas. Para utilizar a integração por favor desative o parametro de Mult-Thread. Operação Cancelada."
						Aviso(STR0001,cMsg,{STR0004},2) // OK
						lContinua := .F.
					EndIf
				EndIf
			EndIf
		EndIf

		If "3" $ cTpExp
			nHandle := At910RHF("at910", cDirArq, .T., Iif(MV_PAR05==1,3,5), ".csv")

			If nHandle == -1
				lContinua := .F.
				cMsg := STR0035//"Problemas na criação do arquivo CSV"
				Help(,, "TECA910",cMsg ,, 1, 0)//"Problemas na criação do arquivo CSV"
				aAdd(aRet[2], cMsg)
			EndIf
		EndIf

		If  cMvGsxInt == "3" .AND. MV_PAR05==1

			aEmpFil := GSItEmpFil(, , "RM", .T., .T., cMsg)
			nHandle2 := At910RHF("RM_Marc", cDirArq, .T., Iif(MV_PAR05==1,3,5), ".txt")

			If nHandle2 == -1  .OR. Len(aEmpFil) = 0
				lContinua := .F.
				cMsg := STR0036//"Problemas na exportação do arquivo da marcações para RM"
				Help(,, "TECA910",cMsg ,, 1, 0)
				aAdd(aRet[2], cMsg)
			EndIf
		EndIf

		If lContinua
			dMVPAR03 := MV_PAR03
			dMVPAR04 := MV_PAR04
			DbSelectArea("ABB")

			//Monta a Query para geração da marcação
			cQuery := At910Qry(aAtendentes)

			cQuery := ChangeQuery( cQuery )

			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAlias , .T. , .T. )

			TcSetField(  cAlias	, "AB9_DTINI", "D", 8, 0 )
			TcSetField(  cAlias	, "AB9_DTFIM", "D", 8, 0 )

			While !(cAlias)->(Eof())
				AADD( aDados, {(cAlias)->AA1_FUNFIL,;
								(cAlias)->AA1_CDFUNC,;
								(cAlias)->AB9_DTINI,;
								(cAlias)->AB9_DTFIM,;
								(cAlias)->AB9_HRINI,;
								(cAlias)->AB9_HRFIM,;
								(cAlias)->TDV_TURNO,;
								(cAlias)->TDV_SEQTRN,;
								(cAlias)->TDV_DTREF})
				If lAglutBtd .AND. MV_PAR13 == 1
					If ASCAN(AtdTDVN, (cAlias)->AA1_FUNFIL + (cAlias)->AA1_CDFUNC ) > 0
						AADD(aAglut, { (cAlias)->AA1_FUNFIL,;
										(cAlias)->AA1_CDFUNC,;
										(cAlias)->TDV_HRMAI,;
										(cAlias)->TDV_HRMEN,;
										(cAlias)->TDV_TPDIA,;
										(cAlias)->RECTDV,;
										(cAlias)->TDV_FILIAL,;
										(cAlias)->AB9_DTINI,;
										(cAlias)->AB9_DTFIM,;
										(cAlias)->AB9_HRINI,;
										(cAlias)->AB9_HRFIM,;
										(cAlias)->TDV_DTREF,;
										(cAlias)->TDV_INTVL1 } )
					EndIf
				EndIf
				nTotal++
				(cAlias)->(DbSkip())
			EndDo
			If !EMPTY(aAglut)
				If !isBlind()
					FwMsgRun(Nil,{|| AglutTDVs(ACLONE(aAglut)) }, Nil, STR0085) //"Aglutinando marcações. . ."
				Else
					AglutTDVs(ACLONE(aAglut))
				EndIf
			EndIf
			(cAlias)->(DbGoTop())
			lInclui := MV_PAR05==1
			If nTotal > 0
				If (!isBlind() .AND. !lSemTela) .OR. !IsInCallStack("TecGeraReg")
					If lParMultFil
						If lInclui
							cTitle := STR0005 // Inclusão
						Else
						    cTitle := STR0088 // Exclusão
						EndIf
					Else
						If lInclui
							cTitle := STR0005+cFilant // Inclusão
						Else
							cTitle := STR0088+cFilant //"Exclusão das Marcações"
						EndIf
					EndIf
					DEFINE MSDIALOG oDlg TITLE cTitle FROM 0,0 TO 100,450 PIXEL STYLE DS_MODALFRAME // "Geração das Marcações"
						oPanTop := TPanel():New( 0, 0, , oDlg, , , , , , 0, 0, ,  )
						oPanTop:Align := CONTROL_ALIGN_ALLCLIENT

						oPanBot := TPanel():New( 0, 0, , oDlg, , , , ,/*CLR_YELLOW*/, 0, 25 , )
						oPanBot:Align := CONTROL_ALIGN_BOTTOM

						DEFINE FONT oFont NAME "Arial" SIZE 0,16
							// "Serão processados "#" atendimentos para a Geração de Marcações."
						If lInclui
							@ 05,08 SAY oSay Var "<center>"+STR0006+cValToChar(nTotal)+STR0007+cFilant+"</center>" PIXEL SIZE 210,65 HTML FONT oFont PIXEL OF oPanTop
						Else
							// "Serão processados "#" Exclusões de Marcações."
							@ 05,08 SAY oSay Var "<center>"+STR0006+cValToChar(nTotal)+STR0090+cFilant+"</center>" PIXEL SIZE 210,65 HTML FONT oFont PIXEL OF oPanTop
						EndIf
						nMeter := 0
						oMeter := TMeter():New(02,7,{|u|if(Pcount()>0,nMeter:=u,nMeter)},nTotal,oPanBot,200,100,,.T.,,,.F.)
						//"Processando..."#
						@ 10,02 SAY oSayMsg Var "<center>"+STR0008+"</center>" PIXEL SIZE 210,65 HTML FONT oFont PIXEL OF oPanBot

					ACTIVATE DIALOG oDlg CENTERED ON INIT At910GerMa(cAlias,oDlg,oMeter,oSayMsg,dDataIni,dDataFim,MV_PAR06==1,lSemTela,cTpExp,nHandle, @aRet, nHandle2, aEmpFil, lLastFil, cFolder)

				Else
					At910GerMa(cAlias,/*oDlg*/,/*oMeter*/,/*oSayMsg*/,dDataIni,dDataFim,MV_PAR06==1,lSemTela, cTpExp, nHandle, @aRet, nHandle2, aEmpFil)
				EndIf
			Else
				At910Log(,,STR0009,aRet,cFilant) //"Não há registros para gerar marcações conforme parametros informados."
				If !lSemTela .AND. lLastFil
					Aviso(STR0001,STR0083 + cFolder,{STR0004},2) //"Processo concluído. Verifique as inconsistências em: "
				EndIf
			EndIf
		EndIf
		lContinua := .T.
		If lParMultFil
			Exit
		EndIf
	Next nX
EndIf

If cFilant <> cFilBkp
	cFilant := cFilBkp
EndIf

If nHandle > 0
	fClose(nHandle)
EndIf

If nHandle2 > 0
	fClose(nHandle2)
EndIf

aAbbHE		:= {}
dMVPAR03 	:= CTOD("")
dMVPAR04 	:= CTOD("")
aDados 		:= {}
aCCT		:= {}

If FindFunction('TECBLimp')
	TECBLimp()
EndIf

Return aRet
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910GerMa()

Realiza o Processamento do Pergunte na geração de marcacoes

@param ExpC:Alias da Tabela de processamento
@param ExpO:Dialog do Processamento
@param ExpO:Tmeter para atualizar o processamento
@param ExpO:Texto do processamento
@param ExpD:Data Inicial Limite
@param ExpD:Data Final Limite
@param ExpL:Gera marcação com os intervalos dos turno?

@return ExpL: Retorna .T. quando houve sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At910GerMa(cAlias,oDlg,oMeter,oSayMsg,dDataIni,dDatafim,lGeraMarcInt,lSemTela, cTpExp, nHandle, aRet, nHandle2, aEmpFil, lLastFil, cFolder)

Local nCritica		:= 0
Local nX			:= 0
Local nY			:= 0
Local lRet 			:= .F.
Local nReg			:= 0
Local aRetorno		:= {}
Local aMarcacao		:= {}
Local cMsg			:= ""
Local cMsgRM		:= ""
Local cCdFunc		:= ""
Local dMarcIni
Local cMarcIni
Local dMarcFim
Local cMarcFim
Local aMarcTec 		:= {} //Armazena marcações do atendente para enviar ao Módulo de ponto eletronico
Local cAtendOld 	:= "" //controle do codigo do atendente
Local lLimite 		:= .F.
Local lGSxInt		:= SuperGetMV("MV_GSXINT",,"2") == "3"
Local lTDXIniHor	:= TDX->( ColumnPos('TDX_INIHOR') ) > 0
Local lTDWCodHor	:= TDW->( ColumnPos('TDW_CODHOR') ) > 0
Local cTDWIniHor	:= ""
Local cTDWCodHor	:= ""
Local lMostra		:= .T.
Local lEnvia		:= MV_PAR05 == 1
Local lMultThread	:= TecHasPerg("MV_PAR11", "TEC910B") .AND. MV_PAR11 == 1
Local dRMDatIni
Local aEscala		:= {}
Local aEscTGY		:= {}
Local cCodTurno		:= ""
Local cAliasTGY		:= GetNextAlias()
Local cOk           := ""

Default lLastFil	:= .F.
Default lSemTela 	:= .F.
Default aRet 		:= {.T.,{}}
Default cFolder		:= ""

While !(cAlias)->(Eof())

	If lGSxInt
		dRMDatIni	:= (cAlias)->AB9_DTINI
	EndIf
	If (!IsBlind() .AND. !lSemTela ).OR. !IsInCallStack("TecGeraReg")
		oMeter:Set(++nReg) // Atualiza Gauge/Tmeter
		oSayMsg:SetText("<center>"+STR0011+cValToChar(nReg)+"</center>") // "Processando..."
	EndIf

	cMarcIni	:= (cAlias)->AB9_HRINI
	cMarcFim	:= (cAlias)->AB9_HRFIM

	If (cAlias)->AB9_DTINI == (cAlias)->AB9_DTFIM
		dMarcIni	:= (cAlias)->AB9_DTINI
		dMarcFim	:= (cAlias)->AB9_DTFIM
		// Se gerou agenda mesma data porém hora inicio 07:00 apos ou igual hora final 07:00 (24 horas)
		If (cAlias)->AB9_HRINI >= (cAlias)->AB9_HRFIM
			dMarcFim	:= (cAlias)->AB9_DTFIM + 1
		EndIF
		At910AProc(@aRetorno,cAlias,dMarcIni,cMarcIni,dMarcFim,cMarcFim)
	ElseIf (cAlias)->AB9_DTFIM > (cAlias)->AB9_DTINI
		//Quando hora final > inicial é pq a marcação final é no dia seguinte. Ex. das 20:00 as 05:00
		If (cAlias)->AB9_HRINI >= (cAlias)->AB9_HRFIM
			//Faz por periodo. Se mais de mais de 1 dia de diferença.
			//Ex. Se de 01/10 a 03/10 das 20:00 as 05:00 gera atendimento:
			//Entrada - 01/10 as 20:00 saida 02/10 as 05:00
			//Entrada - 02/10 as 20:00 saida 03/10 as 05:00
			For nX := 0 To (((cAlias)->AB9_DTFIM) - ((cAlias)->AB9_DTINI) - 1)
				dMarcIni	:= (cAlias)->AB9_DTINI + nX
				dMarcFim	:= (cAlias)->AB9_DTINI + nX + 1
				At910AProc(@aRetorno,cAlias,dMarcIni,cMarcIni,dMarcFim,cMarcFim)
			Next nX
		Else //(cAlias)->AB9_HRINI <= (cAlias)->AB9_HRFIM
			//Faz por periodo quando hora inicial < hora final. Ex. de 01 a 02 das 08:00 as 17:00
			//Entrada - 01/10 as 08:00 saida 01/10 as 17:00
			//Entrada - 02/10 as 08:00 saida 02/10 as 17:00
			For nX := 0 To (((cAlias)->AB9_DTFIM) - ((cAlias)->AB9_DTINI))
				dMarcIni	:= (cAlias)->AB9_DTINI + nX
				dMarcFim	:= (cAlias)->AB9_DTINI + nX
				At910AProc(@aRetorno,cAlias,dMarcIni,cMarcIni,dMarcFim,cMarcFim)
			Next nX
		EndIf
	EndIf
	If lGSxInt
		If (lTDXIniHor .AND. lTDWCodHor)
			If (cAlias)->ABB_TIPOMV == '001' .AND. (cCodTurno <> (cAlias)->TDV_TURNO .OR. cCdFunc <> (cAlias)->AA1_CDFUNC)
				QryEscala( @cAliasTGY, (cAlias)->TDV_TURNO, (cAlias)->TDV_CODABB, (cAlias)->TDV_SEQTRN )
				cTDWIniHor	:= (cAliasTGY)->TDX_INIHOR
				cTDWCodHor	:= (cAliasTGY)->TDW_CODHOR
				cCdFunc		:= (cAlias)->AA1_CDFUNC
				If !Empty(cTDWIniHor) .AND. !Empty(cTDWCodHor)
					aEscala := At910ConRM( cCdFunc, dRMDatIni, cAliasTGY, @aEscTGY, lEnvia, cTDWIniHor, cTDWCodHor, @cMsgRM )
					If lEnvia
						If Empty(cCodTurno)
							If (aEscala[2] <> cTDWCodHor) .OR. (aEscala[2] == cTDWCodHor .AND. aEscala[3] <> cTDWIniHor)
								At910EnvRM( cCdFunc, @cMsgRM, aEscTGY, lEnvia, , cAliasTGY, (cAlias)->TDV_DTREF )
							EndIf
						Else
							If aEscala[2] <> cTDWCodHor
								At910EnvRM( cCdFunc, @cMsgRM, aEscTGY, lEnvia, , cAliasTGY, (cAlias)->TDV_DTREF )
							EndIf
						EndIf
					Else
						If !Empty(aEscala) .AND. !Empty(aEscala[1])
							At910EnvRM( cCdFunc, @cMsgRM, aEscTGY, lEnvia, aEscala, cAliasTGY )
						EndIf
					EndIf
				Else
					cMsgRm	+= STR0050 + CRLF // "Não foi possivel envia a troca de turnos pois os campos TDX_INIHOR e/ou TDW_CODHOR não foram preenchidos."
					cMsgRM 	+= STR0051 + (cAliasTGY)->TDW_COD + CRLF // "Escala: "
					cMsgRM	+= STR0052 + (cAlias)->AA1_NOMTEC + CRLF // "Atendente: "
					cMsgRM	+= STR0053 + cCdFunc + CRLF // "Matricula (CHAPA): "
					cMsgRM	+= STR0054 + (cAlias)->AB9_CODTEC + CRLF + CRLF // "Codigo do Tecnico: "
				EndIf
				(cAliasTGY)->(DBCloseArea())
			EndIf
			cCodTurno	:= (cAlias)->TDV_TURNO
		Else
			If lMostra
				cMsgRM += STR0048 // "Os Campos TDX_INIHOR e TDW_CODHOR não foram identificados, por favor, para utilização da troca de turno é necessário a criação dos mesmo."
				lMostra := .F.
			EndIf
		EndIf
	EndIf

	(cAlias)->(DbSkip())
End

(cAlias)->(DbCloseArea())


If Empty(aRetorno)
	//"Atenção"#"Não há registros para gerar marcações conforme parametros informados."#"OK"
	If !lSemTela .AND. lLastFil
		Aviso(STR0001,STR0014,{STR0004},2) //"Não há registros para gerar marcações conforme parametros informados."
	EndIf
	aRet[1] := .F.
	AADD(aRet[2], STR0014) //"Não há registros para gerar marcações conforme parametros informados."
Else
	//Ordena por Tecnico/Data|Hora Inicial+Data Referencia
	ASort(aRetorno,,,{|x,y| x[1]+DToS(x[2])+x[3]+x[12] < y[1]+DToS(y[2])+y[3]+y[12] })
	If !isBlind()
		FwMsgRun(Nil,{|| aMarcacao := At910PMarc(aRetorno,lGeraMarcInt, aRet) }, Nil, STR0084) //"Preparando o envio. . ."
	Else
		aMarcacao := At910PMarc(aRetorno,lGeraMarcInt, aRet)
	EndIf

	lLimite :=  !Empty(aTail(aRet[02]))


	nReg := 0
	If !IsBlind() .AND. !lSemTela .And. !lMultThread
		oMeter:SetTotal(Len(aMarcacao))
		oMeter:Set(nReg) // Atualiza Gauge/Tmeter
	EndIf

	//realiza aglutinação da marcação para o atendente, considerando que aMarcacao esteja ordenado por atendente.
	For nX := 1 To Len(aMarcacao)
		If cAtendOld != aMArcacao[nX][1]
			aAdd(aMarcTec, {aMarcacao[nX][1], {}})//cria posição do array para o atendente
			cAtendOld := aMarcacao[nX][1]
		EndIf
		aAdd(aMarcTec[Len(aMarcTec)][2], aMarcacao[nX])//adiciona marcações para o atendente
	Next nX

	If !lMultThread
		For nX := 1 To Len(aMarcTec)
			nReg+= Len(aMarcTec[nX][2])
			If (!IsBlind() .AND. !lSemTela ).OR. !IsInCallStack("TecGeraReg")
				oSayMsg:SetText("<center>"+STR0015+cValToChar(Len(aMarcacao))+STR0016+cValToChar(nReg)+"</center>") //"Gerando "###" Marcações. Gerando..."
				oMeter:Set(nReg) // Atualiza Gauge/Tmeter
			EndIf

			If  (lRet := At910Marca(aMarcTec[nX][2],@cMsg,cTpExp, nHandle, nX == 1, nHandle2, aEmpFil))
				For nY:=1 To Len(aMarcTec[nX][2])
					At910AtAB9(aMarcTec[nX][2][nY][11])
				Next nY
			Else
				nCritica++
				For nY:=1 To Len(aMarcTec[nX][2])
					At910Log(,aMarcTec[nX][2][nY], cMsg)
				Next nY
			EndIf
		Next nX

		If nCritica == 0
			//"Atenção"#"Foram processadas: "#" marcações de entrada e saída."#"OK"
			If !lSemTela .AND. lLastFil
				Aviso(STR0001,STR0018 + cValToChar(nReg) + STR0019 + STR0056 + cFilant + IIF(lLimite, CRLF + STR0037, ""),{STR0004},2) //"Verificar o log pois existem colocaboradores que tiveram mais batidas que o limite permitido para o Ponto Protheus"
			EndIf
			AADD(aRet[2], STR0018+ cValToChar(nReg) +  STR0019 )
			cOk := STR0018+ cValToChar(nReg) +  STR0019
		Else
			/*"Atenção"#"Foram processadas: "#" Ocorreram "#" erro(s) no processamento."#
			"Quando há critica todas marcações do tecnico para o período não serão geradas."
			"Foi gerado o log no arquivo "#"OK" */
			If !lSemTela .AND. lLastFil
				Aviso(STR0001,STR0063 +TxLogPath(ALLTRIM(cFilant)+"MarcaErro",,cFolder),{STR0004},2) // "Processo cloncluido, inconsistencia geradas no log: "
			EndIf
			AADD(aRet[2], STR0063 +TxLogPath(ALLTRIM(cFilant)+"MarcaErro",,cFolder)) // "Processo cloncluido, inconsistencia geradas no log: "
		EndIf
	Else
		At910MultP(aMarcTec,cMsg,cTpExp, nHandle, nHandle2, aEmpFil)
		If !lSemTela .AND. lLastFil
			Aviso(STR0001,STR0063 +TxLogPath(ALLTRIM(cFilant)+"MarcaErro",,cFolder),{STR0004},2) // "Processo cloncluido, inconsistencia geradas no log: "
		EndIf
		AADD(aRet[2], STR0063 +TxLogPath(ALLTRIM(cFilant)+"MarcaErro",,cFolder)) // "Processo cloncluido, inconsistencia geradas no log: "
		oDlg:End()
	EndIf
EndIf
If (!IsBlind() .AND. !lSemTela) .OR. !IsInCallStack("TecGeraReg")
	If lGSxInt .AND. !Empty(cMsgRM)
		AtShowLog(cMsgRM,STR0049,/*lVScroll*/,/*lHScroll*/,/*lWrdWrap*/,.F.) // "Integração RM"
	EndIf
	oDlg:End()
EndIf

If !lMultThread
	If ValType(aRet[2][1]) == "C"
		If aRet[2][1] == cOk
			aRet := {.T.,{}}
		EndIf
	EndIf
EndIf
Return( .T. )

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910AProc()

Gera a array de processamento dos atendimentos da o.s.

@param ExpA:Array que sera alimentada, enviar por referencia
@param ExpC:Alias da tabela de processamento
@param ExpD:Data Entrada da Marcacao
@param ExpC:Hora Entrada da Marcacao
@param ExpD:Data Saida da Marcacao
@param ExpC:Hora Saida da Marcacao
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At910AProc(aRetorno,cAlias,dMarcIni,cMarcIni,dMarcFim,cMarcFim)
Local aDadosCCT	:= {}
Local cFuncao	:= ""
Local cRegra	:= ""
Local lRegra	:= TFF->( ColumnPos('TFF_REGRA') ) > 0
Local lGsGerOs	:= SuperGetMV("MV_GSGEROS",.F.,"1") == "1" //Gera O.S na rotina de geração de atendimento do gestão de serviços 1 = Sim e 2 = Não.
Local cCusto	:= ""

	If lBaseOp
		cFuncao := (cAlias)->RJ_FUNCAO
		cCusto 	:= (cAlias)->ABS_CCUSTO
		If lRegra .And. !lGsGerOs
			cRegra := POSICIONE("TFF",1,xFilial("TFF") + (cAlias)->ABQ_CODTFF,"TFF_REGRA")
		EndIf
		If Empty(cRegra)
			cRegra	:= (cAlias)->ABS_REGRA
		EndIf
	EndIf

	AAdd(aRetorno,{;
		(cAlias)->AB9_CODTEC,; 	//1
		dMarcIni,;				//2
		cMarcIni,;				//3
		dMarcFim,;				//4
		cMarcFim,;				//5
		(cAlias)->AA1_CDFUNC,;	//6
		(cAlias)->AA1_FUNFIL,;	//7
		(cAlias)->AB9_NUMOS,;	//8
		(cAlias)->AB9_CODCLI,;	//9
		(cAlias)->AB9_LOJA,;	//10
		(cAlias)->AB9RECNO,;	//11
		(cAlias)->TDV_DTREF,;	//12
		(cAlias)->ABB_CODIGO,; 	//13
		Nil,;					//14
		Nil,;					//15
		(cAlias)->TDV_FILIAL,;	//16
		Nil,;					//17 Filial da CCT
		Nil,;					//18 Codigo da CCT
        (cAlias)->TDV_TURNO,;	//19 Codigo da CCT
		cFuncao,;				//20 Função	
		cRegra,;				//21 Regra
		cCusto				})	//22 Centro de Custo ABS

If SuperGetMV("MV_GSHRPON",.F., "2") == "1" .AND. ( ABB->(ColumnPos('ABB_HRCHIN')) > 0 )
	If !Empty((cAlias)->ABB_HRCHIN) .AND. !Empty((cAlias)->ABB_HRCOUT)
		aRetorno[Len(aRetorno)][14] := (cAlias)->ABB_HRCHIN
		aRetorno[Len(aRetorno)][15] := (cAlias)->ABB_HRCOUT
	EndIf
EndIf
//Verifica se está com a base operacional e a CCT configurados
If lBaseOp
	aDadosCCT := At910CodCCT(cAlias)
	If Len(aDadosCCT) > 0
		aRetorno[Len(aRetorno)][17] := aDadosCCT[1]
		aRetorno[Len(aRetorno)][18] := aDadosCCT[2]
	EndIf
EndIf

Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910Qry()

Gera a query para a geração de marcações

@return ExpC: Retorna a query utilizada para trazer os atendimentos
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At910Qry(aAtendentes)
Local cQuery 		:= ""
Local cFilQuery		:= ""
Local nX
Local lGsGerOs	 	:= SuperGetMV("MV_GSGEROS",.F.,"1") == "1" //Gera O.S na rotina de geração de atendimento do gestão de serviços 1 = Sim e 2 = Não.
Local lGSxInt		:= SuperGetMV("MV_GSXINT",,"2") == "3"
Local lGSHRPon		:= SuperGetMV("MV_GSHRPON",.F., "2") == "1" .AND. ( ABB->(ColumnPos('ABB_HRCHIN')) > 0 )
Local cComAA1 		:= FwModeAccess("AA1",1) +  FwModeAccess("AA1",2) + FwModeAccess("AA1",3)
Local cComSRA 		:= FwModeAccess("SRA",1) +  FwModeAccess("SRA",2) + FwModeAccess("SRA",3)
Local lMultFil		:= SuperGetMV("MV_GSMSFIL",,.F.) .AND. (LEN(STRTRAN( cComAA1  , "E" )) > LEN(STRTRAN(  cComSRA  , "E" )))
Local lMVPar08		:= TecHasPerg("MV_PAR08","TEC910B")
Local lMVPar09		:= TecHasPerg("MV_PAR09","TEC910B")
Local lMVPar10		:= TecHasPerg("MV_PAR10","TEC910B")
Local lMVFil		:= .T.

Default aAtendentes := {}

MakeSqlExpr("TEC910B")
//--------------------------------------
// Parametros Utilizados no Pergunte
//
// MV_PAR01: Atendente De ?
// MV_PAR02: Atendente Ate ?
// MV_PAR03: Data Inicio De ?
// MV_PAR04: Data Inicio Ate ?
// MV_PAR05: Processamento ? 1=Inclusao;2=Exclusao
//--------------------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Query para geração da marcação                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lMVPar10 .AND. MV_PAR10 == 2 .AND. !EMPTY(MV_PAR07)
	cFilQuery := MV_PAR07
	cFilQuery := RIGHT(cFilQuery, LEN(cFilQuery) - 1)
	cFilQuery := LEFT(cFilQuery, LEN(cFilQuery) - 1)

	If "FILIAL" $ cFilQuery
		If AT('TDV_FILIAL',cFilQuery) == 0
			cFilQuery := RIGHT(cFilQuery, LEN(cFilQuery) - 3)
			cFilQuery := "TDV" + cFilQuery
		EndIf
	Else
		lMVFil := .F.
	EndIf
EndIf

If lGsGerOs

	cQuery += "SELECT AB9.AB9_FILIAL,AB9.AB9_NUMOS,AB9.AB9_SEQ,AB9.AB9_CODTEC,AB9.AB9_DTINI,"
	cQuery += " AB9.AB9_DTFIM,AB9.AB9_CODCLI,AB9.AB9_LOJA,AB9.AB9_CONTRT, ABB.ABB_CODIGO, ABB.ABB_LOCAL, "
	If lGSHRPon
		cQuery += " CASE WHEN ABB.ABB_HRCHIN = '' OR ABB.ABB_HRCHIN IS NULL OR ABB.ABB_HRCOUT = '' OR ABB.ABB_HRCOUT IS NULL THEN ABB.ABB_HRINI ELSE ABB.ABB_HRCHIN END AB9_HRINI, "
		cQuery += " CASE WHEN ABB.ABB_HRCHIN = '' OR ABB.ABB_HRCHIN IS NULL OR ABB.ABB_HRCOUT = '' OR ABB.ABB_HRCOUT IS NULL THEN ABB.ABB_HRFIM ELSE ABB.ABB_HRCOUT END AB9_HRFIM, "
		cQuery += " ABB_HRCHIN, ABB_HRCOUT,"
	Else
		cQuery += "AB9_HRINI, AB9_HRFIM, "
	EndIf
	If lGSxInt
		cQuery += " ABB.ABB_TIPOMV, TDV.TDV_CODABB, AA1.AA1_NOMTEC, "
	EndIf
	cQuery += " AA1.AA1_CDFUNC,AA1.AA1_FUNFIL,AA1.AA1_CC,AA1.AA1_TURNO,AA1.AA1_MPONTO, "
	cQuery += " AB9.R_E_C_N_O_ AB9RECNO, TDV.TDV_TURNO, TDV.TDV_SEQTRN, TDV.TDV_DTREF, TDV.TDV_FILIAL, "
	cQuery += " TDV.TDV_HRMAI, TDV.TDV_HRMEN, TDV.TDV_TPDIA, TDV.R_E_C_N_O_ RECTDV, TDV.TDV_INTVL1, TDV.TDV_TURNO "
	cQuery += " FROM "  + RetSqlName( "AB9" ) + " AB9 "
	cQuery += " INNER JOIN "  + RetSqlName( "AA1" ) + " AA1 ON "
	cQuery += " AA1.AA1_FILIAL='" + xFilial( "AA1" ) + "' AND "
	cQuery += " AA1.AA1_CODTEC = AB9.AB9_CODTEC "
	cQuery += " INNER JOIN "  + RetSqlName( "TDV" ) + " TDV ON "

	If !lMultFil
		cQuery += " TDV.TDV_FILIAL ='"+xFilial("TDV") +"' "
	Else
		If lMVPar10 .AND. MV_PAR10 == 2 .AND. !Empty(cFilQuery)
			If lMVFil
				cQuery += " " + cFilQuery + " AND "
			Else
				cQuery += " TDV.TDV_FILIAL " + cFilQuery + " AND "
			EndIf
		EndIf
		cQuery += FWJoinFilial("TDV" , "AB9" , "TDV", "AB9", .T.)
	EndIf
	cQuery += " AND TDV.TDV_CODABB = AB9.AB9_ATAUT "
	cQuery += TECStrExpBlq("TDV")
	cQuery += " INNER JOIN " + RetSqlName( "ABB" ) + " ABB ON "

	If !lMultFil
		cQuery += " ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND "
	EndIf

	cQuery += " ABB.ABB_CODIGO = TDV.TDV_CODABB "
	cQuery += TECStrExpBlq("ABB")
	cQuery += " WHERE "
	If !lMultFil
		cQuery += " AB9.AB9_FILIAL='" + xFilial( "AB9" ) + "' AND "
	EndIf
	cQuery += " AA1.AA1_MPONTO <> '1' AND "

	//Filtra Tecnico
	If Empty(aAtendentes)
		If !Empty(MV_PAR01)
			cQuery += " AB9.AB9_CODTEC >='" +  MV_PAR01 + "' AND "
		EndIf
		If !Empty(MV_PAR02)
			cQuery += " AB9.AB9_CODTEC <='" +  MV_PAR02 + "' AND "
		EndIf
	Else
		cQuery += " AB9.AB9_CODTEC IN ( "
		For nX := 1 to LEN(aAtendentes)
			cQuery += " '" + aAtendentes[nX] + "',"
		Next nX
		cQuery := LEFT(cQuery, LEN(cQuery) - 1)
		cQuery += " ) AND "
	EndIf
	//Filtra Data de Inicio
	If !Empty(MV_PAR03)
		cQuery += " TDV.TDV_DTREF >='" + DToS( MV_PAR03 ) + "' AND "
	EndIf
	If !Empty(MV_PAR04)
		cQuery += " TDV.TDV_DTREF <='" + DToS( MV_PAR04 ) + "' AND "
	EndIf

	//Filtra Marcacao conforme processamento
	cQuery += " AB9.AB9_MPONTO = '"+Iif(MV_PAR05==1,'F','T')+"' AND "

	//Filtra marcacao conforme o Local de Atendimento
	If lMVPar08 .AND. !Empty(MV_PAR08)
		cQuery += " ABB.ABB_LOCAL >='" + MV_PAR08 + "' AND "
	EndIf
	If lMVPar09 .AND. !Empty(MV_PAR09)
		cQuery += " ABB.ABB_LOCAL <='" + MV_PAR09 + "' AND "
	EndIf

	cQuery += " AB9.D_E_L_E_T_=' ' "
	cQuery += " AND AA1.D_E_L_E_T_=' ' "
	cQuery += " AND TDV.D_E_L_E_T_=' ' "
	cQuery += " AND ABB.D_E_L_E_T_=' ' AND ABB.ABB_ATIVO = '1' "
	cQuery += " ORDER BY AB9.AB9_CODTEC,AB9.AB9_DTINI"
Else

	cQuery += "SELECT ABB.ABB_FILIAL AB9_FILIAL, ABB.ABB_NUMOS AB9_NUMOS, ' ' AB9_SEQ, ABB.ABB_CODTEC AB9_CODTEC, ABB.ABB_DTINI AB9_DTINI,"
	cQuery += " ABB.ABB_DTFIM AB9_DTFIM,' ' AB9_CODCLI, ' ' AB9_LOJA, ' ' AB9_CONTRT, "
	cQuery += " AA1.AA1_CDFUNC,AA1.AA1_FUNFIL,AA1.AA1_CC,AA1.AA1_TURNO,AA1.AA1_MPONTO, ABB.ABB_CODIGO, ABB.ABB_LOCAL, "
	If lGSHRPon
		cQuery += " CASE WHEN ABB.ABB_HRCHIN = '' OR ABB.ABB_HRCHIN IS NULL OR ABB.ABB_HRCOUT = '' OR ABB.ABB_HRCOUT IS NULL THEN ABB.ABB_HRINI ELSE ABB.ABB_HRCHIN END AB9_HRINI, "
		cQuery += " CASE WHEN ABB.ABB_HRCHIN = '' OR ABB.ABB_HRCHIN IS NULL OR ABB.ABB_HRCOUT = '' OR ABB.ABB_HRCOUT IS NULL THEN ABB.ABB_HRFIM ELSE ABB.ABB_HRCOUT END AB9_HRFIM, "
		cQuery += " ABB_HRCHIN, ABB_HRCOUT,"
	Else
		cQuery += " ABB.ABB_HRINI AB9_HRINI, ABB.ABB_HRFIM AB9_HRFIM, "
	EndIf
	If lGSxInt
		cQuery += " ABB.ABB_TIPOMV, TDV.TDV_CODABB, AA1.AA1_NOMTEC, "
	EndIf
	If lBaseOp
		cQuery += " ABS.ABS_FILIAL, ABS.ABS_CCUSTO, ABS.ABS_LOCAL, ABS.ABS_BASEOP, ABS.ABS_REGRA, SRJ.RJ_FILIAL, SRJ.RJ_FUNCAO, "
	EndIf
	cQuery += " ABB.R_E_C_N_O_ AB9RECNO, TDV.TDV_TURNO, TDV.TDV_SEQTRN, TDV.TDV_DTREF, TDV.TDV_FILIAL, TDV.TDV_TURNO "
	cQuery += " , TDV.TDV_HRMAI, TDV.TDV_HRMEN, TDV.TDV_TPDIA, TDV.R_E_C_N_O_ RECTDV, TDV.TDV_INTVL1 "
	//Base Operacional e CCT
	If lBaseOp
		cQuery += ",ABQ.ABQ_CODTFF "
	EndIf
	cQuery += " FROM "  + RetSqlName( "ABB" ) + " ABB "
	cQuery += " INNER JOIN "  + RetSqlName( "AA1" ) + " AA1 ON "
	cQuery += " AA1.AA1_FILIAL='" + xFilial("AA1") +"' AND "
	cQuery += " AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	cQuery += " INNER JOIN "  + RetSqlName( "TDV" ) + " TDV ON "
	If !lMultFil
		cQuery += " TDV.TDV_FILIAL='" + xFilial("TDV") +"' "
	Else
		If lMVPar10 .AND. MV_PAR10 == 2 .AND. !Empty(cFilQuery)
			If lMVFil
				cQuery += " " + cFilQuery + " AND "
			Else
				cQuery += " TDV.TDV_FILIAL " + cFilQuery + " AND "
			EndIf
		EndIf
		cQuery += FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.)
	EndIf
	cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
	cQuery += TECStrExpBlq("ABB")

	//Base Operacional e CCT
	If lBaseOp
		cQuery += " INNER JOIN " + RetSqlName("ABQ") + " ABQ ON "
		If lMultFil
			cQuery += FWJoinFilial("ABQ" , "ABB" , "ABQ", "ABB", .T.)
		Else
			cQuery += " ABQ.ABQ_FILIAL = '" + xfilial("ABQ") + "' "
		EndIf
		cQuery += " AND ABQ.ABQ_CONTRT||ABQ.ABQ_ITEM||ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL "
		cQuery += " AND ABQ.D_E_L_E_T_= ' ' "

		cQuery += " INNER JOIN "  + RetSqlName( "SRJ" ) + " SRJ ON "
		cQuery += " SRJ.RJ_FUNCAO = ABQ.ABQ_FUNCAO AND "
		If lMultFil
			cQuery += " " + FWJoinFilial("SRJ" , "ABQ" , "SRJ", "ABQ", .T.) + " "
		Else
			cQuery += " SRJ.RJ_FILIAL = '" + xfilial("SRJ") + "' "
		EndIf
		cQuery += " AND SRJ.D_E_L_E_T_=' ' "

		cQuery += " INNER JOIN "  + RetSqlName( "ABS" ) + " ABS ON "
		cQuery += " ABS.ABS_LOCAL = ABB.ABB_LOCAL AND "
		If !lMultFil
			cQuery += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
		Else
			cQuery += " " + FWJoinFilial("ABS" , "ABB" , "ABS", "ABB", .T.) + " "
		EndIf
		cQuery += " AND ABS.D_E_L_E_T_=' ' "
	EndIf

	cQuery += " WHERE "
	If !lMultFil
		cQuery += " ABB.ABB_FILIAL='" + xFilial( "ABB" ) + "' AND "
	EndIf
	cQuery += " AA1.AA1_MPONTO <> '1' AND "
	cQuery += " ABB.ABB_NUMOS ='" + SPACE(TamSX3("ABB_NUMOS")[1]) + "' AND "
	cQuery += " ABB.ABB_CHEGOU ='S' AND "
	cQuery += " ABB.ABB_ATENDE ='1' AND "

	//Filtra Tecnico
	If Empty(aAtendentes)
		If !Empty(MV_PAR01)
			cQuery += " ABB.ABB_CODTEC >='" +  MV_PAR01 + "' AND "
		EndIf
		If !Empty(MV_PAR02)
			cQuery += " ABB.ABB_CODTEC <='" +  MV_PAR02 + "' AND "
		EndIf
	Else
		cQuery += " ABB.ABB_CODTEC IN ( "
		For nX := 1 to LEN(aAtendentes)
			cQuery += " '" + aAtendentes[nX] + "',"
		Next nX
		cQuery := LEFT(cQuery, LEN(cQuery) - 1)
		cQuery += " ) AND "
	EndIf

	//Filtra Data de Inicio
	If !Empty(MV_PAR03)
		cQuery += " TDV.TDV_DTREF >='" + DToS( MV_PAR03 ) + "' AND "
	EndIf
	If !Empty(MV_PAR04)
		cQuery += " TDV.TDV_DTREF <='" + DToS( MV_PAR04 ) + "' AND "
	EndIf

	//Filtra Marcacao conforme processamento
	cQuery += " ABB.ABB_MPONTO = '"+Iif(MV_PAR05==1,'F','T')+"' AND "

	//Filtra marcacao conforme o Local de Atendimento
	If lMVPar08 .AND. !Empty(MV_PAR08)
		cQuery += " ABB.ABB_LOCAL >='" + MV_PAR08 + "' AND "
	EndIf
	If lMVPar09 .AND. !Empty(MV_PAR09)
		cQuery += " ABB.ABB_LOCAL <='" + MV_PAR09 + "' AND "
	EndIf

	cQuery	+= TECStrExpBlq("ABB",,,2)
	cQuery += " ABB.D_E_L_E_T_=' ' AND ABB.ABB_ATIVO = '1' "
	cQuery += " AND AA1.D_E_L_E_T_=' ' "
	cQuery += " AND TDV.D_E_L_E_T_=' ' "

	cQuery += "ORDER BY ABB.ABB_CODTEC,ABB.ABB_DTINI"

Endif

If ExistBlock("At910Qry")
	cQuery := ExecBlock("At910Qry", .F., .F., {cQuery})
EndIf

Return( cQuery )
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910PMarc()

Ordena o array com as datas e horarios iniciais e finais

		Estrutura do Array aRetorno
		[nX][1]	- Codigo do Atendente(Caracter)
		[nX][2]	- Dia Inicial da marcação(Data)
		[nX][3]	- Horario Inicial(Caracter)
		[nX][4]	- Dia Final(Data)
		[nX][5]	- Horario Final(Caracter)
		[nX][6]	- Codigo da Matricula(Caracter)
		[nX][7]	- Filial do Funcionario(Caracter)
		[nX][8]	- Numero da O.S.(Caracter)
		[nX][9]	- Codigo do Cliente(Caracter)
		[nX][10]	- Loja do Cliente(Caracter)
		[nX][11]	- Recno AB9(Numerico)

@param ExpA:Array contendo os atendimentos

@return ExpA: Array ordenado de acordo com as datas e horarios
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At910PMarc(aRetorno, lGeraMarcInt, aRet)
Local nX			:= 0
Local aMarcacao		:= {}	//Marcacoes Tratadas
Local aRecno		:= {}	//Array com os Recnos que serao atualizados
Local cCodTec		:= ""
Local dMarcIni		:= CtoD("  /  /    ")
Local cMarcIni		:= ""
Local dMarcFim		:= CtoD("  /  /    ")
Local cMarcRef		:= ""
Local cMarcFim		:= ""
Local cCodFunc		:= ""
Local cFilFun		:= ""
Local cCliente		:= ""
Local cLoja			:= ""
Local cNumOs		:= ""
Local lMV_GSXINT	:= SuperGetMv("MV_GSXINT",,"2") <> "2"
Local nColMarc		:= SuperGetMv("MV_COLMARC",,4)  //limite de colunas do relatório
Local nColunas		:= 0
Local nTamRet 		:=  Len(aRetorno)
Local lPrimeira 	:= .T.
Local lUltimo	 	:= .T.
Local lEnviou		:= .F.
//Com o parametro MV_GSHRPON ativo, verifica se os campos ABB_HRCHIN e ABB_HRCOUT estão preenchidos para utilizar os minutos aleatorios.
Local lGSHRPon		:= SuperGetMV("MV_GSHRPON",.F., "2") == "1" .AND. ( ABB->(ColumnPos('ABB_HRCHIN')) > 0 )
Local lHrIniInt		:= .T.
Local lHrFimInt		:= .T.
Local cFilCCT		:= ""
Local cCodCCT		:= ""
Local cTurno		:= ""
Local cFuncao		:= ""
Local cRegra		:= ""
Local cCusto		:= ""

Default lGeraMarcInt := .T.

If !lGeraMarcInt .OR. (!lMV_GSXINT .and. nColMarc > 0)
	For nX := 1 To nTamRet
		lEnviou	:= .F.

		If !lGeraMarcInt
			//Quando inicia, muda o tecnico ou muda o dia inicial ou final da marcacao
			If cCodTec != aRetorno[nX][1] .OR. dMarcIni != aRetorno[nX][2]
				//Quando mudar adiciona a marcacao antes de reiniciar as variaveis desde que nao seja a ultima vez no loop
				If nX != 1
					AAdd(aMarcacao,{cCodTec,dMarcIni,cMarcIni,dMarcFim,cMarcFim,cCodFunc,cFilFun,cCliente,cLoja,cNumOs,aRecno, lHrIniInt, lHrFimInt,cFilCCT,cCodCCT,cTurno,cFuncao,cRegra,cCusto})
					nColunas := 0
				EndIf
				cCodTec		:= aRetorno[nX][1]
				dMarcIni	:= aRetorno[nX][2]
				cMarcIni	:= aRetorno[nX][3]
				dMarcFim	:= aRetorno[nX][4]
				cMarcFim	:= aRetorno[nX][5]
				cCodFunc	:= aRetorno[nX][6]
				cFilFun		:= aRetorno[nX][7]
				cCliente	:= aRetorno[nX][8]
				cLoja		:= aRetorno[nX][9]
				cNumOs		:= aRetorno[nX][10]
				aRecno		:= {aRetorno[nX][11]}	//Quando inicia limpa o recno
				cTurno		:= aRetorno[nX][19]
				cFuncao		:= aRetorno[nX][20]
				cRegra		:= aRetorno[nX][21]
				cCusto 		:= aRetorno[nX][22]
				nColunas++
			Else
				//Quando é o mesmo tecnico e mesmo dia verifica a data/hora fim da Marcacao

				nColunas++
				AAdd(aRecno,aRetorno[nX][11])

				If  DToS(dMarcFim)+cMarcFim < DToS(aRetorno[nX][4])+aRetorno[nX][5]
					dMarcFim := aRetorno[nX][4]
					cMarcFim := aRetorno[nX][5]
				EndIf
			EndIf
			If lBaseOp
				cFilCCT := aRetorno[nX][17]
				cCodCCT	:= aRetorno[nX][18]
			EndIf
			//Adiciona o último registro na marcação
			If nX == nTamRet //Quando mudar adiciona a marcacao antes de reiniciar as variaveis
				AAdd(aMarcacao,{cCodTec,dMarcIni,cMarcIni,dMarcFim,cMarcFim,cCodFunc,cFilFun,cCliente,cLoja,cNumOs,aClone(aRecno), lHrIniInt, lHrFimInt,cFilCCT,cCodCCT,cTurno,cFuncao,cRegra,cCusto})
			EndIf
		Else
			If nColunas <= nColMarc
				If !lPrimeira .AND. !lEnviou
					AAdd(aMarcacao,{cCodTec,dMarcIni,cMarcIni,dMarcFim,cMarcFim,cCodFunc,cFilFun,cCliente,cLoja,cNumOs,aClone(aRecno), lHrIniInt, lHrFimInt,cFilCCT,cCodCCT,cTurno,cFuncao,cRegra,cCusto})
				EndIf
			Else
				At910Log(,aRetorno[nX],STR0038+AllTrim(Str(nColMarc)) + STR0039 ,aRet) //"O Atendente possui mais de "##" marcaçoes para a data de referencia. Esta marcação será ignorada"
			EndIf
			If cCodTec != aRetorno[nX][1] .OR. cMarcRef != aRetorno[nX][12] //Conta as marcacoes a partir da data de referencia
				nColunas 	:= 0
				cMarcRef	:=  aRetorno[nX][12]
				cCodTec 	:= aRetorno[nX][1]
			EndIf

			nColunas++

			dMarcIni	:= aRetorno[nX][2]
			cMarcIni	:= aRetorno[nX][3]
			dMarcFim	:= aRetorno[nX][4]
			cMarcFim	:= aRetorno[nX][5]
			cCodFunc	:= aRetorno[nX][6]
			cFilFun		:= aRetorno[nX][7]
			cCliente	:= aRetorno[nX][8]
			cLoja		:= aRetorno[nX][9]
			cNumOs		:= aRetorno[nX][10]
			aRecno		:= {aRetorno[nX][11]}
			cTurno		:= aRetorno[nX][19]
			cFuncao		:= aRetorno[nX][20]
			cRegra		:= aRetorno[nX][21]
			cCusto 		:= aRetorno[nX][22]
			If lGSHRPon
				lHrIniInt	:= Empty(aRetorno[nX][14])
				lHrFimInt	:= Empty(aRetorno[nX][15])
			EndIf
			If lBaseOp
				cFilCCT := aRetorno[nX][17]
				cCodCCT	:= aRetorno[nX][18]
			EndIf
			//Quando inicia limpa o recno
			lPrimeira := .F.
			lUltimo := .F.
			If nX == nTamRet 	//Quando mudar adiciona a marcacao antes de reiniciar as variaveis
				AAdd(aMarcacao,{cCodTec,dMarcIni,cMarcIni,dMarcFim,cMarcFim,cCodFunc,cFilFun,cCliente,cLoja,cNumOs,aClone(aRecno), lHrIniInt, lHrFimInt,cFilCCT,cCodCCT,cTurno,cFuncao,cRegra,cCusto})
			EndIf
		EndIf
	Next nX
Else
	aMarcacao := aClone(aRetorno)
EndIf

Return(aMarcacao)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910Marca()

Inclui via ExecAuto a Marcacao no POnto Eletronico

@param ExpA:Array contendo os dados para a ExecAuto
@param ExpC:Mensagem de Critica (Passar por referencia. Ira alterar com a mensagem quando houver erro)

@return ExpL: Retorna .T. quando há sucesso na operação
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At910Marca(aMarcacao,cMsg,cTpExp, nHandle, lCab, nHandle2,aEmpFil)
Local lRet		:= .T.	//Retorno da função
Local lExiste	:= .F.
Local aCabec	:= {}
Local aLinha	:= {}
Local aItens	:= {}
Local aRetInc 	:= {}
Local aFuncTr	:= {}
Local nOpc		:= Iif(MV_PAR05==1,3,5)
Local nMsg		:= 0
Local nI		:= 1
Local nX		:= 1
Local nPosMat	:= 0
Local cFilProc 	:= ""
Local cFilSave  := cFilAnt
Local cCodMat	:= ""
Local cTurnoP	:= ""
Local cRegra	:= ""
Local cSeqIni	:= ""
Local cCusto	:= ""
Local aRet		:= {} //Retorno do Ponto de entrada
Local cGSxInt 	:= SuperGetMv("MV_GSXINT",,"2")
Local aDelTurno	:= {}
Local cQrySPF	:= ""
Local cAlsSPF	:= ""
Local lNaoRegra := .T.
Local dPerIni   := stod("")
Local dPerFim   := stod("")
Local nMk		:= 0
Local aErro160	:= {}

Default cMsg 		:= ""
Default cTpExp 		:= "1"
Default nHandle 	:= 0
Default lCab 		:= .f.
Default nHandle2 	:= 0
Default aEmpFil 	:= {}

If Len(aMarcacao) > 0
	AAdd(aCabec,{"RA_FILIAL"	,aMarcacao[1][7]})
	AAdd(aCabec,{"RA_MAT" 	,aMarcacao[1][6]})
EndIf

If nOpc == 5 .AND. ("1" $ cTpExp .AND. cGSxInt == "2") //se for exclusão , retorna a marcação da SP8 por causa dos minutos aleatorios
	DbSelectArea("SP8")
	DbSetOrder(2) // P8_FILIAL+P8_MAT+DTOS(P8_DATA)+STR(P8_HORA,5,2)

	For nI := 1 To Len(aMarcacao)
		If SP8->(DbSeek(aMarcacao[nI][7] + aMarcacao[nI][6] + DTOS(aMarcacao[nI][2])))
			While SP8->(P8_FILIAL + P8_MAT + DTOS(P8_DATA) ) == aMarcacao[nI][7] + aMarcacao[nI][6] + DTOS(aMarcacao[nI][2]) .and. SP8->(!EOF())
				For nX := 1 to len(aItens)
					nPosFil	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_FILIAL)	, x[2] == SP8->P8_FILIAL , 0) })
					nPosMat	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_MAT)		, x[2] == SP8->P8_MAT , 0) })
					nPosDat	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_DATA)		, x[2] == SP8->P8_DATA , 0) })
					nPosHor	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_HORA)		, x[2] == SP8->P8_HORA , 0) })
					If nPosFil > 0 .and. nPosMat > 0 .and. nPosDat > 0 .and. nPosHor > 0
						lExiste := .T.
						Exit
					Else
						lExiste := .F.
					EndIf
				Next

				If !lExiste
					aLinha := {}
					// Entrada
					AAdd(aLinha,{"P8_FILIAL"	,aMarcacao[nI][7]})
					AAdd(aLinha,{"P8_MAT"		,aMarcacao[nI][6]})
					AAdd(aLinha,{"P8_DATA"		,aMarcacao[nI][2]})
					AAdd(aLinha,{"P8_HORA"		,SP8->P8_HORA})
					AAdd(aItens,aLinha)
				EndIf
				SP8->(dbskip())
			EndDo
		EndIf

		If SP8->(DbSeek(aMarcacao[nI][7]  + aMarcacao[nI][6] + DTOS(aMarcacao[nI][4])))
			While SP8->(P8_FILIAL + P8_MAT + DTOS(P8_DATA) ) == aMarcacao[nI][7] + aMarcacao[nI][6] + DTOS(aMarcacao[nI][4]) .and. SP8->(!EOF())
				For nX := 1 to len(aItens)
					nPosFil	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_FILIAL), x[2] == SP8->P8_FILIAL , 0) })
					nPosMat	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_MAT), x[2] == SP8->P8_MAT , 0) })
					nPosDat	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_DATA), x[2] == SP8->P8_DATA , 0) })
					nPosHor	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_HORA), x[2] == SP8->P8_HORA , 0) })
					If nPosFil > 0 .and. nPosMat > 0 .and. nPosDat > 0 .and. nPosHor > 0
						lExiste := .T.
						Exit
					Else
						lExiste := .F.
					EndIf
				Next

				If !lExiste
					aLinha := {}
					// Saida
					AAdd(aLinha,{"P8_FILIAL"	,aMarcacao[nI][7]})
					AAdd(aLinha,{"P8_MAT"		,aMarcacao[nI][6]})
					AAdd(aLinha,{"P8_DATA"		,aMarcacao[nI][4]})
					AAdd(aLinha,{"P8_HORA"		,SP8->P8_HORA})
					AAdd(aItens,aLinha)
				EndIf
				SP8->(dbskip())
			EndDo
		EndIf
	Next nI

Else

	For nI := 1 To Len(aMarcacao)

		aLinha := {}

		//Entrada
		AAdd(aLinha,{"P8_FILIAL"	,aMarcacao[nI][7]})
		AAdd(aLinha,{"P8_MAT"		,aMarcacao[nI][6]})
		AAdd(aLinha,{"P8_DATA"		,aMarcacao[nI][2]})
		AAdd(aLinha,{"P8_HORA"		,Val(StrTran(aMarcacao[nI][3],":","."))})
		AAdd(aLinha,{"P8_TURNO"		,aMarcacao[nI][16]})
		If cCodMat <> aMarcacao[nI][6]
			cFilProc := aMarcacao[nI][7]
			cCodMat	:= aMarcacao[nI][6]
			cTurnoP	:= POSICIONE("SRA",1,aMarcacao[1][7] + aMarcacao[nI][6], "RA_TNOTRAB")
			cRegra	:= POSICIONE("SRA",1,aMarcacao[1][7] + aMarcacao[nI][6], "RA_REGRA")
			cSeqIni := POSICIONE("SRA",1,aMarcacao[1][7] + aMarcacao[nI][6], "RA_SEQTURN")
			cCusto	:= POSICIONE("SRA",1,aMarcacao[1][7] + aMarcacao[nI][6], "RA_CC")
		EndIf
		If lBaseOp
			AAdd(aLinha,{"P8_FILCCT"		,aMarcacao[nI][14]})
			AAdd(aLinha,{"P8_CODCCT"		,aMarcacao[nI][15]})
		EndIf

		If SP8->( FieldPos( 'P8_FUNCTRA' ) )  > 0
			AAdd(aLinha,{"P8_FUNCTRA"		,aMarcacao[nI][17]})
		EndIf
		
		If !Empty(aMarcacao[nI][19]) .AND. cCusto <> aMarcacao[nI][19]
			AAdd(aLinha,{"P8_CC"		, aMarcacao[nI][19]})
		Else
			AAdd(aLinha,{"P8_CC"		, cCusto})
		EndIf
		
		AAdd(aItens,aLinha)

		aLinha := {}

		//Saida
		AAdd(aLinha,{"P8_FILIAL"	,aMarcacao[nI][7]})
		AAdd(aLinha,{"P8_MAT"		,aMarcacao[nI][6]})
		AAdd(aLinha,{"P8_DATA"		,aMarcacao[nI][4]})
		AAdd(aLinha,{"P8_HORA"		,Val(StrTran(aMarcacao[nI][5],":","."))})
		AAdd(aLinha,{"P8_TURNO"		,aMarcacao[nI][16]})

		If lBaseOp
			AAdd(aLinha,{"P8_FILCCT"		,aMarcacao[nI][14]})
			AAdd(aLinha,{"P8_CODCCT"		,aMarcacao[nI][15]})
		EndIf

		If SP8->( FieldPos('P8_FUNCTRA') ) > 0
			AAdd(aLinha,{"P8_FUNCTRA"		,aMarcacao[nI][17]})
		EndIf

		If !Empty(aMarcacao[nI][19]) .AND. cCusto <> aMarcacao[nI][19]
			AAdd(aLinha,{"P8_CC"		, aMarcacao[nI][19]})
		Else
			AAdd(aLinha,{"P8_CC"		, cCusto})
		EndIf

		AAdd(aItens,aLinha)

		lNaoRegra:= .T.
		If cTurnoP <> aMarcacao[nI][16]
			cTurnoP := aMarcacao[nI][16]
			If !Empty(aMarcacao[nI][18]) .AND. cRegra <> aMarcacao[nI][18]
				cRegra:= aMarcacao[nI][18]
			EndIf
			AADD(aFuncTr, { {aMarcacao[1][7] + aMarcacao[nI][6]}, {aMarcacao[nI][2], aMarcacao[nI][16], cSeqIni, cRegra, "Alteração de escala no Gestão de Serviços", aMarcacao[1][7]}})
			lNaoRegra:= .F.
		EndIf

		If lNaoRegra .And. !Empty(aMarcacao[nI][18]) .AND. cRegra <> aMarcacao[nI][18]
			cRegra:= aMarcacao[nI][18]
			AADD(aFuncTr, { {aMarcacao[1][7] + aMarcacao[nI][6]}, {aMarcacao[nI][2], aMarcacao[nI][16], cSeqIni, cRegra, "Alteração de escala no Gestão de Serviços", aMarcacao[1][7]}})
		EndIf

	Next nI
EndIf

aItens := AglutinaP8(aCabec , aItens , aMarcacao, MV_PAR13)

If ExistBlock("At910Ma")
	aRet := ExecBlock("At910Ma", .F., .F., {aCabec, aItens, nOpc, cTpExp})
	If Len(aRet) > 1 .and. Valtype(aRet[1]) = "A" .AND. ValType(aRet[2]) == "A"
		aCabec := aClone(aRet[1])
		aItens := aClone(aRet[2])
	EndIf
EndIf

Begin Transaction
	If "1" $ cTpExp .and. cGSxInt == "2"

		aRetInc := Ponm010(		.F.				,;	//01 -> Se o "Start" foi via WorkFlow
								.F. 			,;	//02 -> Se deve considerar as configuracoes dos parametros do usuario
								.T.				,;	//03 -> Se deve limitar a Data Final de Apontamento a Data Base
								cFilProc		,;	//04 -> Filial a Ser Processada
								.F.				,;	//05 -> Processo por Filial
								.F.				,;	//06 -> Apontar quando nao Leu as Marcacoes para a Filial
								.F.				,;	//07 -> Se deve Forcar o Reapontamento
								aCabec			,;
								aItens			,;
								nOpc    		,;
								)

		If Len(aRetInc) > 0 .And. !(aRetInc[1])
			cMsg := ""
			For nMsg := 1 to Len(aRetInc[2])
				cMsg += aRetInc[2,nMsg] + CRLF
			Next
			lRet := .F.
		EndIf
		IF nOpc == 5
			If lRet
				cAlsSPF:= GetNextAlias()
				
				cQrySPF:= " Select PF_DATA,PF_TURNODE,PF_SEQUEDE,PF_REGRADE,PF_TURNOPA,PF_SEQUEPA,PF_REGRAPA,PF_TRFOBS,PF_INTGTAF,PF_TAFKEY,R_E_C_N_O_ RecSPF "
				cQrySPF+= " FROM " + RetSqlName("SPF") + " SPF "
				cQrySPF+= " WHERE PF_FILIAL ='"+aCabec[1][2]+"' AND PF_MAT='"+aCabec[2][2]+"' AND "
				cQrySPF+= " PF_DATA >='"+ DToS(MV_PAR03) +"' AND PF_DATA <='"+ DToS(MV_PAR04) +"' AND SPF.D_E_L_E_T_=' ' "
				cQrySPF+= " ORDER BY SPF.R_E_C_N_O_ DESC "
				
				cQrySPF := ChangeQuery(cQrySPF)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySPF),cAlsSPF, .F., .T.)
				While !(cAlsSPF)->(EOF())
					aDelTurno:={}
					AADD( aDelTurno ,{ aCabec[1][2]+aCabec[2][2], {	{StoD((cAlsSPF)->PF_DATA),StoD((cAlsSPF)->PF_DATA)}, {(cAlsSPF)->PF_TURNODE,(cAlsSPF)->PF_TURNODE}, {(cAlsSPF)->PF_SEQUEDE,(cAlsSPF)->PF_SEQUEDE},;
																	{(cAlsSPF)->PF_REGRADE,(cAlsSPF)->PF_REGRADE}, {(cAlsSPF)->PF_TURNOPA,(cAlsSPF)->PF_TURNOPA}, {(cAlsSPF)->PF_SEQUEPA,(cAlsSPF)->PF_SEQUEPA},;
																	{(cAlsSPF)->PF_REGRAPA,(cAlsSPF)->PF_REGRAPA}, {(cAlsSPF)->PF_TRFOBS,(cAlsSPF)->PF_TRFOBS}, {(cAlsSPF)->PF_INTGTAF,(cAlsSPF)->PF_INTGTAF},;
																	{(cAlsSPF)->PF_TAFKEY,(cAlsSPF)->PF_TAFKEY}, {"SPF","SPF"}, {(cAlsSPF)->RecSPF,(cAlsSPF)->RecSPF}} })
					Pona160(aDelTurno[1], 4)
				 (cAlsSPF)->(DbSkip())
				EndDo
				(cAlsSPF)->(DbCloseArea())
			EndIf
		Else
			If lRet
				GetPonMesDat( @dPerIni, @dPerFim, aCabec[1][2] ) //Somente se dentro do periodo aberto de apontamento
				If Type("INCLUI") == "U"
					INCLUI := .F.
				EndIf
				For nI := 1 To Len(aFuncTr)
					If aFuncTr[nI,2,1] <= dPerFim .Or. Empty(dPerFim)
						cFilAnt := aFuncTr[nI,2,6]
						aErro160:= PON160lot(aFuncTr[nI]) //Envia troca de turno
						cFilAnt := cFilSave
						If Len(aErro160) > 0
							For nMk:=1 To Len(aErro160)
								cMsg += aErro160[nMk]+ CRLF
							Next nMk
							lRet:= .F.
						EndIf
					EndIf
				Next nI
			EndIf
		EndIf
	EndIf
End Transaction
If "1" $ cTpExp .AND. cGSxInt == "3" .AND. nOpc == 3 .and. nHandle2 > 0  .AND. Len(aEmpFil) > 0 //envia para a RM
	aRetInc :=  At910MCSV({}, aItens,nHandle2, .f., cGSxInt, aEmpFil )
EndIf

If "2" $ cTpExp
	aRetInc := ExecBlock("At910CMa", .F., .F., {aCabec, aItens, nOpc, lCab})
	If Len(aRetInc) > 0 .And. !(aRetInc[1])
		For nMsg := 1 to Len(aRetInc[2])
			cMsg += aRetInc[2,nMsg] + CRLF
		Next
		lRet := .F.
	EndIf
EndIf
If "3"$ cTpExp .AND. nHandle > 0
	aRetInc :=  At910MCSV(aCabec, aItens,nHandle, lCab )

	If Len(aRetInc) > 0 .And. !(aRetInc[1])
		For nMsg := 1 to Len(aRetInc[2])
			cMsg += aRetInc[2,nMsg] + CRLF
		Next
		lRet := .F.
	EndIf
EndIf

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910AtAB9()

Atualiza o Atendimento para informar que já foi gerado Marcacao

@param ExpC:Recno do Atendimento que será atualizado

@return ExpL: Retorna .T. a atualização aconteceu com sucesso
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At910AtAB9(xRecno, lMarca)
Local nI			:= 0
Local aRecnoAB9		:= {}
Local lGsGerOs	 	:= SuperGetMV("MV_GSGEROS",.F.,"1") == "1" //Gera O.S na rotina de geração de atendimento do gestão de serviços 1 = Sim e 2 = Não.

Default lMarca	:= MV_PAR05 == 1
If ValType(xRecno) != "A"
	aRecnoAB9 := {xRecno}
Else
	aRecnoAB9 := xRecno
EndIf

For nI := 1 To Len(aRecnoAB9)
	If lGsGerOs
		AB9->( DBGOTO(aRecnoAB9[nI]) )
		RecLock("AB9", .F.)
		AB9_MPONTO	:= lMarca	//Gerou Marcação ".T." - Sim ; ".F." - Não
		AB9->( MsUnLock() )
	Else
		ABB->( DBGOTO(aRecnoAB9[nI]) )
		RecLock("ABB", .F.)
		ABB_MPONTO	:= lMarca	//Gerou Marcação ".T." - Sim ; ".F." - Não
		ABB->( MsUnLock() )
	Endif

Next nI

Return(.T.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910Log()

Adiciona dados do registro em processamento quando houver crítica.

@param ExpA:Array com as criticas de todo o processamento.
@param Expc:Alias da tabela do processamento.
@param cMsg:Mensagem de critica do registro corrente.

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At910Log(cAlias,aMarcacao,cMsg,aRet,cFilTec,nThread)
Local cText    := ""
Local cRecno   := ""
Local cFolder  := ""
Local lGsGerOs := SuperGetMV("MV_GSGEROS",.F.,"1") == "1" //Gera O.S na rotina de geração de atendimento do gestão de serviços 1 = Sim e 2 = Não.
Local lFolder  := TecHasPerg("MV_PAR14","TEC910B")

Default cAlias    := ""
Default aMarcacao := {}
Default aRet    := {.T.,{}}
Default cFilTec := cFilant
Default nThread := 1

If !Empty(cAlias)
	If lGsGerOs
		//"Crítica ao processar : R_E_C_N_O_ "
		cText += STR0026+cValToChar((cAlias)->AB9RECNO)+CRLF;
		+" "+RetTitle("AB9_CODTEC")+":"+(cAlias)->AB9_CODTEC+CRLF;
		+" "+RetTitle("AB9_NUMOS")+":"+(cAlias)->AB9_NUMOS+CRLF;
		+" "+RetTitle("AB9_SEQ")+":"+(cAlias)->AB9_SEQ+CRLF;
		+" "+RetTitle("AB9_CODCLI")+":"+(cAlias)->AB9_CODCLI+CRLF;
		+" "+RetTitle("AB9_LOJA")+":"+(cAlias)->AB9_LOJA+CRLF;
		+" "+RetTitle("AB9_DTINI")+":"+DtoC((cAlias)->AB9_DTINI)+CRLF;
		+" "+RetTitle("AB9_HRINI")+":"+(cAlias)->AB9_HRINI+CRLF;
		+" "+RetTitle("AB9_DTFIM")+":"+DToC((cAlias)->AB9_DTFIM)+CRLF;
		+" "+RetTitle("AB9_HRFIM")+":"+(cAlias)->AB9_HRFIM+CRLF;
		+" "+CRLF+cMsg+CRLF
	Else
		//"Crítica ao processar : R_E_C_N_O_ "
		cText += STR0026+cValToChar((cAlias)->AB9RECNO)+CRLF;
		+" "+RetTitle("ABB_CODTEC")+":"+(cAlias)->AB9_CODTEC+CRLF;
		+" "+RetTitle("ABB_DTINI")+":"+DtoC((cAlias)->AB9_DTINI)+CRLF;
		+" "+RetTitle("ABB_HRINI")+":"+(cAlias)->AB9_HRINI+CRLF;
		+" "+RetTitle("ABB_DTFIM")+":"+DToC((cAlias)->AB9_DTFIM)+CRLF;
		+" "+RetTitle("ABB_HRFIM")+":"+(cAlias)->AB9_HRFIM+CRLF;
		+" "+CRLF+cMsg+CRLF
	Endif
EndIf

If Len(aMarcacao) > 0
	If ValType(aMarcacao[11]) == "A"
		AEval(aMarcacao[11],{|x| cRecno += cValToChar(x)+"," })
	Else
		cRecno += cValToChar(aMarcacao[11])
	EndIf

	If lGsGerOs
		//"Crítica execauto de marcação : R_E_C_N_O_ "
		cText += STR0027+cRecno+CRLF;
		+" "+RetTitle("AB9_CODTEC")+":"+aMarcacao[1]+CRLF;
		+" "+RetTitle("AB9_NUMOS")+":"+aMarcacao[10]+CRLF;
		+" "+RetTitle("AB9_CODCLI")+":"+aMarcacao[8]+CRLF;
		+" "+RetTitle("AB9_LOJA")+":"+aMarcacao[9]+CRLF;
		+" "+RetTitle("AA1_CDFUNC")+":"+aMarcacao[6]+CRLF;
		+" "+RetTitle("AA1_FUNFIL")+":"+aMarcacao[7]+CRLF;
		+STR0029+DtoC(aMarcacao[2])+CRLF;  	// " Data Inicio:"
		+STR0030+aMarcacao[3]+CRLF;   			// " Hora Inicio:"
		+STR0031+DToC(aMarcacao[4])+CRLF;   	// "Data Fim:"
		+STR0032+aMarcacao[5]+CRLF;   			// " Hora Fim:"
		+" "+CRLF+cMsg+CRLF
	Else
		//"Crítica execauto de marcação : R_E_C_N_O_ "
		cText += STR0027+cRecno+CRLF;
		+" "+RetTitle("ABB_CODTEC")+":"+aMarcacao[1]+CRLF;
		+" "+RetTitle("AA1_CDFUNC")+":"+aMarcacao[6]+CRLF;
		+" "+RetTitle("AA1_FUNFIL")+":"+aMarcacao[7]+CRLF;
		+STR0029+DtoC(aMarcacao[2])+CRLF;  	// " Data Inicio:"
		+STR0030+aMarcacao[3]+CRLF;   			// " Hora Inicio:"
		+STR0031+DToC(aMarcacao[4])+CRLF;   	// "Data Fim:"
		+STR0032+aMarcacao[5]+CRLF;   			// " Hora Fim:"
		+" "+CRLF+cMsg+CRLF
	Endif
ElseIf Empty(cText) .And. !Empty(cMsg)
	cText := cMsg
EndIf

If lFolder
	cFolder := AllTrim(MV_PAR14)
	If !Empty(cFolder)
		If !ExistDir(cFolder)
			cFolder :=""
		ElseIf Subs(cFolder,Len(cFolder),1) <> "\"
			cFolder += "\"
		EndIf
	EndIf
EndIf

//Cria arquivo de Log
TxLogFile(ALLTRIM(cFilTec)+"-MarcaErro " + cValToChar(nThread),cText,,,,cFolder)
AADD(aRet[2], cText)

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910MCSV
@description Gera o Arquivo CSV das Marcações
@param aCabec: Array Contendo a filial e matricula do atendente
@param aItens:Array de Marcaçoes do atendende do Atendimento que será atualizado
@param nHandle:Handle do Arquivo
@param lCab:Gera o cabeçalho da marcação
@return aRetInc: Array de Retorno da Inclusao onde
		aRetInc[1]  - .t. //sUCESSO
		aRetInc[2]  - Array contendo a mensagem de sucesso/ erro
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At910MCSV(aCabec, aItens, nHandle, lCab, cGSxInt,aEmpFil)
Local aRetInc 	:= {.T., {""}}
Local cCab 		:= ""
Local cDetCab 	:= ""
Local cLinha 	:= ""
Local cDetLinha := ""
Local nC 		:= 0
Local nY 		:= 0
Local lRM		:= .f.
Local cDelimit  := ";"
Local nTamSX3 := TamSx3("AA1_CDFUNC")[1]

lRM := cGSxInt == "3"


For nC := 1 to len(aCabec)
	cCab += AllTrim(aCabec[nC, 01]) +cDelimit
	cDetCab += Alltrim(IIF( ValType(aCabec[nC, 02])<> "D",cValToChar(aCabec[nC, 02])  , DtoS(aCabec[nC, 02])))+cDelimit
Next nC

For nC := 1 to Len(aItens)

	cLinha := cCab
	cDetLinha := cDetCab
	For nY := 1 to Len(aItens[nC])

		If !lRM  .OR. !(AllTrim(aItens[nC, nY, 01]) $ "P8_FILIAL#P8_MAT#P8_HORA")
				cDetLinha +=  Alltrim(IIF( ValType(aItens[nC, nY, 02])<> "D",cValToChar(aItens[nC, nY, 02]) , DtoS(aItens[nC, nY, 02])))+cDelimit
		Else

			If (AllTrim(aItens[nC, nY, 01]) = "P8_FILIAL")
				cDetLinha +=  Alltrim(aEmpFil[01])+cDelimit //Coligada
			ElseIf (AllTrim(aItens[nC, nY, 01]) = "P8_HORA")
				cDetLinha += StrTran(StrZero(aItens[nC, nY, 02],5,2),".", ":")+cDelimit
			ElseIf (AllTrim(aItens[nC, nY, 01]) = "P8_MAT")
				cDetLinha += PadL(AllTrim(aItens[nC, nY, 02]), nTamSX3)+cDelimit
			EndIf
		EndIf
	Next nY
	If lCab
		cLinha := Substr(cLinha, 1, Len(cLinha)-Len(cDelimit)) + CRLF
		fWrite(nHandle, cLinha)
		lCab := .f.
	EndIf

	cDetLinha := Substr(cDetLinha, 1, Len(cDetLinha)-Len(cDelimit)) + CRLF
	fWrite(nHandle, cDetLinha)
Next nC

Return aRetInc

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910RHD
@description  Retorna o Diretório de Exportação do Arquivo CSV da Integração RH
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@return cDirArq - Diretório do server a ser gerado o arquivo
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At910RHD()
Local cDirArq := SuperGetMV("MV_GSRHDIR", .F., "")

If !Empty(cDirArq) .AND. Right(cDirArq, 1) <> "\"
	cDirArq += "\"
EndIf

If !Empty(cDirArq) .AND. Left(cDirArq, 1) <> "\"
	cDirArq := "\" +cDirArq
EndIf

Return cDirArq
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At910RHF
@description Gera o Arquivo CSV das Marcações
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@param cRotina: Prefixo da rotina/aquivo
@param cDirArq:Diretório de gravação do arquivo
@param lDelete: Exclui arquivo caso ele exista?
@param nOpc: Opção da Rotina Automática
@return nHandle - Handle do Arquivo Gerado
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At910RHF(cRotina, cDirArq, lDelete, nOpc, cExtensao)
Local nHandle 	:= 0
Local aDir 		:= {}
Local nC 		:= 0
Local cDirTmp 	:= ""

If !ExistDir(cDirArq)
	aDir := StrTokArr(cDirArq, "\")
	For nC := 1 to Len(aDir)
		cDirTmp += "\" +aDir[nC] +"\"
		MakeDir(cDirTmp)
	Next nC
EndIf

cNomeArq := cDirArq+cRotina+"_"+LTrim(Str(nOpc))+"_"+Dtos(Date())+"_"+StrTran(Time(), ":")+cExtensao

If File(cNomeArq)
	If lDelete
		fErase(cNomeArq)
	Else
		nHandle := FOpen(cNomeArq, FO_READWRITE)
		FSeek(nHandle, 0, 2)
	EndIf
EndIf
If nHandle = 0
	nHandle := fCreate(cNomeArq)
EndIf

Return nHandle

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910ConRM
	Função de verificação da ultima troca de turno cadastrado no RM.

@sample At910ConRM( cCdFunc, lContinua, dDiaIni, cAlias, aEscTGY, lEnvia )
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Function At910ConRM( cCdFunc, dDiaIni, cAliasTGY, aEscTGY, lEnvia, cTDWIniHor, cTDWCodHor, cMsgRM )
Local aRet		:= {}
Local aTurno	:= {}
Local aEmpFil	:= {}
Local cWarning 	:= ""
Local cXml		:= ""
Local cError 	:= ""
Local cHoraIni	:= ""
Local cHoraFim	:= ""
Local nTotal
Local oWS 		:= Nil

DEFAULT	cCdFunc		:= ""
DEFAULT	lContinua	:= .T.
DEFAULT dDiaIni		:= ""
DEFAULT	aEscTGY		:= {}
DEFAULT lEnvia		:= .T.

aEmpFil := GSItEmpFil(, ,  'RM', .T., .F., @cError)
oWS := GSItRMWS("RM", .F., @cError)

If oWS <> NIL
	oWS:cDataServerName := "FopHstHorData"
	If lEnvia
		oWS:cFiltro := "PFHstHor.Chapa='" + cCdFunc + "' and PFHstHor.DtMudanca <= '" + FWTimeStamp(3, dDiaIni, "00:00:00") + "'"
	Else
		oWS:cFiltro := "PFHstHor.Chapa='" + cCdFunc + "' and PFHstHor.CodHorario='" + cTDWCodHor + "' and PFHstHor.IndiniciOHor='" + cTDWIniHor + "'"
	EndIf
	If oWS:ReadView()
		If !Empty(oWS:cReadViewResult)
			cXML := oWS:cReadViewResult
			If cXML <> "<NewDataSet />"
				oXML2 := XMLParser( cXML, "_", @cError, @cWarning)
				aTurno := XmlChildEx ( oXML2:_NEWDATASET, "_PFHSTHOR")
				If ValType(aTurno) <> Nil
					If ValType(aTurno) == "O"
						If lEnvia
							aAdd(aRet, { aTurno:_DTMUDANCA:TEXT,;
									 PADR(aTurno:_CODHORARIO:TEXT, TamSX3("TDW_CODHOR")[1]),;
									 PADR(aTurno:_INDINICIOHOR:TEXT, TamSX3("TDX_INIHOR")[1])})
						Else
							cHoraIni := FWTimeStamp(3, MV_PAR03, "00:00:00")
							cHoraFim := FWTimeStamp(3, MV_PAR04, "00:00:00")
							If cHoraIni <= aTurno:_DTMUDANCA:TEXT .AND. aTurno:_DTMUDANCA:TEXT <= cHoraFim
								aAdd(aRet, { aTurno:_DTMUDANCA:TEXT,;
										 PADR(aTurno:_CODHORARIO:TEXT, TamSX3("TDW_CODHOR")[1]),;
										 PADR(aTurno:_INDINICIOHOR:TEXT, TamSX3("TDX_INIHOR")[1])})
							EndIf
						EndIf
					ElseIf ValType(aTurno) == "A"
						nTotal	:= Len(aTurno)
						If lEnvia
							AADD(aRet, { aTurno[nTotal]:_DTMUDANCA:TEXT,;
								 	 PADR(aTurno[nTotal]:_CODHORARIO:TEXT, TamSX3("TDW_CODHOR")[1]),;
								 	 PADR(aTurno[nTotal]:_INDINICIOHOR:TEXT, TamSX3("TDX_INIHOR")[1])} )
						Else
							cHoraIni := FWTimeStamp(3, MV_PAR03, "00:00:00")
							cHoraFim := FWTimeStamp(3, MV_PAR04, "00:00:00")
							If cHoraIni <= aTurno:_DTMUDANCA:TEXT .AND. aTurno:_DTMUDANCA:TEXT <= cHoraFim
								AADD(aRet, { aTurno[nTotal]:_DTMUDANCA:TEXT,;
								 	 PADR(aTurno[nTotal]:_CODHORARIO:TEXT, TamSX3("TDW_CODHOR")[1]),;
								 	 PADR(aTurno[nTotal]:_INDINICIOHOR:TEXT, TamSX3("TDX_INIHOR")[1])} )
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
If Empty( aRet )
	AADD( aRet, { "", (cAliasTGY)->TDW_CODHOR, (cAliasTGY)->TDX_INIHOR } )
EndIf
If !Empty(cError)
	cMsgRM += CRLF + cError
EndIf
Return ( aRet[1] )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910EnvRM
	Função de envio ou exclusão da escala nova para o RM

@sample At910EnvRM( cCdFunc, cMsgRM, aEscTGY, lEnvia, aEscala )
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Function At910EnvRM( cCdFunc, cMsgRM, aEscTGY, lEnvia, aEscala, cAliasTGY, cDatRef )
Local aEmpFil	:= {}
Local cXml		:= ""
Local cError 	:= ""
Local oWS 		:= Nil

DEFAULT	cCdFunc	:= ""
DEFAULT cMsgRM	:= ""
DEFAULT aEscTGY	:= {}
DEFAULT lEnvia 	:= .T.
DEFAULT aEscala := {}

aEmpFil := GSItEmpFil(, ,  'RM', .T., .F., @cError)
oWS := GSItRMWS("RM", .F., @cError)
/*
Adicionado a função SLEEP para que o FWTimeStamp seja diferente.
Ao enviar não substitua o ultimo registro por conta dos segundos iguais, e sim crie.
Ao deletar para que o processamento não pule o registro no RM.
*/
Sleep(1000)

If oWS <> NIL
	If lEnvia
		cXml := "<FopHstHor>"
			cXml += "<PFHstHor>"
				cXml += "<CODCOLIGADA>" + aEmpFil[1] + "</CODCOLIGADA>"
				cXml += "<CHAPA>" + cCdFunc + "</CHAPA>"
				cXml += "<DTMUDANCA>" + FWTimeStamp( 3, SToD(cDatRef)) + "</DTMUDANCA>"
				cXml += "<CODHORARIO>" + (cAliasTGY)->TDW_CODHOR + "</CODHORARIO>"
				cXml += "<INDINICIOHOR>" + (cAliasTGY)->TDX_INIHOR + "</INDINICIOHOR>"
			cXml += "</PFHstHor>"
		cXml += "</FopHstHor>"
		oWS:cDataServerName := "FopHstHorData"
		oWS:cXML := cXml

		If !(oWS:SaveRecord())
			cMsgRM += STR0042 + cCdFunc + CRLF // "Problema no envio do atendente Chapa(RM): "
			cMsgRM += STR0043 + aEscTGY[1] + STR0044 + (cAliasTGY)->TDW_CODHOR  + CRLF // "Turno: " ## " Codigo Horiario(RM): "
			cMsgRM += STR0045 + aEscTGY[3] + STR0046 +  (cAliasTGY)->TDX_INIHOR + CRLF + CRLF // "Sequencia: " ## " Indice(RM) : "
		EndIf
	Else
		cXml := "<FopHstHor>"
			cXml += "<PFHstHor>"
				cXml += "<CODCOLIGADA>" + aEmpFil[1] + "</CODCOLIGADA>"
				cXml += "<CHAPA>" + cCdFunc + "</CHAPA>"
				cXml += "<DTMUDANCA>" + aEscala[1] + "</DTMUDANCA>"
				cXml += "<CODHORARIO>" + aEscala[2] + "</CODHORARIO>"
				cXml += "<INDINICIOHOR>" + aEscala[3] + "</INDINICIOHOR>"
			cXml += "</PFHstHor>"
		cXml += "</FopHstHor>"
		oWS:cDataServerName := "FopHstHorData"
		oWS:cXML := cXml
		If !(oWS:DeleteRecord())
			cMsgRM += STR0047 + cCdFunc + CRLF // "Problema na exclusão do atendente Chapa(RM): "
			cMsgRM += STR0044 + aEscala[2]  + CRLF // " Codigo Horiario(RM): "
			cMsgRM += STR0046 +  aEscala[3] + CRLF + CRLF // " Indice(RM) : "
		EndIf
	EndIf
EndIf

aEscTGY := {}
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} QryEscala
	Função para retorno da escala do atendente

@sample QryEscala( cAlias )
@author	Augusto.Albuquerque
@since		09/04/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function QryEscala( cAliasTGY, cTurno, cCodABB, cSeq )
Local aArea		:= GetArea()
Local cQuery	:= ""

cQuery := " SELECT TDW.TDW_COD, TDX.TDX_INIHOR, TDW.TDW_CODHOR FROM "  + RetSqlName("TDX") + " TDX "
cQuery += " INNER JOIN " + RetSqlName("TDW") + " TDW "
cQuery += " ON TDW.TDW_FILIAL = '" + xFilial("TDW") + "' "
cQuery += " AND TDW.TDW_COD = TDX.TDX_CODTDW "
cQuery += " INNER JOIN " + RetSqlName("TDV") + " TDV "
cQuery += " ON TDV.TDV_FILIAL = '" + xFilial("TDV") + "' "
cQuery += " WHERE TDX.TDX_FILIAL = '" + xFilial("TDX") + "' "
cQuery += " AND TDX.TDX_TURNO = '" + cTurno + "' "
cQuery += " AND TDX.D_E_L_E_T_ = ' ' "
cQuery += " AND TDV.TDV_CODABB = '" + cCodABB + "' "
cQuery += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "
cQuery += " AND TDW.TDW_STATUS = '1'"
cQuery += " AND TDW.D_E_L_E_T_ = ' ' "
cQuery += " AND TDV.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTGY, .T., .T. )

RestArea(aArea)
Return ( )

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecGetaDad
	Função para retorno do array static para a função TecBOrdMrk

@sample TecGetaDad()
@author	Augusto.Albuquerque
@since		28/12/2020
@version	P12
/*/
//------------------------------------------------------------------------------
Function TecGetaDad()
Return aDados

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910MultP
	Função para criação do msgrun

@sample At910MultP(aMarcTec,cMsg,cTpExp, nHandle, nHandle2, aEmpFil)
@author	Augusto.Albuquerque
@since		20/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Function At910MultP(aMarcTec,cMsg,cTpExp, nHandle, nHandle2, aEmpFil)
Local lRet
FwMsgRun(Nil,{|oSay| lRet := PrepMultTh(aMarcTec,cMsg,cTpExp, nHandle, nHandle2, aEmpFil, oSay)}, "Gerando Marcações", "Executando Threads...") //
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrepMultTh
	Função que prepara para o mult-thread, faz a quebra de acordo com os parametros e inicia o job

@sample PrepMultTh(aMarcTec,cMsg,cTpExp, nHandle, nHandle2, aEmpFil)
@author	Augusto.Albuquerque
@since		20/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function PrepMultTh(aMarcTec,cMsg,cTpExp, nHandle, nHandle2, aEmpFil, oSay)
Local aProcs	:= {}
Local cRaizNome	:= 'TECA910ENV'
Local cFolder	:= ""
Local cLogName	:= ""
Local cFileLog	:= ""
Local nOpc		:= Iif(MV_PAR05==1,3,5)
Local nNumProc 	:= IIF(MV_PAR12 == 0, 5, MV_PAR12)
Local nTotalReg := Len(aMarcTec)
Local nThread	:= 0
Local nX		:= 0
Local lRet		:= .T.
Local lFolder	:= TecHasPerg("MV_PAR14","TEC910B")
Local oGrid		:= Nil

Default oSay	:= Nil

If nNumProc > 40
	nNumProc := 40
Endif

If nNumProc > nTotalReg
	nNumProc := nTotalReg
EndIf

aProcs := TecPrepMarc(nNumProc,nTotalReg,cRaizNome,aMarcTec)
nThread := Len(aProcs)

//Objeto do Controlador de Threads (Instancia para Exec das Threads)
oGrid := FWIPCWait():New("TECA910"+cEmpAnt,5000)

//Inicia as Threads
oGrid:SetThreads(nThread)

//Informa o Ambiente Para Exec da Thread
oGrid:SetEnvironment( cEmpAnt, cFilAnt )

//Funcao para ser executada na Thread
oGrid:Start("At910MaJob")

//Se der erro em alguma Thread sai imediatamente.	
oGrid:SetNoErrorStop(.T.)

For nX := 1 to Len(aProcs)
	oGrid:Go( { aProcs[nX][3], aMarcTec, aProcs[nX][2], aProcs[nX][4], ;
				@cMsg, cTpExp, nHandle, nX == 1, nHandle2, aEmpFil, 0, cFilant, nX,;
				MV_PAR03, MV_PAR04, nOpc, MV_PAR13, dDataBase } )
	oSay:SetText("Threads executadas: "+Str(nX)) //
	ProcessMessages()
Next nX

//Fechamento das Threads Iniciadas (O metodo aguarda o encerramentos de todas as Threads antes de retornar ao controle)
oGrid:Stop()

cError := oGrid:GetError()
FreeObj(oGrid)
oGrid := Nil

// If !Empty(cError)
// 	Help(,,"TECA910THR",,cError,1,0)
// 	lRet := .F.
// EndIf

// Copiar Logs gerados no server para pasta local
If lFolder
	cFolder := AllTrim(MV_PAR14)
	If !Empty(cFolder) .And. ExistDir(cFolder)
		For nX := 1 to Len(aProcs)
			cLogName := AllTrim(cFilant)+"-MarcaErro " + cValToChar(nX)
			cFileLog := TxLogPath(cLogName,.T.,"")
			CpyS2T(cFileLog, cFolder, .T.)
		Next nX
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecPrepMarc
	Função de quebra dos registro por trhead.

@sample TecPrepMarc(nNumProc,nTotalReg,cRaizNome,aRegsProc)
@author	Augusto.Albuquerque
@since		20/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function TecPrepMarc(nNumProc,nTotalReg,cRaizNome,aRegsProc)
Local aProcs 		:= Array(nNumProc)
Local nX		 	:= 0
Local cDirSem  		:= "\Semaforo\"
Local cNomeArq		:= ""
Local cMarca  		:= ""
Local nRegAProc		:= 0 // Registros a processar
Local nRegJProc		:= 0 // Total de registros j?processados
Local cVarStatus	:= ""

//?????????????????????
//?ria a pasta do semaforo caso n? exista?
//?????????????????????
If !ExistDir(cDirSem)
	MontaDir(cDirSem)
EndIf
//?????????????????????????
//?ealiza o calculos das quantidades de registros?
//?ue cada thread ir?processar e                ?
//?????????????????????????
For nX := 1 to Len(aProcs)
	cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX)+cValtoChar(INT(Seconds())) + '.lck'
	cMarca		:= GetMark()
	nRegAProc	:= IIf( nX == 1 , 1 , aProcs[nX-1,4]+1 )
	nRegJProc	+= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
	cVarStatus  :="cNFSP"+cEmpAnt+cFilAnt+StrZero(nX,2)+cMarca
	aProcs[nX]	:= {cNomeArq,nRegAProc,cVarStatus,nRegJProc, cMarca}
Next nX

Return aProcs

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910MaJob
	Função do mult-thread, processamento

@sample At910MaJob(cEmpX,cFilX,cFileLck,cVarStatus,cXUserId,cXUserName,cXAcesso,cXUsuario,aTecIni,nIni, nFim, cMsg,cTpExp, nHandle, lCab, nHandle2,aEmpFil, nHors, cFilTec, nThread)
@author	Augusto.Albuquerque
@since		20/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Function At910MaJob(aJob)
Local lRet       := .T.
Local cVarStatus := aJob[1]
Local aTecIni    := aJob[2]
Local nIni       := aJob[3]
Local nFim       := aJob[4]
Local cMsg       := aJob[5]
Local cTpExp     := aJob[6]
Local nHandle    := aJob[7]
Local lCab       := aJob[8]
Local nHandle2   := aJob[9]
Local aEmpFil    := aJob[10]
Local nHors      := aJob[11]
Local cFilTec    := aJob[12]
Local nThread    := aJob[13]
Local dDtIni     := aJob[14]
Local dDtFim     := aJob[15]
Local nOpc       := aJob[16]
Local cMvPar14   := aJob[17]
Local dBckBase   := aJob[18]

Private lMsErroAuto
Private lMsHelpAuto
Private lAutoErrNoFile

Default nOpc := 3

//Set o usuario para buscar as perguntas do profile
lMsErroAuto := .F.
lMsHelpAuto := .T.
lAutoErrNoFile := .T.

dMVPAR03 := dDtIni
dMVPAR04 := dDtFim

lRet := At930AuxJob(aTecIni,cMsg,cTpExp, nHandle, lCab, nHandle2,aEmpFil, nHors, cFilTec, nIni, nFim, nThread, cVarStatus, .F., nOpc, cMvPar14, dBckBase)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At930AuxJob
	Função de processamento, envia atendente por atendente e faz a confirmação da agenda ou adiciona no txt o erro.

@sample At930AuxJob(aTecIni,cMsg,cTpExp, nHandle, lCab, nHandle2,aEmpFil, nHors, cFilTec, nIni, nFim, nThread)
@author	Augusto.Albuquerque
@since		20/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At930AuxJob(aTecIni,cMsg,cTpExp, nHandle, lCab, nHandle2,aEmpFil, nHors, cFilTec, nIni, nFim, nThread,cVarStatus, lPrincipal, nOpc, cMvPar14, dBckBase)
Local nX, nY
Local lRet := .T.
Local aConcluido	:= {}
Local lInclui := nOpc == 3

Default lPrincipal := .F.

For nX := nIni To nFim
	aConcluido := MarcJobAux(aTecIni[nX][2],cTpExp, nHandle, lCab, nHandle2,aEmpFil, nHors, cFilTec, nThread, nFim - nX, nOpc, cMvPar14, dBckBase)
	If aConcluido[1]
		For nY:=1 To Len(aTecIni[nX][2])
			At910AtAB9(aTecIni[nX][2][nY][11], lInclui)
		Next nY
	Else
		For nY:=1 To Len(aTecIni[nX][2])
			At910Log(,aTecIni[nX][2][nY],aConcluido[2], ,cFilTec, nThread)
		Next nY
	EndIf
Next nX

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MarcJobAux
	Função de processamento, envia para o ponto.

@sample MarcJobAux(aMarcacao,cMsg,cTpExp, nHandle, lCab, nHandle2,aEmpFil, nHors, cFilTec)
@author	Augusto.Albuquerque
@since		20/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function MarcJobAux(aMarcacao,cTpExp, nHandle, lCab, nHandle2,aEmpFil, nHors, cFilTec, nThread, nRest, nOpc, cMvPar14, dBckBase)
Local lRet		:= .T.	//Retorno da função
Local lMV_GSLOG := SuperGetMV('MV_GSLOG',,.F.)
Local lExiste	:= .F.
Local aCabec	:= {}
Local aLinha	:= {}
Local aItens	:= {}
Local aRetInc 	:= {}
Local aRet		:= {} //Retorno do Ponto de entrada
Local nMsg		:= 0
Local nI		:= 1
Local nX		:= 0
Local nPosFil	:= 0
Local nPosMat	:= 0
Local nPosDat	:= 0
Local nPosHor	:= 0
Local cMsg		:= ""
Local cFilProc 	:= ""
Local cFilSave  := cFilAnt
Local oGsLog	:= GsLog():New(lMV_GSLOG)
Local cGSxInt 	:= SuperGetMv("MV_GSXINT",,"2")
Local lFuncBaseOp := FindFunction("TecBaseOp") .And. FindFunction("TecConfCCT")
Local lBaseOpMT	:= lFuncBaseOp .And. TecBaseOp() .And. TecConfCCT() .And. SuperGetMV("MV_GSGEROS",.F.,"1") == "2" //Recria variavel a pois a static está em outra thread
Local cCodMat	:= ""
Local cTurnoP	:= ""
Local cRegra	:= ""
Local cCusto	:= ""
Local cSeqIni	:= ""
Local aFuncTr	:= {}
Local cAlsSPF	:= ""
Local cQrySPF	:= ""
Local aDelTurno	:= {}
Local lNaoRegra := .T.
Local nMk		:= 0
Local aErro160	:= {}

Default cTpExp 		:= "1"
Default nHandle 	:= 0
Default lCab 		:= .f.
Default nHandle2 	:= 0
Default aEmpFil 	:= {}

If Len(aMarcacao) > 0
	AAdd(aCabec,{"RA_FILIAL"	,aMarcacao[1][7]})
	AAdd(aCabec,{"RA_MAT" 	,aMarcacao[1][6]})
	cFilProc := aMarcacao[1][7]
EndIf

If nOpc == 5 .AND. ("1" $ cTpExp .AND. cGSxInt == "2") //se for exclusão , retorna a marcação da SP8 por causa dos minutos aleatorios
	DbSelectArea("SP8")
	DbSetOrder(2) // P8_FILIAL+P8_MAT+DTOS(P8_DATA)+STR(P8_HORA,5,2)

	For nI := 1 To Len(aMarcacao)
		If SP8->(DbSeek(aMarcacao[nI][7] + aMarcacao[nI][6] + DTOS(aMarcacao[nI][2])))
			While SP8->(P8_FILIAL + P8_MAT + DTOS(P8_DATA) ) == aMarcacao[nI][7] + aMarcacao[nI][6] + DTOS(aMarcacao[nI][2]) .and. SP8->(!EOF())
				For nX := 1 to len(aItens)
					nPosFil	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_FILIAL)	, x[2] == SP8->P8_FILIAL , 0) })
					nPosMat	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_MAT)		, x[2] == SP8->P8_MAT , 0) })
					nPosDat	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_DATA)		, x[2] == SP8->P8_DATA , 0) })
					nPosHor	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_HORA)		, x[2] == SP8->P8_HORA , 0) })
					If nPosFil > 0 .and. nPosMat > 0 .and. nPosDat > 0 .and. nPosHor > 0
						lExiste := .T.
						Exit
					Else
						lExiste := .F.
					EndIf
				Next

				If !lExiste
					aLinha := {}
					// Entrada
					AAdd(aLinha,{"P8_FILIAL"	,aMarcacao[nI][7]})
					AAdd(aLinha,{"P8_MAT"		,aMarcacao[nI][6]})
					AAdd(aLinha,{"P8_DATA"		,aMarcacao[nI][2]})
					AAdd(aLinha,{"P8_HORA"		,SP8->P8_HORA})
					AAdd(aItens,aLinha)
				EndIf
				SP8->(dbskip())
			EndDo
		EndIf

		If SP8->(DbSeek(aMarcacao[nI][7]  + aMarcacao[nI][6] + DTOS(aMarcacao[nI][4])))
			While SP8->(P8_FILIAL + P8_MAT + DTOS(P8_DATA) ) == aMarcacao[nI][7] + aMarcacao[nI][6] + DTOS(aMarcacao[nI][4]) .and. SP8->(!EOF())
				For nX := 1 to len(aItens)
					nPosFil	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_FILIAL), x[2] == SP8->P8_FILIAL , 0) })
					nPosMat	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_MAT), x[2] == SP8->P8_MAT , 0) })
					nPosDat	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_DATA), x[2] == SP8->P8_DATA , 0) })
					nPosHor	:= AScan(aItens[nX],{|x| Iif(ValType(x[2]) == ValType(SP8->P8_HORA), x[2] == SP8->P8_HORA , 0) })
					If nPosFil > 0 .and. nPosMat > 0 .and. nPosDat > 0 .and. nPosHor > 0
						lExiste := .T.
						Exit
					Else
						lExiste := .F.
					EndIf
				Next

				If !lExiste
					aLinha := {}
					// Saida
					AAdd(aLinha,{"P8_FILIAL"	,aMarcacao[nI][7]})
					AAdd(aLinha,{"P8_MAT"		,aMarcacao[nI][6]})
					AAdd(aLinha,{"P8_DATA"		,aMarcacao[nI][4]})
					AAdd(aLinha,{"P8_HORA"		,SP8->P8_HORA})
					AAdd(aItens,aLinha)
				EndIf
				SP8->(dbskip())
			EndDo
		EndIf
	Next nI

Else

	For nI := 1 To Len(aMarcacao)

		aLinha := {}

		//Entrada
		AAdd(aLinha,{"P8_FILIAL"	,aMarcacao[nI][7]})
		AAdd(aLinha,{"P8_MAT"		,aMarcacao[nI][6]})
		AAdd(aLinha,{"P8_DATA"		,aMarcacao[nI][2]})
		AAdd(aLinha,{"P8_HORA"	,Val(StrTran(aMarcacao[nI][3],":","."))})
		AAdd(aLinha,{"P8_TURNO"		,aMarcacao[nI][16]})
		If cCodMat <> aMarcacao[nI][6]
			cFilProc:= aMarcacao[nI][7]
			cCodMat	:= aMarcacao[nI][6]
			cTurnoP	:= POSICIONE("SRA",1,aMarcacao[1][7] + aMarcacao[nI][6], "RA_TNOTRAB")
			cRegra	:= POSICIONE("SRA",1,aMarcacao[1][7] + aMarcacao[nI][6], "RA_REGRA")
			cSeqIni := POSICIONE("SRA",1,aMarcacao[1][7] + aMarcacao[nI][6], "RA_SEQTURN")
			cCusto	:= POSICIONE("SRA",1,aMarcacao[1][7] + aMarcacao[nI][6], "RA_CC")
		EndIf

		If lBaseOpMT
			AAdd(aLinha,{"P8_FILCCT"		,aMarcacao[nI][14]})
			AAdd(aLinha,{"P8_CODCCT"		,aMarcacao[nI][15]})
		EndIf
		
		If SP8->( FieldPos('P8_FUNCTRA') ) > 0
			AAdd(aLinha,{"P8_FUNCTRA"		,aMarcacao[nI][17]})
		EndIf

		If !Empty(aMarcacao[nI][19]) .AND. cCusto <> aMarcacao[nI][19]
			AAdd(aLinha,{"P8_CC"		, aMarcacao[nI][19]})
		Else
			AAdd(aLinha,{"P8_CC"		, cCusto})
		EndIf

		AAdd(aItens,aLinha)

		aLinha := {}

		//Saida
		AAdd(aLinha,{"P8_FILIAL"	,aMarcacao[nI][7]})
		AAdd(aLinha,{"P8_MAT"		,aMarcacao[nI][6]})
		AAdd(aLinha,{"P8_DATA"		,aMarcacao[nI][4]})
		AAdd(aLinha,{"P8_HORA"	,Val(StrTran(aMarcacao[nI][5],":","."))})
		AAdd(aLinha,{"P8_TURNO"		,aMarcacao[nI][16]})
		
		If lBaseOpMT
			AAdd(aLinha,{"P8_FILCCT"		,aMarcacao[nI][14]})
			AAdd(aLinha,{"P8_CODCCT"		,aMarcacao[nI][15]})
		EndIf
		
		If SP8->( FieldPos('P8_FUNCTRA') ) > 0
			AAdd(aLinha,{"P8_FUNCTRA"		,aMarcacao[nI][17]})
		EndIf

		If !Empty(aMarcacao[nI][19]) .AND. cCusto <> aMarcacao[nI][19]
			AAdd(aLinha,{"P8_CC"		, aMarcacao[nI][19]})
		Else
			AAdd(aLinha,{"P8_CC"		, cCusto})
		EndIf
		
		AAdd(aItens,aLinha)
		lNaoRegra:= .T.
		If cTurnoP <> aMarcacao[nI][16]
			cTurnoP := aMarcacao[nI][16]
			If !Empty(aMarcacao[nI][18]) .AND. cRegra <> aMarcacao[nI][18]
				cRegra:= aMarcacao[nI][18]
			EndIf
			AADD(aFuncTr, { {aMarcacao[1][7] + aMarcacao[nI][6]}, {aMarcacao[nI][2], aMarcacao[nI][16], cSeqIni, cRegra, "Alteração de escala no Gestão de Serviços", aMarcacao[1][7]}})
			lNaoRegra:= .F.
		EndIf

		If lNaoRegra .And. !Empty(aMarcacao[nI][18]) .AND. cRegra <> aMarcacao[nI][18]
			cRegra:= aMarcacao[nI][18]
			AADD(aFuncTr, { {aMarcacao[1][7] + aMarcacao[nI][6]}, {aMarcacao[nI][2], aMarcacao[nI][16], cSeqIni, cRegra, "Alteração de escala no Gestão de Serviços", aMarcacao[1][7]}})
		EndIf

	Next nI
EndIf

aItens := AglutinaP8(aCabec , aItens, aMarcacao, cMvPar14)

If nOpc == 3
	DbSelectArea("AA1")
	AA1->(DbSetOrder(7)) // AA1_FILIAL, AA1_CDFUNC, AA1_FUNFIL
	If AA1->(DbSeek(xFilial("AA1") + aItens[1][AScan(aItens[1],{|x| x[1] == "P8_MAT" })][2] + aItens[1][AScan(aItens[1],{|x| x[1] == "P8_FILIAL" })][2]))
		aDados := At910QryDa( AA1->AA1_CODTEC )
	EndIf
	For nX := 1 To LEN(aDados)
		If VALTYPE(aDados[nX][3]) == 'C'
			aDados[nX][3] := StoD(aDados[nX][3])
		EndIf
		If VALTYPE(aDados[nX][4]) == 'C'
			aDados[nX][4] := StoD(aDados[nX][4])
		Endif
	Next nX
EndIf

If ExistBlock("At910Ma")
	aRet := ExecBlock("At910Ma", .F., .F., {aCabec, aItens, 3, cTpExp})
	If Len(aRet) > 1 .and. Valtype(aRet[1]) = "A" .AND. ValType(aRet[2]) == "A"
		aCabec := aClone(aRet[1])
		aItens := aClone(aRet[2])
	EndIf
EndIf

If lMV_GSLOG
	oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0068 ) //"parametros recebidos"
	oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), "------------------")
	oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0069 + aMarcacao[1][6] ) //"Matricula "
	oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0070 + aMarcacao[1][7] ) //"Filial "
	oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0071 + aMarcacao[1][1]) //"Codigo do Tecnico "
	oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0072 + aMarcacao[1][1] + STR0073 + cValToChar(nThread)) //"Processando o atendente " ## " na Thread "
	If nOpc == 3
		oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0079+ time() ) //"Inicio do Envio das marcações do atendente: "
	Else
		oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0091+ time() ) //"Inicio da Exclusão das marcações do atendente: "
	EndIf
EndIf

Begin Transaction
	dDataBase := dBckBase
	aRetInc := Ponm010(		.T.				,;	//01 -> Se o "Start" foi via WorkFlow
							.F. 			,;	//02 -> Se deve considerar as configuracoes dos parametros do usuario
							.T.				,;	//03 -> Se deve limitar a Data Final de Apontamento a Data Base
							cFilProc		,;	//04 -> Filial a Ser Processada
							.F.				,;	//05 -> Processo por Filial
							.F.				,;	//06 -> Apontar quando nao Leu as Marcacoes para a Filial
							.F.				,;	//07 -> Se deve Forcar o Reapontamento
							aCabec			,;
							aItens			,;
							nOpc    		,;
							cFilTec;
							)

	If lMV_GSLOG
		If nOpc == 3
			oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0078 + time() ) //"Fim do Envio das marcações do atendente: "
		Else
			oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0092 + time() ) //"Fim da Exclusão das marcações do atendente: "
		EndIf
		oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0074 ) //"Atendente Processado !"
		If Len(aRetInc) > 0
			If	!(aRetInc[1])
				oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0080) //"Atendente com inconsistência."
			Else
				oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0081 ) //"Atendente sem inconsistência."
			EndIf
		EndIf
		If nRest == 0
			oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0075) //"Thread Finalizada!"
		Else
			oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), STR0076 + cValtoChar(nRest) + STR0077) //"Restando " ## " Atendentes na Thread"
		EndIf
		oGsLog:addLog("MarcMultThr "+ cValToChar(nThread), "------------------")
		oGsLog:printLog("MarcMultThr "+ cValToChar(nThread))
	EndIf

	If Len(aRetInc) > 0 .And. !(aRetInc[1])
		cMsg := ""
		For nMsg := 1 to Len(aRetInc[2])
			cMsg += aRetInc[2,nMsg] + CRLF
		Next
		lRet := .F.
	EndIf

	IF nOpc == 5
		If lRet
			cAlsSPF:= GetNextAlias()
			
			cQrySPF:= " Select PF_DATA,PF_TURNODE,PF_SEQUEDE,PF_REGRADE,PF_TURNOPA,PF_SEQUEPA,PF_REGRAPA,PF_TRFOBS,PF_INTGTAF,PF_TAFKEY,R_E_C_N_O_ RecSPF "
			cQrySPF+= " FROM " + RetSqlName("SPF") + " SPF "
			cQrySPF+= " WHERE PF_FILIAL ='"+aCabec[1][2]+"' AND PF_MAT='"+aCabec[2][2]+"' AND "
			cQrySPF+= " PF_DATA >='"+ DToS(dMVPAR03) +"' AND PF_DATA <='"+ DToS(dMVPAR04) +"' AND SPF.D_E_L_E_T_=' ' "
			cQrySPF+= " ORDER BY SPF.R_E_C_N_O_ DESC "

			cQrySPF := ChangeQuery(cQrySPF)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySPF),cAlsSPF, .F., .T.)
			While !(cAlsSPF)->(EOF())
				aDelTurno:={}
				AADD( aDelTurno ,{ aCabec[1][2]+aCabec[2][2], {	{StoD((cAlsSPF)->PF_DATA),StoD((cAlsSPF)->PF_DATA)}, {(cAlsSPF)->PF_TURNODE,(cAlsSPF)->PF_TURNODE}, {(cAlsSPF)->PF_SEQUEDE,(cAlsSPF)->PF_SEQUEDE},;
																{(cAlsSPF)->PF_REGRADE,(cAlsSPF)->PF_REGRADE}, {(cAlsSPF)->PF_TURNOPA,(cAlsSPF)->PF_TURNOPA}, {(cAlsSPF)->PF_SEQUEPA,(cAlsSPF)->PF_SEQUEPA},;
																{(cAlsSPF)->PF_REGRAPA,(cAlsSPF)->PF_REGRAPA}, {(cAlsSPF)->PF_TRFOBS,(cAlsSPF)->PF_TRFOBS}, {(cAlsSPF)->PF_INTGTAF,(cAlsSPF)->PF_INTGTAF},;
																{(cAlsSPF)->PF_TAFKEY,(cAlsSPF)->PF_TAFKEY}, {"SPF","SPF"}, {(cAlsSPF)->RecSPF,(cAlsSPF)->RecSPF}} })
				Pona160(aDelTurno[1], 4)
				(cAlsSPF)->(DbSkip())
			EndDo
			(cAlsSPF)->(DbCloseArea())
		EndIf
	Else
		If lRet
			For nI := 1 To Len(aFuncTr)
				cFilAnt := aFuncTr[nI,2,6]
				aErro160:= PON160lot(aFuncTr[nI])
				cFilAnt := cFilSave
				If Len(aErro160)>0
					For nMk:=1 To Len(aErro160)
						cMsg += aErro160[nMk]+ CRLF
					Next nMk
					lRet:= .F.
				EndIf
			Next nI
		EndIf
	EndIf

End Transaction

AADD( aRet,  lRet  )
AADD( aRet,  cMsg  )

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910QryDa
	Função chamada no tecxfunb quando houver troca de turno o mesmo preencher o array static que no multthread não é preenchido

@sample At910QryDa(cCodTec)
@author	Augusto.Albuquerque
@since		20/01/2021
@version	P12
/*/
//------------------------------------------------------------------------------
Function At910QryDa( cCodTec )
Local aArea		:= GetArea()
Local aRet		:= {}
Local aCodTec	:= {cCodTec}
Local cAliasABB	:= GetNextAlias()
Local cQuery	:= ""//At910Qry(cCodTec)

Pergunte("TEC910B",.F.)

cQuery := At910Qry(aCodTec)
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasABB , .T. , .T. )

While !(cAliasABB)->(Eof())
	AADD( aRet, {(cAliasABB)->AA1_FUNFIL,;
					(cAliasABB)->AA1_CDFUNC,;
					(cAliasABB)->AB9_DTINI,;
					(cAliasABB)->AB9_DTFIM,;
					(cAliasABB)->AB9_HRINI,;
					(cAliasABB)->AB9_HRFIM,;
					(cAliasABB)->TDV_TURNO,;
					(cAliasABB)->TDV_SEQTRN,;
					(cAliasABB)->TDV_DTREF})
	(cAliasABB)->(DbSkip())
EndDo

(cAliasABB)->(DbCloseArea())

RestArea(aArea)

Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AT910AbbHE
	Verifica se a agenda é uma cobertura de alguma h.e. de intrajornada
@sample At910QryDa(cCodTec)
@author	boiani
@since	04/02/2021

/*/
//------------------------------------------------------------------------------
Function AT910AbbHE(aAgenda, nRec, dDataIni, dDataFim, cTipoABB)
Local lRet 		:= .F.
Local cSql 		:= ""
Local cAliasQry := GetNextAlias()
Local aArea 	:= GetArea()
Local cCodABB 	:= ""
Local cFilABB 	:= ""
Local lBusca 	:= .T.

Default nRec 		:= 0
Default dDataIni 	:= CTOD("")
Default dDataFim 	:= CTOD("")
Default cTipoABB 	:= ""

DbSelectArea("ABB")
ABB->(DbSetOrder(8))

If !EMPTY(dDataIni) .AND. !EMPTY(dDataFim)
	dMVPAR03 := dDataIni
	dMVPAR04 := dDataFim
EndIf

If !EMPTY(dMVPAR03) .AND. !EMPTY(dMVPAR04) .AND. aAgenda[4] <= dMVPAR04 .AND. aAgenda[2] >= dMVPAR03
	lBusca := ProcAbbHE(aAgenda[1], aAgenda[16], .T.)
Else
	lBusca := ProcAbbHE(aAgenda[1], aAgenda[16], .F.)
EndIf

If !EMPTY(cTipoABB)
	lBusca := lBusca .AND. POSICIONE("TCU",1,xFilial("TCU", aAgenda[16]) + cTipoABB, "TCU_EXMANU") == '1'
EndIf

If lBusca
	cSql := " SELECT ABR.ABR_AGENDA , ABR.ABR_FILIAL FROM " + RetSqlName("ABR") + " ABR "
	cSql += " WHERE ABR.D_E_L_E_T_ = ' ' AND ABR_CODSUB = '" + aAgenda[1] + "' AND "
	cSql += " (( ABR.ABR_DTFIMA = '" + DTOS(aAgenda[4]) + "' AND ABR.ABR_HRFIMA = '" + aAgenda[5] + "' ) "
	cSql += " OR ( ABR.ABR_DTINIA = '" + DTOS(aAgenda[2]) + "' AND ABR.ABR_HRINIA = '" + aAgenda[3] + "' )) "
	cSql += " AND ABR.ABR_FILIAL = '" + aAgenda[16] + "' "
	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
	If !(cAliasQry)->(EOF())
		cCodABB := (cAliasQry)->ABR_AGENDA
		cFilABB := (cAliasQry)->ABR_FILIAL
	EndIf
	(cAliasQry)->(dbCloseArea())

	If !EMPTY(cCodABB) .AND. !EMPTY(cFilABB)
		cSql := ""
		cAliasQry := GetNextAlias()
		cSql += " SELECT ABR.R_E_C_N_O_ REC FROM " + RetSqlName("ABR") + " ABR "
		cSql += " INNER JOIN " + RetSqlName("ABN") + " ABN ON "
		cSql += " ABN.ABN_CODIGO = ABR.ABR_MOTIVO  AND "
		cSql += FWJoinFilial("ABN" , "ABR" , "ABN", "ABR", .T.) + " AND "
		cSql += " ABN.D_E_L_E_T_ = ' ' "
		cSql += " WHERE ABR.D_E_L_E_T_ = ' ' AND "
		cSql += " ABR.ABR_AGENDA = '" + cCodABB + "' AND "
		cSql += " ABR.ABR_FILIAL = '" + cFilABB + "' AND "
		cSql += " ABN.ABN_TIPO = '04' AND "
		cSql += " ABR.ABR_DTINIA = '" + DTOS(aAgenda[2]) + "' "
		cSql := ChangeQuery(cSql)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
		If (lRet := !(cAliasQry)->(EOF()))
			nRec := (cAliasQry)->REC
		EndIf
		(cAliasQry)->(dbCloseArea())

		If !lRet
			If ABB->(DbSeek(cFilABB+cCodABB))

				cSql := " SELECT ABR.ABR_AGENDA , ABR.ABR_FILIAL FROM " + RetSqlName("ABR") + " ABR "
				cSql += " WHERE ABR.D_E_L_E_T_ = ' ' AND ABR_CODSUB = '" + ABB->ABB_CODTEC + "' AND "
				cSql += " (( ABR.ABR_DTFIMA = '" + DTOS(ABB->ABB_DTFIM) + "' AND "
				cSql += " ABR.ABR_HRFIMA = '" + ABB->ABB_HRFIM + "' ) "
				cSql += " OR ( ABR.ABR_DTINIA = '" + DTOS(ABB->ABB_DTINI) + "' AND "
				cSql += " ABR.ABR_HRINIA = '" + ABB->ABB_HRINI + "' )) "
				cSql += " AND ABR.ABR_FILIAL = '" + ABB->ABB_FILIAL + "' "
				cSql := ChangeQuery(cSql)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
				If !(cAliasQry)->(EOF())
					cCodABB := (cAliasQry)->ABR_AGENDA
					cFilABB := (cAliasQry)->ABR_FILIAL
				EndIf
				(cAliasQry)->(dbCloseArea())

				cSql := ""
				cAliasQry := GetNextAlias()
				cSql += " SELECT ABR.R_E_C_N_O_ REC FROM " + RetSqlName("ABR") + " ABR "
				cSql += " INNER JOIN " + RetSqlName("ABN") + " ABN ON "
				cSql += " ABN.ABN_CODIGO = ABR.ABR_MOTIVO  AND "
				cSql += FWJoinFilial("ABN" , "ABR" , "ABN", "ABR", .T.) + " AND "
				cSql += " ABN.D_E_L_E_T_ = ' ' "
				cSql += " WHERE ABR.D_E_L_E_T_ = ' ' AND "
				cSql += " ABR.ABR_AGENDA = '" + cCodABB + "' AND "
				cSql += " ABR.ABR_FILIAL = '" + cFilABB + "' AND "
				cSql += " ABN.ABN_TIPO = '04' AND "
				cSql += " ABR.ABR_DTINIA = '" + DTOS(ABB->ABB_DTINI) + "' "
				cSql := ChangeQuery(cSql)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
				If (lRet := !(cAliasQry)->(EOF()))
					nRec := (cAliasQry)->REC
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf

	EndIf

	RestArea(aArea)
EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AglutinaP8
	Verifica se existe mais de uma marcação para o mesmo dia/horário/matrícula
	e elimina todas
@sample AglutinaP8
@author	boiani
@since	16/02/2021
/*/
//------------------------------------------------------------------------------
Static Function AglutinaP8(aCabec, aItens, aMarcacao, cMvPar14)
Local aArea      := GetArea()
Local aDuplics   := {}
Local aRet       := {}
Local cAliasABB  := ""
Local cData1     := ""
Local cData2     := ""
Local cQry       := ""
Local cABBloq 	 := ""
Local cTDVBloq 	 := ""
Local lAglutBtd  := TecHasPerg("MV_PAR13","TEC910B")
Local lGSHRPon   := SuperGetMV("MV_GSHRPON",.F., "2") == "1" .AND. ( ABB->(ColumnPos('ABB_HRCHIN')) > 0 )
Local nAux       := 0
Local nMod       := 0
Local nNumQry    := 1
Local nPos1Agenda:= 0
Local nPos2Agenda:= 0
Local nPosDados  := 0
Local nRec1      := 0
Local nRec2      := 0
Local nX         := 0
Local oQuery     := Nil

Default cMvPar14 := 1

//Monta a expressão de filtro para campos de bloqueio:
cABBloq := TECStrExpBlq("ABB",,,2)
cTDVBloq := TECStrExpBlq("TDV",,,2)

For nX := 1 To LEN(aItens)
	nMod := 0
	If nX != LEN(aItens)
		nPos1Agenda := ASCAN(aMarcacao, {|a| a[6] == aItens[nX,2,2] .AND. ( (a[2] == aItens[nX,3,2] .AND.;
					ALLTRIM(a[3]) == TecConvhr(aItens[nX,4,2])) .OR. (a[4] == aItens[nX,3,2] .AND. ALLTRIM(a[5]) == TecConvhr(aItens[nX,4,2])) ) .AND. a[7] == aItens[nX,1,2]})

		If (nAux := ASCAN(aItens, {|a| aItens[nX,2,2] == a[2,2] .AND. aItens[nX,3,2] == a[3,2] .AND. aItens[nX,4,2] == a[4,2]}, nX + 1)) != 0
			If nPos1Agenda > 0
				nPos2Agenda := ASCAN(aMarcacao, {|a| a[6] == aItens[nAux,2,2] .AND. ( (a[2] == aItens[nAux,3,2] .AND.;
							ALLTRIM(a[3]) == TecConvhr(aItens[nAux,4,2])) .OR. (a[4] == aItens[nAux,3,2] .AND. ALLTRIM(a[5]) == TecConvhr(aItens[nAux,4,2])) );
							.AND. a[7] == aItens[nAux,1,2]}, nPos1Agenda + 1)

				If nPos2Agenda > 0
					cAliasABB := GetNextAlias()
					cQry	  := ""
					nNumQry	  := 1

					cQry := " SELECT TDV.TDV_DTREF, TDV.TDV_TURNO, ABB.R_E_C_N_O_ RECABB "
					cQry += " FROM ? TDV "
					cQry += " INNER JOIN ? ABB ON "
						cQry += " ABB.ABB_CODIGO = TDV.TDV_CODABB AND "
						cQry += " ABB.ABB_FILIAL = TDV.TDV_FILIAL AND "
					If !Empty(cABBloq)
						cQry += " ? "
					EndIf
						cQry += " ABB.D_E_L_E_T_ = ' ' "
					cQry += " INNER JOIN ? AA1 ON "
						cQry += " AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
						cQry += " AA1.AA1_FILIAL = ? AND "
						cQry += " AA1.AA1_FUNFIL = ? AND "
						cQry += " AA1.D_E_L_E_T_ = ' ' "
					cQry += " WHERE "
						cQry += " ABB.ABB_CODTEC = ? AND "
						cQry += " ABB.ABB_DTINI = ? AND "
						cQry += " ABB.ABB_DTFIM = ? AND "
					If lGSHRPon
						cQry += " ABB.ABB_HRCHIN = ? AND "
						cQry += " ABB.ABB_HRCOUT = ? AND "
					Else
						cQry += " ABB.ABB_HRINI = ? AND "
						cQry += " ABB.ABB_HRFIM = ? AND "
					EndIf
					If !Empty(cTDVBloq)
						cQry += " ? "
					EndIf
						cQry += " TDV.D_E_L_E_T_ = ' ' "

					//Prepara a query:
					oQuery := FwPreparedStatement():New(cQry)

					oQuery:SetNumeric( nNumQry++, RetSQLName("TDV") )
					oQuery:SetNumeric( nNumQry++, RetSQLName("ABB") )
					If !Empty(cABBloq)
						oQuery:SetNumeric(nNumQry++, cABBloq )
					EndIf
					oQuery:SetNumeric(nNumQry++, RetSQLName("AA1") )
					oQuery:SetString( nNumQry++, xFilial("AA1") )
					oQuery:SetString( nNumQry++, aMarcacao[nPos1Agenda][7] )
					oQuery:SetString( nNumQry++, aMarcacao[nPos1Agenda][1] )
					oQuery:SetString( nNumQry++, DTOS(aMarcacao[nPos1Agenda][2]) )
					oQuery:SetString( nNumQry++, DTOS(aMarcacao[nPos1Agenda][4]) )
					oQuery:SetString( nNumQry++, aMarcacao[nPos1Agenda][3] )
					oQuery:SetString( nNumQry++, aMarcacao[nPos1Agenda][5] )
					If !Empty(cTDVBloq)
						oQuery:SetNumeric(nNumQry++, cTDVBloq )
					EndIf

					cQry := oQuery:GetFixQuery()
					MPSysOpenQuery(cQry, cAliasABB)

					dbSelectArea(cAliasABB)

					If !(cAliasABB)->(EOF())
						cData1 := (cAliasABB)->(TDV_DTREF + TDV_TURNO)
						nRec1 := (cAliasABB)->RECABB
					EndIf
					(cAliasABB)->(DbCloseArea())
					oQuery:Destroy()
					FwFreeObj(oQuery)

					If !EMPTY(cData1)
						cAliasABB := GetNextAlias()
						cQry	  := ""
						nNumQry	  := 1						
						
						cQry := " SELECT TDV.TDV_DTREF, TDV.TDV_TURNO, ABB.R_E_C_N_O_ RECABB "
						cQry += " FROM ? TDV "
						cQry += " INNER JOIN ? ABB ON "
							cQry += " ABB.ABB_CODIGO = TDV.TDV_CODABB AND "
							cQry += " ABB.ABB_FILIAL = TDV.TDV_FILIAL AND "
						If !Empty(cABBloq)
							cQry += " ? "
						EndIf
							cQry += " ABB.D_E_L_E_T_ = ' ' "
						cQry += " INNER JOIN ? AA1 ON "
							cQry += " AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
							cQry += " AA1.AA1_FILIAL = ? AND "
							cQry += " AA1.AA1_FUNFIL = ? AND "
							cQry += " AA1.D_E_L_E_T_ = ' ' "
						cQry += " WHERE "
							cQry += " ABB.ABB_CODTEC = ? AND "
							cQry += " ABB.ABB_DTINI = ? AND "
							cQry += " ABB.ABB_DTFIM = ? AND "
						If lGSHRPon
							cQry += " ABB.ABB_HRCHIN = ? AND "
							cQry += " ABB.ABB_HRCOUT = ? AND "
						Else
							cQry += " ABB.ABB_HRINI = ? AND "
							cQry += " ABB.ABB_HRFIM = ? AND "
						EndIf
						If !Empty(cTDVBloq)
							cQry += " ? "
						EndIf
							cQry += " TDV.D_E_L_E_T_ = ' ' "

						//Prepara a query:
						oQuery := FwPreparedStatement():New(cQry)

						oQuery:SetNumeric(nNumQry++, RetSQLName("TDV") )
						oQuery:SetNumeric(nNumQry++, RetSQLName("ABB") )
						If !Empty(cABBloq)
							oQuery:SetNumeric(nNumQry++, cABBloq )
						EndIf
						oQuery:SetNumeric(nNumQry++, RetSQLName("AA1") )
						oQuery:SetString( nNumQry++, xFilial("AA1") )
						oQuery:SetString( nNumQry++, aMarcacao[nPos2Agenda][7] )
						oQuery:SetString( nNumQry++, aMarcacao[nPos2Agenda][1] )
						oQuery:SetString( nNumQry++, DTOS(aMarcacao[nPos2Agenda][2]) )
						oQuery:SetString( nNumQry++, DTOS(aMarcacao[nPos2Agenda][4]) )
						oQuery:SetString( nNumQry++, aMarcacao[nPos2Agenda][3] )
						oQuery:SetString( nNumQry++, aMarcacao[nPos2Agenda][5] )
						If !Empty(cTDVBloq)
							oQuery:SetNumeric(nNumQry++, cTDVBloq )
						EndIf

						cQry := oQuery:GetFixQuery()
						MPSysOpenQuery(cQry, cAliasABB)

						dbSelectArea(cAliasABB)

						If !(cAliasABB)->(EOF())
							cData2 := (cAliasABB)->(TDV_DTREF + TDV_TURNO)
							nRec2 := (cAliasABB)->RECABB
						EndIf
						(cAliasABB)->(DbCloseArea())
						oQuery:Destroy()
						FwFreeObj(oQuery)
						
						If !EMPTY(cData2)
							If cData2 == cData1
								AADD(aDuplics, aItens[nX])
							ElseIf lAglutBtd .AND. cMvPar14 == 1
								If aMarcacao[nPos1Agenda][4] == aMarcacao[nPos2Agenda][2] .AND.;
										aMarcacao[nPos2Agenda][3] == aMarcacao[nPos1Agenda][5] .AND. nPos2Agenda > nPos1Agenda
									ABB->(DBGoTo(nRec1))
									If ABB->ABB_MANUT == '2'
										nMod := 1
									EndIf
									If nMod == 0
										ABB->(DBGoTo(nRec2))
										If ABB->ABB_MANUT == '2'
											nMod := 2
										EndIf
									EndIf
									If nMod == 1
										ABB->(DBGoTo(nRec1))
										RecLock("ABB",.F.)
										If ABB->ABB_HRFIM == "00:00"
											ABB->ABB_HRFIM := "23:59"
											ABB->ABB_DTFIM := (ABB->ABB_DTFIM - 1)
											If !IsInCallStack("MarcJobAux") .AND. (nPosDados := ASCAN(aDados, {|a| a[2] == aItens[nX,2,2] .AND. ( (a[3] == aItens[nX,3,2] .AND. ALLTRIM(a[5]) == TecConvhr(aItens[nX,4,2])) .OR. (a[4] == aItens[nX,3,2] .AND. ALLTRIM(a[6]) == TecConvhr(aItens[nX,4,2])) ) .AND. a[1] == aItens[nX,1,2]})) > 0
												aDados[nPosDados][6] := ABB->ABB_HRFIM
												aDados[nPosDados][4] := ABB->ABB_DTFIM
											EndIf
											aItens[nX][4][2] := TecConvhr(ABB->ABB_HRFIM)
											aItens[nX][3][2] := ABB->ABB_DTFIM
										Else
											ABB->ABB_HRFIM := TecConvhr(SomaHoras(ABB->ABB_HRFIM, -0.01))
											If !IsInCallStack("MarcJobAux") .AND. (nPosDados := ASCAN(aDados, {|a| a[2] == aItens[nX,2,2] .AND. ( (a[3] == aItens[nX,3,2] .AND. ALLTRIM(a[5]) == TecConvhr(aItens[nX,4,2])) .OR. (a[4] == aItens[nX,3,2] .AND. ALLTRIM(a[6]) == TecConvhr(aItens[nX,4,2])) ) .AND. a[1] == aItens[nX,1,2]})) > 0
												aDados[nPosDados][6] := ABB->ABB_HRFIM
											EndIf
											aItens[nX][4][2] := TecConvhr(ABB->ABB_HRFIM)
										EndIf
										ABB->ABB_HRTOT := AtTotHora(ABB->ABB_DTINI ,ABB->ABB_HRINI, ABB->ABB_DTFIM ,ABB->ABB_HRFIM)
										ABB->(MsUnLock())
									ElseIf nMod == 2
										ABB->(DBGoTo(nRec2))
										RecLock("ABB",.F.)
										If ABB->ABB_HRINI == "23:59"
											ABB->ABB_HRINI := "00:00"
											ABB->ABB_DTINI := (ABB->ABB_DTINI - 1)
											If !IsInCallStack("MarcJobAux") .AND. (nPosDados := ASCAN(aDados, {|a| a[2] == aItens[nX,2,2] .AND. ( (a[3] == aItens[nX,3,2] .AND. ALLTRIM(a[5]) == TecConvhr(aItens[nX,4,2])) .OR. (a[4] == aItens[nX,3,2] .AND. ALLTRIM(a[6]) == TecConvhr(aItens[nX,4,2])) ) .AND. a[1] == aItens[nX,1,2]})) > 0
												aDados[nPosDados][5] := ABB->ABB_HRINI
												aDados[nPosDados][3] := ABB->ABB_DTINI
											EndIf
											aItens[nAux][4][2] := TecConvhr(ABB->ABB_HRINI)
											aItens[nAux][3][2] := ABB->ABB_DTINI
										Else
											ABB->ABB_HRINI := TecConvhr(SomaHoras(ABB->ABB_HRINI, 0.01))
											If !IsInCallStack("MarcJobAux") .AND. (nPosDados := ASCAN(aDados, {|a| a[2] == aItens[nX,2,2] .AND. ( (a[3] == aItens[nX,3,2] .AND. ALLTRIM(a[5]) == TecConvhr(aItens[nX,4,2])) .OR. (a[4] == aItens[nX,3,2] .AND. ALLTRIM(a[6]) == TecConvhr(aItens[nX,4,2])) ) .AND. a[1] == aItens[nX,1,2]})) > 0
												aDados[nPosDados][5] := ABB->ABB_HRINI
											EndIf
											aItens[nAux][4][2] := TecConvhr(ABB->ABB_HRINI)
										EndIf
										ABB->ABB_HRTOT := AtTotHora(ABB->ABB_DTINI ,ABB->ABB_HRINI, ABB->ABB_DTFIM ,ABB->ABB_HRFIM)
										ABB->(MsUnLock())
									//Else //TO DO - Caso as duas agendas possuam Manutenção, será necessário modificar a ABR_HRINIA / ABR_HRFIMA
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nX

If Valtype(oQuery) == 'O'
	oQuery:Destroy()
	FwFreeObj(oQuery)
EndIf

For nX := 1 To LEN(aItens)
	If EMPTY(aDuplics) .OR. ASCAN(aDuplics, {|a| aItens[nX,2,2] == a[2,2] .AND. aItens[nX,3,2] == a[3,2] .AND. aItens[nX,4,2] == a[4,2]}) == 0
		AADD(aRet, ACLONE(aItens[nX]))
	EndIf
Next nX

RestArea(aArea)
Return aRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} AglutTDVs
	Ajusta os campos TDV_HRMEN e TDV_HRMAI de forma que todas as batidas para a mesma
	DtRef sejam algutinadas no ponto

	aItens[x]
			[x][01] = AA1_FUNFIL
			[x][02] = AA1_CDFUNC
			[x][03] = TDV_HRMAI
			[x][04] = TDV_HRMEN
			[x][05] = TDV_TPDIA
			[x][06] = TDV.R_E_C_N_O_
			[x][07] = TDV_FILIAL
			[x][08] = ABB_DTINI
			[x][09] = ABB_DTFIM
			[x][10] = ABB_HRINI
			[x][11] = ABB_HRFIM
			[x][12] = TDV_DTREF (C)

@sample AglutinaP8
@author	boiani
@since	26/02/2021
/*/
//------------------------------------------------------------------------------
Static Function AglutTDVs(aItens)
Local nX := 0
Local nY := 0
Local nPos1 := 0
Local nPos2 := 0
Local nPos3 := 0
Local nPos4 := 0
Local nCount := 0
Local aProcs := {}
Local aUmaAgend := {}
Local aAux := {}
Local aArea := GetArea()
Local aRecTDVIntra := {}

DbSelectArea("TDV")

aSort(aItens,,, {|x,y|  x[1] + x[2] + x[12] + DTOS(x[8]) + x[10] + DTOS(x[9]) + x[11] <;
						y[1] + y[2] + y[12] + DTOS(y[8]) + y[10] + DTOS(y[9]) + y[11] })

For nX := 1 To LEN(aItens)
	If aItens[nX][13] == 'S' .AND. aItens[nX][5] == 'S' .AND.;
			ASCAN(aItens, {|a| a[1] == aItens[nX][1] .AND. a[2] == aItens[nX][2] .AND. a[12] == aItens[nX][12] .AND. a[5] == 'N' }) > 0 .AND.;
			ASCAN(aItens, {|a| a[1] == aItens[nX][1] .AND. a[2] == aItens[nX][2] .AND. a[12] == aItens[nX][12] .AND. a[5] == 'S' }, nX+1) == 0
		AADD(aRecTDVIntra, aItens[nX][6])
	EndIf
	nCount := 0
	If nX + 2 <= LEN(aItens)
		For nY := 1 To 3
			If nX + nY <= Len(aItens)
				If aItens[nX][1] == aItens[nX+nY][1] .AND. aItens[nX][2] == aItens[nX+nY][2] .AND. aItens[nX][12] == aItens[nX+nY][12]
					nCount++
					If nCount == 2 .AND. ( EMPTY(aProcs) .OR. ASCAN(aProcs, {|a| a[1] == aItens[nX][1] .AND. a[2] == aItens[nX][2] .AND. a[12] == aItens[nX][12]}) == 0 )
						AADD(aProcs, aItens[nX])
					EndIf
				EndIf
			EndIf
		Next nY
	EndIf

	If aItens[nX][5] == 'N' .AND. (aItens[nX][8] < aItens[nX][9] .OR. aItens[nX][8] == aItens[nX][9]) .AND. ASCAN(aItens,;
		{|a| a[1] == aItens[nX][1] .AND. a[2] == aItens[nX][2] .AND. a[12] == aItens[nX][12]}, nX+1) == 0
		//Apenas uma agenda noturna em um dia não trabalhado
		AADD(aUmaAgend, aItens[nX])
	EndIf
Next nX

For nX := 1 To LEN(aProcs)
	aAux := {}
	nHoraAux := 0
	nPos1 := ASCAN(aItens, {|a| a[1] == aProcs[nX][1] .AND. a[2] == aProcs[nX][2] .AND. a[12] == aProcs[nX][12]} )
	nPos2 := ASCAN(aItens, {|a| a[1] == aProcs[nX][1] .AND. a[2] == aProcs[nX][2] .AND. a[12] == aProcs[nX][12]} , nPos1 + 1)
	nPos3 := ASCAN(aItens, {|a| a[1] == aProcs[nX][1] .AND. a[2] == aProcs[nX][2] .AND. a[12] == aProcs[nX][12]} , nPos1 + 2)
	nPos4 := ASCAN(aItens, {|a| a[1] == aProcs[nX][1] .AND. a[2] == aProcs[nX][2] .AND. a[12] == aProcs[nX][12]} , nPos1 + 3)
	AADD(aAux, ACLONE(aItens[nPos1]))
	AADD(aAux, ACLONE(aItens[nPos2]))
	AADD(aAux, ACLONE(aItens[nPos3]))
	If nPos4 > 0
		AADD(aAux, ACLONE(aItens[nPos4]))

		aSort(aAux,,, {|x,y| TecConvHr(x[11])+IIF(x[9] > STOD(x[12]),24,0) < TecConvHr(y[11])+IIF(y[9] > STOD(y[12]),24,0)})
		If aAux[1][5] == 'N' .AND. aAux[2][5] == 'N' .AND. aAux[3][5] == 'S' .AND. aAux[4][5] == 'S'
			nHoraAux := (TecConvHr(aAux[3][10]) + IIF( aAux[3][8] > STOD(aAux[3][12]) , 24 , 0 )) -;
						TecConvHr(aAux[1][10]) + IIF( aAux[1][8] > STOD(aAux[1][12]) , 24 , 0 )
			If nHoraAux > 0
				TDV->(DbGoTO(aAux[3][6]))
				If (nHoraAux) > TDV->TDV_HRMEN
					RecLock("TDV", .F.)
					TDV_HRMEN := (nHoraAux)
					TDV->( MsUnLock() )
				EndIf
			EndIf
		ElseIf (aAux[1][5] == 'S' .AND. aAux[2][5] == 'S' .AND. aAux[3][5] == 'N' .AND. aAux[4][5] == 'N') .Or. ;
			(aAux[1][5] == 'N' .AND. aAux[2][5] == 'S' .AND. aAux[3][5] == 'N' .AND. aAux[4][5] == 'N')
			nHoraAux := (TecConvHr(aAux[4][11]) + IIF( aAux[4][9] > STOD(aAux[4][12]) , 24 , 0 )) -;
						TecConvHr(aAux[2][11]) + IIF( aAux[2][9] > STOD(aAux[2][12]) , 24 , 0 )
			If nHoraAux > 0
				TDV->(DbGoTO(aAux[2][6]))
				If (nHoraAux) > TDV->TDV_HRMAI
					RecLock("TDV", .F.)
					TDV_HRMAI := (nHoraAux)
					TDV->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	Else
		aSort(aAux,,, {|x,y| TecConvHr(x[11])+IIF(x[9] > STOD(x[12]),24,0) < TecConvHr(y[11])+IIF(y[9] > STOD(y[12]),24,0)})
		If aAux[1][5] == 'N' .AND. aAux[2][5] == 'S' .AND. aAux[3][5] == 'S'
			nHoraAux := (TecConvHr(aAux[2][10]) + IIF( aAux[2][8] > STOD(aAux[2][12]) , 24 , 0 )) -;
						TecConvHr(aAux[1][10]) + IIF( aAux[1][8] > STOD(aAux[1][12]) , 24 , 0 )
			If nHoraAux > 0
				TDV->(DbGoTO(aAux[3][6]))
				If (nHoraAux) > TDV->TDV_HRMEN
					RecLock("TDV", .F.)
					TDV_HRMEN := (nHoraAux)
					TDV->( MsUnLock() )
				EndIf
				If TecBTCUAlC() .AND. At910AloFT(aAux[1][6])
					TDV->(DbGoTO(aAux[2][6]))
					If (nHoraAux) > TDV->TDV_HRMEN
						RecLock("TDV", .F.)
						TDV_HRMEN := (nHoraAux)
						TDV->( MsUnLock() )
					EndIf
				EndIf
			EndIf
		ElseIf aAux[1][5] == 'S' .AND. aAux[2][5] == 'S' .AND. aAux[3][5] == 'N'
			nHoraAux := (TecConvHr(aAux[3][11]) + IIF( aAux[3][9] > STOD(aAux[3][12]) , 24 , 0 )) -;
						TecConvHr(aAux[2][11]) + IIF( aAux[2][9] > STOD(aAux[2][12]) , 24 , 0 )
			If nHoraAux > 0
				TDV->(DbGoTO(aAux[2][6]))
				If (nHoraAux) > TDV->TDV_HRMAI
					At910HRMAI(aAux[2][6],@nHoraAux)
					RecLock("TDV", .F.)
					TDV_HRMAI := (nHoraAux)
					TDV->( MsUnLock() )
				EndIf
			EndIf
		EndIf
	EndIf
Next nX

For nX := 1 To LEN(aUmaAgend)
	TDV->(DbGoTO(aUmaAgend[nX][6]))
	nHoraAux := (TecConvHr(aUmaAgend[nX][11]) + IIF(aUmaAgend[nX][8] < aUmaAgend[nX][9],24,0)) - TecConvHr(aUmaAgend[nX][10])
	If nHoraAux > TDV->TDV_HRMAI
		RecLock("TDV", .F.)
		TDV_HRMAI := nHoraAux
		TDV->( MsUnLock() )
	EndIf
Next nX

For nX := 1 To LEN(aRecTDVIntra)
	TDV->(DbGoTO(aRecTDVIntra[nX]))
	RecLock("TDV", .F.)
		TDV_INTVL1 := 'N'
	TDV->( MsUnLock() )
Next nX

RestArea(aArea)
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} ProcAbbHE
	A função AT910AbbHE é chamada para cada DIA da agenda do atendente, o que pode
	causar um problema de performance ao processar uma grande quantidade de registros.
	Esta função verifica no período inteiro e grava em um array static se em algum dia o
	atendente é uma cobertura, evitando multiplas chamadas da função AT910AbbHE
@author	boiani
@since	21/03/21
/*/
//------------------------------------------------------------------------------
Static Function ProcAbbHE(cAbrCodSub, cAbrFilial, lChkData)
Local lRet := .T.
Local cSql := ""
Local cAliasQry
Local nAux := 0
Default lChkData := .F.

If !EMPTY(aAbbHE) .AND. (nAux := ASCAN(aAbbHE, {|a| a[1] == cAbrCodSub .AND. a[2] == cAbrFilial})) > 0
	lRet := aAbbHE[nAux][3]
Else
	cAliasQry := GetNextAlias()
	cSql := " SELECT 1 REC FROM " + RetSqlName("ABR") + " ABR "
	cSql += " WHERE ABR.D_E_L_E_T_ = ' ' AND ABR_CODSUB = '" + cAbrCodSub + "' AND "
	If lChkData
		cSql += " ABR.ABR_DTFIM <= '" + DTOS(dMVPAR04) + "' AND ABR.ABR_DTINI >= '" + DTOS(dMVPAR03) + "' AND "
	EndIf
	cSql += " ABR.ABR_FILIAL = '" + cAbrFilial + "' "
	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
	AADD(aAbbHE, {cAbrCodSub, cAbrFilial, ( !(cAliasQry)->(EOF()) ) })
	(cAliasQry)->(dbCloseArea())
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910HRMAI
	Verifica o horario da manutenção para adicionar no tempo dO CAMPO TDV_HRMAI

@author	Luiz Gabriel
@since	20/05/2021
/*/
//------------------------------------------------------------------------------
Static Function At910HRMAI(nRecTDV,nHoraAux)

Local cAliasQry := GetNextAlias()
Local cSql		:= ""

cSql := "SELECT ABR.ABR_TEMPO FROM " + RetSqlName("ABB") + " ABB "

cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV ON"
cSql += " TDV.TDV_CODABB = ABB.ABB_CODIGO AND "
cSql += " TDV.R_E_C_N_O_ = " + cValToChar(nRecTDV)
cSQL += TECStrExpBlq("TDV")
cSql += " AND TDV.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName("ABR") + " ABR "
cSql += " ON ABR.ABR_AGENDA = ABB.ABB_CODIGO AND ABR.D_E_L_E_T_ = ''"
cSql += " WHERE ABB.ABB_MANUT = '1' AND ABB.D_E_L_E_T_ = '' "
cSql += TECStrExpBlq("ABB")
cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

If !(cAliasQry)->(EOF()) .And. (cAliasQry)->ABR_TEMPO > "00:00"
	nHoraAux := nHoraAux + TecConvHr((cAliasQry)->ABR_TEMPO)
EndIf

(cAliasQry)->(dbCloseArea())

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910AloFT
	Verifica se a marcação é uma FT

@author	Luiz Gabriel
@since	28/06/2021
/*/
//------------------------------------------------------------------------------
Static Function At910AloFT(nRecTDV)
Local lRet			:= .F.
Local cAliasQry		:= GetNextAlias()
Local cSql 			:= ""
Local lMV_MultFil 	:= TecMultFil() //Indica se a Mesa considera multiplas filiais

cSql := "SELECT TCU.TCU_ALOCEF FROM " + RetSqlName("ABB") + " ABB "

cSql += " INNER JOIN " + RetSqlName("TDV") + " TDV ON"
cSql += " TDV.TDV_CODABB = ABB.ABB_CODIGO AND "
cSql += " TDV.TDV_FILIAL = ABB.ABB_FILIAL AND "
cSql += " TDV.R_E_C_N_O_ = " + cValToChar(nRecTDV)
cSql += TECStrExpBlq("TDV")
cSql += " AND TDV.D_E_L_E_T_ = ''
cSql += " LEFT JOIN " + RetSqlName( "TCU" ) + " TCU ON TCU.TCU_COD = ABB.ABB_TIPOMV AND "

If !lMV_MultFil
	cSql += " TCU.TCU_FILIAL = '" + xFilial("TCU") + "' "
Else
	cSql += " " + FWJoinFilial("ABB" , "TCU" , "ABB", "TCU", .T.) + " "
EndIf

cSql += " AND TCU.TCU_ALOCEF = '2' "
cSql += " AND TCU.D_E_L_E_T_ = ' ' "
cSql += " WHERE ABB.D_E_L_E_T_ = ' ' "
cSql += TECStrExpBlq("ABB")
cSql := ChangeQuery(cSql)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

If !(cAliasQry)->(EOF())
	lRet := .T.
EndIf

(cAliasQry)->(dbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910CodCCT
	Verifica qual é a CCT e filial da CCT que o funcionario trabalhou

@param cAlias - Alias da query com as agendas do técnco

@author	Luiz Gabriel
@since	30/06/2022
/*/
//------------------------------------------------------------------------------
Static Function At910CodCCT(cAlias)
Local aRet 			:= {}
Local cAliasCCT		:= ""
Local cFilLocal		:= ""
Local cLocal		:= ""
Local cBaseOp		:= ""
Local cFilFunc		:= ""
Local cCodFunc		:= ""
Local cWhereAA0		:= ""
Local cWhereREI		:= ""
Local cWhereRI4		:= ""
Local cWhereRUK		:= ""
Local cQry			:= ""
Local cComAA1 		:= FwModeAccess("AA1",1) +  FwModeAccess("AA1",2) + FwModeAccess("AA1",3)
Local cComSRA 		:= FwModeAccess("SRA",1) +  FwModeAccess("SRA",2) + FwModeAccess("SRA",3)
Local lMultFil		:= SuperGetMV("MV_GSMSFIL",,.F.) .AND. (LEN(STRTRAN( cComAA1  , "E" )) > LEN(STRTRAN(  cComSRA  , "E" )))
Local lTemRUK		:= AliasInDic("RUK")
Local nNumQry		:= 1
Local oQry			:= Nil

//Verifica se há dados no array aCCT ou se já existe configuração de CCT
If Empty(aCCT) .Or. At910ChkCCT(cAlias,@aRet)
	cFilLocal	:= (cAlias)->ABS_FILIAL
	cLocal		:= (cAlias)->ABS_LOCAL
	cBaseOp		:= (cAlias)->ABS_BASEOP
	cFilFunc	:= (cAlias)->RJ_FILIAL
	cCodFunc 	:= (cAlias)->RJ_FUNCAO

	If !lMultFil
		cWhereAA0 := "AA0.AA0_FILIAL = '" + xFilial("AA0") + "'"
		cWhereREI := "REI.REI_FILIAL = '" + xFilial("REI") + "'"
		cWhereRI4 := "RI4.RI4_FILIAL = '" + xFilial("RI4") + "'"
		cWhereRUK := "RUK.RUK_FILIAL = '" + xFilial("RUK") + "'"
	Else
		cWhereAA0 := FWJoinFilial("AA0" , "ABS" , "AA0", "ABS", .T.)
		cWhereREI := FWJoinFilial("REI" , "AA0" , "REI", "AA0", .T.)
		cWhereRI4 := FWJoinFilial("RI4" , "REI" , "RI4", "REI", .T.)
		cWhereRUK := FWJoinFilial("RUK" , "RI4" , "RUK", "RI4", .T.)
	Endif

	cQry := "SELECT COALESCE(RI4.RI4_FILCCT,'') RI4_FILCCT, "
	cQry += "       COALESCE(RI4.RI4_CODCCT,'') RI4_CODCCT  "
	cQry += "FROM ? ABS "
	// Base Operacional
	cQry += "   INNER JOIN ? AA0 ON "
	cQry += "      ABS.ABS_BASEOP = AA0.AA0_CODIGO AND ? AND "
	cQry += "      AA0.D_E_L_E_T_ = ' '"
	// CCT X Base Operacional
	cQry += "   INNER JOIN ? REI ON ? AND "
	cQry += "      REI.REI_FILAA0 = AA0.AA0_FILIAL AND "
	cQry += "      REI.REI_CODAA0 = AA0.AA0_CODIGO AND "
	cQry += "      REI.D_E_L_E_T_ = ' '"
	// CCT x Funções
	cQry += "   INNER JOIN ? RI4 ON ? AND "
	cQry += "      RI4.RI4_FILCCT = REI.REI_FILCCT AND "
	cQry += "      RI4.RI4_CODCCT = REI.REI_CODCCT AND "
	cQry += "      RI4.RI4_FILSRJ = ? AND "
	cQry += "      RI4.RI4_CODSRJ = ? AND "
	cQry += "      RI4.D_E_L_E_T_ = ' '"
	// Municípios x CCT
	If lTemRUK
		cQry += "   INNER JOIN ? RUK ON ? AND "
		cQry += "      RUK.RUK_CODCCT = RI4.RI4_CODCCT AND "
		cQry += "      RUK.RUK_FILCCT = RI4.RI4_FILCCT AND "
		cQry += "      RUK.RUK_ESTADO = ABS.ABS_ESTADO AND "
		cQry += "      RUK.RUK_CODMUN = ABS.ABS_CODMUN AND "
		cQry += "      RUK.D_E_L_E_T_ = ' '"
	EndIf
	// Local de Atendimento
	cQry += "   WHERE ABS.ABS_FILIAL = ? AND "
	cQry += "         ABS.ABS_LOCAL  = ? AND "
	cQry += "         ABS.ABS_BASEOP = ? AND "
	cQry += "         ABS.D_E_L_E_T_ = ' '"

	oQry := FwPreparedStatement():New( cQry )

	oQry:setNumeric( nNumQry++, RetSqlName( "ABS" ) )
	oQry:setNumeric( nNumQry++, RetSqlName( "AA0" ) )
	oQry:setNumeric( nNumQry++, cWhereAA0 )
	oQry:setNumeric( nNumQry++, RetSqlName( "REI" ) )
	oQry:setNumeric( nNumQry++, cWhereREI )
	oQry:setNumeric( nNumQry++, RetSqlName( "RI4" ) )
	oQry:setNumeric( nNumQry++, cWhereRI4 )
	oQry:setString(  nNumQry++, cFilFunc )
	oQry:setString(  nNumQry++, cCodFunc )
	If lTemRUK
		oQry:setNumeric( nNumQry++, RetSqlName( "RUK" ) )
		oQry:setNumeric( nNumQry++, cWhereRUK )
	EndIf
	oQry:setString( nNumQry++, cFilLocal )
	oQry:setString( nNumQry++, cLocal )
	oQry:setString( nNumQry++, cBaseOp )

	cQry := oQry:GetFixQuery()
	cQry := ChangeQuery(cQry)
	cAliasCCT := MPSysOpenQuery(cQry)

	If (cAliasCCT)->(!Eof())
		aRet := {(cAliasCCT)->RI4_FILCCT,(cAliasCCT)->RI4_CODCCT}
	EndIf

	AAdd( aCCT, { 	cFilLocal,;
					cLocal,;
					cFilFunc,;
					cCodFunc,;
					(cAliasCCT)->RI4_FILCCT,;
					(cAliasCCT)->RI4_CODCCT } )

	(cAliasCCT)->(dbCloseArea())
	oQry:Destroy()
	FwFreeObj( oQry )

EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At910ChkCCT
	Verifica se já existe no array statico aCCT a filial e codigo da CCT

@param cAlias - Alias da query com as agendas do técnco
@param aRet   - Alias para retornar qual a filial e CCT que o funcionario
trabalhou no dia

@author	Luiz Gabriel
@since	30/06/2022
/*/
//------------------------------------------------------------------------------
Static Function At910ChkCCT(cAlias,aRet)
Local lRet	:= .T.
Local nScan	:= 0

//Verifica se já existe a chave no array para reutilizar
nScan := AScan(aCCT, {|x| Alltrim(x[1]) + Alltrim(x[2]) + Alltrim(x[3]) + Alltrim(x[4]) == Alltrim((cAlias)->ABS_FILIAL) + Alltrim((cAlias)->ABS_LOCAL) + Alltrim((cAlias)->RJ_FILIAL) + Alltrim((cAlias)->RJ_FUNCAO) })

If nScan > 0
	lRet := .F.
	If !Empty(aCCT[nScan][5]+aCCT[nScan][6])
		aRet := {aCCT[nScan][5],aCCT[nScan][6]}
	EndIf
EndIf

Return lRet
