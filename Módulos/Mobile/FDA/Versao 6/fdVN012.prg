#INCLUDE "FDVN012.ch"
#include "eADVPL.ch"

Function ManutPagto(nOperacao,cCodCli,cLojaCli,nAtend,nSldTot,oBrwForma,aForma,aPedido)
// nOperacao => 1=Inclusao ; 2=Alteracao
Local oForma, oCbx //,oBrw,oObj, oGet , oCol
Local aCbx := {STR0028,STR0029,STR0030,STR0031} //"EF-DINHEIRO"###"CH-CHEQUE"###"VA-VALES"###"TF-DEPOSITO"
Local aObj :=  { {},{},{}, {} }
Local aCmpBanco:={}, aIndBanco:={}
Local nCbx :=1, i:=1, nRec:=0
Local cCliente	:= ""	
Local cCond		:= ""

//Todos
Local nValRec := 0
Local nSaldoReal := 0
Local nSldAtu := 0
Local nRecebido := 0

// CHEQUE
Local cNumCh := ""
Local cBanco := ""  
Local cNumAg := ""
Local nValCh := 0.00

// DEPOSITO
Local dDatDep := Date()

//Consulta Banco
Aadd(aCmpBanco,{STR0032,HA6->(FieldPos("A6_COD")),30}) //"Código"
Aadd(aCmpBanco,{STR0033,HA6->(FieldPos("A6_NOME")),100}) //"Nome"
Aadd(aIndBanco,{STR0032,1}) //"Código"

//Totaliza os pagamentos (pagos)
For i:=1 to Len(aForma)
	nRecebido += aForma[i,3]
Next

//Busca Saldo dos Titulos
If nSaldoReal==0
    dbSelectArea("HE1")
    dbSetOrder(1)       
    dbSeek(cCodCli+cLojaCli,.f.)
    While HE1->(!Eof()) .And.  (HE1->E1_CLIENTE == cCodCli .And. HE1->E1_LOJA == cLojaCli)
       nSaldoReal := nSaldoReal + HE1->E1_SALDO 
       HE1->(dbSkip())        
    Enddo
Endif

nSldTot := nSaldoReal - nRecebido
nSaldoReal := nSaldoReal - nRecebido
//nSldAtu	:= nSaldoReal 

nRec:=GridRow(oBrwForma)  

If nOperacao == 2 //Alteracao
								 
	If Alltrim(aForma[nRec,5])==STR0034  //"Transmitido"
		msgAlert(STR0035 , STR0001  )    //"Recebimento ja transmitido, nao pode ser alterado"###"Atencao"
 		Return
	Endif

	If Len(aForma) <= 0
		MsgAlert(STR0015,STR0016) //"No ha registro seleccionado"###"Aviso"
		return nil
	Endif
	LoadPagto(cCodCli,cLojaCli,nAtend,nSldTot,oBrwForma,;
	aForma,@nSaldoReal,@nSldAtu,@nValRec,@cNumCh,@cBanco,@dDatDep,@nCbx,@cCond)
	//Atualizar o saldo total com o item corrente
	nSldTot := nSldTot + nValRec
	nSaldoReal := nSaldoReal + nValRec
Endif

dbSelectArea("HA1")
dbSetOrder(1)
dbSeek(cCodCli+cLojaCli)
If HA1->(Found())
	cCliente := HA1->A1_COD+"/"+HA1->A1_LOJA+" - "+HA1->A1_NREDUZ
	If HA1->A1_STATUS == "N" //Cliente Novo (somente effectivo)
		aSize(aCbx,0)
		aadd(aCbx,STR0036) //"R$-DINHEIRO"
	Endif
Endif

DEFINE DIALOG oForma TITLE STR0001 //"Atencion"
    
@ 21,02 TO 135,158 CAPTION STR0037 OF oForma //"Recebimento"

@ 28,05 GET oObj VAR cCliente SIZE 149,12 READONLY MULTILINE OF oForma

@ 45,10 SAY STR0017 OF oForma //"Tipo:"
@ 45,32 COMBOBOX oCbx VAR nCbx ITEMS aCbx ACTION ATChange(aObj,nCbx) SIZE 110,50 OF oForma

//EFECTIVO
@ 60,10 SAY oObj PROMPT STR0018 OF oForma //"Saldo Total"
AADD(aObj[1],oObj)
@ 60,70 GET oObj VAR nSldTot READONLY PICTURE "@E 999,999.99" SIZE 70,15 of oForma
AADD(aObj[1],oObj)

@ 72,10 SAY oObj PROMPT STR0010 OF oForma //"Pago"
AADD(aObj[1],oObj)
@ 72,70 GET oObj VAR nValRec PICTURE "@E 999,999.99" ;
VALID ATSaldo(nSldTot,nValRec,@nSldAtu,nSaldoReal,aObj[1,6])  SIZE 70,15 of oForma
AADD(aObj[1],oObj)

@ 84,10 SAY oObj PROMPT STR0019 OF oForma //"Saldo Actual"
AADD(aObj[1],oObj)
@ 84,70 GET oObj VAR nSldAtu READONLY PICTURE "@E 999,999.99" SIZE 70,15 of oForma
AADD(aObj[1],oObj)
  
