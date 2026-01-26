//Funcao....: EICDINCP 
//Autor.....: Alex Wallauer
//Data......: 10/02/2003 - 9:00
//Descricao.: Nota de Credito e Proveedores
//Uso.......: SIGAEIC - Argentina
  
#INCLUDE "Eicdi154.ch" 
#INCLUDE "Average.ch"

#DEFINE  NFE_IMPOSTOS  '9'//4
#DEFINE  NFE_DESPESAS  'A'//5
#DEFINE  CUSTO_REAL    'B'//7

*---------------------------*
Function EICDINCP()
*---------------------------*
LOCAL aFixos:={ { AVSX3("W6_HAWB"   ,5) ,"W6_HAWB"   },; //"Processo"
                { AVSX3("W6_DI_NUM" ,5) ,"W6_DI_NUM" },; //"No. da D.I."
                { AVSX3("W6_TX_US_D",5) ,"W6_TX_US_D"},;
                { AVSX3("W6_NF_ENT" ,5) ,"W6_NF_ENT" },; //"1a. NFE"
                { AVSX3("W6_DT_NF"  ,5) ,"W6_DT_NF"  },; //AWR 14/7/98 //"Dt 1a. NFE"
                { AVSX3("W6_NF_COMP",5) ,"W6_NF_COMP"},; //"1a. NFC"
                { AVSX3("W6_DT_NFC" ,5) ,"W6_DT_NFC" },; //AWR 14/7/98 //"Dt 1a. NFC"
                { AVSX3("W6_FOB_TOT",5) ,"W6_FOB_TOT"},; //"Total F.O.B."
                { AVSX3("W6_INLAND" ,5) ,"W6_INLAND" },; //"Inland"
                { AVSX3("W6_PACKING",5) ,"W6_PACKING"},; //"Packing"
                { AVSX3("W6_FRETEIN",5) ,"W6_FRETEIN"},; //"Frete Intl"
                { AVSX3("W6_DESCONT",5) ,"W6_DESCONT"} } //"Desconto"

Local aCores := {{ '(SW6->W6_STATUS)=="1"' , 'DISABLE' },; 	//VERMELHO  //MLS 17/06/2004
                 { '(SW6->W6_STATUS)=="2"' , 'ENABLE'  },;   //VERDE     //MLS 17/06/2004
                 { '(SW6->W6_STATUS)=="3"' , 'BR_AZUL'} }	//AZUL      //MLS 17/06/2004

                
PRIVATE aOpcoes:={}                

PRIVATE cTipoNF:=NFE_DESPESAS  //5  ==> 'A'      
PRIVATE cCond:="IF(!SWD->(DBSEEK(xFilial()+SW6->W6_HAWB)),.F.,.T.)"
PRIVATE cCadastro := STR0013+" - N.C.P." //"Recebimento de Importa‡Æo - NF"

PRIVATE Work1File,Work1FileA,Work1FileB,Work1FileC,Work1FileD,Work2File,Work3File,Work3FileA,Work4File,cFileWk,cFileWkA

PRIVATE aRotina := { {"Busqueda"   ,"AxPesqui"    , 0 , 1},; //"Pesquisar"
                     {"Genera NCP" ,"DINCP"     , 0 , 2}}
PRIVATE bWD_Valor:= {|| IF(SWD->WD_VALOR_R<0,SWD->WD_VALOR_R*-1,SWD->WD_VALOR_R) }
SX6->(DBSETORDER(1))
SX3->(DBSETORDER(2))
SA5->(DBSETORDER(3))
SW2->(DBSETORDER(1))
SWD->(DBSETORDER(1))

IF SW6->(FIELDPOS("W6_STATUS")) # 0 .AND. SIX->(DBSEEK("SF16")) .AND. FINDFUNCTION("DI156COND")
   AADD(aRotina,{"Leyenda",'DINCPLegend' , 0 , 1})  //"Legenda" //MLS
   mBrowse(,,,,"SW6",aFixos,,,,,aCores)
ELSE
   mBrowse(,,,,"SW6",aFixos,,,cCond)
ENDIF

SA5->(DBSETORDER(1))
SWZ->(DBSETORDER(1))
SWN->(DBSETORDER(1))
SF2->(DBSETORDER(1))
SD2->(DBSETORDER(1))
SX3->(DBSETORDER(1))
SW7->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SX3->(DBSETORDER(1))
SWD->(DBSETORDER(1))
DBSELECTAREA("SX3")

Return .T.
*----------------------------------------------------------*
Function DINCP(cAlias,nReg,nOpc)
*----------------------------------------------------------*
LOCAL cFilSW9:=xFilial("SW9"), i
LOCAL oDlg, nCoL1, nCoL2, nCoL3, nCoL4
PRIVATE lTravaNF:=.T.

IF LEN(SWD->WD_NF_COMP) # LEN(SF2->F2_DOC)
   MSGSTOP('Tamanho do campo "WD_NF_COMP" deve ser: '+STR(LEN(SF2->F2_DOC),2) )
   Return .F.
ENDIF

IF SF2->(FIELDPOS("F2_HAWB")) = 0
   MSGSTOP('Campo "F2_HAWB" nao existe.')
   Return .F.
ENDIF

IF SW7->(FIELDPOS("W7_LOCAL")) = 0
   MSGSTOP('Campo "W7_LOCAL" nao existe.')
   Return .F.
ENDIF

IF !SIX->(DBSEEK("SF27")) .OR. ALLTRIM(SIX->CHAVE) # "F2_FILIAL+F2_HAWB"
   MSGSTOP('Indice 7 : "F2_FILIAL+F2_HAWB" do SF2 nao encontrado.')
   Return .F.
ENDIF

DBSELECTAREA("SW6")
IF EasyRecCount() == 0
   Return .F.
EndIf

bSetKey:=SETKEY(VK_F4)
SETKEY(VK_F4,{|| DIHelpSWD() } )

PRIVATE aDespesa:= {}
PRIVATE nDecPais:=MSDECIMAIS(1),nTamRec:=9
PRIVATE aDBF_Stru:={{"WKCOD_I"   ,"C",LEN(SW7->W7_COD_I) ,0},;
                    {"WKFLAG"    ,"C",02,0},;
                    {"WKFORN"    ,"C",LEN(SW7->W7_FORN)  ,0},;
                    {"WKFABR"    ,"C",LEN(SW7->W7_FABR)  ,0},;
                    {"WKTEC"     ,"C",LEN(SB1->B1_POSIPI),0},;
                    {"WKEX_NCM"  ,"C",LEN(SB1->B1_EX_NCM),0},;
                    {"WKEX_NBM"  ,"C",LEN(SB1->B1_EX_NBM),0},;
                    {"WK_CFO"    ,"C",LEN(SWZ->WZ_CFO)    ,0},;
                    {"WK_OPERACA","C",LEN(SW7->W7_OPERACA),0},;
                    {"WKPGI_NUM" ,"C",10,0},;
                    {"WKLOJA"    ,"C",LEN(SA2->A2_LOJA)   ,0},;
                    {"WKQTDE"    ,"N",18,7},;
                    {"WKPRECO"   ,"N",18,7},;
                    {"WKDESCR"   ,"C",60,0},;
                    {"WKUNI"     ,"C",03,0},;
                    {"WKPRUNI"   ,"N",18,8},;
                    {"WKVALMERC" ,"N",18,7},;
                    {"WKVALMERUS","N",18,7},;
                    {"WKRATEIO"  ,"N",18,16},;
                    {"WKRATPESO" ,"N",18,16},;
                    {"WKRATQTDE" ,"N",18,16},;
                    {"WKPESOL"   ,"N",AVSX3("WN_PESOL",3),AVSX3("WN_PESOL",4)},;
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
                    {"WKSI_NUM"  ,"C",AVSX3("W7_SI_NUM",3),0},;  //SO.:0026 OS.:0213/02
                    {"WKPO_NUM"  ,"C",15,0},;
                    {"WKPO_SIGA" ,"C",06,0},;
                    {"WKRECNO"   ,"N",nTamRec,0},;
                    {"WKRECNOWK3","N",nTamRec,0},;
                    {"WKRECNOWK4","N",nTamRec,0},;
                    {"WK_CC"     ,"C",AVSX3("W7_CC",3),0},; //SO.:0026 OS.:0213/02
                    {"WK_NFE"    ,"C",AVSX3("D2_DOC",3),0},;
                    {"WK_NOTA"   ,"C",AVSX3("D2_DOC",3),0},;
                    {"WK_SE_NFE" ,"C",AVSX3("D2_SERIE",3),0},;
                    {"WK_NFE_AUX","C",LEN(SD2->D2_DOC),0},;
                    {"WK_DT_NFE" ,"D",08,0},;
                    {"WKLOCAL"   ,"C",LEN(SC1->C1_LOCAL),0},;
                    {"WKPOSICAO" ,"C",LEN(SW3->W3_POSICAO),0},;
                    {"WK_REG"    ,"N",AVSX3("W1_REG",3),0},;
                    {"WKINVOICE" ,"C",LEN(SW9->W9_INVOICE),0},;
                    {"WKDESPESA" ,"C",33,0},;
                    {"WK_TES"    ,"C",LEN(SYB->YB_TES),0},;
                    {"WK_REC_SWN","N",10,0},;
                    {"WKIMPOSTOS","N",18,7}}

PRIVATE aDBF_Stru2:={{"WKFORN"    ,"C",LEN(SW7->W7_FORN)   ,0},;
                     {"WKFABR"    ,"C",LEN(SW7->W7_FABR)   ,0},;
                     {"WKTEC"     ,"C",10,0},;
                     {"WKEX_NCM"  ,"C",LEN(SB1->B1_EX_NCM) ,0},;
                     {"WKEX_NBM"  ,"C",LEN(SB1->B1_EX_NBM) ,0},;
                     {"WK_CFO"    ,"C",LEN(SWZ->WZ_CFO)    ,0},;
                     {"WK_OPERACA","C",LEN(SW7->W7_OPERACA),0},;
                     {"WKPESOL"   ,"N",AVSX3("B1_PESO",3),AVSX3("B1_PESO",4)},;
                     {"WKFOB"     ,"N",18,7},;
                     {"WKFOB_R"   ,"N",18,7},;
                     {"WKFRETE"   ,"N",18,7},;
                     {"WKFOB_ORI" ,"N",18,7},;
                     {"WKFOBR_ORI","N",18,7},;
                     {"WKCIF_MOE" ,"N",18,7},;
                     {"WKSEGURO"  ,"N",18,7},;
                     {"WKCIF"     ,"N",18,7},;
                     {"WKOUTRDESP","N",18,7},;
                     {"WKOUTRD_US","N",18,7},;
                     {"WK_NF_COMP","C",AVSX3("D2_DOC",3),0},;
                     {"WK_SE_NFC" ,"C",AVSX3("D2_SERIE",3),0},;
                     {"WK_DT_NFC" ,"D",08,0},;
                     {"WKQTDE"    ,"N",18,7}}

             
aDBF_Stru3 :={{"WKRECNO"   ,"C",nTamRec,0},;
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
             {"WKRECNOWK4","N",nTamRec,0},;
             {"WKDT_EMIS" ,"D",08,0}}             

TB_Campos1:={}

Private PICT_CPO03 :=  ALLTRIM(X3PICTURE("B1_POSIPI")) //_PictTec
Private PICT_CPO07 := _PictQtde := ALLTRIM(X3Picture("W3_QTDE"))
PRIVATE PICT15_2:= '@E 999,999,999,999.99'
PRIVATE PICT21_8:= _PictPrUn := ALLTRIM(X3Picture("W3_PRECO"))
PRIVATE PICTPesoT:= AVSX3("B1_PESO",6)
PRIVATE PICTPesoI:= AVSX3("B1_PESO",6)

PRIVATE lGerouNFE:=.F.,TB_Campos2:={},nOpca := 0
PRIVATE cMarca := GetMark(), lInverte := .F., nContProc:= 0
PRIVATE xFilSYB:=xFilial("SYB")
PRIVATE oSayTotGe,aLista:={}
PRIVATE cNumNFE, cSerieNFE, dDtNFE
PRIVATE lNFAutomatica  :=ALLTRIM(EasyGParam("MV_NF_AUTO")) $ cSim
PRIVATE lQuebraOperacao:=ALLTRIM(EasyGParam("MV_QB_OPER")) $ cSim

lGravaWorks:=.F.
cNota      :=''
cMoeDolar  :=EasyGParam("MV_SIMB2")
cMoeDolar  :=IF(EMPTY(cMoeDolar),"U$S",cMoeDolar)

SW7->(DbSeek(xFilial("SW7")+SW6->W6_HAWB))
SWZ->(DBSETORDER(2))
SWN->(DBSETORDER(2))
SF2->(DBSETORDER(7))

aNotasDel:={}

IF SF2->(DBSEEK(xFilial("SF2")+SW6->W6_HAWB))
   lGravaWorks:=.T.
ENDIF

IF !lGravaWorks

   SW8->(DBSETORDER(1))
   SW9->(DBSETORDER(3))
   IF !SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB)) .OR.;
      !SW9->(DBSEEK(xFilial("SW9")+SW6->W6_HAWB))
      MSGSTOP("Nota Fiscal nao pode ser gerada, Processo nao possui Invoices.",STR0022)
      RETURN .F.
   ENDIF

   SW9->(DBSETORDER(3))
   SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))
   DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
	                              SW9->W9_HAWB == SW6->W6_HAWB
	  IF EMPTY(SW9->W9_TX_FOB)
         MSGSTOP("Existem Invoices sem Taxa FOB.",STR0022)
         RETURN .F.
	  ENDIF

	  IF SW9->(FIELDPOS("W9_TUDO_OK")) # 0 .AND.;
	     SW9->W9_TUDO_OK = "2"
         MSGSTOP("Os valores da Invoice nao estao corretos",AVSX3("W9_INVOICE",5)+": "+SW9->W9_INVOICE)
	     RETURN .F.
	  ENDIF

	  SW9->(DBSKIP())
   ENDDO
ENDIF

IF !Empty(SW6->W6_DT_ENCE)
   MSGINFO("Proceso ya encerrado, no es posible "+IF(lGravaWorks,"revertir.","generar."),"Atencion!")
ENDIF

aNFsCompCtr:={}

IF SF2->(DBSEEK(xFilial("SF2")+SW6->W6_HAWB))

   lGravaWorks:=.F.

   aNFsComp   :={}
   TB_Campos  :={}

   AADD(TB_CAMPOS,{"WKFLAG"     ,,""})
   AADD(TB_CAMPOS,{{||WorkNF->F2_DOC+" "+WorkNF->F2_SERIE},,"NCP-Serie"})
   AADD(TB_CAMPOS,{"F2_CLIENTE" ,,AVSX3("F2_CLIENTE",5)})
   AADD(TB_CAMPOS,{"F2_EMISSAO" ,,AVSX3("F2_EMISSAO",5)})
// AADD(TB_CAMPOS,{"F2_VALMERC" ,,AVSX3("F2_VALMERC",5), AVSX3("F2_VALMERC",6) })

   aCampos:={"F2_DOC","F2_SERIE","F2_EMISSAO","F2_VALMERC","F2_CLIENTE","F2_LOJA"}

   WorkNFile:=E_CriaTrab(,{{"WKFLAG","C",2,0}},"WorkNF")
        
   bWhi:={|| SF2->F2_HAWB == SW6->W6_HAWB }

   bFor:={||IncProc(STR0273+' '+SF2->F2_DOC),ASCAN(aNFsComp,{|N|N[1]==SF2->F2_DOC.AND.N[2]==SF2->F2_SERIE.AND.N[6]==SF2->F2_CLIENTE})=0} //"Lendo Despesa: "

   bGrv:={||ProcRegua(SF2->(LASTREC())),;
            SF2->(DBEVAL({||AADD(aNFsComp,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_EMISSAO,SF2->F2_VALMERC,SF2->F2_CLIENTE,SF2->F2_LOJA})},;
                         bFor,bWhi))}

   SF2->(DBSEEK(xFilial("SF2")+SW6->W6_HAWB))
   SA2->(DbSeek(xFilial("SA2")+SF2->F2_CLIENTE))

   Processa(bGrv,STR0031) //"Processando..."

   FOR I:= 1 TO LEN(aNFsComp)
       WorkNF->(DBAPPEND())
       WorkNF->WKFLAG     :=cMarca
       WorkNF->F2_DOC     :=aNFsComp[I][1]
       WorkNF->F2_SERIE   :=aNFsComp[I][2]
       WorkNF->F2_EMISSAO :=aNFsComp[I][3]
//     WorkNF->F2_VALMERC :=aNFsComp[I][4]
       WorkNF->F2_CLIENTE :=aNFsComp[I][5]
       WorkNF->F2_LOJA    :=aNFsComp[I][6]
   NEXT

   DO WHILE .T.
      nOpca:=0
      WorkNF->(DBGOTOP())
   
      DEFINE MSDIALOG oDlg TITLE STR0032 FROM 0,0 TO 20,50 Of oMainWnd //"Nota Fiscal"

         @1.6,06 BUTTON STR0033  SIZE 38,12 ACTION (nOpca:=2,oDlg:End()) OF oDlg WHEN EMPTY(SW6->W6_DT_ENCE) //"&Inclui"

         @1.6,24 BUTTON (IF(EMPTY(SW6->W6_DT_ENCE),STR0034,"Consulta")) SIZE 38,12 ACTION (nOpca:=1,oDlg:End()) OF oDlg //"&Estorna"

         oMarkNF:=MsSelect():New("WorkNF","WKFLAG",,TB_Campos,@lInverte,@cMarca,{33,5,((oDlg:nClientHeight-6)/2)-10,((oDlg:nClientWidth-4)/2)-5})
 
      ACTIVATE MSDIALOG oDlg ON INIT ;
            EnchoiceBar(oDlg,{||nOpca:=2,oDlg:End()},;
                             {||nOpca:=0,oDlg:End()}) CENTERED

   IF nOpca==1

      WorkNF->(DBGOTOP())
      WorkNF->(DBEVAL( {|| AADD(aNotasDel,WorkNF->F2_DOC+WorkNF->F2_SERIE+WorkNF->F2_CLIENTE+WorkNF->F2_LOJA)},;
                       {|| !EMPTY(WorkNF->WKFLAG) } ))
      IF EMPTY(aNotasDel)
         MSGSTOP("No hay registros marcados")
         LOOP
      ENDIF

      SWN->(DBSETORDER(2))
      FOR I:= 1 TO LEN(aNotasDel)
         cChave:=aNotasDel[I]
         If SWN->(DbSeek(xFilial()+cChave))
            lGravaWorks:=.T.
         ELSE
            MSGINFO(STR0035+cChave+STR0036,STR0022) //"Nota Fiscal Complementar: "###" nÆo encontrada"###"Atenção"
            WorkNF->(E_EraseArq(WorkNFile))
            DBSELECTAREA("SW6")
            SW6->(DBGOTO(nReg))
            SWN->(DBSETORDER(1))
            Return .F.
         ENDIF
      NEXT
      SWN->(DBSETORDER(1))

   ELSEIF nOpca == 0

      WorkNF->(E_EraseArq(WorkNFile))
      DBSELECTAREA("SW6")
      SW6->(DBGOTO(nReg))
      Return .F.

   ENDIF
   EXIT
   ENDDO

   WorkNF->(E_EraseArq(WorkNFile))
   DBSELECTAREA("SW6")
   aCampos:={}

ENDIF

If !SW6->(RecLock("SW6",.F.))
   Help(" ",1,"REGNLOCK")
   SW6->(MsUnlock())
   Return .F.
Endif

lNFAutomatica := .F.

AADD(TB_Campos1,{"WK_CFO"    ,, STR0039   }) //"C.F.O."
AADD(TB_Campos1,{"WK_OPERACA",, "Operacao"})
AADD(TB_Campos1,{{||Work2->WK_OPERACA+"/"+TRAN(Work2->WKTEC,PICT_CPO03)+"/"+Work2->WKEX_NCM+"/"+Work2->WKEX_NBM},"",STR0040}) //"Operacao/TEC/Ex-NCM/Ex-NBM"
AADD(TB_Campos1,{"WKPESOL"   ,, STR0144 ,PICTPesoT}) //"Peso Adiçào"
AADD(TB_Campos1,{"WKOUTRDESP",, STR0053 ,PICT15_2}) //"Outras Despesas"

