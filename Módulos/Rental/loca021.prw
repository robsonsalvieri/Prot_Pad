#include "LOCA021.CH"
#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "PROTHEUS.CH"

/*/{PROTHEUS.DOC} LOCA021.PRW
ITUP BUSINESS - TOTVS RENTAL
FUNÇÃO UTILIZADA NA GERAÇÃO DOS PEDIDOS DE VENDA DO FATURAMENTO AUTOMÁTICO.
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION EXECAUTO 23/02/2024 - Frank Fuga DSERLOCA-1979
Existem clientes que usam como Job, mantivemos o funcionamento do mesmo na transformação para execauto.
/*/

Function LOCA021(_aParam , _cPrjIni , _cPrjFim , _aPrjAS, _lGeraPVx, _nTipoF, aExecAuto, aSelect)
Local AAREA
Local CCADASTRO  	:= STR0001 //" PROCESSA FATURAMENTO"
Local ASAYS      	:= {}
Local ABUTTONS   	:= {}
Local NOPC       	:= 0
Local lMvLocBac  	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local _lRetB     	:= .T.
Local lRet21        := .T.
Local aDefPar       := {}
Local cResult       := ""
Local lOff 			:= .F.
Local cLotex        := ""

Private OPROCESS
Private OGETPER
Private _CGETPER
Private CPERG    	:= "LOCP003"
Private APRJAS
Private _LGERA   	:= .T.
Private _LJOB    	:= ( _APARAM <> NIL .OR. VALTYPE(_APARAM) == "A" )
Private lLC21A      := .F.
Private cPacote 	:= "" // Frank 13/11/24
Private lSchedule   := FWIsInCallStack("LOCA021SC")
Private lMsg        := .T.
Private lPreviewX	:= .F.

	// Frank - 30/07/25 - ISSUE 7851
	// Tratamento para validação no execauto se é para executar apenas o preview do faturamento sem gerar nada.
	If type("lPreview") == "L"
		lPreviewX := lPreview
	EndIf

	If valtype(aExecAuto) == "A"
		If len(aExecAuto) > 0
			lLC21A := .T.
		EndIf
	EndIf

	aadd(aDefPar,.F.) // reservado indica que é rotina automatica -1
	aadd(aDefPar,{}) // retorno do processamento -2
	aadd(aDefPar,"") // cliente de -3
	aadd(aDefPar,"") // loja de -4
	aadd(aDefPar,Replicate("Z",TamSx3("A1_COD")[1])) // cliente ate -5
	aadd(aDefPar,Replicate("Z",TamSx3("A1_LOJA")[1])) // loja ate -6
	aadd(aDefPar,"") // equipamento de -7
	aadd(aDefPar,Replicate("Z",TamSx3("T9_CODBEM")[1])) // equipamento até -8
	aadd(aDefPar,"") // produto de -9
	aadd(aDefPar,Replicate("Z",TamSx3("B1_COD")[1])) // produto ate -10
	aadd(aDefPar,"") // obra de -11
	aadd(aDefPar,Replicate("Z",TamSx3("FPA_OBRA")[1])) // obra ate -12
	aadd(aDefPar,ctod("")) // data inicial -13
	aadd(aDefPar,ctod("01/01/5000")) // data final -14
	aadd(aDefPar,3) // tipo do mes de faturamento -15
	aadd(aDefPar,ctod("")) // gera em de -16
	aadd(aDefPar,ctod("01/01/5000")) // gera em ate -17
	aadd(aDefPar,1) // Processamento on-Line Frank em 11/11/24
	aadd(aDefPar,.F.) // lOff
	aadd(aDefPar,"") // cLoteX

	Default aExecAuto := aDefPar

	Default _CPRJINI  	:= ""
	Default _CPRJFIM  	:= ""
	Default _APRJAS   	:= {}
	Default _lGeraPVx 	:= .T.

	Private lLOC21Auto // Indica se o processamento é por rotina automática
	Private CPRJINI 	:= _CPRJINI
	Private CPRJFIM 	:= _cPrjFim
	Private nTipoF  	:= _nTipoF
	Private lGeraPVx	:= _lGeraPVx
	Private LOBRNFREM 	:= SUPERGETMV("MV_LOCX067",.F.,.T.)  		// --> OBRIGA OU NAO UMA NOTA FISCAL DE REMESSA PARA GERACAO DA NOTA DE FATURAMENTO AUTOMATICO.            PADRÃO: .T.

	Private _lTem12		:= .F.
	Private _lTem13		:= .F.
	Private _lTem14		:= .F.

	// DSERLOCA-2142 - Frank em 26/01/24
	Private MV_PAR15 	:= Nil
	Private MV_PAR16 	:= Nil
	Private MV_PAR17    := Nil // Tipo de Mês para faturamento - DSERLOCA-2600 - Frank em 12/03/24
	Private cErroAut    := ""
	Private lPrefer     := .F.
	Private nProcessa   := 1 // Tipo do faturamento onLine - Frank em 11/11/24
	Private aResult     := {} // Array de resultado { Pedido, Valor, Nota}
	Private lOffLine    := FWIsInCallStack("LOCA021GER")

	// Frank - 30/07/25 - ISSUE 7851
	// Tratamento para validação no execauto se é para executar apenas o preview do faturamento sem gerar nada.
	If lPreviewX
		lObrNfRem := .F.
	EndIf

	MV_PAR20 := 1 // Se não tiver pergunta vai ficar como 1 (On-Line)

	cClid  		:= aExecAuto[03]
	cClia  		:= aExecAuto[04]
	cLojd  		:= aExecAuto[05]
	cLoja  		:= aExecAuto[06]
	cEqud  		:= aExecAuto[07]
	cEqua  		:= aExecAuto[08]

	cProd  		:= aExecAuto[09]
	cProa  		:= aExecAuto[10]

	cObrd  		:= aExecAuto[11]
	cObra  		:= aExecAuto[12]
	dIni   		:= aExecAuto[13]
	dFim   		:= aExecAuto[14]
	nTpMes 		:= aExecAuto[15]
	dGeraem1	:= aExecAuto[16]
	dGeraem2 	:= aExecAuto[17]


	Private cClidAut := cClid
	Private cLojdAut := cLojd
	Private cCliaAut := cClia
	Private cLojaAut := cLoja
	Private cEqudAut := cEqud
	Private cEquaAut := cEqua
	Private cProdAut := cProd
	Private cProaAut := cProa
	Private cObrdAut := cObrd
	Private cObraAut := cObra
	Private dIniAut  := dIni
	Private dFimAut  := dFim
	Private nTpMAut  := nTpMes // Tipo de Mês para faturamento - DSERLOCA-2600 - Frank em 12/03/24
	Private dGera1   := dGeraem1
	Private dGera2   := dGeraem2
	Private nProcAut := nProcessa

	lLOC21Auto := lLC21A // Indica se o processamento é por rotina automática

	//cria tabelas caso não existam ainda
	If lMvLocBac
		AAREA := GetArea()
		DbSelectArea("FPY")
		DbSelectArea("FPZ")
		RestArea(AAREA)
	EndIf


	If !lLOC21Auto
		IF !AmIIn(94, 05, 19)
			Return .F.
		EndIF
	Endif

	PERGUNTE(CPERG,.F.)
	If type("MV_PAR12") == "C" .and. len(MV_PAR12) > 1
		_lTem12 := .T.
	EndIf
	If type("MV_PAR13") == "C" .and. len(MV_PAR13) > 1
		_lTem13 := .T.
	EndIf
	If type("MV_PAR14") == "N"
		_lTem14 := .T.
	EndIf

	// DSERLOCA-2142 - Frank em 26/01/24
	If type("MV_PAR15") <> "C"
		MV_PAR15 := Space(TamSX3("FPA_OBRA")[1])
		cPAR15 := MV_PAR15
	EndIf
	If type("MV_PAR16") <> "C"
		MV_PAR16 := Replicate("Z",TamSX3("FPA_OBRA")[1])
		cPAR16 := MV_PAR16
	EndIf
	If type("MV_PAR17") <> "N" // Tipo de Mês para faturamento - DSERLOCA-2600 - Frank em 12/03/24
		MV_PAR17 := 3
		cPAR17 := 3
	EndIf
	If type("MV_PAR18") <> "D" // Geraem de
		MV_PAR18 := ctod("")
		cPar18 := ctod("")
	EndIf
	If type("MV_PAR19") <> "D" // Geraem de
		MV_PAR19 := ctod("01/01/5000")
		cPar19 := ctod("01/01/5000")
	EndIf

	APRJAS := _APRJAS

	If lLOC21Auto .or. _lJob
		lRet21 := PROCFAT(lOff,cLotex,@cResult, aSelect)
	ELSE
		AAREA := GETAREA()
		IF EMPTY(_CPRJINI)
			PERGUNTE(CPERG,.F.)
			AADD(ASAYS,OEMTOANSI(STR0004)) //"ESTA ROTINA TEM POR OBJETIVO GERAR OS PEDIDOS DE VENDA"
			AADD(ASAYS,OEMTOANSI(STR0005)) //"REFERENTE AO PROCESSO DE FATURAMENTO."

			AADD(ABUTTONS, { 5,.T.,{|| PERGUNTE(CPERG,.T.) }} )
			AADD(ABUTTONS, { 1,.T.,{|O| NOPC:= 1,IIF( VALPROC() .AND. MSGYESNO(If(MV_PAR20=2,STR0128,"")+OEMTOANSI(STR0006),OEMTOANSI(STR0007)),O:OWND:END(),NOPC:=0) } } ) //"CONFIRMA PROCESSAMENTO?"###"ATENÇÃO" //"Foi escolhido o processamento OFF-LINE, "
			AADD(ABUTTONS, { 2,.T.,{|O| nOpc := 0, O:OWND:END() }} )

			FORMBATCH( CCADASTRO, ASAYS, ABUTTONS,,200,405 )
			if nOpc = 0
				Return
			endif
		ELSE
			MV_PAR01 := STOD("")
			MV_PAR02 := STOD(CVALTOCHAR(YEAR(DATE())+1)+"1231")
			MV_PAR03 := FP0->FP0_CLI
			MV_PAR04 := FP0->FP0_CLI
			MV_PAR05 := FP0->FP0_LOJA
			MV_PAR06 := FP0->FP0_LOJA
			MV_PAR07 := SPACE(16)
			MV_PAR08 := REPLICATE("Z",16)
			MV_PAR09 := _CPRJINI
			MV_PAR10 := _CPRJFIM
			MV_PAR11 := nTipoF
			If _lTem12
				MV_PAR12 := space(tamsx3("B1_COD")[1])
			EndIF
			If _lTem13
				MV_PAR13 := replicate("Z",tamsx3("B1_COD")[1])
			EndIF
			If _lTem14
				MV_PAR14 := 1 // Não habilitar a selecao em tela
			EndIF
			IF VALPROC() .AND. MSGYESNO(STR0008 + SUPERGETMV("MV_LOCX248",.F.,STR0009) + " " + ALLTRIM(FP0->FP0_PROJET) + "?") //"CONFIRMA O PROCESSAMENTO DO FATURAMENTO DO "###"PROJETO"
				NOPC := 1
			ENDIF
		ENDIF

		IF EXISTBLOCK("LOCA021B")
			_lRetB := EXECBLOCK("LOCA021B" , .T. , .T. )
			If !_lRetB
				If !lPrefer
					cErroAut := STR0121 //"Retorno negativado pelo ponto de entrada LOCA021B"
					Help("",1,"ABORT_FAT",,cErroAut,1,0)
				EndIF
				LMSERROAUTO := .T.
				Return .F.
			EndIf
		ENDIF

		IF NOPC == 1
			_CGETPER := MV_PAR01
			OPROCESS := MSAGUARDE( {|LEND| lRet21 := PROCFAT(lOff,cLotex,@cResult, aSelect)}  , STR0010    , If(MV_PAR20=2, STR0129, STR0011) , .F. )  //"AGUARDE..."###"GERANDO PEDIDOS DE VENDA..." //"Preparando processamento OFF-LINE..."
		ENDIF

		RESTAREA( AAREA )

	ENDIF

	If !lRet21 .and. lLOC21Auto .and. !lPreviewX
		Help("",1,"ERRO_FAT",,cErroAut,1,0)
	EndIF

RETURN (lRet21)

/*/{PROTHEUS.DOC} PROCFAT
@DESCRIPTION PROCESSA FATURAMENTO AUTOMÁTICO.
23/02/2024 - Revisão para funcionamento com msexecauto. Frank DSERLOCA-1979
/*/
STATIC FUNCTION PROCFAT(lOff,cLotex, cResult, aSelect)
Local _APARAM	:= {SM0->M0_CODIGO,SM0->M0_CODFIL}
Local CARQLOCK	:= "LCJLF001" + AllTrim(xFilial("SC5"))
Local lRet      := .T.

Private _LSEMLCJ  := SUPERGETMV("MV_LOCX252",.F.,.T.)
Private LOBRNFREM := SUPERGETMV("MV_LOCX067",.F.,.T.) // OBRIGA OU NAO UMA NOTA FISCAL DE REMESSA PARA GERACAO DA NOTA DE FATURAMENTO AUTOMATICO. PADRÃO: .T.
Private NHDLLOCK  := 0

	// Frank - 30/07/25 - ISSUE 7851
	// Tratamento para validação no execauto se é para executar apenas o preview do faturamento sem gerar nada.
	If lPreviewX
		lObrNfRem := .F.
	EndIf

	IF _LSEMLCJ
		// --> LOCK DE GRAVACAO DA ROTINA - MONOUSUARIO.
		If !LockByName( CARQLOCK, .F., .F. )
			IF !_LJOB .and. !lLOC21Auto
				MSGALERT(STR0014 + CARQLOCK + STR0015 +CRLF+CRLF+STR0016 , STR0017)  //"Concorrência de processo "###", rotina em uso."###"Aguarde o processo, ou avise o administrador do sistema."###"Rental"
			ENDIF
			If lLOC21Auto
				lMsErroAuto := .T.
				If !lPreviewX
					Help("",1,"ABORT_FAT",,STR0013,1,0) //"Rotina já em execução
				EndIf
			EndIF
			Return( .F. )
		EndIf
	ENDIF

	// --> PREPARA AMBIENTE DE PROCESSAMENTO.
	IF _LJOB
		IF FINDFUNCTION("WFPREPENV")
			WFPREPENV(_APARAM[1] , _APARAM[2])
		ELSE
			PREPARE ENVIRONMENT EMPRESA _APARAM[1] FILIAL _APARAM[2]
		ENDIF
	ENDIF

	lRet := GERAPV(_APARAM[1] , _APARAM[2], _LSEMLCJ, CARQLOCK, lOff, cLotex, @cResult, aSelect)

	IF _LSEMLCJ //.and. NHDLLOCK > 0
		// --> CANCELA O LOCK DE GRAVACAO DA ROTINA.
		UnLockByName( CARQLOCK, .F., .F. )
	ENDIF

RETURN (lRet)

/*/{PROTHEUS.DOC} GERAPV
@DESCRIPTION GERACAO DO(S) PEDIDO(S) DE VENDA DO FATURAMENTO AUTOMÁTICO.
23/02/2024 - Revisão para funcionamento com msexecauto. Frank DSERLOCA-1979
/*/
STATIC FUNCTION GERAPV(_CEMP , _CFIL, _LSEMLCJ, CARQLOCK, lOff, cLotex, cResult, aSelect)
Local _AAREAOLD   	:= GETAREA()
Local _AAREASC5   	:= SC5->(GETAREA())
Local _AAREASC6   	:= SC6->(GETAREA())
Local _AAREAZA0   	:= FP0->(GETAREA())
Local _AAREAZA1   	:= FP1->(GETAREA())
Local _AAREAZAG   	:= FPA->(GETAREA())
Local _AAREAZC1   	:= FPG->(GETAREA())
Local aItemFPZ		:= {}
Local aAgluNf		:= {}
Local _LCVAL      	:= SuperGetMv("MV_LOCX051",.F.,.T.)
Local LFATAND     	:= SuperGetMv("MV_LOCX209" ,.F.,.T.)
Local LFATLOC     	:= SuperGetMv("MV_LOCX210" ,.F.,.F.)
Local LFATURA     	:= SuperGetMv("MV_LOCX049"  ,.F.,.T.)		// FATURA O PEDIDO DE VENDAS?
Local LITEMFRT    	:= SuperGetMv("MV_LOCX241",.F.,.T.)
Local CMV_LOCX014  	:= ""
Local CITEMFRT    	:= SuperGetMv("MV_LOCX069" ,.T.,"" )
Local _CNATUREZ   	:= SuperGetMv("MV_LOCX065" ,.T.,"" )
Local _CTES       	:= SuperGetMv("MV_LOCX080" ,.T.,"" )
Local _CTESPRO    	:= SuperGetMv("MV_LOCX078" ,.T.,"" )
Local _ADADOS     	:= {}
Local _AITEMTEMP  	:= {}
Local _AZC1FAT    	:= {}
Local _LINCFRETE  	:= .F.
Local _CAS        	:= ""
Local _CASS       	:= ""
Local NITENS      	:= ""
Local nItemAglu     := 0
Local _CPROJET    	:= ""
Local _CQUERY     	:= ""
Local _CTXT       	:= ""
Local _DDTINI     	:= STOD("")
Local _DDTFIM     	:= STOD("")
Local NSA1RECNO   	:= 0
Local _NVALZC1    	:= 0
Local _NTOTZC1    	:= 0

Local _NVLRSEG    	:= 0
Local _NX         	:= 0
Local NVLR_OKD    	:= 0
Local _CTESEST    	:= " "
Local _CTEMP            // FRANK 22/10/20 GERACAO DOS PV RETORNO PARCIAL
//Local _LMENS      	:= .T.
Local _LPASSA     	:= .T.
Local _AAGLUTINA  	:= {}
Local aItemAGG		:= {}
Local aAgluRat		:= {}
Local _CCUSTOAG   	:= ""
Local _aDescCus   	:= {} // desconto no pedido de venda em decorrencia de existir custo extra negativo - Frank 15/02/21
Local _nDescCus   	:= 0  // valor do desconto - custo extra - Frank 15/02/21
Local _nDescX     	:= 0  // calculo do desconto total - Frank 15/02/21
Local _nDescY     	:= 0  // para exibir o quanto de desconto teve na mensagem dos pedidos gerados
Local _lDescCus   	:= .T. // Indica se o custo extra negativo foi processado - Frank 15/02/21
Local _nP
Local OOK         	:= LOADBITMAP(GETRESOURCES(),"LBOK")
Local ONO         	:= LOADBITMAP(GETRESOURCES(),"LBNO")
Local NJANELAL    	:= 1103
Local NLBTAML	    := 540
Local NLBTAMA	    := 145
Local OFILBUT
Local OCANBUT
Local OMARKBUT
Local cOpcx			:= "0"
Local _aSelecao		:= {}
Local _aSeleca2		:= {}
Local _lSelecao		:= .F.
Local _CLIBLOQ 		:= ExistBlock("CLIBLOQ")
Local _LCJLFINI 	:= ExistBlock("LCJLFINI")
Local _LOCA021C 	:= ExistBlock("LOCA021C")
Local _LOCA021D 	:= ExistBlock("LOCA021D")
Local _MV_LOC253 	:= SuperGetMv("MV_LOCX253",.T.,"515")
Local _MV_LOC080 	:= GETMV("MV_LOCX080")
Local _LCJTES 		:= ExistBlock("LCJTES")
Local _MV_LOCALIZ 	:= SuperGetMv("MV_LOCALIZ",.T.,"S")
Local _LCJLFITE 	:= ExistBlock("LCJLFITE")
Local _LCJLFFRT 	:= ExistBlock("LCJLFFRT")
Local _LOCA021A 	:= ExistBlock("LOCA021A")
Local _LCJNAT 		:= ExistBlock("LCJNAT")
Local _MV_LOC065 	:= GETMV("MV_LOCX065")
Local _LCJLFCAB 	:= ExistBlock("LCJLFCAB")
Local _MV_LOC278 	:= SuperGetMv("MV_LOCX278",,.T.)
Local _LCJATFPG 	:= ExistBlock("LCJATFPG")
Local _LCJATZAG 	:= ExistBlock("LCJATZAG")
Local _MV_LOC243 	:= SuperGetMv("MV_LOCX243",.F.,.F.)
Local _LCJATFIM 	:= ExistBlock("LCJATFIM")
Local cMvLOCX063	:= SuperGetMv("MV_LOCX063",.F.,"")
Local cMvLOCX064	:= SuperGetMv("MV_LOCX064",.F.,"")
Local _LOCA061Z 	:= ExistBlock("LOCA061Z")
Local lLOC021Y 		:= ExistBlock("LOCA021Y")
Local lLOC021W 		:= ExistBlock("LOCA021W")
Local cCliFat		:= ""
Local cLojFat		:= ""
Local cNomFat		:= ""
Local cPvProjet		:= ""
Local cPvObra		:= ""
Local cPvCliente	:= ""
Local cPvCliAux		:= ""
Local cPrdAgluNf	:= ""
Local cCodTab		:= ""
Local cAuxAS		:= ""
Local cAuxPerL 		:= ""
Local _CPAGTO		:= ""
Local dDtFim		:= StoD("")
Local lLOC021F 		:= ExistBlock("LOCA021F")
Local lLOC021G 		:= ExistBlock("LOCA021G")
Local lLOC021H 		:= ExistBlock("LOCA021H")
//Local lLOC021I 		:= ExistBlock("LOCA021I")
Local lLOC021J 		:= ExistBlock("LOCA021J")
Local lLOC021K 		:= ExistBlock("LOCA021K")
Local lLOC021L 		:= ExistBlock("LOCA021L")
Local lLOC021M 		:= ExistBlock("LOCA021M")
Local lLOC021N 		:= ExistBlock("LOCA021N")
Local lLOC021O 		:= ExistBlock("LOCA021O")
Local lLOC021P 		:= ExistBlock("LOCA021P") // Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
Local lLOC021Q 		:= ExistBlock("LOCA021Q") // Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
Local lLOC021S 		:= ExistBlock("LOCA021S") //
Local aComplex 		:= {} // Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
Local nX // Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
Local nPosPv		:= 0
Local nPosPrdAgl	:= 0
Local nAgluTot  	:= 0
Local nPosPerc		:= 0
Local nQtdItens		:= 0
Local nMaxItens 	:= 299
Local nParc1		:= 100
Local nTotAlguNf	:= 0
Local nTamItem		:= TAMSX3("C6_ITEM")[1]
Local lMvLocBac 	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local lLOC021R 		:= ExistBlock("LOCA021R") //  POnto de entrada do Circenis para Orguel
Local cLocx299 		:= GetMV("MV_LOCX299",,"")
Local cCondAtu 		:= ""  // Condição de Pagamento Atual
Local cProdNome 	:= ""
Local cCentrab 		:= ""
Local cCodFami 		:= ""
Local cPesq    		:= Space(50)
Local oPesq
Local _nPosItemX
Local lBlq
Local LOCA021E 		:= ExistBlock("LOCA021E") // dserloca-2408 - Frank em 23/02/2024
Local nValor		:= 0
Local lRet          := .T.
Local cNotAuto		:= ""
Local cSerAuto		:= ""
Local cPerAuto		:= ""
Local aBindParam    := {}
Local dGeraem       := ctod("") // DSERLOCA-2600 - Frank em 13/03/2024
Local lAglutinar    := .F. // Aglutinar os itens do Pedido
Local _AREGFQZ      := {}
Local lLCX049       := ExistBlock("LOCA2149")  
Local lRegra049     := .t.                     //  Para utilização no PE acima

//Local cAsOff		:= ""
//Local nOff1
//Local nOff2
Local aErro := {}
Local nTotPed := 0
Local aNota := {}

// Selecao dos contratos
Private _ASZ1		:= {}
Private	ODLGFIL
Private OFILOS

Private oCont
Private nContaReg	:= 0

Private DPAR01
Private DPAR02
Private CPAR03
Private CPAR04
Private CPAR05
Private CPAR06
Private CPAR07
Private CPAR08
Private CPAR09
Private CPAR10
Private CPAR11
Private CPAR12
Private CPAR13
Private CPAR14

// DSERLOCA-2142 Frank em 26/01/24
Private CPAR15
Private CPAR16

// Tipo de Mês para faturamento - DSERLOCA-2600 - Frank em 12/03/24
Private CPAR17
Private CPAR18
Private CPAR19
Private aFPZ			:= {}
Private aFPY			:= {}
Private cPar20 // Frank 11/11/24

Default _LSEMLCJ := .F.
Default CARQLOCK := ""

	MV_PAR020 := 1 // Inicia sempre com Processamento ON-LINE
	OOK := LOADBITMAP(GETRESOURCES(),"LBOK")
	ONO := LOADBITMAP(GETRESOURCES(),"LBNO")

	If !_lJob .and. !lLOC21Auto
		DPAR01 := IIF(Valtype(MV_PAR01) == 'D', MV_PAR01, StoD(Alltrim(MV_PAR01)))
		DPAR02 := IIF(Valtype(MV_PAR02) == 'D', MV_PAR02, StoD(Alltrim(MV_PAR02)))
		CPAR03 := MV_PAR03
		CPAR04 := MV_PAR04
		CPAR05 := MV_PAR05
		CPAR06 := MV_PAR06
		CPAR07 := MV_PAR07
		CPAR08 := MV_PAR08
		CPAR09 := MV_PAR09
		CPAR10 := MV_PAR10
		CPAR11 := MV_PAR11 // 1 - LOCAÇÃO; 2 - CUSTOS EXTRAS; 3 - AMBOS
		If _lTem12
			CPAR12 := MV_PAR12
		EndIF
		If _lTem13
			CPAR13 := MV_PAR13
		EndIF
		If _lTem14
			CPAR14 := MV_PAR14
		EndIF

		// DSERLOCA-2142 Frank em 26/01/24
		CPAR15 := MV_PAR15
		CPAR16 := MV_PAR16

		// Tipo de Mês para faturamento - DSERLOCA-2600 - Frank em 12/03/24
		CPAR17 := MV_PAR17
		CPAR18 := MV_PAR18
		CPAR19 := MV_PAR19
		cPar20 := MV_PAR20 // Frank 11/11/24

	Else

		If empty(dIniAut)
			dIniAut := ctod("01/01/2000")
		EndIf
		If empty(dFimAut)
			dFimAut := ctod("31/12/5000")
		EndIF

		If empty(cClidAut)
			cClidAut := space(TamSx3("A1_COD")[1])
		EndIF
		If empty(cCliaAut)
			cCliaAut := replicate("Z",TamSx3("A1_COD")[1])
		EndIF

		If empty(cLojdAut)
			cLojdAut := space(TamSx3("A1_LOJA")[1])
		EndIF
		If empty(cLojaAut)
			cLojaAut := replicate("Z",TamSx3("A1_LOJA")[1])
		EndIF

		If empty(cEqudAut)
			cEqudAut := space(TamSx3("T9_CODBEM")[1])
		EndIf
		If empty(cEquaAut)
			cEquaAut := replicate("Z",TamSx3("T9_CODBEM")[1])
		EndIf

		If empty(cProdAut)
			cProdAut := space(TamSx3("B1_COD")[1])
		EndIf
		If empty(cProaAut)
			cProaAut := replicate("Z",TamSx3("B1_COD")[1])
		EndIf

		If empty(cObrdAut)
			cObrdAut := space(TamSx3("FPA_OBRA")[1])
		EndIf
		If empty(cObraAut)
			cObraAut := replicate("Z",TamSx3("FPA_OBRA")[1])
		EndIf

		DPAR01 := dIniAut
		DPAR02 := dFimAut
		CPAR03 := cClidAut
		CPAR04 := cCliaAut
		CPAR05 := cLojdAut
		CPAR06 := cLojaAut
		CPAR07 := cEqudAut
		CPAR08 := cEquaAut
		CPAR09 := CPRJINI
		CPAR10 := CPRJFIM
		CPAR11 := nTipoF
		If _lTem12
			CPAR12 := cProdAut
		EndIF
		If _lTem13
			CPAR13 := cProaAut
		EndIF
		If _lTem14
			CPAR14 := 1
		EndIF

		IF lLOC021R // --> PONTO DE ENTRADA PARA ALTERAÇÃO DOS PARAMETROS DE CALCULO
			EXECBLOCK("LOCA021R" , .F. , .F. , )
		ENDIF

		// DSERLOCA-2142 Frank em 26/01/24
		CPAR15 := cObrdAut
		CPAR16 := cObraAut

		// Tipo de Mês para faturamento - DSERLOCA-2600 - Frank em 12/03/24
		CPAR17 := nTpMAut

		CPAR18 := dGera1
		CPAR19 := dGera2
		CPAR20 := nProcAut // Frank 11/11/24

	EndIf

	Private _AASS       := {}
	Private _ACABPV		:= {}
	Private _AITENSPV	:= {}
	Private APEDIDOS    := {}
	Private LFATREM     := SUPERGETMV("MV_LOCX235",.F.,.T.)  		// FATURA
	Private LCLIBLQ     := .F.
	Private LMSERROAUTO	:= .F.
	Private _LPRIMFAT   := .T.
	Private _CNUMPED 	:= SPACE(6)
	Private _NREG		:= 0
	Private _NREGPR		:= 0
	Private NVALLOC     := 0
	Private NVALTOT     := 0
	Private _NVLRFRETE	:= 0
	Private lItGeraRM	:= ExistBlock("ITGERARM")

	IF !EMPTY(_CTES)
		_CTESEST := POSICIONE("SF4" , 1 , XFILIAL("SF4")+_CTES , "F4_ESTOQUE")
		RESTAREA(_AAREAOLD)
		IF _CTESEST = "S"
			If !_LJOB .and. !lLOC21Auto
				IF !MSGYESNO(STR0020+_CTES+STR0021 , STR0017)  //"A TES ["###"], DEFINIDA NO PARÂMETRO 'MV_LOCX080', POSSUI MOVIMENTAÇÃO DE ESTOQUE E ESTA CONFIGURAÇÃO NÃO É RECOMENDADA, CONTINUA ASSIM MESMO ???"###"GPO - LCJLF001.PRW"
					RETURN .F.
				ENDIF
			EndIf
		ENDIF
	ENDIF

	IF SBM->(FIELDPOS("BM_XACESS")) > 0
		CMV_LOCX014 := LOCA00189()
	ELSE
		CMV_LOCX014 := SUPERGETMV("MV_LOCX014" , .F. , "")
	ENDIF

	SC5->( DBSETORDER(1) )
	FP1->( DBSETORDER(1) )

	IF CPAR11 == 1 .OR. CPAR11 == 3 // 1 - LOCAÇÃO / 3 - AMBOS

		IF SELECT("TMP") > 0
			TMP->( DBCLOSEAREA() )
		ENDIF

		IF lLOC021S	// --> PONTO DE ENTRADA PARA GERAR UMA TMP CUSTOMIZADA
			EXECBLOCK("LOCA021S" , .T. , .T. , )
			dbSelectArea("TMP")
		ELSE
			aBindParam := {}
			_cQuery := " SELECT ZAG.R_E_C_N_O_ ZAGRECNO, FP1.R_E_C_N_O_ FP1RECNO, ZA0.R_E_C_N_O_ ZA0RECNO, SB1.R_E_C_N_O_ SB1RECNO, SA1.R_E_C_N_O_ SA1RECNO, COALESCE(ST9.R_E_C_N_O_,0) ST9RECNO, FPA_PROJET , FPA_CONPAG, FP1_OBRA"
		//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
			_CQUERY += ", CASE"
			If FPA->(ColumnPos("FPA_CLIFAT")) > 0
				_CQUERY += " WHEN FPA_CLIFAT <> ' ' THEN FPA_CLIFAT"
			ENDIF
			_CQUERY += " WHEN FP1_CLIDES <> ' ' THEN FP1_CLIDES"
			_CQUERY += " ELSE FP0_CLI"
			_CQUERY += " END CLIFAT,"
			_CQUERY += " CASE"
			If FPA->(ColumnPos("FPA_CLIFAT")) > 0
				_CQUERY += " WHEN FPA_LOJFAT <> ' ' THEN FPA_LOJFAT"
			endif
			_CQUERY += " WHEN FP1_LOJDES <> ' ' THEN FP1_LOJDES"
			_CQUERY += " ELSE FP0_LOJA"
			_CQUERY += " END LOJFAT,
			_CQUERY += "  CASE "
			If FPA->(ColumnPos("FPA_CLIFAT")) > 0
				_CQUERY += " WHEN FPA_CLIFAT <> ' ' THEN FPA_NOMFAT"
			endif
			_CQUERY += " WHEN FP1_CLIDES <> ' ' THEN FP1_NOMDES"
			_CQUERY += " ELSE A1_NOME"
			_CQUERY += " END NOMFAT "
			_cQuery += " FROM "+RETSQLNAME("FPA")+" ZAG (NOLOCK) "
			_cQuery += " JOIN "+RETSQLNAME("SB1")+" SB1 (NOLOCK) ON B1_FILIAL ='"+XFILIAL("SB1")+"' AND SB1.D_E_L_E_T_ = '' AND B1_COD = FPA_PRODUT "
			_cQuery += " LEFT  JOIN "+RETSQLNAME("ST9")+" ST9 (NOLOCK) ON T9_FILIAL ='"+XFILIAL("ST9")+"' AND ST9.D_E_L_E_T_ = '' AND T9_CODBEM = FPA_GRUA "
			_cQuery += " JOIN "+RETSQLNAME("FP0")+" ZA0 (NOLOCK) ON FP0_FILIAL='"+XFILIAL("FP0")+"' AND ZA0.D_E_L_E_T_ = '' AND FP0_PROJET = FPA_PROJET AND "
			// DSERLOCA-2394 - Frank em 20/02/2024
			_cQuery += " FP0_TIPFAT <> 'M' "

			// DSERLOCA-2142 - Frank
			_cQuery += " AND (FP0_STATUS = '1' OR FP0_STATUS = '5') "
			_cQuery += " JOIN "+RETSQLNAME("FP1")+" FP1 (NOLOCK) ON FP1_FILIAL='"+XFILIAL("FP1")+"' AND FP1.D_E_L_E_T_  = ' ' AND FP1_PROJET = FPA_PROJET AND FP1_OBRA = FPA_OBRA "

			// DSERLOCA-2142 Frank em 26/01/24
			//cTempq := " AND FP1_OBRA >= '"+cPAR15+"' AND FP1_OBRA <= '"+cPAR16+"' "
			//&('_cQuery += cTempq')
			_cQuery += " AND FP1_OBRA >= ? AND FP1_OBRA <= ? "
			aadd(aBindParam,cPAR15)
			aadd(aBindParam,cPAR16)

			If cPAR17 == 1 // Tipo de mês mensal - DSERLOCA-2600 - Frank em 12/03/24
				_cQuery += " AND (FP1_TPMES = '0' OR FP1_TPMES = '2') "
			EndIf
			If cPAR17 == 2 // Tipo de mês corrido - DSERLOCA-2600 - Frank em 12/03/24
				_cQuery += " AND FP1_TPMES = '1' "
			EndIf

			_cQuery += " JOIN "+RETSQLNAME("SA1")+" SA1 (NOLOCK) ON A1_FILIAL ='"+XFILIAL("SA1")+"' AND SA1.D_E_L_E_T_ = ' ' AND A1_COD = FP0_CLI AND A1_LOJA = FP0_LOJA "
			If !lPreviewX
				_cQuery += " INNER JOIN "+RETSQLNAME("FQ5")+" DTQ (NOLOCK) ON FQ5_FILIAL='"+XFILIAL("FQ5")+"' AND DTQ.D_E_L_E_T_ = ' ' AND FQ5_FILORI = FPA_FILIAL AND FQ5_VIAGEM = FPA_VIAGEM AND FQ5_AS = FPA_AS AND FQ5_STATUS = '6' "
			Else
				_cQuery += " INNER JOIN "+RETSQLNAME("FQ5")+" DTQ (NOLOCK) ON FQ5_FILIAL='"+XFILIAL("FQ5")+"' AND DTQ.D_E_L_E_T_ = ' ' AND FQ5_FILORI = FPA_FILIAL AND FQ5_VIAGEM = FPA_VIAGEM AND FQ5_AS = FPA_AS AND (FQ5_STATUS = '6' OR FQ5_STATUS = '3' OR FQ5_STATUS = '1' ) "
			EndIf
			_cQuery += " WHERE FPA_FILIAL = '"+XFILIAL("FPA")+"' "
			_cQuery += " AND FPA_DTFIM <> ' '"

			If FPZ->(FIELDPOS("FPZ_GERAEM")) > 0 .and. FPA->(FIELDPOS("FPA_GERAEM")) > 0
				_cQuery += " AND FPA_GERAEM BETWEEN ? AND ? "
				aadd(aBindParam,DTOS(CPAR18))
				aadd(aBindParam,DTOS(CPAR19))
			EndIF

			// DSERLOCA-2142 Frank em 26/01/24
			_cQuery += " AND FPA_AS <> '' "
			_cQuery += " AND FPA_DTFIM BETWEEN ? AND ? "
			aadd(aBindParam,DTOS(DPAR01))
			aadd(aBindParam,DTOS(DPAR02))

			If ! LFATAND
				_cQuery += " AND (FPA_DNFRET = ' ' OR FPA_DNFRET >= ? )"
				aadd(aBindParam,DTOS(DPAR01))
			EndIf

			_cQuery     += " AND ((FPA_ULTFAT < ? "
			aadd(aBindParam,DTOS(DPAR02))

			// selecionar ultfat < retirada pois igual indica que já faturou até a data - Rossana - 17/12 - DSERLOCA
