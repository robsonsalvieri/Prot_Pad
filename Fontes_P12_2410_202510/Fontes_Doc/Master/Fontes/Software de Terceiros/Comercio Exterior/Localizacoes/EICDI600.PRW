//------------------------------------------------------------------------------------//
//Empresa...: AVERAGE TECNOLOGIA
//Funcao....: EICDI600()
//Autor.....: Alex Wallauer (AWR)
//Data......: 08 de Setembro de 2001, 11:00
//Sintaxe...: #EICDI602 - Desembaraco
//            #EICDI601 - Embarque
//            #EICDI502 - Desembaraco de Nacionalizacao
//Uso.......: SIGAEIC   
//Versao....: Protheus - 7.10    
//Descricao.: Mega Tratamento de D.I. Eletronica...
// Campo WN_LOCAL com conteudo do W7_LOCAL // RAD 01/04/03
//------------------------------------------------------------------------------------//
#INCLUDE "EICDI600.ch"
#include "Average.ch"
#INCLUDE "TOPCONN.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#define COLUNA_FINAL_I (oDlgItens:nClientWidth-4)/2

#define FECHTO_EMBARQUE       "1"
#define FECHTO_DESEMBARACO    "2"
#define FECHTO_NACIONALIZACAO "3"

#define FINALIZAR (nOpca:=1,oDlg:End())
#define VISUAL    2
#define INCLUSAO  3
#define ALTERACAO 4
#define ESTORNO   5

#define SIM     "1"
#define NAO     "2"

#define GENERICO     "06"
#define NCM_GENERICA "99999999"

#DEFINE VALR	1	// Valor total       //MLS
#DEFINE VALM	2	// Valor total MOEDA //MLS


*--------------------------------------*
Function EICDI601() //Antiga EIDI401
*--------------------------------------*
PRIVATE cCadastro := STR0021 //"Embarques"
PRIVATE cTitulo   := STR0022 //"Fechamento do Embarque"
PRIVATE MOpcao     := FECHTO_EMBARQUE
PRIVATE _Declaracao:=.F.
Private aEmbarques :=NIL

DI600Main()
RETURN .T.
*--------------------------------------*
Function EICDI602() //Antiga EIDI402
*--------------------------------------*
PRIVATE cCadastro  := STR0023 //"Desembaraco"
PRIVATE cTitulo    := STR0024 //"Fechamento de Desembaraco"
PRIVATE MOpcao     := FECHTO_DESEMBARACO
PRIVATE _Declaracao:=.F.
Private aEmbarques :=NIL

DI600Main()
RETURN .T.
*--------------------------------------*
Function EICDI603() //Antiga EIDI403
*--------------------------------------*
PRIVATE cCadastro  := STR0027 //"Desembaraço de Nacionalizacao"
PRIVATE cTitulo    := STR0028 //"Fechamento de Desembaraco de Nacionalizacao"
PRIVATE MOpcao     := FECHTO_NACIONALIZACAO
PRIVATE _Declaracao:=.F.
Private aEmbarques :=NIL

DI600Main()
RETURN .T.
*-----------------------------------------------------*
Function DI600Main()//Antiga DI400Main(aFixos)
*-----------------------------------------------------*
LOCAL lOK:=.T., nOrderSX3:=SX3->(IndexOrd()) 
LOCAL nComp1,nComp2 // TLM 03/01/2008
PRIVATE cMoeDolar:= GETNEWPAR("MV_SIMB2","US$")
PRIVATE lFinanceiro:=GetNewPar("MV_EASYFIN","N")=="S"
PRIVATE aDelFile:={},aTabelas:={},aTabHouse:={}
PRIVATE cMarca := GetMark(), lInverte := .F.
PRIVATE lLerFOBPuro:=EasyGParam("MV_FOBPURO",,.F.) .AND. SW8->(FIELDPOS("W8_PRECO_F")) # 0
PRIVATE lFilDa :=EasyGParam("MV_FIL_DA")
PRIVATE nTamReg:=AVSX3("W1_REG",3)
PRIVATE nDecimais :=AVSX3("W9_FOB_TOT",4)
Private lIntDraw := EasyGParam("MV_EIC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
Private cFilED3, cFilED4, cFilED2, cFilSB1:=xFilial("SB1"), cFilSA5:=xFilial("SA5")
Private cFilSW5:=xFilial("SW5"), cFilED0
Private lGravaFin_EIC := EasyGParam("MV_FIN_EIC",,.F.) .AND. !lFinanceiro
Private lCposAdto  := .T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - ParÃ¢metro descontinuado!
Private cFilSW8:=xFilial("SW8"), cFilSW9:=xFilial("SW9")
PRIVATE lBuscaTaxaAuto := .T.
PRIVATE lDISimples,lTemAdicao // AWR - Essa variaveis tem que ser definidas
Private lW2ConaPro := SX3->(DbSeek("W2_CONAPRO"))
Private nValorTit //TRP-18/10/07
Private lTiraSeg := .F. //AAF 25/06/08 - Inicializada variavel
lDISimples := .F.// AWR - Existem funcoes e validacoes no dicionario que usa ou possam vir a usar essa varivel
lTemAdicao := .F.// AWR - Existem funcoes e validacoes no dicionario que usa ou possam vir a usar essa varivel
SX3->(DBSETORDER(2))
Private lExistW8_AC:= SX3->(dbSeek("W8_AC"))
Private lTemRECOF  := SX3->(DBSEEK("W6_RECOF"))  .AND. SX3->(DBSEEK("W6_DTRECOF")) .AND.;
                      SX3->(DBSEEK("W6_OK"))     .AND. SX3->(DBSEEK("W8_SEQ_ADI")) .AND.;
                      EasyGParam("MV_RECOF",,.F.)
SX3->(DBSETORDER(nOrderSX3))
PRIVATE aRotina:= {}
PRIVATE _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")),_PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
Private _PictPO := ALLTRIM(X3Picture("W2_PO_NUM"))
Private cMoedaFrt := "" 
Private cMoedaSeg := ""
Private lValida := .F. //MCF - 25/04/2017
Private nTaxaDolar //MCF - 25/04/2017

//FDR - 11/09/2012
Private lInvAnt := SX3->(dbSeek("EW4_INVOIC")) .AND. SX3->(dbSeek("EW5_INVOIC")) .AND.; //DRL - 15/09/09 - Invoices Antecipadas
                   SX2->(dbSeek("EW4")) .AND. SX2->(dbSeek("EW5")) .AND. SIX->(dbSeek("EW4")) .AND. SIX->(dbSeek("EW5"))
AADD(aRotina,{ STR0029,"DI600Busca",0,1})//"Pesquisar"
AADD(aRotina,{ STR0030,"DI600Manut",0,2})//"Visualizar"
AADD(aRotina,{ STR0031,"DI600Manut",0,3})//"Incluir"
AADD(aRotina,{ STR0032,"DI600Manut",0,4})//"Alterar"
AADD(aRotina,{ STR0034,"DI600Manut",0,5})//"Estornar"
       
//ASR 19/12/2005 - VARIAVEIS USADAS NO DI500
PRIVATE lWB_TP_CON := SWB->(FieldPos("WB_TP_CON")) > 0  .and. SW9->(FieldPos("W9_FORNECC")) > 0 .and.;
                      SW9->(FieldPos("W9_LOJAC")) > 0   .and. SW9->(FieldPos("W9_COMPV")) > 0   .and.;
                      SW9->(FieldPos("W9_PERCOM")) > 0  .and. SW9->(FieldPos("W9_VALCOM")) > 0  .and.;
                      SWB->(FieldPos("WB_TIPOCOM")) > 0 .and. SW6->(FieldPos("W6_CONDP_F")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_F")) > 0 .and. SW6->(FieldPos("W6_CONDP_S")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_S")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0
PRIVATE lMV_SLD_EMB := EasyGParam("MV_SLD_EMB",,.F.)
          
//***ASK 21/01/2008 - Tratamento de Ingressos Brutos
Private lTemCAI := SWD->(FieldPos("WD_PROVENT")) > 0  .and. SWD->(FieldPos("WD_CAI")) > 0 .and.;
                   SWD->(FieldPos("WD_VENCAI")) > 0

Private lSegInc := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND.;
                   SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0 // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
// TLM 03/01/2008  - Verificação do tamanho dos campos WD_DOCTO e E2_NUM. Devem ter o mesmo tamanho.
Sx3->(DbSetOrder(2))  
Sx3->(DbGoTop())
Sx3->(DbSeek(IncSpace("WD_DOCTO",len(X3_CAMPO),.F.))) 
nComp1:=SX3->X3_TAMANHO  
Sx3->(DbSeek(IncSpace("E2_NUM",len(X3_CAMPO),.F.)))    
nComp2:=SX3->X3_TAMANHO   
                                                   		
If nComp1 # nComp2
   Msgstop(STR0555) // "Foi encontrado um problema com o dicionário da dados .O tamanho do campo WD_DOCTO possui tamanho diferente do campo E2_NUM."
   Return .F.
EndIf
IF MOpcao # FECHTO_EMBARQUE
   AADD(aRotina,{ STR0033,"DI600Desp2",0,4})//"Despesas"
ENDIF

/*    FOI RETIRADA ESTA CHECAGEM PORQUE ESTE CAMPO JÁ É ASSUMIDO NA VERSAO 811 ENTAO NAO FAZ SENTIDO CHECAR WD_COND
      RS  31/08/05

IF MOpcao # FECHTO_EMBARQUE
   SIX->(DBSETORDER(1))
   IF SWD->(FIELDPOS("WD_COND")) # 0 .AND. SIX->(DBSEEK("SWD6"))
      AADD(aRotina,{ STR0033,"DI600Desp2",0,4})//"Despesas" //MLS
   ELSE
      AADD(aRotina,{ STR0033,"DI600Despes",0,4})//"Despesas"
   ENDIF
ENDIF
*/

If lIntDraw
   cFilED4:=xFilial("ED4")
   cFilED3:=xFilial("ED3")
   cFilED2:=xFilial("ED2")
   cFilED0:=xFilial("ED0")
EndIf
DI600aEMB()

lCriouOK:=.F.

bSetKey:=SetKey(VK_F12)
//ASK 13/02/07 10:05 - Incluso no AtuSx do P9R1
//SX1->(DBSETORDER(1))
IF lFinanceiro //.AND. SX1->(DBSEEK("EICFI4"))
   SetKey (VK_F12,{|| Pergunte("EICFI4",.T.) })
ENDIF
lNoBaixa:=.T.

DI600Fil(.T.)

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"AROTINA"),)
SW6->(DBSETORDER(1))
mBrowse(,,,,"SW6")

DI600Fil(.F.)
DI600Final()

SetKey(VK_F12,bSetKey)

Return .T.                          
*------------------------------------------------------------------------------*
FUNCTION DI600CriaWork()//Antiga DI_InitWork(bCloseAll,bMsg)
*------------------------------------------------------------------------------*
Local I
Procregua(3)
IncProc(STR0261) //"Iniciando Ambiente..."
aSemSX3SW7:={;
{"WKCOD_I"   ,"C",LEN(SW7->W7_COD_I),0},;
{"WKFABR"    ,"C",LEN(SW7->W7_FABR) ,0} ,{"WKNOME_FAB","C",15,0} ,;
{"WKFORN"    ,"C",LEN(SW7->W7_FORN) ,0} ,{"WKNOME_FOR","C",15,0} ,;
{"WKFLUXO"   ,"C",1 ,0} ,{"WKQTDE"    ,"N",13,3} ,;
{"WKCC"      ,"C",LEN(SW7->W7_CC)   ,0} ,{"WKDESCR"   ,"C",26,0} ,;
{"WKSI_NUM"  ,"C",LEN(SW7->W7_SI_NUM),0} ,{"WKPO_NUM"  ,"C",15,0} ,;
{"WKPGI_NUM" ,"C",10,0} ,{"WKGI_NUM"  ,"C",13,0} ,;
{"WKFLAG"    ,"L",1,0}  ,{"WKFLAG2"   ,"L",1 ,0} ,;
{"WKPRECO"   ,"N",AVSX3("W7_PRECO",3),AVSX3("W7_PRECO",4)} ,;
{"WKSALDO_Q" ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKSALDO_O" ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKQTDE_D"  ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKQTDEDORI","N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKDISPINV" ,"N",AVSX3("W7_QTDE" ,3),AVSX3("W7_QTDE" ,4)} ,;
{"WKDT_EMB"  ,"D",08,0} ,{"WKDT_ENTR" ,"D",8 ,0} ,;
{"WKNBM"     ,"C",10,0} ,{"WKDTENTR_S","D",8 ,0} ,;
{"WKPART_N"  ,"C",LEN(IF(SW3->(FieldPos("W3_PART_N")) # 0,SW3->W3_PART_N,SA5->A5_CODPRF)),0} ,{"WKDOCTO_F" ,"C",15,0} ,;
{"WKSEQ"     ,"N",02,0} ,;
{"WKREG"     ,"N",nTamReg,0},{"WKRECNO_ID","N",10,0} ,;
{"WKPESO_L"  ,"N",AVSX3("B1_PESO",3),AVSX3("B1_PESO",4)},;
{"WKMOEDA"   ,"C",3,0}  ,{"WKFLAGWIN" ,"C",2 ,0} ,;
{"WKFLAGWIN2","C",02,0} ,{"WKOPERACA" ,"C",05,0},;
{"WKSEQ_LI"  ,"C",03,0} ,{"WKREGIST"  ,"C",10,0},;
{"WKREG_VEN" ,"D",08,0} ,{"WKINVOICE" ,"C",LEN(SW9->W9_INVOICE),0},;
{"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0} ,{"WK_ALTEROU","L",01,0},;
{"WKEX_NCM"  ,"C",LEN(SW7->W7_EX_NCM),0},;
{"WKEX_NBM"  ,"C",LEN(SW7->W7_EX_NBM),0},;
{"WKTEC"     ,"C",LEN(SW7->W7_NCM),0},;
{"WKIPIPAUTA","N",15,5},;
{"WKTES"     ,"C",03,0}}     //TRP-10/01/08

//FDR - 21/09/12 - Tratamento de Loja
EICAddWkLoja(aSemSX3SW7, "W7_FABLOJ", "WKFABR")
EICAddWkLoja(aSemSX3SW7, "W7_FORLOJ", "WKFORN")

If lIntDraw .and. lExistW8_AC
   aAdd(aSemSX3SW7,{"WKAC"     ,"C",Len(SW5->W5_AC),0})
   aAdd(aSemSX3SW7,{"WKSEQSIS" ,"C",Len(SW5->W5_SEQSIS),0})
EndIf

IncProc(STR0261) //"Iniciando Ambiente..."

aSemSX3SW8:={}
AADD(aSemSX3SW8,{"WKINVOICE" ,"C",LEN(SW9->W9_INVOICE),0})
AADD(aSemSX3SW8,{"WKQTDE"    ,"N",AVSX3("W8_QTDE" ,3),AVSX3("W8_QTDE" ,4)})
AADD(aSemSX3SW8,{"WKPRECO"   ,"N",AVSX3("W8_PRECO",3),AVSX3("W8_PRECO",4)})
AADD(aSemSX3SW8,{"WKCOD_I"   ,"C",LEN(SW5->W5_COD_I),0})
AADD(aSemSX3SW8,{"WKFABR"    ,"C",AVSX3("W8_FABR",3) ,0})
//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   AADD(aSemSX3SW8,{"W8_FABLOJ"    ,"C",AVSX3("W8_FABLOJ",3) ,0})
EndIf
AADD(aSemSX3SW8,{"WKREG"     ,"N",nTamReg,0})
AADD(aSemSX3SW8,{"WKDT_EMIS" ,"D",8 ,0}) ; AADD(aSemSX3SW8,{"WKPO_NUM" ,"C",15,0})
AADD(aSemSX3SW8,{"WKCC"      ,"C",AVSX3("W8_CC",3) ,0}) ; AADD(aSemSX3SW8,{"WKSI_NUM" ,"C",AVSX3("W8_SI_NUM",3) ,0})
AADD(aSemSX3SW8,{"WKPGI_NUM" ,"C",10,0}) ; AADD(aSemSX3SW8,{"WKDESC_DI","M",10,0})
AADD(aSemSX3SW8,{"WKSEQ_LI"  ,"C",03,0}) ; AADD(aSemSX3SW8,{"WKFLUXO"  ,"C",01,0})
AADD(aSemSX3SW8,{"WKFLAGIV"  ,"C",2 ,0})
AADD(aSemSX3SW8,{"WKDISPLOT" ,"N",AVSX3("WV_QTDE"   ,3),AVSX3("WV_QTDE"   ,4)})// AWR - Lote - 07/06/2004
AADD(aSemSX3SW8,{"WKBASEII"  ,"N",AVSX3("W8_BASEII" ,3),AVSX3("W8_BASEII" ,4)})
AADD(aSemSX3SW8,{"WKBASEICM" ,"N",AVSX3("W8_BASEICM",3),AVSX3("W8_BASEICM",4)})
AADD(aSemSX3SW8,{"WKFOBTOTR" ,"N",AVSX3("W8_FOBTOTR",3),AVSX3("W8_FOBTOTR",4)})
AADD(aSemSX3SW8,{"WKVLMLE"   ,"N",AVSX3("W8_VLMLE"  ,3),AVSX3("W8_VLMLE"  ,4)})
AADD(aSemSX3SW8,{"WKFORN"    ,"C",LEN(SW2->W2_FORN),0})
//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   aAdd(aSemSX3SW8,{"W8_FORLOJ" ,"C", AvSX3("W8_FORLOJ", AV_TAMANHO), 0})
EndIf
AADD(aSemSX3SW8,{"WKPRTOTMOE","N",AVSX3("W9_FOB_TOT",3),AVSX3("W9_FOB_TOT",4)})
AADD(aSemSX3SW8,{"WKOUTDESP" ,"N",AVSX3("W8_OUTDESP",3),AVSX3("W8_OUTDESP",4)}) 
AADD(aSemSX3SW8,{"WKINLAND"  ,"N",AVSX3("W8_INLAND" ,3),AVSX3("W8_INLAND" ,4)})
AADD(aSemSX3SW8,{"WKFRETEIN" ,"N",AVSX3("W8_FRETEIN",3),AVSX3("W8_FRETEIN",4)})
AADD(aSemSX3SW8,{"WKPACKING" ,"N",AVSX3("W8_PACKING",3),AVSX3("W8_PACKING",4)})
AADD(aSemSX3SW8,{"WKDESCONT" ,"N",AVSX3("W8_DESCONT",3),AVSX3("W8_DESCONT",4)})
AADD(aSemSX3SW8,{"WKPESO_L"  ,"N",AVSX3("B1_PESO"   ,3),AVSX3("B1_PESO"   ,4)})
AADD(aSemSX3SW8,{"WKSALDO_AT","N",AVSX3("W7_QTDE"   ,3),AVSX3("W7_QTDE"   ,4)})
AADD(aSemSX3SW8,{"WKSALDO"   ,"N",AVSX3("W7_QTDE"   ,3),AVSX3("W7_QTDE"   ,4)})
AADD(aSemSX3SW8,{"WKDISPINV" ,"N",AVSX3("W7_QTDE"   ,3),AVSX3("W7_QTDE"   ,4)})
AADD(aSemSX3SW8,{"WKVLACRES" ,"N",AVSX3("W8_VLACRES",3),AVSX3("W8_VLACRES",4)})
AADD(aSemSX3SW8,{"WKVLDEDU"  ,"N",AVSX3("W8_VLDEDU" ,3),AVSX3("W8_VLDEDU" ,4)})
AADD(aSemSX3SW8,{"WKPESOTOT" ,"N",18,AVSX3("B1_PESO",4)})
AADD(aSemSX3SW8,{"WKTEC"     ,"C",LEN(SW7->W7_NCM),0}) 
AADD(aSemSX3SW8,{"WKEX_NCM"  ,"C",LEN(SW7->W7_EX_NCM),0}) 
AADD(aSemSX3SW8,{"WKEX_NBM"  ,"C",LEN(SW7->W7_EX_NBM),0})
AADD(aSemSX3SW8,{"WKREGIST"  ,"C",10,0}) ; AADD(aSemSX3SW8,{"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0})
AADD(aSemSX3SW8,{"WKRECNO"   ,"N",10,0}) ; AADD(aSemSX3SW8,{"WKOPERACA" ,"C",05,0}) 
AADD(aSemSX3SW8,{"WKCOND_PA" ,"C",05,0}) ; AADD(aSemSX3SW8,{"WKDIAS_PA" ,"N",03,0})
AADD(aSemSX3SW8,{"WKMOEDA"   ,"C",03,0})
AADD(aSemSX3SW8,{"WKINCOTER" ,"C",03,0}) ; AADD(aSemSX3SW8,{"WKVLSEGMN" ,"N",15,2})
AADD(aSemSX3SW8,{"WKVLFREMN" ,"N",15,2}) ; AADD(aSemSX3SW8,{"WKVLICMS"  ,"N",15,2})
AADD(aSemSX3SW8,{"WKVLII"    ,"N",15,2}) ; AADD(aSemSX3SW8,{"WKVLIPI"   ,"N",15,2})
AADD(aSemSX3SW8,{"WKSEQ_ADI" ,"C",03,0})
IF lLerFOBPuro
   AADD(aSemSX3SW8,{"WKPRECO_F","N",AVSX3("W8_PRECO_F",3),AVSX3("W8_PRECO_F",4) })
ENDIF
If lIntDraw .and. lExistW8_AC
   AADD(aSemSX3SW8,{"WKAC"      ,"C",LEN(SW8->W8_AC),0})
   AADD(aSemSX3SW8,{"WKSEQSIS"  ,"C",LEN(SW8->W8_SEQSIS),0})
   AADD(aSemSX3SW8,{"WKQT_AC"   ,"N",AVSX3("W8_QT_AC",3),AVSX3("W8_QT_AC",4)})
   AADD(aSemSX3SW8,{"WKVL_AC"   ,"N",AVSX3("W8_VL_AC",3),AVSX3("W8_VL_AC",4)})
EndIf

IF cPaisLoc == "CHI"
  AADD(aSemSX3SW8,{"WKJUROS","N",15,2})
ENDIF  
// EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSeginc 
   AADD(aSemSX3SW8,{"WKSEGURO" ,"N",AVSX3("W8_SEGURO",3),AVSX3("W8_SEGURO",4)})
ENDIF
//LRS - 05/05/2017 - Adicionado o campo WKFILTRO no array
AADD(aSemSX3SW8,{"WKFILTRO","C",01,0})

aSemSX3SW9:={{"WK_RECNO"  ,"N",10,00},;
             {"W9_QTDE"   ,"N",15,04},;
             {"W9_PESO"   ,"N",18,AVSX3("B1_PESO",4)},;
             {"WK_TPINV"  ,"N", 1,00}} //EOS

IF SW9->(FIELDPOS("W9_TUDO_OK")) = 0
   AADD(aSemSX3SW9,{"W9_TUDO_OK","C",01,00})
ENDIF
AADD(aSemSX3SW7,{"WKLOCAL","C",LEN(SC1->C1_LOCAL),0})

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"STRU_WORKS"),)

IncProc(STR0262+"1") //"Criando Arquivo Temporario "
//*********************************************************  WORK

FileWork := E_CriaTrab(,aSemSX3SW7,"Work") //Temporario no Banco de Dados

IF ! USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
AADD(aDelFile,{"Work",FileWork})
//MFR OSSME-1974 26/12/2018
IndRegua("Work",FileWork+TeOrdBagExt(),"WKPGI_NUM+WKCC+WKSI_NUM+WKCOD_I")

FileWork2:= E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work",FileWork2+TeOrdBagExt(),"WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I")
AADD(aDelFile,{,FileWork2})

FileWork3:= E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work",FileWork3+TeOrdBagExt(),"WKPO_NUM+WKPGI_NUM+WKPOSICAO")
AADD(aDelFile,{,FileWork3})

FileWork4:= E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work",FileWork4+TeOrdBagExt(),"WKCOD_I+DTOS(WKDT_EMB)")
AADD(aDelFile,{,FileWork4})
//MFR OSSME-1974 26/12/2018
SET INDEX TO (FileWork +TeOrdBagExt()), (FileWork2+TeOrdBagExt()),;
             (FileWork3+TeOrdBagExt()), (FileWork4+TeOrdBagExt())

aSemSX3   :={{"WK_RECNO"  ,"N",10,0}}
aSemSX3EIJ:={{"WK_RECNO"  ,"N",10,0}}
aSemSX3EIO:={{"WK_RECNO"  ,"N",10,0}}
aSemSX3SWV:={{"WKDISPLOT" ,"N",AVSX3("WV_QTDE",3),AVSX3("WV_QTDE",4)},;// AWR - Lote - 07/06/2004
             {"WKFLAGLOT" ,"C",2 ,0}}// AWR - Lote - 07/06/2004
IF EIO->(FIELDPOS("EIO_PARCEL")) = 0
   AADD(aSemSX3EIO,{"EIO_PARCEL","C",02,0})
ENDIF
aSemTOT   :={{"WKCODIGO"  ,"C",1,0}}
aIndiceEIF:={"EIF_CODIGO+EIF_DOCTO" }
aIndiceEIG:={"EIG_CODIGO+EIG_NUMERO"}
//aIndiceSW9:={"W9_INVOICE+W9_FORN"+IF(EICLoja(), "+W9_FORLOJ+W9_HAWB","+W9_HAWB")} // FDR - 13/09/12 - Tratamento de loja 
aIndiceSW9:={"W9_INVOICE+W9_FORN"+IF(EICLoja(), "+W9_FORLOJ","")} // FDR - 13/09/12 - Tratamento de loja
aIndiceCWV:={"WV_LOTE+WV_FORN"+ If(EICLoja(), "+WV_FORLOJ", "")}// FDR - 13/09/12 - Tratamento de loja // AWR - Lote
aIndiceSWV:={"WV_LOTE+WV_FORN"+ If(EICLoja(), "+WV_FORLOJ", ""),;// FDR - 13/09/12 - Tratamento de loja// AWR - Lote
             "WV_FORN"+ If(EICLoja(), "+WV_FORLOJ", ""),;
             "WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE"}// AWR - Lote
aIndiceTWV:={"WV_LOTE+WV_FORN"+ If(EICLoja(), "+WV_FORLOJ", ""),;// AWR - Lote
             "WV_INVOICE+WV_FORN"+ If(EICLoja(), "+WV_FORLOJ", "")+"+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO"}// FDR - 13/09/12 - Tratamento de loja// AWR - Lote
aIndiceSW8:={"WKINVOICE+WKFORN"+If(EICLoja(), "+W8_FORLOJ", "")+"+WKPO_NUM+WKPOSICAO+WKPGI_NUM",;
             "WKFORN"+ If(EICLoja(), "+W8_FORLOJ", "") +"+WKPO_NUM+WKPOSICAO+WKPGI_NUM",;// FDR - 13/09/12 - Tratamento de loja
             "WKREGIST+WKFORN"+ If(EICLoja(), "+W8_FORLOJ", "") +"+WKFABR"+ If(EICLoja(), "+W8_FABLOJ", "") +"+WKTEC+WKEX_NCM+WKEX_NBM+WKCOND_PA+STR(WKDIAS_PA,3,0)+WKMOEDA+WKINCOTER"}
aIndiceTOT:={"WKCODIGO+W9_INVOICE+W9_FORN"+If(EICLoja(), "+W9_FORLOJ", ""),"WKCODIGO+W9_MOE_FOB"}// FDR - 13/09/12 - Tratamento de loja

// FDR - 13/09/12 - Tratamento de loja
If !EICLoja()
   aCpoTot :={"W9_INVOICE","W9_FORN","W9_MOE_FOB","W9_FRETEIN","W9_INLAND","W9_PACKING",;
              "W9_OUTDESP","W9_DESCONT","W9_FOB_TOT","W6_FOB_TOT"}
Else
   aCpoTot :={"W9_INVOICE","W9_FORN","W9_FORLOJ","W9_MOE_FOB","W9_FRETEIN","W9_INLAND","W9_PACKING",;
              "W9_OUTDESP","W9_DESCONT","W9_FOB_TOT","W6_FOB_TOT"}
EndIf  

// EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSeginc 
   AADD(aCpoTot,"W9_SEGURO")
ENDIF           
aTabelas:={}//cAlias,aIndice    ,aSemSX3   ,aCampos,aHeader,cComAlias
AADD(aTabelas,{"SW8",aIndiceSW8 ,aSemSX3SW8,{}     ,       ,'Nao'})
AADD(aTabelas,{"SW9",aIndiceSW9 ,aSemSX3SW9,       ,       ,     })
AADD(aTabelas,{"EIF",aIndiceEIF    ,aSemSX3,       ,{}     ,     })
AADD(aTabelas,{"EIG",aIndiceEIG    ,aSemSX3,       ,{}     ,     })
AADD(aTabelas,{"EIH",{"EIH_CODIGO"},aSemSX3,       ,{}     ,     })
AADD(aTabelas,{"EII",{"EII_CODIGO"},aSemSX3,       ,{}     ,     })
AADD(aTabelas,{"Tot",aIndiceTOT    ,aSemTOT,aCpoTot,       ,'Nao'})
AADD(aTabelas,{"PO" ,{"W3_PO_NUM"} ,       ,{"W3_PO_NUM"}, ,'Nao'})
IF lTemLote// AWR - Lote 
   AADD(aTabelas,{"SWV",aIndiceSWV ,          ,    ,       ,     })// AWR - Lote
   AADD(aTabelas,{"CWV",aIndiceCWV ,          ,    ,       ,'SWV'})// AWR - Lote
   AADD(aTabelas,{"TWV",aIndiceTWV ,aSemSX3SWV,    ,       ,'SWV'})// AWR - Lote
ENDIF

//Alteracao ou Criacao de Indice ou Estrutura
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"IND_ESTRU_EXTRA"),)

Procregua(LEN(aTabelas))
SX3->(DBSETORDER(1))
FOR I := 1 TO LEN(aTabelas)
    IncProc(STR0262+STR(I+1,2))//"Criando Arquivo Temporario "
    IF !DI600CriaTrab(aTabelas[I],aDelFile)
        RETURN .F.
    ENDIF
NEXT
RETURN .T.
*-------------------------------------------------------------------------------------*
Function DI600CriaTrab(aTabelas,aDelFile)
*-------------------------------------------------------------------------------------*
LOCAL cAlias   :=aTabelas[1]
LOCAL aIndice  :=aTabelas[2]
LOCAL aSemSX3  :=aTabelas[3]
LOCAL aCpos    :=aTabelas[4]
LOCAL aHeader  :=aTabelas[5]
LOCAL xComAlias:=aTabelas[6]
LOCAL cAliasWK :="Work_"+cAlias,cFileWk,F
IF SX3->(DBSEEK(cAlias))
   DBSELECTAREA(cAlias)
ENDIF
IF(xComAlias#NIL,IF(xComAlias#'Nao',cAlias:=xComAlias,cAlias:=NIL),)// AWR - Lote
aCampos:=IF(aCpos=NIL,ARRAY((cAlias)->(Fcount())),aCpos)// AWR - Lote
cFileWk:=E_CriaTrab(cAlias,aSemSX3,cAliasWK,aHeader)
IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
AADD(aDelFile,{cAliasWK,cFileWk})
nQtdeIndice:=LEN(aDelFile)
FOR F := 1 TO LEN(aIndice)
   IF F > 1      
      cFileWk:=E_Create(,.F.)
      AADD(aDelFile,{,cFileWk})
   ENDIF
   //MFR OSSME-1974 26/12/2018
   IndRegua(cAliasWK,cFileWk+TeOrdBagExt(),aIndice[F])
NEXT
IF LEN(aIndice) > 1
   DBSELECTAREA(cAliasWk)
   SET INDEX TO
   FOR F := nQtdeIndice TO LEN(aDelFile)
   //MFR OSSME-1974 26/12/2018
      DBSETINDEX(aDelFile[F,2]+TeOrdBagExt())
   NEXT
ENDIF
RETURN .T.

*-----------------------------------------------------*
Function DI600Manut(cAlias,nReg,nOpc)//Antiga DI400Visual(),DI400Inclui(),DI400Altera(),DI400Estorn()
*-----------------------------------------------------*
LOCAL aOk:={{||FINALIZAR},STR0421} //"Sair"
LOCAL bValid :={||.T.}, D, i, I6
LOCAL nOpca  := 0
LOCAL lTopo
PRIVATE lExistEZZ:= SX2->(dbSeek("EZZ"))
PRIVATE aLotes  :={},lGravaSWV:=.F.// AWR - Lote
PRIVATE nOPC_mBrw  := nOPC   // JBS - 28/11/2003 

SIX->(DBSETORDER(1))// AWR - Lote
lTemLote:= SWV->(FIELDPOS("WV_INVOICE")) # 0 .AND.;// AWR - Lote
           SWV->(FIELDPOS("WV_POSICAO")) # 0 .AND.;
           SWV->(FIELDPOS("WV_FORN"))    # 0 .AND.;
           SIX->(dbSeek("SWV2"))

IF nOpc # INCLUSAO .AND. nOpc # VISUAL
   If !DI600PROG()
      Return nOpc
   EndIf
EndIf

IF nOpc = ALTERACAO .OR. nOpc = ESTORNO
   If !SW6->(RecLock("SW6",.F.))
      Return .F.
   Endif
ENDIF

IF !lCriouOK
   Processa({|| lCriouOK:=DI600CriaWork()},STR0260) //"Criando Temporarios"
   IF !lCriouOK
      SW6->(MsUnlock())
      RETURN .F.
   ENDIF
ENDIF

PRIVATE aBotoes1T:={}
PRIVATE aSemSX3:=NIL
PRIVATE aCamposMostra:=aEmbarques
PRIVATE aDarGets:=NIL
PRIVATE lExiste :=.T.,aDeletados:={}
PRIVATE lGravaEIF:=lGravaEIG:=lGravaEIH:=lGravaEII:=.F.
PRIVATE lGravaEIJ:=lGravaEIK:=lGravaEIL:=lGravaEIM:=lGravaEIN:=lGravaEIO:=.F.
PRIVATE nPos_aRotina  := nOpc
PRIVATE lAltDescricao := GETNEWPAR("MV_DESCDI",.T.)
PRIVATE lExisteGarrafa:= .F.
PRIVATE lPrimeiraVez  :=.T.
PRIVATE cPedido:=SPACE(LEN(SW7->W7_PO_NUM))
PRIVATE cPLI:=SPACE(LEN(SW7->W7_PGI_NUM))
PRIVATE aPedido:={},aPLI:={}
PRIVATE cPONAC:=cPedido,lGetPo:=.T.
PRIVATE dDataBranca:=AVCTOD("")
PRIVATE aAliasCapa:={'EIF','EIG','EIH','EII'}
PRIVATE aAliasAdic:={}
PRIVATE lGravaSoCapa:=.T.
PRIVATE lTemCambio  :=.F.
PRIVATE lTemNfE := .F.
PRIVATE cVM_OBS :=' '
PRIVATE cVM_COMP:=' '

IF !Inclui
   SF1->(DBSETORDER(5))
   lTemNfE:= SF1->(DBSEEK(xFilial()+SW6->W6_HAWB))
ENDIF
SF1->(DBSETORDER(1))  
M->W6_IMPORT  :=SPACE(LEN(SW6->W6_IMPORT))
cMOEDAProc    :=SPACE(LEN(SW2->W2_MOEDA))

Work->(AvZap())
FOR D := 1 TO LEN(aTabelas)
   cAliasZ:="Work_"+aTabelas[D,1]
  (cAliasZ)->(AvZap())
NEXT

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"INICIO_OPCAO"),)

DO CASE

CASE nOpc == VISUAL//******* V I S U A L ***********************************************
     DBSELECTAREA("SW6")
     IF Bof() .AND. Eof()
        Return nOpc
     EndIf

     FOR i := 1 TO FCount()
        M->&(FIELDNAME(i)) := FieldGet(i)
     NEXT i

     aCampos:={"W7_SEQ_LI" , "W7_PGI_NUM", "WP_VENCTO" ,"W7_PO_NUM" , "W7_CC"     , "W7_SI_NUM" ,;
               "W7_COD_I"  , "W5_DESC_P" , "W7_POSICAO","W7_FABR"   , "W5_FABR_N" , "W7_FORN"   ,;
               "W5_FORN_N" , "W7_QTDE"   , "W7_PRECO"  ,"W6_FOB_TOT", "W9_INVOICE", "W9_DT_EMIS",;
               "W7_PESO"   , "W7_NCM"    , "W7_EX_NCM" ,"W7_EX_NBM" , "WP_REGIST"}
     If lIntDraw .and. lExistW8_AC
        aAdd(aCampos,"W5_AC")
     EndIf
     
     //FDR - 21/09/12 - Tratamento de Loja
     EICAddLoja(aCampos, "W7_FORLOJ", Nil, "W7_FORN")  
     EICAddLoja(aCampos, "W7_FABLOJ", Nil, "W7_FABR")
     
     aSemSX3:={}
     AADD(aSemSX3,{"WKLOCAL","C",LEN(SC1->C1_LOCAL),0})

     IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"VISUAL_CAMPOS"),)

     cNomArq:=E_CriaTrab(,aSemSX3)
     //MFR OSSME-1974 26/12/2018
     IndRegua("TRB",cNomArq+TeOrdBagExt(),"W7_PGI_NUM+W7_CC+W7_SI_NUM+W7_COD_I")

     aTB_Campos := {}
     IF MOpcao==FECHTO_NACIONALIZACAO
        AADD(aTB_Campos,{{||TRANS(TRB->W7_PO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,STR0079})//"Nacionalizacao"
     ELSE
        AADD(aTB_Campos,{"W7_PO_NUM" ,,AVSX3("W7_PO_NUM" ,5)})
     ENDIF
     AADD(aTB_Campos,{"W7_CC"     ,,AVSX3("W7_CC"     ,5)})
     AADD(aTB_Campos,{"W7_SI_NUM" ,,AVSX3("W7_SI_NUM" ,5)})
     AADD(aTB_Campos,{"W7_POSICAO",,AVSX3("W7_POSICAO",5)})
     AADD(aTB_Campos,{"W7_COD_I"  ,,AVSX3("W7_COD_I"  ,5)})
     AADD(aTB_Campos,{"W5_DESC_P" ,,STR0043              })
     AADD(aTB_Campos,{"W7_FABR"   ,,AVSX3("W7_FABR"   ,5)})
     //FDR - 13/09/12 - Tratamento de loja
     If EICLoja()
        AADD(aTB_Campos,{"W7_FABLOJ"   ,,AVSX3("W7_FABLOJ"   ,5)})
     EndIf
     AADD(aTB_Campos,{"W5_FABR_N" ,,AVSX3("W5_FABR_N" ,5)})
     AADD(aTB_Campos,{"W7_FORN"   ,,AVSX3("W7_FORN"   ,5)})
     //FDR - 13/09/12 - Tratamento de loja
     If EICLoja()
        AADD(aTB_Campos,{"W7_FORLOJ"   ,,AVSX3("W7_FABLOJ"   ,5)})
     EndIf
     AADD(aTB_Campos,{"W5_FORN_N" ,,AVSX3("W5_FORN_N" ,5)})
     AADD(aTB_Campos,{"W7_QTDE"   ,,AVSX3("W7_QTDE"   ,5),AVSX3("W7_QTDE",6)})
     AADD(aTB_Campos,{"W7_PRECO"  ,,AVSX3("W7_PRECO"  ,5),AVSX3("W7_PRECO",6)})
     AADD(aTB_Campos,{"W6_FOB_TOT",,AVSX3("W9_FOB_TOT",5),AVSX3("W6_FOB_TOT",6)})
     AADD(aTB_Campos,{"W7_PESO"   ,,AVSX3("W7_PESO",5)   ,AVSX3("W7_PESO",6)})
     AADD(aTB_Campos,{"W7_NCM"    ,,AVSX3("W3_TEC",5)    ,AVSX3("W3_TEC",6)})
     AADD(aTB_Campos,{"W7_EX_NCM" ,,AVSX3("W3_EX_NCM",5) ,AVSX3("W3_EX_NCM",6)})
     AADD(aTB_Campos,{"W7_EX_NBM" ,,AVSX3("W3_EX_NBM",5) ,AVSX3("W3_EX_NBM",6)})
     AADD(aTB_Campos,{"W9_INVOICE",,AVSX3("W9_INVOICE",5)})
     AADD(aTB_Campos,{"W9_DT_EMIS",,STR0051}) //"Data da Invoice"
     AADD(aTB_Campos,{"WKLOCAL"   ,,AVSX3("C1_LOCAL",5)})

     If lIntDraw .and. lExistW8_AC
        AADD(aTB_Campos,{"W5_AC",,AVSX3("W5_AC",5)}) //"Ato Concess."
     EndIf

     IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"VISUAL_INDICE_COLUNAS"),)

     Processa({|| DI600GrvTRB(.F.) },STR0054) //"Pesquisa de Itens"

     TRB->(DBGOTOP())

     AADD(aBotoes1T,{"VERNOTA"   ,{|| DI600Invoices()},STR0425}) //"Invoices"
     IF(lTemLote, AADD(aBotoes1T,{"CONTAINR",{|| DI600Lotes() },"Lotes"}) ,)// AWR - Lote
     AADD(aBotoes1T,{"SIMULACAO" ,{|| DI600Totais(oMark)  },STR0382 }) //"Totais"

     AADD(aBotoes1T,{"TOP"   ,{|| nOpca:=10,oDlg:End()},STR0511 })//"Primeiro"
     AADD(aBotoes1T,{"PREV"  ,{|| nOpca:=20,oDlg:End()},STR0512 })//"Anterior"
     AADD(aBotoes1T,{"NEXT"  ,{|| nOpca:=30,oDlg:End()},STR0513 })//"Proximo"
     AADD(aBotoes1T,{"BOTTOM",{|| nOpca:=40,oDlg:End()},STR0514 })//"Ultimo"
     //******* V I S U A L ***********************************************
CASE nOpc == INCLUSAO//****** I N C L U S A O ******************************************

     lExiste:=.F.
     DI600Fil(.F.)

     dbSelectArea("SW6")
     FOR I6 := 1 TO FCount()
         M->&(FIELDNAME(I6)) := CRIAVAR(FIELDNAME(I6))
     NEXT I6
     DI500Controle(0,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})
     IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"E_INITVAR"),)

     IF MOpcao == FECHTO_NACIONALIZACAO
        If !DI600SELPO()
           DI600Fil(.T.)
           Return 3
        EndIf
     EndIf

     bValid:={|| Obrigatorio(aGets,aTela).AND.;
                 E_Valid(aGets,{|campo| DI_Valid(campo,,.T.)}).AND.;
                 DI_Valid("TUDO",.F.,.T.)}
     aOk:= {{|| IF(Eval(bValid),IF(DI600Itens(),FINALIZAR,),)}}//NIL

     AADD(aBotoes1T,{"LJPRECO",{|| Processa({|| DI600Taxa(.T.)})    },"Taxas"})
     AADD(aBotoes1T,{"VERNOTA",{|| IF(Eval(bValid),DI600Invoices(),)},"Invoices"})
     IF(lTemLote, AADD(aBotoes1T,{"CONTAINR",{|| DI600Lotes() },"Lotes"}) ,)// AWR - Lote
     AADD(aBotoes1T,{"SIMULACAO" ,{|| DI600Totais() },STR0382 })
     AADD(aBotoes1T,{"NOVACELULA",{|| DI600Comple() },"Edicao Complemento",,"Edit.Comp"})
     AADD(aBotoes1T,{"NEXT"      ,{|| IF(Eval(bValid),IF(DI600Itens(),FINALIZAR,),)},"Itens"})

     //****** I N C L U S A O ******************************************
CASE nOpc == ALTERACAO//**** A L T E R A C A O *****************************************

     DBSELECTAREA("SW6")
     IF Bof() .AND. Eof()
        SW6->(MsUnlock())
        Return nOpc
     EndIf
     FOR i := 1 TO FCount()
        M->&(FIELDNAME(i)) := FieldGet(i)
     NEXT i

     DI500Controle(0,{M->W6_VLFRECC,M->W6_VLFREPP,M->W6_VLFRETN,M->W6_VLSEGMN,M->W6_VL_USSE,M->W6_SEGBASE,M->W6_SEGPERC,M->W6_TX_FRET})
     lNoBaixa:=.T.
     lNoBaixa:=EICFI400("VAL_CPO_DI")

     lSair:=.F.
     IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ALTERA"),)
     
     If lSair
        SW6->(MsUnlock())
        RETURN nOpc
     EndIf
    
     bValid:={|| E_Valid(aGets,{|C| DI_Valid(C,,.T.)}).AND.DI_Valid("TUDO",.F.,.T.)}
     aOk   :={{|| If(DI600GrvCapa(bValid),FINALIZAR,) },"Grava Capa"}

     AADD(aBotoes1T,{"LJPRECO",{|| IF(DI600AlterValid(bValid,.F.),Processa({|| DI600Taxa(.T.)}),) },"Taxas"})
     AADD(aBotoes1T,{"VERNOTA",{|| IF(DI600AlterValid(bValid,.T.,.F.),DI600Invoices(),)},"Invoices"})
     IF(lTemLote, AADD(aBotoes1T,{"CONTAINR",{|| IF(DI600AlterValid(bValid,.T.,.F.),DI600Lotes(),) },"Lotes"}) ,)// AWR - Lote
     AADD(aBotoes1T,{"SIMULACAO" ,{|| DI600Totais() },STR0382 })
     AADD(aBotoes1T,{"NOVACELULA",{|| DI600Comple() },"Edicao Complemento",,"Edit.Comp"})
     AADD(aBotoes1T,{"NEXT"      ,{|| IF(DI600AlterValid(bValid,.T.,.F.),IF(DI600Itens(),FINALIZAR,),)},"Itens"})

     Processa({|| DI600EIGrava('LEITURA',SW6->W6_HAWB,aAliasCapa)},"Gravando Arquivos Temporarios...")

     //**** A L T E R A C A O *****************************************
CASE nOpc == ESTORNO//*******  E S T O R N O  ******************************************

     IF !EICFI400("VAL_CPO_DI")
        EICFI400('MENSAGEM')
        SW6->(MsUnlock())
        RETURN nOpc
     ENDIF

     lSair:=.F.
     IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ESTORNO"),)
     If lSair
        SW6->(MsUnlock())
        RETURN nOpc
     EndIf

     IF !SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))
        Help(" ",1,"E_NAOHAITE")//NAO HA ITENS PARA O PROCESSAMENTO.
     ELSE
        SF1->(DBSETORDER(5))
        IF SF1->(DBSEEK(xFilial()+SW6->W6_HAWB))
           Help("", 1, "AVG0000250")//'Processo não pode ser estornado, pois possui NF(s) de entrada
           SF1->(DBSETORDER(1))
           SW6->(MsUnlock())
           Return nOpc
        ENDIF
        SX3->(DBSETORDER(2))
        IF (SX6->(DBSEEK(SM0->M0_CODFIL+"MV_EIC_ECO")).OR.SX6->(DBSEEK("  "+"MV_EIC_ECO"))) .AND. EasyGParam("MV_EIC_ECO") $ cSim .AND.;
           SX3->(DBSEEK("W6_CONTAB")) 
           IF !EMPTY(SW6->W6_CONTAB)
              Help("", 1, "AVG0000251")//'Itens do processo não podem ser ESTORNADOS -processo Contabilizado
              SX3->(DBSETORDER(x3ord))
              SW6->(MsUnlock())
              Return nOpc
           ENDIF
        ENDIF
        If lIntDraw .and. lExistW8_AC
           ED2->(dbSetOrder(4))
           If ED2->(dbSeek(cFilED2+SW6->W6_HAWB))
              MsgInfo(STR0508+ED2->ED2_AC+").") //"Processo nao pode ser estornado pois esta apropriado para Drawback (A.C. "
              SW6->(MsUnlock())
              Return nOpc
           EndIf
        EndIf
        SX3->(DBSETORDER(1))
        SF1->(DBSETORDER(1))
        IF !lFinanceiro
           SWA->(DBSETORDER(1))
           IF SWA->(DBSEEK(xFilial()+SW6->W6_HAWB))
              Help("", 1, "AVG0000252")//Processo nao pode ser estornado, pois possui controle de cambio
              SW6->(MsUnlock())
              Return nOpc
           ENDIF
        ENDIF
        IF MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO
           IF _Declaracao
              IF SW7->W7_FLUXO # "4"
                 Help(" ",1,"E_ENTRPNAO")//HOUSE NAO EH ENTREPOSTADO
                 SW6->(MsUnlock())
                 Return nOpc
              ENDIF
           ELSE
              IF SW7->W7_FLUXO = "4"
                 Help(" ",1,"E_ENTRPSIM")//HOUSE EH ENTREPOSTADO
                 SW6->(MsUnlock())
                 Return nOpc
              ENDIF
          ENDIF
        ENDIF
     ENDIF

     IF !SW6->(RecLock("SW6",.F.,.T.))
        Return nOpc
     ENDIF

     DbSelectArea("SW6")
     FOR i := 1 TO FCount()
         M->&(FIELDNAME(i)) := FieldGet(i)
     NEXT

     SW7->(DBSETORDER(1))
     SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))

     aCampos:={"W7_SEQ_LI" ,"W7_PGI_NUM","W7_POSICAO","WP_VENCTO","W7_PO_NUM" ,"W7_CC",;
               "W7_SI_NUM" ,"W5_PO_NUM" ,"W7_COD_I"  ,"W5_DESC_P","W7_FABR"   ,"W5_FABR_N",;
               "W7_FORN"   ,"W5_FORN_N" ,"W7_QTDE"   ,"W7_PRECO" ,"W6_FOB_TOT","W7_HAWB" ,;
               "W9_INVOICE","W9_DT_EMIS","WP_REGIST" ,"W7_PESO"  ,"W7_NCM"    ,"W7_EX_NCM",;
               "W7_EX_NBM"}
     If lIntDraw .and. lExistW8_AC
        aAdd(aCampos,"W5_AC")
     EndIf
     
     //FDR - 13/09/12 - Tratamento de loja
     If EICLoja()
        EICAddLoja(aCampos, "W7_FABLOJ", Nil, "W7_FABR")
        EICAddLoja(aCampos, "W7_FORLOJ", Nil ,"W7_FORN")
     EndIf
     
     aSemSX3:={}
     AADD(aSemSX3,{"WKFLAG"    ,"L",01,0})
     AADD(aSemSX3,{"W7_REG"    ,"N",nTamReg,0})
     AADD(aSemSX3,{"W5_PGI_NUM","C",10,0})
     AADD(aSemSX3,{"WKRECNO"   ,"N",10,0})
     AADD(aSemSX3,{"WK_OK"     ,"C",02,0})
     AADD(aSemSX3,{"WKLOCAL","C",LEN(SC1->C1_LOCAL),0})

     IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ESTORNO_CAMPOS"),)

     cNomArq:=E_CriaTrab(,aSemSX3)
     //MFR OSSME-1974 26/12/2018
     IndRegua("TRB",cNomArq+TeOrdBagExt(),"W7_PGI_NUM+W7_CC+W7_SI_NUM+W7_COD_I")

     aTB_Campos:={}
     AADD(aTB_Campos,{"WK_OK"     ,," " })
     IF MOpcao==FECHTO_NACIONALIZACAO
        AADD(aTB_Campos,{{||TRANS(TRB->W7_PO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,STR0079})//"Nacionalizacao"
     ELSE
        AADD(aTB_Campos,{"W7_PO_NUM" ,,AVSX3("W7_PO_NUM" ,5)})
     ENDIF                       
     AADD(aTB_Campos,{"W7_CC"     ,,AVSX3("W7_CC"     ,5)}) 
     AADD(aTB_Campos,{"W7_SI_NUM" ,,AVSX3("W7_SI_NUM" ,5)}) 
     AADD(aTB_Campos,{"W7_POSICAO",,AVSX3("W7_POSICAO",5)}) 
     AADD(aTB_Campos,{"W7_COD_I"  ,,AVSX3("W7_COD_I"  ,5)}) 
     AADD(aTB_Campos,{"W5_DESC_P" ,,STR0043              }) 
     AADD(aTB_Campos,{"W7_FABR"   ,,AVSX3("W7_FABR"   ,5)})
     //FDR - 13/09/12 - Tratamento de loja
     If EICLoja()
        AADD(aTB_Campos,{"W7_FABLOJ"   ,,AVSX3("W7_FABLOJ"   ,5)})
     EndIf 
     AADD(aTB_Campos,{"W5_FABR_N" ,,AVSX3("W5_FABR_N" ,5)}) 
     AADD(aTB_Campos,{"W7_FORN"   ,,AVSX3("W7_FORN"   ,5)})
     //FDR - 13/09/12 - Tratamento de loja
     If EICLoja()
        AADD(aTB_Campos,{"W7_FORLOJ"   ,,AVSX3("W7_FABLOJ"   ,5)})
     EndIf 
     AADD(aTB_Campos,{"W5_FORN_N" ,,AVSX3("W5_FORN_N" ,5)}) 
     AADD(aTB_Campos,{"W7_QTDE"   ,,AVSX3("W7_QTDE"   ,5),_PictQtde})
     AADD(aTB_Campos,{"W7_PRECO"  ,,AVSX3("W7_PRECO"  ,5),AVSX3("W7_PRECO",6)})
     AADD(aTB_Campos,{"W6_FOB_TOT",,AVSX3("W9_FOB_TOT",5),AVSX3("W6_FOB_TOT",6)})
     AADD(aTB_Campos,{"W7_PESO"   ,,AVSX3("W7_PESO"   ,5),AVSX3("W7_PESO",6)})
     AADD(aTB_Campos,{"W7_NCM"    ,,AVSX3("W3_TEC"    ,5),AVSX3("W3_TEC",6)})
     AADD(aTB_Campos,{"W7_EX_NCM" ,,AVSX3("W3_EX_NCM" ,5),AVSX3("W3_EX_NCM",6)})
     AADD(aTB_Campos,{"W7_EX_NBM" ,,AVSX3("W3_EX_NBM" ,5),AVSX3("W3_EX_NBM",6)})
     AADD(aTB_Campos,{"W9_INVOICE",,AVSX3("W9_INVOICE",5)})
     AADD(aTB_Campos,{"WKLOCAL"   ,,AVSX3("C1_LOCAL",5)})

     If lIntDraw .and. lExistW8_AC
        AADD(aTB_Campos,{"W5_AC",,AVSX3("W5_AC",5)}) //"Ato Concess."
     EndIf

     IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ESTORNO_INDICE_COLUNAS"),)

     IF SW7->(DBSEEK(xFilial()+SW6->W6_HAWB))
        Processa({|| DI600GrvTRB(.T.) },STR0054)//"Pesquisa de Itens"
     ENDIF

     MConta:=0
     aOk:={{|| If(DI600Estorno(),FINALIZAR,) },STR0034} //"Estornar"
              
     AADD(aBotoes1T,{"RESPONSA" ,{|| Processa({|| DI600MarcaAll('TRB',oMark:oBrowse)}) },STR0427,,"Marc/Des"}) //"Marca/Desmarca Todos"
     //*******  E S T O R N O  ******************************************
ENDCASE

IF Inclui .And. EasyGParam("MV_NRDI",,.F.)// JVR - 20/07/09 - Inclusão de preenchimento automatico ambiente ARG.
   M->W6_HAWB := "Automatico" //Inicializado para passar pela validacao da primeira tela.
ENDIF
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ANTES_TELA"),)

DO WHILE .T.
   nOpca:=0
   aGets:={}
   aTela:={}
   lTopo:=.F.
   oMainWnd:ReadClientCoords()//So precisa declarar uma fez para o Programa todo
   DEFINE MSDIALOG oDlg TITLE cTitulo ; 
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

    nLinha :=(oDlg:nClientHeight-4)/2 
    IF nOpc = VISUAL .OR. nOpc = ESTORNO
       nLinha :=MEIO_DIALOG-1
    ENDIF

    oEnCh1:=MsMget():New( cAlias,nReg,nOpc,,,,aCamposMostra,{15,1,nLinha,COLUNA_FINAL},aDarGets,3)  

    IF MOpcao == FECHTO_NACIONALIZACAO .AND. nOpc = INCLUSAO
       M->W6_VM_OBS := cVM_OBS
       M->W6_VM_COMP:= cVM_COMP
    ENDIF

    IF nOpc = VISUAL .OR. nOpc = ESTORNO
       lTopo := .t.
       oMark:=MSSELECT():New("TRB",IF(nOpc=ESTORNO,"WK_OK",NIL),,aTB_Campos,lInverte,cMarca,{MEIO_DIALOG,1,(oDlg:nClientHeight-6)/2,COLUNA_FINAL})
       oMark:oBrowse:bWhen:={||DBSELECTAREA("TRB"),.T.}
       oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT       
    ENDIF

   ACTIVATE MSDIALOG oDlg ON INIT (if(nOpc = VISUAL .OR. nOpc = ESTORNO,oMark:oBrowse:Refresh(),),DI600EnchoiceBar(oDlg,aOk,{|| IF(DI600Sair(nOpc), (nOpca:=1,oDlg:End()),) },,aBotoes1T),;
                     oEnch1:oBox:Align := if(lTopo,CONTROL_ALIGN_TOP,CONTROL_ALIGN_ALLCLIENT))  //TRP-06/11/2007

   IF DI600Mov(nOpca)
      LOOP
   ENDIF

   IF nOpca = 1 .OR. (nOpca = 0 .AND. DI600Sair(nOpc))
      EXIT
   ENDIF

ENDDO

IF SELECT('TRB') # 0
   TRB->(E_EraseArq(cNomArq))
ENDIF

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"FINAL_OPCAO"),)

DI600Fil(.T.)

dbSelectArea("SW6")
SW6->(MSUNLOCK())
Return nOpc
*--------------------------------*
Function DI600Mov(nOp)
*--------------------------------*
LOCAL nRecno:=SW6->(RECNO()), i, D

IF LEN(aTabHouse) # 0
   DO CASE
   CASE nOp == 10
        SW6->(DBSEEK(xFilial("SW6")+aTabHouse[1]))

   CASE nOp == 20
        nPos := ASCAN(aTabHouse,SW6->W6_HAWB)
        IF nPos == 1
           Help("",1,"AVG0000263",,ALLTRIM(cChave),2,6)//(STR0210 + ALLTRIM(cChave) ,STR0057  ) //"Não há processos anteriores a este para o PO : "###"Informação"
        ELSE
           SW6->(DBSEEK(xFilial("SW6")+aTabHouse[nPos-1]))
        ENDIF

   CASE nOp == 30
        nPos := ASCAN(aTabHouse,SW6->W6_HAWB)
        IF nPos == LEN(aTabHouse)
           Help("", 1, "AVG0000262",,ALLTRIM(cChave),2,6)//"Não há processos posteriores a este para o PO : "
        ELSE
           SW6->(DBSEEK(xFilial("SW6")+aTabHouse[nPos+1]))
        ENDIF

   CASE nOp == 40
        SW6->(DBSEEK(xFilial("SW6")+aTabHouse[LEN(aTabHouse)]))

   OTHERWISE 
        RETURN .F.
   ENDCASE

ELSE
   DO CASE
   CASE nOp == 10
        SW6->(DBSEEK(xFilial("SW6")))

   CASE nOp == 20
        SW6->(DBSKIP(-1))
        IF SW6->W6_FILIAL != xFilial("SW6") .Or. SW6->(Bof())
           SW6->(DBSEEK(xFilial("SW6")))
        ENDIF

   CASE nOp == 30
        SW6->(DBSKIP())
        IF SW6->W6_FILIAL != xFilial("SW6") .Or. SW6->(Eof())
           SW6->(AVSeekLast(xFilial("SW6"))) // POSICIONA A ULTIMA OCORRENCIA
        ENDIF

   CASE nOp == 40
        SW6->(AVSeekLast(xFilial("SW6"))) // POSICIONA A ULTIMA OCORRENCIA

   OTHERWISE 
        RETURN .F.
   ENDCASE

ENDIF

IF nRecno == SW6->(RECNO())
   RETURN .T.
ENDIF

FOR i := 1 TO SW6->(FCount())
    M->&(SW6->(FIELDNAME(i))) := SW6->(FieldGet(i))
NEXT

FOR D := 1 TO LEN(aTabelas)
   cAliasZ:="Work_"+aTabelas[D,1]
  (cAliasZ)->(AvZap())
NEXT

Processa({|| DI600GrvTRB(.F.) },STR0054) //"Pesquisa de Itens"

RETURN .T.
*-----------------------------*
Function DI600Sair(nOpc)
*-----------------------------*
IF nOpc = VISUAL .OR. nOpc = ESTORNO
   Return .T.
ENDIF
Return MSGYesNo(STR0506,STR0141)//"Cofirma Saida ?"
*------------------------*
FUNCTION DI600Busca()
*------------------------*
LOCAL cCombo, i
LOCAL aTabItens := {}
aTabIndex:={}
SIX->(DBSEEK("SW6"))
DO WHILE ! SIX->(EOF()) .AND. SIX->INDICE == "SW6"
   IF SIX->(FIELDPOS('SHOWPESQ')) # 0 .AND. SIX->SHOWPESQ = 'N'
      SIX->(DBSKIP())
      LOOP
   ENDIF
   AADD(aTabIndex,{Capital(SIX->DESCRICAO),IF("DTOS" $ UPPER(SIX->CHAVE) .OR. "DTOC" $ UPPER(SIX->CHAVE),SIX->CHAVE,SPACE(100))})
   SIX->(DBSKIP())
ENDDO
SIX->(DBSEEK("SW7"+"2"))
AADD(aTabIndex,{Capital(SIX->DESCRICAO),SPACE(100)})
FOR I := 1 TO LEN(aTabIndex)
    AADD(aTAbItens,aTabIndex[I,1])
NEXT
cCombo := aTabItens[1]
cChave := SPACE(90)
lPorPO := .F.

DO WHILE .T.
   nOpcao   := 0

   DEFINE MSDIALOG oDlg FROM 00,00 TO 150,490 PIXEL TITLE STR0029  OF oMainWnd//"Pesquisa"

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 1, 1) //LRS - 18/09/2017
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @05,05 COMBOBOX oCBX VAR cCombo ITEMS aTabItens SIZE 206,36 PIXEL OF oPanel 

      @22,05 MSGET oBigGet VAR cChave SIZE 206,10 PIXEL OF oPanel

   ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, { || nOpcao:=1, oDlg:End() }, { || oDlg:End() },,,,,,,.F.) CENTERED

   IF nOpcao == 1
      IF cCombo == aTabIndex[Len(aTabIndex),1]
         lPorPO := .T.
      ENDIF                         
      IF !EMPTY(cChave)
         IF !DI600Pesq(cCombo,lPorPO,cChave)
            LOOP
         ENDIF
      ENDIF
   ENDIF

   EXIT

ENDDO

lPorPO:=.F.
aTabHouse:={}

RETURN .T.
*---------------------------------------*
FUNCTION DI600Pesq(cCombo,lPorPO,cChave)
*---------------------------------------*
LOCAL nOrd := SW6->(INDEXORD()),cFilSW7:=xFilial("SW7"),lRet:=.T.
LOCAL nOrdSW7 := SW7->(INDEXORD()), nRecSW7:= SW7->(RECNO())

IF lPorPO 
   aTabHouse := {}
   SW7->(DBSETORDER(2))
   IF SW7->(DBSEEK(cFilSW7+RTrim(cChave)))
      cChave:=SW7->W7_PO_NUM
      DO WHILE !SW7->(EOF()) .AND. SW7->W7_FILIAL == cFilSW7 .AND.; 
                                   SW7->W7_PO_NUM == cChave  
         IF ASCAN(aTabHOUSE,SW7->W7_HAWB) == 0
            AADD(aTabHouse,SW7->W7_HAWB)
         ENDIF
         SW7->(DBSKIP())
      ENDDO
      IF LEN(aTabHouse) # 0
         aTabHouse := ASORT(aTabHouse)
         SW6->(DBSETORDER(1))
         SW6->(DBSEEK(xFilial("SW6")+aTabHouse[1]))
         SW7->(DBSETORDER(nOrdSW7))
         SW7->(DBGOTO(nRecSW7))
         DI600Manut("SW6",SW6->(RECNO()),2)
      ENDIF
   ELSE
      IF !EMPTY(cChave)
         HELP(" ",1,"PESQ01")
         lRet:=.F.
      ENDIF
      SW7->(DBSETORDER(nOrdSW7))
      SW7->(DBGOTO(nRecSW7))
   ENDIF
ELSE
   nPos := ASCAN(aTabIndex,{|var| var[1] ==  cCombo})
   IF nPos # 0
      IF !EMPTY(aTabIndex[nPos,2] )
         cChave:= ALLTRIM(ConvData(aTabIndex[nPos,2],cChave))
      Else
         cChave:= RTrim(cChave)
      ENDIF
      SW6->(DBSETORDER(nPos))
      IF !SW6->(DBSEEK(xFilial("SW6")+cChave)) .AND. !EMPTY(cChave)
         HELP(" ",1,"PESQ01")
         lRet:=.F.
      ENDIF
   ENDIF
ENDIF
SW6->(DBSETORDER(nOrd))

RETURN lRet 
*-----------------------------*
Function DI600Comple()
*-----------------------------*
Local lPVez := .T.//,cInvoiceNew,cProcEndNew,cNewImportEnd

IF EMPTY(Alltrim(M->W6_VM_COMP))
   RETURN .F.
ENDIF        

IF !Inclui .AND. lPrimeiraVez
   Processa({|| DI600Existe() },STR0054) //"Pesquisa de Itens"
ENDIF

PRIVATE cTexto, cInvoice, cHouse, cTermo, cImportador, nTam:=AVSX3("W6_VM_COMP",03) 
PRIVATE cImportEnd, cProcurador, cProcEnd, cRefDes,cData , cMaster

SYT->(dbSetOrder(1))

cTexto   := Alltrim(M->W6_VM_COMP)
cInvoice := ""
Work_SW9->(DBGOTOP())
Do While !Work_SW9->(EOF())
   cInvoice += ALLTRIM(Work_SW9->W9_INVOICE) + ", "
   Work_SW9->(dbSkip())
EndDo

cInvoice:= Left(cInvoice , Len(cInvoice)-2)

cHouse := STR0516+ALLTRIM(M->W6_HOUSE)//"Conhecimento "

cMaster := AVSX3("W6_MAWB",5)+" "+ALLTRIM(M->W6_MAWB)

cTermo := If(M->W6_TIPODOC=="2" .And. !EMPTY(M->W6_IDEMANI),STR0517+M->W6_IDEMANI,"")//"Termo de Entrada "

SYT->(dbSeek(xFilial("SYT")+M->W6_IMPORT))

cImportador:= Alltrim(SYT->YT_NOME)
cImportEnd := Alltrim(SYT->YT_ENDE)+ " nro. "+Alltrim(Str(SYT->YT_NR_END))+", "+Alltrim(SYT->YT_BAIRRO)+" - "+Alltrim(SYT->YT_CIDADE)+" - "+Alltrim(SYT->YT_PAIS)

cProcurador:= Alltrim(SYT->YT_PROC1)
cProcEnd:= Alltrim(SYT->YT_END_PR1)
cRefDes := Alltrim(M->W6_REF_DES)
cData   := DtoC(dDataBase)

If(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"ANTES_TROCA_TEXTO"),)

IF(!EMPTY(cInvoice)   ,cTexto:=StrTran(cTexto , "#INVOICE"               ,STR0518+cInvoice),)// "Fatura: "
IF(!EMPTY(cImportador),cTexto:=StrTran(cTexto , "#IMPORTADOR"            ,cImportador),)
IF(!EMPTY(cImportEnd) ,cTexto:=StrTran(cTexto , "#IMPORTENDE"            ,cImportEnd),)
IF(!EMPTY(M->W6_HOUSE),cTexto:=StrTran(cTexto , "#HOUSE"                 ,cHouse),)
IF(!EMPTY(M->W6_MAWB) ,cTexto:=StrTran(cTexto , "#MASTER"                ,cMaster),)
IF(!EMPTY(cProcurador),cTexto:=StrTran(cTexto , "#PROCURADOR"            ,cProcurador),)
IF(!EMPTY(cProcEnd)   ,cTexto:=StrTran(cTexto , "#ENDERECO_DO_PROCURADOR",cProcEnd),)
IF(!EMPTY(cRefDes)    ,cTexto:=StrTran(cTexto , "#REFERENCIA_DESPACHANTE",cRefDes),)
cTexto := StrTran(cTexto,"#TERMOENTRADA",cTermo)
cTexto := StrTran(cTexto,"#DATA"        ,cData)

If(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"DEPOIS_TROCA_TEXTO"),)

M->W6_VM_COMP := cTexto
lGravaSoCapa:=.F.   

Return .T.

*--------------------------------------------------------------------------------------*
Function DI600Itens()//Antiga DI_SelItem() - Parte do Browse
*--------------------------------------------------------------------------------------*
LOCAL aBotoes:={},oDlgItens,nOpcaoItem

IF !Inclui .AND. lPrimeiraVez
   Processa({|| DI600Existe() },STR0054) //"Pesquisa de Itens"
ENDIF

IF Inclui .AND. lPrimeiraVez
   IF !DI600Selecao()
      RETURN .F.
   ENDIF
ENDIF

aCamposItem:={}
AADD(aCamposItem,{"WKFLAGWIN"  ,,""})
IF MOpcao==FECHTO_NACIONALIZACAO
   AADD(aCamposItem,{{||TRANS(Work->WKPO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,STR0079})//"Nacionalizacao"
ELSE
   AADD(aCamposItem,{"WKPO_NUM",,AVSX3("W2_PO_NUM",5),AVSX3("W2_PO_NUM",6)})
ENDIF                                             
AADD(aCamposItem,{"WKPOSICAO"  ,,AVSX3("W7_POSICAO",5)})
AADD(aCamposItem,{"WKCOD_I"    ,,AVSX3("W7_COD_I"  ,5),AVSX3("W7_COD_I",6)})
AADD(aCamposItem,{"WKPART_N"   ,,AVSX3("A5_CODPRF" ,5)})
AADD(aCamposItem,{"WKDESCR"    ,,AVSX3("B1_DESC_GI",5)})
AADD(aCamposItem,{{||Work->WKFABR+' '+Work->WKNOME_FAB},,AVSX3("W7_FABR",5)})
//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   AADD(aCamposItem,{{|| Work->W7_FABLOJ},,AVSX3("W7_FABLOJ",5)})
EndIf
AADD(aCamposItem,{{||Work->WKFORN+' '+Work->WKNOME_FOR},,AVSX3("W7_FORN",5)})
//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   AADD(aCamposItem,{{|| Work->W7_FORLOJ},,AVSX3("W7_FORLOJ",5)})
EndIf
AADD(aCamposItem,{'WKMOEDA'    ,,AVSX3("W2_MOEDA",5)})
AADD(aCamposItem,{'WKPRECO'    ,,AVSX3("W7_PRECO",5),_PictPrUn})
AADD(aCamposItem,{"WKDISPINV"  ,,STR0428,_PictQtde}) //"Disp p/ Inv."
AADD(aCamposItem,{"WKQTDE_D"   ,,AVSX3("W7_QTDE",5)+IF(MOpcao=FECHTO_EMBARQUE,STR0085,STR0086),_PictQtde}) //###"Embarque"###"Desemb"
AADD(aCamposItem,{"WKSALDO_Q"  ,,AVSX3("W7_SALDO_Q",5),_PictQtde})
AADD(aCamposItem,{"WKPESO_L"   ,,AVSX3("W7_PESO",5)  ,AVSX3("W7_PESO",6)})
AADD(aCamposItem,{"WKTEC"      ,,AVSX3("W3_TEC",5)   ,AVSX3("W3_TEC",6)})
AADD(aCamposItem,{"WKEX_NCM"   ,,AVSX3("W3_EX_NCM",5),AVSX3("W3_EX_NCM",6)})
AADD(aCamposItem,{"WKEX_NBM"   ,,AVSX3("W3_EX_NBM",5),AVSX3("W3_EX_NBM",6)})
AADD(aCamposItem,{"WKLOCAL"    ,,AVSX3("C1_LOCAL",5)})

// Botões removidos da tela e passados para o botão de outras ações -- MPG - 12/09/2018 
AADD(aBotoes,{"VERNOTA"   ,{|| DI600Selecao(oMark:oBrowse)  },LEFT(STR0432,12)   })     //"Seleccion PO / PLI's"
AADD(aBotoes,{"VERNOTA"   ,{|| DI600DigItem(oMark:oBrowse)  },STR0434   })              //"Selecao Itens Digit."

AADD(aBotoes,{"VERNOTA"   ,{|| DI600Invoices(oMark:oBrowse)  },STR0425   })     //"Invoices"
IF(lTemLote, AADD(aBotoes,{"CONTAINR",{|| DI600Lotes() },"Lotes"}) ,)           // AWR - Lote
AADD(aBotoes,{"SIMULACAO" ,{|| DI600Totais(oMark)            },STR0382      })  //"Totais"
IF !lTemCambio
   AADD(aBotoes,{"RESPONSA"  ,{|| Processa({|| DI600MarcaAll('Work',oMark:oBrowse)})},STR0427,,"Marc/Des"}) //"Marca/Desmarca Todos"
ENDIF
AADD(aBotoes,{"PREV"      ,{|| nOpcaoItem:=0,oDlgItens:End()},STR0429,,STR0512}) //"Tela Anterior"
AADD(aBotoes,{"NEXT"      ,{|| nOpcaoItem:=1,oDlgItens:End()},STR0430,,STR0513}) //"Proxima Tela"

nOrder:=3
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"BROWSE_SELECIONA"),)

Private cDigCod_I := CriaVar("W7_COD_I")
Private nDigQtde  := CriaVar("W7_QTDE")
//Private nDigPreco := CriaVar("W7_PRECO")

DO WHILE .T.
   DBSELECTAREA("Work")
   SET FILTER TO
   Work->(dbsetorder(norder))
   Work->(DBGOTOP())
   nOpcaoItem:=0

   DEFINE MSDIALOG oDlgItens TITLE STR0431 ; //"Selecao de Itens"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft +05 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
      @00,00  MSPANEL oPanItem Prompt "" Size 60,37 of oDlgItens
      @8,005 SAY AVSX3("W6_HAWB",5)  of oPanItem PIXEL //'Nr. Processo:'
      @8,136 SAY AVSX3("W6_DT_HAWB",5) of oPanItem PIXEL //'Data:'
      @5.5,040 MSGET M->W6_HAWB     PICT "@!" SIZE 60,8 WHEN .F. of oPanItem PIXEL
      @5.5,170 MSGET M->W6_DT_HAWB  PICT "@D" SIZE 40,8 WHEN .F. of oPanItem PIXEL
      @22,005 SAY AVSX3("W6_HOUSE",5)  of oPanItem  PIXEL //'House / B.L.:'
      @20.5,40  MSGET M->W6_HOUSE              SIZE 60,8 WHEN .F. of oPanItem PIXEL
/*
      @5.5,COLUNA_FINAL_I-85 BUTTON oBtnPOPLI PROMPT LEFT(STR0432,12) SIZE 55,13 ; //"Seleccion PO / PLI's"
                          ACTION (DI600Selecao(oMark:oBrowse)) OF oPanItem PIXEL WHEN !lTemCambio
      oBtnPOPLI:cToolTip:=LEFT(STR0433,20) //"Seleccion de Pedidos e P.L.I.'s"

      @19.5,COLUNA_FINAL_I-85 BUTTON oBtnSel   PROMPT STR0434 SIZE 55,13 ; //"Selecao Itens Digit."
                          ACTION (DI600DigItem(oMark:oBrowse)) OF oPanItem PIXEL WHEN !lTemCambio
      oBtnSel:cToolTip := STR0096 //"Seleção de Itens por Digitação"
*/ // Botões removidos da tela e passados para o botão de outras ações -- MPG - 12/09/2018 

      oMark:=MsSelect():New("Work","WKFLAGWIN",,aCamposItem,lInverte,cMarca,{50,1,(oDlgItens:nClientHeight-6)/2,COLUNA_FINAL_I})
      oMark:bAval:={|x| x:= GetFocus(), DI600MarkItem() , SetFocus(x) }
      oMark:oBrowse:bWhen:={||DBSELECTAREA("Work"),.T.}
      oDlgItens:lMaximized:=.T. //AWR 29/07/04 - Maximilização da janela
   ACTIVATE MSDIALOG oDlgItens ON INIT (DI600EnchoiceBar(oDlgItens, {{|| nOpcaoItem:= 1, oDlgItens:End()}}, {|| oDlgItens:End()},.F.,aBotoes),;
                                        oPanItem:Align:=CONTROL_ALIGN_TOP,;          //AWR 29/07/04
                                        oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT, oMark:oBrowse:Refresh()) //TRP-06/11/1007- Alinhamento MDI 

   IF nOpcaoItem = 1
      IF !DI600Conferencia()
         LOOP
      ENDIF
      RETURN .T.
   ENDIF
   EXIT
ENDDO
RETURN .F.

*--------------------------------------------------------------------------------------*
FUNCTION DI600Conferencia()//Antiga D_Tela4()
*--------------------------------------------------------------------------------------*
LOCAL cTitulo:=STR0111+IF(!_Declaracao,IF(MOpcao=FECHTO_EMBARQUE,STR0085,STR0113),STR0114) //'Grava '###'Embarque'###'D.I.'###'D.A.'
LOCAL oDlg, oMark, nGravou:=0,aOk,aBotoes:={}

PRIVATE oGetInland, oGetPacking, oGetFrete, oGetDesconto, oTotalFob, nTotalFob:=0
PRIVATE MDesconto := MInland := MFrt_Int := MPacking := 0

aCamposConf:={}
IF MOpcao==FECHTO_NACIONALIZACAO
   AADD(aCamposConf,{{||TRANS(Work->WKPO_NUM,AVSX3("W2_PO_NUM",6))+"  "},,STR0079})//"Nacionalizacao"
ELSE
   AADD(aCamposConf,{"WKPO_NUM",,AVSX3("W2_PO_NUM",5),AVSX3("W2_PO_NUM",6)})
ENDIF                                             
AADD(aCamposConf,{"WKPOSICAO" ,, AVSX3("W7_POSICAO",5)})
AADD(aCamposConf,{"WKCOD_I"   ,, AVSX3("W7_COD_I",5),AVSX3("B1_COD",6)})
AADD(aCamposConf,{"WKPART_N"  ,, AVSX3("A5_CODPRF",5)})
AADD(aCamposConf,{{||Work->WKFABR+' '+Work->WKNOME_FAB},, AVSX3("W7_FABR",5)})
//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   AADD(aCamposConf,{{|| Work->W7_FABLOJ},,AVSX3("W7_FABLOJ",5)})
EndIf
AADD(aCamposConf,{{||Work->WKFORN+' '+Work->WKNOME_FOR},, AVSX3("W7_FORN",5)})
//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   AADD(aCamposConf,{{|| Work->W7_FORLOJ},,AVSX3("W7_FORLOJ",5)})
EndIf
AADD(aCamposConf,{"WKDISPINV" ,,STR0428,_PictQtde}) //"Disp p/ Inv."
AADD(aCamposConf,{"WKQTDE"    ,,AVSX3("W7_QTDE",5),_PictQtde})
AADD(aCamposConf,{'WKMOEDA'   ,,AVSX3("W2_MOEDA",5)})
AADD(aCamposConf,{'WKPRECO'   ,,AVSX3("W7_PRECO",5),_PictPrUn})
IF MOpcao = FECHTO_EMBARQUE
   AADD(aCamposConf,{"WKDT_ENTR",,AVSX3("W3_DT_ENTR",5)})
   AADD(aCamposConf,{"WKDT_EMB" ,,AVSX3("W3_DT_EMB" ,5)})
ENDIF
AADD(aCamposConf,{"WKPESO_L"  ,,AVSX3("W7_PESO",5)  ,AVSX3("W7_PESO",6)})
AADD(aCamposConf,{"WKTEC"     ,,AVSX3("W3_TEC",5)   ,AVSX3("W3_TEC",6)})
AADD(aCamposConf,{"WKEX_NCM"  ,,AVSX3("W3_EX_NCM",5),AVSX3("W3_EX_NCM",6)})
AADD(aCamposConf,{"WKEX_NBM"  ,,AVSX3("W3_EX_NBM",5),AVSX3("W3_EX_NBM",6)})
AADD(aCamposConf,{"WKCC"      ,,AVSX3("W0__CC"   ,5),AVSX3("W0__CC",6)})
AADD(aCamposConf,{"WKSI_NUM"  ,,AVSX3("W0__NUM"  ,5),AVSX3("W0__NUM",6)})
AADD(aCamposConf,{"WKLOCAL"   ,,AVSX3("C1_LOCAL",5)})

AADD(aBotoes,{"VERNOTA"   ,{|| DI600Invoices(oMark:oBrowse)},STR0425    }) //"Invoices"
IF(lTemLote, AADD(aBotoes,{"CONTAINR",{|| DI600Lotes() },"Lotes"}) ,)// AWR - Lote
AADD(aBotoes,{"SIMULACAO" ,{|| DI600Totais(oMark)   },STR0382      }) //"Totais"
AADD(aBotoes,{"PREV"      ,{|| nGravou:=0,oDlg:End()},STR0429,,STR0512}) //"Tela Anterior"

aOk:={{||IF(DI600_Grava(),(nGravou:=1,oDlg:End()),)},STR0435} //"Gravar D.I."

nOrderConf:=3

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"BROWSE_CONFERENCIA"),)

DBSELECTAREA("Work")
SET FILTER TO WKFLAG

DO WHILE .T.
   nGravou:=0
   Work->(dbsetorder(nOrderConf))
   Work->(DBGOTOP())

   DEFINE MSDIALOG oDlg TITLE STR0119; //"Conferencia Final"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5;
          TO   oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL  

     oMark:=MsSelect():New("Work",,,aCamposConf,lInverte,cMarca,{18,1,(oDlg:nClientHeight-6)/2,COLUNA_FINAL})
     oMark:oBrowse:bWhen:={||DBSELECTAREA("Work"),.T.}
     oDlg:lMaximized:=.T. //AWR 29/07/04 - Maximiliza Janela	
   ACTIVATE MSDIALOG oDlg ON INIT (DI600EnchoiceBar(oDlg,aOk,,.F.,aBotoes),;
                                   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT, oMark:oBrowse:Refresh()) //TRP-06/11/2007 - Alinhamento MDI

   DBSELECTAREA("Work")
   SET FILTER TO

   IF nGravou = 1
      RETURN .T.
   ENDIF
   EXIT
ENDDO

RETURN .F.
*----------------------------------------------------------------------------*
FUNCTION DI600_Grava()//Antiga DbuDi400B()
*----------------------------------------------------------------------------*
LOCAL lOK:=.T.,lItemOK:=.F.,nOrdSW9:=SW9->(INDEXORD()), nWk
DBSELECTAREA("Work")
SET FILTER TO WKFLAG == .T.

Work->(DBGOTOP())
Work->(DBEVAL({||lItemOK:=.T.},{|| WKFLAG },{|| !lItemOK  } ))
Work->(DBGOTOP())

IF !lItemOK .AND. !Inclui
   Help("",1,"AVG0000701")
// MSGINFO(436,0057) //"Nao existem itens Selecionados."
   RETURN .F.
ENDIF         

IF MOpcao = FECHTO_EMBARQUE
   //Verifica se foi feita alguma invoice no Embarque
   Work->(DBEVAL({||lOK:=.F.},{|| Work->WKDISPINV # Work->WKQTDE .AND. Work->WKFLAG },{|| lOK } ))
   Work->(DBGOTOP())
ENDIF

IF MOpcao # FECHTO_EMBARQUE .OR. !lOK
   //Verifica se foi feito invoices e usado todo o saldo no Embarque ou no Desembaraco
   lOK:=.T.
   Work->(DBEVAL({||lOK:=.F.},{|| !EMPTY(Work->WKDISPINV) .AND. Work->WKFLAG },{|| lOK  } ))
   Work->(DBGOTOP())
ENDIF

IF !lOK 
   Help("",1,"AVG0000702")
// MSGINFO(0437,0057) //"Existem itens ou saldo de itens sem Invoice."
   RETURN .F.
ENDIF         

Work_SW9->(DBSETORDER(1))
Work_SW8->(DBSETORDER(1))
Work_SW9->(DBGOTOP())

DO WHILE !Work_SW9->(EOF())
   IF WORK_SW9->W9_TUDO_OK == NAO .AND.;
      Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ"))) // TDF - 13/09/12 - TRATAMENTO DE LOJA
      IF DI600InvConf(.F.,Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,.T.,EICRetLoja("Work_SW9", "W9_FORLOJ")) // TDF - 13/09/12 - TRATAMENTO DE LOJA
         Processa( {|| DI600InvTotais(.F.,.F.) } )
      ELSE
         RETURN .F.
      ENDIF
   ENDIF
   Work_SW9->(DBSKIP())
ENDDO

lSair:=.F.
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_TUDO"),)
IF lSair
   RETURN .F.
EndIf

IF MSgYesNo(STR0059,STR0141)//'Confirma a Gravação ? '###'Fechamento'

   //JVR - 20/07/09
   If Inclui .And. EasyGParam("MV_NRDI",,.F.)
      xControle := EasyGParam("MV_CTRL_DI",,"999999999999998")
      xControle := Val(xControle)+1
      Do While xControle == 999999999999999              
         MsgStop("MV_CTRL_DI => SX6")
         xControle := EasyGParam("MV_CTRL_DI",,"999999999999998")
         xControle := Val(xControle)+1
      EndDo
      xControle  := PadL(xControle,15,"0")
      M->W6_HAWB := xControle
      SetMV("MV_CTRL_DI",xControle)
      If(EasyEntryPoint("EICDI500"),ExecBlock("EICDI500",.F.,.F.,"CTRL_DI"),)
   EndIf
   SW9->(DbSetOrder(3))
   
   IF Inclui .AND. ( SW7->(DbSeek(xFilial()+M->W6_HAWB)) .Or.;
                     SW8->(DbSeek(xFilial()+M->W6_HAWB)) .Or.;
                     SW9->(DbSeek(xFilial()+M->W6_HAWB)) .Or. ;
                     SW6->(DbSeek(xFilial()+M->W6_HAWB))   )
      MSGINFO(Avsx3("W6_HAWB",5)+" "+Alltrim(M->W6_HAWB)+STR0515,STR0141)//ja Cadastrado,Atencao
      SW9->(DbSetOrder(nOrdSW9))
      //JVR - 20/07/09
      If Inclui .And. EasyGParam("MV_NRDI",,.F.)
         M->W6_HAWB := "Automatico"
      EndIf 
      Return .F.
   ENDIF                     
   
   SW9->(DbSetOrder(nOrdSW9))
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ANT_GRAVA_TUDO"),)

   IF lFinanceiro 
      axFlDelWork:={}
      TP251CriaWork()
      axFl2DelWork:={}
      TP252CriaWork()
   ENDIF

   Begin Transaction   
   
    EICFI400("ANT_GRV_DI","I")
    Processa({|| DI600GravaTudo() },STR0024) //"Fechamento de Desembara‡o"
    EICFI400("POS_GRV_DI","I")

   End Transaction

***** DELETAR ARQUIVO DA FUNCAO AV POS_DI(), QDO TEM CONTROLE DE TRANSACAO
   IF lFinanceiro 
      If Select("WorkTP") # 0
         IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
            WorkTP->(E_EraseArq(axFl2DelWork[1]))
            FOR nWk:=2 TO LEN(axFl2DelWork)
                //MFR OSSME-1974 26/12/2018
                FERASE(axFl2DelWork[nWk]+TeOrdBagExt())
            NEXT
         ENDIF
      ENDIF
   ENDIF   
*******************
   
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"POS_GRAVA_TUDO"),)

   IF Inclui .And. EasyGParam("MV_NRDI",,.F.)//JVR - 20/07/09
      MSGINFO( STR0520+M->W6_HAWB,STR0141)//"Numero do Processo: "###"Atencao"
   ENDIF
   RETURN .T.

ENDIF

RETURN .F.
*---------------------------------------------------------*
Function DI600Selecao(oBrw)//Antiga DI_SelPO()
*---------------------------------------------------------*
LOCAL aOk:={{||IF(DI600POPLIValid(.T.,cPedido,.T.),(nOpcaoSele:=1,oDlgSelec:End()),)},"OK"}
LOCAL bCancel:={|| nOpcaoSele:=0,oDlgSelec:End() },cPO,cGI,lOk:=.T.
PRIVATE oLbx1,oLbx2,oDlgSelec
cPedido:=SPACE(LEN(SW7->W7_PO_NUM ))
cPLI   :=SPACE(LEN(SW7->W7_PGI_NUM))
IF Work->(Easyreccount("Work")) = 0 .AND. Inclui
   aPedido:={}
   aPLI:={}
ENDIF
DO WHILE .T.
    nOpcaoSele:=0
    cTitulo:=LEFT(STR0433,21)//"Seleccion de Pedidos y P.L.I."
    nColD := 500
    nLinD := 500

    DEFINE MSDIALOG oDlgSelec TITLE cTitulo FROM 156,155 TO nLinD, nColD OF oMainWnd PIXEL

        oPanel:= TPanel():New(0, 0, "", oDlgSelec,, .F., .F.,,, 1, 1)
        oPanel:Align := CONTROL_ALIGN_ALLCLIENT

        nLin := 2
        nCol := 04
        @ nLin,nCol SAY AVSX3("W2_PO_NUM",5) OF oPanel //"Pedido"

        nLin := 2
        nCol := 07
        #IFDEF TOP
            SETKEY(VK_F4,{|| DI600HLPW2() })
            @ nLin,nCol MSGET cPedido SIZE 54,8 OF oPanel PICT _PictPO VALID DI600POPLIValid(.T.,cPedido,.F.)
            nCol := 14
            @ nLin,nCol SAY "Help (F4)" OF oPanel
        #ELSE
            @ nLin,nCol MSGET cPedido F3 "SW2" SIZE 55,8 OF oPanel PICT _PictPO VALID DI600POPLIValid(.T.,cPedido,.F.)
        #ENDIF

        IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TELA_SELECAO"),)
        
        nLin := 3
        nCol := 07
        @ nLin,nCol LISTBOX oLbx1 VAR cPO ITEMS aPedido SIZE 50,80 OF oPanel UPDATE

    ACTIVATE MSDIALOG oDlgSelec ON INIT DI600EnchoiceBar(oDlgSelec,aOk,bCancel,.F.) CENTERED

   SETKEY(VK_F4,NIL)

   IF nOpcaoSele = 0
      DI600POFIL()
      RETURN .F.
   ENDIF

   IF Len(cPedido) < LEN(SW7->W7_PO_NUM)
      cPedido:= cPedido+SPACE(LEN(SW7->W7_PO_NUM)-LEN(cPedido))
   ENDIF   

   lOk:=.T.
   Processa({|| lOk:=DI600WorkGrava() },STR0054) //"Pesquisa de Itens"
   IF lOk
      EXIT
   ENDIF
ENDDO
lPrimeiraVez:=.F.
Work->(dbsetorder(3))
Work->(DBGOTOP())
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF
RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION DI600POPLIValid(lPedido,cPedido,lOK)//Antiga DI_ValidPO(lValidPO)
*----------------------------------------------------------------------------*
IF lOK                  
   IF LEN(aPedido) = 0  .AND. LEN(aPLI) = 0
      Help("", 1,"AVG0000703")
//    MSGINFO(09,0057) //"Nao ha Pedidos ou P.L.I.s selecionados."
      RETURN .F.
   ENDIF
   lValidPOPLI:=.T.
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"VALID_OK_PEDIDO_PLI"),)
   RETURN lValidPOPLI
ENDIF

IF Len(cPedido) < LEN(SW2->W2_PO_NUM)
   cPedido:= cPedido+SPACE(LEN(SW2->W2_PO_NUM)-LEN(cPedido))
ENDIF   

IF Len(cPLI) < LEN(SW5->W5_PGI_NUM)
   cPLI:= cPLI+SPACE(LEN(SW5->W5_PGI_NUM)-LEN(cPLI))
ENDIF   

IF lPedido .AND. (EMPTY(cPedido) .OR. ASCAN(aPedido,cPedido) # 0)
   RETURN .T.
ELSEIF !lPedido .AND. (EMPTY(cPLI) .OR. ASCAN(aPLI,cPLI) # 0)
   RETURN .T.
ENDIF

IF lPedido
   SW5->(DBSETORDER(3))
   IF !SW5->(DBSEEK(xFilial()+cPedido))
      IF MOpcao == FECHTO_NACIONALIZACAO
         Help(" ",1,"E_SEMGINAC")//'NAO EXISTE P.L.I. PARA A NACIONALIZACAO INFORMADA
      ELSE
         Help(" ",1,"E_SEMGIPO")//NAO EXISTE P.L.I. PARA O P.O. INFORMADO
      ENDIF
      RETURN .F.
   ENDIF
ELSE
   SW5->(DBSETORDER(1))
   SW4->(DBSETORDER(1))
   IF SW4->(DBSEEK(xFilial()+cPLI)) .AND.;
      SW5->(DBSEEK(xFilial()+cPLI))
      cPedido:=SW5->W5_PO_NUM
   ELSE
      Help(" ",1,"E_GINAOCAD")
      RETURN .F.
   ENDIF
ENDIF

SW3->(DBSETORDER(1))
SW2->(DBSETORDER(1))
IF !SW2->(DBSEEK(xFilial()+cPedido)) .OR.;
   !SW3->(DBSEEK(xFilial()+cPedido))
   IF MOpcao == FECHTO_NACIONALIZACAO
      Help(" ",1,"E_NANAOCAD")//NACIONALIZACAO NAO CADASTRADA
   ELSE
      Help(" ",1,"E_PONAOCAD")//P.O. NAO CADASTRADO
   ENDIF
   RETURN .F.
ENDIF
SW3->(DBSEEK(xFilial()+cPedido))//Posiciona no SW3 quando acha o SW2

If MOpcao#FECHTO_NACIONALIZACAO .AND. ! Empty(Alltrim(SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000089")
   Return .F.
Endif

If MOpcao=FECHTO_NACIONALIZACAO .AND. Empty(Alltrim(SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000088")
   Return .F.
Endif

IF(EMPTY(M->W6_IMPORT),M->W6_IMPORT:=SW2->W2_IMPORT,)

IF M->W6_IMPORT # AvKey(SW2->W2_IMPORT,"W6_IMPORT")//FDR - 17/09/12
   Help(" ",1,"E_IMPDIFER")//O IMPORTADOR DESTE P.O. NAO E M->W6_IMPORT
   Return .F.
ENDIF

/*
IF cPaisLoc # "BRA"
   IF(EMPTY(cMoedaProc),cMoedaProc:=SW2->W2_MOEDA,)
   IF cMoedaProc # SW2->W2_MOEDA
      Help(" ",1,"E_MOEDIFER")//'A MOEDA DESTE P.O. NAO E cMoedaProc
      Return .F.
   ENDIF
ENDIF
*/

lValidPOPLI:=.T.
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"VALID_PEDIDO_PLI"),)
IF !lValidPOPLI
   RETURN .F.
ENDIF

IF !lGetPo
   AADD(aPedido,cPedido)
   Return .T.
EndIf

IF lPedido
   oLbx1:ADD(cPedido)
ELSE
   oLbx2:ADD(cPLI)
ENDIF

Return .T.

*----------------------------------------------------------------------------*
FUNCTION DI600WorkGrava()//Antiga DI_SelItem() - Parte da Validacao
*----------------------------------------------------------------------------*
Local nPLI, nPO
PRIVATE lTemItens:= .F. 
PRIVATE oDlgProc := GetWndDefault()

ProcRegua(LEN(aPLI))
SW4->(DBSETORDER(1))

SW5->(DBSETORDER(1))
FOR nPLI:= 1 TO LEN(aPLI)

    cPli:=aPLI[nPLI]
    IncProc(STR0440+cPli) //"Lendo Itens da PLI: "

    SW4->(DBSEEK(xFilial()+cPli))
    IF !SW4->(RecLock("SW4",.F.))
       RETURN .F.
    ENDIF
    SW5->(DBSEEK(xFilial()+cPli))
    cPedido:=SW5->W5_PO_NUM

    DI600POFIL()

    DBSELECTAREA("Work")
    Work->(DBSETORDER(1))
    Work->(DBSEEK(cPli))
    SET FILTER TO Work->WKPGI_NUM == cPli

    DI600ProcGI({|| SW5->W5_PGI_NUM == cPli},cPli)
    DBSELECTAREA("Work")
    SET FILTER TO

NEXT

ProcRegua(LEN(aPedido))

SW5->(DBSETORDER(3))
FOR nPO:= 1 TO LEN(aPedido)

    cPedido:=aPedido[nPO]
    IncProc(STR0441+cPedido) //"Lendo Itens do Pedido: "

    SW5->(DBSEEK(xFilial()+cPedido))
    cPLI:=SW5->W5_PGI_NUM

    SW4->(DBSEEK(xFilial()+cPLI))
    IF !SW4->(RecLock("SW4",.F.))
       RETURN .F.
    ENDIF

    DI600POFIL()

    DBSELECTAREA("Work")
    Work->(DBSETORDER(2))
    Work->(DBSEEK(cPedido))
    SET FILTER TO Work->WKPO_NUM == cPedido

    DI600ProcGI({|| SW5->W5_PO_NUM == cPedido},cPedido)
    DBSELECTAREA("Work")
    SET FILTER TO

NEXT


DBSELECTAREA("Work")
IF !lTemItens .AND. Inclui
   Help("", 1,"AVG0000704")
// MsgInfo(0442,0057) //"Nao ha Itens a serem selecionados."
   SET FILTER TO
   RETURN .F.
ENDIF
lGravaSoCapa:=.F.   

RETURN .T.
*----------------------------------------------------------------------------*
FUNCTION DI600ProcGI(bWhile,cChave)//Antiga DI_ProcGI(bMsg)
*----------------------------------------------------------------------------*
LOCAL lAchou, MChave, MChave_WK 
LOCAL cFilSW5:=xFilial("SW5")
LOCAL cFilSW2:=xFILIAL("SW2")
SW3->(dbSetOrder(1))
SW9->(DBSETORDER(3))
SA5->(DBSETORDER(3))
cIndice:=Work->(INDEXKEY())

DO WHILE SW5->(!EOF()) .AND. EVAL(bWhile) .AND.;
         SW5->W5_FILIAL  == cFilSW5 

   oDlgProc:SetText(STR0282+ALLTRIM(SW5->W5_COD_I)) //"Lendo Item: "
   
   IF SW5->W5_SEQ <> 0 .OR. SW5->W5_SALDO_Q = 0
      SW5->(DBSKIP()) 
      LOOP
   ENDIF

   SW2->(DBSEEK(cFilSW2+SW5->W5_PO_NUM))

   IF MOpcao = FECHTO_DESEMBARACO
      IF !EMPTY(SW2->W2_HAWB_DA)
         SW5->(DBSKIP())
         LOOP
      ENDIF
   ELSEIF MOpcao = FECHTO_NACIONALIZACAO
      IF EMPTY(SW2->W2_HAWB_DA)
         SW5->(DBSKIP())
         LOOP
      ENDIF
   ENDIF

   IF MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO
      IF _Declaracao
         IF SW5->W5_FLUXO # "4"
            SW5->(DBSKIP()) 
            LOOP
         ENDIF
      ELSE
         IF SW5->W5_FLUXO = "4"
            SW5->(DBSKIP()) 
            LOOP
         ENDIF
      ENDIF
   ENDIF

   lLoop:=.F.
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"SKIP_ITEM_SW5"),)
   IF lLoop
      SW5->(DBSKIP()) 
      LOOP
   ENDIF   

   MChave   := cChave+SW5->W5_CC+SW5->W5_SI_NUM+SW5->W5_COD_I
   MChave_WK:= MChave
   Work->(DBSEEK(MChave))
   lAchou:= .F.
   DO WHILE !Work->(EOF()) .AND. MChave == MChave_Wk
      IF SW5->W5_FABR   # Work->WKFABR .OR. ;
         SW5->W5_FORN   # Work->WKFORN .OR. ;
         SW5->W5_REG    # Work->WKREG  .OR. ;
         SW5->W5_PO_NUM # Work->WKPO_NUM .OR. ;
         (EICLoja() .And. SW5->W5_FORLOJ # Work->W7_FORLOJ) .OR.;//FDR - 13/09/12 - Tratamento de loja
         (EICLoja() .And. SW5->W5_FABLOJ # Work->W7_FABLOJ)
         Work->(DBSKIP())
         MChave_WK := Work->(&(cIndice))//WKPGI_NUM ou WKPO_NUM+WKCC+WKSI_NUM+WKCOD_I
         LOOP
      ENDIF
      lAchou:= .T.
      EXIT
   ENDDO

   IF lAchou
      lTemItens:=.T.
      SW5->(DBSKIP())
      LOOP
   ENDIF

   DI600CarregaWork("W5_")//Grava SW5 no Work
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"CARREGA_WORK"),)
   SW5->(DBSKIP())
   lTemItens:=.T.

ENDDO

RETURN .T.

*----------------------------------------*
Function DI600Invoices(oBrw)
*----------------------------------------*
LOCAL aBotoes:={},nInd,oDlgSW9,nTipo:=2
LOCAL aTelaInv, aGetsInv

IF !Inclui .AND. lPrimeiraVez
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_SW8->(Easyreccount("Work_SW8")) = 0
         Processa({|| DI600InvCarrega()},STR0054) //"Pesquisa de Itens"
      ENDIF
   ELSE
      Processa({|| DI600Existe()    },STR0054) //"Pesquisa de Itens"
   ENDIF
ENDIF                   

aTB_CposSW9:=ArrayBrowse("SW9","WORK_SW9")
AADD(aTB_CposSW9,{"W9_PESO",,STR0444,AVSX3("B1_PESO",6)}) //"Peso Total"
// EOS - incluir no bwowse, logo apos o numero da invoice, o tipo da invoice
ASIZE(aTB_CposSW9, LEN(aTB_CposSW9)+1)
AINS(aTB_CposSW9,1)
aTB_CposSW9[1]:={"WK_TPINV",,"Tipo","@!"} 

aTelaInv:=ACLONE(aTela)
aGetsInv:=ACLONE(aGets)

IF nPos_aRotina # VISUAL 
   IF !lTemCambio
      AADD(aBotoes,{'EDIT', {|| DI600W9Manut(1)},STR0031}) //"Incluir"
   ENDIF
   AADD(aBotoes,{'IC_17', {|| DI600W9Manut(2)},STR0032}) //"Alterar"
   IF !lTemCambio
      AADD(aBotoes,{'EXCLUIR', {|| DI600W9Manut(3)},STR0153}) //"Excluir"
   ENDIF
   AADD(aBotoes,{"SIMULACAO", {|| DI600Totais(oMarkSW9)  },STR0382 }) //"Totais"
ELSE
   AADD(aBotoes,{'PESQUISA', {|| DI600W9Manut(4)},STR0450,,"Visuali."}) //"Visualizacao"
   nTipo:=4
ENDIF
AADD(aBotoes,{"PREV",{|| oDlgSW9:End()},STR0429,,STR0512}) //"Tela Anterior"

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"BROWSE_WORK_SW9"),)

DO WHILE .T.

   aGets:={}
   aTela:={}
   Work_SW9->(DBGOTOP())

   DEFINE MSDIALOG oDlgSW9 TITLE STR0446; //"Manutencao de Invoices"
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
          TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd PIXEL

   oMarkSW9:=MSSELECT():New("WORK_SW9",,,aTB_CposSW9,lInverte,cMarca,{15,1,(oDlgSW9:nClientHeight-6)/2,(oDlgSW9:nClientWidth-4)/2})
   oMarkSW9:bAval:={|| DI600W9Manut(nTipo)} 
   oDlgSW9:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlgSW9 ON INIT (DI600EnchoiceBar(oDlgSW9,,,.F.,aBotoes),;
                                     oMarkSW9:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT, oMarkSW9:oBrowse:Refresh()) //TRP-06/11/2007 - Alinhamento MDI
   EXIT
ENDDO
DBSELECTAREA("Work_SW8")
SET FILTER TO

aTela:=ACLONE(aTelaInv)
aGets:=ACLONE(aGetsInv)
Work->(DBGOTOP())
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF
RETURN .T.

*--------------------------------------------------*
FUNCTION DI600W9Manut(nTipo)
*--------------------------------------------------*
LOCAL oDlgW9Manut,cTituto:='',nInd,lErro:=.F.,nOpcao:=0
LOCAL cNomeQtde:=AVSX3("W7_QTDE",5) ,cPictQtde:=AVSX3("W7_QTDE",6)
LOCAL cPictPrec:=AVSX3("W7_PRECO",6),cPictFob :=AVSX3("W6_FOB_TOT",6)
LOCAL nRec:=WORK_SW9->WK_RECNO, W
LOCAL aValida:={"W9_INVOICE","W9_DT_EMIS","W9_FORN","W9_MOE_FOB","W9_COND_PA","W9_INCOTER"}
LOCAL bValid:={|| DI600InvValid(,,aValida) }
LOCAL aOk:={{||IF(EVAL(bValid),(nOpcao:=1,oDlgW9Manut:End()),)},"OK"}
LOCAL bCancel:={||nOpcao:=0,oDlgW9Manut:End()}
LOCAL oDlgTpInv, nOpTpInv:=0
LOCAL lTopo, cAlias:="SW9"
LOCAL cFilter//LRS - 05/05/2017
PRIVATE aDarGetsSW9,aCamposSW8:={},nPos_SW8aRotina,aBotaoSW9:=NIL
PRIVATE aPictures:={AVSX3("W9_INLAND" ,6),AVSX3("W9_PACKING",6),AVSX3("W9_DESCONT",6),;
                    AVSX3("W9_FRETEIN",6),AVSX3("W9_OUTDESP",6)}
PRIVATE nTpInv := 1
         
aCposEncho := {"W9_INVOICE", "W9_DT_EMIS", "W9_FORN"  , "W9_MOE_FOB", "W9_TX_FOB" ,;
               "W9_COND_PA", "W9_DIAS_PA", "W9_INLAND", "W9_PACKING", "W9_FRETEIN",;
               "W9_DESCONT", "W9_OUTDESP"}                    
// EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc 
   AADD(aCposEncho,"W9_SEGURO")
ENDIF                  

//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   aAdd(aValida   , "W9_FORLOJ")
   aAdd(aCposEncho, "W9_FORLOJ")//FDR - 22/11/2012
EndIf

DO CASE
CASE nTipo = 1
     // EOS - Qdo inclusao, escolhe o tipo da invoice (se normal ou sem itens)
     DEFINE MSDIALOG oDlgTpInv TITLE STR0519 FROM 9,10 TO 17,48 Of oMainWnd
        @08,05 TO 43,70 OF oDlgTpInv PIXEL
        @16,10 RADIO nTpInv ITEMS STR0520,STR0521 3D SIZE 49,12 PIXEL  

        @20,105 BUTTON "OK" SIZE 30,11 ACTION (nOpTpInv:=1,oDlgTpInv:End()) OF oDlgTpInv PIXEL 
        @35,105 BUTTON "Cancel" SIZE 30,11 ACTION (nOpTpInv:=0,oDlgTpInv:End()) OF oDlgTpInv PIXEL 
     ACTIVATE MSDIALOG oDlgTpInv CENTERED

     If nOpTpInv = 0
        RETURN NIL
     ENDIF
   
     IF nTpInv==1 .AND. WORK->(BOF()) .AND. WORK->(EOF())
        Help("", 1,"AVG0000705")//"Nao ha itens de Pedidos/P.L.I.s para inclusao de Invoices"
        RETURN NIL
     ENDIF

     cTituto:=STR0447 //"Inclusao"
     nPos_SW8aRotina:=INCLUSAO
     DBSELECTAREA("SW9")
     FOR nInd := 1 TO FCount()
         M->&(FIELDNAME(nInd)) := CRIAVAR(FIELDNAME(nInd))
     NEXT     
     M->WK_TPINV := nTpInv

CASE nTipo = 2
     cTituto:=STR0448 //"Alteracao"
     nPos_SW8aRotina:=ALTERACAO
     DBSELECTAREA("WORK_SW9")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     FOR nInd := 1 TO FCount()
        M->&(FIELDNAME(nInd)) := FieldGet(nInd)
     NEXT i
     DI600WorkSW8()           
     IF lTemCambio
        aDarGetsSW9:={"W9_TX_FOB"}
     ENDIF

CASE nTipo = 3
     aOk:={{||IF(MSGYESNO(STR0165,STR0141),(nOpcao:=1,oDlgW9Manut:End()),)},"OK"}
     cTituto:=STR0449 //"Exclusao"
     aDarGetsSW9:={}
     nPos_SW8aRotina:=ALTERACAO
     DBSELECTAREA("WORK_SW9")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     FOR nInd := 1 TO FCount()
        M->&(FIELDNAME(nInd)) := FieldGet(nInd)
     NEXT i

     IF !DI600LoteVal("EXCLUI_LOTE") // AWR - LOTE
        RETURN .F.
     ENDIF

     DI600WorkSW8()

CASE nTipo = 4
     cTituto:=STR0450 //"Visualizacao"
     aOk:={{||nOpcao:=0,oDlgW9Manut:End()},STR0421} //"Sair"
     bCancel:=NIL
     nPos_SW8aRotina:=VISUAL
     SW9->(DBGOTO(nRec))
     DBSELECTAREA("WORK_SW9")
     IF Bof() .AND. Eof()
        Return .F.
     EndIf
     FOR nInd := 1 TO FCount()
        M->&(FIELDNAME(nInd)) := FieldGet(nInd)
     NEXT i
     IF WORK_SW9->WK_TPINV == 2
        cAlias:="EZZ"
        aCposEncho:=NIL
        EZZ->(DBGOTO(nRec))
        DBSELECTAREA("EZZ")
        FOR nInd := 1 TO FCount()
           M->&(FIELDNAME(nInd)) := FieldGet(nInd)
        NEXT
     ELSE
        DI600WorkSW8()
     ENDIF
ENDCASE        

IF M->WK_TPINV==2
   aValida:={"W9_INVOICE","W9_DT_EMIS","W9_FORN","W9_MOE_FOB","W9_COND_PA"}
ENDIF

IF nTipo # 3 .AND. nTipo # 4
   AADD(aCamposSW8,{"WKFLAGIV"  ,,""})
ENDIF
AADD(aCamposSW8,{"WKPO_NUM"  ,,AVSX3('W8_PO_NUM' ,5)})
AADD(aCamposSW8,{"WKCOD_I"   ,,AVSX3('W8_COD_I'  ,5)})
AADD(aCamposSW8,{"WKFABR"    ,,AVSX3('W8_FABR'   ,5)})
//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   AADD(aCamposSW8,{"W8_FABLOJ",, AVSX3('W8_FABLOJ'   ,5)})
EndIf
AADD(aCamposSW8,{"WKQTDE"    ,,AVSX3("W8_QTDE"   ,5),cPictQtde})
AADD(aCamposSW8,{"WKPRECO"   ,,AVSX3("W8_PRECO"  ,5),cPictPrec})
AADD(aCamposSW8,{"WKPRTOTMOE",,AVSX3("W9_FOB_TOT",5),cPictFob })
IF lLerFOBPuro
   AADD(aCamposSW8,{"WKPRECO_F" ,,AVSX3("W8_PRECO_F",5),AVSX3("W8_PRECO_F",6)})
ENDIF
If lIntDraw .and. lExistW8_AC
   AADD(aCamposSW8,{"WKAC"  ,,AVSX3("W8_AC" ,5)})
ENDIF
AADD(aCamposSW8,{"WKINLAND"  ,,AVSX3("W8_INLAND" ,5),aPictures[1]})
AADD(aCamposSW8,{"WKPACKING" ,,AVSX3("W8_PACKING",5),aPictures[2]})
AADD(aCamposSW8,{"WKDESCONT" ,,AVSX3("W8_DESCONT",5),aPictures[3]})
AADD(aCamposSW8,{"WKFRETEIN" ,,AVSX3('W8_FRETEIN',5),aPictures[4]})
AADD(aCamposSW8,{"WKOUTDESP" ,,AVSX3("W8_OUTDESP",5),aPictures[5]})
// EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc
   AADD(aCamposSW8,{"WKSEGURO" ,,AVSX3("W8_SEGURO",5),AVSX3("W8_SEGURO",6)})
ENDIF
AADD(aCamposSW8,{"WKPESO_L"  ,,AVSX3("W7_PESO"   ,5),AVSX3("W7_PESO",6)})
AADD(aCamposSW8,{"WKPESOTOT" ,,STR0444           ,AVSX3("W7_PESO",6)}) //"Peso Total"
AADD(aCamposSW8,{"WKTEC"     ,,AVSX3("W8_TEC"    ,5)})
AADD(aCamposSW8,{"WKPOSICAO" ,,AVSX3("W8_POSICAO",5)})

lAlteraDesp := .T.//Alteracao de INLAND, PACKING, DESCONTO, FRETE, OUTRAS DESPESAS
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"BROWSE_WORK_SW8"),)

aTela:={}
aGets:={}
DO WHILE .T.

   nOpcao:=0   
   aBotaoSW9:=NIL
   IF nTipo == 2 //Alteracao
      nPos_SW8aRotina:=ALTERACAO
      nOpcao  := 0   
      bCancel := {||nOpcao:=0,oDlgW9Manut:End()}
      aBotaoSW9 :={}   
      IF M->WK_TPINV == 1 // EOS - So para invoices normais
         IF lAltDescricao 
            AADD(aBotaoSW9,{'EDIT',{|| DI600GetDesc()},STR0451}) //"Alterar Descricao do Item"
         ENDIF
         IF !lTemCambio 
            AADD(aBotaoSW9,{"RESPONSA",{|| Processa({|| DI600MarcaAll('Work_SW8',oMarkItens:oBrowse)})},STR0427,,"Marc/Des"}) //"Marca/Desmarca Todos"
         ENDIF
         AADD(aBotaoSW9,{"FORM"    ,{|| Processa({|| DI600InvTotais(.T.,.F.,oMarkItens:oBrowse) })},STR0452,,"Prorratea"}) //"Rateia Despesas"
      ENDIF
   ENDIF

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TELA_INVOICES"),)
   lTopo:= .F. //LRL 25/03/04
   DEFINE MSDIALOG oDlgW9Manut TITLE cTituto+STR0453  ;  //" de Invoice"
             FROM oMainWnd:nTop+125,oMainWnd:nLeft+5;
             TO   oMainWnd:nBottom-60,oMainWnd:nRight-10 OF oMainWnd PIXEL
             
   IF nTipo = 1 .OR. M->WK_TPINV == 2 //Inclui ou invoice especial
      nMeio:=(oDlgW9Manut:nClientHeight-6)/2
   ELSE                  
      nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )-10             
      DBSELECTAREA("Work_SW8")
      Work_SW8->(DBSETORDER(2))
      //LRS - 05/05/2017 - Mudanca no filtro para funcionar corretamente
      IF nTipo = 2 .OR. nTipo = 3 .OR. nTipo = 4   // Exclusao ou Alteracao ou Visualização
         If !EICLoja()
            cFilter := "Work_SW8->WKINVOICE+Work_SW8->WKFORN==Work_SW9->W9_INVOICE+Work_SW9->W9_FORN"
         ELSE
            cFilter := "(EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == Work_SW9->W9_FORN+Work_SW9->W9_MOE_FOB) .OR.  Work_SW8->WKINVOICE+Work_SW8->WKFORN == Work_SW9->W9_INVOICE+Work_SW9->W9_FORN"
         ENDIF      
      ElseIf nTipo = 1 //FDR - 22/12/2012 - Inclusão
         cFilter := "Work_SW8->WKINVOICE==Space(Len(Work_SW8->WKINVOICE))"
      ENDIF

      Work_SW8->(DBEVAL({|| If(&cFilter,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
      Work_SW8->( DbSetFilter({|| Work_SW8->WKFILTRO == 'S'},"Work_SW8->WKFILTRO == 'S'") )

      DBGOTOP()
      oMarkItens:=MSSELECT():New('Work_SW8',IF(nTipo#3,'WKFLAGIV',),,aCamposSW8,lInverte,cMarca,{nMeio,1,(oDlgW9Manut:nClientHeight-6)/2,(oDlgW9Manut:nClientWidth-4)/2})
      oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA('Work_SW8'),.T.} 
      IF nTipo # 3 .AND. nTipo # 4 .AND. !lTemCambio
         oMarkItens:bAval:={|| DI600SW8Get()}
      ELSE
         oMarkItens:bAval:={|| .T. }
      ENDIF   
      lTopo:=.T.
      oMarkItens:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //Alinhamento MDI
      IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"SELECT_INVOICES"),)
   ENDIF   
   
   oEnCh2:=MsMGet():New(cAlias,nRec,nPos_SW8aRotina,,,,IF(M->WK_TPINV==2,aCposEncho,),{15,1,nMeio,(oDlgW9Manut:nClientWidth-4)/2 },aDarGetsSW9,3)

   M->W9_NOM_FOR:=BuscaFabr_Forn(M->W9_FORN, EICRetLoja("M", "W9_FORLOJ")) //TDF - 13/09/12 - TRATAMENTO DE LOJA
   
   oDlgW9Manut:lMaximized:=.T. //AWR 29/07/04 - Maximiliza Janela MDI
   ACTIVATE MSDIALOG oDlgW9Manut ON INIT (If(nTipo <> 1 .AND. M->WK_TPINV <> 2,oMarkItens:oBrowse:Refresh(),), DI600EnchoiceBar(oDlgW9Manut,aOk,bCancel,.F.,aBotaoSW9),;
                     oEnch2:oBox:Align := if(lTopo,CONTROL_ALIGN_TOP,CONTROL_ALIGN_ALLCLIENT)) // CENTERED

   IF nOpcao == 1
      lGravaSoCapa:=.F.
      IF nTipo = 1  //Inclui
         IF nTpInv == 1  //EOS
            IF !DI600WorkSW8()
               Help("", 1,"AVG0000706")
//             MSGINFO(0454,0057) //"Nao ha Itens de Pedidos e P.L.I.s para esse Fornecedor e Moeda"
               LOOP
            ENDIF
         ENDIF
         WORK_SW9->(DBAPPEND())
         AVReplace("M","WORK_SW9")
         nTipo:=2
         IF nTpInv == 1
            LOOP
         ELSE
            EXIT
         ENDIF

      ELSEIF nTipo = 2//Altera
         aDados:={}
         lZera :=.F.
         FOR W := 1 TO WORK_SW9->(FCOUNT())
            AADD(aDados,{WORK_SW9->(FIELDGET(W)),})
            IF !lZera .AND. WORK_SW9->(FIELD(W)) $ "W9_INCOTER,W9_COND_PA,W9_DIAS_PA" .AND.;
               WORK_SW9->(FIELDGET(W)) # EVAL(FieldBlock(WORK_SW9->(FIELD(W))))
               lZera:= .T.
            ENDIF
         NEXT
         AVReplace("M","WORK_SW9")
         Processa( {|| DI600InvTotais(.F.,.F.,,.F.,.F.)} )
         IF DI600InvConf(.T.,Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,.F.,EICRetLoja("Work_SW9", "W9_FORLOJ")) //TDF - 13/09/12 - TRATAMENTO DE LOJA
            Processa( {|| DI600InvTotais(.F.,lZera)} )
         ENDIF
         FOR W := 1 TO WORK_SW9->(FCOUNT())
            aDados[W,2]:=WORK_SW9->(FIELDGET(W))
         NEXT

      ELSEIF nTipo = 3 //Exclui
         DBSELECTAREA("Work_SW8")
         SET FILTER TO 
         Work_SW8->(DBSETORDER(1))
         DO WHILE Work_SW8->(DBSEEK(WORK_SW9->W9_INVOICE+WORK_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ"))) //TDF - 13/09/12 - TRATAMENTO DE LOJA
            DI600InvMarca('D')
            WORK_SW8->(DBDELETE())
            Work_SW8->(DBSKIP())
         ENDDO
         IF !EMPTY(Work_SW9->WK_RECNO)
            AADD(aDeletados,{"SW9",Work_SW9->WK_RECNO})
         ENDIF
         WORK_SW9->(DBDELETE())
         WORK_SW9->(DBGOTOP())
      ENDIF

   ENDIF
   EXIT
ENDDO

DBSELECTAREA("Work_SW8")
Work_SW8->(DBSETORDER(1))
SET FILTER TO
DBSELECTAREA("Work_SW9")
oMarkSW9:oBrowse:Refresh()

RETURN .T.
*-----------------------------------------------*
FUNCTION DI600GetDesc()
*-----------------------------------------------*
LOCAL oDLGDescr,lGrava:=.F.,aBotoes:={},lCarrega:=.F.
PRIVATE mDescGet:=Work_SW8->WKDESC_DI
DEFINE FONT oFont NAME "Courier New" SIZE 0,15

AADD(aBotoes,{"NOVACELULA",{|| lCarrega:=.T.,oDLGDescr:End()},STR0526}) //"Carrega Descricao"

DO WHILE .T.

   DEFINE MSDIALOG oDLGDescr TITLE STR0455 From 15,00 To 32,54 OF oMainWnd  //"Alteracao de Descricao"

// @14,2 GET mDescGet SIZE 203,100 PIXEL OF oDLGDescr HSCROLL
     oDLGDescr:SetFont(oFont)
     @17,2 GET mDescGet MEMO HSCROLL SIZE 203,100 OF oDLGDescr PIXEL

   ACTIVATE MSDIALOG oDLGDescr ON INIT DI600EnchoiceBar(oDLGDescr,;
                                       {{||lGrava:=.T.,oDLGDescr:End()},"OK"},;
                                        {||lGrava:=.F.,oDLGDescr:End()},.F.,aBotoes) CENTERED 
   IF lCarrega
      IF Empty(mDescGet) .OR. MSGYESNO(STR0527,"Descricao GI") //"Deseja sobrepor descricao atual?"
         SB1->(dbSetorder(1))
         SB1->(dbSeek(xFilial("SB1")+Work_SW8->WKCOD_I))
         mDescGet:=MSMM(SB1->B1_DESC_GI,AvSx3("B1_VM_GI",3)) 
         mDescGet:=STRTRAN(mDescGet,CHR(13)+CHR(10),' ')
         IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ALTERA_DESCR_ITEM"),)
      ENDIF
      lCarrega:=.F.
      LOOP
   ENDIF

   IF lGrava
      Work_SW8->WKDESC_DI:=STRTRAN(mDescGet,CHR(13)+CHR(10),' ')
   ENDIF

   EXIT

ENDDO

RETURN lGrava
*----------------------------------------*
FUNCTION DI600WorkSW8()
*----------------------------------------*
LOCAL nRet:= .F.
DBSELECTAREA("Work_SW8")
SET FILTER TO
Work_SW8->(DBSETORDER(1)) 
WORK->(DBGOTOP())       
//ATENCAO: QUALQUER ALTERACAO NA LOGICA DESTA FUNCAO DEVERA SER ANALIZADO SE NAO AFETARA
//O RDMAKE  DA EMBRAER NO PONTO DE ENTRADA "CARREGA_WORK"

DO WHILE ! WORK->(EOF())

   IF !WORK->WKFLAG
      WORK->(DBSKIP())
      LOOP
   ENDIF
   IF WORK->WKMOEDA <> M->W9_MOE_FOB 
      WORK->(DBSKIP())
      LOOP
   ENDIF
   IF WORK->WKFORN <> M->W9_FORN .And. (!EICLoja() .Or. WORK->W7_FORLOJ <> M->W9_FORLOJ)//FDR - 13/09/12 - Tratamento de loja
      WORK->(DBSKIP())
      LOOP
   ENDIF
   lLoop:=.F.
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"SKIP_ITEM_SW8"),)
   IF lLoop
      WORK->(DBSKIP())
      LOOP
   ENDIF   
   
   IF Work_SW8->(DBSEEK(M->W9_INVOICE+WORK->WKFORN+EICRetLoja("Work", "W7_FORLOJ")+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM)) //TDF - 13/09/12 - TRATAMENTO DE LOJA
      Work_SW8->WKSALDO_AT:= Work_SW8->WKQTDE + WORK->WKDISPINV 
      Work_SW8->WKSALDO:= 0
   ELSE                  
      IF EMPTY(WORK->WKDISPINV)
         WORK->(DBSKIP())
         LOOP
      ENDIF   
      IF !Work_SW8->(DBSEEK(SPACE(LEN(SW9->W9_INVOICE))+WORK->WKFORN+EICRetLoja("Work", "W7_FORLOJ")+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM)) //TDF - 13/09/12 - TRATAMENTO DE LOJA
         Work_SW8->(DBAPPEND())
         //Grava os campos WKPO_NUM,WKPOSICAO,WKPGI_NUM,WKCOD_I,WKFORN,WKFABR,WKPESO_L,
         //WKCC,WKSI_NUM,WKREG,WKSEQ_LI,WKFLUXO,WKREGIST,WKTEC,Work->WKEX_NCM,WKEX_NBM
      ENDIF
      AVREPLACE('Work','Work_SW8')
      Work_SW8->WKCOND_PA :=M->W9_COND_PA
      Work_SW8->WKDIAS_PA :=M->W9_DIAS_PA
      Work_SW8->WKMOEDA   :=M->W9_MOE_FOB
      Work_SW8->WKINCOTER :=M->W9_INCOTER
      Work_SW8->WKQTDE    :=WORK->WKDISPINV
      Work_SW8->WKPRECO   :=WORK->WKPRECO
      Work_SW8->WKPRTOTMOE:=DI600Trans(WORK->WKPRECO*Work_SW8->WKQTDE)
      Work_SW8->WKSALDO_AT:=WORK->WKDISPINV
      Work_SW8->WKRECNO   :=WORK->(RECNO())      
      Work_SW8->WKSALDO   :=0    
      
      //FDR - 13/09/12 - Tratamento de loja
      If EICLoja()
         WORK_SW8->W8_FORLOJ := Work->W7_FORLOJ
         WORK_SW8->W8_FABLOJ := Work->W7_FABLOJ
      EndIf
      
   ENDIF   
   nRet:= .T.
   WORK->(DBSKIP())
   
ENDDO

RETURN nRet
*------------------------------*
FUNCTION DI600SW8Get()
*------------------------------*
LOCAL oDlgTela,oFobTotal,cFornecedor,cFabricante,nopca,nRecno:=Work_SW8->(RECNO())
Local cAto:="", nLinBox, nL12, nL13, nLBotao
LOCAL nL2, nL3, nL4, nL5, nL6, nL7, nL8, nL9, nL10, nL11, nC2, nC3, nLFinal
PRIVATE nL1, nC1 // RAD porque eh usado no ponto de entrada 14/06/2006 
nFobTotal:=0

nL1:=10 ; nL2:=23 ; nL3:=036 ; nL4:=49   ; nL5 :=062 
nL6:=75 ; nL7:=88 ; nL8:=101 ; nL9:= 114 ; nL10:=127 ; nL11:=140
nL12:=153 ; nL13:=166 ; nLFinal:=45 ; nLinBox:=13 ; nLBotao := 167
nC1:=8  ; nC2:=56 ; nC3:=88
If lIntDraw .and. lExistW8_AC
   nLFinal:=46 ; nLinBox:=14 ; nLBotao:=181
EndIf

DBSELECTAREA("Work_SW8")
SET FILTER TO

IF !EMPTY(Work_SW8->WKFLAGIV)
   IF DI600LoteVal("TEM_LOTE_AVISO",,,WORK_SW8->(WKFORN+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE))// AWR - Lote
      RETURN .F.// AWR - Lote
   ENDIF
   DI600InvMarca('D')
   DBSELECTAREA("Work_SW8")
   /*
   //FDR - 13/09/12 - Tratamento de loja
   If EICLoja()
      SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB)
   Else
      SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB)
   EndIf
   */
   If ("CTREE" $ RealRDD())
      If !EICLoja()
         Work_SW8->(DBEVAL({||;
         If(Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. ;
         (Work_SW8->WKINVOICE == Space(Len(Work_SW8->WKINVOICE)) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB);
         ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         Work_SW8->( DbSetFilter({|| Work_SW8->WKFILTRO == 'S'},"Work_SW8->WKFILTRO == 'S'") )
      Else
         Work_SW8->(DBEVAL({||;
         If(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. ;
         (Work_SW8->WKINVOICE == Space(Len(Work_SW8->WKINVOICE)) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB);
         ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
         Work_SW8->( DbSetFilter({|| Work_SW8->WKFILTRO == 'S'},"Work_SW8->WKFILTRO == 'S'") )
      EndIf
   Else
      If EICLoja()
         SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB)
      Else
         SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB)
      EndIf
   EndIf
   
   Work_SW8->(DBGOTO(nRecno))
   oMarkItens:oBrowse:Refresh()
   RETURN .T.
ENDIF

SA2->(DBSETORDER(1))
SA2->(DBSEEK(xFilial("SA2")+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ"))) //TDF - 13/09/12 - TRATAMENTO DE LOJA
cFornecedor:=SA2->A2_NREDUZ

SA2->(DBSEEK(xFilial("SA2")+Work_SW8->WKFABR+EICRetLoja("Work_SW8", "W8_FABLOJ"))) //TDF - 13/09/12 - TRATAMENTO DE LOJA
cFabricante:=SA2->A2_NREDUZ

nSaldo   :=Work_SW8->WKQTDE
nPreco   :=Work_SW8->WKPRECO
nInland  :=Work_SW8->WKINLAND
nPacking :=Work_SW8->WKPACKING
nDesconto:=Work_SW8->WKDESCONT
nFrete   :=Work_SW8->WKFRETEIN
nOutDesp :=Work_SW8->WKOUTDESP
// EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc
	nSeguro := Work_SW8->WKSEGURO
ENDIF
nFobTotal:=DI600Trans(nSaldo * nPreco)
If(lIntDraw .and. lExistW8_AC, cAto:=Work_SW8->WKAC ,)

DEFINE MSDIALOG odlgTela TITLE STR0456 From 15,03 To nLFinal,46 OF oMainWnd  //"Seleciona Item da Invoice"

   oPnl:= TPanel():New(0, 0, "", oDlgTela,, .F., .F.,,, 90, 165) //LRS - 18/09/2017
   oPnl:Align:= CONTROL_ALIGN_ALLCLIENT

   @nL1,nC1 SAY AVSX3("W7_COD_I",5)   SIZE 40,8 OF oPnl PIXEL
   @nL1,nC2 MSGET Work_SW8->WKCOD_I   PICTURE AVSX3("W7_COD_I",6) SIZE 95,08 OF oPnl PIXEL WHEN .F.
                                       
   @nL2,nC1 SAY AVSX3("W7_FABR",5)    SIZE 40,8 OF oPnl PIXEL//'Fabricante'
   @nL2,nC2 MSGET cFabricante PICTURE '@!'  SIZE 95,08 OF oPnl PIXEL WHEN .F.

   @nL3,nC1 SAY AVSX3("W7_FORN",5)    SIZE 40,8 OF oPnl PIXEL//'Fornecedor'
   @nL3,nC2 MSGET cFornecedor PICTURE '@!' SIZE 95,08 OF oPnl PIXEL WHEN .F.

   @nL4,nC1 SAY AVSX3("W7_SALDO_Q",5) SIZE 40,08 OF oPnl PIXEL//Saldo Qtde
   @nL4,nC2 MSGET nSaldo   PICTURE _PictQtde VALID DI600InvValid('SALDO',oFobTotal) SIZE 80,08 OF oPnl PIXEL

   @nL5,nC1 SAY AVSX3("W8_PRECO",5)   SIZE 40,8 OF oPnl PIXEL//Preco 
   @nL5,nC2 MSGET nPreco   PICTURE _PictPrUn VALID DI600InvValid('PRECO',oFobTotal)  SIZE 80,08 OF oPnl PIXEL WHEN .F.

   @nL6,nC1 SAY AVSX3("W9_FOB_TOT",5) SIZE 50,8 OF oPnl PIXEL//Preco Total
   @nL6,nC2 MSGET oFobTotal VAR nFobTotal PICTURE _PictPrUn SIZE 80,08 OF oPnl WHEN .F. PIXEL

   @nL7,nC1 SAY AVSX3("W8_INLAND",5)  SIZE 50,8 OF oPnl PIXEL //Inland
   @nL7,nC2 MSGET nInland   PICTURE aPictures[1] VALID DI600InvValid('INLAND')  SIZE 80,08 OF oPnl PIXEL WHEN lAlteraDesp

   @nL8 ,nC1 SAY AVSX3("W8_PACKING",5) SIZE 50,8 OF oPnl PIXEL //Packing
   @nL8 ,nC2 MSGET nPacking PICTURE aPictures[2] VALID DI600InvValid('PACKING') SIZE 80,08 OF oPnl PIXEL WHEN lAlteraDesp

   @nL9,nC1 SAY  AVSX3("W8_DESCONT",5) SIZE 50,8 OF oPnl PIXEL //Desconto
   @nL9,nC2 MSGET nDesconto PICTURE aPictures[3] VALID DI600InvValid('DESCONTO') SIZE 80,08 OF oPnl PIXEL WHEN lAlteraDesp

   @nL10,nC1 SAY AVSX3("W8_FRETEIN",5) SIZE 50,8 OF oPnl PIXEL//Int'l Freigh
   @nL10,nC2 MSGET nFrete   PICTURE aPictures[4] VALID DI600InvValid('FRETE')   SIZE 80,08 OF oPnl PIXEL WHEN lAlteraDesp

   @nL11,nC1 SAY AVSX3("W8_OUTDESP",5) SIZE 50,8 OF oPnl PIXEL
   @nL11,nC2 MSGET nOutDesp PICTURE aPictures[5] VALID DI600InvValid('OUTDESP') SIZE 80,08 OF oPnl PIXEL WHEN lAlteraDesp

   nL := nL12
   // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
      @nL,nC1 SAY AVSX3("W8_SEGURO",5) SIZE 50,8 OF oPnl PIXEL
      @nL,nC2 MSGET nSeguro PICTURE AVSX3("W8_SEGURO",6) Valid DI600InvValid('SEGURO') SIZE 95,08 OF oPnl PIXEL WHEN (lAlteraDesp .and. !lTemCambio)
      nL+=13
   EndIf
   IF lLerFOBPuro
      nPrecoF   :=Work_SW8->WKPRECO_F
      bValPreco :=AVSX3("W8_PRECO_F",7)
      bWhenPreco:=AVSX3("W8_PRECO_F",13)
      @nL,nC1 SAY AVSX3("W8_PRECO_F",5) SIZE 50,8 OF oPnl PIXEL
      @nL,nC2 MSGET nPrecoF PICTURE AVSX3("W8_PRECO_F",6) VALID (EVAL(bValPreco)) SIZE 80,08 OF oPnl PIXEL WHEN (EVAL(bWhenPreco))
   ENDIF

   @0.2,0.3 TO nLinBox,20 OF oPnl

ACTIVATE MSDIALOG oDlgTela ON INIT EnchoiceBar(oDlgTela, { || nOpca:=1, oDlgTela:End() }, { || nOpca:=0, oDlgTela:End() },,,,,,,.F.) CENTERED

IF nOpca==1
   Work_SW8->WKOUTDESP :=nOutDesp
   Work_SW8->WKQTDE    :=nSaldo
   Work_SW8->WKPRECO   :=nPreco
   Work_SW8->WKINLAND  :=nInland
   Work_SW8->WKPACKING :=nPacking
   Work_SW8->WKDESCONT :=nDesconto
   Work_SW8->WKFRETEIN :=nFrete
   Work_SW8->WKOUTDESP :=nOutDesp
   // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
      Work_SW8->WKSEGURO := nSeguro
   ENDIF
   IF lLerFOBPuro
      Work_SW8->WKPRECO_F := nPrecoF
   ENDIF
   DI600InvMarca('M')
ENDIF
DBSELECTAREA("Work_SW8")

//FDR - 13/09/12 - Tratamento de loja
If ("CTREE" $ RealRDD())
    If !EICLoja()
        Work_SW8->(DBEVAL({||;
        If(Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR.;
        (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB);
        ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
        Work_SW8->( DbSetFilter({|| Work_SW8->WKFILTRO == 'S'},"Work_SW8->WKFILTRO == 'S'") )
    Else
        Work_SW8->(DBEVAL({||;
        If(Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR.;
        (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB);
        ,Work_SW8->WKFILTRO:="S",Work_SW8->WKFILTRO:="")}))
        Work_SW8->( DbSetFilter({|| Work_SW8->WKFILTRO == 'S'},"Work_SW8->WKFILTRO == 'S'") )
    EndIf
Else
    If !EICLoja()
        SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB)
	Else
	   SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB)
	EndIf 
EndIf

Work_SW8->(DBGOTO(nRecno))
oMarkItens:oBrowse:Refresh()   
RETURN .T.      

*----------------------------------------------------------*
FUNCTION DI600InvValid(cCampo,oObjeto,aValida)
*----------------------------------------------------------*
LOCAL C
IF aValida # NIL
   If !Obrigatorio(aGets,aTela)
      RETURN .F.
   Endif

   //TDF - 13/09/12 - TRATAMENTO DE LOJA E HAWB NA CHAVE DA INVOICE
   SW9->(DBSETORDER(1))                                      	
   SW9->(DBSEEK(xFilial("SW9")+M->W9_INVOICE+M->W9_FORN+EICRetLoja("M", "W9_FORLOJ")+M->W6_HAWB))
   DO WHILE !SW9->(EOF()) .AND. ;
             SW9->W9_FILIAL  == xFilial("SW9") .AND. ;
             SW9->W9_INVOICE == M->W9_INVOICE  .AND. ;
             SW9->W9_FORN    == M->W9_FORN .AND. nPos_SW8aRotina = INCLUSAO .AND. ;
             (!EICLoja() .Or. SW9->W9_FORLOJ == M->W9_FORLOJ)//FDR - 13/09/12 - Tratamento de loja
      IF SW9->W9_HAWB <> M->W6_HAWB
         MSGINFO(STR0528+SW9->W9_HAWB,STR0529+ALLTRIM(M->W9_INVOICE)+" / "+ALLTRIM(M->W9_FORN)) //"Invoice ja cadastrada para o Processo: "###"Invoice/Fornecedor :"
         RETURN .F.
      ENDIF   
      SW9->(DBSKIP())
   ENDDO
   IF M->WK_TPINV == 2 .AND. lExistEZZ
      // EOS - invoices especiais
      EZZ->(DBSETORDER(2))
      EZZ->(DBSEEK(xFilial("EZZ")+M->W9_INVOICE+M->W9_FORN))
      DO WHILE !EZZ->(EOF()) .AND. ;
                EZZ->EZZ_FILIAL  == xFilial("EZZ") .AND. ;
                EZZ->EZZ_INVOICE == M->W9_INVOICE  .AND. ;
                EZZ->EZZ_FORN    == M->W9_FORN .AND. nPos_SW8aRotina = INCLUSAO
         IF EZZ->EZZ_HAWB <> M->W6_HAWB
            MSGINFO(STR0528+EZZ->EZZ_HAWB,STR0529+ALLTRIM(M->W9_INVOICE)+" / "+ALLTRIM(M->W9_FORN)) //"Invoice ja cadastrada para o Processo: "###"Invoice/Fornecedor :"
            RETURN .F.
         ENDIF   
         EZZ->(DBSKIP())
      ENDDO 
   ENDIF  
   IF !POSITIVO(M->W9_FRETEIN)
      RETURN .F.
   ELSEIF EMPTY(M->W9_FRETEIN) .AND. M->W9_FREINC $ cNao .AND.;
      M->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP" .AND. M->WK_TPINV == 1
      Help(" ",1,"E_FREVALOR")//VALOR DO FRETE NAO INFORMADO
      RETURN .F.      
   ENDIF
   // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)   
   IF lSegInc
      IF !POSITIVO(M->W9_SEGURO)
         RETURN .F.
      ELSEIF EMPTY(M->W9_SEGURO) .AND. M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP" .AND. M->W9_SEGINC $ cNao .AND. M->WK_TPINV == 1
	     Help(" ",1,"E_SEGVALOR")//VALOR DO SEGURO NAO INFORMADO
         RETURN .F.
      ELSEIF !EMPTY(M->W9_SEGURO) .AND. !(M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP")
		 MSGINFO("VALOR DO SEGURO DEVE SER INFORMADO SOMENTE QUANDO O INCOTERM TIVER NEGOCIACAO DE SEGURO !")  		
		 M->W9_SEGURO := 0
      ENDIF
     
   ENDIF  
   FOR C:=1 TO LEN(aValida)
      cCampo:='M->'+ALLTRIM(aValida[C])
      cCampo:=&(cCampo)
      IF EMPTY(cCampo)
         Help("", 1, "AVG0000721",,AVSX3(cCampo,5),1,8)
//       MSGINFO(ALLTRIM(+0457,0057) //" nao preenchido"
         RETURN .F.
      ENDIF
   NEXT 
   IF M->WK_TPINV == 2
      IF DI600RetVal( "TOT_INV, SEM_FOB", "MEMO", .T.) <= 0 // EOB - 03/06/08 - chamada da função DI500RetVal
         MSGINFO(STR0522)
         RETURN .F. 
      ENDIF
   ENDIF
   RETURN .T.
ENDIF
         
IF cCampo == NIL
   cCampo:=UPPER(READVAR())
ENDIF
IF Left(cCampo,3) == "M->"
   cCampo:=Subs(cCampo,4)
ENDIF
  
DO CASE
   CASE cCampo=="W9_INVOICE"
      IF !NaoVazio(M->W9_INVOICE)         
         RETURN .F. 
      //TDF - 13/09/12 - TRATAMENTO DE LOJA E HAWB NA CHAVE DA INVOICE           
      ELSEIF !EMPTY(M->W9_FORN) .And. (!EICLoja() .Or. !Empty(M->W9_FORLOJ)) .AND. WORK_SW9->(DBSEEK(M->W9_INVOICE+M->W9_FORN+EICRetLoja("M", "W9_FORLOJ")+M->W6_HAWB))
         Help(" ",1,"JAGRAVADO")
         RETURN .F.
      ENDIF

   CASE cCampo=="W9_MOE_FOB"
      IF !ExistCpo("SYE",M->W9_MOE_FOB,2)
         RETURN .F.
      ENDIF
      IF EMPTY(M->W9_TX_FOB)
         M->W9_TX_FOB:=BuscaTaxa(M->W9_MOE_FOB,If(!EMPTY(M->W6_DTREG_D),M->W6_DTREG_D,dDataBase),.T.,.F.,.T.)       //NCF - 27/07/09 - Busca taxa pela data de reg. da DI
      Endif                                                                                                         //                 se esta data estiver pre-enchida.
      /*
      IF EMPTY(M->W9_TX_FOB) .AND. lBuscaTaxaAuto .AND. cPaisLoc == "ARG"
         M->W9_TX_FOB := BuscaTaxa(M->W9_MOE_FOB,If(!EMPTY(M->W6_DTREG_D),M->W6_DTREG_D,DI500DtTxInv()),.T.,.F.,.T.)
         //aOrdSW := SaveOrd({"SW6","SW9"})
      Endif                
      */
   CASE cCampo=="W9_FORN"
      IF !NaoVazio(M->W9_FORN) .OR. !ExistCpo("SA2",M->W9_FORN)
         RETURN .F.      
      //TDF - 13/09/12 - TRATAMENTO DE LOJA E HAWB NA CHAVE DA INVOICE
      ELSEIF WORK_SW9->(DBSEEK(M->W9_INVOICE+M->W9_FORN+EICRetLoja("M","W9_FORLOJ")+M->W6_HAWB))
         Help(" ",1,"JAGRAVADO")
         RETURN .F.
      ENDIF   
   
   //FDR - 13/09/12 - Tratamento de loja
   CASE cCampo=="W9_FORLOJ"
      If EICLoja() .AND. !Empty(M->W9_FORLOJ)
         SA2->(DBSETORDER(1))
         If SA2->(DbSeek(xFilial("SA2")+M->W9_FORN+M->W9_FORLOJ))
            M->W9_NOM_FOR := SA2->A2_NREDUZ
         Else
            Return .F.      
         EndIf
      EndIf
      
   CASE cCampo=="W9_FRETEIN"
      IF !POSITIVO(M->W9_FRETEIN)
         RETURN .F.
      ELSEIF EMPTY(M->W9_FRETEIN) .AND. M->W9_FREINC $ cNao .AND.;
         M->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"
         Help(" ",1,"E_FREVALOR")//VALOR DO FRETE NAO INFORMADO
         RETURN .F.            
      ENDIF
   // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)   
   CASE cCampo=="W9_SEGURO"
      IF !POSITIVO(M->W9_SEGURO)
         RETURN .F.
      ELSEIF EMPTY(M->W9_SEGURO) .AND. M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP".AND. M->W9_SEGINC $ cNao
         Help(" ",1,"E_SEGVALOR")//VALOR DO SEGURO NAO INFORMADO
         RETURN .F.
      ELSEIF !EMPTY(M->W9_SEGURO) .AND. !(M->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP")
		 MSGINFO("VALOR DO SEGURO DEVE SER INFORMADO SOMENTE QUANDO O INCOTERM TIVER NEGOCIACAO DE SEGURO !")  		
		 M->W9_SEGURO := 0
      ENDIF

   CASE cCampo=="SALDO" 
      IF nSaldo>Work_SW8->WKSALDO_AT
         Help("", 1,"AVG0000707")
//       MSGINFO(0458,0057) //"Quantidade maior que saldo disponivel"
         RETURN .F.
      ELSEIF !POSITIVO(nSaldo)
         RETURN .F.
      ELSEIF !NaoVazio(nSaldo)//EMPTY(nSaldo)
//       Help(" ",1,"E_SALDOQTD")//SALDO DE QUANTIDADE NAO PREENCHIDO
         RETURN .F.         
      ENDIF   
      nFobTotal:=DI600Trans(nSaldo * nPreco)
      oObjeto:Refresh()
   
   CASE cCampo=="PRECO"
      IF !POSITIVO(nPreco)
         RETURN .F.
      ELSEIF !NaoVazio(nPreco)
         RETURN .F.
      ENDIF
      nFobTotal:=DI600Trans(nSaldo * nPreco)
      oObjeto:Refresh()
   
   CASE cCampo=="INLAND"
      IF !POSITIVO(nInland)
         RETURN .F.
      ENDIF                     
   
   CASE cCampo=="PACKING"         
      IF !POSITIVO(nPacking)
         RETURN .F.
      ENDIF                             
   
   CASE cCampo=="FRETE"         
      IF !POSITIVO(nFrete)
         RETURN .F.
      ENDIF

   // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)   
   CASE cCampo=="SEGURO"         
      IF !POSITIVO(nSeguro)
         RETURN .F.
      ENDIF
   CASE cCampo=='OUTDESP'   
      IF !POSITIVO(nOutDesp)
         RETURN .F.
      ENDIF                             

   CASE cCampo=="DESCONTO"
      IF !POSITIVO(nDesconto)
         RETURN .F.
      ELSEIF nDesconto>nFobTotal+nInland+nPacking+nOutDesp
         Help("",1,"AVG0000708")
//       MSGINFO(0459,0057) //"Desconto maior que a soma FOB TOTAL + Inland + Packing + Outras Despesas"
         RETURN .F.   
      ENDIF

   CASE cCampo=="PRECO_F"         
      IF nPrecoF >= nFobTotal
         MSGSTOP("Precio FOB no puede ser mayor que precio CIF.")
         RETURN .F.
      ENDIF

ENDCASE

RETURN .T.
*----------------------------------------------------------------*                    
FUNCTION DI600InvConf(lSoma,cInvoice,cForn,lPerg,cForLoj) // TDF - 13/09/12 - TRATAMENTO DE LOJA
*----------------------------------------------------------------*                    
LOCAL aConf :={}, nConf
LOCAL nRecno:=Work_SW8->(RECNO())
LOCAL nOrder:=Work_SW8->(INDEXORD())

Work_SW8->(DBSETORDER(1))
IF !Work_SW8->(DBSEEK(cInvoice+cForn+If(EICLoja(), cForLoj, ""))) .AND. lSoma //FDR - 13/09/12 - Tratamento de loja
    Work_SW8->(DBGOTO(nRecno))
    Work_SW8->(DBSETORDER(nOrder))
   RETURN .F.
ENDIF

AADD(aConf,{0,WORK_SW9->W9_INLAND })
AADD(aConf,{0,WORK_SW9->W9_PACKING})
AADD(aConf,{0,WORK_SW9->W9_DESCONT})
AADD(aConf,{0,WORK_SW9->W9_OUTDESP})
IF Work_SW9->W9_FREINC $ cSim
   AADD(aConf,{0,0})
ELSE
   AADD(aConf,{0,WORK_SW9->W9_FRETEIN})
ENDIF
AADD(aConf,{0,WORK_SW9->W9_FOB_TOT})
// EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc
   IF Work_SW9->W9_SEGINC $ cSim
      AADD(aConf,{0,0})
   ELSE
      AADD(aConf,{0,WORK_SW9->W9_SEGURO})
   ENDIF                
ENDIF

DO WHILE Work_SW8->(!EOF())           .AND.;
         Work_SW8->WKINVOICE==cInvoice.AND.;
         Work_SW8->WKFORN   ==cForn   .AND. lSoma .And.;
         (!EICLoja() .Or. Work_SW8->W8_FORLOJ == cForLoj)//FDR - 13/09/12 - Tratamento de loja

   IF EMPTY(Work_SW8->WKFLAGIV)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   aConf[1,1]+=Work_SW8->WKINLAND
   aConf[2,1]+=Work_SW8->WKPACKING
   aConf[3,1]+=Work_SW8->WKDESCONT
   aConf[4,1]+=Work_SW8->WKOUTDESP
   aConf[5,1]+=Work_SW8->WKFRETEIN
   aConf[6,1]+=Work_SW8->WKPRTOTMOE
   // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
      aConf[7,1]+=Work_SW8->WKSEGURO
   ENDIF 
   Work_SW8->(DBSKIP())

ENDDO

IF lSoma
   Work_SW8->(DBGOTO(nRecno))
   Work_SW8->(DBSETORDER(nOrder))
   FOR nConf := 1 TO LEN(aConf)
      IF STR(aConf[nConf,2],18,2) # STR(aConf[nConf,1],18,2)
         lPerg := .T.
         Work_SW9->W9_TUDO_OK:=NAO
      ENDIF
   NEXT
ENDIF

IF lPerg
   RETURN MSGYESNO(STR0510,;//"As somatorias dos valores dos itens difere dos totais na capa da Invoice, Deseja acertar?"
                   STR0283+ALLTRIM(cInvoice)+"/"+cForn)//"Lendo Invoice: "
ENDIF

RETURN .F.

*------------------------------------------------------------------------*                    
FUNCTION DI600InvTotais(lMemoria,lZeraAdicao,oBrw,lRatFrete,lRatPorFOB)
*------------------------------------------------------------------------*                    
LOCAL aAcertos:={},nCont:=0,nRecno:=Work_SW8->(RECNO())
LOCAL nRecFRE:=nRecVlr:=1,nOrder:=Work_SW8->(INDEXORD())
LOCAL nMaiorFre:=nMaiorVlr:=0,lCalcula:=.F.,cTipoRat:='',A
LOCAL cInvoice,cForn,nINLAND:=nPACKING:=nDESCONT:=nOUTDESP:=nFRETEIN:=0
LOCAL nSEGURO:=0, lCalSeg := .F. // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
DEFAULT lRatFrete  := .T.
DEFAULT lRatPorFOB := .T.
lGravaSoCapa:=.F.
lRDMemoria:=lMemoria
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"RATEIA_DESP_INV"),)
lSair:= !lRatFrete .AND. !lRatPorFOB

ProcRegua(20)
IF lMemoria
   cInvoice :=M->W9_INVOICE
   cForn    :=M->W9_FORN
   //FDR - 13/09/12 - Tratamento de loja
   If EICLoja()
      cLoja := M->W9_FORLOJ
   EndIf
   IF lRatPorFOB
      nINLAND :=M->W9_INLAND 
      nPACKING:=M->W9_PACKING
      nDESCONT:=M->W9_DESCONT
      nOUTDESP:=M->W9_OUTDESP
      // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         nSEGURO := M->W9_SEGURO 
         lCalSeg := M->W9_SEGINC $ cNao
      ENDIF      
   ENDIF
   IF lRatFrete 
      nFRETEIN:=M->W9_FRETEIN
      lCalcula:=M->W9_FREINC $ cNao
      cTipoRat:=M->W9_RAT_POR
   ENDIF
ELSE
   cInvoice :=Work_SW9->W9_INVOICE
   cForn    :=Work_SW9->W9_FORN
   //FDR - 13/09/12 - Tratamento de loja
   If EICLoja()
      cLoja := Work_SW9->W9_FORLOJ
   EndIf
   IF lRatPorFOB
      nINLAND :=WORK_SW9->W9_INLAND 
      nPACKING:=WORK_SW9->W9_PACKING
      nDESCONT:=WORK_SW9->W9_DESCONT
      nOUTDESP:=WORK_SW9->W9_OUTDESP
      // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         nSEGURO := WORK_SW9->W9_SEGURO
         lCalSeg := WORK_SW9->W9_SEGINC $ cNao
      ENDIF       
   ENDIF
   IF lRatFrete 
      nFRETEIN:=WORK_SW9->W9_FRETEIN
      lCalcula:=WORK_SW9->W9_FREINC $ cNao
      cTipoRat:=WORK_SW9->W9_RAT_POR
   ENDIF
ENDIF

Work_SW8->(DBSETORDER(1))
IF !Work_SW8->(DBSEEK(cInvoice+cForn+IF(EICLoja(), cLoja, "")))//FDR - 13/09/12 - Tratamento de loja
   Work_SW8->(DBSETORDER(nOrder))
   Work_SW8->(DBGOTO(nRecno))
   RETURN .F.
ENDIF

IF !lSair
   AADD(aAcertos,{0,nINLAND })
   AADD(aAcertos,{0,nPACKING})
   AADD(aAcertos,{0,nDESCONT})
   AADD(aAcertos,{0,nOUTDESP})
   AADD(aAcertos,{0,nFRETEIN})
   // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
	   AADD(aAcertos,{0,nSEGURO})
   ENDIF
ENDIF

IF lRatFrete 
   WORK_SW9->W9_QTDE:=0
ENDIF

M->W9_FOB_TOT:=0
WORK_SW9->W9_PESO   :=0
WORK_SW9->W9_FOB_TOT:=0

DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==cInvoice .AND.;
                                  Work_SW8->WKFORN   ==cForn .And.;
                                  (!EICLoja() .Or. WORK_SW8->W8_FORLOJ == cLoja)//FDR - 13/09/12 - Tratamento de loja
   IF nCont > 10 
      ProcRegua(10) ; nCont:=0
   ENDIF
   IncProc(STR0460+Work_SW8->WKCOD_I) //"Canculando Item: "
   nCont++

   IF !EMPTY(Work_SW8->WKFLAGIV)
      IF !lMemoria
         Work_SW8->WKCOND_PA:= WORK_SW9->W9_COND_PA
         Work_SW8->WKDIAS_PA:= WORK_SW9->W9_DIAS_PA
         Work_SW8->WKMOEDA  := WORK_SW9->W9_MOE_FOB
         Work_SW8->WKINCOTER:= WORK_SW9->W9_INCOTER
      ELSE
         M->W9_FOB_TOT += Work_SW8->WKPRTOTMOE
      ENDIF
      IF !EMPTY(nFRETEIN) .AND. lRatFrete 
         Work_SW9->W9_QTDE  += Work_SW8->WKQTDE
      ENDIF
      Work_SW9->W9_PESO   += Work_SW8->WKPESOTOT
      Work_SW9->W9_FOB_TOT+= Work_SW8->WKPRTOTMOE
      IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"SOMA_DESP_INV"),)
   ENDIF   

   Work_SW8->(DBSKIP())

ENDDO

M->W9_TUDO_OK:=Work_SW9->W9_TUDO_OK:=SIM

IF lSair
   RETURN .F.
ENDIF

Work_SW8->(DBSEEK(cInvoice+cForn+If(EICLoja(), cLoja, "")))//FDR - 13/09/12 - Tratamento de loja

DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==cInvoice .AND.;
                                  Work_SW8->WKFORN   ==cForn .And.;
                                  (!EICLoja() .Or. Work_SW8->W8_FORLOJ == cLoja)//FDR - 13/09/12 - Tratamento de loja
   IF nCont > 10 
      ProcRegua(10) ; nCont:=0
   ENDIF
   IncProc(STR0460+Work_SW8->WKCOD_I) //"Canculando Item: "
   nCont++
   IF EMPTY(Work_SW8->WKFLAGIV)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF lRatPorFOB
      Work_SW8->WKINLAND  :=DI600Trans((Work_SW8->WKPRTOTMOE/WORK_SW9->W9_FOB_TOT)*nINLAND )
      Work_SW8->WKPACKING :=DI600Trans((Work_SW8->WKPRTOTMOE/WORK_SW9->W9_FOB_TOT)*nPACKING)
      Work_SW8->WKDESCONT :=DI600Trans((Work_SW8->WKPRTOTMOE/WORK_SW9->W9_FOB_TOT)*nDESCONT)
      Work_SW8->WKOUTDESP :=DI600Trans((Work_SW8->WKPRTOTMOE/WORK_SW9->W9_FOB_TOT)*nOUTDESP)
   ENDIF

   IF !EMPTY(nFRETEIN) .AND. lRatFrete 
      IF lCalcula
         DO CASE
            CASE cTipoRat == "1" //Peso
                 Work_SW8->WKFRETEIN:=DI600Trans((Work_SW8->WKPESOTOT/WORK_SW9->W9_PESO   )*nFRETEIN)
            CASE cTipoRat == "2" //Preco
                 Work_SW8->WKFRETEIN:=DI600Trans((Work_SW8->WKPRTOTMOE/WORK_SW9->W9_FOB_TOT)*nFRETEIN)
            CASE cTipoRat == "3" //Quantidade                   
                 Work_SW8->WKFRETEIN:=DI600Trans((Work_SW8->WKQTDE   /WORK_SW9->W9_QTDE   )*nFRETEIN)
         ENDCASE   
      ELSE
         Work_SW8->WKFRETEIN:=0
      ENDIF   
   ELSEIF lRatFrete 
      Work_SW8->WKFRETEIN:=0
   ENDIF   
   
   // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc 
      IF !EMPTY(nSEGURO) .AND. lRatPorFOB
         IF lCalSeg
            Work_SW8->WKSEGURO:=DI600Trans((Work_SW8->WKPRTOTMOE/WORK_SW9->W9_FOB_TOT)*nSEGURO)
         ELSE
            Work_SW8->WKSEGURO:=0
         ENDIF
      ELSE
         Work_SW8->WKSEGURO:=0
      ENDIF
   ENDIF
   IF lRatPorFOB
      aAcertos[1,1]+=Work_SW8->WKINLAND
      aAcertos[2,1]+=Work_SW8->WKPACKING
      aAcertos[3,1]+=Work_SW8->WKDESCONT
      aAcertos[4,1]+=Work_SW8->WKOUTDESP
      // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         aAcertos[6,1]+=Work_SW8->WKSEGURO
      ENDIF
   ENDIF
   IF lRatFrete 
      aAcertos[5,1]+=Work_SW8->WKFRETEIN
   ENDIF

   IF lRatPorFOB .AND. Work_SW8->WKPRTOTMOE > nMaiorVlr
      nMaiorVlr:=Work_SW8->WKPRTOTMOE
      nRecVlr  :=Work_SW8->(RECNO())
   ENDIF   

   IF lRatFrete .AND. Work_SW8->WKFRETEIN > nMaiorFre
      nMaiorFre:=Work_SW8->WKFRETEIN
      nRecFre  :=Work_SW8->(RECNO())
   ENDIF   

   Work_SW8->(DBSKIP())

ENDDO   

IF lRatPorFOB
   Work_SW8->(DBGOTO(nRecVlr))
   FOR A := 1 TO 4
      IF !EMPTY(aAcertos[A,1]) .AND.  aAcertos[A,2] # aAcertos[A,1]
         IF(A=1,Work_SW8->WKINLAND += DI600Trans(aAcertos[A,2] - aAcertos[A,1]),)
         IF(A=2,Work_SW8->WKPACKING+= DI600Trans(aAcertos[A,2] - aAcertos[A,1]),)
         IF(A=3,Work_SW8->WKDESCONT+= DI600Trans(aAcertos[A,2] - aAcertos[A,1]),)
         IF(A=4,Work_SW8->WKOUTDESP+= DI600Trans(aAcertos[A,2] - aAcertos[A,1]),)
      ENDIF
   NEXT
ENDIF

IF lRatFrete 
   IF !EMPTY(nFRETEIN) .AND. lCalcula
      Work_SW8->(DBGOTO(nRecFre))
      IF !EMPTY(aAcertos[5,1]) .AND. aAcertos[5,2] # aAcertos[5,1]
         Work_SW8->WKFRETEIN+=DI600Trans(aAcertos[5,2] - aAcertos[5,1])
      ENDIF
   ENDIF
ENDIF

// EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc .AND. lRatPorFOB
   IF !EMPTY(nSEGURO) .AND. lCalSeg
      Work_SW8->(DBGOTO(nRecVlr))
      IF !EMPTY(aAcertos[6,1]) .AND. aAcertos[6,2] # aAcertos[6,1]
         Work_SW8->WKSEGURO+=DI600Trans(aAcertos[6,2] - aAcertos[6,1])
      ENDIF
   ENDIF
ENDIF
Work_SW8->(DBSETORDER(nOrder))
Work_SW8->(DBGOTO(nRecno))
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF

RETURN .T.                          
*------------------------------------*
Function DI600Totais(oBrow)
*------------------------------------*
LOCAL oDlgTotal, aOk:={{|| oDlgTotal:End() },STR0421} //"Sair"
PRIVATE lTotaisInv:=.F.

IF !Inclui .AND. lPrimeiraVez
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_SW8->(Easyreccount("Work_SW8")) = 0
         Processa({|| DI600InvCarrega()},STR0054) //"Pesquisa de Itens"
      ENDIF
   ELSE
      Processa({|| DI600Existe()    },STR0054) //"Pesquisa de Itens"
   ENDIF
ENDIF

Processa({|| DI600SomaTotais() },STR0461)  //"Somando totais"
IF Work_Tot->(BOF()) .AND. Work_Tot->(EOF())
   Help("",1,"AVG0000710")
// MSGINFO(0462,0057) //"Nao existe itens selecionados para Totalizar."
   Return .f.
ENDIF                             

aTB_CpoTot:={}
IF lTotaisInv
   AADD(aTB_CpoTot,{"W9_INVOICE" ,,AVSX3("W9_INVOICE",5)})
ENDIF
AADD(aTB_CpoTot,{"W9_MOE_FOB" ,,AVSX3("W9_MOE_FOB",5),AVSX3("W9_MOE_FOB",6)})
AADD(aTB_CpoTot,{"W9_FOB_TOT" ,,AVSX3("W9_FOB_TOT",5),AVSX3("W9_FOB_TOT",6)})
AADD(aTB_CpoTot,{"W9_INLAND"  ,,AVSX3("W9_INLAND" ,5),AVSX3("W9_INLAND" ,6)})
AADD(aTB_CpoTot,{"W9_PACKING" ,,AVSX3("W9_PACKING",5),AVSX3("W9_PACKING",6)})
AADD(aTB_CpoTot,{"W9_DESCONT" ,,AVSX3("W9_DESCONT",5),AVSX3("W9_DESCONT",6)})
AADD(aTB_CpoTot,{"W9_FRETEIN" ,,AVSX3("W9_FRETEIN",5),AVSX3("W9_FRETEIN",6)})
AADD(aTB_CpoTot,{"W9_OUTDESP" ,,AVSX3("W9_OUTDESP",5),AVSX3("W9_OUTDESP",6)})
// EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc 
   AADD(aTB_CpoTot,{"W9_SEGURO" ,,AVSX3("W9_SEGURO",5),AVSX3("W9_SEGURO",6)})
ENDIF
AADD(aTB_CpoTot,{"W6_FOB_TOT" ,,STR0158        ,AVSX3("W6_FOB_TOT",6)}) //"Total Geral"

Work_Tot->(DBGOTOP())
DEFINE MSDIALOG oDlgTotal TITLE "TOTAIS DO PROCESSO" FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 ;
                                           TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
                                           OF oMainWnd PIXEL

   oMark:=MSSELECT():New("Work_Tot",,,aTB_CpoTot,lInverte,cMarca,{17,1,(oDlgTotal:nClientHeight-4)/2,(oDlgTotal:nClientWidth-4)/2})
   oMark:oBrowse:bWhen:={||DBSELECTAREA("Work_Tot"),.T.}
   oDlgTotal:lMaximized:=.T.  //LRL 26/03/04 - Maximiliza Janela
ACTIVATE MSDIALOG oDlgTotal ON INIT (DI600EnchoiceBar(oDlgTotal,aOk,,.F.),;
                                     oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT, oMark:oBrowse:Refresh()) // TRP-06/11/2007 -Alinhamento MDI

IF Type("oBrow") = "O"
   oBrow:oBrowse:Refresh()
ENDIF

RETURN .T.
*------------------------------------*
Function DI600SomaTotais()
*------------------------------------*
LOCAL cAlias:='Work_SW8',T

Work_SW8->(DBSETORDER(1))
Work_SW9->(DBSETORDER(1))
Work_SW9->(DBGOTOP())
DO WHILE !Work_SW9->(EOF())
   IF WORK_SW9->W9_TUDO_OK == NAO .AND.;
      Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ"))) //TDF - 13/09/12 - TRATAMENTO DE LOJA
      IF DI600InvConf(.F.,Work_SW9->W9_INVOICE,Work_SW9->W9_FORN,.T.,EICRetLoja("Work_SW9", "W9_FORLOJ")) //TDF - 13/09/12 - TRATAMENTO DE LOJA
         DI600InvTotais(.F.,.F.)
      ENDIF
   ENDIF
   Work_SW9->(DBSKIP())
ENDDO

Work_SW9->(DBSETORDER(1))
Work_Tot->(AvZap())//(__DBZAP())
FOR T := 1 TO 2

  IF T = 2 
     IF Work_Tot->(Easyreccount("Work_Tot")) # 0// Se tiver itens de invoice nao precisa do while Work
        EXIT
     ENDIF
     cAlias := 'Work'
  ENDIF

  IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TOTAIS_1"),)

  ProcRegua((cAlias)->(Easyreccount(cAlias)))
  (cAlias)->(DBSETORDER(1))
  (cAlias)->(DBGOTOP())
  DO While !(cAlias)->(Eof())
     IF cAlias == 'Work_SW8'   
        IncProc(STR0463+Work_SW8->WKINVOICE) //"Somando Invoice: "
        IF !nPos_aRotina = VISUAL .AND. !nPos_aRotina = ESTORNO
           IF EMPTY(Work_SW8->WKFLAGIV) .OR. EMPTY(Work_SW8->WKINVOICE)
              Work_SW8->(DBSKIP())
              LOOP
           ENDIF
        ENDIF
        IF lTotaisInv
           Work_Tot->(DBSETORDER(1))
           IF !Work_Tot->(DBSEEK('1'+Work_SW8->WKINVOICE+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ"))) //TDF - 13/09/12 - TRATAMENTO DE LOJA
              Work_Tot->(DBAPPEND())
              Work_Tot->WKCODIGO  :='1'
              Work_Tot->W9_INVOICE:=Work_SW8->WKINVOICE
              Work_Tot->W9_FORN   :=Work_SW8->WKFORN
              //FDR - 13/09/12 - Tratamento de loja
              If EICLoja()
                 Work_Tot->W9_FORLOJ := Work_SW8->W8_FORLOJ
              EndIf
              Work_Tot->W9_MOE_FOB:=Work_SW8->WKMOEDA
              Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+M->W6_HAWB)) //TDF - 13/09/12 - TRATAMENTO DE LOJA E HAWB NA CHAVE DA INVOICE
           ENDIF
           Work_Tot->W9_FOB_TOT+=Work_SW8->WKPRTOTMOE
           Work_Tot->W9_INLAND +=Work_SW8->WKINLAND
           Work_Tot->W9_PACKING+=Work_SW8->WKPACKING
           Work_Tot->W9_DESCONT+=Work_SW8->WKDESCONT
           Work_Tot->W9_FRETEIN+=Work_SW8->WKFRETEIN
           Work_Tot->W9_OUTDESP+=Work_SW8->WKOUTDESP
           // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
           IF lSegInc 
              Work_Tot->W9_SEGURO+=Work_SW8->WKSEGURO
           ENDIF
           Work_Tot->W6_FOB_TOT+=DI600Trans(DI600RetVal("ITEM_INV", "WORK", .T.)) // EOB - 03/06/08 - chamada da função DI500RetVal
           IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TOTAIS_2"),)
        ENDIF
        Work_Tot->(DBSETORDER(2))
        IF !Work_Tot->(DBSEEK('2'+Work_SW8->WKMOEDA))
           Work_Tot->(DBAPPEND())
           Work_Tot->WKCODIGO  :='2'
           Work_Tot->W9_INVOICE:=STR0464 //"Total Moeda:"
           Work_Tot->W9_MOE_FOB:=Work_SW8->WKMOEDA
        ENDIF
        Work_Tot->W9_FOB_TOT+=Work_SW8->WKPRTOTMOE
        Work_Tot->W9_INLAND +=Work_SW8->WKINLAND
        Work_Tot->W9_PACKING+=Work_SW8->WKPACKING
        Work_Tot->W9_DESCONT+=Work_SW8->WKDESCONT
        Work_Tot->W9_FRETEIN+=Work_SW8->WKFRETEIN
        Work_Tot->W9_OUTDESP+=Work_SW8->WKOUTDESP
        // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
        IF lSegInc 
           Work_Tot->W9_SEGURO+=Work_SW8->WKSEGURO
        ENDIF        
        Work_Tot->W6_FOB_TOT+=DI600Trans(DI600RetVal("ITEM_INV", "WORK", .T.)) // EOB - 03/06/08 - chamada da função DI500RetVal
       IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TOTAIS_3"),)

    ELSEIF cAlias == 'Work'
        IncProc(STR0465+Work->WKMOEDA) //"Somando Moeda: "
        IF !nPos_aRotina = VISUAL .AND. !nPos_aRotina = ESTORNO
           IF !WORK->WKFLAG
              WORK->(DBSKIP())
              LOOP
           ENDIF
        ENDIF
        Work_Tot->(DBSETORDER(2))
        IF !Work_Tot->(DBSEEK('3'+Work->WKMOEDA))
           Work_Tot->(DBAPPEND())
           Work_Tot->WKCODIGO  :='3'
           Work_Tot->W9_INVOICE:=STR0464 //"Total Moeda:"
           Work_Tot->W9_MOE_FOB:=Work->WKMOEDA
        ENDIF
        Work_Tot->W9_FOB_TOT+=DI600Trans(Work->WKQTDE*Work->WKPRECO)
        Work_Tot->W6_FOB_TOT+=DI600Trans(Work->WKQTDE*Work->WKPRECO)
        IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TOTAIS_4"),)

    ENDIF
    (cAlias)->(DBSKIP())
  ENDDO

  Work_Tot->(DBSETORDER(2))
  Work_SW9->(DBGOTOP())
  DO WHILE !Work_SW9->(EOF())
     IF Work_SW9->WK_TPINV  = 2  // EOS - Invoice especial, sem itens
        IF !Work_Tot->(DBSEEK('2'+Work_SW9->W9_MOE_FOB))
           Work_Tot->(DBAPPEND())
           Work_Tot->WKCODIGO  :='2'
           Work_Tot->W9_INVOICE:=STR0464 //"Total Moeda:"
           Work_Tot->W9_MOE_FOB:=Work_SW9->W9_MOE_FOB
        ENDIF
        Work_Tot->W9_INLAND +=Work_SW9->W9_INLAND
        Work_Tot->W9_PACKING+=Work_SW9->W9_PACKING
        Work_Tot->W9_DESCONT+=Work_SW9->W9_DESCONT
        Work_Tot->W9_FRETEIN+=Work_SW9->W9_FRETEIN
        Work_Tot->W9_OUTDESP+=Work_SW9->W9_OUTDESP
        // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
        IF lSegInc 
           Work_Tot->W9_SEGURO+=Work_SW9->W9_SEGURO
        ENDIF        
        Work_Tot->W6_FOB_TOT+=DI600Trans(DI600RetVal("TOT_INV,SEM_FOB", "WORK", .T.)) // EOB - 03/06/08 - chamada da função DI500RetVal
     ENDIF
     Work_SW9->(DBSKIP())
  ENDDO

  (cAlias)->(DBGOTOP())

NEXT
Work_SW9->(DBGOTOP())
RETURN .T.

*-------------------------------------*
Function DI600Fil(lFil)
*------------------------------------*
LOCAL cFiltro, cAlias
If lFilDa
   cAlias:=Alias()
   DbSelectArea("SW6")                   
   If lFil
      If MOpcao ==  FECHTO_NACIONALIZACAO
         cFiltro:="W6_FILIAL='"+xFilial("SW6")+"' .AND. W6_TIPOFEC='DIN'"
      Else
         cFiltro:="W6_FILIAL='"+xFilial("SW6")+"' .AND. W6_TIPOFEC<>'DIN'"
      EndIf
      SET FILTER TO &cFiltro
   Else
      SET FILTER TO 
   EndIF
   DbSelectArea(cAlias)                   
EndIf

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"FILTRO"),)
 
Return .T.

/*
nopado por RNLP - 18/09/20 - OSSME-5260 - Função não chamada/utilizada por nenhum fonte do sistema
*--------------------------------------------------------------------*
Function DI600BrowseEI()//Chamado do SXB, XB_ALIAS = 'EIF'
*--------------------------------------------------------------------*
LOCAL aTB_Campos,cTituto:=STR0267,nPos,nTam //"Manutencao de "
LOCAL aOk:={{||IF(DI600EIValid(.T.),oDlgEI:End(),)},"OK"}, T
LOCAL bCancel:={|| oDlgEI:End() },nAlias:=SELECT(), cFileTemp

IF SELECT("Work_EIF") = 0 .OR. SELECT("Work_EIG") = 0 .OR.;
   SELECT("Work_EIH") = 0 .OR. SELECT("Work_EII") = 0
   SELECT(nAlias)
   MSGSTOP(STR0416,STR0141) //"Opcao nao Disponivel, Consulte o Processo pelo Menu."
   RETURN .T.
ENDIF

PRIVATE lValidRepetidos:= .T.,aCpos:={},nLargura:=300
PRIVATE cArq,cAliasWK,bValidEI,bWhile:={||.T.}
PRIVATE cCampo:=UPPER(READVAR())

DO CASE
CASE "W6_INSTRDE" $ cCampo//Capa SW6
     cArq    :="EIF"
     cAliasWK:="Work_EIF"
     bValidEI:={|| EMPTY(EIF_CODIGO).OR.EMPTY(EIF_DOCTO)}
     nLargura:=400
     (cAliasWK)->(DBGOTOP())

CASE "W6_PROCVIN" $ cCampo //Capa SW6
     cArq:="EIG"
     cAliasWK:="Work_EIG"
     bValidEI:={|| EMPTY(EIG_CODIGO).OR.EMPTY(EIG_NUMERO)}
     nLargura:=400
     (cAliasWK)->(DBGOTOP())

CASE "W6_VOLUMES" $ cCampo //Capa SW6
     cArq:="EIH"
     cAliasWK:="Work_EIH"
     bValidEI:={|| EMPTY(EIH_CODIGO).OR.EMPTY(EIH_QTDADE)}
     nLargura:=550
     (cAliasWK)->(DBGOTOP())

CASE "W6_DEBITOS" $ cCampo //Capa SW6
     cArq:="EII"
     cAliasWK:="Work_EII"
     bValidEI:={|| EMPTY(EII_CODIGO).AND.EMPTY(EII_VLTRIB) }
     nLargura:=500
     (cAliasWK)->(DBGOTOP())

OTHERWISE

   IF DI600TelaEI()
      RETURN .T.
   ENDIF

   lSair:=.T.
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"BROWSE_EI"),)
   IF lSair
      RETURN .T.
   ENDIF

ENDCASE

SX2->(DBSETORDER(1))
IF SX2->(DBSEEK(cArq))
   cTituto+=LOWER(FWX2Nome(cArq))
ENDIF

IF "EIJ_EIL" $ cCampo 
   cTituto:=LOWER(FWX2Nome(cArq))
   cTituto:=UPPER(LEFT(cTituto,1))+SUBSTR(cTituto,2)
ENDIF
//Inicia o aHeader guardado na Array aTabelas no inicio do programa
nPos   :=ASCAN(aTabelas,{|A|A[1]==cArq})
aHeader:=ACLONE(aTabelas[nPos,5])

dbSelectArea(cAliasWK)     
cIndice  := (cAliasWK)->(INDEXKEY())
IF AT('EIN_TIPO',cIndice) # 0 .OR. AT('EIO_TIPCOB',cIndice) # 0
   nPos:=AT('+',cIndice)
   cIndice:=SUBSTR(cIndice,nPos+1)//Tira Tipo do Indice
ENDIF
aStru    := DBSTRUCT()

cFileTemp:= E_CriaTrab(,aStru,"Work_TEMP")

IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("Work_Temp",cFileTemp+TeOrdBagExt(),cIndice)
cAliasEI:=cAliasWK
cAliasWK:="Work_TEMP"
(cAliasEI)->(DBEVAL( {|| DI600GrvTemp(.T.) }, ,bWhile))

nPos:=0
nTam:=LEN(aHeader)-LEN(aCpos)
FOR T := 1 TO LEN(aCpos)//Tira os Campos que nao deve aparecer no MSGETDB
    IF (nPos:=ASCAN(aHeader,{|H|H[2]==aCpos[T]})) # 0
       ADEL(aHeader,nPos)
       ASIZE(aHeader,LEN(aHeader)-1)
    ENDIF
NEXT
IF(nPos#0,ASIZE(aHeader,nTam),)

nPos:=nPos_aRotina//Verefica se a MSGETDB deve aparecer com um registro em branco ou nao e serao editavel
IF Work_TEMP->(Easyreccount("Work_TEMP")) > 0 .AND. nPos_aRotina = INCLUSAO
   nPos:= ALTERACAO
ELSEIF Work_TEMP->(Easyreccount("Work_TEMP")) = 0 .AND. nPos_aRotina = ALTERACAO
   nPos:= INCLUSAO
ENDIF

IF nPos = VISUAL .OR. nPos = ESTORNO
   aOk:={{||oDlgEI:End()},STR0421} //"Sair"
   bCancel:=NIL
ENDIF

dbSelectArea(cAliasWK)
(cAliasWK)->(DBSETORDER(1))
(cAliasWK)->(DBGOTOP())

DEFINE MSDIALOG oDlgEI TITLE cTituto ; 
       FROM oMainWnd:nTop   +200,oMainWnd:nLeft +1 ;
       TO   oMainWnd:nBottom-200,oMainWnd:nRight-nLargura OF oMainWnd PIXEL

  oMarkEI:=MsGetDB():New(15,1,(oDlgEI:nClientHeight-6)/2,(oDlgEI:nClientWidth-4)/2,nPos,;
                     "DI600EIValid(.F.)","","",.T.,,,.F.,,cAliasWK)
  oMarkEI:oBrowse:bwhen:={||(dbSelectArea(cAliasWK),.t.)}
  oMarkEI:ForceRefresh()

ACTIVATE MSDIALOG oDlgEI ON INIT (DI600EnchoiceBar(oDlgEI,aOk,bCancel,.F.),;
                                  oMarkEI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT)  CENTERED

Work_TEMP->(E_EraseArq(cArq))
SELECT(nAlias)

DI600GrvCpoVisual(cCampo)

Return .T.
*/

*--------------------------------------------------------------------------------------*
Function DI600GrvCpoVisual(cCampo,nValRealA,nValRealD)//Esta funcao eh chamada do X3_RELACAO
*--------------------------------------------------------------------------------------*
LOCAL nAlias:=SELECT(),cPict
LOCAL nRecSX3:=SX3->(RECNO())//A Funcao AVSX3() desposiciona o SX3
PRIVATE cInitCampo:=''                                

IF SELECT("Work_EIF") = 0 .OR. SELECT("Work_EIG") = 0 .OR.;
   SELECT("Work_EIH") = 0 .OR. SELECT("Work_EII") = 0
   SELECT(nAlias)
   RETURN cInitCampo
ENDIF
   
DO CASE
CASE "W6_INSTRDE" $ cCampo
     Work_EIF->(DBGOTOP())
     M->W6_INSTRVM:=' '
     DO WHILE Work_EIF->(!EOF())
        IF !EMPTY(Work_EIF->EIF_CODIGO) .AND. !Work_EIF->DELETE
           SJE->(DBSEEK(xFilial()+Work_EIF->EIF_CODIGO))
           M->W6_INSTRVM:=cInitCampo:=STR0271+ALLTRIM(SJE->JE_DESC)+"-"+ALLTRIM(Work_EIF->EIF_DOCTO) //"Tipo: "
           EXIT
        ENDIF
        Work_EIF->(DBSKIP())
     ENDDO

CASE "W6_PROCVIN" $ cCampo
     Work_EIG->(DBGOTOP())
     M->W6_PROCVVM:=' '
     DO WHILE Work_EIG->(!EOF())
        IF !EMPTY(Work_EIG->EIG_CODIGO) .AND. !Work_EIG->DELETE
           bCampo:=&("{||"+AVSX3('EIG_CODIGO',14,'Work_EIG')+"}")
           M->W6_PROCVVM:=cInitCampo:=STR0271+EVAL(bCampo)+"-"+ALLTRIM(Work_EIG->EIG_NUMERO) //"Tipo: "
           EXIT
        ENDIF
        Work_EIG->(DBSKIP())
     ENDDO

CASE "W6_VOLUMES" $ cCampo
     Work_EIH->(DBGOTOP())
     M->W6_VOLUMVM:=' '
     DO WHILE Work_EIH->(!EOF())
        IF !EMPTY(Work_EIH->EIH_CODIGO) .AND. !Work_EIH->DELETE                              
           SJF->(DBSEEK(xFilial()+Work_EIH->EIH_CODIGO))
           cPict:=AVSX3("EIH_QTDADE",6)
           M->W6_VOLUMVM:=cInitCampo:=ALLTRIM(TRANS(Work_EIH->EIH_QTDADE,cPict))+" "+ALLTRIM(SJF->JF_DESC)
           EXIT
        ENDIF
        Work_EIH->(DBSKIP())
     ENDDO

CASE "W6_DEBITOS" $ cCampo
     Work_EII->(DBGOTOP())      
     M->W6_DEBITVM:=' '
     DO WHILE Work_EII->(!EOF())
        IF !EMPTY(Work_EII->EII_CODIGO) .AND. !Work_EII->DELETE                              
           SJH->(DBSEEK(xFilial()+Work_EII->EII_CODIGO))
           cPict:=AVSX3("EII_VLTRIB",6)
           M->W6_DEBITVM:=cInitCampo:=ALLTRIM(SJH->JH_DESC)+": R$ "+ALLTRIM(TRANS(Work_EII->EII_VLTRIB,cPict))
           EXIT
       ENDIF
       Work_EII->(DBSKIP())
     ENDDO

ENDCASE

SX3->(DBGOTO(nRecSX3))

IF EasyEntryPoint("EICDI600")
   cRDCampo:=cCampo
   Execblock("EICDI600",.F.,.F.,"GRAVA_MEMOS")
ENDIF

SX3->(DBGOTO(nRecSX3))

RETURN cInitCampo

*--------------------------------------------------------------------------------------*
Function DI600PROG(cPar)//Antiga EICDI400PROG(cPar)
*--------------------------------------------------------------------------------------*
LOCAL lCerto:=.T.                
SW2->(DBSETORDER(1))
lGetPo:=.T.
IF MOpcao == FECHTO_NACIONALIZACAO .AND. ! (Val(SW6->W6_TIPODES) >= 14 .And. Val(SW6->W6_TIPODES) <= 16)
   Help(" ",1,"AVG0000090") 
   lCerto:=.F.
ElseIf MOpcao # FECHTO_NACIONALIZACAO .AND. SW2->(DBSEEK(xFilial("SW2")+LEFT("DA"+SW6->W6_DI_NUM,LEN(SW2->W2_PO_NUM)))) 
   If (Val(SW6->W6_TIPODES) >= 2 .And. Val(SW6->W6_TIPODES) <= 4) 
      Help(" ",1,"AVG0000098") 
      lCerto:=.F.
   Else
      Help(" ",1,"AVG0000091") 
      lCerto:=.F.
   EndIf
ElseIf MOpcao # FECHTO_NACIONALIZACAO .AND. SW6->W6_TIPOFEC = "DIN"
   Help(" ",1,"AVG0000091") 
   lCerto:=.F.
EndIf

Return lCerto

*---------------------------*
Function DI600SelPO()//Antiga EICDISELPO()
*---------------------------*
LOCAL nOpca, cFiltro, i
Local cAliasFil:=Alias()
LOCAL bValid:={|| DI600POPLIValid(.T.,cPedido,.F.) .AND. DI600PONAC() .AND. ExistChav("SW6")}

lGetPo:=.F.
cPedido:=SPACE(Len(SW2->W2_PO_NUM))
M->W6_HAWB:=SPACE(Len(SW6->W6_HAWB))

cFiltro := "W2_FILIAL='"+xFilial("SW2")+"' .And. W2_HAWB_DA <> '"+Space(Len(SW2->W2_HAWB_DA))+"'"
DBSELECTAREA("SW2")
If lFilDa
   SET FILTER TO &cFiltro
   DBSELECTAREA(cAliasFil)
EndIf
nOpca:=0
DO WHILE .T.

   DEFINE MSDIALOG oDlgPONAC TITLE STR0001 From 9,0 To 18,40 OF oMainWnd //"Sele‡ao de P.O."
      If !EasyGParam("MV_NRDI",,.F.) //JVR - 20/07/09
    @ 1.8,0.8 SAY AVSX3("W6_HAWB",5) //Processo
         @ 1.8,5  MSGET M->W6_HAWB PICTURE ALLTRIM(X3Picture("W6_HAWB")) VALID (ExistChav("SW6")) SIZE 60,8
      EndIf                   

    @ 3.6,0.8 SAY AVSX3("W2_PO_NUM",5)//Pedido
    @ 3.6, 5  MSGET cPedido F3 "SW2" PICTURE _PictPO 

  ACTIVATE MSDIALOG oDlgPONAC ON INIT ;
           DI600EnchoiceBar(oDlgPONAC,{{||If(Eval(bValid),(nOpca:=1,oDlgPONAC:End()),)},"OK"},;
                                       {||nOpca:=0,oDlgPONAC:End()},.F.) CENTERED
  If nOpca # 0
     SW2->(DBSETORDER(1))
     SW2->(DBSEEK(xFilial()+cPedido))
     SW6->(DBSETORDER(1))
     SW6->(DBSEEK(xFilial()+SW2->W2_HAWB_DA))
     cProcSave:=M->W6_HAWB
     DBSELECTAREA("SW6")      
     FOR i := 1 TO FCount()
         M->&(FIELDNAME(i)) := FieldGet(i)
     NEXT i
     M->W6_HAWB   :=cProcSave
     M->W6_DI_NUM :=SPACE(LEN(SW6->W6_DI_NUM))
     M->W6_DT     :=AVCTOD("")
     M->W6_DTREG_D:=AVCTOD("")
     M->W6_DT_DESE:=AVCTOD("")
     M->W6_DT_NF  :=AVCTOD("")
     M->W6_NF_ENT :=SPACE(LEN(SW6->W6_NF_ENT))
     M->W6_VL_NF  :=0
     IF !EMPTY(SW6->W6_OBS)
        cVM_OBS := MSMM(SW6->W6_OBS,AVSX3("W6_VM_OBS",03))
     ENDIF
     IF !EMPTY(SW6->W6_COMPLEM)
        cVM_COMP:= MSMM(SW6->W6_COMPLEM,AVSX3("W6_VM_COMP",03))
     ENDIF
  
     DI600POFIL()
     lGetPo:=.T.
     Return .T.

  ENDIF

  EXIT

ENDDO

Return .F.

*--------------------------------------------*
Function DI600PONAC() //Antiga DI_PONAC()
*--------------------------------------------*
Local lRet:=.T.
SW6->(DBSETORDER(1))
If ! SW6->(DBSEEK(xFilial()+SW2->W2_HAWB_DA))
   Help(" ",1,"AVG0000099") 
   lRet := .F.
EndIf
Return lRet

*------------------------------*
Function DI600POFIL()
*------------------------------*
If lFilDa
   cAliasFil:=Alias()
   DBSELECTAREA("SW2")
   SET FILTER TO
   DBSELECTAREA(cAliasFil)
EndIf
Return .T.

*----------------------------------------------------------------------------*
FUNCTION DI600GrvTRB(lEstorno)
*----------------------------------------------------------------------------*
LOCAL lSuframa:=AvFlags("SUFRAMA"),nCont:=0
LOCAL cFilSW7:=xFilial("SW7"), cFilSW8:=xFilial("SW8")
LOCAL cFilSA2:=xFilial("SA2")
LOCAL cFilSB1:=xFilial("SB1")
LOCAL cFilSWP:=xFilial("SWP")
LOCAL cFilSW9:=xFilial("SW9")
LOCAL cFilSW4:=xFilial("SW4")
LOCAL cFilSYX:=xFilial("SW4")
TRB->(AvZap())

SYX->(DBSETORDER(3))
SW2->(DBSETORDER(1))
SW4->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW7->(DBSEEK(cFilSW7+SW6->W6_HAWB))
SW2->(DBSEEK(xFilial()+SW7->W7_PO_NUM))

ProcRegua(10)

DO WHILE !SW7->(EOF())             .AND.;
         SW7->W7_FILIAL == cFilSW7 .AND.;
         SW7->W7_HAWB   == SW6->W6_HAWB

  IF nCont > 10
     ProcRegua(10)
     nCont:=0
  ENDIF
  nCont++
  IncProc(STR0077+ALLTRIM(SW7->W7_COD_I))//"LENDO ITENS DA D.I.: "

  SWP->(DBSEEK(cFilSWP+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
  SB1->(DBSEEK(cFilSB1+ SW7->W7_COD_I))

  TRB->(DBAPPEND())
  TRB->W7_SEQ_LI := SW7->W7_SEQ_LI
  TRB->W7_PGI_NUM:= SW7->W7_PGI_NUM
  TRB->WP_REGIST := SWP->WP_REGIST
  TRB->WP_VENCTO := SWP->WP_VENCTO
  TRB->W7_COD_I  := SW7->W7_COD_I
  TRB->W5_DESC_P := MSMM( SB1->B1_DESC_GI,36,1 ) 
  TRB->W7_PO_NUM := SW7->W7_PO_NUM
  TRB->W7_CC     := SW7->W7_CC
  TRB->W7_SI_NUM := SW7->W7_SI_NUM
  TRB->W7_FABR   := SW7->W7_FABR
  //FDR - 13/09/12 - Tratamento de loja
  If EICLoja()
     TRB->W7_FABLOJ := SW7->W7_FABLOJ
  EndIf
  TRB->W7_POSICAO:= SW7->W7_POSICAO
  TRB->W7_PESO   := SW7->W7_PESO
  TRB->W7_NCM    := SW7->W7_NCM
  TRB->W7_EX_NCM := SW7->W7_EX_NCM
  TRB->W7_EX_NBM := SW7->W7_EX_NBM

  IF lEstorno
     TRB->WKRECNO   :=SW7->(RECNO())
     TRB->W5_PGI_NUM:=SW7->W7_PGI_NUM
     TRB->W7_REG    :=SW7->W7_REG
  ENDIF

  IF lSuframa
     SW4->(DBSEEK(cFilSW4+SW7->W7_PGI_NUM))
     IF !EMPTY(SW4->W4_PROD_SU)                 
        IF SYX->(DBSEEK(cFilSYX+SW4->W4_PROD_SU+SW7->W7_COD_I))
           TRB->W5_DESC_P := MEMOLINE( SYX->YX_DES_ZFM,36,1 )
        ENDIF
     ENDIF
   ENDIF       
     
  SA2->(DBSEEK(cFilSA2+SW7->W7_FABR+EICRetLoja("SW7", "W7_FABLOJ"))) //TDF - 13/09/12 - TRATAMENTO DE LOJA

  TRB->W5_FABR_N := SA2->A2_NREDUZ
  TRB->W7_FORN   := SW7->W7_FORN
  //FDR - 13/09/12 - Tratamento de loja
  If EICLoja()
     TRB->W7_FORLOJ := SW7->W7_FORLOJ
  EndIf

  SA2->(DBSEEK(cFilSA2+SW7->W7_FORN+EICRetLoja("SW7", "W7_FABLOJ"))) //TDF - 13/09/12 - TRATAMENTO DE LOJA

  TRB->W5_FORN_N := SA2->A2_NREDUZ
  TRB->W7_QTDE   := SW7->W7_QTDE
  TRB->W7_PRECO  := SW7->W7_PRECO
  TRB->W6_FOB_TOT:= SW7->W7_QTDE*SW7->W7_PRECO
  TRB->W9_INVOICE:= SW8->(PesqIVH(SW7->W7_HAWB,SW7->W7_COD_I,SW7->W7_FABR,;
                                       SW7->W7_FORN,SW7->W7_PGI_NUM,SW7->W7_SI_NUM,;
                                       SW7->W7_PO_NUM,SW7->W7_CC,SW7->W7_REG,EICRetLoja("SW7", "W7_FABLOJ"),EICRetLoja("SW7", "W7_FORLOJ"))) //TDF - 13/09/12 - TRATAMENTO DE LOJA

  IF !EMPTY(TRB->W9_INVOICE)
     nPos := AT("+",TRB->W9_INVOICE)
     IF nPos # 0
        SW9->(DBSEEK(cFilSW9+SUBST(TRB->W9_INVOICE,1,nPos-1)+TRB->W7_FORN+EICRetLoja("TRB", "W7_FORLOJ")+SW7->W7_HAWB)) //TDF - 13/09/12 - TRATAMENTO DE LOJA E HAWB NA CHAVE DA INVOICE
     ELSE
        SW9->(DBSEEK(cFilSW9+TRB->W9_INVOICE+TRB->W7_FORN+EICRetLoja("TRB", "W7_FORLOJ")+SW7->W7_HAWB)) //TDF - 13/09/12 - TRATAMENTO DE LOJA E HAWB NA CHAVE DA INVOICE
     ENDIF
     TRB->W9_DT_EMIS:=SW9->W9_DT_EMIS
     If lIntDraw .and. lExistW8_AC
        SW8->(dbSetOrder(6))
        If SW8->(dbSeek(cFilSW8+SW7->W7_HAWB+TRB->W9_INVOICE+SW7->W7_PO_NUM+SW7->W7_POSICAO+SW7->W7_PGI_NUM))
           TRB->W5_AC := SW8->W8_AC
        EndIf
     EndIf
  ENDIF
  IF SW7->(FIELDPOS('W7_LOCAL')) # 0
     TRB->WKLOCAL := SW7->W7_LOCAL
  ENDIF

  IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_TRB"),)

  SW7->(DBSKIP())
ENDDO
SYX->(dBSETORDER(1))
TRB->(DBGOTOP())

DI600EIGrava('LEITURA',SW6->W6_HAWB,aAliasCapa)

RETURN .T.

*------------------------------------------------------------------------------*
FUNCTION DI600Final()//Antiga DI_Final(bCloseAll)
*------------------------------------------------------------------------------
Local W
SW4->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SY9->(DBSETORDER(1))
SA5->(DBSETORDER(1))
SWZ->(DBSETORDER(1))
SX3->(DBSETORDER(1))
SWD->(DBSETORDER(1))

FOR W := 1 TO LEN(aDelFile)
   cAlias:=aDelFile[W,1]
   cArq  :=aDelFile[W,2]
   IF cAlias # NIL
      (cAlias)->(E_EraseArq(cArq))
   ELSE
      //MFR OSSME-1974 26/12/2018
      FERASE(cArq+TeOrdBagExt())
   ENDIF
NEXT

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DI600FINAL"),)

DBSELECTAREA("SW6")

RETURN .T.

*---------------------------------------------------------------------------*
Function DI600GrvCapa(bValid)//Antiga DI400Atu(bValid) 
*---------------------------------------------------------------------------*
LOCAL nWk
If !Obrigatorio(aGets,aTela) .or. !Eval(bValid)
   RETURN .F.
Endif

lSair:=.F.
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ANTES_CONF_CAPA"),)
IF lSair
   RETURN .F.
EndIf
                         
IF !lGravaSoCapa
   RETURN DI600_Grava()
ENDIF          

If MsgYesNo(STR0280,STR0141)//'Capa da D.I.' //"Confirma a gravacao somente da capa do processo?"
   
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ANT_GRAVA_CAPA"),)

   IF lFinanceiro 
      axFlDelWork:={}
      TP251CriaWork()
      axFl2DelWork:={}
      TP252CriaWork()
   ENDIF

   Begin Transaction   

     EICFI400("ANT_GRV_DI","A")
     Processa({|| DI600GrvSW6("2") },STR0281) //"Gravacao da Capa..."
     EICFI400("POS_GRV_DI","A")

   End Transaction   

***** DELETAR ARQUIVO DA FUNCAO AV POS_DI(), QDO TEM CONTROLE DE TRANSACAO
   IF lFinanceiro 
      If Select("WorkTP") # 0
         IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
            WorkTP->(E_EraseArq(axFl2DelWork[1]))
            FOR nWk:=2 TO LEN(axFl2DelWork)
            //MFR OSSME-1974 26/12/2018
                FERASE(axFl2DelWork[nWk]+TeOrdBagExt())
            NEXT
         ENDIF
      ENDIF
   ENDIF   
*******************

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"POS_GRAVA_CAPA"),)

   Return .T.
Endif

Return .F.


//Funcao que valida se a data contabil esta preenchida e nao permitir a edicao
//de certos campos 
*--------------------------------------------------------*
Function DI600CTB()//Antiga DI400CTB()
*--------------------------------------------------------*
IF GetNewPar("MV_EIC_ECO","N") $ cSim 
   IF !Inclui .AND. !EMPTY(SW6->W6_CONTAB) .and. !Empty(SW6->W6_DI_NUM)
      RETURN .F.
   ENDIF
EndIf
Return .T.

//Funcao destinada a inicializar a data ETA na inclusao de processos.
//Utilizada atraves do valid do dicionario SX3.
*---------------------------------------------------------------------
Function DI600AtuDtEta(cCalcDt)//Antiga Di_AtuDtEta()  // by CAF 24/09/1998 14:19
*---------------------------------------------------------------------
LOCAL nSYR_Ordem := SYR->(IndexOrd())
LOCAL nSYR_Recno := SYR->(Recno()), lExistLT
SX3->(DBSETORDER(2))                                                   
// EOS campos novos inclusos:
// W6_CALCAUT => calcula as datas automanticamente segundo seus lead times 
// W6_PREVENT => data de previsao de entrega
lExistLT:=SX3->(DBSEEK("W6_CALCAUT")) .AND. SX3->(DBSEEK("W6_PRVENTR"))

IF !lExistLT  // EOS se nao existem os campos novos, continua do jeito que estava...
   IF !Inclui
      RETURN .T.
   ENDIF
   
   SYR->(dbSetOrder(1))  // Filial+Yr_Via+Yr_Origem...
   IF !SYR->(dbSeek(xFilial()+M->W6_VIA_TRA+M->W6_ORIGEM))
      SYR->(dbSetOrder(nSYR_Ordem))
      SYR->(dbGoTo(nSYR_Recno))
      Return .T.
   ENDIF

   IF !Empty(M->W6_DT_EMB)
      M->W6_DT_ETA := M->W6_DT_EMB + SYR->YR_TRANS_T
   ELSEIF ! Empty(M->W6_DT_ETD)
      M->W6_DT_ETA := M->W6_DT_ETD + SYR->YR_TRANS_T
   ENDIF 

ELSEIF M->W6_CALCAUT == "1"   // EOS - se o campo estiver com SIM, calcular as datas segundo os lead times
   SY9->(DBSETORDER(2)) 
   IF cCalcDt == "ETA"  
      SYR->(dbSetOrder(1))  // Filial+Yr_Via+Yr_Origem...
      IF !SYR->(dbSeek(xFilial()+M->W6_VIA_TRA+M->W6_ORIGEM))
         SYR->(dbSetOrder(nSYR_Ordem))
         SYR->(dbGoTo(nSYR_Recno))
         Return .T.
      ENDIF

      IF !Empty(M->W6_DT_EMB)
         M->W6_DT_ETA := M->W6_DT_EMB + SYR->YR_TRANS_T
      ELSEIF ! Empty(M->W6_DT_ETD)
         M->W6_DT_ETA := M->W6_DT_ETD + SYR->YR_TRANS_T
      ENDIF 
      cCalcDt := "PRD"         
   ENDIF               
   IF cCalcDt == "PRD"
      IF !Empty(M->W6_CHEG)
         M->W6_PRVDESE := M->W6_CHEG + IF(SY9->(DBSEEK(xFilial()+M->W6_DEST)),SY9->Y9_LT_DES,EasyGParam("MV_LT_DESE"))
      ELSEIF ! Empty(M->W6_DT_ETA)
         M->W6_PRVDESE := M->W6_DT_ETA + IF(SY9->(DBSEEK(xFilial()+M->W6_DEST)),SY9->Y9_LT_DES,EasyGParam("MV_LT_DESE"))
      ENDIF           
      cCalcDt := "PRE"
   ENDIF
   IF cCalcDt == "PRE" 
      IF !Empty(M->W6_DT_DESE) 
         M->W6_PRVENTR := M->W6_DT_DESE + IF(SY9->(DBSEEK(xFilial()+M->W6_DEST)),SY9->Y9_LT_TRA, 0)       
      ELSEIF !EMPTY(M->W6_PRVDESE)
         M->W6_PRVENTR := M->W6_PRVDESE + IF(SY9->(DBSEEK(xFilial()+M->W6_DEST)),SY9->Y9_LT_TRA, 0) 
      ENDIF       
   ENDIF
   SY9->(DBSETORDER(1))
ENDIF

SYR->(dbSetOrder(nSYR_Ordem))
SYR->(dbGoTo(nSYR_Recno))
lRefresh := .T.

Return .T.

*-----------------------------------------------------------*
Function DI600AlterValid(bValid,lValCampos,lValidCambio)//Antiga DI400NFCamVal()
*-----------------------------------------------------------*
LOCAL x3ord:= SX3->(INDEXORD())
DEFAULT lValidCambio := .T.

IF lValCampos
   IF !Obrigatorio(aGets,aTela) .or. !Eval(bValid)
      RETURN .F.
   ENDIF
ENDIF

IF !lNoBaixa
   EICFI400('MENSAGEM')
   RETURN .F.
ENDIF

SF1->(DBSETORDER(5))
IF SF1->(DBSEEK(xFilial()+SW6->W6_HAWB)) .OR. lTemNFE
   Help("", 1, "AVG0000247")//Itens do processo nao podem ser alterados, pois o processo possui NF(s)
   SF1->(DBSETORDER(1))
   RETURN .F.
ENDIF
SF1->(DBSETORDER(1))

SX3->(DBSETORDER(2))
IF (SX6->(DBSEEK(SM0->M0_CODFIL+"MV_EIC_ECO")).OR.SX6->(DBSEEK("  "+"MV_EIC_ECO"))) .AND. EasyGParam("MV_EIC_ECO") $ cSim .AND.;
   SX3->(DBSEEK("W6_CONTAB")) 
   IF !EMPTY(SW6->W6_CONTAB) .and. !Empty(SW6->W6_DI_NUM)
     Help("", 1, "AVG0000248")//Itens do processo nao podem ser alterados, -processo Contabilizado
     SX3->(DBSETORDER(x3ord))
     RETURN .F.
   Endif
ENDIF
SX3->(DBSETORDER(x3ord))

If MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO
   IF SW7->(DBSEEK(xFilial()+M->W6_HAWB))
      IF _Declaracao
         IF SW7->W7_FLUXO # "4"
            Help(" ",1,"E_ENTRPNAO")//"HOUSE NAO eh ENTREPOSTADO
            Return .F.
         ENDIF
      ELSE
         IF SW7->W7_FLUXO = "4"
            Help(" ",1,"E_ENTRPSIM")//"HOUSE eh ENTREPOSTADO
            Return .F.
          ENDIF
      ENDIF
   ENDIF
ENDIF

If !Empty(SW6->W6_DT_ENCE)
   If MsgYesNo(STR0075,STR0141) # .T. //"Processo j  encerrado - Deseja alter -lo ?"###"Alteração de Processo"
      Return .F.
   Endif
Endif

RETURN .T.

*--------------------------------------------------*
FUNCTION DI600Existe()//Antiga DI_Existe(bMsg)
*--------------------------------------------------*
LOCAL cFilSW7:=xFilial("SW7")
LOCAL nCont:=0

aPedido:={}
aPLI:={}
lPrimeiraVez:=.F.

ProcRegua(10)

SA5->(DBSETORDER(3))
SB1->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW4->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW9->(DBSETORDER(3))
SWP->(DBSETORDER(1))
Work->(DBSETORDER(3))

DBSELECTAREA("SW7")
SW7->(DBSEEK(xFilial()+M->W6_HAWB))

DO WHILE SW7->(!EOF()) .AND.;
         SW7->W7_HAWB   == M->W6_HAWB .AND.;
         SW7->W7_FILIAL == cFilSW7

   IF nCont > 10
      ProcRegua(10)
      nCont:=0
   ENDIF
   nCont++
   IncProc(STR0077+ALLTRIM(SW7->W7_COD_I)) //"LENDO ITENS DA D.I.: "

   IF SW7->W7_SEQ <> 0 .OR. SW7->W7_SALDO_Q = 0
      SW7->(DBSKIP())
      LOOP
   ENDIF

   IF MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO
      IF _Declaracao
         IF SW7->W7_FLUXO # "4"
            SW7->(DBSKIP())
            LOOP
         ENDIF
      ELSE
         IF SW7->W7_FLUXO = "4"
            SW7->(DBSKIP())
            LOOP
         ENDIF
      ENDIF
   ENDIF
   
   IF ASCAN(aPedido,SW7->W7_PO_NUM) = 0
      AADD(aPedido,SW7->W7_PO_NUM)
   ENDIF
   IF SUBSTR(SW7->W7_PGI_NUM,1,1) # '*' .AND. ASCAN(aPLI,SW7->W7_PGI_NUM) = 0
      AADD(aPLI,SW7->W7_PGI_NUM)
   ENDIF

   DI600CarregaWork("W7_")//Grava SW7 na Work
   SW7->(DBSKIP())
ENDDO

DI600InvCarrega()
DI600EIGrava('LEITURA',SW6->W6_HAWB,{})

RETURN .T.

*----------------------------*
FUNCTION DI600InvCarrega()
*----------------------------*
LOCAL cFilSW7:=xFilial("SW7")
LOCAL cFilSW8:=xFilial("SW8")
LOCAL cFilSW9:=xFilial("SW9")
LOCAL cFilEZZ:=xFilial("EZZ")  //EOS 
LOCAL cFilSWP:=xFilial("SWP")
LOCAL cTamMemo:=AVSX3('W8_DESC_VM',3)

nCont:=0
ProcRegua(10)
  
SW7->(DBSETORDER(4))
SWP->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW8->(DBSEEK(xFilial()+SW6->W6_HAWB))
DO WHILE SW8->(!EOF()) .AND.;
         SW8->W8_HAWB   == SW6->W6_HAWB .AND.;
         SW8->W8_FILIAL == cFILSW8

   IF nCont > 10
      ProcRegua(10)
      nCont:=0
   ENDIF
   nCont++
   IncProc(STR0282+ALLTRIM(SW8->W8_COD_I)) //"Lendo Item: "

   Work_SW8->(DBAPPEND())
   DI600GrvWkSW8(.F.)
   Work_SW8->WKFLAGIV    := cMarca
   Work_SW8->WKSALDO_AT  := WORK_SW8->WKQTDE
   Work_SW8->WKSALDO     := WORK_SW8->WKQTDE
   Work_SW8->WKPRTOTMOE  := WORK_SW8->WKQTDE*WORK_SW8->WKPRECO
   //FDR - 13/09/12 - Tratamento de loja
   If EICLoja()
     Work_SW8->W8_FORLOJ := SW8->W8_FORLOJ
     Work_SW8->W8_FABLOJ := SW8->W8_FABLOJ
   EndIf
   IF lAltDescricao .AND. !EMPTY(SW8->W8_DESC_DI)
      Work_SW8->WKDESC_DI:= MSMM(SW8->W8_DESC_DI,cTamMemo)
   ENDIF
   IF SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
      Work_SW8->WKOPERACA:= SW7->W7_OPERACA
      Work_SW8->WKPESO_L := SW7->W7_PESO
      Work_SW8->WKPESOTOT:= WORK_SW8->WKQTDE*SW7->W7_PESO
   ENDIF
   IF SWP->(DBSEEK(cFilSWP+SW8->W8_PGI_NUM+SW8->W8_SEQ_LI))
      Work_SW8->WKREGIST := SWP->WP_REGIST
   ENDIF
   Work_SW8->WKDISPLOT := WORK_SW8->WKQTDE// AWR - Lote - 07/06/2004
   SW8->(DBSKIP())

ENDDO

Work_SW8->(DBSETORDER(1))
SW9->(DBSETORDER(3))
SW9->(DBSEEK(xFilial()+SW6->W6_HAWB))
DO WHILE SW9->(!EOF()) .AND.;
         SW9->W9_HAWB   == SW6->W6_HAWB .AND.;
         SW9->W9_FILIAL == cFILSW9

   IF nCont > 10
      ProcRegua(10)
      nCont:=0
   ENDIF
   nCont++
   IncProc(STR0283+ALLTRIM(SW9->W9_INVOICE)) //"Lendo Invoice: "

   Work_SW9->(DBAPPEND())
   AVREPLACE("SW9","Work_SW9")
   IF SW9->(FIELDPOS("W9_TUDO_OK")) = 0
      WORK_SW9->W9_TUDO_OK:=SIM
   ENDIF
   WORK_SW9->WK_RECNO  :=SW9->(RECNO())
   WORK_SW9->WK_TPINV  := 1  // EOS - invoice normal com itens
   //TDF - 13/09/12 - TRATAMENTO DE LOJA
   
   Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ")))
   DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==Work_SW9->W9_INVOICE .AND.;
                                     Work_SW8->WKFORN   ==Work_SW9->W9_FORN .And.;
                                     (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ)//FDR - 13/09/12 - Tratamento de loja
      Work_SW8->WKCOND_PA :=SW9->W9_COND_PA
      Work_SW8->WKDIAS_PA :=SW9->W9_DIAS_PA
      Work_SW8->WKMOEDA   :=SW9->W9_MOE_FOB
      Work_SW8->WKINCOTER :=SW9->W9_INCOTER
      WORK_SW9->W9_QTDE   +=Work_SW8->WKQTDE
      WORK_SW9->W9_PESO   +=Work_SW8->WKPESOTOT
      Work_SW8->(DBSKIP())
   ENDDO

   SW9->(DBSKIP())

ENDDO

// EOS - Inclui no browse das invoices, as invoices especiais que ficam armazenadas no
// arq. auxiliar EZZ.
IF lExistEZZ
EZZ->(DBSETORDER(1))
EZZ->(DBSEEK(xFilial()+SW6->W6_HAWB))
DO WHILE EZZ->(!EOF()) .AND.;
         EZZ->EZZ_HAWB   == SW6->W6_HAWB .AND.;
         EZZ->EZZ_FILIAL == cFILEZZ

   IF nCont > 10
      ProcRegua(10)
      nCont:=0
   ENDIF
   nCont++
   IncProc(STR0283+ALLTRIM(EZZ->EZZ_INVOIC)) //"Lendo Invoice: "

   Work_SW9->(DBAPPEND())
   Work_SW9->W9_INVOICE := EZZ->EZZ_INVOIC 
   Work_SW9->W9_DT_EMIS := EZZ->EZZ_DTEMIS
   Work_SW9->W9_FORN    := EZZ->EZZ_FORN
   Work_SW9->W9_NOM_FOR := BuscaFabr_Forn(EZZ->EZZ_FORN)
   Work_SW9->W9_MOE_FOB := EZZ->EZZ_MOEDA  
   Work_SW9->W9_TX_FOB  := EZZ->EZZ_TX_FOB
   Work_SW9->W9_COND_PA := EZZ->EZZ_CONDPA
   Work_SW9->W9_DIAS_PA := EZZ->EZZ_DIASPA
   Work_SW9->W9_FRETEIN := EZZ->EZZ_FRETEI  
   Work_SW9->W9_INLAND  := EZZ->EZZ_INLAND
   Work_SW9->W9_PACKING := EZZ->EZZ_PACKIN
   Work_SW9->W9_OUTDESP := EZZ->EZZ_OUTDES
   Work_SW9->W9_DESCONT := EZZ->EZZ_DESCON 
   Work_SW9->WK_TPINV   := 2  // EOS - Invoice especial, sem itens
   Work_SW9->WK_RECNO   := EZZ->(RECNO())

   EZZ->(DBSKIP())
ENDDO
ENDIF
DI600SWVGrv(.T.)// AWR - Lote
  
RETURN .T.
*----------------------------------------------------------------------------*
FUNCTION DI600CarregaWork(cLocAlias)//Antiga DI400GrvWKIGId ( PId_Ig )
*----------------------------------------------------------------------------*
LOCAL cProdSuf:=''
PRIVATE cAlias:=cLocAlias
IF(cAlias="W5_",DBSELECTAREA('SW5'),DBSELECTAREA('SW7'))

SYD->(DBSETORDER(1)) //TRP-10/01/08
Work->(DBAPPEND())
Work->WKCOD_I    :=  FIELDGET(FIELDPOS(cAlias+"COD_I"))
Work->WKFLUXO    :=  FIELDGET(FIELDPOS(cAlias+"FLUXO"))
Work->WKQTDE     :=  FIELDGET(FIELDPOS(cAlias+"QTDE"))
Work->WKPRECO    :=  FIELDGET(FIELDPOS(cAlias+"PRECO"))
Work->WKSALDO_Q  :=  FIELDGET(FIELDPOS(cAlias+"SALDO_Q"))
Work->WKSALDO_O  :=  FIELDGET(FIELDPOS(cAlias+"SALDO_Q"))
Work->WKSI_NUM   :=  FIELDGET(FIELDPOS(cAlias+"SI_NUM"))
Work->WKPO_NUM   :=  FIELDGET(FIELDPOS(cAlias+"PO_NUM"))
Work->WKPGI_NUM  :=  FIELDGET(FIELDPOS(cAlias+"PGI_NUM"))
Work->WKSEQ      :=  FIELDGET(FIELDPOS(cAlias+"SEQ"))
Work->WKCC       :=  FIELDGET(FIELDPOS(cAlias+"CC"))
Work->WKFABR     :=  FIELDGET(FIELDPOS(cAlias+"FABR"))
Work->WKFORN     :=  FIELDGET(FIELDPOS(cAlias+"FORN"))
Work->WKREG      :=  FIELDGET(FIELDPOS(cAlias+"REG"))
Work->WKPOSICAO  :=  FIELDGET(FIELDPOS(cAlias+"POSICAO"))
Work->WKPO_NUM   :=  FIELDGET(FIELDPOS(cAlias+"PO_NUM"))
Work->WKSEQ_LI   :=  FIELDGET(FIELDPOS(cAlias+"SEQ_LI"))
SB1->(DBSEEK(xFilial()+Work->WKCOD_I))
SW2->(DBSEEK(xFilial()+Work->WKPO_NUM))
Work->WKMOEDA    :=  SW2->W2_MOEDA
Work->WKPESO_L   :=  IF(cAlias="W5_",IF(!EMPTY(SW5->W5_PESO),SW5->W5_PESO,B1Peso(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,SW5->W5_FABR,SW5->W5_FORN)),SW7->W7_PESO)
Work->WKTEC      :=  Busca_NCM(IF(cAlias="W5_",'SW5','SW7'),"NCM"   ,.T.)
Work->WKEX_NCM   :=  Busca_NCM(IF(cAlias="W5_",'SW5','SW7'),"EX_NCM",.T.)
Work->WKEX_NBM   :=  Busca_NCM(IF(cAlias="W5_",'SW5','SW7'),"EX_NBM",.T.)
Work->WKDISPINV  :=  0
//FDR - 13/09/12 - Tratamento de loja
If EICLoja()
   Work->W7_FORLOJ :=  FIELDGET(FIELDPOS(cAlias+"FORLOJ"))
   Work->W7_FABLOJ :=  FIELDGET(FIELDPOS(cAlias+"FABLOJ"))
EndIf
If lIntDraw .and. lExistW8_AC
   If cAlias=="W5_"
      Work->WKAC     := FIELDGET(FIELDPOS(cAlias+"AC"))
      Work->WKSEQSIS := FIELDGET(FIELDPOS(cAlias+"SEQSIS"))
   Else
      SW5->(dbSetOrder(8))
      SW5->(dbSeek(cFilSW5+Work->WKPGI_NUM+Work->WKPO_NUM+Work->WKPOSICAO))
      Do While !SW5->(EOF()) .and. SW5->W5_SEQ <> 0
         SW5->(dbSkip())
      EndDo
      If SW5->W5_SEQ=0
         Work->WKAC     := SW5->W5_AC
         Work->WKSEQSIS := SW5->W5_SEQSIS
      EndIf
      SW5->(dbSetOrder(1))
   EndIf
EndIf

IF !SW9->(DBSEEK(xFilial()+SW7->W7_HAWB)) .AND. cAlias="W7_"
   Work->WKDISPINV:= Work->WKQTDE
ENDIF

IF SWP->(DBSEEK(xFilial()+Work->WKPGI_NUM+Work->WKSEQ_LI))
   Work->WKREGIST := SWP->WP_REGIST
   Work->WKREG_VEN:= SWP->WP_VENCTO
ENDIF

IF SW4->(DBSEEK(xFilial()+ Work->WKPGI_NUM ))
   Work->WKGI_NUM:= SW4->W4_GI_NUM
   cProdSuf      := SW4->W4_PROD_SU
ENDIF

E_ItFabFor(,cPRodSuf,"DI")   // grava descricao do item, nome do fabricante e fornecedor

IF SA5->(DBSEEK(xFilial()+Work->WKCOD_I+Work->WKFABR+Work->WKFORN))
   Work->WKPART_N:= SA5->A5_CODPRF
ENDIF

IF cAlias = "W7_"
   Work->WKRECNO_ID := SW7->(Recno())
   Work->WKQTDE_D   := SW7->W7_SALDO_Q
   Work->WKQTDEDORI := SW7->W7_SALDO_Q
   Work->WKOPERACA  := SW7->W7_OPERACA
   SW5->(PosOrd1_It_Guias(Work->WKPGI_NUM,Work->WKCC,Work->WKSI_NUM,;
                          Work->WKCOD_I,Work->WKFABR,Work->WKFORN,Work->WKREG,0,Work->WKPO_NUM, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ"))) // RJB 31/03/2004
   Work->WKSALDO_O  := Work->WKQTDE_D + SW5->W5_SALDO_Q
   Work->WKSALDO_Q  := SW5->W5_SALDO_Q
   Work->WKFLAG     :=  .T.
   Work->WKFLAG2    :=  .T.
   Work->WKFLAGWIN  :=  cMarca
   Work->WKFLAGWIN2 :=  cMarca
   Work->WK_ALTEROU := .F.
   SW2->(DBSEEK(xFilial()+Work->WKPO_NUM))
   M->W6_IMPORT:=SW2->W2_IMPORT
   cMoedaProc  :=SW2->W2_MOEDA
   IF SW7->(FIELDPOS('W7_LOCAL')) # 0
      Work->WKLOCAL := SW7->W7_LOCAL
   ENDIF
ELSE
   Work->WKRECNO_ID := SW5->(Recno())
   Work->WKDT_EMB   := SW5->W5_DT_EMB
   Work->WKDT_ENTR  := SW5->W5_DT_ENTR
   Work->WKNBM      := SW5->W5_NBM
   Work->WKDOCTO_F  := SW5->W5_DOCTO_F
   Work->WKOPERACA  := SW5->W5_OPERACA
   Work->WK_ALTEROU := .T.
   IF Inclui    //Inicializar os itens desmarcados.
      Work->WKQTDE  := 0
      Work->WKQTDE_D:= 0
   ENDIF
   // RAD 01/04/03
   Work->WKLOCAL:=SB1->B1_LOCPAD
   IF PosO1_It_Solic(SW5->W5_CC,SW5->W5_SI_NUM,SW5->W5_COD_I,SW5->W5_REG,0)
      SW0->(DBSEEK(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))
      cPosicaoW1 := ALLTRIM(SW1->W1_POSICAO)
      IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+Right(cPosicaoW1, AvSx3("C1_ITEM", AV_TAMANHO)))) .AND.;
         !EMPTY(SC1->C1_LOCAL)
         Work->WKLOCAL := SC1->C1_LOCAL
      ELSE                             
         xLOCAL:="DP"+SW0->W0__POLE
         IF SX5->(DBSEEK(xFilial("SX5")+xLOCAL))
            Work->WKLOCAL:= SW0->W0__POLE
         ENDIF
      ENDIF            
   ENDIF   
ENDIF

//TRP-10/01/08
IF cAlias = "W5_"
   SYD->(DbSeek(xFilial()+Work->WKTEC+Work->WKEX_NCM+Work->WKEX_NBM))
   Work->WKTES:= SYD->YD_TES
ELSEIF cAlias = "W7_"
   IF SW7->( FieldPos("W7_TES") ) > 0
      Work->WKTES := SW7->W7_TES
   ELSE
      SYD->(DbSeek(xFilial()+Work->WKTEC+Work->WKEX_NCM+Work->WKEX_NBM))
      Work->WKTES:= SYD->YD_TES      
   ENDIF
ENDIF   
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRV_WORK_ITEM"),)

RETURN .T.
*--------------------------------------------------------------------------------------*
Function DI600MarcaAll(cAlias,oBrw)// Antigas DI400AllMark e DI_MarcaAll(oBrw)
*--------------------------------------------------------------------------------------*
Local cNewMarca, nRec_Work := (cAlias)->(Recno()),lOK:=.T.
Local lMensagem:=.F.
ProcRegua((cAlias)->(Easyreccount(cAlias)))
IF cAlias == 'Work'
   lGravaSoCapa:=.F.
   IF Work->WKFLAG
      cNewMarca := Space(2)
      Work->(DBGOTOP())
      Work->(DBEVAL({||lOK:=.F.},{|| Work->WKDISPINV # Work->WKQTDE .AND. WKFLAG },{|| lOK  } ))
      IF !lOK 
         IF !MSGYESNO(STR0284,STR0141) //"Existem Itens com Invoice, Continua Desmarca Todos?"
            (cAlias)->(dbGoTo(nRec_Work))
            RETURN .F. 
         ENDIF
      ENDIF         
   ELSE
      cNewMarca := cMarca
   ENDIF
   Work_SW9->(DBSETORDER(1))
   Work_SW8->(DBSETORDER(2))
   Work->(dbGoTop())
   DO While !Work->(Eof())
      IncProc(STR0285+Work->WKCOD_I) //"Des/Marcando Item: "

      IF Empty(cNewMarca) .And. Work->WKFLAG
         Work->WKSALDO_Q := Work->WKSALDO_O
         Work->WKQTDE_D  := 0
         Work->WKQTDE    := 0
         Work->WKFLAG    := .F.
         Work->WKFLAGWIN := Space(2)
         Work->WK_ALTEROU:= .T.
         WORK->WKDISPINV := 0
         M->W6_PESOL     -= Work->WKPESO_L * Work->WKQTDE
         IF M->W6_PESOL < 0
            M->W6_PESOL := 0
         ENDIF
         IF Work_SW8->(DBSEEK(WORK->WKFORN+EICRetLoja("Work", "W7_FORLOJ")+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM))
            DO WHILE Work_SW8->(!EOF()) .AND.;
                     WORK_SW8->(WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+WKPO_NUM+WKPOSICAO+WKPGI_NUM) ==;
                     WORK->(WKFORN+EICRetLoja("Work", "W7_FORLOJ")+WKPO_NUM+WKPOSICAO+WKPGI_NUM)
               IF Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+WORK_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+M->W6_HAWB)) //TDF - 13/09/12 - TRATAMENTO DE LOTE
                  WORK_SW9->W9_FOB_TOT-=Work_SW8->WKPRTOTMOE
                  WORK_SW9->W9_TUDO_OK:=NAO
               ENDIF
               DI600LoteVal("DEL_LOTE",,,WORK_SW8->(WKFORN+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE))// AWR - Lote
               lDeleta:=.T.
               IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DESMARCA_ALL_ITEM_SW7"),)
               IF lDeleta
                  Work_SW8->(DBDELETE())
               ELSE
                  Work_SW8->WKFLAGIV :="  " 
                  Work_SW8->WKINVOICE:=SPACE(LEN(SW9->W9_INVOICE))
               ENDIF
               Work_SW8->(DBSKIP())
            ENDDO
         ENDIF
      Elseif !Empty(cNewMarca) .And. !Work->WKFLAG
         Work->WKQTDE    := Work->WKSALDO_Q
         Work->WKQTDE_D  := Work->WKSALDO_Q
         Work->WKSALDO_Q := 0
         Work->WKFLAG    := .T.
         Work->WKFLAGWIN := cMarca
         Work->WK_ALTEROU:= .T.
         WORK->WKDISPINV := Work->WKQTDE
         M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE
         IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"MARCA_ALL_ITEM_SW7"),)
     Endif
     Work->(dbSkip())
   ENDDO

ELSEIF cAlias == 'TRB'
   IF TRB->WK_OK == cMarca
      cNewMarca:=SPACE(02)
   ELSE
      cNewMarca:=cMarca
   ENDIF
   TRB->(DBGOTOP())
   DO WHILE !TRB->(EOF())
      IncProc(STR0285+TRB->W7_COD_I) //"Des/Marcando Item: "
      TRB->WK_OK :=cNewMarca
      TRB->(DBSKIP())
   ENDDO

ELSEIF cAlias == 'Work_SW8'
   IF Work_SW8->WKFLAGIV == cMarca
      cNewMarca := Space(2)
   ELSE
      cNewMarca := cMarca
   ENDIF
   IF Empty(cNewMarca)
      IF !DI600LoteVal("EXCLUI_LOTE") // AWR - LOTE
         RETURN .F.
      ENDIF
   ENDIF
   DBSELECTAREA("Work_SW8")
   SET FILTER TO
   Work_SW8->(DBSETORDER(2))
   Work_SW8->(dbGoTop())
   DO While !Work_SW8->(Eof())
      IncProc(STR0285+Work_SW8->WKCOD_I) //"Des/Marcando Item: "
      IF WORK_SW8->WKMOEDA <> M->W9_MOE_FOB 
         WORK_SW8->(DBSKIP())
         LOOP
      ENDIF
      IF WORK_SW8->WKFORN <> M->W9_FORN .Or. (EICLoja() .And. WORK_SW8->W8_FORLOJ <> M->W9_FORLOJ)//FDR - 13/09/12 - Tratamento de loja
         WORK_SW8->(DBSKIP())
         LOOP
      ENDIF

      IF Empty(cNewMarca) .And. !EMPTY(Work_SW8->WKFLAGIV) .AND.;
         Work_SW8->WKINVOICE == M->W9_INVOICE .AND. Work_SW8->WKFORN == M->W9_FORN .And. (!EICLoja() .Or. Work_SW8->W8_FORLOJ == M->W9_FORLOJ)//FDR - 13/09/12 - Tratamento de loja

         DI600InvMarca('D')
      
      Elseif !Empty(cNewMarca).AND.EMPTY(Work_SW8->WKFLAGIV).AND.EMPTY(Work_SW8->WKINVOICE)
      
         DI600InvMarca('M')
      
      Endif
      Work_SW8->(dbSkiP())
   ENDDO
   DBSELECTAREA("Work_SW8")
   Work_SW8->(DBSETORDER(2))

   //FDR - 13/09/12 - Tratamento de loja
   If !EICLoja()
      SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN == M->W9_INVOICE+M->W9_FORN .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_MOE_FOB)
   Else
      SET FILTER TO Work_SW8->WKINVOICE+Work_SW8->WKFORN+Work_SW8->W8_FORLOJ == M->W9_INVOICE+M->W9_FORN+M->W9_FORLOJ .OR. (EMPTY(Work_SW8->WKINVOICE) .AND. Work_SW8->WKFORN+Work_SW8->W8_FORLOJ+Work_SW8->WKMOEDA == M->W9_FORN+M->W9_FORLOJ+M->W9_MOE_FOB)
   EndIf
   
ENDIF

(cAlias)->(dbGoTo(nRec_Work))
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF

RETURN .T.
*-------------------------------------------*
FUNCTION DI600InvMarca(cTipo)   
*-------------------------------------------*
WORK->(DBSETORDER(3))
IF cTipo == 'D'
   DI600LoteVal("DEL_LOTE",,,WORK_SW8->(WKFORN+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE))// AWR - Lote
   Work_SW8->WKFLAGIV:="  "
   Work_SW8->WKINVOICE:=SPACE(LEN(SW9->W9_INVOICE))
   IF WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
      WORK->WKDISPINV:=Work_SW8->WKSALDO_AT
   ENDIF                    
   Work_SW8->WKDISPLOT :=WORK_SW8->WKQTDE// AWR - Lote - 07/06/2004

ELSEIF cTipo == 'M'
   Work_SW8->WKFLAGIV  :=cMarca
   Work_SW8->WKINVOICE :=M->W9_INVOICE
   Work_SW8->WKPRTOTMOE:=DI600Trans(Work_SW8->WKQTDE * Work_SW8->WKPRECO)
   Work_SW8->WKPESOTOT :=Work_SW8->WKPESO_L*Work_SW8->WKQTDE
   IF WORK->(DBSEEK(Work_SW8->WKPO_NUM+Work_SW8->WKPGI_NUM+Work_SW8->WKPOSICAO))
      IF Work_SW8->WKSALDO_AT - Work_SW8->WKQTDE > 0
         WORK->WKDISPINV:=Work_SW8->WKSALDO_AT-Work_SW8->WKQTDE
      ELSE
         WORK->WKDISPINV:=0
      ENDIF
   ENDIF
   Work_SW8->WKDISPLOT :=WORK_SW8->WKQTDE// AWR - Lote - 07/06/2004
ENDIF
RETURN .T.

*----------------------------------------------------------------------------
Function DI600MarkItem()//Antiga DI400ItemMarca()
*----------------------------------------------------------------------------
LOCAL cTitulo:=STR0286, oDlg, nOpcA //"Selecao do Item do Processo"
PRIVATE nL1, nL2, nL3, nL4, nL5, nL6, nL7, nL8, nL9, nLa, nC1, nC2, nC3
PRIVATE  nFobTotal:=0, oFobTotal,lVolta:=.F. //Variavel usada no Rdmake  
lGravaSoCapa:=.F.   

nL1:=10 ; nL2:=23 ; nL3:=036 ; nL4:= 049 ; nL5:= 062 
nL6:=75 ; nL7:=88 ; nL8:=101 ; nL9:= 114 ; nLa:= 127
nC1:=08 ; nC2:=49 ; nC3:=098 ; nC4:= 127

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TELA_MARCA_ITEM"),)

IF lVolta
   RETURN .T.
ENDIF   

Work->WK_ALTEROU := .T.

IF Work->WKFLAG .AND. !lTemCambio
   IF Work->WKDISPINV # Work->WKQTDE
      IF !MSGYESNO(STR0287,STR0141) //"Item possui Invoice, Deseja Desmarcar?"
         RETURN .F. 
      ENDIF
      DBSELECTAREA("Work_SW8")
      SET FILTER TO
      Work_SW8->(DBSETORDER(2))
      IF Work_SW8->(DBSEEK(WORK->WKFORN+EICRetLoja("Work", "W7_FORLOJ")+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM))
         DO WHILE Work_SW8->(!EOF()) .AND.;
                  WORK_SW8->(WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+WKPO_NUM+WKPOSICAO+WKPGI_NUM) ==;
                  WORK->(WKFORN+EICRetLoja("Work", "W7_FORLOJ")+WKPO_NUM+WKPOSICAO+WKPGI_NUM)
            IF Work_SW9->(DBSEEK(Work_SW8->WKINVOICE+WORK_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")))
               WORK_SW9->W9_FOB_TOT-=Work_SW8->WKPRTOTMOE
               WORK_SW9->W9_TUDO_OK:=NAO
            ENDIF
            DI600LoteVal("DEL_LOTE",,,WORK_SW8->(WKFORN+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE))// AWR - Lote
            lDeleta:=.T.
            IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DESMARCA_ITEM_SW7"),)
            IF lDeleta
               Work_SW8->(DBDELETE()) 
            ELSE
               Work_SW8->WKADICAO :="   "
               Work_SW8->WKINVOICE:=SPACE(LEN(SW9->W9_INVOICE))
            ENDIF
            Work_SW8->(DBSKIP())
         ENDDO
      ENDIF
   ENDIF
   Work->WKSALDO_Q:= Work->WKSALDO_O
   Work->WKDISPINV:= 0
   Work->WKQTDE_D := 0
   Work->WKQTDE   := 0
   Work->WKFLAG   := !Work->WKFLAG
   Work->WKFLAGWIN:= Space(2)
   M->W6_PESOL    -= Work->WKPESO_L * Work->WKQTDE
   IF M->W6_PESOL < 0
      M->W6_PESOL := 0
   ENDIF
   RETURN .T.
ENDIF

TSaldo_Q     := Work->WKSALDO_Q
TFobUnit     := Work->WKPRECO
M->W7_PESO   := Work->WKPESO_L
M->W7_NCM    := Work->WKTEC
M->W7_EX_NCM := Work->WKEX_NCM
M->W7_EX_NBM := Work->WKEX_NBM
nFobTotal    := DI600Trans(TSaldo_Q * TFobUnit)
cLocal       := Work->WKLOCAL

DEFINE MSDIALOG oDlg TITLE cTitulo From 15,03 To 47,46 OF oMainWnd //35

   oPnl:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 1, 1)
   oPnl:Align:= CONTROL_ALIGN_ALLCLIENT   

   @nL1,nC1 SAY AVSX3("W7_COD_I",5)  SIZE 40,8 OF oPnl PIXEL//'Codigo Item'
   @nL1,nC2 MSGET Work->WKCOD_I    PICT AVSX3("W7_COD_I",6) SIZE 95,08 OF oPnl PIXEL WHEN .F.

   @nL2,nC1 SAY AVSX3("A5_CODPRF",5)  SIZE 40,8 OF oPnl PIXEL//Part Number
   @nL2,nC2 MSGET Work->WKPART_N   PICT '@!' SIZE 95,08 OF oPnl PIXEL WHEN .F.

   @nL3,nC1 SAY AVSX3("W7_FABR",5)    SIZE 40,8 OF oPnl PIXEL//Fabricante
   @nL3,nC2 MSGET Work->WKNOME_FAB PICT '@!'   SIZE 95,08 OF oPnl PIXEL WHEN .F.

   @nL4,nC1 SAY AVSX3("W7_FORN",5)    SIZE 40,8 OF oPnl PIXEL//Fornecedor
   @nL4,nC2 MSGET Work->WKNOME_FOR PICT '@!'   SIZE 95,08 OF oPnl PIXEL WHEN .F.

   @nL5,nC1 SAY AVSX3("W7_SALDO_Q",5) SIZE 40,08 OF oPnl PIXEL//Saldo Qtde
   @nL5,nC2 MSGET TSaldo_Q PICTURE _PictQtde VALID DI_Valid('TSALDO_Q',.F.) .AND. DI600Valid("W7_PESO") SIZE 80,08 OF oPnl PIXEL WHEN !lTemCambio

   @nL6,nC1 SAY STR0048               SIZE 40,8 OF oPnl PIXEL//Preco Unitario
   @nL6,nC2 MSGET TFobUnit PICTURE _PictPrUn VALID DI_Valid('TFOBUNIT',.F.) SIZE 80,08 OF oPnl PIXEL WHEN !lTemCambio

   @nL7,nC1 SAY STR0108               SIZE 50,8 OF oPnl PIXEL//FOB Total
   @nL7,nC2 MSGET oFobTotal VAR nFobTotal PICTURE _PictPrUn SIZE 80,08 OF oPnl WHEN .F. PIXEL

   @nL8,nC1 SAY AVSX3("W7_PESO",5)    SIZE 50,8 OF oPnl PIXEL
   // RAD 25/03 ARGENTINA @nL8,nC2 MSGET M->W7_PESO    PICTURE AVSX3("W7_PESO",6) VALID DI_Valid('M->W7_PESO',.F.) SIZE 80,08 PIXEL
   //@nL8,nC2 MSGET M->W7_PESO    PICTURE AVSX3("W7_PESO",6)  SIZE 80,08 PIXEL
   @nL8,nC2 MSGET M->W7_PESO  PICTURE AVSX3("W7_PESO",6) VALID DI600Valid("W7_PESO") SIZE 80,08 OF oPnl PIXEL

   @nL9,nC1 SAY AVSX3("W7_NCM",5)  SIZE 40,8 OF oPnl PIXEL
   @nL9,nC2 MSGET M->W7_NCM    SIZE 45,8 OF oPnl VALID DI_Valid('TEC1',.F.) PICTURE AVSX3("W3_TEC"   ,6) F3 AVSX3("W3_TEC",8) PIXEL
   @nL9,nC3 MSGET M->W7_EX_NCM SIZE 05,8 OF oPnl VALID DI_Valid('TEC2',.F.) PICTURE AVSX3("W3_EX_NCM",6) F3 AVSX3("W3_EX_NCM",8) WHEN !Empty(M->W7_NCM) PIXEL
   @nL9,nC4 MSGET M->W7_EX_NBM SIZE 05,8 OF oPnl VALID DI_Valid('TEC3',.F.) PICTURE AVSX3("W3_EX_NBM",6) F3 AVSX3("W3_EX_NBM",8) WHEN !Empty(M->W7_NCM) PIXEL
   cF3:=AVSX3("C1_LOCAL",8)
         
   @nLa,nC1 SAY "Local" OF oPnl PIXEL
   IF EMPTY(cF3)
      @ nLa,nC2 MSGET cLocal SIZE 17,08 OF oPnl PIXEL PICTURE "@!"
   ELSE
      @ nLa,nC2 MSGET cLocal SIZE 17,08 OF oPnl PIXEL PICTURE "@!" F3 AVSX3("C1_LOCAL",8)
   ENDIF

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TELA_GET_ITEM"),)

   @0.2,0.3 TO 10,20 OF oPnl

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, { || nOpcA:=1, oDlg:End() }, { || nOpcA:=0, oDlg:End() },,,,,,,.F.) CENTERED

DBSELECTAREA("Work")

IF nOpcA = 1
   IF lTemCambio
      DBSELECTAREA("Work_SW8")
      SET FILTER TO
      Work_SW8->(DBSETORDER(2))
      IF Work_SW8->(DBSEEK(WORK->WKFORN+WORK->WKPO_NUM+WORK->WKPOSICAO+WORK->WKPGI_NUM))
         DO WHILE Work_SW8->(!EOF()) .AND.;
                  WORK_SW8->(WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM) ==;
                  WORK->(WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM)
            Work_SW8->WKTEC     := M->W7_NCM
            Work_SW8->WKEX_NCM  := M->W7_EX_NCM
            Work_SW8->WKEX_NBM  := M->W7_Ex_NBM
            Work_SW8->WKPESO_L  := M->W7_PESO
            Work_SW8->WKPESOTOT := M->W7_PESO*Work_SW8->WKQTDE
            IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRV_ALT_SW8"),)
            Work_SW8->(DBSKIP())
         ENDDO
      ENDIF
      M->W6_PESOL     -= Work->WKPESO_L * Work->WKQTDE
      IF M->W6_PESOL < 0
         M->W6_PESOL := 0
      ENDIF
      Work->WKPESO_L  := M->W7_PESO
      Work->WKTEC     := M->W7_NCM
      Work->WKEX_NCM  := M->W7_EX_NCM
      Work->WKEX_NBM  := M->W7_Ex_NBM
      M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE
      Work->WKLOCAL   := cLocal
      IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"MARCA_ITEM_COM_CAMBIO"),)
      RETURN .T.
   ENDIF
   Work->WKQTDE    := TSaldo_Q
   Work->WKQTDE_D  := TSaldo_Q
   Work->WKSALDO_Q := Work->WKSALDO_Q - TSaldo_Q
   Work->WKPRECO   := TFobUnit
   Work->WKFLAG    := .T.
   Work->WKFLAGWin := cMarca
   Work->WKPESO_L  := M->W7_PESO
   Work->WKTEC     := M->W7_NCM
   Work->WKEX_NCM  := M->W7_EX_NCM
   Work->WKEX_NBM  := M->W7_Ex_NBM
   WORK->WKDISPINV := Work->WKQTDE
   M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE
   Work->WKLOCAL   := cLocal
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"MARCA_ITEM_SW7"),)
ENDIF

RETURN .T.
*--------------------------------------------------------------------------------------*
Function DI600DigItem(oBrw) // Antiga DI_DigItem(oBrw)// by CAF 29/10/1998
*--------------------------------------------------------------------------------------*
#xTranslate AVPic(<Cpo>) => AllTrim(X3Picture(<Cpo>))
Local oDlg, nOpcA

Local aValid := {"COD_I","QTDE","PRECO"}
Local bValid := {|| aScan(aValid,{|x| !DI600DigVal(x)})==0 }
Local nRec_Work := Work->(Recno()), nOrd_Old
Local lEstavaMarcado := .F.

Local cCod_I_Old, nQtde_Old, nPreco_Old
Local oCod, oQtd, oPrc, oItem//, aObj[3]
Local oConfirma, oCancel

Local nQtdeAtualizada := 0, lAtualizou := .F.

cCod_I_Old := cDigCod_I
nQtde_Old  := nDigQtde

DO While .T.
   cDigCod_I := CriaVar("W7_COD_I")
   nDigQtde  := CriaVar("W7_QTDE")
// nDigPreco := CriaVar("W7_PRECO")

   nOpcA := 0
   DEFINE MSDIALOG oDlg TITLE STR0096 From 7,03 To 25,40 OF oMainWnd //"Seleção de Itens por Digitação"

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 1, 1)
      oPanel:Align := CONTROL_ALIGN_ALLCLIENT

      @ 20,08 TO 58,136 LABEL STR0244 OF oPanel PIXEL //"Último item:"
      @ 26,10 SAY AVSX3("W7_COD_I",5)   OF oPanel PIXEL //'Codigo Item'
      @ 39,10 SAY AVSX3("W7_SALDO_Q",5) OF oPanel PIXEL //'Saldo Qtde'

      @ 26,54 MSGET oCod VAR cCod_I_Old PICT AVPic("B1_COD") F3 "SB1" SIZE 75,9 OF oPanel PIXEL
      oCod:Disable()
      @ 39,54 MSGET oQtd VAR nQtde_Old  PICT AVPic("W7_QTDE") SIZE 75,9 OF oPanel PIXEL
      oQtd:Disable()

      @ 071,8  TO 110,136 LABEL STR0246  OF oPanel PIXEL //"Próximo item:"
      @ 078,10 SAY AVSX3("W7_COD_I",5)   OF oPanel PIXEL //'Codigo Item'
      @ 091,10 SAY AVSX3("W7_SALDO_Q",5) OF oPanel PIXEL //'Saldo Qtde'

      @ 78,54 MSGET oItem VAR cDigCod_I F3 "SB1" PICT AVPic("B1_COD") ;
            VALID (DI600DigVal("COD_I")) SIZE 75,9 OF oPanel PIXEL

      @ 91,54 MSGET nDigQtde  PICT AVPic("W7_QTDE");
            VALID (DI600DigVal("QTDE"))  SIZE 75,9 OF oPanel PIXEL

   ACTIVATE MSDIALOG oDlg ON INIT DI600EnchoiceBar(oDlg,;
                                  {{|| IF(Eval(bValid),(nOpcA:=1,oDlg:End()),)},"OK"},;
                                  {|| nOpcA:=0, oDlg:End()},.F.) CENTERED

   IF nOpcA == 0
      cDigCod_I := cCod_I_Old
      nDigQtde  := nQtde_Old
      Exit
   Endif
   lGravaSoCapa:=.F.   

   cCod_I_Old := cDigCod_I
   nQtde_Old  := nDigQtde

   nOrd_Old := Work->(IndexOrd())
   Work->(dbSetOrder(4)) // WKCOD_I+DTOS(WKDT_EMB)
   Work->(dbGoTop())
   Work->(dbSeek(cDigCod_I))

   DO While !Work->(Eof()) .And. Work->WKCOD_I==cDigCod_I .And.;
         nDigQtde > 0

      lEstavaMarcado := Work->WKFLAG
      nQtdeAtualizada:= 0

      Work->WK_ALTEROU := .T.

      If nDigQtde > Work->WKSALDO_Q
         nDigQtde -= Work->WKSALDO_Q

         IF lEstavaMarcado
            M->W6_PESOL     -= Work->WKPESO_L * Work->WKQTDE
            IF M->W6_PESOL < 0
               M->W6_PESOL := 0
            ENDIF
            Work->WKQTDE    += Work->WKSALDO_Q
         Else
            Work->WKQTDE    := Work->WKSALDO_Q
         Endif

         nQtdeAtualizada := Work->WKSALDO_Q
         Work->WKSALDO_Q := 0
      Else
         Work->WKSALDO_Q -= nDigQtde

         If lEstavaMarcado
            M->W6_PESOL     -= Work->WKPESO_L * Work->WKQTDE
            IF M->W6_PESOL < 0
               M->W6_PESOL := 0
            ENDIF
            Work->WKQTDE    += nDigQtde
            nQtdeAtualizada := nDigQtde
         Else
            Work->WKQTDE    := nDigQtde
         Endif

         nQtdeAtualizada := nDigQtde
         nDigQtde := 0
      Endif

      Work->WKQTDE_D  := Work->WKQTDE
      Work->WKFLAG    := .t.
      Work->WKFLAGWIN := cMarca
      M->W6_PESOL     += Work->WKPESO_L * Work->WKQTDE
      WORK->WKDISPINV := Work->WKQTDE
      Work->(dbSkip())
   EndDO

   Work->(dbSetOrder(nOrd_Old))
   Work->(dbGoTop())
   Work->(dbGoTo(nRec_Work))

EndDO
IF oBrw # NIL
   oBrw:Refresh()
   oBrw:Reset()
ENDIF
Return .T.
*--------------------------------------------------------
Function DI600DigVal(cCpo)
*--------------------------------------------------------
Local nRec_Work := Work->(Recno())
Local nOrd_Old  := Work->(IndexOrd())
Local nSaldo  := 0
Local lOk := .f.
Local lAltPreco := .t., nPreco := 0
Local cPO  := Work->WKPO_NUM
Local cPLI := Work->WKPGI_NUM

DO CASE
   CASE cCpo == "COD_I"
      IF EMPTY(cDigCod_I)
         Return .T.
      ENDIF
      If ! ExistCpo("SB1",cDigCod_I)
         Return .F.
      Endif

      Work->(dbSetOrder(4)) // WKCOD_I+DTOS(WKDT_EMB)
      Work->(dbGoTop())
      Work->(dbSeek(cDigCod_I))

      DO While !Work->(Eof()) .And. Work->WKCOD_I == cDigCod_I
         nSaldo += Work->WKSALDO_Q
         lOk := .T.

         IF Work->WKPO_NUM == cPO .And. Work->WKPGI_NUM == cPLI
            nPreco := Work->WKPRECO
         ENDIF

         If Work->WKFLAG
            lAltPreco := .F.
         ENDIF

         If nSaldo > 0
            IF !lAltPreco
               Exit
            ENDIF
         Endif

         Work->(dbSkip())
      End

      Work->(dbSetOrder(nOrd_Old))
      Work->(dbGoTop())
      Work->(dbGoTo(nRec_Work))

      If ! lOk
         Help("", 1, "AVG0000281")//Item nao cadastrado para este pedido !
         Return .F.
      Endif

      If nSaldo <= 0
         Help("", 1, "AVG0000282")//Nao ha saldo disponivel para este item !
         Return .F.
      Endif

//    IF Empty(nDigPreco)
//       nDigPreco := nPreco
//    ENDIF

//    IF !lAltPreco
//       oPreco:Disable()
//    ENDIF

//    oPreco:Refresh()


   CASE cCpo == "QTDE"
      If !NaoVazio(nDigQtde) .Or. !Positivo(nDigQtde)
         Return .f.
      Endif

      Work->(dbSetOrder(4)) // WKCOD_I+DTOS(WKDT_EMB)
      Work->(dbGoTop())
      Work->(dbSeek(cDigCod_I))

      DO While !Work->(Eof()) .And. Work->WKCOD_I == cDigCod_I
         nSaldo += Work->WKSALDO_Q
         Work->(dbSkip())
      ENDDO

      Work->(dbSetOrder(nOrd_Old))
      Work->(dbGoTop())
      Work->(dbGoTo(nRec_Work))

      If nSaldo < nDigQtde
          Help("", 1, "AVG0000283")//"Quantidade digitada e maior que o saldo atual deste item !
         Return .F.
      Endif

ENDCASE

Return .t.
*----------------------------------------------------------------------------*
FUNCTION DI600GravaTudo()//Antiga DI_GRAVA do EIC.PRW
*----------------------------------------------------------------------------*
LOCAL cDesc:=IF(MOpcao # FECHTO_EMBARQUE,STR0186,STR0085)//'Desembaraco'###'Embarque'
LOCAL aDespDa:={}, nDespDa:=0, P, iDA, i, _nx

DBSELECTAREA("Work")
SET FILTER TO
Work->(DBSETORDER(3))

cPO_NUM := SPACE(07)
ProcRegua(Work->(Easyreccount("Work"))+LEN(aPli)+2)

SWD->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SW7->(DBSETORDER(1))

//INICIA O CONTROLE DE TRANSACAO
//Begin Transaction
   Work->(DBGOTOP())
   DO WHILE Work->(!EOF())

      IncProc(STR0077+ALLTRIM(Work->WKCOD_I))

      If MOpcao == FECHTO_NACIONALIZACAO 
         If SW2->(DBSEEK(xFilial("SW2")+Work->WKPO_NUM)) .AND. ! EMPTY(ALLTRIM(SW2->W2_HAWB_DA))
            SWD->(DBSEEK(xFilial("SWD")+SW2->W2_HAWB_DA))      
            Do While ! SWD->(EOF()) .AND. SWD->WD_HAWB = SW2->W2_HAWB_DA .AND. xFilial("SWD") = SWD->WD_FILIAL
               If LEFT(SWD->WD_DESPESA,1)#"9" .AND. SWD->WD_DESPESA#"101" .AND. SWD->WD_DESPESA#"102" .AND. SWD->WD_DESPESA#"103"
                  nDespDa:=ASCAN(aDespDa, {|x| x[1] = SWD->WD_DESPESA} ) 
                  If nDespDa = 0
                     Aadd(aDespDa,{SWD->WD_DESPESA,;
                                  (SWD->WD_VALOR_R*(((Work->WKQTDE*Work->WKPRECO)/SW2->W2_FOB_TOT))),;
                                   SWD->(RECNO())} )
                  Else
                     aDespDa[nDespDa,2]+=(SWD->WD_VALOR_R*(((Work->WKQTDE*Work->WKPRECO)/SW2->W2_FOB_TOT)))
                  EndIf
               EndIf
               SWD->(DBSKIP())
            EndDo
         EndIf
      EndIf

      IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_ANTES_LOOP_FLAG"),)

      IF !Work->WK_ALTEROU
         Work->(DBSKIP())
         LOOP
      ENDIF

      IF Work->(!WKFLAG) .AND. Work->(!WKFLAG2)
         Work->(DBSKIP())
         LOOP
      ENDIF
      
      IF Work->(!WKFLAG2)

         SW7->(RecLock("SW7",.T.))  // lock com append
         SW7->W7_FILIAL   :=   xFilial("SW7")
         SW7->W7_HAWB     :=   M->W6_HAWB
         SW7->W7_COD_I    :=   Work->WKCOD_I
         SW7->W7_FABR     :=   Work->WKFABR
         SW7->W7_FORN     :=   Work->WKFORN
         SW7->W7_FLUXO    :=   Work->WKFLUXO
         SW7->W7_QTDE     :=   Work->WKQTDE
         SW7->W7_PRECO    :=   Work->WKPRECO
         SW7->W7_SALDO_Q  :=   Work->WKQTDE
         SW7->W7_SI_NUM   :=   Work->WKSI_NUM
         SW7->W7_PO_NUM   :=   Work->WKPO_NUM
         SW7->W7_PGI_NUM  :=   Work->WKPGI_NUM
         SW7->W7_SEQ      :=   0
         SW7->W7_REG      :=   Work->WKREG
         SW7->W7_CC       :=   Work->WKCC
         SW7->W7_SEQ_LI   :=   Work->WKSEQ_LI
         SW7->W7_POSICAO  :=   Work->WKPOSICAO
         SW7->W7_PESO     :=   Work->WKPESO_L
         SW7->W7_NCM      :=   Work->WKTEC
         SW7->W7_EX_NCM   :=   Work->WKEX_NCM
         SW7->W7_EX_NBM   :=   Work->WKEX_NBM
         SW7->W7_OPERACA  :=   Work->WKOPERACA
         IF SW7->(FIELDPOS('W7_LOCAL')) # 0   // RAD 01/04
            SW7->W7_LOCAL :=   Work->WKLOCAL
         ENDIF           
         
         IF SW7->(FIELDPOS("W7_TES")) > 0   // TRP-10/01/08
            SW7->W7_TES := Work->WKTES
         ENDIF
         
         If EICLoja()
            SW7->W7_FABLOJ := Work->W7_FABLOJ
            SW7->W7_FORLOJ := Work->W7_FORLOJ
         EndIf           
         IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_INCLUI_SW7"),)

         SW7->(MSUnlock())

         MSeq := 0    

         DI400IdAtuSld("1")

         MSeq := MSeq + 1
         SW5->(RecLock("SW5",.T.))// lock com append
         SW5->W5_SEQ_LI   :=   Work->WKSEQ_LI  //FCD 31/10/01       
         SW5->W5_COD_I    :=   Work->WKCOD_I
         SW5->W5_FABR     :=   Work->WKFABR
         SW5->W5_FORN     :=   Work->WKFORN  
         
         //FDR - 13/09/12 - Tratamento de loja
         If EICLoja()
            SW5->W5_FABLOJ := Work->W7_FABLOJ
            SW5->W5_FORLOJ := Work->W7_FORLOJ
         EndIf
         
         SW5->W5_FLUXO    :=   Work->WKFLUXO
         SW5->W5_QTDE     :=   Work->WKQTDE
         SW5->W5_PRECO    :=   Work->WKPRECO
         SW5->W5_SALDO_Q  :=   0
         SW5->W5_HAWB     :=   M->W6_HAWB
         SW5->W5_SI_NUM   :=   Work->WKSI_NUM
         SW5->W5_PO_NUM   :=   Work->WKPO_NUM
         SW5->W5_PGI_NUM  :=   Work->WKPGI_NUM
         SW5->W5_NBM      :=   Work->WKNBM
         SW5->W5_DT_EMB   :=   Work->WKDT_EMB
         SW5->W5_DT_ENTR  :=   Work->WKDT_ENTR
         SW5->W5_SEQ      :=   MSeq
         SW5->W5_CC       :=   Work->WKCC
         SW5->W5_REG      :=   Work->WKREG
         SW5->W5_DOCTO_F  :=   Work->WKDOCTO_F
         SW5->W5_FILIAL   :=   xFilial("SW5")
         SW5->W5_POSICAO  :=   Work->WKPOSICAO
         SW5->W5_PESO     :=   Work->WKPESO_L
         SW5->W5_EX_NCM   :=   Work->WKEX_NCM
         SW5->W5_EX_NBM   :=   Work->WKEX_NBM
         
         IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_INCLUI_SW5"),)
         SW5->(MSUnlock())

      ELSE

         IF !Work->(WKFLAG)

            SW7->(DBGOTO( Work->WKRECNO_ID ))
            SW7->(RecLock("SW7",.F.,.T.))
            SW7->(DBDELETE())
            SW7->(MSUnlock())

            IF PosOrd2_IT_Guias(M->W6_HAWB,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I ,;
                                Work->WKFABR,Work->WKFORN,Work->WKREG,Work->WKPGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ")) //RJB 31/03/2004
               SW5->(RecLock("SW5",.F.,.T.))
               SW5->(DBDELETE())
               SW5->(MSUnlock())
            ENDIF

            DI400IdAtuSld("2")

         ELSE

            IF Work->WKQTDE > Work->WKQTDEDORI .OR. Work->WKQTDE < Work->WKQTDEDORI

               SW7->(DBGOTO(Work->WKRECNO_ID))
               SW7->(RecLock("SW7",.F.))

               IF Work->WKQTDE > Work->WKQTDEDORI
                  SW7->W7_QTDE   := SW7->W7_QTDE    + ( Work->WKQTDE - Work->WKQTDEDORI )
                  SW7->W7_SALDO_Q:= SW7->W7_SALDO_Q + ( Work->WKQTDE - Work->WKQTDEDORI )
               ELSE
                  SW7->W7_QTDE   := SW7->W7_QTDE    - ( Work->WKQTDEDORI - Work->WKQTDE )
                  SW7->W7_SALDO_Q:= SW7->W7_SALDO_Q - ( Work->WKQTDEDORI - Work->WKQTDE )
               ENDIF
               IF SW7->(FIELDPOS('W7_LOCAL')) # 0
                  SW7->W7_LOCAL :=   Work->WKLOCAL
               ENDIF           

               IF SW7->(FIELDPOS("W7_TES")) > 0   // TRP-10/01/08
                  SW7->W7_TES := Work->WKTES
               ENDIF
               SW7->(MsUnlock())

               IF PosOrd2_IT_Guias(M->W6_HAWB,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I ,;
                                    Work->WKFABR,Work->WKFORN,Work->WKREG,Work->WKPGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ")) //RJB 31/03/2004
                  SW5->(RecLock("SW5",.F.))
                  IF Work->WKQTDE > Work->WKQTDEDORI
                     SW5->W5_QTDE:= SW5->W5_QTDE+(Work->WKQTDE-Work->WKQTDEDORI)
                  ELSE
                     SW5->W5_QTDE:= SW5->W5_QTDE-(Work->WKQTDEDORI-Work->WKQTDE)
                  ENDIF
                  SW5->(MSUnlock())
               ENDIF

               DI400IdAtuSld("3")

            ENDIF

            SW7->(DBGOTO(Work->WKRECNO_ID))
            SW7->(RecLock("SW7",.F.))
            SW7->W7_PRECO := Work->WKPRECO
            SW7->W7_PESO  := Work->WKPESO_L
            SW7->W7_NCM   := Work->WKTEC
            SW7->W7_EX_NCM:= Work->WKEX_NCM
            SW7->W7_EX_NBM:= Work->WKEX_NBM
            IF SW7->(FIELDPOS('W7_LOCAL')) # 0
               SW7->W7_LOCAL := Work->WKLOCAL
            ENDIF
            IF SW7->(FIELDPOS("W7_TES")) > 0   // TRP-10/01/08
               SW7->W7_TES := Work->WKTES
            ENDIF
            IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_ALTERA_SW7"),)

            SW7->(MSUnlock())
            IF PosOrd2_IT_Guias(M->W6_HAWB,Work->WKCC,Work->WKSI_NUM,Work->WKCOD_I ,;
                                Work->WKFABR,Work->WKFORN,Work->WKREG,Work->WKPGI_NUM,Work->WKPO_NUM,Work->WKPOSICAO, EICRetLoja("Work", "W7_FABLOJ"), EICRetLoja("Work", "W7_FORLOJ")) //RJB 31/03/2004
               SW5->(RecLock("SW5",.F.))
               SW5->W5_PRECO:=Work->WKPRECO
               SW5->(MSUnlock())
            ENDIF

         ENDIF
      ENDIF

      IF EMPTY(cPO_NUM)
         cPO_NUM := Work->WKPO_NUM
      ELSE
         IF cPO_NUM # Work->WKPO_NUM
            DI400AtuOco(cPO_NUM)
            cPO_NUM := Work->WKPO_NUM
         ENDIF
      ENDIF

      Work->(DBSKIP())
   ENDDO

   SW4->(DBSETORDER(1))
   FOR P := 1 TO LEN(aPli)
      IncProc(STR0289+aPLI[P]) //"Lendo PLI: "
      IF SW4->(DBSEEK(xFilial()+aPLI[P]))
         SW4->(MSUNLOCK())
      ENDIF
   NEXT

   IF !EMPTY(cPO_NUM)
      DI400AtuOco(cPO_NUM)
   ENDIF

   IncProc(STR0290+cDesc) //"Atualizando Dados do "

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_ANTES_SW6"),)
   lDeletaSWD:=.F.
   SW7->(dbSetOrder(1))
   IF !SW7->(dbSeek(xFilial()+M->W6_HAWB))
      Work_SW8->(AvZap())//Para deletar as Invoices
      DI600GrvInvoice()  // AWR 27/07/04 - Passado para cima para Integridade Referencial.
      DI600EIGrava('ESTORNO',M->W6_HAWB,{})
      SW6->(RecLock("SW6",.F.))
      SW6->(dbDelete())
      SW6->(MsUnlock())
      lDeletaSWD:=.T.
      aDespDa:={}
   ELSE
      DI600GrvSW6("1")
      DI600EIGrava('GRAVACAO',SW6->W6_HAWB,{})
   ENDIF

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_DEPOIS_SW6"),)

   DI600GrvInvoice()

   // REGIANE 14/09/2007 - PROBLEMAS AO GRAVAR EMBARQUE SEM INVOICE
   IF SW6->(FIELDPOS("W6_STATUS")) # 0 //AWR - 06/09/2007 - Tem que gravar status aqui porque ele testa a taxa da invoice do banco
      SW6->(dbSetOrder(1))
      IF SW6->(DBSEEK(xFilial("SW6")+M->W6_HAWB))      
         SW6->(MSUNLOCK())
         DI156COND()
      ENDIF
   ENDIF

   If MOpcao == FECHTO_NACIONALIZACAO 
      If SWD->(DBSEEK(xFilial("SWD")+M->W6_HAWB))      
         Do While ! SWD->(EOF()) .AND. SWD->WD_HAWB = M->W6_HAWB .AND. xFilial("SWD") = SWD->WD_FILIAL
            IF lDeletaSWD
               SWD->(RECLOCK('SWD',.F.))
               SWD->(DBDELETE())
               SWD->(MSUNLOCK())
               SWD->(DBSKIP())
               LOOP
            ENDIF
            If SWD->WD_DA $ cSim 
               nDespDa:=ASCAN(aDespDa, {|x| x[1] = SWD->WD_DESPESA} )
               SWD->(RECLOCK('SWD',.F.))
               If nDespDa # 0                  
                  SWD->WD_VALOR_R    := aDespDa[nDespDa,2]
                  aDespDa[nDespDa,2] := 0                  
               Else
                  SWD->(DBDELETE())
               EndIf
               SWD->(MSUNLOCK())
            EndIf
            SWD->(DBSKIP())
         EndDo
      EndIf
      For iDA:=1 to LEN(aDespDa)
          If aDespDa[iDA,2] # 0  
             SWD->(DBGOTO(aDespDa[iDA,3]))
             FOR i := 1 TO SWD->(FCount())
                 SWD->( M->&(FIELDNAME(i)) := FieldGet(i) )
             NEXT
             SWD->(RecLock("SWD",.T.))
             For _nX := 1 To SWD->(fCount())
                 _cCampo    := "M->"+SWD->(Field(_nX))
                 _xConteudo := &_cCampo
                 SWD->(FieldPut(_nX, _xConteudo))
             Next
             SWD->WD_FILIAL  := xFilial("SWD")
             SWD->WD_HAWB    := M->W6_HAWB
             SWD->WD_VALOR_R := aDespDa[iDA,2]
             SWD->WD_DA      := '1'
             SWD->WD_BASEADI := "2"
             SWD->(MSUNLOCK())
          EndIf
      Next
   EndIf

   IF SW6->(FIELDPOS("W6_STATUS")) # 0 //AWR - 06/09/2007 - Tem que gravar status aqui porque ele testa a taxa da invoice do banco
      SW6->(MSUNLOCK())
      DI156COND()
   ENDIF

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_FINAL"),)

   EvalTrigger()

IncProc(STR0291) //"Fim do Processamento"

Return .T.
*--------------------------------------------------------------------------------------*
FUNCTION DI600GrvSW6(cAtz_Ocor)//Antiga Di400GrvDi000(PAtz_Ocor) do EIC.PRW
*--------------------------------------------------------------------------------------*
LOCAL cPo_Sal,nFobTotal:=0, lVazioDI:=Empty(SW6->W6_DI_NUM)
LOCAL cFilSW9:=xFilial('SW9')
PRIVATE lGrava:=.F.

IF cAtz_Ocor = "2"
   DBSELECTAREA("Work")
   ProcRegua(Easyreccount("Work"))
   Work->(DBSETORDER(2))
   DBGOTOP()
   DO WHILE !EOF()
      IncProc(STR0292) //"Gravando Ocorrencias..."
      cPo_Sal := WKPO_NUM
      DO WHILE .NOT. EOF() .AND. WKPO_NUM=cPo_Sal
         SKIP
      ENDDO
      DI400AtuOco(cPo_Sal)
   ENDDO
ENDIF

Procregua(2)
IncProc(STR0293) //"Gravando Capa..."
//gravacao automatica
If MOpcao = FECHTO_NACIONALIZACAO
   M->W6_NACIONA:='1'    
   M->W6_TIPOFEC:='DIN'      
ElseIf (Val(M->W6_TIPODES) >= 2 .And. Val(M->W6_TIPODES) <= 4) 
   M->W6_NACIONA:='2'
   M->W6_TIPOFEC:='DA'
Else
   M->W6_NACIONA:='2' 
   M->W6_TIPOFEC:='DI'   
EndIf

E_Grava("SW6",(!lExiste))
lExiste:=.T.//Para nao duplicar o Processo caso a Tela da Capa tenha algum campo nao-validado
// gravacao de campo memo
IF MOpcao = FECHTO_DESEMBARACO .OR. MOpcao = FECHTO_NACIONALIZACAO
   IF !EMPTY(SW6->W6_OBS) .OR. !EMPTY(M->W6_VM_OBS)
      MSMM(If(lExiste,SW6->W6_OBS,),AVSX3("W6_VM_OBS" ,3),,M->W6_VM_OBS ,1,,,"SW6","W6_OBS")
   ENDIF
ENDIF
IF !EMPTY(SW6->W6_COMPLEM) .OR. !EMPTY(M->W6_VM_COMP)
   MSMM(If(lExiste,SW6->W6_COMPLEM,),AVSX3("W6_VM_COMP",3),,M->W6_VM_COMP,1,,,"SW6","W6_COMPLEM")
ENDIF

IF cAtz_Ocor = "2" .AND. SW6->(FIELDPOS("W6_STATUS")) # 0 //.AND. SIX->(DBSEEK("SF16")) .AND. FINDFUNCTION("DI156COND")
   SW6->(MSUNLOCK())
   DI156COND()
ENDIF
IncProc(STR0294) //"Gravando Despesas..."
SF1->(DBSETORDER(5))
IF !SF1->(DBSEEK(xFilial()+SW6->W6_HAWB)) .AND. (MOpcao = FECHTO_DESEMBARACO .OR. MOpcao == FECHTO_NACIONALIZACAO )

   cCampoDT_VAR:=ALLTRIM(EasyGParam("MV_DT_VAR"))
   dDataDT_VAR :=dDataBranca
   cComtrole   :=ALLTRIM(GETNEWPAR("MV_CAMBAUT","NNN"))

   IF !EMPTY(cCampoDT_VAR)
      dDataDT_VAR := SW6->(FIELDGET(FIELDPOS(ALLTRIM(cCampoDT_VAR))))
   ENDIF

//*****************************  FOB  *****************************
   lGrava:=SUBSTR(cComtrole,1,1) $ cSim
   nDiferenca := 0
   nFobTotal  := 0

   IF Work_SW9->(Easyreccount("Work_SW9")) # 0
      ProcRegua(Work_SW9->(Easyreccount("Work_SW9")))
   ELSE
      ProcRegua(SW9->(Easyreccount("SW9"))+1)
   ENDIF
   If lIntDraw
      ED4->(dbSetOrder(2))
      ED0->(dbSetOrder(2))
   EndIf
   SW8->(DBSETORDER(1))
   SW9->(DBSETORDER(3))
   IF Work_SW9->(Easyreccount("Work_SW9")) # 0

      Work_SW9->(DBGOTOP())
      DO WHILE !Work_SW9->(EOF())
         IF Work_SW9->WK_TPINV == 2  //EOS
            Work_SW9->(dbSkip())
         	LOOP
         ENDIF
         IncProc("Gravando Despesas...")
         /* nopado por RNLP OSSME-5253 - Função DI600AtuAC não utilizada - não encontrada em nenhum fonte do sistema
         If lIntDraw .and. lExistW8_AC .and. lVazioDI .and. !Empty(M->W6_DI_NUM) .and. cAtz_Ocor == "2"
            DI600AtuAC()        //Atualiza Ato Concessorio
         EndIf
         */
         IF EMPTY(Work_SW9->W9_TX_FOB)
            nFobTotal  := 0
            EXIT
         ENDIF           
         // EOB - 05/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF Work_SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU"
            lTiraSeg := .T.
         ENDIF
         nValorDT_VAR:=DI600Trans(DI600RetVal("TOT_INV", "WORK", .T., .T.))  // EOB - 03/06/08 - chamada da função DI500RetVal
         nFobTotal   +=nValorDT_VAR
         IF ! EMPTY(cCampoDT_VAR)
             nDiferenca  +=DI600Trans(DI600RetVal("TOT_INV", "WORK", .T.)*BuscaTaxa(Work_SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.))-nValorDT_VAR  // EOB - 03/06/08 - chamada da função DI500RetVal
         ENDIF
         Work_SW9->(DBSKIP())
      ENDDO
      nFobTotal:=nFobTotal-(M->W6_VLFREPP*M->W6_TX_FRET)
      // EOB - 05/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lTiraSeg 
      	 nFobTotal:=nFobTotal-(M->W6_VL_USSE*M->W6_TX_SEG)
      ENDIF
   ELSE

      SW9->(DBSETORDER(3))                           
      cFilSW9:=xFilial("SW9")
      SW9->(DBSEEK(xFilial()+M->W6_HAWB))
      DO WHILE SW9->(!EOF()) .AND. SW9->W9_HAWB   == M->W6_HAWB .AND.;
                                   SW9->W9_FILIAL == cFilSW9
         IncProc("Gravando Despesas...")
         IF EMPTY(SW9->W9_TX_FOB)
            nFobTotal  := 0
            EXIT
         ENDIF           
         // EOB - 05/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF SW9->W9_INCOTER $ "CIF,CIP,DAF,DES,DEQ,DDP,DDU"
            lTiraSeg := .T.
         ENDIF        
         nValorDT_VAR:=DI600Trans(DI600RetVal("TOT_INV", "TAB", .T., .T.))  // EOB - 03/06/08 - chamada da função DI500RetVal
         nFobTotal   +=nValorDT_VAR
         IF ! EMPTY(cCampoDT_VAR)
            nDiferenca  +=DI600Trans(DI600RetVal("TOT_INV", "TAB", .T.)*BuscaTaxa(SW9->W9_MOE_FOB,dDataDT_VAR,.T.,.F.,.T.))-nValorDT_VAR    // EOB - 03/06/08 - chamada da função DI500RetVal
         ENDIF
         SW9->(DBSKIP())
      ENDDO
      nFobTotal:=nFobTotal-(M->W6_VLFREPP*M->W6_TX_FRET)
      // EOB - 05/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lTiraSeg 
      	 nFobTotal:=nFobTotal-(M->W6_VL_USSE*M->W6_TX_SEG)
   ENDIF
   ENDIF
   If lIntDraw
      ED4->(dbSetOrder(1))
      ED0->(dbSetOrder(1))
   EndIf
   IF nFobTotal # 0 
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"101",nFobTotal,nDiferenca,"701",dDataDT_VAR,"711")
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"101",0,0,"701",dDataDT_VAR,"711")
   ENDIF

//*****************************  FRETE  *****************************
   lGrava:=SUBSTR(cComtrole,2,1) $ cSim

   nFrete:=ValorFrete(SW6->W6_HAWB,,,2)
   IF nFrete # 0 .AND. SW6->W6_TX_FRET # 0
      nValorDT_VAR := DI600Trans(nFrete * SW6->W6_TX_FRET)
      nDiferenca := 0
      IF ! EMPTY(cCampoDT_VAR)
         nDiferenca := DI600Trans(nFrete * BuscaTaxa(SW6->W6_FREMOED,dDataDT_VAR,.T.,.F.)-nValorDT_VAR)
      ENDIF
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"102",nValorDT_VAR,nDiferenca,"702",dDataDT_VAR,"712")
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"102",0,0,"702",dDataDT_VAR,"712")
   ENDIF

//*****************************  SEGURO  *****************************
   lGrava:=SUBSTR(cComtrole,3,1) $ cSim

   IF SW6->W6_VL_USSE # 0 .AND. SW6->W6_TX_SEG # 0 .AND. SW6->W6_TX_US_D # 0
      nDiferenca   := 0
      nValorDT_VAR := DI600Trans(SW6->W6_VL_USSE * SW6->W6_TX_SEG)
      IF !EMPTY(cCampoDT_VAR)
         nDiferenca := DI600Trans(SW6->W6_VL_USSE * BuscaTaxa(SW6->W6_SEGMOED,dDataDT_VAR,.T.,.F.) - nValorDT_VAR)
      ENDIF
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"103",nValorDT_VAR,nDiferenca,"703",dDataDT_VAR,"713")
   ELSE
      DI400Grvddi(SW6->W6_HAWB,SW6->W6_DT,"103",0,0,"703",dDataDT_VAR,"713")
   ENDIF

ENDIF

DI600EIGrava('GRAVACAO',SW6->W6_HAWB,aAliasCapa)

DI600SWVGrv(.F.)// AWR - Lote

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"FIM_GRAVA_CAPA"),)

SF1->(DBSETORDER(1))

RETURN .T.
*----------------------------------------------------------------------------
FUNCTION DI600Estorno()//Antiga DI410Estorno()
*----------------------------------------------------------------------------
LOCAL lMarcou := .F., sInvoice, Ind, Wind,cMoedaFob,nWk
LOCAL aInv_CC := {}, a_CC := {},nTotalR:=0,sForn,nIndx
Local aDbf_Stru:={}, Work_SW8//MJB-SAP-1000
Local cFilSW8:=xFilial("SW8")
Local cFilSW9:=xFilial("SW9")
Local cFilSYS:=xFilial("SYS")
Private cCCAux:=""

TRB->(DBGOTOP())
TRB->(DBEVAL({||IF(WKFLAG.OR.WK_OK==cMarca,lMarcou:=.T.,)},,{||!lMarcou}))
TRB->(DBGOTOP())

IF !lMarcou
   Help(" ",1,"E_SEMMARCA")//NENHUM ITEM FOI SELECIONADO PARA O ESTORNO
   Return .F.
ENDIF

lSair:=.F.
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"EXEC_ESTORNO_A"),)
If lSair
   RETURN .F.
EndIf

IF !MsgYesNo(STR0178,STR0141) //"Confirma o Estorno ? "###"Estorno de Processo"
   Return .F.
ENDIF
   
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"EXEC_ESTORNO_B"),)

IF lFinanceiro 
   axFlDelWork:={}
   TP251CriaWork()
   axFl2DelWork:={}
   TP252CriaWork()
ENDIF

Begin Transaction   

EICFI400("ANT_GRV_DI","E")

Processa({|| DI600SW7Del()},STR0180) //"Estorno em andamento..."

EICFI400("POS_GRV_DI","E")

SYS->(DbSetOrder(1))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_MOEDA+YS_INVOICE+YS_CC
SYS->(DbSeek( cFilSYS+"IH"+M->W6_HAWB ) )
DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
   SYS->(RecLock("SYS",.F.,.T.))
   SYS->(DBDELETE())
   SYS->(MSUnlock())
   SYS->(DBSKIP())
End

SYS->( DbSeek( cFilSYS+"II"+ M->W6_HAWB ) )
DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
   SYS->(RecLock("SYS",.F.,.T.))
   SYS->(DBDELETE())
   SYS->(MSUnlock())
   SYS->(DBSKIP())
End

// So entra se for estorno parcial.
SW9->(DbSetOrder(1))
SW8->(DbSetOrder(1))
IF SW8->(DbSeek(cFilSW8+M->W6_HAWB))

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"EXEC_ESTORNO_E"),)

   DO While !SW8->(EOF()) .AND. SW8->W8_FILIAL==cFilSW8 .AND.SW8->W8_HAWB  ==M->W6_HAWB

      sInvoice := SW8->W8_INVOICE
      sForn    := SW8->W8_FORN
      If EICLoja()
      /*cLoja*/cForLoj     := SW8->W8_FORLOJ      //NCF - 22/03/2011
      Else
      /*cLoja*/cForLoj     := ""                  //NCF - 22/03/2011
      EndIf
      aInv_CC  := {}
      
      SW9->(DbSeek(cFilSW9+sInvoice+sForn))      
      nTaxaFob:=1
      cMoedaFob:=SW9->W9_MOE_FOB   
      
      IF EMPTY(SW9->W9_TX_FOB)
         nTaxaFob:=BuscaTaxa(cMoedaFob,dDataBase,.T.,.F.,.T.)
      ELSE
         nTaxaFob:=SW9->W9_TX_FOB
      ENDIF

      DO While !SW8->(EOF()) .AND. SW8->W8_FILIAL  == cFilSW8  .AND.;
                                   SW8->W8_INVOICE == sInvoice .AND.;
                                   SW8->W8_FORN    == sForn .And.;
                                   (!EICLoja() .Or. SW8->W8_FORLOJ == cForLoj)//FDR - 13/09/12 - Tratamento de loja

         cCCAux:=SW8->W8_CC  

         IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"EXEC_ESTORNO_C"),)

         Ind:= ASCAN(aInv_CC,{|Tab| Tab[1] + Tab[2] == SW8->W8_INVOICE + cCCAux} )
         IF Ind == 0
            AADD( aInv_CC,{ SW8->W8_INVOICE , cCCAux, DI600Trans(SW8->W8_QTDE * SW8->W8_PRECO) } )
         ELSE
            aInv_CC[Ind,3]+= DI600Trans(SW8->W8_QTDE * SW8->W8_PRECO)
         ENDIF


         Ind:= ASCAN(a_CC,{|Tab|Tab[1]+Tab[2]+Tab[3] == cCCAux+SW8->W8_FORN+cMoedaFob.And. (!EICLoja() .Or. Tab[5] == cForLoj)} )//FDR - 13/09/12 - Tratamento de loja
         IF Ind == 0
            AADD(a_CC,{cCCAux,SW8->W8_FORN,cMoedaFob,DI600Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob, EICRetLoja("Work_SW8", "W8_FORLOJ") } )
         ELSE
            a_CC[Ind,4]+=DI600Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob
         ENDIF
         
         nTotalR+=DI600Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob

         IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"EXEC_ESTORNO_D"),)

         SW8->( DBSKIP() )
      ENDDO

      FOR Wind = 1 TO LEN(aInv_CC)
          SYS->(RecLock("SYS",.T.))
          SYS->YS_FILIAL  := cFilSYS
          SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
          SYS->YS_TIPO    := "I"      //Invoice 
          SYS->YS_HAWB    := M->W6_HAWB
          SYS->YS_FORN    := SW8->W8_FORN
          //FDR - 13/09/12 - Tratamento de loja
          If EICLoja()
             SYS->YS_FORLOJ := SW8->W8_FORLOJ
          EndIf
          SYS->YS_MOEDA   := SW9->W9_MOE_FOB
          SYS->YS_INVOICE := aInv_CC[Wind,1]
          SYS->YS_CC      := aInv_CC[Wind,2]
          SYS->YS_PERC    := aInv_CC[Wind,3] / SW9->W9_FOB_TOT
          SYS->(MSUnlock())
      NEXT

   ENDDO

   FOR Wind = 1 TO LEN(a_CC)   
       SYS->(RecLock("SYS",.T.))
       SYS->YS_FILIAL  := cFilSYS
       SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
       SYS->YS_TIPO    := "H"
       SYS->YS_HAWB    := M->W6_HAWB
       SYS->YS_CC      := a_CC[Wind,1]
       SYS->YS_FORN    := a_CC[Wind,2]
       //FDR - 13/09/12 - Tratamento de loja
       If EICLoja()
          SYS->YS_FORLOJ := a_CC[Wind,5]
       EndIf
       SYS->YS_MOEDA   := a_CC[Wind,3]
       SYS->YS_PERC    := a_CC[Wind,4] / nTotalR
       SYS->(MSUnlock())
   NEXT

ENDIF

End Transaction

***** DELETAR ARQUIVO DA FUNCAO AV POS_DI(), QDO TEM CONTROLE DE TRANSACAO
   IF lFinanceiro 
      If Select("WorkTP") # 0
         IF TYPE("axFl2DelWork") = "A" .AND. LEN(axFl2DelWork) > 0
            WorkTP->(E_EraseArq(axFl2DelWork[1]))
            FOR nWk:=2 TO LEN(axFl2DelWork)
            //MFR OSSME-1974 26/12/2018
                FERASE(axFl2DelWork[nWk]+TeOrdBagExt())
            NEXT
         ENDIF
      ENDIF
   ENDIF   
*******************

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"EXEC_ESTORNO_F"),)

DbSelectArea("SW6")
TRB->(DBGOTOP())

Return .T.
*----------------------------------------------------------------------------*
FUNCTION DI600GrvInvoice()//Antiga Di400_Gr_Inv
*----------------------------------------------------------------------------*
LOCAL cFilSYS:=xFilial("SYS"), nPosTx, nQtdAux,nTotalR:=0
LOCAL cFilSW7:=xFilial("SW7"), nOrdSW7:=SW7->(IndexOrd())
LOCAL cFilSW8:=xFilial("SW8"), Wind, nDel
LOCAL cFilSW9:=xFilial("SW9")
LOCAL cFilEZZ:=xFilial("EZZ")
LOCAL nTotSW7_R:=nTotSW8_R:=nCont  :=nTotPeso:=nTotSW9_R:=nVLMLEMN:=0,aMoeda:={}
LOCAL nDespesa :=nTotGerRS:=nInland:=nPacking:= nDescont:=nOutDesp:=  nFrete:=0
LOCAL nSeguro := 0  // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
LOCAL cMoedaFob,nTaxaFob
Local lVlDIMoe := EasyGParam("MV_VLDIMOE",,.T.) // AST - 26/11/08 -  Verifica se os campos serão gravados em moeda local ou moeda da DI
Private aInv_CC:={}, a_CC:={}, cForn, cInvoice, cCCAux:=""

SW9->(DBSETORDER(3))
SW9->(DBSEEK(xFilial()+M->W6_HAWB))
ProcRegua(10)

//AWR 30/07/03 - Passado para baixo para Integridade Referencial.
//DO WHILE SW9->(!EOF()) .AND. SW9->W9_HAWB   == M->W6_HAWB .AND.;
//                           SW9->W9_FILIAL == cFilSW9
// IF nCont > 10 
//    ProcRegua(10) ; nCont:=0
// ENDIF                                      
// nCont++
// IncProc(STR0438+SW9->W9_INVOICE)
// IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DELETA_SW9"),)
// SW9->(RecLock("SW9",.F.,.T.))
// SW9->(DBDELETE())
// SW9->(MSUnlock())
// SW9->(DBSKIP())
//ENDDO

//EOS - deleta as invoices especiais
IF lExistEZZ
   EZZ->(DBSETORDER(1))
   EZZ->(DBSEEK(xFilial()+M->W6_HAWB))
   ProcRegua(10)
   DO WHILE EZZ->(!EOF()) .AND. EZZ->EZZ_HAWB   == M->W6_HAWB .AND.;
                             EZZ->EZZ_FILIAL == cFilEZZ
      IF nCont > 10 
         ProcRegua(10) ; nCont:=0
      ENDIF                                      
      nCont++
      IncProc(STR0438+EZZ->EZZ_INVOIC)
                                                         
      EZZ->(RecLock("EZZ",.F.,.T.))
      EZZ->(DBDELETE())
      EZZ->(MSUnlock())
      EZZ->(DBSKIP())
   ENDDO
ENDIF
If lIntDraw
   ED4->(dbSetOrder(2))
EndIf
SW7->(dbSetOrder(4))
SW8->(DBSETORDER(1))
SW8->(DBSEEK(xFilial()+M->W6_HAWB))
DO WHILE SW8->(!EOF()) .AND. SW8->W8_HAWB   == M->W6_HAWB .AND.;
                             SW8->W8_FILIAL == cFilSW8
   IF nCont > 10 
      ProcRegua(10) ; nCont:=0
   ENDIF
   nCont++
   IncProc(STR0445+SW8->W8_COD_I)

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DELETA_SW8"),)

   If lIntDraw .and. lExistW8_AC .and. !Empty(SW8->W8_AC)
      ED4->(dbSeek(cFilED4+SW8->W8_AC+SW8->W8_SEQSIS))
      If ED0->ED0_AC <> ED4->ED4_AC .or. cFilED0 <> ED0->ED0_FILIAL
         ED0->(dbSetOrder(2))
         ED0->(dbSeek(cFilED0+ED4->ED4_AC))
      EndIf
      ED4->(RecLock("ED4",.F.))
      If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
         ED4->ED4_QT_DI  += SW8->W8_QT_AC
         If AvVldUn(ED4->ED4_UMNCM)
            SW7->(dbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
            ED4->ED4_SNCMDI += SW7->W7_PESO * SW8->W8_QTDE
         Else
            ED4->ED4_SNCMDI += AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,SW8->W8_COD_I,SW8->W8_QT_AC)
         EndIf
      EndIf
      ED4->ED4_VL_DI  += SW8->W8_VL_AC
      ED4->(msUnlock())
   EndIf

   SW8->(RecLock("SW8",.F.,.T.))
   SW8->(DBDELETE())
   SW8->(MSUnlock())
   SW8->(DBSKIP())
ENDDO

SW7->(dbSetOrder(nOrdSW7))
SW9->(DBSETORDER(1))

DO WHILE SW9->(!EOF()) .AND. SW9->W9_HAWB   == M->W6_HAWB .AND.; //AWR 30/07/03 - Passado para baixo para Integridade Referencial.
                             SW9->W9_FILIAL == cFilSW9
   IF nCont > 10 
      ProcRegua(10) ; nCont:=0
   ENDIF                                      
   nCont++
   IncProc(STR0438+SW9->W9_INVOICE)

   IF !Work_SW8->(DBSEEK(SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9", "W9_FORLOJ")))
      IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DELETA_SW9"),)
      SW9->(RecLock("SW9",.F.))
      SW9->(DBDELETE())      
      SW9->(MSUnlock())
   ENDIF
   SW9->(DBSKIP())
ENDDO
ProcRegua(LEN(aDeletados))

FOR nDel := 1 TO LEN(aDeletados)
    IF !EMPTY(aDeletados[nDel,2]) .AND. aDeletados[nDel,1] = "SW9"
        cAlias:=aDeletados[nDel,1]
        IncProc(STR0301+SW9->W9_INVOICE) //"Excluindo Registros do "
        SW9->(DBGOTO(aDeletados[nDel,2]))
        IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DELETA_SW9"),)
        SW9->(RECLOCK(cAlias,.F.))
        SW9->(DBDELETE())      
        SW9->(MSUNLOCK())
    ENDIF
NEXT

IncProc(STR0033) //"Atualizando Arquivo de Controle"

SYS->(DbSetOrder(1))
SYS->(DbSeek(cFilSYS+"IH"+M->W6_HAWB))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_MOEDA+YS_INVOICE+YS_CC
DO While !SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
   IncProc(STR0033+' '+SYS->YS_INVOICE)
   SYS->(RecLock("SYS",.F.,.T.))
   SYS->(DBDELETE())
   SYS->(MSUnlock())
   SYS->(DBSKIP())
ENDDO

SYS->(DbSeek(cFilSYS+"II"+M->W6_HAWB))//YS_FILIAL+YS_TPMODU+YS_TIPO+YS_HAWB+YS_FORN+YS_MOEDA+YS_INVOICE+YS_CC
DO While ! SYS->(EOF()) .AND. SYS->YS_FILIAL==cFilSYS .AND. SYS->YS_HAWB==M->W6_HAWB
   IncProc(STR0033+' '+SYS->YS_INVOICE)
   SYS->(RecLock("SYS",.F.,.T.))
   SYS->(DBDELETE())
   SYS->(MSUnlock())
   SYS->(DBSKIP())
End

Work_SW9->(DBSETORDER(1))
Work_SW8->(DBSETORDER(1))

ProcRegua(Work_SW8->(Easyreccount("Work_SW8")))
SW7->(DBSETORDER(4))

Work_SW8->(DBGOTOP())
DO WHILE !Work_SW8->(EOF())
   IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
   cInvoice  := Work_SW8->WKINVOICE
   cForn     := Work_SW8->WKFORN
   //FDR - 13/09/12 - Tratamento de loja
   If EICLoja()
      cLoja     := Work_SW8->W8_FORLOJ
   Else
      cLoja     := ""
   EndIf 
   aInv_CC   := {}

   IF !Work_SW9->(DBSEEK(cInvoice+cForn+IF(EICLOJA(),cLoja,"")))//FDR - 13/09/12 - Tratamento de loja
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF
   IF EMPTY(WORK_SW9->WK_RECNO)
      SW9->(RecLock("SW9",.T.))
   ELSE
      SW9->(DBGOTO(WORK_SW9->WK_RECNO))
      SW9->(RecLock("SW9",.F.))
   ENDIF
   AVREPLACE("Work_SW9","SW9")
   SW9->W9_HAWB   :=M->W6_HAWB
   SW9->W9_FILIAL :=xFilial("SW9")
   SW9->W9_NOM_FOR:=BuscaFabr_Forn(SW9->W9_FORN)
      
   //IF LEN(aMoeda) < 2 .OR. EMPTY(aMoeda)   
   //TRP-18/02/08- Gravação dos campos na moeda local independentemente da qtde de moedas e invoices na DI.
   IF(ASCAN(aMoeda,SW9->W9_MOE_FOB)=0,AADD(aMoeda,SW9->W9_MOE_FOB),)
   //AST - 26/11/08 - Gravação dos campos na moeda local ou moeda da DI (MV_VLDIMOE).
   If lVlDIMOE
      nInland  += SW9->W9_INLAND * SW9->W9_TX_FOB
      nPacking += SW9->W9_PACKING * SW9->W9_TX_FOB
      nDescont += SW9->W9_DESCONT * SW9->W9_TX_FOB
      nOutDesp += SW9->W9_OUTDESP * SW9->W9_TX_FOB
      nFrete   += IF(SW9->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP" .AND. SW9->W9_FREINC $ cNao,;
                 SW9->W9_FRETEIN,0) * SW9->W9_TX_FOB
      // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)                  
      IF lSegInc 
         nSeguro  += IF(/*SW9->W9_INCOTER $ "CIP,CIF,DAF,DES,DEQ,DDU,DDP" .AND.*/ SW9->W9_SEGINC $ cNao, SW9->W9_SEGURO,0) * SW9->W9_TX_FOB//JVR - 29/04/10 - Retirado tratamento de Incoterm
      ENDIF
   nVLMLEMN += SW9->W9_FOB_TOT * SW9->W9_TX_FOB
   //ENDIF
   Else
      nInland  += SW9->W9_INLAND
      nPacking += SW9->W9_PACKING
      nDescont += SW9->W9_DESCONT
      nOutDesp += SW9->W9_OUTDESP
      nFrete   += IF(/*SW9->W9_INCOTER $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP" .AND.*/ SW9->W9_FREINC $ cNao,;//JVR - 29/04/10 - Retirado tratamento de Incoterm
                     SW9->W9_FRETEIN,0)
      // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)                  
      IF lSegInc 
         nSeguro  += IF(/*SW9->W9_INCOTER $ "CIP,CIF,DAF,DES,DEQ,DDU,DDP" .AND. */SW9->W9_SEGINC $ cNao, SW9->W9_SEGURO,0)//JVR - 29/04/10 - Retirado tratamento de Incoterm
      ENDIF
      nVLMLEMN += SW9->W9_FOB_TOT * SW9->W9_TX_FOB  
   EndIf
   nTotSW9_R+=DI600Trans(SW9->W9_FOB_TOT*SW9->W9_TX_FOB)
   nTotSW8_R:=0
   IF SW6->(FIELDPOS("W6_FOB_GER")) # 0
      nDespesa := DI600RetVal("TOT_INV,SEM_FOB", "TAB", .T.) 
      nTotGerRS+=DI600Trans((nDespesa+SW9->W9_FOB_TOT)*SW9->W9_TX_FOB)
   ENDIF

   cMoedaFob:=WORK_SW9->W9_MOE_FOB    

   IF EMPTY(Work_SW9->W9_TX_FOB)
      nTaxaFob:=BuscaTaxa(cMoedaFob,dDataBase,.T.,.F.,.T.)
   ELSE
      nTaxaFob:=Work_SW9->W9_TX_FOB
   ENDIF
      
   DO WHILE !Work_SW8->(EOF()) .AND. Work_SW8->WKINVOICE == cInvoice .AND.;
                                     Work_SW8->WKFORN    == cForn .And.;
                                     (!EICLoja() .Or. Work_SW8->W8_FORLOJ == cLoja)//FDR - 13/09/12 - Tratamento de loja
      IncProc(STR0319+SW8->W8_COD_I)//"Gravando Item: "
      SW8->(RecLock("SW8",.T.))
      DI600GrvWkSW8(.T.)
      SW8->W8_FILIAL   :=  cFilSW8
      SW8->W8_HAWB     :=  M->W6_HAWB
      SW8->W8_PRECO_R  :=  DI600Trans(Work_SW8->WKPRECO * Work_SW8->WKQTDE * Work_SW9->W9_TX_FOB) 
      //FDR - 13/09/12 - Tratamento de loja
      IF EICLOJA()
         SW8->W8_FORLOJ:= WORK_SW8->W8_FORLOJ
         SW8->W8_FABLOJ:= WORK_SW8->W8_FABLOJ
      ENDIF
      SW8->W8_UNID     := TransQtde(0,.T.,,Work_SW8->WKCOD_I,Work_SW8->WKFABR,Work_SW8->WKFORN,Work_SW8->WKCC,Work_SW8->WKSI_NUM)
      nTotSW8_R +=SW8->W8_PRECO_R
      nTotSW7_R +=SW8->W8_PRECO_R
      nTotPeso  +=Work_SW8->WKPESOTOT
      
      If lIntDraw .and. lExistW8_AC
         If !Empty(Work_SW8->WKAC) .and. !Empty(M->W6_DI_NUM)
            If Work_SW8->WKAC <> ED4->ED4_AC .or. Work_SW8->WKSEQSIS <> ED4->ED4_SEQSIS .or.;
            ED4->ED4_FILIAL <> cFilED4
               ED4->(dbSeek(cFilED4+Work_SW8->WKAC+Work_SW8->WKSEQSIS))
            EndIf
            If ED0->ED0_AC <> ED4->ED4_AC .or. cFilED0 <> ED0->ED0_FILIAL
               ED0->(dbSetOrder(2))
               ED0->(dbSeek(cFilED0+ED4->ED4_AC))
            EndIf
            nQtdAux := TransQtde(Work_SW8->WKQTDE,,ED0->ED0_TIPOAC,Work_SW8->WKCOD_I,Work_SW8->WKFABR,Work_SW8->WKFORN,Work_SW8->WKCC,Work_SW8->WKSI_NUM,Work_SW8->WKPESO_L)
            ED4->(RecLock("ED4",.F.))
            If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
               ED4->ED4_QT_DI  -= nQtdAux
               If AvVldUn(ED4->ED4_UMNCM)
                  ED4->ED4_SNCMDI -= Work_SW8->WKPESO_L * Work_SW8->WKQTDE
               Else
                  ED4->ED4_SNCMDI -= AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,Work_SW8->WKCOD_I,nQtdAux)
               EndIf
               SW8->W8_QT_AC := nQtdAux
            EndIf
            ED4->ED4_VL_DI  -= (Work_SW8->WKPRECO * Work_SW8->WKQTDE * Work_SW9->W9_TX_FOB) / M->W6_TX_US_D
            ED4->(msUnlock())
            SW8->W8_VL_AC := (Work_SW8->WKPRECO * Work_SW8->WKQTDE * Work_SW9->W9_TX_FOB) / M->W6_TX_US_D
            AtuValidade()
         EndIf
      EndIf
      IF lAltDescricao
         MSMM(If(lExiste,SW8->W8_DESC_DI,),AVSX3("W8_DESC_VM",3),,Work_SW8->WKDESC_DI,1,,,"SW8","W8_DESC_DI")
      ENDIF
      
      cCCAux:=Work_SW8->WKCC

      IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_SW8_A"),)

      SW8->(MSUnlock())
      
      Ind:= ASCAN(aInv_CC,{|Tab|Tab[1]+Tab[4]+Tab[2]==Work_SW8->WKINVOICE+Work_SW8->WKFORN+cCCAux})
      IF Ind == 0
         AADD(aInv_CC,{Work_SW8->WKINVOICE,cCCAux,DI600Trans(Work_SW8->WKPRECO * Work_SW8->WKQTDE),Work_SW8->WKFORN,EICRetLoja("Work_SW8", "W8_FORLOJ")})
      ELSE
         aInv_CC[Ind,3]+= DI600Trans(Work_SW8->WKPRECO * Work_SW8->WKQTDE)
      ENDIF

      Ind:= ASCAN(a_CC,{|Tab|Tab[1]+Tab[2]+Tab[3] == cCCAux+Work_SW8->WKFORN+cMoedaFob .And. (!EICLoja() .Or. Tab[5] == Work_SW8->W8_FORLOJ)})//FDR - 13/09/12 - Tratamento de loja
      IF Ind == 0
         AADD(a_CC,{cCCAux,Work_SW8->WKFORN,cMoedaFob,DI600Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob, EICRetLoja("Work_SW8", "W8_FORLOJ") } )
      ELSE
         a_CC[Ind,4]+= DI600Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob
      ENDIF        

      nTotalR+=DI600Trans(SW8->W8_QTDE * SW8->W8_PRECO)*nTaxaFob

      Work_SW8->(DBSKIP())
   ENDDO

   If lIntDraw
      ED4->(dbSetOrder(1))
   EndIf

   IF (SW9->W9_FOB_TOT*SW9->W9_TX_FOB) # nTotSW8_R
      nTotSW9_R+= DI600Trans((SW9->W9_FOB_TOT*SW9->W9_TX_FOB)-nTotSW8_R)
   ENDIF

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_SW9_A"),)

   SW9->(MSUnlock())

// EOS - no EICFI400, chamada POS_GRV_DI, ele chama a rotina FI400MOVCONT c/ o 
// parametro GRV_CONTABIL que já contabiliza as invoices
// IF M->W6_TIPOFEC # "DIN"
//    FI400MOVCONT("INVOICE","I") // S.A.M. - para as contabilizaçoes da Invoice
// ENDIF

   FOR Wind = 1 TO LEN(aInv_CC)
       SYS->(RecLock("SYS",.T.))
       SYS->YS_FILIAL  := xFilial("SYS")
       SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
       SYS->YS_TIPO    := "I"       
       SYS->YS_HAWB    := M->W6_HAWB
       SYS->YS_INVOICE := aInv_CC[Wind,1]
       SYS->YS_MOEDA   := SW9->W9_MOE_FOB
       SYS->YS_CC      := aInv_CC[Wind,2]
       SYS->YS_FORN    := aInv_CC[Wind,4]
       //FDR - 13/09/12 - Tratamento de loja
       If EICLoja()
          SYS->YS_FORLOJ := aInv_CC[Wind,5]
       EndIf
       SYS->YS_PERC    := aInv_CC[Wind,3] / SW9->W9_FOB_TOT
       SYS->(MSUnlock())
   NEXT

ENDDO

// IF SW6->(DBSEEK(xFilial()+SW9->W9_HAWB)) // regiane - senao nao grava quando nao tem taxa 
   IF nTotSW7_R # nTotSW9_R
      nTotSW9_R+= DI600Trans(nTotSW7_R-nTotSW9_R)
   ENDIF
   SW6->(RECLOCK("SW6",.F.))
   IF SW6->(FIELDPOS("W6_FOB_GER")) # 0
      SW6->W6_FOB_GER:=nTotGerRS
   ENDIF
   SW6->W6_FOB_TOT:=nTotSW9_R
   SW6->W6_PESOL  :=nTotPeso    

   //IF LEN(aMoeda) < 2
   SW6->W6_INLAND  :=nInland
   SW6->W6_PACKING :=nPacking
   SW6->W6_FRETEIN :=nFrete
   SW6->W6_OUTDESP :=nOutDesp
   SW6->W6_DESCONT :=nDescont
   SW6->W6_VLMLEMN :=nVLMLEMN 
   // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)                  
   IF lSegInc
      SW6->W6_SEGINV :=nSeguro
   ENDIF    
   //ELSE
      //SW6->W6_INLAND  :=0
      //SW6->W6_PACKING :=0
      //SW6->W6_FRETEIN :=0
      //SW6->W6_OUTDESP :=0
      //SW6->W6_DESCONT :=0
      //SW6->W6_VLMLEMN :=0
   //ENDIF
   SW6->(MSUNLOCK())
// ENDIF

ProcRegua(LEN(a_CC)+1)
FOR Wind = 1 TO LEN(a_CC)
    IncProc(STR0034)//"Estornar"
    SYS->( RecLock("SYS",.T.))
    SYS->YS_FILIAL  := cFilSYS
    SYS->YS_TPMODU  := "I"      //Modulo I=Importacao E=Exportacao(Campo Chave)
    SYS->YS_TIPO    := "H"
    SYS->YS_HAWB    := M->W6_HAWB
    SYS->YS_CC      := a_CC[Wind,1]
    SYS->YS_FORN    := a_CC[Wind,2]
    //FDR - 13/09/12 - Tratamento de loja
    If EICLoja()
       SYS->YS_FORLOJ := a_CC[Wind,5]
    EndIf
    SYS->YS_MOEDA   := a_CC[Wind,3]
    SYS->YS_PERC    := a_CC[Wind,4] /nTotalR
    SYS->(MSUnlock())
NEXT
IF lExistEZZ
Work_SW9->(DBGOTOP())
DO WHILE !Work_SW9->(EOF())
   IF Work_SW9->WK_TPINV == 1 //EOS - despreza as invoices normais
      Work_SW9->(dbSkip())
      LOOP
   ENDIF
   EZZ->(RecLock("EZZ",.T.))
   EZZ->EZZ_FILIAL := xFilial("EZZ")
   EZZ->EZZ_HAWB   := M->W6_HAWB
   EZZ->EZZ_INVOIC := Work_SW9->W9_INVOICE
   EZZ->EZZ_DTEMIS := Work_SW9->W9_DT_EMIS
   EZZ->EZZ_FORN   := Work_SW9->W9_FORN
   EZZ->EZZ_MOEDA  := Work_SW9->W9_MOE_FOB 
   EZZ->EZZ_TX_FOB := Work_SW9->W9_TX_FOB
   EZZ->EZZ_CONDPA := Work_SW9->W9_COND_PA
   EZZ->EZZ_DIASPA := Work_SW9->W9_DIAS_PA
   EZZ->EZZ_FRETEI := Work_SW9->W9_FRETEIN  
   EZZ->EZZ_INLAND := Work_SW9->W9_INLAND
   EZZ->EZZ_PACKIN := Work_SW9->W9_PACKING
   EZZ->EZZ_OUTDES := Work_SW9->W9_OUTDESP
   EZZ->EZZ_DESCON := Work_SW9->W9_DESCONT
   EZZ->(MSUnlock())
  
// EOS - no EICFI400, chamada POS_GRV_DI, ele chama a rotina FI400MOVCONT c/ o 
// parametro GRV_CONTABIL que já contabiliza as invoices   
// IF M->W6_TIPOFEC # "DIN"
//    FI400MOVCONT("INVOICE2","I") // EOS para as contabilizaçoes da invoice sem itens
// ENDIF
   
   Work_SW9->(dbSkip())
ENDDO
ENDIF
IncProc(STR0034)//"Estornar"

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"FIM_DELETA_SW8"),)

RETURN .T.

*---------------------------------------------------------------*
Function DI600Despes(Alias,nReg,nOpc)
*---------------------------------------------------------------*
LOCAL aCoordenadas:={15,04,20,74,,.F.,  ,  ,  ,  ,21,04}
LOCAL nOldArea:=SELECT(), oDlg, oMark, i
Local aSemSX3 := { {"RECNO", "N",10, 0} }
Local bAddWork := {|| TRB->(dbAppend()), DI600D_Grava("TRB") }
Local cNomeTemp :=""
LOCAL cAlias:="SWD",oPanel1
PRIVATE lNaoAltera:=.T. //Para incluir uma Nova Despesa através do Botão F3
lSair:=.F.
If(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"DESPESA"),)
IF lSair
   RETURN .F.
EndIf                    

If !DI600PROG()
   Return .F.
EndIf

//PRIVATE cAlias:="SWD"
PRIVATE nOpcao
PRIVATE cPictValor:=X3Picture("WD_VALOR_R")
PRIVATE MSeguro, MImpostos, MAdiant, MOutras, MSaldos, MTot_Ger
PRIVATE aCpos
// *** Cria variaveis para E_CriaTrab ...
PRIVATE aCampos := Array(SWD->(FCount()))
PRIVATE aEnchoice := {"WD_HAWB","WD_DESPESA","WD_DESCDES","WD_DES_ADI",;
                      "WD_VALOR_R","WD_BASEADI","WD_DOCTO","WD_NF_COMP",;
                      "WD_SE_NFC","WD_VL_NFC","WD_DT_NFC","WD_PAGOPOR","WD_DA"}
PRIVATE lBaixaDesp:=.F.,lnoEnvFin:=.T., lAltForn:=.T. // Verifica se esta baixado a Despesa no financeiro
PRIVATE lCposNovosWD := ( SWD->(FieldPos("WD_SE_DOC"))  > 0 .AND. ;
                          SWD->(FieldPos("WD_TES"))     > 0 .AND. ;
                          SWD->(FieldPos("WD_MOEDA"))   > 0 .AND. ;
                          SWD->(FieldPos("WD_VALOR_M")) > 0 .AND. ;
                          SWD->(FieldPos("WD_TX_MOE"))  > 0 )
                          
IF lCposNovosWD
   AADD(aEnchoice, "WD_SE_DOC")
   AADD(aEnchoice, "WD_TES")
   AADD(aEnchoice, "WD_MOEDA")
   AADD(aEnchoice, "WD_VALOR_M")
   AADD(aEnchoice, "WD_TX_MOE") 
ENDIF

IF lFinanceiro
   AADD(aEnchoice,"WD_GERFIN")
   AADD(aEnchoice,"WD_DTENVF")
ENDIF

AADD(aEnchoice,"WD_FORN"  )
AADD(aEnchoice,"WD_LOJA"  )

IF SWD->(FIELDPOS("WD_FORNRAT")) # 0
   AADD(aEnchoice,"WD_FORNRAT")
ENDIF

PRIVATE aHeader := {}
PRIVATE aDeletados := {}

IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"MANUT_DESP"),)

If ! SW6->(RecLock("SW6",.F.))
//   Help(" ",1,"REGNLOCK")
   DbSelectArea(nOldArea)
   Return
Endif

cNomeTemp := E_CriaTrab(cAlias,aSemSX3)  // Criacao do arquivo de Trabalho
//MFR OSSME-1974 26/12/2018
IndRegua("TRB",cNomeTemp+TeOrdBagExt(),"WD_HAWB+WD_DESPESA")

DBSELECTAREA("SWD")
SWD->(DBSETORDER(1))

// *** Grava arquivo de Trabalho ...
SWD->(dbSeek(xFilial()+SW6->W6_HAWB))
SWD->(dbEval(bAddWork,,{|| SWD->WD_FILIAL == xFilial("SWD") .And. SWD->WD_HAWB == SW6->W6_HAWB}))
// ***

SYB->(dbSetOrder(1))

PRIVATE oSeguro, oOutras, oImpostos, oAdiant, oTot_Ger, oSaldos

aCpos:= { {{|| TRB->WD_DESPESA+" "+if(SYB->(dbSeek(xFilial()+TRB->WD_DESPESA)),SYB->YB_DESCR,"")},,AVSX3("WD_DESPESA",5)},; 
          {"WD_DES_ADI",,AVSX3("WD_DES_ADI",5)       },; //"Data"
          {"WD_VALOR_R",,AVSX3("WD_VALOR_R",5),cPictValor  },; //"Valor R$"
          {{|| If(TRB->WD_BASEADI$cSim,STR0002,STR0003)},,AVSX3("WD_BASEADI",5)},; //"Adianta/o ?"
          {"WD_DOCTO"  ,,AVSX3("WD_DOCTO"  ,5)}} //"Documento"

IF SWD->(FieldPos("WD_SE_DOC")) > 0
   AADD( aCpos, { "WD_SE_DOC",, AVSX3("WD_SE_DOC",5)}) // EOS - Serie do docto
ENDIF

AADD(aCpos, {"WD_FORN"   ,,AVSX3("WD_FORN"   ,5)}) //"Fornecedor" 
AADD(aCpos, {"WD_LOJA"   ,,AVSX3("WD_LOJA"   ,5)}) //"Loja" 
AADD(aCpos, {"WD_NF_COMP",,AVSX3("WD_NF_COMP",5)}) //"Nota Fiscal"
AADD(aCpos, {"WD_SE_NFC" ,,AVSX3("WD_SE_NFC" ,5)}) //"Serie"
If lFinanceiro
   AADD(aCpos, {"WD_DTENVF",,AVSX3("WD_DTENVF",5)       } ) //"Data envio Fianceiro" 
Endif
AADD(aCpos, { {|| ALLTRIM(AVCOMBO("WD_DA",IF(EMPTY(TRB->WD_DA),"2",TRB->WD_DA)))},,AVSX3("WD_DA",5) } )

IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"CAMPOS_WD"),)

EICFI400("ANT_TELA_DESP")

dbSelectArea("TRB")
dbGoTop()

While (.T.)
   nOpcao := 0

   oMainWnd:ReadClientCoords()
   SW2->(DBSETORDER(1))
   lAltDesp:=.t.
   IF MOpcao # FECHTO_NACIONALIZACAO .AND.;
      (Val(SW6->W6_TIPODES) >= 2 .And. Val(SW6->W6_TIPODES) <= 4) .AND.;
      SW2->(DBSEEK(xFilial("SW2")+"DA"+Trans(SW6->W6_DI_NUM,ALLTRIM(X3Picture("W6_DI_NUM"))))) .OR.;
      !EMPTY(SW6->W6_DT_ENCE)
      lAltDesp:=.f.
   EndIf
      
   If ! lAltDesp
      cTitJan:=STR0152+" - "+STR0004
   Else
      cTitJan:=STR0152
   EndIf
   
   DEFINE MSDIALOG oDlg TITLE cTitJan ; //"Manuten‡Æo"
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL  
   @ 00,00 MsPanel oPanel1 Prompt "111" Size 60,45 of oDlg
   DI600D_Tela(.T.,oPanel1)
   If lAltDesp
      @15,COLUNA_FINAL-85 BUTTON STR0031     SIZE 34,11 FONT oDlg:oFont ACTION (DI600DespManut(2),oMark:oBrowse:Refresh()) OF oDlg PIXEL //"Incluir"
      @27,COLUNA_FINAL-85 BUTTON STR0032     SIZE 34,11 FONT oDlg:oFont ACTION (DI600DespManut(3),oMark:oBrowse:Refresh()) OF oDlg PIXEL //"Alterar"
      @39,COLUNA_FINAL-85 BUTTON STR0153     SIZE 34,11 FONT oDlg:oFont ACTION (DI600DespManut(4),oMark:oBrowse:Refresh()) OF oDlg PIXEL //"Excluir"
      @15,COLUNA_FINAL-45 BUTTON "Relatorio" SIZE 39,11 FONT oDlg:oFont ACTION (DI600DespManut(5),oMark:oBrowse:Refresh()) OF oDlg PIXEL //"Relatorio"
      @27,COLUNA_FINAL-45 BUTTON "Gera Arq." SIZE 39,11 FONT oDlg:oFont ACTION (DI600DespManut(6),oMark:oBrowse:Refresh()) OF oDlg PIXEL
   EndIf
   oMark:= MSSELECT():New("TRB",,,aCpos,lInverte,cMarca,{55,4,(oDlg:nClientHeight-6)/2,COLUNA_FINAL})
   IF ! lAltDesp
      oMark:bAval := {|| .T. }
   Else
      oMark:bAval := {|| DI600DespManut(3),oMark:oBrowse:Refresh()}
   EndIf

   ACTIVATE MSDIALOG oDlg ON INIT (DI600EnchoiceBar(oDlg,;
                                  {{||nOpcao:= 1,oDlg:End()},"OK"},;
                                   {||nOpcao:= 0,oDlg:End()},.F.),; //CENTERED
                                   oPanel1:Align:=CONTROL_ALIGN_TOP,oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT, oMark:oBrowse:Refresh())  //TRP-06/11/2007
   lLoop:=.F.
   IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,If(nOpcao == 0, "CANCELA_DESPESA", "CONFIRMA_DESPESA")),)
   If lLoop
      Loop
   ENDIF

   If nOpcao # 0   // *** Clicou em Ok.
      //INICIO DA TRANSACAO

      Begin Transaction                  
      
         //AAF 24/06/08 - Paramêtro para geração de titulos de despesas no financeiro
         If EasyGParam("MV_EASYFDE",,.T.)
            EICFI400("ANT_GRV_DESP")
         EndIf

         aTabTitulos:={}
         For i:=1 To Len(aDeletados)
             SWD->(dbGoTo(aDeletados[i]))
             IF SWD->WD_DESPESA#'901' .AND. !EMPTY(SWD->WD_CTRFIN1) .AND.;
               ASCAN(aTabTitulos,SWD->WD_CTRFIN1+SWD->WD_FORN+SWD->WD_LOJA+IF(SWD->WD_VALOR_M<0,"NCP","NF")) = 0
                AADD(aTabTitulos,SWD->WD_CTRFIN1+SWD->WD_FORN+SWD->WD_LOJA+IF(SWD->WD_VALOR_M<0,"NCP","NF"))
             ENDIF
             EICFI400("ANT_DEL_DESP")
             SWD->(RecLock("SWD",.F.))
             SWD->(dbDelete())
             SWD->(MSUnlock())
         Next
         
         TRB->(dbGoTop())
         DO While TRB->(!Eof())
            IF TRB->RECNO == 0
               SWD->(RecLock("SWD",.T.)) // Append com lock
            ELSE
               SWD->(dbGoTo(TRB->RECNO))
               SWD->(RecLock("SWD",.F.))
            ENDIF
                        
            IF !EMPTY(SWD->WD_CTRFIN1) .AND. SWD->WD_DESPESA#'901' .AND.;
               ASCAN(aTabTitulos,SWD->WD_CTRFIN1+SWD->WD_FORN+SWD->WD_LOJA+IF(SWD->WD_VALOR_M<0,"NCP","NF")) # 0
               TRB->WD_CTRFIN1:=''
            ENDIF
            // Grava campos no SWD ...
            DI600D_Grava("SWD",.T.)
                                                     
            TRB->(dbSkip())
            IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"CONFIRMA"),)

         EndDo
         //AAF 24/06/08 - Paramêtro para geração de titulos de despesas no financeiro
         If EasyGParam("MV_EASYFDE",,.T.)
            EICFI400("POS_GRV_DESP")         
         EndIf
         EvalTrigger()

      End Transaction

   EndIf
   Exit
EndDo

TRB->(E_EraseArq(cNomeTemp))

DBSELECTAREA(nOldArea)

SW6->(MSUnlock())

Return Nil           

*--------------------------------*
Function DI600DespManut(nOpcao)
*--------------------------------*
PRIVATE dDat01:=CTOD(""),dDat02:=CTOD("")
   If nOpcao == 2 // Incluir
      DI600D_Edi(.T.)
   Elseif nOpcao == 3 // Alterar
	  lSair:=.F.
      IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"DESP_ALTERA1"),)
	  IF lSair
         Return
      ENDIF

      If TRB->WD_DA == "1" .AND. SW6->W6_TIPOFEC = "DIN"//AWR
         Help(" ",1,"AVG0000104")
         Return
      EndIf

      
      IF !EMPTY(TRB->WD_NF_COMP)

         SF1->(DBSETORDER(1))
         cTipoNF:=IF(cPaisLoc="BRA","2,3","5")
         IF SF1->(DBSEEK(xFILIAL()+TRB->WD_NF_COMP+TRB->WD_SE_NFC))
            DO WHILE !SF1->(EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1")  .AND.;
                                         SF1->F1_DOC    == TRB->WD_NF_COMP .AND.;
                                         SF1->F1_SERIE  == TRB->WD_SE_NFC               
               IF SF1->F1_HAWB == SW6->W6_HAWB .AND.;
                  SF1->F1_TIPO_NF $ cTipoNF
                  Help("", 1, "AVG0000257")//Despesa nao pode ser alterada, pois o processo possui NF(s) de Entrada.
                  RETURN .F.
               ENDIF
               SF1->(DBSKIP())   
            ENDDO   
         ENDIF
         DI600D_Edi(.F.)
      ELSE
         DI600D_Edi(.F.)
      ENDIF
   Elseif nOpcao == 4  // Excluir
	  lSair:=.F.
      IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"DESP_EXCLUI1"),)
	  IF lSair
         Return
      ENDIF

      If TRB->WD_DA == "1" .AND. SW6->W6_TIPOFEC = "DIN"//AWR
         Help(" ",1,"AVG0000104")
         Return .F.
      EndIf      

      IF !EMPTY(TRB->WD_NF_COMP)
         SF1->(DBSETORDER(1))
         cTipoNF:=IF(cPaisLoc="BRA","2,3","5")
         IF SF1->(DBSEEK(xFILIAL("SF1")+TRB->WD_NF_COMP+TRB->WD_SE_NFC))
            DO WHILE !SF1->(EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1")  .AND.;
                                         SF1->F1_DOC    == TRB->WD_NF_COMP .AND.;
                                         SF1->F1_SERIE  == TRB->WD_SE_NFC
               IF SF1->F1_HAWB == SW6->W6_HAWB .AND.;
                  SF1->F1_TIPO_NF $ cTipoNF
                  Help("", 1, "AVG0000258")//Despesa nao pode ser excluida, pois o processo possui NF(s) de Entrada.
                  Return .F.
               ENDIF
               SF1->(DBSKIP())
             ENDDO      
         ENDIF
      ELSE
         DI600D_Del()
      ENDIF
   Elseif nOpcao == 5  // Relatorio   
     
      DI600RelDesp(.F.)    

   Elseif nOpcao == 6  // Gerar Arquivo
     
      DI600RelDesp(.T.)    
   ENDIF
Return Nil
*-----------------------------------------*
FUNCTION DI600RelDesp(lGera)
*-----------------------------------------*
nOpca:= 0   
DEFINE MSDIALOG oDlg TITLE STR0491 From 14,03 To 20,46 OF oMainWnd  //"Parametro para Relatorio"

   oPnl:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 116, 171)
   oPnl:Align:= CONTROL_ALIGN_ALLCLIENT   

   @05.2,15.3 SAY   STR0492 SIZE    40,8 OF oPnl PIXEL //"Data Inicial : "
   @05.2,55.3 MSGET dDat01  Picture "@D" SIZE 40,8 OF oPnl PIXEL
   @25.2,15.3 SAY   STR0493 SIZE    40,8 OF oPnl PIXEL //"Data Final  : "
   @25.2,55.3 MSGET dDat02  Picture "@D" SIZE 40,8 OF oPnl PIXEL

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, { || IF(E_PERIODO_OK(@dDat01,@dDat02),(nOpcA:=1,oDlg:End()),) },;
                                                    { || nOpcA:=0, oDlg:End() },,,,,,,.F.) CENTERED 

If nOpcA =0 
   RETURN
Endif                                     
aDbf_Str1 :={ {"WKIMP"    ,"C",LEN(SW6->W6_IMPORT) ,0} ,;
              {"WKHAWB"   ,"C",LEN(SWD->WD_HAWB)   ,0} ,;
              {"WKDESPCD" ,"C",LEN(SWD->WD_DESPESA),0} ,;
              {"WKDESPDE" ,"C",LEN(SYB->YB_DESCR)  ,0} ,;
              {"WKVALOR"  ,"N",AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)},;
              {"WKDATA"   ,"D",8 ,0} }

If(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"WOR_ESTR1"),)

FileWork:= E_CriaTrab(,aDBF_Str1,"Work_Rel")

IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF   
//MFR OSSME-1974 26/12/2018
IndRegua("Work_Rel",FileWork+TeOrdBagExt(),"WKDESPCD") 
TRB->(DBGOTOP())      
      
DO WHILE !TRB->(EOF())
   If TRB->WD_DES_ADI > dDAT02 .OR.;
      TRB->WD_DES_ADI < dDat01 .OR.;
      TRB->WD_DESPESA $ '101,102,103'
      TRB->(DBSKIP())           
      LOOP
   Endif 
   Work_Rel->(DBAPPEND())
   Work_Rel->WKIMP   := SW6->W6_IMPORT
   Work_Rel->WKHAWB  := TRB->WD_HAWB
   Work_Rel->WKDESPCD:= TRB->WD_DESPESA
   Work_Rel->WKDESPDE:= IIF(SYB->(DBSEEK(xFilial("SYB")+TRB->WD_DESPESA)),SYB->YB_DESCR,)
   Work_Rel->WKVALOR := TRB->WD_VALOR_R
   Work_Rel->WKDATA  := TRB->WD_DES_ADI
   If(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"WOR_GRAV1"),)
         
   TRB->(DBSKIP())         
ENDDO                                                    

IF Work_Rel->(Easyreccount("Work_Rel")) = 0
   Work_Rel->(E_ERASEArq(FileWork))
   DBSELECTAREA("SWD")
   TRB->(DBGOTOP())
   Help("",1,"AVG0000718")
// MSGINFO(0494,0057) //"Nao existem registros para serem listados."
   RETURN .T.
ENDIF

IF lGera
   TR350ARQUIVO("Work_Rel")    
   Work_Rel->(E_ERASEArq(FileWork))
   DBSELECTAREA('SWD')
   TRB->(DBGOTOP())
   RETURN .T.
Endif                                     

Work_Rel->(DbGoTop())
PRIVATE aDados:={"Work_Rel",;
                STR0495,;  //"Relatorio "
                STR0496,;  //"Cambios"
                "",;
                "M",;
                80,;
                STR0497+Work_Rel->WKIMP +STR0498+WKHAWB,; //"Importador : "###"    Processso  : "
                "",;
                STR0499,; //"Relatorio de Despesas"
                { "Zebrado", 1,STR0500, 1, 2, 1, "",1 },; //"Importacao"
                "EICDI600" ,;
                { {||.T.} , {||.T.} }  }

TB_Campos:={}
AADD(TB_Campos,{"WKDESPCD" ,,AVSX3("WD_DESPESA",5)}) //"Despesa"
AADD(TB_Campos,{"WKDESPDE" ,,AVSX3("YB_DESCR"  ,5)}) //"Descricao"
AADD(TB_Campos,{"WKVALOR"  ,,AVSX3("WD_VALOR_R",5),AVSX3("WD_VALOR_R",6)})
AADD(TB_Campos,{"WKDATA"   ,,AVSX3("WD_DES_ADI",5)}) //"Data"

IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"INCACAMPOS"),)

TB_Campos:= E_CriarCampos(TB_Campos)

Work_Rel->(DbGoTop())
E_Report(aDados,TB_Campos)

Work_Rel->(E_ERASEArq(FileWork))
DBSELECTAREA('SWD')
TRB->(DBGOTOP())

Return .T.
//Paramentros: cAlias  ->  <"SWD" | "TRB>
*--------------------------------------------------------------
FUNCTION DI600D_Grava(cAlias,cTestaMoe)
*--------------------------------------------------------------
Local i, xValue

For i:=1 To SWD->(FCount())
   If "FILIAL" $ (cAlias)->(Field(i))
      Loop
   Endif

   If AllTrim((cAlias)->(Field(i))) == "WD_HAWB"
      (cAlias)->(FieldPut(i,SW6->W6_HAWB))
      Loop
   Endif

   If AllTrim((cAlias)->(Field(i))) == "WD_VALOR_M"
      (cAlias)->(FieldPut(i,TRB->WD_VALOR_M))
      Loop
   Endif

   If AllTrim((cAlias)->(Field(i))) == "WD_VALOR_R"
      If cTestaMoe              
         If(!Empty(cMoeda))
           (cAlias)->(FieldPut(i,(cMoeda*TRB->WD_VALOR_M)))
         Else
           (cAlias)->(FieldPut(i,(TRB->WD_VALOR_M)))
         Endif  
         Loop
      Endif
   Endif

   IF cAlias == "SWD"
      IF TRB->(FieldPos(SWD->(Field(i)))) # 0
         xValue := TRB->(FieldGet( FieldPos(SWD->(Field(i)))))
         SWD->(FieldPut(i,xValue))
      ENDIF
   ELSE// Alias TRB
      IF (nPosNew:= TRB->(FieldPos(SWD->(Field(i))))) # 0
         xValue := SWD->(FieldGet(i))
         TRB->(FieldPut(nPosNew,xValue))
      ENDIF
   ENDIF

Next i

If cAlias == "SWD"
   SWD->WD_FILIAL := xFilial("SWD")
   TRB->RECNO := SWD->(RECNO())  // S.A.M 11/07/2001
Else
   // Alias TRB
   TRB->RECNO := SWD->(RECNO())
Endif

Return Nil
*----------------------------------------------------------------------------
FUNCTION DI600D_Tela(lInit,oDlg)
*----------------------------------------------------------------------------
Local MRecno := TRB->(RECNO()), nL2, nL3, nC2, nC3, nC4
PRIVATE nL1, nC1 // RAD porque eh usado no ponto de entrada 14/06/2006 

MSeguro:=MImpostos:=MAdiant:=MOutras:=MSaldos:=MTot_Ger:=0

nL1:=1.4 ; nL2:=2.2 ; nL3:=3.0 ; nC1:=0.8 ; nC2:=15 ; nC3:=05 ; nC4:=20

TRB->(dbGoTop())

DO WHILE ! TRB->(EOF())
   DO CASE
      CASE SUBST(TRB->WD_DESPESA,1,1) == '1'
           IF TRB->WD_DESPESA $ '102,103'
              MSeguro += TRB->WD_VALOR_R 
           ENDIF
           MTot_Ger  += TRB->WD_VALOR_R
      CASE SUBST(TRB->WD_DESPESA,1,1) == '2'
           MImpostos += TRB->WD_VALOR_R
           MTot_Ger  += TRB->WD_VALOR_R
      CASE TRB->WD_DESPESA == "903"
           MAdiant   -= TRB->WD_VALOR_R
           MSaldos   -= TRB->WD_VALOR_R
      CASE SUBST(TRB->WD_DESPESA,1,1) == '9'
           MAdiant   += TRB->WD_VALOR_R
           MSaldos   += TRB->WD_VALOR_R
      OTHERWISE
           MOutras   += TRB->WD_VALOR_R
           MTot_Ger  += TRB->WD_VALOR_R
   ENDCASE

   IF TRB->WD_BASEADI $ cSim .AND. ! (SUBST(TRB->WD_DESPESA,1,1)== '9')
      MSaldos -= TRB->WD_VALOR_R
   ENDIF

   TRB->(DBSKIP())
ENDDO

TRB->(DBGOTO(MRecno))

nL1:=0.8 ; nL2:=1.8 ; nL3:=2.8
nC1:=01  ; nC2:=14  ; nC3:=06 ; nC4:=20

If lInit # NIL
   //JVR - 28/07/09 - Alinhamento e Definição dos SAYs da tela.
   @nL1,nC1 SAY STR0154 OF oDlg Size 50,8 //"Seguro/Frete"
   @nL1,nC2 SAY STR0155 OF oDlg Size 50,8 //"Outras Despesas"
   
   @nL2,nC1 SAY STR0156 OF oDlg Size 50,8 //"Impostos"
   @nL2,nC2 SAY STR0157 OF oDlg Size 50,8 //"Adiantamentos"
   
   @nL3,nC1 SAY STR0158 OF oDlg Size 50,8 //"Total Geral"
   @nL3,nC2 SAY STR0159 OF oDlg Size 50,8 //"Saldo Adianta/o"
   
   nL1:=03 ; nL2:=04 ; nL3:=05
   @nL1,nC3 MSGET oSeguro   VAR MSeguro   PICTURE cPictValor WHEN .F. SIZE 50,8 RIGHT
   @nL1,nC4 MSGET oOutras   VAR MOutras   PICTURE cPictValor WHEN .F. SIZE 50,8 RIGHT
   
   @nL2,nC3 MSGET oImpostos VAR MImpostos PICTURE cPictValor WHEN .F. SIZE 50,8 RIGHT
   @nL2,nC4 MSGET oAdiant   VAR MAdiant   PICTURE cPictValor WHEN .F. SIZE 50,8 RIGHT
   
   @nL3,nC3 MSGET oTot_Ger  VAR MTot_Ger  PICTURE cPictValor WHEN .F. SIZE 50,8 RIGHT
   @nL3,nC4 MSGET oSaldos   VAR MSaldos   PICTURE cPictValor WHEN .F. SIZE 50,8 RIGHT
Else
   oSeguro:Refresh()
   oOutras:Refresh()
   oImpostos:Refresh()
   oAdiant:Refresh()
   oTot_Ger:Refresh()
   oSaldos:Refresh()
Endif

Return Nil

*----------------------------------------------------------------------------
FUNCTION DI600D_Edi(lInclui)
*----------------------------------------------------------------------------
LOCAL nOpcA:=0, nRec := 0, i6, i
LOCAL cQual, nTipo, bCampo, oDlg

If !lInclui   
   If(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"DESP_ALTERA2"),)

   If !Empty(TRB->WD_NF_COMP)

      SF1->(DBSETORDER(1))
      cTipoNF:=IF(cPaisLoc="BRA","2,3","5")
      IF SF1->(DBSEEK(xFILIAL("SF1")+TRB->WD_NF_COMP+TRB->WD_SE_NFC))
         DO WHILE !SF1->(EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1")  .AND.;
                                      SF1->F1_DOC    == TRB->WD_NF_COMP .AND.;
                                      SF1->F1_SERIE  == TRB->WD_SE_NFC
            IF SF1->F1_HAWB == SW6->W6_HAWB .AND.;
               SF1->F1_TIPO_NF $ cTipoNF
               Help("", 1, "AVG0000259")//Despesa nao pode ser alterada, pois o processo possui NF(s) de Entrada.
               Return .F.
            ENDIF
            SF1->(DBSKIP())
         ENDDO      
      ENDIF
   Endif
   
Endif

//AAF 24/06/08 - Paramêtro para geração de titulos de despesas no financeiro
If EasyGParam("MV_EASYFDE",,.T.)
   EICFI400("ANT_GET_DESP",IF(lInclui,"S","N"))
EndIf

// variaveis p/ EnChoice
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE nCampos := 0

dbSelectArea("SWD")
bCampo := { |nCPO| Field(nCPO) }
FOR i6 := 1 TO FCount()
    M->&(FIELDNAME(i6)) := CRIAVAR(FIELDNAME(i6))
NEXT i6

dbSelectArea("TRB")

IF lInclui
   Inclui := .T.
   cQual:=STR0161 //"InclusÆo de Despesas"
   nTipo:=3
Else
   Inclui := .F.
   IF Easyreccount("TRB") == 0
      Help(" ",1,"EICSEMIT")
      RETURN
   ENDIF

   IF TRB->WD_DESPESA = "101" .Or. ;
      TRB->WD_DESPESA = "104"
      Help(" ",1,"E_FOBCIFNA")
      Return
   ENDIF

   FOR i := 1 TO FCount()
      M->&(EVAL(bCampo,i)) := FieldGet(i)
      nCampos++
   NEXT i

   cQual:=STR0162 ; nTipo:=4 //"Altera‡Æo de Despesas"
Endif

WHILE .T.
   M->WD_HAWB := SW6->W6_HAWB
   nOpca := 0
   
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE cQual ;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL  

   oEnchEdi:=MsMget():New("SWD",nRec,nTipo,,,,aEnchoice,{15,1,(oDlg:nClientHeight-6)/2,COLUNA_FINAL},,3)
   oDlg:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlg ON INIT (DI600EnchoiceBar(oDlg,{{||nopca:=1,oDlg:End()},"OK"},;
                                                         {||nopca:=0,oDlg:End()},.F.),;
                                              oEnchEdi:oBox:Align:=CONTROL_ALIGN_ALLCLIENT)

   If nOpcA = 1
      If !Obrigatorio(aGets,aTela) .OR. !di_validDesp("TUDO")
         Loop
      Endif

      // Verifica se a despesa cadastrada e do tipo DA caso seja nao permite o seu cadastro 
      IF MOpcao == FECHTO_NACIONALIZACAO .And. M->WD_DA == "1"       	       	   
      	 Help("", 1, "AVG0005109")  // 'Despesa Cadastrada devera ser diferente de DA!
         Loop 	            
      Endif

      //AAF 24/06/08 - Paramêtro para geração de titulos de despesas no financeiro
      If EasyGParam("MV_EASYFDE",,.T.) .AND. !EICFI400("POS_GET_DESP")     
         loop
      ENDIF
      IF ! lInclui
         M->RECNO := TRB->RECNO
      ELSE
         M->RECNO := 0
      ENDIF

      M->DELETE := .F.

      E_Grava("TRB",lInclui)

      If ! lInclui
         Exit
      Endif

      E_InitVar()
      ASize(AGets,0) ; ASize(ATela,0)

   ELSE
      Exit
   ENDIF

ENDDO

DI600D_Tela()

RETURN

*----------------------------------------------------------------------------
FUNCTION DI600D_Del()
*----------------------------------------------------------------------------
LOCAL nOpcA, nReg:= TRB->(Recno()), i
LOCAL oDlg, cTit:=STR0163 //"ExclusÆo de Despesas"
LOCAL nOrdSF1 := SF1->(INDEXORD())
SF1->(DBSETORDER(5))
lTemNfE:= .F.
IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB))
  lTemNFE:= .T.
ENDIF
SF1->(DBSETORDER(nOrdSF1))  

lSair:=.F.
IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"DES_EXCLUI2"),)
IF lSair
   Return
ENDIF

IF !EMPTY(TRB->WD_NF_COMP)

   SF1->(DBSETORDER(1))
   cTipoNF:=IF(cPaisLoc="BRA","2,3","5")
   IF SF1->(DBSEEK(xFILIAL("SF1")+TRB->WD_NF_COMP+TRB->WD_SE_NFC))
      DO WHILE !SF1->(EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1")  .AND.;
                                   SF1->F1_DOC    == TRB->WD_NF_COMP .AND.;
                                   SF1->F1_SERIE  == TRB->WD_SE_NFC
         IF SF1->F1_HAWB == SW6->W6_HAWB .AND.;
            SF1->F1_TIPO_NF $ cTipoNF
            Help("", 1, "AVG0000260")//Despesa nao pode ser excluida, pois o processo possui NF(s) de Entrada.
            Return .F.
         ENDIF
         SF1->(DBSKIP())
      ENDDO      
   ENDIF   
Endif

Inclui := .F.

IF TRB->( Easyreccount("TRB") ) == 0
   Help(" ",1,"EICSEMIT")
   RETURN
ENDIF

IF TRB->WD_DESPESA = "101" .Or. ;
   TRB->WD_DESPESA = "104"
   Help(" ",1,"E_FOBCIFNA")
   Return
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE bCampo, nCampos := 0
bCampo := {|x| Field(x) }

dbSelectArea("TRB")
FOR i := 1 TO FCount()
   M->&(EVAL(bCampo,i)) := FieldGet(i)
   nCampos++
NEXT i

nTipo:=ALTERACAO
aAltCpo:={}
IF !EMPTY(TRB->RECNO)
   SWD->(DBGOTO(TRB->RECNO))
   nTipo:=ESTORNO
   aAltCpo:=NIL
ENDIF

DO While .T.
   nOpcA:=1
   
   oMainWnd:ReadClientCoords()  
   DEFINE MSDIALOG oDlg TITLE cTit ;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL  

   oEnchEdi:=MsMget():New("SWD",nReg,nTipo,,,,aEnchoice,{15,1,(oDlg:nClientHeight-6)/2,COLUNA_FINAL},aAltCpo,3)
   oDlg:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlg ON INIT ;
        (DI600EnchoiceBar(oDlg,{{|| If(MsgYesNo(STR0165,STR0141),(nOpca:=2,oDlg:End()),)},"OK" },; //"Confirma a ExclusÆo ?"##"ExclusÆo de Despesas"
                               {|| nOpca:=1,oDlg:End()},.F.),;
         oEnchEdi:oBox:Align:=CONTROL_ALIGN_ALLCLIENT)

   IF nOpcA == 2
     //AAF 24/06/08 - Paramêtro para geração de titulos de despesas no financeiro
     IF !EasyGParam("MV_EASYFDE",,.T.) .OR. EICFI400("MAN_EXC_DESP")
   
      If TRB->WD_DA # "1"
         If TRB->RECNO != 0
            aAdd(aDeletados,TRB->RECNO)
         Endif
         dbSelectArea("TRB")
         dbDelete()
         dbskip(-1)
         IF Bof()
            dbSkip()
            If Eof()
               Pack  // Corrige problema do browse qdo nao existe reg. valido.
            Endif
            Endif
         Endif
      EndIf      
   Endif

   Exit
End

DI600D_Tela()

Return

*--------------------------------------------------------------*
Function DI600EnchoiceBar(oDlg,aOk,bCancel,nOpc,aBotoes)
*--------------------------------------------------------------*
   Local oEnch

   oEnch := EnchoiceBar(oDlg, IIf(aOk != Nil, aOk[1], {||oDlg:End()}), IIf(bCancel != Nil, bCancel, {||oDlg:End()}), , aBotoes)

Return oEnch


*------------------------------------------------------------------------------*
FUNCTION DI600GrvWkSW8(lGrava)//Antiga DI400GrvIvh()
*------------------------------------------------------------------------------*
LOCAL cFieldSW8,cFieldWk,bFieldWk,bFieldSW8,I

For I:=1 To SW8->(FCOUNT())
   
   cFieldSW8:=SW8->(FieldName(i))
   cFieldWk :='WK'+SUBSTR(cFieldSW8,4)
   IF Work_SW8->(FieldPos(cFieldWk)) == 0
      Loop
   Else
      //bFieldWk = {|Valor|IF(Valor==NIL,Work_SW8->WK???????,Work_SW8->WK???????:=Valor)}
      bFieldWk:=FieldWBlock(cFieldWk,Select("Work_SW8"))
   Endif
   //bFieldSW8 = {|Valor|IF(Valor==NIL,SW8->W8_???????,SW8->W8_???????:=Valor)}
   bFieldSW8:=FieldWBlock(cFieldSW8,Select("SW8"))

   IF lGrava
      Eval(bFieldSW8,Eval(bFieldWk))
   ELSE
      Eval(bFieldWK,Eval(bFieldSW8))
   ENDIF
Next
RETURN .T.
*--------------------------------------------------------------------------------------*
FUNCTION DI600SW7Del()// Antiga DI_Estorno //MJB-SAP-1000
*--------------------------------------------------------------------------------------*
LOCAL cMessage:='', nPeso_L:=0 , lEstornouItem := .F., aOcorrencia:={}
LOCAL aInvAcerta:={}, I

DBSELECTAREA("TRB")
TRB->(DBGOTOP())

lEstornouItem = .F.

//Begin Transaction

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ESTORNO_ANTES"),)

DO WHILE TRB->(!EOF())

   IncProc(STR0071+W7_COD_I)//"Processando Item "

   IF !TRB->WK_OK == cMarca
      TRB->(DBSKIP())
      LOOP
   ENDIF

   lEstornouItem := .T.

   IF PosOrd2_IT_Guias(SW6->W6_HAWB,TRB->W7_CC,TRB->W7_SI_NUM,TRB->W7_COD_I ,;
                       TRB->W7_FABR,TRB->W7_FORN,TRB->W7_REG,TRB->W5_PGI_NUM,TRB->W7_PO_NUM,TRB->W7_POSICAO,EICRetLoja("TRB", "W7_FABLOJ"), EICRetLoja("TRB", "W7_FORLOJ")) //RJB 31/03/2004

      SW5->(RecLock("SW5",.F.,.T.))
      SW5->(DBDELETE())
      SW5->(MsUnlock())
   ENDIF

   IF PosOrd1_IT_Guias(TRB->W5_PGI_NUM,TRB->W7_CC,TRB->W7_SI_NUM,;
                       TRB->W7_COD_I,TRB->W7_FABR,TRB->W7_FORN  ,;
                       TRB->W7_REG,0,TRB->W7_PO_NUM,EICRetLoja("TRB", "W7_FABLOJ"), EICRetLoja("TRB", "W7_FORLOJ")) //RJB 31/03/2004

      SW5->(RecLock("SW5",.F.,.T.))
      SW5->W5_SALDO_Q:=SW5->W5_SALDO_Q + TRB->W7_QTDE
      SW5->(MsUnlock())
   ENDIF

   SW7->(DBGOTO(TRB->WKRECNO))
   DI600SW8Del(SW7->W7_HAWB,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,;
               SW7->W7_PGI_NUM,SW7->W7_SI_NUM,SW7->W7_PO_NUM,SW7->W7_CC,;
               SW7->W7_REG,aInvAcerta)

   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ESTORNO_ITEM"),)

   nPeso_L  += SW7->W7_PESO  * SW7->W7_QTDE

   SW7->(RecLock("SW7",.F.,.T.))
   SW7->(DBDELETE())
   SW7->(MsUnlock())
   IF ASCAN(aOcorrencia,TRB->W7_PO_NUM) = 0
      AADD (aOcorrencia,TRB->W7_PO_NUM)
   ENDIF

   TRB->(DBSKIP())
ENDDO

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ESTORNO_MEIO"),)

SW7->(DBSETORDER(1))
IF !SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))

   DBSELECTAREA("SW6")
   M->W6_HAWB:=SW6->W6_HAWB
   IF !EMPTY(SW6->W6_OBS)
      MSMM(SW6->W6_OBS,,,,2)// exclui campo memo
   ENDIF
   IF !EMPTY(SW6->W6_COMPLEM)
      MSMM(SW6->W6_COMPLEM,,,,2)// exclui campo memo
   ENDIF
   SW6->(RecLock("SW6",.F.,.T.))
   SW6->(DBDELETE())
   SW6->(MsUnlock())

   If Select("EIC") > 0
      EIC->(dbSetOrder(1))
      EIC->(dbSeek(xFilial("EIC")+M->W6_HAWB))
      DO While !(EIC->(Eof())) .And. EIC->EIC_FILIAL+EIC->EIC_HAWB == ;
                                  xFilial("EIC")+M->W6_HAWB
         EIC->(RecLock("EIC", .F.))
         EIC->(dbDelete())
         EIC->(MsUnLock())
         EIC->(dbSkip())
      EndDo
   EndIf

   SWD->(DBSETORDER(1))
   IF SWD->(DBSEEK(xFilial()+M->W6_HAWB))
      DO WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL == xFilial("SWD") .AND. SWD->WD_HAWB == M->W6_HAWB
      //JVR - 03/07/09 - Deletar as NF do financeiro.
      DeleDupEIC("EIC",;         //Prefixo do titulo
                 SWD->WD_DOCTO,; //Numero das duplicatas
                 -1,;            //Numero de parcela.
                 "NF ",;         //Tipo do titulo
                 SWD->WD_FORN,;  //Fornecedor
                 SWD->WD_LOJA,;  //Loja
                 "SIGAEIC")      //Origem da geracao da duplicata (Nome da rotina)
         SWD->(RecLock("SWD",.F.,.T.))
         SWD->(DBDELETE())
         SWD->(MsUnLock())
         SWD->(DBSKIP())
      ENDDO
   ENDIF

   SWB->(DBSETORDER(1))
   SWB->(DBSEEK(xFilial()+M->W6_HAWB))
   DO WHILE ! SWB->(EOF()) .AND. SWB->WB_FILIAL == xFilial("SWB") .AND. SWB->WB_HAWB = M->W6_HAWB
      SWB->(RecLock("SWB",.F.,.T.))
      SWB->(DBDELETE())
      SWB->(MsUnLock())
      SWB->(DBSKIP())
   ENDDO

   SWA->(DBSETORDER(1))
   IF SWA->(DBSEEK(xFilial()+M->W6_HAWB))
      SWA->(RecLock("SWA",.F.,.T.))
      SWA->(DBDELETE())
      SWA->(MsUnLock())
   ENDIF

   DI600EIGrava('ESTORNO',SW6->W6_HAWB,{})

   cMessage:= STR0182+UPPER(cCadastro) //"ESTORNO TOTAL "

ELSE

   IF lEstornouItem
      DBSELECTAREA("SW6")
      SW6->(RecLock("SW6",.F.))
      SW6->W6_DT_ENCE :=dDataBranca
      SW6->W6_PESOL   :=SW6->W6_PESOL-nPeso_L
      SW6->(MsUnlock())
   ENDIF

   cMessage:= STR0184+UPPER(cCadastro) //"ESTORNO PARCIAL "

ENDIF
 
DI600AcertaSW9(SW6->W6_HAWB,aInvAcerta)
 
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ESTORNO_DEPOIS"),)

FOR I=1 TO LEN(aOcorrencia)
    Grava_Ocor(aOcorrencia[I],dDataBase,cMessage)
NEXT

//End Transaction

TRB->(DBGOTOP())
RETURN .T.
*--------------------------------------------------------------------------------*
FUNCTION DI600SW8Del(PHawb,PItem,PFabr,PForn,PPGi,PSi,PPo,PCc,PReg,aInvAcerta)// Antiga DI410_IVH() //MJB-SAP-1000
*--------------------------------------------------------------------------------*
LOCAL cFilSW8:=xFilial('SW8'), nOrdSW7:=SW7->(IndexOrd())

If lIntDraw
   ED4->(dbSetOrder(2))
EndIf
SW7->(dbSetOrder(4))
SW8->(DBSETORDER(3))
//SW8->(DBSEEK(cFilSW8+PHawb+PPgi+PPo+PSi+PCc+PItem+STR(PReg,nTamReg,0)))
//TRP - 21/09/12
SW8->(DBSEEK(cFilSW8 + AvKey(PHawb,"W8_HAWB")   +;
                       AvKey(PPgi,"W8_PGI_NUM") +;
                       AvKey(PPo,"W8_PO_NUM")   +;
                       AvKey(PSi,"W8_SI_NUM")   +;
                       AvKey(PCc,"W8_CC")       +;
                       AvKey(PItem,"W8_COD_I")  +;
                       STR(PReg,nTamReg,0)))

//TRP - 21/09/12
DO WHILE ! SW8->(EOF())             .AND. SW8->W8_FILIAL == cFilSW8 .AND.;
           SW8->W8_HAWB    == AvKey(PHawb,"W8_HAWB") .AND. SW8->W8_COD_I  == AvKey(PItem,"W8_COD_I")   .AND.;
           SW8->W8_PGI_NUM == AvKey(PPgi,"W8_PGI_NUM")  .AND. SW8->W8_SI_NUM == AvKey(PSi,"W8_SI_NUM")     .AND.;
           SW8->W8_CC      == AvKey(PCc,"W8_CC")   .AND. SW8->W8_REG    == PReg    .AND.;
           SW8->W8_PO_NUM  == AvKey(PPo,"W8_PO_NUM")
   IF ASCAN(aInvAcerta,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")) = 0
      AADD(aInvAcerta,SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ"))
   ENDIF
   IF !EMPTY(SW8->W8_DESC_DI)
      MSMM(SW8->W8_DESC_DI,,,,2)
   ENDIF

   If lIntDraw .and. lExistW8_AC .and. !Empty(SW8->W8_AC)
      ED4->(dbSeek(cFilED4+SW8->W8_AC+SW8->W8_SEQSIS))
      If ED0->ED0_AC <> ED4->ED4_AC .or. cFilED0 <> ED0->ED0_FILIAL
         ED0->(dbSetOrder(2))
         ED0->(dbSeek(cFilED0+ED4->ED4_AC))
      EndIf
      ED4->(RecLock("ED4",.F.))
      If ED0->ED0_TIPOAC <> GENERICO .or. ED4->ED4_NCM <> NCM_GENERICA
         ED4->ED4_QT_DI  += SW8->W8_QT_AC
         If AvVldUn(ED4->ED4_UMNCM)
            SW7->(dbSeek(xFilial("SW7")+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
            ED4->ED4_SNCMDI += SW7->W7_PESO * SW8->W8_QTDE
         Else
            ED4->ED4_SNCMDI += AVTransUnid(ED4->ED4_UMITEM,ED4->ED4_UMNCM,SW8->W8_COD_I,SW8->W8_QT_AC)
         EndIf
      EndIf
      ED4->ED4_VL_DI  += SW8->W8_VL_AC
      ED4->(msUnlock())
   EndIf
   IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DELETA_SW8DEL"),)

   DI600SWVEstorno(SW8->(W8_INVOICE+W8_PGI_NUM+W8_PO_NUM+W8_POSICAO))// AWR - Lote

   SW8->(RecLock("SW8",.F.,.T.))
   SW8->(DBDELETE())
   SW8->(MsUnlock())
   SW8->(DBSKIP())
ENDDO

SW7->(dbSetOrder(nOrdSW7))

If lIntDraw
   ED4->(dbSetOrder(1))
EndIf

RETURN .T.
*--------------------------------------------------------------------------------*
FUNCTION DI600AcertaSW9(cProcesso,aInvAcerta)
*--------------------------------------------------------------------------------*
LOCAL cFilSW7:=xFilial('SW7'), A
LOCAL cFilSW8:=xFilial('SW8')
LOCAL cFilSW9:=xFilial('SW9')
LOCAL cFilEZZ:=xFilial('EZZ')
LOCAL nTotalQTDE:=nRateio:=nTotalPESO:=0
LOCAL aAcertos:={},nRecFRE:=nRecVlr:=1,lPerg
LOCAL nMaiorFre:=nMaiorVlr:=0,nCont:=0,lRateia:=.F.
LOCAL nTotSW7_R:= nTotSW8_R:= nTotSW9_R:= nVLMLEMN:=0,aMoeda:={}
LOCAL nInland:= nPacking:= nDescont:= nOutDesp:= nFrete:=0
LOCAL nSeguro := 0   // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)

SW8->(DBSETORDER(1))
SW9->(DBSETORDER(3))
SW7->(DBSETORDER(4))
ProcRegua(10)

IF SW9->(DBSEEK(cFilSW9+cProcesso))
   DO WHILE SW9->(!EOF())  .AND.;
            SW9->W9_HAWB   == cProcesso .AND.;
            SW9->W9_FILIAL == cFilSW9
   
      IF nCont > 10
         nCont:=0
         ProcRegua(10)
      ELSE
         nCont++
         IncProc(STR0299+SW9->W9_INVOICE) //"Acertando Invoice: "
      ENDIF
      SW9->(RecLock("SW9",.F.))

      IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DELETA_SW9_A"),)
//    IF(!EMPTY(SW9->W9_DTLANC),FI400MOVCONT("INVOICE","E"),)

      IF !SW8->(DBSEEK(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9", "W9_FORLOJ")))//FDR - 13/09/12 - Tratamento de loja
         SW9->(DBDELETE())
         SW9->(MsUnlock())
         SW9->(DBSKIP())  
         LOOP
      ELSEIF ASCAN(aInvAcerta,SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9", "W9_FORLOJ")) # 0//FDR - 13/09/12 - Tratamento de loja
         SW9->W9_FOB_TOT:=0
         nTotalQTDE:=nTotalPESO:=0    
         nCont:=0
         DO WHILE SW8->(!EOF()) .AND. SW8->W8_HAWB   ==SW9->W9_HAWB    .AND.;
                                      SW8->W8_INVOICE==SW9->W9_INVOICE .AND.;
                                      SW8->W8_FORN   ==SW9->W9_FORN    .AND.;
                                      SW8->W8_FILIAL == cFilSW8 .And.;
                                      (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ)//FDR - 13/09/12 - Tratamento de loja
            nCont++
            SW9->W9_FOB_TOT+=(SW8->W8_QTDE*SW8->W8_PRECO)
            nTotalQTDE     +=SW8->W8_QTDE
            IF SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
               nTotalPESO  +=(SW8->W8_QTDE*SW7->W7_PESO)
            ENDIF
            SW8->(DBSKIP())
         ENDDO

         lPerg:=(DI600RetVal("TOT_INV,SEM_FOB", "TAB", .T.) # 0)  // EOB - 03/06/08 - chamada da função DI500RetVal

         lRateia:=DI600InvConf(.F.,SW9->W9_INVOICE,SW9->W9_FORN,lPerg, EICRetLoja("SW9", "W9_FORLOJ"))//FDR - 13/09/12 - Tratamento de loja

         aAcertos:={}
         AADD(aAcertos,{0,SW9->W9_INLAND })
         AADD(aAcertos,{0,SW9->W9_PACKING})
         AADD(aAcertos,{0,SW9->W9_DESCONT})
         AADD(aAcertos,{0,SW9->W9_OUTDESP})
         AADD(aAcertos,{0,SW9->W9_FRETEIN})
         // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
         IF lSegInc
            AADD(aAcertos,{0,SW9->W9_SEGURO})
         ENDIF

         ProcRegua(nCont)
         SW8->(DBSEEK(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN))
         DO WHILE SW8->(!EOF()) .AND. SW8->W8_HAWB   ==SW9->W9_HAWB    .AND.;
                                      SW8->W8_INVOICE==SW9->W9_INVOICE .AND.;
                                      SW8->W8_FORN   ==SW9->W9_FORN    .AND.;
                                      SW8->W8_FILIAL == cFilSW8 .AND. lRateia .And.;
                                      (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ)//FDR - 13/09/12 - Tratamento de loja
            IncProc(STR0299+SW9->W9_INVOICE) //"Acertando Invoice: "
            SW8->(RecLock("SW8",.F.))
            nRateio:=(SW8->W8_QTDE*SW8->W8_PRECO)/SW9->W9_FOB_TOT
            SW8->W8_INLAND  :=DI600Trans(nRateio*SW9->W9_INLAND )
            SW8->W8_PACKING :=DI600Trans(nRateio*SW9->W9_PACKING)
            SW8->W8_DESCONT :=DI600Trans(nRateio*SW9->W9_DESCONT)
            SW8->W8_OUTDESP :=DI600Trans(nRateio*SW9->W9_OUTDESP)
            // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
            IF lSegInc                                           
               IF !EMPTY(SW9->W9_SEGURO) .AND. SW9->W9_SEGINC $ cNao
                   SW8->W8_SEGURO :=DI600Trans(nRateio*SW9->W9_SEGURO)
               ENDIF
            ENDIF

            IF !EMPTY(SW9->W9_FRETEIN) .AND. SW9->W9_FREINC $ cNao
               IF SW9->W9_RAT_POR == "1" //Peso
                  nRateio:=0
                  IF SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
                     nRateio:=(SW8->W8_QTDE*SW7->W7_PESO)/nTotalPESO
                  ENDIF
               ELSEIF SW9->W9_RAT_POR == "3" //Quantidade               
                  nRateio:=SW8->W8_QTDE/nTotalQTDE
               ENDIF
               SW8->W8_FRETEIN:=DI600Trans(nRateio*SW9->W9_FRETEIN)
            ENDIF   
            SW8->(MsUnlock())
   
            aAcertos[1,1]+=SW8->W8_INLAND
            aAcertos[2,1]+=SW8->W8_PACKING
            aAcertos[3,1]+=SW8->W8_DESCONT
            aAcertos[4,1]+=SW8->W8_OUTDESP
            aAcertos[5,1]+=SW8->W8_FRETEIN
            // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
            IF lSegInc
               aAcertos[6,1]+=SW8->W8_SEGURO
            ENDIF
            IF (SW8->W8_QTDE*SW8->W8_PRECO) > nMaiorVlr
               nMaiorVlr:=SW8->W8_QTDE*SW8->W8_PRECO
               nRecVlr  :=SW8->(RECNO())
            ENDIF   
            IF SW8->W8_FRETEIN > nMaiorFre
               nMaiorFre:=SW8->W8_FRETEIN
               nRecFre  :=SW8->(RECNO())
            ENDIF   
            SW8->(DBSKIP())
         ENDDO

//       FI400MOVCONT("INVOICE","I")

         IF lRateia
            SW8->(DBGOTO(nRecVlr))
            SW8->(RecLock("SW8",.F.))
            FOR A := 1 TO 6
               IF !EMPTY(aAcertos[A,1]) .AND.  aAcertos[A,2] # aAcertos[A,1]
                  IF(A=1,SW8->W8_INLAND += aAcertos[A,2] - aAcertos[A,1],)
                  IF(A=2,SW8->W8_PACKING+= aAcertos[A,2] - aAcertos[A,1],)
                  IF(A=3,SW8->W8_DESCONT+= aAcertos[A,2] - aAcertos[A,1],)
                  IF(A=4,SW8->W8_OUTDESP+= aAcertos[A,2] - aAcertos[A,1],)
                  // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
                  IF lSegInc
                     IF(A=6,SW8->W8_SEGURO+= aAcertos[A,2] - aAcertos[A,1],)
                  ENDIF
               ENDIF
            NEXT
            SW8->(MsUnlock())
            IF !EMPTY(aAcertos[5,1]) .AND. aAcertos[5,2] # aAcertos[5,1]
               SW8->(DBGOTO(nRecFre))
               SW8->(RecLock("SW8",.F.))
               SW8->W8_FRETEIN+=aAcertos[5,2] - aAcertos[5,1]
               SW8->(MsUnlock())
            ENDIF
         ENDIF
      ENDIF
      
      IF SW6->(DBSEEK(xFilial()+cProcesso))   
         //IF LEN(aMoeda) < 2 .OR. EMPTY(aMoeda)
         IF ASCAN(aMoeda,SW9->W9_MOE_FOB)=0
            AADD(aMoeda,SW9->W9_MOE_FOB)
         ENDIF
         //TRP-18/02/08- Gravação dos campos na moeda local independentemente da qtde de moedas e invoices na DI.
         //AST - 26/11/08 - Gravação dos campos na moeda local ou moeda da DI (MV_VLDIMOE).
         If lVlDIMoe
            nInland  += SW9->W9_INLAND * SW9->W9_TX_FOB
            nPacking += SW9->W9_PACKING * SW9->W9_TX_FOB
            nDescont += SW9->W9_DESCONT * SW9->W9_TX_FOB
            nOutDesp += SW9->W9_OUTDESP * SW9->W9_TX_FOB  
            nFrete   += SW9->W9_FRETEIN * SW9->W9_TX_FOB  
            nVLMLEMN += SW9->W9_FOB_TOT * SW9->W9_TX_FOB  
            // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
            IF lSegInc
               nSeguro += SW9->W9_SEGURO * SW9->W9_TX_FOB
            ENDIF
         Else
            nInland  += SW9->W9_INLAND 
            nPacking += SW9->W9_PACKING 
            nDescont += SW9->W9_DESCONT
            nOutDesp += SW9->W9_OUTDESP
            nFrete   += SW9->W9_FRETEIN
            nVLMLEMN += SW9->W9_FOB_TOT
            // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
            IF lSegInc
               nSeguro += SW9->W9_SEGURO 
         EndIf         
         EndIf         
         //ENDIF
         nTotSW9_R+=(SW9->W9_FOB_TOT*SW9->W9_TX_FOB)
      ENDIF
      IF !lRateia .AND. SW9->(FIELDPOS("W9_TUDO_OK")) # 0
         SW9->W9_TUDO_OK:=NAO
      ENDIF
      SW9->(MsUnlock())
      SW9->(DBSKIP())
   ENDDO
                             
   // EOS - Exclui as invoices especiais somente se for estorno total
IF lExistEZZ
   IF !SW9->(DBSEEK(cFilSW9+cProcesso))   
       EZZ->(DBSEEK(cFilEZZ+cProcesso))
       DO WHILE EZZ->(!EOF()) .AND. EZZ->EZZ_FILIAL == cFilEZZ .AND. ;
                                    EZZ->EZZ_HAWB   == cProcesso 
          IF nCont > 10
             nCont:=0
             ProcRegua(10)
          ELSE
             nCont++
             IncProc(STR0299+EZZ->EZZ_INVOIC) //"Acertando Invoice: "
          ENDIF
          EZZ->(RecLock("EZZ",.F.))
          EZZ->(DBDELETE())
          EZZ->(MsUnlock())
          EZZ->(DBSKIP())  
          LOOP
       ENDDO   			
   ENDIF
ENDIF
  
   IF SW6->(DBSEEK(xFilial()+cProcesso))
      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_FOB_TOT:=nTotSW9_R
      //IF LEN(aMoeda) < 2
      SW6->W6_INLAND  :=nInland
      SW6->W6_PACKING :=nPacking
      SW6->W6_FRETEIN :=nFrete
      SW6->W6_OUTDESP :=nOutDesp
      SW6->W6_DESCONT :=nDescont
      SW6->W6_VLMLEMN :=nVLMLEMN
      // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         SW6->W6_SEGINV := nSeguro
      ENDIF      
      //ENDIF
      SW6->(MSUNLOCK())
   ENDIF

ENDIF

RETURN .T.

*--------------------------------------------------*
Function DI600EIGrava(cExecuta,cHawb,aAlias)
*--------------------------------------------------*
LOCAL cAlias,nDel,i,cWork,cFilAux,nRecTot:=0,lGrava, A
Private cExec := cExecuta

DO CASE
CASE cExecuta == 'LEITURA'
   ProcRegua(Len(aAlias))
   For I:=1 To Len(aAlias)
      cWork   := "Work_"+aAlias[i]
      cAlias  := aAlias[i]
      cFilAux := xFilial(cAlias)
      IncProc(STR0300+cAlias+"...") //"Gravando Temporario do "
      (cWork)->(AvZap())
      IF (cAlias)->(DBSEEK(cFilAux+cHawb))
         DO WHILE !(cAlias)->(EOF()) .AND.;
                   (cAlias)->&(cAlias+"_FILIAL") == cFilAux .AND.;
                   (cAlias)->&(cAlias+"_HAWB")   == cHawb
            (cWork)->(DBAPPEND())
            AVReplace(cAlias,cWork)
            (cWork)->WK_RECNO:=(cAlias)->(RECNO())
            (cAlias)->(DBSKIP())
         ENDDO
      ENDIF   
   Next

CASE cExecuta == 'GRAVACAO'
   For I:=1 To Len(aAlias)
      nRecTot += (aAlias[I])->(Easyreccount(aAlias[I]))
   NEXT
   ProcRegua(LEN(aDeletados)+nRecTot)
   FOR nDel := 1 TO LEN(aDeletados)
       IF !EMPTY(aDeletados[nDel,2])
          cAlias:=aDeletados[nDel,1]
          IncProc(STR0301+cAlias+"...") //"Excluindo Registros do "
          (cAlias)->(DBGOTO(aDeletados[nDel,2]))
          (cAlias)->(RECLOCK(cAlias,.F.))
          (cAlias)->(DBDELETE())      
          (cAlias)->(MSUNLOCK())
       ENDIF
   NEXT
   For I:=1 To Len(aAlias)
      cAlias:= aAlias[I]
      lGrava:='lGrava'+cAlias
      lGrava:=&(lGrava)
      IF !lGrava
         LOOP
      ENDIF
      cWork   := "Work_"+cAlias
      bGrvHAWB:= FIELDWBLOCK(cAlias+"_HAWB",SELECT(cAlias))
      (cWork)->(DBGOTOP())         

      DO WHILE (cWork)->(!EOF())
         IncProc(STR0302+cAlias+"...") //"Gravando Registros do "
         IF EMPTY((cWork)->WK_RECNO)
            (cAlias)->(RECLOCK(cAlias,.T.))
         ELSE
            (cAlias)->(DBGOTO((cWork)->WK_RECNO))
            (cAlias)->(RECLOCK(cAlias,.F.))
         ENDIF
         AVReplace(cWork,cAlias)//Esta funcao ja grava filial
         EVAL(bGrvHAWB,M->W6_HAWB)
         (cAlias)->(MSUNLOCK())
         (cWork)->(DBSKIP())
      ENDDO
   Next

CASE cExecuta == 'ESTORNO'
   FOR A := 1 TO LEN(aAliasCapa)
       AADD(aAlias,aAliasCapa[A])
   NEXT
   ProcRegua(Len(aAlias))
   For i:=1 To Len(aAlias)
      cAlias  := aAlias[i]   
      cFilAux := xFilial(cAlias)
      IncProc(STR0301+cAlias+"...") //"Excluindo Registros do "
      IF (cAlias)->(DBSEEK(cFilAux+cHawb))
         DO WHILE (cAlias)->&(cAlias+"_FILIAL") == cFilAux .AND. !(cAlias)->(EOF()) .AND.;
                  (cAlias)->&(cAlias+"_HAWB")   == cHawb
            (cAlias)->(RECLOCK(cAlias,.F.))
            (cAlias)->(DBDELETE())      
            (cAlias)->(MSUNLOCK())
            (cAlias)->(DBSKIP())
         ENDDO
      ENDIF   
   Next
   
ENDCASE

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"GRAVA_EI"),)

RETURN .T.
*--------------------------------------------------------*
Function DI600aEMB()//Antiga EICDI400aEMB
*--------------------------------------------------------*
LOCAL I
PRIVATE aTiraCampos:={"W6_ADICAOK","W6_DEBITOS","W6_DEBITVM","W6_PROCVIN","W6_PROCVVM",;
                      "W6_QTD_ADI","W6_SEGBASE","W6_SEGPERC","W6_VOLUMES","W6_VOLUMVM",;
                      "W6_INSTRDE","W6_INSTRVM"}

IF MOpcao == FECHTO_EMBARQUE
   aEmbarques:={ "W6_HAWB"    , "W6_HOUSE"   , "W6_DT_HAWB" , "W6_DT_EMB"  ,;
                 "W6_MAWB"    , "W6_DT_ETD"  , "W6_IDENTVE" , "W6_PAISVEI" ,;
                 "W6_PAISNOM" , "W6_AGENTE"  , "W6_AGENTEN" , "W6_VIA_TRA" ,;
                 "W6_DESCVIA" , "W6_DESP"    , "W6_DESPNOM" , "W6_DT_ETA"  ,;
                 "W6_REF_DES" , "W6_ORIGEM"  , "W6_DEST"    , "W6_LOCAL"   ,;
                 "W6_FAT_DES" , "W6_CONEVE1" , "W6_CONEET1" , "W6_CONEPO1" ,;
                 "W6_CONEVE2" , "W6_CONEET2" , "W6_CONEPO2" , "W6_PESO_BR" ,;
                 "W6_MT3"     , "W6_VOLUME"  , "W6_OUT_CTN" , "W6_OUTROS"  ,;
                 "W6_PESO_TX" , "W6_CONTA20" , "W6_PESOTOT" , "W6_CONTA40" ,;
                 "W6_TIPODES" , "W6_URF_DES" , "W6_URF_ENT" , "W6_REC_ALF" ,;
                 "W6_MODAL_D" , "W6_TIPOCON" , "W6_TIPODOC" , "W6_UTILCON" ,;
                 "W6_IDEMANI" , "W6_VM_COMP" , "W6_IDENTCT" , "W6_FREMOED" ,;
                 "W6_FOB_GER" , "W6_CON40HC" , "W6_SETORRA" , "W6_TX_FRET" ,;
                 "W6_VM_TDES" , "W6_VM_UENT" , "W6_VM_UDES" , "W6_VM_RECA" ,;
                 "W6_VLFRECC" , "W6_VLFREPP" , "W6_VLFRETN" , "W6_SEGMOED" ,;
                 "W6_VL_USSE" , "W6_VLSEGMN" , "W6_TX_SEG"  ,;
                 "W6_VM_TCON" , "W6_LOCALN"  , "W6_MSG_COM" , "W6_ARMAZEM" }
                 

ElseIf MOpcao == FECHTO_NACIONALIZACAO .AND. EasyGParam("MV_MOST_DA")
   aEmbarques:={ "W6_HAWB"    , "W6_DT_HAWB" , "W6_DESP"    , "W6_DESPNOM" ,;
                 "W6_REF_DES" , "W6_LOCAL"   , "W6_LOCALN"  , "W6_FAT_DES" ,;
                 "W6_DTRECDO" , "W6_LOTE"    , "W6_PRVDESE" , "W6_DT"      ,;
                 "W6_DI_NUM"  , "W6_DTREG_D" , "W6_TX_US_D" , "W6_VLSEGMN" ,;
                 "W6_FOB_TOT" , "W6_INLAND"  , "W6_PACKING" , "W6_DESCONT" ,;
                 "W6_FOB_GER" , "W6_FREMOED" , "W6_VLFRECC" , "W6_VLFREPP" ,;
                 "W6_TX_FRET" , "W6_SEGMOED" , "W6_VL_USSE" , "W6_DT_DESE" ,;
                 "W6_DESCRPG" , "W6_NF_ENT"  , "W6_MSG_COM" , "W6_VLFRETN" ,;
                 "W6_SE_NF"   , "W6_DT_NF"   , "W6_VL_NF"   , "W6_PROG_DI" ,;
                 "W6_DT_ENTR" , "W6_NF_COMP" , "W6_SE_NFC"  , "W6_DT_NFC"  ,;
                 "W6_VL_NFC"  , "W6_PESO_BR" , "W6_MT3"     , "W6_VOLUME"  ,;
                 "W6_PESO_TX" , "W6_PESOTOT" , "W6_DT_AVE"  , "W6_VM_OBS"  ,;
                 "W6_NR_PRO"  , "W6_DT_DOC"  , "W6_TIPODES" , "W6_VM_TDES" ,;
                 "W6_REC_ALF" , "W6_VM_RECA" , "W6_MODAL_D" , "W6_URF_DES" ,;
                 "W6_VM_UDES" , "W6_URF_ENT" , "W6_VM_UENT" , "W6_VM_COMP" ,;
                 "W6_DT_ENCE" , "W6_UTILCON" , "W6_TIPODOC" , "W6_FREPPCC" ,;
                 "W6_ID_MANI" , "W6_TIPOCON" , "W6_VM_TCON" , "W6_TX_SEG" }
EndIf

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ALTERA_AEMBARQUE"),)

IF cPaisLoc # "BRA"
   IF aEmbarques = NIL
      aEmbarques:={}                             
      SX3->(DBSETORDER(1))
      SX3->(DbSeek("SW6"))
      DO WHILE SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "SW6"
          IF X3USO(SX3->X3_USADO) .AND. ASCAN(aTiraCampos,ALLTRIM(SX3->X3_CAMPO)) = 0
             AADD(aEmbarques,ALLTRIM(SX3->X3_CAMPO))
          ENDIF
          SX3->(DBSKIP())
      ENDDO
   ELSE
      aAuxEmb:=ACLONE(aEmbarques)
      aEmbarques:={}
      For I := 1 TO LEN(aAuxEmb)
          IF ASCAN(aTiraCampos,aAuxEmb[I]) = 0
             AADD(aEmbarques,aAuxEmb[I])
          ENDIF
      NEXT
   ENDIF
ENDIF

Return .T.

*------------------------------------------*
Function DI600Trans(nValor,nDec)
*------------------------------------------*
DEFAULT nDec := nDecimais
RETURN ROUND(nValor,nDec)

*---------------------------------------------------*
Function DI600Taxa(lMemoria)
*---------------------------------------------------*
LOCAL nTaxaInv:=1,lDif:=.F.,cFILSW9:=xFilial("SW9")
LOCAL nTaxaUSD:=nTaxaSeg:=nTaxaFre:=0
LOCAL dDataBusca:=dDataBase
Private lMem:=lMemoria //para uso no ponto de entrada

IF lMem
   IF EMPTY(M->W6_DTREG_D)               
      Help("", 1, "AVG0000721",,AVSX3("W6_DTREG_D",5),1,8)
      RETURN .F.
   ENDIF
   dDataBusca:=M->W6_DTREG_D
ELSE
   IF EMPTY(SW6->W6_DTREG_D)               
      Help("", 1, "AVG0000721",,AVSX3("W6_DTREG_D",5),1,8)
      RETURN .F.
   ENDIF
   dDataBusca:=SW6->W6_DTREG_D
ENDIF   

nTaxaUSD:=BuscaTaxa(cMoeDolar,dDataBusca,.T.,.F.,.T.)
IF lMemoria
   nTaxaSeg:=BuscaTaxa(M->W6_SEGMOED,dDataBusca,.T.,.F.,.T.)
   nTaxaFre:=BuscaTaxa(M->W6_FREMOED,dDataBusca,.T.,.F.,.T.)
   IF !Inclui .AND. lPrimeiraVez
      Processa({|| DI600Existe() },STR0054) //"Pesquisa de Itens"
   ENDIF
ELSE
   nTaxaSeg:=BuscaTaxa(SW6->W6_SEGMOED,dDataBusca,.T.,.F.,.T.)
   nTaxaFre:=BuscaTaxa(SW6->W6_FREMOED,dDataBusca,.T.,.F.,.T.)
ENDIF

ProcRegua(4)
IncProc(STR0338) //"Verificando Taxa Seguro..."
IF lMemoria
   IF !EMPTY(M->W6_VL_USSE) .AND. M->W6_TX_SEG # nTaxaSeg
      M->W6_TX_SEG :=nTaxaSeg
      M->W6_VLSEGMN:=M->W6_VL_USSE*M->W6_TX_SEG
      lDif:=.T.
   ENDIF           
ELSE
   IF !EMPTY(SW6->W6_VL_USSE) .AND. SW6->W6_TX_SEG # nTaxaSeg
      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_TX_SEG :=nTaxaSeg
      SW6->W6_VLSEGMN:=SW6->W6_VL_USSE*SW6->W6_TX_SEG
      SW6->(MSUNLOCK())
      lDif:=.T.
   ENDIF           
ENDIF           

IncProc(STR0339) //"Verificando Taxa Frete..."
IF lMemoria
   nFrete:=ValorFrete(M->W6_HAWB,,,2,.T.)
   IF !EMPTY(nFrete) .AND. M->W6_TX_FRET # nTaxaFre
      M->W6_TX_FRET:=nTaxaFre
      lDif:=.T.
   ENDIF
ELSE
   nFrete:=ValorFrete(SW6->W6_HAWB,,,2)
   IF !EMPTY(nFrete) .AND. SW6->W6_TX_FRET # nTaxaFre
      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_TX_FRET:=nTaxaFre
      SW6->(MSUNLOCK())
      lDif:=.T.
   ENDIF
ENDIF

IncProc(STR0340) //"Verificando Taxa D.I. ..."
IF lMemoria
   IF M->W6_TX_US_D # nTaxaUSD
      M->W6_TX_US_D:=nTaxaUSD
   ENDIF
ELSE
   IF SW6->W6_TX_US_D # nTaxaUSD
      SW6->(RECLOCK("SW6",.F.))
      SW6->W6_TX_US_D:=nTaxaUSD
      SW6->(MSUNLOCK())
   // lDif:=.T.  // Esta taxa nao influencia nas adicoes
   ENDIF
ENDIF

IncProc(STR0341) //"Verificando Taxas Invoices..."
IF lMemoria
   Work_SW9->(DBSETORDER(1))
   Work_SW9->(DBGOTOP())
   cAlias:="Work_SW9"
   bWhile:={||.T.}
ELSE               
   SW9->(DBSETORDER(3))
   SW9->(DBSEEK(cFILSW9+SW6->W6_HAWB))
   cAlias:="SW9"
   bWhile:={|| SW9->W9_HAWB   == SW6->W6_HAWB .AND.;
               SW9->W9_FILIAL == cFILSW9}
ENDIF

DO WHILE (cAlias)->(!EOF()) .AND. EVAL(bWhile)
   nTaxaInv:=BuscaTaxa((cAlias)->W9_MOE_FOB,dDataBusca,.T.,.F.,.T.)
   IF (cAlias)->W9_TX_FOB # nTaxaInv
      IF(!lMemoria, SW9->(RECLOCK("SW9",.F.)) ,)
      (cAlias)->W9_TX_FOB:=nTaxaInv
      IF(!lMemoria, SW9->(MSUNLOCK()) ,)
      lGravaSoCapa:=.F.
      IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ALTERA_SW9_A"),)
   Endif           
   (cAlias)->(DBSKIP())
ENDDO

IncProc()

RETURN .T.

*----------------------------
FUNCTION Di_ValidDesp(cValid)
*----------------------------
LOCAL lRetorno  := .T.

PRIVATE lCposNovosWD := ( SWD->(FieldPos("WD_SE_DOC"))  > 0 .AND. ;
                          SWD->(FieldPos("WD_TES"))     > 0 .AND. ;
                          SWD->(FieldPos("WD_MOEDA"))   > 0 .AND. ;
                          SWD->(FieldPos("WD_VALOR_M")) > 0 .AND. ;
                          SWD->(FieldPos("WD_TX_MOE"))  > 0 )

IF !lCposNovosWD
   RETURN .T.
ENDIF
DO CASE              
	CASE cValid == "TUDO"
		IF EMPTY(M->WD_MOEDA)
			IF EMPTY(M->WD_VALOR_R)
				MSGINFO(STR0523)
				lRetorno := .F.
			ENDIF
		ELSE
			IF EMPTY(M->WD_TX_MOE)
				MSGINFO(STR0524)
				lRetorno := .F.
			ELSEIF EMPTY(M->WD_VALOR_M)
			    MSGINFO(STR0525)
			    lRetorno := .F.
			ENDIF
		ENDIF
	      
	CASE cValid == "TEM_MOEDA"
//IF EMPTY(M->WD_MOEDA) 
//   M->WD_TX_MOE  := 0
//   M->WD_VALOR_M := 0
//   lRetorno := .F.
//ENDIF
	CASE cValid == "WD_TX_MOE"
	    IF !EMPTY(M->WD_MOEDA) .AND. M->WD_TX_MOE = 0
	       MSGINFO(STR0524)
	       RETURN .F.
       	ENDIF                                    
       	M->WD_VALOR_R:=(M->WD_TX_MOE*M->WD_VALOR_M)
ENDCASE	
RETURN lRetorno

*----------------------*
FUNCTION DI600HLPW2()
*----------------------*
LOCAL oDlg, Tb_Campos:={},lOK:=.F.
LOCAL bAction:={||lOK:=.T.,CPEDIDO:=Work_PO->W3_PO_NUM,oDlg:End()}
LOCAL bCancel:={||lOK:=.F.,oDlg:End()}

IF UPPER(ReadVar()) <> "CPEDIDO"
   RETURN .F.
ENDIF

AADD(Tb_Campos, {"W3_PO_NUM",,AVSX3("W2_PO_NUM",5),AVSX3("W2_PO_NUM",6)} )

IF SELECT("Work_PO") <> 0
   Work_PO->(AvZap())   
ENDIF

DBSELECTAREA("Work_PO")

Processa({|| DI600GrW2Hlp()},"Generando help de los P.O.")
nAlt := 20
nLar := 38
DEFINE MSDIALOG oDlg TITLE "Consulta de los P.O." FROM 4,1 TO nAlt,nLar OF oMainWnd

   Work_PO->(dbGoTop())

    nAlt := (oDlg:nClientHeight-32)/2
    nLar := COLUNA_FINAL-55
    oMark:= MsSelect():New("Work_PO",,,TB_Campos,@lInverte,@cMarca,{4,4,nAlt,nLar})
    oMark:baval:=bAction
    
    nLar := COLUNA_FINAL-50
    @10,nLar BUTTON "Seleccion PO" SIZE 44,13 ACTION (Eval(bAction)) OF oDlg PIXEL
    @30,nLar BUTTON "Anular"       SIZE 44,13 ACTION (Eval(bCancel)) OF oDlg PIXEL

//ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bAction,bCancel)  CENTERED
ACTIVATE MSDIALOG oDlg CENTERED

DBSELECTAREA("SW3")

RETURN lOK

*----------------------------------------------------------------------------*
Function DI600GrW2Hlp()  
*----------------------------------------------------------------------------*
ProcRegua(SW2->(Easyreccount("SW2")))

//IF !Inclui
//   RETURN .F.
//ENDIF
        
OldArea:=SELECT()

cCPos:="SW5.W5_PO_NUM W5_PO_NUM "   
   
/* REGIANE 20/09 - Erro na leitura do SW5

cQuery:="SELECT DISTINCT "+cCpos+" FROM SW5"+SM0->M0_CODIGO+"0 SW5 WHERE "+;
        "SW5.W5_FILIAL  = '"+xFilial("SW5")+"' AND "+;
        "SW5.D_E_L_E_T_ <> '*' AND "+;
        "SW5.W5_SEQ = 0 AND  SW5.W5_SALDO_Q <> 0"
*/                                       

cQuery:="SELECT DISTINCT "+cCpos+" FROM " +RetSqlName("SW5") +" SW5 WHERE "+;
        "SW5.W5_FILIAL  = '"+xFilial("SW5")+"' AND "+;
        "SW5.D_E_L_E_T_ <> '*' AND "+;
        "SW5.W5_SEQ = 0 AND  SW5.W5_SALDO_Q <> 0"
        
cQuery:=ChangeQuery(cQuery)   
TcQuery cQuery ALIAS "SW5NEW" NEW
   
SW5NEW->(DBGOTOP())

DO WHILE !SW5NEW->(EOF())

   IncProc("Procesando S.I. num. "+SW5NEW->W5_PO_NUM)
   
   Work_PO->(DBAPPEND())
   Work_PO->W3_PO_NUM:=SW5NEW->W5_PO_NUM
   SW5NEW->(DBSKIP())

ENDDO
     
SW5NEW->(DBCLOSEAREA())
    
DBSELECTAREA(OldArea)

RETURN .T.
  
// MLS - Despesa - 06/2004 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
*----------------------------------------------------------------------------*
FUNCTION DI600Desp2() ////MLS
*----------------------------------------------------------------------------*
LOCAL aCoordenadas:={15,04,20,74,,.F.,  ,  ,  ,  ,21,04}
LOCAL nOldArea:=SELECT(), oDlg, oMark, oPanel2
//Local aSemSX3 := { {"RECNO", "N",10, 0} }
Local bAddWork := {|| TRB->(dbAppend()), DI600D_Grava("TRB") }

LOCAL cAlias:="SWD"
PRIVATE aSemSX3 := { {"RECNO", "N",10, 0} }
PRIVATE cNomeTemp :=""
PRIVATE lNaoAltera:=.T. //Para incluir uma Nova Despesa através do Botão F3
lSair:=.F.
If(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"DESPESA"),)
IF lSair
   RETURN .F.
EndIf                    

If !DI600PROG()
   Return .F.
EndIf

PRIVATE nOpcao
PRIVATE cPictValor:=X3Picture("WD_VALOR_R")
PRIVATE MSeguro, MImpostos, MAdiant, MOutras, MSaldos, MTot_Ger
PRIVATE aCpos
PRIVATE aCpos2

// *** Cria variaveis para E_CriaTrab ...
PRIVATE aCampos := Array(SWD->(FCount()))

PRIVATE aEnchoice := {"WD_HAWB","WD_DESPESA","WD_DESCDES","WD_DES_ADI",;
                      "WD_VALOR_R","WD_BASEADI","WD_DOCTO","WD_NF_COMP",;
                      "WD_SE_NFC","WD_VL_NFC","WD_DT_NFC","WD_PAGOPOR","WD_DA"}

PRIVATE lBaixaDesp:=.F.,lnoEnvFin:=.T., lAltForn:=.T. // Verifica se esta baixado a Despesa no financeiro

PRIVATE lCposNovosWD := ( SWD->(FieldPos("WD_SE_DOC"))  > 0 .AND. ;
                          SWD->(FieldPos("WD_TES"))     > 0 .AND. ;
                          SWD->(FieldPos("WD_MOEDA"))   > 0 .AND. ;
                          SWD->(FieldPos("WD_VALOR_M")) > 0 .AND. ;
                          SWD->(FieldPos("WD_TX_MOE"))  > 0 )
                          
IF lCposNovosWD
   AADD(aEnchoice, "WD_SE_DOC")
   AADD(aEnchoice, "WD_TES")
   AADD(aEnchoice, "WD_MOEDA")
   AADD(aEnchoice, "WD_VALOR_M")
   AADD(aEnchoice, "WD_TX_MOE") 
ENDIF

IF lFinanceiro
   AADD(aEnchoice,"WD_GERFIN")
   AADD(aEnchoice,"WD_DTENVF")
ENDIF

AADD(aEnchoice,"WD_FORN"  )
AADD(aEnchoice,"WD_LOJA"  )

IF SWD->(FIELDPOS("WD_FORNRAT")) # 0
   AADD(aEnchoice,"WD_FORNRAT")
ENDIF

PRIVATE aHeader := {}
PRIVATE aDeletados := {}

  
IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"MANUT_DESP"),)
/*
If ! SW6->(RecLock("SW6",.F.))
//   Help(" ",1,"REGNLOCK")
   DbSelectArea(nOldArea)
   Return
Endif
*/
cNomeTemp := E_CriaTrab(cAlias,aSemSX3)  // Criacao do arquivo de Trabalho

DBSELECTAREA("SWD")
SWD->(DBSETORDER(1))

// *** Grava arquivo de Trabalho ...
SWD->(dbSeek(xFilial()+SW6->W6_HAWB))
SWD->(dbEval(bAddWork,,{|| SWD->WD_FILIAL == xFilial("SWD") .And. SWD->WD_HAWB == SW6->W6_HAWB}))
// ***

SYB->(dbSetOrder(1))

PRIVATE oSeguro, oOutras, oImpostos, oAdiant, oTot_Ger, oSaldos

aCpos:= { {{|| TRB->WD_DESPESA+" "+if(SYB->(dbSeek(xFilial()+TRB->WD_DESPESA)),SYB->YB_DESCR,"")},,AVSX3("WD_DESPESA",5)},; 
          {"WD_DES_ADI",,AVSX3("WD_DES_ADI",5)       },; //"Data"
          {"WD_VALOR_R",,AVSX3("WD_VALOR_R",5),cPictValor  },; //"Valor R$"
          {{|| If(TRB->WD_BASEADI$cSim,STR0002,STR0003)},,AVSX3("WD_BASEADI",5)},; //"Adianta/o ?"
          {"WD_DOCTO"  ,,AVSX3("WD_DOCTO"  ,5)}} //"Documento"

IF SWD->(FieldPos("WD_SE_DOC")) > 0
   AADD( aCpos, { "WD_SE_DOC",, AVSX3("WD_SE_DOC",5)}) // EOS - Serie do docto
ENDIF

AADD(aCpos, {"WD_FORN"   ,,AVSX3("WD_FORN"   ,5)}) //"Fornecedor" 
AADD(aCpos, {"WD_LOJA"   ,,AVSX3("WD_LOJA"   ,5)}) //"Loja" 
AADD(aCpos, {"WD_NF_COMP",,AVSX3("WD_NF_COMP",5)}) //"Nota Fiscal"
AADD(aCpos, {"WD_SE_NFC" ,,AVSX3("WD_SE_NFC" ,5)}) //"Serie"
If lFinanceiro
   AADD(aCpos, {"WD_DTENVF",,AVSX3("WD_DTENVF",5)       } ) //"Data envio Fianceiro" 
Endif
AADD(aCpos, { {|| ALLTRIM(AVCOMBO("WD_DA",IF(EMPTY(TRB->WD_DA),"2",TRB->WD_DA)))},,AVSX3("WD_DA",5) } )

IF(EasyEntryPoint("EICDI600"),ExecBlock("EICDI600",.F.,.F.,"CAMPOS_WD"),)

//AAF 24/06/08 - Paramêtro para geração de titulos de despesas no financeiro
IF !EasyGParam("MV_EASYFDE",,.T.)
   EICFI400("ANT_TELA_DESP")
EndIf

dbSelectArea("TRB")
//MFR OSSME-1974 26/12/2018
IndRegua("TRB",cNomeTemp+TeOrdBagExt(),"WD_DOCTO+WD_DESPESA")
dbGoTop()

   nOpcao := 0

   oMainWnd:ReadClientCoords()
   SW2->(DBSETORDER(1))
   lAltDesp:=.t.
   IF MOpcao # FECHTO_NACIONALIZACAO .AND.;
      (Val(SW6->W6_TIPODES) >= 2 .And. Val(SW6->W6_TIPODES) <= 4) .AND.;
      SW2->(DBSEEK(xFilial("SW2")+"DA"+Trans(SW6->W6_DI_NUM,ALLTRIM(X3Picture("W6_DI_NUM"))))) .OR.;
      !EMPTY(SW6->W6_DT_ENCE)
      lAltDesp:=.f.
   EndIf
      
   If ! lAltDesp
      cTitJan:=STR0152+" - "+STR0004
   Else
      cTitJan:=STR0152
   EndIf

aCpos2:= {{"WD_DOCTO"  ,,AVSX3("WD_DOCTO"  ,5)},; 
          {"WD_SE_DOC" ,,AVSX3("WD_SE_DOC" ,5)},; //"Serie"
          {"WD_DT_EMIS",,AVSX3("WD_DT_EMIS",5)},; //"Data"
          {"WD_FORN"   ,,AVSX3("WD_FORN"   ,5)},; //"Fornecedor" 
          {"WD_LOJA"   ,,AVSX3("WD_LOJA"   ,5)},; //"Loja" 
          {{|| TRB->WD_DESPESA+" "+if(SYB->(dbSeek(xFilial()+TRB->WD_DESPESA)),SYB->YB_DESCR,"")},,AVSX3("WD_DESPESA",5)},;
          {"WD_VALOR_R",,AVSX3("WD_VALOR_R",5),cPictValor}} //"Valor R$"

   
    DEFINE MSDIALOG oDlg TITLE cTitJan ; //"Manuten‡Æo"
    FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom+80,oMainWnd:nRight-10;
    OF oMainWnd PIXEL  
        nAlt := 60 ; nLar := 45
        oPanel2 := tPanel():New(01,01,"",oDlg,,.T.,,,,nLar,nAlt)
        DI600D_Tela(.T.,oPanel2)

            nLin := 40
            nCol := COLUNA_FINAL-120
            @nLin,nCol BUTTON STR0031      SIZE 35,11 FONT oDlg:oFont ACTION (DI600Desp3(1),oMark:oBrowse:Refresh()) OF oDlg PIXEL //"Incluir"

            nCol := COLUNA_FINAL-80
            @nLin,nCol BUTTON STR0032      SIZE 35,11 FONT oDlg:oFont ACTION (DI600Desp3(2),oMark:oBrowse:Refresh()) OF oDlg PIXEL //"Alterar"

            nLin := 55
            nCol := COLUNA_FINAL-120
            @nLin,nCol BUTTON STR0153      SIZE 35,11 FONT oDlg:oFont ACTION (DI600Desp3(3),oMark:oBrowse:Refresh()) OF oDlg PIXEL //"Excluir"

            nCol := COLUNA_FINAL-80
            @nLin,nCol BUTTON "Visualizar" SIZE 35,11 FONT oDlg:oFont ACTION (DI600Desp3(5),oMark:oBrowse:Refresh()) OF oDlg PIXEL //"Visualizar"

        nLin := 60 ; nCol := 05 ; nAlt := (oDlg:nClientHeight-6)/2 ; nLar := COLUNA_FINAL
        oMark:=MSSELECT():New("TRB",,,aCPOS2,lInverte,cMarca,{nLin,nCol,nAlt,nLar }, , oDlg )//MLS
        oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT       

    ACTIVATE MSDIALOG oDlg ON INIT (DI600EnchoiceBar(oDlg,;
                                  {{||nOpcao:= 1,oDlg:End()},"OK"},;
                                   {||nOpcao:= 0,oDlg:End()},.F.),; //CENTERED
                                   oPanel2:Align:=CONTROL_ALIGN_TOP,oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT,;
                                   oMark:oBrowse:Refresh())//ER - 20/11/2007

EvalTrigger()
TRB->(E_EraseArq(cNomeTemp))
//TRB->(DBCLOSEAREA())

DBSELECTAREA(nOldArea)

SW6->(MSUnlock())

Return Nil


*----------------------------------------------------------------------------*
FUNCTION DI600Desp3(NOPCX)
*----------------------------------------------------------------------------*

Local aAreaPR        := GetArea()
Local aPosGet	     := {}
Local aSizeAut       := MsAdvSize(,.F.,400)
Local aObjects	     := {}
Local nI             := 0
Local nUSADO         := 0
Local cCadastro      := "Gastos"
local cNOMEFOR       := space(50)

Local aTitles	     := {OemToAnsi("Totales"),; //"Totais"
                         OemToAnsi("Inf. del Provedor"),; //"Inf. Fornecedor"
                         OemToAnsi("Impuestos"),; //"Frete/Despesas"
                         OemToAnsi("Cuentas por pagar") } //"Mensagem/Reajuste"

local aDialogs       := {"Totales","Inf.del Provedor","Impuestos","Cuentas por pagar"}

Local cAlias         := "SWD"

Local nPos2          := 0
Local cTES           := SPACE(03)
Local nPos           := 0
Local nVALR          := 0
Local aTab           := {}
Local nJ             := 0  
Local wIND           := 0
LOCAL NX             := 0
LOCAL nCnt           := 0 ,oPanel3,oDlg,oPanelG

Private bAtuTasa       := {|| nTasa := BuscaTaxa(AvKey(cMoeda,"YE_MOEDA"),dDataBase) }//,oTasa:Refresh() AWR - 20/08/2008

PRIVATE nMoedaCor    := 1
PRIVATE cCondicao    := ""

PRIVATE oFolder
PRIVATE aObj[21]	 // Array com os objetos utilizados no Folder
PRIVATE aObj2[2]     // Array 2 com objetos utilizados no Folder
PRIVATE oTASA

PRIVATE cMOEDA       := CriaVar("WD_MOEDA") //AAF 24/06/08 - Inicializar com moeda local.
PRIVATE cDOC         := CriaVar("WD_DOCTO")
PRIVATE cSER         := CriaVar("WD_SE_DOC")
PRIVATE cPROV        := SPACE(06)
PRIVATE cTIEN        := SPACE(03)
PRIVATE cCOND        := CriaVar("WD_COND")
PRIVATE cSTR         := SPACE(30)
PRIVATE dFECH        := dDataBase
PRIVATE DFAT         := dDataBase

PRIVATE oVLR
PRIVATE oVLR2
PRIVATE oVLRM
PRIVATE nVALOR       :=0
PRIVATE nVALORM      :=0
PRIVATE nTASA        :=0
PRIVATE aInfForn	 := {"","",CTOD(""),CTOD(""),"","",""}
PRIVATE aValores	 := {0,0,0,0,0,0,0,0,{{'','',0,0,0}}}
//PRIVATE aCOND        := {"","","",""}
PRIVATE lPRIM        :=.T.
PRIVATE nchk         := 0
PRIVATE nPOSchk      := 0
PRIVATE cDescMsg	 := ""
PRIVATE cDescFor     := ""

PRIVATE lBaixaDesp   := .F.,lnoEnvFin:=.T., lAltForn:=.T. // Verifica se esta baixado a Despesa no financeiro
PRIVATE l103Visual   := .F.
PRIVATE lCHKTES      := .F.
PRIVATE lCHKVAL      := .F.
PRIVATE nCHKVAL      := 0

Private aCols        := {}
Private aHeader  	 := {}
Private aRotina      := {{"Alterar", "AxAltera", 0, 4}}
private nopca
PRIVATE lCHKFC       :=.T.

PRIVATE cDOCANT      := SPACE(12)
PRIVATE cSERANT      := SPACE(03)
PRIVATE cHAWANT      := SPACE(15) 
PRIVATE cFORANT      := SPACE(03)
PRIVATE cLOJANT      := SPACE(02)
PRIVATE cNFCANT      := SPACE(15)
PRIVATE cSNFANT      := SPACE(03)
PRIVATE CSERCOM      := SPACE(30)
PRIVATE aHEADIMP     :={}
PRIVATE aCOLSIMP     :={}
PRIVATE aHEADFIN     :={}
PRIVATE aCOND        :={}

PRIVATE nPosDES      := 0
PRIVATE	nPosVAL      := 0
PRIVATE	nPosTES      := 0
                                 
//***ASK 21/01/2008 - Tratamento de Ingressos Brutos
Private cProvEnt     := SPACE(2) 
Private oCAI
Private cCAI         := SPACE(14)
Private dVenctoCAI   := CtoD("")

nopc  :=NOPCX
CPROC :=SPACE(17)
NOPCA :=NOPCX

IF nOPCA == 2  .OR. nOPCA == 3

   IF LEFT(TRB->WD_DESPESA,1) == "1"
      Help(" ",1,"E_DDFOBREG")//"E_FOBCIFNA")
      RETURN .F.
   ENDIF    

   IF !LEFT(TRB->WD_DESPESA,1) $ "2,9" .AND. !EMPTY(TRB->WD_NF_COMP)
      SF1->(DBSETORDER(1))
      IF SF1->(DBSEEK(xFILIAL()+TRB->WD_NF_COMP+TRB->WD_SE_NFC))
         DO WHILE !SF1->(EOF()) .AND. SF1->F1_FILIAL == xFilial("SF1")  .AND.;
                                      SF1->F1_DOC    == TRB->WD_NF_COMP .AND.;
                                      SF1->F1_SERIE  == TRB->WD_SE_NFC               

            IF SF1->F1_HAWB == SW6->W6_HAWB .AND. SF1->F1_TIPO_NF $ "9,A"
               Help("", 1, "AVG0000257")//Despesa nao pode ser alterada, pois o processo possui NF(s) de Entrada.
               RETURN .F.
            ENDIF

            SF1->(DBSKIP())   
         ENDDO   
      ENDIF

      SF2->(DBSETORDER(1))
      IF SF2->(DBSEEK(xFilial()+TRB->WD_NF_COMP+TRB->WD_SE_NFC+TRB->WD_FORN+TRB->WD_LOJA))
         Help("", 1, "AVG0000257")//Despesa nao pode ser alterada, pois o processo possui NF(s) de Entrada.
         RETURN .F.
      ENDIF

   ENDIF

ENDIF

DO CASE 

   CASE  nOPCA==1 //INCLUIR
         lINCLUIR := .T.
         lALTERAR := .F.
         lEXCLUIR := .F.
         cCadastro:="Gastos - Incluir "
         aRotina      := {{"Alterar", "AxAltera", 0, 4}}
   CASE  nOPCA==2 //MODIFICAR

         lINCLUIR := .F.
         lALTERAR := .T.
         lEXCLUIR := .F.
         cCadastro:="Gastos - Modificar "         
         aRotina      := {{"Alterar", "AxAltera", 0, 4}}
   CASE  nOPCA==3 //BORRAR

         IF TRB->WD_DESPESA == "101" .Or. TRB->WD_DESPESA == "104"
            Help(" ",1,"E_DDFOBREG")//"E_FOBCIFNA")
            RETURN .F.
         ENDIF    

         lINCLUIR := .F.
         lALTERAR := .F.
         lEXCLUIR := .T.
         cCadastro:="Gastos - Borrar "         
         aRotina      := {{"Alterar", "AxAltera", 0, 4}}
   CASE  nOPCA==5
         lINCLUIR := .F.
         lALTERAR := .F.
         lEXCLUIR := .F.
         cCadastro:="Gastos - Visualizar "         
         aRotina      := {{"Alterar", "AxAltera", 0, 2}}

END CASE   
/*
AADD(aHeadIMP,{ "Impuestos"  ,"Impuestos ","", 5,0,nil,nil,"C",nil,nil})
AADD(aHeadIMP,{         " %" ,         "%","@E 999.99", 5,2,nil,nil,"N",nil,nil})
AADD(aHeadIMP,{      "Base Moneda",    "Base Moneda","@E 9,999,999,999.99",15,3,nil,nil,"N",nil,nil})
AADD(aHeadIMP,{"Valor Moneda","Valor Moneda","@E 9,999,999,999.99",15,3,nil,nil,"N",nil,nil})
*/

//** AAF 25/06/08 - Para não dar erro no F3 da TES.
aAdd(aRotina,aRotina[1])
//**

M->uVar1 := M->uVar2 := M->uVar3 := M->uVar4 := M->uVar5 := M->uVar6 := M->uVar7 := M->uVar8 := ""

AADD(aHeadIMP,{"Impuestos"   ,"uVar1","", 5,0,nil,nil,"C",nil,nil})
AADD(aHeadIMP,{" %"          ,"uVar2","@E 999.99", 5,2,nil,nil,"N",nil,nil})
AADD(aHeadIMP,{"Base Moneda" ,"uVar3","@E 9,999,999,999.99",15,3,nil,nil,"N",nil,nil})
AADD(aHeadIMP,{"Valor Moneda","uVar4","@E 9,999,999,999.99",15,3,nil,nil,"N",nil,nil})

Aadd(aColsIMP,Array(5))
aColsIMP[1][5] := .F.
                    
AADD(aHeadFIN,{"Titulo","uVar5","",12,0,nil,nil,"C",nil,nil})
AADD(aHeadFIN,{"Cuota",      "uVar6","",01,0,nil,nil,"C",nil,nil})
AADD(aHeadFIN,{"Vencimiento","uVar7","@D",08,0,nil,nil,"D",nil,nil})
IF nOPCA==5
   AADD(aHeadFIN,{"Vlr. Titulo Moneda","uVar8","@E 9,999,999,999.99",15,3,nil,nil,"C",nil,nil})
ELSE
   AADD(aHeadFIN,{"Vlr. Titulo Moneda","uVar8","@E 9,999,999,999.99",15,3,nil,nil,"N",nil,nil})
ENDIF      

Aadd(aCOND,Array(5))
aCoND[1][5] := .F.


IF nOPCA==2 .OR. nOPCA==3 .OR. nOPCA==5
   
   cDOCANT  := TRB->WD_DOCTO
   cSERANT  := TRB->WD_SE_DOC
   cHAWANT  := SW6->W6_HAWB
   cFORANT  := TRB->WD_FORN
   cLOJANT  := TRB->WD_LOJA
   cNFCANT  := TRB->WD_NF_COMP
   cSNFANT  := TRB->WD_SE_NFC
   cCOND    := TRB->WD_COND
   dFECH    := TRB->WD_DT_EMIS
   DFAT     := TRB->WD_DT_NFC

   cHAWB    := SW6->W6_HAWB 
   cDOC     := TRB->WD_DOCTO
   cSER     := TRB->WD_SE_DOC
   cPROV    := TRB->WD_FORN
   cTIEN    := TRB->WD_LOJA
   cCOND    := TRB->WD_COND
   cMOEDA   := TRB->WD_MOEDA
   nTASA    := TRB->WD_TX_MOE
   cSERCOM  := ALLTRIM(TRB->WD_NF_COMP)+" / "+ALLTRIM(TRB->WD_SE_NFC)

   cNOMEFOR := POSICIONE("SA2",1,XFILIAL("SA1")+cPROV+cTIEN,"A2_NOME")

//***ASK 21/01/2008 - Tratamento de Ingressos Brutos
   IF lTemCAI 
      cProvEnt  := TRB->WD_PROVENT
      cCAI      := TRB->WD_CAI
      dVenctoCAI:= TRB->WD_VENCAI
   EndIF
   
ENDIF   

cAlias := "SWD"

SWD->(dbSelectArea( cAlias ))
SWD->(dbGoTop())
SX2->(DBSelectAREA("SX2"))
SX2->(DBSEEK(cAlias))
SX3->(DBSELECTAREA("SX3"))
SX3->(DBSEEK(cAlias))

nUsado := 0

While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == "SWD"

//IF SX3->X3_BROWSE =="S" 
	   IF ALLTRIM(SX3->X3_CAMPO) $ ("WD_DOCTO/WD_SE_DOC/WD_DTLANC/WD_FORN/WD_LOJA/WD_MOEDA/WD_TX_MOE/WD_VALOR_R/WD_CAI/WD_PROVENT/WD_VENCAI")
	      //
       ELSEIF ALLTRIM(SX3->X3_CAMPO) $ ("WD_DESPESA/WD_DESCDES/WD_BASEADI/WD_NATUREZ/WD_TES/WD_VALOR_M")
          nUsado := nUsado + 1
          IF     ALLTRIM(SX3->X3_CAMPO) == "WD_TES"
                 AADD(aHeader,{ AVSX3("WD_TES",5), SX3->X3_CAMPO, SX3->X3_PICTURE,;
				 SX3->X3_TAMANHO, SX3->X3_DECIMAL,'VAZIO() .OR. EXISTCPO("SF4",M->WD_TES) .AND. CHKTES(.T.) .and. ADI600FRefresh(aObj)',;//FDR - 24/01/13
				 SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO } )
          ELSEIF ALLTRIM(SX3->X3_CAMPO) == "WD_DESPESA"
                 AADD(aHeader,{ AVSX3("WD_DESPESA",5), SX3->X3_CAMPO, SX3->X3_PICTURE,;
                 SX3->X3_TAMANHO, SX3->X3_DECIMAL,'EXISTCPO("SYB",M->WD_DESPESA) .AND. CHKFOBCIF() .AND. CHKDESP()',;
                 SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO } )
          ELSEIF ALLTRIM(SX3->X3_CAMPO) == "WD_VALOR_M"
                 AADD(aHeader,{ AVSX3("WD_VALOR_M",5), SX3->X3_CAMPO, SX3->X3_PICTURE,;
                 SX3->X3_TAMANHO, SX3->X3_DECIMAL,'CHKFOBCIF().AND. ADI600FRefresh(aObj)',;
                 SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO } )
          ELSEIF SX3->X3_BROWSE == "S"
		         AADD(aHeader,{ AVSX3(ALLTRIM(SX3->X3_CAMPO),5), SX3->X3_CAMPO, SX3->X3_PICTURE,;
		         SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_VALID,;
		         SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO } )
		  ENDIF   
	   ENDIF	
//ENDIF
	
	SX3->(DBSkip())

EndDo
For nx	:= 1 to Len(aHeader)
	Do Case
	Case Alltrim(aHeader[nx][2])=="WD_DESPESA"
		nPosDES	:= nx
	Case AllTrim(aHeader[nx][2])=="WD_VALOR_M"
		nPosVAL:= nx
	Case AllTrim(aHeader[nx][2])=="WD_TES"
		nPosTES	:= nx
	EndCase
Next

IF NOPCA  == 1  //INCLUIR

   cHAWANT  := SW6->W6_HAWB
   Aadd(aCols,Array(nUsado+1))
   For nJ := 1 To nUsado

     	   aCols[1][nJ] := CriaVar(aHeader[nJ][2])
     
   Next

   aCols[1][nUsado+1] := .F.

ENDIF

IF NOPCA  <> 1  //INCLUIR

   DBSELECTAREA("SWD")
   SWD->(DBSETORDER(1))
   SWD->(DBSEEK(XFILIAL("SWD")+CHAWB))

   nCnt    :=0
   NVALOR  :=0
   NVALORM :=0
   
   DO While !SWD->(EOF()) .And. SWD->WD_HAWB==CHAWB //SW6->W6_HAWB

      IF CDOC==SWD->WD_DOCTO .AND. CSER==SWD->WD_SE_DOC .AND.;
         cFORANT == SWD->WD_FORN .AND. cLOJANT == SWD->WD_LOJA

        nCnt     := nCnt+1
        NVALOR   := NVALOR +SWD->WD_VALOR_R
        NVALORM  := NVALORM+SWD->WD_VALOR_M

      ENDIF   

      SWD->(DBSKIP())

   EndDo

   SWD->(DBSELECTAREA("SWD"))
   SWD->(DBSEEK(XFILIAL("SWD")+SW6->W6_HAWB))

   aCOLS := Array(nCnt,nUsado+1)
   nCnt  := 0

   DO While !SWD->(EOF()) .And. SWD->WD_HAWB==CHAWB//SW6->W6_HAWB

	   nUsado:=0

       IF CDOC==SWD->WD_DOCTO .AND. CSER==SWD->WD_SE_DOC .AND.;
         cFORANT == SWD->WD_FORN .AND. cLOJANT == SWD->WD_LOJA

	      nCnt   := nCnt+1

 	      SX3->(DBSELECTAREA("SX3"))
	      SX3->(DBSeek (cAlias))

	      DO While !SX3->(EOF()) .And. SX3->X3_ARQUIVO == cAlias

             IF ALLTRIM(SX3->X3_CAMPO) $ ("WD_DOCTO/WD_SE_DOC/WD_DTLANC/WD_FORN/WD_LOJA/WD_MOEDA/WD_TX_MOE/WD_VALOR_R")
                //CAMPOS CABEC
             ELSEIF ALLTRIM(SX3->X3_CAMPO) $ ("WD_DESPESA/WD_DESCDES/WD_BASEADI/WD_NATUREZ/WD_TES/WD_VALOR_M")
	                 nUsado := nUsado+1
                     IF SX3->X3_CAMPO=="WD_DESCDES" 
                        nPos := aScan(aHeader, { |x| Alltrim(x[2])=="WD_DESPESA"})
                        aCOLS[nCnt][nUsado] :=POSICIONE("SYB",1,XFILIAL("SYB")+aCOLS[nCnt][nPOS],"YB_DESCR")
                     ELSE
                        aCOLS[nCnt][nUsado] := &(cAlias+"->"+SX3->X3_CAMPO)
                     ENDIF   

             ENDIF    

		     SX3->(DBSkip())

	      EndDo

	      aCOLS[nCnt][nUsado+1] := .f. //Flag de Delecao
	      
	   ENDIF

	   SWD->(dbSelectArea( cAlias ))
	   SWD->(DBSkip())

   EndDo

   FOR NI := 1 TO LEN(aCOLS)
   
       nPos2 := aScan(aHeader, { |x| Alltrim(x[2])=="WD_TES"})
       If nPos2 > 0
         cTES  := aCols[nI][npos2]
       EndIf
       nPos  := aScan(aHeader, { |x| Alltrim(x[2])=="WD_VALOR_M"})
       If nPos > 0
         nVALR := aCols[nI][npos]   
       EndIf
       aTab  := CalcImpGer( cTES,,,nValr,,,,{},,nValR,.t.)
   
       For wind:=1 to len(aTab[6])
   
          IF EMPTY(aColsIMP[1][1])
   
       	     aColsIMP[1][1]  :=aTab[6,wind,1]
       	     aColsIMP[1][2]  :=aTab[6,wind,2]
       	     aColsIMP[1][3]  :=aTab[6,wind,3] //BASE IMPOSTO
             aColsIMP[1][4]  :=aTab[6,wind,4] 
             LINF :=.T.
   
          ENDIF

           NJ:= ASCAN( ACOLSIMP, { |TAB1| TAB1[1] == aTab[6,wind,1] } ) 
        
           IF NJ == 0
              IF aTab[6,wind,4] >0
                 AADD(aColsIMP, { aTab[6,wind,1] , aTab[6,wind,2] , aTab[6,wind,3] , aTab[6,wind,4] , .F. })
              ENDIF
       	   ELSE  
       	        IF LINF ==.F.
                   aColsIMP[NJ][3] :=aTab[6,wind,3]+(aColsIMP[NJ][3]) //BASE IMPOSTO
                   aColsIMP[NJ][4] :=aTab[6,wind,4]+(aColsIMP[NJ][4]) //VALOR IMPOSTO
                ENDIF   
           ENDIF       
        
           LINF :=.F.
       
       next WIND
   NEXT NI
   ADI600Forn(TRB->WD_FORN,TRB->WD_LOJA,@aInfForn,.F.)
ELSE
   TRB->( DBGOBOTTOM() )
   TRB->( DBSKIP())

ENDIF
IF NOPCA== 5 .OR.NOPCA== 3
     
      SE2->(DBSETORDER(6))
//    SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+cDOCANT))// "EIC"+aCOND[1][1]+ALLTRIM(STR(aCOND[1][2]))+"NF "+cFORANT+cLOJANT))
      SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+AvKey(cDOCANT,"E2_NUM")))   // RS - 24/03/06 COLOCADO AVKEY PARA AJUSTAR TAMANHO CAMPO COND. PAGTO

      IF SE2->(FOUND())

         DO WHILE .NOT. SE2->(EOF()) .AND. SE2->E2_FILIAL==xFILIAL("SE2") .AND. SE2->E2_FORNECE==cFORANT .AND. SE2->E2_LOJA==cLOJANT ;
                                     .AND. SE2->E2_PREFIXO == "EIC" .AND. SE2->E2_NUM==AvKey(cDOCANT,"E2_NUM")
             
             IF EMPTY(ACOND[1][1])
             
                ACOND[1][1] := SE2->E2_NUM
                ACOND[1][2] := SE2->E2_PARCELA
                ACOND[1][3] := SE2->E2_VENCTO
                ACOND[1][4] := SE2->E2_VALOR
                ACOND[1][5] := .F. 
               
             ELSE   
                AADD(ACOND,{SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_VENCTO,SE2->E2_VALOR,.F.})
             ENDIF   
         
             SE2->(DBSKIP())
         
         ENDDO   

      ENDIF
   
ENDIF



REGTOMEMORY("SWD",.F.)

aObjects := {}

AAdd( aObjects, { 0,    41, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 0,    75, .T., .F. } )

aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
           {{3,40,95,165,217,234,268},;
           {10,40,111,145,223,268,60},;
           {5,70,160,205,295},;
           {6,34,200,215},;
           {6,34,80,113,160,185},;
           {6,34,245,268,260},;
           {10,50,150,190},;
           {273,130,190},;
           {8,45,80,103,139,173,200,235,270},;
           {133,190,144,190,289,293},;
           {142,293,140},;
           {9,47,188,148,9,146} } )
OCDOC :=CDOC

//DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
DEFINE MSDIALOG oDlg TITLE cCadastro ;
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o cabecalho da rotina                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )-10             

//@ aPosObj[1][1],aPosObj[1][2] TO (aPosObj[1][3])+45,aPosObj[1][4] LABEL '' OF oDlg PIXEL

@ 00,00 MsPanel oPanel3 Prompt "" Size 10,65 of oDlg

oPanelG:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF-10/05/2017
oPanelG:Align:= CONTROL_ALIGN_TOP

nLin:=17

@ nLin,aPosGet[1,1] SAY OemToAnsi("Numero DOC")                                                   OF oPanelG PIXEL SIZE 045,010  
@ nLin,aPosGet[1,2] MSGET OcDOC     PICTURE PesqPict('SWD','WD_DOCTO')  WHEN(LINCLUIR);            
                    VALID ADI600Refresh(@aValores) OF oPanelG PIXEL SIZE 050,006
@ nLin,aPosGet[1,4] SAY OemToAnsi("Serie DOC")                                                    OF oPanelG PIXEL SIZE 060,010  
@ nLin,aPosGet[1,5] MSGET cSER     PICTURE PesqPict('SWD','WD_SE_NFC') WHEN(LINCLUIR);//.OR.LALTERAR
                    Valid()  OF oPanelG PIXEL SIZE 050,006
nLin+=12            
@ nLin,aPosGet[1,1] SAY OemToAnsi("Fecha Documento")                                              OF oPanelG PIXEL SIZE 050,010  
@ nLin,aPosGet[1,2] MSGET dFECH    PICTURE "@D"                        WHEN(LINCLUIR.OR.LALTERAR) OF oPanelG PIXEL SIZE 050,006
@ nLin,aPosGet[1,4] SAY OemToAnsi("Factura Generada em ")                                         OF oPanelG PIXEL SIZE 060,010  
@ nLin,aPosGet[1,5] MSGET dFAT     PICTURE "@D"                        WHEN EMPTY(cSERCOM)        OF oPanelG PIXEL SIZE 050,006

nLin+=12
@ nLin,aPosGet[1,1] SAY OemToAnsi("Proveedor+Tienda")                                              OF oPanelG PIXEL SIZE 050,010  
@ nLin,aPosGet[1,2] MSGET cPROV    PICTURE PesqPict('SWD','WD_FORN') F3 CpoRetF3('WD_FORN');
  				    Valid ADI600Forn(cPROV,"",@aInfForn) WHEN(LINCLUIR) OF oPanelG PIXEL SIZE 030,006//.OR.LALTERAR
@ nLin,aPosGet[1,2]+34 MSGET ctIEN PICT PesqPict('SWD','WD_LOJA') WHEN .F.                        OF oPanelG PIXEL SIZE 020,006
@ nLin,aPosGet[1,2]+56 MSGET aObj[5] VAR aInfForn[1] PICTURE PesqPict('SA2','A2_NOME') WHEN.F.    OF oPanelG PIXEL SIZE 105,006				   
@ nLin,aPosGet[1,4] SAY OemToAnsi("Numero/Serie")                                                 OF oPanelG PIXEL SIZE 060,010 
@ nLin,aPosGet[1,5] MSGET cSERCOM WHEN .F.                                                        OF oPanelG PIXEL SIZE 050,006
nLin+=12

@ nLin,aPosGet[1,1] SAY "Condicion de Pago"                                                          OF oPanelG PIXEL SIZE 050,006 
@ nLin,aPosGet[1,2] MSGET cCOND  F3 "SE4" VALID ADI600Cond(cCond) .AND. ADI600Refresh(@aValores) WHEN(LINCLUIR.OR.LALTERAR)  OF oPanelG PIXEL SIZE 050,006
@ nLin,aPosGet[1,4] SAY "Valor generado Moneda"                                                      OF oPanelG PIXEL SIZE 060,010  
@ nLin,aPosGet[1,5] MSGET oVLR2  VAR  aValores[VALR]   PICTURE PesqPict('SWD','WD_VALOR_M') WHEN .F. OF oPanelG PIXEL SIZE 050,006
nLin+=12

@ nLin,aPosGet[1,1] SAY "Moneda"                                                                   OF oPanelG PIXEL SIZE 045,006  
// @ nLin,aPosGet[1,2] MSGET cMOEDA F3 "SYE" VALID ADI600Refresh(@aValores)WHEN(LINCLUIR.OR.LALTERAR) OF oDlg PIXEL SIZE 050,006 PICTURE "@!"
//@ nLin,aPosGet[1,2] MSGET cMOEDA F3 "SYF" VALID (ADI600Refresh(@aValores).AND.(vazio() .or. ExistCpo("SYF",cMOEDA,1)),Eval(bAtuTasa));
@ nLin,aPosGet[1,2] MSGET cMOEDA F3 "SYF" VALID DI600Valid("WD_MOEDA") ;
                    WHEN(LINCLUIR.OR.LALTERAR) OF oPanelG PIXEL SIZE 050,006 PICTURE "@!"
If Empty(nTasa)
   If !EMPTY(cMoeda) .AND. cMoeda <> EasyGParam("MV_SIMB1",,"$")
      Eval(bAtuTasa)
   Else
      nTasa := 1
   Endif
EndIf
@ nLin,aPosGet[1,4] SAY OemToAnsi("Tasa de cotizacion")                                            OF oPanelG PIXEL SIZE 060,006  
@ nLin,aPosGet[1,5] MSGET oTASA VAR nTASA    PICTURE PesqPict('SYE','YE_VLCON_C') VALID ADI600Refresh(@aValores);
                    WHEN (LINCLUIR.OR.LALTERAR) .AND. cMoeda <> EasyGParam("MV_SIMB1",,"$") .AND. !Empty(cMoeda) OF oPanelG PIXEL SIZE 050,006
nLin+=12

//***ASK 21/01/2008 - Tratamento de Ingressos Brutos
If lTemCAI 

   @ nLin,aPosGet[1,1] SAY "Prov.Entrega" OF oPanelG PIXEL SIZE 045,006  
   @ nLin,aPosGet[1,2] MSGET cProvEnt F3 "12" VALID (Vazio() .or. ExistCpo("SX5","12"+cProvEnt));
                     WHEN(LINCLUIR.OR.LALTERAR) OF oPanelG PIXEL SIZE 050,006 PICTURE "@!"


   @ nLin,aPosGet[1,4] SAY "CAI" OF oPanelG PIXEL SIZE 060,006  
   @ nLin,aPosGet[1,5] MSGET oCAI VAR cCAI      PICTURE PesqPict('SWD','WD_CAI');
                       WHEN(LINCLUIR.OR.LALTERAR) OF oPanelG PIXEL SIZE 050,006 PICTURE "@!"
   nLin+=12

   @ nLin,aPosGet[1,1] SAY "Vencto" OF oPanelG PIXEL SIZE 045,006  
   @ nLin,aPosGet[1,2] MSGET dVenctoCAI  VALID IIF(!EMPTY(cCAI), dVenctoCAI>dDataBase,Vazio());
                       WHEN(LINCLUIR.OR.LALTERAR) OF oPanelG PIXEL SIZE 050,006 PICTURE "@D"

   nLin+=12                      
   
EndIf

nLin+=33 // MCF-16/05/2017
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a area da getdados da rotina                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDados := MSGetDados():New( nLin ,aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,'DI600LinOk','AllwaysTrue()',,.T.,,,,300,,,,'DI600Del')
oGetDados:oBrowse:Refresh()
oGetDados:oBrowse:bldblClick:={|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a area do rodape da rotina                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,{"HEADER"},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2]-3,aPosObj[3,3]-aPosObj[3,1],)

//acerto no folder para nao perder o foco
/*
For nX := 1 to Len(oFolder:aDialogs)
	DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
Next nX
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder dos totais da rotina                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder:aDialogs[1]:oFont := oDlg:oFont
@ 006,aPosGet[3,1] SAY OemToAnsi("Valor Total Moneda")      OF oFolder:aDialogs[1] PIXEL SIZE 055,009 // "Valor da Mercadoria"
@ 005,aPosGet[3,2] MSGET oVLR   VAR  aValores[VALR]  PICTURE PesqPict('SWD','WD_VALOR_R',17) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
@ 026,aPosGet[3,1] SAY OemToAnsi("Valor Total $") OF oFolder:aDialogs[1] PIXEL SIZE 055,009 // "Valor da Mercadoria"
@ 025,aPosGet[3,2] MSGET oVLRM  VAR  aValores[VALM]  PICTURE PesqPict('SWD','WD_VALOR_R',17) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
@ 043,003 TO 46 ,aPosGet[3,5] LABEL '' OF oFolder:aDialogs[1] PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder com as informacoes do fornecedor                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder:aDialogs[2]:oFont := oDlg:oFont
@ 006,aPosGet[4,1] SAY OemToAnsi("Nome")                OF oFolder:aDialogs[2] PIXEL SIZE 037,009 // "Nome"
@ 005,aPosGet[4,2] MSGET aObj[5] VAR aInfForn[1] PICTURE PesqPict('SA2','A2_NOME');
                   WHEN.F.                              OF oFolder:aDialogs[2] PIXEL SIZE 159,009
@ 006,aPosGet[4,3] SAY OemToAnsi("Tel.")                OF oFolder:aDialogs[2] PIXEL SIZE 023,009 // "Tel."
@ 005,aPosGet[4,4] MSGET aObj[6] VAR aInfForn[2];
	               WHEN .F.                             OF oFolder:aDialogs[2] PIXEL SIZE 074,009
@ 043,aPosGet[5,1] SAY OemToAnsi("1a Compra")           OF oFolder:aDialogs[2] PIXEL SIZE 032,009 // "1a Compra"
@ 042,aPosGet[5,2] MSGET aObj[7] VAR aInfForn[3] PICTURE PesqPict('SA2','A2_PRICOM') ;
                   WHEN .F.                             OF oFolder:aDialogs[2] PIXEL SIZE 040,009
@ 043,aPosGet[5,3] SAY OemToAnsi("Ult. Compra")         OF oFolder:aDialogs[2] PIXEL SIZE 036,009 // "Ult. Compra"
@ 042,aPosGet[5,4] MSGET aObj[8] VAR aInfForn[4] PICTURE PesqPict('SA2','A2_ULTCOM');
                   WHEN .F.                             OF oFolder:aDialogs[2] PIXEL SIZE 040,009
@ 43 ,aPosGet[5,5] SAY RTrim(RetTitle("A2_CGC"))        Of oFolder:aDialogs[2] PIXEL SIZE 31 ,009 // "CNPJ / CPF"
@ 42 ,aPosGet[5,6] MSGET aObj[21] VAR aInfForn[7] Picture PesqPict('SA2','A2_CGC');
	               WHEN .F.                             OF oFolder:aDialogs[2] PIXEL SIZE 76 ,9
@ 024,aPosGet[6,1] SAY OemToAnsi("Endereco")            OF oFolder:aDialogs[2] PIXEL SIZE 049,009 // "Endereco"
@ 023,aPosGet[6,2] MSGET aObj[9] VAR aInfForn[5]  PICTURE PesqPict('SA2','A2_END');
                   WHEN .F.                             OF oFolder:aDialogs[2] PIXEL SIZE 205,009
@ 024,aPosGet[6,3] SAY OemToAnsi("Estado")              OF oFolder:aDialogs[2] PIXEL SIZE 032,009 // "Estado"
@ 023,aPosGet[6,4] MSGET aObj[10] VAR aInfForn[6]  PICTURE PesqPict('SA2','A2_EST');
                   WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 021,009
//@ 042,aPosGet[6,5] BUTTON OemToAnsi("Mais Inf.") SIZE 030,010  FONT oDlg:oFont ACTION A120ToFC030()  OF oFolder:aDialogs[2] PIXEL // "Mais Inf."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Folder do resumo de impostos                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder:aDialogs[3]:oFont := oDlg:oFont
//oCtaPagIMP := (MsNewGetDados():New(004,150,058,450,IIF(.T.,GD_INSERT+GD_UPDATE+GD_DELETE,0) ,/*"NfeLOkSE2"*/,/*"NfeTOkSE2"*/,/*inicpos*/,/*aCpoHead*/,/*freeze*/,120,/*fieldok*/,/*superdel*/,/*delok*/,oFolder:aDialogs[3],aHeadIMP,aColsIMP)) 
oCtaPagIMP := (MsNewGetDados():New(004,10,058,300,4,"AllwaysTrue()","AllwaysTrue()",,{},/*freeze*/,120,/*fieldok*/,/*superdel*/,/*delok*/,oFolder:aDialogs[3],aHeadIMP,aColsIMP))
oCtaPagIMP:oBrowse:REFRESH()
oCtaPagIMP:oBrowse:bldblClick:={|| .T. }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder do Financeiro                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
oFolder:aDialogs[4]:oFont := oDlg:oFont			
oCtaPagFIN := (MsNewGetDados():New(004,010,058,300,4,"AllwaysTrue()","AllwaysTrue()",,{},/*freeze*/,120,/*fieldok*/,/*superdel*/,/*delok*/,oFolder:aDialogs[4],aHeadFIN,aCOND)) 
oCtaPagFIN:oBrowse:REFRESH()
oCtaPagFIN:oBrowse:bldblClick:={|| .T. }
*****************************************************************************************

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"TELA"),)

ADI600Refresh(@aValores) // AWR 

oDlg:lMaximized:=.T.

IF lIncluir .OR. lAlterar
   bOK:={|| If( DI6EXISTNF(cDOC,cSER,CPROV,CTIEN) .AND. DI600TudOk() , oDlg:End() , ) }
ELSEIF lExcluir
   bOK:={|| If( DI600TudOk() , oDlg:End() , ) }
ELSE
   bOK:={|| .T. }
ENDIF

ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,bOK,{|| oDlg:End()}) , oPanel3:Align:=CONTROL_ALIGN_TOP,/*oGetDados:oBrowse:Align:=CONTROL_ALIGN_TOP*/) //ASK 21/01/2008

DI600D_Tela()

IF SW6->(FIELDPOS("W6_STATUS")) # 0 //.AND. SIX->(DBSEEK("SF16")) .AND. FINDFUNCTION("DI156COND")
   DI156COND()
ENDIF

RestArea(aAreaPR)

RETURN .T.

*----------------------------------------------------------------------------*
Function ADI600FRefresh(aObj)
*----------------------------------------------------------------------------*
Local aArea	:= GetArea()
LOCAL NI    := 0
LOCAL NVLR1 := 0
local lsair :=.f.
LOCAL ExpA1 
LOCAL aCONDTMP := {}

IF NOPCA <> 5 .AND. NOPCA <> 3 //VISUALIZACAO
   nValor      := 0
   nvalorTit   := 0  //TRP-18/10/07
   nPos        := aScan(aHeader, { |x| Alltrim(x[2])=="WD_VALOR_M"})
   nPOSD       := aScan(aHeader, { |x| Alltrim(x[2])=="WD_DESPESA"})
   nPosTes     := aScan(aHeader, { |x| Alltrim(x[2])=="WD_TES"})
   cDESP       := acols[n,nPosd]
   NVLR1       := M->WD_VALOR_M
   NPOS2       := n

	
   FOR NI := 1 TO LEN(ACOLS)

     //FDR - 23/01/2013
     // Atualiza o array com o valor correto da TES, porque o calculo da funcao DI600CHKTES utiliza o acols e tem o valor da TES antiga
      IF N == NI .And. readvar() == "M->WD_TES" 
         aCols[NI][nPosTes]:=&(readvar())
      ENDIF

      If N == NI .And. readvar() == "M->WD_VALOR_M"
         NVLR1 := M->WD_VALOR_M
      Else
         NVLR1 := acols[NI,nPos] 
      EndIf

      If nPosTes > 0    
         SF4->(DbSetOrder(1))  //TRP-18/10/07
         SF4->(DBSeek(xFilial("SF4")+aCols[NI][nPosTes]))  //TRP-18/10/07
      EndIf
      If !aCols[NI][Len(aCols[NI])]
         IF CDESP == acols[NI,nPosD]  .AND. CDESP <> "101" .AND. CDESP <> "104"
            nValor+=NVLR1
            If nPosTes > 0
               nValor+=DI600CHKTES( aCols[NI][nPosTes] , nVLR1 )
            EndIf
            CDESP :="   "
            lCHKVAL :=.T.
            nCHKVAL  :=NVLR1
            IF nPosTes > 0 .And. !SF4->F4_DUPLIC == "N" //TRP-18/10/07- Se o campo Gera Título no cadastro da TES estiver como Sim, 
               nValorTit+=nVLR1       //TRP-18/10/07- acumula valor da despesa na variável nValorTit, para ser mostrado no contas a pagar no financeiro.
               nValorTit+=DI600CHKTES( aCols[NI][nPosTes] , nVLR1 ) //TRP-18/10/07  
            Else 
               Loop 
            Endif   
          
         ELSE
            nValor+=acols[NI,nPos]
            If nPosTes > 0    
               nValor+=DI600CHKTES( aCols[NI][nPosTes] , acols[NI,nPos] )
            EndIf 
            IF nPosTes > 0 .And. !SF4->F4_DUPLIC == "N"     //TRP-18/10/07- Se o campo Gera Título no cadastro da TES estiver como Sim,
               nValorTit+=acols[NI,nPos]  //TRP-18/10/07- acumula valor da despesa na variável nValorTit, para ser mostrado no contas a pagar no financeiro.
               nValorTit+=DI600CHKTES( aCols[NI][nPosTes] , acols[NI,nPos] ) //TRP-18/10/07
            Else 
               Loop  
            Endif   
             
         ENDIF   
      ENDIF
   NEXT NI

//   nVALORm         := nTASA*nvalor
//   aValores[VALR]  := nVALOR
//   aValores[VALM]  := nVALORm // POR LDR 12/08/04 
   
   nVALORm         := nTASA*nvalor
   aValores[VALM]  := nVALORm          
   aValores[VALR]  := nValor
     
   oVLR:REFRESH()
   oVLR2:REFRESH()
   oVLRM:REFRESH()

   //ExpA1 := Condicao(nVALOR,cCOND,,DATE()) //TRP-18/10/07
   ExpA1 := Condicao(nValorTit,cCOND,,DATE()) //TRP-18/10/07

   FOR NI := 1 TO LEN(EXPA1)
       AADD(ACONDTMP,{OcDOC,NI,EXPA1[NI][1],EXPA1[NI][2],.F.})
   NEXT NI    

   ACOND := ACONDTMP

   oCtaPagFIN:ACOLS:=ACOND
   oCtaPagFIN:oBrowse:REFRESH()
   lCHKTES :=.F.
   CHKTES(.F.)


   oGetDados:oBrowse:Refresh()
   RestArea(aArea)
   
ENDIF

Return .T.
                        
*----------------------------------------------------------------------------*
Function ADI600Forn(cFornece,cCodLoja,aInfForn,lAtuInfo)
*----------------------------------------------------------------------------*
Local aArea	:= GetArea()
Local lRet  := .F.

DEFAULT lAtuInfo := .T.

If !Empty(cFornece)
   If Empty(cCodLoja)
      SA2->(dbSetOrder(1))
	  If (cFornece == SA2->A2_COD) .OR. SA2->(DBSeek(xFilial("SA2")+cFornece))
	     CTIEN := SA2->A2_LOJA
		 lRet := .T.
	  EndIf
   Else
      SA2->(dbSetOrder(1))
      If SA2->(DBSeek(xFilial("SA2")+cFornece+cCodLoja))
         lRet := .T.
	  EndIf
   EndIf
   if !lRet
      MSGINFO("Proveedor no registrado.")
      RETURN .F.
   EndIf
ELSE
   MSGINFO("Proveedor no llenado.")
   RETURN .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o array que contem os dados do Fornecedor      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. aInfForn != Nil
	
	aInfForn[1]	:= SA2->A2_NOME						// Nome
	aInfForn[2] := IIF(!Empty(SA2->A2_DDI),"( "+TransForm(SA2->A2_DDI,PesqPict("SA2","A2_DDI"))+") ","");
	               +TransForm(alltrim(SA2->A2_DDD),PesqPict("SA2","A2_DDD"))+" "+TransForm(SA2->A2_TEL,PesqPict("SA2","A2_TEL")) // Telefone
	aInfForn[3]	:= SA2->A2_PRICOM	    			//Primeira Compra
	aInfForn[4] := SA2->A2_ULTCOM      				//Ultima Compra
	aInfForn[5]	:= SA2->A2_END+" - "+SA2->A2_MUN	//Endereco
	aInfForn[6]	:= SA2->A2_EST         				//Estado
	aInfForn[7]	:= SA2->A2_CGC         				//cnpj

	If lAtuInfo
		cCondicao 	:= SA2->A2_COND
		cContato	:= SA2->A2_CONTATO
	EndIf
	
EndIf

RestArea(aArea)

Return lRet

*----------------------------------------------------------------------------*
Function ADI600Refresh(aValores)
*----------------------------------------------------------------------------*
Local aArea	   := GetArea()
LOCAL NI       := 0
LOCAL ExpA1 
LOCAL aCONDTMP := {}
 
nVALOR         := 0
nValorTit      := 0 //TRP-18/10/07
nPosVal        := aScan(aHeader, { |x| Alltrim(x[2])=="WD_VALOR_M"})
nPosTes        := aScan(aHeader, { |x| Alltrim(x[2])=="WD_TES"})

If nPosVal > 0 .And. nPosTes > 0
   FOR NI := 1 TO LEN(ACOLS)
      
      SF4->(DbSetOrder(1))  //TRP-18/10/07
      SF4->(DBSeek(xFilial("SF4")+aCols[NI][nPosTes]))  //TRP-18/10/07
      
      If !aCols[NI][Len(aCols[NI])]
         //nValor+=acols[NI,nPos]
         nValor+=acols[NI,nPosVal]
         nValor+=DI600CHKTES( aCols[NI][nPosTes] , acols[NI,nPosVal] )
         IF !SF4->F4_DUPLIC == "N"  //TRP-18/10/07- Se o campo Gera Título no cadastro da TES estiver como Sim,
            nValorTit+=acols[NI,nPosVal]  //TRP-18/10/07- acumula valor da despesa na variável nValorTit, para ser mostrado no contas a pagar no financeiro.
            nValorTit+=DI600CHKTES( aCols[NI][nPosTes] , acols[NI,nPosVal] )  //TRP-18/10/07 
         Else 
            Loop 
         Endif   
      ENDIF   
   NEXT NI    
EndIf

nVALORm:=nTASA*nvalor

aValores[VALR]	:= nVALOR
aValores[VALM] 	:= nVALORm

oVLR:REFRESH()
oVLR2:REFRESH()
oVLRM:REFRESH()

RestArea(aArea)

//IF NOPCA <> 5 .AND. NOPCA <> 3 // VISUALIZAR BORRAR  	  
   //ExpA1 := Condicao(nVALOR,cCOND,        ,DATE(), , )  //TRP-18/10/07
   ExpA1 := Condicao(nValorTit,cCOND,        ,DATE(), , ) //TRP-18/10/07

   FOR NI := 1 TO LEN(EXPA1)
       AADD(ACONDTMP,{OcDOC,NI,EXPA1[NI][1],EXPA1[NI][2],.F.})
   NEXT NI    

   ACOND := ACONDTMP

   oCtaPagFIN:ACOLS:=ACOND
   oCtaPagFIN:oBrowse:REFRESH()
   lCHKTES :=.F.
   CHKTES(.F.)
   
//ENDIF

Return .T.

*----------------------------------------------------------------------------*
FUNCTION DI600LINOK()
*----------------------------------------------------------------------------*
Local cRet     :=.T. 
LOCAL cTEXTO   := SPACE(01)

PRIVATE cCAMPO :=SPACE(10)

IF  nOpca ==1 .or. nOpca==2
   If !aCols[n][Len(aCols[n])]  // Verifica se esta deletado
      IF Empty(aCols[n][nPosDES])
         cTEXTO:=ALLTRIM(cTEXTO+"Gasto Vazio "+Chr(13)+Chr(10))
         cret:=.f.
      ENDIF
      IF Empty(aCols[n][nPosVAL])
         cTEXTO:=ALLTRIM(cTEXTO+"Valor Vazio "+Chr(13)+Chr(10))
         cret:=.f.
      ENDIF
         IF Empty(aCols[n][nPosTES])
         cTEXTO:=ALLTRIM(cTEXTO+"TES Vazio "+Chr(13)+Chr(10))
         cret:=.f.
      ENDIF
      IF CRET==.F. 
         MSGINFO(CTEXTO)
      ENDIF   
    ENDIF
ENDIF       

RETURN cRET

*-------------------------------------------------------
FUNCTION DI600TUDOK()
*------------------------------------------------------
Local nJ,nI
Local cRet      := .T. 
LOCAL cTEXTO    := SPACE(01)
Local lGRVSE2   := .F.
//Local nChr		:= Asc(Alltrim(EasyGParam("MV_1DUP"))) - 1
LOCAL NPARCELA  := 0
LOCAL cPARCELA  := SPACE(01)
LOCAL cPARCELAS := ""
Local nMoedaCor	:= 1
Local cNatureza := ""
Private cUltParc := ""   // GFP - 20/01/2014

IF  nOpca ==1 .or. nOpca==2

   IF EMPTY(OcDOC)
      cTEXTO :=ALLTRIM(cTEXTO+"Numero DOC no llenado"+Chr(13)+Chr(10))
      cRET   :=.f.
   ENDIF

   IF EMPTY(DFECH)   
      cTEXTO:=ALLTRIM(cTEXTO+"Fecha DOC no llenado"+Chr(13)+Chr(10))
      cRET  :=.f.
   ENDIF

   IF EMPTY(cprov)   
      cTEXTO:=ALLTRIM(cTEXTO+"Proveedor no llenado"+Chr(13)+Chr(10))
      cret:=.f.
   ENDIF
  
   IF EMPTY(ccond)   
      cTEXTO:=ALLTRIM(cTEXTO+"Condicion de Pago no llenado")
      cret:=.f.
   ENDIF
  
   IF CRET==.F.
      MSGINFO(CTEXTO)
      RETURN .F. 
   ENDIF   

   IF Empty(aCols[n][nPosDES]) //CCH - 08/04/2009 - Valida campos quando pressionado o botão OK
      cTEXTO:=ALLTRIM(cTEXTO+"Gasto Vazio "+Chr(13)+Chr(10))
      cRet:=.f.
   ENDIF
   
   IF Empty(aCols[n][nPosVAL])
      cTEXTO:=ALLTRIM(cTEXTO+"Valor Vazio "+Chr(13)+Chr(10))
      cRet:=.f.
   ENDIF
   
   IF nPosTES > 0 .And. Empty(aCols[n][nPosTES])
      cTEXTO:=ALLTRIM(cTEXTO+"TES Vazio "+Chr(13)+Chr(10))
      cRet:=.f.
   ENDIF
   
   IF CRET==.F. 
      MSGINFO(CTEXTO)
   ENDIF   
ENDIF   

//TRP 20/11/2007 - Verifica se a data de encerramento do processo está preenchida.
                // Caso esteja, não permite incluir/alterar/excluir despesas.
IF  nOpca ==1 .or. nOpca==2 .or. nOpca==3
   IF !EMPTY(SW6->W6_DT_ENCE)  
      MsgInfo("Este proceso ya está cerrado, no si puede modificar gastos.")   
      cRET := .F.
   ENDIF
ENDIF
SE2->(DBSETORDER(6))
//SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+aCOND[1][1]))// "EIC"+aCOND[1][1]+ALLTRIM(STR(aCOND[1][2]))+"NF "+cFORANT+cLOJANT))

SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+AvKey(cDOCANT,"E2_NUM")))   // RS - 24/03/06 COLOCADO AVKEY PARA AJUSTAR TAMANHO CAMPO COND. PAGTO
IF SE2->(FOUND())
   DO WHILE .NOT. SE2->(EOF()) .AND. SE2->E2_FILIAL==xFILIAL("SE2") .AND. SE2->E2_FORNECE==cFORANT .AND. SE2->E2_LOJA==cLOJANT ;
                               .AND. SE2->E2_PREFIXO == "EIC" .AND. SE2->E2_NUM==AvKey(cDOCANT,"E2_NUM")
      IF SE2->E2_SALDO < SE2->E2_VALOR
         MSGINFO("Titulo "+SE2->E2_NUM+" Cota "+SE2->E2_PARCELA+" Cancel.") 
         RETURN .F. 
      ENDIF
      SE2->(DBSKIP())
   ENDDO                                    
ENDIF

IF cRET ==.T.  .AND.  nOpcA <> 3

   IF nOpcA <> 1 
   
//    SWD->(INDREGUA("SWD","TEMPSWD","WD_FILIAL+WD_DOCTO+WD_SE_DOC+WD_HAWB+WD_FORN+WD_LOJA"))
//    SWD->(DBSEEK(XFILIAL("SWD")+cDOCANT +cSERANT +cHAWANT+cFORANT+cLOJANT))
      If SIX->(DBSeek("SWD6"))
         SWD->(DBSETORDER(6))//WD_FILIAL+WD_DOCTO+WD_FORN+WD_LOJA
      Else
         SWD->(DBSETORDER(4))//WD_FILIAL+WD_DOCTO
      EndIf
      IF SWD->(DBSEEK(XFILIAL("SWD")+cDOCANT+cFORANT+cLOJANT))

         DO WHILE SWD->(!EOF()) .AND. XFILIAL("SWD")==SWD->WD_FILIAL  .AND. cDOCANT==SWD->WD_DOCTO;
                                .AND. cFORANT==SWD->WD_FORN    .AND. cLOJANT==SWD->WD_LOJA

            IF cSERANT # SWD->WD_SE_DOC .OR. cHAWANT # SWD->WD_HAWB
               SWD->(DBSKIP())
               LOOP
            ENDIF

            SWD->(RECLOCK("SWD",.F.))
            SWD->(DBDELETE())
            SWD->(MSUNLOCK())
            SWD->(DBSKIP())
            
         ENDDO  

      ENDIF     
      
   ENDIF  
  
   FOR nJ  := 1 TO Len(aCols)
     
       If !aCols[nJ][Len(aCols[nJ])] 
          
          SWD->(RECLOCK("SWD",.T.))
       
          SWD->WD_FILIAL  := XFILIAL("SWD")
          SWD->WD_HAWB    := cHAWANT
          SWD->WD_DOCTO   := oCDOC
          SWD->WD_SE_DOC  := CSER
          SWD->WD_FORN    := CPROV
          SWD->WD_LOJA    := CTIEN
          SWD->WD_MOEDA   := CMOEDA
          SWD->WD_TX_MOE  := NTASA
//        SWD->WD_VALOR_M := oVLRM
          SWD->WD_COND    := cCOND
          SWD->WD_DT_EMIS := dFECH
          SWD->WD_DT_NFC  := DFAT
          SWD->WD_NF_COMP := cNFCANT
          SWD->WD_SE_NFC  := cSNFANT
          If lTemCAI
             SWD->WD_CAI     := cCAI
             SWD->WD_VENCAI  := dVenctoCAI
             SWD->WD_PROVENT := cProvEnt
          EndIf
       
          For nI := 1 to Len(aHeader)
          
              IF (ALLTRIM(AHEADER[NI][2])) <> "WD_DOCTO"   .AND. (ALLTRIM(AHEADER[NI][2])) <> "WD_SE_DOC"  .AND. (ALLTRIM(AHEADER[NI][2])) <> "WD_FORN"    .AND. (ALLTRIM(AHEADER[NI][2])) <> "WD_LOJA" .AND. ;
                 (ALLTRIM(AHEADER[NI][2])) <> "WD_MOEDA"   .AND. (ALLTRIM(AHEADER[NI][2])) <> "WD_TX_MOE"  .AND. (ALLTRIM(AHEADER[NI][2])) <> "WD_COND" .AND. ;//(ALLTRIM(AHEADER[NI][2])) <> "WD_VALOR_M" .AND. 
                 (ALLTRIM(AHEADER[NI][2])) <> "WD_DT_EMIS" .AND. (ALLTRIM(AHEADER[NI][2])) <> "WD_NF_COMP" .AND. (ALLTRIM(AHEADER[NI][2])) <> "WD_SE_NFC"  .AND. (ALLTRIM(AHEADER[NI][2])) <> "WD_HAWB"
              
                 cCAMPO := "SWD->"+(ALLTRIM(AHEADER[NI][2]))
                
                 IF CCAMPO <> "SWD->WD_DESCDES"
                    &(cCAMPO)  :=  aCOLS[nj][nI]     //("SWD->"+(ALLTRIM(AHEADER[NI][2])))
                 ENDIF   
                 
              ENDIF   
              
          NEXT nI
          SWD->WD_VALOR_R := SWD->WD_VALOR_M * IF( EMPTY(SWD->WD_TX_MOE) , 1 , SWD->WD_TX_MOE)//AWR -13/8/2004
          
          SWD->(MSUNLOCK())
          
       ENDIF   
       
   Next nJ    
   
   If EasyGParam("MV_EASYFDE",,.T.)
   SE2->(DBSETORDER(1))
   FOR NI := 1 TO LEN(aCOND)
       nParcela:=aCOND[nI][2]
 	   cParcela := EasyGetParc(nParcela) // GFP - 20/01/2014   //Chr(nChr + nParcela)
//       SE2->(DBSEEK(xFILIAL("SE2")+"EIC"+aCOND[nI][1]+cParcela+"NF "+cFORANT+cLOJANT))
       SE2->(DBSEEK(xFILIAL("SE2")+"EIC"+AvKey(aCOND[nI][1],"E2_NUM")+cParcela+"NF "+cFORANT+cLOJANT))   // RS - 24/03/06 - USO DA AVKEY
       
       IF lFoundSE2 := SE2->(FOUND())
          IF SE2->E2_SALDO < SE2->E2_VALOR
             // TITULO BAIXADO 
             lGRVSE2:=.F.
          ELSE
             //SE2->(RECLOCK("SE2",.F.))   
             lGRVSE2:=.T.
          ENDIF
       ELSE
          lGRVSE2:=.T.
       ENDIF     
       
          //AAF 24/06/08 - Inicialização da Moeda Local
          If Empty(cMoeda)
             cMoeda := EasyGParam("MV_SIMB1",,"$")
          EndIf
       //ASK 28/09/2007 - Geração dos títulos das despesas do desembaraço de acordo com o WD_MOEDA e se estiver config. no MV_SIMB??
       nMoedSubs := SimbToMoeda(cMoeda)
       IF nMoedSubs == 0
          MSGSTOP(STR0553 + cMoeda + STR0554)//"Nao e possivel a geracao do titulo! A moeda: "" nao esta configurada no Financeiro!"
          lGRVSE2 := .F.
       Else
          lGRVSE2 := .T.
       EndIf
       
       IF lGRVSE2==.T.
            SE2->(RECLOCK("SE2",!lFoundSE2))   
            nParcela:=aCOND[nI][2]
    		
    		cParcela := EasyGetParc(nParcela) // GFP - 20/01/2014   ////Chr(nChr + nParcela)
    		
    		If SWD->(FieldPos("WD_NATUREZ")) > 0 
	           If !Empty(SWD->WD_NATUREZ)
		          cNatureza := SWD->WD_NATUREZ
		       EndIf
            EndIf

            cNatureza:=IF(EMPTY(cNatureza),SA2->A2_NATUREZ,cNatureza) 
            
         	SE2->E2_FILIAL  	:= xFilial("SE2")
			SE2->E2_EMISSAO 	:= dFECH
			SE2->E2_EMIS1	    := dFECH
			SE2->E2_FORNECE 	:= cPROV
			SE2->E2_NOMFOR 	    := POSICIONE("SA2",1,XFILIAL("SA2")+cPROV+cTIEN,"A2_NOME")
			SE2->E2_LOJA    	:= cTIEN
			SE2->E2_PREFIXO 	:= "EIC"
			SE2->E2_TIPO    	:= "NF "
		    //SE2->E2_MOEDA   	:= nMoedaCor
            SE2->E2_MOEDA       := nMoedSubs
			SE2->E2_NUM     	:= aCOND[nI][1]
			SE2->E2_PARCELA 	:= cParcela
			SE2->E2_VENCORI     := aCOND[nI][3]
			SE2->E2_VENCTO      := aCOND[nI][3]
			SE2->E2_VENCREA     := DataValida(aCOND[nI][3],.T.)
			SE2->E2_VALOR   	:= aCOND[nI][4]


            IF !Empty(nTASA) 
               SE2->E2_VLCRUZ := (SE2->E2_VALOR * nTASA)
            ELSE               
               SE2->E2_VLCRUZ := xMoeda(aCOND[nI][4],nMoedaCor,1,dFECH,,nTASA)               
            ENDIF

            SE2->E2_TXMOEDA 	:= nTASA							
			SE2->E2_SALDO   	:= aCOND[nI][4]
			SE2->E2_NATUREZ     := cNatureza                          
			SE2->E2_OCORREN 	:= CriaVar("E2_OCORREN")
			SE2->E2_ORIGEM  	:= "SIGAEIC"
			SE2->E2_HIST    	:= "PROC. "+cHAWANT
			SE2->E2_LA	 	    := "S"
			If cPaisLoc == "CHI"
				SE2->E2_CGC  :=  SA2->A2_CGC
			Endif
			cPARCELAS :=cPARCELAS+"/"+cParcela

            SE2->(MSUNLOCK())
             
            lGRVSE2:=.F.
             
       ENDIF 
          
   NEXT nI       
   SE2->(MSUNLOCK())
   SE2->(DBSETORDER(6))
// SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+aCOND[1][1]))// "EIC"+aCOND[1][1]+ALLTRIM(STR(aCOND[1][2]))+"NF "+cFORANT+cLOJANT))   
   SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+AvKey(cDOCANT,"E2_NUM")))// "EIC"+aCOND[1][1]+ALLTRIM(STR(aCOND[1][2]))+"NF "+cFORANT+cLOJANT))

   IF SE2->(FOUND())

      DO WHILE .NOT. SE2->(EOF()) .AND. SE2->E2_FILIAL==xFILIAL("SE2") .AND. SE2->E2_FORNECE==cFORANT .AND. SE2->E2_LOJA==cLOJANT ;
                                  .AND. SE2->E2_PREFIXO == "EIC" .AND. SE2->E2_NUM==AvKey(cDOCANT,"E2_NUM")

          IF SE2->E2_PARCELA $(CPARCELAS)
             //
          ELSE
             SE2->(RECLOCK("SE2",.F.))
             SE2->(DBDELETE())
             SE2->(MSUNLOCK())
          ENDIF
            
          SE2->(DBSKIP())
         
      ENDDO   

   ENDIF
endif
endif

IF cRET ==.T.  .AND.  nOpcA == 3 //BORRAR
  
// SWD->(INDREGUA("SWD","TEMPSWD","WD_FILIAL+WD_DOCTO+WD_SE_DOC+WD_HAWB+WD_FORN+WD_LOJA"))
// SWD->(DBSEEK(XFILIAL("SWD")+cDOCANT +cSERANT +cHAWANT+cFORANT+cLOJANT))
   If SIX->(DBSeek("SWD6"))
      SWD->(DBSETORDER(6))//WD_FILIAL+WD_DOCTO+WD_FORN+WD_LOJA
   Else
      SWD->(DBSETORDER(4))//WD_FILIAL+WD_DOCTO
   EndIf
   IF SWD->(DBSEEK(XFILIAL("SWD")+cDOCANT+cFORANT+cLOJANT))

      DO WHILE SWD->(!EOF()) .AND. XFILIAL("SWD")==SWD->WD_FILIAL  .AND. cDOCANT==SWD->WD_DOCTO;
                             .AND. cFORANT==SWD->WD_FORN    .AND. cLOJANT==SWD->WD_LOJA

         IF cSERANT # SWD->WD_SE_DOC .OR. cHAWANT # SWD->WD_HAWB
            SWD->(DBSKIP())
            LOOP
         ENDIF

         SWD->(RECLOCK("SWD",.F.))
         SWD->(DBDELETE())
         SWD->(MSUNLOCK())
         SWD->(DBSKIP())
            
     ENDDO  

     SE2->(DBSETORDER(6))
//   IF SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+aCOND[1][1]))// "EIC"+aCOND[1][1]+ALLTRIM(STR(aCOND[1][2]))+"NF "+cFORANT+cLOJANT))
//   IF SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+AvKey(aCOND[1][1],"E2_NUM")))// "EIC"+aCOND[1][1]+ALLTRIM(STR(aCOND[1][2]))+"NF "+cFORANT+cLOJANT))
     IF SE2->(DBSEEK(xFILIAL("SE2")+cFORANT+cLOJANT+"EIC"+AvKey(cDOCANT,"E2_NUM")))//AWR - 06/09/2007
     
        DO WHILE .NOT. SE2->(EOF()) .AND. SE2->E2_FILIAL==xFILIAL("SE2") .AND. SE2->E2_FORNECE==cFORANT .AND. SE2->E2_LOJA==cLOJANT ;
                                    .AND. SE2->E2_PREFIXO == "EIC" .AND. SE2->E2_NUM==AvKey(cDOCANT,"E2_NUM")

               SE2->(RECLOCK("SE2",.F.))
               SE2->(DBDELETE())
               SE2->(MSUNLOCK())
               SE2->(DBSKIP())

        ENDDO   
              
     ENDIF
           
   ENDIF     
       
ENDIF  

IF cRET ==.T.
   DBSELECTAREA("SWD")
   SWD->(DBSETORDER(1))
   SWD->(dbSeek(xFilial()+SW6->W6_HAWB))
   DBSELECTAREA("TRB")
   AvZap()

   SWD->(dbEval({|| TRB->(dbAppend()), DI600D_Grava("TRB") },,{|| SWD->WD_FILIAL == xFilial("SWD") .And. SWD->WD_HAWB == SW6->W6_HAWB}))

   dbSelectArea("TRB")
   //MFR OSSME-1974 26/12/2018
   IndRegua("TRB",cNomeTemp+TeOrdBagExt(),"WD_DOCTO+WD_DESPESA")
   dbGoTop()
ENDIF

RETURN cRET           

*----------------------------------------------------------------------------*
FUNCTION DI600DEL()
*----------------------------------------------------------------------------*
Local aArea	:= GetArea()
LOCAL cRET  := .T.
Local nPOS  := 0
Local cDESP

nPos  := aScan(aHeader, { |x| Alltrim(x[2])=="WD_DESPESA"})

cDESP := acols[n,nPos]

IF cDESP = "101" .Or. ;
   cDESP = "104"
   
   IF LCHKFC == .T.
      Help(" ",1,"E_FOBCIFNA")
      cRET:= .F.
   ENDIF   
      
ENDIF  
  
ADI600Refresh(@aValores)

RestArea(aArea)

RETURN cRET

*----------------------------------------------------------------------------*
FUNCTION DI6EXISTNF(cDOC,cSER,cProv,cTien)
*----------------------------------------------------------------------------*
LOCAL CRET :=.T.

/*VERIFICA DE NF JA EXISTE PARA  ESTE FORNECEDOR*/
IF SF1->(DBSEEK(XFILIAL("SF1")+cDOC+cSER+cProv+cTien))
   MSGINFO("Doc ya registrado para este proveedor") 
   CRET :=.F.
ENDIF   
/*VERIFICA DE NF JA EXISTE PARA  ESTE PROCESSO*/

If SIX->(DBSeek("SWD6"))
   SWD->(DBSETORDER(6))//WD_FILIAL+WD_DOCTO+WD_FORN+WD_LOJA
Else
   SWD->(DBSETORDER(4))//WD_FILIAL+WD_DOCTO
EndIf
IF SWD->(DBSEEK(xFILIAL("SWD")+OcDOC+cPROV+cTIEN))

   IF OcDOC <> CDOCANT .OR. cPROV <> CFORANT .OR.  cTIEN<> CLOJANT
      MSGINFO("Doc ya registrado para este proceso") 
      CRET :=.F.
   ENDIF   

ENDIF

RETURN cRET

*----------------------------------------------------------------------------*
Function DI6Formula(cFormula,cDescri)
*----------------------------------------------------------------------------*

Local aArea	:= GetArea()
Local lRet  := .T.

If !Empty(cFormula)
	If SM4->(DBSeek(xFilial("SM4")+cFormula))
		cDescri := Sm4->M4_DESCR
	Else
		lRet := .F.
	EndIf	
Else
	cDescri := ""
EndIf

RestArea(aArea)

Return lRet



*----------------------------------------------------------------------------*
FUNCTION CHKFOBCIF()
*----------------------------------------------------------------------------*
Local aArea	:= GetArea()
LOCAL nPos
LOCAL CDESP
lOCAL NJ  := 0
Local Lret := .T.

nPos  := aScan(aHeader, { |x| Alltrim(x[2])=="WD_DESPESA"})
CDESP := acols[n,nPos]

IF CDESP = "101" .Or. ;
   CDESP = "104"

   IF LCHKFC == .T.
      Help(" ",1,"E_DDFOBREG")//"E_FOBCIFNA")
      Lret := .F.
   ENDIF   
ENDIF    

//ADI600FRefresh(aObj)
   
RestArea(aArea)

RETURN lRET

*----------------------------------------------------------------------------*
FUNCTION DI600CHKTES(cTES,nValr)
*----------------------------------------------------------------------------*
LOCAL WIND    := 0
LOCAL nValTot := 0

IF EMPTY(cTES) .OR. EMPTY(nValr)
   RETURN 0
ENDIF  

SA2->(DBSEEK(XFILIAL("SA1")+CPROV+CTIEN))

aTab   := CalcImpGer( cTES,,,nValr,,,,{},,nValR,.t.)

For wind:=1 to len(aTab[6])
    IF aTab[6,wind,4] > 0    
       nValTot+= aTab[6,wind,4]
    ENDIF
Next

RETURN nValTot


*----------------------------------------------------------------------------*
FUNCTION CHKTES(lCHKTES2)
*----------------------------------------------------------------------------*

Local aArea	   := GetArea()
LOCAL lIMPREPL :=.F.
LOCAL NI       := 0
lOCAL NJ       := 0
LOCAL WIND     := 0
LOCAL nVALR    := 0
LOCAL ACOLSTMP :={}
LOCAL CTES
LOCAL LDEL     :=.F.

LOCAL NVLR1 := 0
local lsair :=.f.
LOCAL ExpA1 
LOCAL aCONDTMP := {}

//AADD(aColsTMP, {"","",0,0,.F.}) - AWR - 5/8/2004 - p/ nao ficar nennhuma linha em branco
aColsTMP:={}
nPos2  := aScan(aHeader, { |x| Alltrim(x[2])=="WD_TES"})

IF lCHKTES2 == .T.
   cTES:= M->WD_TES
   lCHKVAL :=.F.
ELSE
   If nPos2 > 0
      cTES:= aCols[n][npos2]
   EndIf
ENDIF

nPos := aScan(aHeader, { |x| Alltrim(x[2])=="WD_VALOR_M"})

IF lCHKVAL == .T.
   nVALR :=nCHKVAL
ELSE
   If nPos > 0
      nVALR :=aCols[n][npos]
   EndIf
ENDIF   

IF EMPTY(cTES) .OR. EMPTY(nVALR)
   RETURN .T.
ENDIF  

SA2->(DBSEEK(XFILIAL("SA1")+CPROV+CTIEN))
    
nATUAL := n
aTab   := CalcImpGer( cTES,,,nValr,,,,{},,nValR,.t.)
For wind:=1 to len(aTab[6])

    IF aTab[6,wind,4] > 0    
//     IF EMPTY(aColsTMP[1][1]) - AWR 5/8/2004
//       	 aColsTMP[1][1]:=aTab[6,wind,1]
//     	     aColsTMP[1][2]:=aTab[6,wind,2]
//     ENDIF

       NJ:= ASCAN( ACOLSTMP, { |TAB1| TAB1[1] == aTab[6,wind,1] } ) 

       IF NJ == 0
          IF aCols[n][Len(aCols[n])]
             aTab[6,wind,3]:=0
             aTab[6,wind,4]:=0
             LDEL :=.T.
          ENDIF 
          AADD(aColsTMP, {aTab[6,wind,1],aTab[6,wind,2],aTab[6,wind,3],aTab[6,wind,4],.F.})
       ELSE
          IF aCols[n][Len(aCols[n])]
             aColsTMP[NJ][3] := 0//+(aColsIMP[NJ][3]) //BASE IMPOSTO
             aColsTMP[NJ][4] := 0//+(aColsIMP[NJ][4]) //VALOR IMPOSTO
             LDEL := .T.
           ELSE
             aColsTMP[NJ][3] :=aTab[6,wind,3]//+(aColsIMP[NJ][3]) //BASE IMPOSTO
             aColsTMP[NJ][4] :=aTab[6,wind,4]//+(aColsIMP[NJ][4]) //VALOR IMPOSTO
           
           ENDIF  
       ENDIF   

    ENDIF       

next WIND

FOR NI := 1 TO LEN(aCOLS)

    IF NI <> NATUAL .and.  !aCols[nI][Len(aCols[nI])]

       nPos2 := aScan(aHeader, { |x| Alltrim(x[2])=="WD_TES"})
       cTES  := aCols[nI][npos2]
       nPos  := aScan(aHeader, { |x| Alltrim(x[2])=="WD_VALOR_M"})
       nVALR := aCols[nI][npos]   
       SA2->(DBSEEK(XFILIAL("SA1")+CPROV+CTIEN))

       aTab  := CalcImpGer( cTES,,,nValr,,,,{},,nValR,.t.)
       For wind:=1 to len(aTab[6])
           IF aTab[6,wind,4] > 0    
              NJ:= ASCAN( ACOLSTMP, { |TAB1| TAB1[1] == aTab[6,wind,1] } ) 
              IF NJ == 0
                 IF aCols[nI][Len(aCols[nI])]
                    aTab[6,wind,3]:=0
                    aTab[6,wind,4]:=0
                    LDEL := .T.
                 ENDIF
                 AADD(aColsTMP, {aTab[6,wind,1],aTab[6,wind,2],aTab[6,wind,3],aTab[6,wind,4],.F.})
       	      ELSE 
       	         IF aCols[nI][Len(aCols[nI])]
       	            aColsTMP[NJ][3] := 0 //BASE IMPOSTO
                    aColsTMP[NJ][4] := 0 //VALOR IMPOSTO
                    LDEL := .T.
                 ELSE
                    aColsTMP[NJ][3] :=aTab[6,wind,3]+(aColsTMP[NJ][3]) //BASE IMPOSTO
                    aColsTMP[NJ][4] :=aTab[6,wind,4]+(aColsTMP[NJ][4]) //VALOR IMPOSTO
                 ENDIF       
              ENDIF   
           ENDIF
       next WIND

    ENDIF

NEXT NI

aCOLSIMP   :=aCOLSTMP

oCtaPagIMP:ACOLS:=aColsIMP
oCtaPagIMP:oBrowse:REFRESH()
lCHKVAL :=.F.
nCHKVAL := 0 

IF lCHKTES2 == .T. .OR. lDEL ==.T.
   nValor      := 0
   nValorTit   := 0 //TRP-18/10/07
   nPos        := aScan(aHeader, { |x| Alltrim(x[2])=="WD_VALOR_M"})
   nPOSD       := aScan(aHeader, { |x| Alltrim(x[2])=="WD_DESPESA"})
   nPosTes     := aScan(aHeader, { |x| Alltrim(x[2])=="WD_TES"})
   cDESP       := acols[n,nPosd]

   FOR NI := 1 TO LEN(ACOLS)
       
      SF4->(DbSetOrder(1))  //TRP-18/10/07
      SF4->(DBSeek(xFilial("SF4")+aCols[NI][nPosTes])) //TRP-18/10/07
       
      If !aCols[NI][Len(aCols[NI])]
              
         nValor+=acols[NI,nPos]
         //nValor+=DI600CHKTES( aCols[NI][nPosTes] , acols[NI,nPos] )
         IF !SF4->F4_DUPLIC == "N" //TRP-18/10/07- Se o campo Gera Título no cadastro da TES estiver como Sim,
            nValorTit+=acols[NI,nPos]   //TRP-18/10/07- acumula valor da despesa na variável nValorTit, para ser mostrado no contas a pagar no financeiro.
         Else 
            Loop 
         Endif   
       
      ENDIF
   NEXT NI
   FOR NI:= 1 TO LEN(ACOLSIMP)
   
          nValor+=ACOLSIMP[nI][4]
   
   NEXT NI

   nVALORm         := nTASA*nvalor
   aValores[VALR]  := nVALOR
   aValores[VALM]  := nVALORm

   oVLR:REFRESH()
   oVLR2:REFRESH()
   oVLRM:REFRESH()

   //ExpA1 := Condicao(nVALOR,cCOND,        ,DATE(), , )   //TRP-18/10/07
   ExpA1 := Condicao(nValorTit,cCOND,        ,DATE(), , )  //TRP-18/10/07

   FOR NI := 1 TO LEN(EXPA1)
       AADD(ACONDTMP,{OcDOC,NI,EXPA1[NI][1],EXPA1[NI][2],.F.})
   NEXT NI    

   ACOND := ACONDTMP


   oCtaPagFIN:ACOLS:=ACOND
   oCtaPagFIN:oBrowse:REFRESH()

ENDIF

//** AAF 25/06/08 - Para não dar erro ao visualizar sem impostos.
If Len(aColsImp) == 0
   aAdd(aColsImp,Array(5))
   aColsImp[1][5] := .F.
EndIf
//**
oGetDados:oBrowse:Refresh()

RestArea(aArea)

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION CHKDESP
*----------------------------------------------------------------------------*
LOCAL NPOS
LOCAL CDESP 
LOCAL lRET :=.T.

nPos  := aScan(aHeader, { |x| Alltrim(x[2])=="WD_DESPESA"})
cDESP :=M->WD_DESPESA
NJ:= ASCAN( ACOLS, { |TAB1| TAB1[nPos] == CDESP } ) 

IF NJ <> 0
   MSGINFO("Despesa ya Cadastrada")
   lRET := .F.
ENDIF

IF cDESP = "101" .Or. ;
   cDESP = "104"
   
   IF LCHKFC == .T.
      Help(" ",1,"E_DDFOBREG")//"E_FOBCIFNA")
   ENDIF   
   lRET := .F.
      
ENDIF  

RETURN lRET
// MLS - Despesa - 06/2004 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

// AWR - Lote - 07/06/2004 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
*-----------------------------------------------*
Function DI600Lotes()
*-----------------------------------------------*
LOCAL oDlg, lTemItens:=.F., C
PRIVATE aForn:={},aPLIs:={},aPOs:={},aInvoice:={}
PRIVATE cPLI,cPO,cInvoice,oMarkItens,nSelOp
PRIVATE oCboPLI,oCboPO,oInv
PRIVATE aBotaoLote:={},bBlocSel:={||.T.}
PRIVATE dDtValLote := CTOD("")  // GFP - 19/03/2014

IF !Inclui .AND. lPrimeiraVez
   IF nPos_aRotina = VISUAL .OR. nPos_aRotina = ESTORNO
      IF Work_SW8->(Easyreccount("Work_SW8")) = 0
         Processa({|| DI600InvCarrega()},STR0054) //"Pesquisa de Itens"
      ENDIF
      DI600VerLotes(.T.)
      RETURN .T.
   ELSE
      Processa({|| DI600Existe() },STR0054) //"Pesquisa de Itens"
   ENDIF
ENDIF

Work_SWV->(DBSETORDER(1))
Work_SWV->(DBGOTOP())
SA2->(DBSETORDER(1))
Work_SW8->(DBGOTOP())

DO WHILE Work_SW8->(!EOF())

   IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   lTemItens:=.T.
   IF ASCAN( aForn, Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")  ) == 0
      SA2->(DBSEEK(xFilial("SA2")+Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")))
      AADD ( aForn, Work_SW8->WKFORN+EICRetLoja("Work_SW8", "W8_FORLOJ")+" - "+ALLTRIM(SA2->A2_NREDUZ)  )
      cForn:=aForn[1] 
      cLoja:=EICRetLoja("Work_SW8", "W8_FORLOJ")//FDR - 27/11/12 - Tratamento de loja
   ENDIF

   IF ASCAN( aInvoice, Work_SW8->WKINVOICE ) == 0
      AADD ( aInvoice, Work_SW8->WKINVOICE )
      cInvoice:=aInvoice[1]
   ENDIF

   IF ASCAN( aPOs, Work_SW8->WKPO_NUM ) == 0
      AADD ( aPOs, Work_SW8->WKPO_NUM )
      cPO:=aPOs[1]
   ENDIF

   Work_SW8->(DBSKIP())

ENDDO

IF !lTemItens
   MSGSTOP(STR0530)//"Processo nao possui Itens de Invoice."
   Work_SW8->(DBGOTOP())
   RETURN .T.
ENDIF

Work_SWV->(DBSETORDER(1))
Work_CWV->(DBGOTOP())
DO While !Work_CWV->(Eof())
   IF !Work_SWV->(DBSEEK(Work_CWV->WV_LOTE+Work_CWV->WV_FORN+EICRetLoja("WORK_CWV", "WV_FORLOJ")+DTOS(Work_CWV->WV_DT_VALI)))//FDR - 04/12/12 - Tratamento de Loja
      Work_CWV->(DBDELETE())
   ENDIF
   Work_CWV->(DBSKIP())
ENDDO
DBSELECTAREA("Work_CWV")
PACK

nCol   := 130
nLin   := 4 
aCamposTWV:={}
AADD(aCamposTWV,{"WKFLAGLOT" ,,""})
AADD(aCamposTWV,{"WKDISPLOT" ,,"Qtde Disp Lote"  ,AVSX3("WV_QTDE",6)})
AADD(aCamposTWV,{"WV_QTDE"   ,,AVSX3("WV_QTDE",5),AVSX3("WV_QTDE",6)})

aCposTira:={ AVSX3("WV_LOTE",5),AVSX3("WV_DT_VALI",5),AVSX3("WV_OBS",5),AVSX3("WV_QTDE",5) }

aCposTWV:=ArrayBrowse("SWV","WORK_TWV")

FOR C := 1 TO LEN(aCposTWV)
    IF ASCAN(aCposTira, {|cTira| ALLTRIM(aCposTWV[C,3]) = ALLTRIM(cTira) }) = 0
       AADD(aCamposTWV,aCposTWV[C])
    ENDIF
NEXT

lLoteInclui:=.F.

aCposMostra:={}
AADD(aBotaoLote,{"PREV"    ,{|| IF(DI600LoteVal("LOTE",,.T.),(nSelOp:=1,oDlg:End()),) },STR0429,,STR0512}) //"Tela Anterior"
AADD(aBotaoLote,{"NEXT"    ,{|| IF(DI600LoteVal("LOTE",,.T.),(nSelOp:=2,oDlg:End()),) },STR0430,,STR0513}) //"Proxima Tela"
AADD(aBotaoLote,{"CONTAINR",{|| DI600VerLotes(.F.)     },STR0531,,"Lotes"})//"Todos os Lotes"
AADD(aBotaoLote,{"RESPONSA",{|| DI600MLotes(),oMarkItens:oBrowse:Refresh() }, STR0427,,"Marc/Des"}) //"Marca/Desmarca Todos"
aTelaSW6:=ACLONE(aTela)
aGetsSW6:=ACLONE(aGets)
aTela:={}
aGets:={}

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"COLUNAS_BOTOES_LOTES"),)

Work_CWV->(DBGOTOP())
nSelOp := 0

DO WHILE .T.

   IF nSelOp = 1     // Anterior
      Work_CWV->(DBSKIP(-1))
      IF Work_CWV->(BOF())
         Work_CWV->(DBGOBOTTOM())
      ENDIF
   ELSEIF nSelOp = 2 // Proximo
      Work_CWV->(DBSKIP())
      IF Work_CWV->(EOF())
         Work_CWV->(DBGOTOP())
      ENDIF
   ELSEIF nSelOp = 4 // Exclusao
      Work_CWV->(DBSKIP(-1))
   ENDIF
   IF Work_CWV->(Easyreccount("Work_CWV")) = 0 .OR. lLoteInclui
      DBSELECTAREA("SWV")
      M->WV_LOTE   := CRIAVAR("WV_LOTE")
      M->WV_DT_VALI:= CRIAVAR("WV_DT_VALI")
      M->WV_OBS    := CRIAVAR("WV_OBS")
      Work_TWV->(DBSETORDER(1))
      Work_TWV->(DBGOTOP())
      lLoteInclui  := .T.
      IF !DI600CrgTWV("","",{|| .T. })
         MSGSTOP(STR0532)//"Nao existe mais itens disponivel p/ Lotes."
         lLoteInclui:= .F.
         nSelOp:=3
         LOOP
      ENDIF
   ELSE
      M->WV_LOTE   := Work_CWV->WV_LOTE
      M->WV_DT_VALI:= Work_CWV->WV_DT_VALI
      dDtValLote := M->WV_DT_VALI  // GFP - 19/03/2014
      M->WV_OBS    := Work_CWV->WV_OBS
      DI600CrgTWV(Work_CWV->WV_LOTE,Work_CWV->WV_FORN,{|| .T. })
      IF (nPos:=ASCAN(aForn, { |F| F = Work_CWV->WV_FORN })) # 0 
         cForn:=aForn[nPos]
      ENDIF
      lLoteInclui:=.F.
   ENDIF

   nSelOp := 0

   DEFINE MSDIALOG oDlg TITLE STR0533 FROM 0,0 TO 28,99 Of oMainWnd //"Manutencao de Lotes"

      nMeio:=60

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 150)
      oPanelTop:= TPanel():New(0, 0, "", oPanel,, .F., .F.,,, 90, 80)
      oPanelForn:= TPanel():New(0, 0, "", oPanel,, .F., .F.,,, 150, 265)
      oPanelSel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 150, 265)
      
      oPanel:Align := CONTROL_ALIGN_TOP
      oPanelTop:Align := CONTROL_ALIGN_TOP
      oPanelForn:Align := CONTROL_ALIGN_ALLCLIENT
      oPanelSel:Align := CONTROL_ALIGN_ALLCLIENT

      aCposMostra:={"WV_LOTE","WV_DT_VALI","WV_OBS"}
      IF lLoteInclui
         aCposGet:=aCposMostra
      ELSE
         aCposGet:={"WV_DT_VALI","WV_OBS"}
      ENDIF

      oEnChSWV:=MsMGet():New("SWV",1,3,,,,aCposMostra,{02,02,75,COLUNA_FINAL},aCposGet,3,,,,oPanelTop,,,,,.T.)//19o. parametro com .T.: Desabilita as Pastas 
      oEnChSWV:oBox:Align:=CONTROL_ALIGN_ALLCLIENT

      @15,COLUNA_FINAL BUTTON oBtn1 PROMPT STR0535 SIZE 50,14 WHEN !lLoteInclui ;//"Inclui Lote"
                          ACTION (  (nSelOp:=3,oDlg:End()) ) OF oPanelTop PIXEL

      @30,COLUNA_FINAL BUTTON oBtn2 PROMPT STR0536 SIZE 50,14 WHEN !EMPTY(M->WV_LOTE) ;//"Exclui Lote"
                          ACTION (  (nSelOp:=4,oDlg:End()) ) OF oPanelTop PIXEL

      @45,COLUNA_FINAL BUTTON oBtn3 PROMPT STR0537 SIZE 50,14 ;//"Filtra Itens"
                          ACTION ( DI600TelaSel(),oMarkItens:oBrowse:Refresh() ) OF oPanelTop PIXEL

      @ 1,6 SAY STR0534 OF oPanelForn PIXEL//"Fornecedor"
      @ 11,6 COMBOBOX cForn ITEMS aForn SIZE 180,18 PIXEL WHEN lLoteInclui VALID DI600LoteVal("COMBOFORN",,.F.) OF oPanelForn

      DBSELECTAREA("Work_TWV")
      DBSETORDER(1)
      DBGOTOP()
      IF SetMDIChild()
         nPosTop:=nMeio+25
      ELSE
         nPosTop:=nMeio+15
      ENDIF
      oMarkItens:=MSSELECT():New("Work_TWV","WKFLAGLOT",,aCamposTWV,lInverte,cMarca,{nPosTop,2,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2},,,oPanelSel)
      oMarkItens:oBrowse:bWhen:={|| DBSELECTAREA('Work_TWV'),DBSETORDER(1),.T.} 
      oMarkItens:bAval:={|| DI600GetQtde(),oMarkItens:oBrowse:Refresh() } 
      oMarkItens:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
      oDlg:lMaximized:=.T.
      
   ACTIVATE MSDIALOG oDlg ON INIT (DI600EnchoiceBar(oDlg,{{|| IF(DI600LoteVal("LOTE",,.T.),(nSelOp:=5,oDlg:End()),) },"OK"},;
                                                          {|| (nSelOp:=0,oDlg:End()) },.F.,aBotaoLote)) CENTERED//,oPanelL:Align:=CONTROL_ALIGN_RIGHT

   IF nSelOp # 0
      lGravaSWV:=.T.
      IF !EMPTY(M->WV_LOTE)
         Processa({|| DI600GrvLote(nSelOp,M->WV_LOTE+LEFT(cForn,LEN(Work_SWV->WV_FORN)+IF(EICLOJA(),LEN(WORK_SWV->WV_FORLOJ),0))+DTOS(M->WV_DT_VALI))})//FDR - Tratamento de Loja
      ELSEIF lLoteInclui
         lLoteInclui := .F.
      ENDIF
      IF nSelOp = 3 // Inclusao
         lLoteInclui := .T.
      ENDIF
      IF nSelOp = 5 // OK
         EXIT
      ENDIF
      LOOP
   ENDIF
   
   EXIT 

Enddo

aTela:=ACLONE(aTelaSW6)
aGets:=ACLONE(aGetsSW6)

Return NIL
*-----------------------------------*
FUNCTION DI600GetQtde()
*-----------------------------------*
LOCAL nQtde:=IF(!EMPTY(Work_TWV->WV_QTDE),Work_TWV->WV_QTDE,Work_TWV->WKDISPLOT)
LOCAL nOpca:= 0 

IF !DI600LoteVal("GET_QTDE")
   RETURN .F.
ENDIF

DEFINE MSDIALOG oDlgGet TITLE AVSX3("WV_QTDE",5) FROM 9,10 TO 18,48 Of oMainWnd

  @1.2,01 SAY AVSX3("WV_QTDE",5)
  @1.2,05 MSGET nQtde PICTURE _PictQtde  SIZE 50,8 VALID (Positivo(nQtde))

  @14,105 BUTTON "OK"    SIZE 25,11 ACTION (IF(DI600LoteVal("QTDE",nQtde),(nOpca:=1,oDlgGet:End()),)) OF oDlgGet PIXEL 
  @34,105 BUTTON "Salir" SIZE 25,11 ACTION (nOpca:=0,oDlgGet:End())                             OF oDlgGet PIXEL 

ACTIVATE MSDIALOG oDlgGet CENTERED

IF nOpca = 1 
   DI600MarLote(nQtde)
ENDIF

Return NIL
*-----------------------------------*
FUNCTION DI600MarLote(nQtde)
*-----------------------------------*
IF nQtde > 0
   Work_TWV->WV_QTDE  := nQtde
   Work_TWV->WKFLAGLOT:= cMarca
   Work_TWV->WKDISPLOT:= Work_TWV->WKDISPLOT - Work_TWV->WV_QTDE//FDR - 04/12/12
ELSE
   Work_TWV->WKDISPLOT:= Work_TWV->WKDISPLOT + Work_TWV->WV_QTDE  // GFP - 05/02/2014
   Work_TWV->WV_QTDE  := 0
   Work_TWV->WKFLAGLOT:= ""
ENDIF

Return .T.

*---------------------------------------------------------------------------------------------------------*
FUNCTION DI600LoteVal(cCampo,nQtde,lVerItens,cChave)
*---------------------------------------------------------------------------------------------------------*
LOCAL nRecno,nOrder
DEFAULT lVerItens := .F.

IF SELECT("Work_SWV") = 0
   RETURN .T.
ENDIF

IF cCampo == "GET_QTDE"
   IF EMPTY(M->WV_LOTE)
      MSGSTOP("Lote no llenado.")
      Return .F.
   ENDIF
   IF cForn # Work_TWV->WV_FORN
      MSGSTOP("Proveedor seleccionado es distinto del proveedor del item.")
      Return .F.
   ENDIF

ELSEIF cCampo == "COMBOFORN"
   Work_SWV->(DBSETORDER(1))
   IF Work_SWV->(DBSEEK(M->WV_LOTE+LEFT(cForn,LEN(Work_SWV->WV_FORN)))) .AND. lLoteInclui
      MSGSTOP(STR0542)//"Lote ja existe p/ esse Fornecedor."
      Return .F.
   ENDIF
   nRecno:=Work_TWV->(RECNO())
   nOrder:=Work_TWV->(INDEXORD())
   Work_TWV->(dbGoTop())
   DO While !Work_TWV->(Eof())

      If !EMPTY(Work_TWV->WV_QTDE) .AND. LEFT(cForn,LEN(Work_SWV->WV_FORN)) # Work_TWV->WV_FORN
         MSGSTOP(STR0539)//"Fornecedor nao pode ser alterado, pois ja existe itens marcados."
         Work_TWV->(DBSETORDER(nOrder))
         Work_TWV->(DBGOTO(nRecno))
         RETURN .F.
      EndIf
      
      Work_TWV->(dbSkip())

   ENDDO
   Work_TWV->(DBSETORDER(nOrder))
   Work_TWV->(DBGOTO(nRecno))

ELSEIF cCampo == "QTDE"
   IF nQtde > Work_TWV->WKDISPLOT
      MSGSTOP(STR0540)//"Quantidade do Lote nao pode ser maior que a quantidade Disponivel."
      Return .F.
   ENDIF

ELSEIF cCampo == "LOTE"
   IF EMPTY(M->WV_LOTE)
      RETURN .T.
   ENDIF
   IF TYPE("cForn") # "C"// AWR - TEM QUE TESTAR PORQUE ESSA VALIDACAO É CHAMADA DO X3_VALID
      RETURN .T.
   ENDIF
   IF TYPE("cLoja") # "C"//FDR - 27/11/12 - TEM QUE TESTAR PORQUE ESSA VALIDACAO É CHAMADA DO X3_VALID
      RETURN .T.
   ENDIF
   Work_SWV->(DBSETORDER(1))
   IF Work_SWV->(DBSEEK(M->WV_LOTE+LEFT(cForn,LEN(Work_SWV->WV_FORN))+IF(EICLOJA(),cLoja,""))) .AND. lLoteInclui
      MSGSTOP(STR0542)//"Lote ja existe p/ esse Fornecedor."
      Return .F.
   ENDIF

ELSEIF cCampo == "DEL_LOTE"

   Work_SWV->(DBSETORDER(2))//WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE
   Work_SWV->(DBSEEK(cChave))
   DO While Work_SWV->(DBSEEK(cChave))
      Work_SWV->(DBDELETE())
      Work_SWV->(dbSkip())
   ENDDO
   Work_SW8->WKDISPLOT:=WORK_SW8->WKQTDE

ELSEIF cCampo == "TEM_LOTE_AVISO"
   Work_SWV->(DBSETORDER(2))//WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE
   IF Work_SWV->(DBSEEK(cChave))
      IF MSGYESNO(STR0543)//"Item pertence a um Lote,  Deseja Desmarcar ?"
         Return .F.
      ELSE
         Return .T.
      ENDIF
   ENDIF
   Return .F.

ELSEIF cCampo == "EXCLUI_LOTE"
   nRecno:=Work_SW8->(RECNO())
   nOrder:=Work_SW8->(INDEXORD())
   Work_SWV->(DBSETORDER(2))//WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO+WV_INVOICE
   Work_SW8->(DBSETORDER(1))
   //TDF - 13/09/12 - TRATAMENTO DE LOJA
   Work_SW8->(DBSEEK(Work_SW9->W9_INVOICE+Work_SW9->W9_FORN+EICRetLoja("Work_SW9", "W9_FORLOJ")))
   lExcluiLote:=.T.
   DO WHILE Work_SW8->(!EOF()) .AND. Work_SW8->WKINVOICE==WORK_SW9->W9_INVOICE .AND.;
                                     Work_SW8->WKFORN   ==WORK_SW9->W9_FORN .And.;
                                     (!EICLoja() .Or. Work_SW8->W8_FORLOJ == Work_SW9->W9_FORLOJ)//FDR - 13/09/12 - Tratamento de loja
                                     
      IF Work_SWV->(DBSEEK(WORK_SW8->(WKFORN+WKPGI_NUM+WKPO_NUM+WKPOSICAO+WKINVOICE)))
         lExcluiLote:= MSGYESNO(STR0544)//"Invoice possui itens com Lote,  Deseja Continuar ?"
         EXIT
      ENDIF
      Work_SW8->(DBSKIP())
   ENDDO
   Work_SW8->(DBSETORDER(nOrder))
   Work_SW8->(DBGOTO(nRecno))
   Return lExcluiLote

ENDIF

IF lVerItens
   Work_TWV->(dbGoTop())
   DO While !Work_TWV->(Eof())

      If Work_TWV->WV_QTDE # 0 //Quantidade
         Return .T.
      ENDIF

      Work_TWV->(dbSkip())

   ENDDO
   Work_TWV->(dbGoTop())
   MSGSTOP(STR0545)//"Nao existe Itens selecionados para esse Lote."
   Return .F.
ENDIF

Return .T.

*-----------------------------------*
FUNCTION DI600VerLotes(lVisual)
*-----------------------------------*
LOCAL oMarkVer,oDlgLotes,aCamposSWV:=ArrayBrowse("SWV","WORK_SWV")

IF !lVisual .AND. !EMPTY(M->WV_LOTE)
   Processa({|| DI600GrvLote(nSelOp,M->WV_LOTE+LEFT(cForn,LEN(Work_SWV->WV_FORN)+IF(EICLOJA(),LEN(WORK_SWV->WV_FORLOJ),0))+DTOS(M->WV_DT_VALI))})//FDR - 04/12/12
ENDIF

DEFINE MSDIALOG oDlgLotes TITLE STR0546 FROM 0,0 TO 28,99 Of oMainWnd //"Visualiza Lotes"
          
    DBSELECTAREA("Work_SWV")
    DBSETORDER(1)
    DBGOTOP()
    oMarkVer:=MSSELECT():New("Work_SWV",,,aCamposSWV,lInverte,cMarca,{25,2,(oDlgLotes:nClientHeight-6)/2,(oDlgLotes:nClientWidth-4)/2})
    oMarkVer:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
    oDlgLotes:lMaximized:=.T.

ACTIVATE MSDIALOG oDlgLotes ON INIT DI600EnchoiceBar(oDlgLotes,,{|| (nSelOp:=0,oDlgLotes:End()) },.F.) CENTERED

DBSELECTAREA("Work_TWV")

Return .T.
*-----------------------------------*
FUNCTION DI600MLotes()
*-----------------------------------*
LOCAL lMarca:=.F.,nRecno := 0
IF !DI600LoteVal("LOTE",,.F.)
   RETURN .F.
ENDIF
Work_TWV->(dbGoTop())
DO While !Work_TWV->(Eof())

   If cForn # Work_TWV->WV_FORN
      DI600MarLote(0)
      Work_TWV->(dbSkip())
      Loop
   EndIf
   IF nRecno = 0
      nRecno := Work_TWV->(RECNO())   
      IF EMPTY(Work_TWV->WV_QTDE)
         lMarca:=.T.
      ENDIF
   ENDIF
   IF lMarca
      DI600MarLote(Work_TWV->WKDISPLOT)
   ELSE
      DI600MarLote(0)
   ENDIF

   Work_TWV->(dbSkip())

ENDDO

Work_TWV->(DBGOTO(nRecno))

RETURN .T.
*-----------------------------------*
FUNCTION DI600TelaSel()
*-----------------------------------*
LOCAL oDlg, oRadio
LOCAL nLin := 17
LOCAL nColR:= 20 
LOCAL nCol := nColR+111
LOCAL nColS:= nCol-35
LOCAL nSoma:= 16
LOCAL nMarcaOK:=0
bBlocSel:={||.T.}

IF !EMPTY(M->WV_LOTE)
   Processa({|| DI600GrvLote(nSelOp,M->WV_LOTE+LEFT(cForn,LEN(Work_SWV->WV_FORN))) })
ENDIF

DO WHILE .T.

   nLin := 17
   
   DEFINE MSDIALOG oDlg TITLE STR0547 FROM 0,0 TO 20,63 Of oMainWnd //"Filtro de Itens"
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 150)
   oPanel:Align := CONTROL_ALIGN_ALLCLIENT
   nOpRad:=3
   @nLin   ,nColR   TO nLin+065, nColR+54 LABEL STR0548 OF oPanel PIXEL //"Selecao"
   @nLin+07,nColR+5 RADIO oRadio VAR nOpRad ITEMS STR0549,STR0550,STR0551 3D SIZE 45,16 ;//"Pedido","Invoice","Todos"
                                            PIXEL OF oPanel ON CHANGE (DI600CBOX()) 
   nLin+=10
   
   @nLin+.6, nColS SAY STR0549 OF oPanel PIXEL //"Pedido"
   @nLin,    nCol  COMBOBOX oCboPO  VAR cPO     ITEMS aPOs     SIZE 75,18 PIXEL WHEN {|| nOpRad==1 } OF oPanel
   nLin+=nSoma
   
   @nLin+.6, nColS SAY STR0550 OF oPanel PIXEL //"Invoice"
   @nLin,    nCol  COMBOBOX oInv  VAR cInvoice  ITEMS aInvoice SIZE 75,18 PIXEL WHEN {|| nOpRad==2 } OF oPanel
   nLin+=nSoma

   @ nLin+.6,nColS SAY STR0534 OF oPanel PIXEL //"Fornecedor"
   @ nLin,   nCol  COMBOBOX oCboFor VAR cForn    ITEMS aForn    SIZE 75,18 PIXEL WHEN EVAL({|| nOpRad==3 }) .AND. lLoteInclui OF oPanel

   ACTIVATE MSDIALOG oDlg ON INIT DI600EnchoiceBar(oDlg,{{|| (nMarcaOK:=1,oDlg:End()) },"OK"},{|| (nMarcaOK:=0,oDlg:End()) },.F.) CENTERED

   IF nMarcaOK = 1
      cFornSel:=cForn
      IF lLoteInclui .AND. nOpRad # 3
         cFornSel:=""
      ENDIF
      IF nOpRad == 1
         bBlocSel := {|| RTRIM(Work_SW8->WKPO_NUM ) == RTRIM(cPO)}
      ELSEIF nOpRad == 2
         bBlocSel := {|| RTRIM(Work_SW8->WKINVOICE) == RTRIM(cInvoice)}      
      ENDIF

      IF !DI600CrgTWV(M->WV_LOTE,LEFT(cFornSel,LEN(Work_SWV->WV_FORN)),bBlocSel,.F.)
         MSGSTOP(STR0552)//"Nao existe itens disponivel p/ essa selecao."
         LOOP
      ENDIF

   ENDIF

   EXIT

ENDDO

Work_TWV->(DBGOTOP())

RETURN .T.
*------------------------------*
FUNCTION DI600CBOX()
*------------------------------*
IF(nOpRad=1, oCboPO:ENABLE(), oCboPO:DISABLE()) // Escolheu PO
IF(nOpRad=2,   oInv:ENABLE(),   oInv:DISABLE()) // Escolheu Invoice
IF(nOpRad=3 .AND. lLoteInclui,oCboFor:ENABLE(),oCboFor:DISABLE()) // Escolheu Todos
RETURN .T.

*-------------------------------------------------------------------------------------*
FUNCTION DI600GrvLote(nSelOp,cChave)
*-------------------------------------------------------------------------------------*
LOCAL nCont:=xTotal:=0,lGrvItem:=.F.  

ProcRegua( Work_SWV->(Easyreccount("Work_SWV")) )

IF nSelOp = 4 // Exclui Lote
   IF Work_CWV->(DBSEEK(cChave))
      IncProc()
      Work_CWV->(DBDELETE())
      DBSELECTAREA("Work_CWV")
      PACK
   ENDIF
ENDIF

Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
Work_SWV->(DBSETORDER(1))
Work_SWV->(DBSEEK(cChave))
lDeletou:=.F.
DO While !Work_SWV->(Eof()) .AND. cChave == Work_SWV->WV_LOTE+Work_SWV->WV_FORN+If(EicLoja(),Work_SWV->WV_FORLOJ,"")+DTOS(Work_SWV->WV_DT_VALI)//FDR - 27/11/12 - Tratamento de loja

   IncProc()
   //FDR - 27/11/12 - Tratamento de Loja
   IF EICLOJA()
      IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
         Work_SW8->WKDISPLOT+=Work_SWV->WV_QTDE
      ENDIF
   ELSE   
      IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
      Work_SW8->WKDISPLOT+=Work_SWV->WV_QTDE
      ENDIF
   ENDIF   
   lDeletou:=.T.
   Work_SWV->(DBDELETE())
   Work_SWV->(dbSkip())

ENDDO

IF lDeletou
   DBSELECTAREA("Work_SWV")
   PACK
ENDIF

IF nSelOp = 4 // Exclui Lote
   RETURN .T.
ENDIF

ProcRegua(xTotal:=Work_TWV->(Easyreccount("Work_TWV")))
xTotal:=LTRIM(STR(xTotal,7))

Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
Work_TWV->(DBSETORDER(1))
Work_TWV->(dbGoTop())
DO While !Work_TWV->(Eof())

   nCont++
   IncProc()

   If Work_TWV->WV_QTDE <= 0 //Quantidade
      Work_TWV->(dbSkip())
      Loop
   EndIf

   If !Work_SWV->(DBSEEK(M->WV_LOTE+M->W6_FORN+IF(EICLOJA(),M->W6_LOJA,"")+DTOS(dDtValLote)))  // GFP - 19/03/2014
      Work_SWV->(DBAPPEND())
   EndIf

   AVREPLACE("Work_TWV","Work_SWV")

   Work_SWV->WV_LOTE   :=M->WV_LOTE
   Work_SWV->WV_DT_VALI:=M->WV_DT_VALI
   Work_SWV->WV_OBS    :=M->WV_OBS

   //FDR - 14/11/12
   IF EICLOJA()
      IF Work_SW8->(DBSEEK( Work_TWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
         Work_SW8->WKDISPLOT-=Work_SWV->WV_QTDE
      ENDIF
   ELSE
      IF Work_SW8->(DBSEEK( Work_TWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
         Work_SW8->WKDISPLOT-=Work_SWV->WV_QTDE
      ENDIF
   ENDIF

   lLoteInclui:=.F.
   lGrvItem   :=.T.  
   Work_TWV->(dbSkip())

ENDDO

IF lGrvItem
   IF !Work_CWV->(DBSEEK(cChave))
      Work_CWV->(DBAPPEND())
      Work_CWV->WV_LOTE:=M->WV_LOTE
      Work_CWV->WV_FORN:=cForn 
   ENDIF
   AVREPLACE("M","Work_CWV")
   Work_CWV->WV_LOTE   :=M->WV_LOTE
   Work_CWV->WV_FORN   :=cForn     
   //FDR - Tratamento de loja
   If EicLoja()
      Work_CWV->WV_FORLOJ:= cLoja
   EndIf
   
   Work_CWV->WV_DT_VALI:=M->WV_DT_VALI
   Work_CWV->WV_OBS    :=M->WV_OBS
ENDIF

Work_TWV->(dbGoTop())

RETURN .T.
*-----------------------------------------------------------------------------------------------------------------*
FUNCTION DI600CrgTWV(cLote,cFornecedor,bBlocSel,lZap)
*-----------------------------------------------------------------------------------------------------------------*
DEFAULT lZap := .T.

IF lZap
   DBSELECTAREA("Work_TWV")
   AvZap()
   AvZap("Work_TWV")//FDR - 29/11/12
ENDIF

ProcRegua(Work_SW8->(Easyreccount("Work_SW8")))
Work_TWV->(DBSETORDER(2))
Work_SWV->(DBSETORDER(2))
Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
Work_SW8->(dbGoTop())
lTemItens := .F.
DO While !Work_SW8->(Eof())

   IncProc()

   IF EMPTY(Work_SW8->WKFLAGIV) .OR.  EMPTY(Work_SW8->WKINVOICE)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF EMPTY(Work_SW8->WKDISPLOT)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF !EVAL(bBlocSel)
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF !EMPTY(cFornecedor) .AND. Work_SW8->WKFORN # cFornecedor
      Work_SW8->(DBSKIP())
      LOOP
   ENDIF

   IF !lZap// Para dar ZAP so se existir itens p/ trazer no filtro ( DI600TelaSel() )
      DBSELECTAREA("Work_TWV")
      AvZap()
      lZap:=.T.
   ENDIF
      
   Work_TWV->(DBAPPEND())
   DI600SW8TWVGrv()
   Work_TWV->WKDISPLOT:= Work_SW8->WKDISPLOT
   Work_TWV->WV_QTDE  := 0
   Work_TWV->WKFLAGLOT:= ""

   lTemItens := .T.

   Work_SW8->(dbSkip())

ENDDO

Work_TWV->(DBGOTOP())
IF (nPos:=ASCAN(aForn, { |F| F = Work_TWV->WV_FORN })) # 0 
   cForn:=aForn[nPos]
ENDIF

IF !EMPTY(cLote+cFornecedor)

   ProcRegua(Work_SWV->(Easyreccount("Work_SWV")))
   Work_TWV->(DBSETORDER(2))//WV_INVOICE+WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO
   Work_SW8->(DBSETORDER(1))//WKINVOICE+WKFORN+WKPO_NUM+WKPOSICAO+WKPGI_NUM
   Work_SWV->(DBSETORDER(1))
   Work_SWV->(DBSEEK(cLote+cFornecedor))

   DO While !Work_SWV->(Eof()) .AND. cLote+cFornecedor == Work_SWV->WV_LOTE+Work_SWV->WV_FORN

      IncProc()
      //FDR - 04/12/12 - Tratamento de Loja
      IF EICLOJA()
         IF !Work_TWV->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO) ))
            Work_TWV->(DBAPPEND())
            AVREPLACE("Work_SWV","Work_TWV")
         ENDIF
      ELSE
         IF !Work_TWV->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO) ))
            Work_TWV->(DBAPPEND())
            AVREPLACE("Work_SWV","Work_TWV")
         ENDIF
      ENDIF   

      Work_TWV->WV_QTDE  := Work_SWV->WV_QTDE
      Work_TWV->WKFLAGLOT:= cMarca
      IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
         Work_TWV->WKDISPLOT:=(Work_SW8->WKDISPLOT+Work_SWV->WV_QTDE)
      ENDIF

      Work_SWV->(dbSkip())

   ENDDO

ENDIF

Work_TWV->(DBSETORDER(1))
Work_SWV->(DBSETORDER(1))

Return lTemItens


*------------------------------------------------------------------------------*
FUNCTION DI600SW8TWVGrv()
*------------------------------------------------------------------------------*
LOCAL cFieldSW8,cFieldTWV,bFieldTWV,bFieldSW8,I

For I:=1 To Work_SW8->(FCOUNT())
   
    cFieldSW8:=Work_SW8->(FieldName(i))
    cFieldTWV:='WV_'+SUBSTR(cFieldSW8,3)
    //FDR - 14/11/12
    IF EICLOJA() .And. "LOJ" $ cFieldSW8
       If "FO" $ cFieldSW8
          cFieldTWV:="WV_FORLOJ"
       EndIf
       If "FA" $ cFieldSW8
          cFieldTWV:="WV_FABLOJ"
       EndIF
    ENDIF
    IF Work_TWV->(FieldPos(cFieldTWV)) == 0
       LOOP
    Else
       //bFieldWk = {|Valor|IF(Valor==NIL,Work_TWV->WV_???????,Work_TWV->WV_???????:=Valor)}
       bFieldTWV:=FieldWBlock(cFieldTWV,Select("Work_TWV"))
    Endif

    //bFieldSW8 = {|Valor|IF(Valor==NIL,Work_SW8->W8_???????,Work_SW8->W8_???????:=Valor)}
    bFieldSW8:=FieldWBlock(cFieldSW8,Select("Work_SW8"))

    Eval(bFieldTWV,Eval(bFieldSW8))

Next

RETURN .T.

*------------------------------------------------------------------------------*
FUNCTION DI600SWVGrv(lLer)
*------------------------------------------------------------------------------*
LOCAL cFilSWV:=xFilial("SWV"),nCont:=0

IF !lTemLote
   RETURN .F.
ENDIF

ProcRegua(10)

IF lLer
   DBSELECTAREA("Work_CWV")//FDR - 28/11/12
   //ZAP
   AvZap("Work_CWV")
   DBSELECTAREA("Work_SWV")//FDR - 28/11/12
   //ZAP
   AvZap("Work_SWV")
   aLotes:={}
   SW8->(DBSETORDER(1))
   SWV->(DBSETORDER(1))
   SWV->(DBSEEK(cFilSWV+SW6->W6_HAWB))
   DO While !SWV->(Eof()) .AND. SW6->W6_HAWB == SWV->WV_HAWB .AND. cFilSWV == SWV->WV_FILIAL

      IF nCont > 10
         ProcRegua(10)
         nCont:=0
      ELSE
         nCont++
         IncProc()
      ENDIF

      IF EMPTY(SWV->WV_FORN) .OR. EMPTY(SWV->WV_INVOICE)
         SWV->(dbSkip())
         LOOP
      ENDIF

      Work_SWV->(DBAPPEND())
      AVREPLACE("SWV","Work_SWV")

      IF !Work_CWV->(DBSEEK(SWV->WV_LOTE+SWV->WV_FORN+DTOS(SWV->WV_DT_VALI)))
         Work_CWV->(DBAPPEND())
         AVREPLACE("SWV","Work_CWV")//FDR - 28/11/12
         Work_CWV->WV_LOTE   :=SWV->WV_LOTE
         Work_CWV->WV_FORN   :=SWV->WV_FORN
         Work_CWV->WV_DT_VALI:=SWV->WV_DT_VALI
         Work_CWV->WV_OBS    :=SWV->WV_OBS
      ENDIF

      //FDR - 28/11/12 - Tratamento de Loja
      IF EICLOJA()
         IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
            Work_SW8->WKDISPLOT-=Work_SWV->WV_QTDE
         ENDIF
      ELSE
         IF Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) ))
            Work_SW8->WKDISPLOT-=Work_SWV->WV_QTDE
         ENDIF
      ENDIF
      SWV->(dbSkip())

   ENDDO

ELSE

   IF !lGravaSWV
      RETURN .F.
   ENDIF
   SWV->(DBSETORDER(1))
   SWV->(DBSEEK(cFilSWV+M->W6_HAWB))
   DO While !SWV->(Eof()) .AND. M->W6_HAWB == SWV->WV_HAWB .AND. cFilSWV == SWV->WV_FILIAL
      IF EMPTY(SWV->WV_FORN) .OR. EMPTY(SWV->WV_INVOICE)
         SWV->(dbSkip())
         LOOP
      ENDIF

      IF nCont > 10
         ProcRegua(10)
         nCont:=0
      ELSE
         nCont++
         IncProc()
      ENDIF

      SWV->(RECLOCK("SWV",.F.))
      SWV->(DBDELETE())
      SWV->(MSUNLOCK())
      SWV->(dbSkip())

   ENDDO

   ProcRegua(Work_SWV->(Easyreccount("Work_SWV")))
   Work_SW8->(DBSETORDER(1))
   Work_SWV->(DBSETORDER(1))
   Work_SWV->(dbGoTop())
   DO While !Work_SWV->(Eof())

      IncProc()

      //FDR - 14/11/2012
      IF !Work_SW8->(DBSEEK( Work_SWV->(WV_INVOICE+WV_FORN+If(EICLOJA(), WV_FORLOJ, "")+WV_PO_NUM+WV_POSICAO+WV_PGI_NUM) )) .OR. EMPTY(Work_SW8->WKFLAGIV)
         Work_SWV->(dbSkip())
         LOOP
      ENDIF

      SWV->(RECLOCK("SWV",.T.))
      AVREPLACE("Work_SWV","SWV")
      SWV->WV_FILIAL:= cFilSWV
      SWV->WV_HAWB  := M->W6_HAWB
      SWV->(MSUNLOCK())
      Work_SWV->(dbSkip())

   ENDDO

ENDIF

RETURN  .T.

*------------------------------------------------------------------------------*
FUNCTION DI600SWVEstorno(cChave)
*------------------------------------------------------------------------------*
LOCAL cFilSWV:=xFilial("SWV")
IF !lTemLote
   RETURN .F.
ENDIF
SWV->(DBSETORDER(2))
SWV->(DBSEEK(cFilSWV+SW6->W6_HAWB+cChave))
DO While !SWV->(Eof()) .AND. SW6->W6_HAWB == SWV->WV_HAWB   .AND.;
                                  cFilSWV == SWV->WV_FILIAL .AND.;
                                  cChave  == SWV->(WV_INVOICE+WV_PGI_NUM+WV_PO_NUM+WV_POSICAO)
   SWV->(RECLOCK("SWV",.F.))
   SWV->(DBDELETE())
   SWV->(MSUNLOCK())
   SWV->(dbSkip())

ENDDO
SWV->(DBSETORDER(1))
RETURN  .T.

*------------------------------------------------------------------------------*
FUNCTION ADI600COND(cCond) //Validar condicao de pagamento digitada.
*------------------------------------------------------------------------------*
LOCAL aArea := GetArea()
LOCAL lRet := .T.

If LINCLUIR.OR.LALTERAR
	SE4->(DbSetOrder(1))
	If ! SE4->(DbSeek(xFilial("SE4")+cCond))
		Help("","1","ADI600COND")
	    lRet := .F.
	ENDIF
EndIf
RestArea(aArea)
RETURN lRet


*----------------------------------------------------*
Function DI600RetVal(cTot,cArea,lDesp,lConv )
// cTot := string que indica se é total do FOB do item(ITEM_INV) ou da invoice total (TOT_INV). Caso não seja para considerar o FOB, enviar a string(SEM_FOB)
// cArea := string que indica se pega de variável de memoria (MEMO), de Work (WORK) ou da tabela (TAB)
// lDesp := var lógica que indica se deve somar as despesas da invoice (.T.)
// lConv := var lógica que indica se deve converter em reais o valor apurado
// Elizabete de Oliveira Brito - 02/06/08
*----------------------------------------------------*
Local nFobTot := 0
Local lIn327  := EasyGParam("MV_IN327" ,,.F.)
DEFAULT lDesp := .F.
DEFAULT lConv := .F. 

lSegInc := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND. ;
           SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0 // EOB - 02/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)

IF "TOT_INV" $ cTot
   IF cArea == "MEMO"
      IF !("SEM_FOB" $ cTot)
         nFobTot := M->W9_FOB_TOT
      ENDIF
      IF lDesp
         nFobTot += M->W9_INLAND+M->W9_PACKING+M->W9_OUTDESP-IF(!lIn327,M->W9_DESCONT,0)
         IF M->W9_FREINC $ cNao // .AND. M->W9_INCOTERM $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"//JVR - 29/04/10 - Retirado tratamento de Incoterm
            nFobTot += M->W9_FRETEIN
         ENDIF
         IF lSegInc .AND. M->W9_SEGINC $ cNao // .AND. M->W9_INCOTERM $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"//JVR - 29/04/10 - Retirado tratamento de Incoterm
            nFobTot += M->W9_SEGURO
         ENDIF
      ENDIF
   ELSEIF cArea == "WORK"
      IF !("SEM_FOB" $ cTot)
         nFobTot := Work_SW9->W9_FOB_TOT
      ENDIF
      IF lDesp
         nFobTot += Work_SW9->W9_INLAND+Work_SW9->W9_PACKING+Work_SW9->W9_OUTDESP-IF(!lIn327,Work_SW9->W9_DESCONT,0)
         IF Work_SW9->W9_FREINC $ cNao // .AND. Work_SW9->W9_INCOTERM $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"//JVR - 29/04/10 - Retirado tratamento de Incoterm
            nFobTot += Work_SW9->W9_FRETEIN
         ENDIF
         IF lSegInc .AND. Work_SW9->W9_SEGINC $ cNao // .AND. Work_SW9->W9_INCOTERM $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"//JVR - 29/04/10 - Retirado tratamento de Incoterm
            nFobTot += Work_SW9->W9_SEGURO
         ENDIF
      ENDIF
      IF lConv
         nFobTot := nFobTot * Work_SW9->W9_TX_FOB
      ENDIF
   ELSEIF cArea == "TAB"
      IF !("SEM_FOB" $ cTot)
         nFobTot := SW9->W9_FOB_TOT
      ENDIF
      IF lDesp
         nFobTot += SW9->W9_INLAND+SW9->W9_PACKING+SW9->W9_OUTDESP-IF(!lIn327,SW9->W9_DESCONT,0)
         IF SW9->W9_FREINC $ cNao // .AND. SW9->W9_INCOTERM $ "CFR,CPT,CIF,CIP,DAF,DES,DEQ,DDU,DDP"//JVR - 29/04/10 - Retirado tratamento de Incoterm
            nFobTot += SW9->W9_FRETEIN
         ENDIF
         IF lSegInc .AND. SW9->W9_SEGINC $ cNao // .AND. SW9->W9_INCOTERM $ "CIF,CIP,DAF,DES,DEQ,DDU,DDP"//JVR - 29/04/10 - Retirado tratamento de Incoterm
            nFobTot += SW9->W9_SEGURO
         ENDIF
      ENDIF
      IF lConv
         nFobTot := nFobTot * SW9->W9_TX_FOB
      ENDIF   
   ENDIF
ELSEIF "INV_ESP" $ cTot
   IF cArea == "TAB"
      IF lDesp 
         nFobTot += EZZ->EZZ_INLAND+EZZ->EZZ_PACKIN+EZZ->EZZ_OUTDES+EZZ->EZZ_FRETEI-EZZ->EZZ_DESCONT 
      ENDIF
      IF lConv
         nFobTot := nFobTot*EZZ->EZZ_TX_FOB
      ENDIF    
   ENDIF
ELSE
   IF cArea == "WORK"
      IF !("SEM_FOB" $ cTot)
         nFobTot := Work_SW8->WKPRECO*Work_SW8->WKQTDE
      ENDIF
      IF lDesp
         nFobTot += Work_SW8->WKINLAND+Work_SW8->WKPACKING+Work_SW8->WKOUTDESP-IF(!lIn327,Work_SW8->WKDESCONT,0)+Work_SW8->WKFRETEIN
         IF lSegInc 
            nFobTot += Work_SW8->WKSEGURO
         ENDIF
      ENDIF
      IF lConv
         nFobTot := nFobTot * Work_SW9->W9_TX_FOB
      ENDIF   
   ELSEIF cArea == "TAB"
      IF !("SEM_FOB" $ cTot)
         nFobTot := SW8->W8_PRECO*SW8->W8_QTDE
      ENDIF
      IF lDesp
         nFobTot += SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-IF(!lIn327,SW8->W8_DESCONTO,0)+SW8->W8_FRETEIN
         IF lSegInc 
            nFobTot += SW8->W8_SEGURO
         ENDIF
      ENDIF
      IF lConv
         nFobTot := nFobTot * SW9->W9_TX_FOB
      ENDIF         
   ENDIF                
ENDIF

RETURN nFobTot

***************************
Function DI600Valid(cCampo)
***************************
Private lRet := .T.

PRIVATE cNomeCampo := cCampo     

IF cNomeCampo == NIL
   cNomeCampo:=UPPER(READVAR()) // variavel private da Enchoice
ENDIF

IF Left(cNomeCampo,3) == 'M->'
   cNomeCampo:=Subs(cNomeCampo,4)
ENDIF

Private lSair:=.F.
IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"ANT_DI_VALID"),)
IF lSair
   RETURN lRet
ENDIF   

DO CASE         

   CASE cNomeCampo == 'W7_PESO'
      nOrdX3 := SX3->(IndexOrd())
      SX3->(dbSetOrder(2))
      SX3->(dbSeek("B1_PESO"))
      
      If Int(M->W7_PESO*TSaldo_Q) > (10^(SX3->(X3_TAMANHO-X3_DECIMAL-1))-1)
         MsgStop("Peso unitario incorrecto. Peso total del item no compatible con tamaño del campo producto. ")
         lRet := .F.
      EndIf
      
      SX3->(dbSetOrder(nOrdX3))
      
   CASE cNomeCampo == "WD_MOEDA"
      If !Empty(cMoeda)
         If ExistCpo("SYF",cMOEDA,1)
            ADI600Refresh(@aValores)
            If cMoeda <> EasyGParam("MV_SIMB1",,"$")
               Eval(bAtuTasa)
               oTasa:Refresh() //AWR - 20/08/2008
            Else
               nTasa := 1
            Endif
         Else
            lRet := .F.
         EndIf
      Else
         nTasa := 1
      EndIf
      
   CASE cNomeCampo=="W6_DT"                                   // NCF - 27/07/09 - Validação do campo de data do registro da DI
      IF EMPTY(M->W6_CHEG)                                    //                  em relação ao pre-enchimento do campo de data  
         Help("", 1, "AVG0000721",,AVSX3("W6_CHEG",5),1,8)    //                  da atracação.
//       MSGINFO(ALLTRIM(+0457,0057) //" nao preenchido"
         RETURN .F.
      ENDIF
      
ENDCASE

IF(EasyEntryPoint("EICDI600"),Execblock("EICDI600",.F.,.F.,"DEPOIS_DI_VALID"),)
lRefresh := .T.


Return lRet
//------------------------------------------------------------------------------------//
//                     FIM DO PROGRAMA EICDI600.PRW
//------------------------------------------------------------------------------------//