IF !lGravaWorks .AND. !lNFAutomatica
    AADD(TB_Campos2,{"WKFLAG",,"",})
ENDIF

AADD(TB_Campos2,{"WK_NFE"    ,,"N.C.P."})
AADD(TB_Campos2,{"WK_SE_NFE" ,,"Serie"})
AADD(TB_Campos2,{"WKDESPESA" ,,"Gasto"})
AADD(TB_Campos2,{"WKFORN"    ,,AVSX3("W7_FORN",5)})
AADD(TB_Campos2,{"WK_CFO"    ,,STR0039}) //"C.F.O."
AADD(TB_Campos2,{{||Work1->WK_OPERACA+" "+TRAN(Work1->WKTEC,PICT_CPO03)+" "+Work1->WKEX_NCM+" "+Work1->WKEX_NBM},,STR0040,}) //"Operacao/TEC/Ex-NCM/Ex-NBM"
AADD(TB_Campos2,{"WKCOD_I"   ,,STR0054}) //"C¢d. Item"
AADD(TB_Campos2,{{||Left(Work1->WKDESCR,30)},,STR0055}) //"Descri‡Æo do Item"
AADD(TB_Campos2,{"WKPESOL"   ,,STR0041,PICTPesoI}) //"Peso L¡quido"
AADD(TB_Campos2,{"WKPRUNI"   ,,STR0056,PICT21_8 }) //"Pre‡o Unit rio(R$)"
AADD(TB_Campos2,{"WKQTDE"    ,,STR0057,PICT_CPO07}) //"Quantidade"
AADD(TB_Campos2,{"WKVALMERC" ,,STR0058,_PictPrUn}) //"Pre‡o Total(R$)"
//AADD(TB_Campos2,{"WKIMPOSTOS",,"Impuestos",PICT15_2})
IF !lGravaWorks
   AADD(TB_Campos2,{"WK_DT_NFE" ,,STR0096}) //"Data da N.F."
   AADD(TB_Campos2,{"WK_TES"    ,,"TES"  }) //"S‚rie NF"
ENDIF
AADD(TB_Campos2,{"WKPO_NUM"  ,,STR0063}) //"N§ P.O."
AADD(TB_Campos2,{"WK_DT_NFE" ,,STR0096}) //"Data da N.F."
nTotImpostos:=0

aCampos:={};aHeader:={}     

nTam:=AVSX3("WZ_CFO",3)+AVSX3("W7_OPERACA",3)+AVSX3("YD_TEC",3)+AVSX3("YD_EX_NCM",3)+AVSX3("YD_EX_NBM",3)

aSemSX3:={{"WKRECNO"   ,"C",06,0},;
{"WKITEM"    ,"C",AVSX3("W7_COD_I",3),0},;
{"WK_IMP"    ,"C",03,0},;
{"WK_NCM"    ,"C",nTam,0},;
{"WK_IMPDESC","C",20,0},;
{"WKPERC"    ,"N",06,2},;
{"WKVALOR"   ,"N",18,7},;          
{"WKVALORUS" ,"N",18,7},;
{"WKBASE"    ,"N",18,7},;
{"WKVLR_CPO" ,"C",10,0},;
{"WKALI_CPO" ,"C",10,0},;
{"WKBAS_CPO" ,"C",10,0}}

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

cFile:=E_CriaTrab(,aTesStru,"WorkTES")
IF ! USED()
   Help("",1,"AVG0000802")//"Nao foi possivel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("WorkTES",cFile+TeOrdBagExt(),"WKRECNO+WK_NCM+WK_IMP")

Work1File:= E_CriaTrab(,aDBF_Stru,"Work1")

IF !USED()
   E_RESET_AREA()
   Help("",1,"AVG0000802")//"Nao foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF

cIndice:="WK_CFO+WK_OPERACA+WKFORN+WKTEC+WKEX_NCM+WKEX_NBM"
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1File +TeOrdBagExt(),cIndice)//1

Work1FileA:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileA+TeOrdBagExt(),"WK_NFE+WK_SE_NFE")//2

Work1FileB:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileB+TeOrdBagExt(),"WKPO_NUM+WKPOSICAO+WKPGI_NUM")//3

Work1FileC:=E_Create(,.F.)//4
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileC+TeOrdBagExt(),"WK_NFE+WK_SE_NFE+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKPO_NUM")//4

Work1FileD:=E_Create(,.F.)//5
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileD+TeOrdBagExt(),"WKFORN+WK_CFO+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKCOD_I+WKPOSICAO")//5

Work1FileE:=E_Create(,.F.)//6
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileE+TeOrdBagExt(),"WKFORN+WK_NFE+WK_SE_NFE+WK_OPERACA+WKTEC+WKEX_NCM+WKEX_NBM+WKPO_NUM")//6

Work1FileF:=E_Create(,.F.)
//MFR OSSME-1974 26/12/2018
IndRegua("Work1",Work1FileF+TeOrdBagExt(),"WK_NFE+WK_SE_NFE+WKFORN+WKLOJA")//7

//MFR OSSME-1974 26/12/2018
SET INDEX TO (Work1File+TeOrdBagExt()),(Work1FileA+TeOrdBagExt()), (Work1FileB+TeOrdBagExt()), (Work1FileC+TeOrdBagExt()), (Work1FileD+TeOrdBagExt()), (Work1FileE+TeOrdBagExt()), (Work1FileF+TeOrdBagExt())


//Work2
Work2File:= E_CriaTrab(,aDBF_Stru2,"Work2")

IF ! USED()
   E_RESET_AREA()
   Help("",1,"AVG0000802")//"Nao foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("Work2",Work2File+TeOrdBagExt(),cIndice)

bSeekWk1:=&("{|| Work2->("+cIndice+")}")
bSeekWk2:=&("{|| Work1->("+cIndice+")}")
bWhileWk:=&("{|| Work2->("+cIndice+") == Work1->("+cIndice+")}")


//Work3
Work3File:= E_CriaTrab(,aDBF_Stru3,"Work3")

IF ! USED()
   E_RESET_AREA()
   Help("",1,"AVG0000802")//"Nao foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("Work3",Work3File+TeOrdBagExt(),"WKRECNO+WKDESPESA+WKFORN+WKLOJA+WK_NF_COMP")

Work3FileA:=E_Create(aDBF_Stru3,.F.)

aWk4Stru:=  {{"WKDESPESA","C",33,0},;
             {"WKFILTRO" ,"C",01,0},;
             {"WKBRANCO" ,"C",01,0},;
             {"WKFLAG"   ,"C",02,0},;
			 {"WKVALOR"  ,"N",18,2},;
			 {"WKFORN"   ,"C",LEN(SA2->A2_COD    ),0},;
			 {"WKLOJA"   ,"C",LEN(SA2->A2_LOJA   ),0},;
			 {"WKDOC"    ,"C",LEN(SWD->WD_NF_COMP),0},;
			 {"WKSEDOC"  ,"C",LEN(SWD->WD_SE_NFC ),0},;
			 {"WKNOTA"   ,"C",LEN(SWD->WD_NF_COMP),0},;
			 {"WKSERIE"  ,"C",LEN(SWD->WD_SE_NFC ),0},;
			 {"WKNOTANEW","C",LEN(SWD->WD_NF_COMP),0},;
			 {"WKSERINEW","C",LEN(SWD->WD_SE_NFC ),0},;
			 {"WKDATA"   ,"D",8,0},;
			 {"WKRECNO"  ,"N",7,0},;
			 {"WKRECNOWK4","N",7,0},;
			 {"WKTES"    ,"C",LEN(SYB->YB_TES   ),0}}

aCampos:={}
//-----------------------------------  Work4
Work4File:=E_CriaTrab(,aWk4Stru,"Work4") 
IF ! USED()
   E_RESET_AREA()
   Help("",1,"AVG0000802")//"Nao foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
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

PRIVATE MDI_OUTR:=MDI_OU_US:=0
PRIVATE lMV_EASY_SIM:=EasyGParam("MV_EASY",,"N")=="S"

lTemDespesas:=.F.
Processa({|| DINCPGrvDespesa() },"Leyendo Gastos...")

IF !lGravaWorks
   nVolta:=DINCPDespTela(.T.)                                
   IF nVolta = 0
      E_RESET_AREA()
      Return .T.
   ENDIF
ENDIF
        
Work4->(DBSETORDER(3))
Work4->(DBGOTOP())
Work4->(DBEVAL({|| Work4->WKFILTRO:=" "}))

SA2->(DbSeek(xFilial("SA2")+SW7->W7_FORN))

IF lGravaWorks
   Processa({|| DINCPGrWorks()},STR0068)//"Pesquisando Informa‡äes..."
ELSE
   Processa({|| DINCPGrava()  },STR0068)//"Pesquisando Informa‡äes..."

   If Empty(MDI_OUTR)
      E_RESET_AREA()
      Help(" ",1,"DI154DESP")//Nao ha  despesas p/ geracao de Nota Fiscal Complementar
      Return .F.
   Endif
   IF Work3->(BOF()) .AND. Work3->(EOF())  // EOS 29/10 
      E_RESET_AREA()
      Return .F.
   ENDIF
ENDIF

IF Work2->(BOF()) .AND. Work2->(EOF())
   IF !lGravaWorks
      E_RESET_AREA()
      Help(" ",1,"EICSEMREG")
      Return .F.
   ENDIF
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
SA2->(DbSeek(xFilial("SA2")+SW7->W7_FORN))

cTit:=cCadastro+" Nota NCP"

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
   nMeio:= 86
                  
   @ nLin,nLin TO nLin+nMeio,249       PIXEL
   @ nLin,250  TO nLin+nMeio,260+nSize PIXEL

   nLin+=04
   @ nLin,nCoL1 SAY AVSX3("W6_HAWB",5) SIZE 58,7 PIXEL
   @ nLin,nCoL2 MSGET SW6->W6_HAWB     WHEN .F. SIZE 58,8 PIXEL

   @ nLin,nCoL3 SAY AVSX3("W6_DT_DESE",5) SIZE 58,7 PIXEL//"Dt.Desembaraço"  
   @ nLin,nCoL4 MSGET SW6->W6_DT_DESE     WHEN .F. SIZE 58,8 PIXEL

   nLin+=12
   @ nLin,nCoL1 SAY STR0084        SIZE 58,7 PIXEL//"Fornecedor"
   IF LEN(aLista) < 2
      @ nLin,nCoL2 MSGET SA2->A2_NOME WHEN .F. SIZE 180,8 PIXEL
   ELSE
      cForn:=aLista[1]
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
   @ nLin,nCoL1 SAY STR0053 SIZE 58,7 PIXEL//"Outras Desp.(R$)"
   @ nLin,nCoL2 MSGET oSayImp   VAR MDI_OUTR     PICTURE PICT15_2 SIZE 58,8 OF oDlg WHEN .F. RIGHT PIXEL