//			_cQuery     +=" AND (FPA_ULTFAT < FPA_DTSCRT OR FPA_DTSCRT = '')) OR FPA_ULTFAT = ' ')"
			_cQuery     +=" AND (FPA_ULTFAT < FPA_DTSCRT OR FPA_DTSCRT = '')) OR FPA_ULTFAT = ' ')"

			IF LOBRNFREM  			// --> MV_LOCX067 - OBRIGA OU NAO UMA NOTA FISCAL DE REMESSA PARA GERACAO DA NOTA DE FATURAMENTO AUTOMATICO.            PADRÃO: .T.

				// DSERLOCA-2875 - Frank Fuga em 09/04/2024
				// Alteração no formato de encontrar se existe uma nota de remessa
				_cQuery += " AND ( FPA_NFREM <> '' OR FPA_TIPOSE <> 'L' ) "
			ENDIF
			IF FPA->(FIELDPOS("FPA_PDESC")) > 0
				_cQuery += " AND  FPA_PDESC < 100"
			ENDIF
			_cQuery += " AND (FPA_TIPOSE <> 'L' OR FPA_GRUA BETWEEN ? AND ? ) "
			aadd(aBindParam,CPAR07)
			aadd(aBindParam,CPAR08)

			_cQuery += " AND FPA_PROJET BETWEEN ? AND ? "
			aadd(aBindParam,CPAR09)
			aadd(aBindParam,CPAR10)

			// Novos filtros do produto e acerto do funcionamento do filtro dos bens - Frank em 08/09/21
			If _lTem12 .and. _lTem13
				_cQuery += " AND FPA_PRODUT BETWEEN ? AND ? "
				aadd(aBindParam,CPAR12)
				aadd(aBindParam,CPAR13)
			EndIF
			_cQuery += " AND FPA_GRUA BETWEEN ? AND ? "
			aadd(aBindParam,CPAR07)
			aadd(aBindParam,CPAR08)

			IF LFATLOC
				_cQuery += " AND FPA_TIPOSE = 'L' "
			ELSE
				_cQuery += " AND FPA_TIPOSE IN ('L','M','Z','O') "
			ENDIF
			IF LEN(APRJAS) > 0
				FOR _NX := 1 TO LEN(APRJAS)
					IF EMPTY(_CASS)
						_CASS := "'"   + APRJAS[_NX]
					ELSE
						_CASS += "','" + APRJAS[_NX]
					ENDIF
					IF _NX == LEN(APRJAS)
						_CASS += "'"
					ENDIF
				NEXT _NX
				_cQuery += " AND  FPA_AS IN ("
				&('_cQuery +=_CASS')
				_cQuery +=") "
			ENDIF

			_cQuery += " AND  ZAG.D_E_L_E_T_ = '' "
			_cQuery += " ORDER BY 	FPA_PROJET, FPA_OBRA,  "
			_cQuery += " CLIFAT, LOJFAT, FPA_CONPAG, FPA_AS"  // ORDENADO POR CLIENTE para facilitar a quebra posterior do PV

			_cQuery := CHANGEQUERY(_cQuery)

			MPSysOpenQuery(_cQuery,"TMP",,,aBindParam)

		endif


		DBSELECTAREA("TMP")
		DBGOTOP()

		// Tela para seleção dos registros Frank em 27/10/21
		If !_lJob .and. _lTem14 .and. !lLOC21Auto // se não for job e existe o pergunte da selecao
			If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
				If cPar11 <> 3 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
					// Selecionar os contratos
					_ASZ1 := {}
					While !TMP->(Eof())
						FPA->( DBGOTO(TMP->ZAGRECNO) )
						FP1->( DBGOTO(TMP->FP1RECNO) )
						SA1->( DBGOTO(TMP->SA1RECNO) )

						//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
						cCliFat := TMP->CLIFAT
						cLojFat := TMP->LOJFAT
						cNomFat := TMP->NOMFAT

						If !Empty(FPA->FPA_DTSCRT) 
							If FPA->FPA_DTSCRT < FPA->FPA_DTINI
								TMP->(dbSkip())
								Loop
							EndIf
						EndIf

						// Filtro do cliente após a identificação do clifat - Frank em 04/07/23
						If cCliFat < cPar03 .or. cCliFat > cPar04
							TMP->(dbSkip())
							Loop
						EndIF
						If cLojFat < cPar05 .or. cLojFat > cPar06
							TMP->(dbSkip())
							Loop
						EndIF

						SB1->(dbSetorder(1))
						SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
						If !lPreviewX
							If FPA->FPA_TIPOSE == "Z" .and. !empty(FPA->FPA_ULTFAT)
								TMP->(dbSkip())
								Loop
							EndIF
						//Else
						//	If FPA->FPA_TIPOSE == "Z" .and. !empty(dUltFat248)
						//		TMP->(dbSkip())
						//		Loop
						//	EndIF
						EndIF

						cProdNome := SB1->B1_DESC
						cCentrab := ""
						cCodFami := ""
						If !empty(FPA->FPA_GRUA)
							ST9->(dbSetOrder(1))
							If ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
								cProdNome := ST9->T9_NOME
								cCodFami := ST9->T9_CODFAMI
								If !empty(ST9->T9_CENTRAB)
									SHB->(dbSetOrder(1))
									If SHB->(dbSeek(xFilial("SHB")+ST9->T9_CENTRAB))
										cCenTrab := SHB->HB_NOME
									EndIF
								EndIF
							EndIF
						EndIF

						aadd(_ASZ1,{.T.,;
							FPA->FPA_OBRA,;
							FPA->FPA_SEQGRU,;
							FPA->FPA_PRODUT,;
							FPA->FPA_GRUA,;
							cProdNome,;
							FPA->FPA_QUANT,;
							FPA->FPA_PRCUNI,;
							FPA->FPA_PDESC,;
							FPA->FPA_VRHOR,;
							FPA->FPA_DTINI,;
							FPA->FPA_DTFIM,;
							FPA->FPA_DTENRE,;
							FPA->FPA_ULTFAT,;
							FPA->FPA_CONPAG,;
							cCodFami,;
							cCenTrab,;
							FPA->FPA_FILEMI,;
							FPA->FPA_NFREM,;
							FPA->FPA_SERREM,;
							FPA->FPA_NFRET,;
							FPA->FPA_SERRET,;
							FPA->FPA_AS,;
							cCliFat,;
							cLojFat,;
							cNomFat,;
							TMP->ZAGRECNO,;
							FPA->FPA_PROJET,;
							FPA->FPA_DTSCRT})

						nContaReg++

						// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
						IF lLOC021P
							aCompleX := EXECBLOCK("LOCA021P" , .T. , .T. , {1} )
							If len(aComplex) > 0
								For nX := 1 to len(aComplex[1])
									aadd(_aSZ1[len(_ASZ1)],aComplex[1,nX])
								Next
							EndIF
						ENDIF

						TMP->(dbSkip())
					EndDo

					If len(_aSZ1) == 0
						If !lPreviewX
							MsgAlert(STR0085,STR0007) // Não houve registro para a selecao###Atencao
						EndIf
						If !lPrefer
							cErroAut := STR0085 // Não houve registro para a selecao
						EndIF
						LMSERROAUTO := .T.
						Return .F.
					EndIF

					cOpcx := "0"
					_aSelecao := {}
					//NJANELAA
					DEFINE MSDIALOG ODLGFIL TITLE STR0076 FROM 010,005 TO 500,NJANELAL PIXEL//Seleção dos projetos
					@ 1.5,0.7 LISTBOX OFILOS FIELDS HEADER  " ",;
						STR0115,; //"Projeto"
					STR0090,; //"Obra"
					STR0091,; //"Seq."
					STR0092,; //"Produto"
					STR0093,; //"Bem"
					STR0094,; //"Descrição"
					STR0095,; //"Quantidade"
					STR0096,; //"Vlr.Unit."
					STR0097,; //"% Desc"
					STR0098,; //"Vlr. Base"
					STR0099,; //"Dt.Ini."
					STR0101,; //"Prox.Fat."
					STR0100,; //"Dt.Fim"
					STR0102,; //"Ult.Fat."
					STR0103,; //"Cond.Pag."
					STR0104,; //"Família"
					STR0105,; //"Descrição Centrab."
					STR0106,; //"Fil.Remessa"
					STR0107,; //"Nf.Remessa"
					STR0108,; //"Série Remessa"
					STR0109,; //"Nf.Retorno"
					STR0110,; //"Série Retorno"
					STR0111,; //"AS"
					STR0112,; //"Cod.Cliente"
					STR0113,; //"Loja"
					STR0114,; //"Nome"
					STR0116,; //"Dt.Sol.Retira"
					""; // Recno
					SIZE NLBTAML,NLBTAMA+55 ON DBLCLICK (MARCARREGI(.F.))
					// antigo Projeto, Obra, AS, Cod.Produto, Descricao, "Cod.Cliente","Loja","Nome"

					// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
					IF lLOC021Q
						aCompleX := EXECBLOCK("LOCA021Q" , .T. , .T. , {1} )
						If len(aComplex) > 0
							For nX := 1 to len(aComplex[1])
								aadd(OFILOS:aHeaders,aComplex[1,nX])
							Next
						EndIF
					ENDIF
					OFILOS:SETARRAY(_ASZ1)

					cLinha := "{|| { IF( _ASZ1[OFILOS:NAT,1],OOK,ONO),"
					cLinha += "_ASZ1[OFILOS:NAT,28],"
					cLinha += "_ASZ1[OFILOS:NAT,2],"
					cLinha += "_ASZ1[OFILOS:NAT,3],"
					cLinha += "_ASZ1[OFILOS:NAT,4],"
					cLinha += "_ASZ1[OFILOS:NAT,5],"
					cLinha += "_ASZ1[OFILOS:NAT,6],"
					cLinha += "_ASZ1[OFILOS:NAT,7],"
					cLinha += "_ASZ1[OFILOS:NAT,8],"
					cLinha += "_ASZ1[OFILOS:NAT,9],"
					cLinha += "_ASZ1[OFILOS:NAT,10],"
					cLinha += "_ASZ1[OFILOS:NAT,11],"
					cLinha += "_ASZ1[OFILOS:NAT,12],"
					cLinha += "_ASZ1[OFILOS:NAT,13],"
					cLinha += "_ASZ1[OFILOS:NAT,14],"
					cLinha += "_ASZ1[OFILOS:NAT,15],"
					cLinha += "_ASZ1[OFILOS:NAT,16],"
					cLinha += "_ASZ1[OFILOS:NAT,17],"
					cLinha += "_ASZ1[OFILOS:NAT,18],"
					cLinha += "_ASZ1[OFILOS:NAT,19],"
					cLinha += "_ASZ1[OFILOS:NAT,20],"
					cLinha += "_ASZ1[OFILOS:NAT,21],"
					cLinha += "_ASZ1[OFILOS:NAT,22],"
					cLinha += "_ASZ1[OFILOS:NAT,23],"
					cLinha += "_ASZ1[OFILOS:NAT,24],"
					cLinha += "_ASZ1[OFILOS:NAT,25],"
					cLinha += "_ASZ1[OFILOS:NAT,26],"
					cLinha += "_ASZ1[OFILOS:NAT,29],"
					cLinha += "_ASZ1[OFILOS:NAT,27]"
					// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
					IF lLOC021Q
						aCompleX := EXECBLOCK("LOCA021Q" , .T. , .T. , {1} )
						If len(aComplex) > 0
							nComple := 29
							For nX := 1 to len(aComplex[1])
								nComple ++
								cLinha += ",_ASZ1[OFILOS:NAT,"+alltrim(str(nComple))+"]"
							Next
						EndIF
					ENDIF
					cLinha += "}}"

					OFILOS:BLINE := &(cLinha)

					@ 230,007 BUTTON OMARKBUT PROMPT STR0089 SIZE 55,12 OF ODLGFIL PIXEL ACTION (MARCARREGI(.T.)) //"(Des)marcar todos"
					@ 230,062 BUTTON OFILBUT  PROMPT STR0082 SIZE 55,12 OF ODLGFIL PIXEL ;  //"GERA FATURAMENTO"
					ACTION ( IIF(MSGYESNO(OEMTOANSI(STR0083) , STR0007) , ;  //"Confirma a geracao do faturamento?"###"Atencao"
					cOpcx := "1"  , ;
						cOpcx := "0") , ;
						ODLGFIL:END() )
					@ 230,117 BUTTON OCANBUT PROMPT STR0084             SIZE 55,12 OF ODLGFIL PIXEL ACTION (cOpcx := "0", ODLGFIL:END()) //"CANCELAR"
					@ 233,485 Say "Marcados " SIZE 50,10 PIXEL OF ODLGFIL 
					@ 230,515 MsGet oCont Var nContaReg SIZE 25,10 PIXEL OF ODLGFIL WHEN .F.
					@ 003,002 MsGet oPesq Var cPesq Size 342,009 COLOR CLR_BLACK PIXEL OF ODLGFIL
					@ 003,345 Button STR0117 Size 043,012 PIXEL OF ODLGFIL Action IF(!Empty(OFILOS:aArray[OFILOS:nAt][2]),ITPESQ(OFILOS,cPesq),Nil) //Localiza
					ACTIVATE MSDIALOG ODLGFIL CENTERED

					// Validar se selecionou pelo menos um contrato
					If cOpcx == "0"
						If !lPrefer
							cErroAut := STR0085 // Não houve registro para a selecao
						EndIF
						LMSERROAUTO := .T.
						Return .F.
					Else
						For _nX := 1 to len(_aSZ1)
							If _aSZ1[_nX,1]
								aadd(_aSelecao,{_aSZ1[_nX][27]})
							EndIF
						Next
					EndIF
					If len(_aSelecao) == 0
						If !lPrefer
							cErroAut := STR0085 // Não houve registro para a selecao
						EndIF
						LMSERROAUTO := .T.
						Return .F.
					EndIF

					// dserloca-2408 - Frank em 23/02/2024
					If LOCA021E
						If !EXECBLOCK("LOCA021E" , .T. , .T. , {_aSelecao,"1",_aSZ1} )
							If !lPrefer
								cErroAut := STR0085 // Não houve registro para a selecao
							EndIf
							LMSERROAUTO := .T.
							Return .F.
						EndIF
					EndIf

				Else
					MsgAlert(STR0075,STR0017) //A opção ambos não permite a seleção dos contratos.###Rental
					If !lPrefer
						cErroAut := STR0075 //A opção ambos não permite a seleção dos contratos.
					EndIf
					LMSERROAUTO := .T.
					Return .F.
				EndIF
			EndIf
		EndIF

		If MV_PAR20 = 2 .and. !lLOC21Auto .and.! _lJob // Escolheu deixar o processamento OFF-LINE
			// Gera registro na tabela de Jobs
			LOCA021OFF(MV_PAR09, MV_PAR10, MV_PAR11, _aSelecao)
			Return
		endif

		if !Empty(aSelect)
			_aSelecao := aSelect
		endif

		DBSELECTAREA("TMP")
		DBGOTOP()

		WHILE TMP->( !EOF() )

			If !_lJob .and. _lTem14 .and. !lLOC21Auto // se não for job e existe o pergunte da selecao
				If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
					If cPar11 <> 3 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
						_lSelecao := .F.
						If len(_aSelecao) > 0
							For _nX:=1 to len(_aSelecao)
								If _aSelecao[_nX][1] == TMP->ZAGRECNO
									_lSelecao := .T.
									Exit
								EndIF
							Next
						EndIF
						If !_lSelecao
							TMP->(dbSkip())
							Loop
						EndIF
					EndIF
				EndIF
			EndIF

			FPA->( DBGOTO(TMP->ZAGRECNO) )
			FP1->( DBGOTO(TMP->FP1RECNO) )
			FP0->( DBGOTO(TMP->ZA0RECNO) )
			SA1->( DBGOTO(TMP->SA1RECNO) )

			//CONOUT("[INICIO ] " + FPA->FPA_PROJET + " " + TIME())
			NSA1RECNO := TMP->SA1RECNO

			//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
			cPvCliente := TMP->(CLIFAT+LOJFAT)
			cCliFat := TMP->CLIFAT
			cLojFat := TMP->LOJFAT

			// Filtro do cliente após a identificação do clifat - Frank em 04/07/23
			If substr(cPvCliente,1,tamsx3("A1_COD")[1]) < cPar03 .or. substr(cPvCliente,1,tamsx3("A1_COD")[1]) > cPar04
				TMP->(dbSkip())
				Loop
			EndIF
			If substr(cPvCliente,tamsx3("A1_COD")[1]+1,tamsx3("A1_LOJA")[1]) < cPar05 .or. substr(cPvCliente,tamsx3("A1_COD")[1]+1,tamsx3("A1_LOJA")[1]) > cPar06
				TMP->(dbSkip())
				Loop
			EndIF

			SA1->(DbSetOrder(1))
			/*If SA1->(DbSeek(xFilial("SA1") + cPvCliente))
			Else
				Help(NIL, NIL, "LOCA021_1", NIL, STR0119, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0120 + AllTrim(FPA->FPA_PROJET) + " | Obra: " + FPA->FPA_OBRA + STR0126 + FPA->FPA_SEQGRU}) //"Cliente não localizado"###"Informe um cliente válido no Projeto "###" | Seq: "
				If !lPrefer
					cErroAut := STR0119 //"Cliente não localizado"
				EndIf
				LMSERROAUTO := .T.
				Return .F.
			EndIf*/

			IF _CLIBLOQ
				If EXECBLOCK("CLIBLOQ" , .T. , .T. , {FP0->FP0_CLI , FP0->FP0_LOJA , .T.})
					TMP->( DBSKIP() )
					LOOP
				ENDIF
			ENDIF

			LCLIBLQ := ( SA1->A1_MSBLQL == "1" )

			IF LCLIBLQ
				IF RECLOCK("SA1", .F.)
					SA1->A1_MSBLQL := "2"
					SA1->(MSUNLOCK())
				ENDIF
			ENDIF

			_ADADOS	   := {}
			_AITENSPV  := {}
			NITENS	   := replicate("0",TamSx3("C6_ITEM")[1]) // Frank em 27/12/2022 chamado 612 antes estava ""
			_NVLRFRETE := 0
			_NVLRSEG   := 0
			NPESO      := 0
			If lGeraPVx
				_CNUMPED := ""
			Else
				_CNUMPED := ""
			EndIF

			_AASS      := {}
			_CPROJET   := FPA->FPA_PROJET
			//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
			cPvProjet 	:= TMP->FPA_PROJET
			cPvObra 	:= FP1->FP1_OBRA
			cPvCliAux	:= cPvCliente
			nQtdItens	:= 0 //SIGALOC94-665 - Jose Eulalio - Gerar mais de um PV quando tiver mais de 300 linhas sendo processada
			cCondAtu    := FPA->FPA_CONPAG
			_lDescCus := .F. // controle dos descontos por custo extra - Frank 15/02/21 / Frank 19/11/21
			_aDescCus := {}
			aAgluNf   := {} // Itens Aglutinados
			aAgluRat  := {} // Reteio de Aglutinação

			If lMvLocBac // Vai Gera FPY e FPZ
				aFPY := {}
				AFPZ := {}
			endif
			lAglutinar := FP0->(FieldPos("FP0_AGLUNF")) > 0 .And. FP0->FP0_AGLUNF == "1"
			//realiza quebra dos itens
			//WHILE TMP->( !EOF() ) .AND. _CPROJET == TMP->FPA_PROJET
			//nova forma de quebra a partir de SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
			//SIGALOC94-665 - Jose Eulalio - Gerar mais de um PV quando tiver mais de 300 linhas sendo processada
			//QUEBRA PEDIDO POR PROJETO / OBRA / CLIENTE / QTD ITENS (299)
			// Ao aglutinar não há limite de itens
			WHILE TMP->( !EOF() ) .AND. cPvProjet == TMP->FPA_PROJET .And. cPvObra == TMP->FP1_OBRA .And. cPvCliente == cPvCliAux .And. IF(lAglutinar, .T. , nQtdItens < nMaxItens) .and. TMP->FPA_CONPAG == cCondAtu

				//soma para garantir menos de 300 itens por pedido
				nQtdItens++

				FPA->( DBGOTO( TMP->ZAGRECNO ) )
				FP1->( DBGOTO( TMP->FP1RECNO ) )

				If !_lJob .and. _lTem14 .and. !lLOC21Auto // se não for job e existe o pergunte da selecao
					If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
						If cPar11 <> 3 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
							_lSelecao := .F.
							If len(_aSelecao) > 0
								For _nX:=1 to len(_aSelecao)
									If _aSelecao[_nX][1] == TMP->ZAGRECNO
										_lSelecao := .T.
										Exit
									EndIF
								Next
							EndIF

							nForca := 0
							IF lLOC021F
								nForca := EXECBLOCK("LOCA021F" , .T. , .T. , {} )
							ENDIF

							If !_lSelecao .or. nForca > 0
								TMP->(dbSkip())
								//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
								If TMP->( !EOF() )
									FPA->( DBGOTO( TMP->ZAGRECNO ) )
									FP1->( DBGOTO( TMP->FP1RECNO ) )
									//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
									cPvCliAux :=TMP->(CLIFAT + LOJFAT)
								EndIf
								Loop
							EndIF
						EndIF
					EndIF
				EndIF

				SB1->( DBGOTO( TMP->SB1RECNO ) )
				ST9->( DBGOTO( TMP->ST9RECNO ) )
				_CAS		:= FPA->FPA_AS
				_LPRIMFAT   := PRIMFAT(_CAS)

				nForca := 0
				IF lLOC021G
					nForca := EXECBLOCK("LOCA021G" , .T. , .T. , {} )
				ENDIF

				IF !_LPRIMFAT .AND. ALLTRIM(FPA->FPA_TIPOSE) $ "Z#O" .or. nForca > 0
					TMP->(DBSKIP())
					//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
					If TMP->( !EOF() ) .or. nForca > 0
						FPA->( DBGOTO( TMP->ZAGRECNO ) )
						FP1->( DBGOTO( TMP->FP1RECNO ) )
						//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
						cPvCliAux := TMP->(CLIFAT + LOJFAT)

					EndIf
					LOOP
				ENDIF

				IF _LCJLFINI //EXISTBLOCK("LCJLFINI")
					EXECBLOCK("LCJLFINI" , .T. , .T. , NIL)
				ENDIF

				_DDTINI := STOD("")
				_DDTFIM := STOD("")

				DO CASE
				CASE FPA->FPA_TPBASE == "M"
					NDIASTRB := 30
				CASE FPA->FPA_TPBASE == "Q"
					NDIASTRB := 15
				CASE FPA->FPA_TPBASE == "S"
					NDIASTRB :=  7
				OTHERWISE
					DO CASE
					CASE FPA->( FIELDPOS("FPA_LOCDIA") ) > 0
						NDIASTRB := FPA->FPA_LOCDIA
					CASE FPA->( FIELDPOS("FPA_PREDIA") ) > 0
						NDIASTRB := FPA->FPA_PREDIA
					OTHERWISE
						NDIASTRB := FPA->FPA_DTENRE - FPA->FPA_DTINI + 1
					ENDCASE
				ENDCASE

				//	FP1_TPMES --- "0" = FECHADO  E  "1" = ABERTO e '2' = Fixo

				NVALLOC := (FPA->FPA_VRHOR/NDIASTRB) // TRANSFORMA O VALOR MENSAL EM VALOR DIÁRIO DA LOCAÇÃO CONSIDERANDO O PADRÃO DE 30 DIAS
				
				If !lPreviewX
					DULTFAT	 := FPA->FPA_DTFIM
					DPROXFAT := (FPA->FPA_DTFIM + NDIASTRB + 1)
				Else
					DULTFAT	 := dDtFim248
					DPROXFAT := (dDtFim248 + NDIASTRB + 1)
				EndIf

				If !lPreviewX
					IF EMPTY(FPA->FPA_ULTFAT)
						_DDTINI := FPA->FPA_DTINI
					ELSE
						_DDTINI := FPA->FPA_ULTFAT + 1
					ENDIF
				Else
					IF EMPTY(dUltFat248)
						_DDTINI := FPA->FPA_DTINI
					ELSE
						_DDTINI := dUltFat248 + 1
					ENDIF
				EndIf

				NVALLOC := FPA->FPA_VRHOR

				IF FP1->FP1_TPMES == "0"				// MES FECHADO
					NDIASTRB := 30 // quantidade de dias do mês fechado que foi usado
					_nDiasX  := 30 // quantidade de dias do fator do periodo

					// ATENCAO: se alterar a forma de encontrar o _dDtFim e DUltFat e dProcFat
					// precisa ser replicado para o mes fixo TPMES = 2

					IF _LOCA021C //EXISTBLOCK("LOCA021C") // ponto de entrada para alteracao dos dias fixos = 30
						NDIASTRB := EXECBLOCK("LOCA021C" , .T. , .T. )
						_nDiasX  := EXECBLOCK("LOCA021C" , .T. , .T. )
					ENDIF

					If !lPreviewX
						_DDTFIM  := FPA->FPA_DTFIM
					Else
						_DDTFIM  := dDtFim248
					EndIF

					DULTFAT  := _DDTFIM
					DPROXFAT := MONTHSUM(DULTFAT,1)

					// somente se o dia for 30 e proximo mes 31
					// se for 29 de janeiro validar o maior dia de fevereiro
					// frank em 20/07/22 - ajuste do ultimo dia do mes fechado
					If day(dProxFat) == 30 .or. (month(dUltfat) == 1 .and. day(dultfat) == 28)  .or. (month(dUltfat) == 2 .and. (day(dultfat) == 28.or.day(dultfat) == 29))
						nMes := month(dproxfat)
						while nMes == month(dproxfat)
							dProxFat ++
						EndDo
						dproxfat := dproxfat - 1
					EndIf

					// Frank em 20/07/22 - somente quando for segundo faturamento em diante
					// considerar os dias corretos para o calculo
					If !lPreviewX
						IF !EMPTY(FPA->FPA_ULTFAT)
							NDIASTRB := _DDTFIM - _DDTINI + 1
							NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
						EndIf
						IF EMPTY(FPA->FPA_ULTFAT) //.AND. ((_DDTFIM - _DDTINI) + 1) < _nDiasX   //DAY(_DDTINI) - 1 <> DAY(_DDTFIM)
							NDIASTRB := _DDTFIM - _DDTINI + 1
							NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
						ENDIF
					Else
						IF !EMPTY(dUltFat248)
							NDIASTRB := _DDTFIM - _DDTINI + 1
							NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
						EndIf
						IF EMPTY(dUltFat248) //.AND. ((_DDTFIM - _DDTINI) + 1) < _nDiasX   //DAY(_DDTINI) - 1 <> DAY(_DDTFIM)
							NDIASTRB := _DDTFIM - _DDTINI + 1
							NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
						ENDIF
					EndIf			

					IF !EMPTY(FPA->FPA_DTSCRT)
						IF FPA->FPA_DTSCRT < _DDTFIM
							nValLoc := FPA->FPA_VRHOR
							NDIASTRB := FPA->FPA_DTSCRT - _DDTINI + 1
							_DDTFIM  := FPA->FPA_DTSCRT
							IF NDIASTRB < _nDiasX
								NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
							ENDIF

							// Frank 21/09/23 - tratamento quanto for 1.fat
							If !lPreviewX
								IF EMPTY(FPA->FPA_ULTFAT)
									nValLoc := FPA->FPA_VRHOR
									NDIASTRB := FPA->FPA_DTSCRT - _DDTINI + 1
									NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
								ENDIF
							Else
								IF EMPTY(dUltFat248)
									nValLoc := FPA->FPA_VRHOR
									NDIASTRB := FPA->FPA_DTSCRT - _DDTINI + 1
									NVALLOC := (NVALLOC * NDIASTRB) / _nDiasX
								ENDIF
							EndIf
						ENDIF
					ENDIF
				ELSEIF FP1->FP1_TPMES == "1"				// MES ABERTO
					IF EMPTY(FPA->FPA_DTSCRT)
						// DSERLOCA-2875 - Frank em 09/04/2024
						//_DDTFIM := _DDTINI + NDIASTRB - 1
						_DDTFIM := _DDTINI + FPA->FPA_LOCDIA - 1
					ELSE
						// DSERLOCA-2875 - Frank em 09/04/2024
						//IF _DDTINI + NDIASTRB - 1 < FPA->FPA_DTSCRT
						IF _DDTINI + FPA->FPA_LOCDIA - 1 < FPA->FPA_DTSCRT
							//_DDTFIM := _DDTINI + NDIASTRB - 1
							_DDTFIM := _DDTINI + FPA->FPA_LOCDIA - 1
						ELSE
							_DDTFIM := FPA->FPA_DTSCRT
						ENDIF
					ENDIF
					DULTFAT  := _DDTFIM
					// DSERLOCA-2875 - Frank em 09/04/2024
					//DPROXFAT := DULTFAT + NDIASTRB
					DPROXFAT := DULTFAT + FPA->FPA_LOCDIA
					// DSERLOCA-2875 - Frank em 09/04/2024
					//NVALLOC  := NVALLOC * (_DDTFIM - _DDTINI + 1) / NDIASTRB
					NVALLOC  := NVALLOC * (_DDTFIM - _DDTINI + 1) / FPA->FPA_LOCDIA
				ELSE // mes fixo

					If !lPreviewX
						_DDTFIM := FPA->FPA_DTFIM
					Else
						_DDTFIM := dDtFim248
					EndIf
					
					DULTFAT  := _DDTFIM
					DPROXFAT := MONTHSUM(DULTFAT,1)

					// somente se o dia for 30 e proximo mes 31
					// se for 29 de janeiro validar o maior dia de fevereiro
					// frank em 20/07/22 - ajuste do ultimo dia do mes fechado
					If day(dProxFat) == 30 .or. (month(dUltfat) == 1 .and. day(dultfat) == 28)  .or. (month(dUltfat) == 2 .and. (day(dultfat) == 28.or.day(dultfat) == 29))
						nMes := month(dproxfat)
						while nMes == month(dproxfat)
							dProxFat ++
						EndDo
						dproxfat := dproxfat - 1
					EndIf

					IF !EMPTY(FPA->FPA_DTSCRT)
						IF FPA->FPA_DTSCRT < _DDTFIM
							_DDTFIM  := FPA->FPA_DTSCRT
						ENDIF
					ENDIF

					nDias :=  _DDTFIM - _DDTINI + 1

					If month(_DDTINI) == 2 .and. month(_DDTFIM) > 2
						If nDias == 28 .or. nDias == 29
							nDias := 30
						EndIf
					Else
						If month(_DDTINI) == 2 .and. month(_DDTFIM) == 2
							If nDias == 28 .or. nDias == 29
								nDias := 30
							EndIf
						EndIf
					EndIf

					If !lPreviewX
						If EMPTY(FPA->FPA_DTSCRT) .and. !empty(FPA->FPA_ULTFAT)
							nDias := 30
						EndIF

						if (!EMPTY(FPA->FPA_DTSCRT) .or. Empty(FPA->FPA_ULTFAT)) .and. nDias > 30
							nDias := 30
						endif
					Else
						If EMPTY(FPA->FPA_DTSCRT) .and. !empty(dUltFat248)
							nDias := 30
						EndIF

						if (!EMPTY(FPA->FPA_DTSCRT) .or. Empty(dUltFat248)) .and. nDias > 30
							nDias := 30
						endif
					EndIf

					NVALLOC := FPA->FPA_VRHOR / 30 // Calculo do valor por dia
					NVALLOC := ROUND(NVALLOC * nDias,GETSX3CACHE("C6_VALOR","X3_DECIMAL"))   // (30 - 31 = -1 dia 30 - 29 = 1 dia)

				ENDIF

				nForca := 0
				IF lLOC021H
					nForca := EXECBLOCK("LOCA021H" , .T. , .T. , {} )
				ENDIF

				IF NDIASTRB < 0 .OR. _DDTINI > _DDTFIM .or. nForca > 0
					TMP->(DBSKIP())
					//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
					If TMP->( !EOF() )
						FPA->( DBGOTO( TMP->ZAGRECNO ) )
						FP1->( DBGOTO( TMP->FP1RECNO ) )
						//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
						cPvCliAux := TMP->(CLIFAT + LOJFAT)
					EndIf
					LOOP
				ENDIF

				_CPERLOC := DTOC(_DDTINI) + STR0027 + DTOC(_DDTFIM) //" A "

				IF _LOCA021D //EXISTBLOCK("LOCA021D")
					_cPerloc := EXECBLOCK("LOCA021D" , .F. , .F., {_CPERLOC} )
				ENDIF

				IF NVALLOC < 0
					_CTES   := _MV_LOC253 //SUPERGETMV("MV_LOCX253",.T.,"515")
					NVALLOC := ROUND((NVALLOC * -1),2)
				ELSE
					NVALLOC := ROUND(NVALLOC,2)
				ENDIF

				NVLR_OKD := NVALLOC

				// Melhoria na velocidade
				// DSERLOCA-2142 - Frank - 26/01/24
				lBlq := .F.
				IF SELECT("TRBSC6") > 0
					TRBSC6->(DBCLOSEAREA())
				ENDIF
				aBindParam := {}
				_cQuery := " SELECT C6_NUM"
				_cQuery += " FROM " + RETSQLNAME("SC6") + " SC6 (NOLOCK) "
				If lMvLocBac
					_cQuery += " INNER JOIN  " + RETSQLNAME("FPZ") + " FPZ (NOLOCK) "
					_cQuery += " ON	FPZ_FILIAL = C6_FILIAL AND "
					_cQuery += " FPZ_PEDVEN = C6_NUM AND FPZ.D_E_L_E_T_ = '' "
					_cQuery += " AND FPZ_AS = ? "
					aadd(aBindParam,_CAS)
					_cQuery += " INNER JOIN  " + RETSQLNAME("FPY") + " FPY (NOLOCK) "
					_cQuery += " ON	FPY_FILIAL = C6_FILIAL AND "
					_cQuery += " FPY_PEDVEN = C6_NUM AND "
					_cQuery += " FPY_TIPFAT = 'P' AND "
					_cQuery += " RTRIM(FPY_STATUS) <> '2' AND FPY.D_E_L_E_T_ = '' "
				EndIF
				_cQuery += " WHERE  C6_FILIAL = '" + XFILIAL("SC6") + "'"
				If !lMvLocBac
					If SC6->(FIELDPOS("C6_XAS")) > 0
						_cQuery +=   " AND  C6_XAS = ? "
						aadd(aBindParam,_CAS)
					EndIF
				EndIF
				_cQuery += " AND C6_ENTREG BETWEEN ? AND ? "
				aadd(aBindParam,DTOS(DDATABASE-(NDIASTRB-2)))
				aadd(aBindParam,DTOS(DDATABASE+(NDIASTRB-2)))
				_cQuery += " AND C6_BLQ NOT IN ('R','S') "
				_cQuery += " AND SC6.D_E_L_E_T_ = '' "
				_cQuery := CHANGEQUERY(_cQuery)
				MPSysOpenQuery(_cQuery,"TRBSC6",,,aBindParam)

				If TRBSC6->(!EOF())
					lBlq := .T.
				EndIF
				TRBSC6->(DBCLOSEAREA())

				_LPASSA := .T. // FRANK 27/10/20 PARA QUESTAO DOS ITENS FILHOS, FICA APRESENTANDO A MENSAGEM VARIAS VEZES

				IF ALLTRIM(FPA->FPA_TIPOSE) $ "Z#O"
					NVALLOC := FPA->FPA_VRHOR
				ENDIF

				// Valor da Locação diferente de Zero ou a Tes ACite Valor Zerado
				IF NVALLOC <> 0 .Or. SF4->F4_VLRZERO == "1" // Jose Eulalio - 14/02/2023 - SIGALOC94-660 - Chamado - 29947 | 30159 - Gerar faturamento com PV zerado (faturamento automático)
					IF  NVALLOC <> ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRCVEN","X3_DECIMAL"))) * FPA->FPA_QUANT
						NVALLOC := ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRCVEN","X3_DECIMAL"))) * FPA->FPA_QUANT
					ENDIF
					NVALLOC := ROUND(NVALLOC,SC6->(GETSX3CACHE("C6_VALOR","X3_DECIMAL")))

					_AITEMTEMP := {}
					_CTES := _MV_LOC080 //GETMV("MV_LOCX080")

					IF _LCJTES //EXISTBLOCK("LCJTES") 				// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
						_CTES := EXECBLOCK("LCJTES" , .T. , .T. , {_CTES})
					ENDIF
					// Frank em 27/12/2022 chamado 612
					NITENS := soma1(nItens) //   STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])

					// Identificação do local padrão de estoque
					If empty(FPA->FPA_LOCAL) // não informado na locação o local de estoque
						// utilizar o default informado no cadastro de produtos
						_cLocaPad := SB1->B1_LOCPAD
					Else
						_cLocaPad := FPA->FPA_LOCAL
					EndIF

					//AADD(_AITEMTEMP         , {"C6_NUM"     , _CNUMPED              , NIL})  // array 1 Comentado por Frank em 18/09/23
					AADD(_AITEMTEMP         , {"C6_FILIAL"  , XFILIAL("SC6")        , NIL})  // array 2
					AADD(_AITEMTEMP         , {"C6_ITEM"    , NITENS                , NIL})  // array 3
					AADD(_AITEMTEMP         , {"C6_PRODUTO"	, SB1->B1_COD           , NIL})  // array 4
					IF EMPTY(FPA->FPA_GRUA)
						AADD(_AITEMTEMP     , {"C6_DESCRI"  , ALLTRIM(SB1->B1_DESC)                                 , NIL})   // array 5
					ELSE
						AADD(_AITEMTEMP     , {"C6_DESCRI"  , ALLTRIM(SB1->B1_DESC)+" ("+ALLTRIM(FPA->FPA_GRUA)+")" , NIL})   // array 5
					ENDIF
					AADD(_AITEMTEMP,{"C6_LOCAL"	,_cLocaPad       , Nil})   // array 6

					// Alterado por Frank para o tratamento do endereçamento
					// se não houver em estoque deixaremos como não liberado
					// 11/08/21
					_nQtdLib := FPA->FPA_QUANT
					_NQTD    := FPA->FPA_QUANT
					// Controle do endereçamento - Frank 11/08/2021
					// [ inicio - controle de endereçamento ]
					// https://tdn.totvs.com/display/public/PROT/PEST06504+-+Atividade+do+controle+de+numero+de+serie
					_cNumSer := FPA->FPA_GRUA

					IF SC6->(FIELDPOS("C6_FROTA")) > 0
						AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil})   // array 7
					ENDIF

					IF ALLTRIM(FPA->FPA_TIPOSE) $ "Z"
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))

						If _MV_LOCALIZ == "S" .and. SB1->B1_LOCALIZ == "N" .and. !empty(_cNumSer)
							// Neste caso levaremos apenas para o SC6 o número de série da FPA.
							// Não precisa encontrar o endereçamento na SBF.
							//IF SC6->(FIELDPOS("C6_NUMSERI")) > 0
							//	AADD(AITENS,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)})
							//ENDIF
							IF SC6->(FIELDPOS("C6_FROTA")) > 0
								AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil})
							ENDIF
						ElseIf _MV_LOCALIZ == "S" .and. SB1->B1_LOCALIZ == "S"
							If empty(_cNumSer)
								// Neste caso não foi informado o número de série
								// Então vamos encontrar o local de endereçamento na SBF pelo produto/local que tenha o saldo necessário e levar o
								// endereçamento para a SC6
								SBF->(dbSetOrder(2))
								If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
									// Não foi localizado na tabela de endereçamento o produto
									_nQtdLib := 0 // Não libera o pedido de vendas
								Else
									_cLocaEnd := ""
									// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
									While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
										If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD
											_cLocaEnd := SBF->BF_LOCALIZ
											exit
										EndIF
										SBF->(dbSkip())
									EndDo
									If empty(_cLocaEnd)
										// Não foi localizado um endereço de estoque com a quantidade necessária para o produto
										_nQtdLib := 0 // Não libera o pedido de vendas
									EndIF
									AADD(_AITEMTEMP,{"C6_LOCALIZ"	,_cLocaEnd  , Nil})
								EndIF
							Else
								// Neste caso foi informado o número de série
								// Então vamos encontrar o local de endereçamento na SBF produto/local/NS que tenha o saldo necessário e levar
								// o endereçamento para a SC6
								// levar em consideração a mensagem de que existem saldos parciais que atendem o todo avisar e não deixar gerar o pv
								IF SC6->(FIELDPOS("C6_NUMSERI")) > 0
									AADD(_AITEMTEMP,{"C6_NUMSERI"	,_cNumSer       , Nil})
								ENDIF
								IF SC6->(FIELDPOS("C6_FROTA")) > 0
									AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil})
								ENDIF
								SBF->(dbSetOrder(2))
								If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
									// "Não foi localizado na tabela de endereçamento o produto
									_nQtdLib := 0 // Não libera o pedido de vendas
								Else
									_cLocaEnd := ""
									// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
									While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
										If alltrim(SBF->BF_NUMSERI) == alltrim(_cNumSer)
											If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD
												_cLocaEnd := SBF->BF_LOCALIZ
												exit
											EndIF
										EndIF
										SBF->(dbSkip())
									EndDo
									If empty(_cLocaEnd)
										_nTempSld := 0
										_cMsgSld  := ""
										SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
										While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
											If !empty(SBF->BF_NUMSERI)
												_nTempSld += (SBF->BF_QUANT - SBF->BF_EMPENHO)
												_cMsgSld  += alltrim(SBF->BF_NUMSERI)+" "
												If _nTempSld >= _NQTD
													exit
												EndIF
											EndIF
											SBF->(dbSkip())
										EndDo
										If _nTempSld >= _NQTD
											// "Os seguintes equipamentos precisam ser inseridos na aba locação
										Else
											// "Não existe saldo nos itens endereçados para esta quantidade.
										EndIF
										_nQtdLib := 0 // Não libera o pedido de vendas
									EndIF
									AADD(_AITEMTEMP,{"C6_LOCALIZ"	,_cLocaEnd  , Nil})
								EndIf
							EndIF
						ElseIf _MV_LOCALIZ == "N" .and. SB1->B1_LOCALIZ == "S"
							// Neste caso independente de ser infomado o NS
							// Vamos encontrar o local de endereçamento pelo produto/armazem na SBF que tenha o saldo necessário e levar o
							// endereçamento para a SC6
							// não levaremos o número de série para a sc6.

							SBF->(dbSetOrder(2))
							If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
								// Não foi localizado na tabela de endereçamento o produto
								_nQtdLib := 0 // Não libera o pedido de vendas
							Else
								_cLocaEnd := ""
								// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
								While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_LOCAL == _cLocaPad
									If SBF->BF_QUANT - SBF->BF_EMPENHO >= _NQTD
										_cLocaEnd := SBF->BF_LOCALIZ
										exit
									EndIF
									SBF->(dbSkip())
								EndDo
								If empty(_cLocaEnd)
									// Não foi localizado um endereço de estoque com a quantidade necessária para o produto
									_nQtdLib := 0 // Não libera o pedido de vendas
								EndIF
								IF SC6->(FIELDPOS("C6_FROTA")) > 0
									AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil})
								ENDIF
								AADD(_AITEMTEMP,{"C6_LOCALIZ"	,_cLocaEnd  , Nil})
							EndIF
						EndIF
						If _MV_LOCALIZ == "N" .and. SB1->B1_LOCALIZ == "N"
							IF SC6->(FIELDPOS("C6_FROTA")) > 0
								AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil})
							ENDIF
						EndIF
					Else
						IF SC6->(FIELDPOS("C6_FROTA")) > 0
							AADD(_AITEMTEMP,{"C6_FROTA"	,_cNumSer       , Nil})
						ENDIF
					EndIF
					// Fim controle de enderecamento

					nForca := 0
					IF lLOC021J
						nForca := EXECBLOCK("LOCA021J" , .T. , .T. , {} )
					ENDIF

					IF ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CMV_LOCX014) .or. nForca > 0
						IF FPA->(FIELDPOS("FPA_VRAND")) > 0 .or. nForca > 0
							IF FPA->FPA_VRAND > 0 .or. nForca > 0
								TMP->( DBSKIP() )
								//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
								If TMP->( !EOF() ) .or. nForca > 0
									FPA->( DBGOTO( TMP->ZAGRECNO ) )
									FP1->( DBGOTO( TMP->FP1RECNO ) )
									//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
									cPvCliAux := TMP->(CLIFAT + LOJFAT)
								EndIf
								LOOP
							ENDIF
							AADD(_AITEMTEMP , {"C6_QTDVEN"  , FPA->FPA_QUANT        , NIL})
							AADD(_AITEMTEMP , {"C6_QTDLIB"  , _nQtdLib        , NIL}) // controle de enderecamento frank 11/08/21
							AADD(_AITEMTEMP , {"C6_PRCVEN"  , NVALLOC               , NIL})
							AADD(_AITEMTEMP , {"C6_PRUNIT"  , NVALLOC               , NIL})
							AADD(_AITEMTEMP , {"C6_VALOR"   , NVALLOC               , NIL})
							nTotPed += nValLoc
						ELSE
							AADD(_AITEMTEMP , {"C6_QTDVEN"  , FPA->FPA_QUANT        , NIL})
							AADD(_AITEMTEMP , {"C6_QTDLIB"  , _nQtdLib        , NIL}) // controle de enderecamento Frank 11/08/21
							AADD(_AITEMTEMP , {"C6_PRCVEN"  , ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRCVEN","X3_DECIMAL"))) , NIL})
							AADD(_AITEMTEMP , {"C6_PRUNIT"  , ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRUNIT","X3_DECIMAL"))) , NIL})
							AADD(_AITEMTEMP , {"C6_VALOR"   , NVALLOC               , NIL})
							nTotPed += nValLoc
						ENDIF
					ELSE
						AADD(_AITEMTEMP     , {"C6_QTDVEN"  , 1                     , NIL})
						AADD(_AITEMTEMP     , {"C6_QTDLIB"  , _nQtdLib              , NIL}) // era 1 11/08/21 Frank controle de enderecamento
						AADD(_AITEMTEMP     , {"C6_PRCVEN"  , NVALLOC               , NIL})
						AADD(_AITEMTEMP     , {"C6_PRUNIT"  , NVALLOC               , NIL})
						AADD(_AITEMTEMP     , {"C6_VALOR"   , NVALLOC               , NIL})
						nTotPed += nValLoc
					ENDIF

					If empty(FPA->FPA_TESFAT)
						AADD(_AITEMTEMP         , {"C6_TES"     , _CTES                 , NIL})
					Else
						AADD(_AITEMTEMP         , {"C6_TES"     , FPA->FPA_TESFAT       , NIL})
					EndIf

					If !lMvLocBac
						IF SC6->(FIELDPOS("C6_XAS")) > 0
							AADD(_AITEMTEMP         , {"C6_XAS"     , FPA->FPA_AS           , NIL})
						EndIf
						IF SC6->(FIELDPOS("C6_XBEM")) > 0
							AADD(_AITEMTEMP         , {"C6_XBEM"    , FPA->FPA_GRUA         , NIL})
						EndIf

						IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0
							AADD(_AITEMTEMP     , {"C6_XCCUSTO" , FPA->FPA_CUSTO        , NIL})
						ENDIF

						IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
							AADD(_AITEMTEMP     , {"C6_XPERLOC" , _CPERLOC              , NIL})
						ENDIF
					EndIf
					IF SC6->(FIELDPOS("C6_CC")) > 0
						AADD(_AITEMTEMP     , {"C6_CC"      , FPA->FPA_CUSTO        , NIL})
					ENDIF
					IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
						AADD(_AITEMTEMP      , {"C6_CLVL"    , AllTrim(FPA->FPA_AS)           , NIL})
					ENDIF

					// rotina para validar se existem custos extras negativos para entrar como desconto.
					// Frank Z Fuga em 15/02/21
					//_lDescCus := .F.
					FPG->(dbSetOrder(1))
					FPG->(dbSeek(xFilial("FPG")+FPA->FPA_PROJET+FPA->FPA_AS))
					_nDescCus := 0
					While !FPG->(Eof()) .and. FPG->(FPG_FILIAL+FPG_PROJET+FPG_NRAS) == xFilial("FPG")+FPA->FPA_PROJET+FPA->FPA_AS
						If FPG->FPG_VALTOT < 0 .and. FPG->FPG_COBRA == "S" .and. FPG->FPG_STATUS == "1" .and. FPG->FPG_JUNTO == "S"
							If 	FPG->FPG_DTENT >= IIF(Valtype(MV_PAR01) == 'D', MV_PAR01, StoD(Alltrim(MV_PAR01))) .And. ;
								FPG->FPG_DTENT <= IIF(Valtype(MV_PAR02) == 'D', MV_PAR02, StoD(CVALTOCHAR(YEAR(DATE())+1)+"1231"))
								If empty(FPG->FPG_PVNUM)
									aadd(_aDescCus,{FPG->(Recno()),FPG->FPG_VALTOT*-1,NITENS})
									_nDescCus += (FPG->FPG_VALTOT*-1)
									_lDescCus := .T.
								EndIf
							EndIF
						EndIF
						FPG->(dbSkip())
					EndDo


					IF FPA->FPA_PDESC > 0 .or. _nDescCus > 0

						// desconto := custo fixo negativo + percentual sobre o valor total
						// _nDescX := _nDescCus + (FPA->FPA_VLBRUT * (FPA->FPA_PDESC/100)) // comentado por Frank em 09/07/21
						_nDescX := _nDescCus // ajustado por Frank em 09/07/21
						_nDescY += _nDescX

						//If FPA->FPA_VLBRUT == _nDescX // comentado por Frank em 09/07/21
						If FPA->FPA_VRHOR  == _nDescX // ajustado por Frank em 09/07/21
							// se o total de desconto for = ao valor do titulo
							// _nDescX := FPA->FPA_VLBRUT - 0.01 // Forçar um valor positivo para a geração do PV // comentado por Frank em 09/07/21
							_nDescX := _nDescCus - 0.01 // ajustado por Frank em 09/07/21

							_nDescX := (nValLoc * 99.99)/100

							_nDescY += _nDescX
							AADD(_AITEMTEMP , {"C6_VALDESC" , _nDescX        , NIL})
							NVALLOC -= _nDescX
						ElseIf FPA->FPA_VRHOR < _nDescX
							IF ! _LJOB
								MsgAlert(STR0032,STR0033) //"Existem custos extras a serem processados, porém o valor do faturamento não alcança o valor total do desconto."###"Atenção!"
							EndIf
							_lDescCus := .F.
						Else
							AADD(_AITEMTEMP , {"C6_VALDESC" , _nDescX        , NIL})
							NVALLOC -= _nDescX
						EndIF
					ENDIF

					IF _LCJLFITE //EXISTBLOCK("LCJLFITE") 				// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
						_AITEMTEMP := EXECBLOCK("LCJLFITE" , .T. , .T. , {_AITEMTEMP})
					ENDIF

					//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
					//Itens da Tabela de Pedido de Venda x Locação
					dGeraem := ctod("")

					IF lAglutinar // Vai Haver aglutinação
						//determina o produto pelo tipo de serviço
						If FPA->FPA_TIPOSE == "L"
							cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODL), FP0->FP0_PRODL , cMvLOCX063)
						ElseIf FPA->FPA_TIPOSE $ "O|Z"
							cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODOZ), FP0->FP0_PRODOZ , cMvLOCX063)
						ElseIf FPA->FPA_TIPOSE == "M"
							cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODM), FP0->FP0_PRODM , cMvLOCX064)
						EndIf

						nForca := 0
						IF lLOC021Y
							nForca := EXECBLOCK("LOCA021Y" , .T. , .T. , {} )
						ENDIF

						//caso não tenha nada no array adiciona novo item aglutinado
						If Len(aAgluNf) == 0 .or. aScan(aAgluNf,{|x| x[1]==cPrdAgluNf}) =0
							Aadd(aAgluNf,{ cPrdAgluNf , NVALLOC , NITENS })
							nItemAglu := Len(aAgluNf)
							nPosPrdAgl := nItemAglu
							//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
							aItemAGG := {}
							Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(1,2)	,	NIL })
							Aadd(aItemAGG, {"AGG_PERC"		, NVALLOC			,	NIL }) //será atualizado mais a frente com a proporção
							Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
							if _LCVAL
								Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
							else
								Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
							endif
							//campos vazios devem ser enviados
							Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
							Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
							Aadd(aAgluRat, { StrZero(nItemAglu,2,0) , {aClone(aItemAGG)} })
							//se não, soma valor no produto já existente
						else
							nPosPrdAgl := aScan(aAgluNf,{|x| x[1]==cPrdAgluNf})
							aAgluNf[nPosPrdAgl][2] += NVALLOC
							nItemAglu := Len(aAgluRat[nPosPrdAgl][2])
							//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
							aItemAGG := {}
							Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(nItemAglu+1,2)	,	NIL })
							Aadd(aItemAGG, {"AGG_PERC"		, NVALLOC			,	NIL }) //será atualizado mais a frente com a proporção
							Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
							if _LCVAL
								Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
							else
								Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
							endif
							//campos vazios devem ser enviados
							Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
							Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
							Aadd(aAgluRat[nPosPrdAgl][2], aClone(aItemAGG) )

						EndIf
					EndIf

					If lMvLocBac
						aItemFPZ := {}
						Aadd(aItemFPZ, {"FPZ_FILIAL"	, XFILIAL("SC6")	,	NIL })
						//Aadd(aItemFPZ, {"FPZ_PEDVEN"	, _CNUMPED			, 	NIL }) Removido por Frank em 18/09/23
						Aadd(aItemFPZ, {"FPZ_PEDVEN"	, ""				, 	NIL })
						Aadd(aItemFPZ, {"FPZ_DTPED"	, dDataBase				, 	NIL })
						Aadd(aItemFPZ, {"FPZ_DTINI"	, _DDTINI				, 	NIL })
						Aadd(aItemFPZ, {"FPZ_DTFIM"	, _DDTFIM				, 	NIL })
						Aadd(aItemFPZ, {"FPZ_PROJET"	, FPA->FPA_PROJET	,	NIL })
						Aadd(aItemFPZ, {"FPZ_PRVFAT"	, FPA->FPA_ULTFAT	,	NIL })
						IF lAglutinar
							if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
								Aadd(aItemFPZ, {"FPZ_ITEM"		    , StrZero(nPosPrdAgl, TAMSX3("FPZ_ITEM")[1],0),	NIL })
							else
								Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
							endif
						ELSE
							Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
						ENDIF

						Aadd(aItemFPZ, {"FPZ_AS"		, FPA->FPA_AS		, 	NIL })
						Aadd(aItemFPZ, {"FPZ_EXTRA"		, "N"				,	NIL })
						Aadd(aItemFPZ, {"FPZ_FROTA"		, FPA->FPA_GRUA		,	NIL })
						Aadd(aItemFPZ, {"FPZ_PERLOC"	, _CPERLOC			,	NIL })
						Aadd(aItemFPZ, {"FPZ_CCUSTO"	, FPA->FPA_CUSTO	,	NIL })

						// DSERLOCA-2600 - Frank em 13/03/24
						// Se o campo FPA_GERAEM estiver em branco nada se faz
						If FPZ->(FIELDPOS("FPZ_GERAEM")) > 0 .and. FPA->(FIELDPOS("FPA_GERAEM")) > 0
							dGeraem := ctod("")
							If !lPreviewX
								If !empty(FPA->FPA_GERAEM)
									If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
										dGeraem := MONTHSUM(FPA->FPA_GERAEM,1)
									else // dias corridos
										dGeraem := FPA->FPA_GERAEM + FPA->FPA_LOCDIA
									EndIF
								EndIf
							Else
								If !empty(dGeraEm248)
									If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
										dGeraem := MONTHSUM(dGeraEm248,1)
									else // dias corridos
										dGeraem := dGeraEm248 + FPA->FPA_LOCDIA
									EndIF
								EndIf
							EndIf
							
							Aadd(aItemFPZ, {"FPZ_GERAEM", FPA->FPA_GERAEM,	NIL })
						EndIF
						// Inclusão de novos campos FPZ Alexandre Circenis 14/06/24
						if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
							Aadd(aItemFPZ, {"FPZ_ITMFPZ"		, NITENS ,	NIL })
							Aadd(aItemFPZ, {"FPZ_QUANT", FPA->FPA_QUANT,	NIL })
							Aadd(aItemFPZ, {"FPZ_VALUNI", ROUND(NVALLOC/FPA->FPA_QUANT,SC6->(GETSX3CACHE("C6_PRUNIT","X3_DECIMAL"))),	NIL })
							Aadd(aItemFPZ, {"FPZ_PROD"  , FPA->FPA_PRODUT,	NIL })
							Aadd(aItemFPZ, {"FPZ_VIAGEM", FPA->FPA_VIAGEM,	NIL })
							Aadd(aItemFPZ, {"FPZ_DIAS"  , _DDTFIM - _DDTINI + 1,	NIL })
							Aadd(aItemFPZ, {"FPZ_TOTAL", NVALLOC,	NIL })
							Aadd(aItemFPZ, {"FPZ_OBRA", FPA->FPA_OBRA,	NIL })
							
							If empty(FPA->FPA_TESFAT)
								Aadd(aItemFPZ, {"FPZ_TES" , _CTES                 , NIL})
							Else
								Aadd(aItemFPZ, {"FPZ_TES" ,  FPA->FPA_TESFAT       , NIL})
							EndIf
							
							if _LCVAL
								Aadd(aItemFPZ, {"FPZ_CLVL"  , FPA->FPA_AS,	NIL })
							endif
						//	if _nDescX > 0 .and. FPA->FPA_VRHOR > _nDescX
						//		Aadd(aItemFPZ, {"FPZ_VALDES",_nDescX,	NIL })
						//	endif
						endif

						Aadd(aFPZ,Aclone(aItemFPZ))

					EndIf

					_NREG++
					AADD(_AITENSPV , ACLONE(_AITEMTEMP))

					NPESO    += 0 //ST9->T9_PESO
					NVALTOT  += NVALLOC
				    AADD(_AASS , {FPA->FPA_PROJET , FPA->FPA_AS , _DDTFIM , ""       , NITENS , DULTFAT , DPROXFAT, dGeraem})
				ENDIF										// --> IF NVALLOC <> 0

				IF _LCJLFFRT //EXISTBLOCK("LCJLFFRT") 					// --> PONTO DE ENTRADA PARA MANIPULAÇÃO DO VALOR DO FRETE.
					EXECBLOCK("LCJLFFRT" , .T. , .T. , {_LPRIMFAT , _NVLRFRETE})
				ELSE
					// --> FRETE
					IF _LPRIMFAT .AND. FPA->FPA_TPGUIM == "C"
						_NVLRFRETE += FPA->FPA_GUIMON
					ENDIF
					IF (FPA->FPA_DTSCRT <= _DDTFIM .AND. !EMPTY(FPA->FPA_DTSCRT) .AND. FPA->FPA_TPGUID == "C") .OR.;
					(ALLTRIM(FPA->FPA_TIPOSE) $ "Z#O" .and. FPA->FPA_TPGUID == "C")
						_NVLRFRETE += FPA->FPA_GUIDES
					ENDIF
				ENDIF

				// --> SEGURO
				IF empty(FPA->FPA_ULTFAT) // Frank 23/06/21
					_NVLRSEG += FPA->FPA_VRSEGU
					NVALTOT  += FPA->FPA_VRSEGU
				EndIF
				_CCUSTOAG := FPA->FPA_CUSTO

				IF CPAR11 == 3 								// AMBOS
					IF SELECT("TRBFPG") > 0
						TRBFPG->( DBCLOSEAREA() )
					ENDIF
					aBindParam := {}
					_CQUERY := " SELECT  FPG_PRODUT , FPG_QUANT , FPG_DESCRI , FPG_VLUNIT , FPG_TAXAV , FPG_DTENT,"
					_CQUERY += "         FPG_COBRAT , FPG_VALOR , FPG_VALTOT , FPG_CUSTO , ZC1.R_E_C_N_O_ ZC1RECNO "
					_CQUERY += " FROM " + RETSQLNAME("FPG") + " ZC1 "
					_CQUERY += " WHERE   FPG_NRAS   =  ? "
					aadd(aBindParam,FPA->FPA_AS)
					_CQUERY += "   AND   FPG_COBRA IN ('S','D') "
					_CQUERY += "   AND   FPG_JUNTO  =  'S' "
					_CQUERY += "   AND   FPG_STATUS =  '1' "
					_CQUERY += "   AND   FPG_VALTOT > 0 "
					_CQUERY += "   AND   FPG_PRODUT <> ''  "

					// novos filtros por produto
					IF _lTem12 .and. _lTem13
						_CQUERY += " AND FPG_PRODUT BETWEEN ? AND ? "
						aadd(aBindParam,CPAR12)
						aadd(aBindParam,CPAR13)
					EndIF
					_CQUERY += "   AND  (FPG_DTENT BETWEEN ? AND ? "
					aadd(aBindParam,DTOS(DPAR01))
					aadd(aBindParam,DTOS(DPAR02))
					_CQUERY += "    OR   FPG_DTENT = '')"
					_CQUERY += "   AND   ZC1.D_E_L_E_T_ = '' "
					_CQUERY := CHANGEQUERY(_CQUERY)
					MPSysOpenQuery(_cQuery,"TRBFPG",,,aBindParam)

					DBSELECTAREA("TRBFPG")
					TRBFPG->(DBGOTOP())

					IF !EMPTY(TRBFPG->FPG_PRODUT)

						WHILE !TRBFPG->(EOF())
							IF TRBFPG->FPG_COBRAT == "N"
								_NTOTZC1 := TRBFPG->FPG_VALOR
							ELSE
								_NTOTZC1 := TRBFPG->FPG_VALTOT
							ENDIF

							_NVALZC1   := ROUND(_NTOTZC1 / TRBFPG->FPG_QUANT,SC6->(GETSX3CACHE("C6_VALOR","X3_DECIMAL")))
							_AITEMTEMP := {}
							// Frank em 27/12/2022 chamado 612
							NITENS := soma1(nItens)
							AADD(_AITEMTEMP , {"C6_FILIAL"  , XFILIAL("SC6")     , NIL})
							AADD(_AITEMTEMP , {"C6_ITEM"    , NITENS             , NIL})

							_cProdXa := TRBFPG->FPG_PRODUT
							_cDescXa := TRBFPG->FPG_DESCRI
							IF _LOCA021A //EXISTBLOCK("LOCA021A")
								_cProdXa := EXECBLOCK("LOCA021A" , .T. , .T. , {TRBFPG->ZC1RECNO,1}) // 1 = Código do produto
								_cDescXa := EXECBLOCK("LOCA021A" , .T. , .T. , {TRBFPG->ZC1RECNO,2}) // 2 = Descricao do produto
							ENDIF

							AADD(_AITEMTEMP , {"C6_PRODUTO" , _cProdXa , NIL})
							AADD(_AITEMTEMP , {"C6_DESCRI"  , _cDescXa , NIL})
							AADD(_AITEMTEMP , {"C6_QTDVEN"  , TRBFPG->FPG_QUANT  , NIL})
							AADD(_AITEMTEMP , {"C6_PRCVEN"  , _NVALZC1           , NIL})
							AADD(_AITEMTEMP , {"C6_PRUNIT"  , _NVALZC1           , NIL})
							AADD(_AITEMTEMP , {"C6_VALOR"   , _NTOTZC1           , NIL})
							nTotPed += _NTOTZC1
							//AADD(_AITEMTEMP , {"C6_TES"     , _CTESPRO           , NIL})
							If !empty(FPA->FPA_TESFAT)
								AADD(_AITEMTEMP , {"C6_TES"     , FPA->FPA_TESFAT    , NIL})
							Else
								AADD(_AITEMTEMP , {"C6_TES"     , _CTESPRO           , NIL})
							EndIF
							AADD(_AITEMTEMP , {"C6_QTDLIB"  , TRBFPG->FPG_QUANT  , NIL})
							AADD(_AITEMTEMP , {"C6_CC"      , TRBFPG->FPG_CUSTO  , NIL})
							IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
								AADD(_AITEMTEMP      , {"C6_CLVL"    , AllTrim(FPA->FPA_AS)           , NIL})
							ENDIF
							If !lMvLocBac
								IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0
									AADD(_AITEMTEMP     , {"C6_XCCUSTO" , FPA->FPA_CUSTO        , NIL})
								ENDIF

								IF SC6->(FIELDPOS("C6_XEXTRA")) > 0
									AADD(_AITEMTEMP , {"C6_XEXTRA"  , "S"                , NIL})
								EndIf
								IF SC6->(FIELDPOS("C6_XAS")) > 0
									AADD(_AITEMTEMP , {"C6_XAS"     , FPA->FPA_AS        , NIL})
								EndIf
								IF SC6->(FIELDPOS("C6_XBEM")) > 0
									AADD(_AITEMTEMP , {"C6_XBEM"    , FPA->FPA_GRUA      , NIL})
								EndIf
								IF SC6->(FIELDPOS("C6_FROTA")) > 0
									AADD(_AITEMTEMP     , {"C6_FROTA"      , FPA->FPA_GRUA        , NIL})
								ENDIF
								IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
									AADD(_AITEMTEMP     , {"C6_XPERLOC" , _CPERLOC              , NIL})
								ENDIF
							EndIf

							_NREG++

							NVALTOT += _NTOTZC1

							AADD( _AITENSPV , ACLONE(_AITEMTEMP) )
							AADD( _AZC1FAT , {TRBFPG->ZC1RECNO , ""       , NITENS} )


							//SIGALOC94-394 - Aglutinação para pedidos de vendas usando FP0
							IF lAglutinar
								//determina o produto pelo tipo de serviço
								If FPA->FPA_TIPOSE == "L"
									cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODL), FP0->FP0_PRODL , cMvLOCX063)
								ElseIf FPA->FPA_TIPOSE $ "O|Z"
									cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODOZ), FP0->FP0_PRODOZ , cMvLOCX063)
								ElseIf FPA->FPA_TIPOSE == "M"
									cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODM), FP0->FP0_PRODM , cMvLOCX064)
								EndIf

								//caso não tenha nada no array adiciona ou ainda não adicionado
								If Len(aAgluNf) == 0 .Or. aScan(aAgluNf,{|x| x[1]  == cPrdAgluNf}) == 0

									Aadd(aAgluNf, { cPrdAgluNf , _NTOTZC1 , NITENS })
									nItemAglu := Len(aAgluNf)
									PosPrdAgl := nItemAglu
									//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
									aItemAGG := {}
									Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(1,2)	,	NIL })
									Aadd(aItemAGG, {"AGG_PERC"		, _NTOTZC1			,	NIL }) //será atualizado mais a frente com a proporção
									Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
									if _LCVAL
										Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
									else
										Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
									endif
									//campos vazios devem ser enviados
									Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
									Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
									Aadd(aAgluRat, { StrZero(nItemAglu, 2,0) , {aClone(aItemAGG)} })
								Else
									//caso já exista o array verifica se o produto já foi adicionado
									nPosPrdAgl := aScan(aAgluNf,{|x| x[1]==cPrdAgluNf})

									nForca := 0
									IF lLOC021W 
										nForca := EXECBLOCK("LOCA021W" , .T. , .T. , {} )
									ENDIF

									//se não existir o produto no array adiciona
									/* Já adicionado acima
									If nPosPrdAgl == 0 .or. nForca > 0
										Aadd(aAgluNf, { cPrdAgluNf , _NTOTZC1 , NITENS })
										//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
										aItemAGG := {}
										Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(1,2)	,	NIL })
										Aadd(aItemAGG, {"AGG_PERC"		, _NTOTZC1			,	NIL }) //será atualizado mais a frente com a proporção
										Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
										if _LCVAL
											Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
										else
											Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
										endif
										//campos vazios devem ser enviados
										Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
										Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
										Aadd(aAgluRat, { NITENS , {aClone(aItemAGG)} })
									//se não, soma valor no produto já existente
									else */
										aAgluNf[nPosPrdAgl][2] += _NTOTZC1
										nItemAglu := Len(aAgluRat[nPosPrdAgl][2]) // Informar o ultimo item incluido
										//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
										aItemAGG := {}
										Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(nItemAglu+1,2)	,	NIL })
										Aadd(aItemAGG, {"AGG_PERC"		, _NTOTZC1			,	NIL }) //será atualizado mais a frente com a proporção
										Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
										if _LCVAL
											Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
										else
											Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
										endif
										//campos vazios devem ser enviados
										Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
										Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
										Aadd(aAgluRat[nPosPrdAgl][2], aClone(aItemAGG) )
									//EndIf
								EndIf

							EndIf

							//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
							//Itens da Tabela de Pedido de Venda x Locação
							If lMvLocBac
								aItemFPZ := {}
								Aadd(aItemFPZ, {"FPZ_FILIAL"	, XFILIAL("SC6")	,	NIL })
								//Aadd(aItemFPZ, {"FPZ_PEDVEN"	, _CNUMPED			, 	NIL }) Removido por Frank em 18/09/23
								Aadd(aItemFPZ, {"FPZ_PEDVEN"	, ""				, 	NIL })
								Aadd(aItemFPZ, {"FPZ_DTPED"	, dDataBase				, 	NIL })
								Aadd(aItemFPZ, {"FPZ_DTINI"	, _DDTINI				, 	NIL })
								Aadd(aItemFPZ, {"FPZ_DTFIM"	, _DDTFIM				, 	NIL })
								Aadd(aItemFPZ, {"FPZ_PROJET"	, FPA->FPA_PROJET	,	NIL })
								Aadd(aItemFPZ, {"FPZ_PRVFAT"	, FPA->FPA_ULTFAT	,	NIL })
								IF lAglutinar
									if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
										Aadd(aItemFPZ, {"FPZ_ITEM"		    , StrZero(nPosPrdAgl, TAMSX3("FPZ_ITEM")[1],0),	NIL })
									else
										Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
									endif
								ELSE
									Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
								ENDIF

								Aadd(aItemFPZ, {"FPZ_AS"		, FPA->FPA_AS		, 	NIL })
								Aadd(aItemFPZ, {"FPZ_EXTRA"		, "S"				,	NIL })
								Aadd(aItemFPZ, {"FPZ_FROTA"		, FPA->FPA_GRUA		,	NIL })
								Aadd(aItemFPZ, {"FPZ_PERLOC"	, DTOC(STOD(TRBFPG->FPG_DTENT)) + " A " + DTOC(STOD(TRBFPG->FPG_DTENT)) ,	NIL })
								Aadd(aItemFPZ, {"FPZ_CCUSTO"	, FPA->FPA_CUSTO	,	NIL })

								// DSERLOCA-2600 - Frank em 13/03/24
								// Se o campo FPA_GERAEM estiver em branco nada se faz
								If FPZ->(FIELDPOS("FPZ_GERAEM")) > 0 .and. FPA->(FIELDPOS("FPA_GERAEM")) > 0
									dGeraem := ctod("")
									If !lPreviewX
										If !empty(FPA->FPA_GERAEM)
											If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
												dGeraem := MONTHSUM(FPA->FPA_GERAEM,1)
											else // dias corridos
												dGeraem := FPA->FPA_GERAEM + FPA->FPA_LOCDIA
											EndIF
										EndIf
									//Else
									//	If !empty(dGeraEm248)
									//		If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
									//			dGeraem := MONTHSUM(dGeraEm248,1)
									//		else // dias corridos
									//			dGeraem := dGeraEm248 + FPA->FPA_LOCDIA
									//		EndIF
									//	EndIf
									EndIf
									Aadd(aItemFPZ, {"FPZ_GERAEM", FPA->FPA_GERAEM,	NIL })
								EndIF
								// Inclusão de novos campos FPZ Alexandre Circenis 14/06/24
								if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
									Aadd(aItemFPZ, {"FPZ_ITMFPZ"		, NITENS ,	NIL })
									Aadd(aItemFPZ, {"FPZ_QUANT", FPA->FPA_QUANT,	NIL })
									Aadd(aItemFPZ, {"FPZ_VALUNI", _NVALZC1 ,	NIL })
									Aadd(aItemFPZ, {"FPZ_PROD"  , _cProdXa,	NIL })
									Aadd(aItemFPZ, {"FPZ_VIAGEM", FPA->FPA_VIAGEM,	NIL })
									Aadd(aItemFPZ, {"FPZ_DIAS"  , _DDTFIM - _DDTINI + 1,	NIL })
									Aadd(aItemFPZ, {"FPZ_TOTAL", _NTOTZC1,	NIL })
									Aadd(aItemFPZ, {"FPZ_OBRA", FPA->FPA_OBRA,	NIL })
									if _LCVAL
										Aadd(aItemFPZ, {"FPZ_CLVL"  , FPA->FPA_AS,	NIL })
									endif
									If empty(FPA->FPA_TESFAT)
										Aadd(aItemFPZ, {"FPZ_TES" , _CTESPRO               , NIL})
									Else
										Aadd(aItemFPZ, {"FPZ_TES" ,  FPA->FPA_TESFAT       , NIL})
									EndIf
								endif

								Aadd(aFPZ,Aclone(aItemFPZ))
							EndIf

							TRBFPG->(DBSKIP())
						ENDDO
					ENDIF
				ENDIF

				nForca := 0
				IF lLOC021K
					nForca := EXECBLOCK("LOCA021K" , .T. , .T. , {} )
				ENDIF

				//SIGALOC94-788	- 06/06/2023 - Erros Faturamento Automático
				_CPAGTO  := FPA->FPA_CONPAG
				cCodTab	 := FPA->FPA_CODTAB
				cAuxAS   := FPA->FPA_AS
				cAuxPerL := _CPERLOC

				TMP->( DBSKIP() )
				//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO

				If TMP->( !EOF() )
					//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
					cPvCliAux := TMP->CLIFAT + TMP->LOJFAT
				EndIf

			ENDDO

			_CTXT := STR0034 + ALLTRIM(FP1->FP1_NOMORI) + CRLF //"OBRA: "
			_CTXT += STR0035 + ALLTRIM(FP1->FP1_ENDORI) + CRLF //"ENDERECO: "
			_CTXT += STR0036 + ALLTRIM(FP1->FP1_BAIORI) + CRLF //"BAIRRO: "
			_CTXT += STR0037 + ALLTRIM(FP1->FP1_MUNORI) + CRLF //"MUNICIPIO: "
			_CTXT += STR0038 + ALLTRIM(FP1->FP1_ESTORI) + CRLF //"ESTADO: "

			IF ! EMPTY(FP1->FP1_CEIORI)
				_CTXT += STR0039    + ALLTRIM(FP1->FP1_CEIORI) + CRLF //"CEI: "
			ENDIF
			_CNATUREZ := _MV_LOC065 //GETMV("MV_LOCX065")
			IF _LCJNAT //EXISTBLOCK("LCJNAT") 								// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA NATUREZA FINANCEIRA.
				_CNATUREZ := EXECBLOCK("LCJNAT" , .T. , .T. , {_CNATUREZ})
			ENDIF

			//SIGALOC94-788	- 06/06/2023 - Erros Faturamento Automático
			//_CPAGTO   := FPA->FPA_CONPAG

			// Frank em 05/05/22 - indica se usa tabela de preços para a geração do SC5
			// é obrigatório somente quando a condição de pagamento esta amarrada com uma tabela de precos
			_lUsaTab := .F.
			//SIGALOC94-788	- 06/06/2023 - Erros Faturamento Automático
			//If !empty(FPA->FPA_CODTAB)
			If !empty(cCodTab)
				DA0->(dbSetOrder(1))
				//If DA0->(dbSeek(xFilial("DA0")+FPA->FPA_CODTAB))
				If DA0->(dbSeek(xFilial("DA0")+cCodTab))
					If !empty(DA0->DA0_CONDPG)
						_lUsaTab := .T.
					EndIf
				EndIf
			EndIF
			// Preparando para Gerar o Pedido baseado na FPA

			_ACABPV	:= {}

			//CONOUT("[LCJLF001.PRW] # ((INICIO ARRAY SC5 - A))")
			//AADD(_ACABPV , {"C5_FILIAL"	 , XFILIAL("SC5")        , NIL})
			//AADD(_ACABPV , {"C5_NUM"     , _CNUMPED              , NIL}) Comentado por Frank em 18/09/23
			AADD(_ACABPV , {"C5_TIPO"    , "N"                   , NIL})
			AADD(_ACABPV , {"C5_CLIENTE" , cCliFat               , NIL})
			AADD(_ACABPV , {"C5_LOJACLI" , cLojFat		         , NIL})
			If _lUsaTab
				//SIGALOC94-788	- 06/06/2023 - Erros Faturamento Automático
				//AADD(_ACABPV , {"C5_TABELA"  , FPA->FPA_CODTAB       , NIL})
				AADD(_ACABPV , {"C5_TABELA"  , cCodTab       , NIL})
			EndIF
			AADD(_ACABPV , {"C5_CONDPAG" , _CPAGTO               , NIL})
			AADD(_ACABPV , {"C5_VEND1"   , FP0->FP0_VENDED       , NIL})
			AADD(_ACABPV , {"C5_PESOL"   , NPESO                 , NIL})
			AADD(_ACABPV , {"C5_PBRUTO"  , NPESO                 , NIL})
			If !lMvLocBac
				IF SC5->(FIELDPOS("C5_XPROJET")) > 0
					AADD(_ACABPV , {"C5_XPROJET" , FP0->FP0_PROJET       , NIL})
				EndIf
				IF SC5->(FIELDPOS("C5_XTIPFAT")) > 0
					If lItGeraRM
						AADD(_ACABPV , {"C5_XTIPFAT" , "I"                   , NIL}) // M=MEDICAO, P=PADRAO, I=INTEGRACAO RM
					else
						AADD(_ACABPV , {"C5_XTIPFAT" , "P"                   , NIL})
					endif
				EndIf
				IF SC5->(FIELDPOS("C5_XEXTRA")) > 0
					AADD(_ACABPV , {"C5_XEXTRA"  , "N"                   , NIL})
				EndIf
			EndIf

			AADD(_ACABPV , {"C5_SEGURO"  , _NVLRSEG              , NIL})

			AADD(_ACABPV , {"C5_NATUREZ" , _CNATUREZ             , NIL})

			AADD(_ACABPV , {"C5_MOEDA"   , FP0->FP0_MOEDA        , NIL})
			//CONOUT("[LCJLF001.PRW] # ((FINAL  ARRAY SC5 - A))")
			// DSERLOCA-3759 - Circenis- Campos Mercado Internacional
			if cPaisLoc = "ARG" // Argentina
				AADD(_ACABPV , {"C5_DOCGER"  , '1'		      , NIL } ) // 1 = Fatura
			endif
			_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)

			IF _LOCA021D //EXISTBLOCK("LOCA021D")
				_cPerloc := EXECBLOCK("LOCA021D" , .T. , .T., {_CPERLOC} )
			ENDIF

			//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
			//Cabeçalho da Tabela de Pedido de Venda x Locação
			If lMvLocBac
				aFPY := {}
				Aadd(aFPY, {"FPY_FILIAL"	, XFILIAL("SC6")	,	NIL })
				//Aadd(aFPY, {"FPY_PEDVEN"	, _CNUMPED			,	NIL }) Removido por Frank em 18/09/23
				Aadd(aFPY, {"FPY_PEDVEN"	, ""				,	NIL })
				Aadd(aFPY, {"FPY_PROJET"	, FP0->FP0_PROJET	,	NIL })
				Aadd(aFPY, {"FPY_TIPFAT"	, "P"				,	NIL })
				Aadd(aFPY, {"FPY_STATUS "	, "1"				,	NIL }) //1=Pedido Ativo;2=Pedido Cancelado
				If FPY->(FieldPos("FPY_OBRA")) > 0
					Aadd(aFPY, {"FPY_OBRA", cPvObra , NIL })
				endif
			//	_NREGPR ++ - somando 1 a mais
			/*	if cPAR20 == 2 Nesse momento não será usado
					cAsOff := ""
					For nOff1 := 1 to len(aFPZ)
						For nOff2 := 1 to len(aFPZ[nOff1])
							If alltrim(aFPZ[nOff1][nOff2][1]) == "FPZ_AS"
								cAsOff += "{"+alltrim(aFPZ[nOff1][nOff2][2])+"}"
								Exit
							EndIF
						Next
					Next

					_NREGPR ++

				Endif */

			EndIf
			// Se a FPA tiver frete
			IF LITEMFRT
				IF _NVLRFRETE > 0
					//NVALTOT += _NVLRFRETE - DSERLOCA-2882 Frank em 11/04/2024
					IF SB1->( DBSEEK( XFILIAL("SB1")+ CITEMFRT ) )
						//NITENS := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
						// Frank em 27/12/2022 chamado 612
						NITENS := soma1(nItens)
						_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)

						IF _LOCA021D //EXISTBLOCK("LOCA021D")
							_cPerloc := EXECBLOCK("LOCA021D" , .T. , .T., {_CPERLOC} )
						ENDIF

						// Identificação do local padrão de estoque
						If empty(FPA->FPA_LOCAL) // não informado na locação o local de estoque
							// utilizar o default informado no cadastro de produtos
							_cLocaPad := SB1->B1_LOCPAD
						Else
							_cLocaPad := FPA->FPA_LOCAL
						EndIF

						_AITEMTEMP := {}
						//aadd(_AITEMTEMP, {"C6_NUM"     , _CNUMPED       , NIL}) Comentado por Frank em 18/09/23
						aadd(_AITEMTEMP, {"C6_FILIAL"  , XFILIAL("SC6") , NIL})
						aadd(_AITEMTEMP, {"C6_ITEM"    , NITENS         , NIL})
						aadd(_AITEMTEMP, {"C6_PRODUTO" , SB1->B1_COD    , NIL})
						aadd(_AITEMTEMP, {"C6_DESCRI"  , SB1->B1_DESC   , NIL})
						aadd(_AITEMTEMP, {"C6_QTDVEN"  , 1              , NIL})
						aadd(_AITEMTEMP, {"C6_PRCVEN"  , _NVLRFRETE     , NIL})
						aadd(_AITEMTEMP, {"C6_PRUNIT"  , _NVLRFRETE     , NIL})
						aadd(_AITEMTEMP, {"C6_VALOR"   , _NVLRFRETE     , NIL})
						nTotPed += _NVLRFRETE
						aadd(_AITEMTEMP, {"C6_QTDLIB"  , 1              , NIL})
						aadd(_AITEMTEMP, {"C6_TES"     , _CTES          , NIL})
						aadd(_AITEMTEMP, {"C6_CC"      , FPA->FPA_CUSTO , NIL})
						IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
							AADD(_AITEMTEMP      , {"C6_CLVL"    , AllTrim(FPA->FPA_AS)           , NIL})
						ENDIF
						IF !lMvLocBac .And. SC6->(FIELDPOS("C6_XPERLOC")) > 0
							aadd(_AITEMTEMP, {"C6_XPERLOC" , _CPERLOC       , NIL})
						EndIF

						//CONOUT("[LCJLF001.PRW] # ((FINAL  ARRAY SC6 - C))")
						AADD(_AITENSPV , ACLONE(_AITEMTEMP))
						_LINCFRETE := .F.
						_NREG++

						//soma total do pedido
						nValTot	  += _NVLRFRETE


						//SIGALOC94-394 - Aglutinação para pedidos de vendas usando FP0
						IF lAglutinar
							//Aadd(SB1->B1_COD, _NVLRFRETE)
							//determina o produto pelo tipo de serviço
							If FPA->FPA_TIPOSE == "L"
								cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODL), FP0->FP0_PRODL , cMvLOCX063)
							ElseIf FPA->FPA_TIPOSE $ "O|Z"
								cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODOZ), FP0->FP0_PRODOZ , cMvLOCX063)
							ElseIf FPA->FPA_TIPOSE == "M"
								cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODM), FP0->FP0_PRODM , cMvLOCX064)
							EndIf
							//caso não tenha nada no array adiciona
							If Len(aAgluNf) == 0 .Or. aScan(aAgluNf,{|x| x[1]  == cPrdAgluNf}) == 0
								Aadd(aAgluNf, { cPrdAgluNf , _NVLRFRETE , NITENS })
								//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
								aItemAGG := {}
								Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(1,2)	,	NIL })
								Aadd(aItemAGG, {"AGG_PERC"		, _NVLRFRETE			,	NIL }) //será atualizado mais a frente com a proporção
								Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
								if _LCVAL
									Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
								else
									Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
								endif
								//campos vazios devem ser enviados
								Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
								Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
								Aadd(aAgluRat, { NITENS , {aClone(aItemAGG)} })
							Else
								/* Se Existir produto só ajustar
 								//caso já exista o array verifica se o produto já foi adicionado
								nPosPrdAgl := aScan(aAgluNf,{|x| x[1]==cPrdAgluNf})*/
								nForca := 0
								IF lLOC021W
									nForca := EXECBLOCK("LOCA021W" , .T. , .T. , {} )
								ENDIF
									//se não existir o produto no array adiciona
								/*If nPosPrdAgl == 0 .or. nForca > 0
									Aadd(aAgluNf, { cPrdAgluNf ,_NVLRFRETE , NITENS })
									nPosPrdAg := Len(aAgluNf)
									//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
									aItemAGG := {}
									Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(1,2)	,	NIL })
									Aadd(aItemAGG, {"AGG_PERC"		, _NVLRFRETE			,	NIL }) //será atualizado mais a frente com a proporção
									Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
									if _LCVAL
										Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
									else
										Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
									endif
									//campos vazios devem ser enviados
									Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
									Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
									Aadd(aAgluRat, { NITENS , {aClone(aItemAGG)} })
									//se não, soma valor no produto já existente
									else */
								aAgluNf[nPosPrdAgl][2] += _NVLRFRETE
								//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
								aItemAGG := {}
								Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(1,2)	,	NIL })
								Aadd(aItemAGG, {"AGG_PERC"		, _NVLRFRETE			,	NIL }) //será atualizado mais a frente com a proporção
								Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
								if _LCVAL
									Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
								else
									Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
								endif
								//campos vazios devem ser enviados
								Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
								Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
								Aadd(aAgluRat[nPosPrdAgl][2], aClone(aItemAGG) )
								//EndIf
							EndIf
						EndIf

						//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
						//Itens da Tabela de Pedido de Venda x Locação
						If lMvLocBac
							aItemFPZ := {}
							Aadd(aItemFPZ, {"FPZ_FILIAL"	, XFILIAL("SC6")	,	NIL })
							//Aadd(aItemFPZ, {"FPZ_PEDVEN"	, _CNUMPED			, 	NIL }) // Removido por Frank em 18/09/23
							Aadd(aItemFPZ, {"FPZ_PEDVEN"	, ""				, 	NIL })
							Aadd(aItemFPZ, {"FPZ_DTPED"	, dDataBase				, 	NIL })
							Aadd(aItemFPZ, {"FPZ_DTINI"	, _DDTINI				, 	NIL })
							Aadd(aItemFPZ, {"FPZ_DTFIM"	, _DDTFIM				, 	NIL })
							Aadd(aItemFPZ, {"FPZ_PROJET"	, FPA->FPA_PROJET	,	NIL })
							Aadd(aItemFPZ, {"FPZ_PRVFAT"	, FPA->FPA_ULTFAT	,	NIL })
							IF lAglutinar
								if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
									Aadd(aItemFPZ, {"FPZ_ITEM"		    , StrZero(nPosPrdAgl, TAMSX3("FPZ_ITEM")[1],0),	NIL })
								else
									Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
								endif
							ELSE
								Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
							ENDIF
							Aadd(aItemFPZ, {"FPZ_AS"		, cAuxAs		    , 	NIL }) // Rossana
							Aadd(aItemFPZ, {"FPZ_EXTRA"		, "N"				,	NIL })
							Aadd(aItemFPZ, {"FPZ_PERLOC"	, cAuxPerL			,	NIL })
							Aadd(aItemFPZ, {"FPZ_CCUSTO"	, FPA->FPA_CUSTO	,	NIL })
							//Aadd(aItemFPZ, {"FPZ_QUANT"		, 1  				,	NIL })
							//Aadd(aItemFPZ, {"FPZ_VALUNI"	, _NVLRFRETE		,	NIL })
							//Aadd(aItemFPZ, {"FPZ_TOTAL "	, _NVLRFRETE	,	NIL })
							//Aadd(aItemFPZ, {"FPZ_PROD  "	, SB1->B1_COD   	,	NIL })
							//Aadd(aItemFPZ, {"FPZ_VIAGEM"	, FPA->FPA_VIAGEM	,	NIL })
							//Aadd(aItemFPZ, {"FPZ_DIAS"	    , _DDTFIM - _DDTINI + 1	,	NIL })
							// DSERLOCA-2600 - Frank em 13/03/24
							// Se o campo FPA_GERAEM estiver em branco nada se faz
							If FPZ->(FIELDPOS("FPZ_GERAEM")) > 0 .and. FPA->(FIELDPOS("FPA_GERAEM")) > 0
								dGeraem := ctod("")
								If !lPreviewX
									If !empty(FPA->FPA_GERAEM)
										If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
											dGeraem := MONTHSUM(FPA->FPA_GERAEM,1)
										else // dias corridos
											dGeraem := FPA->FPA_GERAEM + FPA->FPA_LOCDIA
										EndIF
										Aadd(aItemFPZ, {"FPZ_GERAEM", FPA->FPA_GERAEM,	NIL })
									EndIf
								//Else
								//	If !empty(dGeraEm248)
								//		If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
								//			dGeraem := MONTHSUM(dGeraEm248,1)
								//		else // dias corridos
								//			dGeraem := dGeraEm248 + FPA->FPA_LOCDIA
								//		EndIF
								//		Aadd(aItemFPZ, {"FPZ_GERAEM", dGeraEm248,	NIL })
								//	EndIf
								EndIf
							endif

							if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
								Aadd(aItemFPZ, {"FPZ_ITMFPZ", NITENS ,	NIL })
								Aadd(aItemFPZ, {"FPZ_QUANT" , 1,	NIL })
								Aadd(aItemFPZ, {"FPZ_VALUNI", ROUND(_NVLRFRETE,SC6->(GETSX3CACHE("C6_PRUNIT","X3_DECIMAL"))),	NIL })
								Aadd(aItemFPZ, {"FPZ_PROD"  , SB1->B1_COD,	NIL })
								Aadd(aItemFPZ, {"FPZ_VIAGEM", "",	NIL })
								Aadd(aItemFPZ, {"FPZ_DIAS"  , _DDTFIM - _DDTINI + 1,	NIL })
								Aadd(aItemFPZ, {"FPZ_TOTAL" , _NVLRFRETE,	NIL })
								Aadd(aItemFPZ, {"FPZ_OBRA"  , FPA->FPA_OBRA,	NIL })

								if _LCVAL
									Aadd(aItemFPZ, {"FPZ_CLVL"  , FPA->FPA_AS,	NIL })
								endif
					
								Aadd(aItemFPZ, {"FPZ_TES" , _CTES                 , NIL})
								
							endif
							Aadd(aFPZ,Aclone(aItemFPZ))
						EndIf

					ELSE
						MSGALERT(STR0040+ ALLTRIM(CITEMFRT) + STR0041 , STR0017)  //"FATURAMENTO AUTOMÁTICO - NÃO FOI ENCONTRADO O PRODUTO DE FRETE -> "###"CADASTRADO NO PARÂMETRO MV_LOCX069"###"GPO - LCJLF001.PRW"
						AADD(_ACABPV , {"C5_FRETE"   , _NVLRFRETE , NIL})
					ENDIF
				ENDIF
			ELSE
				AADD(_ACABPV , {"C5_FRETE"   , _NVLRFRETE , NIL})
			ENDIF

			//SIGALOC94-944 - 17/07/2023 -  Jose Eulalio - Condição de Pagamenteo tipo 9
			SE4->(DBSETORDER(1))
			If SE4->( MSSEEK(XFILIAL("SE4") + _CPAGTO, .F. ) ) .And. SE4->E4_TIPO == "9"
				If AllTrim(SE4->E4_COND) == "0"
					nParc1 := nValTot
				EndIf
				dDtFim := IIF(FPA->FPA_DTFIM < dDataBase, dDataBase, FPA->FPA_DTFIM)
				AADD(_ACABPV     , {"C5_PARC1"  , nParc1	, NIL } )
				AADD(_ACABPV     , {"C5_DATA1"  , dDtFim	, NIL } )
			EndIf

			IF _LCJLFCAB //EXISTBLOCK("LCJLFCAB") 								// --> PONTO DE ENTRADA PARA INCLUSÃO DE CAMPOS NO CABEÇALHO DO PEDIDO DE VENDA.
				_ACABPV := EXECBLOCK("LCJLFCAB" , .F. , .F. , {_ACABPV,"C"}) 	// --> Alterado para .F. conforme solicitado pelo Circenis - Djalma 14/10/2022
			ENDIF
			IF _LCJLFCAB //EXISTBLOCK("LCJLFCAB")
				_AITENSPV := EXECBLOCK("LCJLFCAB" , .F. , .F. , {_AITENSPV,"I"}) // --> Alterado para .F. conforme solicitado pelo Circenis - Djalma 14/10/2022
			ENDIF


			// SE HOUVER O PARÂMETRO INDICANDO QUE PRECISA DE UM PEDIDO AGLUTINADO PARA INTEGRAÇÃO COM RM
			// GERAMOS o pedido  VENDAS COM OS ITENS AGLUTINADOS.
			// Alexandre Circenis  - 03/10/2023
			// --------------------------------------------------------------------------------------------------------------------
			//SIGALOC94-394 - Aglutinação para pedidos de vendas usando FP0
			If lAglutinar
				_AITENSPV := {}
				FOR _NX:=1 TO LEN(aAgluNf)

					SB1->(DBSETORDER(1))
					SB1->(DBSEEK(XFILIAL("SB1") + aAgluNf[_NX][1]))

					//monta os itens
					_AAGLUTINA := {}
					//aadd(_AAGLUTINA, {"C6_NUM"     , _CNUMPED2      , NIL}) Comentado por Frank em 18/09/23
					aadd(_AAGLUTINA, {"C6_FILIAL"  , XFILIAL("SC6") , NIL})
					aadd(_AAGLUTINA, {"C6_ITEM"    , StrZero(_NX,nTamItem), NIL})
					aadd(_AAGLUTINA, {"C6_PRODUTO" , SB1->B1_COD    , NIL})
					aadd(_AAGLUTINA, {"C6_DESCRI"  , SB1->B1_DESC   , NIL})
					aadd(_AAGLUTINA, {"C6_QTDVEN"  , 1              , NIL})
					aadd(_AAGLUTINA, {"C6_PRCVEN"  , aAgluNf[_NX][2], NIL})
					aadd(_AAGLUTINA, {"C6_PRUNIT"  , aAgluNf[_NX][2], NIL})
					aadd(_AAGLUTINA, {"C6_VALOR"   , aAgluNf[_NX][2], NIL})
					aadd(_AAGLUTINA, {"C6_QTDLIB"  , 1              , NIL})
					aadd(_AAGLUTINA, {"C6_TES"     , _CTES          , NIL})
					aadd(_AAGLUTINA, {"C6_CC"      , _CCUSTOAG      , NIL})

					nTotAlguNf += aAgluNf[_NX][2]

					IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
						aadd(_AAGLUTINA, {"C6_XPERLOC" , _CPERLOC       , NIL})
					EndIF
					AADD(_AITENSPV , ACLONE(_AAGLUTINA))

				Next _nX

			endif
			// Gerar o Pedido baseado na FPA
			IF _NREG > 0 .and. lGeraPVx

				LMSERROAUTO := .F.
				// Sprint 3 - Frank Z Fuga - EAI - 04/10/22
				If !empty(cLocx299)
					SetRotInteg("MATA410")
				EndIf

				// Se Houver Aglutinção processar o array antes de gravar
				If Len(aAgluRat) > 0
					nAgluTot := 0
					//pega posição dos campos
					nPosPv 		:= aScan(aAgluRat[1][2][1],{|x| AllTrim(x[1])=="AGG_ITEM"})
					nPosPerc 	:= aScan(aAgluRat[1][2][1],{|x| AllTrim(x[1])=="AGG_PERC"})
					//soma total dos itens
					For _nX := 1 To Len(aAgluRat)
						nAgluTot := 0
						For nX := 1 To Len(aAgluRat[_nX][2])
							//nAgluTot += aAgluRat[_nX][2][nx][nPosPerc][2]
							nAgluTot += aAgluRat[_nX][2][nx][nPosPerc][2]
						Next nX

						For nX := 1 To Len(aAgluRat[_nX][2])
							//aAgluRat[_nX][2][nx][nPosPerc][2] 	:= (aAgluRat[_nX][2][nx][nPosPerc][2] / nAgluTot) * 100 // atualiza proporção
							aAgluRat[_nX][2][nx][nPosPerc][2] 	:= (aAgluRat[_nX][2][nx][nPosPerc][2] / nAgluTot) * 100 // atualiza proporção
						 //	aAgluRat[_nX][2][nx][nPosPv][2] 	:=  StrZero(nX,2)										// atualiza item
						Next nX


					Next _nX

					//exectua rotina automática
					//MSEXECAUTO({|X,Y,Z,,,,,W| MATA410(X,Y,Z,,,,,W)} , _ACABPV , _AITENSPV , 3 , , , , , aAgluRat)
					//pega retorno
					If len(_aCabPV) > 0 .and. len(_aItensPV) > 0
						lMsg := .T.
						If cPAR20 == 1 // Frank 13/11/24
							If LOCA021V(_ACABPV, _AITENSPV, aAGlurat)
								// Frank - 30/07/25 - ISSUE 7851
								// Tratamento para validação no execauto se é para executar apenas o preview do faturamento sem gerar nada.
								If !lPreviewX
									MSEXECAUTO({|X,Y,Z,W| MATA410(X,Y,Z,,,,,W)} , _ACABPV , _AITENSPV , 3, aAGlurat)
								Else
									LOCA021I(_aCabPV)
								EndIf
							Else
								If !_LJOB .and. !lLOC21Auto
									MsgStop(STR0137,STR0033) //"Houve um erro na geração dos complementos do faturamento FPY e FPZ, o pedido de vendas não será gerado."###"Atenção!"
								EndIf
								LMSERROAUTO := .T.
								lMsg := .F.
							EndIf
						EndIF
					EndIf
				else
					If len(_aCabPV) > 0 .and. len(_aItensPV) > 0
						lMsg := .T.
						If cPAR20 == 1 // Frank 13/11/24
							If LOCA021V(_ACABPV, _AITENSPV)
								// Frank - 30/07/25 - ISSUE 7851
								// Tratamento para validação no execauto se é para executar apenas o preview do faturamento sem gerar nada.
								If !lPreviewX
									MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABPV , _AITENSPV , 3)
								Else
									LOCA021I(_aCabPV)
								EndIf
							Else
								If !_LJOB .and. !lLOC21Auto
									MsgStop(STR0137,STR0033) //"Houve um erro na geração dos complementos do faturamento FPY e FPZ, o pedido de vendas não será gerado."###"Atenção!"
								EndIf
								LMSERROAUTO := .T.
								lMsg := .F.
							EndIf
						EndIF
					EndIF
				endif

				If len(_aCabPV) > 0 .and. len(_aItensPV) > 0 .and. cPAR20 == 1 .and. lPreviewX .and. len(_aass) > 0
					dUltFat248 := _AASS[1][6]
					dDtFim248  := _AASS[1][7]
					dGeraEm248 := _AASS[1][8]
				EndIf

				If len(_aCabPV) > 0 .and. len(_aItensPV) > 0 .and. cPAR20 == 1 .and. !lPreviewX // Frank 13/11/24
					IF LMSERROAUTO
						If !_LJOB .and. !lLOC21Auto .and. lMsg
							MOSTRAERRO()
						EndIF

						If lMsg
							ROLLBACKSXE()
						EndIf
						
						If lLOC21Auto .or. _lJob
							if lOffLine
								aRetJob[1] += STR0131+FPA->FPA_PROJET+STR0130+FPA->FPA_OBRA +CRLF //" obra : " //"Erro ao Gerar Pedido Projeto :"
								
								If lMsg
									aErro := GetAutoGRLog()
								Else
									aErro := {}
									aadd(aErro,STR0137) //"Houve um erro na geração dos complementos do faturamento FPY e FPZ, o pedido de vendas não será gerado."
								EndIf
								
								for nX := 1 to Len(aErro)
									aRetJob[1] += aErro[nX] + CRLF
								Next nX
								aRetJob[1] += CRLF
							endif
							cErroAut := ""
							LMSERROAUTO := .T.
							lPrefer := .T.
						EndIF
					ELSE
						CONFIRMSX8()
						_NVLRFRETE := 0
						_NVLRSEG   := 0
						_NREGPR++

						AADD( APEDIDOS , SC5->C5_NUM )

						IF RECLOCK("SC5", .F.)
							SC5->C5_ORIGEM := "LOCA021"
							SC5->(MSUNLOCK())
						ENDIF
						If  (lLOC21Auto .or. _lJob) .and. lOffLine
							aRetJob[2,1] += STR0134+FPA->FPA_PROJET+STR0130+FPA->FPA_OBRA+ STR0133+ SC5->C5_NUM+STR0132+TransForm( nToTPed,"@E 999,999,999,999.99") //" Valor : " //" Pedido : " //" obra : " //"Projeto :"
							aRetJob[2,2]++
							aRetJob[2,3] += nTotPed
							nTotPed := 0
						endif
						//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
						//Grava Tabela de Pedido de Venda x Locação
						If lMvLocBac
							// Alimentar os arrays com o pedido gerado Frank 18/09/23
							aFPY[2,2] := SC5->C5_NUM
							For _nX := 1 to len(aFPZ)
								aFPZ[_nX,2,2] := SC5->C5_NUM
							Next
							LOCA0822(aFPY,aFPZ,NIL)
							aFPZ := {}
						EndIf

						IF lLCX049    // PONTO DE ENTRADA PARA REGRA ESPECÍFICA AO UTILIZAR MV_LOCX049
						    lRegra049 := EXECBLOCK("LOCA2149" , .F. , .F. ,{lRegra049,SC5->C5_NUM} ) 
						ENDIF   

						// Geramos fatura somente para o Pais Brasil
						IF LFATURA .and. cPaisLoc = "BRA" .and. lRegra049
							aNota := GRAVANFS(SC5->C5_NUM)
							If  (lLOC21Auto .or. _lJob) .and. lOffLine
								if ValType(aNota) = "A"
									aRetJob[2,1] += STR0136+aNota[1]+STR0135+aNota[2] //" Serie : " //" Nota : "
								endif
							endif
						ENDIF

						// FRANK - 08/12/2020 - ATUALIZACAO DO CAMPO C6_XPERLOC
						FOR _NX := 1 TO LEN(_AITENSPV)
							If !lMvLocBac
								_cPerLocx := ""
								For _nP := 1 to len(_aItensPV[_nX])
									IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
										If alltrim(_aItensPV[_nX][_nP][01]) == "C6_XPERLOC"
											_cPerLocx := _aItensPV[_nX][_nP][02]
										EndIf
									EndIF
								Next

								_nPosItemX := ASCAN(_aitenspv[_NX],{|X| ALLTRIM(X[1])=="C6_ITEM"})

								SC6->(DBSETORDER(1))
								//IF SC6->(DBSEEK(XFILIAL("SC6")+_CNUMPED+_AITENSPV[_NX][3][2])) Removido por Frank em 18/09/23
								IF SC6->(DBSEEK(XFILIAL("SC6")+SC5->C5_NUM+_AITENSPV[_NX][_nPosItemX][2]))
									SC6->(RECLOCK("SC6",.F.))
									IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
										SC6->C6_XPERLOC := _cPerLocx //_AITENSPV[_NX][16][2]
									EndIf
									IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0
										SC6->C6_XCCUSTO := SC6->C6_CC
									EndIF
									SC6->(MSUNLOCK())
								ENDIF
							EndIf
						NEXT

						// Frank - 15/02/21 - Baixa dos custos extras negativos
						If _lDescCus
							For _nX := 1 to len(_aDescCus)
								FPG->(dbGoto(_aDescCus[_nX][01]))

								If empty(FPG->FPG_SEQ)
									_cSeq := GetSx8Num("FPG","FPG_SEQ")
									ConfirmSx8()
									If FPG->(RecLock("FPG",.F.))
										FPG->FPG_SEQ := _cSeq
										FPG->(MsUnlock())
									EndIF
								EndIf

								IF _LCJATFPG //EXISTBLOCK("LCJATFPG")
									EXECBLOCK("LCJATFPG" , .T. , .T. , {})
								ELSE
									FPG->(RecLock("FPG",.F.))
									FPG->FPG_STATUS := "2"
									//FPG->FPG_PVNUM  := _CNUMPED Removido por Frank em 18/09/23
									FPG->FPG_PVNUM  := SC5->C5_NUM
									FPG->FPG_PVITEM := _aDescCus[_nX][03]
									FPG->(MsUnlock())
								EndIF
							Next
							_aDescCus := {}
						EndIF

						DBSELECTAREA("FPA")
						FOR _NX := 1 TO LEN(_AASS)
							_aass[_nX,4] := SC5->C5_NUM
							FPA->(DBSETORDER(6))
							IF FPA->(DBSEEK(XFILIAL("FPA") + _AASS[_NX][1] + _AASS[_NX][2]))
								IF _LCJATZAG //EXISTBLOCK("LCJATZAG") 				// --> PONTO DE ENTRADA APÓS A ALTERAÇÃO DE CADA ITEM DA ZAG.
									EXECBLOCK("LCJATZAG" , .T. , .T. , {})
								ELSE
									IF RECLOCK("FPA",.F.)
										FPA->FPA_ULTFAT := _AASS[_NX][6]
										FPA->FPA_DTFIM  := _AASS[_NX][7]
										If FPZ->(FIELDPOS("FPZ_GERAEM")) > 0 .and. FPA->(FIELDPOS("FPA_GERAEM")) > 0
											FPA->FPA_GERAEM := _AASS[_NX][8]
										EndIf
										FPA->(MSUNLOCK())
									ENDIF
								ENDIF
							ENDIF

							// DSERLOCA-6564 - Frank em 04/07/2025
							// Tratamento da geração do título provisório pelo campo FP0_PROV
							If FP0->(FieldPos("FP0_PROV")) > 0
								If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
									_MV_LOC278 := .T.
								Else
									_MV_LOC278 := .F.
								EndIf
							EndIf

							If _MV_LOC278 //supergetmv("MV_LOCX278",,.T.)
								DELTITPR(FPA->FPA_AS, FPA->FPA_PROJET)
							EndIf

							IF _MV_LOC243 //SUPERGETMV("MV_LOCX243",.F.,.F.)
								LOCA062(SC5->C5_FILIAL , _AASS[_NX][4] , _AASS[_NX][5] , FPA->FPA_FILIAL , _AASS[_NX][1] , _AASS[_NX][2])
							ENDIF
						NEXT _NX

						FOR _NX := 1 TO LEN(_AZC1FAT)
							_aZc1Fat[_nX,2] := SC5->C5_NUM
							DBSELECTAREA("FPG")
							FPG->(DBGOTO(_AZC1FAT[_NX][01]))

							If empty(FPG->FPG_SEQ)
								_cSeq := GetSx8Num("FPG","FPG_SEQ")
								ConfirmSx8()
								If FPG->(RecLock("FPG",.F.))
									FPG->FPG_SEQ := _cSeq
									FPG->(MsUnlock())
								EndIF
							EndIf

							IF _LCJATFPG // EXISTBLOCK("LCJATFPG")
								EXECBLOCK("LCJATFPG" , .T. , .T. , {})
							ELSE
								IF RECLOCK("FPG",.F.)
									FPG->FPG_STATUS := "2"					// FATURADO
									FPG->FPG_PVNUM  := _AZC1FAT[_NX][02]
									FPG->FPG_PVITEM := _AZC1FAT[_NX][03]
									FPG->(MSUNLOCK())
									//Copia o Banco de Conhecimento do Custo Extra para o Pedido de Venda (LOCA007.PRW)
									LC007BCOPV(SC5->C5_FILIAL,FPG->FPG_PVNUM)
								ENDIF
							EndIF
						NEXT _NX

						IF _LCJATFIM //EXISTBLOCK("LCJATFIM")
							EXECBLOCK("LCJATFIM" , .T. , .T. , NIL)
						ENDIF

						If  (lLOC21Auto .or. _lJob) .and. lOffLine
							aRetJob[2,1] += CRLF // Salta de Linha do Log
						endif
					EndIF
				EndIf
			endif

			IF len(_AITENSPV) > 0 .and. cPAR20 == 1 // Frank 13/11/24//_NREG > 0 .and. !lGeraPVx
				IF _LOCA061Z //EXISTBLOCK("LOCA061Z")
					For _nX := 1 to len(_aZc1Fat)
						_aZc1Fat[_nX,2] := SC5->C5_NUM
					Next
					EXECBLOCK("LOCA061Z" , .T. , .T. , {_ACABPV,_AITENSPV,_AZC1FAT,lGeraPVx})
				EndIF
			ENDIF

			IF LCLIBLQ .and. cPAR20 == 1 .and. !lPreviewX // Frank 13/11/24
				SA1->( DBGOTO(NSA1RECNO) )
				IF RECLOCK("SA1", .F.)
					SA1->A1_MSBLQL := "1"
					SA1->(MSUNLOCK())
				ENDIF
			ENDIF

			DBSELECTAREA("TMP")
		ENDDO

		TMP->( DBCLOSEAREA() )

	ENDIF			// IF CPAR11 == 1 .OR. CPAR11 == 3 				// 1 - LOCAÇÃO / 3 - AMBOS

	IF CPAR11 == 2 .OR. CPAR11 == 3 								// 2 - CUSTOS EXTRAS / 3 - AMBOS

		IF SELECT("TRBFPG") > 0
			TRBFPG->( DBCLOSEAREA() )
		ENDIF
		aBindParam := {}
		_CQUERY     := " SELECT FPG_PRODUT , FPG_QUANT  , FPG_DESCRI , FPG_VLUNIT , FPG_NATURE, "
		_CQUERY     += "        FPG_TAXAV  , FPG_VALTOT , ZC1.R_E_C_N_O_ ZC1RECNO , "
		_CQUERY     += "        ZA0.R_E_C_N_O_ ZA0RECNO , ZAG.R_E_C_N_O_ ZAGRECNO , "
		_CQUERY     += "        FP1.R_E_C_N_O_ FP1RECNO , "
		_CQUERY     += " 	    FP0_PROJET PROJET ,FP0_VENDED "
		_CQUERY += ", CASE"
		If FPA->(ColumnPos("FPA_CLIFAT")) > 0
			_CQUERY += " WHEN FPA_CLIFAT <> ' ' THEN FPA_CLIFAT"
		ENDIF
		_CQUERY += " WHEN FP1_CLIDES <> ' ' THEN FP1_CLIDES"
		_CQUERY += " ELSE FP0_CLI"
		_CQUERY += " END CLIFAT,"
		_CQUERY += " CASE"
		If FPA->(ColumnPos("FPA_CLIFAT")) > 0
			_CQUERY += " WHEN FPA_LOJFAT <> ' ' THEN FPA_LOJFAT"
		endif
		_CQUERY += " WHEN FP1_LOJDES <> ' ' THEN FP1_LOJDES"
		_CQUERY += " ELSE FP0_LOJA"
		_CQUERY += " END LOJFAT, "
		_CQUERY += " CASE"
		If FPA->(ColumnPos("FPA_CLIFAT")) > 0
			_CQUERY += " WHEN FPA_CLIFAT <> ' ' THEN FPA_NOMFAT"
		endif
		_CQUERY += " WHEN FP1_CLIDES <> ' ' THEN FP1_NOMDES"
		_CQUERY += " ELSE A1_NOME"
		_CQUERY += " END NOMFAT
		_CQUERY     += " FROM " + RETSQLNAME("FPG") + " ZC1 "
		_CQUERY     += "        INNER JOIN " + RETSQLNAME("FPA") + " ZAG ON  ZAG.FPA_AS     = FPG_NRAS   AND  ZAG.FPA_AS    <> '' "
		_CQUERY     += "                                                 AND ZAG.D_E_L_E_T_ = ''  "

		// Novos filtros do produto e acerto do funcionamento do filtro dos bens - Frank em 08/09/21
		If _lTem12 .and. _lTem13
			_CQUERY += " AND ZAG.FPA_PRODUT BETWEEN ? AND ? "
			aadd(aBindParam,CPAR12)
			aadd(aBindParam,CPAR13)
		EndIF
		_CQUERY += " AND ZAG.FPA_GRUA BETWEEN ? AND ? "
		aadd(aBindParam,CPAR07)
		aadd(aBindParam,CPAR08)

		_CQUERY     += "        INNER JOIN " + RETSQLNAME("FQ5") + " DTQ ON  DTQ.FQ5_AS     = FPA_AS     AND  DTQ.FQ5_SOT    = FPA_PROJET "
		_CQUERY     += "                                                 AND DTQ.FQ5_STATUS = '6' "
		_CQUERY     += "                                                 AND DTQ.D_E_L_E_T_ = ''  "
		_CQUERY     += "        INNER JOIN " + RETSQLNAME("FP0") + " ZA0 ON  ZA0.FP0_FILIAL = FPA_FILIAL AND  ZA0.FP0_PROJET = FPA_PROJET "
		_CQUERY += "                                                 AND ZA0.FP0_PROJET BETWEEN ? AND ? "
		aadd(aBindParam,CPAR09)
		aadd(aBindParam,CPAR10)
		_CQUERY     += "                                                 AND ZA0.D_E_L_E_T_ = '' "
		_CQUERY     += "        INNER JOIN "+RETSQLNAME("FP1")+" FP1 ON FP1.FP1_FILIAL = FPA_FILIAL"
		_CQUERY     += "                                                 AND FP1.FP1_PROJET = FPA_PROJET"
		_CQUERY     += "                                                 AND FP1_OBRA = FPA_OBRA"
		_CQUERY     += "                                                 AND FP1.D_E_L_E_T_ = '' "
		_cQuery 	+= " JOIN "+RETSQLNAME("SA1")+" SA1 (NOLOCK) ON A1_FILIAL ='"+XFILIAL("SA1")+"' AND SA1.D_E_L_E_T_ = ' ' AND A1_COD = FP0_CLI AND A1_LOJA = FP0_LOJA "

		// DSERLOCA-2142 Frank em 26/01/24
		_CQUERY += " AND FP1_OBRA >= ? AND FP1_OBRA <= ? "
		aadd(aBindParam,CPAR15)
		aadd(aBindParam,CPAR16)

		If cPAR17 == 1 // Tipo de mês mensal - DSERLOCA-2600 - Frank em 12/03/24
			_cQuery += " AND (FP1_TPMES = '0' OR FP1_TPMES = '2') "
		EndIf
		If cPAR17 == 2 // Tipo de mês corrido - DSERLOCA-2600 - Frank em 12/03/24
			_cQuery += " AND FP1_TPMES = '1' "
		EndIf

		_CQUERY     += " WHERE  FPG_FILIAL = '" + XFILIAL("FPG") + "'"
		_CQUERY     += "   AND  FPG_COBRA IN ('S','D')"
		IF CPAR11 == 3 												// AMBOS -> CONSIDERA APENAS N, POIS O S JÁ FOI FATURADO NO PEDIDO DA LOCAÇÃO
			_CQUERY += "   AND  FPG_JUNTO = 'N' "
		ENDIF
		_CQUERY     += "   AND  FPG_STATUS = '1' "
		_CQUERY     += "   AND  FPG_PRODUT <> '' "
		_CQUERY += "   AND (FPG_DTENT BETWEEN ? AND ? "
		aadd(aBindParam,DTOS(DPAR01))
		aadd(aBindParam,DTOS(DPAR02))
		_CQUERY     += "    OR  FPG_DTENT = '') "
		_CQUERY     += "   AND  ZC1.D_E_L_E_T_ = ''"
		_CQUERY     += "   AND FPG_VALTOT > 0 "


		_CQUERY     += " ORDER BY 	FPA_PROJET, FPA_OBRA,  "
		_CQUERY     += " 			CLIFAT DESC , LOJFAT, FPA_AS, "  // ORDENADO POR CLIENTE para facilitar a quebra posterior do PV
		_CQUERY     += "  			FPG_DTENT , ZC1RECNO "
		_CQUERY     := CHANGEQUERY(_CQUERY)
		MPSysOpenQuery(_cQuery,"TRBFPG",,,aBindParam)
		TRBFPG->(dbGotop())

		// Tela para seleção dos registros Frank em 27/10/21
		nForca := 0
		IF lLOC021L
			nForca := EXECBLOCK("LOCA021L" , .T. , .T. , {} )
		ENDIF
		_ASZ1 := {}
		If !_lJob .and. (_lTem14 .or. nForca > 0) .and. !lLOC21Auto // se não for job e existe o pergunte da selecao
			If cPar14 == 2 .or. nForca > 0 // Se optou por selecionar os contratos para faturamento
				If cPar11 <> 3 .or. nForca > 0 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
					// Selecionar os contratos
					_ASZ1 := {}
					While !TRBFPG->(Eof()) .or. nForca > 0
						FPA->( DBGOTO( TRBFPG->ZAGRECNO ) )
						FP1->( DBGOTO(TRBFPG->FP1RECNO) )
						FP0->( DBGOTO(TRBFPG->ZA0RECNO) )

						//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
						cCliFat := TRBFPG->CLIFAT
						cLojFat := TRBFPG->LOJFAT
						cNomFat := alltrim(TRBFPG->NOMFAT)

						// Filtro do cliente após a identificação do clifat - Frank em 04/07/23
						If cCliFat < cPar03 .or. cCliFat > cPar04
							TRBFPG->(dbSkip())
							Loop
						EndIF
						If cLojFat < cPar05 .or. cLojFat > cPar06
							TRBFPG->(dbSkip())
							Loop
						EndIF

						SB1->(dbSetorder(1))
						SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))

						cProdNome := SB1->B1_DESC
						cCentrab := ""
						cCodFami := ""
						If !empty(FPA->FPA_GRUA)
							ST9->(dbSetOrder(1))
							If ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
								cProdNome := ST9->T9_NOME
								cCodFami := ST9->T9_CODFAMI
								If !empty(ST9->T9_CENTRAB)
									SHB->(dbSetOrder(1))
									If SHB->(dbSeek(xFilial("SHB")+ST9->T9_CENTRAB))
										cCenTrab := SHB->HB_NOME
									EndIF
								EndIF
							EndIF
						EndIF

						aadd(_ASZ1,{.T.,;
							FPA->FPA_OBRA,;
							FPA->FPA_SEQGRU,;
							FPA->FPA_PRODUT,;
							FPA->FPA_GRUA,;
							cProdNome,;
							FPA->FPA_QUANT,;
							FPA->FPA_PRCUNI,;
							FPA->FPA_PDESC,;
							FPA->FPA_VRHOR,;
							FPA->FPA_DTINI,;
							FPA->FPA_DTFIM,;
							FPA->FPA_DTENRE,;
							FPA->FPA_ULTFAT,;
							FPA->FPA_CONPAG,;
							cCodFami,;
							cCenTrab,;
							FPA->FPA_FILEMI,;
							FPA->FPA_NFREM,;
							FPA->FPA_SERREM,;
							FPA->FPA_NFRET,;
							FPA->FPA_SERRET,;
							FPA->FPA_AS,;
							cCliFat,;
							cLojFat,;
							cNomFat,;
							TRBFPG->ZC1RECNO,TRBFPG->ZAGRECNO,;
							FPA->FPA_PROJET,;
							FPA->FPA_DTSCRT})

						//aadd(_ASZ1,{.T.,FPA->FPA_PROJET,FPA->FPA_OBRA, FPA->FPA_AS, FPA->FPA_PRODUT, SB1->B1_DESC, TRBFPG->ZC1RECNO, TRBFPG->ZAGRECNO, cCliFat, cLojFat, cNomFat})
						// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
						IF lLOC021P
							aCompleX := EXECBLOCK("LOCA021P" , .T. , .T. , {3} )
							If len(aComplex) > 0
								For nX := 1 to len(aComplex[1])
									aadd(_aSZ1[len(_ASZ1)],aComplex[1,nX])
								Next
							EndIF
						ENDIF
						TRBFPG->(dbSkip())

						If nForca > 0
							If !lPrefer
								cErroAut := STR0123 //"Retorno negativado pelo ponto de entrada LOCA021L"
							EndIf
							LMSERROAUTO := .T.
							Return .F.
						EndIF

					EndDo

					If len(_aSZ1) == 0
						MsgAlert(STR0085,STR0007) // Não houve registro para a selecao###Atencao
						If !lPrefer
							cErroAut := STR0085 // Não houve registro para a selecao
						EndIf
						LMSERROAUTO := .T.
						Return .F.
					EndIF

					cOpcx := "0"
					_aSeleca2 := {}
					// custo extra
					DEFINE MSDIALOG ODLGFIL TITLE STR0076 FROM 010,005 TO 500,NJANELAL PIXEL//Seleção dos projetos
					@ 1.5,0.7 LISTBOX OFILOS FIELDS HEADER  " ",;
						STR0115,; //"Projeto"
					STR0090,; //"Obra"
					STR0091,; //"Seq."
					STR0092,; //"Produto"
					STR0093,; //"Bem"
					STR0094,; //"Descrição"
					STR0095,; //"Quantidade"
					STR0096,; //"Vlr.Unit."
					STR0097,; //"% Desc"
					STR0098,; //"Vlr. Base"
					STR0099,; //"Dt.Ini."
					STR0101,; //"Prox.Fat."
					STR0100,; //"Dt.Fim"
					STR0102,; //"Ult.Fat."
					STR0103,; //"Cond.Pag."
					STR0104,; //"Família"
					STR0105,; //"Descrição Centrab."
					STR0106,; //"Fil.Remessa"
					STR0107,; //"Nf.Remessa"
					STR0108,; //"Série Remessa"
					STR0109,; //"Nf.Retorno"
					STR0110,; //"Série Retorno"
					STR0111,; //"AS"
					STR0112,; //"Cod.Cliente"
					STR0113,; //"Loja"
					STR0114,; //"Nome"
					STR0116,; //"Dt.Sol.Retira"
					"",""; // Recno
					SIZE NLBTAML,NLBTAMA+55 ON DBLCLICK (MARCARREGI(.F.))


					// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
					IF lLOC021Q
						aCompleX := EXECBLOCK("LOCA021Q" , .T. , .T. , {3} )
						If len(aComplex) > 0
							For nX := 1 to len(aComplex[1])
								aadd(OFILOS:aHeaders,aComplex[1,nX])
							Next
						EndIF
					EndIF

					OFILOS:SETARRAY(_ASZ1)

					cLinha := "{|| { IF( _ASZ1[OFILOS:NAT,1],OOK,ONO),"
					cLinha += "_ASZ1[OFILOS:NAT,29],"
					cLinha += "_ASZ1[OFILOS:NAT,2],"
					cLinha += "_ASZ1[OFILOS:NAT,3],"
					cLinha += "_ASZ1[OFILOS:NAT,4],"
					cLinha += "_ASZ1[OFILOS:NAT,5],"
					cLinha += "_ASZ1[OFILOS:NAT,6],"
					cLinha += "_ASZ1[OFILOS:NAT,7],"
					cLinha += "_ASZ1[OFILOS:NAT,8],"
					cLinha += "_ASZ1[OFILOS:NAT,9],"
					cLinha += "_ASZ1[OFILOS:NAT,10],"
					cLinha += "_ASZ1[OFILOS:NAT,11],"
					cLinha += "_ASZ1[OFILOS:NAT,12],"
					cLinha += "_ASZ1[OFILOS:NAT,13],"
					cLinha += "_ASZ1[OFILOS:NAT,14],"
					cLinha += "_ASZ1[OFILOS:NAT,15],"
					cLinha += "_ASZ1[OFILOS:NAT,16],"
					cLinha += "_ASZ1[OFILOS:NAT,17],"
					cLinha += "_ASZ1[OFILOS:NAT,18],"
					cLinha += "_ASZ1[OFILOS:NAT,19],"
					cLinha += "_ASZ1[OFILOS:NAT,20],"
					cLinha += "_ASZ1[OFILOS:NAT,21],"
					cLinha += "_ASZ1[OFILOS:NAT,22],"
					cLinha += "_ASZ1[OFILOS:NAT,23],"
					cLinha += "_ASZ1[OFILOS:NAT,24],"
					cLinha += "_ASZ1[OFILOS:NAT,25],"
					cLinha += "_ASZ1[OFILOS:NAT,26],"
					cLinha += "_ASZ1[OFILOS:NAT,30],"
					cLinha += "_ASZ1[OFILOS:NAT,27],"
					cLinha += "_ASZ1[OFILOS:NAT,28]"

					// Card 428 sprint Bug - Frank Zwarg Fuga em 13/07/2022
					IF lLOC021Q
						aCompleX := EXECBLOCK("LOCA021Q" , .T. , .T. , {3} )
						If len(aComplex) > 0
							nComple := 30
							For nX := 1 to len(aComplex[1])
								nComple ++
								cLinha += ",_ASZ1[OFILOS:NAT,"+alltrim(str(nComple))+"]"
							Next
						EndIF
					EndIF
					cLinha += "}}"

					OFILOS:BLINE := &(cLinha)

					@ 230,007 BUTTON OMARKBUT 	PROMPT STR0089 SIZE 55,12 OF ODLGFIL PIXEL ACTION (MARCARREGI(.T.)) //"(Des)marcar todos"
					@ 230,062 BUTTON OFILBUT 	PROMPT STR0082 SIZE 55,12 OF ODLGFIL PIXEL ;  //"GERA FATURAMENTO"
					ACTION ( IIF(MSGYESNO(OEMTOANSI(STR0083) , STR0007) , ;  //"Confirma a geracao do faturamento?"###"Atencao"
					cOpcx := "1"  , ;
						cOpcx := "0") , ;
						ODLGFIL:END() )
					@ 230,117 BUTTON   OCANBUT PROMPT STR0084             SIZE 55,12 OF ODLGFIL PIXEL ACTION (cOpcx := "0", ODLGFIL:END()) //"CANCELAR"
					@ 003,002 MsGet oPesq Var cPesq Size 342,009 COLOR CLR_BLACK PIXEL OF ODLGFIL
					@ 003,345 Button STR0117 Size 043,012 PIXEL OF ODLGFIL Action IF(!Empty(OFILOS:aArray[OFILOS:nAt][2]),ITPESQ(OFILOS,cPesq),Nil) //Localiza
					ACTIVATE MSDIALOG ODLGFIL CENTERED

					// Validar se selecionou pelo menos um contrato
					If cOpcx == "0"
						If !lPrefer
							cErroAut := STR0085 // Não houve registro para a selecao
						EndIF
						LMSERROAUTO := .T.
						Return .F.
					Else
						For _nX := 1 to len(_aSZ1)
							If _aSZ1[_nX,1]
								aadd(_aSeleca2,{_aSZ1[_nX][27],_aSZ1[_nX][28]})
							EndIF
						Next
					EndIf
					If len(_aSeleca2) == 0
						If !lPrefer
							cErroAut := STR0085 // Não houve registro para a selecao
						EndIf
						LMSERROAUTO := .T.
						Return .F.
					EndIF

					// dserloca-2408 - Frank em 23/02/2024
					If LOCA021E
						If !EXECBLOCK("LOCA021E" , .T. , .T. , {_aSeleca2,"2",_aSZ1} )
							If !lPrefer
								cErroAut := STR0085 // Não houve registro para a selecao
							EndIF
							LMSERROAUTO := .T.
							Return .F.
						EndIF
					EndIF

					//Else
					//	MsgAlert(STR0075,STR0017) //A opção ambos não permite a seleção dos contratos.###Rental
					//	If !lPrefer
					//		cErroAut := STR0075 // A opção ambos não permite a seleção dos contratos.
					//	EndIf
					//	LMSERROAUTO := .T.
					//	Return .F.
				EndIf
			EndIF
		EndIf
		TRBFPG->(dbGotop())

		NITENS    := replicate("0",TamSx3("C6_ITEM")[1]) // Frank em 27/12/2022 chamado 612 antes era ""
		_AITENSPV := {}
		_AZC1FAT  := {}
		aFPZ := {}
		DBSELECTAREA("FP0")
		DBSELECTAREA("FPA")
		DBSELECTAREA("FPG")
		WHILE TRBFPG->(!EOF())

			If !_lJob .and. _lTem14 // se não for job e existe o pergunte da selecao
				If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
					If cPar11 <> 3 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
						_lSelecao := .F.
						If len(_aSeleca2) > 0
							For _nX:=1 to len(_aSeleca2)
								If _aSeleca2[_nX][1] == TRBFPG->ZC1RECNO
									_lSelecao := .T.
									Exit
								EndIF
							Next
						EndIF
						If !_lSelecao
							TRBFPG->(dbSkip())
							Loop
						EndIF
					EndIF
				EndIF
			EndIF

			If lGeraPVx
				//_CNUMPED := GETSXENUM("SC5","C5_NUM") Comentado por Frank em 18/09/23
				_CNUMPED := ""
			ELSE
				_CNUMPED := ""
			EndIF
			SC5->(dbSetOrder(1))

			_CNATUREZ := _MV_LOC065 //GETMV("MV_LOCX065")

			If !empty(TRBFPG->FPG_NATURE)
				_CNATUREZ := TRBFPG->FPG_NATURE
			ENDIF

			_CPROJET  := TRBFPG->PROJET
			_cTabel   := ""

			FPA->( DBGOTO(TRBFPG->ZAGRECNO) )
			FP1->( DBGOTO(TRBFPG->FP1RECNO) )
			FP0->( DBGOTO(TRBFPG->ZA0RECNO) )

			nForca := 0
			IF lLOC021M
				nForca := EXECBLOCK("LOCA021M" , .T. , .T. , {} )
			ENDIF

			//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
			If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT) .or. nForca == 1
				cPvCliente := FPA->FPA_CLIFAT + FPA->FPA_LOJFAT
			ElseIf !Empty(FP1->FP1_CLIDES) .or. nForca == 2
				cPvCliente := FP1->FP1_CLIDES + FP1->FP1_LOJDES
			Else
				cPvCliente := FP0->FP0_CLI + FP0->FP0_LOJA
			EndIf

			// Filtro do cliente após a identificação do clifat - Frank em 04/07/23
			If substr(cPvCliente,1,tamsx3("A1_COD")[1]) < cPar03 .or. substr(cPvCliente,1,tamsx3("A1_COD")[1]) > cPar04
				TRBFPG->(dbSkip())
				Loop
			EndIF
			If substr(cPvCliente,tamsx3("A1_COD")[1]+1,tamsx3("A1_LOJA")[1]) < cPar05 .or. substr(cPvCliente,tamsx3("A1_COD")[1]+1,tamsx3("A1_LOJA")[1]) > cPar06
				TRBFPG->(dbSkip())
				Loop
			ENDIF

			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1") + cPvCliente)) .and. nForca == 0
			Else
				If lLOC21Auto
					If !lPrefer
						cErroAut := STR0119 //"Cliente não localizado"
					EndIf
					LMSERROAUTO := .T.
				Else
					If !lPreviewX
						Help(NIL, NIL, "LOCA021_2", NIL, STR0119, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0120 + AllTrim(FPA->FPA_PROJET) + " | Obra: " + FPA->FPA_OBRA + STR0126 + FPA->FPA_SEQGRU}) //"Cliente não localizado"###"Informe um cliente válido no Projeto "###" | Seq: "
					EndIf
				EndIF
				Return .F.
			EndIf

			//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
			cPvProjet 	:= TRBFPG->PROJET
			cPvObra 	:= FP1->FP1_OBRA
			cPvCliAux	:= cPvCliente
			nQtdItens	:= 0 //SIGALOC94-665 - Jose Eulalio - Gerar mais de um PV quando tiver mais de 300 linhas sendo processada

			//realiza quebra dos itens
			//WHILE TRBFPG->(!EOF()) .AND. _CPROJET == TRBFPG->PROJET
			//nova forma de quebra a partir de SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
			//QUEBRA PEDIDO POR PROJETO / OBRA / CLIENTE

			nForca := 0
			IF lLOC021N
				nForca := EXECBLOCK("LOCA021N" , .T. , .T. , {} )
			ENDIF

			WHILE TRBFPG->( !EOF() ) .AND. cPvProjet == TRBFPG->PROJET .And. cPvObra == FP1->FP1_OBRA .And. cPvCliente == cPvCliAux .And. nQtdItens < nMaxItens .or. nForca > 0

				//soma para garantir menos de mil itens por pedido
				nQtdItens++

				FPA->( DBGOTO( TRBFPG->ZAGRECNO ) )
				FPG->( DBGOTO( TRBFPG->ZC1RECNO ) )
				FP1->( DBGOTO( TRBFPG->FP1RECNO ) )
				//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
				cCliFat := TRBFPG->CLIFAT
				cLojFat := TRBFPG->LOJFAT
				cNomFat := alltrim(TRBFPG->NOMFAT)

				If !_lJob .and. (_lTem14 .or. nforca > 0) .and. !lLOC21Auto // se não for job e existe o pergunte da selecao
					If cPar14 == 2 .or. nforca > 0 // Se optou por selecionar os contratos para faturamento
						If cPar11 <> 3 .or. nforca > 0 // Se optou por locação, ou custo extra (não é válido ambos para a selecao)
							_lSelecao := .F.
							If len(_aSeleca2) > 0
								For _nX:=1 to len(_aSeleca2)
									If _aSeleca2[_nX][1] == TRBFPG->ZC1RECNO
										_lSelecao := .T.
										Exit
									EndIF
								Next
							EndIF
							If !_lSelecao .or. nforca > 0
								TRBFPG->(dbSkip())
								//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
								If TRBFPG->( !EOF() ) .or. nforca > 0
									FPA->( DBGOTO( TRBFPG->ZAGRECNO ) )
									FP1->( DBGOTO( TRBFPG->FP1RECNO ) )
									//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
									cPvCliAux := TRBFPG->(CLIFAT + LOJFAT)
								EndIf
								If nForca > 0

									If !lPrefer
										cErroAut := STR0124 //"Retorno negativado pelo ponto de entrada LOCA021N"
									EndIF
									LMSERROAUTO := .T.

									Return .F.
								EndIF
								Loop
							EndIF
						EndIF
					EndIF
				EndIF

				IF FPG->FPG_COBRAT == "N"
					_NTOTZC1 := FPG->FPG_VALOR
				ELSE
					_NTOTZC1 := FPG->FPG_VALTOT
				ENDIF

				_NVALZC1 := ROUND(_NTOTZC1 / FPG->FPG_QUANT,SC6->(GETSX3CACHE("C6_VALOR","X3_DECIMAL")))

				_AITEMTEMP := {}
				//NITENS := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
				// Frank em 27/12/2022 chamado 612
				NITENS := soma1(nItens) //   STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
				//AADD(_AITEMTEMP , {"C6_NUM"     , _CNUMPED        , NIL}) Comentado por Frank em 18/09/23
				AADD(_AITEMTEMP , {"C6_FILIAL"  , XFILIAL("SC6")  , NIL})
				AADD(_AITEMTEMP , {"C6_ITEM"    , NITENS          , NIL})

				_cProdXa := FPG->FPG_PRODUT
				_cDescXa := FPG->FPG_DESCRI
				IF _LOCA021A //EXISTBLOCK("LOCA021A")
					_cProdXa := EXECBLOCK("LOCA021A" , .T. , .T. , {FPG->(Recno()),1}) // 1 = Código do produto
					_cDescXa := EXECBLOCK("LOCA021A" , .T. , .T. , {FPG->(Recno()),2}) // 2 = Descricao do produto
				ENDIF

				AADD(_AITEMTEMP , {"C6_PRODUTO" , _cProdXa , NIL})
				AADD(_AITEMTEMP , {"C6_DESCRI"  , _cDescXa , NIL})

				AADD(_AITEMTEMP , {"C6_QTDVEN"  , FPG->FPG_QUANT  , NIL})
				AADD(_AITEMTEMP , {"C6_PRCVEN"  , _NVALZC1        , NIL})
				AADD(_AITEMTEMP , {"C6_PRUNIT"  , _NVALZC1        , NIL})
				AADD(_AITEMTEMP , {"C6_VALOR"   , _NTOTZC1        , NIL})
				nTotPed += nValLoc
				If empty(FPA->FPA_TESFAT)
					AADD(_AITEMTEMP , {"C6_TES"     , _CTESPRO        , NIL})
				Else
					AADD(_AITEMTEMP , {"C6_TES"     , FPA->FPA_TESFAT , NIL})
				ENDIF
				AADD(_AITEMTEMP , {"C6_QTDLIB"  , FPG->FPG_QUANT  , NIL})
				AADD(_AITEMTEMP , {"C6_CC"      , FPG->FPG_CUSTO  , NIL})
				IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
					AADD(_AITEMTEMP      , {"C6_CLVL"    , Alltrim(FPA->FPA_AS)           , NIL})
				ENDIF
				If !lMvLocBac
					IF SC6->(FIELDPOS("C6_XEXTRA")) > 0
						AADD(_AITEMTEMP , {"C6_XEXTRA"  , "S"             , NIL})
					EndIF
					IF SC6->(FIELDPOS("C6_XAS")) > 0
						AADD(_AITEMTEMP , {"C6_XAS"     , FPG->FPG_NRAS   , NIL})
					EndIF
					IF SC6->(FIELDPOS("C6_XBEM")) > 0
						AADD(_AITEMTEMP , {"C6_XBEM"    , FPA->FPA_GRUA   , NIL})
					EndIF
					IF SC6->(FIELDPOS("C6_FROTA")) > 0
						AADD(_AITEMTEMP     , {"C6_FROTA"      , FPA->FPA_GRUA        , NIL})
					ENDIF
					IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
						_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)

						IF _LOCA021D //EXISTBLOCK("LOCA021D")
							_cPerloc := EXECBLOCK("LOCA021D" , .F. , .F., {_CPERLOC} )
						ENDIF

						AADD(_AITEMTEMP     , {"C6_XPERLOC" , _CPERLOC              , NIL})
					ENDIF
					IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0
						AADD(_AITEMTEMP     , {"C6_XCCUSTO" , FPA->FPA_CUSTO        , NIL})
					ENDIF
				EndIf

				_NREG++

				NVALTOT += _NTOTZC1

				//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
				//Itens da Tabela de Pedido de Venda x Locação
				If lMvLocBac

					// Card 2600 - Frank em 13/03/2024
					FP1->(dbSetOrder(1))
					FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))

					_CPERLOC := DTOC(FPG->FPG_DTENT) + " A " + DTOC(FPG->FPG_DTENT)
					IF _LOCA021D //EXISTBLOCK("LOCA021D")
						_cPerloc := EXECBLOCK("LOCA021D" , .F. , .F., {_CPERLOC} )
					ENDIF

					aItemFPZ := {}
					Aadd(aItemFPZ, {"FPZ_FILIAL"	, XFILIAL("SC6")	,	NIL })
					//Aadd(aItemFPZ, {"FPZ_PEDVEN"	, _CNUMPED			, 	NIL }) Removido por Frank em 18/09/23
					Aadd(aItemFPZ, {"FPZ_PEDVEN"	, ""				, 	NIL })
					Aadd(aItemFPZ, {"FPZ_DTPED"	, dDataBase				, 	NIL })
					Aadd(aItemFPZ, {"FPZ_DTINI"	, FPA->FPA_DTINI				, 	NIL })
					Aadd(aItemFPZ, {"FPZ_DTFIM"	, FPA->FPA_DTFIM				, 	NIL })
					Aadd(aItemFPZ, {"FPZ_PROJET"	, FP0->FP0_PROJET 	,	NIL })
					Aadd(aItemFPZ, {"FPZ_PRVFAT"	, FPA->FPA_ULTFAT	,	NIL })
					IF lAglutinar
						if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
							Aadd(aItemFPZ, {"FPZ_ITEM"		    , StrZero(nPosPrdAgl, TAMSX3("FPZ_ITEM")[1],0),	NIL })
						else
							Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
						endif
					else
						Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
					endif
					Aadd(aItemFPZ, {"FPZ_AS"		, FPG->FPG_NRAS		, 	NIL })
					Aadd(aItemFPZ, {"FPZ_EXTRA"		, "S"				,	NIL })
					Aadd(aItemFPZ, {"FPZ_FROTA"		, FPA->FPA_GRUA		,	NIL })
					Aadd(aItemFPZ, {"FPZ_PERLOC"	, _CPERLOC			,	NIL })
					Aadd(aItemFPZ, {"FPZ_CCUSTO"	, FPA->FPA_CUSTO	,	NIL })

					if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
						Aadd(aItemFPZ, {"FPZ_ITMFPZ"		, NITENS ,	NIL })
						Aadd(aItemFPZ, {"FPZ_QUANT", FPG->FPG_QUANT,	NIL })
						Aadd(aItemFPZ, {"FPZ_VALUNI", _NVALZC1 ,	NIL })
						Aadd(aItemFPZ, {"FPZ_PROD"  , _cProdXa,	NIL })
						Aadd(aItemFPZ, {"FPZ_VIAGEM", FPA->FPA_VIAGEM,	NIL })
						//Aadd(aItemFPZ, {"FPZ_DIAS"  , _DDTFIM - _DDTINI + 1,	NIL })
						Aadd(aItemFPZ, {"FPZ_TOTAL", _NTOTZC1,	NIL })
						Aadd(aItemFPZ, {"FPZ_OBRA", FPA->FPA_OBRA,	NIL })

						if _LCVAL
							Aadd(aItemFPZ, {"FPZ_CLVL"  , FPA->FPA_AS,	NIL })
						endif

						If empty(FPA->FPA_TESFAT)
							Aadd(aItemFPZ, {"FPZ_TES" , _CTESPRO                , NIL})
						Else
							Aadd(aItemFPZ, {"FPZ_TES" ,  FPA->FPA_TESFAT       , NIL})
						EndIf

					endif
					Aadd(aFPZ,Aclone(aItemFPZ))

				endif

				AADD( _AITENSPV , ACLONE(_AITEMTEMP) )
				AADD( _AZC1FAT , {TRBFPG->ZC1RECNO,""      ,NITENS} )

				_CPAGTO := FPA->FPA_CONPAG
				_cTabel := FPA->FPA_CODTAB

				FP0->(DBSETORDER(1))	// ZA0_FILIAL + ZA0_PROJET
				FP0->( DBGOTO( TRBFPG->ZA0RECNO ) )

				TRBFPG->(DBSKIP())
				//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO

				nForca := 0
				IF lLOC021O
					nForca := EXECBLOCK("LOCA021O" , .T. , .T. , {} )
				ENDIF

				If TRBFPG->( !EOF() ) .or. nforca > 0
					FPA->( DBGOTO( TRBFPG->ZAGRECNO ) )
					FP1->( DBGOTO( TRBFPG->FP1RECNO ) )
					//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
					cPvCliAux := TRBFPG->CLIFAT + TRBFPG->LOJFAT
				EndIf

				If nforca > 0
					If lLOC21Auto
						If !lPrefer
							cErroAut := STR0125 //"Retorno negativado pelo ponto de entrada LOCA021O"
						EndIf
						LMSERROAUTO := .T.
					EndIf
					Return .F.
				EndIF

			ENDDO

			// Frank em 05/05/22 - indica se usa tabela de preços para a geração do SC5
			// é obrigatório somente quando a condição de pagamento esta amarrada com uma tabela de precos
			_lUsaTab := .F.
			If !empty(_cTabel)
				DA0->(dbSetOrder(1))
				If DA0->(dbSeek(xFilial("DA0")+_cTabel))
					If !empty(DA0->DA0_CONDPG)
						_lUsaTab := .T.
					EndIf
				EndIf
			EndIf

			_ACABPV	:= {}

			// Frank em 29/02/2024 - DSERLOCA-2489 - Toda vez que for criar um novo PV limpar esta variavel
			NITENS := replicate("0",TamSx3("C6_ITEM")[1]) // Frank em 27/12/2022 chamado 612 antes estava ""

			AADD(_ACABPV , {"C5_TIPO"    , "N"                  , NIL})
			AADD(_ACABPV , {"C5_CLIENTE" , cCliFat         		, NIL})
			AADD(_ACABPV , {"C5_LOJACLI" , cLojFat        		, NIL})
			If _lUsaTab
				AADD(_ACABPV , {"C5_TABELA" , _cTabel                , NIL})
			EndIF
			AADD(_ACABPV , {"C5_CONDPAG" , _CPAGTO               , NIL})
			AADD(_ACABPV , {"C5_VEND1"   , FP0->FP0_VENDED       , NIL})
			If !lMvLocBac
				IF SC5->(FIELDPOS("C5_XPROJET")) > 0
					AADD(_ACABPV , {"C5_XPROJET" , FP0->FP0_PROJET       , NIL})
				EndIF
				IF SC5->(FIELDPOS("C5_XTIPFAT")) > 0
					AADD(_ACABPV , {"C5_XTIPFAT" , "P"                   , NIL})
				EndIF
			EndIF

				AADD(_ACABPV , {"C5_NATUREZ" , _CNATUREZ             , NIL})

			AADD(_ACABPV , {"C5_MOEDA"   , FP0->FP0_MOEDA        , NIL})
			// DSERLOCA-3759 - Circenis- Campos Mercado Internacional
			if cPaisLoc = "ARG" // Argentina
				AADD(_ACABPV , {"C5_DOCGER"  , '1'		      , NIL } ) // 1 =  Fatura
			endif
			//SIGALOC94-944 - 17/07/2023 -  Jose Eulalio - Condição de Pagamenteo tipo 9
			SE4->(DBSETORDER(1))
			If SE4->( MSSEEK(XFILIAL("SE4") + _CPAGTO, .F. ) ) .And. SE4->E4_TIPO == "9"
				If AllTrim(SE4->E4_COND) == "0"
					nParc1 := nValTot
				EndIf
				dDtFim := IIF(FPA->FPA_DTFIM < dDataBase, dDataBase, FPA->FPA_DTFIM)
				AADD(_ACABPV     , {"C5_PARC1"  , nParc1	, NIL } )
				AADD(_ACABPV     , {"C5_DATA1"  , dDtFim	, NIL } )
			EndIf

			IF _LCJLFCAB //EXISTBLOCK("LCJLFCAB") 								// --> PONTO DE ENTRADA PARA INCLUSÃO DE CAMPOS NO CABEÇALHO DO PEDIDO DE VENDA.
				_ACABPV := EXECBLOCK("LCJLFCAB" , .F. , .F. , {_ACABPV,"C"}) 	// --> Alterado para .F. conforme solicitado pelo Circenis - Djalma 14/10/2022
			ENDIF
			IF _LCJLFCAB //EXISTBLOCK("LCJLFCAB")
				_AITENSPV := EXECBLOCK("LCJLFCAB" , .F. , .F. , {_AITENSPV,"I"}) 	// --> Alterado para .F. conforme solicitado pelo Circenis - Djalma 14/10/2022
			endif

			//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
			//Cabeçalho da Tabela de Pedido de Venda x Locação
			If lMvLocBac
				aFPY := {}
				Aadd(aFPY, {"FPY_FILIAL"	, XFILIAL("SC6")	,	NIL })
				//Aadd(aFPY, {"FPY_PEDVEN"	, _CNUMPED			,	NIL }) Removido por Frank em 18/09/23
				Aadd(aFPY, {"FPY_PEDVEN"	, ""				,	NIL })
				Aadd(aFPY, {"FPY_PROJET"	, FP0->FP0_PROJET	,	NIL })
				Aadd(aFPY, {"FPY_TIPFAT"	, "P"				,	NIL })
				Aadd(aFPY, {"FPY_STATUS "	, "1"				,	NIL }) //1=Pedido Ativo;2=Pedido Cancelado
				If FPY->(FieldPos("FPY_OBRA")) > 0
					Aadd(aFPY, {"FPY_OBRA", cPvObra , NIL })
				endif
				_NREGPR ++
			/*	if cPAR20 == 2
					cAsOff := ""
					For nOff1 := 1 to len(aFPZ)
						For nOff2 := 1 to len(aFPZ[nOff1])
							If alltrim(aFPZ[nOff1][nOff2][1]) == "FPZ_AS"
								cAsOff += "{"+alltrim(aFPZ[nOff1][nOff2][2])+"}"
								Exit
							EndIF
						Next
					Next

					_NREGPR ++

				Endif */

			EndIf

			IF _NREG > 0 .and. lGeraPVx

				LMSERROAUTO := .F.
				// Sprint 3 - Frank Z Fuga - EAI - 04/10/22
				If !empty(cLocx299)
					SetRotInteg("MATA410")
				EndIf

				If len(_aCabPV) > 0 .and. len(_aItensPV) > 0
					If cPAR20 == 1 // Frank 13/11/24
						lMsg := .T. // variavel indicando se apresenta o erro, quando não existir erros na FPY e FPZ
						If LOCA021V(_ACABPV, _AITENSPV)
							// Frank - 30/07/25 - ISSUE 7851
							// Tratamento para validação no execauto se é para executar apenas o preview do faturamento sem gerar nada.
							If !lPreviewX
								MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABPV , _AITENSPV , 3)
							//Else
							//	LOCA021I(_aCabPV)
							EndIf
						Else
							lMsg := .F.
							If !_LJOB .and. !lLOC21Auto
								MsgStop(STR0137,STR0033) //"Houve um erro na geração dos complementos do faturamento FPY e FPZ, o pedido de vendas não será gerado."###"Atenção!"
							EndIf
							_ACABPV := {}
							_AITENSPV := {}
							LMSERROAUTO := .T.
						EndIF

						IF LMSERROAUTO .and. !lPreviewX
							If !lLOC21Auto .and. !_lJob .and. lMsg
								MOSTRAERRO()
							EndIF

							If lMsg
								ROLLBACKSXE()
							EndIf

							If  (lLOC21Auto .or. _lJob) .and. lOffLine
								aRetJob[1] += STR0131+FPA->FPA_PROJET+STR0130+FPA->FPA_OBRA +CRLF //" obra : " //"Erro ao Gerar Pedido Projeto :"
								
								If lMsg
									aErro := GetAutoGRLog()
								Else
									aErro := {}
									aadd(aErro,STR0137) //"Houve um erro na geração dos complementos do faturamento FPY e FPZ, o pedido de vendas não será gerado."
								EndIf
								
								for nX := 1 to Len(aErro)
									aRetJob[1] += aErro[nX] + CRLF
								Next nX
								aRetJob[1] += CRLF
								cErroAut := ""
								lPrefer := .T.
							EndIF
							lRet := .F.

						EndIf
						If !LMSERROAUTO .and. !lPreviewX

							SC5->(ConfirmSx8())
							_NREGPR++

							AADD( APEDIDOS , SC5->C5_NUM )
							If  (lLOC21Auto .or. _lJob) .and. lOffLine
								aRetJob[2,1] += STR0134+FPA->FPA_PROJET+STR0130+FPA->FPA_OBRA+ STR0133+ SC5->C5_NUM+STR0132+TransForm( nToTPed,"@E 999,999,999,999.99") //" obra : " //"Projeto :" //" Pedido : " //" Valor : "
								aRetJob[2,2]++
								aRetJob[2,3] += nTotPed
								nTotPed := 0
							endif

							IF RECLOCK("SC5", .F.)
								SC5->C5_ORIGEM := "LOCA021"
								SC5->(MSUNLOCK())
							EndIF

							//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
							//Grava Tabela de Pedido de Venda x Locação
							If lMvLocBac
								// Alimentar os arrays com o pedido gerado Frank 18/09/23
								aFPY[2,2] := SC5->C5_NUM
								For _nX := 1 to len(aFPZ)
									aFPZ[_nX,2,2] := SC5->C5_NUM
								Next
								LOCA0822(aFPY,aFPZ,NIL)
								aFPZ := {}
							ENDIF

							IF lLCX049                                     // PONTO DE ENTRADA PARA REGRA ESPECÍFICA AO UTILIZAR MV_LOCX049
							    lRegra049 := EXECBLOCK("LOCA2149" , .F. , .F. ,{lRegra049,SC5->C5_NUM} ) 
							ENDIF   

							// Geramos fatura somente para o Pais Brasil
							IF LFATURA .and. cPaisLoc = "BRA" .and. lRegra049
								aNota := GRAVANFS(SC5->C5_NUM)
								If  (lLOC21Auto .or. _lJob) .and. lOffLine
									if ValType(aNota) = "A"
										aRetJob[2,1] += STR0136+aNota[1]+STR0135+aNota[2] //" Serie : " //" Nota : "
									endif
								endif
							ENDIF

							FOR _NX := 1 TO LEN(_AZC1FAT)
								_aZc1Fat[_nX,2] := SC5->C5_NUM
								DBSELECTAREA("FPG")
								FPG->(DBGOTO(_AZC1FAT[_NX][01]))

								If empty(FPG->FPG_SEQ)
									_cSeq := GetSx8Num("FPG","FPG_SEQ")
									ConfirmSx8()
									If FPG->(RecLock("FPG",.F.))
										FPG->FPG_SEQ := _cSeq
										FPG->(MsUnlock())
									EndIF
								EndIf

								IF _LCJATFPG //EXISTBLOCK("LCJATFPG")
									EXECBLOCK("LCJATFPG" , .T. , .T. , {})
								ELSE
									IF RECLOCK("FPG",.F.)
										FPG->FPG_STATUS := "2"					// FATURADO
										FPG->FPG_PVNUM  := _AZC1FAT[_NX][02]
										FPG->FPG_PVITEM := _AZC1FAT[_NX][03]

										FPG->(MSUNLOCK())
										//Copia o Banco de Conhecimento do Custo Extra para o Pedido de Venda (LOCA007.PRW)
										LC007BCOPV(SC5->C5_FILIAL,FPG->FPG_PVNUM)
									ENDIF
								EndIF
							NEXT _NX

							// DSERLOCA-2510 - Frank em 01/03/2024
							_AZC1FAT := {}

							// FRANK - 08/12/2020 - ATUALIZACAO DO CAMPO C6_XPERLOC
							FOR _NX := 1 TO LEN(_AITENSPV)

								_cPerLocx := ""
								IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
									For _nP := 1 to len(_aItensPV[_nX])
										If alltrim(_aItensPV[_nX][_nP][01]) == "C6_XPERLOC"
											_cPerLocx := _aItensPV[_nX][_nP][02]
										EndIf
									Next
								EndIF

								SC6->(DBSETORDER(1))
								//IF SC6->(DBSEEK(XFILIAL("SC6")+_CNUMPED+_AITENSPV[_NX][3][2])) Removido por Frank em 18/09/23
								_nPosItemX := ASCAN(_aitenspv[_NX],{|X| ALLTRIM(X[1])=="C6_ITEM"})
								IF SC6->(DBSEEK(XFILIAL("SC6")+SC5->C5_NUM+_AITENSPV[_NX][_nPosItemX][2]))
									IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
										SC6->(RECLOCK("SC6",.F.))
										SC6->C6_XPERLOC := _cPerlocx //_AITENSPV[_NX][17][2]
										SC6->(MSUNLOCK())
									EndIF
								ENDIF
								If _MV_LOC278 //supergetmv("MV_LOCX278",,.T.)
									//DELTITPR() custo extra não deleta provisorios
								EndIf
							Next


							IF _LCJATFIM //EXISTBLOCK("LCJATFIM")
								EXECBLOCK("LCJATFIM" , .T. , .T. , NIL)
							EndIF

							// DSERLOCA-2489 - Frank em 29/02/2024
							_AITENSPV := {}

						ENDIF
					ENDIF

				ENDIF
				_NREG := 0
			EndIF

			IF len(_AITENSPV) > 0 .and. cPAR20 == 1 // Frank 13/11/24 //_NREG > 0 .and. !lGeraPVx
				IF _LOCA061Z //EXISTBLOCK("LOCA061Z")
					EXECBLOCK("LOCA061Z" , .T. , .T. , {_ACABPV,_AITENSPV,_AZC1FAT,lGeraPVx})
				ENDIF
			ENDIF
			If  (lLOC21Auto .or. _lJob) .and. lOffLine
				aRetJob[2,1] += CRLF // Salta de Linha do Log
			endif
		ENDDO

		TRBFPG->(DBCLOSEAREA())
	ENDIF			// IF CPAR11 == 2 .OR. CPAR11 == 3 				// 2 - CUSTOS EXTRAS / 3 - AMBOS

	// FRANK FUGA - 21/10/2020
	// GERACAO DA COBRANCA DA PRO-RATA NO CASO DE NOTA FISCAL DEVOLVIDA PARCIALMENTE
	IF CPAR11 == 1 .OR. CPAR11 == 3 // LOCACAO

		aBindParam := {}
		_cQuery := ""
		_cQuery += " SELECT * FROM ("
		_CQUERY += " SELECT FPA_PROJET, FPA_OBRA, FPA_LOJFAT, FPA_CONPAG, FPA_AS, FQZ_PROJET, FP1_OBRA, FQZ.R_E_C_N_O_ REG, FPA.R_E_C_N_O_ FPARECNO, FP1.R_E_C_N_O_ FP1RECNO, FP0.R_E_C_N_O_ FP0RECNO,  "
		//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
		_CQUERY += " CASE"
		If FPA->(ColumnPos("FPA_CLIFAT")) > 0
			_CQUERY += " WHEN FPA_CLIFAT <> ' ' THEN FPA_CLIFAT"
		EndIF
		_CQUERY += " WHEN FP1_CLIDES <> ' ' THEN FP1_CLIDES"
		_CQUERY += " ELSE FP0_CLI"
		_CQUERY += " END CLIFAT,"
		_CQUERY += " CASE"
		If FPA->(ColumnPos("FPA_CLIFAT")) > 0
			_CQUERY += " WHEN FPA_LOJFAT <> ' ' THEN FPA_LOJFAT"
		endif
		_CQUERY += " WHEN FP1_LOJDES <> ' ' THEN FP1_LOJDES"
		_CQUERY += " ELSE FP0_LOJA"
		_CQUERY += " END LOJFAT "
		_CQUERY += " FROM "+RETSQLNAME("FQZ")+ " FQZ "
		_CQUERY += " INNER JOIN "+RETSQLNAME("FPA")+" FPA ON FPA_FILIAL='"+XFILIAL("FPA")+"' AND FPA.D_E_L_E_T_ = '' AND FPA_AS = FQZ.FQZ_AS AND FPA_AS <> '' "
		_cQuery += " AND FPA_TIPOSE <> 'S' "
		_cQuery += " AND FPA_PRODUT >= ? AND FPA_PRODUT <= ? "
		aadd(aBindParam,cPar12)
		aadd(aBindParam,cPar13)

		// DSERLOCA-2142 Frank em 26/01/24
		_cQuery += " AND FPA_OBRA >= ? AND FPA_OBRA <= ? "
		aadd(aBindParam,cPar15)
		aadd(aBindParam,cPar16)

		_CQUERY += " INNER JOIN "+RETSQLNAME("FP0")+" FP0  ON FP0_FILIAL='"+XFILIAL("FP0")+"' AND FP0.D_E_L_E_T_ = '' AND FP0_PROJET = FPA_PROJET "
		//_CQUERY += " AND FP0_CLI >= ? AND FP0_CLI <= ? "
		//aadd(aBindParam,cPar03)
		//aadd(aBindParam,cPar04)

		//_CQUERY += " AND FP0_LOJA >= ? AND FP0_LOJA <= ? "
		//aadd(aBindParam,cPar05)
		//aadd(aBindParam,cPar06)

		_CQUERY += "AND FPA_GRUA >= ? AND FPA_GRUA <= ? "
		aadd(aBindParam,cPar07)
		aadd(aBindParam,cPar08)
		_CQUERY += " INNER JOIN "+RETSQLNAME("FP1")+" FP1 ON FP1_FILIAL='"+XFILIAL("FP1")+"' AND FP1_PROJET = FP0_PROJET and FP1_OBRA = FPA_OBRA
		_CQUERY += " WHERE  FQZ.FQZ_FILIAL  = '"+XFILIAL("FQZ")+"' "
		_CQUERY += "   AND  FQZ.FQZ_PROJET BETWEEN ? AND ? "
		aadd(aBindParam,cPar09)
		aadd(aBindParam,cPar10)

		_CQUERY += "   AND  FQZ.FQZ_DTINI  >= ? "
		aadd(aBindParam,DTOS(DPAR01))

		_CQUERY += "   AND (FQZ.FQZ_DTFIM  <> '' OR FQZ.FQZ_DTFIM <= ?) "
		aadd(aBindParam,DTOS(DPAR02))

		_CQUERY += "   AND  FQZ.FQZ_PV   = '' "
		_CQUERY += "   AND  FQZ.FQZ_MSBLQL  = '2' "
		_CQUERY += "   AND  FQZ.D_E_L_E_T_ = '' "
		_cQuery += " ) X"
		_cQuery += " WHERE "
		_cQuery += " CLIFAT >=  ? AND CLIFAT <= ?"
		aadd(aBindParam, cPar03)
		aadd(aBindParam, cPar04)
		_cQuery += " AND LOJFAT >=  ? AND LOJFAT <= ?"
		aadd(aBindParam, cPar05)
		aadd(aBindParam, cPar06)
		_cQuery += " ORDER BY 	FPA_PROJET, FPA_OBRA,  "
		_cQuery += " CLIFAT DESC , FPA_LOJFAT, FPA_CONPAG, FPA_AS"  // ORDENADO POR CLIENTE para facilitar a quebra posterior do PV

		_CQUERY := CHANGEQUERY(_CQUERY) // estava comentado - DSERLOCA 5180

		MPSysOpenQuery(_cQuery,"TRBFQZ",,,aBindParam)

		_CTEMP    := ""
		_ACABPV   := {}
		_CNATUREZ := _MV_LOC065 //GETMV("MV_LOCX065")
		_NREGX    := 0
		_CPAGTO   := ""
		_AREGFQZ  :=  {}

		WHILE !TRBFQZ->(EOF())
			FQZ->(DBGOTO(TRBFQZ->REG))
			FPA->( DBGOTO(TRBFQZ->FPARECNO) )
			FP1->( DBGOTO(TRBFQZ->FP1RECNO) )
			FP0->( DBGOTO(TRBFQZ->FP0RECNO) )

			If !_lJob .and. _lTem14 .and. !lLOC21Auto // se não for job e existe o pergunte da selecao
				If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
					If cPar11 == 1 // Se optou por locação
						_lSelecao := .F.
						If len(_aSelecao) > 0
							For _nX:=1 to len(_aSelecao)
								If _aSelecao[_nX][1] == FPA->(Recno())
									_lSelecao := .T.
									Exit
								EndIF
							Next
						EndIF
						If !_lSelecao
							TRBFQZ->(dbSkip())
							Loop
						EndIF
					EndIF
				EndIF
			EndIF

			_NREGX     := TRBFQZ->REG
			cPvCliente := TRBFQZ->(CLIFAT + LOJFAT)
			cPvObra    := cPvObra
			_AITENSPV  := {}
			NITENS	   := replicate("0",TamSx3("C6_ITEM")[1]) // Frank em 27/12/2022 chamado 612 antes estava ""
			_CNUMPED := ""

			_AASS      := {}
			_CPROJET   := FPA->FPA_PROJET
			//SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
			cPvProjet 	:= TRBFQZ->FQZ_PROJET
			cPvObra 	:= TRBFQZ->FP1_OBRA
			cPvCliAux	:= cPvCliente
			nQtdItens	:= 0 //SIGALOC94-665 - Jose Eulalio - Gerar mais de um PV quando tiver mais de 300 linhas sendo processada
			cCondAtu    := TRBFQZ->FPA_CONPAG
			_lDescCus := .F. // controle dos descontos por custo extra - Frank 15/02/21 / Frank 19/11/21
			_aDescCus := {}
			aAgluNf   := {} // Itens Aglutinados
			aAgluRat  := {} // Reteio de Aglutinação
			_AITENSPV := {}

			If lMvLocBac // Vai Gera FPY e FPZ
				aFPY := {}
				AFPZ := {}
			EndIF
			lAglutinar := FP0->(FieldPos("FP0_AGLUNF")) > 0 .And. FP0->FP0_AGLUNF == "1"
			//realiza quebra dos itens
			//WHILE TMP->( !EOF() ) .AND. _CPROJET == TMP->FPA_PROJET
			//nova forma de quebra a partir de SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
			//SIGALOC94-665 - Jose Eulalio - Gerar mais de um PV quando tiver mais de 300 linhas sendo processada
			//QUEBRA PEDIDO POR PROJETO / OBRA / CLIENTE / QTD ITENS (299)
			// Ao aglutinar não há limite de itens
			WHILE TRBFQZ->( !EOF() ) .AND. cPvProjet == TRBFQZ->FQZ_PROJET .And. cPvObra == TRBFQZ->FP1_OBRA .And. cPvCliente == cPvCliAux .And. IF(lAglutinar, .T. , nQtdItens < nMaxItens) .and.TRBFQZ->FPA_CONPAG == cCondAtu


				FQZ->( DBGOTO(TRBFQZ->REG))
				FPA->( DBGOTO(TRBFQZ->FPARECNO) )
				FP1->( DBGOTO(TRBFQZ->FP1RECNO) )
				FP0->( DBGOTO(TRBFQZ->FP0RECNO) )

				If !_lJob .and. _lTem14 .and. !lLOC21Auto // se não for job e existe o pergunte da selecao
					If cPar14 == 2 // Se optou por selecionar os contratos para faturamento
						If cPar11 == 1 // Se optou por locação
							_lSelecao := .F.
							If len(_aSelecao) > 0
								For _nX:=1 to len(_aSelecao)
									If _aSelecao[_nX][1] == FPA->(Recno())
										_lSelecao := .T.
										Exit
									EndIF
								Next
							EndIF
							If !_lSelecao
								TRBFQZ->(dbSkip())
								Loop
							EndIF
						EndIF
					EndIF
				EndIF

				AADD(_AREGFQZ,{TRBFQZ->REG})
				_CTEMP   := TRBFQZ->FQZ_PROJET
				_CPAGTO := FPA->FPA_CONPAG

				If empty(FPA->FPA_TESFAT)
					cTESAux :=  _CTES
				Else
					cTESAux :=  FPA->FPA_TESFAT
				EndIf

				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFilial("SF4")+cTESAux)

				// So Gera pedido para valores Positivos e se a TES permitir gerar valores zerados
				if FQZ->FQZ_VLRPRO > 0 .or. (FQZ->FQZ_VLRPRO=0 .and. SF4->F4_VLRZERO == "1")

					FPA->(DBSETORDER(3))
					FPA->(DBSEEK(XFILIAL("FPA")+FQZ->FQZ_AS))
					FP0->(DBSETORDER(1))
					FP0->(DBSEEK(XFILIAL("FP0")+TRBFQZ->FQZ_PROJET))

					if Len( _aItensPV) = 0
						_ACABPV := {} // Frank em 04/07/23
						AADD(_ACABPV , {"C5_TIPO"    , "N"                   , NIL})
						AADD(_ACABPV , {"C5_CLIENTE" , cCliFat       		 , NIL})
						AADD(_ACABPV , {"C5_LOJACLI" , cLojFat		         , NIL})
						AADD(_ACABPV , {"C5_CODTAB"  , FPA->FPA_CODTAB       , NIL})
						AADD(_ACABPV , {"C5_CONDPAG" , _CPAGTO               , NIL})
						AADD(_ACABPV , {"C5_VEND1"   , FP0->FP0_VENDED       , NIL})
						If !lMvLocBac
							If SC5->(FIELDPOS("C5_XPROJET")) > 0
								AADD(_ACABPV , {"C5_XPROJET" , FP0->FP0_PROJET       , NIL})
							EndIF
							If SC5->(FIELDPOS("C5_XTIPFAT")) > 0
								AADD(_ACABPV , {"C5_XTIPFAT" , "P"                   , NIL}) // P=PADRAO, M=MEDICAO
							EndIF
						EndIF

						AADD(_ACABPV , {"C5_NATUREZ" , _CNATUREZ             , NIL})

						AADD(_ACABPV , {"C5_MOEDA"   , FP0->FP0_MOEDA        , NIL})
						// DSERLOCA-3759 - Circenis- Campos Mercado Internacional
						if cPaisLoc = "ARG" // Argentina
							AADD(_ACABPV , {"C5_DOCGER"  , '1'		      , NIL} ) // 1 = Fatura
						endif
						//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
						//Cabeçalho da Tabela de Pedido de Venda x Locação
						If lMvLocBac
							aFPY := {}
							Aadd(aFPY, {"FPY_FILIAL"	, XFILIAL("SC6")	,	NIL })
							//Aadd(aFPY, {"FPY_PEDVEN"	, _CNUMPED			,	NIL }) Removido por Frank em 18/09/23
							Aadd(aFPY, {"FPY_PEDVEN"	, ""				,	NIL })
							Aadd(aFPY, {"FPY_PROJET"	, FP0->FP0_PROJET	,	NIL })
							Aadd(aFPY, {"FPY_TIPFAT"	, "P"				,	NIL })
							Aadd(aFPY, {"FPY_STATUS "	, "1"				,	NIL }) //1=Pedido Ativo;2=Pedido Cancelado
							If FPY->(FieldPos("FPY_OBRA")) > 0
								Aadd(aFPY, {"FPY_OBRA", cPvObra , NIL })
							endif

							_NREGPR ++

						Endif

					ENDIF
				ENDIF

				FQZ->(dbGoto(TRBFQZ->REG))
				SB1->(DBSETORDER(1))
				SB1->(DBSEEK(XFILIAL("SB1")+FQZ->FQZ_COD))
				FPA->(DBSETORDER(3))
				FPA->(DBSEEK(XFILIAL("FPA")+FQZ->FQZ_AS))
				FP0->(DBSETORDER(1))
				FP0->(DBSEEK(XFILIAL("FP0")+FQZ->FQZ_PROJET))



				//NITENS := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
				// Frank em 27/12/2022 chamado 612
					_AITEMTEMP := {}
				NITENS := soma1(nItens) //   STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
				AADD(_AITEMTEMP , {"C6_FILIAL"  , XFILIAL("SC6")  , NIL})
				AADD(_AITEMTEMP , {"C6_ITEM"    , NITENS          , NIL})
				AADD(_AITEMTEMP , {"C6_PRODUTO" , FQZ->FQZ_COD , NIL})
				AADD(_AITEMTEMP , {"C6_DESCRI"  , SB1->B1_DESC , NIL})
				AADD(_AITEMTEMP , {"C6_QTDVEN"  , FQZ->FQZ_QTD  , NIL})
				AADD(_AITEMTEMP , {"C6_PRCVEN"  , FQZ->FQZ_VLRPRO / FQZ->FQZ_QTD        , NIL})
				AADD(_AITEMTEMP , {"C6_PRUNIT"  , FQZ->FQZ_VLRPRO / FQZ->FQZ_QTD        , NIL})
				AADD(_AITEMTEMP , {"C6_VALOR"   , FQZ->FQZ_VLRPRO        , NIL})
				nTotPed += FQZ->FQZ_VLRPRO
				AADD(_AITEMTEMP , {"C6_TES"     , cTESAux        , NIL})

				AADD(_AITEMTEMP , {"C6_QTDLIB"  , FQZ->FQZ_QTD  , NIL})
				AADD(_AITEMTEMP , {"C6_CC"      , FPA->FPA_CUSTO  , NIL})

				If !lMvLocBac
					If SC6->(FIELDPOS("C6_XEXTRA")) > 0
						AADD(_AITEMTEMP , {"C6_XEXTRA"  , "N"             , NIL})
					endif
					If SC6->(FIELDPOS("C6_XAS")) > 0
						AADD(_AITEMTEMP , {"C6_XAS"     , FQZ->FQZ_AS   , NIL})
					EndIF
					If SC6->(FIELDPOS("C6_XBEM")) > 0
						AADD(_AITEMTEMP , {"C6_XBEM"    , FPA->FPA_GRUA   , NIL})
					EndIf
					IF SC6->(FIELDPOS("C6_FROTA")) > 0
						AADD(_AITEMTEMP     , {"C6_FROTA"      , FPA->FPA_GRUA        , NIL})
					endif
					IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
						// 19/10/2022 - Jose Eulalio - SIGALOC94-536 - Lui e Ryan passaram a regra abaixo - Corrigir XPERLOC dos PV oriundo de pro rata (FQZ)
						//_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)
						_CPERLOC := IIF(!Empty(FQZ->FQZ_ULTFAT),DTOC(FQZ->FQZ_ULTFAT + 1),DTOC(FQZ->FQZ_DTINI)) + " A " + DTOC(FQZ->FQZ_RETIRA)

						IF _LOCA021D //EXISTBLOCK("LOCA021D")
							_cPerloc := EXECBLOCK("LOCA021D" , .F. , .F., {_CPERLOC} )
						ENDIF

						AADD(_AITEMTEMP     , {"C6_XPERLOC" , _CPERLOC              , NIL})
					ENDIF

					IF SC6->(FIELDPOS("C6_XCCUSTO")) > 0
						AADD(_AITEMTEMP     , {"C6_XCCUSTO" , FPA->FPA_CUSTO        , NIL})
					endif
				ENDIF

				IF lAglutinar // Vai Haver aglutinação
					//determina o produto pelo tipo de serviço
					If FPA->FPA_TIPOSE == "L"
						cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODL), FP0->FP0_PRODL , cMvLOCX063)
	//				ElseIf FPA->FPA_TIPOSE $ "O|Z"
	//					cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODOZ), FP0->FP0_PRODOZ , cMvLOCX063)
	//				ElseIf FPA->FPA_TIPOSE == "M"
	//					cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODM), FP0->FP0_PRODM , cMvLOCX064)
					EndIf

					//caso não tenha nada no array adiciona novo item aglutinado
					If Len(aAgluNf) == 0 .or. aScan(aAgluNf,{|x| x[1]==cPrdAgluNf}) =0
							Aadd(aAgluNf,{ cPrdAgluNf , FQZ->FQZ_VLRPRO , NITENS })
						nItemAglu := Len(aAgluNf)
						nPosPrdAgl := nItemAglu
						//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
						aItemAGG := {}
						Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(1,2)	,	NIL })
						Aadd(aItemAGG, {"AGG_PERC"		, NVALLOC			,	NIL }) //será atualizado mais a frente com a proporção
						Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
						if _LCVAL
							Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
						else
							Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
						endif
						//campos vazios devem ser enviados
						Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
						Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
						Aadd(aAgluRat, { StrZero(nItemAglu,2,0) , {aClone(aItemAGG)} })
						//se não, soma valor no produto já existente
					else
						nPosPrdAgl := aScan(aAgluNf,{|x| x[1]==cPrdAgluNf})
							aAgluNf[nPosPrdAgl][2] += FQZ->FQZ_VLRPRO
						nItemAglu := Len(aAgluRat[nPosPrdAgl][2])
						//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
						aItemAGG := {}
						Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(nItemAglu+1,2)	,	NIL })
							Aadd(aItemAGG, {"AGG_PERC"		, FQZ->FQZ_VLRPRO			,	NIL }) //será atualizado mais a frente com a proporção
						Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
						if _LCVAL
							Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
						else
							Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
						EndIF
						//campos vazios devem ser enviados
						Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
						Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
						Aadd(aAgluRat[nPosPrdAgl][2], aClone(aItemAGG) )

					EndIf
				EndIf

				//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
				//Itens da Tabela de Pedido de Venda x Locação
				If lMvLocBac
					// Kesley M Martins - 29/05/2024 - DSERLOCA-3180
					// Ajuste para corrigir data do campo (FPZ_PERLOC), estava buscando informação errado (FPA->FPA_DTFIM)
					//_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FPA->FPA_DTFIM)
					_CPERLOC := DTOC(FPA->FPA_DTINI) + " A " + DTOC(FQZ->FQZ_EMISS)

					IF _LOCA021D //EXISTBLOCK("LOCA021D")
						_cPerloc := EXECBLOCK("LOCA021D" , .F. , .F., {_CPERLOC} )
					ENDIF
					aFPZ := {}
					aItemFPZ := {}
					Aadd(aItemFPZ, {"FPZ_FILIAL"	, XFILIAL("SC6")	,	NIL })
					//Aadd(aItemFPZ, {"FPZ_PEDVEN"	, _CNUMPED			, 	NIL }) Removido por Frank em 18/09/23
					Aadd(aItemFPZ, {"FPZ_PEDVEN"	, ""				, 	NIL })
					Aadd(aItemFPZ, {"FPZ_DTPED"	, dDataBase				, 	NIL })
					Aadd(aItemFPZ, {"FPZ_DTINI"	, IF(!Empty(FQZ->FQZ_ULTFAT), FQZ->FQZ_ULTFAT + 1, FQZ->FQZ_DTINI)				, 	NIL })
					Aadd(aItemFPZ, {"FPZ_DTFIM"	, FQZ->FQZ_RETIRA				, 	NIL })
					Aadd(aItemFPZ, {"FPZ_PROJET"	, FPA->FPA_PROJET	,	NIL })
					Aadd(aItemFPZ, {"FPZ_PRVFAT"	, FPA->FPA_ULTFAT	,	NIL })
					IF lAglutinar
						if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
							Aadd(aItemFPZ, {"FPZ_ITEM"		    , StrZero(nPosPrdAgl, TAMSX3("FPZ_ITEM")[1],0),	NIL })
						else
							Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
						endif
					ELSE
						Aadd(aItemFPZ, {"FPZ_ITEM"		, NITENS			,	NIL })
					endif

					Aadd(aItemFPZ, {"FPZ_AS"		, FQZ->FQZ_AS		, 	NIL })
					Aadd(aItemFPZ, {"FPZ_EXTRA"		, "N"				,	NIL })
					Aadd(aItemFPZ, {"FPZ_FROTA"		, FPA->FPA_GRUA		,	NIL })
					Aadd(aItemFPZ, {"FPZ_PERLOC"	, _cPerloc			,	NIL })
					Aadd(aItemFPZ, {"FPZ_CCUSTO"	, FPA->FPA_CUSTO	,	NIL })

					// DSERLOCA-2600 - Frank em 13/03/24
					// Se o campo FPA_GERAEM estiver em branco nada se faz
					/*
					If FPZ->(FIELDPOS("FPZ_GERAEM")) > 0 .and. FPA->(FIELDPOS("FPA_GERAEM")) > 0
						dGeraem := ctod("")
						If !empty(FPA->FPA_GERAEM)
							If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
								dGeraem := MONTHSUM(FPA->FPA_GERAEM,1)
							else // dias corridos
								dGeraem := FPA->FPA_GERAEM + FPA->FPA_LOCDIA
							EndIF
						EndIf
						Aadd(aItemFPZ, {"FPZ_GERAEM", dGeraem,	NIL })
					EndIF */
					// Inclusão de novos campos FPZ Alexandre Circenis 14/06/24
					if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
						Aadd(aItemFPZ, {"FPZ_ITMFPZ"		, NITENS ,	NIL })
						Aadd(aItemFPZ, {"FPZ_QUANT", FQZ->FQZ_QTD,	NIL })
						Aadd(aItemFPZ, {"FPZ_VALUNI", ROUND(FQZ->FQZ_VLRPRO / FQZ->FQZ_QTD,SC6->(GETSX3CACHE("C6_PRUNIT","X3_DECIMAL"))),	NIL })
						Aadd(aItemFPZ, {"FPZ_PROD"  , FQZ->FQZ_COD   ,	NIL })
						Aadd(aItemFPZ, {"FPZ_VIAGEM", FPA->FPA_VIAGEM,	NIL })
						Aadd(aItemFPZ, {"FPZ_DIAS"  , FQZ->FQZ_PERPRO,	NIL })
						Aadd(aItemFPZ, {"FPZ_TOTAL", FQZ->FQZ_VLRPRO,	NIL })
						Aadd(aItemFPZ, {"FPZ_OBRA", FQZ->FQZ_OBRA,	NIL })

						if _LCVAL
							Aadd(aItemFPZ, {"FPZ_CLVL"  , FQZ->FQZ_AS,	NIL })
						endif

						Aadd(aItemFPZ, {"FPZ_TES" , cTESAux               , NIL})
						
					endif

					Aadd(aFPZ,Aclone(aItemFPZ))

					_NREG++
					NVALTOT += FQZ->FQZ_VLRPRO

					AADD( _AITENSPV , ACLONE(_AITEMTEMP) )
				EndIf
				TRBFQZ->(DBSKIP())

			ENDDO // fINALIZOU A QUEBRA DO PEDIDO

			// GERAR O PV DA DEVOLUÇÃO PARCIAL.
			If len(_AITENSPV) > 0 .and. lGeraPVx

				//SIGALOC94-944 - 17/07/2023 -  Jose Eulalio - Condição de Pagamenteo tipo 9
				SE4->(DBSETORDER(1))
				If SE4->( MSSEEK(XFILIAL("SE4") + _CPAGTO, .F. ) ) .And. SE4->E4_TIPO == "9"
					If AllTrim(SE4->E4_COND) == "0"
						nParc1 := nValTot
					EndIf
					dDtFim := IIF(FPA->FPA_DTFIM < dDataBase, dDataBase, FPA->FPA_DTFIM)
					AADD(_ACABPV     , {"C5_PARC1"  , nParc1	, NIL } )
					AADD(_ACABPV     , {"C5_DATA1"  , dDtFim	, NIL } )
				EndIf
				// SE HOUVER O PARÂMETRO INDICANDO QUE PRECISA DE UM PEDIDO AGLUTINADO PARA INTEGRAÇÃO COM RM
				// GERARMOS o pedido  VENDAS COM OS ITENS AGLUTINADOS.
				// Alexandre Circenis  - 03/10/2023
				// --------------------------------------------------------------------------------------------------------------------
				//SIGALOC94-394 - Aglutinação para pedidos de vendas usando FP0
				If lAglutinar
					_AITENSPV := {}
					FOR _NX:=1 TO LEN(aAgluNf)
						SB1->(DBSETORDER(1))
						SB1->(DBSEEK(XFILIAL("SB1") + aAgluNf[_NX][1]))
						//monta os itens
						_AAGLUTINA := {}
						//aadd(_AAGLUTINA, {"C6_NUM"     , _CNUMPED2      , NIL}) Comentado por Frank em 18/09/23
						aadd(_AAGLUTINA, {"C6_FILIAL"  , XFILIAL("SC6") , NIL})
						aadd(_AAGLUTINA, {"C6_ITEM"    , StrZero(_NX,nTamItem), NIL})
						aadd(_AAGLUTINA, {"C6_PRODUTO" , SB1->B1_COD    , NIL})
						aadd(_AAGLUTINA, {"C6_DESCRI"  , SB1->B1_DESC   , NIL})
						aadd(_AAGLUTINA, {"C6_QTDVEN"  , 1              , NIL})
						aadd(_AAGLUTINA, {"C6_PRCVEN"  , aAgluNf[_NX][2], NIL})
						aadd(_AAGLUTINA, {"C6_PRUNIT"  , aAgluNf[_NX][2], NIL})
						aadd(_AAGLUTINA, {"C6_VALOR"   , aAgluNf[_NX][2], NIL})
						aadd(_AAGLUTINA, {"C6_QTDLIB"  , 1              , NIL})
						aadd(_AAGLUTINA, {"C6_TES"     , _CTES          , NIL})
						aadd(_AAGLUTINA, {"C6_CC"      , _CCUSTOAG      , NIL})

						nTotAlguNf += aAgluNf[_NX][2]

						IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
							aadd(_AAGLUTINA, {"C6_XPERLOC" , _CPERLOC       , NIL})
						EndIF
						AADD(_AITENSPV , ACLONE(_AAGLUTINA))
					Next _nX

				endif

			LMSERROAUTO := .F.
			// Sprint 3 - Frank Z Fuga - EAI - 04/10/22
			If !empty(cLocx299)
				SetRotInteg("MATA410")
			EndIf

			// Se Houver Aglutinação processar o array antes de gravar
			If Len(aAgluRat) > 0
				nAgluTot := 0
				//pega posição dos campos
				nPosPv 		:= aScan(aAgluRat[1][2][1],{|x| AllTrim(x[1])=="AGG_ITEM"})
				nPosPerc 	:= aScan(aAgluRat[1][2][1],{|x| AllTrim(x[1])=="AGG_PERC"})
				//soma total dos itens
				For _nX := 1 To Len(aAgluRat)
					nAgluTot := 0
					For nX := 1 To Len(aAgluRat[_nX][2])
						//nAgluTot += aAgluRat[_nX][2][nx][nPosPerc][2]
						nAgluTot += aAgluRat[_nX][2][nx][nPosPerc][2]
					Next nX

					For nX := 1 To Len(aAgluRat[_nX][2])
						//aAgluRat[_nX][2][nx][nPosPerc][2] 	:= (aAgluRat[_nX][2][nx][nPosPerc][2] / nAgluTot) * 100 // atualiza proporção
						aAgluRat[_nX][2][nx][nPosPerc][2] 	:= (aAgluRat[_nX][2][nx][nPosPerc][2] / nAgluTot) * 100 // atualiza proporção
						//	aAgluRat[_nX][2][nx][nPosPv][2] 	:=  StrZero(nX,2)										// atualiza item
					Next nX


				Next _nX

				//exectua rotina automática
				//MSEXECAUTO({|X,Y,Z,,,,,W| MATA410(X,Y,Z,,,,,W)} , _ACABPV , _AITENSPV , 3 , , , , , aAgluRat)
				//pega retorno
				If len(_aCabPV) > 0 .and. len(_aItensPV) > 0
					lMsg := .T.
					If cPAR20 == 1 // Frank 13/11/24
						If LOCA021V(_ACABPV, _AITENSPV, aAGlurat)
							// Frank - 30/07/25 - ISSUE 7851
							// Tratamento para validação no execauto se é para executar apenas o preview do faturamento sem gerar nada.
							If !lPreviewX
								MSEXECAUTO({|X,Y,Z,W| MATA410(X,Y,Z,,,,,W)} , _ACABPV , _AITENSPV , 3, aAGlurat)
							Else
								LOCA021I(_aCabPV)
							EndIf
						Else
							If !_LJOB .and. !lLOC21Auto
								MsgStop(STR0137,STR0033) //"Houve um erro na geração dos complementos do faturamento FPY e FPZ, o pedido de vendas não será gerado."###"Atenção!"
							EndIf
							_ACABPV := {}
							_AITENSPV := {}
							LMSERROAUTO := .T.	
							lMsg := .F.
						EndIf
					EndIf
				EndIf
			Else
				If len(_aCabPV) > 0 .and. len(_aItensPV) > 0
					lMsg := .T.
					If cPAR20 == 1 // Frank 13/11/24
						If LOCA021V(_ACABPV, _AITENSPV)
							// Frank - 30/07/25 - ISSUE 7851
							// Tratamento para validação no execauto se é para executar apenas o preview do faturamento sem gerar nada.
							If !lPreviewX
								MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABPV , _AITENSPV , 3)
							Else
								LOCA021I(_aCabPV)
							EndIf
						Else
							If !_LJOB .and. !lLOC21Auto
								MsgStop(STR0137,STR0033) //"Houve um erro na geração dos complementos do faturamento FPY e FPZ, o pedido de vendas não será gerado."###"Atenção!"
							EndIf
							_ACABPV := {}
							_AITENSPV := {}
							LMSERROAUTO := .T.		
							lMsg := .F.
						EndIf
					EndIF
				EndIF
			EndIF

			If cPAR20 == 1 // Frank 13/11/24
				IF LMSERROAUTO .and. !lPreviewX
					If !_LJOB .and. !lLOC21Auto .and. lMsg
						MOSTRAERRO()
					Else
						if  (lLOC21Auto .or. _lJob .or. lMsg) .and. lOffLine
							aRetJob[1] += STR0131+FPA->FPA_PROJET+STR0130+FPA->FPA_OBRA +CRLF //" obra : " //"Erro ao Gerar Pedido Projeto :"
							
							If lMsg
								aErro := GetAutoGRLog()
							Else
								aErro := {}
								aadd(aErro,STR0137) //"Houve um erro na geração dos complementos do faturamento FPY e FPZ, o pedido de vendas não será gerado."
							EndIf
							
							for nX := 1 to Len(aErro)
								aRetJob[1] += aErro[nX] + CRLF
							Next nX
							aRetJob[1] += CRLF
						endif
						cErroAut := ""
						lPrefer := .T.
					EndIF
					lRet := .F.
				EndIF
				If !LMSERROAUTO .and. !lPreviewX

					CONFIRMSX8()

					AADD( APEDIDOS , SC5->C5_NUM )

					If  (lLOC21Auto .or. _lJob) .and. lOffLine
						aRetJob[2,1] += STR0134+FPA->FPA_PROJET+STR0130+FPA->FPA_OBRA+ STR0133+ SC5->C5_NUM+STR0132+TransForm( nToTPed,"@E 999,999,999,999.99") //" Valor : " //" Pedido : " //"Projeto :" //" obra : "
						aRetJob[2,2]++
						aRetJob[2,3] += nTotPed
					endif

					IF RECLOCK("SC5", .F.)
						SC5->C5_ORIGEM := "LOCA021"
						SC5->(MSUNLOCK())
					ENDIF

					//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
					//Grava Tabela de Pedido de Venda x Locação
					If lMvLocBac
						// Alimentar os arrays com o pedido gerado Frank 18/09/23
						aFPY[2,2] := SC5->C5_NUM
						For _nX := 1 to len(aFPZ)
							aFPZ[_nX,2,2] := SC5->C5_NUM
						Next
						LOCA0822(aFPY,aFPZ,NIL)
						aFPZ := {}
					EndIf

					IF lLCX049                                     // PONTO DE ENTRADA PARA REGRA ESPECÍFICA AO UTILIZAR MV_LOCX049
					    lRegra049 := EXECBLOCK("LOCA2149" , .F. , .F. ,{lRegra049,SC5->C5_NUM} ) 
					ENDIF   

					// Geramos fatura somente para o Pais Brasil
					IF LFATURA .and. cPaisLoc = "BRA" .and. lRegra049
						aNota := GRAVANFS(SC5->C5_NUM)
						If  (lLOC21Auto .or. _lJob) .and. lOffLine
							if ValType(aNota) = "A"
								aRetJob[2,1] += STR0136+aNota[1]+STR0135+aNota[2] //" Serie : " //" Nota : "
							endif
						endif
					ENDIF

					If !lMvLocBac
						// FRANK - 08/12/2020 - ATUALIZACAO DO CAMPO C6_XPERLOC
						FOR _NX := 1 TO LEN(_AITENSPV)

							_cPerLocx := ""
							IF SC6->(FIELDPOS("C6_XPERLOC")) > 0
								For _nP := 1 to len(_aItensPV[_nX])
									If alltrim(_aItensPV[_nX][_nP][01]) == "C6_XPERLOC"
										_cPerLocx := _aItensPV[_nX][_nP][02]
									EndIf
								Next
							EndIF

							SC6->(DBSETORDER(1))
							//IF SC6->(DBSEEK(XFILIAL("SC6")+_CNUMPED+_AITENSPV[_NX][3][2])) Removido por Frank em 18/09/23
							_nPosItemX := ASCAN(_aitenspv[_NX],{|X| ALLTRIM(X[1])=="C6_ITEM"})
							IF SC6->(DBSEEK(XFILIAL("SC6")+SC5->C5_NUM+_AITENSPV[_NX][_nPosItemX][2]))
								If SC6->(FIELDPOS("C6_XPERLOC")) > 0
									SC6->(RECLOCK("SC6",.F.))
									SC6->C6_XPERLOC := _cPerLocx //_AITENSPV[_NX][17][2]
									SC6->(MSUNLOCK())
								EndIF
							EndIf
						Next
					EndIF

					_NREGPR++
					AADD( APEDIDOS , SC5->C5_NUM )
					FOR _NX := 1 TO LEN(_AREGFQZ)
						FQZ->(DBGOTO(_AREGFQZ[_NX][1]))
						FQZ->(RECLOCK("FQZ",.F.))
						FQZ->FQZ_PV := SC5->C5_NUM
						FQZ->(MSUNLOCK())
					NEXT
					_AREGFQZ := {}

				ENDIF
				If (lLOC21Auto .or. _lJob) .and. lOffLine
					aRetJob[2,1] += CRLF // Salta de Linha do Log
				endif
			EndIf

			_aitenspv := {}
			cPvCliente := TRBFQZ->(CLIFAT + LOJFAT)

			endif

		ENDDO // Final da Cobrança se pro
		TRBFQZ->( DBCLOSEAREA() )

	ENDIF


	IF EXISTBLOCK("LCJLFFIM") 										// --> PONTO DE ENTRADA NO FINAL DO FATURAMENTO AUTOMATICO.
		//U_LCJLFFIM(CPAR09,CPAR10)
		EXECBLOCK("LCJLFFIM" , .T. , .T. , {CPAR09,CPAR10})
	ENDIF

	IF _NREGPR > 0 
		CMSG := STR0046+ALLTRIM(STR(_NREGPR))+ " " + CRLF //"TOTAL DE REGISTROS PROCESSADOS: "
		ASORT(APEDIDOS,,,{|X,Y| X < Y })
		IF LEN(APEDIDOS) > 0

			If lLOC21Auto
				For nX := 1 to len(aPedidos)
					nValor := 0
					SC6->(dbSetOrder(1))
					SC6->(dbSeek(xFilial("SC6")+aPedidos[nX]))
					cNotAuto := ""
					cSerAuto := ""
					cPerAuto := ""
					While !SC6->(Eof()) .and. SC6->(C6_FILIAL + C6_NUM) == xFilial("SC6") + aPedidos[nX]
						nValor += SC6->C6_VALOR
						cNotAuto := SC6->C6_NOTA
						cSerAuto := SC6->C6_SERIE
						cPerAuto := ""

						If !lMvLocBac
							cPerAuto := SC6->C6_XPERLOC
						Else
							FPY->(dbSetOrder(1))
							If FPY->(dbSeek(xFilial("FPY")+SC6->C6_NUM))
								FPZ->(dbSetOrder(1))
								If FPZ->(dbSeek(xFilial("FPZ")+SC6->C6_NUM+FPY->FPY_PROJET+SC6->C6_ITEM))
									cPerAuto := FPZ->FPZ_PERLOC
								EndIf
							EndIf
						EndIf

						SC6->(dbSkip())
					EndDo
					aadd(aRetExec,{aPedidos[nX],nValor,cNotAuto,cSerAuto,cPerAuto})
				Next
			EndIF

			CMSG += STR0047 + APEDIDOS[1] + STR0048+APEDIDOS[ LEN(APEDIDOS) ] + " "+ CRLF //"PRIMEIRO PEDIDO: "###" - ULTIMO PEDIDO: "
		EndIF
		If cPar20 == 1
			CMSG += STR0049+ ALLTRIM(STR(LEN(APEDIDOS))) + CRLF //"TOTAL DE PEDIDOS GERADOS: "
			CMSG += STR0050+ ALLTRIM( TRANSFORM(NVALTOT,"@E 999,999,999,999.99") ) //"VALOR: "
		ENDIF
		IF ! _LJOB .and. !lLOC21Auto

			IF _LSEMLCJ .and. !empty(CARQLOCK)
				// --> CANCELA O LOCK DE GRAVACAO DA ROTINA.
				FCLOSE(NHDLLOCK)
				FERASE(CARQLOCK)
				NHDLLOCK := 0
			ENDIF

			If len(aPedidos) > 0
				AVISO(STR0051 , CMSG , {"OK"} , 2)  //"PROCESSAMENTO EXECUTADO COM SUCESSO!"
			EndIf
		EndIf
		lRet := .T.
	ELSE
		IF ! _LJOB .and. !lLOC21Auto

			IF _LSEMLCJ .and. !empty(CARQLOCK)
				// --> CANCELA O LOCK DE GRAVACAO DA ROTINA.
				FCLOSE(NHDLLOCK)
				FERASE(CARQLOCK)
				NHDLLOCK := 0
			ENDIF

			MSGSTOP(STR0052 , STR0017)  //"NÃO EXISTEM REGISTROS PARA PROCESSAMENTO!"###"GPO - LCJLF001.PRW"

			If !lPrefer
				cErroAut := STR0052 // "NÃO EXISTEM REGISTROS PARA PROCESSAMENTO!"
			EndIf
			lRet := .F.
			LMSERROAUTO := .T.
		ELSE
			//CONOUT("[LCJLF001.PRW] - NÃO EXISTEM REGISTROS PARA PROCESSAMENTO!")
			If lLOC21Auto
				If !lPrefer
					cErroAut := STR0052 // "NÃO EXISTEM REGISTROS PARA PROCESSAMENTO!"
				EndIf
				LMSERROAUTO := .T.
			EndIF
			lRet := .F.
		EndIF
	ENDIF

	If _NREGPR == 0 .and. lLOC21Auto
		If !lPrefer
			cErroAut := STR0085 // Não houve registro para a selecao
		EndIf
		LMSERROAUTO := .T.
		lRet := .F.
	EndIf

	FPG->(RESTAREA(_AAREAZC1))
	FPA->(RESTAREA(_AAREAZAG))
	FP1->(RESTAREA(_AAREAZA1))
	FP0->(RESTAREA(_AAREAZA0))
	SC6->(RESTAREA(_AAREASC6))
	SC5->(RESTAREA(_AAREASC5))
	RESTAREA(_AAREAOLD)

