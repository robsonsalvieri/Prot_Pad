#INCLUDE "FDRC104.ch"
#include "eADVPL.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Prep. recebe        ³Autor-Marcelo Vieira ³ Data ³15/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Recebimento       					 			  ³±±
±±³			 ³ RCPreRec  -> Prepara a Recebimento					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SFA PRONTA ENTREGA 7.0                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³NOperacao 1- Inclusao /2 - Alteracao /3 -                   ´±±
±±³			 ³4 -                                  	     		 		  ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RCPrepRec(oDuplicatas,aDuplicatas,oBrwDuplicatas)
//Variaveis Locais
Local oDlgRec, oLbx, nLbx:=1 , oBco, oAge, oCta
Local oFld1, oFld2, oItem, oMnu
Local lCheck := .t.             
Local oGetDesc,oGetMult,oGetTxp,oGetVrec
Local nLinha := 0, oBtnChq, oBtnCanc
Local cCodCli, cLojaCli              
Local aMotvs:={STR0001, STR0002,STR0003 }, aObjs:={}         //"NORMAL"###"DACAO"###"DEVOLUCAO"
Local oGetBco,oGetAge,oGetCta,oGetRec,oGetCrd,oGetHBx
Local cBanco,cAgen,cCta,cHbx, nVlDivida:=0
Local dDtRec:=ctod("")
Local dDtcrd:=ctod("")
//valores da Baixa
Local nDescto:=0, nMulta:=0, nTaxaPerm:=0, nValorRec:=0, nAbatim:=0, nPagParc:=0, nDescr:=0, nAcres:=0
Public aGets:={}

if Len(aDuplicatas) = 0
   MsgStop( STR0004, STR0005 )  //"Nao existem títulos para baixar"###"Aviso"
   Return 
endif

cHbx:=STR0006                                            //"VALOR RECEBIDO S/TITULO"

// Inicializa Variaveis com parametros

dbSelectArea("HCF")
if dbSeek(RetFilial("HCF")+"MV_SFABCO")
    cBanco:=AllTrim(HCF->CF_VALOR)
Endif	

if dbSeek(RetFilial("HCF")+"MV_SFAAGE")
    cAgen:=AllTrim(HCF->CF_VALOR)
Endif	

if dbSeek(RetFilial("HCF")+"MV_SFACTA")
    cCta:=AllTrim(HCF->CF_VALOR)
Endif	

//
                                       
nLinha := GridRow(oBrwDuplicatas)

cCodCli :=HA1->A1_COD
cLojaCli:=HA1->A1_LOJA

dDtRec:=Date()
dDtcrd:=Date()

dbSelectArea("HE1")
dbSetOrder(1)               
dbSeek( RetFilial("HE1") + cCodCli + cLojaCLi + aDuplicatas[nLinha,1] + aDuplicatas[nLinha,2] )
nVlDivida:=HE1->E1_SALDO         
nValorRec:=nVlDivida

DEFINE DIALOG oDlgRec TITLE STR0007   //"Baixa a Receber"

ADD MENUBAR oMnu CAPTION STR0007 OF oDlgRec //"Baixa a Receber"
ADD MENUITEM oItem CAPTION STR0008 ACTION CloseDialog() OF oMnu //"Retornar"

ADD FOLDER oFld1 CAPTION STR0009 OF oDlgRec //"Dados Gerais"

@ 15,05 SAY STR0010 + HE1->E1_NUM + " " + HE1->E1_PARCELA OF oFld1 //"Titulo: "
aadd( aGets,HE1->E1_NUM     )  // 1 Numero
aadd( aGets,HE1->E1_PARCELA )  // 2 parcela
@ 27,05 SAY STR0011 + Dtoc(HE1->E1_EMISSAO) OF oFld1 //"Emissao: "
aadd( aGets,HE1->E1_EMISSAO )  // 3 emissao
@ 27,85 SAY STR0012 + Dtoc(HE1->E1_VENCTO) OF oFld1   //"Vencto : "
aadd( aGets,HE1->E1_VENCTO )  //  5 Vencimento
@ 37,05 SAY STR0013 + cCodCli+ "-" + cLojaCli + " " + HA1->A1_NOME OF oFld1 //"Cliente: "
aadd( aGets, cCodCli  )  // 6 Cliente
aadd( aGets, cLojaCli )  // 7 Loja
@ 50,05 SAY STR0014 OF oFld1 //"Mot.Baixa: "
@ 50,48 COMBOBOX oLbx VAR nLbx ITEMS aMotvs ACTION RCMotivo(aObjs,nLbx,@cBanco,@cAgen,@cCta) SIZE 68,40 OF oFld1
aadd( aGets, nLbx )  // 8 Motivo da Baixa
If nLbx=1
	@ 65,05 SAY oBco PROMPT STR0015   OF oFld1 //"Banco: "
	aadd( aObjs,oBco )
	@ 65,48 GET oGetBco VAR cBanco PICTURE STR0016 OF oFld1 //"@! XXXXX"
	aadd( aObjs,oGetBco )
	@ 65,75 SAY oAge PROMPT STR0017 OF oFld1 //"Agencia: "
	aadd( aObjs,oAge )
	@ 65,110 GET oGetAge VAR cAgen PICTURE "@! XXXXXXXXXXX" OF oFld1
	aadd( aObjs,oGetAge )                                               
	@ 77,05 SAY oCta PROMPT STR0018 OF oFld1 //"Conta  : "
	aadd( aObjs,oCta )
	@ 77,48 GET oGetCta VAR cCta PICTURE "@! XXXXXXXXXXXX" OF oFld1
	aadd( aObjs,oGetCta )
