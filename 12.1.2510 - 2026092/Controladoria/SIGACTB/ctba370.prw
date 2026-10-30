#INCLUDE "CTBA370.ch"
#Include "PROTHEUS.Ch"


// 17/08/2009 -- Filial com mais de 2 caracteres
Static lFWCodFil := FindFunction("FWCodFil")
STATIC __lBlind		:= IsBlind()

// TRADUÇÃO RELEASE P10 1.2 - 21/07/08
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CTBA370  ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 21.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recalcula o valor dos lancamentos em moedas fortes.        ³±±
±±³          ³ de acordo com os lancamentos contabeis                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA370(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA370(lBat As Logical)

Local nOpca	As Numeric
Local aSays	, aButtons As Array	

DEFAULT lBat := IsBlind()
                      
Private cCadastro As Character
Private dDataLanc As Date

nOpca	:= 0
aSays	:= {} 
aButtons := {}	

cCadastro := STR0001 //"Atualizacao de Lancamentos em Moedas"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01 // A partir da Data                                 ³
//³ mv_par02 // Ate a Data                                       ³
//³ mv_par03 // Moedas - Especificas ou Todas                    ³
//³ mv_par04 // Qual moeda ?                                     ³
//³ mv_par05 // Qual Tipo de Saldo - F3 - SLD                    ³
//³ mv_par06 // Considera criterio - Plano de Contas/Lancamento  ³
//³ mv_par07 // Reprocessa Saldos?                               ³
//³ mv_par08 // Filial De ?                                      ³
//³ mv_par09 // Filial Ate ?                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !FWGetRunSchedule()
    Pergunte("CTB370",.f.)
EndIf

AADD(aSays, STR0002 ) //"Este programa tem como objetivo recalcular o valor dos  lancamentos contabeis dentro"
AADD(aSays,	STR0003 ) //"de um determinado periodo. Podera ser utilizado quando"
AADD(aSays,	STR0004 ) //"for alterado o criterio de conversao no plano de contas."
AADD(aSays,	STR0009 ) //"Rodar o Reprocessamento Contabil do periodo informado caso a atualizacao de saldos nao seja on line."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T.,{|| Pergunte("CTB370",.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( ConaOk(),FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

If ! lBat
	FormBatch( cCadastro, aSays, aButtons,, 200, 600 )
Else
	nOpca := 1
Endif		

IF nOpca == 1

	If !CtbValiDt(,dDataBASE,,,,{"FIN001","FIN002"},)
		Return
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("INICIO")

	If !CTBSerialI("CTBPROC","OFF")
		Return
	Endif

	If !lBat
		Processa({|lEnd| Ct370Proc()})
	Else
		Ct370Proc(lBat)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o log de processamento   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogAtu("FIM")

	CTBSerialF("CTBPROC","OFF")
Endif

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ca370Proc ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 21.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recalculo valor lanc moeda forte                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ca370Proc()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CONA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct370Proc(lBat)

Local nCont, cMoed, nVal
Local lAtSldBase	:= Iif(GetMv("MV_ATUSAL")== "S",.T.,.F.)
Local cCriter		:= ""   
Local cAlias		:= ""
Local cFiltro		:= ""
Local cOrder		:= ""
Local cIndex		:= ""
Local nIndex		:= ""
Local nValMoeda	    := 0                      
Local nRecnoAnt		:= 0
Local __lCusto		:= CtbMovSaldo("CTT")
Local __lItem	  	:= CtbMovSaldo("CTD")
Local __lCLVL	  	:= CtbMovSaldo("CTH")
Local dData			:= CTOD("  / /  ")
Local cLote			:= ""
Local cSubLote		:= ""
Local cDoc			:= ""
Local cLinha		:= ""
Local cTpSald		:= ""
Local cEmpOri		:= ""
Local cFilOri		:= ""
Local nRegCT2		:= 0
Local lGravaCT2		:= .T.
Local cStatusBlq	:= GetNewPar("MV_CTGBLOQ","")
Local cKeyCT2		:= ""
Local dDtCV3		:= CTOD("  /  /  ")
Local lDtTxUso		:= .F.
Local dDataAnt		:= CTOD("  /  /  ")
Local cLoteAnt		:= ""
Local cSbLoteAnt	:= ""
Local cDocAnt		:= ""
Local nDif			:= 0
Local nRecAlias		:= 0
Local cUltLin		:= ""
Local aRecnos		:= {}

//A variavel lReproc, sera utilizada na gravacao de saldos. Caso nao seja para atualizar
//os saldos no momento da grav. dos lanc. contab., ira atualizar o saldo somente da DATA.
//Analogo ao Reprocessamento.
Local lReproc		:= Iif(lAtSldBase,.F.,.T.)
Local aDecCols		:= {}
Local lPodeGrv		:= .F.
Local cCampo 		:= ""
Local cFilIni		:= ""
Local cFilFim		:= ""
Local cQuery		:= ""
Local lRetorno      := .T.
Local cMoeda        := ""
Local nMoedas       := 0
Local aArea         := {}
Local cTpSaldo      :=""
Local lTpSaldo      := .T. 
Local nSoma         := GetMv("MV_SOMA")
Local cTDataBase    := ""
Local aDataBase     := {}
Local nPos          := 0
Local lTrbProc
Local aResult		:= {}
                       
DEFAULT lBat := .F.

For nCont	:= 2 to __nQuantas
	If CtbUso("CT2_DTTX"+StrZero(nCont,2))			
		lDtTxUso		:= .T.
		Exit		
	EndIf
Next   

If Empty(cStatusBlq)
	cStatusBlq := "234"
Endif
aCols 		:= {}
aColsOri	:= {}

lRet := VlDtCal(mv_par01,mv_par02,mv_par03,mv_par04,cStatusBlq,!lBat,Trim(mv_par05))	/// VALIDA PERIODOS BLOQUEADOS NO CALENDARIO DENTRO DO INTERVALO DE DATAS 

If lRet

	cCampo := "SX5->(X5DESCRI())"
	// Verifica se existe apuracao na data, moeda e tipo de saldo informado.	
	dbSelectarea("SX5")
	dbSetOrder(1)
	If MsSeek(xFilial("SX5")+"LP"+cEmpAnt+cFilAnt, .F.)
		While SX5->(!Eof()) .and. SX5->X5_FILIAL = xFilial() .And. SubStr(SX5->X5_CHAVE,1,2) == cEmpAnt .And. SubStr(SX5->X5_CHAVE,3,2) == cFilAnt
  			If Substr(&cCampo, 1, 8) >= Dtos(mv_par01)
  				If Substr(&cCampo, 11, 1 ) = Trim(mv_par05)
  					If mv_par03 = 2 .or. (mv_par03 = 1 .and. Substr(&cCampo, 9, 2) = If(Empty(mv_par04),'00',Trim(mv_par04)))
  						If !lBat
	  						MsgAlert(STR0008) //"O Ajuste de Moedas nao deve ser executado para periodos que tiveram Apuracao de Resultados. Certifique-se de que nao existe apuracao de resultados na data, moeda e tipo de saldo informados "
	  					EndIf
  						lRet:= .f.
  						Exit
  					EndIf
  				EndIf
  			Endif
			SX5->(dbSkip())
		EndDo
	EndIf
Endif

If Empty(mv_par09)
	Help(NIL, NIL, STR0024 /*"Filial até"*/, NIL, STR0025/*"Parâmetro filial até, não foi informado"*/, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0026/*"Necessário informar o parâmetro filial até"*/})
	lRet := .F.	