RETURN lRet


/*/{PROTHEUS.DOC} GRAVANFS
@DESCRIPTION GERAÇÃO DE NOTA FISCAL DE SAÍDA.
@TYPE    FUNCTION
@AUTHOR  IT UP BUSINESS
@SINCE   16/09/2016
@VERSION 2.0
/*/
STATIC FUNCTION GRAVANFS( _CPEDIDO )
Local _AAREAOLD := GETAREA()
Local _AAREASC5 := SC5->(GETAREA())
Local _AAREASC6 := SC6->(GETAREA())
Local _AAREASC9 := SC9->(GETAREA())
Local _AAREASE4 := SE4->(GETAREA())
Local _AAREASB1 := SB1->(GETAREA())
Local _AAREASB2 := SB2->(GETAREA())
Local _AAREASF4 := SF4->(GETAREA())
Local _ATABAUX  := {}
Local _APVLNFS  := {}
Local _CQUERY   := ""
Local _CNOTA    := ""
Local _CSERIE   := GETMV("MV_LOCX024")

	//CONOUT("[LCJLF001.PRW] - PROCFAT() - GERAPV() - GRAVANFS() - INICIO")

	PERGUNTE("MT460A",.F.)

	_APVLNFS := {}

	SC5->( DBSETORDER(1) )	// C5_FILIAL + C5_NUM
	SC6->( DBSETORDER(1) )	// C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
	SC9->( DBSETORDER(1) )	// C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO

	IF SELECT("TRBNFR") > 0
		TRBNFR->(DBCLOSEAREA())
	ENDIF

	_CQUERY := " SELECT C9_PEDIDO PEDIDO , C9_ITEM   ITEM  , C9_SEQUEN  SEQUEN  , "
	_CQUERY += "        C9_QTDLIB QUANT  , C9_PRCVEN VALOR , C9_PRODUTO PRODUTO , "
	_CQUERY += "        SC9.R_E_C_N_O_ SC9RECNO, SC5.R_E_C_N_O_ SC5RECNO , "
	_CQUERY += "        SC6.R_E_C_N_O_ SC6RECNO, SE4.R_E_C_N_O_ SE4RECNO , "
	_CQUERY += "        SB1.R_E_C_N_O_ SB1RECNO, SB2.R_E_C_N_O_ SB2RECNO , "
	_CQUERY += "        SF4.R_E_C_N_O_ SF4RECNO "
	_CQUERY += " FROM " + RETSQLNAME("SC9") + " SC9 (NOLOCK) "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SC6") + " SC6 (NOLOCK) ON  C6_FILIAL  = '" + XFILIAL("SC6") + "'"
	_CQUERY += "                                                          AND C6_NUM     = C9_PEDIDO  AND C6_ITEM    = C9_ITEM "
	_CQUERY += "                                                          AND C6_PRODUTO = C9_PRODUTO AND C6_BLQ NOT IN ('R','S') "
	_CQUERY += "                                                          AND SC6.D_E_L_E_T_ = '' "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SC5") + " SC5 (NOLOCK) ON  C5_FILIAL  = '" + XFILIAL("SC5") + "'"
	_CQUERY += "                                                          AND C5_NUM     = C6_NUM     AND SC5.D_E_L_E_T_ = '' "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SE4") + " SE4 (NOLOCK) ON  E4_FILIAL  = '" + XFILIAL("SE4") + "'"
	_CQUERY += "                                                          AND E4_CODIGO  = C5_CONDPAG AND SE4.D_E_L_E_T_ = '' "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SB1") + " SB1 (NOLOCK) ON  B1_FILIAL  = '" + XFILIAL("SB1") + "'"
	_CQUERY += "                                                          AND B1_COD     = C6_PRODUTO AND SB1.D_E_L_E_T_ = '' "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SB2") + " SB2 (NOLOCK) ON  B2_FILIAL  = '" + XFILIAL("SB2") + "'"
	_CQUERY += "                                                          AND B2_COD     = C6_PRODUTO AND B2_LOCAL   = C6_LOCAL "
	_CQUERY += "                                                          AND SB2.D_E_L_E_T_ = '' "
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SF4") + " SF4 (NOLOCK) ON  F4_FILIAL  = '" + XFILIAL("SF4") + "'"
	_CQUERY += "                                                          AND F4_CODIGO  = C6_TES     AND SF4.D_E_L_E_T_ = '' "
	_CQUERY += " WHERE  C9_FILIAL  = '" + XFILIAL("SC9") + "'"
	_CQUERY += "   AND  C9_PEDIDO  = ? "
	_CQUERY += "   AND  C9_NFISCAL = ''"
	_CQUERY += "   AND  SC9.D_E_L_E_T_ = ''"
	_CQUERY += " ORDER BY PEDIDO , ITEM , SEQUEN , PRODUTO "
	_CQUERY := CHANGEQUERY(_CQUERY)
	aBindParam := {_CPEDIDO}
	MPSysOpenQuery(_cQuery,"TRBNFR",,,aBindParam)

	WHILE TRBNFR->(!EOF())
		_ATABAUX := {}

		AADD( _ATABAUX , TRBNFR->PEDIDO   )
		AADD( _ATABAUX , TRBNFR->ITEM     )
		AADD( _ATABAUX , TRBNFR->SEQUEN   )
		AADD( _ATABAUX , TRBNFR->QUANT    )
		AADD( _ATABAUX , TRBNFR->VALOR    )
		AADD( _ATABAUX , TRBNFR->PRODUTO  )
		AADD( _ATABAUX , .F.              )
		AADD( _ATABAUX , TRBNFR->SC9RECNO )
		AADD( _ATABAUX , TRBNFR->SC5RECNO )
		AADD( _ATABAUX , TRBNFR->SC6RECNO )
		AADD( _ATABAUX , TRBNFR->SE4RECNO )
		AADD( _ATABAUX , TRBNFR->SB1RECNO )
		AADD( _ATABAUX , TRBNFR->SB2RECNO )
		AADD( _ATABAUX , TRBNFR->SF4RECNO )

		AADD( _APVLNFS , ACLONE(_ATABAUX) )

		TRBNFR->(DBSKIP())
	ENDDO

	TRBNFR->(DBCLOSEAREA())

	DBSELECTAREA( "SC9" )

	IF LEN(_APVLNFS) > 0
		IF EXISTBLOCK("LCJSER") 									// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA SÉRIE.
			_CSERIE := EXECBLOCK("LCJSER" , .T. , .T. , {_CSERIE})
		ENDIF

		_CNOTA := MAPVLNFS(_APVLNFS , _CSERIE , .F. , .F. , .F. , .T. , .F. , 0 , 0 , .T. , .F.)

		PUTGLBVALUE("CNF_PAR" , _CNOTA) 							// --> ALIMENTA NO. DA NF
	ENDIF

	SF4->(RESTAREA( _AAREASF4 ))
	SB2->(RESTAREA( _AAREASB2 ))
	SB1->(RESTAREA( _AAREASB1 ))
	SE4->(RESTAREA( _AAREASE4 ))
	SC9->(RESTAREA( _AAREASC9 ))
	SC6->(RESTAREA( _AAREASC6 ))
	SC5->(RESTAREA( _AAREASC5 ))
	RESTAREA( _AAREAOLD )