// @ nLin,nCoL3 SAY "Impuestos" SIZE 58,7 PIXEL 
// @ nLin,nCoL4 MSGET oSayImp   VAR nTotImpostos PICTURE PICT15_2 SIZE 58,8 OF oDlg WHEN .F. RIGHT PIXEL

   nLin+=12                                 
   n_VlTota:=DITRANS((nTotImpostos+MDI_OUTR),2)
   @ nLin,nCoL1 SAY "T. General $" SIZE 58,7 PIXEL //"Total Geral (R$)"
   @ nLin,nCoL2 MSGET oSayTotGe VAR n_VlTota     PICTURE PICT15_2 SIZE 58,8 OF oDlg WHEN .F. RIGHT PIXEL

   nLin:=05
   @ nLin,nCoL5 BUTTON STR0103 SIZE nSize,12 ACTION (nOpca:=0,oDlg:End()) OF oDlg PIXEL //"&Sair"
   nLin+=12
   @ nLin,nCoL5 BUTTON STR0085 SIZE nSize,12 ACTION ; //"&Estorno"
                               (IF( MsgYesNo(STR0087,STR0088)#.T.,,(nOpca:=1,oDlg:End()) )); //"Confirma Estorno ?"###"Estorno"
                               WHEN ((lGravaWorks.OR.lGerouNFE) .AND. EMPTY(SW6->W6_DT_ENCE)) OF oDlg PIXEL
   IF !lGravaWorks
      nLin+=12
      @ nLin,nCoL5 BUTTON STR0089 SIZE nSize,12 ACTION ; //"&Itens"
                                  ((nOpca:=2,oDlg:End()) ) OF oDlg PIXEL
   ENDIF

   nLin+=12
   @ nLin,nCoL5 BUTTON STR0276 SIZE nSize,12 ACTION (DINCPDespTela(.F.))  OF oDlg PIXEL //"&Despesas"
   nLin+=12
   @ nLin,nCoL5 BUTTON STR0100 SIZE nSize,12 ACTION (DIMostraTotais()) OF oDlg PIXEL //"&Totais"

   IF lGravaWorks 
      nLin+=12 
      @ nLin,nCoL5 BUTTON STR0278 SIZE nSize,12 ACTION (nOpca:=3,oDlg:End()) OF oDlg PIXEL //"I&mpressão"
   ELSE
      nLin+=12 
      @ nLin,nCoL5 BUTTON "I&mpuestos" SIZE nSize,12 ACTION (DINCPTelaImpostos(.T.)) PIXEL  //MLS
   ENDIF

// nLin+=12 
// @ nLin,nCoL5 BUTTON "Impuestos" SIZE nSize,12 ACTION (DINCPTelaImpostos(!lGravaWorks)) PIXEL

   IF SetMDIChild()
      nMeio:=060
   ENDIF

   IF lGravaWorks
      Work1->(DBSETORDER(5))
      Work1->(DBGOTOP())
      oMark:= MsSelect():New("Work1",,,TB_Campos2,.T.,@cMarca,{nMeio+2,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
   ELSE
      oMark:= MsSelect():New("Work2",,,TB_Campos1,.T.,@cMarca,{nMeio+2,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})
   ENDIF
   oMark:oBrowse:Align:=CONTROL_ALIGN_BOTTOM
   oDlg:lMaximized:=.T.

 IF !lGravaWorks .AND. !lGerouNFE
    oMark:bAval:={|| DINCPTelaImpostos(!lGravaWorks)}
 ENDIF
   
   ACTIVATE MSDIALOG oDlg 

   DO CASE
      CASE nOpca = 0            
           EXIT
      CASE nOpca = 1 
           lNoErro:=.T.
           Processa({|| lNoErro:=DINCPDeleta() },STR0090) //"Processando Estorno..."
           IF !lNoErro
              LOOP
           ENDIF
           EXIT 
      CASE nOpca = 2 ; DINCPItens() // Itens
      CASE nOpca = 3 ; DINCPNFE() //Impressão
   ENDCASE

ENDDO

SW6->(DBGOTO(nReg))

IF SW6->(FIELDPOS("W6_STATUS")) # 0 .AND. SIX->(DBSEEK("SF16")) .AND. FINDFUNCTION("DI156COND")
   DI156COND()
ENDIF

E_RESET_AREA()

Return .T.
*-----------------------------------------*
Function DINCPDespTela(lFlag)
*-----------------------------------------*
LOCAL oDlg,TB_Campos:={},oMarkTela,lTem:=.F.
LOCAL aBotao:={{"DESTINOS",{|| DINCPMark(.T.),oMarkTela:oBrowse:Refresh()},"Marca Todos","Todos"}}
PRIVATE cFiltro:=" "

IF !lGravaWorks
   aAdd(TB_Campos,{"WKFLAG",,""})
ENDIF
IF lFlag
   IF !lTemDespesas
      MSGINFO("No hay gastos p/generacion de N.C.P.")
      RETURN 0
   ENDIF
   Work4->(DBSETORDER(1))
   cFiltro:="S"
   aAdd(TB_Campos,{"WKDOC"  ,,AVSX3("WD_DOCTO",5)}) 
   AADD(TB_Campos,{"WKSEDOC",,AVSX3("WD_SE_DOC",5)})
   aAdd(TB_Campos,{"WKFORN" ,,AVSX3("W2_FORN",5)}) 
   aAdd(TB_Campos,{"WKLOJA" ,,AVSX3("A2_LOJA",5)}) 
ENDIF
aAdd(TB_Campos,{"WKDESPESA",,"Gastos"})
aAdd(TB_Campos,{"WKVALOR"  ,,"Valor $",PICT15_2})
IF !lFlag            
   aBotao:=NIL
   Work4->(DBSETORDER(2))
   aAdd(TB_Campos,{"WKDOC"  ,,AVSX3("WD_DOCTO",5)}) 
   AADD(TB_Campos,{"WKSEDOC",,AVSX3("WD_SE_DOC",5)})
   aAdd(TB_Campos,{"WKFORN" ,,AVSX3("W2_FORN" ,5)}) 
   aAdd(TB_Campos,{"WKLOJA" ,,AVSX3("A2_LOJA" ,5)}) 
ENDIF
aAdd(TB_Campos,{"WKTES"    ,,AVSX3("YB_TES"  ,5)}) 
IF !lFlag            
// aAdd(TB_Campos,{"WKNOTA",,"Factura"}) 
   IF !lGravaWorks
      AADD(TB_Campos,{"WKNOTANEW",,"N.C.P. New"}) 
      AADD(TB_Campos,{"WKSERINEW",,"Serie New"  })
   ENDIF
ENDIF
DO WHILE .T.
   nVolta:=0  
   
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE "Visualiza Gastos";
          FROM 000,oMainWnd:nLeft TO 300,oMainWnd:nRight-25 OF oMainWnd PIXEL

    Work4->(dBGoTop())                         

    DBSELECTAREA("Work4")
    oMarkTela:=MsSelect():NEW("Work4","WKFLAG",,TB_Campos,@lInverte,@cMarca,{015,005,(oDlg:nClientHeight-4)/2,(oDlg:nClientWidth-4)/2},"DINCPFiltra(cFiltro)","DINCPFiltra(cFiltro)")
    oMarkTela:oBrowse:bWhen:={|| DBSELECTAREA("Work4"),.T. }
  
    IF lFlag
       oMarkTela:bAval:={|| DINCPMark(.F.),oMarkTela:oBrowse:Refresh()}
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
//    IF lGrvDespSD1
         SYB->(dbSetOrder(1))
         SB1->(dbSetOrder(1))
         DO WHILE Work4->(!EOF())
            IF !EMPTY(Work4->WKFLAG)
               IF EMPTY(Work4->WKFORN)
                  nVolta:=0
                  MSGINFO("Proveedor no llenado del gasto: " +Work4->WKDESPESA) // 
                  EXIT
               ENDIF
               IF SYB->(dbSeek(xFilial()+Work4->WKDESPESA)) 
                  IF EMPTY(SYB->YB_COD_I)
                     nVolta:=0
                     MSGINFO("Item no llenado del gasto: "+Work4->WKDESPESA) //"Produto nao informado para despesa: " 
                     EXIT
                  ELSEIF !SB1->(dbSeek(xFilial()+SYB->YB_COD_I))
                     nVolta:=0
                     MSGINFO("Produto nao localizado no cad. de Produtos: " +SYB->YB_COD_I)
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
//    ENDIF
      Work4->(DBEVAL({|| lTem:=.T.}, {|| !EMPTY(Work4->WKFLAG) }, {||!lTem} ))
      IF !lTem
          MSGINFO("No hay gastos marcados p/generacion de N.C.P.")
          LOOP
      ENDIF         
   ENDIF

   EXIT

ENDDO

RETURN nVolta
*-----------------------------------------*
Function DINCPMark(lTodos)
*-----------------------------------------*
LOCAL cMarcaNew:=IF(!EMPTY(Work4->WKFLAG),"  ",cMarca)
LOCAL nRecno:=Work4->(Recno())
LOCAL cChave:=Work4->(WKFILTRO+WKDOC+WKFORN+WKLOJA)
LOCAL bFor:={|| !EMPTY(Work4->WKFORN) .AND. !EMPTY(Work4->WKTES) }
LOCAL bWhi:={|| .T. }
LOCAL bGrv:={||Work4->WKFLAG:=cMarcaNew }

Work4->(DBSETORDER(1))
Work4->(DBGOTOP())

IF !lTodos
   bWhi:={|| cChave == Work4->(WKFILTRO+WKDOC+WKFORN+WKLOJA) }
   Work4->(DBSEEK(cChave))     
   IF EMPTY(Work4->WKFORN)
      MSGSTOP("Proveedor no ingresado.")
      RETURN .F.
   ENDIF
   IF EMPTY(Work4->WKTES)
      MSGSTOP("TES no ingresada.")
      RETURN .F.
   ENDIF                                              
ELSE
   Work4->(DBEVAL({||.T.},,{|| EMPTY(Work4->WKFORN) .OR. EMPTY(Work4->WKTES) }))
   cMarcaNew:=IF(!EMPTY(Work4->WKFLAG),"  ",cMarca)
   Work4->(DBGOTOP())
ENDIF
Work4->(DBEVAL(bGrv,bFor,bWhi))

Work4->(DBGOTO(nRecno))
RETURN .T.


*-----------------------------------*
Function DINCPItens()
*-----------------------------------*
LOCAL lInverte := .F., oDlg
LOCAL cBotao:=STR0282
LOCAL nCol:=IF(!lNFAutomatica,31,17)
IF SetMDIChild()
   nCol:=0
ENDIF

PRIVATE nOpca := 0 // POR CAUSA DO BOTAO DO RDMAKE
DO WHILE .T.

   Work1->(DBSETORDER(5))
   Work1->(DBGOTOP())
   nOpca:=0
   
   oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlg TITLE STR0097 ; //"Itens da NF's"
      FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10;
      OF oMainWnd PIXEL  
   
   oMark:= MsSelect():New("Work1","WKFLAG",,TB_Campos2,@lInverte,@cMarca,{nCol,1,(oDlg:nClientHeight-6)/2,(oDlg:nClientWidth-4)/2})

   oMark:bAval:={|| DINCPIt_Alt() ,DBSELECTAREA("Work1"),oMark:oBrowse:Refresh()}
   oMark:oBrowse:bWhen:={|| DBSELECTAREA("Work1"),.T. }
   oMark:oBrowse:Align:=CONTROL_ALIGN_BOTTOM

// @ 04,085 BUTTON "Impuestos / Item"  SIZE 45,11 ACTION (DINCPIt_Alt(),oMark:oBrowse:Refresh());
   @ 04,085 BUTTON "Item"  SIZE 45,11 ACTION (DINCPIt_Alt(),oMark:oBrowse:Refresh());
                                       OF oDlg PIXEL WHEN !lGerouNFE

   @ 04,135 BUTTON STR0272  SIZE 35,11 ACTION (nOpca:=1,oDlg:End()) OF oDlg PIXEL //"&Impressao"

   @ 04,175 BUTTON "Busqueda"  SIZE 30,11 ACTION (DINCPPesquisa(),oMark:oBrowse:Refresh());
                                       OF oDlg PIXEL //"&Pesquisa"

// @ 04,210 BUTTON STR0100  SIZE 30,11 ACTION (DIMostraTotais(),oMark:oBrowse:Refresh());
//                                     OF oDlg PIXEL //"&Totais"
   
   @ 04,241 BUTTON "Genera N.C.P."   SIZE 45,11 ACTION (nOpca:=2,oDlg:End());
                                       OF oDlg PIXEL WHEN (lGeraNF.AND.!lGerouNFE)

   @ 04,290 BUTTON STR0103  SIZE 30,11 ACTION (nOpca:=0,oDlg:End());
                                       OF oDlg PIXEL //"&Sair"

   IF !lNFAutomatica
      @ 17,205 BUTTON STR0098 SIZE 50,11 ACTION (DIMarcados(.T.),oMark:oBrowse:Refresh()) OF oDlg PIXEL WHEN !lGerouNFE//"A&ltera Marcados"

      @ 17,255 BUTTON STR0099 SIZE 55,11 ACTION (DIMarcados(.F.),oMark:oBrowse:Refresh()) OF oDlg PIXEL WHEN !lGerouNFE//"&Marca/Desm. Todos"
   ENDIF
   oDlg:lMaximized:=.T.

   ACTIVATE MSDIALOG oDlg

   IF nOpca=1
      DINCPNFE()
      LOOP
   ENDIF
   
   IF nOpca=2
      Processa({|| DINCPGerNF(@lGerouNFE)},STR0104) //"Geracao de NF's"
      If !lGerouNFE ; LOOP ; ENDIF
   ENDIF

   IF nOpca=0
      EXIT
   ENDIF

ENDDO

Work2->(DBGOTOP())

RETURN .T.

*-----------------------------------*
STATIC Function DIMarcados(lAlt)
*----------------------------------*
LOCAL oDlg, nOpca, nRecno:=Work1->(RECNO())
LOCAL cTit  :=IF(lAlt,(STR0105),STR0106) //"Altera‡Æo dos Itens Marcados"###"Marca / Desmarca Itens"
LOCAL bValid:=IF(lAlt,{||DINCPValid("NFE")      .AND.;
                         DINCPValid("SERIE",.F.).AND.;
                         DINCPValid("DATA")},{||.T.})
LOCAL nCo1:=1, nCo2:=7,nOrd:=Work1->(INDEXORD())
LOCAL nMarca:=1, cChave:=Work1->(WK_NFE+WK_SE_NFE+WKFORN+WKLOJA)
LOCAL cMarcaNew,bWhile

IF lAlt
   nOpca:=.T.
   Work1->( DBGOTOP() )
   Work1->( DBEVAL({|| nOpca:=!Work1->WKFLAG==cMarca },,{||nOpca}) )
   Work1->( DBGOTO(nRecno) )
   IF nOpca
      MSGSTOP("Nao existe registros marcados",STR0022)
      RETURN .F.
   Endif
Endif

cNumNFE  :=Work1->WK_NFE
cSerieNFE:=Work1->WK_SE_NFE
dDtNFE   :=dDataBase
IF !EMPTY(Work1->WK_DT_NFE)
   dDtNFE:=Work1->WK_DT_NFE
ENDIF
nOpca    :=0

DEFINE MSDIALOG oDlg TITLE cTit FROM 9,10 TO 18,48 Of oMainWnd

  IF lAlt

     @1,nCo1 SAY "N.C.P."                                         
     IF !lTravaNF
        @1,14   SAY "Help (F4)"
     ENDIF
     @2,nCo1 SAY "Serie"
     @3,nCo1 SAY "Fecha N.C.P." //"Data da N.F."

     @1,nCo2 MSGET cNumNFE   PICTURE "@!"  SIZE 50,8 WHEN !lTravaNF
     @2,nCo2 MSGET cSerieNFE PICTURE "@!"  SIZE 15,8 WHEN !lTravaNF
     @3,nCo2 MSGET dDtNFE    PICTURE "@D"  SIZE 45,8

  ELSE

     @08,05 TO 45,80 OF oDlg PIXEL

     @16,10 RADIO nMarca ITEMS "Por NCP + Proveedor",;
                               "Todos los Itemes   " SIZE 60,12 PIXEL

  ENDIF

  @22,110 BUTTON STR0111 SIZE 30,12 ACTION (If(EVAL(bValid),(nOpca:=1,oDlg:End()),)) OF oDlg PIXEL //"&OK"

  @35,110 BUTTON STR0103 SIZE 30,12 ACTION (nOpca:=0,oDlg:End())                     OF oDlg PIXEL //"&Sair"


ACTIVATE MSDIALOG oDlg CENTERED

If nOpca = 0
   RETURN .F.
Endif

cMarcaNew:=IF(Work1->WKFLAG==cMarca,"  ",cMarca)

bWhile:={||.T.}

Work1->(DBSETORDER(7))
Work1->(DBGOTOP())

IF !lAlt .AND. nMarca == 1
   bWhile:={|| cChave == Work1->(WK_NFE+WK_SE_NFE+WKFORN+WKLOJA) }
   Work1->(DBSEEK(cChave))
ENDIF

Processa({|| DIGravaAlt(lAlt,bWhile,cMarcaNew)},STR0112) //"Alterando Itens..."

Work1->(DBSETORDER(nOrd))
Work1->(DBGOTO(nRecno))

RETURN .T.

*----------------------------------------------------------------------------*
STATIC Function DIGravaAlt(lAlt,bWhile,cMarcaNew)
*----------------------------------------------------------------------------*
LOCAL nRec
ProcRegua(Work1->(LASTREC()))

DO WHILE !Work1->(EOF()) .AND. EVAL(bWhile)

   IncProc(STR0113+' '+Work1->WKCOD_I) //"Processando Item: "

   IF Work1->WKFLAG == cMarca .AND. lAlt

      Work1->(DBSKIP())
      nRec:=Work1->(RECNO())
      Work1->(DBSKIP(-1))
      IF !lTravaNF
         Work1->WK_NFE   := cNumNFE
         Work1->WK_SE_NFE:= cSerieNFE
      ENDIF
      Work1->WK_DT_NFE:= dDtNFE
      Work1->WKFLAG   := '  '
      DINCPGrvW3W4(cNumNFE,cSerieNFE,dDtNFE)

      Work1->(DBGOTO(nRec))

   ELSEIF !lAlt

      Work1->WKFLAG := cMarcaNew
      Work1->(DBSKIP())

   ELSE
      Work1->(DBSKIP())
   ENDIF

ENDDO

RETURN .T.

*---------------------------------------*
Static Function DIMostraTotais()
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
//DIGerImpostos(cTipoNF = NFE_DESPESAS) //MLS 23/06/04

aAdd(TB_CamposTes,{"WK_IMP"    ,,"Impuesto"}) //"Impuesto"
aAdd(TB_CamposTes,{"WK_IMPDESC",,"Descripción"}) //"Descripción"
aAdd(TB_CamposTes,{"WKBASE"    ,,"Base "+' $',PICT15_2}) //"Base "
aAdd(TB_CamposTes,{"WKBASEUS"  ,,"Base "+' ('+cMoeDolar+')' ,PICT15_2}) //"Base "
aAdd(TB_CamposTes,{"WKVALOR"   ,,"Valor "+' $',PICT15_2}) //"Valor "
aAdd(TB_CamposTes,{"WKVALORUS" ,,"Valor "+' ('+cMoeDolar+')',PICT15_2}) //"Valor "

Processa({|| DI156Soma()},OemToAnsi("Calculando Totais")) //"Calculando Totais"

nVlTota:=DITRANS((nDIFOB+nTotImpostos))

oMainWnd:ReadClientCoords()
DEFINE MSDIALOG oDlgImp TITLE "TOTAIS" ;
       FROM 000,oMainWnd:nLeft TO 380,oMainWnd:nRight-200 PIXEL //"TOTAIS"

   oPnl:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 116, 171)
   oPnl:Align:= CONTROL_ALIGN_TOP

   @ nLin   ,nCo1 SAY "FOB $"     OF oPnl //"FOB (R$)"
   @ nLin+=1,nCo1 SAY "Frete $"   OF oPnl //"Frete (R$)"
   @ nLin+=1,nCo1 SAY "Seguro $"  OF oPnl //"Seguro (R$)"
   @ nLin+=1,nCo1 SAY "Valor "+' ('+cMoeDolar+')' OF oPnl //"Valor "
   nLin:=0.5
   @ nLin   ,nCo2 GET nFobR   WHEN .F. PICTURE PICT15_2 SIZE 55,8 OF oPnl
   @ nLin+=1,nCo2 GET nFrete  WHEN .F. PICTURE PICT15_2 SIZE 55,8 OF oPnl
   @ nLin+=1,nCo2 GET nSeguro WHEN .F. PICTURE PICT15_2 SIZE 55,8 OF oPnl
   @ nLin+=1,nCo2 GET nDolar  WHEN .F. PICTURE PICT15_2 SIZE 55,8 OF oPnl
   nLin:=0.5
   @ nLin   ,nCo3 SAY STR0058+" $" OF oPnl //"Vl. Mercadoria" 
   @ nLin+=1,nCo3 SAY "Impuestos $" OF oPnl       //"Impuestos"
   @ nLin+=1,nCo3 SAY "T. General $" OF oPnl     //"Total Geral"
   nLin:=0.5
   @ nLin   ,nCo4 GET nDIFOB       WHEN .F. PICTURE PICT15_2 SIZE 55,8 OF oPnl
   @ nLin+=1,nCo4 GET nTotImpostos WHEN .F. PICTURE PICT15_2 SIZE 55,8 OF oPnl
   @ nLin+=1,nCo4 GET nVlTota      WHEN .F. PICTURE PICT15_2 SIZE 55,8 OF oPnl
   nLin+=65

   IF !lGravaWorks//cTipoNF = NFE_DESPESAS .OR. cTipoNF = NFE_IMPOSTOS .OR. cTipoNF = CUSTO_REAL
      DBSELECTAREA("WorkTES")
      oMarkTot:=MsSelect():New("WorkTES",,,TB_CamposTes,.F.,cMarca,{nLin,005,nLin+100,(oDlgImp:nClientWidth-4)/2},"DI156Filtra(cFiltro)","DI156Filtra(cFiltro)")
      oMarkTot:oBrowse:bWhen:={|| DBSELECTAREA("WorkTES"),.T. }
      oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT
   ELSE
      oDlgImp:nHeight:=160
      oDlgImp:nWidth :=oDlgImp:nWidth - 60
   ENDIF

ACTIVATE DIALOG oDlgImp ON INIT EnchoiceBar(oDlgImp, { || oDlgImp:End() }, { || oDlgImp:End() },,,,,,,.F.) CENTERED

RETURN NIL

*--------------------------------------*
Function DINCPIt_Alt()
*--------------------------------------*
LOCAL nCo1:=0.8, nCo2:=6.3, nCo3:=20, nCo4:=25, nLin:=1.4
LOCAL oDlgImp
LOCAL TB_Campos:={},oMark1
LOCAL nCif, oDlg, nOpca:=0, nRecno:=Work1->(RECNO())
LOCAL cTit     :=(STR0123) //"Altera‡Æo do Item Atual"

LOCAL nVLMERC :=Work1->WKVALMERC
LOCAL nPreco  :=Work1->WKPRUNI

LOCAL bValid:=IF(!lNFAutomatica,;
              {|| DINCPValid("NFE")       .AND. ;
                  DINCPValid("SERIE",.F.) .AND. ;
                  DINCPValid("DATA")},{||.T.})

PRIVATE cFiltro:=STRZERO(Work1->(RECNO()),6)

aAdd(TB_Campos,{"WK_IMP"    ,,"Impuesto"})
aAdd(TB_Campos,{"WK_IMPDESC",,"Descripción"})
aAdd(TB_Campos,{"WKPERC"    ,,"% Alicuota","@E 999.99"})
aAdd(TB_Campos,{"WKBASE"    ,,"Base $"    ,"@E 99,999,999,999.99"})
aAdd(TB_Campos,{{|| WorkTES->WKBASE/SW6->W6_TX_US_D } ,,"Base "+cMoeDolar,PICT15_2})
aAdd(TB_Campos,{"WKVALOR"   ,,"Valor $"   ,"@E 99,999,999,999.99"})

cCod     :=Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM
cNumNFE  :=Work1->WK_NFE
cSerieNFE:=Work1->WK_SE_NFE
dDtNFE   :=IF(EMPTY(Work1->WK_DT_NFE),dDataBase,Work1->WK_DT_NFE)

DEFINE MSDIALOG oDlgImp TITLE cTit;
       FROM 000,oMainWnd:nLeft+10 TO 150,oMainWnd:nRight-120 OF oMainWnd PIXEL

nLin:=1.4
@nLin   ,nCo1 SAY STR0094 //"N§ da N.F."
@nLin   ,nCo3 SAY "Precio Unitario"
@nLin+=1,nCo1 SAY STR0095 //"S‚rie"
@nLin   ,nCo3 SAY STR0058 //"Vl. Mercadoria"
@nLin+=1,nCo1 SAY STR0096 //"Data da N.F."

nLin:=1.4
//@nLin   ,14   SAY "Help (F4)"
@nLin   ,nCo2 MSGET cNumNFE   PICTURE "@!" VALID DINCPValid("NFE")       SIZE 57,8 WHEN .F.
@nLin+=1,nCo2 MSGET cSerieNFE PICTURE "@!" VALID DINCPValid("SERIE",.F.) SIZE 15,8 WHEN .F.
@nLin+=1,nCo2 MSGET dDtNFE    VALID DINCPValid("DATA")                   SIZE 40,8

nLin:=1.4
@nLin   ,nCo4 MSGET nPreco    PICTURE PICT15_2          SIZE 60,8
@nLin+=1,nCo4 MSGET nVLMERC   PICTURE PICT15_2          SIZE 60,8

nLin+=065

//DBSELECTAREA("WorkTES")
//oMark1:=MsSelect():New("WorkTES",,,TB_Campos,.F.,cMarca,{nLin,005,nLin+100,(oDlgImp:nClientWidth-4)/2},"DINCPFiltra(cFiltro)","DINCPFiltra(cFiltro)")
//oMark1:oBrowse:bWhen:={|| DBSELECTAREA("WorkTES"),.T. }
//oMark1:bAval:={|| DINCPImpAltera(),oMark1:oBrowse:Refresh()}

ACTIVATE DIALOG oDlgImp ON INIT EnchoiceBar(oDlgImp,;
         {||If(EVAL(bValid),(nOpcA:=1,oDlgImp:End()),)},;
         {||nOpcA:=0, oDlgImp:End()}) CENTERED

If nOpca = 0
   Return .F.
Endif

Work1->(DBGOTO(nRecno))

Work1->WK_NFE    := cNumNFE
Work1->WK_SE_NFE := cSerieNFE
Work1->WK_DT_NFE := dDtNFE
Work1->WKVALMERC := nVLMERC
Work1->WKOUT_DESP:= nVLMERC

DINCPGrvW3W4(cNumNFE,cSerieNFE,dDtNFE)

RETURN .T.

/*---------------------------------------*
STATIC Function DINCPImpAltera()
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
DEFINE MSDIALOG oDlg TITLE "Modificacion de Impuesto: "+WorkTES->WK_IMP; 
       FROM 000,oMainWnd:nLeft+10 TO 135,oMainWnd:nRight-550  Of oMainWnd PIXEL

@nLin,1.8 SAY "% Alicuota"
@nLin,6.3 MSGET nPERC  PICTURE "@E 999.99" SIZE 60,8

@nLin+=1,1.8 SAY "Base $"
@nLin   ,6.3 MSGET nBASE  PICTURE PICT15_2    SIZE 60,8

@nLin+=1,1.8 SAY 'Valor $'
@nLin   ,6.3 MSGET nVALOR PICTURE PICT15_2    SIZE 60,8

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,;
{|| If(Eval(bEqual),nOpcA:=0,(nOpcA:=1,oDlg:End()))},;
{|| nOpcA:=0, oDlg:End()}) CENTERED

If nOpcA = 0
   Return .F.
Endif
WorkTES->(DBSEEK("TOTAIS"+SPACE(LEN(cNCM))+cImp))
WorkTES->WKBASE   :=DITRANS((WorkTES->WKBASE -nOldBASE )+nBASE )
WorkTES->WKVALOR  :=DITRANS((WorkTES->WKVALOR-nOldVALOR)+nVALOR)
WorkTES->WKVALORUS:=WorkTES->WKVALOR/SW6->W6_TX_US_D

WorkTES->(DBSEEK("TOTAIS"+cNCM+cImp))
WorkTES->WKBASE   :=DITRANS((WorkTES->WKBASE -nOldBASE )+nBASE )
WorkTES->WKVALOR  :=DITRANS((WorkTES->WKVALOR-nOldVALOR)+nVALOR)
WorkTES->WKVALORUS:=WorkTES->WKVALOR/SW6->W6_TX_US_D

WorkTES->(DBGOTO(nRecno))
WorkTES->WKPERC   :=nPERC
WorkTES->WKBASE   :=nBASE
WorkTES->WKVALOR  :=nVALOR
WorkTES->WKVALORUS:=WorkTES->WKVALOR/SW6->W6_TX_US_D

//Work1->WKIMPOSTOS:=DITRANS((Work1->WKIMPOSTOS-nOldVALOR)+nVALOR)
//nTotImpostos     :=DITRANS((nTotImpostos     -nOldVALOR)+nVALOR)


Return .T.
*/
*----------------------------------------------*
Function DINCPGrWorks()
*----------------------------------------------*
Local cFilSA2:=xFilial("SA2")
LOCAL cFilSWN:=xFILIAL("SWN")
LOCAL cFilSF2:=xFILIAL("SF2")
nContProc:=0
ProcRegua(50)

DINCPIncProc(STR0132) //"Verificando Processo, Aguarde..."

SWN->(DBSETORDER(2))
SF2->(DBSETORDER(7))
SWD->(DBSETORDER(1))
SF2->(DBSEEK(cFilSF2+SW6->W6_HAWB))

DO WHILE SF2->(!EOF())                 .AND.;
         SF2->F2_FILIAL  == cFilSF2    .AND.;
         SF2->F2_HAWB    == SW6->W6_HAWB

   DINCPIncProc(STR0133) //"Lendo Nota Fiscal, Aguarde..."

   IF ASCAN(aNotasDel,SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) = 0
      SF2->(DBSKIP())
      LOOP
   ENDIF

   SWN->(DBSEEK(cFilSWN+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

   DO WHILE SWN->(!EOF())                    .AND.;
            SWN->WN_FILIAL == cFilSWN        .AND.;
            SWN->WN_DOC    == SF2->F2_DOC    .AND.;
            SWN->WN_SERIE  == SF2->F2_SERIE  .AND.;
            SWN->WN_FORNECE== SF2->F2_CLIENTE.AND.;
            SWN->WN_LOJA   == SF2->F2_LOJA

         IF SWN->WN_TIPO_NF # "N" .OR.;
            SWN->WN_HAWB    # SW6->W6_HAWB
            SWN->(DBSKIP())
            LOOP
         ENDIF
         
         DINCPIncProc(STR0133) //"Lendo Nota Fiscal, Aguarde..."

         Work1->(DBAPPEND())
         Work1->WK_NFE     := SWN->WN_DOC
         Work1->WK_NOTA    := SWN->WN_DOC
         Work1->WK_SE_NFE  := SWN->WN_SERIE
         Work1->WKTEC      := SWN->WN_TEC
         Work1->WKEX_NCM   := SWN->WN_EX_NCM
         Work1->WKEX_NBM   := SWN->WN_EX_NBM
         Work1->WKQTDE     := SWN->WN_QUANT   
         Work1->WKPRECO    := SWN->WN_PRECO   
         Work1->WKPO_NUM   := SWN->WN_PO_EIC
         Work1->WKCOD_I    := SWN->WN_PRODUTO
         Work1->WKVALMERC  := SWN->WN_VALOR
         Work1->WK_CFO     := SWN->WN_CFO
         Work1->WK_OPERACA := SWN->WN_OPERACA
//       Work1->WKDESPESA  := SWN->WN_DESCR
         Work1->WKUNI      := SWN->WN_UNI
         Work1->WKPRUNI    := SWN->WN_PRUNI
         Work1->WKPESOL    := SWN->WN_PESOL
         Work1->WKOUT_DESP := SWN->WN_DESPESAS
         Work1->WK_CFO     := SWN->WN_CFO
         Work1->WKOUT_D_US := SWN->WN_OUTR_US
         Work1->WK_CC      := SWN->WN_CC 
         Work1->WKSI_NUM   := SWN->WN_SI_NUM
         Work1->WKFORN     := SWN->WN_FORNECE
         Work1->WKLOJA     := SWN->WN_LOJA
         Work1->WKPOSICAO  := SWN->WN_ITEM    
         Work1->WKPGI_NUM  := SWN->WN_PGI_NUM
         IF SWN->(FIELDPOS("WN_CODESP")) # 0
            SYB->(DbSeek(xFilial("SYB")+SWN->WN_CODESP))
            Work1->WKDESPESA := SWN->WN_CODESP+" "+SYB->YB_DESCR
         ENDIF

         IF SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB+LEFT(Work1->WKDESPESA,3))) .AND. !EMPTY(SWD->WD_TES)
            Work1->WK_TES := SWD->WD_TES
         ELSEIF SYB->(DbSeek(xFilial("SYB")+LEFT(Work1->WKDESPESA,3))) .AND. !EMPTY(SYB->YB_TES)
            Work1->WK_TES := SYB->YB_TES
         ENDIF

         SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))
         IF(ASCAN(aLista,{|F|F=Work1->WKFORN})=0,AADD(aLista,Work1->WKFORN+"-"+SA2->A2_NREDUZ),)

         MDI_OUTR +=Work1->WKOUT_DESP

//       DINCPLerGrvImpostos('LER_SWN')

         SWN->(DBSKIP())

   ENDDO

   SF2->(DBSKIP())

ENDDO

DINCPIncProc() // 100%

DBSELECTAREA("Work1")

Work1->(DBGOTOP())

RETURN .T.
*---------------------------------------*
Function DINCPForDesp()
*---------------------------------------*
LOCAL nTaxa

IncProc("Gastos: "+Work4->WKDESPESA)

IF EMPTY(Work4->WKFLAG)
   RETURN .F.
ENDIF

SWD->(DBGOTO(Work4->WKRECNO))
nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI)
MDI_OUTR +=EVAL(bWD_Valor)
MDI_OU_US+=EVAL(bWD_Valor) / IF(nTaxa#0,nTaxa,1)
DINCPTabDes(aDespesa)

RETURN .T.
*------------------------------------------------------*
Function DINCPGrava()
*------------------------------------------------------*
LOCAL cFilSWD:=xFILIAL("SWD"), Wind, E
LOCAL nRecno:=1,cTam:=AVSX3("B1_VM_P",3)
LOCAL cFilSA2:=xFILIAL("SA2")
LOCAL cFilSA5:=xFILIAL("SA5")
LOCAL cFilSB1:=xFILIAL("SB1")
LOCAL cFilSW2:=xFILIAL("SW2")
LOCAL cFilSW7:=xFILIAL("SW7")
LOCAL cFilSW8:=xFILIAL("SW8")
LOCAL cFilSW9:=xFILIAL("SW9")
LOCAL cFilSWZ:=xFILIAL("SWZ")
LOCAL cFilSYD:=xFILIAL("SYD")
LOCAL cFilSWP:=xFILIAL("SWP")
LOCAL nRatIPD:=0, cFornRat := ""
MDespesas :=nMaior:=nContProc:= 0
aDespesa  := {}; nFobMoeda:=nFobTot:=nPesoL:=0
aDesAcerto:={}
MDI_OUTR  :=MDI_OU_US:=0

ProcRegua(Work4->(LASTREC()))

Work4->(DbEval({|| DINCPForDesp()}))//Ignora despesas com Numero de Nota

IF Empty(MDI_OUTR)
   Return .F.
ENDIF

ProcRegua(50)

DINCPIncProc()

SWZ->(DBSETORDER(2) )
SYB->(DBSETORDER(1) )
SW7->(DBSETORDER(4) )

SW7->(DbSeek(xFILIAL("SW7")+SW6->W6_HAWB))
SW2->(DbSeek(xFilial()+SW7->W7_PO_NUM))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN))

