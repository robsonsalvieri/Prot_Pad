#Include "CTBA231.Ch"
#Include "PROTHEUS.Ch"
#Include "FONT.CH"
#Include "COLORS.CH"

STATIC __lBlind 	:= IsBlind()
STATIC nMAX_LINHA	:= CtbLinMax(GetMv("MV_NUMLIN"))
STATIC __lCtbIsCube := NIL
STATIC oTable		:= NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ctba231  ³ Autor  ³ Marcelo Akama           ³ Data 21.05.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Aglutina‡„o de dados Configurada. (Modelo B)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ctba231()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ lBat - Indica se será executada com BatchProcess           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctba231(lBat)

Local cCadastro:= STR0001  		//"Consolida‡„o de Empresas / Filiais"

Local cMensagem:= ""

Local nOpca
Local aSays 		:= {}
Local aButtons		:= {}
Local lret

Private cMaxLin		:= strzero(nMAX_LINHA,3)

If lBat == nil
	lBat := .F.
EndIf

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If CTB->(FieldPos("CTB_HAGLUT"))<=0 // Verifica se a base está atualizada
	MsgAlert(STR0013) // "Execute o compatibilizador para o correto funcionamento da rotina"
	Return
Endif

If __lCtbIsCube == nil
	__lCtbIsCube := CtbIsCube()
EndIf

If Ctb240Emp() //Se estiver na empresa/filial DESTINO (de acordo com o param. MV_CONSOLD
	If __lBlind .Or. lBat
		BatchProcess( 	cCadastro, 	STR0007+chr(13)+chr(10)+STR0008, "CTB231", { || Ct231Proc(.T.) }, { || .F. }  )
		Return .T.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra tela de aviso - processar exclusivo			         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMensagem := STR0005+chr(13)  		//"E melhor que os arquivos associados a esta rotina nao estejam em uso por outras estacoes."
	cMensagem += STR0006+chr(13)  		//"Faca com que os outros usuarios saiam do sistema."
	    IF !MsgYesNo(cMensagem,STR0004)		//"ATEN€ŽO"
			Return
		Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par12     // Cod. Roteiro Consolidacao                    ³
	//³ mv_par02     // da data                                      ³
	//³ mv_par03     // Ate a data                                   ³
	//³ mv_par04     // Apaga? Periodo/Tudo                   		 ³
	//³ mv_par05     // Escolhe Moeda?                               ³
	//³ mv_par06     // Qual Moeda?                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("CTB231",.f.)
	AADD(aSays,STR0007 )	//Este programa tem como objetivo aglutinar os lancamentos conforme configurado
	AADD(aSays,STR0008 )	//pelo usuario na Rotina de Consolidacao.
	AADD(aSays,' ' )	//
	
	AADD(aButtons, { 5,.T.,{|| Pergunte("CTB231",.T. ) } })
	AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CtbOk(), FechaBatch(), nOpca:=0 ) }} )
	AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
		
	FormBatch( cCadastro, aSays, aButtons,, 160 )
	
	IF nOpca == 1 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
		//³VALIDACAO DE AMARRAÇÕES E BLOQUEIOS DE MOEDA/CALENDARIO³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
			MsgRun(STR0025, STR0030, {|| lRet := !CtVlDTMoed(mv_par02,mv_par03,mv_par05,mv_par06) })   // "Validação moedas"
	        MsgRun(STR0025, STR0031, {|| lRet := lRet .And. Ct231VldSld()})								// "Validação Saldos"
		
		If lRet 
			If mv_par08 == 1  // Gera Saldo Inicial
				If mv_par04 = 1  // Limpa periodo
					dbSelectArea("CT2")
					dbSetOrder(1)
					If dbSeek(xFilial("CT2")+DTOS(mv_par02-1),.F.)
						If !__lBlind
							MsgInfo(STR0018)   //"Ja existem dados na data de saldo inicial, saldo inicial nao sera gerado."
						EndIf
						mv_par08 := 2
					EndIf
				EndIf
			EndIf
			
			MsgRun(STR0025, STR0024, {|lEnd| CT231Proc()})
		EndIf
		
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ct231Proc³ Autor  ³ Marcelo Akama           ³ Data 22.05.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Inicia o processamento dos arquivos de consolidacao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct231Proc() - Baseado na Ct230Proc()                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ N„o h                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231Proc(lBat)

Local dDataIni	:= mv_par02
Local dDataFim	:= mv_par03
Local nMoedas 	:= 0
Local cMoeda 	:= ""
Local aEmpOri	:= {}
Local aEmpOriEnt:= {}
Local lDelFisico:= GetNewPar('MV_CTB230D',.T.)
Local cArquivo
Local aAlias 	:= {}
Local cChave    := ""
Local cQuery	:= ""
Local nMax		:= 0
Local nX
Local i
Local aModSX2 := {}
Local aModCTI := {}
Local aModCT4 := {}
Local aModCT3 := {}
Local aModCT7 := {}
Local aModCVX := {}
Local cArqCTI := {}
Local cArqCT4 := {}
Local cArqCT3 := {}
Local cArqCT7 := {}
Local cArqCVX := {}
Local lDefTop := IfDefTopCTB() .and. Upper(Alltrim(TcGetDb())) != 'INFORMIX' // verificar se pode executar query (TOPCONN)
Local cAliasCTB := ""  
Local aEmpCT2 := {}

If lBat == nil
	lBat := .F.
EndIf

If CTB->(FieldPos("CTB_HAGLUT"))<=0 // Verifica se a base está atualizada
	MsgAlert(STR0013) // "Execute o compatibilizador para o correto funcionamento da rotina"
	Return
Endif

If mv_par05 == 2						// Considera Moeda Especifica
	aCtbMoeda  	:= CtbMoeda(mv_par06)
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		TRB->(DbCloseArea())
		Return .F.
	EndIf
	nMoedas  := 1
	cMoeda := aCtbMoeda[1]
Else
	nMoedas := __nQuantas
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
//³VALIDACAO DE AMARRAÇÕES E BLOQUEIOS DE MOEDA/CALENDARIO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄC
If CtVlDTMoed(dDataIni,dDataFim,mv_par05,mv_par06)
	// Se houver moeda, data ou data em moeda com status bloqueado.
	Return .F.
EndIf

If	!(	MA280FLock("CT1") .And.;
		MA280FLock("CT2") .And.;
		MA280FLock("CQ0") .And.;
		MA280FLock("CQ1") .And.;
		MA280FLock("CQ2") .And.;
		MA280FLock("CQ3") .And.;
		MA280FLock("CQ4") .And.;
		MA280FLock("CQ5") .And.;
		MA280FLock("CQ6") .And.;
		MA280FLock("CQ7") .And.;
		MA280FLock("CTC") .And.;
		MA280FLock("CTD") .And.;
		MA280FLock("CTF") .And.;
		MA280FLock("CTH") .And.;
		MA280FLock("CTC") .And.;
		MA280FLock("CTB") .And.;
		MA280FLock("CTT") .And.;
		MA280FLock("CVX") .And.;
		MA280FLock("CVY") )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha todos os arquivos e reabre-os de forma compartilhada   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbCloseAll()
	OpenFile(SubStr(cNumEmp,1,2))
	Return .T.
EndIf

If mv_par01 == 1
	If lDelFisico
		If mv_par04 == 2					// Apaga os arquivos
			If lDefTop
				aAlias := {"CT2","CQ0","CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CQ8","CQ9","CTC","CTF","CVX","CVY"}
				For i := 1 to Len(aAlias)
					If AliasInDic(aAlias[i])
						nMax := (aAlias[i])->(LastRec())
						cQuery := "DELETE FROM "+RetSqlName(aAlias[i])
						cQuery += " WHERE "
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						For nX := 1 To nMax STEP 1024
							cChave := "R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+1023,10,0)+""
							TcSqlExec(cQuery+cChave)
						Next nX
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³A tabela eh fechada para restaurar o buffer da aplicacao³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea(aAlias[i])
						dbCloseArea()
						ChkFile(aAlias[i],.F.)
					EndIf
				Next
			EndIf
		Else						// Zera somente o periodo informado
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Zera valores de saldos no periodo a consolidar     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Ct231Apaga()
		EndIf
		sleep(1000) // Delay para bases com poucos lançamentos, pois nao da tempo de limpar as tabelas antes do insert
	Endif
Else	/// Caso não apague os lançamentos na empresa consolidadora.
	dbSelectArea("CT2")
	dbSetOrder(1)
	dbSeek(xFilial("CT2")+DTOS(mv_par02),.T.)
	If !Eof() .and. CT2->CT2_DATA <= mv_par03
		If ! __lBlind
			If !MsgNoYes(STR0014+;//"Existem lançamentos na empresa consolidadora neste período. "
				STR0015+;//"(Recomendado processamento apagando período a ser consolidado)."
				STR0016,;//" Deseja realmente continuar ? "
				STR0017)//"Periodo já consolidado !"
				Return
			EndIf
		EndIf
	EndIf
EndIf

If lDefTop
	cNomeArq:=CriaTrab( nil, .F. )
	cQuery := " SELECT CTB_EMPORI EMP FROM "+RETSQLNAME('CTB')+" WHERE CTB_CODIGO BETWEEN '"+MV_PAR12+"' AND '"+MV_PAR13+"' AND D_E_L_E_T_=' ' GROUP BY CTB_EMPORI ORDER BY CTB_EMPORI "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNomeArq)
	While (cNomeArq)->(!Eof())

		Ct231Alias("CT2",@aModSX2,@cArquivo,(cNomeArq)->EMP)
		AADD(aEmpCT2,{(cNomeArq)->EMP,aModSX2 })

		If __lCtbIsCube
			Ct231Alias("CVX",@aModCVX ,@cArqCVX,(cNomeArq)->EMP)
			Ct231Alias("CT2",@aModSX2,@cArquivo,(cNomeArq)->EMP)
			AADD(aEmpOri,{(cNomeArq)->EMP,{aModCVX,cArqCVX}})
			AADD(aEmpOriEnt,{(cNomeArq)->EMP,{aModSX2,cArquivo}})
		Else
			Ct231Alias("CT2",@aModSX2,@cArquivo,(cNomeArq)->EMP)
			Ct231Alias("CQ7",@aModCTI ,@cArqCTI,(cNomeArq)->EMP)
			Ct231Alias("CQ5",@aModCT4 ,@cArqCT4,(cNomeArq)->EMP)
			Ct231Alias("CQ3",@aModCT3 ,@cArqCT3,(cNomeArq)->EMP)
			Ct231Alias("CQ1",@aModCT7 ,@cArqCT7,(cNomeArq)->EMP)
			AADD(aEmpOri,{(cNomeArq)->EMP,{aModSX2,cArquivo},{aModCTI,cArqCTI},{aModCT4,cArqCT4},{aModCT3,cArqCT3},{aModCT7,cArqCT7}})
		EndIf
		(cNomeArq)->(DbSkip())
	End

	(cNomeArq)->(dbCloseArea())

	If CT231TbCTB(@cAliasCTB,aEmpCT2)
		If mv_par08 == 1
			iF __lCtbIsCube
				Ct231SldIni(aEmpOri,cAliasCTB)  /* Lancatos Slds Iniciais com NOVAS ENTIDADES */
			Else
				Ct231SlInP(aEmpOri,cAliasCTB)  /* Lancatos Slds Iniciais entidades básicas */
			EndIf
		EndIf
		
		If __lCtbIsCube
			Ct231ExecP(aEmpOriEnt,cAliasCTB)
		Else
			Ct231ExecP(aEmpOri,cAliasCTB)
		EndIf
		
		//Atualiza o cashe do DBAccess após executar a procedure
		TCRefresh( RetSqlName("CT2") )
		
		MsErase(cAliasCTB,,"TOPCONN")
	EndIf
	
EndIf

If mv_par16 == 1
	//CHAMA O REPROCESSAMENTO PARA ATUALIZAR OS SALDOS.
	/// ATUALIZA OS SALDOS AO FINAL DO PROCESSAMENTO
	oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T., IIf( mv_par08 == 1, mv_par02-1, mv_par02 ),mv_par03,cFilAnt,cFilAnt,mv_par07,mv_par05 == 2,mv_par06)		},"","",.F.)
	oProcess:Activate()
EndIf
 
// PONTO DE ENTRADA UTILIZADO PARA MANIPULAR AS INFORMACOES DO LANCAMENTO CONTABIL DE DESTINO APOS A GRAVACAO NA TABELA CT2
If ExistBlock("Ct231PosGrv")
	ExecBlock("Ct231PosGrv",.F.,.F.)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231Ok   ³ Autor  ³ Simone Mie Sato         ³ Data 10.07.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Confirma processamento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct231Ok()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Mensagem para confirmacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231OK()

Local cMensagem
Local cCodEmp	:= FWGRPCompany()
Local cNomeEmp := FWFilialName(cEmpAnt,cFilAnt,2)
Local cCodFil	:= FWGETCODFILIAL
Local cNomeFil	:= FWFilialName(cEmpAnt,cFilAnt,1)

If mv_par01 == 1
	cMensagem := STR0010+chr(13)		//"Os dados da empresa abaixo serao apagados"
	cMensagem += STR0002+cCodEmp+"-"+cNomeEmp+chr(13) //"Empresa : "
	cMensagem += STR0003+cCodFil+"-"+cNomeFil+chr(13)//"Filial  : "
	cMensagem += STR0010				//"Confirma Consolidacao nesta empresa?"
Else
	cMensagem := STR0010+chr(13)  //"Confirma Consolidacao nesta empresa?"
	cMensagem += STR0002+cCodEmp+"-"+cNomeEmp+chr(13) //"Empresa : "
	cMensagem += STR0003+cCodFil+"-"+cNomeFil        //"Filial : "
EndIf
Return MsgYesNo(cMensagem,STR0004)  //"Aten‡„o"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231Alias³ Autor  ³ Simone Mie Sato         ³ Data 10.07.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Abre arquivo origem                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct231Alias(cAlias,cModoSX2,cArquivo)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ExpC1 = Alias do arquivo                                    ³±±
±±³           ³ExpC2 = Modo de acesso                                      ³±±
±±³           ³ExpC3 = Nome do arquivo                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231Alias(cAlias,aModSX2,cArquivo,cEmpAlias)
Local lRet := .T.

aModSX2 := {}

Aadd(aModSX2,FWModeAccess(cAlias,1,cEmpAlias))
Aadd(aModSX2,FWModeAccess(cAlias,2,cEmpAlias))
Aadd(aModSX2,FWModeAccess(cAlias,3,cEmpAlias))

cArquivo := Trim(RetFullName(cAlias,cEmpAlias))

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231Apaga³ Autor  ³ Simone Mie Sato         ³ Data 10.07.01³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Apaga periodo desejado                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct231Apaga()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231Apaga()

Local dDataIni := mv_par02
Local dDataFim := mv_par03
Local aAlias	:= {}
Local cChave	:= ""
Local cQuery	:= ""
Local Ct231Del	:= ""
Local nCountReg:= 0
Local nMax		:= 0
Local nMin		:= 0
Local i         := 0

aAlias := {"CT2","CQ0","CQ1","CQ2","CQ3","CQ4","CQ5","CQ6","CQ7","CTC","CTF","CVX","CVY"}
For i := 1 to Len(aAlias)
	If AliasInDic(aAlias[i])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica qual eh o maior e o menor Recno que satisfaca a selecao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Ct231Del	:= "Ct231Del"
		
		cQuery := "SELECT R_E_C_N_O_ RECNO "
		cQuery += "FROM "+RetSqlName(aAlias[i])
		cQuery += " WHERE " +aAlias[i]+"_FILIAL = '" + xFilial(aAlias[i])+"' AND "
		cQuery += aAlias[i]+"_DATA >= '" + DTOS(dDataIni)+ "' AND "
		cQuery += aAlias[i]+"_DATA <= '" + DTOS(dDataFim)+ "' AND "
		cQuery += " D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY RECNO"
		
		cQuery := ChangeQuery(cQuery)
		
		If ( Select ( "Ct231Del" ) <> 0 )
			dbSelectArea ( "Ct231Del" )
			dbCloseArea ()
		Endif
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),Ct231Del)
		
		dbSelectArea(aAlias[i])
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta a string de execucao no banco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := "DELETE FROM "+RetSqlName(aAlias[i])
		cQuery += " WHERE " + aAlias[i]+"_FILIAL = '" + xFilial(aAlias[i])+"' AND "
		cQuery += aAlias[i]+"_DATA >= '" + DTOS(dDataIni)+ "' AND "
		cQuery += aAlias[i]+"_DATA <= '" + DTOS(dDataFim)+ "' AND "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa a string de execucao no banco para os proximos 1024 registro a fim de nao estourar o log do SGBD³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While Ct231Del->(!Eof())
			
			nMin := (Ct231Del)->RECNO
			
			nCountReg := 0
			
			While Ct231Del->(!Eof()) .and. nCountReg <= 4096
				
				nMax := (Ct231Del)->RECNO
				nCountReg++
				Ct231Del->(DbSkip())
				
			End
			
			cChave := "R_E_C_N_O_>="+Str(nMin,10,0)+" AND R_E_C_N_O_<="+Str(nMax,10,0)+""
			TcSqlExec(cQuery+cChave)
			
		End
		dbCloseArea()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A tabela eh fechada para restaurar o buffer da aplicacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(aAlias[i])
		dbCloseArea()
		ChkFile(aAlias[i],.F.)
	EndIf
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231RCons³ Autor  ³ Marcelo Akama           ³ Data 26.05.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Aglut dos lancamentos de acordo com roteiro de consolidacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct231RCons(dDataIni,dDataFim,cMoeda,nMoedas,cCodigo,cFilX) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ExpD1 = Data Inicial (se nil, saldo inicial ate data final) ³±±
±±³           ³ExpD2 = Data Final                                          ³±±
±±³           ³ExpC1 = Moeda                                               ³±±
±±³           ³ExpN1 = Numero de Moedas                                    ³±±
±±³           ³ExpC2 = Codigo da Empresa                                   ³±±
±±³           ³ExpC3 = Codigo da Filial                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231RCons(dDataIni,dDataFim,cMoeda,nMoedas,cCodigo,cFilx)