RETURN ({_CNOTA,_CSERIE })



/*/{PROTHEUS.DOC} PRIMFAT
@DESCRIPTION VERIFICA SE É O PRIMEIO FATURAMENTO DA AS.
@TYPE    FUNCTION
@AUTHOR  IT UP BUSINESS
@SINCE   24/10/2016
@VERSION 1.0
/*/
// ======================================================================= \\
STATIC FUNCTION PRIMFAT(_CNRAS)
// ======================================================================= \\
Local _LRET   := .T.
Local _CQUERY := ""
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC

	IF !lMvLocBac

		IF SELECT("TRBPRI") > 0
			TRBPRI->(DBCLOSEAREA())
		ENDIF

		_CQUERY := " SELECT C6_XAS "
		_CQUERY += " FROM " + RETSQLNAME("SC6") + " SC6 (NOLOCK) "
		_CQUERY += " INNER JOIN "+RETSQLNAME("SC5")+" SC5 (NOLOCK) "
		_CQUERY += " ON  SC5.C5_FILIAL = SC6.C6_FILIAL "
		_CQUERY += " AND SC5.C5_NUM = SC6.C6_NUM "
		If SC5->(FIELDPOS("C5_XTIPFAT")) > 0
			_CQUERY += " AND SC5.C5_XTIPFAT = 'P' "
		EndIf
		_CQUERY += " AND SC5.D_E_L_E_T_ = '' "
		_CQUERY += " WHERE  SC6.D_E_L_E_T_ = '' "
		_CQUERY += " AND  SC6.C6_XAS = ? "
		_CQUERY += " AND  SC6.C6_BLQ NOT IN ('R','S') "
		_CQUERY += " AND  SC6.C6_FILIAL  = '"+XFILIAL("SC6")+"' "
		_CQUERY := CHANGEQUERY(_CQUERY)

		aBindParam := {_CNRAS}
		MPSysOpenQuery(_cQuery,"TRBPRI",,,aBindParam)

		IF TRBPRI->(!EOF())
			_LRET := .F.
		ENDIF

		TRBPRI->(DBCLOSEAREA())
	Else
	
		IF SELECT("TRBPRI") > 0
			TRBPRI->(DBCLOSEAREA())
		ENDIF

		_cQuery := " SELECT FPZ_AS "
		_cQuery += " FROM " + RETSQLNAME("FPZ") + " FPZ "
		_cQuery += " INNER JOIN "+RETSQLNAME("FPY")+" FPY  "
		_cQuery += " ON FPY.FPY_FILIAL = FPZ.FPZ_FILIAL AND FPY.FPY_PEDVEN = FPZ.FPZ_PEDVEN AND FPY.FPY_TIPFAT = 'P' AND FPY.D_E_L_E_T_ = '' AND FPY.FPY_STATUS <> '2 ' "
