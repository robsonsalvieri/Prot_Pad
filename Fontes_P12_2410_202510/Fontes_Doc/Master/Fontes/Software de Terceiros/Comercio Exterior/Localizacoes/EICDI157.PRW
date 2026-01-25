#INCLUDE "Eicdi157.ch"
/*
Autor:		Alex Wallauer
Função:		EICDI157
Descrição:	Emissão do Relatório do Custo Realizado do Processo / Solicitação da N.F.E.
Data:       06/Jul/2001
*/                                                             
//----------------------------------------------------------------------------//
// Printer                                                                  
#xcommand TRACO_NORMAL  => oPrn:Line(nxLinha,  0050,nxLinha,  2300);
						;  oPrn:Line(nxLinha+1,0050,nxLinha+1,2300) 
#xcommand TRACO_REDU_01 => oPrn:Box(nxLinha+nxIncrem,0050,nxLinha+nxIncrem+1,0950)
#xcommand TRACO_REDU_02 => oPrn:Box(nxLinha,1270,nxLinha+1,2300)
#xcommand TRACO_REDU_03 => oPrn:Box(nxLinha,0750,nxLinha+1,2300)
#xcommand TRACO_VERT_01 => oPrn:Line(nxLinha,0049,nxLinha+nxIncrem,0049);
						;  oPrn:Line(nxLinha,0050,nxLinha+nxIncrem,0050);
						;  oPrn:Line(nxLinha,2299,nxLinha+nxIncrem,2299);
						;  oPrn:Line(nxLinha,2300,nxLinha+nxIncrem,2300)
#xcommand TRACO_VERT_02 => oPrn:Box(nxLinha,0950,nxLinha+nxIncrem,0951)
#xcommand COMECA_PAGINA => AVNEWPAGE; nxLinha:=0; ++nxPagina; ICus_INICPG()
#xcommand ENCERRA_PAGINA => TRACO_NORMAL  
//----------------------------------------------------------------------------//
// Definicao de Fontes
#xtranslate :ARIAL_08       => \[1\]
#xtranslate :ARIAL_08_BOLD  => \[2\]
#xtranslate :ARIAL_09_BOLD  => \[3\]
#xtranslate :ARIAL_10       => \[4\]
#xtranslate :ARIAL_10_BOLD  => \[5\]
#xtranslate :ARIAL_13_BOLD  => \[6\]
#xtranslate :ARIAL_18_BOLD  => \[7\]
#DEFINE COURIER_09 oFont8
//----------------------------------------------------------------------------//
// Definição de Apresentação de Datas
#xtranslate DATA_MES(<x>)   => SUBS(DTOC(<x>),1,2)+" "+SUBS(MesExtenso(<x>),1,3)+" "+SUBS(DTOC(<x>),7,2)
#INCLUDE "FONT.CH"
#INCLUDE "AVPRINT.CH"
#INCLUDE "PRINT.CH"
#include "rwmake.ch"
//----------------------------------------------------------------------------//
#DEFINE  NFE_FOB       '5'//1
#DEFINE  NFE_FRETE     '6'//2
#DEFINE  NFE_SEGURO    '7'//3
#DEFINE  NFE_CIF       '8'//6
#DEFINE  NFE_IMPOSTOS  '9'//4
#DEFINE  NFE_DESPESAS  'A'//5
#DEFINE  CUSTO_REAL    'B'//7
#DEFINE  NFE_PRIMEIRA  "5,6,7,A"//"1,2,3,6"
#DEFINE  NFE_FRE_SEG   "6,7"//"2,3"
#DEFINE  NFE_FOB_SEG   "5,7"//"1,3"
#DEFINE  NFE_FRE_FOB   "5,6"//"2,1"

*===================================*
Function EICDI157(ParamIXB)
//USER FUNCTION EICDI157()
*===================================*
PRIVATE cPictPeso:= AVSX3('B1_PESO',6)
PRIVATE cSim:="SY1",cNao:="2N"

nRelTipo:=ParamIXB

//OBS.: QUANDO ESTE PROGRAMA FOR PASSADO P/ RDMAKE, TIRAR ESTA CHAMADA P/ NAO OCORRER LOOP//
IF EasyEntryPoint("EICDI157")
   ExecBlock("EICDI157",.F.,.F.,nRelTipo)
   RETURN .T.
ENDIF
//----------------------------------------------------------------------------------------//

IF nRelTipo == NIL            
   cProcesso:=SPACE(LEN(SW6->W6_HAWB))
   nOpc:=0
   @ 000,000 TO 095,340 DIALOG oDlg TITLE STR0001 //"Relatorio de Custo Realizado"
  	
     @ 010,010 SAY STR0002 SIZE 50,10 //"Processo:"
     @ 010,040 GET cProcesso   SIZE 70,10 F3 'SW6' 
     @ 005,130 BMPBUTTON TYPE 01	ACTION (IF(DI157Valid(),(nOpc:=1,oDlg:End()),))
     @ 020,130 BMPBUTTON TYPE 02	ACTION (nOpc:=0,oDlg:End())
	  
   ACTIVATE DIALOG oDlg CENTERED
   If nOpc==0
      RETURN .F.
   EndIf
   nRelTipo:=CUSTO_REAL
ENDIF

IF nRelTipo == "TXT"//--- Emissão do TXT
   DI157PRETXT()
   RETURN .T.
ENDIF

IF nRelTipo == CUSTO_REAL//--- Emissão do Custo Realizado
  	DI157Custo()
ELSE
  	DI157NFE(nRelTipo)
Endif

RETURN .T.
*----------------------------*
Static Function DI157Valid()
*----------------------------*
SW6->(DBSETORDER(1))
IF !SW6->(DBSEEK(xFiliaL('SW6')+cProcesso))
   MSGINFO(STR0003,STR0004) //"Processo não cadastrado"###"Atenção"
   RETURN .F.
ENDIF

EI1->(DBSETORDER(1))
EI2->(DBSETORDER(1))
If	!EI1->(dBSeek(xFilial('EI1')+SW6->W6_HAWB)).or.;
  	!EI2->(dBSeek(xFilial('EI2')+SW6->W6_HAWB))
  	MsgInfo(STR0005,STR0006) //"Não existe CUSTO gravado nesse Processo para ser impresso."###"Custo Realizado"
  	Return .F.
EndIf

RETURN .T.
*----------------------------*
Static Function DI157Custo()
*----------------------------*
Local axSimNao	:={STR0007,STR0008} //"S-Sim"###"N-Não"
Local axTipoRel	:={STR0009,STR0010} //"P-Por P.O."###"I-Por Item"
Local axStru1	:={}
//Local axStru2	:={}
Local cxArqTrab1:=''
Local cxArqTrab2:=''
Local cxTitulo	:=STR0006 //"Custo Realizado"
Local nxOpc		:=0     

// Configuração do Relatório e Definição/Carga de variáveis
lxCusPO		:=.T.
lxCusIte	:=.T.
lxDespDet	:=.T.
lxResPO		:=.T.
lxResCC		:=.T.
lxExistDv	:=.F.
lxResDV		:=.F.
nxIncrem	:=50
nxPagina	:=0
nxLinha		:=0
nxTcIPIICM	:=0							//---	Total com IPI e ICM
nxTsIPIICM	:=0							//---	Total sem IPI e ICM
nxRotinas	:=0
cxPicQtde	:='@E 99,999,999.99'
cxPicValor	:='@E 999,999,999.99'
cxPicPerc	:='@E 9999.999'
dxVencto	:=AVCTOD("  /  /  ")
dxLiquid	:=AVCTOD("  /  /  ")
dxContrat	:=AVCTOD("  /  /  ")
lLote       := EasyGParam("MV_LOTEEIC") $ cSim
lLoteCpos   :=SX3->(dBSeek('WW_LOTECTL')) .AND.;
              SX3->(dBSeek('EI2_LOTECT')) .AND.;
              SX3->(dBSeek('EI2_DTVALI'))
//--- Verifica qual será a configuração do lay-Out de Impressão dentre os 
//--- 32 possíveis quando existir o campo Y3_DIVIS ou entre os 16 posíveis
//--- quando não existir o campo Y3_DIVIS no SY3.
	SX3->(dBSetOrder(2))
	If SX3->(dBSeek('Y3_DIVIS'))
		lxExistDV:=.T.
		lxResDV	 :=.T.
	EndIf
lTemCposEI2 := SX3->(DBSEEK("EI2_FOB_R"))
	SX3->(dBSetOrder(1))		
	@ 000,000 TO 160,350 DIALOG oDlg TITLE cxTitulo+STR0011+SW6->W6_HAWB //"   Processo: "
	@ 002,005 TO 070,135
	@ 010,010 CHECKBOX STR0012		   VAR lxDespDet //"Despesas detalhadas"
	@ 020,010 CHECKBOX STR0013						    VAR lxCusPO //"Custo por P.O."
	@ 030,010 CHECKBOX STR0014						    VAR lxCusIte //"Custo por Item"
	@ 040,010 CHECKBOX STR0015					    VAR lxResPO //"Resumo por P.O."
	@ 050,010 CHECKBOX STR0016	VAR lxResCC //"Resumo por Centro Custo"
 If lxExistDv
  		@ 060,010 CHECKBOX STR0017			VAR lxResDV //"Resumo por Divisão"
	EndIf
	@ 005,145 BMPBUTTON TYPE 01	ACTION (nxOpc:=1,oDlg:End())
	@ 020,145 BMPBUTTON TYPE 02	ACTION (nxOpc:=0,oDlg:End())
	ACTIVATE DIALOG oDlg CENTERED
	If nxOpc==0
	   RETURN .F.//EXIT
	EndIf
	nxRotinas	:=3
	If	lxCusPO
		  ++nxRotinas
	EndIf
	If	lxCusIte
		  ++nxRotinas
	EndIf
	If	lxResPO
		  ++nxRotinas
	EndIf
	If	lxResCC
		  ++nxRotinas
	EndIf
	If	lxResDV
		  ++nxRotinas
	EndIf
//EndIf
//----------------------------------------------------------------------------//
// Posiciona os arquivos de CUSTO
EI1->(DBSETORDER(1))
EI2->(DBSETORDER(1))
If	EI1->(!dBSeek(xFilial('EI1')+SW6->W6_HAWB)).or.;
	  EI2->(!dBSeek(xFilial('EI2')+SW6->W6_HAWB))
  	MsgInfo(STR0018,STR0006) //"É necessário que o CUSTO esteja gravado para ser impresso!."###"Custo Realizado"
  	Return
EndIf
nxNR_EI1:=0
nxNR_EI2:=0
EI1->(dBEval({|| nxNR_EI1++},,{|| EI1_FILIAL+EI1_HAWB==xFilial('EI1')+SW6->W6_HAWB}))
EI2->(dBEval({|| nxNR_EI2++},,{|| EI2_FILIAL+EI2_HAWB==xFilial('EI2')+SW6->W6_HAWB}))
EI1->(dBSeek(xFilial('EI1')+SW6->W6_HAWB))
EI2->(dBSeek(xFilial('EI2')+SW6->W6_HAWB))
//----------------------------------------------------------------------------//
// Arquivo termporário
If lxExistDV
	xxAux:=If(AvSX3('Y3_COD',3)>AvSX3('Y3_DIVIS',3),AvSX3('Y3_COD',3),AvSX3('Y3_DIVIS',3))
Else
	xxAux:=AvSX3('Y3_COD',3)
EndIf
//
aAdd(axStru1,{"WK1TIPO",	"C",1,0})		  				// 1=PO+CC 2=Centro de Custo 3=Divisao
aAdd(axStru1,{"WK1PEDIDO",	"C",AvSX3('W2_PO_NUM',3),0})	// Número do PO
aAdd(axStru1,{"WK1CODIGO",	"C",xxAux,0})  					// Centro de Custo/Divisao
aAdd(axStru1,{"WK1ITEM",	"C",AvSX3('B1_COD',3),0})		// Código Item
aAdd(axStru1,{"WK1POSICA",	"C",AvSX3('W3_POSICA',3),0})	// Posição Item
aAdd(axStru1,{"WK1DESP",	"C",40,0})		  				// Despesa
aAdd(axStru1,{"WK1VALSEM",	"N",14,2})  					// Valor sem impostos
aAdd(axStru1,{"WK1VALCOM",	"N",14,2})  					// Valor com impostos/Valor Despesa
aAdd(axStru1,{"WK1VALDES",	"N",14,2})  					// Valor Despesa da variacao cambial para nao gerar o valor em Dolar.(701.702.703)//FCD OS.:0080/02 SO.:0015/02
aAdd(axStru1,{"WK1UN",		"C",02,0})		  				// Unidade
aAdd(axStru1,{"WK1QTDE",	"N",AvSX3('W3_QTDE',3),AvSX3('W3_QTDE',4)})	// Quantidade
aAdd(axStru1,{"WK1FABR",	"C",AvSX3('W3_FABR',3),0})      // Valor com impostos/Valor Despesa  //SO0026/02 SO.:0214/02  FCD
aAdd(axStru1,{"WK1POSIPI",	"C",AvSX3('B1_POSIPI',3),0})	// N.C.M.
aAdd(axStru1,{"WK1EX_NCM",	"C",AvSX3('B1_EX_NCM',3),0})	// EX-NCM
aAdd(axStru1,{"WK1EX_NBM",	"C",AvSX3('B1_EX_NBM',3),0})	// EX_NBM
//Segundo Rogeiro o no. da GI e' igual o no. da PLI - AWR
//Solucao do erro de duplicar as despesas: tamanho do campo
aAdd(axStru1,{"WK1GI_NUM",	"C",AvSX3('W4_PGI_NUM',3),0})	// Número da L.I. do item
nTam:=AvSX3('WN_LOTECTL',3)
aAdd(axStru1,{"WK1_LOTE" ,	"C",nTam,0})	// Número de Lote
aAdd(axStru1,{"WK1_DTVAL",	"D",08,0})	// Validade do Lote
AADD(axStru1,{"WK1PESO", "N",AVSX3("B1_PESO",3),AVSX3("B1_PESO",4)})


//
//         1         2         3         4         5         6         7         8         9         0
//123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789
//1TOT            PRC                                                                  99999999999999           - Total do Processo
//2XXXXXXXXXXXXXXXXXXXXXXXXX                                                           99999999999999           - Total PO+CC
//3XXXXXXXXXXXXXXXPED                                                                  99999999999999           - Total do PO
//4TOTCC          XXXXXXXXXX                                                           99999999999999           - Total do CC
//5TOTDV          XXXXXXXXXX                                                           99999999999999           - Total da Divisão
//6                                            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX99999999999999           - Despesas do Processo
//7XXXXXXXXXXXXXXX                             XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX99999999999999           - Despesas do PO
//8XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX9999XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX99999999999999XX99999999 - Despesas do Item/CC/PO
//9XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX9999XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX99999999999999XX99999999 -
//

cxArqTrab1 := E_CriaTrab(,axStru1,'TRB1') //Temporario no Banco de Dados

If NetErr()
	MsgBox(STR0019,STR0020,"STOP") //"ERRO DE REDE!."###"Criação de arquivo temporário"
	Return
EndIf
//MFR OSSME-1974 26/12/2018
IndRegua('TRB1',(cxArqTrab1+TeOrdBagExt()),'WK1TIPO+WK1PEDIDO+WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM+WK1DESP')

SYD->(DBSETORDER(1))
SFB->(DBSETORDER(1))
SW3->(dBSetOrder(8))
EI2->(Processa({|| MontaTRBa()}))
EI1->(Processa({|| MontaTRBb()}))