Local aSaveArea := GetArea()
Local aSaldoLanc:=	{}
Local lConta 	:= .F.
Local lCusto	:= .F.
Local lItem		:= .F.
Local lClasse	:= .F.
Local cFilAntX  := cFilX
Local dDataAtu 	:= CriaVar("CQ1_DATA")
Local cCodCta 	:= ""
Local cCodCC	:= ""
Local cCodItem	:= ""
Local cCodEmp	:= ""
Local cDescHP
Local lIni		:= empty(dDataIni)

If lIni
	dDataIni := Space(8)
EndIf

// Recarrega variaveis
lConta 	:= .F.
lCusto	:= .F.
lItem	:= .F.
lClasse	:= .F.

If !Empty(CTB->CTB_CT1INI) .And. !Empty(CTB->CTB_CT1FIM)	// Tem Conta
	lConta := .T.
EndIf
If !Empty(CTB->CTB_CTTINI) .And. !Empty(CTB->CTB_CTTFIM)	// Tem C.Custo
	lCusto := .T.
Endif
If !Empty(CTB->CTB_CTDINI) .And. !Empty(CTB->CTB_CTDFIM)	// Tem Item
	lItem := .T.
Endif
If !Empty(CTB->CTB_CTHINI) .And. !Empty(CTB->CTB_CTHFIM)	// Tem Classe
	lClasse := .T.
Endif

cCodemp := CTB->CTB_EMPORI

// Abre a area "Aglutina" -> dados origem

If lCusto
	cCodCC := CTB->CTB_CCDES
Else
	cCodCC := ""
Endif

If lConta
	cCodCta := CTB->CTB_CTADES
Else
	cCodCta := ""
Endif

If lItem
	cCodItem := CTB->CTB_ITEMDE
Else
	cCodItem := ""
Endif


// Debito

dbSelectArea("Aglutina")

cFilX := xFilial("CT2",cFilX)
If lClVl
	dbSetOrder(8)
	dbSeek(cFilX +CTB->CTB_CTHINI+dtos(dDataIni),.T.)
ElseIf lItem
	dbSetOrder(6)
	dbSeek(cFilX +CTB->CTB_CTDINI+dtos(dDataIni),.T.)
ElseIf lCusto
	dbSetOrder(4)
	dbSeek(cFilX +CTB->CTB_CTTINI+dtos(dDataIni),.T.)
Else
	dbSetOrder(2)
	dbSeek(cFilX +CTB->CTB_CT1INI+dtos(dDataIni),.T.)
EndIf

While !Eof() .And. Aglutina->CT2_DATA <= dDataFim .And. Aglutina->CT2_DATA >= dDataIni
	
	If 	!( Aglutina->CT2_DC $ '13' )
		dbSkip()
		Loop
	Endif
	
	If 	( lClVl .And. ( Aglutina->CT2_CLVLDB > CTB->CTB_CTHFIM .Or. ( !lIni .and. Aglutina->CT2_CLVLDB < CTB->CTB_CTHINI ) ) ) ;
		.or. ( !lClVl .and. !empty(Aglutina->CT2_CLVLDB) )
		dbSkip()
		Loop
	Endif
	
	If 	lItem .And. ( Aglutina->CT2_ITEMD > CTB->CTB_CTDFIM .Or. ( !lIni .and. Aglutina->CT2_ITEMD < CTB->CTB_CTDINI ) ) ;
		.or. ( !lItem .and. !empty(Aglutina->CT2_ITEMD) )
		dbSkip()
		Loop
	Endif
	
	If 	lCusto .And. ( Aglutina->CT2_CCD > CTB->CTB_CTTFIM .Or. ( !lIni .and. Aglutina->CT2_CCD < CTB->CTB_CTTINI ) ) ;
		.or. ( !lCusto .and. !empty(Aglutina->CT2_CCD) )
		dbSkip()
		Loop
	Endif
	
	If 	lConta .And. ( Aglutina->CT2_DEBITO > CTB->CTB_CT1FIM .Or. ( !lIni .and. Aglutina->CT2_DEBITO < CTB->CTB_CT1INI ) ) ;
		.or. ( !lConta .and. !empty(Aglutina->CT2_DEBITO) )
		dbSkip()
		Loop
	Endif
	
	If mv_par05 == 2 .and. Aglutina->CT2_MOEDLC <> cMoeda
		dbSkip()
		Loop
	Endif
	
	If Aglutina->CT2_TPSALD <> CTB->CTB_TPSLDO
		dbSkip()
		Loop
	Endif
	
	If lIni
		dDataAtu := dDataFim
	Else
		dDataAtu := Aglutina->CT2_DATA
	EndIf
	//Calculo os Saldos de acordo com o Roteiro de Consolidacao
	aSaldoLanc := Ct231SldCn(CTB->CTB_CT1INI,CTB->CTB_CT1FIM,CTB->CTB_CTTINI,CTB->CTB_CTTFIM,CTB->CTB_CTDINI,;
	CTB->CTB_CTDFIM,CTB->CTB_CTHINI,CTB->CTB_CTHFIM,dDataAtu,Aglutina->CT2_MOEDLC,CTB->CTB_TPSLDO,cFilx,;
	lConta,lCusto,lItem,.T.,.T.,@cDescHP,lIni)
	
	cKey := ('D'+DTOS(dDataAtu)+CTB->CTB_CTADES+CTB->CTB_CCDES+CTB->CTB_ITEMDE+CTB->CTB_CLVLDE+Aglutina->CT2_MOEDLC+CTB->CTB_TPSLDE)
	Ct231GrTrb(cKey,Aglutina->CT2_MOEDLC,aSaldoLanc,dDataAtu,cDescHP,'D',lIni)
	aSaldoLanc:= {}
	dbSelectArea("Aglutina")
End

// Credito

dbSelectArea("Aglutina")

If lClVl
	dbSetOrder(9)
	dbSeek(cFilX +CTB->CTB_CTHINI+dtos(dDataIni),.T.)
ElseIf lItem
	dbSetOrder(7)
	dbSeek(cFilX +CTB->CTB_CTDINI+dtos(dDataIni),.T.)
ElseIf lCusto
	dbSetOrder(5)
	dbSeek(cFilX +CTB->CTB_CTTINI+dtos(dDataIni),.T.)
Else
	dbSetOrder(3)
	dbSeek(cFilX +CTB->CTB_CT1INI+dtos(dDataIni),.T.)
EndIf

While !Eof() .And. Aglutina->CT2_DATA <= dDataFim .And. Aglutina->CT2_DATA >= dDataIni
	
	If 	!( Aglutina->CT2_DC $ '23' )
		dbSkip()
		Loop
	Endif
	
	If 	lClVl .And. ( Aglutina->CT2_CLVLCR > CTB->CTB_CTHFIM .Or. ( !lIni .and. Aglutina->CT2_CLVLCR < CTB->CTB_CTHINI ) ) ;
		.or. ( !lClVl .and. !empty(Aglutina->CT2_CLVLCR) )
		dbSkip()
		Loop
	Endif
	
	If 	lItem .And. ( Aglutina->CT2_ITEMC > CTB->CTB_CTDFIM .Or. ( !lIni .and. Aglutina->CT2_ITEMC < CTB->CTB_CTDINI ) ) ;
		.or. ( !lItem .and. !empty(Aglutina->CT2_ITEMC) )
		dbSkip()
		Loop
	Endif
	
	If 	lCusto .And. ( Aglutina->CT2_CCC > CTB->CTB_CTTFIM .Or. ( !lIni .and. Aglutina->CT2_CCC < CTB->CTB_CTTINI ) ) ;
		.or. ( !lCusto .and. !empty(Aglutina->CT2_CCC) )
		dbSkip()
		Loop
	Endif
	
	If 	lConta .And. ( Aglutina->CT2_CREDIT > CTB->CTB_CT1FIM .Or. ( !lIni .and. Aglutina->CT2_CREDIT < CTB->CTB_CT1INI ) ) ;
		.or. ( !lConta .and. !empty(Aglutina->CT2_CREDIT) )
		dbSkip()
		Loop
	Endif
	
	If mv_par05 == 2 .and. Aglutina->CT2_MOEDLC <> cMoeda
		dbSkip()
		Loop
	Endif
	
	If Aglutina->CT2_TPSALD <> CTB->CTB_TPSLDO
		dbSkip()
		Loop
	Endif
	
	If lIni
		dDataAtu := dDataFim
	Else
		dDataAtu := Aglutina->CT2_DATA
	EndIf
	//Calculo os Saldos de acordo com o Roteiro de Consolidacao
	aSaldoLanc := Ct231SldCn(CTB->CTB_CT1INI,CTB->CTB_CT1FIM,CTB->CTB_CTTINI,CTB->CTB_CTTFIM,CTB->CTB_CTDINI,;
	CTB->CTB_CTDFIM,CTB->CTB_CTHINI,CTB->CTB_CTHFIM,dDataAtu,Aglutina->CT2_MOEDLC,CTB->CTB_TPSLDO,cFilx,;
	lConta,lCusto,lItem,.T.,.T.,@cDescHP,lIni)
	
	cKey := ('C'+DTOS(dDataAtu)+CTB->CTB_CTADES+CTB->CTB_CCDES+CTB->CTB_ITEMDE+CTB->CTB_CLVLDE+Aglutina->CT2_MOEDLC+CTB->CTB_TPSLDE)
	Ct231GrTrb(cKey,Aglutina->CT2_MOEDLC,aSaldoLanc,dDataAtu,cDescHP,'C',lIni)
	aSaldoLanc:= {}
	dbSelectArea("Aglutina")
End

cFilX := cFilAntX
dbSelectArea("Aglutina")
dbCloseArea ()

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231SldCn³ Autor  ³ Marcelo Akama           ³ Data 25.05.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Aglutinacao dos saldos/lancamentos             			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Ct231SldCn(cContaIni,cContaFim,cCusIni,cCusFim,            ³±±
±±³			  ³	cItemIni,cItemFim,cClVlIni,cClVlFim,,dDataAtu,cMoeda,      ³±±
±±³			  ³	cTpSald,cFilFix,lConta,lCusto,lItem,lClVl)				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³nDebito,nCredito                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ExpC1 = Alias do arquivo                                    ³±±
±±³           ³ExpC2 = Conta Inicial                                       ³±±
±±³           ³ExpC3 = Conta Final                                         ³±±
±±³           ³ExpC4 = C.Custo Inicial                                     ³±±
±±³           ³ExpC5 = C.Custo Final                                       ³±±
±±³           ³ExpC6 = Item Inicial                                        ³±±
±±³           ³ExpC7 = Item Final                                          ³±±
±±³           ³ExpC1 = Classe de Valor Inicial                             ³±±
±±³           ³ExpC2 = Classe de Valor Final                               ³±±
±±³           ³ExpD1 = Data                                                ³±±
±±³           ³ExpC9 = Moeda                                               ³±±
±±³           ³ExpC10= Tipo de Saldo                                       ³±±
±±³           ³ExpC11= Filial                                              ³±±
±±³           ³ExpL1 = Define se tem conta ou nao                          ³±±
±±³           ³ExpL2 = Define se tem C.custo ou nao                        ³±±
±±³           ³ExpL3 = Define se tem Item ou nao                           ³±±
±±³           ³ExpL4 = Define se tem Cl.Valor ou nao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231SldCn(cContaIni,cContafim,cCusIni,cCusFim,cItemIni,cItemFim,cClvlIni,cClVlFim,dDataAtu,cMoeda,cTpSald,cFilX,lConta,lCusto,lItem,lClvl,lDebito,cDescHP,lIni)

Local nDebito	:= 0					// Valor Debito na Data
Local nCredito 	:= 0					// Valor Credito na Data
Local bCond 	:= {||.F.}
Local cConta	:= cAlias+"_CONTA"
Local cCusto	:= cAlias+"_CUSTO"
Local cItem		:= cAlias+"_ITEM"
Local cClVl		:= cAlias+"_CLVL"
Local cMoed		:= cAlias+"_MOEDA"
Local lOk		:= .T.

dbSelectArea("Aglutina")

cTpSald := Iif(Empty(cTpSald),"1",cTpSald)

If lClvl
	If lDebito
		If lIni
			bCond := { || Aglutina->CT2_DATA<=dDataAtu .And. Aglutina->CT2_CLVLDB <= cClvlFim }
		Else
			bCond := { || Aglutina->CT2_DATA==dDataAtu .And. Aglutina->CT2_CLVLDB <= cClvlFim }
		EndIf
	Else
		If lIni
			bCond := { || Aglutina->CT2_DATA<=dDataAtu .And.  Aglutina->CT2_CLVLCR <= cClvlFim }
		Else
			bCond := { || Aglutina->CT2_DATA==dDataAtu .And.  Aglutina->CT2_CLVLCR <= cClvlFim }
		EndIf
	EndIf
ElseIf lItem
	If lDebito
		If lIni
			bCond := { || Aglutina->CT2_DATA<=dDataAtu .And. Aglutina->CT2_ITEMD <= cItemFim }
		Else
			bCond := { || Aglutina->CT2_DATA==dDataAtu .And. Aglutina->CT2_ITEMD <= cItemFim }
		EndIf
	Else
		If lIni
			bCond := { || Aglutina->CT2_DATA<=dDataAtu .And. Aglutina->CT2_ITEMC <= cItemFim }
		Else
			bCond := { || Aglutina->CT2_DATA==dDataAtu .And. Aglutina->CT2_ITEMC <= cItemFim }
		EndIf
	EndIf
ElseIf lCusto
	If lDebito
		If lIni
			bCond := { || Aglutina->CT2_DATA<=dDataAtu .And. Aglutina->CT2_CCD <= cCusFim }
		Else
			bCond := { || Aglutina->CT2_DATA==dDataAtu .And. Aglutina->CT2_CCD <= cCusFim }
		EndIf
	Else
		If lIni
			bCond := { || Aglutina->CT2_DATA<=dDataAtu .And. Aglutina->CT2_CCC <= cCusFim }
		Else
			bCond := { || Aglutina->CT2_DATA==dDataAtu .And. Aglutina->CT2_CCC <= cCusFim }
		EndIf
	EndIf
Else
	If lDebito
		If lIni
			bCond := { || Aglutina->CT2_DATA<=dDataAtu .And. Aglutina->CT2_DEBITO <= cContaFim }
		Else
			bCond := { || Aglutina->CT2_DATA==dDataAtu .And. Aglutina->CT2_DEBITO <= cContaFim }
		EndIf
	Else
		If lIni
			bCond := { || Aglutina->CT2_DATA<=dDataAtu .And. Aglutina->CT2_CREDIT <= cContaFim }
		Else
			bCond := { || Aglutina->CT2_DATA==dDataAtu .And. Aglutina->CT2_CREDIT <= cContaFim }
		EndIf
	EndIf
EndIf
If lDebito
	cConta := "CT2_DEBITO"
	cCusto := "CT2_CUSTOD"
	cItem  := "CT2_ITEMD"
	cClVl  := "CT2_CLVLDB"
Else
	cConta := "CT2_CREDIT"
	cCusto := "CT2_CUSTOC"
	cItem  := "CT2_ITEMC"
	cClVl  := "CT2_CLVLCR"
EndIf

cDescHP := ''

If	Eval(bCond)
	
	While !Eof() .And. Aglutina->CT2_FILIAL == cFilX	.And. Eval(bCond) .and. lOk
		
		If &("Aglutina->"+cMoed) != cMoeda
			dbSkip()
			Loop
		Endif
		
		If Aglutina->CT2_TPSALD != cTpsald
			dbSkip()
			Loop
		Endif
		
		If lConta .And. (&("Aglutina->"+cConta) < cContaIni .Or. &("Aglutina->"+cConta) > cContaFim)
			dbSkip()
			Loop
		Endif
		
		If lCusto .And. (&("Aglutina->"+cCusto) < cCusIni .Or. &("Aglutina->"+cCusto) > cCusFim)
			dbSkip()
			Loop
		Endif
		
		If lItem .And. (&("Aglutina->"+cItem) < cItemIni .Or. &("Aglutina->"+cItem) > cItemFim)
			dbSkip()
			Loop
		Endif
		
		If cAlias == "CT2"
			If lDebito
				nDebito		+= Aglutina->CT2_VALOR
			Else
				nCredito	+= Aglutina->CT2_VALOR
			EndIf
			
			If Len(cDescHP)<100
				cDescHP := cDescHP + AllTrim( Aglutina->CT2_HIST )
			EndIf
			
		Else
			nDebito		+= Aglutina->CT2_DEBITO
			nCredito	+= Aglutina->CT2_CREDIT
		EndIf
		Aglutina->(dbSkip())
		
		lOk := mv_par14 == 1
	End
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                             ³
//³ [1] Debito na Data                                   ³
//³ [2] Credito na Data                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//      [1]       [2]
Return {nDebito,nCredito}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ Ct231GrTrb                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Simone Mie Sato                          ³ Data ³ 20.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Grava no Arq. de Trabalho os mov. debito/credito.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Ct231GrTrb(cChave,cMoeda,aSaldo,dDataAtu)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³           ³ ExpC2 = Chave                                              ³±±
±±³           ³ ExpC3 = Moeda                                              ³±±
±±³           ³ ExpA1 = Array contendo os saldos                           ³±±
±±³           ³ ExpD1 = Data                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231GrTrb(cChave,cMoeda,aSaldo,dDataAtu,cDesc,cDC,lIni)