//		_cQuery += " INNER JOIN "+RETSQLNAME("SC5")+" SC5 (NOLOCK) ON SC5.C5_FILIAL = FPZ.FPZ_FILIAL AND SC5.C5_NUM = FPZ.FPZ_PEDVEN AND SC5.D_E_L_E_T_ = ' ' "
		_cQuery += " INNER JOIN "+RETSQLNAME("SC6")+" SC6 "
		_cQuery += " ON SC6.C6_FILIAL = FPZ.FPZ_FILIAL AND SC6.C6_NUM = FPZ.FPZ_PEDVEN AND SC6.C6_ITEM = FPZ.FPZ_ITEM AND SC6.C6_BLQ NOT IN ('R' , 'S') AND SC6.D_E_L_E_T_ = '' "
		_cQuery += " WHERE FPZ.D_E_L_E_T_ = '' "
		_cQuery += " AND FPZ_FILIAL = '"+XFILIAL("FPZ")+"' "
		_cQuery += " AND FPZ.FPZ_AS = ? "

		_cQuery := CHANGEQUERY(_cQuery)
		aBindParam := {_CNRAS}
		MPSysOpenQuery(_cQuery,"TRBPRI",,,aBindParam)

		IF TRBPRI->(!EOF())
			_LRET := .F.
		ENDIF

		TRBPRI->(DBCLOSEAREA()) 


	EndIf

