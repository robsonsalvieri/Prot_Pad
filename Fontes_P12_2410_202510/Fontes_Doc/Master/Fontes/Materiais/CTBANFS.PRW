#INCLUDE "CTBANFS.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE OPT_SELECT 1
#DEFINE OPT_FROM   2                                                                      
#DEFINE OPT_WHERE  3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao do array para controle do processamento MultThread³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE ARQUIVO		 		1
#DEFINE MARCA		 	  	2
#DEFINE QTD_REGISTROS		3
#DEFINE VAR_STATUS			4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Flag de processamento escrito no arquivo de controle ³
//³de threads                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE OK		 		"OK"
#DEFINE ERRO		 	"ERRO"

Static lAuthToken := Alltrim(__FWLibVersion()) >= "20250630"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTBANFS   ³Autor  ³ Eduardo Riera         ³ Data ³20.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de processamento da contabilizacao off-line dos Docu- ³±±
±±³          ³mentos de Saida.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Parametros da rotina                                  ³±±
±±³          ³       Quando informado nao existe a necessidade de interface³±±
±±³          ³       com o usuario. Pode ser colocado como um servico do   ³±±
±±³          ³       sistema.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo contabilizar os documentos de  ³±±
±±³          ³saida com base nos lancamentos contabeis, de forma off-line  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB/FAT/OMS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function CTBANFS(aPergunte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis locais                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSays    := {}
Local aButtons := {}
Local nOpcA    := 0
Local nX       := 0
Local cPerg    := "CTBNFS"
Local cMvPar   := ""
Local lAuto    := aPergunte<>Nil
Local oRegua   := Nil
Local cString
Local nNumProc := GetMv("MV_CNFSTHR", .F., 1 )
Local lOptNfs  := GetMV("MV_OPTNFS", .F., 1 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis Private                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aRotina := MenuDef()
Private cCadastro := STR0002  //"Lan‡amentos Contabeis Off-Line"
Private INCLUI    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida o Bloqueio de processo do calendário contábil         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ctbValiDt( Nil, dDataBase, .T., Nil, Nil, { "FAT003" }, Nil )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desliga Refresh no Lock do Top                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TCInternal(5,"*OFF")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ mv_par01 - Mostra Lancamentos Contabeis ?  Sim Nao           ³
	//³ mv_par02 - Aglutina Lancamentos         ?  Sim Nao           ³  
	//³ mv_par03 - Gerar Lancamentos Por        ?  NF  Periodo Dia   ³
	//³ mv_par04 - Contabiliza C.M.V.           ?  Sim Nao           ³
	//³ mv_par05 - Data Inicial                                      ³
	//³ mv_par06 - Data Final                                        ³
	//³ mv_par07 - Da Filial                                         ³
	//³ mv_par08 - At‚ a Filial                                      ³
	//³ mv_par09 - Contabiliza Notas de Credito ? Sim Nao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	// Inicializa as variaveis staticas da contabilização
	ClearCx105()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da inteface de processamento                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o log de processamento                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogIni(aButtons,"CTBANFS")

	If Empty(aPergunte)
		Pergunte(cPerg,.F.)
		If !IsBlind()
			aadd(aSays,STR0003) //"   Este programa tem como objetivo gerar automaticamente os"
			aadd(aSays,STR0004) //"lan‡amentos cont beis dos movimentos de saida."
			aadd(aSays,STR0005) //"   ATEN€AO: A visualiza‡„o do lan‡amentos por Nota Fiscal   "
			aadd(aSays,STR0006) //"ter  uma grande interferˆncia manual.                       "
			
			aadd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
			aadd(aButtons, { 1,.T.,{|| nOpcA:= 1, FechaBatch() }} )
			aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )
		
			FormBatch( cCadastro, aSays, aButtons )
		Else
			nOpca:= 1
		EndIf
	Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializacao do processamento automatico                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ConOut("-",80)
		ConOut(STR0002+" - "+STR0007,80) //"Lan‡amentos Contabeis Off-Line"###"Documento de Saida"
		ConOut("")
		ConOut(STR0001) //"Parametros"
		ConOut("")	
		nOpcA := 1
		Pergunte(cPerg,.F.)
		dbSelectArea("SX1")
		dbSetOrder(1)
		MsSeek( Padr( cPerg, Len( X1_GRUPO ) , ' ' ) )
		While SX1->(!Eof()) .And. SX1->X1_GRUPO == Padr( cPerg, Len( X1_GRUPO ) , ' ' )
			nX++		
			If nX <= Len(aPergunte)
				cMvPar  := "M->MV_PAR"+StrZero(nX,2)
				&cMvPar := aPergunte[nX]
			
				Do Case
					Case SX1->X1_TIPO=="N"
						cString := AllTrim(Str(aPergunte[nX],SX1->X1_TAMANHO,SX1->X1_DECIMAL))
					Case SX1->X1_TIPO=="D"
						cString := Dtoc(aPergunte[nX])
					Case SX1->X1_TIPO=="C"
						cString := 	aPergunte[nX]
					OtherWise
						cString := "NULL"
				EndCase
			Else
				cString := "NULL"
			EndIf
			ConOut(X1Pergunt()+": "+cString)
			SX1->( dbSkip() )
		EndDo
		ConOut("")
		ConOut("-",80)
	EndIf

	//³Validação para multthread.
	nNumProc:= IIF(nNumProc < 1 , 1, nNumProc) 

	If nNumProc > 1 .And. nOpcA == 1
		If CtbValMult(.T.,MV_PAR02 == 1,MV_PAR01 == 1,MV_PAR03 ) 
			nOpcA := 1
		Else
			nOpcA := 0
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	nOpcA == 1
		If CanProcItvl(mv_par05, mv_par06,mv_par07,mv_par08,"CTBNFS")
			Do Case
				Case IsBlind() .And. !lAuto
					BatchProcess( 	cCadastro, 	STR0003 + Chr(13) + Chr(10) +;
					STR0004 + Chr(13) + Chr(10) +;
					STR0005 + Chr(13) + Chr(10) +;
					STR0006, "CTBNFS",;
					{ || 	MaCtbNfs(MV_PAR01==1,MV_PAR02==1,MV_PAR03,;
					MV_PAR04==1,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08,If(cPaisLoc=="BRA",.F.,MV_PAR09==1),;
					Nil,.F.) }, { || .F. })
				Case nNumProc > 1 .And. !lAuto .And. CtbValMult(.F.,MV_PAR02 == 1, MV_PAR01 == 1, MV_PAR03 )
					MsgRun( "Contabilizando...",, {|| CtbNFSMult(MV_PAR04==1,mv_par05,mv_par06,mv_par07,MV_PAR08,If(cPaisLoc<>"BRA",MV_PAR09==1,.F.),nNumProc,MV_PAR03) } ) //"Contabilizando..."
				Case !lAuto
					oRegua := MsNewProcess():New({|lEnd| MaCtbNfs(MV_PAR01==1,;
					MV_PAR02==1,;
					MV_PAR03,;
					MV_PAR04==1,;
					MV_PAR05,;
					MV_PAR06,;
					MV_PAR07,;
					MV_PAR08,;
					If(cPaisLoc=="BRA",.F.,MV_PAR09==1),;
					oRegua,;
					@lEnd) },STR0002,"",.T.)//"Lan‡amentos Contabeis Off-Line"
					oRegua:Activate()
				OtherWise                                                                                   
					ConOut("Starting: "+Time())
					MaCtbNfs(MV_PAR01==1,;
					MV_PAR02==1,;
					MV_PAR03,;
					MV_PAR04==1,;
					MV_PAR05,;
					MV_PAR06,;
					MV_PAR07,;
					MV_PAR08,;
					If(cPaisLoc=="BRA",.F.,MV_PAR09==1),;
					Nil,;
					.F.)
					ConOut("Finished: "+Time())
			EndCase
		EndIf 
		FreeProcItvl("CTBNFS")
	EndIf

	// Inicializa as variaveis staticas da contabilização
	ClearCx105()
EndIf

Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaCtbNfs  ³Autor  ³ Eduardo Riera         ³ Data ³20.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de contabilizacao dos documentos de saida off-line    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Mostra Lancamento Contabil                            ³±±
±±³          ³ExpL2: Aglutina lancamentos contabeis                        ³±±
±±³          ³ExpN3: Contabilizar por:                                     ³±±
±±³          ³       [1] Documento de Saida                                ³±±
±±³          ³       [2] Periodo                                           ³±±
±±³          ³       [3] Dia                                               ³±±
±±³          ³ExpL4: Contabiliza Custo da Mercadoria Vendida               ³±±
±±³          ³ExpD5: Data de emissao inicial                               ³±±
±±³          ³ExpD6: Data de emissao final                                 ³±±
±±³          ³ExpC7: Codigo da filial inicial                              ³±±
±±³          ³ExpC8: Codigo da filial final                                ³±±
±±³          ³ExpO9: Objeto da interface                              (OPC)³±±
±±³          ³ExpLA: Flag de cancelamento da rotina                        ³±±
±±³          ³PARAMETROS PARA PROCESSAMENTO MULTITHREAD                    ³±±
±±³          ³ExpL10: Flag para processamento de Pedido                     ³±±
±±³          ³ExpL11: Flag para processamento de Nota Fiscal                ³±±
±±³          ³ExpL12: Pedidos a ser Processado                               ³±±
±±³          ³ExpL13: Nota Fiscal a ser processada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo contabilizar os documentos de  ³±±
±±³          ³saida com base nas regras dos lancamentos padronizados.      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB/FAT/OMS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MaCtbNfs(lDigita,lAglutina,nTpCtb,lCMV,dDataIni,dDataFim,cFilDe,cFilAte,lContNCP,oObj,lEnd,lContPed,lContNFS,cAliasSC5,cAliasSF2,lMulti,cCodIni,cCodFim,lDevolucao)

Local aArea      := GetArea()
Local aAreaSM0   := SM0->(GetArea())
Local aCT5       := {}
Local dSavBase   := dDataBase
Local dDataProc  := Ctod("")
Local lFirst     := .T.					// Indica se é o primeiro item da Venda. Usado p/ o L.P. 620 soh ser processado uma vez por Venda.
Local lFirst631	 := .T.					// Indica se é o primeiro item da Venda. Usado p/ o L.P. 631 soh ser processado uma vez por Venda.
Local lCtNfsDt   := ExistBlock("CTNFSDT")
Local lFilSf2    := Existblock("CTNFSFIL")
Local lLctPad10  := VerPadrao("610")	// Credito de Estoque / Debito de C.M.V.
Local lLctPad11  := VerPadrao("611")	// Devolucao do item de rateio
Local lLctPad13  := VerPadrao("613")	// Devolucao dos rateios do item da NF
Local lLctPad20  := VerPadrao("620")	// Debito de Cliente  / Credito de Venda
Local lLctPad31  := VerPadrao("631")	// Debito de Cliente  / Credito de Venda (Modulo Loja, a partir do SL4)
Local lLctPad78  := VerPadrao("678")	// Credito de Estoque / Debito de C.M.V. (CUSTO)
Local lLctPad12  := VerPadrao("612")    // Itens do Pedido de Venda
Local lLctPad21  := VerPadrao("621")    // cabeçalho do Pedido de Venda
Local dDtEmissao
Local lLctPad    := .F.
Local lDetProva  := .F.
Local lHeader    := .F.
Local lContinua  := .T.
Local lValido    := .F.
Local lInterface := oObj<>Nil
Local lOptimize  := .F.
Local lSkipSF2   := .F.
Local lLctoOk  := .T.
Local cLoteCtb   := ""
Local cArqCtb    := ""
Local cAliasSD2  := "SD2"
Local cAliasSB1  := "SB1"
Local cAliasSF4  := "SF4"
Local cAliasSA1  := "SA1"
Local cAliasSA2  := "SA2"
Local cAliasSC6  := "SC6"
Local cCliente   := ""
Local cLoja      := ""
Local cDocumento := ""
Local cSerie     := ""
Local c610       := Nil
Local c611       := Nil
Local c613       := Nil
Local c620       := Nil
Local c631       := Nil
Local c678       := Nil 
Local c612       := Nil
Local c621       := Nil
Local cQuery     := ""
Local cKeySF2    := "F2_FILIAL+DTOS(F2_EMISSAO)+F2_SERIE+F2_DOC+F2_CLIENTE+F2_LOJA"
Local cArqSF2    := ""
Local cKeySC5    := "C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM"
Local cArqSC5    := ""
Local nHdlPrv    := 0 
Local nTotalCtb  := 0
Local nOrdSF2    := 0 
Local nOrdSC5    := 0
Local nRecSF2    := 0 
Local nRecSC5    := 0
Local nY         := 0
Local nUltSD2	 := 1
Local nSD2Ori	 := 0
Local nSF2Ori	 := 0
Local nSC5Ori	 := 0
Local nSC6Ori	 := 0
Local lF2DTDIG	 := .T.
Local lHasLoja   := .F.
Local aFlagCTB   := {}
Local lUsaFlag 	 := GetNewPar("MV_CTBFLAG",.F.)
Local lMV_OPTNFS := GetNewPar("MV_OPTNFS",.F.)
Local cMV_CTBPAIS:= GetNewPar("MV_CTBPAIS","CHI,MEX")

//Variaveis para gravação do código de correlativo
Local aDiario	:= {}
Local lSeqCorr	:= UsaSeqCor("SF1/SF2/SC7")

Local aSM0 		:= AdmAbreSM0()
Local nContFil	:= 0
Local __cFilAnt := cFilAnt
Local cFilSX5	:= xFilial("SX5")
Local aOptimize  := {}
Local aStruSA1   := {}
Local aStruSA2   := {}
Local aStruSD2   := {}
Local aStruSB1   := {}
Local aStruSF2   := {}
Local aStruSF4   := {} 
Local aStruSC5   := {}
Local aStruSC6   := {}
Local cString    := ""
Local nX         := 0	
Local lD2CtaRec  := SD2->(ColumnPos("D2_CTAREC")) > 0 //Valida se o campo D2_CTAREC existe para gravar a Conta de Receita - EFD Contribuições
Local cCtaRec	 := "" //Conta de Receita do Item - EFD Contribuições
Local _lCtbIniLan	:= FindFunction("CtbIniLan")
Local lSemLPad	 := .F. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa parametros DEFAULT                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lDigita    := .F.
DEFAULT lAglutina  := .F.
DEFAULT nTpCtb     := 1
DEFAULT dDataIni   := FirstDay(dDataBase)
DEFAULT dDataFim   := LastDay(dDataBase)
DEFAULT lCMV       := .F.
DEFAULT cFilDe     := cFilAnt
DEFAULT cFilAte    := cFilAnt
DEFAULT lContNCP   := .T.
DEFAULT lEnd       := .F. 
DEFAULT lContPed   := .T.
DEFAULT lContNFS   := .T.
DEFAULT cAliasSC5  := "SC5"
DEFAULT cAliasSF2  := "SF2"
DEFAULT lMulti     := .F.
DEFAULT cCodIni    := ""
DEFAULT cCodFim    := ""
DEFAULT lDevolucao := .F.

If !CtbInUse()				/// SIGACON NÃO FAZ A MARCAÇÃO DOS FLAGS DE CONTABILIZACAO
	lUsaFlag := .F.			/// MANTEM A MARCACAO DOS FLAGS PELA ROTINA DE CONTABILIZAÇÃO
Endif

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return
Endif

//cria temporario de contabilizacao no banco de dados e otimiza validacao do lancamento
If _lCtbIniLan
	CtbIniLan()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compatibilizacao dos lancamentos contabeis                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCMV
	lLctPad78 := .F.
EndIf

lLctPad  := lLctPad13 .Or. lLctPad10 .Or. lLctPad20 .Or. lLctPad78 .Or. lLctPad31 .Or. lLctPad11.Or. lLctPad12 .Or. lLctPad21
lContinua := lLctPad

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da primeira regua por filiais                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInterface
	oObj:SetRegua1(Len(aSM0))
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o log de processamento                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogIni({},"CTBANFS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do processamento                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("INICIO")

//Verifica se é devolução e multithread
lDevolucao := lDevolucao .And. lMulti

For nContFil := 1 to Len(aSM0)
	
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf
	
	If !lContinua
		Exit
	EndIf 
	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	
	__nQuantas := CtbMoedas()   //colocado pois qdo cliente utiliza CTO-MOEDAS exclusivo e com qtd de moedas diferentes entre filiais
	                            //deve carregar novamente a variavel public carregada pela LIB
	
	aCT5     := {}
	c610     := NIL
	c611     := NIL
	c613     := NIL
	c620     := Nil
	c631     := Nil
	c678     := Nil 
	c612     := Nil
	c621     := Nil	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a regua de processamento de filiais                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lInterface
		oObj:IncRegua1(STR0008+": "+aSM0[nContFil][SM0_CODFIL]+"/"+aSM0[nContFil][SM0_NOMRED]) //"Contabilizando"
	EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa os pedidos de vendas                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	If !Empty( SC5->( FieldPos( "C5_DTLANC" ) ) )
			
		If (lLctPad12 .or. lLctPad21) .And. lContPed
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSelectArea("SC6")
			dbSetOrder(1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o parametro de otimizacao                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMV_OPTNFS
				lOptimize := .T.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Demonstra regua de processamento da query                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInterface
				If lOptimize
					oObj:IncRegua2(STR0010) //"Executando processo de otimizacao com query"
				Else 
					oObj:IncRegua2(STR0011) //"Executando query"
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do Array de otimizacao de Query                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aOptimize := {}					
			aadd(aOptimize,{}) //SELECT
			aadd(aOptimize,{}) //FROM
			aadd(aOptimize,{})	//WHERE

			If lOptimize
				cAliasSC5 := "CTBANFS"
				cAliasSC6 := "CTBANFS"
				cAliasSB1 := "CTBANFS"
				cAliasSA1 := "CTBANFS"
			
				aStruSC5  := SC5->(dbStruct())
				aStruSC6  := SC6->(dbStruct())
				aStruSB1  := SB1->(dbStruct())
				aStruSA1  := SA1->(dbStruct())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da instrucao select                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aStruSC5)
						aadd(aOptimize[OPT_SELECT],aStruSC5[nX])
				Next nX
				For nX := 1 To Len(aStruSC6)
						aadd(aOptimize[OPT_SELECT],aStruSC6[nX])
				Next nX
			
				For nX := 1 To Len(aStruSA1)
						If aStruSA1[nX][1]$"A1_FILIAL,A1_COD,A1_LOJA,A1_CONTA,A1_NOME,A1_NREDUZ"
							aadd(aOptimize[OPT_SELECT],aStruSA1[nX])
						EndIf
				Next nX
				
				For nX := 1 To Len(aStruSB1)
					If aStruSB1[nX][1]$"B1_FILIAL,B1_COD,B1_TIPO,B1_CONTA"
						aadd(aOptimize[OPT_SELECT],aStruSB1[nX])
					EndIf
				Next nX
				
			Else
				cAliasSC5 := "QRYSC5"
				cAliasSC6 := "QRYSC5"
				cAliasSB1 := "QRYSC5"                       
				cAliasSA1 := "QRYSC5"                              
				
				aStruSC5  := SC5->(dbStruct())
				aStruSC6  := SC6->(dbStruct())
				aStruSB1  := SB1->(dbStruct())
				aStruSA1  := SA1->(dbStruct())

				For nX := 1 To Len(aStruSC5)
						aadd(aOptimize[OPT_SELECT],aStruSC5[nX])
				Next nX
				For nX := 1 To Len(aStruSC6)
						aadd(aOptimize[OPT_SELECT],aStruSC6[nX])
				Next nX
				
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da instrucao from                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aOptimize[OPT_FROM],{RetSqlName("SC5"),"SC5"})
			aadd(aOptimize[OPT_FROM],{RetSqlName("SC6"),"SC6"})
			aadd(aOptimize[OPT_FROM],{RetSqlName("SB1"),"SB1"})
			aadd(aOptimize[OPT_FROM],{RetSqlName("SA1"),"SA1"})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da instrucao where                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aOptimize[OPT_WHERE] := "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
				aOptimize[OPT_WHERE] += "SA1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
				aOptimize[OPT_WHERE] += "SB1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
				aOptimize[OPT_WHERE] += "SC6.C6_FILIAL = SC5.C5_FILIAL AND "
				aOptimize[OPT_WHERE] += "SC6.C6_NUM = SC5.C5_NUM AND "
				aOptimize[OPT_WHERE] += "SC6.C6_CLI = SC5.C5_CLIENTE AND "
				aOptimize[OPT_WHERE] += "SC6.C6_LOJA = SC5.C5_LOJACLI AND "   
				aOptimize[OPT_WHERE] += "SC6.C6_PRODUTO = SB1.B1_COD AND "
				aOptimize[OPT_WHERE] += "SC6.C6_CLI = SA1.A1_COD AND "
				aOptimize[OPT_WHERE] += "SC6.C6_LOJA = SA1.A1_LOJA AND "
				aOptimize[OPT_WHERE] += "SC6.D_E_L_E_T_=' ' AND " 
				aOptimize[OPT_WHERE] += "SC5.C5_EMISSAO >= '"+Dtos(dDataIni)+"' AND "
				aOptimize[OPT_WHERE] += "SC5.C5_EMISSAO <= '"+Dtos(dDataFim)+"' AND "
				If lMulti .And. !Empty(cCodIni) .And. !Empty(cCodFim)
					aOptimize[OPT_WHERE] += "SC5.C5_NUM BETWEEN '" + cCodIni + "' AND '" + cCodFim + "' AND " 
				EndIf
				aOptimize[OPT_WHERE] += "SC5.C5_DTLANC = '"+Dtos(Ctod(""))+"'   

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da Query                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			cString := ""
			For nX := 1 To Len(aOptimize[OPT_SELECT])
				cString += ","+aOptimize[OPT_SELECT][nX][1]
			Next nX
			If lOptimize
				cQuery := "SELECT SC5.R_E_C_N_O_ SC5RECNO"+cString
			Else
				cQuery := "SELECT SC5.R_E_C_N_O_ SC5RECNO,"
				cQuery += "SA1.R_E_C_N_O_ SA1RECNO,"
				cQuery += "SB1.R_E_C_N_O_ SB1RECNO"+cString
			EndIf
			cQuery += ",SC6.R_E_C_N_O_ SC6RECNO"
			cString := ""
			For nX := 1 To Len(aOptimize[OPT_FROM])
				cString += ","+aOptimize[OPT_FROM][nX][1]+" "+aOptimize[OPT_FROM][nX][2]
			Next nX
			cQuery += " FROM "+SubStr(cString,2)
			cQuery += " WHERE "+aOptimize[OPT_WHERE]
													
			cQuery += " ORDER BY SC5.C5_EMISSAO,SC5.C5_NUM" 

		
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC5,.T.,.T.)
		
			For nX := 1 To Len(aOptimize[OPT_SELECT])
				If aOptimize[OPT_SELECT][nX][2]<>"C"
					TcSetField(cAliasSC5,aOptimize[OPT_SELECT][nX][1],aOptimize[OPT_SELECT][nX][2],aOptimize[OPT_SELECT][nX][3],aOptimize[OPT_SELECT][nX][4])
				EndIf
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preparacao da contabilizacao por periodo                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLctPad .And. nTpCtb == 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o numero do lote contabil                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SX5")
				dbSetOrder(1)
				If MsSeek(cFilSX5+"09FAT")
					cLoteCtb := AllTrim(X5Descri())
				Else
					cLoteCtb := "FAT "
				EndIf		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa um execblock                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If At(UPPER("EXEC"),X5Descri()) > 0
					cLoteCtb := &(X5Descri())
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa o arquivo de contabilizacao                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				nHdlPrv:=HeadProva(cLoteCtb,"CTBANFS",Subs(cUsuario,7,6),@cArqCtb)
				IF nHdlPrv <= 0
					HELP(" ",1,"SEM_LANC")
					lContinua := .F.
				Else
					lHeader := .T.
				EndIf		
			EndIf			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da segunda regua por periodo                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInterface
				oObj:SetRegua2(dDataFim+1-dDataIni)
				dDataProc := dDataIni
			EndIf       
			
			dbSelectArea(cAliasSC5)
			
			While ( !Eof() .And. (cAliasSC5)->C5_FILIAL == xFilial("SC5") .And.;
				(cAliasSC5)->C5_EMISSAO <= dDataFim .And. lContinua)
				
				lValido   := .T.
				lDetProva := .F.
				lSkipSC5  := .T.
	          	dDtEmissao:= (cAliasSC5)->C5_EMISSAO  
	          	lFirst	  := .T.			                              
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicia a contabilizacao deste pedido de venda                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				If lValido
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no Cabecalho do pedido de venda                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lOptimize
						SC5->(MsGoto((cAliasSC5)->SC5RECNO))
					Else
						nRecSC5 := (cAliasSC5)->SC5RECNO
					EndIf													
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ajusta a data base com a data de contabilizacao              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Do Case
					Case nTpCtb == 1 .Or. nTpCtb == 3 
						dDataBase := (cAliasSC5)->C5_EMISSAO						
					Case nTpCtb == 2
						dDataBase := dDataFim
					EndCase
	
					If lUsaFlag
						aAdd(aFlagCTB,{"C5_DTLANC",dDataBase,"SC5",(cAliasSC5)->SC5RECNO,0,0,0})
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preparacao da contabilizacao por documento                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction
				    	If 	!lHeader
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica o numero do lote contabil                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SX5")
							dbSetOrder(1)
							If MsSeek(cFilSX5+"09FAT")
								cLoteCtb := AllTrim(X5Descri())
							Else
								cLoteCtb := "FAT "
							EndIf		
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Inicializa o arquivo de contabilizacao                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nHdlPrv:=HeadProva(cLoteCtb,"CTBANFS",Subs(cUsuario,7,6),@cArqCtb)
							IF nHdlPrv <= 0
								HELP(" ",1,"SEM_LANC")
								lContinua := .F.
							Else
								lHeader := .T.
							EndIf		
		           		EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona registros vinculados ao cabecalho do documento     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SA1")
							dbSetOrder(1)
							If !lOptimize
								SA1->(MsGoto((cAliasSA1)->SA1RECNO))
							EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Processa os itens do pedido de venda                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						
						cCliente   := (cAliasSC5)->C5_CLIENTE
						cLoja      := (cAliasSC5)->C5_LOJACLI
						cDocumento := (cAliasSC5)->C5_NUM
						
						dbSelectArea(cAliasSC6)
						While ( !Eof() .And. (cAliasSC6)->C6_FILIAL == xFilial("SC6") .And.;
							(cAliasSC6)->C6_NUM == cDocumento) 
							                             
		
							lValido := .T.
							
							nUltSC6 := (cAliasSC6)->SC6RECNO
							If !lOptimize
								SC6->(dbGoTo(nUltSC6))
							EndIf
									
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Preparacao da contabilizacao por item do documento           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
								If lValido						
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Posiciona registros vinculados ao item do documento          ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbSelectArea("SB1")
									dbSetOrder(1)
									If !lOptimize
										SB1->(MsGoto((cAliasSB1)->SB1RECNO))
									EndIf
		
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Executa os lancamentos contabeis ( 612 ) - Item pv           ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If lLctPad12  .And. lHeader
										//c612       := CtRelation("611",.F.,{{cAliasSC5,"SC5"},{cAliasSC6,"SC6"},{cAliasSC6,"CTBANFS"}})
										lDetProva := .T.
										nTotalCtb += DetProva(nHdlPrv,"612","CTBANFS",cLoteCtb,,,,,@c612,@aCT5,,@aFlagCTB)
									EndIf
									
									If lValido .and. lFirst 
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Executa os lancamentos contabeis ( 621 ) - Cabecalho PV      ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If lLctPad21 .And. lHeader
										    lFirst := .F.
											//c621       := CtRelation("621",.F.,{{cAliasSC5,"SC5"},{cAliasSC6,"SC6"},{cAliasSC6,"CTBANFS"}})
											lDetProva := .T.
											nTotalCtb += DetProva(nHdlPrv,"621","CTBANFS",cLoteCtb,,,,,@c621,@aCT5,,@aFlagCTB)																
										EndIf
									EndIf
							
							
								EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Ponto de entrada para tratar customizações nos itens do pedido³
							//³ de vendas(sc6) no momento da contabilização.                  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ExistBlock("CTBAPED")
								ExecBlock("CTBAPED",.F.,.F.,{ cCliente,cLoja,cDocumento })
							Endif	
	
							dbSelectArea(cAliasSC6)
							dbSkip()     
							
							lSkipSC5 := .F.
							
							If lInterface .And. lEnd
								oObj:IncRegua2(STR0012) //"Aguarde abortando execucao"
							EndIf
							
						EndDo          
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza a data de lancamento contabil para nao refaze-lo    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lDetProva .And. lHeader
							If lOptimize
							    SC5->(MsGoto(nRecSC5))
							    dbSelectArea(cAliasSC5)
				    		EndIf
							If !lUsaFlag      
						    	RecLock("SC5")
								SC5->C5_DTLANC := dDataBase
								MsUnlock()
							EndIf
			            EndIf
			    	End Transaction
					If nTpCtb == 1 .And. lHeader
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Fecha os lancamentos contabeis                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lHeader := .F.
						RodaProva(nHdlPrv,nTotalCtb)
						If nTotalCtb > 0 				
							nSC6Ori := SC6->(Recno())	/// GUARDA O POSICIONAMENTO DO SC6
							SC6->(dbGoTo(nUltSC6))		// POSICIONA NO ÚLTIMO SC6 DO PEDIDO.
							nSC5Ori := SC5->(Recno())	/// GUARDA O POSICIONAMENTO DO SC5
							nTotalCtb := 0
							lLctoOk := cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
							aDiario := {}
							SC5->(dbGoTo(nSC5Ori))		// VOLTA O POSICIONAMENTO DO SC5 ORIGINAL						
							If !lUsaFlag .And. !lLctoOk
					    		RecLock("SC5")
								SC5->C5_DTLANC := CtoD("")
								MsUnlock()
							EndIf
							SC6->(dbGoTo(nSC6Ori))		// VOLTA O POSICIONAMENTO DO SC6 ORIGINAL						
						EndIf
					EndIf
				EndIf
				If lSkipSC5
					dbSelectArea(cAliasSC5)
					dbSkip()
				Else
					dbSelectArea(cAliasSC5)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a regua de processamento por periodo                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If dDataProc<>(cAliasSC5)->C5_EMISSAO
					While dDataProc<=(cAliasSC5)->C5_EMISSAO
						If lInterface
							oObj:IncRegua2(STR0008+": "+Dtoc((cAliasSC5)->C5_EMISSAO)) //"Documento de"
						Endif
						dDataProc++
					EndDo
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a contabilizacao foi abortada                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lEnd
					Exit
				EndIf
				If nTpCtb == 3 .And. (cAliasSC5)->C5_EMISSAO <> dDtEmissao
							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader   := .F.
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0
						nTotalCtb := 0			
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
					EndIf
				EndIf			
			EndDo
	
			If nTpCtb == 2 .And. lHeader
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha os lancamentos contabeis                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lHeader   := .F.
				RodaProva(nHdlPrv,nTotalCtb)
				If nTotalCtb > 0
					nTotalCtb := 0			
					cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
				EndIf
			EndIf			
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorna a situacao inicial                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSC5)
			dbCloseArea()
		Endif	
	Endif
    If lContNFS
		For nY := 1 To 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa os documentos de saida da filial corrente           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SL1")
			dbSetOrder(2)
			lHasLoja :=  MsSeek( xFilial("SL1"))
			
			dbSelectArea("SF2")
			dbSetOrder(1)
			dbSelectArea("SD2")
			dbSetOrder(3)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o parametro de otimizacao                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lMV_OPTNFS
				lOptimize := .T.
			EndIf

			//Se for devolução evita o primeiro loop
			If lDevolucao .And. nY == 1
				Loop
			EndIf

			//Se for devolução não deve sair do loop
			If lMulti .And. nY == 2 .And. !lDevolucao
				Exit
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Demonstra regua de processamento da query                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInterface
				If lOptimize
					oObj:IncRegua2(STR0010) //"Executando processo de otimizacao com query"
				Else 
					oObj:IncRegua2(STR0011) //"Executando query"
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do Array de otimizacao de Query                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aOptimize := {}					
			aadd(aOptimize,{}) //SELECT
			aadd(aOptimize,{}) //FROM
			aadd(aOptimize,{})	//WHERE

			If lOptimize
				cAliasSF2 := "CTBANFS"
				cAliasSD2 := "CTBANFS"
				cAliasSB1 := "CTBANFS"
				cAliasSF4 := "CTBANFS"
				cAliasSA1 := "CTBANFS"
				cAliasSA2 := "CTBANFS"
			
				aStruSF2  := SF2->(dbStruct())
				aStruSD2  := SD2->(dbStruct())
				aStruSB1  := SB1->(dbStruct())
				aStruSF4  := SF4->(dbStruct())
				aStruSA1  := SA1->(dbStruct())
				aStruSA2  := SA2->(dbStruct())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Montagem da instrucao select                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aStruSF2)
					If !"F2_BASE"$aStruSF2[nX][1] .and. !"F2_BASI"$aStruSF2[nX][1] .and. ((!"F2_ESPECI"$aStruSF2[nX][1]).Or.Alltrim(aStruSF2[nX][1])=="F2_ESPECIE") .and.;
						!"F2_VOLUME"$aStruSF2[nX][1] .and. !"F2_VEND"$aStruSF2[nX][1] .And. !"F2_DTBASE"$aStruSF2[nX][1] .and.;
						!aStruSF2[nX][1]$"F2_REGIAO/F2_DTREAJ/F2_REAJUST/F2_FATORB0/F2_FATORB1/F2_VARIAC/F2_PLIQUI/F2_PBRUTO/F2_TRANSP/F2_TPREDES/F2_REDESP/F2_PLACA"
						aadd(aOptimize[OPT_SELECT],aStruSF2[nX])
					EndIf
				Next nX
				For nX := 1 To Len(aStruSD2)
					If 	!"D2_BASE"$aStruSD2[nX][1] .And. !"D2_BASI"$aStruSD2[nX][1] .And. !"D2_ALIQ"$aStruSD2[nX][1] .And. ;
							!"D2_ALQIMP"$aStruSD2[nX][1]	 .And. 	!"D2_COMIS"$aStruSD2[nX][1] .And. !"D2_CP"$aStruSD2[nX][1]
						aadd(aOptimize[OPT_SELECT],aStruSD2[nX])
					EndIf
				Next nX
			
				If nY == 1
					For nX := 1 To Len(aStruSA1)
						If aStruSA1[nX][1]$"A1_FILIAL,A1_COD,A1_LOJA,A1_CONTA,A1_NOME,A1_NREDUZ"
							aadd(aOptimize[OPT_SELECT],aStruSA1[nX])
						EndIf
					Next nX
				Else
					For nX := 1 To Len(aStruSA2)
						If aStruSA2[nX][1]$"A2_FILIAL,A2_COD,A2_LOJA,A2_CONTA,A2_NOME,A2_NREDUZ"
							aadd(aOptimize[OPT_SELECT],aStruSA2[nX])
						EndIf
					Next nX
				EndIf
				For nX := 1 To Len(aStruSB1)
					If aStruSB1[nX][1]$"B1_FILIAL,B1_COD,B1_TIPO,B1_CONTA"
						aadd(aOptimize[OPT_SELECT],aStruSB1[nX])
					EndIf
				Next nX
				For nX := 1 To Len(aStruSF4)
					If aStruSF4[nX][1]$"F4_FILIAL,F4_CODIGO,F4_CF"
						aadd(aOptimize[OPT_SELECT],aStruSF4[nX])
					EndIf
					Next nX
			Else
				cAliasSF2 := "QRYSD2"
				cAliasSD2 := "QRYSD2"
				cAliasSB1 := "QRYSD2"
				cAliasSF4 := "QRYSD2"
				cAliasSA1 := "QRYSD2"
				cAliasSA2 := "QRYSD2"
				
				/// CAMPOS CHAVE DA TABELA SF2
				aadd(aOptimize[OPT_SELECT], {"F2_FILIAL"	,"C"} )
				aadd(aOptimize[OPT_SELECT], {"F2_EMISSAO"	,"D",8,0} )
				aadd(aOptimize[OPT_SELECT], {"F2_DTLANC"	,"D",8,0} )
				If lF2DTDIG
					aadd(aOptimize[OPT_SELECT], {"F2_DTDIGIT","D",8,0} )
				EndIf
				aadd(aOptimize[OPT_SELECT], {"F2_TIPO"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"F2_CLIENTE"	,"C"} )
				aadd(aOptimize[OPT_SELECT], {"F2_LOJA"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"F2_DOC"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"F2_SERIE"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"F2_ESPECIE"	,"C"} )
				aadd(aOptimize[OPT_SELECT], {"F2_FORMUL"	,"C"} )

				aadd(aOptimize[OPT_SELECT], {"D2_FILIAL"	,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_DOC"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_SERIE"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_CLIENTE"	,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_LOJA"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_COD"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_ITEM"		,"C"} )		/// ITEM FAZ PARTE CHAVE RASTREAMENTO (MOD. HELP).
				aadd(aOptimize[OPT_SELECT], {"D2_ORIGLAN"	,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_TES"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_ITEMORI"	,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_NFORI"		,"C"} )
				aadd(aOptimize[OPT_SELECT], {"D2_SERIORI"	,"C"} )
											
				//aadd(aOptimize[OPT_SELECT],{{"D2_"},{"D2_"},{"D2_"},{"D2_"},{"D2_"}})							
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da instrucao from                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aOptimize[OPT_FROM],{RetSqlName("SF2"),"SF2"})
			aadd(aOptimize[OPT_FROM],{RetSqlName("SD2"),"SD2"})
			aadd(aOptimize[OPT_FROM],{RetSqlName("SB1"),"SB1"})
			aadd(aOptimize[OPT_FROM],{RetSqlName("SF4"),"SF4"})
			If nY == 1
				aadd(aOptimize[OPT_FROM],{RetSqlName("SA1"),"SA1"})
			Else
				aadd(aOptimize[OPT_FROM],{RetSqlName("SA2"),"SA2"})
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da instrucao where                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aOptimize[OPT_WHERE] := " SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
			aOptimize[OPT_WHERE] += "SF2.F2_EMISSAO >= '"+Dtos(dDataIni)+"' AND "
			aOptimize[OPT_WHERE] += "SF2.F2_EMISSAO <= '"+Dtos(dDataFim)+"' AND "
			If lMulti .And. !Empty(cCodIni) .And. !Empty(cCodFim)
				aOptimize[OPT_WHERE] += "SF2.F2_DOC BETWEEN '" + cCodIni + "' AND '" + cCodFim + "' AND " 
			EndIf						
			aOptimize[OPT_WHERE] += "SF2.F2_DTLANC = '"+Dtos(Ctod(""))+"' AND "
			aOptimize[OPT_WHERE] += "SF2.D_E_L_E_T_=' ' AND "
			aOptimize[OPT_WHERE] += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
			aOptimize[OPT_WHERE] += "SD2.D2_DOC = SF2.F2_DOC AND "
			aOptimize[OPT_WHERE] += "SD2.D2_SERIE = SF2.F2_SERIE AND "
			aOptimize[OPT_WHERE] += "SD2.D2_CLIENTE = SF2.F2_CLIENTE AND "
			aOptimize[OPT_WHERE] += "SD2.D2_LOJA = SF2.F2_LOJA AND "
			aOptimize[OPT_WHERE] += "SD2.D_E_L_E_T_=' ' AND "
			aOptimize[OPT_WHERE] += "SD2.D2_ORIGLAN<>'LF' AND "
			aOptimize[OPT_WHERE] += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
			aOptimize[OPT_WHERE] += "SB1.B1_COD=SD2.D2_COD AND "
			aOptimize[OPT_WHERE] += "SB1.D_E_L_E_T_=' ' AND "
			aOptimize[OPT_WHERE] += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
			aOptimize[OPT_WHERE] += "SF4.F4_CODIGO=SD2.D2_TES AND "	
			aOptimize[OPT_WHERE] += "SF4.D_E_L_E_T_=' ' AND "
			If nY == 1
				aOptimize[OPT_WHERE] += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
				aOptimize[OPT_WHERE] += "SA1.A1_COD = SF2.F2_CLIENTE AND "
				aOptimize[OPT_WHERE] += "SA1.A1_LOJA = SF2.F2_LOJA AND "
				aOptimize[OPT_WHERE] += "SA1.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "SF2.F2_TIPO NOT IN('D','B') "
			Else
				aOptimize[OPT_WHERE] += "SA2.A2_FILIAL='"+xFilial("SA2")+"' AND "
				aOptimize[OPT_WHERE] += "SA2.A2_COD = SF2.F2_CLIENTE AND "
				aOptimize[OPT_WHERE] += "SA2.A2_LOJA = SF2.F2_LOJA AND "
				aOptimize[OPT_WHERE] += "SA2.D_E_L_E_T_=' ' AND "
				aOptimize[OPT_WHERE] += "SF2.F2_TIPO IN('D','B') "
			EndIf					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Execucao do execblock para alteracao da query de otimizacao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("CTBNFS")
				aOptimize := ExecBlock("CTBNFS",.F.,.F.,aOptimize)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da Query                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
			cString := ""
			For nX := 1 To Len(aOptimize[OPT_SELECT])
				cString += ","+aOptimize[OPT_SELECT][nX][1]
			Next nX
			If lOptimize
				cQuery := "SELECT SF2.R_E_C_N_O_ SF2RECNO"+cString
			Else
				cQuery := "SELECT SF2.R_E_C_N_O_ SF2RECNO,"
				If nY == 1
					cQuery += "SA1.R_E_C_N_O_ SA1RECNO,"
				Else
					cQuery += "SA2.R_E_C_N_O_ SA2RECNO,"
				EndIf
				cQuery += "SF4.R_E_C_N_O_ SF4RECNO,"
				cQuery += "SB1.R_E_C_N_O_ SB1RECNO"+cString
			EndIf
			cQuery += ",SD2.R_E_C_N_O_ SD2RECNO"
			cString := ""
			For nX := 1 To Len(aOptimize[OPT_FROM])
				cString += ","+aOptimize[OPT_FROM][nX][1]+" "+aOptimize[OPT_FROM][nX][2]
			Next nX
			cQuery += " FROM "+SubStr(cString,2)
			cQuery += " WHERE "+aOptimize[OPT_WHERE]
													
			If nTpCtb == 3 //-- Contabiliza por Dia
				cQuery += " ORDER BY " + SqlOrder("F2_FILIAL+F2_EMISSAO+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA")+","+SqlOrder(SD2->(IndexKey()))
			Else 
				cQuery += " ORDER BY " + SqlOrder(SF2->(IndexKey()))+ "," +SqlOrder(SD2->(IndexKey()))				
			EndIf	
		
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)
		
			For nX := 1 To Len(aOptimize[OPT_SELECT])
				If aOptimize[OPT_SELECT][nX][2]<>"C"
					TcSetField(cAliasSF2,aOptimize[OPT_SELECT][nX][1],aOptimize[OPT_SELECT][nX][2],aOptimize[OPT_SELECT][nX][3],aOptimize[OPT_SELECT][nX][4])
				EndIf
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preparacao da contabilizacao por periodo                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLctPad .And. nTpCtb == 2
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o numero do lote contabil                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SX5")
				dbSetOrder(1)
				If MsSeek(cFilSX5+"09FAT")
					cLoteCtb := AllTrim(X5Descri())
				Else
					cLoteCtb := "FAT "
				EndIf		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa um execblock                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If At(UPPER("EXEC"),X5Descri()) > 0
					cLoteCtb := &(X5Descri())
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa o arquivo de contabilizacao                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				nHdlPrv:=HeadProva(cLoteCtb,"CTBANFS",Subs(cUsuario,7,6),@cArqCtb)
				IF nHdlPrv <= 0
					HELP(" ",1,"SEM_LANC")
					lContinua := .F.
				Else
					lHeader := .T.
				EndIf		
			EndIf			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da segunda regua por periodo                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lInterface
				oObj:SetRegua2(dDataFim+1-dDataIni)
				dDataProc := dDataIni
			EndIf
			dbSelectArea(cAliasSF2)
			While ( !Eof() .And. (cAliasSF2)->F2_FILIAL == xFilial("SF2") .And.;
				(cAliasSF2)->F2_EMISSAO <= dDataFim .And. lContinua)
				
				lValido   := .T.
				lDetProva := .F.
				lSkipSF2  := .T.
	          	dDtEmissao:= (cAliasSF2)->F2_EMISSAO 			                              
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a nota nao foi contabilizada                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty((cAliasSF2)->F2_DTLANC)
				
					If cPaisloc <> "BRA" .And. nY == 2 .And. (cAliasSF2)->F2_TIPO == "D"
						lValido := .F.
					EndIf	
						
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa a filtragem da customizacao                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFilSf2
						If !(Execblock("CTNFSFIL",.F.,.F.,{cAliasSF2}))
							lValido := .F.
						EndIf
					EndIf
				Else
					lValido := .F.
				EndIf                                                             
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Melhoria pedida no Bops 67407, para contabilizar a NCC no modulo de faturamento e ³
				//³ as NCP no modulo de compras.                                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc $ cMV_CTBPAIS .And. ((Alltrim((cAliasSF2)->F2_TIPO) == "D" .And. Alltrim(cModulo) == "FAT") .Or. (Alltrim((cAliasSF2)->F2_TIPO) <> "D" .And. Alltrim(cModulo) == "COM"))
					lValido := .F.
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicia a contabilizacao deste documento de saida             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
				If lValido
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona no Cabecalho do documento de saida                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lOptimize
						SF2->(MsGoto((cAliasSF2)->SF2RECNO))
					Else
						nRecSF2 := (cAliasSF2)->SF2RECNO
					EndIf													
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ajusta a data base com a data de contabilizacao              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Do Case
					Case nTpCtb == 1 .Or. nTpCtb == 3 
						dDataBase := (cAliasSF2)->F2_EMISSAO						
						If lCtNfsDt
							dDataBase := Execblock("CTNFSDT",.F.,.F.)
						EndIf
					Case nTpCtb == 2
						dDataBase := dDataFim
					EndCase
	
					If lUsaFlag
						aAdd(aFlagCTB,{"F2_DTLANC",dDataBase,"SF2",(cAliasSF2)->SF2RECNO,0,0,0})
					EndIf
					If lSeqCorr
						If lOptimize
							cDiario := (cAliasSF2)->F2_DIACTB
						Else
							cDiario := SF2->F2_DIACTB
						EndIf
						aAdd( aDiario , {"SF2",(cAliasSF2)->SF2RECNO,cDiario,"F2_NODIA","F2_DIACTB"} )
					EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Preparacao da contabilizacao por documento                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Begin Transaction
				    	If 	!lHeader
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica o numero do lote contabil                           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							dbSelectArea("SX5")
							dbSetOrder(1)
							If MsSeek(cFilSX5+"09FAT")
								cLoteCtb := AllTrim(X5Descri())
							Else
								cLoteCtb := "FAT "
							EndIf		
	
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ No chile contabiliza NCP separada de NF, por isto deve ser   ³
							//³ contabilizado com LOTE DIFERENCIADO.                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				     		If cPaisLoc $ cMV_CTBPAIS .And. (AllTrim(cModulo) == "COM") 
								If (cAliasSF2)->F2_TIPO $ "D" 
									If MsSeek(xFilial()+"09COM")
										cLoteCtb := AllTrim(X5Descri())
									Else
										cLoteCtb := "COM "
									EndIf 
								EndIf
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executa um execblock                                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If At("EXEC",Upper(X5Descri())) > 0
								cLoteCtb := &(X5Descri())
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Inicializa o arquivo de contabilizacao                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nHdlPrv:=HeadProva(cLoteCtb,"CTBANFS",Subs(cUsuario,7,6),@cArqCtb)
							IF nHdlPrv <= 0
								HELP(" ",1,"SEM_LANC")
								lContinua := .F.
							Else
								lHeader := .T.
							EndIf		
		           		EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Posiciona registros vinculados ao cabecalho do documento     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cAliasSF2)->F2_TIPO $ "DB"
							dbSelectArea("SA2")
							dbSetOrder(1)
							If !lOptimize
								SA2->(MsGoto((cAliasSA2)->SA2RECNO))
							EndIf
						Else
							dbSelectArea("SA1")
							dbSetOrder(1)
							If !lOptimize
								SA1->(MsGoto((cAliasSA1)->SA1RECNO))
							EndIf
						EndIf
						dbSelectArea(cAliasSF2)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Processa os itens do documento de saida                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea(cAliasSF2)
						
						cCliente   := (cAliasSF2)->F2_CLIENTE
						cLoja      := (cAliasSF2)->F2_LOJA
						cDocumento := (cAliasSF2)->F2_DOC
						cSerie     := (cAliasSF2)->F2_SERIE
						lFirst     := .T.	// boleano p/ LP 620 ser processado soh uma vez por Venda e nao a cada item.
						lFirst631  := .T.	// boleano p/ LP 631 ser processado soh uma vez por Venda e nao a cada item.
						
						While ( (cAliasSD2)->(!Eof()) .And. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .And.;
							(cAliasSD2)->D2_DOC == cDocumento .And.;
							(cAliasSD2)->D2_SERIE == cSerie .And.;
							(cAliasSD2)->D2_CLIENTE == cCliente .And.;
							(cAliasSD2)->D2_LOJA == cLoja )
		
							lValido := .T.
							
							nUltSD2 := (cAliasSD2)->SD2RECNO
							If !lOptimize
								SD2->(dbGoTo(nUltSD2))
							EndIf
							If (cAliasSD2)->D2_ORIGLAN <> "LF"
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciona registros vinculados ao item do documento          ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lHasLoja .AND. lFirst631
									
									lFirst631 := .F.	// boleano p/ LP 631 ser processado soh uma vez por Venda e nao a cada item.
								
									dbSelectArea("SL1")
									dbSetOrder(2)
									MsSeek( xFilial("SL1")+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC)
									
									dbSelectArea("SL2")
									dbSetOrder(3)
									MsSeek( xFilial("SL2")+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_COD)
						
									If cPaisLoc $ cMV_CTBPAIS
										If (cAliasSD2)->D2_ORIGLAN != "LO"
											lValido := .F.
										EndIf
									EndIf
									
									// Permite a contabilizacao pelo SL4 (Itens de Venda por Forma de Pagamento)
									If lLctPad31
										dbSelectArea("SL4")
										dbSetOrder(1)
										If dbSeek(xFilial()+SL1->L1_NUM)
											While !Eof() .and. xFilial() == SL4->L4_FILIAL .and. SL4->L4_NUM == SL1->L1_NUM
												c631       := CtRelation("631",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
												nTotalCtb += DetProva(nHdlPrv,"631","CTBANFS",cLoteCtb,,,,,@c631,@aCT5,,@aFlagCTB)
												dbSkip()
												Loop
											End
										EndIf
							 		EndIf
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Preparacao da contabilizacao por item do documento           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
								If lValido						
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Posiciona registros vinculados ao item do documento          ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbSelectArea("SB1")
									dbSetOrder(1)
									If !lOptimize
										SB1->(MsGoto((cAliasSB1)->SB1RECNO))
									EndIf
		
									dbSelectArea("SF4")
									dbSetOrder(1)
									If !lOptimize
										SF4->(MsGoto((cAliasSF4)->SF4RECNO))
									EndIf
									
									cCtaRec := "" //Limpa a variavel devido processamento em laço
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Executa os lancamentos contabeis ( 610 ) - Item              ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If lLctPad10  .And. lHeader
										c610       := CtRelation("610",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
										lDetProva := .T.
										nTotalCtb += DetProva(nHdlPrv,"610","CTBANFS",cLoteCtb,,,,,@c610,@aCT5,,@aFlagCTB,,,,,,,@cCtaRec)
									 	
										//Tratamento para contabilizar quando só utiliza o LP 610 e MV_CTBFLAG =.T. 
										If !lLctPad11 .AND. !lLctPad12 .AND. !lLctPad13 .AND. !lLctPad20 .AND. !lLctPad21 .AND. !lLctPad31 .AND. !lLctPad78
											lSemLPad := .T.
										EndIf
										//-----------------------------------------------------------------------------------------
										// Adequacao para Gravar a Conta de Receita do Item da Nota, para uso no EFD-Contribuições
										//-----------------------------------------------------------------------------------------													
										If lD2CtaRec .And. !Empty(cCtaRec)
											Iif (lSemLPad, Aadd(aFlagCTB,{"D2_CTAREC",cCtaRec,"SD2",nUltSD2,0,0,1}), Aadd(aFlagCTB,{"D2_CTAREC",cCtaRec,"SD2",nUltSD2,0,0,0}))

											SFT->(DbSetOrder(1))
											If SFT->(DbSeek(xFilial("SFT")+"S"+(cAliasSD2)->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+Padr(D2_ITEM,TAMSX3("FT_ITEM")[1])+D2_COD))) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO 
												Iif (lSemLPad, Aadd(aFlagCTB,{"FT_CONTA",cCtaRec,"SFT",SFT->(Recno()),0,0,1}), Aadd(aFlagCTB,{"FT_CONTA",cCtaRec,"SFT",SFT->(Recno()),0,0,0}))
											EndIf						
										EndIf
										If lLctPad11  .And. lHeader .And. !Empty((cAliasSD2)->D2_ITEMORI)									
											dbSelectArea("SF1")
											dbSetOrder(1)
											MsSeek(xFilial("SF1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
											
											dbSelectArea("SD1")
											dbSetOrder(1)
											MsSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
												
											dbSelectArea("SDE")
											dbSetOrder(1)
											MsSeek(xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
											While ( !Eof() .And. ;
												xFilial("SDE") == SDE->DE_FILIAL .And.;
												SD1->D1_DOC == SDE->DE_DOC .And.;
												SD1->D1_SERIE == SDE->DE_SERIE .And.;
												SD1->D1_FORNECE == SDE->DE_FORNECE .And.;
												SD1->D1_LOJA == SDE->DE_LOJA .And.;
												SD1->D1_ITEM == SDE->DE_ITEMNF)
	
												nTotalCtb += DetProva(nHdlPrv,"611","CTBANFS",cLoteCtb,,,,,@c611,@aCT5,,@aFlagCTB)
												
												dbSelectArea("SDE")
												dbSkip()
											EndDo
										EndIf
									EndIf
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Executa os lancamentos contabeis ( 613 ) - rateio Item       ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If lLctPad13  .And. lHeader
										c613       := CtRelation("613",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
										lDetProva := .T.
										dbSelectArea("AGH")
										AGH->(dbSetOrder(2)) //AGH->AGH_FILIAL + AGH->AGH_NUM + AGH->AGH_ITEMPD + AGH->AGH_ITEM
										If dbSeek(xFilial("AGH")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_ITEM ) 
											While (!AGH->(EOF()) .And. ;
												xFilial("AGH") == AGH->AGH_FILIAL .And.;
												(cAliasSD2)->D2_DOC == AGH->AGH_NUM .And.;
												(cAliasSD2)->D2_SERIE == AGH->AGH_SERIE .And.;
												(cAliasSD2)->D2_ITEM == AGH->AGH_ITEMPD)
																	
												nTotalCtb += DetProva(nHdlPrv,"613","MATA460",cLoteCtb,,,,,@c613,@aCT5,,@aFlagCTB)
												AGH->(dbSkip())
											EndDo 	
										EndIf
									EndIf	
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Executa os lancamentos contabeis ( 678 ) - C.M.V.            ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If lLctPad78 .And. lHeader
										c678       := CtRelation("678",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
										lDetProva := .T.
										nTotalCtb += DetProva(nHdlPrv,"678","CNA200C",cLoteCtb,,,,,@c678,@aCT5,,@aFlagCTB)
									EndIf
								EndIf
							EndIf						
							If lValido .And. lFirst
								lFirst := .F.	// boleano p/ LP 620 ser processado soh uma vez por Venda e nao a cada item.
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Executa os lancamentos contabeis ( 620 ) - Cabecalho         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lLctPad20 .And. lHeader
									c620       := CtRelation("620",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
									lDetProva := .T.
									nTotalCtb += DetProva(nHdlPrv,"620","CTBANFS",cLoteCtb,,,,,@c620,@aCT5,,@aFlagCTB)																
								EndIf
							EndIf										
							(cAliasSD2)->(dbSkip())
							lSkipSF2 := .F.
							
							If lInterface .And. lEnd
								oObj:IncRegua2(STR0012) //"Aguarde abortando execucao"
							EndIf
							
						EndDo
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza a data de lancamento contabil para nao refaze-lo    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lDetProva .And. lHeader
							If lOptimize
								SF2->(MsGoto(nRecSF2))
							EndIf
							If !lUsaFlag
								RecLock("SF2")
								SF2->F2_DTLANC := dDataBase
								MsUnlock()
							EndIf
			            EndIf
			    	End Transaction
					If nTpCtb == 1 .And. lHeader
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Fecha os lancamentos contabeis                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lHeader := .F.
						RodaProva(nHdlPrv,nTotalCtb)
						If nTotalCtb > 0 				
							nSD2Ori := SD2->(Recno())	/// GUARDA O POSICIONAMENTO DO SD2
							SD2->(dbGoTo(nUltSD2))		// POSICIONA NO ÚLTIMO SD2 DA NF.
							nSF2Ori := SF2->(Recno())	/// GUARDA O POSICIONAMENTO DO SF2
							nTotalCtb := 0
							lLctoOk := cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
							aDiario := {}
							SF2->(dbGoTo(nSF2Ori))		// VOLTA O POSICIONAMENTO DO SF2 ORIGINAL						
							If !lUsaFlag .And. !lLctoOk
								RecLock("SF2")
								SF2->F2_DTLANC := CtoD("")
								MsUnlock()
							EndIf
							SD2->(dbGoTo(nSD2Ori))		// VOLTA O POSICIONAMENTO DO SD2 ORIGINAL						
						EndIf
					EndIf
				EndIf
				If lSkipSF2 
					dbSelectArea(cAliasSF2)
					dbSkip()
				Else
					dbSelectArea(cAliasSF2)
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza a regua de processamento por periodo                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If dDataProc<>(cAliasSF2)->F2_EMISSAO
					While dDataProc<=(cAliasSF2)->F2_EMISSAO
						If lInterface
							oObj:IncRegua2(STR0008+": "+Dtoc((cAliasSF2)->F2_EMISSAO)) //"Documento de"
						Endif
						dDataProc++
					EndDo
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a contabilizacao foi abortada                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lEnd
					Exit
				EndIf
				If nTpCtb == 3 .And. (cAliasSF2)->F2_EMISSAO <> dDtEmissao
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader   := .F.
					If nTotalCtb > 0
					RodaProva(nHdlPrv,nTotalCtb)
						nTotalCtb := 0			
						cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
					EndIf
				EndIf			
			EndDo
	
			If nTpCtb == 2 .And. lHeader
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha os lancamentos contabeis                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lHeader   := .F.
				RodaProva(nHdlPrv,nTotalCtb)
				If nTotalCtb > 0
					nTotalCtb := 0			
					cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
				EndIf
			EndIf			
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorna a situacao inicial                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea(cAliasSF2)
			dbCloseArea()
		Next nY
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o arquivo e compartilhado para encerrar a contab.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(xFilial("SF2"))
		Exit
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a contabilizacao foi abortada                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEnd
		Exit
	EndIf	
Next nContFil
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da Rotina                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)
cFilAnt := __cFilAnt
dDataBase := dSavBase


If cPaisLoc <> "BRA" .and. lF2DTDIG
 	 If cPaisLoc $ cMV_CTBPAIS .and. ! AllTrim(cModulo) $ "COM|EST"
	    lContNCP  := .F.
     Else
		If lContNCP
			CTBANCPS(lDigita,lAglutina,nTpCtb,lCMV,dDataIni,dDataFim,cFilDe,cFilAte,oObj,lEnd)
			RestArea(aArea)
			cFilAnt := __cFilAnt
			dDataBase := dSavBase
        EndIf
	EndIf
EndIf

If _lCtbIniLan
	CtbFinLan()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o log de processamento   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcLogAtu("FIM")


Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTBANCPS  ³Autor  ³ Paulo Augusto         ³ Data ³28.04.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de processamento da contabilizacao off-line dos Docu- ³±±
±±³          ³mentos de Credito de Fornecedores                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 							                                   ³±±
±±³          ³														       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo contabilizar os documentos de  ³±±
±±³          ³Credito de Fornecedores com base nos lancamentos contabeis,  ³±±
±±³          ³de forma off-line                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB/FAT/OMS                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CTBANCPS(lDigita,lAglutina,nTpCtb,lCMV,dDataIni,dDataFim,cFilDe,cFilAte,oObj,lEnd)

Local aCT5       := {}
Local dDataProc  := Ctod("")
Local lFirst     := .T.					// Indica se é o primeiro item da Venda. Usado p/ o L.P. 620 soh ser processado uma vez por Venda.
Local lFirst631	 := .T.					// Indica se é o primeiro item da Venda. Usado p/ o L.P. 631 soh ser processado uma vez por Venda.
Local lCtNfsDt   := ExistBlock("CTNFSDT")
Local lFilSf2    := Existblock("CTNFSFIL")
Local lLctPad10  := VerPadrao("610")	// Credito de Estoque / Debito de C.M.V.
Local lLctPad11  := VerPadrao("611")	// Devolucao do item de rateio
Local lLctPad13  := VerPadrao("613")	// Devolucao dos rateios do item da
Local lLctPad20  := VerPadrao("620")	// Debito de Cliente  / Credito de Venda
Local lLctPad31  := VerPadrao("631")	// Debito de Cliente  / Credito de Venda (Modulo Loja, a partir do SL4)
Local lLctPad78  := VerPadrao("678")	// Credito de Estoque / Debito de C.M.V. (CUSTO)
Local dDtDigit   
Local lLctPad    := .F.
Local lDetProva  := .F.
Local lHeader    := .F.
Local lContinua  := .T.
Local lValido    := .F.
Local lInterface := oObj<>Nil
Local lOptimize  := .F.
Local lSkipSF2   := .F.
Local lLctoOk    := .T.
Local cLoteCtb   := ""
Local cArqCtb    := ""
Local cAliasSD2  := "SD2"
Local cAliasSF2  := "SF2"
Local cAliasSB1  := "SB1"
Local cAliasSF4  := "SF4"
Local cAliasSA1  := "SA1"
Local cAliasSA2  := "SA2"
Local cCliente   := ""
Local cLoja      := ""
Local cDocumento := ""
Local cSerie     := ""
Local c610       := Nil
Local c611       := Nil
Local c613       := Nil
Local c620       := Nil
Local c631       := Nil
Local c678       := Nil
Local cQuery     := ""
Local cKeySF2    := "F2_FILIAL+DTOS(F2_DTDIGIT)"
Local cArqSF2    := ""
Local nHdlPrv    := 0 
Local nTotalCtb  := 0
Local nOrdSF2    := 0
Local nRecSF2    := 0
Local nY         := 0
Local nUltSD2	 := 1
Local nSD2Ori	 := 0
Local nSF2Ori	 := 0
Local aFlagCTB 	 := {}
Local lUsaFlag 	 := GetNewPar("MV_CTBFLAG",.T.) 
Local aDiario	 := {}
Local lSeqCorr	 := UsaSeqCor("SF1/SF2/SC7")
Local lMV_OPTNFS := GetNewPar("MV_OPTNFS",.F.)
Local cMV_CTBPAIS:= GetNewPar("MV_CTBPAIS","CHI,MEX")

Local aSM0 		 := AdmAbreSM0()
Local nContFil	:= 0
Local __cFilAnt := cFilAnt
Local cFilSX5	:= xFilial("SX5")
Local aOptimize  := {}
Local aStruSF2   := {}
Local aStruSD2   := {}
Local aStruSB1   := {}
Local aStruSF4   := {}
Local aStruSA1   := {}
Local aStruSA2   := {}
Local cString    := ""
Local nX         := 0	
Local lD2CtaRec  := SD2->(ColumnPos("D2_CTAREC")) > 0 //Valida se o campo D2_CTAREC existe para gravar a Conta de Receita - EFD Contribuições
Local cCtaRec	 := "" //Conta de Receita do Item - EFD Contribuições
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa parametros DEFAULT                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT lDigita   := .F.
DEFAULT lAglutina := .F.
DEFAULT nTpCtb    := 1
DEFAULT dDataIni  := FirstDay(dDataBase)
DEFAULT dDataFim  := LastDay(dDataBase)
DEFAULT lCMV      := .F.
DEFAULT cFilDe    := cFilAnt
DEFAULT cFilAte   := cFilAnt
DEFAULT lEnd      := .F.

If !CtbInUse()				/// SIGACON NÃO FAZ A MARCAÇÃO DOS FLAGS DE CONTABILIZACAO
	lUsaFlag := .F.			/// MANTEM A MARCACAO DOS FLAGS PELA ROTINA DE CONTABILIZAÇÃO
Endif

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Compatibilizacao dos lancamentos contabeis                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lCMV
	lLctPad78 := .F.
EndIf
lLctPad  := lLctPad13 .Or. lLctPad10 .Or. lLctPad20 .Or. lLctPad78 .Or. lLctPad11
lContinua := lLctPad
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da primeira regua por filiais                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lInterface
	oObj:SetRegua1(Len(aSM0))
EndIf

For nContFil := 1 to Len(aSM0)
	
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf
	
	If !lContinua
		Exit
	EndIf 
	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	
	If cPaisLoc == "ARG"
		__nQuantas := CtbMoedas()   //colocado pois qdo cliente utiliza CTO-MOEDAS exclusivo e com qtd de moedas diferentes entre filiais
	    	                        //deve carregar novamente a variavel public carregada pela LIB
	EndIf

	aCT5 := {}
	c610 := NIL
	c611 := NIL
	c620 := Nil
	c631 := Nil
	c678 := Nil	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza a regua de processamento de filiais                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lInterface
		oObj:IncRegua1(STR0008+": "+aSM0[nContFil][SM0_CODFIL]+"/"+aSM0[nContFil][SM0_NOMRED]) //"Contabilizando"
	EndIf
	For nY := 1 To 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa os documentos de saida da filial corrente           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF2")
		dbSetOrder(1)
		dbSelectArea("SD2")
		dbSetOrder(3)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Demonstra regua de processamento da query                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lInterface
			If lOptimize
				oObj:IncRegua2(STR0010) //"Executando processo de otimizacao com query"
			Else 
				oObj:IncRegua2(STR0011) //"Executando query"
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o parametro de otimizacao                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMV_OPTNFS
			lOptimize := .T.
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do Array de otimizacao de Query                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aOptimize := {}					
		aadd(aOptimize,{}) //SELECT
		aadd(aOptimize,{}) //FROM
		aadd(aOptimize,{})	//WHERE

		If lOptimize
			cAliasSF2 := "CTBANFS"
			cAliasSD2 := "CTBANFS"
			cAliasSB1 := "CTBANFS"
			cAliasSF4 := "CTBANFS"
			cAliasSA1 := "CTBANFS"
			cAliasSA2 := "CTBANFS"
		
			aStruSF2  := SF2->(dbStruct())
			aStruSD2  := SD2->(dbStruct())
			aStruSB1  := SB1->(dbStruct())
			aStruSF4  := SF4->(dbStruct())
			aStruSA1  := SA1->(dbStruct())
			aStruSA2  := SA2->(dbStruct())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem da instrucao select                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 To Len(aStruSF2)
				If !"F2_BASE"$aStruSF2[nX][1]
					aadd(aOptimize[OPT_SELECT],aStruSF2[nX])
				EndIf
			Next nX
			For nX := 1 To Len(aStruSD2)
				If !"D2_BASE"$aStruSD2[nX][1] .And. !"D2_CP"$aStruSD2[nX][1]
					aadd(aOptimize[OPT_SELECT],aStruSD2[nX])
				EndIf
			Next nX
			If lOptimize
				If nY == 1
					For nX := 1 To Len(aStruSA1)
						If aStruSA1[nX][1]$"A1_FILIAL,A1_COD,A1_LOJA,A1_CONTA,A1_NOME,A1_NREDUZ"
							aadd(aOptimize[OPT_SELECT],aStruSA1[nX])
						EndIf
					Next nX
				Else
					For nX := 1 To Len(aStruSA2)
						If aStruSA2[nX][1]$"A2_FILIAL,A2_COD,A2_LOJA,A2_CONTA,A2_NOME,A2_NREDUZ"
							aadd(aOptimize[OPT_SELECT],aStruSA2[nX])
						EndIf
					Next nX
				EndIf
				For nX := 1 To Len(aStruSB1)
					If aStruSB1[nX][1]$"B1_FILIAL,B1_COD,B1_TIPO,B1_CONTA"
						aadd(aOptimize[OPT_SELECT],aStruSB1[nX])
					EndIf
				Next nX
				For nX := 1 To Len(aStruSF4)
					If aStruSF4[nX][1]$"F4_FILIAL,F4_CODIGO,F4_CF"
						aadd(aOptimize[OPT_SELECT],aStruSF4[nX])
					EndIf
				Next nX
			EndIf			
		Else
			cAliasSF2 := "QRYSD2"
			cAliasSD2 := "QRYSD2"
			cAliasSB1 := "QRYSD2"
			cAliasSF4 := "QRYSD2"
			cAliasSA1 := "QRYSD2"
			cAliasSA2 := "QRYSD2"

			/// CAMPOS CHAVE DA TABELA SF2
			aadd(aOptimize[OPT_SELECT], {"F2_FILIAL"	,"C"} )
			aadd(aOptimize[OPT_SELECT], {"F2_EMISSAO"	,"D",8,0} )
			aadd(aOptimize[OPT_SELECT], {"F2_DTLANC"	,"D",8,0} )
			aadd(aOptimize[OPT_SELECT], {"F2_DTDIGIT","D",8,0} )
			
			aadd(aOptimize[OPT_SELECT], {"F2_TIPO"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"F2_CLIENTE"	,"C"} )
			aadd(aOptimize[OPT_SELECT], {"F2_LOJA"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"F2_DOC"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"F2_SERIE"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"F2_ESPECIE"		,"C"} )

			aadd(aOptimize[OPT_SELECT], {"D2_FILIAL"	,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_DOC"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_SERIE"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_CLIENTE"	,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_LOJA"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_COD"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_ITEM"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_ORIGLAN"	,"C"} )

			aadd(aOptimize[OPT_SELECT], {"D2_TES"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_ITEMORI"	,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_NFORI"		,"C"} )
			aadd(aOptimize[OPT_SELECT], {"D2_SERIORI"	,"C"} )
			
		EndIf
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da instrucao from                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aadd(aOptimize[OPT_FROM],{RetSqlName("SF2"),"SF2"})
		aadd(aOptimize[OPT_FROM],{RetSqlName("SD2"),"SD2"})
		aadd(aOptimize[OPT_FROM],{RetSqlName("SB1"),"SB1"})
		aadd(aOptimize[OPT_FROM],{RetSqlName("SF4"),"SF4"})
		If nY == 1
			aadd(aOptimize[OPT_FROM],{RetSqlName("SA1"),"SA1"})
		Else
			aadd(aOptimize[OPT_FROM],{RetSqlName("SA2"),"SA2"})
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da instrucao where                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aOptimize[OPT_WHERE] := "SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
		aOptimize[OPT_WHERE] += "SF2.F2_DTDIGIT >= '"+Dtos(dDataIni)+"' AND "
		aOptimize[OPT_WHERE] += "SF2.F2_DTDIGIT <= '"+Dtos(dDataFim)+"' AND "
		aOptimize[OPT_WHERE] += "SF2.F2_DTLANC = '"+Dtos(Ctod(""))+"' AND "
		aOptimize[OPT_WHERE] += "SF2.D_E_L_E_T_=' ' AND "
		aOptimize[OPT_WHERE] += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
		aOptimize[OPT_WHERE] += "SD2.D2_DOC = SF2.F2_DOC AND "
		aOptimize[OPT_WHERE] += "SD2.D2_SERIE = SF2.F2_SERIE AND "
		aOptimize[OPT_WHERE] += "SD2.D2_CLIENTE = SF2.F2_CLIENTE AND "
		aOptimize[OPT_WHERE] += "SD2.D2_LOJA = SF2.F2_LOJA AND "
		aOptimize[OPT_WHERE] += "SD2.D_E_L_E_T_=' ' AND "
		aOptimize[OPT_WHERE] += "SD2.D2_ORIGLAN<>'LF' AND "
		aOptimize[OPT_WHERE] += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		aOptimize[OPT_WHERE] += "SB1.B1_COD=SD2.D2_COD AND "
		aOptimize[OPT_WHERE] += "SB1.D_E_L_E_T_=' ' AND "
		aOptimize[OPT_WHERE] += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
		aOptimize[OPT_WHERE] += "SF4.F4_CODIGO=SD2.D2_TES AND "	
		aOptimize[OPT_WHERE] += "SF4.D_E_L_E_T_=' ' AND "
		If nY == 1
			aOptimize[OPT_WHERE] += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
			aOptimize[OPT_WHERE] += "SA1.A1_COD = SF2.F2_CLIENTE AND "
			aOptimize[OPT_WHERE] += "SA1.A1_LOJA = SF2.F2_LOJA AND "
			aOptimize[OPT_WHERE] += "SA1.D_E_L_E_T_=' ' AND "
			aOptimize[OPT_WHERE] += "SF2.F2_TIPO NOT IN('D','B') "
		Else
			aOptimize[OPT_WHERE] += "SA2.A2_FILIAL='"+xFilial("SA2")+"' AND "
			aOptimize[OPT_WHERE] += "SA2.A2_COD = SF2.F2_CLIENTE AND "
			aOptimize[OPT_WHERE] += "SA2.A2_LOJA = SF2.F2_LOJA AND "
			aOptimize[OPT_WHERE] += "SA2.D_E_L_E_T_=' ' AND "
			aOptimize[OPT_WHERE] += "SF2.F2_TIPO IN('D','B') "
		EndIf					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Execucao do execblock para alteracao da query de otimizacao  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CTBNFS")
			aOptimize := ExecBlock("CTBNFS",.F.,.F.,aOptimize)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Query                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
		cString := ""
		For nX := 1 To Len(aOptimize[OPT_SELECT])
			cString += ","+aOptimize[OPT_SELECT][nX][1]
		Next nX
		If lOptimize
			cQuery := "SELECT SF2.R_E_C_N_O_ SF2RECNO"+cString
		Else
			cQuery := "SELECT SF2.R_E_C_N_O_ SF2RECNO,"
			If nY == 1
				cQuery += "SA1.R_E_C_N_O_ SA1RECNO,"
			Else
				cQuery += "SA2.R_E_C_N_O_ SA2RECNO,"
			EndIf
			cQuery += "SF4.R_E_C_N_O_ SF4RECNO,"
			cQuery += "SB1.R_E_C_N_O_ SB1RECNO"+cString
		EndIf
		cQuery += ",SD2.R_E_C_N_O_ SD2RECNO"
		cString := ""
		For nX := 1 To Len(aOptimize[OPT_FROM])
			cString += ","+aOptimize[OPT_FROM][nX][1]+" "+aOptimize[OPT_FROM][nX][2]
		Next nX
		cQuery += " FROM "+SubStr(cString,2)
		cQuery += " WHERE "+aOptimize[OPT_WHERE]				

		If nTpCtb == 3 //-- Contabiliza por Dia
			cQuery += " ORDER BY " + SqlOrder("F2_FILIAL+F2_DTDIGIT+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA")+","+SqlOrder(SD2->(IndexKey()))
		Else 
			cQuery += " ORDER BY " + SqlOrder(SF2->(IndexKey()))+ "," +SqlOrder(SD2->(IndexKey()))				
		EndIf	
	
		cQuery := ChangeQuery(cQuery)
		
						
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)
	
		For nX := 1 To Len(aOptimize[OPT_SELECT])
			If aOptimize[OPT_SELECT][nX][2]<>"C"
				TcSetField(cAliasSF2,aOptimize[OPT_SELECT][nX][1],aOptimize[OPT_SELECT][nX][2],aOptimize[OPT_SELECT][nX][3],aOptimize[OPT_SELECT][nX][4])
			EndIf
		Next nX

		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Preparacao da contabilizacao por periodo                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLctPad .And. nTpCtb == 2
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o numero do lote contabil                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX5")
			dbSetOrder(1)
			If MsSeek(cFilSX5+IIf(!cPaisLoc $ cMV_CTBPAIS,"09FAT","09COM"))
				cLoteCtb := AllTrim(X5Descri())
			Else
				cLoteCtb := IIf(!cPaisLoc $ cMV_CTBPAIS,"FAT ","COM ")
			EndIf		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa um execblock                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If At(UPPER("EXEC"),X5Descri()) > 0
				cLoteCtb := &(X5Descri())
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa o arquivo de contabilizacao                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			nHdlPrv:=HeadProva(cLoteCtb,"CTBANFS",Subs(cUsuario,7,6),@cArqCtb)
			IF nHdlPrv <= 0
				HELP(" ",1,"SEM_LANC")
				lContinua := .F.
			Else
				lHeader := .T.
			EndIf		
		EndIf			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da segunda regua por periodo                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lInterface
			oObj:SetRegua2(dDataFim+1-dDataIni)
			dDataProc := dDataIni
			oObj:IncRegua2(STR0013+": "+Dtoc((cAliasSF2)->F2_DTDIGIT)) //"Documento de Credito de "
		EndIf
		dbSelectArea(cAliasSF2)
		While ( !Eof() .And. (cAliasSF2)->F2_FILIAL == xFilial("SF2") .And.;
			(cAliasSF2)->F2_DTDIGIT <= dDataFim .And. lContinua)
			
			lValido   := .T.
			lDetProva := .F.
			lSkipSF2  := .T.
	        dDtDigit  := (cAliasSF2)->F2_DTDIGIT 			
         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a nota nao foi contabilizada                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty((cAliasSF2)->F2_DTLANC)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa a filtragem da customizacao                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFilSf2
					If !(Execblock("CTNFSFIL",.F.,.F.,{cAliasSF2}))
						lValido := .F.
					EndIf
				EndIf
			Else
				lValido := .F.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicia a contabilizacao deste documento de saida             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If lValido	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no Cabecalho do documento de saida                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lOptimize
					SF2->(MsGoto((cAliasSF2)->SF2RECNO))
				Else
					nRecSF2 := (cAliasSF2)->SF2RECNO
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ajusta a data base com a data de contabilizacao              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Do Case
					Case nTpCtb == 1 .Or. nTpCtb == 3 
						dDataBase := (cAliasSF2)->F2_DTDIGIT						
						If lCtNfsDt
							dDataBase := Execblock("CTNFSDT",.F.,.F.)
						EndIf
					Case nTpCtb == 2
						dDataBase := dDataFim
				EndCase

				If lUsaFlag
					aAdd(aFlagCTB,{"F2_DTLANC",dDataBase,"SF2",(cAliasSF2)->SF2RECNO,0,0,0})
				EndIf
				If lSeqCorr
					If lOptimize
						cDiario := (cAliasSF2)->F2_DIACTB
					Else
						cDiario := SF2->F2_DIACTB
					EndIf
					aAdd(aDiario, {"SF2",(cAliasSF2)->SF2RECNO,cDiario,"F2_NODIA","F2_DIACTB"})
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Preparacao da contabilizacao por documento                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Begin Transaction
			    	If 	!lHeader
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica o numero do lote contabil                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						dbSelectArea("SX5")
						dbSetOrder(1)
						If MsSeek(cFilSX5+"09FAT")
							cLoteCtb := AllTrim(X5Descri())
						Else
							cLoteCtb := "FAT "
						EndIf		
						If cPaisLoc $ cMV_CTBPAIS .And. (cAliasSF2)->F2_TIPO $ "D" 
							If MsSeek(xFilial()+"09COM")
								cLoteCtb := AllTrim(X5Descri())
							Else
								cLoteCtb := "COM "
							EndIf 
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Executa um execblock                                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If At("EXEC",Upper(X5Descri())) > 0
							cLoteCtb := &(X5Descri())
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Inicializa o arquivo de contabilizacao                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nHdlPrv:=HeadProva(cLoteCtb,"CTBANFS",Subs(cUsuario,7,6),@cArqCtb)
						IF nHdlPrv <= 0
							HELP(" ",1,"SEM_LANC")
							lContinua := .F.
						Else
							lHeader := .T.
						EndIf		
	            	EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona registros vinculados ao cabecalho do documento     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cAliasSF2)->F2_TIPO $ "DB"
						dbSelectArea("SA2")
						dbSetOrder(1)
						If !lOptimize
							SA2->(MsGoto((cAliasSA2)->SA2RECNO))
						EndIf
					Else
						dbSelectArea("SA1")
						dbSetOrder(1)
						If !lOptimize .And. nY == 1
							SA1->(MsGoto((cAliasSA1)->SA1RECNO))
						EndIf
					EndIf
					dbSelectArea(cAliasSF2)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Processa os itens do documento de saida                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea(cAliasSF2)
					
					cCliente   := (cAliasSF2)->F2_CLIENTE
					cLoja      := (cAliasSF2)->F2_LOJA
					cDocumento := (cAliasSF2)->F2_DOC
					cSerie     := (cAliasSF2)->F2_SERIE
					lFirst     := .T.	// boleano p/ LP 620 ser processado soh uma vez por Venda e nao a cada item.
					lFirst631  := .T.	// boleano p/ LP 631 ser processado soh uma vez por Venda e nao a cada item.
					
					While ( (cAliasSD2)->(!Eof()) .And. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .And.;
						(cAliasSD2)->D2_DOC == cDocumento .And.;
						(cAliasSD2)->D2_SERIE == cSerie .And.;
						(cAliasSD2)->D2_CLIENTE == cCliente .And.;
						(cAliasSD2)->D2_LOJA == cLoja )
	
						lValido := .T.
						
						nUltSD2 := (cAliasSD2)->SD2RECNO
						If !lOptimize
							SD2->(dbGoTo(nUltSD2))
						EndIf

						If 	(cAliasSD2)->D2_ORIGLAN <> "LF"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Posiciona registros vinculados ao item do documento          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If cModulo == "LOJ" .AND. lFirst631
							
								lFirst631	 := .F.	// boleano p/ LP 631 ser processado soh uma vez por Venda e nao a cada item.
							
								dbSelectArea("SL1")
								dbSetOrder(2)
								MsSeek( xFilial("SL1")+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC)

								dbSelectArea("SL2")
								dbSetOrder(3)
								MsSeek( xFilial("SL2")+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_COD)

								If cPaisLoc $ cMV_CTBPAIS
									If (cAliasSD2)->D2_ORIGLAN != "LO"
										lValido := .F.
									EndIf
								EndIf

								// Permite a contabilizacao pelo SL4 (Itens de Venda por Forma de Pagamento)
								If lLctPad31
									dbSelectArea("SL4")
									dbSetOrder(1)
									If dbSeek(xFilial()+SL1->L1_NUM)
										While !Eof() .and. xFilial() == SL4->L4_FILIAL .and. SL4->L4_NUM == SL1->L1_NUM
											c631       := CtRelation("631",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
											nTotalCtb += DetProva(nHdlPrv,"631","CTBANFS",cLoteCtb,,,,,@c631,@aCT5,,@aFlagCTB)
											dbSkip()
											Loop
										End
									EndIf
						 		EndIf
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Preparacao da contabilizacao por item do documento           ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
							If lValido						
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Posiciona registros vinculados ao item do documento          ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("SB1")
								dbSetOrder(1)
								If !lOptimize
									SB1->(MsGoto((cAliasSB1)->SB1RECNO))
								EndIf									
	
								dbSelectArea("SF4")
								dbSetOrder(1)
								If !lOptimize
									SF4->(MsGoto((cAliasSF4)->SF4RECNO))
								EndIf

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Executa os lancamentos contabeis ( 610 ) - Item              ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cCtaRec := "" //Limpa a variavel devido processamento em laço
								If lLctPad10  .And. lHeader
									c610       := CtRelation("610",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
									lDetProva := .T.
									nTotalCtb += DetProva(nHdlPrv,"610","CTBANFS",cLoteCtb,,,,,@c610,@aCT5,,@aFlagCTB,,,,,,,@cCtaRec)
									//-----------------------------------------------------------------------------------------
									// Adequacao para Gravar a Conta de Receita do Item da Nota, para uso no EFD-Contribuições
									//-----------------------------------------------------------------------------------------
									If lD2CtaRec .And. !Empty(cCtaRec)
										Aadd(aFlagCTB,{"D2_CTAREC",cCtaRec,"SD2",SD2->(Recno()),0,0,0})

										SFT->(DbSetOrder(1))
										If SFT->(DbSeek(xFilial("SFT")+"S"+(cAliasSD2)->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+Padr(D2_ITEM,TAMSX3("FT_ITEM")[1])+D2_COD))) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO 
											Aadd(aFlagCTB,{"FT_CONTA",cCtaRec,"SFT",SFT->(Recno()),0,0,0})
										EndIf
									EndIf

									If lLctPad11  .And. lHeader .And. !Empty((cAliasSD2)->D2_ITEMORI)									
										dbSelectArea("SF1")
										dbSetOrder(1)
										MsSeek(xFilial("SF1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA)
										
										dbSelectArea("SD1")
										dbSetOrder(1)
										MsSeek(xFilial("SD1")+(cAliasSD2)->D2_NFORI+(cAliasSD2)->D2_SERIORI+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMORI)
											
										dbSelectArea("SDE")
										dbSetOrder(1)
										MsSeek(xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM)
										While ( !Eof() .And. ;
											xFilial("SDE") == SDE->DE_FILIAL .And.;
											SD1->D1_DOC == SDE->DE_DOC .And.;
											SD1->D1_SERIE == SDE->DE_SERIE .And.;
											SD1->D1_FORNECE == SDE->DE_FORNECE .And.;
											SD1->D1_LOJA == SDE->DE_LOJA .And.;
											SD1->D1_ITEM == SDE->DE_ITEMNF)

											nTotalCtb += DetProva(nHdlPrv,"611","CTBANFS",cLoteCtb,,,,,@c611,@aCT5,,@aFlagCTB)

											dbSelectArea("SDE")
											dbSkip()
										EndDo
									EndIf
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Executa os lancamentos contabeis ( 678 ) - C.M.V.            ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lLctPad78 .And. lHeader
									c678       := CtRelation("678",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
									lDetProva := .T.
									nTotalCtb += DetProva(nHdlPrv,"678","CNA200C",cLoteCtb,,,,,@c678,@aCT5,,@aFlagCTB)
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Executa os lancamentos contabeis ( 613 ) - rateio Item       ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If lLctPad13  .And. lHeader .And. cPaisLoc == "ARG" .And. SD2->D2_RATEIO == "1"
									c613       := CtRelation("613",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
									lDetProva := .T.
									dbSelectArea("AGH")
									AGH->(dbSetOrder(2)) //AGH->AGH_FILIAL + AGH->AGH_NUM + AGH->AGH_ITEMPD + AGH->AGH_ITEM
									If dbSeek(xFilial("AGH")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_ITEM )
										While (!AGH->(EOF()) .And. ;
											xFilial("AGH") == AGH->AGH_FILIAL .And.;
											(cAliasSD2)->D2_DOC == AGH->AGH_NUM .And.;
											(cAliasSD2)->D2_SERIE == AGH->AGH_SERIE .And.;
											(cAliasSD2)->D2_ITEM == AGH->AGH_ITEMPD)

											nTotalCtb += DetProva(nHdlPrv,"613","CTBANFS",cLoteCtb,,,,,@c613,@aCT5,,@aFlagCTB)
											AGH->(dbSkip())
										EndDo
									EndIf
								EndIf
							EndIf
						EndIf						
						If lValido .And. lFirst
							lFirst := .F.	// boleano p/ LP 620 ser processado soh uma vez por Venda e nao a cada item.
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Executa os lancamentos contabeis ( 620 ) - Cabecalho         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lLctPad20 .And. lHeader
								c620       := CtRelation("620",.F.,{{cAliasSF2,"SF2"},{cAliasSD2,"SD2"},{cAliasSD2,"CTBANFS"}})
								lDetProva := .T.
								nTotalCtb += DetProva(nHdlPrv,"620","CTBANFS",cLoteCtb,,,,,@c620,@aCT5,,@aFlagCTB)
							EndIf
						EndIf										
						dbSelectArea(cAliasSD2)
						dbSkip()
						lSkipSF2 := .F.
						
						If lInterface .And. lEnd
							oObj:IncRegua2(STR0012) //"Aguarde abortando execucao"
						EndIf
						
					EndDo
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza a data de lancamento contabil para nao refaze-lo    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lDetProva .And. lHeader
						If lOptimize
							SF2->(MsGoto(nRecSF2))
						EndIf		
						If !lUsaFlag
							RecLock("SF2")
							SF2->F2_DTLANC := dDataBase
							MsUnlock()
						EndIf
		            EndIf
		    	End Transaction
				If nTpCtb == 1 .And. lHeader
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Fecha os lancamentos contabeis                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lHeader := .F.
					RodaProva(nHdlPrv,nTotalCtb)
					If nTotalCtb > 0 				
						nSD2Ori := SD2->(Recno())	/// GUARDA O POSICIONAMENTO DO SD2
						SD2->(dbGoTo(nUltSD2))		// POSICIONA NO ÚLTIMO SD2 DA NF.
						nSF2Ori := SF2->(Recno())	/// GUARDA O POSICIONAMENTO DO SF2
						nTotalCtb := 0
						lLctoOk := cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB,,aDiario)
						aDiario := {}
						
						SF2->(dbGoTo(nSF2Ori))		// VOLTA O POSICIONAMENTO DO SF2 ORIGINAL												
						If !lUsaFlag .And. !lLctoOk
							RecLock("SF2")
							SF2->F2_DTLANC := CtoD("")
							MsUnlock()
						EndIf
						SD2->(dbGoTo(nSD2Ori))		// VOLTA O POSICIONAMENTO DO SD2 ORIGINAL
					EndIf
				EndIf
			EndIf
			If lSkipSF2 
				dbSelectArea(cAliasSF2)
				dbSkip()
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza a regua de processamento por periodo                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dDataProc<>(cAliasSF2)->F2_DTDIGIT
				While dDataProc<=(cAliasSF2)->F2_DTDIGIT
					If lInterface
						oObj:IncRegua2(STR0013+": "+Dtoc((cAliasSF2)->F2_DTDIGIT)) //"Documento de Credito de "
					Endif
					dDataProc++
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a contabilizacao foi abortada                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lEnd
				Exit
			EndIf
			
			If nTpCtb == 3 .And. (cAliasSF2)->F2_DTDIGIT <> dDtDigit
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Fecha os lancamentos contabeis                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lHeader   := .F.
				RodaProva(nHdlPrv,nTotalCtb)
				If nTotalCtb > 0
					nTotalCtb := 0			
					cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
				EndIf
			EndIf
				
		EndDo
		
		If nTpCtb == 2 .And. lHeader
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Fecha os lancamentos contabeis                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lHeader   := .F.
			RodaProva(nHdlPrv,nTotalCtb)
			If nTotalCtb > 0
				nTotalCtb := 0			
				cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lDigita,lAglutina,,,,@aFlagCTB)
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna a situacao inicial                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea(cAliasSF2)
		dbCloseArea()
	Next nY
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o arquivo e compartilhado para encerrar a contab.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(xFilial("SF2"))
		Exit
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a contabilizacao foi abortada                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEnd
		Exit
	EndIf	
Next nContFil
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³06/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina   := { { STR0001 ,"AllwaysTrue", 0 , 3} }  //"Parametros"
Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbNFSMultºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Contabilização MultiThread de pedido de venda e NFS        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbNFSMult(lCMV,dDataIni,dDataFim,cFilDe,cFilAte,lContNCP,nNumProc,cTpLanc)
Local aArea 	  := GetArea()
Local aSM0 		  := AdmAbreSM0()
Local nContFil	  := 0
Local cFilIni	  := cFilAnt 
Local nX		  := 0
Local lRet		  := .T.
Local lLctPad12  := VerPadrao("612",.T.)    // Itens do Pedido de Venda
Local lLctPad21  := VerPadrao("621",.T.)    // cabeçalho do Pedido de Venda

For nContFil := 1 to Len(aSM0)

	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt  
		Loop
	EndIf

	cFilAnt := aSM0[nContFil][SM0_CODFIL] 
	
	__nQuantas := CtbMoedas()   //colocado pois qdo cliente utiliza CTO-MOEDAS exclusivo e com qtd de moedas diferentes entre filiais
	                            //deve carregar novamente a variavel public carregada pela LIB

	If lLctPad12 .Or. lLctPad21
		//Contabilização de Pedido de Compras
		lRet := CtbMComPed(dDataIni,dDataFim,nNumProc,cTpLanc)
	EndIF
    
	If lRet
		For nX := 1 to 2
			//Contabilização de Nota Fiscal de Entrada
			lRet := CtbMComNFS(dDataIni,dDataFim,lCMV,lContNCP,nNumProc , nX == 2,cTpLanc)
			If !lRet
				Exit
			EndIf
		Next nX
	EndIf
	
Next nContFil

cFilAnt := cFilIni
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMComNFSºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contabilização da nota fiscal de entrada                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMComNFS(dDataIni,dDataFim,lCMV,lContNCP,nNumProc,lDevolucao,cTpLanc)
Local aArea 	 := GetArea()
Local lRet		 := .T.
Local nX		 := 0
Local aProcs 	 := {}
Local aNFsMult	 := {}
Local cChave	 := SF2->(IndexKey(1))
Local nTotalReg	 := 0
Local cRaizNome	 := 'CTBNFSPROC'  
Local cToken	 := ""			   

Default cTpLanc := 1

If lAuthToken
	cToken := totvs.framework.users.rpc.getAuthToken()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o arquivo de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNFsMult := CtbGrvNFS(dDataIni,dDataFim,lDevolucao,cChave)

nTotalReg := Len(aNFsMult)

If nTotalReg > 0
		
	If nNumProc > 40
		nNumProc := 40
	Endif
		
	If  nTotalReg >= nNumProc .And. nNumProc > 1 // MultiThread
		aProcs := CTBPrepNFS(nNumProc,nTotalReg,cRaizNome,aNFsMult)
		//Inicializa as Threads Transação controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("JOBCTBNFS", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],lCMV,lContNCP,dDataIni,dDataFim,cValToChar(nX),;
													   aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,aProcs[nX][5],aProcs[nX][6],cTpLanc,lDevolucao,cToken)
			Sleep(3000)
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o controle das Threads³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Sleep(3000)
		lRet := NFSMonitor(aProcs,IIF(lDevolucao,3,2)) 

	Else		
		lRet := CtbProcNFS(lCMV,lContNCP,dDataIni,dDataFim,"","",cTpLanc,lDevolucao)
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMComPedºAutor  ³Alvaro Camillo Neto º Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contabilização do pedido de compra                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbMComPed(dDataIni,dDataFim,nNumProc,cTpLanc)
Local aArea := GetArea()
Local lRet		 := .T.
Local nX		 := 0
Local aProcs 	 := {}
Local aPedMult	 := {}
Local cChave	 := SC5->(IndexKey(1))
Local nTotalReg	 := 0
Local cRaizNome	 := 'CTBNFSPROC'
Local cToken	 := ""
	
If lAuthToken
	cToken := totvs.framework.users.rpc.getAuthToken()
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o arquivo de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPedMult := CtbGrvPV(dDataIni,dDataFim,cChave)

nTotalReg := Len(aPedMult)

If nTotalReg > 0
	
	If nNumProc > 40
		nNumProc := 40
	Endif                                                       
	
	If  nTotalReg >= nNumProc .And. nNumProc > 1 // MultiThread
		aProcs := CTBPrepNFS(nNumProc,nTotalReg,cRaizNome,aPedMult)
		//Inicializa as Threads Transação controlada nas Threads
		For nX := 1 to Len(aProcs)
			StartJob("JOBMCTBPV", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nX][MARCA],aProcs[nX][ARQUIVO],dDataIni,dDataFim,cValToChar(nX),;
													   aProcs[nX][VAR_STATUS],cChave,__cUserId,cUserName,cAcesso,cUsuario,aProcs[nX][5],aProcs[nX][6],cTpLanc,cToken)
			Sleep(3000)
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza o controle das Threads³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Sleep(3000)
		lRet := NFSMonitor(aProcs,1)

	Else
		lRet := CtbProcPV(dDataIni,dDataFim,"","",cTpLanc)

	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGrvPV   ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo temporario dos pedidos de compra              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvPV(dDataIni,dDataFim,cChave)

Local cQuery		:= ""
Local cAliasSC5		:= GetNextAlias()
Local aPedidos	 	:= {}
Local aAreaAnt		:= GetArea()
 
cQuery := "SELECT SC5.C5_NUM "
cQuery += "FROM "
cQuery += 		 RetSqlName("SC5")	+ " SC5 "
cQuery += "WHERE "
cQuery += 		"SC5.C5_FILIAL = '" + xFilial("SC5")+"' AND "
cQuery += 		"SC5.C5_EMISSAO >= '"+Dtos(dDataIni)+"' AND "
cQuery += 		"SC5.C5_EMISSAO <= '"+Dtos(dDataFim)+"' AND "
cQuery +=		"SC5.C5_DTLANC   = '"+Dtos(Ctod(""))+"' AND "
cQuery += 		"SC5.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY " + SqlOrder(cChave)

cQuery := ChangeQuery(cQuery)

If Select(cAliasSC5) > 0
	dbSelectArea(cAliasSC5)
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC5,.F.,.T.)

// Carrega Array aPedidos
While (cAliasSC5)->(!Eof())
	aAdd(aPedidos,(cAliasSC5)->C5_NUM)
	(cAliasSC5)->(dbSkip())
EndDo

If Select(cAliasSC5) > 0
	dbSelectArea(cAliasSC5)
	dbCloseArea()
EndIf
RestArea(aAreaAnt)
Return aPedidos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGrvNFS  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo temporario das notas fiscais de entrada       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbGrvNFS(dDataIni,dDataFim,lDevolucao,cChave)

Local cQuery		:= ""
Local cAliasSF2		:= GetNextAlias()
Local aNotas	 	:= {}
Local aAreaAnt		:= GetArea()
 
cQuery := "SELECT DISTINCT SF2.F2_DOC "
cQuery += "FROM "
cQuery += 		 RetSqlName("SF2")	+ " SF2 "
cQuery += "WHERE "
cQuery += 		"SF2.F2_FILIAL = '" + xFilial("SF2")+"' AND "
cQuery += 		"SF2.F2_EMISSAO >= '"+Dtos(dDataIni)+"' AND "
cQuery += 		"SF2.F2_EMISSAO <= '"+Dtos(dDataFim)+"' AND "
cQuery +=		"SF2.F2_DTLANC   = '"+Dtos(Ctod(""))+"' AND "
If !lDevolucao
	cQuery +=		"SF2.F2_TIPO NOT IN('D','B') AND "
Else
	cQuery +=		"SF2.F2_TIPO IN('D','B') AND "
EndIf
cQuery += 		"SF2.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

If Select(cAliasSF2) > 0
	dbSelectArea(cAliasSF2)
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.F.,.T.)

// Carrega Array aNotas
While (cAliasSF2)->(!Eof())
	aAdd(aNotas,(cAliasSF2)->F2_DOC)
	(cAliasSF2)->(dbSkip())
EndDo

// Sorteia array com os numeros dos documentos
aSort(aNotas)

If Select(cAliasSF2) > 0
	dbSelectArea(cAliasSF2)
	dbCloseArea()
EndIf
RestArea(aAreaAnt)
Return aNotas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBMCTBPV  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job da contabilização do Pedido de Compra                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JOBMCTBPV(cEmpX,cFilX,cMarca,cFileLck,dDataIni,dDataFim,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cProdIni,cProdFim,cTpLanc, cToken)
Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 
Default cToken 	:= ""
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nHandle := NFSLock(cFileLck)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cVarStatus, "1" )
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)

RpcClearEnv()

// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,,,)

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cVarStatus, "2" )
GlbUnLock()

//Set o usuário para buscar as perguntas do profile
lMsErroAuto := .F.
lMsHelpAuto := .T. 
lAutoErrNoFile := .T.
	
If lAuthToken
	totvs.framework.users.rpc.authByToken(cToken)
Else
	__cUserId   := cXUserId
EndIf 

cUserName := cXUserName
cAcesso   := cXAcesso
cUsuario  := cXUsuario

ConOut("Starting: "+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := CtbProcPV(dDataIni,dDataFim,cProdIni,cProdFim,cTpLanc)

JOBNFSEnd(cVarStatus,nHandle,lRet)

ConOut("Finished: "+Time())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBCTBNFS  ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job da contabilização da Nota Fiscal de Entrada            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function JOBCTBNFS(cEmpX,cFilX,cMarca,cFileLck,lCMV,lContNCP,dDataIni,dDataFim,cId,cVarStatus,cChave,cXUserId,cXUserName,cXAcesso,cXUsuario,cDocIni,cDocFim,cTpLanc,lDevolucao, cToken)
Local nHandle	 := 0
Local lRet		 := .T.

Private lMsErroAuto 
Private lMsHelpAuto 
Private lAutoErrNoFile 

Default cToken := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Abre o arquivo de Lock parao controle externo das threads³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHandle := NFSLock(cFileLck) 

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cVarStatus, "1" )
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,,,)

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cVarStatus, "2" )
GlbUnLock()