EndIf

If !lRet
	Return
Endif

cFilIni := mv_par08	
cFilFim := mv_par09

aadd(aDatabase,{"MSSQL" })
aadd(aDatabase,{"MSSQL7" })
aadd(aDatabase,{"ORACLE" })
aadd(aDatabase,{"DB2" })
aadd(aDatabase,{"SYBASE" })
aadd(aDatabase,{"INFORMIX" })
If Trim(Upper(TcSrvType())) = "ISERIES"
	// Top 4 para AS400, instala procedures = DB2
	aadd(aDatabase,{"DB2/400"})
EndIf
cTDataBase = Trim(Upper(TcGetDb()))
nPos:= Ascan( aDataBase, {|z| z[1] == cTDataBase })

If nPos == 0
	lRetorno := .F.	
EndIf

If lRetorno
	//Reprocessa Saldos no periodo
	If mv_par07 = 1
		CTBA190(.T., mv_par01, mv_par02, cFilIni, cFilFim, mv_par05, If(mv_par03 = 2, .T., .F.), If(Empty(mv_par04), "00",mv_par04))
	EndIf
	aArea := GetArea()
	cMoeda   := ""
	If mv_par03 = 2  //moeda especifica
		cMoeda := Trim(mv_par04)
		If cMoeda != "01"
			nMoedas := 1
		EndIf
	else
		dbSelectArea("CTO")
		dbSetOrder(1)
		dbSeek(xFilial())
		While !Eof() .And. xFilial() == CTO->CTO_FILIAL
			If CTO->CTO_MOEDA != '01' .and. CTO->CTO_BLOQ = '2'
				nMoedas++
				cMoeda += CTO->CTO_MOEDA
			EndIf
			dbSkip()
		EndDo
	EndIf
	/* Ordem de chamada das procedures - NAO EXCLUIR OS COMENTARIOS
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Criacao de procedure de dinamica  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  1.  CTBA370Proc     - Pai - Chamador.................................... 
          1.1 CTBA370A    - Retorna o valor convertido........................ 
      0. CallXFilial - xfilial - Cria procedure xfilial Gestao Corporativa ...  */
		
	If nMoedas > 0
		If mv_par05 = '*'
			lTpSaldo := .F.
		EndIf
		cTpSaldo := Trim(mv_par05)
		If CTBInstPRC('38')
			aResult := TCSPExec(xProcedures('CTBA370A_38'), cFilIni, cFilFim, Dtos(mv_par01), Dtos(mv_par02),;
					If( lTpSaldo, "1", "0" ), cTpSaldo,       cMoeda,         StrZero(mv_par06,1), If( nSoma = 1, "1", "2"))
		EndIf
				
		TcRefresh(RetSqlName("CT2"))
		If Empty(aResult) .Or. aResult[1] = "0"
			If !lBat
				MsgAlert(STR0010)  //"Erro na Atualizacao de moedas com procedures. O processo sera realizado pelo processo padrao."
			EndIf
			lRetorno := .F.
		Else
			CTBA190(.T.,mv_par01,mv_par02,cFilIni,cFilFim,mv_par05,.F.,"00")
		EndIf
		RestArea(aArea)
	Else
		lRetorno := .F.
	EndIf