RETURN _LRET



/*/{PROTHEUS.DOC} VALPRATA
@DESCRIPTION RETORNA VALOR A SER FATURADO COM DEVOLUCOES PARCIAIS.
@TYPE    FUNCTION
@AUTHOR  IT UP BUSINESS
@SINCE   08/03/2019
@VERSION 1.0
/*/
STATIC FUNCTION VALPRATA(_CAS , _DDTINI , _DDTFIM , _NQUANT , _NVALBRUT)
Local _NRET     := 0
RETURN _NRET

/*/{PROTHEUS.DOC} CRIASX1
@DESCRIPTION CRIA PERGUNTE DO FATURAMENTO AUTOMATICO.
@TYPE    FUNCTION
/*/
STATIC FUNCTION CRIASX1()
RETURN NIL

/*/{PROTHEUS.DOC} VALPROC
@DESCRIPTION FUNÇÃO PARA VALIDAR SE PODE REALIZAR O PROCESSAMENTO E CHAMADA DO PONTO DE ENTRADA LCJF1CLD
@TYPE    FUNCTION
@AUTHOR  IT UP BUSINESS
/*/
STATIC FUNCTION VALPROC()
LOCAL LRET := .T.

	IF LRET .AND. EXISTBLOCK("LCJF1VLD")							// --> PONTO DE ENTRADA PARA VALIDACAO DE GERACAO DA FATURA AUTOMATICO.
		LRET := EXECBLOCK("LCJF1VLD" , .T. , .T. , NIL)
	ENDIF