SW3->(dBSetOrder(1))
//
//----------------------------------------------------------------------------//
// Posiciona os arquivos que serao trabalhados
SW7->(dBSeek(xFilial('SW7')+SW6->W6_HAWB))								//--- Item Desembaraco
SW1->(dBSeek(xFilial('SW1')+SW7->(W7_CC+W7_SI_NUM+W7_COD_I)))			//--- Item SI
SW2->(dBSeek(xFilial('SW2')+SW7->W7_PO_NUM))							//--- PO
SYT->(dBSeek(xFilial('SYT')+SW2->W2_IMPORT))							//--- Importadores
SA2->(dBSeek(xFilial('SA2')+SW2->W2_FORN))								//--- Fornecedores
SYQ->(dBSeek(xFilial('SYQ')+SW6->W6_VIA_TRA))							//--- Vias de Transporte
SYR->(dBSeek(xFilial('SYR')+SW6->(W6_VIA_TRA+W6_ORIGEM+W6_DEST)))
xxAux:=SY9->(IndexOrd())
SY9->(dBSetOrder(2))
SY9->(dBSeek(xFilial('SY9')+SYR->YR_DESTINO))							//--- Portos/Aeroportor
SY9->(dBSetOrder(xxAux))
SY4->(dBSeek(xFilial('SY4')+SW6->W6_AGENTE))							//--- Agente
SY5->(dBSeek(xFilial('SY5')+SW6->W6_DESP))								//--- Despachante
If !Empty(SW2->W2_EMISCCA).or.!Empty(SW2->W2_NRCCAMB).or.!Empty(SW2->W2_RECCCAM)
	SA6->(dBSeek(xFilial('SA6')+SW2->(W2_BANCO+W2_AGENCIA)))			//--- BANCOS
	dxVencto	:=	SW2->W2_EMISCCA
	dxContrat	:=	AVCTOD('')
	dxLiquid	:=	SW2->W2_RECCCAM
Else
	SWB->(dBSeek(xFilial('SWB')+SW6->W6_HAWB))							//--- CAMBIO
	SA6->(dBSeek(xFilial('SA6')+SWB->(WB_BANCO+WB_AGENCIA)))			//--- BANCOS
	dxVencto	:=	SWB->WB_DT_VEN
	dxContrat	:=	SWB->WB_DT_CONT
	dxLiquid	:=	SWB->WB_CA_DT
EndIf
IF !EMPTY(SW6->W6_COND_PA)
   SY6->(dBSeek(xFilial('SY6')+SW6->W6_COND_PA+STR(SW6->W6_DIAS_PA,3,0)))	//--- CONDICAO DE PAGAMENTO
ELSE
   SY6->(dBSeek(xFilial('SY6')+SW2->W2_COND_PA+STR(SW2->W2_DIAS_PA,3,0)))	//--- CONDICAO DE PAGAMENTO
ENDIF

//--- Continua rotina...
oFont1		:=oFont2 :=oFont3:=oFont4 :=oFont5 :=oFont6 :=NIL
oFont7		:=oFont8 :=oFont9:=oFont10:=oFont11:=aFontes:=NIL
oPrn		:=NIL
AVPRINT oPrn NAME STR0021 //"Emissão do Custo Realizado"
	oFont1 :=oSend(TFont(),'NEW','Arial',      0,08 ,,.F.,,,,,.F.,,,,,,oPrn)
	oFont2 :=oSend(TFont(),'NEW','Arial',      0,08 ,,.T.,,,,,.F.,,,,,,oPrn)
	oFont3 :=oSend(TFont(),'NEW','Arial',      0,09 ,,.T.,,,,,.F.,,,,,,oPrn)
	oFont4 :=oSend(TFont(),'NEW','Arial',      0,10 ,,.F.,,,,,.F.,,,,,,oPrn)
	oFont5 :=oSend(TFont(),'NEW','Arial',      0,10 ,,.T.,,,,,.F.,,,,,,oPrn)
	oFont6 :=oSend(TFont(),'NEW','Arial',      0,13 ,,.T.,,,,,.F.,,,,,,oPrn)
	oFont7 :=oSend(TFont(),'NEW','Arial',      0,18 ,,.T.,,,,,.F.,,,,,,oPrn)
	oFont8 :=oSend(TFont(),'NEW','Courier New',0,09 ,,.T.,,,,,.F.,,,,,,oPrn)
	aFontes:={oFont1,oFont2,oFont3,oFont4,oFont5,oFont6,oFont7}
	AVPAGE
		Processa({|x| lEnd:=x, ICus_CUSTO()})
	AVENDPAGE
	oSend(oFont1,'END')
	oSend(oFont2,'END')
	oSend(oFont3,'END')
	oSend(oFont4,'END')
	oSend(oFont5,'END')
	oSend(oFont6,'END')
	oSend(oFont7,'END')
AVENDPRINT

TRB1->(E_EraseArq(cxArqTrab1))

Return

