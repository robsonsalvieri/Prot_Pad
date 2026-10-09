#INCLUDE "CTBA105.CH"
#INCLUDE "FONT.CH"
#INCLUDE "PROTHEUS.CH"
#include 'fwlibversion.ch'

STATIC __aMedias[99]
STATIC __aDtMedias 	:= {}

STATIC __lConOutR
STATIC __lCusto 	:= CtbMovSaldo("CTT")
STATIC __lItem		:= CtbMovSaldo("CTD")
STATIC __lCLVL		:= CtbMovSaldo("CTH")
STATIC __lEnt05		:= C105QtdEnt() >= 5
STATIC __lEnt06		:= C105QtdEnt() >= 6
STATIC __lEnt07		:= C105QtdEnt() >= 7
STATIC __lEnt08		:= C105QtdEnt() >= 8
STATIC __lEnt09		:= C105QtdEnt() >= 9
STATIC __jErrorList := Nil
STATIC __lCT2Incons := CT2->(FieldPos("CT2_INCONS"))>0
STATIC __lCT2IncDet := CT2->(FieldPos("CT2_INCDET"))>0

STATIC __ClearCx 	:= Nil

STATIC aMVS[6]
STATIC MAX_LINHA
STATIC lEXELOTECTB 	:= ExistBlock("LOTECTB")
STATIC lCt105LOK	:= ExistBlock("CT105LOK")
STATIC lCT105VLENT 	:= ExistBlock("CT105VLENT") //P.E. para validacao das ent. contabeis na gravacao
STATIC lCt105TOK	:= ExistBlock("CT105TOK")
STATIC lCt105CHK	:= ExistBlock("CT105CHK")
STATIC lAntCtbGrv	:= ExistBlock("ANTCTBGRV")
STATIC lDepCtbGrv	:= ExistBlock("DEPCTBGRV")
STATIC lAltDataL	:= ExistBlock("ALTDATAL")
STATIC lCt105Qry	:= ExistBlock("CT105QRY")
STATIC lCT102DLG	:= ExistBlock("CT102DLG")
STATIC lCt105OutM	:= ExistBlock("CTB105OUTM")
STATIC lCt105Pos	:= ExistBlock("CT105POS")
STATIC lCampoESP	:= ExistBlock("C105CESP")
STATIC lCt105But	:= ExistBlock("CT105But")
STATIC lCt105SbLote := ExistBlock("CT105SBLOTE")
Static _lC105VLIN   := ExistBlock("C105VLIN")
Static _lCT105REV   := ExistBlock("CT105REV")
STATIC lAglByHist	:= Nil
STATIC cMVAGLPROC   := Nil
STATIC lMVAGLHIST   := Nil

STATIC lCTKHAGLUT  	:= .T.

STATIC __cCurdir    := CurDir()
STATIC __issrvunix  := IsSrvUnix()
STATIC __IsCtbJob	   := NIL

STATIC cDbsExt		:= GetDBExtension()
STATIC cIndExt		:= OrdBagExt()

STATIC cPictVal  	:= MyPesqPict("CT2","CT2_VALOR")
STATIC aMoedaOk		:=	{}
STATIC aCTOCTPOK	:=	{}

STATIC nQtdEntid
Static aPerCache    :=  {} // Grava os períodos e moedas válidas na data do lançamento
STATIC lVldTps 		:= SuperGetMv("MV_CTBCTG",.T.,.F.) // Habilita validação por amarração entre calendário x moeda x tipo de saldo

Static cEnt05Db		:= Nil
Static cEnt05Cr		:= Nil
Static cEnt06Db		:= Nil
Static cEnt06Cr		:= Nil
Static cEnt07Db		:= Nil
Static cEnt07Cr		:= Nil
Static cEnt08Db		:= Nil
Static cEnt08Cr		:= Nil
Static cEnt09Db		:= Nil
Static cEnt09Cr		:= Nil
Static cAtiviDb		:= Nil
Static cAtiviCr		:= Nil
Static __lDCDUso    := NIL
Static __alDtTaxa   := NIL
Static __cCodSeq		:= ""
Static __lMoedFat		:= Nil


STATIC __aCampos	:= Nil
STATIC __aAltera	:= Nil
STATIC __aHeadCtb	:= Nil
STATIC __nUsado 	:= Nil

Static __lProcCtb	:= Nil   //trocado nome para ficar mais claro a utilizacao por procedure  - __lArqTmpB
Static __cArq1		:= ""
Static __cArq2		:= ""
Static _cAliasOld   := NIL   //alias tmp a ser salvo para posterior recuperacao do alias
Static _cAliasTmp   := NIL   //alias da tabela temporaria utilizada na MSGETDB
Static _oCTBA105    := NIL   //Objeto para receber metodos da classe FwTemporaryTable
Static __cGetRealname := ""

Static __lBlind		:= IsBlind()
Static __cProcAmar 	:= NIL
Static __cProcRegra := NIL
Static __cProcPai 	:= NIL
Static __cProcGrv   := NIL
Static __cProcZero  := NIL
Static __cProcSoma1 := NIL
Static __cProcDoc   := NIL
Static __cProcFil   := NIL

Static	_lCtbGrv 	:= ExistBlock("CTBGRV")

Static __oCritPln	:= JsonObject():New()
Static lRotMVC		:= .F.
Static lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) //Flag to indicate if is Russia location
Static lNewRelease   := GetRpoRelease() >= "12.1.031"

//objeto para changequery do CTK
STATIC __LoadCTK	:= NIL
STATIC __cQuery		:=''
STATIC __LoadCTKGRVG:= NIL
STATIC __cQueryGrv	:=''
STATIC __oQueryTdOk := NIL

STATIC __lSleepOra  := 1000
Static __cSGBD      := Alltrim(Upper(TcGetDB()))
STATIC __SgdbOra    := Iif(__cSGBD == 'ORACLE', .T., .F. )
STATIC __SgdbPg     := Iif(__cSGBD == 'POSTGRES', .T., .F. )
Static lVazioSubL  := If(Empty(GetNewPar("MV_SUBLOTE"," ")),.T.,.F.)
Static lQuebraLP   := GetNewPar("MV_CTBQBLP",.F.)
Static __lIntPOUI  := .F. //Controle de integracao com POUI
Static lFromProcPOUI //Controle de chamada pelo CTBA102POUI

Static _oQryTdOk1   
Static _oQryTdOk2   
Static _oQryTdOk3
Static _oQryTdOk4
Static _MVCRITPLN  := SuperGetMv( "MV_CRITPLN" , .F., .T.)

#DEFINE MV_ALTLCTO		1
#DEFINE MV_SUBLOTE		2
#DEFINE MV_PRELAN		3
#DEFINE MV_CONTSB		4
#DEFINE MV_CONTBAT		5
#DEFINE MV_SOMA    		6

#DEFINE D_PRELAN		"9"

#DEFINE DEF_DB_ORACLE   "ORACLE"
#DEFINE DEF_DB_MSSQL    "MSSQL"
#DEFINE DEF_DB_POSTGRES "POSTGRES"
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS     ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf Medrano ³08/04/16³TVPIJ3    ³Merge v118 vs v1217                      ³±±
±±³            ³        ³          ³Se modif Func CT105TOk se agrega CT102LOK³±±
±±³            ³        ³          ³Valida existencia de NIT en comprobantes ³±±
±±³            ³        ³          ³contables COLOMBIA                       ³±±
±±³            ³        ³          ³Se agrega comentarios en func CT102LOK   ³±±
±±³Dora Vega   ³04/09/17³DMINA-169 ³Rep. 12.1.7 Se incluye validacion de     ³±±
±±³            ³v12.1.07³DMINA-67  ³items encontrados en browse, tras carga  ³±±
±±³            ³        ³          ³de Asientos Contables desde la rutina    ³±±
±±³            ³        ³          ³Contabilidad TXT. Pais: TODOS            ³±±
±±³Raul Ortiz  ³13/12/17³DMICNS-649³Se realizan modificaciones para uso de   ³±±
±±³            ³        ³          ³tablas temporales - arg                  ³±±
±±³Marco Aur   ³22/03/18³DMICNS-   ³Efetuado alterações para uso de tabelas  ³±±
±±³            ³        ³ 1588     ³temporarias do FINA087A - Arg            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CTB_Incl  ³ Autor ³ Pilar S Albaladejo    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de inclus„o de Lan‡amentos Cont beis.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:=CTB105Incl(ExpC1,ExpN1,ExpN2,ExpC2,ExpL1,ExpL2)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Nome do arquivo                                    ³±±
±±³          ³ ExpN1 = Numero do Header                                   ³±±
±±³          ³ ExpN2 = Numero da Opcao escolhida                          ³±±
±±³          ³ ExpC2 = Numero do Lote                                     ³±±
±±³          ³ ExpL1 = Se Mostra ou nao                                   ³±±
±±³          ³ ExpL2 = Se Aglutina ou nao                                 ³±±
±±³          ³ ExpC3 = Determina se sera On Line ou pelo cProva           ³±±
±±³          ³ dData = Data para geracao dos lancamentos contabeis        ³±±
±±³          ³ dReproc = Parametro que indica que lancamentos nao atualiza³±±
±±³          ³           saldos e apos gravacao executa reprocessamento   ³±±
±±³          ³ aFlagCTB    = Array com dados para utilizacao do CTB       ³±±
±±³          ³ aDadosProva = Array com dados para utilizacao multi-thread ³±±
±±³          ³ aTpSaldo = Array para armazenar os tipos de saldos gerados ³±±
±±³          ³            no lancamento contabil                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB_Incl(	cArquivo, nHdlPrv, nOpcx, cLoteContabil, lDigita, lAglut, cOnLine,;
					dData, dReproc, aFlagCTB, aDadosProva, aTpSaldo, aSeqDiario, lSimula,;
					cTabCTK, cTabCT2,cIdProcess)

Local aSaveArea	    := GetArea()
Local nOpca			:= 0
Local nArqAbre		:= 1
Local cArqAbre		:= "CT0"
Local CTF_LOCK		:= 0
Local cCadastro 	:= OemToAnsi(STR0001)				// Lancamentos Contabeis
Local cEmpOri		:= cEmpAnt
Local cFilOri		:= cFilAnt
Local oSize

Local oDlg
Local oFilial
Local oLote
Local oSubLote, lSubLote
Local oDoc
Local oHistCapLt
Local oFnt

Local lFirst		:= .T.
Local lRpc			:= Type("oMainWnd") = "U"		// Chamada via Rpc nao tem tela
Local lRpcOk		:= .T.
Local nLin  		:= 0
Local nRecCTK 		:= 0
Local cAliasCTK		:= "CTK"

// Variaveis para guardar eventuais funcoes ja atruibuidas às teclas F4 F5 F6 e F7 em outros modulos, para serem
// restauradas no final.
Local bVK_4
Local bVK_5
Local bVK_6
Local bVK_7

Local cPreLcto		:= ""
Local cRotina		:= FunName()
Local cProgName		:= ""
Local aButton 		:= {}
Local aButtonNew	:= {}
Local cLoteEXEC		:= ""
Local cSbLoteExec   := ""
Local cExpFil		:= ""
Local cTxtfil		:= ""

Local aCTKxCT2		:= {}
Local dCt2Data
Local aStruCTK 	:= {}
Local aStruQry		:= {}
Local lOrdEnt		:= If(GetNewPar("MV_ORDLCTB","L")=="E",.T.,.F.)			/// MV_ORDLCTB : L= LP (sequen+lp)/ E = Entrada (Recno)
Local nMoedas		:= 0
Local nPosQry		:= 0
Local nY
Local lOrdTpSld		:= If(GetNewPar("MV_ORDLCTB","L")=="T",.T.,.F.)			/// MV_ORDLCTB : T= Tipo de Saldo
Local lOrdLp        := If(GetNewPar("MV_ORDLCTB","L")=="L",.T.,.F.)			/// MV_ORDLCTB : L= Lanc.Padrao
Local nTipoSaldo

Local lSeqCorr   	:= UsaSeqCor("CT2/CTK/CT5")
Local cSeqCorr 		:= Space(10)
Local nX
Local cChaveCT2		:= ""
Local cChaveCTK		:= ""
Local lDigitaOri    := lDigita   // salva o status original
Local cHistCapLt	:= "" //Historico Capa do Lote
Local nCtr1stRow
Local nLbl1st1
Local nCmp1st1
Local nLbl1st2
Local nCmp1st2
Local nQry := 1 

Local nCtr3rdRow
Local nLbl3rd1
Local nCmp3rd1
Local nLbl3rd2
Local nCmp3rd2
Local nLbl3rd3
Local nCmp3rd3
Local lExistcFun    := Type("cFunname")<>"U"

Local cFilLanc		:= FWXFilial("CT2")
Local lFlagMain     := .F.
Local aValDif		:= {}
Local lLockRec      as Logical

//Variaveis utilizadas para metricas
Local nQtdCntb		:= 0

//variaveis para utilizar o FwPreparedStatement para a Changequery. 
Local cAuxCTK       := ""
Local aSelect		:= {}
Local lBlqMoeda     := SuperGetMV('MV_CTBBLMO',, .F.) // Indica se haverá bloqueio do lançamento contábil caso pelo menos uma moeda não tenha calendário amarrado.
Local lExit         := .F.

Private aTELA		:= {}
Private aGETS		:= {}
Private aCols		:= Nil
Private aRotina		:= MenuDef()
Private dDataLanc	:= Iif(dData == Nil,dDataBase,dData)
Private nTotInf		:= 0
Private aTotRdpe 	:= {{0,0,0,0},{0,0,0,0}}
Private nUsado		:= 0
Private nSaida		:= 0

Private oDig
Private oDeb
Private oCred
Private oInf
Private oDescEnt

Private cLote		:= cLoteContabil, cSubLote
Private cDoc		:= Space(6)

Private cSeqCrAnt   := Space(10)

Private aColsP		:= {}
Private oGetDb

Private OPCAO
Private aCtbEntid

Private __aCT2LC	:= {}

Private aAltera		:= {}
Private aHeader		:= {}

Private oFlag105 := JsonObject():New()

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

If FindFunction("ClearCT2LC")
	ClearCT2LC() //- limpeza do objeto Json
Endif

//Tratamento para verificar se prossegue lançamento
//- não mudar esta posicao do fonte
If nHdlPrv == 65536	.and. GetHProva() == 1024
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso houve abertura por HeadProva() ( nHdlPrv == 65536 )     ³
	//³ e houve lan‡amento cont bil (Handle Interno == 1024)         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeqChave:= GetHFile()  // Retorna a chave dos dados gravados no CTK
Else
	RestArea(aSaveArea)
	Return .F.
Endif

//Tratamento para mudar o alias TMP Externo a ca100Incl que porventura estiver aberto 
//- nao mudar esta posicao do fonte - tem que ser a primeira a executar
CtbSavTmpE()

If __lConOutR
	ConOutR("*PROCES*|Iniciando a montagem do aheader.")
EndIf

//Se o fonte chamador não tem a chamada da CTBAINILAN, tento forçar o desvio pela procedure
If __lProcCtb == Nil		
	CtbIniLan()
ElseIf __lProcCtb .And. InTransAct()
	//Se o fonte chamador executou a CTBAINILAN, mas chamo a CTB_INCL em transação, desativo a procedure
	__lProcCtb := .F.
EndIf	

//bloco que vai criar o temporario com fwtemporary table e disponibilizar o mesmo como TMP daqui em diante - nao mudar esta posicao do fonte
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader para Lan‡amentos Cont beis                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Ctb105Head(@aAltera,lSimula)  //Nesta funcao sao carregada as variaveis static __aCampos  e  __aAltera - tem que executar antes da Ctb105Cria

If __lConOutR
	ConOutR("*PROCES*|Finalizando a montagem do aheader.")
	ConOutR("*PROCES*|Iniciando a criacao tabela temporaria.")
EndIf

Ctb105Cria(__aCampos)   //criacao e/ou limpeza da tabela temporaria - criada com fwtemporary table

If __lConOutR
	ConOutR("*PROCES*|Finalizando a criacao tabela temporaria.")
EndIf

//-->Aqui colocar tratamento para mudar o alias para TMP da tabela criada com FWTemporaryTable<----------------------------------
CtbChg_Tmp()

//----------->neste momento o alias TMP ta pronto para ser utilizada na MSGETDB<-------------------------------------------------
//-----------> a partir deste ponto o TMP do escopo da Contabilidade esta em uso <-----------------------------------------------

/* lNewRelease >= "12.1.31" */
 If lNewRelease
	lLockRec := .T.
	/* ---------------------------------------------------------------------------------------------
		Fazer o bloqueio dos Registros no módulo origem passadas pelo vetor aFlagCTBe nos conteudos
		dos campos CTK_TABORI e CTK_RECORI. Na maioria das vezes é o mesmo do vetor aFlagCTB 
	---------------------------------------------------------------------------------------------- */
	lLockRec:= _105LockFlg(aFlagCtb)
Endif

If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

lAglByHist := RetAlgHist()

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If aCtbEntid == NIL
	aCtbEntid := Array(2,nQtdEntid)  //posicao 1=debito  2=credito
EndIf

//DEBITO
aCtbEntid[1,1] := {|| TMP->CT2_DEBITO 	}
aCtbEntid[1,2] := {|| TMP->CT2_CCD		}
aCtbEntid[1,3] := {|| TMP->CT2_ITEMD 	}
aCtbEntid[1,4] := {|| TMP->CT2_CLVLDB 	}
//CREDITO
aCtbEntid[2,1] := {|| TMP->CT2_CREDIT }
aCtbEntid[2,2] := {|| TMP->CT2_CCC		}
aCtbEntid[2,3] := {|| TMP->CT2_ITEMC 	}
aCtbEntid[2,4] := {|| TMP->CT2_CLVLCR 	}

For nX := 5 TO nQtdEntid
	aCtbEntid[1, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"DB } ")  //debito
	aCtbEntid[2, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"CR } ")  //credito
Next

// controle de limpeza do cache
If __ClearCx == Nil
	__ClearCx := GetNewPar( "MV_CTBCLSC" , .F. )
Endif

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf

If __lConOutR
	ConOutR("*LOGINI*|INICIO CTBA105")
EndIf

If FindFunction("ClearCT2LC")
	ClearCT2LC() //- limpeza do objeto Json
Endif

DEFAULT aFlagCTB	:= {}
DEFAULT nOpcX		:= 3

// define o valor da variavel opcao utilizada na gravação
OPCAO := nOpcx

Default cIdProcess := "" 
__lIntPOUI := IIf(CT2->(FieldPos("CT2_INCONS")) > 0 .And. !Empty(cIdProcess), .T., .F.)  //Controle integracao POUI
__lBlind   := IIf(__lIntPOUI, __lIntPOUI, __lBlind) //Se chamada POUI, flag com Isblind pois não exibe msgs em tela Protheus

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Assume as informacoes do array aDadosProva, caso as mesmas   |
//| tenham sido passadas via parametro.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(aDadosProva) == "A"
	__HeadProva := ACLONE(aDadosProva)
EndIf

If aMVS[MV_ALTLCTO] = Nil
	aMVS[MV_ALTLCTO] := Iif( SuperGetMv( "MV_ALTLCTO" , .F., "S") == "S", .T., .F. )	
Endif

If aMVS[MV_SUBLOTE] = Nil
	aMVS[MV_SUBLOTE] := SuperGetMv("MV_SUBLOTE")
Endif

If aMvs[MV_PRELAN] = Nil
	aMvs[MV_PRELAN] := SuperGetMv("MV_PRELAN")
Endif

If MAX_LINHA = Nil
	MAX_LINHA := { CtbLinMax(SuperGetMv("MV_NUMLIN")), SuperGetMv("MV_NUMMAN") }
Endif

//Alterar o conteudo da variavel dDataLanc, caso exista o ponto de entrada
If lAltDataL .and. !lOrdTpSld .And. !lSimula
	dDataLanc	:= 	ExecBlock("ALTDATAL",.F.,.F.,{dDataLanc,cRotina})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a numeracao do lote foi alterada pelo PE LOTECTB³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEXELOTECTB .And. !lSimula		//PONTO DE ENTRADA PARA ALTERAÇÃO NO NUMERO DO LOTE CTB.
	cLoteEXEC := EXECBLOCK("LOTECTB",.F.,.F.,{cLote})
	If ValType(cLoteEXEC) == "C" .and. !Empty(cLoteEXEC)
		cLoteContabil := cLoteEXEC
	EndIf
EndIf

cSubLote	:= aMVS[MV_SUBLOTE]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Altera SubLote antes da gravação PE CT105SBLOTE    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lCt105SbLote .And. !lSimula		//PONTO DE ENTRADA PARA ALTERAÇÃO DO SUBLOTE CTB.
	cSbLoteExec := ExecBlock("CT105SBLOTE",.F.,.F.,{cSubLote})
	If ValType(cSbLoteExec) == "C" .and. !Empty(cSbLoteExec)
		cSubLote := cSbLoteExec
	EndIf
EndIf

lSubLote 	:= Empty(cSubLote)
nOpc		:= 4
cLote 		:= Iif(Len(Alltrim(cLoteContabil)) < 6 , PADL(ALLTRIM(cLotecontabil),6,"0") , cLoteContabil)

If __lConOutR
	ConOutR("*PROCES*|Inicializando o calculo das medias para conversão das moedas.")
EndIf

// Calcula medias para conversao de moedas
CtbMedias( dDataLanc )

If __lConOutR
	ConOutR("*PROCES*|Finalizando o calculo das medias para conversão das moedas e iniciando a leitura do headprova.")
EndIf

If __lConOutR
	ConOutR("*PROCES*|Finalizando a leitura do headprova e iniciando A ABERTURA DOS ARQUIVOS DO CTB.")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AQUI! Abre os Arquivos do CTB em outros m¢dulos              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nArqAbre :=1 to 20 // Arquivos CT1 a CTK
	cArqAbre := soma1(cArqAbre)
	If Select(cArqAbre) <= 0
		ChkFile(cArqAbre)
	Endif
Next

If __lConOutR
	ConOutR("*PROCES*|Finalizando a abertura dos arquivos do CTB.")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CT2")
If lSimula .and. !(lExistcFun .and. (cFunname == "FINA840" .or. cFunname == "FINA087A" .or. cFunname == "FINA850"))
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()
	If SIX->(dbSeek("CT21"))
		cChaveCT2 := AllTrim(SIX->CHAVE)
		IndRegua("CT2", cTabCT2, cChaveCT2, , , )
	EndIf
	dbSelectArea("CT2")
Else
	dbSetOrder(1)
EndIf

If __lConOutR
	ConOutR("*PROCES*|Inicio da leitura do CTK.")
EndIf

DbSelectArea("CTK")
If lSimula
	dbSelectArea("SIX")
	dbSetOrder(1)
	dbGoTop()
	If SIX->(dbSeek("CTK1"))
		cChaveCTK := AllTrim(SIX->CHAVE)
		IndRegua("CTK", cTabCTK, cChaveCTK, , , )
	EndIf
	dbSelectArea("CTK")
Else
	DbSetOrder(1)
EndIf

CTK->(DbCommit())		// Garanto que os registros estejam no BANCO

aStruCTK	:= CTK->(dbStruct())
cAliasCTK	:= "QUERYCTK"

cQuery := ""

If lAglut
	cQuery += "CTK_FILIAL,CTK_SEQUEN,CTK_DC"
	cQuery += ",CTK_DEBITO,CTK_CREDIT,CTK_CCD,CTK_CCC,CTK_ITEMD,CTK_ITEMC,CTK_CLVLDB,CTK_CLVLCR,CTK_MLTSLD"
	For nX := 5 TO nQtdEntid
		cQuery += ",CTK_EC"+StrZero(nX,2)+"DB,CTK_EC"+StrZero(nX,2)+"CR"
	Next
	cQuery += ",CTK_TPSALD,CTK_DATA,CTK_LP"

	If lAglByHist
		If lCTKHAGLUT
			cQuery += ",CTK_HAGLUT CTK_HIST" /// Campo CTK_HAGLUT recebe CTK_HIST como apelido
		Else
			cQuery += ",CTK_HIST"
		EndIf
	Endif

	cQuery += ",CTK_CODPAR"
	cQuery += ",CTK_DIACTB"

	//Tratativa para aglutinação da Moeda do fato - Variacao Cambial
	cQuery += ",CTK_MOEFDB,CTK_MOEFCR"
	
	For nMoedas	:= 1 to __nQuantas
		cQuery += ",SUM( CTK_VLR" + StrZero(nMoedas,2) + " ) CTK_VLR" + StrZero(nMoedas,2)
	Next

	cQuery +=",MAX(CONCAT(CTK_LP,CTK_LPSEQ)) CTKLPLPSEQ"
	cQuery +=",MIN(CTK_ORIGEM) CTK_ORIGEM"
	cQuery +=",MIN(CTK.R_E_C_N_O_) CTKMINRECNO"
	cQuery +=",MAX(CTK.R_E_C_N_O_) RECNO"
	cQuery +=",MIN(CTK_ROTINA) CTK_ROTINA"
	cQuery +=",MIN(CTK_KEY) CTK_KEY"
	cQuery +=",MIN(CTK_ATIVDE) CTK_ATIVDE"
	cQuery +=",MIN(CTK_ATIVCR) CTK_ATIVCR"
	cQuery +=",COUNT(1) CONTAAGLUT"
	cQuery += ",MIN(CTK_DTVENC) CTK_DTVENC"
	cQuery += ",CTK_AT01DB,CTK_AT02DB,CTK_AT03DB,CTK_AT04DB,CTK_AT01CR,CTK_AT02CR,CTK_AT03CR,CTK_AT04CR"
	If cPaisLoc == "MEX"
		If CTK->( FieldPos("CTK_UUID")) > 0 .and. CT2->(FieldPos("CT2_UUID")) > 0
			cQuery += ",CTK_UUID"
		Endif
		If CTK->( FieldPos("CTK_RFC")) > 0 .and. CT2->(FieldPos("CT2_RFC")) > 0
			cQuery += ",CTK_RFC"
		Endif
	EndIf
Else
	For nY := 1 To Len(aStruCTK)
		cQuery += aStruCTK[nY][1] + ","
	Next nY
	cQuery +="CTK.R_E_C_N_O_ RECNO"

EndIf

cQuery := " SELECT " + cQuery

cAuxCTK = Iif(lSimula, (cTabCTK), RetSqlName( "CTK" ))

cQuery += " FROM  "+cAuxCTK+" CTK "
cQuery += " WHERE CTK.CTK_FILIAL =  ? " 
cQuery += "   AND CTK.CTK_SEQUEN = ? " 	

If lAglut
	cQuery += "	AND CTK_DC IN (?) "
Endif

cQuery += " AND CTK.D_E_L_E_T_ = ? "

If lAglut
	cQuery += "GROUP BY CTK_FILIAL,CTK_SEQUEN,CTK_DC,CTK_DEBITO,CTK_CREDIT,CTK_CCD,CTK_CCC,CTK_ITEMD,CTK_ITEMC,CTK_CLVLDB,CTK_MLTSLD  "
	cQuery += ",CTK_AT01DB,CTK_AT02DB,CTK_AT03DB,CTK_AT04DB,CTK_AT01CR,CTK_AT02CR,CTK_AT03CR,CTK_AT04CR "
	For nX := 5 TO nQtdEntid
		cQuery += ",CTK_EC"+StrZero(nX,2)+"DB,CTK_EC"+StrZero(nX,2)+"CR"
	Next
	cQuery += ",CTK_CLVLCR,CTK_TPSALD,CTK_DATA,CTK_LP"
	If lAglByHist
		If lCTKHAGLUT
			cQuery += ",CTK_HAGLUT"
		Else
			cQuery += ",CTK_HIST"
		EndIf
	Endif

	cQuery += ",CTK_CODPAR"
	cQuery += ",CTK_DIACTB"

	//Tratativa para a aglutinação da moeda do fato - Variacao Cambial
	cQuery += ",CTK_MOEFDB,CTK_MOEFCR"

	If cPaisLoc == "MEX"
		If CTK->( FieldPos("CTK_UUID")) > 0 .and. CT2->(FieldPos("CT2_UUID")) > 0
			cQuery += ",CTK_UUID"
		Endif
		If CTK->( FieldPos("CTK_RFC")) > 0 .and. CT2->(FieldPos("CT2_RFC")) > 0
			cQuery += ",CTK_RFC"
		Endif
	EndIf

	cQuery += " ORDER BY  "
	If 	lOrdTpSld	/// MV_ORDLCTB : T= Tipo de Saldo
		cQuery += "CTK_TPSALD,"
	EndIf
	cQuery += "CTKMINRECNO " /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
Else
	If lOrdEnt
		cQuery += "ORDER BY RECNO"  //"+SqlOrder(CTK->(IndexKey())) /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
	Else
		cQuery += "ORDER BY "
		If 	lOrdTpSld	/// MV_ORDLCTB : T= Tipo de Saldo
			cQuery += "CTK_TPSALD,"
		ElseIf lOrdLp .AND. lVazioSubL .AND. lQuebraLP /// MV_ORDLCTB : L = Lanc.Padrao
			cQuery += "CTK_LP,"	
		EndIf

		cQuery += SqlOrder(CTK->(IndexKey())) /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
		cQuery += ", CTK_TABORI, CTK_RECORI, RECNO" /// ORDEM DE RECNO DEVIDO À SEQUENCIA DOS LANÇAMENTOS bops: 64512
	Endif
EndIf

If lCt105Qry .And. !lSimula
	cQuery 	:= 	ExecBlock("CT105QRY",.F.,.F.,{cQuery,lAglut})
EndIf


IF __LoadCTK == NIL .or. !__cQuery == cQuery
	__cQuery := cQuery
	If !__LoadCTK == NIL
		FreeObj(__LoadCTK)
	EndIf 
	cQuery := ChangeQuery(cQuery)
	__LoadCTK := FWExecStatement():New(cQuery)
EndIf 
__LoadCTK:SetString(nQry++,xFilial( "CTK" ) ) // P2 filial
__LoadCTK:SetString(nQry++,cSeqChave) 		 // P3 sequencia	

If lAglut
	__LoadCTK:Setin(nQry++,{'1','2','3'})
Endif
__LoadCTK:SetString(nQry++,Space(1) ) 

cAliasCTK := __LoadCTK:OpenAlias(cAliasCTK)

aStruQry	:= &(cAliasCTK)->(dbStruct())
For nY := 1 To Len(aStruCTK)
	If aStruCTK[nY][2] <> "C"
		//Verificar se o campo existe na query antes do TcSetField
		nPosQry	:= aScan(aStruQry,{|x|(x[1])==Trim(aStruCTK[nY][1])})
		If nPosQry > 0
			Aadd( aSelect, {aStruCTK[nY][1],aStruCTK[nY][2],aStruCTK[nY][3],aStruCTK[nY][4]})
		EndIf
	EndIf
Next nY
__LoadCTK:setFields( aSelect )
__LoadCTK:doTcSetField( cAliasCTK )

If __lConOutR
	ConOutR("*PROCES*|FIM QUERY CTK e Inicio da CARGA TMP.")
EndIf

cProgName := (cAliasCTK)->CTK_ROTINA
If Empty(cProgName)
	cProgName := FunName()
Endif

bVK_4 := SetKey(VK_F4)
bVK_5 := SetKey(VK_F5)
bVK_6 := SetKey(VK_F6)
bVK_7 := SetKey(VK_F7)

lEndCTK := .F.

ChgFlag105(aFlagCTB,.T.)

While (cAliasCTK)->( Ctb105Grv(	cSeqChave,lAglut,__aCampos,dDataLanc,@cSubLote,@nLin,@nRecCTK,cAliasCTK,@aFlagCTB,@aCTKxCT2,@lEndCTK,lSeqCorr,@cSeqCorr,aSeqDiario,Nil,lSimula,cTabCTK,cTabCT2,@cHistCapLt))

	__cCodSeq := SubStr(cSeqCorr,1,2)

	If __lConOutR
		ConOutR("*PROCES*|FIM CARGA TMP -> CTB105GRV")
	EndIf

	If TMP->(RecCount()) == 0

		//por conta do return abaixo tem que colocar este trecho para restaurar TMP carregado antes de chamar ca100Incl
		//nao retirar desta posicao antes do RestArea que antecede o Return
		CTBRstTmpE()

		RestArea(aSaveArea)
		Return
	EndIf

	If (lFirst .Or. (nLin > MAX_LINHA[1])) .And. !lSimula
		If CTF_LOCK > 0		//LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC (DEPOIS DE GRAVAR O PRIMEIRO DOC)
			dbSelectArea("CTF")
			dbGoTo(CTF_LOCK)
			CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
		Endif

		If lAltDataL .and. lOrdTpSld .And. !lSimula
			dDataLanc	:= 	ExecBlock("ALTDATAL",.F.,.F.,{dData,cRotina})
		EndIf
		
		Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o N§ do Doc estourou, incrementa o lote         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cLote := CtbInc_Lot(cLote, cModulo)

		Enddo
		
		lFirst := .F.

	Endif

	aButton := {}
	Aadd( aButton, {"RECALC"   , { || MsAguarde({|| CtRecRdPe()},STR0055) },STR0056 } )//"Recalculando totais..."#"Rec.Totais"
	Aadd( aButton, {"SIMULACAO",{ || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc)} , STR0015+" - <F5>",STR0016 } ) //"Totais do lote e documento (outras moedas)" "Totais"
	Aadd( aButton, {"PREV"     ,{ || CTB105Flt (oGetDb,.F.              ) },STR0019,STR0026 } ) //"Inconsistencia Anterior" //"Anterior"
	Aadd( aButton, {"NEXT"     ,{ || CTB105Flt (oGetDb,.T.              ) },STR0020,STR0050 } ) //"Proxima Inconsistencia" //"Próxima"
	If aMvs[MV_ALTLCTO]
		Aadd( aButton, {"CTBREPLA"   ,{ || Ctb102Repla()}, STR0051 ,STR0052		} ) //"Replicar o conteudo do campo posicionado"###"Replicar"
	EndIf
	aButton := AddToExcel(aButton,{	{"ARRAY",STR0053,{STR0002,STR0003,STR0013,STR0004},{{dDataLanc,cLote,cSubLote,cDoc}}},{"GETDB",STR0054,aHeader,"TMP"} } ) //"Documento"###"Lançamentos"
	Aadd( aButton, {"PESQUISA"   ,{ || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil) },STR0021 } ) //"Localizar"
	Aadd( aButton, {"IMPRIMIR"   ,{ || CTB_IMPLANC() }, OemToAnsi(STR0086) } ) //'Imprimir'

	//----------------------------------------------------------------
	// Ponto de entrada para inclusão de novos itens no menu aButton
	//----------------------------------------------------------------
	If lCT105But
		aButtonNew := ExecBlock("CT105But",.F.,.F.,aButton)
		If (ValType(aButtonNew) == "A")
			aButton := aClone(aButtonNew)
		EndIf
	EndIf

	If __lConOutR
		ConOutR("*PROCES*|PEGOU No DOCUMENTO CTB")
	EndIf

	__PreLan 	:= .F.		// Indica se tenta gravar como pre-lancamento

	If !lDigita										// Se altera lancamento -> visualiza!!
		If lRpc
			//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lAntCtbGrv .And. !lSimula
				ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
			Endif

			If __lConOutR
				ConOutR("*PROCES*|INICIO VALIDACOES1")
			EndIf

			//Validacao
			If lSimula
				lRpcOk := .T.
			Else
				lRpcOk	:= CTB105Rpc(lDigita) .And. Ct105TOK(lCT105TOK,lCT105CHK,.F., .F.,aTotRdpe,nTotInf)
			EndIf

			If !lRpcOk .Or. __Prelan == .T.
				cPreLcto	:= "S"
			Else
				cPreLcto	:= "N"
			EndIf

			If __lConOutR
				ConOutR("*PROCES*|FIM VALIDACOES1")
			EndIf

			If FwGetRunSchedule() .Or. __lBlind
				Ct105TOK(lCT105TOK,lCT105CHK,.F., .F.,aTotRdpe,nTotInf,,,@aValDif)
				CtbChkDif(aValDif, @aCTKxCT2, cTabCTK)		
			EndIf

			CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,__lCusto,__lItem,__lCLVL,,cProgName,;
					cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
					cHistCapLt,,,,,,,,,,,,cIdProcess)

			//- indica a existência de registros a atualizar e reforça a 
			//- sincronização do JSON
			IIf ( Len(aFlagCTB) > 0 , ( ChgFlag105(,.F.) , ChgFlag105(aFlagCTB,.T.) ) , .T.) 

			If __lConOutR
				ConOutR("*PROCES*|TERMINOU CTBGRAVA1")
			EndIf
			//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lDepCtbGrv .And. !lSimula
				ExecBlock("DEPCTBGRV",.F.,.F., {nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
			Endif

			If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo

				CtbZap_Tmp( "TMP" )   //selecionar alias TMP e dar ZAP para limpar o arquivo para proximo documento

			EndIf
		Else
			If __lConOutR
				ConOutR("*PROCES*|INICIO VALIDACOES2 | GRAVAÇÃO DO CT2")
			EndIf

			//Validacao
			If lSimula
				lRpcOk := .T.
			Else
				lRpcOk := Ct105TOK(lCT105TOK,lCT105CHK,.F.,.F.,aTotRdpe,nTotInf,,,@aValDif)
			EndIf

			IF ! lRpcOk
				lDigita := aMvs[MV_ALTLCTO]
			Else
				If !CtbValiDt(nOpc,dDataLanc)//Se nao tem uma data valida
					lDigita	:= .T. //Mostra lancamento contabil
		    	Endif
			Endif

			If !lDigita

				//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lAntCtbGrv .And. !lSimula
					ExecBlock("ANTCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
				Endif

				If lSimula
					lRpcOk := .T.
				Else
					lRpcOk := lRpcOk .And. CTB105Rpc(lDigita)
				EndIf

				If !lRpcOk  .Or. __Prelan == .T.
					cPreLcto	:= "S"
				Else
					cPreLcto	:= "N"
				EndIf

	           lSimula := Iif(cPaisLoc=="ARG" .and. !(lExistcFun .and. cFunname == "FINA850"),.f.,lSimula)
				
				CtbChkDif(aValDif, @aCTKxCT2, cTabCTK)
				
				CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,;
						__lCusto,__lItem,__lCLVL,,cProgName,cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,lSimula,cTabCTK,cTabCT2,;
						cHistCapLt,,,,,,,,,,,,cIdProcess)

				//- indica a existência de registros a atualizar e reforça a 
				//- sincronização do JSON
				If Len(aFlagCTB) > 0 
					ChgFlag105(,.F.)
					ChgFlag105(aFlagCTB,.T.)
				EndIf 

	           lSimula := Iif(cPaisLoc=="ARG" .and. !(lExistcFun .and. cFunname == "FINA850"),.t.,lSimula)

				//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lDepCtbGrv .And. !lSimula
					ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
				Endif

				If !lEndCTK		///Se não terminou a leitura de CTK carrega TMP novo
				
					CtbZap_Tmp( "TMP" )   //selecionar alias TMP e dar ZAP para limpar o arquivo para proximo documento

				EndIf

			EndIf

			If __lConOutR
				ConOutR("*PROCES*|FIM VALIDACOES2 | GRAVAÇÃO DO CT2")
			EndIf
		EndIf
	Endif

	If lDigita
		If __lConOutR
			ConOutR("*PROCES*|INICIO INTERFACE")
		EndIf
		nOpcA 		:= 0
		__PreLan 	:= .F.		// Indica se tenta gravar como pre-lancamento

		/* Nao pemite alteracao nos lancamentos complementares */
		If CTBLCUso()
			If AllTrim(TMP->CT2_ROTINA) == "__CTBLC__"
				nOpcA := 1
			Endif
		Endif

		lFlagMain := Type("oMainWnd")="U"

		While nOpcA == 0

			lExit := .F.
			
			If lFlagMain
				//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lAntCtbGrv
					ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
				Endif

				If __lConOutR
					ConOutR("*PROCES*|INICIO CTBGRAVA3")
				EndIf

				// valida sem mostrar ajudas, caso tenha erro
				// marca para pre-lancamento
				cPreLcto	:= "N"
				If! CTB105Rpc(lDigita, @nQtdCntb)
					cPreLcto	:= "S"
				EndIf

				If FwGetRunSchedule() .Or. __lBlind
					Ct105TOK(lCT105TOK,lCT105CHK,.F., .F.,aTotRdpe,nTotInf,,,@aValDif)
					CtbChkDif(aValDif, @aCTKxCT2, cTabCTK)
				EndIf
				
				CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,	__lCusto,__lItem,__lCLVL, nTotInf,cProgName,;
						cPreLcto ,	dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,;
						,,,cHistCapLt,,,,,,,,,,,,cIdProcess)
				
				//- indica a existência de registros a atualizar e reforça a 
				//- sincronização do JSON
				IIf ( Len(aFlagCTB) > 0 , ( ChgFlag105(,.F.) , ChgFlag105(aFlagCTB,.T.) ) , .T.) 
					
					
				 

				If __lConOutR
					ConOutR("*PROCES*|FIM CTBGRAVA3")
				EndIf

				//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
				//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
				//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
				//posteriormente.
				If lDepCtbGrv
					ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
				Endif

				If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo

					CtbZap_Tmp( "TMP" )   //selecionar alias TMP e dar ZAP para limpar o arquivo para proximo documento

				EndIf
	
				Exit

			Endif

			SetKey(VK_F4, { || Ctb102OutM(dDataLanc,cLote,cSubLote,cDoc) })
			SetKey(VK_F5, { || CTB105Flt (oGetDb,.F.                   ) })
			SetKey(VK_F6, { || CTB105Flt (oGetDb,.T.                   ) })
			SetKey(VK_F7, { || CTB105FtBs(oGetDb,@cExpFil,@cTxtFil     ) })

			//Faz o calculo automatico de dimensoes de objetos
			oSize := FwDefSize():New(.T.)

			oSize:lLateral	:= .F.
			oSize:lProp		:= .T. // Proporcional

			oSize:AddObject( "1STROW" ,  100, 08, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "2NDROW" ,  100, 78, .T., .T. ) // Totalmente dimensionavel
			oSize:AddObject( "3RDROW" ,  100, 14, .T., .T. ) // Totalmente dimensionavel

			oSize:aMargins	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3

			oSize:Process() // Dispara os calculos

			a1stRow := {	oSize:GetDimension("1STROW","LININI"),;
							oSize:GetDimension("1STROW","COLINI"),;
							oSize:GetDimension("1STROW","LINEND"),;
							oSize:GetDimension("1STROW","COLEND")}

			a2ndRow := {	oSize:GetDimension("2NDROW","LININI"),;
							oSize:GetDimension("2NDROW","COLINI"),;
							oSize:GetDimension("2NDROW","LINEND"),;
							oSize:GetDimension("2NDROW","COLEND")}

			a3rdRow := {	oSize:GetDimension("3RDROW","LININI"),;
							oSize:GetDimension("3RDROW","COLINI"),;
							oSize:GetDimension("3RDROW","LINEND"),;
							oSize:GetDimension("3RDROW","COLEND")}

			//calculo o centro objeto
			nCtr1stRow := a1stRow[1] + ((a1stRow[3] - a1stRow[1]) / 2)
			nCtr3rdRow := a3rdRow[1] + ((a3rdRow[3] - a3rdRow[1]) / 2)

			//defino as coordenadas das labels e dos campos.
			nLbl3rd1	:= nCtr3rdRow - 18
			nCmp3rd1	:= nCtr3rdRow - 20
			nLbl3rd2	:= nCtr3rdRow - 4
			nCmp3rd2	:= nCtr3rdRow - 6
			nLbl3rd3	:= nCtr3rdRow + 10
			nCmp3rd3	:= nCtr3rdRow + 8

			If lSeqCorr .OR. cPaisLoc == "ARG"
				nLbl1st1 := a1stRow[1] + 6
				nCmp1st1 := a1stRow[1] + 3
				nLbl1st2 := nCtr1stRow + 6
				nCmp1st2 := nCtr1stRow + 3
			Else
				nLbl1st1 := nCtr1stRow - 3
				nCmp1st1 := nCtr1stRow - 6
			EndIf

			DEFINE MSDIALOG oDlg TITLE cCadastro From oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
			oDlg:lMaximized := .T.

			@ nLbl1st1, a1stRow[2] + 000 Say OemToAnsi(STR0091) SIZE 25,9 PIXEl OF oDlg FONT oFnt //"Filial"
			@ nCmp1st1 ,a1stRow[2] + 024 MSGET oFilial VAR cFilLanc PIXEl SIZE 42, 10 OF oDlg PIXEL WHEN .F.

			@ nLbl1st1, a1stRow[2] + 071 Say OemToAnsi(STR0002) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Data"
			@ nCmp1st1, a1stRow[2] + 088 MSGET dDataLanc  Picture "99/99/9999" SIZE 45, 10 OF oDlg PIXEL HASBUTTON When aMvs[MV_ALTLCTO] Valid (NaoVazio(dDataLanc) .and. ;
				C050Next(dDataLanc,@cLote,@cSubLote,@cDoc,oLote,oSubLote,oDoc,@CTF_LOCK,3,2)).And.CtbValiDt(nOpc,dDataLanc) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

			@ nLbl1st1, a1stRow[2] + 137 Say OemToAnsi(STR0003) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Lote"
			@ nCmp1st1, a1stRow[2] + 150 MSGET oLote VAR cLote Picture "@!" PIXEl SIZE 25, 10 OF oDlg When aMvs[MV_ALTLCTO];
				Valid NaoVazio(cLote) .and.;
				C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK) .And.;
				Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,;
				oDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

			@ nLbl1st1, a1stRow[2] + 180 Say OemToAnsi(STR0013) SIZE 30,9 PIXEl	OF oDlg FONT oFnt	//"Sub-Lote"
			@ nCmp1st1, a1stRow[2] + 204 MSGET cSubLote Picture "!!!" PIXEl SIZE 24, 10 OF oDlg WHEN If( !lSeqCorr, aMvs[MV_ALTLCTO] .And. lSubLote, .F.) F3 "SB";
				VALID NaoVazio(cSubLote) .and.;
				C102ProxDoc(dDataLanc,cLote,@cSubLote,@cDoc,@oLote,@oSubLote,@oDoc,@CTF_LOCK) .And.;
				Ctb101Lote(dDataLanc,cLote,cSubLote,@cDoc,;
				oDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

		  	@ nLbl1st1, a1stRow[2] + 237 Say OemToAnsi(STR0004) SIZE 30,9 PIXEl OF oDlg FONT oFnt	//"Docto"
		  	@ nCmp1st1, a1stRow[2] + 253 MSGET cDoc Picture "999999" PIXEl SIZE 25, 10 OF oDlg When aMvs[MV_ALTLCTO];
				Valid NaoVazio(cDoc) .and.;
				Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,@CTF_LOCK,3) .And.;
				Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK) .And.;
				Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe)

			If lSeqCorr
		  		@ nLbl1st2 ,284 Say OemToAnsi(STR0014) PIXEl	OF oDlg SIZE 55,9 FONT oFnt	//"Correlativo"
		 		@ nCmp1st2 ,318 MSGET oDoc VAR cSeqCorr Picture PesqPict("CT2","CT2_NODIA") PIXEl	SIZE 80, 10 OF oDlg READONLY
			EndIf

			If cPaisLoc == "ARG" //Tratamento para o historico na capa do lote
		  		@ nLbl1st2 ,If(lSeqCorr,414,284) Say OemToAnsi(STR0068) PIXEl	OF oDlg SIZE 55,9 FONT oFnt	//"Historico"
		 		@ nCmp1st2 ,If(lSeqCorr,443,318) MSGET oHistCapLt VAR cHistCapLt Picture "@!" PIXEL SIZE 160, 10 OF oDlg
			EndIf

			TMP->(dbSetOrder(0))

			Ctb102TamHist()


			If aMvs[MV_ALTLCTO]
				oGetDB := MSGetDB():New( a2ndRow[1], a2ndRow[2], a2ndRow[3], a2ndRow[4], 4,"CT105LINOK", "CT105TOk", "+CT2_LINHA",.T.,aAltera,,.T.,DefMaxLinha(VAL(CT2->CT2_LINHA)),"TMP",,,,oDlg,,,"CT102DEL(nOpc)")
				oGetDB:cSuperDel := "IIf(CT105SDEL(nOpc),(Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,@aTotais,@aTotRdPe),oGetDb:oBrowse:Refresh()),)"
			Else
				oGetDB := MSGetDB():New( a2ndRow[1], a2ndRow[2], a2ndRow[3], a2ndRow[4], 2,"AlwaysTrue", "AlwaysTrue", "+CT2_LINHA",	.F.,,,.T.,,"TMP",,,,oDlg,,,"CT102DEL(nOpc)")
			EndIf

			Ctb102TamHist(.T.)

			aTotMov	:= CtbTotMov()
			aTotais	:= Ctb050Tot(dDataLanc,cLote,cSubLote,cDoc)

			//Contem os saldos do CT6 + Conteudo da Tela
			aTotRdPe[1][2] := aTotMov[1][2]
			aTotRdPe[1][3] := aTotMov[1][3]
			aTotRdPe[1][1] := aTotMov[1][1]

			//Contem somente o que esta na GETDB.
			aTotRdPe[2][2] := aTotMov[1][2]
			aTotRdPe[2][3] := aTotMov[1][3]
			aTotRdPe[2][1] := aTotMov[1][1]

			nTotInf	:= aTotais[1][4]

			@ nLbl3rd1, a3rdRow[2] + 008  	SAY OemToAnsi(STR0012) Of oDlg PIXEL FONT oFnt //"Descri‡„o da Entidade"
			@ nCmp3rd1, a3rdRow[2] + 073 	SAY oDescEnt PROMPT space(50) FONT oDlg:oFont PIXEL COLOR CLR_HBLUE	Of oDlg

			@ nLbl3rd2, a3rdRow[2] + 008  	SAY OemToAnsi(STR0006) Of oDlg PIXEL FONT oFnt //"Total Informado :"
			@ nLbl3rd3, a3rdRow[2] + 008  	SAY OemToAnsi(STR0007) Of oDlg PIXEL FONT oFnt //"Total Digitado  :"
			@ nCmp3rd2, a3rdRow[2] + 065 	MSGET oInf VAR nTotInf Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
			@ nCmp3rd3, a3rdRow[2] + 065 	MSGET oDig VAR aTotRdpe[1][1] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL

			@ nLbl3rd2, a3rdRow[2] + 190 	SAY OemToAnsi(STR0008) Of oDlg PIXEL FONT oFnt //"Total Debito  :"
			@ nLbl3rd3, a3rdRow[2] + 190	SAY OemToAnsi(STR0009) Of oDlg PIXEL FONT oFnt //"Total Credito :"
			@ nCmp3rd2, a3rdRow[2] + 240	MSGET oDeb VAR aTotRdPe[1][2] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL
			@ nCmp3rd3, a3rdRow[2] + 240	MSGET oCred VAR aTotRdPe[1][3] Picture cPictVal Of oDlg READONLY SIZE 95 ,9 PIXEL


			//ponto de entrada para usuario
			If lCT102DLG
				Execblock("CT102DLG",.f.,.f.)
			Endif

			If __lConOutR
				ConOutR("*PROCES*|FIM INTERFACE")
			EndIf

			ACTIVATE MSDIALOG oDlg ON INIT (	oGetDB:oBrowse:Refresh(),;
													EnchoiceBar(oDlg,{||nOpcA:=1,IIf(Ct105TOK(lCT105TOK,lCT105CHK,oGetDB:lModified,,aTotRdpe,nTotInf,,,@aValDif) .And.;
											       Ctb101Doc(dDataLanc,cLote,cSubLote,@cDoc,oDoc,CTF_LOCK,nOpc) .And.;
 											       Ct102GrCTF(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK),oDlg:End(),nOpcA := 0)}, {||IIf(lBlqMoeda,(lExit := .T.,oDlg:End()),If(AllTrim(ProcName(1)) <> "CTBA102",MsgAlert(STR0057,STR0011),oDlg:End()))},,aButton))//"Atencao"##"Para encerrar essa opcao e necessario confirmar ou excluir a(s) linha(s) de lancamento(s) contabil!"

			If lExit
				Exit
			EndIf

		EndDo

		IF nOpcA == 1

			//Ponto de entrada criado com a funcao de alterar a filial para gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lAntCtbGrv
				ExecBlock("ANTCTBGRV",.F.,.F.,{ nOpcx,dDataLanc,cLote,cSubLote,cDoc} )
			Endif

			//Validacao
			//nQtdCntb - Variavel usada para identificar qntd de linhas de lançamentos para metricas
			lRpcOk	:= CTB105Rpc(lDigita, @nQtdCntb)

			If !lRpcOk .Or. __PreLan == .T.
				cPreLcto	:= "S"
			Else
				cPreLcto	:= "N"
			EndIf

			If __lConOutR
				ConOutR("*PROCES*|INICIO CTBGRAVA4")
			EndIf

			CtbChkDif(aValDif,@aCTKxCT2, cTabCTK)
			
			CTBGrava(3,dDatalanc,cLote,cSubLote,cDoc,lAglut,cSeqChave,__lCusto,__lItem,__lCLVL,nTotInf,cProgName,;
					cPreLcto,dReproc,cEmpOri,cFilOri,@aFlagCTB,@aCTKxCT2,@aTpSaldo,,aSeqDiario,,cSeqCorr,,,,;
					cHistCapLt,,,,,,,,,,,,cIdProcess)

			//- indica a existência de registros a atualizar e reforça a 
			//- sincronização do JSON
			IIf ( Len(aFlagCTB) > 0 , ( ChgFlag105(,.F.) , ChgFlag105(aFlagCTB,.T.) ) , .T.) 

			If __lConOutR
				ConOutR("*PROCES*|FIM CTBGRAVA4")
			EndIf
			// Qdo o usuario solicita que nao mostre a tela de lancto, a tela sera exibida somente qdo houver alguma nao conformidade no doc.
			// Se os documentos seguintes estiverem corretos a tela não será exibida.
			lDigita := IIf( lDigitaOri, .T.,.F.)
			//Ponto de entrada criado com a funcao de voltar a filial apos a gravacao dos saldos e lancamentos contabeis.
			//Como exemplo, podera ser utilizado com as tabelas do financeiro compartilhadas e as tabelas do CTB exclusivas.
			//O financeiro sera consolidado e a contabilidade  nao. Na contabilidade sera executada a rotina de Consolidacao
			//posteriormente.
			If lDepCtbGrv
				ExecBlock("DEPCTBGRV",.F.,.F., { nOpcx,dDataLanc,cLote,cSubLote,cDoc } )
			Endif

			If !lEndCTK			///Se não terminou a leitura de CTK carrega TMP novo
			
				CtbZap_Tmp( "TMP" )   //selecionar alias TMP e dar ZAP para limpar o arquivo para proximo documento

			EndIf
		Endif
	EndIf
EndDo

If CTF_LOCK > 0					/// LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL
	dbSelectArea("CTF")
	dbGoTo(CTF_LOCK)
	CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK,lSimula,cTabCTK,cTabCT2)
Endif

If Select(cAliasCTK) > 0 //.And. ! ( "INFORMIX" $ Alltrim(Upper(TCGetDB())) )
	(cAliasCTK)->(DbCloseArea())
Endif
//- efetua a liberação do objeto em uso 
ChgFlag105(,.F.)

//_ZAP_ na tabela temporaria para deixar limpo para proximo documento ou chamada da ca100Incl
CtbZap_Tmp( "TMP")

DbSelectArea( "CT2" )

//
// Restaurando ou Desabilitando as teclas de função utilizadas nesta função, que foram F4, F5, F6 e F7
//
If bVK_4 == NIL
	Set Key VK_F4 to
Else
	SetKey(VK_F4,bVK_4)
EndIf
If bVK_5 == NIL
	Set Key VK_F5 to
Else
	SetKey(VK_F5,bVK_5)
EndIf
If bVK_6 == NIL
	Set Key VK_F6 to
Else
	SetKey(VK_F6,bVK_6)
EndIf
If bVK_7 == NIL
	Set Key VK_F7 to
Else
	SetKey(VK_F7,bVK_7)
EndIf

If dReproc <> Nil .AND. SuperGetMv( "MV_ATUSAL" )== "S"
	If aTpSaldo == Nil .Or. Len( aTpSaldo ) == 0
		aTpSaldo := {"1"}	//	Reprocessar ao menos o tipo de saldo 1-Real
	EndIf

	If lSimula
		dbSelectArea("SIX")
		dbSetOrder(1)		//INDICE+ORDEM
		dbGoTop()
		If SIX->(dbSeek("CT21"))
			cChaveCT2 := AllTrim(SIX->CHAVE)
			IndRegua("CT2", cTabCT2, cChaveCT2, , , )
		EndIf
		dbSelectArea("CT2")
	Else
		CT2->(DbSetOrder(1))
	EndIf

	CT2->(DbSeek(Soma1(xFilial()), .T.))	// Procuro a proxima filial
	CT2->(DbSkip(-1))						// Volto para o registro anterior
	dCt2Data := CT2->CT2_DATA

	If !lSimula
		For nTipoSaldo := 1 to Len( aTpSaldo )
			If CT2->CT2_FILIAL = xFilial("CT2") .And. dCt2Data > dReproc
				CTBA190(.T.,dReproc,dCt2Data,cFilAnt,cFilAnt,aTpSaldo[nTipoSaldo],.F.,"  ")
			Else
				CTBA190(.T.,dReproc,dReproc,cFilAnt,cFilAnt,aTpSaldo[nTipoSaldo],.F.,"  ")
			Endif
		Next
	EndIf
Endif

//restaurar alias TMP para variavel _cAliasTmp para quando voltar para o alias chamado antes da ca100Incl e tb usado na Ctb105Cria()
//nao retirar desta posicao, pois tem que anteceder a restauracao do TMP anterior a chamada da ca100Incl
CtbRst_Tmp()

//colocado este trecho para restaurar TMP carregado antes de chamar ca100Incl
//nao retirar desta posicao antes do RestArea da função Ctb_Incl
CTBRstTmpE()

RestArea(aSaveArea)

PutHFile("")

If __lConOutR
	ConOutR("*LOGFIM*|FIM CTBA105",.T.)
EndIf

// efetua a limpeza dos caches da rotina
If __ClearCx
	ClearCx105()
Endif


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Lancamento de complementar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If CTBLCUso()
	If (Type("__aCT2LC") == "A") .And. !Empty(__aCT2LC)
		CTBLCGerLC()
	Endif
Endif

Return .T.

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}CTBSavTmp()
Salvar o alias TMP externo a ca100Incl que porventura estiver aberto
Utiliza variavel static _cAliasOld
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Static Function CtbSavTmpE()

//Tratamento para mudar o alias TMP que porventura estiver aberto - nao mudar esta posicao do fonte - tem que ser a primeira a executar
//carrega variavel static _cAliasOld que tera o alias TMP mudado para esta variavel
If _cAliasOld == NIL
	If !_cAliasTmp == nil 
		_cAliasOld := _cAliasTmp
	Else 
		_cAliasOld := GetNextAlias()
	EndIf 
EndIf

//se alias TMP estiver aberto - muda ele para variavel static _cAliasOld
If  Select("TMP") > 0 
	DbChangeAlias( "TMP", _cAliasOld )
EndIf

Return

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}CtbRstTmpE()
Restaurar o alias TMP externo a ca100Incl que porventura estiver aberto
Utiliza variavel static _cAliasOld
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Static Function CtbRstTmpE()

//colocado este trecho para restaurar TMP carregado antes de chamar ca100Incl
If  Select(_cAliasOld) > 0 
	DbChangeAlias( _cAliasOld, "TMP" )
EndIf

Return

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}CtbChg_Tmp()
Mudar o alias criado na funcao Ctb105Cria - para TMP 
Utiliza variavel static _cAliasTmp alimentada na Ctb105Cria
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Static Function CtbChg_Tmp()

//-->Aqui colocar tratamento para mudar o alias para TMP da tabela criada com FWTemporaryTable<-------
If _cAliasTmp <> NIL
	If  Select(_cAliasTmp) > 0 .and. Select('TMP') == 0
		If !DbChangeAlias( _cAliasTmp, "TMP" )
			ConOutR('CtbChg_Tmp ->>'+_cAliasTmp)
		EndIF 
	EndIf
EndIf

Return

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}CtbRst_Tmp()
Restaura o alias TMP para o _cTmpAlias criado na funcao Ctb105Cria
Utiliza variavel static _cAliasTmp alimentada na Ctb105Cria
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Static Function CtbRst_Tmp()

If  Select( "TMP" ) > 0 .and. _cAliasTmp != nil
	If !DbChangeAlias( "TMP", _cAliasTmp )
		ConOutR('CtbRst_Tmp ->>'+_cAliasTmp)
	EndIf 
EndIf

Return


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}CtbZap_Tmp()
Apaga todos os registros da tabela temporaria com _Zap_
Caso ca100Incl esteja em transacao temos que utilizar _Truncate_Table para bancos SQLServer e Oracle 
Para os demais vamos usar _DbDelete_ na tabela temporaria
Esta tabela somente atualmente recebe no maximo em torno de 35000 registros-retorno da funcao CtbLinMax
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Static Function CtbZap_Tmp( cTmpAlias )
	//- O uso do delete se dá pelo fato de que o truncate possui 
	//- um commit implicito e isso faz com que o rollback não 
	//- funcione corretamente, portanto não se deve usar Truncate
    TcSqlExec(" DELETE FROM "+ __cGetRealname )  //_Zap_

	If Select(cTmpAlias) > 0
		(cTmpAlias)->(dbGoto(99999999))
		(cTmpAlias)->(dbGotop())
		
		If (cTmpAlias)->(!Eof())
			(cTmpAlias)->(dbappend())
			(cTmpAlias)->(dbcommit())
			(cTmpAlias)->(dbGotop())
		
			While (cTmpAlias)->(!Eof())
				(cTmpAlias)->(dbDelete())
				(cTmpAlias)->(dbSkip())
			Enddo 
		
			(cTmpAlias)->(dbGotop())
		EndIf 
	EndIf
    
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105Head³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aHeader para MsGetDB                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb105Head(aAltera)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpA1 = Matriz com campos da MSGETDB                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expa1 = Array de alteracao                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb105Head(aAltera,lSimula, lForceHead)

Local aSaveArea:= GetArea()
Local aFora		:= {"CT2_CALEND","CT2_DATA","CT2_LOTE", "CT2_SBLOTE", "CT2_DOC", "CT2_MOEDLC"}
Local aCampos	:= {}
Local lMVRedSt  := SuperGetMv("MV_REDSTORN",.F.,.F.)
Local lCT2MSUIDT	:= CT2->(FieldPos("CT2_MSUIDT") > 0 )

If Type("nUsado") == "U"
	PRIVATE nUsado := 0
EndIf

Default lSimula    := .F.
Default lForceHead := .F.

If lForceHead   //variaveis static __aCampos / __aAltera devem ser inicializadas e carregadas em conjunto
	__aCampos	:= Nil	
	__aAltera	:= Nil
	__nUsado	:= Nil
	__aHeadCtb	:= Nil
EndIf

If __aCampos == Nil .And. __aAltera == Nil  //as 2 variaveis static - tem que andar em conjunto

	nUsado := 0
	lAglByHist := RetAlgHist()

	AADD(aFora,"CT2_DTLP")

	// Na rotina de Lançamento Contábil Parametrizado (CTBA103) o tipo de saldo é
	If IsInCallStack("CTBA103")
		AADD(aFora,"CT2_TPSALD")
	EndIf

	// Montagem da matriz aHeader
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek("CT2")
	While !EOF() .And. (x3_arquivo == "CT2")
		
		If lCT2MSUIDT .And. X3_CAMPO == "CT2_MSUIDT"
			dbSkip()
		EndIf
		If ( Alltrim(x3_campo) == "CT2_LINHA" .Or. X3USO( X3_USADO ) .Or. (Type("lCt102Auto") <> "U" .And. lCt102Auto .And. Alltrim(x3_campo) == "CT2_MANUAL")) .and. cNivel >= x3_nivel
			If Ascan(aFora,Trim(X3_CAMPO)) <= 0
				nUsado++
				AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, "TMP", x3_context } )
				If Alltrim(x3_campo) <> "CT2_LINHA"
					If lIsRussia .And. lMVRedSt
						If Alltrim(x3_campo) <> "CT2_EC05DB" .And. Alltrim(x3_campo) <> "CT2_EC05CR"
							Aadd(aAltera,Trim(X3_CAMPO))
						Endif
					Else
						Aadd(aAltera,Trim(X3_CAMPO))
					Endif
				EndIf
			EndIF
		EndIF
		aAdd( aCampos, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
		dbSkip()
	EndDO

	If ( __cSGBD == "AS/400" .OR. "INFORMIX" $ __cSGBD ) .and. lAglByHist
		dbSetOrder(2)
		If MsSeek("CT2_HIST")
			aAdd(aCampos,{"CT2_TMPHIS", SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL } )
		Else
			aAdd(aCampos,{"CT2_TMPHIS", "C", 40,0 } )
		Endif
		dbSetOrder(1)
	Endif

	//bloco para validacao do temporario quando criado diretamente no banco de dados
	If CtbProcedBD()
		aadd(aCampos,{"CT2_VLD01","C",2,0})
		aadd(aCampos,{"CT2_VLD02","C",2,0})
		aadd(aCampos,{"CT2_VLD03","C",2,0})
		aadd(aCampos,{"CT2_VLD04","C",2,0})
		aadd(aCampos,{"CT2_VLD05","C",2,0})
		aadd(aCampos,{"CT2_VLD06","C",2,0})
		aadd(aCampos,{"CT2_VLD07","C",2,0})
		aadd(aCampos,{"CT2_VLD08","C",2,0})
		aadd(aCampos,{"CT2_VLD09","C",2,0})
		aadd(aCampos,{"CT2_VLD10","C",2,0})
		aadd(aCampos,{"CT2_VLD11","C",2,0})
		aadd(aCampos,{"CT2_VLD12","C",2,0})
		aadd(aCampos,{"CT2_VLD13","C",2,0})
		aadd(aCampos,{"CT2_VLD14","C",2,0})
		aadd(aCampos,{"CT2_VLD15","C",2,0})
		aadd(aCampos,{"CT2_VLD16","C",2,0})
		aadd(aCampos,{"CT2_VLD17","C",2,0})
		aadd(aCampos,{"CT2_VLD18","C",2,0})
		aadd(aCampos,{"CT2_VLD19","C",2,0})
		aadd(aCampos,{"CT2_VLD20","C",2,0})
		aadd(aCampos,{"CT2_VLD21","C",2,0})
		aadd(aCampos,{"CT2_VLD22","C",2,0})
		aadd(aCampos,{"CT2_VLD23","C",2,0})
		aadd(aCampos,{"CT2_VLD24","C",2,0})
		aadd(aCampos,{"CT2_VLD25","C",2,0})
		aAdd(aCampos,{"CT2_RECCTK", "N" , 12 ,0 } ) 
	EndIf
		//Bloco necessario para consulta Walk-Thru
		Ctb102HeaderWT("CT2", aHeader)
		aadd(aCampos,{"CT2_REC_WT","N",12,0}) 
		aadd(aCampos,{"CT2_ALI_WT","C",3,0})

		Aadd(aCampos,{"CT2_RECNO","N",12,0}) 
		Aadd(aCampos,{"MODIFIED","N",1,0})
		Aadd(aCampos,{"ATUSALDO","N",1,0})
		Aadd(aCampos,{"CT2_FLAG","L",1,0})

	If lCampoESP .And. !lSimula
		ExecBlock("C105CESP",.F.,.F.,{})
	Endif

	__aCampos	:= aClone( aCampos )	
	__aAltera	:= aClone( aAltera )
	__aHeadCtb	:= aClone( aHeader)
	__nUsado	:= nUsado

Else

	//carrega as variaveis locais com conteudo das variaveis static
	aCampos := aClone( __aCampos )  //esta variavel eh retorno da funcao
	aAltera := aClone( __aAltera )  //esta variavel normalmente vem por referencia entao deve ser carregada
	aHeader := aClone( __aHeadCtb ) //variavel aHeader é utilizada internamente na MSGETDB
	nUsado  := __nUsado

EndIf

RestArea(aSaveArea)

Return aCampos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105Cria³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria arquivo temporario e indices para MSGETDB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintxe    ³ Ctb105Cria(aCampos,cArq1,cArq2)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Matriz com campos da MSGETDB                       ³±±
±±³          ³ ExpC1 = Arquivo 1                                          ³±±
±±³          ³ ExpC2 = Arquivo 2                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb105Cria(aCampos,lForceCrTmp)

Local aSaveArea		:= GetArea()
Local aChave

Default lForceCrTmp := .F.

If _cAliasTmp == NIL
	_cAliasTmp := CriaTrab(,.F.)
EndIf

If lForceCrTmp
	If _cAliasTmp <> NIL .And. Select(_cAliasTmp) > 0
		dbSelectArea( _cAliasTmp )
		(_cAliasTmp)->( dbCloseArea() )
	EndIf
	//Deleta tabela temporaria no banco, caso ja exita
	If _oCTBA105 <> Nil
		_oCTBA105:Delete()
		FreeObj(_oCTBA105)
		_oCTBA105 := Nil
		__cGetRealname := ""
	Endif
Else
	//Limpa dados da tabela para utilizar a mesma estrutura
	//melhora de performance feita para Rodonaves DSERCTR1-29237
	If _oCTBA105 <> Nil
		//- verifica se existe o alias tmp aberto e retorna a execução 
		//- do alias da temporária referente ao objeto 
		If Select('TMP') > 0 
			CtbRst_Tmp()
		EndIf 
		
		CtbZap_Tmp( _cAliasTmp )   //selecionar alias TMP e dar ZAP para limpar o arquivo para proximo documento

	Endif
Endif
//---------------------------------------------------------------------------
//Cria tabela temporaria no banco de dados atraves da classe FwTemporaryTable
//---------------------------------------------------------------------------
If _oCTBA105 == Nil .Or. Empty(__cGetRealname) .Or. (  _cAliasTmp <> NIL .And. Select( _cAliasTmp ) == 0 )

	lAglByHist := RetAlgHist()

	aChave := {"CT2_DC","CT2_DEBITO","CT2_CREDIT","CT2_CCD","CT2_CCC","CT2_ITEMD","CT2_ITEMC","CT2_CLVLDB","CT2_CLVLCR","CT2_TPSALD"}

	If ( __cSGBD == "AS/400"  .OR. "INFORMIX" $ __cSGBD )  .and. lAglByHist
		Aadd( aChave, "CT2_TMPHIS" )
	Endif
    //Criacao da tabela na area temporaria do banco de dados com a classe fwtemporarytable	
	_oCTBA105 := FWTemporaryTable():New( _cAliasTmp )		
	_oCTBA105:SetFields(aCampos)
	_oCTBA105:AddIndex("1", aChave )
	_oCTBA105:AddIndex("2", {"CT2_LINHA"})
	_oCTBA105:AddIndex("3", {"CT2_FLAG","CT2_DC"})
	_oCTBA105:AddIndex("4", {"CT2_DC",'CT2_DEBITO'})
	_oCTBA105:AddIndex("5", {"CT2_DC","CT2_CREDIT"})
	_oCTBA105:Create()

	dbSetOrder(1) 

EndIf

__cArq1 		:= _oCTBA105:GETREALNAME()
__cArq2 		:= _oCTBA105:GETREALNAME()
__cGetRealname 	:= _oCTBA105:GETREALNAME()

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105GRV ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arq. temporario com dados para MSGETDB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB105GRV( cSeqChave, lAglut, aCampos, dDataLanc, cSubLote )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Contador / Flag do lancamento                      ³±±
±±³          ³ ExpL1 = Aglutina lancamento?                               ³±±
±±³          ³ ExpA1 = Matriz com campos do arquivo temporario            ³±±
±±³          ³ ExpD1 = Data do lancamento                                 ³±±
±±³          ³ ExpC2 = SubLote                                            ³±±
±±³          ³ ExpN1 = Linha atual sendo processada                       ³±±
±±³          ³ ExpN2 = Recno atual                                        ³±±
±±³          ³ ExpC3 = Alias sendo processado [VIA TOP UTILIZA QUERY]     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105GRV( cSeqChave, lAglut, aCampos, dDataLanc, cSubLote,nLin, nRecCtk, cAliasCTK, aFlagCTB,	aCTKxCT2 ,;
					lEndCTK, lSeqCorr, cSeqCorr, aSeqDiario, lDCDUso, lSimula, cTabCTK, cTabCT2, cHistCapLt)

Local aSaveArea		:= GetArea()
Local cMoeda		:= ""
Local lSomaLinha	:= .t.
Local lZero			:= .T.
Local nLinha		:= 0
Local nVal	 		:= 0
Local nCont			:= 0
Local nCont1		:= 0
Local cSeqLan 		:= StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001"
Local nSeqHis 		:= 0
Local lRet			:= .F.
Local cLinha		:= Replicate( "9", Len(CT2->CT2_LINHA) )  // "999"
Local aPeriodos		:= {}
Local nOrdCTK 		:= 1
Local cCampoCtk	:= ""
Local nZ
Local cTpSald		:= ""
Local cCt2Conv		:= ""
Local cSrvType		:= TcSrvType()
Local nPosAFlag		:= 0
Local aCTKs			:= {}
Local cTmpValr    	:= ""
Local cCtkValr		:= ""
Local nPosPer		:=	0
Local nValCTKTMP	:= 0
Local dDataTxMI		:= CTOD("  /  /  ")
Local lMTA330		:= FunName() $ "MATA330|MATA331|MATA333|MATA038"
Local cAlsHst		:= ""
Local cQryHst		:= ""
Local oQryHst		:= Nil

// ****************************
// Controle do Correlativo   *
// ****************************

Local cCodSeq		:= ""
Local lDiaCtb		:= .F.

Local lCache        := CtbCache(9)

// ****************************
// Controle do Hash Map       *
// ****************************
Local lFound
Local cBusca
Local nConta, xValue
Local aHash
Local oHash

Local cQueryCtk		:= ''
Local cLancPadr     := ""
Local aParQry       := {}
Local  lTaAglut     := .F.    //  Trata aglutinamento por historico

Static lOrdEnt		:= If(GetNewPar("MV_ORDLCTB","L")=="E",.T.,.F.)			/// MV_ORDLCTB : L= LP (sequen+lp)/ E = Entrada (Recno)
Static lOrdTpSld	:= If(GetNewPar("MV_ORDLCTB","L")=="T",.T.,.F.)			/// MV_ORDLCTB : T= Tipo de Saldo
Static lOrdLp       := If(GetNewPar("MV_ORDLCTB","L")=="L",.T.,.F.)			/// MV_ORDLCTB : L= Lanc.Padrao

DEFAULT aCTKxCT2	:= {}
DEFAULT lEndCTK		:= .F.
DEFAULT lSeqCorr 	:= UsaSeqCor("CT2/CTK/CT5")
DEFAULT cSeqCorr 	:= CriaVar("CT2_NODIA")
DEFAULT aSeqDiario 	:= {}

Default lDCDUso 	:= __lDCDUso    //  Digito de Controle

Default lSimula	:= .F.
Default cTabCTK	:= "CTK"
Default cTabCT2	:= "CT2"

If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

lAglByHist := RetAlgHist()

//array que contera se o campo "CT2_DTTX" estara em uso para a Moeda
If __alDtTaxa == NIL .Or. Len(__alDtTaxa) != __nQuantas
	__alDtTaxa 	:= Array(__nQuantas)
	__alDtTaxa[1] := .T.
	For  nCont := 2	To __nQuantas
		cMoeda := StrZero(nCont,2)
		__alDtTaxa[nCont] := CtbUso("CT2_DTTX"+cMoeda)
	Next
EndIf
DbSelectArea( cAliasCTK )

If nRecCTK > 0
	If "INFORMIX" $ __cSGBD
		dbGoto(nRecCTK)
		nRecCTK := 0
	Endif
Endif

nOrdCTK := IndexOrd()

If ( "INFORMIX" $ __cSGBD ) .and. lOrdEnt
	dbSetOrder(0)
Endif

cTpSldAtu 	:= (cAliasCTK)->CTK_TPSALD
cLancPadr   := (cAliasCTK)->CTK_LP
lDiaCtb		:= UsaSeqCor("CT2/CTK/CT5")

If __lConOutR
	ConOutR("*PROCES*|INICIO CARGA CTK->TMP->CT2")
EndIf

cSeqCrAnt := IIf(Type("cSeqOficNFE")="C",cSeqOficNFE,IIf(valType(cSeqCorr)="C",cSeqCorr,Space(10)))


If lAglut

	//tratamento para quando aglutinado
	While (cAliasCTK)->(!Eof()) .and. (cAliasCTK)->CTK_SEQUEN == cSeqChave .And. nLinha < MAX_LINHA[1]

		If lOrdTpSld			/// QUANDO ORDEM POR TIPO DE SALDO - QUEBRA DOCUMENTO POR TIPO DE SALDO
			If (cAliasCTK)->CTK_TPSALD <> cTpSldAtu
				nLin := MAX_LINHA[1]+1		/// SETA LINHA PARA QUEBRAR DOCUMENTO POR TIPO DE SALDO
				Exit
			EndIf
		ElseIf lOrdLp .AND. lVazioSubL .AND. lQuebraLP
			If (cAliasCTK)->CTK_LP <> cLancPadr
				nLin := MAX_LINHA[1]+1		/// SETA LINHA PARA QUEBRAR DOCUMENTO POR TIPO DE SALDO
				Exit
			EndIf
		EndIf

		If lDiaCtb
			If ( !Empty( (cAliasCTK)->CTK_DIACTB ) ) // A precedencia é o que está no LP
				cCodSeq := (cAliasCTK)->CTK_DIACTB
			ElseIf Len(aSeqDiario) >= 1 .And. ( !Empty(aSeqDiario[1][3])  .And. aSeqDiario[1][3] != "99" )
				cCodSeq := aSeqDiario[1][3]
			ElseIf Len(aSeqDiario) >= 1
				cCodSeq := CtbrDia( (cAliasCTK)->CTK_LP )
			EndIf
		Endif

		// Verifica se existe algum valor <> de 0
		If (cAliasCTK)->CTK_DC != "4"
			lZero := .F.
			For nCont1 := 1 To __nQuantas
				lZero := .T.
				If !(cAliasCTK)->(Ctb105Get("CTK_VLR"+StrZero(nCont1,2))) == 0 
					lZero := .F.
					Exit
				EndIf
			Next nCont1
		EndIf

		If !lZero
			DbSelectArea( "TMP" )
			DbSetOrder(1)

			If ! ( "INFORMIX" $ __cSGBD )
				lSomaLinha	:= .T.
				CtdbAppend()
				nVal := 0
			Else
				If AMVS[3] == "S"
					cTpSald	:= "9"
				Else
					cTpSald	:= (cAliasCTK)->CTK_TPSALD
				EndIf

				cSeekTMP := (cAliasCTK)->(CTK_DC+CTK_DEBITO+CTK_CREDIT+CTK_CCD+CTK_CCC+CTK_ITEMD+CTK_ITEMC+;
						CTK_CLVLDB+CTK_CLVLCR+cTpSald)

				If lAglByHist
					If lCTKHAGLUT
						cSeekTMP += (cAliasCTK)->CTK_HIST /// Campo CTK_HAGLUT recebe CTK_HIST como apelido
					EndIf
				Endif
				If MsSeek(cSeekTMP)
						If TMP->CT2_DC = "4"
							nVal := 0
							CtdbAppend()
							lSomaLinha := .T.
						Else
							lSomaLinha := .F.
						EndIf
				Else
					nVal := 0
					CtdbAppend()
					lSomaLinha := .T.
				EndIf
			Endif

			If CtbProcedBD()
				TMP->CT2_RECCTK := (cAliasCTK)->RECNO
			EndIf

			cKeyCT5 := FWxFilial("CT5") + (cAliasCTK)->CTKLPLPSEQ					//// USA A QUERY (MAIOR LP E SEQUENCIA)

			CT5->(MsSeek(cKeyCT5))

			//Obtém o Historico do documento contábil da primeira sequencia
			If cPaisLoc $ "ARG/EQU" .And. Empty(cHistCapLt)
				cHistCapLt := CT5->CT5_DOCHIS
			EndIf

			If Empty(TMP->CT2_MOEDAS)
				TMP->CT2_MOEDAS := CT5->CT5_MOEDAS
				If CTBLCUso()
					If AllTrim((cAliasCTK)->CTK_ROTINA) == '__CTBLC__'
						cMoedCtk := ""
						For nCont1 := 1 To __nQuantas
							If !(cAliasCTK)->(Ctb105Get("CTK_VLR"+StrZero(nCont1,2))) == 0 
								cMoedCTK += "1"
							Else
								cMoedCTK += "2"
							EndIf
						Next nCont1
						TMP->CT2_MOEDAS := cMoedCTK
					Endif
				Endif
			Endif

			For nCont := 1 To Len(aCampos)
				cCampoCTK := "CTK_" + Substr(aCampos[nCont][1],5,Len(aCampos[nCont][1]))
				nPos := FieldPos(aCampos[nCont][1])

				If AllTrim(aCampos[nCont][1]) == "CT2_VALOR" // contabilização na moeda 01

					If !aMVS[MV_ALTLCTO]		// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ SE INCONSISTENTE)
							TMP->CT2_VALOR += (cAliasCTK)->CTK_VLR01
					ElseIf Left(TMP->CT2_MOEDAS,1) == "1"
							TMP->CT2_VALOR += (cAliasCTK)->CTK_VLR01
					EndIf

				ElseIf Subs(aCampos[nCont][1],1,8) == "CT2_VALR" // contabilização das outras moedas

					//Verifica se existe calendario para a moeda na data do lancamento
					If lCache
						If (nPosPer := Ascan(aPerCache,{|x| x[1] == Subs(aCampos[nCont][1],9,2)})) == 0
							aPeriodos	:= CtbPeriodos(Subs(aCampos[nCont][1],9,2),dDataLanc,dDataLanc,.F.,.F.)
							aadd(aPerCache,{Subs(aCampos[nCont][1],9,2),aClone(aPeriodos)})
						Else
							aPeriodos	:=	aClone(aPerCache[nPosPer,2])
						Endif
					Else
						aPeriodos	:= CtbPeriodos(Subs(aCampos[nCont][1],9,2),dDataLanc,dDataLanc,.F.,.F.)
					EndIf

					// BOPS 131255 - RFC
					// tratamento dos campos do valor
					cTmpValr := "CT2_VALR" + Subs( aCampos[ nCont ][1] ,9 ,2 )
					cCtkValr := "CTK_VLR"  + Subs( aCampos[ nCont ][1] ,9 ,2 )

					// verifica se o campo existe antes de continuar a operacao
					// em agluns casos o campo existe no temporario mais não existe na query
					If ( TMP->( FieldPos( cTmpValr ) ) <= 0 .Or. ( cAliasCTK )->( FieldPos( cCtkValr ) ) <= 0 )
						Loop
					Endif

					// passo o valor da contabilização para uma variavel
					// afim de evitar sugeiras ou valores estranhos na contabilização
					nValCTKTMP := (cAliasCTK)->(Ctb105Get(cCtkValr))

					If ! aMVS[MV_ALTLCTO]		// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ SE INCONSISTENTE)
						TMP->(&cTmpValr) += nValCTKTMP

					ElseIf ! Empty(aPeriodos[1][1]) .and. SubStr(TMP->CT2_MOEDAS,Val(Subs(aCampos[nCont][1],9,2)),1) == "1"

						If aPeriodos[1][4] $ "1"	//Se o calendario estiver aberto
							TMP->(&cTmpValr) += nValCTKTMP
						Else
							Loop
						EndIf
					EndIf

					nValCTKTMP := 0

				ElseIf Subs( aCampos[ nCont ][1], 1, 9 ) == "CT2_DTCV3" // atualização da data do CV3
					TMP->CT2_DTCV3 := (cAliasCTK)->CTK_DATA

				ElseIf Tmp->(FieldPos(aCampos[nCont][1])) > 0 .And. (cAliasCTK)->(FieldPos(cCampoCTK)) > 0
					FieldPut(nPos,(cAliasCTK)->(Ctb105Get(cCampoCTK)))
				EndIf

			Next nCont
			If lSomaLinha
				If nLinha >  Val( Replicate( "9", Len(CT2->CT2_LINHA) ) ) - 1 // 998
					cLinha := Soma1(cLinha)
					nLinha++
					TMP->CT2_LINHA 	:= cLinha
				Else
					nLinha++
					TMP->CT2_LINHA 	:= StrZero(nLinha,Len(CT2->CT2_LINHA))  //3
				Endif
			EndIf

			If (cAliasCTK)->CONTAAGLUT > 1
				aAreaFlag := GetArea()

				cQueryCtk := Iif(lSimula, (cTabCTK), RetSqlName( "CTK" ))
					
				//cQryFlag := " SELECT R_E_C_N_O_ FROM ? " // P1 RetSqlName
				cQryFlag := " SELECT R_E_C_N_O_ FROM "+ cQueryCtk // P1 RetSqlName
				cQryFlag += " WHERE CTK_FILIAL = ? "	 // P2 Filial
				cQryFlag += " AND CTK_SEQUEN = ? "		 // P3 Chave Sequencial       
				cQryFlag += " AND CTK_DC = ? "			 // P4 Tipo do Lancamento     
				cQryFlag += " AND CTK_DEBITO = ? "		 // P5 Conta Debito           
				cQryFlag += " AND CTK_CREDIT = ? "		 // P6 Conta Credito          
				cQryFlag += " AND CTK_CCD = ? "			 // P7 Centro de Custo Debito 
				cQryFlag += " AND CTK_CCC = ? "			 // P8 Centro de Custo Credito
				cQryFlag += " AND CTK_ITEMD = ? "		 // P9 Item Debito            
				cQryFlag += " AND CTK_ITEMC = ? "		 // P10 Item Credito          
				cQryFlag += " AND CTK_CLVLDB = ? "		 // P11 Classe Valor Debito   
				cQryFlag += " AND CTK_CLVLCR = ? "		 // P12 Classe Valor Credito  
				cQryFlag += " AND CTK_TPSALD = ? "		 // P13 Tipo do Saldo         
				cQryFlag += " AND CTK_LP = ? "			 // P14 Lancto Padrao Gerador 
				If lAglByHist
					If lCTKHAGLUT															
						cQryFlag += " AND CTK_HAGLUT = ? " 	// P15 Historico Lancamento  //TOPCONN CTK_HAGLUT ALIAS = CTK_HIST - 
					Else
						cQryFlag += " AND CTK_HIST = ? " 	// P15 Historico Lancamento  				
					EndIf
				EndIf
				cQryFlag += " AND CTK_AT01DB = ? "       // P16 Ativ.01 DB  
				cQryFlag += " AND CTK_AT02DB = ? "       // P17 Ativ.02 DB  
				cQryFlag += " AND CTK_AT03DB = ? "       // P18 Ativ.03 DB
				cQryFlag += " AND CTK_AT04DB = ? "       // P19 Ativ.04 DB
				cQryFlag += " AND CTK_AT01CR = ? "       // P20 Ativ.01 CR
				cQryFlag += " AND CTK_AT02CR = ? "       // P21 Ativ.02 CR
				cQryFlag += " AND CTK_AT03CR = ? "       // P22 Ativ.03 CR
				cQryFlag += " AND CTK_AT04CR = ? "       // P23 Ativ.04 CR

				cQryFlag += " AND D_E_L_E_T_ = ? "       // P24 D_E_L_E_T_

				If __LoadCTKGRVG == Nil
					__cQueryGrv := cQryFlag
					cQryFlag := ChangeQuery(cQryFlag)
					__LoadCTKGRVG := FWPreparedStatement():New(cQryFlag)
				Else
					If __cQueryGrv <> cQryFlag
						__cQueryGrv := cQryFlag
						__LoadCTKGRVG:= Nil 
						FreeObj(__LoadCTKGRVG)
						cQryFlag := ChangeQuery(cQryFlag)
						__LoadCTKGRVG := FWPreparedStatement():New(cQryFlag)
					EndIF
				EndIf
	/*			__LoadCTKGRVG:SetNumeric(1,cQueryCtk) 				// P1 RetSqlname
				__LoadCTKGRVG:SetString(2,(cAliasCTK)->CTK_FILIAL ) // P2 Filial
				__LoadCTKGRVG:SetString(3,(cAliasCTK)->CTK_SEQUEN ) // P3 Chave Sequencial         
				__LoadCTKGRVG:SetString(4,(cAliasCTK)->CTK_DC ) 	// P4 Tipo do Lancamento       
				__LoadCTKGRVG:SetString(5,(cAliasCTK)->CTK_DEBITO ) // P5 Conta Debito             
				__LoadCTKGRVG:SetString(6,(cAliasCTK)->CTK_CREDIT ) // P6 Conta Credito            
				__LoadCTKGRVG:SetString(7,(cAliasCTK)->CTK_CCD) 	// P7 Centro de Custo Debito   
				__LoadCTKGRVG:SetString(8,(cAliasCTK)->CTK_CCC ) 	// P8 Centro de Custo Credito  
				__LoadCTKGRVG:SetString(9,(cAliasCTK)->CTK_ITEMD )  // P9 Item Debito              
				__LoadCTKGRVG:SetString(10,(cAliasCTK)->CTK_ITEMC ) // P10 Item Credito             
				__LoadCTKGRVG:SetString(11,(cAliasCTK)->CTK_CLVLDB )// P11 Classe Valor Debito      
				__LoadCTKGRVG:SetString(12,(cAliasCTK)->CTK_CLVLCR )// P12 Classe Valor Credito     
				__LoadCTKGRVG:SetString(13,(cAliasCTK)->CTK_TPSALD )// P13 Tipo do Saldo            
				__LoadCTKGRVG:SetString(14,(cAliasCTK)->CTK_LP ) 	// P14 Lancto Padrao Gerador    
				If lAglByHist
					__LoadCTKGRVG:SetString(15,(cAliasCTK)->CTK_HIST )  // P15 Historico Lancamento     
				EndiF*/
				aParQry := {}
	//			aadd(aParQry, cQueryCtk) 				// P1 RetSqlname
				aadd(aParQry, (cAliasCTK)->CTK_FILIAL ) // P2 Filial
				aadd(aParQry, (cAliasCTK)->CTK_SEQUEN ) // P3 Chave Sequencial         
				aadd(aParQry, (cAliasCTK)->CTK_DC ) 	// P4 Tipo do Lancamento       
				aadd(aParQry, (cAliasCTK)->CTK_DEBITO ) // P5 Conta Debito             
				aadd(aParQry, (cAliasCTK)->CTK_CREDIT ) // P6 Conta Credito            
				aadd(aParQry, (cAliasCTK)->CTK_CCD) 	// P7 Centro de Custo Debito   
				aadd(aParQry, (cAliasCTK)->CTK_CCC ) 	// P8 Centro de Custo Credito  
				aadd(aParQry, (cAliasCTK)->CTK_ITEMD )  // P9 Item Debito              
				aadd(aParQry, (cAliasCTK)->CTK_ITEMC ) // P10 Item Credito             
				aadd(aParQry, (cAliasCTK)->CTK_CLVLDB )// P11 Classe Valor Debito      
				aadd(aParQry, (cAliasCTK)->CTK_CLVLCR )// P12 Classe Valor Credito     
				aadd(aParQry, (cAliasCTK)->CTK_TPSALD )// P13 Tipo do Saldo            
				aadd(aParQry, (cAliasCTK)->CTK_LP ) 	// P14 Lancto Padrao Gerador    

				If lAglByHist
					aadd(aParQry, (cAliasCTK)->CTK_HIST )  // P15 Historico Lancamento     
				EndiF

				aadd(aParQry, (cAliasCTK)->CTK_AT01DB )  // P16 Ativ.01 DB 
				aadd(aParQry, (cAliasCTK)->CTK_AT02DB )  // P17 Ativ.02 DB
				aadd(aParQry, (cAliasCTK)->CTK_AT03DB )  // P18 Ativ.03 DB
				aadd(aParQry, (cAliasCTK)->CTK_AT04DB )  // P19 Ativ.04 DB
				aadd(aParQry, (cAliasCTK)->CTK_AT01CR )  // P20 Ativ.01 CR
				aadd(aParQry, (cAliasCTK)->CTK_AT02CR )  // P21 Ativ.02 CR
				aadd(aParQry, (cAliasCTK)->CTK_AT03CR )  // P22 Ativ.03 CR
				aadd(aParQry, (cAliasCTK)->CTK_AT04CR )  // P23 Ativ.04 CR
				
				aadd(aParQry, Space(1) )                 // P24 D_E_L_E_T_
				
				If Select("cQryFlag") > 0
					dbSelectArea("cQryFlag")
					cQryFlag->(dbCloseArea())
				EndIf

				//cQryFlag  := MPSYSOpenQuery(__LoadCTKGRVG:GetFixQuery(),"cQryFlag")
				//ConOut("Tempo GetFixQuery Ini =" + str(seconds()))
				//cQryFlag  := __LoadCTKGRVG:GetFixQuery()
				//ConOut("Tempo GetFixQuery Fim =" + str(seconds()))

				dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQryFlag, aParQry),"cQryFlag",.T.,.T.)
				TcSetField("cQryFlag","R_E_C_N_O_","N",17,0)
				asize(aParQry , 0)
				dbSelectArea("cQryFlag")

				nLenAFlag := Len(aFlagCTB)

				If nLenAFlag > 0					//// CASO SEJA FEITA CONTABILIZACAO COM CONTROLE DE TRANSACAO

					// Criacao de HashMap para otimizar a busca da posicao no aFlagCTB

					aHash 		:= {}

					For nConta := 1 To Len(aFlagCTB)
						Aadd(aHash,{aFlagCTB[nConta,6],nConta})
					Next nConta

					oHash := aToHM(aHash)
				EndIf
				///////////////////////////////////////////////////////////////////////////////////
				/// aCTKs - CONTROLE DE RASTREAMENTO DOS LANCAMENTOS (SEM CTL) -> UTILIZADO NA CTBGRAVA()
				aCTKs := {}
				While cQryFlag->(!Eof())
					aAdd( aCTKs, cQryFlag->R_E_C_N_O_ )

					If nLenAFlag > 0					//// CASO SEJA FEITA CONTABILIZACAO COM CONTROLE DE TRANSACAO
						cBusca := cQryFlag->R_E_C_N_O_
						lFound := HMGet( oHash , cBusca , @xValue )

						If lFound
							nPosAFlag := xValue[1,2]
						Else
							nPosAFlag := 0
						Endif

						If nPosAFlag > 0				/// SE TEM NO ARRAY DE FLAG DE CONTABILIZACAO REGISTRO CORRESPONDENTE
							nAFlag := nPosAFlag
							While nAFlag <= nLenAFlag .and. aFlagCTB[nAFlag][6] == cQryFlag->R_E_C_N_O_
								aFlagCTB[nAFlag][7] := TMP->(Recno())
								nAFlag++
							EndDo
						EndIf
					EndIf
					cQryFlag->(dbSkip())
				EndDo
				If nLenAFlag > 0					//// CASO SEJA FEITA CONTABILIZACAO COM CONTROLE DE TRANSACAO
					HMClean(oHash)	// Limpa o HashMap
				EndIf
				aAdd(aCTKxCT2,{TMP->(Recno()),aCTKs})
				cQryFlag->(dbCloseArea())
				RestArea(aAreaFlag)
			Else		/// CASO NAO SEJA CONTABILIZACAO AGLUTINADA - TOPCONN
				///////////////////////////////////////////////////////////////////////////////////
				/// CONTROLE DE RASTREAMENTO DOS LANCAMENTOS (SEM CTL) -> UTILIZADO NA CTBGRAVA()
				aAdd(aCTKxCT2,{TMP->(Recno()), { (cAliasCTK)->RECNO } })
				///////////////////////////////////////////////////////////////////////////////////

				If Len(aFlagCTB) > 0					//// CASO SEJA FEITA CONTABILIZACAO COM CONTROLE DE TRANSACAO
					If (nPosAFlag:= oFlag105[cValToChar((cAliasCTK)->RECNO)]) == nil 
						nPosAFlag := 0
					EndIf 
					If nPosAFlag > 0				/// SE TEM NO ARRAY DE FLAG DE CONTABILIZACAO REGISTRO CORRESPONDENTE
						nLenAFlag := Len(aFlagCTB)
						nAFlag := nPosAFlag	/// POSICAO INICIAL DO ARRAY CORRESPONDENTE AO LANCAMENTO
						While nAFlag <= nLenAFlag .and. aFlagCTB[nAFlag][6] == (cAliasCTK)->RECNO
							aFlagCTB[nAFlag][7] := TMP->(Recno())
							nAFlag++
						EndDo
					EndIf
				EndIf
			EndIf

			// Criterio de conversao
			If TMP->CT2_DC == "1" .Or. TMP->CT2_DC == "3"
				CarrCriter((cAliasCTK)->CTK_DEBITO,"1","TMP->CT2_CONVER",dDataLanc)
			EndIf
			If TMP->CT2_DC == "2" .Or. TMP->CT2_DC == "3"
				CarrCriter((cAliasCTK)->CTK_CREDIT,"2","TMP->CT2_CONVER",dDataLanc)
			EndIf

			// Valor nas outras moedas
			For  nCont := 2	To __nQuantas
				cMoeda := StrZero(nCont,2)

				// Verifica se moeda esta em uso ou se está bloqueada ou se data esta bloqueada para a moeda
				If (! CTBMInUse(cMoeda) )
					Loop
				EndIf

				If Substr(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. Substr(TMP->CT2_MOEDAS,nCont,1) == "3"
					cMoeda := StrZero(nCont,2)
					If lCache
						If (nPosPer := Ascan(aPerCache,{|x| x[1] == cMoeda})) == 0
							aPeriodos	:= CtbPeriodos(cMoeda,dDataLanc,dDataLanc,.F.,.F.)
							aadd(aPerCache,{cMoeda,aClone(aPeriodos)})
						Else
							aPeriodos	:=	aClone(aPerCache[nPosPer,2])
						Endif
					Else
						aPeriodos	:= CtbPeriodos(cMoeda,dDataLanc,dDataLanc,.F.,.F.)
					EndIf
					If !Empty(aPeriodos[1][1])
						// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ)
						// Se o calendario estiver aberto
						If !aMVS[MV_ALTLCTO] .or. aPeriodos[1][4] $ "1"
							// Converte valores
							If (cAliasCTK)->(Ctb105Get("CTK_VLR"+StrZero(nCont,2))) == 0 .and. Empty(&("CT5->CT5_VLR"+StrZero(nCont,2)))
								TMP->(CTB105Put("CT2_VALR"+StrZero(nCont,2),CtbConv(Substr(TMP->CT2_CONVER,nCont,1),dDataLanc,cMoeda,TMP->CT2_VALOR)))
							EndIf
						EndIf
					EndIf
				EndIf

				If __alDtTaxa[nCont] //CtbUso("CT2_DTTX"+cMoeda)
					If cPaisLoc == "PER" .And. FindFunction("DtMoeAstMI") .And. DtMoeAstMI(@dDataTxMI)
						TMP->(CTB105Put("CT2_DTTX"+cMoeda,dDataTxMI))
					Else
						TMP->(CTB105Put("CT2_DTTX"+cMoeda,dDataLanc))
					EndIf
				EndIf

			Next nCont

			//Atualizar o criterio de conversao apos prencher os valores em outras moedas.
			//Se o valor na moeda 01 estiver zerado, alterar o criterio de conversao para "5".
			//Nas outras moedas, o criterio de conversao devera ser alterado para "4".
			cCt2Conv := TMP->CT2_CONVER

			For nCont := 1 to __nQuantas
				If nCont == 1
					If TMP->CT2_VALOR == 0
						cCt2Conv := "5" + SubStr(cCt2Conv,2,__nQuantas)
					Else
						cCt2Conv := "1" + SubStr(cCt2Conv,2,__nQuantas)
					EndIf
				Else
					// tratativa para o carregamento dos valores
					If !Empty(&("CT5->CT5_VLR"+StrZero(nCont,2)))

						// criterio de conversão para as moedas
						IF ALLTRIM(SubStr(cCt2Conv,2,__nQuantas)) == "A" .AND. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3"
							TMP->(CTB105Put("CT2_VALR"+StrZero(nCont,2),&( &("CT5->CT5_VLR"+StrZero(nCont,2)))))
							cCt2Conv	:= Stuff(cCt2Conv,nCont,1,"A")

						// se o criterio de conversão for 5, zero o valor da moeda
						ELSEIF ALLTRIM(SubStr(cCt2Conv,nCont,1)) == "5"
							TMP->(CTB105Put("CT2_VALR"+StrZero(nCont,2),0))

						ELSE
							// Senão somente modifico o criterio de conversão
							cCt2Conv	:= Stuff(cCt2Conv,nCont,1,"4")
						ENDIF

					// se o valor estiver zerado, modifico o criterio de conversão para 5
					ElseIf TMP->(Ctb105Get("CT2_VALR"+StrZero(nCont,2))) == 0
						If Subs(cCt2Conv,nCont,1) != "4"  //se for informado nao alterar para 5
							cCt2Conv := Stuff(cCt2Conv,nCont,1,"5")
						EndIf

					ElseIf Empty(Substr(cCt2Conv,nCont,1)) .and. !Empty(Substr(TMP->CT2_CONVER,nCont,1))
						cCt2Conv := Left(cCt2Conv,nCont-1)+Substr(TMP->CT2_CONVER,nCont,1)+SubStr(cCt2Conv,nCont+1,Len(cCt2Conv))
					EndIf
				EndIf
			Next

			If !Empty(cCt2Conv)
				// Pode ocorrer que neste momento a conta ainda esteja em branco (ver BOPS 89576). Se isso ocorrer,
				// nao gravar no TMP o criterio de conversao. No momento que o usuario informar a conta, o sistema
				// trara o criterio automaticamente do Plano de Contas.
				If !Empty(TMP->CT2_DEBITO) .Or. !Empty(TMP->CT2_CREDIT)
					TMP->CT2_CONVER	:= cCt2Conv
					cCt2Conv	:= ""
				EndIf
			EndIf

			TMP->CT2_FLAG := .F.
			If __lCT2Incons
				TMP->CT2_INCONS := "2"
			EndIf

			If TMP->CT2_LINHA == StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
				cSeqLan	:= StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001"
				nSeqHis	:= 1
				TMP->CT2_SEQLAN := cSeqLan
				TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
			ElseIf TMP->CT2_DC == '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
				nSeqHis ++
				TMP->CT2_SEQLAN := cSeqLan
				TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
			ElseIf TMP->CT2_DC != '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
				nSeqHis	:= 1
				cSeqLan := Soma1(cSeqLan)
				TMP->CT2_SEQLAN := cSeqLan
				TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
			Endif
			If aMvs[MV_PRELAN] = "S"		// Grava como pre lancamento se for S = Sempre
				TMP->CT2_TPSALD := D_PRELAN
			Endif

			If lSeqCorr

				If lSeqCorr .AND. lAglut
					cSeqCorr := CTBSQCor( Left((cAliasCTK)->CTKLPLPSEQ,3), cCodSeq, dDataLanc )
				ElseIf lSeqCorr
					cSeqCorr := CTBSQCor( (cAliasCTK)->CTK_LP, cCodSeq, dDataLanc )
				Endif

				If cSeqCrAnt > cSeqCorr
					cSeqCorr := cSeqCrAnt  // trata o caso do correlativo manual (digitado)
				EndIf
			EndIf

			//Grava Digito verificador das contas, caso o campo esteja em uso
			If lDCDUso						//  Digito de Controle
				If Empty(TMP->CT2_DCD)
					dbSelectArea("CT1")
					dbSetOrder(1)
					If MsSeek(xFilial()+TMP->CT2_DEBITO)
						TMP->CT2_DCD	:= CT1->CT1_DC
					EndIf
					dbSelectArea("TMP")
				EndIf
				If Empty(TMP->CT2_DCC)
					dbSelectArea("CT1")
					dbSetOrder(1)
					If MsSeek(xFilial()+TMP->CT2_CREDIT)
						TMP->CT2_DCC	:= CT1->CT1_DC
					EndIf
					dbSelectArea("TMP")
				EndIf
			EndIf

			If ( __cSGBD == "AS/400" ) .and. lAglByHist
				If lCTKHAGLUT
					TMP->CT2_TMPHIS := (cAliasCTK)->CTK_HAGLUT		/// GRAVA ANTES DO HISTORICO POIS PODE TER VARIAS LINHAS
				Else
					TMP->CT2_TMPHIS := (cAliasCTK)->CTK_HIST		/// GRAVA ANTES DO HISTORICO POIS PODE TER VARIAS LINHAS
				EndIf
			Endif

			lGravaHist	 := .F.
			lGravaHAglut := .F.
			If CT5->(MsSeek(cKeyCT5)) 		/// SE ACHAR O LANCAMENTO PADRAO DE ORIGEM
				If !Empty(CT5->CT5_HAGLUT)  /// E O HISTORICO AGLUTINADO ESTIVER PREENCHIDO
					If Empty(TMP->CT2_HIST)	/// SE O HISTORICO DO TMP ESTIVER VAZIO
						lGravaHAglut := .T.	/// MONTA HISTORICO AGLUTINADO
						lGravaHist	 := .T.
					Else					/// SE O HISTORICO DO TMP ESTIVER PREENCHIDO
						lGravaHAglut := .F.	/// GRAVA CONTINUAÇÕES DE HISTORICO DO CTK_HAGLUT/CTK_HIST (TOP)
						lGravaHist	 := .T.
					EndIf
				ElseIf lSomaLinha					/// SE NAO 1º REGISTRO AGLUTINACAO CODEBASE (TOP SEMPRE .T.)
					lGravaHist 		:= .T.
					lGravaHAglut	:= .F.
				EndIf
			Else
				lGravaHist		:= .F.
				lGravaHAglut	:= .F.
			EndIf

			If lGravaHist
				If lGravaHAglut
					cTpSald 	:= TMP->CT2_TPSALD
					cHistorico 	:= AllTrim(TransLcta(CT5->CT5_HAGLUT,240*2))
					nLen := Iif( GetNewPar( "MV_CT5HIST" , .T. ), Len(CT2->CT2_HIST), Len(CTK->CTK_HIST) )
					For nZ := 1 To Len(cHistorico) Step nLen
						If nZ > 1
							nSeqHis ++
						Endif
						cHist := SubStr(cHistorico,nZ,nLen)
						If nZ > 1
							dbSelectArea("TMP")
							DbSetOrder(2)
							DbSkip()
							If TMP->CT2_HIST = cHist
								Loop
							Endif

							CtdbAppend()
							TMP->CT2_DC	:= "4"

							If nLinha > Val( Replicate( "9", Len(CT2->CT2_LINHA) ) ) - 1 // 998
								cLinha := Soma1(cLinha)
								nLinha++
								TMP->CT2_LINHA 	:= cLinha
							Else
								nLinha++
								TMP->CT2_LINHA 	:= StrZero(nLinha,Len(CT2->CT2_LINHA))    //3
							Endif
						Endif

						TMP->CT2_HIST	:= cHist
						TMP->CT2_TPSALD := cTpSald
						TMP->CT2_SEQLAN := cSeqLan
						TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
						TMP->CT2_LP		:= CT5->CT5_LANPAD
						TMP->CT2_MOEDLC := CT5->CT5_MOEDLC
						TMP->CT2_MOEDAS := CT5->CT5_MOEDAS
						TMP->CT2_ORIGEM	:= (cAliasCTK)->CTK_ORIGEM
					Next nZ
				Else
					nRecCTKPos := CTK->(Recno())
					dbSelectArea("CTK")
					dbSetOrder(1)
					MsGoTo((cAliasCTK)->(CTKMINRECNO))

					If lCTKHAGLUT .And. !Empty(CT5->CT5_HAGLUT)
						cHistorico := CTK->CTK_HAGLUT
						lTaAglut := .T.
					Else
						cHistorico 	:= CTK->CTK_HIST
						lTaAglut := .F.
					EndIf

					if lMTA330

						cQryHst := " SELECT "
						cQryHst += " 		CTK.CTK_HIST "
						cQryHst += " 	,	CTK.CTK_HAGLUT "
						cQryHst += " FROM " + RetSQLName("CTK") + " CTK "
						cQryHst += " WHERE "
						cQryHst += " 		CTK.CTK_FILIAL			= ? "
						cQryHst += " 	AND	CTK.CTK_SEQUEN			= ? "
						cQryHst += " 	AND	CTK.CTK_DC				= ? "
						cQryHst += " 	AND	CTK.CTK_LP				= ? "
						cQryHst += " 	AND	CTK.CTK_LPSEQ			= ? "
						cQryHst += " 	AND	CTK.CTK_RECORI			= ? "
						cQryHst += " 	AND	CTK.D_E_L_E_T_ 			= ? "
						
						oQryHst := FwExecStatement():New( changeQuery(cQryHst) )
						oQryHst:setString(1, FWxFilial("CTK"))
						oQryHst:setString(2, cSeqChave)
						oQryHst:setString(3, "4")
						oQryHst:setString(4, CTK->CTK_LP) 
						oQryHst:setString(5, CTK->CTK_LPSEQ)
						oQryHst:setString(6, CTK->CTK_RECORI)//Pego somente o adicional de histórico da CTK posicionada acima
						oQryHst:setString(7, " ")

						cQryHst := oQryHst:GetFixQuery()

						oQryHst:destroy()

						cAlsHst := MPSYSOpenQuery(cQryHst)

						(cAlsHst)->(DbEval( { || cHistorico += if( lCTKHAGLUT .and. !empty((cAlsHst)->CTK_HAGLUT), (cAlsHst)->CTK_HAGLUT, if(lTaAglut,"",(cAlsHst)->CTK_HIST))}, ,;
											{ || (cAlsHst)->(!Eof()) }))

						(cAlsHst)->(DbCloseArea())
						
						cHistorico := Rtrim(cHistorico)
					
					else

						CTK->(dbSkip())
						While CTK->(!Eof()) .and. CTK->CTK_FILIAL == xFilial("CTK") .and. CTK->CTK_SEQUEN == cSeqChave .and. CTK->CTK_DC == "4"

							If lCTKHAGLUT .And. ! Empty(CT5->CT5_HAGLUT)
								cHistorico += CTK->CTK_HAGLUT
							ElseIf !lTaAglut                              // Para não copiar o históico CTK_HIST quando o históico aglutina estiver vazio
								cHistorico += CTK->CTK_HIST
							EndIf
							CTK->(dbSkip())
						EndDo
						cHistorico := Rtrim(cHistorico)

						CTK->(MsGoTo(nRecCTKPos))
						dbSelectArea("TMP")
					endif

					cTpSald	:= TMP->CT2_TPSALD

					nLen 	:= Iif( GetNewPar( "MV_CT5HIST" , .T. ), Len(CT2->CT2_HIST), Len(CTK->CTK_HIST) )

					For nZ := 1 To Len(cHistorico) Step nLen
						If nZ > 1
							nSeqHis ++
						Endif
						cHist := SubStr(cHistorico,nZ,nLen)
						If nZ > 1
							dbSelectArea("TMP")
							DbSetOrder(2)
							DbSkip()
							If TMP->CT2_HIST = cHist
								Loop
							Endif

							CtdbAppend()
							TMP->CT2_DC	:= "4"

							If nLinha > Val( Replicate( "9", Len(CT2->CT2_LINHA) ) ) - 1 // 998
								cLinha := Soma1(cLinha)
								nLinha++
								TMP->CT2_LINHA 	:= cLinha
							Else
								nLinha++
								TMP->CT2_LINHA 	:= StrZero(nLinha, Len(CT2->CT2_LINHA))
							Endif
						Endif

						TMP->CT2_HIST	:= cHist
						TMP->CT2_TPSALD := cTpSald
						TMP->CT2_SEQLAN := cSeqLan
						TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
						TMP->CT2_LP		:= CT5->CT5_LANPAD
						TMP->CT2_MOEDLC := CT5->CT5_MOEDLC
						TMP->CT2_MOEDAS := CT5->CT5_MOEDAS
						TMP->CT2_ORIGEM	:= (cAliasCTK)->CTK_ORIGEM
					Next nZ
				EndIf

				If Empty(cSubLote)
					cSubLote	:= CT5->CT5_SBLOTE
				Endif
			Endif

		EndIf

		If __lConOutR
			ConOutR("*PROCES*|ITEM ADICIONADO CARGA CTK->TMP->CT2")
		EndIf

		DbSelectArea( cAliasCTK )
		DbSkip()
		nLin ++
		lRet := .T.

	EndDo

	If CTK->(Eof()) .or. (cAliasCTK)->CTK_SEQUEN <> cSeqChave
		lEndCTK := .T.	///Indica que terminou a leitura de registros do CTK para a contabilizacao.
	EndIf

	dbSelectArea(cAliasCTK)
	dbSetOrder(nOrdCTK)
	nRecCTK := Recno()
	dbSelectArea("TMP")
	dbSetOrder(2)
	dbGoTop()

	// Em caso de aglutinar a sequencia de lancamento pode ser gerado errada, portanto eh refeita
	cSeqLan := StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001" -  pode ser gerado errada, portanto eh refeita
	nSeqHis := 0
	While ! Eof()
		If TMP->CT2_LINHA == StrZero( 1, Len(CT2->CT2_LINHA) )  //'001'
			cSeqLan	:= StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001"
			nSeqHis	:= 1
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		ElseIf TMP->CT2_DC == '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )  //'001'
			nSeqHis ++
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		ElseIf TMP->CT2_DC != '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )  //'001'
			nSeqHis	:= 1
			cSeqLan := Soma1(cSeqLan)
			TMP->CT2_SEQLAN := cSeqLan
			TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
		Endif
		DbSkip()
	EndDo

Else

    //tratamento normal - nao aglutinado
	While (cAliasCTK)->(!Eof()) .and. (cAliasCTK)->CTK_SEQUEN == cSeqChave .And. nLinha < MAX_LINHA[1]

		If lOrdTpSld			/// QUANDO ORDEM POR TIPO DE SALDO - QUEBRA DOCUMENTO POR TIPO DE SALDO
			If (cAliasCTK)->CTK_TPSALD <> cTpSldAtu
				nLin := MAX_LINHA[1]+1		/// SETA LINHA PARA QUEBRAR DOCUMENTO POR TIPO DE SALDO
				Exit
			EndIf
		ElseIf lOrdLp .AND. lVazioSubL .AND. lQuebraLP
			If (cAliasCTK)->CTK_LP <> cLancPadr
				nLin := MAX_LINHA[1]+1		/// SETA LINHA PARA QUEBRAR DOCUMENTO POR TIPO DE SALDO
				Exit
			EndIf
		EndIf

		If lDiaCtb
			If ( !Empty( (cAliasCTK)->CTK_DIACTB ) ) // A precedencia é o que está no LP
				cCodSeq := (cAliasCTK)->CTK_DIACTB
			ElseIf Len(aSeqDiario) >= 1 .And. ( !Empty(aSeqDiario[1][3])  .And. aSeqDiario[1][3] != "99" )
				cCodSeq := aSeqDiario[1][3]
			ElseIf Len(aSeqDiario) >= 1
				cCodSeq := CtbrDia( (cAliasCTK)->CTK_LP )
			EndIf
		Endif

		// Verifica se existe algum valor <> de 0
		If (cAliasCTK)->CTK_DC != "4"
			lZero := .F.
			For nCont1 := 1 To __nQuantas
				If !(cAliasCTK)->(Ctb105Get("CTK_VLR"+StrZero(nCont1,2))) == 0 
					lZero := .F.
					Exit
				Else
					lZero := .T.
				EndIf
			Next nCont1
		EndIf

		If !lZero
			DbSelectArea( "TMP" )
			DbSetOrder(1)
			CtdbAppend()
			lSomaLinha := .T.
			
			If CtbProcedBD()
				TMP->CT2_RECCTK := (cAliasCTK)->RECNO
			EndIf

			cKeyCT5 := xFilial("CT5") + (cAliasCTK)->(CTK_LP+CTK_LPSEQ)		/// USA O LP E SEQUENCIA POSICIONADOS
			
			CT5->(MsSeek(cKeyCT5))

			//Obtém o Historico do documento contábil da primeira sequencia
			If cPaisLoc $ "ARG/EQU" .And. Empty(cHistCapLt)
				cHistCapLt := CT5->CT5_DOCHIS
			EndIf

			If Empty(TMP->CT2_MOEDAS)
				TMP->CT2_MOEDAS := CT5->CT5_MOEDAS
				If CTBLCUso()
					If AllTrim((cAliasCTK)->CTK_ROTINA) == '__CTBLC__'
						cMoedCtk := ""
						For nCont1 := 1 To __nQuantas
							If !(cAliasCTK)->(Ctb105Get("CTK_VLR"+StrZero(nCont1,2))) == 0
								cMoedCTK += "1"
							Else
								cMoedCTK += "2"
							EndIf
						Next nCont1
						TMP->CT2_MOEDAS := cMoedCTK
					Endif
				Endif
			Endif

			For nCont := 1 To Len(aCampos)
				cCampoCTK := "CTK_" + Substr(aCampos[nCont][1],5,Len(aCampos[nCont][1]))
				nPos := FieldPos(aCampos[nCont][1])

				If AllTrim(aCampos[nCont][1]) == "CT2_VALOR" // contabilização na moeda 01

					If !aMVS[MV_ALTLCTO]		// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ SE INCONSISTENTE)

						TMP->CT2_VALOR := (cAliasCTK)->CTK_VLR01
					
					ElseIf Left(TMP->CT2_MOEDAS,1) == "1"

						TMP->CT2_VALOR := (cAliasCTK)->CTK_VLR01
						
					EndIf

				ElseIf Subs(aCampos[nCont][1],1,8) == "CT2_VALR" // contabilização das outras moedas

					//Verifica se existe calendario para a moeda na data do lancamento
					If lCache
						If (nPosPer := Ascan(aPerCache,{|x| x[1] == Subs(aCampos[nCont][1],9,2)})) == 0
							aPeriodos	:= CtbPeriodos(Subs(aCampos[nCont][1],9,2),dDataLanc,dDataLanc,.F.,.F.)
							aadd(aPerCache,{Subs(aCampos[nCont][1],9,2),aClone(aPeriodos)})
						Else
							aPeriodos	:=	aClone(aPerCache[nPosPer,2])
						Endif
					Else
						aPeriodos	:= CtbPeriodos(Subs(aCampos[nCont][1],9,2),dDataLanc,dDataLanc,.F.,.F.)
					EndIf

					// BOPS 131255 - RFC
					// tratamento dos campos do valor
					cTmpValr := "CT2_VALR" + Subs( aCampos[ nCont ][1] ,9 ,2 )
					cCtkValr := "CTK_VLR"  + Subs( aCampos[ nCont ][1] ,9 ,2 )

					// verifica se o campo existe antes de continuar a operacao
					// em agluns casos o campo existe no temporario mais não existe na query
					If ( TMP->( FieldPos( cTmpValr ) ) <= 0 .Or. ( cAliasCTK )->( FieldPos( cCtkValr ) ) <= 0 )
						Loop
					Endif

					// passo o valor da contabilização para uma variavel
					// afim de evitar sugeiras ou valores estranhos na contabilização
					nValCTKTMP := (cAliasCTK)->(Ctb105Get(cCtkValr))

					If ! aMVS[MV_ALTLCTO]		// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ SE INCONSISTENTE)

						TMP->(&cTmpValr) := nValCTKTMP

					ElseIf ! Empty(aPeriodos[1][1]) .and. SubStr(TMP->CT2_MOEDAS,Val(Subs(aCampos[nCont][1],9,2)),1) == "1"

						If aPeriodos[1][4] $ "1"	//Se o calendario estiver aberto

							TMP->(&cTmpValr) := nValCTKTMP
							
						Else
							Loop
						EndIf
					EndIf

					nValCTKTMP := 0

				ElseIf Subs( aCampos[ nCont ][1], 1, 9 ) == "CT2_DTCV3" // atualização da data do CV3
					TMP->CT2_DTCV3 := (cAliasCTK)->CTK_DATA

				ElseIf Tmp->(FieldPos(aCampos[nCont][1])) > 0 .And. (cAliasCTK)->(FieldPos(cCampoCTK)) > 0
					FieldPut(nPos,(cAliasCTK)->(Ctb105Get(cCampoCTK)))
				EndIf

			Next nCont
			If lSomaLinha
				If nLinha >  Val( Replicate( "9", Len(CT2->CT2_LINHA) ) ) - 1 // 998
					cLinha := Soma1(cLinha)
					nLinha++
					TMP->CT2_LINHA 	:= cLinha
				Else
					nLinha++
					TMP->CT2_LINHA 	:= StrZero(nLinha,Len(CT2->CT2_LINHA))  //3
				Endif
			EndIf


			/// CASO NAO SEJA CONTABILIZACAO AGLUTINADA - TOPCONN
			///////////////////////////////////////////////////////////////////////////////////
			/// CONTROLE DE RASTREAMENTO DOS LANCAMENTOS (SEM CTL) -> UTILIZADO NA CTBGRAVA()
			aAdd(aCTKxCT2,{TMP->(Recno()), { (cAliasCTK)->RECNO } })
			///////////////////////////////////////////////////////////////////////////////////

			If Len(aFlagCTB) > 0					//// CASO SEJA FEITA CONTABILIZACAO COM CONTROLE DE TRANSACAO
				If (nPosAFlag:= oFlag105[cValToChar((cAliasCTK)->RECNO)]) == nil 
					nPosAFlag := 0
				EndIf 
				If nPosAFlag > 0				/// SE TEM NO ARRAY DE FLAG DE CONTABILIZACAO REGISTRO CORRESPONDENTE
					nLenAFlag := Len(aFlagCTB)
					nAFlag := nPosAFlag	/// POSICAO INICIAL DO ARRAY CORRESPONDENTE AO LANCAMENTO
					While nAFlag <= nLenAFlag .and. aFlagCTB[nAFlag][6] == (cAliasCTK)->RECNO
						aFlagCTB[nAFlag][7] := TMP->(Recno())
						nAFlag++
					EndDo
				EndIf
			EndIf

			// Criterio de conversao
			If TMP->CT2_DC == "1" .Or. TMP->CT2_DC == "3"
				CarrCriter((cAliasCTK)->CTK_DEBITO,"1","TMP->CT2_CONVER",dDataLanc)
			EndIf
			If TMP->CT2_DC == "2" .Or. TMP->CT2_DC == "3"
				CarrCriter((cAliasCTK)->CTK_CREDIT,"2","TMP->CT2_CONVER",dDataLanc)
			EndIf

			//If !lAglut			//Grava TMP->CT2_KEY
				TMP->CT2_KEY	:= (cAliasCTK)->CTK_KEY
			//Endif

			// Valor nas outras moedas
			For  nCont := 2	To __nQuantas
				cMoeda := StrZero(nCont,2)

				// Verifica se moeda esta em uso ou se está bloqueada ou se data esta bloqueada para a moeda
				If (! CTBMInUse(cMoeda) )
					Loop
				EndIf

				If Substr(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. Substr(TMP->CT2_MOEDAS,nCont,1) == "3"
					cMoeda := StrZero(nCont,2)
					If lCache
						If (nPosPer := Ascan(aPerCache,{|x| x[1] == cMoeda})) == 0
							aPeriodos	:= CtbPeriodos(cMoeda,dDataLanc,dDataLanc,.F.,.F.)
							aadd(aPerCache,{cMoeda,aClone(aPeriodos)})
						Else
							aPeriodos	:=	aClone(aPerCache[nPosPer,2])
						Endif
					Else
						aPeriodos	:= CtbPeriodos(cMoeda,dDataLanc,dDataLanc,.F.,.F.)
					EndIf
					If !Empty(aPeriodos[1][1])
						// Se o calendario estiver aberto					
						// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ)
						If !aMVS[MV_ALTLCTO] .or. aPeriodos[1][4] $ "1"	
							// Converte valores
							If (cAliasCTK)->(Ctb105Get('CTK_VLR'+StrZero(nCont,2))) == 0 .and. Empty(&("CT5->CT5_VLR"+StrZero(nCont,2))) 
								TMP->(CTB105Put('CT2_VALR'+StrZero(nCont,2),CtbConv(Substr(TMP->CT2_CONVER,nCont,1),dDataLanc,cMoeda,TMP->CT2_VALOR)))
							EndIf
						EndIf
					EndIf
				EndIf

				If __alDtTaxa[nCont] //CtbUso("CT2_DTTX"+cMoeda)
					If cPaisLoc == "PER" .And. FindFunction("DtMoeAstMI") .And. DtMoeAstMI(@dDataTxMI)
						TMP->(CTB105Put("CT2_DTTX"+cMoeda,dDataTxMI))
				  	Else
						TMP->(CTB105Put("CT2_DTTX"+cMoeda,dDataLanc))
				  EndIf
				EndIf

			Next nCont

			//Atualizar o criterio de conversao apos prencher os valores em outras moedas.
			//Se o valor na moeda 01 estiver zerado, alterar o criterio de conversao para "5".
			//Nas outras moedas, o criterio de conversao devera ser alterado para "4".
			cCt2Conv := TMP->CT2_CONVER

			For nCont := 1 to __nQuantas
				If nCont == 1
					If TMP->CT2_VALOR == 0
						cCt2Conv := "5" + SubStr(cCt2Conv,2,__nQuantas)
					Else
						cCt2Conv := "1" + SubStr(cCt2Conv,2,__nQuantas)
					EndIf
				Else
					// tratativa para o carregamento dos valores
					If ! Empty(&("CT5->CT5_VLR"+StrZero(nCont,2)))

						// criterio de conversão para as moedas
						IF ALLTRIM(SubStr(cCt2Conv,2,__nQuantas)) == "A" .AND. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3"
							TMP->(CTB105Put("CT2_VALR"+StrZero(nCont,2), &( &("CT5->CT5_VLR"+StrZero(nCont,2)))))
							cCt2Conv	:= Stuff(cCt2Conv,nCont,1,"A")

						// se o criterio de conversão for 5, zero o valor da moeda
						ELSEIF ALLTRIM(SubStr(cCt2Conv,nCont,1)) == "5"
							TMP->(CTB105Put("CT2_VALR"+StrZero(nCont,2),0))

						ELSE
							// Senão somente modifico o criterio de conversão
							cCt2Conv	:= Stuff(cCt2Conv,nCont,1,"4")
						ENDIF

					// se o valor estiver zerado, modifico o criterio de conversão para 5
					ElseIf TMP->(Ctb105Get("CT2_VALR" + Strzero( nCont,2 ))) == 0
						If Subs(cCt2Conv,nCont,1) != "4"  //se for informado nao alterar para 5
							cCt2Conv := Stuff(cCt2Conv,nCont,1,"5")
						EndIf

					ElseIf Empty(Substr(cCt2Conv,nCont,1)) .and. !Empty(Substr(TMP->CT2_CONVER,nCont,1))
						cCt2Conv := Left(cCt2Conv,nCont-1)+Substr(TMP->CT2_CONVER,nCont,1)+SubStr(cCt2Conv,nCont+1,Len(cCt2Conv))
					EndIf
				EndIf
			Next

			If !Empty(cCt2Conv)
				// Pode ocorrer que neste momento a conta ainda esteja em branco (ver BOPS 89576). Se isso ocorrer,
				// nao gravar no TMP o criterio de conversao. No momento que o usuario informar a conta, o sistema
				// trara o criterio automaticamente do Plano de Contas.
				If !Empty(TMP->CT2_DEBITO) .Or. !Empty(TMP->CT2_CREDIT)
					TMP->CT2_CONVER	:= cCt2Conv
					cCt2Conv	:= ""
				EndIf
			EndIf

			TMP->CT2_FLAG := .F.
			If __lCT2Incons
				TMP->CT2_INCONS := "2"
			EndIf

			If TMP->CT2_LINHA == StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
				cSeqLan	:= StrZero( 1, Len(CT2->CT2_SEQLAN) )//"001"
				nSeqHis	:= 1
				TMP->CT2_SEQLAN := cSeqLan
				TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
			ElseIf TMP->CT2_DC == '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
				nSeqHis ++
				TMP->CT2_SEQLAN := cSeqLan
				TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
			ElseIf TMP->CT2_DC != '4' .And. TMP->CT2_LINHA != StrZero( 1, Len(CT2->CT2_LINHA) )//'001'
				nSeqHis	:= 1
				cSeqLan := Soma1(cSeqLan)
				TMP->CT2_SEQLAN := cSeqLan
				TMP->CT2_SEQHIS := StrZero(nSeqHis,3)
			Endif
			If aMvs[MV_PRELAN] = "S"		// Grava como pre lancamento se for S = Sempre
				TMP->CT2_TPSALD := D_PRELAN
			Endif

			If lSeqCorr

				If lSeqCorr .AND. lAglut
					cSeqCorr := CTBSQCor( Left((cAliasCTK)->CTKLPLPSEQ,3), cCodSeq, dDataLanc )
				ElseIf lSeqCorr
					cSeqCorr := CTBSQCor( (cAliasCTK)->CTK_LP, cCodSeq, dDataLanc )
				Endif

				If cSeqCrAnt > cSeqCorr
					cSeqCorr := cSeqCrAnt  // trata o caso do correlativo manual (digitado)
				EndIf
			EndIf

			//Grava Digito verificador das contas, caso o campo esteja em uso
			If lDCDUso						//  Digito de Controle
				If Empty(TMP->CT2_DCD)
					dbSelectArea("CT1")
					dbSetOrder(1)
					If MsSeek(xFilial()+TMP->CT2_DEBITO)
						TMP->CT2_DCD	:= CT1->CT1_DC
					EndIf
					dbSelectArea("TMP")
				EndIf
				If Empty(TMP->CT2_DCC)
					dbSelectArea("CT1")
					dbSetOrder(1)
					If MsSeek(xFilial()+TMP->CT2_CREDIT)
						TMP->CT2_DCC	:= CT1->CT1_DC
					EndIf
					dbSelectArea("TMP")
				EndIf
			EndIf

			//// SE NÃO FOR AGLUTINADO
			If (Empty(cSubLote) .OR. (lVazioSubL .AND. !lCt105SbLote .AND. lQuebraLP )) .and. CT5->(MsSeek(cKeyCT5))	//// SE O NUMERO DE SUB-LOTE ESTIVER EM BRANCO 
				cSubLote	:= CT5->CT5_SBLOTE
			Endif
		
		EndIf

		If __lConOutR
			ConOutR("*PROCES*|ITEM ADICIONADO CARGA CTK->TMP->CT2")
		EndIf

		DbSelectArea( cAliasCTK )
		(cAliasCTK)->(DbSkip())
		nLin ++
		lRet := .T.

	EndDo
	
	If CTK->(Eof()) .or. (cAliasCTK)->CTK_SEQUEN <> cSeqChave
		lEndCTK := .T.	///Indica que terminou a leitura de registros do CTK para a contabilizacao.
	EndIf

	dbSelectArea(cAliasCTK)
	(cAliasCTK)->(dbSetOrder(nOrdCTK))
	nRecCTK := (cAliasCTK)->(Recno())
	dbSelectArea("TMP")
	dbSetOrder(2)
	dbGoTop()

EndIf

//volta para inicio do arquivo temporario
TMP->(dbGotop())

If __lConOutR
	ConOutR("*PROCES*|TERMINO CARGA CTK->TMP->CT2")
EndIf
Asize(aPeriodos,0)
aPeriodos := nil 
RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CtExibeCta³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Criterio de Conversao - Validacao MSGETDB          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtExibeCta(cConta,cTipo)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta Contabil                                     ³±±
±±³          ³ ExpC2 = Tipo do Lancamento contabil                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtExibeCta(cConta,cTipo,dDataLanc)

// Carrega criterio de conversao
CarrCriter(cConta,cTipo,"TMP->CT2_CONVER",dDataLanc)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CarrCriter³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Criterio de Conversao para campo arq temporario    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CarrCriter(cConta,cTipo,cCampo)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta Contabil                                     ³±±
±±³          ³ ExpC2 = Tipo do Lancamento contabil                        ³±±
±±³          ³ ExpC3 = Campo                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CarrCriter(cConta,cTipo,cCampo,dDataLanc)

Local cCriter
Local nCont
Local aSaveArea := GetArea()
Local aPeriodos	:= {}
Local lCT1Eof
Local cPreenchido := ""
Local cKeySeek 

Local lCache := CtbCache(9)
Local nPosCrit := 0

DEFAULT dDataLanc := CTOD("  /  /  ")

// Criterio de conversao
If cTipo == "1" .Or. cTipo == "3"

	cCriter := "1"	//Ref a moeda 01
	cKeySeek := xFilial("CT1") + cConta
	
	//- efetua o posicionamento do CT1
	If (nPosCrit := __oCritPln[cKeySeek]) == nil
		nPosCrit := 0 
		If CT1->(MsSeek(cKeySeek, .T. ))
			nPosCrit  := CT1->(Recno())
		EndIf 
		__oCritPln[cKeySeek] := nPosCrit
	EndIf 
	
	//- garante o posicionamento do CT1
	If nPosCrit > 0 
		CT1->(MsGoto( nPosCrit ))
	Else
		CT1->(dbGoBottom())  //ultimo registro
		CT1->(dbSkip()) //posicionar em fim de arquivo
	EndIf
	
	lCT1Eof := nPosCrit <= 0
	
	If _MVCRITPLN
		For nCont := 2	To __nQuantas
			If ! Empty( dDataLanc )

				If !aMVS[MV_ALTLCTO]					/// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ)

					If (FunName() $ 'CTBA102#CTBA103#CTBA104' .Or. ( FunName() <> 'CTBA102' .And. (!Empty(TMP->CT2_MOEDAS) .And. Subs(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3" ) .Or. Empty(TMP->CT2_MOEDAS)))
						cCriter += CT1->(Ctb105Get('CT1_CVD'+StrZero(nCont,2)))
					Else
						cCriter += "5"
					EndIf
				Else
					//Verifica se exist e calendario para a moeda na data do lancamento
					If lCache
						If (nPosPer := Ascan(aPerCache,{|x| x[1] == StrZero(nCont,2)})) == 0
							aPeriodos	:= CtbPeriodos(StrZero(nCont,2),dDataLanc,dDataLanc,.F.,.F.)
							aadd(aPerCache,{StrZero(nCont,2),aClone(aPeriodos)})
						Else
							aPeriodos	:=	aClone(aPerCache[nPosPer,2])
						Endif
					Else
						aPeriodos	:= CtbPeriodos(StrZero(nCont,2),dDataLanc,dDataLanc,.F.,.F.)
					EndIf

					If !Empty(aPeriodos[1][1])
						If aPeriodos[1][4] $ "1".And. (FunName() $ 'CTBA102#CTBA103' 	.Or. ( FunName() <> 'CTBA102' .And. (!Empty(TMP->CT2_MOEDAS) .And. Subs(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3" ) .Or. Empty(TMP->CT2_MOEDAS)))
							cCriter += CT1->(Ctb105Get('CT1_CVD'+StrZero(nCont,2)))
						Else
							cCriter += "5"
						EndIf
					Else
						cCriter += "5"
					EndIf
				EndIf
			Else
				cCriter += CT1->(Ctb105Get('CT1_CVD'+StrZero(nCont,2)))
			EndIf
		Next nCont
	Else
		if FunName() == "CTBA100"
			cCriter := FwFldGet(cCampo)
		else
			cCriter := &(cCampo)
		endif

		If Empty( cCriter )
			cCriter := CriaVar(StrTran(cCampo, "TMP", "CT2"))
		Endif
	Endif
EndIf

If cTipo == "2" .Or. cTipo == "3"
	cCriter := "1"	//Ref. a moeda 01

	cKeySeek := xFilial("CT1") + cConta
	
	If (nPosCrit := __oCritPln[cKeySeek]) == nil
		nPosCrit := 0 
		If CT1->(MsSeek( cKeySeek , .T. ))
			nPosCrit  := CT1->(Recno())
		EndIf 
		__oCritPln[cKeySeek] := nPosCrit
	EndIf 
	
	//- garante o posicionamento do CT1
	If nPosCrit > 0 
		CT1->(MsGoto( nPosCrit ))
	Else
		CT1->(dbGoBottom())  //ultimo registro
		CT1->(dbSkip()) //posicionar em fim de arquivo
	EndIf

	lCT1Eof := nPosCrit <= 0

	If _MVCRITPLN
		For nCont := 2	To __nQuantas
			If !Empty(dDataLanc)
				If !aMVS[MV_ALTLCTO]					/// SE NÃO ALTERA LANÇAMENTO (IRA GERAR PRÉ)
					If (FunName() $ 'CTBA102#CTBA103#CTBA104' .Or.;
						 ( FunName() <> 'CTBA102' .And. ;
						 (!Empty(TMP->CT2_MOEDAS) .And. Subs(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3" ) .Or. Empty(TMP->CT2_MOEDAS)))
						cCriter += CT1->(Ctb105Get('CT1_CVC'+StrZero(nCont,2)))
					Else
						cCriter += "5"
					EndIf
				Else
					If lCache
						If (nPosPer := Ascan(aPerCache,{|x| x[1] == StrZero(nCont,2)})) == 0
							aPeriodos	:= CtbPeriodos(StrZero(nCont,2),dDataLanc,dDataLanc,.F.,.F.)
							aadd(aPerCache,{StrZero(nCont,2),aClone(aPeriodos)})
						Else
							aPeriodos	:=	aClone(aPerCache[nPosPer,2])
						Endif
					Else
						aPeriodos	:= CtbPeriodos(StrZero(nCont,2),dDataLanc,dDataLanc,.F.,.F.)
					EndIf

					If !Empty(aPeriodos[1][1])
						If aPeriodos[1][4] $ "1" .And. (FunName() $ 'CTBA102#CTBA103#CTBA104' .Or.;
							 ( FunName() <> 'CTBA102' .And. ;
							 (!Empty(TMP->CT2_MOEDAS) .And. Subs(TMP->CT2_MOEDAS,nCont,1) == "1" .OR. ALLTRIM(SubStr(TMP->CT2_MOEDAS,nCont,1)) == "3") .Or. Empty(TMP->CT2_MOEDAS)))
							cCriter += CT1->(Ctb105Get('CT1_CVC'+StrZero(nCont,2)))
						Else
							cCriter += "5"
						EndIf
					Else
						cCriter += "5"
					EndIf
				EndIf
			Else
				cCriter += CT1->(Ctb105Get('CT1_CVC'+StrZero(nCont,2)))
			EndIf
		Next nCont
	Else
		if FunName() == "CTBA100"
			cCriter := FwFldGet(cCampo)
		else
			cCriter := &(cCampo)
		endif
		
		If Empty(cCriter)
			cCriter := CriaVar(StrTran(cCampo, "TMP", "CT2"))
		Endif
	Endif
EndIf

If !Empty(cCriter) .And. !Empty(cCampo)
	If Upper(cCampo) == "TMP->CT2_CONVER"
		If _MVCRITPLN .And. !lCt1Eof
			cPreenchido := cCriter
		ElseIf Empty(&(cCampo)) .and. !lCt1Eof  //  Se o campo estiver vazio e encontrou a conta no CT1
			cPreenchido := cCriter
		EndIf
	Else
		cPreenchido := cCriter
	EndIf

	// colocado esse controle pois a rotina CTBA100 foi alterada de
	// MSGetDB da 11 para um AddGrid da 12
	// FIX: buscar uma solucao para nao ter que ficar colocando funname
	If FunName() == "CTBA100"
		If subs(cCampo,1,4) <> 'CT9_' //VERIFICAR EM VERSOES FUTURAS SE AINDA É NECESSARIO O AJUSTE POR CONTA DE COMPATIBILIDADE, -> x3_valid dos campos CT9_DEBITO/CREDIT
			cCampo := 'CT9_CRITER'
		Endif
		FwFldPut(cCampo, cPreenchido)
	Else
		&(cCampo) := cPreenchido
	EndIf
EndIf
aSize(aPeriodos,0)
aPeriodos := nil 
RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105Conv³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Valores de  Conversao - Validacao MSGETDB          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb105Conv(nValor,cCriter,cMoedas)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor do Lancamento Contabil                       ³±±
±±³          ³ ExpC1 = Criterio de Conversao                              ³±±
±±³          ³ ExpC2 = Moedas do Lancamento Contabil                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb105Conv(nValor,cCriter)

Local cMoeda
Local nValorConv
Local nCont
Local cCritAlt	:= ""
Local aSize
Local nVlMax

cCriter := Iif(Empty(cCriter),TMP->CT2_CONVER,cCriter)
nValor	:= Iif(nValor==Nil,TMP->CT2_VALOR,nValor)

// Zera valor na moeda 1 -> quando CT2_CONVER,1,1 = "2"
If Substr(cCriter,1,1) == "5" //Nao utiliza criterio de conversao
	TMP->CT2_VALOR := 0
EndIf

//Se alterar o valor, atualiza o criterio de conversao.
If nValor == 0
	cCritAlt	:= "5"+Subs(cCriter,2,Len(cCriter))
	TMP->CT2_CONVER	:= cCritAlt
EndIf


For nCont := 1 To Len(cCriter)
	cMoeda := StrZero(nCont,2)

	// Atualiza a data de conversao conforme a data do lancamento
	If FunName() $ 'CTBA102#CTBA103#CTBA104' .AND. CtbUso( "CT2_DTTX" + cMoeda )
		TMP->(CTB105Put("CT2_DTTX" + cMoeda,dDataLanc))
	EndIf

	If cMoeda ='01'
		Loop
	EndIf

	// Verifica se moeda esta bloqueada ou se data esta bloqueada para a moeda
	lOkCTOCTP	:= (Ascan(aCTOCTPOk,cMoeda) > 0)
	If !lOkCTOCTP .And.(!CTBMInUse(cMoeda) .Or. !CtbDtInUse(cMoeda,dDataLanc))
		Loop
	Else
		If !lOkCTOCTP
			AAdd(aCTOCTPOk,cMoeda)
		Endif
	EndIf

	//Se alterar a taxa de conversao, atualiza os valores
	If Substr(cCriter,nCont,1) <> "5"	//Se utiliza taxa de conversao
		If Substr(cCriter,nCont,1) <> "4" .And. Substr(cCriter,nCont,1) <> "A"	//Se for taxa informada, nao altero o valor na outra moeda
			aSize := TamSX3('CT2_VALR'+cMoeda)
			nVlMax := val(repl('9',aSize[1]-IIf(aSize[2]>0,aSize[2]+1,0)))
			If CtbUso("CT2_DTTX"+cMoeda) .And. Substr(cCriter,nCont,1) == "9"
				nValorConv 	:= CtbConv("9",TMP->(Ctb105Get("CT2_DTTX"+cMoeda)),cMoeda,nValor)
			Else
				nValorConv 	:= CtbConv(Substr(cCriter,nCont,1),dDataLanc,cMoeda,nValor)
			EndIf
			If int(nValorConv)>nVlMax
				Help(" ",1,"WIDTHERR",, STR0067 ,3,0 ) // "A conversão da moeda implicará em valor fora da faixa de representação numérica."
				Return .F.
			EndIf
			TMP->(CTB105Put('CT2_VALR'+cMoeda,Round(nValorConv,aSize[2])))
		EndIf
	Else
		TMP->(CTB105Put('CT2_VALR'+cMoeda,0))
	EndIf
Next nCont
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105Cta ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida conta da GetDB                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb105Cta(cConta,cTipo)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expc1 = Conta                                              ³±±
±±³          ³ Expc2 = Tipo da conta                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105CTA(cConta,cTipo)

Local aSaveArea := GetArea()
Local lRet		:= .T., lCtaNil
Local lRateio	:= .F.
Local nValRat	:= 0
Local nTotalDeb	:= 0
Local nTotalCrd	:= 0
Local nRecTmp	:= 0
Local cProg		:= FunName()
Local cRateio	:= ""
Local cCampo	:= ReadVar()
Local lIntGC 	:= IIf((SuperGetMV("MV_VEICULO",,"N")) == "S", .T., .F.)
Local lFuncDMS	:= IIf(lIntGC .and. FindFunction("FGX_CallDMS"),FGX_CallDMS(), .F.)
Local oModel	:= iif(IsInCallstack("ATFA012") .Or. IsInCallstack("ATFA240") .Or. lFuncDMS ,Nil, FWModelActive())
Local nMVSOMA   := SuperGetMv("MV_SOMA")
Local cSaveVar  := IIf(Type("__READVAR") == "U", "", __READVAR) //Saved __READVAR
Local lRusBlind	:= .F. 

If lIsRussia
	lRusBlind = IsBlind()
Endif 

If (lCtaNil := cConta = Nil)
	cConta := &(ReadVar())
Endif

If ! CtbInUse()			  		// Compatilizacao para usar tambem com SigaCon
	Return Ca050cta(cConta, 1)	// Nao utilizo ValidaConta por ser recursiva
Endif

If cTipo == Nil			// Chamada externa lancamentos contabeis nao passar tipo
	dDataLanc := dDataBase
Endif

ConvConta(@cConta)

//Verificar se a conta possui o campo de Rateio preenchido. Valido somente para a digitacao de lancamentos contabeis
//atraves da rotina CTBA102. Verifica se esta posicionado na Getdb, pois quando digitava a conta na tela de rateio
//estava mostrando a tela do valor a ratear novamente.
If cProg $ 'CTBA102#CTBA103#CTBA104' .And. (TMP->(Recno()) == TMP->(RecCount())) .And. ;
	(Subs(cCampo,4,10) == "CT2_DEBITO" .Or. Subs(cCampo,4,10) == "CT2_CREDIT")
	dbSelectArea("CT1")
	dbSetOrder(1)
	If (MsSeek(xFilial()+cConta,.F.)) .And. !Empty(CT1->CT1_RATEIO)
		//Mostra tela para digitacao do valor a ser rateado. Retorna o valor digitado.
		nValRat	:= Ctb102VlRt()

		If nValRat > 0
		    cRateio	:= CT1->CT1_RATEIO
			cTipo 		:= CtbRateio(cRateio,nValRat,@nTotalDeb,@nTotalCrd,"","","")

			aTotRdpe := {{0,0,0,0},{0,0,0,0}}

			nRecTmp := TMP->(Recno())
			TMP->(DbGoTop())
			While ! TMP->(Eof())
				If Subs(cCampo,4,10) == "CT2_DEBITO"
					lRateio	:= .T.
					If TMP->CT2_DC $ "1/3" .Or. ;
						(!Empty(TMP->CT2_CCD) .Or. !Empty(TMP->CT2_ITEMD) .Or. !Empty(TMP->CT2_CLVLDB))
						TMP->CT2_DEBITO := cConta
					Else
						TMP->CT2_DEBITO := ""
					EndIf
				ElseIf Subs(cCampo,4,10) == "CT2_CREDIT"
					lRateio	:= .T.
					If TMP->CT2_DC $ "2/3" .Or. ;
						(!Empty(TMP->CT2_CCC) .Or. !Empty(TMP->CT2_ITEMC) .Or. !Empty(TMP->CT2_CLVLCR))
						TMP->CT2_CREDIT	:= cConta
					Else
						TMP->CT2_CREDIT	:= ""
					EndIf
				EndIf
				If ! TMP->CT2_FLAG
					CTB102Exibe(TMP->CT2_VALOR,0,TMP->CT2_DC,"",nMVSOMA)
				Endif
				TMP->(DbSkip())
			EndDo
			TMP->(DbGoTo(nRecTmp))
		EndIf
	EndIf
EndIf

//Se nao eh rateio de conta
If !lRateio
	If cTipo == '1'
		TMP->CT2_DEBITO := cConta
	ElseIf cTipo <> Nil
		TMP->CT2_CREDIT := cConta
	Endif
EndIf

lRET := ValidaConta(cConta,cTipo,,,.T.)
If lRet
	If cTipo <> Nil		// Chamada externa lancamentos contabeis nao passar tipo
		If ( TMP->CT2_DC $ '1/3' .And. cTipo == "1" ) .Or. ( TMP->CT2_DC $ '2/3' .And. cTipo == "2" )
			CTExibeCta(cConta,cTipo,dDataLanc)
			C102ExbCta(cConta)
			Ctb105Conv()
			// Se a conta tiver um Hist. Padrao cadastrado e o Histórico na MSGETDB estiver em branco,
			// jogar este Hist. Padrao na MSGETDB atraves de Ctb101Hist
			If ! Empty(CT1->CT1_HP) .And. Empty(TMP->CT2_HP) .and. Empty(TMP->CT2_HIST)
				Ctb101Hist(CT1->CT1_HP,,,,,,,,.T.)
			EndIf
		EndIf
		If lRet
			If !Empty(cConta) .And. TMP->CT2_DC == '4'
				Help(" ",1,"NOCTAHIS")
				lRet := .F.
			EndIf
		EndIf
	Endif

	If lRet
		lRet :=	ValidaBloq(cConta,dDataLanc,"CT1")
	EndIf
EndIf

If lRet .And. ((cTipo == Nil .And. lCtaNil) .or. ( (FunName() $ "CTBA102|CTBA103"  ) .And. IIf(cTipo != Nil, cTipo $ "1|2", .F.)  )) .And. !(IsInCallStack("AUTO681") .Or. IsInCallStack("CustoPrep"))  .And. !(FunName() $ "AGRA600|AGRA605|")	// Chamada externa lancamentos contabeis nao passar tipo

	If oModel == Nil .or. !oModel:IsActive() .or. lRotMVC .or. lRusBlind .Or. (Type("l103Auto")=="L" .And. l103Auto) // Verifico se a rotina esta em MVC ... Para rotinas que não estejam em MVC é necessário passar a variável como .T.
			&(ReadVar()) := cConta
	Else
		If At("->",cCampo) > 0
			cCampo := SubStr(cCampo, At("->",cCampo) + 2, Len(cCampo))
		EndIf

		FWFldPut(cCampo,cConta,,,,.T.)
		
		oView := FWViewActive()

		cView := CTBRetIdV(cCampo)
		
		If oView <> Nil	.And. oView:IsActive() .And. oView:GetModel():GetID()<>"ATFA012" .And. oView:GetModel():GetID()<>"CNTA300" .And. oView:GetModel():GetID()<>"CNTA121"
		oView:Refresh()
			If !Empty(cView) .and. !Empty(cCampo)
				If FwLibVersion() >= '20201009'
					oView:fieldRefresh(cView, cCampo)
				Endif
			EndIf	
		Endif

		//Occurs where the __READVAR variable changes your value after View Loaded
		If (lIsRussia .AND. !(Type("__READVAR") == "U") .AND. !(Empty(cSaveVar)))
			//Restoring __READVAR
			__READVAR := cSaveVar
		EndIf		
	Endif
Endif

RestArea(aSaveArea)

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105CC  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Centro de Custo da GetDB                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTB105CC(cCusto,cTipo)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Centro de Custo                                    ³±±
±±³          ³ ExpC2 = Tipo do centro do custo                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105CC(cCusto,cTipo)

Local aSaveArea := GetArea()
Local lRet		:= .T., lCusNil
Local cCampo	:= ""
Local lIntGC 	:= IIf((SuperGetMV("MV_VEICULO",,"N")) == "S", .T., .F.)
Local lFuncDMS	:= IIf(lIntGC .and. FindFunction("FGX_CallDMS"),FGX_CallDMS(), .F.)
Local oModel	:= iif( FWIsInCallStack( 'MNTA411' ) .Or. IsInCallstack("ATFA012") .Or.;
	IsInCallstack("ATFA240") .Or. lFuncDMS, Nil, FWModelActive() )

If (lCusNil := cCusto = Nil)
	cCusto := &(ReadVar())
Endif

If ! CtbInUse()				// Compatilizacao para usar tambem com SigaCon
	Return ExistCpo("SI3",cCusto)	// Nao utilizo ValidaCusto por ser recursiva
Endif

If cTipo = Nil			// Chamada externa lancamentos contabeis nao passar tipo
	dDataLanc 	:= dDataBase
Endif

ConvCusto(@cCusto)

If cTipo == '1'
	TMP->CT2_CCD := cCusto
ElseIf cTipo <> Nil		// Chamada externa lancamentos contabeis nao passar tipo
	TMP->CT2_CCC := cCusto
Endif

lRET := ValidaCusto(cCusto,cTipo,,,.T.)

If lRet
	lRet := ValidaBloq(cCusto,dDataLanc,"CTT")
	If cTipo <> Nil // Chamada externa lancamentos contabeis nao passar tipo
		C102ExbCC(cCusto)
	Endif
EndIf

If lRet .And. cTipo = Nil .And. lCusNil	.And. !(FunName() $ "AGRA600|AGRA605|")	// Chamada externa lancamentos contabeis nao passar tipo

	If oModel == Nil .or. !oModel:IsActive() .or. lRotMVC // Verifico se a rotina esta em MVC ... Para rotinas que não estejam em MVC é necessário passar a variável como .T.
		&(ReadVar()) := cCusto
	Else
		cCampo := ReadVar()

		If At("->",cCampo) > 0
			cCampo := SubStr(cCampo, At("->",cCampo) + 2, Len(cCampo))
		EndIf

		FWFldPut(cCampo,cCusto,,,,.T.)
	Endif
Endif

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105ITEM³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Item Contabil da GetDB                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb105item(cItem,ctipo)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Item Contabil                                      ³±±
±±³          ³ ExpC2 = Tipo do Item contabil                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105Item(cItem,cTipo)

Local aSaveArea := GetArea()
Local lRet		:= .T., lItNil
Local cCampo	:= ''
Local lIntGC 	:= IIf((SuperGetMV("MV_VEICULO",,"N")) == "S", .T., .F.)
Local lFuncDMS	:= IIf(lIntGC .and. FindFunction("FGX_CallDMS"),FGX_CallDMS(), .F.)
Local oModel	:= iif(IsInCallstack("ATFA012") .Or. IsInCallstack("ATFA240") .Or. lFuncDMS ,Nil, FWModelActive())

If (lItNil := cItem = Nil)
	cItem := &(ReadVar())
Endif

If ! CtbInUse()				// Compatilizacao para usar tambem com SigaCon
	Return ExistCpo("SID",cItem)	// Nao utilizo ValidaCusto por ser recursiva
Endif

If cTipo = Nil			// Chamada externa lancamentos contabeis nao passar tipo
	dDataLanc := dDataBase
Endif

ConvItem(@cItem)

If cTipo == '1'
	TMP->CT2_ITEMD := cItem
ElseIf cTipo <> Nil		// Chamada externa lancamentos contabeis nao passar tipo
	TMP->CT2_ITEMC := cItem
Endif

lRet := ValidItem(cItem,cTipo,,,.T.)
If lRet
	lRet := ValidaBloq(cItem,dDataLanc,"CTD")
	If cTipo <> Nil			// Chamada externa lancamentos contabeis nao passar tipo
		C102ExbIt(cItem)
	Endif
EndIf

If lRet .And. cTipo = Nil .And. lItNil	// Chamada externa lancamentos contabeis nao passar tipo

	If oModel == Nil .or. !oModel:IsActive() .or. lRotMVC // Verifico se a rotina esta em MVC ... Para rotinas que não estejam em MVC é necessário passar a variável como .T.
		&(ReadVar()) := cItem
	Else
		cCampo := ReadVar()

		If At("->",cCampo) > 0
			cCampo := SubStr(cCampo, At("->",cCampo) + 2, Len(cCampo))
		EndIf

		FWFldPut(cCampo,cItem,,,,.T.)
	Endif
Endif

RestArea(aSaveArea)

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb105CLVL³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Classe de Valor da GetDB                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb105Clvl(cClVl,cTipo)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = classe de valor                                    ³±±
±±³          ³ ExpC2 = Tipo da classe de valor                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105CLVL(cClvl,cTipo)

Local aSaveArea := GetArea()
Local lRet		:= .T., lClNil
Local cCampo	:= ""
Local lIntGC 	:= IIf((SuperGetMV("MV_VEICULO",,"N")) == "S", .T., .F.)
Local lFuncDMS	:= IIf(lIntGC .and. FindFunction("FGX_CallDMS"),FGX_CallDMS(), .F.)
Local oModel	:= iif(IsInCallstack("ATFA012") .Or. IsInCallstack("ATFA240") .Or. lFuncDMS ,Nil, FWModelActive())

If (lClNil := cClVl = Nil)
	cClVl := &(ReadVar())
Endif

If cTipo = Nil			// Chamada externa lancamentos contabeis nao passar tipo
	dDataLanc := dDataBase
Endif

ConvCLVL(@cClvl)

If cTipo == '1'
	TMP->CT2_CLVLDB := cClvl
ElseIf cTipo <> Nil		// Chamada externa lancamentos contabeis nao passar tipo
	TMP->CT2_CLVLCR := cClvl
Endif

lRET := ValidaCLVL(cCLVL,cTipo,,,.T.)

If lRet
	lRet :=	ValidaBloq(cCLVL,dDataLanc,"CTH")
	If cTipo <> Nil			// Chamada externa lancamentos contabeis nao passar tipo
		C102ExbCV(cClvl)
	Endif
EndIf

If lRet .And. cTipo = Nil .And. lClNil	// Chamada externa lancamentos contabeis nao passar tipo

	If oModel == Nil .or. !oModel:IsActive() .or. lRotMVC // Verifico se a rotina esta em MVC ... Para rotinas que não estejam em MVC é necessário passar a variável como .T.
		&(ReadVar()) := cClVl
	Else
		cCampo := ReadVar()

		If At("->",cCampo) > 0
			cCampo := SubStr(cCampo, At("->",cCampo) + 2, Len(cCampo))
		EndIf 

		FWFldPut(cCampo,cClVl,,,,.T.)
	Endif

Endif

RestArea(aSaveArea)

Return lRET

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CT105LINOK³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida linha do lancamento na MSGETDB                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct105LinOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo  :                                                  ³±±
±±³          ³ lEfetiva: Se .T., indica que esta executando a rotina de   ³±±
±±³          ³           Efetivacao de Lanctos.				              ³±±
±±³          ³ aErro   : Array que recebera codigos para identificar as   ³±±
±±³          ³           inconsistencias. Sera utilizada na Efetivacao.   ³±±
±±³          ³ lTodas  : Se .T., indica que deve verificar todas as incon-³±±
±±³          ³           sistencias. Se .F., retornara na primeira incon- ³±±
±±³          ³           encontrada.                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ANALISTA          * ALTERAÇÕES                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±Wagner Montenegro * ADICIONADO TRATAMENTO PARA ATIVIDADES COMPLEMENTARES³±±
±±       28/04/2010 * FUNÇÃO CTBValidAt("??",?)??="DB" OU "CR"            ³±±
±±                  * ?=1 P/CTBA101 OU 2 P/CTBA105                        ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT105LINOK(cCampo,lEfetiva,aErro,lTodas,nOpc,lDCDUso)

Local aSaveArea	:= GetArea()
Local cDCD			:= " "
Local cDCC			:= " "
Local cContCCD
Local cContCCC
Local cItemD
Local cItemC
Local cCLVLD
Local cCLVLC
Local cHist		:= TMP->CT2_HIST
Local cDebito  	:= TMP->CT2_DEBITO
Local cCredito 	:= TMP->CT2_CREDIT
Local cDC      	:= TMP->CT2_DC
Local cCriter
Local cLinha	:= TMP->CT2_LINHA
Local cTpSald	:= TMP->CT2_TPSALD

Local lRet			:= .t.
Local lDigito		:= .F.
Local lVlrConv		:= .F.
Local nOutVlr 		:= 0
Local cConver		:= ""

Local nCont
Local nValor   	:= TMP->CT2_VALOR
Local lRpc		:= Type("oMainWnd") <> "U"

Local nQtdMoeda

Local lCallEfet		:= FunName() == "CTBA350"

Local lVAt 			:= FindFunction("CTBValidAt")
Local cTpSaldoAnt 	:= ""
Local lCtrCtb       := SuperGetMV("MV_CTRCTB",.F.,"2") == "1"
Local lVlTpPart		:= SuperGetMv("MV_CTBVLP",.F.,.F.) //Valida tipo da partida, Se .T. em linhas de debito/credito apenas podem ser preenchidas contas da mesma natureza

// ARRAY PASSADO PARA FUNÇÃO CTBVALIDAT
Private aAtivCT1:={}
Private aAtivCTD:={}
Private aAtivCTH:={}
Private aAtivCTT:={}
Private aCtbEntid

If lFromProcPOUI == Nil
	lFromProcPOUI := FwIsInCallStack("CTB102POUI") // Essa função é chamada nos fontes CTBA350 e CTBC020, essa variável é usada na função Ctb102Carr().
EndIf

If Type("cLote") == "U"
	Private cLote := TMP->CT2_LOTE	
EndIf

If Type("cSubLote") == "U"
	Private cSubLote := TMP->CT2_SBLOTE
EndIf

__lIntPOUI := IIf(__lIntPOUI != Nil, __lIntPOUI, .F.) //Integracao POUI

Default cCampo		:= ""
Default lEfetiva	:= .F.		// Chamada a partir da Efetivacao de Lancamentos. Se .T., irá até o fim da rotina para encontrar todos os erros; por isso lRet recebera lEfetiva.
Default aErro		:= {}		// Retorna os codigos de erro para a Efetivacao, que gravará como inconsistencia
Default lTodas		:= .F.		// Se .F., indica que pode retornar na primeira inconsistencia encontrada; se .T.,
								//	devera verificar TODAS as inconsistencias
If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

Default lDCDUso 	:= __lDCDUso          //  Digito de Controle

If Empty(nOpc)
	If TYPE("OPCAO") <> "U" .and. ValType(OPCAO) == "N"
		Default nOpc		:= OPCAO
	Else
		Default nOpc		:= 3
	EndIf
EndIf

If lEfetiva
	lRpc		:= .F.
	cCriter		:= Replicate( TMP->CT2_CRCONV,__nQuantas )
	nQtdMoeda	:= 1
Else
	If TMP->CT2_FLAG .and. GetNewPar( "MV_CT105LD" , 1 ) == 1							//  Linha Deletada
 		If _lC105VLIN 
			Return ExecBlock("C105VLIN", .F., .F.,{TMP->CT2_FLAG})
		Else
			Return .T.
		EndIf
	EndIf

	//	Se estiver no remote, não for CTBA101 e CTBA102, e nao permite alteração do lançamento
    If (lRpc .And. !( FunName() $ "CTBA101#CTBA102#CTBA103#CTBA104" )) .Or. __lBlind .And. !aMVS[MV_ALTLCTO]
    	lRpc := GetNewPar("MV_CT105MS","S") == "S"				//	S-Mostra msg; N-Não mostra msg
	EndIf
	cCriter		:= TMP->CT2_CONVER
	nQtdMoeda	:= __nQuantas
EndIf

If lFromProcPOUI .Or. __lIntPOUI
	lRpc := .T.
EndIf

If __lCusto									// Centro de custo
	cContCCD	:=	TMP->CT2_CCD
	cContCCC	:=	TMP->CT2_CCC
EndIf

If __lITem									// Item
	cItemD 	:= TMP->CT2_ITEMD
	cItemC 	:= TMP->CT2_ITEMC
EndIf

If __lCLVL									// Classe de Valor
	cClVLD	:= TMP->CT2_CLVLDB
	cCLVLC  := TMP->CT2_CLVLCR
EndIf

If lDCDUso						//  Digito de Controle
	cDCD  	:= TMP->CT2_DCD
	cDCC  	:= TMP->CT2_DCC
	lDigito	:= .T.
EndIf

// Novas entidades
If __lEnt05
	cEnt05Db 	:= TMP->CT2_EC05DB
	cEnt05Cr 	:= TMP->CT2_EC05CR
Endif

If __lEnt06
	cEnt06Db 	:= TMP->CT2_EC06DB
	cEnt06Cr 	:= TMP->CT2_EC06CR
Endif

If __lEnt07
	cEnt07Db 	:= TMP->CT2_EC07DB
	cEnt07Cr 	:= TMP->CT2_EC07CR
Endif

If __lEnt08
	cEnt08Db 	:= TMP->CT2_EC08DB
	cEnt08Cr 	:= TMP->CT2_EC08CR
Endif

If __lEnt09
	cEnt09Db 	:= TMP->CT2_EC09DB
	cEnt09Cr 	:= TMP->CT2_EC09CR
Endif

// ******************************************
// * Entidade Contabil 05 - Peru e Colombia *
// ******************************************
cEnt05Db := If(TMP->(FieldPos("CT2_EC05DB"))>0,TMP->CT2_EC05DB,'')
cEnt05Cr := If(TMP->(FieldPos("CT2_EC05CR"))>0,TMP->CT2_EC05CR,'')
cEnt06Db := If(TMP->(FieldPos("CT2_EC06DB"))>0,TMP->CT2_EC06DB,'')
cEnt06Cr := If(TMP->(FieldPos("CT2_EC06CR"))>0,TMP->CT2_EC06CR,'')
cEnt07Db := If(TMP->(FieldPos("CT2_EC07DB"))>0,TMP->CT2_EC07DB,'')
cEnt07Cr := If(TMP->(FieldPos("CT2_EC07CR"))>0,TMP->CT2_EC07CR,'')
cEnt08Db := If(TMP->(FieldPos("CT2_EC08DB"))>0,TMP->CT2_EC08DB,'')
cEnt08Cr := If(TMP->(FieldPos("CT2_EC08CR"))>0,TMP->CT2_EC08CR,'')
cEnt09Db := If(TMP->(FieldPos("CT2_EC09DB"))>0,TMP->CT2_EC09DB,'')
cEnt09Cr := If(TMP->(FieldPos("CT2_EC09CR"))>0,TMP->CT2_EC09CR,'')

cAtiviDb := If(TMP->(FieldPos("CT2_ATIVDE"))>0,TMP->CT2_ATIVDE,'')
cAtiviCr := If(TMP->(FieldPos("CT2_ATIVCR"))>0,TMP->CT2_ATIVCR,'')

If nOpc <> 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Tipo nao foi preenchido                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( cDC )
		If lRpc
			Help( " ", 1, "FALTATPLAN" )
		EndIf
		cCampo := "CT2_DC"
		lRet   := lTodas
		Aadd(aErro,1)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Valor nao preenchido                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .and. cDC <> "4"
		For nCont := 2 To nQtdMoeda
			cCoin4	:= StrZero(nCont,2)
			nOutVlr := TMP->(Ctb105Get("CT2_VALR"+cCoin4))
			cConver	:= Subs(TMP->CT2_CONVER,nCont,1)

			//Teste para verificar se há algum valor de conversão.
			If nOutVlr <>  0
				If cConver == "5"
					cCampo := "CT2_VLR"+cCoin4
					lRet   := lTodas
					Aadd(aErro,2)
					If lRpc
						Help( " ", 1, cCampo )
					EndIf
					Exit
				EndIf
				lVlrConv		:= .T.
			EndiF
		Next

		If lRet .and. (nValor = 0 .And. !lVlrConv)
			cCampo := "CT2_VALOR"
			lRet   := lTodas
			Aadd(aErro,2)
			If lRpc
				Help( " ", 1, "FALTAVALOR" )
			EndIf
		EndIf
	EndIf
EndIf

If lRet .And. cDC <> "4"
	If cPaisLoc <> "BRA"
		//Se o parâmetro da blindagem contábil estiver habilitado = "1", será validado a configuração da blindagem contábil.
		If lCtrCtb
			//Habilita a utilização da validação dos controles contábeis nos lançamentos contábeis manuais e de integração
			If !Empty(__cCodSeq)
				lRet := CTBVldCtrl(cDebito, cCredito,cLote ,cSubLote,__cCodSeq,cLinha)
			Else
				lRet := CTBVldCtrl(cDebito, cCredito,cLote ,cSubLote,,cLinha)
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ///MSL - 16/10/06
//³VALIDACAO DE BLOQUEIOS E AMARRAÇÕES (CTG, CTO, CTP).³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ///MSL - 16/10/06
If lRet .and. cDC <> "4"
	If nOpc == 3 .or. nOpc == 6 .or. nOpc == 7	/// Se for inclusão (estorno ou copia inclusive)
		For nCont := 1 to nQtdMoeda	/// Roda todas as moedas
			If lEfetiva
				cCoin4		:= TMP->CT2_MOEDLC
				nVlrLan		:= TMP->CT2_VALOR
			Else
				cCoin4 		:= alltrim(strzero(int(nCont),2))
				iF nCont == 1
					nVlrLan := TMP->CT2_VALOR
				Else
					nVlrLan := 	TMP->(Ctb105Get("CT2_VALR"+cCoin4))
				EndIf
			EndIf

			If nVlrLan <> 0 // Se houver valor
				// Verifica CTO e 			no CTP ausência ou bloqueios.
				lOkCTOCTP	:= (Ascan(aCTOCTPOk,cCoin4) > 0)
				If !lOkCTOCTP .And. (!CTBMInUse(cCoin4) .Or. !CtbDtInUse(cCoin4,dDataLanc))
					Aadd(aErro,19)
					lRet   := lTodas
					If lRpc
						Help( " ", 1, "CT2_VLR"+cCoin4 )
					EndIf
					If !lTodas
						Exit
					EndIf
				Else
					If !lOkCTOCTP
						AAdd(aCTOCTPOk,cCoin4)
					Endif
 					If AScan(aMoedaOk, {|x| x[1] + IIF(lVldTps,x[2],"") == cCoin4 + IIF(lVldTps,cTpSald,"")} ) == 0
						// Verifica CTG ausencia ou bloqueio de calendário.
						If CtbDtComp(3,dDataLanc,cCoin4,,cTpSald)
							AAdd(aMoedaOk,{cCoin4,cTpSald})
						Else
							Aadd(aErro,19)
							lRet   := lTodas
							If !lTodas
								Exit
							EnDif
						EnDif
					Endif
				EndIf
			EndIf

			If lEfetiva
				Exit
			EndIf
		Next
	ElseIf nOpc == 4	/// Se for alteração

		cKeyLin 	:= ""
		For nCont := 1 to nQtdMoeda	/// Roda todas as moedas
			cCoin4 		:= alltrim(strzero(int(nCont),2))
			lValidCoin	:= .F.
			/// SE TIVER VALOR NA MOEDA VALIDA
			If nCont == 1
				If TMP->CT2_VALOR <> 0
					lValidCoin	:= .T.
				EndIf
			Else
				If TMP->(Ctb105Get("CT2_VALR"+cCoin4)) <> 0
					lValidCoin  := .T.
				EndIf
			EndIf

			If lCallEfet				/// Se for chamada, pela tela de lancto na efetivação.
				lValidCoin	:= .F.
			Else
				lValidCoin	:= .F.

				If nCont == 1	// Na moeda 01
					If TMP->CT2_RECNO > 0
						CT2->(MsGoTo(TMP->CT2_RECNO))
						cTpSaldoAnt := CT2->CT2_TPSALD
						If TMP->CT2_RECNO == CT2->(Recno())
							/// Se o lançamento da moeda 01 já existe
							cKeyLin := CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_TPSALD+CT2_EMPORI+CT2_FILORI)
							If TMP->CT2_VALOR <> CT2->CT2_VALOR // e mudou o valor do lançamento
								lValidCoin := .T.
							EndIf

							If !lValidCoin
								If Len(CtbMudouL(,,CT2->(Recno()) )) > 0
									lValidCoin := .T.
								EndIf
							EndIf

						Else
							// Se o lançamento da moeda 01 não existe
							If TMP->CT2_VALOR <> 0
								lValidCoin := .T.
							EndIf
						EndIf
					Else	// Se o lançamento da moeda 01 não existe
						If TMP->CT2_VALOR <> 0
							lValidCoin := .T.
						EndIf
					EndIf
				Else		// Nas moedas de conversão 0X
					nVlrLan := TMP->(Ctb105Get("CT2_VALR"+cCoin4))
					dbSelectArea("CT2")
					dbSetOrder(1)
					If Empty(cKeyLin)
					   cKeyLin := xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+cLinha+TMP->(CT2_TPSALD+CT2_EMPORI+CT2_FILORI)
					EndIf
					If MsSeek(cKeyLin+cCoin4,.F.)
					   cTpSaldoAnt := CT2->CT2_TPSALD
					   If nVlrLan <> CT2->CT2_VALOR
							lValidCoin := .T.
					   EndIf

						If !lValidCoin
							If Len(CtbMudouL(,,CT2->(Recno()) )) > 0
								lValidCoin := .T.
							EndIf
						EndIf

					Else
						If nVlrLan <> 0
							lValidCoin	:= .T.
						EnDif
					EndIf
				EndIf
			EndIf

			If lValidCoin
				// Verifica CTO e 			no CTP ausência ou bloqueios.
				lOkCTOCTP	:= (Ascan(aCTOCTPOk,cCoin4) > 0)
				If !lOkCTOCTP .And. (!CTBMInUse(cCoin4) .Or. !CtbDtInUse(cCoin4,dDataLanc)) .And. TMP->(Ctb105Get("CT2_VALR"+cCoin4)) <> 0
					Aadd(aErro,19)
					lRet   := lTodas
					If lRpc
						Help( " ", 1, "CT2_VLR"+cCoin4 )
					EndIf
					If !lTodas
						Exit
					EndIf
				Else
					If !lOkCTOCTP
						AAdd(aCTOCTPOk,cCoin4)
					Endif

					If !Empty(cTpSaldoAnt)
						If !CtbDtComp(3,dDataLanc,cCoin4,,cTpSaldoAnt)
					    	lRet := .F.
					    	Exit
						EndIf
					EndIf

					// Verifica CTG ausencia ou bloqueio de calendário.
					If AScan(aMoedaOk, {|x| x[1] + IIF(lVldTps,x[2],"") == cCoin4 + IIF(lVldTps,cTpSald,"")} ) == 0
						If CtbDtComp(3,dDataLanc,cCoin4,,cTpSald)
							AAdd(aMoedaOk,{cCoin4,cTpSald})
						Else
							Aadd(aErro,19)
							lRet   := lTodas
		 					If !lTodas
								Exit
							EnDif
						EnDif
					Endif
				EndIf
			EndIf
		Next

	ElseIf nOpc == 5	/// Se for Exclusão
		For nCont := 1 to nQtdMoeda	/// Roda todas as moedas
			cCoin4 		:= alltrim(strzero(int(nCont),2))
			iF nCont == 1
				nVlrLan := TMP->CT2_VALOR
			Else
				nVlrLan := 	TMP->(Ctb105Get("CT2_VALR"+cCoin4))
			EndIf

			If nVlrLan <> 0 // Se houver valor
				// Verifica CTO e no CTP ausência ou bloqueios.
				lOkCTOCTP	:= (Ascan(aCTOCTPOk,cCoin4) > 0)
				If !lOkCTOCTP .And. (!CTBMInUse(cCoin4) .Or. !CtbDtInUse(cCoin4,dDataLanc))
					Aadd(aErro,19)
					lRet   := lTodas
					If lRpc
						Help( " ", 1, "CT2_VLR"+cCoin4 )
					EndIf
					If !lTodas
						Exit
					EndIf
				Else
					If !lOkCTOCTP
						AAdd(aCTOCTPOk,cCoin4)
					Endif
					// Verifica CTG ausencia ou bloqueio de calendário.
					If AScan(aMoedaOk, {|x| x[1] + IIF(lVldTps,x[2],"") == cCoin4 + IIF(lVldTps,cTpSald,"")} ) == 0
						If CtbDtComp(3,dDataLanc,cCoin4,,cTpSald)
							AAdd(aMoedaOk,{cCoin4,cTpSald})
						Else
							Aadd(aErro,19)
							lRet   := lTodas
							If !lTodas
								Exit
							EnDif
						Endif
					EnDif
				EndIf
			EndIf
		Next
	EndIf
EndIf

If nOpc <> 5
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se Historico nao preenchido                         								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If Empty( cHist )
			If lRpc
				Help( " ", 1, "CTB105HIST" )
			EndIf
			cCampo := "CT2_HIST"
			lRet   := lTodas
			Aadd(aErro,3)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se eh lancamento de historico complementar, nao pode ter valor.						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If cDC == "4" .And. TMP->CT2_VALOR <> 0
			If lRpc
				Help ( " " ,1, "CONTHIST")
			EndIf
			cCampo := "CT2_VLR01"
			lRet   := lTodas
			Aadd(aErro,4)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se eh lancamento de historico complementar, nao pode ter conta prenchida.			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 If lRet
		If cDC == "4" .And. (!Empty(TMP->CT2_DEBITO) .Or. !Empty(TMP->CT2_CREDIT) .Or. !Empty(TMP->CT2_CCD) .Or.!Empty(TMP->CT2_CCC) .Or. ;
								!Empty(TMP->CT2_ITEMD) .Or. !Empty(TMP->CT2_ITEMC) .Or. !Empty(TMP->CT2_CLVLDB) .OR. !Empty(TMP->CT2_CLVLCR)  )
			If lRpc
				Help( " ",1,"HISTNOENT")
	  	 	EndIf
			If !Empty(TMP->CT2_DEBITO)
				cCampo := "CT2_DEBITO"
			ElseIf !Empty(TMP->CT2_CREDIT)
				cCampo := "CT2_CREDIT"
			ElseIf !Empty(TMP->CT2_CCD)
				cCampo := "CT2_CCD"
			ElseIf !Empty(TMP->CT2_CCC)
				cCampo := "CT2_CCC"
			ElseIf !Empty(TMP->CT2_ITEMD)
				cCampo := "CT2_ITEMD"
			ElseIf !Empty(TMP->CT2_ITEMC)
				cCampo := "CT2_ITEMC"
			ElseIf !Empty(TMP->CT2_CLVLDB)
				cCampo := "CT2_CLVLDB"
			ElseIf !Empty(TMP->CT2_CLVLCR)
				cCampo := "CT2_CLVLCR"
			Endif
			lRet	:= lTodas
			Aadd(aErro,5)
	    EndIf
	 EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloco de Valida‡oes Lancamentos a Debito                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> 5
	If lRet
		If cDC $ "13"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CONTA CONTABIL A DEBITO                                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta foi preenchida                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty( cDebito )
				If lRpc
					Help(" ", 1, "FALTA DEB" )
				EndIf
				cCampo := "CT2_DEBITO"
				lRet   := lTodas
				Aadd(aErro,6)
			Endif

			//-------------------------------------------------------------------------------
			//	Valida se no lancamento do tipo debito existem campos de credito preenchidos
			//  Validacao retirada por não estar de acordo com o documentacao do sistema
			//-------------------------------------------------------------------------------

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta existe e nao e sintetica                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				lRet:= ValidaConta(cDebito,"1",,,.T.,lRpc)
				If lRet
					If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
						lRet := ValidaBloq(cDebito,dDataLanc,"CT1",lRpc)
						If !lRet
							Aadd(aErro,7)
							lRet := lTodas
						EndIf
					EndIf
				Else
					If lEfetiva
						Aadd(aErro,20)
						lRet := lTodas
						If lRet .And. ValidaBloq(cDebito,dDataLanc,"CT1",lRpc)
							Aadd(aErro,7)
						EndIf
					EndIf
				EndIf
				If !lRet
					cCampo := "CT2_DEBITO"
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ DIGITO DE CONTROLE - CONTA DEBITO                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If lDigito

			  		dbSelectArea("CT1")
			   		dbSetOrder(1)
			   		MsSeek(xFilial()+TMP->CT2_DEBITO)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se lan‡amento e devedor e digito da conta nao preenchido                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty( cDCD )
						If lRpc
							Help( " ", 1, "DIG-DEBITO" )
						EndIf
						lRet := lTodas
						Aadd(aErro,8)
					ElseIf cDCD != CT1->CT1_DC
						If lRpc
							Help( " ", 1, "DIGITO" )
						EndIf
						lRet := lTodas
						Aadd(aErro,9)
					Endif
					If !lRet
						cCampo := "CT2_DCD"
					Endif
				EndIf
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CENTRO DE CUSTO - DEBITO                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lCusto
					If lRet
						lRet:= ValidaCusto(cContCCD,"1",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cContCCD,dDataLanc,"CTT",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cContCCD,dDataLanc,"CTT",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					Endif
					If !lRet
						cCampo := "CT2_CCD"
					Endif
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ITEM - DEBITO 		                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lItem
					If lRet
						lRet:= ValidItem(cItemD,"1",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cItemD,dDataLanc,"CTD",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cItemD,dDataLanc,"CTD",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					Endif
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CLASSE VALOR - DEBITO 		                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lCLVL
					If lRet
						lRet:= ValidaCLVL(cCLVLD,"1",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cCLVLD,dDataLanc,"CTH",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cCLVLD,dDataLanc,"CTH",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se as amarracoes estao corretas                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				lRet  := _CtbAmarr(.T., cDebito,cContCCD,cItemD,cCLVLD,.T.,lRpc,.T.)
				If !lRet .And. lEfetiva
					Aadd(aErro,10)
					lRet := lTodas
				EndIf
			EndIf

			//Valida informações complementares
			If ( lVAt ) .And. ( lRet )
				lRet := CTBValidAt( "DB", 2, cDebito, cContCCD, cItemD, cCLVLD )	//Função do CTBXFUNC.PRW
			Endif

   			// Valida Entidades Obrigatorias -> Ligacao entre Conta e demais entidades
			If lRet
				lRet  := CtbObrig(  cDebito,;
									cContCCD,;
									cItemD,;
									cCLVLD,;
									.T.,;
									"1",;
									lRpc,;
									cEnt05Db,;
									"",;
									cEnt05Db,;
									cEnt06Db,;
									cEnt07Db,;
									cEnt08Db,;
									cEnt09Db,,,;
									aAtivCT1, aAtivCTD, aAtivCTH, aAtivCTT )

				If !lRet .And. lEfetiva
					Aadd(aErro,11)
					lRet := lTodas
				EndIf
			EndIf

			//-------------------------------------------------------------------
			// Valida se a conta contábil permite lançamento de variação cambial
			//-------------------------------------------------------------------
			If lRet
				If !Empty(TMP->CT2_MOEFDB) .And. GetAdvFVal("CT1","CT1_PVARC",XFilial("CT1")+cDebito,1,"",.T.) == "2"
					lRet := .F.
					Help( " ", 1, "CT105LINOK",,STR0089 + RetTitle("CT2_MOEFDB"), 1, 0 ) //"A conta contábil débito está configurada para não permitir a geração de variação cambial. Verifique o cadastro da conta contábil ou o valor informado no campo "
				Endif
			EndIf

		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Bloco de Valida‡oes Lancamentos a Credito                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If cDC $ "23"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CONTA CONTABIL A CREDITO                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta foi preenchida                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty( cCredito )
				If lRpc
					Help( " ", 1, "FALTA CRD" )
				EndIf
				cCampo := "CT2_CREDIT"
				lRet   := lTodas
				Aadd(aErro,12)
			Endif

			//-------------------------------------------------------------------------------
			//	Valida se no lancamento do tipo credito existem campos de debito preenchidos
			//  Validacao retirada por não estar de acordo com o documentacao do sistema
			//-------------------------------------------------------------------------------

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a conta existe e nao e sintetica                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				lRet := ValidaConta(cCredito,"2",,,.T.,lRpc)
				If lRet
					If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
						lRet := ValidaBloq(cCredito,dDataLanc,"CT1",lRpc)
						If !lRet
							Aadd(aErro,7)
							lRet := lTodas
						EndIf
					EndIf
				Else
					If lEfetiva
						Aadd(aErro,20)
						lRet := lTodas
						If lRet .And. ValidaBloq(cCredito,dDataLanc,"CT1",lRpc)
							Aadd(aErro,7)
						EndIf
					EndIf
				EndIf
				If !lRet
					cCampo := "CT2_CREDIT"
				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ DIGITO DE CONTROLE - CONTA CREDITO                                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If lDigito
					dbSelectArea("CT1")
			   		dbSetOrder(1)
			   		MsSeek(xFilial()+TMP->CT2_CREDIT)


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se lan‡amento ‚ credor e digito da conta nao preenchido                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty( cDCC )
						If lRpc
							Help( " ", 1, "DIG-CREDIT" )
						EndIf
						lRet  := lTodas
						Aadd(aErro,13)
					ElseIf cDCC != CT1->CT1_DC
						If lRpc
							Help( " ", 1, "DIGITO" )
						EndIf
						lRet  := lTodas
						Aadd(aErro,9)
					Endif
					If !lRet
						cCampo := "CT2_DCC"
					Endif
				Endif
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CENTRO DE CUSTO - CREDITO                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lCusto
					If lRet
						lRet:= ValidaCusto(cContCCC,"2",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cContCCC,dDataLanc,"CTT",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cContCCC,dDataLanc,"CTT",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					Endif
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ ITEM - CREDITO		                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lItem
					If lRet
						lRet:= ValidItem(cItemC,"2",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cItemC,dDataLanc,"CTD",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
						Else
							If lEfetiva
								Aadd(aErro,20)
								lRet := lTodas
								If lRet .And. ValidaBloq(cItemC,dDataLanc,"CTD",lRpc)
									Aadd(aErro,7)
								EndIf
							EndIf
						EndIf
					Endif
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ CLASSE VALOR - CREDITO		                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If __lCLVL
					If lRet
						lRet := ValidaCLVL(cCLVLC,"2",,,.T.,lRpc)
						If lRet
							If nOpc == 7 .OR. FunName() <> "CTBA102" .OR. FunName() <> "CTBA103" .Or. lEfetiva
								lRet := ValidaBloq(cCLVLC,dDataLanc,"CTH",lRpc)
								If !lRet
									Aadd(aErro,7)
									lRet := lTodas
								EndIf
							EndIf
					Else
						If lEfetiva
							Aadd(aErro,20)
							lRet := lTodas
							If lRet .And. ValidaBloq(cCLVLC,dDataLanc,"CTH",lRpc)
						  		Aadd(aErro,7)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se as amarracoes estao corretas                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				lRet  := _CtbAmarr(.F., cCredito,cContCCC,cItemC,cCLVLC,.T.,lRpc,.t.)
				If !lRet .And. lEfetiva
					Aadd(aErro,10)
					lRet := lTodas
				EndIf
			EndIf

			//Valida informações complementares
			If ( lVAt ) .And. ( lRet )
				lRet := CTBValidAt( "CR", 2, cCredito, cContCCC, cItemC, cCLVLC )	//Função do CTBXFUNC.PRW
			Endif

			// Valida Entidades Obrigatorias -> Ligacao entre Conta e demais entidades
			If lRet

				lRet := CtbObrig(   cCredito,;
									cContCCC,;
									cItemC,;
									cCLVLC,;
									.T.,;
									"2",;
									lRpc,;
									cEnt05Cr,;
							   		"",;
									cEnt05Cr,;
									cEnt06Cr,;
									cEnt07Cr,;
									cEnt08Cr,;
									cEnt09Cr,,,;
									aAtivCT1, aAtivCTD, aAtivCTH, aAtivCTT )

				If !lRet .And. lEfetiva
					Aadd(aErro,11)
					lRet := lTodas
				EndIf
			EndIf

			//-------------------------------------------------------------------
			// Valida se a conta contábil permite lançamento de variação cambial
			//-------------------------------------------------------------------
			If lRet
				If !Empty(TMP->CT2_MOEFCR) .And. GetAdvFVal("CT1","CT1_PVARC",XFilial("CT1")+cCredito,1,"",.T.) == "2"
					lRet := .F.
					Help( " ", 1, "CT105LINOK",,STR0090 + RetTitle("CT2_MOEFCR"), 1, 0 ) //"A conta contábil crédito está configurada para não permitir a geração de variação cambial. Verifique o cadastro da conta contábil ou o valor informado no campo "
				Endif
			EndIf

		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se as moedas foram informados corretamente ( 1=S ou 2=N )                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. (cDebito == cCredito) .And. cDC == "3"
		lEqual := .T.

		If lEqual .And. __lCusto
			lEqual := Alltrim( cContCCD ) == Alltrim( cContCCC )
		Endif

		If lEqual .And. __lItem
			lEqual := Alltrim( cItemD ) == Alltrim( cItemC )
		Endif

		If lEqual .And. __lCLVL
			lEqual := Alltrim( cCLVLD ) == Alltrim( cCLVLC )
		Endif

		If lEqual .And. __lEnt05
			lEqual := Alltrim( cEnt05Db ) == Alltrim( cEnt05Cr)
		Endif

		If lEqual .And. __lEnt06
			lEqual := Alltrim( cEnt06Db ) == Alltrim( cEnt06Cr)
		Endif

		If lEqual .And. __lEnt07
			lEqual := Alltrim( cEnt07Db ) == Alltrim( cEnt07Cr)
		Endif

		If lEqual .And. __lEnt08
			lEqual := Alltrim( cEnt08Db ) == Alltrim( cEnt08Cr)
		Endif

		If lEqual .And. __lEnt09
			lEqual := Alltrim( cEnt09Db ) == Alltrim( cEnt09Cr)
		Endif

		If lEqual
			If lRpc
				Help(" ",1,"CTAEQUA123")
			Endif
			lRet := .F.
		Endif
		If !lRet .And. lEfetiva
			Aadd(aErro,15)
			lRet := lTodas
		EndIf
	Endif
	// P.E. para validacao das entidades contabeis
	If 	lRet .And. lCT105VLENT
		lRet := ExecBlock("CT105VLENT",.F.,.F.,{cDC,cDebito,cCredito, cContCCD,cContCCC, cItemD,cItemC, cCLVLD,cCLVLC,;
		cEnt05Db,cEnt05Cr,cEnt07Db,cEnt07Cr,cEnt08Db,cEnt08Cr,cEnt09Db,cEnt09Cr})

		If !lRet
			Help(" ",1,"CTAEQUA123")
		Endif
	EndIf

	If lRet
		// Valida Debito
		If cDC == "1"

			If lVlTpPart .And. !Empty(cCredito)
				Help(" ",1,"NOENTDEB",,"Conta Credito " + STR0070, 1, 0 )
				lRet := .F.
			EndIf	

			If !Empty(cDebito) .And. (Empty(cContCCD) .And. !Empty(cContCCC))
				If lRpc
					Help(" ",1,"NOCTADEB")
				EndIf
				lRet  := .F.
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cItemD) .And. !Empty(cItemC))
					If lRpc
						Help(" ",1,"NOCTADEB")
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cClVlD) .And. !Empty(cClVlC))
					If lRpc
						Help(" ",1,"NOCTADEB")
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt05Db) .And. !Empty(cEnt05Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"05")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "05"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt06Db) .And. !Empty(cEnt06Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"06")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "06"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt07Db) .And. !Empty(cEnt07Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"07")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "07"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt08Db) .And. !Empty(cEnt08Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"08")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "08"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cDebito) .And. (Empty(cEnt09Db) .And. !Empty(cEnt09Cr))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"09")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "09"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTDEB",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				cCampo := "CT2_DEBITO"
				If lEfetiva
					Aadd(aErro,16)
					lRet := lTodas
				EndIf
			Endif
		EndIf

		// Valida credito
		If cDC == "2" .And. lRet

			If lVlTpPart .And. !Empty(cDebito)
				Help(" ",1,"NOENTCRD",," Conta Debito " + STR0070, 1, 0 )
				lRet := .F.
			EndIf	

			If !Empty(cCredito) .And. (Empty(cContCCC) .And. !Empty(cContCCD))
				If lRpc
					Help(" ",1,"NOCTACRD")
				EndIf
				lRet := .F.
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cItemC) .And. !Empty(cItemD))
					If lRpc
						Help(" ",1,"NOCTACRD")
					Endif
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cClVlC) .And. !Empty(cClVlD))
					If lRpc
						Help(" ",1,"NOCTACRD")
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt05Cr) .And. !Empty(cEnt05Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"05")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "05"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt06Cr) .And. !Empty(cEnt06Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"06")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "06"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt07Cr) .And. !Empty(cEnt07Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"07")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "07"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt08Cr) .And. !Empty(cEnt08Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"08")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "08"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCredito) .And. (Empty(cEnt09Cr) .And. !Empty(cEnt09Db))
					If lRpc
						dbSelectArea("CT0")
						dbSetOrder(1)
						If MsSeek(xFilial("CT0")+"09")
							cDsc := Alltrim(CT0->CT0_DESC)
						Else
							cDsc := STR0069 + " " + "09"	// "Entidade"
						EndIf
						Help(" ",1,"NOENTCRD",, cDsc + STR0070, 1, 0 )	//  " nao esta preenchida de acordo com o tipo do lançamento."
					EndIf
					lRet := .F.
				EndIf
			EndIf
			If !lRet
				cCampo := "CT2_CREDIT"
				If lEfetiva
					Aadd(aErro,17)
					lRet := lTodas
				EndIf
			Endif
		EndIf
	EndIf

	// validação do tipo de saldo, na rotina CTBA103 o tipo de saldo é fixo pelo parametro
	If lRet .And. !IsInCallStack("CTBA103")
		If ! VldTpSald( cTpSald )
			Help(" ",1,"NOSALD" , , "Tipo de Saldo inválido" ,3,0 )
			lRet := .F.
		ENDIF
	Endif

	If lRet
		If lCt105LOK
			lRet  := ExecBlock("CT105LOK",.F.,.F., {OPCAO , dDataLanc} )
         If !lRet .And. lEfetiva
				Aadd(aErro,18)
			EndIf
		Endif
	EndIf

	If lEfetiva .And. Len( aErro ) > 0
		lRet := .F.
	EndIf
EndIf

RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil 

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105TOK ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida toda MSGETDB                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CT105TOk(lCT105TOK,lCT105CHK,lModified,lDigitacao)   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1    =                                                  ³±±
±±³          ³ExpL2    =                                                  ³±±
±±³          ³ExpL3    = Se alterou                                       ³±±
±±³          ³ExpL4    = Se apresenta mensagem de confirmacao             ³±±
±±³          ³aTotRdpe = Array com os totais de rodape                    ³±±
±±³          ³nTotInf  = Valor informado no total do documento            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT105TOk(lCT105TOK As Logical,lCT105CHK As Logical,lModified As Logical,lConfirma As Logical,aTotRdpe As Array,nTotInf As Numeric,nOpc As Numeric,cTpSaldo As Character,aValDif As Array) As Logical
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis.                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSaveArea		As Array
Local lRet			As Logical
Local uTot 					
Local nValDeb		As Numeric
Local nValCrd		As Numeric
Local nValLimit     As Numeric
Local aLimitDif     As Array
Local aDebCrd		As Array
Local nPosTPSLD		As Numeric
Local cCtbVldM		As Character
Local cCtbLimc      As Character
Local cCtbCenc   	As Character
Local nI			As Numeric
Local lContBat		As Logical
Local lContSb       As Logical
Local lExecMsg      As Logical
Local cQuery  		As Character
Local cNextAlias	As Character
Local lAtlLcto		As Logical
Local lSeqCorr		As Logical
Local cSegOfi 		As Character
Local cExConc 		As Character
Local aRetValC      As Array

Local aDadTmp 		As Array
Local lAvanca 		As Logical
Local cTabCTK		As Character
Local cTabCT2		As Character
Local lSimula 		As Logical
Local nRegAtivo		As Numeric
Local lDCDUso		As Logical
Local aResult		As Array
Local nX			As Numeric
Local lProcOK 		As Logical

Local lCond102   	As Logical
Local lCT105MS		As Logical
Local cCT2Error 	As Character
Local aCT2Error 	As Array
Local aErroTexto 	As Array
Local lCT2Error 	As Logical
Local cHistAvulso	As Character
Local lVldTps		As Logical
Local cTpSaldOk  	As Character
Local nRecnoTMP   	As Numeric
Local cSQLExec      As Character
Local nQry          as numeric 
Local nIncons	    as numeric
Local cVldDef 	    as Character
Local cQtdVld 	    as Character
Local lCTFBloq 		as Logical
Local cFuncao		as Character

aSaveArea		:= GetArea()
lRet			:= .T.
uTot 			:= {}
nValDeb			:= 0
nValCrd			:= 0
nValLimit     	:= 0
aLimitDif     	:= {}
aDebCrd			:= {}
nPosTPSLD		:= 1
cCtbVldM		:= GetNewPar( "MV_CTBVLDM" , '12222' ) // retorna em quais moedas o sistema efetuará a validação, DEFAULT somente moeda 01.
cCtbLimc      	:= GetNewPar( "MV_CTBLIMC" , '0' )
cCtbCenc   		:= GetNewPar( "MV_CTBCENC", '' )
nI				:= 0
lContBat		:= .T.
lContSb       	:= .T.
lExecMsg      	:= .T.
cQuery  		:=	""
cNextAlias		:= GetNextAlias()
lAtlLcto		:= aMVS[MV_ALTLCTO]
lSeqCorr		:= UsaSeqCor("CT2/CTK/CT5")
cSegOfi 		:= SuperGetMv( "MV_SEGOFI" , .F. , "0" )
cExConc 		:= SuperGetMv("MV_CTBVLDC" , .F. , "1" )
aRetValC      	:= {}

aDadTmp 		:= {}
lAvanca 		:= .F.
cTabCTK			:= "CTK"
cTabCT2			:= "CT2"
lSimula 		:= .F.
nRegAtivo		:= 0
lDCDUso			:= .F.
aResult			:= {}
nX				:= 0
lProcOK 		:= .T.

lCond102  		:= (cPaisLoc=="BRA" .And. FunName()=="CTBA102")
lCT105MS		:=  SUPERGETMV("MV_CT105MS", .F.,"S") == "S"
cCT2Error 		:= ""
aCT2Error 		:= {}
aErroTexto 		:= {}
lCT2Error 		:= CT2->(FieldPos("CT2_INCONS")) > 0 .And. CT2->(FieldPos("CT2_INCDET")) > 0
cHistAvulso		:= ""

cTpSaldOk  		:= ""
nRecnoTMP   	:= 0
lVldTps 		:= SuperGetMv("MV_CTBCTG",.T.,.F.)
nIncons			:= 0

cFuncao 	:= Upper( AllTrim( FunName() ) )
cVldDef   	:= Upper(SuperGetMv("MV_CTFBLOQ",.T.,"ALL"))
cQtdVld   	:= AllTrim(SuperGetMv("MV_CTVBLOQ",.T.,"111"))

If cVldDef == 'ALL'
    lCTFBloq := "1" $ cQtdVld
Else
    lCTFBloq := ("1" $ cQtdVld) .And. ( cFuncao $ Upper(cVldDef) )  
EndIf


If __lDCDUso == NIL
	__lDCDUso := CtbUso("CT2_DCD")
EndIf

lDCDUso     	:= __lDCDUso    //  Digito de Controle

DEFAULT lConfirma 	:= .T.
DEFAULT cTpSaldo	:= ""
DEFAULT aValDif 	:= {}

__lIntPOUI := IIf(__lIntPOUI != Nil, __lIntPOUI, .F.) //Integracao POUI
If lFromProcPOUI == Nil
	lFromProcPOUI := FwIsInCallStack("CTB102POUI") // Essa função é chamada nos fontes CTBA350 e CTBC020, essa variável é usada na função Ctb102Carr().
EndIf

If __lIntPOUI //POUI altera variaveis para armazenamento dos erros atraves do Help()
	Private lMsHelpBkp   := .F. 
	Private lMsErFileBkp := .F. 
	Private lMsErAutBkp  := .F. 
	
	If Type("lMsHelpAuto") != "U" 
		lMsHelpBkp := lMsHelpAuto		
	EndIf			
	If Type("lAutoErrNoFile") != "U" 
		lMsErFileBkp := lAutoErrNoFile
	EndIf
	If Type("lMsErroAuto") != "U" 
		lMsErAutBkp := lMsErroAuto
	EndIf

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .T.
EndIf

// carrego os valores para as outras moedas
uTot := CtbTotMov( .T. , cCtbVldM )

If __lConOutR == Nil
	__lConOutR := FindFunction("CONOUTR")
EndIf

If Empty(nOpc)
	If Type("OPCAO") <> "U" .and. ValType(OPCAO) == "N"
		DEFAULT nOpc		:= OPCAO
	Else
		DEFAULT nOpc		:= 3
	EnDiF
EndIf

If nOpc == 2 //Visualizar
	Return .T.
EndIf

If __lConOutR
	ConOutR("*105TOK*|INICIO VALIDACAO")
EndIf

If nOpc <> 5				///Se exclusão não entra
	If ValType(uTot) = "L"
		lRet := uTot
	Else
		nValDeb := uTot[1][2]
		nValCrd := uTot[1][3]
	Endif

	If lRet
		If Empty(cSubLote)
			Help(" ",1,"CT5LOTE1",,STR0018,1,0)//"O Sublote nao pode ficar em branco. Favor preenche-lo."
			lRet	:= .F.
		EndIf
	Endif
	//Validacion para Colombia
	If lRet .and. cPaisLoc=='COL'
		lRet := CT102LOK() //será chamado no fonte CTBXMI
	EndIf
EndIf

If lVldTps .AND. Empty(cTpSaldo) .AND. (nOpc == 5 .OR. nOpc == 7)	//Se for exclusão ou cópia

	nRecnoTMP   := TMP->(Recno())

    TMP->(DBGoTop())
	While TMP->(!Eof())
		If !Empty(TMP->CT2_TPSALD) .AND. !(TMP->CT2_TPSALD $ cTpSaldOk) .AND. !TMP->CT2_FLAG
			If !CtbValiDt(nOpc,dDataLanc,,TMP->CT2_TPSALD)
				lRet	:= .F.
				Exit
			EndIf
			cTpSaldOk += TMP->CT2_TPSALD //Preencho a variável pra validar apenas uma vez por tipo de saldo
		EndIf
		TMP->(dbSkip())
	EndDo
	
	dbSelectArea( "TMP" )
	TMP->(MsGoto(nRecnoTMP))//- volta para o registro posicionado 

ElseIf !CtbValiDt(nOpc,dDataLanc,,cTpSaldo)
	lRet	:= .F.
EndIf

If nOpc == 5			///Se for exclusão
	If lRet .And. lSeqCorr .And. cSegOfi == '5'
		Help(" ",1,"CORRNOEXC")
		lRet := .F.
	EndIf
	If lRet .And. (!CtbVldLP(dDataLanc,cLote,cSubLote,cDoc,nOpc,Nil,lSimula,cTabCTK,cTabCT2) .or. !CtbTmpBloq(dDataLanc,cLote,cSubLote,cDoc,nOpc,Nil,lSimula,cTabCTK,cTabCT2) .or. !Ctb102Alert())
		lRet := .F.
	EndIf
EnDif

If lRet .And. (nOpc == 4 .Or. nOpc == 5)///Se for exclusão ou Alteração
	// Validação para verificar se registro já esta conciliado
	If cExConc == '2' .Or. cExConc == '3'
		aRetValC := VldIDConc(dDataLanc,cLote,cSubLote,cDoc)
		lRet := aRetValC[1]
	EndIf
EndIF

If _lCT105REV
	lRet := ExecBlock("CT105REV",.f.,.f.,{dDataLanc,cLote,cSubLote,cDoc })
EndIf

If lRet .And. (nOpc == 4 .OR. nOpc == 5) .And. IsCtbJob()
	If __oQueryTdOk == Nil
		cQuery := " SELECT Count(1) CONTA "
		cQuery += " FROM "+RetSqlName("CQA")+" CQA"  
		cQuery += " WHERE CQA.CQA_FILIAL = ? "		// P1 xFilial( "CQA" )	 	
		cQuery += " AND CQA.CQA_FILCT2   = ? "		// P2 xFilial( "CT2" )
		cQuery += " AND CQA.CQA_DATA     = ? " 		// P3 dDataLanc   
		cQuery += " AND CQA.CQA_LOTE     = ? " 		// P4 cLote     
		cQuery += " AND CQA.CQA_SBLOTE   = ? "		// P5 cSubLote    
		cQuery += " AND CQA.CQA_DOC      = ? " 		// P6 cDoc    
		cQuery += " AND CQA.D_E_L_E_T_   = ? "	    // P7 DELETE
		cQuery := ChangeQuery(cQuery)

		__oQueryTdOk := FwExecStatement():New(cQuery)
	EndIf
	nQry := 1
	__oQueryTdOk:SetString(nQry++, xFilial( "CQA" )  )   // P1 xFilial( "CQA" )					
	__oQueryTdOk:SetString(nQry++, xFilial( "CT2" )  )   // P2 xFilial( "CT2" )					
	__oQueryTdOk:setString(nQry++, Dtos(dDataLanc) )  	 // P3 dDataLanc   				
	__oQueryTdOk:SetString(nQry++, cLote   )  			 // P4 cLote     	
	__oQueryTdOk:SetString(nQry++, cSubLote  )  		 // P5 cSubLote    	
	__oQueryTdOk:SetString(nQry++, cDoc  )  		 	 // P6 cDoc    
	__oQueryTdOk:SetString(nQry++, Space(1))             // P7 DELETE
	
	lRet	:= __oQueryTdOk:ExecScalar('CONTA') == 0

	If !lRet
		If lConfirma
			Help(" ",1,"DOCNAOATU",,"Documento aguardando" + CRLF + "processamento de sal-" + CRLF + "dos (Fila de saldos)." + CRLF + "Aguarde!",1,0)
			lRet :=  .F.
		Endif
	Endif
Endif

If lRet
	If CtbProcedBD()		
		nRecTMP := TMP->(Recno())
		//com procedure de validacao quando tmp eh criado no banco de dados
		//executa a procedure para validacao de todo arquivo TMP
		aResult	:= {}
		If lRet
			__cProcPai := "CTBA105B_31"+"_"+cEmpAnt
			aResult := TCSPExec( __cProcPai,  DTOS(dDataLanc), cFilAnt , If(FindFunction("CtbUseAmar"),CtbUseAmar(),"1") , If(__lDCDUso,'1','0') ,  __cArq1, If(lCTFBloq,'1','0'), cQtdVld)				
			
			If Empty(aResult) .Or. aResult[1] = "0"
				MsgAlert("Erro na Execucao da Procedure [Validacao Linha OK] : "+__cProcPai+tcsqlerror(),"Erro")
				lProcOK := .F.
			EndIf
		EndIf
		
		If lProcOK .and. !Empty(aResult[2])
			lRet := .F.
			If lCT105MS
				Help(" ",1,"ERRLCTO",, aResult[2] ,1,0 ) 
			EndIf
		EndIf
		
		If lProcOk .And. lRet
			aDadTmp := {}
			lAvanca := .F.						
			cHistAvulso	:= ""
			nRegAtivo := 0 

			If lSeqCorr
				If _oQryTdOk3 == Nil
					cQuery := "SELECT COUNT(1) ATIVOS FROM "+__cGetRealname
					cQuery += " WHERE CT2_FLAG = ? "
					cQuery += " AND D_E_L_E_T_ = ?"
					cQuery := ChangeQuery(cQuery)
					_oQryTdOk3 := FWExecStatement():New(cQuery)
				EndIf 
				nQry:= 1
				_oQryTdOk3:SetString(nQry++,'F')
				_oQryTdOk3:SetString(nQry++,Space(1))
				
				_oQryTdOk3:OpenAlias(cNextAlias)
				
				If (cNextAlias)->(!Eof())
					nRegAtivo := (cNextAlias)->ATIVOS
				EndIf 

				(cNextAlias)->(dbCloSeArea())
			EndIf

			nRecTMP := TMP->(Recno())
			TMP->(dbGotop())

			While TMP->(!Eof())
				//- valida o registro valido
				If !TMP->CT2_FLAG .And. Empty(cHistAvulso) // VALIDA SE É UM LANCAMENTO AVULSO DE COMPL. HISTORICO
					cHistAvulso := Iif(TMP->CT2_DC <> '4', "N", "S")							
					Exit 
				EndIf
				TMP->(dbSkip())
			EndDo
			
			dbSelectArea( "TMP" )
			TMP->(MsGoto(nRecTMP))//- volta para o registro posicionado 

		EndIf

	EndIf
	//modo normal sem procedure( lRet .And. ! CtbProcedBD() )  ou
	If ( lRet .And. ! CtbProcedBD() ) .OR. ( CtbProcedBD() .And. !lProcOK)  //se eh validacao por procedure e nao consegui executar
		dbSelectArea( "TMP" )
		nRecTMP := TMP->(Recno())

		aDadTmp := {}
		lAvanca := .F.				
		cHistAvulso	:= ""

		//Verifica na cópia entre filiais se o historico existe
		If FwIsInCallStack("Ctba102Cop") .And. !ValidaHist(TMP->CT2_HP)
			lRet := .F.
		EndIf

		dbGoTop()
		While TMP->(!Eof())					
			If lCond102
				// Se veio do CTBA102 e é Brasil, só valido se teve alteração na linha
				If TMP->MODIFIED == 1
					If CT105LINOK(,,,,nOpc) // Valida a Linha do Lançamento
						If lCT2Error //Se existirem inconsistencias nos totalizadores, grava campos de controle
							
							If "INFORMIX" $ __cSGBD
								RecLock("TMP", .F.)
									TMP->CT2_INCONS := '2'
									TMP->CT2_INCDET := ""
								TMP->(MsUnlock())
							Else
								cSQLExec := " UPDATE "+__cGetRealname+" SET CT2_INCONS = '2', CT2_INCDET = NULL "
								cSQLExec += " WHERE R_E_C_N_O_ = "+cValToChar(TMP->(Recno()))
							
								If TcSqlExec(cSQLExec) <> 0
									UserException('CT105TOk - 1'+CRLF+TcSqlError())
								EndIf 		
							EndIf
						EndIf		
					Else
						lRet := .F.
						Exit
					EndIf
				EndIf				
			Else 
				If CT105LINOK(,,,,nOpc)	// Valida a Linha do Lançamento
					If lCT2Error //Se existirem inconsistencias nos totalizadores, grava campos de controle
						
						If "INFORMIX" $ __cSGBD
							RecLock("TMP", .F.)
								TMP->CT2_INCONS := '2'
								TMP->CT2_INCDET := ""
							TMP->(MsUnlock())
						Else
							cSQLExec := " UPDATE "+__cGetRealname+" SET CT2_INCONS = '2', CT2_INCDET = NULL "
							cSQLExec += " WHERE R_E_C_N_O_ = "+cValToChar(TMP->(Recno()))
						
							If TcSqlExec(cSQLExec) <> 0
								UserException('CT105TOk - 1'+CRLF+TcSqlError())
							EndIf
						EndIf
					EndIf
				Else
					lRet := .F.
					If lCT2Error																		
						cCT2Error := ""
						aCT2Error := GetAutoGRLog()
						For nI := 1 To Len(aCT2Error)
							cCT2Error += aCT2Error[nI]+"|"
							cCT2Error := StrTran(cCT2Error, CHR(13)+CHR(10), "") //Remove quebra de linha
						Next nI

						If "INFORMIX" $ __cSGBD
							RecLock("TMP", .F.)
								TMP->CT2_INCONS := '1'
								TMP->CT2_INCDET := SubStr(cCT2Error, 1, Len(cCT2Error)-1)
							TMP->(MsUnlock())
						Else
							cSQLExec := " UPDATE "+__cGetRealname+" SET CT2_INCONS = '1', CT2_INCDET = "
							If __SgdbOra
								cSQLExec += " TO_BLOB(UTL_RAW.CAST_TO_RAW(RTRIM('"+SubStr(cCT2Error, 1, Len(cCT2Error)-1)+"'))) "
							ElseIf __SgdbPg
								cSQLExec += " CAST(RTRIM('"+SubStr(cCT2Error, 1, Len(cCT2Error)-1)+"') AS bytea) "
							Else
								cSQLExec += " CONVERT(varbinary(max), RTRIM('"+SubStr(cCT2Error, 1, Len(cCT2Error)-1)+"')) "
							EndIf
							cSQLExec += " WHERE R_E_C_N_O_ = "+cValToChar(TMP->(Recno()))
							
							If TcSqlExec(cSQLExec) <> 0
								UserException('CT105TOk - 2'+CRLF+TcSqlError())
							EndIf 		
						EndIf										
					Else
						Exit
					EndIf				
				EndIf		
			Endif

			If !TMP->CT2_FLAG
				nRegAtivo++
			EndIf

			If !TMP->CT2_FLAG .And. Empty(cHistAvulso) // VALIDA SE É UM LANCAMENTO AVULSO DE COMPL. HISTORICO
				If TMP->CT2_DC <> '4'
					cHistAvulso := "N"
				Else
					cHistAvulso := "S"	
				EndIf					
			EndIf
			TMP->(dbSkip())
		EndDo	
	EndIf

	If lSeqCorr .And. nRegAtivo > 0
		If !CTBVlSeqCr(dDataLanc,.F.)
			lRet	:= .F.
		EndIf
	EndIf

	If lRet
		If cHistAvulso == "S"
			Help(" ",1,"HISTAVULSO",, STR0124 ,3,0,NIL, NIL, NIL, NIL, NIL, {STR0125} ) // "Primeira linha não pode ser Continuação de Histórico." # "Informe outro tipo de lançamento Contábil." 
			lRet	:= .F.
		EndIf	
	EndIf

	dbSelectArea("TMP")
	dbGoto(nRecTMP)
EndIf

If nOpc <> 5				///Se exclusão não entra
	If lRet
		If aMvs[MV_CONTSB] = Nil
			lContSb 	:= IIF(SuperGetMv("MV_CONTSB") == "N",.T.,.F.)
			lContBat 	:= IIF(SuperGetMv("MV_CONTBAT") == "S",.T.,.F.)
		Endif

		// efetuo a validação para as moedas
		FOR nI := 1 To Len( uTot )
			
			aAdd(aValDif,{0,""})

			nValDeb := uTot[nI][2]
			nValCrd := uTot[nI][3]

			// não efetua a validação para valores zerados
			If nValDeb == 0 .And. nValCrd == 0
				LOOP
			Endif

			IF NoRound(Round(nValDeb,3)) != NoRound(Round(nValCrd,3))

				If lCT105TOK

					lRet := ExecBlock("CT105TOK",.f.,.f.,{nValDeb,nValCrd,;
															aTotRdpe[1][1],;
																nTotInf })
				Else

					If lContSb .And. lRet
						If lContBat		// So grava quando DOC batido
							aLimitDif := QuebraParam(cCtbLimc,";")

							If Len( aLimitDif ) >= nI
								nValLimit := Val(aLimitDif[nI])
							Else
								nValLimit := 0
							EndIf

							//Se o paramentro MV_CTBLIMC (nValLimit) for maior que zero não efetua a validação do parâmetro MV_CONTBAT
					 		If nValLimit > 0

				 				If !Empty(cCtbCenc)
									aCtbCenc := QuebraParam(cCtbCenc)
									lRet := CtbBenc(aCtbCenc)
								Else
									Help( " ", 1, "MV_CTBENC" )//"Favor informar o parâmetro MV_CTBCENC com as entidades contábeis!"
									lRet := .F.
								EndIf

								If lRet
									//Se a diferença for maior que o nValLimit não permitir o lançamento
									If ABS(NoRound(Round(nValCrd,3))- NoRound(Round(nValDeb,3))) > nValLimit
										Help(" ",1,"DIFLIMITE")//Diferença de Crédito e Débito é maior que o valor permitido no pârametro MV_CTBLIMC.
								 		lRet := .F.
								 	Else
								 		lExecMsg := .F.
										aValDif[nI,1] := ABS(NoRound(Round(nValDeb,3)) - NoRound(Round(nValCrd,3)))
								 		
										If nValDeb > nValCrd
											aValDif[nI,2] := "C"
								 		Else
											aValDif[nI,2] := "D"
								 		EndIf
										
									EndIf
								EndIf
							 Else
 								If lConfirma .Or. IsBlind()
									
									//So entra se controla o MV_CT105MS = S, integracao POUI ou Se vier das rotinas semelhantes a CTBA102(parametro nao tem efeito nessas rotinas).
									If ( lCT105MS  .Or. ( FunName() $ "CTBA101#CTBA102#CTBA103#CTBA104" .And. !lCT105MS ) .Or. __lIntPOUI)
										Help(" ",1,"DOCNOBAT")
									Endif

								Endif
								lRet := .F.
							EndIf

						Else
							If lConfirma
								lRet := MsgYesNo(OemToAnsi(STR0010),OemToAnsi(STR0011))   //"D‚bito e Cr‚dito n„o conferem !, Aceita Lan‡amento "###"Aten‡„o"
							Else
								//Se for execAuto da mensagem única, retorna .T.
								If IsIncallStack("CTBI102")
									lRet := .T.
								Else
									If ( lCT105MS  .Or. ( FunName() $ "CTBA101#CTBA102#CTBA103#CTBA104" .And. !lCT105MS ) .Or. __lIntPOUI )
										Help(" ",1,"DOCNOBAT")
									Endif
									lRet := .F.
								Endif
							Endif
						Endif
					EndIf

				EndIf

				If lRet .And. aMvs[MV_PRELAN] = "D"
					__PreLan := .T.		// Caso MV_PRELAN estiver indicado para
				EndIf					// Documentos inconsistentes

				If ! lRet
					Exit
				EndIf

			EndIf
		NEXT
	EndIf

	If lRet .and. SuperGetMV("MV_CONTSLD",.F.,"S") == "S"
		dbSelectArea("TMP")
		nRecTMP := TMP->(Recno())
		
		If _oQryTdOk1 == Nil
			cQuery := "SELECT CT2_DC, CT2_TPSALD, SUM(CT2_VALOR) CT2_VALOR "
			cQuery += " FROM ? "
			cQuery += " WHERE CT2_FLAG = ? "
			cQuery += " AND CT2_DC IN (?)"
			cQuery += " AND D_E_L_E_T_ = ? "
			cQuery += " GROUP BY CT2_DC, CT2_TPSALD"
			cQuery := ChangeQuery(cQuery)
			_oQryTdOk1 := FwExecStatement():New(cQuery)
		EndIf 
		nQry := 1 
		_oQryTdOk1:SetUnsafe(nQry++,__cGetRealname)
		_oQryTdOk1:SetString(nQry++,'F')
		_oQryTdOk1:Setin(nQry++,{'1','2','3'})
		_oQryTdOk1:SetString(nQry++,Space(1))
		
		_oQryTdOk1:OpenAlias(cNextAlias)
		
		
		While (cNextAlias)->(!Eof())
			nVLRDEB	:= 0
			nVLRCRD	:= 0

			If (cNextAlias)->CT2_DC$"13"
				nVLRDEB	:= (cNextAlias)->CT2_VALOR
			Endif
			If (cNextAlias)->CT2_DC$"23"
				nVLRCRD	:= (cNextAlias)->CT2_VALOR
			Endif

			nPosTPSLD := Ascan(aDebCrd,{|x| x[1] == (cNextAlias)->CT2_TPSALD})

			If nPosTpSLD > 0
				aDebCrd[nPosTpSLD][2] := aDebCrd[nPosTpSLD][2] + nVLRDEB
				aDebCrd[nPosTpSLD][3] := aDebCrd[nPosTpSLD][3] + nVLRCRD
			Else
				aAdd(aDebCrd,{(cNextAlias)->CT2_TPSALD,nVLRDEB,nVLRCRD})
			Endif
			(cNextAlias)->(dbSkip())
		EndDo
		
		(cNextAlias)->(dbCloSeArea())
		
		dbSelectArea("TMP")
		TMP->(MsGoTo(nRecTMP))
		
		For nPosTPSLD := 1 to Len(aDebCrd)
			If NoRound(Round(aDebCrd[nPosTPSLD,2],3)) != NoRound(Round(aDebCrd[nPosTPSLD,3],3))  .And. lExecMsg
				lRet := .F.
			Endif
		Next
		If !lRet
			If aMvs[MV_CONTSB] = Nil
				lContSb 	:= IIF(SuperGetMv("MV_CONTSB") == "N",.T.,.F.)
				lContBat 	:= IIF(SuperGetMv("MV_CONTBAT") == "S",.T.,.F.)
			Endif
			If lContSb
				If lContBat		// So grava quando DOC batido
					If lConfirma .Or. IsBlind()
						If ( lCT105MS  .Or. ( FunName() $ "CTBA101#CTBA102#CTBA103#CTBA104" .And. !lCT105MS ) .Or. __lIntPOUI )
							Help(" ",1,"DOCNOBAT")
						Endif
					Endif
					lRet := .F.
				Else
					If !lCT105TOK
						If lConfirma
							lRet := MsgYesNo(OemToAnsi(STR0010),OemToAnsi(STR0011))   //"D‚bito e Cr‚dito n„o conferem !, Aceita Lan‡amento "###"Aten‡„o"
						Else
							//Se for execAuto da mensagem única, retorna .T.
							If IsIncallStack("CTBI102")
								lRet := .T.
							Else
								Help(" ",1,"DOCNOBAT")
								lRet := .F.
							Endif
						Endif
					Endif
					If lRet .And. aMvs[MV_PRELAN] = "D"
						__PreLan := .T.	// Caso MV_PRELAN estiver indicado para
					Endif					// Documentos inconsistentes
				EndIf
			Else
				lRet := .T.
			EndIf
		EndIf
	Endif

	If lRet
		If lCT105CHK
			lRet := ExecBlock("CT105CHK",.F.,.F.,{lModified})
		EndIf
	EndIf

	If lRet
		If lCt105OutM
			lRet := ExecBlock("CTB105OUTM",.F.,.F.,{dDataLanc,cLote,cSubLote,cDoc})
		EndIf
	EndIf

	//ultima validacao customizada por usuario
	IF lCt105Pos
		lRet := ExecBlock("CT105POS",.f.,.f.,{lRet,lConfirma})
	Endif

	If FunName() $ "CTBA102#CTBA103#CTBA104" // No caso de lancamento manual, DEVE sempre manipular a getdados
		lAtlLcto := .T.
	EndIf

	If ! lRet .And. ! lAtlLcto .And. ! lFromProcPOUI // Caso lancamento invalido mas nao poder
		__PreLan := .T.								 // alterar, retorno verdadeiro para gravar
		lRet := .T.									 // como pre-lancamento
	Endif
	
	If lCT2Error //Se existirem inconsistencias nos totalizadores, grava campos de controle
		cCT2Error := ""
		aCT2Error := GetAutoGRLog()		
		If Len(aCT2Error) > 0			
			For nI := 1 To Len(aCT2Error)
				cCT2Error += aCT2Error[nI]+"|"
				cCT2Error := StrTran(cCT2Error, CHR(13)+CHR(10), "") //Remove quebra de linha
			Next nI
			
			While TMP->(!Eof())						
				If TMP->CT2_INCONS != "1"
					
					If "INFORMIX" $ __cSGBD
						RecLock("TMP", .F.)
							TMP->CT2_INCONS := '1'
							TMP->CT2_INCDET := SubStr(cCT2Error, 1, Len(cCT2Error)-1)
						TMP->(MsUnlock())
					Else					
						cSQLExec := " UPDATE "+__cGetRealname+" SET CT2_INCONS = '1', CT2_INCDET = "					
						If __SgdbOra
							cSQLExec += " TO_BLOB(UTL_RAW.CAST_TO_RAW(RTRIM('"+SubStr(cCT2Error, 1, Len(cCT2Error)-1)+"'))) "
						ElseIf __SgdbPg
							cSQLExec += " CAST(RTRIM('"+SubStr(cCT2Error, 1, Len(cCT2Error)-1)+"') AS bytea) "
						Else
							cSQLExec += " CONVERT(varbinary(max), RTRIM('"+SubStr(cCT2Error, 1, Len(cCT2Error)-1)+"')) "
						EndIf
						cSQLExec += " WHERE R_E_C_N_O_ = "+cValToChar(TMP->(Recno()))
						
						If TcSqlExec(cSQLExec) <> 0
							UserException('CT105TOk - 3'+CRLF+TcSqlError())
						EndIf
					EndIf
				EndIf

				TMP->(dbSkip())
			EndDo		
		EndIf		
	EndIf
EndIf

If __lIntPOUI	
	If Type("lMsHelpBkp") != "U"
		lMsHelpAuto := lMsHelpBkp
	EndIf
	If Type("lMsErFileBkp") != "U"
		lAutoErrNoFile := lMsErFileBkp
	EndIf
	If Type("lMsErAutBkp") != "U"
		lMsErroAuto := lMsErAutBkp
	EndIf
EndIf

If lRet .and. FunName() $ "PROJETOGESPLAN#FINI100G#FINITITG" .and. (Type("lMsErroAuto") != "U" .and. lMsErroAuto) 
	lMsErroAuto:= .F. //lançamento será cadastrado,nesse caso não retornar a execauto como erro para a gesplan
EndIf
aSize(aDebCrd,0)
aDebCrd := nil
aSize(aLimitDif,0)
aLimitDif := nil 
RestArea(aSaveArea)
aSize(aSaveArea,0)
aSaveArea := nil

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBTotMov ³ Autor ³ Simone Mie Sato       ³ Data ³ 06.04.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Soma o valor do temporario de digitacao (Baseado no CTK)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtbTotMov()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aTotMov                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBTotMov(lTudoOk,cMoedas)

Local _cAliasTOT:= Alias()
Local aTotMov 	:= {}
Local lPartDob 	:= .F.
Local aMoedas	:= {}
Local cMoedAux	:= ''
Local nValCt2 	:= 0
Local nRecTMP	:= 0
Local nI		:= 0
Local cQuery  
Local _QryCTBTot

DEFAULT lTudoOk := .F.
DEFAULT cMoedas := nil

If aMvs[MV_SOMA] = Nil	 //Determina se o lancam. tipo 3 ira ser somado 1 ou 2 vezes
	aMvs[MV_SOMA] := SuperGetMv("MV_SOMA")
Endif

If cMoedas == Nil
	aMoedas := {{'01' , .T.}}

	// adiciono uma linha o aTotMov
	Aadd( aTotMov , {0,0,0} )
Else
	cMoedAux := Alltrim( cMoedas )

	FOR nI := 1 TO Len( cMoedAux )
		aAdd( aMoedas , { StrZero(nI,2) , iif( Substr( cMoedAux ,1,1 ) == '1' , .T. , .F. ) } )

		cMoedAux := Substr( cMoedAux ,2 )

		// adiciono uma linha o aTotMov
		Aadd( aTotMov , {0,0,0} )
	NEXT

Endif

dbSelectArea("TMP")
nRecTMP := TMP->(RECNO())
TMP->(DbGoTop())

cQuery := "SELECT CT2_DC,SUM(CT2_VALOR) CT2_VALR01 "
FOR nI := 1 To Len( aMoedas )
	IF aMoedas[nI][2] == .T. // moedas que irão entrar na validação
		If !aMoedas[nI][1] == '01'
			cQuery += " ,SUM(CT2_VALR" + aMoedas[nI][1] +") CT2_VALR" + aMoedas[nI][1] 
		Endif
	EndIf 
Next nI 
cQuery += " FROM "+__cGetRealname
cQuery += " WHERE CT2_FLAG = ?"
cQuery += " AND D_E_L_E_T_ = ?"
cQuery += " GROUP BY CT2_DC"

_QryCTBTot := FwExecStatement():New(cQuery)
_QryCTBTot:SetString(1,'F')
_QryCTBTot:SetString(2,Space(1))

_QryCTBTot:OpenAlias("CTBTotMov")

While CTBTotMov->(!Eof())
	FOR nI := 1 To Len( aMoedas )

		IF aMoedas[nI][2] == .T. // moedas que irão entrar na validação
			nValCt2 := CTBTotMov->(Ctb105Get('CT2_VALR'+aMoedas[nI][1]))
		Else
			nValCt2 := 0
		Endif

		IF nValCt2 <> 0
			// verificação de debito e credito
			If CTBTotMov->CT2_DC == '3' .OR. CTBTotMov->CT2_DC == '1'
				aTotMov[nI][2] += nValCt2		 		// Valor a Debito
			Endif
			If CTBTotMov->CT2_DC == '3' .OR. CTBTotMov->CT2_DC == '2'
				aTotMov[nI][3] += nValCt2				// Valor a Credito
			Endif

			//Se o tipo do lancamento e 3, verifica o parametro MV_SOMA:caso seja 1, soma 1 vez
			//Se for igual a 2, soma 2 vezes no valor digitado.
			If CTBTotMov->CT2_DC == '3'
				lPartDob := .T.
			Endif

			If lPartDob
				If aMvs[MV_SOMA] == 1
					aTotMov[nI][1]+= nValCt2
				Elseif aMvs[MV_SOMA] == 2
					aTotMov[nI][1]+= (nValCt2 * 2)
				EndIf
			Else
				aTotMov[nI][1]+= nValCt2
			Endif
		Endif
	Next

	CTBTotMov->(dbSkip())
EndDo

CTBTotMov->(dbCloseArea())

_QryCTBTot:Destroy()

dbSelectArea("TMP")
TMP->(DbGoTo(nRecTMP))

If !Empty(_cAliasTOT)
	dbSelectArea(_cAliasTOT)
EndIf 

Return aTotMov

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CT105ATRDP³ Autor ³ Simone Mie Sato       ³ Data ³ 28.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao do Rodape, quando altera lote, data ou doc.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,aTotais,aTotRdPe)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = data do lancamento                                 ³±±
±±³          ³ ExpC1 = Lote                                               ³±±
±±³          ³ ExpC2 = SubLote                                            ³±±
±±³          ³ ExpC3 = Documento                                          ³±±
±±³          ³ ExpA1 = Array com os totais                                ³±±
±±³          ³ ExpA2 = Array com os totais do rodape                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct105AtRdp(dDataLanc,cLote,cSubLote,cDoc,aTotais,aTotRdPe)

Local aSaveArea := GetArea()
Local lRet 		:= .T.

aTotais         := Ctb050Tot(dDataLanc,cLote,cSubLote,cDoc)
aTotRdPe[2]		:= CTBTotMov()[1]

aTotRdPe[1][2] := aTotRdPe[2][2]
aTotRdPe[1][3] := aTotRdPe[2][3]
aTotRdPe[1][1] := aTotRdPe[2][1]

//Atualiza o rodape (refresh)
ctb050ImpT()

RestArea(aSaveArea)

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105Rpc ³ Autor ³ Simone Mie Sato       ³ Data ³ 22.08.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida toda MSGETDB                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB105RPC(lCT105TOK,lCT105CHK,lModified,lDigitacao)   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1    =                                                  ³±±
±±³          ³ExpL2    =                                                  ³±±
±±³          ³ExpL3    = Se alterou                                       ³±±
±±³          ³ExpL4    = Se apresenta mensagem de confirmacao             ³±±
±±³          ³aTotRdpe = Array com os totais de rodape                    ³±±
±±³          ³nTotInf  = Valor informado no total do documento            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105Rpc(lDigita, nQtdCntb)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis.                                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _cAlias       := Alias()
Local lRet			:= .T.
Local lCusto		:= CtbMovSaldo("CTT")
Local lItem 		:= CtbMovSaldo("CTD")
Local lClVl 		:= CtbMovSaldo("CTH")
Local lHelp			:= lDigita
Local cQuery   
Local cNextAlias
Local oQry105RPC
Local lTotaliza     := .T.

If nQtdCntb == nil 
	lTotaliza := .F. // indica que não existe o parametro nQtdCntb passado como referencias 
	nQtdCntb  := 0
EndIf 

//--------------------------------------------
//- Verificar se existe DC vazios
//--------------------------------------------
cQuery := "SELECT COUNT(1) EMPTY_DC FROM "
cQuery += __cGetRealname
cQuery += " WHERE CT2_FLAG = ?"
cQuery += " AND CT2_DC = ?"
cQuery += " AND D_E_L_E_T_ = ?"

oQry105RPC := FwExecStatement():New(cQuery)

oQry105RPC:SetString(1,'F')
oQry105RPC:SetString(2, Space(Len(TMP->CT2_DC)))
oQry105RPC:SetString(3, Space(1))

lRet := oQry105RPC:ExecScalar('EMPTY_DC') == 0 

oQry105RPC:Destroy()

If lRet 
	//--------------------------------------------
	//- Verificar se existe debito vazios
	//--------------------------------------------
	cQuery := "SELECT COUNT(1) EMPTY_DC FROM "
	cQuery += __cGetRealname
	cQuery += " WHERE CT2_FLAG = ?"
	cQuery += " AND CT2_DC IN (?)"
	cQuery += " AND CT2_DEBITO = ?"
	cQuery += " AND D_E_L_E_T_ = ? "

	oQry105RPC := FwExecStatement():New(cQuery)
	oQry105RPC:SetString(1,'F')
	oQry105RPC:Setin(2,{'1','3'})
	oQry105RPC:SetString(3, Space(Len(TMP->CT2_DEBITO)))	
	oQry105RPC:SetString(4, Space(1))
	lRet := oQry105RPC:ExecScalar('EMPTY_DC') == 0 

	oQry105RPC:Destroy()
EndIF

If lRet 
	//--------------------------------------------
	//- Verificar se existe crédito vazios
	//--------------------------------------------
	cQuery := "SELECT COUNT(1) EMPTY_DC FROM "
	cQuery += __cGetRealname
	cQuery += " WHERE CT2_FLAG = ?"
	cQuery += " AND CT2_DC IN (?)"
	cQuery += " AND CT2_CREDIT = ?"
	cQuery += " AND D_E_L_E_T_ = ?"
	oQry105RPC := FwExecStatement():New(cQuery)			
		
	oQry105RPC:SetString(1,'F')
	oQry105RPC:Setin(2,{'2','3'})
	oQry105RPC:SetString(3, Space(Len(TMP->CT2_CREDIT)))	
	oQry105RPC:SetString(4, Space(1))

	lRet := oQry105RPC:ExecScalar('EMPTY_DC') == 0 
	
	oQry105RPC:Destroy()
EndIF

//validação de conta dos movimeto DEBITO
If lRet 
	cQuery := "SELECT CT2_DEBITO "
	If lCusto
		cQuery += ", CT2_CCD"
	EndIf 
	If lItem 
		cQuery += ", CT2_ITEMD"
	EndIf 
	If lCLVL
		cQuery += ", CT2_CLVLDB"
	EndIf 
	cQuery += " FROM "
	cQuery += __cGetRealname
	cQuery += " WHERE CT2_FLAG = ?"
	cQuery += " AND CT2_DC IN (?)"
	cQuery += " AND D_E_L_E_T_ = ?"
	cQuery += " GROUP BY CT2_DEBITO "
	If lCusto
		cQuery += ", CT2_CCD"
	EndIf 
	If lItem 
		cQuery += ", CT2_ITEMD"
	EndIf 
	If lCLVL
		cQuery += ", CT2_CLVLDB"
	EndIf 
	oQry105RPC := FwExecStatement():New(cQuery)
	oQry105RPC:SetString(1,'F')
	oQry105RPC:Setin(2,{'1','3'})
	oQry105RPC:SetString(3,Space(1))

	cNextAlias := oQry105RPC:OpenAlias()
	
	While (cNextAlias)->(!Eof()) .and. lRet 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a conta existe e nao e sintetica                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			lRet:= ValidaConta((cNextAlias)->CT2_DEBITO,"1",,,.T.,.F.,lHelp)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CENTRO DE CUSTO - DEBITO                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .and. lCusto
			lRet:= ValidaCusto((cNextAlias)->CT2_CCD,"1",,,.T.,.F.,lHelp)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ITEM - DEBITO 		                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .and. lItem
			lRet:= ValidItem((cNextAlias)->CT2_ITEMD,"1",,,.T.,.F.,lHelp)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CLASSE VALOR - DEBITO 		                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .and. lCLVL
			lRet:= ValidaCLVL((cNextAlias)->CT2_CLVLDB,"1",,,.T.,.F.,lHelp)
		EndIf
		(cNextAlias)->(dbSkip())
	EndDo 

	(cNextAlias)->(dbCloseArea()) 
	oQry105RPC:Destroy()
EndIf 

//validação de conta dos movimeto CREDITO
If lRet 
	cQuery := "SELECT CT2_CREDIT"
	If lCusto
		cQuery += ", CT2_CCC"
	EndIf 
	If lItem 
		cQuery += ", CT2_ITEMC"
	EndIf 
	If lCLVL
		cQuery += ", CT2_CLVLCR"
	EndIf 
	cQuery += " FROM "
	cQuery += __cGetRealname
	cQuery += " WHERE CT2_FLAG = ?"
	cQuery += " AND CT2_DC IN (?)"
	cQuery += " AND D_E_L_E_T_ = ?"
	cQuery += " GROUP BY CT2_CREDIT "
	If lCusto
		cQuery += ", CT2_CCC"
	EndIf 
	If lItem 
		cQuery += ", CT2_ITEMC"
	EndIf 
	If lCLVL
		cQuery += ", CT2_CLVLCR"
	EndIf 
	oQry105RPC := FwExecStatement():New(cQuery)
	oQry105RPC:SetString(1,'F')
	oQry105RPC:Setin(2,{'2','3'})
	oQry105RPC:SetString(3,Space(1))
	
	cNextAlias := oQry105RPC:OpenAlias()

	While (cNextAlias)->(!Eof()) .and. lRet 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a conta existe e nao e sintetica                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			lRet := ValidaConta((cNextAlias)->CT2_CREDIT,"2",,,.T.,.F.,lHelp)
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CENTRO DE CUSTO - CREDITO                                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .and. lCusto
			lRet:= ValidaCusto((cNextAlias)->CT2_CCC,"2",,,.T.,.F.,lHelp)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ ITEM - CREDITO		                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .and. lItem
			lRet:= ValidItem((cNextAlias)->CT2_ITEMC,"2",,,.T.,.F.,lHelp)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ CLASSE VALOR - CREDITO		                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .and. lCLVL
			lRet:= ValidaCLVL((cNextAlias)->CT2_CLVLCR,"2",,,.T.,.F.,lHelp)
		EndIf

		(cNextAlias)->(dbSkip())
	EndDo 

	(cNextAlias)->(dbCloseArea()) 
	oQry105RPC:Destroy()
EndIf 

//-------------------------------------------------------------------------------------------------
//- verifica a necessidade de totalização da quantidade de registro pela passagem de referencia
//-------------------------------------------------------------------------------------------------
If lRet .and. lTotaliza
	//--------------------------------------------
	//- Totalização de registros 
	//--------------------------------------------
	cQuery := "SELECT COUNT(1) EMPTY_DC FROM "
	cQuery += __cGetRealname
	cQuery += " WHERE CT2_FLAG = ?"
	cQuery += " AND D_E_L_E_T_ = ?"
	oQry105RPC := FwExecStatement():New(cQuery)
	
	oQry105RPC:SetString(1,'F')	
	oQry105RPC:SetString(2,Space(1))

	nQtdCntb := oQry105RPC:ExecScalar('EMPTY_DC') 

	oQry105RPC:Destroy()
EndIf 

If !lRet
	__PreLan := .T.
Endif

//--------------------------------------------
//- verifica se existe alias salvo 
//--------------------------------------------
If !Empty(_cAlias)
	dbSelectArea(_cAlias)
EndIf 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT105SDEL ºAutor  ³Marcos S. Lobo      º Data ³  04/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a deleção de todas as linhas da tela de lancamentos º±±
±±º          ³contabeis (lancamento automatico).                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT105SDEL(nOpc)
Local lRet := .F.

If ValType(nOpc) <> "N" .or. nOpc == 2
	Return(lRet)
Endif

If MsgYesNo(STR0017)///"Deseja realmente deletar todas as linhas ?"
	dbSelectArea("TMP")
	dbGoTop()
	While !Eof()
		CT102DEL(nOpc, .F.)
		TMP->CT2_FLAG := .T.
		TMP->(dbSkip())
	EndDo
	dbSelectArea("TMP")
	dbGoTop()
	lRet := .T.
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105Flt ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca inconsistencias na GetDB e posiciona cursor          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA105                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105Flt(oGetDb,lAvan)

Local nColPos 	:= oGetDb:oBrowse:nColPos
Local nRowPos	:= oGetDb:oBrowse:nAt
Local nMaxPos	:= oGetDb:oBrowse:nLen
Local cCampo 	:=	""
Local nLimite	:= 0
Local nSkip		:= 0
Local cMsg		:= ""
Local nLinBrowse := 1

Default lAvan	:= .T.

nSkip	:= If(lAvan,1      ,-1)
nLimite := If(lAvan,nMaxPos, 1)

While ( lOk := CT105LINOK(@cCampo) )
	nLinBrowse:= oGetDb:oBrowse:nAt
	If ( oGetDb:oBrowse:nAt == nLimite )
		Exit
	Endif
	oGetDb:oBrowse:SKIP( nSkip )
	If oGetDb:oBrowse:nAt == nLinBrowse
		oGetDb:oBrowse:nAt := nLinBrowse+nSkip
	EndIf
	//oGetDb:oBrowse:Refresh()
Enddo
oGetDb:oBrowse:Refresh()
If lOk
	oGetDb:GoTo(nRowPos)
	cMsg := STR0022 + If( lAvan, STR0023, STR0024 ) //"Nenhuma inconsistencia "###"abaixo"###"acima"
	MsgInfo( cMsg )
Else
	nColPos	:=	Ascan(aHeader,{|x| alltrim(x[2])==cCampo})
	If nColPos > 0
		oGetDb:oBrowse:nColPos := nColPos
	Endif
Endif
oGetDb:oBrowse:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105FtBs³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro generico para posicionar o cursor no registro exato ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA105                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTB105FtBs(oGetDb,cFiltro,cTexto)

Local nColPos 	 := oGetDb:oBrowse:nColPos
Local nColPosOri := nColPos
Local nRowPos	 := oGetDb:oBrowse:nAt
Local nMaxPos	 := oGetDb:oBrowse:nLen
Local cMsg		 := ""
Local cCampo 	 :=	""
Local lFind		 := .F.
Local nOpc		 :=	1
Local aOpcoes	 :=	{STR0025,STR0026,STR0027,STR0028} //"Nova"###"Anterior"###"Proxima"###"Cancela"
Local nSkip		 := 0
Local nLimite	 := 0
Local nLinGDB    := 0

dbSelectArea("TMP")
If !Empty(cFiltro)
	nOpc	:=	Aviso('Pesquisa',cTexto,aOpcoes)
Endif
If nOpc <> 4
	If Empty(cFiltro).Or. nOpc == 1
		aFiltro := CTB105FlTl("TMP",@cFiltro,@cTexto)
		cFiltro	:=	aFiltro[1]
		cTexto	:=	aFiltro[2]
		nOpc	:=	aFiltro[3]
	Endif
	If nOpc == 2
		nSkip	:=	-1
		nLimite	:=	1
	ElseIf nOpc == 3
		nSkip	:=	1
		nLimite	:=	nMaxPos
	Else
		Return
	Endif

	If !Empty( cFiltro )
				nLinGDB := oGetDb:oBrowse:nAt
		oGetDb:oBrowse:SKIP(nSkip)
		While  !(lFind := &cFiltro)
			If nOpc == 2	
				nLinGDB--
				If nLinGDB<=nLimite
					Exit
				Endif			
			ElseIf nOpc == 3
				nLinGDB++			
				If nLinGDB>=nLimite
					Exit
				Endif			
			EndIf		
			
			oGetDb:oBrowse:SKIP(nSkip)			
		Enddo

		If !lFind
			cMsg := STR0029 //"Nenhum lancamento encontrado "
			If nOpc == 2
				cMsg += STR0024 //"acima"
			ElseIf nOpc == 3
				cMsg += STR0023 //"abaixo"
			Endif
			MsgInfo( cMsg )
			oGetDb:GoTo(nRowPos)
			oGetDb:oBrowse:nColPos := nColPosOri
		Else
			nColPos	:=	Ascan(aHeader,{|x| alltrim(x[2])==Alltrim(Left(cFiltro,10))})
			If nColPos > 0
				oGetDb:oBrowse:nColPos := nColPos
			Endif
		Endif
		oGetDb:oBrowse:Refresh()
	Endif
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB105FlTl³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro parecido com BuildExpr()							  ³±±
±±³          ³ Criado pela necessidade de se trabalhar com o Arq. TMP     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTBA105 e CTBA102                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CTB105FlTl(cAl,cExpFil,cTxtFil)

Local oDlgPesq
Local oBtna , oBtn  , oBtnOp, oBtne, oBtnOu
Local oMatch, oCampo, oOper , oExpr, oTxtFil
Local aCpos		:= {}
Local aCampo	:= {}
Local aStrOp	:= {}
Local cTitulo	:= ""
Local cCampo	:= ""
Local cExpr		:= ""
Local cOper		:= ""
Local nMatch 	:= 0
Local nA		:= 0
Local nOpc		:= 4

Private cAlias2	:= ""
Private cAlias	:= ""

Default cTxtFil := ""
Default cExpFil := ""
Default cAl		:= "TMP"
		cAlias	:= cAl
		cAlias2 := cAlias + "->"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campos do Localizador ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nA := 1 to Len(aHeader)
	AADD( aCpos , aHeader[nA][1] )
	AADD( aCampo,{aHeader[nA][2],aHeader[nA][1],.T.,"01",aHeader[nA][4],If(Empty(aHeader[nA][3]),Space(45),aHeader[nA][3]),aHeader[nA][8],aHeader[nA][5]})
Next nA

cTitulo := STR0021 //"Localizar"

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(cTitulo) FROM 000,000 TO 250,405 PIXEL

	aStrOp := { OemToAnsi(STR0030),OemToAnsi(STR0031),OemToAnsi(STR0032),OemToAnsi(STR0033),OemToAnsi(STR0034),OemToAnsi(STR0035),OemToAnsi(STR0036),OemToANsi(STR0037),OemToANsi(STR0038),OemToAnsi(STR0039)}
	//"Igual a"###"Diferente de"###"Menor que"###"Menor ou igual a"###"Maior que"###"Maior ou igual a"###"Cont‚m a express„o"###"N„o cont‚m"###"Est  contido em"###"N„o est  contido em"

	@ 05,005 SAY OemToAnsi(STR0040) SIZE 20,8 PIXEL OF oDlgPesq //"Campo:"
	@ 05,060 SAY OemToAnsi(STR0041) SIZE 30,8 PIXEL OF oDlgPesq //"Operador:"
	@ 05,115 SAY OemToAnsi(STR0042) SIZE 30,8 PIXEL OF oDlgPesq //"Express„o:"
	@ 50,005 SAY OemToAnsi(STR0043) SIZE 20,8 PIXEL OF oDlgPesq //"Filtro:"

	@ 35,005 BUTTON oBtna PROMPT OemToAnsi(STR0044) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Adiciona"
		ACTION (cTxtFil := BuildTxt(cTxtFil,Trim(cCampo),cOper,cExpr,.t.,@cExpFil,aCampo,oCampo:nAt,oOper:nAt),cExpr := CalcField(oCampo:nAt,aCampo),BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq),oTxtFil:Refresh(),oBtne:Enable(),oBtnOp:Disable(),oBtnOu:Enable(),oBtna:Disable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh()) ;
		FONT oDlgPesq:oFont

	@ 35,45 BUTTON oBtn PROMPT OemToAnsi(STR0045) SIZE 35,10 OF oDlgPesq PIXEL ; //"&Limpa Filtro"
		ACTION (cTxtFil := "",cExpFil := "",nMatch := 0,oTxtFil:Refresh(),oBtnA:Enable(),oBtnE:Disable(),oBtnOu:Disable(),oMatch:Disable(),oBtnOp:Enable()) ;
		FONT oDlgPesq:oFont

	@ 30,175 BUTTON oBtnOp PROMPT OemToAnsi("(") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont ;
		ACTION (If(nMatch==0,oMatch:Enable(),nil),nMatch++,cTxtFil+= " ( ",cExpFil+="(",oTxtFil:Refresh()) ;

	@ 30,190 BUTTON oMatch PROMPT OemToAnsi(")") SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont;
		ACTION (nMatch--,cTxtFil+= " ) ",cExpFil+=")",If(nMatch==0,oMatch:Disable(),nil),oTxtFil:Refresh()) ;

	@ 45,175 BUTTON oBtne PROMPT OemToAnsi(STR0046) SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" E "
		ACTION (cTxtFil+=STR0046,cExpFil += ".and.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) ; //" e "

	@ 45,190 BUTTON oBtnOu PROMPT OemToAnsi(STR0047) SIZE 12,12 OF oDlgPesq PIXEL FONT oDlgPesq:oFont; //" OU "
		ACTION (cTxtFil+=STR0047,cExpFil += ".or.",oTxtFil:Refresh(),oBtne:Disable(),oBtnou:Disable(),oBtna:Enable(),oBtne:Refresh(),oBtnou:Refresh(),oBtna:Refresh(),oBtnOp:Enable()) //" ou "
	oMatch:Disable()

	cCampo := aCpos[1]
	@ 15,05 COMBOBOX oCampo VAR cCampo ITEMS aCpos SIZE 50,50 OF oDlgPesq PIXEL;
		ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)
	cExpr := CalcField(oCampo:nAt,aCampo)
	cOper := aStrOp[1]

	@ 15,60 COMBOBOX oOper VAR cOper ITEMS aStrOp SIZE 50,50 OF oDlgPesq PIXEL;
		ON CHANGE BuildGet(oExpr,@cExpr,aCampo,oCampo,oDlgPesq,,oOper:nAt)

`	@ 15,115 MSGET oExpr VAR cExpr SIZE 85,10 PIXEL OF oDlgPesq PICTURE AllTrim(aCampo[oCampo:nAt,6]) FONT oDlgPesq:oFont

	@ 60,05 GET oTxtFil VAR cTxtFil MEMO SIZE 195,40 PIXEL OF oDlgPesq READONLY
	oTxtFil:bRClicked := {||AlwaysTrue()}

	If Empty(cExpFil) .And. Empty(cTxtFil)
		oBtne:Disable()
		oBtnou:Disable()
	Else
		oBtna:Disable()
		oBtnOp:Disable()
		oMatch:Disable()
	Endif

	DEFINE SBUTTON o1 FROM 113,115  TYPE 20  ACTION (nOpc:=2,ValidText(@cExpFil,@cTxtFil),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o2 FROM 113,145  TYPE 19  ACTION (nOpc:=3,ValidText(@cExpFil,@cTxtFil),oDlgPesq:End()) OF oDlgPesq When .T.
	DEFINE SBUTTON o3 FROM 113,175  TYPE 02  ACTION (nOpc:=4                              ,oDlgPesq:End()) OF oDlgPesq When .T.

	o1:cToolTip := STR0048 //"Localizar Anterior"
	o2:cToolTip := STR0049 //"Localizar Proximo"

ACTIVATE MSDIALOG oDlgPesq CENTERED

Return {cExpFil,cTxtFil,nOpc }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³BuildTxt  ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BuildTxt(cTxtFil,cCampo,cOper,xExpr,lAnd,cExpFil,aCampo,nCpo,nOper)
Local cChar := OemToAnsi(CHR(39))
Local cType := ValType(xExpr)
Local aOper := { "==","!=","<","<=",">",">=","..","!.","$","!x"}

cTxtFil += cCampo+" "+cOper+" "+If(cType=="C",cChar,"")+cValToChar(xExpr)+If(cType=="C",cChar,"")

If cType == "C"
	If  aOper[nOper] == "!."    //  Nao Contem
		cExpFil += '!('+'"'+AllTrim(cValToChar(xExpr))+'"'+' $ '+aCampo[nCpo,1]+')'   // Inverte Posicoes
	ElseIf aOper[nOper] == "!x"   // Nao esta contido
		cExpFil += '!('+aCampo[nCpo,1]+" $ " + '"'+AllTrim(cValToChar(xExpr))+'")'
	ElseIf aOper[nOper]	== ".."  // Contem a Expressao
		cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'+" $ "+aCampo[nCpo,1] +" "   // Inverte Posicoes
	Else
		If (aOper[nOper]=="==")
			cExpFil += aCampo[nCpo,1] +aOper[nOper]+" "
			cExpFil += '"'+cValToChar(xExpr)+'"'
		Else
			cExpFil += 'Alltrim('+aCampo[nCpo,1] +')' +aOper[nOper]+" "
			cExpFil += '"'+AllTrim(cValToChar(xExpr))+'"'
		EndIf
	EndIf
ElseIf cType == "D"
	// Nao Mexer, deixar dToS pois e'a FLAG Para Limpeza do Filtro
	//
	cExpFil += "dToS("+aCampo[nCpo,1]+") "+aOper[nOper]+' "'
	cExpFil += Dtos(CTOD(cValToChar(xExpr)))+'"'
Else
	cExpFil += aCampo[nCpo,1]+" "+aOper[nOper]+" "
	cExpFil += cValToChar(xExpr)
EndIf

Return cTxtFil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CalcField ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcField(nAt,aCampo)

Local cRet

If aCampo[nAt,7] == "C"
	cRet := Space(aCampo[nAt,5])
ElseIf aCampo[nAt,7] == "N"
	cRet := 0
ElseIf aCampo[nAt,7] == "D"
	cRet := CTOD("  /  /  ")
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ValidText ³ Autor ³ Cristiano Denardi     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ajusta experessao de busca para que nao gere error.log     ³±±
±±³          ³ de Invalid Macro por inconsistencia.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CTB105FlTl                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidText(cExp,cTxt)

Local lValid := .F.

Default cExp := ""
Default cTxt := ""

If !Empty(cExp) .And. !Empty(cTxt)
	While !lValid
		Do Case
			Case Right(cTxt,2) == "( "
				cTxt := Left( cTxt, Len(cTxt)-3 )
			Case Right(cTxt,2) == "E "
				cTxt := Left( cTxt, Len(cTxt)-3 )
			Case Right(cTxt,3) == "OU "
				cTxt := Left( cTxt, Len(cTxt)-4 )
			Case Right(cExp,1) == "("
				cExp := Left( cExp, Len(cExp)-1 )
			Case Right(cExp,5) == ".and."
				cExp := Left( cExp, Len(cExp)-5 )
			Case Right(cExp,4) == ".or."
				cExp := Left( cExp, Len(cExp)-4 )
			Otherwise
				lValid := .T.
		End Case
	EndDo
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbMudouL ºAutor  ³Marcos S. Lobo      º Data ³  10/17/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se houve alteracao nas caracteristicas do lancto.  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP - Validacoes CTBA101, CTBA102, CTBA105 e CTBA350       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbMudouL(aNewCont,aOldCont,nRecOld)

/// SE HOUVEREM VARIAS MOEDAS CHAMAR UMA VEZ PARA CADA MOEDA (nRecOld muda)

Local aAreaOri		:= GetArea()
Local aAreaCT2		:= CT2->(GetArea())
Local aMudou		:= {}		///Retorno: Array com os campos alterados (se houver)
Local nField		:= 1

DEFAULT aNewCont	:= {}		///Conteudos Novos/Alterados
DEFAULT aOldCont	:= {}		///Conteudos Antigos/Originais
DEFAULT nRecOld		:= 0		///Numero do Registro Original no CT2 (presume-se TMP posicionado)

aCampos := {"CT2_DC",;
			"CT2_DEBITO","CT2_CREDIT",;
			"CT2_CCD","CT2_CCC",;
			"CT2_ITEMD","CT2_ITEMC",;
			"CT2_CLVLDB","CT2_CLVLCR",;
			"CT2_TPSALD"}

/// TENTA OBTER CONTEUDOS NOVOS PELO TMP POSICIONADO.
If Len(aNewCont) <= 0
	If Select("TMP") > 0
		For nField := 1 to Len(aCampos)
			aAdd( aNewCont, TMP->(Ctb105Get(aCampos[nField])))
		Next
	EndIf
EndIf

/// TENTA OBTER CONTEUDOS ANTIGOS PELO CT2 POSICIONADO.
If Len(aOldCont) <= 0			/// SE NAO VIEREM POR PARAMETRO DA FUNCAO
	If nRecOld > 0				/// VERIFICA SE PASSOU O RECNO() DO CT2 DE ORIGEM/ANTIGO
		CT2->(MsGoTo(nRecOld))
		If CT2->(Recno()) == nRecOld
			For nField := 1 to Len(aCampos)
				aAdd( aOldCont, CT2->(Ctb105Get(aCampos[nField])))
			Next
		EndIf
	ElseIf CT2->(!Eof())		/// SE NAO PASSOU ASSUME CT2 POSICIONADO.
		For nField := 1 to Len(aCampos)
			aAdd( aOldCont, CT2->(Ctb105Get(aCampos[nField])))
		Next
	EndIf
EndIf

/// VERIFICA SE EXISTEM DIFERENÇAS ENTRE OS CONTEUDOS NOVOS E OS ANTIGOS
For nField := 1 to Len(aCampos)
	If Len(aNewCont) < nField .or. Len(aOldCont) < nField
		Exit
	EndIf

	///VERIFICA SE HOUVE MUDANCA
	If ValType(aNewCont[nField]) <> ValType(aOldCont[nField])
		aAdd(aMudou,aCampos[nField])
	Else
		If aNewCont[nField] <> aOldCont[nField]
			aAdd(aMudou,aCampos[nField])
		EndIf
	EndIf
Next

RestArea(aAreaCT2)
RestArea(aAreaOri)

Return aMudou

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
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
Local aRotina :=	{	{ "aRotina Falso", "AxPesq",		0, 1 },;
						{ "aRotina Falso", "AxVisual",	0, 2 },;
						{ "aRotina Falso", "AxInclui",	0, 3 },;
						{ "aRotina Falso", "AxAltera",	0, 4 }}

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClearCx105ºAutor  ³Renato F. Campos    º Data ³  09/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa os caches utilizados pela rotina                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ClearCx105()

__aDtMedias := {}
__lConOutR	:= Nil

//Zera array estatico com as moedas ja validadas
aMoedaOk	:=	{}
aCTOCTPOk	:=	{}
aPerCache	:=  {}
__aCritPln := {}

// limpa a ctba101
ClearCx101()

// limpa a ctbxvld
ClearCxVld()

If FindFunction('CtbPerClear')
	CtbPerClear()  //limpa cache utilizada na funcao ctbperiodo s fonte ctbxctb
EndIf

If FindFunction('CtbClrCT0')
	CtbClrCT0()  //limpa cache utilizada na funcao CtbObrig Entid.Adic.
EndIf

If FindFunction('CtbClrTpSd')
	CtbClrTpSd()  //limpa cache utilizada na funcao VldTpSald
EndIf

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA105   ºAutor  ³Microsiga           º Data ³  08/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbLinMax(nMv_NumLin)
Local nRet := 0

If Len(CT2->CT2_LINHA) == 3
	If nMv_NumLin >= 35658  //limite estabelecido em razao do tamanho campo CT2_LINHA  = 3 e utilizar a funcao Soma1() para incremento
		nRet := 35658
	Else
		nRet := nMv_NumLin
	EndIf
Else
	nRet := nMv_NumLin
EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_CtbAmarr ºAutor  ³Microsiga           º Data ³  xx/xx/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function _CtbAmarr(lDebito,cConta,cCusto,cItem ,cCLVL,lPosiciona,lHelp,lValidLinOk,aEntidade)
Local xRetorno := .T.

If nQtdEntid == NIL
	nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
EndIf

If aCtbEntid == NIL
	aCtbEntid := aCtbEntidLoad()
EndIf

If nQtdEntid > 4 .And. Type( 'aCtbEntid' ) == 'A' .And. Len( aCtbEntid ) > 0
	xRetorno := CtbAmarr1( lDebito, lHelp ) // novo metodo de verificação da amarração
Else
	If nQtdEntid > 4
		Help(" ",1,"CT5ENT",,STR0061 + " " + STR0062 + " " + STR0063,1,0)//'A rotina utilizada está incompativel com a rotina atual de amarração.'##'O metodo antigo de verificação da amarração foi acionado.'##'Favor verificar a possibilidade de atualizar o ambiente SIGACTB!'
	Endif

	xRetorno := CtbAmarra(cConta,cCusto,cItem ,cCLVL,lPosiciona,lHelp,lValidLinOk) // metodo antigo de verificação da amarração
Endif

Return xRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbAmarr1 ºAutor  ³Microsiga           º Data ³  xx/xx/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbAmarr1(lDebito,lMessage)
Local aEntidades := {}
Local nX
Local abEntid
Local xRetorno	:= .F.

Default lMessage := .T.

IF Type( 'aCtbEntid' ) == 'A' .And. Len( aCtbEntid ) > 0
	//a variavel aCtbEntid eh private declarada nos fontes ctba101 / ctba102 / ctba105
	abEntid := aCtbEntid[ If(lDebito,1,2) ]

	For nX := 1 TO Len(abEntid)
		If lDebito   //debito
			aAdd(aEntidades, Eval(abEntid[nX]) )
		Else        //credito
			aAdd(aEntidades, Eval(abEntid[nX]) )
		EndIf
	Next

	xRetorno := CtbAmarra(aEntidades[1]/*cConta*/,aEntidades[2]/*cCusto*/,aEntidades[3]/*cItem*/,aEntidades[4]/*cCLVL*/,,lMessage,,aEntidades)
Else
	Help(" ",1,"NOAMARR1",, STR0064 + CRLF + STR0065 + CRLF + STR0066 + CRLF + 'SIGACTB!', 3,0 )  //'A rotina utilizada está'##'incompativel com a rotina atual.'##'Favor atualizar o ambiente'
Endif

Return xRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} CTB_IMPLANC
Função para impressão dos lançamentos contabeis online

@author Pedro Alencar
@since 02/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function CTB_IMPLANC()
	Local oReport As Object
	Local aMoedas As Array
	Local nOpcAvi As Numeric
	Local nRecAtu As Numeric

	oReport := Nil
	aMoedas := {}
	nOpcAvi := 0
	nRecAtu := TMP->(Recno())

	nOpcAvi := Aviso(OemToAnsi(STR0078), OemToAnsi(STR0079), {OemToAnsi(STR0080), OemToAnsi(STR0081)}) //'Selecionar Moedas', 'Deseja selecionar as moedas em que serão apresentados os valores? Caso clique em Não, será exibida apenas a moeda padrão.', 'Sim', 'Não'

	If nOpcAvi = 1
		aMoedas := GetMoedaCT()
	Else
		aadd(aMoedas,'01')
	Endif

	oReport := ReportDef(aMoedas)
	oReport:PrintDialog()

	oReport := Nil

	DBSelectArea("TMP")
	TMP->(DbGoTo(nRecAtu))

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Define a estrutura do relatório de contabilização online

@author Pedro Alencar
@since 02/01/2014
@version 12
@param aMoedas, Vetor com as moedas contábeis nas quais serão exibidos os valores
@return oReport, Objeto com a estrutura do relatório TReport
/*/
//-------------------------------------------------------------------------------
Static Function ReportDef(aMoedas)
	Local oReport
	Local oSection1
	Local oSection2
	Local nCount := 0
	Local cField := ""
	Local lValor := .F.
	//Vetores com os campos que serão carregados no relatório, por padrão
	Local aCab := {"CT2_DATA", "CT2_LOTE", "CT2_SBLOTE", "CT2_DOC"}
	Local aLcto := {"CT2_LINHA", "CT2_DC", "CT2_DEBITO", "CT2_CREDIT", "CT2_HIST", "CT2_CCD", "CT2_CCC", "CT2_CLVLDB", "CT2_CLVLCR", "CT2_TPSALD", "CT2_NODIA", "CT2_DIACTB"}

	oReport := TReport():New("CTB_IMPLANC", OemToAnsi(STR0082),,{|oReport| PrintReport(oReport,aMoedas)}, OemToAnsi(STR0083), .T.) //'lançamento Contábil', 'Impressão de Contabilização Online'

	//Cria as duas sessões do relatório
	oSection1 := TRSection():New(oReport,OemToAnsi(STR0084),"TMP",,.T.,.T.) //'Cabeçalho'
	oSection2 := TRSection():New(oReport,OemToAnsi(STR0085),"TMP",,.T.,.T.) //'Lançamentos'

	//Verifica se é pra adicionar o valor de outras moedas na secão 2
	If Len(aMoedas) > 0
		For nCount := 1 to Len(aMoedas)
			If aMoedas[nCount] == "01"
				//Valor na Moeda 1
				aAdd(aLcto, "CT2_VALOR")
			Else
				aAdd(aLcto, "CT2_VALR" + aMoedas[nCount])
			Endif
		Next nCount
	Else
		//Valor na Moeda 1
		aAdd(aLcto, "CT2_VALOR")
	Endif

	//Pega os campos da tabela temporária e cria uma cell para cada um deles
	For nCount := 1 To TMP->(FCOUNT())
		//Pega o nome do campo da tabela TMP
		cField := ALLTRIM(TMP->(FIELD(nCount)))

		//Verifica se é campo de valor, para fazer tratamentos em seguida
		If SubStr(cField, 5, 5) == "VALOR" .OR. SubStr(cField, 5, 4) == "VALR"
			lValor := .T.
		Else
			lValor := .F.
		Endif

		//Se for campo de valor, divide em dois campos, débito e crédito, para totalizar corretamente
		If lValor
			//Adiciona os campos de valor, dividindo em débito e crédito, em ambas as seções
			TRCell():New(oSection1,cField + OemToAnsi(STR0087),"TMP",AllTrim(RetTitle(cfield)) + OemToAnsi(STR0087),,,.F.,,,.T.) //'(DEB)'
			TRCell():New(oSection1,cField + OemToAnsi(STR0088),"TMP",AllTrim(RetTitle(cfield)) + OemToAnsi(STR0088),,,.F.,,,.T.) //'(CRED)'
			TRCell():New(oSection2,cField + OemToAnsi(STR0087),"TMP",AllTrim(RetTitle(cfield)) + OemToAnsi(STR0087),,,.F.,,,.T.) //'(DEB)'
			TRCell():New(oSection2,cField + OemToAnsi(STR0088),"TMP",AllTrim(RetTitle(cfield)) + OemToAnsi(STR0088),,,.F.,,,.T.) //'(CRED)'
			//Adiciona um totalizador para os campos de valores
			TRFunction():New(oSection2:Cell(cField + OemToAnsi(STR0087)),"Total","SUM",,,,,.F.,.T.,.F.) //'(DEB)'
			TRFunction():New(oSection2:Cell(cField + OemToAnsi(STR0088)),"Total","SUM",,,,,.F.,.T.,.F.) //'(CRED)'

			//Verifica se o campo deve aparecer, por padrão, na seção 1. Se não, deixa o campo selecionavel na personalização
			If aScan(aCab, Upper(cField)) > 0
				oSection1:Cell(cField + OemToAnsi(STR0087)):lEnabled := .T. //'(DEB)'
				oSection1:Cell(cField + OemToAnsi(STR0087)):lUserEnabled := .T. //'(DEB)'
				oSection1:Cell(cField + OemToAnsi(STR0088)):lEnabled := .T. //'(CRED)'
				oSection1:Cell(cField + OemToAnsi(STR0088)):lUserEnabled := .T. //'(CRED)'
			Else
				oSection1:Cell(cField + OemToAnsi(STR0087)):lEnabled := .F. //'(DEB)'
				oSection1:Cell(cField + OemToAnsi(STR0087)):lUserEnabled := .F. //'(DEB)'
				oSection1:Cell(cField + OemToAnsi(STR0088)):lEnabled := .F. //'(CRED)'
				oSection1:Cell(cField + OemToAnsi(STR0088)):lUserEnabled := .F. //'(CRED)'
			EndIf

			//Verifica se o campo deve aparecer, por padrão, na seção 2. Se não, deixa o campo selecionavel na personalização
			If aScan(aLcto, Upper(cField)) > 0
				oSection2:Cell(cField + OemToAnsi(STR0087)):lEnabled := .T. //'(DEB)'
				oSection2:Cell(cField + OemToAnsi(STR0087)):lUserEnabled := .T. //'(DEB)'
				oSection2:Cell(cField + OemToAnsi(STR0088)):lEnabled := .T. //'(CRED)'
				oSection2:Cell(cField + OemToAnsi(STR0088)):lUserEnabled := .T. //'(CRED)'
			Else
				oSection2:Cell(cField + OemToAnsi(STR0087)):lEnabled := .F. //'(DEB)'
				oSection2:Cell(cField + OemToAnsi(STR0087)):lUserEnabled := .F. //'(DEB)'
				oSection2:Cell(cField + OemToAnsi(STR0088)):lEnabled := .F. //'(CRED)'
				oSection2:Cell(cField + OemToAnsi(STR0088)):lUserEnabled := .F. //'(CRED)'
			EndIf
		Else //Outros campos que não são os valores do lançamento
			//Adiciona o campo em ambas as seções
			TRCell():New(oSection1,cField,"TMP",,,,.F.,,,.T.)
			TRCell():New(oSection2,cField,"TMP",,,,.F.,,,.T.)

			//Verifica se o campo deve aparecer, por padrão, na seção 1. Se não, deixa o campo selecionavel na personalização
			If aScan(aCab, Upper(cField)) > 0
				oSection1:Cell(cField):lEnabled := .T.
				oSection1:Cell(cField):lUserEnabled := .T.
			Else
				oSection1:Cell(cField):lEnabled := .F.
				oSection1:Cell(cField):lUserEnabled := .F.
			EndIf

			//Verifica se o campo deve aparecer, por padrão, na seção 2. Se não, deixa o campo selecionavel na personalização
			If aScan(aLcto, Upper(cField)) > 0
				oSection2:Cell(cField):lEnabled := .T.
				oSection2:Cell(cField):lUserEnabled := .T.
			Else
				oSection2:Cell(cField):lEnabled := .F.
				oSection2:Cell(cField):lUserEnabled := .F.
			EndIf
		Endif

	Next nCount

	//Impressão dos totalizadores por coluna
	oReport:SetTotalInLine(.F.)

	//Define o ajuste de tamanho automatico nas seções e a quebra de linha caso os campos ultrapassem o limite de tamanho da tela
	oSection1:SetAutoSize(.T.)
	oSection2:SetAutoSize(.T.)
	oSection1:SetLineBreak(.T.)
	oSection2:SetLineBreak(.T.)
Return oReport

//----------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Define a visualização dos registros do relatório de contabilização online

@author Pedro Alencar
@since 02/01/2014
@version 12
@param oReport, Objeto com a estrutura do relatório TReport
@param aMoedas, Vetor com as moedas contábeis selecionadas
/*/
//----------------------------------------------------------------------
Static Function PrintReport(oReport, aMoedas)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local aAreaAnt := TMP->(GetArea())
	Local cHistorico := ""
	Local lImprime := .F.
	Local lPrimeiro := .T.
	Local nAux := 0
	Local nCount := 0
	Local nRecHist := 0

	DbSelectArea("TMP")
	TMP->(DbGoTop())

	oSection1:Init()
	//Os campos do cabeçalho da tela de lançamentos são preenchidos com variáveis com os valores já tratados
	//Verifica se essas variáveis existem para pegar os seus valores e colocar no relatório, senão pega da tabela TMP
	Iif(Type("dDataLanc") == "U", oSection1:Cell("CT2_DATA"):SetValue(TMP->CT2_DATA), oSection1:Cell("CT2_DATA"):SetValue(dDataLanc))
	Iif(Type("cLote") == "U", oSection1:Cell("CT2_LOTE"):SetValue(TMP->CT2_LOTE), oSection1:Cell("CT2_LOTE"):SetValue(cLote))
	Iif(Type("cSubLote") == "U", oSection1:Cell("CT2_SBLOTE"):SetValue(TMP->CT2_SBLOTE), oSection1:Cell("CT2_SBLOTE"):SetValue(cSubLote))
	Iif(Type("cDoc") == "U", oSection1:Cell("CT2_DOC"):SetValue(TMP->CT2_DOC), oSection1:Cell("CT2_DOC"):SetValue(cDoc))
	oSection1:PrintLine()
	oSection1:Finish()

	oSection2:Init()
	//Imprime a seção 2 para cada registro contido na tabela TMP, com tratamento do histórico
	While TMP->(!EOF())

		If lPrimeiro .And. TMP->CT2_FLAG = .T. //Se o registro estiver apagado avanca e vai para proximo 
			TMP->( dbSkip() )
			Loop			
		EndIf

		nAux += 1

		//Se o registro não estiver apagado
		If TMP->CT2_FLAG = .F.
			//Se for complemento de histórico, não imprime a linha e concatena para imprimir quando acabar o histórico
			If TMP->CT2_DC == "4"
				lImprime := .F.
				While TMP->(!EOF() .And. TMP->CT2_DC == "4")
					If TMP->CT2_FLAG = .F. //Se o registro não estiver apagado
						cHistorico += ' ' + AllTrim(TMP->CT2_HIST)
					EndIf
					nRecHist := TMP->( Recno() )
					TMP->( dbSkip() )
					nAux += 1
				EndDo
				nAux -= 1
				TMP->( dbGoto(nRecHist) )  //volta para ultima cont historico pois logo abaixo vai sofrer dbskip novamente
			Else
				//Se não for continuação de histórico, verifica se é o primeiro lançamento a ser analisado
				If lPrimeiro = .T.
					cHistorico += ' ' + AllTrim(TMP->CT2_HIST)
					lImprime := .F.
					lPrimeiro = .F.
				Else //Se não é complemento de histórico nem é a primeira linha de lançamento, então já é outro lançamento (o lançamento anterior deve ser impresso agora)
					lPrimeiro := .T.
					lImprime := .T.
				Endif
			Endif

			//Se for pra imprimir, volta alguns registros na tabela temporária de acordo com a variavél auxiliar de controle de registros (nAux)
			//Volto os registros para que seja possível imprimir a linha correta com todo o histórico aglutinado
			If lImprime = .T.
				lImprime := .F.
				TMP->(DbSkip(-nAux+1))
				oSection2:Cell("CT2_HIST"):SetValue(cHistorico)

				//Se for débito, imprime o valor apenas no campo de débito criado para os campos de valores
				If TMP->CT2_DC == "1"
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(TMP->CT2_VALOR) //'(DEB)'
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(0) //'(CRED)'

					If Len(aMoedas) > 0
						For nCount := 1 to Len(aMoedas)
							If aMoedas[nCount] != "01"
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(TMP->(Ctb105Get("CT2_VALR" + aMoedas[nCount]))) //'(DEB)'
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(0)	//'(CRED)'
							Endif
						Next nCount
					Endif
				ElseIf TMP->CT2_DC == "2" //Se for crédito, imprime o valor apenas no campo de crédito criado para os campos de valores
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(0) //'(DEB)'
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(TMP->CT2_VALOR) //'(CRED)'

					//Verifica se vai imprimir os valores em outras moedas, com base no vetor de moedas contábeis selecionadas
					If Len(aMoedas) > 0
						For nCount := 1 to Len(aMoedas)
							If aMoedas[nCount] != "01"
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(0) //'(DEB)'
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(TMP->(Ctb105Get("CT2_VALR" + aMoedas[nCount]))) //'(CRED)'
							Endif
						Next nCount
					Endif
				Else //Se for partida dobrada, imprime o valor tanto no campo de débito quanto no de crédito, criados para os campos de valores
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(TMP->CT2_VALOR) //'(DEB)'
					oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(TMP->CT2_VALOR) //'(CRED)'

					//Verifica se vai imprimir os valores em outras moedas, com base no vetor de moedas contábeis selecionadas
					If Len(aMoedas) > 0
						For nCount := 1 to Len(aMoedas)
							If aMoedas[nCount] != "01"
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(TMP->(Ctb105Get("CT2_VALR" + aMoedas[nCount]))) //'(DEB)'
								oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(TMP->(Ctb105Get("CT2_VALR" + aMoedas[nCount]))) //'(CRED)'
							Endif
						Next nCount
					Endif
				Endif

				oSection2:PrintLine()
				cHistorico := ""
				TMP->(DbSkip(nAux-2))
				nAux := 0
			Endif
		Endif

		TMP->(DbSkip())

		//Se houve uma linha de lançamento (não complemento de histórico) e a tabela já está no final, então imprime a última linha
		If TMP->(EOF()) .AND. lPrimeiro = .F. .AND. TMP->CT2_FLAG = .F.
			TMP->(DbSkip(-1))  //adicionado -1 antes ...por algum motivo ao ser final de arquivo dbskip nao consegue voltar varias posições
			TMP->(DbSkip(-nAux +1))
			oSection2:Cell("CT2_HIST"):SetValue(cHistorico)

			//Se for débito, imprime o valor apenas no campo de débito criado para os campos de valores
			If TMP->CT2_DC == "1"
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(TMP->CT2_VALOR) //'(DEB)'
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(0) //'(CRED)'

				If Len(aMoedas) > 0
					For nCount := 1 to Len(aMoedas)
						If aMoedas[nCount] != "01"
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(TMP->(Ctb105Get("CT2_VALR" + aMoedas[nCount]))) //'(DEB)'
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(0)	//'(CRED)'
						Endif
					Next nCount
				Endif
			ElseIf TMP->CT2_DC == "2" //Se for crédito, imprime o valor apenas no campo de crédito criado para os campos de valores
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(0) //'(DEB)'
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(TMP->CT2_VALOR) //'(CRED)'

				//Verifica se vai imprimir os valores em outras moedas, com base no vetor de moedas contábeis selecionadas
				If Len(aMoedas) > 0
					For nCount := 1 to Len(aMoedas)
						If aMoedas[nCount] != "01"
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(0) //'(DEB)'
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(TMP->(Ctb105Get("CT2_VALR" + aMoedas[nCount]))) //'(CRED)'
						Endif
					Next nCount
				Endif
			Else //Se for partida dobrada, imprime o valor tanto no campo de débito quanto no de crédito, criados para os campos de valores
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0087)):SetValue(TMP->CT2_VALOR) //'(DEB)'
				oSection2:Cell("CT2_VALOR" + OemToAnsi(STR0088)):SetValue(TMP->CT2_VALOR) //'(CRED)'

				//Verifica se vai imprimir os valores em outras moedas, com base no vetor de moedas contábeis selecionadas
				If Len(aMoedas) > 0
					For nCount := 1 to Len(aMoedas)
						If aMoedas[nCount] != "01"
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0087)):SetValue(TMP->(Ctb105Get("CT2_VALR" + aMoedas[nCount]))) //'(DEB)'
							oSection2:Cell("CT2_VALR" + aMoedas[nCount] + OemToAnsi(STR0088)):SetValue(TMP->(Ctb105Get("CT2_VALR" + aMoedas[nCount]))) //'(CRED)'
						Endif
					Next nCount
				Endif
			Endif

			oSection2:PrintLine()
			TMP->(DbSkip(nAux))
		Endif
	EndDo

	TMP->(RestArea(aAreaAnt))
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaDif
Grava a diferença da contabilização incluindo uma linha nova.

@author David Moraes

@Return Nill
@since 11/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GravaDifCent(nValDif, cLancCont, aCTKxCT2, cTabCTK, cMoeda)
Local aArea		:= GetArea()
Local nLin		:= 0
Local lRet		:= .T.
Local cCtbCenc	:= GetNewPar( "MV_CTBCENC", '' )
Local cTpSald	:= ""
Local cHp		:= ""
Local cHpDesc	:= ""
Local cKey		:= ""
Local cSequen	:= ""
Local cTabOri	:= ""
Local cLote		:= ""
Local cRotina	:= ""
Local nRecOri	:= 0
Local dDtLanc	:= Ctod("//")
Local aRet		:= {}
Local lCTKxCT2	:= .F.

DEFAULT nValDif  := 0 
DEFAULT cLancCont:= ""
DEFAULT cTabCTK	 := ""
DEFAULT aCTKxCT2 := {}
DEFAULT cMoeda	 := ""

If !Empty(cCtbCenc)
	aRet := QuebraParam(cCtbCenc)
	lRet := CtbBenc(aRet)
Else
	Help( " ", 1, "MV_CTBENC" )//"Favor informar o parâmetro MV_CTBCENC com as entidades contábeis!"
	lRet := .F.
EndIf

If lRet
	lCTKxCT2 := !Empty(aCTKxCT2)
	If lCTKxCT2
		(cTabCTK)->(DbGoTo(aCTKxCT2[1,2,1]))
		cTabOri := (cTabCTK)->CTK_TABORI
		nRecOri := (cTabCTK)->CTK_RECORI
	Endif

	DbSelectArea( "TMP" )
	//Úlima linha
	TMP->(DbGoTop())
	While TMP->(!Eof())
		If !TMP->CT2_FLAG
			cTpSald := TMP->CT2_TPSALD
			cHp     := TMP->CT2_HP
			cHpDesc := TMP->CT2_HIST
			cKey 	:= TMP->CT2_KEY
			cSequen	:= TMP->CT2_SEQUEN
			dDtLanc	:= TMP->CT2_DATA
			cLote	:= TMP->CT2_LOTE
			cRotina	:= TMP->CT2_ROTINA
			nLin++
		EndIf
		TMP->(dbSkip())
	EndDo

	//Inclui uma linha nova
	DbGoTop()
	RecLock("TMP",.T.)

	cLinha := Soma1(Strzero(nLin,3))
	TMP->CT2_LINHA 	:= cLinha
	TMP->CT2_KEY	:= ckey
	TMP->CT2_SEQUEN	:= cSequen

	If cLancCont == "D"//Debito
		TMP->CT2_DC     := "1"
		TMP->CT2_DEBITO := aRet[1]
		TMP->CT2_CCD    := aRet[2]
		TMP->CT2_ITEMD  := aRet[3]
		TMP->CT2_CLVLDB := aRet[4]
		TMP->CT2_TPSALD := cTpSald
		TMP->CT2_HP     := cHp
		TMP->CT2_HIST   := cHpDesc

		If __lEnt05
			If !Empty(aRet[5])
				TMP->CT2_EC05DB := aRet[5]
			EndIf
		EndIf

		If __lEnt06
			If !Empty(aRet[6])
				TMP->CT2_EC06DB := aRet[6]
			EndIf
		EndIf

		If __lEnt07
			If !Empty(aRet[7])
				TMP->CT2_EC07DB := aRet[7]
			EndIf
		EndIf

		If __lEnt08
			If !Empty(aRet[8])
				TMP->CT2_EC08DB := aRet[8]
			EndIf
		EndIf

		If __lEnt09
			If !Empty(aRet[9])
				TMP->CT2_EC09DB := aRet[9]
			EndIf
		EndIf

	Else//Credito
		TMP->CT2_DC     := "2"
		TMP->CT2_CREDIT := aRet[1]
		TMP->CT2_CCC    := aRet[2]
		TMP->CT2_ITEMC  := aRet[3]
		TMP->CT2_CLVLCR := aRet[4]
		TMP->CT2_TPSALD := cTpSald
		TMP->CT2_HP     := cHp
		TMP->CT2_HIST   := cHpDesc

		If __lEnt05
			If !Empty(aRet[5])
				TMP->CT2_EC05CR := aRet[5]
			EndIf
		EndIf

		If __lEnt06
			If !Empty(aRet[6])
				TMP->CT2_EC06CR := aRet[6]
			EndIf
		EndIf

		If __lEnt07
			If !Empty(aRet[7])
				TMP->CT2_EC07CR := aRet[7]
			EndIf
		EndIf

		If __lEnt08
			If !Empty(aRet[8])
				TMP->CT2_EC08CR := aRet[8]
			EndIf
		EndIf

		If __lEnt09
			If !Empty(aRet[9])
				TMP->CT2_EC09CR := aRet[9]
			EndIf
		EndIf

	EndIf

	TMP->CT2_MOEDLC := cMoeda

	If cMoeda == '01'
		TMP->CT2_VALOR  := nValDif
	Else
		&("TMP->CT2_VALR"+cMoeda) := nValDif
	EndIf

	MsUnlock()

	If lCTKxCT2
		RecLock(cTabCTK,.T.)
		(cTabCTK)->CTK_FILIAL 	:= xFilial("CTK")
		(cTabCTK)->CTK_DATA		:= dDtLanc
		(cTabCTK)->CTK_SEQUEN	:= TMP->CT2_SEQUEN
		(cTabCTK)->CTK_DC		:= TMP->CT2_DC
		(cTabCTK)->CTK_LP		:= TMP->CT2_LP
		(cTabCTK)->CTK_LPSEQ	:= TMP->CT2_SEQLAN
		(cTabCTK)->CTK_KEY		:= TMP->CT2_KEY
		(cTabCTK)->CTK_DEBITO	:= TMP->CT2_DEBITO
		(cTabCTK)->CTK_CREDIT	:= TMP->CT2_CREDIT
		(cTabCTK)->CTK_VLR01	:= nValDif
		(cTabCTK)->CTK_HIST		:= TMP->CT2_HIST
		(cTabCTK)->CTK_HAGLUT	:= TMP->CT2_HIST
		(cTabCTK)->CTK_CCC		:= TMP->CT2_CCC
		(cTabCTK)->CTK_CCD		:= TMP->CT2_CCD
		(cTabCTK)->CTK_ITEMC	:= TMP->CT2_ITEMC
		(cTabCTK)->CTK_ITEMD	:= TMP->CT2_ITEMD
		(cTabCTK)->CTK_CLVLDB	:= TMP->CT2_CLVLDB
		(cTabCTK)->CTK_CLVLCR	:= TMP->CT2_CLVLCR
		(cTabCTK)->CTK_MOEDLC	:= TMP->CT2_MOEDLC
		(cTabCTK)->CTK_TPSALD	:= TMP->CT2_TPSALD
		(cTabCTK)->CTK_ROTINA	:= cRotina
		(cTabCTK)->CTK_LOTE		:= cLote
		(cTabCTK)->CTK_CONTAB	:= "2"
		(cTabCTK)->CTK_TABORI	:= cTabOri
		(cTabCTK)->CTK_RECORI	:= nRecOri
		MsUnLock()
		Aadd(aCTKxCT2,{TMP->(Recno()),{(cTabCTK)->(Recno())}})
	Endif
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QuebraParam
Efetua a quebra do valor em array de acordo com o delimitador informado no parametro.

@author David Moraes

@Return aRet retorna em forma de Array os valores informados no parametro.
@since 11/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function QuebraParam(cText, cChar)
Local nX       := 0
Local nPosIni  := 1
Local nPosFim  := 1
Local aRet     := {}

Default cChar      := ";"
Default cText      := ""

For nX :=  1 To Len(cText)

	nPosFim := AT(cChar, cText)
	If nPosFim > 0
		AADD(aRet,SubStr(cText,nPosIni,nPosFim-1))
		cText := SubStr(cText,nPosFim+1,Len(cText))
	Else
		If !Empty(cText)
			AADD(aRet,Alltrim(cText))
		EndIf

		Exit

	EndIf
Next nX

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbSetProcºAutor  ³Microsiga           º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Flag de variavel static para indicar se vai utilizar       º±±
±±º          ³ procedure para gravacao CT2 e validacao do TMP             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbSetProc(lUsaProced)

__lProcCtb	:= lUsaProced

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbCrTmpBDºAutor  ³Microsiga           º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Criacao do  tmp (tela de contabilizacao) direto no banco   º±±
±±º          ³ de dados                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbCrTmpBD()

Private aHeader := {}  //esta variavel sera utilizada na funcao Ctb105Head
Private aAltera := {}  //esta variavel sera utilizada na funcao Ctb105Head
/*
Monta aHeader para Lan‡amentos Contabeis 
nesta funcao Ctb105Head são carregado as variaveis static __aCampos / __aAltera / __aHeadCtb
que em uma segunda chamada carrega nas variaveis private aHeader  e aAltera da funcao ca100Incl
*/
Ctb105Head(@aAltera,.F./*lSimula*/)

//as variaveis static __aCampos / __cArq1 / __cArq2 são carregadas na função Ctb105Head chamada acima e na propria Ctb105Cria (arq1 e arq2)
Ctb105Cria(__aCampos)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbProcedBDºAutor  ³Microsiga          º Data ³  28/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna se arquivo tmp foi criado no banco                 º±±
±±º          ³ de dados                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbProcedBD()
Local lRet := .T.

lRet := __lProcCtb

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtdbAppendºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui registros na tabela TMP - Quando criada no banco     º±±
±±º          ³tem que utilizar RecLock para gravar recno no banco pois    º±±
±±º          ³este sera usada na procedure de gravacao da CT2             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtdbAppend()
//- cria o registro novo 
RecLock("TMP", .T.)
TMP->(MsUnLock())
RecLock("TMP", .F.)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbIniLan ºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inicializa variaveis para contabilizao com criacao de arq.  º±±
±±º          ³TMP no banco e cria as procedures de validacao e            º±±
±±º          ³gravacao CT2/CV3/TRW.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CtbIniLan()
Local cRotina as Caracter
Local lUseProc as Logical
Local lRet as Logical

cRotina := FunName()
lUseProc := SuperGetMv("MV_CTBUPRC",.T.,.F.)
lRet := .T.

If !lUseProc .And. cRotina$"MATA330/MATA331/MATA333/MATA038" //Se for contabilização do custo médio, verifico o parâmetro novo: MV_M33UPRC
	lUseProc := SuperGetMv("MV_M33UPRC",.T.,.F.)		
EndIf

//Se está em transação não posso executar pela procedure
If lUseProc .And. InTransact()
	lUseProc := .F.			
EndIf

If lUseProc
	CtbSetProc(lUseProc)          	//Seta a variavel static para informar que sera tratamento com procedure
	CtbCrTmpBD()			        //cria a tabela temporaria (tela de contabilizacao) 
	
	If FindFunction("CTBInstPRC")
		CTBInstPRC("31")
	EndIf
	
	lUseProc := TCSPExist("CTBA105A_31"+"_"+cEmpAnt)
	
	CtbSetProc(lUseProc) 
	
	lRet := lUseProc
Else
	CtbSetProc(lUseProc)         //lUseProc==FALSE - Seta a variavel static para indicar que nao usa procedure
	CtbCrTmpBD()			//cria a tabela temporaria  (tela de contabilizacao)
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbFinLan ºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Finalizacao de contabilizao - exlui o arquivo tmp criado    º±±
±±º          ³no banco e as procedures de validacao e gravacao CT2/CV3/TRWº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CtbFinLan()
Return Ct105VOrig()

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}Ct105VOrig
Retorna o estado original das variaveis static utilizada na rotina, principalmente 
CtbIniLan / Ctb105Head / Ctb105Cria
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Function Ct105VOrig()
//retorna as variaveis staticas ao seu valor original
__cArq1			:= ""
__cArq2			:= ""
__cProcAmar 	:= NIL
__cProcRegra 	:= NIL
__cProcPai 		:= NIL
__cProcGrv   	:= NIL
__cProcZero  	:= NIL
__cProcSoma1 	:= NIL
__cProcDoc  	:= NIL
__cProcFil      := NIL

__aCampos	    := Nil
__aAltera	    := Nil
__aHeadCtb	    := Nil
__nUsado 	    := Nil

//limpa arquivo temporario para quando voltar para outro documento 
If Select("TMP") > 0
	dbSelectArea( "TMP" )
	If Alias() == "TMP"
		Ctb_ZapTmp() //Zap
	EndIf
	TMP->( dbGotop() )
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBby_ProcºAutor  ³Microsiga           º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Criacao da procedure para gravacao dos movimentos contabeis º±±
±±º          ³CT2/CV3 e TRW para atualizacao dos saldos e chamada da      º±±
±±º          ³multithread para execucao da procedure                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CTBby_Proc(nOpc, lInclui, dDataLanc, cLote, cSubLote, cDoc, cFilOri, cEmpOri, cSequenc, ;
									lAglut, nContMoeda, cMoeda, aHeader, lAltTpSld, cProg, cSeqLan, cSeqLan01, ;
									nSeqHis, cSeqHis01, lFirstSq, lSeqCorr, cSeqCorr, lCusto,lItem,lCLVL, 	;
									nTotInf, lSimula, cTabCTK, cTabCT2,_lCTB185,__nQuantas,aTpSaldo,lAgruSld,lTrbProc,;
									cModoClr, cPreLcto , dReproc, cHoraLc, aAtuSaldos, cIdProcess)


Local lCT2_MLTSLD 	:= CT2->( FieldPos( "CT2_MLTSLD" ) ) > 0
Local lCT2_CTLSLD	:= CT2->( FieldPos( "CT2_CTLSLD" ) ) > 0
Local lCT2_DIACTB 	:= CT2->( FieldPos( "CT2_DIACTB" ) > 0 )
Local lGrvTRW 		:= _lctb185 .And. !lSimula
Local cManual		:= Iif(empty(cSequenc),"1","2")
Local lCTBA101 		:= ( cProg == 'CTBA101' )
Local lOutrMoeda	:= .F.
Local lPodeExc		:= .T.
Local lAtuProc		:= .F.
Local lOk 			:= .T.
Local lContinua		:= .T.
Local cMoedaOld
Local _lAtSldBase := .T.
Local _lReproc    := .F.
Local cQuery

Default lSeqCorr	:= ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
Default lSimula		:= .F.
Default cTabCTK		:= "CTK"
Default cTabCT2		:= "CT2"
Default cIdProcess  := ""

If __IsCtbJob  == NIL
	__IsCtbJob  := If( FindFunction( "IsCtbJob"), IsCtbJob() , .F. )
EndIf

lGrvTRW := lGrvTRW .And. ! __IsCtbJob

cMoedaOld := cMoeda

// VerIficacao para identIficar se grava na moeda 01 com Valor 0.00
lOutrMoeda   := CtbVOt_Moed(__nQuantas)
TMP->(dbGotop())
WHILE TMP->(!EOF()) .and. lContinua

	For nContMoeda := 1 To __nQuantas

		cMoeda := StrZero(nContMoeda,2)
		nValor := CtbGet_Valor(cMoeda, @cEmpOri, @cFilOri)
		nValorAnt:= 0 // SÓ CHAMA AQUI QDO FOR INCLUSAO, PORTANTO, VALOR ANTERIOR ZERADO SEMPRE!

        //armazena no array aAtuSaldos para posterior a gravacao do CT2 proceder atualizacao de saldos
		lContinua := CtbArmSald(nOpc, nOpc, aAtuSaldos, nContMoeda, cMoeda, lPodeExc, aTpSaldo, lAgruSld, ;
							lTrbProc, @lAtuProc, cModoClr, dReproc, nValor, nValorAnt, lSimula, cTabCTK, cTabCT2)

	Next nContMoeda

	TMP->(dbSkip())

EndDo

cMoeda := cMoedaOld

If lContinua

	// efetua a gravação do numero gerado, caso já exista o numero, ele  irá gerar um novo.
	If lSeqCorr
	 	cSeqCorr := CTBSQGrv( cSeqCorr ,dDataLanc )
	EndIf
	FreeUsedCode()  //libera codigos de correlativos reservados pela MayIUseCode()
	lOutrMoeda   := CtbVOt_Moed(__nQuantas)
	If __lConOutR
		ConOutR("CHAMA PROCEDURE DE GRAVACAO: "+TIME())
	EndIf
	//- garante que todos os registros travados sejam "gravados" dentro do banco 
	MsUnLockAll()

	aResult := TCSPExec( "CTBA105A_31"+"_"+cEmpAnt, ; // nome da procedure
			DtoS(dDataLanc),;
			cLote, ;
			cSubLote, ;
			cDoc, ;
			cFilOri, ;
			cEmpOri, ;
			cSequenc, ;
			iif(lAglut, '1', '0'), ;
			cProg, ;
			cSeqLan, ;
			iif(lSeqCorr, '1', '0'), ;
			cSeqCorr, ;
			iif(lCusto, '1', '0'),;
			iif(lItem, '1', '0'),;
			iif(lCLVL, '1', '0'),;				
			__nQuantas, ;
			xFilial("CT2"), ;
			cHoraLc,;
			cManual, ;
			iif(lCTBA101, '1', '0'), ;
			iif(lCT2_DIACTB, '1', '0'), ;
			iif(lCT2_MLTSLD, '1', '0'), ;
			iif(lCT2_CTLSLD, '1', '0'), ;
			Iif(lGrvTRW,'1', '0'),;
			cPreLcto ,;
			StrZero(ThreadID(),Len(CT2->CT2_ATIVDE)),;
			Iif(lSimula, '1', '0'),;
			Iif(nTotInf == NIL, 0,nTotInf),;
			Iif(_lAtSldBase, '1', '0'),;
			Iif(_lReproc, '1', '0'),;
			nOpc,;
			cFilAnt,;
			If (cIdProcess != "" ,cIdProcess,  "  "),;
			__cArq1,;
			CTBInTrans())	

	If __lConOutR
		ConOutR("FIM DA PROCEDURE DE GRAVACAO: "+TIME())
	EndIf

	If lOk .and. ( Empty(aResult) .or. aResult[1] != "1" )
		lOk:= .F.
		UserException( "Erro na procedure de contabilização! Por favor, entrar em contato com atendimento." + CRLF + TCSqlError()  + CRLF )
	Else
		//laco para ponto de entrada CTBGRV
		dbSelectArea("CT2")
		dbSetOrder(1)

		dbSeek( xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc+"001" )  //posicionar sempre na primeira linha
		
		If _lCtbGrv .And. !lSimula
			While CT2->( !Eof() .And. CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC == xFilial("CT2")+DTOS(dDataLanc)+cLote+cSubLote+cDoc )

				ExecBlock("CTBGRV",.f.,.f.,{nOpc,cProg,.T./*lProcedure*/,CT2->(Recno())/*nRecCT2*/})

				CT2->( dbSkip() )

			EndDo
		Endif
		
		cQuery := "UPDATE "+RetSqlName("CTK")
		cQuery += " SET CTK_RECDES = '"+Padr(cValToChar(CT2->(Recno())),Len(CTK->CTK_RECDES))+"'"
		cQuery += " WHERE CTK_FILIAL = '"+xFilial('CTK')+"'"
		cQuery += " AND CTK_SEQUEN = '"+cSequenc+"'"
		cQuery += " AND CTK_RECDES = '"+Space(Len(CTK->CTK_RECDES))+"'"
		cQuery += " AND CTK_DC IN ('1','2','3')"
		cQuery += " AND D_E_L_E_T_  = ' ' "
		If TcSqlExec(cQuery) <> 0 
			UserException('Update CTK'+CRLF+TcSqlError())
		EndIf 
		
	Endif
	
Endif

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbVOt_MoedºAutor  ³Microsiga          º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se valor positivo existe em outras moedas          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbVOt_Moed(nMoedas)
// VerIficacao para identIficar se grava na moeda 01 com Valor 0.00
Local lOutrMoeda   := .F.
Local nContMoeda
For nContMoeda 	:= 2 To nMoedas			//comecao o for a partir da segunda moeda
	If ! TMP->CT2_FLAG
		lOutrMoeda := TMP->(Ctb105Get("CT2_VALR" + StrZero( nContMoeda, 2 ))) > 0
    	If lOutrMoeda
    		Exit
    	EndIf
	EndIf
Next

Return(loutrMoeda)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbGet_ValorºAutor  ³Microsiga         º Data ³  13/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recupera o valor na moeda informada                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CtbGet_Valor(cMoeda, cEmpOri, cFilOri)
Local nValor := 0 

If !TMP->CT2_FLAG						////// SE NAO ESTIVER DELETADO NO TMP
	If cMoeda == '01'
		nValor	:= TMP->CT2_VALOR
		//Se estiver na empresa consolidadora, ira considerar os campos CT2_EMPORI e CT2_FILORI
		//da moeda 01. Caso inclua algum registro novo em outra moeda, ira gravar com o mesmo
		//conteudo da moeda 01.
		If !Empty(TMP->CT2_EMPORI) .And. !Empty(TMP->CT2_FILORI)
			cEmpOri	:= TMP->CT2_EMPORI
			cFilOri	:= TMP->CT2_FILORI
		EndIf
	Else
		nValor	:= TMP->(Ctb105Get("CT2_VALR"+cMoeda))
	EndIf
EndIf

Return(nValor)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³MyPesqPict  ³ Autor ³ Eduardo K.          ³ Data ³29/09/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento para evitar o desposicionamento de registros    ³±±
±±³          ³ ao executar a função PesqPict							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/

Static Function MyPesqPict(cTab,cCampo)

local cPict
Local aArea	   := GetArea()
Local aAreaSX3 := SX3->(GetArea())

cPict := PesqPict(cTab,cCampo)

RestArea(aAreaSX3)
RestArea(aArea)

Return cPict

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ C105DelTmp   ºAutor ³ TOTVS           º Data ³  06/02/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Excluir o TMP criado pela função CTB105Cria                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C105DelTmp()
//Deleta tabela temporaria no banco, caso ja exita
	If _oCTBA105 <> Nil
		_oCTBA105:Delete()
		_oCTBA105 := Nil
		__cGetRealname := ""
	Endif
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc}CTB105MVC
Função pra verificar se as rotinas (EXTERNAS) que utilizam as validações
constantes neste fonte (CTB105CTA / CTB105CC / CTB105Item / CTB105CLVL)
estão em MVC ou devem passar pela validação antiga.
@author Totvs
@since  29/06/2018
@version 12
/*/
Function CTB105MVC(lSetValue)

Default lSetValue := .F.

lRotMVC := lSetValue

Return lRotMVC
//-------------------------------------------------------------------
/*/{Protheus.doc}aCtbEntidLoad
Função que carrega array de entidades contábeis com bloco de código
para validação de amarração
@author Totvs
@since  10/10/2019
@version 12
//-------------------------------------------------------------------
/*/

Function aCtbEntidLoad()

Local nX

//Debito
aCtbEntid := Array(2,nQtdEntid)  //posicao 1=debito  2=credito

aCtbEntid[1,1] := {|| TMP->CT2_DEBITO 	}
aCtbEntid[1,2] := {|| TMP->CT2_CCD		}
aCtbEntid[1,3] := {|| TMP->CT2_ITEMD 	}
aCtbEntid[1,4] := {|| TMP->CT2_CLVLDB 	}
//Crédito
aCtbEntid[2,1] := {|| TMP->CT2_CREDIT }
aCtbEntid[2,2] := {|| TMP->CT2_CCC		}
aCtbEntid[2,3] := {|| TMP->CT2_ITEMC 	}
aCtbEntid[2,4] := {|| TMP->CT2_CLVLCR 	}

//Entidade adicionais
For nX := 5 TO nQtdEntid
	aCtbEntid[1, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"DB } ")  //debito
	aCtbEntid[2, nX] := MontaBlock("{|| TMP->CT2_EC"+StrZero(nX,2)+"CR } ")  //credito
Next

return aCtbEntid

/*/{Protheus.doc} RetAlgHist
Função para verificar se o lançamento será aglutinado por histórico.
@author  Totvs
@since   05/11/2019
@version 12
/*/
Static Function RetAlgHist()
Local lRet := .F.

If lMVAGLHIST == NIL
	lMVAGLHIST	:= GetNewPar("MV_AGLHIST",.F.) 
EndIf

If lMVAGLHIST
	lRet := .T.
Else
	If cMVAGLPROC == NIL
		cMVAGLPROC := UPPER(GetNewPar("MV_AGLPROC",""))
	EndIf
	lRet := (UPPER(AllTrim(FUNNAME()))$cMVAGLPROC)
EndIf

Return lRet

/*/{Protheus.doc} CtbChkDif
Verifica se existe diferença de centavos para ser lançada
@author  Totvs
@since   05/11/2019
@version 12
/*/
Function CtbChkDif(aValDif,aCTKxCT2,cTabCTK)
Local nI 		 := 0
DEFAULT aValDif  :={}
DEFAULT aCTKxCT2 :={}
DEFAULT cTabCTK  :=""

For nI := 1 to Len(aValDif)
	If aValDif[nI,1] > 0
		GravaDifCent(aValDif[nI,1],aValDif[nI,2], @aCTKxCT2,cTabCTK,StrZero(nI,2))
	EndIf
Next nI

Return

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}105LockFlg
Fazer o bloqueio dos Registros no módulo origem passadas pelo vetor aFlagCTB 
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Function _105LockFlg(aFlagCtb)
Local nX as Numeric
Local lRet as Logical

Default aFlagCTB := {}

SaveInter()
lRet := .T.
/*  ---------------------------------------------------
aFlagCTB[1][1] - Cpo da tabela a ser marcado na origem
aFlagCTB[1][2] - String a ser gravado no campo origem
aFlagCTB[1][3] - Alias da tabela da origem
aFlagCTB[1][4] - Recno da tabela Origem a ser marcado 
-----------------------------------------------------  */
// Verificar se pode ser alias diferente? se for
If Len(aFlagCtb) > 0
	If aFlagCTB[1][3] != NIL
		DbSelectArea((aFlagCTB[1][3]))
	Endif
	For nX := 1 to Len(aFlagCTB)
		/* Só faz SimpleLock se recebeu Alias e recno da origem 
		   Exemplo de processo que chega sem essas informações - Estorno de Pre Nota */
		If Len(aFlagCTB[nX]) > 0
			If aFlagCTB[nX][3] != NIL .and. aFlagCTB[nX][4] > 0  
				(aFlagCTB[nX][3])->(dbgoto(aFlagCTB[nx][4]))
				If !(aFlagCTB[nX][3])->(SimpleLock(aFlagCTB[nx][4]))
					Loop
				Endif
			EndIf
		EndIf
	Next
Endif
RestInter()
Return(lRet)

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}_105UnLckFlg
Fazer o desbloqueio dos Registros no módulo origem passadas pelo vetor aFlagCTB 
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Function _105UnLckFlg(aFlgSimple)
Local nX as Numeric
Default aFlgSimple := {}

SaveInter()
nX := 1
If Len(aFlgSimple) > 0
	For nX := 1 to Len(aFlgSimple)
		dbSelectArea(aFlgSimple[nX][1])
		(aFlgSimple[nX][1])->(dbgoto(aFlgSimple[nx][2]))
		If (aFlgSimple[nX][1])->(MsRUnLock(aFlgSimple[nx][2]))
			Loop
		Endif
	Next
Endif
RestInter()
Return()

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}CTBRetIdV
Retorna o ID da View para atualização em tempo de execução na conta reduzida
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------


Function CTBRetIdV(cCampo)
Local cIdView := ""
DEFAULT cCampo := ""

If !Empty(cCampo)
	If cCampo == "B1_CONTA"
		cIdView := "FORMSB1"
	EndIf
EndIf

Return cIdView


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}Ctb105STmp()
Seta o temporario criado na funcao ctb105cria para o alias TMP
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Function Ctb105STmp()

CtbChg_Tmp()

Return

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc}Ctb_ZapTmp()
Apaga todos os registros da tabela temporaria com _Zap_
Caso ca100Incl esteja em transacao temos que utilizar _Truncate_Table para bancos SQLServer e Oracle 
Para os demais vamos usar _DbDelete_ na tabela temporaria
Esta tabela somente atualmente recebe no maximo em torno de 35000 registros-retorno da funcao CtbLinMax

Funcao para chamar por exemplo CTBA102
@author Totvs
@since  31/03/2020
@version 12/*/
//-----------------------------------------------------------------------------------------
Function Ctb_ZapTmp()

CtbZap_Tmp("TMP")

Return

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}ChgFlag105(aFlagCTB,lCarga)
Função responsável por efetuar a carga do array aFlagCTB para acelerar o processo de ascan
aFlagCTB  - Array com os registro 
lCarga    - True indica que será iniciado a carga 
			False indica que é para liberar seu uso

@author Nilton Rodrigues - Engenharia
@since  07/10/2022
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function ChgFlag105(aFlagCTB,lCarga)
Local nX 
Local nTotal
Local cValor
If !lCarga //- reseta o objeto 
	oFlag105:fromJson("{}")
	FreeObj(oFlag105)
	oFlag105 := nil 
Else 
	//- tratamento para a segunda passagem 
	If oFlag105 == nil 
		oFlag105 := JsonObject():New()
	EndIf 
	nTotal := Len(aFlagCTB)
	For nX := 1 to nTotal
		cValor := cValToChar(aFlagCTB[nX][6]) //- converte em string para o Json
		//- verifica se o recno já existe 
		//- não existindo é guardado sua posição
		If oFlag105[cValor] == nil 
			oFlag105[cValor] := nX
		EndIf 
	Next nX
EndIf 
Return 

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc}DefMaxLinha(nCt2Linha)
Função responsável por verificar a quantidade de linhas a serem inseridas no documento
MAX_LINHA  - Array com conteudo dos parâmetros MV_NUMMAN, MV_NUMLIN
[1] -> MV_NUMLIN - Limita o numero de linhas do documento no lancamento contabil de integracao (automatico).
[2] -> MV_NUMMAN - Limita o numero de linhas do documento no lancamento contabil manual.
nCt2Linha - Contem a quantidade de linhas de contabilização do documento anterior
nQtdLinAtu - Após passar pelo TMP->(DbGoBottom()) essa varivel receberá a quantidade linhas do documento atual
nRecTotal - Contém a quantidade de linhas de contabilização dos documentos anteriores e atual de forma acumulada.
Exemplo: Documento 1 contabilizou 30 linhas, Documento 2 contabilizou 20 linhas, Documento atual contabilizou 5 linhas
Valor a ser atribuido na variavel: 57
nMaxLinha - Retorno

@author Vinícius Nascimento
@since  23/09/2024
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function DefMaxLinha(nCt2Linha as Numeric) as Numeric
Local nMaxLinha 	as Numeric
Local aArea 		as Array
Local nQtdLinAtu 	as Numeric
Local nRecTotal		as Numeric

Default nCt2Linha := 0

nMaxLinha 	:= MAX_LINHA[2]
aArea		:= TMP->(GetArea())

TMP->(DbGoBottom())

nQtdLinAtu 	:= Val(TMP->CT2_LINHA)
nRecTotal	:= TMP->(LastRec())

If nCt2Linha > 0
	If nQtdLinAtu >= MAX_LINHA[2] 
		nMaxLinha :=  MAX_LINHA[2]
	Else
		nMaxLinha :=  nRecTotal + ABS( MAX_LINHA[2] - nQtdLinAtu )
	EndIf 
EndIf

TMP->(DbGoTop())
RestArea(aArea)

Return nMaxLinha
//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} Ctb105Get(__cCampo)
Retorna o valor de um campo

__cCampo = Campo que o valor será retornado

@author TOTVS
@since  20/02/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function Ctb105Get(__cCampo)
Return FieldGet(FieldPos(__cCampo))
//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} CTB105Put(__cCampo, __xValue)
Atribui valor ao campo

__cCampo = Campo que o valor será atribuído
__xValue = Valor para atribuir

@author TOTVS
@since  20/02/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function CTB105Put(__cCampo,__xValue)
Return FieldPut(FieldPos(__cCampo),__xValue)

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} GetTextErr(cTexto)
Retorna a instrução com a sintaxe de cada banco

@author TOTVS
@since  20/02/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function GetTextErr(cCodErro)
DEFAULT cCodErro := ""
Return RetTextErr(cCodErro)

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} RetTextErr(nCodErro)
Retorna o código de erro para a procedure
nCodErro  - Código do erro CT2_VLD??

@author TOTVS
@since  20/02/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function RetTextErr(cCodInc)
DEFAULT __jErrorList := LoadJsonErr()
Return __jErrorList[cCodInc]


//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} LoadJsonErr()
Faz a carga do Json com erros

@author TOTVS
@since  20/02/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function LoadJsonErr()
Local aErrorList := {}
Local nI         := 0
DEFAULT __jErrorList := JsonObject():New()

aErrorList := ct350aerro()
For nI := 1 to Len(aErrorList)
	__jErrorList[cValToChar(nI)] := AllTrim(StrTran(StrTran(aErrorList[nI],CHR(13),""),CHR(10),""))
Next nI

Return __jErrorList

//------------------TRATAMENTOS PARA INSTALAÇÃO DO PROCESSO 31---------------------------//

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} CTBInTrans()
Retorna se existe transação aberta no momento

@author TOTVS
@since  25/08/2025
@version 12
*/
//-----------------------------------------------------------------------------------------
Static Function CTBInTrans
Return if(InTransAct(),'1','0')

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngSPS31Signature()
Controle de assinatura da procedure

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngSPS31Signature()	
Return "003"

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngPre31Compile()
Ponto de entrada antes da compilação da procedure, antes do MSParse

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngPre31Compile(cProcesso as character, cEmpresa as character, cError as character)
Local cNomeTab := "0_SP"

	If !TcCanOpen("TRW"+cEmpresa+cNomeTab)
		EngSPSWorkTable("CT2","TRW"+cEmpresa+cNomeTab,{},.F.)	
	EndIf

Return .T.

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngOn31Compile()
Ponto de durante a compilação da procedure, antes do MSParse

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngOn31Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character)
	Local cDeclare := ''
	Local cCpoCursor := ''
	Local cVarProc := ''
	Local cCamposProc := ''
	Local cVarGrvCps := ''
	Local cVarIni := ''

	If cProcName == 'CTBA105A'
		// Faz a troca das tags "###" nos nomes de tabelas especificas do processo
		cBuffer := StrTran( cBuffer, "TRW###", "TRW"+cEmpresa +'0' )
		CtbSetProc(.T.)		
		CtbCrTmpBD()//popula o __campos

		CtbPrep31( @cDeclare, @cCpoCursor, @cVarProc, @cCamposProc, @cVarGrvCps, .F. )
		If ! ( "@nCT2_VALR06" $ cDeclare )
			cDeclare	+= "Declare @nCT2_VALR06 float"+ CRLF
		EndIf
		If ! ( "@nCT2_VALR07" $ cDeclare )
			cDeclare	+= "Declare @nCT2_VALR07 float"+ CRLF
		EndIf
		If ! ( "@nCT2_VALR08" $ cDeclare )
			cDeclare	+= "Declare @nCT2_VALR08 float"+ CRLF
		EndIf
		If ! ( "@nCT2_VALR09" $ cDeclare )
			cDeclare	+= "Declare @nCT2_VALR09 float"+ CRLF
		EndIf
		If ! ( "@nCT2_VALR10" $ cDeclare )
			cDeclare	+= "Declare @nCT2_VALR10 float"+ CRLF
		EndIf
		If ! ( "@nCT2_VALR11" $ cDeclare )
			cDeclare	+= "Declare @nCT2_VALR11 float"+ CRLF
		EndIf
		If ! ( "@nCT2_VALR12" $ cDeclare )
			cDeclare	+= "Declare @nCT2_VALR12 float"+ CRLF
		EndIf

		//remove todas as ocorrencias de valor de cVarGrvCps pois o insert sera com valor zero
		cVarGrvCps := StrTran(cVarGrvCps, "@nCT2_VALOR", '0')
		cVarGrvCps := StrTran(cVarGrvCps, "@nCT2_TAXA", '0')
		While ( "@nCT2_VLR" $ cVarGrvCps )
			cVarGrvCps := stuff(cVarGrvCps , AT( '@nCT2_VLR' , cVarGrvCps ), 11 , '0')
		EndDo
		
		cBuffer := StrTran(cBuffer, "--sobrescreve Declaration of variables", CRLF + cDeclare)
		cBuffer := StrTran(cBuffer, "SELECT CT2_FILIAL --ini select", 'SELECT ' + cCpoCursor)
		cBuffer := StrTran(cBuffer, "INTO @cCT2_FILIAL --ini cursor", 'INTO ' + cVarProc)
		cBuffer := StrTran(cBuffer, "INSERT INTO CT2### (CT2_FILIAL ) --ini insert into", 'INSERT INTO CT2### ( ' + cCamposProc+ ')' )
		cBuffer := StrTran(cBuffer, "VALUES (@cCT2_FILIAL )--ini values", 'VALUES ( '+ cVarGrvCps + ' ) ' )
		cBuffer := StrTran(cBuffer, "INTO @cCT2_FILIAL --recarrega cursor", 'INTO ' + cVarProc)

	EndIf
	If cProcName == 'CTBA105B'
		CtbPrep31( @cDeclare, @cCpoCursor, @cVarProc,,,, @cVarIni )
		cBuffer := StrTran(cBuffer, "DECLARE @nMoedaInUse Integer -- Declaration of variables", 'DECLARE @nMoedaInUse Integer' + CRLF + cDeclare)
		cBuffer := StrTran(cBuffer, "SELECT @cCT2_FILIAL  = ' ' --sobreescreve cvarini",  cVarIni )
		cBuffer := StrTran(cBuffer, "SELECT CT2_FILIAL --sobreescreve cCpoCursor", 'SELECT '+ cCpoCursor )
		cBuffer := StrTran(cBuffer, "INTO @cCT2_FILIAL --sobreescreve cVarProc 1", ' INTO '+ cVarProc )
		cBuffer := StrTran(cBuffer, "INTO @cCT2_FILIAL --sobreescreve cVarProc 2", ' INTO '+ cVarProc )
	EndIf

Return .T.

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} EngPos31Compile()
Ponto de entrada após a compilação da procedure, depois do MSParse

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Function EngPos31Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)
	Local __jErrorList := JsonObject():New()
	Do Case
		Case cLocalDB == DEF_DB_MSSQL		
			cBuffer := StrTran(cBuffer, "DECLARE @cExecSql nvarchar", "DECLARE @cExecSql nvarchar(MAX)")
			If cProcName == 'CTBA105B'	
				cBuffer := StrTran(cBuffer, "#INICONVERT", "CONVERT(varbinary(max), RTRIM(")
				cBuffer := StrTran(cBuffer, "#FIMCONVERT", " ) )")
				cBuffer := StrTran(cBuffer, "CTA_DESC", "TOP(1) 1")
			EndIf
		Case cLocalDB == DEF_DB_ORACLE
			cBuffer := StrTran(cBuffer, "cExecSql VARCHAR( MAX )", "cExecSql CLOB")
			cBuffer := StrTran(cBuffer, "OPEN cCursorCTB", "OPEN cCursorCTB FOR vcExecSql") 	
			cBuffer := StrTran(cBuffer, "vcCursorCTB CHAR( 1 )", "cCursorCTB   SYS_REFCURSOR") 	
			cBuffer := StrTran(cBuffer, "vcExecSql  := 'IMMEDIATE'", "EXECUTE IMMEDIATE vcExecSql") 
			If cProcName == 'CTBA105A'	
				cBuffer := StrTran(cBuffer, "CHAR( 1000 )", "BLOB") 
			EndIf
			If cProcName == 'CTBA105B'	
				cBuffer := StrTran(cBuffer, "#INICONVERT", "TO_BLOB(UTL_RAW.CAST_TO_RAW(RTRIM (")
				cBuffer := StrTran(cBuffer, "#FIMCONVERT", ") ) )")
				cBuffer := StrTran(cBuffer, "ORDER BY CTA_DESC ", " AND ROWNUM = 1 ")
				cBuffer := StrTran(cBuffer, "CTA_DESC", " 1 ")
			EndIf
			
		Case cLocalDB == DEF_DB_POSTGRES	
			cBuffer := StrTran(cBuffer, "vcCursorCTB CHAR( 2 )", "cCursorCTB REFCURSOR")
			cBuffer := StrTran(cBuffer, "vnfim_CUR FLOAT", "fim_CUR FLOAT ")
			If cProcName == 'CTBA105A'	
				cBuffer := StrTran(cBuffer, "CHAR( 1000 )", "BYTEA")
			Else 
				If cProcName == 'CTBA105B'	
					cBuffer := StrTran(cBuffer, "ORDER BY CTA_DESC", "LIMIT 1 ")
					cBuffer := StrTran(cBuffer, "CTA_DESC", " 1 ")
				EndIf
			EndIf
			cBuffer := StrTran(cBuffer, "cExecSql VARCHAR( MAX ) ", "cExecSql TEXT")
			cBuffer := StrTran(cBuffer, "PERFORM @CEXECSQL ()", "EXECUTE vcExecSql ")
			cBuffer := StrTran(cBuffer, "OPEN cCursorCTB", "OPEN cCursorCTB FOR EXECUTE vcExecSql ") 
			cBuffer := StrTran(cBuffer, "::bpchar", "") 
			cBuffer := StrTran(cBuffer, "#INICONVERT", " ")		
			cBuffer := StrTran(cBuffer, "#FIMCONVERT", " ")
	EndCase
	If cProcName == 'CTBA105B'	
		__jErrorList := LoadJsonErr()
		cBuffer := StrTran(cBuffer, "#ERRO01", __jErrorList['1'])
		cBuffer := StrTran(cBuffer, "#ERRO02", __jErrorList['2'])
		cBuffer := StrTran(cBuffer, "#ERRO03", __jErrorList['3'])
		cBuffer := StrTran(cBuffer, "#ERRO04", __jErrorList['4'])
		cBuffer := StrTran(cBuffer, "#ERRO05", __jErrorList['5'])
		cBuffer := StrTran(cBuffer, "#ERRO06", __jErrorList['6'])
		cBuffer := StrTran(cBuffer, "#ERRO07", __jErrorList['7'])
		cBuffer := StrTran(cBuffer, "#ERRO08", __jErrorList['8'])
		cBuffer := StrTran(cBuffer, "#ERRO09", __jErrorList['9'])
		cBuffer := StrTran(cBuffer, "#ERRO10", __jErrorList['10'])
		cBuffer := StrTran(cBuffer, "#ERRO11", __jErrorList['11'])
		cBuffer := StrTran(cBuffer, "#ERRO12", __jErrorList['12'])
		cBuffer := StrTran(cBuffer, "#ERRO13", __jErrorList['13'])
		cBuffer := StrTran(cBuffer, "#ERRO14", __jErrorList['14'])
		cBuffer := StrTran(cBuffer, "#ERRO15", __jErrorList['15'])
		cBuffer := StrTran(cBuffer, "#ERRO16", __jErrorList['16'])
		cBuffer := StrTran(cBuffer, "#ERRO17", __jErrorList['17'])
		cBuffer := StrTran(cBuffer, "#ERRO18", __jErrorList['18'])
		cBuffer := StrTran(cBuffer, "#ERRO19", __jErrorList['19'])
		cBuffer := StrTran(cBuffer, "#ERRO20", __jErrorList['20'])
		cBuffer := StrTran(cBuffer, "vcExecSql  := '#EXECUTE' ;", "EXECUTE vcExecSql USING RTRIM(vmCT2_INCDET)::bytea ;") 
	EndIf
Return  .T.

//-----------------------------------------------------------------------------------------
/*
{Protheus.doc} CtbPrep31()
Tratamentos diversos para istalação das procedures do 105

@author TOTVS
@since  25/08/2025
@version 12
*/
//----------------------------------------------------------------------------------------
Static Function CtbPrep31(cDeclare, cCpoCursor, cVarProc, cCposCT2, cVarCT2, lProc1,cVarIni)
Local nX
Local nLenCpos := Len(__aCampos)

DEFAULT cDeclare := ""
DEFAULT cCpoCursor := ""
DEFAULT cVarProc := ""
DEFAULT cCposCT2 := ""
DEFAULT cVarIni := ""
DEFAULT cVarCT2 := ""
DEFAULT lProc1 := .T.

For nX := 1 To nLenCpos  //todos os campos contidos no array static __aCampos

	cDeclare+= "Declare "  //declaracao das variaveis a ser utilizada no curosr
	cVarIni += "Select "

	If 	__aCampos[nX][2] == "C"
		cVarProc 	+= " @c"
		cDeclare 	+= " @c"+__aCampos[nX][1]+" char(" + Alltrim(STR(__aCampos[nX][3])) + ")" + CRLF
		cVarIni   += " @c"+__aCampos[nX][1]+ " = ' '" + CRLF
	Elseif 	__aCampos[nX][2] == "N"
		cVarProc 	+= " @n"
		cDeclare	+= " @n"+__aCampos[nX][1]+" float" + CRLF
		cVarIni 	+= " @n"+__aCampos[nX][1]+ " = 0" + CRLF
	Elseif 	__aCampos[nX][2] == "D"
		cVarProc 	+= " @c"
		cDeclare 	+= " @c"+__aCampos[nX][1]+" char(8)" + CRLF
		cVarIni 	+= " @c"+__aCampos[nX][1]+ " = ' '" + CRLF
	Elseif 	__aCampos[nX][2] == "M"
		cVarProc 	+= " @m"
		cDeclare 	+= " @m"+__aCampos[nX][1]+" char(1000)" + CRLF
		cVarIni 	+= " @m"+__aCampos[nX][1]+ " = ' '" + CRLF
	Else // logico "L"
		cVarProc 	+= " @l"
		cDeclare 	+= " @l"+__aCampos[nX][1]+" char(1)" + CRLF
		cVarIni 	+= " @l"+__aCampos[nX][1]+ " = '0'" + CRLF
	Endif

	cVarTipo := Right(cVarProc, 2)

	cCpoCursor += __aCampos[nX][1]+", "
	
	cVarProc += __aCampos[nX][1]+", "  //variaveis do cursor mesmo nome do campo com @tipvar

	If CT2->(FieldPos(__aCampos[nX][1])) > 0
		cCposCT2 	+= __aCampos[nX][1]+", "
		If __aCampos[nX][1] = "CT2_PROCES"
			cVarCT2	+= "@IN_PROCES"+","		
		ElseIf  "MSSQL" $ __cSGBD .and. __aCampos[nX][2] == "M"
			cVarCT2	+= "CONVERT(VARBINARY(MAX),"+cVarTipo+__aCampos[nX][1]+"),"
		Else
			cVarCT2	+= cVarTipo+__aCampos[nX][1]+","
		EndiF
	Endif

Next nX

If lProc1
	cDeclare += " Declare @iRecno integer "
	cVarIni  += " Select @iRecno = 0 " + CRLF
Else
	cDeclare += "Declare @iRecCT2 integer "+ CRLF
EndIf

cCpoCursor += " R_E_C_N_O_ "
If lProc1
	cVarProc 	+= " @iRecno "
Else
	cVarProc 	+= " @iRecCT2 "
EndIf

cVarCT2	+= " @iRecno "
cCposCT2 	+= " R_E_C_N_O_ "

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} C105QtdEnt
Retorna a quantidade de entidades contábeis via CtbQtdEntd(), garantindo a abertura
preventiva do alias CT0 antes da chamada. Evita erro de alias inexistente em contextos
sem ambiente completo (ex.: Central de Diagnóstico). Utilizada na inicialização das
variáveis estáticas de controle de entidades do fonte.

@author  Renan Leite Gremes
@since   18/06/2026
@version 12.1.2410
/*/
//------------------------------------------------------------------------------------------
static function C105QtdEnt()
	local nQtdEntid as numeric

	//Força abertura da CT0
	if Select("CT0") == 0
		ChkFile("CT0")
	endif

	nQtdEntid := CtbQtdEntd()
return nQtdEntid