RETURN LRET


// Rotina para verificar se tem que deletar o movimento da pro-rata
// neste momento estamos posicionados na linha da SC6.
Function DELTITPR(cAsDel,cProjDel)
Local _aArea := GetArea()
Local aAreaFPA := FPA->(GetArea())

	// Deleta os títulos provisórios
	LOCA013DEL(2, cProjDel, cAsDel, .T.)

	FPA->(RestArea(aAreaFPA))
	RestArea(_aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ MARCARREGIº AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ FUNÇÃO AUXILIAR DO LISTBOX, SERVE PARA MARCAR E DESMARCAR  º±±
±±º          ³ OS ITENS.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MARCARREGI(LTODOS)
Local NI        := 0
Local LMARCADOS := _ASZ1[OFILOS:NAT,1]

	IF LTODOS
		nContaReg := 0
		LMARCADOS := ! LMARCADOS
		FOR NI := 1 TO LEN(_ASZ1)
			_ASZ1[NI,1] := LMARCADOS
			If LMARCADOS
				nContaReg++
			EndIf
		NEXT NI
	ELSE
		_ASZ1[OFILOS:NAT,1] := !LMARCADOS
		If LMARCADOS
			nContaReg--
		Else
			nContaReg++
		EndIf
	ENDIF

	OCONT:REFRESH()
	OFILOS:REFRESH()
	ODLGFIL:REFRESH()

RETURN NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} LC007DOC
@description	Chama MsDocument
@author			José Eulálio
@version   		1.00
@since     		16/11/2021
/*/
//-------------------------------------------------------------------
STATIC FUNCTION LC007DOC()
	ItupDocs("FPG", FPG->(Recno()))
RETURN


// rotina para pesquisa dentro da listbox
// Frank Fuga em 13/12/23
Static Function ITPESQ(OFILOS,cPesq)
Local nX
Local nY
Local nZ
Local xTemp
Local nLAtual
Local lAchou := .F.

	cPesq := alltrim(cPesq)
	nLAtual := oFilos:nAt
	If !empty(cPesq)
		nZ := 1
		While .T.
			nZ ++
			If nZ > 3
				Exit
			EndIF
			For nX := 1 to len(oFilos:aArray) // Linhas
				If nX >= nLAtual
					For nY := 1 to len(oFilos:aHeaders) // colunas
						xTemp := oFilos:aArray[nX,nY]
						If valtype(xTemp) $ "CNDM"
							If valtype(xTemp) == "N"
								xTemp := alltrim(str(xTemp))
							EndIf
							If valtype(xTemp) == "D"
								xTemp := dtoc(xTemp)
							EndIf
							If AT(cPesq,xTemp) > 0
								oFilos:nAt := nX
								lAchou := .T.
								Exit
							EndIf
						EndIF
					Next
				EndIF
				If lAchou
					Exit
				EndIF
			Next
			If !lAchou .and. nZ > 1
				oFilos:nAt := 1
				nLAtual := 1
			Else
				exit
			EndIf
		EndDo
		If !lAchou
			MsgAlert(STR0118 ,STR0007) // ###Atenção
		EndIf
	EndIF

Return .T.

// Rotina para processamento off-line
// Grava na FPK (tabela de processamento off-line) os registros a serem processados
// Frank em 13/11/24
Function LOCA021OFF(cProjDe, cProjAte, nTipo,aSelecao)
Local lRet := .T.
Local aArea := GetArea()
Local cPacote := ''
Local aEXecAuto := {}

Private lSchedule   := FWIsInCallStack("LOCA021SC")

	cPacote := GETSXENUM("FPK","FPK_NRBV")
	ConfirmSx8()

	FPK->(RecLock("FPK",.T.))
	FPK->FPK_FILIAL	:= xFilial("FPK")
	FPK->FPK_NRBV	:= cPacote
	FPK->FPK_ITEM	:= '0001'
	FPK->FPK_DATA	:= dDataBase
	FPK->FPK_HORA	:= Time()
	FPK->FPK_DTFIM	:= ctod("")
	FPK->FPK_HFIM	:= ""
	FPK->FPK_SOT    := cProjDe
	FPK->FPK_SOTATE := cProjAte
	FPK->FPK_TIPO   := Str(nTipo,1,0)
	FPK->FPK_STATUS	:= "2"
	FPK->(MsUnlock())
	RestArea(aArea)

	aExecAuto := {}
	aadd(aExecAuto,MV_PAR01) // 1 Data Inicial
	aadd(aExecAuto,MV_PAR02) // 2 Data Final
	aadd(aExecAuto,MV_PAR03) // 3 Cliente de
	aadd(aExecAuto,MV_PAR04) // 4 Cliente ate
	aadd(aExecAuto,MV_PAR05) // 5 Loja de
	aadd(aExecAuto,MV_PAR06) // 6 LOja ate
	aadd(aExecAuto,MV_PAR07) // 7 Equipamento de
	aadd(aExecAuto,MV_PAR08) // 8 Equipamento ate
	//aadd(aExecAuto,MV_PAR09) // Projeto de
	//aadd(aExecAuto,MV_PAR10) // Projeto ate
	//aadd(aExecAuto,MV_PAR11) //  Tipo de Projeto 1=Locacao; 2=Custos Extra; 3=Ambos
	aadd(aExecAuto,MV_PAR12) // 09 Produto de
	aadd(aExecAuto,MV_PAR13) // 10 Produto até

//	aadd(aExecAuto,MV_PAR14) //  Selecao 1=Nao;2=Sim
	aadd(aExecAuto,MV_PAR15) // 11 Obra de
	aadd(aExecAuto,MV_PAR16) // 12 Obra ate
	aadd(aExecAuto,MV_PAR01) // 13 Data Inicial
	aadd(aExecAuto,MV_PAR02) // 14 Data Final

	aadd(aExecAuto,MV_PAR17) // 15  Tipo Mes 1=Fechado/Fixo; 2=Corrido; 3=Ambos
	aadd(aExecAuto,MV_PAR18) // 16 Gera em de
	aadd(aExecAuto,MV_PAR19) // 17 Gera em ate

	aadd(aExecAuto,MV_PAR20) //  18 PRocessamento 1=On-Line; 2=Off-Line

	IF lSchedule
		Loca021Ger(cEmpAnt, cFilant, aExecAuto, aSelecao, FPK->(Recno()),lSchedule)
	ELSE	
		// Acionar o Job off-line
		startjob("LOCA021GER",getenvserver(),.F.,cEmpAnt, cFilant, aExecAuto, aSelecao, FPK->(Recno()), lSchedule)
	ENDIF
Return lRet


// Rotina para processamento off-line - gera pv
// Frank em 13/11/24
Function LOCA021GER(cEmp, cFil, aExecAuto, aSelecao, nFPKRECNO, lSchedule)
//Local _APARAM	:= {SM0->M0_CODIGO,SM0->M0_CODFIL}

Local lRet := .T.
Local cLote
Local cPrjd
Local cPrja

Private LMSERROAUTO := .F.
Private aRetJob := {"",{"",0,0}}
Private lAutoErrNoFile := .T.
Private lMsHelpAuto :=.T.
Private cRetErro := ""
Private aRetExec := {}

if !lSChedule
	RPCClearEnv()
	RpcSetType(3)
	RpcSetEnv(cEmp, cFil,,,'LOC','LOCA021GER',{"FP0","FPA","FQZ","SF4","SA1"},,.T.,,.T.)
endif
	/*
	IF FINDFUNCTION("WFPREPENV")
		WFPREPENV(_APARAM[1] , _APARAM[2])
	ELSE
		PREPARE ENVIRONMENT EMPRESA _APARAM[1] FILIAL _APARAM[2]
	ENDIF
	*/

	BEGIN Transaction

		dbSelectArea("FPK")
		FPK->(dbGoto(nFPKRECNO))

		// Status em processamento
		FPK->(RecLock("FPK",.F.))
		FPK->FPK_STATUS := "2"
		FPK->(MsUnlock())

		cLote := FPK->FPK_NRBV

		cPrjd := FPK->FPK_SOT
   		cPrja := FPK->FPK_SOTATE

		MSEXECAUTO({|A,B,C,D,E,F,G,H| LOCA021(A,B,C,D,E,F,G,H)} ,;
			Nil , cPrjd , cPrja, {} , .T. , Val(FPK->FPK_TIPO) , aExecAuto, aSelecao)

		If !Empty(aRetJob[1])

			FPK->(RecLock("FPK",.F.))
			FPK->FPK_STATUS := "4"
			FPK->FPK_ERROS := aRetJob[1]
			FPK->FPK_DTFIM  := dDataBase
			FPk->FPK_HFIM   := Time()
			FPK->(MsUnlock())
		endif
		if !Empty(aRetJob[2,1]) // Tem Pedidos gerados
			cRetExec := ""
			nTotal := 0
			FPK->(RecLock("FPK",.F.))
			if Empty(aRetJob[1])
				FPK->FPK_STATUS := "3"
			endif
			FPK->FPK_RESULT := aRetJob[2,1]
			FPK->FPK_QUANT  := aRetJob[2,2]
			FPK->FPK_VLTOT  := aRetJob[2,3]
			FPK->FPK_DTFIM  := dDataBase
			FPk->FPK_HFIM   := Time()
			FPK->(MsUnlock())
		EndIF

	End Transaction