Local aSaveArea := GetArea()
Local cDescHP

dbSelectArea("TRB")
dbSetOrder(1)
If !DbSeek(cChave) .or. mv_par14==2
	Reclock("TRB",.T.)
	
	TRB->CUSTO	:= CTB->CTB_CCDES
	TRB->ITEM	:= CTB->CTB_ITEMDE
	TRB->CLVL	:= CTB->CTB_CLVLDE
	TRB->DC		:= cDC
	TRB->INI	:= lIni
	
	If !empty(CTB->CTB_FORMUL)
		cDescHP := &(CTB->CTB_FORMUL)
	ElseIf !empty(CTB->CTB_HAGLUT)
		cDescHP := &(CTB->CTB_HAGLUT)
	Else
		cDescHP := cDesc
	EndIf
	
	If ValType(cDescHP)<>'C'
		cDescHP:='CTBA231'
	EndIf
	
	TRB->EMPORI := CTB->CTB_EMPORI
	TRB->FILORI := CTB->CTB_FILORI
	TRB->HIST	:= cDescHP
	TRB->CONTA 	:= CTB->CTB_CTADEST
	TRB->DTSALDO:= CTOD(RIGHT(DDATAATU,2)+"/"+SUBS(DDATAATU,5,2)+"/"+LEFT(DDATAATU,4))
	TRB->MOEDA  := cMoeda
	TRB->TPSALDO:= CTB->CTB_TPSLDE
	TRB->DEBITO := aSaldo[1]
	TRB->CREDITO:= aSaldo[2]
	MsUnlock()
Else
	Reclock("TRB",.F.)
	If CTB->CTB_IDENT == "1"
		TRB->DEBITO 	+= aSaldo[1]
		TRB->CREDITO	+= aSaldo[2]
	ElseIf CTB->CTB_IDENT == "2"
		TRB->DEBITO 	-= aSaldo[1]
		TRB->CREDITO 	-= aSaldo[2]
	Endif
	MsUnlock()
Endif