Endif

If lRetorno
	Return
EndIf

CriaConv()

If 	(Ascan(aCols, { |x| x[1] = mv_par04 }) = 0) .Or.;
	(Len(aCols) = 1 .And. Empty(aCols[1][1]))
	If Len(aCols) = 1 .And. Empty(aCols[1][1])
		aCols := {}
	Endif
	DbSelectArea("CTO")
	dbSeek(xFilial()+"01",.T.)
	AADD(aCols, { "01", " ", 0.00, "2", "1", 0.00, CTO->CTO_DESC, .F. } )
	aSort(aCols,,,{|X,Y| x[1] < y[1]})
Endif

If mv_par03 = 2 .And. (nColMoeda := Ascan(aCols, { |x| x[1] = mv_par04 })) > 0
	aCols := { aCols[nColMoeda] }
Endif

dbSelectArea("CTO")
dbSetOrder(1)
For nCont := 1 to Len(aCols)
	If dbSeek(xFilial("CTO")+aCols[nCont][1])
		aAdd(aDecCols,CTO->CTO_DECIM)
	Else
		aAdd(aDecCols,2)	
	EndIf
Next
											
aColsOri := aClone(aCols)
											
dbSelectArea("CT2")
dbSetOrder(1)
cOrder := IndexKey()

