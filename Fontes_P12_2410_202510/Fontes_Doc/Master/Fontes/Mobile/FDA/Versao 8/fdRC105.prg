#INCLUDE "FDRC105.ch"

/*********************************************************************************/
/* Funcao: Consulta Cheques
/* Realiza consulta de cheques duvidosos                                         */
/*********************************************************************************/
Function RCCheque(nVlDivida,dDataBase,aGets)
Local oDlg, oBrw, oMnu, oItem,oBtnMais,oBtnMenos,oFld1,oFld2
//oBtnGrvCQ
Local oGet1,oGet2,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9,oGet10
Local oSaldo,nSaldo:=0, oLblSaldo
Local oBtnBco, oBtnAge,oBtnChq,oBtnVlr, oBtnDt, oBtnCnpj,oBtnCli,oBtnMes,oBtnAno
Local aItems := {}
Local cBanco, cAgencia, cCheque, nValor, dVencto,cCnpj,cAno,cMes,cCli,cCta          
Local aObjs:={}, aGetsChq:={}                                                                     

cBanco  :=""
cAgencia:=""
cCheque:=""
nValor :=0.00
dVencto:=Date()
cCli   := HA1->A1_NOME
cCnpj  := HA1->A1_CGC 
nSaldo := nVlDivida
cAno   :=""
cMes   :=""
cCta   :=""

DEFINE DIALOG oDlg TITLE STR0001 //"Cheques"
ADD MENUBAR oMnu CAPTION STR0002 OF oDlg  //"Opções"
ADD MENUITEM oItem CAPTION STR0003 ACTION CloseDialog() OF oMnu  //"Retornar"

ADD FOLDER oFld1 CAPTION STR0001 ON ACTIVATE FldChq1(aObjs) of oDlg  //"Cheques"

@ 020,05 SAY oLblSaldo PROMPT  STR0004 OF oDlg //"Saldo"
AADD( aObjs, oLblSaldo )
@ 020,35  SAY oSaldo VAR nSaldo PICTURE "@E 999,999.99" OF oDlg
AADD( aObjs, oSaldo )
//Banco (1)
@ 037,05  BUTTON oBtnBco CAPTION STR0005 SIZE 28,11 ACTION chama_kb(1,oGet1) OF oDlg //"Banco"
AADD( aObjs, oBtnBco )
@ 037,35  GET oGet1 VAR cBanco PICTURE "@R 99999"  OF oDlg      
Alert(oGet1)                       
AADD( aObjs, oGet1 )
AADD( aGets, cBanco )  // 15 
//Agencia (2)
@ 037,85  BUTTON oBtnAge CAPTION STR0006 SIZE 35,11 ACTION chama_kb(1,oGet2) OF oDlg //"Agencia"
AADD( aObjs, oBtnAge )
@ 037,122 GET oGet2 VAR cAgencia PICTURE "@R 99999999"  OF oDlg
AADD( aObjs, oGet2 )
AADD( aGets, cAgencia )  // 16 
//nr da Conta (3)
@ 054,05  BUTTON oBtnCta CAPTION STR0007 SIZE 28,11 ACTION chama_kb(1,oGet3) OF oDlg //"Conta"
AADD( aObjs, oBtnCta )
@ 054,35  GET oGet3 VAR cCta PICTURE "@R 9999999999" OF oDlg
AADD( aObjs, oGet3 )                                       
AADD( aGets, cCta )  // 17 
//nr do Cheque(4)
@ 054,85  BUTTON oBtnChq CAPTION STR0008 SIZE 33,11 ACTION chama_kb(1,oGet4) OF oDlg //"Cheque"
AADD( aObjs, oBtnChq )
@ 054,119  GET oGet4 VAR cCheque PICTURE "@! XXXXXXXXXX" OF oDlg
AADD( aObjs, oGet4 )
AADD( aGets, cCheque )  // 18 
// valor do Cheque
@ 071,05  BUTTON oBtnVlr CAPTION STR0009 SIZE 28,11 ACTION chama_kb(1,oGet5) OF oDlg //"Valor"
AADD( aObjs, oBtnVlr )
@ 071,35 GET oGet5 VAR nValor PICTURE "@E 99999.99" OF oDlg
AADD( aObjs, oGet5 )
AADD( aGets, nValor )  // 19 
// Vencto Cheque
@ 071,85  BUTTON oBtnDt CAPTION STR0010 SIZE 30,11 ACTION CallGetDate(oGet6,@dVencto) OF oDlg //"Venc"
AADD( aObjs, oBtnDt )
@ 071,117 GET oGet6 VAR dVencto  OF oDlg 
AADD( aObjs, oGet6 )           
AADD( aGets, dVencto )  // 20 
//nome do Cliente 
@ 88,05  BUTTON oBtnCli CAPTION STR0011 SIZE 33,11 ACTION chama_kb(0,oGet7) OF oDlg //"Cliente"
AADD( aObjs, oBtnCli )
@ 88,42  GET oGet7 VAR cCli PICTURE "@! XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  OF oDlg
AADD( aObjs, oGet7 )
AADD( aGets, cCli )  // 21 
// Cpf/Cnpj
@ 105,05  BUTTON oBtnCnpj CAPTION STR0012 SIZE 39,11 ACTION chama_kb(1,oGet8) OF oDlg //"Cnpj/Cpf"
AADD( aObjs, oBtnCnpj )
@ 105,49  GET oGet8 VAR cCnpj PICTURE "@R 999999999999999999" OF oDlg 
AADD( aObjs, oGet8 )
AADD( aGets, cCnpj )  // 22 
// Mes e ano de abertura da conta
@ 122,05  BUTTON oBtnMes CAPTION STR0013 SIZE 28,11 ACTION chama_kb(1,oGet9) OF oDlg //"Mes"
AADD( aObjs, oBtnMes )
@ 122,35  GET oGet9 VAR cMes PICTURE "@R 9999"  OF oDlg
AADD( aObjs, oGet9 )
@ 122,60  BUTTON oBtnAno CAPTION STR0014 SIZE 28,11 ACTION chama_kb(1,oGet10) OF oDlg //"Ano"
AADD( aObjs, oBtnAno )
@ 122,090 GET oGet10 VAR cAno PICTURE "@R 999999" OF oDlg 
AADD( aObjs, oGet10 )
//Botoes (inclue, exclue itens)
@ 132,125 BUTTON oBtnMais   CAPTION "+" ACTION AddCheque(oBrw,aItems,cBanco,cAgencia,cCheque,nValor,dVencto,cCnpj,cCli,cCta,cMes,cAno,nSaldo,oSaldo,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9,oGet10,dDataBase,aGets) CANCEL OF oDlg
AADD( aObjs, oBtnMais )