RestArea(aSaveArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231ExecP³ Autor  ³ Marcelo Akama           ³ Data 16.06.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Aglutinacao dos saldos/lancamentos             			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Ct231ExecP(aEmpOri)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 - Array com os nomes das tabelas das empresas origem ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231ExecP(aEmpOri As Array, cAliasCTB As Character) As Logical
	Local cTmp As Character
	Local cProc As Character
	Local cSQL As Character
	Local aResult As Array
	Local cCT2 As Character
	Local cCTB As Character
	Local cCTF As Character
	Local aCtbMoeda As Array
	Local cMoeda As Character
	Local cDataIni As Character
	Local cDataFim As Character
	Local cEmpOri As Character
	Local cFilOri As Character
	Local cValor As Character
	Local cFormul As Character
	Local cHaglut As Character
	Local cHist As Character
	Local cLote As Character
	Local cSub As Character
	Local cDoc As Character
	Local cLinha As Character
	Local cRec As Character
	Local cDeb As Character
	Local cCrd As Character
	Local cCtaDb As Character
	Local cCCDb As Character
	Local cItemDb As Character
	Local cCLVLDb As Character
	Local cCtaCr As Character
	Local cCCCr As Character
	Local cItemCr As Character
	Local cCLVLCr As Character
	Local cRet As Character
	Local lRet As Logical
	Local nX As Numeric
	Local cTamLote As Character
	Local nTamLote As Numeric
	Local cTamSub As Character
	Local cTamDoc As Character
	Local nTamDoc As Numeric
	Local cTamLinha As Character
	Local cLenCta As Character
	Local cLenCC As Character
	Local cLenItem As Character
	Local cLenCLVL As Character
	Local cLen As Character
	Local cDec As Character
	Local cLenHist As Character
	Local nCTKHist As Numeric
	Local nCTBHist As Numeric
	Local aCposEnt As Array
	Local nQtdeEnt As Numeric
	Local cEntidade As Character
	Local nZ As Numeric
	Local cSQLOld As Character
	Local cSQLPE As Character
	Local cTmpUNQ As Character
	Local lMultiRot As Logical
	Local oQueryCUR
	Local oQy1CT2
	Local oQy2CT2
	Local oQy1CTF
	Local cSub_Lote As Character
	Local dtant As Character
	Local lSeek		:= .F.

	cTmp		:= CriaTrab(nil,.F.)
	cProc		:= 'CTB231_P'+CriaTrab(nil,.F.)
	cSQL		:= ''
	aResult		:= {}
	cCT2		:= RetSQLName("CT2")
	cCTB		:= cAliasCTB
	cCTF		:= RetSQLName("CTF")
	aCtbMoeda	:= CtbMoeda(mv_par06)
	cMoeda		:= aCtbMoeda[1]
	cDataIni	:= DTOS(mv_par02)
	cDataFim	:= DTOS(mv_par03)
	cEmpOri		:= ""
	cFilOri		:= ""
	cValor		:= ""
	cFormul		:= ""
	cHaglut		:= ""
	cHist		:= ""
	cLote		:= ""
	cSub		:= ""
	cDoc		:= ""
	cLinha		:= ""
	cRec		:= ""
	cDeb		:= ""
	cCrd		:= ""
	cCtaDb		:= ""
	cCCDb		:= ""
	cItemDb		:= ""
	cCLVLDb		:= ""
	cCtaCr		:= ""
	cCCCr		:= ""
	cItemCr		:= ""
	cCLVLCr		:= ""
	cRet		:= ""
	cSub_Lote	:= ""
	lRet		:= .T.
	nX			:= 0
	cTamLote	:= alltrim(str(TamSX3('CT2_LOTE')[1]))
	nTamLote	:= VAL(cTamLote)
	cTamSub		:= alltrim(str(TamSX3('CT2_SBLOTE')[1]))
	nTamSub		:= VAL(cTamSub)
	cTamDoc		:= alltrim(str(TamSX3('CT2_DOC')[1]))
	nTamDoc		:= TamSX3('CT2_DOC')[1]
	cTamLinha	:= alltrim(str(TamSX3('CT2_LINHA')[1]))
	cLenCta		:= alltrim(str(TamSX3('CTB_CTADES')[1]))
	cLenCC		:= alltrim(str(TamSX3('CTB_CCDES' )[1]))
	cLenItem	:= alltrim(str(TamSX3('CTB_ITEMDE')[1]))
	cLenCLVL	:= alltrim(str(TamSX3('CTB_CLVLDE')[1]))
	cLen		:= alltrim(str(TamSX3('CT2_VALOR')[1]))
	cDec		:= alltrim(str(TamSX3('CT2_VALOR')[2]))
	cLenHist	:= alltrim(str(TamSX3('CT2_HIST')[1]))
	nLenHist	:= val(cLenHist)
	nCTKHist	:= TamSX3('CTK_HAGLUT')[1]
	nCTBHist	:= TamSX3('CTB_HAGLUT')[1]
	aCposEnt	:= {}
	nQtdeEnt	:= 0
	cEntidade	:= ""
	nZ			:= 0
	cSQLOld		:= "" // Variável utilizada para manter as informações da procedure antes do PE
	cSQLPE		:= "" // Retorno da procedure depois do PE
	cTmpUNQ		:= ""
	lMultiRot 	:= SuperGetMV("MV_CTBMTRT",, .F.)

	DEFAULT aEmpOri	:= {}

	If mv_par05==2 .And. Empty(cMoeda)
		Help(" ",1,"NOMOEDA")
		Return .F.
	EndIf

	//cria arquivo temporario que ira fazer de/para do sublote se violar chave unica da CT2 - possivel pq a rotina roda em modo exclusivo
	cTmpUNQ := CrTmpUNQ()
	CT2->(DBSETORDER(1))//CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC, R_E_C_N_O_, D_E_L_E_T_
	If __lCtbIsCube
		nQtdeEnt := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
		cSql:='CREATE TABLE '+cTmp+' ( EMPORI char(2), FILORI varchar(12), ' + IIf(lMultiRot, 'CTB_CODIGO char(3), ', '') + 'CTB_TPSLDO char(1), CTB_CTADB varchar('+cLenCta+'), CTB_CCDB varchar('+cLenCC+'), CTB_ITEMDB varchar('+cLenItem+'), CTB_CLVLDB varchar('+cLenCLVL+'), CTB_CTACR varchar('+cLenCta+'), CTB_CCCR varchar('+cLenCC+'), CTB_ITEMCR varchar('+cLenItem+'), CTB_CLVLCR varchar('+cLenCLVL+'), '
		
		For nZ:= 5 To nQtdeEnt
			cEntidade := StrZero(nZ,2)
			AADD(aCposEnt,{	'CTB_NIV'+cEntidade+'DB',;						// 1 - Nome campo temporario debito
			'CTB_NIV'+cEntidade+'CR',;  					// 2 - Nome campo temporario credito
			'@cnivel'+cEntidade+'DB',;					   	// 3 - Nome da variavel debito
			'@cnivel'+cEntidade+'CR',;						// 4 - Nome da variavel credito
			CtbCposCrDb("CT2","D", cEntidade),;				// 5 - Nome campo Debito tabela CT2
			CtbCposCrDb("CT2","C", cEntidade),;				// 6 - Nome campo Credito tabela CT2
			cValToChar(TamSx3(CtbCposCrDb("CT2","C", cEntidade))[1]),;	// 7 - Tamanho do campo
			'CTB_E'+cEntidade+'DES',;						// 8 - Nome do campo entidade DESTINO
			'CTB_E'+cEntidade+'INI',;						// 9 - Nome do campo entidade INICIO
			'CTB_E'+cEntidade+'FIM'})						// 10- Nome do campo entidade FIM
			cSql += aCposEnt[Len(aCposEnt)]	[1] + ' varchar('+aCposEnt[Len(aCposEnt)][7]+'), ' + aCposEnt[Len(aCposEnt)][2] + ' varchar('+aCposEnt[Len(aCposEnt)][7]+'), '
		Next nZ
		
		cSql += 'VALOR numeric('+cLen+','+cDec+'), CDATA char(8), FORMUL varchar(100), HAGLUT varchar('+ iIf(nCTKHist > nCTBHist,ALLTRIM(STR(nCTKHist)),ALLTRIM(STR(nCTBHist))) +'), HIST varchar('+cValToChar(TamSx3('CTK_HIST')[1])+'), DTLP char(8), MOEDA char(2), TIPO char(1), LOTE varchar('+cTamLote+'), SBLOTE varchar('+cTamSub+'), DOC varchar('+cTamDoc+'), LINHA varchar('+cTamLinha+'), REC int )'
	Else
		cSql:='CREATE TABLE '+cTmp+' ( EMPORI char(2), FILORI varchar(12), ' + IIf(lMultiRot, 'CTB_CODIGO char(3), ', '') + ' CTB_TPSLDO char(1), CTB_CTADB varchar('+cLenCta+'), CTB_CCDB varchar('+cLenCC+'), CTB_ITEMDB varchar('+cLenItem+'), CTB_CLVLDB varchar('+cLenCLVL+'), CTB_CTACR varchar('+cLenCta+'), CTB_CCCR varchar('+cLenCC+'), CTB_ITEMCR varchar('+cLenItem+'), CTB_CLVLCR varchar('+cLenCLVL+'), VALOR numeric('+cLen+','+cDec+'), CDATA char(8), FORMUL varchar(100), HAGLUT varchar('+iIf(nCTKHist > nCTBHist,ALLTRIM(STR(nCTKHist)),ALLTRIM(STR(nCTBHist)))+'), HIST varchar('+cValToChar(TamSx3('CTK_HIST')[1])+'), DTLP char(8), MOEDA char(2), TIPO char(1), LOTE varchar('+cTamLote+'), SBLOTE varchar('+cTamSub+'), DOC varchar('+cTamDoc+'), LINHA varchar('+cTamLinha+'), REC int )'
	EndIf


	if TcSqlExec(cSQL)<>0
		if !__lBlind
			MsgAlert(STR0019+" "+cTmp+": "+TCSqlError())  //'Erro criando a tabela temporaria'
		endif
		conout(STR0019+" "+cTmp+": "+TCSqlError())  //'Erro criando a tabela temporaria:'
		Return .F.
	endif

	cSQL:=''

	
	If mv_par14 == 1
		cEmpOri := "max(CTB_EMPORI)"
		cFilOri := "max(CTB_FILORI)"
		cValor  := "sum(CT2_VALOR)"
		cFormul := "max(CTB_FORMUL)"
		cHaglut := "max(CTB_HAGLUT)"
		cHist   := "max(CT2_HIST)"
		cLote	:= "' '"
		cSub	:= "' '"
		cDoc	:= "' '"
		cLinha	:= "' '"
		cRec	:= "0"
		cDeb	:= "'1'"
		cCrd	:= "'2'"
	Else
		cEmpOri := "CTB_EMPORI"
		cFilOri := "CTB_FILORI"
		cValor  := "CT2_VALOR"
		cFormul := "CTB_FORMUL"
		cHaglut := "CTB_HAGLUT"
		cHist   := "CT2_HIST"
		cLote	:= "CT2_LOTE"
		cSub	:= "CT2_SBLOTE"
		cDoc	:= "CT2_DOC"
		cLinha	:= "CT2_LINHA"
		cRec	:= "CT2.R_E_C_N_O_"
		cDeb	:= "CT2_DC"
		cCrd	:= "CT2_DC"
	Endif
	
	For nX:=1 to Len(aEmpOri)
		// Débito
		If __lCtbIsCube
			cSQL:=cSQL+"insert into "+cTmp+" (EMPORI, FILORI, " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR, "
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui novos campos das entidades³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ:=1 To Len(aCposEnt)
				cSQL:=cSQL+aCposEnt[nZ][1]+", "+aCposEnt[nZ][2]+", "
			Next nZ
			cSQL:=cSQL+"VALOR, CDATA, FORMUL, HAGLUT, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC)"+CRLF
		Else
			cSQL:=cSQL+"insert into "+cTmp+" (EMPORI, FILORI, " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR, VALOR, CDATA, FORMUL, HAGLUT, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC)"+CRLF
		EndIf
		cSQL:=cSQL+"select"+CRLF
		cSQL:=cSQL+"	"+cEmpOri+" as EMPORI,"+CRLF
		cSQL:=cSQL+"	"+cFilOri+" as FILORI,"+CRLF
		If lMultiRot
			cSQL:=cSQL+"	CTB_CODIGO,"+CRLF
		EndIf
		cSQL:=cSQL+"	CTB_TPSLDE,"+CRLF
		cSQL:=cSQL+"	CTB_CTADES,"+CRLF
		cSQL:=cSQL+"	CTB_CCDES,"+CRLF
		cSQL:=cSQL+"	CTB_ITEMDE,"+CRLF
		cSQL:=cSQL+"	CTB_CLVLDE,"+CRLF
		cSQL:=cSQL+"	' ' as CTACR,"+CRLF
		cSQL:=cSQL+"	' ' as CCCR,"+CRLF
		cSQL:=cSQL+"	' ' as ITEMCR,"+CRLF
		cSQL:=cSQL+"	' ' as CLVLCR,"+CRLF
		
		If __lCtbIsCube
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui novos campos das entidades³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ:=1 To Len(aCposEnt)
				cSQL:=cSQL+"    "+ aCposEnt[nZ][8]+"," +CRLF
				cSQL:=cSQL+"	' ' as " +aCposEnt[nZ][2]+","+CRLF
			Next nZ
		EndIf
		
		cSQL:=cSQL+"	"+cValor+" as VALOR,"+CRLF
		cSQL:=cSQL+"	CT2_DATA as CDATA,"+CRLF
		cSQL:=cSQL+"	"+cFormul+" as FORMUL,"+CRLF
		cSQL:=cSQL+"	"+cHaglut+" as HAGLUT,"+CRLF
		cSQL:=cSQL+"	"+cHist+" as HIST,"+CRLF
		cSQL:=cSQL+"	CT2_DTLP as DTLP,"+CRLF
		cSQL:=cSQL+"	CT2_MOEDLC as MOEDA,"+CRLF
		cSQL:=cSQL+"	"+cDeb+"	as TIPO,"+CRLF
		cSQL:=cSQL+"	"+cLote+" as LOTE,"+CRLF
		cSQL:=cSQL+"	"+cSub+" as SBLOTE,"+CRLF
		cSQL:=cSQL+"	"+cDoc+" as DOC,"+CRLF
		cSQL:=cSQL+"	"+cLinha+" as LINHA,"+CRLF
		cSQL:=cSQL+"	"+cRec+" as REC"+CRLF
		cSQL:=cSQL+"from "+cCTB+" CTB, "+aEmpOri[nX,2,2]+" CT2"+CRLF

		cSQL:=cSQL+"where CT2_FILIAL = CTB_CT2FIL "+CRLF

		If ExistBlock("Ct231AdQry")
   		   cSql += ExecBlock("Ct231AdQry",.F.,.F.,{1})//(1)Debito
		Endif 
		
		cSQL:=cSQL+"and CTB_EMPORI='"+aEmpOri[nX,1]+"'"+CRLF
		cSQL:=cSQL+"and CT2_DATA between '"+cDataIni+"' and '"+cDataFim+"'"+CRLF
		cSQL:=cSQL+"and CT2_DEBITO between CTB_CT1INI and CTB_CT1FIM "+CRLF
		cSQL:=cSQL+"and CT2_CCD    between CTB_CTTINI and CTB_CTTFIM "+CRLF
		cSQL:=cSQL+"and CT2_ITEMD  between CTB_CTDINI and CTB_CTDFIM "+CRLF
		cSQL:=cSQL+"and CT2_CLVLDB between CTB_CTHINI and CTB_CTHFIM "+CRLF
		
		If __lCtbIsCube
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui novos campos das entidades³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ:=1 To Len(aCposEnt)
				cSQL:=cSQL+"and "+aCposEnt[nZ][5]+" between "+aCposEnt[nZ][9]+" and "+aCposEnt[nZ][10]+" "+CRLF
			Next nZ
			
		EndIf
		
		cSQL:=cSQL+"and CT2_DC in ('1','3')"+CRLF
		cSQL:=cSQL+"and CT2_TPSALD=CTB_TPSLDO"+CRLF
		If mv_par07<>'*'
			cSQL:=cSQL+"and CTB_TPSLDO='"+mv_par07+"'"+CRLF
		EndIf
		If mv_par05 == 2
			cSQL:=cSQL+"and CT2_MOEDLC='"+cMoeda+"'"+CRLF
		Endif
		cSQL:=cSQL+"and CT2.D_E_L_E_T_ = ' '"+CRLF
		cSQL:=cSQL+"and CTB_CODIGO between '"+mv_par12+"' and '"+mv_par13+"'"+CRLF
		cSQL:=cSQL+"and CTB.D_E_L_E_T_ = ' '"+CRLF
		If mv_par14 == 1
			
			If __lCtbIsCube
				cSQL:=cSQL+"group by " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDE, CTB_CTADES, CTB_CCDES, CTB_ITEMDE, CTB_CLVLDE, "
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui novos campos das entidades³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nZ:=1 To Len(aCposEnt)
					cSQL:=cSQL + aCposEnt[nZ][8]+", "
				Next nZ
				cSQL:=cSQL+"CT2_DATA, CT2_MOEDLC, CT2_DTLP"+CRLF
			Else
				cSQL:=cSQL+"group by " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDE, CTB_CTADES, CTB_CCDES, CTB_ITEMDE, CTB_CLVLDE, CT2_DATA, CT2_MOEDLC, CT2_DTLP"+CRLF
			EndIf
			
		EndIf
	    tcsqlexec(cSQL)
        cSQL :=	""
	
		If __lCtbIsCube
			cSQL:=cSQL+"insert into "+cTmp+" (EMPORI, FILORI, " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR,"
			For nZ:=1 To Len(aCposEnt)
				cSQL:=cSQL+aCposEnt[nZ][1]+","+aCposEnt[nZ][2]+","
			Next nZ
			cSQL:=cSQL+"VALOR, CDATA, FORMUL, HAGLUT, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC)"+CRLF
		Else
			cSQL:=cSQL+"insert into "+cTmp+" (EMPORI, FILORI, " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR, VALOR, CDATA, FORMUL, HAGLUT, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC)"+CRLF
		EndIf
		cSQL:=cSQL+"select"+CRLF
		cSQL:=cSQL+"	"+cEmpOri+" as EMPORI,"+CRLF
		cSQL:=cSQL+"	"+cFilOri+" as FILORI,"+CRLF
		If lMultiRot
			cSQL:=cSQL+"	CTB_CODIGO,"+CRLF
		EndIf
		cSQL:=cSQL+"	CTB_TPSLDE,"+CRLF
		cSQL:=cSQL+"	' ' as CTADB,"+CRLF
		cSQL:=cSQL+"	' ' as CCDB,"+CRLF
		cSQL:=cSQL+"	' ' as ITEMDB,"+CRLF
		cSQL:=cSQL+"	' ' as CLVLDB,"+CRLF
		cSQL:=cSQL+"	CTB_CTADES,"+CRLF
		cSQL:=cSQL+"	CTB_CCDES,"+CRLF
		cSQL:=cSQL+"	CTB_ITEMDE,"+CRLF
		cSQL:=cSQL+"	CTB_CLVLDE,"+CRLF
		
		If __lCtbIsCube
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui novos campos das entidades³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ:=1 To Len(aCposEnt)
				cSQL:=cSQL+"	' ' as " +aCposEnt[nZ][1]+","+CRLF
				cSQL:=cSQL+"    "+ aCposEnt[nZ][8]+"," +CRLF
			Next nZ
		EndIf
		
		cSQL:=cSQL+"	"+cValor+" as VALOR,"+CRLF
		cSQL:=cSQL+"	CT2_DATA as CDATA,"+CRLF
		cSQL:=cSQL+"	"+cFormul+" as FORMUL,"+CRLF
		cSQL:=cSQL+"	"+cHaglut+" as HAGLUT,"+CRLF
		cSQL:=cSQL+"	"+cHist+" as HIST,"+CRLF
		cSQL:=cSQL+"	CT2_DTLP as DTLP,"+CRLF
		cSQL:=cSQL+"	CT2_MOEDLC as MOEDA,"+CRLF
		cSQL:=cSQL+"	"+cCrd+" as TIPO,"+CRLF
		cSQL:=cSQL+"	"+cLote+" as LOTE,"+CRLF
		cSQL:=cSQL+"	"+cSub+" as SBLOTE,"+CRLF
		cSQL:=cSQL+"	"+cDoc+" as DOC,"+CRLF
		cSQL:=cSQL+"	"+cLinha+" as LINHA,"+CRLF
		cSQL:=cSQL+"	"+cRec+" as REC"+CRLF
		cSQL:=cSQL+"from "+cCTB+" CTB, "+aEmpOri[nX,2,2]+" CT2"+CRLF

		cSQL:=cSQL+"where CT2_FILIAL = CTB_CT2FIL "+CRLF

		If ExistBlock("Ct231AdQry")
   		   cSql += ExecBlock("Ct231AdQry",.F.,.F.,{2})//(2)Credito
		Endif 
		 
		cSQL:=cSQL+"and CTB_EMPORI='"+aEmpOri[nX,1]+"'"+CRLF
		cSQL:=cSQL+"and CT2_DATA between '"+cDataIni+"' and '"+cDataFim+"'"+CRLF
		cSQL:=cSQL+"and CT2_CREDIT between CTB_CT1INI and CTB_CT1FIM "+CRLF
		cSQL:=cSQL+"and CT2_CCC    between CTB_CTTINI and CTB_CTTFIM "+CRLF
		cSQL:=cSQL+"and CT2_ITEMC  between CTB_CTDINI and CTB_CTDFIM "+CRLF
		cSQL:=cSQL+"and CT2_CLVLCR between CTB_CTHINI and CTB_CTHFIM "+CRLF
		
		If __lCtbIsCube
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui novos campos das entidades³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ:=1 To Len(aCposEnt)
				cSQL:=cSQL+"and "+aCposEnt[nZ][6]+" between "+aCposEnt[nZ][9]+" and "+aCposEnt[nZ][10]+" "+CRLF
			Next nZ
			
		EndIf
		
		cSQL:=cSQL+"and CT2_DC in ('2','3')"+CRLF
		cSQL:=cSQL+"and CT2_TPSALD=CTB_TPSLDO"+CRLF
		If mv_par07<>'*'
			cSQL:=cSQL+"and CTB_TPSLDO='"+mv_par07+"'"+CRLF
		EndIf
		If mv_par05 == 2
			cSQL:=cSQL+"and CT2_MOEDLC='"+cMoeda+"'"+CRLF
		Endif
		cSQL:=cSQL+"and CT2.D_E_L_E_T_ = ' '"+CRLF
		cSQL:=cSQL+"and CTB_CODIGO between '"+mv_par12+"' and '"+mv_par13+"'"+CRLF
		cSQL:=cSQL+"and CTB.D_E_L_E_T_ = ' '"+CRLF
		
		If mv_par14 == 1
			If __lCtbIsCube
				cSQL:=cSQL+"group by " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDE, CTB_CTADES, CTB_CCDES, CTB_ITEMDE, CTB_CLVLDE, " 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Inclui novos campos das entidades³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nZ:=1 To Len(aCposEnt)
					cSQL:=cSQL + aCposEnt[nZ][8]+", "
				Next nZ
				cSQL:=cSQL+"CT2_DATA, CT2_MOEDLC, CT2_DTLP"+CRLF
			Else
				cSQL:=cSQL+"group by " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDE, CTB_CTADES, CTB_CCDES, CTB_ITEMDE, CTB_CLVLDE, CT2_DATA, CT2_MOEDLC, CT2_DTLP"+CRLF
			EndIf
		EndIf
		tcsqlexec(cSQL)

        cSQL :=	""
	Next
	
	If mv_par14 == 1
		cEmpOri := "max(EMPORI) as EMPORI"
		cFilOri := "max(FILORI) as FILORI"
		cValor  := "sum(VALOR) as VALOR"
		cHist   := "max(HIST) as HIST"
		cCtaDb	:= "CTB_CTADB"
		cCCDb	:= "CTB_CCDB"
		cItemDb	:= "CTB_ITEMDB"
		cCLVLDb	:= "CTB_CLVLDB"
		cCtaCr	:= "CTB_CTACR"
		cCCCr	:= "CTB_CCCR"
		cItemCr	:= "CTB_ITEMCR"
		cCLVLCr	:= "CTB_CLVLCR"
	Else
		cEmpOri := "EMPORI"
		cFilOri := "FILORI"
		cValor  := "VALOR"
		cHist   := "HIST"
		cCtaDb	:= "max(CTB_CTADB) as CTB_CTADB"
		cCCDb	:= "max(CTB_CCDB) as CTB_CCDB"
		cItemDb	:= "max(CTB_ITEMDB) as CTB_ITEMDB"
		cCLVLDb	:= "max(CTB_CLVLDB) as CTB_CLVLDB"
		cCtaCr	:= "max(CTB_CTACR) as CTB_CTACR"
		cCCCr	:= "max(CTB_CCCR) as CTB_CCCR"
		cItemCr	:= "max(CTB_ITEMCR) as CTB_ITEMCR"
		cCLVLCr	:= "max(CTB_CLVLCR) as CTB_CLVLCR"
	Endif

	cSQL:=cSQL+"select"+CRLF
	cSQL:=cSQL+"	"+cEmpOri+","+CRLF
	cSQL:=cSQL+"	"+cFilOri+","+CRLF
	If lMultiRot
		cSQL:=cSQL+"	CTB_CODIGO,"+CRLF
	EndIf
	cSQL:=cSQL+"	CTB_TPSLDO,"+CRLF
	cSQL:=cSQL+"	"+cCtaDb+","+CRLF
	cSQL:=cSQL+"	"+cCCDb+","+CRLF
	cSQL:=cSQL+"	"+cItemDb+","+CRLF
	cSQL:=cSQL+"	"+cCLVLDb+","+CRLF
	cSQL:=cSQL+"	"+cCtaCr+","+CRLF
	cSQL:=cSQL+"	"+cCCCr+","+CRLF
	cSQL:=cSQL+"	"+cItemCr+","+CRLF
	cSQL:=cSQL+"	"+cCLVLCr+","+CRLF
	
	If __lCtbIsCube
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclui novos campos das entidades³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nZ:=1 To Len(aCposEnt)
			If mv_par14 == 1
				cSQL:=cSQL+"    "+ aCposEnt[nZ][1]+"," +CRLF
				cSQL:=cSQL+"    "+ aCposEnt[nZ][2]+"," +CRLF
			Else
				cSQL:=cSQL+ "max("+ aCposEnt[nZ][1]+") as "+ aCposEnt[nZ][1]+", "+CRLF
				cSQL:=cSQL+ "max("+ aCposEnt[nZ][2]+") as "+ aCposEnt[nZ][2]+", "+CRLF
			EndIf
		Next nZ
	EndIf
	
	cSQL:=cSQL+"	"+cValor+","+CRLF
	cSQL:=cSQL+"	CDATA,"+CRLF
	cSQL:=cSQL+"	max(FORMUL) as FORMUL,"+CRLF
	cSQL:=cSQL+"	max(HAGLUT) as HAGLUT,"+CRLF
	cSQL:=cSQL+"	"+cHist+","+CRLF
	cSQL:=cSQL+"	DTLP,"+CRLF
	cSQL:=cSQL+"	MOEDA,"+CRLF
	If mv_par14 == 1
		cSQL:=cSQL+"	TIPO"+CRLF
	Else
		cSQL:=cSQL+"	TIPO,"+CRLF
		cSQL:=cSQL+"	LOTE,"+CRLF
		cSQL:=cSQL+"	SBLOTE,"+CRLF
		cSQL:=cSQL+"	DOC,"+CRLF
		cSQL:=cSQL+"	LINHA"+CRLF
	EndIf
	cSQL:=cSQL+"from "+cTmp+CRLF
	If mv_par14 == 1
		If __lCtbIsCube
			cSQL:=cSQL+"group by " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR, "
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui novos campos das entidades³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ:=1 To Len(aCposEnt)
				cSQL:=cSQL + aCposEnt[nZ][1]+", "
				cSQL:=cSQL + aCposEnt[nZ][2]+", "
			Next nZ
			cSQL:=cSQL+"CDATA, DTLP, MOEDA, TIPO"+CRLF
		Else
			//			cSQL:=cSQL+"group by CTB_TPSLDO, CTB_CTADES, CTB_CCDES, CTB_ITEMDE, CTB_CLVLDE, CT2_DATA, CT2_MOEDLC, CT2_DTLP"+CRLF
			cSQL:=cSQL+"group by TIPO, " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR, CDATA, MOEDA, DTLP"+CRLF
		EndIf
	Else
		cSQL:=cSQL+"group by EMPORI, FILORI, " + IIf(lMultiRot, 'CTB_CODIGO, ', '') + "CTB_TPSLDO, VALOR, CDATA, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC"+CRLF
	EndIf
	cSQL:=cSQL+"order by CDATA"+CRLF
	cSQL := ChangeQuery(cSQL)
	MPSysOpenQuery(cSQL, "CUR")

	dtant	:=	'XXXXXXXX'
	clinha	:=	'001'
	cSQL := " select max(CTF_LOTE) LOTE, max(CTF_SBLOTE) SUB, max(CTF_DOC) DOC, MIN( R_E_C_N_O_ ) RECCTF "+CRLF
	cSQL += "	from "+cCTF+CRLF
	cSQL += "  where CTF_FILIAL = ? "+CRLF
	cSQL += "	 and CTF_DATA = ? "+CRLF
	cSQL += "	 and D_E_L_E_T_ = ? "+CRLF
	oQueryCUR := FwExecStatement():New( ChangeQuery(cSQL) )

	cSQL := " select min(R_E_C_N_O_) NREC_CT2"+CRLF
	cSQL += "   from "+cCT2+CRLF
	cSQL += "  where CT2_FILIAL = ? "+CRLF
	cSQL += "    and CT2_DATA = ? "+CRLF
	cSQL += "    and CT2_LOTE = ? "+CRLF
	cSQL += "    and CT2_SBLOTE = ? "+CRLF
	cSQL += "    and CT2_DOC = ? "+CRLF
	cSQL += "    and CT2_LINHA = ? "+CRLF
	cSQL += "    and CT2_EMPORI = ? "+CRLF
	cSQL += "    and CT2_FILORI = ? "+CRLF
	cSQL += "    and CT2_MOEDLC = ? "+CRLF
	cSQL += "    and D_E_L_E_T_ = ? "+CRLF
	oQy1CT2 := FwExecStatement():New( ChangeQuery(cSQL) )
  
  	cSQL := " select min(CT2_SBLNEW) CSBLNEW"+CRLF
	cSQL += "   from "+cTmpUNQ+CRLF
	cSQL += "  where CT2_FILIAL = ? "+CRLF
	cSQL += "    and CT2_DATA = ? "+CRLF
	cSQL += "    and CT2_LOTE = ? "+CRLF
	cSQL += "    and CT2_SBLOTE = ? "+CRLF
	cSQL += "    and CT2_DOC = ? "+CRLF
	cSQL += "    and CT2_EMPORI = ? "+CRLF
	cSQL += "    and CT2_FILORI = ? "+CRLF
	cSQL += "    and D_E_L_E_T_ = ? "+CRLF
	oQy2CT2 := FwExecStatement():New( ChangeQuery(cSQL) )

	cSQL := " select min(R_E_C_N_O_) RECCTF "+CRLF
	cSQL += "   from "+cCTF+CRLF
	cSQL += "  where CTF_FILIAL = ? "+CRLF
	cSQL += "    and CTF_DATA = ? "+CRLF
	cSQL += "    and CTF_LOTE = ? "+CRLF
	cSQL += "    and CTF_SBLOTE = ? "+CRLF
	cSQL += "    and CTF_DOC = ? "+CRLF
	cSQL += "    and D_E_L_E_T_ = ? "+CRLF
	oQy1CTF := FwExecStatement():New( ChangeQuery(cSQL) )
	cFilCTF		:= xFilial("CTF")
	cFilCT2		:= xFilial("CT2")
	cDoc		:= space(ntamdoc)
	cLote		:= strzero(1,nTamLote)
	cSub		:= strzero(1,nTamSub)
    WHILE CUR->(!EOF())
        If mv_par14 == 1
			oQueryCUR:setString(1,  cFilCTF)
			oQueryCUR:setString(2,  CUR->CDATA)//CTF_DATA
			oQueryCUR:setString(3,  ' ')//D_E_L_E_T_
			oQueryCUR:OpenAlias( "CURCTF" )
			IF dtant <> CUR->CDATA .or. clinha  == cMaxLin
				IF CURCTF->(EOF()) .OR. CURCTF->RECCTF = 0
					reclock("CTF",.T.)
					CTF->CTF_FILIAL		:= cFilCTF
					CTF->CTF_DATA		:= Stod(CUR->CDATA)
					CTF->CTF_LOTE		:= clote
					CTF->CTF_SBLOTE		:= cSub
					CTF->CTF_DOC		:= cDoc
					CTF->CTF_LINHA		:= '001'
					CTF->CTF_USADO		:= 'S'
					MsUnlock()
					 clote	:=	strzero(1,nTamLote)
					 csub	:=	strzero(1,nTamSub)
					 cDoc	:=	strzero(1,ntamdoc)
					 clinha	:=	'001'
				ELSE
					If cDoc == '999999'
						cDoc	:=	strzero(1,ntamdoc)
						if clote == '999999'
							clote	:= strzero(1,nTamLote)
							nI 		:= val(cSub)+1
							cSub	:= strzero(nI,3)
						else
							nI		:= val(clote)+1
							cLote	:= strzero(nI,nTamLote)
						endif
					else
						If (mv_par05 == 1 .AND. cMoeda =='01') .OR. mv_par05 != 1
							nI				:= val(cDoc) + 1
                        	cDoc			:= strzero(nI,ntamdoc)
						ENDIF
					endif
					clinha	:= '001'
					CTF->(DBGoTo(CURCTF->RECCTF))
					RECLOCK("CTF",.F.)
					//CTF->CTF_FILIAL		:= cFilCTF
					CTF->CTF_LOTE		:= clote
					CTF->CTF_SBLOTE		:= cSub
					CTF->CTF_DOC		:= cDoc
					CTF->CTF_LINHA		:= clinha
					MSUNLOCK()
				ENDIF
			else
				If (mv_par05 == 1 .AND. cMoeda =='01') .OR. mv_par05 != 1
					nI		:= val(clinha)+1
					clinha	:= strzero(ni,3)
				endif
				CTF->(DBGoTo(CURCTF->RECCTF))
				RECLOCK("CTF",.F.)
				CTF->CTF_LINHA		:= clinha
				MSUNLOCK()
			endif
			CURCTF->(DBCLOSEAREA())
		else
			cSub_Lote	:= CUR->SBLOTE
			cSub		:= CUR->SBLOTE
			cDoc		:= CUR->DOC
			clote		:= CUR->LOTE
			nflag		:= 1
			while nflag < 100
				oQy1CT2:setString(1,  cFilCT2)
				oQy1CT2:setString(2,  CUR->CDATA)//CT2_DATA
				oQy1CT2:setString(3,  CUR->LOTE)//CT2_LOTE
				oQy1CT2:setString(4,  CUR->SBLOTE)//CT2_SBLOTE
				oQy1CT2:setString(5,  CUR->DOC)//CT2_DOC
				oQy1CT2:setString(6,  CUR->LINHA)//CT2_LINHA
				oQy1CT2:setString(7,  CUR->EMPORI)//CT2_EMPORI
				oQy1CT2:setString(8,  CUR->FILORI)//CT2_FILORI
				oQy1CT2:setString(9,  cMoeda)//CT2_MOEDLC
				oQy1CT2:setString(10,  ' ')//D_E_L_E_T_
				oQy1CT2:OpenAlias("CUR1CT2")
				if CUR1CT2->(eof()) .OR. CUR1CT2->NREC_CT2 == 0
					if cSub != cSub_Lote
						cUpdate := " insert into "+cTmpUNQ+" ( CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_SBLNEW)"+CRLF
						cUpdate += " values ( '"+cFilCT2+"', '"+CUR->CDATA+"','"+CUR->LOTE+"', '"+cSub+"', '"+CUR->DOC+"', '"+cSub_Lote+"' )"
						tcsqlexec(cUpdate)
					endif
					cSub	:= cSub_Lote 
					nflag	:= 100
				Else
					oQy2CT2:setString(1,  cFilCT2)
					oQy2CT2:setString(2,  CUR->CDATA)//CT2_DATA
					oQy2CT2:setString(3,  CUR->LOTE)//CT2_LOTE
					oQy2CT2:setString(4,  CUR->SBLOTE)//CT2_SBLOTE
					oQy2CT2:setString(5,  CUR->DOC)//CT2_DOC
					oQy2CT2:setString(6,  CUR->EMPORI)//CT2_EMPORI
					oQy2CT2:setString(7,  CUR->FILORI)//CT2_FILORI
					oQy2CT2:setString(8,  ' ')//D_E_L_E_T_
					oQy2CT2:OpenAlias("CUR2CT2")
					if CUR2CT2->(!eof())
						cSub	:= CUR2CT2->CSBLNEW
						nflag	:= 100
					ELSE
						if nflag = 1
							cSub_Lote := '9'+substr(cSub,2,2)
						ElseIf nflag = 2
							cSub_Lote := '8'+substr(cSub,2,2)
						ElseIf nflag = 3
							cSub_Lote := '7'+substr(cSub,2,2)
						ElseIf nflag = 4
							cSub_Lote := '6'+substr(cSub,2,2)
						ElseIf nflag = 5
							cSub_Lote := '5'+substr(cSub,2,2)
						ElseIf nflag = 6
							cSub_Lote := '4'+substr(cSub,2,2)
						ElseIf nflag = 7
							cSub_Lote := '3'+substr(cSub,2,2)
						ElseIf nflag = 8
							cSub_Lote := '2'+substr(cSub,2,2)
						ElseIf nflag = 9
							cSub_Lote := '1'+substr(cSub,2,2)
						ElseIf nflag > 9
							cSub_Lote := '9'+substr(cvaltochar(nflag),1,2)
						endif
						nflag := nflag + 1
					ENDIF
					CUR2CT2->(DBCloseArea())
				endif
				CUR1CT2->(DBCloseArea())
			end
			oQy1CTF:setString(1,  cFilCTF)//CTF_FILIAL
			oQy1CTF:setString(2,  CUR->CDATA)//CTF_DATA
			oQy1CTF:setString(3,  CUR->LOTE)//CTF_LOTE
			oQy1CTF:setString(4,  cSub)//CTF_SBLOTE
			oQy1CTF:setString(5,  CUR->DOC)//CTF_DOC
			oQy1CTF:setString(6,  ' ')//D_E_L_E_T_
			oQy1CTF:OpenAlias("CUR1CTF")
			if CUR1CTF->(eof()) .OR. CUR1CTF->RECCTF == 0
				reclock("CTF",.T.)
				CTF->CTF_FILIAL		:= cFilCTF
				CTF->CTF_DATA		:= stod(CUR->CDATA)
				CTF->CTF_LOTE		:= CUR->LOTE
				CTF->CTF_SBLOTE		:= cSub
				CTF->CTF_DOC		:= CUR->DOC
				CTF->CTF_LINHA		:= clinha
				CTF->CTF_USADO		:= 'S'
				MsUnlock()
			ELSE
				CTF->(DBGoTo(CUR1CTF->RECCTF))
				IF clinha > CTF->CTF_LINHA 
					RECLOCK("CTF",.F.)
					CTF->CTF_LINHA		:= clinha
					MSUNLOCK()
				EndIf
			ENDIF
			CUR1CTF->(DBCloseArea())
		endif
		if !empty(CUR->CTB_CTADB) .and. empty(CUR->CTB_CTACR)
			cTipo := '1'
		ENDIF
		if empty(CUR->CTB_CTADB) .and. !empty(CUR->CTB_CTACR)
			cTipo := '2'
		endif
		if !EMPTY(CUR->FORMUL)
			chist	:= CUR->FORMUL
		Elseif !Empty(CUR->HAGLUT)
			chist	:= CUR->HAGLUT
		endif
		If !Empty(mv_par15)
			chist	:= mv_par15
		endif
		chist	:= substr(chist,1,nLenHist)
		
		// gravação
		lSeek       := !(CT2->(DBSeek(cFilCT2+CUR->CDATA+cLote+cSub+cDoc+clinha+CUR->CTB_TPSLDO+CUR->EMPORI+CUR->FILORI+cMoeda)))
		IF lSeek
			RECLOCK("CT2",lSeek)
			CT2->CT2_FILIAL		:= cFilCT2
			CT2->CT2_DATA		:= stod(CUR->CDATA)
			CT2->CT2_LOTE		:= clote
			CT2->CT2_SBLOTE		:= cSub
			CT2->CT2_DOC		:= cDoc
			CT2->CT2_LINHA		:= clinha
			CT2->CT2_MOEDLC		:= cMoeda
			CT2->CT2_DC			:= cTipo
			CT2->CT2_DEBITO		:= CUR->CTB_CTADB
			CT2->CT2_CREDIT		:= CUR->CTB_CTACR
			CT2->CT2_VALOR		:= CUR->VALOR
			CT2->CT2_HIST		:= chist	
			CT2->CT2_CCD		:= CUR->CTB_CCDB
			CT2->CT2_CCC		:= CUR->CTB_CCCR
			CT2->CT2_ITEMD		:= CUR->CTB_ITEMDB
			CT2->CT2_ITEMC		:= CUR->CTB_ITEMCR
			CT2->CT2_CLVLDB		:= CUR->CTB_CLVLDB
			CT2->CT2_CLVLCR		:= CUR->CTB_CLVLCR
			If __lCtbIsCube
				For nZ := 1 To Len(aCposEnt)
					&("CT2->"+aCposEnt[nZ][5]) := (aCposEnt[nZ][3])
					&("CT2->"+aCposEnt[nZ][6]) := (aCposEnt[nZ][4])
				Next nZ
			endif
			CT2->CT2_EMPORI		:= CUR->EMPORI
			CT2->CT2_FILORI		:= CUR->FILORI
			CT2->CT2_TPSALD		:= CUR->CTB_TPSLDO
			CT2->CT2_DTLP		:= stod(CUR->DTLP)
			CT2->CT2_MANUAL		:= '1'
			CT2->CT2_ROTINA		:= 'CTBA231'
			CT2->CT2_AGLUT		:= '1'
			CT2->CT2_SEQHIS		:= '001'
			CT2->CT2_SEQLAN		:= clinha
			CT2->CT2_TAXA		:= 0
			CT2->CT2_VLR01		:= 0
			CT2->CT2_VLR02		:= 0
			CT2->CT2_VLR03		:= 0
			CT2->CT2_VLR04		:= 0
			CT2->CT2_VLR05		:= 0
			CT2->CT2_CRCONV		:= '1'
			CT2->CT2_CTLSLD		:= '0'
			msunlock()
		endif
		/* Ponto de Entrada para minipulaçãoo das informações de origem, 
			esta demanda foi disponibilizada pois o cliente tinha necessidade 
			de levar o complemento do histórico completo para a consolidadora	*/
		If ExistBlock("CTB231PR")
			ExecBlock( "CTB231PR", .F., .F.)
		Endif
		dtant	:= CUR->CDATA
        CUR->(DBSKIP())
    END
    CUR->(DBCloseArea())

	MsErase(cTmp,,"TOPCONN")
	oQy2CT2:Destroy()
	oQueryCUR:Destroy()
	oQy1CT2:Destroy()
	oQy1CTF:Destroy()

	If(ValType(oTable) <> 'U')
		(cTmpUNQ)->(DbCloseArea())
		oTable:Delete()   
		FreeObj(oTable)
	EndIf

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc}CrTmpUNQ
Criar tabela temporaria onde armazenar o novo sub-lote para nao ocorrer chave duplicada na CT2