//Set o usuário para buscar as perguntas do profile
lMsErroAuto := .F.
lMsHelpAuto := .T. 
lAutoErrNoFile := .T.

If lAuthToken
	totvs.framework.users.rpc.authByToken(cToken)
Else
	__cUserId   := cXUserId
EndIf 

cUserName := cXUserName
cAcesso   := cXAcesso
cUsuario  := cXUsuario

ConOut("Starting: "+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o processamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := CtbProcNFS(lCMV,lContNCP,dDataIni,dDataFim,cDocIni,cDocFim,cTpLanc,lDevolucao)

JOBNFSEnd(cVarStatus,nHandle,lRet)

ConOut("Finished: "+Time())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbProcNFS ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     Processa a contabilização                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbProcNFS(lCMV,lContNCP,dDataIni,dDataFim,cDocIni,cDocFim,cTpLanc,lDevolucao)
Local aArea := GetArea()
Local lRet := .T.

Default cTpLanc :=  1

MaCtbNFS(.F.,.F.,cTpLanc,lCMV,dDataIni,dDataFim,xFilial("SF2"),xFilial("SF2"),lContNCP,Nil,.F.,.F.,.T.,Nil,Nil,.T.,cDocIni,cDocFim,lDevolucao)

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbProPV ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     Processa a contabilização                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbProcPV(dDataIni,dDataFim,cProdIni,cProdFim,cTpLanc)
Local aArea := GetArea()
Local lRet := .T.

Default cTpLanc := 1

MaCtbNfs(.F.,.F.,cTpLanc,.F.,dDataIni,dDataFim,xFilial("SC5"),xFilial("SC5"),.F.,Nil,.F.,.T.,.F.,Nil,Nil,.T.,cProdIni,cProdFim)

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NFSMonitorºAutor³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função responsavel por monitorar as threads de processamen º±±
±±º          ³ to                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function NFSMonitor(aProcs,nTipo)
Local lRet			:= .T.
Local nX			:= 0
Local aConcluido	:= {}
Local nHandle		:= 0
Local cMsg			:= ""
Local cRotErro		:= ""
Local cTipoErro		:= ""
Local cMsgErro		:= ""
Local aErros		:= {}

Default nTipo := 1

While .T.
	For nX := 1 to Len(aProcs)
		nHandle := NFSLock(aProcs[nX][ARQUIVO])
		If  nHandle >= 0
			fClose(nHandle)
			If aScan(aConcluido,{|aItem| aItem[3] == aProcs[nX][MARCA]} ) == 0
				AADD(aConcluido, { nHandle, aProcs[nX][ARQUIVO], aProcs[nX][MARCA]})
			EndIf
		EndIf
	Next nX
	
	If Len(aConcluido) >= Len(aProcs)
		Exit
	EndIF
	Sleep(5000)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se todas a threads foram processadas corretamente³
//³libera o recurso e apaga o arquivo                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aConcluido)
	FT_FUse(aConcluido[nX][2])
	FT_FGoTop()
	cMsg := FT_FReadLn()
	FT_FUse()
	fErase(aConcluido[nX][2])
	If lRet .And. ALLTRIM(cMsg) != OK
		lRet := .F.
	EndIf
Next nX


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica quais threads deram erro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet       
	Do Case
		Case nTipo == 1 //Pedido de Venda
			cRotErro := " Erro no processamento do pedido de Venda: "
		Case nTipo == 2 //Nota Fiscal de Entrada                     
			cRotErro := " Erro no processamento de nota fiscal de saida: " 
		Case nTipo == 3 //Nota Fiscal de Devolução                   	
			cRotErro := " Erro no processamento do nota fiscal de devolução: "	
	EndCase
	
	For nX := 1 to Len(aProcs)
		cStatus := GetGlbValue(aProcs[nX][VAR_STATUS])
		If cStatus != "3" // Concluido com sucesso 
	        Do Case
				Case cStatus == "1" // Erro na Conexão
					cTipoErro := " Erro na inicialização do processo"
				Case cStatus == "2" // Erro no Processamento
				   	cTipoErro := " Erro no processo de contabilização"			
			EndCase
			cMsgErro := cRotErro + cTipoErro + " processo numero " + cValTochar(nX) //" processo numero "
			ProcLogAtu("ERRO","Erro no Processamento",cMsgErro)//"Erro no Processamento"
			aAdd(aErros,cMsgErro)
		EndIf
	Next nX
EndIf

If !lRet
	If MsgYesNo("Ocorreram inconsistencia no processo, deseja imprimir o relatorio de erros?")//"Ocorreram inconsistencia no processo, deseja imprimir o relatorio de erros?"
		CtRConOut(aErros)
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NFSUnLock³ Autor ³Marcos Justo            ³ Data ³ 15/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Encerra a trava                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NFSUnLock(nHandle,lOk)
Local cMsg := IIF(lOk,OK,ERRO)
FWRITE(nHandle,cMsg)
FCLOSE(nHandle)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NFSLock ºAutor  ³Alvaro Camillo Netoº Data ³  15/04/10   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria arquivo para travar processos e garantir que sao unicos³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NFSLock(cFile)
Local nHJob := 0
If File(cFile)
	nHJob := FOPEN(cFile,2)
Else
	nHJob := FCREATE(cFile)
EndIf
Return nHJob

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBPrepNFS  ºAutor³Alvaro Camillo Netoº Data ³  15/04/10    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Prepara as informacoes para o processamento multithread     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTBPrepNFS(nNumProc,nTotalReg,cRaizNome,aRegsProc)
Local aProcs 		:= Array(nNumProc)
Local nX		 	:= 0
Local cDirSem  		:= "\Semaforo\"
Local cNomeArq		:= ""
Local cMarca  		:= ""
Local nRegAProc		:= 0 // Registros a processar
Local nRegJProc		:= 0 // Total de registros já processados
Local cVarStatus	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria a pasta do semaforo caso não exista³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ExistDir(cDirSem)
	MontaDir(cDirSem)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o calculos das quantidades de registros³
//³que cada thread irá processar e                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to Len(aProcs)
	cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX)+cValtoChar(INT(Seconds())) + '.lck'
	cMarca		:= GetMark()
	nRegAProc	:= IIf( nX == 1 , 1 , aProcs[nX-1,7]+1 )
	nRegJProc	+= IIf( nX == Len(aProcs), nTotalReg-nRegJProc, Int(nTotalReg / nNumProc) )
	cVarStatus  :="cNFSP"+cEmpAnt+cFilAnt+StrZero(nX,2)+cMarca
	PutGlbValue(cVarStatus,"0")
	GlbUnLock()
	aProcs[nX]	:= {cNomeArq,cMarca,nRegAProc,cVarStatus,aRegsProc[nRegAProc],aRegsProc[nRegJProc],nRegJProc}