cAlias := "CT2QRY"
cQuery	:= "SELECT CT2.R_E_C_N_O_ RECNO FROM " + RetSqlName("CT2") + " CT2 "
cQuery 	+= "WHERE CT2_FILIAL = '" + xFilial("CT2") + "' AND "
cQuery 	+= "CT2_DATA >= '" + Dtos(mv_par01) + "' AND CT2_DATA <= '" + Dtos(mv_par02) + "' "
cQuery	+= "AND CT2_MOEDLC = '01' AND D_E_L_E_T_=' ' "
If mv_par05 != "*"
	cQuery += " AND CT2_TPSALD = '"+ mv_par05 + "'"
EndIf
//BOPS 139805                                                            //
//PE C370MODQRY -> PARA CRIACAO DE CONDICOES PARA SER INCLUIDO NA QUERY. //
//RETORNO -> CARACTER.                                                   //
///////////////////////////////////////////////////////////////////////////
If ExistBlock("C370CODQRY")
	cQuery+= " AND "+ExecBlock("C370CODQRY",.F.,.F.)
EndIf
		
cQuery += "ORDER BY " +  SqlOrder(cOrder) + ",R_E_C_N_O_"
	
cQuery := ChangeQuery(cQuery)
		                     
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

While ! Eof() .And. CT2->CT2_DATA <= mv_par02
	
	dbSelectArea("CT2")
	dbGoto((cAlias)->RECNO)
	
	If CT2->CT2_MOEDLC <> '01'
		dbSkip()
		Loop
	EndIf
	aCols := aClone(aColsOri)

	MontaConv(	CT2->CT2_VALOR,CT2->CT2_DC,CT2->CT2_DATA,,;
		CT2->CT2_DEBITO,CT2->CT2_CREDIT,CT2->CT2_MOEDLC, mv_par06 = 2,,!lBat)
				
	BEGIN TRANSACTION

    //Guarda registro ref. a primeira moeda
		nRecnoAnt	:= CT2->(Recno())
	// Grava demais moedas -> a partir de aCols        
		For nCont 	 := 1 To Len(aCols)
			dbSelectArea("CT2")
			dbGoto(nRecnoAnt)
			cMoed	 := aCols[nCont][1]
			nVal 	 := NoRound(aCols[nCont][3], aDecCols[nCont])
		
			nValMoeda:=CtbVlrMoed(CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_LINHA,CT2->CT2_TPSALD,cMoed,CT2->CT2_EMPORI,CT2->CT2_FILORI)
			cCriter  := aCols[nCont][2]

			If Empty(cCriter)
				cCriter:= aCols[nCont][2]
			EndIf
			IF cCriter != "A"
				If Empty(cMoed) .Or. cMoed = CT2->CT2_MOEDLC .Or.	nValMoeda = nVal 	//Taxa informada
					Loop
				EndIf
		
				If mv_par03 == 2 //Se for moeda especifica
					If cMoed <> mv_par04
						Loop
					EndIf
				EndIf

		//Se o criterio de conversão atual é Informado (4) ou Nao possui criterio de Conversao (5) e 
		//o lancamento possui valor nessa moeda, deletar o lancamento existente nessa moeda.						
				If nValMoeda <> 0 .And. nVal == 0 .And. cCriter $ "45"
					cLote		:= CT2->CT2_LOTE
					cSubLote	:= CT2->CT2_SBLOTE
					cDoc		:= CT2->CT2_DOC
					cLinha		:= CT2->CT2_LINHA
					cTpSald		:= CT2->CT2_TPSALD
					cEmpOri		:= CT2->CT2_EMPORI
					cFilOri		:= CT2->CT2_FILORI
					dData		:= CT2->CT2_DATA

			// Desativa a atualização de saldos ( Sera executada por reprocessamento )
					If SuperGetMv("MV_CTA370S",.F.,"1") == "1"
						dbSelectArea("CT2")
						dbSetOrder(1)
						nRegCT2	:= Recno()
						If MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cDoc+cLinha+cTpSald+cEmpOri+cFilOri+cMoed)
					//Se o criterio de conversao gravado no CT2 for "4", nao alterar valor. 
							If CT2->CT2_CRCONV <>  "4"
	
								aTravas := {}
			
								IF !Empty(CT2->CT2_DEBITO)
									AADD(aTravas,CT2->CT2_DEBITO)
								Endif
								IF !Empty(CT2->CT2_CREDIT)
									AADD(aTravas,CT2->CT2_CREDIT)
								Endif
							
						/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
								If CtbCanGrv(aTravas,@lAtSldBase)
				
									RecLock("CT2",.F.,.T.)
									dbDelete()
									MsUnlocK()
									dbGoto(nRegCT2)
						    
							// DesGravacao de Saldos  --> cOperacao "-"
									CtbGravSaldo(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,;
										CT2->CT2_DC,cMoed,CT2->CT2_DEBITO,;
										CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
										CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nVal,CT2->CT2_TPSALD,;
										4,CT2->CT2_DEBITO,;
										CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
										CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValMoeda,;
										CT2->CT2_DC,CT2->CT2_TPSALD,cMoed,;
										__lCusto,__lItem,__lClVL,,lAtSldBase,lReproc,CT2->CT2_DTLP,,,,,,,,,lTrbProc,"-"/*cOperacao*/)
								EndIf
							EndIf
						EndIf
						dbGoto(nRegCT2)
					EndIf
				Else

					cLote		:= CT2->CT2_LOTE
					cSubLote	:= CT2->CT2_SBLOTE
					cDoc		:= CT2->CT2_DOC
					cLinha		:= CT2->CT2_LINHA
					cTpSald		:= CT2->CT2_TPSALD
					cEmpOri		:= CT2->CT2_EMPORI
					cFilOri		:= CT2->CT2_FILORI
					dData		:= CT2->CT2_DATA
					cKeyCT2		:= CT2->CT2_KEY
					dDtCV3		:= CT2->CT2_DTCV3
                                         
					dbSelectArea("CT2")
					dbSetOrder(1)
					nRegCT2	:= Recno()
					If MsSeek(xFilial()+dtos(dData)+cLote+cSubLote+cDoc+cLinha+cTpSald+cEmpOri+cFilOri+cMoed)
						If CT2->CT2_CRCONV ==  "4"
							lGravaCT2	:= .F.
						EndIf
					EndIf
					dbGoto(nRegCT2)

					If lGravaCT2

						aTravas := {}
	
						IF !Empty(CT2->CT2_DEBITO)
							AADD(aTravas,CT2->CT2_DEBITO)
						Endif
						IF !Empty(CT2->CT2_CREDIT)
							AADD(aTravas,CT2->CT2_CREDIT)
						Endif
				
				/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVAÇÃO DOS LANÇAMENTOS/SALDOS
						If CtbCanGrv(aTravas,@lAtSldBase)
		
					// Desativa a atualização de saldos ( Sera executada por reprocessamento )
							If SuperGetMv("MV_CTA370S",.F.,"1") == "1"
						// DesGravacao de Saldos  --> cOperacao "-"
								CtbGravSaldo(	CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,;
									CT2->CT2_DC,cMoed,CT2->CT2_DEBITO,;
									CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
									CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nVal,CT2->CT2_TPSALD,;
									4,CT2->CT2_DEBITO,;
									CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
									CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValMoeda,;
									CT2->CT2_DC,CT2->CT2_TPSALD,cMoed,;
									__lCusto,__lItem,__lClVL,,lAtSldBase,lReproc,CT2->CT2_DTLP,,,,,,,,,lTrbProc,"-"/*cOperacao*/)

						// Gravacao dos Saldos de Contas
								CtbGravSaldo(	CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_DATA,;
									CT2->CT2_DC,cMoed,CT2->CT2_DEBITO,;
									CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
									CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nVal,CT2->CT2_TPSALD,;
									4,CT2->CT2_DEBITO,;
									CT2->CT2_CREDIT,CT2->CT2_CCD,CT2->CT2_CCC,CT2->CT2_ITEMD,;
									CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,nValMoeda,;
									CT2->CT2_DC,CT2->CT2_TPSALD,cMoed,;
									__lCusto,__lItem,__lClVL,,lAtSldBase,lReproc,CT2->CT2_DTLP,,,,,,,,,,"+"/*cOperacao*/)
					  
							EndIf
		    
							CtGrVlMoed(CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_LINHA,CT2->CT2_TPSALD,;
								cMoed,CT2->CT2_EMPORI,CT2->CT2_FILORI,nVal,;
								CT2->CT2_DC,CT2->CT2_DEBITO,CT2->CT2_DCD,CT2->CT2_CREDIT,CT2->CT2_DCC,CT2->CT2_CCD,CT2->CT2_CCC,;
								CT2->CT2_ITEMD,CT2->CT2_ITEMC,CT2->CT2_CLVLDB,CT2->CT2_CLVLCR,	CT2->CT2_LP,CT2->CT2_SEQUEN,;
								CT2->CT2_ORIGEM,CT2->CT2_AGLUT,cCriter,CT2->CT2_HP,CT2->CT2_HIST,CT2->CT2_SEQLAN,CT2->CT2_SEQHIS,;
								CT2->CT2_DTLP,CT2->CT2_SLBASE,cKeyCT2,dDtCV3)
						EndIf
					EndIf
					lGravaCT2	:= .T.
				EndIf
			EndIf
		Next nCont
	END TRANSACTION


	dDataAnt	:= CT2->CT2_DATA
	cLoteAnt	:= CT2->CT2_LOTE
	cSbLoteAnt	:= CT2->CT2_SBLOTE
	cDocAnt		:= CT2->CT2_DOC
	cUltLin		:= CT2->CT2_LINHA
	
	DbSelectArea(cAlias)
	DbSkip()

	dbSelectArea("CT2")
	dbGoto((cAlias)->RECNO)
	
	//Se mudar o documento, verificar o total debito/credito nas outras moedas.		

	nRecAlias		:= CT2->(Recno())
	
	If DTOS(dDataAnt) <> DTOS(CT2->CT2_DATA) .Or. cLoteAnt <> CT2->CT2_LOTE .Or. ;
			cSbLoteAnt	<> CT2->CT2_SBLOTE .Or. cDocAnt <> CT2->CT2_DOC
		
		For nCont := 1 to Len(aCols)
			If StrZero(nCont,2) == '01'
				Loop
			EndIf

			aRecnos 	:= {}
			//Se houver diferenca debito/credito em outra moeda, gera a diferença na ultima linha	
			nDif := Ctba370DIf(dDataAnt,cLoteAnt,cSbLoteant,cDocAnt,StrZero(nCont,2),@aRecnos)

			If nDif <> 0  .And. ( Abs( nDif ) <= 0.02 )	// Diferenca menor que 2 centavos.
				dbSelectArea("CT2")
				If nDif > 0 				//Alterar a diferenca a debito
					dbgoto(aRecnos[1][2])
				ElseIf nDif < 0
					dbgoto(aRecnos[2][2])
				EndIf

				RecLock( "CT2" , .F. )

				CT2->CT2_VALOR	+= Abs( nDif )

				MsUnlock()
			EndIf
			
		Next
		
	EndIf
	dbSelectArea("CT2")
	dbGoto(nRecAlias)
	