@author Totvs
@since  13/01/2023
@version 12
/*/
//---------------------------------------------------------------------
Static Function CrTmpUNQ()
Local aArea := GetArea()
Local cTmpUNQ
Local aStruct := {}

oTable  := totvs.framework.database.temporary.SharedTable():New()

//Estrutura CT2_FILIAL / CT2_DATA / CT2_LOTE / CT2_SBLOTE / CT2_DOC / CT2_EMPORI / CT2_FILORI / CT2_SBLNEW
aAdd(aStruct,{"CT2_FILIAL","C", Len(CT2->CT2_FILIAL), 00}) 
aAdd(aStruct,{"CT2_DATA"  ,"C", 8                   , 00}) //ARMAZENAR COMO STRING UTILIZANDO DTOS()
aAdd(aStruct,{"CT2_LOTE"  ,"C", Len(CT2->CT2_LOTE)  , 00}) 
aAdd(aStruct,{"CT2_SBLOTE","C", Len(CT2->CT2_SBLOTE), 00}) 
aAdd(aStruct,{"CT2_DOC"   ,"C", Len(CT2->CT2_DOC)   , 00}) 
aAdd(aStruct,{"CT2_EMPORI","C", Len(CT2->CT2_EMPORI), 00}) 
aAdd(aStruct,{"CT2_FILORI","C", Len(CT2->CT2_FILORI), 00}) 
aAdd(aStruct,{"CT2_SBLNEW","C", Len(CT2->CT2_SBLOTE), 00}) 

oTable:SetFields(aStruct)

oTable:AddIndex("01", {"CT2_FILIAL","CT2_DATA","CT2_LOTE","CT2_SBLOTE","CT2_DOC","CT2_EMPORI","CT2_FILORI"} )

oTable:Create()

cTmpUNQ:= oTable:GetRealName()

DBUseArea(.T., "TOPCONN", cTmpUNQ, cTmpUNQ, .T., .F.)

RestArea(aArea) 

Return(cTmpUNQ)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231SlInP³ Autor  ³ Marcelo Akama           ³ Data 30.06.09³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Gera lancamentos de saldo inicial             			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Ct231SlInP(aEmpOri)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 - Array com os nomes das tabelas das empresas origem ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231SlInP(aEmpOri,cAliasCTB)
    Local cTmp		:= CriaTrab(nil,.F.)
    Local cSQL		:= ''
    Local cCTB		:= cAliasCTB
    Local aCtbMoeda	:= CtbMoeda(mv_par06)
    Local cMoeda	:= aCtbMoeda[1]
    Local cDataSld	:= DTOS(mv_par02-1)
    Local cLenCta	:= alltrim(str(TamSX3('CTB_CTADES')[1]))
    Local cLenCC	:= alltrim(str(TamSX3('CTB_CCDES' )[1]))
    Local cLenItem	:= alltrim(str(TamSX3('CTB_ITEMDE')[1]))
    Local cLenCLVL	:= alltrim(str(TamSX3('CTB_CLVLDE')[1]))
    Local cLen		:= alltrim(str(TamSX3('CT2_VALOR')[1]))
    Local cDec		:= alltrim(str(TamSX3('CT2_VALOR')[2]))
	Local cTamLote	:= alltrim(str(TamSX3('CT2_LOTE')[1]))
	Local nTamDoc	:= TamSX3('CT2_DOC')[1]
	Local nTamLote  := val(cTamLote) 
    Local lRet		:= .T.
    Local nX
	Local nFlag		:= 0
	Local nCria		:= 0
	Local nValor	:= 0
	Local nI		:= 0
	Local cSub		:= '000'
	Local cLote		:= '000000'
	Local cDoc  	:= '000000'
	Local CTF_LOCK	:= 0
	Local cTabCTK	:= "CTK"
	Local cTabCT2	:= "CT2"
	Local lSimula	:= .F.
	Local cLp		:= ""
	Local cFilCT2	:= ""
	Local lSeek		:= .F.
    
    DEFAULT aEmpOri	:= {}

    If mv_par05==2 .And. Empty(cMoeda)
        Help(" ",1,"NOMOEDA")
        Return .F.
    EndIf

    cSQL:='CREATE TABLE '+cTmp+' ( EMPORI char(2), FILORI varchar(12), CDATA char(8), MOEDA char(2), TPSALD char(1), CONTA varchar('+cLenCta+'), CUSTO varchar('+cLenCC+'), ITEM varchar('+cLenItem+'), CLVL varchar('+cLenClVl+'), DEBITO numeric('+cLen+','+cDec+'), CREDITO numeric('+cLen+','+cDec+'), CONTA_ORI varchar('+cLenCta+'), CUSTO_ORI varchar('+cLenCC+'), ITEM_ORI varchar('+cLenItem+'), CLVL_ORI varchar('+cLenClVl+'), DTLP char(8), LP char(1), FLAG int )'
	if TcSqlExec(cSQL)<>0
        if !__lBlind
            MsgAlert(STR0019+" "+cTmp+": "+TCSqlError())  //'Erro criando a tabela temporaria'
        endif
        conout(STR0019+" "+cTmp+": "+TCSqlError())  //'Erro criando a tabela temporaria:'
        Return .F.
    endif
	CT2->(DBSETORDER(1))//CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC, R_E_C_N_O_, D_E_L_E_T_
	cSQL:=''

    For nX:=1 to Len(aEmpOri)
        cSQL:= "" +CRLF
        /*---   RET 2 ---*/
        cSQL:=cSQL+"insert into "+cTmp+" (EMPORI, FILORI, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, CONTA_ORI, CUSTO_ORI, ITEM_ORI, CLVL_ORI, DTLP, LP, DEBITO, CREDITO, CDATA, FLAG)"+CRLF
        cSQL:=cSQL+"select"+CRLF
        cSQL:=cSQL+"	CTB_EMPORI as EMPORI,"+CRLF
        cSQL:=cSQL+"	CTB_FILORI as FILORI,"+CRLF
        cSQL:=cSQL+"	CQ7_MOEDA as MOEDA,"+CRLF
        cSQL:=cSQL+"	CTB_TPSLDE as TPSALD,"+CRLF
        cSQL:=cSQL+"	CTB_CTADES as CONTA,"+CRLF
        cSQL:=cSQL+"	CTB_CCDES as CUSTO,"+CRLF
        cSQL:=cSQL+"	CTB_ITEMDE as ITEM,"+CRLF
        cSQL:=cSQL+"	CTB_CLVLDE as CLVL,"+CRLF
        cSQL:=cSQL+"	CQ7_CONTA as CONTA_ORI,"+CRLF
        cSQL:=cSQL+"	CQ7_CCUSTO as CUSTO_ORI,"+CRLF
        cSQL:=cSQL+"	CQ7_ITEM as ITEM_ORI,"+CRLF
        cSQL:=cSQL+"	CQ7_CLVL as CLVL_ORI,"+CRLF
        cSQL:=cSQL+"	CQ7_DTLP as DTLP,"+CRLF
        cSQL:=cSQL+"	CQ7_LP as LP,"+CRLF
        cSQL:=cSQL+"	Sum(CQ7_DEBITO) as DEBITO,"+CRLF
        cSQL:=cSQL+"	Sum(CQ7_CREDIT) as CREDITO,"+CRLF
        cSQL:=cSQL+"	'"+cDataSld+"' as CDATA,"+CRLF
        cSQL:=cSQL+"	1 as FLAG"+CRLF
        cSQL:=cSQL+"from "+aEmpOri[nX,3,2]+" CQ7, "+cCTB+" CTB"+CRLF
        cSQL:=cSQL+"where CQ7.D_E_L_E_T_ = ' ' and CTB.D_E_L_E_T_ = ' '"+CRLF
        cSQL:=cSQL+"and CQ7_FILIAL=CTB_FILORI "+CRLF
        cSQL:=cSQL+"and CTB_EMPORI='"+aEmpOri[nX,1]+"'"+CRLF
        cSQL:=cSQL+"and ( (CQ7_CONTA between CTB_CT1INI and CTB_CT1FIM and CTB_CT1INI<>' ' and CTB_CT1FIM<>' ') or ( (CTB_CT1INI=' ' or CTB_CT1FIM=' ') and CQ7_CONTA=' ' ) )"+CRLF
        cSQL:=cSQL+"and ( (CQ7_CCUSTO between CTB_CTTINI and CTB_CTTFIM and CTB_CTTINI<>' ' and CTB_CTTFIM<>' ') or ( (CTB_CTTINI=' ' or CTB_CTTFIM=' ') and CQ7_CCUSTO=' ' ) )"+CRLF
        cSQL:=cSQL+"and ( (CQ7_ITEM  between CTB_CTDINI and CTB_CTDFIM and CTB_CTDINI<>' ' and CTB_CTDFIM<>' ') or ( (CTB_CTDINI=' ' or CTB_CTDFIM=' ') and CQ7_ITEM =' ' ) )"+CRLF
        cSQL:=cSQL+"and ( (CQ7_CLVL  between CTB_CTHINI and CTB_CTHFIM and CTB_CTHINI<>' ' and CTB_CTHFIM<>' ') or ( (CTB_CTHINI=' ' or CTB_CTHFIM=' ') and CQ7_CLVL =' ' ) )"+CRLF
        cSQL:=cSQL+"and CQ7_TPSALD=CTB_TPSLDO"+CRLF
        cSQL:=cSQL+"and CTB_CODIGO between '"+mv_par12+"' and '"+mv_par13+"'"+CRLF
        If mv_par07<>'*'
            cSQL:=cSQL+"and CQ7_TPSALD='"+mv_par07+"'"+CRLF
        EndIf
        If mv_par05 == 2
            cSQL:=cSQL+"and CQ7_MOEDA='"+cMoeda+"'"+CRLF
        Endif
        cSQL:=cSQL+"Group By CTB_EMPORI, CTB_FILORI, CQ7_MOEDA, CTB_TPSLDE, CTB_CTADES, CTB_CCDES, CTB_ITEMDE, CTB_CLVLDE,CQ7_CONTA , CQ7_CCUSTO, CQ7_ITEM , CQ7_CLVL, CQ7_DTLP,CQ7_LP"+CRLF
        cSQL:=cSQL+""+CRLF
        tcsqlexec(cSQL)
        cSQL :=	""
        /*---   RET 3 ---*/
        cSQL:=cSQL+"insert into "+cTmp+" (EMPORI, FILORI, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, CONTA_ORI, CUSTO_ORI, ITEM_ORI, CLVL_ORI, DTLP, LP, DEBITO, CREDITO, CDATA, FLAG)"+CRLF
        cSQL:=cSQL+"select"+CRLF
        cSQL:=cSQL+"	CTB_EMPORI as EMPORI,"+CRLF
        cSQL:=cSQL+"	CTB_FILORI as FILORI,"+CRLF
        cSQL:=cSQL+"	CQ5_MOEDA as MOEDA,"+CRLF
        cSQL:=cSQL+"	CTB_TPSLDE as TPSALD,"+CRLF
        cSQL:=cSQL+"	CTB_CTADES as CONTA,"+CRLF
        cSQL:=cSQL+"	CTB_CCDES as CUSTO,"+CRLF
        cSQL:=cSQL+"	CTB_ITEMDE as ITEM,"+CRLF
        cSQL:=cSQL+"	CTB_CLVLDE as CLVL,"+CRLF
        cSQL:=cSQL+"	CQ5_CONTA as CONTA_ORI,"+CRLF
        cSQL:=cSQL+"	CQ5_CCUSTO as CUSTO_ORI,"+CRLF
        cSQL:=cSQL+"	CQ5_ITEM as ITEM_ORI,"+CRLF
        cSQL:=cSQL+"	' ' as CLVL_ORI,"+CRLF
        cSQL:=cSQL+"	CQ5_DTLP as DTLP,"+CRLF
        cSQL:=cSQL+"	CQ5_LP as LP,"+CRLF
        cSQL:=cSQL+"	SUM(CQ5_DEBITO) as DEBITO,"+CRLF
        cSQL:=cSQL+"	SUM(CQ5_CREDIT) as CREDITO,"+CRLF
        cSQL:=cSQL+"	'"+cDataSld+"' as CDATA,"+CRLF
        cSQL:=cSQL+"	1 as FLAG"+CRLF
        cSQL:=cSQL+"from "+aEmpOri[nX,4,2]+" CQ5, "+cCTB+" CTB"+CRLF
        cSQL:=cSQL+"where CQ5.D_E_L_E_T_ = ' ' and CTB.D_E_L_E_T_ = ' '"+CRLF
        cSQL:=cSQL+"and CQ5_FILIAL=CTB_FILORI"+CRLF
        cSQL:=cSQL+"and CTB_EMPORI='"+aEmpOri[nX,1]+"'"+CRLF
        cSQL:=cSQL+"and ( (CQ5_CONTA between CTB_CT1INI and CTB_CT1FIM and CTB_CT1INI<>' ' and CTB_CT1FIM<>' ') or ( (CTB_CT1INI=' ' or CTB_CT1FIM=' ') and CQ5_CONTA=' ' ) )"+CRLF
        cSQL:=cSQL+"and ( (CQ5_CCUSTO between CTB_CTTINI and CTB_CTTFIM and CTB_CTTINI<>' ' and CTB_CTTFIM<>' ') or ( (CTB_CTTINI=' ' or CTB_CTTFIM=' ') and CQ5_CCUSTO=' ' ) )"+CRLF
        cSQL:=cSQL+"and ( (CQ5_ITEM  between CTB_CTDINI and CTB_CTDFIM and CTB_CTDINI<>' ' and CTB_CTDFIM<>' ') or ( (CTB_CTDINI=' ' or CTB_CTDFIM=' ') and CQ5_ITEM =' ' ) )"+CRLF
        cSQL:=cSQL+"and ( CTB_CTHINI=' ' or CTB_CTHFIM=' ' )"+CRLF
        cSQL:=cSQL+"and CQ5_TPSALD=CTB_TPSLDO"+CRLF
        cSQL:=cSQL+"and CTB_CODIGO between '"+mv_par12+"' and '"+mv_par13+"'"+CRLF
        If mv_par07<>'*'
            cSQL:=cSQL+"and CQ5_TPSALD='"+mv_par07+"'"+CRLF
        EndIf
        If mv_par05 == 2
            cSQL:=cSQL+"and CQ5_MOEDA='"+cMoeda+"'"+CRLF
        Endif
        cSQL:=cSQL+"Group By CTB_EMPORI,CTB_FILORI,CQ5_MOEDA ,CTB_TPSLDE,CTB_CTADES,CTB_CCDES ,CTB_ITEMDE,CTB_CLVLDE,CQ5_CONTA ,CQ5_CCUSTO,CQ5_ITEM,CQ5_DTLP,CQ5_LP"+CRLF
        tcsqlexec(cSQL)

        cSQL :=	""
        /*---   RET 4 ---*/
        cSQL:=cSQL+"insert into "+cTmp+" (EMPORI, FILORI, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, CONTA_ORI, CUSTO_ORI, ITEM_ORI, CLVL_ORI, DTLP, LP, DEBITO, CREDITO, CDATA, FLAG)"+CRLF
        cSQL:=cSQL+"select"+CRLF
        cSQL:=cSQL+"	CTB_EMPORI as EMPORI,"+CRLF
        cSQL:=cSQL+"	CTB_FILORI as FILORI,"+CRLF
        cSQL:=cSQL+"	CQ3_MOEDA as MOEDA,"+CRLF
        cSQL:=cSQL+"	CTB_TPSLDE as TPSALD,"+CRLF
        cSQL:=cSQL+"	CTB_CTADES as CONTA,"+CRLF
        cSQL:=cSQL+"	CTB_CCDES as CUSTO,"+CRLF
        cSQL:=cSQL+"	CTB_ITEMDE as ITEM,"+CRLF
        cSQL:=cSQL+"	CTB_CLVLDE as CLVL,"+CRLF
        cSQL:=cSQL+"	CQ3_CONTA as CONTA_ORI,"+CRLF
        cSQL:=cSQL+"	CQ3_CCUSTO as CUSTO_ORI,"+CRLF
        cSQL:=cSQL+"	' ' as ITEM_ORI,"+CRLF
        cSQL:=cSQL+"	' ' as CLVL_ORI,"+CRLF
        cSQL:=cSQL+"	CQ3_DTLP as DTLP,"+CRLF
        cSQL:=cSQL+"	CQ3_LP as LP,"+CRLF
        cSQL:=cSQL+"	Sum(CQ3_DEBITO) as DEBITO,"+CRLF
        cSQL:=cSQL+"	Sum(CQ3_CREDIT) as CREDITO,"+CRLF
        cSQL:=cSQL+"	'"+cDataSld+"' as CDATA,"+CRLF
        cSQL:=cSQL+"	1 as FLAG"+CRLF
        cSQL:=cSQL+"from "+aEmpOri[nX,5,2]+" CQ3, "+cCTB+" CTB"+CRLF
        cSQL:=cSQL+"where CQ3.D_E_L_E_T_ = ' ' and CTB.D_E_L_E_T_ = ' '"+CRLF
        cSQL:=cSQL+"and CQ3_FILIAL= CTB_FILORI" +CRLF
        cSQL:=cSQL+"and CTB_EMPORI='"+aEmpOri[nX,1]+"'"+CRLF
        cSQL:=cSQL+"and ( (CQ3_CONTA between CTB_CT1INI and CTB_CT1FIM and CTB_CT1INI<>' ' and CTB_CT1FIM<>' ') or ( (CTB_CT1INI=' ' or CTB_CT1FIM=' ') and CQ3_CONTA=' ' ) )"+CRLF
        cSQL:=cSQL+"and ( (CQ3_CCUSTO between CTB_CTTINI and CTB_CTTFIM and CTB_CTTINI<>' ' and CTB_CTTFIM<>' ') or ( (CTB_CTTINI=' ' or CTB_CTTFIM=' ') and CQ3_CCUSTO=' ' ) )"+CRLF
        cSQL:=cSQL+"and ( CTB_CTDINI=' ' or CTB_CTDFIM=' ' )"+CRLF
        cSQL:=cSQL+"and ( CTB_CTHINI=' ' or CTB_CTHFIM=' ' )"+CRLF
        cSQL:=cSQL+"and CQ3_TPSALD=CTB_TPSLDO"+CRLF
        cSQL:=cSQL+"and CTB_CODIGO between '"+mv_par12+"' and '"+mv_par13+"'"+CRLF
        If mv_par07<>'*'
            cSQL:=cSQL+"and CQ3_TPSALD='"+mv_par07+"'"+CRLF
        EndIf
        If mv_par05 == 2
            cSQL:=cSQL+"and CQ3_MOEDA='"+cMoeda+"'"+CRLF
        Endif
        cSQL:=cSQL+"GROUP BY CTB_EMPORI, CTB_FILORI, CQ3_MOEDA,CTB_TPSLDE, CTB_CTADES,CTB_CCDES,CTB_ITEMDE,CTB_CLVLDE,CQ3_DEBITO,CQ3_CREDIT,CQ3_CONTA,CQ3_CCUSTO,CQ3_DTLP,CQ3_LP"+CRLF
        tcsqlexec(cSQL)
        cSQL :=	""

        /*---   RET 2 ---*/
        cSQL:=cSQL+"insert into "+cTmp+" (EMPORI, FILORI, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, CONTA_ORI, CUSTO_ORI, ITEM_ORI, CLVL_ORI, DTLP, LP, DEBITO, CREDITO, CDATA, FLAG)"+CRLF
        cSQL:=cSQL+"select"+CRLF
        cSQL:=cSQL+"	CTB_EMPORI as EMPORI,"+CRLF
        cSQL:=cSQL+"	CTB_FILORI as FILORI,"+CRLF
        cSQL:=cSQL+"	CQ1_MOEDA as MOEDA,"+CRLF
        cSQL:=cSQL+"	CTB_TPSLDE as TPSALD,"+CRLF
        cSQL:=cSQL+"	CTB_CTADES as CONTA,"+CRLF
        cSQL:=cSQL+"	CTB_CCDES as CUSTO,"+CRLF
        cSQL:=cSQL+"	CTB_ITEMDE as ITEM,"+CRLF
        cSQL:=cSQL+"	CTB_CLVLDE as CLVL,"+CRLF
        cSQL:=cSQL+"	CQ1_CONTA as CONTA_ORI,"+CRLF
        cSQL:=cSQL+"	' ' as CUSTO_ORI,"+CRLF
        cSQL:=cSQL+"	' ' as ITEM_ORI,"+CRLF
        cSQL:=cSQL+"	' ' as CLVL_ORI,"+CRLF
        cSQL:=cSQL+"	CQ1_DTLP as DTLP,"+CRLF
        cSQL:=cSQL+"	CQ1_LP as LP,"+CRLF
        cSQL:=cSQL+"	SUM(CQ1_DEBITO) as DEBITO,"+CRLF
        cSQL:=cSQL+"	SUM(CQ1_CREDIT) as CREDITO,"+CRLF
        cSQL:=cSQL+"	'"+cDataSld+"' as CDATA,"+CRLF
        cSQL:=cSQL+"	1 as FLAG"+CRLF
        cSQL:=cSQL+"from "+aEmpOri[nX,6,2]+" CQ1, "+cCTB+" CTB"+CRLF
        cSQL:=cSQL+"where CQ1.D_E_L_E_T_ = ' ' and CTB.D_E_L_E_T_ = ' '"+CRLF
        cSQL:=cSQL+"and CQ1_FILIAL= CTB_FILORI"+CRLF
        cSQL:=cSQL+"and CTB_EMPORI='"+aEmpOri[nX,1]+"'"+CRLF
        cSQL:=cSQL+"and ( (CQ1_CONTA between CTB_CT1INI and CTB_CT1FIM and CTB_CT1INI<>' ' and CTB_CT1FIM<>' ') or ( (CTB_CT1INI=' ' or CTB_CT1FIM=' ') and CQ1_CONTA=' ' ) )"+CRLF
        cSQL:=cSQL+"and ( CTB_CTTINI=' ' or CTB_CTTFIM=' ' )"+CRLF
        cSQL:=cSQL+"and ( CTB_CTDINI=' ' or CTB_CTDFIM=' ' )"+CRLF
        cSQL:=cSQL+"and ( CTB_CTHINI=' ' or CTB_CTHFIM=' ' )"+CRLF
        cSQL:=cSQL+"and CQ1_TPSALD=CTB_TPSLDO"+CRLF
        cSQL:=cSQL+"and CTB_CODIGO between '"+mv_par12+"' and '"+mv_par13+"'"+CRLF
        If mv_par07<>'*'
            cSQL:=cSQL+"and CQ1_TPSALD='"+mv_par07+"'"+CRLF
        EndIf
        If mv_par05 == 2
            cSQL:=cSQL+"and CQ1_MOEDA='"+cMoeda+"'"+CRLF
        Endif
        cSQL:=cSQL+" group by CTB_EMPORI , CTB_FILORI, CQ1_MOEDA, CTB_TPSLDE, CTB_CTADES, CTB_CCDES, CTB_ITEMDE, CTB_CLVLDE, CQ1_CONTA, CQ1_DTLP, CQ1_LP"+CRLF
        tcsqlexec(cSQL)
        cSQL :=	""

    Next
    // CURSOR 5
    cSQL:= ""
    cSQL+=" SELECT EMPORI , FILORI , CDATA , MOEDA , TPSALD , CONTA_ORI , CUSTO_ORI , ITEM_ORI , CLVL_ORI , MIN ( LP ) as LP1 , MAX ( LP ) as LP2 "+CRLF
    cSQL+="   FROM "+cTmp+CRLF
    cSQL+=" GROUP BY EMPORI , FILORI , CDATA , MOEDA , TPSALD , CONTA_ORI , CUSTO_ORI , ITEM_ORI , CLVL_ORI "+CRLF
    cSQL+=" HAVING COUNT ( * ) > 1 "+CRLF
    cLp	:= ""
	cSQL := ChangeQuery(cSQL)
	MPSysOpenQuery(cSQL, "CUR5")
    WHILE CUR5->(!EOF())
		if CUR5->LP1=='S'
			cLp	:=	CUR5->LP2
		Else
			cLp	:=	CUR5->LP1
		endif
        cUpdate := "DELETE "+cTmp
        cUpdate += " WHERE EMPORI  = '"+CUR5->EMPORI+"'  and FILORI  = '"+CUR5->FILORI+"'  and CDATA  = '"+CUR5->CDATA+"' "
        cUpdate += "   and MOEDA  = '"+CUR5->MOEDA+"'  and TPSALD  = '"+CUR5->TPSALD+"'  and CONTA_ORI  = '"+CUR5->CONTA_ORI+"' "
        cUpdate += "   and CUSTO_ORI  = '"+CUR5->CUSTO_ORI+"'  and ITEM_ORI  = '"+CUR5->ITEM_ORI+"'  and CLVL_ORI  = '"+CUR5->CLVL_ORI+"'  and LP  <> '"+cLp+"'  "
        TcSqlExec(cUpdate)
        CUR5->(DBSKIP())
    END
    CUR5->(DBCloseArea())

    // CURSOR 2
    cSQL:= ""
    cSQL+=" SELECT EMPORI , FILORI , CONTA_ORI , CUSTO_ORI , ITEM_ORI , COALESCE ( SUM(DEBITO ), 0 ) as DEBITO , COALESCE ( SUM(CREDITO ), 0 ) as CREDITO "+CRLF
    cSQL+=" FROM "+cTmp+CRLF
    cSQL+=" WHERE CLVL_ORI  <> ' '  "+CRLF
    cSQL+=" GROUP BY EMPORI , FILORI , CONTA_ORI , CUSTO_ORI , ITEM_ORI  "
	cSQL := ChangeQuery(cSQL)
    MPSysOpenQuery(cSQL, "CUR2")
    WHILE CUR2->(!EOF())
        cUpdate := " UPDATE "+cTmp+" SET DEBITO  = DEBITO  - "+CVALTOCHAR(CUR2->DEBITO)+" , CREDITO  = CREDITO  - "+CVALTOCHAR(CUR2->CREDITO)
		cUpdate += "  WHERE EMPORI  = '"+CUR2->EMPORI+"' and FILORI  = '"+CUR2->FILORI+"'  and CONTA_ORI  = '"+CUR2->CONTA_ORI+"'  and CUSTO_ORI = '"+CUR2->CUSTO_ORI+"' and ITEM_ORI  = '"+CUR2->ITEM_ORI+"' "
		cUpdate += "    and CLVL_ORI  = ' ' "
		TcSqlExec(cUpdate)
		cUpdate := " UPDATE "+cTmp+" SET DEBITO  = DEBITO  - "+CVALTOCHAR(CUR2->DEBITO)+" , CREDITO  = CREDITO  - "+CVALTOCHAR(CUR2->CREDITO)
		cUpdate += "  WHERE EMPORI  = '"+CUR2->EMPORI+"' and FILORI  = '"+CUR2->FILORI+"'  and CONTA_ORI  = '"+CUR2->CONTA_ORI+"'  and CUSTO_ORI = '"+CUR2->CUSTO_ORI+"' and ITEM_ORI  = ' ' "
		cUpdate += "    and CLVL_ORI  = ' ' "
		TcSqlExec(cUpdate)
        cUpdate := " UPDATE "+cTmp+" SET DEBITO  = DEBITO  - "+CVALTOCHAR(CUR2->DEBITO)+" , CREDITO  = CREDITO  - "+CVALTOCHAR(CUR2->CREDITO)
        cUpdate += "  WHERE EMPORI  = '"+CUR2->EMPORI+"' and FILORI  = '"+CUR2->FILORI+"'  and CONTA_ORI  = '"+CUR2->CONTA_ORI+"'  and CUSTO_ORI = ' ' and ITEM_ORI  = ' ' "
        cUpdate += "    and CLVL_ORI  = ' ' "
        TcSqlExec(cUpdate)
        CUR2->(DBSKIP())
    END
    CUR2->(DBCloseArea())

    // CURSOR 3
    cSQL:= ""
    cSQL+= " select EMPORI, FILORI, CONTA_ORI, CUSTO_ORI, COALESCE(sum(DEBITO),0) as DEBITO, COALESCE(sum(CREDITO),0) as CREDITO"+CRLF
    cSQL+= "   from "+cTmp+CRLF
    cSQL+= "  where ITEM_ORI<>' ' and CLVL_ORI=' '"+CRLF
    cSQL+= "  group by EMPORI, FILORI, CONTA_ORI, CUSTO_ORI"+CRLF
	cSQL := ChangeQuery(cSQL)
    MPSysOpenQuery(cSQL, "CUR3")
    WHILE CUR3->(!EOF())
		cUpdate := " UPDATE "+cTmp+" SET DEBITO  = DEBITO  - "+CVALTOCHAR(CUR3->DEBITO)+" , CREDITO  = CREDITO  - "+CVALTOCHAR(CUR3->CREDITO)
		cUpdate += "  WHERE EMPORI  = '"+CUR3->EMPORI+"' and FILORI  = '"+CUR3->FILORI+"'  and CONTA_ORI  = '"+CUR3->CONTA_ORI+"'  and CUSTO_ORI = '"+CUR3->CUSTO_ORI+"' AND ITEM_ORI=' ' AND CLVL_ORI=' ' "
		TcSqlExec(cUpdate)
        cUpdate := " UPDATE "+cTmp+" SET DEBITO  = DEBITO  - "+CVALTOCHAR(CUR3->DEBITO)+" , CREDITO  = CREDITO  - "+CVALTOCHAR(CUR3->CREDITO)
        cUpdate += "  WHERE EMPORI  = '"+CUR3->EMPORI+"' and FILORI  = '"+CUR3->FILORI+"'  and CONTA_ORI  = '"+CUR3->CONTA_ORI+"'  and CUSTO_ORI = ' ' AND ITEM_ORI=' ' AND CLVL_ORI=' ' "
        TcSqlExec(cUpdate)
        CUR3->(DBSKIP())
    END
    CUR3->(DBCloseArea())

    // CURSOR 4
    cSQL:= ""
    cSQL+= " select EMPORI, FILORI, CONTA_ORI, COALESCE(sum(DEBITO),0) as DEBITO, COALESCE(sum(CREDITO),0) as CREDITO"+CRLF
    cSQL+= "   from "+cTmp+CRLF
    cSQL+= "  where CUSTO_ORI<>' ' and ITEM_ORI=' ' and CLVL_ORI=' '"+CRLF
    cSQL+= "  group by EMPORI, FILORI, CONTA_ORI "+CRLF
	cSQL := ChangeQuery(cSQL)
    MPSysOpenQuery(cSQL, "CUR4")
    WHILE CUR4->(!EOF())
        cUpdate := " UPDATE "+cTmp+" SET DEBITO  = DEBITO  - "+CVALTOCHAR(CUR4->DEBITO)+" , CREDITO  = CREDITO  - "+CVALTOCHAR(CUR4->CREDITO)
        cUpdate += "  WHERE EMPORI  = '"+CUR4->EMPORI+"' and FILORI  = '"+CUR4->FILORI+"'  and CONTA_ORI  = '"+CUR4->CONTA_ORI+"'  and CUSTO_ORI = ' ' AND ITEM_ORI=' ' AND CLVL_ORI=' ' "
        TcSqlExec(cUpdate)
        CUR4->(DBSKIP())
    END
    CUR4->(DBCloseArea())

    // CURSOR MAE
    cSQL:= ""
    cSQL+= " select"+CRLF
    cSQL+= " 	max(EMPORI) as EMPORI,"+CRLF
    cSQL+= " 	max(FILORI) as FILORI,"+CRLF
    cSQL+= " 	CDATA,"+CRLF
    cSQL+= " 	MOEDA,"+CRLF
    cSQL+= " 	TPSALD,"+CRLF
    cSQL+= " 	CONTA,"+CRLF
    cSQL+= " 	CUSTO,"+CRLF
    cSQL+= " 	ITEM,"+CRLF
    cSQL+= " 	CLVL,"+CRLF
    cSQL+= " 	DTLP,"+CRLF
    cSQL+= " 	sum(DEBITO) as DEBITO,"+CRLF
    cSQL+= " 	sum(CREDITO) as CREDITO"+CRLF
    cSQL+= " from "+cTmp+CRLF
    cSQL+= " group by CDATA, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, DTLP"+CRLF
    cSQL+= " order by CDATA"+CRLF
    MPSysOpenQuery(cSQL, "MAE")
    cLinha  := '001'

    CTF->(DBSETORDER(1))//CTF_FILIAL, CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC
    CT2->(DBSETORDER(1))//CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC, R_E_C_N_O_, D_E_L_E_T_
	cDoc	:= mv_par11
	cLote	:= mv_par09
	cSub	:= mv_par10
	cFilCT2	:= xFilial("CT2")
    WHILE MAE->(!EOF())
        nFlag	:= 1
        nCria	:= 1
        nValor	:= MAE->CREDITO - MAE->DEBITO
        WHILE nFlag < 3
            if ( round(MAE->CREDITO, val(cDec) ) = round(MAE->DEBITO, val(cDec)) ) .and. ( round(MAE->CREDITO, val(cDec)) <> 0 .or. round(MAE->DEBITO, val(cDec)) <> 0 )
                if nflag = 1
                    nValor	:= MAE->CREDITO
                    nflag	:= 2
                elseif nflag = 2
                    nValor	:= ( 0 - MAE->DEBITO )
                	nflag	:= 3
                endif
                nCria	:= 1
            else
                if round(nValor, val(cDec)) <> 0
                    nCria	:= 1
                else
                    nCria	:= 0
                	nflag	:= 3
                endif
            endif
            if nCria = 1
                if cLinha >= cMaxLin
                    IF cDoc == '999999'
                        cDoc := '000001'
                        IF cLote  == '999999'
                            cLote		:= '000001'
                            nI			:= val(cSub) + 1
                            cSub		:= strzero(nI,3)
                        ELSE
                            ni			:= val(cLote) + 1
                            cLote		:= strzero(nI,nTamLote)
                        ENDIF
                    else
						If (mv_par05 == 1 .AND. cMoeda =='01') .OR. mv_par05 != 1
							nI				:= val(cDoc) + 1
                        	cDoc			:= strzero(nI,ntamdoc)
						ENDIF
                    endif
                    cLinha      := '001'
                endif
            Else
				If (mv_par05 == 1 .AND. cMoeda =='01') .OR. mv_par05 != 1
					ni          := val(cLinha) + 1
					clinha      := strzero( ni, 3 )
				ENDIF
            ENDIF
			Do While !ProxDoc(stod(MAE->CDATA),cLote,cSub,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso o N§ do Doc estourou, incrementa o lote         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cLote := CtbInc_Lot(cLote, cModulo)
			Enddo

			// gravação
			lSeek       := !(CT2->(DBSeek(cFilCT2+MAE->CDATA+cLote+cSub+cDoc+clinha+MAE->TPSALD+MAE->EMPORI+MAE->FILORI+MAE->MOEDA)))
			IF lSeek
				RECLOCK("CT2",.T.)
				CT2->CT2_FILIAL  := cFilCT2
				CT2->CT2_DATA    := stod(MAE->CDATA)
				CT2->CT2_LOTE    := cLote
				CT2->CT2_SBLOTE  := cSub
				CT2->CT2_DOC     := cDoc
				CT2->CT2_LINHA   := clinha
				CT2->CT2_MOEDLC  := MAE->MOEDA
				if nValor  < 0
					CT2->CT2_DC      := '1'
				else
					CT2->CT2_DC      := '2'
				endif
				CT2->CT2_DEBITO  := MAE->CONTA
				CT2->CT2_VALOR   := ABS(nValor)
				CT2->CT2_HIST    := 'Saldo Inicial'
				CT2->CT2_CCD     := MAE->CUSTO
				CT2->CT2_ITEMD   := MAE->ITEM
				CT2->CT2_CLVLDB  := MAE->CLVL
				CT2->CT2_EMPORI  := MAE->EMPORI
				CT2->CT2_FILORI  := MAE->FILORI
				CT2->CT2_TPSALD  := MAE->TPSALD
				CT2->CT2_DTLP    := STOD(MAE->DTLP)
				CT2->CT2_MANUAL  := '1'
				CT2->CT2_ROTINA  := 'CTBA231'
				CT2->CT2_AGLUT   := '1'
				CT2->CT2_SEQHIS  := '001'
				CT2->CT2_SEQLAN  := clinha
				CT2->CT2_TAXA    := 0
				CT2->CT2_VLR01   := 0
				CT2->CT2_VLR02   := 0
				CT2->CT2_VLR03   := 0
				CT2->CT2_VLR04   := 0
				CT2->CT2_VLR05   := 0
				CT2->CT2_CRCONV  := '1'
				CT2->CT2_CTLSLD  := '0'
				MsUnlock()
			endif
		    /* Ponto de Entrada para minipulaçãoo das informações de origem, 
			esta demanda foi disponibilizada pois o cliente tinha necessidade 
			de levar o complemento do histórico completo para a consolidadora	*/
			If ExistBlock("CTB231PR")
				ExecBlock( "CTB231PR", .F., .F.)
			Endif
        END
        MAE->(DBSKIP())
    END
    MAE->(DBCloseArea())

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231SldIni³ Autor  ³ TOTVS                   ³ Data 18.05.10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Gera lancamentos de saldo inicial NOVAS ENTIDADES		    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Ct231SlInP(aEmpOri)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ ExpA1 - Array com os nomes das tabelas das empresas origem  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct231SldIni(aEmpOri,cAliasCTB)
Local aCtbMoeda	:= CtbMoeda(mv_par06)
Local cMoeda	:= aCtbMoeda[1]
Local cDataSld	:= DTOS(mv_par02-1)
Local nX		:= 0
Local nZ		:= 0
Local cQuery	:= ""
Local cWhere	:= ""
Local cSelect	:= "CTB_EMPORI,CTB_FILORI,"
Local nQtdeEnt
Local cEntidade	:= ""
Local aCposEnt	:= {}
Local aCampos	:= {}
Local cTmp1		:= ""
Local nPos		:= 0
Local cQry		:= ""
Local cQryAlias	:= ""
Local aTamVlr  	:= TamSX3("CVX_SLDCRD")
Local CTF_LOCK	:= 0
Local cLote		:= mv_par09
Local cSubLote	:= mv_par10
Local cDoc		:= mv_par11
Local cLinha	:= "001"
Local cSeqLan	:= "001"
Local nLinha	:= 0
Local lFirst	:= .T.
Local aCpoDeb	:= {}
Local aCpoCrd	:= {}

Private lSublote := .T.

If mv_par05==2 .And. Empty(cMoeda)
	Help(" ",1,"NOMOEDA")
	Return .F.
EndIf

nQtdeEnt := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor

AADD(aCposEnt,{	'CVX_NIV01',;						// 1 - Nome campo temporario
'CTB_CTADES',;						// 2 - Nome do campo entidade DESTINO
'CTB_CT1INI',;						// 3 - Nome do campo entidade INICIO
'CTB_CT1FIM',;						// 4 - Nome do campo entidade FIM
'CT2_DEBITO',;						// 5 - Nome do campo tabela CT2 entidade DEBITO
'CT2_CREDIT'})						// 6 - Nome do campo tabela CT2 entidade CREDITO

AADD(aCposEnt,{	'CVX_NIV02',;						// 1 - Nome campo temporario
'CTB_CCDES',;						// 2 - Nome do campo entidade DESTINO
'CTB_CTTINI',;						// 3 - Nome do campo entidade INICIO
'CTB_CTTFIM',;						// 4 - Nome do campo entidade FIM
'CT2_CCD',;							// 5 - Nome do campo tabela CT2 entidade DEBITO
'CT2_CCC'})							// 6 - Nome do campo tabela CT2 entidade CREDITO

AADD(aCposEnt,{	'CVX_NIV03',;						// 1 - Nome campo temporario
'CTB_ITEMDE',;						// 2 - Nome do campo entidade DESTINO
'CTB_CTDINI',;						// 3 - Nome do campo entidade INICIO
'CTB_CTDFIM',;						// 4 - Nome do campo entidade FIM
'CT2_ITEMD',;						// 5 - Nome do campo tabela CT2 entidade DEBITO
'CT2_ITEMC'})						// 6 - Nome do campo tabela CT2 entidade CREDITO

AADD(aCposEnt,{	'CVX_NIV04',;						// 1 - Nome campo temporario
'CTB_CLVLDE',;						// 2 - Nome do campo entidade DESTINO
'CTB_CTHINI',;						// 3 - Nome do campo entidade INICIO
'CTB_CTHFIM',;						// 4 - Nome do campo entidade FIM
'CT2_CLVLDB',;						// 5 - Nome do campo tabela CT2 entidade DEBITO
'CT2_CLVLCR'})						// 6 - Nome do campo tabela CT2 entidade CREDITO

AADD(aCampos,{"CVX_SLDCRD"	,"N"	,aTamVlr[1]+2	,aTamVlr[2]})
AADD(aCampos,{"CVX_SLDDEB"	,"N"	,aTamVlr[1]+2	,aTamVlr[2]})
AADD(aCampos,{"CTB_EMPORI"	,"C"	,TamSX3("CTB_EMPORI")[1]+2	,0})
AADD(aCampos,{"CTB_FILORI"	,"C"	,TamSX3("CTB_FILORI")[1]+2	,0})


nPos := 2
For nZ:= 1 To nQtdeEnt
	cEntidade := StrZero(nZ,2)
	If nZ >= 5
		AADD(aCposEnt,{	'CVX_NIV'+cEntidade,;	 			// 1 - Nome campo temporario
		'CTB_E'+cEntidade+'DES',;			// 2 - Nome do campo entidade DESTINO
		'CTB_E'+cEntidade+'INI',;			// 3 - Nome do campo entidade INICIO
		'CTB_E'+cEntidade+'FIM',;			// 4 - Nome do campo entidade FIM
		CtbCposCrDb("CT2","D", cEntidade),;	// 5 - Nome do campo tabela CT2 entidade DEBITO
		CtbCposCrDb("CT2","C", cEntidade)})	// 6 - Nome do campo tabela CT2 entidade CREDITO
	EndIf
	cSelect += aCposEnt[nZ][2]+ Iif(nZ<nQtdeEnt,',','')
	cWhere  += "and ( ("+aCposEnt[nZ][1]+" between "+aCposEnt[nZ][3]+" and "+aCposEnt[nZ][4]+" and "+aCposEnt[nZ][3]+"<>' ' and "+aCposEnt[nZ][4]+"<>' ') or ( ("+aCposEnt[nZ][3]+"=' ' or "+aCposEnt[nZ][4]+"=' ') and "+aCposEnt[nZ][1]+"=' ' ) )"+CRLF
	
	AADD(aCampos,{aCposEnt[nZ][nPos],"C",TamSX3(aCposEnt[nZ][nPos])[1],0})
	
	//             campo CT2       campo QUERY
	AADD(aCpoDeb,{aCposEnt[nZ][5],aCposEnt[nZ][nPos]})
	AADD(aCpoCrd,{aCposEnt[nZ][6],aCposEnt[nZ][nPos]})
	
Next nZ

cTmp1 := CriaTrab( nil, .F. )
If CT231CrTB(cTmp1,aCampos)

	For nX:=1 to Len(aEmpOri)
		
		cQuery += "insert into "+cTmp1+" (CVX_SLDCRD,CVX_SLDDEB," + cSelect + ") "
		cQuery += "SELECT SUM(CVX_SLDCRD) CVX_SLDCRD,SUM(CVX_SLDDEB) CVX_SLDDEB,"
		cQuery += cSelect
		cQuery += " from "+aEmpOri[nX,2,2]+" CVX, "+cAliasCTB+" CTB"+CRLF
		cQuery += " where CVX.D_E_L_E_T_ = ' ' and CTB.D_E_L_E_T_ = ' '"+CRLF
		cQuery += " and CVX_FILIAL=CTB_FILORI"+CRLF
		cQuery += " and CTB_EMPORI='"+aEmpOri[nX,1]+"'"+CRLF
		cQuery += " and CVX_TPSALD=CTB_TPSLDO"+CRLF
		cQuery += " and CTB_CODIGO between '"+mv_par12+"' and '"+mv_par13+"'"+CRLF
		cQuery += cWhere
		
		If mv_par07<>'*'
			cQuery += " and CVX_TPSALD='"+mv_par07+"'"+CRLF
		EndIf
		
		If mv_par05 == 2
			cQuery += " and CVX_MOEDA='"+cMoeda+"'"+CRLF
		Endif
		
		cQuery += "	and CVX_DATA  <= '"+cDataSld+"'"+CRLF
		cQuery += "	and CVX_CONFIG  = '"+StrZero(nQtdeEnt,2)+"'"+CRLF
		
		cQuery += " GROUP BY "+ cSelect
		
		if TcSqlExec(cQuery)<>0
			if !__lBlind
				MsgAlert("Erro atualizando arquivo temp funcao Ct231SldIni : "+TCSqlError())
			endif
			conout("Erro atualizando arquivo temp funcao Ct231SldIni : "+TCSqlError())
		endif
		
		cQuery:= ""
		
	Next nX
	
	cQry += "SELECT SUM(CVX_SLDCRD) CVX_SLDCRD,SUM(CVX_SLDDEB) CVX_SLDDEB,"
	cQry += cSelect
	cQry += " FROM " + cTmp1
	cQry += " GROUP BY "+ cSelect
	cQry := ChangeQuery(cQry)
	cQryAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cQryAlias,.T.,.T.)
	TCSetField(cQryAlias,"CVX_SLDCRD", "N",aTamVlr[1],aTamVlr[2])
	TCSetField(cQryAlias,"CVX_SLDDEB", "N",aTamVlr[1],aTamVlr[2])
	
	DbSelectArea(cQryAlias)
	DbGoTop()
	While (cQryAlias)->(!Eof())
		
		nLinha := Val(cLinha)
		
		If lFirst .or. nLinha > nMAX_LINHA
			
			//Gera numero de Lote e Documento na validacao da Data
			C050Next(Stod(cDataSld),@cLote,@cSubLote,@cDoc,,,,@CTF_LOCK,3,1)
			
			lFirst := .F.
			cLinha := "001"
			nLinha := 0
			cSeqLan:= "001"
		Else
			cSeqLan	:= Soma1(cSeqLan)
			cLinha	:= Soma1(cLinha)
		EndIf
		
		//Debito
		If (cQryAlias)->CVX_SLDDEB > 0
			
			Ct231GrvCT2(Stod(cDataSld),cLote,cSubLote,cDoc,'01'/*cMoedaLanc*/,'1',cLinha,(cQryAlias)->CVX_SLDDEB,(cQryAlias)->CTB_EMPORI,(cQryAlias)->CTB_FILORI,'1'/*cTpSaldo*/,StrZero(1,3),cSeqLan,aCpoDeb,cQryAlias)
			
		EndIf
		
		nLinha := Val(cLinha)
		
		If lFirst .or. nLinha > nMAX_LINHA
			
			//Gera numero de Lote e Documento na validacao da Data
			C050Next(Stod(cDataSld),@cLote,@cSubLote,@cDoc,,,,@CTF_LOCK,3,1)
			
			lFirst := .F.
			cLinha := "001"
			nLinha := 0
			cSeqLan:= "001"
		Else
			cSeqLan	:= Soma1(cSeqLan)
			cLinha	:= Soma1(cLinha)
		EndIf
		
		//Credito
		If (cQryAlias)->CVX_SLDCRD > 0
			
			Ct231GrvCT2(Stod(cDataSld),cLote,cSubLote,cDoc,'01'/*cMoedaLanc*/,'2',cLinha,(cQryAlias)->CVX_SLDCRD,(cQryAlias)->CTB_EMPORI,(cQryAlias)->CTB_FILORI,'1'/*cTpSaldo*/,StrZero(1,3),cSeqLan,aCpoCrd,cQryAlias)
			
		EndIf
		
		(cQryAlias)->(DbSkip())
		
	EndDo
	
	If Select(cQryAlias) > 0
		DbSelectArea(cQryAlias)
		DbCloseArea()
	EndIf
	MsErase(cTmp1,,"TOPCONN")