*=========================*
Static Function MontaTRBa()
*=========================*
LOCAL aTab:={}
PRIVATE cLote
PRIVATE nTotImpostos:=0
ProcRegua(nxNR_EI2)
DO While EI2->(!Eof()).and.EI2->EI2_FILIAL+EI2->EI2_HAWB==xfilial("EI2")+SW6->W6_HAWB
   IncProc(STR0022) //"Montando o Arquivo de Trabalho 01/02..."
    cLote   := EI2->EI2_LOTECT
    dDataVal:= EI2->EI2_DTVALI
   aTab:={}
   IF !EMPTY(EI2->EI2_TEC) .AND. ;
      SYD->(DbSeek(xFilial("SYD")+EI2->EI2_TEC+EI2->EI2_EX_NCM+EI2->EI2_EX_NBM)) .AND. ;
	  !EMPTY(SYD->YD_TES)
	  aTab:=DI156DFB(SYD->YD_TES)
   ENDIF
   ICPadGrvImp("6",TRB1->(Space(Len(WK1PEDIDO+WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM))),aTab )
   //--- Totaliza Processo
   If TRB1->(!dBSeek('1TOT'+Spac(Len(TRB1->WK1PEDIDO)-3)+"PRC"))
      TRB1->(DBAPPEND())
	  TRB1->WK1TIPO   :='1'
	  TRB1->WK1PEDIDO :='TOT'
	  TRB1->WK1CODIGO :='PRC'
   EndIf
   TRB1->WK1VALCOM+=(EI2->EI2_VALOR+nTotImpostos)
   TRB1->WK1VALSEM+=EI2->EI2_VALOR
   //--- Totaliza Centros de Custos dentro do PO
	If !TRB1->(dBSeek('2'+EI2->(EI2_PO_NUM+PadL(EI2_CC,Len(TRB1->WK1CODIGO)))))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :='2'
			TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
			TRB1->WK1CODIGO :=EI2->EI2_CC
		EndIf
	TRB1->WK1VALCOM += (EI2->EI2_VALOR+nTotImpostos)
	TRB1->WK1VALSEM += EI2->EI2_VALOR
		//--- Totaliza PO
		If TRB1->(!dBSeek('3'+EI2->EI2_PO_NUM+'PED'))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :='3'
			TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
			TRB1->WK1CODIGO :='PED'
		EndIf
	TRB1->WK1VALCOM  +=(EI2->EI2_VALOR+nTotImpostos)
	TRB1->WK1VALSEM  +=EI2->EI2_VALOR
	//--- Totaliza CC
	If lxResCC
		If TRB1->(!dBSeek('4TOTCC'+Space(Len(TRB1->WK1PEDIDO)-5)+EI2->EI2_CC))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :='4' 
			TRB1->WK1PEDIDO :='TOTCC'
			TRB1->WK1CODIGO :=EI2->EI2_CC
		EndIf
		TRB1->WK1VALCOM  +=(EI2->EI2_VALOR+nTotImpostos)
		TRB1->WK1VALSEM  +=EI2->EI2_VALOR
	EndIf
	//--- Totaliza Divisão
	If lxResDV
		SY3->(dBSeek(xFilial('SY3')+EI2->EI2_CC))
		If TRB1->(!dBSeek('5TOTDV'+Space(Len(TRB1->WK1PEDIDO)-5)+SY3->Y3_DIVIS))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :='5'
			TRB1->WK1PEDIDO :='TOTDV'
			TRB1->WK1CODIGO :=SY3->Y3_DIVIS
		EndIf
		TRB1->WK1VALCOM+=(EI2->EI2_VALOR+nTotImpostos)
		TRB1->WK1VALSEM+=EI2->EI2_VALOR
	EndIf
	//--- Descreve FOB/FRETE/SEGURO/CIF/II/IPI/ICMS/TOTAL IMPOSTOS por Processo
	If TRB1->(!dBSeek('6'+TRB1->(Space(Len(WK1PEDIDO+WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+'101'))
       TRB1->(DBAPPEND())
		TRB1->WK1TIPO   :='6'
		TRB1->WK1DESP	:=STR0023 //"101-F.O.B."
		TRB1->WK1VALCOM :=IF(lTemCposEI2,EI2->EI2_FOB_R,EI2->(EI2_CIF-EI2_SEGURO-EI2_FRETE))
	Else
		TRB1->WK1VALCOM :=TRB1->WK1VALCOM + IF(lTemCposEI2,EI2->EI2_FOB_R,EI2->(EI2_CIF-EI2_SEGURO-EI2_FRETE))
	EndIf

	If EI2->EI2_FRETE > 0
		If TRB1->(!dBSeek('6'+TRB1->(Space(Len(WK1PEDIDO+WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+"102"))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :='6'
			TRB1->WK1DESP	:=STR0024 //"102-FRETE"
			TRB1->WK1VALCOM :=EI2->EI2_FRETE
		Else
			TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_FRETE
		EndIf
	EndIf
	If EI2->EI2_SEGURO > 0
		If TRB1->(!dBSeek('6'+TRB1->(Space(Len(WK1PEDIDO+WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+"103"))
            TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :='6'
			TRB1->WK1DESP	:=STR0025 //"103-SEGURO"
			TRB1->WK1VALCOM :=EI2->EI2_SEGURO
		Else
			TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_SEGURO
		EndIf
	Endif
	If TRB1->(!dBSeek("6"+TRB1->(Space(Len(WK1PEDIDO+WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+"104"))
       TRB1->(DBAPPEND())                                                                          
		TRB1->WK1TIPO   :="6"
		TRB1->WK1DESP	:=STR0026 //"104-C.I.F."
		TRB1->WK1VALCOM :=EI2->EI2_CIF
	Else
		TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_CIF
	EndIf

	ICPadGrvImp( "7",EI2->EI2_PO_NUM+Space(Len(TRB1->(WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM))),aTab )

	If TRB1->(!dBSeek("7"+EI2->EI2_PO_NUM+Space(Len(TRB1->(WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+"101"))
       TRB1->(DBAPPEND())
		TRB1->WK1TIPO   :="7"
		TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
		TRB1->WK1DESP	:=STR0023 //"101-F.O.B."
		TRB1->WK1VALCOM :=IF(lTemCposEI2,EI2->EI2_FOB_R,EI2->(EI2_CIF-EI2_SEGURO-EI2_FRETE))
	Else
		TRB1->WK1VALCOM :=TRB1->WK1VALCOM + IF(lTemCposEI2,EI2->EI2_FOB_R,EI2->(EI2_CIF-EI2_SEGURO-EI2_FRETE))
	EndIf
	If EI2->EI2_FRETE > 0
		If TRB1->(!dBSeek("7"+EI2->EI2_PO_NUM+Space(Len(TRB1->(WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+"102"))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :="7"
			TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
			TRB1->WK1DESP	:=STR0024 //"102-FRETE"
			TRB1->WK1VALCOM :=EI2->EI2_FRETE
		Else
			TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_FRETE
		EndIf
	EndIf
	If EI2_SEGURO > 0
		If TRB1->(!dBSeek("7"+EI2->EI2_PO_NUM+Space(Len(TRB1->(WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+"103"))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :="7"
			TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
			TRB1->WK1DESP	:=STR0025 //"103-SEGURO"
			TRB1->WK1VALCOM :=EI2->EI2_SEGURO
		Else
			TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_SEGURO
		EndIf
	EndIf
	If TRB1->(!dBSeek("7"+EI2->EI2_PO_NUM+Space(Len(TRB1->(WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+"104"))
       TRB1->(DBAPPEND())
		TRB1->WK1TIPO   :="7"
		TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
		TRB1->WK1DESP	:=STR0026 //"104-C.I.F."
		TRB1->WK1VALCOM :=EI2->EI2_CIF
	 Else
		TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_CIF
	 EndIf
	 ///--- Descreve FOB/FRETE/SEGURO/CIF/II/IPI/ICMS/TOTAL IMPOSTOS por Item
	 SW3->(dBSetOrder(8))
	 SW3->(dBSeek(xFilial("SW3")+EI2->(EI2_PO_NUM+EI2_POSICA)))
	
	 ICPadGrvImp( "8",EI2->(EI2_PO_NUM+EI2_CC+EI2_PRODUTO)+EI2->EI2_POSICA+cLote+EI2->EI2_PGI_NU,aTab)

	 If TRB1->(!dBSeek("8"+EI2->(EI2_PO_NUM+EI2_CC+EI2_PRODUTO+EI2_POSICA+cLote+EI2_PGI_NU)+"101"))
       TRB1->(DBAPPEND())
		TRB1->WK1TIPO   :="8"
		TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
		TRB1->WK1CODIGO :=EI2->EI2_CC
		TRB1->WK1ITEM   :=EI2->EI2_PRODUTO
		TRB1->WK1POSICA :=EI2->EI2_POSICA
		TRB1->WK1_LOTE  :=cLote
		TRB1->WK1DESP	:=STR0023 //"101-F.O.B."
		TRB1->WK1VALCOM :=IF(lTemCposEI2,EI2->EI2_FOB_R,EI2->(EI2_CIF-EI2_SEGURO-EI2_FRETE))
		TRB1->WK1GI_NUM :=EI2->EI2_PGI_NU
		TRB1->WK1PESO   :=EI2->EI2_PESOL		
	 Else
		TRB1->WK1VALCOM :=TRB1->WK1VALCOM + IF(lTemCposEI2,EI2->EI2_FOB_R,EI2->(EI2_CIF-EI2_SEGURO-EI2_FRETE))
	 EndIf
	 If EI2->EI2_FRETE > 0
		If TRB1->(!dBSeek("8"+EI2->(EI2_PO_NUM+EI2_CC+EI2_PRODUTO+EI2_POSICA+cLote+EI2_PGI_NU)+"102"))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :="8"
			TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
			TRB1->WK1CODIGO :=EI2->EI2_CC
			TRB1->WK1ITEM 	:=EI2->EI2_PRODUTO
			TRB1->WK1POSICA :=EI2->EI2_POSICA
            TRB1->WK1_LOTE  :=cLote
			TRB1->WK1DESP	:=STR0024 //"102-FRETE"
			TRB1->WK1VALCOM :=EI2->EI2_FRETE
   		    TRB1->WK1GI_NUM :=EI2->EI2_PGI_NU
   		    TRB1->WK1PESO   :=EI2->EI2_PESOL
		Else
			TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_FRETE
		EndIf
	 EndIf
	 If EI2->EI2_SEGURO > 0
		If TRB1->(!dBSeek("8"+EI2->(EI2_PO_NUM+EI2_CC+EI2_PRODUTO+EI2_POSICA+cLote+EI2_PGI_NU)+"103"))
           TRB1->(DBAPPEND())
			TRB1->WK1TIPO   :="8"
			TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
			TRB1->WK1CODIGO :=EI2->EI2_CC
			TRB1->WK1ITEM 	:=SW3->W3_COD_I
			TRB1->WK1POSICA :=EI2->EI2_POSICA
            TRB1->WK1_LOTE  :=cLote
			TRB1->WK1DESP	:=STR0025 //"103-SEGURO"
			TRB1->WK1VALCOM :=EI2->EI2_SEGURO
		    TRB1->WK1GI_NUM :=EI2->EI2_PGI_NU
   		    TRB1->WK1PESO   :=EI2->EI2_PESOL
		Else
			TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_SEGURO
		EndIf
	 EndIf
 	 If TRB1->(!dBSeek("8"+EI2->(EI2_PO_NUM+EI2_CC+EI2_PRODUTO+EI2_POSICA+cLote+EI2_PGI_NU)+"104"))
        TRB1->(DBAPPEND())
		TRB1->WK1TIPO   :="8"
		TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
		TRB1->WK1CODIGO :=EI2->EI2_CC
		TRB1->WK1ITEM 	:=SW3->W3_COD_I
		TRB1->WK1POSICA :=EI2->EI2_POSICA
        TRB1->WK1_LOTE  :=cLote
		TRB1->WK1DESP	:=STR0026 //"104-C.I.F."
		TRB1->WK1VALCOM :=EI2->EI2_CIF
		TRB1->WK1GI_NUM :=EI2->EI2_PGI_NU
		TRB1->WK1PESO   :=EI2->EI2_PESOL
	 Else
		TRB1->WK1VALCOM :=TRB1->WK1VALCOM + EI2->EI2_CIF
	 EndIf

 	 If TRB1->(!dBSeek("9"+EI2->(EI2_PO_NUM+EI2_CC+EI2_PRODUTO+EI2_POSICA+cLote+EI2_PGI_NU)))
        TRB1->(DBAPPEND())
		TRB1->WK1TIPO   :="9"
		TRB1->WK1PEDIDO :=EI2->EI2_PO_NUM
		TRB1->WK1CODIGO :=EI2->EI2_CC
		TRB1->WK1ITEM 	:=SW3->W3_COD_I
		TRB1->WK1POSICA :=EI2->EI2_POSICA
        TRB1->WK1_LOTE  :=cLote
		TRB1->WK1_DTVAL :=dDataVal
		TRB1->WK1UN		:=EI2->EI2_UNI
		TRB1->WK1QTDE	:=EI2->EI2_QUANT
		TRB1->WK1FABR	:=SW3->W3_FABR
		TRB1->WK1POSIPI	:=EI2->EI2_TEC
		TRB1->WK1EX_NCM	:=EI2->EI2_EX_NCM
		TRB1->WK1EX_NBM	:=EI2->EI2_EX_NBM
  	    TRB1->WK1PESO   :=EI2->EI2_PESOL
  	    TRB1->WK1GI_NUM :=EI2->EI2_PGI_NU
	EndIf
	TRB1->WK1VALCOM +=(EI2->EI2_VALOR+nTotImpostos)
	TRB1->WK1VALSEM +=EI2->EI2_VALOR

	EI2->(dBSkip())
EndDo
Return

*===============================================*
Static Function ICPadGrvImp(cTipo,cChave,aTab)
*===============================================*
Local E
nTotImpostos:=0
IF !EMPTY(aTab)
   FOR E := 1 TO LEN(aTab)
       nCpoVLR:=EI2->( FIELDPOS("EI2"+STUFF(aTab[E,3],7,1,"")) )
       If !TRB1->(DBSeek(cTipo+cChave+aTab[E,1]))
          SFB->(DBSEEK(xFilial("SFB")+aTab[E,1]))
          TRB1->(DBAPPEND())
          TRB1->WK1TIPO     :=cTipo
          IF cTipo # "6"
             TRB1->WK1PEDIDO:=EI2->EI2_PO_NUM
          ENDIF
          IF cTipo = "8"
             TRB1->WK1CODIGO:=EI2->EI2_CC
             TRB1->WK1ITEM  :=EI2->EI2_PRODUT
             TRB1->WK1POSICA:=EI2->EI2_POSICA
             TRB1->WK1GI_NUM:=EI2->EI2_PGI_NU
             TRB1->WK1_LOTE :=cLote
          ENDIF
          TRB1->WK1DESP     :=aTab[E,1]+'-'+LEFT(SFB->FB_DESCR,20)
       ENDIF
       IF nCpoVLR # 0
          TRB1->WK1VALCOM +=EI2->( FIELDGET(nCpoVLR) )
          nTotImpostos    +=EI2->( FIELDGET(nCpoVLR) )
       ENDIF
    NEXT
ENDIF

RETURN 
*=========================*
Static Function MontaTRBb()
*=========================*
LOCAL cLote
ProcRegua(nxNR_EI1)
DO While EI1->(EI1_FILIAL+EI1_HAWB)==xFilial("EI1")+SW6->W6_HAWB
	IncProc(STR0034) //"Montando o Arquivo de Trabalho 02/02..."
	SWW->(dBSeek(xFilial("SWW")+EI1->EI1_DOC))
	DO While SWW->(!Eof()).and.SWW->(WW_FILIAL+WW_NF_COMP)==xFilial("SWW")+EI1->EI1_DOC
		IF SWW->WW_TIPO_NF # CUSTO_REAL .OR.;
           SWW->WW_HAWB   # SW6->W6_HAWB
		   SWW->(DBSKIP())
		   LOOP
		ENDIF
			xxAux:=If(lxDespDet,SWW->WW_DESPESA,STR0035) //"XXX-OUTRAS DESPESAS"
			cLote:=SWW->WW_LOTECTL
			If TRB1->(!dBSeek("6"+Spac(Len(TRB1->(WK1PEDIDO+WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+Left(xxAux,3)))
               TRB1->(DBAPPEND())
				TRB1->WK1TIPO	:="6"
				TRB1->WK1DESP   :=xxAux
			EndIf
			TRB1->WK1VALCOM  :=	TRB1->WK1VALCOM + SWW->WW_VALOR
			If TRB1->(!dBSeek("7"+SWW->WW_PO_NUM+Space(Len(TRB1->(WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM)))+Left(xxAux,3)))
               TRB1->(DBAPPEND())
				TRB1->WK1TIPO   :="7"
				TRB1->WK1PEDIDO :=SWW->WW_PO_NUM
				TRB1->WK1DESP	:=xxAux
			EndIf
			TRB1->WK1VALCOM  :=	TRB1->WK1VALCOM + SWW->WW_VALOR
			SW3->(dBSetOrder(8))
			SW3->(dBSeek(xFilial("SW3")+SWW->(WW_PO_NUM+WW_NR_CONT)))
			SW3->(dBSetOrder(1))
			If TRB1->(!dBSeek("8"+SWW->WW_PO_NUM+SW3->(W3_CC+W3_COD_I)+SWW->WW_NR_CONT+cLote+SWW->WW_PGI_NUM+Left(xxAux,3)))
               TRB1->(DBAPPEND())
				TRB1->WK1TIPO   :="8"
				TRB1->WK1PEDIDO :=SWW->WW_PO_NUM
				TRB1->WK1CODIGO :=SW3->W3_CC
				TRB1->WK1ITEM 	:=SW3->W3_COD_I
				TRB1->WK1POSICA :=SWW->WW_NR_CONT
                TRB1->WK1_LOTE  :=cLote
				TRB1->WK1DESP	:=xxAux
				TRB1->WK1GI_NUM :=SWW->WW_PGI_NUM
			EndIf
			TRB1->WK1VALCOM  :=	TRB1->WK1VALCOM + SWW->WW_VALOR
		SWW->(dBSkip())
	EndDo
	EI1->(dBSkip())
EndDo
Return

*==========================*
Static FUNCTION ICus_CUSTO()
*==========================*
Local   axDespach	:={0,0,0}
Local	cxObserv	:=MSMM(SW6->W6_OBS,57)
Local	nxLoop		:=0
Private nxTotPrc	:=0.00

//
TRB1->(dBSeek("1TOT"+Space(Len(TRB1->WK1PEDIDO)-3)+"PRC"))
nxTotPrc	:=TRB1->WK1VALCOM  //--- Total do processo com IPI e ICMS
nxTcIPIICM	:=TRB1->WK1VALCOM  //--- Total do processo com IPI e ICMS
nxTsIPIICM	:=TRB1->WK1VALSEM  //--- Total do processo sem IPI e ICMS
//
ProcRegua(nxRotinas)
IncProc(STR0036) //"Imprimindo Cabeçalho do Custo..."
If nxPagina #0
	COMECA_PAGINA
Else
	nxLinha	:=0
	nxPagina:=nxPagina+1
	ICus_INICPG()
EndIf
TRACO_NORMAL
ICus_CABEC()
TRACO_NORMAL
nxLinha+=nxIncrem
TRACO_NORMAL
//
IncProc(STR0037) //"Imprimindo Despesas do Processo..."
ICus_DETDESP()
TRACO_NORMAL
If	lxCusPO		//--- Custo por P.O.
	IncProc(STR0038) //"Imprimindo Custo por PO..."
	nxLinha+=nxIncrem
	ICus_TitRel(STR0013) //"Custo por P.O."
	nxLinha+=nxIncrem
	TRACO_NORMAL
	ICus_CusPO()
	TRACO_NORMAL
EndIf	
If	lxCusIte		//--- Custo por Item
	IncProc(STR0039) //"Imprimindo Custo por Item..."
	nxLinha+=nxIncrem
	ICus_TitRel(STR0014) //"Custo por Item"
	nxLinha+=nxIncrem
	ICus_CusItem()
	TRACO_NORMAL
EndIf
If	lxResPO
	IncProc(STR0040) //"Imprimindo Detalhamento do PO..."
	nxLinha+=nxIncrem
	ICus_TitRel(STR0041) //"Detalhe de P.O."
	nxLinha+=nxIncrem
	ICus_DetPO()
	TRACO_NORMAL
EndIf
If	lxResCC
	IncProc(STR0042) //"Imprimindo Resumo por Centro de Custo..."
	nxLinha+=nxIncrem
	ICus_TitRel(STR0043) //"Resumo C.C."
	nxLinha+=nxIncrem
	ICus_Resumo("C")
	TRACO_NORMAL
EndIf
If	lxResDV
	IncProc(STR0044) //"Imprimindo Resumo por Divisão..."
	nxLinha+=nxIncrem
	ICus_TitRel(STR0045) //"Resumo Divisão"
	nxLinha+=nxIncrem
    ICus_Resumo("D")
	TRACO_NORMAL
EndIf
nxLinha+=nxIncrem
If	nxLinha > 3000
	ICus_IMPCAB(" ")
EndIf
IncProc(STR0046) //"Imprimindo Observações..."
TRACO_NORMAL
TRACO_VERT_01
oPrn:Say(nxLinha, 1150, STR0047, aFontes:ARIAL_10_BOLD,,,,2) //"Observações Gerais"
nxLinha+=nxIncrem
TRACO_NORMAL
TRACO_VERT_01
//
If	SWD->(dBSeek(xFilial("SWD")+SW6->W6_HAWB+"901"))
	axDespach[01]:=SWD->WD_VALOR_R
EndIf
If	SWD->(dBSeek(xFilial("SWD")+SW6->W6_HAWB+"902"))
	axDespach[02]:=SWD->WD_VALOR_R
EndIf
If	SWD->(dBSeek(xFilial("SWD")+SW6->W6_HAWB+"903"))
	axDespach[03]:=SWD->WD_VALOR_R
EndIf
//
oPrn:Say(nxLinha,230,STR0048+" "+EasyGParam("MV_SIMB1",,"R$"),             aFontes:ARIAL_08_BOLD) //"Adiantamento ao Despachante (R$)"
oPrn:Say(nxLinha,1200,Transf(axDespach[01],"@E 999,999,999,999.99"),aFontes:ARIAL_10_BOLD,,,,1)
nxLinha+=nxIncrem
If nxLinha > 3000
	TRACO_NORMAL
	ICus_IMPCAB("3")
EndIf
//
TRACO_VERT_01
oPrn:Say(nxLinha,230,STR0049+" "+EasyGParam("MV_SIMB1",,"R$"),             aFontes:ARIAL_08_BOLD) //"Complementos ao Despachante (R$)"
oPrn:Say(nxLinha,1200,Transf(axDespach[02],"@E 999,999,999,999.99"),aFontes:ARIAL_10_BOLD,,,,1)
nxLinha+=nxIncrem
If nxLinha > 3000
	TRACO_NORMAL
	ICus_IMPCAB("3")
EndIf
//
TRACO_VERT_01
oPrn:Say(nxLinha,230,STR0050+" "+EasyGParam("MV_SIMB1",,"R$"),               aFontes:ARIAL_08_BOLD) //"Devoluções do Despachante (R$)"
oPrn:Say(nxLinha,1200,Transf(axDespach[03],"@E 999,999,999,999.99"),aFontes:ARIAL_10_BOLD,,,,1)
nxLinha+=nxIncrem
If nxLinha > 3000
	TRACO_NORMAL
	ICus_IMPCAB("3")
EndIf
TRACO_VERT_01
oPrn:Say(nxLinha,230,STR0051+" "+EasyGParam("MV_SIMB1",,"R$"),               aFontes:ARIAL_08_BOLD) //"Valor trabalhado com o Despachante (R$)"
oPrn:Say(nxLinha,1200,Transf((axDespach[01]+axDespach[02]-axDespach[03]),"@E 999,999,999,999.99"),aFontes:ARIAL_10_BOLD,,,,1)
nxLinha+=nxIncrem
//
If !Empty(cxObserv)
	For nxLoop:=1 to MlCount(cxObserv,57)
		If !empty(MemoLine(cxObserv,57,nxLoop))
			If nxLinha > 3000
				TRACO_NORMAL
				ICus_IMPCAB("3")
			EndIf
			TRACO_VERT_01
			If mlCount(cxObserv,57)==nxLoop
				oPrn:Say(nxLinha,230,MemoLine(cxObserv,57,nxLoop),aFontes:ARIAL_10_BOLD)
			Else
				oPrn:Say(nxLinha,230,AV_Justifica(MemoLine(cxObserv,57,nxLoop)),aFontes:ARIAL_10_BOLD)
			EndIf
			nxLinha+=nxIncrem
		EndIf
	Next
EndIf
TRACO_NORMAL
Return

*===========================*
Static FUNCTION ICus_INICPG()
*===========================*
SX3->(dBSetOrder(2))
If SX3->(dBSeek("YT_LOGO"))
	If !Empty(SYT->YT_LOGO) //--- LOGOTIPO do Importador
		oPrn:SayBitmap(nxLinha,0100,AllTrim(SYT->YT_LOGO)+".BMP",0400,0300)
	EndIf
EndIf
SX3->(dBSetOrder(1))
oPrn:BOX(nxLinha,     1500,(nxLinha+160),2300)
oPrn:Say((nxLinha+70),1520,STR0052,aFontes:ARIAL_08) //"No.Processo"
oPrn:Say((nxLinha+70),1700,SW6->W6_HAWB            ,aFontes:ARIAL_13_BOLD)
nxLinha+=200
oPrn:Say(nxLinha,     1000,STR0006,aFontes:ARIAL_18_BOLD) //"Custo Realizado"
oPrn:Say(nxLinha+30,  1600,STR0053+DATA_MES(dDataBase)+Space(28)+; //"Emitido em "
										STR0054+StrZero(nxPagina,3),	aFontes:ARIAL_09_BOLD) //"Pag."
nxLinha+=100
Return

*==========================*
Static FUNCTION ICus_CABEC()
*==========================*
Local nxLoop	:=0, xxAux
Local cxInvoice	:=''
Local nxTotInv	:=0
Local cxCondPA	:=MSMM(SY6->Y6_DESC_P,48)
TRACO_VERT_01
nxLinha+=nxIncrem
TRACO_VERT_01
oPrn:Say(nxLinha, 055, STR0055,	aFontes:ARIAL_08) //"Importador"
oPrn:Say(nxLinha, 230, SYT->YT_NOME,	aFontes:ARIAL_08_BOLD)
oPrn:Say(nxLinha,1270, STR0056   ,	aFontes:ARIAL_08) //"Embarque"
oPrn:Say(nxLinha,1490, DATA_MES(SW6->W6_DT_EMB),aFontes:ARIAL_08_BOLD)
nxLinha+=nxIncrem
TRACO_VERT_01
oPrn:Say(nxLinha, 055, STR0057 ,	aFontes:ARIAL_08) //"Fornecedor"
oPrn:Say(nxLinha, 230, SA2->A2_NOME,	aFontes:ARIAL_08_BOLD)
/*oPrn:Say(nxLinha,1270, STR0058,	aFontes:ARIAL_08) //"Vcto.Câmbio"        RAD 30/10/2007
If SWB->(!Eof())
	oPrn:Say(nxLinha,1490, DATA_MES(dxVencto),aFontes:ARIAL_08_BOLD)
EndIf*/
nxLinha+=nxIncrem
TRACO_VERT_01
oPrn:Say(nxLinha, 055, STR0059,aFontes:ARIAL_08) //"Via Transp."
oPrn:Say(nxLinha, 230, Alltrim(SYQ->YQ_DESCR)+" from "+AllTrim(SYR->YR_CID_ORI)+;
		" to "+SY9->Y9_DESCR+"    ("+SYR->(YR_ORIGEM+" - "+YR_DESTINO)+")",aFontes:ARIAL_08_BOLD)
/* oPrn:Say(nxLinha,1270, STR0060,aFontes:ARIAL_08) //"Dt.Contrato"    RAD 30/10/2007
If SWB->(!Eof())
	oPrn:Say(nxLinha,1490, DATA_MES(dxContrat),aFontes:ARIAL_08_BOLD)
EndIf*/
nxLinha+=nxIncrem
TRACO_VERT_01
oPrn:Say(nxLinha, 055, STR0061      ,aFontes:ARIAL_08) //"Agente"
oPrn:Say(nxLinha, 230, SY4->Y4_NOME             ,aFontes:ARIAL_08_BOLD)
/*oPrn:Say(nxLinha,1270, STR0062,aFontes:ARIAL_08) //"Banco Câmbio"     RAD 30/10/2007
If SWB->(!Eof())
	oPrn:Say(nxLinha,1490, SA6->A6_NOME          ,aFontes:ARIAL_08_BOLD)
EndIf*/
nxLinha+=nxIncrem
TRACO_VERT_01
oPrn:Say(nxLinha,0055, STR0063,aFontes:ARIAL_08) //"Despachante"
oPrn:Say(nxLinha,0230, SY5->Y5_NOME            ,aFontes:ARIAL_08_BOLD)
/*oPrn:Say(nxLinha,1270, STR0064,aFontes:ARIAL_08) //"Dt.Liq.Câmbio"
oPrn:Say(nxLinha,1490, DATA_MES(dxLiquid)   ,aFontes:ARIAL_08_BOLD)	 RAD 30/10/2007 */
nxLinha+=nxIncrem
TRACO_VERT_01
//oPrn:Say(nxLinha, 055, STR0065+AllTrim(SW6->W6_INCOTER),												aFontes:ARIAL_08) //"Total "
//oPrn:Say(nxLinha, 230, "("+SW6->W6_FOBMOE+")  "+Transf(SW6->(W6_FOB_TOT+W6_PACKING+W6_INLAND-W6_DESCONTO),"@E 999,999,999,999.99"),			aFontes:ARIAL_08_BOLD)
//oPrn:Say(nxLinha,1270, STR0066,aFontes:ARIAL_08) //"Tx.Moeda"
//oPrn:Say(nxLinha,1490, "("+SW6->W6_FOBMOE+")  "+Transf(SW6->W6_TX_FOB,"@E 999,999.99999999")   ,aFontes:ARIAL_08_BOLD)
//nxLinha+=nxIncrem
//TRACO_VERT_01                       
IF !EMPTY(SW6->W6_VL_FRET)
   oPrn:Say(nxLinha, 055, STR0067,																		aFontes:ARIAL_08) //"Frete"
   oPrn:Say(nxLinha, 230, "("+SW6->W6_FREMOED+")  "+Transf(ValorFrete(SW6->W6_HAWB,,,2,),"@E 999,999,999,999.99"),	aFontes:ARIAL_08_BOLD)
   oPrn:Say(nxLinha,1270, STR0068,aFontes:ARIAL_08) //"Tx.Frete"
   oPrn:Say(nxLinha,1490, "("+SW6->W6_FREMOED+")  "+Transf(SW6->W6_TX_FRET,"@E 999,999.99999999")   ,aFontes:ARIAL_08_BOLD)
   nxLinha+=nxIncrem
   TRACO_VERT_01
ENDIF
IF !EMPTY(SW6->W6_VL_USSE)
   oPrn:Say(nxLinha, 055, STR0069,																	aFontes:ARIAL_08) //"Seguro"
   oPrn:Say(nxLinha, 230, "("+SW6->W6_SEGMOED+")  "+Transf(SW6->W6_VL_USSE,"@E 999,999,999,999.99"),	aFontes:ARIAL_08_BOLD)
   SX3->(dBSetOrder(2))
      oPrn:Say(nxLinha,1270, STR0070,																	aFontes:ARIAL_08) //"Tx.Seguro"
      oPrn:Say(nxLinha,1490, Transf(SW6->W6_TX_SEG,"@E 999,999.99999999"),aFontes:ARIAL_08_BOLD)
   SX3->(dBSetOrder(1))		
   nxLinha+=nxIncrem
   TRACO_VERT_01
EndIf
oPrn:Say(nxLinha, 055, STR0071,						aFontes:ARIAL_08) //"D.I."
oPrn:Say(nxLinha, 230, SW6->W6_DI_NUM,				aFontes:ARIAL_08_BOLD)
oPrn:Say(nxLinha,1270, STR0072,				aFontes:ARIAL_08) //"Tx.US$ D.I."
oPrn:Say(nxLinha,1490, Transf(SW6->W6_TX_US_D,"@E 999,999.99999999"),aFontes:ARIAL_08_BOLD)
nxLinha+=nxIncrem
TRACO_VERT_01
If !Empty(SW6->W6_NF_ENT)
	oPrn:Say(nxLinha, 055, STR0073,					aFontes:ARIAL_08) //"NFE/Série"
	oPrn:Say(nxLinha, 230, SW6->(W6_NF_ENT+"/"+W6_SE_NF),aFontes:ARIAL_08_BOLD)
	oPrn:Say(nxLinha,1270, STR0074,					aFontes:ARIAL_08) //"Dt.NFE"
	oPrn:Say(nxLinha,1490, DtoC(SW6->W6_DT_NF),aFontes:ARIAL_08_BOLD)
	nxLinha+=nxIncrem
	TRACO_VERT_01
EndIf	
oPrn:Say(nxLinha, 055, STR0075,aFontes:ARIAL_08) //"Cond.Pagto."
If !Empty(SW6->W6_DT_ENTR)
	oPrn:Say(nxLinha,1270, STR0076,		aFontes:ARIAL_08) //"Dt.Entrega"
	oPrn:Say(nxLinha,1490, DtoC(SW6->W6_DT_ENTR),aFontes:ARIAL_08_BOLD)
EndIf
For xxAux:=1 to MlCount(cxCondPA,48)
	If !empty(MemoLine(cxCondPA,48,xxAux))
		If xxAux>1
			TRACO_VERT_01
		EndIf
		If mlCount(cxCondPA,48)==xxAux
			oPrn:Say(nxLinha,230,MemoLine(cxCondPA,48,xxAux),aFontes:ARIAL_08_BOLD)
		Else
			oPrn:Say(nxLinha,230,AV_Justifica(MemoLine(cxCondPA,48,xxAux)),aFontes:ARIAL_08_BOLD)
		EndIf
		nxLinha+=nxIncrem
	EndIf
Next
//
TRACO_VERT_01
nxLinha+=nxIncrem
TRACO_VERT_01
SW9->(dBSetOrder(3))
SW9->(dBSeek(xFilial("SW9")+SW6->W6_HAWB))
While !SW9->(Eof()).and.SW9->W9_FILIAL+SW9->W9_HAWB==xFilial("SW9")+SW6->W6_HAWB
	cxInvoice+= If(!Empty(SW9->W9_INVOICE),AllTrim(SW9->W9_INVOICE)+", ",)
	nxTotInv += (SW9->W9_FOB_TOT + SW9->W9_OUTDESP + SW9->W9_PACKING + SW9->W9_INLAND - SW9->W9_DESCONTO)
	SW9->(dBSkip())
EndDo
oPrn:Say(nxLinha, 055,STR0077,aFontes:ARIAL_08) //"No.Invoices"
For nxLoop:=1 To MlCount(Memoline(cxInvoice,40))
	If !Empty(Memoline(cxInvoice,40,nxLoop))
		oPrn:Say(nxLinha, 230, Memoline(cxInvoice,40,nxLoop),aFontes:ARIAL_08_BOLD)
		nxLinha+=nxIncrem
		TRACO_VERT_01
	EndIf
Next
nxLinha-=nxIncrem
oPrn:Say(nxLinha,1270, STR0078,aFontes:ARIAL_08_BOLD) //"Total das Invoices"
oPrn:Say(nxLinha,1530, SW6->W6_FOBMOE+" "+Transf(nxTotInv,"@E 999,999,999.99"),aFontes:ARIAL_08_BOLD)
nxLinha+=nxIncrem
//TRACO_VERT_01
Return

*============================*
Static FUNCTION ICus_DETDESP()
*============================*
Local nxFOB:=0
If nxLinha >= 3000+nxIncrem
   COMECA_PAGINA
ENDIF
TRACO_NORMAL
TRACO_VERT_01
//oPrn:Say(nxLinha,2140, STR0079, aFontes:ARIAL_08_BOLD,,,,1) //"% s/ IPI"
//oPrn:Say(nxLinha,2290, STR0080, aFontes:ARIAL_08_BOLD,,,,1) //"% c/ IPI"
//nxLinha+=nxIncrem
//TRACO_VERT_01
oPrn:Say(nxLinha, 300, STR0081,    aFontes:ARIAL_10_BOLD) //"Despesas"
oPrn:Say(nxLinha,1530, STR0082+" "+EasyGParam("MV_SIMB1",,"R$"), aFontes:ARIAL_08_BOLD,,,,1) //"Valor em"
oPrn:Say(nxLinha,1790, STR0083,aFontes:ARIAL_08_BOLD,,,,1) //"Valor em US$"
oPrn:Say(nxLinha,1990, STR0084,       aFontes:ARIAL_08_BOLD,,,,1) //"% FOB"
//oPrn:Say(nxLinha,2140, STR0085,        aFontes:ARIAL_08_BOLD,,,,1) //"ICMS"
//oPrn:Say(nxLinha,2290, STR0085,        aFontes:ARIAL_08_BOLD,,,,1) //"ICMS"
nxLinha+=nxIncrem
TRACO_NORMAL
TRB1->(dBSeek("6"))
DO While TRB1->(!Eof()).and.TRB1->WK1TIPO=="6"
	If nxLinha >= 3000
       TRACO_NORMAL
		ICus_IMPCAB("5")
	EndIf
	TRACO_VERT_01
	oPrn:Say(nxLinha,  55, TRB1->(If(Left(WK1DESP,3)$"104.204",Subs(WK1DESP,5),WK1DESP)),   If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_10_BOLD,aFontes:ARIAL_10))
	oPrn:Say(nxLinha,1530, Transf(TRB1->WK1VALCOM,"@E 999,999,999.99"),                    If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	oPrn:Say(nxLinha,1790, Transf((TRB1->WK1VALCOM/SW6->W6_TX_US_D),"@E 999,999,999.99"),  If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	If Left(TRB1->WK1DESP,3)=="101"
		oPrn:Say(nxLinha,1990, STR0086,														aFontes:ARIAL_10_BOLD,,,,1) //"BASE"
		nxFOB:=TRB1->WK1VALCOM
	Else
		oPrn:Say(nxLinha,1990, Transf(((TRB1->WK1VALCOM/nxFOB)*100),"@E 999.999"),			If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	EndIf
//      If Left(TRB1->WK1DESP,3)$"202.203.204"
//         oPrn:Say(nxLinha,2140, "- * -",                                                     If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
//      Else
//         oPrn:Say(nxLinha,2140, Transf(((TRB1->WK1VALCOM/nxTsIPIICM)*100),"@E 999.999"),    If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)//s/ ICMS
//      EndIf
//      oPrn:Say(nxLinha,2290, Transf(((TRB1->WK1VALCOM/nxTcIPIICM)*100),"@E 999.999"),        If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)//c/ICMS
	nxLinha+=nxIncrem
	If Left(TRB1->WK1DESP,3)$"104.204"
		TRACO_NORMAL
	EndIf
	TRB1->(dBSkip())
EndDo
//TRACO_NORMAL
//TRACO_VERT_01
//oPrn:Say(nxLinha,  55, STR0087,aFontes:ARIAL_10_BOLD) //"Total Geral sem IPI/ICMS"
//oPrn:Say(nxLinha,1530, Transf(nxTsIPIICM,"@E 999,999,999.99"),                          aFontes:ARIAL_08_BOLD,,,,1)
//oPrn:Say(nxLinha,1790, Transf((nxTsIPIICM/SW6->W6_TX_US_D),"@E 999,999,999.99"),        aFontes:ARIAL_08_BOLD,,,,1)
//oPrn:Say(nxLinha,1990, Transf(((nxTsIPIICM/nxFOB)*100),"@E 999.999"),                           aFontes:ARIAL_08_BOLD,,,,1)
//oPrn:Say(nxLinha,2140, Transf(((nxTsIPIICM/nxTsIPIICM)*100),"@E 999.999"),              aFontes:ARIAL_08_BOLD,,,,1)
//oPrn:Say(nxLinha,2290, Transf(((nxTsIPIICM/nxTcIPIICM)*100),"@E 999.999"),              aFontes:ARIAL_08_BOLD,,,,1)
//nxLinha+=nxIncrem
//TRACO_VERT_01
//oPrn:Say(nxLinha,  55, STR0088,aFontes:ARIAL_10_BOLD) //"Total Geral com IPI/ICMS"
//oPrn:Say(nxLinha,1530, Transf(nxTcIPIICM,"@E 999,999,999.99"),                          aFontes:ARIAL_08_BOLD,,,,1)
//oPrn:Say(nxLinha,1790, Transf((nxTcIPIICM/SW6->W6_TX_US_D),"@E 999,999,999.99"),        aFontes:ARIAL_08_BOLD,,,,1)
//oPrn:Say(nxLinha,1990, Transf(((nxTcIPIICM/nxFOB)*100),"@E 999.999"),                           aFontes:ARIAL_08_BOLD,,,,1)
//oPrn:Say(nxLinha,2290, Transf(((nxTcIPIICM/nxTcIPIICM)*100),"@E 999.999"),              aFontes:ARIAL_08_BOLD,,,,1)
//nxLinha+=nxIncrem
Return

*==========================*
Static FUNCTION ICus_DetPO()
*==========================*
Local cxPedAnt	:=Spac(Len(TRB1->WK1PEDIDO))
Local cxCCAnt	:=Spac(05)
Local nxTotPed	:=0.00
Local nxTotCC	:=0.00
If nxLinha >= 3000
   COMECA_PAGINA
EndIf
ICus_IMPCAB("4")
//
TRB1->(dBSeek("9"))
DO While TRB1->(!Eof()).and.TRB1->WK1TIPO=="9"
	If nxLinha >= 3000-nxIncrem
       TRACO_NORMAL
		COMECA_PAGINA
		ICus_IMPCAB("4")
	EndIf
	lImprimiu:=.F.
	If !Empty(cxCCAnt).and.cxCCAnt #TRB1->WK1CODIGO .and. nxTotCC > 0
        lImprimiu:=.T.
		TRACO_REDU_02
		TRACO_VERT_01
		oPrn:Say(nxLinha,1270, STR0089+AllTrim(cxCCAnt), aFontes:ARIAL_10_BOLD,,,,1) //"Total do C.Custo - "
		oPrn:Say(nxLinha,1530, Transf(nxTotCC,"@E 999,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,1790, Transf((nxTotCC/SW6->W6_TX_US_D),"@E 99,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,2290, Transf(((nxTotCC/nxTotPrc)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,1990, Transf(((nxTotCC/nxTotCC)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,2140, Transf(((nxTotCC/nxTotPed)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,2290, Transf(((nxTotCC/nxTotPrc)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		nxLinha+=nxIncrem
		cxCCAnt:=TRB1->WK1CODIGO
		//
		xxAux:=TRB1->(RecNo())
		TRB1->(dBSeek("2"+TRB1->(WK1PEDIDO+WK1CODIGO)))
		nxTotCC:=TRB1->WK1VALCOM  //--- Total do Centro de Custo com IPI e ICMS
		TRB1->(dBGoTo(xxAux))
		//
	EndIf
	If Empty(cxPedAnt).or.cxPedAnt #TRB1->WK1PEDIDO
		If !Empty(cxPedAnt)
			If nxTotCC > 0 .AND. !lImprimiu
				TRACO_REDU_02
				TRACO_VERT_01
				oPrn:Say(nxLinha,1270, STR0089+AllTrim(cxCCAnt), aFontes:ARIAL_10_BOLD,,,,1) //"Total do C.Custo - "
				oPrn:Say(nxLinha,1530, Transf(nxTotCC,"@E 999,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
				oPrn:Say(nxLinha,1790, Transf((nxTotCC/SW6->W6_TX_US_D),"@E 99,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
				oPrn:Say(nxLinha,2290, Transf(((nxTotCC/nxTotPrc)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
				oPrn:Say(nxLinha,1990, Transf(((nxTotCC/nxTotCC)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
				oPrn:Say(nxLinha,2140, Transf(((nxTotCC/nxTotPed)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
				oPrn:Say(nxLinha,2290, Transf(((nxTotCC/nxTotPrc)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
				nxLinha+=nxIncrem
			EndIf
			TRACO_REDU_02
			TRACO_VERT_01
			oPrn:Say(nxLinha,1270, STR0090+AllTrim(cxPedAnt), aFontes:ARIAL_10_BOLD,,,,1) //"Total do Pedido - "
			oPrn:Say(nxLinha,1530, Transf(nxTotPed,"@E 999,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			oPrn:Say(nxLinha,1790, Transf((nxTotPed/SW6->W6_TX_US_D),"@E 99,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			oPrn:Say(nxLinha,2140, Transf(((nxTotPed/nxTotPed)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			oPrn:Say(nxLinha,2290, Transf(((nxTotPed/nxTotPrc)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			nxLinha+=nxIncrem
		EndIf
		//
		TRACO_NORMAL
		TRACO_VERT_01
		TRACO_VERT_02
		TRACO_REDU_01
		SW2->(dBSeek(xFilial("SW2")+TRB1->WK1PEDIDO))
		oPrn:Say(nxLinha,0055, STR0091+TRB1->WK1PEDIDO, aFontes:ARIAL_10_BOLD,,,,) //"Pedido   "
		oPrn:Say(nxLinha,0945, STR0092+DtoC(SW2->W2_PO_DT), 	aFontes:ARIAL_10_BOLD,,,,1) //"Dt."
		nxLinha+=nxIncrem
		//
		xxAux:=TRB1->(RecNo())
		TRB1->(dBSeek("2"+TRB1->(WK1PEDIDO+WK1CODIGO)))
		nxTotCC:=TRB1->WK1VALCOM  //--- Total do Centro de Custo com IPI e ICMS
		//
		TRB1->(dBSeek("3"+TRB1->WK1PEDIDO+"PED"))
		nxTotPed:=TRB1->WK1VALCOM  //--- Total do Pedido com IPI e ICMS
		TRB1->(dBGoTo(xxAux))
		//
		cxPedAnt:=TRB1->WK1PEDIDO
		cxCCAnt :=TRB1->WK1CODIGO
	EndIf
	TRACO_VERT_01
	oPrn:Say(nxLinha,0055, TRB1->WK1CODIGO,						aFontes:ARIAL_08,,,,)
	If lxExistDV
		SY3->(dBSeek(xFilial("SY3")+TRB1->WK1CODIGO))
		oPrn:Say(nxLinha,0325, SY3->Y3_DIVIS,					aFontes:ARIAL_08,,,,)
	EndIf
	oPrn:Say(nxLinha,0595,TRB1->WK1ITEM,											aFontes:ARIAL_08,,,,)
	oPrn:Say(nxLinha,1000,TRB1->WK1UN,												aFontes:ARIAL_08,,,,1)
	oPrn:Say(nxLinha,1270,Transf(TRB1->WK1QTDE,"@E 99,999,999.999"),				aFontes:ARIAL_08,,,,1)
	oPrn:Say(nxLinha,1530,Transf(TRB1->WK1VALCOM,"@E 999,999,999.99"),				aFontes:ARIAL_08,,,,1)
	oPrn:Say(nxLinha,1790,Transf((TRB1->WK1VALCOM/SW6->W6_TX_US_D),"@E 99,999,999.99"), aFontes:ARIAL_08,,,,1)
	oPrn:Say(nxLinha,1990,Transf(((TRB1->WK1VALCOM/nxTotCC)*100),"@E 999.99"), 	aFontes:ARIAL_08,,,,1)
	oPrn:Say(nxLinha,2140,Transf(((TRB1->WK1VALCOM/nxTotPed)*100),"@E 999.99"),	aFontes:ARIAL_08,,,,1)
	oPrn:Say(nxLinha,2290,Transf(((TRB1->WK1VALCOM/nxTotPrc)*100),"@E 999.99"),	aFontes:ARIAL_08,,,,1)
	nxLinha+=nxIncrem
	TRB1->(dBSkip())
EndDo
If nxTotPed #0
	If !Empty(cxPedAnt)
		If nxTotCC > 0
			TRACO_REDU_02
			TRACO_VERT_01
			oPrn:Say(nxLinha,1270, STR0089+AllTrim(cxCCAnt),        aFontes:ARIAL_10_BOLD,,,,1) //"Total do C.Custo - "
			oPrn:Say(nxLinha,1530, Transf(nxTotCC,"@E 999,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			oPrn:Say(nxLinha,1790, Transf((nxTotCC/SW6->W6_TX_US_D),"@E 99,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			oPrn:Say(nxLinha,1990, Transf(((nxTotCC/nxTotCC)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			oPrn:Say(nxLinha,2140, Transf(((nxTotCC/nxTotPed)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			oPrn:Say(nxLinha,2290, Transf(((nxTotCC/nxTotPrc)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
			nxLinha+=nxIncrem
		EndIf
		TRACO_REDU_02
		TRACO_VERT_01
		oPrn:Say(nxLinha,1270, STR0090+AllTrim(cxPedAnt), aFontes:ARIAL_10_BOLD,,,,1) //"Total do Pedido - "
		oPrn:Say(nxLinha,1530, Transf(nxTotPed,"@E 999,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,1790, Transf((nxTotPed/SW6->W6_TX_US_D),"@E 99,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,2140, Transf(((nxTotPed/nxTotPed)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,2290, Transf(((nxTotPed/nxTotPrc)*100),"@E 999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		nxLinha+=nxIncrem
		TRACO_REDU_02
		TRACO_VERT_01
		oPrn:Say(nxLinha,1270, STR0093+AllTrim(SW6->W6_HAWB),    aFontes:ARIAL_10_BOLD,,,,1) //"Total do Processo - "
		oPrn:Say(nxLinha,1530, Transf(nxTotPrc,"@E 999,999,999.99"),                  aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,1790, Transf((nxTotPrc/SW6->W6_TX_US_D),"@E 99,999,999.99"), aFontes:ARIAL_10_BOLD,,,,1)
		oPrn:Say(nxLinha,2290, Transf(((nxTotPrc/nxTotPrc)*100),"@E 999.99"),       aFontes:ARIAL_10_BOLD,,,,1)
		nxLinha+=nxIncrem
	EndIf
EndIf
Return

*==================================*
Static FUNCTION ICus_Resumo(cxTpRes)
*==================================*
If nxLinha > 3000-nxIncrem
   COMECA_PAGINA
EndIf
TRACO_NORMAL
TRACO_VERT_01
oPrn:Say(nxLinha, 300, If(cxTpRes=="C",STR0094,STR0095),		  aFontes:ARIAL_10_BOLD) //"Centros de Custo"###"Divisão"
oPrn:Say(nxLinha,1530, STR0082+" "+EasyGParam("MV_SIMB1",,"R$"),      aFontes:ARIAL_08_BOLD,,,,1) //"Valor em R$"
oPrn:Say(nxLinha,1790, STR0083,     aFontes:ARIAL_08_BOLD,,,,1) //"Valor em US$"
oPrn:Say(nxLinha,2290, STR0096,            aFontes:ARIAL_08_BOLD,,,,1) //"%Proc"
nxLinha+=nxIncrem
TRACO_NORMAL
TRB1->(dBSeek(If(cxTpRes=="C","4","5")))
DO While TRB1->(!Eof()).and.TRB1->WK1TIPO==If(cxTpRes=="C","4","5")
	If nxLinha > 3000
		ICus_IMPCAB(If(cxTpRes=="C","1","2"))
	EndIf
	TRACO_VERT_01
	oPrn:Say(nxLinha,  55, TRB1->WK1CODIGO,													aFontes:ARIAL_10)
	oPrn:Say(nxLinha,1530, Transf(TRB1->WK1VALCOM,"@E 999,999,999.99"),					aFontes:ARIAL_08,,,,1)
	oPrn:Say(nxLinha,1790, Transf((TRB1->WK1VALCOM/SW6->W6_TX_US_D),"@E 999,999,999.99"),	aFontes:ARIAL_08,,,,1)
	oPrn:Say(nxLinha,2290, Transf(((TRB1->WK1VALCOM/nxTotPrc)*100),"@E 999.999"),			aFontes:ARIAL_08,,,,1)
	nxLinha   :=nxLinha+nxIncrem
	TRB1->(dBSkip())
EndDo
TRACO_REDU_02
TRACO_VERT_01
oPrn:Say(nxLinha,1270, STR0093+AllTrim(SW6->W6_HAWB),	aFontes:ARIAL_10_BOLD,,,,1) //"Total do Processo - "
oPrn:Say(nxLinha,1530, Transf(nxTotPrc,"@E 999,999,999.99"),					aFontes:ARIAL_10_BOLD,,,,1)
oPrn:Say(nxLinha,1790, Transf((nxTotPrc/SW6->W6_TX_US_D),"@E 99,999,999.99"),	aFontes:ARIAL_10_BOLD,,,,1)
oPrn:Say(nxLinha,2290, Transf(((nxTotPrc/nxTotPrc)*100),"@E 999.99"),			aFontes:ARIAL_10_BOLD,,,,1)
nxLinha+=nxIncrem
Return

*==========================*
Static FUNCTION ICus_CusPO()
*==========================*
Local cxPedAnt	:=Spac(Len(TRB1->WK1PEDIDO))
Local nxCTotPed	:=0.00
Local nxSTotPed	:=0.00
Local nxFOB		:=0.00
Local cWK1PEDIDO
//
If nxLinha >= 3000-nxIncrem-nxIncrem
   COMECA_PAGINA
EndIf
TRACO_NORMAL
TRACO_VERT_01
oPrn:Say(nxLinha, 300, STR0081,    aFontes:ARIAL_10_BOLD) //"Despesas"
oPrn:Say(nxLinha,1530, STR0082+" "+EasyGParam("MV_SIMB1",,"R$"), aFontes:ARIAL_08_BOLD,,,,1) //"Valor em"
oPrn:Say(nxLinha,1790, STR0083,aFontes:ARIAL_08_BOLD,,,,1) //"Valor em US$"
oPrn:Say(nxLinha,1990, STR0084,       aFontes:ARIAL_08_BOLD,,,,1) //"% FOB"
nxLinha+=nxIncrem
TRACO_NORMAL
TRB1->(dBSeek("7"))
DO While TRB1->(!Eof()).and.TRB1->WK1TIPO=="7"
	If nxLinha >= 3000-nxIncrem
       TRACO_NORMAL
		ICus_IMPCAB("5")
	EndIf
	If Empty(cxPedAnt).or.cxPedAnt #TRB1->WK1PEDIDO
		TRACO_NORMAL
		TRACO_VERT_01
		TRACO_VERT_02
		TRACO_REDU_01
		SW2->(dBSeek(xFilial("SW2")+TRB1->WK1PEDIDO))
		oPrn:Say(nxLinha,0055, STR0091+TRB1->WK1PEDIDO, aFontes:ARIAL_10_BOLD,,,,) //"Pedido   "
		oPrn:Say(nxLinha,0945, STR0092+DtoC(SW2->W2_PO_DT), 	aFontes:ARIAL_10_BOLD,,,,1) //"Dt."
		nxLinha+=nxIncrem
		xxAux:=TRB1->(RecNo())
      cWK1PEDIDO:=TRB1->WK1PEDIDO
		TRB1->(dBSeek("3"+cWK1PEDIDO+"PED"))
		nxCTotPed:=TRB1->WK1VALCOM  //--- Total do Pedido com IPI e ICMS
		nxSTotPed:=TRB1->WK1VALSEM  //--- Total do Pedido sem IPI e ICMS
		TRB1->(dBGoTo(xxAux))
		cxPedAnt:=TRB1->WK1PEDIDO
	EndIf
	TRACO_VERT_01
	oPrn:Say(nxLinha,  55, TRB1->(If(Left(WK1DESP,3)$"104.204",Subs(WK1DESP,5),WK1DESP)),   If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_10_BOLD,aFontes:ARIAL_10))
	oPrn:Say(nxLinha,1530,Transf(TRB1->WK1VALCOM,"@E 999,999,999.99"),						If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	oPrn:Say(nxLinha,1790,Transf((TRB1->WK1VALCOM/SW6->W6_TX_US_D),"@E 99,999,999.99"), 	If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	If Left(TRB1->WK1DESP,3)=="101"
		oPrn:Say(nxLinha,1990, STR0086,														aFontes:ARIAL_10_BOLD,,,,1) //"BASE"
		nxFOB:=TRB1->WK1VALCOM
	Else
		oPrn:Say(nxLinha,1990, Transf(((TRB1->WK1VALCOM/nxFOB)*100),"@E 999.999"),			If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	EndIf
	nxLinha+=nxIncrem
	TRB1->(dBSkip())
EndDo

Return

*============================*
Static FUNCTION ICus_CusItem()
*============================*
Local cxPedAnt	:=Spac(Len(TRB1->WK1PEDIDO))
Local cxPosAnt	:=Spac(Len(TRB1->WK1POSICA))
Local cxLotAnt  :=Spac(Len(TRB1->WK1_LOTE ))
LOCAL cxPgiAnt  :=Spac(Len(TRB1->WK1GI_NUM))
Local nxQtdIte	:=0
Local nxCTotIte	:=0.00
Local nxSTotIte	:=0.00
Local nxFOB		:=0.00
Local cxDesc	:=''
//
If nxLinha >= 3000-nxIncrem-nxIncrem
   COMECA_PAGINA
EndIf
TRACO_NORMAL
TRACO_VERT_01
oPrn:Say(nxLinha, 300, STR0081,    aFontes:ARIAL_10_BOLD) //"Despesas"
oPrn:Say(nxLinha,1010, STR0100+" "+EasyGParam("MV_SIMB1",,"R$"), aFontes:ARIAL_08_BOLD,,,,1) //"Val.Unit."
oPrn:Say(nxLinha,1270, STR0101,aFontes:ARIAL_08_BOLD,,,,1) //"Val.Unit.US$"
oPrn:Say(nxLinha,1530, STR0102+" "+EasyGParam("MV_SIMB1",,"R$"), aFontes:ARIAL_08_BOLD,,,,1) //"Val.Tot."
oPrn:Say(nxLinha,1790, STR0103,aFontes:ARIAL_08_BOLD,,,,1) //"Val.Tot. US$"
oPrn:Say(nxLinha,1990, STR0084,       aFontes:ARIAL_08_BOLD,,,,1) //"% FOB"
nxLinha+=nxIncrem
TRACO_NORMAL
TRB1->(dBSeek("8"))
DO While TRB1->(!Eof()).and.TRB1->WK1TIPO=="8"
	If nxLinha >= 3000-nxIncrem
		TRACO_NORMAL
		ICus_IMPCAB("6")
	EndIf
	If 	Empty(cxPedAnt) .or. Empty(cxPosAnt) .or.;
		cxPedAnt#TRB1->WK1PEDIDO .or. cxPosAnt#TRB1->WK1POSICA.or.;
		cxLotAnt#TRB1->WK1_LOTE  .OR. cxPgiAnt # TRB1->WK1GI_NUM
		/*If !Empty(cxPedAnt).And.!Empty(cxPosAnt)
			TRACO_REDU_03
			TRACO_VERT_01
			oPrn:Say(nxLinha,0750, STR0104,											aFontes:ARIAL_10_BOLD,,,,1) //"Tot.Item s/ IPI/ICMS - "
			oPrn:Say(nxLinha,1010, Transf((nxSTotIte/nxQtdIte),"@E 999,999,999.9999"), 				aFontes:ARIAL_08_BOLD,,,,1)
			oPrn:Say(nxLinha,1270, Transf(((nxSTotIte/nxQtdIte)/SW6->W6_TX_US_D),"@E 999,999,999.9999"),aFontes:ARIAL_08_BOLD,,,,1)
			oPrn:Say(nxLinha,1530, Transf(nxSTotIte,"@E 999,999,999.99"), 								aFontes:ARIAL_08_BOLD,,,,1)
			oPrn:Say(nxLinha,1790, Transf((nxSTotIte/SW6->W6_TX_US_D),"@E 99,999,999.99"), 			aFontes:ARIAL_08_BOLD,,,,1)
			oPrn:Say(nxLinha,1990, Transf(((nxSTotIte/nxFOB)*100),"@E 999.999"),						aFontes:ARIAL_08_BOLD,,,,1)
//          oPrn:Say(nxLinha,2140, Transf(((nxSTotIte/nxSTotIte)*100),"@E 999.999"),                                        aFontes:ARIAL_08_BOLD,,,,1)
//           oPrn:Say(nxLinha,2290, Transf(((nxSTotIte/nxCTotIte)*100),"@E 999.999"),                                        aFontes:ARIAL_08_BOLD,,,,1)
//                      nxLinha+=nxIncrem
//                      TRACO_VERT_01
//                      oPrn:Say(nxLinha,0750, STR0105,                                                                                 aFontes:ARIAL_10_BOLD,,,,1) //"Tot.Item c/ IPI/ICMS - "
//                      oPrn:Say(nxLinha,1010, Transf((nxCTotIte/nxQtdIte),"@E 999,999,999.9999"),                              aFontes:ARIAL_08_BOLD,,,,1)
//                      oPrn:Say(nxLinha,1270, Transf(((nxCTotIte/nxQtdIte)/SW6->W6_TX_US_D),"@E 999,999,999.9999"),aFontes:ARIAL_08_BOLD,,,,1)
//                      oPrn:Say(nxLinha,1530, Transf(nxCTotIte,"@E 999,999,999.99"),                                                           aFontes:ARIAL_08_BOLD,,,,1)
//                      oPrn:Say(nxLinha,1790, Transf((nxCTotIte/SW6->W6_TX_US_D),"@E 99,999,999.99"),                  aFontes:ARIAL_08_BOLD,,,,1)
//                      oPrn:Say(nxLinha,1990, Transf(((nxCTotIte/nxFOB)*100),"@E 999.999"),                                            aFontes:ARIAL_08_BOLD,,,,1)
//                      oPrn:Say(nxLinha,2290, Transf(((nxCTotIte/nxCTotIte)*100),"@E 999.999"),                                aFontes:ARIAL_08_BOLD,,,,1)
			nxLinha+=nxIncrem
      EndIf*/
		//
        If nxLinha >= 3000-nxIncrem-nxIncrem
		   TRACO_NORMAL
			ICus_IMPCAB("6")
		EndIf
		TRACO_NORMAL
		TRACO_VERT_01
		TRACO_VERT_02
		TRACO_REDU_01
		SW2->(dBSeek(xFilial("SW2")+TRB1->WK1PEDIDO))
		SB1->(dBSeek(xFilial("SB1")+TRB1->WK1ITEM))
		cxDesc:=MSMM(SB1->B1_DESC_P,36)
		cxDesc:=StrTRAN(cxDesc,CHR(13)+CHR(10)," ")
		oPrn:Say(nxLinha,0055, STR0091+TRB1->WK1PEDIDO, aFontes:ARIAL_10_BOLD,,,,) //"Pedido   "
		oPrn:Say(nxLinha,0945, STR0092+DtoC(SW2->W2_PO_DT), 	aFontes:ARIAL_10_BOLD,,,,1) //"Dt."
		//
		xxAux:=TRB1->(RecNo())
		TRB1->(dBSeek("9"+WK1PEDIDO+WK1CODIGO+WK1ITEM+WK1POSICA+WK1_LOTE+WK1GI_NUM))
		SA2->(dBSeek(xFilial("SA2")+TRB1->WK1FABR))
		nxCTotIte:=TRB1->WK1VALCOM  //--- Total do Pedido com IPI e ICMS
		nxSTotIte:=TRB1->WK1VALSEM  //--- Total do Pedido sem IPI e ICMS
		nxQtdIte :=TRB1->WK1QTDE    //--- Quantidade
      
		oPrn:Say(nxLinha,1000, STR0106,aFontes:ARIAL_08,,,,) //"Prod.: "
		oPrn:Say(nxLinha,1090, TRB1->WK1ITEM,aFontes:ARIAL_10_BOLD,,,,)
		oPrn:Say(nxLinha,1490, MemoLine(cxDesc,40,1),COURIER_09)
		nxLinha+=nxIncrem
		If !Empty(MemoLine(cxDesc,40,2))
			TRACO_VERT_01
			oPrn:Say(nxLinha,1490, MemoLine(cxDesc,40,2),COURIER_09)
			nxLinha+=nxIncrem
		EndIf
		IF lLote .AND. !EMPTY(TRB1->WK1_LOTE)
		TRACO_VERT_01
           oPrn:Say(nxLinha,1000, AVSX3("WN_LOTECTL",5)+".:",aFontes:ARIAL_08,,,,)
           oPrn:Say(nxLinha,1200, TRB1->WK1_LOTE            ,aFontes:ARIAL_08_BOLD,,,,)
           oPrn:Say(nxLinha,1530, AVSX3("WN_DTVALID",5)+".:",aFontes:ARIAL_08,,,,)
           oPrn:Say(nxLinha,2000, DTOC(TRB1->WK1_DTVAL)     ,aFontes:ARIAL_08_BOLD,,,,)
           nxLinha+=nxIncrem
        endif
		TRACO_VERT_01
		oPrn:Say(nxLinha,1000, STR0107, 						aFontes:ARIAL_08,,,,) //"Fabr.: "
		oPrn:Say(nxLinha,1100, TRB1->WK1FABR+" - "+SA2->A2_NOME,aFontes:ARIAL_08_BOLD,,,,)
		nxLinha+=nxIncrem
		TRACO_VERT_01
		oPrn:Say(nxLinha,1000, STR0108, 						aFontes:ARIAL_08,,,,) //"Qtde.: "
		oPrn:Say(nxLinha,1100, Transf(nxQtdIte,"@E 99,999,999.999")+" "+TRB1->WK1UN, 	aFontes:ARIAL_08_BOLD,,,,)
		oPrn:Say(nxLinha,1530, STR0109,			aFontes:ARIAL_08,,,,) //"NCM/Ex-NCM/Ex-NBM:"
		oPrn:Say(nxLinha,2000, TRB1->(AllTrim(WK1POSIPI)+"/"+WK1EX_NCM+"/"+WK1EX_NBM), 	aFontes:ARIAL_08_BOLD,,,,)
		nxLinha+=nxIncrem
		TRACO_VERT_01
		oPrn:Say(nxLinha,1095, STR0110,						aFontes:ARIAL_08,,,,1) //"Peso Líq Unit.: "
		oPrn:Say(nxLinha,1100, Transf((TRB1->WK1PESO/nxQtdIte),cPictPeso),	aFontes:ARIAL_08_BOLD,,,,)
		oPrn:Say(nxLinha,1530, STR0111,								aFontes:ARIAL_08,,,,) //"Total:"
        oPrn:Say(nxLinha,2000, Transf(TRB1->WK1PESO,cPictPeso),	aFontes:ARIAL_08_BOLD,,,,)
		nxLinha+=nxIncrem
		If Left(TRB1->WK1GI_NUM,1)#"*"
			TRACO_VERT_01
//			oPrn:Say(nxLinha,1000, STR0112, 					aFontes:ARIAL_08,,,,) //"L.I..: "               RAD 30/10/2007
//			oPrn:Say(nxLinha,1100, TRB1->WK1GI_NUM,				aFontes:ARIAL_08_BOLD,,,,)      RAD 30/10/2007
			nxLinha+=nxIncrem
		EndIf
		TRACO_NORMAL
		TRB1->(dBGoTo(xxAux))
		cxPedAnt:=TRB1->WK1PEDIDO
		cxPosAnt:=TRB1->WK1POSICA
		cxLotAnt:=TRB1->WK1_LOTE            
		cxPgiAnt:=TRB1->WK1GI_NUM
	EndIf
	If nxLinha >= 3000-nxIncrem
		TRACO_NORMAL
		ICus_IMPCAB("6")
	EndIf
	TRACO_VERT_01
	oPrn:Say(nxLinha,  55,TRB1->(If(Left(WK1DESP,3)$"104.204",Subs(WK1DESP,5),WK1DESP)),	If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_10_BOLD,aFontes:ARIAL_10))
	oPrn:Say(nxLinha,1010,Transf((TRB1->WK1VALCOM/nxQtdIte),"@E 999,999,999.9999"), 					If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	oPrn:Say(nxLinha,1270,Transf(((TRB1->WK1VALCOM/nxQtdIte)/SW6->W6_TX_US_D),"@E 999,999,999.9999"),	If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	oPrn:Say(nxLinha,1530,Transf(TRB1->WK1VALCOM,"@E 999,999,999.99"),						If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	oPrn:Say(nxLinha,1790,Transf((TRB1->WK1VALCOM/SW6->W6_TX_US_D),"@E 99,999,999.99"), 	If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	If Left(TRB1->WK1DESP,3)=="101"
		oPrn:Say(nxLinha,1990, STR0086,														aFontes:ARIAL_10_BOLD,,,,1) //"BASE"
		nxFOB:=TRB1->WK1VALCOM
	Else
		oPrn:Say(nxLinha,1990, Transf(((TRB1->WK1VALCOM/nxFOB)*100),"@E 999.999"),			If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
      EndIf
//      If Left(TRB1->WK1DESP,3)$"202.203.204"
//              oPrn:Say(nxLinha,2140, "- * -",                                                     If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
//      Else
//              oPrn:Say(nxLinha,2140, Transf(((TRB1->WK1VALCOM/nxSTotIte)*100),"@E 999.999"),          If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
//      EndIf
//      oPrn:Say(nxLinha,2290, Transf(((TRB1->WK1VALCOM/nxCTotIte)*100),"@E 999.999"),          If(Left(TRB1->WK1DESP,3)$"104.204",aFontes:ARIAL_08_BOLD,aFontes:ARIAL_08),,,,1)
	nxLinha+=nxIncrem
	TRB1->(dBSkip())
EndDo
If nxLinha >= 3000-nxIncrem
	TRACO_NORMAL
	ICus_IMPCAB("6")
EndIf
/*If nxSTotIte #0
	If !Empty(cxPedAnt).or.!Empty(cxPosAnt)
		TRACO_REDU_03
		TRACO_VERT_01
		oPrn:Say(nxLinha,0750, STR0104, 											aFontes:ARIAL_10_BOLD,,,,1) //"Tot.Item s/ IPI/ICMS - "
		oPrn:Say(nxLinha,1010, Transf((nxSTotIte/nxQtdIte),"@E 999,999,999.9999"), 				aFontes:ARIAL_08_BOLD,,,,1)
		oPrn:Say(nxLinha,1270, Transf(((nxSTotIte/nxQtdIte)/SW6->W6_TX_US_D),"@E 999,999,999.9999"),aFontes:ARIAL_08_BOLD,,,,1)
		oPrn:Say(nxLinha,1530, Transf(nxSTotIte,"@E 999,999,999.99"), 								aFontes:ARIAL_08_BOLD,,,,1)
		oPrn:Say(nxLinha,1790, Transf((nxSTotIte/SW6->W6_TX_US_D),"@E 99,999,999.99"), 			aFontes:ARIAL_08_BOLD,,,,1)
		oPrn:Say(nxLinha,1990, Transf(((nxSTotIte/nxFOB)*100),"@E 999.999"),     					aFontes:ARIAL_08_BOLD,,,,1)
//              oPrn:Say(nxLinha,2140, Transf(((nxSTotIte/nxSTotIte)*100),"@E 999.999"),aFontes:ARIAL_08_BOLD,,,,1)
//              oPrn:Say(nxLinha,2290, Transf(((nxSTotIte/nxCTotIte)*100),"@E 999.999"),aFontes:ARIAL_08_BOLD,,,,1)
//              nxLinha+=nxIncrem
//              TRACO_VERT_01
//              oPrn:Say(nxLinha,0750, STR0105,                                                                                         aFontes:ARIAL_10_BOLD,,,,1) //"Tot.Item c/ IPI/ICMS - "
//              oPrn:Say(nxLinha,1010, Transf((nxCTotIte/nxQtdIte),"@E 999,999,999.9999"),                              aFontes:ARIAL_08_BOLD,,,,1)
//              oPrn:Say(nxLinha,1270, Transf(((nxCTotIte/nxQtdIte)/SW6->W6_TX_US_D),"@E 999,999,999.9999"),aFontes:ARIAL_08_BOLD,,,,1)
//              oPrn:Say(nxLinha,1530, Transf(nxCTotIte,"@E 999,999,999.99"),                                                           aFontes:ARIAL_08_BOLD,,,,1)
//              oPrn:Say(nxLinha,1790, Transf((nxCTotIte/SW6->W6_TX_US_D),"@E 99,999,999.99"),                  aFontes:ARIAL_08_BOLD,,,,1)
//              oPrn:Say(nxLinha,1990, Transf(((nxCTotIte/nxFOB)*100),"@E 999.999"),aFontes:ARIAL_08_BOLD,,,,1)
//              oPrn:Say(nxLinha,2290, Transf(((nxCTotIte/nxCTotIte)*100),"@E 999.999"),aFontes:ARIAL_08_BOLD,,,,1)
		nxLinha+=nxIncrem
EndIf
EndIf*/

Return

*==================================*
Static FUNCTION ICus_IMPCAB(cxCabec)
*==================================*
IF cxCabec # '4'
	COMECA_PAGINA
EndIf	
If cxCabec $ "12"  //--- Cabecalho de Resumo de Centro de Custos/Divisão
	TRACO_NORMAL
	TRACO_VERT_01
        oPrn:Say(nxLinha, 300, If(cxCabec=="1",STR0094,; //"Centros de Custo"
							STR0095),	aFontes:ARIAL_10_BOLD) //"Divisão"
	oPrn:Say(nxLinha,1530, STR0082+" "+EasyGParam("MV_SIMB1",,"R$"),	aFontes:ARIAL_08_BOLD,,,,1) //"Valor em R$"
	oPrn:Say(nxLinha,1790, STR0083,	aFontes:ARIAL_08_BOLD,,,,1) //"Valor em US$"
	oPrn:Say(nxLinha,2290, STR0096,			aFontes:ARIAL_08_BOLD,,,,1) //"%Proc"
	nxLinha+=nxIncrem
	TRACO_NORMAL
ElseIf cxCabec=="3"
	TRACO_NORMAL
	TRACO_VERT_01
	oPrn:Say(nxLinha, 1150, STR0047, aFontes:ARIAL_10_BOLD,,,,2) //"Observações Gerais"
	nxLinha+=nxIncrem
	TRACO_NORMAL
ElseIf cxCabec=="4"
	TRACO_NORMAL
	TRACO_VERT_01
	oPrn:Say(nxLinha,0055, STR0113,	aFontes:ARIAL_08_BOLD,,,,) //"Centro Custo"
	If lxExistDV
		oPrn:Say(nxLinha,0325, STR0095,	aFontes:ARIAL_08_BOLD,,,,) //"Divisão"
	EndIf
	oPrn:Say(nxLinha,0595, STR0114,aFontes:ARIAL_08_BOLD,,,,) //"Codigo Produto"
	oPrn:Say(nxLinha,1000, STR0115,			aFontes:ARIAL_08_BOLD,,,,1) //"UN"
	oPrn:Say(nxLinha,1270, STR0116,	aFontes:ARIAL_08_BOLD,,,,1) //"Qtde.Total"
	oPrn:Say(nxLinha,1530, STR0082+" "+EasyGParam("MV_SIMB1",,"R$"),	aFontes:ARIAL_08_BOLD,,,,1) //"Valor em R$"
	oPrn:Say(nxLinha,1790, STR0083,	aFontes:ARIAL_08_BOLD,,,,1) //"Valor em US$"
	oPrn:Say(nxLinha,1990, STR0117,			aFontes:ARIAL_08_BOLD,,,,1) //"%C.C."
	oPrn:Say(nxLinha,2140, STR0118,			aFontes:ARIAL_08_BOLD,,,,1) //"%Ped."
	oPrn:Say(nxLinha,2290, STR0119,		aFontes:ARIAL_08_BOLD,,,,1) //"%Proc."
	nxLinha+=nxIncrem	
	TRACO_NORMAL
ElseIf cxCabec=="5"
	TRACO_NORMAL
	TRACO_VERT_01
//      oPrn:Say(nxLinha,2140, STR0079, aFontes:ARIAL_08_BOLD,,,,1) //"% s/ IPI"
//      oPrn:Say(nxLinha,2290, STR0080, aFontes:ARIAL_08_BOLD,,,,1) //"% c/ IPI"
//      nxLinha+=nxIncrem
//      TRACO_VERT_01
	oPrn:Say(nxLinha, 300, STR0081,    aFontes:ARIAL_10_BOLD) //"Despesas"
	oPrn:Say(nxLinha,1530, STR0082+" "+EasyGParam("MV_SIMB1",,"R$"), aFontes:ARIAL_08_BOLD,,,,1) //"Valor em R$"
	oPrn:Say(nxLinha,1790, STR0083,aFontes:ARIAL_08_BOLD,,,,1) //"Valor em US$"
	oPrn:Say(nxLinha,1990, STR0084,       aFontes:ARIAL_08_BOLD,,,,1) //"% FOB"
//      oPrn:Say(nxLinha,2140, STR0085,aFontes:ARIAL_08_BOLD,,,,1) //"ICMS"
//      oPrn:Say(nxLinha,2290, STR0085,aFontes:ARIAL_08_BOLD,,,,1) //"ICMS"
	nxLinha+=nxIncrem
	TRACO_NORMAL
ElseIf cxCabec=="6"
	TRACO_NORMAL
//      TRACO_VERT_01
//      oPrn:Say(nxLinha,2140, STR0079, aFontes:ARIAL_08_BOLD,,,,1) //"% s/ IPI"
//      oPrn:Say(nxLinha,2290, STR0080, aFontes:ARIAL_08_BOLD,,,,1) //"% c/ IPI"
//      nxLinha+=nxIncrem
        TRACO_VERT_01
	oPrn:Say(nxLinha, 300, STR0081,    aFontes:ARIAL_10_BOLD) //"Despesas"
	oPrn:Say(nxLinha,1010, STR0100+" "+EasyGParam("MV_SIMB1",,"R$"), aFontes:ARIAL_08_BOLD,,,,1) //"Val.Unit."
	oPrn:Say(nxLinha,1270, STR0101,aFontes:ARIAL_08_BOLD,,,,1) //"Val.Unit.US$"
	oPrn:Say(nxLinha,1530, STR0102+" "+EasyGParam("MV_SIMB1",,"R$"), aFontes:ARIAL_08_BOLD,,,,1) //"Val.Tot."
	oPrn:Say(nxLinha,1790, STR0103,aFontes:ARIAL_08_BOLD,,,,1) //"Val.Tot. US$"
	oPrn:Say(nxLinha,1990, STR0084,       aFontes:ARIAL_08_BOLD,,,,1) //"% FOB"
//      oPrn:Say(nxLinha,2140, STR0085,aFontes:ARIAL_08_BOLD,,,,1) //"ICMS"
//      oPrn:Say(nxLinha,2290, STR0085,aFontes:ARIAL_08_BOLD,,,,1) //"ICMS"
	nxLinha+=nxIncrem
	TRACO_NORMAL
EndIf
Return


*===================================*
Static FUNCTION ICus_TitRel(cxTitRel)
*===================================*
If nxLinha >= 3000-160
   COMECA_PAGINA
ENDIF
oPrn:BOX(nxLinha,1600,(nxLinha+150),2300)
oPrn:BOX((nxLinha+5),(1600+5),((nxLinha+150)-5),(2300-5))
oPrn:Say((nxLinha+55),1800,cxTitRel,aFontes:ARIAL_13_BOLD)
nxLinha+=150	
Return

*===================================*
Static Function DI157NFE(cTipoNF)
*===================================*
// PRIVATE cTitulo:="Solicitação de Factura"    REGIANE 30/10/2007
PRIVATE cTitulo:=STR0185

DO CASE
   CASE cTipoNF = NFE_FOB      ; cTitulo += STR0170 //" (FOB)"
   CASE cTipoNF = NFE_FRETE    ; cTitulo += STR0171 //" (Flete)"
   CASE cTipoNF = NFE_SEGURO   ; cTitulo += STR0172 //" (Seguro)"
   CASE cTipoNF = NFE_IMPOSTOS ; cTitulo += STR0173 //" (Impuestos)"
   CASE cTipoNF = NFE_CIF      ; cTitulo += STR0183 //" (CIF)"
   CASE cTipoNF = NFE_DESPESAS ; cTitulo += STR0174 //" (Gastos)"
EndCASE

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
      Processa({|| DI157RelNFE(cTipoNF)} ,STR0124,,.T.) //"Impressao da Nota Fiscal..."

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
Static Function DI157RelNFE(cTipoNF)
*----------------------------------------------------------------------------------*
PRIVATE lAbortPrint:=.F.
PRIVATE nItem:= nValImp  := nFrete:= nSeguro:= nCIF:= nIIVal:= nValMerc:= nICMSVal:= nGastos:= 0
PRIVATE cPictNotaF:=IF(!EMPTY(AVSX3("WN_DOC",6)),AVSX3("WN_DOC",6),"@!")
PRIVATE cPictItem:= AVSX3('B1_COD',6)
PRIVATE cPictTec := AVSX3('B1_POSIPI',6)
PRIVATE cPictFre := '@E 9,999,999,999.99'
PRIVATE cPictSeg := '@E 999,999,999.99'
PRIVATE cPICT15_2:= '@E 9,999,999,999.99'
PRIVATE cPICT06_2:= '@E 999.99'
PRIVATE cPICTICMS:= AVSX3('YD_ICMS_RE',6)

ProcRegua( SF1->(LASTREC()) + 10 )

IncProc(STR0125) //"Iniciando variaveis do relatorio, Aguarde..."
lPrimPag:= .T.
nLimPage:= 2200
nColFim := 3090
nLin    := 99999 
nPag    := 0 
cChave  := ''
cNFChave:= ''

IncProc(STR0125) //"Iniciando variaveis do relatorio, Aguarde..."
nCol01 := 0
nCol03 := nCol01
nCol05 := nCol03+500
nCol06 := nCol05+000
nCol07 := nCol06+290
nCol08 := nCol07+260
nCol09 := nCol08+260
nCol10 := nCol09+260 
nCol11 := nCol10+260 
nCol12 := nCol11+260 
nCol13 := nCol12+260 
nCol14 := nCol13+260//040
nCol15 := nCol14+040//250 
nCol16 := nCol15+260 
nCol17 := nCol16+120 
nCol18 := nColFim

IncProc(STR0126) //"Ajustando arquivos, Aguarde..."
SF1->(DBSETORDER(5))
SWN->(DBSETORDER(2))
SW7->(DBSETORDER(1))
SW2->(DBSETORDER(1))

SW7->(DbSeek(xFILIAL('SW7')+SW6->W6_HAWB))
SW2->(DbSeek(xFilial("SW2")+SW7->W7_PO_NUM))

ProcRegua( Work1->(LASTREC()) )
Work1->(DBSETORDER(6))
Work1->(DBGOTOP())
Work1->(DBEVAL( {|| DI157DetRel(.T.,cTipoNF) },, {|| !lAbortPrint } ))
Work1->(DBGOTOP())

DI157Totais(cTipoNF)

SF1->(DBSETORDER(1))
SWN->(DBSETORDER(1))
SWZ->(DBSETORDER(1))
RETURN .T.
*----------------------------------*
STATIC FUNCTION DI157CabRel(lWork)
*----------------------------------*
LOCAL vTAXAS:={}
LOCAL n:=0

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
oPrn:Say(nLin,nColFim,STR0132+STR(nPag,8),COURIER_12,,,,1) //"Pagina..: "
nLin+=50

oPrn:Say(nLin,01,STR0133,COURIER_12) //"SIGAEIC"
oPrn:Say(nLin,nColFim/2,STR0134,COURIER_12,,,,2) //"Analítico"
oPrn:Say(nLin,nColFim,STR0135+DTOC(dDataBase),COURIER_12,,,,1) //"Emissao.: "
nLin+=50

oPrn:Box( nLin,01,nLin+1,nColFim)
nLin +=25

SYT->(DBSEEK(XFILIAL('SYT')+SW2->W2_IMPORT))

oPrn:Say(nLin,0001,STR0136+SW2->W2_IMPORT+" - "+ALLTRIM(SYT->YT_NOME)+" - "+ALLTRIM(SYT->YT_ENDE),COURIER_08) //"Empresa ..........: "
nLin+=45
oPrn:Say(nLin,0001,STR0137+SW6->W6_HAWB,COURIER_08) //"Processo..........: "
oPrn:Say(nLin,0800,STR0138+SA2->A2_COD+" - "+ALLTRIM(SA2->A2_NREDUZ),COURIER_08) //"Fornecedor ............: "
oPrn:Say(nLin,2400,STR0139  +SW6->W6_HOUSE,COURIER_08) //"Conhecimento.........: "
nLin+=45
oPrn:Say(nLin,0001,STR0140+DTOC(SW6->W6_DT_HAWB),COURIER_08) //"Dt. Processo......: "
oPrn:Say(nLin,0800,STR0141+TRANS(SW6->W6_DI_NUM,'@R 99/9999999-9'),COURIER_08) //"D.I....................: "
oPrn:Say(nLin,1600,STR0142+DTOC(SW6->W6_DT),COURIER_08) //"Dt. D.I.............: "
oPrn:Say(nLin,2400,STR0143+DTOC(SW6->W6_DT_ENTR),COURIER_08) //"Dt. Entrega..........: "
nLin+=45
// oPrn:Say(nLin,0001,STR0144+TRANS(SW6->W6_TX_FOB ,AVSX3('W6_TX_FOB',6)),COURIER_08) //"Tx. Conversao FOB.: " // RAD 30/10/07
                                                                                                                                                            
SW9->(dBSetOrder(3))
SW9->(dBSeek(xFilial("SW9")+SW6->W6_HAWB))                                           

While !SW9->(Eof()).and.SW9->W9_FILIAL+SW9->W9_HAWB==xFilial("SW9")+SW6->W6_HAWB
    IF ASCAN(vTAXAS, SW9->W9_TX_FOB)==0
        AADD(vTAXAS, SW9->W9_TX_FOB)
    ENDIF
	SW9->(dBSkip())
EndDo

oPrn:Say(nLin,0800,STR0145+TRANS(SW6->W6_TX_US_D,AVSX3('W6_TX_US_D',6)),COURIER_08) //"Tx. Conversao US$ D.I..: "
oPrn:Say(nLin,1600,STR0146+TRANS(SW6->W6_TX_FRET,AVSX3('W6_TX_FRET',6)),COURIER_08) //"Tx. Conversao Frete.: "

For N := 1 TO LEN(vTAXAS)                   
        oPrn:Say(nLin,0001,STR0144+TRANS(vTAXAS[n],AVSX3('W6_TX_FOB',6)),COURIER_08) //"Tx. Conversao FOB.: " // RAD 30/10/07
        nLin+=50        
NEXT

SX3->(dBSetOrder(2))
If SX3->(dBSeek("W6_TX_SEG"))
   oPrn:Say(nLin,2400,STR0147  +TRANS(IF(lWork,nTx_Seguro,SW6->W6_TX_SEG),AVSX3('W6_TX_SEG',6)),COURIER_08) //"Tx. Conversao Seguro.: "
ENDIF
nLin+=50

cMoedaLoc := EasyGParam("MV_SIMB1",,"R$")
oPrn:Box( nLin,01,nLin+1,nColFim)
nLin +=25          
oPrn:Say( nLin,nCol03,STR0148 ,COURIER_07)      //"Cod. Item"
oPrn:Say( nLin,nCol05,STR0149 ,COURIER_07,,,,1) //"Peso Líq."
oPrn:Say( nLin,nCol07,STR0151 ,COURIER_07,,,,1) //"Quantidade"
oPrn:Say( nLin,nCol08,STR0152+" ("+cMoedaLoc+")" ,COURIER_07,,,,1) //"Preco"
oPrn:Say( nLin,nCol09,STR0175+" ("+cMoedaLoc+")" ,COURIER_07,,,,1) //"Precio Total"
oPrn:Say( nLin,nCol10,STR0153+" ("+cMoedaLoc+")" ,COURIER_07,,,,1) //"Vlr Frete"
oPrn:Say( nLin,nCol11,STR0154+" ("+cMoedaLoc+")" ,COURIER_07,,,,1) //"Vlr Seguro"
oPrn:Say( nLin,nCol12,STR0176+" ("+cMoedaLoc+")" ,COURIER_07,,,,1) //"Vlr FOB"
oPrn:Say( nLin,nCol13,STR0177 ,COURIER_07,,,,1) //"Vlr Impuestos"
oPrn:Say( nLin,nCol14,STR0184 ,COURIER_07,,,,1) //"Gastos"
oPrn:Say( nLin,nCol15,STR0178 ,COURIER_07)      //"Nro.P.O."
nLin +=40     
oPrn:Say( nLin,nCol03,REPL('=',20           ),COURIER_07)
oPrn:Say( nLin,nCol05,REPL('=',LEN(cPeso   )),COURIER_07,,,,1)
oPrn:Say( nLin,nCol07,REPL('=',LEN(cUni+cQtde)),COURIER_07,,,,1)
oPrn:Say( nLin,nCol08,REPL('=',LEN(cPreco  )),COURIER_07,,,,1)
oPrn:Say( nLin,nCol09,REPL('=',LEN(cFrete  )),COURIER_07,,,,1)
oPrn:Say( nLin,nCol10,REPL('=',LEN(cFrete  )),COURIER_07,,,,1)
oPrn:Say( nLin,nCol11,REPL('=',LEN(cSeguro )),COURIER_07,,,,1)
oPrn:Say( nLin,nCol12,REPL('=',LEN(cCIF    )),COURIER_07,,,,1)
oPrn:Say( nLin,nCol13,REPL('=',LEN(cValImp)) ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol14,REPL('=',LEN(cGastos)) ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol15,REPL('=',LEN(cPedido)) ,COURIER_07)                                   


//oPrn:Say( nLin,nCol15,REPL('=',LEN(cForn+" - "+LEFT(SA2->A2_NREDUZ,10))),COURIER_07)
nLin +=35

RETURN .T.
*----------------------------------------------------------------------------------*
Static Function DI157DetRel(lWorkAux,cTipoNF)
*----------------------------------------------------------------------------------*
LOCAL lPassou:=.F.
PRIVATE cMarca //Usado no Rdmake Eicdi157_ap5.prw("REL_DET")
Private lWork:=If(lWorkAux=NIL,.F.,lWorkAux)

cNotaF  :=       IF(lWork, Work1->WK_NFE    , SWN->WN_DOC     )
cSerie  :=       IF(lWork, Work1->WK_SE_NFE , SWN->WN_SERIE   )
cCFO    :=       IF(lWork, Work1->WK_CFO    , SWN->WN_CFO     )
cOperac :=       IF(lWork, Work1->WK_OPERACA, SWN->WN_OPERACA )
cForn   :=       IF(lWork, Work1->WKFORN    , SWN->WN_FORNECE )
cPedido :=       IF(lWork, Work1->WKPO_NUM  , SWN->WN_PO_EIC  )
cCod_I  := TRAN( IF(lWork, Work1->WKCOD_I   , SWN->WN_PRODUTO ) ,cPictItem)
cDescr  := LEFT( IF(lWork, Work1->WKDESCR   , SWN->WN_DESCR   ) ,25)
cUni    :=       IF(lWork, Work1->WKUNI     , SWN->WN_UNI	    )
cPeso   := TRAN( DI157Valor(0,lWork,cTipoNF), cPictPeso)
cQtde   := TRAN( DI157Valor(1,lWork,cTipoNF),'@E 999,999,999.999' )
cPreco  := TRAN( DI157Valor(2,lWork,cTipoNF),'@E 999,999,999.9999')
cValMerc:= TRAN( IF(lWork, Work1->WKVALMERC , SWN->WN_VALOR   ) ,cPICT15_2)
cFrete  := TRAN( IF(lWork, Work1->WKFRETE   , SWN->WN_FRETE   ) ,cPictFre)
cSeguro := TRAN( IF(lWork, Work1->WKSEGURO  , SWN->WN_SEGURO  ) ,cPictSeg)
cCIF    := TRAN( IF(lWork, Work1->WKFOB_R   , SWN->WN_CIF     ) ,cPICT15_2)
cValImp := TRAN( Work1->WKIMPOSTOS                              ,cPICT15_2)
cTec    := TRAN( IF(lWork, Work1->WKTEC     , SWN->WN_TEC     ) ,cPictTec)
cEx_Ncm :=   " "+IF(lWork, Work1->WKEX_NCM  , SWN->WN_EX_NCM  )
cEx_Nbm :=   " "+IF(lWork, Work1->WKEX_NBM  , SWN->WN_EX_NBM  )
cGastos := TRAN( IF(lWork, Work1->WKOUT_DESP, SWN->WN_DESPESA ) ,cPICT15_2)

IncProc(STR0163+Work1->WKCOD_I) //"Imprimindo Item: "

IF nLin > nLimPage
   DI157CabRel(lWork)
   lPassou:=.T.
ENDIF                            

IF cChave # cForn+cNotaF+cSerie+cOperac+cTec+cEx_Ncm+cEx_Nbm+cPedido

   IF cNFChave # TRANS(cNotaF,cPictNotaF)+" "+cSerie
      IF(lPassou,nLin+=40,)
      DI157Totais(cTipoNF)
      cNFChave:= TRANS(cNotaF,cPictNotaF)+" "+cSerie
      lPassou := .F.
   ENDIF   

   IF nLin > nLimPage
      DI157CabRel(lWork)
      lPassou:=.T.
   ENDIF                            

   IF !lPassou 
      oPrn:Box( nLin,01,nLin+1,nColFim)
      nLin +=15
   ENDIF   
   SA2->(dBSeek(xFilial('SA2')+cForn))
   
   IF !lWork .AND. SWN->( FieldPos("WN_TES") ) > 0 .AND. !EMPTY(SWN->WN_TES)
   	  cTES := SWN->WN_TES
   ELSEIF lWork .AND. !EMPTY(Work1->WKTES)	              
      cTES := Work1->WKTES
   ELSE
	  vORDSYD:= SYD->(INDEXORD())
	  SYD->(DBSETORDER(1))
	  IF SYD->(DBSEEK(xFILIAL("SYD")+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM)) .AND. !EMPTY(SYD->YD_TES)
		 cTES:=SYD->YD_TES
	  ELSE
		 cTES:=""   
	  ENDIF
	  SYD->(DBSETORDER(vORDSYD))                                 
   ENDIF
   
   oPrn:Say( nLin,nCol01,STR0164+TRANS(cNotaF,cPictNotaF)+' '+cSerie+' '+;			//"Nota Fiscal: "
                                    STR0179+': '+cForn+"-"+LEFT(SA2->A2_NREDUZ,20)+;		//"Proveedor"
                                    STR0166+cTec+cEx_Ncm+cEx_Nbm +'  '+; 	                    //"      N.C.M.: "  
                                    AVSX3("YD_TES",5)+":" + cTES, COURIER_07N)      			// RAD 02/11/07 - Para incluir TES  
  
   /*oPrn:Say( nLin,nCol01,STR0164+TRANS(cNotaF,cPictNotaF)+' '+cSerie+' '+;//"Nota Fiscal: "
                         STR0179+': '+cForn+"-"+LEFT(SA2->A2_NREDUZ,20)+;//"Proveedor"
                         STR0166+cTec+cEx_Ncm+cEx_Nbm,COURIER_07N) //"      N.C.M.: "    // RAD 02/11/07 - Para incluir TES */
                         
                         
   cChave  := cForn+cNotaF+cSerie+cOperac+cTec+cEx_Ncm+cEx_Nbm+cPedido
   nLin+=40

   IF nLin > nLimPage
      DI157CabRel(lWork)
   ENDIF                               
ENDIF                       
SA2->(dBSeek(xFilial('SA2')+cForn))
nItem++

oPrn:Say( nLin,nCol03,cCod_I  ,COURIER_07)
oPrn:Say( nLin,nCol05,cPeso   ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol07,cUni+cQtde,COURIER_07,,,,1)
oPrn:Say( nLin,nCol08,cPreco  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol09,cValMerc,COURIER_07,,,,1)
oPrn:Say( nLin,nCol10,cFrete  ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol11,cSeguro ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol12,cCIF    ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol13,cValImp ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol14,cGastos ,COURIER_07,,,,1)
oPrn:Say( nLin,nCol15,cPedido ,COURIER_07)                                                                  

//oPrn:Say( nLin,nCol15,cForn+" - "+ALLTRIM(LEFT(SA2->A2_NREDUZ,10)),COURIER_07)

nLin+=40             
   
nValMerc+= VAL(STR( IF(lWork, Work1->WKVALMERC , SWN->WN_VALOR   ) ,15,2))
nValImp += VAL(STR( Work1->WKIMPOSTOS,15,2))
nFrete  += VAL(STR( IF(lWork, Work1->WKFRETE   , SWN->WN_FRETE   ) ,15,2))
nSeguro += VAL(STR( IF(lWork, Work1->WKSEGURO  , SWN->WN_SEGURO  ) ,15,2))
nCIF    += VAL(STR( IF(lWork, Work1->WKFOB_R   , SWN->WN_CIF     ) ,15,2))
nGastos += VAL(STR( IF(lWork, Work1->WKOUT_DESP, SWN->WN_DESPESA ) ,15,2))

RETURN .T.
*----------------------------------------------------------------------------------*
Static Function DI157Valor(nTipo,lWork,cTipoNF)
*----------------------------------------------------------------------------------*
LOCAL nValor:=0

IF cTipoNF # NFE_DESPESAS
   IF nTipo==0
      nValor:=IF(lWork,Work1->WKPESOL,SWN->WN_PESOL)
   ELSEIF nTipo==1
      nValor:=IF(lWork,Work1->WKQTDE ,SWN->WN_QUANT)
   ELSEIF nTipo==2
      nValor:=IF(lWork,Work1->WKPRUNI,SWN->WN_PRUNI)
   ENDIF
ENDIF

RETURN nValor

*---------------------------------------------------------------------------------*
Static FUNCTION DI157Totais(cTipoNF)
*---------------------------------------------------------------------------------*
IF nItem > 1
   oPrn:Say( nLin,nCol09,REPL('=',LEN(cPICT15_2)-3),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol10,REPL('=',LEN(cPictFre)-3),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol11,REPL('=',LEN(cPictSeg)-3),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol12,REPL('=',LEN(cPICT15_2)-3),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol13,REPL('=',LEN(cPICT15_2)-3),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol14,REPL('=',LEN(cPICT15_2)-3),COURIER_07,,,,1)
   nLin +=30
   oPrn:Say( nLin,nCol09,TRAN(nValMerc,cPICT15_2),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol10,TRAN(nFrete  ,cPictFre),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol11,TRAN(nSeguro ,cPictSeg),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol12,TRAN(nCIF    ,cPICT15_2),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol13,TRAN(nValImp,cPICT15_2),COURIER_07,,,,1)
   oPrn:Say( nLin,nCol14,TRAN(nGastos,cPICT15_2),COURIER_07,,,,1)
   nLin +=40
ENDIF                                                                                  
iF cPAISLOC<>"BRA"
    oPrn:Say( nLin,nCol13,STR0168+ALLTRIM(cNFChave)+STR0180+TRAN(nValImp+nValMerc,cPICT15_2),COURIER_10,,,,1) //"TOTAL N.F.E.: " //" (Precio Total + Impuestos).: "
ELSE   // RAD 30/10/2007 - Nao se tem impostos na 1a nota em outros paises. 
    oPrn:Say( nLin,nCol13,STR0168+ALLTRIM(cNFChave)+STR0186+TRAN(nValImp+nValMerc,cPICT15_2),COURIER_10,,,,1) //"TOTAL N.F.E.: " //" (Precio Total + Impuestos).: "
ENDIF         
nLin+=45
nItem:= nValImp := nFrete:= nSeguro:= nCIF:= nIIVal:= nValMerc:= nICMSVal:= 0

RETURN .T.
*-------------------------------------------------------------------------------------------------------*
STATIC FUNCTION DI157PRETXT()
*-------------------------------------------------------------------------------------------------------*
LOCAL OldArea:=SELECT()               
PRIVATE aEstrutura:={{"WKCOD_I"   ,"C",30,00},;
                   {"WKTEC"     ,"C",08,00},;
                   {"WKQUALIF"  ,"C",03,00},;
                   {"WKQUAL_NCM","C",03,00},;
                   {"WKQTDE"    ,"N",15,04},;
                   {"WKDESCR"   ,"C",60,00},;
                   {"WKUNI"     ,"C",03,00},;
                   {"WKPESOL"   ,"N",18,08},;
                   {"WKFOB"     ,"N",18,08},;
                   {"WKFRETE"   ,"N",18,08},;
                   {"WKSEGURO"  ,"N",18,08},;
                   {"WKCIF"     ,"N",18,08},;
                   {"WKIIVAL"   ,"N",18,08},;
                   {"WKIPIVAL"  ,"N",18,08},;
                   {"WKVL_ICM"  ,"N",18,08},;
                   {"WKOUT_DESP","N",18,08},;
                   {"WKRATEIO"  ,"N",18,16},;
                   {"WKIITX"    ,"N",06,02},;
                   {"WKIPITX"   ,"N",06,02},;           
                   {"WKICMS_A"  ,"N",06,02},;
                   {"WKMOE_FOB" ,"C",03,00},;
                   {"WKTX_FOB"  ,"N",15,08},;
                   {"WKMOE_FRE" ,"C",03,00},;
                   {"WKTX_FRETE","N",15,08},;
                   {"WKMOE_SEG" ,"C",03,00},;
                   {"WKTX_USD"  ,"N",15,08},;
                   {"WKHOUSE"   ,"C",20,00},;
                   {"WKHOUSE_DT","C",08,00},;
                   {"WKDI"      ,AVSX3("W6_DI_NUM",2),10,00},;
                   {"WKDI_DT"   ,"C",08,00},;
                   {"WKNFE"     ,"C",20,00},;
                   {"WKNFE_DT"  ,"C",08,00},;
                   {"WKDT_DESEM","C",08,00},;
                   {"WKDT_ENTR" ,"C",08,00},;
                   {"WKLI_NUM"  ,"C",13,00},;
                   {"WKPO_NUM"  ,"C",15,00},;
                   {"WKSI_NUM"  ,"C",06,00},;
                   {"WKCC_NUM"  ,"C",05,00},;
                   {"WKFORN"    ,"C",15,00},;
                   {"WKREG"     ,"C",02,00}} // para Merck

PRIVATE aCampos:={}
PRIVATE aHeader:={}
cFileTXT:=E_CriaTrab(,aEstrutura,"WorkTxt")
IF ! USED()
   MSGINFO(OemToAnsi(STR0067),STR0022) //"NÆo foi poss¡vel a abertura do Arquivo de Trabalho"###"Atenção"
   Return .F.
ENDIF
//MFR OSSME-1974 26/12/2018
IndRegua("WorkTxt",cFileTXT+TeOrdBagExt(),"WKTEC+WKQUALIF+WKQUAL_NCM+WKCOD_I")

Processa({|| DI157GerTXT()},STR0181);// GERAR ARQUIVO //"Gerando Arquivo Temporario"

IF cTipoNF = CUSTO_REAL
   TR350Arquivo("WorkTxt","Work3")
ELSE
   TR350Arquivo("WorkTxt")
ENDIF

WorkTxt->(E_EraseArq(cFileTXT)) 

Work1->(DBGOTOP())
DBSELECTAREA(OldArea)

RETURN .T.

*-------------------------------------------------------------------------------------------------------*
Static FUNCTION DI157GerTXT()
*-------------------------------------------------------------------------------------------------------*
DBSELECTAREA("Work2")
Work1->(DBGOTOP())        
ProcRegua(Work1->(LASTREC()))
DO WHILE ! Work1->(EOF())

   IncProc(STR0182+Work1->WKCOD_I) //"Processando Item: "
   
   Work2->(DBSEEK(Work1->WK_CFO+Work1->WK_OPERACA+Work1->WKTEC+Work1->WKEX_NCM+Work1->WKEX_NBM))
   WorkTxt->(DBAPPEND())
   WorkTxt->WKCOD_I     := Work1->WKCOD_I
   WorkTxt->WKTEC       := Work1->WKTEC
   WorkTxt->WKQUALIF    := Work1->WKEX_NBM
   WorkTxt->WKQUAL_NCM  := Work1->WKEX_NCM
   WorkTxt->WKQTDE      := Work1->WKQTDE
   WorkTxt->WKDESCR     := Work1->WKDESCR
   WorkTxt->WKUNI       := Work1->WKUNI
   WorkTxt->WKPESOL     := Work1->WKPESOL / Work1->WKQTDE

   WorkTxt->WKCIF       := Work1->WKVALMERC/Work1->WKQTDE
   WorkTxt->WKFRETE     := (Work2->WKFRETE*Work1->WKPESOL/Work2->WKPESOL)/Work1->WKQTDE
   WorkTxt->WKSEGURO    := Work2->WKSEGURO*Work1->WKRATEIO/Work1->WKQTDE
   WorkTxt->WKFOB       := WorkTxt->WKCIF-WorkTxt->WKFRETE-WorkTxt->WKSEGURO

   IF cTipoNF = CUSTO_REAL
      WorkTxt->WKFOB       := Work1->WKVALMERC / Work1->WKQTDE
      WorkTxt->WKCIF       := WorkTxt->WKFOB+WorkTxt->WKFRETE+WorkTxt->WKSEGURO
   ENDIF

   WorkTxt->WKOUT_DESP  := VAL(STR((Work2->WKOUTRDESP * Work1->WKRATEIO)/Work1->WKQTDE,18,8))

   IF cTipoNF = NFE_IMPOSTOS
      WorkTxt->WKCIF       := WorkTxt->WKFOB+WorkTxt->WKFRETE+WorkTxt->WKSEGURO
   ENDIF

   WorkTxt->WKRATEIO    := Work1->WKRATEIO
   WorkTxt->WKMOE_FOB   := SW4->W4_MOEDA
   WorkTxt->WKTX_FOB    := SW6->W6_TX_FOB
   WorkTxt->WKMOE_FRE   := SW6->W6_FREMOEDA
   WorkTxt->WKTX_FRETE  := SW6->W6_TX_FRET
   WorkTxt->WKMOE_SEG   := SW6->W6_SEGMOED
   WorkTxt->WKTX_USD    := SW6->W6_TX_US_D

   WorkTxt->WKHOUSE     := SW6->W6_HAWB
   WorkTxt->WKHOUSE_DT  := STRZERO(YEAR(SW6->W6_DT_HAWB),4)+STRZERO(MONTH(SW6->W6_DT_HAWB),2)+STRZERO(DAY(SW6->W6_DT_HAWB),2)
   WorkTxt->WKDI        := SW6->W6_DI_NUM
   WorkTxt->WKDI_DT     := STRZERO(YEAR(SW6->W6_DT),4)+STRZERO(MONTH(SW6->W6_DT),2)+STRZERO(DAY(SW6->W6_DT),2)
   WorkTxt->WKNFE       := SW6->W6_NF_ENT
   WorkTxt->WKNFE_DT    := STRZERO(YEAR(SW6->W6_DT_NF),4)+STRZERO(MONTH(SW6->W6_DT_NF),2)+STRZERO(DAY(SW6->W6_DT_NF),2)
   WorkTxt->WKDT_DESEM  := STRZERO(YEAR(SW6->W6_DT_DESE),4)+STRZERO(MONTH(SW6->W6_DT_DESE),2)+STRZERO(DAY(SW6->W6_DT_DESE),2)
   WorkTxt->WKDT_ENTR   := STRZERO(YEAR(SW6->W6_DT_ENTR),4)+STRZERO(MONTH(SW6->W6_DT_ENTR),2)+STRZERO(DAY(SW6->W6_DT_ENTR),2)

   SW7->(DBGOTO(Work1->WKRECNO))
   SWP->(DBSEEK(xFilial("SWP")+SW7->W7_PGI_NUM+SW7->W7_SEQ_LI))
   WorkTxt->WKLI_NUM    := SWP->WP_REGIST
   WorkTxt->WKPO_NUM    := SW7->W7_PO_NUM
   WorkTxt->WKSI_NUM    := SW7->W7_SI_NUM
   WorkTxt->WKCC_NUM    := SW7->W7_CC
   WorkTxt->WKFORN      := BuscaFabr_Forn(SW7->W7_FORN)
   WorkTxt->WKREG:=STRZERO(SW7->W7_REG,2) 

   Work1->(DBSKIP())
ENDDO
SW3->(DBSETORDER(1))

RETURN .T.
*======================================================================================*
*                            FIM DO PROGRAMA EICDI157.PRW                              *
*======================================================================================*