DINCPIncProc()
nFobMoeda:= 0
aTotalForn:={}

SW9->(DBSETORDER(3))
SW9->(DbSeek(cFilSW9+SW6->W6_HAWB))
DO WHILE ! SW9->(EOF()) .AND. SW9->W9_FILIAL == cFilSW9 .AND.;
                              SW9->W9_HAWB == SW6->W6_HAWB
   DINCPIncProc()
   MDespesas +=DITrans(((SW9->W9_INLAND+SW9->W9_PACKING+;
                         SW9->W9_OUTDESP-SW9->W9_DESCONTO)*SW9->W9_TX_FOB),2)
   IF SW9->W9_FREINC $ cNao
      MDespesas +=DITrans(SW9->W9_FRETEIN*SW9->W9_TX_FOB,2)
   ENDIF  

   nFobInv:=DITRANS(SW9->W9_FOB_TOT+SW9->W9_INLAND+SW9->W9_PACKING-SW9->W9_DESCONTO*SW9->W9_TX_FOB,2)
   IF (nPosF:=ASCAN(aTotalForn,{|F| F[1] == SW9->W9_FORN } )) = 0 
      AADD(aTotalForn, {SW9->W9_FORN,nFobInv} )
   ELSE
      aTotalForn[nPosF,2]+=nFobInv
   ENDIF

   SW9->(DBSKIP())
ENDDO

MDI_FOB_R :=SW6->W6_FOB_TOT+DITrans(MDespesas,2)

DINCPIncProc()

SW7->(DbSeek(xFILIAL("SW7")+SW6->W6_HAWB))

aRecWork1:={} 

ProcRegua(SW8->(LASTREC()))

Work1->(dbsetorder(3)) 

SW0->(DBSETORDER(1))
SYQ->(DBSETORDER(1))
SY1->(DBSETORDER(1))
SW9->(DBSETORDER(1))
SW8->(DBSETORDER(1))
SW8->(DBSEEK(cFilSW8+SW6->W6_HAWB))

DO WHILE  !SW8->(EOF()) .AND. SW8->W8_FILIAL == cFilSW8 .AND. SW8->W8_HAWB == SW6->W6_HAWB

   DINCPIncProc(STR0136+' '+SW8->W8_COD_I) //"Lendo Item: "

   SB1->(DbSeek(cFilSB1+SW8->W8_COD_I))
   SW2->(DbSeek(cFilSW2+SW8->W8_PO_NUM))
   SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN))
   DO WHILE !SW9->(EOF()) .AND. SW9->W9_FILIAL  == cFILSW9         .AND.;
                                SW8->W8_INVOICE == SW9->W9_INVOICE .AND.;
                                SW8->W8_FORN    == SW9->W9_FORN   
      IF SW8->W8_HAWB  == SW9->W9_HAWB
         EXIT
      ENDIF
      SW9->(DBSKIP())
   ENDDO

   IF !SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
      Help("",1,"AVG0000804")//"Existe Desbalanceamento no Banco de Dados, por favor saia do Sistema.","Atencao: Arquivo SW8 => SW7")
      RETURN .F.
   ENDIF

   M->WK_TEC    := SW8->W8_TEC
   M->WK_EX_NCM := SW8->W8_EX_NCM
   M->WK_EX_NBM := SW8->W8_EX_NBM

   SA5->(DbSeek(cFilSA5+SW8->W8_COD_I+SW8->W8_FABR+SW8->W8_FORN))
   SA2->(DBSEEK(cFilSA2+SW8->W8_FORN))
   SWP->(DBSEEK(cFilSWP+SW8->W8_PGI_NUM+SW8->W8_SEQ_LI))
   SWZ->(DbSeek(cFilSWZ+SW7->W7_OPERACA))
   SYD->(DbSeek(cFilSYD+M->WK_TEC+M->WK_EX_NCM+M->WK_EX_NBM))

   Work1->(DBAPPEND())
   Work1->WKFORN    := SW8->W8_FORN
   Work1->WKTEC     := M->WK_TEC
   Work1->WKEX_NCM  := M->WK_EX_NCM
   Work1->WKEX_NBM  := M->WK_EX_NBM
   Work1->WKCOD_I   := SW8->W8_COD_I
   Work1->WKPO_NUM  := SW8->W8_PO_NUM
   Work1->WKPOSICAO := SW8->W8_POSICAO
   Work1->WKPGI_NUM := SW8->W8_PGI_NUM
   Work1->WKLOJA    := SA2->A2_LOJA
   Work1->WKQTDE    := SW8->W8_QTDE
   Work1->WKPRECO   := SW8->W8_PRECO
   Work1->WKDESCR   := MEMOLINE(MSMM(SB1->B1_DESC_P,cTam),60)
   Work1->WKUNI     := BUSCA_UM(SW7->W7_COD_I+SW7->W7_FABR +SW7->W7_FORN,SW7->W7_CC+SW7->W7_SI_NUM)//IF(!EMPTY(SA5->A5_UNID),SA5->A5_UNID,SB1->B1_UM)
   Work1->WKRECNO   := SW7->(RECNO())
   Work1->WKPO_SIGA := SW2->W2_PO_SIGA
   Work1->WK_CC     := SW8->W8_CC     
   Work1->WKSI_NUM  := SW8->W8_SI_NUM
   Work1->WK_CFO    := SWZ->WZ_CFO    
   Work1->WK_OPERACA:= SW7->W7_OPERACA
   Work1->WK_REG    := SW8->W8_REG //Campo para procurar o lote e Seg. UM
   Work1->WKINVOICE := SW8->W8_INVOICE
   Work1->WKLOCAL   := SW7->W7_LOCAL
   
   IF !Work2->(DbSeek(EVAL(bSeekWk2)))
      Work2->(DBAPPEND())
      Work2->WKFORN    := SW8->W8_FORN
      Work2->WKTEC     := M->WK_TEC
      Work2->WKEX_NCM  := M->WK_EX_NCM
      Work2->WKEX_NBM  := M->WK_EX_NBM
      Work2->WK_CFO    := SWZ->WZ_CFO
      Work2->WK_OPERACA:= SW7->W7_OPERACA
   ENDIF

   nPesoL    := SW7->W7_PESO * SW8->W8_QTDE
   nFobMoeda := DITrans(SW8->W8_PRECO*SW8->W8_QTDE,2)
   nPrecoReal:= SW8->W8_PRECO_R
   nRatIPD   := DITRANS(SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-SW8->W8_DESCONT+SW8->W8_FRETEIN,2)
   nRatIPD_RS:= DITRANS(nRatIPD*SW9->W9_TX_FOB,2)

   AADD(aRecWork1,Work1->(RECNO()))

   Work1->WKFOB     := DITrans(nFobMoeda+nRatIPD,2)
   Work1->WKFOB_R   := DITrans(nPrecoReal+nRatIPD_RS,2)

   Work1->WKFOB_ORI := DITrans(nFobMoeda+nRatIPD,2)
   Work1->WKFOBR_ORI:= DITrans(nPrecoReal+nRatIPD_RS,2)

   Work1->WKRATEIO  :=(Work1->WKFOBR_ORI/MDI_FOB_R)
   Work1->WKPESOL   := nPesoL

   Work2->WKPESOL   += Work1->WKPESOL
   Work2->WKFOB     += Work1->WKFOB
   Work2->WKFOB_R   += Work1->WKFOB_R
   Work2->WKFOB_ORI += Work1->WKFOB_ORI
   Work2->WKFOBR_ORI+= Work1->WKFOBR_ORI
   Work2->WKQTDE    += Work1->WKQTDE
   Work2->WKSEGURO  += Work1->WKSEGURO

   FOR Wind = 1 TO LEN(aDespesa)
       SWD->(DBGOTO(aDespesa[Wind,4]))
       nRateio:=Work1->WKRATEIO
       IF !EMPTY(SWD->WD_FORNRAT)            
          cFornRat := SWD->WD_FORNRAT
          nRateio:=0
          IF Work1->WKFORN == SWD->WD_FORNRAT
             IF (nPosF:=ASCAN(aTotalForn,{|F| F[1] == SWD->WD_FORNRAT } )) # 0 
                 nRateio:=((nPrecoReal+nRatIPD_RS)/aTotalForn[nPosF,2])
             ENDIF   
          ENDIF
          IF nRateio = 0
             LOOP
          ENDIF
       ENDIF
       cNotaF:= aDespesa[Wind,07]
       cSerie:= aDespesa[Wind,11]
       nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI,.T.,.F.,.T.)     
       IF(nTaxa=0,nTaxa:=1,)
       IF !EMPTY(aDespesa[Wind,09])
          cForn := aDespesa[Wind,09]
          cLoja := aDespesa[Wind,10]
       ELSE
          cForn := Work1->WKFORN
          cLoja := Work1->WKLOJA
       ENDIF
       IF !Work3->(DBSEEK(STRZERO(Work1->(RECNO()),nTamRec)+aDespesa[Wind,1]+cForn+cLoja+cNotaF))
          SYB->(DBSEEK(XFILIAL("SYB")+aDespesa[Wind,1]))
          Work3->(DBAPPEND())
          Work3->WKRECNO   := STRZERO(Work1->(RECNO()),nTamRec)
          Work3->WKFLAG    := aDespesa[Wind,3]
          Work3->WKDESPESA := aDespesa[Wind,1]
          Work3->WKDESCR   := SYB->YB_DESCR
          Work3->WKPO_NUM  := Work1->WKPO_NUM
          Work3->WKPOSICAO := Work1->WKPOSICAO
          Work3->WKPGI_NUM := Work1->WKPGI_NUM
          Work3->WK_NF_COMP:= cNotaF
          Work3->WK_SE_NFC := cSerie
          Work3->WK_DT_NFC := aDespesa[Wind,08]
          Work3->WKFORN    := cForn
          Work3->WKLOJA    := cLoja   //REPLACE WORK3
          IF ASCAN(aLista,{|F|F=cForn})=0
             SA2->(DBSEEK(xFilial("SA2")+cForn+cLoja))
             AADD(aLista,cForn+"-"+SA2->A2_NREDUZ)
          ENDIF
          Work3->WKRECNOWK4:=aDespesa[Wind,05]//Recno do work4
          Work1->WK_NFE_AUX:=aDespesa[Wind,07]//Nota Fiscal
       ENDIF                                   
       nValor:=DITRANS(aDespesa[Wind,2] * (Work1->WKFOBR_ORI/(MDI_FOB_R)) ,2)
       Work3->WKVALOR+= nValor
       Work3->WKVALOR_US:= DITRANS(Work3->WKVALOR/nTaxa,2)

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
   NEXT

   SW8->(DBSKIP())

ENDDO

// EOS - 29/10 - Caso a despesa esteja com o campo WD_FORNRAT preenchido e nao houver 
// items para o rateio das despesas, dar mensagem de aviso.
Work3->(DBGOTOP())
IF Work3->(eof()) .AND. !EMPTY(cFornRat)
   MSGINFO("No hay items para el proveedor: "+ cFornRat +" p/ prorrateo de los gastos!")
   RETURN .F.
ENDIF
   
FOR E=1 TO LEN(aDesAcerto)
    IF aDesAcerto[E,2] # aDesAcerto[E,4]
       Work3->(DBGOTO(aDesAcerto[E,6]))
       Work3->WKVALOR   :=Work3->WKVALOR   +(aDesAcerto[E,4]-aDesAcerto[E,2])
    ENDIF
    IF aDesAcerto[E,3] # aDesAcerto[E,5]
       Work3->(DBGOTO(aDesAcerto[E,6]))
       Work3->WKVALOR_US:=Work3->WKVALOR_US+(aDesAcerto[E,5]-aDesAcerto[E,3])
    ENDIF
NEXT

Work3->(DBGOTOP())
Work2->(DBGOTOP())

ProcRegua( Work2->( LASTREC() ) )

nOUTRDESP:=nOUTRD_US:=nMaior:=0

DO WHILE  Work2->(!EOF())

   IncProc("Prorrateo de las NCMs")

   Work2->WKOUTRDESP:= DITRANS(MDI_OUTR *(Work2->WKFOBR_ORI/MDI_FOB_R),2)
   Work2->WKOUTRD_US:= DITRANS(MDI_OU_US*(Work2->WKFOBR_ORI/MDI_FOB_R),2)

   nOUTRDESP += Work2->WKOUTRDESP
   nOUTRD_US += Work2->WKOUTRD_US

   IF Work2->WKOUTRDESP > nMaior
      nMaior:=Work2->WKOUTRDESP
      nRecno:=Work2->(RECNO())
   ENDIF  

   DINCPRateio()

   //   o fob em reais deve ser zerado apos o rateio, para nf complementar
   Work2->WKFOB  :=0
   Work2->WKFOB_R:=0
   
   Work2->(DBSKIP())
ENDDO

Work2->(DBGOTO(nRecno))

IF DiTrans( MDI_OUTR,2 ) # DiTrans( nOUTRDESP,2 )
   Work2->WKOUTRDESP += DiTrans( MDI_OUTR ,2 ) - DiTrans( nOUTRDESP,2 )