EndIf



Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³Ct231GrvCT2 ³ Autor  ³ TOTVS                   ³ Data 20.05.10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Grava registro no CT2                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ Ct231GrvCT2                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ SigaCTB                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Par„metros³ExpD1 = Data do lancamento                                    ³±±
±±³           ³ExpC2 = Numero do lote                                        ³±±
±±³           ³ExpC3 = Numero do sub-lote                                    ³±±
±±³           ³ExpC4 = Numero do documento                                   ³±±
±±³           ³ExpC5 = Codigo da moeda                                       ³±±
±±³           ³ExpC6 = tipo do lancamento 1-Debito e 2-Credito               ³±±
±±³           ³ExpC7 = Numero da linha do lancamento                         ³±±
±±³           ³ExpN8 = Valor                                                 ³±±
±±³           ³ExpC9 = Empresa origem                                        ³±±
±±³           ³ExpC10= Filial origem                                         ³±±
±±³           ³ExpC11= Tipo do saldo                                         ³±±
±±³           ³ExpC12= Sequencia do historico                                ³±±
±±³           ³ExpC13= Sequencia do lancamento                               ³±±
±±³           ³ExpA14= Array com campos do CT2 e da query                    ³±±
±±³           ³ExpC15= Alias da query                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ct231GrvCT2(cData,cLote,cSbLote,cDoc,cMoedaLanc,cTpDC,cLinha,nValor,c_EmpOri,c_FilOri,cTpSaldo,cSeqHist,cSeqLan,aCpos,cQryAlias)
Local aAreaAtu	:= GetArea()
Local nCp		:= 0