ADD FOLDER oFld2 CAPTION STR0015 ON ACTIVATE FldChq2(aObjs,aGets) of oDlg //"Detalhes"
@ 20,05 BROWSE oBrw SIZE 145,95 OF oFld2
SET BROWSE oBrw ARRAY aItems
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1  HEADER STR0016 WIDTH 60 //"Situacao"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2  HEADER STR0017   WIDTH 27 //"Banco "
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3  HEADER STR0018   WIDTH 27 //"Agenc."
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4  HEADER STR0019 WIDTH 30  //"Nr conta"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 5  HEADER STR0008   WIDTH 50  //"Cheque"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 6  HEADER STR0020   WIDTH 50 PICTURE "@E 999,999.99" ALIGN RIGHT //"Valor "
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 7  HEADER STR0021   WIDTH 50  //"Vencto"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 8  HEADER STR0011  WIDTH 95 //"Cliente"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 9  HEADER STR0022 WIDTH 70  //"Cpf/Cnpj"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 10 HEADER STR0023 WIDTH 40  //"Mes aber"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 11 HEADER STR0024 WIDTH 40  //"Ano aber"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 12 HEADER STR0025   WIDTH 27 PICTURE "@E 9999" ALIGN RIGHT //"N.Dias"

@ 125,05  BUTTON oBtnCons  CAPTION STR0026 SIZE 40,10 ACTION ConsultaCQ(aItems) OF oFld2 //"Consulta"
@ 125,55  BUTTON oBtnCalc  CAPTION STR0027 SIZE 40,10 ACTION CalculaPM(aItems)   OF oFld2 //"Calcula"
//@ 125,105 BUTTON oBtnGrvCQ  CAPTION "G" ACTION GravaCheq(aItems,oBrw,aGets) CANCEL SIZE 20,10 OF oFld2
@ 125,130 BUTTON oBtnMenos  CAPTION "-" ACTION ExcCheque(oBrw,aItems,@nSaldo,oSaldo) CANCEL SIZE 20,10 OF oFld2
//AADD( aObjs, oBtnMenos )

SetArray(oBrw,aItems)

ACTIVATE DIALOG oDlg

Return nil

/*********************************************************************************/
/* Funcao: AddCheque
/* Adiciona Items e modifica o array do objeto Browse                            */
/*********************************************************************************/
Function AddCheque(oBrw,aItems,cBanco,cAgencia,cCheque,nValor,dVencto,cCnpj,cCli,cCta,cMes,cAno,nSaldo,oSaldo,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9,oGet10,dDataBase,aGets)
Local nRec 
Local nDias:=0
Local aItGravar:={}

if Empty(cBanco) .or. Empty(cCheque) .Or. nvalor=0
   Alert(STR0028) //"Nao foram preenchidos todos os campos"
   Return Nil