ENDIF

IF DiTrans( MDI_OU_US,2 ) # DiTrans( nOUTRD_US,2 )
   Work2->WKOUTRD_US += DiTrans( MDI_OU_US ,2 ) - DiTrans( nOUTRD_US,2 )
ENDIF

DBSELECTAREA("Work2")

DINCPIncProc()

Processa({|| ICGeraDespesas() } ,"Prorrateo de los Gastos...")

//Processa({|| ICGeraImpostos() } ,"Generando Impuestos...")
Processa({|| DIGerImpostos(cTipoNF = NFE_DESPESAS) } ,"Generando Impuestos...")//MLS 23/06/04

RETURN .T.
*----------------------------------------------------------------------------*
Function DINCPIncProc(cMsg)
*----------------------------------------------------------------------------*
IF nContProc > 50
   ProcRegua(50)
   nContProc:=0
ENDIF   
nContProc++
IncProc(cMsg)
RETURN .T.     
*----------------------------------------------------------------------------*
Function DINCPGrvDespesa()// AWR 03/08/2000
*----------------------------------------------------------------------------*
LOCAL aDoc:={}
SYB->(DBSETORDER(1))
SWD->(DBSETORDER(1))
SWD->(DbSeek((xFilSWD:=xFilial("SWD"))+SW6->W6_HAWB))

ProcRegua(10)

Work4->(__DBZAP())

DO WHILE  xFilSWD == SWD->WD_FILIAL .AND. SWD->WD_HAWB==SW6->W6_HAWB .AND. !SWD->(EOF())

   DINCPIncProc("Gastos: "+SWD->WD_DESPESA) 

   Work4->(DBAPPEND())
   SYB->(DBSEEK(xFilSYB+SWD->WD_DESPESA))  // JBS - 28/10/2003                
   
   IF SWD->(FIELDPOS("WD_TES")) > 0 .AND. !EMPTY(SWD->WD_TES)
      Work4->WKTES:=SWD->WD_TES
   ELSE //IF SYB->(found())  // JBS - 28/10/2003
      Work4->WKTES:=SYB->YB_TES
   ENDIF
   Work4->WKFLAG   :=''
   Work4->WKDESPESA:=SWD->WD_DESPESA+" - "+SYB->YB_DESCR
   Work4->WKVALOR  :=EVAL(bWD_Valor)

   Work4->WKDOC    :=SWD->WD_DOCTO
   Work4->WKSEDOC  :=SWD->WD_SE_DOC

   Work4->WKNOTA   :=SWD->WD_NF_COMP
   Work4->WKSERIE  :=SWD->WD_SE_NFC

   Work4->WKFORN   :=SWD->WD_FORN
   Work4->WKLOJA   :=SWD->WD_LOJA
   Work4->WKDATA   :=SWD->WD_DT_NFC
   Work4->WKRECNO  :=SWD->(RECNO())
   IF !LEFT(Work4->WKDESPESA,1) $ "1,2,9" .AND.;
      EMPTY(Work4->WKNOTA) .AND. SWD->WD_VALOR_R < 0
      Work4->WKFILTRO:="S"
      IF !EMPTY(Work4->WKFORN) .AND. !EMPTY(Work4->WKTES)
         lTemDespesas    :=.T.
         Work4->WKFLAG   :=cMarca
         Work4->WKNOTANEW:=SWD->WD_DOCTO
         Work4->WKSERINEW:=SWD->WD_SE_DOC
      ENDIF
   ENDIF
   IF !EMPTY(Work4->WKDOC) .AND. ASCAN(aDoc,Work4->WKDOC)=0
      AADD(aDoc,Work4->WKDOC)
      Work4->WKBRANCO :="N"
   ENDIF
   SWD->(DBSKIP())

ENDDO                    

Return NIL

*----------------------------------------------------------------------------*
Function DINCPRateio()
*----------------------------------------------------------------------------*
LOCAL nRec, nValMerc:= nDesp:= nDesp_US:= 0
LOCAL nMaior := 0

Work1->(DBSETORDER(1))
IF !Work1->(DbSeek(EVAL(bSeekWk1)))
   MSGSTOP("Existe Desbalanceamento no Banco de Dados, por favor saia do Sistema")
   RETURN .F.
ENDIF
nRec  :=Work1->(RECNO())
nMaior:=Work1->WKVALMERC

DO WHILE !Work1->(EOF()) .AND. EVAL(bWhileWk)

  Work1->WKVALMERC := DITrans(Work2->WKOUTRDESP * Work1->WKRATEIO,2)
  Work1->WKOUT_DESP:= DITrans(Work2->WKOUTRDESP * Work1->WKRATEIO ,2)
  Work1->WKOUT_D_US:= DITrans(Work2->WKOUTRD_US * Work1->WKRATEIO ,2)
  Work1->WKPRUNI   := Work1->WKVALMERC / Work1->WKQTDE

  IF Work1->WKVALMERC > nMaior
     nMaior:= Work1->WKVALMERC
     nRec  := Work1->(RECNO())
  ENDIF

  nDesp    += Work1->WKOUT_DESP
  nDesp_US += Work1->WKOUT_D_US
  nValMerc += Work1->WKVALMERC

  Work1->WKFOB  := 0
  Work1->WKFOB_R:= 0
     
  Work1->(DBSKIP())

ENDDO

Work1->(DBGOTO(nRec)) // posiciona no primeiro item da nbm

IF nDesp # (Work2->WKOUTRDESP)
   Work1->WKOUT_DESP += (Work2->WKOUTRDESP)-DITrans(nDesp,2)
ENDIF

IF nDesp_US # Work2->WKOUTRD_US
   Work1->WKOUT_D_US += (Work2->WKOUTRD_US)-DITrans(nDesp_US,2)
ENDIF

IF nValMerc # (Work2->WKOUTRDESP)
   Work1->WKVALMERC+=(Work2->WKOUTRDESP) - DITrans(nValMerc,2)
ENDIF

RETURN .T.
*-----------------------------------------------------------------------*
Function DINCPGerNF(lGerouNFE)
*-----------------------------------------------------------------------*
LOCAL nRec1:=Work1->(RecNo())
LOCAL nRec2:=Work2->(RecNo())
LOCAL nRec3:=Work3->(RecNo())
LOCAL cTec,cExNCM,cExNBM

PRIVATE cOperacao,cCFO
PRIVATE cNumero, cSerie, nItem:= 0
PRIVATE cForn :="",aValores:={}

dDtNFE:=IF(EMPTY(dDtNFE),dDataBase,dDtNFE)

SW7->(DBSEEK(xFilial("SW7")+SW6->W6_HAWB))
SA2->(DBSEEK(xFilial("SA2")+SW7->W7_FORN))

IF lNFAutomatica

   ProcRegua(Work1->(LASTREC()))

   Work2->(DBSETORDER(1))
   Work1->(DBSETORDER(7))
   Work1->(DBGOTOP())
   nItem:=0
   cForn:=""
   cCFO :=""     
   cOperacao :=""

   DO WHILE !Work1->(EOF())

      IncProc(STR0150) //"Gerando Nota Fiscal"

      IF nItem >= EasyGParam("MV_NUMITEN") .OR.;
         cForn # Work1->WKFORN+Work1->WKLOJA .OR.;
         nItem == 0 .OR. cCFO # Work1->WK_CFO .OR.;
         (lQuebraOperacao .AND. cOperacao # Work1->WK_OPERACA)
         
         cNumero:=""
                 
         DO WHILE !SX5NumNota(.F.)
         ENDDO
         NxTSx5Nota(cSerie,.T.)
              
         nItem:=0
         cForn    := Work1->WKFORN+Work1->WKLOJA
         cCFO     := Work1->WK_CFO
         cOperacao:= Work1->WK_OPERACA
      ENDIF
      nItem++

      Work1->WK_NFE   :=cNumero
      Work1->WK_SE_NFE:=cSerie
      Work1->WK_DT_NFE:=dDtNFE

      DINCPGrvW3W4(cNumero,cSerie,dDtNFE)
      
      Work1->(DBSKIP())

   ENDDO


ELSEIF !lNFAutomatica
   Work1->(DBSETORDER(7))
   Work1->(DBGOTOP())
   DO WHILE !Work1->(EOF())
      IF EMPTY(Work1->WK_NFE)
         Help("",1,"AVG0000806")//"Existem Notas Fiscais nao informadas",0022)
         RETURN .F.
      ENDIF
      Work1->(DBSKIP())
   ENDDO
ENDIF

ProcRegua(Work1->(LASTREC()))

Work2->(DBSETORDER(1))
Work1->(DBSETORDER(7))
Work1->(DBGOTOP())

cOperacao:=Work1->WK_OPERACA
cExNCM:=Work1->WKEX_NCM
cExNBM:=Work1->WKEX_NBM
cTec  :=Work1->WKTEC
nNFE  :=Work1->WK_NFE
nSerie:=Work1->WK_SE_NFE
cForn :=Work1->WKFORN+Work1->WKLOJA
dDtNFE:=Work1->WK_DT_NFE
nDespesa:=0
nItem:=0
lGerouNFE :=.F.
nNFEAux  :=""
nSerieAux:="" 
aCab  :={}//Para gravacao da Microsiga
aItens:={}//Para gravacao da Microsiga
lMSErroAuto := .F. 
lMSHelpAuto := .F. // para mostrar os erros na tela

SC1->(DBSETORDER(1))
SB1->(DBSETORDER(1))
SB1->(DbSeek(xFilial("SB1")+EasyGParam("MV_PRODIMP")))

Begin Transaction

Begin SEQUENCE

SW6->(RecLock("SW6",.F.))

DINCPSWNGrv()

ProcRegua(Work1->(LASTREC()))
Work1->(DbGoTop())

DO WHILE !Work1->(EOF())

   IncProc(STR0151) //"Gravando Nota Fiscal"

      IF nNFE # Work1->WK_NFE .OR. nSerie # Work1->WK_SE_NFE .OR. cForn # Work1->WKFORN+Work1->WKLOJA

         IF !DINCPCapNF()
            EXIT
         ENDIF
         aItens:={}//Limpa os itens da tabela para nao acumular para a proxima nota
         nNFE  :=Work1->WK_NFE
         nSerie:=Work1->WK_SE_NFE
         cForn :=Work1->WKFORN+Work1->WKLOJA
         dDtNFE:=Work1->WK_DT_NFE
         nItem:=0
         nDespesa:=0

      ENDIF
      nItem++

      // O Seek do Work2 e do SA2 esta antes do Skip do Work1 para incluir os dados, na Capa, do Registro certo do Work2 e do SA2
      Work2->(DBSEEK(EVAL(bSeekWk2)))
      SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))//AWR 21/03/2001
      
//    DINCPGrvSD2()
//    aGrvImpSD:={}
//    DINCPLerGrvImpostos("GRAVA_SD",aGrvImpSD)
//    nUltReg:=LEN(aItens)
//    FOR Imp := 1 TO LEN(aGrvImpSD)
//        AADD( aItens[nUltReg] , ACLONE(aGrvImpSD[Imp]) )
//    NEXT
//    IF !lMV_EASY_SIM .AND. nUltReg # 0
//       SD2->(RecLock("SD2",.T.))
//       SD2->D2_FILIAL := xFilial("SD2")
//       FOR GRV := 1 TO LEN(aItens[nUltReg]) 
//           IF ( nPos:=SD2->( FIELDPOS(aItens[nUltReg,GRV,1]) ) ) # 0
//              SD2->( FIELDPUT(nPos,aItens[nUltReg,GRV,2]) )
//           ENDIF
//       NEXT
//       SD2->(MsUnlock())
//    ENDIF
///   nDespesa    +=Work1->WKOUT_DESP
   
   Work1->(DbSkip())

ENDDO

IF !lMSErroAuto
   DINCPCapNF()
ENDIF

IF lMSErroAuto 
   
   ProcRegua(Work1->(LASTREC()))
   Work1->(DBGOTOP())
   DO WHILE !Work1->(EOF())
      IncProc(STR0151) //"Gravando Nota Fiscal"

      SWN->(DBGOTO(Work1->WK_REC_SWN))
      SWN->(RecLock("SWN",.F.))
      SWN->(DBDELETE())
      Work1->(DbSkip())

   ENDDO

   BREAK
ENDIF

ProcRegua(Work4->(LASTREC()))

Work4->(DBGOTOP())
DO While Work4->(!EOF())
   IncProc(STR0152+Work4->WKDESPESA)//"Gravando Despesas: "
   IF !EMPTY(Work4->WKFLAG) .AND. !LEFT(Work4->WKDESPESA,1) $ "1,2,9"
      SWD->(DBGOTO(Work4->WKRECNO))
      SWD->(RecLock("SWD",.F.))
      SWD->WD_NF_COMP:=Work4->WKNOTANEW
      SWD->WD_SE_NFC :=Work4->WKSERINEW
      SWD->WD_DT_NFC :=Work4->WKDATA
      SWD->(MsUnlock())
   ENDIF
   Work4->(DBSKIP())
ENDDO

End SEQUENCE

SW6->(MsUnlock())

End Transaction

Work1->(DBSETORDER(1))
Work1->(DbGoto(nRec1))
Work2->(DbGoto(nRec2))
Work3->(DbGoto(nRec3))

IF !lMSErroAuto 
   lGerouNFE:=.T.
   MSGINFO(STR0153,STR0108) //"Geracao de Nota Fiscal Concluida"###"Informação"
ENDIF

Return .T.
*--------------------------------------------------------------------------------------*
Function DINCPSWNGrv()
*--------------------------------------------------------------------------------------*
ProcRegua(Work1->(LASTREC()))

DBSELECTAREA("Work1")

Work1->(DBSETORDER(7))
Work1->(DBGOTOP())
nNFE  :=Work1->WK_NFE
nSerie:=Work1->WK_SE_NFE
cForn :=Work1->WKFORN+Work1->WKLOJA
dDtNFE:=Work1->WK_DT_NFE
nItem :=0
nNFEAux  :=""
nSerieAux:="" 

SB1->(DBSETORDER(1))

DO WHILE !Work1->(EOF())

   IncProc(STR0151) //"Gravando Nota Fiscal"

   SA2->(DBSEEK(xFilial("SA2")+Work1->WKFORN+Work1->WKLOJA))

   SWN->(RecLock("SWN",.T.))
   SWN->WN_FILIAL   := xFilial("SWN")
   SWN->WN_TIPO_NF  := "N"
   SWN->WN_HAWB     := SW6->W6_HAWB
   SWN->WN_DOC      := Work1->WK_NFE
   SWN->WN_SERIE    := Work1->WK_SE_NFE
   SWN->WN_TEC      := Work1->WKTEC
   SWN->WN_EX_NCM   := Work1->WKEX_NCM
   SWN->WN_EX_NBM   := Work1->WKEX_NBM
   SWN->WN_PO_EIC   := Work1->WKPO_NUM
   SWN->WN_PO_NUM   := Work1->WKPO_SIGA
   SWN->WN_ITEM     := Work1->WKPOSICAO
   SWN->WN_QUANT    := Work1->WKQTDE
   SWN->WN_PRECO    := Work1->WKPRECO
   SWN->WN_UNI      := Work1->WKUNI
   SWN->WN_LOCAL    := Work1->WKLOCAL
   SWN->WN_PRODUTO  := Work1->WKCOD_I
   SWN->WN_VALOR    := Work1->WKVALMERC
   SWN->WN_OPERACA  := Work1->WK_OPERACA
   SWN->WN_FORNECE  := Work1->WKFORN
   SWN->WN_LOJA     := Work1->WKLOJA
// SWN->WN_DESCR    := Work1->WKDESPESA
   SWN->WN_PRUNI    := Work1->WKPRUNI
   SWN->WN_RATEIO   := DITRANS(Work1->WKRATEIO,9)
   SWN->WN_PESOL    := Work1->WKPESOL
   SWN->WN_DESPESAS := Work1->WKOUT_DESP
   SWN->WN_SI_NUM   := Work1->WKSI_NUM
   SWN->WN_CC       := Work1->WK_CC
   SWN->WN_CFO      := Work1->WK_CFO
   SWN->WN_OUTR_US  := Work1->WKOUT_D_US
   SWN->WN_PGI_NUM  := Work1->WKPGI_NUM
   SWN->WN_INVOICE  := Work1->WKINVOICE
   IF SWN->(FIELDPOS("WN_CODESP")) # 0
      SWN->WN_CODESP := LEFT(Work1->WKDESPESA,LEN(SWD->WD_DESPESA))
   ENDIF

   Work1->WK_REC_SWN:= SWN->(RECNO())
   SWN->(MsUnlock())

   Work1->(DbSkip())

ENDDO

Return .T.

/*--------------------------------------------------------------------------------------*
STATIC Function DINCPGrvSD2()
*--------------------------------------------------------------------------------------*
LOCAL GRV

SC7->(DBSETORDER(1))
SC7->(DBSEEK(xFilial()+Work1->WKPO_SIGA+Work1->WKPOSICAO))
SB1->(DbSeek(xFilial()+Work1->WKCOD_I))
aItem:={}
AADD(aItem,{"D2_COD"         ,Work1->WKCOD_I   ,NIL})// codigo do produto
AADD(aItem,{"D2_QUANT"       ,1                ,NIL}) // quantidade do produto
AADD(aItem,{"D2_PRUNIT"      ,Work1->WKVALMERC  ,NIL}) // valor unitario do item
AADD(aItem,{"D2_PRCVEN"      ,Work1->WKVALMERC  ,NIL}) // valor unitario do item
AADD(aItem,{"D2_TOTAL"       ,Work1->WKVALMERC ,NIL})  // valor total do item (quantidade * preco)
If !Empty(Work1->WK_CFO)
   AADD(aItem,{"D2_CF"       ,Work1->WK_CFO    ,NIL})  // Classificacao Fiscal                                                
ENDIF
AADD(aItem,{"D2_DESC"        ,0                ,NIL})
AADD(aItem,{"D2_DESCON"      ,0                ,NIL})
AADD(aItem,{"D2_TES"         ,Work1->WK_TES    ,NIL})
AADD(aItem,{"D2_CLIENTE"     ,Work1->WKFORN    ,NIL})
AADD(aItem,{"D2_LOJA"        ,Work1->WKLOJA    ,NIL})
AADD(aItem,{"D2_LOCAL"       ,Work1->WKLOCAL   ,NIL})
AADD(aItem,{"D2_DOC"         ,Work1->WK_NFE    ,NIL})
AADD(aItem,{"D2_SERIE"       ,Work1->WK_SE_NFE ,NIL})
AADD(aItem,{"D2_EMISSAO"     ,Work1->WK_DT_NFE ,NIL})
AADD(aItem,{"D2_TIPO"        ,"D"              ,NIL})
AADD(aItem,{"D2_CONTA"       ,SB1->B1_CONTA    ,NIL})
AADD(aItem,{"D2_CCUSTO"      ,SB1->B1_CC       ,NIL})
AADD(aItem,{"D2_GRUPO"       ,SB1->B1_GRUPO    ,NIL})
AADD(aItem,{"D2_TP"          ,SB1->B1_TIPO     ,NIL})
AADD(aItem,{"D2_NUMSEQ"      ,ProxNum()        ,NIL})
AADD(aItem,{"D2_HAWB"        ,SW6->W6_HAWB     ,NIl})
AADD(aItem,{"D2_ITEM"        ,STRZERO(nItem,2) ,NIL})
AADD(aItem,{"D2_ESPECIE"     ,'NCP'            ,NIL})
AADD(aItens,ACLONE(aItem))

RETURN .T.*/

*--------------------------------*
Function DINCPCapNF()
*--------------------------------*
LOCAL GRV,cChaveSF2,aCab
PRIVATE cNatureza:=""
DIRefaz()

cChaveSF2:=nNFE+nSerie+cForn//+"D"
AADD(aNotasDel,nNFE+nSerie+cForn)
SA2->(DBSEEK(xFilial("SA2")+cForn))//AWR 11/04/2003