DbSelectArea('CT2')
RecLock('CT2',.T.)
CT2->CT2_FILIAL	:= xFilial('CT2')
CT2->CT2_DATA	:= cData
CT2->CT2_LOTE	:= cLote
CT2->CT2_SBLOTE	:= cSbLote
CT2->CT2_DOC	:= cDoc
CT2->CT2_MOEDLC	:= cMoedaLanc
CT2->CT2_DC		:= cTpDC
CT2->CT2_VALOR	:= nValor
CT2->CT2_HIST	:= 'Saldo Inicial'
CT2->CT2_EMPORI	:= c_EmpOri
CT2->CT2_FILORI	:= c_FilOri
CT2->CT2_TPSALD	:= cTpSaldo
CT2->CT2_MANUAL	:= '1'
CT2->CT2_ROTINA	:= 'CTBA231'
CT2->CT2_AGLUT	:= '1'
CT2->CT2_SEQHIS	:= cSeqHist
CT2->CT2_SEQLAN	:= cSeqLan
CT2->CT2_LINHA	:= cLinha
CT2->CT2_CRCONV	:= '1'
CT2->CT2_CTLSLD	:= '0'

For nCp:=1 To Len(aCpos)
	CT2->&(aCpos[nCp][1]) := (cQryAlias)->&(aCpos[nCp][2])