endif
//Pesquisar no Array para saber se o cheque ja foi lancado
nRec:= ScanArray( aItems,cCheque,,,5)  
if nRec >0 .And. AItems[nRec,2]=cBanco
   Alert( STR0029 ) //"Cheque ja existe!"
Else
   if dVencto>dDatabase
     nDias:=dVencto - dDatabase
   endif
   AADD(aItems,{"",cBanco,cAgencia,cCta,cCheque,nValor,dVencto,cCli,cCnpj,cMes,cAno,nDias})
   
   //Grava o cheque na base 
   GravaCheq(oBrw,aItems,aGets) 

   //Atualizar o saldo devido
   nSaldo:=nSaldo-nValor
   SetText( oSaldo, nSAldo )
   // Limpa as variaveis para evitar redundancia de valores
   cCheque:=""
   nValor :=0
   dVencto:=ctod("")
   SetText(oGet4,cCheque )   
   SetText(oGet5,nValor  )
   SetText(oGet6,dVencto )
   SetFocus(oGet4)
endif

Return nil

/*********************************************************************************/
/* Funcao: Chama_kb
/* Chama o teclado para atualizar o Get
/*********************************************************************************/
Function chama_kb(nTpTecla,cVarGet)
KeyBoard(nTpTecla,cVarGet )

Return Nil

/*********************************************************************************/
/* Funcao: CallGetDate                                                           */
/* Mostra a utilizacao da funcao GetDate()                                       */
/*********************************************************************************/
Function CallGetDate(oGet5,dVencto)

dVencto:= SelectDate(STR0030,date()) //"Selecione data..."

SetText(oGet5,dVencto)

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GravaCheq           ³Autor: Marcelo Vieira³ Data ³17/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava registros de cheques				     			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aItems - Array dos Dados; oBrw - Objeto do Browse          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GravaCheq(oBrw,aItems,aGets) 
Local i := 0, cFil:="  "     
Local cTable := "HEF"+cEmpresa

If !File(cTable)
	MsgStop(STR0031 + cTable + STR0032,STR0033) //"Não é possível gravar. Tabela de Cheque "###" não encontrada!"###"Aviso"
	Return Nil
EndIf

If !MsgYesOrNo(STR0034,STR0001) //"Confirma Gravação dos Cheques ?"###"Cheques"
	Return
EndIf

dbSelectArea("HEF")
dbSetOrder(1)

Alert( len(aGets) )                     
cMsg:="" 
For  ii:=1 to Len( aGets )
     if Valtype(aGets[ii])=="N" 
        cMsg:=Str(aGets[ii])
     Elseif aGets[ii]==Nil 
        cMsg:="NIL"
     Elseif Valtype(aGets[ii])=="D" 
        cMsg:=dtoC(aGets[ii])
     Else
        cMsg:=aGets[ii]     
     endif
     MsgAlert( cMsg, str(ii) ) 
Next                        
  
//alert(  cFil + aGets[18,1]+aGets[15,1]+aGets[16,1]+aGets[17,1] )
ALERT( aGets[18,1] )
ALERT( aGets[15,1] )
ALERT( aGets[16,1] )
ALERT( aGets[17,1] )

           //EF_FILIAL+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA TO HEF3001  
if !dbSeek( RetFilial("HEF") + Str(aGets[18,1])+ Str(aGets[15,1])+ Str(aGets[16,1])+ Str(aGets[17,1]) )
	HEF->( dbAppend() )
	HEF->HEF_FILIAL := RetFilial("HEF")
	HEF->EF_PREFIXO := ""
	HEF->EF_TITULO  := aGets[1,1]
	HEF->EF_PARCELA := aGets[2,1]
	HEF->EF_TIPO    := ""        
	HEF->EF_DATA    := aGets[3,1]
	HEF->EF_BANCO   := aGets[15,1]
	HEF->EF_AGENCIA := aGets[16,1]
	HEF->EF_CONTA   := aGets[17,1]
	HEF->EF_NUM     := aGets[18,1]
	HEF->EF_VALOR   := aGets[19,1]
	HEF->EF_IMPRESS := ""
	HEF->EF_HIST    := STR0035 //"Valor pago s/ Titulo"
	HEF->EF_NUMNOTA := aGets[1,1]
	HEF->EF_SERIE   := ""
	HEF->EF_VENCTO  := aGets[20,1]
	HEF->EF_VALORBX := aGets[19,1]
	HEF->EF_CLIENTE := aGets[6,1]
	HEF->EF_LOJACLI := aGets[7,1]
	HEF->EF_CPFCNPJ := aGets[22,1]
	HEF->EF_EMITENT := ""
	HEF->EF_STATUS  := "N"
	HEF->( dbCommit() )
	
	Alert(STR0036) //"Cheque(s) gravado(s) com sucesso."

EndIf

SetArray(oBrw, aItems )

Return Nil