Next nX

Return aProcs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbValMult ºAutor  ³Alvaro Camillo Netoº Data ³  05/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o processamento será feito MultiThread           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbValMult(lMostraHelp,lAglutina,lMostraLanc,nTipo) 
Local lRet 		:= .T. 
Local lBlind    := IsBlind()
Local nHelp		:= 1 
Default lMostraHelp := .F.
Default nTipo 		:= 1
Default lMostraLanc := .F.

If lMostraHelp .And. !lBlind  
	nHelp := 1
Else
	nHelp := 0
EndIf 


	
If lRet .And. lAglutina
	If lMostraHelp .And. !lBlind  
		lRet := MsgYesNo(STR0017,STR0016)//"O processamento Multithread está disponivel apenas para processamento sem aglutinação, o processamento será feito sem multithread. Concorda com operação?" ##"Atenção"
	Else
		lRet := .F.
	EndIf
EndIf  

If lRet
	lCtbInTran := CTBINTRAN(nHelp,lMostraLanc)
	
	If !lCtbInTran
		If lMostraHelp .And. !lBlind   
			lRet := MsgYesNo(STR0018,STR0016)//"O processamento será feito sem multithread. Concorda com operação?" ##"Atenção"
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf


Return lRet  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JOBFINEnd   ºAutor  ³Microsiga           º Data ³  06/21/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Finaliza a Thread verificando se ocorrer help (erro)      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function JOBNFSEnd(cVarStatus,nHandle,lRet)
Local nX	:= 0
Local aLog  := {}
Local cMsg	:= ""
aLog  := GETAUTOGRLOG()

If !Empty(aLog)
	For nX := 1 to Len(aLog)
		cMsg := aLog[nX] 	
	Next
	UserException( "Error CTBNFS - " + cMsg )	
Else
	// STATUS 3 - Processado com Sucesso
	PutGlbValue(cVarStatus, "3" )
	GlbUnLock()
	NFSUnLock(nHandle,lRet)
Endif

Return Nil

/*/{Protheus.doc} SchedDef()
Preparação para rotinas automaticas por Schedule
@author SQUAD CRM FAT
@since 18/11/2021
@return 
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Local aReturn := { "P",;
				   "CTBNFS",;
					Nil,;
					Nil,;
					Nil ;
				}
						
Return aReturn