Next nCp

MsUnlock()

RestArea(aAreaAtu)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct231VldSld  ºAutor  ³Microsiga        º Data ³  04/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se saldos destinos são iguais                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ct231VldSld()
Local lRet := .T.
Local cTpSald := ""

dbSelectArea("CTB")
dbSetOrder(1)
If !Empty(mv_par12)
	If !dbSeek(xFilial("CTB")+mv_par12)
		MsgInfo(STR0026)  //"Roteiro Inicial não encontrado. Verifique!"
		lRet := .F.
	EndIf
Else
	If Empty(mv_par13)
		MsgInfo(STR0027)  //"Roteiro Final não preenchido. Verifique!"
		lRet := .F.
	Else
		If !dbSeek(xFilial("CTB")+mv_par13)
			MsgInfo(STR0028)  //"Roteiro Final não encontrado. Verifique!"
			lRet := .F.
		EndIf
	EndIf
	If lRet
		dbSeek(xFilial("CTB"))
		mv_par12 := CTB_CODIGO  //qdo nao informado roteiro inicial posiciona com xFilial e pega o primeiro
	EndIf
EndIf
If lRet
	cTpSald := CTB->CTB_TPSLDE
	CTB->(dbSkip())
	While CTB->(!Eof() .And. CTB_CODIGO >= mv_par12 .And.  CTB_CODIGO <= mv_par13)
		If cTpSald != CTB->CTB_TPSLDE
			MsgInfo(STR0029) //"Tipo de saldo destino deve ser igual para todos os roteiros na consolidacao configurada. Verifique!"
			lRet := .F.
			Exit
		EndIf
		CTB->(dbSkip())
	EndDo
EndIf

Return(lRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT231TbCTBºAutor  ³Alvaro Camillo Neto º Data ³  17/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna uma cópia da tabela CTB mas com o campo CTB_CT2FIL º±±
±±º          ³ tratado com a filial da tabela CT2 da empresa origem       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT231TbCTB(cAliasCTB,aEmpCT2)
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaCTB	:= CTB->(GetArea())
Local aStruct	:= CTB->(dbStruct())
Local nX		:= 0                                       
Local nPos		:= 0
Local aAux		:= {}
Local cModoEmp	:= ""
Local cModoUn	:= ""
Local cModoFil	:= ""
Local cConteudo := ""

cAliasCTB := GetNextAlias() 

MsErase(cAliasCTB,,"TOPCONN")
MsCreate(cAliasCTB, aStruct, 'TOPCONN' ) 
dbUseArea( .T., 'TOPCONN', cAliasCTB, cAliasCTB, .T., .F. ) 
dbSelectArea( cAliasCTB ) 
CTB->(dbGoTop())
While CTB->(!EOF())
	If CTB->CTB_FILIAL == xFilial("CTB") .And. CTB->CTB_CODIGO >= MV_PAR12 .And. CTB->CTB_CODIGO <= MV_PAR13 
		RecLock(cAliasCTB,.T.)
		For nX := 1 to Len(aStruct)
			cConteudo := ""

			If aStruct[nX][1] == "CTB_CT1FIM" 
				cConteudo := CTB->&(aStruct[nX][1])
				(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])				
			EndIf

			If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_CTTFIM" 
				cConteudo := CTB->&(aStruct[nX][1])
				(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
			EndIf

			If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_CTDFIM" 
				cConteudo := CTB->&(aStruct[nX][1])
				(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
			EndIf
			
			If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_CTHFIM" 
				cConteudo := CTB->&(aStruct[nX][1])
				(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
			EndIf

			If __lCtbIsCube
				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E05FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf
				
				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E06FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf
				
				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E07FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf
				
				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E08FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf

				If Empty(cConteudo) .And. aStruct[nX][1] == "CTB_E09FIM" 
					cConteudo := CTB->&(aStruct[nX][1])
					(cAliasCTB)->&(aStruct[nX][1]) := C231RetRg(@cConteudo,aStruct[nX][3])	
				EndIf
			EndIf


			If Empty(cConteudo)
				If aStruct[nX][1] == "CTB_CT2FIL"

					nPos := AScan(aEmpCT2 ,{|x| Alltrim(x[1]) == AllTrim(CTB->CTB_EMPORI)})

					If nPos > 0

						aAux := aEmpCT2[nPos][2] 

						cModoEmp := aAux[1]
						cModoUn  := aAux[2]
						cModoFil := aAux[3]

						(cAliasCTB)->CTB_CT2FIL := FWXFilial("CT2",CTB->CTB_FILORI,cModoEmp,cModoUN,cModoFil)

					Else

						lRet := .F.
						Help(" ",1,"CT231TbCTB",,STR0034,1,0) //"Problema na leitura da tabela CTB no preparo para execução."
						Exit

					EndIf

				Else
					(cAliasCTB)->&(aStruct[nX][1]) := CTB->&(aStruct[nX][1])
				EndIf
			EndIf			

		Next nX

		MsUnLock()
	EndIf
	CTB->(dbSkip())
EndDo

(cAliasCTB)->(dbCloseArea())
RestArea(aAreaCTB)
RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA231   ºAutor  ³Microsiga           º Data ³  04/17/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT231CrTB(cTmp,aCampos)
Local lRet := .T.
Local cSQL := ""
Local nX   := 0

cSQL += 'CREATE TABLE '+cTmp+' ( ' 
For nX := 1 to Len(aCampos)
	cSQL += ' ' +aCampos[nX][1]
	If aCampos[nX][2] == "N" 
		cSQL += ' numeric'
		cSQL += '(' + cValtoChar(aCampos[nX][3]) + ',' + cValtoChar(aCampos[nX][4]) + ') '
	Else
		cSQL += ' varchar'
		cSQL += '(' + cValtoChar(aCampos[nX][3]) + ') '
	EndIf
	cSQL += ","
Next nX
cSQL := Left(cSQL,Len(cSQL)-1)
cSQL += ')'

if TcSqlExec(cSQL)<>0
	if !__lBlind
		MsgAlert(STR0019+" "+cTmp+": "+TCSqlError())  //'Erro criando a tabela temporaria'
	endif
	conout(STR0019+" "+cTmp+": "+TCSqlError())  //'Erro criando a tabela temporaria:'
	lRet := .F.
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C231RetRg
Retorna o valor máximo zzz formatado com o tamanho do campo

@author TOTVS
@since 18/09/2023
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function C231RetRg(cConteudo,nTamCpo)
DEFAULT cConteudo := ""
DEFAULT nTamCpo := 0

If Empty(cConteudo)
	cConteudo := Replicate('z',nTamCpo)
EndIf

Return cConteudo