aCab := {}
AADD(aCab,{"F2_TIPO"        ,"D"               ,".T."})// TIPO DA NOTA - "N"ORMAL OU "C"OMPLEMENTAR
AADD(aCab,{"F2_DOC"         ,nNFE              ,".T."})   // NUMERO DA NOTA
AADD(aCab,{"F2_SERIE"       ,nSerie            ,".T."})   // SERIE DA NOTA
AADD(aCab,{"F2_EMISSAO"     ,dDtNFE            ,".T."})   // DATA DA EMISSAO DA NOTA                                 
AADD(aCab,{"F2_DTLANC"      ,dDataBase         ,".T."})
AADD(aCab,{"F2_LOJA"        ,RIGHT(cForn,2)     ,".T."})   // LOJA DO FORNECEDOR 
AADD(aCab,{"F2_CLIENTE"     ,LEFT(cForn,LEN(SA2->A2_COD)) ,".T."})   // FORNECEDOR  
AADD(aCab,{"F2_FORMUL"      ,"S"               ,".T."})
AADD(aCab,{"F2_COND"        ,"001"             ,".T."})
AADD(aCab,{"F2_DESCONT"     ,0                 ,".T."})
AADD(aCab,{"F2_TIPODOC"     ,'07'              ,".T."})// Conforme falado com Marcelo Grabiel da Microsiga - 16/08/2004
AADD(aCab,{"F2_VALMERC"     ,nDespesa          ,".T."})
AADD(aCab,{"F2_VALBRUT"     ,nDespesa          ,".T."})
AADD(aCab,{"F2_DESPESA"     ,0                 ,".T."})
AADD(aCab,{"F2_ESPECIE"     ,"NCP"             ,".T."})
AADD(aCab,{"F2_DUPL"        ,nNFE              ,".T."}) 
AADD(aCab,{"F2_EST"         ,"EX"              ,".T."}) 
AADD(aCab,{"F2_VALFAT"      ,nDespesa          ,".T."})
AADD(aCab,{"F2_NATUREZ"     ,cNatureza         ,".T."})
AADD(aCab,{"F2_TXMOEDA"     ,1                 ,".T."})
AADD(aCab,{"F2_MOEDA"       ,1                 ,".T."})
AADD(aCab,{"F2_HAWB"        ,SW6->W6_HAWB      ,".T."})
AADD(aCab,{"F2_TIPOCLI"     ,SA2->A2_TIPO      ,})

IF lMV_EASY_SIM

   MSExecAuto({|x,y| MATA466N(x,y)},aCab,aItens)
   IF lMSErroAuto           
      MostraErro()
      RETURN .F.
   ENDIF               
   IF (nPos:=ASCAN(aCab,{ |A| A[1]="F2_EST" } )) # 0
      SF2->(DBSETORDER(1))
      IF SF2->(DBSEEK(xFilial()+cChaveSF2))
         SF2->(RecLock("SF2",.F.))
         FOR GRV := nPos TO LEN(aCab) 
             IF ( nPos:=SF2->( FIELDPOS(aCab[GRV,1]) ) ) # 0
                SF2->( FIELDPUT(nPos,aCab[GRV,2]) )
             ENDIF
         NEXT
//       DINCPGrvImpostos("SF2")
         SF2->(MsUnlock())
      ELSE         
         MSGSTOP(STR0038+": ( "+cChaveSF2+" ) "+STR0036,STR0022)
         lMSErroAuto:=.T.
         RETURN .F.
      ENDIF
   ENDIF

ELSE

   SF2->(RecLock("SF2",.T.))
   SF2->F2_FILIAL := xFilial("SF2")
   FOR GRV := 1 TO LEN(aCab) 
       IF ( nPos:=SF2->( FIELDPOS(aCab[GRV,1]) ) ) # 0
          SF2->( FIELDPUT(nPos,aCab[GRV,2]) )
       ENDIF
   NEXT
// DINCPGrvImpostos("SF2")
   SF2->(MsUnlock())

ENDIF                  

RETURN .T.

*--------------------------------------*
Function DINCPDeleta()
*--------------------------------------*
LOCAL nCont:=0
LOCAL aItem,aItens,aCab
PRIVATE cFilSF2:=xFILIAL("SF2")
PRIVATE cFilSD2:=xFILIAL("SD2")

lMSErroAuto:=.F. 
lMSHelpAuto:=.F.
nContProc  := 0
ProcRegua(50)

DINCPIncProc(STR0157) //"Estornando Nota Fiscal"

Begin Transaction

   SW6->(RecLock("SW6",.F.))
   SD2->(DBSETORDER(3))
   SF2->(DBSETORDER(7))

   aItens:={}
   SF2->(DBSEEK(cFilSF2+SW6->W6_HAWB))

   DO WHILE SF2->(!EOF())                  .AND.;
         SF2->F2_FILIAL  == xFilial("SF2") .AND.;
         SF2->F2_HAWB    == SW6->W6_HAWB

      DINCPIncProc(STR0157) //"Estornando Nota Fiscal"

      IF ASCAN(aNotasDel,SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) = 0
         SF2->(DBSKIP())
         LOOP
      ENDIF

      SD2->(DBSEEK(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))

      DO WHILE SD2->(!EOF())                 .AND.;
            SD2->D2_FILIAL == xFilial("SD2") .AND.;
            SD2->D2_DOC    == SF2->F2_DOC    .AND.;
            SD2->D2_SERIE  == SF2->F2_SERIE  .AND.;
            SD2->D2_CLIENTE== SF2->F2_CLIENTE.AND.;
            SD2->D2_LOJA   == SF2->F2_LOJA

         DINCPIncProc()
         IF lMV_EASY_SIM
            aItem:={}
            AADD(aItem,{"D2_COD"         ,SD2->D2_COD    ,})
            AADD(aItem,{"D2_QUANT"       ,SD2->D2_QUANT  ,})
            AADD(aItem,{"D2_PRUNIT"      ,SD2->D2_PRUNIT ,})
            AADD(aItem,{"D2_PRCVEN"      ,SD2->D2_PRCVEN ,})
            AADD(aItem,{"D2_TES"         ,SD2->D2_TES    ,})
            AADD(aItem,{"D2_TOTAL"       ,SD2->D2_TOTAL  ,})
            AADD(aItem,{"D2_CLIENTE"     ,SD2->D2_CLIENTE,})
            AADD(aItem,{"D2_LOJA"        ,SD2->D2_LOJA   ,})
            AADD(aItem,{"D2_LOCAL"       ,SD2->D2_LOCAL  ,})
            AADD(aItem,{"D2_DOC"         ,SD2->D2_DOC    ,})
            AADD(aItem,{"D2_SERIE"       ,SD2->D2_SERIE  ,})
            AADD(aItem,{"D2_EMISSAO"     ,SD2->D2_EMISSAO,})
            AADD(aItem,{"D2_TIPO"        ,SD2->D2_TIPO   ,})
            AADD(aItem,{"D2_CONTA"       ,SD2->D2_CONTA  ,})
            AADD(aItem,{"D2_CCUSTO"      ,SD2->D2_CCUSTO ,})
            AADD(aItem,{"D2_GRUPO"       ,SD2->D2_GRUPO  ,})
            AADD(aItem,{"D2_TP"          ,SD2->D2_TP     ,})
            AADD(aItem,{"D2_NUMSEQ"      ,SD2->D2_NUMSEQ ,})
            AADD(aItem,{"D2_ITEM"        ,SD2->D2_ITEM   ,})
            AADD(aItem,{"D2_ESPECIE"     ,SD2->D2_ESPECIE,})
            AADD(aItens,ACLONE(aItem))
         ELSE
            SD2->(RecLock("SD2",.F.,.T.))
            SD2->(DBDELETE())
            SD2->(MsUnlock())
         ENDIF 
         SD2->(DbSkip())

      ENDDO

      DINCPIncProc()

      IF lMV_EASY_SIM
         aCab := {}
         AADD(aCab,{"F2_TIPO"    ,SF2->F2_TIPO   ,})
         AADD(aCab,{"F2_DOC"     ,SF2->F2_DOC    ,})
         AADD(aCab,{"F2_SERIE"   ,SF2->F2_SERIE  ,})
         AADD(aCab,{"F2_EMISSAO" ,SF2->F2_EMISSAO,})
         AADD(aCab,{"F2_DTLANC"  ,SF2->F2_DTLANC ,})
         AADD(aCab,{"F2_LOJA"    ,SF2->F2_LOJA   ,})
         AADD(aCab,{"F2_CLIENTE" ,SF2->F2_CLIENTE,})
         AADD(aCab,{"F2_FORMUL"  ,SF2->F2_FORMUL ,})
         AADD(aCab,{"F2_COND"    ,SF2->F2_COND   ,})
         AADD(aCab,{"F2_TIPODOC" ,SF2->F2_TIPODOC,})// Conforme falado com Marcelo Grabiel da Microsiga - 16/08/2004
         AADD(aCab,{"F2_VALMERC" ,SF2->F2_VALMERC,})
         AADD(aCab,{"F2_ESPECIE" ,SF2->F2_ESPECIE,})
         AADD(aCab,{"F2_DUPL"    ,SF2->F2_DUPL   ,}) 
         AADD(aCab,{"F2_EST"     ,SF2->F2_EST    ,}) 
         AADD(aCab,{"F2_HAWB"    ,SF2->F2_HAWB   ,})
         AADD(aCab,{"F2_TIPOCLI" ,SF2->F2_TIPOCLI,})
         
         nRecno:=SF2->(RECNO())
         MSExecAuto({|x,y,z| MATA466N(x,y,z)},aCab,aItens,5)
         SF2->(DBGOTO(nRecno))
         IF lMSErroAuto           
            MostraErro()
            EXIT
         ENDIF
         DINCPIncProc()
      ELSE
         SF2->(RecLock("SF2",.F.,.T.))
         SF2->(DBDELETE())
         SF2->(MsUnlock())
      ENDIF 
      SF2->(DbSkip())

   ENDDO

   IF !lMSErroAuto
      DINCPIncProc(STR0157) //"Estornando Nota Fiscal"

      SWD->(DBSETORDER(1))
      SWD->(DBSEEK(xFilial("SWD")+SW6->W6_HAWB))
      DO WHILE SWD->(!EOF())              .AND.;
               SWD->WD_FILIAL==xFilial("SWD").AND.;
               SWD->WD_HAWB  == SW6->W6_HAWB

         DINCPIncProc()

         IF ASCAN(aNotasDel,SWD->WD_NF_COMP+SWD->WD_SE_NFC+SWD->WD_FORN+SWD->WD_LOJA) = 0
            SWD->(DBSKIP())
            LOOP
         ENDIF

         SWD->(RecLock("SWD",.F.))
         SWD->WD_NF_COMP:=""
         SWD->WD_SE_NFC :=""
         SWD->WD_DT_NFC :=AVCTOD("")
         SWD->WD_VL_NFC :=0
         SWD->(MsUnlock())
         SWD->(DBSKIP())

      ENDDO


   ENDIF
   
   SWN->(DBSETORDER(3))
   IF SWN->(DBSEEK(xFilial("SWN")+SW6->W6_HAWB+"N")) .AND. !lMSErroAuto
      DO WHILE SWN->(!EOF())                   .AND.;
               SWN->WN_FILIAL == xFilial("SWN").AND.;
               SWN->WN_HAWB   == SW6->W6_HAWB  .AND.;
               SWN->WN_TIPO_NF== "N"
         DINCPIncProc()
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

   SW6->(MsUnlock())

End Transaction

SWN->(DBSETORDER(1))
SWW->(DBSETORDER(1))

DINCPIncProc()

IF lMSErroAuto
   RETURN .F.
ENDIF

RETURN .T.

*---------------------------------------*
STATIC Function DITrans(nVal,nDec)
*---------------------------------------*
Return ROUND(nVal,nDecPais)

*--------------------------------------------*
Function DINCPTabDes(aDespesa)
*--------------------------------------------*
LOCAL nPos

nPos:= ASCAN(aDespesa,{|Desp|Desp[01]==SWD->WD_DESPESA .AND.;
                             Desp[07]==SWD->WD_DOCTO   .AND.;
                             Desp[09]==SWD->WD_FORN    .AND.;
                             Desp[10]==SWD->WD_LOJA    .AND.;
                             IF(SWD->(FieldPos("WD_SE_DOC"))>0, Desp[11]==SWD->WD_SE_DOC,.T.) })

nTaxa:=BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI)
IF(nTaxa=0,nTaxa:=1,)

IF nPos = 0
   AADD(aDespesa,{SWD->WD_DESPESA,;//1
                  EVAL(bWD_Valor),;//2
                    Work4->WKFLAG,;//3
                   SWD->(RECNO()),;//4
                 Work4->(RECNO()),;//5
            EVAL(bWD_Valor)/nTaxa,;//6
                  SWD->WD_DOCTO  ,;//7
                  SWD->WD_DES_ADI,;//8
                  SWD->WD_FORN   ,;//9
                  SWD->WD_LOJA   ,;//10
                  SWD->WD_SE_DOC ,;//11
                  SWD->WD_TES    })//12
ELSE 
   aDespesa[nPos,2]+=EVAL(bWD_Valor)
   aDespesa[nPos,6]+=EVAL(bWD_Valor) / nTaxa
ENDIF

RETURN .T.

*---------------------------------*
Function DINCPValid(cQual)
*---------------------------------*
IF !lGeraNF
   Return .T.
ENDIF

DO CASE
   CASE cQual = "NFE"

        If Empty(cNumNFE)
           Help("",1,"AVG0000809")
//         MSGINFO(0252),0022) //"Numero da N.F. nao informado"###"Atenção"
           Return .F.
        Endif

   CASE cQual = "SERIE"
        SD2->(DBSETORDER(3))
        If SD2->(DbSeek(xFilial("SD2")+cNumNFE+cSerieNFE+Work1->WKFORN+Work1->WKLOJA))
           Help("",1,"AVG0000810")
//         MSGINFO((0254),0022) //"Numero da N.F. e da Serie ja cadastrados no sistema."###"Atenção"
           Return .F.
        Endif

   CASE cQual = "DATA"

        If Empty(dDtNFE)
           Help("",1,"AVG0000811")
//         MsgInfo(0257,0022) //"Data da N.F. não Preenchida"###"Atenção"
           Return .F.
        Endif
EndCase

Return .T.

*------------------------------------*
Function DINCPPesquisa()
*------------------------------------*
LOCAL nOpca  :=0, oDlgPeq
LOCAL nRecno :=Work1->(RECNO())
LOCAL nOrder :=Work1->(INDEXORD())
LOCAL cForn  :=Work1->WKFORN
LOCAL cCFO   :=Work1->WK_CFO
LOCAL cOpera :=Work1->WK_OPERACA
LOCAL cTec   :=Work1->WKTEC
LOCAL cNcm   :=Work1->WKEX_NCM
LOCAL cNbm   :=Work1->WKEX_NBM
LOCAL cItem  :=Work1->WKCOD_I
LOCAL cChave :=cCFO+cOpera+cTec+cNcm+cNbm+cItem
LOCAL nCo1   :=04
LOCAL nCo2   :=40
LOCAL nLin   :=05

DEFINE MSDIALOG oDlgPeq TITLE STR0258 From 0,0 To 17,35 OF oMainWnd //"Pesquisa Chave"

nLin+=12
@nLin,nCo1 SAY STR0084  SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cForn  SIZE 50,8 PIXEL F3 "SA2"

nLin+=12
@nLin,nCo1 SAY STR0039  SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cCFO   SIZE 50,8 PIXEL

nLin+=12
@nLin,nCo1 SAY "Operacao" SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cOpera SIZE 50,8 PIXEL F3 "SWZ"

nLin+=12
@nLin,nCo1 SAY "TEC"    SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cTec   SIZE 52,8 PIXEL F3 "SYD"  PICTURE "@R 9999.99.99"

nLin+=12
@nLin,nCo1 SAY "EX-NCM" SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cNcm   SIZE 50,8 PIXEL F3 "WD2"

nLin+=12
@nLin,nCo1 SAY "EX-NBM" SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cNbm   SIZE 50,8 PIXEL F3 "WD3"

nLin+=12
@nLin,nCo1 SAY "Cod. Item" SIZE 25,8 PIXEL
@nLin,nCo2 MSGET cItem  SIZE 50,8 PIXEL F3 "SB1"

@ 10,100 BUTTON STR0111 SIZE 30,11 ACTION (nOpca:=1,oDlgPeq:End()) OF oDlgPeq PIXEL //"&OK"
@ 30,100 BUTTON STR0103 SIZE 30,11 ACTION (nOpca:=0,oDlgPeq:End()) OF oDlgPeq PIXEL //"&Sair"

ACTIVATE MSDIALOG oDlgPeq CENTERED

If nOpcA = 0
   RETURN .F.
Endif
cChave:=cForn+cCFO+cOpera+cTec+"  "+cNcm+cNbm+cItem
Work1->(DBSETORDER(5))
Work1->(DBSEEK(RTRIM(cChave),.T.))
IF Work1->(EOF())
   Work1->(DBGOTO(nRecno))
ENDIF
Work1->(DBSETORDER(nOrder))
RETURN .T.

*-----------------------------------------------------------------------------------------------------------------------------------*
STATIC FUNCTION E_RESET_AREA()
*-----------------------------------------------------------------------------------------------------------------------------------*
DBSELECTAREA("SW6")

SW6->(MSUnlock())
IF SELECT("Work1") # 0
   Work1->(E_EraseArq(Work1File,Work1FileA,Work1FileB))
   //MFR OSSME-1974 26/12/2018
   FErase(Work1FileC+TeOrdBagExt())
   FErase(Work1FileD+TeOrdBagExt())
ENDIF
IF SELECT("Work2") # 0
   Work2->(E_EraseArq(Work2File))