// CHEQUE
@ 60,10 SAY oObj PROMPT STR0018 OF oForma //"Saldo Total"
AADD(aObj[2],oObj)
@ 60,70 GET oObj VAR nSldTot READONLY PICTURE "@E 999,999.99" SIZE 70,15 of oForma
AADD(aObj[2],oObj)
@ 73,10 SAY oObj PROMPT STR0022 OF oForma //"Importe"
AADD(aObj[2],oObj)
@ 73,70 GET oObj VAR nValRec PICTURE "@E 999,999.99" ;
VALID ATSaldo(nSldTot,nValRec,@nSldAtu,nSaldoReal,aObj[2,12]) SIZE 70,15 of oForma
AADD(aObj[2],oObj)    
@ 86,10 SAY oObj PROMPT STR0020 OF oForma  //"No.Cheque"
AADD(aObj[2],oObj)
@ 86,70 GET oObj VAR cNumCh SIZE 70,15 of oForma
AADD(aObj[2],oObj)
@ 100,10 SAY oObj PROMPT STR0027 OF oForma  //"Agencia"
AADD(aObj[2],oObj)    
@ 100,70 GET oObj VAR cNumAg SIZE 20,15 of oForma
AADD(aObj[2],oObj)    
@ 100,95 BUTTON oObj CAPTION STR0021 ACTION SFConsPadrao("HA6",@cBanco,aObj[2,10],aCmpBanco,aIndBanco,) OF oForma //"Banco"
AADD(aObj[2],oObj)                                
@ 100,132 GET oObj VAR cBanco SIZE 22,15 of oForma
AADD(aObj[2],oObj)            
@ 113,10 SAY oObj PROMPT STR0019 OF oForma //"Saldo Actual"
AADD(aObj[2],oObj)
@ 113,70 GET oObj VAR nSldAtu READONLY PICTURE "@E 999,999.99" SIZE 70,15 of oForma
AADD(aObj[2],oObj)

//VALES
@ 60,10 SAY oObj PROMPT STR0018 OF oForma //"Saldo Total"
AADD(aObj[3],oObj)
@ 60,70 GET oObj VAR nSldTot READONLY PICTURE "@E 999,999.99" SIZE 70,15 of oForma
AADD(aObj[3],oObj)
@ 73,10 SAY oObj PROMPT STR0010 OF oForma //"Pago"
AADD(aObj[3],oObj)
@ 73,70 GET oObj VAR nValRec PICTURE "@E 999,999.99" ;
VALID ATSaldo(nSldTot,nValRec,@nSldAtu,nSaldoReal,aObj[3,6]) SIZE 70,15 of oForma
AADD(aObj[3],oObj)
@ 86,10 SAY oObj PROMPT STR0019 OF oForma //"Saldo Actual"
AADD(aObj[3],oObj)
@ 86,70 GET oObj VAR nSldAtu READONLY PICTURE "@E 999,999.99" SIZE 70,15 of oForma
AADD(aObj[3],oObj)

//DEPOSITO
@ 60,10 SAY oObj PROMPT STR0018 OF oForma //"Saldo Total"
AADD(aObj[4],oObj)
@ 60,70 GET oObj VAR nSldTot READONLY PICTURE "@E 999,999.99" SIZE 70,15 of oForma
AADD(aObj[4],oObj)
@ 74,10 SAY oObj PROMPT STR0010 OF oForma //"Pago"
AADD(aObj[4],oObj)
@ 74,70 GET oObj VAR nValRec PICTURE "@E 999,999.99" ;
VALID ATSaldo(nSldTot,nValRec,@nSldAtu,nSaldoReal,aObj[4,6])  SIZE 70,15 of oForma
AADD(aObj[4],oObj)
@ 87,10 SAY oObj PROMPT STR0019 OF oForma //"Saldo Actual"
AADD(aObj[4],oObj)
@ 87,70 GET oObj VAR nSldAtu READONLY PICTURE "@E 999,999.99" SIZE 70,15 of oForma
AADD(aObj[4],oObj)
@ 101,10 BUTTON oObj CAPTION STR0024 ACTION MovData(dDatDep,aObj[4,8]) SIZE 32,12 of oForma //"Data"
AADD(aObj[4],oObj)
@ 101,70 GET oObj VAR dDatDep SIZE 70,15 of oForma
AADD(aObj[4],oObj)

@ 140,60 BUTTON oObj CAPTION STR0025 ; //"Grabar"
ACTION GrvPagto(nOperacao,cCodCli,cLojaCli,aObj,aCbx,nCbx,oBrwForma,;
aForma,nValRec,cNumCh,cBanco,dDatDep,cCond,nSldTot,aPedido,cNumAg) ;
SIZE 45,15 OF oForma

@ 140,110 BUTTON oObj CAPTION STR0026 ACTION CloseDialog() SIZE 45,15 OF oForma //"Anular"

ATChange(aObj,nCbx)

ACTIVATE DIALOG oForma

Return Nil