Return lRet

/*/{PROTHEUS.DOC} LOCA021V
ITUP BUSINESS - TOTVS RENTAL
VALIDACAO DA FPY E FPZ ANTES DA GERAÇÃO DO PV
@AUTHOR FRANK ZWARG FUGA
@SINCE 22/05/2025
/*/

Function LOCA021V(aCabec, aItens, aAGlurat)
Local lRet := .T.
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.)
Local lForca := file("\SYSTEM\L021E1.TXT")

Default aAGlurat := {}

	If lMvLocBac
		lRet := .F.
		
		If len(aFPY) > 0
			If !empty(aFPY[3])
				lRet := .T.
			EndIf
		EndIF

		If lRet
			If len(aAGlurat) == 0
				If len(aItens) <> len(aFPZ) .or. lForca
					lRet := .F.
				EndIf
			Else
				If len(aFPZ) <> len(aaglurat) .or. lForca // // DSERLOCA 8626 - aaglurat não é do mesmo tamanho do aFPZ
//					lRet := .F.
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} LOCA021I
ISSUE 7851 - Preview do faturamento
@author Frank Zwarg Fuga
@since 30/07/2025
/*/
Function LOCA021I(aCabec)
aadd(aRetExec,{aCabec,dUltFat248,FPA->FPA_VRHOR,FPA->FPA_AS,FPA->FPA_CUSTO,FPA->FPA_CONPAG,FPA->FPA_OBRA,FPA->FPA_SEQGRU,DULTFAT})
Return .T.

/*/{Protheus.doc} LOCA021X
@author Rossana
@since 22/09/2025
/*/
Function LOCA021X

return .t.