ENDIF
IF(SELECT("Work4")   #0,Work4->(E_EraseArq(Work4File)),)
IF(SELECT("Work3")   #0,Work3->(E_EraseArq(Work3File,Work3FileA)),)
IF(SELECT("WorkTES") #0,WorkTES->(E_EraseArq(cFile)),)
//MFR OSSME-1974 26/12/2018
FErase(Work1FileD+TeOrdBagExt())
FErase(Work1FileE+TeOrdBagExt())
FErase(Work1FileF+TeOrdBagExt())

SetKey(VK_F4,bSetKey)

DBSELECTAREA("SW6")
RETURN .T.

*-----------------------------------------------*
STATIC Function ICGeraDespesas()
*-----------------------------------------------*
Local J, N
ProcRegua(LEN(aRecWork1))
aCampos:={}
AADD(aCampos,"WKCOD_I"   );AADD(aCampos,"WKTEC"    );AADD(aCampos,"WKEX_NCM" )
AADD(aCampos,"WKEX_NBM"  );AADD(aCampos,"WKDESCR"  );AADD(aCampos,"WKFORN"   )
AADD(aCampos,"WKUNI"     );AADD(aCampos,"WKSI_NUM" );AADD(aCampos,"WKPESOL"  )
AADD(aCampos,"WKPO_NUM"  );AADD(aCampos,"WKPO_SIGA");AADD(aCampos,"WKLOJA"   )
AADD(aCampos,"WKRECNO"   );AADD(aCampos,"WK_CC"    );AADD(aCampos,"WK_CFO"   )
AADD(aCampos,"WK_NFE"    );AADD(aCampos,"WK_SE_NFE");AADD(aCampos,"WK_DT_NFE")
AADD(aCampos,"WK_OPERACA");AADD(aCampos,"WKPOSICAO");AADD(aCampos,"WKQTDE")
AADD(aCampos,"WKPGI_NUM" );AADD(aCampos,"WK_REG"   );AADD(aCampos,"WKINVOICE")
AADD(aCampos,"WKRATEIO"  )

aDados:=ARRAY(LEN(aCampos))
SWD->(DBSETORDER(1))

FOR N := 1 TO LEN(aRecWork1)

    Work1->(dbGoTo(aRecWork1[N]))
    IncProc()
    IF Work3->(DBSEEK(STRZERO(aRecWork1[N],nTamRec)))

       Work1->WKVALMERC :=Work3->WKVALOR//Preco Total
       Work1->WKPRUNI   :=Work1->WKVALMERC / Work1->WKQTDE//Preco Unitario
       Work1->WK_DT_NFE :=Work3->WK_DT_NFC
       Work1->WKDESPESA :=Work3->WKDESPESA+' - '+Work3->WKDESCR
       Work1->WKOUT_DESP:=Work3->WKVALOR//Preco Total
       Work1->WKOUT_D_US:=Work3->WKVALOR_US//Preco Total em Dolar
       Work1->WKFORN    :=Work3->WKFORN
       Work1->WKLOJA    :=Work3->WKLOJA
       Work1->WKVALMERUS:=Work1->WKVALMERC / SW6->W6_TX_US_D
       Work1->WKRECNOWK3:=Work3->(RECNO())
       Work1->WKRECNOWK4:=Work3->WKRECNOWK4//Recno do work4
       IF SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB+LEFT(Work3->WKDESPESA,3))) .AND. !EMPTY(SWD->WD_TES)
          Work1->WK_TES := SWD->WD_TES
       ELSEIF SYB->(DbSeek(xFilial("SYB")+LEFT(Work3->WKDESPESA,3))) .AND. !EMPTY(SYB->YB_TES)
          Work1->WK_TES := SYB->YB_TES
       ENDIF
       IF !lNFAutomatica
          Work1->WK_NFE    :=Work3->WK_NF_COMP
          Work1->WK_SE_NFE :=Work3->WK_SE_NFC
          Work1->WK_NFE_AUX:=Work3->WK_NF_COMP
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
          Work1->WKDESPESA :=Work3->WKDESPESA+' - '+Work3->WKDESCR
          Work1->WKOUT_DESP:=Work3->WKVALOR//Preco Total
          Work1->WKOUT_D_US:=Work3->WKVALOR_US//Preco Total em Dolar
          Work1->WKFORN    :=Work3->WKFORN
          Work1->WKLOJA    :=Work3->WKLOJA
          Work1->WKVALMERUS:=Work1->WKVALMERC / SW6->W6_TX_US_D
          Work1->WKRECNOWK3:=Work3->(RECNO())                  
          Work1->WKRECNOWK4:=Work3->WKRECNOWK4//Recno do work4
          IF SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB+LEFT(Work3->WKDESPESA,3))) .AND. !EMPTY(SWD->WD_TES)
             Work1->WK_TES := SWD->WD_TES
          ELSEIF SYB->(DbSeek(xFilial("SYB")+LEFT(Work3->WKDESPESA,3))) .AND. !EMPTY(SYB->YB_TES)
             Work1->WK_TES := SYB->YB_TES
          ENDIF
          IF !lNFAutomatica
             Work1->WK_NFE    := Work3->WK_NF_COMP
             Work1->WK_SE_NFE := Work3->WK_SE_NFC
             Work1->WK_NFE_AUX:= Work3->WK_NF_COMP
          ENDIF
          IF EMPTY(Work1->WK_NFE)
             Work1->WKFLAG :=cMarca
          ELSE
             Work1->WKFLAG :=''
          ENDIF

          Work3->(DBSKIP())
   
       EndDo
   
    Endif

NEXT

RETURN .T.

/*-----------------------------------------------*
STATIC Function ICGeraImpostos()
*-----------------------------------------------*
Local lEof	:=	.F.
aTotais:={};nTotImpostos:=0
ProcRegua(Work1->(LastRec()))
WorkTES->(__DBZAP())
Work1->(DBGOTOP())
DO WHILE Work1->(!EOF())
   IncProc()
   lGera:=.F.
   cCodTES := ""
   IF SWD->(dbSeek(xFilial("SWD")+SW6->W6_HAWB+LEFT(Work1->WKDESPESA,3))) .AND.;
      SWD->(FieldPos("WD_TES")) > 0 .AND. !EMPTY(SWD->WD_TES)
      lGera   := .T.
      cCodTES := SWD->WD_TES
   ELSEIF SYB->(DbSeek(xFilial("SYB")+LEFT(Work1->WKDESPESA,3))) .AND. !EMPTY(SYB->YB_TES)
      lGera := .T.
      cCodTES := SYB->YB_TES
   ENDIF

   IF lGera
      Work1->(DbSkip())
      lEof :=Work1->(EOF())
      Work1->(DbSkip(-1))
      aTab:=CalcTesGer(cCodTES,,,Work1->WKVALMERC,,,,{},,MDI_OUTR,lEof)
      IF !EMPTY(aTab)
         Work1->WKIMPOSTOS:=0//Eh preciso Zerar por causa da alteracao do peso
         SFB->(DBSETORDER(1))
         FOR I := 1 TO LEN(aTab[6])
            WorkTES->(DBAPPEND())
            WorkTES->WKRECNO   :=STRZERO(Work1->(RECNO()),6)
            WorkTES->WKITEM    :=Work1->WKCOD_I
            WorkTES->WK_IMP    :=aTab[6,I,1]
            WorkTES->WK_NCM    :=Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM
            SFB->(DBSEEK(xFilial("SFB")+WorkTES->WK_IMP))
            WorkTES->WK_IMPDESC:=LEFT(SFB->FB_DESCR,20)
            WorkTES->WKPERC    :=aTab[6,I,2]
            WorkTES->WKBASE    :=aTab[6,I,3]
            WorkTES->WKVALOR   :=aTab[6,I,4]
            WorkTES->WKVLR_CPO :=SUBSTR(aTab[6,I,6],3)
            WorkTES->WKBAS_CPO :=SUBSTR(aTab[6,I,7],3)
            WorkTES->WKALI_CPO :="_ALQIMP"+RIGHT(ALLTRIM(aTab[6,I,7]),1)
            IF (nPos:=ASCAN(aTotais,{|aDesp|aDesp[1]==WorkTES->WK_IMP.AND.aDesp[4]==WorkTES->WK_NCM} )) == 0
               AADD(aTotais,{WorkTES->WK_IMP,DITRANS(WorkTES->WKVALOR,2),DITRANS(WorkTES->WKBASE,2),WorkTES->WK_NCM} )
            ELSE
               aTotais[nPos,2]+=DITRANS(WorkTES->WKVALOR,2)//Valor
               aTotais[nPos,3]+=DITRANS(WorkTES->WKBASE ,2)//Base
            ENDIF
            Work1->WKIMPOSTOS +=DITRANS(WorkTES->WKVALOR,2)
         NEXT
         nTotImpostos+=Work1->WKIMPOSTOS
      ENDIF
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
   //TOTAL POR NCM
   WorkTES->(DBAPPEND())
   WorkTES->WKRECNO   :="TOTAIS"
   WorkTES->WK_IMP    :=aTotais[I,1]
   WorkTES->WK_NCM    :=aTotais[I,4]
   WorkTES->WK_IMPDESC:=LEFT(SFB->FB_DESCR,20)
   WorkTES->WKVALOR   :=aTotais[I,2]
   WorkTES->WKBASE    :=aTotais[I,3]
   WorkTES->WKVALORUS +=aTotais[I,2] / SW6->W6_TX_US_D
NEXT

Work1->(DBGOTOP())

// EOS - AWR *************************
//IF lGrvDespSD1
   Work4->(dbGoTop())
   DO WHILE !Work4->(eof())
      IF EMPTY(Work4->WKFLAG)
         Work4->(dbSkip())
         LOOP
      ENDIF
      aTab1:=CalcImpGer(Work4->WKTES,,,Work4->WKVALOR,,,,{},,MDI_OUTR,.F.)      
      IF (nPos := ASCAN(aDespesa, {|A| A[1] == LEFT(Work4->WKDESPESA,3)} ) ) > 0
         AADD( aDespesa[nPos], aTab1[6] )
      ENDIF
      Work4->(dbSkip())
   ENDDO
//ENDIF
// EOS - AWR *************************

Return .T.            
  
*--------------------------------------------------------------*
Static Function DINCPLerGrvImpostos(cExecute,aGrvImpSD)
*--------------------------------------------------------------*
LOCAL lGera:=.F.,lGeraDesp:=.F.,aDespTES:={},aTab:={},aTab1:={}
LOCAL cFil:=xFilial("SWW"),aImpGer:={}
DO CASE

   CASE cExecute == 'LER_SWN'

         IF !EMPTY(Work1->WK_TES)
            aTab:=DINCPDFB(Work1->WK_TES)
            FOR E := 1 TO LEN(aDespTES)
               IF SYD->YD_TES # aDespTES[E]
                  aTab1:=DINCPDFB(aDespTES[E])
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
                   nCpoALI:=SWN->( FIELDPOS("WN"+aTab[I,2]) )
                   nCpoVLR:=SWN->( FIELDPOS("WN"+aTab[I,3]) )
                   nCpoBAS:=SWN->( FIELDPOS("WN"+aTab[I,4]) )
                   IF nCpoVLR # 0 .AND. nCpoBAS # 0
                      WorkTES->(DBAPPEND())
                      WorkTES->WKRECNO   :=STRZERO(Work1->(RECNO()),6)
                      WorkTES->WKITEM    :=Work1->WKCOD_I
                      WorkTES->WK_IMP    :=aTab[I,1]
                      SFB->(DBSEEK(xFilial("SFB")+WorkTES->WK_IMP))
                      WorkTES->WK_IMPDESC:=LEFT(SFB->FB_DESCR,20)
                      WorkTES->WKVALOR  :=SWN->( FIELDGET(nCpoVLR) )
                      WorkTES->WKVALORUS:=WorkTES->WKVALOR / SW6->W6_TX_US_D
                      WorkTES->WKBASE   :=SWN->( FIELDGET(nCpoBAS) )
                      IF(nCpoALI#0,WorkTES->WKPERC:=SWN->(FIELDGET(nCpoALI)),)
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
            NEXT
            nTotImpostos+=Work1->WKIMPOSTOS

         ENDIF
    

   CASE (cExecute == "GRAVA_SWN"   .OR.;
         cExecute == "GRAVA_SD")
         
         cAlias:="SWN"
         cAlias:=IF(cExecute = "GRAVA_SD","SD2",cAlias)

         IF WorkTES->(DBSEEK( STRZERO(Work1->(RECNO()),6) ))
            DO WHILE !WorkTES->(EOF()) .AND. STRZERO(Work1->(RECNO()),6) == WorkTES->WKRECNO
               IF (nPos:=ASCAN(aValores, {|aImp|aImp[1]==WorkTES->WK_IMP} )) == 0
                  AADD(aValores,{WorkTES->WK_IMP,WorkTES->WKVALOR,WorkTES->WKBASE,WorkTES->WKVLR_CPO,WorkTES->WKBAS_CPO,WorkTES->WKALI_CPO} )
               ELSE
                  aValores[nPos,2]+=DITRANS(WorkTES->WKVALOR,2)//Valor
                  aValores[nPos,3]+=DITRANS(WorkTES->WKBASE ,2)//Base
               ENDIF
               IF cExecute == "GRAVA_SWN" .OR.;
                  cExecute == "GRAVA_SD"
                  DINCPGrvImpostos(cAlias,aGrvImpSD)
               ENDIF
               WorkTES->(DBSKIP())
            ENDDO
         ENDIF

ENDCASE

RETURN .T.

*---------------------------------------------------*
Static Function DINCPGrvImpostos(cAlias,aGrvImpSD)
*---------------------------------------------------*
IF cAlias = "SD2"

   nCpoVLR:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKVLR_CPO) )
   nCpoBAS:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKBAS_CPO) )
   nCpoALI:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKALI_CPO) )
   
   IF nCpoVLR # 0 .AND. nCpoBAS # 0
      AADD(aGrvImpSD,{ (cAlias)->(FIELD(nCpoVLR)),WorkTES->WKVALOR,".T."} )
      AADD(aGrvImpSD,{ (cAlias)->(FIELD(nCpoBAS)),WorkTES->WKBASE ,".T."} )
   ENDIF
   IF nCpoALI # 0
      AADD(aGrvImpSD,{ (cAlias)->(FIELD(nCpoALI)),WorkTES->WKPERC ,".T."})
   ENDIF

ELSEIF cAlias = "SWN"
   nCpoVLR:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKVLR_CPO) )
   nCpoBAS:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKBAS_CPO) )
   nCpoALI:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+WorkTES->WKALI_CPO) )
   DINCPPut(cAlias,WorkTES->WKVALOR,WorkTES->WKBASE,WorkTES->WKPERC)
ELSE
   FOR I := 1 TO LEN(aValores)
      nCpoVLR:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+aValores[I,4]) )
      nCpoBAS:=(cAlias)->( FIELDPOS(RIGHT(cAlias,2)+aValores[I,5]) )
      nCpoALI:=0
      DINCPPut(cAlias,aValores[I,2],aValores[I,3],0)
   NEXT
   aValores:={}
ENDIF

RETURN .T.                       

*----------------------------------------------------*
Static Function DINCPPut(cAlias,nValor,nBase,nAliq)
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
Static Function DINCPDFB(cTes)
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
*/
*-----------------------------------------*
Function DINCPTelaImpostos(lNCM)
*-----------------------------------------*
LOCAL TB_Campos:={},oMark,nLin:=05
PRIVATE cFiltro:=STRZERO(Work1->(RECNO()),6)
IF lNCM
   cFiltro:="TOTAIS"+Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM
ENDIF
aAdd(TB_Campos,{"WK_IMP" ,,"Impuesto"})
aAdd(TB_Campos,{"WK_IMPDESC",,"Descripcion"})
IF !lNCM
   aAdd(TB_Campos,{"WKPERC",,"% Alicuota","@E 999.99"})
ENDIF
aAdd(TB_Campos,{"WKBASE"   ,,"Base $",PICT15_2})
aAdd(TB_Campos,{{|| WorkTES->WKBASE/SW6->W6_TX_US_D } ,,"Base "+cMoeDolar,PICT15_2})
aAdd(TB_Campos,{"WKVALOR"  ,,"Valor $",PICT15_2})
aAdd(TB_Campos,{"WKVALORUS",,"Valor "+cMoeDolar,PICT15_2})

oMainWnd:ReadClientCoords()
DEFINE MSDIALOG oDlgImp TITLE "Impuestos - "+IF(lNCM,"Arancel: "+ALLTRIM(Work2->WK_CFO+Work2->WK_OPERACA+Work2->WKTEC+Work2->WKEX_NCM+Work2->WKEX_NBM),; 
  "Item: "+Work1->WKCOD_I); 
  FROM 000,oMainWnd:nLeft TO 250,oMainWnd:nRight-100 OF oMainWnd PIXEL

  DBSELECTAREA("WorkTES")
  oMark:=MsSelect():New("WorkTES",,,TB_Campos,.F.,cMarca,{nLin,005,nLin+100,(oDlgImp:nClientWidth-4)/2},"DINCPFiltra(cFiltro)","DINCPFiltra(cFiltro)")
  oMark:oBrowse:bWhen:={|| DBSELECTAREA("WorkTES"),.T. }
  oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT

ACTIVATE DIALOG oDlgImp ON INIT EnchoiceBar(oDlgImp, { || oDlgImp:End() }, { || oDlgImp:End() },,,,,,,.F.) CENTERED

RETURN .T.

*-----------------------------------------*
Function DINCPFiltra(cFiltro)
*-----------------------------------------*                                             
RETURN cFiltro

*------------------------------------------------*
Function DIHelpSWD()
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
DEFINE MSDIALOG oDlg TITLE "Consulta N.C.P." FROM 0,3 TO 15,27 OF oMainWnd

   DBSELECTAREA("Work4")
   oMark:=MsSelect():New("Work4",,,{{"WKDOC",,STR0038}},.F.,cMarca,{2,2,(oDlg:nClientHeight-5)/2,53},"DI156Filtra(cFiltro)","DI156Filtra(cFiltro)") //"Factura"
   oMark:oBrowse:bWhen:={|| DBSELECTAREA("Work4"),.T. }
   oMark:baval:=bAction
   oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg, bAction, { || oDlg:End() },,,,,,,.F.) CENTERED   

IF lOK
   cNumNFE:=Work4->WKDOC
ENDIF
Work4->(DBSETORDER(2))
DBSELECTAREA("Work1")

RETURN lOK
*---------------------------------------------------*
FUNCTION DINCPGrvW3W4(cNumero,cSerie,dDtNFE)
*---------------------------------------------------*
      
IF !EMPTY(Work1->WKRECNOWK4)
   Work4->(DBGOTO(Work1->WKRECNOWK4))
   Work4->WKNOTANEW:=cNumero
   Work4->WKSERINEW:=cSerie
   Work4->WKDATA   :=dDtNFE
ENDIF

IF !EMPTY(Work1->WKRECNOWK3)
   Work3->(DBGOTO(Work1->WKRECNOWK3))
   Work3->WK_NF_COMP:=cNumero
   Work3->WK_SE_NFC :=cSerie
   Work3->WK_DT_NFC :=dDtNFE
ENDIF

RETURN .T.
*===================================*
Function DINCPNFE()
*===================================*
PRIVATE cTitulo:="Solicitud de NCP"

#INCLUDE "FONT.CH"
#INCLUDE "AVPRINT.CH"
#INCLUDE "PRINT.CH"
#DEFINE COURIER_07  oFont1
#DEFINE COURIER_07N oFont2
#DEFINE COURIER_08  oFont3
#DEFINE COURIER_10  oFont4
#DEFINE COURIER_12  oFont5  


PRINT oPrn NAME ''
      oPrn:SetLandsCape()
ENDPRINT

AVPRINT oPrn NAME cTitulo

   DEFINE FONT oFont1  NAME 'Courier New' SIZE 0,07 OF  oPrn
   DEFINE FONT oFont2  NAME 'Courier New' SIZE 0,07 OF  oPrn BOLD
   DEFINE FONT oFont3  NAME 'Courier New' SIZE 0,08 OF  oPrn
   DEFINE FONT oFont4  NAME 'Courier New' SIZE 0,10 OF  oPrn
   DEFINE FONT oFont5  NAME 'Courier New' SIZE 0,12 OF  oPrn

   AVPAGE

      oPrn:oFont:=COURIER_07
      lAbortPrint:=.F.
      Processa({|| DINCPRelNFE()} ,"Impressao da Nota Fiscal...",,.T.)

   AVENDPAGE

AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()
oFont5:End()
Work1->(DBSETORDER(1))
Work1->(DBGOTOP())

RETURN .T.
*----------------------------------------------------------------------------------*
Function DINCPRelNFE()
*----------------------------------------------------------------------------------*
PRIVATE lAbortPrint:=.F.
PRIVATE nItem:= nValImp  := nValMerc:= 0
PRIVATE cPictNotaF:=IF(!EMPTY(AVSX3("WN_DOC",6)),AVSX3("WN_DOC",6),"@!")
PRIVATE cPictItem:= AVSX3('B1_COD',6)
PRIVATE cPictTec := AVSX3('B1_POSIPI',6)
PRIVATE cPICT15_2:= '@E 9,999,999,999.99'
PRIVATE cPictPeso:= AVSX3('B1_PESO',6)

ProcRegua( Work1->(LASTREC()) + 3 )

IncProc()
lPrimPag:= .T.
nLimPage:= 2200
nColFim := 3090
nLin    := 99999 
nPag    := 0 
cChave  := ''
cNFChave:= ''

IncProc()
nCol01 := 0
nCol03 := nCol01
nCol05 := nCol03+500
//nCol06 := nCol05+020
nCol07 := nCol05+300
nCol08 := nCol07+260
nCol09 := nCol08+260
//nCol10 := nCol09+260 
//nCol11 := nCol10+260 
//nCol12 := nCol11+260 
nCol13 := nCol09//+260 
//nCol14 := nCol13+260//040
nCol15 := nCol09+040//250 
nCol16 := nCol15+250 
nCol06 := nCol16+110
//nCol17 := nCol16+120 
//nCol18 := nColFim

IncProc()
SWN->(DBSETORDER(2))
SW7->(DBSETORDER(1))
SW2->(DBSETORDER(1))

SW7->(DbSeek(xFILIAL('SW7')+SW6->W6_HAWB))
SW2->(DbSeek(xFilial("SW2")+SW7->W7_PO_NUM))

Work1->(DBSETORDER(6))
Work1->(DBGOTOP())
Work1->(DBEVAL( {|| DINCPDetRel(.T.) },, {|| !lAbortPrint } ))
Work1->(DBGOTOP())

DINCPTotais()

