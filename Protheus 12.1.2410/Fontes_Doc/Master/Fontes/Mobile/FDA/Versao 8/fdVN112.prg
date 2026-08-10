#INCLUDE "FDVN112.ch"
#include "eADVPL.ch"

Function ATChange(aObj,nCbx)
if nCbx == 1
  AtShowHide(aObj,2,.F. )
  AtShowHide(aObj,3,.F. )
  AtShowHide(aObj,4,.F. )
  AtShowHide(aObj,1,.T. )
Elseif nCbx == 2
  AtShowHide(aObj,1,.F. )
  AtShowHide(aObj,3,.F. )
  AtShowHide(aObj,4,.F. )
  AtShowHide(aObj,2,.T. )
elseif nCbx == 3
  AtShowHide(aObj,1,.F. )
  AtShowHide(aObj,2,.F. )
  AtShowHide(aObj,4,.F. )
  AtShowHide(aObj,3,.T. )
elseif nCbx == 4
  AtShowHide(aObj,1,.F. )
  AtShowHide(aObj,2,.F. )
  AtShowHide(aObj,3,.F. )
  AtShowHide(aObj,4,.T. )
endif
Return Nil


Function AtShowHide(aObj, nCbx,lShow )
Local i
For i := 1 to Len(aObj[nCbx])
   If lShow
      ShowControl(aObj[nCbx,i])
   Else
      HideControl(aObj[nCbx,i])
   EndIf
Next
Return Nil
                           
Function ATSaldo(nSldTot,nValRec,nSldAtu,nSaldoReal,oObj) 
Local lRet := .t.
nSldAtu := nSaldoReal - nValRec

If nSldAtu < 0
	//SetFocus(oObj)
	MsgAlert(STR0001,STR0002) //"Pago maior que Saldo Actual"###"Aviso"
	return .f.
Endif

SetText(oObj,nSldAtu)
Return lRet


Function ATSair(aPedido,aDev,nAtend)
Local cResp:=""
cResp:= if(MsgYesOrNo(STR0003,STR0004),"Sim","Nao")  //"¿Desea Salir el Atencion?"###"Atencion"
if cResp = "Sim"
	if Len(aPedido) > 0 .Or. Len(aDev) > 0
		nAtend := 1
	Endif
	CloseDialog()
Endif
Return Nil      

//Rotina que monta o array com os saldos do cliente
Function CalcSaldos(cCodCli,cLojaCli,nAtend,aSaldo,nSldTot)
Local nSldAnt:=0,nVndAtu:=0,nValDev:=0,nValCompens:=0
Local nPagos:=0,nSldFinal:=0,nSaldoReal:=0             

If Len(aSaldo) > 0
	aSize(aSaldo,0)
Endif

MsgStatus(STR0005) //"Aguarde..."

dbSelectArea("HA1")
dbSetOrder(1)
dbgotop()
dbSeek(RetFilial("HA1")+cCodCli+cLojaCli)
If HA1->(Found())
	nSldAnt := HA1->A1_SALDUP
	nSldTot := 0
Endif     

dbSelectArea("HC5")
dbSetOrder(2)
dbSeek(RetFilial("HC5")+cCodCli+cLojaCli,.f.)
While !Eof() .And. HC5->HC5_FILIAL == RetFilial("HC5") .and. HC5->C5_CLI == cCodCli .and. HC5->C5_LOJA == cLojaCli
    If HC5->C5_STATUS = "N" .and. HC5->C5_EMISS = dDataBase
    	nVndAtu := nVndAtu + HC5->C5_VALOR
    Endif
	HC5->(dbSkip())
Enddo

dbSelectArea("HF1")
dbSetOrder(2) 
dbSeek(RetFilial("HF1")+cCodCli+cLojaCli,.f.)
While !Eof() .And. HF1->HF1_FILIAL == RetFilial("HF1") .and. HF1->F1_FORNECE == cCodCli .and. HF1->F1_LOJA == cLojaCli
    If HF1->F1_EMISSAO = dDataBase .And. HF1->F1_STATUS = "N"
	    nValDev := nValDev + HF1->F1_VALOR
	Endif

	HF1->(dbSkip())
Enddo

//Saldo Total = (Sld. Anterior + Vendas do dia) - Devolucoes
nSldTot := (nSldAnt + nVndAtu) - nValDev

//Totalizar os recebimentos
dbSelectArea("HEL") 
dbSetOrder(1)
dbSeek(RetFilial("HEL")+cCodCli+cLojaCli,.f.)
While !Eof() .And. HEL->HEL_FILIAL == RetFilial("HEL") .and. HEL->EL_CLIENTE == cCodCli .and. HEL->EL_LOJA == cLojaCli
    If HEL->EL_EMISSAO = dDataBase 
    	nPagos := nPagos + HEL->EL_VALOR
    	If HEL->EL_TIPODOC <> "EF"
	    	//Valores a compensar (Credito ou deposito)
    		nValCompens += HEL->EL_VALOR
    	Endif
    Endif
	HEL->(dbSkip())
Enddo

//Saldo Real (sem os valores a compensar)
nSaldoReal := nSldTot - (nPagos - nValCompens)

//Saldo Previsto = Total - Pagamentos
nSldFinal := nSldTot - nPagos

aadd(aSaldo, {STR0006, nSldAnt } )    //"Saldo Anterior"
aadd(aSaldo, {STR0007, nVndAtu } )    //"Venta del dia"
aadd(aSaldo, {STR0008, nValDev } )    //"Devolución"
aadd(aSaldo, {STR0009, nSldTot } )    //"Total"
aadd(aSaldo, {STR0010, nPagos } )     //"Pago"
aadd(aSaldo, {STR0011, nSaldoReal } ) //"Saldo Real"
aadd(aSaldo, {STR0012, nSldFinal } )  //"Saldo Previsto"

ClearStatus()

Return nil

Function MovData(dDatDep,oDtDep)
Local dData :=dDataBase
if !Empty(dDatDep) .And. !dDatDep=Nil 
	dDatDep := SelectDate(STR0013,dDatDep)  //"Seleccione Data"
else
	dDatDep := SelectDate(STR0013,dData)  //"Seleccione Data"
Endif
SetText(oDtDep,dDatDep)
Return nil