EndDo

dbSelectArea(cAlias)
dbCloseArea()

dbSelectArea("CT2")
dbSetOrder(1)

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ctba370Dif³ Autor ³ Simone Mie Sato       ³ Data ³ 09.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o total debito/credito na outra moeda.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ca370VlDoc)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data                                               ³±±
±±³          ³ ExpC1 = Lote                                               ³±±
±±³          ³ ExpC2 = SubLote                                            ³±±
±±³          ³ ExpC3 = Documento                                          ³±±
±±³          ³ ExpC4 = Moeda                                              ³±±
±±³          ³ ExpA1 = Matriz com os ult. reg. debito e credito           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba370DIf(dDataLan,cLoteLan,cSbLoteLan,cDocLan,cMoedaLan,aRecnos)

Local aSaveArea	:= GetArea()
Local nDebito	:= 0
Local nCredito	:= 0 
Local nDif		:= 0 
Local nCont		:= 0

For nCont	:= 1 to 2
	AADD(aRecnos,{Str(ncont,1),0})
Next

dbSelectArea("CT2")
dbSetOrder(1)
If MsSeek(xFilial()+DTOS(dDataLan)+cLoteLan+cSbLoteLan+cDocLan)
	While !Eof() .And. xFilial() == CT2->CT2_FILIAL  .And. DTOS(dDataLan) == DTOS(CT2->CT2_DATA) .And. ;
		CT2->CT2_LOTE == cLoteLan .And. CT2->CT2_SBLOTE == cSbLoteLan .And. CT2->CT2_DOC == cDocLan 
		
		If CT2->CT2_MOEDLC <> cMoedaLan
			dbSkip()
			Loop
		EndIf		
	
		If CT2->CT2_DC $ "1/3"	
			nDebito	+= CT2->CT2_VALOR
			If CT2->CT2_DC == "1"
				aRecnos[1][2]	:= CT2->(Recno())
			EndIf				
		EndIf
		
		If CT2->CT2_DC $ "2/3"
			nCredito += CT2->CT2_VALOR
			If CT2->CT2_DC == "2"
				aRecnos[2][2]	:= CT2->(Recno())		
			EndIF
		EndIf				
		
       dbSkip()
	End