endif
aadd( aGets, cBanco )  // 9 Banco
aadd( aGets, cAgen  )  // 10 Agencia
aadd( aGets, cCta   )  // 11 Conta
@ 89,01 BUTTON oBtnDtr CAPTION STR0019 ACTION RCData(oGetRec,@dDtRec)  SIZE 43,10  OF oFld1 //"Dt Receb."
@ 89,48 GET oGetRec VAR dDtRec OF oFld1
aadd( aGets, dDtRec )  // 12 Data do recebimento
@ 103,01 BUTTON oBtnDtr CAPTION STR0020 ACTION  RCData(oGetCrd,@dDtcrd)  SIZE 43,10 OF oFld1  //"Dt Cred."
@ 103,48 GET oGetCrd VAR dDtcrd OF oFld1
aadd( aGets, dDtcrd )  // 13 Data do Credito
@ 115,05 SAY STR0021 OF oFld1                                      //"Hist.Baixa:"
@ 115,48 GET oGetHBx VAR cHbx OF oFld1
aadd( aGets, cHbx )  // 14 Historico da baixa
@ 130,005 BUTTON oBtnChq CAPTION  STR0022   ACTION RCCheque(nVlDivida,dDtRec,aGets)SIZE 50,11 OF oFld1   //"Cheques"
@ 130,100 BUTTON oBtnCanc CAPTION STR0023 ACTION RCGrvRec(aGets) SIZE 50,11 OF oFld1   //"Confirmar"

ADD FOLDER oFld2 CAPTION STR0024 OF oDlgRec //"Vlrs da Baixa"

@ 15,05 SAY STR0025 OF oFld2 //"Valor Original   "
@ 15,75 SAY nVlDivida PICTURE "@E 99,999.99" OF oFld2
@ 25,05 SAY STR0026 OF oFld2 //"- Abatimentos    "
@ 25,75 SAY nAbatim   PICTURE "@E 99,999.99" OF oFld2
@ 35,05 SAY STR0027 OF oFld2 //"- Pagtos Parciais"
@ 35,75 SAY nPagParc  PICTURE "@E 99,999.99" OF oFld2
@ 45,05 SAY STR0028 OF oFld2 //"- Decréscimo     "
@ 45,75 SAY nDescr   PICTURE "@E 99,999.99" OF oFld2
@ 55,05 SAY STR0029 OF oFld2 //"+ Acréscimo      "
@ 55,75 SAY nAcres   PICTURE "@E 99,999.99" OF oFld2
// Gets de dados para Baixa
@ 75,05 SAY STR0030 OF oFld2 //"- Descontos      "
@ 75,75 GET oGetDesc VAR nDescto PICTURE "@E 99,999.99" VALID RCRefresh(oGetVrec,nVlDivida,@nValorRec,nDescto,nMulta,nTaxaPerm) OF oFld2                    
aadd( aGets, nDescto )  // 15 desconto
@ 90,05 SAY STR0031 OF oFld2 //"+ Multa          "
@ 90,75 GET oGetMult VAR  nMulta PICTURE "@E 99,999.99" VALID RCRefresh(oGetVrec,nVlDivida,@nValorRec,nDescto,nMulta,nTaxaPerm) OF oFld2                 
aadd( aGets, nMulta )  // 16 Multa
@105,05 SAY STR0032 OF oFld2 //"+ Tx.Permanec.   "
@105,75 GET oGetTxp VAR nTaxaPerm PICTURE "@E 99,999.99" VALID RCRefresh(oGetVrec,nVlDivida,@nValorRec,nDescto,nMulta,nTaxaPerm) OF oFld2                            
aadd( aGets, nTaxaPerm )  // 17 Tx.Permanenc.
@120,05 SAY STR0033 OF oFld2                                              //"Valor Recebido   "
@120,75 GET oGetVrec VAR nValorRec PICTURE "@E 99,999.99" VALID RCRefresh(oGetVrec,nVlDivida,@nValorRec,nDescto,nMulta,nTaxaPerm)OF oFld2                          
aadd( aGets, nValorRec )  // 18 Valor recebido 
ACTIVATE DIALOG oDlgRec

Return nil

// Atualiza o Valor total a receber 
Function RCRefresh(oGetVrec,nVlDivida,nValorRec,nDescto,nMulta,nTaxaPerm) 
nValorRec:=nVlDivida
nValorRec:= ( ( (nValorRec - nDescto) + nMulta ) + nTaxaPerm ) 

SetText( oGetVrec,nValorRec )                               

Return

/***************************************************************************/
/* Seleciona data para o Fechamento do Dia                                 */
/***************************************************************************/
Function RCData(oData,dData)

dData := SelectDate(STR0034,dData) //"Selecione data..."
SetText(oData,dData)

Return nil

/***************************************************************************/
/* Seleciona data para o Fechamento do Dia                                 */
/***************************************************************************/
// Decide se Zera Alguns objetos conforme
Function RCMotivo(aObjs,nLbx,cBanco,cAgen,cCta)
Local n
       
if nLbx<>1
   cBanco:="" 
   cAgen :=""
   cCta  :="" 
endif

for n:=1 to Len(aObjs)
    if  nLbx=2 .or. nLbx=3
        HideControl( aObjs[n] )  
    else                       
        ShowControl( aObjs[n] )
    endif

Next

Return nil

