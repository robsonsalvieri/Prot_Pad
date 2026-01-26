//Funcao    :EICDI156  
//Autor     :ALEX WALLAUER  25/06/2001 - (Protheus V508)       
//Descricao :Recebimento de Importacao (Solicitacao de Factura)
//Uso       :SIGAEIC                                                     
  
#INCLUDE "EICDI156.ch" 
#INCLUDE "Average.ch"
//#DEFINE  NFE_PRIMEIRA  1
//#DEFINE  NFE_COMPLEMEN 2
//#DEFINE  NFE_UNICA     3
//#DEFINE  CUSTO_REAL    4
#DEFINE  NFE_FOB       '5'//1
#DEFINE  NFE_FRETE     '6'//2
#DEFINE  NFE_SEGURO    '7'//3
#DEFINE  NFE_CIF       '8'//6
#DEFINE  NFE_IMPOSTOS  '9'//4
#DEFINE  NFE_DESPESAS  'A'//5
#DEFINE  CUSTO_REAL    'B'//7
#DEFINE  NFE_PRIMEIRA  "5,6,7,A"//"1,2,3,6"
#DEFINE  NFE_FO_FR_SE  "5,6,7"//"1,2,3"
#DEFINE  NFE_FRE_SEG   "6,7"//"2,3"
#DEFINE  NFE_FOB_SEG   "5,7"//"1,3"	
#DEFINE  NFE_FRE_FOB   "5,6"//"2,1"

*--------------------------*
Function EICDI156()
*--------------------------*
LOCAL cCond:="If(Empty(SW6->W6_DI_NUM) .OR. EMPTY(SW6->W6_TX_US_D),.F.,.T.)"
LOCAL cCampo :=""   
LOCAL cMoedaFOB := ""
Local aCores := {{ '(SW6->W6_STATUS)=="1"' , 'DISABLE' },; 	//VERMELHO  //MLS 17/06/2004
                 { '(SW6->W6_STATUS)=="2"' , 'ENABLE'  },;  //VERDE     //MLS 17/06/2004
	             { '(SW6->W6_STATUS)=="3"' , 'BR_AZUL'} }	//AZUL      //MLS 17/06/2004

LOCAL aFixos:={ { AVSX3("W6_HAWB"   ,5) ,"W6_HAWB"   },; 
                { AVSX3("W6_TX_US_D",5) ,"W6_TX_US_D"},;
                { AVSX3("W6_DI_NUM" ,5) ,"W6_DI_NUM" },; 
                { AVSX3("W6_FOB_TOT",5) ,"W6_FOB_TOT"},; 
                { AVSX3("W6_INLAND" ,5) ,"W6_INLAND" },; 
                { AVSX3("W6_PACKING",5) ,"W6_PACKING"},; 
                { AVSX3("W6_FRETEIN",5) ,"W6_FRETEIN"},; 
                { AVSX3("W6_DESCONT",5) ,"W6_DESCONT"},; 
                { AVSX3("W6_NF_COMP",5) ,"W6_NF_COMP"},; 
                { AVSX3("W6_DT_NFC" ,5) ,"W6_DT_NFC" },; 
                { AVSX3("W6_NF_ENT" ,5) ,"W6_NF_ENT" },;
                { AVSX3("W6_DT_NF"  ,5) ,"W6_DT_NF"  }}

PRIVATE cCadastro := OemtoAnsi(STR0013) //"Recebimento de Importa‡Æo - NF"
PRIVATE lMV_EASY_SIM:=EasyGParam("MV_EASY",,"N") $ cSim
PRIVATE cFormPro := "N"
PRIVATE bSeekWk1,bSeekWk2,bWhileWk,cIndice

//JVR - 18/05/10 - Inclusao de Acrescimos e deducoes na base de impostos
Private lAcresDeduc := SWN->(FIELDPOS("WN_VLACRES")) # 0 .AND. SWN->(FIELDPOS("WN_VLDEDUC")) # 0 .AND. ;
                       EI2->(FIELDPOS("EI2_VACRES")) # 0 .AND. EI2->(FIELDPOS("EI2_VDEDUC")) # 0 .AND. SX3->(dbSeek("EIU"))

PRIVATE aRotina := { {STR0014,'AxPesqui'    , 0 , 1},; //"Pesquisar"  
                     {STR0287,'DI156TipoNF' , 0 , 4}}  //"Entradas"
Private _PictPrUn := ALLTRIM(X3Picture("W3_PRECO")), _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
PRIVATE Work1File,Work1FileA,Work1FileB,Work1FileC,Work1FileD,Work1FileE,Work1FileF
PRIVATE cFileTES,Work2File,Work3File,Work4File,Work4FileA,Work4FileB,nTamRec:=7
PRIVATE cFileWK, cFileWKA
Private lSegInc  := SW9->(FIELDPOS("W9_SEGINC")) # 0 .AND. SW9->(FIELDPOS("W9_SEGURO")) # 0 .AND. ;
                    SW8->(FIELDPOS("W8_SEGURO")) # 0 .AND. SW6->(FIELDPOS("W6_SEGINV")) # 0 // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
Private cMv_ESPEIC := IF(cPaisLoc='BRA' ,GetMv("MV_ESPEIC",,'NFE'),'NF')

// EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
IF lSegInc    
   ASIZE(aFixos, LEN(aFixos)+1)
   AINS( aFixos, 9 )
   aFixos[9] := {AVSX3("W6_SEGINV",5) ,"W6_SEGINV"}
ENDIF

cCampo:=''
SX3->(DBSETORDER(2))
IF(!SX3->(DBSEEK("Y4_FORN"   )),cCampo+=" Y4_FORN",) 
IF(!SX3->(DBSEEK("Y4_LOJA"   )),cCampo+=" Y4_LOJA",) 
IF(!SX3->(DBSEEK("W6_CORRETO")),cCampo+=" W6_CORRETO",) 
IF(!SX3->(DBSEEK("W6_NF_SEG" )),cCampo+=" W6_NF_SEG",)
IF(!SX3->(DBSEEK("YW_FORN"   )),cCampo+=" YW_FORN",) 
IF(!SX3->(DBSEEK("YW_LOJA"   )),cCampo+=" YW_LOJA",) 
IF !EMPTY(cCampo)
   MSGINFO(STR0010+cCampo+chr(13)+chr(10)+;//"Não existe no dicionario: "
           STR0011)//"Saia do Sistema e crie os campos."
   RETURN .T.
ENDIF

IF (T:=LEN(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)) # LEN(SF1->F1_CTR_NFC)
   MSGINFO(STR0343+STRZERO(T,2)+chr(13)+chr(10)+; //"O Campo F1_CTR_NFC deve ter o Tamanho: "
           STR0344) //"Saia do Sistema e altere o campo."
   RETURN .T.
ENDIF

IF (T:=LEN(SWD->WD_NF_COMP)) # LEN(SF1->F1_DOC)
   MSGINFO("O Campo WD_NF_COMP deve ter o Tamanho: "+STRZERO(T,2)+chr(13)+chr(10)+; 
           STR0344) //"Saia do Sistema e altere o campo."
   RETURN .T.
ENDIF

Processa({|| DI156CriaWork()},STR0288) //"Criando Arquivos Temporarios"

bSetKey:=SETKEY(VK_F4)

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"MBROWSE"),)

IF SW6->(FIELDPOS("W6_STATUS")) # 0 //.AND. SIX->(DBSEEK("SF16"))
   AADD(aRotina, {STR0355,'DI156Legend' , 0 , 1} ) //"Legenda" //MLS
   mBrowse( 6, 1,22,75,"SW6",aFixos,,,,,aCores) //MLS 17/06/2004
ELSE
   mBrowse(,,,,"SW6",aFixos,,,cCond)
ENDIF

SetKey(VK_F4,bSetKey)

DI156Final()

SA5->(DBSETORDER(1))
SWZ->(DBSETORDER(1))
SWN->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SF1->(DBSETORDER(1))
SD1->(DBSETORDER(1))
SX3->(DBSETORDER(1))
SWD->(DBSETORDER(1))
DBSELECTAREA("SX3")

Return .T.
*------------------------------------------------*
Function DI156TipoNF(cAlias,nReg,nOpc)
*------------------------------------------------*      
Local nOpcao:=1,nVolta:=0 //"1 - Por FOB"
Local nAltu, nLargu
Local nVertSize

PRIVATE lEIB_Processa:=GETNEWPAR("MV_UTILEIB",.F.)
PRIVATE PICT15_2  := '@E 999,999,999,999.99'                                 
PRIVATE cTipoRat:=STR0289, cFilSW9:=xFilial("SW9"),lTrava:=.F.
PRIVATE lMV_EICNSE2:=EasyGParam("MV_EICNSE2",,.F.)
PRIVATE cTipoNF:='5', nContProc:=0,nTotalPuro:=0,nSomaNoCIF:=0, cMarca := GetMark(), lInverte:=.F.
PRIVATE aOpcoes:={}


DBSELECTAREA("SW6")
IF EasyRecCount() == 0
   Return nOpc
EndIf

AADD(aOpcoes,STR0290) //"Factura FOB"
AADD(aOpcoes,STR0291) //"Factura Flete"
AADD(aOpcoes,STR0292) //"Factura Seguro"
AADD(aOpcoes,STR0346) //"Factura CIF"
AADD(aOpcoes,IF(cPaisLoc="CHI",STR0347,STR0293)) //"Factura Del Agente Aduana"###"Factura Impuestos s/ CIF"
AADD(aOpcoes,STR0294) //"Factura Gastos"
AADD(aOpcoes,STR0037) //"Costo Realizado"

IF cPaisLoc = "PAR" 
   cTipoRat:=STR0295  //"2 - Por Cantidad"
ENDIF
// REGIANE, para trocar o default de rateio e coloquei o cTIPORAT como PRIVATE

IF EasyEntryPoint("EICDI156")
   ExecBlock("EICDI156",.F.,.F.,"OPCOES")
ENDIF               

DO WHILE .T.
  
   nVolta:=0
   nAltu := 430
   nAltu2 := 80
   nAltu3 := 118
   nLargu := 430   
 
   DEFINE MSDIALOG oDlg FROM 117, 180 TO nAltu, nLargu TITLE STR0296 of oMainWnd PIXEL //"Tipo de Factura"

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 1, 1)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 06,10 TO nAltu2,105 LABEL STR0297 OF oPanel  PIXEL  //"Seleção"
      oRad1:=TRadMenu():New(14,18,aOpcoes,{|x| if(x=nil,nOpcao,nOpcao:=x)},oPanel,,,,,,,,080,9,,,.T.,.T.)

      @ 85,10 TO nAltu3,105 LABEL STR0298 OF oPanel  PIXEL  //"Prorateio del Flete"
      @ 93,20 COMBOBOX cTipoRat ITEMS {STR0289,STR0295,STR0299} SIZE 65,42 OF oPanel PIXEL //"1 - Por FOB"###"2 - Por Cantidad"###"3 - Por Peso"
      
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, { || nVolta:=1, oDlg:End() }, { || nVolta:=0, oDlg:End() },,,,,,,.F.) CENTERED

      IF nVolta == 0                      
         EXIT
      ENDIF

      DO CASE
         CASE nOpcao = 1
              cTipoNF:=NFE_FOB       //1  ==> '5'
         CASE nOpcao = 2
              cTipoNF:=NFE_FRETE     //2  ==> '6'
         CASE nOpcao = 3
              cTipoNF:=NFE_SEGURO    //3  ==> '7'
         CASE nOpcao = 4
              cTipoNF:=NFE_CIF       //6  ==> '8'
         CASE nOpcao = 5
              cTipoNF:=NFE_IMPOSTOS  //4  ==> '9' 
         CASE nOpcao = 6
              cTipoNF:=NFE_DESPESAS  //5  ==> 'A'
         CASE nOpcao = 7
              cTipoNF:=CUSTO_REAL    //7  ==> 'B'
      ENDCASE

  IF cTipoNF == NFE_FRETE .AND. EMPTY(ValorFrete(SW6->W6_HAWB,,,2))
     MSGINFO(STR0341,STR0019)//"Valor do Frete nao preenchido."
     LOOP
  ENDIF

  IF cTipoNF == NFE_SEGURO .AND. EMPTY(SW6->W6_VL_USSE)
     MSGINFO(STR0342,STR0019)//"Valor do Seguro nao preenchido."
     LOOP
  ENDIF

  SF1->(DBSETORDER(5))

  IF cTipoNF $ NFE_FO_FR_SE 
     IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+NFE_CIF))
        lAchouNF:=.F.
        DO WHILE SF1->(!EOF())               .AND.;
           SF1->F1_FILIAL  == xFilial("SF1") .AND.;
           SF1->F1_HAWB    == SW6->W6_HAWB   .AND.;
           SF1->F1_TIPO_NF == NFE_CIF
           IF SF1->F1_ESPECIE = "RCN"
              SF1->(DBSKIP())
              LOOP
           ENDIF
           lAchouNF:=.T.
           EXIT
        ENDDO
        IF lAchouNF
           MSGINFO(STR0349,STR0019)//"Proceso ya posee Factura CIF"
           LOOP
        ENDIF
     ENDIF
     IF cTipoNF $ NFE_FRE_SEG .AND. !SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+NFE_FOB))
        lAchouNF:=.F.
        DO WHILE SF1->(!EOF())               .AND.;
           SF1->F1_FILIAL  == xFilial("SF1") .AND.;
           SF1->F1_HAWB    == SW6->W6_HAWB   .AND.;
           SF1->F1_TIPO_NF == NFE_FOB
           IF SF1->F1_ESPECIE = "RCN"
              SF1->(DBSKIP())
              LOOP
           ENDIF
           lAchouNF:=.T.
           EXIT
        ENDDO
        IF lAchouNF
           MSGINFO(STR0350,STR0019)//"Proceso no posee Factura FOB"
           LOOP
        ENDIF
     ENDIF
  ENDIF

  IF cTipoNF == NFE_CIF .AND. SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+NFE_FOB))
     lAchouNF:=.F.
     DO WHILE SF1->(!EOF())               .AND.;
        SF1->F1_FILIAL  == xFilial("SF1") .AND.;
        SF1->F1_HAWB    == SW6->W6_HAWB   .AND.;
        SF1->F1_TIPO_NF == NFE_FOB
        IF SF1->F1_ESPECIE = "RCN"
           SF1->(DBSKIP())
           LOOP
        ENDIF
        lAchouNF:=.T.
        EXIT
     ENDDO
     IF lAchouNF
        MSGINFO(STR0351,STR0019)//"Proceso ya posee Factura FOB"
        LOOP
     ENDIF
  ENDIF

  lSNPeso     :=.F.
  lTemDespesas:=.F.
  lGravaWorks :=.F.
  lNFTemComp  :=.F.
  cNota       :=''
  lLote       := EasyGParam("MV_LOTEEIC",,"N") $ cSim
  lGrvDespSD1 := GETNEWPAR("MV_DESPSD1","N") $ cSim
  lLerFOBPuro := cTipoNF == NFE_IMPOSTOS .AND. GETNEWPAR("MV_FOBPURO",.F.) .AND. SW8->(FIELDPOS("W8_PRECO_F")) # 0
  cFornSWN    := IF(SW6->(FIELDPOS("W6_FORN"))#0,SW6->W6_FORN,"")
  cLojaSWN    := IF(SW6->(FIELDPOS("W6_LOJA"))#0,SW6->W6_LOJA,"")
  lWN_DESPSUB := SWN->(FIELDPOS("WN_DESPSUB"))#0  .AND. (cTipoNF = NFE_IMPOSTOS  .OR. cTipoNF = NFE_DESPESAS)//AWR 21/5/2003
  lWN_CODESP  := SWN->(FIELDPOS("WN_CODESP")) #0
  lTemDespBaseICM:= AVSX3("WN_DESPICM",,,.T.) .AND. IF(EasyGParam("MV_EASY",,"N")$ cSim ,.T.,AVSX3("F1_DESPICM",,,.T.) )
  lCurrier    := SW6->W6_CURRIER $ cSim
  lRatFretePorFOB:=cTipoRat="1"
  lRatFreQtde    :=cTipoRat="2"
  lTrava:=.F.

  IF lGrvDespSD1 .AND. ( cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS )
     lTrava:=.T.
  ENDIF
  
  EI2->(DBSETORDER(1))
  SX6->(DBSETORDER(1))
  SY5->(DBSETORDER(1))
  SA5->(DBSETORDER(3))
  SW2->(DBSETORDER(1))
  SWW->(DBSETORDER(1))

  IF SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+cTipoNF)) .OR.;
     (cTipoNF == CUSTO_REAL .AND. ;
     EI2->(DBSEEK(xFilial("EI2")+SW6->W6_HAWB)))

     lAchouNF:=.T.
     IF cTipoNF # CUSTO_REAL// AWR  - 05/09/2007 - IGNORA A NOTA DE REMITO
        lAchouNF:=.F.
        DO WHILE SF1->(!EOF())               .AND.;
           SF1->F1_FILIAL  == xFilial("SF1") .AND.;
           SF1->F1_HAWB    == SW6->W6_HAWB   .AND.;
           SF1->F1_TIPO_NF == cTipoNF
           IF SF1->F1_ESPECIE = "RCN"
              SF1->(DBSKIP())
              LOOP
           ENDIF
           lAchouNF:=.T.
           EXIT
        ENDDO
     ENDIF

     IF lAchouNF// AWR  - 05/09/2007 - IGNORA A NOTA DE REMITO
        lGravaWorks:=.T.
        lNFTemComp :=.T.
        cNota      :=SF1->F1_CTR_NFC//Nota + Serie + Forn + Loja
     ENDIF

  ENDIF

  If !Empty(SW6->W6_DT_ENCE)
     MSGINFO("Proceso ya encerrado, no es posible "+IF(lGravaWorks,"revertir.","generar."),"Atencion!")
     IF !lGravaWorks
        LOOP
     ENDIF
  ENDIF

  IF !lGravaWorks
     IF EMPTY(SW6->W6_TX_US_D)
        Help('',1,"DI154SEMTX")//Processo nao possui Taxa de Conversao na D.I.
        Return .F.
     ENDIF
     IF EMPTY(SW6->W6_DI_NUM)
        Help(" ",1,"DI154SEMDI")//"Processo nao possui D.I.
        RETURN .F.
     ENDIF

   SW8->(DBSETORDER(1))
   SW9->(DBSETORDER(3))

   IF !SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB)) .OR.;
      !SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
      Help("",1,"AVG0000813")//"Nota Fiscal nao pode ser gerada, Processo nao possui Invoices.",STR0022)
      RETURN .F.
   ENDIF

   SW9->(DBSETORDER(3))
   SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))

   cMoedaFOB := SW9->W9_MOE_FOB
   DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
	                              SW9->W9_HAWB == SW6->W6_HAWB
	  IF EMPTY(SW9->W9_TX_FOB)
         Help("",1,"AVG0000814")//("Existem Invoices sem Taxa FOB.",STR0022)
	     RETURN .F.
	  ENDIF

	  IF SW9->(FIELDPOS("W9_TUDO_OK")) # 0 .AND.;
	     SW9->W9_TUDO_OK = "2"
         Help("",1,"AVG0000815")//"Os valores da Invoice nao estao corretos",AVSX3("W9_INVOICE",5)+": "+SW9->W9_INVOICE)
	     RETURN .F.
	  ENDIF

	  SW9->(DBSKIP())
   ENDDO

   //Varrer a tabela de moeda SYE, para verificar se existe taxa cadastrada antes de gerar as
   //Faturas de Impostos e Despesas (WN_TIPO_NF $ "9A"), Evitar problemas com os Custos.
   //Argentina, Lucas 15/08/07.
   /*
   SWD->(DBSETORDER(1))
   If SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB)) .AND. cTipoNF $ "9A"

	   DO WHILE ! SWD->(EOF()) .AND. SWD->WD_FILIAL == xFilial("SWD") .AND.;
	                              SWD->WD_HAWB == SW6->W6_HAWB
	                              
		  IF ! EMPTY(SWD->WD_DOCTO)
		     SYE->(DbSetOrder(1))
		     If ! SYE->(DbSeek(xFilial("SYE")+DTOS(SWD->WD_DT_EMIS)+cMoedaFOB))
		         //Help("",1,"AVG0250262")     // ("Não existem taxas para o dia "+DTOS(SWD->WD_DT_EMIS)+" !")
		         MsgStop(STR0359+DTOC(SWD->WD_DT_EMIS)+". "+CHR(13)+CHR(10)+;
		                 STR0360,STR0361)
		         RETURN .F.
		     ElseIf SYE->YE_VLFISCA == 0.00
		         //Help("",1,"AVG0250262")     // ("Não existem taxas para o dia "+DTOS(SWD->WD_DT_EMIS)+" !")
		         MsgStop(STR0362+DTOC(SWD->WD_DT_EMIS)+STR0363+CHR(13)+CHR(10)+;
		                 STR0364,STR0361)
		         RETURN .F.		         
		     EndIf    
		     
		  EndIf   
		  
          SWD->(DBSKIP())
 	   ENDDO 
  	ENDIF
    */
  ENDIF

  IF !lGravaWorks .AND. lEIB_Processa .AND.;
     (cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_FRETE .OR. cTipoNF = NFE_CIF)
     EIB->(DBSETORDER(1))
     IF EIB->(DBSEEK(xFilial("EIB")+SW6->W6_HAWB))
        lSNPeso:=MSGYESNO(STR0265,STR0263)
     ENDIF
  ENDIF
  
  Processa({|| DI156GrvDespesa()})

  cDocDespesa :=' '
  cSerieDesp  :=' '
  cFornDespesa:=PADR(GETNEWPAR("MV_FORDESP",' '),LEN(SA2->A2_COD))
  cLojaDespesa:=PADR(GETNEWPAR("MV_LOJDESP",' '),LEN(SA2->A2_LOJA))
  IF SY5->(DBSEEK(XFILIAL("SY5")+SW6->W6_DESP ))
     IF !EMPTY(SY5->Y5_FORNECE)
        cFornDespesa:=SY5->Y5_FORNECE 
        cLojaDespesa:=SY5->Y5_LOJAF   
     ENDIF
  ENDIF
  IF (cTipoNF = NFE_DESPESAS .AND. !lNFTemComp ) .OR.;
     (cTipoNF = NFE_IMPOSTOS .AND. !lGravaWorks)
     nVolta:=DI156DespTela(.T.)                                
  ENDIF

  IF nVolta # 0                      
     If !SW6->(RecLock("SW6",.F.))
        Help(" ",1,"REGNLOCK")
        SW6->(MsUnlock())
        EXIT
     Endif

     DI156NFE()

     SW6->(MsUnlock())

  ENDIF

ENDDO            

IF SW6->(FIELDPOS("W6_STATUS")) # 0 //.AND. SIX->(DBSEEK("SF16"))
   Di156COND()
ENDIF
Return nOpc

*----------------------------------------------------------*
Function DI156NFE()
*----------------------------------------------------------*
LOCAL oDlg, nCoL1, nCoL2, nCoL3, nCoL4, i
PRIVATE aNFsCompCtr:={},aNFsComp:={}

SF1->(DBSETORDER(5))
IF cTipoNF == NFE_DESPESAS .AND.;
   SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+NFE_DESPESAS))

   lGravaWorks:=.F.
   TB_Campos  :={}
   aHeader    :={}
   
   AADD(TB_CAMPOS,{{||WorkNF->F1_DOC+WorkNF->F1_SERIE},,OemToAnsi(STR0027)}) //"N§ Nota Fiscal"
   AADD(TB_CAMPOS,{"F1_FORNECE" ,,STR0084}) //"Fornecedor"
   AADD(TB_CAMPOS,{"F1_EMISSAO" ,,STR0029}) //"Data NF"

   aCampos:={"F1_DOC","F1_SERIE","F1_EMISSAO","F1_CTR_NFC","F1_FORNECE","F1_LOJA"}

   WorkNFile:=E_CriaTrab(,,"WorkNF")
        
   bWhi:={||SF1->F1_TIPO_NF == NFE_DESPESAS .AND. SF1->F1_HAWB == SW6->W6_HAWB}

   bFor:={||IncProc(STR0273+' '+SF1->F1_DOC),;
            SF1->F1_ESPECIE # "RCN" .AND.;// AWR  - 03/9/2004 - IGNORA A NOTA DE REMITO
            ASCAN(aNFsComp,{|N|N[1]==SF1->F1_DOC    .AND.;
                               N[2]==SF1->F1_SERIE  .AND.;
                               N[5]==SF1->F1_FORNECE.AND.;
                               N[6]==SF1->F1_LOJA})=0} //"Lendo Despesa: "

   bGrv:={||ProcRegua(SF1->(LASTREC())),;
   SF1->(DBEVAL({||AADD(aNFsComp,{SF1->F1_DOC    ,;
                                  SF1->F1_SERIE  ,;
                                  SF1->F1_EMISSAO,;
                                  SF1->F1_CTR_NFC,;
                                  SF1->F1_FORNECE,;
                                  SF1->F1_LOJA})},bFor,bWhi))}

   SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+cTipoNF))
   SA2->(DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))//FDR - 21/09/12 - Tratamento de Loja

   Processa(bGrv,STR0031) //"Processando..."

   FOR I:= 1 TO LEN(aNFsComp)
       WorkNF->(DBAPPEND())
       WorkNF->F1_DOC     :=aNFsComp[I][1]
       WorkNF->F1_SERIE   :=aNFsComp[I][2]
       WorkNF->F1_EMISSAO :=aNFsComp[I][3]
       WorkNF->F1_CTR_NFC :=aNFsComp[I][4]
       WorkNF->F1_FORNECE :=aNFsComp[I][5]
       WorkNF->F1_LOJA    :=aNFsComp[I][6]
       IF ASCAN(aNFsCompCtr,aNFsComp[I][4])=0
          AADD (aNFsCompCtr,aNFsComp[I][4])
       ENDIF
   NEXT

   DO WHILE .T.
      nOpca:=0
      WorkNF->(DBGOTOP())
   
      DEFINE MSDIALOG oDlg TITLE STR0032 FROM 0,10 TO 22,55 Of oMainWnd //"Nota Fiscal"

        @1.6,06 BUTTON STR0033 SIZE 38,10 ACTION (nOpca:=2,oDlg:End()) OF oDlg WHEN EMPTY(SW6->W6_DT_ENCE)//"&Inclui"

        @1.6,24 BUTTON (IF(EMPTY(SW6->W6_DT_ENCE),STR0034,"Consulta")) SIZE 38,10 ACTION (nOpca:=1,oDlg:End()) OF oDlg //"&Estorna"

        DBSELECTAREA("WorkNF")
        oMark:=MsSelect():New("WorkNF",,,TB_Campos,.F.,"XX",{35,5,((oDlg:nClientHeight-6)/2)-10,(oDlg:nClientWidth-4)/2})
        oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkNF"),.T. }
        oMark:bAval:={||nOpca:=1,oDlg:End()}//Estorna

      ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||nOpca:=2,oDlg:End()},;//Inclui
                             {||nOpca:=0,oDlg:End()}) CENTERED//Voltar

      IF nOpca==1//Estorna

         cNota :=WorkNF->F1_CTR_NFC//Nota + Serie + Forn + Loja
         cChave:=WorkNF->F1_DOC+WorkNF->F1_SERIE+WorkNF->F1_FORNECE+WorkNF->F1_LOJA+" (SWN) "
         SWN->(DBSETORDER(2))
         If SWN->(DbSeek(xFilial()+WorkNF->F1_DOC+WorkNF->F1_SERIE+WorkNF->F1_FORNECE+WorkNF->F1_LOJA))
            lGravaWorks:=.T.
         ELSE
            MSGINFO(STR0035+cChave+OemToAnsi(STR0036),STR0022) //"Nota Fiscal Complementar: "###" nÆo encontrada"###"Atenção"
            LOOP
         ENDIF

      ELSEIF nOpca == 0//Voltar

         WorkNF->(E_EraseArq(WorkNFile))
         DBSELECTAREA("SW6")
         Return .F.

      ELSEIF nOpca == 2//Inclui

         lNFTemComp:=.F.

      ENDIF

      IF !lNFTemComp
         IF DI156DespTela(.T.) = 0
            lNFTemComp:=.T.//Volta o que estava antes da Inclusao (nOpca == 2) 
            LOOP
         ENDIF
      ENDIF

      WorkNF->(E_EraseArq(WorkNFile))
      DBSELECTAREA("SW6")
      EXIT
   ENDDO 

ENDIF

Work4->(DBSETORDER(3))
Work4->(DBGOTOP())
Work4->(DBEVAL({|| Work4->WKFILTRO:=" "}))

PRIVATE nDecPais  := MSDECIMAIS(1)
PRIVATE PICT15_8  := '@E 999,999.99999999'
PRIVATE PICT21_8  := _PictPrUn
PRIVATE PICTPesoT := AVSX3("B1_PESO",6)
PRIVATE PICTPesoI := AVSX3("B1_PESO",6)
PRIVATE PICT_CPO03:= ALLTRIM(X3PICTURE("B1_POSIPI"))
PRIVATE PICT_CPO07:= _PictQtde//"@E 999,999,999.9999"

PRIVATE lGerouNFE:=.F.,TB_Campos2:={},nOpca := 0
PRIVATE MDI_FOB:=MDI_FOB_R:=MDI_FRET_MOE:=MDI_FRETE:=MDI_SEGURO:=MDI_CIF:=0
PRIVATE MDespesas:=MDespMoeda:=MDI_QTDE:=MDI_PESO:=MLin:=MDI_OUTR:=MDI_OU_US:=MDI_CIFMOE:=0
PRIVATE n_Tx_Fre:=0.00 // Regiane 29/10/2007 Para usar com o ponto de entrada ALT_TAXA
PRIVATE aDespesa:={}
PRIVATE n_CIF:=0
PRIVATE nFob:=0,nPesoL:=0,nTx_Seguro:=0,cTipoTx:=""
PRIVATE aLista:={}
PRIVATE nFob_R:=0, n_Frete:=0, n_Seguro:=0
PRIVATE cNumNFE, cSerieNFE, dDtNFE
PRIVATE lNFAutomatica  :=GetNewPar("MV_NF_AUTO","N") $ cSim
PRIVATE lQuebraOperacao:=GetNewPar("MV_QB_OPER","N") $ cSim
PRIVATE cMoeDolar:=GetNewPar("MV_SIMB2","US$")                                                    
PRIVATE nTotImpostos :=0
PRIVATE lAlterouPeso :=.F.//Variavel usada para verificar se houve alteracao nas aliquotas e peso
PRIVATE cDespSelo:=' ', nTotSelo:=0

SW9->(DBSETORDER(3))
SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))
SW7->(DBSETORDER(1))
SW7->(DbSeek(xFilial()+SW6->W6_HAWB))
SW2->(DBSETORDER(1))
SW2->(dBSeek(xFilial()+SW7->W7_PO_NUM))
SA2->(DBSETORDER(1))
SA2->(DbSeek(xFilial()+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))//FDR - 21/09/12 - Tratamento de Loja
PRIVATE n_Tx_Fob  := SW9->W9_TX_FOB
PRIVATE lTemSelo  := !Empty(cDespSelo:=GetNewPar("MV_SELO"," ")) 
cMoeDolar := IF(EMPTY(cMoeDolar),"US$",cMoeDolar)
PRIVATE cMoedaProc:= cMoeDolar//SW2->W2_MOEDA
PRIVATE cRatProc  := GETNEWPAR("MV_RATPROC","N") 

Private aDeletados := {}//JVR - 21/05/10 - Utilizado no tratamento de acrescimo e deduções.

Work1  ->(AvZap())   
Work2  ->(AvZap())   
Work3  ->(AvZap())   
WorkTES->(AvZap())   
Work_Tot->(AvZap())

IF lGravaWorks
   Processa({|| DI156GrWorks()},STR0068) //"Pesquisando Informa‡äes..."
ELSE
   Processa({|| DI156Grava()  },STR0068) //"Pesquisando Informa‡äes..."
ENDIF

IF cTipoNF==NFE_DESPESAS
   If Empty(MDI_OUTR)
      Help(" ",1,"AVG0000340")//"Nao ha despesas p/ geracao de Nota Fiscal
      Return .F.
   Endif
Endif

IF (Work2->(BOF()) .AND. Work2->(EOF())) .OR.;
   (Work1->(BOF()) .AND. Work1->(EOF()))
   IF !lGravaWorks
      Help(" ",1,"EICSEMREG")
      Return .F.
   ENDIF
ENDIF

SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
SW2->(dBSeek(xFilial("SW2")+SW7->W7_PO_NUM))
TB_Campos1:={}
AADD(TB_Campos1,{"WK_CFO"   ,, STR0039 }) //"C.F.O."
AADD(TB_Campos1,{{||Work2->WK_OPERACA+"/"+TRAN(Work2->WKTEC,PICT_CPO03)+"/"+Work2->WKEX_NCM+"/"+Work2->WKEX_NBM},"",STR0040}) //"Operacao/TEC/Ex-NCM/Ex-NBM"
AADD(TB_Campos1,{"WKPESOL"  ,, STR0144 ,PICTPesoT }) //"Peso Adicao"
IF cTipoNF = NFE_FOB .OR. cTipoNF = NFE_IMPOSTOS
   AADD(TB_Campos1,{"WKTES","","TES",}) //TES  //TRP-10/01/08
ENDIF
IF lRatFreQtde .AND. (cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_FRETE)
   AADD(TB_Campos1,{"WKQTDE",, STR0057 ,PICT_CPO07}) //"Quantidade"
ENDIF
IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_CIF .OR. cTipoNF = CUSTO_REAL
   //AADD(TB_Campos1,{"WKCIF"     ,,STR0058,PICT15_2}) //"Preco Total (R$)"
   AADD(TB_Campos1,{"WKCIF"     ,,STR0058+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //Precio Total 
   AADD(TB_Campos1,{"WKFOB_US"  ,,STR0058+" ("+cMoeDolar+")",_PictPrUn}) //"Preco Total"
   AADD(TB_Campos1,{"WKFOB_R"   ,,STR0042+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"FOB"
   AADD(TB_Campos1,{"WKFRETE"   ,,STR0043+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"FRETE"
   AADD(TB_Campos1,{"WKSEGURO"  ,,STR0044+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"SEGURO"
   IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      AADD(TB_Campos1,{"WKOUTRDESP",,STR0053+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"Outras Despesas"
   ENDIF
ELSE
   //AADD(TB_Campos1,{"WKFOB_R"  ,, OemToAnsi(STR0058),PICT15_2})//"Preco Total (R$)"
   AADD(TB_Campos1,{"WKFOB_R"  ,, OemToAnsi(STR0058)+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2})//"Precio Total"  
   AADD(TB_Campos1,{"WKFOB_US" ,,STR0058+" ("+cMoeDolar+")",_PictPrUn}) //"Precio Total"
ENDIF

IF cPaisLoc # "BRA" .And. lAcresDeduc //JVR - 25/05/10 - Acrescimo/Deduçao.
   AADD(TB_Campos1,{"WKACRES",,STR0371,PICT15_2})
   AADD(TB_Campos1,{"WKDEDUC",,STR0372,PICT15_2})
ENDIF

IF !lGravaWorks .AND. !lNFAutomatica .AND. cTipoNF # CUSTO_REAL
    AADD(TB_Campos2,{"WKFLAG","" ,"",})
ENDIF
IF cTipoNF == CUSTO_REAL
   AADD(TB_Campos2,{"WK_NFE",,OemToAnsi(STR0037),}) //"Costo Realizado"
ELSE
   AADD(TB_Campos2,{"WK_NFE"    ,,STR0038})//"Factura"
   AADD(TB_Campos2,{"WK_SE_NFE" ,,STR0095})//"Serie"
   IF cTipoNF = NFE_DESPESAS
      AADD(TB_Campos2,{"WKDESPESA" ,"" ,STR0302,}) //"Despesa"
   ENDIF
ENDIF
AADD(TB_Campos2,{"WKFORN",,AVSX3("W7_FORN",5),})  
//FDR - 19/09/12 - Tratamento de Loja
If EICLoja()
   AADD(TB_Campos2,{"WKLOJA"    ,"" ,"Loja"      ,})
EndIf
AADD(TB_Campos2,{{||Work1->WK_OPERACA+" "+TRAN(Work1->WKTEC,PICT_CPO03)+" "+Work1->WKEX_NCM+" "+Work1->WKEX_NBM},,STR0040,}) //"Operacao/TEC/Ex-NCM/Ex-NBM"
AADD(TB_Campos2,{"WKCOD_I"   ,"" ,OemToAnsi(STR0054)           ,}) //"Cod. Item"
AADD(TB_Campos2,{{||Left(Work1->WKDESCR,35)},,OemToAnsi(STR0055)}) //"Descricao do Item"
AADD(TB_Campos2,{"WKPESOL"   ,"" ,OemToAnsi(STR0041),PICTPesoI}) //"Peso Liquido"
AADD(TB_Campos2,{"WKPRUNI"   ,"" ,OemToAnsi(STR0056)+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT21_8 }) //"Precio Unitario(R$)"
AADD(TB_Campos2,{"WKQTDE"    ,"" , STR0057          ,PICT_CPO07}) //"Quantidade"
AADD(TB_Campos2,{"WKVALMERC" ,"" ,OemToAnsi(STR0058)+" ("+EasyGParam("MV_SIMB1",,"R$")+")",_PictPrUn}) //"Precio Total"
AADD(TB_Campos2,{"WKVALMERUS","" ,STR0058+' ('+cMoeDolar+')',_PictPrUn}) //"Precio Total"
IF lLerFOBPuro .AND. !lGravaWorks .AND. !cTipoNF = NFE_DESPESAS
   AADD(TB_Campos2,{"WKPRECO_F",,AVSX3("W8_PRECO_F",5),AVSX3("W8_PRECO_F",6)})
ENDIF
IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_CIF .OR. cTipoNF = CUSTO_REAL
   AADD(TB_Campos2,{"WKFOB_R"   ,,STR0042+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"FOB"
   AADD(TB_Campos2,{"WKFRETE"   ,,STR0043+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"Frete"
   AADD(TB_Campos2,{"WKSEGURO"  ,,STR0044+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"Seguro"
   IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      AADD(TB_Campos2,{"WKCIF"     ,,STR0045+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"C.I.F."
      AADD(TB_Campos2,{"WKOUT_DESP",,STR0053+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"Outras Despesas"
   ENDIF
// AADD(TB_Campos2,{"WKCIF"     ,"" , STR0045          ,PICT15_2}) //"C.I.F. (R$)"
ENDIF
IF cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
   AADD(TB_Campos2,{"WKTES"     ,,AVSX3("YB_TES",5)})//TES
   AADD(TB_Campos2,{"WKIMPOSTOS",,STR0303          ,PICT15_2}) //"Impuestos"
ENDIF
AADD(TB_Campos2,{"WKPO_NUM",,STR0063,}) //"P.O. No."
IF lLote
   AADD(TB_Campos2,{"WK_LOTE"  ,,STR0064}) //"No. Lote"
   AADD(TB_Campos2,{"WKDTVALID",,STR0065}) //"Dt. Validade"
ENDIF
AADD(TB_Campos2,{"WK_DT_NFE",,STR0096})
IF lWN_DESPSUB
   AADD(TB_Campos2,{"WKDESPSUB",, AVSX3("WN_DESPSUB",5),PICT15_2 })
ENDIF
IF cPaisLoc # "BRA" .ANd. !lGravaWorks   // EOS - 06/10/03 
   AADD(TB_Campos2,{"WKLOCAL",,AVSX3("C1_LOCAL",5),})
ENDIF

IF cPaisLoc # "BRA" .And. lAcresDeduc //JVR - 25/05/10 - Acrescimo/Deduçao.
   AADD(TB_Campos2,{"WKACRES",,STR0371,PICT15_2})
   AADD(TB_Campos2,{"WKDEDUC",,STR0372,PICT15_2})
ENDIF

IF EasyEntryPoint("EICDI156")
   ExecBlock("EICDI156",.F.,.F.,"TB_CAMPOS2")
ENDIF               

IF cTipoNF==NFE_DESPESAS

   nFob_R  :=0
   n_Frete :=0
   n_Seguro:=0
   n_CIF   :=0
   n_Desp  :=0
   n_Tx_Fob:=0
   n_Vl_Fre:=0
   n_Tx_Fre:=0
   n_Vl_USS:=0
   n_Tx_Seg:=0
   MDI_FOB :=0

ELSE
   
   nFob_R  :=IF(lLerFOBPuro,nTotalPuro,MDI_FOB_R)
   n_Frete :=MDI_FRETE
   n_Seguro:=MDI_SEGURO
   n_CIF   :=MDI_CIF
   n_Desp  :=MDespMoeda//MDespesas
   n_Vl_Fre:=MDI_FRET_MOE
   n_Tx_Fre:=SW6->W6_TX_FRET
   n_Tx_Seg:=nTx_Seguro
// n_Vl_USS:=SW6->W6_VL_USSE
// n_Vl_USS := DITRANS((n_SEGURO / IF(EMPTY(n_Tx_Seg),1,n_Tx_Seg)))   
//Bete 15/03/06 - Por se tratar de moeda estrangeira(US$), nao devemos arredondar
   n_Vl_USS := n_SEGURO / IF(EMPTY(n_Tx_Seg),1,n_Tx_Seg)   
   IF cTipoNF==NFE_FOB
      n_Tx_Seg:=0
      n_Tx_Fre:=0
      n_Vl_USS:=0
      n_Vl_Fre:=0
      n_Desp  :=0
   ELSEIF cTipoNF==NFE_FRETE
      MDI_FOB :=0
      n_Vl_USS:=0
      n_Tx_Seg:=0
      n_Tx_FOB:=0
      n_Desp  :=0
   ELSEIF cTipoNF==NFE_SEGURO
      MDI_FOB :=0
      n_Vl_Fre:=0
      n_Tx_Fre:=0
      n_Tx_FOB:=0
      n_Desp  :=0
   ENDIF
ENDIF

//ER - 18/10/2007
IF EasyEntryPoint("EICDI156")
   ExecBlock("EICDI156",.F.,.F.,"ALT_TAXA")
ENDIF               

cPictDI:=IF(RIGHT(STR(MDI_FOB,15,4),2)="00",;
              PICT15_2,"@E 999,999,999,999.9999")
cTotal  :=STR0280
n_VlTota:=DITRANS(n_CIF+MDI_OUTR)
IF cTipoNF==NFE_FRETE
   n_VlTota:=n_FRETE
ELSEIF cTipoNF==NFE_SEGURO
   n_VlTota:=n_SEGURO
ENDIF

nL1:=1.4; nL2:=2.2; nL3:=3.0; nL4:=3.8; nL5:=4.6; nL6:=5.4; nL7:=6.2; nL8:=7.0
nC1:=0.7; nC2:=5.2; nC3:=13.0; nC4:=18.2; nC5:=25.7; nC6:=31.2


Work2->(DBGOTOP())
Work1->(DBGOTOP())

SA2->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW2->(DBSETORDER(1))
SYT->(DBSETORDER(1))
SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
SW2->(dBSeek(xFilial("SW2")+SW7->W7_PO_NUM))
SYT->(dBSeek(xFilial("SYT")+SW2->W2_IMPORT))
SA2->(DbSeek(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))//FDR - 20/09/12 - Tratamento de Loja
cTit:=cCadastro
DO CASE
   CASE cTipoNF == NFE_FOB
        cTit+="  ["+ALLTRIM(aOpcoes[1])+"]"

   CASE cTipoNF==NFE_FRETE
        cTit+="  ["+ALLTRIM(aOpcoes[2])+"]"

   CASE cTipoNF==NFE_SEGURO
        cTit+="  ["+ALLTRIM(aOpcoes[3])+"]"

   CASE cTipoNF==NFE_CIF
        cTit+="  ["+ALLTRIM(aOpcoes[4])+"]"

   CASE cTipoNF==NFE_IMPOSTOS
        cTit+="  ["+ALLTRIM(aOpcoes[5])+"]"

   CASE cTipoNF==NFE_DESPESAS
        cTit+="  ["+ALLTRIM(aOpcoes[6])+"]"

   CASE cTipoNF==CUSTO_REAL
        cTit+="  ["+ALLTRIM(STR0018)+"]"

ENDCASE

//JVR - 26/05/10
DI156VAl_AD( SW6->W6_HAWB, .T., "WORK1", .T., .T.)
DI156VAl_AD( SW6->W6_HAWB, .T., "WORK2", .T., .T.)

DO WHILE .T.

   lGeraNF:=.T.
   nOpca:=000
   nLin :=0.1
   nCoL1:=005
   nCoL2:=050
   nCoL3:=122
   nCoL4:=172
   nCoL5:=255
   
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE cTit ;
      FROM oMainWnd:nTop+060,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL  

   nSize:= 56 
                  
   @ nLin,nLin TO nLin+116,249       PIXEL
   @ nLin,250  TO nLin+116,260+nSize PIXEL

   nLin+=04
   @ nLin,nCoL1 SAY AVSX3("W6_HAWB",5) SIZE 58,7 PIXEL
   @ nLin,nCoL2 MSGET SW6->W6_HAWB     WHEN .F. SIZE 58,8 PIXEL

   @ nLin,nCoL3 SAY AVSX3("W6_DT_DESE",5) SIZE 58,7 PIXEL//"Dt.Desembaraço"  
   @ nLin,nCoL4 MSGET SW6->W6_DT_DESE     WHEN .F. SIZE 58,8 PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0084        SIZE 58,7 PIXEL//"Fornecedor"
   cForn:=aLista[1]
   IF LEN(aLista) < 2
      @ nLin,nCoL2 MSGET cForn WHEN .F. SIZE 180,8 PIXEL
   ELSE
      @ nLin,nCoL2 LISTBOX cForn ITEMS aLista SIZE 180,10 PIXEL
   ENDIF
   nLin+=12
   @ nLin,nCoL1 SAY STR0083        SIZE 58,7 PIXEL//"Importador" 
   @ nLin,nCoL2 MSGET SYT->YT_NOME WHEN .F. SIZE 180,8 PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY AVSX3("W6_DI_NUM",5) SIZE 58,7 PIXEL//"Nº D.I."
   @ nLin,nCoL2 MSGET SW6->W6_DI_NUM     WHEN .F. SIZE 58,8 PIXEL

   @ nLin,nCoL3 SAY AVSX3("W6_DTREG_D",5) SIZE 58,7 PIXEL
   @ nLin,nCoL4 MSGET SW6->W6_DTREG_D     WHEN .F. SIZE 58,8 PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0073+"("+SW6->W6_FREMOED+")" SIZE 58,7 PIXEL//"Frete
   @ nLin,nCoL2 MSGET n_Vl_Fre  PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   @ nLin,nCoL3 SAY AVSX3("W6_TX_FRET",5) SIZE 58,7 PIXEL
   @ nLin,nCoL4 MSGET n_Tx_Fre PICTURE PICT15_8 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0075+"("+SW6->W6_SEGMOEDA+")" SIZE 58,7 PIXEL//"Seguro
   @ nLin,nCoL2 MSGET n_Vl_USS  PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   @ nLin,nCoL3 SAY STR0076+cTipoTx SIZE 58,7 PIXEL//"Tx Seg "
   @ nLin,nCoL4 MSGET n_Tx_Seg PICTURE PICT15_8 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0071 SIZE 58,7 PIXEL//"Despesas"
   @ nLin,nCoL2 MSGET n_Desp  PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   @ nLin,nCoL3 SAY STR0274+" ("+EasyGParam("MV_SIMB1",,"R$")+")" SIZE 58,7 PIXEL //"Total Geral"
   @ nLin,nCoL4 MSGET n_VlTota PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

   If lAcresDeduc
      nLin+=12
      aValores := DI156VAl_AD(SW6->W6_HAWB)
      @ nLin,nCoL1 SAY STR0371 SIZE 58,7 PIXEL//"Acrescimo"
      @ nLin,nCoL2 MSGET aValores[1]  PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL

      @ nLin,nCoL3 SAY STR0372 SIZE 58,7 PIXEL //"Deduçao"
      @ nLin,nCoL4 MSGET aValores[2] PICTURE PICT15_2 SIZE 58, 7 OF oDlg WHEN .F. RIGHT PIXEL 
   EndIf


   nLin:=05
   @ nLin,nCoL5 BUTTON STR0103 SIZE nSize,12 ACTION (nOpca:=0,oDlg:End()) OF oDlg PIXEL //"&Sair"
   nLin+=12
   @ nLin,nCoL5 BUTTON STR0085 SIZE nSize,12 ACTION ; //"&Estorno"
                               (nOpca:=1,oDlg:End()) WHEN ((lGravaWorks .OR. (lGerouNFE.AND.cTipoNF # NFE_DESPESAS)) .AND. EMPTY(SW6->W6_DT_ENCE) ) OF oDlg PIXEL
   IF !lGravaWorks
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0089 SIZE nSize,12 ACTION (nOpca:=2,oDlg:End()) OF oDlg PIXEL //"&Itens"
   ENDIF

   IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_CIF .OR. cTipoNF = CUSTO_REAL
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0275 SIZE nSize,12 ACTION (DI156ValTxTela()) OF oDlg PIXEL //"&Valores/Taxas"
   ENDIF

   nLin+=12
   @ nLin,nCoL5 BUTTON STR0276 SIZE nSize,12 ACTION (DI156DespTela(.F.))  OF oDlg PIXEL //"&Despesas"

   //TRP-10/01/08
   IF (cTipoNF = NFE_FOB .OR. cTipoNF = NFE_IMPOSTOS) .AND. !lGravaWorks .AND. cPaisLoc == "ARG" .AND.;
      SWN->( FieldPos("WN_TES") ) > 0 .AND. SW7->( FieldPos("W7_TES") ) > 0
      nLin+=12
      @ nLin,nCoL5 BUTTON "Modifica TES" SIZE nSize,12 ACTION (DI156AltTes())  OF oDlg PIXEL //"Modifica TES"
   ENDIF
   
    //JVR - 18/05/10 - Tratamento de Acrescimo.
   If lAcresDeduc .AND. cTipoNF = NFE_IMPOSTOS// .AND. lGravaWorks
      nLin+=12
      @ nLin,nCoL5 BUTTON "Acresc/Deduc." SIZE nSize,12 ACTION (DI156Manu_AD(),DI156GerImpostos(.F.),oDlg:Refresh()) OF oDlg PIXEL // "Acresc/Deduc."
   ENDIF
   
   IF !lGravaWorks .AND. !lGerouNFE .AND. !lRatFretePorFOB .AND. !lRatFreQtde .AND.;
      (cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_FRETE .OR.;
       cTipoNF = NFE_CIF .OR. cTipoNF = CUSTO_REAL)
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0304 SIZE nSize,12 ACTION (DI156Altera()) OF oDlg PIXEL  //"&Altera Peso"
   ENDIF                                     

   IF lGravaWorks 
      nLin+=12 
      @ nLin,nCoL5 BUTTON STR0278 SIZE nSize,12 ACTION (nOpca:=3,oDlg:End()) OF oDlg PIXEL //"I&mpressão"
   ENDIF

   IF cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      nLin+=12 
      @ nLin,nCoL5 BUTTON STR0303 SIZE nSize,12 ACTION (DI156TelaImpostos(!lGravaWorks)) OF oDlg PIXEL //"Impuestos"
     // IF lGravaWorks// MLS 22/06/2004
      nLin+=12 
      IF cTipoNF =  NFE_IMPOSTOS
         @ nLin,nCoL5 BUTTON STR0100 SIZE nSize,12 ACTION (DI156TOTAIS()) OF oDlg PIXEL //"&Totais"     
         else
         @ nLin,nCoL5 BUTTON STR0100 SIZE nSize,12 ACTION (DI156MostraTotais()) OF oDlg PIXEL //"&Totais"
      endif   
     // ENDIF  // MLS 22/06/2004
   ENDIF

   IF SetMDIChild()
      nLinha:=075
   ELSE
      nLinha:=103
   ENDIF

   If lAcresDeduc .AND. cTipoNF = NFE_IMPOSTOS .and. !lGravaWorks
      nLinha += 12
   EndIf
   IF lGravaWorks
      Work1->(dbsetorder(2))
      DBSELECTAREA("Work1")
      DBGOTOP()
      oMark:= MsSelect():New('Work1',,,TB_Campos2,.F.,"XX",{nLinha,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
      oMark:oBrowse:bWhen:={|| DBSELECTAREA("Work1"),.T. }
   ELSE
      DBSELECTAREA("Work2")
      DBGOTOP()
      oMark:= MsSelect():New('Work2',,,TB_Campos1,.F.,"XX",{nLinha,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
      oMark:oBrowse:bWhen:={|| DBSELECTAREA("Work2"),.T. }
   ENDIF

   oMark:oBrowse:Align:=CONTROL_ALIGN_BOTTOM
   oDlg:lMaximized:=.T.

   IF cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      oMark:bAval:={|| DI156TelaImpostos(!lGravaWorks)}
   ENDIF

   IF (EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'TELA1'),)
   
   ACTIVATE MSDIALOG oDlg 

   DO CASE
      CASE nOpca = 0            
           IF !lGravaWorks .AND. !lGerouNFE .AND. lAlterouPeso  .AND.;
              (cTipoNF = NFE_IMPOSTOS .OR.;
               cTipoNF = NFE_FRETE    .OR.;
               cTipoNF = NFE_CIF      .OR.;
               cTipoNF = CUSTO_REAL)    .AND.;
              lEIB_Processa .AND.  MsgYesNo(STR0260) //"Deseja Gravar as Alterações das N.C.M.'s ?"
              DI156LeEIB(.F.)  
           ENDIF
           EXIT
      CASE nOpca = 1 
           lDel:=.T.
           IF (EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'ESTORNA'),)
           IF lDel .AND. MsgYesNo(STR0087,STR0088)//"Confirma Estorno ?"###"Estorno"
              lDeletou:=.T.
              Processa({|| lDeletou:=DI156Delet()},STR0090) //"Processando Estorno..."
              IF lDeletou
                 EXIT 
              ENDIF
           ENDIF
      CASE nOpca = 2 ; DI156Itens() // Itens
      CASE nOpca = 3 ; EICDI157(cTipoNF) //Impressão
   ENDCASE

ENDDO

Return( nOpca )

*------------------------------------------------*
Function DI156ValTxTela()
*------------------------------------------------*      
LOCAL oDlg, nLin, nCoL1, nCoL2, nCoL3, nCoL4, nCoL5, nCoL6, nAltuPnl

nLin :=005//JVR - 28/07/09 - Alinhamento dos itens na tela.
nCoL1:=003
nCoL2:=047
nCoL3:=107
nCoL4:=152
nCoL5:=212
nCoL6:=253
aTB_CpoTot:={}
AADD(aTB_CpoTot,{"W9_MOE_FOB" ,,AVSX3("W9_MOE_FOB",5),AVSX3("W9_MOE_FOB",6)})
AADD(aTB_CpoTot,{"W9_FOB_TOT" ,,AVSX3("W9_FOB_TOT",5),AVSX3("W9_FOB_TOT",6)})
IF lLerFOBPuro//so p/ NF impostos
   AADD(aTB_CpoTot,{"W8_PRECO_F",,AVSX3("W8_PRECO_F",5),AVSX3("W8_PRECO_F",6)})
ENDIF
AADD(aTB_CpoTot,{"W9_INLAND"  ,,AVSX3("W9_INLAND" ,5),AVSX3("W9_INLAND" ,6)})
AADD(aTB_CpoTot,{"W9_PACKING" ,,AVSX3("W9_PACKING",5),AVSX3("W9_PACKING",6)})
AADD(aTB_CpoTot,{"W9_DESCONT" ,,AVSX3("W9_DESCONT",5),AVSX3("W9_DESCONT",6)})
AADD(aTB_CpoTot,{"W9_FRETEIN" ,,AVSX3("W9_FRETEIN",5),AVSX3("W9_FRETEIN",6)})
AADD(aTB_CpoTot,{"W9_OUTDESP" ,,AVSX3("W9_OUTDESP",5),AVSX3("W9_OUTDESP",6)})
// EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP
IF lSegInc
   AADD(aTB_CpoTot,{"W9_SEGURO",,AVSX3("W9_SEGURO",5),AVSX3("W9_SEGURO",6)})
ENDIF
AADD(aTB_CpoTot,{"W6_FOB_TOT" ,,"Total Geral"        ,AVSX3("W6_FOB_TOT",6)})


IF Work_Tot->(BOF()) .AND. Work_Tot->(EOF())
   Processa({|| DI156SomaTotais() },"Somando totais") 
ENDIF                             

nAltuPnl:=80

DEFINE MSDIALOG oDlg TITLE STR0279 ; //"Visualiza Valores/Taxas"
       FROM oMainWnd:nTop+080,oMainWnd:nLeft TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
       OF oMainWnd PIXEL  

   //TPanel():New( [ nRow ], [ nCol ], [ cText ], [ oWnd ], [ oFont ], [ lCentered ], [ uParam7 ], [ nClrText ], [ nClrBack ], [ nWidth ], [ nHeight ], [ lLowered ], [ lRaised ] )

   oPnl1:= TPanel():New(0, 0, "", oDlg, , .F., .F.,,, 116, nAltuPnl)
   oPnl1:Align:= CONTROL_ALIGN_TOP

   @ nLin,nCoL1 SAY STR0042 +" ("+EasyGParam("MV_SIMB1",,"R$")+")" SIZE 57,7 OF oPnl1 PIXEL//"FOB"
   @ nLin,nCoL2 MSGET nFOB_R PICTURE PICT15_2 SIZE 57, 7 OF oPnl1 WHEN .F. RIGHT  PIXEL

   @ nLin,nCoL3 SAY STR0043+" ("+EasyGParam("MV_SIMB1",,"R$")+")" SIZE 57,7 OF oPnl1 PIXEL//"Frete" 
   @ nLin,nCoL4 MSGET n_FRETE PICTURE PICT15_2 SIZE 57, 7 OF oPnl1 WHEN .F. RIGHT  PIXEL

   @ nLin,nCoL5 SAY STR0044+" ("+EasyGParam("MV_SIMB1",,"R$")+")"    SIZE 57,7 OF oPnl1 PIXEL //"Seguro"
   @ nLin,nCoL6 MSGET n_SEGURO PICTURE PICT15_2 SIZE 57, 7 OF oPnl1 WHEN .F. RIGHT  PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0053+" ("+EasyGParam("MV_SIMB1",,"R$")+")" SIZE 57,7 OF oPnl1 PIXEL//"Outras Despesas"
   @ nLin,nCoL2 MSGET MDI_OUTR PICTURE PICT15_2 SIZE 57, 7 OF oPnl1 WHEN .F. RIGHT PIXEL

   @ nLin,nCoL3 SAY AVSX3("W6_TX_US_D",5) SIZE 57,7 OF oPnl1 PIXEL
   @ nLin,nCoL4 MSGET SW6->W6_TX_US_D PICTURE PICT15_8 SIZE 57, 7 OF oPnl1 WHEN .F. RIGHT PIXEL

   @ nLin,nCoL5 SAY STR0284+" ("+EasyGParam("MV_SIMB1",,"R$")+")" SIZE 57,7 OF oPnl1 PIXEL//"Desp. Base"
   @ nLin,nCoL6 MSGET nSomaNoCIF PICTURE PICT15_2 SIZE 57, 7 OF oPnl1 WHEN .F. RIGHT PIXEL

   nLin+=12
   @ nLin,nCoL5 SAY STR0305+" ("+EasyGParam("MV_SIMB1",,"R$")+")" SIZE 57,7 OF oPnl1 PIXEL //"Total General"
   @ nLin,nCoL6 MSGET n_vlTota PICTURE PICT15_2 SIZE 57, 7 OF oPnl1 WHEN .F. RIGHT PIXEL

   oMarkTot:=MSSELECT():New("Work_Tot",,,aTB_CpoTot,lInverte,cMarca,{1,1,1,1})
   oMarkTot:oBrowse:bWhen:={||DBSELECTAREA("Work_Tot"),.T.}
   oMarkTot:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT   

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, { || oDlg:End() }, { || oDlg:End() },,,,,,,.F.) CENTERED

RETURN .T.

*------------------------------------*
Function DI156SomaTotais()
*------------------------------------*
LOCAL cFilSW8:=xFilial("SW8")
LOCAL cFilSW9:=xFilial("SW9")
Local lExistEZZ:= SX2->(dbSeek("EZZ"))
PRIVATE lTotaisInv:=.F.

ProcRegua(SW8->(LASTREC()))
SW8->(DBSETORDER(1))
SW9->(DBSETORDER(1))

SW8->(DBSEEK(cFilSW8+SW6->W6_HAWB))

DO While !SW8->(Eof()) .AND. ;
          SW8->W8_FILIAL == cFilSW8 .AND.;
          SW8->W8_HAWB   == SW6->W6_HAWB

   IncProc("Somando Invoice: "+SW8->W8_INVOICE)

	   SW9->(DBSEEK(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")))//FDR - 21/09/12 - Tratamento de Loja
   
   IF lTotaisInv
      Work_Tot->(DBSETORDER(1))
      IF !Work_Tot->(DBSEEK('1'+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")))//FDR - 21/09/12 - Tratamento de Loja
          Work_Tot->(DBAPPEND())
          Work_Tot->WKCODIGO  :='1'
          Work_Tot->W9_INVOICE:=SW8->W8_INVOICE
          Work_Tot->W9_FORN   :=SW8->W8_FORN
          //FDR - 19/09/12 - Tratamento de Loja
          If EICLoja()
             Work_TOT->W9_FORLOJ := SW8->W8_FORLOJ
          EndIf
          Work_Tot->W9_MOE_FOB:=SW9->W9_MOE_FOB
      ENDIF
      Work_Tot->W9_FOB_TOT+=(SW8->W8_PRECO*SW8->W8_QTDE)
      Work_Tot->W9_INLAND +=SW8->W8_INLAND
      Work_Tot->W9_PACKING+=SW8->W8_PACKING
      Work_Tot->W9_DESCONT+=SW8->W8_DESCONT
      Work_Tot->W9_FRETEIN+=SW8->W8_FRETEIN
      Work_Tot->W9_OUTDESP+=SW8->W8_OUTDESP
      // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         Work_Tot->W9_SEGURO+=SW8->W8_SEGURO
      ENDIF       
      Work_Tot->W6_FOB_TOT+=DI600RetVal("ITEM_INV", "TAB", .T.) // EOB - 03/06/08 - chamada da função DI600RetVal
   ENDIF
   Work_Tot->(DBSETORDER(2))
   IF !Work_Tot->(DBSEEK('2'+SW9->W9_MOE_FOB))
      Work_Tot->(DBAPPEND())
      Work_Tot->WKCODIGO  :='2'
      Work_Tot->W9_INVOICE:="Total Moeda:"
      Work_Tot->W9_MOE_FOB:=SW9->W9_MOE_FOB
   ENDIF
   Work_Tot->W9_FOB_TOT+=(SW8->W8_PRECO*SW8->W8_QTDE)
   Work_Tot->W9_INLAND +=SW8->W8_INLAND
   Work_Tot->W9_PACKING+=SW8->W8_PACKING
   Work_Tot->W9_DESCONT+=SW8->W8_DESCONT
   Work_Tot->W9_FRETEIN+=SW8->W8_FRETEIN
   Work_Tot->W9_OUTDESP+=SW8->W8_OUTDESP
   // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
   IF lSegInc
      Work_Tot->W9_SEGURO+=SW8->W8_SEGURO
   ENDIF    
   IF lLerFOBPuro//so p/ NF impostos
      Work_Tot->W8_PRECO_F+=SW8->W8_PRECO_F
   ENDIF
   Work_Tot->W6_FOB_TOT+=DI600RetVal("ITEM_INV", "TAB", .T.) // EOB - 03/06/08 - chamada da função DI600RetVal
   SW8->(DBSKIP())
ENDDO

IF cRatProc $ cSim .AND. lExistEZZ   // EOS - tratamento de invoices sem itens
   ProcRegua(EZZ->(LASTREC()))
   cFilEZZ := xFilial("EZZ")
   EZZ->(DBSETORDER(1))
   EZZ->(DBSEEK(cFilEZZ+SW6->W6_HAWB))
   DO While !EZZ->(Eof()) .AND. ;
             EZZ->EZZ_FILIAL == cFilEZZ .AND.;
             EZZ->EZZ_HAWB   == SW6->W6_HAWB

      IncProc("Somando Invoice: "+EZZ->EZZ_INVOIC)

      Work_Tot->(DBSETORDER(2))
      IF !Work_Tot->(DBSEEK('2'+EZZ->EZZ_MOEDA))
         Work_Tot->(DBAPPEND())
         Work_Tot->WKCODIGO  :='2'
         Work_Tot->W9_INVOICE:="Total Moeda:"
         Work_Tot->W9_MOE_FOB:=EZZ->EZZ_MOEDA
      ENDIF
      Work_Tot->W9_INLAND +=EZZ->EZZ_INLAND
      Work_Tot->W9_PACKING+=EZZ->EZZ_PACKIN
      Work_Tot->W9_DESCONT+=EZZ->EZZ_DESCON
      Work_Tot->W9_FRETEIN+=EZZ->EZZ_FRETEI
      Work_Tot->W9_OUTDESP+=EZZ->EZZ_OUTDES
      // EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP)
      IF lSegInc
         Work_Tot->W9_SEGURO+=EZZ->EZZ_SEGURO
      ENDIF 
      Work_Tot->W6_FOB_TOT+=DI600RetVal("INV_ESP", "TAB", .T.)  // EOB - 03/06/08 - chamada da função DI600RetVal
      EZZ->(DBSKIP())
   ENDDO
ENDIF                

Work_TOT->(DBGOTOP())

RETURN .T.
*-----------------------------------------*
Function DI156DespTela(lFlag)
*-----------------------------------------*
LOCAL oDlg,TB_Campos:={},oMarkTela,lTem:=.F.
LOCAL aBotao:={{"DESTINOS",{|| DI156Mark(.T.),oMarkTela:oBrowse:Refresh()},STR0306,"Todos"}} //"Marca Todos"
PRIVATE cFiltro:=" "

aAdd(TB_Campos,{"WKFLAG",,""})
IF lFlag
   IF !lTemDespesas
      IF cTipoNF = NFE_IMPOSTOS
         RETURN 1
      ENDIF
      MSGINFO(STR0069) //"No hay gastos p/generacion de Factura"
      RETURN 0
   ENDIF
   Work4->(DBSETORDER(1))
   cFiltro:="S"
   aAdd(TB_Campos,{"WKDOC" ,,AVSX3("WD_DOCTO",5)}) 
   IF SWD->(FieldPos("WD_SE_DOC")) > 0
      AADD(TB_Campos,{"WKSEDOC",,AVSX3("WD_SE_DOC",5)})
   ENDIF
   aAdd(TB_Campos,{"WKFORN",,AVSX3("W2_FORN",5)}) 
   aAdd(TB_Campos,{"WKLOJA",,AVSX3("A2_LOJA",5)}) 
ENDIF
aAdd(TB_Campos,{"WKDESPESA",,STR0071}) //"Despesas"
aAdd(TB_Campos,{"WKVALOR"  ,,STR0281+" ("+EasyGParam("MV_SIMB1",,"R$")+")",PICT15_2}) //"Valor"
IF !lFlag            
   aBotao:=NIL
   Work4->(DBSETORDER(2))
   aAdd(TB_Campos,{"WKDOC" ,,AVSX3("WD_DOCTO",5)}) 
   IF SWD->(FieldPos("WD_SE_DOC")) > 0
      AADD(TB_Campos,{"WKSEDOC",,AVSX3("WD_SE_DOC",5)})
   ENDIF 
   aAdd(TB_Campos,{"WKFORN",,AVSX3("W2_FORN",5)}) 
   aAdd(TB_Campos,{"WKLOJA",,AVSX3("A2_LOJA",5)}) 
ENDIF
aAdd(TB_Campos,{{|| DI156SimNao(Work4->WKBASECUS,1)},,AVSX3("YB_BASECUS",5)})
aAdd(TB_Campos,{{|| DI156SimNao(Work4->WKBASEIMP,2)},,AVSX3("YB_BASEIMP",5)})
aAdd(TB_Campos,{"WKTES"    ,,AVSX3("YB_TES"    ,5)}) 
aAdd(TB_Campos,{"WKIMPINS" ,,AVSX3("YB_IMPINS" ,5)}) 
aAdd(TB_Campos,{"WKNOTA"   ,,AVSX3("WD_NF_COMP",5)}) 
aAdd(TB_Campos,{"WKSERIE"  ,,AVSX3("WD_SE_NFC" ,5)})
DO WHILE .T.
   nVolta:=0  
   
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE STR0307; //"Visualiza Gastos"
          FROM 000,oMainWnd:nLeft TO 300,oMainWnd:nRight-50 OF oMainWnd PIXEL

    Work4->(dBGoTop())                         

    DBSELECTAREA("Work4")
    oMarkTela:=MsSelect():NEW("Work4","WKFLAG",,TB_Campos,@lInverte,@cMarca,{015,005,(oDlg:nClientHeight-4)/2,(oDlg:nClientWidth-4)/2},"DI156Filtra(cFiltro)","DI156Filtra(cFiltro)")
    oMarkTela:oBrowse:bWhen:={|| DBSELECTAREA("Work4"),.T. }
  
    IF lFlag
       oMarkTela:bAval:={|| DI156Mark(.F.),oMarkTela:oBrowse:Refresh()}
    ELSE
       oMarkTela:bAval:={||.T.}
    ENDIF
    oMarkTela:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT

   ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nVolta:=1,oDlg:End() },;
                                                 {||nVolta:=0,oDlg:End()},,;
                                                 aBotao) CENTERED
   IF nVolta = 1 .AND. lFlag
      Work4->(DBGOTOP())       
      // EOS
      IF lGrvDespSD1 .AND. ( cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS )
         SYB->(dbSetOrder(1))
         SB1->(dbSetOrder(1))
         DO WHILE Work4->(!EOF())
            IF !EMPTY(Work4->WKFLAG)
               IF EMPTY(Work4->WKFORN)
                  nVolta:=0
                  MSGINFO(STR0352+Work4->WKDESPESA) // "Fornecedor nao informado para despesa: " 
                  EXIT
               ENDIF
               IF SYB->(dbSeek(xFilial()+Work4->WKDESPESA)) 
                  IF EMPTY(SYB->YB_COD_I)
                     nVolta:=0
                     MSGINFO(STR0353+Work4->WKDESPESA) //"Produto nao informado para despesa: " 
                     EXIT
                  ELSEIF !SB1->(dbSeek(xFilial()+SYB->YB_COD_I))
                     nVolta:=0
                     MSGINFO(STR0354+SYB->YB_COD_I) //"Produto nao localizado no cad. de Produtos: " 
                     EXIT
                  ENDIF
               ENDIF
            ENDIF
            Work4->(dbSkip())
         ENDDO 
         Work4->(DBGOTOP())
         IF nVolta == 0
            EXIT
         ENDIF 
      ENDIF
    
      IF cTipoNF = NFE_IMPOSTOS
         DO WHILE Work4->(!EOF())
            IF !EMPTY(Work4->WKFLAG)
               cDocDespesa :=Work4->WKDOC
               cSerieDesp  :=Work4->WKSEDOC 
               cFornDespesa:=Work4->WKFORN
               cLojaDespesa:=Work4->WKLOJA
               EXIT
            ENDIF  
            Work4->(DBSKIP())
         ENDDO
      ELSE
         Work4->(DBEVAL({|| lTem:=.T.}, {|| !EMPTY(Work4->WKFLAG) }, {||!lTem} ))
         IF !lTem
            MSGINFO(STR0340)// "No hay gastos marcados p/generacion de Factura"
            LOOP
         ENDIF         
      ENDIF         
   ENDIF

   EXIT

ENDDO

RETURN nVolta
*-----------------------------------------*
Function DI156Mark(lTodos)
*-----------------------------------------*
LOCAL cMarcaNew:=IF(!EMPTY(Work4->WKFLAG),"  ",cMarca)
LOCAL nRecno:=Work4->(Recno())
LOCAL cChave:=Work4->(WKFILTRO+WKDOC+WKFORN+WKLOJA)
LOCAL bWhi:={|| .T. }
LOCAL bGrv:={||Work4->WKFLAG:=cMarcaNew }

Work4->(DBSETORDER(1))
Work4->(DBGOTOP())

IF cTipoNF = NFE_IMPOSTOS
   bWhi:={|| .T. }
   bGrv:={||IF(cChave == Work4->(WKFILTRO+WKDOC+WKFORN+WKLOJA),;
            Work4->WKFLAG:=cMarcaNew, Work4->WKFLAG:='') }
ELSEIF !lTodos
   bWhi:={|| cChave == Work4->(WKFILTRO+WKDOC+WKFORN+WKLOJA) }
   Work4->(DBSEEK(cChave))
ENDIF
Work4->(DBEVAL(bGrv,,bWhi))

Work4->(DBGOTO(nRecno))
RETURN .T.
*-----------------------------------------*
Function DI156SimNao(cCampo,nBranco)
*-----------------------------------------*
IF AT(SWD->(LEFT(Work4->WKDESPESA,1)),"129") =0
   DO CASE 
      CASE cCampo  $ cSim ; RETURN STR0261//"1-Sim"
      CASE cCampo  $ cNao ; RETURN STR0262//"2-Não"
      CASE nBranco = 1    ; RETURN STR0261//"1-Sim"
      CASE nBranco = 2    ; RETURN STR0262//"2-Não"
   ENDCASE
ENDIF
RETURN "   "

*-----------------------------------*
Function DI156Itens()
*-----------------------------------*
LOCAL oDlg,oMark
LOCAL cBotao:=IF(cTipoNF # CUSTO_REAL,STR0282,STR0283) //"&Gera NFE"###"&Grava"
LOCAL nCol:=IF(!lNFAutomatica.AND.cTipoNF#CUSTO_REAL,31,17)
IF SetMDIChild()
   nCol:=01
ENDIF

PRIVATE nOpca := 0 // POR CAUSA DO BOTAO DO RDMAKE
DO WHILE .T.

   DBSELECTAREA("Work1")
   Work1->(dbsetorder(2))//JVR - alterado a ordem de 1 para 2.
   Work1->(DBGOTOP())
   nOpca:=0
   
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE STR0097 ; //"Itens da NF's"
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL           
   
   oMark:= MsSelect():New("Work1","WKFLAG",,TB_Campos2,@lInverte,@cMarca,{nCol,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
   oMark:oBrowse:bWhen:={|| DBSELECTAREA("Work1"),.T. }
   IF lNFAutomatica .OR. cTipoNF == CUSTO_REAL
      oMark:bAval:={|| DI156It_Alt(),DBSELECTAREA("Work1"),oMark:oBrowse:Refresh()}
   ELSEIF cTipoNF == NFE_DESPESAS
      oMark:bAval:={|| DI156Marcados(.F.,.T.),oMark:oBrowse:Refresh()}
   ENDIF
   oMark:oBrowse:Align:=CONTROL_ALIGN_BOTTOM

   IF (EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"BOTAO"),)

   @ 04,40 BUTTON STR0259   SIZE 37,11 ACTION EICDI157("TXT");// GERAR ARQUIVO
                                       OF oDlg PIXEL

   @ 04,85 BUTTON STR0308   SIZE 45,12 ACTION (DI156It_Alt(),DBSELECTAREA("Work1"),oMark:oBrowse:Refresh()); //"Impuestos / Item"
                                                WHEN !lGerouNFE OF oDlg PIXEL

   @ 04,135 BUTTON STR0272  SIZE 35,11 ACTION (nOpca:=1,oDlg:End());
                                       OF oDlg PIXEL WHEN (cTipoNF#CUSTO_REAL.OR.lGerouNFE)//"&Impressão"

   @ 04,175 BUTTON STR0101  SIZE 30,11 ACTION (DI156Pesquisa(),oMark:oBrowse:Refresh());
                                       OF oDlg PIXEL //"&Pesquisa"

   @ 04,210 BUTTON STR0100  SIZE 30,11 ACTION (DI156MostraTotais());
                                       OF oDlg PIXEL //"&Totais"
   
   @ 04,245 BUTTON cBotao   SIZE 30,11 ACTION (nOpca:=2,oDlg:End());
                                       OF oDlg PIXEL WHEN (lGeraNF.AND.!lGerouNFE)

   @ 04,280 BUTTON STR0103  SIZE 30,11 ACTION (nOpca:=0,oDlg:End());
                                       OF oDlg PIXEL //"&Sair"

   IF !lNFAutomatica .AND. cTipoNF # CUSTO_REAL
      @ 17,200 BUTTON STR0098 SIZE 50,11 ACTION (DI156Marcados(.T.,.F.),oMark:oBrowse:Refresh()) OF oDlg PIXEL WHEN !lGerouNFE//"A&ltera Marcados"

      @ 17,255 BUTTON STR0099 SIZE 55,11 ACTION (DI156Marcados(.F.,.F.),oMark:oBrowse:Refresh()) OF oDlg PIXEL WHEN !lGerouNFE//"&Marca/Desm. Todos"
   ENDIF
   oDlg:lMaximized:=.T.

   ACTIVATE MSDIALOG oDlg

   IF nOpca=1
      EICDI157(cTipoNF)
      LOOP
   ENDIF
   
   IF nOpca=2 //Clicou no botao 'Genera'
      Processa({|| DI156GerNF(@lGerouNFE)},STR0104) //"Gera‡Æo de NF's"
      If !lGerouNFE ; LOOP ; ENDIF
   ENDIF

   IF nOpca=0
      EXIT
   ENDIF

ENDDO

Work2->(DBGOTOP())

RETURN .T.

*---------------------------------------*
Function DI156Marcados(lAlt,lItem)
*---------------------------------------*
LOCAL oDlg, nOpca, nRecno:=Work1->(RECNO())
LOCAL cTit  :=IF(lAlt,OemToAnsi(STR0105),STR0106) //"Altera‡Æo dos Itens Marcados"###"Marca / Desmarca Itens"
LOCAL bValid:=IF(lAlt,{||DI156Valid("NFE")      .AND.;
                         DI156Valid("SERIE",.F.).AND.;
                         DI156Valid("DATA")},{||.T.})
LOCAL nCo1:=0.8, nCo2:=6.3,cSelecao
LOCAL nMarca:=1, cNCM :=Work1->WKTEC,cMarcaNew
LOCAL cChave:=Work1->WKDESPESA+Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+Work1->WKLOJA
LOCAL cForn :=Work1->WKFORN+Work1->WKLOJA
Local aOrdWK1 := SaveOrd({"Work1"})//JVR - 08/06/10


IF lAlt
   nOpca:=.T.
   Work1->( DBGOTOP() )
   Work1->( DBEVAL({|| nOpca:=!Work1->WKFLAG==cMarca },,{||nOpca}) )
   Work1->( DBGOTO(nRecno) )
   IF nOpca
      MSGinfo(STR0107,STR0108) //"Não existe registros marcados"###"Informação"
      RETURN .F.
   Endif
Endif

cNumNFE  :=Work1->WK_NFE
cSerieNFE:=Work1->WK_SE_NFE
dDtNFE   :=IF(!EMPTY(Work1->WK_DT_NFE),Work1->WK_DT_NFE,dDataBase)
nOpca    :=0
                           
//JVR - 27/05/10 - Tratamento para preenchimento da Serie da NF.
If cTipoNF # NFE_IMPOSTOS .and. Empty(cSerieNFE)
   cSerieNFE := EasyGParam("MV_SER_ARG",,"A")
EndIf

IF cTipoNF = NFE_DESPESAS
   cSelecao:=STR0084
ELSE
   cSelecao:=STR0310
ENDIF

IF !lItem

   DEFINE MSDIALOG oDlg TITLE cTit FROM 9,10 TO 18,48 Of oMainWnd

     IF lAlt

        @1.3,nCo1 SAY OemToAnsi(STR0094) SIZE 25,8//"N§ da N.F."
        IF !lTrava
           SETKEY(VK_F4,{|| DI156HelpSWD() } )
           @1.3,13   SAY STR0309 SIZE 25,8 //"Help (F4)"
        ENDIF
        @2.2,nCo1 SAY OemToAnsi(STR0095) //"S‚rie"
        @3.2,nCo1 SAY STR0096 //"Data da N.F."

        @1.3,nCo2 MSGET cNumNFE   PICTURE "@!" SIZE 50,8 WHEN !lTrava
        @2.2,nCo2 MSGET cSerieNFE PICTURE "@!" SIZE 15,8 WHEN !lTrava
        @3.2,nCo2 MSGET dDtNFE    PICTURE "@D" SIZE 45,8

     ELSE

        @08,05 TO 45,70 OF oDlg PIXEL

        @18,10 RADIO nMarca ITEMS cSelecao,STR0110 3D SIZE 49,12 PIXEL //"&Por Arancel"###"&Todos os Itens" 

     ENDIF

     @26,105 BUTTON STR0111 SIZE 25,11 ACTION (If(EVAL(bValid),(nOpca:=1,oDlg:End()),)) OF oDlg PIXEL //"&OK"

     @40,105 BUTTON STR0103 SIZE 25,11 ACTION (nOpca:=0,oDlg:End())                     OF oDlg PIXEL //"&Sair"


   ACTIVATE MSDIALOG oDlg CENTERED

   If nOpca = 0
      RETURN .F.
   Endif
ENDIF

cMarcaNew:=IF(Work1->WKFLAG==cMarca,"  ",cMarca)

bFor:={||.T.}

Work1->(DBSETORDER(1))
Work1->(DBGOTOP())

bFor:={||.T.}

IF !lAlt .AND. nMarca == 1
   IF cTipoNF = NFE_DESPESAS
      bFor:={|| cForn == Work1->WKFORN+Work1->WKLOJA }
   ELSE
      bFor:={|| cNCM  == Work1->WKTEC }
   ENDIF
ENDIF

IF lItem 
   bFor:={|| cChave==Work1->WKDESPESA+Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+Work1->WKLOJA }
ENDIF

Processa({|| DI156GrvAltNf(lAlt,bFor,cMarcaNew)},STR0112) //"Alterando Itens..."

//Work1->(DBGOTO(nRecno))
RestOrd(aOrdWK1, .t.)
                                   

RETURN .T.

*----------------------------------------------------------------------------*
STATIC Function DI156GrvAltNf(lAlt,bFor,cMarcaNew)
*----------------------------------------------------------------------------*

ProcRegua(Work1->(LASTREC()))
Work1->(DBGOTOP())
Work3->(DBSETORDER(1))

DO WHILE !Work1->(EOF())

   IncProc(STR0113+' '+Work1->WKCOD_I) //"Processando Item: "

   IF Work1->WKFLAG == cMarca .AND. lAlt

      Work1->WK_NFE   := cNumNFE
      Work1->WK_SE_NFE:= SerieNfId(,4,"WN_SERIE",dDtNFE,cMv_ESPEIC,cSerieNFE) //cSerieNFE
      Work1->WK_DT_NFE:= dDtNFE

      IF Work1->WKRECNOWK3 # 0
         Work3->(DBGOTO(Work1->WKRECNOWK3))
         Work3->WK_NF_COMP:=cNumNFE
         Work3->WK_SE_NFC :=cSerieNFE
         Work3->WK_DT_NFC :=dDtNFE
      ENDIF

   ELSEIF !lAlt .AND. EVAL(bFOR)

      Work1->WKFLAG := cMarcaNew

   ENDIF

   Work1->(DBSKIP())

ENDDO

RETURN .T.

*---------------------------------------*
Static Function DI156MostraTotais()
*---------------------------------------*
LOCAL nCo1:=0.5, nCo2:=5, nCo3:=12.5, nCo4:=18.0,nLin:=0.5
LOCAL nTotNFE:= nVlTota:= 0, oDlgImp
LOCAL TB_CamposTes:={},oMarkTot
PRIVATE nOutDesp:=nFobR:=nFrete:=nSeguro:=nDolar:=nDIFOB:=0,lSair:=.F.
PRIVATE cFiltro:="TOTAIS"+SPACE(LEN(WorkTES->WK_NCM))

IF EasyEntryPoint('EICDI156')
   Execblock('EICDI156',.F.,.F.,'TELA_TOTAIS')
   IF lSair
      RETURN .T.
   ENDIF
ENDIF

aAdd(TB_CamposTes,{"WK_IMP"    ,,STR0311}) //"Impuesto"
aAdd(TB_CamposTes,{"WK_IMPDESC",,STR0312}) //"Descripción"
aAdd(TB_CamposTes,{"WKBASE"    ,,STR0313+' $',PICT15_2}) //"Base "
aAdd(TB_CamposTes,{"WKBASEUS"  ,,STR0313+' ('+cMoeDolar+')' ,PICT15_2}) //"Base "
aAdd(TB_CamposTes,{"WKVALOR"   ,,STR0315+' $',PICT15_2}) //"Valor "
aAdd(TB_CamposTes,{"WKVALORUS" ,,STR0315+' ('+cMoeDolar+')',PICT15_2}) //"Valor "

Processa({|| DI156Soma()},OemToAnsi(STR0114)) //"Calculando Totais"

nVlTota:=DITRANS((nDIFOB+nTotImpostos))

oMainWnd:ReadClientCoords()
DEFINE MSDIALOG oDlgImp TITLE STR0115 ;
       FROM 000,oMainWnd:nLeft TO 380,oMainWnd:nRight-200 PIXEL //"TOTAIS"

   @ nLin   ,nCo1 SAY STR0042+" ("+EasyGParam("MV_SIMB1",,"R$")+")" //"FOB"
   @ nLin+=1,nCo1 SAY STR0043+" ("+EasyGParam("MV_SIMB1",,"R$")+")" //"Frete"
   @ nLin+=1,nCo1 SAY STR0044+" ("+EasyGParam("MV_SIMB1",,"R$")+")" //"Seguro"
   @ nLin+=1,nCo1 SAY STR0315+' ('+cMoeDolar+')' //"Valor "
   nLin:=0.5
   @ nLin   ,nCo2 GET nFobR   WHEN .F. PICTURE PICT15_2 SIZE 55,8
   @ nLin+=1,nCo2 GET nFrete  WHEN .F. PICTURE PICT15_2 SIZE 55,8
   @ nLin+=1,nCo2 GET nSeguro WHEN .F. PICTURE PICT15_2 SIZE 55,8
   @ nLin+=1,nCo2 GET nDolar  WHEN .F. PICTURE PICT15_2 SIZE 55,8
   nLin:=0.5
   @ nLin   ,nCo3 SAY STR0058+" ("+EasyGParam("MV_SIMB1",,"R$")+")" //"Vl. Mercadoria"
   @ nLin+=1,nCo3 SAY STR0303 //"Impuestos"
   @ nLin+=1,nCo3 SAY STR0082 //"Total Geral"
   IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      @ nLin+=1,nCo3 SAY STR0053+" ("+EasyGParam("MV_SIMB1",,"R$")+")" //"Outras Despesas"
   ENDIF
   nLin:=0.5
   @ nLin   ,nCo4 GET nDIFOB       WHEN .F. PICTURE PICT15_2 SIZE 55,8 
   @ nLin+=1,nCo4 GET nTotImpostos WHEN .F. PICTURE PICT15_2 SIZE 55,8 
   @ nLin+=1,nCo4 GET nVlTota      WHEN .F. PICTURE PICT15_2 SIZE 55,8 
   IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      @ nLin+=1,nCo4 GET nOutDesp  WHEN .F. PICTURE PICT15_2 SIZE 55,8 
   ENDIF
   nLin+=65

   IF cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      DBSELECTAREA("WorkTES")
      oMarkTot:=MsSelect():New("WorkTES",,,TB_CamposTes,.F.,cMarca,{nLin,005,nLin+100,(oDlgImp:nClientWidth-4)/2},"DI156Filtra(cFiltro)","DI156Filtra(cFiltro)")
      oMarkTot:oBrowse:bWhen:={|| DBSELECTAREA("WorkTES"),.T. }
   ELSE
      oDlgImp:nHeight:=160
      oDlgImp:nWidth :=oDlgImp:nWidth - 60
   ENDIF

ACTIVATE DIALOG oDlgImp ON INIT EnchoiceBar(oDlgImp, { || oDlgImp:End() }, { || oDlgImp:End() },,,,,,,.F.)  CENTERED

RETURN NIL

*----------------------*
Function DI156Soma()
*----------------------*
LOCAL nRecno:=Work1->(RECNO())

ProcRegua( Work1->(LASTREC()) )
Work1->(DBGOTOP())

DO WHILE !Work1->(EOF())
   IncProc()
   nFobR   +=Work1->WKFOB_R
   nFrete  +=Work1->WKFRETE
   nSeguro +=Work1->WKSEGURO
   nDolar  +=Work1->WKVALMERUS
   nDIFOB  +=Work1->WKVALMERC
   nOutDesp+=Work1->WKOUT_DESP
   Work1->(DBSKIP())
ENDDO

Work1->(DBGOTO(nRecno))

RETURN .T.

*----------------------*
Function DI156It_Alt()
*----------------------*
LOCAL nCo1:=0.8, nCo2:=6.3, nCo3:=18, nCo4:=23, nLin:=1.4, nAltuPnl
LOCAL oDlgImp,cTit1
LOCAL TB_Campos:={},oMark1,aBotoes:={},nOrdem:=Work1->(INDEXORD())
LOCAL oDlg, nTela:=0, nRecno:=Work1->(RECNO())
LOCAL cTit     :=OemToAnsi(STR0123) //"Altera‡Æo do Item Atual"

LOCAL nFOBRS  :=Work1->WKFOB_R
LOCAL nSeguro :=Work1->WKSEGURO
LOCAL nFrete  :=Work1->WKFRETE
LOCAL nVLDolar:=Work1->WKVALMERUS
LOCAL nVLMERC :=Work1->WKVALMERC

LOCAL nCFOBRS  :=Work1->WKFOB_R
LOCAL nCSeguro :=Work1->WKSEGURO
LOCAL nCFrete  :=Work1->WKFRETE
LOCAL nCVLMERC :=Work1->WKVALMERC

LOCAL bValid:=IF(cTipoNF # CUSTO_REAL .AND. !lNFAutomatica,;
              {|| DI156Valid("NFE")       .AND. ;
                  DI156Valid("SERIE",.F.) .AND. ;
                  DI156Valid("DATA")},{||.T.})

PRIVATE cFiltro:=STRZERO(Work1->(RECNO()),6)

aAdd(TB_Campos,{"WK_IMP" ,,STR0311}) //"Impuesto"
aAdd(TB_Campos,{"WK_IMPDESC",,STR0312}) //"Descripción"
aAdd(TB_Campos,{"WKORIGEM"  ,,"Origen"})
aAdd(TB_Campos,{"WKPERC" ,,STR0316,"@E 999.99"}) //"% Alicuota"
aAdd(TB_Campos,{"WKBASE" ,,STR0313+' $',PICT15_2}) //"Base "
aAdd(TB_Campos,{"WKBASEUS",,STR0313+cMoeDolar,PICT15_2}) //"Base $"
aAdd(TB_Campos,{"WKVALOR",,STR0315+' $',PICT15_2}) //"Valor"
aAdd(TB_Campos,{"WKVALORUS",,STR0315+cMoeDolar,PICT15_2}) //"Valor"

cCod     :=Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM
cNumNFE  :=Work1->WK_NFE
cSerieNFE:=Work1->WK_SE_NFE
dDtNFE   :=IF(EMPTY(Work1->WK_DT_NFE),dDataBase,Work1->WK_DT_NFE)

oMainWnd:ReadClientCoords()

DO WHILE .T.

   aBotoes:={}
   If nTela = 1
      WorkTES->(DBSETORDER(2))
      cFiltro:=STRZERO(Work1->(RECNO()),6)+"P"
      AADD(aBotoes, {"VERNOTA"   ,{|| (nTela:=2,oDlgImp:End()) },"Impuestos del Gastos","Imp.Gast"} )
      AADD(aBotoes, {"RESPONSA"  ,{|| (nTela:=3,oDlgImp:End()) },"Todo los Impuestos"  ,"Todos"     } )
      cTit1:=" - Impuestos ADUANA"
   ELSEIf nTela = 2
      WorkTES->(DBSETORDER(2))
      cFiltro:=STRZERO(Work1->(RECNO()),6)+"D"
      AADD(aBotoes, {"NOVACELULA",{|| (nTela:=1,oDlgImp:End()) },"Impuestos del Items","Imp.Items"} )
      AADD(aBotoes, {"RESPONSA"  ,{|| (nTela:=3,oDlgImp:End()) },"Todo los Impuestos" ,"Todos"    } )
      cTit1:=" - Impuestos de los gastos"
   ELSE
      WorkTES->(DBSETORDER(1))
      cFiltro:=STRZERO(Work1->(RECNO()),6)
      AADD(aBotoes, {"NOVACELULA",{|| (nTela:=1,oDlgImp:End()) },"Impuestos del Items" ,"Imp.Items" } )
      AADD(aBotoes, {"VERNOTA"   ,{|| (nTela:=2,oDlgImp:End()) },"Impuestos del Gastos","Imp.Gast"} )
      cTit1:=" - Todos los Impuestos"
   ENDIF

   IF cTipoNF = NFE_DESPESAS   
      aBotoes:=NIL
   ENDIF
   nTela := 0

   If cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      nAltuPnl := 80
      nAltDlg := 400
   Else   
      nAltDlg := 300
      nAltuPnl := 200
   EndIf

   DEFINE MSDIALOG oDlgImp TITLE cTit+cTit1;
          FROM 000,oMainWnd:nLeft+10 TO nAltDlg, oMainWnd:nRight-100 OF oMainWnd PIXEL

   //TPanel():New( [ nRow ], [ nCol ], [ cText ], [ oWnd ], [ oFont ], [ lCentered ], [ uParam7 ], [ nClrText ], [ nClrBack ], [ nWidth ], [ nHeight ], [ lLowered ], [ lRaised ] )

   oPnl1:= TPanel():New(0, 0, "", oDlgImp, , .F., .F.,,, 116, nAltuPnl)
   oPnl1:Align:= CONTROL_ALIGN_TOP

   nLin:=1.4
   @nLin   ,nCo1 SAY OemToAnsi(STR0094) OF oPnl1 //"N§ da N.F."
   @nLin+=1,nCo1 SAY OemToAnsi(STR0095) OF oPnl1 //"S‚rie"
   @nLin+=1,nCo1 SAY STR0096 OF oPnl1 //"Data da N.F."
   @nLin+=1,nCo1 SAY STR0058+" ("+EasyGParam("MV_SIMB1",,"R$")+")" OF oPnl1 //"Vl. Mercadoria"

   nLin:=1.4
   @nLin   ,nCo2 MSGET cNumNFE   PICTURE "@!" VALID DI156Valid("NFE")       SIZE 57,8 OF oPnl1 WHEN cTipoNF # NFE_DESPESAS .AND. !lNFAutomatica .AND. cTipoNF # CUSTO_REAL .AND. !lTrava
   @nLin+=1,nCo2 MSGET cSerieNFE PICTURE "@!" VALID DI156Valid("SERIE",.F.) SIZE 15,8 OF oPnl1 WHEN cTipoNF # NFE_DESPESAS .AND. !lNFAutomatica .AND. cTipoNF # CUSTO_REAL .AND. !lTrava
   @nLin+=1,nCo2 MSGET dDtNFE    VALID DI156Valid("DATA")                   SIZE 40,8 OF oPnl1 WHEN cTipoNF # NFE_DESPESAS
   @nLin+=1,nCo2 MSGET nVLMERC   VALID nVLMERC>=0 PICTURE PICT15_2          SIZE 57,8 OF oPnl1

   nLin:=1.4
   IF !lTrava
      SETKEY(VK_F4,{|| DI156HelpSWD() } )
      @nLin   ,14   SAY STR0309 OF oPnl1 //"Help (F4)"
   ENDIF
   @nLin   ,nCo3 SAY STR0124 OF oPnl1 //"Valor FOB"
   @nLin+=1,nCo3 SAY STR0125 OF oPnl1 //"Valor Seguro"
   @nLin+=1,nCo3 SAY STR0126 OF oPnl1 //"Valor Frete"
   @nLin+=1,nCo3 SAY STR0315+' ('+cMoeDolar+')' OF oPnl1 //"Valor "

   nLin:=1.4
   @nLin   ,nCo4 MSGET nFOBRS    VALID nFOBRS  >=0 PICTURE PICT15_2    SIZE 55,8 OF oPnl1 WHEN cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
   @nLin+=1,nCo4 MSGET nSeguro   VALID nSeguro >=0 PICTURE PICT15_2    SIZE 55,8 OF oPnl1 WHEN cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
   @nLin+=1,nCo4 MSGET nFrete    VALID nFrete  >=0 PICTURE PICT15_2    SIZE 55,8 OF oPnl1 WHEN cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
   @nLin+=1,nCo4 MSGET nVLDolar  VALID nVLDolar>=0 PICTURE PICT15_2    SIZE 55,8 OF oPnl1
   nLin+=071

   IF cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      DBSELECTAREA("WorkTES")
      oMark1:=MsSelect():New("WorkTES",,,TB_Campos,.F.,cMarca,{1,1,1,1},"DI156Filtra(cFiltro)","DI156Filtra(cFiltro)")
      oMark1:oBrowse:bWhen:={|| DBSELECTAREA("WorkTES"),.T. }
      oMark1:bAval:={|| DI156ImpAltera(),oMark1:oBrowse:Refresh()}
      oMark1:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
   ELSE
      aBotoes:=NIL
      oDlgImp:nWidth :=oDlgImp:nWidth - 100
   ENDIF

   ACTIVATE DIALOG oDlgImp ON INIT EnchoiceBar(oDlgImp,;
            {||If(EVAL(bValid),(nTela:=4,oDlgImp:End()),)},;
            {||nTela:=0, oDlgImp:End()},,aBotoes) CENTERED

   If nTela = 0
      WorkTES->(DBSETORDER(1))
      Return .F.
   ELSEIf nTela = 1 .OR. nTela = 2 .OR. nTela = 3
      LOOP
   ENDIF
   EXIT
ENDDO

WorkTES->(DBSETORDER(1))
Work1->(DBSETORDER(1))
Work1->(DBGOTO(nRecno))
Work2->(DBSEEK(Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))

IF cTipoNF = NFE_FOB
   nFOBRS := nVLMERC
ENDIF
Work1->WK_DT_NFE := dDtNFE
Work1->WKVALMERUS:= nVLDolar
Work1->WKFOB_R   := nFOBRS
Work1->WKFRETE   := nFrete
Work1->WKVALMERC := nVLMERC
Work1->WKSEGURO  := nSeguro
Work1->WKCIF     := nVLMERC

Work1->(DBGOTO(nRecno))
Work1->WK_NFE    := cNumNFE
Work1->WK_SE_NFE := SerieNfId(,4,"WN_SERIE",dDtNFE,cMv_ESPEIC,cSerieNFE) //cSerieNFE
IF Work1->WKRECNOWK3 # 0
   Work3->(DBGOTO(Work1->WKRECNOWK3))
   Work3->WK_NF_COMP:=cNumNFE
   Work3->WK_SE_NFC :=cSerieNFE
   Work3->WK_DT_NFC :=dDtNFE
ENDIF

// Subtrai os valores anteriores da tela principal
n_CIF    := DITRANS((n_CIF    - nCVLMERC))
nFOB_R   := DITRANS((nFOB_R   - nCFOBRS))
n_FRETE  := DITRANS((n_FRETE  - nCFrete))
n_SEGURO := DITRANS((n_SEGURO - nCSeguro))

// Soma os novos valores na tela principal
n_CIF    := DITRANS((n_CIF    + nVLMERC))
nFOB_R   := DITRANS((nFOB_R   + nFOBRS))
MDI_FOB  := nFOB_R   / IF(EMPTY(n_Tx_Fob),1,n_Tx_Fob)
n_FRETE  := DITRANS((n_FRETE  + nFrete))
//n_Vl_Fre := DITRANS((n_FRETE  / IF(EMPTY(n_Tx_Fre),1,n_Tx_Fre)))
//Bete 15/03/06 - Por se tratar de moeda estrangeira(US$), nao devemos arredondar
n_Vl_Fre := n_FRETE  / IF(EMPTY(n_Tx_Fre),1,n_Tx_Fre)
n_SEGURO := DITRANS((n_SEGURO + nSeguro))
//n_Vl_USS := DITRANS((n_SEGURO / IF(EMPTY(n_Tx_Seg),1,n_Tx_Seg)))
//Bete 15/03/06 - Por se tratar de moeda estrangeira(US$), nao devemos arredondar
n_Vl_USS := n_SEGURO / IF(EMPTY(n_Tx_Seg),1,n_Tx_Seg)
n_VlTota := DITRANS((n_CIF +MDI_OUTR))
cPictDI  := IF(RIGHT(STR(MDI_FOB,15,4),2)="00",;
              PICT15_2,"@E 999,999,999,999.9999")
Work1->(DBSETORDER(nOrdem))
RETURN .T.
*---------------------------------------*
STATIC Function DI156ImpAltera()
*---------------------------------------*
LOCAL oDlg, nOpcA:=0,nLin:=1.3, nRecno:=WorkTES->(RECNO())
LOCAL cImp  :=WorkTES->WK_IMP
LOCAL cNCM  :=WorkTES->WK_NCM
LOCAL nPERC :=WorkTES->WKPERC
LOCAL nBASE :=nOldBASE :=WorkTES->WKBASE
LOCAL nVALOR:=nOldVALOR:=WorkTES->WKVALOR
LOCAL bEqual:={||nPERC ==WorkTES->WKPERC .AND.;
                 nBASE ==WorkTES->WKBASE .AND.;
                 nVALOR==WorkTES->WKVALOR}

oMainWnd:ReadClientCoords()
DEFINE MSDIALOG oDlg TITLE STR0317+WorkTES->WK_IMP; //"Modificacion de Impuesto: "
       FROM 000,oMainWnd:nLeft+10 TO 135,oMainWnd:nRight-550  Of oMainWnd PIXEL

@nLin,1.8 SAY STR0316 //"% Alicuota"
@nLin,6.3 MSGET nPERC  PICTURE "@E 999.99" SIZE 60,8

@nLin+=1,1.8 SAY STR0313 //"Base $"
@nLin   ,6.3 MSGET nBASE  PICTURE PICT15_2    SIZE 60,8

@nLin+=1,1.8 SAY STR0315+' $' //"Valor "
@nLin   ,6.3 MSGET nVALOR PICTURE PICT15_2    SIZE 60,8

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,;
{|| If(Eval(bEqual),nOpcA:=0,(nOpcA:=1,oDlg:End()))},;
{|| nOpcA:=0, oDlg:End()}) CENTERED

If nOpcA = 0
   Return .F.
Endif
WorkTES->(DBSEEK("TOTAIS"+SPACE(LEN(cNCM))+cImp))
WorkTES->WKBASE   :=DITRANS((WorkTES->WKBASE -nOldBASE )+nBASE ) 
WorkTES->WKBASEUS :=WorkTES->WKBASE/SW6->W6_TX_US_D 
WorkTES->WKVALOR  :=DITRANS((WorkTES->WKVALOR-nOldVALOR)+nVALOR)
WorkTES->WKVALORUS:=WorkTES->WKVALOR/SW6->W6_TX_US_D

WorkTES->(DBSEEK("TOTAIS"+cNCM+cImp))
WorkTES->WKBASE   :=DITRANS((WorkTES->WKBASE -nOldBASE )+nBASE )
WorkTES->WKBASEUS :=WorkTES->WKBASE/SW6->W6_TX_US_D
WorkTES->WKVALOR  :=DITRANS((WorkTES->WKVALOR-nOldVALOR)+nVALOR)
WorkTES->WKVALORUS:=WorkTES->WKVALOR/SW6->W6_TX_US_D

WorkTES->(DBGOTO(nRecno))
WorkTES->WKPERC   :=nPERC
WorkTES->WKBASE   :=nBASE
WorkTES->WKBASEUS :=WorkTES->WKBASE/SW6->W6_TX_US_D
WorkTES->WKVALOR  :=nVALOR
WorkTES->WKVALORUS:=WorkTES->WKVALOR/SW6->W6_TX_US_D

Work1->WKIMPOSTOS:=DITRANS((Work1->WKIMPOSTOS-nOldVALOR)+nVALOR)
nTotImpostos     :=DITRANS((nTotImpostos     -nOldVALOR)+nVALOR)


Return .T.

*----------------------------------------------*
Function DI156GrWorks()
*----------------------------------------------*
LOCAL nCont:=0,nValor:=0, lSair:=.F.,nMaiorWK1:=nValTotMerUS:=0,nRecnoWK1:=0
Local lExistEZZ  := SX2->(dbSeek("EZZ"))

aDespesa:={};nFob:=nPesoL:=nTx_Seguro:=nContProc:=nSomaNoCIF:=0;cTipoTx:=""

SD1->(DBSETORDER(8))//9
SYB->(DBSETORDER(1))
SWW->(DBSETORDER(1))
SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
SW2->(dBSeek(xFilial("SW2")+SW7->W7_PO_NUM))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))//FDR - 21/09/12 - Tratamento de Loja
SW4->(DbSeek(xFilial("SW4")+SW7->W7_PGI_NUM))

ProcRegua(2)

DI156IncProc(STR0132) //"Verificando Processo, Aguarde..."
IF !empty(SW6->W6_VL_USSE)
   nTx_Seguro:=SW6->W6_TX_SEG
ENDIF

DI156IncProc(STR0132) //"Verificando Processo, Aguarde..."

SW9->(DBSETORDER(3))
SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))


MDespesas:=MDI_FOB:=MDespMoeda:=0
DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                              SW9->W9_HAWB == SW6->W6_HAWB
   MDespesas += DI600RetVal("TOT_INV,SEM_FOB", "TAB", .T., .T.)  // EOB - 03/06/08 - chamada da função DI600RetVal
   SW9->(DBSKIP())
ENDDO

//EOS - inclusao das invoices especiais
IF cRatProc $ cSim .AND. lExistEZZ
   cFilEZZ:=xFilial("EZZ")
   EZZ->(DBSETORDER(1))
   EZZ->(DbSeek(cFilEZZ+SW6->W6_HAWB)) 
   DO WHILE ! EZZ->(EOF()) .AND. EZZ->EZZ_FILIAL == cFilEZZ .AND.;
                                 EZZ->EZZ_HAWB   == SW6->W6_HAWB
      MDespesas += DI600RetVal("INV_ESP", "TAB", .T., .T.)  // EOB - 03/06/08 - chamada da função DI600RetVal
      EZZ->(DBSKIP())
   ENDDO   
ENDIF

/*IF !EMPTY(SW6->W6_VLMLEMN)
   MDI_FOB:= SW6->W6_VLMLEMN+MDespMoeda
ENDIF*/

MDI_FOB_R := DITrans(SW6->W6_FOB_TOT+MDespesas,2)

IF cTipoNF # NFE_DESPESAS

   IF cTipoNF # NFE_FOB
      MDI_FRETE    := DITrans(ValorFrete(SW6->W6_HAWB,,,1),2)
      MDI_FRET_MOE := ValorFrete(SW6->W6_HAWB,,,2)
      MDI_SEGURO   := DITrans(SW6->W6_VLSEGMN,2)  
                 
      // EOS - 06/10/03
      IF cPaisLoc # "BRA" .AND. SW6->(FIELDPOS("W6_VMINSEG")) # 0 .AND. cTipoNF = '9'
         MDI_SEGURO := DITrans(SW6->W6_VMINSEG,2)
      ENDIF        
      
      IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"LE_BASE_SEGURO"),)
      
   ENDIF
   IF cTipoNF = NFE_SEGURO
      MDI_FRET_MOE := 0
      MDI_FRETE    := 0
   ENDIF
   IF cTipoNF = NFE_FRETE
      MDI_SEGURO:=0
   ENDIF
   MDI_CIF   := DITrans( MDI_FOB_R + MDI_FRETE + MDI_SEGURO + nSomaNoCIF)
ENDIF

IF cTipoNF # CUSTO_REAL

   SF1->(DBSETORDER(5))
   SWN->(DBSETORDER(2))
   ProcRegua(50)

   SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+cTipoNF))

   DO WHILE SF1->(!EOF())                  .AND.;
         SF1->F1_FILIAL  == xFilial("SF1") .AND.;
         SF1->F1_HAWB    == SW6->W6_HAWB   .AND.;
         SF1->F1_TIPO_NF == cTipoNF

      DI156IncProc(STR0133) //"Lendo Nota Fiscal, Aguarde..."

      IF !EMPTY(cNota) .AND. cNota # SF1->F1_CTR_NFC // Nota + Serie + Fornecedor + Loja
         SF1->(DBSKIP())
         LOOP
      ENDIF
      IF SF1->F1_ESPECIE = "RCN" // AWR  - 16/8/2004 - IGNORA A NOTA DE REMITO
         SF1->(DBSKIP())
         LOOP
      ENDIF
      IF EMPTY(cFornSWN) .OR. cTipoNF # NFE_IMPOSTOS
         cFornSWN:=SF1->F1_FORNECE
         cLojaSWN:=SF1->F1_LOJA
      ENDIF
      
      IF ASCAN(aLista,{|F|F=SF1->F1_FORNECE}) = 0
         SA2->(DBSEEK(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
         AADD(aLista,SF1->F1_FORNECE+"-"+SF1->F1_LOJA+"-"+SA2->A2_NREDUZ)//FDR - 21/09/12 - Tratamento de Loja
      ENDIF

      SWN->(DBSEEK(xFilial("SWN")+SF1->F1_DOC+SF1->F1_SERIE+cFornSWN))

      DO WHILE SWN->(!EOF())                 .AND.;
            SWN->WN_FILIAL == xFilial("SWN") .AND.;
            SWN->WN_DOC    == SF1->F1_DOC    .AND.;
            SWN->WN_SERIE  == SF1->F1_SERIE  .AND.;
            SWN->WN_FORNECE== cFornSWN       .AND.; 
            SWN->WN_LOJA   == cLojaSWN

         IF SWN->WN_TIPO_NF # cTipoNF .OR.;
            SWN->WN_HAWB    # SW6->W6_HAWB
            SWN->(DBSKIP())
            LOOP
         ENDIF
         
         DI156IncProc(STR0133) //"Lendo Nota Fiscal, Aguarde..."

         Work1->(DBAPPEND())
         Work1->WK_NFE     := SWN->WN_DOC
         Work1->WK_SE_NFE  := SWN->WN_SERIE
         Work1->WKTEC      := SWN->WN_TEC
         Work1->WKEX_NCM   := SWN->WN_EX_NCM
         Work1->WKEX_NBM   := SWN->WN_EX_NBM
         Work1->WKQTDE     := SWN->WN_QUANT   
         Work1->WKPRECO    := SWN->WN_PRECO   
         Work1->WKPO_NUM   := SWN->WN_PO_EIC
         IF EasyEntryPoint("COMPSC01") .AND.;
            !EMPTY(SWN->WN_QTSEGUM)
            Work1->WKQTDE := SWN->WN_QTSEGUM
            SB1->(DBSEEK(xfilial()+SWN->WN_PRODUTO)) 
            IF SB1->B1_TIPCONV == "M"//Gravou convertido, esta voltando ao valor original
               Work1->WKPRECO:=SWN->WN_PRECO / SB1->B1_CONV
            ELSE
               Work1->WKPRECO:=SWN->WN_PRECO * SB1->B1_CONV
            ENDIF
         ENDIF
         Work1->WKCOD_I    := SWN->WN_PRODUTO
         IF cTipoNF = NFE_IMPOSTOS
            Work1->WKVALMERC:= SWN->WN_CIF
         ELSE
            Work1->WKVALMERC:= SWN->WN_VALOR
         ENDIF
         Work1->WK_CFO     := SWN->WN_CFO
         Work1->WK_OPERACA := SWN->WN_OPERACA
         Work1->WKDESCR    := SWN->WN_DESCR
         Work1->WKUNI      := SWN->WN_UNI
         Work1->WKPRUNI    := SWN->WN_PRUNI
         Work1->WKPESOL    := SWN->WN_PESOL
         Work1->WKSEGURO   := SWN->WN_SEGURO
         Work1->WKCIF      := SWN->WN_CIF
         Work1->WKOUT_DESP := SWN->WN_DESPESA
         Work1->WKFRETE    := SWN->WN_FRETE
         Work1->WK_CFO     := SWN->WN_CFO
         Work1->WKOUT_D_US := SWN->WN_OUTR_US
         Work1->WKFOB_R    := SWN->WN_FOB_R
         Work1->WKFORN     := SWN->WN_FORNECE
         Work1->WKLOJA     := SWN->WN_LOJA
         Work1->WKPOSICAO  := SWN->WN_ITEM
         Work1->WKPGI_NUM  := SWN->WN_PGI_NUM
         Work1->WKINVOICE  := SWN->WN_INVOICE
         Work1->WKVALMERUS := Work1->WKVALMERC / SW6->W6_TX_US_D
         Work1->WK_DT_NFE  := SF1->F1_EMISSAO
         SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))
         IF(ASCAN(aLista,{|F|F=Work1->WKFORN})=0,AADD(aLista,Work1->WKFORN+"-"+Work1->WKLOJA+"-"+SA2->A2_NREDUZ),)//FDR - 21/09/12 - Tratamento de Loja

         MDI_OUTR    +=Work1->WKOUT_DESP
         nValTotMerUS+=Work1->WKVALMERUS
         IF Work1->WKVALMERC > nMaiorWK1
            nMaiorWK1:= Work1->WKVALMERC
            nRecnowk1:= Work1->(RECNO())
         ENDIF
         IF lLote
            Work1->WK_LOTE  := SWN->WN_LOTECTL
            Work1->WKDTVALID:= SWN->WN_DTVALID
         ENDIF    
         IF lWN_DESPSUB
            Work1->WKDESPSUB := SWN->WN_DESPSUB
         ENDIF
         IF lWN_CODESP
            SYB->(DbSeek(xFilial("SYB")+SWN->WN_CODESP))
            Work1->WKDESPESA := SWN->WN_CODESP+" "+SYB->YB_DESCR
         ENDIF
         //TRP-10/01/08
         IF SWN->( FieldPos("WN_TES") ) > 0
            Work1->WKTES := SWN->WN_TES
         ELSEIF SW7->( FieldPos("W7_TES") ) > 0
            SW7->(DbSetOrder(4))
            SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB+Work1->WKPO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM))
            Work1->WKTES := SW7->W7_TES
         ELSE
            SYD->(DbSetOrder(1))
            SYD->(DbSeek(xFilial()+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
            Work1->WKTES := SYD->YD_TES
         ENDIF   
         DI156LerGrvImpostos('LER_SF1_SWN')

         IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'LER_SF1_SWN'),)

         SWN->(DBSKIP())

      ENDDO

      SF1->(DBSKIP())

   ENDDO



ELSE

   EI2->(DBSETORDER(1))

   ProcRegua(50)

   EI2->(DBSEEK(xFilial()+SW6->W6_HAWB))

   DO WHILE ! EI2->(EOF())                     .AND.;
              EI2->EI2_FILIAL == xFilial("EI2").AND.;
              EI2->EI2_HAWB   == SW6->W6_HAWB

      DI156IncProc(STR0134) //"Lendo Custo, Aguarde..."

      IF EI2->EI2_TIPO_NF # cTipoNF
         EI2->(DBSKIP())
         LOOP
      ENDIF

      Work1->(DBAPPEND())
      Work1->WK_NFE    := EI2->EI2_DOC
      Work1->WK_SE_NFE := EI2->EI2_SERIE
      Work1->WKTEC     := EI2->EI2_TEC
      Work1->WKEX_NCM  := EI2->EI2_EX_NCM
      Work1->WKEX_NBM  := EI2->EI2_EX_NBM
      Work1->WKPO_NUM  := EI2->EI2_PO_NUM
      Work1->WKQTDE    := EI2->EI2_QUANT
      Work1->WKCOD_I   := EI2->EI2_PRODUT
      Work1->WKVALMERC := EI2->EI2_VALOR
      Work1->WK_CFO    := EI2->EI2_CFO
      Work1->WK_OPERACA:= EI2->EI2_OPERAC
      Work1->WKPRECO   := EI2->EI2_PRECO
      Work1->WKDESCR   := EI2->EI2_DESCR
      Work1->WKUNI     := EI2->EI2_UNI
      Work1->WKPRUNI   := EI2->EI2_PRUNI
      Work1->WKPESOL   := EI2->EI2_PESOL
      Work1->WKSEGURO  := EI2->EI2_SEGURO
      Work1->WKCIF     := EI2->EI2_CIF
      Work1->WKOUT_DESP:= EI2->EI2_DESPES
      Work1->WKFRETE   := EI2->EI2_FRETE
      Work1->WK_CFO    := EI2->EI2_CFO
      Work1->WKOUT_D_US:= EI2->EI2_OUTR_U
      Work1->WKFOB_R   := EI2->EI2_FOB_R
      Work1->WKFORN    := EI2->EI2_FORNEC
      //FDR - 19/09/12 - Tratamento de Loja
      If EICLoja()
         Work1->WKLOJA := EI2->EI2_LOJA
      EndIf
      Work1->WKPOSICAO := EI2->EI2_POSICA
      Work1->WKPGI_NUM := EI2->EI2_PGI_NU
      Work1->WKINVOICE := EI2->EI2_INVOIC
      Work1->WKVALMERUS:= Work1->WKVALMERC / SW6->W6_TX_US_D
      IF lLote
         Work1->WK_LOTE  :=EI2->EI2_LOTECT
         Work1->WKDTVALID:=EI2->EI2_DTVALI 
      ENDIF
      //TRP-10/01/08
      IF SW7->( FieldPos("W7_TES") ) > 0
         SW7->(DbSetOrder(4))
         SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB+Work1->WKPO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM))
         Work1->WKTES := SW7->W7_TES
      ELSE
         SYD->(DbSetOrder(1))
         SYD->(DbSeek(xFilial()+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
         Work1->WKTES := SYD->YD_TES   
      ENDIF
      SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))
      IF(ASCAN(aLista,{|F|F=Work1->WKFORN})=0,AADD(aLista,Work1->WKFORN+"-"+Work1->WKLOJA+"-"+SA2->A2_NREDUZ),)//FDR - 21/09/12 - Tratamento de Loja

      MDI_OUTR +=Work1->WKOUT_DESP

      DI156LerGrvImpostos('LEREI2')
      
      IF (EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'LEREI2'),)

      EI2->(DbSkip())

   ENDDO

ENDIF
MDI_FOB := MDI_FOB_R / SW6->W6_TX_US_D

//MFR OSSME-1974 28/12/2018
If nRecnoWK1 > 0

    Work1->(DBGOTO(nRecnoWK1))
    DO CASE
    CASE cTipoNF == NFE_FOB .AND. cMoeDolar == cMoedaProc
            IF MDI_FOB # nValTotMerUS
            Work1->WKVALMERUS+=MDI_FOB - nValTotMerUS
            ENDIF

    CASE cTipoNF = NFE_FRETE .AND. cMoeDolar == SW6->W6_FREMOED
            IF MDI_FRET_MOE # nValTotMerUS
            Work1->WKVALMERUS+=MDI_FRET_MOE - nValTotMerUS
            ENDIF

    CASE cTipoNF = NFE_SEGURO .AND. cMoeDolar == SW6->W6_SEGMOEDA
            IF SW6->W6_VL_USSE # nValTotMerUS
            Work1->WKVALMERUS+=SW6->W6_VL_USSE - nValTotMerUS
            ENDIF

    CASE (cTipoNF = NFE_IMPOSTOS     .OR. ;
            cTipoNF = NFE_CIF)         .AND.;
            cMoeDolar == cMoedaProc .AND.;
            cMoeDolar == SW6->W6_FREMOED.AND.;
            cMoeDolar == SW6->W6_SEGMOEDA
            cCifUS:=(MDI_FOB+ MDI_FRET_MOE + (MDI_SEGURO / SW6->W6_TX_US_D))
            IF cCifUS # nValTotMerUS
            Work1->WKVALMERUS+=cCifUS - nValTotMerUS
            ENDIF

    ENDCASE
EndIf
DI156IncProc() // 100%

DBSELECTAREA("Work1")

Work1->(DBGOTOP())

RETURN .T.
*---------------------------------------*
Function DI156ForDesp()
*---------------------------------------*
LOCAL nTaxa

DI156IncProc(STR0319+Work4->WKDESPESA)

IF EMPTY(Work4->WKFLAG) .AND. (cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS)
   RETURN .F.
ENDIF

SWD->(DBGOTO(Work4->WKRECNO))

IF SYB->(DbSeek(xFilial("SYB")+Work4->WKDESPESA)).AND.;
   !(SYB->YB_BASECUS $ cNao)

   IF lTemSelo .AND. SWD->WD_DESPESA == cDespSelo
      DI156TabDes(aDespesa)
      RETURN .T.
   ELSEIF !EMPTY(Work4->WKFLAG) .AND. SWD->WD_DESPESA # "ERC"
      //nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI)
      nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DT_EMIS)
      MDI_OUTR +=SWD->WD_VALOR_R
      MDI_OU_US+=SWD->WD_VALOR_R / IF(nTaxa#0,nTaxa,1)
   ENDIF

   DI156TabDes(aDespesa)
ELSE   
   RETURN .F.
ENDIF

RETURN .T.
*---------------------------------------*
Function DI156Grava()
*---------------------------------------*
LOCAL bFor1:={|| !LEFT(Work4->WKDESPESA,1) $ '1,2,9' .AND. Empty(Work4->WKNOTA)}
LOCAL bFor2:={|| !LEFT(Work4->WKDESPESA,1) $ '1,2,9' }, cChave:=''
Local nPos := 0
LOCAL nNBM_FOB:=nNBM_FRETE:=nNBM_FOB_R:=nNBM_SEGURO:=0, i
LOCAL nOUTRDESP := nOUTRD_US:= nPesoTot:=0//nRDIFCamb:=
Local lExistEZZ := SX2->(dbSeek("EZZ"))
Local aOrdWK1 := {}

PRIVATE nVlrMaior := 0, nRecno:=1, lPesoNew := 0 
PRIVATE cFilSW7:=xFilial('SW7'),nRatIPD:=0
Private nItemNf := 0 //Número sequencial que será incrementado na graação da Work1.
//Private aItemNf := {} //SVG - 15/07/2010 -

nTotSelo:=MDespesas:= nContProc:= nSomaNoCIF:=0//nDifCamb:= 
aDespesa := {}; nFob:=nTx_Seguro:=0; cTipoTx:=""
aDesAcerto:={}; aRecWork1:={}

ProcRegua(Work4->(LASTREC()))

IF cTipoNF = NFE_DESPESAS
   Work4->(DbEval({|| DI156ForDesp()},bFor1))//Ignora despesas com Numero de Nota
   IF Empty(MDI_OUTR)
      Return .F.
   Endif
ELSEIF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
   Work4->(DbEval({|| DI156ForDesp()},bFor2))//Le todas as despesas
ENDIF

ProcRegua(50)

DI156IncProc()

SWZ->(DBSETORDER(2) )
SYB->(DBSETORDER(1) )
SW7->(DBSETORDER(4))
SW7->(DbSeek(cFilSW7+SW6->W6_HAWB))
SW2->(DbSeek(xFilial()+SW7->W7_PO_NUM))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))//FDR - 21/09/12 - Tratamento de Loja
SW4->(DbSeek(xFilial("SW4")+SW7->W7_PGI_NUM))

IF !empty(SW6->W6_VL_USSEG)
   nTx_Seguro:=SW6->W6_TX_SEG
ENDIF
DI156IncProc()

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRVWORK_1"),)

SW8->(DBSETORDER(1)) 
SW9->(DBSETORDER(3))
SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))

MDespesas:=MDI_FOB:=MDespMoeda:=0

nTotalPuro:=SW6->W6_FOB_TOT
IF lLerFOBPuro//so p/ NF impostos
   nTotalPuro:=0
ENDIF

DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                              SW9->W9_HAWB == SW6->W6_HAWB
          
   MDespesas += DI600RetVal( "TOT_INV,SEM_FOB", "TAB", .T., .T. )  // EOB - 03/06/08 - chamada da função DI600RetVal
   
   IF lLerFOBPuro//so p/ NF impostos
      SW8->(DBSEEK(xFilial("SW8")+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9", "W9_FORLOJ")))//FDR - 13/09/12 - Tratamento de loja
      DO WHILE SW8->W8_HAWB    == SW9->W9_HAWB   .AND. ;
               SW8->W8_INVOICE == SW9->W9_INVOICE.AND. ;
               SW8->W8_FORN    == SW9->W9_FORN   .AND. ;
               (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ) .AND. !SW8->(EOF())//FDR - 20/09/12 - Tratamento de Loja
         
         IF !EMPTY(SW8->W8_PRECO_F)
            nTotalPuro +=   SW8->W8_PRECO_F*SW9->W9_TX_FOB 
         ELSE
            nTotalPuro +=   SW8->W8_PRECO*SW8->W8_QTDE*SW9->W9_TX_FOB 
         ENDIF
         SW8->(DBSKIP())
      ENDDO
      nTotalPuro := DITrans(nTotalPuro, 2)
   ENDIF
   IF SW9->W9_MOE_FOB # cMoeDolar
      cMoedaProc:=SW9->W9_MOE_FOB
   ENDIF
   SW9->(DBSKIP())
ENDDO

//EOS - inclusao das invoices especiais
IF cRatProc $ cSim .AND. lExistEZZ
   cFilEZZ:=xFilial("EZZ")
   EZZ->(DBSETORDER(1))
   EZZ->(DbSeek(cFilEZZ+SW6->W6_HAWB)) 
   DO WHILE ! EZZ->(EOF()) .AND. EZZ->EZZ_FILIAL == cFilEZZ .AND. EZZ->EZZ_HAWB == SW6->W6_HAWB
      MDespesas += DI600RetVal( "INV_ESP", "TAB", .T., .T. )  // EOB - 03/06/08 - chamada da função DI600RetVal
      EZZ->(DBSKIP())
   ENDDO   
ENDIF

MDI_FOB_R  := DITrans(SW6->W6_FOB_TOT+MDespesas,2)

IF cTipoNF # NFE_DESPESAS
   IF cTipoNF # NFE_FOB
      MDI_FRETE    := DITRANS(ValorFrete(SW6->W6_HAWB,,,1),2)
      MDI_FRET_MOE := ValorFrete(SW6->W6_HAWB,,,2)
      MDI_SEGURO   := DITRANS(SW6->W6_VLSEGMN,2)
                         
      // EOS - 06/10/03                                                                            
      IF cPaisLoc # "BRA"
         DI156BASEG()
      ENDIF
      
      IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"BASE_SEGURO"),)
      
   ENDIF
   IF cTipoNF = NFE_SEGURO
      MDI_FRET_MOE := 0
      MDI_FRETE:=0
   ENDIF
   IF cTipoNF = NFE_FRETE
      MDI_SEGURO:=0
   ENDIF
   MDI_CIF := DITrans( MDI_FOB_R + MDI_FRETE + MDI_SEGURO + nSomaNoCIF, 2)
ENDIF

DI156IncProc()

SW7->(DbSeek(cFilSW7+SW6->W6_HAWB))
SW0->(DBSETORDER(1))
SYQ->(DBSETORDER(1))
SY1->(DBSETORDER(1))
SW8->(DBSETORDER(1)) 
SY4->(DBSETORDER(1)) 
SYW->(DBSETORDER(1)) 
SW9->(DBSETORDER(3))
Work1->(dbsetorder(3))
Work3->(DBSETORDER(1))

DI156IncProc()

SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
IF cTipoNF = NFE_FRETE 
   SY4->(DBSEEK(xFilial("SY4")+SW6->W6_AGENTE))
ELSEIF cTipoNF = NFE_SEGURO
   SYW->(DBSEEK(xFilial("SYW")+SW6->W6_CORRETO))
ENDIF
aTotalForn:={}
DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == xFILIAL("SW9") .AND. SW9->W9_HAWB == SW6->W6_HAWB
   DI156IncProc(STR0136+SW8->W8_COD_I) //"Lendo Item: "
   SW8->(DBSEEK(xFilial("SW8")+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9", "W9_FORLOJ")))//FDR - 13/09/12 - Tratamento de loja
   nTotal_Aux:=nRateioDes:=0; nVl_Maior:=0; nRecno_Aux:= 0
   n_Tx_Fob  := SW9->W9_TX_FOB
   
   DO WHILE SW8->W8_HAWB    == SW9->W9_HAWB   .AND. ;
            SW8->W8_INVOICE == SW9->W9_INVOICE.AND. ;
            SW8->W8_FORN    == SW9->W9_FORN   .AND. ;
            (!EICLoja() .Or. SW8->W8_FORLOJ == SW9->W9_FORLOJ) .AND. !SW8->(EOF())//FDR - 20/09/12 - Tratamento de Loja
           
         //cChave:=SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM+SW8->W8_INVOICE
         cChave:= (SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_TEC+SW8->W8_EX_NCM+SW8->W8_EX_NBM+SW8->W8_PO_NUM+SW8->W8_COD_I)//FDR - 20/09/12 - Tratamento de Loja
         IF !Work1->(DBSEEK(cChave))
            Work1->(DBAPPEND())
            Work1->WKPO_NUM :=SW8->W8_PO_NUM
            Work1->WKPOSICAO:=SW8->W8_POSICAO
            Work1->WKPGI_NUM:=SW8->W8_PGI_NUM
            Work1->WKINVOICE:=SW8->W8_INVOICE
            DO CASE 
               CASE  cTipoNF==NFE_FOB       //1  ==> '5'
	               Work1->WK_DT_NFE:= SW9->W9_DT_EMIS
	           CASE  cTipoNF==NFE_FRETE     //2  ==> '6'
	               Work1->WK_DT_NFE:= SW6->W6_DT_HAWB
	           CASE  cTipoNF==NFE_SEGURO    //3  ==> '7'
	               Work1->WK_DT_NFE:= SW6->W6_DT_HAWB
	           CASE  cTipoNF==NFE_CIF       //6  ==> '8'
	               Work1->WK_DT_NFE:= SW9->W9_DT_EMIS
	           CASE  cTipoNF==CUSTO_REAL    //7  ==> 'B'
	               Work1->WK_DT_NFE:= SW9->W9_DT_EMIS
	        ENDCASE
            IF cTipoNF = NFE_FOB .OR. cTipoNF = NFE_CIF
               Work1->WK_NFE:=SW8->W8_INVOICE
            ENDIF   
         ENDIF   
         nFob:= DITrans(SW8->W8_PRECO*SW8->W8_QTDE,2)
 	  	 IF cRatProc $ cSim
         	nRateioDes:= DITRANS(mDespesas * ((nFob*n_Tx_Fob)/SW6->W6_FOB_TOT),2)
         ELSE
           	nRateioDes:= DITRANS(DI600RetVal("ITEM_INV,SEM_FOB", "TAB", .T.))  // EOB - 03/06/08 - chamada da função DI600RetVal
         ENDIF

         DI156GrvWork1()

         IF EasyEntryPoint("EICDI156")
		   ExecBlock("EICDI156",.F.,.F.,"GRAVA_WORK1")
		 ENDIF               

         SW8->(DBSKIP())
   ENDDO   
   SW9->(DBSKIP())
ENDDO             

IF !EMPTY(cFornSWN) .AND. ASCAN(aLista,{|F|F=cFornSWN}) = 0 .AND. cTipoNF = NFE_IMPOSTOS
   SA2->(DBSEEK(xFilial("SA2")+cFornSWN+cLojaSWN))
   AADD(aLista,cFornSWN+"-"+cLojaSWN+"-"+SA2->A2_NREDUZ)//FDR - 21/09/12 - Tratamento de Loja
ENDIF

DI156Lote()
//SVG - 15/07/2010 - Posicionada rotina apos a informação do numero e serie da nota, assim numeração do campo WN_ITEMNF fica correta.
/*
//É realizado um nov loop na Work1 para regravar o campo WN_ITEMNF de
//acordo com a ordem de gravação utilizada na tabela SD1. (Ordenado
//conforme a chave 7 de indice da Work1)      
//Essa ação é necessária, porque a gravação da Work1 não utiliza
//um ordem que contempla os campos da chave 7 da Work1.
If SWN->(FieldPos("WN_ITEMNF")) > 0 
   aOrdWK1 := SaveOrd({"Work1"})
   
   nItemNf := 1
   
   Work1->(DbSetOrder(2))//JVR - 11/06/10
   Work1->(DbGoTop())
   While Work1->(!EOF())
      
      //nPos := aScan(aItemNF,Work1->(WKINVOICE+WKFORN))
      nPos := aScan(aItemNF,Work1->(WK_NFE+WK_SE_NFE))

      If nPos > 0 
         nItemNf++ 
      Else
         nItemNf := 1
         //aAdd(aItemNF,Work1->(WKINVOICE+WKFORN))
         aAdd(aItemNF,Work1->(WK_NFE+WK_SE_NFE))//JVR - 11/06/10 - Alterado a chave.
      EndIf
      
      Work1->WK_ITEMNF := STRZERO(nItemNf,Len(SWN->WN_ITEMNF))
   
      Work1->(DbSkip())
   EndDo

   RestOrd(aOrdWK1,.T.)
EndIf
*/
DI156Work3Grv()

SW8->(DBSETORDER(1))

Work1->(dbsetorder(3)) 

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRVWORK_2"),)

IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_FRETE .OR.;
   cTipoNF = NFE_CIF      .OR. cTipoNF = CUSTO_REAL
   DI156LeEIB(.T.)
ENDIF

FOR I=1 TO LEN(aDesAcerto)
   IF lTemSelo .AND. LEFT(aDesAcerto[I,1],3) == cDespSelo// estampilhas de cigarro
      LOOP
   ENDIF
   IF aDesAcerto[I,2] # aDesAcerto[I,4]
      Work3->(DBGOTO(aDesAcerto[I,6]))
      Work3->WKVALOR   :=Work3->WKVALOR   +(aDesAcerto[I,4]-aDesAcerto[I,2])
   ENDIF
   IF aDesAcerto[I,3] # aDesAcerto[I,5]
      Work3->(DBGOTO(aDesAcerto[I,6]))
      Work3->WKVALOR_US:=Work3->WKVALOR_US+(aDesAcerto[I,5]-aDesAcerto[I,3])
   ENDIF
NEXT

Work2->(DBGOTOP())

ProcRegua( Work2->( LASTREC() ) * 2 )
nVlrMaior:=0
nRecnoWK2:=Work2->(RECNO())

DO WHILE  Work2->(!EOF())

   DI156IncProc(STR0137) //"Gravando impostos das NCMs"

   IF cTipoNF # NFE_DESPESAS 
      DI156FreSegCIF("1")
   ENDIF

   IF !cTipoNF $ NFE_PRIMEIRA
      Work2->WKOUTRDESP:= DITRANS(MDI_OUTR  * (Work2->WKFOBR_ORI / MDI_FOB_R),2)
      Work2->WKOUTRD_US:= DITRANS(MDI_OU_US * (Work2->WKFOBR_ORI / MDI_FOB_R),2)
   ENDIF

   IF cTipoNF = NFE_DESPESAS 
      IF Work2->WKOUTRDESP > nVlrMaior
         nVlrMaior:=Work2->WKOUTRDESP
         nRecnoWK2:=Work2->(RECNO())
      ENDIF  
   ELSEIF Work2->WKCIF > nVlrMaior
      nVlrMaior:=Work2->WKCIF
      nRecnoWK2:=Work2->(RECNO())
   ENDIF  

   nNBM_FOB_R  += Work2->WKFOB_R
   nNBM_FOB    += Work2->WKFOB
   nNBM_FRETE  += Work2->WKFRETE
   nNBM_SEGURO += Work2->WKSEGURO
   nOUTRDESP   += Work2->WKOUTRDESP
   nOUTRD_US   += Work2->WKOUTRD_US

   Work2->(DBSKIP())
ENDDO

Work2->(DBGOTO(nRecnoWK2))

IF lLerFOBPuro//so p/ NF impostos
   IF nTotalPuro # nNBM_FOB_R 
      Work2->WKFOB_R += nTotalPuro - DiTrans( nNBM_FOB_R,2 )
   ENDIF
ELSE
   IF MDI_FOB_R # nNBM_FOB_R 
      Work2->WKFOB_R += MDI_FOB_R - DiTrans( nNBM_FOB_R,2 )
   ENDIF
ENDIF

IF MDI_FRETE # nNBM_FRETE
   Work2->WKFRETE += MDI_FRETE - DiTrans( nNBM_FRETE,2 )
ENDIF

IF MDI_SEGURO # nNBM_SEGURO
   Work2->WKSEGURO += MDI_SEGURO - DiTrans( nNBM_SEGURO,2 )
ENDIF

IF !cTipoNF $ NFE_PRIMEIRA
   IF MDI_OUTR # nOUTRDESP
      Work2->WKOUTRDESP += MDI_OUTR - DiTrans( nOUTRDESP,2 )
   ENDIF

   IF MDI_OU_US # nOUTRD_US
      Work2->WKOUTRD_US += MDI_OU_US - DiTrans( nOUTRD_US,2 )
   ENDIF
ENDIF

Work1->(DBGOTOP())
Work2->(DBGOTOP())
nValFOBUS:=nValTotMerUS:=nMaiorWK1:=0
nRecnoWK1:=Work1->(RECNO())

DO WHILE  Work2->(!EOF())

   DI156IncProc(STR0137) //"Gravando impostos das NCMs"

   IF cTipoNF # NFE_DESPESAS
      DI156FreSegCIF("2")
   ENDIF

   IF cTipoNF == NFE_DESPESAS
      Work2->WKCIF    := 0
      Work2->WKFRETE  := 0
      Work2->WKSEGURO := 0
   ENDIF

   DI156Rateio(.F.)

   IF cTipoNF == NFE_DESPESAS .OR. cTipoNF $ NFE_FRE_SEG
      Work2->WKFOB_R  := 0
      Work2->WKFOB    := 0
      Work2->WKCIF    := 0
   ENDIF
   IF cTipoNF == NFE_FRETE
      Work2->WKFOB_R  := Work2->WKFRETE
   ELSEIF cTipoNF == NFE_SEGURO
      Work2->WKFOB_R  := Work2->WKSEGURO
   ELSEIF (cTipoNF == NFE_IMPOSTOS .OR. cTipoNF == CUSTO_REAL .OR. cTipoNF == NFE_CIF);
          .AND. EMPTY(Work2->WKFOB_US)
      Work2->WKFOB_US := Work2->WKCIF / SW6->W6_TX_US_D
   ENDIF
   IF cTipoNF # NFE_IMPOSTOS .AND. EMPTY(Work2->WKFOB_US)
      Work2->WKFOB_US := Work2->WKFOB_R / SW6->W6_TX_US_D
   ENDIF
   
   nValFOBUS+=Work2->WKFOB_US

   Work2->(DBSKIP())
ENDDO
MDI_FOB := MDI_FOB_R / SW6->W6_TX_US_D
Work2->(DBGOTO(nRecnoWK2))
Work1->(DBGOTO(nRecnoWK1))
DO CASE
   CASE cTipoNF = NFE_FOB .AND. cMoeDolar == cMoedaProc
        IF MDI_FOB # nValTotMerUS
           Work1->WKVALMERUS+=MDI_FOB - nValTotMerUS
        ENDIF
        IF MDI_FOB # nValFOBUS
           Work2->WKFOB_US  +=MDI_FOB - nValFOBUS
        ENDIF

   CASE cTipoNF = NFE_FRETE .AND. cMoeDolar == SW6->W6_FREMOED
        IF MDI_FRET_MOE # nValTotMerUS
           Work1->WKVALMERUS+=MDI_FRET_MOE - nValTotMerUS
        ENDIF
        IF MDI_FRET_MOE # nValFOBUS
           Work2->WKFOB_US  +=MDI_FRET_MOE - nValFOBUS
        ENDIF

   CASE cTipoNF = NFE_SEGURO .AND. cMoeDolar == SW6->W6_SEGMOEDA
        IF SW6->W6_VL_USSE # nValTotMerUS
           Work1->WKVALMERUS+=SW6->W6_VL_USSE - nValTotMerUS
        ENDIF
        IF SW6->W6_VL_USSE # nValFOBUS
           Work2->WKFOB_US  +=SW6->W6_VL_USSE - nValFOBUS
        ENDIF

   CASE (cTipoNF = NFE_IMPOSTOS     .OR. ;
         cTipoNF = NFE_CIF)         .AND.;
        cMoeDolar == cMoedaProc .AND.;
        cMoeDolar == SW6->W6_FREMOED.AND.;
        cMoeDolar == SW6->W6_SEGMOEDA
        cCifUS:=(MDI_FOB+ MDI_FRET_MOE + (MDI_SEGURO / SW6->W6_TX_US_D) )
        IF cCifUS # nValTotMerUS
           Work1->WKVALMERUS+=cCifUS - nValTotMerUS
        ENDIF
        IF cCifUS # nValFOBUS
           Work2->WKFOB_US  +=cCifUS - nValFOBUS
        ENDIF

ENDCASE

DBSELECTAREA("Work2")
DI156IncProc()

Work2->(DBGOTOP())

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"FINALGRAVA1"),)

IF cTipoNF = NFE_DESPESAS
   MDI_OUTR +=nTotSelo
   DI156GeraDespesas()
ENDIF

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"FINALGRAVA2"),)

IF cTipoNF = NFE_DESPESAS .OR.;
   cTipoNF = NFE_IMPOSTOS .OR.;
   cTipoNF = CUSTO_REAL
   DI156GerImpostos(cTipoNF = NFE_DESPESAS)
ENDIF

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"FINALGRAVA3"),)

aDesAcerto:={}

RETURN NIL   

*--------------------------*                       
FUNCTION DI156GrvWork1()
*--------------------------*     
LOCAL lErro:=.T.,nValor:=0
Local cSerieNFE:= ""

IF !SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
   MSGINFO(STR0318,STR0022) //"Existe Desbalanceamento no Banco de Dados, por favor saia do Sistema."###"Atenção"
   RETURN .F.
ENDIF
DI156IncProc(STR0136+SW7->W7_COD_I) //"Lendo Item: "

SB1->(DbSeek(xFilial("SB1")+SW7->W7_COD_I))
SW2->(DbSeek(xFilial()+SW7->W7_PO_NUM))

M->WK_TEC   :=SW8->W8_TEC
M->WK_EX_NCM:=SW8->W8_EX_NCM
M->WK_EX_NBM:=SW8->W8_EX_NBM

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRVWORK_1A"),)

SWZ->(DbSeek(xFilial("SWZ")+SW7->W7_OPERACA))

// REGIANE - PARAGUAI EM ENERO/2002 PARA GARANTIR QUE TEM TES E QUE EXISTE A NCM NO CADASTRO
// CASO CONTRARIO A CLASSIFICACAO DA NOTA É FEITA COM ERRO, PASSAR AS MSGS PARA STR
IF !SYD->(DbSeek(xFilial("SYD")+M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM))
   IF !EMPTY(M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM)
      MSGSTOP("Producto sen partida arancelaria ! " + M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM , "STOP")      
   ELSE       
      MSGSTOP("Partida Arancelaria en blanco " , "ATENCION")
   ENDIF   
ELSE       
   IF EMPTY(SYD->YD_TES) 
      MSGSTOP("TES invalido en archivo de partida arancelaria : " + M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM , "STOP")
   ENDIF
ENDIF   

IF !Work2->(DbSeek(SWZ->WZ_CFO+SW7->W7_OPERACA+M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM))
   Work2->(DBAPPEND())
   Work2->WK_OPERACA  := SW7->W7_OPERACA
   Work2->WK_CFO      := SWZ->WZ_CFO
   Work2->WKTEC       := M->WK_TEC
   Work2->WKEX_NCM    := M->WK_EX_NCM
   Work2->WKEX_NBM    := M->WK_EX_NBM
ENDIF

lPesoNew:=SW7->W7_PESO
IF lMV_EASY_SIM
   SB1->(DBSEEK(xfilial()+SW8->W8_COD_I)) 
   aTabSeg:=AV_Seg_Uni(SW8->W8_CC,SW8->W8_SI_NUM,SW8->W8_COD_I,SW8->W8_REG,SW8->W8_QTDE,,.T.)
   IF(LEN(aTabSeg)>2,lPesoNew:=aTabSeg[3],)
ENDIF

IF(EasyEntryPoint('EICDI156'),ExecBlock('EICDI156',.F.,.F.,"PESONEW"),)

nPesoTot := lPesoNew * SW8->W8_QTDE
nFob     := DITrans(SW8->W8_PRECO * SW8->W8_QTDE,2)
MDI_QTDE += SW8->W8_QTDE
MDI_PESO += nPesoTot

//SA5->(DbSeek(xFilial("SA5")+SW7->W7_COD_I+SW7->W7_FABR+SW7->W7_FORN))
//FDR - 21/09/12 - Tratamento de Loja
EICSFabFor(xFilial("SA5")+SW7->W7_COD_I+SW7->W7_FABR+SW7->W7_FORN, EICRetLoja("SW7", "W7_FABLOJ"), EICRetLoja("SW7", "W7_FORLOJ"))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))

Work1->WKCOD_I   := SW7->W7_COD_I
Work1->WKTEC     := M->WK_TEC
Work1->WKEX_NCM  := M->WK_EX_NCM
Work1->WKEX_NBM  := M->WK_EX_NBM
Work1->WKPRECO   := SW8->W8_PRECO
Work1->WKDESCR   := MSMM(SB1->B1_DESC_P,60,1)
Work1->WKUNI     := IF(! EMPTY(SA5->A5_UNID),SA5->A5_UNID,SB1->B1_UM)
Work1->WKRECNO   := SW7->(RECNO())
Work1->WKFORN    := SW7->W7_FORN
Work1->WKLOJA    := SA2->A2_LOJA
Work1->WKFORNITEM:= SW7->W7_FORN
Work1->WKLOJAITEM:= SA2->A2_LOJA
Work1->WKPO_SIGA := DI154_PO_SIGA() // RA - 18/11/03 - O.S. 1252/03 // Antes=>SW2->W2_PO_SIGA
Work1->WK_CC     := SW7->W7_CC     
Work1->WKSI_NUM  := SW7->W7_SI_NUM
Work1->WK_CFO    := SWZ->WZ_CFO    
Work1->WK_OPERACA:= SW7->W7_OPERACA
Work1->WK_REG    := SW7->W7_REG
Work1->WKQTDE    := SW8->W8_QTDE
Work1->WKPESOL   := nPesoTot
Work1->WKFOBR_ORI:= DITRANS((nFob * n_Tx_Fob) +nRateioDes,2)
Work1->WKFOB_R   := DITRANS((nFob * n_Tx_Fob) +nRateioDes,2)

IF lLerFOBPuro//so p/ NF impostos
   IF !EMPTY(SW8->W8_PRECO_F)
      Work1->WKPRECO_F:=DITrans( SW8->W8_PRECO_F*SW9->W9_TX_FOB ,2)
   ELSE
      Work1->WKPRECO_F:=DITrans( SW8->W8_PRECO*SW8->W8_QTDE*SW9->W9_TX_FOB ,2)
   ENDIF
   Work1->WKFOB_R  :=Work1->WKPRECO_F
   Work2->WKPRECO_F+=Work1->WKPRECO_F
ENDIF

IF lTemSelo .AND. ASCAN( aDespesa,{|A|A[1]=cDespSelo } ) # 0// estampilhas de cigarro
   Work1->WKVLR_SELO+= DITRANS(SB1->B1_VLRSELO * SW8->W8_QTDE,2)
   nTotSelo         += DITRANS(SB1->B1_VLRSELO * SW8->W8_QTDE,2)
ENDIF

Work2->WKPESOL   += Work1->WKPESOL
Work2->WKFOB_R   += Work1->WKFOB_R
Work2->WKFOBR_ORI+= Work1->WKFOBR_ORI
Work2->WKQTDE    += Work1->WKQTDE

IF (nPosF:=ASCAN(aTotalForn,{|F| F[1] == SW9->W9_FORN } )) = 0 
   AADD(aTotalForn, {SW9->W9_FORN,Work1->WKFOBR_ORI} )
ELSE
   aTotalForn[nPosF,2]+=Work1->WKFOBR_ORI
ENDIF

//Os arquivos SY4 e SYW jah estao posicionados
IF cTipoNF = NFE_FRETE 
   Work1->WK_NFE := SW6->W6_HOUSE
   IF !EMPTY(SY4->Y4_FORN)
      Work1->WKFORN := SY4->Y4_FORN 
      Work1->WKLOJA := SY4->Y4_LOJA
   ENDIF
ELSEIF cTipoNF = NFE_SEGURO
   Work1->WK_NFE := SW6->W6_NF_SEG
   IF !EMPTY(SYW->YW_FORN)
      Work1->WKFORN := SYW->YW_FORN  
      Work1->WKLOJA := SYW->YW_LOJA
   ENDIF
ELSEIF cTipoNF = NFE_IMPOSTOS
   Work1->WK_NFE := cDocDespesa
   cSerieNFE:= cSerieDesp
   IF SWD->(FieldPos("WD_SE_DOC")) > 0
      Work1->WK_SE_NFE := SerieNfId(,4,"WN_SERIE",Work1->WK_DT_NFE,cMv_ESPEIC,cSerieDesp)//cSerieDesp
   ENDIF
   Work1->WKFORN := cFornDespesa
   Work1->WKLOJA := cLojaDespesa
ENDIF

//JVR - 01/06/10 - Inicializaçao do campo Serie.
IF cTipoNF # NFE_IMPOSTOS .And. Empty(cSerieNFE)
   cSerieNFE:= EasyGParam("MV_SER_ARG",,"A")
EndIf
Work1->WK_SE_NFE := SerieNfId(,4,"WN_SERIE",Work1->WK_DT_NFE,cMv_ESPEIC,cSerieNFE)
IF lNFAutomatica
   Work1->WK_NFE:=""
ENDIF
IF EMPTY(Work1->WK_NFE)
   Work1->WKFLAG:=cMarca
ELSE
   Work1->WKFLAG:=''
ENDIF
IF ASCAN(aRecWork1,Work1->(RECNO())) = 0
   AADD(aRecWork1,Work1->(RECNO()))
ENDIF

SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))
IF cTipoNF # NFE_DESPESAS .AND. ASCAN(aLista,{|F|F=Work1->WKFORN})=0
   AADD(aLista,Work1->WKFORN+"-"+Work1->WKLOJA+"-"+SA2->A2_NREDUZ)//FDR - 13/09/12 - Tratamento de loja
ENDIF
             
// EOS - 06/10/03                                                                 
IF cPaisLoc # "BRA" .AND. SW7->(FIELDPOS('W7_LOCAL')) # 0
   Work1->WKLOCAL:=SW7->W7_LOCAL
ENDIF

//TRP-10/01/08
IF SW7->( FieldPos("W7_TES") ) > 0 .AND. !EMPTY(SW7->W7_TES)
   Work2->WKTES := SW7->W7_TES
ELSE
   SYD->(DbSetOrder(1))
   SYD->(DbSeek(xFilial()+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))      
   Work2->WKTES := SYD->YD_TES
ENDIF
Work1->WKTES := Work2->WKTES
//** Incluso no padrão conforme Bops 128813 e 128403,Lucas 16/08/07 (Redondeo en prorrateo)
//
Work2->WKFOB_R   -= Work1->WKFOB_R
Work2->WKFOBR_ORI-= Work1->WKFOBR_ORI
nFob     := Round(SW8->W8_PRECO * SW8->W8_QTDE,2) 
Work1->WKFOBR_ORI:= DITRANS((nFob * n_Tx_Fob) +nRateioDes)
Work1->WKFOB_R   := DITRANS((nFob * n_Tx_Fob) +nRateioDes)

Work2->WKFOB_R   += Work1->WKFOB_R 
Work2->WKFOBR_ORI+= Work1->WKFOBR_ORI 
//

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRVWORK_4"),)


RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION DI156Work3Grv()
*----------------------------------------------------------------------------*
LOCAL cFilSA2 := xFilial("SA2"),nPosF
LOCAL cFilSB1 := xFilial("SB1"),nDespSub:=0
LOCAL cFilSF4 := xFilial("SF4"),nTotDespSub:=0
LOCAL cFilSYB := xFilial("SYB"),aDespSub:={}
LOCAL nMaior  := 0, nRec:=1, Wind

IF !(cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_DESPESAS .OR. cTipoNF = CUSTO_REAL)
   RETURN .F.
ENDIF

SA2->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SF4->(DBSETORDER(1))
SYB->(DBSETORDER(1))

Work1->(DBGOTOP())
ProcRegua( Work1->(LASTREC())*LEN(aDespesa) )

DO WHILE Work1->(!EOF())

   SW7->(DBGOTO(Work1->WKRECNO))
   lAcerta:=.T.
   FOR Wind = 1 TO LEN(aDespesa)
       
       IncProc(STR0319+aDespesa[Wind,1]) //"Gastos: "
       
       SWD->(DBGOTO(aDespesa[Wind,4]))      
       nRateio:=(Work1->WKFOBR_ORI/MDI_FOB_R) 
       lGrvWk3 := .T.
       // EOS - As despesas que contiverem o campo WD_FORNRAT preenchido, somente serao
       // rateadas para os itens do mesmo fornecedor 
       IF SWD->(FIELDPOS("WD_FORNRAT")) > 0 .AND. !EMPTY(SWD->WD_FORNRAT)
          IF SWD->WD_FORNRAT <> SW7->W7_FORN
             lGrvWk3 := .F.
          ELSEIF (nPosF:=ASCAN(aTotalForn,{|F| F[1] == SWD->WD_FORNRAT } )) # 0 
             nRateio:=(Work1->WKFOBR_ORI/aTotalForn[nPosF,2]) 
          ENDIF
       ENDIF
       IF lGrvWk3   
          //nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI)     
          nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DT_EMIS)     
          IF(nTaxa=0,nTaxa:=1,)
          IF !EMPTY(aDespesa[Wind,09]) .AND. ( cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS )
             cNotaF:= aDespesa[Wind,07]
             cForn := aDespesa[Wind,09]
             cLoja := aDespesa[Wind,10]
          ELSE
             cNotaF:= Work1->WK_NFE
             cForn := Work1->WKFORN
             cLoja := Work1->WKLOJA
          ENDIF
          cSeekWork3 := aDespesa[Wind,1]+cForn+cLoja+aDespesa[Wind,07]
          IF SWD->(FieldPos("WD_SE_DOC"))>0
             cSeekWork3 += aDespesa[Wind,11]        
          ENDIF
          IF !Work3->(DBSEEK(STRZERO(Work1->(RECNO()),nTamRec)+cSeekWork3))
             SYB->(DBSEEK(cFilSYB+aDespesa[Wind,1]))
             Work3->(DBAPPEND())
             Work3->WKRECNO   := STRZERO(Work1->(RECNO()),nTamRec)
             Work3->WKFLAG    := aDespesa[Wind,3]
             Work3->WKDESPESA := aDespesa[Wind,1]
             Work3->WKDESCR   := SYB->YB_DESCR
             Work3->WKPO_NUM  := Work1->WKPO_NUM
             Work3->WKPOSICAO := Work1->WKPOSICAO
             Work3->WKPGI_NUM := Work1->WKPGI_NUM
             Work3->WK_NF_COMP:= IIF(EMPTY(cNotaF),aDespesa[Wind,07],cNotaF) 
             IF SWD->(FieldPos("WD_SE_DOC"))>0  // EOS
                Work3->WK_SE_NFC:= aDespesa[Wind,11]//Serie da Nota Fiscal
             ENDIF
             Work3->WK_DT_NFC := aDespesa[Wind,08]
             Work3->WKFORN    := cForn
             Work3->WKLOJA    := cLoja
             Work3->WKDT_EMIS := aDespesa[Wind,13] //J.S.  SWD->WD_DT_EMIS ou dDataBase
             IF cTipoNF = NFE_IMPOSTOS
                Work1->WK_DT_NFE :=Work3->WKDT_EMIS
             ENDIF
             IF cTipoNF = NFE_DESPESAS .AND. ASCAN(aLista,{|F|F=cForn})=0
                SA2->(DBSEEK(cFilSA2+cForn+cLoja))
                AADD(aLista,cForn+"-"+cLoja+"-"+SA2->A2_NREDUZ)//FDR - 21/09/12
             ENDIF
             Work1->WKRECNOWK3:=Work3->(RECNO())
             Work1->WK_NFE_AUX:=aDespesa[Wind,07]//Nota Fiscal
          ENDIF                                   
          nValor:=DITRANS(aDespesa[Wind,2] * nRateio ,2)
          IF lTemSelo .AND. Work3->WKDESPESA == cDespSelo// estampilhas de cigarro
             SB1->(DbSeek(cFilSB1+Work1->WKCOD_I))
             Work3->WKVALOR+= DITRANS(SB1->B1_VLRSELO * Work1->WKQTDE,2)
          ELSE
             Work3->WKVALOR+= nValor
          ENDIF
          Work3->WKVALOR_US:= DITRANS(Work3->WKVALOR/nTaxa,2)
          Work3->WKTES     := aDespesa[Wind,12]   //EOS

          IF lWN_DESPSUB .AND. cTipoNF # NFE_DESPESAS//AWR 21/5/2003
             IF Work1->WKFOBR_ORI > nMaior
                nMaior:= Work1->WKFOBR_ORI
                nRec  := Work1->(RECNO())
             ENDIF
             IF SF4->(dbSeek(cFilSF4+Work3->WKTES)) .AND. SF4->F4_ESTOQUE $ cNao
                Work1->WKDESPSUB+= nValor
                nDespSub+= nValor
                IF ASCAN(aDespSub,Work3->WKDESPESA) = 0
                   AADD(aDespSub,Work3->WKDESPESA)
                   nTotDespSub+=aDespesa[Wind,2]
                ENDIF
             ENDIF
          ENDIF

          IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRVWORK3"),)
          IF lAcerta 
             IF (nPos:=ASCAN(aDesAcerto, {|D|D[10]==aDespesa[Wind,05]} )) = 0
                AADD(aDesAcerto,{Work3->WKDESPESA ,;//1
                                 Work3->WKVALOR   ,;//2
                                 Work3->WKVALOR_US,;//3
                                 aDespesa[Wind,2] ,;//4 Valor Total
                                 DITRANS(aDespesa[Wind,2]/nTaxa,2),;//5 Valor Total Dolar
                                 Work3->(RECNO()) ,;//6
                                 Work3->WK_NF_COMP,;//7
                                 aDespesa[Wind,09],;//8 Fornecedor
                                 aDespesa[Wind,10],;//9 Loja
                                 aDespesa[Wind,05]})//10 Recno Work4
             ELSE
                aDesAcerto[nPos,2] += nValor
                aDesAcerto[nPos,3] += DITRANS(nValor/nTaxa,2)
             ENDIF
          ENDIF
       ENDIF
   NEXT

   Work1->(DBSKIP())

ENDDO

IF lWN_DESPSUB .AND. cTipoNF # NFE_DESPESAS//AWR 21/5/2003
   Work1->(dbgoto(nRec))
   IF nDespSub # nTotDespSub
      Work1->WKDESPSUB+= (nTotDespSub-nDespSub)
   ENDIF
ENDIF

RETURN .T.

*----------------------------------------------------------------------------*
FUNCTION DI156IncProc(cMsg)
*----------------------------------------------------------------------------*
IF nContProc > 50
   ProcRegua(50)
   nContProc:=0
ENDIF   
nContProc++
IncProc(cMsg)
RETURN .T.     
*----------------------------------------------------------------------------*
FUNCTION DI156GrvDespesa()
*----------------------------------------------------------------------------*
LOCAL xFilSYB:=xFilial("SYB"),aDoc:={}
SYB->(DBSETORDER(1))
SWD->(DBSETORDER(1))
SWD->(DbSeek((xFilSWD:=xFilial("SWD"))+SW6->W6_HAWB))

nSomaNoCIF:=0

ProcRegua(10)

Work4->(AvZap())
cMensagem:=""
DO WHILE  xFilSWD == SWD->WD_FILIAL .AND. SWD->WD_HAWB==SW6->W6_HAWB .AND. !SWD->(EOF())

   DI156IncProc(STR0319+SWD->WD_DESPESA) //"Gastos: "

   IF !SYB->(DBSEEK(xFilSYB+SWD->WD_DESPESA))
      MSGINFO("Atencion! El gasto: "+SWD->WD_DESPESA+" no esta registrado en el registro de Gastos.")
      SWD->(DBSKIP())
      LOOP
   ENDIF
   IF SWD->(FieldPos("WD_TES")) > 0 .AND. !EMPTY(SWD->WD_TES)
      cCodTes := SWD->WD_TES
      cMensagem:="Gastos del Despacho "
   ELSE
      cCodTes := SYB->YB_TES
      cMensagem:="Gastos "
   ENDIF                         
   IF cCodTes > "499"
      MSGINFO("Atencion! El Codigo del TES: "+CCODTES+", del gasto: "+SWD->WD_DESPESA+" que esta en el registro de "+cMensagem+;
              "esta incorrecto, pues es mayor que 499.")
//    MSGINFO("Atencao! O Codigo da TES: "+CCODTES+", da despesa: "+SWD->WD_DESPESA+" que esta no cadastro de "+cMensagem+;
//            "esta incorreto, pois e maior que 499.")
      SWD->(DBSKIP())
      LOOP
   ENDIF

   Work4->(DBAPPEND())


   Work4->WKBASECUS:=SYB->YB_BASECUS
   Work4->WKBASEIMP:=SYB->YB_BASEIMP
   Work4->WKIMPINS :=SYB->YB_IMPINS
   IF SYB->YB_BASEIMP $ cSim
      nSomaNoCIF+=SWD->WD_VALOR_R
   ENDIF
   Work4->WKFLAG   :=''
   Work4->WKTES    :=cCodTes
   Work4->WKDESPESA:=SWD->WD_DESPESA+"-"+SYB->YB_DESCR
   Work4->WKVALOR  :=SWD->WD_VALOR_R
   Work4->WKDOC    :=SWD->WD_DOCTO
   IF SWD->(FieldPos("WD_SE_DOC")) > 0
      Work4->WKSEDOC := SWD->WD_SE_DOC
   ENDIF
   Work4->WKFORN   :=SWD->WD_FORN
   Work4->WKLOJA   :=SWD->WD_LOJA
   Work4->WKNOTA   :=SWD->WD_NF_COMP
   Work4->WKSERIE  :=SWD->WD_SE_NFC
   Work4->WKRECNO  :=SWD->(RECNO())
   IF !LEFT(Work4->WKDESPESA,1) $ "1,2,9" .AND.;
      EMPTY(Work4->WKNOTA) .AND.;
      (cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS)
      lTemDespesas:=.T.
      Work4->WKFILTRO:="S"                               
      IF cTipoNF # NFE_IMPOSTOS
         Work4->WKFLAG :=cMarca
      ENDIF
   ENDIF
   IF cTipoNF = CUSTO_REAL
      Work4->WKFLAG :=cMarca
   ENDIF
   IF !EMPTY(Work4->WKDOC) .AND. ASCAN(aDoc,Work4->WKDOC)=0
      AADD(aDoc,Work4->WKDOC)
      Work4->WKBRANCO :="N"
   ENDIF
   //ponto de entrada pedido por Alfio em 11/11/03 -rhp 
   IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRV_WORK4"),)

   SWD->(DBSKIP())

ENDDO                    

Return NIL
*----------------------------------------------------------------------------*
FUNCTION DI156Rateio(lAlteracao)
*----------------------------------------------------------------------------*
LOCAL nValMerc:= nDesp:= nDesp_US:= nFob:= nFrete:= nSeguro:= nCIF:=0
LOCAL nValMerUS:= 0,nRec, nRateioFrete:=0
LOCAL nSomaCIF_NCM:=DITRANS(nSomaNoCIF*(Work2->WKFOBR_ORI/MDI_FOB_R))

Work1->(DBSETORDER(1))
IF !Work1->(DbSeek(Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
   MSGINFO(STR0318,STR0022) //"Existe Desbalanceamento no Banco de Dados, por favor saia do Sistema."###"Atenção"
   RETURN .F.
ENDIF
nRec:=Work1->(RECNO())

DO WHILE !Work1->(EOF()) .AND.;
         (Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM) ==;
         (Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM)

  IF !lAlteracao
     Work1->WKRATEIO:=Work1->WKFOBR_ORI/Work2->WKFOBR_ORI
     IF lRatFreQTDE 
        Work1->WKRATQTDE:=Work1->WKQTDE/Work2->WKQTDE
     ELSEIF !lRatFretePorFOB
        Work1->WKRATPESO:=Work1->WKPESOL/Work2->WKPESOL
     ENDIF
     IF lLerFOBPuro//so p/ NF impostos
        Work1->WKRATEIO:=Work1->WKPRECO_F/Work2->WKPRECO_F
     ENDIF
  ENDIF
 
  nRateioFrete:=Work1->WKRATEIO
  IF lRatFreQTDE        
     nRateioFrete:=Work1->WKRATQTDE
  ELSEIF !lRatFretePorFOB
     nRateioFrete:=Work1->WKRATPESO
  ENDIF
 
  IF cTipoNF # NFE_DESPESAS
     Work1->WKSEGURO  := DITrans(Work2->WKSEGURO * Work1->WKRATEIO ,2)  
     Work1->WKFRETE   := DITrans(Work2->WKFRETE  * nRateioFrete    ,2)

     IF !(lAlteracao .AND. cTipoNF == NFE_FRETE)
        Work1->WKCIF  := DITrans(Work1->WKFOB_R+Work1->WKFRETE+Work1->WKSEGURO,2)
        Work1->WKCIF  := DITRANS(Work1->WKCIF + (nSomaCIF_NCM*Work1->WKRATEIO),2)
     ENDIF   

     IF cTipoNF == NFE_FRETE
        Work1->WKVALMERC := Work1->WKFRETE
     ELSEIF cTipoNF == NFE_SEGURO
        Work1->WKVALMERC := Work1->WKSEGURO
     ELSE
        Work1->WKVALMERC := Work1->WKCIF
     ENDIF
  ELSE
     Work1->WKVALMERC:= DITrans(Work2->WKOUTRDESP * Work1->WKRATEIO,2)
     IF lTemSelo
        Work1->WKVALMERC += Work1->WKVLR_SELO
     ENDIF        
  ENDIF

  IF !cTipoNF $ NFE_PRIMEIRA
     Work1->WKOUT_DESP:= DITrans(Work2->WKOUTRDESP * Work1->WKRATEIO ,2)
     Work1->WKOUT_D_US:= DITrans(Work2->WKOUTRD_US * Work1->WKRATEIO ,2)
     IF lTemSelo
        Work1->WKOUT_DESP+= Work1->WKVLR_SELO
        Work2->WKOUTRDESP+= Work1->WKVLR_SELO
     ENDIF        
  ENDIF

  IF cTipoNF = CUSTO_REAL
     Work1->WKVALMERC += Work1->WKOUT_DESP
  ENDIF

  IF EMPTY(Work1->WKVALMERUS) .OR. lAlteracao
     Work1->WKVALMERUS:=Work1->WKVALMERC / SW6->W6_TX_US_D
  ENDIF
  Work1->WKPRUNI :=Work1->WKVALMERC / Work1->WKQTDE

  IF cTipoNF $ NFE_FRE_SEG
     Work1->WKFOB     := 0
     Work1->WKFOB_R   := 0
     Work1->WKCIF     := 0
     Work1->WKFRETE   := 0
     Work1->WKSEGURO  := 0
  ELSEIF cTipoNF = NFE_FOB
     Work1->WKCIF     := 0
  ENDIF

  IF cTipoNF # NFE_DESPESAS
     nFob    += Work1->WKFOB_R
     nFrete  += Work1->WKFRETE
     nSeguro += Work1->WKSEGURO
     nCIF    += Work1->WKCIF
  ENDIF
  IF !cTipoNF $ NFE_PRIMEIRA
     nDesp    += Work1->WKOUT_DESP
     nDesp_US += Work1->WKOUT_D_US
  ENDIF

  nValMerc +=Work1->WKVALMERC
  nValMerUS+=Work1->WKVALMERUS
  nValTotMerUS+=Work1->WKVALMERUS

  IF Work1->WKVALMERC > nMaiorWK1
     nMaiorWK1:= Work1->WKVALMERC
     nRecnowk1:= Work1->(RECNO())
     nRec := Work1->(RECNO())
  ENDIF

  
  Work1->(DBSKIP())

ENDDO

Work1->(DBGOTO(nRec)) // posiciona no item de maior CIF
// acerta diferenca entre os calculos `a nivel de item e de nbm
DO CASE
	CASE cTipoNF = NFE_FOB
		nTotMerUS:=Work2->WKFOB_R / SW6->W6_TX_US_D
		
	CASE cTipoNF = NFE_FRETE
		nTotMerUS:=Work2->WKFRETE / SW6->W6_TX_US_D
		IF nValMerc # Work2->WKFRETE
			Work1->WKVALMERC += DITrans(Work2->WKFRETE - nValMerc,2)
            Work1->WKVALMERUS:= Work1->WKVALMERC / SW6->W6_TX_US_D
            Work1->WKPRUNI   := Work1->WKVALMERC / Work1->WKQTDE
		ENDIF
		
	CASE cTipoNF = NFE_SEGURO
		nTotMerUS:=Work2->WKSEGURO / SW6->W6_TX_US_D
		IF nValMerc # Work2->WKSEGURO
			Work1->WKVALMERC += DITrans(Work2->WKSEGURO - nValMerc,2)
            Work1->WKVALMERUS:= Work1->WKVALMERC / SW6->W6_TX_US_D
            Work1->WKPRUNI   := Work1->WKVALMERC / Work1->WKQTDE
		ENDIF
		
	CASE cTipoNF = NFE_IMPOSTOS
		nTotMerUS:=Work2->WKCIF / SW6->W6_TX_US_D
		IF nValMerc # Work2->WKCIF
			Work1->WKVALMERC += DITrans(Work2->WKCIF - nValMerc)
            Work1->WKVALMERUS:= Work1->WKVALMERC / SW6->W6_TX_US_D
            Work1->WKPRUNI   := Work1->WKVALMERC / Work1->WKQTDE
		ENDIF
		IF nDesp # Work2->WKOUTRDESP
			Work1->WKOUT_DESP += DITrans(Work2->WKOUTRDESP - nDesp)
		ENDIF
		IF nDesp_US # Work2->WKOUTRD_US
			Work1->WKOUT_D_US += DITrans(Work2->WKOUTRD_US - nDesp_US)
		ENDIF
		
	CASE cTipoNF = NFE_DESPESAS
		nTotMerUS:=Work2->WKOUTRDESP / SW6->W6_TX_US_D
		IF nValMerc # Work2->WKOUTRDESP
			Work1->WKVALMERC += DITrans(Work2->WKOUTRDESP - nValMerc)
            Work1->WKVALMERUS:= Work1->WKVALMERC / SW6->W6_TX_US_D
            Work1->WKPRUNI   := Work1->WKVALMERC / Work1->WKQTDE
		ENDIF
		IF nDesp # Work2->WKOUTRDESP
			Work1->WKOUT_DESP += DITrans(Work2->WKOUTRDESP - nDesp)
		ENDIF
		IF nDesp_US # Work2->WKOUTRD_US
			Work1->WKOUT_D_US += DITrans(Work2->WKOUTRD_US - nDesp_US)
		ENDIF
		
	CASE cTipoNF = NFE_CIF
		nTotMerUS:=Work2->WKCIF / SW6->W6_TX_US_D
		IF nValMerc # Work2->WKCIF
			Work1->WKVALMERC += DITrans(Work2->WKCIF - nValMerc)
            Work1->WKVALMERUS:= Work1->WKVALMERC / SW6->W6_TX_US_D
            Work1->WKPRUNI   := Work1->WKVALMERC / Work1->WKQTDE
		ENDIF

	CASE cTipoNF = CUSTO_REAL
		nTotMerUS:=(Work2->WKOUTRDESP + Work2->WKCIF)  / SW6->W6_TX_US_D
		IF nValMerc # (Work2->WKOUTRDESP + Work2->WKCIF)
			Work1->WKVALMERC += DITrans((Work2->WKOUTRDESP + Work2->WKCIF) - nValMerc)
            Work1->WKVALMERUS:= Work1->WKVALMERC / SW6->W6_TX_US_D
            Work1->WKPRUNI   := Work1->WKVALMERC / Work1->WKQTDE
		ENDIF
		
ENDCASE

IF nTotMerUS # nValMerUS
   Work1->WKVALMERUS+=nTotMerUS - nValMerUS
   nValTotMerUS     +=nTotMerUS - nValMerUS
ENDIF

IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_FOB .OR. cTipoNF = NFE_CIF
   IF nFob # Work2->WKFOB_R
      Work1->WKFOB_R   += DITrans(Work2->WKFOB_R-nFob,2)
   ENDIF
   IF nCIF # Work2->WKCIF
      Work1->WKCIF    += DITrans(Work2->WKCIF-nCIF,2)
   ENDIF
   IF nFrete # Work2->WKFRETE
      Work1->WKFRETE += DITrans(Work2->WKFRETE-nFrete,2)
   ENDIF
   IF nSeguro # Work2->WKSEGURO
      Work1->WKSEGURO += DITrans(Work2->WKSEGURO-nSeguro,2)
   ENDIF
ENDIF

RETURN
*----------------------------------------------------------------------------
FUNCTION DI156FreSegCIF(nFlag)
*----------------------------------------------------------------------------
LOCAL nFOBRateio  :=Work2->WKFOB_R/MDI_FOB_R
LOCAL nRateioFrete
IF lLerFOBPuro//so p/ NF impostos
   nFOBRateio:=Work2->WKPRECO_F/nTotalPuro
ENDIF
nRateioFrete:=nFOBRateio
IF lRatFreQTDE        
   nRateioFrete:=Work2->WKQTDE /MDI_QTDE
ELSEIF !lRatFretePorFOB
   nRateioFrete:=Work2->WKPESOL/MDI_PESO
ENDIF

IF nFlag = "1"
   IF !cTipoNF $ NFE_FOB_SEG
      Work2->WKFRETE := DITrans(MDI_FRET_MOE*nRateioFrete*SW6->W6_TX_FRETE,2)
   ENDIF
   IF !cTipoNF $ NFE_FRE_FOB
      Work2->WKSEGURO:= DITRANS(MDI_SEGURO * nFOBRateio,2)
   ENDIF
   RETURN .F.
ENDIF

IF nFlag = "3" 
   Work2->WKFRETE := DITrans(MDI_FRET_MOE*nRateioFrete*SW6->W6_TX_FRETE,2)
   RETURN .F.
ENDIF

Work2->WKCIF:= DITrans(Work2->WKFOB_R + Work2->WKFRETE + Work2->WKSEGURO,2)
Work2->WKCIF:= DITRANS(Work2->WKCIF+(nSomaNoCIF * nFOBRateio),2)

RETURN .F.

*-----------------------------------------------*
STATIC FUNCTION DI156Altera()
*-----------------------------------------------*
LOCAL nOpcA:=0, nPesol:=Work2->WKPESOL, nRecord:=1
LOCAL nFatorFrete:= 0,nPesoTotal:=0
LOCAL cConfirma:=OemToAnsi(STR0141) //"Confirma a Altera‡Æo ?"
LOCAL cTit:=OemToAnsi(STR0142) //"Confirma‡Æo"

IF EasyEntryPoint('EICDI156')
   lAlterou:=.f.
   Execblock('EICDI156',.F.,.F.,'ALTERA_IMPOSTOS')
   If lAlterou
      RETURN
   ENDIF
ENDIF

DEFINE MSDIALOG oDlgAlt TITLE STR0320 FROM 0,0 TO 5,35 Of oMainWnd //"Altera‡Æo de Impostos" //"Modificacion de Peso"

  @1.4,0.8 SAY STR0144 //"Peso"
  @1.4,6.0 MSGET nPesol  PICTURE "@E 999,999,999.99999999" VALID nPesol > 0  SIZE 70,7

ACTIVATE MSDIALOG oDlgAlt ON INIT;
         EnchoiceBar(oDlgAlt,;
                     {|| If(nPesol > 0 .And. MsgYesNo(cConfirma,cTit),;
                            (nOpcA:=1,oDlgAlt:End()),)},;
                     {|| nOpcA:=0, oDlgAlt:End()}) CENTERED

If nOpcA = 0 .OR. Work2->WKPESOL == nPesol
   Return
Endif

lAlterouPeso:=.T.

MDI_PESO      -= Work2->WKPESOL
MDI_PESO      += nPesol
nFatorFrete   := nPesol / Work2->WKPESOL
Work2->WKPESOL:= nPesol
nRecord       := Work2->(RECNO())

Work1->(DBSETORDER(1))
Work1->(DBSEEK(Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
DO WHILE  ! Work1->(EOF()) .AND. ;
       Work1->WK_CFO     ==  Work2->WK_CFO      .AND. ;
       Work1->WK_OPERACA ==  Work2->WK_OPERACA  .AND. ;
       Work1->WKTEC      ==  Work2->WKTEC       .AND. ;
       Work1->WKEX_NCM   ==  Work2->WKEX_NCM    .AND. ;
       Work1->WKEX_NBM   ==  Work2->WKEX_NBM

  Work1->WKPESOL := Work1->WKPESOL * nFatorFrete
  nPesoTotal     += Work1->WKPESOL
  Work1->(DBSKIP())

ENDDO
Work1->(DBSEEK(Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
IF Work2->WKPESOL # nPesoTotal
   Work1->WKPESOL += Work2->WKPESOL - nPesoTotal
ENDIF
Work2->(DBGOTOP())

Processa({|| DI156Recalc()},STR0147) //"Pesquisando NBMs..."

Work2->(DBGOTO(nRecord))

IF oMark # NIL
   oMark:oBrowse:Refresh()
ENDIF    

IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
   Processa({|| DI156GerImpostos(.F.)},STR0321) //"Generando Impuestos"
ENDIF

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'ALTEROU_IMPOSTOS'),)

RETURN .T.
*----------------------------------------------------------------------------
FUNCTION DI156Recalc()
*----------------------------------------------------------------------------
LOCAL nMaior:=0,nCIF:=0
LOCAL nRecnoWK2:=Work2->(RECNO()), nFRETE:=0
LOCAL nValFOBUS:=0
PRIVATE nValTotMerUS:=0

ProcRegua(Work2->(LASTREC())*2)
Work2->(DBGOTOP())
DO WHILE ! Work2->(EOF())
   IncProc(STR0322) //"Recalculando Valores"
   DI156FreSegCIF("3")
   nFRETE += Work2->WKFRETE
   IF cTipoNF = NFE_FRETE
      IF Work2->WKFRETE > nMaior
         nMaior:=Work2->WKFRETE
         nRecnoWK2:=Work2->(RECNO())
      ENDIF  
      Work2->WKFOB_R  := Work2->WKFRETE
      Work2->WKFOB_US := Work2->WKFOB_R / SW6->W6_TX_US_D
   ELSEIF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      IF Work2->WKCIF > nMaior
         nMaior:=Work2->WKCIF
         nRecnoWK2:=Work2->(RECNO())
      ENDIF  
      DI156FreSegCIF("2")
      nCIF += Work2->WKCIF
      Work2->WKFOB_US := Work2->WKCIF / SW6->W6_TX_US_D
   ENDIF  
   Work2->(DBSKIP())
ENDDO
Work2->(DBGOTO(nRecnoWK2))

IF MDI_FRETE # nFRETE
   Work2->WKFRETE += DiTrans(MDI_FRETE-nFRETE,2)
ENDIF
IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL .AND. MDI_CIF # nCIF
   Work2->WKCIF   += DITRANS(MDI_CIF-nCIF)
ENDIF

Work1->(DBGOTOP())
nRecnoWK1:=Work1->(RECNO())
nMaiorWK1:=0
Work2->(DBGOTOP())
DO WHILE ! Work2->(EOF())
   IncProc(STR0322) //"Recalculando Valores"
   DI156Rateio(.T.)
   nValFOBUS+=Work2->WKFOB_US
   Work2->(DBSKIP())
ENDDO

Work2->(DBGOTO(nRecnoWK2))
Work1->(DBGOTO(nRecnoWK1))
DO CASE
   CASE cTipoNF = NFE_FRETE .AND. cMoeDolar == SW6->W6_FREMOED
        IF MDI_FRET_MOE # nValTotMerUS
           Work1->WKVALMERUS+=MDI_FRET_MOE - nValTotMerUS
        ENDIF
        IF MDI_FRET_MOE # nValFOBUS
           Work2->WKFOB_US  +=MDI_FRET_MOE - nValFOBUS
        ENDIF

   CASE (cTipoNF = NFE_IMPOSTOS     .OR. ;
         cTipoNF = NFE_CIF)         .AND.;
        cMoeDolar == cMoedaProc .AND.;
        cMoeDolar == SW6->W6_FREMOED.AND.;
        cMoeDolar == SW6->W6_SEGMOEDA
        cCifUS:=(MDI_FOB+MDI_FRET_MOE+SW6->W6_VL_USSE)
        IF cCifUS # nValTotMerUS
           Work1->WKVALMERUS+=cCifUS - nValTotMerUS
        ENDIF
        IF cCifUS # nValFOBUS
           Work2->WKFOB_US  +=cCifUS - nValFOBUS
        ENDIF
ENDCASE

RETURN .T.
*-----------------------------------------------*
STATIC Function DI156GeraDespesas()
*-----------------------------------------------*
LOCAL cFilSF4 := xFilial("SF4")
LOCAL C,J, N

SF4->(DBSETORDER(1))

ProcRegua(LEN(aRecWork1))
aCampos:={}

AADD(aCampos,"WKPESOL")  ; AADD(aCampos,"WKRECNO")  ; AADD(aCampos,"WKQTDE")
AADD(aCampos,"WK_REG")   ; AADD(aCampos,"WKPRECO")  ; AADD(aCampos,"WKRATEIO")
AADD(aCampos,"WKRATPESO"); AADD(aCampos,"WKRATQTDE"); AADD(aCampos,"WKRATFOB")
AADD(aCampos,"WKPRECO_F"); AADD(aCampos,"WKFOB_R")  ; AADD(aCampos,"WKFOBR_ORI")

DBSELECTAREA("Work1")
FOR C := 1 TO FCOUNT()
    IF VALTYPE(FIELDGET(C)) $ "CDL"
       AADD(aCampos,FIELD(C))
    ENDIF
NEXT

aDados:=ARRAY(LEN(aCampos))

FOR N := 1 TO LEN(aRecWork1)

    Work1->(dbGoTo(aRecWork1[N]))
    
    //JVR - 21/01/10 - Incluido validação FieldPos
    If SWN->(FieldPos("WN_ITEMNF")) > 0 
       nItemNf := Val(Work1->WK_ITEMNF)
    EndIf
    
    IncProc()
    IF Work3->(DBSEEK(STRZERO(aRecWork1[N],nTamRec)))

       Work1->WKVALMERC :=Work3->WKVALOR                  //Preco Total
       Work1->WKPRUNI   :=Work1->WKVALMERC / Work1->WKQTDE//Preco Unitario
       Work1->WK_DT_NFE :=Work3->WK_DT_NFC
       Work1->WKDESPESA :=Work3->WKDESPESA+'-'+Work3->WKDESCR
       Work1->WKOUT_DESP:=Work3->WKVALOR                  //Preco Total
       Work1->WKOUT_D_US:=Work3->WKVALOR_US               //Preco Total em Dolar
       Work1->WKFORN    :=Work3->WKFORN
       Work1->WKLOJA    :=Work3->WKLOJA
       Work1->WKVALMERUS:=Work1->WKVALMERC / SW6->W6_TX_US_D
       Work1->WKRECNOWK3:=Work3->(RECNO())
       IF lWN_DESPSUB//AWR 21/5/2003
          IF SF4->(dbSeek(cFilSF4+Work3->WKTES)) .AND. SF4->F4_ESTOQUE $ cNao
             Work1->WKDESPSUB := Work3->WKVALOR
          ENDIF
       ENDIF
       IF !lNFAutomatica
          Work1->WK_NFE    :=Work3->WK_NF_COMP
          IF SWD->(FieldPos("WD_SE_DOC")) > 0 // EOS
             Work1->WK_SE_NFE := Work3->WK_SE_NFC
          ENDIF
          Work1->WK_NFE_AUX:=Work3->WK_NF_COMP
          Work1->WK_DT_NFE :=Work3->WKDT_EMIS
       ENDIF
       IF EMPTY(Work1->WK_NFE)
          Work1->WKFLAG :=cMarca
       ELSE
          Work1->WKFLAG :=''
       ENDIF
       Work3->(DBSKIP())

       DO WHILE !Work3->(EOF()) .AND. STRZERO(aRecWork1[N],nTamRec) == Work3->WKRECNO
   
          For j := 1 To LEN(aCampos)
              aDados[J]:=Work1->(FieldGet(FieldPos(aCampos[j])))
          Next

          Work1->(DBAPPEND())

          For j := 1 To LEN(aCampos)
              Work1->(FieldPut(FieldPos(aCampos[j]),aDados[J]))
          Next

          Work1->WKVALMERC :=Work3->WKVALOR//Preco Total
          Work1->WKPRUNI   :=Work1->WKVALMERC / Work1->WKQTDE//Preco Unitario
          Work1->WK_DT_NFE :=Work3->WK_DT_NFC
          Work1->WKDESPESA :=Work3->WKDESPESA+'-'+Work3->WKDESCR
          Work1->WKOUT_DESP:=Work3->WKVALOR//Preco Total
          Work1->WKOUT_D_US:=Work3->WKVALOR_US//Preco Total em Dolar
          Work1->WKFORN    :=Work3->WKFORN
          Work1->WKLOJA    :=Work3->WKLOJA
          Work1->WKVALMERUS:=Work1->WKVALMERC / SW6->W6_TX_US_D
          Work1->WKRECNOWK3:=Work3->(RECNO())
          IF lWN_DESPSUB//AWR 21/5/2003
             IF SF4->(dbSeek(cFilSF4+Work3->WKTES)) .AND. SF4->F4_ESTOQUE $ cNao
                Work1->WKDESPSUB := Work3->WKVALOR
             ENDIF
          ENDIF
          IF !lNFAutomatica
             Work1->WK_NFE    :=Work3->WK_NF_COMP
             IF SWD->(FieldPos("WD_SE_DOC")) > 0 // EOS
                Work1->WK_SE_NFE := Work3->WK_SE_NFC
             ENDIF
             Work1->WK_NFE_AUX:=Work3->WK_NF_COMP
             Work1->WK_DT_NFE :=Work3->WKDT_EMIS
          ENDIF
          IF EMPTY(Work1->WK_NFE)
             Work1->WKFLAG :=cMarca
          ELSE
             Work1->WKFLAG :=''
          ENDIF
           
          If SWN->(FieldPos("WN_ITEMNF")) > 0 
             Work1->WK_ITEMNF := STRZERO(nItemNf,Len(SWN->WN_ITEMNF))
          EndIf

          Work3->(DBSKIP())
   
       EndDo
   
    Endif

NEXT

RETURN .F.
*-----------------------------------------------*
STATIC Function DI156GerImpostos(lDespesas)
*-----------------------------------------------*
LOCAL lEof:=.F. ,aDespBase:={},aDespGera:={},aTabAll:={},aTab1:={},aTabNCM:={}
LOCAL cFilSA2:=xFilial("SA2"), W, I, A, nDesp
LOCAL cImpNFDesp := "EIV|EDI|ETE|EIG|EIB|EIA|EFC|PVG" // - BHF
Local lGera := .F.
aTotais:={};nTotImpostos:=0    
ProcRegua(Work1->(LastRec()))
SA2->(DBSETORDER(1))
SYB->(DBSETORDER(1))
SYD->(DBSETORDER(1))           
SWD->(DBSETORDER(1))
Work2->(DBSETORDER(1))
WorkTES->(AvZap())
Work1->(DBGOTOP())
DO WHILE Work1->(!EOF())
   IncProc(STR0323+' '+Work1->WKCOD_I) //"Item: "
   IF !lDespesas
      IF !EMPTY(Work1->WKTES)  //TRP-10/01/08
         lGera:= .T.
      ENDIF
   ELSE                                             
      lGera := .F.      
      cCodTES := ""
      IF !EMPTY(Work1->WKDESPESA)
         IF SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB+LEFT(Work1->WKDESPESA, LEN(SWD->WD_DESPESA) ))) .AND.;
            SWD->(FieldPos("WD_TES")) > 0 .AND. !EMPTY(SWD->WD_TES)
            lGera   := .T.
            cCodTES := SWD->WD_TES
         ELSEIF SYB->(DbSeek(xFilial("SYB")+LEFT(Work1->WKDESPESA,LEN(SWD->WD_DESPESA)))) .AND. ;
            !EMPTY(SYB->YB_TES)
            lGera := .T.
            cCodTES := SYB->YB_TES
         ENDIF
      ENDIF
   ENDIF
   IF cTipoNF == NFE_DESPESAS
      IF Work2->(DBSEEK(Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
         Work2->WKFOB_R += Work1->WKVALMERC
         Work2->WKFOB_US:= Work2->WKFOB_R / SW6->W6_TX_US_D
      ENDIF
   ENDIF
   IF !lDespesas .OR. lGera
      aDespBase:={}        
      aDespGera:={}
      aTabAll  :={}
      Work1->(DbSkip())
      lEof :=Work1->(EOF())
      Work1->(DbSkip(-1))
      IF !lDespesas
         IF Work2->(DBSEEK(Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM)) .AND.;
            ASCAN(aTabNCM,Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM) = 0
            AADD(aTabNCM,Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM)
            Work2->WKOUTRDESP:= 0
            Work2->WKOUTRD_US:= 0
         ENDIF
         Work1->WKOUT_DESP:= 0
         Work1->WKOUT_D_US:= 0
         IF Work3->(DBSEEK(STRZERO(Work1->(RECNO()),nTamRec)))
            DO WHILE !Work3->(EOF()) .AND. STRZERO(Work1->(RECNO()),nTamRec) == Work3->WKRECNO
               IF SYB->(DbSeek(xFilial("SYB")+Work3->WKDESPESA))

                  IF !EMPTY(SYB->YB_IMPINS)
                     AADD(aDespBase,{Work3->WKDESPESA,;
                                     Work3->WKVALOR,;
                                     SYB->YB_IMPINS})
                  ENDIF                                                                                 
                  IF !EMPTY(Work3->WKFLAG)    
                     IF !EMPTY(Work3->WKTES)  //EOS
                        AADD(aDespGera,{Work3->WKDESPESA,;
                                        Work3->WKVALOR,;
                                        Work3->WKTES  ,;
                                        Work3->WKFORN ,;
                                        Work3->WKLOJA })
                                   
                     ELSEIF !EMPTY(SYB->YB_TES)
                        AADD(aDespGera,{Work3->WKDESPESA,;
                                        Work3->WKVALOR,;
                                        SYB->YB_TES   ,;
                                        Work3->WKFORN ,;
                                        Work3->WKLOJA })
                     ENDIF   
                  ENDIF                                                                                 
               ENDIF                                                                                 

               IF !EMPTY(Work3->WKFLAG)
                  Work1->WKOUT_DESP+= Work3->WKVALOR
                  Work1->WKOUT_D_US:= Work1->WKOUT_DESP / SW6->W6_TX_US_D
                  Work2->WKOUTRDESP+= Work3->WKVALOR
                  Work2->WKOUTRD_US:= Work2->WKOUTRDESP / SW6->W6_TX_US_D
               ENDIF
               Work3->(DBSKIP())
            ENDDO
         ENDIF
         FOR W := 1 TO LEN(aDespGera)
             SA2->(DBSEEK(cFilSA2+aDespGera[W,4]+aDespGera[W,5]))
             aTab1:=CalcImpGer(aDespGera[W,3],,,aDespGera[W,2],,,,{},,MDI_OUTR,lEof)
             AADD(aTab1,"D"+aDespGera[W,1])  // AWR - p/ identificar que o imposto se refere a despesa 
             AADD(aTabAll,aTab1)
         NEXT
         IF lGera//Quando eh impostos decide aqui se gera
            IF cTipoNF == NFE_IMPOSTOS
               SA2->(DBSEEK(cFilSA2+Work1->WKFORNITEM+Work1->WKLOJAITEM))
               //Verificar se na NCM se o imposto deve ser calculado pelo valor total da Mercadoria + despesa (WKCIF) ou pelo valor liquido
               //somente valor do mercadoria sem despesas (WKFOB_R).
               
               //JVR - 24/05/10 - rateio por item
               aAcresDed := DI156VAl_AD(SW6->W6_HAWB, .T., "WORK1")
               nAcresDed := aAcresDed[3] - aAcresDed[4]//Acrescimo - Deduçao
               
               SYD->(DbSetOrder(1))
               If SYD->(FIELDPOS("YD_FOBEXEN")) # 0 .AND. SYD->(DbSeek(xFilial("SYD")+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM)) .AND. SYD->YD_FOBEXEN == "1"
               	  aTab1:=CalcImpGer(Work1->WKTES,,,Work1->WKVALMERC-Work1->WKFOB_R+nAcresDed,,,,aDespBase,Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM,MDI_CIF,lEof)    //TRP-10/01/08 //JVR - 24/05/10 - nAcresDed       
               Else
               	  aTab1:=CalcImpGer(Work1->WKTES,,,Work1->WKVALMERC+nAcresDed,,,,aDespBase,Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM,MDI_CIF,lEof)//JVR - 24/05/10 - nAcresDed       
               EndIf		
            ELSE//Custo
               SA2->(DBSEEK(cFilSA2+Work1->WKFORN+Work1->WKLOJA))
               aTab1:=CalcImpGer(SYD->YD_TES,,,Work1->WKCIF    ,,,,aDespBase,Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM,MDI_CIF,lEof)
            ENDIF
            AADD(aTab1,"P")  // AWR - p/ identificar que o imposto se refere ao produto 
            AADD(aTabAll,aTab1)
         ENDIF
      ELSE//Despesas
         SA2->(DBSEEK(cFilSA2+Work1->WKFORN+Work1->WKLOJA))
         aTab1:=CalcImpGer(cCodTES,,,Work1->WKVALMERC,,,,{},Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM,MDI_OUTR,lEof)
         AADD(aTab1,"D"+LEFT(Work1->WKDESPESA,LEN(SWD->WD_DESPESA)))  // AWR - p/ identificar que o imposto se refere a despesa 
         AADD(aTabAll,aTab1)
      ENDIF         
      Work1->WKIMPOSTOS:=0//Eh preciso Zerar por causa da alteracao do peso
      SFB->(DBSETORDER(1))
      FOR A := 1 TO LEN(aTabAll)
         aTab:=aTabAll[A]
         IF !EMPTY(aTab)
            FOR I := 1 TO LEN(aTab[6])
               //IF lCurrier .AND. aTab[LEN(aTab)] = "P" .AND. !(aTab[6,I,1] $ "EIV","EDI","ETE") //Lucas, 22/08/07
               //   LOOP                                                                          //Na Arg e Chi se calcula impostos para Currier.
               //ENDIF
               IF aTab[LEN(aTab)] = "P" .and. ! aTab[6,I,1] $ cImpNFDesp //Lucas, 06/09/07
                  LOOP
               ENDIF
               WorkTES->(DBAPPEND())
               WorkTES->WKRECNO   :=STRZERO(Work1->(RECNO()),6)
               WorkTES->WKITEM    :=Work1->WKCOD_I
               WorkTES->WK_IMP    :=aTab[6,I,1]
               WorkTES->WK_NCM    :=Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM
               SFB->(DBSEEK(xFilial("SFB")+WorkTES->WK_IMP))
               WorkTES->WK_IMPDESC:=LEFT(SFB->FB_DESCR,20)
               WorkTES->WKPERC    :=aTab[6,I,2]
               WorkTES->WKBASE    :=aTab[6,I,3]
               WorkTES->WKBASEUS  :=WorkTES->WKBASE / SW6->W6_TX_US_D 
               WorkTES->WKVALOR   :=aTab[6,I,4]
               WorkTES->WKVALORUS :=WorkTES->WKVALOR / SW6->W6_TX_US_D
               WorkTES->WKVLR_CPO :=SUBSTR(aTab[6,I,6],3)
               WorkTES->WKBAS_CPO :=SUBSTR(aTab[6,I,7],3)
               WorkTES->WKALI_CPO :="_ALQIMP"+RIGHT(ALLTRIM(aTab[6,I,7]),1)
               WorkTES->WKORIGEM  := IF(aTab[LEN(aTab)]="P","ADUANA",RIGHT(aTab[LEN(aTab)],3))
               WorkTES->WKID_IMP  := aTab[LEN(aTab)]
               IF (nPos:=ASCAN(aTotais,{|aDesp|aDesp[1]==WorkTES->WK_IMP.AND.aDesp[4]==WorkTES->WK_NCM} )) == 0
                  AADD(aTotais,{WorkTES->WK_IMP,;
                                DITRANS(WorkTES->WKVALOR),;
                                DITRANS(WorkTES->WKBASE),;
                                WorkTES->WK_NCM,} )
               ELSE
                  aTotais[nPos,2]+=DITRANS(WorkTES->WKVALOR  )//Valor
                  aTotais[nPos,3]+=DITRANS(WorkTES->WKBASE   )//Base
               ENDIF
               Work1->WKIMPOSTOS +=DITRANS(WorkTES->WKVALOR)
            NEXT I
         ENDIF
      NEXT A
      nTotImpostos+=Work1->WKIMPOSTOS
   ENDIF

   Work1->(DBSKIP())
ENDDO
ProcRegua(LEN(aTotais))
SFB->(DBSETORDER(1))
FOR I := 1 TO LEN(aTotais)
   IncProc()
   //TOTAL GERAL
   SFB->(DBSEEK(xFilial("SFB")+aTotais[I,1]))
   IF !WorkTES->(DBSEEK( "TOTAIS"+SPACE(LEN(WorkTES->WK_NCM))+aTotais[I,1] ))
      WorkTES->(DBAPPEND())
      WorkTES->WKRECNO   :="TOTAIS"
      WorkTES->WK_IMP    :=aTotais[I,1]
      WorkTES->WK_IMPDESC:=LEFT(SFB->FB_DESCR,20)
   ENDIF
   WorkTES->WKVALOR   +=aTotais[I,2]
   WorkTES->WKBASE    +=aTotais[I,3]
   WorkTES->WKVALORUS +=aTotais[I,2] / SW6->W6_TX_US_D
   WorkTES->WKBASEUS  +=aTotais[I,3] / SW6->W6_TX_US_D
   //TOTAL POR NCM
   WorkTES->(DBAPPEND())
   WorkTES->WKRECNO   :="TOTAIS"
   WorkTES->WK_IMP    :=aTotais[I,1]
   WorkTES->WKVALOR   :=aTotais[I,2]
   WorkTES->WKBASE    :=aTotais[I,3]
   WorkTES->WK_NCM    :=aTotais[I,4]
   WorkTES->WKVALORUS +=aTotais[I,2] / SW6->W6_TX_US_D
   WorkTES->WKBASEUS  +=aTotais[I,3] / SW6->W6_TX_US_D
   WorkTES->WK_IMPDESC:=LEFT(SFB->FB_DESCR,20)
NEXT

IF lGrvDespSD1 .AND. ( cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS )
   FOR nDesp := 1 to LEN(aDespesa)
      Work4->(DBGOTO(aDespesa[nDesp,5]))
      IF EMPTY(Work4->WKFLAG)
         LOOP
      ENDIF

      SWD->(DBGOTO(aDespesa[nDesp,4]))
      SYB->(DbSeek(xFilial()+aDespesa[nDesp,1]))
      SB1->(DbSeek(xFilial()+SYB->YB_COD_I))

      SA2->(DBSEEK(cFilSA2+Work4->WKFORN+Work4->WKLOJA))
      
      aTab1:=CalcImpGer(Work4->WKTES,,,Work4->WKVALOR,,,,{}, SB1->(B1_POSIPI + B1_EX_NCM + B1_EX_NBM),MDI_OUTR,.F.)
      AADD( aDespesa[nDesp], aTab1[6] )
   NEXT
ENDIF

Work1->(DBGOTOP())
Return .T.
*---------------------------------------------*
Function DI156GerNF(lGerouNFE)
*---------------------------------------------*
LOCAL nRec1:=Work1->(RecNo()), Imp, R, x
LOCAL nRec2:=Work2->(RecNo())
LOCAL cFilSWD :=xFILIAL('SWD')
LOCAL nQtdeNFs:=0, nVlTotNFs:=0, nDespTotNFCs:=0
LOCAL cTec,cExNCM,cExNBM,nFob,nDespUS,nFob_R,nCIF_Moe
LOCAL aImpostos
LOCAL nY:=0, nPosSD1:=0
LOCAL nPosicao:=0  //TRP-16/07/08
Local aOrdWK1 := {}                 
Local nPos := 0
Local cTpNF := If(cTipoNF == "A","C","N")
Local nSeqNf:= 0
Local cNFSer := ""

PRIVATE aItensNF:= {} //TRP-16/07/08

PRIVATE cOperacao,cCFO, lSair:=.F.
PRIVATE cNumero, cSerie, nItem:= 0
PRIVATE cChvQuebra:= ""
PRIVATE nWK1Ordem :=5 //Variavel usada para trocar a ordem da Work no Rdmake
PRIVATE nWK2Ordem :=1 //Variavel usada para trocar a ordem da Work no Rdmake
PRIVATE cForn:="", aValores:={}
Private cInvoice:=""
PRIVATE aRecnosSF1:={}
Private aItemNf := {}
//Controle para a numeração dos itens (WN_LINHA) POR NOTA
Private aNFLin := {}
Private nNFLin := 0

dDtNFE:=IF(EMPTY(Work1->WK_DT_NFE),dDataBase,Work1->WK_DT_NFE)

SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN+EICRetLoja("SW7", "W7_FORLOJ")))//FDR - 21/09/12 - Tratamento de Loja

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'IniciaVariavel'),)
IF lSair
   DbSelectArea("Work1")
   Return .T.
ENDIF

IF !lNFAutomatica .AND. cTipoNF # CUSTO_REAL
   Work1->(DBSETORDER(2))
   Work1->(DBGOTOP())
   aNF1:={}
   aNF2:={}
   aNF3:={}

   //CEO - issue TE-9524 - Bloqueia caso ja exista registro na SF1 com a chave F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
   SF1->(DbSetOrder(1))

   DO WHILE !Work1->(EOF())
      //JVR - 27/05/10 - Tratamento para preenchimento da Serie da NF.
      If cTipoNF # NFE_IMPOSTOS .and. Empty(Work1->WK_SE_NFE)
         MsgInfo(STR0373)//"Serie não informada"
         Return .F.
      EndIf      
      
      IF EMPTY(Work1->WK_NFE)
         MSGINFO(STR0324,STR0022) //"Existem facturas no informadas"
         DbSelectArea("Work1")
         Return .T.
      ENDIF

      IF ASCAN(aNF1,{|N| N[1]==Work1->WK_NFE+Work1->WK_SE_NFE .AND. N[2]==Work1->WKFORN} ) == 0
         AADD (aNF1,{ Work1->WK_NFE+Work1->WK_SE_NFE,Work1->WKFORN })
         IF ASCAN(aNF2,{|F| F[1]==aNF1[LEN(aNF1),1] }) == 0
            AADD (aNF2,{ aNF1[LEN(aNF1),1] })
         ELSE
            Help("",1,"AVG0000807")//"Existem Fornecedores com os mesmo numeros de N.F.'s.",0022)
            RETURN .F.
         ENDIF
      ENDIF

      //AADD (aNF3, xFilial("SF1")+Work1->WKINVOICE+Work1->WK_SE_NFE+Work1->WKFORN+Work1->WKLOJA+cTipoNF)

      If !aScan(aNF3, xFilial("SF1")+Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+Work1->WKLOJA+cTpNF)

         If SF1->(DbSeek(xFilial("SF1")+Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+Work1->WKLOJA+cTpNF))

			   MsgInfo(StrTran(StrTran(STR0374, "####", AllTrim(Work1->WK_NFE) + "/ " + AllTrim(Work1->WK_SE_NFE)),; 
                           "$$$$", AllTrim(Work1->WKFORN) + "/ " + AllTrim(Work1->WKLOJA)))

            RETURN .F.
         EndIf

         AADD (aNF3, {xFilial("SF1")+Work1->WKINVOICE+Work1->WK_SE_NFE+Work1->WKFORN+Work1->WKLOJA+cTpNF})

      EndIf

      Work1->(DBSKIP())
   ENDDO
ENDIF

//SVG - 15/07/2010 - Posicionada rotina apos a informação do numero e serie da nota, assim numeração do campo WN_ITEMNF fica correta.
//É realizado um nov loop na Work1 para regravar o campo WN_ITEMNF de
//acordo com a ordem de gravação utilizada na tabela SD1. (Ordenado
//conforme a chave 7 de indice da Work1)      
//Essa ação é necessária, porque a gravação da Work1 não utiliza
//um ordem que contempla os campos da chave 7 da Work1.
If SWN->(FieldPos("WN_ITEMNF")) > 0 
   aOrdWK1 := SaveOrd({"Work1"})
   
   nItemNf := 1
   nSeqNf  := 0
   
   Work1->(DbSetOrder(2))//JVR - 11/06/10
   Work1->(DbGoTop())
   cNFSer := WK_NFE+WK_SE_NFE
   While Work1->(!EOF())

      If (cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS)
            If cNFSer == WK_NFE+WK_SE_NFE
                nPos := aScan(aItemNF,{|X| X[1] == Work1->(WKINVOICE+WKFORN+WKDESPESA)})
            else
                nPos := 0
                aItemNF := {}
            endif
      Else
         nPos := aScan(aItemNF,Work1->(WK_NFE+WK_SE_NFE))
      EndIf

      If nPos > 0
	     If (cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS)
			nItemNf := (++aItemNF[nPos][2])
		 Else
            nItemNf++
		 EndIf
      Else
         nItemNf := 1
         If (cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS)
            aAdd(aItemNF,{Work1->(WKINVOICE+WKFORN+WKDESPESA),nItemNf})
         Else
            aAdd(aItemNF,Work1->(WK_NFE+WK_SE_NFE))//JVR - 11/06/10 - Alterado a chave.
         EndIf
      EndIf
      Work1->WK_ITEMNF := STRZERO(nItemNf,Len(SWN->WN_ITEMNF))
   
      ++nSeqNf
      Work1->WKSEQNF:= STRZERO(nSeqNf, Len(Work1->WKSEQNF))

      cNFSer := WK_NFE+WK_SE_NFE
      Work1->(DbSkip())
   EndDo

   RestOrd(aOrdWK1,.T.)
EndIf

Work1->(DBSETORDER(nWK1Ordem))//5

IF lNFAutomatica .AND. cTipoNF # CUSTO_REAL

   ProcRegua(Work1->(LASTREC()))

   Work1->(DBSETORDER(nWK1Ordem))//5
   Work2->(DBSETORDER(nWK2Ordem))//1
   Work3->(DBSETORDER(1))
   Work1->(DBGOTOP())
   nItem:=0
   cForn:=cCFO:=cOperacao:=""

   DO WHILE !Work1->(EOF())

      IncProc(STR0150) //"Gerando Nota Fiscal"

      IF DI156Quebrou()
         cNumero:=""
         IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'GET_NOTA'),)
                 
         IF EMPTY(cNumero)
            DO WHILE !SX5NumNota(.F.)
            ENDDO
            //NxTSx5Nota(cSerie,.T.)
            NxTSx5Nota(Left(cSerie,SerieNfId("SWN",6,"WN_SERIE")),.T.)
         ENDIF     
      
         nItem:=0
         cForn     := Work1->WKFORN+Work1->WKLOJA
         cCFO      := Work1->WK_CFO
         cOperacao := Work1->WK_OPERACA
         cInvoice  :=Work1->WKINVOICE
      ENDIF
      nItem++

      Work1->WK_NFE   :=cNumero
      Work1->WK_SE_NFE:= SerieNfId(,4,"WN_SERIE",dDtNFE,cMv_ESPEIC,cSerie)//cSerie
      Work1->WK_DT_NFE:=dDtNFE

      //IF Work3->(DBSEEK(Work1->(RECNO())))
      IF Work3->(DBSEEK(STRZERO(Work1->(RECNO()),nTamRec)))
                          
         //DO WHILE !Work3->(EOF()) .AND. Work1->(RECNO()) == Work3->WKRECNO  //ASK 24/09/2007
         DO WHILE !Work3->(EOF()) .AND. STRZERO(Work1->(RECNO()),nTamRec) == Work3->WKRECNO
            Work3->WK_NF_COMP:=cNumero
            Work3->WK_SE_NFC :=cSerie
            Work3->WK_DT_NFC :=dDtNFE

            Work3->(DBSKIP())

         ENDDO

      ENDIF
      
      Work1->(DBSKIP())

   ENDDO

ELSEIF cTipoNF = CUSTO_REAL

   ProcRegua(Work1->(LASTREC()))

   Work2->(DBSETORDER(nWK2Ordem))//1
   Work1->(DBSETORDER(nWK1Ordem))//5
   Work3->(DBSETORDER(1))
   Work1->(DBGOTOP())
   nItem:=EasyGParam("MV_NRCUSTO")
   nItem++
   SetMV("MV_NRCUSTO",nItem)
   cNumero:=STRZERO(nItem,6,0)
   cForn  := Work1->WKFORN+Work1->WKLOJA
   cInvoice:=Work1->WKINVOICE
   
   DO WHILE !Work1->(EOF())

      IncProc(STR0150) //"Gerando Nota Fiscal"

      IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'QUEBRA_CUSTO'),)

      IF cForn # Work1->WKFORN+Work1->WKLOJA
         cForn:=Work1->WKFORN+Work1->WKLOJA
         cInvoice:=Work1->WKINVOICE
         nItem:=GetNewPar("MV_NRCUSTO",nItem)
         nItem++
         SetMV("MV_NRCUSTO",nItem)
         cNumero:=STRZERO(nItem,6,0)
      ENDIF

      Work1->WK_NFE   :=cNumero
      Work1->WK_DT_NFE:=dDtNFE

      //IF Work3->(DBSEEK(Work1->(RECNO())))
      IF Work3->(DBSEEK(STRZERO(Work1->(RECNO()),nTamRec)))

        // DO WHILE !Work3->(EOF()) .AND. Work1->(RECNO()) == Work3->WKRECNO //ASK 24/09/2007
           Do While !Work3->(EOF()) .AND. STRZERO(Work1->(RECNO()),nTamRec) == Work3->WKRECNO

            Work3->WK_NF_COMP:=cNumero
            Work3->WK_DT_NFC :=dDtNFE

            Work3->(DBSKIP())

         ENDDO

      ENDIF

      Work1->(DBSKIP())

   ENDDO


ENDIF

If lMV_EASY_SIM .AND. cTipoNF # CUSTO_REAL .AND. cPaisLoc # "ARG" .AND. cPaisLoc # "CHI" //FDR - 11/10/12
   If MSGYESNO(STR0348,STR0022)//"Utiliza Formulario Proprio?"
      cFormPro   := "S"
   Endif
Endif

ProcRegua((Work1->(LASTREC())*2)+Work4->(LASTREC())+Work3->(LastRec()) )

Work2->(DBSETORDER(1))
Work1->(DBSETORDER(4))
Work1->(DBGOTOP())

cOperacao:=Work1->WK_OPERACA
cExNCM:=Work1->WKEX_NCM
cExNBM:=Work1->WKEX_NBM
cTec  :=Work1->WKTEC
nNFE  :=Work1->WK_NFE
nSerie:=Work1->WK_SE_NFE
cForn :=Work1->WKFORN+Work1->WKLOJA
cInvoice:=Work1->WKINVOICE
dDtNFE:=Work1->WK_DT_NFE
nPesol:=nFob:=nFrete:=nSeguro:=nCIF:=nDespesa:=nDespUS:=0
nFob_R:=nCIF_Moe:=nItem:=nValor:=nItem:=nContItem:=0
lGerouNFE :=.F.
cNotaGrupo:=Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+Work1->WKLOJA
nNFEAux  :=""
nSerieAux:="" 
aCab  :={}//Para gravacao da Microsiga
aItens:={}//Para gravacao da Microsiga
lMSErroAuto := .F. 
lMSHelpAuto := .F. // para mostrar os erros na tela

IF lMV_EASY_SIM
   SC1->(DBSETORDER(1))
ENDIF

SB1->(DBSETORDER(1))
SB1->(DbSeek(xFilial("SB1")+EasyGParam("MV_PRODIMP")))
cNaturez:=EasyGParam("MV_NATDESP",,'')

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"LEWORK1_GERNF"),)
Begin Transaction

Begin SEQUENCE
  
DO WHILE If(cTipoNF # CUSTO_REAL, !Work1->(EOF()) , .T. )

   IncProc(STR0151) //"Gravando Nota Fiscal"

   If cTipoNF # CUSTO_REAL

      IF DI156CapQuebrou()//nNFE # Work1->WK_NFE  .OR. nSerie # Work1->WK_SE_NFE

         IF !DI156CapNF()
            BREAK
         ENDIF
         /*
         //TRP-16/07/08
         If lMV_EASY_SIM .AND. cTipoNF # NFE_DESPESAS
            For x:= 1 to Len(aItens)
               Aadd(aItensNF,{nNFE+nSerie+cForn+aItens[x][2][2]+aItens[x][1][2]+aItens[x][3][2],x})    
            Next x
         Endif
         */
         aItens:={}//Limpa os itens da tabela para nao acumular para a proxima nota
         nQtdeNFs +=1
         nVlTotNFs+=nValor
         nDespTotNFCs+=nDespesa
         cForn :=Work1->WKFORN+Work1->WKLOJA
         cInvoice:=Work1->WKINVOICE
         nNFE  :=Work1->WK_NFE
         nSerie:=Work1->WK_SE_NFE
         dDtNFE:=Work1->WK_DT_NFE
         nPesol:=nValor:=nFrete:=nSeguro:=nCIF:=nDespesa:=0

      ENDIF
      
      // O Seek do Work2 e do SA2 esta antes do Skip do Work1 para incluir os dados, na Capa, do Registro certo do Work2 e do SA2
      Work2->(DBSEEK(EVAL(bSeekWk2)))
      SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))

      IF lMV_EASY_SIM
         cNaturez:=IF(!EMPTY(SA2->A2_NATUREZ),SA2->A2_NATUREZ,cNaturez)
         cLOCAL:=SPACE(LEN(SC1->C1_LOCAL))
         IF PosO1_It_Solic(Work1->WK_CC,Work1->WKSI_NUM,Work1->WKCOD_I,Work1->WK_REG,0)
            SW0->(DBSEEK(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))
            IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+SW1->W1_POSICAO))
               cLOCAL   := SC1->C1_LOCAL
               cNaturez := IF(!EMPTY(SC1->C1_NATUREZ),SC1->C1_NATUREZ,cNaturez)
            ENDIF
         ENDIF

         IF SW1->(FIELDPOS("W1_NATUREZ")) # 0 .AND. !EMPTY(SW1->W1_NATUREZ)
            cNaturez := SW1->W1_NATUREZ
         ENDIF

         IF cTipoNF = NFE_IMPOSTOS
            nCIFItem:=Work1->WKOUT_DESP
         ELSE
            nCIFItem:=Work1->WKVALMERC
         ENDIF

         nQTSEGUM:=0
         nQUANT  :=Work1->WKQTDE
         cSEGUM  :=SPACE(LEN(Work1->WKUNI))
         cUNI    :=Work1->WKUNI
         aSegUM  :=AV_Seg_Uni(Work1->WK_CC,Work1->WKSI_NUM,Work1->WKCOD_I,Work1->WK_REG,Work1->WKQTDE)
         IF !EMPTY(aSegUM[2])
            If EasyGParam("MV_UNIDCOM",,2) == 2            
               nQTSEGUM:=Work1->WKQTDE
               nQUANT  :=aSegUM[2]
            Else
               nQTSEGUM:=aSegUM[2]         
            Endif   
            If SW0->(DBSeek(xFilial("SW0")+Work1->WK_CC+Work1->WKSI_NUM))
               IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+SW1->W1_POSICAO))//SW1 ja esta posicionado
                  cUNI  :=SC1->C1_UM
                  cSEGUM:=SC1->C1_SEGUM
               Endif               
            Endif
         ENDIF

         If cTipoNF==NFE_DESPESAS
            nQTSEGUM:=0
            cSEGUM  :=SPACE(LEN(Work1->WKUNI))
            cUNI    :=SPACE(LEN(Work1->WKUNI))
         ENDIF
         
         IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRVSD1_NF"),)         
         Di156GrvSD1(cLOCAL,nQTSEGUM,nQUANT,cUNI,cSEGUM,nCIFItem,cTipoNF,.T.)//AWR 27/08/2002
         aGrvImpSD1:={}
         DI156LerGrvImpostos("GRAVA_SD1",aGrvImpSD1)
         nUltReg:=LEN(aItens)
         FOR Imp := 1 TO LEN(aGrvImpSD1)
             AADD( aItens[nUltReg] , ACLONE(aGrvImpSD1[Imp]) )
         NEXT

      ENDIF
      
      IF cTipoNF = NFE_IMPOSTOS
         nCIF +=Work1->WKOUT_DESP
      ELSE
         nCIF +=Work1->WKVALMERC
      ENDIF
      nPesol  +=Work1->WKPESOL
      nValor  +=Work1->WKFOB_R
      nFrete  +=Work1->WKFRETE
      nSeguro +=Work1->WKSEGURO
      nDespesa+=Work1->WKOUT_DESP
      nVlTotNFs   +=Work1->WKFOB_R
      nDespTotNFCs+=Work1->WKOUT_DESP

   ELSE

      IF nNFE   # Work1->WK_NFE  .OR. nSerie    # Work1->WK_SE_NFE .OR.;
         cTec   # Work1->WKTEC   .OR. cOperacao # Work1->WK_OPERACA.OR.;
         cExNCM # Work1->WKEX_NCM.OR. cExNBM    # Work1->WKEX_NBM

         Work1->(DbSkip(-1))//Para gravar os dados do registro anterior
         Work2->(DBSEEK(Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
    
         EI3->(RecLock("EI3",.T.))
         EI3->EI3_FILIAL := xFilial("EI3")
         EI3->EI3_TIPO_N := cTipoNF
         EI3->EI3_HAWB   := SW6->W6_HAWB
         EI3->EI3_TEC    := Work2->WKTEC
         EI3->EI3_EX_NCM := Work2->WKEX_NCM
         EI3->EI3_EX_NBM := Work2->WKEX_NBM
         EI3->EI3_PESOL  := nPesol
         EI3->EI3_FOB    := nFob
         EI3->EI3_FOB_R  := nFob_R
         EI3->EI3_FRETE  := nFrete
         EI3->EI3_CIF_MO := nCIF_Moe
         EI3->EI3_SEGURO := nSeguro
         EI3->EI3_CIF    := nCIF 
         EI3->EI3_OUTRDE := nDespesa
         EI3->EI3_OUTR_U := nDespUS
         EI3->EI3_CFO    := Work2->WK_CFO
         EI3->EI3_OPERAC := Work2->WK_OPERACA
         EI3->EI3_NF_COM := Work1->WK_NFE
         //EI3->EI3_SE_NFC := Work1->WK_SE_NFE
         SerieNfId("EI3",1,"EI3_SE_NFC",,,,Work1->WK_SE_NFE)
         EI3->EI3_DT_NFC := Work1->WK_DT_NFE
         DI156GrvImpostos("EI3")
         EI3->(MsUnlock())

         IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRAVA_SD1_EI3"),)

         Work1->(DbSkip())
 
         IF Work1->(Eof())
            EXIT
         ENDIF

         cOperacao:=Work1->WK_OPERACA
         cExNCM:=Work1->WKEX_NCM
         cExNBM:=Work1->WKEX_NBM
         cTec  :=Work1->WKTEC
         nNFE  :=Work1->WK_NFE
         nSerie:=Work1->WK_SE_NFE
         dDtNFE:=Work1->WK_DT_NFE
         nPesol:=nFob:=nFrete:=nSeguro:=nCIF:=nDespesa:=nDespUS:=nFob_R:=nCIF_Moe:=0

      ENDIF

      nFob    +=Work1->WKFOB
      nFob_R  +=Work1->WKFOB_R
      nPesol  +=Work1->WKPESOL
      nFrete  +=Work1->WKFRETE
      nSeguro +=Work1->WKSEGURO
      nCIF    +=Work1->WKCIF
      nDespesa+=Work1->WKOUT_DESP
      nDespUS +=Work1->WKOUT_D_US

      DI156LerGrvImpostos("ACUMULA_SD1_EI3")

      IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"ACUMULA_SD1_EI3"),)

   ENDIF
   
   Work1->(DbSkip())

ENDDO

IF !lMSErroAuto .AND. cTipoNF # CUSTO_REAL
   DI156CapNF()
ENDIF
/*
//TRP 16/07/08
If cTipoNF # CUSTO_REAL .AND. lMV_EASY_SIM .AND. cTipoNF # NFE_DESPESAS .and. cTipoNF # NFE_IMPOSTOS
   For x:= 1 to Len(aItens)
      Aadd(aItensNF,{nNFE+nSerie+cForn+aItens[x][2][2]+aItens[x][1][2]+aItens[x][3][2],x})    
   Next x
Endif
*/
IF lMSErroAuto 
   BREAK
ENDIF

nWK1Ordem :=2 //Variavel usada para trocar a ordem da Work no Rdmake

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'IniciaVar2'),)

DBSELECTAREA("Work1")

Work4->(DBSETORDER(1))
Work1->(DBSETORDER(nWK1Ordem))//2
Work1->(DBGOTOP())
cForn :=Work1->WKFORN+Work1->WKLOJA
nNFE  :=Work1->WK_NFE
nSerie:=Work1->WK_SE_NFE
dDtNFE:=Work1->WK_DT_NFE
cInvoice:=Work1->WKINVOICE
nPesol:=nValor:=nFrete:=nSeguro:=nCIF:=nDespesa:=nItem:=0
nNFEAux  :=""
nSerieAux:="" 

DO WHILE ! Work1->(EOF())

   IncProc(STR0151) //"Gravando Nota Fiscal"

   If cTipoNF # CUSTO_REAL
      SWN->(RecLock("SWN",.T.))
      SWN->WN_FILIAL   := xFilial("SWN")
      SWN->WN_TIPO_NF  := cTipoNF
      SWN->WN_HAWB     := SW6->W6_HAWB
      SWN->WN_DOC      := Work1->WK_NFE
      //SWN->WN_SERIE    := Work1->WK_SE_NFE
      SerieNfId("SWN",1,"WN_SERIE",,,,Work1->WK_SE_NFE)
      SWN->WN_TEC      := Work1->WKTEC
      SWN->WN_EX_NCM   := Work1->WKEX_NCM
      SWN->WN_EX_NBM   := Work1->WKEX_NBM
      SWN->WN_PO_EIC   := Work1->WKPO_NUM 
      SWN->WN_PO_NUM   := Work1->WKPO_SIGA

      If (cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS)
         SWN->WN_ITEM:=  Work1->WKSEQNF
      Else
         SWN->WN_ITEM     := Work1->WKPOSICAO
      EndIf

      SWN->WN_QUANT    := If(cTipoNF==NFE_DESPESAS,0,Work1->WKQTDE)
      SWN->WN_PRECO    := Work1->WKPRECO
      SWN->WN_UNI      := Work1->WKUNI
      
      /*
      //TRP-16/07/08
      If lMV_EASY_SIM// .AND. cTipoNF # NFE_DESPESAS .and. cTipoNF # NFE_IMPOSTOS
         If (nPosicao:= ASCAN(aItensNF,{|x| x[1] =Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+Work1->WKLOJA+Work1->WKPO_SIGA+Work1->WKCOD_I+Work1->WKPOSICAO})) # 0 
            SWN->WN_ITEMNF := STRZERO(aItensNF[nPosicao,2],Len(SWN->WN_ITEMNF))
         Endif
      Endif
      */
      
      If SWN->(FieldPos("WN_ITEMNF")) > 0
         SWN->WN_ITEMNF := Work1->WK_ITEMNF
      EndIf
      
      //Controle para a numeração dos itens (WN_LINHA) POR NOTA
      If SWN->(FieldPos("WN_LINHA")) > 0
	      IF (nNFLin := ASCAN(aNFLin, {|x|x[1]==Work1->(WK_NFE+WK_SE_NFE)}) ) == 0
    	     SWN->WN_LINHA := 1
	         AADD(aNFLin, {Work1->(WK_NFE+WK_SE_NFE), 1})
    	  Else
        	 aNFLin[nNFLin,2] += 1
	         SWN->WN_LINHA := aNFLin[nNFLin,2]
    	  Endif
      EndIf

      IF lMV_EASY_SIM
         IF PosO1_It_Solic(Work1->WK_CC,Work1->WKSI_NUM,Work1->WKCOD_I,Work1->WK_REG,0)
            SW0->(DBSEEK(xFilial("SW0")+SW1->W1_CC+SW1->W1_SI_NUM))
            IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+SW1->W1_POSICAO))
               SWN->WN_LOCAL := SC1->C1_LOCAL
            ENDIF
         ENDIF      
         
         aSegUM:=AV_Seg_Uni(Work1->WK_CC,Work1->WKSI_NUM,Work1->WKCOD_I,Work1->WK_REG,Work1->WKQTDE)
         IF !EMPTY(aSegUM[2])
            If EasyGParam("MV_UNIDCOM",,2) == 2            
               SWN->WN_PRECO  :=(Work1->WKQTDE * Work1->WKPRECO) / aSegUM[2]
               SWN->WN_QTSEGUM:=If(cTipoNF==NFE_DESPESAS,0,Work1->WKQTDE)
               SWN->WN_QUANT  :=If(cTipoNF==NFE_DESPESAS,0,aSegUM[2])
            Else
               SWN->WN_QTSEGUM:=aSegUM[2]         
            Endif   
            If SW0->(DBSeek(xFilial("SW0")+Work1->WK_CC+Work1->WKSI_NUM))
               IF SC1->(DBSEEK(xFilial("SC1")+SW0->W0_C1_NUM+SW1->W1_POSICAO))//SW1 ja esta posicionado
                  cUNI  :=SC1->C1_UM
                  cSEGUM:=SC1->C1_SEGUM
               Endif               
            Endif
         ENDIF
      ENDIF

      SWN->WN_PRODUTO  := Work1->WKCOD_I
      SWN->WN_OPERACA  := Work1->WK_OPERACA
      SWN->WN_FORNECE  := IF(EMPTY(cFornSWN).OR.cTipoNF#NFE_IMPOSTOS,Work1->WKFORN,cFornSWN)
      SWN->WN_LOJA     := IF(EMPTY(cFornSWN).OR.cTipoNF#NFE_IMPOSTOS,Work1->WKLOJA,cLojaSWN)
      SWN->WN_DESCR    := Work1->WKDESCR
      SWN->WN_UNI      := Work1->WKUNI
      SWN->WN_PRUNI    := Work1->WKPRUNI
      SWN->WN_RATEIO   := DITRANS(Work1->WKRATEIO,9)
      SWN->WN_PESOL    := Work1->WKPESOL
      IF cTipoNF = NFE_IMPOSTOS
         SWN->WN_VALOR := Work1->WKOUT_DESP
      ELSE
         SWN->WN_VALOR := Work1->WKVALMERC
      ENDIF
      SWN->WN_FRETE    := Work1->WKFRETE
      SWN->WN_SEGURO   := Work1->WKSEGURO
      SWN->WN_CIF      := Work1->WKVALMERC//Work1->WKCIF
      SWN->WN_DESPESA  := Work1->WKOUT_DESP
      SWN->WN_SI_NUM   := Work1->WKSI_NUM
      SWN->WN_CC       := Work1->WK_CC
      SWN->WN_CFO      := Work1->WK_CFO
      SWN->WN_OUTR_US  := Work1->WKOUT_D_US
      SWN->WN_PGI_NUM  := Work1->WKPGI_NUM
      SWN->WN_INVOICE  := Work1->WKINVOICE
      SWN->WN_FOB_R    := Work1->WKFOB_R
      IF lLote
         SWN->WN_LOTECTL:= Work1->WK_LOTE
         SWN->WN_DTVALID:= Work1->WKDTVALID
      ENDIF
      IF lWN_DESPSUB .AND. !EMPTY(Work1->WKDESPSUB)
         SWN->WN_DESPSUB:= Work1->WKDESPSUB
      ENDIF
      IF lWN_CODESP
         If SWN->WN_TIPO_NF $ "9"
         	SWN->WN_CODESP := LEFT(Work4->WKDESPESA,LEN(SWD->WD_DESPESA))
         Else
         	SWN->WN_CODESP := LEFT(Work1->WKDESPESA,LEN(SWD->WD_DESPESA))       
         EndIf	
         //SWN->WN_CODESP := SWD->WD_DESPESA 
      ENDIF
      DI156LerGrvImpostos("GRAVA_SWN_EI2")
                   
      // EOS - 06/10/03
      IF cPaisLoc # "BRA" .AND. SWN->(FIELDPOS('WN_LOCAL')) # 0
         // No WN_LOCAL ja vem gravado o C1_LOCAL e no WKLOCAL ja vem o W7_LOCAL
         // Prioridade 1o. - SW7, 2o. - SC1, 3o. - SB1
         IF !EMPTY(Work1->WKLOCAL)//SW7
            SWN->WN_LOCAL := Work1->WKLOCAL
         ELSEIF EMPTY(SWN->WN_LOCAL)//SC1
            SB1->(DbSeek(xFilial("SB1")+Work1->WKCOD_I))
            SWN->WN_LOCAL := SB1->B1_LOCPAD
         ENDIF
      ENDIF

      //TRP-10/01/08
      IF SWN->( FieldPos("WN_TES") ) > 0
         SWN->WN_TES := Work1->WKTES
      ENDIF
      IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRAVACAO_SWN"),)     

      SWN->(MsUnlock())
      //TRP-10/01/08
      /*IF SW7->( FieldPos("W7_TES") ) > 0
         SW7->(DbSetOrder(4))
         SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB+Work1->WKPO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM))
         SW7->(RecLock("SW7",.F.))
         SW7->W7_TES := Work1->WKTES   
         SW7->(MsUnlock())
      ENDIF*/

      nPesol  +=SWN->WN_PESOL
      nValor  +=SWN->WN_VALOR//Work1->WKFOB_R
      nFrete  +=SWN->WN_FRETE
      nSeguro +=SWN->WN_SEGURO
      nCIF    +=SWN->WN_CIF
      nDespesa+=SWN->WN_DESPESA 

   ELSE

      IF DI156CapQuebrou()

        DI156CapNF()
        nQtdeNFs +=1
        nVlTotNFs+=nValor
        nDespTotNFCs+=nDespesa
        cForn :=Work1->WKFORN+Work1->WKLOJA
        nNFE  :=Work1->WK_NFE
        nSerie:=Work1->WK_SE_NFE
        dDtNFE:=Work1->WK_DT_NFE
        nPesol:=nValor:=nFrete:=nSeguro:=nCIF:=nDespesa:=0
        cInvoice:=Work1->WKINVOICE
      ENDIF

      EI2->(RecLock("EI2",.T.))
      EI2->EI2_FILIAL   := xFilial("EI2")
      EI2->EI2_TIPO_NF  := cTipoNF
      EI2->EI2_HAWB     := SW6->W6_HAWB
      EI2->EI2_DOC      := Work1->WK_NFE
      //EI2->EI2_SERIE    := Work1->WK_SE_NFE
      SerieNfId("EI2",1,"EI2_SERIE",,,,Work1->WK_SE_NFE)

      EI2->EI2_TEC      := Work1->WKTEC
      EI2->EI2_EX_NCM   := Work1->WKEX_NCM
      EI2->EI2_EX_NBM   := Work1->WKEX_NBM
      EI2->EI2_PO_NUM   := Work1->WKPO_NUM
      EI2->EI2_POSICA   := Work1->WKPOSICAO
      EI2->EI2_QUANT    := If(cTipoNF==NFE_DESPESAS,0,Work1->WKQTDE)
      EI2->EI2_PRODUTO  := Work1->WKCOD_I
      EI2->EI2_VALOR    := Work1->WKVALMERC
      EI2->EI2_OPERACA  := Work1->WK_OPERACA
      EI2->EI2_FORNECE  := Work1->WKFORN
      EI2->EI2_LOJA     := Work1->WKLOJA
      EI2->EI2_PRECO    := Work1->WKPRECO
      EI2->EI2_DESCR    := Work1->WKDESCR
      EI2->EI2_UNI      := Work1->WKUNI
      EI2->EI2_PRUNI    := Work1->WKPRUNI
      EI2->EI2_RATEIO   := DITRANS(Work1->WKRATEIO,9)
      EI2->EI2_PESOL    := Work1->WKPESOL
      EI2->EI2_SEGURO   := Work1->WKSEGURO
      EI2->EI2_CIF      := Work1->WKCIF
      EI2->EI2_DESPES   := Work1->WKOUT_DESP
      EI2->EI2_FRETE    := Work1->WKFRETE
      EI2->EI2_SI_NUM   := Work1->WKSI_NUM
      EI2->EI2_CC       := Work1->WK_CC
      EI2->EI2_CFO      := Work1->WK_CFO
      EI2->EI2_REC_ID   := Work1->WKRECNO
      EI2->EI2_OUTR_U   := Work1->WKOUT_D_US
      EI2->EI2_PGI_NU   := Work1->WKPGI_NUM
      EI2->EI2_FOB_R    := Work1->WKFOB_R
      EI2->EI2_INVOICE  := Work1->WKINVOICE
      IF lLote
         EI2->EI2_LOTECT:= Work1->WK_LOTE
         EI2->EI2_DTVALI:= Work1->WKDTVALID
      ENDIF
      DI156LerGrvImpostos("GRAVA_SWN_EI2")      
      
      EI2->(MsUnlock())

      nPesol  +=EI2->EI2_PESOL
      nValor  +=Work1->WKFOB_R
      nFrete  +=EI2->EI2_FRETE
      nSeguro +=EI2->EI2_SEGURO
      nCIF    +=EI2->EI2_CIF
      nDespesa+=EI2->EI2_DESPESAS

   ENDIF

   IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRAVA_SWN_EI2"),)     
 
   // O Seek do SA2 e Work4 esta antes do Skip do Work1 para incluir os dados, na Capa, do Registro certo do SA2
   Work2->(DBSEEK(Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
   SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))
   
   If cTipoNF = NFE_DESPESAS
      IF Work4->(DBSEEK(" "+Work1->(WK_NFE_AUX+WKFORN+WKLOJA+LEFT(WKDESPESA,LEN(SWD->WD_DESPESA)))))
         DO While Work4->(!EOF()) .AND.;
                  " "+Work1->(WK_NFE_AUX+WKFORN+WKLOJA+LEFT(WKDESPESA,LEN(SWD->WD_DESPESA))) ==;
                  Work4->(WKFILTRO+WKDOC+WKFORN+WKLOJA+LEFT(WKDESPESA,LEN(SWD->WD_DESPESA)))
            IF !EMPTY(Work4->WKFLAG)
               Work4->WKNOTA :=Work1->WK_NFE
               Work4->WKSERIE:=Work1->WK_SE_NFE
            ENDIF
            Work4->(DBSKIP())
         ENDDO
      ENDIF
   ENDIF
   
   Work1->(DbSkip())

ENDDO

If cTipoNF = CUSTO_REAL
   DI156CapNF()
ENDIF

nQtdeNFs +=1
nVlTotNFs+=nValor
nDespTotNFCs+=nDespesa

Work1->(DbGoTop())

SW6->(RecLock("SW6",.F.))

If cTipoNF = NFE_IMPOSTOS
   SW6->W6_NF_ENT  :=ALLTRIM(Work1->WK_NFE)+IF(nQtdeNFs>1," ...","")
   //SW6->W6_SE_NF   :=Work1->WK_SE_NFE
   SerieNfId("SW6",1,"W6_SE_NF",,,,Work1->WK_SE_NFE)

   SW6->W6_DT_NF   :=Work1->WK_DT_NFE
   SW6->W6_VL_NF   :=nVlTotNFs
ENDIF
IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = NFE_FRETE .OR.;
   cTipoNF = NFE_CIF      .OR. cTipoNF = CUSTO_REAL
   DI156ProcEIB(.T.)
ENDIF

If cTipoNF = NFE_DESPESAS
   SW6->W6_NF_COMP:=ALLTRIM(Work1->WK_NFE)+IF(nQtdeNFs>1," ...","")
   //IF(SW6->(FIELDPOS('W6_SE_NFC'))#0,SW6->W6_SE_NFC:=Work1->WK_SE_NFE,)
   SerieNfId("SW6",1,"W6_SE_NFC",,,,Work1->WK_SE_NFE)
   SW6->W6_DT_NFC :=Work1->WK_DT_NFE
   IF(SW6->(FIELDPOS('W6_VL_NFC'))#0,SW6->W6_VL_NFC :=nDespTotNFCs,)
ENDIF

Work1->(DBSETORDER(nWK1Ordem))//2
Work1->(DBGOTOP())

If cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS
   Work4->(DBGOTOP())
   DO While Work4->(!EOF())
      IncProc(STR0152+Work4->WKDESPESA)//"Gravando Despesas: "
      IF !EMPTY(Work4->WKFLAG) .AND. !LEFT(Work4->WKDESPESA,1) $ "1,2,9"
         SWD->(DBGOTO(Work4->WKRECNO))
         SWD->(RecLock("SWD",.F.))
         If cTipoNF = NFE_DESPESAS
            SWD->WD_NF_COMP:=Work4->WKNOTA
            //SWD->WD_SE_NFC :=Work4->WKSERIE
            SerieNfId("SWD",1,"WD_SE_NFC",,,,Work4->WKSERIE)
         ELSE
            SWD->WD_NF_COMP:=Work1->WK_NFE
            //SWD->WD_SE_NFC :=Work1->WK_SE_NFE
            SerieNfId("SWD",1,"WD_SE_NFC",,,,Work1->WK_SE_NFE)
         ENDIF
         SWD->WD_DT_NFC :=Work1->WK_DT_NFE
         SWD->WD_VL_NFC :=nVlTotNFs
         SWD->(MsUnlock())
      ENDIF
      Work4->(DBSKIP())
    ENDDO
ENDIF
           
// EOS - 06/10/03
IF cPaisLoc # "BRA" .AND. SW6->(FIELDPOS("W6_VMINSEG")) # 0 .AND. cTipoNF = '9'
   SW6->W6_VMINSEG := MDI_SEGURO 
ENDIF

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRAVA_CAPA_SW6"),)

SW6->(MsUnlock())

IF cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
   Work3->(DBGOTOP())
   DO WHILE Work3->(!EOF())
      IncProc(STR0152+Work3->WKDESPESA+'-'+Work3->WKDESCR)//"Gravando Despesas: "
      IF !EMPTY(Work3->WKFLAG)
         Work1->(DBGOTO(VAL(Work3->WKRECNO)))
         SWW->(RecLock("SWW",.T.))
         SWW->WW_FILIAL  := xFilial("SWW")
         SWW->WW_DESPESA := Work3->WKDESPESA+'-'+Work3->WKDESCR
         SWW->WW_VALOR   := Work3->WKVALOR
         SWW->WW_PO_NUM  := Work3->WKPO_NUM
         If cTipoNF = NFE_DESPESAS
            SWW->WW_NF_COMP := Work3->WK_NF_COMP
            //SWW->WW_SE_NFC  := Work3->WK_SE_NFC
            SerieNfId("SWW",1,"WW_SE_NFC",,,,Work3->WK_SE_NFC)
         ELSE
            SWW->WW_NF_COMP := Work1->WK_NFE
            //SWW->WW_SE_NFC  := Work1->WK_SE_NFE
            SerieNfId("SWW",1,"WW_SE_NFC",,,,Work1->WK_SE_NFE)
         ENDIF
         SWW->WW_DT_NFC  := Work1->WK_DT_NFE
         SWW->WW_TIPO_NF := cTipoNF
         SWW->WW_NR_CONT := Work3->WKPOSICAO
         SWW->WW_HAWB    := SW6->W6_HAWB
         SWW->WW_PGI_NUM := Work3->WKPGI_NUM
         SWW->WW_FORNECE := Work3->WKFORN
         SWW->WW_LOJA    := Work3->WKLOJA
         IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRAVA_SWW"),)
         SWW->(MsUnlock())
      ENDIF
      Work3->(DBSKIP())
   ENDDO
ENDIF

Work1->(DBSETORDER(1))
Work1->(DbGoto(nRec1))
Work2->(DbGoto(nRec2))

End SEQUENCE

End Transaction

IF lMV_EASY_SIM .AND. !lMSErroAuto .AND. cTipoNF # CUSTO_REAL

   cClassif:=EasyGParam("MV_CLASSNF",,"1")
   If cClassif== '3'
      lClassif := MsgYesNo('Desea clasificar la factura automaticamente?')	
   Else 
      lClassif := (cClassif == '1')
   ENDIF

   IF lClassif
      FOR R := 1 TO LEN(aRecnosSF1)
          SF1->(DBGOTO( aRecnosSF1[R] ))
          aCab  :={}
          aItens:={}
          AADD(aCab,{"F1_DOC"    ,SF1->F1_DOC    ,".T."})// NUMERO DA NOTA
          AADD(aCab,{"F1_SERIE"  ,SF1->F1_SERIE  ,".T."})// SERIE DA NOTA
          AADD(aCab,{"F1_FORNECE",SF1->F1_FORNECE,".T."})// FORNECEDOR  
          AADD(aCab,{"F1_LOJA"   ,SF1->F1_LOJA   ,".T."})// LOJA DO FORNECEDOR 
          AADD(aCab,{"F1_TIPODOC",SF1->F1_TIPODOC,".T."})// NUMERO DA NOTA
          AADD(aCab,{"F1_MOEDA"  ,SF1->F1_MOEDA  ,".T."})// Moeda
          AADD(aCab,{"F1_TXMOEDA",SF1->F1_TXMOEDA,".T."})// Taxa da Moeda
          AADD(aCab,{"F1_COND"   ,SF1->F1_COND   ,".T."})// Condicion de Pagamento

          IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRAVA_CPO_DIGITADA_CLASSIFICACAO"),)

          MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCab,aItens,4,.F.)// Classifica a nota no Compras MicroSiga
          IF lMSErroAuto           
             MostraErro()
             EXIT
          ENDIF
      NEXT
   ENDIF

ENDIF

// Incluso no padrão conforme Bops 127122
IF !lMSErroAuto .AND.  cTipoNF == NFE_IMPOSTOS .AND. lMV_EICNSE2

// Para actualizar financiero correctamente en la factura de gastos 
/*  nMas := 0// AWR 25/08/2008 - While nopado
  SD1->(DbSetOrder( 1 ))
	SD1->(DbSeek( xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE+SF1->F1_LOJA ))
 	While !SD1->( EOF() ) .and. SF1->F1_DOC == SD1->D1_DOC .and. SF1->F1_SERIE == SD1->D1_SERIE .and. SF1->F1_FORNECE == SD1->D1_FORNECE .and. SF1->F1_LOJA == SD1->D1_LOJA
		//nMas := nMas + SD1->D1_VALIMP1 + SD1->D1_VALIMP2 + SD1->D1_VALIMP3 + SD1->D1_VALIMP4 + SD1->D1_VALIMP5 + SD1->D1_VALIMP6 
		aImpostos := DefImposto(SD1->D1_TES)
		For nY:=1 to Len(aImpostos)
			nPosSD1 := SD1->(FieldPos("D1_"+Substr(aImpostos[nY][2],1,7)))
			If nPosSD1 > 0
				If ( aImpostos[nY][4] $ "S1" ) //Verifica se suma el impuesto al título a pagar (Cpo FC_INCDUPL), Lucas 07/09/2007
					nMas := nMas + SD1->(FieldGet(nPosSD1))
				EndIf
			EndIf
		Next nY
		SD1->(DbSkip())
	EndDo*/
	SE2->(DbSetOrder( 6 ))
	//IF SE2->(DbSeek( xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + "EIC" + SF1->F1_DOC )) 
	IF SE2->(DbSeek( xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SWD->WD_SE_DOC + SF1->F1_DOC ))
		nCobrado = SE2->E2_VALOR - SE2->E2_SALDO
		SE2->(RecLock( 'SE2', .F. ))
		SE2->E2_VLCRUZ := SE2->E2_VLCRUZ + nTotImpostos//SF1->F1_FOB_R + nMas // AWR 25/08/2008
		SE2->E2_VALOR  := ( SE2->E2_VLCRUZ )  / If(SE2->E2_TXMOEDA=0, 1,SE2->E2_TXMOEDA )
		SE2->E2_SALDO  := ( SE2->E2_VLCRUZ )  / If(SE2->E2_TXMOEDA=0, 1,SE2->E2_TXMOEDA ) - nCobrado
		SE2->(MsUnlock())
	Endif
endif                                                                                                         

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"FINAL_GRV_NF"),)

IF !lMSErroAuto 
   lGerouNFE:=.T.
   cNota:=cNotaGrupo//Para o Estorno logo apos gerar a NF
   IF cTipoNF # CUSTO_REAL
      MSGINFO(OemtoAnsi(STR0153),STR0108) //"Gera‡Æo de Nota Fiscal Conclu¡da"###"Informação"
   ELSE
      MsgInfo(OemTOAnsi(STR0154),STR0108) //"Grava‡Æo de Custo Conclu¡da"###"Informação"
   ENDIF
ENDIF
DbSelectArea("Work1")
Return .T.

*---------------------*
Function DI156Quebrou()
*---------------------*
PRIVATE lQuebra_Espe:=.f., lQuebrou_NF:=.f.

IF (EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'Tem_Outra_Quebra'),)

IF ! lQuebra_Espe
   IF nItem >= GetNewPar("MV_NUMITEN",99) .OR.;
      nItem == 0 .OR. cForn # Work1->WKFORN+Work1->WKLOJA .OR.;
      cCFO # Work1->WK_CFO .OR.;
      (lQuebraOperacao .AND. cOperacao # Work1->WK_OPERACA)
     RETURN .T.
   ELSE
     RETURN .F.
   ENDIF
ENDIF

RETURN lQuebrou_NF

*-------------------------*
Function DI156CapQuebrou()
*-------------------------*
PRIVATE lQuebra_Espe:=.F., lQuebrou_NF:=.F.

IF (EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'Outra_Quebra'),)

IF ! lQuebra_Espe
   IF nNFE # Work1->WK_NFE .OR. nSerie # Work1->WK_SE_NFE .OR. cForn # Work1->WKFORN+Work1->WKLOJA
     RETURN .T.
   ELSE
     RETURN .F.
   ENDIF
ENDIF
     
RETURN lQuebrou_NF

*-----------------------*
Function DI156CapNF()
*-----------------------*
LOCAL GRV, cChaveSF1
//***ASK 21/01/2008 - Tratamento de Ingressos Brutos
Local cCAI := ""
Local dVenCAI := CtoD("") 
Local cProvEnt := ""
Local cCondPag := ""

Private lTemCAI :=  SWD->(FieldPos("WD_PROVENT")) > 0 .and.;
                    SWD->(FieldPos("WD_CAI")    ) > 0 .and.;
                    SWD->(FieldPos("WD_VENCAI") ) > 0
                   
//Nota:
//NFE_DESPESAS  'A'
cNFCompl:="A"       

// EOS - desvio para reconstrucao do aitens para gravar no SD1
IF lGrvDespSD1 .AND. ( cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS )
   DI156Refaz()
ENDIF   

If cTipoNF = NFE_DESPESAS
   cNotaGrupo:=nNFE+nSerie+cForn
ENDIF
                     
//***ASK 21/01/2008 - Tratamento de Ingressos Brutos
If cTipoNF $ "9A"
    SWD->(DbSetOrder(6))
    If SWD->(DbSeek(xFilial("SWD") + nNFE + SA2->A2_COD + SA2->A2_LOJA))
        cCondPag := SWD->WD_COND
        IF lTemCAI
            cCai     := SWD->WD_CAI
            dVenCAi  := SWD->WD_VENCAI
            cProvEnt := SWD->WD_PROVENT
        ENDIF
    EndIF
ElseIf cTipoNF $ NFE_FOB
    SW9->(DbSetOrder(1)) //W9_FILIAL+W9_INVOICE+W9_FORN+W9_FORLOJ+W9_HAWB -- SW2->W2_PO_NUM
    If SW9->( DbSeek(xFilial("SW9") + cInvoice + cForn + SW6->W6_HAWB ) )
        If SY6->( DbSeek( xFilial("SY6") + SW9->W9_COND_PA ))
            If SE4->(DbSeek( xFilial("SE4") + SY6->Y6_SIGSE4 ))
                cCondPag := SE4->E4_CODIGO
            EndIf
        EndIf
    EndIf
EndIf

If cTipoNF # CUSTO_REAL
    SA2->(DBSEEK(xFilial("SA2")+cForn))
    cChaveSF1:=nNFE+nSerie+SA2->A2_COD+SA2->A2_LOJA+IF(cTipoNF$cNFCompl,"C","N")

    aCab := {}
    AADD(aCab,{"F1_TIPO"        ,IF(cTipoNF $ cNFCompl,"C","N"),".T."})// TIPO DA NOTA - "N"ORMAL OU "C"OMPLEMENTAR
    AADD(aCab,{"F1_FORMUL"      ,cFormPro          ,".T."})   // FORMULARIO PROPRIO SIM OU NAO, CONF.OPCAO DO USUARIO
    AADD(aCab,{"F1_DOC"         ,nNFE              ,".T."})   // NUMERO DA NOTA
    AADD(aCab,{"F1_SERIE"       ,nSerie            ,".T."})   // SERIE DA NOTA
    AADD(aCab,{"F1_EMISSAO"     ,dDtNFE            ,".T."})   // DATA DA EMISSAO DA NOTA                                 
    AADD(aCab,{"F1_FORNECE"     ,SA2->A2_COD       ,".T."})   // FORNECEDOR  
    AADD(aCab,{"F1_LOJA"        ,SA2->A2_LOJA      ,".T."})   // LOJA DO FORNECEDOR 
    AADD(aCab,{"F1_ESPECIE"     ,'NF'              ,".T."})   // NOTA FISCAL DE ENTRADA
    AADD(aCab,{"F1_DTDIGIT"     ,dDataBase         ,".T."})
    AADD(aCab,{"F1_EST"         ,"EX"              ,".T."}) 
    AADD(aCab,{"F1_TIPODOC"     ,IF(cTipoNF $ cNFCompl,"13","10"),".T."})
    AADD(aCab,{"F1_TIPO_NF"     ,cTipoNF           ,".T."})
    AADD(aCab,{"F1_HAWB"        ,SW6->W6_HAWB      ,".T."})
    AADD(aCab,{"F1_PESOL"       ,nPesol            ,".T."})
    AADD(aCab,{"F1_FOB_R"       ,nValor            ,".T."})
    AADD(aCab,{"F1_FRETE"       ,nFrete            ,".T."})
    AADD(aCab,{"F1_SEGURO"      ,nSeguro           ,".T."})
    AADD(aCab,{"F1_CIF"         ,nCIF              ,".T."})
    AADD(aCab,{"F1_DESPESA"     ,nDespesa          ,".T."})
    AADD(aCab,{"F1_CTR_NFC"     ,cNotaGrupo        ,".T."})
    AADD(aCab,{"F1_MOEDA"       ,1                 ,".T."})
    AADD(aCab,{"F1_TXMOEDA"     ,1.00              ,".T."})
    AADD(aCab,{"F1_STATUS"      ,"A"               ,".T."})// NF Classificada
    //TRP - 06/07/2012 - Vide Chamado 093906 - Origem sempre da tabela SYT.
    SYT->(DBSETORDER(1))
    IF SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
        lSeekouSYT:= .T.
    ENDIF
    //***ASK 21/01/2008 - Tratamento de Ingressos Brutos
    If lTemCai .And. cTipoNF $ "9A" 
        AADD(aCab,{"F1_CAI"     ,cCAI               ,".T."})
        AADD(aCab,{"F1_VENCAI"  ,dVenCAI            ,".T."})
        IF lSeekouSYT
            AADD(aCab,{"F1_PROVENT" ,Alltrim(SYT->YT_ESTADO)     ,".T."}) 
        ENDIF
        //AADD(aCab,{"F1_PROVENT" ,cProvEnt           ,".T."})   
    Else
        IF lSeekouSYT
            IF cPaisLoc = "ARG"
            AADD(aCab,{"F1_PROVENT"     ,Alltrim(SYT->YT_ESTADO)       ,".T."})
            ENDIF  
        Endif
    EndIf
    If cTipoNF $ "9A" .OR. cTipoNF $ NFE_FOB
        AADD(aCab,{"F1_COND"    ,cCondPag           ,".T."})
    EndIf

    IF(EasyEntryPoint("EICDI154"),Execblock("EICDI154",.F.,.F.,"GRAVACAO_SF1"),)
                                                    
    IF lMV_EASY_SIM
        
        MSExecAuto({|x,y| MATA140(x,y)},aCab,aItens, 3)
        
        IF lMSErroAuto
            MostraErro()
            RETURN .F.
        ENDIF
        IF (nPos:=ASCAN(aCab,{ |A| A[1]="F1_EST" } )) # 0
            SF1->(DBSETORDER(1))
            IF SF1->(DBSEEK(xFilial()+cChaveSF1))
                AADD(aRecnosSF1, SF1->(RECNO()) )
                SF1->(RecLock("SF1",.F.))
                FOR GRV := nPos TO LEN(aCab) 
                    IF ( nPos:=SF1->( FIELDPOS(aCab[GRV,1]) ) ) # 0
                        SF1->( FIELDPUT(nPos,aCab[GRV,2]) )
                    ENDIF
                NEXT
                DI156GrvImpostos("SF1")
                SF1->(MsUnlock())
            ELSE         
                MSGSTOP(STR0038+": ( "+cChaveSF1+" ) "+STR0036,STR0022)
                lMSErroAuto:=.T.
                RETURN .F.
            ENDIF
        ENDIF
        IF lMSErroAuto
            MostraErro()
        ENDIF

    ELSE

        SF1->(RecLock("SF1",.T.))
        SF1->F1_FILIAL := xFilial("SF1")
        FOR GRV := 1 TO LEN(aCab) 
            IF ( nPos:=SF1->( FIELDPOS(aCab[GRV,1]) ) ) # 0
                SF1->( FIELDPUT(nPos,aCab[GRV,2]) )
            ENDIF
        NEXT
        DI156GrvImpostos("SF1")
        SF1->(MsUnlock())

    ENDIF                  

Else
   EI1->(RecLock("EI1",.T.))
   EI1->EI1_FILIAL   := xFilial("EI1")
   EI1->EI1_CIF      := nCIF
   EI1->EI1_DOC      := nNFE
   //EI1->EI1_SERIE    := nSerie
   SerieNfId("EI1",1,"EI1_SERIE",,,,nSerie)
   EI1->EI1_DTDIGI   := dDataBase
   EI1->EI1_DESPES   := nDespesa
   EI1->EI1_EMISSA   := dDtNFE
   EI1->EI1_FOB_R    := nValor
   EI1->EI1_FORNEC   := SA2->A2_COD
   EI1->EI1_FRETE    := nFrete
   EI1->EI1_HAWB     := SW6->W6_HAWB
   EI1->EI1_LOJA     := SA2->A2_LOJA
   EI1->EI1_PESOL    := nPesol
   EI1->EI1_SEGURO   := nSeguro
   //EI1->EI1_SERIE    := nSerie
   EI1->EI1_TIPO_NF  := cTipoNF
   DI156GrvImpostos("EI1")
   EI1->(MsUnlock())
Endif

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRAVA_SF1_EI1"),)

RETURN .T.


*--------------------------------------*
Function DI156Delet()
*--------------------------------------*
LOCAL nCont:=0, lNFClassif:=.F.,lTemMensagem:=.F.
LOCAL cPos:="",cPO:="",I
LOCAL nY
PRIVATE cFilSF1:=xFILIAL("SF1")
PRIVATE cFilSD1:=xFILIAL("SD1")
lMSErroAuto := .F. 
lMSHelpAuto := .F.

IF cTipoNF # CUSTO_REAL

   ProcRegua(2)

   SF1->(DBSETORDER(1))
   bForNota:={ || SF1->(DBSEEK(cFilSF1+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA))) .AND.;
                 (EMPTY(cNota) .OR. cNota == SF1->F1_CTR_NFC) }

   IncProc(STR0132) //"Verificando Processo, Aguarde..."
   SD1->(DBSETORDER(8))
   SD1->(DBSEEK(cFilSD1+SW6->W6_HAWB+cTipoNF))
   SD1->(DBEVAL({||lNFClassif:=!EMPTY(SD1->D1_TES)},bForNota,;
                {||cFilSD1         == SD1->D1_FILIAL  .AND.;
                   SD1->D1_CONHEC  == SW6->W6_HAWB    .AND.;
                   SD1->D1_TIPO_NF == cTipoNF.AND.;
                   !lNFClassif }))

// IF lNFClassif
//    IncProc(OemtoAnsi(STR0155)) //"Notas Fiscais nÆo pode serem estornadas"
//    MSGINFO(OemToAnsi(STR0156),STR0022) //"Essa nota j  esta apropriada no SIGACOM"###"Atenção"
//    RETURN .F.
// ENDIF

   SF1->(DBSETORDER(5))
   SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+cTipoNF))
   SF1->(DBEVAL({||++nCont},,{||xFilial("SF1")  == SF1->F1_FILIAL  .AND.;
                                SF1->F1_HAWB    == SW6->W6_HAWB    .AND.;
                                SF1->F1_TIPO_NF == cTipoNF}))


   ProcRegua(nCont+3)

   IncProc(STR0157) //"Estornando Nota Fiscal"

cClassif:=EasyGParam("MV_CLASSNF",,"1")
If cClassif== '3'            // AWR - 19/08/2004 - Nao precisa perguntar, pois p/ estornar precisa cancelar a classificacao
   lDesClassif := lNFClassif
   IF lDesClassif
      IF !MsgYesNo("Desea anular la clasificacion de la factura automaticamente?")
         MSGSTOP("Anule la clasificacion en SIGACOM y despues revierta en SIGAEIC.")//"Cancele a classficacao no SIGACOM e depois estone no SIGAEIC."
         RETURN .F.
      ENDIF
   ENDIF
Else 
   lDesClassif := lNFClassif .AND. (cClassif == '1')
ENDIF

Begin Transaction

BEGIN SEQUENCE
   SD1->(DBSETORDER(1))
   SF1->(DBSETORDER(5))

   aItens:={}
   aNotasDel:={}
   SF1->(DBSEEK(xFilial("SF1")+SW6->W6_HAWB+cTipoNF))

   DO WHILE SF1->(!EOF())                  .AND.;
         SF1->F1_FILIAL  == xFilial("SF1") .AND.;
         SF1->F1_HAWB    == SW6->W6_HAWB   .AND.;
         SF1->F1_TIPO_NF == cTipoNF

      IncProc(STR0157) //"Estornando Nota Fiscal"

	  IF ALLTRIM(SF1->F1_ESPECIE) == "RCN"
         SF1->(DBSKIP())
         LOOP
      ENDIF
      IF !EMPTY(cNota) .AND. cNota # SF1->F1_CTR_NFC
         SF1->(DBSKIP())
         LOOP
      ENDIF
      lLoop:=.F.
      IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"ESTORNO_NA_NOTA"),)
      IF lLoop
         LOOP
      ENDIF
      
      SD1->(DBSEEK(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

      DO WHILE SD1->(!EOF())                 .AND.;
            SD1->D1_FILIAL == xFilial("SD1") .AND.;
            SD1->D1_DOC    == SF1->F1_DOC    .AND.;
            SD1->D1_SERIE  == SF1->F1_SERIE  .AND.;
            SD1->D1_FORNECE== SF1->F1_FORNECE.AND.;
            SD1->D1_LOJA   == SF1->F1_LOJA

 		  IF ALLTRIM(SD1->D1_ESPECIE) == "RCN"
    	     SD1->(DBSKIP())
          	 LOOP
	      ENDIF
         IF SD1->D1_TIPO_NF # cTipoNF .OR.;
            SD1->D1_CONHEC  # SW6->W6_HAWB
            SD1->(DBSKIP())
            LOOP
         ENDIF

         IF lMV_EASY_SIM
            aItem:={}
            AADD(aItem,{"D1_DOC"    ,SD1->D1_DOC    ,".T."})
            AADD(aItem,{"D1_SERIE"  ,SD1->D1_SERIE  ,".T."})
            AADD(aItem,{"D1_FORNECE",SD1->D1_FORNECE,".T."})
            AADD(aItem,{"D1_LOJA"   ,SD1->D1_LOJA   ,".T."})
            AADD(aItens,ACLONE(aItem))
         ELSE
            SD1->(RecLock("SD1",.F.,.T.))
            SD1->(DBDELETE())
            SD1->(MsUnlock())
         ENDIF
         SD1->(DbSkip())

      ENDDO

      AADD(aNotasDel,SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
      IF !EMPTY(cFornSWN) .AND. cTipoNF = NFE_IMPOSTOS
         AADD(aNotasDel,SF1->F1_DOC+SF1->F1_SERIE+cFornSWN+cLojaSWN)
      ENDIF

      //** Incluso para resolver o problemas causado no padrão devido a alteração feita no Bops 127122
/*    nMas := 0 // AWR 25/08/2008 - While nopado
      IF cTipoNF == NFE_IMPOSTOS// Para actualizar financiero correctamente en la factura de gastos          
         SD1->(DbSetOrder( 1 ))
         SD1->(DbSeek( xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE+SF1->F1_LOJA ))
         While !SD1->( EOF() ) .and. SF1->F1_DOC == SD1->D1_DOC .and. SF1->F1_SERIE == SD1->D1_SERIE .and. SF1->F1_FORNECE == SD1->D1_FORNECE .and. SF1->F1_LOJA == SD1->D1_LOJA
            //nMas := nMas + SD1->D1_VALIMP1 + SD1->D1_VALIMP2 + SD1->D1_VALIMP3 + SD1->D1_VALIMP4 + SD1->D1_VALIMP5 + SD1->D1_VALIMP6 
            aImpostos := DefImposto(SD1->D1_TES)
            For nY:=1 to Len(aImpostos)
                nPosSD1 := SD1->(FieldPos("D1_"+Substr(aImpostos[nY][2],1,7)))
                If nPosSD1 > 0
      				If ( aImpostos[nY][4] $ "S1" ) //Verifica se suma el impuesto al título a pagar (Cpo FC_INCDUPL), Lucas 07/09/2007
	    				nMas := nMas + SD1->(FieldGet(nPosSD1))
		   	    	EndIf
 		    	EndIf
     		Next nY
    		SD1->(DbSkip())
	     EndDo
      EndIf
      //**
*/    
      cChave := xFilial("SE2") + SF1->F1_FORNECE + SF1->F1_LOJA + SWD->WD_SE_DOC + SF1->F1_DOC
      IF lMV_EASY_SIM
         aCab := {}
         AADD(aCab,{"F1_DOC"    ,SF1->F1_DOC    ,".T."})   // NUMERO DA NOTA
         AADD(aCab,{"F1_SERIE"  ,SF1->F1_SERIE  ,".T."})   // SERIE DA NOTA
         AADD(aCab,{"F1_FORNECE",SF1->F1_FORNECE,".T."})   // FORNECEDOR  
         AADD(aCab,{"F1_LOJA"   ,SF1->F1_LOJA   ,".T."})   // LOJA DO FORNECEDOR 
         AADD(aCab,{"F1_TIPODOC",SF1->F1_TIPODOC,".T."})   // NUMERO DA NOTA
         AADD(aCab,{"F1_MOEDA"  ,SF1->F1_MOEDA  ,".T."})   // Moeda
         AADD(aCab,{"F1_TXMOEDA",SF1->F1_TXMOEDA,".T."})   // Taxa da Moeda

         IF lDesClassif
            MSExecAuto({|x,y,z,a| MATA101N(x,y,z,a)},aCab,aItens,5,.F.)// Desclassifica a nota no Compras MicroSiga
         ENDIF
         IF lMSErroAuto           
            MostraErro()
            BREAK
         ENDIF
         MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aItens,5)
         IF lMSErroAuto           
            MostraErro()
            BREAK
         ENDIF
      ELSE
         SF1->(RecLock("SF1",.F.,.T.))
         SF1->(DBDELETE())
         SF1->(MsUnlock())
      ENDIF
   
      //** Incluso para resolver o problemas causado no padrão devido a alteração feita no Bops 127122      
      IF cTipoNF == NFE_IMPOSTOS .AND. lMV_EICNSE2// Para actualizar financiero correctamente en la factura de gastos          
         SE2->(DbSetOrder( 6 ))
         IF nTotImpostos > 0 .AND. SE2->(DbSeek(cChave))
     	    nCobrado = SE2->E2_VALOR - SE2->E2_SALDO
     	    If SE2->E2_SALDO >= (nTotImpostos / If(SE2->E2_TXMOEDA=0, 1,SE2->E2_TXMOEDA ))
    	   	   SE2->(RecLock( 'SE2', .F. ))
        	   SE2->E2_VLCRUZ -= nTotImpostos//nMas - AWR - 25/08/2008
	       	   SE2->E2_VALOR  := SE2->E2_VLCRUZ / If(SE2->E2_TXMOEDA=0, 1,SE2->E2_TXMOEDA )
    	       SE2->E2_SALDO  := SE2->E2_VALOR - nCobrado
	       	   SE2->( MsUnlock() )
            Endif
         Endif
      Endif
      //**
      SF1->(DbSkip())

   ENDDO

   IF !lMSErroAuto
      SW6->(RecLock("SW6",.F.))

      If cTipoNF = NFE_IMPOSTOS

         SW6->W6_NF_ENT  :=""
         //SW6->W6_SE_NF   :=""
         SerieNfId("SW6",1,"W6_SE_NF",CTod("  /  /  "),"","","")

         SW6->W6_DT_NF   :=CTOD("")
         SW6->W6_VL_NF   :=0
         SW6->W6_DT_ENTR :=CTOD("")
      Endif

      IncProc(STR0157) //"Estornando Nota Fiscal"

      IF cTipoNF==NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS

         IF cTipoNF==NFE_DESPESAS

            IF LEN(aNFsCompCtr) > 1 .AND. (I:=ASCAN(aNFsCompCtr,cNota)) # 0
               I:=IF(I=1,2,I-1)
               SW6->W6_NF_COMP:=aNFsComp[I][1]
               //IF(SW6->(FIELDPOS('W6_SE_NFC'))#0,SW6->W6_SE_NFC:=aNFsComp[I][2],)
               SerieNfId("SW6",1,"W6_SE_NFC",,,,aNFsComp[I][2])

               SW6->W6_DT_NFC :=aNFsComp[I][3]
               IF(SW6->(FIELDPOS('W6_VL_NFC'))#0,SW6->W6_VL_NFC :=MDI_OUTR,)
            ELSE  
               SW6->W6_NF_COMP:=""
               //IF(SW6->(FIELDPOS('W6_SE_NFC'))#0,SW6->W6_SE_NFC:="",)
               SerieNfId("SW6",1,"W6_SE_NFC",CTod("  /  /  "),"","","")
               SW6->W6_DT_NFC :=CTOD("")
               IF(SW6->(FIELDPOS('W6_VL_NFC'))#0,SW6->W6_VL_NFC:=0,)
            ENDIF
         ENDIF

         SWD->(DBSETORDER(1))
         SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB))
         DO WHILE SWD->(!EOF())                 .AND.;
                  SWD->WD_FILIAL==xFilial("SWD").AND.;
                  SWD->WD_HAWB  == SW6->W6_HAWB

            IF !LEFT(SWD->WD_DESPESA,1) $ "1,2,9" .AND.;
               SWD->WD_NF_COMP+SWD->WD_SE_NFC+SWD->WD_FORN+SWD->WD_LOJA == cNota

               SWD->(RecLock("SWD",.F.))
               SWD->WD_NF_COMP:=""
               //SWD->WD_SE_NFC :=""
               SerieNfId("SWD",1,"WD_SE_NFC",CTod("  /  /  "),"","","")
               SWD->WD_DT_NFC :=CTOD("")
               SWD->WD_VL_NFC :=0
               SWD->(MsUnlock())

            ENDIF

            SWD->(DBSKIP())
         ENDDO

      ENDIF

      SW6->(MsUnlock())
   
   ENDIF
   
   SWN->(DBSETORDER(3))
   IF SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB+cTipoNF)) .AND. !lMSErroAuto
      DO WHILE SWN->(!EOF())                   .AND.;
               SWN->WN_FILIAL == xFilial("SWN").AND.;
               SWN->WN_HAWB   == SW6->W6_HAWB  .AND.;
               SWN->WN_TIPO_NF== cTipoNF

         IF ASCAN(aNotasDel,SWN->WN_DOC+SWN->WN_SERIE+SWN->WN_FORNECE+SWN->WN_LOJA) = 0
            SWN->(DBSKIP())
            LOOP
         ENDIF

         SWN->(RecLock("SWN",.F.,.T.))
         SWN->(DBDELETE())
         SWN->(MsUnlock())
         SWN->(DbSkip())
      ENDDO        
   ENDIF

   SWW->(DBSETORDER(2))
   IF SWW->(DBSEEK(Xfilial("SWW")+SW6->W6_HAWB+cTipoNF)) .AND. !lMSErroAuto
      DO WHILE !SWW->(EOF())                    .AND.;
                SWW->WW_FILIAL == xFilial("SWW").AND.;
                SWW->WW_HAWB   == SW6->W6_HAWB  .AND.;
                SWW->WW_TIPO_NF== cTipoNF

         IF ASCAN(aNotasDel,SWW->WW_NF_COMP+SWW->WW_SE_NFC+SWW->WW_FORNECE+SWW->WW_LOJA) = 0
            SWW->(DBSKIP())
            LOOP
         ENDIF

         SWW->(RecLock("SWW",.F.,.T.))
         SWW->(DBDELETE())
         SWW->(MsUnlock())
         SWW->(DbSkip())
      ENDDO
   ENDIF

END SEQUENCE

End Transaction

ELSE

   ProcRegua(2)

   EI1->(DBSETORDER(1))
   EI1->(DBSEEK( xFilial("EI1") + SW6->W6_HAWB ))
   IncProc(STR0158) //"Estornando Custo..."

   EI1->(DBEVAL({||++nCont},,{||xFilial("EI1") == EI1->EI1_FILIAL .AND.;
                                EI1->EI1_HAWB  == SW6->W6_HAWB}))

   IncProc(STR0158) //"Estornando Custo..."

   ProcRegua(nCont+3)

Begin Transaction

   EI1->(DBSEEK( xFilial("EI1") + SW6->W6_HAWB ))

   DO WHILE ! EI1->(EOF())                      .AND.;
              EI1->EI1_FILIAL == xFilial("EI1") .AND.;
              EI1->EI1_HAWB   == SW6->W6_HAWB

      IncProc(STR0158) //"Estornando Custo..."

      IF EI1->EI1_TIPO_NF # cTipoNF
         EI1->(DBSKIP())
         LOOP
      ENDIF

      SWW->(DBSEEK(Xfilial("SWW")+EI1->EI1_DOC+EI1->EI1_SERIE+EI1->EI1_FORNEC+EI1->EI1_LOJA))

      DO WHILE ! SWW->(EOF())                      .AND.;
                 SWW->WW_FILIAL  == xFilial("SWW") .AND.;
                 SWW->WW_NF_COMP == EI1->EI1_DOC   .AND.;
                 SWW->WW_SE_NFC  == EI1->EI1_SERIE .AND.;
                 SWW->WW_FORNECE == EI1->EI1_FORNEC.AND.;
                 SWW->WW_LOJA    == EI1->EI1_LOJA

         IF SWW->WW_TIPO_NF # cTipoNF .OR.;
            SWW->WW_HAWB    # SW6->W6_HAWB
            SWW->(DBSKIP())
            LOOP
         ENDIF

         SWW->(RecLock("SWW",.F.,.T.))
         SWW->(DBDELETE())
         SWW->(MsUnlock())
         SWW->(DbSkip())

      ENDDO
  
      EI1->(RecLock("EI1",.F.,.T.))
      EI1->(DBDELETE())
      EI1->(MsUnlock())
      EI1->(DbSkip())

   ENDDO

   EI2->(DBSETORDER(1))
   EI2->(DBSEEK(xFilial("EI2")+SW6->W6_HAWB))
   IncProc(STR0158) //"Estornando Custo..."

   DO WHILE ! EI2->(EOF())                      .AND.;
              EI2->EI2_FILIAL == xFilial("EI2") .AND.;
              EI2->EI2_HAWB   == SW6->W6_HAWB

      IF EI2->EI2_TIPO_NF # cTipoNF
         EI2->(DBSKIP())
         LOOP
      ENDIF
      EI2->(RecLock("EI2",.F.,.T.))
      EI2->(DBDELETE())
      EI2->(MsUnlock())
      EI2->(DbSkip())
   ENDDO

   EI3->(DBSETORDER(1))
   EI3->(DBSEEK( xFilial("EI3") + SW6->W6_HAWB ))
   IncProc(STR0158) //"Estornando Custo..."

   DO WHILE ! EI3->(EOF())                      .AND.;
              EI3->EI3_FILIAL == xFilial("EI3") .AND.;
              EI3->EI3_HAWB   == SW6->W6_HAWB

      IF EI3->EI3_TIPO_NF # cTipoNF
         EI3->(DBSKIP())
         LOOP
      ENDIF

      EI3->(RecLock("EI3",.F.,.T.))
      EI3->(DBDELETE())
      EI3->(MsUnlock())
      EI3->(DbSkip())
   ENDDO

End Transaction

ENDIF

IncProc() //100%

IF lMSErroAuto           
   RETURN .F.
ENDIF

RETURN .T.

*------------------------------------*
Static Function DITrans(nVal)
*------------------------------------*
Return ROUND(nVal,nDecPais)

*---------------------------------------------------------------------*
Function DI156LeEIB(lLer)
*---------------------------------------------------------------------*
IF !lEIB_Processa 
   RETURN .F.
ENDIF   

IF lLer
   IF lSNPeso
      Processa({|| DI156ProcEIB(.F.,lSNPeso)},STR0266) //"Lendo Valores Gravados"
   ENDIF
ELSE
   Processa({|| DI156ProcEIB(.T.)},STR0267) //"Gravando Valores Alterados"
ENDIF

RETURN .T.
*---------------------------------------------------------------------*
Function DI156ProcEIB(lGrava,lSNPeso)
*---------------------------------------------------------------------*
LOCAL nCont:=0, nFatorFrete:=1,lExistiaReg:=.F.,cFil:=xFilial("EIB")

IF !lEIB_Processa .OR. (lGrava .AND. !lAlterouPeso)  
   RETURN .F.
ENDIF   

DBSELECTAREA("EIB")
DBSETORDER(1)             
Work1->(DBSETORDER(1))
lExistiaReg:=EIB->(DBSEEK(xFilial("EIB")+SW6->W6_HAWB))
ProcRegua(Work2->(LASTREC()))
Work2->(DBGOTOP())

DO WHILE Work2->(!EOF())
   
   IncProc(STR0268+Work2->WKTEC) //"Processando NCM: "
   
   IF lGrava
      nCont++
      IF EIB->(DBSEEK(xFilial("EIB")+SW6->W6_HAWB+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
         EIB->(RECLOCK("EIB",.F.))
         EIB->EIB_PESO  :=Work2->WKPESOL    
         EIB->EIB_FILLER:="ALTERADO"          
         EIB->(MSUNLOCK())
      ELSE                                  
         EIB->(RECLOCK("EIB",.T.))          
         EIB->EIB_FILIAL:=xFilial("EIB")    
         EIB->EIB_HAWB  :=SW6->W6_HAWB      
         EIB->EIB_POSIPI:=Work2->WKTEC      
         EIB->EIB_EX_NCM:=Work2->WKEX_NCM
         EIB->EIB_EX_NBM:=Work2->WKEX_NBM
         EIB->EIB_PESO  :=Work2->WKPESOL    
         EIB->EIB_CFO   :=Work2->WK_CFO      
         EIB->EIB_OPERA :=Work2->WK_OPERACA  
         IF(lExistiaReg,EIB->EIB_FILLER:="INCLUIDO",)
         EIB->(MSUNLOCK())                  
      ENDIF                                 
   ELSE                                     
      IF EIB->(DBSEEK(xFilial("EIB")+SW6->W6_HAWB+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
         IF lSNPeso
            MDI_PESO       -= Work2->WKPESOL
            MDI_PESO       += EIB->EIB_PESO
            nFatorFrete    := EIB->EIB_PESO / Work2->WKPESOL
            Work2->WKPESOL := EIB->EIB_PESO
            Work1->(DBSEEK(Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))
            DO WHILE Work1->WK_CFO     ==  Work2->WK_CFO     .AND. ;
                     Work1->WK_OPERACA ==  Work2->WK_OPERACA .AND. ;
                     Work1->WKTEC      ==  Work2->WKTEC      .AND. ;
                     Work1->WKEX_NCM   ==  Work2->WKEX_NCM   .AND. ;
                     Work1->WKEX_NBM   ==  Work2->WKEX_NBM   .AND. Work1->(!EOF())
               Work1->WKPESOL := Work1->WKPESOL * nFatorFrete
               Work1->(DBSKIP())
            ENDDO
         ENDIF
      ENDIF
   ENDIF
   Work2->(DBSKIP())
ENDDO
   
IF lGrava .AND. lExistiaReg
   ProcRegua(nCont)
   EIB->(DBSEEK(cFil+SW6->W6_HAWB))
   DO WHILE EIB->EIB_HAWB  ==SW6->W6_HAWB .AND. EIB->(!EOF()).AND.;
            EIB->EIB_FILIAL==cFil          
            
      EIB->(RECLOCK("EIB",.F.))
      IF !EMPTY(EIB->EIB_FILLER)
         IncProc(STR0268+EIB->EIB_POSIPI) //"Processando NCM: "
         EIB->EIB_FILLER:=""
         EIB->(MSUNLOCK())                  
      ELSE
         EIB->(DBDELETE())                  
             ENDIF
      EIB->(DBSKIP())
   ENDDO
ENDIF

RETURN .T.


*------------------------------*
FUNCTION DI156TabDes(aDespesa)
*------------------------------*
LOCAL nPos := 0

lSair:=.F.
IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"TAB_DESPESAS"),)
IF lSair
   RETURN .T.
ENDIF
SWD->(DBGOTO(Work4->WKRECNO))
nPos:= ASCAN(aDespesa,{|Desp|Desp[01]==SWD->WD_DESPESA .AND.;
                             Desp[07]==SWD->WD_DOCTO   .AND.;
                             Desp[09]==SWD->WD_FORN    .AND.;
                             Desp[10]==SWD->WD_LOJA    .AND.;
                             IF(SWD->(FieldPos("WD_SE_DOC"))>0, Desp[11]==SWD->WD_SE_DOC,.T.) })
                             
IF nPos = 0
   AADD(aDespesa,{SWD->WD_DESPESA,;//1
                  SWD->WD_VALOR_R,;//2
                    Work4->WKFLAG,;//3
                   SWD->(RECNO()),;//4
                 Work4->(RECNO()),;//5
                                0,;//6
                  SWD->WD_DOCTO  ,;//7
                  SWD->WD_DES_ADI,;//8
                  SWD->WD_FORN   ,;//9
                  SWD->WD_LOJA   ,;//10
                  IF(SWD->(FieldPos("WD_SE_DOC"))>0, SWD->WD_SE_DOC,""),; //11                
                  IF(SWD->(FieldPos("WD_TES"))>0, SWD->WD_TES,""),; //12 
                  IF(SWD->(FieldPos("WD_DT_EMIS"))>0,SWD->WD_DT_EMIS,dDataBase)})//13
ELSE 
   aDespesa[nPos,2]+=SWD->WD_VALOR_R
// aDespesa[nPos,6]+=SWD->WD_VALOR_R / IF(BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI)#0,BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI),1)
ENDIF

RETURN .T.

*------------------------------*
FUNCTION DI156Valid(cQual,lSeek)
*------------------------------*
lSeek:=IF(lSeek=NIL,.T.,lSeek)

//JVR - 27/05/10 - Tratamento para preenchimento da Serie da NF.
If cQual == "SERIE" .and. cTipoNF # NFE_IMPOSTOS .and. Empty(cSerieNFE)
   MsgInfo(STR0373)//"Serie não informada"
   Return .F.
EndIf

Return .T.

*----------------------*
Function DI156Pesquisa()
*----------------------*
LOCAL nOpca  :=0, oDlgPeq
LOCAL nRecno :=Work1->(RECNO())
LOCAL cCFO   :=Work1->WK_CFO
LOCAL cOpera :=Work1->WK_OPERACA
LOCAL cTec   :=Work1->WKTEC
LOCAL cNcm   :=Work1->WKEX_NCM
LOCAL cNbm   :=Work1->WKEX_NBM
LOCAL cChave :=''

Private nLin_F := 11
Private cSayCod:= STR0054
Private cItem  :=Work1->WKCOD_I
Private cF3    := "SB1"
Private nCo1   :=04
Private nCo2   :=40
Private nLin   :=05
Private bValida:= {||If(ExistCpo("SB1", cItem),.T.,.F.)}

IF EasyEntryPoint("EICDI156")
   ExecBlock("EICDI156",.F.,.F.,"Tela_Pesq")
ENDIF               

DEFINE MSDIALOG oDlgPeq TITLE STR0258 From 0,0 To nLin_F, 35 OF oMainWnd //"Pesquisa Chave"

@nLin,nCo1 SAY STR0039  SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cCFO   SIZE 50,8 PIXEL

nLin+=12
@nLin,nCo1 SAY STR0329 SIZE 25,8 PIXEL //"Operação"
@nLin,nCo2 MSGET cOpera SIZE 50,8 PIXEL F3 "SWZ"

nLin+=12
@nLin,nCo1 SAY STR0330    SIZE 25,8 PIXEL //"TEC"
@nLin,nCo2 MSGET cTec   SIZE 52,8 PIXEL F3 "SYD"  PICTURE PICT_CPO03//"@R 9999.99.99"

nLin+=12
@nLin,nCo1 SAY STR0331 SIZE 25,8 PIXEL //"EX-NCM"
@nLin,nCo2 MSGET cNcm   SIZE 50,8 PIXEL F3 "WD2"

nLin+=12
@nLin,nCo1 SAY STR0332 SIZE 25,8 PIXEL //"EX-NBM"
@nLin,nCo2 MSGET cNbm   SIZE 50,8 PIXEL F3 "WD3"

nLin+=12
@nLin,nCo1 SAY cSayCod SIZE 25,8 PIXEL //"Cod. Item"
@nLin,nCo2 MSGET cItem  Valid Eval(bValida) SIZE 50,8 PIXEL F3 cF3

@ 10,100 BUTTON STR0111 SIZE 30,11 ACTION (nOpca:=1,oDlgPeq:End()) OF oDlgPeq PIXEL //"&OK"
@ 30,100 BUTTON STR0103 SIZE 30,11 ACTION (nOpca:=0,oDlgPeq:End()) OF oDlgPeq PIXEL //"&Sair"

IF EasyEntryPoint("EICDI156")
   ExecBlock("EICDI156",.F.,.F.,"Say_Gets")
ENDIF               

ACTIVATE MSDIALOG oDlgPeq CENTERED

If nOpcA = 0
   RETURN .F.
Endif                                                               
IF LEN(SB1->B1_POSIPI) > LEN(cTec)
   cTec:=cTec+SPACE(LEN(SB1->B1_POSIPI)-LEN(cTec))
ENDIF
cChave:=cCFO+cOpera+cTec+cNcm+cNbm+cItem
Work1->(DBSETORDER(1))
Work1->(DBSEEK(RTRIM(cChave),.T.))
IF Work1->(EOF())
   Work1->(DBGOTO(nRecno))
ENDIF

RETURN .T.

*--------------------------------------------------------------*
Static Function DI156LerGrvImpostos(cExecute,aGrvImpSD1)
*--------------------------------------------------------------*
LOCAL lGera:=.F.,lGeraDesp:=.F.,aDespTES:={},aTab:={},aTab1:={}
LOCAL cFil:=xFilial("SWW"),aImpGer:={}, T, E, I
SWD->(DBSETORDER(1))
DO CASE

   CASE (cExecute == 'LER_SF1_SWN' .OR. cExecute == 'LEREI2')

       IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
          IF !EMPTY(Work1->WKTES)  //TRP-10/01/08
             lGera := .T.
          ENDIF   
	
          IF SWW->(DBSEEK(xFilial("SWW")+Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+;
                                         Work1->WKLOJA+Work1->WKPO_NUM+Work1->WKPOSICAO))
	       	 DO WHILE ! SWW->(EOF())               .AND.;
       			SWW->WW_FILIAL  == cFil            .AND.;
       			SWW->WW_NF_COMP == Work1->WK_NFE   .AND.;
       			SWW->WW_SE_NFC  == Work1->WK_SE_NFE.AND.;
       			SWW->WW_FORNECE == Work1->WKFORN   .AND.;
       			SWW->WW_LOJA    == Work1->WKLOJA   .AND.;
       			SWW->WW_PO_NUM  == Work1->WKPO_NUM .AND.;
       			SWW->WW_NR_CONT == Work1->WKPOSICAO
			
       			IF SWW->WW_TIPO_NF # cTipoNF .OR.;
       			   SWW->WW_HAWB    # SW6->W6_HAWB
       			   SWW->(DBSKIP())
       			   LOOP
       			ENDIF
       			cCodTES := "" 
       			IF SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB+LEFT(SWW->WW_DESPESA,3))) .AND.;
       			   SWD->(FieldPos("WD_TES")) > 0 .AND. !EMPTY(SWD->WD_TES)
				   cCodTES := SWD->WD_TES       			   
       			ELSEIF SYB->(DbSeek(xFilial("SYB")+LEFT(SWW->WW_DESPESA,3))) .AND. !EMPTY(SYB->YB_TES)
       			   cCodTES := SYB->YB_TES
       			ENDIF
       			IF !EMPTY(cCodTES)
                   IF ASCAN(aDespTES,cCodTES) = 0
       			      AADD (aDespTES,cCodTES)
       			      lGeraDesp:=.T.
       			   ENDIF
       			ENDIF
			    SWW->(DBSKIP())
      	    ENDDO
       	  ENDIF
    
       ELSEIF cTipoNF = NFE_DESPESAS
           IF EMPTY(Work1->WKDESPESA)
              SWW->(DBSEEK(xFilial("SWW")+Work1->WK_NFE+Work1->WK_SE_NFE+Work1->WKFORN+;
                           Work1->WKLOJA+Work1->WKPO_NUM+Work1->WKPOSICAO))
              Work1->WKDESPESA := SWW->WW_DESPESA
           ENDIF
            lGera := .F.      
            cCodTES := ""
            IF !EMPTY(Work1->WKDESPESA)
               IF SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB+LEFT(Work1->WKDESPESA,LEN(SWD->WD_DESPESA)))) .AND.;
                  SWD->(FieldPos("WD_TES")) > 0 .AND. !EMPTY(SWD->WD_TES)
                  lGera   := .T.
                  cCodTES := SWD->WD_TES
               ELSEIF SYB->(DbSeek(xFilial("SYB")+LEFT(Work1->WKDESPESA,LEN(SWD->WD_DESPESA)))) .AND. ;
                  !EMPTY(SYB->YB_TES)
                  lGera := .T.
                  cCodTES := SYB->YB_TES
               ENDIF
            ENDIF
       ENDIF
         
         IF lGera .OR. lGeraDesp
            IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
               aTab:=DI156DFB(Work1->WKTES)  //TRP-10/01/08
            ELSE
               aTab:=DI156DFB(cCodTES)
            ENDIF           
            IF lGrvDespSD1 .AND. ( cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS )
               aDespTES:={}
            ENDIF
            FOR E := 1 TO LEN(aDespTES)
               IF Work1->WKTES # aDespTES[E]  //TRP-10/01/08
                  aTab1:=DI156DFB(aDespTES[E])
                  FOR T := 1 TO LEN(aTab1)
                     AADD(aTab,aTab1[T])
                  NEXT
               ENDIF
            NEXT
            SFB->(DBSETORDER(1))
            aTotais:={}
            IF !EMPTY(aTab)   
               FOR I := 1 TO LEN(aTab)
                   IF Ascan(aImpGer,aTab[I,1]) # 0
                      LOOP
                   ENDIF
                   AADD(aImpGer,aTab[I,1])
                   IF cTipoNF # CUSTO_REAL
                      nCpoALI:=SWN->( FIELDPOS("WN"+aTab[I,2]) )
                      nCpoVLR:=SWN->( FIELDPOS("WN"+aTab[I,3]) )
                      nCpoBAS:=SWN->( FIELDPOS("WN"+aTab[I,4]) )
                   ELSE
                      nCpoALI:=EI2->( FIELDPOS("EI2"+STUFF(aTab[I,2],7,1,"")) )
                      nCpoVLR:=EI2->( FIELDPOS("EI2"+STUFF(aTab[I,3],7,1,"")) )
                      nCpoBAS:=EI2->( FIELDPOS("EI2"+STUFF(aTab[I,4],7,1,"")) )
                   ENDIF                     
                   IF nCpoVLR # 0 .AND. nCpoBAS # 0
                      WorkTES->(DBAPPEND())
                      WorkTES->WKRECNO   :=STRZERO(Work1->(RECNO()),6)
                      WorkTES->WKITEM    :=Work1->WKCOD_I
                      WorkTES->WK_IMP    :=aTab[I,1]
                      SFB->(DBSEEK(xFilial("SFB")+WorkTES->WK_IMP))
	                  WorkTES->WK_IMPDESC:=LEFT(SFB->FB_DESCR,20)
                      IF cTipoNF # CUSTO_REAL
                         WorkTES->WKVALOR  :=SWN->( FIELDGET(nCpoVLR) )
                         WorkTES->WKVALORUS:=WorkTES->WKVALOR / SW6->W6_TX_US_D
                         WorkTES->WKBASE   :=SWN->( FIELDGET(nCpoBAS) )
                         WorkTES->WKBASEUS :=WorkTES->WKBASE / SW6->W6_TX_US_D
                         IF(nCpoALI#0,WorkTES->WKPERC:=SWN->(FIELDGET(nCpoALI)),)
                      ELSE
                         WorkTES->WKVALOR  :=EI2->( FIELDGET(nCpoVLR) )
                         WorkTES->WKVALORUS:=WorkTES->WKVALOR / SW6->W6_TX_US_D
                         WorkTES->WKBASE   :=EI2->( FIELDGET(nCpoBAS) )
                         WorkTES->WKBASEUS :=WorkTES->WKBASE / SW6->W6_TX_US_D
                         IF(nCpoALI#0,WorkTES->WKPERC:=EI2->(FIELDGET(nCpoALI)),)
                      ENDIF                     
                      Work1->WKIMPOSTOS +=DITRANS(WorkTES->WKVALOR)
                      IF (nPos:=ASCAN(aTotais,{|aDesp|aDesp[1]==WorkTES->WK_IMP} )) == 0
                         AADD(aTotais,{WorkTES->WK_IMP,;
                                       DITRANS(WorkTES->WKVALOR),;
                                       DITRANS(WorkTES->WKBASE),} )
                      ELSE
                         aTotais[nPos,2]+=DITRANS(WorkTES->WKVALOR  )//Valor
                         aTotais[nPos,3]+=DITRANS(WorkTES->WKBASE   )//Base
                      ENDIF
                   
                   ENDIF
               NEXT
            ENDIF

            FOR I := 1 TO LEN(aTotais)
               //TOTAL GERAL
               SFB->(DBSEEK(xFilial("SFB")+aTotais[I,1]))
               IF !WorkTES->(DBSEEK( "TOTAIS"+SPACE(LEN(WorkTES->WK_NCM))+aTotais[I,1] ))
                  WorkTES->(DBAPPEND())
                  WorkTES->WKRECNO   :="TOTAIS"
                  WorkTES->WK_IMP    :=aTotais[I,1]
                  WorkTES->WK_IMPDESC:=LEFT(SFB->FB_DESCR,20)
               ENDIF
               WorkTES->WKVALOR   +=aTotais[I,2]
               WorkTES->WKBASE    +=aTotais[I,3]
               WorkTES->WKVALORUS +=aTotais[I,2] / SW6->W6_TX_US_D
               WorkTES->WKBASEUS  +=aTotais[I,3] / SW6->W6_TX_US_D
            NEXT
            nTotImpostos+=Work1->WKIMPOSTOS

         ENDIF
    

   CASE (cExecute == "ACUMULA_SD1_EI3" .OR.;
         cExecute == "GRAVA_SWN_EI2"   .OR.;
         cExecute == "GRAVA_SD1")
         
         cAlias:=IF(cTipoNF # CUSTO_REAL,"SWN","EI2")
         cAlias:=IF(cExecute = "GRAVA_SD1","SD1",cAlias)

         IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"LE_IMP_WORKTES"),)
         IF WorkTES->(DBSEEK( STRZERO(Work1->(RECNO()),6) ))
            DO WHILE !WorkTES->(EOF()) .AND. STRZERO(Work1->(RECNO()),6) == WorkTES->WKRECNO

               IF lGrvDespSD1 .AND. WorkTES->WKID_IMP = "D" .AND. cTipoNF == NFE_IMPOSTOS 
                  WorkTES->(DBSKIP())    
                  LOOP
               ENDIF
            
               IF (nPos:=ASCAN(aValores, {|aImp|aImp[1]==WorkTES->WK_IMP} )) == 0
                  AADD(aValores,{WorkTES->WK_IMP,WorkTES->WKVALOR,WorkTES->WKBASE,WorkTES->WKVLR_CPO,WorkTES->WKBAS_CPO,WorkTES->WKALI_CPO} )
               ELSE
                  aValores[nPos,2]+=DITRANS(WorkTES->WKVALOR,2)//Valor
                  aValores[nPos,3]+=DITRANS(WorkTES->WKBASE ,2)//Base
               ENDIF
               IF cExecute == "GRAVA_SWN_EI2" .OR.;
                  cExecute == "GRAVA_SD1"
                  DI156GrvImpostos(cAlias,aGrvImpSD1)
               ENDIF
               IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"LE_WORKTES"),)
               WorkTES->(DBSKIP())
            ENDDO
         ENDIF

ENDCASE

RETURN .T.

*---------------------------------------------------*
Static Function DI156GrvImpostos(cAlias,aGrvImpSD1)
*---------------------------------------------------*
Local I
IF cAlias = "SD1"

   nCpoVLR:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKVLR_CPO) )
   nCpoBAS:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKBAS_CPO) )
   nCpoALI:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKALI_CPO) )
   
   IF nCpoVLR # 0 .AND. nCpoBAS # 0
      AADD(aGrvImpSD1,{ (cAlias)->(FIELD(nCpoVLR)),WorkTES->WKVALOR,".T."} )
      AADD(aGrvImpSD1,{ (cAlias)->(FIELD(nCpoBAS)),WorkTES->WKBASE ,".T."} )
   ENDIF
   IF nCpoALI # 0
      AADD(aGrvImpSD1,{ (cAlias)->(FIELD(nCpoALI)),WorkTES->WKPERC ,".T."})
   ENDIF

ELSEIF cAlias $ "SWN,EI2"
   IF cTipoNF # CUSTO_REAL
      nCpoVLR:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKVLR_CPO) )
      nCpoBAS:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKBAS_CPO) )
      nCpoALI:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKALI_CPO) )
   ELSE
      nCpoVLR:=(cAlias)->( FIELDPOS(cAlias+STUFF(WorkTES->WKVLR_CPO,7,1,"")) )
      nCpoBAS:=(cAlias)->( FIELDPOS(cAlias+STUFF(WorkTES->WKBAS_CPO,7,1,"")) )
      nCpoALI:=(cAlias)->( FIELDPOS(cAlias+STUFF(WorkTES->WKALI_CPO,7,1,"")) )
   ENDIF                     
   DI156Put(cAlias,WorkTES->WKVALOR,WorkTES->WKBASE,WorkTES->WKPERC)
ELSE
   FOR I := 1 TO LEN(aValores)
      IF cTipoNF # CUSTO_REAL
         nCpoVLR:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+aValores[I,4]) )
         nCpoBAS:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+aValores[I,5]) )
      ELSE
         nCpoVLR:=(cAlias)->( FIELDPOS(cAlias+STUFF(aValores[I,4],7,1,"")) )
         nCpoBAS:=(cAlias)->( FIELDPOS(cAlias+STUFF(aValores[I,5],7,1,"")) )
      ENDIF                       
      nCpoALI:=0
      DI156Put(cAlias,aValores[I,2],aValores[I,3],0)
   NEXT
   aValores:={}
ENDIF

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,"GRV_IMP_SD1"),)
RETURN .T.                       
*----------------------------------------------------*
Static Function DI156Put(cAlias,nValor,nBase,nAliq)
*----------------------------------------------------*
IF nCpoVLR # 0 .AND. nCpoBAS # 0
   (cAlias)->( FIELDPUT(nCpoVLR, ((cAlias)->(FIELDGET(nCpoVLR))+nValor) ) )
   (cAlias)->( FIELDPUT(nCpoBAS, ((cAlias)->(FIELDGET(nCpoBAS))+nBase ) ) )
ENDIF
IF nCpoALI # 0
   (cAlias)->( FIELDPUT(nCpoALI, ((cAlias)->(FIELDGET(nCpoALI))+nAliq ) ) )
ENDIF
RETURN .T.
*------------------------------------------------*
Function DI156DFB(cTes)
*------------------------------------------------*
LOCAL ATAB:={}, cFil:=xFilial("SFC")
SFC->(DBSETORDER(1))
SFC->(DBSEEK(xFilial("SFC")+cTes))
DO WHILE cTes == SFC->FC_TES .AND. SFC->(!EOF()) .AND. cFil == SFC->FC_FILIAL
   IF SFB->(DBSEEK(xFilial("SFB")+SFC->FC_IMPOSTO))
      AADD(ATAB,{ SFC->FC_IMPOSTO,"_ALQIMP"+SFB->FB_CPOLVRO,"_VALIMP"+SFB->FB_CPOLVRO,"_BASIMP"+SFB->FB_CPOLVRO })
   ENDIF
   SFC->(DBSKIP())
ENDDO
RETURN ATAB

*-----------------------------------------*
STATIC Function DI156TelaImpostos(lNCM)
*-----------------------------------------*
LOCAL TB_Campos:={},oMark,nLin:=05
PRIVATE cFiltro:=STRZERO(Work1->(RECNO()),6)
IF lNCM
   cFiltro:="TOTAIS"+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM
ENDIF
aAdd(TB_Campos,{"WK_IMP" ,,STR0311}) //"Impuesto"
aAdd(TB_Campos,{"WK_IMPDESC",,STR0312}) //"Descripción"
IF !lNCM
   aAdd(TB_Campos,{"WKPERC",,STR0316,"@E 999.99"}) //"% Alicuota"
ENDIF
aAdd(TB_Campos,{"WKBASE"   ,,STR0313+' $',PICT15_2})
aAdd(TB_Campos,{"WKBASEUS" ,,STR0313+cMoeDolar,PICT15_2})
aAdd(TB_Campos,{"WKVALOR"  ,,STR0315+' $',PICT15_2})
aAdd(TB_Campos,{"WKVALORUS",,STR0315+cMoeDolar,PICT15_2}) //"Valor"

oMainWnd:ReadClientCoords()    

DO WHILE .T. 

DEFINE MSDIALOG oDlgImp TITLE STR0333+IF(lNCM,STR0334+ALLTRIM(Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM),; //"Impuestos - "###"Arancel: "
  STR0323+Work1->WKCOD_I); //"Item: "
  FROM 000,oMainWnd:nLeft TO 250,oMainWnd:nRight-100 OF oMainWnd PIXEL

  DBSELECTAREA("WorkTES")
  oMark:=MsSelect():New("WorkTES",,,TB_Campos,.F.,cMarca,{nLin,005,nLin+100,(oDlgImp:nClientWidth-4)/2},"DI156Filtra(cFiltro)","DI156Filtra(cFiltro)")
  oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkTES"),.T. }

ACTIVATE DIALOG oDlgImp ON INIT EnchoiceBar(oDlgImp, { || oDlgImp:End() }, { || oDlgImp:End() },,,,,,,.F.) CENTERED

  EXIT
ENDDO

RETURN .T.
*-----------------------------------------*
Function DI156Filtra(cFiltro)
*-----------------------------------------*
RETURN cFiltro

*-----------------------------------------*
STATIC Function DI156CriaWork()
*-----------------------------------------*
PRIVATE nTam:=LEN(SWZ->WZ_CFO)+LEN(SW7->W7_OPERACA)+LEN(SYD->YD_TEC)+LEN(SYD->YD_EX_NCM)+LEN(SYD->YD_EX_NBM)//USADO NO RDMAKE EICDI156("CRIA_WORK")
ProcRegua(5)
aWk1Stru:= {{"WKCOD_I"   ,"C",LEN(SW7->W7_COD_I),0},;
            {"WKFLAG"    ,"C",02,0},;
            {"WKTEC"     ,"C",10,0},;
            {"WKEX_NCM"  ,"C",03,0},;
            {"WKEX_NBM"  ,"C",03,0},;
            {"WKQTDE"    ,"N",18,7},;
            {"WKPRECO"   ,"N",18,7},;
            {"WKDESCR"   ,"C",60,0},;
            {"WKUNI"     ,"C",03,0},;
            {"WKPRUNI"   ,"N",18,7},;
            {"WKVALMERC" ,"N",18,7},;
            {"WKVALMERUS","N",18,7},;
            {"WKRATEIO"  ,"N",18,16},;
            {"WKRATPESO" ,"N",18,16},;
            {"WKRATQTDE" ,"N",18,16},;
            {"WKRATFOB"  ,"N",18,16},;
            {"WKPESOL"   ,"N",AVSX3("B1_PESO",3),AVSX3("B1_PESO",4)},;
            {"WKFOB"     ,"N",18,7},;
            {"WKFOB_R"   ,"N",18,7},;
            {"WKFOB_ORI" ,"N",18,7},;
            {"WKFOBR_ORI","N",18,7},;
            {"WKSEGURO"  ,"N",18,7},;
            {"WKCIF"     ,"N",18,7},;
            {"WKCIF_MOE" ,"N",18,7},;
            {"WKOUT_DESP","N",18,7},;
            {"WKOUT_D_US","N",18,7},;
            {"WKFRETE"   ,"N",18,7},;
            {"WKDTVALID" ,"D",08,0},;
            {"WK_LOTE"   ,"C",LEN(SWN->WN_LOTECTL),0},;
            {"WKSI_NUM"  ,"C",06,2},;
            {"WKPO_NUM"  ,"C",15,0},;
            {"WKPO_SIGA" ,"C",06,0},;
            {"WKINVOICE" ,"C",LEN(SW8->W8_INVOICE),0},;
            {"WKFORN"    ,"C",LEN(SW7->W7_FORN   ),0},;
            {"WKLOJA"    ,"C",LEN(SA2->A2_LOJA   ),0},;
            {"WKFORNITEM","C",LEN(SW7->W7_FORN   ),0},;
            {"WKLOJAITEM","C",LEN(SA2->A2_LOJA   ),0},;
            {"WK_NFE_AUX","C",LEN(SD1->D1_DOC    ),0},;
            {"WK_CFO"    ,"C",LEN(SWZ->WZ_CFO    ),0},;
            {"WK_NFE"    ,"C",LEN(SD1->D1_DOC    ),0},;
            {"WK_SE_NFE" ,"C",AVSX3("D1_SERIE", 3),0},;
            {"WK_CC"     ,"C",05,0},;
            {"WKRECNO"   ,"N",nTamRec,0},;
            {"WKRECNOWK3","N",nTamRec,0},;
            {"WK_DT_NFE" ,"D",08,0},;
            {"WK_OPERACA","C",05,0},;
            {"WKPOSICAO" ,"C",04,0},;
            {"WKSEQNF"   ,"C",AVSX3("D1_ITEM", 3),0},;
            {"WKPOSSIGA" ,"C",LEN(SW3->W3_POSICAO),0},; // RA - 18/11/03 - O.S. 1256/03            {"WKPGI_NUM" ,"C",10,0},;
            {"WKPGI_NUM" ,"C",10,0},;
            {"WK_REG"    ,"N",02,0},;
            {"WKVLR_SELO","N",18,7},;
            {"WKPRECO_F" ,"N",18,7},;
            {"WKDESPESA" ,"C",33,0},;
            {"WKIMPOSTOS","N",18,7},;
            {"WKDESPSUB" ,"N",18,7},;
            {"WKDT_EMIS" ,"D",08,0},;
            {"WKTES"     ,"C",03,0}}  //TRP-10/01/08
                                          
//JVR - 25/05/10
If lAcresDeduc
   aAdd(aWk1Stru, {"WKACRES"   ,"N",18,7} ) 
   aAdd(aWk1Stru, {"WKDEDUC"   ,"N",18,7} )
EndIf

aWk2Stru:=  {{"WKTEC"     ,"C",10,0},;
             {"WKEX_NCM"  ,"C",03,0},;
             {"WKEX_NBM"  ,"C",03,0},;
             {"WKPESOL"   ,"N",AVSX3("B1_PESO",3),AVSX3("B1_PESO",4)},;
             {"WKFOB"     ,"N",18,7},;
             {"WKFOB_R"   ,"N",18,7},;
             {"WKFOB_US"  ,"N",18,7},;
             {"WKFRETE"   ,"N",18,7},;
             {"WKPRECO_F" ,"N",18,7},;
             {"WKFOB_ORI" ,"N",18,7},;
             {"WKFOBR_ORI","N",18,7},;
             {"WKCIF_MOE" ,"N",18,7},;
             {"WKSEGURO"  ,"N",18,7},;
             {"WKCIF"     ,"N",18,7},;
             {"WKOUTRDESP","N",18,7},;
             {"WKOUTRD_US","N",18,7},;
             {"WK_CFO"    ,"C",LEN(SWZ->WZ_CFO),0},;
             {"WK_OPERACA","C",05,0},;
             {"WKRDIFCAMB","N",18,7},;
             {"WKQTDE"    ,"N",18,7},;
             {"WKUDIFMID" ,"N",18,7},;
             {"WKTES"     ,"C",03,0}}  //TRP-10/01/08
//JVR - 25/05/10
If lAcresDeduc
   aAdd(aWk2Stru, {"WKACRES"   ,"N",18,7} ) 
   aAdd(aWk2Stru, {"WKDEDUC"   ,"N",18,7} )
EndIf

aWk3Stru  :={{"WKRECNO"   ,"C",nTamRec,0},;
             {"WKFLAG"    ,"C",02,0},;
             {"WKDESPESA" ,"C",LEN(SWD->WD_DESPESA),0},;
             {"WKDESCR"   ,"C",30,0},;
             {"WKVALOR"   ,"N",18,7},;
             {"WKVALOR_US","N",18,7},;
             {"WK_NF_COMP","C",LEN(SD1->D1_DOC  ),0},;
             {"WK_SE_NFC" ,"C",LEN(SD1->D1_SERIE),0},;
             {"WK_DT_NFC" ,"D",08,0},;
             {"WKPO_NUM"  ,"C",15,0},;
             {"WKPOSICAO" ,"C",04,0},;
             {"WKFORN"    ,"C",LEN(SW7->W7_FORN),0},;
             {"WKLOJA"    ,"C",LEN(SA2->A2_LOJA),0},;
             {"WK_LOTE"   ,"C",LEN(SWN->WN_LOTECTL),0},;
             {"WKPGI_NUM" ,"C",10,0},;
             {"WKTES"     ,"C",LEN(SYB->YB_TES),0} ,;
             {"WKDT_EMIS" ,"D",08,0}}

aWk4Stru:=  {{"WKDESPESA","C",33,0},;
             {"WKFILTRO" ,"C",01,0},;
             {"WKBRANCO" ,"C",01,0},;
             {"WKFLAG"   ,"C",02,0},;
			 {"WKVALOR"  ,"N",18,2},;
			 {"WKDOC"    ,"C",LEN(SWD->WD_NF_COMP),0},;
			 {"WKSEDOC"  ,"C",LEN(SWD->WD_SE_NFC ),0},;
			 {"WKFORN"   ,"C",LEN(SA2->A2_COD    ),0},;
			 {"WKLOJA"   ,"C",LEN(SA2->A2_LOJA   ),0},;
			 {"WKNOTA"   ,"C",LEN(SWD->WD_NF_COMP),0},;
			 {"WKSERIE"  ,"C",LEN(SWD->WD_SE_NFC ),0},;
			 {"WKRECNO"  ,"N",nTamRec,0},;
			 {"WKTES"    ,"C",LEN(SYB->YB_TES   ),0},;
			 {"WKIMPINS" ,"C",LEN(SYB->YB_IMPINS),0},;
			 {"WKBASEIMP","C",01,0},;
			 {"WKBASECUS","C",01,0},;
			 {"WKDT_EMIS","D",08,0}} 

aTesStru  :={{"WKRECNO"   ,"C",06,0},;
             {"WKITEM"    ,"C",LEN(SW7->W7_COD_I),0},;
             {"WK_IMP"    ,"C",03,0},;
             {"WK_NCM"    ,"C",nTam,0},;
             {"WK_IMPDESC","C",20,0},;
             {"WKPERC"    ,"N",06,2},;
             {"WKVALOR"   ,"N",18,7},;
             {"WKVALORUS" ,"N",18,7},;
             {"WKBASE"    ,"N",18,7},;
             {"WKBASEUS"  ,"N",18,7},;
             {"WKVLR_CPO" ,"C",10,0},;
             {"WKALI_CPO" ,"C",10,0},;
             {"WKBAS_CPO" ,"C",10,0},;
             {"WKORIGEM"  ,"C",06,0},;
             {"WKID_IMP"  ,"C",01,0} }
           
// EOS - 06/10/03
IF cPaisLoc # "BRA"                                                                 
   AADD(aWk1Stru,{"WKLOCAL","C",LEN(SC1->C1_LOCAL),0})
ENDIF

//ER - 14/08/2009.
If SWN->(FieldPos("WN_ITEMNF")) > 0
   aAdd(aWk1Stru,{"WK_ITEMNF","C",LEN(SWN->WN_ITEMNF),0})
EndIf

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'ESTRUTURA_WORK'),)

IF EasyEntryPoint("EICDI156")
   ExecBlock("EICDI156",.F.,.F.,"CRIA_WORK")
ENDIF               

//--------------------------------------------  WorkTES
IncProc(STR0335) //"Criando Arquivo 1"
aCampos:={}
aHeader:={}

cFileTES:=E_CriaTrab(,aTesStru,"WorkTES")
IF !USED()
   MSGINFO(OemToAnsi(STR0067),STR0022) //"NÆo foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("WorkTES",cFileTES+TeOrdBagExt(),"WKRECNO+WK_NCM+WK_IMP")

cFileTES1:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("WorkTES",cFileTES1+TeOrdBagExt(),"WKRECNO+WKID_IMP+WK_IMP")
//MFR OSSME-1974 26/12/2018
SET INDEX TO (cFileTES+TeOrdBagExt()),(cFileTES1+TeOrdBagExt())

//--------------------------------------------  Work1
IncProc(STR0336) //"Criando Arquivo 2"
Work1File:=E_CriaTrab(,aWk1Stru,"Work1") 
IF ! USED()
   DI156Final()
   MSGINFO(OemToAnsi(STR0067),STR0022) //"NÆo foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
cIndice:="WK_CFO+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM"
//1
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1File +TeOrdBagExt(),cIndice+"+WKCOD_I+WKPOSICAO")
//2
Work1FileA:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileA+TeOrdBagExt(),"WK_NFE+WK_SE_NFE+WKFORN")
//3
Work1FileB:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileB+TeOrdBagExt(),"WKPO_NUM+WKPOSICAO+WKPGI_NUM+WKINVOICE")
//4
Work1FileC:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileC+TeOrdBagExt(),"WK_NFE+WK_SE_NFE+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKPO_NUM")
//5
Work1FileD:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileD+TeOrdBagExt(),"WKFORN"+ If(EICLoja(), "+WKLOJA", "") +"+WK_CFO+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKCOD_I+WKPOSICAO")//FDR - 21/09/12 - Tratamento de Loja
//6
Work1FileE:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileE+TeOrdBagExt(),"WKFORN+WK_NFE+WK_SE_NFE+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKPO_NUM")
//7
Work1FileF:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileF+TeOrdBagExt(),"WKINVOICE+WKFORN+WKTEC+WKEX_NCM+WKEX_NBM+WKPO_NUM+WKPOSICAO+WKCOD_I+WK_LOTE")
//MFR OSSME-1974 26/12/2018
SET INDEX TO (Work1File+TeOrdBagExt()),(Work1FileA+TeOrdBagExt()), (Work1FileB+TeOrdBagExt()), (Work1FileC+TeOrdBagExt()), (Work1FileD+TeOrdBagExt()), (Work1FileE+TeOrdBagExt()), (Work1FileF+TeOrdBagExt())


//-----------------------------------  Work2
IncProc(STR0337) //"Criando Arquivo 3"
Work2File:=E_CriaTrab(,aWk2Stru,"Work2") 

IF ! USED()
   DI156Final()
   MSGINFO(OemToAnsi(STR0067),STR0022) //"NÆo foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("Work2",Work2File+TeOrdBagExt(),cIndice)

bSeekWk1:=&("{|| Work2->("+cIndice+")}")
bSeekWk2:=&("{|| Work1->("+cIndice+")}")
bWhileWk:=&("{|| Work2->("+cIndice+") == Work1->("+cIndice+")}")

//-----------------------------------  Work3
IncProc(STR0338) //"Criando Arquivo 4"
Work3File:=E_CriaTrab(,aWk3Stru,"Work3") 
IF ! USED()
   DI156Final()
   MsgINFO(OemToAnsi(STR0067),STR0022) //"NÆo foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("Work3",Work3File +TeOrdBagExt(),"WKRECNO+WKDESPESA+WKFORN+WKLOJA+WK_NF_COMP+WK_SE_NFC")

//-----------------------------------  Work4
IncProc(STR0339) //"Criando Arquivo 5"
Work4File:=E_CriaTrab(,aWk4Stru,"Work4") 
IF ! USED()
   MSGINFO(OemToAnsi(STR0067),STR0022) //"NÆo foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("Work4",Work4File+TeOrdBagExt(),"WKFILTRO+WKDOC+WKFORN+WKLOJA+WKDESPESA")

Work4FileA:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work4",Work4FileA+TeOrdBagExt(),"WKFILTRO+WKDESPESA")

Work4FileB:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work4",Work4FileB+TeOrdBagExt(),"WKBRANCO+WKDESPESA")
//MFR OSSME-1974 26/12/2018
SET INDEX TO (Work4File+TeOrdBagExt()),(Work4FileA+TeOrdBagExt()),(Work4FileB+TeOrdBagExt())

aCampos :={"W9_INVOICE","W9_FORN","W9_MOE_FOB","W9_FRETEIN","W9_INLAND","W9_PACKING",;
           "W9_OUTDESP","W9_DESCONT","W9_FOB_TOT","W6_FOB_TOT"}
//FDR - 19/09/12 - Tratamento de Loja           
If EICLoja()
   aAdd(aCampos, "W9_FORLOJ")
EndIf
	           
IF SW8->(FIELDPOS("W8_PRECO_F")) # 0
   AADD(aCampos,"W8_PRECO_F")
ENDIF
                    
// EOB - 03/06/08 - tratamento para os incoterms que contenham seguro (CIF,CIP,DAF,DES,DEQ,DDU e DDP	           
IF lSegInc
   AADD( aCampos, "W9_SEGURO")
ENDIF
cFileWk:=E_CriaTrab(,{{"WKCODIGO","C",1,0}},"Work_Tot")
IF !USED()
   SW6->(MSUnlock())
   Help("",1,"AVG0000802")//"Nao foi possivel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("Work_Tot",cFileWk+TeOrdBagExt(),"WKCODIGO+W9_INVOICE+W9_FORN"+IF(EICLoja(), "+W9_FORLOJ", ""))//FDR - 21/09/12 - Tratamento de Loja

cFileWkA:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work_Tot",cFileWkA+TeOrdBagExt(),"WKCODIGO+W9_MOE_FOB")
//MFR OSSME-1974 26/12/2018
SET INDEX TO (cFileWk+TeOrdBagExt()),(cFileWkA+TeOrdBagExt())

IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'INDICES_WORKS'),)

RETURN .T.

*-------------------------------------------------------------------------------------------------------*
STATIC FUNCTION DI156Final()
*-------------------------------------------------------------------------------------------------------*
DBSELECTAREA("SW6")
IF(EasyEntryPoint('EICDI156'),Execblock('EICDI156',.F.,.F.,'DELETAWORK'),)
SW6->(MSUnlock())           
IF(SELECT("WorkTES")# 0,WorkTES->(E_EraseArq(cFileTES)),)
IF SELECT("Work1")  # 0
   Work1->(E_EraseArq(Work1File,Work1FileA,Work1FileB,Work1FileC))
   //MFR OSSME-1974 26/12/2018
   FErase(Work1FileD+TeOrdBagExt())
   FErase(Work1FileE+TeOrdBagExt())
ENDIF
IF(SELECT("Work2")  # 0,Work2->(E_EraseArq(Work2File)),)
IF(SELECT("Work3")  # 0,Work3->(E_EraseArq(Work3File)),)
IF(SELECT("Work4")  # 0,Work4->(E_EraseArq(Work4File,Work4FileA,Work4FileB)),)
IF(SELECT("Work_Tot")#0,Work_Tot->(E_EraseArq(cFileWk,cFileWkA)) ,)

DBSELECTAREA("SW6")
RETURN .T.
*------------------------------------------------*
Function DI156HelpSWD()
*------------------------------------------------*      
LOCAL cVariavel:=UPPER(ReadVar())
LOCAL oDlg,lOK :=.F.,oMark
LOCAL bAction  :={|| lOK:=.T.,oDlg:End() }

IF ReadVar() # "CNUMNFE"
   RETURN .F.
ENDIF

DBSELECTAREA("Work4")
Work4->(DBSETORDER(3))
DBGOTOP()
cFiltro:="N"
DEFINE MSDIALOG oDlg TITLE STR0345 FROM 0,3 TO 15,27 OF oMainWnd //"Consulta Facturas"

   DBSELECTAREA("Work4")
   oMark:=MsSelect():New("Work4",,,{{"WKDOC",,STR0038}},.F.,cMarca,{2,2,((oDlg:nClientHeight-5)/2)-10,53},"DI156Filtra(cFiltro)","DI156Filtra(cFiltro)") //"Factura"
   oMark:oBrowse:bWhen:={|| DBSELECTAREA("Work4"),.T. }
   oMark:baval:=bAction

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, { || EVAL(bAction) }, { || oDlg:End() },,,,,,,.F.) CENTERED

IF lOK
   cNumNFE:=Work4->WKDOC
ENDIF
Work4->(DBSETORDER(2))
DBSELECTAREA("Work1")

RETURN lOK

*-------------------------------*
FUNCTION DI156Refaz()       
*-------------------------------*
LOCAL aItem:={}, nAux := 1, nAux2
cNaturez:=EasyGParam("MV_NATDESP",,'')
aItens   := {} 
aValores := {}
SYB->(dbSetOrder(1))
SB1->(dbSetOrder(1))

FOR nAux := 1 TO LEN(aDespesa)
    IF LEN(aDespesa[nAux]) > 12
       IF ALLTRIM(aDespesa[nAux,7]) == ALLTRIM(nNFE) .AND. nSerie == aDespesa[nAux,11] ;
                       .AND. cForn  == aDespesa[nAux,9]+aDespesa[nAux,10]
          SWD->(DBGOTO(aDespesa[nAux,4]))
          SYB->(DbSeek(xFilial()+aDespesa[nAux,1]))
          SB1->(DbSeek(xFilial()+SYB->YB_COD_I))

          AADD(aItem,{"D1_COD"    , SB1->B1_COD      ,".T."}) // codigo do produto
          AADD(aItem,{"D1_QUANT"  , 1                ,".T."}) // qtde da despesa - sempre 1 
          AADD(aItem,{"D1_VUNIT"  , aDespesa[nAux,2] ,".T."}) // valor da despesa
          AADD(aItem,{"D1_TOTAL"  , aDespesa[nAux,2] ,".T."}) // valor da despesa
          AADD(aItem,{"D1_TES"    , aDespesa[nAux,12],".T."}) // TES da despesa
          AADD(aItem,{"D1_FORNECE", aDespesa[nAux,9] ,".T."}) // fornecedor
          AADD(aItem,{"D1_LOJA"   , aDespesa[nAux,10],".T."}) // loja
          AADD(aItem,{"D1_DOC"    , aDespesa[nAux,7] ,".T."}) // numero da fatura
          AADD(aItem,{"D1_SERIE"  , aDespesa[nAux,11],".T."}) // serie
          AADD(aItem,{"D1_EMISSAO", aDespesa[nAux,13],".T."}) // dt de emissao
          AADD(aItem,{"D1_DTDIGIT", dDataBase        ,".T."})
          AADD(aItem,{"D1_TIPO"   , "N"              ,".T."})
          AADD(aItem,{"D1_TIPODOC", "10"             ,".T."})
          AADD(aItem,{"D1_TP"     , SB1->B1_TIPO     ,".T."})
          AADD(aItem,{"D1_FORMUL" , cFormPro         ,".T."})
          AADD(aItem,{"D1_CONHEC" , SW6->W6_HAWB     ,".T."})
          AADD(aItem,{"D1_TIPO_NF", cTipoNF          ,".T."}) 
          AADD(aItem,{"D1_ESPECIE", IF(cPaisLoc='BRA','NFE','NF'),".T."})// NOTA FISCAL DE ENTRADA
          AADD(aItem,{"D1_LOCAL"   ,SD1->D1_LOCAL  ,".T."})
          IF SD1->(FIELDPOS("D1_TESDES")) # 0
             AADD(aItem,{"D1_TESDES",aDespesa[nAux,12],".T."})
          ENDIF
          IF SD1->(FIELDPOS("D1_NATUREZ")) # 0 .AND. SWD->(FIELDPOS("WD_NATUREZ")) # 0
             SA2->(DbSeek(xFilial()+aDespesa[nAux,9]+aDespesa[nAux,10]))
             cNaturez:=IF(!EMPTY(SA2->A2_NATUREZ),SA2->A2_NATUREZ,cNaturez)
             cNaturez:=IF(!EMPTY(SWD->WD_NATUREZ),SWD->WD_NATUREZ,cNaturez)
             IF !EMPTY(cNaturez)
                AADD(aItem,{"D1_NATUREZ",cNaturez,".T."})
             ENDIF
          ENDIF
          nTam:=Len(aDespesa[nAux])
          If ValType(aDespesa[nAux,nTam]) == "A"
            FOR nAux2=1 TO Len(aDespesa[nAux,nTam])
               nCpoVLR:=SD1->( FIELDPOS("D1"+SUBSTR(aDespesa[nAux,nTam,nAux2,6],3)) )
               nCpoBAS:=SD1->( FIELDPOS("D1"+SUBSTR(aDespesa[nAux,nTam,nAux2,7],3)) )
               nCpoALI:=SD1->( FIELDPOS("D1_ALQIMP"+RIGHT(ALLTRIM(aDespesa[nAux,nTam,nAux2,7]),1)) ) 
         
               IF nCpoVLR # 0 
                  AADD(aItem,{ SD1->(FIELD(nCpoVLR)), aDespesa[nAux,nTam,nAux2,4],".T."} )
               ENDIF
               IF nCpoBAS # 0
                  AADD(aItem,{ SD1->(FIELD(nCpoBAS)), aDespesa[nAux,nTam,nAux2,3],".T."} )
               ENDIF
               IF nCpoALI # 0
                  AADD(aItem,{ SD1->(FIELD(nCpoALI)), aDespesa[nAux,nTam,nAux2,2],".T."})
               ENDIF    
            
               IF (nPos:=ASCAN(aValores, {|aImp|aImp[1]==aDespesa[nAux,nTam,nAux2,1]} )) == 0
                  AADD(aValores,{aDespesa[nAux,nTam,nAux2,1],;               // imposto
                                 aDespesa[nAux,nTam,nAux2,4],;           // valor do imposto
                                 aDespesa[nAux,nTam,nAux2,3],;           // base do imposto
                                 SUBSTR(aDespesa[nAux,nTam,nAux2,6],3),; // campo p/ grv vlr
                                 SUBSTR(aDespesa[nAux,nTam,nAux2,7],3),; // campo p/ grv base
                                 "_ALQIMP"+RIGHT(ALLTRIM(aDespesa[nAux,nTam,nAux2,7]),1) })  // campo p/ grv aliq
               ELSE
                  aValores[nPos,2]+=aDespesa[nAux,nTam,nAux2,4]  // valor do imposto
                  aValores[nPos,3]+=aDespesa[nAux,nTam,nAux2,3]  // base do imposto
               ENDIF
            NEXT
          EndIf
          AADD(aItens,ACLONE(aItem))
          aItem := {}
       ENDIF
    ENDIF
NEXT   
nValor := MDI_OUTR
nCIF   := MDI_OUTR
nPesol := nFrete := nSeguro := nDespesa := 0
RETURN .T.

*------------------------------*
FUNCTION DI156Lote()
*------------------------------*
LOCAL C,J, N
IF lLote

   IF SIX->(DBSEEK("SWV")) .AND. SWV->(FIELDPOS("WV_INVOICE")) # 0
      SWV->(DBSETORDER(2))
      bSeek :={|| Work1->(WKINVOICE+WKPGI_NUM+WKPO_NUM+WKPOSICAO) }
      bWhile:={|| SWV->WV_INVOICE == Work1->WKINVOICE.And.; 
                  SWV->WV_PGI_NUM == Work1->WKPGI_NUM.And.; 
                  SWV->WV_PO_NUM  == Work1->WKPO_NUM .And.; 
                  SWV->WV_POSICAO == Work1->WKPOSICAO}
   ELSE
      SWV->(DBSETORDER(1))
      bSeek :={|| Work1->(WKPGI_NUM+WKPO_NUM+WK_CC+WKSI_NUM+WKCOD_I+STR(WK_REG,nTamReg)) }
      bWhile:={|| SWV->WV_PGI_NUM == Work1->WKPGI_NUM.And.; 
                  SWV->WV_PO_NUM  == Work1->WKPO_NUM .And.; 
                  SWV->WV_CC      == Work1->WK_CC    .And.; 
                  SWV->WV_SI_NUM  == Work1->WKSI_NUM .And.; 
                  SWV->WV_COD_I   == Work1->WKCOD_I  .And.; 
                  SWV->WV_REG     == Work1->WK_REG}
   ENDIF
   DBSELECTAREA("Work1")

   Work1->(DBGOTOP())
   ProcRegua(LEN(aRecWork1))
   aCampos:={}
   nTamReg:=AVSX3("WV_REG",3)

   AADD(aCampos,"WKPRECO");AADD(aCampos,"WKRECNO"  )
   AADD(aCampos,"WKPRUNI");AADD(aCampos,"WK_REG")

   DBSELECTAREA("Work1")
   FOR C := 1 TO FCOUNT()
       IF VALTYPE(FIELDGET(C)) $ "CDL"
          AADD(aCampos,FIELD(C))
       ENDIF
   NEXT
   
   aDados:=ARRAY(LEN(aCampos))
   aValor:=ARRAY(14,3)
   FOR N := 1 TO LEN(aRecWork1)

      Work1->(dbGoTo(aRecWork1[N]))

      IncProc(STR0113+Work1->WKCOD_I) //"Processando Item: "

      IF SWV->(dbSeek(xFilial()+SW6->W6_HAWB+EVAL(bSeek)))

         nQtde       :=Work1->WKQTDE
         aValor[01,1]:=Work1->WKFOB
         aValor[02,1]:=Work1->WKOUT_DESP
         aValor[03,1]:=Work1->WKOUT_D_US
         aValor[04,1]:=Work1->WKPESOL   // Peso Liquido
         aValor[05,1]:=Work1->WKVALMERC // Preco Total
         aValor[06,1]:=Work1->WKFOB_R   // FOB R$
         aValor[07,1]:=Work1->WKFRETE   // Frete R$
         aValor[08,1]:=Work1->WKSEGURO  // Seguro R$
         aValor[09,1]:=Work1->WKCIF     // CIF
         aValor[10,1]:=Work1->WKRATPESO // Rateio Peso
         aValor[11,1]:=Work1->WKRATEIO  // Rateio FOB
         aValor[12,1]:=Work1->WKFOBR_ORI// FOB R$ original
         aValor[13,1]:=Work1->WKVLR_SELO// Valor do Selo
         aValor[14,1]:=Work1->WKPRECO_F

         AEVAL(aValor,{|t,I|aValor[I,2]:=0})
 
         DI156RatLote()

         SWV->(dbSkip())

         DO While !SWV->(Eof())                    .And.;
                SWV->WV_FILIAL  == xFilial("SWV")  .And.;
                SWV->WV_HAWB    == SW6->W6_HAWB    .And. EVAL(bWhile)
   
   
            For j := 1 To LEN(aCampos)
                aDados[J]:=Work1->(FieldGet(FieldPos(aCampos[j])))
            Next

            Work1->(DBAPPEND())

            For j := 1 To LEN(aCampos)
                IF !EMPTY(aDados[J])
                   Work1->(FieldPut(FieldPos(aCampos[j]),aDados[J]))
                ENDIF
            Next

            IF ASCAN(aRecWork1,Work1->(RECNO())) = 0
               AADD(aRecWork1,Work1->(RECNO()))
            ENDIF

            DI156RatLote()

            SWV->(dbSkip())
   
         EndDo
   
       //Diferenca   :=Total Original- Somatoria
         aValor[01,3]:= aValor[01,1] - aValor[01,2]
         aValor[02,3]:= aValor[02,1] - aValor[02,2]
         aValor[03,3]:= aValor[03,1] - aValor[03,2]
         aValor[04,3]:= aValor[04,1] - aValor[04,2]
         aValor[05,3]:= aValor[05,1] - aValor[05,2]
         aValor[06,3]:= aValor[06,1] - aValor[06,2]
         aValor[07,3]:= aValor[07,1] - aValor[07,2]
         aValor[08,3]:= aValor[08,1] - aValor[08,2]
         aValor[09,3]:= aValor[09,1] - aValor[09,2]
         aValor[10,3]:= aValor[10,1] - aValor[10,2]
         aValor[11,3]:= aValor[11,1] - aValor[11,2]
         aValor[12,3]:= aValor[12,1] - aValor[12,2]
         aValor[13,3]:= aValor[13,1] - aValor[13,2]
         aValor[14,3]:= aValor[14,1] - aValor[14,2]
         
       //Acerto           :=Valor            +Diferenca
         Work1->WKFOB     :=Work1->WKFOB     +aValor[01,3]
         Work1->WKOUT_DESP:=Work1->WKOUT_DESP+aValor[02,3]
         Work1->WKOUT_D_US:=Work1->WKOUT_D_US+aValor[03,3]
         Work1->WKPESOL   :=Work1->WKPESOL   +aValor[04,3]// Peso Liquido
         Work1->WKVALMERC :=Work1->WKVALMERC +aValor[05,3]// Preco Total
         Work1->WKFOB_R   :=Work1->WKFOB_R   +aValor[06,3]// FOB R$
         Work1->WKFRETE   :=Work1->WKFRETE   +aValor[07,3]// Frete R$
         Work1->WKSEGURO  :=Work1->WKSEGURO  +aValor[08,3]// Seguro R$
         Work1->WKCIF     :=Work1->WKCIF     +aValor[09,3]// CIF
         Work1->WKRATPESO :=Work1->WKRATPESO +aValor[10,3]// Rateio Peso
         Work1->WKRATEIO  :=Work1->WKRATEIO  +aValor[11,3]// Rateio FOB
         Work1->WKFOBR_ORI:=Work1->WKFOBR_ORI+aValor[12,3]// FOB R$ original
         Work1->WKVLR_SELO:=Work1->WKVLR_SELO+aValor[13,3]// Valor do Selo
         Work1->WKPRECO_F :=Work1->WKPRECO_F +aValor[14,3]
   
      Endif

   NEXT

ELSE

   Return .F.

ENDIF

Return .T.

*-------------------------------------*
Function DI156RatLote()
*-------------------------------------*

nPerc:=SWV->WV_QTDE/nQtde

Work1->WKQTDE    :=SWV->WV_QTDE
Work1->WK_LOTE   :=SWV->WV_LOTE   
Work1->WKDTVALID :=SWV->WV_DT_VALI
Work1->WKFOB     :=aValor[01,1] * nPerc
Work1->WKOUT_DESP:=aValor[02,1] * nPerc
Work1->WKOUT_D_US:=aValor[03,1] * nPerc
Work1->WKPESOL   :=aValor[04,1] * nPerc// Peso Liquido
Work1->WKVALMERC :=aValor[05,1] * nPerc// Preco Total
Work1->WKFOB_R   :=aValor[06,1] * nPerc// FOB R$
Work1->WKFRETE   :=aValor[07,1] * nPerc// Frete R$
Work1->WKSEGURO  :=aValor[08,1] * nPerc// Seguro R$
Work1->WKCIF     :=aValor[09,1] * nPerc// CIF
Work1->WKRATPESO :=aValor[10,1] * nPerc// Rateio peso
Work1->WKRATEIO  :=aValor[11,1] * nPerc// Rateio FOB
Work1->WKFOBR_ORI:=aValor[12,1] * nPerc// FOB R$ original
Work1->WKVLR_SELO:=aValor[13,1] * nPerc// Valor do Selo
Work1->WKPRECO_F :=aValor[14,1] * nPerc// FOB puro
                               
//Somatoria                    
aValor[01,2]:=aValor[01,2]+Work1->WKFOB
aValor[02,2]:=aValor[02,2]+Work1->WKOUT_DESP
aValor[03,2]:=aValor[03,2]+Work1->WKOUT_D_US
aValor[04,2]:=aValor[04,2]+Work1->WKPESOL   // Peso Liquido
aValor[05,2]:=aValor[05,2]+Work1->WKVALMERC // Preco Total
aValor[06,2]:=aValor[06,2]+Work1->WKFOB_R   // FOB R$
aValor[07,2]:=aValor[07,2]+Work1->WKFRETE   // Frete R$
aValor[08,2]:=aValor[08,2]+Work1->WKSEGURO  // Seguro R$
aValor[09,2]:=aValor[09,2]+Work1->WKCIF     // CIF
aValor[10,2]:=aValor[10,2]+Work1->WKRATPESO // Rateio Peso
aValor[11,2]:=aValor[11,2]+Work1->WKRATEIO  // Rateio FOB
aValor[12,2]:=aValor[12,2]+Work1->WKFOBR_ORI// FOB R$ original
aValor[13,2]:=aValor[13,2]+Work1->WKVLR_SELO// Valor do Selo
aValor[14,2]:=aValor[14,2]+Work1->WKPRECO_F // FOB puro

Return .T.

*-------------------------------------*
Function DI156BASEG()
*-------------------------------------*

lW6_VMINSEG := SW6->(FIELDPOS("W6_VMINSEG")) # 0
	    
IF cTipoNF = '9' .AND. lW6_VMINSEG // Nota de impostos
   IF SW6->W6_VMINSEG == 0
      MDI_SEGURO := (SW6->W6_FOB_TOT + MDI_FRETE + MDespesas) / 100
   ELSE
      MDI_SEGURO := SW6->W6_VMINSEG 
   ENDIF
   
   MDI_SEGURO := MDI_SEGURO/SW6->W6_TX_US_D  //MLS CONVERTE BASE SEGURO PARA DOLAR
	       
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlgAux TITLE "Base de Seguro" FROM 000,oMainWnd:nLeft TO 155,oMainWnd:nRight-475 Of oMainWnd PIXEL
       @1.0,1.5 SAY "Processo:"
       @1.0,9.0 MSGET SW6->W6_HAWB PICTURE "@!" SIZE 60,8 WHEN .F.

       @2.3,1.5 SAY "Total do FOB:" 
       @2.3,9.0 MSGET SW6->W6_FOB_TOT PICTURE PICT15_2 SIZE 60,8 WHEN .F.

       @3.6,1.5 SAY "Base de Seguro ("+cMoeDolar+"):"
       @3.6,9.0 MSGET MDI_SEGURO  PICTURE PICT15_2 SIZE 60,8 //VALID MDI_SEGURO > 0 // mls mdi_seguro//JVR - 25/05/10 - retirado validação
           
       @6.5,15.0 BUTTON "OK" SIZE 38,10 ACTION oDlgAux:End() OF oDlgAux 
           
   ACTIVATE DIALOG oDlgAux CENTERED
  
   MDI_SEGURO := DITRANS(MDI_SEGURO*SW6->W6_TX_US_D,2)  //MLS CONVERTE BASE DE DOLAR PARA MOEDA ATUAL 
ENDIF

Return .T.

*--------------------------------------------------------------------------------------*
//Atencao: Essa funcao eh chamada somente do EICDI156.PRW
Function Di156GrvSD1(cLOCAL,nQTSEGUM,nQUANT,cUNI,cSEGUM,nCIF,xTipoNF,lEICDI156)
*--------------------------------------------------------------------------------------*
Local cPosicao := Work1->WKPOSICAO // RA - 24/10/03 - O.S. 1075/03
LOCAL GRV:=0
DEFAULT lEICDI156 := .T.                                            

//IF lEICDI156 //lEICDI156 eh sempre .T. AWR 17/12/2003
//Notas do EIDI156.PRW
//NFE_DESPESAS  'A'
   IF xTipoNF $ "A"
      nTipoNF:=2//NFE_COMPLEMEN
   ELSE
      nTipoNF:=VAL(xTipoNF)
   ENDIF
//ELSEIF VALTYPE(xTipoNF) = "N"
//   xTipoNF:=STR(xTipoNF,1)
//ENDIF
SC7->(DBSETORDER(1))
// RA - 24/10/03 - O.S. 1075/03 - Inicio
// IF !SC7->(DBSEEK(xFilial()+Work1->WKPO_SIGA+Work1->WKPOSICAO))
//    SC7->(DBSEEK(xFilial()+Work1->WKPO_SIGA+'01  '+Work1->WKPOSICAO))
// ENDIF                   

IF Work1->(fieldpos("WKPOSSIGA")) >0
   If !Empty(Work1->WKPOSSIGA) // DI veio de uma DA
       cPosicao := Work1->WKPOSSIGA
   EndIf
ENDIF   
IF !SC7->(DBSEEK(xFilial()+Work1->WKPO_SIGA+cPosicao))
    SC7->(DBSEEK(xFilial()+Work1->WKPO_SIGA+'01  '+cPosicao))
ENDIF
// RA - 24/10/03 - O.S. 1075/03 - Final
SB1->(DbSeek(xFilial()+Work1->WKCOD_I))
aItem:={}

// AADD(aItem,{"D1_ITEM"        ,Work1->WKPOSICAO ,NIL}) OS 1163/03   -  08/11/2003
//JVR - 08/06/10 - Inclusão do envio do ItemNf
If (cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS)
   AADD(aItem,{"D1_ITEM"        , Work1->WKSEQNF ,NIL})
Else
   If SWN->(FieldPos("WN_ITEMNF")) > 0// .and. cTipoNF = NFE_FOB
      AADD(aItem,{"D1_ITEM"        , Work1->WK_ITEMNF ,NIL})
   EndIf
EndIf

AADD(aItem,{"D1_COD"         ,Work1->WKCOD_I  ,".T."})// codigo do produto
If nTipoNF # 2//NFE_COMPLEMEN
   AADD(aItem,{"D1_PEDIDO"   ,Work1->WKPO_SIGA,".T."})// Pedido de compra
   AADD(aItem,{"D1_ITEMPC"   ,Work1->WKPOSICAO,".T."})// Item do Pedido de compra                                                                          
//   AADD(aItem,{"D1_ITEMPC"   ,SC7->C7_ITEM,".T."})// Item do Pedido de compra                                                                          
Endif	
If !Empty(cUNI)
   AADD(aItem,{"D1_UM"       ,cUNI            ,".T."}) // unidade do produto
Endif	
If !Empty(cSEGUM)
   AADD(aItem,{"D1_SEGUM"    ,cSEGUM          ,".T."})
Endif	
If nTipoNF = 2//NFE_COMPLEMEN
   AADD(aItem,{"D1_VUNIT"    ,Work1->WKVALMERC,".T."}) // valor unitario do item
ELSE
   AADD(aItem,{"D1_QUANT"    ,nQUANT          ,".T."}) // quantidade do produto
   AADD(aItem,{"D1_VUNIT"    ,Work1->WKVALMERC/nQuant,".T."})// valor unitario do item
Endif
AADD(aItem,{"D1_TOTAL"       ,Work1->WKVALMERC ,".T."}) // valor total do item (quantidade * preco)
//TRP-10/01/08
IF cTipoNF = NFE_FOB .OR. cTipoNF = NFE_FRETE .OR. cTipoNF = NFE_SEGURO .OR. cTipoNF = NFE_CIF .OR. cTipoNF = NFE_IMPOSTOS 
   AADD(aItem,{"D1_TES"       ,Work1->WKTES ,".T."})  //TES
ENDIF   
//IF !lEICDI156 //lEICDI156 eh sempre .T. AWR 17/12/2003
////   AADD(aItem,{"D1_VALFRE"   ,Work1->WKFRETE   ,".T."})  // Vlr do Frete  - Campo solicitado por Eduardo da Microsiga 5/6/2003
////   AADD(aItem,{"D1_SEGURO"   ,Work1->WKSEGURO  ,".T."}) // Vlr do Seguro - Campo solicitado por Eduardo da Microsiga 5/6/2003
////   AADD(aItem,{"D1_II"       ,Work1->WKIIVAL   ,NIL})  // Vlr do II     - Campo solicitado por Eduardo da Microsiga 5/6/2003
//   AADD(aItem,{"D1_VALIPI"   ,Work1->WKIPIVAL  ,".T."})  // Vlr do IPI 
//   AADD(aItem,{"D1_VALICM"   ,Work1->WKVL_ICM  ,".T."}) // Vlr do ICMS
//Endif
If !Empty(Work1->WK_CFO)
   AADD(aItem,{"D1_CF"       ,Work1->WK_CFO    ,".T."})  // Classificacao Fiscal                                                
ENDIF
//AADD(aItem,{"D1_RATEIO"    ,'2'              ,".T."})  // O Bruno falou que nao precisa - Rateio por centro de custo "1" Sim ou "2" Nao
//IF !lEICDI156 //lEICDI156 eh sempre .T. AWR 17/12/2003
//   AADD(aItem,{"D1_IPI"      ,Work1->WKIPITX   ,".T."})
//   AADD(aItem,{"D1_PICM"     ,Work1->WKICMS_A  ,".T."})
//ENDIF
AADD(aItem,{"D1_PESO"     ,Work1->WKPESOL   ,".T."})  // Peso Total do Item
AADD(aItem,{"D1_FORNECE"  ,Work1->WKFORN    ,".T."})
AADD(aItem,{"D1_LOJA"     ,Work1->WKLOJA    ,".T."})
AADD(aItem,{"D1_LOCAL"    ,cLOCAL           ,".T."})
AADD(aItem,{"D1_DOC"      ,Work1->WK_NFE    ,".T."})
AADD(aItem,{"D1_SERIE"    ,Work1->WK_SE_NFE ,".T."})
AADD(aItem,{"D1_EMISSAO"  ,Work1->WK_DT_NFE ,".T."})
AADD(aItem,{"D1_DTDIGIT"  ,dDataBase        ,".T."})          
AADD(aItem,{"D1_TIPO"     ,IF(nTipoNF=2,"C" ,"N" ),".T."})//NFE_COMPLEMEN
AADD(aItem,{"D1_TIPODOC"  ,IF(nTipoNF=2,"13","10"),".T."})//NFE_COMPLEMEN
AADD(aItem,{"D1_TP"       ,SB1->B1_TIPO     ,".T."})

If !Empty(cSEGUM)
//   AADD(aItem,{"D1_QTSEGUM"  ,ConvUm(Work1->WKCOD_I,nQUANT,0,2),".T."})
   AADD(aItem,{"D1_QTSEGUM"  ,nQTSEGUM         ,".T."})
Endif	

//IF !lEICDI156 //lEICDI156 eh sempre .T. AWR 17/12/2003
//   AADD(aItem,{"D1_BASEICM"  ,Work1->WKBASEICMS,".T."})
//   AADD(aItem,{"D1_BASEIPI"  ,Work1->WKIPIBASE ,".T."})
//Endif	

AADD(aItem,{"D1_FORMUL"      ,cFormPro         ,".T."})
AADD(aItem,{"D1_TEC"         ,Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM+Work1->WK_OPERACA,".T."})
AADD(aItem,{"D1_CONHEC"      ,SW6->W6_HAWB     ,".T."})
AADD(aItem,{"D1_TIPO_NF"     ,xTipoNF          ,".T."}) 

IF nTipoNF == 2//NFE_COMPLEMEN  // Alfredo Magalhaes - Microsiga
   AADD(aItem,{"D1_NFORI"    ,STRTRAN(SW6->W6_NF_ENT,"...",""),".T."})
   AADD(aItem,{"D1_SERIORI"  ,SW6->W6_SE_NF    ,".T."})
Endif                                    

IF cPaisLoc # "BRA"  // pedido por Eduardo Rieira em mail dia 10/07/03 -rhp
  AADD(aItem,{"D1_ESPECIE"     ,'NF',".T."})// NOTA FISCAL DE ENTRADA
ENDIF

IF lEICDI156 .AND. SD1->(FIELDPOS("D1_NATUREZ")) # 0 .AND. TYPE("cNaturez") = "C"
   IF !EMPTY(cNaturez)
      AADD(aItem,{"D1_NATUREZ",cNaturez,,".T."})
   ENDIF
ENDIF

//TRP - 06/07/2012 - Vide Chamado 093906 - Origem sempre da tabela SYT. 
SYT->(DBSETORDER(1))
IF SYT->(dBSeek(xFilial("SYT")+SW6->W6_IMPORT))
   IF cPaisLoc = "ARG"
      AADD(aItem,{"D1_PROVENT"     ,Alltrim(SYT->YT_ESTADO)       ,".T."})
   ENDIF  
ENDIF

IF lLote .AND. SD1->(FIELDPOS("D1_LOTECTL")) # 0 .AND. SD1->(FIELDPOS("D1_DTVALID")) # 0
   SB1->(DBSEEK(xFilial("SB1")+Work1->WKCOD_I))
   IF SB1->B1_RASTRO $ "SL" .AND. !EMPTY(Work1->WK_LOTE)
      AADD(aItem,{"D1_LOTECTL",Work1->WK_LOTE  ,})
       IF !EMPTY(Work1->WKDTVALID)
          AADD(aItem,{"D1_DTVALID",Work1->WKDTVALID,})
       ENDIF
   ENDIF
ENDIF

//IF !lEICDI156 .AND. Work1->(FIELDPOS("WKDESPICM")) # 0 //lEICDI156 eh sempre .T. AWR 17/12/2003
//   AADD(aItem,{"D1_DESPESA",Work1->WKDESPICM,})
//ENDIF

// EOS - 06/10/03
IF cPaisLoc # "BRA" .AND. SWN->(FIELDPOS('WN_LOCAL')) # 0
   // No D1_LOCAL ja vem gravado o C1_LOCAL e no WKLOCAL ja vem o W7_LOCAL
   // Prioridade 1o. - SW7, 2o. - SC1, 3o. - SB1
   IF (nPosLoc:=ASCAN(aItem,{|A| A[1] == "D1_LOCAL"})) # 0
      IF !EMPTY(Work1->WKLOCAL)//SW7
         aItem[nPosLoc,2]:=Work1->WKLOCAL
      ELSEIF EMPTY(SWN->WN_LOCAL)//SC1
         SB1->(DbSeek(xFilial("SB1")+Work1->WKCOD_I))
         aItem[nPosLoc,2]:=SB1->B1_LOCPAD
      ENDIF
   ENDIF
ENDIF

// Nopado por TRP em 03/10/07, pois esse tratamento retira os valores das despesas do cálculo do valor FOB.  
//** Incluso no padrão conforme Bops 128398,Lucas 16/08/07 (Flete para dos Invoices).   
/*If cTipoNF = NFE_FOB    
  	dbselectarea("SW8")
  	dbsetorder(6)
  	dbseek(xfilial("SW8")+SW6->W6_HAWB+Work1->WKINVOICE+Work1->WKPO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM)
 	if Found()
  		nW8Fob:=SW8->W8_QTDE*SW8->W8_PRECO
	endif
    dbselectarea("SW9")
    dbsetorder(1)
  	dbseek(xfilial("SW9")+Work1->WKINVOICE+Work1->WKFORN)
  	if Found()
  		nW9Fob:=SW9->W9_FOB_TOT
  		nW9Fre:=SW9->W9_FRETEIN
  		nTxFob:=SW9->W9_TX_FOB
 	endif
  	nRatMl:=nW9Fre/nW9Fob*nW8Fob
	nRatPesos:=Round(nRatMl*nTxFob,0)

	//Rateio de las Facturas de Fretes em SD1 -> aItens
 	//nPosVunit	:=	Ascan(aItem,{|x| Alltrim(x[1]) == 'D1_VUNIT'})
	//nPosTotal	:=	Ascan(aItem,{|x| Alltrim(x[1]) == 'D1_TOTAL'})
	//aItem[nPosTotal,2]:=Round(SW8->W8_PRECO_R,0)+nRatPesos
	//aItem[nPosVunit,2]:=aItem[nPosTotal,2]/nQuant
    
	Work1->WKVALMERC := Round(SW8->W8_PRECO_R,0)+nRatPesos
	Work1->WKPRECO := nW8Fob+nRatMl
	Work1->WKPRUNI := Work1->WKVALMERC/SW8->W8_QTDE
	Work1->WKCIF := Work1->WKVALMERC
	Work1->WKFOB_R := Work1->WKVALMERC
endif */
//**

//** Incluso no padrão conforme Bops 128423 // HONEYWELL
//AWR - 06/09/2007 - Acrescentei o Teste do Pais e do Indice
if cPaisLoc = "CHI" .AND. SIX->(DBSEEK("SF38")) .AND. (cTipoNF = NFE_FOB .or. cTipoNF = NFE_IMPOSTOS .or. cTipoNF = NFE_DESPESAS)// para actualizar fecha de facturas
	dbselectarea("SD1")
	//dbsetorder( 1 )
	//sd1->(dbseek( xfilial("sd1") + sf1->f1_remito + "ri " + sf1->f1_fornece+sf1->f1_loja ))
	dbsetorder( 8 )
	SD1->(dbgotop())
	SD1->( dbseek(xfilial("SD1")+SW6->W6_HAWB)) //+ ctiponf))
	if found()
		while !eof() .and. (xfilial("SD1")+SW6->W6_HAWB) == (SD1->D1_FILIAL+SD1->D1_CONHEC)
			if alltrim(SD1->D1_ESPECIE)="NF"
				dbselectarea("SF3")
				dbsetorder(8)
    	
				SF3->(dbseek(xfilial("SF3")+dtos(SD1->D1_DTDIGIT)+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TES))
				if found()				
					reclock("SF3",.f.)
					replace F3_ENTRADA with SD1->D1_EMISSAO
					msunlock()
				endif
				dbselectarea("SF1")
				dbsetorder(5)
				SF1->(dbseek(xfilial("SF1")+SD1->D1_CONHEC+SD1->D1_TIPO_NF+SD1->D1_DOC+SD1->D1_SERIE))
				if found()
					Reclock("SF1",.f.)
					replace F1_EMISSAO with SD1->D1_EMISSAO
					msunlock()
				endif
			endif
			sd1->(dbskip())
		enddo
	endif
endif
//**


//IF(EasyEntryPoint("EICDI154"),Execblock("EICDI154",.F.,.F.,'GRAVACAO_SD1'),)
//Chamada EICDI554 por que essa funcao eh chamada do EIDI554.PRW - AWR 31/08/2002
//IF(EasyEntryPoint("EICDI554"),Execblock("EICDI554",.F.,.F.,'GRAVACAO_SD1'),)
//Chamada EICDI156 por que essa funcao eh chamada do EIDI156.PRW - AWR 14/11/2002
IF(EasyEntryPoint("EICDI156"),Execblock("EICDI156",.F.,.F.,'GRAVACAO_SD1'),)

AADD(aItens,ACLONE(aItem))

aAdd(aItensNF,{Work1->(WK_NFE+WK_SE_NFE+WKFORN+WKLOJA+WKPO_SIGA+WKCOD_I+WKPOSICAO),Len(aItens)})

RETURN .T.

*--------------------------------------------------------------------------------------*
Function Di156COND() //MLS 17/06/2004
*--------------------------------------------------------------------------------------*
LOCAL NW6RECNO    := SW6->(RECNO())
LOCAL cHAWB       := SW6->W6_HAWB
LOCAL cDINUM      := SW6->W6_DI_NUM
PRIVATE lAzul     :=.F.
PRIVATE lFOB      :=.F.//5
PRIVATE lFRETE    :=.F.//6
PRIVATE lSEGURO   :=.F.//7
PRIVATE lCIF      :=.F.//8
PRIVATE lImpostos :=.F.//9
PRIVATE lDESPESAS :=.T.//A
PRIVATE cCOR      :=""
SW9->(DBSETORDER(3))
IF Empty(cDINUM)
   lAzul :=.T.
ELSEIF SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))
   DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
	                              SW9->W9_HAWB == SW6->W6_HAWB
	  IF EMPTY(SW9->W9_TX_FOB)
         lAzul :=.T.
         EXIT
	  ENDIF

	  IF SW9->(FIELDPOS("W9_TUDO_OK")) # 0 .AND. SW9->W9_TUDO_OK = "2"
         lAzul :=.T.
         EXIT
	  ENDIF

	  SW9->(DBSKIP())
   ENDDO
ENDIF
SW9->(DBSETORDER(1))

IF lAzul

   cCOR :="3"  //AZUL  VAZIO NUMERO

ELSE
   SF1->(DBSETORDER(5))
   IF SF1->(DBSEEK(xFILIAL("SF1")+cHAWB+"5"))
      lFOB:= .T.
   ENDIF   

   IF SF1->(DBSEEK(xFILIAL("SF1")+cHAWB+"6"))
      lFRETE:= .T.
   ENDIF   

   IF SF1->(DBSEEK(xFILIAL("SF1")+cHAWB+"7"))
      lSEGURO:= .T.
   ENDIF   

   IF SF1->(DBSEEK(xFILIAL("SF1")+cHAWB+"8"))
      lCIF:= .T.
   ENDIF   

   IF SF1->(DBSEEK(xFILIAL("SF1")+cHAWB+"9"))
      lImpostos:= .T.
   ENDIF   

   SF2->(DBSETORDER(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
   //SF1->(DBSETORDER(6))
   SWD->(DBSETORDER(1))
   IF SWD->(DBSEEK(xFILIAL("SWD")+cHAWB))
      DO WHILE  SWD->WD_HAWB==CHAWB .AND. !SWD->(EOF())
            
         IF !LEFT(SWD->WD_DESPESA,1) $ "1,2,9"
               
            IF EMPTY(SWD->WD_NF_COMP+SWD->WD_SE_NFC)
               lDESPESAS :=.F.
               EXIT
            ENDIF      
            
         ENDIF
         SWD->(DBSKIP())
      ENDDO   
   ENDIF   
   SF1->(DBSETORDER(1))
                                        
   IF(EasyEntryPoint("EICDI156"),Execblock("EICDI156",.F.,.F.,"ALTERA_STATUS_1"),)
    
   IF (lFOB .AND. lFRETE .AND. lSEGURO .AND. lImpostos .AND. lDESPESAS) .OR.;
      (lCIF .AND. lImpostos .AND. lDESPESAS)

      cCOR :="1" //VERMELHO    PROCESSO POSSUI TODAS AS NOTAS
   
   ELSE
   
      cCOR :="2" //VERDE   PROCESSO POSSUI NOTAS PENDENTE
   
   ENDIF   
   
ENDIF   

IF(EasyEntryPoint("EICDI156"),Execblock("EICDI156",.F.,.F.,"ALTERA_STATUS_2"),)

IF cCOR <> SW6->W6_STATUS
   SW6->(RECLOCK("SW6",.F.))
   SW6->W6_STATUS := CCOR
   SW6->(MSUNLOCK())
ENDIF

SW6->(DBGOTO(NW6RECNO))   

RETURN .T.

*--------------------------------------------------------------------------------------*
Function DI156Legend() //MLS 17/06/2004
*--------------------------------------------------------------------------------------*

BrwLegenda(cCadastro,STR0355,{	{"ENABLE"   ,STR0356}    ,;  //Verde
                                {"DISABLE"  ,STR0357}    ,;  //Vermelho
                                {"BR_AZUL"  ,STR0358}} )     //Azul
Return .T.

*---------------------------------------*
Static Function DI156TOTAIS() //MLS
*---------------------------------------*
LOCAL nCo1:=0.5, nCo2:=5, nCo3:=12.5, nCo4:=18.0,nLin:=0.5
LOCAL nTotNFE:= nVlTota:= 0, oDlgImp
LOCAL TB_CamposTes:={},oMarkTot

LOCAL nTOTsw9  := 0
LOCAL nTFrete  := 0
LOCAL nTBaseg  := 0
LOCAL nTFOBUSD := 0

PRIVATE nOutDesp:=nFobR:=nFrete:=nSeguro:=nDolar:=nDIFOB:=0,lSair:=.F.
PRIVATE cFiltro:="TOTAIS"+SPACE(LEN(WorkTES->WK_NCM))

IF EasyEntryPoint('EICDI156')
   Execblock('EICDI156',.F.,.F.,'TELA_TOTAIS')
   IF lSair
      RETURN .T.
   ENDIF
ENDIF

aAdd(TB_CamposTes,{"WK_IMP"    ,,STR0311}) //"Impuesto"
aAdd(TB_CamposTes,{"WK_IMPDESC",,STR0312}) //"Descripción"
aAdd(TB_CamposTes,{"WKBASE"    ,,STR0313+' $',PICT15_2}) //"Base "
aAdd(TB_CamposTes,{"WKBASEUS"  ,,STR0313+' ('+cMoeDolar+')' ,PICT15_2}) //"Base "
aAdd(TB_CamposTes,{"WKVALOR"   ,,STR0315+' $',PICT15_2}) //"Valor "
aAdd(TB_CamposTes,{"WKVALORUS" ,,STR0315+' ('+cMoeDolar+')',PICT15_2}) //"Valor "

Processa({|| DI156Soma()},OemToAnsi(STR0114)) //"Calculando Totais"

SW9->(DBSETORDER(3))
SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))
nSW9 := 0
DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                            SW9->W9_HAWB == SW6->W6_HAWB 
   nSW9 += DI600RetVal("TOT_INV,SEM_FOB", "TAB", .T., .T.)  // EOB - 03/06/08 - chamada da função DI600RetVal                            

   SW9->(DBSKIP())

ENDDO	    

nTOTsw9  := (nSW9/SW6->W6_TX_US_D)

nTFrete  := (nFrete/SW6->W6_TX_US_D)

nTBaseg  := (SW6->W6_VMINSEG*SW6->W6_TX_SEG)/SW6->W6_TX_US_D

nTFOBUSD := (nTFOBUSD/SW6->W6_TX_US_D)

nVlTota  := DITRANS((nDIFOB+nTotImpostos))

oMainWnd:ReadClientCoords()
DEFINE MSDIALOG oDlgImp TITLE STR0115 ;
       FROM oMainWnd:nTop+060,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 PIXEL

@ nLin,nLin TO nLin+080,249       PIXEL
@ nLin,250  TO nLin+080,260+nSize PIXEL

@ nLin   ,nCo1 SAY STR0042+" ("+EasyGParam("MV_SIMB1",,"R$")+")" //"FOB"
@ nLin+=1,nCo1 SAY STR0043+" ("+EasyGParam("MV_SIMB1",,"R$")+")" //"Frete"
@ nLin+=1,nCo1 SAY STR0044+" ("+EasyGParam("MV_SIMB1",,"R$")+")" //"Seguro"
@ nLin+=1,nCo1 SAY STR0315+' ('+cMoeDolar+')' //"Valor "
nLin:=0.5
@ nLin   ,nCo2 GET nFobR   WHEN .F. PICTURE PICT15_2 SIZE 55,8
@ nLin+=1,nCo2 GET nFrete  WHEN .F. PICTURE PICT15_2 SIZE 55,8
@ nLin+=1,nCo2 GET nSeguro WHEN .F. PICTURE PICT15_2 SIZE 55,8
@ nLin+=1,nCo2 GET nDolar  WHEN .F. PICTURE PICT15_2 SIZE 55,8
//nLin:=0.5
//@ nLin   ,nCo3 SAY STR0058 //"Vl. Mercadoria"
//@ nLin+=1,nCo3 SAY STR0303 //"Impuestos"
//@ nLin+=1,nCo3 SAY STR0082 //"Total Geral"
//IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
//   @ nLin+=1,nCo3 SAY STR0053 //"Outras Despesas"
//ENDIF
//nLin:=0.5
//@ nLin   ,nCo4 GET nDIFOB       WHEN .F. PICTURE PICT15_2 SIZE 55,8 
//@ nLin+=1,nCo4 GET nTotImpostos WHEN .F. PICTURE PICT15_2 SIZE 55,8 
//@ nLin+=1,nCo4 GET nVlTota      WHEN .F. PICTURE PICT15_2 SIZE 55,8 
//IF cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
//   @ nLin+=1,nCo4 GET nOutDesp  WHEN .F. PICTURE PICT15_2 SIZE 55,8 
//ENDIF

nLin:=0.5
@ nLin   ,nCo3 SAY "FOB ("      +cMoeDolar+")"
@ nLin+=1,nCo3 SAY "Ajuste ("   +cMoeDolar+")"
@ nLin+=1,nCo3 SAY "Flete ("    +cMoeDolar+")"
@ nLin+=1,nCo3 SAY "Base Seg. ("+cMoeDolar+")"
nLin:=0.5
@ nLin   ,nCo4 GET nTFOBUSD  WHEN .F. PICTURE PICT15_2 SIZE 55,8 
@ nLin+=1,nCo4 GET nTOTsw9   WHEN .F. PICTURE PICT15_2 SIZE 55,8 
@ nLin+=1,nCo4 GET nTFrete   WHEN .F. PICTURE PICT15_2 SIZE 55,8 
@ nLin+=1,nCo4 GET nTBaseg   WHEN .F. PICTURE PICT15_2 SIZE 55,8 

nLin:=05
@ nLin,nCoL5 BUTTON STR0103 SIZE nSize,12 ACTION (nOpca:=0,oDlgImp:End()) OF oDlgImp PIXEL //"&Sair"
nLin+=12
@ nLin,nCoL5 BUTTON "&Invoices" SIZE nSize,12 ACTION (DI156Invoices()) OF oDlgImp PIXEL  //"&Invoices
nLin+=12
@ nLin,nCoL5 BUTTON "A&juste"   SIZE nSize,12 ACTION (DI156Ajuste()) OF oDlgImp PIXEL  //"&Ajuste"
nLin+=65

IF cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
   DBSELECTAREA("WorkTES")
   oMarkTot:=MsSelect():New("WorkTES",,,TB_CamposTes,.F.,cMarca,{103,1,(oDlgImp:nClientHeight-6)/2,(oDlgImp:nClientWidth-4)/2},"DI156Filtra(cFiltro)","DI156Filtra(cFiltro)")
   oMarkTot:oBrowse:bWhen:={|| DBSELECTAREA("WorkTES"),.T. }
   oMarkTot:oBrowse:Align:=CONTROL_ALIGN_BOTTOM
ELSE
   oDlgImp:nHeight:=160
   oDlgImp:nWidth :=oDlgImp:nWidth - 60
ENDIF

ACTIVATE DIALOG oDlgImp //CENTERED

RETURN NIL

*-----------------------------------------*
STATIC Function DI156Ajuste()//mls
*-----------------------------------------*
LOCAL TB_CampAJ:={},oMark,nLin:=05
Local lExistEZZ:= SX2->(dbSeek("EZZ"))
LOCAL oDLGAJ
LOCAL cFileaj  :=""
LOCAL aworkaj  :={{ "WKINVOICE","C",15,0},;
                  {"WKFRETEIN" ,"N",15,2},;
                  {"WKINLAND"  ,"N",15,2},;
                  {"WKOUTDESP" ,"N",15,2},;
                  {"WKPACKING" ,"N",15,2},;
                  {"WKSEGURO"  ,"N",15,2},;
                  {"WKDESCONT" ,"N",15,2} }

aAdd(TB_CampAJ,{"WKINVOICE",,"Invoice" })
aAdd(TB_CampAJ,{"WKINLAND" ,,"Inland (" +cMoeDolar+")",PICT15_2 })
aAdd(TB_CampAJ,{"WKPACKING",,"Packing ("+cMoeDolar+")",PICT15_2 })
aAdd(TB_CampAJ,{"WKFRETEIN",,"FleteIN ("+cMoeDolar+")",PICT15_2 })
aAdd(TB_CampAJ,{"WKSEGURO" ,,"Seguro (" +cMoeDolar+")",PICT15_2 })
aAdd(TB_CampAJ,{"WKDESCONT",,"Descont ("+cMoeDolar+")",PICT15_2 })
aAdd(TB_CampAJ,{"WKOUTDESP",,"OutGast ("+cMoeDolar+")",PICT15_2 })

cFileaj:=E_CriaTrab(,aworkaj,"Workaj")

IF !USED()
   MSGINFO(OemToAnsi(STR0067),STR0022) //"NÆo foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("Workaj",cFileaj+TeOrdBagExt(),"WKINVOICE")
//MFR OSSME-1974 26/12/2018
SET INDEX TO (cFileaj+TeOrdBagExt())

SW9->(DBSETORDER(3))
SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))

DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                              SW9->W9_HAWB   == SW6->W6_HAWB
   WorkAJ->(DBAPPEND())

   WorkAJ->WKINVOICE := SW9->W9_INVOICE 
   WorkAJ->WKFRETEIN := (SW9->W9_FRETEIN*SW9->W9_TX_FOB) / SW6->W6_TX_US_D
   WorkAJ->WKINLAND  := (SW9->W9_INLAND *SW9->W9_TX_FOB) / SW6->W6_TX_US_D
   WorkAJ->WKOUTDESP := (SW9->W9_OUTDESP*SW9->W9_TX_FOB) / SW6->W6_TX_US_D
   WorkAJ->WKPACKING := (SW9->W9_PACKING*SW9->W9_TX_FOB) / SW6->W6_TX_US_D
   WorkAJ->WKSEGURO  := (SW9->W9_SEGURO *SW9->W9_TX_FOB) / SW6->W6_TX_US_D
   WorkAJ->WKDESCONT := (SW9->W9_DESCONT*SW9->W9_TX_FOB) / SW6->W6_TX_US_D

   SW9->(DBSKIP())
   
ENDDO

IF lExistEZZ
   cFilEZZ:=xfilial("EZZ")
   EZZ->(DBSETORDER(1))
   EZZ->(DbSeek(cFilEZZ+SW6->W6_HAWB))

   DO WHILE !EZZ->(EOF()) .AND. EZZ->EZZ_FILIAL == cFilEZZ .AND.;
                                EZZ->EZZ_HAWB   == SW6->W6_HAWB
      WorkAJ->(DBAPPEND())

      WorkAJ->WKINVOICE := EZZ->EZZ_INVOIC 
      WorkAJ->WKFRETEIN := (EZZ->EZZ_FRETEI*EZZ->EZZ_TX_FOB) / SW6->W6_TX_US_D
      WorkAJ->WKINLAND  := (EZZ->EZZ_INLAND*EZZ->EZZ_TX_FOB) / SW6->W6_TX_US_D
      WorkAJ->WKOUTDESP := (EZZ->EZZ_OUTDES*EZZ->EZZ_TX_FOB) / SW6->W6_TX_US_D
      WorkAJ->WKPACKING := (EZZ->EZZ_PACKIN*EZZ->EZZ_TX_FOB) / SW6->W6_TX_US_D
      WorkAJ->WKDESCONT := (EZZ->EZZ_DESCON*EZZ->EZZ_TX_FOB) / SW6->W6_TX_US_D
      IF lSegInc
         WorkAJ->WKSEGURO  := (EZZ->EZZ_SEGURO*EZZ->EZZ_TX_FOB) / SW6->W6_TX_US_D
      ENDIF

      EZZ->(DBSKIP())
   
   ENDDO
ENDIF
oMainWnd:ReadClientCoords()    

DEFINE MSDIALOG oDlgAJ TITLE STR0365 FROM 000,oMainWnd:nLeft TO 250,oMainWnd:nRight-100 OF oMainWnd PIXEL//Outros Gastos/otros Gastos/other Taxes

  DBSELECTAREA("WorkAJ")
  WorkAJ->(dBGoTop())                         
  oMark:=MsSelect():New("WorkAJ",,,TB_CampAJ,.F.,"XX" ,{nLin,005,nLin+100,(oDlgAJ:nClientWidth-4)/2})
  oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkAJ"),.T. }

ACTIVATE DIALOG oDlgAJ ON INIT EnchoiceBar(oDlgAJ, { || oDlgAJ:End() }, { || oDlgAJ:End() },,,,,,,.F.) CENTERED

WorkAJ->(E_EraseArq(cFileaj))

RETURN

*-----------------------------------------*
STATIC Function DI156Invoices()//mls
*-----------------------------------------*
LOCAL TB_CampIV:={},oMark,nLin:=05
LOCAL cFileIV  :=""
LOCAL oDLGIV
LOCAL aworkIV  :={{ "WKINVOICE" ,"C",15,0},;
                  {"WKMOEDA"    ,"C",03,0},;
                  {"WKVLRFOB"   ,"N",15,2},;                  
                  {"WKINCOTER"  ,"C",03,0}}

aAdd(TB_CampIV,{"WKINVOICE",,"Invoice" })
aAdd(TB_CampIV,{"WKMOEDA"  ,,"Moeda  " })
aAdd(TB_CampIV,{"WKVLRFOB" ,,"Vlr.FOB ("+cMoeDolar+")",PICT15_2 })
aAdd(TB_CampIV,{"WKINCOTER",,"Incoterms" })

cFileIV:=E_CriaTrab(,aworkIV,"WorkIV")

IF !USED()
   MSGINFO(OemToAnsi(STR0067),STR0022) //"NÆo foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("WorkIV",cFileIV+TeOrdBagExt(),"WKINVOICE")
//MFR OSSME-1974 26/12/2018
SET INDEX TO (cFileIV+TeOrdBagExt())

SW9->(DBSETORDER(3))
SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))

DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                            SW9->W9_HAWB == SW6->W6_HAWB
   WorkIV->(DBAPPEND())

   WorkIV->WKINVOICE := SW9->W9_INVOICE 
   WorkIV->WKMOEDA   := SW9->W9_MOE_FOB
   WorkIV->WKVLRFOB  := SW9->W9_FOB_TOT / SW6->W6_TX_US_D
   WorkIV->WKINCOTER := SW9->W9_INCOTER

   SW9->(DBSKIP())
   
ENDDO

oMainWnd:ReadClientCoords()    

DEFINE MSDIALOG oDlgIV TITLE "Invoices" FROM 000,oMainWnd:nLeft TO 250,oMainWnd:nRight-100 OF oMainWnd PIXEL

  DBSELECTAREA("WorkIV")
  WorkIV->(dBGoTop())                         
  oMark:=MsSelect():New("Workiv",,,TB_CampIV,.F.,"XX" ,{nLin,005,nLin+100,(oDlgIV:nClientWidth-4)/2})
  oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkIV"),.T. }

ACTIVATE DIALOG oDlgIV ON INIT EnchoiceBar(oDlgIV, { || oDlgIV:End() }, { || oDlgIV:End() },,,,,,,.F.) CENTERED

WorkIV->(E_EraseArq(cFileIV))

RETURN

//TRP-10/01/08- Função que permiti alterar a TES do(s) item(ns).
*--------------------------*
FUNCTION DI156AltTes()
*--------------------------*
Local oDlg
Local _PictTES := ALLTRIM(X3PICTURE("W7_TES"))
Local bOk , bCancel
Private cTES_

bOk := {|| If (MsgYesNo("Desea grabar las informaciones cambiadas?"), ( oDlg:End(),DI156GrvNewTes()), oDlg:End() )}    //Deseja gravar as informações alteradas?
bCancel := {|| oDlg:End()}

DEFINE MSDIALOG oDlg TITLE "Modificar TES" From 9,0 To 18,45 OF oMainWnd //"Modificar TES"
   
   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 18/09/2017
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT 
   
   cTES_ := Work2->WKTES
   
   @ 18,30 SAY "TES" SIZE 10,08 PIXEL OF oPanel //"TES"
   @ 18,123 SAY "(F3-Help)" SIZE 25,08 OF oPanel PIXEL //'(F3-Help)'  
   
   @ 18,43 MSGET cTES_  SIZE 60,08 PICTURE _PictTES F3 "SFC" VALID DI156TesValida() OF oPanel PIXEL       

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

RETURN NIL

//TRP-11/01/08- Função que realiza a gravação da nova TES alterada na função DI156AltTes()
*-----------------------------* 
Function DI156GrvNewTes()
*-----------------------------*
Local lSW7TES:= SW7->( FieldPos("W7_TES") ) > 0
Local aOrdSW7:= {}

aOrdSW7:= SaveOrd({"SW7"})

SW7->(DbSetOrder(4))

Work2->WKTES := cTES_

Work1->(DBSEEK(Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM))   
DO WHILE  ! Work1->(EOF()) .AND. ;
   Work1->WK_CFO     ==  Work2->WK_CFO      .AND. ;
   Work1->WK_OPERACA ==  Work2->WK_OPERACA  .AND. ;
   Work1->WKTEC      ==  Work2->WKTEC       .AND. ;
   Work1->WKEX_NCM   ==  Work2->WKEX_NCM    .AND. ;
   Work1->WKEX_NBM   ==  Work2->WKEX_NBM
      
   Work1->WKTES := Work2->WKTES    
        
   IF lSW7TES
      If SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB+Work1->WKPO_NUM+Work1->WKPOSICAO+Work1->WKPGI_NUM))
         SW7->(RecLock("SW7",.F.))
         SW7->W7_TES := Work1->WKTES   
         SW7->(MsUnlock())
      ENDIF
   ENDIF
   
   Work1->(DbSkip())
ENDDO

RestOrd(aOrdSW7,.T.)

IF cTipoNF = NFE_IMPOSTOS
   Di156GerImpostos(.F.)
ENDIF      

RETURN NIL
//TRP-28/01/08- Função que valida a seleção da TES.
*-----------------------------* 
Function DI156TesValida()
*-----------------------------*

IF !EMPTY(cTES_)
   IF !EXISTCPO("SFC",cTES_)
      RETURN .F.
   ENDIF
   SFC->(DBSETORDER(1))
   IF SFC->(DBSEEK((cFil:=xFilial("SFC"))+cTES_))
      DO WHILE SFC->(!EOF()) .AND. cTES_ == SFC->FC_TES .AND. cFil == SFC->FC_FILIAL
         IF SFC->FC_INTEIC $ "1,Y,S"
            RETURN .T.
         ENDIF
         SFC->(DBSKIP())
      ENDDO
      HELP("",1,"AVG0000400")//"Não há impostos de importação cadastrados para essa TES"
      RETURN .F.
   ENDIF
ENDIF

Return .T.   

/*
Funcao      : DI156Manu_AD
Parametros  : 
Retorno     : 
Objetivos   : Tela Acrescimo/deduçoes.
Autor       : Jean Victor Rocha
Data/Hora   : 18/05/2010
Revisao     : 
Obs.        : 
*/    
*----------------------------*
Static Function DI156Manu_AD()
*----------------------------*
Local lRet := .T.           
Local oDlg_AD
Local cTitulo := STR0366//"Acrescimos/Deducoes"
Local bOk     := {|| (DI156GRV_AD(), oDlg_AD:End()) }
Local bCancel := {|| oDlg_AD:End() }
Local lNewReg := .F.
Local nOpc    := 2 

Private aCpos:={'EIU_TIPO', 'EIU_CODIGO', 'EIU_DESC', 'EIU_VALOR', 'EIU_MOE', 'EIU_TX'}//Campos a serem exibidos no MSGetDb
Private aHeader    := {}

//Criação da Work, caso nao exista.
CriaWork_AD()

//Validaçao de tipo de manutençao.
If !lGravaWorks .and. WORK_AD->(BOF()) .and. WORK_AD->(EOF())
   WORK_AD->(DBAPPEND())
   WORK_AD->EIU_TIPO := "A"
ElseIf lGravaWorks
   nOpc := 1
EndIf
                
DEFINE MSDIALOG oDlg_AD TITLE cTitulo; 
       FROM oMainWnd:nTop   +200,oMainWnd:nLeft +15;
       TO   oMainWnd:nBottom-200,oMainWnd:nRight-50 OF oMainWnd PIXEL

  oMark:= MsGetDB():New( 25, 1, (oDlg_AD:nClientHeight-6)/2, (oDlg_AD:nClientWidth-4)/2, nOpc, "U_DI156LinOk_AD", /**/, , .T., aCpos, , .F., , "WORK_AD",,,lNewReg,,,,"U_DI156ApagaReg")

ACTIVATE MSDIALOG oDlg_AD ON INIT (EnchoiceBar(oDlg_AD, bOk, bCancel,.F.),;
                                   oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT) CENTERED

//Atualiza valores que estão no array.
aValores := DI156VAl_AD(SW6->W6_HAWB)
DI156VAl_AD( SW6->W6_HAWB, .T., "WORK1", .T., .T.)
DI156VAl_AD( SW6->W6_HAWB, .T., "WORK2", .T., .T.)

Return lRet

/*
Funcao      : CriaWork_AD
Parametros  : 
Retorno     : 
Objetivos   : Criação da work e carregar a work, a ser utilizada pela tela de acrescimos/deduções.
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/      
*---------------------------*
Static Function CriaWork_AD()
*---------------------------*
Local lRet := .T.

//Criação da Work_AD.
If SELECT("Work_AD") = 0
   SX3->(dbSetOrder(1))
   IF SX3->(DBSEEK("EIU"))
      aCampos := Array(EIU->(FCount()))       
      aSemSX3 :={{"WK_RECNO"  ,"N",10,00}}
   EndIf
   Work5File:=E_CriaTrab("EIU",aSemSX3,"Work_AD",aHeader)    
   IF !USED()    
      /* nopado por RNLP - 18/09/20 - OSSME-5260 - Função não escrita por nenhum fonte do sistema em modo function, outros fontes usam como static function  
      E_RESET_AREA()    
      */  
      Help("",1,"AVG0000802")//"Nao foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
      Return .F.
   ENDIF
   //MFR OSSME-1974 26/12/2018
   IndRegua("Work_AD",Work5File+TeOrdBagExt(),"EIU_CODIGO")
Else
   Work_AD->(AvZap())
EndIf

aHeader := {}
CriaEstru(aCpos,@aHeader)

//Carrega Work.            
EIU->(DbSetOrder(1))
If EIU->(DbSeek(xFilial("EIU") + SW6->W6_HAWB))
   While EIU->(!EOF()) .and. EIU->EIU_HAWB == SW6->W6_HAWB
      WORK_AD->(DbAppend())
      AvReplace("EIU", "WORK_AD")
      WORK_AD->WK_RECNO := EIU->(RECNO())
      If WORK_AD->EIU_TIPO == "A" .and. SJN->(DbSeek(xFilial("SJN") + WORK_AD->EIU_CODIGO))
         WORK_AD->EIU_DESC := SJN->JN_DESC
      ElseIf WORK_AD->EIU_TIPO == "D" .and. SJO->(DbSeek(xFilial("SJO") + WORK_AD->EIU_CODIGO))
         WORK_AD->EIU_DESC := SJO->JO_DESC      
      EndIf
      WORK_AD->(MsUnLock())
      EIU->(DBSKIP())
   EndDo
EndIf  

Return lRet

/*
Funcao      : DI156GRV_AD
Parametros  : 
Retorno     : 
Objetivos   : Gravação dos itens da tela de Acrescimos/deduções.
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/      
*---------------------------*
Static Function DI156GRV_AD()
*---------------------------*
Local lLock := .T.
DI156EST_AD()

//Gravação do processo.
WORK_AD->(DbGoTop())
While WORK_AD->(!EOF())
   lLock := .T.
   //Verifica se ja existe registro/ se foi somente alterado, grava as alterações.
   If EIU->(DbSeek(xFilial("EIU")+ WORK_AD->EIU_HAWB))
      While EIU->(!EOF()) .and. EIU->EIU_HAWB == WORK_AD->EIU_HAWB 
         If WORK_AD->WK_RECNO == EIU->(RECNO()) .or.;
            (EIU->EIU_CODIGO == WORK_AD->EIU_CODIGO .and. EIU->EIU_TIPO == WORK_AD->EIU_TIPO)
            
            lLock := .F. 
            Exit           
         EndIf
         EIU->(DbSkip())
      EndDo
   EndIf
   EIU->(RecLock("EIU", lLock))
   AvReplace("WORK_AD", "EIU")
   EIU->EIU_FILIAL := xFilial("EIU")
   EIU->EIU_HAWB   := SW6->W6_HAWB
   EIU->EIU_TIPONF := NFE_IMPOSTOS
   EIU->(MsUnLock())
   WORK_AD->(DbSkip())
EndDo

Return .T. 
 
/*
Funcao      : DI156EST_AD
Parametros  : 
Retorno     : 
Objetivos   : Deletar os itens pre-selecionados pelo array aDeletados.
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/      
*---------------------------*
Static Function DI156EST_AD()
*---------------------------*
Local i                 

For i:=1 to Len(aDeletados) 
   WORK_AD->(DbGoTo(aDeletados[i]))
   If EIU->(DbSeek(xFilial("EIU")+ WORK_AD->EIU_HAWB)) 
       While EIU->(!EOF()) .and. EIU->EIU_HAWB == WORK_AD->EIU_HAWB
          If WORK_AD->EIU_CODIGO == WORK_AD->EIU_CODIGO .and. WORK_AD->EIU_TIPO == WORK_AD->EIU_TIPO
             EIU->(RecLock("EIU", .F.))
             EIU->(DBDelete())
             EIU->(MsUnLock())
          EndIf
          EIU->(DbSkip())
       EndDo
   EndIf
   //Deleta tambem na Work, para que no momento da gravação contenha apenas os registros provenientes de inclusao/alteraçao.
   WORK_AD->(RecLock("WORK_AD", .F.))
   WORK_AD->(DBDelete())
   WORK_AD->(MsUnLock())
Next i

aDeletados := {}

Return .T.

/*
Funcao      : D1156BrwEIU()
Parametros  : 
Retorno     : 
Objetivos   : Ativar o F3 do campo EIU_CODIGO, utilizado na tela de acrescimos/deduções.
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/   
*---------------------------------------------------------*
Function D1156BrwEIU()//Chamado do SXB, XB_ALIAS = 'EIU'
*---------------------------------------------------------*
Local lRet := .T.

If Work_AD->EIU_TIPO == "A"
   lRet := ConPad1(,,,'SJN',,,.F.)
ElseIf Work_AD->EIU_TIPO == "D"
   lRet := ConPad1(,,,'SJO',,,.F.)
EndIf

Return lRet

/*
Funcao      : DI156EIUValid()
Parametros  : cCpoEIU =  Campo a ser validado
Retorno     : 
Objetivos   : Validação de campos especificos, função utilizada no X3_VALID.
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/  
*-----------------------------*
Function DI156EIUValid(cCpoEIU)
*-----------------------------*
Local lRet := .F.

Do CASE
   CASE cCpoEIU == "EIU_CODIGO"
      lRet := .T.
      //Quando acionado o camando F3, o conteudo do campo é perdido, porem a tabela correspondente do SXB ja esta posicionada, possibilitando o uso do campo.
      IF WORK_AD->EIU_TIPO == 'A'
         lRet := Vazio() .OR. ExistCpo("SJN", IF(TYPE(M->EIU_CODIGO)<>NIL,M->EIU_CODIGO,SJN->JN_CODIGO)) 
         IF lRet
            If TYPE(M->EIU_CODIGO)<>NIL
               SJN->(DbSeek(xFilial("SJN") + M->EIU_CODIGO))
            EndIf
            WORK_AD->EIU_DESC := SJN->JN_DESC
         EndIf
      ELSEIF WORK_AD->EIU_TIPO == 'D'
         lRet := Vazio() .OR. ExistCpo("SJO", IF(TYPE(M->EIU_CODIGO)<>NIL,M->EIU_CODIGO,SJN->JN_CODIGO))
         IF lRet
            If TYPE(M->EIU_CODIGO)<>NIL
               SJO->(DbSeek(xFilial("SJO") + M->EIU_CODIGO))
            EndIf
            WORK_AD->EIU_DESC := SJO->JO_DESC
         EndIf
      ENDIF  
      oMark:ForceRefresh()
      lExecF3 := .F.

   CASE cCpoEIU == "EIU_MOE"                                              
      If !EMPTY(IF(TYPE(M->EIU_MOE)<>NIL,M->EIU_MOE,WORK_AD->EIU_MOE)) .AND. ExistCpo("SYF",  IF(TYPE(M->EIU_MOE)<>NIL,M->EIU_MOE,WORK_AD->EIU_MOE))
         lRet := .T.
         M->EIU_TX := 0
         If M->EIU_MOE $ EasyGParam("MV_SIMB2",,"")
            M->EIU_TX := SW6->W6_TX_US_D
            WORK_AD->EIU_TX:= SW6->W6_TX_US_D
         ElseIf M->EIU_MOE $ EasyGParam("MV_SIMB1",,"")
            M->EIU_TX := 1
            WORK_AD->EIU_TX := 1
         Else
            M->EIU_TX := SW9->W9_TX_FOB
            WORK_AD->EIU_TX := SW9->W9_TX_FOB
         EndIf
      EndIf
      oMark:ForceRefresh()
      lExecF3 := .F.  

    
EndCASE 
 
RETURN lRet

/*
Funcao      : DI156LinOk_AD
Parametros  : 
Retorno     : 
Objetivos   : Validação da linha do MsGetDb utilizado no Acrescimos/deduções
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/      
*-----------------------------*
User Function DI156LinOk_AD()
*-----------------------------*       
Local lRet := .T.
Local aOrd := SaveOrd({"Work_AD"})
Local cTipo:= WORK_AD->EIU_TIPO
Local cCod := WORK_AD->EIU_CODIGO 
Local nRecnoWORK := WORK_AD->(RECNO())

//Se for registro deletado, não executa a validação.
If WORK_AD->DELETE
   Return .T.
EndIf

If EMPTY(WORK_AD->EIU_CODIGO) .or. EMPTY(WORK_AD->EIU_TIPO) .or. EMPTY(WORK_AD->EIU_VALOR)
    MsgInfo(STR0367)//"Um ou mais campos obrigatório não foram preenchidos."
   Return .F.
EndIf

WORK_AD->(DbGoTop())
While WORK_AD->(!EOF())
  If WORK_AD->EIU_CODIGO == cCod .and. WORK_AD->EIU_TIPO == cTipo .and. WORK_AD->(RECNO()) <> nRecnoWORK  
     MsgInfo(STR0368)//"Código selecionado já utilizado."
     lRet := .F.
  EndIf 
  WORK_AD->(DBSKIP())
EndDo

WORK_AD->(DbGoTo(nRecnoWORK))

If !WORK_AD->EIU_TIPO $ "A/D"
   MsgInfo(STR0369)//"Opção invalida no campo Tipo."
   lRet := .F.   
EndIf 
   
   
If WORK_AD->EIU_TX == 0
   MsgInfo(STR0370)//"Taxa não informada."
   lRet := .F.
EndIf 

RestOrd(aOrd, .T.)
Return lRet 

/*
Funcao      : DI156ApagaReg
Parametros  : 
Retorno     : 
Objetivos   : Adiciona no array aDeletados os itens da MsGetDb utilizado na tela de Acrescimons/Deduções.
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/  
*------------------------------------------------------------------*
USER Function DI156ApagaReg()                                         
*------------------------------------------------------------------*
Local lRet := .T.
Local nRecnoDel := WORK_AD->(RECNO())

If (nPos := AScan(aDeletados,{ |x| x == nRecnoDel } )) > 0
   ADel(aDeletados,nPos)
   ASize(aDeletados,Len(aDeletados)-1)
Else
   AAdd(aDeletados, nRecnoDel)
EndIf

Return lRet

/*
Funcao      : DI156VAl_AD
Parametros  : cHawb   = Numero do Processo a ser verificado.
              lRAteio = Verifica se vai efetuar o rateio por item.
              cWork   = Nome da work.
              lAtu    = Verifica se ja atualiza a work.
Retorno     : 
Objetivos   : Retorna o Valor de acrescimo e Deduções do processo. Com o rateio por item ou nao.
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/      
*--------------------------------------------------------*
Function DI156VAl_AD(cHawb, lRateio, cWork, lAtu, lAtuAll)
*--------------------------------------------------------*
Local aRet   := {}
Local nAcres := nDed:= 0
Local aOrd   := {}
Local aValRat:= {0, 0}
                         
Default lRateio := .F.
Default lAtu    := .F.
Default lAtuAll := .F.
                                         
EIU->(DbSetOrder(1))
If EIU->(DbSeek(xFilial("EIU") + cHawb ))
   nDed := nAcres := 0
   While EIU->(!EOF()) .and. EIU->EIU_HAWB == cHawb
      If EIU->EIU_TIPO == "A"
         nAcres += EIU->EIU_VALOR * EIU->EIU_TX
      ElseIf EIU->EIU_TIPO == "D"
         nDed   += EIU->EIU_VALOR * EIU->EIU_TX
      EndIf
      EIU->(DbSkip())
   EndDo
EndIf

aAdd(aRet, nAcres)//acrescimo
aAdd(aRet, nDed  )//Dedução

//Tratamento do rateio , definido sempre da work1(item) ou Work2(grupo)
If lRateio                                
   aOrd := SaveOrd({ "WORK1", "WORK2"} )
   If lAtuAll
      Work1->(DbGoTop())
      While Work1->(!EOF())
         aValRat := DI156Rat_AD(nAcres, nDed, "WORK1")   
         If lAtu
            Work1->WKACRES := aValRat[1]
            Work1->WKDEDUC := aValRat[2]
         EndIf
         Work1->(DbSkip())
      EndDo             
      Work2->(DbGoTop())
      While Work2->(!EOF())
         aValRat := DI156Rat_AD(nAcres, nDed, "WORK2")
         If lAtu
            Work2->WKACRES := aValRat[1]
            Work2->WKDEDUC := aValRat[2]
         EndIf
         Work2->(DbSkip())
      EndDo
   Else  
      If  cWork == "WORK1"
         aValRat := DI156Rat_AD(nAcres, nDed, "WORK1")      
         If lAtu
            Work1->WKACRES := aValRat[1]
            Work1->WKDEDUC := aValRat[2]
         EndIf
      ElseIf cWork == "WORK2"
         aValRat := DI156Rat_AD(nAcres, nDed, "WORK2")
         If lAtu
            Work2->WKACRES := aValRat[1]
            Work2->WKDEDUC := aValRat[2]
         EndIf
      EndIf
   EndIf

   RestOrd(aOrd, .T.)

   aAdd(aRet, aValRat[1])//acrescimo rateado
   aAdd(aRet, aValRat[2])//Dedução rateado
EndIf       

Return aRet

/*
Funcao      : DI156Rat_AD
Parametros  : nAcres   = Valor total de acrescimo do processo
              nDed     = Valor total de deduçao do processo
              cWork    = Work a ser utilizada.
Retorno     : 
Objetivos   : Retorna o rateio.
Autor       : Jean Victor Rocha
Data/Hora   : 21/05/2010
Revisao     : 
Obs.        : 
*/      
*---------------------------------------*
Function DI156Rat_AD(nAcres, nDed, cWork)
*---------------------------------------*
Local nValTot  := 0 
Local nValItem := 0 
Local aOrd := {}
Local aRet := {}
   
Do Case
   Case cWork == "WORK1"
      nValItem := Work1->WKVALMERC
      aOrd := SaveOrd("WORK1")
      Work1->(DbGoTop())
      While Work1->(!EOF())
         nValTot += Work1->WKVALMERC
         Work1->(DbSkip())
      EndDo

   Case  cWork == "WORK2"
      aOrd := SaveOrd({"WORK2","WORK1"} )
      Work1->(DbGoTop())
      DO WHILE  ! Work1->(EOF())
         If Work1->WK_CFO     ==  Work2->WK_CFO      .AND. ;
            Work1->WK_OPERACA ==  Work2->WK_OPERACA  .AND. ;
            Work1->WKTEC      ==  Work2->WKTEC       .AND. ;
            Work1->WKEX_NCM   ==  Work2->WKEX_NCM    .AND. ;
            Work1->WKEX_NBM   ==  Work2->WKEX_NBM
   
            nValItem += Work1->WKVALMERC//valor total do item(grupo)
         EndIf
         nValTot += Work1->WKVALMERC//Valor total de todos os itens.

         Work1->(DbSkip())
      ENDDO 
    
EndCase

aAdd(aRet, (( nAcres/nValTot) * nValItem) )
aAdd(aRet, (( nDed  /nValTot) * nValItem) )

RestOrd(aOrd, .T.)

Return aRet
*---------------------------------------------------------------------------------------------------*
*                                  FIM DO PROGRAMA EICDI156.PRW 
*---------------------------------------------------------------------------------------------------*