EndIf        

nDif := NoRound(Round(nCredito,3)) - NoRound(Round(nDebito,3)) 

RestArea(aSaveArea)

Return(nDif)

//-------------------------------------------------------------------
/*/{Protheus.doc} ScheDef()

Definição de Static Function SchedDef para o novo Schedule

@author TOTVS
@since 03/06/2021
@version MP12
/*/
//-------------------------------------------------------------------

Static Function SchedDef()

Local aParam := {}

aParam := { "P",;            // Tipo R para relatório P para processo
			"CTB370",;       // Pergunte do relatório, caso não use, passar ParamDef
			,;               // Alias     
			,;               // Array de ordens
			STR0001,;        // Título
			,;				 // Nome do Relatório
			.T.,;			 // Indica se permite que o agendamento possa ser cadastrado como sempre ativo
			.F. }			 // Indica que o agendamento pode ser realizado por filiais


Return aParam




//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngSPSXXSignature()
Controle de assinatura da procedure

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngSPS38Signature()	
Return "001"

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngPre38Compile()
Ponto de entrada antes da compilação da procedure, antes do MSParse

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngPre38Compile(cProcesso as character, cEmpresa as character, cError as character)

Return .T.

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngOn38Compile()
Ponto de durante a compilação da procedure, antes do MSParse

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngOn38Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character)
	Local cDeclare 	 := '' as character
	Local cZeramento := '' as character
	Local cSelectD 	 := '' as character
	Local cSelectC 	 := '' as character
	Local cCriterioD := '' as character
	Local cCriterioC := '' as character
	Local cStrZero 	 := '' as character
	Local nQuantas 	 := 0  as Numeric
	Local nX         := 0  as Numeric

	If cProcName == 'CTBA370A'
		nQuantas 	 := QntMoedas()
		For nX := 2 to nQuantas
			cStrZero := STRZERO(nX, 2)
			cDeclare +="Declare @cCT1_CVD" + cStrZero + " Char(01)"+CRLF
			cDeclare +="Declare @cCT1_CVC" + cStrZero + " Char(01)"+CRLF
			cZeramento += "SELECT  @cCT1_CVD" + cStrZero + " = ' ' " +CRLF
			cZeramento += "SELECT  @cCT1_CVC" + cStrZero + " = ' ' " +CRLF
			cSelectD += ", @cCT1_CVD" + cStrZero +  " = CT1_CVD" + cStrZero + CRLF
			cSelectC += ", @cCT1_CVC" + cStrZero +  " = CT1_CVC" + cStrZero + CRLF
			cCriterioD += "IF @cMoeda = '"+ cStrZero +"'"+CRLF + "BEGIN"+ CRLF
			cCriterioD += "SELECT @cCriterio = @cCT1_CVD"+ cStrZero + CRLF + "END" + CRLF
			cCriterioC += "IF @cMoeda = '"+ cStrZero +"'"+CRLF + "BEGIN"+ CRLF
			cCriterioC += "SELECT @cCriterio = @cCT1_CVC"+ cStrZero + CRLF + "END"+ CRLF
		Next
		cBuffer := StrTran( cBuffer, "Declare @cTratar Char( 01 )", cDeclare )
		cBuffer := StrTran( cBuffer, "SELECT @cData = ' '", "SELECT @cData = ' '" + CRLF + cZeramento )
		cBuffer := StrTran( cBuffer, "SELECT @iRecnoCT1 = IsNull(R_E_C_N_O_, 0)", "SELECT @iRecnoCT1 = IsNull(R_E_C_N_O_, 0) " + cSelectD + CRLF , ,1 )
		cBuffer := StrTran( cBuffer, "SELECT @iRecnoCT1 = IsNull(R_E_C_N_O_, 0)", "SELECT @iRecnoCT1 = IsNull(R_E_C_N_O_, 0) " + cSelectC + CRLF ,2, 1  )
		cBuffer := StrTran( cBuffer, "SELECT @cMoeda = 'TR'",  cCriterioD + CRLF  , ,1 )
		cBuffer := StrTran( cBuffer, "SELECT @cMoeda = 'TR'",  cCriterioC + CRLF )
	EndIf

Return .T.

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngPos38Compile()
Ponto de entrada após a compilação da procedure, depois do MSParse

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngPos38Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)
Return  .T.


//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} QntMoedas()
CALCULA A MAIOR QUANTIDADE DE MOEDAS DE ACORDO COM O GRUPO DE EMPRESA

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Static Function QntMoedas()

	Local nQuantas := 0 as Numeric
	Local cQuery   := '' as Character
	Local aArea	   := GetArea() AS Array

	cQuery :=   "SELECT MAX(NCONT) AS NMOEDAS FROM " +;
				" ( SELECT COUNT(CTO_FILIAL) NCONT FROM "+RetSqlName("CTO")  +;
				" WHERE  D_E_L_E_T_ = ' ' " +;
	            " GROUP BY CTO_FILIAL ) BASE"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'CTDMOEDA', .F., .T.)
	// TcSetField('CTDMOEDA',"NCONT","N",10,0)
	nQuantas := CTDMOEDA->NMOEDAS
	CTDMOEDA->( dbCloseArea() )

	RestArea(aArea)
	FwFreeArray(aArea)

return nQuantas 