SWN->(DBSETORDER(1))
SWZ->(DBSETORDER(1))
RETURN .T.
*----------------------------------*
FUNCTION DINCPCabRel(lWork)
*----------------------------------*
IF lPrimPag
   lPrimPag:=.F.
   cNFChave:=TRANS(cNotaF,cPictNotaF)+" "+cSerie
ELSE
   AVNEWPAGE
ENDIF

nLin:= 100
nPag++

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin+=25

oPrn:Say(nLin,01,SM0->M0_NOME,COURIER_12)
oPrn:Say(nLin,nColFim/2,cTitulo,COURIER_12,,,,2)
oPrn:Say(nLin,nColFim,"Hoja....: "+STR(nPag,8),COURIER_12,,,,1) //
nLin+=50

oPrn:Say(nLin,01,"SIGAEIC",COURIER_12) //
oPrn:Say(nLin,nColFim/2,"Detallado",COURIER_12,,,,2) //"Analítico"
oPrn:Say(nLin,nColFim,"Emisao.: "+DTOC(dDataBase),COURIER_12,,,,1)
nLin+=50

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin +=25

SYT->(DBSEEK(XFILIAL('SYT')+SW2->W2_IMPORT))

oPrn:Say(nLin,0001,AVSX3('W2_IMPORT',5) +"..: "+SW2->W2_IMPORT+" - "+ALLTRIM(SYT->YT_NOME)+" - "+ALLTRIM(SYT->YT_ENDE),COURIER_08) //"Empresa ..........: "
nLin+=45
oPrn:Say(nLin,0001,AVSX3('W6_HAWB',5)   +".....: "+SW6->W6_HAWB,COURIER_08) //"Processo..........: "
oPrn:Say(nLin,0800,"Proveedor..: "      +SA2->A2_COD+" - "+ALLTRIM(SA2->A2_NREDUZ),COURIER_08)
oPrn:Say(nLin,2400,AVSX3('W6_HOUSE',5)  +": "+SW6->W6_HOUSE,COURIER_08) //"Conhecimento.........: "
nLin+=45
oPrn:Say(nLin,0001,AVSX3('W6_DT_HAWB',5)+".: "+DTOC(SW6->W6_DT_HAWB),COURIER_08) //"Dt. Processo......: "
oPrn:Say(nLin,0800,AVSX3('W6_DI_NUM',5) +".: "+TRANS(SW6->W6_DI_NUM,'@R 99/9999999-9'),COURIER_08) //"D.I....................: "
oPrn:Say(nLin,1600,AVSX3('W6_DT',5)     +": "+DTOC(SW6->W6_DT),COURIER_08) //"Dt. D.I.............: "
oPrn:Say(nLin,2400,AVSX3('W6_DT_ENTR',5)+".: "+DTOC(SW6->W6_DT_ENTR),COURIER_08) //"Dt. Entrega..........: "
nLin+=45
//oPrn:Say(nLin,0001,STR0144+TRANS(SW6->W6_TX_FOB ,AVSX3('W6_TX_FOB',6)),COURIER_08) //"Tx. Conversao FOB.: "
oPrn:Say(nLin,0800,AVSX3('W6_TX_US_D',5)+": "+TRANS(SW6->W6_TX_US_D,AVSX3('W6_TX_US_D',6)),COURIER_08) //"Tx. Conversao US$ D.I..: "
nLin+=50

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin +=25          
oPrn:Say( nLin,nCol03,"Cod. Item"     ,COURIER_07)  
oPrn:Say( nLin,nCol05,"Peso"          ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol07,"Cantidad"      ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol08,"Precio"        ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol09,"Precio Totale" ,COURIER_07,,,,1)
//oPrn:Say( nLin,nCol13,"Vlr Impuestos" ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol15,"Nro.P.O."      ,COURIER_07)     
oPrn:Say( nLin,nCol16,"TES"           ,COURIER_07)
oPrn:Say( nLin,nCol06,"Gastos"        ,COURIER_07)
nLin +=40     
oPrn:Say( nLin,nCol03,REPL('=',20           ),COURIER_07)
oPrn:Say( nLin,nCol05,REPL('=',LEN(cPeso   )),COURIER_07,,,,1)
oPrn:Say( nLin,nCol07,REPL('=',LEN(cUni+cQtde)),COURIER_07,,,,1)
oPrn:Say( nLin,nCol08,REPL('=',LEN(cPreco  )),COURIER_07,,,,1)
oPrn:Say( nLin,nCol09,REPL('=',LEN(cValMerc)),COURIER_07,,,,1)
//oPrn:Say( nLin,nCol13,REPL('=',LEN(cValImp)) ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol15,REPL('=',LEN(cPedido)) ,COURIER_07)
oPrn:Say( nLin,nCol16,REPL('=',LEN(cTES    )),COURIER_07)
oPrn:Say( nLin,nCol06,REPL('=',LEN(cGastos )),COURIER_07)

nLin +=35

RETURN .T.
*----------------------------------------------------------------------------------*
Function DINCPDetRel()
*----------------------------------------------------------------------------------*
LOCAL lPassou:=.F.
Private lWork:=.T.

cNotaF  := Work1->WK_NFE
cSerie  := Work1->WK_SE_NFE
cCFO    := Work1->WK_CFO
cOperac := Work1->WK_OPERACA
cForn   := Work1->WKFORN    
cPedido := Work1->WKPO_NUM  
cCod_I  := TRAN(Work1->WKCOD_I,cPictItem)
cDescr  := LEFT(Work1->WKDESCR,25)       
cUni    := Work1->WKUNI
cPeso   := TRAN(DINCPValor(0), cPictPeso)
cGastos := Work1->WKDESPESA
cTES    := Work1->WK_TES
cQtde   := TRAN(DINCPValor(1),'@E 999,999,999.999' )
cPreco  := TRAN(DINCPValor(2),'@E 999,999,999.9999')
cValMerc:= TRAN(Work1->WKVALMERC ,cPICT15_2)
cValImp := TRAN(Work1->WKIMPOSTOS,cPICT15_2)
cTec    := TRAN(Work1->WKTEC     ,cPictTec)
cEx_Ncm := " "+Work1->WKEX_NCM
cEx_Nbm := " "+Work1->WKEX_NBM

IncProc("Imprimindo Item: "+Work1->WKCOD_I) //

IF nLin > nLimPage
   DINCPCabRel(lWork)
   lPassou:=.T.
ENDIF                            

IF cChave # cForn+cNotaF+cSerie+cOperac+cTec+cEx_Ncm+cEx_Nbm+cPedido

   IF cNFChave # TRANS(cNotaF,cPictNotaF)+" "+cSerie
      IF(lPassou,nLin+=40,)
      DINCPTotais()
      cNFChave:= TRANS(cNotaF,cPictNotaF)+" "+cSerie
      lPassou := .F.
   ENDIF   

   IF nLin > nLimPage
      DINCPCabRel(lWork)
      lPassou:=.T.
   ENDIF                            

   IF !lPassou 
      oPrn:Box( nLin,01,nLin+1,nColFim)
      nLin +=15
   ENDIF   
   SA2->(dBSeek(xFilial('SA2')+cForn))
   oPrn:Say( nLin,nCol01,"N.C.P.: "+TRANS(cNotaF,cPictNotaF)+' '+cSerie+' '+;//
                         "Proveedor"+': '+cForn+"-"+LEFT(SA2->A2_NREDUZ,20)+;//
                         "      N.C.M.: "+cTec+cEx_Ncm+cEx_Nbm,COURIER_07N) //
   cChave  := cForn+cNotaF+cSerie+cOperac+cTec+cEx_Ncm+cEx_Nbm+cPedido
   nLin+=40

   IF nLin > nLimPage
      DINCPCabRel(lWork)
   ENDIF                               
ENDIF                       
SA2->(dBSeek(xFilial('SA2')+cForn))
nItem++

oPrn:Say( nLin,nCol03,cCod_I    ,COURIER_07)
oPrn:Say( nLin,nCol05,cPeso     ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol07,cUni+cQtde,COURIER_07,,,,1)
oPrn:Say( nLin,nCol08,cPreco    ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol09,cValMerc  ,COURIER_07,,,,1)
//oPrn:Say( nLin,nCol13,cValImp   ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol15,cPedido   ,COURIER_07)
oPrn:Say( nLin,nCol16,cTES      ,COURIER_07)
oPrn:Say( nLin,nCol06,cGastos   ,COURIER_07)

nLin+=40             
   
nValMerc+= VAL(STR( Work1->WKVALMERC ,15,2))
nValImp += VAL(STR( Work1->WKIMPOSTOS,15,2))

RETURN .T.
*----------------------------------------------------------------------------------*
Function DINCPValor(nTipo)
*----------------------------------------------------------------------------------*
LOCAL nValor:=0

IF nTipo==0
   nValor:=Work1->WKPESOL
ELSEIF nTipo==1
   nValor:=Work1->WKQTDE 
 ELSEIF nTipo==2
   nValor:=Work1->WKPRUNI
ENDIF

RETURN nValor

*---------------------------------------------------------------------------------*
FUNCTION DINCPTotais()
*---------------------------------------------------------------------------------*
IF nItem > 1
   oPrn:Say( nLin,nCol09,REPL('=',LEN(cPICT15_2)-3),COURIER_07,,,,1)
// oPrn:Say( nLin,nCol13,REPL('=',LEN(cPICT15_2)-3),COURIER_07,,,,1)
   nLin +=30
   oPrn:Say( nLin,nCol09,TRAN(nValMerc,cPICT15_2),COURIER_07,,,,1)
// oPrn:Say( nLin,nCol13,TRAN(nValImp ,cPICT15_2),COURIER_07,,,,1)
   nLin +=40
ENDIF
oPrn:Say( nLin,nCol13,"TOTAL N.F.E.: "+ALLTRIM(cNFChave)+".: "+TRAN(nValImp+nValMerc,cPICT15_2),COURIER_10,,,,1)//+" (Precio Total + Impuestos)
nLin+=45
nItem:= nValImp := nValMerc:= 0

RETURN .T.

*-------------------------------*
FUNCTION DIRefaz()       
*-------------------------------*
LOCAL aItem:={}, nAux := 1, ITE, GRV
aItens   := {} 
aValores := {}
SYB->(dbSetOrder(1))
SB1->(dbSetOrder(1))
FOR nAux := 1 TO LEN(aDespesa)
    IF !EMPTY(aDespesa[nAux,12])
       IF ALLTRIM(aDespesa[nAux,7]) == ALLTRIM(nNFE) .AND. nSerie == aDespesa[nAux,11] ;
                       .AND. cForn  == aDespesa[nAux,9]+aDespesa[nAux,10]
          SWD->(DBGOTO(aDespesa[nAux,4]))
          SYB->(DbSeek(xFilial("SYB")+aDespesa[nAux,1]))
          SB1->(DbSeek(xFilial("SB1")+SYB->YB_COD_I))
          cNatureza:=SWD->WD_NATUREZ
          aItem:={}
          AADD(aItem,{"D2_COD"         ,SB1->B1_COD      ,".T."}) // codigo do produto
          AADD(aItem,{"D2_QUANT"       ,1                ,".T."}) // quantidade do produto
          AADD(aItem,{"D2_PRUNIT"      ,aDespesa[nAux,2] ,".T."}) // valor unitario do item
          AADD(aItem,{"D2_PRCVEN"      ,aDespesa[nAux,2] ,".T."}) // valor unitario do item
          AADD(aItem,{"D2_TES"         ,aDespesa[nAux,12],".T."})
          AADD(aItem,{"D2_TOTAL"       ,aDespesa[nAux,2] ,".T."}) // valor total do item (quantidade * preco)
          AADD(aItem,{"D2_DESC"        ,0                ,".T."})
          AADD(aItem,{"D2_DESCON"      ,0                ,".T."})
          AADD(aItem,{"D2_CLIENTE"     ,aDespesa[nAux,9] ,".T."})
          AADD(aItem,{"D2_LOJA"        ,aDespesa[nAux,10],".T."})
          AADD(aItem,{"D2_LOCAL"       ,SB1->B1_LOCPAD   ,".T."})
          AADD(aItem,{"D2_DOC"         ,aDespesa[nAux,7] ,".T."})
          AADD(aItem,{"D2_SERIE"       ,aDespesa[nAux,11],".T."})
          AADD(aItem,{"D2_EMISSAO"     ,aDespesa[nAux,8] ,".T."})
          AADD(aItem,{"D2_TIPO"        ,"D"              ,".T."})
          AADD(aItem,{"D2_CONTA"       ,SB1->B1_CONTA    ,".T."})
          AADD(aItem,{"D2_CCUSTO"      ,SB1->B1_CC       ,".T."})
          AADD(aItem,{"D2_GRUPO"       ,SB1->B1_GRUPO    ,".T."})
          AADD(aItem,{"D2_TP"          ,SB1->B1_TIPO     ,".T."})
          AADD(aItem,{"D2_NUMSEQ"      ,ProxNum()        ,".T."})
//        AADD(aItem,{"D2_HAWB"        ,SW6->W6_HAWB     ,".T."})
          AADD(aItem,{"D2_ITEM"        ,STRZERO(nItem,2) ,".T."})
          AADD(aItem,{"D2_ESPECIE"     ,'NCP'            ,".T."})
          nDespesa+=aDespesa[nAux,2]
/*        FOR nAux2=1 TO LEN(aDespesa[nAux,13])  
              nCpoVLR:=SD2->( FIELDPOS("D2"+SUBSTR(aDespesa[nAux,13,nAux2,6],3)) )
              nCpoBAS:=SD2->( FIELDPOS("D2"+SUBSTR(aDespesa[nAux,13,nAux2,7],3)) )
              nCpoALI:=SD2->( FIELDPOS("D2_ALQIMP"+RIGHT(ALLTRIM(aDespesa[nAux,13,nAux2,7]),1)) ) 
        
              IF nCpoVLR # 0 
                 AADD(aItem,{ SD2->(FIELD(nCpoVLR)), aDespesa[nAux,13,nAux2,4],".T."} )
              ENDIF
              IF nCpoBAS # 0
                 AADD(aItem,{ SD2->(FIELD(nCpoBAS)), aDespesa[nAux,13,nAux2,3],".T."} )
              ENDIF
              IF nCpoALI # 0
                 AADD(aItem,{ SD2->(FIELD(nCpoALI)), aDespesa[nAux,13,nAux2,2],".T."})
              ENDIF    
           
              IF (nPos:=ASCAN(aValores, {|aImp|aImp[1]==aDespesa[nAux,13,nAux2,1]} )) == 0
                 AADD(aValores,{aDespesa[nAux,13,nAux2,1],;           // imposto
                                aDespesa[nAux,13,nAux2,4],;           // valor do imposto
                                aDespesa[nAux,13,nAux2,3],;           // base do imposto
                                SUBSTR(aDespesa[nAux,13,nAux2,6],3),; // campo p/ grv vlr
                                SUBSTR(aDespesa[nAux,13,nAux2,7],3),; // campo p/ grv base
                                "_ALQIMP"+RIGHT(ALLTRIM(aDespesa[nAux,13,nAux2,7]),1) })  // campo p/ grv aliq
              ELSE
                 aValores[nPos,2]+=aDespesa[nAux,13,nAux2,4]  // valor do imposto
                 aValores[nPos,3]+=aDespesa[nAux,13,nAux2,3]  // base do imposto
              ENDIF
          NEXT*/
          AADD(aItens,ACLONE(aItem))
       ENDIF
    ENDIF
NEXT   
IF !lMV_EASY_SIM .AND. LEN(aItens) # 0
   FOR ITE := 1 TO LEN(aItens) 
       aItem:=aItens[ITE]
       IF LEN(aItem) # 0
          SD2->(RecLock("SD2",.T.))
          SD2->D2_FILIAL := xFilial("SD2")
          FOR GRV := 1 TO LEN(aItem) 
              IF ( nPos:=SD2->( FIELDPOS(aItem[GRV,1]) ) ) # 0
                 SD2->( FIELDPUT(nPos,aItem[GRV,2]) )
              ENDIF
          NEXT
         SD2->(MsUnlock())
   	   ENDIF
   NEXT
ENDIF

nValor := MDI_OUTR
nCIF   := MDI_OUTR
nPesol := nFrete := nSeguro := 0
RETURN .T.

*-----------------------------------------------*
STATIC Function DIGerImpostos(lDespesas) //MLS 23/06/2004
*-----------------------------------------------*
LOCAL lEof:=.F. ,aDespBase:={},aDespGera:={},aTabAll:={},aTab1:={},aTabNCM:={}
LOCAL cFilSA2:=xFilial("SA2"),I,A,nDesp
aTotais      :={};nTotImpostos:=0
lCurrier     := SW6->W6_CURRIER $ cSim
lGrvDespSD1  := GETNEWPAR("MV_DESPSD1","N") $ cSim
ProcRegua(Work1->(LastRec()))
SA2->(DBSETORDER(1))
SYB->(DBSETORDER(1))
SYD->(DBSETORDER(1))           
SWD->(DBSETORDER(1))
Work2->(DBSETORDER(1))
WorkTES->(__DBZAP())
Work1->(DBGOTOP())
DO WHILE Work1->(!EOF())
   IncProc("Item: "+' '+Work1->WKCOD_I) //"Item: "
   IF !lDespesas
      lGera:=!EMPTY(Work1->WKTEC) .AND. ;
             SYD->(DbSeek(xFilial("SYD")+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM)) .AND. ;
             !EMPTY(SYD->YD_TES)
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
   IF lGera .OR. !lDespesas
      aDespBase:={}        
      aDespGera:={}
      aTabAll  :={}
      Work1->(DbSkip())
      lEof :=Work1->(EOF())
      Work1->(DbSkip(-1))

      IF lDespesas
         //ELSE//Despesas
         SA2->(DBSEEK(cFilSA2+Work1->WKFORN+Work1->WKLOJA))
         aTab1:=CalcImpGer(cCodTES,,,Work1->WKVALMERC,,,,{},,MDI_OUTR,lEof)
         AADD(aTab1,"D"+LEFT(Work1->WKDESPESA,LEN(SWD->WD_DESPESA)))  // AWR - p/ identificar que o imposto se refere a despesa 
         AADD(aTabAll,aTab1)
      ENDIF         
      Work1->WKIMPOSTOS:=0//Eh preciso Zerar por causa da alteracao do peso
      SFB->(DBSETORDER(1))
      FOR A := 1 TO LEN(aTabAll)
         aTab:=aTabAll[A]
         IF !EMPTY(aTab)
            FOR I := 1 TO LEN(aTab[6])
               IF lCurrier .AND. aTab[LEN(aTab)] = "P" .AND. !(aTab[6,I,1] $ "EIV,ETE,EDI")
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

// EOS           
IF lGrvDespSD1 .AND. ( cTipoNF == NFE_DESPESAS .OR. cTipoNF == NFE_IMPOSTOS )
   FOR nDesp := 1 to LEN(aDespesa)
       Work4->(DBGOTO(aDespesa[nDesp,5]))
       IF EMPTY(Work4->WKFLAG)
          LOOP
       ENDIF
       SA2->(DBSEEK(cFilSA2+Work4->WKFORN+Work4->WKLOJA))
       aTab1:=CalcImpGer(Work4->WKTES,,,Work4->WKVALOR,,,,{},,MDI_OUTR,.F.)      
       AADD( aDespesa[nDesp], aTab1[6] )
   NEXT
ENDIF
Work1->(DBGOTOP())
Return .T.

*--------------------------------------------------------------------------------------*
Function DINCPLegend() //MLS 17/06/2004
*--------------------------------------------------------------------------------------*

BrwLegenda(cCadastro,"Leyenda",{{"ENABLE"   ,"Hay gastos que no tienen factura generada  "}    ,;  //Verde
                                {"DISABLE"  ,"No hay mas gastos sin factura generada     "}    ,;  //Vermelho
                                {"BR_AZUL"  ,"No hay Tasa de Conv.y/o N.Despacho DI      "}} )     //Azul
Return .T.

//------------------------------------------------------------------------------------//
//                        FIM DO PROGRAMA EICDINCP_RDM.PRW 
//------------------------------------------------------------------------------------//
